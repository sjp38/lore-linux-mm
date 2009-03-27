Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 90C696B0047
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 10:55:08 -0400 (EDT)
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate5.de.ibm.com (8.14.3/8.13.8) with ESMTP id n2RFAg3d685492
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 15:10:42 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2RFADwG4157622
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 16:10:18 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2RFADlq015295
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 16:10:13 +0100
Message-Id: <20090327151012.713478499@de.ibm.com>
References: <20090327150905.819861420@de.ibm.com>
Date: Fri, 27 Mar 2009 16:09:10 +0100
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [patch 5/6] Guest page hinting: minor fault optimization.
Content-Disposition: inline; filename=005-hva-nohv.diff
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.osdl.org
Cc: frankeh@watson.ibm.com, akpm@osdl.org, nickpiggin@yahoo.com.au, hugh@veritas.com, riel@redhat.com, Martin Schwidefsky <schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

From: Martin Schwidefsky <schwidefsky@de.ibm.com>
From: Hubertus Franke <frankeh@watson.ibm.com>
From: Himanshu Raj

On of the challenges of the guest page hinting scheme is the cost for
the state transitions. If the cost gets too high the whole concept of
page state information is in question. Therefore it is important to
avoid the state transitions when possible. One place where the state
transitions can be avoided are minor faults. Why change the page state
to stable in find_get_page and back in page_add_anon_rmap/
page_add_file_rmap if the discarded pages can be handled by the discard
fault handler? If the page is in page/swap cache just map it even if it
is already discarded. The first access to the page will cause a discard
fault which needs to be able to deal with this kind of situation anyway
because of other races in the memory management.

The special find_get_page_nodiscard variant introduced for volatile
swap cache is used which does not change the page state. The calls to
find_get_page in filemap_nopage and lookup_swap_cache are replaced with
find_get_page_nodiscard. By the use of this function a new race is
created. If a minor fault races with the discard of a page the page may
not get mapped to the page table because the discard handler removed
the page from the cache which removes the page->mapping that is needed
to find the page table entry. A check for the discarded bit is added to
do_swap_page and do_no_page. The page table lock for the pte takes care
of the synchronization.

That removes the state transitions on the minor fault path. A page that
has been mapped will eventually be unmapped again. On the unmap path
each page that has been removed from the page table is freed with a
call to page_cache_release. In general that causes an unnecessary page
state transition from volatile to volatile. To get rid of these state
transitions as well a special variants of page_cache_release is added
that does not attempt to make the page volatile.
page_cache_release_nocheck is then used in free_page_and_swap_cache
and release_pages. This makes the unmap of ptes state transitions free.

Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---

 include/linux/pagemap.h |    4 ++++
 include/linux/swap.h    |    2 +-
 mm/filemap.c            |   27 ++++++++++++++++++++++++---
 mm/fremap.c             |    1 +
 mm/memory.c             |    4 ++--
 mm/rmap.c               |    4 +---
 mm/shmem.c              |    7 +++++++
 mm/swap_state.c         |    4 ++--
 8 files changed, 42 insertions(+), 11 deletions(-)

Index: linux-2.6/include/linux/pagemap.h
===================================================================
--- linux-2.6.orig/include/linux/pagemap.h
+++ linux-2.6/include/linux/pagemap.h
@@ -93,11 +93,15 @@ static inline void mapping_set_gfp_mask(
 #ifdef CONFIG_PAGE_STATES
 extern struct page * find_get_page_nodiscard(struct address_space *mapping,
 					     unsigned long index);
+extern struct page * find_lock_page_nodiscard(struct address_space *mapping,
+					      unsigned long index);
 #define page_cache_release(page)	put_page_check(page)
 #else
 #define find_get_page_nodiscard(mapping, index) find_get_page(mapping, index)
+#define find_lock_page_nodiscard(mapping, index) find_lock_page(mapping, index)
 #define page_cache_release(page)	put_page(page)
 #endif
+#define page_cache_release_nocheck(page)	put_page(page)
 void release_pages(struct page **pages, int nr, int cold);
 
 /*
Index: linux-2.6/include/linux/swap.h
===================================================================
--- linux-2.6.orig/include/linux/swap.h
+++ linux-2.6/include/linux/swap.h
@@ -362,7 +362,7 @@ static inline void mem_cgroup_uncharge_s
 /* only sparc can not include linux/pagemap.h in this file
  * so leave page_cache_release and release_pages undeclared... */
 #define free_page_and_swap_cache(page) \
-	page_cache_release(page)
+	page_cache_release_nocheck(page)
 #define free_pages_and_swap_cache(pages, nr) \
 	release_pages((pages), (nr), 0);
 
Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c
+++ linux-2.6/mm/filemap.c
@@ -592,6 +592,27 @@ repeat:
 
 EXPORT_SYMBOL(find_get_page_nodiscard);
 
+struct page *find_lock_page_nodiscard(struct address_space *mapping,
+				      unsigned long offset)
+{
+	struct page *page;
+
+repeat:
+	page = find_get_page_nodiscard(mapping, offset);
+	if (page) {
+		lock_page(page);
+		/* Has the page been truncated? */
+		if (unlikely(page->mapping != mapping)) {
+			unlock_page(page);
+			page_cache_release(page);
+			goto repeat;
+		}
+		VM_BUG_ON(page->index != offset);
+	}
+	return page;
+}
+EXPORT_SYMBOL(find_lock_page_nodiscard);
+
 #endif
 
 /*
@@ -1586,7 +1607,7 @@ int filemap_fault(struct vm_area_struct 
 	 * Do we have something in the page cache already?
 	 */
 retry_find:
-	page = find_lock_page(mapping, vmf->pgoff);
+	page = find_lock_page_nodiscard(mapping, vmf->pgoff);
 	/*
 	 * For sequential accesses, we use the generic readahead logic.
 	 */
@@ -1594,7 +1615,7 @@ retry_find:
 		if (!page) {
 			page_cache_sync_readahead(mapping, ra, file,
 							   vmf->pgoff, 1);
-			page = find_lock_page(mapping, vmf->pgoff);
+			page = find_lock_page_nodiscard(mapping, vmf->pgoff);
 			if (!page)
 				goto no_cached_page;
 		}
@@ -1633,7 +1654,7 @@ retry_find:
 				start = vmf->pgoff - ra_pages / 2;
 			do_page_cache_readahead(mapping, file, start, ra_pages);
 		}
-		page = find_lock_page(mapping, vmf->pgoff);
+		page = find_lock_page_nodiscard(mapping, vmf->pgoff);
 		if (!page)
 			goto no_cached_page;
 	}
Index: linux-2.6/mm/fremap.c
===================================================================
--- linux-2.6.orig/mm/fremap.c
+++ linux-2.6/mm/fremap.c
@@ -16,6 +16,7 @@
 #include <linux/module.h>
 #include <linux/syscalls.h>
 #include <linux/mmu_notifier.h>
+#include <linux/page-states.h>
 
 #include <asm/mmu_context.h>
 #include <asm/cacheflush.h>
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -2513,7 +2513,7 @@ static int do_swap_page(struct mm_struct
 	 * Back out if somebody else already faulted in this pte.
 	 */
 	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
-	if (unlikely(!pte_same(*page_table, orig_pte)))
+	if (unlikely(!pte_same(*page_table, orig_pte) || PageDiscarded(page)))
 		goto out_nomap;
 
 	if (unlikely(!PageUptodate(page))) {
@@ -2753,7 +2753,7 @@ retry:
 	 * handle that later.
 	 */
 	/* Only go through if we didn't race with anybody else... */
-	if (likely(pte_same(*page_table, orig_pte))) {
+	if (likely(pte_same(*page_table, orig_pte) && !PageDiscarded(page))) {
 		flush_icache_page(vma, page);
 		entry = mk_pte(page, vma->vm_page_prot);
 		if (flags & FAULT_FLAG_WRITE)
Index: linux-2.6/mm/rmap.c
===================================================================
--- linux-2.6.orig/mm/rmap.c
+++ linux-2.6/mm/rmap.c
@@ -703,7 +703,6 @@ void page_add_file_rmap(struct page *pag
 {
 	if (atomic_inc_and_test(&page->_mapcount))
 		__inc_zone_page_state(page, NR_FILE_MAPPED);
-	page_make_volatile(page, 1);
 }
 
 #ifdef CONFIG_DEBUG_VM
@@ -763,7 +762,6 @@ void page_remove_rmap(struct page *page)
 		 * faster for those pages still in swapcache.
 		 */
 	}
-	page_make_volatile(page, 1);
 }
 
 /*
@@ -862,7 +860,7 @@ static int try_to_unmap_one(struct page 
 	}
 
 	page_remove_rmap(page);
-	page_cache_release(page);
+	page_cache_release_nocheck(page);
 
 out_unmap:
 	pte_unmap_unlock(pte, ptl);
Index: linux-2.6/mm/shmem.c
===================================================================
--- linux-2.6.orig/mm/shmem.c
+++ linux-2.6/mm/shmem.c
@@ -59,6 +59,7 @@ static struct vfsmount *shm_mnt;
 #include <linux/highmem.h>
 #include <linux/seq_file.h>
 #include <linux/magic.h>
+#include <linux/page-states.h>
 
 #include <asm/uaccess.h>
 #include <asm/div64.h>
@@ -1245,6 +1246,12 @@ repeat:
 	if (swap.val) {
 		/* Look it up and read it in.. */
 		swappage = lookup_swap_cache(swap);
+		if (swappage && unlikely(!page_make_stable(swappage))) {
+			shmem_swp_unmap(entry);
+			spin_unlock(&info->lock);
+			page_discard(swappage);
+			goto repeat;
+		}
 		if (!swappage) {
 			shmem_swp_unmap(entry);
 			/* here we actually do the io */
Index: linux-2.6/mm/swap_state.c
===================================================================
--- linux-2.6.orig/mm/swap_state.c
+++ linux-2.6/mm/swap_state.c
@@ -241,7 +241,7 @@ static inline void free_swap_cache(struc
 void free_page_and_swap_cache(struct page *page)
 {
 	free_swap_cache(page);
-	page_cache_release(page);
+	page_cache_release_nocheck(page);
 }
 
 /*
@@ -275,7 +275,7 @@ struct page * lookup_swap_cache(swp_entr
 {
 	struct page *page;
 
-	page = find_get_page(&swapper_space, entry.val);
+	page = find_get_page_nodiscard(&swapper_space, entry.val);
 
 	if (page)
 		INC_CACHE_INFO(find_success);

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
