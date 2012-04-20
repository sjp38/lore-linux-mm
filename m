Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id EB4C76B004D
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 14:38:19 -0400 (EDT)
Date: Fri, 20 Apr 2012 20:37:18 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [RFC 0/6] uprobes: kill uprobes_srcu/uprobe_srcu_id
Message-ID: <20120420183718.GA2236@redhat.com>
References: <20120405222024.GA19154@redhat.com> <1334409396.2528.100.camel@twins> <20120414205200.GA9083@redhat.com> <1334487062.2528.113.camel@twins> <20120415195351.GA22095@redhat.com> <1334526513.28150.23.camel@twins> <20120415234401.GA32662@redhat.com> <1334571419.28150.30.camel@twins> <20120416214707.GA27639@redhat.com> <1334916861.2463.50.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1334916861.2463.50.camel@laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@elte.hu>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Anton Arapov <anton@redhat.com>

On 04/20, Peter Zijlstra wrote:
>
> On Mon, 2012-04-16 at 23:47 +0200, Oleg Nesterov wrote:
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
> that.

Sure, I agree.

A false positive MMF_HAS_UPROBE can only slow down the non-uprobe
int3 in the same ->mm, I think we can tolerate this.

> The better optimization seems to be to not install breakpoints
> when ->filter() excludes the task..

Ah, this is another story. And I agree this is more important.

So far I do not understand what we should do. Of course, it would
be simple to add the filtering when we install the breakpoint but
I don't think it is that simple, even if we ignore the nasty
complications with multiple consumers with different filters.

Say, a user wants to probe /sbin/init only. What if init forks?
We should remove breakpoints from child->mm somehow.

And then we also need the filtering in uprobe_mmap() at least.

But yes, I agree, it would be very nice to do this.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
