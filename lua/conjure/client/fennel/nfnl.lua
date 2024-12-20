-- [nfnl] Compiled from fnl/conjure/client/fennel/nfnl.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("nfnl.module")
local autoload = _local_1_["autoload"]
local ts = autoload("conjure.tree-sitter")
local config = autoload("conjure.config")
local text = autoload("conjure.text")
local log = autoload("conjure.log")
local core = autoload("nfnl.core")
local fennel = autoload("nfnl.fennel")
local str = autoload("nfnl.string")
local repl = autoload("nfnl.repl")
local fs = autoload("nfnl.fs")
local comment_node_3f = ts["lisp-comment-node?"]
local function form_node_3f(node)
  return ts["node-surrounded-by-form-pair-chars?"](node, {{"#(", ")"}})
end
local buf_suffix = ".fnl"
local comment_prefix = "; "
config.merge({client = {fennel = {nfnl = {}}}})
if config["get-in"]({"mapping", "enable_defaults"}) then
  config.merge({client = {fennel = {nfnl = {mapping = {}}}}})
else
end
local cfg = config["get-in-fn"]({"client", "fennel", "nfnl"})
local repls = {}
local function repl_for_path(path)
  local _4_
  do
    local t_3_ = repls
    if (nil ~= t_3_) then
      t_3_ = t_3_[path]
    else
    end
    _4_ = t_3_
  end
  if _4_ then
    return repls[path]
  else
    local r = repl.new()
    repls[path] = r
    return r
  end
end
local function module_path(path)
  if path then
    local parts = fs["split-path"](fs["file-name-root"](path))
    local fnl_and_below
    local function _7_(_241)
      return (_241 ~= "fnl")
    end
    fnl_and_below = core["drop-while"](_7_, parts)
    if ("fnl" == core.first(fnl_and_below)) then
      return str.join(".", core.rest(fnl_and_below))
    else
      return nil
    end
  else
    return nil
  end
end
--[[ (module-path "~/repos/Olical/conjure/fnl/conjure/client/fennel/nfnl.fnl") ]]
local function eval_str(opts)
  local repl0 = repl_for_path(opts["file-path"])
  local results = repl0((opts.code .. "\n"))
  local result_strs = core.map(fennel.view, results)
  local lines = text["split-lines"](str.join("\n", result_strs))
  if ((("buf" == opts.origin) or ("file" == opts.origin)) and core["table?"](core.last(results))) then
    local mod_path = module_path(opts["file-path"])
    local mod = core.get(package.loaded, mod_path)
    package.loaded[mod_path] = core["merge!"](mod, core.last(results))
  else
  end
  return log.append(lines)
end
local function eval_file(opts)
  opts.code = core.slurp(opts["file-path"])
  if opts.code then
    return eval_str(opts)
  else
    return nil
  end
end
local function doc_str(opts)
  core.assoc(opts, "code", (",doc " .. opts.code))
  return eval_str(opts)
end
return {["comment-node?"] = comment_node_3f, ["form-node?"] = form_node_3f, ["buf-suffix"] = buf_suffix, ["module-path"] = module_path, ["repl-for-path"] = repl_for_path, ["comment-prefix"] = comment_prefix, ["eval-str"] = eval_str, ["eval-file"] = eval_file, ["doc-str"] = doc_str}
