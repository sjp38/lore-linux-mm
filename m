Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id F10832803BB
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 06:01:28 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id m7so1218008pga.8
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 03:01:28 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id e84si2545920pfh.35.2017.08.24.03.01.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Aug 2017 03:01:27 -0700 (PDT)
From: Kemi Wang <kemi.wang@intel.com>
Subject: [PATCH v2 3/3] mm: Consider the number in local CPUs when *reads* NUMA stats
Date: Thu, 24 Aug 2017 18:00:01 +0800
Message-Id: <1503568801-21305-4-git-send-email-kemi.wang@intel.com>
In-Reply-To: <1503568801-21305-1-git-send-email-kemi.wang@intel.com>
References: <1503568801-21305-1-git-send-email-kemi.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Christopher Lameter <cl@linux.com>
Cc: Dave <dave.hansen@linux.intel.com>, Andi Kleen <andi.kleen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Tim Chen <tim.c.chen@intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Kemi Wang <kemi.wang@intel.com>

To avoid deviation, the per cpu number of NUMA stats in vm_numa_stat_diff[]
is included when a user *reads* the NUMA stats.

Since NUMA stats does not be read by users frequently, and kernel does not
need it to make a decision, it will not be a problem to make the readers
more expensive.

Changelog:
v2:
    a) new creation.

Signed-off-by: Kemi Wang <kemi.wang@intel.com>
---
 include/linux/vmstat.h | 6 +++++-
 mm/vmstat.c            | 9 +++++++--
 2 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index a29bd98..72e9ca6 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -125,10 +125,14 @@ static inline unsigned long global_numa_state(enum numa_stat_item item)
 	return x;
 }
 
-static inline unsigned long zone_numa_state(struct zone *zone,
+static inline unsigned long zone_numa_state_snapshot(struct zone *zone,
 					enum numa_stat_item item)
 {
 	long x = atomic_long_read(&zone->vm_numa_stat[item]);
+	int cpu;
+
+	for_each_online_cpu(cpu)
+		x += per_cpu_ptr(zone->pageset, cpu)->vm_numa_stat_diff[item];
 
 	return x;
 }
diff --git a/mm/vmstat.c b/mm/vmstat.c
index b015f39..abeab81 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -895,6 +895,10 @@ unsigned long sum_zone_node_page_state(int node,
 	return count;
 }
 
+/*
+ * Determine the per node value of a numa stat item. To avoid deviation,
+ * the per cpu stat number in vm_numa_stat_diff[] is also included.
+ */
 unsigned long sum_zone_numa_state(int node,
 				 enum numa_stat_item item)
 {
@@ -903,7 +907,7 @@ unsigned long sum_zone_numa_state(int node,
 	unsigned long count = 0;
 
 	for (i = 0; i < MAX_NR_ZONES; i++)
-		count += zone_numa_state(zones + i, item);
+		count += zone_numa_state_snapshot(zones + i, item);
 
 	return count;
 }
@@ -1534,7 +1538,7 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
 	for (i = 0; i < NR_VM_NUMA_STAT_ITEMS; i++)
 		seq_printf(m, "\n      %-12s %lu",
 				vmstat_text[i + NR_VM_ZONE_STAT_ITEMS],
-				zone_numa_state(zone, i));
+				zone_numa_state_snapshot(zone, i));
 #endif
 
 	seq_printf(m, "\n  pagesets");
@@ -1790,6 +1794,7 @@ static bool need_update(int cpu)
 #ifdef CONFIG_NUMA
 		BUILD_BUG_ON(sizeof(p->vm_numa_stat_diff[0]) != 2);
 #endif
+
 		/*
 		 * The fast way of checking if there are any vmstat diffs.
 		 * This works because the diffs are byte sized items.
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
