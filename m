Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 3B999900110
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 03:37:09 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 12/13] mm: Throttle direct reclaimers if PF_MEMALLOC reserves are low and swap is backed by network storage
Date: Tue, 26 Apr 2011 08:36:53 +0100
Message-Id: <1303803414-5937-13-git-send-email-mgorman@suse.de>
In-Reply-To: <1303803414-5937-1-git-send-email-mgorman@suse.de>
References: <1303803414-5937-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>

If swap is backed by network storage such as NBD, there is a risk that a
large number of reclaimers can hang the system by consuming all
PF_MEMALLOC reserves. To avoid these hangs, the administrator must tune
min_free_kbytes in advance. This patch will throttle direct reclaimers
if half the PF_MEMALLOC reserves are in use as the system is at risk of
hanging.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/mmzone.h |    1 +
 mm/page_alloc.c        |    1 +
 mm/vmscan.c            |   57 ++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 59 insertions(+), 0 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index e56f835..8e5c627 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -638,6 +638,7 @@ typedef struct pglist_data {
 					     range, including holes */
 	int node_id;
 	wait_queue_head_t kswapd_wait;
+	wait_queue_head_t pfmemalloc_wait;
 	struct task_struct *kswapd;
 	int kswapd_max_order;
 	enum zone_type classzone_idx;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c0c42ce..13fc246 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4225,6 +4225,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 	pgdat_resize_init(pgdat);
 	pgdat->nr_zones = 0;
 	init_waitqueue_head(&pgdat->kswapd_wait);
+	init_waitqueue_head(&pgdat->pfmemalloc_wait);
 	pgdat->kswapd_max_order = 0;
 	pgdat_page_cgroup_init(pgdat);
 	
diff --git a/mm/vmscan.c b/mm/vmscan.c
index b3a569f..8b6da2b 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2117,6 +2117,55 @@ out:
 	return 0;
 }
 
+static bool pfmemalloc_watermark_ok(pg_data_t *pgdat, int high_zoneidx)
+{
+	struct zone *zone;
+	unsigned long pfmemalloc_reserve = 0;
+	unsigned long free_pages = 0;
+	int i;
+
+	for (i = 0; i <= high_zoneidx; i++) {
+		zone = &pgdat->node_zones[i];
+		pfmemalloc_reserve += min_wmark_pages(zone);
+		free_pages += zone_page_state(zone, NR_FREE_PAGES);
+	}
+
+	return (free_pages > pfmemalloc_reserve / 2) ? true : false;
+}
+
+/*
+ * Throttle direct reclaimers if backing storage is backed by the network
+ * and the PFMEMALLOC reserve for the preferred node is getting dangerously
+ * depleted. kswapd will continue to make progress and wake the processes
+ * when the low watermark is reached
+ */
+static void throttle_direct_reclaim(gfp_t gfp_mask, struct zonelist *zonelist,
+					nodemask_t *nodemask)
+{
+	struct zone *zone;
+	int high_zoneidx = gfp_zone(gfp_mask);
+	DEFINE_WAIT(wait);
+
+	/* Check if the pfmemalloc reserves are ok */
+	first_zones_zonelist(zonelist, high_zoneidx, NULL, &zone);
+	prepare_to_wait(&zone->zone_pgdat->pfmemalloc_wait, &wait,
+							TASK_INTERRUPTIBLE);
+	if (pfmemalloc_watermark_ok(zone->zone_pgdat, high_zoneidx))
+		goto out;
+
+	/* Throttle */
+	do {
+		schedule();
+		finish_wait(&zone->zone_pgdat->pfmemalloc_wait, &wait);
+		prepare_to_wait(&zone->zone_pgdat->pfmemalloc_wait, &wait,
+							TASK_INTERRUPTIBLE);
+	} while (!pfmemalloc_watermark_ok(zone->zone_pgdat, high_zoneidx) &&
+			!fatal_signal_pending(current));
+
+out:
+	finish_wait(&zone->zone_pgdat->pfmemalloc_wait, &wait);
+}
+
 unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 				gfp_t gfp_mask, nodemask_t *nodemask)
 {
@@ -2133,6 +2182,8 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 		.nodemask = nodemask,
 	};
 
+	throttle_direct_reclaim(gfp_mask, zonelist, nodemask);
+
 	trace_mm_vmscan_direct_reclaim_begin(order,
 				sc.may_writepage,
 				gfp_mask);
@@ -2488,6 +2539,12 @@ loop_again:
 			}
 
 		}
+
+		/* Wake throttled direct reclaimers if low watermark is met */
+		if (waitqueue_active(&pgdat->pfmemalloc_wait) &&
+				pfmemalloc_watermark_ok(pgdat, MAX_NR_ZONES - 1))
+			wake_up_interruptible(&pgdat->pfmemalloc_wait);
+
 		if (all_zones_ok || (order && pgdat_balanced(pgdat, balanced, *classzone_idx)))
 			break;		/* kswapd: all done */
 		/*
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
