Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id ACA978D0039
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 06:03:55 -0500 (EST)
Date: Thu, 3 Mar 2011 11:03:24 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: stable: mm: vmstat: use a single setter function and callback for
	adjusting percpu thresholds
Message-ID: <20110303110324.GH14162@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: "Nadolski, Edmund" <edmund.nadolski@intel.com>, Greg KH <gregkh@suse.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Williams, Dan J" <dan.j.williams@intel.com>, Christoph Lameter <cl@linux.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, stable@kernel.org, linux-mm@kvack.org

Edmund Nadolski reported the same problem Kosaki did against the commit
[88f5acf8: mm: page allocator: adjust the per-cpu counter threshold when
memory is low] whereby kswapd was in an inconsistent locking state due
to calling get_online_cpus(): See https://lkml.org/lkml/2011/3/2/398 for
details. This is already fixed upstream by commit [b44129b3: mm: vmstat: use
a single setter function and callback for adjusting percpu thresholds]. Unless
there is an objection, can this be picked up for 2.6.37-stable please?
Ideally it would apply against 2.6.36.x as well but that release is no
longer maintained.

==== CUT HERE ====

reduce_pgdat_percpu_threshold() and restore_pgdat_percpu_threshold() exist
to adjust the per-cpu vmstat thresholds while kswapd is awake to avoid
errors due to counter drift.  The functions duplicate some code so this
patch replaces them with a single set_pgdat_percpu_threshold() that takes
a callback function to calculate the desired threshold as a parameter.

[akpm@linux-foundation.org: readability tweak]
[kosaki.motohiro@jp.fujitsu.com: set_pgdat_percpu_threshold(): don't use for_each_online_cpu]
Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Reviewed-by: Christoph Lameter <cl@linux.com>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>

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
index 5da4295..86f8c34 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2448,9 +2448,24 @@ static int kswapd(void *p)
 				 */
 				if (!sleeping_prematurely(pgdat, order, remaining)) {
 					trace_mm_vmscan_kswapd_sleep(pgdat->node_id);
-					restore_pgdat_percpu_threshold(pgdat);
+
+					/*
+					 * vmstat counters are not perfectly
+					 * accurate and the estimated value
+					 * for counters such as NR_FREE_PAGES
+					 * can deviate from the true value by
+					 * nr_online_cpus * threshold. To
+					 * avoid the zone watermarks being
+					 * breached while under pressure, we
+					 * reduce the per-cpu vmstat threshold
+					 * while kswapd is awake and restore
+					 * them before going back to sleep.
+					 */
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
index bc0f095..751a65e 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -83,7 +83,7 @@ EXPORT_SYMBOL(vm_stat);
 
 #ifdef CONFIG_SMP
 
-static int calculate_pressure_threshold(struct zone *zone)
+int calculate_pressure_threshold(struct zone *zone)
 {
 	int threshold;
 	int watermark_distance;
@@ -107,7 +107,7 @@ static int calculate_pressure_threshold(struct zone *zone)
 	return threshold;
 }
 
-static int calculate_threshold(struct zone *zone)
+int calculate_normal_threshold(struct zone *zone)
 {
 	int threshold;
 	int mem;	/* memory in 128 MB units */
@@ -166,7 +166,7 @@ static void refresh_zone_stat_thresholds(void)
 	for_each_populated_zone(zone) {
 		unsigned long max_drift, tolerate_drift;
 
-		threshold = calculate_threshold(zone);
+		threshold = calculate_normal_threshold(zone);
 
 		for_each_online_cpu(cpu)
 			per_cpu_ptr(zone->pageset, cpu)->stat_threshold
@@ -185,46 +185,24 @@ static void refresh_zone_stat_thresholds(void)
 	}
 }
 
-void reduce_pgdat_percpu_threshold(pg_data_t *pgdat)
+void set_pgdat_percpu_threshold(pg_data_t *pgdat,
+				int (*calculate_pressure)(struct zone *))
 {
 	struct zone *zone;
 	int cpu;
 	int threshold;
 	int i;
 
-	get_online_cpus();
-	for (i = 0; i < pgdat->nr_zones; i++) {
-		zone = &pgdat->node_zones[i];
-		if (!zone->percpu_drift_mark)
-			continue;
-
-		threshold = calculate_pressure_threshold(zone);
-		for_each_online_cpu(cpu)
-			per_cpu_ptr(zone->pageset, cpu)->stat_threshold
-							= threshold;
-	}
-	put_online_cpus();
-}
-
-void restore_pgdat_percpu_threshold(pg_data_t *pgdat)
-{
-	struct zone *zone;
-	int cpu;
-	int threshold;
-	int i;
-
-	get_online_cpus();
 	for (i = 0; i < pgdat->nr_zones; i++) {
 		zone = &pgdat->node_zones[i];
 		if (!zone->percpu_drift_mark)
 			continue;
 
-		threshold = calculate_threshold(zone);
-		for_each_online_cpu(cpu)
+		threshold = (*calculate_pressure)(zone);
+		for_each_possible_cpu(cpu)
 			per_cpu_ptr(zone->pageset, cpu)->stat_threshold
 							= threshold;
 	}
-	put_online_cpus();
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
