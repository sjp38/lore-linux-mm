Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id B3BFF6B025F
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 16:12:16 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 143so64249414pfx.0
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 13:12:16 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id xj8si14251650pab.203.2016.06.15.13.07.04
        for <linux-mm@kvack.org>;
        Wed, 15 Jun 2016 13:07:04 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv9-rebased2 24/37] filemap: prepare find and delete operations for huge pages
Date: Wed, 15 Jun 2016 23:06:29 +0300
Message-Id: <1466021202-61880-25-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1466021202-61880-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1465222029-45942-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1466021202-61880-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, Andres Lagar-Cavilla <andreslc@google.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Ebru Akagunduz <ebru.akagunduz@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

For now, we would have HPAGE_PMD_NR entries in radix tree for every huge
page. That's suboptimal and it will be changed to use Matthew's
multi-order entries later.

'add' operation is not changed, because we don't need it to implement
hugetmpfs: shmem uses its own implementation.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/filemap.c | 178 ++++++++++++++++++++++++++++++++++++++++-------------------
 1 file changed, 122 insertions(+), 56 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 1efd2994dccf..21508ea25717 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -114,14 +114,14 @@ static void page_cache_tree_delete(struct address_space *mapping,
 				   struct page *page, void *shadow)
 {
 	struct radix_tree_node *node;
+	int i, nr = PageHuge(page) ? 1 : hpage_nr_pages(page);
 
-	VM_BUG_ON(!PageLocked(page));
-
-	node = radix_tree_replace_clear_tags(&mapping->page_tree, page->index,
-								shadow);
+	VM_BUG_ON_PAGE(!PageLocked(page), page);
+	VM_BUG_ON_PAGE(PageTail(page), page);
+	VM_BUG_ON_PAGE(nr != 1 && shadow, page);
 
 	if (shadow) {
-		mapping->nrexceptional++;
+		mapping->nrexceptional += nr;
 		/*
 		 * Make sure the nrexceptional update is committed before
 		 * the nrpages update so that final truncate racing
@@ -130,31 +130,38 @@ static void page_cache_tree_delete(struct address_space *mapping,
 		 */
 		smp_wmb();
 	}
-	mapping->nrpages--;
-
-	if (!node)
-		return;
+	mapping->nrpages -= nr;
 
-	workingset_node_pages_dec(node);
-	if (shadow)
-		workingset_node_shadows_inc(node);
-	else
-		if (__radix_tree_delete_node(&mapping->page_tree, node))
+	for (i = 0; i < nr; i++) {
+		node = radix_tree_replace_clear_tags(&mapping->page_tree,
+				page->index + i, shadow);
+		if (!node) {
+			VM_BUG_ON_PAGE(nr != 1, page);
 			return;
+		}
 
-	/*
-	 * Track node that only contains shadow entries. DAX mappings contain
-	 * no shadow entries and may contain other exceptional entries so skip
-	 * those.
-	 *
-	 * Avoid acquiring the list_lru lock if already tracked.  The
-	 * list_empty() test is safe as node->private_list is
-	 * protected by mapping->tree_lock.
-	 */
-	if (!dax_mapping(mapping) && !workingset_node_pages(node) &&
-	    list_empty(&node->private_list)) {
-		node->private_data = mapping;
-		list_lru_add(&workingset_shadow_nodes, &node->private_list);
+		workingset_node_pages_dec(node);
+		if (shadow)
+			workingset_node_shadows_inc(node);
+		else
+			if (__radix_tree_delete_node(&mapping->page_tree, node))
+				continue;
+
+		/*
+		 * Track node that only contains shadow entries. DAX mappings
+		 * contain no shadow entries and may contain other exceptional
+		 * entries so skip those.
+		 *
+		 * Avoid acquiring the list_lru lock if already tracked.
+		 * The list_empty() test is safe as node->private_list is
+		 * protected by mapping->tree_lock.
+		 */
+		if (!dax_mapping(mapping) && !workingset_node_pages(node) &&
+				list_empty(&node->private_list)) {
+			node->private_data = mapping;
+			list_lru_add(&workingset_shadow_nodes,
+					&node->private_list);
+		}
 	}
 }
 
@@ -166,6 +173,7 @@ static void page_cache_tree_delete(struct address_space *mapping,
 void __delete_from_page_cache(struct page *page, void *shadow)
 {
 	struct address_space *mapping = page->mapping;
+	int nr = hpage_nr_pages(page);
 
 	trace_mm_filemap_delete_from_page_cache(page);
 	/*
@@ -178,6 +186,7 @@ void __delete_from_page_cache(struct page *page, void *shadow)
 	else
 		cleancache_invalidate_page(mapping, page);
 
+	VM_BUG_ON_PAGE(PageTail(page), page);
 	VM_BUG_ON_PAGE(page_mapped(page), page);
 	if (!IS_ENABLED(CONFIG_DEBUG_VM) && unlikely(page_mapped(page))) {
 		int mapcount;
@@ -209,9 +218,9 @@ void __delete_from_page_cache(struct page *page, void *shadow)
 
 	/* hugetlb pages do not participate in page cache accounting. */
 	if (!PageHuge(page))
-		__dec_zone_page_state(page, NR_FILE_PAGES);
+		__mod_zone_page_state(page_zone(page), NR_FILE_PAGES, -nr);
 	if (PageSwapBacked(page))
-		__dec_zone_page_state(page, NR_SHMEM);
+		__mod_zone_page_state(page_zone(page), NR_SHMEM, -nr);
 
 	/*
 	 * At this point page must be either written or cleaned by truncate.
@@ -235,9 +244,8 @@ void __delete_from_page_cache(struct page *page, void *shadow)
  */
 void delete_from_page_cache(struct page *page)
 {
-	struct address_space *mapping = page->mapping;
+	struct address_space *mapping = page_mapping(page);
 	unsigned long flags;
-
 	void (*freepage)(struct page *);
 
 	BUG_ON(!PageLocked(page));
@@ -250,7 +258,13 @@ void delete_from_page_cache(struct page *page)
 
 	if (freepage)
 		freepage(page);
-	put_page(page);
+
+	if (PageTransHuge(page) && !PageHuge(page)) {
+		page_ref_sub(page, HPAGE_PMD_NR);
+		VM_BUG_ON_PAGE(page_count(page) <= 0, page);
+	} else {
+		put_page(page);
+	}
 }
 EXPORT_SYMBOL(delete_from_page_cache);
 
@@ -1053,7 +1067,7 @@ EXPORT_SYMBOL(page_cache_prev_hole);
 struct page *find_get_entry(struct address_space *mapping, pgoff_t offset)
 {
 	void **pagep;
-	struct page *page;
+	struct page *head, *page;
 
 	rcu_read_lock();
 repeat:
@@ -1073,8 +1087,16 @@ repeat:
 			 */
 			goto out;
 		}
-		if (!page_cache_get_speculative(page))
+
+		head = compound_head(page);
+		if (!page_cache_get_speculative(head))
+			goto repeat;
+
+		/* The page was split under us? */
+		if (compound_head(page) != head) {
+			put_page(head);
 			goto repeat;
+		}
 
 		/*
 		 * Has the page moved?
@@ -1082,7 +1104,7 @@ repeat:
 		 * include/linux/pagemap.h for details.
 		 */
 		if (unlikely(page != *pagep)) {
-			put_page(page);
+			put_page(head);
 			goto repeat;
 		}
 	}
@@ -1118,12 +1140,12 @@ repeat:
 	if (page && !radix_tree_exception(page)) {
 		lock_page(page);
 		/* Has the page been truncated? */
-		if (unlikely(page->mapping != mapping)) {
+		if (unlikely(page_mapping(page) != mapping)) {
 			unlock_page(page);
 			put_page(page);
 			goto repeat;
 		}
-		VM_BUG_ON_PAGE(page->index != offset, page);
+		VM_BUG_ON_PAGE(page_to_pgoff(page) != offset, page);
 	}
 	return page;
 }
@@ -1255,7 +1277,7 @@ unsigned find_get_entries(struct address_space *mapping,
 
 	rcu_read_lock();
 	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, start) {
-		struct page *page;
+		struct page *head, *page;
 repeat:
 		page = radix_tree_deref_slot(slot);
 		if (unlikely(!page))
@@ -1272,12 +1294,20 @@ repeat:
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
+			put_page(head);
 			goto repeat;
+		}
 
 		/* Has the page moved? */
 		if (unlikely(page != *slot)) {
-			put_page(page);
+			put_page(head);
 			goto repeat;
 		}
 export:
@@ -1318,7 +1348,7 @@ unsigned find_get_pages(struct address_space *mapping, pgoff_t start,
 
 	rcu_read_lock();
 	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, start) {
-		struct page *page;
+		struct page *head, *page;
 repeat:
 		page = radix_tree_deref_slot(slot);
 		if (unlikely(!page))
@@ -1337,12 +1367,19 @@ repeat:
 			continue;
 		}
 
-		if (!page_cache_get_speculative(page))
+		head = compound_head(page);
+		if (!page_cache_get_speculative(head))
+			goto repeat;
+
+		/* The page was split under us? */
+		if (compound_head(page) != head) {
+			put_page(head);
 			goto repeat;
+		}
 
 		/* Has the page moved? */
 		if (unlikely(page != *slot)) {
-			put_page(page);
+			put_page(head);
 			goto repeat;
 		}
 
@@ -1379,7 +1416,7 @@ unsigned find_get_pages_contig(struct address_space *mapping, pgoff_t index,
 
 	rcu_read_lock();
 	radix_tree_for_each_contig(slot, &mapping->page_tree, &iter, index) {
-		struct page *page;
+		struct page *head, *page;
 repeat:
 		page = radix_tree_deref_slot(slot);
 		/* The hole, there no reason to continue */
@@ -1399,12 +1436,19 @@ repeat:
 			break;
 		}
 
-		if (!page_cache_get_speculative(page))
+		head = compound_head(page);
+		if (!page_cache_get_speculative(head))
+			goto repeat;
+
+		/* The page was split under us? */
+		if (compound_head(page) != head) {
+			put_page(head);
 			goto repeat;
+		}
 
 		/* Has the page moved? */
 		if (unlikely(page != *slot)) {
-			put_page(page);
+			put_page(head);
 			goto repeat;
 		}
 
@@ -1413,7 +1457,7 @@ repeat:
 		 * otherwise we can get both false positives and false
 		 * negatives, which is just confusing to the caller.
 		 */
-		if (page->mapping == NULL || page->index != iter.index) {
+		if (page->mapping == NULL || page_to_pgoff(page) != iter.index) {
 			put_page(page);
 			break;
 		}
@@ -1451,7 +1495,7 @@ unsigned find_get_pages_tag(struct address_space *mapping, pgoff_t *index,
 	rcu_read_lock();
 	radix_tree_for_each_tagged(slot, &mapping->page_tree,
 				   &iter, *index, tag) {
-		struct page *page;
+		struct page *head, *page;
 repeat:
 		page = radix_tree_deref_slot(slot);
 		if (unlikely(!page))
@@ -1476,12 +1520,19 @@ repeat:
 			continue;
 		}
 
-		if (!page_cache_get_speculative(page))
+		head = compound_head(page);
+		if (!page_cache_get_speculative(head))
 			goto repeat;
 
+		/* The page was split under us? */
+		if (compound_head(page) != head) {
+			put_page(head);
+			goto repeat;
+		}
+
 		/* Has the page moved? */
 		if (unlikely(page != *slot)) {
-			put_page(page);
+			put_page(head);
 			goto repeat;
 		}
 
@@ -1525,7 +1576,7 @@ unsigned find_get_entries_tag(struct address_space *mapping, pgoff_t start,
 	rcu_read_lock();
 	radix_tree_for_each_tagged(slot, &mapping->page_tree,
 				   &iter, start, tag) {
-		struct page *page;
+		struct page *head, *page;
 repeat:
 		page = radix_tree_deref_slot(slot);
 		if (unlikely(!page))
@@ -1543,12 +1594,20 @@ repeat:
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
+			put_page(head);
+			goto repeat;
+		}
+
 		/* Has the page moved? */
 		if (unlikely(page != *slot)) {
-			put_page(page);
+			put_page(head);
 			goto repeat;
 		}
 export:
@@ -2137,7 +2196,7 @@ void filemap_map_pages(struct fault_env *fe,
 	struct address_space *mapping = file->f_mapping;
 	pgoff_t last_pgoff = start_pgoff;
 	loff_t size;
-	struct page *page;
+	struct page *head, *page;
 
 	rcu_read_lock();
 	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter,
@@ -2156,12 +2215,19 @@ repeat:
 			goto next;
 		}
 
-		if (!page_cache_get_speculative(page))
+		head = compound_head(page);
+		if (!page_cache_get_speculative(head))
 			goto repeat;
 
+		/* The page was split under us? */
+		if (compound_head(page) != head) {
+			put_page(head);
+			goto repeat;
+		}
+
 		/* Has the page moved? */
 		if (unlikely(page != *slot)) {
-			put_page(page);
+			put_page(head);
 			goto repeat;
 		}
 
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
