Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8791D6B0071
	for <linux-mm@kvack.org>; Wed, 27 Oct 2010 04:47:36 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 2/2] mm: vmstat: Use a single setter function and callback for adjusting percpu thresholds
Date: Wed, 27 Oct 2010 09:47:36 +0100
Message-Id: <1288169256-7174-3-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1288169256-7174-1-git-send-email-mel@csn.ul.ie>
References: <1288169256-7174-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Shaohua Li <shaohua.li@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

reduce_pgdat_percpu_threshold() and restore_pgdat_percpu_threshold()
exist to adjust the per-cpu vmstat thresholds while kswapd is awake to
avoid errors due to counter drift. The functions duplicate some code so
this patch replaces them with a single set_pgdat_percpu_threshold() that
takes a callback function to calculate the desired threshold as a
parameter.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 include/linux/vmstat.h |   10 ++++++----
 mm/vmscan.c            |    6 ++++--
 mm/vmstat.c            |   30 ++++++------------------------
 3 files changed, 16 insertions(+), 30 deletions(-)

diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index e4cc21c..833e676 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -254,8 +254,11 @@ extern void dec_zone_state(struct zone *, enum zone_stat_item);
 extern void __dec_zone_state(struct zone *, enum zone_stat_item);
 
 void refresh_cpu_vm_stats(int);
-void reduce_pgdat_percpu_threshold(pg_data_t *pgdat);
-void restore_pgdat_percpu_threshold(pg_data_t *pgdat);
+
+int calculate_pressure_threshold(struct zone *zone);
+int calculate_normal_threshold(struct zone *zone);
+void set_pgdat_percpu_threshold(pg_data_t *pgdat,
+				int (*calculate_pressure)(struct zone *));
 #else /* CONFIG_SMP */
 
 /*
@@ -300,8 +303,7 @@ static inline void __dec_zone_page_state(struct page *page,
 #define dec_zone_page_state __dec_zone_page_state
 #define mod_zone_page_state __mod_zone_page_state
 
-static inline void reduce_pgdat_percpu_threshold(pg_data_t *pgdat) { }
-static inline void restore_pgdat_percpu_threshold(pg_data_t *pgdat) { }
+#define set_pgdat_percpu_threshold(pgdat, callback) { }
 
 static inline void refresh_cpu_vm_stats(int cpu) { }
 #endif
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 3e71cb1..7966110 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2378,9 +2378,11 @@ static int kswapd(void *p)
 				 */
 				if (!sleeping_prematurely(pgdat, order, remaining)) {
 					trace_mm_vmscan_kswapd_sleep(pgdat->node_id);
-					restore_pgdat_percpu_threshold(pgdat);
+					set_pgdat_percpu_threshold(pgdat,
+						calculate_normal_threshold);
 					schedule();
-					reduce_pgdat_percpu_threshold(pgdat);
+					set_pgdat_percpu_threshold(pgdat,
+						calculate_pressure_threshold);
 				} else {
 					if (remaining)
 						count_vm_event(KSWAPD_LOW_WMARK_HIT_QUICKLY);
diff --git a/mm/vmstat.c b/mm/vmstat.c
index cafcc2d..73661e8 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -81,13 +81,13 @@ EXPORT_SYMBOL(vm_stat);
 
 #ifdef CONFIG_SMP
 
-static int calculate_pressure_threshold(struct zone *zone)
+int calculate_pressure_threshold(struct zone *zone)
 {
 	return max(1, (int)((high_wmark_pages(zone) - low_wmark_pages(zone) /
 				num_online_cpus())));
 }
 
-static int calculate_threshold(struct zone *zone)
+int calculate_normal_threshold(struct zone *zone)
 {
 	int threshold;
 	int mem;	/* memory in 128 MB units */
@@ -146,7 +146,7 @@ static void refresh_zone_stat_thresholds(void)
 	for_each_populated_zone(zone) {
 		unsigned long max_drift, tolerate_drift;
 
-		threshold = calculate_threshold(zone);
+		threshold = calculate_normal_threshold(zone);
 
 		for_each_online_cpu(cpu)
 			per_cpu_ptr(zone->pageset, cpu)->stat_threshold
@@ -165,7 +165,8 @@ static void refresh_zone_stat_thresholds(void)
 	}
 }
 
-void reduce_pgdat_percpu_threshold(pg_data_t *pgdat)
+void set_pgdat_percpu_threshold(pg_data_t *pgdat,
+				int (*calculate_pressure)(struct zone *))
 {
 	struct zone *zone;
 	int cpu;
@@ -177,26 +178,7 @@ void reduce_pgdat_percpu_threshold(pg_data_t *pgdat)
 		if (!zone->percpu_drift_mark)
 			continue;
 
-		threshold = calculate_pressure_threshold(zone);
-		for_each_online_cpu(cpu)
-			per_cpu_ptr(zone->pageset, cpu)->stat_threshold
-							= threshold;
-	}
-}
-
-void restore_pgdat_percpu_threshold(pg_data_t *pgdat)
-{
-	struct zone *zone;
-	int cpu;
-	int threshold;
-	int i;
-
-	for (i = 0; i < pgdat->nr_zones; i++) {
-		zone = &pgdat->node_zones[i];
-		if (!zone->percpu_drift_mark)
-			continue;
-
-		threshold = calculate_threshold(zone);
+		threshold = calculate_pressure(zone);
 		for_each_online_cpu(cpu)
 			per_cpu_ptr(zone->pageset, cpu)->stat_threshold
 							= threshold;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
