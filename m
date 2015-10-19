Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f172.google.com (mail-ob0-f172.google.com [209.85.214.172])
	by kanga.kvack.org (Postfix) with ESMTP id 98A0A82F67
	for <linux-mm@kvack.org>; Mon, 19 Oct 2015 00:50:54 -0400 (EDT)
Received: by obbzf10 with SMTP id zf10so129696949obb.2
        for <linux-mm@kvack.org>; Sun, 18 Oct 2015 21:50:54 -0700 (PDT)
Received: from mail-ob0-x231.google.com (mail-ob0-x231.google.com. [2607:f8b0:4003:c01::231])
        by mx.google.com with ESMTPS id wk6si13660214oeb.101.2015.10.18.21.50.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 Oct 2015 21:50:53 -0700 (PDT)
Received: by obcqt19 with SMTP id qt19so51776364obc.3
        for <linux-mm@kvack.org>; Sun, 18 Oct 2015 21:50:53 -0700 (PDT)
Date: Sun, 18 Oct 2015 21:50:47 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 2/12] mm: rmap use pte lock not mmap_sem to set PageMlocked
In-Reply-To: <alpine.LSU.2.11.1510182132470.2481@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1510182148040.2481@eggly.anvils>
References: <alpine.LSU.2.11.1510182132470.2481@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Davidlohr Bueso <dave@stgolabs.net>, Oleg Nesterov <oleg@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Andrey Konovalov <andreyknvl@google.com>, Dmitry Vyukov <dvyukov@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org

KernelThreadSanitizer (ktsan) has shown that the down_read_trylock()
of mmap_sem in try_to_unmap_one() (when going to set PageMlocked on
a page found mapped in a VM_LOCKED vma) is ineffective against races
with exit_mmap()'s munlock_vma_pages_all(), because mmap_sem is not
held when tearing down an mm.

But that's okay, those races are benign; and although we've believed
for years in that ugly down_read_trylock(), it's unsuitable for the job,
and frustrates the good intention of setting PageMlocked when it fails.

It just doesn't matter if here we read vm_flags an instant before or
after a racing mlock() or munlock() or exit_mmap() sets or clears
VM_LOCKED: the syscalls (or exit) work their way up the address space
(taking pt locks after updating vm_flags) to establish the final state.

We do still need to be careful never to mark a page Mlocked (hence
unevictable) by any race that will not be corrected shortly after.
The page lock protects from many of the races, but not all (a page
is not necessarily locked when it's unmapped).  But the pte lock we
just dropped is good to cover the rest (and serializes even with
munlock_vma_pages_all(), so no special barriers required): now hold
on to the pte lock while calling mlock_vma_page().  Is that lock
ordering safe?  Yes, that's how follow_page_pte() calls it, and
how page_remove_rmap() calls the complementary clear_page_mlock().

This fixes the following case (though not a case which anyone has
complained of), which mmap_sem did not: truncation's preliminary
unmap_mapping_range() is supposed to remove even the anonymous COWs
of filecache pages, and that might race with try_to_unmap_one() on a
VM_LOCKED vma, so that mlock_vma_page() sets PageMlocked just after
zap_pte_range() unmaps the page, causing "Bad page state (mlocked)"
when freed.  The pte lock protects against this.

You could say that it also protects against the more ordinary case,
racing with the preliminary unmapping of a filecache page itself: but
in our current tree, that's independently protected by i_mmap_rwsem;
and that race would be why "Bad page state (mlocked)" was seen before
commit 48ec833b7851 ("Revert mm/memory.c: share the i_mmap_rwsem").

While we're here, make a related optimization in try_to_munmap_one():
if it's doing TTU_MUNLOCK, then there's no point at all in descending
the page tables and getting the pt lock, unless the vma is VM_LOCKED.
Yes, that can change racily, but it can change racily even without the
optimization: it's not critical.  Far better not to waste time here.

Stopped short of separating try_to_munlock_one() from try_to_munmap_one()
on this occasion, but that's probably the sensible next step - with a
rename, given that try_to_munlock()'s business is to try to set Mlocked.

Updated the unevictable-lru Documentation, to remove its reference to
mmap semaphore, but found a few more updates needed in just that area.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
I've cc'ed a lot of people on this one, since it originated in the
"Multiple potential races on vma->vm_flags" discussion.  But didn't
cc everyone on the not-very-interesting 1/12 "mm Documentation: undoc
non-linear vmas" - so if you apply just this to a 4.3-rc6 or mmotm tree,
yes, there will be rejects on unevictable-lru.txt, that's expected.

 Documentation/vm/unevictable-lru.txt |   65 ++++++-------------------
 mm/rmap.c                            |   36 ++++---------
 2 files changed, 29 insertions(+), 72 deletions(-)

--- migrat.orig/Documentation/vm/unevictable-lru.txt	2015-10-18 17:53:03.716313651 -0700
+++ migrat/Documentation/vm/unevictable-lru.txt	2015-10-18 17:53:07.098317501 -0700
@@ -531,37 +531,20 @@ map.
 
 try_to_unmap() is always called, by either vmscan for reclaim or for page
 migration, with the argument page locked and isolated from the LRU.  Separate
-functions handle anonymous and mapped file pages, as these types of pages have
-different reverse map mechanisms.
-
- (*) try_to_unmap_anon()
-
-     To unmap anonymous pages, each VMA in the list anchored in the anon_vma
-     must be visited - at least until a VM_LOCKED VMA is encountered.  If the
-     page is being unmapped for migration, VM_LOCKED VMAs do not stop the
-     process because mlocked pages are migratable.  However, for reclaim, if
-     the page is mapped into a VM_LOCKED VMA, the scan stops.
-
-     try_to_unmap_anon() attempts to acquire in read mode the mmap semaphore of
-     the mm_struct to which the VMA belongs.  If this is successful, it will
-     mlock the page via mlock_vma_page() - we wouldn't have gotten to
-     try_to_unmap_anon() if the page were already mlocked - and will return
-     SWAP_MLOCK, indicating that the page is unevictable.
-
-     If the mmap semaphore cannot be acquired, we are not sure whether the page
-     is really unevictable or not.  In this case, try_to_unmap_anon() will
-     return SWAP_AGAIN.
-
- (*) try_to_unmap_file()
-
-     Unmapping of a mapped file page works the same as for anonymous mappings,
-     except that the scan visits all VMAs that map the page's index/page offset
-     in the page's mapping's reverse map interval search tree.
-
-     As for anonymous pages, on encountering a VM_LOCKED VMA for a mapped file
-     page, try_to_unmap_file() will attempt to acquire the associated
-     mm_struct's mmap semaphore to mlock the page, returning SWAP_MLOCK if this
-     is successful, and SWAP_AGAIN, if not.
+functions handle anonymous and mapped file and KSM pages, as these types of
+pages have different reverse map lookup mechanisms, with different locking.
+In each case, whether rmap_walk_anon() or rmap_walk_file() or rmap_walk_ksm(),
+it will call try_to_unmap_one() for every VMA which might contain the page.
+
+When trying to reclaim, if try_to_unmap_one() finds the page in a VM_LOCKED
+VMA, it will then mlock the page via mlock_vma_page() instead of unmapping it,
+and return SWAP_MLOCK to indicate that the page is unevictable: and the scan
+stops there.
+
+mlock_vma_page() is called while holding the page table's lock (in addition
+to the page lock, and the rmap lock): to serialize against concurrent mlock or
+munlock or munmap system calls, mm teardown (munlock_vma_pages_all), reclaim,
+holepunching, and truncation of file pages and their anonymous COWed pages.
 
 
 try_to_munlock() REVERSE MAP SCAN
@@ -577,22 +560,15 @@ all PTEs from the page.  For this purpos
 introduced a variant of try_to_unmap() called try_to_munlock().
 
 try_to_munlock() calls the same functions as try_to_unmap() for anonymous and
-mapped file pages with an additional argument specifying unlock versus unmap
+mapped file and KSM pages with a flag argument specifying unlock versus unmap
 processing.  Again, these functions walk the respective reverse maps looking
 for VM_LOCKED VMAs.  When such a VMA is found, as in the try_to_unmap() case,
-the functions attempt to acquire the associated mmap semaphore, mlock the page
-via mlock_vma_page() and return SWAP_MLOCK.  This effectively undoes the
-pre-clearing of the page's PG_mlocked done by munlock_vma_page.
-
-If try_to_unmap() is unable to acquire a VM_LOCKED VMA's associated mmap
-semaphore, it will return SWAP_AGAIN.  This will allow shrink_page_list() to
-recycle the page on the inactive list and hope that it has better luck with the
-page next time.
+the functions mlock the page via mlock_vma_page() and return SWAP_MLOCK.  This
+undoes the pre-clearing of the page's PG_mlocked done by munlock_vma_page.
 
 Note that try_to_munlock()'s reverse map walk must visit every VMA in a page's
 reverse map to determine that a page is NOT mapped into any VM_LOCKED VMA.
-However, the scan can terminate when it encounters a VM_LOCKED VMA and can
-successfully acquire the VMA's mmap semaphore for read and mlock the page.
+However, the scan can terminate when it encounters a VM_LOCKED VMA.
 Although try_to_munlock() might be called a great many times when munlocking a
 large region or tearing down a large address space that has been mlocked via
 mlockall(), overall this is a fairly rare event.
@@ -620,11 +596,6 @@ Some examples of these unevictable pages
  (3) mlocked pages that could not be isolated from the LRU and moved to the
      unevictable list in mlock_vma_page().
 
- (4) Pages mapped into multiple VM_LOCKED VMAs, but try_to_munlock() couldn't
-     acquire the VMA's mmap semaphore to test the flags and set PageMlocked.
-     munlock_vma_page() was forced to let the page back on to the normal LRU
-     list for vmscan to handle.
-
 shrink_inactive_list() also diverts any unevictable pages that it finds on the
 inactive lists to the appropriate zone's unevictable list.
 
--- migrat.orig/mm/rmap.c	2015-09-12 18:30:20.857039763 -0700
+++ migrat/mm/rmap.c	2015-10-18 17:53:07.099317502 -0700
@@ -1304,6 +1304,10 @@ static int try_to_unmap_one(struct page
 	int ret = SWAP_AGAIN;
 	enum ttu_flags flags = (enum ttu_flags)arg;
 
+	/* munlock has nothing to gain from examining un-locked vmas */
+	if ((flags & TTU_MUNLOCK) && !(vma->vm_flags & VM_LOCKED))
+		goto out;
+
 	pte = page_check_address(page, mm, address, &ptl, 0);
 	if (!pte)
 		goto out;
@@ -1314,9 +1318,12 @@ static int try_to_unmap_one(struct page
 	 * skipped over this mm) then we should reactivate it.
 	 */
 	if (!(flags & TTU_IGNORE_MLOCK)) {
-		if (vma->vm_flags & VM_LOCKED)
-			goto out_mlock;
-
+		if (vma->vm_flags & VM_LOCKED) {
+			/* Holding pte lock, we do *not* need mmap_sem here */
+			mlock_vma_page(page);
+			ret = SWAP_MLOCK;
+			goto out_unmap;
+		}
 		if (flags & TTU_MUNLOCK)
 			goto out_unmap;
 	}
@@ -1419,31 +1426,10 @@ static int try_to_unmap_one(struct page
 
 out_unmap:
 	pte_unmap_unlock(pte, ptl);
-	if (ret != SWAP_FAIL && !(flags & TTU_MUNLOCK))
+	if (ret != SWAP_FAIL && ret != SWAP_MLOCK && !(flags & TTU_MUNLOCK))
 		mmu_notifier_invalidate_page(mm, address);
 out:
 	return ret;
-
-out_mlock:
-	pte_unmap_unlock(pte, ptl);
-
-
-	/*
-	 * We need mmap_sem locking, Otherwise VM_LOCKED check makes
-	 * unstable result and race. Plus, We can't wait here because
-	 * we now hold anon_vma->rwsem or mapping->i_mmap_rwsem.
-	 * if trylock failed, the page remain in evictable lru and later
-	 * vmscan could retry to move the page to unevictable lru if the
-	 * page is actually mlocked.
-	 */
-	if (down_read_trylock(&vma->vm_mm->mmap_sem)) {
-		if (vma->vm_flags & VM_LOCKED) {
-			mlock_vma_page(page);
-			ret = SWAP_MLOCK;
-		}
-		up_read(&vma->vm_mm->mmap_sem);
-	}
-	return ret;
 }
 
 bool is_vma_temporary_stack(struct vm_area_struct *vma)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
