Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 77ED66B0071
	for <linux-mm@kvack.org>; Tue, 10 Sep 2013 05:32:59 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 24/50] sched: Reschedule task on preferred NUMA node once selected
Date: Tue, 10 Sep 2013 10:32:04 +0100
Message-Id: <1378805550-29949-25-git-send-email-mgorman@suse.de>
In-Reply-To: <1378805550-29949-1-git-send-email-mgorman@suse.de>
References: <1378805550-29949-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

A preferred node is selected based on the node the most NUMA hinting
faults was incurred on. There is no guarantee that the task is running
on that node at the time so this patch rescheules the task to run on
the most idle CPU of the selected node when selected. This avoids
waiting for the balancer to make a decision.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 kernel/sched/core.c  | 19 +++++++++++++++++++
 kernel/sched/fair.c  | 46 +++++++++++++++++++++++++++++++++++++++++++++-
 kernel/sched/sched.h |  1 +
 3 files changed, 65 insertions(+), 1 deletion(-)

diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 0dbd5cd..e94509d 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -4368,6 +4368,25 @@ fail:
 	return ret;
 }
 
+#ifdef CONFIG_NUMA_BALANCING
+/* Migrate current task p to target_cpu */
+int migrate_task_to(struct task_struct *p, int target_cpu)
+{
+	struct migration_arg arg = { p, target_cpu };
+	int curr_cpu = task_cpu(p);
+
+	if (curr_cpu == target_cpu)
+		return 0;
+
+	if (!cpumask_test_cpu(target_cpu, tsk_cpus_allowed(p)))
+		return -EINVAL;
+
+	/* TODO: This is not properly updating schedstats */
+
+	return stop_one_cpu(curr_cpu, migration_cpu_stop, &arg);
+}
+#endif
+
 /*
  * migration_cpu_stop - this will be executed by a highprio stopper thread
  * and performs thread migration by bumping thread off CPU then
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 5649280..350c411 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -886,6 +886,31 @@ static unsigned int task_scan_max(struct task_struct *p)
  */
 unsigned int sysctl_numa_balancing_settle_count __read_mostly = 3;
 
+static unsigned long weighted_cpuload(const int cpu);
+
+
+static int
+find_idlest_cpu_node(int this_cpu, int nid)
+{
+	unsigned long load, min_load = ULONG_MAX;
+	int i, idlest_cpu = this_cpu;
+
+	BUG_ON(cpu_to_node(this_cpu) == nid);
+
+	rcu_read_lock();
+	for_each_cpu(i, cpumask_of_node(nid)) {
+		load = weighted_cpuload(i);
+
+		if (load < min_load) {
+			min_load = load;
+			idlest_cpu = i;
+		}
+	}
+	rcu_read_unlock();
+
+	return idlest_cpu;
+}
+
 static void task_numa_placement(struct task_struct *p)
 {
 	int seq, nid, max_nid = -1;
@@ -916,10 +941,29 @@ static void task_numa_placement(struct task_struct *p)
 		}
 	}
 
-	/* Update the tasks preferred node if necessary */
+	/*
+	 * Record the preferred node as the node with the most faults,
+	 * requeue the task to be running on the idlest CPU on the
+	 * preferred node and reset the scanning rate to recheck
+	 * the working set placement.
+	 */
 	if (max_faults && max_nid != p->numa_preferred_nid) {
+		int preferred_cpu;
+
+		/*
+		 * If the task is not on the preferred node then find the most
+		 * idle CPU to migrate to.
+		 */
+		preferred_cpu = task_cpu(p);
+		if (cpu_to_node(preferred_cpu) != max_nid) {
+			preferred_cpu = find_idlest_cpu_node(preferred_cpu,
+							     max_nid);
+		}
+
+		/* Update the preferred nid and migrate task if possible */
 		p->numa_preferred_nid = max_nid;
 		p->numa_migrate_seq = 0;
+		migrate_task_to(p, preferred_cpu);
 	}
 }
 
diff --git a/kernel/sched/sched.h b/kernel/sched/sched.h
index 46c2068..778f875 100644
--- a/kernel/sched/sched.h
+++ b/kernel/sched/sched.h
@@ -555,6 +555,7 @@ static inline u64 rq_clock_task(struct rq *rq)
 }
 
 #ifdef CONFIG_NUMA_BALANCING
+extern int migrate_task_to(struct task_struct *p, int cpu);
 static inline void task_numa_free(struct task_struct *p)
 {
 	kfree(p->numa_faults);
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
