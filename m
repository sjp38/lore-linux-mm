Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f170.google.com (mail-pf0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id BA0206B0269
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 09:23:29 -0500 (EST)
Received: by mail-pf0-f170.google.com with SMTP id e127so30223552pfe.3
        for <linux-mm@kvack.org>; Thu, 11 Feb 2016 06:23:29 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id w18si12879378pfi.224.2016.02.11.06.23.00
        for <linux-mm@kvack.org>;
        Thu, 11 Feb 2016 06:23:00 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 24/28] filemap: prepare find and delete operations for huge pages
Date: Thu, 11 Feb 2016 17:21:52 +0300
Message-Id: <1455200516-132137-25-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1455200516-132137-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1455200516-132137-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

For now, we would have HPAGE_PMD_NR entries in radix tree for every huge
page. That's suboptimal and it will be changed to use Matthew's
multi-order entries later.

'add' operation is not changed, because we don't need it to implement
hugetmpfs: shmem uses its own implementation.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/filemap.c | 187 ++++++++++++++++++++++++++++++++++++++++++-----------------
 1 file changed, 134 insertions(+), 53 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index ba8150d6dc33..d082ca524ba3 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -110,43 +110,18 @@
  *   ->tasklist_lock            (memory_failure, collect_procs_ao)
  */
 
-static void page_cache_tree_delete(struct address_space *mapping,
-				   struct page *page, void *shadow)
+static void __page_cache_tree_delete(struct address_space *mapping,
+		struct radix_tree_node *node, void **slot, unsigned long index,
+		void *shadow)
 {
-	struct radix_tree_node *node;
-	unsigned long index;
-	unsigned int offset;
 	unsigned int tag;
-	void **slot;
-
-	VM_BUG_ON(!PageLocked(page));
 
-	__radix_tree_lookup(&mapping->page_tree, page->index, &node, &slot);
-
-	if (shadow) {
-		mapping->nrexceptional++;
-		/*
-		 * Make sure the nrexceptional update is committed before
-		 * the nrpages update so that final truncate racing
-		 * with reclaim does not see both counters 0 at the
-		 * same time and miss a shadow entry.
-		 */
-		smp_wmb();
-	}
-	mapping->nrpages--;
-
-	if (!node) {
-		/* Clear direct pointer tags in root node */
-		mapping->page_tree.gfp_mask &= __GFP_BITS_MASK;
-		radix_tree_replace_slot(slot, shadow);
-		return;
-	}
+	VM_BUG_ON(node == NULL);
+	VM_BUG_ON(*slot == NULL);
 
 	/* Clear tree tags for the removed page */
-	index = page->index;
-	offset = index & RADIX_TREE_MAP_MASK;
 	for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++) {
-		if (test_bit(offset, node->tags[tag]))
+		if (test_bit(index & RADIX_TREE_MAP_MASK, node->tags[tag]))
 			radix_tree_tag_clear(&mapping->page_tree, index, tag);
 	}
 
@@ -173,6 +148,54 @@ static void page_cache_tree_delete(struct address_space *mapping,
 	}
 }
 
+static void page_cache_tree_delete(struct address_space *mapping,
+				   struct page *page, void *shadow)
+{
+	struct radix_tree_node *node;
+	unsigned long index;
+	void **slot;
+	int i, nr = PageHuge(page) ? 1 : hpage_nr_pages(page);
+
+	VM_BUG_ON_PAGE(!PageLocked(page), page);
+	VM_BUG_ON_PAGE(PageTail(page), page);
+
+	__radix_tree_lookup(&mapping->page_tree, page->index, &node, &slot);
+
+	if (shadow) {
+		mapping->nrexceptional += nr;
+		/*
+		 * Make sure the nrexceptional update is committed before
+		 * the nrpages update so that final truncate racing
+		 * with reclaim does not see both counters 0 at the
+		 * same time and miss a shadow entry.
+		 */
+		smp_wmb();
+	}
+	mapping->nrpages -= nr;
+
+	if (!node) {
+		/* Clear direct pointer tags in root node */
+		mapping->page_tree.gfp_mask &= __GFP_BITS_MASK;
+		VM_BUG_ON(nr != 1);
+		radix_tree_replace_slot(slot, shadow);
+		return;
+	}
+
+	index = page->index;
+	VM_BUG_ON_PAGE(index & (nr - 1), page);
+	for (i = 0; i < nr; i++) {
+		/* Cross node border */
+		if (i && ((index + i) & RADIX_TREE_MAP_MASK) == 0) {
+			__radix_tree_lookup(&mapping->page_tree,
+					page->index + i, &node, &slot);
+		}
+
+		__page_cache_tree_delete(mapping, node,
+				slot + (i & RADIX_TREE_MAP_MASK), index + i,
+				shadow);
+	}
+}
+
 /*
  * Delete a page from the page cache and free it. Caller has to make
  * sure the page is locked and that nobody else uses it - or that usage
@@ -181,6 +204,7 @@ static void page_cache_tree_delete(struct address_space *mapping,
 void __delete_from_page_cache(struct page *page, void *shadow)
 {
 	struct address_space *mapping = page->mapping;
+	int nr = hpage_nr_pages(page);
 
 	trace_mm_filemap_delete_from_page_cache(page);
 	/*
@@ -200,9 +224,10 @@ void __delete_from_page_cache(struct page *page, void *shadow)
 
 	/* hugetlb pages do not participate in page cache accounting. */
 	if (!PageHuge(page))
-		__dec_zone_page_state(page, NR_FILE_PAGES);
+		__mod_zone_page_state(page_zone(page), NR_FILE_PAGES, -nr);
 	if (PageSwapBacked(page))
-		__dec_zone_page_state(page, NR_SHMEM);
+		__mod_zone_page_state(page_zone(page), NR_SHMEM, -nr);
+	VM_BUG_ON_PAGE(PageTail(page), page);
 	VM_BUG_ON_PAGE(page_mapped(page), page);
 
 	/*
@@ -227,9 +252,8 @@ void __delete_from_page_cache(struct page *page, void *shadow)
  */
 void delete_from_page_cache(struct page *page)
 {
-	struct address_space *mapping = page->mapping;
+	struct address_space *mapping = page_mapping(page);
 	unsigned long flags;
-
 	void (*freepage)(struct page *);
 
 	BUG_ON(!PageLocked(page));
@@ -242,7 +266,13 @@ void delete_from_page_cache(struct page *page)
 
 	if (freepage)
 		freepage(page);
-	page_cache_release(page);
+
+	if (PageTransHuge(page) && !PageHuge(page)) {
+		atomic_sub(HPAGE_PMD_NR, &page->_count);
+		VM_BUG_ON_PAGE(atomic_read(&page->_count) <= 0, page);
+	} else {
+		page_cache_release(page);
+	}
 }
 EXPORT_SYMBOL(delete_from_page_cache);
 
@@ -1035,7 +1065,7 @@ EXPORT_SYMBOL(page_cache_prev_hole);
 struct page *find_get_entry(struct address_space *mapping, pgoff_t offset)
 {
 	void **pagep;
-	struct page *page;
+	struct page *head, *page;
 
 	rcu_read_lock();
 repeat:
@@ -1055,9 +1085,17 @@ repeat:
 			 */
 			goto out;
 		}
-		if (!page_cache_get_speculative(page))
+
+		head = compound_head(page);
+		if (!page_cache_get_speculative(head))
 			goto repeat;
 
+		/* The page was split under us? */
+		if (compound_head(page) != head) {
+			page_cache_release(page);
+			goto repeat;
+		}
+
 		/*
 		 * Has the page moved?
 		 * This is part of the lockless pagecache protocol. See
@@ -1100,12 +1138,12 @@ repeat:
 	if (page && !radix_tree_exception(page)) {
 		lock_page(page);
 		/* Has the page been truncated? */
-		if (unlikely(page->mapping != mapping)) {
+		if (unlikely(page_mapping(page) != mapping)) {
 			unlock_page(page);
 			page_cache_release(page);
 			goto repeat;
 		}
-		VM_BUG_ON_PAGE(page->index != offset, page);
+		VM_BUG_ON_PAGE(page_to_pgoff(page) != offset, page);
 	}
 	return page;
 }
@@ -1238,7 +1276,7 @@ unsigned find_get_entries(struct address_space *mapping,
 	rcu_read_lock();
 restart:
 	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, start) {
-		struct page *page;
+		struct page *head, *page;
 repeat:
 		page = radix_tree_deref_slot(slot);
 		if (unlikely(!page))
@@ -1253,8 +1291,16 @@ repeat:
 			 */
 			goto export;
 		}
-		if (!page_cache_get_speculative(page))
+
+		head = compound_head(page);
+		if (!page_cache_get_speculative(head))
+			goto repeat;
+
+		/* The page was split under us? */
+		if (compound_head(page) != head) {
+			page_cache_release(page);
 			goto repeat;
+		}
 
 		/* Has the page moved? */
 		if (unlikely(page != *slot)) {
@@ -1300,7 +1346,7 @@ unsigned find_get_pages(struct address_space *mapping, pgoff_t start,
 	rcu_read_lock();
 restart:
 	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, start) {
-		struct page *page;
+		struct page *head, *page;
 repeat:
 		page = radix_tree_deref_slot(slot);
 		if (unlikely(!page))
@@ -1324,9 +1370,16 @@ repeat:
 			continue;
 		}
 
-		if (!page_cache_get_speculative(page))
+		head = compound_head(page);
+		if (!page_cache_get_speculative(head))
 			goto repeat;
 
+		/* The page was split under us? */
+		if (compound_head(page) != head) {
+			page_cache_release(page);
+			goto repeat;
+		}
+
 		/* Has the page moved? */
 		if (unlikely(page != *slot)) {
 			page_cache_release(page);
@@ -1367,7 +1420,7 @@ unsigned find_get_pages_contig(struct address_space *mapping, pgoff_t index,
 	rcu_read_lock();
 restart:
 	radix_tree_for_each_contig(slot, &mapping->page_tree, &iter, index) {
-		struct page *page;
+		struct page *head, *page;
 repeat:
 		page = radix_tree_deref_slot(slot);
 		/* The hole, there no reason to continue */
@@ -1391,8 +1444,14 @@ repeat:
 			break;
 		}
 
-		if (!page_cache_get_speculative(page))
+		head = compound_head(page);
+		if (!page_cache_get_speculative(head))
 			goto repeat;
+		/* The page was split under us? */
+		if (compound_head(page) != head) {
+			page_cache_release(page);
+			goto repeat;
+		}
 
 		/* Has the page moved? */
 		if (unlikely(page != *slot)) {
@@ -1405,7 +1464,7 @@ repeat:
 		 * otherwise we can get both false positives and false
 		 * negatives, which is just confusing to the caller.
 		 */
-		if (page->mapping == NULL || page->index != iter.index) {
+		if (page->mapping == NULL || page_to_pgoff(page) != iter.index) {
 			page_cache_release(page);
 			break;
 		}
@@ -1444,7 +1503,7 @@ unsigned find_get_pages_tag(struct address_space *mapping, pgoff_t *index,
 restart:
 	radix_tree_for_each_tagged(slot, &mapping->page_tree,
 				   &iter, *index, tag) {
-		struct page *page;
+		struct page *head, *page;
 repeat:
 		page = radix_tree_deref_slot(slot);
 		if (unlikely(!page))
@@ -1473,8 +1532,15 @@ repeat:
 			continue;
 		}
 
-		if (!page_cache_get_speculative(page))
+		head = compound_head(page);
+		if (!page_cache_get_speculative(head))
+			goto repeat;
+
+		/* The page was split under us? */
+		if (compound_head(page) != head) {
+			page_cache_release(page);
 			goto repeat;
+		}
 
 		/* Has the page moved? */
 		if (unlikely(page != *slot)) {
@@ -1523,7 +1589,7 @@ unsigned find_get_entries_tag(struct address_space *mapping, pgoff_t start,
 restart:
 	radix_tree_for_each_tagged(slot, &mapping->page_tree,
 				   &iter, start, tag) {
-		struct page *page;
+		struct page *head, *page;
 repeat:
 		page = radix_tree_deref_slot(slot);
 		if (unlikely(!page))
@@ -1545,9 +1611,17 @@ repeat:
 			 */
 			goto export;
 		}
-		if (!page_cache_get_speculative(page))
+
+		head = compound_head(page);
+		if (!page_cache_get_speculative(head))
 			goto repeat;
 
+		/* The page was split under us? */
+		if (compound_head(page) != head) {
+			page_cache_release(page);
+			goto repeat;
+		}
+
 		/* Has the page moved? */
 		if (unlikely(page != *slot)) {
 			page_cache_release(page);
@@ -2139,7 +2213,7 @@ void filemap_map_pages(struct fault_env *fe,
 	struct address_space *mapping = file->f_mapping;
 	pgoff_t last_pgoff = start_pgoff;
 	loff_t size;
-	struct page *page;
+	struct page *head, *page;
 
 	rcu_read_lock();
 	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter,
@@ -2157,8 +2231,15 @@ repeat:
 				goto next;
 		}
 
-		if (!page_cache_get_speculative(page))
+		head = compound_head(page);
+		if (!page_cache_get_speculative(head))
+			goto repeat;
+
+		/* The page was split under us? */
+		if (compound_head(page) != head) {
+			page_cache_release(page);
 			goto repeat;
+		}
 
 		/* Has the page moved? */
 		if (unlikely(page != *slot)) {
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
