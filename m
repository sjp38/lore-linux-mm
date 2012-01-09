Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 350816B005C
	for <linux-mm@kvack.org>; Mon,  9 Jan 2012 06:30:54 -0500 (EST)
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Mon, 9 Jan 2012 04:30:52 -0700
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q09BUIlI111980
	for <linux-mm@kvack.org>; Mon, 9 Jan 2012 04:30:18 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q09BUG4M019901
	for <linux-mm@kvack.org>; Mon, 9 Jan 2012 04:30:18 -0700
Date: Mon, 9 Jan 2012 16:52:36 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v8 3.2.0-rc5 9/9] perf: perf interface for uprobes
Message-ID: <20120109112236.GA10189@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20111216122756.2085.95791.sendpatchset@srdronam.in.ibm.com>
 <20111216122951.2085.95511.sendpatchset@srdronam.in.ibm.com>
 <4F06D22D.9060906@hitachi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <4F06D22D.9060906@hitachi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Rothwell <sfr@canb.auug.org.au>, yrl.pp-manager.tt@hitachi.com

> >  
> > +static int init_perf_uprobes(void)
> 
> This would be better called as init_user_exec().

okay

> > +{
> > +	int ret = 0;
> > +
> > +	symbol_conf.try_vmlinux_path = false;
> > +	symbol_conf.sort_by_name = true;
> > +	ret = symbol__init();
> > +	if (ret < 0)
> > +		pr_debug("Failed to init symbol map.\n");
> > +
> > +	return ret;
> > +}
> 
> and this can be used in show_available_funcs() too.

Okay.

> 
> > +
> > +static int convert_to_perf_probe_point(struct probe_trace_point *tp,
> > +					struct perf_probe_point *pp)
> > +{
> > +	pp->function = strdup(tp->symbol);
> > +	if (pp->function == NULL)
> > +		return -ENOMEM;
> > +	pp->offset = tp->offset;
> > +	pp->retprobe = tp->retprobe;
> > +
> > +	return 0;
> > +}
> 
> This function could be used in kprobe_convert_to_perf_probe() too.
> In that case, it will be separated as a cleanup from this.

Do you mean kprobe_convert_to_perf_probe under #ifdef DWARF_SUPPORT?
because kprobe_convert_to_perf_probe under ifndef DWARF_SUPPORT already
uses convert_to_perf_probe_point.

> 
> >  #ifdef DWARF_SUPPORT
> >  /* Open new debuginfo of given module */
> >  static struct debuginfo *open_debuginfo(const char *module)
> > @@ -281,6 +309,15 @@ static int try_to_find_probe_trace_events(struct perf_probe_event *pev,
> >  	struct debuginfo *dinfo = open_debuginfo(target);
> 
> You need not to call open_debuginfo() when it is a uprobe.
> 

Okay

> >  	int ntevs, ret = 0;
> >  
> > +	if (pev->uprobes) {
> > +		if (need_dwarf) {
> > +			pr_warning("Debuginfo-analysis is not yet supported"
> > +					" with -x/--exec option.\n");
> > +			return -ENOSYS;
> > +		}
> > +		return convert_name_to_addr(pev, target);
> > +	}
> > +
> >  	if (!dinfo) {
> >  		if (need_dwarf) {
> >  			pr_warning("Failed to open debuginfo file.\n");
> [...]
> > @@ -887,6 +921,11 @@ static int parse_perf_probe_point(char *arg, struct perf_probe_event *pev)
> >  		return -EINVAL;
> >  	}
> >  
> > +	if (pev->uprobes && !pp->function) {
> > +		semantic_error("No function specified for uprobes");
> > +		return -EINVAL;
> > +	}
> 
> I think this check would better be done when converting
> function to address.

This can also be done.

> 
> >  	if ((pp->offset || pp->line || pp->lazy_line) && pp->retprobe) {
> >  		semantic_error("Offset/Line/Lazy pattern can't be used with "
> >  			       "return probe.\n");
> > @@ -896,6 +935,11 @@ static int parse_perf_probe_point(char *arg, struct perf_probe_event *pev)
> >  	pr_debug("symbol:%s file:%s line:%d offset:%lu return:%d lazy:%s\n",
> >  		 pp->function, pp->file, pp->line, pp->offset, pp->retprobe,
> >  		 pp->lazy_line);
> > +
> > +	if (pev->uprobes && perf_probe_event_need_dwarf(pev)) {
> > +		semantic_error("no dwarf based probes for uprobes.");
> > +		return -EINVAL;
> > +	}
> 
> Hmm, this also would be done in converting phase.

Okay, will do.

> 
> >  	return 0;
> >  }
> >  
> > @@ -1047,7 +1091,8 @@ bool perf_probe_event_need_dwarf(struct perf_probe_event *pev)
> >  {
> >  	int i;
> >  
> > -	if (pev->point.file || pev->point.line || pev->point.lazy_line)
> > +	if ((pev->point.file && !pev->uprobes) || pev->point.line ||
> > +					pev->point.lazy_line)
> 
> point.file will point a source file, not executable file.
> 
> >  		return true;
> >  
> >  	for (i = 0; i < pev->nargs; i++)
> > @@ -1344,11 +1389,17 @@ char *synthesize_probe_trace_command(struct probe_trace_event *tev)
> >  	if (buf == NULL)
> >  		return NULL;
> >  
> > -	len = e_snprintf(buf, MAX_CMDLEN, "%c:%s/%s %s%s%s+%lu",
> > -			 tp->retprobe ? 'r' : 'p',
> > -			 tev->group, tev->event,
> > -			 tp->module ?: "", tp->module ? ":" : "",
> > -			 tp->symbol, tp->offset);
> > +	if (tev->uprobes)
> > +		len = e_snprintf(buf, MAX_CMDLEN, "%c:%s/%s %s",
> > +				 tp->retprobe ? 'r' : 'p',
> > +				 tev->group, tev->event, tp->symbol);
> > +	else
> > +		len = e_snprintf(buf, MAX_CMDLEN, "%c:%s/%s %s%s%s+%lu",
> > +				 tp->retprobe ? 'r' : 'p',
> > +				 tev->group, tev->event,
> > +				 tp->module ?: "", tp->module ? ":" : "",
> > +				 tp->symbol, tp->offset);
> 
> I think tp->module should be the executable file even when
> tp is a user space probe, because when parsing the uprobes list
> in tracing/trace_uprobes, exec file will be stored in tp->module.

can be done. What I used to do is overload the tp->symbol with the
real-name as well as the offset.  Now I will just keep the offset in the
symbol and use the target that the user has requested.

> 
> > +
> >  	if (len <= 0)
> >  		goto error;
> >  
> [...]
> >  
> > -/* Get raw string list of current kprobe_events */
> > +static int open_kprobe_events(bool readwrite)
> > +{
> > +	return open_probe_events(readwrite, 1);
> > +}
> > +
> > +static int open_uprobe_events(bool readwrite)
> > +{
> > +	return open_probe_events(readwrite, 0);
> > +}
> 
> Hmm, I'd rather like to have
>  open_probe_events(const char *fname, bool rw)
> and print errors in each open_u/kprobe_events().
> 

Okay, I wanted to keep using the errno just after open but I am fine to
split this.

> 
> > +
> > +/* Get raw string list of current kprobe_events  or uprobe_events */
> >  static struct strlist *get_probe_trace_command_rawlist(int fd)
> >  {
> >  	int ret, idx;
> [...]
> > @@ -2065,30 +2180,150 @@ static int filter_available_functions(struct map *map __unused,
> >  	return 1;
> >  }
> >  
> > -int show_available_funcs(const char *target, struct strfilter *_filter)
> > +static int __show_available_funcs(struct map *map)
> > +{
> > +	if (map__load(map, filter_available_functions)) {
> > +		pr_err("Failed to load map.\n");
> > +		return -EINVAL;
> > +	}
> > +	if (!dso__sorted_by_name(map->dso, map->type))
> > +		dso__sort_by_name(map->dso, map->type);
> > +
> > +	dso__fprintf_symbols_by_name(map->dso, map->type, stdout);
> > +	return 0;
> > +}
> > +
> > +static int available_kernel_funcs(const char *module)
> >  {
> >  	struct map *map;
> >  	int ret;
> >  
> > -	setup_pager();
> > -
> >  	ret = init_vmlinux();
> >  	if (ret < 0)
> >  		return ret;
> >  
> > -	map = kernel_get_module_map(target);
> > +	map = kernel_get_module_map(module);
> >  	if (!map) {
> > -		pr_err("Failed to find %s map.\n", (target) ? : "kernel");
> > +		pr_err("Failed to find %s map.\n", (module) ? : "kernel");
> >  		return -EINVAL;
> >  	}
> > +	return __show_available_funcs(map);
> > +}
> 
> I think we'd better introduce available_user_funcs() here too.

Okay done.

> 
> > +
> > +int show_available_funcs(const char *target, struct strfilter *_filter,
> > +					bool user)
> > +{
> > +	struct map *map;
> > +	int ret;
> > +
> > +	setup_pager();
> >  	available_func_filter = _filter;
> > +
> > +	if (!user)
> > +		return available_kernel_funcs(target);
> > +
> > +	symbol_conf.try_vmlinux_path = false;
> > +	symbol_conf.sort_by_name = true;
> > +	ret = symbol__init();
> > +	if (ret < 0) {
> > +		pr_err("Failed to init symbol map.\n");
> > +		return ret;
> > +	}
> > +	map = dso__new_map(target);
> > +	ret = __show_available_funcs(map);
> > +	dso__delete(map->dso);
> > +	map__delete(map);
> > +	return ret;
> > +}
> > +
> > +#define DEFAULT_FUNC_FILTER "!_*"
> 
> This is a hidden rule for users ... please remove it.
> (or, is there any reason why we need to have it?)
> 

This is to be in sync with your commit 
3c42258c9a4db70133fa6946a275b62a16792bb5


> > +
> > +/*
> > + * uprobe_events only accepts address:
> > + * Convert function and any offset to address
> > + */
> > +static int convert_name_to_addr(struct perf_probe_event *pev, const char *exec)
> > +{
> 
> I'm not sure why wouldn't you convert function to "vaddr",
> instead of "exec:vaddr"?
> 

If the user provides a symbolic link, convert_name_to_addr would get the
target executable for the given executable. This would handy if we were
to compare existing probes registered on the same application using a
different name (symbolic links). Since you seem to like that we register
with the name the user has provided, I will just feed address here.

--
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
