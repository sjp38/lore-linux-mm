Date: Sun, 23 Nov 2008 22:03:50 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 6/8] mm: remove try_to_munlock from vmscan
In-Reply-To: <Pine.LNX.4.64.0811232151400.3748@blonde.site>
Message-ID: <Pine.LNX.4.64.0811232202040.4142@blonde.site>
References: <Pine.LNX.4.64.0811232151400.3748@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

An unfortunate feature of the Unevictable LRU work was that reclaiming an
anonymous page involved an extra scan through the anon_vma: to check that
the page is evictable before allocating swap, because the swap could not
be freed reliably soon afterwards.

Now try_to_free_swap() has replaced remove_exclusive_swap_page(), that's
not an issue any more: remove try_to_munlock() call from shrink_page_list(),
leaving it to try_to_munmap() to discover if the page is one to be culled
to the unevictable list - in which case then try_to_free_swap().

Update unevictable-lru.txt to remove comments on the try_to_munlock()
in shrink_page_list(), and shorten some lines over 80 columns.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---
I've not tested this against whatever test showed the need for that
try_to_munlock() in shrink_page_list() in the first place.  Rik or Lee,
please, would you have the time to run that test on the next -mm that has
this patch in, to check that I've not messed things up?  Alternatively,
please point me to such a test - but I think you've been targeting
larger machines than I have access to - thanks.

 Documentation/vm/unevictable-lru.txt |   63 +++++++------------------
 mm/vmscan.c                          |   11 ----
 2 files changed, 20 insertions(+), 54 deletions(-)

--- swapfree5/Documentation/vm/unevictable-lru.txt	2008-10-24 09:27:37.000000000 +0100
+++ swapfree6/Documentation/vm/unevictable-lru.txt	2008-11-21 18:51:01.000000000 +0000
@@ -137,13 +137,6 @@ shrink_page_list() where they will be de
 map in try_to_unmap().  If try_to_unmap() returns SWAP_MLOCK, shrink_page_list()
 will cull the page at that point.
 
-Note that for anonymous pages, shrink_page_list() attempts to add the page to
-the swap cache before it tries to unmap the page.  To avoid this unnecessary
-consumption of swap space, shrink_page_list() calls try_to_munlock() to check
-whether any VM_LOCKED vmas map the page without attempting to unmap the page.
-If try_to_munlock() returns SWAP_MLOCK, shrink_page_list() will cull the page
-without consuming swap space.  try_to_munlock() will be described below.
-
 To "cull" an unevictable page, vmscan simply puts the page back on the lru
 list using putback_lru_page()--the inverse operation to isolate_lru_page()--
 after dropping the page lock.  Because the condition which makes the page
@@ -190,8 +183,8 @@ several places:
    in the VM_LOCKED flag being set for the vma.
 3) in the fault path, if mlocked pages are "culled" in the fault path,
    and when a VM_LOCKED stack segment is expanded.
-4) as mentioned above, in vmscan:shrink_page_list() with attempting to
-   reclaim a page in a VM_LOCKED vma--via try_to_unmap() or try_to_munlock().
+4) as mentioned above, in vmscan:shrink_page_list() when attempting to
+   reclaim a page in a VM_LOCKED vma via try_to_unmap().
 
 Mlocked pages become unlocked and rescued from the unevictable list when:
 
@@ -260,9 +253,9 @@ mlock_fixup() filters several classes of
 
 2) vmas mapping hugetlbfs page are already effectively pinned into memory.
    We don't need nor want to mlock() these pages.  However, to preserve the
-   prior behavior of mlock()--before the unevictable/mlock changes--mlock_fixup()
-   will call make_pages_present() in the hugetlbfs vma range to allocate the
-   huge pages and populate the ptes.
+   prior behavior of mlock()--before the unevictable/mlock changes--
+   mlock_fixup() will call make_pages_present() in the hugetlbfs vma range
+   to allocate the huge pages and populate the ptes.
 
 3) vmas with VM_DONTEXPAND|VM_RESERVED are generally user space mappings of
    kernel pages, such as the vdso page, relay channel pages, etc.  These pages
@@ -322,7 +315,7 @@ __mlock_vma_pages_range()--the same func
 passing a flag to indicate that munlock() is being performed.
 
 Because the vma access protections could have been changed to PROT_NONE after
-faulting in and mlocking some pages, get_user_pages() was unreliable for visiting
+faulting in and mlocking pages, get_user_pages() was unreliable for visiting
 these pages for munlocking.  Because we don't want to leave pages mlocked(),
 get_user_pages() was enhanced to accept a flag to ignore the permissions when
 fetching the pages--all of which should be resident as a result of previous
@@ -416,8 +409,8 @@ Mlocked Pages:  munmap()/exit()/exec() S
 When unmapping an mlocked region of memory, whether by an explicit call to
 munmap() or via an internal unmap from exit() or exec() processing, we must
 munlock the pages if we're removing the last VM_LOCKED vma that maps the pages.
-Before the unevictable/mlock changes, mlocking did not mark the pages in any way,
-so unmapping them required no processing.
+Before the unevictable/mlock changes, mlocking did not mark the pages in any
+way, so unmapping them required no processing.
 
 To munlock a range of memory under the unevictable/mlock infrastructure, the
 munmap() hander and task address space tear down function call
@@ -517,12 +510,10 @@ couldn't be mlocked.
 Mlocked pages:  try_to_munlock() Reverse Map Scan
 
 TODO/FIXME:  a better name might be page_mlocked()--analogous to the
-page_referenced() reverse map walker--especially if we continue to call this
-from shrink_page_list().  See related TODO/FIXME below.
+page_referenced() reverse map walker.
 
-When munlock_vma_page()--see "Mlocked Pages:  munlock()/munlockall() System
-Call Handling" above--tries to munlock a page, or when shrink_page_list()
-encounters an anonymous page that is not yet in the swap cache, they need to
+When munlock_vma_page()--see "Mlocked Pages:  munlock()/munlockall()
+System Call Handling" above--tries to munlock a page, it needs to
 determine whether or not the page is mapped by any VM_LOCKED vma, without
 actually attempting to unmap all ptes from the page.  For this purpose, the
 unevictable/mlock infrastructure introduced a variant of try_to_unmap() called
@@ -535,10 +526,7 @@ for VM_LOCKED vmas.  When such a vma is 
 pages mapped in linear VMAs, as in the try_to_unmap() case, the functions
 attempt to acquire the associated mmap semphore, mlock the page via
 mlock_vma_page() and return SWAP_MLOCK.  This effectively undoes the
-pre-clearing of the page's PG_mlocked done by munlock_vma_page() and informs
-shrink_page_list() that the anonymous page should be culled rather than added
-to the swap cache in preparation for a try_to_unmap() that will almost
-certainly fail.
+pre-clearing of the page's PG_mlocked done by munlock_vma_page.
 
 If try_to_unmap() is unable to acquire a VM_LOCKED vma's associated mmap
 semaphore, it will return SWAP_AGAIN.  This will allow shrink_page_list()
@@ -557,10 +545,7 @@ However, the scan can terminate when it 
 successfully acquire the vma's mmap semphore for read and mlock the page.
 Although try_to_munlock() can be called many [very many!] times when
 munlock()ing a large region or tearing down a large address space that has been
-mlocked via mlockall(), overall this is a fairly rare event.  In addition,
-although shrink_page_list() calls try_to_munlock() for every anonymous page that
-it handles that is not yet in the swap cache, on average anonymous pages will
-have very short reverse map lists.
+mlocked via mlockall(), overall this is a fairly rare event.
 
 Mlocked Page:  Page Reclaim in shrink_*_list()
 
@@ -588,8 +573,8 @@ Some examples of these unevictable pages
    munlock_vma_page() was forced to let the page back on to the normal
    LRU list for vmscan to handle.
 
-shrink_inactive_list() also culls any unevictable pages that it finds
-on the inactive lists, again diverting them to the appropriate zone's unevictable
+shrink_inactive_list() also culls any unevictable pages that it finds on
+the inactive lists, again diverting them to the appropriate zone's unevictable
 lru list.  shrink_inactive_list() should only see SHM_LOCKed pages that became
 SHM_LOCKed after shrink_active_list() had moved them to the inactive list, or
 pages mapped into VM_LOCKED vmas that munlock_vma_page() couldn't isolate from
@@ -597,19 +582,7 @@ the lru to recheck via try_to_munlock().
 the latter, but will pass on to shrink_page_list().
 
 shrink_page_list() again culls obviously unevictable pages that it could
-encounter for similar reason to shrink_inactive_list().  As already discussed,
-shrink_page_list() proactively looks for anonymous pages that should have
-PG_mlocked set but don't--these would not be detected by page_evictable()--to
-avoid adding them to the swap cache unnecessarily.  File pages mapped into
+encounter for similar reason to shrink_inactive_list().  Pages mapped into
 VM_LOCKED vmas but without PG_mlocked set will make it all the way to
-try_to_unmap().  shrink_page_list() will divert them to the unevictable list when
-try_to_unmap() returns SWAP_MLOCK, as discussed above.
-
-TODO/FIXME:  If we can enhance the swap cache to reliably remove entries
-with page_count(page) > 2, as long as all ptes are mapped to the page and
-not the swap entry, we can probably remove the call to try_to_munlock() in
-shrink_page_list() and just remove the page from the swap cache when
-try_to_unmap() returns SWAP_MLOCK.   Currently, remove_exclusive_swap_page()
-doesn't seem to allow that.
-
-
+try_to_unmap().  shrink_page_list() will divert them to the unevictable list
+when try_to_unmap() returns SWAP_MLOCK, as discussed above.
--- swapfree5/mm/vmscan.c	2008-11-21 18:50:50.000000000 +0000
+++ swapfree6/mm/vmscan.c	2008-11-21 18:51:01.000000000 +0000
@@ -673,15 +673,6 @@ static unsigned long shrink_page_list(st
 		if (PageAnon(page) && !PageSwapCache(page)) {
 			if (!(sc->gfp_mask & __GFP_IO))
 				goto keep_locked;
-			switch (try_to_munlock(page)) {
-			case SWAP_FAIL:		/* shouldn't happen */
-			case SWAP_AGAIN:
-				goto keep_locked;
-			case SWAP_MLOCK:
-				goto cull_mlocked;
-			case SWAP_SUCCESS:
-				; /* fall thru'; add to swap cache */
-			}
 			if (!add_to_swap(page, GFP_ATOMIC))
 				goto activate_locked;
 			may_enter_fs = 1;
@@ -798,6 +789,8 @@ free_it:
 		continue;
 
 cull_mlocked:
+		if (PageSwapCache(page))
+			try_to_free_swap(page);
 		unlock_page(page);
 		putback_lru_page(page);
 		continue;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
