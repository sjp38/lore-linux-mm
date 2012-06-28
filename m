Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id AE9E66B00A4
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 08:57:18 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 13/40] autonuma: CPU follow memory algorithm
Date: Thu, 28 Jun 2012 14:55:53 +0200
Message-Id: <1340888180-15355-14-git-send-email-aarcange@redhat.com>
In-Reply-To: <1340888180-15355-1-git-send-email-aarcange@redhat.com>
References: <1340888180-15355-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

This algorithm takes as input the statistical information filled by the
knuma_scand (mm->mm_autonuma) and by the NUMA hinting page faults
(p->sched_autonuma), evaluates it for the current scheduled task, and
compares it against every other running process to see if it should
move the current task to another NUMA node.

When the scheduler decides if the task should be migrated to a
different NUMA node or to stay in the same NUMA node, the decision is
then stored into p->sched_autonuma->autonuma_node. The fair scheduler
than tries to keep the task on the autonuma_node too.

Code include fixes and cleanups from Hillf Danton <dhillf@gmail.com>.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/autonuma_sched.h |   50 ++++
 include/linux/mm_types.h       |    5 +
 include/linux/sched.h          |    3 +
 kernel/sched/core.c            |    1 +
 kernel/sched/numa.c            |  586 ++++++++++++++++++++++++++++++++++++++++
 kernel/sched/sched.h           |   18 ++
 6 files changed, 663 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/autonuma_sched.h
 create mode 100644 kernel/sched/numa.c

diff --git a/include/linux/autonuma_sched.h b/include/linux/autonuma_sched.h
new file mode 100644
index 0000000..aff31d4
--- /dev/null
+++ b/include/linux/autonuma_sched.h
@@ -0,0 +1,50 @@
+#ifndef _LINUX_AUTONUMA_SCHED_H
+#define _LINUX_AUTONUMA_SCHED_H
+
+#ifdef CONFIG_AUTONUMA
+#include <linux/autonuma_flags.h>
+
+extern void sched_autonuma_balance(void);
+extern bool sched_autonuma_can_migrate_task(struct task_struct *p,
+					    int numa, int dst_cpu,
+					    enum cpu_idle_type idle);
+#else /* CONFIG_AUTONUMA */
+static inline void sched_autonuma_balance(void) {}
+static inline bool sched_autonuma_can_migrate_task(struct task_struct *p,
+						   int numa, int dst_cpu,
+						   enum cpu_idle_type idle)
+{
+	return true;
+}
+#endif /* CONFIG_AUTONUMA */
+
+static bool inline task_autonuma_cpu(struct task_struct *p, int cpu)
+{
+#ifdef CONFIG_AUTONUMA
+	int autonuma_node;
+	struct task_autonuma *task_autonuma = p->task_autonuma;
+
+	if (!task_autonuma)
+		return true;
+
+	autonuma_node = ACCESS_ONCE(task_autonuma->autonuma_node);
+	if (autonuma_node < 0 || autonuma_node == cpu_to_node(cpu))
+		return true;
+	else
+		return false;
+#else
+	return true;
+#endif
+}
+
+static inline void sched_set_autonuma_need_balance(void)
+{
+#ifdef CONFIG_AUTONUMA
+	struct task_autonuma *ta = current->task_autonuma;
+
+	if (ta && current->mm)
+		sched_autonuma_balance();
+#endif
+}
+
+#endif /* _LINUX_AUTONUMA_SCHED_H */
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 704a626..f0c6379 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -13,6 +13,7 @@
 #include <linux/cpumask.h>
 #include <linux/page-debug-flags.h>
 #include <linux/uprobes.h>
+#include <linux/autonuma_types.h>
 #include <asm/page.h>
 #include <asm/mmu.h>
 
@@ -389,6 +390,10 @@ struct mm_struct {
 	struct cpumask cpumask_allocation;
 #endif
 	struct uprobes_state uprobes_state;
+#ifdef CONFIG_AUTONUMA
+	/* this is used by the scheduler and the page allocator */
+	struct mm_autonuma *mm_autonuma;
+#endif
 };
 
 static inline void mm_init_cpumask(struct mm_struct *mm)
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 699324c..cb20347 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1514,6 +1514,9 @@ struct task_struct {
 	struct mempolicy *mempolicy;	/* Protected by alloc_lock */
 	short il_next;
 	short pref_node_fork;
+#ifdef CONFIG_AUTONUMA
+	struct task_autonuma *task_autonuma;
+#endif
 #endif
 	struct rcu_head rcu;
 
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index d5594a4..a8f94b9 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -72,6 +72,7 @@
 #include <linux/slab.h>
 #include <linux/init_task.h>
 #include <linux/binfmts.h>
+#include <linux/autonuma_sched.h>
 
 #include <asm/switch_to.h>
 #include <asm/tlb.h>
diff --git a/kernel/sched/numa.c b/kernel/sched/numa.c
new file mode 100644
index 0000000..72f6158
--- /dev/null
+++ b/kernel/sched/numa.c
@@ -0,0 +1,586 @@
+/*
+ *  Copyright (C) 2012  Red Hat, Inc.
+ *
+ *  This work is licensed under the terms of the GNU GPL, version 2. See
+ *  the COPYING file in the top-level directory.
+ */
+
+#include <linux/sched.h>
+#include <linux/autonuma_sched.h>
+#include <asm/tlb.h>
+
+#include "sched.h"
+
+/*
+ * autonuma_balance_cpu_stop() is a callback to be invoked by
+ * stop_one_cpu_nowait(). It is used by sched_autonuma_balance() to
+ * migrate the tasks to the selected_cpu, from softirq context.
+ */
+static int autonuma_balance_cpu_stop(void *data)
+{
+	struct rq *src_rq = data;
+	int src_cpu = cpu_of(src_rq);
+	int dst_cpu = src_rq->autonuma_balance_dst_cpu;
+	struct task_struct *p = src_rq->autonuma_balance_task;
+	struct rq *dst_rq = cpu_rq(dst_cpu);
+
+	raw_spin_lock_irq(&p->pi_lock);
+	raw_spin_lock(&src_rq->lock);
+
+	/* Make sure the selected cpu hasn't gone down in the meanwhile */
+	if (unlikely(src_cpu != smp_processor_id() ||
+		     !src_rq->autonuma_balance))
+		goto out_unlock;
+
+	/* Check if the affinity changed in the meanwhile */
+	if (!cpumask_test_cpu(dst_cpu, tsk_cpus_allowed(p)))
+		goto out_unlock;
+
+	/* Is the task to migrate still there? */
+	if (task_cpu(p) != src_cpu)
+		goto out_unlock;
+
+	BUG_ON(src_rq == dst_rq);
+
+	/* Prepare to move the task from src_rq to dst_rq */
+	double_lock_balance(src_rq, dst_rq);
+
+	/*
+	 * Supposedly pi_lock should have been enough but some code
+	 * seems to call __set_task_cpu without pi_lock.
+	 */
+	if (task_cpu(p) != src_cpu) {
+		WARN_ONCE(1, "autonuma_balance_cpu_stop: "
+			  "not pi_lock protected");
+		goto out_double_unlock;
+	}
+
+	/*
+	 * If the task is not on a rq, the autonuma_node will take
+	 * care of the NUMA affinity at the next wake-up.
+	 */
+	if (p->on_rq) {
+		deactivate_task(src_rq, p, 0);
+		set_task_cpu(p, dst_cpu);
+		activate_task(dst_rq, p, 0);
+		check_preempt_curr(dst_rq, p, 0);
+	}
+
+out_double_unlock:
+	double_unlock_balance(src_rq, dst_rq);
+out_unlock:
+	src_rq->autonuma_balance = false;
+	raw_spin_unlock(&src_rq->lock);
+	/* spinlocks acts as barrier() so p is stored local on the stack */
+	raw_spin_unlock_irq(&p->pi_lock);
+	put_task_struct(p);
+	return 0;
+}
+
+#define AUTONUMA_BALANCE_SCALE 1000
+
+enum {
+	W_TYPE_THREAD,
+	W_TYPE_PROCESS,
+};
+
+/*
+ * This function sched_autonuma_balance() is responsible for deciding
+ * which is the best CPU each process should be running on according
+ * to the NUMA statistics collected in mm->mm_autonuma and
+ * tsk->task_autonuma.
+ *
+ * The core math that evaluates the current CPU against the CPUs of
+ * all _other_ nodes is this:
+ *
+ *	if (w_nid > w_other && w_nid > w_cpu_nid)
+ *		weight = w_nid - w_other + w_nid - w_cpu_nid;
+ *
+ * w_nid: NUMA affinity of the current thread/process if run on the
+ * other CPU.
+ *
+ * w_other: NUMA affinity of the other thread/process if run on the
+ * other CPU.
+ *
+ * w_cpu_nid: NUMA affinity of the current thread/process if run on
+ * the current CPU.
+ *
+ * weight: combined NUMA affinity benefit in moving the current
+ * thread/process to the other CPU taking into account both the higher
+ * NUMA affinity of the current process if run on the other CPU, and
+ * the increase in NUMA affinity in the other CPU by replacing the
+ * other process.
+ *
+ * We run the above math on every CPU not part of the current NUMA
+ * node, and we compare the current process against the other
+ * processes running in the other CPUs in the remote NUMA nodes. The
+ * objective is to select the cpu (in selected_cpu) with a bigger
+ * "weight". The bigger the "weight" the biggest gain we'll get by
+ * moving the current process to the selected_cpu (not only the
+ * biggest immediate CPU gain but also the fewer async memory
+ * migrations that will be required to reach full convergence
+ * later). If we select a cpu we migrate the current process to it.
+ *
+ * Checking that the current process has higher NUMA affinity than the
+ * other process on the other CPU (w_nid > w_other) and not only that
+ * the current process has higher NUMA affinity on the other CPU than
+ * on the current CPU (w_nid > w_cpu_nid) completely avoids ping pongs
+ * and ensures (temporary) convergence of the algorithm (at least from
+ * a CPU standpoint).
+ *
+ * It's then up to the idle balancing code that will run as soon as
+ * the current CPU goes idle to pick the other process and move it
+ * here (or in some other idle CPU if any).
+ *
+ * By only evaluating running processes against running processes we
+ * avoid interfering with the CFS stock active idle balancing, which
+ * is critical to optimal performance with HT enabled. (getting HT
+ * wrong is worse than running on remote memory so the active idle
+ * balancing has priority)
+ *
+ * Idle balancing and all other CFS load balancing become NUMA
+ * affinity aware through the introduction of
+ * sched_autonuma_can_migrate_task(). CFS searches CPUs in the task's
+ * autonuma_node first when it needs to find idle CPUs during idle
+ * balancing or tasks to pick during load balancing.
+ *
+ * The task's autonuma_node is the node selected by
+ * sched_autonuma_balance() when it migrates a task to the
+ * selected_cpu in the selected_nid.
+ *
+ * Once a process/thread has been moved to another node, closer to the
+ * much of memory it has recently accessed, any memory for that task
+ * not in the new node moves slowly (asynchronously in the background)
+ * to the new node. This is done by the knuma_migratedN (where the
+ * suffix N is the node id) daemon described in mm/autonuma.c.
+ *
+ * One non trivial bit of this logic that deserves an explanation is
+ * how the three crucial variables of the core math
+ * (w_nid/w_other/wcpu_nid) are going to change depending on whether
+ * the other CPU is running a thread of the current process, or a
+ * thread of a different process.
+ *
+ * A simple example is required. Given the following:
+ * - 2 processes
+ * - 4 threads per process
+ * - 2 NUMA nodes
+ * - 4 CPUS per NUMA node
+ *
+ * Because the 8 threads belong to 2 different processes, by using the
+ * process statistics when comparing threads of different processes,
+ * we will converge reliably and quickly to a configuration where the
+ * 1st process is entirely contained in one node and the 2nd process
+ * in the other node.
+ *
+ * If all threads only use thread local memory (no sharing of memory
+ * between the threads), it wouldn't matter if we use per-thread or
+ * per-mm statistics for w_nid/w_other/w_cpu_nid. We could then use
+ * per-thread statistics all the time.
+ *
+ * But clearly with threads it's expected to get some sharing of
+ * memory. To avoid false sharing it's better to keep all threads of
+ * the same process in the same node (or if they don't fit in a single
+ * node, in as fewer nodes as possible). This is why we have to use
+ * processes statistics in w_nid/w_other/wcpu_nid when comparing
+ * threads of different processes. Why instead do we have to use
+ * thread statistics when comparing threads of the same process? This
+ * should be obvious if you're still reading (hint: the mm statistics
+ * are identical for threads of the same process). If some process
+ * doesn't fit in one node, the thread statistics will then distribute
+ * the threads to the best nodes within the group of nodes where the
+ * process is contained.
+ *
+ * False sharing in the above sentence (and generally in AutoNUMA
+ * context) is intended as virtual memory accessed simultaneously (or
+ * frequently) by threads running in CPUs of different nodes. This
+ * doesn't refer to shared memory as in tmpfs, but it refers to
+ * CLONE_VM instead. If the threads access the same memory from CPUs
+ * of different nodes it means the memory accesses will be NUMA local
+ * for some thread and NUMA remote for some other thread. The only way
+ * to avoid NUMA false sharing is to schedule all threads accessing
+ * the same memory in the same node (which may or may not be possible,
+ * if it's not possible because there aren't enough CPUs in the node,
+ * the threads should be scheduled in as few nodes as possible and the
+ * nodes distance should be the lowest possible).
+ *
+ * This is an example of the CPU layout after the startup of 2
+ * processes with 12 threads each. This is some of the logs you will
+ * find in `dmesg` after running:
+ *
+ *	echo 1 >/sys/kernel/mm/autonuma/debug
+ *
+ * nid is the node id
+ * mm is the pointer to the mm structure (kind of the "ID" of the process)
+ * nr is the number of threads of that belongs to that process in that node id.
+ *
+ * This dumps the raw content of the CPUs' runqueues, it doesn't show
+ * kernel threads (the kernel thread dumping the below stats is
+ * clearly using one CPU, hence only 23 CPUs are dumped, clearly the
+ * debug mode can be improved but it's good enough to see what's going
+ * on).
+ *
+ * nid 0 mm ffff880433367b80 nr 6
+ * nid 0 mm ffff880433367480 nr 5
+ * nid 1 mm ffff880433367b80 nr 6
+ * nid 1 mm ffff880433367480 nr 6
+ *
+ * Now, the process with mm == ffff880433367b80 has 6 threads in node0
+ * and 6 threads in node1, while the process with mm ==
+ * ffff880433367480 has 5 threads in node0 and 6 threads running in
+ * node1.
+ *
+ * And after a few seconds it becomes:
+ *
+ * nid 0 mm ffff880433367b80 nr 12
+ * nid 1 mm ffff880433367480 nr 11
+ *
+ * Now, 12 threads of one process are running on node 0 and 11 threads
+ * of the other process are running on node 1.
+ *
+ * Before scanning all other CPUs' runqueues to compute the above
+ * math, we also verify that the current CPU is not already in the
+ * preferred NUMA node from the point of view of both the process
+ * statistics and the thread statistics. In such case we can return to
+ * the caller without having to check any other CPUs' runqueues
+ * because full convergence has been already reached.
+ *
+ * This algorithm might be expanded to take all runnable processes
+ * into account but examining just the currently running processes is
+ * a good enough approximation because some runnable processes may run
+ * only for a short time so statistically there will always be a bias
+ * on the processes that uses most the of the CPU. This is ideal
+ * because it doesn't matter if NUMA balancing isn't optimal for
+ * processes that run only for a short time.
+ *
+ * This function is invoked at the same frequency and in the same
+ * location of the CFS load balancer and only if the CPU is not
+ * idle. The rest of the time we depend on CFS to keep sticking to the
+ * current CPU or to prioritize on the CPUs in the selected_nid
+ * (recorded in the task's autonuma_node field).
+ */
+void sched_autonuma_balance(void)
+{
+	int cpu, nid, selected_cpu, selected_nid, selected_nid_mm;
+	int cpu_nid = numa_node_id();
+	int this_cpu = smp_processor_id();
+	/*
+	 * w_t: node thread weight
+	 * w_t_t: total sum of all node thread weights
+	 * w_m: node mm/process weight
+	 * w_m_t: total sum of all node mm/process weights
+	 */
+	unsigned long w_t, w_t_t, w_m, w_m_t;
+	unsigned long w_t_max, w_m_max;
+	unsigned long weight_max, weight;
+	long s_w_nid = -1, s_w_cpu_nid = -1, s_w_other = -1;
+	int s_w_type = -1;
+	struct cpumask *allowed;
+	struct task_struct *p = current;
+	struct task_autonuma *task_autonuma = p->task_autonuma;
+	struct rq *rq;
+
+	/* per-cpu statically allocated in runqueues */
+	long *task_numa_weight;
+	long *mm_numa_weight;
+
+	if (!task_autonuma || !p->mm)
+		return;
+
+	if (!autonuma_enabled()) {
+		if (task_autonuma->autonuma_node != -1)
+			task_autonuma->autonuma_node = -1;
+		return;
+	}
+
+	allowed = tsk_cpus_allowed(p);
+
+	/*
+	 * Do nothing if the task had no numa hinting page faults yet
+	 * or if the mm hasn't been fully scanned by knuma_scand yet.
+	 */
+	w_t_t = task_autonuma->task_numa_fault_tot;
+	if (!w_t_t)
+		return;
+	w_m_t = ACCESS_ONCE(p->mm->mm_autonuma->mm_numa_fault_tot);
+	if (!w_m_t)
+		return;
+
+	/*
+	 * The below two arrays holds the NUMA affinity information of
+	 * the current process if scheduled in the "nid". This is task
+	 * local and mm local information. We compute this information
+	 * for all nodes.
+	 *
+	 * task/mm_numa_weight[nid] will become w_nid.
+	 * task/mm_numa_weight[cpu_nid] will become w_cpu_nid.
+	 */
+	rq = cpu_rq(this_cpu);
+	task_numa_weight = rq->task_numa_weight;
+	mm_numa_weight = rq->mm_numa_weight;
+
+	w_t_max = w_m_max = 0;
+	selected_nid = selected_nid_mm = -1;
+	for_each_online_node(nid) {
+		w_m = ACCESS_ONCE(p->mm->mm_autonuma->mm_numa_fault[nid]);
+		w_t = task_autonuma->task_numa_fault[nid];
+		if (w_m > w_m_t)
+			w_m_t = w_m;
+		mm_numa_weight[nid] = w_m*AUTONUMA_BALANCE_SCALE/w_m_t;
+		if (w_t > w_t_t)
+			w_t_t = w_t;
+		task_numa_weight[nid] = w_t*AUTONUMA_BALANCE_SCALE/w_t_t;
+		if (mm_numa_weight[nid] > w_m_max) {
+			w_m_max = mm_numa_weight[nid];
+			selected_nid_mm = nid;
+		}
+		if (task_numa_weight[nid] > w_t_max) {
+			w_t_max = task_numa_weight[nid];
+			selected_nid = nid;
+		}
+	}
+	/*
+	 * See if we already converged to skip the more expensive loop
+	 * below. Return if we can already predict here with only
+	 * mm/task local information, that the below loop would
+	 * selected the current cpu_nid.
+	 */
+	if (selected_nid == cpu_nid && selected_nid_mm == selected_nid) {
+		if (task_autonuma->autonuma_node != selected_nid)
+			task_autonuma->autonuma_node = selected_nid;
+		return;
+	}
+
+	selected_cpu = this_cpu;
+	selected_nid = cpu_nid;
+
+	weight = weight_max = 0;
+
+	/* check that the following raw_spin_lock_irq is safe */
+	BUG_ON(irqs_disabled());
+
+	for_each_online_node(nid) {
+		/*
+		 * Calculate the "weight" for all CPUs that the
+		 * current process is allowed to be migrated to,
+		 * except the CPUs of the current nid (it would be
+		 * worthless from a NUMA affinity standpoint to
+		 * migrate the task to another CPU of the current
+		 * node).
+		 */
+		if (nid == cpu_nid)
+			continue;
+		for_each_cpu_and(cpu, cpumask_of_node(nid), allowed) {
+			long w_nid, w_cpu_nid, w_other;
+			int w_type;
+			struct mm_struct *mm;
+			rq = cpu_rq(cpu);
+			if (!cpu_online(cpu))
+				continue;
+
+			if (idle_cpu(cpu))
+				/*
+				 * Offload the while IDLE balancing
+				 * and physical / logical imbalances
+				 * to CFS.
+				 */
+				continue;
+
+			mm = rq->curr->mm;
+			if (!mm)
+				continue;
+			/*
+			 * Grab the w_m/w_t/w_m_t/w_t_t of the
+			 * processes running in the other CPUs to
+			 * compute w_other.
+			 */
+			raw_spin_lock_irq(&rq->lock);
+			/* recheck after implicit barrier() */
+			mm = rq->curr->mm;
+			if (!mm) {
+				raw_spin_unlock_irq(&rq->lock);
+				continue;
+			}
+			w_m_t = ACCESS_ONCE(mm->mm_autonuma->mm_numa_fault_tot);
+			w_t_t = rq->curr->task_autonuma->task_numa_fault_tot;
+			if (!w_m_t || !w_t_t) {
+				raw_spin_unlock_irq(&rq->lock);
+				continue;
+			}
+			w_m = ACCESS_ONCE(mm->mm_autonuma->mm_numa_fault[nid]);
+			w_t = rq->curr->task_autonuma->task_numa_fault[nid];
+			raw_spin_unlock_irq(&rq->lock);
+			/*
+			 * Generate the w_nid/w_cpu_nid from the
+			 * pre-computed mm/task_numa_weight[] and
+			 * compute w_other using the w_m/w_t info
+			 * collected from the other process.
+			 */
+			if (mm == p->mm) {
+				if (w_t > w_t_t)
+					w_t_t = w_t;
+				w_other = w_t*AUTONUMA_BALANCE_SCALE/w_t_t;
+				w_nid = task_numa_weight[nid];
+				w_cpu_nid = task_numa_weight[cpu_nid];
+				w_type = W_TYPE_THREAD;
+			} else {
+				if (w_m > w_m_t)
+					w_m_t = w_m;
+				w_other = w_m*AUTONUMA_BALANCE_SCALE/w_m_t;
+				w_nid = mm_numa_weight[nid];
+				w_cpu_nid = mm_numa_weight[cpu_nid];
+				w_type = W_TYPE_PROCESS;
+			}
+
+			/*
+			 * Finally check if there's a combined gain in
+			 * NUMA affinity. If there is and it's the
+			 * biggest weight seen so far, record its
+			 * weight and select this NUMA remote "cpu" as
+			 * candidate migration destination.
+			 */
+			if (w_nid > w_other && w_nid > w_cpu_nid) {
+				weight = w_nid - w_other + w_nid - w_cpu_nid;
+
+				if (weight > weight_max) {
+					weight_max = weight;
+					selected_cpu = cpu;
+					selected_nid = nid;
+
+					s_w_other = w_other;
+					s_w_nid = w_nid;
+					s_w_cpu_nid = w_cpu_nid;
+					s_w_type = w_type;
+				}
+			}
+		}
+	}
+
+	if (task_autonuma->autonuma_node != selected_nid)
+		task_autonuma->autonuma_node = selected_nid;
+	if (selected_cpu != this_cpu) {
+		if (autonuma_debug()) {
+			char *w_type_str = NULL;
+			switch (s_w_type) {
+			case W_TYPE_THREAD:
+				w_type_str = "thread";
+				break;
+			case W_TYPE_PROCESS:
+				w_type_str = "process";
+				break;
+			}
+			printk("%p %d - %dto%d - %dto%d - %ld %ld %ld - %s\n",
+			       p->mm, p->pid, cpu_nid, selected_nid,
+			       this_cpu, selected_cpu,
+			       s_w_other, s_w_nid, s_w_cpu_nid,
+			       w_type_str);
+		}
+		BUG_ON(cpu_nid == selected_nid);
+		goto found;
+	}
+
+	return;
+
+found:
+	rq = cpu_rq(this_cpu);
+
+	/*
+	 * autonuma_balance synchronizes accesses to
+	 * autonuma_balance_work. Once set, it's cleared by the
+	 * callback once the migration work is finished.
+	 */
+	raw_spin_lock_irq(&rq->lock);
+	if (rq->autonuma_balance) {
+		raw_spin_unlock_irq(&rq->lock);
+		return;
+	}
+	rq->autonuma_balance = true;
+	raw_spin_unlock_irq(&rq->lock);
+
+	rq->autonuma_balance_dst_cpu = selected_cpu;
+	rq->autonuma_balance_task = p;
+	get_task_struct(p);
+
+	stop_one_cpu_nowait(this_cpu,
+			    autonuma_balance_cpu_stop, rq,
+			    &rq->autonuma_balance_work);
+#ifdef __ia64__
+#error "NOTE: tlb_migrate_finish won't run here"
+#endif
+}
+
+/*
+ * The function sched_autonuma_can_migrate_task is called by CFS
+ * can_migrate_task() to prioritize on the task's autonuma_node. It is
+ * called during load_balancing, idle balancing and in general
+ * before any task CPU migration event happens.
+ *
+ * The caller first scans the CFS migration candidate tasks passing a
+ * not zero numa parameter, to skip tasks without AutoNUMA affinity
+ * (according to the tasks's autonuma_node). If no task can be
+ * migrated in the first scan, a second scan is run with a zero numa
+ * parameter.
+ *
+ * If load_balance_strict is enabled, AutoNUMA will only allow
+ * migration of tasks for idle balancing purposes (the idle balancing
+ * of CFS is never altered by AutoNUMA). In the not strict mode the
+ * load balancing is not altered and the AutoNUMA affinity is
+ * disregarded in favor of higher fairness. The load_balance_strict
+ * knob is runtime tunable in sysfs.
+ *
+ * If load_balance_strict is enabled, it tends to partition the
+ * system. In turn it may reduce the scheduler fairness across NUMA
+ * nodes, but it should deliver higher global performance.
+ */
+bool sched_autonuma_can_migrate_task(struct task_struct *p,
+				     int numa, int dst_cpu,
+				     enum cpu_idle_type idle)
+{
+	if (!task_autonuma_cpu(p, dst_cpu)) {
+		if (numa)
+			return false;
+		if (autonuma_sched_load_balance_strict() &&
+		    idle != CPU_NEWLY_IDLE && idle != CPU_IDLE)
+			return false;
+	}
+	return true;
+}
+
+/*
+ * sched_autonuma_dump_mm is a purely debugging function called at
+ * regular intervals when /sys/kernel/mm/autonuma/debug is
+ * enabled. This prints in the kernel logs how the threads and
+ * processes are distributed in all NUMA nodes to easily check if the
+ * threads of the same processes are converging in the same
+ * nodes. This won't take into account kernel threads and because it
+ * runs itself from a kernel thread it won't show what was running in
+ * the current CPU, but it's simple and good enough to get what we
+ * need in the debug logs. This function can be disabled or deleted
+ * later.
+ */
+void sched_autonuma_dump_mm(void)
+{
+	int nid, cpu;
+	cpumask_var_t x;
+
+	if (!alloc_cpumask_var(&x, GFP_KERNEL))
+		return;
+	cpumask_setall(x);
+	for_each_online_node(nid) {
+		for_each_cpu(cpu, cpumask_of_node(nid)) {
+			struct rq *rq = cpu_rq(cpu);
+			struct mm_struct *mm = rq->curr->mm;
+			int nr = 0, cpux;
+			if (!cpumask_test_cpu(cpu, x))
+				continue;
+			for_each_cpu(cpux, cpumask_of_node(nid)) {
+				struct rq *rqx = cpu_rq(cpux);
+				if (rqx->curr->mm == mm) {
+					nr++;
+					cpumask_clear_cpu(cpux, x);
+				}
+			}
+			printk("nid %d mm %p nr %d\n", nid, mm, nr);
+		}
+	}
+	free_cpumask_var(x);
+}
diff --git a/kernel/sched/sched.h b/kernel/sched/sched.h
index 6d52cea..e5b7ae9 100644
--- a/kernel/sched/sched.h
+++ b/kernel/sched/sched.h
@@ -463,6 +463,24 @@ struct rq {
 #ifdef CONFIG_SMP
 	struct llist_head wake_list;
 #endif
+#ifdef CONFIG_AUTONUMA
+	/*
+	 * Per-cpu arrays to compute the per-thread and per-process
+	 * statistics. Allocated statically to avoid overflowing the
+	 * stack with large MAX_NUMNODES values.
+	 *
+	 * FIXME: allocate dynamically and with num_possible_nodes()
+	 * array sizes only if autonuma is not impossible, to save
+	 * some dozen KB of RAM when booting on not NUMA (or small
+	 * NUMA) systems.
+	 */
+	long task_numa_weight[MAX_NUMNODES];
+	long mm_numa_weight[MAX_NUMNODES];
+	bool autonuma_balance;
+	int autonuma_balance_dst_cpu;
+	struct task_struct *autonuma_balance_task;
+	struct cpu_stop_work autonuma_balance_work;
+#endif
 };
 
 static inline int cpu_of(struct rq *rq)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
