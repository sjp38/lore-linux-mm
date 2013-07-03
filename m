Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 766446B0039
	for <linux-mm@kvack.org>; Wed,  3 Jul 2013 10:22:21 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 06/13] sched: Reschedule task on preferred NUMA node once selected
Date: Wed,  3 Jul 2013 15:21:33 +0100
Message-Id: <1372861300-9973-7-git-send-email-mgorman@suse.de>
In-Reply-To: <1372861300-9973-1-git-send-email-mgorman@suse.de>
References: <1372861300-9973-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

A preferred node is selected based on the node the most NUMA hinting
faults was incurred on. There is no guarantee that the task is running
on that node at the time so this patch rescheules the task to run on
the most idle CPU of the selected node when selected. This avoids
waiting for the balancer to make a decision.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 kernel/sched/core.c  | 18 ++++++++++++++++--
 kernel/sched/fair.c  | 54 ++++++++++++++++++++++++++++++++++++++++++++++++++--
 kernel/sched/sched.h |  2 +-
 3 files changed, 69 insertions(+), 5 deletions(-)

diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index ba9470e..b4722d6 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -5717,11 +5717,25 @@ struct sched_domain_topology_level;
 
 #ifdef CONFIG_NUMA_BALANCING
 
-/* Set a tasks preferred NUMA node */
-void sched_setnuma(struct task_struct *p, int nid)
+/* Set a tasks preferred NUMA node and reschedule to it */
+void sched_setnuma(struct task_struct *p, int nid, int idlest_cpu)
 {
+	int curr_cpu = task_cpu(p);
+	struct migration_arg arg = { p, idlest_cpu };
+
 	p->numa_preferred_nid = nid;
 	p->numa_migrate_seq = 0;
+
+	/* Do not reschedule if already running on the target CPU */
+	if (idlest_cpu == curr_cpu)
+		return;
+
+	/* Ensure the target CPU is eligible */
+	if (!cpumask_test_cpu(idlest_cpu, tsk_cpus_allowed(p)))
+		return;
+
+	/* Move current running task to idlest CPU on preferred node */
+	stop_one_cpu(curr_cpu, migration_cpu_stop, &arg);
 }
 #endif /* CONFIG_NUMA_BALANCING */
 
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 2a0bbc2..b9139be 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -800,6 +800,37 @@ unsigned int sysctl_numa_balancing_scan_delay = 1000;
  */
 unsigned int sysctl_numa_balancing_settle_count __read_mostly = 3;
 
+static unsigned long weighted_cpuload(const int cpu);
+
+static int
+find_idlest_cpu_node(int this_cpu, int nid)
+{
+	unsigned long load, min_load = ULONG_MAX;
+	int i, idlest_cpu = this_cpu;
+
+	BUG_ON(cpu_to_node(this_cpu) == nid);
+
+	for_each_cpu(i, cpumask_of_node(nid)) {
+		load = weighted_cpuload(i);
+
+		if (load < min_load) {
+			struct task_struct *p;
+
+			/* Do not preempt a task running on its preferred node */
+			struct rq *rq = cpu_rq(i);
+			raw_spin_lock_irq(&rq->lock);
+			p = rq->curr;
+			if (p->numa_preferred_nid != nid) {
+				min_load = load;
+				idlest_cpu = i;
+			}
+			raw_spin_unlock_irq(&rq->lock);
+		}
+	}
+
+	return idlest_cpu;
+}
+
 static void task_numa_placement(struct task_struct *p)
 {
 	int seq, nid, max_nid = 0;
@@ -829,8 +860,27 @@ static void task_numa_placement(struct task_struct *p)
 		}
 	}
 
-	if (max_faults && max_nid != p->numa_preferred_nid)
-		sched_setnuma(p, max_nid);
+	/*
+	 * Record the preferred node as the node with the most faults,
+	 * requeue the task to be running on the idlest CPU on the
+	 * preferred node and reset the scanning rate to recheck
+	 * the working set placement.
+	 */
+	if (max_faults && max_nid != p->numa_preferred_nid) {
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
+		sched_setnuma(p, max_nid, preferred_cpu);
+	}
 }
 
 /*
diff --git a/kernel/sched/sched.h b/kernel/sched/sched.h
index 65a0cf0..64c37a3 100644
--- a/kernel/sched/sched.h
+++ b/kernel/sched/sched.h
@@ -504,7 +504,7 @@ DECLARE_PER_CPU(struct rq, runqueues);
 #define raw_rq()		(&__raw_get_cpu_var(runqueues))
 
 #ifdef CONFIG_NUMA_BALANCING
-extern void sched_setnuma(struct task_struct *p, int nid);
+extern void sched_setnuma(struct task_struct *p, int nid, int idlest_cpu);
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
