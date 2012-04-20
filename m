Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 0D01B6B004D
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 06:14:25 -0400 (EDT)
Received: from dhcp-089-099-019-018.chello.nl ([89.99.19.18] helo=dyad.programming.kicks-ass.net)
	by casper.infradead.org with esmtpsa (Exim 4.76 #1 (Red Hat Linux))
	id 1SLArA-0000Wi-8Q
	for linux-mm@kvack.org; Fri, 20 Apr 2012 10:14:24 +0000
Subject: Re: [RFC 0/6] uprobes: kill uprobes_srcu/uprobe_srcu_id
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20120416214707.GA27639@redhat.com>
References: <20120405222024.GA19154@redhat.com>
	 <1334409396.2528.100.camel@twins> <20120414205200.GA9083@redhat.com>
	 <1334487062.2528.113.camel@twins> <20120415195351.GA22095@redhat.com>
	 <1334526513.28150.23.camel@twins> <20120415234401.GA32662@redhat.com>
	 <1334571419.28150.30.camel@twins>  <20120416214707.GA27639@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 20 Apr 2012 12:14:21 +0200
Message-ID: <1334916861.2463.50.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Ingo Molnar <mingo@elte.hu>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Anton Arapov <anton@redhat.com>

On Mon, 2012-04-16 at 23:47 +0200, Oleg Nesterov wrote:
> On 04/16, Peter Zijlstra wrote:
> >
> > On Mon, 2012-04-16 at 01:44 +0200, Oleg Nesterov wrote:
> >
> > > And. I have another reason for down_write() in register/unregister.
> > > I am still not sure this is possible (I had no time to try to
> > > implement), but it seems to me we can kill the uprobe counter in
> > > mm_struct.
> >
> > You mean by making register/unregister down_write, you're exclusive with
> > munmap()
> 
> .. and with register/unregister.
> 
> Why do we need mm->uprobes_state.count? It is writeonly, except we
> check it in the DIE_INT3 notifier before anything else to avoid the
> unnecessary uprobes overhead.

and uprobe_munmap().

> Suppose we kill it, and add the new MMF_HAS_UPROBE flag instead.
> install_breakpoint() sets it unconditionally,
> uprobe_pre_sstep_notifier() checks it.

Argh, why are MMF_flags part of sched.h.. one would expect those to be
in mm.h or mm_types.h.. somewhere near struct mm.

> (And perhaps we can stop right here? I mean how often this can
>  slow down the debugger which installs int3 in the same mm?)
> 
> Now we need to clear MMF_HAS_UPROBE somehowe, when the last
> uprobe goes away. Lets ignore uprobe_map/unmap for simplicity.
>
> 	- We add another flag, MMF_UPROBE_RECALC, it is set by
> 	  remove_breakpoint().
> 
> 	- We change handle_swbp(). Ignoring all details it does:
> 
> 		if (find_uprobe(vaddr))
> 			process_uprobe();
> 		else if (test_bit(MMF_HAS_UPROBE) && test_bit(MMF_UPROBE_RECALC))
> 			recalc_mmf_uprobe_flag();
> 
> 	  where recalc_mmf_uprobe_flag() checks all vmas and either
> 	  clears both flags or MMF_UPROBE_RECALC only.
> 
> 	  This is the really slow O(n) path, but it can only happen after
> 	  unregister, and only if we hit another non-uprobe breakpoint
> 	  in the same mm.
> 
> Something like this. What do you think?

I think I can live with the simple set MMF_HAS_UPROBE and leave it at
that. The better optimization seems to be to not install breakpoints
when ->filter() excludes the task..

It looks like we currently install the breakpoint unconditionally and
only ->filter() once we hit the breakpoint, which is somewhat
sub-optimal.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
