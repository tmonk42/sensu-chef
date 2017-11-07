use_inline_resources

action :create do
  definitions = Sensu::Helpers.select_attributes(
    node["sensu"]["enterprise-dashboard"],
    %w(dashboard sensu)
  )

  data_bag_name = node["sensu"]["enterprise-dashboard"]["data_bag"]["name"]
  config_item = node["sensu"]["enterprise-dashboard"]["data_bag"]["config_item"]

  begin
    config = data_bag_item(data_bag_name, config_item) # missingok: true ???
  rescue
    # noop
  end

  if config
    definitions = Chef::Mixin::DeepMerge.merge(definitions, config.to_hash)
  end

  f = sensu_json_file ::File.join(node["sensu"]["directory"], "dashboard.json") do
    content Sensu::Helpers.sanitize(definitions)
  end

  new_resource.updated_by_last_action(f.updated_by_last_action?)
end
