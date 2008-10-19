Date: Sun, 19 Oct 2008 10:45:58 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch] mm: fix anon_vma races
In-Reply-To: <20081019024115.GA16562@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0810190921170.11802@blonde.site>
References: <20081016041033.GB10371@wotan.suse.de>
 <1224285222.10548.22.camel@lappy.programming.kicks-ass.net>
 <alpine.LFD.2.00.0810171621180.3438@nehalem.linux-foundation.org>
 <alpine.LFD.2.00.0810171737350.3438@nehalem.linux-foundation.org>
 <Pine.LNX.4.64.0810190111250.25710@blonde.site> <20081019024115.GA16562@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

I'm fairly lost by now in all this, suffering from barrier sickness,
and we're not understanding each other very well.  I'll have a try.

On Sun, 19 Oct 2008, Nick Piggin wrote:
> On Sun, Oct 19, 2008 at 02:13:06AM +0100, Hugh Dickins wrote:
> > 
> > That leaves Nick's original point, of the three CPUs with the third
> > doing reclaim, with my point about needing smp_read_barrier_depends()
> > over there.  I now think those races were illusory, that we were all
> > overlooking something.  Reclaim (or page migration) doesn't arrive at
> > those pages by scanning the old mem_map[] array, it gets them off an
> > LRU list, whose spinlock is locked and unlocked to take them off; and
> > the original faulting CPU had to lock and unlock that spinlock to put
> > them on the LRU originally, at a stage after its anon_vma_prepare().
> > 
> > Surely we have enough barriers there to make sure that anon_vma->lock
> > is visibly initialized by the time page_lock_anon_vma() tries to take
> > it?
> 
> I don't think so. According to the race, the stores to anon_vma from
> the first process would not arrive at the reclaimer in time. There
> is no amount of barriers the reclaimer can perform to change this.

No amount of barriers the reclaimer can do alone, the other end needs
the complementary barriers.  I'm suggesting the lock-unlock pair when
page is put on LRU provides that (though I do recall that unlock-lock
is stronger), in association with reclaimer's lock when when it goes
to take page from LRU.

I don't grasp where I'm going wrong on that; but you're more interested
in asserting that it's irrelevant by now anyway, and I'll probably be
prepared to accept that.

> But
> anyway all that goes away if we just use locking properly as -per my
> last patch (see below).

I don't see your last patch below, so presume you're referring to the
previous you posted (and your "modulo final hunk" remark bears that
out).  I probably gave it less attention than it deserved amidst
all the other flurry of discussion.

There is no dispute between us over locking the newly allocated
anon_vma in anon_vma_prepare(): I think all three of us came to
suggest that independently, and we all agree there are separate
reasons why it's essential.  It's what Linus did in the patch
which I was commending but you're demurring from.

I think you're saying that with just that change to anon_vma_prepare(),
we've then no need for the smp_wmb() and smp_read_barrier_depends() he
retained from his first version.  I'm afraid my barrier sickness has
reached that advanced stage in which I can no long tell whether that's
obviously true or obviously false: like those perspective cube outlines
you can switch either way in your mind, I see it both ways and feel
very very stupid.  You'll have to settle that with Linus.

> > Nick, are you happy with Linus's patch below?
> > Or if not, please explain again what's missing - thanks.
> 
> No, I don't agree with the need for barriers and I think Linus had also
> not worked through the whole problem at this point because of the
> just-in-case barriers and hoping to initialise the newly allocated lock
> as locked, as an optimisation.
> 
> With my patch, the rules are simple: anybody who wants to look in the
> anon_vma or modify the anon_vma must take the anon_vma->lock. Then there
> are no problems with ordering, and no need for any explicit barriers.

But we still have the case where one caller sails through
anon_vma_prepare() seeing vma->anon_vma set, before the initialization
of that struct anon_vma (and in particular the lock) is visible to it.

I think you're saying, hell, we don't need separate steps to make a
lock visible, that would be intolerable: locking the lock makes it
visible.  So all we have to do is not skip the locking of it in the
newly allocated case.  If Linus is persuaded, then so am I.

> 
> I don't understand your point about requiring ->lock to be initialised
> coming from find_mergeable_anon_vma. Why? All the critical memory operations
> get ordered inside the lock AFAIKS (I haven't actually applied Linus'
> patch to see what the result is, but that should be the case with my
> patch).

When find_mergeable_anon_vma returns the anon_vma from an adjacent vma
which could be merged with this one, that's the one case (setting aside
extend_stack) where this faulting CPU will want to access the content
of a struct anon_vma which may have been initialized by another CPU -
to lock it and add vma to its list - rather than just use its address.

> 
> So, no. I still think my patch is the right one.
> 
> 
> This btw. is modulo the final hunk of my last patch. That was supposed to
> address the different, percieved issue I saw with getting an old anon_vma.
> I still think that's pretty ugly even if correct. It would be nice just
> to add the single branch (or better, just move one down) to avoid having
> to think about it. I will submit a separate patch for that.

Yes, I think we've now understood and agreed on that part.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
