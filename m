Date: Wed, 11 Jul 2007 21:45:15 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: mmu_gather changes & generalization
In-Reply-To: <1184046405.6059.17.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0707112100050.16237@blonde.wat.veritas.com>
References: <1184046405.6059.17.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>
List-ID: <linux-mm.kvack.org>

On Tue, 10 Jul 2007, Benjamin Herrenschmidt wrote:
> So to make things simple: I want to generalize the tlb batch interfaces
> to all flushing, except single pages and possible kernel page table
> flushing.
> 
> Note that I expect some perf. improvements on things like ppc32 on fork
> due to being able to target for shooting only hash entries for PTEs that
> have actually be turned into RO. The current ppc32 hash code just
> basically re-walks the page tables in flush_tlb_mm() and shoots down all
> PTEs that have been hashed.

I've moved your last paragraph up here: that last sentence makes sense
of the whole thing, and I'm now much happier with what you're intending,
than when I first just thought you were trying to complicate flush_tlb_mm.

> 
> I've discussed a bit with Nick today, and came up with this idea as a
> first step toward possible bigger changes/cleanups. He told me you have
> been working around the same lines, so I'd like your feedback there and
> possibly whatever patches you are already cooking :-)

I worked on it around 2.6.16, but wasn't satisfied with the result,
and then got stalled.  What I should do now is update what I had to
2.6.22, and in doing so remind myself of the limitations, and send
the results off to you - from what you say, I've a few days for that
before you get to work on it.

I think there were two issues that stalled me.  One, I was mainly
trying to remove that horrid ZAP_BLOCK_SIZE from unmap_vmas, allowing
preemption more naturally; but failed to solve the truncation case,
when i_mmap_lock is held.  Two, I needed to understand the different
arches better: though it's grand if you're coming aboard, because
powerpc (along with the seemingly similar sparc64) was one of the
exceptions, deferring the flush to context switch (I need to remind
myself why that was an issue).  The other arches, even if not using
asm-generic, seemed pretty much generic: arm a little simpler than
generic, ia64 a little more baroque but more similar than it looked.
Sounds like Martin may be about to take s390 in its own direction.

The only arches I actually converted over were i386 and x86_64
(knowing others would keep changing while I worked on the patch).

> 
> First, the situation/problems:
> 
>  - The problems with using the current mmu_gather is the fact that it's
> per-cpu, thus needs to be flushed when we do lock dropping and might
> schedule. That means more work than necessary on things like x86 when
> using it for fork or mprotect for example.

Yes, it dates from early 2.4, long before preemption latency placed
limits on our use of per-cpu areas.

> 
>  - Essentially, a simple batch data structure doesn't need to be
> per-CPU, it could just be on the stack. However, the current one is
> per-cpu because of this massive list of struct page's which is too big
> for a stack allocation.
> 
> Now the idea is to turn mmu_gather into a small stack based data
> structure, with an optional pointer to the list of pages which remains,
> for now, per-cpu.

What I had was the small stack based data structure, with a small
fallback array of struct page pointers built in, and attempts to
allocate a full page atomically when this array not big enough -
just go slower with the small array when that allocation fails.
There may be cleverer approaches, but it seems good enough.

> 
> The initializer for it (tlb_gather_init ?) would then take a flag/type
> argument saying whether it is to be used for simple invalidations, or
> invalidations + pages freeing.

Yes, I had some flags too.

> 
> If used for page freeing, that pointer points to the per-cpu list of
> pages and we do get_cpu (and put_cpu when finishing the batch). If used
> for simple invalidations, we set that pointer to NULL and don't do
> get_cpu/put_cpu.

The particularly bad thing about get_cpu/put_cpu there, is that
the efficiently big array stores up a lot of work for the future
(when swapcached pages are freed), which still has to be done
with preemption disabled.

Could the migrate_disable now proposed help there?  At the time
I had that same idea, but discarded it because of the complication
of different tasks (different mms) needing the same per-cpu buffer;
but perhaps that isn't much of a complication in fact.

> 
> That way, we don't have to finish/restart the batch unless we are
> freeing pages. Thus users like fork() don't need to finish/restart the
> batch, and thus, we have no overhead on x86 compared to the current
> implementation (well, other than setting need_flush to 1 but that's
> probably not close to measurable).

;)

> 
> Thus, the implementation remains as far as unmap_vmas is concerned,
> essentially the same. We just make it stack based at the top-level and
> change the init call, and we can avoid passing double indirections down
> the call chain, which is a nice cleanup.

Yes, that cleanup I did do.

> 
> An additional cleanup that it directly leads to is rather than
> finish/init when doing lock-break, when can introduce a reinit call that
> restarts a batch keeping the existing "settings" (We would still call
> finish, it's just that the call pair would be finish/reinit). That way,
> we don't have to "remember" things like fullmm like we have to do
> currently.
> 
> Since it's no longer per-cpu, things like fullmm or mm are still valid
> in the batch structure, and so we don't have to carry "fullmm" around
> like we do in unmap_vmas (and like we would have to do in other users).
> In fact, arch implementations can carry around even more state that they
> might need and keep it around lock breaks that way.

Yes, more good cleanup that fell out naturally.

> 
> That would provide a good ground for then looking into changing the
> per-cpu list of pages to something else, as Nick told me you were
> working on.
> 
> Any comment, idea, suggestions ? I will give a go at implementing that
> sometime this week I hope (I have some urgent stuff to do first) unless
> you guys convince me it's worthless :-)

So ignore my initial distrust, it all seems reasonable.  But please
remind me, what other than dup_mmap would you be extending this to?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
