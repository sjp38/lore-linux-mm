Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id B08BC6B004D
	for <linux-mm@kvack.org>; Wed,  2 May 2012 04:48:56 -0400 (EDT)
Received: from euspt2 (mailout2.w1.samsung.com [210.118.77.12])
 by mailout2.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0M3E00HH10HC6Q@mailout2.w1.samsung.com> for linux-mm@kvack.org;
 Wed, 02 May 2012 09:48:48 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M3E00DZI0HGCO@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 02 May 2012 09:48:52 +0100 (BST)
Date: Wed, 02 May 2012 10:47:44 +0200
From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: [PATCH v5] mm: compaction: handle incorrect MIGRATE_UNMOVABLE type
 pageblocks
Message-id: <201205021047.45188.b.zolnierkie@samsung.com>
MIME-version: 1.0
Content-type: Text/Plain; charset=us-ascii
Content-transfer-encoding: 7BIT
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>

From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: [PATCH v5] mm: compaction: handle incorrect MIGRATE_UNMOVABLE type pageblocks

When MIGRATE_UNMOVABLE pages are freed from MIGRATE_UNMOVABLE
type pageblock (and some MIGRATE_MOVABLE pages are left in it)
waiting until an allocation takes ownership of the block may
take too long.  The type of the pageblock remains unchanged
so the pageblock cannot be used as a migration target during
compaction.

Fix it by:

* Adding enum compact_mode (COMPACT_ASYNC_[MOVABLE,UNMOVABLE],
  and COMPACT_SYNC) and then converting sync field in struct
  compact_control to use it.

* Adding nr_[pageblocks,skipped] fields to struct compact_control
  and tracking how many destination pageblocks were scanned during
  compaction and how many of them were of MIGRATE_UNMOVABLE type.
  If COMPACT_ASYNC_MOVABLE mode compaction ran fully in
  try_to_compact_pages() (COMPACT_COMPLETE) it implies that
  there is not a suitable page for allocation.  In this case then
  check how if there were enough MIGRATE_UNMOVABLE pageblocks to
  try a second pass in COMPACT_ASYNC_UNMOVABLE mode.

* Scanning the MIGRATE_UNMOVABLE pageblocks (during COMPACT_SYNC
  and COMPACT_ASYNC_UNMOVABLE compaction modes) and building
  a count based on finding PageBuddy pages, page_count(page) == 0
  or PageLRU pages.  If all pages within the MIGRATE_UNMOVABLE
  pageblock are in one of those three sets change the whole
  pageblock type to MIGRATE_MOVABLE.


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
v2:
- redo the patch basing on review from Mel Gorman
  (http://marc.info/?l=linux-mm&m=133519311025444&w=2)
v3:
- apply review comments from Minchan Kim
  (http://marc.info/?l=linux-mm&m=133531540308862&w=2)
v4:
- more review comments from Mel
  (http://marc.info/?l=linux-mm&m=133545110625042&w=2)
v5:
- even more comments from Mel
  (http://marc.info/?l=linux-mm&m=133577669023492&w=2)
- fix patch description

 include/linux/compaction.h |   19 +++++++
 mm/compaction.c            |  109 +++++++++++++++++++++++++++++++++++++--------
 mm/internal.h              |   10 +++-
 mm/page_alloc.c            |    8 +--
 4 files changed, 124 insertions(+), 22 deletions(-)

Index: b/include/linux/compaction.h
===================================================================
--- a/include/linux/compaction.h	2012-05-02 10:39:17.000000000 +0200
+++ b/include/linux/compaction.h	2012-05-02 10:40:03.708727714 +0200
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
Index: b/mm/compaction.c
===================================================================
--- a/mm/compaction.c	2012-05-02 10:39:19.000000000 +0200
+++ b/mm/compaction.c	2012-05-02 10:44:44.380727714 +0200
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
@@ -357,13 +358,59 @@
 
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
+				      struct compact_control *cc,
+				      bool count_pageblocks)
 {
 
 	int migratetype = get_pageblock_migratetype(page);
 
+	if (count_pageblocks && cc->mode == COMPACT_ASYNC_MOVABLE) {
+		cc->nr_pageblocks++;
+		if (migratetype == MIGRATE_UNMOVABLE)
+			cc->nr_skipped++;
+	}
+
 	/* Don't interfere with memory hot-remove or the min_free_kbytes blocks */
 	if (migratetype == MIGRATE_ISOLATE || migratetype == MIGRATE_RESERVE)
 		return false;
@@ -373,7 +420,13 @@
 		return true;
 
 	/* If the block is MIGRATE_MOVABLE or MIGRATE_CMA, allow migration */
-	if (migrate_async_suitable(migratetype))
+	if (cc->mode != COMPACT_ASYNC_UNMOVABLE &&
+	    migrate_async_suitable(migratetype))
+		return true;
+
+	if (cc->mode != COMPACT_ASYNC_MOVABLE &&
+	    migratetype == MIGRATE_UNMOVABLE &&
+	    rescue_unmovable_pageblock(page))
 		return true;
 
 	/* Otherwise skip the block */
@@ -410,6 +463,9 @@
 
 	zone_end_pfn = zone->zone_start_pfn + zone->spanned_pages;
 
+	cc->nr_pageblocks = 0;
+	cc->nr_skipped = 0;
+
 	/*
 	 * Isolate free pages until enough are available to migrate the
 	 * pages on cc->migratepages. We stop searching if the migrate
@@ -434,7 +490,7 @@
 			continue;
 
 		/* Check the block is suitable for migration */
-		if (!suitable_migration_target(page))
+		if (!suitable_migration_target(page, cc, true))
 			continue;
 
 		/*
@@ -445,7 +501,7 @@
 		 */
 		isolated = 0;
 		spin_lock_irqsave(&zone->lock, flags);
-		if (suitable_migration_target(page)) {
+		if (suitable_migration_target(page, cc, false)) {
 			end_pfn = min(pfn + pageblock_nr_pages, zone_end_pfn);
 			isolated = isolate_freepages_block(pfn, end_pfn,
 							   freelist, false);
@@ -682,8 +738,9 @@
 
 		nr_migrate = cc->nr_migratepages;
 		err = migrate_pages(&cc->migratepages, compaction_alloc,
-				(unsigned long)cc, false,
-				cc->sync ? MIGRATE_SYNC_LIGHT : MIGRATE_ASYNC);
+			(unsigned long)cc, false,
+			(cc->mode == COMPACT_SYNC) ? MIGRATE_SYNC_LIGHT
+						      : MIGRATE_ASYNC);
 		update_nr_listpages(cc);
 		nr_remaining = cc->nr_migratepages;
 
@@ -712,7 +769,9 @@
 
 static unsigned long compact_zone_order(struct zone *zone,
 				 int order, gfp_t gfp_mask,
-				 bool sync)
+				 enum compact_mode mode,
+				 unsigned long *nr_pageblocks,
+				 unsigned long *nr_skipped)
 {
 	struct compact_control cc = {
 		.nr_freepages = 0,
@@ -720,12 +779,18 @@
 		.order = order,
 		.migratetype = allocflags_to_migratetype(gfp_mask),
 		.zone = zone,
-		.sync = sync,
+		.mode = mode,
 	};
+	unsigned long rc;
+
 	INIT_LIST_HEAD(&cc.freepages);
 	INIT_LIST_HEAD(&cc.migratepages);
 
-	return compact_zone(zone, &cc);
+	rc = compact_zone(zone, &cc);
+	*nr_pageblocks = cc.nr_pageblocks;
+	*nr_skipped = cc.nr_skipped;
+
+	return rc;
 }
 
 int sysctl_extfrag_threshold = 500;
@@ -750,6 +815,8 @@
 	struct zoneref *z;
 	struct zone *zone;
 	int rc = COMPACT_SKIPPED;
+	unsigned long nr_pageblocks = 0, nr_skipped = 0;
+	enum compact_mode mode = sync ? COMPACT_SYNC : COMPACT_ASYNC_MOVABLE;
 
 	/*
 	 * Check whether it is worth even starting compaction. The order check is
@@ -760,13 +827,14 @@
 		return rc;
 
 	count_vm_event(COMPACTSTALL);
-
+compact:
 	/* Compact each zone in the list */
 	for_each_zone_zonelist_nodemask(zone, z, zonelist, high_zoneidx,
 								nodemask) {
 		int status;
 
-		status = compact_zone_order(zone, order, gfp_mask, sync);
+		status = compact_zone_order(zone, order, gfp_mask, mode,
+					    &nr_pageblocks, &nr_skipped);
 		rc = max(status, rc);
 
 		/* If a normal allocation would succeed, stop compacting */
@@ -774,6 +842,13 @@
 			break;
 	}
 
+	if (rc == COMPACT_COMPLETE && mode == COMPACT_ASYNC_MOVABLE) {
+		if (nr_pageblocks && nr_skipped) {
+			mode = COMPACT_ASYNC_UNMOVABLE;
+			goto compact;
+		}
+	}
+
 	return rc;
 }
 
@@ -805,7 +880,7 @@
 			if (ok && cc->order > zone->compact_order_failed)
 				zone->compact_order_failed = cc->order + 1;
 			/* Currently async compaction is never deferred. */
-			else if (!ok && cc->sync)
+			else if (!ok && cc->mode == COMPACT_SYNC)
 				defer_compaction(zone, cc->order);
 		}
 
@@ -820,7 +895,7 @@
 {
 	struct compact_control cc = {
 		.order = order,
-		.sync = false,
+		.mode = COMPACT_ASYNC_MOVABLE,
 	};
 
 	return __compact_pgdat(pgdat, &cc);
@@ -830,7 +905,7 @@
 {
 	struct compact_control cc = {
 		.order = -1,
-		.sync = true,
+		.mode = COMPACT_SYNC,
 	};
 
 	return __compact_pgdat(NODE_DATA(nid), &cc);
Index: b/mm/internal.h
===================================================================
--- a/mm/internal.h	2012-05-02 10:39:19.000000000 +0200
+++ b/mm/internal.h	2012-05-02 10:42:05.060727733 +0200
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
@@ -119,11 +123,15 @@
 	unsigned long nr_migratepages;	/* Number of pages to migrate */
 	unsigned long free_pfn;		/* isolate_freepages search base */
 	unsigned long migrate_pfn;	/* isolate_migratepages search base */
-	bool sync;			/* Synchronous migration */
+	enum compact_mode mode;		/* partial/full/sync compaction */
 
 	int order;			/* order a direct compactor needs */
 	int migratetype;		/* MOVABLE, RECLAIMABLE etc */
 	struct zone *zone;
+	unsigned long nr_pageblocks;	/* Number of scanned destination
+					   pageblocks */
+	unsigned long nr_skipped;	/* Number of UNMOVABLE destination
+					   pageblocks skipped during scan */
 };
 
 unsigned long
Index: b/mm/page_alloc.c
===================================================================
--- a/mm/page_alloc.c	2012-05-02 10:39:19.000000000 +0200
+++ b/mm/page_alloc.c	2012-05-02 10:40:03.712727760 +0200
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
@@ -5654,7 +5654,7 @@
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
