Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id E8B406B00A9
	for <linux-mm@kvack.org>; Mon, 16 Jan 2012 13:22:24 -0500 (EST)
Received: from /spool/local
	by e5.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Mon, 16 Jan 2012 13:22:23 -0500
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 40ACA6EB836
	for <linux-mm@kvack.org>; Mon, 16 Jan 2012 11:50:38 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q0GGobgG274774
	for <linux-mm@kvack.org>; Mon, 16 Jan 2012 11:50:37 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q0GGoRa2009855
	for <linux-mm@kvack.org>; Mon, 16 Jan 2012 14:50:37 -0200
Date: Mon, 16 Jan 2012 22:11:46 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v9 3.2 7/9] tracing: uprobes trace_event interface
Message-ID: <20120116164146.GI10189@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20120110114821.17610.9188.sendpatchset@srdronam.in.ibm.com>
 <20120110114943.17610.28293.sendpatchset@srdronam.in.ibm.com>
 <20120116131137.GB5265@m.brq.redhat.com>
 <20120116144538.GG10189@linux.vnet.ibm.com>
 <20120116153327.GE5265@m.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20120116153327.GE5265@m.brq.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Olsa <jolsa@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Rothwell <sfr@canb.auug.org.au>

* Jiri Olsa <jolsa@redhat.com> [2012-01-16 16:33:27]:

> On Mon, Jan 16, 2012 at 08:15:38PM +0530, Srikar Dronamraju wrote:
> > > 
> > > I've tested following event:
> > >         echo "p:probe_libc/free /lib64/libc-2.13.so:0x7a4f0 %ax" > ./uprobe_events
> > > 
> > > and commands like:
> > >         perf record -a -e probe_libc:free  --filter "common_pid == 1127"
> > >         perf record -e probe_libc:free --filter "arg1 == 0xa" ls
> > > 
> > > got me proper results.
> > > 
> > 
> > Okay thanks for the inputs.
> > 
> > > thanks,
> > > jirka
> > > 
> > > ---
> > > The preemption needs to be disabled when submitting data into perf.
> > 
> > I actually looked at other places where perf_trace_buf_prepare and
> > perf_trace_buf_submit are being called. for example perf_syscall_enter
> > and perf_syscall_exit both call the above routines and they didnt seem
> > to be called with premption disabled. Is that the way perf probe is
> > called in our case that needs us to call pre-emption here? Did you see a
> > case where calling these without preemption disabled caused a problem?
> 
> the perf_trace_buf_prepare touches per cpu variables,
> hence the preemption disabling
> 
> the perf_trace_buf_prepare code is used by syscalls,
> kprobes, and trace events
> 
> - both syscalls and trace events are implemented by
>   tracepoints which disable preemption before calling the probe
>   (see __DO_TRACE macro in include/linux/tracepoint.h)
> 
> - kprobes disable preemption as well
>   (kprobe_handler in arch/x86/kernel/kprobes.c)
>   haven't checked the optimalized kprobes,
>   but should be the same case
> 
> jirka
> 

Okay, thanks for the clarification, I will pick the fix.

--
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
