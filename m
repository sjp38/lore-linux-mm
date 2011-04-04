Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 00DC38D003B
	for <linux-mm@kvack.org>; Mon,  4 Apr 2011 06:15:21 -0400 (EDT)
Message-ID: <4D999A2F.4020204@hitachi.com>
Date: Mon, 04 Apr 2011 19:15:11 +0900
From: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 2.6.39-rc1-tip 23/26] 23: perf: show possible probes
 in a given executable file or library.
References: <20110401143223.15455.19844.sendpatchset@localhost6.localdomain6> <20110401143707.15455.66114.sendpatchset@localhost6.localdomain6>
In-Reply-To: <20110401143707.15455.66114.sendpatchset@localhost6.localdomain6>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Thomas Gleixner <tglx@linutronix.de>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, SystemTap <systemtap@sources.redhat.com>, Andrew Morton <akpm@linux-foundation.org>

(2011/04/01 23:37), Srikar Dronamraju wrote:
> Enhances -F/--funcs option of "perf probe" to list possible probe points in
> an executable file or library. A new option -e/--exe specifies the path of
> the executable or library.

I think you'd better use -x for abbr. of --exe, since -e is used for --event
for other subcommands.

And also, it seems this kind of patch should be placed after perf-probe
uprobe support patch, because without uprobe support, user binary analysis
is meaningless. (In the result, this introduces -u/--uprobe option without
uprobe support)


> Show last 10 functions in /bin/zsh.
> 
> # perf probe -F -u -e /bin/zsh | tail

I also can't understand why -u is required even if we have -x for user
binaries and -m for kernel modules.

Thanks,

> zstrtol
> ztrcmp
> ztrdup
> ztrduppfx
> ztrftime
> ztrlen
> ztrncpy
> ztrsub
> zwarn
> zwarnnam
> 
> Show first 10 functions in /lib/libc.so.6
> 
> # perf probe -u -F -e /lib/libc.so.6 | head
> _IO_adjust_column
> _IO_adjust_wcolumn
> _IO_default_doallocate
> _IO_default_finish
> _IO_default_pbackfail
> _IO_default_uflow
> _IO_default_xsgetn
> _IO_default_xsputn
> _IO_do_write@@GLIBC_2.2.5
> _IO_doallocbuf
> 
> Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
> ---
>  tools/perf/builtin-probe.c    |    9 +++++--
>  tools/perf/util/probe-event.c |   56 +++++++++++++++++++++++++++++++----------
>  tools/perf/util/probe-event.h |    4 +--
>  tools/perf/util/symbol.c      |    8 ++++++
>  tools/perf/util/symbol.h      |    1 +
>  5 files changed, 61 insertions(+), 17 deletions(-)
> 
> diff --git a/tools/perf/builtin-probe.c b/tools/perf/builtin-probe.c
> index 98db08f..6ceebea 100644
> --- a/tools/perf/builtin-probe.c
> +++ b/tools/perf/builtin-probe.c
> @@ -57,6 +57,7 @@ static struct {
>  	bool show_ext_vars;
>  	bool show_funcs;
>  	bool mod_events;
> +	bool uprobes;
>  	int nevents;
>  	struct perf_probe_event events[MAX_PROBES];
>  	struct strlist *dellist;
> @@ -249,6 +250,10 @@ static const struct option options[] = {
>  		 "Set how many probe points can be found for a probe."),
>  	OPT_BOOLEAN('F', "funcs", &params.show_funcs,
>  		    "Show potential probe-able functions."),
> +	OPT_BOOLEAN('u', "uprobe", &params.uprobes,
> +		    "user space probe events"),
> +	OPT_STRING('e', "exe", &params.target,
> +		   "executable", "userspace executable or library"),
>  	OPT_CALLBACK('\0', "filter", NULL,
>  		     "[!]FILTER", "Set a filter (with --vars/funcs only)\n"
>  		     "\t\t\t(default: \"" DEFAULT_VAR_FILTER "\" for --vars,\n"
> @@ -327,8 +332,8 @@ int cmd_probe(int argc, const char **argv, const char *prefix __used)
>  		if (!params.filter)
>  			params.filter = strfilter__new(DEFAULT_FUNC_FILTER,
>  						       NULL);
> -		ret = show_available_funcs(params.target,
> -					   params.filter);
> +		ret = show_available_funcs(params.target, params.filter,
> +					params.uprobes);
>  		strfilter__delete(params.filter);
>  		if (ret < 0)
>  			pr_err("  Error: Failed to show functions."
> diff --git a/tools/perf/util/probe-event.c b/tools/perf/util/probe-event.c
> index 09c53c1..cf77feb 100644
> --- a/tools/perf/util/probe-event.c
> +++ b/tools/perf/util/probe-event.c
> @@ -47,6 +47,7 @@
>  #include "trace-event.h"	/* For __unused */
>  #include "probe-event.h"
>  #include "probe-finder.h"
> +#include "session.h"
>  
>  #define MAX_CMDLEN 256
>  #define MAX_PROBE_ARGS 128
> @@ -1963,6 +1964,7 @@ int del_perf_probe_events(struct strlist *dellist)
>  
>  	return ret;
>  }
> +
>  /* TODO: don't use a global variable for filter ... */
>  static struct strfilter *available_func_filter;
>  
> @@ -1979,30 +1981,58 @@ static int filter_available_functions(struct map *map __unused,
>  	return 1;
>  }
>  
> -int show_available_funcs(const char *elfobject, struct strfilter *_filter)
> +static int __show_available_funcs(struct map *map)
> +{
> +	if (map__load(map, filter_available_functions)) {
> +		pr_err("Failed to load map.\n");
> +		return -EINVAL;
> +	}
> +	if (!dso__sorted_by_name(map->dso, map->type))
> +		dso__sort_by_name(map->dso, map->type);
> +
> +	dso__fprintf_symbols_by_name(map->dso, map->type, stdout);
> +	return 0;
> +}
> +
> +static int available_kernel_funcs(const char *module)
>  {
>  	struct map *map;
>  	int ret;
>  
> -	setup_pager();
> -
>  	ret = init_vmlinux();
>  	if (ret < 0)
>  		return ret;
>  
> -	map = kernel_get_module_map(elfobject);
> +	map = kernel_get_module_map(module);
>  	if (!map) {
> -		pr_err("Failed to find %s map.\n", (elfobject) ? : "kernel");
> +		pr_err("Failed to find %s map.\n", (module) ? : "kernel");
>  		return -EINVAL;
>  	}
> +	return __show_available_funcs(map);
> +}
> +
> +int show_available_funcs(const char *elfobject, struct strfilter *_filter,
> +					bool user)
> +{
> +	struct map *map;
> +	int ret;
> +
> +	setup_pager();
>  	available_func_filter = _filter;
> -	if (map__load(map, filter_available_functions)) {
> -		pr_err("Failed to load map.\n");
> -		return -EINVAL;
> -	}
> -	if (!dso__sorted_by_name(map->dso, map->type))
> -		dso__sort_by_name(map->dso, map->type);
>  
> -	dso__fprintf_symbols_by_name(map->dso, map->type, stdout);
> -	return 0;
> +	if (!user)
> +		return available_kernel_funcs(elfobject);
> +
> +	symbol_conf.try_vmlinux_path = false;
> +	symbol_conf.sort_by_name = true;
> +	ret = symbol__init();
> +	if (ret < 0) {
> +		pr_err("Failed to init symbol map.\n");
> +		return ret;
> +	}
> +	map = dso__new_map(elfobject);
> +	ret = __show_available_funcs(map);
> +	dso__delete(map->dso);
> +	map__delete(map);
> +	return ret;
>  }
> diff --git a/tools/perf/util/probe-event.h b/tools/perf/util/probe-event.h
> index 3434fc9..4c24a85 100644
> --- a/tools/perf/util/probe-event.h
> +++ b/tools/perf/util/probe-event.h
> @@ -128,8 +128,8 @@ extern int show_line_range(struct line_range *lr, const char *module);
>  extern int show_available_vars(struct perf_probe_event *pevs, int npevs,
>  			       int max_probe_points, const char *module,
>  			       struct strfilter *filter, bool externs);
> -extern int show_available_funcs(const char *module, struct strfilter *filter);
> -
> +extern int show_available_funcs(const char *module, struct strfilter *filter,
> +				bool user);
>  
>  /* Maximum index number of event-name postfix */
>  #define MAX_EVENT_INDEX	1024
> diff --git a/tools/perf/util/symbol.c b/tools/perf/util/symbol.c
> index f06c10f..eefeab4 100644
> --- a/tools/perf/util/symbol.c
> +++ b/tools/perf/util/symbol.c
> @@ -2606,3 +2606,11 @@ int machine__load_vmlinux_path(struct machine *self, enum map_type type,
>  
>  	return ret;
>  }
> +
> +struct map *dso__new_map(const char *name)
> +{
> +	struct dso *dso = dso__new(name);
> +	struct map *map = map__new2(0, dso, MAP__FUNCTION);
> +
> +	return map;
> +}
> diff --git a/tools/perf/util/symbol.h b/tools/perf/util/symbol.h
> index 713b0b4..3838909 100644
> --- a/tools/perf/util/symbol.h
> +++ b/tools/perf/util/symbol.h
> @@ -211,6 +211,7 @@ char dso__symtab_origin(const struct dso *self);
>  void dso__set_long_name(struct dso *self, char *name);
>  void dso__set_build_id(struct dso *self, void *build_id);
>  void dso__read_running_kernel_build_id(struct dso *self, struct machine *machine);
> +struct map *dso__new_map(const char *name);
>  struct symbol *dso__find_symbol(struct dso *self, enum map_type type, u64 addr);
>  struct symbol *dso__find_symbol_by_name(struct dso *self, enum map_type type,
>  					const char *name);
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/


-- 
Masami HIRAMATSU
Software Platform Research Dept. Linux Technology Center
Hitachi, Ltd., Yokohama Research Laboratory
E-mail: masami.hiramatsu.pt@hitachi.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
