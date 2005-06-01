Date: Wed, 1 Jun 2005 10:23:26 -0400
From: Martin Hicks <mort@sgi.com>
Subject: [PATCH 4/4] VM: rate limit early reclaim
Message-ID: <20050601142326.GW14894@localhost>
References: <20050601141154.GN14894@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050601141154.GN14894@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
Cc: Ray Bryant <raybry@engr.sgi.com>
List-ID: <linux-mm.kvack.org>

When early zone reclaim is turned on the LRU is scanned more frequently
when a zone is low on memory.  This limits when the zone reclaim can
be called by skipping the scan if another thread (either via kswapd or
sync reclaim) is already reclaiming from the zone.

Signed-off-by: Martin Hicks <mort@sgi.com> 

 include/linux/mmzone.h |    2 ++
 mm/page_alloc.c        |    1 +
 mm/vmscan.c            |   10 ++++++++++
 3 files changed, 13 insertions(+)

Index: linux-2.6.12-rc5-mm1/mm/vmscan.c
===================================================================
--- linux-2.6.12-rc5-mm1.orig/mm/vmscan.c	2005-05-26 12:27:11.000000000 -0700
+++ linux-2.6.12-rc5-mm1/mm/vmscan.c	2005-05-26 12:27:17.000000000 -0700
@@ -903,7 +903,9 @@ shrink_caches(struct zone **zones, struc
 		if (zone->all_unreclaimable && sc->priority != DEF_PRIORITY)
 			continue;	/* Let kswapd poll it */
 
+		atomic_inc(&zone->reclaim_in_progress);
 		shrink_zone(zone, sc);
+		atomic_dec(&zone->reclaim_in_progress);
 	}
 }
  
@@ -1114,7 +1116,9 @@ scan:
 			sc.nr_reclaimed = 0;
 			sc.priority = priority;
 			sc.swap_cluster_max = nr_pages? nr_pages : SWAP_CLUSTER_MAX;
+			atomic_inc(&zone->reclaim_in_progress);
 			shrink_zone(zone, &sc);
+			atomic_dec(&zone->reclaim_in_progress);
 			reclaim_state->reclaimed_slab = 0;
 			nr_slab = shrink_slab(sc.nr_scanned, GFP_KERNEL,
 						lru_pages);
@@ -1357,9 +1361,15 @@ int zone_reclaim(struct zone *zone, unsi
 	else
 		sc.swap_cluster_max = SWAP_CLUSTER_MAX;
 
+	/* Don't reclaim the zone if there are other reclaimers active */
+	if (!atomic_inc_and_test(&zone->reclaim_in_progress))
+		goto out;
+
 	shrink_zone(zone, &sc);
 	total_reclaimed = sc.nr_reclaimed;
 
+ out:
+	atomic_dec(&zone->reclaim_in_progress);
 	return total_reclaimed;
 }
 
Index: linux-2.6.12-rc5-mm1/include/linux/mmzone.h
===================================================================
--- linux-2.6.12-rc5-mm1.orig/include/linux/mmzone.h	2005-05-26 12:27:11.000000000 -0700
+++ linux-2.6.12-rc5-mm1/include/linux/mmzone.h	2005-05-26 12:27:17.000000000 -0700
@@ -149,6 +149,8 @@ struct zone {
 	 * as it fails a watermark_ok() in __alloc_pages?
 	 */
 	int			reclaim_pages;
+	/* A count of how many reclaimers are scanning this zone */
+	atomic_t		reclaim_in_progress;
 
 	/*
 	 * prev_priority holds the scanning priority for this zone.  It is
Index: linux-2.6.12-rc5-mm1/mm/page_alloc.c
===================================================================
--- linux-2.6.12-rc5-mm1.orig/mm/page_alloc.c	2005-05-26 12:27:15.000000000 -0700
+++ linux-2.6.12-rc5-mm1/mm/page_alloc.c	2005-05-26 12:27:17.000000000 -0700
@@ -1757,6 +1757,7 @@ static void __init free_area_init_core(s
 		zone->nr_scan_inactive = 0;
 		zone->nr_active = 0;
 		zone->nr_inactive = 0;
+		atomic_set(&zone->reclaim_in_progress, -1);
 		if (!size)
 			continue;
 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
