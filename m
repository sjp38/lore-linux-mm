Date: Sat, 14 Jul 2007 16:33:22 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: mmu_gather changes & generalization
In-Reply-To: <1184366770.6059.266.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0707141620320.15139@blonde.wat.veritas.com>
References: <1184046405.6059.17.camel@localhost.localdomain>
 <Pine.LNX.4.64.0707112100050.16237@blonde.wat.veritas.com>
 <1184195933.6059.111.camel@localhost.localdomain>
 <Pine.LNX.4.64.0707121715500.4887@blonde.wat.veritas.com>
 <1184287915.6059.163.camel@localhost.localdomain>
 <Pine.LNX.4.64.0707132126001.5377@blonde.wat.veritas.com>
 <1184366770.6059.266.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>
List-ID: <linux-mm.kvack.org>

On Sat, 14 Jul 2007, Benjamin Herrenschmidt wrote:
> 
> > Here's the 2.6.22 version of what I worked on just after 2.6.16.
> > As I said before, if you find it useful to build upon, do so;
> > but if not, not.  From something you said earlier, I've a
> > feeling we'll be fighting over where to place the TLB flushes,
> > inside or outside the page table lock.
> 
> ppc64 needs inside, but I don't want to change the behaviour for others,
> so I'll probably do a pair of tlb_after_pte_lock and
> tlb_before_pte_unlock that do nothing by default and that ppc64 can use
> to do the flush before unlocking.

Yeah, something like that, I suppose (better naming!).  And I think
your ppc64 implementation will do best just to flush TLB in _before,
leaving the page freeing to the _after; whereas most will do them
both in the _after.

> 
> It seems like virtualization stuff needs that too, thus we could replace
> a whole lot of the lazy_mmu stuff in there with those 2 hooks, making
> things a little bit less confusing.

That would be good, I didn't look into those lazy_mmu things at all:
we're in perfect agreement that the fewer such the better.

> 
> > A few notes:
> > 
> > Keep in mind: hard to have low preemption latency with decent throughput
> > in zap_pte_range - easier than it once was now the ptl is taken lower down,
> > but big problem when truncation/invalidation holds i_mmap_lock to scan the
> > vma prio_tree - drop that lock and it has to restart.  Not satisfactorily
> > solved yet (sometimes I think we should collapse the prio_tree into a list
> > for the duration of the unmapping: no problem putting a marker in the list).
> 
> I don't intend to change he behaviour at this stage, only the
> interfaces, though I expect the new interfaces to make it easier to toy
> around with the behaviour.

Right, that may lead you to set aside a lot of what I did for now.

..../... (if I may echo you ;)

> I think we could do better by having the mmu_gather contain an
> mmu_gather_arch field (arch defined, for additional fields in there) and
> use for -all- the mmu_gather functions something like
> 
> #ifndef tlb_start_vma
> static inline void tlb_start_vma(...)
> {
> 	..../...
> }
> #endif
> 
> Thus archs that need their own version would just do:
> 
> static inline void tlb_start_vma(...)
> {
> 	..../...
> }
> #define tlb_start_vma tlb_start_vma
> 
> Not sure about that yet, waiting for people to flame me with "that's
> horrible" :-)

No, sounds good to me, no flame from this direction:
it's exactly what Linus prefers to the __HAVE_ARCH... stuff.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
