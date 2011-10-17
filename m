Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0500C6B0031
	for <linux-mm@kvack.org>; Mon, 17 Oct 2011 14:51:14 -0400 (EDT)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id p9HIp63E016311
	for <linux-mm@kvack.org>; Mon, 17 Oct 2011 11:51:11 -0700
Received: from vcbfk14 (vcbfk14.prod.google.com [10.220.204.14])
	by wpaz1.hot.corp.google.com with ESMTP id p9HIp4L7024372
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 17 Oct 2011 11:51:05 -0700
Received: by vcbfk14 with SMTP id fk14so5833846vcb.6
        for <linux-mm@kvack.org>; Mon, 17 Oct 2011 11:51:04 -0700 (PDT)
Date: Mon, 17 Oct 2011 11:51:00 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: kernel 3.0: BUG: soft lockup: find_get_pages+0x51/0x110
In-Reply-To: <20111016235442.GB25266@redhat.com>
Message-ID: <alpine.LSU.2.00.1110171111150.2545@sister.anvils>
References: <201110122012.33767.pluto@agmk.net> <alpine.LSU.2.00.1110131547550.1346@sister.anvils> <alpine.LSU.2.00.1110131629530.1410@sister.anvils> <20111016235442.GB25266@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Pawel Sikora <pluto@agmk.net>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, jpiszcz@lucidpixels.com, arekm@pld-linux.org, linux-kernel@vger.kernel.org

On Mon, 17 Oct 2011, Andrea Arcangeli wrote:
> On Thu, Oct 13, 2011 at 04:30:09PM -0700, Hugh Dickins wrote:
> > mremap's down_write of mmap_sem, together with i_mmap_mutex/lock,
> > and pagetable locks, were good enough before page migration (with its
> > requirement that every migration entry be found) came in; and enough
> > while migration always held mmap_sem.  But not enough nowadays, when
> > there's memory hotremove and compaction: anon_vma lock is also needed,
> > to make sure a migration entry is not dodging around behind our back.
> 
> For things like migrate and split_huge_page, the anon_vma layer must
> guarantee the page is reachable by rmap walk at all times regardless
> if it's at the old or new address.
> 
> This shall be guaranteed by the copy_vma called by move_vma well
> before move_page_tables/move_ptes can run.
> 
> copy_vma obviously takes the anon_vma lock to insert the new "dst" vma
> into the anon_vma chains structures (vma_link does that). That before
> any pte can be moved.
> 
> Because we keep two vmas mapped on both src and dst range, with
> different vma->vm_pgoff that is valid for the page (the page doesn't
> change its page->index) the page should always find _all_ its pte at
> any given time.
> 
> There may be other variables at play like the order of insertion in
> the anon_vma chain matches our direction of copy and removal of the
> old pte. But I think the double locking of the PT lock should make the
> order in the anon_vma chain absolutely irrelevant (the rmap_walk
> obviously takes the PT lock too), and furthermore likely the
> anon_vma_chain insertion is favorable (the dst vma is inserted last
> and checked last). But it shouldn't matter.

Thanks a lot for thinking it over.  I _almost_ agree with you, except
there's one aspect that I forgot to highlight in the patch comment:
remove_migration_pte() behaves as page_check_address() does by default,
it peeks to see if what it wants is there _before_ taking ptlock.

And therefore, I think, it is possible that during mremap move, the swap
pte is in neither of the locations it tries at the instant it peeks there.

We could put a stop to that: see plausible alternative patch below.
Though I have dithered from one to the other and back, I think on the
whole I still prefer the anon_vma locking in move_ptes(): we don't care
too deeply about the speed of mremap, but we do care about the speed of
exec, and this does add another lock/unlock there, but it will always
be uncontended; whereas the patch at the migration end could be adding
a contended and unnecessary lock.

Oh, I don't know which, you vote - if you now agree there is a problem.
I'll sign off the migrate.c one if you prefer it.  But no hurry.

> 
> Another thing could be the copy_vma vma_merge branch succeeding
> (returning not NULL) but I doubt we risk to fall into that one. For
> the rmap_walk to be always working on both the src and dst
> vma->vma_pgoff the pgoff must be different so we can't possibly be ok
> if there's just 1 vma covering the whole range. I exclude this could
> be the case because the pgoff passed to copy_vma is different than the
> vma->vm_pgoff given to copy_vma, so vma_merge can't possibly succeed.
> 
> Yet another point to investigate is the point where we teardown the
> old vma and we leave the new vma generated by copy_vma
> established. That's apparently taken care of by do_munmap in move_vma
> so that shall be safe too as munmap is safe in the first place.
> 
> Overall I don't think this patch is needed and it seems a noop.
> 
> > It appears that Mel's a8bef8ff6ea1 "mm: migration: avoid race between
> > shift_arg_pages() and rmap_walk() during migration by not migrating
> > temporary stacks" was actually a workaround for this in the special
> > common case of exec's use of move_pagetables(); and we should probably
> > now remove that VM_STACK_INCOMPLETE_SETUP stuff as a separate cleanup.
> 
> I don't think this patch can help with that, the problem of execve vs
> rmap_walk is that there's 1 single vma existing for src and dst
> virtual ranges while execve runs move_page_tables. So there is no
> possible way that rmap_walk will be guaranteed to find _all_ ptes
> mapping a page if there's just one vma mapping either the src or dst
> range while move_page_table runs. No addition of locking whatsoever
> can fix that bug because we miss a vma (well modulo locking that
> prevents rmap_walk to run at all, until we're finished with execve,
> which is more or less what VM_STACK_INCOMPLETE_SETUP does...).
> 
> The only way is to fix this is prevent migrate (or any other rmap_walk
> user that requires 100% reliability from the rmap layer, for example
> swap doesn't require 100% reliability and can still run and gracefully
> fail at finding the pte) while we're moving pagetables in execve. And
> that's what Mel's above mentioned patch does.

Thanks for explaining, yes, you're right.

> 
> The other way to fix that bug that I implemented was to do copy_vma in
> execve, so that we still have both src and dst ranges of
> move_page_tables covered by 2 (not 1) vma, each with the proper
> vma->vm_pgoff, so my approach fixed that bug as well (but requires a
> vma allocation in execve so it was dropped in favor of Mel's patch
> which is totally fine with as both approaches fixes the bug equally
> well, even if now we've to deal with this special case of sometime
> rmap_walk having false negatives if the vma_flags is set, and the
> important thing is that after VM_STACK_INCOMPLETE_SETUP has been
> cleared it won't ever be set again for the whole lifetime of the vma).

I think your two-vmas approach is more aesthetically pleasing (and
matches mremap), but can see that Mel's vmaflag hack^Htechnique ends up
more economical.  It is a bit sad that we lose that all-pages-swappable
condition for unlimited args, for a brief moment, but I think no memory
allocations are made in that interval, so I guess it's fine.

Hugh

> 
> I may be missing something, I did a short review so far, just so the
> patch doesn't get merged if not needed. I mean I think it needs a bit
> more looks on it... The fact the i_mmap_mutex was taken but the
> anon_vma lock was not taken (while in every other place they both are
> needed) certainly makes the patch look correct, but that's just a
> misleading coincidence I think.
> 

--- 3.1-rc9/mm/migrate.c	2011-07-21 19:17:23.000000000 -0700
+++ linux/mm/migrate.c	2011-10-17 11:21:48.923826334 -0700
@@ -119,12 +119,6 @@ static int remove_migration_pte(struct p
 			goto out;
 
 		ptep = pte_offset_map(pmd, addr);
-
-		if (!is_swap_pte(*ptep)) {
-			pte_unmap(ptep);
-			goto out;
-		}
-
 		ptl = pte_lockptr(mm, pmd);
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
