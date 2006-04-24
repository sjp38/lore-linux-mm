Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate4.de.ibm.com (8.13.6/8.13.6) with ESMTP id k3OCYhUr183054
	for <linux-mm@kvack.org>; Mon, 24 Apr 2006 12:34:43 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k3OCZmGv118974
	for <linux-mm@kvack.org>; Mon, 24 Apr 2006 14:35:48 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11/8.13.3) with ESMTP id k3OCYhIu005741
	for <linux-mm@kvack.org>; Mon, 24 Apr 2006 14:34:43 +0200
Date: Mon, 24 Apr 2006 14:34:48 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [patch 3/8] Page host virtual assist: volatile swap cache.
Message-ID: <20060424123447.GD15817@skybase>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
From: Hubertus Franke <frankeh@watson.ibm.com>
From: Himanshu Raj <rhim@cc.gatech.edu>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, akpm@osdl.org, frankeh@watson.ibm.com, rhim@cc.gatech.edu
List-ID: <linux-mm.kvack.org>

[patch 3/8] Page host virtual assist: volatile swap cache.

The volatile page state can be used for anonymous pages as well, if
they have been added to the swap cache and the swap write is done.
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

 include/linux/pagemap.h |    7 ++++++
 mm/filemap.c            |   19 ++++++++++++++++++
 mm/memory.c             |   12 +++++++++--
 mm/page_hva.c           |   13 ++++++------
 mm/rmap.c               |   49 ++++++++++++++++++++++++++++++++++++++++++++----
 mm/swapfile.c           |   20 ++++++++++++++++---
 6 files changed, 105 insertions(+), 15 deletions(-)

diff -urpN linux-2.6/include/linux/pagemap.h linux-2.6-patched/include/linux/pagemap.h
--- linux-2.6/include/linux/pagemap.h	2006-04-24 12:51:20.000000000 +0200
+++ linux-2.6-patched/include/linux/pagemap.h	2006-04-24 12:51:27.000000000 +0200
@@ -81,6 +81,13 @@ unsigned find_get_pages(struct address_s
 unsigned find_get_pages_tag(struct address_space *mapping, pgoff_t *index,
 			int tag, unsigned int nr_pages, struct page **pages);
 
+#if defined(CONFIG_PAGE_HVA)
+extern struct page * find_get_page_nohv(struct address_space *mapping,
+				unsigned long index);
+#else
+#define find_get_page_nohv(mapping, index)	find_get_page(mapping, index)
+#endif
+
 /*
  * Returns locked page at given index in given cache, creating it if needed.
  */
diff -urpN linux-2.6/mm/filemap.c linux-2.6-patched/mm/filemap.c
--- linux-2.6/mm/filemap.c	2006-04-24 12:51:27.000000000 +0200
+++ linux-2.6-patched/mm/filemap.c	2006-04-24 12:51:27.000000000 +0200
@@ -574,6 +574,25 @@ struct page * find_get_page(struct addre
 
 EXPORT_SYMBOL(find_get_page);
 
+#if defined(CONFIG_PAGE_HVA)
+
+struct page * find_get_page_nohv(struct address_space *mapping,
+				unsigned long offset)
+{
+	struct page *page;
+
+	read_lock_irq(&mapping->tree_lock);
+	page = radix_tree_lookup(&mapping->page_tree, offset);
+	if (page)
+		page_cache_get(page);
+	read_unlock_irq(&mapping->tree_lock);
+	return page;
+}
+
+EXPORT_SYMBOL(find_get_page_nohv);
+
+#endif
+
 /*
  * Same as above, but trylock it instead of incrementing the count.
  */
diff -urpN linux-2.6/mm/memory.c linux-2.6-patched/mm/memory.c
--- linux-2.6/mm/memory.c	2006-04-24 12:51:27.000000000 +0200
+++ linux-2.6-patched/mm/memory.c	2006-04-24 12:51:27.000000000 +0200
@@ -1967,8 +1967,16 @@ static int do_swap_page(struct mm_struct
 	unlock_page(page);
 
 	if (write_access) {
-		if (do_wp_page(mm, vma, address,
-				page_table, pmd, ptl, pte) == VM_FAULT_OOM)
+		int rc = do_wp_page(mm, vma, address, page_table,
+				    pmd, ptl, pte);
+		if (page_hva_enabled() && rc == VM_FAULT_MAJOR)
+			/*
+			 * A discard removed the page, and do_wp_page called
+			 * page_hva_discard_page which removed the pte as well.
+			 * handle_pte_fault needs to be repeated.
+			 */
+			ret = VM_FAULT_MINOR;
+		else if (rc == VM_FAULT_OOM)
 			ret = VM_FAULT_OOM;
 		goto out;
 	}
diff -urpN linux-2.6/mm/page_hva.c linux-2.6-patched/mm/page_hva.c
--- linux-2.6/mm/page_hva.c	2006-04-24 12:51:27.000000000 +0200
+++ linux-2.6-patched/mm/page_hva.c	2006-04-24 12:51:27.000000000 +0200
@@ -17,6 +17,7 @@
 #include <linux/module.h>
 #include <linux/spinlock.h>
 #include <linux/buffer_head.h>
+#include <linux/swap.h>
 
 #include "internal.h"
 
@@ -32,7 +33,7 @@ static inline int __page_hva_discardable
 	 */
 	if (PageDirty(page) || PageReserved(page) || PageWriteback(page) ||
 	    PageLocked(page) || PagePrivate(page) || PageDiscarded(page) ||
-	    !PageUptodate(page) || PageAnon(page))
+	    !PageUptodate(page) || (PageAnon(page) && !PageSwapCache(page)))
 		return 0;
 
 	/*
@@ -149,11 +150,11 @@ static void __page_hva_discard_page(stru
 	del_page_from_lru(zone, page);
 	spin_unlock_irq(&zone->lru_lock);
 
-	/* We can't handle swap cache pages (yet). */
-	BUG_ON(PageSwapCache(page));
-
-	/* Remove page from page cache. */
-	remove_from_page_cache(page);
+	/* Remove page from page/swap cache. */
+	if (PageSwapCache(page))
+		delete_from_swap_cache(page);
+	else
+		remove_from_page_cache(page);
 }
 
 /**
diff -urpN linux-2.6/mm/rmap.c linux-2.6-patched/mm/rmap.c
--- linux-2.6/mm/rmap.c	2006-04-24 12:51:27.000000000 +0200
+++ linux-2.6-patched/mm/rmap.c	2006-04-24 12:51:27.000000000 +0200
@@ -472,6 +472,7 @@ void page_add_anon_rmap(struct page *pag
 	if (atomic_inc_and_test(&page->_mapcount))
 		__page_set_anon_rmap(page, vma, address);
 	/* else checking page index and mapping is racy */
+	page_hva_make_volatile(page, 1);
 }
 
 /*
@@ -858,13 +859,13 @@ int try_to_unmap(struct page *page, int 
 #if defined(CONFIG_PAGE_HVA)
 
 /**
- * page_hva_unmap_all - removes all mappings of a page
+ * page_hva_unmap_file - removes all mappings of a file page
  *
  * @page: the page which mapping in the vma should be struck down
  *
  * the caller needs to hold page lock
  */
-void page_hva_unmap_all(struct page* page)
+static void page_hva_unmap_file(struct page* page)
 {
 	struct address_space *mapping = page_mapping(page);
 	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
@@ -872,8 +873,6 @@ void page_hva_unmap_all(struct page* pag
 	struct prio_tree_iter iter;
 	unsigned long address;
 
-	BUG_ON(!PageLocked(page) || PageReserved(page) || PageAnon(page));
-
 	spin_lock(&mapping->i_mmap_lock);
 	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
 		address = vma_address(page, vma);
@@ -902,4 +901,46 @@ out:
 	spin_unlock(&mapping->i_mmap_lock);
 }
 
+/**
+ * page_hva_unmap_anon - removes all mappings of an anonymous page
+ *
+ * @page: the page which mapping in the vma should be struck down
+ *
+ * the caller needs to hold page lock
+ */
+static void page_hva_unmap_anon(struct page* page)
+{
+	struct anon_vma *anon_vma;
+	struct vm_area_struct *vma;
+	unsigned long address;
+
+	anon_vma = page_lock_anon_vma(page);
+	if (!anon_vma)
+		return;
+	list_for_each_entry(vma, &anon_vma->head, anon_vma_node) {
+		address = vma_address(page, vma);
+		if (address == -EFAULT)
+			continue;
+		BUG_ON(try_to_unmap_one(page, vma, address, 0) == SWAP_FAIL);
+	}
+	spin_unlock(&anon_vma->lock);
+}
+
+/**
+ * page_hva_unmap_all - removes all mappings of a page
+ *
+ * @page: the page which mapping in the vma should be struck down
+ *
+ * the caller needs to hold page lock
+ */
+void page_hva_unmap_all(struct page *page)
+{
+	BUG_ON(!PageLocked(page) || PageReserved(page));
+
+	if (PageAnon(page))
+		page_hva_unmap_anon(page);
+	else
+		page_hva_unmap_file(page);
+}
+
 #endif
diff -urpN linux-2.6/mm/swapfile.c linux-2.6-patched/mm/swapfile.c
--- linux-2.6/mm/swapfile.c	2006-04-24 12:51:21.000000000 +0200
+++ linux-2.6-patched/mm/swapfile.c	2006-04-24 12:51:27.000000000 +0200
@@ -401,7 +401,12 @@ void free_swap_and_cache(swp_entry_t ent
 	p = swap_info_get(entry);
 	if (p) {
 		if (swap_entry_free(p, swp_offset(entry)) == 1) {
-			page = find_get_page(&swapper_space, entry.val);
+			/*
+			 * Use find_get_page_nohv to avoid the deadlock
+			 * on the swap_lock and the page table lock if
+			 * the page has been discarded.
+			 */
+			page = find_get_page_nohv(&swapper_space, entry.val);
 			if (page && unlikely(TestSetPageLocked(page))) {
 				page_cache_release(page);
 				page = NULL;
@@ -418,8 +423,17 @@ void free_swap_and_cache(swp_entry_t ent
 		/* Also recheck PageSwapCache after page is locked (above) */
 		if (PageSwapCache(page) && !PageWriteback(page) &&
 					(one_user || vm_swap_full())) {
-			delete_from_swap_cache(page);
-			SetPageDirty(page);
+			/*
+			 * The caller of free_swap_and_cache holds a
+			 * page table lock for this page. A discarded
+			 * page can not be removed at this point. To be
+			 * able to reload the page from swap the swap
+			 * slot may not be freed.
+			 */
+			if (likely(page_hva_make_stable(page))) {
+				delete_from_swap_cache(page);
+				SetPageDirty(page);
+			}
 		}
 		unlock_page(page);
 		page_cache_release(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
