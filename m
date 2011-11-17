Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id DCA746B0072
	for <linux-mm@kvack.org>; Thu, 17 Nov 2011 13:43:00 -0500 (EST)
Date: Thu, 17 Nov 2011 19:42:52 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mremap: enforce rmap src/dst vma ordering in case of
 vma_merge succeeding in copy_vma
Message-ID: <20111117184252.GK3306@redhat.com>
References: <20111104235603.GT18879@redhat.com>
 <CAPQyPG5i87VcnwU5UoKiT6_=tzqO_NOPXFvyEooA1Orbe_ztGQ@mail.gmail.com>
 <20111105013317.GU18879@redhat.com>
 <CAPQyPG5Y1e2dac38OLwZAinWb6xpPMWCya2vTaWLPi9+vp1JXQ@mail.gmail.com>
 <20111107131413.GA18279@suse.de>
 <20111107154235.GE3249@redhat.com>
 <20111107162808.GA3083@suse.de>
 <20111109012542.GC5075@redhat.com>
 <20111116140042.GD3306@redhat.com>
 <alpine.LSU.2.00.1111161540060.1861@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1111161540060.1861@sister.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Mel Gorman <mgorman@suse.de>, Nai Xia <nai.xia@gmail.com>, Pawel Sikora <pluto@agmk.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, jpiszcz@lucidpixels.com, arekm@pld-linux.org, linux-kernel@vger.kernel.org

Hi Hugh,

On Wed, Nov 16, 2011 at 04:16:57PM -0800, Hugh Dickins wrote:
> As you found, the mremap locking long predates truncation's double unmap.
> 
> That's an interesting point, and you may be right - though, what about
> the *very* unlikely case where unmap_mapping_range looks at new vma
> when pte is in old, then at old vma when pte is in new, then
> move_page_tables runs out of memory and cannot complete, then the
> second unmap_mapping_range looks at old vma while pte is still in new
> (I guess this needs some other activity to have jumbled the prio_tree,
> and may just be impossible), then at new (to be abandoned) vma after
> pte has moved back to old.

I tend to think it should still work fine. The second loop is needed
to take care of the "reverse" order. If the first move_page_tables is
not in order the second move_page_tables will be in order. So it
should catch it. If the first move_page_tables is in order, the double
loop will catch any skip in the second move_page_tables.

Well if I'm missing something worst case we'd need a dummy
mutex_lock/unlock of the i_mmap_mutex before running the rolling-back
move_page_tables no big deal, still out of the fast path.

> But since nobody ever complained about that added overhead, I never
> got around to bothering; and you may consider the i_mmap_mutex in
> move_ptes a more serious unnecessary overhead.

The point is that if there's no solution to fix truncate by removing
the double loop for the other reasons, so we could take advantage of
the double loop in mremap too (adding proper comment to truncate.c of
course).

> By the way, you mention "a comment saying it's for fork()": I don't
> find "fork" anywhere in mm/truncate.c, my understanding is in this
> comment (probably mine) from truncate_pagecache():
> 
> 	/*
> 	 * unmap_mapping_range is called twice, first simply for
> 	 * efficiency so that truncate_inode_pages does fewer
> 	 * single-page unmaps.  However after this first call, and
> 	 * before truncate_inode_pages finishes, it is possible for
> 	 * private pages to be COWed, which remain after
> 	 * truncate_inode_pages finishes, hence the second
> 	 * unmap_mapping_range call must be made for correctness.
> 	 */
> 
> The second call was not (I think) necessary when we relied upon
> truncate_count, but became necessary once Nick relied upon page lock
> (the page lock on the file page providing no guarantee for the COWed
> page).

I see. Truncate locks down the page while it shoots down the pte so no
new mapping could be established, while the COWs still can because
they don't take the lock on the old page. But do_wp_page takes the
lock for anon pages and MAP_SHARED. It's a little weird it doesn't
take it for MAP_PRIVATE (i.e. VM_SHARED not set). MAP_SHARED already
does the check for page->mapping being null after the lock is obtained.

The double loop happens to make fork safe too, or the inverse ordering
between truncate and fork would lead to the same issue and that will
also map pagecache (not just anon cows). I don't see lock_page in fork
it just copies the pte it doesn't mangle on the page lock.

Note however that for a tiny window, with the current truncate code
that does unmap+truncate+unmap, there can still be a pte in the fork
child that points to an orphaned pagecache (before the second call of
unmap_mapping_range starts). It'd be a transient pte, it'll be dropped
as soon as the second unmap_mapping_range runs. Not sure how bad that
thing is. To avoid it we'd need to run unmap+unmap+truncate. That way
no pte in fork could map anymore a orphaned pagecache. But then the
second unmap wouldn't take down the COWs generated by do_wp_page in
MAP_PRIVATE areas anymore.

So it boils down if we are ok with transient pte mapping an orphaned
pagecache for a little. The only problem I can see is that writes
would then be discared without triggering SIGBUS beyond the end of
i_size on MAP_SHARED. But if the write from the other process (or
thread) happened a millisecond before it would be discared anyway. So
I guess it's not a problem and it's mostly an implementation issue if
there could be any code that won't like a pte pointing to an orphaned
pagecache for a little while. I'm optimistic it can work safe and we
can just drop the i_mmap_mutex completely from mremap after checking
that those transient ptes mapping orphaned pagecache won't trigger
asserts.

As for the anon_vma my ordering patch (last version I posted) fixes it
already. The other way is to add double loops. Or the anon_vma->lock
of course!

If we go double loops for anon-vma, with split_huge_page I could
unlink any anon_vma_chain where the address-range matches but the
pte/pmd is not found, and re-check in the second loop _only_ those
anon_vma_chains where we failed to find a mapping. Only thought about
it, not actually attempted to implement it. Even rmap_walk could do
that but it requires changes to the caller (i.e. migrate.c), while for
split_huge_page it'd be simpler local change. Then I would relink the
re-checked anon_vma_chains with list_splice. The whole list is
protected by the root anon vma lock which is hold for the whole
duration of split_huge_page so I guess it shall be doable.

The rmap_walks of filebacked mappings won't need any double loop (only
migrate and split_huge_page will need it) because neither
remove_migration_ptes nor split_huge_page runs on filebacked mappings
as migration ptes and hugepage splits only runs for anon memory. And
nothing would prevent to add double loops there too if we extend
split_huge_page to pagecache (we already double loop in truncate).

Nai, if prio tree could guarantee ordering, 1) there would be no
i_mmap_lock I guess, or there would be a comment that it's only for
the vma_merge case and the error path that goes in reverse order, 2)
if you were right that list_add_tail in prio tree and both src and dst
vmas being in the same node guarantees ordering, it would imply the
prio tree works in O(N) and that can't be or we'd use a list instead
of a prio tree. The whole idea of any structure smarter of a list is
to insert things in some "order" that depends on the index (the index
is the vm_start,vm_end range in the prio tree case) do some "work" in
insert so the walk can be faster, but that practically guarantees the
walk won't be in the same order as the way it was inserted.

If prio tree could guarantee ordering then I could also reoder the
prio tree extending my patch that already fixes it the anon_vma case,
and still avoid the i_mmap_mutex without requiring double loops.

So in short.

1) for anon I'm not sure if it's better my current patch that fixes
the anon case just fine, or if to go double loops in
split_huge_page/migrate, or if to add the anon_vma lock aroudn
move_page_tables.

2) for filebacked if we can deal with the transient pte on orphaned
pagecache we can just add a comment to truncate.c and drop the
i_mmap_mutex.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
