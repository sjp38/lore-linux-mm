From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch] mm: fix anon_vma races
Date: Tue, 21 Oct 2008 14:59:54 +1100
References: <20081016041033.GB10371@wotan.suse.de> <20081019024115.GA16562@wotan.suse.de> <Pine.LNX.4.64.0810190921170.11802@blonde.site>
In-Reply-To: <Pine.LNX.4.64.0810190921170.11802@blonde.site>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200810211459.54882.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Nick Piggin <npiggin@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sunday 19 October 2008 20:45, Hugh Dickins wrote:
> I'm fairly lost by now in all this, suffering from barrier sickness,
> and we're not understanding each other very well.  I'll have a try.

Not sure if you're still worried about this I'll just try to answer
anyway. Ignore it if you like ;)


> On Sun, 19 Oct 2008, Nick Piggin wrote:
> > On Sun, Oct 19, 2008 at 02:13:06AM +0100, Hugh Dickins wrote:
> > > That leaves Nick's original point, of the three CPUs with the third
> > > doing reclaim, with my point about needing smp_read_barrier_depends()
> > > over there.  I now think those races were illusory, that we were all
> > > overlooking something.  Reclaim (or page migration) doesn't arrive at
> > > those pages by scanning the old mem_map[] array, it gets them off an
> > > LRU list, whose spinlock is locked and unlocked to take them off; and
> > > the original faulting CPU had to lock and unlock that spinlock to put
> > > them on the LRU originally, at a stage after its anon_vma_prepare().
> > >
> > > Surely we have enough barriers there to make sure that anon_vma->lock
> > > is visibly initialized by the time page_lock_anon_vma() tries to take
> > > it?
> >
> > I don't think so. According to the race, the stores to anon_vma from
> > the first process would not arrive at the reclaimer in time. There
> > is no amount of barriers the reclaimer can perform to change this.
>
> No amount of barriers the reclaimer can do alone, the other end needs
> the complementary barriers.  I'm suggesting the lock-unlock pair when
> page is put on LRU provides that (though I do recall that unlock-lock
> is stronger), in association with reclaimer's lock when when it goes
> to take page from LRU.
>
> I don't grasp where I'm going wrong on that; but you're more interested
> in asserting that it's irrelevant by now anyway, and I'll probably be
> prepared to accept that.

Well it's just that CPU1 is what puts the page on the LRU, but CPU0
is the one who's stores we need to order.

CPU0
anon_vma->initialised = 1;
vma->anon_vma = vma;

CPU1
anon_vma = vma->anon_vma;
page->anon_vma = anon_vma;
spin_lock(lru_lock);
list_add(page, lru);
spin_unlock(lru_lock);

CPU2
spin_lock(lru_lock);
anon_vma = page->anon_vma;

So CPU2 definitely would see page->anon_vma to be what CPU1 set it to.
Locks provide that much ordering, of course. But it's CPU0's ordering
which is what matters -- CPU2 could still see anon_vma->initialised == 0
So CPU0 needs smp_wmb() between those.


> I think you're saying that with just that change to anon_vma_prepare(),
> we've then no need for the smp_wmb() and smp_read_barrier_depends() he
> retained from his first version.  I'm afraid my barrier sickness has
> reached that advanced stage in which I can no long tell whether that's
> obviously true or obviously false: like those perspective cube outlines
> you can switch either way in your mind, I see it both ways and feel
> very very stupid.  You'll have to settle that with Linus.

I think you may have worked though it with Linus? However going back to
my example above: if CPU0 were to hold anon_vma->lock around its assignments,
and CPU2 were to take the lock before checking initialised, then the wmb()
would not be required.

It could still be the case that the store to vma->anon_vma becomes visible
first (and so CPU1 could assign the pointer to a page->mapping). However,
by the time anybody is allowed to look inside anon_vma, initialised must be
1 (the spin_unlock must not be visible until _all_ prior stores are).


> > > Nick, are you happy with Linus's patch below?
> > > Or if not, please explain again what's missing - thanks.
> >
> > No, I don't agree with the need for barriers and I think Linus had also
> > not worked through the whole problem at this point because of the
> > just-in-case barriers and hoping to initialise the newly allocated lock
> > as locked, as an optimisation.
> >
> > With my patch, the rules are simple: anybody who wants to look in the
> > anon_vma or modify the anon_vma must take the anon_vma->lock. Then there
> > are no problems with ordering, and no need for any explicit barriers.
>
> But we still have the case where one caller sails through
> anon_vma_prepare() seeing vma->anon_vma set, before the initialization
> of that struct anon_vma (and in particular the lock) is visible to it.
>
> I think you're saying, hell, we don't need separate steps to make a
> lock visible, that would be intolerable: locking the lock makes it
> visible.  So all we have to do is not skip the locking of it in the
> newly allocated case.  If Linus is persuaded, then so am I.


The lock definitely gets initialised by CPU0, by the ctor. So it would
be wrong to allow the anon_vma to become visible and have CPU2 try to
lock a possibly uninitialised lock.

But lock barriers say that subsequent stores are not allowed to be
visible before the store to acquire the lock, and normal (obvious)
cache coherency rules says that the stores to initialise the lock
must not come after the store to lock it. So the store to
vma->anon_vma could not be visible before the lock is locked.

Inside the critical section, things can get jumbled around as usual,
but if you only ever care about those orderings from within the same
lock, everything is guaranteed to be visible.


> > I don't understand your point about requiring ->lock to be initialised
> > coming from find_mergeable_anon_vma. Why? All the critical memory
> > operations get ordered inside the lock AFAIKS (I haven't actually applied
> > Linus' patch to see what the result is, but that should be the case with
> > my patch).
>
> When find_mergeable_anon_vma returns the anon_vma from an adjacent vma
> which could be merged with this one, that's the one case (setting aside
> extend_stack) where this faulting CPU will want to access the content
> of a struct anon_vma which may have been initialized by another CPU -
> to lock it and add vma to its list - rather than just use its address.

OK. But the mergeable anon_vma checks don't actually look inside the
anon_vma AFAIKS. It will end up taking the lock (and hence having the
same memory ordering guarantees as CPU2).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
