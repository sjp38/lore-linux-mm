Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id E00176B0062
	for <linux-mm@kvack.org>; Mon,  4 Jun 2012 09:44:10 -0400 (EDT)
Received: from euspt1 (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0M53003AVI6HXK10@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 04 Jun 2012 14:44:41 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M53002CBI5K4M@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 04 Jun 2012 14:44:09 +0100 (BST)
Date: Mon, 04 Jun 2012 15:43:56 +0200
From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: [PATCH v9] mm: compaction: handle incorrect MIGRATE_UNMOVABLE type
 pageblocks
Message-id: <201206041543.56917.b.zolnierkie@samsung.com>
MIME-version: 1.0
Content-type: Text/Plain; charset=us-ascii
Content-transfer-encoding: 7BIT
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Kyungmin Park <kyungmin.park@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Cong Wang <amwang@redhat.com>, Markus Trippelsdorf <markus@trippelsdorf.de>


Dave, could you please test this version?

From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: [PATCH v9] mm: compaction: handle incorrect MIGRATE_UNMOVABLE type pageblocks

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

* Adding nr_pageblocks_skipped field to struct compact_control
  and tracking how many destination pageblocks were of
  MIGRATE_UNMOVABLE type.  If COMPACT_ASYNC_MOVABLE mode compaction
  ran fully in try_to_compact_pages() (COMPACT_COMPLETE) it implies
  that there is not a suitable page for allocation.  In this case
  then check how if there were enough MIGRATE_UNMOVABLE pageblocks
  to try a second pass in COMPACT_ASYNC_UNMOVABLE mode.

* Scanning the MIGRATE_UNMOVABLE pageblocks (during COMPACT_SYNC
  and COMPACT_ASYNC_UNMOVABLE compaction modes) and building
  a count based on finding PageBuddy pages, page_count(page) == 0
  or PageLRU pages.  If all pages within the MIGRATE_UNMOVABLE
  pageblock are in one of those three sets change the whole
  pageblock type to MIGRATE_MOVABLE.

My particular test case (on a ARM EXYNOS4 device with 512 MiB,
which means 131072 standard 4KiB pages in 'Normal' zone) is to:
- allocate 95000 pages for kernel's usage
- free every second page (47500 pages) of memory just allocated
- allocate and use 60000 pages from user space
- free remaining 60000 pages of kernel memory
(now we have fragmented memory occupied mostly by user space pages)
- try to allocate 100 order-9 (2048 KiB) pages for kernel's usage

The results:
- with compaction disabled I get 10 successful allocations
- with compaction enabled - 11 successful allocations
- with this patch I'm able to get 25 successful allocations

NOTE: If we can make kswapd aware of order-0 request during
compaction, we can enhance kswapd with changing mode to
COMPACT_ASYNC_FULL (COMPACT_ASYNC_MOVABLE + COMPACT_ASYNC_UNMOVABLE).
Please see the following thread:

	http://marc.info/?l=linux-mm&m=133552069417068&w=2

[minchan@kernel.org: minor cleanups]
Cc: Hugh Dickins <hughd@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Dave Jones <davej@redhat.com>
Cc: Cong Wang <amwang@redhat.com>
Cc: Markus Trippelsdorf <markus@trippelsdorf.de>
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
v6: (based on comments from Minchan Kim and Mel Gorman)
- add note about kswapd
- rename nr_pageblocks to nr_pageblocks_scanned_scanned and nr_skipped
  to nr_pageblocks_scanned_skipped
- fix pageblocks counting in suitable_migration_target()
- fix try_to_compact_pages() to do COMPACT_ASYNC_UNMOVABLE per zone 
v7:
- minor cleanups from Minchan Kim
- cleanup try_to_compact_pages()
v8:
- document rescue_unmovable_pageblock()
- enum result_smt -> enum_smt_result
- fix suitable_migration_target() documentation
- add comment about zeroing cc->nr_pageblocks_skipped
- fix FAIL_UNMOVABLE_TARGET handling in isolate_freepages()
v9:
- use right page for pageblock conversion in rescue_unmovable_pageblock()
- split rescue_unmovable_pageblock() on can_rescue_unmovable_pageblock()
  and __rescue_unmovable_pageblock()
- add missing locking
- modify test-case slightly

 include/linux/compaction.h |   19 +++++
 mm/compaction.c            |  166 ++++++++++++++++++++++++++++++++++++++-------
 mm/internal.h              |    9 ++
 mm/page_alloc.c            |    8 +-
 4 files changed, 174 insertions(+), 28 deletions(-)

Index: b/include/linux/compaction.h
===================================================================
--- a/include/linux/compaction.h	2012-06-04 15:01:40.957552983 +0200
+++ b/include/linux/compaction.h	2012-06-04 15:16:30.396467898 +0200
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
--- a/mm/compaction.c	2012-06-04 15:16:11.884467919 +0200
+++ b/mm/compaction.c	2012-06-04 15:18:34.220467910 +0200
@@ -236,7 +236,7 @@ isolate_migratepages_range(struct zone *
 	 */
 	while (unlikely(too_many_isolated(zone))) {
 		/* async migration should just abort */
-		if (!cc->sync)
+		if (cc->mode != COMPACT_SYNC)
 			return 0;
 
 		congestion_wait(BLK_RW_ASYNC, HZ/10);
@@ -304,7 +304,8 @@ isolate_migratepages_range(struct zone *
 		 * satisfies the allocation
 		 */
 		pageblock_nr = low_pfn >> pageblock_order;
-		if (!cc->sync && last_pageblock_nr != pageblock_nr &&
+		if (cc->mode != COMPACT_SYNC &&
+		    last_pageblock_nr != pageblock_nr &&
 		    !migrate_async_suitable(get_pageblock_migratetype(page))) {
 			low_pfn += pageblock_nr_pages;
 			low_pfn = ALIGN(low_pfn, pageblock_nr_pages) - 1;
@@ -325,7 +326,7 @@ isolate_migratepages_range(struct zone *
 			continue;
 		}
 
-		if (!cc->sync)
+		if (cc->mode != COMPACT_SYNC)
 			mode |= ISOLATE_ASYNC_MIGRATE;
 
 		lruvec = mem_cgroup_page_lruvec(page, zone);
@@ -360,27 +361,110 @@ isolate_migratepages_range(struct zone *
 
 #endif /* CONFIG_COMPACTION || CONFIG_CMA */
 #ifdef CONFIG_COMPACTION
+/*
+ * Returns true if MIGRATE_UNMOVABLE pageblock can be successfully
+ * converted to MIGRATE_MOVABLE type, false otherwise.
+ */
+static bool can_rescue_unmovable_pageblock(struct page *page, bool locked)
+{
+	unsigned long pfn, start_pfn, end_pfn;
+	struct page *start_page, *end_page, *cursor_page;
+
+	pfn = page_to_pfn(page);
+	start_pfn = pfn & ~(pageblock_nr_pages - 1);
+	end_pfn = start_pfn + pageblock_nr_pages - 1;
+
+	start_page = pfn_to_page(start_pfn);
+	end_page = pfn_to_page(end_pfn);
+
+	for (cursor_page = start_page, pfn = start_pfn; cursor_page <= end_page;
+		pfn++, cursor_page++) {
+		struct zone *zone = page_zone(start_page);
+		unsigned long flags;
+
+		if (!pfn_valid_within(pfn))
+			continue;
+
+		/* Do not deal with pageblocks that overlap zones */
+		if (page_zone(cursor_page) != zone)
+			return false;
+
+		if (!locked)
+			spin_lock_irqsave(&zone->lock, flags);
+
+		if (PageBuddy(cursor_page)) {
+			int order = page_order(cursor_page);
 
-/* Returns true if the page is within a block suitable for migration to */
-static bool suitable_migration_target(struct page *page)
+			pfn += (1 << order) - 1;
+			cursor_page += (1 << order) - 1;
+
+			if (!locked)
+				spin_unlock_irqrestore(&zone->lock, flags);
+			continue;
+		} else if (page_count(cursor_page) == 0 ||
+			   PageLRU(cursor_page)) {
+			if (!locked)
+				spin_unlock_irqrestore(&zone->lock, flags);
+			continue;
+		}
+
+		if (!locked)
+			spin_unlock_irqrestore(&zone->lock, flags);
+
+		return false;
+	}
+
+	return true;
+}
+
+void __rescue_unmovable_pageblock(struct page *page)
+{
+	set_pageblock_migratetype(page, MIGRATE_MOVABLE);
+	move_freepages_block(page_zone(page), page, MIGRATE_MOVABLE);
+}
+
+enum smt_result {
+	GOOD_AS_MIGRATION_TARGET,
+	GOOD_CAN_RESCUE_UNMOVABLE_TARGET,
+	FAIL_UNMOVABLE_TARGET,
+	FAIL_BAD_TARGET,
+};
+
+/*
+ * Returns GOOD_AS_MIGRATION_TARGET if the page is within a block
+ * suitable for migration to, FAIL_UNMOVABLE_TARGET if the page
+ * is within a MIGRATE_UNMOVABLE block, FAIL_BAD_TARGET otherwise.
+ */
+static enum smt_result suitable_migration_target(struct page *page,
+				      struct compact_control *cc, bool locked)
 {
 
 	int migratetype = get_pageblock_migratetype(page);
 
 	/* Don't interfere with memory hot-remove or the min_free_kbytes blocks */
 	if (migratetype == MIGRATE_ISOLATE || migratetype == MIGRATE_RESERVE)
-		return false;
+		return FAIL_BAD_TARGET;
 
 	/* If the page is a large free page, then allow migration */
 	if (PageBuddy(page) && page_order(page) >= pageblock_order)
-		return true;
+		return GOOD_AS_MIGRATION_TARGET;
 
 	/* If the block is MIGRATE_MOVABLE or MIGRATE_CMA, allow migration */
-	if (migrate_async_suitable(migratetype))
-		return true;
+	if (cc->mode != COMPACT_ASYNC_UNMOVABLE &&
+	    migrate_async_suitable(migratetype))
+		return GOOD_AS_MIGRATION_TARGET;
+
+	if (cc->mode == COMPACT_ASYNC_MOVABLE &&
+	    migratetype == MIGRATE_UNMOVABLE)
+		return FAIL_UNMOVABLE_TARGET;
+
+	if (cc->mode != COMPACT_ASYNC_MOVABLE &&
+	    migratetype == MIGRATE_UNMOVABLE &&
+	    can_rescue_unmovable_pageblock(page, locked))
+		return GOOD_CAN_RESCUE_UNMOVABLE_TARGET;
 
 	/* Otherwise skip the block */
-	return false;
+	return FAIL_BAD_TARGET;
 }
 
 /*
@@ -414,6 +498,13 @@ static void isolate_freepages(struct zon
 	zone_end_pfn = zone->zone_start_pfn + zone->spanned_pages;
 
 	/*
+	 * isolate_freepages() may be called more than once during
+	 * compact_zone_order() run and we want only the most recent
+	 * count.
+	 */
+	cc->nr_pageblocks_skipped = 0;
+
+	/*
 	 * Isolate free pages until enough are available to migrate the
 	 * pages on cc->migratepages. We stop searching if the migrate
 	 * and free page scanners meet or enough free pages are isolated.
@@ -421,6 +512,7 @@ static void isolate_freepages(struct zon
 	for (; pfn > low_pfn && cc->nr_migratepages > nr_freepages;
 					pfn -= pageblock_nr_pages) {
 		unsigned long isolated;
+		enum smt_result ret;
 
 		if (!pfn_valid(pfn))
 			continue;
@@ -437,9 +529,13 @@ static void isolate_freepages(struct zon
 			continue;
 
 		/* Check the block is suitable for migration */
-		if (!suitable_migration_target(page))
+		ret = suitable_migration_target(page, cc, false);
+		if (ret != GOOD_AS_MIGRATION_TARGET &&
+		    ret != GOOD_CAN_RESCUE_UNMOVABLE_TARGET) {
+			if (ret == FAIL_UNMOVABLE_TARGET)
+				cc->nr_pageblocks_skipped++;
 			continue;
-
+		}
 		/*
 		 * Found a block suitable for isolating free pages from. Now
 		 * we disabled interrupts, double check things are ok and
@@ -448,12 +544,17 @@ static void isolate_freepages(struct zon
 		 */
 		isolated = 0;
 		spin_lock_irqsave(&zone->lock, flags);
-		if (suitable_migration_target(page)) {
+		ret = suitable_migration_target(page, cc, true);
+		if (ret == GOOD_AS_MIGRATION_TARGET ||
+		    ret == GOOD_CAN_RESCUE_UNMOVABLE_TARGET) {
+			if (ret == GOOD_CAN_RESCUE_UNMOVABLE_TARGET)
+				__rescue_unmovable_pageblock(page);
 			end_pfn = min(pfn + pageblock_nr_pages, zone_end_pfn);
 			isolated = isolate_freepages_block(pfn, end_pfn,
 							   freelist, false);
 			nr_freepages += isolated;
-		}
+		} else if (ret == FAIL_UNMOVABLE_TARGET)
+			cc->nr_pageblocks_skipped++;
 		spin_unlock_irqrestore(&zone->lock, flags);
 
 		/*
@@ -685,8 +786,9 @@ static int compact_zone(struct zone *zon
 
 		nr_migrate = cc->nr_migratepages;
 		err = migrate_pages(&cc->migratepages, compaction_alloc,
-				(unsigned long)cc, false,
-				cc->sync ? MIGRATE_SYNC_LIGHT : MIGRATE_ASYNC);
+			(unsigned long)&cc->freepages, false,
+			(cc->mode == COMPACT_SYNC) ? MIGRATE_SYNC_LIGHT
+						      : MIGRATE_ASYNC);
 		update_nr_listpages(cc);
 		nr_remaining = cc->nr_migratepages;
 
@@ -715,7 +817,8 @@ out:
 
 static unsigned long compact_zone_order(struct zone *zone,
 				 int order, gfp_t gfp_mask,
-				 bool sync)
+				 enum compact_mode mode,
+				 unsigned long *nr_pageblocks_skipped)
 {
 	struct compact_control cc = {
 		.nr_freepages = 0,
@@ -723,12 +826,17 @@ static unsigned long compact_zone_order(
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
+	*nr_pageblocks_skipped = cc.nr_pageblocks_skipped;
+
+	return rc;
 }
 
 int sysctl_extfrag_threshold = 500;
@@ -753,6 +861,8 @@ unsigned long try_to_compact_pages(struc
 	struct zoneref *z;
 	struct zone *zone;
 	int rc = COMPACT_SKIPPED;
+	unsigned long nr_pageblocks_skipped;
+	enum compact_mode mode;
 
 	/*
 	 * Check whether it is worth even starting compaction. The order check is
@@ -769,12 +879,22 @@ unsigned long try_to_compact_pages(struc
 								nodemask) {
 		int status;
 
-		status = compact_zone_order(zone, order, gfp_mask, sync);
+		mode = sync ? COMPACT_SYNC : COMPACT_ASYNC_MOVABLE;
+retry:
+		status = compact_zone_order(zone, order, gfp_mask, mode,
+						&nr_pageblocks_skipped);
 		rc = max(status, rc);
 
 		/* If a normal allocation would succeed, stop compacting */
 		if (zone_watermark_ok(zone, order, low_wmark_pages(zone), 0, 0))
 			break;
+
+		if (rc == COMPACT_COMPLETE && mode == COMPACT_ASYNC_MOVABLE) {
+			if (nr_pageblocks_skipped) {
+				mode = COMPACT_ASYNC_UNMOVABLE;
+				goto retry;
+			}
+		}
 	}
 
 	return rc;
@@ -808,7 +928,7 @@ static int __compact_pgdat(pg_data_t *pg
 			if (ok && cc->order > zone->compact_order_failed)
 				zone->compact_order_failed = cc->order + 1;
 			/* Currently async compaction is never deferred. */
-			else if (!ok && cc->sync)
+			else if (!ok && cc->mode == COMPACT_SYNC)
 				defer_compaction(zone, cc->order);
 		}
 
@@ -823,7 +943,7 @@ int compact_pgdat(pg_data_t *pgdat, int 
 {
 	struct compact_control cc = {
 		.order = order,
-		.sync = false,
+		.mode = COMPACT_ASYNC_MOVABLE,
 	};
 
 	return __compact_pgdat(pgdat, &cc);
@@ -833,7 +953,7 @@ static int compact_node(int nid)
 {
 	struct compact_control cc = {
 		.order = -1,
-		.sync = true,
+		.mode = COMPACT_SYNC,
 	};
 
 	return __compact_pgdat(NODE_DATA(nid), &cc);
Index: b/mm/internal.h
===================================================================
--- a/mm/internal.h	2012-06-04 15:16:11.908467919 +0200
+++ b/mm/internal.h	2012-06-04 15:16:30.396467898 +0200
@@ -94,6 +94,9 @@ extern void putback_lru_page(struct page
 /*
  * in mm/page_alloc.c
  */
+extern void set_pageblock_migratetype(struct page *page, int migratetype);
+extern int move_freepages_block(struct zone *zone, struct page *page,
+				int migratetype);
 extern void __free_pages_bootmem(struct page *page, unsigned int order);
 extern void prep_compound_page(struct page *page, unsigned long order);
 #ifdef CONFIG_MEMORY_FAILURE
@@ -101,6 +104,7 @@ extern bool is_free_buddy_page(struct pa
 #endif
 
 #if defined CONFIG_COMPACTION || defined CONFIG_CMA
+#include <linux/compaction.h>
 
 /*
  * in mm/compaction.c
@@ -119,11 +123,14 @@ struct compact_control {
 	unsigned long nr_migratepages;	/* Number of pages to migrate */
 	unsigned long free_pfn;		/* isolate_freepages search base */
 	unsigned long migrate_pfn;	/* isolate_migratepages search base */
-	bool sync;			/* Synchronous migration */
+	enum compact_mode mode;		/* Compaction mode */
 
 	int order;			/* order a direct compactor needs */
 	int migratetype;		/* MOVABLE, RECLAIMABLE etc */
 	struct zone *zone;
+
+	/* Number of UNMOVABLE destination pageblocks skipped during scan */
+	unsigned long nr_pageblocks_skipped;
 };
 
 unsigned long
Index: b/mm/page_alloc.c
===================================================================
--- a/mm/page_alloc.c	2012-06-04 15:16:27.356467917 +0200
+++ b/mm/page_alloc.c	2012-06-04 15:16:30.396467898 +0200
@@ -241,7 +241,7 @@ static char *migratetype_to_str(int migr
 	}
 }
 
-static void set_pageblock_migratetype(struct page *page, int migratetype)
+void set_pageblock_migratetype(struct page *page, int migratetype)
 {
 	struct zone *zone = page_zone(page);
 
@@ -982,8 +982,8 @@ static int move_freepages(struct zone *z
 	return pages_moved;
 }
 
-static int move_freepages_block(struct zone *zone, struct page *page,
-				int migratetype)
+int move_freepages_block(struct zone *zone, struct page *page,
+			 int migratetype)
 {
 	unsigned long start_pfn, end_pfn;
 	struct page *start_page, *end_page;
@@ -5684,7 +5684,7 @@ static int __alloc_contig_migrate_range(
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
