Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 5F86C6B0268
	for <linux-mm@kvack.org>; Fri, 14 Sep 2012 10:29:58 -0400 (EDT)
Received: from epcpsbgm1.samsung.com (epcpsbgm1 [203.254.230.26])
 by mailout1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MAC00ISUG9ML0C0@mailout1.samsung.com> for
 linux-mm@kvack.org; Fri, 14 Sep 2012 23:29:57 +0900 (KST)
Received: from mcdsrvbld02.digital.local ([106.116.37.23])
 by mmp2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0MAC00M85G9E5EA0@mmp2.samsung.com> for linux-mm@kvack.org;
 Fri, 14 Sep 2012 23:29:56 +0900 (KST)
From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: [PATCH v4 3/4] cma: count free CMA pages
Date: Fri, 14 Sep 2012 16:29:33 +0200
Message-id: <1347632974-20465-4-git-send-email-b.zolnierkie@samsung.com>
In-reply-to: <1347632974-20465-1-git-send-email-b.zolnierkie@samsung.com>
References: <1347632974-20465-1-git-send-email-b.zolnierkie@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: m.szyprowski@samsung.com, mina86@mina86.com, minchan@kernel.org, mgorman@suse.de, hughd@google.com, kyungmin.park@samsung.com, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>

Add NR_FREE_CMA_PAGES counter to be later used for checking watermark
in __zone_watermark_ok().  For simplicity and to avoid #ifdef hell make
this counter always available (not only when CONFIG_CMA=y).

Cc: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Michal Nazarewicz <mina86@mina86.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 include/linux/mmzone.h |  1 +
 include/linux/vmstat.h |  8 ++++++++
 mm/page_alloc.c        | 26 +++++++++++++++++++-------
 mm/page_isolation.c    |  5 +++--
 mm/vmstat.c            |  1 +
 5 files changed, 32 insertions(+), 9 deletions(-)

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
diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index ad2cfd5..a5bb150 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -253,6 +253,14 @@ static inline void refresh_zone_stat_thresholds(void) { }
 
 #endif		/* CONFIG_SMP */
 
+static inline void __mod_zone_freepage_state(struct zone *zone, int nr_pages,
+					     int migratetype)
+{
+	__mod_zone_page_state(zone, NR_FREE_PAGES, nr_pages);
+	if (is_migrate_cma(migratetype))
+		__mod_zone_page_state(zone, NR_FREE_CMA_PAGES, nr_pages);
+}
+
 extern const char * const vmstat_text[];
 
 #endif /* _LINUX_VMSTAT_H */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6a59e42..287f79d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -558,7 +558,8 @@ static inline void __free_one_page(struct page *page,
 		if (page_is_guard(buddy)) {
 			clear_page_guard_flag(buddy);
 			set_page_private(page, 0);
-			__mod_zone_page_state(zone, NR_FREE_PAGES, 1 << order);
+			__mod_zone_freepage_state(zone, 1 << order,
+						  migratetype);
 		} else {
 			list_del(&buddy->lru);
 			zone->free_area[order].nr_free--;
@@ -677,6 +678,8 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 			/* MIGRATE_MOVABLE list may include MIGRATE_RESERVEs */
 			__free_one_page(page, zone, 0, mt);
 			trace_mm_page_pcpu_drain(page, 0, mt);
+			if (is_migrate_cma(mt))
+				__mod_zone_page_state(zone, NR_FREE_CMA_PAGES, 1);
 		} while (--to_free && --batch_free && !list_empty(list));
 	}
 	__mod_zone_page_state(zone, NR_FREE_PAGES, count);
@@ -692,7 +695,7 @@ static void free_one_page(struct zone *zone, struct page *page, int order,
 
 	__free_one_page(page, zone, order, migratetype);
 	if (unlikely(migratetype != MIGRATE_ISOLATE))
-		__mod_zone_page_state(zone, NR_FREE_PAGES, 1 << order);
+		__mod_zone_freepage_state(zone, 1 << order, migratetype);
 	spin_unlock(&zone->lock);
 }
 
@@ -815,7 +818,8 @@ static inline void expand(struct zone *zone, struct page *page,
 			set_page_guard_flag(&page[size]);
 			set_page_private(&page[size], high);
 			/* Guard pages are not available for any usage */
-			__mod_zone_page_state(zone, NR_FREE_PAGES, -(1 << high));
+			__mod_zone_freepage_state(zone, -(1 << high),
+						  migratetype);
 			continue;
 		}
 #endif
@@ -1141,6 +1145,9 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
 		}
 		set_page_private(page, mt);
 		list = &page->lru;
+		if (is_migrate_cma(mt))
+			__mod_zone_page_state(zone, NR_FREE_CMA_PAGES,
+					      -(1 << order));
 	}
 	__mod_zone_page_state(zone, NR_FREE_PAGES, -(i << order));
 	spin_unlock(&zone->lock);
@@ -1419,7 +1426,7 @@ int split_free_page(struct page *page, bool check_wmark)
 
 	mt = get_pageblock_migratetype(page);
 	if (unlikely(mt != MIGRATE_ISOLATE))
-		__mod_zone_page_state(zone, NR_FREE_PAGES, -(1UL << order));
+		__mod_zone_freepage_state(zone, -(1UL << order), mt);
 
 	/* Split into individual pages */
 	set_page_refcounted(page);
@@ -1494,7 +1501,8 @@ again:
 		spin_unlock(&zone->lock);
 		if (!page)
 			goto failed;
-		__mod_zone_page_state(zone, NR_FREE_PAGES, -(1 << order));
+		__mod_zone_freepage_state(zone, -(1 << order),
+					  get_pageblock_migratetype(page));
 	}
 
 	__count_zone_vm_events(PGALLOC, zone, 1 << order);
@@ -2862,7 +2870,8 @@ void show_free_areas(unsigned int filter)
 		" unevictable:%lu"
 		" dirty:%lu writeback:%lu unstable:%lu\n"
 		" free:%lu slab_reclaimable:%lu slab_unreclaimable:%lu\n"
-		" mapped:%lu shmem:%lu pagetables:%lu bounce:%lu\n",
+		" mapped:%lu shmem:%lu pagetables:%lu bounce:%lu\n"
+		" free_cma:%lu\n",
 		global_page_state(NR_ACTIVE_ANON),
 		global_page_state(NR_INACTIVE_ANON),
 		global_page_state(NR_ISOLATED_ANON),
@@ -2879,7 +2888,8 @@ void show_free_areas(unsigned int filter)
 		global_page_state(NR_FILE_MAPPED),
 		global_page_state(NR_SHMEM),
 		global_page_state(NR_PAGETABLE),
-		global_page_state(NR_BOUNCE));
+		global_page_state(NR_BOUNCE),
+		global_page_state(NR_FREE_CMA_PAGES));
 
 	for_each_populated_zone(zone) {
 		int i;
@@ -2911,6 +2921,7 @@ void show_free_areas(unsigned int filter)
 			" pagetables:%lukB"
 			" unstable:%lukB"
 			" bounce:%lukB"
+			" free_cma:%lukB"
 			" writeback_tmp:%lukB"
 			" pages_scanned:%lu"
 			" all_unreclaimable? %s"
@@ -2940,6 +2951,7 @@ void show_free_areas(unsigned int filter)
 			K(zone_page_state(zone, NR_PAGETABLE)),
 			K(zone_page_state(zone, NR_UNSTABLE_NFS)),
 			K(zone_page_state(zone, NR_BOUNCE)),
+			K(zone_page_state(zone, NR_FREE_CMA_PAGES)),
 			K(zone_page_state(zone, NR_WRITEBACK_TEMP)),
 			zone->pages_scanned,
 			(zone->all_unreclaimable ? "yes" : "no")
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index 3ca1716..bce97c9 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -77,11 +77,12 @@ int set_migratetype_isolate(struct page *page)
 out:
 	if (!ret) {
 		unsigned long nr_pages;
+		int mt = get_pageblock_migratetype(page);
 
 		set_pageblock_isolate(page);
 		nr_pages = move_freepages_block(zone, page, MIGRATE_ISOLATE);
 
-		__mod_zone_page_state(zone, NR_FREE_PAGES, -nr_pages);
+		__mod_zone_freepage_state(zone, -nr_pages, mt);
 	}
 
 	spin_unlock_irqrestore(&zone->lock, flags);
@@ -100,7 +101,7 @@ void unset_migratetype_isolate(struct page *page, unsigned migratetype)
 	if (get_pageblock_migratetype(page) != MIGRATE_ISOLATE)
 		goto out;
 	nr_pages = move_freepages_block(zone, page, migratetype);
-	__mod_zone_page_state(zone, NR_FREE_PAGES, nr_pages);
+	__mod_zone_freepage_state(zone, nr_pages, migratetype);
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
