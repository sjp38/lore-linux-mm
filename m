Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 90FA56B00EB
	for <linux-mm@kvack.org>; Thu,  5 Apr 2012 20:12:55 -0400 (EDT)
Subject: Re: [PATCH 3/3] tracing: Provide traceevents interface for uprobes
From: Steven Rostedt <rostedt@goodmis.org>
In-Reply-To: <20120403010502.17852.58528.sendpatchset@srdronam.in.ibm.com>
References: <20120403010442.17852.9888.sendpatchset@srdronam.in.ibm.com>
	 <20120403010502.17852.58528.sendpatchset@srdronam.in.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 05 Apr 2012 20:12:44 -0400
Message-ID: <1333671164.3764.71.camel@pippen.local.home>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Anton Arapov <anton@redhat.com>

On Tue, 2012-04-03 at 06:35 +0530, Srikar Dronamraju wrote:
> From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
> --- /dev/null
> +++ b/Documentation/trace/uprobetracer.txt
> @@ -0,0 +1,93 @@
> +		Uprobe-tracer: Uprobe-based Event Tracing
> +		=========================================
> +                 Documentation written by Srikar Dronamraju
> +
> +Overview
> +--------
> +Uprobe based trace events are similar to kprobe based trace events.
> +To enable this feature, build your kernel with CONFIG_UPROBE_EVENTS=y.
> +
> +Similar to the kprobe-event tracer, this doesn't need to be activated via
> +current_tracer. Instead of that, add probe points via
> +/sys/kernel/debug/tracing/uprobe_events, and enable it via
> +/sys/kernel/debug/tracing/events/uprobes/<EVENT>/enabled.
> +
> +
> +Synopsis of uprobe_tracer
> +-------------------------
> +  p[:[GRP/]EVENT] PATH:SYMBOL[+offs] [FETCHARGS]	: Set a probe
> +
> + GRP		: Group name. If omitted, use "uprobes" for it.
> + EVENT		: Event name. If omitted, the event name is generated
> +		  based on SYMBOL+offs.
> + PATH		: path to an executable or a library.
> + SYMBOL[+offs]	: Symbol+offset where the probe is inserted.
> +
> + FETCHARGS	: Arguments. Each probe can have up to 128 args.
> +  %REG		: Fetch register REG
> +
> +Event Profiling
> +---------------
> + You can check the total number of probe hits and probe miss-hits via
> +/sys/kernel/debug/tracing/uprobe_profile.
> + The first column is event name, the second is the number of probe hits,
> +the third is the number of probe miss-hits.
> +
> +Usage examples
> +--------------
> +To add a probe as a new event, write a new definition to uprobe_events
> +as below.
> +
> +  echo 'p: /bin/bash:0x4245c0' > /sys/kernel/debug/tracing/uprobe_events
> +
> + This sets a uprobe at an offset of 0x4245c0 in the executable /bin/bash
> +
> +
> +  echo > /sys/kernel/debug/tracing/uprobe_events
> +
> + This clears all probe points.
> +
> +The following example shows how to dump the instruction pointer and %ax
> +a register at the probed text address.  Here we are trying to probe
> +function zfree in /bin/zsh
> +
> +    # cd /sys/kernel/debug/tracing/
> +    # cat /proc/`pgrep  zsh`/maps | grep /bin/zsh | grep r-xp
> +    00400000-0048a000 r-xp 00000000 08:03 130904 /bin/zsh
> +    # objdump -T /bin/zsh | grep -w zfree
> +    0000000000446420 g    DF .text  0000000000000012  Base        zfree
> +
> +0x46420 is the offset of zfree in object /bin/zsh that is loaded at
> +0x00400000. Hence the command to probe would be :
> +
> +    # echo 'p /bin/zsh:0x46420 %ip %ax' > uprobe_events

Nice example, but I would explicitly state that the uprobe event
interface expects the offset in the object, which needs to be
calculated. This may be a nit, but as I'm a bit tired (been out late
last night here at the current conference I'm in ;-), I had to read it
three times before I figured it out.

> +
> +We can see the events that are registered by looking at the uprobe_events
> +file.
> +
> +    # cat uprobe_events
> +    p:uprobes/p_zsh_0x46420 /bin/zsh:0x0000000000046420
> +
> +Right after definition, each event is disabled by default. For tracing these
> +events, you need to enable it by:
> +
> +    # echo 1 > events/uprobes/enable
> +
> +Lets disable the event after sleeping for some time.
> +    # sleep 20
> +    # echo 0 > events/uprobes/enable
> +
> +And you can see the traced information via /sys/kernel/debug/tracing/trace.
> +
> +    # cat trace
> +    # tracer: nop
> +    #
> +    #           TASK-PID    CPU#    TIMESTAMP  FUNCTION
> +    #              | |       |          |         |
> +                 zsh-24842 [006] 258544.995456: p_zsh_0x46420: (0x446420) arg1=446421 arg2=79
> +                 zsh-24842 [007] 258545.000270: p_zsh_0x46420: (0x446420) arg1=446421 arg2=79
> +                 zsh-24842 [002] 258545.043929: p_zsh_0x46420: (0x446420) arg1=446421 arg2=79
> +                 zsh-24842 [004] 258547.046129: p_zsh_0x46420: (0x446420) arg1=446421 arg2=79
> +
> +Each line shows us probes were triggered for a pid 24842 with ip being
> +0x446421 and contents of ax register being 79.
> diff --git a/kernel/trace/Kconfig b/kernel/trace/Kconfig
> index ce5a5c5..18f03a6 100644
> --- a/kernel/trace/Kconfig
> +++ b/kernel/trace/Kconfig
> @@ -386,6 +386,22 @@ config KPROBE_EVENT
>  	  This option is also required by perf-probe subcommand of perf tools.
>  	  If you want to use perf tools, this option is strongly recommended.
>  
> +config UPROBE_EVENT
> +	bool "Enable uprobes-based dynamic events"
> +	depends on ARCH_SUPPORTS_UPROBES
> +	depends on MMU
> +	select UPROBES
> +	select PROBE_EVENTS
> +	select TRACING
> +	default n
> +	help
> +	  This allows the user to add tracing events on top of userspace dynamic
> +	  events (similar to tracepoints) on the fly via the traceevents interface.

s/traceevents/trace events/

> +	  Those events can be inserted wherever uprobes can probe, and record
> +	  various registers.
> +	  This option is required if you plan to use perf-probe subcommand of perf
> +	  tools on user space applications.
> +
>  config PROBE_EVENTS
>  	def_bool n
>  
> diff --git a/kernel/trace/Makefile b/kernel/trace/Makefile
> index fa10d5c..1734c03 100644
> --- a/kernel/trace/Makefile
> +++ b/kernel/trace/Makefile
> @@ -62,5 +62,6 @@ ifeq ($(CONFIG_TRACING),y)
>  obj-$(CONFIG_KGDB_KDB) += trace_kdb.o
>  endif
>  obj-$(CONFIG_PROBE_EVENTS) += trace_probe.o
> +obj-$(CONFIG_UPROBE_EVENT) += trace_uprobe.o
>  
>  libftrace-y := ftrace.o
> diff --git a/kernel/trace/trace.h b/kernel/trace/trace.h
> index 95059f0..1bcdbec 100644
> --- a/kernel/trace/trace.h
> +++ b/kernel/trace/trace.h
> @@ -103,6 +103,11 @@ struct kretprobe_trace_entry_head {
>  	unsigned long		ret_ip;
>  };
>  
> +struct uprobe_trace_entry_head {
> +	struct trace_entry	ent;
> +	unsigned long		ip;
> +};
> +
>  /*
>   * trace_flag_type is an enumeration that holds different
>   * states when a trace occurs. These are:
> diff --git a/kernel/trace/trace_kprobe.c b/kernel/trace/trace_kprobe.c
> index f8b7773..eb52983 100644
> --- a/kernel/trace/trace_kprobe.c
> +++ b/kernel/trace/trace_kprobe.c
> @@ -524,8 +524,8 @@ static int create_trace_probe(int argc, char **argv)
>  		}
>  
>  		/* Parse fetch argument */
> -		ret = traceprobe_parse_probe_arg(arg, &tp->size, &tp->args[i],
> -								is_return);
> +		ret = traceprobe_parse_probe_arg(arg, &tp->size,
> +					&tp->args[i], is_return, true);
>  		if (ret) {
>  			pr_info("Parse error at argument[%d]. (%d)\n", i, ret);
>  			goto error;
> diff --git a/kernel/trace/trace_probe.c b/kernel/trace/trace_probe.c
> index deb375a..56d0705 100644
> --- a/kernel/trace/trace_probe.c
> +++ b/kernel/trace/trace_probe.c
> @@ -552,7 +552,7 @@ static int parse_probe_vars(char *arg, const struct fetch_type *t,
>  
>  /* Recursive argument parser */
>  static int parse_probe_arg(char *arg, const struct fetch_type *t,
> -		     struct fetch_param *f, bool is_return)
> +		     struct fetch_param *f, bool is_return, bool is_kprobe)
>  {
>  	unsigned long param;
>  	long offset;
> @@ -560,6 +560,10 @@ static int parse_probe_arg(char *arg, const struct fetch_type *t,
>  	int ret;
>  
>  	ret = 0;
> +	/* Until uprobe_events supports only reg arguments */

Blank line is needed after the ret = 0;

> +	if (!is_kprobe && arg[0] != '%')
> +		return -EINVAL;
> +
>  	switch (arg[0]) {
>  	case '$':
>  		ret = parse_probe_vars(arg + 1, t, f, is_return);
> @@ -621,7 +625,8 @@ static int parse_probe_arg(char *arg, const struct fetch_type *t,
>  				return -ENOMEM;
>  
>  			dprm->offset = offset;
> -			ret = parse_probe_arg(arg, t2, &dprm->orig, is_return);
> +			ret = parse_probe_arg(arg, t2, &dprm->orig, is_return,
> +							is_kprobe);
>  			if (ret)
>  				kfree(dprm);
>  			else {
> @@ -679,7 +684,7 @@ static int __parse_bitfield_probe_arg(const char *bf,
>  
>  /* String length checking wrapper */
>  int traceprobe_parse_probe_arg(char *arg, ssize_t *size,
> -		struct probe_arg *parg, bool is_return)
> +		struct probe_arg *parg, bool is_return, bool is_kprobe)
>  {
>  	const char *t;
>  	int ret;
> @@ -705,7 +710,7 @@ int traceprobe_parse_probe_arg(char *arg, ssize_t *size,
>  	}
>  	parg->offset = *size;
>  	*size += parg->type->size;
> -	ret = parse_probe_arg(arg, parg->type, &parg->fetch, is_return);
> +	ret = parse_probe_arg(arg, parg->type, &parg->fetch, is_return, is_kprobe);
>  
>  	if (ret >= 0 && t != NULL)
>  		ret = __parse_bitfield_probe_arg(t, parg->type, &parg->fetch);
> diff --git a/kernel/trace/trace_probe.h b/kernel/trace/trace_probe.h
> index 2df9a18..9337086 100644
> --- a/kernel/trace/trace_probe.h
> +++ b/kernel/trace/trace_probe.h
> @@ -66,6 +66,7 @@
>  #define TP_FLAG_TRACE		1
>  #define TP_FLAG_PROFILE		2
>  #define TP_FLAG_REGISTERED	4
> +#define TP_FLAG_UPROBE		8
>  
> 
>  /* data_rloc: data relative location, compatible with u32 */
> @@ -143,7 +144,7 @@ static inline int is_good_name(const char *name)
>  }
>  
>  extern int traceprobe_parse_probe_arg(char *arg, ssize_t *size,
> -		   struct probe_arg *parg, bool is_return);
> +		   struct probe_arg *parg, bool is_return, bool is_kprobe);
>  
>  extern int traceprobe_conflict_field_name(const char *name,
>  			       struct probe_arg *args, int narg);
> diff --git a/kernel/trace/trace_uprobe.c b/kernel/trace/trace_uprobe.c
> new file mode 100644
> index 0000000..d8b11cf
> --- /dev/null
> +++ b/kernel/trace/trace_uprobe.c
> @@ -0,0 +1,787 @@
> +/*
> + * uprobes-based tracing events
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2 as
> + * published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program; if not, write to the Free Software
> + * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
> + *
> + * Copyright (C) IBM Corporation, 2010-2012
> + * Author:	Srikar Dronamraju <srikar@linux.vnet.ibm.com>
> + */
> +
> +#include <linux/module.h>
> +#include <linux/uaccess.h>
> +#include <linux/uprobes.h>
> +#include <linux/namei.h>
> +
> +#include "trace_probe.h"
> +
> +#define UPROBE_EVENT_SYSTEM	"uprobes"
> +
> +/**
> + * uprobe event core functions
> + */
> +struct trace_uprobe;
> +struct uprobe_trace_consumer {
> +	struct uprobe_consumer		cons;
> +	struct trace_uprobe		*tp;
> +};
> +
> +struct trace_uprobe {
> +	struct list_head		list;
> +	struct ftrace_event_class	class;
> +	struct ftrace_event_call	call;
> +	struct uprobe_trace_consumer	*consumer;
> +	struct inode			*inode;
> +	char				*filename;
> +	unsigned long			offset;
> +	unsigned long			nhit;
> +	unsigned int			flags;	/* For TP_FLAG_* */
> +	ssize_t				size;	/* trace entry size */
> +	unsigned int			nr_args;
> +	struct probe_arg		args[];
> +};
> +
> +#define SIZEOF_TRACE_UPROBE(n)			\
> +	(offsetof(struct trace_uprobe, args) +	\
> +	(sizeof(struct probe_arg) * (n)))
> +
> +static int register_uprobe_event(struct trace_uprobe *tp);
> +static void unregister_uprobe_event(struct trace_uprobe *tp);
> +
> +static DEFINE_MUTEX(uprobe_lock);
> +static LIST_HEAD(uprobe_list);
> +
> +static int uprobe_dispatcher(struct uprobe_consumer *con, struct pt_regs *regs);
> +
> +/*
> + * Allocate new trace_uprobe and initialize it (including uprobes).
> + */
> +static struct trace_uprobe *
> +alloc_trace_uprobe(const char *group, const char *event, int nargs)
> +{
> +	struct trace_uprobe *tp;
> +
> +	if (!event || !is_good_name(event))
> +		return ERR_PTR(-EINVAL);
> +
> +	if (!group || !is_good_name(group))
> +		return ERR_PTR(-EINVAL);
> +
> +	tp = kzalloc(SIZEOF_TRACE_UPROBE(nargs), GFP_KERNEL);
> +	if (!tp)
> +		return ERR_PTR(-ENOMEM);
> +
> +	tp->call.class = &tp->class;
> +	tp->call.name = kstrdup(event, GFP_KERNEL);
> +	if (!tp->call.name)
> +		goto error;
> +
> +	tp->class.system = kstrdup(group, GFP_KERNEL);
> +	if (!tp->class.system)
> +		goto error;
> +
> +	INIT_LIST_HEAD(&tp->list);
> +	return tp;
> +
> +error:
> +	kfree(tp->call.name);
> +	kfree(tp);
> +
> +	return ERR_PTR(-ENOMEM);
> +}
> +
> +static void free_trace_uprobe(struct trace_uprobe *tp)
> +{
> +	int i;
> +
> +	for (i = 0; i < tp->nr_args; i++)
> +		traceprobe_free_probe_arg(&tp->args[i]);
> +
> +	iput(tp->inode);
> +	kfree(tp->call.class->system);
> +	kfree(tp->call.name);
> +	kfree(tp->filename);
> +	kfree(tp);
> +}
> +
> +static struct trace_uprobe *find_probe_event(const char *event, const char *group)
> +{
> +	struct trace_uprobe *tp;
> +
> +	list_for_each_entry(tp, &uprobe_list, list)
> +		if (strcmp(tp->call.name, event) == 0 &&
> +		    strcmp(tp->call.class->system, group) == 0)
> +			return tp;
> +
> +	return NULL;
> +}
> +
> +/* Unregister a trace_uprobe and probe_event: call with locking uprobe_lock */
> +static void unregister_trace_uprobe(struct trace_uprobe *tp)
> +{
> +	list_del(&tp->list);
> +	unregister_uprobe_event(tp);
> +	free_trace_uprobe(tp);
> +}
> +
> +/* Register a trace_uprobe and probe_event */
> +static int register_trace_uprobe(struct trace_uprobe *tp)
> +{
> +	struct trace_uprobe *old_tp;
> +	int ret;
> +
> +	mutex_lock(&uprobe_lock);
> +
> +	/* register as an event */
> +	old_tp = find_probe_event(tp->call.name, tp->call.class->system);
> +	if (old_tp)
> +		/* delete old event */
> +		unregister_trace_uprobe(old_tp);
> +
> +	ret = register_uprobe_event(tp);
> +	if (ret) {
> +		pr_warning("Failed to register probe event(%d)\n", ret);
> +		goto end;
> +	}
> +
> +	list_add_tail(&tp->list, &uprobe_list);
> +
> +end:
> +	mutex_unlock(&uprobe_lock);
> +
> +	return ret;
> +}
> +
> +/*
> + * Argument syntax:
> + *  - Add uprobe: p[:[GRP/]EVENT] PATH:SYMBOL[+offs] [FETCHARGS]
> + *
> + *  - Remove uprobe: -:[GRP/]EVENT
> + */
> +static int create_trace_uprobe(int argc, char **argv)
> +{
> +	struct trace_uprobe *tp;
> +	struct inode *inode;
> +	char *arg, *event, *group, *filename;
> +	char buf[MAX_EVENT_NAME_LEN];
> +	struct path path;
> +	unsigned long offset;
> +	bool is_delete;
> +	int i, ret;
> +
> +	inode = NULL;
> +	ret = 0;
> +	is_delete = false;
> +	arg = NULL;
> +	event = NULL;
> +	group = NULL;
> +
> +	/* argc must be >= 1 */
> +	if (argv[0][0] == '-')
> +		is_delete = true;
> +	else if (argv[0][0] != 'p') {
> +		pr_info("Probe definition must be started with 'p', 'r' or" " '-'.\n");
> +		return -EINVAL;
> +	}
> +
> +	if (argv[0][1] == ':') {
> +		event = &argv[0][2];
> +
> +		if (strchr(event, '/')) {

What about using a temp variable above so that you do not need to repeat
the search (strchr) again below?

-- Steve

> +			group = event;
> +			event = strchr(group, '/') + 1;
> +			event[-1] = '\0';
> +
> +			if (strlen(group) == 0) {
> +				pr_info("Group name is not specified\n");
> +				return -EINVAL;
> +			}
> +		}
> +		if (strlen(event) == 0) {
> +			pr_info("Event name is not specified\n");
> +			return -EINVAL;
> +		}
> +	}
> +	if (!group)
> +		group = UPROBE_EVENT_SYSTEM;
> +
> +	if (is_delete) {
> +		if (!event) {
> +			pr_info("Delete command needs an event name.\n");
> +			return -EINVAL;
> +		}
> +		mutex_lock(&uprobe_lock);
> +		tp = find_probe_event(event, group);
> +
> +		if (!tp) {
> +			mutex_unlock(&uprobe_lock);
> +			pr_info("Event %s/%s doesn't exist.\n", group, event);
> +			return -ENOENT;
> +		}
> +		/* delete an event */
> +		unregister_trace_uprobe(tp);
> +		mutex_unlock(&uprobe_lock);
> +		return 0;
> +	}
> +
> +	if (argc < 2) {
> +		pr_info("Probe point is not specified.\n");
> +		return -EINVAL;
> +	}
> +	if (isdigit(argv[1][0])) {
> +		pr_info("probe point must be have a filename.\n");
> +		return -EINVAL;
> +	}
> +	arg = strchr(argv[1], ':');
> +	if (!arg)
> +		goto fail_address_parse;
> +
> +	*arg++ = '\0';
> +	filename = argv[1];
> +	ret = kern_path(filename, LOOKUP_FOLLOW, &path);
> +	if (ret)
> +		goto fail_address_parse;
> +
> +	ret = strict_strtoul(arg, 0, &offset);
> +	if (ret)
> +		goto fail_address_parse;
> +
> +	inode = igrab(path.dentry->d_inode);
> +
> +	argc -= 2;
> +	argv += 2;
> +

> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
