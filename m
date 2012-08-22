Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 0C3726B006C
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 11:00:11 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 10/36] autonuma: CPU follows memory algorithm
Date: Wed, 22 Aug 2012 16:58:54 +0200
Message-Id: <1345647560-30387-11-git-send-email-aarcange@redhat.com>
In-Reply-To: <1345647560-30387-1-git-send-email-aarcange@redhat.com>
References: <1345647560-30387-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

This algorithm takes as input the statistical information filled by the
knuma_scand (mm->mm_autonuma) and by the NUMA hinting page faults
(p->task_autonuma), evaluates it for the current scheduled task, and
compares it against every other running process to see if it should
move the current task to another NUMA node.

When the scheduler decides if the task should be migrated to a
different NUMA node or to stay in the same NUMA node, the decision is
then stored into p->task_autonuma->task_selected_nid. The fair
scheduler then tries to keep the task on the task_selected_nid.

Code include fixes and cleanups from Hillf Danton <dhillf@gmail.com>.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/autonuma_sched.h |   50 ++++
 include/linux/mm_types.h       |    5 +
 include/linux/sched.h          |    3 +
 kernel/sched/core.c            |    1 +
 kernel/sched/fair.c            |    4 +
 kernel/sched/numa.c            |  604 ++++++++++++++++++++++++++++++++++++++++
 kernel/sched/sched.h           |   19 ++
 7 files changed, 686 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/autonuma_sched.h
 create mode 100644 kernel/sched/numa.c

diff --git a/include/linux/autonuma_sched.h b/include/linux/autonuma_sched.h
new file mode 100644
index 0000000..588bba5
--- /dev/null
+++ b/include/linux/autonuma_sched.h
@@ -0,0 +1,50 @@
+#ifndef _LINUX_AUTONUMA_SCHED_H
+#define _LINUX_AUTONUMA_SCHED_H
+
+#ifdef CONFIG_AUTONUMA
+#include <linux/autonuma_flags.h>
+
+extern void __sched_autonuma_balance(void);
+extern bool sched_autonuma_can_migrate_task(struct task_struct *p,
+					    int numa, int dst_cpu,
+					    enum cpu_idle_type idle);
+
+static bool inline task_autonuma_cpu(struct task_struct *p, int cpu)
+{
+	int task_selected_nid;
+	struct task_autonuma *task_autonuma = p->task_autonuma;
+
+	if (!task_autonuma)
+		return true;
+
+	task_selected_nid = ACCESS_ONCE(task_autonuma->task_selected_nid);
+	if (task_selected_nid < 0 || task_selected_nid == cpu_to_node(cpu))
+		return true;
+	else
+		return false;
+}
+
+static inline void sched_autonuma_balance(void)
+{
+	struct task_autonuma *ta = current->task_autonuma;
+
+	if (ta && current->mm)
+		__sched_autonuma_balance();
+}
+#else /* CONFIG_AUTONUMA */
+static inline bool sched_autonuma_can_migrate_task(struct task_struct *p,
+						   int numa, int dst_cpu,
+						   enum cpu_idle_type idle)
+{
+	return true;
+}
+
+static bool inline task_autonuma_cpu(struct task_struct *p, int cpu)
+{
+	return true;
+}
+
+static inline void sched_autonuma_balance(void) {}
+#endif /* CONFIG_AUTONUMA */
+
+#endif /* _LINUX_AUTONUMA_SCHED_H */
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index bf78672..c80101c 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -13,6 +13,7 @@
 #include <linux/cpumask.h>
 #include <linux/page-debug-flags.h>
 #include <linux/uprobes.h>
+#include <linux/autonuma_types.h>
 #include <asm/page.h>
 #include <asm/mmu.h>
 
@@ -405,6 +406,10 @@ struct mm_struct {
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
index b8c8664..8b91676 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1523,6 +1523,9 @@ struct task_struct {
 	struct mempolicy *mempolicy;	/* Protected by alloc_lock */
 	short il_next;
 	short pref_node_fork;
+#ifdef CONFIG_AUTONUMA
+	struct task_autonuma *task_autonuma;
+#endif
 #endif
 	struct rcu_head rcu;
 
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index fbf1fd0..d0af967 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -72,6 +72,7 @@
 #include <linux/slab.h>
 #include <linux/init_task.h>
 #include <linux/binfmts.h>
+#include <linux/autonuma_sched.h>
 
 #include <asm/switch_to.h>
 #include <asm/tlb.h>
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index c219bf8..42a88fa 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -26,6 +26,7 @@
 #include <linux/slab.h>
 #include <linux/profile.h>
 #include <linux/interrupt.h>
+#include <linux/autonuma_sched.h>
 
 #include <trace/events/sched.h>
 
@@ -4920,6 +4921,9 @@ static void run_rebalance_domains(struct softirq_action *h)
 
 	rebalance_domains(this_cpu, idle);
 
+	if (!this_rq->idle_balance)
+		sched_autonuma_balance();
+
 	/*
 	 * If this cpu has a pending nohz_balance_kick, then do the
 	 * balancing on behalf of the other idle cpus whose ticks are
diff --git a/kernel/sched/numa.c b/kernel/sched/numa.c
new file mode 100644
index 0000000..2646c82
--- /dev/null
+++ b/kernel/sched/numa.c
@@ -0,0 +1,604 @@
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
+ * Callback used by the AutoNUMA balancer to migrate a task to the
+ * selected CPU. Invoked by stop_one_cpu_nowait().
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
+	if (task_cpu(p) != src_cpu)
+		goto out_double_unlock;
+
+	/*
+	 * If the task is not on a rq, the task_selected_nid will take
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
+	/* spinlocks acts as barrier() so p is stored locally on the stack */
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
+ * This function __sched_autonuma_balance() is responsible for
+ * deciding which is the best CPU each process should be running on
+ * according to the NUMA statistics collected in mm->mm_autonuma and
+ * tsk->task_autonuma.
+ *
+ * This will not alter the active idle load balancing and most other
+ * scheduling activity, it works by exchanging running tasks across
+ * CPUs located in different NUMA nodes, when such an exchange
+ * provides a net benefit in increasing the system wide NUMA
+ * convergence.
+ *
+ * The tasks that are the closest to "fully converged" are given the
+ * maximum priority in being moved to their "best node".
+ *
+ * "Full convergence" is achieved when all memory accesses by a task
+ * are 100% local to the CPU it is running on. A task's "best node" is
+ * the NUMA node that recently had the most memory accesses from the
+ * task. The tasks that are closest to being fully converged are given
+ * maximum priority for being moved to their "best node."
+ *
+ * To find how close a task is to converging we use weights. These
+ * weights are computed using the task_autonuma and mm_autonuma
+ * statistics. These weights represent the percentage amounts of
+ * memory accesses (in AUTONUMA_BALANCE_SCALE) that each task recently
+ * had in each node. If the weight of one node is equal to
+ * AUTONUMA_BALANCE_SCALE that implies the task reached "full
+ * convergence" in that given node. To the contrary, a node with a
+ * zero weight would be the "worst node" for the task.
+ *
+ * If the weights for two tasks on CPUs in different nodes are equal
+ * no switch will happen.
+ *
+ * The core math that evaluates the current CPU against the CPUs of
+ * all other nodes is this:
+ *
+ *	if (w_nid > w_other && w_nid > w_this_nid)
+ *		weight = w_nid - w_other + w_nid - w_this_nid;
+ *
+ * w_nid is the memory weight of this task on the other CPU.
+ * w_other is the memory weight of the other task in the other CPU.
+ * w_this_nid is the memory weight of this task on the current CPU.
+ *
+ * w_nid > w_other means: the current task is closer to fully converge
+ * on the node of the other CPU than the other task that is currently
+ * running in the other CPU.
+ *
+ * w_nid > w_this_nid means: the current task is closer to converge on
+ * the node of the other CPU than in the current node.
+ *
+ * If both checks succeed it guarantees that we found a way to
+ * multilaterally improve the system wide NUMA
+ * convergence. Multilateral here means that the same checks will not
+ * succeed again on those same two tasks, after the task exchange, so
+ * there is no risk of ping-pong.
+ *
+ * If a task exchange can happen because the two checks succeed, we
+ * select the destination CPU that will give us the biggest increase
+ * in system wide convergence (i.e. biggest "weight", in the above
+ * quoted code).
+ *
+ * CFS is NUMA aware via sched_autonuma_can migrate_task(). CFS searches
+ * CPUs in the task's task_selected_nid first during load balancing and
+ * idle balancing.
+ *
+ * The task's task_selected_nid is the node selected by
+ * __sched_autonuma_balance() when it migrates the current task to the
+ * selected cpu in the selected node during the task exchange.
+ *
+ * Once a task has been moved to another node, closer to most of the
+ * memory it has recently accessed, any memory for that task not in
+ * the new node moves slowly (asynchronously in the background) to the
+ * new node. This is done by the knuma_migratedN (where the suffix N
+ * is the node id) daemon described in mm/autonuma.c.
+ *
+ * One important thing is how we calculate the weights using
+ * task_autonuma or mm_autonuma, depending if the other CPU is running
+ * a thread of the current process, or a thread of a different
+ * process.
+ *
+ * We use the mm_autonuma statistics to calculate the NUMA weights of
+ * the two task candidates for exchange if the task in the other CPU
+ * belongs to a different process. This way all threads of the same
+ * process will converge to the same node, which is the one with the
+ * highest percentage of memory for the process.  This will happen
+ * even if the thread's "best node" is busy running threads of a
+ * different process.
+ *
+ * If the two candidate tasks for exchange are threads of the same
+ * process, we use the task_autonuma information (because the
+ * mm_autonuma information is identical). By using the task_autonuma
+ * statistics, each thread follows its own memory locality and they
+ * will not necessarily converge on the same node. This is often very
+ * desirable for processes with more theads than CPUs on each NUMA
+ * node.
+ *
+ * To avoid the risk of NUMA false sharing it's best to schedule all
+ * threads accessing the same memory in the same node (on in as fewer
+ * nodes as possible if they can't fit in a single node).
+ *
+ * False sharing in the above sentence is intended as simultaneous
+ * virtual memory accesses to the same pages of memory, by threads
+ * running in CPUs of different nodes. Sharing doesn't refer to shared
+ * memory as in tmpfs, but it refers to CLONE_VM instead.
+ *
+ * This algorithm might be expanded to take all runnable processes
+ * into account later.
+ *
+ * This algorithm is executed by every CPU in the context of the
+ * SCHED_SOFTIRQ load balancing event at regular intervals.
+ *
+ * If the task is found to have converged in the current node, we
+ * already know that the check "w_nid > w_this_nid" will not succeed,
+ * so the function returns without having to check any of the CPUs of
+ * the other NUMA nodes.
+ */
+void __sched_autonuma_balance(void)
+{
+	int cpu, nid, selected_cpu, selected_nid, selected_nid_mm;
+	int this_nid = numa_node_id();
+	int this_cpu = smp_processor_id();
+	/*
+	 * task_weight: node thread weight
+	 * task_tot: total sum of all node thread weights
+	 * mm_weight: node mm/process weight
+	 * mm_tot: total sum of all node mm/process weights
+	 */
+	unsigned long task_weight, task_tot, mm_weight, mm_tot;
+	unsigned long task_max, mm_max;
+	unsigned long weight_max, weight;
+	long s_w_nid = -1, s_w_this_nid = -1, s_w_other = -1;
+	int s_w_type = -1;
+	struct cpumask *allowed;
+	struct task_struct *p = current, *selected_task;
+	struct task_autonuma *task_autonuma = p->task_autonuma;
+	struct mm_autonuma *mm_autonuma;
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
+		if (task_autonuma->task_selected_nid != -1)
+			task_autonuma->task_selected_nid = -1;
+		return;
+	}
+
+	allowed = tsk_cpus_allowed(p);
+	mm_autonuma = p->mm->mm_autonuma;
+
+	/*
+	 * If the task has no NUMA hinting page faults or if the mm
+	 * hasn't been fully scanned by knuma_scand yet, set task
+	 * selected nid to the current nid, to avoid the task bounce
+	 * around randomly.
+	 */
+	mm_tot = ACCESS_ONCE(mm_autonuma->mm_numa_fault_tot);
+	if (!mm_tot) {
+		if (task_autonuma->task_selected_nid != this_nid)
+			task_autonuma->task_selected_nid = this_nid;
+		return;
+	}
+	task_tot = task_autonuma->task_numa_fault_tot;
+	if (!task_tot) {
+		if (task_autonuma->task_selected_nid != this_nid)
+			task_autonuma->task_selected_nid = this_nid;
+		return;
+	}
+
+	rq = cpu_rq(this_cpu);
+
+	/*
+	 * Verify that we can migrate the current task, otherwise try
+	 * again later.
+	 */
+	if (ACCESS_ONCE(rq->autonuma_balance))
+		return;
+
+	/*
+	 * The following two arrays will hold the NUMA affinity weight
+	 * information for the current process if scheduled on the
+	 * given NUMA node.
+	 *
+	 * mm_numa_weight[nid] - mm NUMA affinity weight for the NUMA node
+	 * task_numa_weight[nid] - task NUMA affinity weight for the NUMA node
+	 */
+	task_numa_weight = rq->task_numa_weight;
+	mm_numa_weight = rq->mm_numa_weight;
+
+	/*
+	 * Identify the NUMA node where this thread (task_struct), and
+	 * the process (mm_struct) as a whole, has the largest number
+	 * of NUMA faults.
+	 */
+	task_max = mm_max = 0;
+	selected_nid = selected_nid_mm = -1;
+	for_each_online_node(nid) {
+		mm_weight = ACCESS_ONCE(mm_autonuma->mm_numa_fault[nid]);
+		task_weight = task_autonuma->task_numa_fault[nid];
+		if (mm_weight > mm_tot)
+			/* could be removed with a seqlock */
+			mm_tot = mm_weight;
+		mm_numa_weight[nid] = mm_weight*AUTONUMA_BALANCE_SCALE/mm_tot;
+		if (task_weight > task_tot) {
+			task_tot = task_weight;
+			WARN_ON(1);
+		}
+		task_numa_weight[nid] = task_weight*AUTONUMA_BALANCE_SCALE/task_tot;
+		if (mm_numa_weight[nid] > mm_max) {
+			mm_max = mm_numa_weight[nid];
+			selected_nid_mm = nid;
+		}
+		if (task_numa_weight[nid] > task_max) {
+			task_max = task_numa_weight[nid];
+			selected_nid = nid;
+		}
+	}
+	/*
+	 * If this NUMA node is the selected one, based on process
+	 * memory and task NUMA faults, set task_selected_nid and
+	 * we're done.
+	 */
+	if (selected_nid == this_nid && selected_nid_mm == selected_nid) {
+		if (task_autonuma->task_selected_nid != selected_nid)
+			task_autonuma->task_selected_nid = selected_nid;
+		return;
+	}
+
+	selected_cpu = this_cpu;
+	selected_nid = this_nid;
+
+	weight = weight_max = 0;
+
+	selected_task = NULL;
+
+	/* check that the following raw_spin_lock_irq is safe */
+	BUG_ON(irqs_disabled());
+
+	/*
+	 * Check the other NUMA nodes to see if there is a task we
+	 * should exchange places with.
+	 */
+	for_each_online_node(nid) {
+		/* No need to check our current node. */
+		if (nid == this_nid)
+			continue;
+		for_each_cpu_and(cpu, cpumask_of_node(nid), allowed) {
+			long w_nid, w_this_nid, w_other;
+			int w_type;
+			struct mm_struct *mm;
+			struct task_struct *_selected_task;
+			rq = cpu_rq(cpu);
+			if (!cpu_online(cpu))
+				continue;
+
+			/* CFS takes care of idle balancing. */
+			if (idle_cpu(cpu))
+				continue;
+
+			mm = rq->curr->mm;
+			if (!mm)
+				continue;
+
+			/*
+			 * Check if the _selected_task is pending for
+			 * migrate. Do it locklessly: it's an
+			 * optimistic racy check anyway.
+			 */
+			if (ACCESS_ONCE(rq->autonuma_balance))
+				continue;
+
+			/*
+			 * Grab the mm_weight/task_weight/mm_tot/task_tot of the
+			 * processes running in the other CPUs to
+			 * compute w_other.
+			 */
+			raw_spin_lock_irq(&rq->lock);
+			_selected_task = rq->curr;
+			/* recheck after implicit barrier() */
+			mm = _selected_task->mm;
+			if (!mm) {
+				raw_spin_unlock_irq(&rq->lock);
+				continue;
+			}
+			mm_tot = ACCESS_ONCE(mm->mm_autonuma->mm_numa_fault_tot);
+			task_tot = _selected_task->task_autonuma->task_numa_fault_tot;
+			if (!mm_tot || !task_tot) {
+				/* Need NUMA faults to evaluate NUMA placement. */
+				raw_spin_unlock_irq(&rq->lock);
+				continue;
+			}
+			/*
+			 * Check if that the _selected_task is allowed
+			 * to be migrated to this_cpu.
+			 */
+			if (!cpumask_test_cpu(this_cpu,
+					      tsk_cpus_allowed(_selected_task))) {
+				raw_spin_unlock_irq(&rq->lock);
+				continue;
+			}
+			mm_weight = ACCESS_ONCE(mm->mm_autonuma->mm_numa_fault[nid]);
+			task_weight = _selected_task->task_autonuma->task_numa_fault[nid];
+			raw_spin_unlock_irq(&rq->lock);
+
+			if (mm == p->mm) {
+				/*
+				 * This task is another thread in the
+				 * same process. Use the task statistics.
+				 */
+				if (task_weight > task_tot)
+					task_tot = task_weight;
+				w_other = task_weight*AUTONUMA_BALANCE_SCALE/task_tot;
+				w_nid = task_numa_weight[nid];
+				w_this_nid = task_numa_weight[this_nid];
+				w_type = W_TYPE_THREAD;
+			} else {
+				/*
+				 * This task is part of another process.
+				 * Use the mm statistics.
+				 */
+				if (mm_weight > mm_tot)
+					mm_tot = mm_weight;
+				w_other = mm_weight*AUTONUMA_BALANCE_SCALE/mm_tot;
+				w_nid = mm_numa_weight[nid];
+				w_this_nid = mm_numa_weight[this_nid];
+				w_type = W_TYPE_PROCESS;
+			}
+
+			/*
+			 * Would swapping NUMA location with this task
+			 * reduce the total number of cross-node NUMA
+			 * faults in the system?
+			 */
+			if (w_nid > w_other && w_nid > w_this_nid) {
+				weight = w_nid - w_other + w_nid - w_this_nid;
+
+				/* Remember the best candidate. */
+				if (weight > weight_max) {
+					weight_max = weight;
+					selected_cpu = cpu;
+					selected_nid = nid;
+
+					s_w_other = w_other;
+					s_w_nid = w_nid;
+					s_w_this_nid = w_this_nid;
+					s_w_type = w_type;
+					selected_task = _selected_task;
+				}
+			}
+		}
+	}
+
+	if (task_autonuma->task_selected_nid != selected_nid)
+		task_autonuma->task_selected_nid = selected_nid;
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
+			       p->mm, p->pid, this_nid, selected_nid,
+			       this_cpu, selected_cpu,
+			       s_w_other, s_w_nid, s_w_this_nid,
+			       w_type_str);
+		}
+		BUG_ON(this_nid == selected_nid);
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
+	 * autonuma_balance_work. After set, it's cleared by the
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
+	/* Do the actual migration. */
+	stop_one_cpu_nowait(this_cpu,
+			    autonuma_balance_cpu_stop, rq,
+			    &rq->autonuma_balance_work);
+
+	BUG_ON(!selected_task);
+	rq = cpu_rq(selected_cpu);
+
+	/*
+	 * autonuma_balance synchronizes accesses to
+	 * autonuma_balance_work. After set, it's cleared by the
+	 * callback once the migration work is finished.
+	 */
+	raw_spin_lock_irq(&rq->lock);
+	/*
+	 * The chance of selected_task having quit in the meanwhile
+	 * and another task having reused its previous task struct is
+	 * tiny. Even if it happens the kernel will be stable.
+	 */
+	if (rq->autonuma_balance || rq->curr != selected_task) {
+		raw_spin_unlock_irq(&rq->lock);
+		return;
+	}
+	rq->autonuma_balance = true;
+	/* take the pin on the task struct before dropping the lock */
+	get_task_struct(selected_task);
+	raw_spin_unlock_irq(&rq->lock);
+
+	rq->autonuma_balance_dst_cpu = this_cpu;
+	rq->autonuma_balance_task = selected_task;
+
+	/* Do the actual migration. */
+	stop_one_cpu_nowait(selected_cpu,
+			    autonuma_balance_cpu_stop, rq,
+			    &rq->autonuma_balance_work);
+#ifdef __ia64__
+#error "NOTE: tlb_migrate_finish won't run here, review before deleting"
+#endif
+}
+
+/*
+ * The function sched_autonuma_can_migrate_task is called by CFS
+ * can_migrate_task() to prioritize on the task's
+ * task_selected_nid. It is called during load_balancing, idle
+ * balancing and in general before any task CPU migration event
+ * happens.
+ *
+ * The caller first scans the CFS migration candidate tasks passing a
+ * not zero numa parameter, to skip tasks without AutoNUMA affinity
+ * (according to the tasks's task_selected_nid). If no task can be
+ * migrated in the first scan, a second scan is run with a zero numa
+ * parameter.
+ *
+ * If the numa parameter is not zero, this function allows the task
+ * migration only if the dst_cpu of the migration is in the node
+ * selected by AutoNUMA or if it's an idle load balancing event.
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
+			printk("nid %d process %p nr_threads %d\n", nid, mm, nr);
+		}
+	}
+	free_cpumask_var(x);
+}
diff --git a/kernel/sched/sched.h b/kernel/sched/sched.h
index f6714d0..458b711 100644
--- a/kernel/sched/sched.h
+++ b/kernel/sched/sched.h
@@ -467,6 +467,25 @@ struct rq {
 #ifdef CONFIG_SMP
 	struct llist_head wake_list;
 #endif
+#ifdef CONFIG_AUTONUMA
+	/* stop_one_cpu_nowait() data used by autonuma_balance_cpu_stop() */
+	bool autonuma_balance;
+	int autonuma_balance_dst_cpu;
+	struct task_struct *autonuma_balance_task;
+	struct cpu_stop_work autonuma_balance_work;
+	/*
+	 * Per-cpu arrays used to compute the per-thread and
+	 * per-process NUMA affinity weights (per nid) for the current
+	 * process. Allocated statically to avoid overflowing the
+	 * stack with large MAX_NUMNODES values.
+	 *
+	 * FIXME: allocate with dynamic num_possible_nodes() array
+	 * sizes and only if autonuma is possible, to save some dozen
+	 * KB of RAM when booting on non NUMA (or small NUMA) systems.
+	 */
+	long task_numa_weight[MAX_NUMNODES];
+	long mm_numa_weight[MAX_NUMNODES];
+#endif
 };
 
 static inline int cpu_of(struct rq *rq)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
