Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B13F56B0047
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 10:53:57 -0400 (EDT)
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate7.de.ibm.com (8.14.3/8.13.8) with ESMTP id n2RFAIeQ224358
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 15:10:18 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2RFACFn3735602
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 16:10:12 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2RFACNg015227
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 16:10:12 +0100
Message-Id: <20090327151011.798602788@de.ibm.com>
References: <20090327150905.819861420@de.ibm.com>
Date: Fri, 27 Mar 2009 16:09:07 +0100
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [patch 2/6] Guest page hinting: volatile swap cache.
Content-Disposition: inline; filename=002-hva-swap.diff
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.osdl.org
Cc: frankeh@watson.ibm.com, akpm@osdl.org, nickpiggin@yahoo.com.au, hugh@veritas.com, riel@redhat.com, Martin Schwidefsky <schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

From: Martin Schwidefsky <schwidefsky@de.ibm.com>
From: Hubertus Franke <frankeh@watson.ibm.com>
From: Himanshu Raj

The volatile page state can be used for anonymous pages as well, if
they have been added to the swap cache and the swap write is finished.
The tricky bit is in free_swap_and_cache. The call to find_get_page
dead-locks with the discard handler. If the page has been discarded
find_get_page will try to remove it. To do that it needs the page table
lock of all mappers but one is held by the caller of free_swap_and_cache.
A special variant of find_get_page is needed that does not check the
page state and returns a page reference even if the page is discarded.
The second pitfall is that the page needs to be made stable before the
swap slot gets freed. If the page cannot be made stable because it has
been discarded the swap slot may not be freed because it is still
needed to reload the discarded page from the swap device.

Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---

 include/linux/pagemap.h |    3 ++
 include/linux/swap.h    |    5 ++++
 mm/filemap.c            |   39 ++++++++++++++++++++++++++++++++++++
 mm/memory.c             |   13 +++++++++++-
 mm/page-states.c        |   34 +++++++++++++++++++++++---------
 mm/rmap.c               |   51 ++++++++++++++++++++++++++++++++++++++++++++----
 mm/swap_state.c         |   25 ++++++++++++++++++++++-
 mm/swapfile.c           |   24 +++++++++++++++++++---
 8 files changed, 176 insertions(+), 18 deletions(-)

Index: linux-2.6/include/linux/pagemap.h
===================================================================
--- linux-2.6.orig/include/linux/pagemap.h
+++ linux-2.6/include/linux/pagemap.h
@@ -91,8 +91,11 @@ static inline void mapping_set_gfp_mask(
 
 #define page_cache_get(page)		get_page(page)
 #ifdef CONFIG_PAGE_STATES
+extern struct page * find_get_page_nodiscard(struct address_space *mapping,
+					     unsigned long index);
 #define page_cache_release(page)	put_page_check(page)
 #else
+#define find_get_page_nodiscard(mapping, index) find_get_page(mapping, index)
 #define page_cache_release(page)	put_page(page)
 #endif
 void release_pages(struct page **pages, int nr, int cold);
Index: linux-2.6/include/linux/swap.h
===================================================================
--- linux-2.6.orig/include/linux/swap.h
+++ linux-2.6/include/linux/swap.h
@@ -285,6 +285,7 @@ extern void show_swap_cache_info(void);
 extern int add_to_swap(struct page *);
 extern int add_to_swap_cache(struct page *, swp_entry_t, gfp_t);
 extern void __delete_from_swap_cache(struct page *);
+extern void __delete_from_swap_cache_nocheck(struct page *);
 extern void delete_from_swap_cache(struct page *);
 extern void free_page_and_swap_cache(struct page *);
 extern void free_pages_and_swap_cache(struct page **, int);
@@ -402,6 +403,10 @@ static inline void __delete_from_swap_ca
 {
 }
 
+static inline void __delete_from_swap_cache_nocheck(struct page *page)
+{
+}
+
 static inline void delete_from_swap_cache(struct page *page)
 {
 }
Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c
+++ linux-2.6/mm/filemap.c
@@ -555,6 +555,45 @@ static int __sleep_on_page_lock(void *wo
 	return 0;
 }
 
+#ifdef CONFIG_PAGE_STATES
+
+struct page * find_get_page_nodiscard(struct address_space *mapping,
+				      unsigned long offset)
+{
+	void **pagep;
+	struct page *page;
+
+	rcu_read_lock();
+repeat:
+	page = NULL;
+	pagep = radix_tree_lookup_slot(&mapping->page_tree, offset);
+	if (pagep) {
+		page = radix_tree_deref_slot(pagep);
+		if (unlikely(!page || page == RADIX_TREE_RETRY))
+			goto repeat;
+
+		if (!page_cache_get_speculative(page))
+			goto repeat;
+
+		/*
+		 * Has the page moved?
+		 * This is part of the lockless pagecache protocol. See
+		 * include/linux/pagemap.h for details.
+		 */
+		if (unlikely(page != *pagep)) {
+			page_cache_release(page);
+			goto repeat;
+		}
+	}
+	rcu_read_unlock();
+
+	return page;
+}
+
+EXPORT_SYMBOL(find_get_page_nodiscard);
+
+#endif
+
 /*
  * In order to wait for pages to become available there must be
  * waitqueues associated with pages. By using a hash table of
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -614,7 +614,18 @@ out_discard_pte:
 	 * in the page cache anymore. Do what try_to_unmap_one would do
 	 * if the copy_one_pte had taken place before page_discard.
 	 */
-	if (page->index != linear_page_index(vma, addr))
+	if (PageAnon(page)) {
+		swp_entry_t entry = { .val = page_private(page) };
+		swap_duplicate(entry);
+		if (list_empty(&dst_mm->mmlist)) {
+			spin_lock(&mmlist_lock);
+			if (list_empty(&dst_mm->mmlist))
+				list_add(&dst_mm->mmlist, &init_mm.mmlist);
+			spin_unlock(&mmlist_lock);
+		}
+		pte = swp_entry_to_pte(entry);
+		set_pte_at(dst_mm, addr, dst_pte, pte);
+	} else if (page->index != linear_page_index(vma, addr))
 		/* If nonlinear, store the file page offset in the pte. */
 		set_pte_at(dst_mm, addr, dst_pte, pgoff_to_pte(page->index));
 	else
Index: linux-2.6/mm/page-states.c
===================================================================
--- linux-2.6.orig/mm/page-states.c
+++ linux-2.6/mm/page-states.c
@@ -20,6 +20,7 @@
 #include <linux/buffer_head.h>
 #include <linux/pagevec.h>
 #include <linux/page-states.h>
+#include <linux/swap.h>
 
 #include "internal.h"
 
@@ -35,7 +36,16 @@ static inline int check_bits(struct page
 	 */
 	if (PageDirty(page) || PageReserved(page) || PageWriteback(page) ||
 	    PageLocked(page) || PagePrivate(page) || PageDiscarded(page) ||
-	    !PageUptodate(page) || !PageLRU(page) || PageAnon(page))
+	    !PageUptodate(page) || !PageLRU(page) ||
+	    (PageAnon(page) && !PageSwapCache(page)))
+		return 0;
+
+	/*
+	 * Special case shared memory: page is PageSwapCache but not
+	 * PageAnon. page_unmap_all failes for swapped shared memory
+	 * pages.
+	 */
+	if (PageSwapCache(page) && !PageAnon(page))
 		return 0;
 
 	/*
@@ -169,15 +179,21 @@ static void __page_discard(struct page *
 	}
 	spin_unlock_irq(&zone->lru_lock);
 
-	/* We can't handle swap cache pages (yet). */
-	VM_BUG_ON(PageSwapCache(page));
-
-	/* Remove page from page cache. */
+	/* Remove page from page cache/swap cache. */
 	mapping = page->mapping;
-	spin_lock_irq(&mapping->tree_lock);
-	__remove_from_page_cache_nocheck(page);
-	spin_unlock_irq(&mapping->tree_lock);
-	__put_page(page);
+	if (PageSwapCache(page)) {
+		swp_entry_t entry = { .val = page_private(page) };
+		spin_lock_irq(&swapper_space.tree_lock);
+		__delete_from_swap_cache_nocheck(page);
+		spin_unlock_irq(&swapper_space.tree_lock);
+		swap_free(entry);
+		page_cache_release(page);
+	} else {
+		spin_lock_irq(&mapping->tree_lock);
+		__remove_from_page_cache_nocheck(page);
+		spin_unlock_irq(&mapping->tree_lock);
+		__put_page(page);
+	}
 }
 
 /**
Index: linux-2.6/mm/rmap.c
===================================================================
--- linux-2.6.orig/mm/rmap.c
+++ linux-2.6/mm/rmap.c
@@ -762,6 +762,7 @@ void page_remove_rmap(struct page *page)
 		 * faster for those pages still in swapcache.
 		 */
 	}
+	page_make_volatile(page, 1);
 }
 
 /*
@@ -1253,13 +1254,13 @@ int try_to_munlock(struct page *page)
 #ifdef CONFIG_PAGE_STATES
 
 /**
- * page_unmap_all - removes all mappings of a page
+ * page_unmap_file - removes all mappings of a file page
  *
  * @page: the page which mapping in the vma should be struck down
  *
  * the caller needs to hold page lock
  */
-void page_unmap_all(struct page* page)
+static void page_unmap_file(struct page* page)
 {
 	struct address_space *mapping = page_mapping(page);
 	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
@@ -1268,8 +1269,6 @@ void page_unmap_all(struct page* page)
 	unsigned long address;
 	int rc;
 
-	VM_BUG_ON(!PageLocked(page) || PageReserved(page) || PageAnon(page));
-
 	spin_lock(&mapping->i_mmap_lock);
 	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
 		address = vma_address(page, vma);
@@ -1300,4 +1299,48 @@ out:
 	spin_unlock(&mapping->i_mmap_lock);
 }
 
+/**
+ * page_unmap_anon - removes all mappings of an anonymous page
+ *
+ * @page: the page which mapping in the vma should be struck down
+ *
+ * the caller needs to hold page lock
+ */
+static void page_unmap_anon(struct page* page)
+{
+	struct anon_vma *anon_vma;
+	struct vm_area_struct *vma;
+	unsigned long address;
+	int rc;
+
+	anon_vma = page_lock_anon_vma(page);
+	if (!anon_vma)
+		return;
+	list_for_each_entry(vma, &anon_vma->head, anon_vma_node) {
+		address = vma_address(page, vma);
+		if (address == -EFAULT)
+			continue;
+		rc = try_to_unmap_one(page, vma, address, 0);
+		VM_BUG_ON(rc == SWAP_FAIL);
+	}
+	page_unlock_anon_vma(anon_vma);
+}
+
+/**
+ * page_unmap_all - removes all mappings of a page
+ *
+ * @page: the page which mapping in the vma should be struck down
+ *
+ * the caller needs to hold page lock
+ */
+void page_unmap_all(struct page *page)
+{
+	VM_BUG_ON(!PageLocked(page) || PageReserved(page));
+
+	if (PageAnon(page))
+		page_unmap_anon(page);
+	else
+		page_unmap_file(page);
+}
+
 #endif
Index: linux-2.6/mm/swap_state.c
===================================================================
--- linux-2.6.orig/mm/swap_state.c
+++ linux-2.6/mm/swap_state.c
@@ -18,6 +18,7 @@
 #include <linux/pagevec.h>
 #include <linux/migrate.h>
 #include <linux/page_cgroup.h>
+#include <linux/page-states.h>
 
 #include <asm/pgtable.h>
 
@@ -107,7 +108,7 @@ int add_to_swap_cache(struct page *page,
  * This must be called only on pages that have
  * been verified to be in the swap cache.
  */
-void __delete_from_swap_cache(struct page *page)
+void inline __delete_from_swap_cache_nocheck(struct page *page)
 {
 	swp_entry_t ent = {.val = page_private(page)};
 
@@ -124,6 +125,28 @@ void __delete_from_swap_cache(struct pag
 	mem_cgroup_uncharge_swapcache(page, ent);
 }
 
+void __delete_from_swap_cache(struct page *page)
+{
+	/*
+	 * Check if the discard fault handler already removed
+	 * the page from the page cache. If not set the discard
+	 * bit in the page flags to prevent double page free if
+	 * a discard fault is racing with normal page free.
+	 */
+	if (TestSetPageDiscarded(page))
+		return;
+
+	__delete_from_swap_cache_nocheck(page);
+
+	/*
+	 * Check the hardware page state and clear the discard
+	 * bit in the page flags only if the page is not
+	 * discarded.
+	 */
+	if (!page_discarded(page))
+		ClearPageDiscarded(page);
+}
+
 /**
  * add_to_swap - allocate swap space for a page
  * @page: page we want to move to swap
Index: linux-2.6/mm/swapfile.c
===================================================================
--- linux-2.6.orig/mm/swapfile.c
+++ linux-2.6/mm/swapfile.c
@@ -29,6 +29,7 @@
 #include <linux/capability.h>
 #include <linux/syscalls.h>
 #include <linux/memcontrol.h>
+#include <linux/page-states.h>
 
 #include <asm/pgtable.h>
 #include <asm/tlbflush.h>
@@ -564,6 +565,8 @@ int try_to_free_swap(struct page *page)
 		return 0;
 	if (page_swapcount(page))
 		return 0;
+	if (!page_make_stable(page))
+		return 0;
 
 	delete_from_swap_cache(page);
 	SetPageDirty(page);
@@ -585,7 +588,13 @@ int free_swap_and_cache(swp_entry_t entr
 	p = swap_info_get(entry);
 	if (p) {
 		if (swap_entry_free(p, entry) == 1) {
-			page = find_get_page(&swapper_space, entry.val);
+			/*
+			 * Use find_get_page_nodiscard to avoid the deadlock
+			 * on the swap_lock and the page table lock if the
+			 * page has been discarded.
+			 */
+			page = find_get_page_nodiscard(&swapper_space,
+						       entry.val);
 			if (page && !trylock_page(page)) {
 				page_cache_release(page);
 				page = NULL;
@@ -600,8 +609,17 @@ int free_swap_and_cache(swp_entry_t entr
 		 */
 		if (PageSwapCache(page) && !PageWriteback(page) &&
 				(!page_mapped(page) || vm_swap_full())) {
-			delete_from_swap_cache(page);
-			SetPageDirty(page);
+			/*
+			 * To be able to reload the page from swap the
+			 * swap slot may not be freed. The caller of
+			 * free_swap_and_cache holds a page table lock
+			 * for this page. The discarded page can not be
+			 * removed here.
+			 */
+			if (likely(page_make_stable(page))) {
+				delete_from_swap_cache(page);
+				SetPageDirty(page);
+			}
 		}
 		unlock_page(page);
 		page_cache_release(page);

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
