Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate7.de.ibm.com (8.13.8/8.13.8) with ESMTP id l5SGfCdj352680
	for <linux-mm@kvack.org>; Thu, 28 Jun 2007 16:41:12 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5SGfCQb921768
	for <linux-mm@kvack.org>; Thu, 28 Jun 2007 18:41:12 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5SGfCB7016549
	for <linux-mm@kvack.org>; Thu, 28 Jun 2007 18:41:12 +0200
Message-Id: <20070628164312.668459739@de.ibm.com>
References: <20070628164049.118610355@de.ibm.com>
Date: Thu, 28 Jun 2007 18:40:51 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [patch 2/6] Guest page hinting: volatile swap cache.
Content-Disposition: inline; filename=002-hva-swap.diff
Sender: owner-linux-mm@kvack.org
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
From: Hubertus Franke <frankeh@watson.ibm.com>
From: Himanshu Raj <rhim@cc.gatech.edu>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm-devel@lists.sourceforge.net, linux-mm@kvack.org
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

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
 mm/filemap.c            |   19 +++++++++++++++++
 mm/memory.c             |   13 +++++++++++-
 mm/page-states.c        |   26 ++++++++++++++++--------
 mm/rmap.c               |   51 ++++++++++++++++++++++++++++++++++++++++++++----
 mm/swap_state.c         |   25 ++++++++++++++++++++++-
 mm/swapfile.c           |   30 ++++++++++++++++++++++------
 mm/vmscan.c             |    3 ++
 9 files changed, 154 insertions(+), 21 deletions(-)

diff -urpN linux-2.6/include/linux/pagemap.h linux-2.6-patched/include/linux/pagemap.h
--- linux-2.6/include/linux/pagemap.h	2007-06-28 18:19:44.000000000 +0200
+++ linux-2.6-patched/include/linux/pagemap.h	2007-06-28 18:19:44.000000000 +0200
@@ -61,8 +61,11 @@ static inline void mapping_set_gfp_mask(
 
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
diff -urpN linux-2.6/include/linux/swap.h linux-2.6-patched/include/linux/swap.h
--- linux-2.6/include/linux/swap.h	2007-02-12 12:09:06.000000000 +0100
+++ linux-2.6-patched/include/linux/swap.h	2007-06-28 18:19:44.000000000 +0200
@@ -228,6 +228,7 @@ extern struct address_space swapper_spac
 extern void show_swap_cache_info(void);
 extern int add_to_swap(struct page *, gfp_t);
 extern void __delete_from_swap_cache(struct page *);
+extern void __delete_from_swap_cache_nocheck(struct page *);
 extern void delete_from_swap_cache(struct page *);
 extern int move_to_swap_cache(struct page *, swp_entry_t);
 extern int move_from_swap_cache(struct page *, unsigned long,
@@ -343,6 +344,10 @@ static inline void __delete_from_swap_ca
 {
 }
 
+static inline void __delete_from_swap_cache_nocheck(struct page *page)
+{
+}
+
 static inline void delete_from_swap_cache(struct page *page)
 {
 }
diff -urpN linux-2.6/mm/filemap.c linux-2.6-patched/mm/filemap.c
--- linux-2.6/mm/filemap.c	2007-06-28 18:19:44.000000000 +0200
+++ linux-2.6-patched/mm/filemap.c	2007-06-28 18:19:44.000000000 +0200
@@ -507,6 +507,25 @@ static int __sleep_on_page_lock(void *wo
 	return 0;
 }
 
+#ifdef CONFIG_PAGE_STATES
+
+struct page * find_get_page_nodiscard(struct address_space *mapping,
+				      unsigned long offset)
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
+EXPORT_SYMBOL(find_get_page_nodiscard);
+
+#endif
+
 /*
  * In order to wait for pages to become available there must be
  * waitqueues associated with pages. By using a hash table of
diff -urpN linux-2.6/mm/memory.c linux-2.6-patched/mm/memory.c
--- linux-2.6/mm/memory.c	2007-06-28 18:19:44.000000000 +0200
+++ linux-2.6-patched/mm/memory.c	2007-06-28 18:19:44.000000000 +0200
@@ -500,7 +500,18 @@ out_discard_pte:
 	 * in page cache anymore. Do what try_to_unmap_one would do
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
diff -urpN linux-2.6/mm/page-states.c linux-2.6-patched/mm/page-states.c
--- linux-2.6/mm/page-states.c	2007-06-28 18:19:44.000000000 +0200
+++ linux-2.6-patched/mm/page-states.c	2007-06-28 18:19:44.000000000 +0200
@@ -19,6 +19,7 @@
 #include <linux/buffer_head.h>
 #include <linux/pagevec.h>
 #include <linux/page-states.h>
+#include <linux/swap.h>
 
 #include "internal.h"
 
@@ -34,7 +35,8 @@ static inline int check_bits(struct page
 	 */
 	if (PageDirty(page) || PageReserved(page) || PageWriteback(page) ||
 	    PageLocked(page) || PagePrivate(page) || PageDiscarded(page) ||
-	    !PageUptodate(page) || !PageLRU(page) || PageAnon(page))
+	    !PageUptodate(page) || !PageLRU(page) ||
+	    (PageAnon(page) && !PageSwapCache(page)))
 		return 0;
 
 	/*
@@ -168,15 +170,21 @@ static void __page_discard(struct page *
 	}
 	spin_unlock_irq(&zone->lru_lock);
 
-	/* We can't handle swap cache pages (yet). */
-	VM_BUG_ON(PageSwapCache(page));
-
-	/* Remove page from page cache. */
+	/* Remove page from page cache/swap cache. */
  	mapping = page->mapping;
-	write_lock_irq(&mapping->tree_lock);
-	__remove_from_page_cache_nocheck(page);
-	write_unlock_irq(&mapping->tree_lock);
-	__put_page(page);
+	if (PageSwapCache(page)) {
+		swp_entry_t entry = { .val = page_private(page) };
+		write_lock_irq(&swapper_space.tree_lock);
+		__delete_from_swap_cache_nocheck(page);
+		write_unlock_irq(&swapper_space.tree_lock);
+		swap_free(entry);
+		page_cache_release(page);
+	} else {
+		write_lock_irq(&mapping->tree_lock);
+		__remove_from_page_cache_nocheck(page);
+		write_unlock_irq(&mapping->tree_lock);
+ 		__put_page(page);
+	}
 }
 
 /**
diff -urpN linux-2.6/mm/rmap.c linux-2.6-patched/mm/rmap.c
--- linux-2.6/mm/rmap.c	2007-06-28 18:19:44.000000000 +0200
+++ linux-2.6-patched/mm/rmap.c	2007-06-28 18:19:44.000000000 +0200
@@ -587,6 +587,7 @@ void page_add_anon_rmap(struct page *pag
 		__page_set_anon_rmap(page, vma, address);
 	else
 		__page_check_anon_rmap(page, vma, address);
+	page_make_volatile(page, 1);
 }
 
 /*
@@ -1020,13 +1021,13 @@ int try_to_unmap(struct page *page, int 
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
@@ -1035,8 +1036,6 @@ void page_unmap_all(struct page* page)
 	unsigned long address;
 	int rc;
 
-	VM_BUG_ON(!PageLocked(page) || PageReserved(page) || PageAnon(page));
-
 	spin_lock(&mapping->i_mmap_lock);
 	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
 		address = vma_address(page, vma);
@@ -1067,4 +1066,48 @@ out:
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
diff -urpN linux-2.6/mm/swapfile.c linux-2.6-patched/mm/swapfile.c
--- linux-2.6/mm/swapfile.c	2007-05-08 09:23:16.000000000 +0200
+++ linux-2.6-patched/mm/swapfile.c	2007-06-28 18:19:44.000000000 +0200
@@ -27,6 +27,7 @@
 #include <linux/mutex.h>
 #include <linux/capability.h>
 #include <linux/syscalls.h>
+#include <linux/page-states.h>
 
 #include <asm/pgtable.h>
 #include <asm/tlbflush.h>
@@ -369,9 +370,11 @@ int remove_exclusive_swap_page(struct pa
 		/* Recheck the page count with the swapcache lock held.. */
 		write_lock_irq(&swapper_space.tree_lock);
 		if ((page_count(page) == 2) && !PageWriteback(page)) {
-			__delete_from_swap_cache(page);
-			SetPageDirty(page);
-			retval = 1;
+			if (likely(page_make_stable(page))) {
+				__delete_from_swap_cache(page);
+				SetPageDirty(page);
+				retval = 1;
+			}
 		}
 		write_unlock_irq(&swapper_space.tree_lock);
 	}
@@ -400,7 +403,13 @@ void free_swap_and_cache(swp_entry_t ent
 	p = swap_info_get(entry);
 	if (p) {
 		if (swap_entry_free(p, swp_offset(entry)) == 1) {
-			page = find_get_page(&swapper_space, entry.val);
+			/*
+			 * Use find_get_page_nodiscard to avoid the deadlock
+			 * on the swap_lock and the page table lock if the
+			 * page has been discarded.
+			 */
+			page = find_get_page_nodiscard(&swapper_space,
+						       entry.val);
 			if (page && unlikely(TestSetPageLocked(page))) {
 				page_cache_release(page);
 				page = NULL;
@@ -417,8 +426,17 @@ void free_swap_and_cache(swp_entry_t ent
 		/* Also recheck PageSwapCache after page is locked (above) */
 		if (PageSwapCache(page) && !PageWriteback(page) &&
 					(one_user || vm_swap_full())) {
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
diff -urpN linux-2.6/mm/swap_state.c linux-2.6-patched/mm/swap_state.c
--- linux-2.6/mm/swap_state.c	2006-11-08 10:45:56.000000000 +0100
+++ linux-2.6-patched/mm/swap_state.c	2007-06-28 18:19:44.000000000 +0200
@@ -16,6 +16,7 @@
 #include <linux/backing-dev.h>
 #include <linux/pagevec.h>
 #include <linux/migrate.h>
+#include <linux/page-states.h>
 
 #include <asm/pgtable.h>
 
@@ -121,7 +122,7 @@ static int add_to_swap_cache(struct page
  * This must be called only on pages that have
  * been verified to be in the swap cache.
  */
-void __delete_from_swap_cache(struct page *page)
+void inline __delete_from_swap_cache_nocheck(struct page *page)
 {
 	BUG_ON(!PageLocked(page));
 	BUG_ON(!PageSwapCache(page));
@@ -136,6 +137,28 @@ void __delete_from_swap_cache(struct pag
 	INC_CACHE_INFO(del_total);
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
diff -urpN linux-2.6/mm/vmscan.c linux-2.6-patched/mm/vmscan.c
--- linux-2.6/mm/vmscan.c	2007-06-28 18:19:44.000000000 +0200
+++ linux-2.6-patched/mm/vmscan.c	2007-06-28 18:19:44.000000000 +0200
@@ -470,6 +470,9 @@ static unsigned long shrink_page_list(st
 
 		sc->nr_scanned++;
 
+		if (unlikely(PageDiscarded(page)))
+			goto free_it;
+
 		if (!sc->may_swap && page_mapped(page))
 			goto keep_locked;
 

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
