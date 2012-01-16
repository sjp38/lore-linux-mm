Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id E27B76B0089
	for <linux-mm@kvack.org>; Mon, 16 Jan 2012 08:12:25 -0500 (EST)
Date: Mon, 16 Jan 2012 14:11:37 +0100
From: Jiri Olsa <jolsa@redhat.com>
Subject: Re: [PATCH v9 3.2 7/9] tracing: uprobes trace_event interface
Message-ID: <20120116131137.GB5265@m.brq.redhat.com>
References: <20120110114821.17610.9188.sendpatchset@srdronam.in.ibm.com>
 <20120110114943.17610.28293.sendpatchset@srdronam.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120110114943.17610.28293.sendpatchset@srdronam.in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Rothwell <sfr@canb.auug.org.au>

On Tue, Jan 10, 2012 at 05:19:43PM +0530, Srikar Dronamraju wrote:
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
> TODO: Connect a filter to a consumer.

hi,

It looks to me the perf/trace filtering is already working
with the small fix attached.

In another email discussion I think you suggested to use
the 'filter property of uprobe consumer' for the perf/trace
filtering.  The current code does the filtering in the handler
itself, and it's same for other perf/trace based events.

I discussed the 'filter property of uprobe consumer' with Oleg,
and he is not sure why it was added.. was it only for the perf/trace
filtering?

I've tested following event:
        echo "p:probe_libc/free /lib64/libc-2.13.so:0x7a4f0 %ax" > ./uprobe_events

and commands like:
        perf record -a -e probe_libc:free  --filter "common_pid == 1127"
        perf record -e probe_libc:free --filter "arg1 == 0xa" ls

got me proper results.

thanks,
jirka

---
The preemption needs to be disabled when submitting data into perf.

---
 kernel/trace/trace_uprobe.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/kernel/trace/trace_uprobe.c b/kernel/trace/trace_uprobe.c
index af29368..4d3857c 100644
--- a/kernel/trace/trace_uprobe.c
+++ b/kernel/trace/trace_uprobe.c
@@ -653,9 +653,11 @@ static void uprobe_perf_func(struct trace_uprobe *tp, struct pt_regs *regs)
 		     "profile buffer not large enough"))
 		return;
 
+	preempt_disable();
+
 	entry = perf_trace_buf_prepare(size, call->event.type, regs, &rctx);
 	if (!entry)
-		return;
+		goto out;
 
 	entry->ip = get_uprobe_bkpt_addr(task_pt_regs(current));
 	data = (u8 *)&entry[1];
@@ -665,6 +667,8 @@ static void uprobe_perf_func(struct trace_uprobe *tp, struct pt_regs *regs)
 
 	head = this_cpu_ptr(call->perf_events);
 	perf_trace_buf_submit(entry, size, rctx, entry->ip, 1, regs, head);
+ out:
+	preempt_enable();
 }
 #endif	/* CONFIG_PERF_EVENTS */
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
