Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.8/8.13.8) with ESMTP id l4BDxjqF076406
	for <linux-mm@kvack.org>; Fri, 11 May 2007 13:59:45 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4BDxjhA1540106
	for <linux-mm@kvack.org>; Fri, 11 May 2007 15:59:45 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4BDx0uG030274
	for <linux-mm@kvack.org>; Fri, 11 May 2007 15:59:00 +0200
Message-Id: <20070511135926.510623591@de.ibm.com>
References: <20070511135827.393181482@de.ibm.com>
Date: Fri, 11 May 2007 15:58:32 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [patch 5/6] Guest page hinting: minor fault optimization.
Content-Disposition: inline; filename=005-hva-nohv.diff
Sender: owner-linux-mm@kvack.org
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
From: Hubertus Franke <frankeh@watson.ibm.com>
From: Himanshu Raj <rhim@cc.gatech.edu>
Return-Path: <owner-linux-mm@kvack.org>
To: virtualization@lists.osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Zachary Amsden <zach@vmware.com>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Hubertus Franke <frankeh@watson.ibm.com>, Rik van Riel <riel@redhat.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

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

 include/linux/pagemap.h |    1 +
 include/linux/swap.h    |    2 +-
 mm/filemap.c            |    4 ++--
 mm/fremap.c             |    2 ++
 mm/memory.c             |    4 ++--
 mm/rmap.c               |    4 +---
 mm/shmem.c              |    7 +++++++
 mm/swap_state.c         |    4 ++--
 8 files changed, 18 insertions(+), 10 deletions(-)

diff -urpN linux-2.6/include/linux/pagemap.h linux-2.6-patched/include/linux/pagemap.h
--- linux-2.6/include/linux/pagemap.h	2007-05-11 15:52:16.000000000 +0200
+++ linux-2.6-patched/include/linux/pagemap.h	2007-05-11 15:52:17.000000000 +0200
@@ -68,6 +68,7 @@ extern struct page * find_get_page_nodis
 #define find_get_page_nodiscard(mapping, index) find_get_page(mapping, index)
 #define page_cache_release(page)	put_page(page)
 #endif
+#define page_cache_release_nocheck(page)	put_page(page)
 void release_pages(struct page **pages, int nr, int cold);
 
 #ifdef CONFIG_NUMA
diff -urpN linux-2.6/include/linux/swap.h linux-2.6-patched/include/linux/swap.h
--- linux-2.6/include/linux/swap.h	2007-05-11 15:52:16.000000000 +0200
+++ linux-2.6-patched/include/linux/swap.h	2007-05-11 15:52:17.000000000 +0200
@@ -290,7 +290,7 @@ static inline void disable_swap_token(vo
 /* only sparc can not include linux/pagemap.h in this file
  * so leave page_cache_release and release_pages undeclared... */
 #define free_page_and_swap_cache(page) \
-	page_cache_release(page)
+	page_cache_release_nocheck(page)
 #define free_pages_and_swap_cache(pages, nr) \
 	release_pages((pages), (nr), 0);
 
diff -urpN linux-2.6/mm/filemap.c linux-2.6-patched/mm/filemap.c
--- linux-2.6/mm/filemap.c	2007-05-11 15:52:16.000000000 +0200
+++ linux-2.6-patched/mm/filemap.c	2007-05-11 15:52:17.000000000 +0200
@@ -1466,7 +1466,7 @@ retry_all:
 	 * Do we have something in the page cache already?
 	 */
 retry_find:
-	page = find_get_page(mapping, pgoff);
+	page = find_get_page_nodiscard(mapping, pgoff);
 	if (!page) {
 		unsigned long ra_pages;
 
@@ -1500,7 +1500,7 @@ retry_find:
 				start = pgoff - ra_pages / 2;
 			do_page_cache_readahead(mapping, file, start, ra_pages);
 		}
-		page = find_get_page(mapping, pgoff);
+		page = find_get_page_nodiscard(mapping, pgoff);
 		if (!page)
 			goto no_cached_page;
 	}
diff -urpN linux-2.6/mm/fremap.c linux-2.6-patched/mm/fremap.c
--- linux-2.6/mm/fremap.c	2007-05-11 15:52:17.000000000 +0200
+++ linux-2.6-patched/mm/fremap.c	2007-05-11 15:52:17.000000000 +0200
@@ -15,6 +15,7 @@
 #include <linux/rmap.h>
 #include <linux/module.h>
 #include <linux/syscalls.h>
+#include <linux/page-states.h>
 
 #include <asm/mmu_context.h>
 #include <asm/cacheflush.h>
@@ -83,6 +84,7 @@ int install_page(struct mm_struct *mm, s
 	page_check_writable(page, pte_val, 2);
 	set_pte_at(mm, addr, pte, pte_val);
 	page_add_file_rmap(page);
+	page_make_volatile(page, 1);
 	update_mmu_cache(vma, addr, pte_val);
 	lazy_mmu_prot_update(pte_val);
 	err = 0;
diff -urpN linux-2.6/mm/memory.c linux-2.6-patched/mm/memory.c
--- linux-2.6/mm/memory.c	2007-05-11 15:52:17.000000000 +0200
+++ linux-2.6-patched/mm/memory.c	2007-05-11 15:52:17.000000000 +0200
@@ -2229,7 +2229,7 @@ static int do_swap_page(struct mm_struct
 	 * Back out if somebody else already faulted in this pte.
 	 */
 	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
-	if (unlikely(!pte_same(*page_table, orig_pte)))
+	if (unlikely(!pte_same(*page_table, orig_pte) || PageDiscarded(page)))
 		goto out_nomap;
 
 	if (unlikely(!PageUptodate(page))) {
@@ -2451,7 +2451,7 @@ retry:
 	 * handle that later.
 	 */
 	/* Only go through if we didn't race with anybody else... */
-	if (pte_none(*page_table)) {
+	if (pte_none(*page_table) && likely(!PageDiscarded(new_page))) {
 		flush_icache_page(vma, new_page);
 		entry = mk_pte(new_page, vma->vm_page_prot);
 		if (write_access)
diff -urpN linux-2.6/mm/rmap.c linux-2.6-patched/mm/rmap.c
--- linux-2.6/mm/rmap.c	2007-05-11 15:52:17.000000000 +0200
+++ linux-2.6-patched/mm/rmap.c	2007-05-11 15:52:17.000000000 +0200
@@ -557,7 +557,6 @@ void page_add_anon_rmap(struct page *pag
 	if (atomic_inc_and_test(&page->_mapcount))
 		__page_set_anon_rmap(page, vma, address);
 	/* else checking page index and mapping is racy */
-	page_make_volatile(page, 1);
 }
 
 /*
@@ -586,7 +585,6 @@ void page_add_file_rmap(struct page *pag
 {
 	if (atomic_inc_and_test(&page->_mapcount))
 		__inc_zone_page_state(page, NR_FILE_MAPPED);
-	page_make_volatile(page, 1);
 }
 
 /**
@@ -727,7 +725,7 @@ static int try_to_unmap_one(struct page 
 	}
 
 	page_remove_rmap(page, vma);
-	page_cache_release(page);
+	page_cache_release_nocheck(page);
 
 out_unmap:
 	pte_unmap_unlock(pte, ptl);
diff -urpN linux-2.6/mm/shmem.c linux-2.6-patched/mm/shmem.c
--- linux-2.6/mm/shmem.c	2007-05-08 09:31:18.000000000 +0200
+++ linux-2.6-patched/mm/shmem.c	2007-05-11 15:52:17.000000000 +0200
@@ -49,6 +49,7 @@
 #include <linux/migrate.h>
 #include <linux/highmem.h>
 #include <linux/backing-dev.h>
+#include <linux/page-states.h>
 
 #include <asm/uaccess.h>
 #include <asm/div64.h>
@@ -1124,6 +1125,12 @@ repeat:
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
diff -urpN linux-2.6/mm/swap_state.c linux-2.6-patched/mm/swap_state.c
--- linux-2.6/mm/swap_state.c	2007-05-11 15:52:16.000000000 +0200
+++ linux-2.6-patched/mm/swap_state.c	2007-05-11 15:52:17.000000000 +0200
@@ -288,7 +288,7 @@ static inline void free_swap_cache(struc
 void free_page_and_swap_cache(struct page *page)
 {
 	free_swap_cache(page);
-	page_cache_release(page);
+	page_cache_release_nocheck(page);
 }
 
 /*
@@ -322,7 +322,7 @@ struct page * lookup_swap_cache(swp_entr
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
