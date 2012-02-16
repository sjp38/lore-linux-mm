Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 0191F6B0083
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 16:09:25 -0500 (EST)
From: =?UTF-8?q?Rados=C5=82aw=20Smogura?= <mail@smogura.eu>
Subject: [PATCH 15/18] Splitting and truncating
Date: Thu, 16 Feb 2012 15:31:42 +0100
Message-Id: <1329402705-25454-15-git-send-email-mail@smogura.eu>
In-Reply-To: <1329402705-25454-1-git-send-email-mail@smogura.eu>
References: <1329402705-25454-1-git-send-email-mail@smogura.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Yongqiang Yang <xiaoqiangnk@gmail.com>, mail@smogura.eu, linux-ext4@vger.kernel.org

This add support for page splitting. Page splitting should be called
only in special situations (when continous region of compound page is
about to stop representing same continous region of mapping, e. g. some
tail pages are going to be removed from page cache).

We reuse zap vma for split purpose, it's not quite nice, but fast path,
should be corrected.

SHM support for this will be added later.

Signed-off-by: RadosA?aw Smogura <mail@smogura.eu>
---
 include/linux/huge_mm.h |   21 ++++++
 include/linux/mm.h      |   20 +++++
 mm/filemap.c            |   14 ++++-
 mm/huge_memory.c        |  178 +++++++++++++++++++++++++++++++++++++---------
 mm/memory.c             |   54 ++++++++++-----
 mm/truncate.c           |   18 +++++-
 6 files changed, 251 insertions(+), 54 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index c72a849..8e6bfc7 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -87,6 +87,23 @@ extern int handle_pte_fault(struct mm_struct *mm,
 			    struct vm_area_struct *vma, unsigned long address,
 			    pte_t *pte, pmd_t *pmd, unsigned int flags);
 extern int split_huge_page(struct page *page);
+
+/** Splits huge file page.
+ * @param head the head of page
+ * @param page the page that is going to be invalidated.
+ * @return 0 - inplace split, 1 - newly dequeued, 2 - dequeud and was dequeued
+ */
+extern int split_huge_page_file(struct page *head, struct page *page);
+
+/** Tries to aquire all possible locks on compound page. This includes,
+ * compound lock on all tails and normal locks on all tails. Function takes
+ * {@code page} as signle parameter head must be frozen, {@code page}
+ * must have normal ({@code lock_page}) lock.
+ *
+ * @param page locked page contained in compound page, may be head or tail
+ */
+extern int compound_try_lock_all(struct page *page);
+
 extern void __split_huge_page_pmd(struct mm_struct *mm, pmd_t *pmd);
 extern void __split_huge_page_pmd_vma(struct vm_area_struct *vma,
 	unsigned long address, pmd_t *pmd);
@@ -167,6 +184,10 @@ static inline int split_huge_page(struct page *page)
 {
 	return 0;
 }
+static inline int split_huge_page_file(struct page *head, struct page *page)
+{
+	return 0;
+}
 #define split_huge_page_pmd(__mm, __pmd)	\
 	do { } while (0)
 #define split_huge_page_pmd_vma(__vma, __addr, __pmd) do { } while (0)
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 236a6be..4c67555 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -279,6 +279,19 @@ struct inode;
 extern int put_compound_head(struct page *head);
 extern int put_compound_tail(struct page *page);
 
+/** Tries to aquire compound lock.
+ * @return not zero on success or when {@code CONFIG_TRANSPARENT_HUGEPAGE}
+ *         is not enabled, {@code 0} otherwise
+ */
+static inline int compound_trylock(struct page *head)
+{
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	return (likely(!test_and_set_bit_lock(PG_compound_lock, &head->flags)));
+#else
+	return 1;
+#endif
+}
+
 static inline void compound_lock(struct page *page)
 {
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
@@ -1058,6 +1071,11 @@ struct zap_details {
 	struct address_space *check_mapping;	/* Check page->mapping if set */
 	pgoff_t	first_index;			/* Lowest page->index to unmap */
 	pgoff_t last_index;			/* Highest page->index to unmap */
+
+	/* Instead of unmapping areas just split it down to pte level. Used
+	 * for splitting pages.
+	 */
+	int	just_split;
 };
 
 struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
@@ -1108,6 +1126,8 @@ int copy_page_range(struct mm_struct *dst, struct mm_struct *src,
 			struct vm_area_struct *vma);
 void unmap_mapping_range(struct address_space *mapping,
 		loff_t const holebegin, loff_t const holelen, int even_cows);
+void split_mapping_range(struct address_space *mapping, loff_t const holebegin,
+	loff_t const holelen);
 int follow_pfn(struct vm_area_struct *vma, unsigned long address,
 	unsigned long *pfn);
 int follow_phys(struct vm_area_struct *vma, unsigned long address,
diff --git a/mm/filemap.c b/mm/filemap.c
index b662757..8363cd9 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -124,7 +124,19 @@ void __delete_from_page_cache(struct page *page)
 		cleancache_put_page(page);
 	else
 		cleancache_flush_page(mapping, page);
-
+#if CONFIG_DEBUG_VM
+	/** This is really strong assumption, but it may be usefull
+	 * for finding problems when page is truncated, we actually allow
+	 * situation when parts of huge page will be valid in page cache,
+	 * but page should be marked & to mark page compund needs to be frozen.
+	 * The bug will not only bug, but will show nice stack trace, what is
+	 * wrong.
+	 */
+	if (PageCompound(page)) {
+		struct page *head = compound_head(page);
+		VM_BUG_ON(PageCompound(page) && !PageSplitDeque(head));
+	}
+#endif
 	radix_tree_delete(&mapping->page_tree, page->index);
 	page->mapping = NULL;
 	/* Leave page->index set: truncation lookup relies upon it */
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 95c9ce7..87fb0b1 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1256,11 +1256,17 @@ static int __split_huge_page_splitting(struct page *page,
 	return ret;
 }
 
-static void __split_huge_page_refcount(struct page *page)
+static void __split_huge_page_refcount(struct page *page,
+	struct page *keep_locked)
 {
 	int i;
 	int tail_counter;
 	struct zone *zone = page_zone(page);
+	int anon_mode = PageAnon(page);
+	const int pages = (1 << compound_order(page));
+
+	VM_BUG_ON(PageTail(page));
+	VM_BUG_ON(compound_order(page) < 2);
 
 	/* prevent PageLRU to go away from under us, and freeze lru stats */
 	spin_lock_irq(&zone->lru_lock);
@@ -1270,7 +1276,7 @@ static void __split_huge_page_refcount(struct page *page)
 
 	tail_counter = compound_elements(page);
 
-	for (i = HPAGE_PMD_NR - 1; i >= 1; i--) {
+	for (i = pages - 1; i >= 1; i--) {
 		struct page *page_tail = page + i;
 
 		/* tail_page->_mapcount cannot change */
@@ -1278,8 +1284,10 @@ static void __split_huge_page_refcount(struct page *page)
 
 		/*
 		 * tail_page->_count represents actuall number of tail pages
+		 * file backed pages have own map count.
 		 */
-		atomic_add(page_mapcount(page) + 1, &page_tail->_count);
+		if (anon_mode)
+			atomic_add(page_mapcount(page) + 1, &page_tail->_count);
 
 		/* after clearing PageTail the gup refcount can be released */
 		smp_mb();
@@ -1290,17 +1298,23 @@ static void __split_huge_page_refcount(struct page *page)
 		 *   by the memory-failure.
 		 * retain lock, and compound lock
 		 */
-		page_tail->flags &= ~PAGE_FLAGS_CHECK_AT_PREP
-			| __PG_HWPOISON
-			| PG_locked
-			| PG_compound_lock;
-
-		page_tail->flags |= (page->flags &
-				     ((1L << PG_referenced) |
-				      (1L << PG_swapbacked) |
-				      (1L << PG_mlocked) |
-				      (1L << PG_uptodate)));
-		page_tail->flags |= (1L << PG_dirty);
+		if (anon_mode) {
+			page_tail->flags &= ~PAGE_FLAGS_CHECK_AT_PREP
+				| __PG_HWPOISON
+				| PG_locked
+				| PG_compound_lock;
+
+			page_tail->flags |= (page->flags &
+					((1L << PG_referenced) |
+					(1L << PG_swapbacked) |
+					(1L << PG_mlocked) |
+					(1L << PG_uptodate)));
+			page_tail->flags |= (1L << PG_dirty);
+		} else {
+			/* Retain all flags excepting tail, head :D */
+			int clearFlags = ~((1L << PG_tail) | (1L << PG_head));
+			page_tail->flags = (page_tail->flags & clearFlags);
+		}
 
 		/* clear PageTail before overwriting first_page */
 		smp_wmb();
@@ -1319,26 +1333,31 @@ static void __split_huge_page_refcount(struct page *page)
 		 * status is achieved setting a reserved bit in the
 		 * pmd, not by clearing the present bit.
 		*/
-		page_tail->_mapcount = page->_mapcount;
+		if (anon_mode) {
+			page_tail->_mapcount = page->_mapcount;
 
-		BUG_ON(page_tail->mapping);
-		page_tail->mapping = page->mapping;
+			BUG_ON(page_tail->mapping);
+			page_tail->mapping = page->mapping;
 
-		page_tail->index = page->index + i;
-
-		BUG_ON(!PageAnon(page_tail));
-		BUG_ON(!PageUptodate(page_tail));
-		BUG_ON(!PageDirty(page_tail));
-		BUG_ON(!PageSwapBacked(page_tail));
+			page_tail->index = page->index + i;
 
+			BUG_ON(!PageAnon(page_tail));
+			BUG_ON(!PageUptodate(page_tail));
+			BUG_ON(!PageDirty(page_tail));
+			BUG_ON(!PageSwapBacked(page_tail));
+		}
+		page_tail->__first_page = NULL;
 		lru_add_page_tail(zone, page, page_tail);
 	}
 	BUG_ON(atomic_read(&page->_count) <= 0);
 
-	__dec_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
-	__mod_zone_page_state(zone, NR_ANON_PAGES, HPAGE_PMD_NR);
+	if (anon_mode) {
+		__dec_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
+		__mod_zone_page_state(zone, NR_ANON_PAGES, HPAGE_PMD_NR);
+	}
 
 	ClearPageCompound(page);
+	TestClearPageSplitDeque(page);
 	compound_unlock(page);
 	/* Remove additional reference used in compound. */
 	if (tail_counter)
@@ -1348,17 +1367,25 @@ static void __split_huge_page_refcount(struct page *page)
 
 	for (i = 1; i < HPAGE_PMD_NR; i++) {
 		struct page *page_tail = page + i;
-		BUG_ON(page_count(page_tail) <= 0);
-		/*
-		 * Tail pages may be freed if there wasn't any mapping
-		 * like if add_to_swap() is running on a lru page that
-		 * had its mapping zapped. And freeing these pages
-		 * requires taking the lru_lock so we do the put_page
-		 * of the tail pages after the split is complete.
-		 */
-		put_page(page_tail);
+		if (anon_mode) {
+			BUG_ON(page_count(page_tail) <= 0);
+			/*
+			* Tail pages may be freed if there wasn't any mapping
+			* like if add_to_swap() is running on a lru page that
+			* had its mapping zapped. And freeing these pages
+			* requires taking the lru_lock so we do the put_page
+			* of the tail pages after the split is complete.
+			*/
+			put_page(page_tail);
+		} else {
+			if (page_tail != keep_locked)
+				unlock_page(page_tail);
+		}
 	}
 
+	if (!anon_mode && page != keep_locked)
+		unlock_page(page);
+
 	/*
 	 * Only the head page (now become a regular page) is required
 	 * to be pinned by the caller.
@@ -1473,7 +1500,7 @@ static void __split_huge_page(struct page *page,
 		       mapcount, page_mapcount(page));
 	BUG_ON(mapcount != page_mapcount(page));
 
-	__split_huge_page_refcount(page);
+	__split_huge_page_refcount(page, NULL);
 
 	mapcount2 = 0;
 	list_for_each_entry(avc, &anon_vma->head, same_anon_vma) {
@@ -1490,6 +1517,87 @@ static void __split_huge_page(struct page *page,
 	BUG_ON(mapcount != mapcount2);
 }
 
+int compound_try_lock_all(struct page *page)
+{
+	struct page *head;
+	struct page *p;
+	int processed;
+	int toProcess;
+
+	VM_BUG_ON(!PageLocked(page));
+
+	/* Requirement compound must be getted so no split. */
+	head = compound_head(page);
+	VM_BUG_ON(compound_order(head) < 2);
+	VM_BUG_ON(atomic_read(&head[2]._compound_usage) != 0);
+
+	toProcess = 1 << compound_order(head);
+
+	/* First two passes will go explicite, next by __first_page to speed up.
+	 */
+	if (head != page) {
+		if (!trylock_page(head))
+			return 0;
+	}
+
+	if ((head + 1) != page) {
+		if (!trylock_page(head + 1)) {
+			unlock_page(head);
+			return 0;
+		}
+	}
+
+	processed = 2;
+	/* Lock ordering page lock, then compound lock */
+	for (p = head + 2; p->__first_page == head; p++, processed++) {
+		if (p != page) {
+			if (!trylock_page(p))
+				break;
+		}
+	}
+	if (processed == toProcess)
+		return 1;
+
+	/** Rollback - reverse order */
+	do {
+		p--;
+		if (p != page)
+			unlock_page(p);
+		if (p == head)
+			return 0;
+	} while (1);
+}
+/** Splits huge file page.
+ * @param head the head of page
+ * @param page the page that is going to be invalidated.
+ * @return 0 - inplace split, 1 - newly dequeued, 2 - dequeud and was dequeued
+ */
+int split_huge_page_file(struct page *head, struct page *page)
+{
+	VM_BUG_ON(compound_order(head) < 2);
+	VM_BUG_ON(atomic_read(&compound_head(head)[2]._compound_usage));
+	VM_BUG_ON(PageAnon(head));
+
+	if (PageSplitDeque(head))
+		return 2;
+
+	/* Split all vma's. */
+	split_mapping_range(page_mapping(head),
+		(loff_t)page->index << PAGE_CACHE_SHIFT,
+		PAGE_CACHE_SIZE * (1 << compound_order(head)));
+
+	if (compound_try_lock_all(page)) {
+		/* Do in place split. */
+		__split_huge_page_refcount(head, page);
+		return 0;
+	} else {
+		/* We can't lock all tail pages, mark page as split dequed. */
+		if (TestSetPageSplitDeque(head))
+			return 2;
+		else
+			return 1;
+	}
+}
 int split_huge_page(struct page *page)
 {
 	struct anon_vma *anon_vma;
diff --git a/mm/memory.c b/mm/memory.c
index 539d1f4..2b43661 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1253,12 +1253,15 @@ static inline unsigned long zap_pmd_range(struct mmu_gather *tlb,
 	do {
 		next = pmd_addr_end(addr, end);
 		if (pmd_trans_huge(*pmd)) {
-			if (next-addr != HPAGE_PMD_SIZE) {
+			if (unlikely(details && details->just_split) ||
+				next - addr != HPAGE_PMD_SIZE) {
 				/* And now we go again in conflict with, THP...
 				 * THP requires semaphore, we require compound
 				 * frozen, why...?
 				 */
 				split_huge_page_pmd_vma(vma, addr, pmd);
+				if (unlikely(details && details->just_split))
+					continue;
 			} else if (zap_huge_pmd(tlb, vma, pmd, addr))
 				continue;
 			/* fall through */
@@ -2826,22 +2829,9 @@ static inline void unmap_mapping_range_list(struct list_head *head,
 	}
 }
 
-/**
- * unmap_mapping_range - unmap the portion of all mmaps in the specified address_space corresponding to the specified page range in the underlying file.
- * @mapping: the address space containing mmaps to be unmapped.
- * @holebegin: byte in first page to unmap, relative to the start of
- * the underlying file.  This will be rounded down to a PAGE_SIZE
- * boundary.  Note that this is different from truncate_pagecache(), which
- * must keep the partial page.  In contrast, we must get rid of
- * partial pages.
- * @holelen: size of prospective hole in bytes.  This will be rounded
- * up to a PAGE_SIZE boundary.  A holelen of zero truncates to the
- * end of the file.
- * @even_cows: 1 when truncating a file, unmap even private COWed pages;
- * but 0 when invalidating pagecache, don't throw away private data.
- */
-void unmap_mapping_range(struct address_space *mapping,
-		loff_t const holebegin, loff_t const holelen, int even_cows)
+static void _unmap_mapping_range(struct address_space *mapping,
+		loff_t const holebegin, loff_t const holelen, int even_cows,
+		int just_split)
 {
 	struct zap_details details;
 	pgoff_t hba = holebegin >> PAGE_SHIFT;
@@ -2859,6 +2849,8 @@ void unmap_mapping_range(struct address_space *mapping,
 	details.nonlinear_vma = NULL;
 	details.first_index = hba;
 	details.last_index = hba + hlen - 1;
+	details.just_split = just_split;
+
 	if (details.last_index < details.first_index)
 		details.last_index = ULONG_MAX;
 
@@ -2870,8 +2862,36 @@ void unmap_mapping_range(struct address_space *mapping,
 		unmap_mapping_range_list(&mapping->i_mmap_nonlinear, &details);
 	mutex_unlock(&mapping->i_mmap_mutex);
 }
+/**
+ * unmap_mapping_range - unmap the portion of all mmaps in the specified address_space corresponding to the specified page range in the underlying file.
+ * @mapping: the address space containing mmaps to be unmapped.
+ * @holebegin: byte in first page to unmap, relative to the start of
+ * the underlying file.  This will be rounded down to a PAGE_SIZE
+ * boundary.  Note that this is different from truncate_pagecache(), which
+ * must keep the partial page.  In contrast, we must get rid of
+ * partial pages.
+ * @holelen: size of prospective hole in bytes.  This will be rounded
+ * up to a PAGE_SIZE boundary.  A holelen of zero truncates to the
+ * end of the file.
+ * @even_cows: 1 when truncating a file, unmap even private COWed pages;
+ * but 0 when invalidating pagecache, don't throw away private data.
+ */
+void unmap_mapping_range(struct address_space *mapping,
+		loff_t const holebegin, loff_t const holelen, int even_cows)
+{
+	_unmap_mapping_range(mapping, holebegin, holelen, even_cows, false);
+}
 EXPORT_SYMBOL(unmap_mapping_range);
 
+void split_mapping_range(struct address_space *mapping,
+		loff_t const holebegin, loff_t const holelen)
+{
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	_unmap_mapping_range(mapping, holebegin, holelen, false, true);
+#endif
+}
+EXPORT_SYMBOL(split_mapping_range);
+
 /*
  * We enter with non-exclusive mmap_sem (to exclude vma changes,
  * but allow concurrent faults), and pte mapped but not yet locked.
diff --git a/mm/truncate.c b/mm/truncate.c
index 632b15e..6112a76 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -140,12 +140,28 @@ invalidate_complete_page(struct address_space *mapping, struct page *page)
 
 int truncate_inode_page(struct address_space *mapping, struct page *page)
 {
+	struct page *head = NULL;
+	int result;
+
+	if (unlikely(PageCompound(page))) {
+		head = compound_head(page);
+		if (compound_freeze(head)) {
+			if (!split_huge_page_file(head, page))
+				head = NULL;
+		} else {
+			head = NULL;
+		}
+	}
+
 	if (page_mapped(page)) {
 		unmap_mapping_range(mapping,
 				   (loff_t)page->index << PAGE_CACHE_SHIFT,
 				   PAGE_CACHE_SIZE, 0);
 	}
-	return truncate_complete_page(mapping, page);
+	result = truncate_complete_page(mapping, page);
+	if (head)
+		compound_unfreeze(head);
+	return result;
 }
 
 /*
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
