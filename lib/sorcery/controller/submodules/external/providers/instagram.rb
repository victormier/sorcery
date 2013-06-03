module Sorcery
  module Controller
    module Submodules
      module External
        module Providers
          # This module adds support for OAuth with instagram.com.
          # When included in the 'config.providers' option, it adds a new option, 'config.instagram'.
          # Via this new option you can configure instagram specific settings like your app's key and secret.
          #
          #   config.instagram.key = <key>
          #   config.instagram.secret = <secret>
          #   ...
          #
          module Instagram
            def self.included(base)
              base.module_eval do
                class << self
                  attr_reader :instagram

                  def merge_instagram_defaults!
                    @defaults.merge!(:@instagram => InstagramClient)
                  end
                end
                merge_instagram_defaults!
                update!
              end
            end

            module InstagramClient
              class << self
                attr_accessor :key,
                              :secret,
                              :callback_url,
                              :auth_path,
                              :token_path,
                              :site,
                              :scope,
                              :user_info_path,
                              :user_info_mapping
                attr_reader   :access_token

                include Protocols::Oauth2

                def init
                  @site           = "https://api.instagram.com"
                  @user_info_path = "https://api.instagram.com/users/self"
                  @scope          = 'basic'
                  @auth_path      = "/oauth/authorize"
                  @token_path     = "/oauth/access_token"
                  @user_info_mapping = {}
                end

                def get_user_hash
                  user_hash = {}
                  user_hash[:user_info] = @access_token.params['user']
                  user_hash[:uid] = user_hash[:user_info]['id']
                  user_hash
                end

                def has_callback?
                  true
                end

                # calculates and returns the url to which the user should be redirected,
                # to get authenticated at the external provider's site.
                def login_url(params,session)
                  self.authorize_url({:authorize_url => @auth_path})
                end

                # tries to login the user from access token
                def process_callback(params,session)
                  args = {}
                  args.merge!({:code => params[:code]}) if params[:code]
                  options = {
                    :token_url    => @token_path,
                    :token_method => :post
                  }
                  @access_token = self.get_access_token(args, options)
                end

              end
              init
            end

          end
        end
      end
    end
  end
end
