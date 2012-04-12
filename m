Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 1348E6B007E
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 09:14:19 -0400 (EDT)
Message-ID: <1334236456.23924.333.camel@gandalf.stny.rr.com>
Subject: Re: [PATCH UPDATED 3/3] tracing: Provide trace events interface for
 uprobes
From: Steven Rostedt <rostedt@goodmis.org>
Date: Thu, 12 Apr 2012 09:14:16 -0400
In-Reply-To: <20120411103043.GB29437@linux.vnet.ibm.com>
References: <20120409091133.8343.65289.sendpatchset@srdronam.in.ibm.com>
	 <20120409091154.8343.50489.sendpatchset@srdronam.in.ibm.com>
	 <20120411103043.GB29437@linux.vnet.ibm.com>
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Anton Arapov <anton@redhat.com>

On Wed, 2012-04-11 at 16:00 +0530, Srikar Dronamraju wrote:
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

I'm fine with what I see here (still need to fix what Masami suggested).

Acked-by: Steven Rostedt <rostedt@goodmis.org>

-- Steve




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
