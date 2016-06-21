Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f197.google.com (mail-lb0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7A8956B0265
	for <linux-mm@kvack.org>; Tue, 21 Jun 2016 10:17:40 -0400 (EDT)
Received: by mail-lb0-f197.google.com with SMTP id js8so14921709lbc.2
        for <linux-mm@kvack.org>; Tue, 21 Jun 2016 07:17:40 -0700 (PDT)
Received: from outbound-smtp06.blacknight.com (outbound-smtp06.blacknight.com. [81.17.249.39])
        by mx.google.com with ESMTPS id w8si36482898wjd.21.2016.06.21.07.17.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 21 Jun 2016 07:17:39 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp06.blacknight.com (Postfix) with ESMTPS id C48FF98B0D
	for <linux-mm@kvack.org>; Tue, 21 Jun 2016 14:17:38 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 08/27] mm, vmscan: Simplify the logic deciding whether kswapd sleeps
Date: Tue, 21 Jun 2016 15:15:47 +0100
Message-Id: <1466518566-30034-9-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1466518566-30034-1-git-send-email-mgorman@techsingularity.net>
References: <1466518566-30034-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

kswapd goes through some complex steps trying to figure out if it
should stay awake based on the classzone_idx and the requested order.
It is unnecessarily complex and passes in an invalid classzone_idx to
balance_pgdat().  What matters most of all is whether a larger order has
been requsted and whether kswapd successfully reclaimed at the previous
order. This patch irons out the logic to check just that and the end result
is less headache inducing.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/mmzone.h |   5 ++-
 mm/memory_hotplug.c    |   5 ++-
 mm/page_alloc.c        |   2 +-
 mm/vmscan.c            | 102 ++++++++++++++++++++++++++-----------------------
 4 files changed, 62 insertions(+), 52 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index f09d5f37ab7b..890d1858aa22 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -665,8 +665,9 @@ typedef struct pglist_data {
 	wait_queue_head_t pfmemalloc_wait;
 	struct task_struct *kswapd;	/* Protected by
 					   mem_hotplug_begin/end() */
-	int kswapd_max_order;
-	enum zone_type classzone_idx;
+	int kswapd_order;
+	enum zone_type kswapd_classzone_idx;
+
 #ifdef CONFIG_COMPACTION
 	int kcompactd_max_order;
 	enum zone_type kcompactd_classzone_idx;
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index c5278360ca66..065140ecd081 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1209,9 +1209,10 @@ static pg_data_t __ref *hotadd_new_pgdat(int nid, u64 start)
 
 		arch_refresh_nodedata(nid, pgdat);
 	} else {
-		/* Reset the nr_zones and classzone_idx to 0 before reuse */
+		/* Reset the nr_zones, order and classzone_idx before reuse */
 		pgdat->nr_zones = 0;
-		pgdat->classzone_idx = 0;
+		pgdat->kswapd_order = 0;
+		pgdat->kswapd_classzone_idx = 0;
 	}
 
 	/* we can use NODE_DATA(nid) from here */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0d3cb9ad430b..e128af8de05f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6027,7 +6027,7 @@ void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
 	unsigned long end_pfn = 0;
 
 	/* pg_data_t should be reset to zero when it's allocated */
-	WARN_ON(pgdat->nr_zones || pgdat->classzone_idx);
+	WARN_ON(pgdat->nr_zones || pgdat->kswapd_classzone_idx);
 
 	reset_deferred_meminit(pgdat);
 	pgdat->node_id = nid;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 2c83dff0650e..ce712ca1f696 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2756,7 +2756,7 @@ static bool pfmemalloc_watermark_ok(pg_data_t *pgdat)
 
 	/* kswapd must be awake if processes are being throttled */
 	if (!wmark_ok && waitqueue_active(&pgdat->kswapd_wait)) {
-		pgdat->classzone_idx = min(pgdat->classzone_idx,
+		pgdat->kswapd_classzone_idx = min(pgdat->kswapd_classzone_idx,
 						(enum zone_type)ZONE_NORMAL);
 		wake_up_interruptible(&pgdat->kswapd_wait);
 	}
@@ -3230,8 +3230,8 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 	return sc.order;
 }
 
-static void kswapd_try_to_sleep(pg_data_t *pgdat, int order,
-				int classzone_idx, int balanced_classzone_idx)
+static void kswapd_try_to_sleep(pg_data_t *pgdat, int alloc_order, int reclaim_order,
+				int classzone_idx)
 {
 	long remaining = 0;
 	DEFINE_WAIT(wait);
@@ -3241,9 +3241,19 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int order,
 
 	prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
 
+	/*
+	 * If kswapd has not been woken recently, then kswapd goes fully
+	 * to sleep. kcompactd may still need to wake if the original
+	 * request was high-order.
+	 */
+	if (classzone_idx == -1) {
+		wakeup_kcompactd(pgdat, alloc_order, classzone_idx);
+		classzone_idx = MAX_NR_ZONES - 1;
+		goto full_sleep;
+	}
+
 	/* Try to sleep for a short interval */
-	if (prepare_kswapd_sleep(pgdat, order, remaining,
-						balanced_classzone_idx)) {
+	if (prepare_kswapd_sleep(pgdat, reclaim_order, remaining, classzone_idx)) {
 		/*
 		 * Compaction records what page blocks it recently failed to
 		 * isolate pages from and skips them in the future scanning.
@@ -3256,19 +3266,19 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int order,
 		 * We have freed the memory, now we should compact it to make
 		 * allocation of the requested order possible.
 		 */
-		wakeup_kcompactd(pgdat, order, classzone_idx);
+		wakeup_kcompactd(pgdat, alloc_order, classzone_idx);
 
 		remaining = schedule_timeout(HZ/10);
 		finish_wait(&pgdat->kswapd_wait, &wait);
 		prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
 	}
 
+full_sleep:
 	/*
 	 * After a short sleep, check if it was a premature sleep. If not, then
 	 * go fully to sleep until explicitly woken up.
 	 */
-	if (prepare_kswapd_sleep(pgdat, order, remaining,
-						balanced_classzone_idx)) {
+	if (prepare_kswapd_sleep(pgdat, reclaim_order, remaining, classzone_idx)) {
 		trace_mm_vmscan_kswapd_sleep(pgdat->node_id);
 
 		/*
@@ -3309,9 +3319,7 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int order,
  */
 static int kswapd(void *p)
 {
-	unsigned long order, new_order;
-	int classzone_idx, new_classzone_idx;
-	int balanced_classzone_idx;
+	unsigned int alloc_order, reclaim_order, classzone_idx;
 	pg_data_t *pgdat = (pg_data_t*)p;
 	struct task_struct *tsk = current;
 
@@ -3341,38 +3349,26 @@ static int kswapd(void *p)
 	tsk->flags |= PF_MEMALLOC | PF_SWAPWRITE | PF_KSWAPD;
 	set_freezable();
 
-	order = new_order = 0;
-	classzone_idx = new_classzone_idx = pgdat->nr_zones - 1;
-	balanced_classzone_idx = classzone_idx;
+	pgdat->kswapd_order = alloc_order = reclaim_order = 0;
+	pgdat->kswapd_classzone_idx = classzone_idx = -1;
 	for ( ; ; ) {
 		bool ret;
 
+kswapd_try_sleep:
+		kswapd_try_to_sleep(pgdat, alloc_order, reclaim_order,
+					classzone_idx);
+
 		/*
-		 * While we were reclaiming, there might have been another
-		 * wakeup, so check the values.
+		 * Read the new order and classzone_idx which may be -1 if
+		 * kswapd_try_to_sleep() woke up after a short timeout instead
+		 * of being woken by the page allocator.
 		 */
-		new_order = pgdat->kswapd_max_order;
-		new_classzone_idx = pgdat->classzone_idx;
-		pgdat->kswapd_max_order =  0;
-		pgdat->classzone_idx = pgdat->nr_zones - 1;
-
-		if (order < new_order || classzone_idx > new_classzone_idx) {
-			/*
-			 * Don't sleep if someone wants a larger 'order'
-			 * allocation or has tigher zone constraints
-			 */
-			order = new_order;
-			classzone_idx = new_classzone_idx;
-		} else {
-			kswapd_try_to_sleep(pgdat, order, classzone_idx,
-						balanced_classzone_idx);
-			order = pgdat->kswapd_max_order;
-			classzone_idx = pgdat->classzone_idx;
-			new_order = order;
-			new_classzone_idx = classzone_idx;
-			pgdat->kswapd_max_order = 0;
-			pgdat->classzone_idx = pgdat->nr_zones - 1;
-		}
+		alloc_order = reclaim_order = pgdat->kswapd_order;
+		classzone_idx = pgdat->kswapd_classzone_idx;
+		if (classzone_idx == -1)
+			classzone_idx = MAX_NR_ZONES - 1;
+		pgdat->kswapd_order = 0;
+		pgdat->kswapd_classzone_idx = -1;
 
 		ret = try_to_freeze();
 		if (kthread_should_stop())
@@ -3382,12 +3378,24 @@ static int kswapd(void *p)
 		 * We can speed up thawing tasks if we don't call balance_pgdat
 		 * after returning from the refrigerator
 		 */
-		if (!ret) {
-			trace_mm_vmscan_kswapd_wake(pgdat->node_id, order);
+		if (ret)
+			continue;
 
-			/* return value ignored until next patch */
-			balance_pgdat(pgdat, order, classzone_idx);
-		}
+		/*
+		 * Reclaim begins at the requested order but if a high-order
+		 * reclaim fails then kswapd falls back to reclaiming for
+		 * order-0. If that happens, kswapd will consider sleeping
+		 * for the order it finished reclaiming at (reclaim_order)
+		 * but kcompactd is woken to compact for the original
+		 * request (alloc_order).
+		 */
+		trace_mm_vmscan_kswapd_wake(pgdat->node_id, alloc_order);
+		reclaim_order = balance_pgdat(pgdat, alloc_order, classzone_idx);
+		if (reclaim_order < alloc_order)
+			goto kswapd_try_sleep;
+
+		alloc_order = reclaim_order = pgdat->kswapd_order;
+		classzone_idx = pgdat->kswapd_classzone_idx;
 	}
 
 	tsk->flags &= ~(PF_MEMALLOC | PF_SWAPWRITE | PF_KSWAPD);
@@ -3410,10 +3418,10 @@ void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
 	if (!cpuset_zone_allowed(zone, GFP_KERNEL | __GFP_HARDWALL))
 		return;
 	pgdat = zone->zone_pgdat;
-	if (pgdat->kswapd_max_order < order) {
-		pgdat->kswapd_max_order = order;
-		pgdat->classzone_idx = min(pgdat->classzone_idx, classzone_idx);
-	}
+	if (pgdat->kswapd_classzone_idx == -1)
+		pgdat->kswapd_classzone_idx = classzone_idx;
+	pgdat->kswapd_classzone_idx = max(pgdat->kswapd_classzone_idx, classzone_idx);
+	pgdat->kswapd_order = max(pgdat->kswapd_order, order);
 	if (!waitqueue_active(&pgdat->kswapd_wait))
 		return;
 	if (zone_balanced(zone, order, 0))
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
