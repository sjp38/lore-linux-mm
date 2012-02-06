Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 921206B13F6
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 17:56:34 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 14/15] mm: Throttle direct reclaimers if PF_MEMALLOC reserves are low and swap is backed by network storage
Date: Mon,  6 Feb 2012 22:56:17 +0000
Message-Id: <1328568978-17553-15-git-send-email-mgorman@suse.de>
In-Reply-To: <1328568978-17553-1-git-send-email-mgorman@suse.de>
References: <1328568978-17553-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>

If swap is backed by network storage such as NBD, there is a risk
that a large number of reclaimers can hang the system by consuming
all PF_MEMALLOC reserves. To avoid these hangs, the administrator
must tune min_free_kbytes in advance. This patch will throttle direct
reclaimers if half the PF_MEMALLOC reserves are in use as the system
is at risk of hanging.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/mmzone.h |    1 +
 mm/page_alloc.c        |    1 +
 mm/vmscan.c            |   71 ++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 73 insertions(+), 0 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 650ba2f..eea0398 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -662,6 +662,7 @@ typedef struct pglist_data {
 					     range, including holes */
 	int node_id;
 	wait_queue_head_t kswapd_wait;
+	wait_queue_head_t pfmemalloc_wait;
 	struct task_struct *kswapd;
 	int kswapd_max_order;
 	enum zone_type classzone_idx;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 7c26962..01138a6 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4281,6 +4281,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 	pgdat_resize_init(pgdat);
 	pgdat->nr_zones = 0;
 	init_waitqueue_head(&pgdat->kswapd_wait);
+	init_waitqueue_head(&pgdat->pfmemalloc_wait);
 	pgdat->kswapd_max_order = 0;
 	pgdat_page_cgroup_init(pgdat);
 	
diff --git a/mm/vmscan.c b/mm/vmscan.c
index c52b235..87ae4314 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2425,6 +2425,49 @@ out:
 	return 0;
 }
 
+static bool pfmemalloc_watermark_ok(pg_data_t *pgdat)
+{
+	struct zone *zone;
+	unsigned long pfmemalloc_reserve = 0;
+	unsigned long free_pages = 0;
+	int i;
+
+	for (i = 0; i <= ZONE_NORMAL; i++) {
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
+	/* Kernel threads such as kjournald should not be throttled */
+	if (current->flags & PF_KTHREAD)
+		return;
+
+	/* Check if the pfmemalloc reserves are ok */
+	first_zones_zonelist(zonelist, high_zoneidx, NULL, &zone);
+	if (pfmemalloc_watermark_ok(zone->zone_pgdat))
+		return;
+
+	/* Throttle */
+	wait_event_killable(zone->zone_pgdat->pfmemalloc_wait,
+		pfmemalloc_watermark_ok(zone->zone_pgdat));
+}
+
 unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 				gfp_t gfp_mask, nodemask_t *nodemask)
 {
@@ -2443,6 +2486,15 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 		.gfp_mask = sc.gfp_mask,
 	};
 
+	throttle_direct_reclaim(gfp_mask, zonelist, nodemask);
+
+	/*
+	 * Do not enter reclaim if fatal signal is pending. 1 is returned so
+	 * that the page allocator does not consider triggering OOM
+	 */
+	if (fatal_signal_pending(current))
+		return 1;
+
 	trace_mm_vmscan_direct_reclaim_begin(order,
 				sc.may_writepage,
 				gfp_mask);
@@ -2840,6 +2892,12 @@ loop_again:
 			}
 
 		}
+
+		/* Wake throttled direct reclaimers if low watermark is met */
+		if (waitqueue_active(&pgdat->pfmemalloc_wait) &&
+				pfmemalloc_watermark_ok(pgdat))
+			wake_up(&pgdat->pfmemalloc_wait);
+
 		if (all_zones_ok || (order && pgdat_balanced(pgdat, balanced, *classzone_idx)))
 			break;		/* kswapd: all done */
 		/*
@@ -2961,6 +3019,19 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int order, int classzone_idx)
 		trace_mm_vmscan_kswapd_sleep(pgdat->node_id);
 
 		/*
+		 * There is a potential race between when kswapd checks it
+		 * watermarks and a process gets throttled. There is also
+		 * a potential race if processes get throttled, kswapd wakes,
+		 * a large process exits therby balancing the zones that causes
+		 * kswapd to miss a wakeup. If kswapd is going to sleep, no
+		 * process should be sleeping on pfmemalloc_wait so wake them
+		 * now if necessary. If necessary, processes will wake kswapd
+		 * and get throttled again
+		 */
+		if (waitqueue_active(&pgdat->pfmemalloc_wait))
+			wake_up(&pgdat->pfmemalloc_wait);
+
+		/*
 		 * vmstat counters are not perfectly accurate and the estimated
 		 * value for counters such as NR_FREE_PAGES can deviate from the
 		 * true value by nr_online_cpus * threshold. To avoid the zone
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
