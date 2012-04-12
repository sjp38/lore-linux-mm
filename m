Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id CD4716B007E
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 09:02:34 -0400 (EDT)
Message-ID: <4F86D264.9020004@hitachi.com>
Date: Thu, 12 Apr 2012 22:02:28 +0900
From: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
MIME-Version: 1.0
Subject: Re: [PATCH UPDATED 3/3] tracing: Provide trace events interface
 for uprobes
References: <20120409091133.8343.65289.sendpatchset@srdronam.in.ibm.com> <20120409091154.8343.50489.sendpatchset@srdronam.in.ibm.com> <20120411103043.GB29437@linux.vnet.ibm.com>
In-Reply-To: <20120411103043.GB29437@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Anton Arapov <anton@redhat.com>

(2012/04/11 19:30), Srikar Dronamraju wrote:
> From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
> 
> Implements trace_event support for uprobes. In its current form it can
> be used to put probes at a specified offset in a file and dump the
> required registers when the code flow reaches the probed address.
> 
> The following example shows how to dump the instruction pointer and %ax
> a register at the probed text address.  Here we are trying to probe
> zfree in /bin/zsh
> 
> # cd /sys/kernel/debug/tracing/
> # cat /proc/`pgrep  zsh`/maps | grep /bin/zsh | grep r-xp
> 00400000-0048a000 r-xp 00000000 08:03 130904 /bin/zsh
> # objdump -T /bin/zsh | grep -w zfree
> 0000000000446420 g    DF .text  0000000000000012  Base        zfree
> # echo 'p /bin/zsh:0x46420 %ip %ax' > uprobe_events
> # cat uprobe_events
> p:uprobes/p_zsh_0x46420 /bin/zsh:0x0000000000046420
> # echo 1 > events/uprobes/enable
> # sleep 20
> # echo 0 > events/uprobes/enable
> # cat trace
> # tracer: nop
> #
> #           TASK-PID    CPU#    TIMESTAMP  FUNCTION
> #              | |       |          |         |
>              zsh-24842 [006] 258544.995456: p_zsh_0x46420: (0x446420) arg1=446421 arg2=79
>              zsh-24842 [007] 258545.000270: p_zsh_0x46420: (0x446420) arg1=446421 arg2=79
>              zsh-24842 [002] 258545.043929: p_zsh_0x46420: (0x446420) arg1=446421 arg2=79
>              zsh-24842 [004] 258547.046129: p_zsh_0x46420: (0x446420) arg1=446421 arg2=79
> 
> Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
> ---
> 
> Changelog (since v9)
> - Handle comments from Steven Rostedt about uprobe tracer documentation.
> - Disable preemption while in perf handler as suggested by Jiri Olsa.
> 
> Changelog (since v5)
> - Added uprobe tracer documentation to this patch.
> 
>  Documentation/trace/uprobetracer.txt |   95 ++++
>  arch/Kconfig                         |    2 
>  kernel/trace/Kconfig                 |   16 +
>  kernel/trace/Makefile                |    1 
>  kernel/trace/trace.h                 |    5 
>  kernel/trace/trace_kprobe.c          |    2 
>  kernel/trace/trace_probe.c           |   14 -
>  kernel/trace/trace_probe.h           |    3 
>  kernel/trace/trace_uprobe.c          |  788 ++++++++++++++++++++++++++++++++++
>  9 files changed, 919 insertions(+), 7 deletions(-)
>  create mode 100644 Documentation/trace/uprobetracer.txt
>  create mode 100644 kernel/trace/trace_uprobe.c
> 
> diff --git a/Documentation/trace/uprobetracer.txt b/Documentation/trace/uprobetracer.txt
> new file mode 100644
> index 0000000..eae40a0
> --- /dev/null
> +++ b/Documentation/trace/uprobetracer.txt
> @@ -0,0 +1,95 @@
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
> +However unlike kprobe-event tracer, the uprobe event interface expects the
> +user to calculate the offset of the probepoint in the object
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
> +
> +Please note: User has to explicitly calculate the offset of the probepoint
> +in the object. We can see the events that are registered by looking at the
> +uprobe_events file.
> +
> +    # cat uprobe_events
> +    p:uprobes/p_zsh_0x46420 /bin/zsh:0x0000000000046420

Doesn't uprobe_events show the arguments of existing events?
And also, could you add an event format of above event here?

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
