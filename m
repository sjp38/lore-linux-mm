Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 36F106B006E
	for <linux-mm@kvack.org>; Fri,  8 Jun 2012 04:53:28 -0400 (EDT)
Received: from epcpsbgm1.samsung.com (mailout2.samsung.com [203.254.224.25])
 by mailout2.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0M5A00LMFJCZNVU0@mailout2.samsung.com> for
 linux-mm@kvack.org; Fri, 08 Jun 2012 17:53:26 +0900 (KST)
Received: from bzolnier-desktop.localnet ([106.116.48.38])
 by mmp1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0M5A00MI8JCZRB70@mmp1.samsung.com> for linux-mm@kvack.org;
 Fri, 08 Jun 2012 17:53:26 +0900 (KST)
From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: [PATCH v10] mm: compaction: handle incorrect MIGRATE_UNMOVABLE type
 pageblocks
Date: Fri, 08 Jun 2012 10:46:32 +0200
MIME-version: 1.0
Content-type: Text/Plain; charset=us-ascii
Content-transfer-encoding: 7bit
Message-id: <201206081046.32382.b.zolnierkie@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Dave Jones <davej@redhat.com>, Cong Wang <amwang@redhat.com>, Markus Trippelsdorf <markus@trippelsdorf.de>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>


Hi,

This version is much simpler as it just uses __count_immobile_pages()
instead of using its own open coded version and it integrates changes
from Minchan Kim (without page_count change as it doesn't seem correct
and __count_immobile_pages() does the check in the standard way; if it
still is a problem I think that removing 1st phase check altogether
would be better instead of adding more locking complexity).

The patch also adds compact_rescued_unmovable_blocks vmevent to vmstats
to make it possible to easily check if the code is working in practice.

Best regards,
--
Bartlomiej Zolnierkiewicz
Samsung Poland R&D Center


From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: [PATCH v10] mm: compaction: handle incorrect MIGRATE_UNMOVABLE type pageblocks

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
v10:
- merge changes from Minchan Kim
- use __count_immobile_pages()
- add compact_rescued_unmovable_blocks vmevent to vmstats

 include/linux/compaction.h    |   19 +++++
 include/linux/vm_event_item.h |    1 
 mm/compaction.c               |  140 +++++++++++++++++++++++++++++++++++-------
 mm/internal.h                 |   11 +++
 mm/page_alloc.c               |   16 +++-
 mm/vmstat.c                   |    1 
 6 files changed, 158 insertions(+), 30 deletions(-)

Index: b/include/linux/compaction.h
===================================================================
--- a/include/linux/compaction.h	2012-06-08 09:01:32.041681656 +0200
+++ b/include/linux/compaction.h	2012-06-08 09:01:35.697681651 +0200
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
Index: b/include/linux/vm_event_item.h
===================================================================
--- a/include/linux/vm_event_item.h	2012-06-08 09:55:12.653681272 +0200
+++ b/include/linux/vm_event_item.h	2012-06-08 10:02:32.069681221 +0200
@@ -39,6 +39,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PS
 #ifdef CONFIG_COMPACTION
 		COMPACTBLOCKS, COMPACTPAGES, COMPACTPAGEFAILED,
 		COMPACTSTALL, COMPACTFAIL, COMPACTSUCCESS,
+		COMPACT_RESCUED_UNMOVABLE_BLOCKS,
 #endif
 #ifdef CONFIG_HUGETLB_PAGE
 		HTLB_BUDDY_PGALLOC, HTLB_BUDDY_PGALLOC_FAIL,
Index: b/mm/compaction.c
===================================================================
--- a/mm/compaction.c	2012-06-08 09:01:32.105681656 +0200
+++ b/mm/compaction.c	2012-06-08 10:03:38.413681248 +0200
@@ -235,7 +235,7 @@ isolate_migratepages_range(struct zone *
 	 */
 	while (unlikely(too_many_isolated(zone))) {
 		/* async migration should just abort */
-		if (!cc->sync)
+		if (cc->mode != COMPACT_SYNC)
 			return 0;
 
 		congestion_wait(BLK_RW_ASYNC, HZ/10);
@@ -303,7 +303,8 @@ isolate_migratepages_range(struct zone *
 		 * satisfies the allocation
 		 */
 		pageblock_nr = low_pfn >> pageblock_order;
-		if (!cc->sync && last_pageblock_nr != pageblock_nr &&
+		if (cc->mode != COMPACT_SYNC &&
+		    last_pageblock_nr != pageblock_nr &&
 		    !migrate_async_suitable(get_pageblock_migratetype(page))) {
 			low_pfn += pageblock_nr_pages;
 			low_pfn = ALIGN(low_pfn, pageblock_nr_pages) - 1;
@@ -324,7 +325,7 @@ isolate_migratepages_range(struct zone *
 			continue;
 		}
 
-		if (!cc->sync)
+		if (cc->mode != COMPACT_SYNC)
 			mode |= ISOLATE_ASYNC_MIGRATE;
 
 		/* Try isolate the page */
@@ -357,27 +358,86 @@ isolate_migratepages_range(struct zone *
 
 #endif /* CONFIG_COMPACTION || CONFIG_CMA */
 #ifdef CONFIG_COMPACTION
+/*
+ * Returns true if MIGRATE_UNMOVABLE pageblock can be successfully
+ * converted to MIGRATE_MOVABLE type, false otherwise.
+ */
+static bool can_rescue_unmovable_pageblock(struct page *page)
+{
+	struct zone *zone;
+	unsigned long pfn, start_pfn, end_pfn;
+	struct page *start_page;
+
+	zone = page_zone(page);
+	pfn = page_to_pfn(page);
+	start_pfn = pfn & ~(pageblock_nr_pages - 1);
+	start_page = pfn_to_page(start_pfn);
+
+	/*
+	 * Race with page allocator/reclaimer can happen so that it can
+	 * deceive unmovable block to migratable type on this pageblock.
+	 * It could regress on anti-fragmentation but it's rare and not
+	 * critical.
+	 */
+	return __count_immobile_pages(zone, start_page, 0);
+}
+
+static void rescue_unmovable_pageblock(struct page *page)
+{
+	set_pageblock_migratetype(page, MIGRATE_MOVABLE);
+	move_freepages_block(page_zone(page), page, MIGRATE_MOVABLE);
+
+	count_vm_event(COMPACT_RESCUED_UNMOVABLE_BLOCKS);
+}
+
+/*
+ * MIGRATE_TARGET : good for migration target
+ * RESCUE_UNMOVABLE_TARTET : good only if we can rescue the unmovable pageblock.
+ * UNMOVABLE_TARGET : can't migrate because it's a page in unmovable pageblock.
+ * SKIP_TARGET : can't migrate by another reasons.
+ */
+enum smt_result {
+	MIGRATE_TARGET,
+	RESCUE_UNMOVABLE_TARGET,
+	UNMOVABLE_TARGET,
+	SKIP_TARGET,
+};
 
-/* Returns true if the page is within a block suitable for migration to */
-static bool suitable_migration_target(struct page *page)
+/*
+ * Returns MIGRATE_TARGET if the page is within a block
+ * suitable for migration to, UNMOVABLE_TARGET if the page
+ * is within a MIGRATE_UNMOVABLE block, SKIP_TARGET otherwise.
+ */
+static enum smt_result suitable_migration_target(struct page *page,
+			      struct compact_control *cc)
 {
 
 	int migratetype = get_pageblock_migratetype(page);
 
 	/* Don't interfere with memory hot-remove or the min_free_kbytes blocks */
 	if (migratetype == MIGRATE_ISOLATE || migratetype == MIGRATE_RESERVE)
-		return false;
+		return SKIP_TARGET;
 
 	/* If the page is a large free page, then allow migration */
 	if (PageBuddy(page) && page_order(page) >= pageblock_order)
-		return true;
+		return MIGRATE_TARGET;
 
 	/* If the block is MIGRATE_MOVABLE or MIGRATE_CMA, allow migration */
-	if (migrate_async_suitable(migratetype))
-		return true;
+	if (cc->mode != COMPACT_ASYNC_UNMOVABLE &&
+	    migrate_async_suitable(migratetype))
+		return MIGRATE_TARGET;
+
+	if (cc->mode == COMPACT_ASYNC_MOVABLE &&
+	    migratetype == MIGRATE_UNMOVABLE)
+		return UNMOVABLE_TARGET;
+
+	if (cc->mode != COMPACT_ASYNC_MOVABLE &&
+	    migratetype == MIGRATE_UNMOVABLE &&
+	    can_rescue_unmovable_pageblock(page))
+		return RESCUE_UNMOVABLE_TARGET;
 
 	/* Otherwise skip the block */
-	return false;
+	return SKIP_TARGET;
 }
 
 /*
@@ -411,6 +471,13 @@ static void isolate_freepages(struct zon
 	zone_end_pfn = zone->zone_start_pfn + zone->spanned_pages;
 
 	/*
+	 * isolate_freepages() may be called more than once during
+	 * compact_zone_order() run and we want only the most recent
+	 * count.
+	 */
+	cc->nr_unmovable_pageblock = 0;
+
+	/*
 	 * Isolate free pages until enough are available to migrate the
 	 * pages on cc->migratepages. We stop searching if the migrate
 	 * and free page scanners meet or enough free pages are isolated.
@@ -418,6 +485,7 @@ static void isolate_freepages(struct zon
 	for (; pfn > low_pfn && cc->nr_migratepages > nr_freepages;
 					pfn -= pageblock_nr_pages) {
 		unsigned long isolated;
+		enum smt_result ret;
 
 		if (!pfn_valid(pfn))
 			continue;
@@ -434,9 +502,12 @@ static void isolate_freepages(struct zon
 			continue;
 
 		/* Check the block is suitable for migration */
-		if (!suitable_migration_target(page))
+		ret = suitable_migration_target(page, cc);
+		if (ret != MIGRATE_TARGET && ret != RESCUE_UNMOVABLE_TARGET) {
+			if (ret == UNMOVABLE_TARGET)
+				cc->nr_unmovable_pageblock++;
 			continue;
-
+		}
 		/*
 		 * Found a block suitable for isolating free pages from. Now
 		 * we disabled interrupts, double check things are ok and
@@ -445,12 +516,16 @@ static void isolate_freepages(struct zon
 		 */
 		isolated = 0;
 		spin_lock_irqsave(&zone->lock, flags);
-		if (suitable_migration_target(page)) {
+		ret = suitable_migration_target(page, cc);
+		if (ret == MIGRATE_TARGET || ret == RESCUE_UNMOVABLE_TARGET) {
+			if (ret == RESCUE_UNMOVABLE_TARGET)
+				rescue_unmovable_pageblock(page);
 			end_pfn = min(pfn + pageblock_nr_pages, zone_end_pfn);
 			isolated = isolate_freepages_block(pfn, end_pfn,
 							   freelist, false);
 			nr_freepages += isolated;
-		}
+		} else if (ret == UNMOVABLE_TARGET)
+			cc->nr_unmovable_pageblock++;
 		spin_unlock_irqrestore(&zone->lock, flags);
 
 		/*
@@ -682,8 +757,9 @@ static int compact_zone(struct zone *zon
 
 		nr_migrate = cc->nr_migratepages;
 		err = migrate_pages(&cc->migratepages, compaction_alloc,
-				(unsigned long)cc, false,
-				cc->sync ? MIGRATE_SYNC_LIGHT : MIGRATE_ASYNC);
+			(unsigned long)&cc->freepages, false,
+			(cc->mode == COMPACT_SYNC) ? MIGRATE_SYNC_LIGHT
+						      : MIGRATE_ASYNC);
 		update_nr_listpages(cc);
 		nr_remaining = cc->nr_migratepages;
 
@@ -712,7 +788,8 @@ out:
 
 static unsigned long compact_zone_order(struct zone *zone,
 				 int order, gfp_t gfp_mask,
-				 bool sync)
+				 enum compact_mode mode,
+				 unsigned long *nr_pageblocks_skipped)
 {
 	struct compact_control cc = {
 		.nr_freepages = 0,
@@ -720,12 +797,17 @@ static unsigned long compact_zone_order(
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
+	*nr_pageblocks_skipped = cc.nr_unmovable_pageblock;
+
+	return rc;
 }
 
 int sysctl_extfrag_threshold = 500;
@@ -750,6 +832,8 @@ unsigned long try_to_compact_pages(struc
 	struct zoneref *z;
 	struct zone *zone;
 	int rc = COMPACT_SKIPPED;
+	unsigned long nr_pageblocks_skipped;
+	enum compact_mode mode;
 
 	/*
 	 * Check whether it is worth even starting compaction. The order check is
@@ -766,12 +850,22 @@ unsigned long try_to_compact_pages(struc
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
@@ -805,7 +899,7 @@ static int __compact_pgdat(pg_data_t *pg
 			if (ok && cc->order > zone->compact_order_failed)
 				zone->compact_order_failed = cc->order + 1;
 			/* Currently async compaction is never deferred. */
-			else if (!ok && cc->sync)
+			else if (!ok && cc->mode == COMPACT_SYNC)
 				defer_compaction(zone, cc->order);
 		}
 
@@ -820,7 +914,7 @@ int compact_pgdat(pg_data_t *pgdat, int 
 {
 	struct compact_control cc = {
 		.order = order,
-		.sync = false,
+		.mode = COMPACT_ASYNC_MOVABLE,
 	};
 
 	return __compact_pgdat(pgdat, &cc);
@@ -830,7 +924,7 @@ static int compact_node(int nid)
 {
 	struct compact_control cc = {
 		.order = -1,
-		.sync = true,
+		.mode = COMPACT_SYNC,
 	};
 
 	return __compact_pgdat(NODE_DATA(nid), &cc);
Index: b/mm/internal.h
===================================================================
--- a/mm/internal.h	2012-06-08 09:01:32.109681656 +0200
+++ b/mm/internal.h	2012-06-08 09:06:09.481681670 +0200
@@ -94,6 +94,11 @@ extern void putback_lru_page(struct page
 /*
  * in mm/page_alloc.c
  */
+extern void set_pageblock_migratetype(struct page *page, int migratetype);
+extern int move_freepages_block(struct zone *zone, struct page *page,
+				int migratetype);
+extern int __count_immobile_pages(struct zone *zone, struct page *page,
+				  int count);
 extern void __free_pages_bootmem(struct page *page, unsigned int order);
 extern void prep_compound_page(struct page *page, unsigned long order);
 #ifdef CONFIG_MEMORY_FAILURE
@@ -101,6 +106,7 @@ extern bool is_free_buddy_page(struct pa
 #endif
 
 #if defined CONFIG_COMPACTION || defined CONFIG_CMA
+#include <linux/compaction.h>
 
 /*
  * in mm/compaction.c
@@ -119,11 +125,14 @@ struct compact_control {
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
+	unsigned long nr_unmovable_pageblock;
 };
 
 unsigned long
Index: b/mm/page_alloc.c
===================================================================
--- a/mm/page_alloc.c	2012-06-08 09:01:32.125681656 +0200
+++ b/mm/page_alloc.c	2012-06-08 09:04:51.693681694 +0200
@@ -219,7 +219,7 @@ EXPORT_SYMBOL(nr_online_nodes);
 
 int page_group_by_mobility_disabled __read_mostly;
 
-static void set_pageblock_migratetype(struct page *page, int migratetype)
+void set_pageblock_migratetype(struct page *page, int migratetype)
 {
 
 	if (unlikely(page_group_by_mobility_disabled))
@@ -954,8 +954,8 @@ static int move_freepages(struct zone *z
 	return pages_moved;
 }
 
-static int move_freepages_block(struct zone *zone, struct page *page,
-				int migratetype)
+int move_freepages_block(struct zone *zone, struct page *page,
+			 int migratetype)
 {
 	unsigned long start_pfn, end_pfn;
 	struct page *start_page, *end_page;
@@ -5476,8 +5476,7 @@ void set_pageblock_flags_group(struct pa
  * page allocater never alloc memory from ISOLATE block.
  */
 
-static int
-__count_immobile_pages(struct zone *zone, struct page *page, int count)
+int __count_immobile_pages(struct zone *zone, struct page *page, int count)
 {
 	unsigned long pfn, iter, found;
 	int mt;
@@ -5500,6 +5499,11 @@ __count_immobile_pages(struct zone *zone
 			continue;
 
 		page = pfn_to_page(check);
+
+		/* Do not deal with pageblocks that overlap zones */
+		if (page_zone(page) != zone)
+			return false;
+
 		if (!page_count(page)) {
 			if (PageBuddy(page))
 				iter += (1 << page_order(page)) - 1;
@@ -5654,7 +5658,7 @@ static int __alloc_contig_migrate_range(
 		.nr_migratepages = 0,
 		.order = -1,
 		.zone = page_zone(pfn_to_page(start)),
-		.sync = true,
+		.mode = COMPACT_SYNC,
 	};
 	INIT_LIST_HEAD(&cc.migratepages);
 
Index: b/mm/vmstat.c
===================================================================
--- a/mm/vmstat.c	2012-06-08 09:39:22.421681379 +0200
+++ b/mm/vmstat.c	2012-06-08 10:02:22.053681226 +0200
@@ -767,6 +767,7 @@ const char * const vmstat_text[] = {
 	"compact_stall",
 	"compact_fail",
 	"compact_success",
+	"compact_rescued_unmovable_blocks",
 #endif
 
 #ifdef CONFIG_HUGETLB_PAGE

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
