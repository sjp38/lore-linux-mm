Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 97FF06B0253
	for <linux-mm@kvack.org>; Fri, 15 Sep 2017 05:24:53 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id j16so3839637pga.6
        for <linux-mm@kvack.org>; Fri, 15 Sep 2017 02:24:53 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id o1si419828pll.166.2017.09.15.02.24.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Sep 2017 02:24:52 -0700 (PDT)
From: Kemi Wang <kemi.wang@intel.com>
Subject: [PATCH 2/3] mm: Handle numa statistics distinctively based-on different VM stats modes
Date: Fri, 15 Sep 2017 17:23:25 +0800
Message-Id: <1505467406-9945-3-git-send-email-kemi.wang@intel.com>
In-Reply-To: <1505467406-9945-1-git-send-email-kemi.wang@intel.com>
References: <1505467406-9945-1-git-send-email-kemi.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luis R . Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Christopher Lameter <cl@linux.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>, Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: Dave <dave.hansen@linux.intel.com>, Tim Chen <tim.c.chen@intel.com>, Andi Kleen <andi.kleen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Kemi Wang <kemi.wang@intel.com>, Proc sysctl <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

Each page allocation updates a set of per-zone statistics with a call to
zone_statistics().  As discussed at the 2017 MM Summit, these are a
substantial source of overhead in the page allocator and are very rarely
consumed.

A link to the MM summit slides:
http://people.netfilter.org/hawk/presentations/MM-summit2017/MM-summit2017
-JesperBrouer.pdf

Therefore, with different VM stats mode, numa counters update can operate
differently so that everybody can benefit:
If vmstat_mode = auto, automatic detection of numa statistics, numa counter
update is skipped unless it has been read by users at least once,
e.g. cat /proc/zoneinfo.

If vmstat_mode = strict, numa counter is updated for each page allocation.

If vmstat_mode = coarse, numa counter update is ignored. We can see about
*4.8%*(185->176) drop of cpu cycles per single page allocation and reclaim
on Jesper's page_bench01 (single thread) and *8.1%*(343->315) drop of cpu
cycles per single page allocation and reclaim on Jesper's page_bench03 (88
threads) running on a 2-Socket Broadwell-based server (88 threads, 126G
memory).

Benchmark link provided by Jesper D Brouer(increase loop times to
10000000):
https://github.com/netoptimizer/prototype-kernel/tree/master/kernel/mm/
bench

Reported-by: Jesper Dangaard Brouer <brouer@redhat.com>
Suggested-by: Dave Hansen <dave.hansen@intel.com>
Suggested-by: Ying Huang <ying.huang@intel.com>
Signed-off-by: Kemi Wang <kemi.wang@intel.com>
---
 drivers/base/node.c    |  2 ++
 include/linux/vmstat.h |  6 +++++
 mm/page_alloc.c        | 13 +++++++++++
 mm/vmstat.c            | 60 +++++++++++++++++++++++++++++++++++++++++++++++---
 4 files changed, 78 insertions(+), 3 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index 3855902..033c0c3 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -153,6 +153,7 @@ static DEVICE_ATTR(meminfo, S_IRUGO, node_read_meminfo, NULL);
 static ssize_t node_read_numastat(struct device *dev,
 				struct device_attribute *attr, char *buf)
 {
+	disable_zone_statistics = false;
 	return sprintf(buf,
 		       "numa_hit %lu\n"
 		       "numa_miss %lu\n"
@@ -194,6 +195,7 @@ static ssize_t node_read_vmstat(struct device *dev,
 			     NR_VM_NUMA_STAT_ITEMS],
 			     node_page_state(pgdat, i));
 
+	disable_zone_statistics = false;
 	return n;
 }
 static DEVICE_ATTR(vmstat, S_IRUGO, node_read_vmstat, NULL);
diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index c3634c7..ca9854c 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -9,6 +9,7 @@
 
 extern int sysctl_stat_interval;
 
+extern bool disable_zone_statistics;
 /*
  * vmstat_mode:
  * 0 = auto mode of vmstat, automatic detection of VM statistics.
@@ -19,6 +20,7 @@ extern int sysctl_stat_interval;
 #define VMSTAT_STRICT_MODE  1
 #define VMSTAT_COARSE_MODE  2
 #define VMSTAT_MODE_LEN 16
+extern int vmstat_mode;
 extern char sysctl_vmstat_mode[];
 extern int sysctl_vmstat_mode_handler(struct ctl_table *table, int write,
 		void __user *buffer, size_t *length, loff_t *ppos);
@@ -243,6 +245,10 @@ extern unsigned long sum_zone_node_page_state(int node,
 extern unsigned long sum_zone_numa_state(int node, enum numa_stat_item item);
 extern unsigned long node_page_state(struct pglist_data *pgdat,
 						enum node_stat_item item);
+extern void zero_zone_numa_counters(struct zone *zone);
+extern void zero_zones_numa_counters(void);
+extern void zero_global_numa_counters(void);
+extern void invalid_numa_statistics(void);
 #else
 #define sum_zone_node_page_state(node, item) global_zone_page_state(item)
 #define node_page_state(node, item) global_node_page_state(item)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c841af8..010a620 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -83,6 +83,8 @@ DEFINE_PER_CPU(int, numa_node);
 EXPORT_PER_CPU_SYMBOL(numa_node);
 #endif
 
+bool disable_zone_statistics = true;
+
 #ifdef CONFIG_HAVE_MEMORYLESS_NODES
 /*
  * N.B., Do NOT reference the '_numa_mem_' per cpu variable directly.
@@ -2743,6 +2745,17 @@ static inline void zone_statistics(struct zone *preferred_zone, struct zone *z)
 #ifdef CONFIG_NUMA
 	enum numa_stat_item local_stat = NUMA_LOCAL;
 
+	/*
+	 * skip zone_statistics() if vmstat is a coarse mode or zone statistics
+	 * is inactive in auto vmstat mode
+	 */
+
+	if (vmstat_mode) {
+		if (vmstat_mode == VMSTAT_COARSE_MODE)
+			return;
+	} else if (disable_zone_statistics)
+		return;
+
 	if (z->node != numa_node_id())
 		local_stat = NUMA_OTHER;
 
diff --git a/mm/vmstat.c b/mm/vmstat.c
index e675ad2..bcaef62 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -85,15 +85,31 @@ int sysctl_vmstat_mode_handler(struct ctl_table *table, int write,
 			/* no change */
 			mutex_unlock(&vmstat_mode_lock);
 			return 0;
-		} else if (vmstat_mode == VMSTAT_AUTO_MODE)
+		} else if (vmstat_mode == VMSTAT_AUTO_MODE) {
 			pr_info("vmstat mode changes from %s to auto mode\n",
 					vmstat_mode_name[oldval]);
-		else if (vmstat_mode == VMSTAT_STRICT_MODE)
+			/*
+			 * Set default numa stats action when vmstat mode changes
+			 * from coarse to auto
+			 */
+			if (oldval == VMSTAT_COARSE_MODE)
+				disable_zone_statistics = true;
+		} else if (vmstat_mode == VMSTAT_STRICT_MODE)
 			pr_info("vmstat mode changes from %s to strict mode\n",
 					vmstat_mode_name[oldval]);
-		else if (vmstat_mode == VMSTAT_COARSE_MODE)
+		else if (vmstat_mode == VMSTAT_COARSE_MODE) {
 			pr_info("vmstat mode changes from %s to coarse mode\n",
 					vmstat_mode_name[oldval]);
+#ifdef CONFIG_NUMA
+			/*
+			 * Invalidate numa counters when vmstat mode is set to coarse
+			 * mode, because users can't tell the difference between the
+			 * dead state and when allocator activity is quiet once
+			 * zone_statistics() is turned off.
+			 */
+			invalid_numa_statistics();
+#endif
+		}
 		else
 			pr_warn("invalid vmstat_mode:%d\n", vmstat_mode);
 	}
@@ -984,6 +1000,42 @@ unsigned long sum_zone_numa_state(int node,
 	return count;
 }
 
+/* zero numa counters within a zone */
+void zero_zone_numa_counters(struct zone *zone)
+{
+	int item, cpu;
+
+	for (item = 0; item < NR_VM_NUMA_STAT_ITEMS; item++) {
+		atomic_long_set(&zone->vm_numa_stat[item], 0);
+		for_each_online_cpu(cpu)
+			per_cpu_ptr(zone->pageset, cpu)->vm_numa_stat_diff[item] = 0;
+	}
+}
+
+/* zero numa counters of all the populated zones */
+void zero_zones_numa_counters(void)
+{
+	struct zone *zone;
+
+	for_each_populated_zone(zone)
+		zero_zone_numa_counters(zone);
+}
+
+/* zero global numa counters */
+void zero_global_numa_counters(void)
+{
+	int item;
+
+	for (item = 0; item < NR_VM_NUMA_STAT_ITEMS; item++)
+		atomic_long_set(&vm_numa_stat[item], 0);
+}
+
+void invalid_numa_statistics(void)
+{
+	zero_zones_numa_counters();
+	zero_global_numa_counters();
+}
+
 /*
  * Determine the per node value of a stat item.
  */
@@ -1652,6 +1704,7 @@ static int zoneinfo_show(struct seq_file *m, void *arg)
 {
 	pg_data_t *pgdat = (pg_data_t *)arg;
 	walk_zones_in_node(m, pgdat, false, false, zoneinfo_show_print);
+	disable_zone_statistics = false;
 	return 0;
 }
 
@@ -1748,6 +1801,7 @@ static int vmstat_show(struct seq_file *m, void *arg)
 
 static void vmstat_stop(struct seq_file *m, void *arg)
 {
+	disable_zone_statistics = false;
 	kfree(m->private);
 	m->private = NULL;
 }
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
