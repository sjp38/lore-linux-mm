Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 613486B004D
	for <linux-mm@kvack.org>; Fri,  6 Jan 2012 05:52:29 -0500 (EST)
Message-ID: <4F06D22D.9060906@hitachi.com>
Date: Fri, 06 Jan 2012 19:51:25 +0900
From: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
MIME-Version: 1.0
Subject: Re: [PATCH v8 3.2.0-rc5 9/9] perf: perf interface for uprobes
References: <20111216122756.2085.95791.sendpatchset@srdronam.in.ibm.com> <20111216122951.2085.95511.sendpatchset@srdronam.in.ibm.com>
In-Reply-To: <20111216122951.2085.95511.sendpatchset@srdronam.in.ibm.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Rothwell <sfr@canb.auug.org.au>, yrl.pp-manager.tt@hitachi.com

Hi Srikar,

I have some comments on it.

(2011/12/16 21:29), Srikar Dronamraju wrote:
[...]
> diff --git a/tools/perf/util/probe-event.c b/tools/perf/util/probe-event.c
> index d54eefb..2c4ec61 100644
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
> @@ -73,6 +74,8 @@ static int e_snprintf(char *str, size_t size, const char *format, ...)
>  }
>  
>  static char *synthesize_perf_probe_point(struct perf_probe_point *pp);
> +static int convert_name_to_addr(struct perf_probe_event *pev,
> +				const char *exec);
>  static struct machine machine;
>  
>  /* Initialize symbol maps and path of vmlinux/modules */
> @@ -173,6 +176,31 @@ const char *kernel_get_module_path(const char *module)
>  	return (dso) ? dso->long_name : NULL;
>  }
>  
> +static int init_perf_uprobes(void)

This would be better called as init_user_exec().

> +{
> +	int ret = 0;
> +
> +	symbol_conf.try_vmlinux_path = false;
> +	symbol_conf.sort_by_name = true;
> +	ret = symbol__init();
> +	if (ret < 0)
> +		pr_debug("Failed to init symbol map.\n");
> +
> +	return ret;
> +}

and this can be used in show_available_funcs() too.

> +
> +static int convert_to_perf_probe_point(struct probe_trace_point *tp,
> +					struct perf_probe_point *pp)
> +{
> +	pp->function = strdup(tp->symbol);
> +	if (pp->function == NULL)
> +		return -ENOMEM;
> +	pp->offset = tp->offset;
> +	pp->retprobe = tp->retprobe;
> +
> +	return 0;
> +}

This function could be used in kprobe_convert_to_perf_probe() too.
In that case, it will be separated as a cleanup from this.

>  #ifdef DWARF_SUPPORT
>  /* Open new debuginfo of given module */
>  static struct debuginfo *open_debuginfo(const char *module)
> @@ -281,6 +309,15 @@ static int try_to_find_probe_trace_events(struct perf_probe_event *pev,
>  	struct debuginfo *dinfo = open_debuginfo(target);

You need not to call open_debuginfo() when it is a uprobe.

>  	int ntevs, ret = 0;
>  
> +	if (pev->uprobes) {
> +		if (need_dwarf) {
> +			pr_warning("Debuginfo-analysis is not yet supported"
> +					" with -x/--exec option.\n");
> +			return -ENOSYS;
> +		}
> +		return convert_name_to_addr(pev, target);
> +	}
> +
>  	if (!dinfo) {
>  		if (need_dwarf) {
>  			pr_warning("Failed to open debuginfo file.\n");
[...]
> @@ -887,6 +921,11 @@ static int parse_perf_probe_point(char *arg, struct perf_probe_event *pev)
>  		return -EINVAL;
>  	}
>  
> +	if (pev->uprobes && !pp->function) {
> +		semantic_error("No function specified for uprobes");
> +		return -EINVAL;
> +	}

I think this check would better be done when converting
function to address.

>  	if ((pp->offset || pp->line || pp->lazy_line) && pp->retprobe) {
>  		semantic_error("Offset/Line/Lazy pattern can't be used with "
>  			       "return probe.\n");
> @@ -896,6 +935,11 @@ static int parse_perf_probe_point(char *arg, struct perf_probe_event *pev)
>  	pr_debug("symbol:%s file:%s line:%d offset:%lu return:%d lazy:%s\n",
>  		 pp->function, pp->file, pp->line, pp->offset, pp->retprobe,
>  		 pp->lazy_line);
> +
> +	if (pev->uprobes && perf_probe_event_need_dwarf(pev)) {
> +		semantic_error("no dwarf based probes for uprobes.");
> +		return -EINVAL;
> +	}

Hmm, this also would be done in converting phase.

>  	return 0;
>  }
>  
> @@ -1047,7 +1091,8 @@ bool perf_probe_event_need_dwarf(struct perf_probe_event *pev)
>  {
>  	int i;
>  
> -	if (pev->point.file || pev->point.line || pev->point.lazy_line)
> +	if ((pev->point.file && !pev->uprobes) || pev->point.line ||
> +					pev->point.lazy_line)

point.file will point a source file, not executable file.

>  		return true;
>  
>  	for (i = 0; i < pev->nargs; i++)
> @@ -1344,11 +1389,17 @@ char *synthesize_probe_trace_command(struct probe_trace_event *tev)
>  	if (buf == NULL)
>  		return NULL;
>  
> -	len = e_snprintf(buf, MAX_CMDLEN, "%c:%s/%s %s%s%s+%lu",
> -			 tp->retprobe ? 'r' : 'p',
> -			 tev->group, tev->event,
> -			 tp->module ?: "", tp->module ? ":" : "",
> -			 tp->symbol, tp->offset);
> +	if (tev->uprobes)
> +		len = e_snprintf(buf, MAX_CMDLEN, "%c:%s/%s %s",
> +				 tp->retprobe ? 'r' : 'p',
> +				 tev->group, tev->event, tp->symbol);
> +	else
> +		len = e_snprintf(buf, MAX_CMDLEN, "%c:%s/%s %s%s%s+%lu",
> +				 tp->retprobe ? 'r' : 'p',
> +				 tev->group, tev->event,
> +				 tp->module ?: "", tp->module ? ":" : "",
> +				 tp->symbol, tp->offset);

I think tp->module should be the executable file even when
tp is a user space probe, because when parsing the uprobes list
in tracing/trace_uprobes, exec file will be stored in tp->module.

> +
>  	if (len <= 0)
>  		goto error;
>  
[...]
>  
> -/* Get raw string list of current kprobe_events */
> +static int open_kprobe_events(bool readwrite)
> +{
> +	return open_probe_events(readwrite, 1);
> +}
> +
> +static int open_uprobe_events(bool readwrite)
> +{
> +	return open_probe_events(readwrite, 0);
> +}

Hmm, I'd rather like to have
 open_probe_events(const char *fname, bool rw)
and print errors in each open_u/kprobe_events().


> +
> +/* Get raw string list of current kprobe_events  or uprobe_events */
>  static struct strlist *get_probe_trace_command_rawlist(int fd)
>  {
>  	int ret, idx;
[...]
> @@ -2065,30 +2180,150 @@ static int filter_available_functions(struct map *map __unused,
>  	return 1;
>  }
>  
> -int show_available_funcs(const char *target, struct strfilter *_filter)
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
> -	map = kernel_get_module_map(target);
> +	map = kernel_get_module_map(module);
>  	if (!map) {
> -		pr_err("Failed to find %s map.\n", (target) ? : "kernel");
> +		pr_err("Failed to find %s map.\n", (module) ? : "kernel");
>  		return -EINVAL;
>  	}
> +	return __show_available_funcs(map);
> +}

I think we'd better introduce available_user_funcs() here too.

> +
> +int show_available_funcs(const char *target, struct strfilter *_filter,
> +					bool user)
> +{
> +	struct map *map;
> +	int ret;
> +
> +	setup_pager();
>  	available_func_filter = _filter;
> +
> +	if (!user)
> +		return available_kernel_funcs(target);
> +
> +	symbol_conf.try_vmlinux_path = false;
> +	symbol_conf.sort_by_name = true;
> +	ret = symbol__init();
> +	if (ret < 0) {
> +		pr_err("Failed to init symbol map.\n");
> +		return ret;
> +	}
> +	map = dso__new_map(target);
> +	ret = __show_available_funcs(map);
> +	dso__delete(map->dso);
> +	map__delete(map);
> +	return ret;
> +}
> +
> +#define DEFAULT_FUNC_FILTER "!_*"

This is a hidden rule for users ... please remove it.
(or, is there any reason why we need to have it?)

> +
> +/*
> + * uprobe_events only accepts address:
> + * Convert function and any offset to address
> + */
> +static int convert_name_to_addr(struct perf_probe_event *pev, const char *exec)
> +{

I'm not sure why wouldn't you convert function to "vaddr",
instead of "exec:vaddr"?

Thank you,

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
