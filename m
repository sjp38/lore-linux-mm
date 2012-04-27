Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 930326B004A
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 06:58:03 -0400 (EDT)
Received: from euspt2 (mailout2.w1.samsung.com [210.118.77.12])
 by mailout2.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0M3400MOKX4JKZ@mailout2.w1.samsung.com> for linux-mm@kvack.org;
 Fri, 27 Apr 2012 11:57:55 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M3400HIZX4MIQ@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 27 Apr 2012 11:57:59 +0100 (BST)
Date: Fri, 27 Apr 2012 12:57:11 +0200
From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: [PATCH v4] mm: compaction: handle incorrect Unmovable type pageblocks
Message-id: <201204271257.11501.b.zolnierkie@samsung.com>
MIME-version: 1.0
Content-type: Text/Plain; charset=us-ascii
Content-transfer-encoding: 7BIT
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>

From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: [PATCH v4] mm: compaction: handle incorrect Unmovable type pageblocks

When Unmovable pages are freed from Unmovable type pageblock
(and some Movable type pages are left in it) waiting until
an allocation takes ownership of the block may take too long.
The type of the pageblock remains unchanged so the pageblock
cannot be used as a migration target during compaction.

Fix it by:

* Adding enum compact_mode (COMPACT_ASYNC_MOVABLE,
  COMPACT_ASYNC_UNMOVABLE and COMPACT_SYNC) and then converting
  sync field in struct compact_control to use it.

* Scanning the Unmovable pageblocks (during COMPACT_ASYNC_UNMOVABLE
  and COMPACT_SYNC compactions) and building a count based on
  finding PageBuddy pages, page_count(page) == 0 or PageLRU pages.
  If all pages within the Unmovable pageblock are in one of those
  three sets change the whole pageblock type to Movable.


My particular test case (on a ARM EXYNOS4 device with 512 MiB,
which means 131072 standard 4KiB pages in 'Normal' zone) is to:
- allocate 120000 pages for kernel's usage
- free every second page (60000 pages) of memory just allocated
- allocate and use 60000 pages from user space
- free remaining 60000 pages of kernel memory
(now we have fragmented memory occupied mostly by user space pages)
- try to allocate 100 order-9 (2048 KiB) pages for kernel's usage

The results:
- with compaction disabled I get 11 successful allocations
- with compaction enabled - 14 successful allocations
- with this patch I'm able to get all 100 successful allocations

Cc: Mel Gorman <mgorman@suse.de>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>
Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
v2: redo the patch basing on review from Mel Gorman
    (http://marc.info/?l=linux-mm&m=133519311025444&w=2)
v3: apply review comments from Minchan Kim
    (http://marc.info/?l=linux-mm&m=133531540308862&w=2)
v4: more review comments from Mel
    (http://marc.info/?l=linux-mm&m=133545110625042&w=2)

 include/linux/compaction.h |   23 +++++++++++--
 mm/compaction.c            |   79 +++++++++++++++++++++++++++++++++++----------
 mm/internal.h              |    6 ++-
 mm/page_alloc.c            |   40 ++++++++++++++--------
 4 files changed, 115 insertions(+), 33 deletions(-)

Index: b/include/linux/compaction.h
===================================================================
--- a/include/linux/compaction.h	2012-04-27 12:45:12.000000000 +0200
+++ b/include/linux/compaction.h	2012-04-27 12:47:54.402339068 +0200
@@ -1,6 +1,8 @@
 #ifndef _LINUX_COMPACTION_H
 #define _LINUX_COMPACTION_H
 
+#include <linux/node.h>
+
 /* Return values for compact_zone() and try_to_compact_pages() */
 /* compaction didn't start as it was not possible or direct reclaim was more suitable */
 #define COMPACT_SKIPPED		0
@@ -11,6 +13,23 @@
 /* The full zone was compacted */
 #define COMPACT_COMPLETE	3
 
+/*
+ * compaction supports three modes
+ *
+ * COMPACT_ASYNC_MOVABLE uses asynchronous migration and only scans
+ *    MIGRATE_MOVABLE pageblocks as migration sources and targets.
+ * COMPACT_ASYNC_UNMOVABLE uses asynchronous migration and only scans
+ *    MIGRATE_MOVABLE pageblocks as migration sources.
+ *    MIGRATE_UNMOVABLE pageblocks are scanned as potential migration
+ *    targets and convers them to MIGRATE_MOVABLE if possible
+ * COMPACT_SYNC uses synchronous migration and scans all pageblocks
+ */
+enum compact_mode {
+	COMPACT_ASYNC_MOVABLE,
+	COMPACT_ASYNC_UNMOVABLE,
+	COMPACT_SYNC,
+};
+
 #ifdef CONFIG_COMPACTION
 extern int sysctl_compact_memory;
 extern int sysctl_compaction_handler(struct ctl_table *table, int write,
@@ -22,7 +41,7 @@
 extern int fragmentation_index(struct zone *zone, unsigned int order);
 extern unsigned long try_to_compact_pages(struct zonelist *zonelist,
 			int order, gfp_t gfp_mask, nodemask_t *mask,
-			bool sync);
+			enum compact_mode mode);
 extern int compact_pgdat(pg_data_t *pgdat, int order);
 extern unsigned long compaction_suitable(struct zone *zone, int order);
 
@@ -64,7 +83,7 @@
 #else
 static inline unsigned long try_to_compact_pages(struct zonelist *zonelist,
 			int order, gfp_t gfp_mask, nodemask_t *nodemask,
-			bool sync)
+			enum compact_mode mode)
 {
 	return COMPACT_CONTINUE;
 }
Index: b/mm/compaction.c
===================================================================
--- a/mm/compaction.c	2012-04-27 12:45:14.000000000 +0200
+++ b/mm/compaction.c	2012-04-27 12:52:47.762338484 +0200
@@ -235,7 +235,7 @@
 	 */
 	while (unlikely(too_many_isolated(zone))) {
 		/* async migration should just abort */
-		if (!cc->sync)
+		if (cc->mode != COMPACT_SYNC)
 			return 0;
 
 		congestion_wait(BLK_RW_ASYNC, HZ/10);
@@ -303,7 +303,8 @@
 		 * satisfies the allocation
 		 */
 		pageblock_nr = low_pfn >> pageblock_order;
-		if (!cc->sync && last_pageblock_nr != pageblock_nr &&
+		if (cc->mode != COMPACT_SYNC &&
+		    last_pageblock_nr != pageblock_nr &&
 		    !migrate_async_suitable(get_pageblock_migratetype(page))) {
 			low_pfn += pageblock_nr_pages;
 			low_pfn = ALIGN(low_pfn, pageblock_nr_pages) - 1;
@@ -324,7 +325,7 @@
 			continue;
 		}
 
-		if (!cc->sync)
+		if (cc->mode != COMPACT_SYNC)
 			mode |= ISOLATE_ASYNC_MIGRATE;
 
 		/* Try isolate the page */
@@ -357,9 +358,48 @@
 
 #endif /* CONFIG_COMPACTION || CONFIG_CMA */
 #ifdef CONFIG_COMPACTION
+static bool rescue_unmovable_pageblock(struct page *page)
+{
+	unsigned long pfn, start_pfn, end_pfn;
+	struct page *start_page, *end_page;
+
+	pfn = page_to_pfn(page);
+	start_pfn = pfn & ~(pageblock_nr_pages - 1);
+	end_pfn = start_pfn + pageblock_nr_pages;
+
+	start_page = pfn_to_page(start_pfn);
+	end_page = pfn_to_page(end_pfn);
+
+	/* Do not deal with pageblocks that overlap zones */
+	if (page_zone(start_page) != page_zone(end_page))
+		return false;
+
+	for (page = start_page, pfn = start_pfn; page < end_page; pfn++,
+								  page++) {
+		if (!pfn_valid_within(pfn))
+			continue;
+
+		if (PageBuddy(page)) {
+			int order = page_order(page);
+
+			pfn += (1 << order) - 1;
+			page += (1 << order) - 1;
+
+			continue;
+		} else if (page_count(page) == 0 || PageLRU(page))
+			continue;
+
+		return false;
+	}
+
+	set_pageblock_migratetype(page, MIGRATE_MOVABLE);
+	move_freepages_block(page_zone(page), page, MIGRATE_MOVABLE);
+	return true;
+}
 
 /* Returns true if the page is within a block suitable for migration to */
-static bool suitable_migration_target(struct page *page)
+static bool suitable_migration_target(struct page *page,
+				      enum compact_mode mode)
 {
 
 	int migratetype = get_pageblock_migratetype(page);
@@ -373,7 +413,13 @@
 		return true;
 
 	/* If the block is MIGRATE_MOVABLE or MIGRATE_CMA, allow migration */
-	if (migrate_async_suitable(migratetype))
+	if (mode != COMPACT_ASYNC_UNMOVABLE &&
+	    migrate_async_suitable(migratetype))
+		return true;
+
+	if (mode != COMPACT_ASYNC_MOVABLE &&
+	    migratetype == MIGRATE_UNMOVABLE &&
+	    rescue_unmovable_pageblock(page))
 		return true;
 
 	/* Otherwise skip the block */
@@ -434,7 +480,7 @@
 			continue;
 
 		/* Check the block is suitable for migration */
-		if (!suitable_migration_target(page))
+		if (!suitable_migration_target(page, cc->mode))
 			continue;
 
 		/*
@@ -445,7 +491,7 @@
 		 */
 		isolated = 0;
 		spin_lock_irqsave(&zone->lock, flags);
-		if (suitable_migration_target(page)) {
+		if (suitable_migration_target(page, cc->mode)) {
 			end_pfn = min(pfn + pageblock_nr_pages, zone_end_pfn);
 			isolated = isolate_freepages_block(pfn, end_pfn,
 							   freelist, false);
@@ -682,8 +728,9 @@
 
 		nr_migrate = cc->nr_migratepages;
 		err = migrate_pages(&cc->migratepages, compaction_alloc,
-				(unsigned long)cc, false,
-				cc->sync ? MIGRATE_SYNC_LIGHT : MIGRATE_ASYNC);
+			(unsigned long)cc, false,
+			(cc->mode == COMPACT_SYNC) ? MIGRATE_SYNC_LIGHT
+						      : MIGRATE_ASYNC);
 		update_nr_listpages(cc);
 		nr_remaining = cc->nr_migratepages;
 
@@ -712,7 +759,7 @@
 
 static unsigned long compact_zone_order(struct zone *zone,
 				 int order, gfp_t gfp_mask,
-				 bool sync)
+				 enum compact_mode mode)
 {
 	struct compact_control cc = {
 		.nr_freepages = 0,
@@ -720,7 +767,7 @@
 		.order = order,
 		.migratetype = allocflags_to_migratetype(gfp_mask),
 		.zone = zone,
-		.sync = sync,
+		.mode = mode,
 	};
 	INIT_LIST_HEAD(&cc.freepages);
 	INIT_LIST_HEAD(&cc.migratepages);
@@ -742,7 +789,7 @@
  */
 unsigned long try_to_compact_pages(struct zonelist *zonelist,
 			int order, gfp_t gfp_mask, nodemask_t *nodemask,
-			bool sync)
+			enum compact_mode mode)
 {
 	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
 	int may_enter_fs = gfp_mask & __GFP_FS;
@@ -766,7 +813,7 @@
 								nodemask) {
 		int status;
 
-		status = compact_zone_order(zone, order, gfp_mask, sync);
+		status = compact_zone_order(zone, order, gfp_mask, mode);
 		rc = max(status, rc);
 
 		/* If a normal allocation would succeed, stop compacting */
@@ -805,7 +852,7 @@
 			if (ok && cc->order > zone->compact_order_failed)
 				zone->compact_order_failed = cc->order + 1;
 			/* Currently async compaction is never deferred. */
-			else if (!ok && cc->sync)
+			else if (!ok && cc->mode == COMPACT_SYNC)
 				defer_compaction(zone, cc->order);
 		}
 
@@ -820,7 +867,7 @@
 {
 	struct compact_control cc = {
 		.order = order,
-		.sync = false,
+		.mode = COMPACT_ASYNC_MOVABLE,
 	};
 
 	return __compact_pgdat(pgdat, &cc);
@@ -830,7 +877,7 @@
 {
 	struct compact_control cc = {
 		.order = -1,
-		.sync = true,
+		.mode = COMPACT_SYNC,
 	};
 
 	return __compact_pgdat(NODE_DATA(nid), &cc);
Index: b/mm/internal.h
===================================================================
--- a/mm/internal.h	2012-04-27 12:45:15.000000000 +0200
+++ b/mm/internal.h	2012-04-27 12:47:06.442339168 +0200
@@ -94,6 +94,9 @@
 /*
  * in mm/page_alloc.c
  */
+extern void set_pageblock_migratetype(struct page *page, int migratetype);
+extern int move_freepages_block(struct zone *zone, struct page *page,
+				int migratetype);
 extern void __free_pages_bootmem(struct page *page, unsigned int order);
 extern void prep_compound_page(struct page *page, unsigned long order);
 #ifdef CONFIG_MEMORY_FAILURE
@@ -101,6 +104,7 @@
 #endif
 
 #if defined CONFIG_COMPACTION || defined CONFIG_CMA
+#include <linux/compaction.h>
 
 /*
  * in mm/compaction.c
@@ -119,7 +123,7 @@
 	unsigned long nr_migratepages;	/* Number of pages to migrate */
 	unsigned long free_pfn;		/* isolate_freepages search base */
 	unsigned long migrate_pfn;	/* isolate_migratepages search base */
-	bool sync;			/* Synchronous migration */
+	enum compact_mode mode;		/* partial/full/sync compaction */
 
 	int order;			/* order a direct compactor needs */
 	int migratetype;		/* MOVABLE, RECLAIMABLE etc */
Index: b/mm/page_alloc.c
===================================================================
--- a/mm/page_alloc.c	2012-04-27 12:45:15.000000000 +0200
+++ b/mm/page_alloc.c	2012-04-27 12:49:36.738338868 +0200
@@ -219,7 +219,7 @@
 
 int page_group_by_mobility_disabled __read_mostly;
 
-static void set_pageblock_migratetype(struct page *page, int migratetype)
+void set_pageblock_migratetype(struct page *page, int migratetype)
 {
 
 	if (unlikely(page_group_by_mobility_disabled))
@@ -954,8 +954,8 @@
 	return pages_moved;
 }
 
-static int move_freepages_block(struct zone *zone, struct page *page,
-				int migratetype)
+int move_freepages_block(struct zone *zone, struct page *page,
+			 int migratetype)
 {
 	unsigned long start_pfn, end_pfn;
 	struct page *start_page, *end_page;
@@ -2061,7 +2061,7 @@
 __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 	struct zonelist *zonelist, enum zone_type high_zoneidx,
 	nodemask_t *nodemask, int alloc_flags, struct zone *preferred_zone,
-	int migratetype, bool sync_migration,
+	int migratetype, enum compact_mode migration_mode,
 	bool *deferred_compaction,
 	unsigned long *did_some_progress)
 {
@@ -2077,7 +2077,7 @@
 
 	current->flags |= PF_MEMALLOC;
 	*did_some_progress = try_to_compact_pages(zonelist, order, gfp_mask,
-						nodemask, sync_migration);
+						nodemask, migration_mode);
 	current->flags &= ~PF_MEMALLOC;
 	if (*did_some_progress != COMPACT_SKIPPED) {
 
@@ -2109,7 +2109,7 @@
 		 * As async compaction considers a subset of pageblocks, only
 		 * defer if the failure was a sync compaction failure.
 		 */
-		if (sync_migration)
+		if (migration_mode == COMPACT_SYNC)
 			defer_compaction(preferred_zone, order);
 
 		cond_resched();
@@ -2122,7 +2122,7 @@
 __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 	struct zonelist *zonelist, enum zone_type high_zoneidx,
 	nodemask_t *nodemask, int alloc_flags, struct zone *preferred_zone,
-	int migratetype, bool sync_migration,
+	int migratetype, enum compact_mode migration_mode,
 	bool *deferred_compaction,
 	unsigned long *did_some_progress)
 {
@@ -2285,7 +2285,7 @@
 	int alloc_flags;
 	unsigned long pages_reclaimed = 0;
 	unsigned long did_some_progress;
-	bool sync_migration = false;
+	enum compact_mode migration_mode = COMPACT_ASYNC_MOVABLE;
 	bool deferred_compaction = false;
 
 	/*
@@ -2360,19 +2360,31 @@
 		goto nopage;
 
 	/*
-	 * Try direct compaction. The first pass is asynchronous. Subsequent
-	 * attempts after direct reclaim are synchronous
+	 * Try direct compaction. The first and second pass are asynchronous.
+	 * Subsequent attempts after direct reclaim are synchronous.
 	 */
 	page = __alloc_pages_direct_compact(gfp_mask, order,
 					zonelist, high_zoneidx,
 					nodemask,
 					alloc_flags, preferred_zone,
-					migratetype, sync_migration,
+					migratetype, migration_mode,
 					&deferred_compaction,
 					&did_some_progress);
 	if (page)
 		goto got_pg;
-	sync_migration = true;
+
+	migration_mode = COMPACT_ASYNC_UNMOVABLE;
+	page = __alloc_pages_direct_compact(gfp_mask, order,
+					zonelist, high_zoneidx,
+					nodemask,
+					alloc_flags, preferred_zone,
+					migratetype, migration_mode,
+					&deferred_compaction,
+					&did_some_progress);
+	if (page)
+		goto got_pg;
+
+	migration_mode = COMPACT_SYNC;
 
 	/*
 	 * If compaction is deferred for high-order allocations, it is because
@@ -2450,7 +2462,7 @@
 					zonelist, high_zoneidx,
 					nodemask,
 					alloc_flags, preferred_zone,
-					migratetype, sync_migration,
+					migratetype, migration_mode,
 					&deferred_compaction,
 					&did_some_progress);
 		if (page)
@@ -5654,7 +5666,7 @@
 		.nr_migratepages = 0,
 		.order = -1,
 		.zone = page_zone(pfn_to_page(start)),
-		.sync = true,
+		.mode = COMPACT_SYNC,
 	};
 	INIT_LIST_HEAD(&cc.migratepages);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
