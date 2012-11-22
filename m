Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 32FBB8D0002
	for <linux-mm@kvack.org>; Thu, 22 Nov 2012 17:51:04 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so6043409eek.14
        for <linux-mm@kvack.org>; Thu, 22 Nov 2012 14:51:03 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 14/33] mm/migration: Improve migrate_misplaced_page()
Date: Thu, 22 Nov 2012 23:49:35 +0100
Message-Id: <1353624594-1118-15-git-send-email-mingo@kernel.org>
In-Reply-To: <1353624594-1118-1-git-send-email-mingo@kernel.org>
References: <1353624594-1118-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

From: Mel Gorman <mgorman@suse.de>

Fix, improve and clean up migrate_misplaced_page() to
reuse migrate_pages() and to check for zone watermarks
to make sure we don't overload the node.

This was originally based on Peter's patch "mm/migrate: Introduce
migrate_misplaced_page()" but borrows extremely heavily from Andrea's
"autonuma: memory follows CPU algorithm and task/mm_autonuma stats
collection".

Based-on-work-by: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Based-on-work-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Based-on-work-by: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Rik van Riel <riel@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Link: http://lkml.kernel.org/r/1353064973-26082-14-git-send-email-mgorman@suse.de
[ Adapted to the numa/core tree. Kept Mel's patch separate to retain
  original authorship for the authors. ]
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 include/linux/migrate_mode.h |   3 -
 mm/memory.c                  |  13 ++--
 mm/migrate.c                 | 143 +++++++++++++++++++++++++++----------------
 3 files changed, 95 insertions(+), 64 deletions(-)

diff --git a/include/linux/migrate_mode.h b/include/linux/migrate_mode.h
index 40b37dc..ebf3d89 100644
--- a/include/linux/migrate_mode.h
+++ b/include/linux/migrate_mode.h
@@ -6,14 +6,11 @@
  *	on most operations but not ->writepage as the potential stall time
  *	is too significant
  * MIGRATE_SYNC will block when migrating pages
- * MIGRATE_FAULT called from the fault path to migrate-on-fault for mempolicy
- *	this path has an extra reference count
  */
 enum migrate_mode {
 	MIGRATE_ASYNC,
 	MIGRATE_SYNC_LIGHT,
 	MIGRATE_SYNC,
-	MIGRATE_FAULT,
 };
 
 #endif		/* MIGRATE_MODE_H_INCLUDED */
diff --git a/mm/memory.c b/mm/memory.c
index 23ad2eb..52ad29d 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3492,28 +3492,25 @@ out_pte_upgrade_unlock:
 
 out_unlock:
 	pte_unmap_unlock(ptep, ptl);
-out:
+
 	if (page) {
 		task_numa_fault(page_nid, last_cpu, 1);
 		put_page(page);
 	}
-
+out:
 	return 0;
 
 migrate:
 	pte_unmap_unlock(ptep, ptl);
 
-	if (!migrate_misplaced_page(page, node)) {
-		page_nid = node;
+	if (migrate_misplaced_page(page, node)) {
 		goto out;
 	}
+	page = NULL;
 
 	ptep = pte_offset_map_lock(mm, pmd, address, &ptl);
-	if (!pte_same(*ptep, entry)) {
-		put_page(page);
-		page = NULL;
+	if (!pte_same(*ptep, entry))
 		goto out_unlock;
-	}
 
 	goto out_pte_upgrade_unlock;
 }
diff --git a/mm/migrate.c b/mm/migrate.c
index b89062d..16a4709 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -225,7 +225,7 @@ static bool buffer_migrate_lock_buffers(struct buffer_head *head,
 	struct buffer_head *bh = head;
 
 	/* Simple case, sync compaction */
-	if (mode != MIGRATE_ASYNC && mode != MIGRATE_FAULT) {
+	if (mode != MIGRATE_ASYNC) {
 		do {
 			get_bh(bh);
 			lock_buffer(bh);
@@ -282,19 +282,9 @@ static int migrate_page_move_mapping(struct address_space *mapping,
 	int expected_count = 0;
 	void **pslot;
 
-	if (mode == MIGRATE_FAULT) {
-		/*
-		 * MIGRATE_FAULT has an extra reference on the page and
-		 * otherwise acts like ASYNC, no point in delaying the
-		 * fault, we'll try again next time.
-		 */
-		expected_count++;
-	}
-
 	if (!mapping) {
 		/* Anonymous page without mapping */
-		expected_count += 1;
-		if (page_count(page) != expected_count)
+		if (page_count(page) != 1)
 			return -EAGAIN;
 		return 0;
 	}
@@ -304,7 +294,7 @@ static int migrate_page_move_mapping(struct address_space *mapping,
 	pslot = radix_tree_lookup_slot(&mapping->page_tree,
  					page_index(page));
 
-	expected_count += 2 + page_has_private(page);
+	expected_count = 2 + page_has_private(page);
 	if (page_count(page) != expected_count ||
 		radix_tree_deref_slot_protected(pslot, &mapping->tree_lock) != page) {
 		spin_unlock_irq(&mapping->tree_lock);
@@ -323,7 +313,7 @@ static int migrate_page_move_mapping(struct address_space *mapping,
 	 * the mapping back due to an elevated page count, we would have to
 	 * block waiting on other references to be dropped.
 	 */
-	if ((mode == MIGRATE_ASYNC || mode == MIGRATE_FAULT) && head &&
+	if (mode == MIGRATE_ASYNC && head &&
 			!buffer_migrate_lock_buffers(head, mode)) {
 		page_unfreeze_refs(page, expected_count);
 		spin_unlock_irq(&mapping->tree_lock);
@@ -531,7 +521,7 @@ int buffer_migrate_page(struct address_space *mapping,
 	 * with an IRQ-safe spinlock held. In the sync case, the buffers
 	 * need to be locked now
 	 */
-	if (mode != MIGRATE_ASYNC && mode != MIGRATE_FAULT)
+	if (mode != MIGRATE_ASYNC)
 		BUG_ON(!buffer_migrate_lock_buffers(head, mode));
 
 	ClearPagePrivate(page);
@@ -697,7 +687,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 	struct anon_vma *anon_vma = NULL;
 
 	if (!trylock_page(page)) {
-		if (!force || mode == MIGRATE_ASYNC || mode == MIGRATE_FAULT)
+		if (!force || mode == MIGRATE_ASYNC)
 			goto out;
 
 		/*
@@ -1415,55 +1405,102 @@ int migrate_vmas(struct mm_struct *mm, const nodemask_t *to,
 }
 
 /*
+ * Returns true if this is a safe migration target node for misplaced NUMA
+ * pages. Currently it only checks the watermarks which is a bit crude.
+ */
+static bool migrate_balanced_pgdat(struct pglist_data *pgdat,
+				   int nr_migrate_pages)
+{
+	int z;
+
+	for (z = pgdat->nr_zones - 1; z >= 0; z--) {
+		struct zone *zone = pgdat->node_zones + z;
+
+		if (!populated_zone(zone))
+			continue;
+
+		if (zone->all_unreclaimable)
+			continue;
+
+		/* Avoid waking kswapd by allocating pages_to_migrate pages. */
+		if (!zone_watermark_ok(zone, 0,
+				       high_wmark_pages(zone) +
+				       nr_migrate_pages,
+				       0, 0))
+			continue;
+		return true;
+	}
+	return false;
+}
+
+static struct page *alloc_misplaced_dst_page(struct page *page,
+					   unsigned long data,
+					   int **result)
+{
+	int nid = (int) data;
+	struct page *newpage;
+
+	newpage = alloc_pages_exact_node(nid,
+					 (GFP_HIGHUSER_MOVABLE | GFP_THISNODE |
+					  __GFP_NOMEMALLOC | __GFP_NORETRY |
+					  __GFP_NOWARN) &
+					 ~GFP_IOFS, 0);
+	return newpage;
+}
+
+/*
  * Attempt to migrate a misplaced page to the specified destination
- * node.
+ * node. Caller is expected to have an elevated reference count on
+ * the page that will be dropped by this function before returning.
  */
 int migrate_misplaced_page(struct page *page, int node)
 {
-	struct address_space *mapping = page_mapping(page);
-	int page_lru = page_is_file_cache(page);
-	struct page *newpage;
-	int ret = -EAGAIN;
-	gfp_t gfp = GFP_HIGHUSER_MOVABLE;
+	int isolated = 0;
+	LIST_HEAD(migratepages);
 
 	/*
-	 * Never wait for allocations just to migrate on fault, but don't dip
-	 * into reserves. And, only accept pages from the specified node. No
-	 * sense migrating to a different "misplaced" page!
+	 * Don't migrate pages that are mapped in multiple processes.
+	 * TODO: Handle false sharing detection instead of this hammer
 	 */
-	if (mapping)
-		gfp = mapping_gfp_mask(mapping);
-	gfp &= ~__GFP_WAIT;
-	gfp |= __GFP_NOMEMALLOC | GFP_THISNODE;
-
-	newpage = alloc_pages_node(node, gfp, 0);
-	if (!newpage) {
-		ret = -ENOMEM;
+	if (page_mapcount(page) != 1)
 		goto out;
-	}
 
-	if (isolate_lru_page(page)) {
-		ret = -EBUSY;
-		goto put_new;
+	/* Avoid migrating to a node that is nearly full */
+	if (migrate_balanced_pgdat(NODE_DATA(node), 1)) {
+		int page_lru;
+
+		if (isolate_lru_page(page)) {
+			put_page(page);
+			goto out;
+		}
+		isolated = 1;
+
+		/*
+		 * Page is isolated which takes a reference count so now the
+		 * callers reference can be safely dropped without the page
+		 * disappearing underneath us during migration
+		 */
+		put_page(page);
+
+		page_lru = page_is_file_cache(page);
+		inc_zone_page_state(page, NR_ISOLATED_ANON + page_lru);
+		list_add(&page->lru, &migratepages);
 	}
 
-	inc_zone_page_state(page, NR_ISOLATED_ANON + page_lru);
-	ret = __unmap_and_move(page, newpage, 0, 0, MIGRATE_FAULT);
-	/*
-	 * A page that has been migrated has all references removed and will be
-	 * freed. A page that has not been migrated will have kepts its
-	 * references and be restored.
-	 */
-	dec_zone_page_state(page, NR_ISOLATED_ANON + page_lru);
-	putback_lru_page(page);
-put_new:
-	/*
-	 * Move the new page to the LRU. If migration was not successful
-	 * then this will free the page.
-	 */
-	putback_lru_page(newpage);
+	if (isolated) {
+		int nr_remaining;
+
+		nr_remaining = migrate_pages(&migratepages,
+				alloc_misplaced_dst_page,
+				node, false, MIGRATE_ASYNC);
+		if (nr_remaining) {
+			putback_lru_pages(&migratepages);
+			isolated = 0;
+		}
+	}
+	BUG_ON(!list_empty(&migratepages));
 out:
-	return ret;
+	return isolated;
 }
 
 #endif /* CONFIG_NUMA */
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
