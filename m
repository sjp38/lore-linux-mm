Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 018036B0073
	for <linux-mm@kvack.org>; Thu,  1 Dec 2011 08:26:17 -0500 (EST)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Thu, 1 Dec 2011 08:26:16 -0500
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pB1DQBVJ236204
	for <linux-mm@kvack.org>; Thu, 1 Dec 2011 08:26:12 -0500
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pB1DQ9T2030070
	for <linux-mm@kvack.org>; Thu, 1 Dec 2011 06:26:11 -0700
Date: Thu, 1 Dec 2011 18:54:06 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v7 3.2-rc2 4/30] uprobes: Define hooks for mmap/munmap.
Message-ID: <20111201132406.GI18380@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20111118110723.10512.66282.sendpatchset@srdronam.in.ibm.com>
 <1322071812.14799.87.camel@twins>
 <20111124134742.GH28065@linux.vnet.ibm.com>
 <1322492384.2921.143.camel@twins>
 <20111129083322.GD13445@linux.vnet.ibm.com>
 <1322567326.2921.226.camel@twins>
 <20111129162237.GA18380@linux.vnet.ibm.com>
 <1322655933.2921.271.camel@twins>
 <20111201054018.GC18380@linux.vnet.ibm.com>
 <1322739387.4699.10.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1322739387.4699.10.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>, tulasidhard@gmail.com

> > I was following the general convention being used within the kernel to not
> > bother about the area that we are going to unmap. For example: If a ptraced
> > area were to be unmapped or remapped, I dont see the breakpoint being
> > removed and added back. Also if a ptrace process is exitting, we dont go
> > about removing the installed breakpoints.
> > 
> > Also we would still need the check for EEXIST and read_opcode for handling
> > the fork() case. So even if we add extra line to remove the actual
> > breakpoint in munmap, It doesnt make the code any more simpler.
> 
> Not adding the counter now does though. The whole mm->mm_uprobes_count
> thing itself is basically an optimization.
> 
> Without it we'll get to uprobe_notify_resume() too often, but who cares.
> And not having to worry about it removes a lot of this complexity.
> 
> Then in the patch where you introduce this optimization you can list all
> the nitty gritty details of mremap/fork and counter balancing.
> 

Okay, I will move the optimization parts into a separate patch and keep
it at the end of the patchset.

> Another point, maybe add some comments on how the generic bits of
> uprobe_notify_resume()/uprobe_bkpt_notifier()/uprobe_post_notifier() etc
> hang together and what the arch stuff should do. 
> 
> Currently I have to flip back and forth between those to figure out what
> happens.
> 
> Having that information also helps validate that x86 does indeed do what
> is expected and helps other arch maintainers write their code without
> having to grok wtf x86 does.
> 

Okay, will work towards this.

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
