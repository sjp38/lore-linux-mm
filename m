Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id A0DD26B02B4
	for <linux-mm@kvack.org>; Tue, 15 Aug 2017 04:46:55 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id l30so5479435pgc.15
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 01:46:55 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id w26si5283768pfi.302.2017.08.15.01.46.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Aug 2017 01:46:54 -0700 (PDT)
From: Kemi Wang <kemi.wang@intel.com>
Subject: [PATCH 2/2] mm: Update NUMA counter threshold size
Date: Tue, 15 Aug 2017 16:45:36 +0800
Message-Id: <1502786736-21585-3-git-send-email-kemi.wang@intel.com>
In-Reply-To: <1502786736-21585-1-git-send-email-kemi.wang@intel.com>
References: <1502786736-21585-1-git-send-email-kemi.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Dave <dave.hansen@linux.intel.com>, Andi Kleen <andi.kleen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Tim Chen <tim.c.chen@intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Kemi Wang <kemi.wang@intel.com>

There is significant overhead in cache bouncing caused by zone counters
(NUMA associated counters) update in parallel in multi-threaded page
allocation (suggested by Dave Hansen).

This patch updates NUMA counter threshold to a fixed size of 32765, as a
small threshold greatly increases the update frequency of the global
counter from local per cpu counter, and the number of NUMA items in each
cpu (vm_numa_stat_diff[]) is added to zone->vm_numa_stat[] when a user
*reads* the value of numa counter to eliminate deviation (suggested by
Ying Huang).

The rationality is that these statistics counters don't need to be read
often, unlike other VM counters, so it's not a problem to use a large
threshold and make readers more expensive.

With this patchset, we see 26.6% drop of CPU cycles(537-->394) for per
single page allocation and reclaim on Jesper's page_bench03 benchmark.

Benchmark provided by Jesper D Broucer(increase loop times to 10000000):
https://github.com/netoptimizer/prototype-kernel/tree/master/kernel/mm/bench

 Threshold   CPU cycles    Throughput(88 threads)
     32          799         241760478
     64          640         301628829
     125         537         358906028 <==> system by default (base)
     256         468         412397590
     512         428         450550704
     4096        399         482520943
     20000       394         489009617
     30000       395         488017817
     32765       394(-26.6%) 488932078(+36.2%) <==> with this patchset
     N/A         342(-36.3%) 562900157(+56.8%) <==> disable zone_statistics

Signed-off-by: Kemi Wang <kemi.wang@intel.com>
Suggested-by: Dave Hansen <dave.hansen@intel.com>
Suggested-by: Ying Huang <ying.huang@intel.com>
---
 include/linux/mmzone.h |  4 ++--
 include/linux/vmstat.h |  6 +++++-
 mm/vmstat.c            | 23 ++++++++++-------------
 3 files changed, 17 insertions(+), 16 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 0b11ba7..7eaf0e8 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -282,8 +282,8 @@ struct per_cpu_pageset {
 	struct per_cpu_pages pcp;
 #ifdef CONFIG_NUMA
 	s8 expire;
-	s8 numa_stat_threshold;
-	s8 vm_numa_stat_diff[NR_VM_ZONE_NUMA_STAT_ITEMS];
+	s16 numa_stat_threshold;
+	s16 vm_numa_stat_diff[NR_VM_ZONE_NUMA_STAT_ITEMS];
 #endif
 #ifdef CONFIG_SMP
 	s8 stat_threshold;
diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index 1e19379..d97cc34 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -125,10 +125,14 @@ static inline unsigned long global_numa_state(enum zone_numa_stat_item item)
 	return x;
 }
 
-static inline unsigned long zone_numa_state(struct zone *zone,
+static inline unsigned long zone_numa_state_snapshot(struct zone *zone,
 					enum zone_numa_stat_item item)
 {
 	long x = atomic_long_read(&zone->vm_numa_stat[item]);
+	int cpu;
+
+	for_each_online_cpu(cpu)
+		x += per_cpu_ptr(zone->pageset, cpu)->vm_numa_stat_diff[item];
 
 	return x;
 }
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 5a7fa30..c7f50ed 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -30,6 +30,8 @@
 
 #include "internal.h"
 
+#define NUMA_STAT_THRESHOLD  32765
+
 #ifdef CONFIG_VM_EVENT_COUNTERS
 DEFINE_PER_CPU(struct vm_event_state, vm_event_states) = {{0}};
 EXPORT_PER_CPU_SYMBOL(vm_event_states);
@@ -196,7 +198,7 @@ void refresh_zone_stat_thresholds(void)
 							= threshold;
 #ifdef CONFIG_NUMA
 			per_cpu_ptr(zone->pageset, cpu)->numa_stat_threshold
-							= threshold;
+							= NUMA_STAT_THRESHOLD;
 #endif
 			/* Base nodestat threshold on the largest populated zone. */
 			pgdat_threshold = per_cpu_ptr(pgdat->per_cpu_nodestats, cpu)->stat_threshold;
@@ -231,14 +233,9 @@ void set_pgdat_percpu_threshold(pg_data_t *pgdat,
 			continue;
 
 		threshold = (*calculate_pressure)(zone);
-		for_each_online_cpu(cpu) {
+		for_each_online_cpu(cpu)
 			per_cpu_ptr(zone->pageset, cpu)->stat_threshold
 							= threshold;
-#ifdef CONFIG_NUMA
-			per_cpu_ptr(zone->pageset, cpu)->numa_stat_threshold
-							= threshold;
-#endif
-		}
 	}
 }
 
@@ -872,13 +869,13 @@ void __inc_zone_numa_state(struct zone *zone,
 				 enum zone_numa_stat_item item)
 {
 	struct per_cpu_pageset __percpu *pcp = zone->pageset;
-	s8 __percpu *p = pcp->vm_numa_stat_diff + item;
-	s8 v, t;
+	s16 __percpu *p = pcp->vm_numa_stat_diff + item;
+	s16 v, t;
 
 	v = __this_cpu_inc_return(*p);
 	t = __this_cpu_read(pcp->numa_stat_threshold);
 	if (unlikely(v > t)) {
-		s8 overstep = t >> 1;
+		s16 overstep = t >> 1;
 
 		zone_numa_state_add(v + overstep, zone, item);
 		__this_cpu_write(*p, -overstep);
@@ -914,7 +911,7 @@ unsigned long sum_zone_node_numa_state(int node,
 	unsigned long count = 0;
 
 	for (i = 0; i < MAX_NR_ZONES; i++)
-		count += zone_numa_state(zones + i, item);
+		count += zone_numa_state_snapshot(zones + i, item);
 
 	return count;
 }
@@ -1536,7 +1533,7 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
 	for (i = 0; i < NR_VM_ZONE_NUMA_STAT_ITEMS; i++)
 		seq_printf(m, "\n      %-12s %lu",
 				vmstat_text[i + NR_VM_ZONE_STAT_ITEMS],
-				zone_numa_state(zone, i));
+				zone_numa_state_snapshot(zone, i));
 #endif
 
 	seq_printf(m, "\n  pagesets");
@@ -1795,7 +1792,7 @@ static bool need_update(int cpu)
 
 		BUILD_BUG_ON(sizeof(p->vm_stat_diff[0]) != 1);
 #ifdef CONFIG_NUMA
-		BUILD_BUG_ON(sizeof(p->vm_numa_stat_diff[0]) != 1);
+		BUILD_BUG_ON(sizeof(p->vm_numa_stat_diff[0]) != 2);
 #endif
 		/*
 		 * The fast way of checking if there are any vmstat diffs.
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
