Subject: Re: mmu_gather changes & generalization
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <Pine.LNX.4.64.0707112100050.16237@blonde.wat.veritas.com>
References: <1184046405.6059.17.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0707112100050.16237@blonde.wat.veritas.com>
Content-Type: text/plain
Date: Thu, 12 Jul 2007 09:18:53 +1000
Message-Id: <1184195933.6059.111.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>
List-ID: <linux-mm.kvack.org>

> I think there were two issues that stalled me.  One, I was mainly
> trying to remove that horrid ZAP_BLOCK_SIZE from unmap_vmas, allowing
> preemption more naturally; but failed to solve the truncation case,
> when i_mmap_lock is held.  Two, I needed to understand the different
> arches better: though it's grand if you're coming aboard, because
> powerpc (along with the seemingly similar sparc64) was one of the
> exceptions, deferring the flush to context switch (I need to remind
> myself why that was an issue).

Actually, that was broken on ppc64. It really needs to flush before we
drop the PTE lock or you may end up with duplicate entries in the hash
table which is fatal. I fixed it recently by using a completely
different mechanism there. I now use the lazy mmu hooks to start/stop
batching of invalidations. But that's temporary. One of the thing I want
to do with the batches is to add a hook for use by ppc64 to be called
before releasing the PTE lock :-) That or I may do things a bit
differently to make it safe to defer the flush.

In any case, that's orthogonal to the changes I'm thinking about.

> The other arches, even if not using
> asm-generic, seemed pretty much generic: arm a little simpler than
> generic, ia64 a little more baroque but more similar than it looked.
> Sounds like Martin may be about to take s390 in its own direction.

arm and sparc64 have a simpler version, which could be moved to
asm-generic/tlb-simple.h or so, for arch that either don't care much or
use a different batching mechanism (such as sparc64).
 
> The only arches I actually converted over were i386 and x86_64
> (knowing others would keep changing while I worked on the patch).

That's allright. I can take care of the ppc's and maybe sparc64 too.

 .../...

> >  - Essentially, a simple batch data structure doesn't need to be
> > per-CPU, it could just be on the stack. However, the current one is
> > per-cpu because of this massive list of struct page's which is too big
> > for a stack allocation.
> > 
> > Now the idea is to turn mmu_gather into a small stack based data
> > structure, with an optional pointer to the list of pages which remains,
> > for now, per-cpu.
> 
> What I had was the small stack based data structure, with a small
> fallback array of struct page pointers built in, and attempts to
> allocate a full page atomically when this array not big enough -
> just go slower with the small array when that allocation fails.
> There may be cleverer approaches, but it seems good enough.

Yes, that's what Nick described. I had in mind an incremental approach,
starting with just splitting the batch into the stack based structure
and the page list and keeping the per-cpu page list, and then, letting
you change that too separately, but we can do it the other way around.

 .../...

> The particularly bad thing about get_cpu/put_cpu there, is that
> the efficiently big array stores up a lot of work for the future
> (when swapcached pages are freed), which still has to be done
> with preemption disabled.
> 
> Could the migrate_disable now proposed help there?  At the time
> I had that same idea, but discarded it because of the complication
> of different tasks (different mms) needing the same per-cpu buffer;
> but perhaps that isn't much of a complication in fact.

I haven't looked at that migrate_disable thing yet. Google time :-)

> So ignore my initial distrust, it all seems reasonable.  But please
> remind me, what other than dup_mmap would you be extending this to?

Initially, just that and that gremlin in fs/proc/task_mmu.c... (that is
users of flush_tlb_mm(), thus removing it as a generic->arch hook).

Though I was thinking of also taking care of flush_tlb_range(), which
would then add mprotect to the list, and some hugetlb stuff.

BTW, talking about MMU interfaces.... I've had a quick look yesterday
and there's a load of stuff in the various pgtable.h imeplemtations that
isn't used at all anymore ! For example, ptep_test_and_clear_dirty() is
no longer used by rmap, and there's a whole lot of others like that.

Also, there are some archs whose implementation is identical to
asm-generic for some of these.

I was thinking about doing pass through the whole tree getting rid of
everything that's not used or duplicate of asm-generic while at it,
unless you have reasons not to do that or you know somebody already
doing it.

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
