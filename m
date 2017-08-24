Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6E9AA2803BB
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 06:01:27 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id r11so1153441pgs.9
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 03:01:27 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id e84si2545920pfh.35.2017.08.24.03.01.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Aug 2017 03:01:25 -0700 (PDT)
From: Kemi Wang <kemi.wang@intel.com>
Subject: [PATCH v2 2/3] mm: Update NUMA counter threshold size
Date: Thu, 24 Aug 2017 18:00:00 +0800
Message-Id: <1503568801-21305-3-git-send-email-kemi.wang@intel.com>
In-Reply-To: <1503568801-21305-1-git-send-email-kemi.wang@intel.com>
References: <1503568801-21305-1-git-send-email-kemi.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Christopher Lameter <cl@linux.com>
Cc: Dave <dave.hansen@linux.intel.com>, Andi Kleen <andi.kleen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Tim Chen <tim.c.chen@intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Kemi Wang <kemi.wang@intel.com>

There is significant overhead in cache bouncing caused by zone counters
(NUMA associated counters) update in parallel in multi-threaded page
allocation (suggested by Dave Hansen).

This patch updates NUMA counter threshold to a fixed size of MAX_U16 - 2,
as a small threshold greatly increases the update frequency of the global
counter from local per cpu counter(suggested by Ying Huang).

The rationality is that these statistics counters don't affect the kernel's
decision, unlike other VM counters, so it's not a problem to use a large
threshold.

With this patchset, we see 31.3% drop of CPU cycles(537-->369) for per
single page allocation and reclaim on Jesper's page_bench03 benchmark.

Benchmark provided by Jesper D Brouer(increase loop times to 10000000):
https://github.com/netoptimizer/prototype-kernel/tree/master/kernel/mm/
bench

 Threshold   CPU cycles    Throughput(88 threads)
     32          799         241760478
     64          640         301628829
     125         537         358906028 <==> system by default (base)
     256         468         412397590
     512         428         450550704
     4096        399         482520943
     20000       394         489009617
     30000       395         488017817
     65533       369(-31.3%) 521661345(+45.3%) <==> with this patchset
     N/A         342(-36.3%) 562900157(+56.8%) <==> disable zone_statistics

Changelog:
v2:
    a) Change the type of vm_numa_stat_diff[] from s16 to u16, since numa
    stats counter is always a incremental field.
    b) Remove numa_stat_threshold field in struct per_cpu_pageset, since it
    is a constant value and rarely be changed.
    c) Cut down instructions in __inc_numa_state() due to the incremental
    numa counter and the consistant numa threshold.
    d) Move zone_numa_state_snapshot() to an individual patch, since it
    does not appear to be related to this patch.

Signed-off-by: Kemi Wang <kemi.wang@intel.com>
Suggested-by: Dave Hansen <dave.hansen@intel.com>
Suggested-by: Ying Huang <ying.huang@intel.com>
---
 include/linux/mmzone.h |  3 +--
 mm/vmstat.c            | 28 ++++++++++------------------
 2 files changed, 11 insertions(+), 20 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 582f6d9..c386ec4 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -282,8 +282,7 @@ struct per_cpu_pageset {
 	struct per_cpu_pages pcp;
 #ifdef CONFIG_NUMA
 	s8 expire;
-	s8 numa_stat_threshold;
-	s8 vm_numa_stat_diff[NR_VM_NUMA_STAT_ITEMS];
+	u16 vm_numa_stat_diff[NR_VM_NUMA_STAT_ITEMS];
 #endif
 #ifdef CONFIG_SMP
 	s8 stat_threshold;
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 0c3b54b..b015f39 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -30,6 +30,8 @@
 
 #include "internal.h"
 
+#define NUMA_STATS_THRESHOLD (U16_MAX - 2)
+
 #ifdef CONFIG_VM_EVENT_COUNTERS
 DEFINE_PER_CPU(struct vm_event_state, vm_event_states) = {{0}};
 EXPORT_PER_CPU_SYMBOL(vm_event_states);
@@ -194,10 +196,7 @@ void refresh_zone_stat_thresholds(void)
 
 			per_cpu_ptr(zone->pageset, cpu)->stat_threshold
 							= threshold;
-#ifdef CONFIG_NUMA
-			per_cpu_ptr(zone->pageset, cpu)->numa_stat_threshold
-							= threshold;
-#endif
+
 			/* Base nodestat threshold on the largest populated zone. */
 			pgdat_threshold = per_cpu_ptr(pgdat->per_cpu_nodestats, cpu)->stat_threshold;
 			per_cpu_ptr(pgdat->per_cpu_nodestats, cpu)->stat_threshold
@@ -231,14 +230,9 @@ void set_pgdat_percpu_threshold(pg_data_t *pgdat,
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
 
@@ -872,16 +866,14 @@ void __inc_numa_state(struct zone *zone,
 				 enum numa_stat_item item)
 {
 	struct per_cpu_pageset __percpu *pcp = zone->pageset;
-	s8 __percpu *p = pcp->vm_numa_stat_diff + item;
-	s8 v, t;
+	u16 __percpu *p = pcp->vm_numa_stat_diff + item;
+	u16 v;
 
 	v = __this_cpu_inc_return(*p);
-	t = __this_cpu_read(pcp->numa_stat_threshold);
-	if (unlikely(v > t)) {
-		s8 overstep = t >> 1;
 
-		zone_numa_state_add(v + overstep, zone, item);
-		__this_cpu_write(*p, -overstep);
+	if (unlikely(v > NUMA_STATS_THRESHOLD)) {
+		zone_numa_state_add(v, zone, item);
+		__this_cpu_write(*p, 0);
 	}
 }
 
@@ -1796,7 +1788,7 @@ static bool need_update(int cpu)
 
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
