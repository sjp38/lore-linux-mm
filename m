Subject: Re: mmu_gather changes & generalization
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <Pine.LNX.4.64.0707132126001.5377@blonde.wat.veritas.com>
References: <1184046405.6059.17.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0707112100050.16237@blonde.wat.veritas.com>
	 <1184195933.6059.111.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0707121715500.4887@blonde.wat.veritas.com>
	 <1184287915.6059.163.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0707132126001.5377@blonde.wat.veritas.com>
Content-Type: text/plain
Date: Sat, 14 Jul 2007 08:46:10 +1000
Message-Id: <1184366770.6059.266.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>
List-ID: <linux-mm.kvack.org>

> Here's the 2.6.22 version of what I worked on just after 2.6.16.
> As I said before, if you find it useful to build upon, do so;
> but if not, not.  From something you said earlier, I've a
> feeling we'll be fighting over where to place the TLB flushes,
> inside or outside the page table lock.

ppc64 needs inside, but I don't want to change the behaviour for others,
so I'll probably do a pair of tlb_after_pte_lock and
tlb_before_pte_unlock that do nothing by default and that ppc64 can use
to do the flush before unlocking.

It seems like virtualization stuff needs that too, thus we could replace
a whole lot of the lazy_mmu stuff in there with those 2 hooks, making
things a little bit less confusing.

> A few notes:
> 
> Keep in mind: hard to have low preemption latency with decent throughput
> in zap_pte_range - easier than it once was now the ptl is taken lower down,
> but big problem when truncation/invalidation holds i_mmap_lock to scan the
> vma prio_tree - drop that lock and it has to restart.  Not satisfactorily
> solved yet (sometimes I think we should collapse the prio_tree into a list
> for the duration of the unmapping: no problem putting a marker in the list).

I don't intend to change he behaviour at this stage, only the
interfaces, though I expect the new interfaces to make it easier to toy
around with the behaviour.

> The mmu_gather of pages to be freed after TLB flush represents a signficant
> quantity of deferred work, particularly when those pages are in swapcache:
> we do want preemption enabled while freeing them, but we don't want to lose
> our place in the prio_tree very often.

Same comment as above :-) I understand the problem but I don't see any
magical way of making things better here, so I'll concentrate on
cleaning up the interfaces while keeping the exact same behaviour and
then I can have a second look see if I come up with some idea on how to
make things better.

> Don't be misled by inclusion of patches to ia64 and powerpc hugetlbpage.c,
> that's just to replace **tlb by *tlb in one function: the real mmu_gather
> conversion is yet to be done there.

Ok.

> Only i386 and x86_64 have been converted, built and (inadequately) tested so
> far: but most arches shouldn't need more than removing their DEFINE_PER_CPU,
> with arm and arm26 probably just wanting to use more of the generic code.
> 
> sparc64 uses a flush_tlb_pending technique which defers a lot of work until
> context switch, when it cannot be preempted: I've given little thought to it.
> powerpc appeared similar to sparc64, but you've changed it since 2.6.16.

powerpc64 used to do that, but I had that massive bug because it needs
to flush before the page table lock is released (or we might end up with
duplicates in the hash table, which is fatal).

> I've removed the start,end args to tlb_finish_mmu, and several levels above
> it: the tlb_start_valid business in unmap_vmas always seemed ugly to me,
> only ia64 has made use of them, and I cannot see why it shouldn't just
> record first and last addr when its tlb_remove_tlb_entry is called.
> But since ia64 isn't done yet, that end of it isn't seen in the patch.

Agreed. I'd rather have archs that care explicitely record start/end.

One thing I'm also thinking about doing is slighlty changing the way the
"generic" gather interface is defined. Currently, you have some things
you can define in the arch (such as tlb_start/end_vma), some things
that are totally defined for you, such as the struct mmu_gather itself,
etc... thus some archs have to replace the whole things, some can hook
half way through, but in general, I find it confusing.

I think we could do better by having the mmu_gather contain an
mmu_gather_arch field (arch defined, for additional fields in there) and
use for -all- the mmu_gather functions something like

#ifndef tlb_start_vma
static inline void tlb_start_vma(...)
{
	..../...
}
#endif

Thus archs that need their own version would just do:

static inline void tlb_start_vma(...)
{
	..../...
}
#define tlb_start_vma tlb_start_vma

Not sure about that yet, waiting for people to flame me with "that's
horrible" :-)

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
