Message-Id: <200610201953.k9KJrXCu032315@shell0.pdx.osdl.net>
Subject: [patch 1/4] vmscan: Fix temp_priority race
From: akpm@osdl.org
Date: Fri, 20 Oct 2006 12:53:32 -0700
Sender: owner-linux-mm@kvack.org
From: Martin Bligh <mbligh@mbligh.org>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@osdl.org, mbligh@mbligh.org, clameter@engr.sgi.com, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

The temp_priority field in zone is racy, as we can walk through a reclaim
path, and just before we copy it into prev_priority, it can be overwritten
(say with DEF_PRIORITY) by another reclaimer.

The same bug is contained in both try_to_free_pages and balance_pgdat, but
it is fixed slightly differently.  In balance_pgdat, we keep a separate
priority record per zone in a local array.  In try_to_free_pages there is
no need to do this, as the priority level is the same for all zones that we
reclaim from.

Impact of this bug is that temp_priority is copied into prev_priority, and
setting this artificially high causes reclaimers to set distress
artificially low.  They then fail to reclaim mapped pages, when they are,
in fact, under severe memory pressure (their priority may be as low as 0). 
This causes the OOM killer to fire incorrectly.

Cc: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Christoph Lameter <clameter@engr.sgi.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 include/linux/mmzone.h |    6 +-----
 mm/page_alloc.c        |    2 +-
 mm/vmscan.c            |   22 ++++++++++++----------
 mm/vmstat.c            |    2 --
 4 files changed, 14 insertions(+), 18 deletions(-)

diff -puN include/linux/mmzone.h~vmscan-fix-temp_priority-race include/linux/mmzone.h
--- a/include/linux/mmzone.h~vmscan-fix-temp_priority-race
+++ a/include/linux/mmzone.h
@@ -218,13 +218,9 @@ struct zone {
 	 * under - it drives the swappiness decision: whether to unmap mapped
 	 * pages.
 	 *
-	 * temp_priority is used to remember the scanning priority at which
-	 * this zone was successfully refilled to free_pages == pages_high.
-	 *
-	 * Access to both these fields is quite racy even on uniprocessor.  But
+	 * Access to both this field is quite racy even on uniprocessor.  But
 	 * it is expected to average out OK.
 	 */
-	int temp_priority;
 	int prev_priority;
 
 
diff -puN mm/page_alloc.c~vmscan-fix-temp_priority-race mm/page_alloc.c
--- a/mm/page_alloc.c~vmscan-fix-temp_priority-race
+++ a/mm/page_alloc.c
@@ -2407,7 +2407,7 @@ static void __meminit free_area_init_cor
 		zone->zone_pgdat = pgdat;
 		zone->free_pages = 0;
 
-		zone->temp_priority = zone->prev_priority = DEF_PRIORITY;
+		zone->prev_priority = DEF_PRIORITY;
 
 		zone_pcp_init(zone);
 		INIT_LIST_HEAD(&zone->active_list);
diff -puN mm/vmscan.c~vmscan-fix-temp_priority-race mm/vmscan.c
--- a/mm/vmscan.c~vmscan-fix-temp_priority-race
+++ a/mm/vmscan.c
@@ -972,7 +972,6 @@ static unsigned long shrink_zones(int pr
 		if (!cpuset_zone_allowed(zone, __GFP_HARDWALL))
 			continue;
 
-		zone->temp_priority = priority;
 		if (zone->prev_priority > priority)
 			zone->prev_priority = priority;
 
@@ -1024,7 +1023,6 @@ unsigned long try_to_free_pages(struct z
 		if (!cpuset_zone_allowed(zone, __GFP_HARDWALL))
 			continue;
 
-		zone->temp_priority = DEF_PRIORITY;
 		lru_pages += zone->nr_active + zone->nr_inactive;
 	}
 
@@ -1065,13 +1063,15 @@ unsigned long try_to_free_pages(struct z
 	if (!sc.all_unreclaimable)
 		ret = 1;
 out:
+	if (priority < 0)
+		priority = 0;
 	for (i = 0; zones[i] != 0; i++) {
 		struct zone *zone = zones[i];
 
 		if (!cpuset_zone_allowed(zone, __GFP_HARDWALL))
 			continue;
 
-		zone->prev_priority = zone->temp_priority;
+		zone->prev_priority = priority;
 	}
 	return ret;
 }
@@ -1111,6 +1111,11 @@ static unsigned long balance_pgdat(pg_da
 		.swap_cluster_max = SWAP_CLUSTER_MAX,
 		.swappiness = vm_swappiness,
 	};
+	/*
+	 * temp_priority is used to remember the scanning priority at which
+	 * this zone was successfully refilled to free_pages == pages_high.
+	 */
+	int temp_priority[MAX_NR_ZONES];
 
 loop_again:
 	total_scanned = 0;
@@ -1118,11 +1123,8 @@ loop_again:
 	sc.may_writepage = !laptop_mode;
 	count_vm_event(PAGEOUTRUN);
 
-	for (i = 0; i < pgdat->nr_zones; i++) {
-		struct zone *zone = pgdat->node_zones + i;
-
-		zone->temp_priority = DEF_PRIORITY;
-	}
+	for (i = 0; i < pgdat->nr_zones; i++)
+		temp_priority[i] = DEF_PRIORITY;
 
 	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
 		int end_zone = 0;	/* Inclusive.  0 = ZONE_DMA */
@@ -1183,7 +1185,7 @@ scan:
 			if (!zone_watermark_ok(zone, order, zone->pages_high,
 					       end_zone, 0))
 				all_zones_ok = 0;
-			zone->temp_priority = priority;
+			temp_priority[i] = priority;
 			if (zone->prev_priority > priority)
 				zone->prev_priority = priority;
 			sc.nr_scanned = 0;
@@ -1229,7 +1231,7 @@ out:
 	for (i = 0; i < pgdat->nr_zones; i++) {
 		struct zone *zone = pgdat->node_zones + i;
 
-		zone->prev_priority = zone->temp_priority;
+		zone->prev_priority = temp_priority[i];
 	}
 	if (!all_zones_ok) {
 		cond_resched();
diff -puN mm/vmstat.c~vmscan-fix-temp_priority-race mm/vmstat.c
--- a/mm/vmstat.c~vmscan-fix-temp_priority-race
+++ a/mm/vmstat.c
@@ -587,11 +587,9 @@ static int zoneinfo_show(struct seq_file
 		seq_printf(m,
 			   "\n  all_unreclaimable: %u"
 			   "\n  prev_priority:     %i"
-			   "\n  temp_priority:     %i"
 			   "\n  start_pfn:         %lu",
 			   zone->all_unreclaimable,
 			   zone->prev_priority,
-			   zone->temp_priority,
 			   zone->zone_start_pfn);
 		spin_unlock_irqrestore(&zone->lock, flags);
 		seq_putc(m, '\n');
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
