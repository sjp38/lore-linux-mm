Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate4.de.ibm.com (8.13.8/8.13.8) with ESMTP id l5SGfDP5027744
	for <linux-mm@kvack.org>; Thu, 28 Jun 2007 16:41:13 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5SGfDVI1007644
	for <linux-mm@kvack.org>; Thu, 28 Jun 2007 18:41:13 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5SGfCBQ016599
	for <linux-mm@kvack.org>; Thu, 28 Jun 2007 18:41:13 +0200
Message-Id: <20070628164313.401159236@de.ibm.com>
References: <20070628164049.118610355@de.ibm.com>
Date: Thu, 28 Jun 2007 18:40:54 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [patch 5/6] Guest page hinting: minor fault optimization.
Content-Disposition: inline; filename=005-hva-nohv.diff
Sender: owner-linux-mm@kvack.org
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
From: Hubertus Franke <frankeh@watson.ibm.com>
From: Himanshu Raj <rhim@cc.gatech.edu>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm-devel@lists.sourceforge.net, linux-mm@kvack.org
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
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
--- linux-2.6/include/linux/pagemap.h	2007-06-28 18:19:45.000000000 +0200
+++ linux-2.6-patched/include/linux/pagemap.h	2007-06-28 18:19:48.000000000 +0200
@@ -68,6 +68,7 @@ extern struct page * find_get_page_nodis
 #define find_get_page_nodiscard(mapping, index) find_get_page(mapping, index)
 #define page_cache_release(page)	put_page(page)
 #endif
+#define page_cache_release_nocheck(page)	put_page(page)
 void release_pages(struct page **pages, int nr, int cold);
 
 #ifdef CONFIG_NUMA
diff -urpN linux-2.6/include/linux/swap.h linux-2.6-patched/include/linux/swap.h
--- linux-2.6/include/linux/swap.h	2007-06-28 18:19:45.000000000 +0200
+++ linux-2.6-patched/include/linux/swap.h	2007-06-28 18:19:48.000000000 +0200
@@ -290,7 +290,7 @@ static inline void disable_swap_token(vo
 /* only sparc can not include linux/pagemap.h in this file
  * so leave page_cache_release and release_pages undeclared... */
 #define free_page_and_swap_cache(page) \
-	page_cache_release(page)
+	page_cache_release_nocheck(page)
 #define free_pages_and_swap_cache(pages, nr) \
 	release_pages((pages), (nr), 0);
 
diff -urpN linux-2.6/mm/filemap.c linux-2.6-patched/mm/filemap.c
--- linux-2.6/mm/filemap.c	2007-06-28 18:19:45.000000000 +0200
+++ linux-2.6-patched/mm/filemap.c	2007-06-28 18:19:48.000000000 +0200
@@ -1467,7 +1467,7 @@ retry_all:
 	 * Do we have something in the page cache already?
 	 */
 retry_find:
-	page = find_get_page(mapping, pgoff);
+	page = find_get_page_nodiscard(mapping, pgoff);
 	if (!page) {
 		unsigned long ra_pages;
 
@@ -1501,7 +1501,7 @@ retry_find:
 				start = pgoff - ra_pages / 2;
 			do_page_cache_readahead(mapping, file, start, ra_pages);
 		}
-		page = find_get_page(mapping, pgoff);
+		page = find_get_page_nodiscard(mapping, pgoff);
 		if (!page)
 			goto no_cached_page;
 	}
diff -urpN linux-2.6/mm/fremap.c linux-2.6-patched/mm/fremap.c
--- linux-2.6/mm/fremap.c	2007-06-28 18:19:48.000000000 +0200
+++ linux-2.6-patched/mm/fremap.c	2007-06-28 18:19:48.000000000 +0200
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
--- linux-2.6/mm/memory.c	2007-06-28 18:19:48.000000000 +0200
+++ linux-2.6-patched/mm/memory.c	2007-06-28 18:19:48.000000000 +0200
@@ -2230,7 +2230,7 @@ static int do_swap_page(struct mm_struct
 	 * Back out if somebody else already faulted in this pte.
 	 */
 	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
-	if (unlikely(!pte_same(*page_table, orig_pte)))
+	if (unlikely(!pte_same(*page_table, orig_pte) || PageDiscarded(page)))
 		goto out_nomap;
 
 	if (unlikely(!PageUptodate(page))) {
@@ -2452,7 +2452,7 @@ retry:
 	 * handle that later.
 	 */
 	/* Only go through if we didn't race with anybody else... */
-	if (pte_none(*page_table)) {
+	if (pte_none(*page_table) && likely(!PageDiscarded(new_page))) {
 		flush_icache_page(vma, new_page);
 		entry = mk_pte(new_page, vma->vm_page_prot);
 		if (write_access)
diff -urpN linux-2.6/mm/rmap.c linux-2.6-patched/mm/rmap.c
--- linux-2.6/mm/rmap.c	2007-06-28 18:19:48.000000000 +0200
+++ linux-2.6-patched/mm/rmap.c	2007-06-28 18:19:48.000000000 +0200
@@ -587,7 +587,6 @@ void page_add_anon_rmap(struct page *pag
 		__page_set_anon_rmap(page, vma, address);
 	else
 		__page_check_anon_rmap(page, vma, address);
-	page_make_volatile(page, 1);
 }
 
 /*
@@ -618,7 +617,6 @@ void page_add_file_rmap(struct page *pag
 {
 	if (atomic_inc_and_test(&page->_mapcount))
 		__inc_zone_page_state(page, NR_FILE_MAPPED);
-	page_make_volatile(page, 1);
 }
 
 #ifdef CONFIG_DEBUG_VM
@@ -779,7 +777,7 @@ static int try_to_unmap_one(struct page 
 	}
 
 	page_remove_rmap(page, vma);
-	page_cache_release(page);
+	page_cache_release_nocheck(page);
 
 out_unmap:
 	pte_unmap_unlock(pte, ptl);
diff -urpN linux-2.6/mm/shmem.c linux-2.6-patched/mm/shmem.c
--- linux-2.6/mm/shmem.c	2007-06-09 12:24:04.000000000 +0200
+++ linux-2.6-patched/mm/shmem.c	2007-06-28 18:19:48.000000000 +0200
@@ -49,6 +49,7 @@
 #include <linux/migrate.h>
 #include <linux/highmem.h>
 #include <linux/backing-dev.h>
+#include <linux/page-states.h>
 
 #include <asm/uaccess.h>
 #include <asm/div64.h>
@@ -1126,6 +1127,12 @@ repeat:
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
--- linux-2.6/mm/swap_state.c	2007-06-28 18:19:45.000000000 +0200
+++ linux-2.6-patched/mm/swap_state.c	2007-06-28 18:19:48.000000000 +0200
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
