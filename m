Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id F07366B00F6
	for <linux-mm@kvack.org>; Mon, 16 Apr 2012 08:17:22 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 15/16] mm: Throttle direct reclaimers if PF_MEMALLOC reserves are low and swap is backed by network storage
Date: Mon, 16 Apr 2012 13:17:02 +0100
Message-Id: <1334578624-23257-16-git-send-email-mgorman@suse.de>
In-Reply-To: <1334578624-23257-1-git-send-email-mgorman@suse.de>
References: <1334578624-23257-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>, Mel Gorman <mgorman@suse.de>

If swap is backed by network storage such as NBD, there is a risk
that a large number of reclaimers can hang the system by consuming
all PF_MEMALLOC reserves. To avoid these hangs, the administrator
must tune min_free_kbytes in advance which is a bit fragile.

This patch throttles direct reclaimers if half the PF_MEMALLOC reserves
are in use. If the system is routinely getting throttled the system
administrator can increase min_free_kbytes so degradation is smoother
but the system will keep running.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/mmzone.h |    1 +
 mm/page_alloc.c        |    1 +
 mm/vmscan.c            |  109 ++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 111 insertions(+)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index dff7115..e6b733d 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -663,6 +663,7 @@ typedef struct pglist_data {
 					     range, including holes */
 	int node_id;
 	wait_queue_head_t kswapd_wait;
+	wait_queue_head_t pfmemalloc_wait;
 	struct task_struct *kswapd;
 	int kswapd_max_order;
 	enum zone_type classzone_idx;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0d7bea5..71802cb 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4325,6 +4325,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 	pgdat_resize_init(pgdat);
 	pgdat->nr_zones = 0;
 	init_waitqueue_head(&pgdat->kswapd_wait);
+	init_waitqueue_head(&pgdat->pfmemalloc_wait);
 	pgdat->kswapd_max_order = 0;
 	pgdat_page_cgroup_init(pgdat);
 	
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 33c332b..fdb63db 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2431,6 +2431,73 @@ out:
 	return 0;
 }
 
+static bool pfmemalloc_watermark_ok(pg_data_t *pgdat)
+{
+	struct zone *zone;
+	unsigned long pfmemalloc_reserve = 0;
+	unsigned long free_pages = 0;
+	int i;
+	bool wmark_ok;
+
+	for (i = 0; i <= ZONE_NORMAL; i++) {
+		zone = &pgdat->node_zones[i];
+		pfmemalloc_reserve += min_wmark_pages(zone);
+		free_pages += zone_page_state(zone, NR_FREE_PAGES);
+	}
+
+	wmark_ok = (free_pages > pfmemalloc_reserve / 2) ? true : false;
+
+	/* kswapd must be awake if processes are being throttled */
+	if (!wmark_ok && waitqueue_active(&pgdat->kswapd_wait)) {
+		pgdat->classzone_idx = min(pgdat->classzone_idx,
+						(enum zone_type)ZONE_NORMAL);
+		wake_up_interruptible(&pgdat->kswapd_wait);
+	}
+
+	return wmark_ok;
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
+	pg_data_t *pgdat;
+
+	/* Kernel threads such as kjournald should not be throttled */
+	if (current->flags & PF_KTHREAD)
+		return;
+
+	/* Check if the pfmemalloc reserves are ok */
+	first_zones_zonelist(zonelist, high_zoneidx, NULL, &zone);
+	pgdat = zone->zone_pgdat;
+	if (pfmemalloc_watermark_ok(pgdat))
+		return;
+
+	/*
+	 * If the caller cannot enter the filesystem, it's possible that it
+	 * is processing a journal transaction. In this case, it is not safe
+	 * to block on pfmemalloc_wait as kswapd could also be blocked waiting
+	 * to start a transaction. Instead, throttle for up to a second before
+	 * the reclaim must continue.
+	 */
+	if (!(gfp_mask & __GFP_FS)) {
+		wait_event_interruptible_timeout(pgdat->pfmemalloc_wait,
+			pfmemalloc_watermark_ok(pgdat), HZ);
+		return;
+	}
+
+	/* Throttle until kswapd wakes the process */
+	wait_event_killable(zone->zone_pgdat->pfmemalloc_wait,
+		pfmemalloc_watermark_ok(pgdat));
+}
+
 unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 				gfp_t gfp_mask, nodemask_t *nodemask)
 {
@@ -2449,6 +2516,15 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
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
@@ -2610,6 +2686,20 @@ static bool sleeping_prematurely(pg_data_t *pgdat, int order, long remaining,
 	if (remaining)
 		return true;
 
+	/*
+	 * There is a potential race between when kswapd checks it watermarks
+	 * and a process gets throttled. There is also a potential race if
+	 * processes get throttled, kswapd wakes, a large process exits therby
+	 * balancing the zones that causes kswapd to miss a wakeup. If kswapd
+	 * is going to sleep, no process should be sleeping on pfmemalloc_wait
+	 * so wake them now if necessary. If necessary, processes will wake
+	 * kswapd and get throttled again
+	 */
+	if (waitqueue_active(&pgdat->pfmemalloc_wait)) {
+		wake_up(&pgdat->pfmemalloc_wait);
+		return true;
+	}
+
 	/* Check the watermark levels */
 	for (i = 0; i <= classzone_idx; i++) {
 		struct zone *zone = pgdat->node_zones + i;
@@ -2871,6 +2961,12 @@ loop_again:
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
@@ -3005,6 +3101,19 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int order, int classzone_idx)
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
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
