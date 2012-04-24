Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 6EC356B0044
	for <linux-mm@kvack.org>; Tue, 24 Apr 2012 08:09:10 -0400 (EDT)
Received: from euspt2 (mailout2.w1.samsung.com [210.118.77.12])
 by mailout2.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0M2Z002TRGF1NL@mailout2.w1.samsung.com> for linux-mm@kvack.org;
 Tue, 24 Apr 2012 13:09:01 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M2Z00L9NGF5MW@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 24 Apr 2012 13:09:05 +0100 (BST)
Date: Tue, 24 Apr 2012 14:05:07 +0200
From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: [PATCH v2] mm: compaction: handle incorrect Unmovable type pageblocks
Message-id: <201204241405.07596.b.zolnierkie@samsung.com>
MIME-version: 1.0
Content-type: Text/Plain; charset=us-ascii
Content-transfer-encoding: 7BIT
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Mel Gorman <mgorman@suse.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>

From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: [PATCH v2] mm: compaction: handle incorrect Unmovable type pageblocks

When Unmovable pages are freed from Unmovable type pageblock
(and some Movable type pages are left in it) the type of
the pageblock remains unchanged and therefore the pageblock
cannot be used as a migration target during compaction.

Fix it by:

* Adding enum compaction_type (COMPACTION_ASYNC_PARTIAL,
  COMPACTION_ASYNC_FULL and COMPACTION_SYNC) and then converting
  sync field in struct compact_control to use it.

* Scanning the Unmovable pageblocks (during COMPACTION_ASYNC_FULL
  and COMPACTION_SYNC compactions) and building a count based on
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
Cc: Marek Szyprowski <m.szyprowski@samsung.com>
Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
v2: redo the patch basing on review from Mel Gorman.

 include/linux/compaction.h |   12 ++++++--
 mm/compaction.c            |   65 ++++++++++++++++++++++++++++++++++++---------
 mm/internal.h              |    6 +++-
 mm/page_alloc.c            |   18 ++++++------
 4 files changed, 77 insertions(+), 24 deletions(-)

Index: b/include/linux/compaction.h
===================================================================
--- a/include/linux/compaction.h	2012-04-24 13:36:36.000000000 +0200
+++ b/include/linux/compaction.h	2012-04-24 13:48:05.180421908 +0200
@@ -1,6 +1,8 @@
 #ifndef _LINUX_COMPACTION_H
 #define _LINUX_COMPACTION_H
 
+#include <linux/node.h>
+
 /* Return values for compact_zone() and try_to_compact_pages() */
 /* compaction didn't start as it was not possible or direct reclaim was more suitable */
 #define COMPACT_SKIPPED		0
@@ -11,6 +13,12 @@
 /* The full zone was compacted */
 #define COMPACT_COMPLETE	3
 
+enum compaction_type {
+	COMPACTION_ASYNC_PARTIAL,
+	COMPACTION_ASYNC_FULL,
+	COMPACTION_SYNC,
+};
+
 #ifdef CONFIG_COMPACTION
 extern int sysctl_compact_memory;
 extern int sysctl_compaction_handler(struct ctl_table *table, int write,
@@ -22,7 +30,7 @@
 extern int fragmentation_index(struct zone *zone, unsigned int order);
 extern unsigned long try_to_compact_pages(struct zonelist *zonelist,
 			int order, gfp_t gfp_mask, nodemask_t *mask,
-			bool sync);
+			enum compaction_type sync);
 extern int compact_pgdat(pg_data_t *pgdat, int order);
 extern unsigned long compaction_suitable(struct zone *zone, int order);
 
@@ -64,7 +72,7 @@
 #else
 static inline unsigned long try_to_compact_pages(struct zonelist *zonelist,
 			int order, gfp_t gfp_mask, nodemask_t *nodemask,
-			bool sync)
+			enum compaction_type sync)
 {
 	return COMPACT_CONTINUE;
 }
Index: b/mm/compaction.c
===================================================================
--- a/mm/compaction.c	2012-04-24 13:47:06.000000000 +0200
+++ b/mm/compaction.c	2012-04-24 13:51:06.760421886 +0200
@@ -235,7 +235,8 @@
 	 */
 	while (unlikely(too_many_isolated(zone))) {
 		/* async migration should just abort */
-		if (!cc->sync)
+		if (cc->sync == COMPACTION_ASYNC_PARTIAL ||
+		    cc->sync == COMPACTION_ASYNC_FULL)
 			return 0;
 
 		congestion_wait(BLK_RW_ASYNC, HZ/10);
@@ -303,7 +304,9 @@
 		 * satisfies the allocation
 		 */
 		pageblock_nr = low_pfn >> pageblock_order;
-		if (!cc->sync && last_pageblock_nr != pageblock_nr &&
+		if ((cc->sync == COMPACTION_ASYNC_PARTIAL ||
+		     cc->sync == COMPACTION_ASYNC_FULL) &&
+		    last_pageblock_nr != pageblock_nr &&
 		    !migrate_async_suitable(get_pageblock_migratetype(page))) {
 			low_pfn += pageblock_nr_pages;
 			low_pfn = ALIGN(low_pfn, pageblock_nr_pages) - 1;
@@ -324,7 +327,8 @@
 			continue;
 		}
 
-		if (!cc->sync)
+		if (cc->sync == COMPACTION_ASYNC_PARTIAL ||
+		    cc->sync == COMPACTION_ASYNC_FULL)
 			mode |= ISOLATE_ASYNC_MIGRATE;
 
 		/* Try isolate the page */
@@ -357,9 +361,39 @@
 
 #endif /* CONFIG_COMPACTION || CONFIG_CMA */
 #ifdef CONFIG_COMPACTION
+static bool convert_unmovable_pageblock(struct page *page)
+{
+	unsigned long pfn, start_pfn, end_pfn;
+	int i = 0;
+
+	pfn = page_to_pfn(page);
+	start_pfn = pfn & ~(pageblock_nr_pages - 1);
+	end_pfn = start_pfn + pageblock_nr_pages;
+
+	for (pfn = start_pfn; pfn < end_pfn; pfn++) {
+		page = pfn_to_page(pfn);
+
+		if (PageBuddy(page)) {
+			int order = page_order(page);
+
+			i += (1 << order);
+			pfn += ((1 << order) - 1);
+		} else if (page_count(page) == 0 || PageLRU(page))
+			i++;
+	}
+
+	if (i == pageblock_nr_pages) {
+		set_pageblock_migratetype(page, MIGRATE_MOVABLE);
+		move_freepages_block(page_zone(page), page, MIGRATE_MOVABLE);
+		return true;
+	}
+
+	return false;
+}
 
 /* Returns true if the page is within a block suitable for migration to */
-static bool suitable_migration_target(struct page *page)
+static bool suitable_migration_target(struct page *page,
+				      struct compact_control *cc)
 {
 
 	int migratetype = get_pageblock_migratetype(page);
@@ -376,6 +410,12 @@
 	if (migrate_async_suitable(migratetype))
 		return true;
 
+	if ((cc->sync == COMPACTION_ASYNC_FULL ||
+	     cc->sync == COMPACTION_SYNC) &&
+	    migratetype == MIGRATE_UNMOVABLE &&
+	    convert_unmovable_pageblock(page))
+		return true;
+
 	/* Otherwise skip the block */
 	return false;
 }
@@ -434,7 +474,7 @@
 			continue;
 
 		/* Check the block is suitable for migration */
-		if (!suitable_migration_target(page))
+		if (!suitable_migration_target(page, cc))
 			continue;
 
 		/*
@@ -445,7 +485,7 @@
 		 */
 		isolated = 0;
 		spin_lock_irqsave(&zone->lock, flags);
-		if (suitable_migration_target(page)) {
+		if (suitable_migration_target(page, cc)) {
 			end_pfn = min(pfn + pageblock_nr_pages, zone_end_pfn);
 			isolated = isolate_freepages_block(pfn, end_pfn,
 							   freelist, false);
@@ -682,8 +722,9 @@
 
 		nr_migrate = cc->nr_migratepages;
 		err = migrate_pages(&cc->migratepages, compaction_alloc,
-				(unsigned long)cc, false,
-				cc->sync ? MIGRATE_SYNC_LIGHT : MIGRATE_ASYNC);
+			(unsigned long)cc, false,
+			(cc->sync == COMPACTION_SYNC) ? MIGRATE_SYNC_LIGHT
+						      : MIGRATE_ASYNC);
 		update_nr_listpages(cc);
 		nr_remaining = cc->nr_migratepages;
 
@@ -712,7 +753,7 @@
 
 static unsigned long compact_zone_order(struct zone *zone,
 				 int order, gfp_t gfp_mask,
-				 bool sync)
+				 enum compaction_type sync)
 {
 	struct compact_control cc = {
 		.nr_freepages = 0,
@@ -742,7 +783,7 @@
  */
 unsigned long try_to_compact_pages(struct zonelist *zonelist,
 			int order, gfp_t gfp_mask, nodemask_t *nodemask,
-			bool sync)
+			enum compaction_type sync)
 {
 	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
 	int may_enter_fs = gfp_mask & __GFP_FS;
@@ -820,7 +861,7 @@
 {
 	struct compact_control cc = {
 		.order = order,
-		.sync = false,
+		.sync = COMPACTION_ASYNC_PARTIAL,
 	};
 
 	return __compact_pgdat(pgdat, &cc);
@@ -830,7 +871,7 @@
 {
 	struct compact_control cc = {
 		.order = -1,
-		.sync = true,
+		.sync = COMPACTION_SYNC,
 	};
 
 	return __compact_pgdat(NODE_DATA(nid), &cc);
Index: b/mm/internal.h
===================================================================
--- a/mm/internal.h	2012-04-24 13:47:06.000000000 +0200
+++ b/mm/internal.h	2012-04-24 13:47:33.156421912 +0200
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
+	enum compaction_type sync;	/* Synchronous/asynchronous migration */
 
 	int order;			/* order a direct compactor needs */
 	int migratetype;		/* MOVABLE, RECLAIMABLE etc */
Index: b/mm/page_alloc.c
===================================================================
--- a/mm/page_alloc.c	2012-04-24 13:47:06.000000000 +0200
+++ b/mm/page_alloc.c	2012-04-24 13:52:40.648421874 +0200
@@ -232,7 +232,7 @@
 
 int page_group_by_mobility_disabled __read_mostly;
 
-static void set_pageblock_migratetype(struct page *page, int migratetype)
+void set_pageblock_migratetype(struct page *page, int migratetype)
 {
 
 	if (unlikely(page_group_by_mobility_disabled))
@@ -967,8 +967,8 @@
 	return pages_moved;
 }
 
-static int move_freepages_block(struct zone *zone, struct page *page,
-				int migratetype)
+int move_freepages_block(struct zone *zone, struct page *page,
+			 int migratetype)
 {
 	unsigned long start_pfn, end_pfn;
 	struct page *start_page, *end_page;
@@ -2074,7 +2074,7 @@
 __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 	struct zonelist *zonelist, enum zone_type high_zoneidx,
 	nodemask_t *nodemask, int alloc_flags, struct zone *preferred_zone,
-	int migratetype, bool sync_migration,
+	int migratetype, enum compaction_type sync_migration,
 	bool *deferred_compaction,
 	unsigned long *did_some_progress)
 {
@@ -2122,7 +2122,7 @@
 		 * As async compaction considers a subset of pageblocks, only
 		 * defer if the failure was a sync compaction failure.
 		 */
-		if (sync_migration)
+		if (sync_migration == COMPACTION_SYNC)
 			defer_compaction(preferred_zone, order);
 
 		cond_resched();
@@ -2135,7 +2135,7 @@
 __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 	struct zonelist *zonelist, enum zone_type high_zoneidx,
 	nodemask_t *nodemask, int alloc_flags, struct zone *preferred_zone,
-	int migratetype, bool sync_migration,
+	int migratetype, enum compaction_type sync_migration,
 	bool *deferred_compaction,
 	unsigned long *did_some_progress)
 {
@@ -2298,7 +2298,7 @@
 	int alloc_flags;
 	unsigned long pages_reclaimed = 0;
 	unsigned long did_some_progress;
-	bool sync_migration = false;
+	enum compaction_type sync_migration = COMPACTION_ASYNC_FULL;
 	bool deferred_compaction = false;
 
 	/*
@@ -2385,7 +2385,7 @@
 					&did_some_progress);
 	if (page)
 		goto got_pg;
-	sync_migration = true;
+	sync_migration = COMPACTION_SYNC;
 
 	/*
 	 * If compaction is deferred for high-order allocations, it is because
@@ -5673,7 +5673,7 @@
 		.nr_migratepages = 0,
 		.order = -1,
 		.zone = page_zone(pfn_to_page(start)),
-		.sync = true,
+		.sync = COMPACTION_SYNC,
 	};
 	INIT_LIST_HEAD(&cc.migratepages);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
