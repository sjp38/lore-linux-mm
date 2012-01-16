Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id B51856B0096
	for <linux-mm@kvack.org>; Mon, 16 Jan 2012 09:55:19 -0500 (EST)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Mon, 16 Jan 2012 09:55:17 -0500
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id B18E23E4004F
	for <linux-mm@kvack.org>; Mon, 16 Jan 2012 07:54:50 -0700 (MST)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q0GEsPsi091262
	for <linux-mm@kvack.org>; Mon, 16 Jan 2012 07:54:33 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q0GEsNpr007170
	for <linux-mm@kvack.org>; Mon, 16 Jan 2012 07:54:25 -0700
Date: Mon, 16 Jan 2012 20:15:38 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v9 3.2 7/9] tracing: uprobes trace_event interface
Message-ID: <20120116144538.GG10189@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20120110114821.17610.9188.sendpatchset@srdronam.in.ibm.com>
 <20120110114943.17610.28293.sendpatchset@srdronam.in.ibm.com>
 <20120116131137.GB5265@m.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20120116131137.GB5265@m.brq.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Olsa <jolsa@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Rothwell <sfr@canb.auug.org.au>

> 
> I've tested following event:
>         echo "p:probe_libc/free /lib64/libc-2.13.so:0x7a4f0 %ax" > ./uprobe_events
> 
> and commands like:
>         perf record -a -e probe_libc:free  --filter "common_pid == 1127"
>         perf record -e probe_libc:free --filter "arg1 == 0xa" ls
> 
> got me proper results.
> 

Okay thanks for the inputs.

> thanks,
> jirka
> 
> ---
> The preemption needs to be disabled when submitting data into perf.

I actually looked at other places where perf_trace_buf_prepare and
perf_trace_buf_submit are being called. for example perf_syscall_enter
and perf_syscall_exit both call the above routines and they didnt seem
to be called with premption disabled. Is that the way perf probe is
called in our case that needs us to call pre-emption here? Did you see a
case where calling these without preemption disabled caused a problem?


> ---
>  kernel/trace/trace_uprobe.c |    6 +++++-
>  1 files changed, 5 insertions(+), 1 deletions(-)
> 
> diff --git a/kernel/trace/trace_uprobe.c b/kernel/trace/trace_uprobe.c
> index af29368..4d3857c 100644
> --- a/kernel/trace/trace_uprobe.c
> +++ b/kernel/trace/trace_uprobe.c
> @@ -653,9 +653,11 @@ static void uprobe_perf_func(struct trace_uprobe *tp, struct pt_regs *regs)
>  		     "profile buffer not large enough"))
>  		return;
> 
> +	preempt_disable();
> +
>  	entry = perf_trace_buf_prepare(size, call->event.type, regs, &rctx);
>  	if (!entry)
> -		return;
> +		goto out;
> 
>  	entry->ip = get_uprobe_bkpt_addr(task_pt_regs(current));
>  	data = (u8 *)&entry[1];
> @@ -665,6 +667,8 @@ static void uprobe_perf_func(struct trace_uprobe *tp, struct pt_regs *regs)
> 
>  	head = this_cpu_ptr(call->perf_events);
>  	perf_trace_buf_submit(entry, size, rctx, entry->ip, 1, regs, head);
> + out:
> +	preempt_enable();
>  }
>  #endif	/* CONFIG_PERF_EVENTS */
> 

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
