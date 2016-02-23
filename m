Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 963A46B0259
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 10:05:11 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id a4so213268492wme.1
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 07:05:11 -0800 (PST)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id t201si40008905wme.122.2016.02.23.07.04.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Feb 2016 07:04:53 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id 8950F1C1BC0
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 15:04:53 +0000 (GMT)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 09/27] mm, vmscan: Simplify the logic deciding whether kswapd sleeps
Date: Tue, 23 Feb 2016 15:04:32 +0000
Message-Id: <1456239890-20737-10-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1456239890-20737-1-git-send-email-mgorman@techsingularity.net>
References: <1456239890-20737-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

kswapd goes through some complex steps trying to figure out if it
should stay awake based on the classzone_idx and the requested order.
It is unnecessarily complex and passes in an invalid classzone_idx to
balance_pgdat().  What matters most of all is whether a larger order has
been requsted and whether kswapd successfully reclaimed at the previous
order. This patch irons out the logic to check just that and the end result
is less headache inducing.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 include/linux/mmzone.h |  5 ++--
 mm/compaction.c        |  4 +--
 mm/memory_hotplug.c    |  5 ++--
 mm/page_alloc.c        |  2 +-
 mm/vmscan.c            | 80 +++++++++++++++++++++++++-------------------------
 5 files changed, 49 insertions(+), 47 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 93151a9a4f56..8f164ce06627 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -667,8 +667,9 @@ typedef struct pglist_data {
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
diff --git a/mm/compaction.c b/mm/compaction.c
index 2ae7c7ea664e..a1274a1f5e66 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1828,8 +1828,8 @@ static void kcompactd_do_work(pg_data_t *pgdat)
 	 */
 	if (pgdat->kcompactd_max_order <= cc.order)
 		pgdat->kcompactd_max_order = 0;
-	if (pgdat->classzone_idx >= cc.classzone_idx)
-		pgdat->classzone_idx = pgdat->nr_zones - 1;
+	if (pgdat->kswapd_classzone_idx >= cc.classzone_idx)
+		pgdat->kcompactd_classzone_idx = pgdat->nr_zones - 1;
 }
 
 void wakeup_kcompactd(pg_data_t *pgdat, int order, int classzone_idx)
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index b33fe895a35c..1cb26f8bbda1 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1147,9 +1147,10 @@ static pg_data_t __ref *hotadd_new_pgdat(int nid, u64 start)
 
 		arch_refresh_nodedata(nid, pgdat);
 	} else {
-		/* Reset the nr_zones and classzone_idx to 0 before reuse */
+		/* Reset the nr_zones, order and classzone_idx before reuse */
 		pgdat->nr_zones = 0;
-		pgdat->classzone_idx = 0;
+		pgdat->kswapd_order = 0;
+		pgdat->kswapd_classzone_idx = -1;
 	}
 
 	/* we can use NODE_DATA(nid) from here */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b03c7b5872bf..34faebad3972 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5653,7 +5653,7 @@ void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
 	unsigned long end_pfn = 0;
 
 	/* pg_data_t should be reset to zero when it's allocated */
-	WARN_ON(pgdat->nr_zones || pgdat->classzone_idx);
+	WARN_ON(pgdat->nr_zones || pgdat->kswapd_classzone_idx);
 
 	reset_deferred_meminit(pgdat);
 	pgdat->node_id = nid;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 57114c130df1..0417f20aead7 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2750,7 +2750,7 @@ static bool pfmemalloc_watermark_ok(pg_data_t *pgdat)
 
 	/* kswapd must be awake if processes are being throttled */
 	if (!wmark_ok && waitqueue_active(&pgdat->kswapd_wait)) {
-		pgdat->classzone_idx = min(pgdat->classzone_idx,
+		pgdat->kswapd_classzone_idx = min(pgdat->kswapd_classzone_idx,
 						(enum zone_type)ZONE_NORMAL);
 		wake_up_interruptible(&pgdat->kswapd_wait);
 	}
@@ -3235,6 +3235,12 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int order,
 
 	prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
 
+	/* If kswapd has not been woken recently, then full sleep */
+	if (classzone_idx == -1) {
+		classzone_idx = balanced_classzone_idx = MAX_NR_ZONES - 1;
+		goto full_sleep;
+	}
+
 	/* Try to sleep for a short interval */
 	if (prepare_kswapd_sleep(pgdat, order, remaining,
 						balanced_classzone_idx)) {
@@ -3243,6 +3249,7 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int order,
 		prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
 	}
 
+full_sleep:
 	/*
 	 * After a short sleep, check if it was a premature sleep. If not, then
 	 * go fully to sleep until explicitly woken up.
@@ -3303,9 +3310,7 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int order,
  */
 static int kswapd(void *p)
 {
-	unsigned long order, new_order;
-	int classzone_idx, new_classzone_idx;
-	int balanced_classzone_idx;
+	unsigned int order, classzone_idx;
 	pg_data_t *pgdat = (pg_data_t*)p;
 	struct task_struct *tsk = current;
 
@@ -3335,38 +3340,25 @@ static int kswapd(void *p)
 	tsk->flags |= PF_MEMALLOC | PF_SWAPWRITE | PF_KSWAPD;
 	set_freezable();
 
-	order = new_order = 0;
-	classzone_idx = new_classzone_idx = pgdat->nr_zones - 1;
-	balanced_classzone_idx = classzone_idx;
+	pgdat->kswapd_order = order = 0;
+	pgdat->kswapd_classzone_idx = classzone_idx = -1;
 	for ( ; ; ) {
 		bool ret;
 
+kswapd_try_sleep:
+		kswapd_try_to_sleep(pgdat, order, classzone_idx, classzone_idx);
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
+		order = pgdat->kswapd_order;
+		classzone_idx = pgdat->kswapd_classzone_idx;
+		if (classzone_idx == -1)
+			classzone_idx = MAX_NR_ZONES - 1;
+		pgdat->kswapd_order = 0;
+		pgdat->kswapd_classzone_idx = -1;
 
 		ret = try_to_freeze();
 		if (kthread_should_stop())
@@ -3376,11 +3368,19 @@ static int kswapd(void *p)
 		 * We can speed up thawing tasks if we don't call balance_pgdat
 		 * after returning from the refrigerator
 		 */
-		if (!ret) {
-			trace_mm_vmscan_kswapd_wake(pgdat->node_id, order);
-			balanced_classzone_idx = balance_pgdat(pgdat, order,
-								classzone_idx);
-		}
+		if (ret)
+			continue;
+
+		/*
+		 * Try reclaim the requested order but if that fails
+		 * then try sleeping on the basis of the order reclaimed.
+		 */
+		trace_mm_vmscan_kswapd_wake(pgdat->node_id, order);
+		if (balance_pgdat(pgdat, order, classzone_idx) < order)
+			goto kswapd_try_sleep;
+
+		order = pgdat->kswapd_order;
+		classzone_idx = pgdat->kswapd_classzone_idx;
 	}
 
 	tsk->flags &= ~(PF_MEMALLOC | PF_SWAPWRITE | PF_KSWAPD);
@@ -3403,10 +3403,10 @@ void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
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
 	if (zone_balanced(zone, order, 0, 0))
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
