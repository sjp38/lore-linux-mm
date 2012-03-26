Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 0F9B86B00EA
	for <linux-mm@kvack.org>; Mon, 26 Mar 2012 14:18:47 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 11/39] autonuma: CPU follow memory algorithm
Date: Mon, 26 Mar 2012 19:45:58 +0200
Message-Id: <1332783986-24195-12-git-send-email-aarcange@redhat.com>
In-Reply-To: <1332783986-24195-1-git-send-email-aarcange@redhat.com>
References: <1332783986-24195-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>

This algorithm takes as input the statistical information filled by the
knuma_scand (mm->mm_autonuma) and by the NUMA hinting page faults
(p->sched_autonuma), evaluates it for the current scheduled task, and
compares it against every other running process to see if it should
move the current task to another NUMA node.

For example if there's any idle CPU in the NUMA node where the current
task prefers to be scheduled into (according to the mm_autonuma and
sched_autonuma data structures) the task will be migrated there
instead of keep running in the current CPU.

When the scheduler decides if the task should be migrated to a
different NUMA node or to stay in the same NUMA node, the decision is
then stored into p->sched_autonuma->autonuma_node. The fair scheduler
than tries to keep the task on the autonuma_node too.

Code include fixes from Hillf Danton <dhillf@gmail.com>.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/autonuma_sched.h |   61 +++++++++
 include/linux/mm_types.h       |    5 +
 include/linux/sched.h          |    3 +
 kernel/sched/core.c            |   12 +-
 kernel/sched/numa.c            |  276 ++++++++++++++++++++++++++++++++++++++++
 kernel/sched/sched.h           |   12 ++
 6 files changed, 361 insertions(+), 8 deletions(-)
 create mode 100644 include/linux/autonuma_sched.h
 create mode 100644 kernel/sched/numa.c

diff --git a/include/linux/autonuma_sched.h b/include/linux/autonuma_sched.h
new file mode 100644
index 0000000..286308f
--- /dev/null
+++ b/include/linux/autonuma_sched.h
@@ -0,0 +1,61 @@
+#ifndef _LINUX_AUTONUMA_SCHED_H
+#define _LINUX_AUTONUMA_SCHED_H
+
+#include <linux/autonuma_flags.h>
+
+static bool inline task_autonuma_cpu(struct task_struct *p, int cpu)
+{
+#ifdef CONFIG_AUTONUMA
+	int autonuma_node;
+	struct sched_autonuma *sched_autonuma = p->sched_autonuma;
+
+	if (!sched_autonuma)
+		return true;
+
+	autonuma_node = ACCESS_ONCE(sched_autonuma->autonuma_node);
+	if (autonuma_node < 0 || autonuma_node == cpu_to_node(cpu))
+		return true;
+	else
+		return false;
+#else
+	return true;
+#endif
+}
+
+static bool inline task_autonuma(void)
+{
+#ifdef CONFIG_AUTONUMA
+	struct task_struct *p = current;
+	struct sched_autonuma *sched_autonuma = p->sched_autonuma;
+	int autonuma_node;
+
+	if (!sched_autonuma)
+		return true;
+
+	autonuma_node = ACCESS_ONCE(sched_autonuma->autonuma_node);
+	if (autonuma_node < 0 || autonuma_node == numa_node_id())
+		return true;
+	else
+		return false;
+#else
+	return true;
+#endif
+}
+
+#ifdef CONFIG_AUTONUMA
+extern void sched_autonuma_balance(void);
+extern bool sched_autonuma_can_migrate_task(struct task_struct *p,
+					    int numa, int dst_cpu,
+					    enum cpu_idle_type idle,
+					    struct cpumask *allowed);
+#else /* CONFIG_AUTONUMA */
+static inline void sched_autonuma_balance(void) {}
+static inline bool sched_autonuma_can_migrate_task(struct task_struct *p,
+						   int numa, int dst_cpu,
+						   enum cpu_idle_type idle,
+						   struct cpumask *allowed) {
+	return true;
+}
+#endif /* CONFIG_AUTONUMA */
+
+#endif /* _LINUX_AUTONUMA_SCHED_H */
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 3cc3062..2567798 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -12,6 +12,7 @@
 #include <linux/completion.h>
 #include <linux/cpumask.h>
 #include <linux/page-debug-flags.h>
+#include <linux/autonuma_types.h>
 #include <asm/page.h>
 #include <asm/mmu.h>
 
@@ -388,6 +389,10 @@ struct mm_struct {
 #ifdef CONFIG_CPUMASK_OFFSTACK
 	struct cpumask cpumask_allocation;
 #endif
+#ifdef CONFIG_AUTONUMA
+	/* this is used by the scheduler and the page allocator */
+	struct mm_autonuma *mm_autonuma;
+#endif
 };
 
 static inline void mm_init_cpumask(struct mm_struct *mm)
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 0c3854b..d0f2182 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1553,6 +1553,9 @@ struct task_struct {
 	struct mempolicy *mempolicy;	/* Protected by alloc_lock */
 	short il_next;
 	short pref_node_fork;
+#ifdef CONFIG_AUTONUMA
+	struct sched_autonuma *sched_autonuma;
+#endif
 #endif
 	struct rcu_head rcu;
 
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 503d642..501b87f 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -72,6 +72,7 @@
 #include <linux/slab.h>
 #include <linux/init_task.h>
 #include <linux/binfmts.h>
+#include <linux/autonuma_sched.h>
 
 #include <asm/tlb.h>
 #include <asm/irq_regs.h>
@@ -1117,13 +1118,6 @@ void set_task_cpu(struct task_struct *p, unsigned int new_cpu)
 	__set_task_cpu(p, new_cpu);
 }
 
-struct migration_arg {
-	struct task_struct *task;
-	int dest_cpu;
-};
-
-static int migration_cpu_stop(void *data);
-
 /*
  * wait_task_inactive - wait for a thread to unschedule.
  *
@@ -3220,6 +3214,8 @@ need_resched:
 
 	post_schedule(rq);
 
+	sched_autonuma_balance();
+
 	sched_preempt_enable_no_resched();
 	if (need_resched())
 		goto need_resched;
@@ -5055,7 +5051,7 @@ fail:
  * and performs thread migration by bumping thread off CPU then
  * 'pushing' onto another runqueue.
  */
-static int migration_cpu_stop(void *data)
+int migration_cpu_stop(void *data)
 {
 	struct migration_arg *arg = data;
 
diff --git a/kernel/sched/numa.c b/kernel/sched/numa.c
new file mode 100644
index 0000000..d51e1ec
--- /dev/null
+++ b/kernel/sched/numa.c
@@ -0,0 +1,276 @@
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
+#define AUTONUMA_BALANCE_SCALE 1000
+
+/*
+ * This function is responsible for deciding which is the best CPU
+ * each process should be running on according to the NUMA
+ * affinity. To do that it evaluates all CPUs and checks if there's
+ * any remote CPU where the current process has more NUMA affinity
+ * than with the current CPU, and where the process running on the
+ * remote CPU has less NUMA affinity than the current process to run
+ * on the remote CPU. Ideally this should be expanded to take all
+ * runnable processes into account but this is a good
+ * approximation. When we compare the NUMA affinity between the
+ * current and remote CPU we use the per-thread information if the
+ * remote CPU runs a thread of the same process that the current task
+ * belongs to, or the per-process information if the remote CPU runs a
+ * different process than the current one. If the remote CPU runs the
+ * idle task we require both the per-thread and per-process
+ * information to have more affinity with the remote CPU than with the
+ * current CPU for a migration to happen.
+ *
+ * This has O(N) complexity but N isn't the number of running
+ * processes, but the number of CPUs, so if you assume a constant
+ * number of CPUs (capped at NR_CPUS) it is O(1). O(1) misleading math
+ * aside, the number of cachelines touched with thousands of CPU might
+ * make it measurable. Calling this at every schedule may also be
+ * overkill and it may be enough to call it with a frequency similar
+ * to the load balancing, but by doing so we're also verifying the
+ * algorithm is a converging one in all workloads if performance is
+ * improved and there's no frequent CPU migration, so it's good in the
+ * short term for stressing the algorithm.
+ */
+void sched_autonuma_balance(void)
+{
+	int cpu, nid, selected_cpu, selected_nid;
+	int cpu_nid = numa_node_id();
+	int this_cpu = smp_processor_id();
+	unsigned long p_w, p_t, m_w, m_t;
+	unsigned long weight_delta_max, weight;
+	struct cpumask *allowed;
+	struct migration_arg arg;
+	struct task_struct *p = current;
+	struct sched_autonuma *sched_autonuma = p->sched_autonuma;
+
+	/* per-cpu statically allocated in runqueues */
+	long *weight_others;
+	long *weight_current;
+	long *weight_current_mm;
+	unsigned long *mm_mask;
+
+	if (!sched_autonuma || sched_autonuma->autonuma_stop_one_cpu || !p->mm)
+		return;
+
+	if (!autonuma_enabled()) {
+		if (sched_autonuma->autonuma_node != -1)
+			sched_autonuma->autonuma_node = -1;
+		return;
+	}
+
+	allowed = tsk_cpus_allowed(p);
+
+	m_t = ACCESS_ONCE(p->mm->mm_autonuma->numa_fault_tot);
+	p_t = sched_autonuma->numa_fault_tot;
+	/*
+	 * If a process still misses the per-thread or per-process
+	 * information skip it.
+	 */
+	if (!m_t || !p_t)
+		return;
+
+	weight_others = cpu_rq(this_cpu)->weight_others;
+	weight_current = cpu_rq(this_cpu)->weight_current;
+	weight_current_mm = cpu_rq(this_cpu)->weight_current_mm;
+	mm_mask = cpu_rq(this_cpu)->mm_mask;
+
+	for_each_online_node(nid) {
+		m_w = ACCESS_ONCE(p->mm->mm_autonuma->numa_fault[nid]);
+		p_w = sched_autonuma->numa_fault[nid];
+		if (m_w > m_t)
+			m_t = m_w;
+		weight_current_mm[nid] = m_w*AUTONUMA_BALANCE_SCALE/m_t;
+		if (p_w > p_t)
+			p_t = p_w;
+		weight_current[nid] = p_w*AUTONUMA_BALANCE_SCALE/p_t;
+	}
+
+	bitmap_zero(mm_mask, NR_CPUS);
+	for_each_online_node(nid) {
+		if (nid == cpu_nid)
+			continue;
+		for_each_cpu_and(cpu, cpumask_of_node(nid), allowed) {
+			struct mm_struct *mm;
+			struct rq *rq = cpu_rq(cpu);
+			if (!cpu_online(cpu))
+				continue;
+			weight_others[cpu] = LONG_MAX;
+			if (idle_cpu(cpu) &&
+			    rq->avg_idle > sysctl_sched_migration_cost) {
+				if (weight_current[nid] >
+				    weight_current[cpu_nid] &&
+				    weight_current_mm[nid] >
+				    weight_current_mm[cpu_nid])
+					weight_others[cpu] = -1;
+				continue;
+			}
+			mm = rq->curr->mm;
+			if (!mm)
+				continue;
+			raw_spin_lock_irq(&rq->lock);
+			/* recheck after implicit barrier() */
+			mm = rq->curr->mm;
+			if (!mm) {
+				raw_spin_unlock_irq(&rq->lock);
+				continue;
+			}
+			m_t = ACCESS_ONCE(mm->mm_autonuma->numa_fault_tot);
+			p_t = rq->curr->sched_autonuma->numa_fault_tot;
+			if (!m_t || !p_t) {
+				raw_spin_unlock_irq(&rq->lock);
+				continue;
+			}
+			m_w = ACCESS_ONCE(mm->mm_autonuma->numa_fault[nid]);
+			p_w = rq->curr->sched_autonuma->numa_fault[nid];
+			raw_spin_unlock_irq(&rq->lock);
+			if (mm == p->mm) {
+				if (p_w > p_t)
+					p_t = p_w;
+				weight_others[cpu] = p_w*
+					AUTONUMA_BALANCE_SCALE/p_t;
+
+				__set_bit(cpu, mm_mask);
+			} else {
+				if (m_w > m_t)
+					m_t = m_w;
+				weight_others[cpu] = m_w*
+					AUTONUMA_BALANCE_SCALE/m_t;
+			}
+		}
+	}
+
+	selected_cpu = this_cpu;
+	selected_nid = cpu_nid;
+	weight_delta_max = 0;
+
+	for_each_online_node(nid) {
+		if (nid == cpu_nid)
+			continue;
+		for_each_cpu_and(cpu, cpumask_of_node(nid), allowed) {
+			long w_nid, w_cpu_nid;
+			if (!cpu_online(cpu))
+				continue;
+			if (test_bit(cpu, mm_mask)) {
+				w_nid = weight_current[nid];
+				w_cpu_nid = weight_current[cpu_nid];
+			} else {
+				w_nid = weight_current_mm[nid];
+				w_cpu_nid = weight_current_mm[cpu_nid];
+			}
+			if (w_nid > weight_others[cpu] &&
+			    w_nid > w_cpu_nid) {
+				weight = w_nid -
+					weight_others[cpu] +
+					w_nid -
+					w_cpu_nid;
+				if (weight > weight_delta_max) {
+					weight_delta_max = weight;
+					selected_cpu = cpu;
+					selected_nid = nid;
+				}
+			}
+		}
+	}
+
+	if (sched_autonuma->autonuma_node != selected_nid)
+		sched_autonuma->autonuma_node = selected_nid;
+	if (selected_cpu != this_cpu) {
+		if (autonuma_debug())
+			printk("%p %d - %dto%d - %dto%d - %ld %ld %ld - %s\n",
+			       p->mm, p->pid, cpu_nid, selected_nid,
+			       this_cpu, selected_cpu,
+			       weight_others[selected_cpu],
+			       test_bit(selected_cpu, mm_mask) ?
+			       weight_current[selected_nid] :
+			       weight_current_mm[selected_nid],
+			       test_bit(selected_cpu, mm_mask) ?
+			       weight_current[cpu_nid] :
+			       weight_current_mm[cpu_nid],
+			       test_bit(selected_cpu, mm_mask) ?
+			       "thread" : "process");
+		BUG_ON(cpu_nid == selected_nid);
+		goto found;
+	}
+
+	return;
+
+found:
+	arg = (struct migration_arg) { p, selected_cpu };
+	/* Need help from migration thread: drop lock and wait. */
+	sched_autonuma->autonuma_stop_one_cpu = true;
+	sched_preempt_enable_no_resched();
+	stop_one_cpu(this_cpu, migration_cpu_stop, &arg);
+	preempt_disable();
+	sched_autonuma->autonuma_stop_one_cpu = false;
+	tlb_migrate_finish(p->mm);
+}
+
+bool sched_autonuma_can_migrate_task(struct task_struct *p,
+				     int numa, int dst_cpu,
+				     enum cpu_idle_type idle,
+				     struct cpumask *allowed)
+{
+	if (!task_autonuma_cpu(p, dst_cpu)) {
+		int cpu;
+		int autonuma_node;
+
+		if (numa)
+			return false;
+		if (autonuma_sched_load_balance_strict() &&
+		    idle != CPU_NEWLY_IDLE && idle != CPU_IDLE)
+			return false;
+
+		autonuma_node = ACCESS_ONCE(p->sched_autonuma->autonuma_node);
+		for_each_cpu_and(cpu, cpumask_of_node(autonuma_node),
+				 allowed) {
+			struct rq *rq = cpu_rq(cpu);
+			int _autonuma_node;
+			struct sched_autonuma *sa;
+			if (!cpu_online(cpu))
+				continue;
+			sa = rq->curr->sched_autonuma;
+			_autonuma_node = ACCESS_ONCE(sa->autonuma_node);
+			if (_autonuma_node != autonuma_node)
+				return false;
+			if (idle_cpu(cpu) && rq->avg_idle >=
+			    sysctl_sched_migration_cost)
+				return false;
+		}
+	}
+	return true;
+}
+
+void sched_autonuma_dump_mm(void)
+{
+	int nid, cpu;
+	struct cpumask x;
+	cpumask_setall(&x);
+	for_each_online_node(nid) {
+		for_each_cpu(cpu, cpumask_of_node(nid)) {
+			struct rq *rq = cpu_rq(cpu);
+			struct mm_struct *mm = rq->curr->mm;
+			int nr = 0, cpux;
+			if (!cpumask_test_cpu(cpu, &x))
+				continue;
+			for_each_cpu(cpux, cpumask_of_node(nid)) {
+				struct rq *rqx = cpu_rq(cpux);
+				if (rqx->curr->mm == mm) {
+					nr++;
+					cpumask_clear_cpu(cpux, &x);
+				}
+			}
+			printk("nid %d mm %p nr %d\n", nid, mm, nr);
+		}
+	}
+}
diff --git a/kernel/sched/sched.h b/kernel/sched/sched.h
index 42b1f30..261a295 100644
--- a/kernel/sched/sched.h
+++ b/kernel/sched/sched.h
@@ -463,6 +463,12 @@ struct rq {
 #ifdef CONFIG_SMP
 	struct llist_head wake_list;
 #endif
+#ifdef CONFIG_AUTONUMA
+	long weight_others[NR_CPUS];
+	long weight_current[MAX_NUMNODES];
+	long weight_current_mm[MAX_NUMNODES];
+	DECLARE_BITMAP(mm_mask, NR_CPUS);
+#endif
 };
 
 static inline int cpu_of(struct rq *rq)
@@ -526,6 +532,12 @@ static inline struct sched_domain *highest_flag_domain(int cpu, int flag)
 DECLARE_PER_CPU(struct sched_domain *, sd_llc);
 DECLARE_PER_CPU(int, sd_llc_id);
 
+struct migration_arg {
+	struct task_struct *task;
+	int dest_cpu;
+};
+extern int migration_cpu_stop(void *data);
+
 #endif /* CONFIG_SMP */
 
 #include "stats.h"

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
