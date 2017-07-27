Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 16F936B04B6
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 12:07:15 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id g71so13822445wmg.13
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 09:07:15 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d196si1904292wme.2.2017.07.27.09.07.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 27 Jul 2017 09:07:13 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 1/6] mm, kswapd: refactor kswapd_try_to_sleep()
Date: Thu, 27 Jul 2017 18:06:56 +0200
Message-Id: <20170727160701.9245-2-vbabka@suse.cz>
In-Reply-To: <20170727160701.9245-1-vbabka@suse.cz>
References: <20170727160701.9245-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>

The code of kswapd_try_to_sleep() is unnecessarily hard to follow. Also we
needlessly call prepare_kswapd_sleep() twice, if the first one fails.
Restructure the code so that each non-success case is accounted and returns
immediately.

This patch should not introduce any functional change, except when the first
prepare_kswapd_sleep() would have returned false, and then the second would be
true (because somebody else has freed memory), kswapd would sleep before this
patch and now it won't. This has likely been an accidental property of the
implementation, and extremely rare to happen in practice anyway.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/vmscan.c | 88 ++++++++++++++++++++++++++++++-------------------------------
 1 file changed, 44 insertions(+), 44 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 8ad39bbc79e6..9b6dfa67131e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3385,65 +3385,65 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int alloc_order, int reclaim_o
 	 * eligible zone balanced that it's also unlikely that compaction will
 	 * succeed.
 	 */
-	if (prepare_kswapd_sleep(pgdat, reclaim_order, classzone_idx)) {
-		/*
-		 * Compaction records what page blocks it recently failed to
-		 * isolate pages from and skips them in the future scanning.
-		 * When kswapd is going to sleep, it is reasonable to assume
-		 * that pages and compaction may succeed so reset the cache.
-		 */
-		reset_isolation_suitable(pgdat);
+	if (!prepare_kswapd_sleep(pgdat, reclaim_order, classzone_idx)) {
+		count_vm_event(KSWAPD_HIGH_WMARK_HIT_QUICKLY);
+		goto out;
+	}
 
-		/*
-		 * We have freed the memory, now we should compact it to make
-		 * allocation of the requested order possible.
-		 */
-		wakeup_kcompactd(pgdat, alloc_order, classzone_idx);
+	/*
+	 * Compaction records what page blocks it recently failed to isolate
+	 * pages from and skips them in the future scanning.  When kswapd is
+	 * going to sleep, it is reasonable to assume that pages and compaction
+	 * may succeed so reset the cache.
+	 */
+	reset_isolation_suitable(pgdat);
+
+	/*
+	 * We have freed the memory, now we should compact it to make
+	 * allocation of the requested order possible.
+	 */
+	wakeup_kcompactd(pgdat, alloc_order, classzone_idx);
 
-		remaining = schedule_timeout(HZ/10);
+	remaining = schedule_timeout(HZ/10);
 
+	/* After a short sleep, check if it was a premature sleep. */
+	if (remaining) {
 		/*
 		 * If woken prematurely then reset kswapd_classzone_idx and
 		 * order. The values will either be from a wakeup request or
 		 * the previous request that slept prematurely.
 		 */
-		if (remaining) {
-			pgdat->kswapd_classzone_idx = kswapd_classzone_idx(pgdat, classzone_idx);
-			pgdat->kswapd_order = max(pgdat->kswapd_order, reclaim_order);
-		}
+		pgdat->kswapd_classzone_idx = kswapd_classzone_idx(pgdat, classzone_idx);
+		pgdat->kswapd_order = max(pgdat->kswapd_order, reclaim_order);
+
+		count_vm_event(KSWAPD_LOW_WMARK_HIT_QUICKLY);
+		goto out;
+	}
 
-		finish_wait(&pgdat->kswapd_wait, &wait);
-		prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
+	/* If not, then go fully to sleep until explicitly woken up. */
+	finish_wait(&pgdat->kswapd_wait, &wait);
+	prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
+	if (!prepare_kswapd_sleep(pgdat, reclaim_order, classzone_idx)) {
+		count_vm_event(KSWAPD_HIGH_WMARK_HIT_QUICKLY);
+		goto out;
 	}
 
+	trace_mm_vmscan_kswapd_sleep(pgdat->node_id);
+
 	/*
-	 * After a short sleep, check if it was a premature sleep. If not, then
-	 * go fully to sleep until explicitly woken up.
+	 * vmstat counters are not perfectly accurate and the estimated value
+	 * for counters such as NR_FREE_PAGES can deviate from the true value by
+	 * nr_online_cpus * threshold. To avoid the zone watermarks being
+	 * breached while under pressure, we reduce the per-cpu vmstat threshold
+	 * while kswapd is awake and restore them before going back to sleep.
 	 */
-	if (!remaining &&
-	    prepare_kswapd_sleep(pgdat, reclaim_order, classzone_idx)) {
-		trace_mm_vmscan_kswapd_sleep(pgdat->node_id);
+	set_pgdat_percpu_threshold(pgdat, calculate_normal_threshold);
 
-		/*
-		 * vmstat counters are not perfectly accurate and the estimated
-		 * value for counters such as NR_FREE_PAGES can deviate from the
-		 * true value by nr_online_cpus * threshold. To avoid the zone
-		 * watermarks being breached while under pressure, we reduce the
-		 * per-cpu vmstat threshold while kswapd is awake and restore
-		 * them before going back to sleep.
-		 */
-		set_pgdat_percpu_threshold(pgdat, calculate_normal_threshold);
-
-		if (!kthread_should_stop())
-			schedule();
+	if (!kthread_should_stop())
+		schedule();
 
-		set_pgdat_percpu_threshold(pgdat, calculate_pressure_threshold);
-	} else {
-		if (remaining)
-			count_vm_event(KSWAPD_LOW_WMARK_HIT_QUICKLY);
-		else
-			count_vm_event(KSWAPD_HIGH_WMARK_HIT_QUICKLY);
-	}
+	set_pgdat_percpu_threshold(pgdat, calculate_pressure_threshold);
+out:
 	finish_wait(&pgdat->kswapd_wait, &wait);
 }
 
-- 
2.13.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
