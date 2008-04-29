Date: Tue, 29 Apr 2008 11:49:11 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH 01 of 12] Core of mmu notifiers
In-Reply-To: <20080429001052.GA8315@duo.random>
Message-ID: <Pine.LNX.4.64.0804291128330.12702@blonde.site>
References: <20080423002848.GA32618@sgi.com> <20080423163713.GC24536@duo.random>
 <20080423221928.GV24536@duo.random> <20080424064753.GH24536@duo.random>
 <20080424095112.GC30298@sgi.com> <20080424153943.GJ24536@duo.random>
 <20080424174145.GM24536@duo.random> <20080426131734.GB19717@sgi.com>
 <20080427122727.GO9514@duo.random> <Pine.LNX.4.64.0804281332030.31163@schroedinger.engr.sgi.com>
 <20080429001052.GA8315@duo.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Christoph Lameter <clameter@sgi.com>, Robin Holt <holt@sgi.com>, Jack Steiner <steiner@sgi.com>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, general@lists.openfabrics.org, akpm@linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>
List-ID: <linux-mm.kvack.org>

On Tue, 29 Apr 2008, Andrea Arcangeli wrote:
> 
> My point of view is that there was no rcu when I wrote that code, yet
> there was no reference count and yet all locking looks still exactly
> the same as I wrote it. There's even still the page_table_lock to
> serialize threads taking the mmap_sem in read mode against the first
> vma->anon_vma = anon_vma during the page fault.
> 
> Frankly I've absolutely no idea why rcu is needed in all rmap code
> when walking the page->mapping. Definitely the PG_locked is taken so
> there's no way page->mapping could possibly go away under the rmap
> code, hence the anon_vma can't go away as it's queued in the vma, and
> the vma has to go away before the page is zapped out of the pte.

[I'm scarcely following the mmu notifiers to-and-fro, which seems
to be in good hands, amongst faster thinkers than me: who actually
need and can test this stuff.  Don't let me slow you down; but I
can quickly clarify on this history.]

No, the locking was different as you had it, Andrea: there was an extra
bitspin lock, carried over from the pte_chains days (maybe we changed
the name, maybe we disagreed over the name, I forget), which mainly
guarded the page->mapcount.  I thought that was one lock more than we
needed, and eliminated it in favour of atomic page->mapcount in 2.6.9.

Here's the relevant extracts from ChangeLog-2.6.9:

[PATCH] rmaplock: PageAnon in mapping

First of a batch of five patches to eliminate rmap's page_map_lock, replace
its trylocking by spinlocking, and use anon_vma to speed up swapoff.

Patches updated from the originals against 2.6.7-mm7: nothing new so I won't
spam the list, but including Manfred's SLAB_DESTROY_BY_RCU fixes, and omitting
the unuse_process mmap_sem fix already in 2.6.8-rc3.

This patch:

Replace the PG_anon page->flags bit by setting the lower bit of the pointer in
page->mapping when it's anon_vma: PAGE_MAPPING_ANON bit.

We're about to eliminate the locking which kept the flags and mapping in
synch: it's much easier to work on a local copy of page->mapping, than worry
about whether flags and mapping are in synch (though I imagine it could be
done, at greater cost, with some barriers).

[PATCH] rmaplock: kill page_map_lock

The pte_chains rmap used pte_chain_lock (bit_spin_lock on PG_chainlock) to
lock its pte_chains.  We kept this (as page_map_lock: bit_spin_lock on
PG_maplock) when we moved to objrmap.  But the file objrmap locks its vma tree
with mapping->i_mmap_lock, and the anon objrmap locks its vma list with
anon_vma->lock: so isn't the page_map_lock superfluous?

Pretty much, yes.  The mapcount was protected by it, and needs to become an
atomic: starting at -1 like page _count, so nr_mapped can be tracked precisely
up and down.  The last page_remove_rmap can't clear anon page mapping any
more, because of races with page_add_rmap; from which some BUG_ONs must go for
the same reason, but they've served their purpose.

vmscan decisions are naturally racy, little change there beyond removing
page_map_lock/unlock.  But to stabilize the file-backed page->mapping against
truncation while acquiring i_mmap_lock, page_referenced_file now needs page
lock to be held even for refill_inactive_zone.  There's a similar issue in
acquiring anon_vma->lock, where page lock doesn't help: which this patch
pretends to handle, but actually it needs the next.

Roughly 10% cut off lmbench fork numbers on my 2*HT*P4.  Must confess my
testing failed to show the races even while they were knowingly exposed: would
benefit from testing on racier equipment.

[PATCH] rmaplock: SLAB_DESTROY_BY_RCU

With page_map_lock gone, how to stabilize page->mapping's anon_vma while
acquiring anon_vma->lock in page_referenced_anon and try_to_unmap_anon?

The page cannot actually be freed (vmscan holds reference), but however much
we check page_mapped (which guarantees that anon_vma is in use - or would
guarantee that if we added suitable barriers), there's no locking against page
becoming unmapped the instant after, then anon_vma freed.

It's okay to take anon_vma->lock after it's freed, so long as it remains a
struct anon_vma (its list would become empty, or perhaps reused for an
unrelated anon_vma: but no problem since we always check that the page located
is the right one); but corruption if that memory gets reused for some other
purpose.

This is not unique: it's liable to be problem whenever the kernel tries to
approach a structure obliquely.  It's generally solved with an atomic
reference count; but one advantage of anon_vma over anonmm is that it does not
have such a count, and it would be a backward step to add one.

Therefore...  implement SLAB_DESTROY_BY_RCU flag, to guarantee that such a
kmem_cache_alloc'ed structure cannot get freed to other use while the
rcu_read_lock is held i.e.  preempt disabled; and use that for anon_vma.

Fix concerns raised by Manfred: this flag is incompatible with poisoning and
destructor, and kmem_cache_destroy needs to synchronize_kernel.

I hope SLAB_DESTROY_BY_RCU may be useful elsewhere; but though it's safe for
little anon_vma, I'd be reluctant to use it on any caches whose immediate
shrinkage under pressure is important to the system.

[PATCH] rmaplock: mm lock ordering

With page_map_lock out of the way, there's no need for page_referenced and
try_to_unmap to use trylocks - provided we switch anon_vma->lock and
mm->page_table_lock around in anon_vma_prepare.  Though I suppose it's
possible that we'll find that vmscan makes better progress with trylocks than
spinning - we're free to choose trylocks again if so.

Try to update the mm lock ordering documentation in filemap.c.  But I still
find it confusing, and I've no idea of where to stop.  So add an mm lock
ordering list I can understand to rmap.c.

[The fifth patch was about using anon_vma in swapoff, not relevant here.]

So, going back to what you wrote: holding the page lock there is
not enough to prevent the struct anon_vma going away beneath us.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
