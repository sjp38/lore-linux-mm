Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f41.google.com (mail-oi0-f41.google.com [209.85.218.41])
	by kanga.kvack.org (Postfix) with ESMTP id 91E8E6B0254
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 15:45:06 -0500 (EST)
Received: by oige206 with SMTP id e206so53297029oig.2
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 12:45:06 -0800 (PST)
Received: from resqmta-po-12v.sys.comcast.net (resqmta-po-12v.sys.comcast.net. [2001:558:fe16:19:96:114:154:171])
        by mx.google.com with ESMTPS id p14si5966131obq.85.2015.12.10.12.45.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 10 Dec 2015 12:45:05 -0800 (PST)
Date: Thu, 10 Dec 2015 14:45:02 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: vmstat: make vmstat_updater deferrable again and shut down on idle
Message-ID: <alpine.DEB.2.20.1512101441140.19122@east.gentwo.org>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hannes@cmpxchg.org, penguin-kernel@I-love.SAKURA.ne.jp

Currently the vmstat updater is not deferrable as a result of commit
ba4877b9ca51f80b5d30f304a46762f0509e1635. This in turn can cause multiple
interruptions of the applications because the vmstat updater may run at
different times than tick processing. No good.

Make vmstate_update deferrable again and provide a function that
folds the differentials when the processor is going to idle mode thus
addressing the issue of the above commit in a clean way.

Note that the shepherd thread will continue scanning the differentials
from another processor and will reenable the vmstat workers if it
detects any changes.

Fixes: ba4877b9ca51f80b5d30f304a46762f0509e1635 (do not use deferrable delay)
Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/vmstat.c
===================================================================
--- linux.orig/mm/vmstat.c
+++ linux/mm/vmstat.c
@@ -460,7 +460,7 @@ static int fold_diff(int *diff)
  *
  * The function returns the number of global counters updated.
  */
-static int refresh_cpu_vm_stats(void)
+static int refresh_cpu_vm_stats(bool do_pagesets)
 {
 	struct zone *zone;
 	int i;
@@ -484,33 +484,35 @@ static int refresh_cpu_vm_stats(void)
 #endif
 			}
 		}
-		cond_resched();
 #ifdef CONFIG_NUMA
-		/*
-		 * Deal with draining the remote pageset of this
-		 * processor
-		 *
-		 * Check if there are pages remaining in this pageset
-		 * if not then there is nothing to expire.
-		 */
-		if (!__this_cpu_read(p->expire) ||
+		if (do_pagesets) {
+			cond_resched();
+			/*
+			 * Deal with draining the remote pageset of this
+			 * processor
+			 *
+			 * Check if there are pages remaining in this pageset
+			 * if not then there is nothing to expire.
+			 */
+			if (!__this_cpu_read(p->expire) ||
 			       !__this_cpu_read(p->pcp.count))
-			continue;
+				continue;

-		/*
-		 * We never drain zones local to this processor.
-		 */
-		if (zone_to_nid(zone) == numa_node_id()) {
-			__this_cpu_write(p->expire, 0);
-			continue;
-		}
+			/*
+			 * We never drain zones local to this processor.
+			 */
+			if (zone_to_nid(zone) == numa_node_id()) {
+				__this_cpu_write(p->expire, 0);
+				continue;
+			}

-		if (__this_cpu_dec_return(p->expire))
-			continue;
+			if (__this_cpu_dec_return(p->expire))
+				continue;

-		if (__this_cpu_read(p->pcp.count)) {
-			drain_zone_pages(zone, this_cpu_ptr(&p->pcp));
-			changes++;
+			if (__this_cpu_read(p->pcp.count)) {
+				drain_zone_pages(zone, this_cpu_ptr(&p->pcp));
+				changes++;
+			}
 		}
 #endif
 	}
@@ -1376,7 +1378,7 @@ static cpumask_var_t cpu_stat_off;

 static void vmstat_update(struct work_struct *w)
 {
-	if (refresh_cpu_vm_stats()) {
+	if (refresh_cpu_vm_stats(true)) {
 		/*
 		 * Counters were updated so we expect more updates
 		 * to occur in the future. Keep on running the
@@ -1408,6 +1410,20 @@ static void vmstat_update(struct work_st
 }

 /*
+ * Switch off vmstat processing and then fold all the remaining differentials
+ * until the diffs stay at zero. The function is used by NOHZ and can only be
+ * invoked when tick processing is not active.
+ */
+void quiet_vmstat(void)
+{
+	do {
+		if (!cpumask_test_and_set_cpu(smp_processor_id(), cpu_stat_off))
+			cancel_delayed_work(this_cpu_ptr(&vmstat_work));
+
+	} while (refresh_cpu_vm_stats(false));
+}
+
+/*
  * Check if the diffs for a certain cpu indicate that
  * an update is needed.
  */
@@ -1439,7 +1455,7 @@ static bool need_update(int cpu)
  */
 static void vmstat_shepherd(struct work_struct *w);

-static DECLARE_DELAYED_WORK(shepherd, vmstat_shepherd);
+static DECLARE_DEFERRABLE_WORK(shepherd, vmstat_shepherd);

 static void vmstat_shepherd(struct work_struct *w)
 {
Index: linux/include/linux/vmstat.h
===================================================================
--- linux.orig/include/linux/vmstat.h
+++ linux/include/linux/vmstat.h
@@ -189,6 +189,7 @@ extern void __inc_zone_state(struct zone
 extern void dec_zone_state(struct zone *, enum zone_stat_item);
 extern void __dec_zone_state(struct zone *, enum zone_stat_item);

+void quiet_vmstat(void);
 void cpu_vm_stats_fold(int cpu);
 void refresh_zone_stat_thresholds(void);

@@ -249,6 +250,7 @@ static inline void __dec_zone_page_state

 static inline void refresh_zone_stat_thresholds(void) { }
 static inline void cpu_vm_stats_fold(int cpu) { }
+static inline void quiet_vmstat(void) { }

 static inline void drain_zonestat(struct zone *zone,
 			struct per_cpu_pageset *pset) { }
Index: linux/kernel/sched/idle.c
===================================================================
--- linux.orig/kernel/sched/idle.c
+++ linux/kernel/sched/idle.c
@@ -219,6 +219,7 @@ static void cpu_idle_loop(void)
 		 */

 		__current_set_polling();
+		quiet_vmstat();
 		tick_nohz_idle_enter();

 		while (!need_resched()) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
