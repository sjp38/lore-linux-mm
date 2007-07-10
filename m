Subject: mmu_gather changes & generalization
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Content-Type: text/plain
Date: Tue, 10 Jul 2007 15:46:45 +1000
Message-Id: <1184046405.6059.17.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>
List-ID: <linux-mm.kvack.org>

So to make things simple: I want to generalize the tlb batch interfaces
to all flushing, except single pages and possible kernel page table
flushing.

I've discussed a bit with Nick today, and came up with this idea as a
first step toward possible bigger changes/cleanups. He told me you have
been working around the same lines, so I'd like your feedback there and
possibly whatever patches you are already cooking :-)

First, the situation/problems:

 - The problems with using the current mmu_gather is the fact that it's
per-cpu, thus needs to be flushed when we do lock dropping and might
schedule. That means more work than necessary on things like x86 when
using it for fork or mprotect for example.

 - Essentially, a simple batch data structure doesn't need to be
per-CPU, it could just be on the stack. However, the current one is
per-cpu because of this massive list of struct page's which is too big
for a stack allocation.

Now the idea is to turn mmu_gather into a small stack based data
structure, with an optional pointer to the list of pages which remains,
for now, per-cpu.

The initializer for it (tlb_gather_init ?) would then take a flag/type
argument saying whether it is to be used for simple invalidations, or
invalidations + pages freeing.

If used for page freeing, that pointer points to the per-cpu list of
pages and we do get_cpu (and put_cpu when finishing the batch). If used
for simple invalidations, we set that pointer to NULL and don't do
get_cpu/put_cpu.

That way, we don't have to finish/restart the batch unless we are
freeing pages. Thus users like fork() don't need to finish/restart the
batch, and thus, we have no overhead on x86 compared to the current
implementation (well, other than setting need_flush to 1 but that's
probably not close to measurable).

Thus, the implementation remains as far as unmap_vmas is concerned,
essentially the same. We just make it stack based at the top-level and
change the init call, and we can avoid passing double indirections down
the call chain, which is a nice cleanup.

An additional cleanup that it directly leads to is rather than
finish/init when doing lock-break, when can introduce a reinit call that
restarts a batch keeping the existing "settings" (We would still call
finish, it's just that the call pair would be finish/reinit). That way,
we don't have to "remember" things like fullmm like we have to do
currently.

Since it's no longer per-cpu, things like fullmm or mm are still valid
in the batch structure, and so we don't have to carry "fullmm" around
like we do in unmap_vmas (and like we would have to do in other users).
In fact, arch implementations can carry around even more state that they
might need and keep it around lock breaks that way.

That would provide a good ground for then looking into changing the
per-cpu list of pages to something else, as Nick told me you were
working on.

Any comment, idea, suggestions ? I will give a go at implementing that
sometime this week I hope (I have some urgent stuff to do first) unless
you guys convince me it's worthless :-)

Note that I expect some perf. improvements on things like ppc32 on fork
due to being able to target for shooting only hash entries for PTEs that
have actually be turned into RO. The current ppc32 hash code just
basically re-walks the page tables in flush_tlb_mm() and shoots down all
PTEs that have been hashed.

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
