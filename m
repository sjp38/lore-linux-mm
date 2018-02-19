Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 683EF6B029D
	for <linux-mm@kvack.org>; Mon, 19 Feb 2018 14:46:27 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id m22so3695846pfg.15
        for <linux-mm@kvack.org>; Mon, 19 Feb 2018 11:46:27 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b11si339761pgr.612.2018.02.19.11.46.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 19 Feb 2018 11:46:26 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v7 41/61] mm: Convert collapse_shmem to XArray
Date: Mon, 19 Feb 2018 11:45:36 -0800
Message-Id: <20180219194556.6575-42-willy@infradead.org>
In-Reply-To: <20180219194556.6575-1-willy@infradead.org>
References: <20180219194556.6575-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

I found another victim of the radix tree being hard to use.  Because
there was no call to radix_tree_preload(), khugepaged was allocating
radix_tree_nodes using GFP_ATOMIC.

I also converted a local_irq_save()/restore() pair to
disable()/enable().

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 mm/khugepaged.c | 158 +++++++++++++++++++++++---------------------------------
 1 file changed, 65 insertions(+), 93 deletions(-)

diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index 70e10c1f3127..a1b1a714aff9 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -1282,17 +1282,17 @@ static void retract_page_tables(struct address_space *mapping, pgoff_t pgoff)
  *
  * Basic scheme is simple, details are more complex:
  *  - allocate and freeze a new huge page;
- *  - scan over radix tree replacing old pages the new one
+ *  - scan page cache replacing old pages with the new one
  *    + swap in pages if necessary;
  *    + fill in gaps;
- *    + keep old pages around in case if rollback is required;
- *  - if replacing succeed:
+ *    + keep old pages around in case rollback is required;
+ *  - if replacing succeeds:
  *    + copy data over;
  *    + free old pages;
  *    + unfreeze huge page;
  *  - if replacing failed;
  *    + put all pages back and unfreeze them;
- *    + restore gaps in the radix-tree;
+ *    + restore gaps in the page cache;
  *    + free huge page;
  */
 static void collapse_shmem(struct mm_struct *mm,
@@ -1300,12 +1300,11 @@ static void collapse_shmem(struct mm_struct *mm,
 		struct page **hpage, int node)
 {
 	gfp_t gfp;
-	struct page *page, *new_page, *tmp;
+	struct page *new_page;
 	struct mem_cgroup *memcg;
 	pgoff_t index, end = start + HPAGE_PMD_NR;
 	LIST_HEAD(pagelist);
-	struct radix_tree_iter iter;
-	void **slot;
+	XA_STATE(xas, &mapping->pages, start);
 	int nr_none = 0, result = SCAN_SUCCEED;
 
 	VM_BUG_ON(start & (HPAGE_PMD_NR - 1));
@@ -1330,48 +1329,48 @@ static void collapse_shmem(struct mm_struct *mm,
 	__SetPageLocked(new_page);
 	BUG_ON(!page_ref_freeze(new_page, 1));
 
-
 	/*
-	 * At this point the new_page is 'frozen' (page_count() is zero), locked
-	 * and not up-to-date. It's safe to insert it into radix tree, because
-	 * nobody would be able to map it or use it in other way until we
-	 * unfreeze it.
+	 * At this point the new_page is 'frozen' (page_count() is zero),
+	 * locked and not up-to-date. It's safe to insert it into the page
+	 * cache, because nobody would be able to map it or use it in other
+	 * way until we unfreeze it.
 	 */
 
-	index = start;
-	xa_lock_irq(&mapping->pages);
-	radix_tree_for_each_slot(slot, &mapping->pages, &iter, start) {
-		int n = min(iter.index, end) - index;
-
-		/*
-		 * Handle holes in the radix tree: charge it from shmem and
-		 * insert relevant subpage of new_page into the radix-tree.
-		 */
-		if (n && !shmem_charge(mapping->host, n)) {
-			result = SCAN_FAIL;
+	/* This will be less messy when we use multi-index entries */
+	do {
+		xas_lock_irq(&xas);
+		xas_create_range(&xas, end - 1);
+		if (!xas_error(&xas))
 			break;
-		}
-		nr_none += n;
-		for (; index < min(iter.index, end); index++) {
-			radix_tree_insert(&mapping->pages, index,
-					new_page + (index % HPAGE_PMD_NR));
-		}
+		xas_unlock_irq(&xas);
+		if (!xas_nomem(&xas, GFP_KERNEL))
+			goto out;
+	} while (1);
 
-		/* We are done. */
-		if (index >= end)
-			break;
+	for (index = start; index < end; index++) {
+		struct page *page = xas_next(&xas);
+
+		VM_BUG_ON(index != xas.xa_index);
+		if (!page) {
+			if (!shmem_charge(mapping->host, 1)) {
+				result = SCAN_FAIL;
+				break;
+			}
+			xas_store(&xas, new_page + (index % HPAGE_PMD_NR));
+			nr_none++;
+			continue;
+		}
 
-		page = radix_tree_deref_slot_protected(slot,
-				&mapping->pages.xa_lock);
 		if (xa_is_value(page) || !PageUptodate(page)) {
-			xa_unlock_irq(&mapping->pages);
+			xas_unlock_irq(&xas);
 			/* swap in or instantiate fallocated page */
 			if (shmem_getpage(mapping->host, index, &page,
 						SGP_NOHUGE)) {
 				result = SCAN_FAIL;
-				goto tree_unlocked;
+				goto xa_unlocked;
 			}
-			xa_lock_irq(&mapping->pages);
+			xas_lock_irq(&xas);
+			xas_set(&xas, index);
 		} else if (trylock_page(page)) {
 			get_page(page);
 		} else {
@@ -1391,7 +1390,7 @@ static void collapse_shmem(struct mm_struct *mm,
 			result = SCAN_TRUNCATED;
 			goto out_unlock;
 		}
-		xa_unlock_irq(&mapping->pages);
+		xas_unlock_irq(&xas);
 
 		if (isolate_lru_page(page)) {
 			result = SCAN_DEL_PAGE_LRU;
@@ -1401,17 +1400,16 @@ static void collapse_shmem(struct mm_struct *mm,
 		if (page_mapped(page))
 			unmap_mapping_pages(mapping, index, 1, false);
 
-		xa_lock_irq(&mapping->pages);
+		xas_lock(&xas);
+		xas_set(&xas, index);
 
-		slot = radix_tree_lookup_slot(&mapping->pages, index);
-		VM_BUG_ON_PAGE(page != radix_tree_deref_slot_protected(slot,
-					&mapping->pages.xa_lock), page);
+		VM_BUG_ON_PAGE(page != xas_load(&xas), page);
 		VM_BUG_ON_PAGE(page_mapped(page), page);
 
 		/*
 		 * The page is expected to have page_count() == 3:
 		 *  - we hold a pin on it;
-		 *  - one reference from radix tree;
+		 *  - one reference from page cache;
 		 *  - one from isolate_lru_page;
 		 */
 		if (!page_ref_freeze(page, 3)) {
@@ -1426,56 +1424,30 @@ static void collapse_shmem(struct mm_struct *mm,
 		list_add_tail(&page->lru, &pagelist);
 
 		/* Finally, replace with the new page. */
-		radix_tree_replace_slot(&mapping->pages, slot,
-				new_page + (index % HPAGE_PMD_NR));
-
-		slot = radix_tree_iter_resume(slot, &iter);
-		index++;
+		xas_store(&xas, new_page + (index % HPAGE_PMD_NR));
 		continue;
 out_lru:
-		xa_unlock_irq(&mapping->pages);
+		xas_unlock_irq(&xas);
 		putback_lru_page(page);
 out_isolate_failed:
 		unlock_page(page);
 		put_page(page);
-		goto tree_unlocked;
+		goto xa_unlocked;
 out_unlock:
 		unlock_page(page);
 		put_page(page);
 		break;
 	}
+	xas_unlock_irq(&xas);
 
-	/*
-	 * Handle hole in radix tree at the end of the range.
-	 * This code only triggers if there's nothing in radix tree
-	 * beyond 'end'.
-	 */
-	if (result == SCAN_SUCCEED && index < end) {
-		int n = end - index;
-
-		if (!shmem_charge(mapping->host, n)) {
-			result = SCAN_FAIL;
-			goto tree_locked;
-		}
-
-		for (; index < end; index++) {
-			radix_tree_insert(&mapping->pages, index,
-					new_page + (index % HPAGE_PMD_NR));
-		}
-		nr_none += n;
-	}
-
-tree_locked:
-	xa_unlock_irq(&mapping->pages);
-tree_unlocked:
-
+xa_unlocked:
 	if (result == SCAN_SUCCEED) {
-		unsigned long flags;
+		struct page *page, *tmp;
 		struct zone *zone = page_zone(new_page);
 
 		/*
-		 * Replacing old pages with new one has succeed, now we need to
-		 * copy the content and free old pages.
+		 * Replacing old pages with new one has succeeded, now we
+		 * need to copy the content and free the old pages.
 		 */
 		list_for_each_entry_safe(page, tmp, &pagelist, lru) {
 			copy_highpage(new_page + (page->index % HPAGE_PMD_NR),
@@ -1489,16 +1461,16 @@ static void collapse_shmem(struct mm_struct *mm,
 			put_page(page);
 		}
 
-		local_irq_save(flags);
+		local_irq_disable();
 		__inc_node_page_state(new_page, NR_SHMEM_THPS);
 		if (nr_none) {
 			__mod_node_page_state(zone->zone_pgdat, NR_FILE_PAGES, nr_none);
 			__mod_node_page_state(zone->zone_pgdat, NR_SHMEM, nr_none);
 		}
-		local_irq_restore(flags);
+		local_irq_enable();
 
 		/*
-		 * Remove pte page tables, so we can re-faulti
+		 * Remove pte page tables, so we can re-fault
 		 * the page as huge.
 		 */
 		retract_page_tables(mapping, start);
@@ -1513,37 +1485,37 @@ static void collapse_shmem(struct mm_struct *mm,
 
 		*hpage = NULL;
 	} else {
-		/* Something went wrong: rollback changes to the radix-tree */
+		struct page *page;
+		/* Something went wrong: roll back page cache changes */
 		shmem_uncharge(mapping->host, nr_none);
-		xa_lock_irq(&mapping->pages);
-		radix_tree_for_each_slot(slot, &mapping->pages, &iter, start) {
-			if (iter.index >= end)
-				break;
+		xas_lock_irq(&xas);
+		xas_set(&xas, start);
+		xas_for_each(&xas, page, end - 1) {
 			page = list_first_entry_or_null(&pagelist,
 					struct page, lru);
-			if (!page || iter.index < page->index) {
+			if (!page || xas.xa_index < page->index) {
 				if (!nr_none)
 					break;
 				nr_none--;
 				/* Put holes back where they were */
-				radix_tree_delete(&mapping->pages, iter.index);
+				xas_store(&xas, NULL);
 				continue;
 			}
 
-			VM_BUG_ON_PAGE(page->index != iter.index, page);
+			VM_BUG_ON_PAGE(page->index != xas.xa_index, page);
 
 			/* Unfreeze the page. */
 			list_del(&page->lru);
 			page_ref_unfreeze(page, 2);
-			radix_tree_replace_slot(&mapping->pages, slot, page);
-			slot = radix_tree_iter_resume(slot, &iter);
-			xa_unlock_irq(&mapping->pages);
+			xas_store(&xas, page);
+			xas_pause(&xas);
+			xas_unlock_irq(&xas);
 			putback_lru_page(page);
 			unlock_page(page);
-			xa_lock_irq(&mapping->pages);
+			xas_lock_irq(&xas);
 		}
 		VM_BUG_ON(nr_none);
-		xa_unlock_irq(&mapping->pages);
+		xas_unlock_irq(&xas);
 
 		/* Unfreeze new_page, caller would take care about freeing it */
 		page_ref_unfreeze(new_page, 1);
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
