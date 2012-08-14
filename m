Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 85BC66B0044
	for <linux-mm@kvack.org>; Tue, 14 Aug 2012 12:41:38 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 3/5] mm: compaction: Capture a suitable high-order page immediately when it is made available
Date: Tue, 14 Aug 2012 17:41:30 +0100
Message-Id: <1344962492-1914-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1344962492-1914-1-git-send-email-mgorman@suse.de>
References: <1344962492-1914-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Jim Schutt <jaschut@sandia.gov>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

While compaction is migrating pages to free up large contiguous blocks for
allocation it races with other allocation requests that may steal these
blocks or break them up. This patch alters direct compaction to capture a
suitable free page as soon as it becomes available to reduce this race. It
uses similar logic to split_free_page() to ensure that watermarks are
still obeyed.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Rik van Riel <riel@redhat.com>
Reviewed-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/compaction.h |    4 +-
 include/linux/mm.h         |    1 +
 mm/compaction.c            |   88 ++++++++++++++++++++++++++++++++++++++------
 mm/internal.h              |    1 +
 mm/page_alloc.c            |   63 +++++++++++++++++++++++--------
 5 files changed, 128 insertions(+), 29 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index 133ddcf..fd20c15 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -22,7 +22,7 @@ extern int sysctl_extfrag_handler(struct ctl_table *table, int write,
 extern int fragmentation_index(struct zone *zone, unsigned int order);
 extern unsigned long try_to_compact_pages(struct zonelist *zonelist,
 			int order, gfp_t gfp_mask, nodemask_t *mask,
-			bool sync);
+			bool sync, struct page **page);
 extern int compact_pgdat(pg_data_t *pgdat, int order);
 extern unsigned long compaction_suitable(struct zone *zone, int order);
 
@@ -64,7 +64,7 @@ static inline bool compaction_deferred(struct zone *zone, int order)
 #else
 static inline unsigned long try_to_compact_pages(struct zonelist *zonelist,
 			int order, gfp_t gfp_mask, nodemask_t *nodemask,
-			bool sync)
+			bool sync, struct page **page)
 {
 	return COMPACT_CONTINUE;
 }
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0514fe9..5ddb11b 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -442,6 +442,7 @@ void put_pages_list(struct list_head *pages);
 
 void split_page(struct page *page, unsigned int order);
 int split_free_page(struct page *page);
+int capture_free_page(struct page *page, int alloc_order, int migratetype);
 
 /*
  * Compound pages have a destructor function.  Provide a
diff --git a/mm/compaction.c b/mm/compaction.c
index ea588eb..a806a9c 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -50,6 +50,59 @@ static inline bool migrate_async_suitable(int migratetype)
 	return is_migrate_cma(migratetype) || migratetype == MIGRATE_MOVABLE;
 }
 
+static void compact_capture_page(struct compact_control *cc)
+{
+	unsigned long flags;
+	int mtype, mtype_low, mtype_high;
+
+	if (!cc->page || *cc->page)
+		return;
+
+	/*
+	 * For MIGRATE_MOVABLE allocations we capture a suitable page ASAP
+	 * regardless of the migratetype of the freelist is is captured from.
+	 * This is fine because the order for a high-order MIGRATE_MOVABLE
+	 * allocation is typically at least a pageblock size and overall
+	 * fragmentation is not impaired. Other allocation types must
+	 * capture pages from their own migratelist because otherwise they
+	 * could pollute other pageblocks like MIGRATE_MOVABLE with
+	 * difficult to move pages and making fragmentation worse overall.
+	 */
+	if (cc->migratetype == MIGRATE_MOVABLE) {
+		mtype_low = 0;
+		mtype_high = MIGRATE_PCPTYPES;
+	} else {
+		mtype_low = cc->migratetype;
+		mtype_high = cc->migratetype + 1;
+	}
+
+	/* Speculatively examine the free lists without zone lock */
+	for (mtype = mtype_low; mtype < mtype_high; mtype++) {
+		int order;
+		for (order = cc->order; order < MAX_ORDER; order++) {
+			struct page *page;
+			struct free_area *area;
+			area = &(cc->zone->free_area[order]);
+			if (list_empty(&area->free_list[mtype]))
+				continue;
+
+			/* Take the lock and attempt capture of the page */
+			spin_lock_irqsave(&cc->zone->lock, flags);
+			if (!list_empty(&area->free_list[mtype])) {
+				page = list_entry(area->free_list[mtype].next,
+							struct page, lru);
+				if (capture_free_page(page, cc->order, mtype)) {
+					spin_unlock_irqrestore(&cc->zone->lock,
+									flags);
+					*cc->page = page;
+					return;
+				}
+			}
+			spin_unlock_irqrestore(&cc->zone->lock, flags);
+		}
+	}
+}
+
 /*
  * Isolate free pages onto a private freelist. Caller must hold zone->lock.
  * If @strict is true, will abort returning 0 on any invalid PFNs or non-free
@@ -589,7 +642,6 @@ static unsigned long start_free_pfn(struct zone *zone)
 static int compact_finished(struct zone *zone,
 			    struct compact_control *cc)
 {
-	unsigned int order;
 	unsigned long watermark;
 
 	if (fatal_signal_pending(current))
@@ -632,14 +684,22 @@ static int compact_finished(struct zone *zone,
 		return COMPACT_CONTINUE;
 
 	/* Direct compactor: Is a suitable page free? */
-	for (order = cc->order; order < MAX_ORDER; order++) {
-		/* Job done if page is free of the right migratetype */
-		if (!list_empty(&zone->free_area[order].free_list[cc->migratetype]))
-			return COMPACT_PARTIAL;
-
-		/* Job done if allocation would set block type */
-		if (order >= pageblock_order && zone->free_area[order].nr_free)
+	if (cc->page) {
+		/* Was a suitable page captured? */
+		if (*cc->page)
 			return COMPACT_PARTIAL;
+	} else {
+		unsigned int order;
+		for (order = cc->order; order < MAX_ORDER; order++) {
+			struct free_area *area = &zone->free_area[cc->order];
+			/* Job done if page is free of the right migratetype */
+			if (!list_empty(&area->free_list[cc->migratetype]))
+				return COMPACT_PARTIAL;
+
+			/* Job done if allocation would set block type */
+			if (cc->order >= pageblock_order && area->nr_free)
+				return COMPACT_PARTIAL;
+		}
 	}
 
 	return COMPACT_CONTINUE;
@@ -761,6 +821,9 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 				goto out;
 			}
 		}
+
+		/* Capture a page now if it is a suitable size */
+		compact_capture_page(cc);
 	}
 
 out:
@@ -773,7 +836,7 @@ out:
 
 static unsigned long compact_zone_order(struct zone *zone,
 				 int order, gfp_t gfp_mask,
-				 bool sync)
+				 bool sync, struct page **page)
 {
 	struct compact_control cc = {
 		.nr_freepages = 0,
@@ -782,6 +845,7 @@ static unsigned long compact_zone_order(struct zone *zone,
 		.migratetype = allocflags_to_migratetype(gfp_mask),
 		.zone = zone,
 		.sync = sync,
+		.page = page,
 	};
 	INIT_LIST_HEAD(&cc.freepages);
 	INIT_LIST_HEAD(&cc.migratepages);
@@ -803,7 +867,7 @@ int sysctl_extfrag_threshold = 500;
  */
 unsigned long try_to_compact_pages(struct zonelist *zonelist,
 			int order, gfp_t gfp_mask, nodemask_t *nodemask,
-			bool sync)
+			bool sync, struct page **page)
 {
 	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
 	int may_enter_fs = gfp_mask & __GFP_FS;
@@ -823,7 +887,7 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
 								nodemask) {
 		int status;
 
-		status = compact_zone_order(zone, order, gfp_mask, sync);
+		status = compact_zone_order(zone, order, gfp_mask, sync, page);
 		rc = max(status, rc);
 
 		/* If a normal allocation would succeed, stop compacting */
@@ -878,6 +942,7 @@ int compact_pgdat(pg_data_t *pgdat, int order)
 	struct compact_control cc = {
 		.order = order,
 		.sync = false,
+		.page = NULL,
 	};
 
 	return __compact_pgdat(pgdat, &cc);
@@ -888,6 +953,7 @@ static int compact_node(int nid)
 	struct compact_control cc = {
 		.order = -1,
 		.sync = true,
+		.page = NULL,
 	};
 
 	return __compact_pgdat(NODE_DATA(nid), &cc);
diff --git a/mm/internal.h b/mm/internal.h
index 3314f79..b03f05e 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -130,6 +130,7 @@ struct compact_control {
 	int order;			/* order a direct compactor needs */
 	int migratetype;		/* MOVABLE, RECLAIMABLE etc */
 	struct zone *zone;
+	struct page **page;		/* Page captured of requested size */
 };
 
 unsigned long
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index cefac39..d1759f5 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1379,16 +1379,11 @@ void split_page(struct page *page, unsigned int order)
 }
 
 /*
- * Similar to split_page except the page is already free. As this is only
- * being used for migration, the migratetype of the block also changes.
- * As this is called with interrupts disabled, the caller is responsible
- * for calling arch_alloc_page() and kernel_map_page() after interrupts
- * are enabled.
- *
- * Note: this is probably too low level an operation for use in drivers.
- * Please consult with lkml before using this in your driver.
+ * Similar to the split_page family of functions except that the page
+ * required at the given order and being isolated now to prevent races
+ * with parallel allocators
  */
-int split_free_page(struct page *page)
+int capture_free_page(struct page *page, int alloc_order, int migratetype)
 {
 	unsigned int order;
 	unsigned long watermark;
@@ -1410,10 +1405,11 @@ int split_free_page(struct page *page)
 	rmv_page_order(page);
 	__mod_zone_page_state(zone, NR_FREE_PAGES, -(1UL << order));
 
-	/* Split into individual pages */
-	set_page_refcounted(page);
-	split_page(page, order);
+	if (alloc_order != order)
+		expand(zone, page, alloc_order, order,
+			&zone->free_area[order], migratetype);
 
+	/* Set the pageblock if the captured page is at least a pageblock */
 	if (order >= pageblock_order - 1) {
 		struct page *endpage = page + (1 << order) - 1;
 		for (; page < endpage; page += pageblock_nr_pages) {
@@ -1424,7 +1420,35 @@ int split_free_page(struct page *page)
 		}
 	}
 
-	return 1 << order;
+	return 1UL << order;
+}
+
+/*
+ * Similar to split_page except the page is already free. As this is only
+ * being used for migration, the migratetype of the block also changes.
+ * As this is called with interrupts disabled, the caller is responsible
+ * for calling arch_alloc_page() and kernel_map_page() after interrupts
+ * are enabled.
+ *
+ * Note: this is probably too low level an operation for use in drivers.
+ * Please consult with lkml before using this in your driver.
+ */
+int split_free_page(struct page *page)
+{
+	unsigned int order;
+	int nr_pages;
+
+	BUG_ON(!PageBuddy(page));
+	order = page_order(page);
+
+	nr_pages = capture_free_page(page, order, 0);
+	if (!nr_pages)
+		return 0;
+
+	/* Split into individual pages */
+	set_page_refcounted(page);
+	split_page(page, order);
+	return nr_pages;
 }
 
 /*
@@ -2093,7 +2117,7 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 	bool *deferred_compaction,
 	unsigned long *did_some_progress)
 {
-	struct page *page;
+	struct page *page = NULL;
 
 	if (!order)
 		return NULL;
@@ -2105,10 +2129,16 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 
 	current->flags |= PF_MEMALLOC;
 	*did_some_progress = try_to_compact_pages(zonelist, order, gfp_mask,
-						nodemask, sync_migration);
+					nodemask, sync_migration, &page);
 	current->flags &= ~PF_MEMALLOC;
-	if (*did_some_progress != COMPACT_SKIPPED) {
 
+	/* If compaction captured a page, prep and use it */
+	if (page) {
+		prep_new_page(page, order, gfp_mask);
+		goto got_page;
+	}
+
+	if (*did_some_progress != COMPACT_SKIPPED) {
 		/* Page migration frees to the PCP lists but we want merging */
 		drain_pages(get_cpu());
 		put_cpu();
@@ -2118,6 +2148,7 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 				alloc_flags & ~ALLOC_NO_WATERMARKS,
 				preferred_zone, migratetype);
 		if (page) {
+got_page:
 			preferred_zone->compact_considered = 0;
 			preferred_zone->compact_defer_shift = 0;
 			if (order >= preferred_zone->compact_order_failed)
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
