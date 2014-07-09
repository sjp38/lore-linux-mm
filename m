Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f180.google.com (mail-we0-f180.google.com [74.125.82.180])
	by kanga.kvack.org (Postfix) with ESMTP id 4FECC8298E
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 04:13:14 -0400 (EDT)
Received: by mail-we0-f180.google.com with SMTP id x48so7027729wes.39
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 01:13:13 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gv8si6798978wib.98.2014.07.09.01.13.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 09 Jul 2014 01:13:13 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 3/6] mm: Move zone->pages_scanned into a vmstat counter
Date: Wed,  9 Jul 2014 09:13:05 +0100
Message-Id: <1404893588-21371-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1404893588-21371-1-git-send-email-mgorman@suse.de>
References: <1404893588-21371-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>

zone->pages_scanned is a write-intensive cache line during page reclaim
and it's also updated during page free. Move the counter into vmstat to
take advantage of the per-cpu updates and do not update it in the free
paths unless necessary.

On a small UMA machine running tiobench the difference is marginal. On a
4-node machine the overhead is more noticable. Note that automatic NUMA
balancing was disabled for this test as otherwise the system CPU overhead
is unpredictable.

          3.16.0-rc3  3.16.0-rc3  3.16.0-rc3
             vanillarearrange-v5   vmstat-v5
User          746.94      759.78      774.56
System      65336.22    58350.98    32847.27
Elapsed     27553.52    27282.02    27415.04

Note that the overhead reduction will vary depending on where exactly
pages are allocated and freed.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/mmzone.h |  2 +-
 mm/page_alloc.c        | 12 +++++++++---
 mm/vmscan.c            |  7 ++++---
 mm/vmstat.c            |  3 ++-
 4 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index fbadc45..c0ee2ec 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -143,6 +143,7 @@ enum zone_stat_item {
 	NR_SHMEM,		/* shmem pages (included tmpfs/GEM pages) */
 	NR_DIRTIED,		/* page dirtyings since bootup */
 	NR_WRITTEN,		/* page writings since bootup */
+	NR_PAGES_SCANNED,	/* pages scanned since last reclaim */
 #ifdef CONFIG_NUMA
 	NUMA_HIT,		/* allocated in intended node */
 	NUMA_MISS,		/* allocated in non intended node */
@@ -480,7 +481,6 @@ struct zone {
 
 	/* Fields commonly accessed by the page reclaim scanner */
 	spinlock_t		lru_lock;
-	unsigned long		pages_scanned;	   /* since last reclaim */
 	struct lruvec		lruvec;
 
 	/* Evictions & activations on the inactive file list */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c607acd..aa46f00 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -680,9 +680,12 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 	int migratetype = 0;
 	int batch_free = 0;
 	int to_free = count;
+	unsigned long nr_scanned;
 
 	spin_lock(&zone->lock);
-	zone->pages_scanned = 0;
+	nr_scanned = zone_page_state(zone, NR_PAGES_SCANNED);
+	if (nr_scanned)
+		__mod_zone_page_state(zone, NR_PAGES_SCANNED, -nr_scanned);
 
 	while (to_free) {
 		struct page *page;
@@ -731,8 +734,11 @@ static void free_one_page(struct zone *zone,
 				unsigned int order,
 				int migratetype)
 {
+	unsigned long nr_scanned;
 	spin_lock(&zone->lock);
-	zone->pages_scanned = 0;
+	nr_scanned = zone_page_state(zone, NR_PAGES_SCANNED);
+	if (nr_scanned)
+		__mod_zone_page_state(zone, NR_PAGES_SCANNED, -nr_scanned);
 
 	__free_one_page(page, pfn, zone, order, migratetype);
 	if (unlikely(!is_migrate_isolate(migratetype)))
@@ -3240,7 +3246,7 @@ void show_free_areas(unsigned int filter)
 			K(zone_page_state(zone, NR_BOUNCE)),
 			K(zone_page_state(zone, NR_FREE_CMA_PAGES)),
 			K(zone_page_state(zone, NR_WRITEBACK_TEMP)),
-			zone->pages_scanned,
+			K(zone_page_state(zone, NR_PAGES_SCANNED)),
 			(!zone_reclaimable(zone) ? "yes" : "no")
 			);
 		printk("lowmem_reserve[]:");
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 0f16ffe..761c628 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -169,7 +169,8 @@ static unsigned long zone_reclaimable_pages(struct zone *zone)
 
 bool zone_reclaimable(struct zone *zone)
 {
-	return zone->pages_scanned < zone_reclaimable_pages(zone) * 6;
+	return zone_page_state(zone, NR_PAGES_SCANNED) <
+		zone_reclaimable_pages(zone) * 6;
 }
 
 static unsigned long get_lru_size(struct lruvec *lruvec, enum lru_list lru)
@@ -1503,7 +1504,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, nr_taken);
 
 	if (global_reclaim(sc)) {
-		zone->pages_scanned += nr_scanned;
+		__mod_zone_page_state(zone, NR_PAGES_SCANNED, nr_scanned);
 		if (current_is_kswapd())
 			__count_zone_vm_events(PGSCAN_KSWAPD, zone, nr_scanned);
 		else
@@ -1693,7 +1694,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	nr_taken = isolate_lru_pages(nr_to_scan, lruvec, &l_hold,
 				     &nr_scanned, sc, isolate_mode, lru);
 	if (global_reclaim(sc))
-		zone->pages_scanned += nr_scanned;
+		__mod_zone_page_state(zone, NR_PAGES_SCANNED, nr_scanned);
 
 	reclaim_stat->recent_scanned[file] += nr_taken;
 
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 8267f77..e574e883 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -763,6 +763,7 @@ const char * const vmstat_text[] = {
 	"nr_shmem",
 	"nr_dirtied",
 	"nr_written",
+	"nr_pages_scanned",
 
 #ifdef CONFIG_NUMA
 	"numa_hit",
@@ -1067,7 +1068,7 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
 		   min_wmark_pages(zone),
 		   low_wmark_pages(zone),
 		   high_wmark_pages(zone),
-		   zone->pages_scanned,
+		   zone_page_state(zone, NR_PAGES_SCANNED),
 		   zone->spanned_pages,
 		   zone->present_pages,
 		   zone->managed_pages);
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
