Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id D4E8B9C000E
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 06:30:05 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id r10so7011399pdi.28
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 03:30:05 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 22/63] sched: Favour moving tasks towards the preferred node
Date: Mon,  7 Oct 2013 11:29:00 +0100
Message-Id: <1381141781-10992-23-git-send-email-mgorman@suse.de>
In-Reply-To: <1381141781-10992-1-git-send-email-mgorman@suse.de>
References: <1381141781-10992-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

This patch favours moving tasks towards NUMA node that recorded a higher
number of NUMA faults during active load balancing.  Ideally this is
self-reinforcing as the longer the task runs on that node, the more faults
it should incur causing task_numa_placement to keep the task running on that
node. In reality a big weakness is that the nodes CPUs can be overloaded
and it would be more efficient to queue tasks on an idle node and migrate
to the new node. This would require additional smarts in the balancer so
for now the balancer will simply prefer to place the task on the preferred
node for a PTE scans which is controlled by the numa_balancing_settle_count
sysctl. Once the settle_count number of scans has complete the schedule
is free to place the task on an alternative node if the load is imbalanced.

[srikar@linux.vnet.ibm.com: Fixed statistics]
[peterz@infradead.org: Tunable and use higher faults instead of preferred]
Signed-off-by: Peter Zijlstra <peterz@infradead.org>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 Documentation/sysctl/kernel.txt |  8 +++++-
 include/linux/sched.h           |  1 +
 kernel/sched/core.c             |  3 +-
 kernel/sched/fair.c             | 63 ++++++++++++++++++++++++++++++++++++++---
 kernel/sched/features.h         |  7 +++++
 kernel/sysctl.c                 |  7 +++++
 6 files changed, 83 insertions(+), 6 deletions(-)

diff --git a/Documentation/sysctl/kernel.txt b/Documentation/sysctl/kernel.txt
index 8cd7e5f..d48bca4 100644
--- a/Documentation/sysctl/kernel.txt
+++ b/Documentation/sysctl/kernel.txt
@@ -375,7 +375,8 @@ feature should be disabled. Otherwise, if the system overhead from the
 feature is too high then the rate the kernel samples for NUMA hinting
 faults may be controlled by the numa_balancing_scan_period_min_ms,
 numa_balancing_scan_delay_ms, numa_balancing_scan_period_reset,
-numa_balancing_scan_period_max_ms and numa_balancing_scan_size_mb sysctls.
+numa_balancing_scan_period_max_ms, numa_balancing_scan_size_mb and
+numa_balancing_settle_count sysctls.
 
 ==============================================================
 
@@ -420,6 +421,11 @@ scanned for a given scan.
 numa_balancing_scan_period_reset is a blunt instrument that controls how
 often a tasks scan delay is reset to detect sudden changes in task behaviour.
 
+numa_balancing_settle_count is how many scan periods must complete before
+the schedule balancer stops pushing the task towards a preferred node. This
+gives the scheduler a chance to place the task on an alternative node if the
+preferred node is overloaded.
+
 ==============================================================
 
 osrelease, ostype & version:
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 2e02757..d5ae4bd 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -768,6 +768,7 @@ enum cpu_idle_type {
 #define SD_ASYM_PACKING		0x0800  /* Place busy groups earlier in the domain */
 #define SD_PREFER_SIBLING	0x1000	/* Prefer to place tasks in a sibling domain */
 #define SD_OVERLAP		0x2000	/* sched_domains of this level overlap */
+#define SD_NUMA			0x4000	/* cross-node balancing */
 
 extern int __weak arch_sd_sibiling_asym_packing(void);
 
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 201c953..3515c41 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -1626,7 +1626,7 @@ static void __sched_fork(struct task_struct *p)
 
 	p->node_stamp = 0ULL;
 	p->numa_scan_seq = p->mm ? p->mm->numa_scan_seq : 0;
-	p->numa_migrate_seq = p->mm ? p->mm->numa_scan_seq - 1 : 0;
+	p->numa_migrate_seq = 0;
 	p->numa_scan_period = sysctl_numa_balancing_scan_delay;
 	p->numa_preferred_nid = -1;
 	p->numa_work.next = &p->numa_work;
@@ -5661,6 +5661,7 @@ sd_numa_init(struct sched_domain_topology_level *tl, int cpu)
 					| 0*SD_SHARE_PKG_RESOURCES
 					| 1*SD_SERIALIZE
 					| 0*SD_PREFER_SIBLING
+					| 1*SD_NUMA
 					| sd_local_flags(level)
 					,
 		.last_balance		= jiffies,
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 6227fb4..8c2b779 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -877,6 +877,15 @@ static unsigned int task_scan_max(struct task_struct *p)
 	return max(smin, smax);
 }
 
+/*
+ * Once a preferred node is selected the scheduler balancer will prefer moving
+ * a task to that node for sysctl_numa_balancing_settle_count number of PTE
+ * scans. This will give the process the chance to accumulate more faults on
+ * the preferred node but still allow the scheduler to move the task again if
+ * the nodes CPUs are overloaded.
+ */
+unsigned int sysctl_numa_balancing_settle_count __read_mostly = 3;
+
 static void task_numa_placement(struct task_struct *p)
 {
 	int seq, nid, max_nid = -1;
@@ -888,6 +897,7 @@ static void task_numa_placement(struct task_struct *p)
 	if (p->numa_scan_seq == seq)
 		return;
 	p->numa_scan_seq = seq;
+	p->numa_migrate_seq++;
 	p->numa_scan_period_max = task_scan_max(p);
 
 	/* Find the node with the highest number of faults */
@@ -907,8 +917,10 @@ static void task_numa_placement(struct task_struct *p)
 	}
 
 	/* Update the tasks preferred node if necessary */
-	if (max_faults && max_nid != p->numa_preferred_nid)
+	if (max_faults && max_nid != p->numa_preferred_nid) {
 		p->numa_preferred_nid = max_nid;
+		p->numa_migrate_seq = 0;
+	}
 }
 
 /*
@@ -4070,6 +4082,38 @@ task_hot(struct task_struct *p, u64 now, struct sched_domain *sd)
 	return delta < (s64)sysctl_sched_migration_cost;
 }
 
+#ifdef CONFIG_NUMA_BALANCING
+/* Returns true if the destination node has incurred more faults */
+static bool migrate_improves_locality(struct task_struct *p, struct lb_env *env)
+{
+	int src_nid, dst_nid;
+
+	if (!sched_feat(NUMA_FAVOUR_HIGHER) || !p->numa_faults ||
+	    !(env->sd->flags & SD_NUMA)) {
+		return false;
+	}
+
+	src_nid = cpu_to_node(env->src_cpu);
+	dst_nid = cpu_to_node(env->dst_cpu);
+
+	if (src_nid == dst_nid ||
+	    p->numa_migrate_seq >= sysctl_numa_balancing_settle_count)
+		return false;
+
+	if (dst_nid == p->numa_preferred_nid ||
+	    p->numa_faults[dst_nid] > p->numa_faults[src_nid])
+		return true;
+
+	return false;
+}
+#else
+static inline bool migrate_improves_locality(struct task_struct *p,
+					     struct lb_env *env)
+{
+	return false;
+}
+#endif
+
 /*
  * can_migrate_task - may task p from runqueue rq be migrated to this_cpu?
  */
@@ -4125,11 +4169,22 @@ int can_migrate_task(struct task_struct *p, struct lb_env *env)
 
 	/*
 	 * Aggressive migration if:
-	 * 1) task is cache cold, or
-	 * 2) too many balance attempts have failed.
+	 * 1) destination numa is preferred
+	 * 2) task is cache cold, or
+	 * 3) too many balance attempts have failed.
 	 */
-
 	tsk_cache_hot = task_hot(p, rq_clock_task(env->src_rq), env->sd);
+
+	if (migrate_improves_locality(p, env)) {
+#ifdef CONFIG_SCHEDSTATS
+		if (tsk_cache_hot) {
+			schedstat_inc(env->sd, lb_hot_gained[env->idle]);
+			schedstat_inc(p, se.statistics.nr_forced_migrations);
+		}
+#endif
+		return 1;
+	}
+
 	if (!tsk_cache_hot ||
 		env->sd->nr_balance_failed > env->sd->cache_nice_tries) {
 
diff --git a/kernel/sched/features.h b/kernel/sched/features.h
index cba5c61..d9278ce 100644
--- a/kernel/sched/features.h
+++ b/kernel/sched/features.h
@@ -67,4 +67,11 @@ SCHED_FEAT(LB_MIN, false)
  */
 #ifdef CONFIG_NUMA_BALANCING
 SCHED_FEAT(NUMA,	false)
+
+/*
+ * NUMA_FAVOUR_HIGHER will favor moving tasks towards nodes where a
+ * higher number of hinting faults are recorded during active load
+ * balancing.
+ */
+SCHED_FEAT(NUMA_FAVOUR_HIGHER, true)
 #endif
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index b2f06f3..42f616a 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -391,6 +391,13 @@ static struct ctl_table kern_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
+	{
+		.procname       = "numa_balancing_settle_count",
+		.data           = &sysctl_numa_balancing_settle_count,
+		.maxlen         = sizeof(unsigned int),
+		.mode           = 0644,
+		.proc_handler   = proc_dointvec,
+	},
 #endif /* CONFIG_NUMA_BALANCING */
 #endif /* CONFIG_SCHED_DEBUG */
 	{
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
