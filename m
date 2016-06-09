Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id B7ADD6B0265
	for <linux-mm@kvack.org>; Thu,  9 Jun 2016 14:06:17 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id 132so20698139lfz.3
        for <linux-mm@kvack.org>; Thu, 09 Jun 2016 11:06:17 -0700 (PDT)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id wt5si9182198wjb.111.2016.06.09.11.06.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 09 Jun 2016 11:06:16 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id D758298EA1
	for <linux-mm@kvack.org>; Thu,  9 Jun 2016 18:06:15 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 08/27] mm, vmscan: Simplify the logic deciding whether kswapd sleeps
Date: Thu,  9 Jun 2016 19:04:24 +0100
Message-Id: <1465495483-11855-9-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1465495483-11855-1-git-send-email-mgorman@techsingularity.net>
References: <1465495483-11855-1-git-send-email-mgorman@techsingularity.net>
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
 include/linux/mmzone.h |  5 ++--
 mm/memory_hotplug.c    |  5 ++--
 mm/page_alloc.c        |  2 +-
 mm/vmscan.c            | 79 +++++++++++++++++++++++++-------------------------
 4 files changed, 46 insertions(+), 45 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index aff621fcc6af..15ce454d0d59 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -663,8 +663,9 @@ typedef struct pglist_data {
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
index c5278360ca66..42d758bffd0a 100644
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
+		pgdat->kswapd_classzone_idx = -1;
 	}
 
 	/* we can use NODE_DATA(nid) from here */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4ce578b969da..d8cb483d5cad 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6036,7 +6036,7 @@ void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
 	unsigned long end_pfn = 0;
 
 	/* pg_data_t should be reset to zero when it's allocated */
-	WARN_ON(pgdat->nr_zones || pgdat->classzone_idx);
+	WARN_ON(pgdat->nr_zones || pgdat->kswapd_classzone_idx);
 
 	reset_deferred_meminit(pgdat);
 	pgdat->node_id = nid;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 96bf841f9352..14b34eebedff 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2727,7 +2727,7 @@ static bool pfmemalloc_watermark_ok(pg_data_t *pgdat)
 
 	/* kswapd must be awake if processes are being throttled */
 	if (!wmark_ok && waitqueue_active(&pgdat->kswapd_wait)) {
-		pgdat->classzone_idx = min(pgdat->classzone_idx,
+		pgdat->kswapd_classzone_idx = min(pgdat->kswapd_classzone_idx,
 						(enum zone_type)ZONE_NORMAL);
 		wake_up_interruptible(&pgdat->kswapd_wait);
 	}
@@ -3211,6 +3211,12 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int order,
 
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
@@ -3233,6 +3239,7 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int order,
 		prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
 	}
 
+full_sleep:
 	/*
 	 * After a short sleep, check if it was a premature sleep. If not, then
 	 * go fully to sleep until explicitly woken up.
@@ -3279,9 +3286,7 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int order,
  */
 static int kswapd(void *p)
 {
-	unsigned long order, new_order;
-	int classzone_idx, new_classzone_idx;
-	int balanced_classzone_idx;
+	unsigned int order, classzone_idx;
 	pg_data_t *pgdat = (pg_data_t*)p;
 	struct task_struct *tsk = current;
 
@@ -3311,38 +3316,25 @@ static int kswapd(void *p)
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
@@ -3352,12 +3344,19 @@ static int kswapd(void *p)
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
@@ -3380,10 +3379,10 @@ void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
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
