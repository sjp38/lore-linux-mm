Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id E09B56B0078
	for <linux-mm@kvack.org>; Thu, 12 Jul 2012 02:40:55 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 15/16] mm: Throttle direct reclaimers if PF_MEMALLOC reserves are low and swap is backed by network storage
Date: Thu, 12 Jul 2012 07:40:31 +0100
Message-Id: <1342075232-29267-16-git-send-email-mgorman@suse.de>
In-Reply-To: <1342075232-29267-1-git-send-email-mgorman@suse.de>
References: <1342075232-29267-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>, Eric Dumazet <eric.dumazet@gmail.com>, Sebastian Andrzej Siewior <sebastian@breakpoint.cc>, Mel Gorman <mgorman@suse.de>

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
 mm/vmscan.c            |  128 +++++++++++++++++++++++++++++++++++++++++++++---
 3 files changed, 122 insertions(+), 8 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index c3dd003..a80d4e9 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -696,6 +696,7 @@ typedef struct pglist_data {
 					     range, including holes */
 	int node_id;
 	wait_queue_head_t kswapd_wait;
+	wait_queue_head_t pfmemalloc_wait;
 	struct task_struct *kswapd;	/* Protected by lock_memory_hotplug() */
 	int kswapd_max_order;
 	enum zone_type classzone_idx;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index cdc1536..c591c0c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4381,6 +4381,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 	pgdat_resize_init(pgdat);
 	pgdat->nr_zones = 0;
 	init_waitqueue_head(&pgdat->kswapd_wait);
+	init_waitqueue_head(&pgdat->pfmemalloc_wait);
 	pgdat->kswapd_max_order = 0;
 	pgdat_page_cgroup_init(pgdat);
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 5d19243..ffe58d3 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2122,6 +2122,80 @@ out:
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
+	wmark_ok = free_pages > pfmemalloc_reserve / 2;
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
+	/*
+	 * Kernel threads should not be throttled as they may be indirectly
+	 * responsible for cleaning pages necessary for reclaim to make forward
+	 * progress. kjournald for example may enter direct reclaim while
+	 * committing a transaction where throttling it could forcing other
+	 * processes to block on log_wait_commit().
+	 */
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
+	 * is due to the caller holding an FS lock or performing a journal
+	 * transaction in the case of a filesystem like ext[3|4]. In this case,
+	 * it is not safe to block on pfmemalloc_wait as kswapd could be
+	 * blocked waiting on the same lock. Instead, throttle for up to a
+	 * second before continuing.
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
@@ -2141,6 +2215,15 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
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
@@ -2285,8 +2368,13 @@ static bool pgdat_balanced(pg_data_t *pgdat, unsigned long balanced_pages,
 	return balanced_pages >= (present_pages >> 2);
 }
 
-/* is kswapd sleeping prematurely? */
-static bool sleeping_prematurely(pg_data_t *pgdat, int order, long remaining,
+/*
+ * Prepare kswapd for sleeping. This verifies that there are no processes
+ * waiting in throttle_direct_reclaim() and that watermarks have been met.
+ *
+ * Returns true if kswapd is ready to sleep
+ */
+static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, long remaining,
 					int classzone_idx)
 {
 	int i;
@@ -2295,7 +2383,21 @@ static bool sleeping_prematurely(pg_data_t *pgdat, int order, long remaining,
 
 	/* If a direct reclaimer woke kswapd within HZ/10, it's premature */
 	if (remaining)
-		return true;
+		return false;
+
+	/*
+	 * There is a potential race between when kswapd checks its watermarks
+	 * and a process gets throttled. There is also a potential race if
+	 * processes get throttled, kswapd wakes, a large process exits therby
+	 * balancing the zones that causes kswapd to miss a wakeup. If kswapd
+	 * is going to sleep, no process should be sleeping on pfmemalloc_wait
+	 * so wake them now if necessary. If necessary, processes will wake
+	 * kswapd and get throttled again
+	 */
+	if (waitqueue_active(&pgdat->pfmemalloc_wait)) {
+		wake_up(&pgdat->pfmemalloc_wait);
+		return false;
+	}
 
 	/* Check the watermark levels */
 	for (i = 0; i <= classzone_idx; i++) {
@@ -2328,9 +2430,9 @@ static bool sleeping_prematurely(pg_data_t *pgdat, int order, long remaining,
 	 * must be balanced
 	 */
 	if (order)
-		return !pgdat_balanced(pgdat, balanced, classzone_idx);
+		return pgdat_balanced(pgdat, balanced, classzone_idx);
 	else
-		return !all_zones_ok;
+		return all_zones_ok;
 }
 
 /*
@@ -2556,6 +2658,16 @@ loop_again:
 			}
 
 		}
+
+		/*
+		 * If the low watermark is met there is no need for processes
+		 * to be throttled on pfmemalloc_wait as they should not be
+		 * able to safely make forward progress. Wake them
+		 */
+		if (waitqueue_active(&pgdat->pfmemalloc_wait) &&
+				pfmemalloc_watermark_ok(pgdat))
+			wake_up(&pgdat->pfmemalloc_wait);
+
 		if (all_zones_ok || (order && pgdat_balanced(pgdat, balanced, *classzone_idx)))
 			break;		/* kswapd: all done */
 		/*
@@ -2657,7 +2769,7 @@ out:
 	}
 
 	/*
-	 * Return the order we were reclaiming at so sleeping_prematurely()
+	 * Return the order we were reclaiming at so prepare_kswapd_sleep()
 	 * makes a decision on the order we were last reclaiming at. However,
 	 * if another caller entered the allocator slow path while kswapd
 	 * was awake, order will remain at the higher level
@@ -2677,7 +2789,7 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int order, int classzone_idx)
 	prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
 
 	/* Try to sleep for a short interval */
-	if (!sleeping_prematurely(pgdat, order, remaining, classzone_idx)) {
+	if (prepare_kswapd_sleep(pgdat, order, remaining, classzone_idx)) {
 		remaining = schedule_timeout(HZ/10);
 		finish_wait(&pgdat->kswapd_wait, &wait);
 		prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
@@ -2687,7 +2799,7 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int order, int classzone_idx)
 	 * After a short sleep, check if it was a premature sleep. If not, then
 	 * go fully to sleep until explicitly woken up.
 	 */
-	if (!sleeping_prematurely(pgdat, order, remaining, classzone_idx)) {
+	if (prepare_kswapd_sleep(pgdat, order, remaining, classzone_idx)) {
 		trace_mm_vmscan_kswapd_sleep(pgdat->node_id);
 
 		/*
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
