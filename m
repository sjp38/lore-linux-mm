Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 8A45E6B006C
	for <linux-mm@kvack.org>; Mon,  3 Sep 2012 11:33:32 -0400 (EDT)
Received: from epcpsbgm2.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0M9S00IAK5VPATU0@mailout1.samsung.com> for
 linux-mm@kvack.org; Tue, 04 Sep 2012 00:33:31 +0900 (KST)
Received: from mcdsrvbld02.digital.local ([106.116.37.23])
 by mmp1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0M9S000OM5VGTX90@mmp1.samsung.com> for linux-mm@kvack.org;
 Tue, 04 Sep 2012 00:33:31 +0900 (KST)
From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: [PATCH v2 2/4] cma: count free CMA pages
Date: Mon, 03 Sep 2012 17:33:02 +0200
Message-id: <1346686384-1866-3-git-send-email-b.zolnierkie@samsung.com>
In-reply-to: <1346686384-1866-1-git-send-email-b.zolnierkie@samsung.com>
References: <1346686384-1866-1-git-send-email-b.zolnierkie@samsung.com>
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
 include/linux/mmzone.h |  1 +
 mm/page_alloc.c        | 36 ++++++++++++++++++++++++++++++++----
 mm/page_isolation.c    |  7 +++++++
 mm/vmstat.c            |  1 +
 4 files changed, 41 insertions(+), 4 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index ca034a1..904889d 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -140,6 +140,7 @@ enum zone_stat_item {
 	NUMA_OTHER,		/* allocation from other node */
 #endif
 	NR_ANON_TRANSPARENT_HUGEPAGES,
+	NR_FREE_CMA_PAGES,
 	NR_VM_ZONE_STAT_ITEMS };
 
 /*
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 64ccf72..8afae42 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -559,6 +559,9 @@ static inline void __free_one_page(struct page *page,
 			clear_page_guard_flag(buddy);
 			set_page_private(page, 0);
 			__mod_zone_page_state(zone, NR_FREE_PAGES, 1 << order);
+			if (is_migrate_cma(migratetype))
+				__mod_zone_page_state(zone, NR_FREE_CMA_PAGES,
+						      1 << order);
 		} else {
 			list_del(&buddy->lru);
 			zone->free_area[order].nr_free--;
@@ -674,6 +677,8 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 			/* MIGRATE_MOVABLE list may include MIGRATE_RESERVEs */
 			__free_one_page(page, zone, 0, page_private(page));
 			trace_mm_page_pcpu_drain(page, 0, page_private(page));
+			if (is_migrate_cma(page_private(page)))
+				__mod_zone_page_state(zone, NR_FREE_CMA_PAGES, 1);
 		} while (--to_free && --batch_free && !list_empty(list));
 	}
 	__mod_zone_page_state(zone, NR_FREE_PAGES, count);
@@ -688,8 +693,12 @@ static void free_one_page(struct zone *zone, struct page *page, int order,
 	zone->pages_scanned = 0;
 
 	__free_one_page(page, zone, order, migratetype);
-	if (migratetype != MIGRATE_ISOLATE)
+	if (migratetype != MIGRATE_ISOLATE) {
 		__mod_zone_page_state(zone, NR_FREE_PAGES, 1 << order);
+		if (is_migrate_cma(migratetype))
+			__mod_zone_page_state(zone, NR_FREE_CMA_PAGES,
+					      1 << order);
+	}
 	spin_unlock(&zone->lock);
 }
 
@@ -813,6 +822,9 @@ static inline void expand(struct zone *zone, struct page *page,
 			set_page_private(&page[size], high);
 			/* Guard pages are not available for any usage */
 			__mod_zone_page_state(zone, NR_FREE_PAGES, -(1 << high));
+			if (is_migrate_cma(migratetype))
+				__mod_zone_page_state(zone, NR_FREE_CMA_PAGES,
+						      -(1 << high));
 			continue;
 		}
 #endif
@@ -1138,6 +1150,9 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
 		}
 		set_page_private(page, mt);
 		list = &page->lru;
+		if (is_migrate_cma(mt))
+			__mod_zone_page_state(zone, NR_FREE_CMA_PAGES,
+					      -(1 << order));
 	}
 	__mod_zone_page_state(zone, NR_FREE_PAGES, -(i << order));
 	spin_unlock(&zone->lock);
@@ -1396,6 +1411,7 @@ int split_free_page(struct page *page, bool check_wmark)
 	unsigned int order;
 	unsigned long watermark;
 	struct zone *zone;
+	int mt;
 
 	BUG_ON(!PageBuddy(page));
 
@@ -1414,8 +1430,13 @@ int split_free_page(struct page *page, bool check_wmark)
 	zone->free_area[order].nr_free--;
 	rmv_page_order(page);
 
-	if (get_pageblock_migratetype(page) != MIGRATE_ISOLATE)
+	mt = get_pageblock_migratetype(page);
+	if (mt != MIGRATE_ISOLATE) {
 		__mod_zone_page_state(zone, NR_FREE_PAGES, -(1UL << order));
+		if (is_migrate_cma(mt))
+			__mod_zone_page_state(zone, NR_FREE_CMA_PAGES,
+					      -(1UL << order));
+	}
 
 	/* Split into individual pages */
 	set_page_refcounted(page);
@@ -1490,6 +1511,9 @@ again:
 		spin_unlock(&zone->lock);
 		if (!page)
 			goto failed;
+		if (is_migrate_cma(get_pageblock_migratetype(page)))
+			__mod_zone_page_state(zone, NR_FREE_CMA_PAGES,
+					      -(1 << order));
 		__mod_zone_page_state(zone, NR_FREE_PAGES, -(1 << order));
 	}
 
@@ -2852,7 +2876,8 @@ void show_free_areas(unsigned int filter)
 		" unevictable:%lu"
 		" dirty:%lu writeback:%lu unstable:%lu\n"
 		" free:%lu slab_reclaimable:%lu slab_unreclaimable:%lu\n"
-		" mapped:%lu shmem:%lu pagetables:%lu bounce:%lu\n",
+		" mapped:%lu shmem:%lu pagetables:%lu bounce:%lu\n"
+		" free_cma:%lu\n",
 		global_page_state(NR_ACTIVE_ANON),
 		global_page_state(NR_INACTIVE_ANON),
 		global_page_state(NR_ISOLATED_ANON),
@@ -2869,7 +2894,8 @@ void show_free_areas(unsigned int filter)
 		global_page_state(NR_FILE_MAPPED),
 		global_page_state(NR_SHMEM),
 		global_page_state(NR_PAGETABLE),
-		global_page_state(NR_BOUNCE));
+		global_page_state(NR_BOUNCE),
+		global_page_state(NR_FREE_CMA_PAGES));
 
 	for_each_populated_zone(zone) {
 		int i;
@@ -2901,6 +2927,7 @@ void show_free_areas(unsigned int filter)
 			" pagetables:%lukB"
 			" unstable:%lukB"
 			" bounce:%lukB"
+			" free_cma:%lukB"
 			" writeback_tmp:%lukB"
 			" pages_scanned:%lu"
 			" all_unreclaimable? %s"
@@ -2930,6 +2957,7 @@ void show_free_areas(unsigned int filter)
 			K(zone_page_state(zone, NR_PAGETABLE)),
 			K(zone_page_state(zone, NR_UNSTABLE_NFS)),
 			K(zone_page_state(zone, NR_BOUNCE)),
+			K(zone_page_state(zone, NR_FREE_CMA_PAGES)),
 			K(zone_page_state(zone, NR_WRITEBACK_TEMP)),
 			zone->pages_scanned,
 			(zone->all_unreclaimable ? "yes" : "no")
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index d210cc8..6ead34d 100644
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
+		if (is_migrate_cma(mt))
+			__mod_zone_page_state(zone, NR_FREE_CMA_PAGES,
+					      -nr_pages);
 	}
 
 	spin_unlock_irqrestore(&zone->lock, flags);
@@ -102,6 +106,9 @@ void unset_migratetype_isolate(struct page *page, unsigned migratetype)
 		goto out;
 	nr_pages = move_freepages_block(zone, page, migratetype);
 	__mod_zone_page_state(zone, NR_FREE_PAGES, nr_pages);
+	if (is_migrate_cma(migratetype))
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
