From: Magnus Damm <magnus@valinux.co.jp>
Message-Id: <20051208113000.6309.85768.sendpatchset@cherry.local>
In-Reply-To: <20051208112940.6309.39428.sendpatchset@cherry.local>
References: <20051208112940.6309.39428.sendpatchset@cherry.local>
Subject: [PATCH 04/07] Replace mapcount with PG_mapped
Date: Thu,  8 Dec 2005 20:27:15 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Magnus Damm <magnus@valinux.co.jp>, andrea@suse.de
List-ID: <linux-mm.kvack.org>

Replace mapcount with PG_mapped.

This patch contains the core of the page->_mapcount removal code. PG_mapped
replaces page->_mapcount and update_page_mapped() is introduced.

Signed-off-by: Magnus Damm <magnus@valinux.co.jp>
---

 include/linux/mm.h   |    8 --
 include/linux/rmap.h |   16 +----
 mm/fremap.c          |    3 +
 mm/rmap.c            |  143 ++++++++++++++++++++++++++++++++++++++++++--------- mm/swap.c            |   10 +++
 mm/truncate.c        |    3 -
 6 files changed, 140 insertions(+), 43 deletions(-)

--- from-0003/include/linux/mm.h
+++ to-work/include/linux/mm.h	2005-12-08 15:00:40.000000000 +0900
@@ -218,10 +218,6 @@ struct page {
 	unsigned long flags;		/* Atomic flags, some possibly
 					 * updated asynchronously */
 	atomic_t _count;		/* Usage count, see below. */
-	atomic_t _mapcount;		/* Count of ptes mapped in mms,
-					 * to show when page is mapped
-					 * & limit reverse map searches.
-					 */
 	union {
 		unsigned long private;	/* Mapping-private opaque data:
 					 * usually used for buffer_heads
@@ -583,7 +579,7 @@ static inline pgoff_t page_index(struct 
  */
 static inline void reset_page_mapcount(struct page *page)
 {
-	atomic_set(&(page)->_mapcount, -1);
+	ClearPageMapped(page);
 }
 
 /*
@@ -591,7 +587,7 @@ static inline void reset_page_mapcount(s
  */
 static inline int page_mapped(struct page *page)
 {
-	return atomic_read(&(page)->_mapcount) >= 0;
+	return PageMapped(page);
 }
 
 /*
--- from-0005/include/linux/rmap.h
+++ to-work/include/linux/rmap.h	2005-12-08 15:00:40.000000000 +0900
@@ -74,19 +74,11 @@ void __anon_vma_link(struct vm_area_stru
  */
 void page_add_anon_rmap(struct page *, struct vm_area_struct *, unsigned long);
 void page_add_file_rmap(struct page *);
-void page_remove_rmap(struct page *);
 
-/**
- * page_dup_rmap - duplicate pte mapping to a page
- * @page:	the page to add the mapping to
- *
- * For copy_page_range only: minimal extract from page_add_rmap,
- * avoiding unnecessary tests (already checked) so it's quicker.
- */
-static inline void page_dup_rmap(struct page *page)
-{
-	atomic_inc(&page->_mapcount);
-}
+static inline void page_remove_rmap(struct page *page) {}
+static inline void page_dup_rmap(struct page *page) {}
+
+int update_page_mapped(struct page *);
 
 /*
  * Called from mm/vmscan.c to handle paging out
--- from-0003/mm/fremap.c
+++ to-work/mm/fremap.c	2005-12-08 15:00:40.000000000 +0900
@@ -62,6 +62,8 @@ int install_page(struct mm_struct *mm, s
 	if (!pte)
 		goto out;
 
+	lock_page(page);
+
 	/*
 	 * This page may have been truncated. Tell the
 	 * caller about it.
@@ -85,6 +87,7 @@ int install_page(struct mm_struct *mm, s
 unlock:
 	pte_unmap_unlock(pte, ptl);
 out:
+	unlock_page(page);
 	return err;
 }
 EXPORT_SYMBOL(install_page);
--- from-0005/mm/rmap.c
+++ to-work/mm/rmap.c	2005-12-08 17:52:34.000000000 +0900
@@ -430,7 +430,7 @@ int page_referenced(struct page *page, i
 void page_add_anon_rmap(struct page *page,
 	struct vm_area_struct *vma, unsigned long address)
 {
-	if (atomic_inc_and_test(&page->_mapcount)) {
+	if (!PageMapped(page)) {
 		struct anon_vma *anon_vma = vma->anon_vma;
 
 		BUG_ON(!anon_vma);
@@ -442,6 +442,8 @@ void page_add_anon_rmap(struct page *pag
 		page->index = linear_page_index(vma, address);
 
 		inc_page_state(nr_mapped);
+		if (TestSetPageMapped(page))
+			BUG();
 	}
 	/* else checking page index and mapping is racy */
 }
@@ -457,34 +459,124 @@ void page_add_file_rmap(struct page *pag
 	BUG_ON(PageAnon(page));
 	BUG_ON(!pfn_valid(page_to_pfn(page)));
 
-	if (atomic_inc_and_test(&page->_mapcount))
+	if (!PageMapped(page)) {
 		inc_page_state(nr_mapped);
+		if (TestSetPageMapped(page))
+			BUG();
+	}
 }
 
-/**
- * page_remove_rmap - take down pte mapping from a page
- * @page: page to remove mapping from
- *
- * The caller needs to hold the pte lock.
+
+/*
+ * Subfunctions of update_page_mapped: page_mapped_one called
+ * repeatedly from either page_mapped_anon or page_mapped_file.
  */
-void page_remove_rmap(struct page *page)
+static int page_mapped_one(struct page *page, struct vm_area_struct *vma)
 {
-	if (atomic_add_negative(-1, &page->_mapcount)) {
-		/*
-		 * It would be tidy to reset the PageAnon mapping here,
-		 * but that might overwrite a racing page_add_anon_rmap
-		 * which increments mapcount after us but sets mapping
-		 * before us: so leave the reset to free_hot_cold_page,
-		 * and remember that it's only reliable while mapped.
-		 * Leaving it set also helps swapoff to reinstate ptes
-		 * faster for those pages still in swapcache.
-		 */
-		if (page_test_and_clear_dirty(page))
-			set_page_dirty(page);
-		dec_page_state(nr_mapped);
+	struct mm_struct *mm = vma->vm_mm;
+	unsigned long address;
+	pte_t *pte;
+	spinlock_t *ptl;
+	int mapped = 0;
+
+	address = vma_address(page, vma);
+	if (address == -EFAULT)
+		goto out;
+
+	pte = page_check_address(page, mm, address, &ptl);
+	if (!pte)
+		goto out;
+
+	mapped++;
+
+	pte_unmap_unlock(pte, ptl);
+out:
+	return mapped;
+}
+
+static int page_mapped_anon(struct page *page)
+{
+	struct anon_vma *anon_vma;
+	struct vm_area_struct *vma;
+	int mapped = 0;
+
+	anon_vma = page_lock_anon_vma(page);
+	if (!anon_vma)
+		return mapped;
+
+	list_for_each_entry(vma, &anon_vma->head, anon_vma_node) {
+		mapped += page_mapped_one(page, vma);
+		if (mapped)
+			break;
 	}
+
+	spin_unlock(&anon_vma->lock);
+	return mapped;
 }
 
+static int page_mapped_file(struct page *page)
+{
+	struct address_space *mapping = page->mapping;
+	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+	struct vm_area_struct *vma;
+	struct prio_tree_iter iter;
+	int mapped = 0;
+
+	/*
+	 * The caller's checks on page->mapping and !PageAnon have made
+	 * sure that this is a file page: the check for page->mapping
+	 * excludes the case just before it gets set on an anon page.
+	 */
+	BUG_ON(PageAnon(page));
+
+	/*
+	 * The page lock not only makes sure that page->mapping cannot
+	 * suddenly be NULLified by truncation, it makes sure that the
+	 * structure at mapping cannot be freed and reused yet,
+	 * so we can safely take mapping->i_mmap_lock.
+	 */
+	BUG_ON(!PageLocked(page));
+
+	spin_lock(&mapping->i_mmap_lock);
+
+	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
+		mapped += page_mapped_one(page, vma);
+		if (mapped)
+			break;
+	}
+
+	spin_unlock(&mapping->i_mmap_lock);
+	return mapped;
+}
+
+/*
+ * update_page_mapped - update the mapped bit in page->flags
+ * @page: the page to test
+ */
+int update_page_mapped(struct page *page)
+{
+	int mappings = 0;
+
+	BUG_ON(!PageLocked(page));
+
+	if (PageMapped(page)) {
+		if (page->mapping) {
+			if (PageAnon(page))
+				mappings = page_mapped_anon(page);
+			else
+				mappings = page_mapped_file(page);
+		}
+
+		if (mappings == 0) {
+			ClearPageMapped(page);
+			dec_page_state(nr_mapped);
+		}
+        }
+
+	return PageMapped(page);
+ }
+
+
 /*
  * Subfunctions of try_to_unmap: try_to_unmap_one called
  * repeatedly from either try_to_unmap_anon or try_to_unmap_file.
@@ -657,7 +749,7 @@ static int try_to_unmap_anon(struct page
 
 	list_for_each_entry(vma, &anon_vma->head, anon_vma_node) {
 		ret = try_to_unmap_one(page, vma);
-		if (ret == SWAP_FAIL || !page_mapped(page))
+		if (ret == SWAP_FAIL)
 			break;
 	}
 	spin_unlock(&anon_vma->lock);
@@ -684,10 +776,13 @@ static int try_to_unmap_file(struct page
 	unsigned long max_nl_cursor = 0;
 	unsigned long max_nl_size = 0;
 
+	if (!mapping)
+		return ret;
+
 	spin_lock(&mapping->i_mmap_lock);
 	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
 		ret = try_to_unmap_one(page, vma);
-		if (ret == SWAP_FAIL || !page_mapped(page))
+		if (ret == SWAP_FAIL)
 			goto out;
 	}
 
@@ -776,7 +871,7 @@ int try_to_unmap(struct page *page)
 	else
 		ret = try_to_unmap_file(page);
 
-	if (!page_mapped(page))
+	if (!update_page_mapped(page))
 		ret = SWAP_SUCCESS;
 	return ret;
 }
--- from-0002/mm/swap.c
+++ to-work/mm/swap.c	2005-12-08 15:00:40.000000000 +0900
@@ -177,6 +177,11 @@ void fastcall __page_cache_release(struc
 	unsigned long flags;
 	struct zone *zone = page_zone(page);
 
+	if (PageMapped(page)) {
+		dec_page_state(nr_mapped);
+		ClearPageMapped(page);
+	}
+
 	spin_lock_irqsave(&zone->lru_lock, flags);
 	if (TestClearPageLRU(page))
 		del_page_from_lru(zone, page);
@@ -215,6 +220,11 @@ void release_pages(struct page **pages, 
 		if (!put_page_testzero(page))
 			continue;
 
+		if (PageMapped(page)) {
+			dec_page_state(nr_mapped);
+			ClearPageMapped(page);
+		}
+
 		pagezone = page_zone(page);
 		if (pagezone != zone) {
 			if (zone)
--- from-0002/mm/truncate.c
+++ to-work/mm/truncate.c	2005-12-08 15:00:40.000000000 +0900
@@ -12,6 +12,7 @@
 #include <linux/module.h>
 #include <linux/pagemap.h>
 #include <linux/pagevec.h>
+#include <linux/rmap.h>
 #include <linux/buffer_head.h>	/* grr. try_to_release_page,
 				   do_invalidatepage */
 
@@ -276,7 +277,7 @@ int invalidate_inode_pages2_range(struct
 				break;
 			}
 			wait_on_page_writeback(page);
-			while (page_mapped(page)) {
+			while (update_page_mapped(page)) {
 				if (!did_range_unmap) {
 					/*
 					 * Zap the rest of the file in one hit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
