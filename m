Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 52BBA6B0038
	for <linux-mm@kvack.org>; Mon, 16 Oct 2017 21:22:44 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id u70so161836pfa.2
        for <linux-mm@kvack.org>; Mon, 16 Oct 2017 18:22:44 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id 99si5423834pla.563.2017.10.16.18.22.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Oct 2017 18:22:42 -0700 (PDT)
From: Kemi Wang <kemi.wang@intel.com>
Subject: [PATCH v4] mm, sysctl: make NUMA stats configurable
Date: Tue, 17 Oct 2017 09:20:58 +0800
Message-Id: <1508203258-9444-1-git-send-email-kemi.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luis R . Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Christopher Lameter <cl@linux.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>, Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Dave <dave.hansen@linux.intel.com>, Tim Chen <tim.c.chen@intel.com>, Andi Kleen <andi.kleen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Kemi Wang <kemi.wang@intel.com>, Proc sysctl <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

This is the second step which introduces a tunable interface that allow
numa stats configurable for optimizing zone_statistics(), as suggested by
Dave Hansen and Ying Huang.

=========================================================================
When page allocation performance becomes a bottleneck and you can tolerate
some possible tool breakage and decreased numa counter precision, you can
do:
	echo 0 > /proc/sys/vm/numa_stat
In this case, numa counter update is ignored. We can see about
*4.8%*(185->176) drop of cpu cycles per single page allocation and reclaim
on Jesper's page_bench01 (single thread) and *8.1%*(343->315) drop of cpu
cycles per single page allocation and reclaim on Jesper's page_bench03 (88
threads) running on a 2-Socket Broadwell-based server (88 threads, 126G
memory).

Benchmark link provided by Jesper D Brouer(increase loop times to
10000000):
https://github.com/netoptimizer/prototype-kernel/tree/master/kernel/mm/
bench

=========================================================================
When page allocation performance is not a bottleneck and you want all
tooling to work, you can do:
	echo 1 > /proc/sys/vm/numa_stat
This is system default setting.

Many thanks to Michal Hocko, Dave Hansen, Ying Huang and Vlastimil Babka
for comments to help improve the original patch.

ChangeLog:
  V3->V4
  a) Get rid of auto mode of numa stats, and may add it back if necessary,
  as alignment before;
  b) Skip NUMA_INTERLEAVE_HIT counter update when numa stats is disabled,
  as reported by Andrey Ryabinin. See commit "de55c8b2519" for details
  c) Remove extern declaration for those clear_numa_ function, and make
  them static in vmstat.c, as suggested by Vlastimil Babka.

  V2->V3:
  a) Propose a better way to use jump label to eliminate the overhead of
  branch selection in zone_statistics(), as inspired by Ying Huang;
  b) Add a paragraph in commit log to describe the way for branch target
  selection;
  c) Use a more descriptive name numa_stats_mode instead of vmstat_mode,
  and change the description accordingly, as suggested by Michal Hocko;
  d) Make this functionality NUMA-specific via ifdef

  V1->V2:
  a) Merge to one patch;
  b) Use jump label to eliminate the overhead of branch selection;
  c) Add a single-time log message at boot time to help tell users what
  happened.

Reported-by: Jesper Dangaard Brouer <brouer@redhat.com>
Suggested-by: Dave Hansen <dave.hansen@intel.com>
Suggested-by: Ying Huang <ying.huang@intel.com>
Signed-off-by: Kemi Wang <kemi.wang@intel.com>
---
 Documentation/sysctl/vm.txt | 16 +++++++++++
 include/linux/vmstat.h      | 10 +++++++
 kernel/sysctl.c             |  7 +++++
 mm/mempolicy.c              |  3 ++
 mm/page_alloc.c             |  6 ++++
 mm/vmstat.c                 | 70 +++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 112 insertions(+)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 9baf66a..f65c5c7 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -58,6 +58,7 @@ Currently, these files are in /proc/sys/vm:
 - percpu_pagelist_fraction
 - stat_interval
 - stat_refresh
+- numa_stat
 - swappiness
 - user_reserve_kbytes
 - vfs_cache_pressure
@@ -792,6 +793,21 @@ with no ill effects: errors and warnings on these stats are suppressed.)
 
 ==============================================================
 
+numa_stat
+
+This interface allows runtime configuration of numa statistics.
+
+When page allocation performance becomes a bottleneck and you can tolerate
+some possible tool breakage and decreased numa counter precision, you can
+do:
+	echo 0 > /proc/sys/vm/numa_stat
+
+When page allocation performance is not a bottleneck and you want all
+tooling to work, you can do:
+	echo 1 > /proc/sys/vm/numa_stat
+
+==============================================================
+
 swappiness
 
 This control is used to define how aggressive the kernel will swap
diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index ade7cb5..c605c94 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -6,9 +6,19 @@
 #include <linux/mmzone.h>
 #include <linux/vm_event_item.h>
 #include <linux/atomic.h>
+#include <linux/static_key.h>
 
 extern int sysctl_stat_interval;
 
+#ifdef CONFIG_NUMA
+#define ENABLE_NUMA_STAT   1
+#define DISABLE_NUMA_STAT   0
+extern int sysctl_vm_numa_stat;
+DECLARE_STATIC_KEY_TRUE(vm_numa_stat_key);
+extern int sysctl_vm_numa_stat_handler(struct ctl_table *table,
+		int write, void __user *buffer, size_t *length, loff_t *ppos);
+#endif
+
 #ifdef CONFIG_VM_EVENT_COUNTERS
 /*
  * Light weight per cpu counter implementation.
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index d9c31bc..f6a79a3 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1371,6 +1371,13 @@ static struct ctl_table vm_table[] = {
 		.mode           = 0644,
 		.proc_handler   = &hugetlb_mempolicy_sysctl_handler,
 	},
+	{
+		.procname		= "numa_stat",
+		.data			= &sysctl_vm_numa_stat,
+		.maxlen			= sizeof(int),
+		.mode			= 0644,
+		.proc_handler	= sysctl_vm_numa_stat_handler,
+	},
 #endif
 	 {
 		.procname	= "hugetlb_shm_group",
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index a2af6d5..78344cf 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1920,6 +1920,9 @@ static struct page *alloc_page_interleave(gfp_t gfp, unsigned order,
 	struct page *page;
 
 	page = __alloc_pages(gfp, order, nid);
+	/* skip NUMA_INTERLEAVE_HIT counter update if numa stats is disabled */
+	if (!static_branch_likely(&vm_numa_stat_key))
+		return page;
 	if (page && page_to_nid(page) == nid) {
 		preempt_disable();
 		__inc_numa_state(page_zone(page), NUMA_INTERLEAVE_HIT);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 77e4d3c..7bdb4f7 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -83,6 +83,8 @@ DEFINE_PER_CPU(int, numa_node);
 EXPORT_PER_CPU_SYMBOL(numa_node);
 #endif
 
+DEFINE_STATIC_KEY_TRUE(vm_numa_stat_key);
+
 #ifdef CONFIG_HAVE_MEMORYLESS_NODES
 /*
  * N.B., Do NOT reference the '_numa_mem_' per cpu variable directly.
@@ -2743,6 +2745,10 @@ static inline void zone_statistics(struct zone *preferred_zone, struct zone *z)
 #ifdef CONFIG_NUMA
 	enum numa_stat_item local_stat = NUMA_LOCAL;
 
+	/* skip numa counters update if numa stats is disabled */
+	if (!static_branch_likely(&vm_numa_stat_key))
+		return;
+
 	if (z->node != numa_node_id())
 		local_stat = NUMA_OTHER;
 
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 4bb13e7..e746ed1 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -32,6 +32,76 @@
 
 #define NUMA_STATS_THRESHOLD (U16_MAX - 2)
 
+#ifdef CONFIG_NUMA
+int sysctl_vm_numa_stat = ENABLE_NUMA_STAT;
+static DEFINE_MUTEX(vm_numa_stat_lock);
+
+/* zero numa counters within a zone */
+static void zero_zone_numa_counters(struct zone *zone)
+{
+	int item, cpu;
+
+	for (item = 0; item < NR_VM_NUMA_STAT_ITEMS; item++) {
+		atomic_long_set(&zone->vm_numa_stat[item], 0);
+		for_each_online_cpu(cpu)
+			per_cpu_ptr(zone->pageset, cpu)->vm_numa_stat_diff[item]
+						= 0;
+	}
+}
+
+/* zero numa counters of all the populated zones */
+static void zero_zones_numa_counters(void)
+{
+	struct zone *zone;
+
+	for_each_populated_zone(zone)
+		zero_zone_numa_counters(zone);
+}
+
+/* zero global numa counters */
+static void zero_global_numa_counters(void)
+{
+	int item;
+
+	for (item = 0; item < NR_VM_NUMA_STAT_ITEMS; item++)
+		atomic_long_set(&vm_numa_stat[item], 0);
+}
+
+static void invalid_numa_statistics(void)
+{
+	zero_zones_numa_counters();
+	zero_global_numa_counters();
+}
+
+int sysctl_vm_numa_stat_handler(struct ctl_table *table, int write,
+		void __user *buffer, size_t *length, loff_t *ppos)
+{
+	int ret, oldval;
+
+	mutex_lock(&vm_numa_stat_lock);
+	if (write)
+		oldval = sysctl_vm_numa_stat;
+	ret = proc_dointvec(table, write, buffer, length, ppos);
+	if (ret || !write)
+		goto out;
+
+	if (oldval == sysctl_vm_numa_stat)
+		goto out;
+	else if (oldval == DISABLE_NUMA_STAT) {
+		static_branch_enable(&vm_numa_stat_key);
+		pr_info("enable numa statistics\n");
+	} else if (sysctl_vm_numa_stat == DISABLE_NUMA_STAT) {
+		static_branch_disable(&vm_numa_stat_key);
+		invalid_numa_statistics();
+		pr_info("disable numa statistics, and clear numa counters\n");
+	}
+
+out:
+	mutex_unlock(&vm_numa_stat_lock);
+	return ret;
+}
+#endif
+
 #ifdef CONFIG_VM_EVENT_COUNTERS
 DEFINE_PER_CPU(struct vm_event_state, vm_event_states) = {{0}};
 EXPORT_PER_CPU_SYMBOL(vm_event_states);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
