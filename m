Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 50E946B004D
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 06:25:22 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Fri, 20 Apr 2012 04:25:21 -0600
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id A5324C90052
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 06:25:16 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q3KAPIuB255944
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 06:25:18 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q3KAPG3l019162
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 07:25:17 -0300
Date: Fri, 20 Apr 2012 15:46:44 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [RFC 0/6] uprobes: kill uprobes_srcu/uprobe_srcu_id
Message-ID: <20120420101644.GA17994@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20120405222024.GA19154@redhat.com>
 <1334409396.2528.100.camel@twins>
 <20120414205200.GA9083@redhat.com>
 <1334487062.2528.113.camel@twins>
 <20120415195351.GA22095@redhat.com>
 <1334526513.28150.23.camel@twins>
 <20120415234401.GA32662@redhat.com>
 <1334571419.28150.30.camel@twins>
 <20120416214707.GA27639@redhat.com>
 <1334916861.2463.50.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1334916861.2463.50.camel@laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Anton Arapov <anton@redhat.com>

* Peter Zijlstra <peterz@infradead.org> [2012-04-20 12:14:21]:

> On Mon, 2012-04-16 at 23:47 +0200, Oleg Nesterov wrote:
> > On 04/16, Peter Zijlstra wrote:
> > >
> > > On Mon, 2012-04-16 at 01:44 +0200, Oleg Nesterov wrote:
> > >
> > > > And. I have another reason for down_write() in register/unregister.
> > > > I am still not sure this is possible (I had no time to try to
> > > > implement), but it seems to me we can kill the uprobe counter in
> > > > mm_struct.
> > >
> > > You mean by making register/unregister down_write, you're exclusive with
> > > munmap()
> > 
> > .. and with register/unregister.
> > 
> > Why do we need mm->uprobes_state.count? It is writeonly, except we
> > check it in the DIE_INT3 notifier before anything else to avoid the
> > unnecessary uprobes overhead.
> 
> and uprobe_munmap().

If we can kill mm->uprobs_state.count, we can do away with
uprobe_munmap. Because uprobe_munmap is only around to manage
mm->uprobes_state.count.

> 
> > Suppose we kill it, and add the new MMF_HAS_UPROBE flag instead.
> > install_breakpoint() sets it unconditionally,
> > uprobe_pre_sstep_notifier() checks it.
> 
> Argh, why are MMF_flags part of sched.h.. one would expect those to be
> in mm.h or mm_types.h.. somewhere near struct mm.
> 
> > (And perhaps we can stop right here? I mean how often this can
> >  slow down the debugger which installs int3 in the same mm?)
> > 
> > Now we need to clear MMF_HAS_UPROBE somehowe, when the last
> > uprobe goes away. Lets ignore uprobe_map/unmap for simplicity.
> >
> > 	- We add another flag, MMF_UPROBE_RECALC, it is set by
> > 	  remove_breakpoint().
> > 
> > 	- We change handle_swbp(). Ignoring all details it does:
> > 
> > 		if (find_uprobe(vaddr))
> > 			process_uprobe();
> > 		else if (test_bit(MMF_HAS_UPROBE) && test_bit(MMF_UPROBE_RECALC))
> > 			recalc_mmf_uprobe_flag();
> > 
> > 	  where recalc_mmf_uprobe_flag() checks all vmas and either
> > 	  clears both flags or MMF_UPROBE_RECALC only.
> > 
> > 	  This is the really slow O(n) path, but it can only happen after
> > 	  unregister, and only if we hit another non-uprobe breakpoint
> > 	  in the same mm.
> > 
> > Something like this. What do you think?
> 
> I think I can live with the simple set MMF_HAS_UPROBE and leave it at
> that. The better optimization seems to be to not install breakpoints
> when ->filter() excludes the task..
> 
> It looks like we currently install the breakpoint unconditionally and
> only ->filter() once we hit the breakpoint, which is somewhat
> sub-optimal.
> 

Yes, We install breakpoints unconditionally, I think we had already
discussed this and Oleg had proposed a solution too.
http://lkml.org/lkml/2011/6/16/470 where we move the mm struct from task
struct to signal struct.

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
