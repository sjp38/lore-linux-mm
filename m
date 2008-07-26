Date: Sat, 26 Jul 2008 15:10:15 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: MMU notifiers review and some proposals
Message-ID: <20080726131015.GB21820@wotan.suse.de>
References: <20080724143949.GB12897@wotan.suse.de> <20080725214552.GB21150@duo.random> <20080726030810.GA18896@wotan.suse.de> <20080726113813.GD21150@duo.random> <20080726122826.GA17958@wotan.suse.de> <20080726130202.GA9598@duo.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080726130202.GA9598@duo.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-arch@vger.kernel.org, steiner@sgi.com, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Sat, Jul 26, 2008 at 03:02:02PM +0200, Andrea Arcangeli wrote:
> On Sat, Jul 26, 2008 at 02:28:26PM +0200, Nick Piggin wrote:
> > 3) livelock/starvation problem with TLB holdoff
> >
> > That's not shooting yourself in the foot if you are forced into the
> > design. Definitely there can be indefinite starvation because there
> > is no notion of queueing on the range_active count.
> 
> I don't see how, it's all per-mm, all other -mm can't possibly be hold
> off. What can happen is that once cpu loops because the other cpu is
> mprotecting in a flood forever. Both have to be threads belonging to
> the same -mm for this holdoff to be meaningful. It's the same app,
> with multiple threads. The rest of the system can't even notice
> whatever happens in that -mm and they all reschedule all the time, so
> it can't starve other tasks. It's not a _global_ hold off! It's a
> per-mm holdoff. The counter is in the kvm struct and the kvm struct is
> bind to a single mm. Each different kvm struct has a different
> counter. all it can happen that an app is shooting itself in the foot,
> it's actually easier to run "for (;;)" if it wants to shoot itself in
> the foot... so no big deal.
> 
> I really can't see any issue with your point 3, and infact this looks a
> nice locking design to me.

I am talking about a number of threads starving another thread of the
same process, but that isn't shooting themselves in the foot because
they might be doing simple normal operations that don't expect the
kernel to cause starvation.

 
> > I'm doing range flushing withing tlb-gathers in the patch I posted which
> > does not add a branch for every pte teardown. And I don't really
> > consider range_start/end as better, given my reasons.
> 
> As you said you missed tlb_remove_page, that is the _only_ troublesome
> one! A bit too easy to skip that one and then claim your patch as
> simpler...
> 
> Just post a patch that works for real and see if you can avoid to
> invalidate every pte, or if you've to hack inside
> asm-generic/tlb.h... I can't see how you can avoid to mangle on the
> asm-generic/tlb.h if you don't want to send IPIs at every single pte
> zapped with your patch...


What's the problem with patching asm-*/tlb.h? They're just other files,
but they all form part os the same tlb flushing design.


> > If I had seen even a single number to show the more complex scheme
> 
> Please post a patch that actually works then we'll re-evaluate what is
> the best tradeoff ;).
> 
> In the meantime please merge -mm patches into Linus's tree, this is
> taking forever and if the changes are so small to go Nick's way and
> his future "actually working" patch remains so small, it can be
> applied incrementally without any problem IMHO, infact it is presented
> as an incremental patch in the first place.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
