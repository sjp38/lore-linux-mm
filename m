Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 0809B6B006C
	for <linux-mm@kvack.org>; Fri, 24 Aug 2012 06:45:51 -0400 (EDT)
Received: from epcpsbgm1.samsung.com (mailout2.samsung.com [203.254.224.25])
 by mailout2.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0M99003ET9V7INU0@mailout2.samsung.com> for
 linux-mm@kvack.org; Fri, 24 Aug 2012 19:45:39 +0900 (KST)
Received: from mcdsrvbld02.digital.local ([106.116.37.23])
 by mmp1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0M990073E9VOI960@mmp1.samsung.com> for linux-mm@kvack.org;
 Fri, 24 Aug 2012 19:45:39 +0900 (KST)
From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: [PATCH 2/4] cma: count free CMA pages
Date: Fri, 24 Aug 2012 12:45:18 +0200
Message-id: <1345805120-797-3-git-send-email-b.zolnierkie@samsung.com>
In-reply-to: <1345805120-797-1-git-send-email-b.zolnierkie@samsung.com>
References: <1345805120-797-1-git-send-email-b.zolnierkie@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: m.szyprowski@samsung.com, mina86@mina86.com, minchan@kernel.org, mgorman@suse.de, kyungmin.park@samsung.com, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>

Add NR_FREE_CMA_PAGES counter to be later used for checking watermark
in __zone_watermark_ok().  For simplicity and to avoid #ifdef hell make
this counter always available (not only when CONFIG_CMA=y).

Cc: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Michal Nazarewicz <mina86@mina86.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>
Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 include/linux/mmzone.h |  3 +++
 mm/page_alloc.c        | 39 +++++++++++++++++++++++++++++++++++----
 mm/page_isolation.c    |  7 +++++++
 mm/vmstat.c            |  1 +
 4 files changed, 46 insertions(+), 4 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index ca034a1..1ef0696 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -62,8 +62,10 @@ enum {
 };
 
 #ifdef CONFIG_CMA
+bool is_cma_pageblock(struct page *page);
 #  define is_migrate_cma(migratetype) unlikely((migratetype) == MIGRATE_CMA)
 #else
+#  define is_cma_pageblock(page) false
 #  define is_migrate_cma(migratetype) false
 #endif
 
@@ -140,6 +142,7 @@ enum zone_stat_item {
 	NUMA_OTHER,		/* allocation from other node */
 #endif
 	NR_ANON_TRANSPARENT_HUGEPAGES,
+	NR_FREE_CMA_PAGES,
 	NR_VM_ZONE_STAT_ITEMS };
 
 /*
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e9bbd7c..e28e506 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -559,6 +559,9 @@ static inline void __free_one_page(struct page *page,
 			clear_page_guard_flag(buddy);
 			set_page_private(page, 0);
 			__mod_zone_page_state(zone, NR_FREE_PAGES, 1 << order);
+			if (is_cma_pageblock(page))
+				__mod_zone_page_state(zone, NR_FREE_CMA_PAGES,
+						      1 << order);
 		} else {
 			list_del(&buddy->lru);
 			zone->free_area[order].nr_free--;
@@ -674,6 +677,8 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 			/* MIGRATE_MOVABLE list may include MIGRATE_RESERVEs */
 			__free_one_page(page, zone, 0, page_private(page));
 			trace_mm_page_pcpu_drain(page, 0, page_private(page));
+			if (is_cma_pageblock(page))
+				__mod_zone_page_state(zone, NR_FREE_CMA_PAGES, 1);
 		} while (--to_free && --batch_free && !list_empty(list));
 	}
 	__mod_zone_page_state(zone, NR_FREE_PAGES, count);
@@ -688,8 +693,12 @@ static void free_one_page(struct zone *zone, struct page *page, int order,
 	zone->pages_scanned = 0;
 
 	__free_one_page(page, zone, order, migratetype);
-	if (get_pageblock_migratetype(page) != MIGRATE_ISOLATE)
+	if (get_pageblock_migratetype(page) != MIGRATE_ISOLATE) {
 		__mod_zone_page_state(zone, NR_FREE_PAGES, 1 << order);
+		if (is_cma_pageblock(page))
+			__mod_zone_page_state(zone, NR_FREE_CMA_PAGES,
+					      1 << order);
+	}
 	spin_unlock(&zone->lock);
 }
 
@@ -756,6 +765,11 @@ void __meminit __free_pages_bootmem(struct page *page, unsigned int order)
 }
 
 #ifdef CONFIG_CMA
+bool is_cma_pageblock(struct page *page)
+{
+	return get_pageblock_migratetype(page) == MIGRATE_CMA;
+}
+
 /* Free whole pageblock and set it's migration type to MIGRATE_CMA. */
 void __init init_cma_reserved_pageblock(struct page *page)
 {
@@ -813,6 +827,9 @@ static inline void expand(struct zone *zone, struct page *page,
 			set_page_private(&page[size], high);
 			/* Guard pages are not available for any usage */
 			__mod_zone_page_state(zone, NR_FREE_PAGES, -(1 << high));
+			if (is_cma_pageblock(&page[size]))
+				__mod_zone_page_state(zone, NR_FREE_CMA_PAGES,
+						      -(1 << high));
 			continue;
 		}
 #endif
@@ -1138,6 +1155,9 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
 		}
 		set_page_private(page, mt);
 		list = &page->lru;
+		if (is_cma_pageblock(page))
+			__mod_zone_page_state(zone, NR_FREE_CMA_PAGES,
+					      -(1 << order));
 	}
 	__mod_zone_page_state(zone, NR_FREE_PAGES, -(i << order));
 	spin_unlock(&zone->lock);
@@ -1414,8 +1434,12 @@ int split_free_page(struct page *page, bool check_wmark)
 	zone->free_area[order].nr_free--;
 	rmv_page_order(page);
 
-	if (get_pageblock_migratetype(page) != MIGRATE_ISOLATE)
+	if (get_pageblock_migratetype(page) != MIGRATE_ISOLATE) {
 		__mod_zone_page_state(zone, NR_FREE_PAGES, -(1UL << order));
+		if (is_cma_pageblock(page))
+			__mod_zone_page_state(zone, NR_FREE_CMA_PAGES,
+					      -(1UL << order));
+	}
 
 	/* Split into individual pages */
 	set_page_refcounted(page);
@@ -1490,6 +1514,9 @@ again:
 		spin_unlock(&zone->lock);
 		if (!page)
 			goto failed;
+		if (is_cma_pageblock(page))
+			__mod_zone_page_state(zone, NR_FREE_CMA_PAGES,
+					      -(1 << order));
 		__mod_zone_page_state(zone, NR_FREE_PAGES, -(1 << order));
 	}
 
@@ -2852,7 +2879,8 @@ void show_free_areas(unsigned int filter)
 		" unevictable:%lu"
 		" dirty:%lu writeback:%lu unstable:%lu\n"
 		" free:%lu slab_reclaimable:%lu slab_unreclaimable:%lu\n"
-		" mapped:%lu shmem:%lu pagetables:%lu bounce:%lu\n",
+		" mapped:%lu shmem:%lu pagetables:%lu bounce:%lu\n"
+		" free_cma:%lu\n",
 		global_page_state(NR_ACTIVE_ANON),
 		global_page_state(NR_INACTIVE_ANON),
 		global_page_state(NR_ISOLATED_ANON),
@@ -2869,7 +2897,8 @@ void show_free_areas(unsigned int filter)
 		global_page_state(NR_FILE_MAPPED),
 		global_page_state(NR_SHMEM),
 		global_page_state(NR_PAGETABLE),
-		global_page_state(NR_BOUNCE));
+		global_page_state(NR_BOUNCE),
+		global_page_state(NR_FREE_CMA_PAGES));
 
 	for_each_populated_zone(zone) {
 		int i;
@@ -2901,6 +2930,7 @@ void show_free_areas(unsigned int filter)
 			" pagetables:%lukB"
 			" unstable:%lukB"
 			" bounce:%lukB"
+			" free_cma:%lukB"
 			" writeback_tmp:%lukB"
 			" pages_scanned:%lu"
 			" all_unreclaimable? %s"
@@ -2930,6 +2960,7 @@ void show_free_areas(unsigned int filter)
 			K(zone_page_state(zone, NR_PAGETABLE)),
 			K(zone_page_state(zone, NR_UNSTABLE_NFS)),
 			K(zone_page_state(zone, NR_BOUNCE)),
+			K(zone_page_state(zone, NR_FREE_CMA_PAGES)),
 			K(zone_page_state(zone, NR_WRITEBACK_TEMP)),
 			zone->pages_scanned,
 			(zone->all_unreclaimable ? "yes" : "no")
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index d210cc8..b8dba12 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -77,11 +77,15 @@ int set_migratetype_isolate(struct page *page)
 out:
 	if (!ret) {
 		unsigned long nr_pages;
+		int mt = get_pageblock_migratetype(page);
 
 		set_pageblock_isolate(page);
 		nr_pages = move_freepages_block(zone, page, MIGRATE_ISOLATE);
 
 		__mod_zone_page_state(zone, NR_FREE_PAGES, -nr_pages);
+		if (mt == MIGRATE_CMA)
+			__mod_zone_page_state(zone, NR_FREE_CMA_PAGES,
+					      -nr_pages);
 	}
 
 	spin_unlock_irqrestore(&zone->lock, flags);
@@ -102,6 +106,9 @@ void unset_migratetype_isolate(struct page *page, unsigned migratetype)
 		goto out;
 	nr_pages = move_freepages_block(zone, page, migratetype);
 	__mod_zone_page_state(zone, NR_FREE_PAGES, nr_pages);
+	if (migratetype == MIGRATE_CMA)
+		__mod_zone_page_state(zone, NR_FREE_CMA_PAGES,
+				      nr_pages);
 	restore_pageblock_isolate(page, migratetype);
 out:
 	spin_unlock_irqrestore(&zone->lock, flags);
diff --git a/mm/vmstat.c b/mm/vmstat.c
index df7a674..7c102e6 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -722,6 +722,7 @@ const char * const vmstat_text[] = {
 	"numa_other",
 #endif
 	"nr_anon_transparent_hugepages",
+	"nr_free_cma",
 	"nr_dirty_threshold",
 	"nr_dirty_background_threshold",
 
-- 
1.7.11.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
