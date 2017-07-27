Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5380B6B04BB
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 12:07:18 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id r7so35789115wrb.0
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 09:07:18 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r125si1968298wma.29.2017.07.27.09.07.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 27 Jul 2017 09:07:16 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 2/6] mm, kswapd: don't reset kswapd_order prematurely
Date: Thu, 27 Jul 2017 18:06:57 +0200
Message-Id: <20170727160701.9245-3-vbabka@suse.cz>
In-Reply-To: <20170727160701.9245-1-vbabka@suse.cz>
References: <20170727160701.9245-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>

This patch deals with a corner case found when testing kcompactd with a very
simple testcase that first fragments memory (by creating a large shmem file and
then punching hole in every even page) and then uses artificial order-9
GFP_NOWAIT allocations in a loop. This is freshly after virtme-run boot in KVM
and no other activity.

What happens is that kswapd always reclaims too little to get over
compact_gap() in kswapd_shrink_node(), so it doesn't set sc->order to 0, thus
"goto kswapd_try_sleep" in kswapd() doesn't happen. In the next iteration of
kswapd() loop, alloc_order and reclaim_order is read again from
pgdat->kswapd_order, which the previous iteration has reset to 0 and there was
no other kswapd wakeup meanwhile (the workload inserts short sleeps between
allocations). With the working order 0, node appears balanced and
wakeup_kcompactd() does nothing.

This part is fixed by setting alloc/reclaim order to max of the value used for
balancing in previous iteration, and eventual newly arrived kswapd wakeup.
This mirrors what we do for classzone_idx already.

The next problem comes when kswapd_try_to_sleep() fails to sleep, because the
node is not balanced for order-9. Then it again reads pgdat->kswapd_order and
classzone_idx, which have been reset in the previous iteration. Then it has
nothing to balance and goes to sleep with order-0 for balance check and
kcompactd wakeup. Arguably it should continue with the original order and
classzone_idx, which is still not balanced. This patch makes
kswapd_try_to_sleep() indicate whether it has been successful with a full
sleep, only then is the kswapd_order and classzone_idx read freshly and reset.
Otherwise, we again take the maximum of the current value and any wakeup
attemps that meanwhile came. This has been partially done for the case of
premature wakeup in kswapd_try_to_sleep(), so we can now remove this code.

These changes might potentially make kswapd loop uselessly for a high-order
wakeup. If it has enough to reclaim to overcome the compact gap,
kswapd_shrink_node() will reset the order to 0 and defer to kcompactd. If it
has nothing to reclaim, pgdat->kswapd_failures will eventually exceed
MAX_RECLAIM_RETRIES and send kswapd to sleep. This is what ultimately happens
in the test scenario above. The remaining possible case is that kswapd
repeatedly reclaims more than 0 but less that compact gap pages. In that case
it should arguably also defer to kcompactd, and right now it doesn't. This is
handled in the next patch.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/vmscan.c | 51 +++++++++++++++++++++++++++++----------------------
 1 file changed, 29 insertions(+), 22 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 9b6dfa67131e..ae897a85e7f3 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3367,14 +3367,19 @@ static enum zone_type kswapd_classzone_idx(pg_data_t *pgdat,
 	return max(pgdat->kswapd_classzone_idx, classzone_idx);
 }
 
-static void kswapd_try_to_sleep(pg_data_t *pgdat, int alloc_order, int reclaim_order,
+/*
+ * Return true if kswapd fully slept because pgdat was balanced and there was
+ * no premature wakeup.
+ */
+static bool kswapd_try_to_sleep(pg_data_t *pgdat, int alloc_order, int reclaim_order,
 				unsigned int classzone_idx)
 {
 	long remaining = 0;
 	DEFINE_WAIT(wait);
+	bool ret = false;
 
 	if (freezing(current) || kthread_should_stop())
-		return;
+		return false;
 
 	prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
 
@@ -3408,14 +3413,6 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int alloc_order, int reclaim_o
 
 	/* After a short sleep, check if it was a premature sleep. */
 	if (remaining) {
-		/*
-		 * If woken prematurely then reset kswapd_classzone_idx and
-		 * order. The values will either be from a wakeup request or
-		 * the previous request that slept prematurely.
-		 */
-		pgdat->kswapd_classzone_idx = kswapd_classzone_idx(pgdat, classzone_idx);
-		pgdat->kswapd_order = max(pgdat->kswapd_order, reclaim_order);
-
 		count_vm_event(KSWAPD_LOW_WMARK_HIT_QUICKLY);
 		goto out;
 	}
@@ -3429,6 +3426,7 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int alloc_order, int reclaim_o
 	}
 
 	trace_mm_vmscan_kswapd_sleep(pgdat->node_id);
+	ret = true;
 
 	/*
 	 * vmstat counters are not perfectly accurate and the estimated value
@@ -3442,9 +3440,9 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int alloc_order, int reclaim_o
 	if (!kthread_should_stop())
 		schedule();
 
-	set_pgdat_percpu_threshold(pgdat, calculate_pressure_threshold);
 out:
 	finish_wait(&pgdat->kswapd_wait, &wait);
+	return ret;
 }
 
 /*
@@ -3462,7 +3460,7 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int alloc_order, int reclaim_o
  */
 static int kswapd(void *p)
 {
-	unsigned int alloc_order, reclaim_order;
+	int alloc_order, reclaim_order;
 	unsigned int classzone_idx = MAX_NR_ZONES - 1;
 	pg_data_t *pgdat = (pg_data_t*)p;
 	struct task_struct *tsk = current;
@@ -3493,23 +3491,32 @@ static int kswapd(void *p)
 	tsk->flags |= PF_MEMALLOC | PF_SWAPWRITE | PF_KSWAPD;
 	set_freezable();
 
-	pgdat->kswapd_order = 0;
+	pgdat->kswapd_order = alloc_order = reclaim_order = 0;
 	pgdat->kswapd_classzone_idx = MAX_NR_ZONES;
 	for ( ; ; ) {
 		bool ret;
 
-		alloc_order = reclaim_order = pgdat->kswapd_order;
+		alloc_order = reclaim_order = max(alloc_order, pgdat->kswapd_order);
 		classzone_idx = kswapd_classzone_idx(pgdat, classzone_idx);
 
 kswapd_try_sleep:
-		kswapd_try_to_sleep(pgdat, alloc_order, reclaim_order,
-					classzone_idx);
-
-		/* Read the new order and classzone_idx */
-		alloc_order = reclaim_order = pgdat->kswapd_order;
-		classzone_idx = kswapd_classzone_idx(pgdat, 0);
-		pgdat->kswapd_order = 0;
-		pgdat->kswapd_classzone_idx = MAX_NR_ZONES;
+		if (kswapd_try_to_sleep(pgdat, alloc_order, reclaim_order,
+							classzone_idx)) {
+
+			/* Read the new order and classzone_idx */
+			alloc_order = reclaim_order = pgdat->kswapd_order;
+			classzone_idx = kswapd_classzone_idx(pgdat, 0);
+			pgdat->kswapd_order = 0;
+			pgdat->kswapd_classzone_idx = MAX_NR_ZONES;
+		} else {
+			/*
+			 * We failed to sleep, so continue on the current order
+			 * and classzone_idx, unless they increased.
+			 */
+			alloc_order = max(alloc_order, pgdat->kswapd_order);
+			reclaim_order = max(reclaim_order, pgdat->kswapd_order) ;
+			classzone_idx = kswapd_classzone_idx(pgdat, classzone_idx);
+		}
 
 		ret = try_to_freeze();
 		if (kthread_should_stop())
-- 
2.13.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
