Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 3E3E56B00A3
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 05:23:07 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 42/46] sched: numa: CPU follows memory
Date: Wed, 21 Nov 2012 10:21:48 +0000
Message-Id: <1353493312-8069-43-git-send-email-mgorman@suse.de>
In-Reply-To: <1353493312-8069-1-git-send-email-mgorman@suse.de>
References: <1353493312-8069-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

NOTE: This is heavily based on "autonuma: CPU follows memory algorithm"
	and "autonuma: mm_autonuma and task_autonuma data structures"
	with bits taken but worked within the scheduler hooks and home
	node mechanism as defined by schednuma.

This patch adds per-mm and per-task data structures to track the number
of faults in total and on a per-nid basis. On each NUMA fault it
checks if the system would benefit if the current task was migrated
to another node. If the task should be migrated, its home node is
updated and the task is requeued.

[dhillf@gmail.com: remove unnecessary check]
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/sched.h |    1 -
 kernel/sched/fair.c   |  228 ++++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 226 insertions(+), 3 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 7b6625a..269ff7d 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -2040,7 +2040,6 @@ extern unsigned int sysctl_balance_numa_scan_delay;
 extern unsigned int sysctl_balance_numa_scan_period_min;
 extern unsigned int sysctl_balance_numa_scan_period_max;
 extern unsigned int sysctl_balance_numa_scan_size;
-extern unsigned int sysctl_balance_numa_settle_count;
 
 #ifdef CONFIG_SCHED_DEBUG
 extern unsigned int sysctl_sched_migration_cost;
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index fc8f95d..495eed8 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -837,15 +837,229 @@ unsigned int sysctl_balance_numa_scan_size = 256;
 /* Scan @scan_size MB every @scan_period after an initial @scan_delay in ms */
 unsigned int sysctl_balance_numa_scan_delay = 1000;
 
+#define BALANCENUMA_SCALE 1000
+static inline unsigned long balancenuma_weight(unsigned long nid_faults,
+					       unsigned long total_faults)
+{
+	if (nid_faults > total_faults)
+		nid_faults = total_faults;
+
+	return nid_faults * BALANCENUMA_SCALE / total_faults;
+}
+
+static inline unsigned long balancenuma_task_weight(struct task_struct *p,
+							int nid)
+{
+	struct task_balancenuma *task_balancenuma = p->task_balancenuma;
+	unsigned long nid_faults, total_faults;
+
+	nid_faults = task_balancenuma->task_numa_fault[nid];
+	total_faults = task_balancenuma->task_numa_fault_tot;
+	return balancenuma_weight(nid_faults, total_faults);
+}
+
+static inline unsigned long balancenuma_mm_weight(struct task_struct *p,
+							int nid)
+{
+	struct mm_balancenuma *mm_balancenuma = p->mm->mm_balancenuma;
+	unsigned long nid_faults, total_faults;
+
+	nid_faults = mm_balancenuma->mm_numa_fault[nid];
+	total_faults = mm_balancenuma->mm_numa_fault_tot;
+
+	/* It's possible for total_faults to decay to 0 in parallel so check */
+	return total_faults ? balancenuma_weight(nid_faults, total_faults) : 0;
+}
+
+/*
+ * Examines all other nodes examining remote tasks to see if there would
+ * be fewer remote numa faults if tasks swapped home nodes
+ */
+static void task_numa_find_placement(struct task_struct *p)
+{
+	struct cpumask *allowed = tsk_cpus_allowed(p);
+	int this_cpu = smp_processor_id();
+	int this_nid = numa_node_id();
+	long p_task_weight, p_mm_weight;
+	long weight_diff_max = 0;
+	struct task_struct *selected_task = NULL;
+	int selected_nid = -1;
+	int nid;
+
+	p_task_weight = balancenuma_task_weight(p, this_nid);
+	p_mm_weight = balancenuma_mm_weight(p, this_nid);
+
+	/* Examine a task on every other node */
+	for_each_online_node(nid) {
+		int cpu;
+		for_each_cpu_and(cpu, cpumask_of_node(nid), allowed) {
+			struct rq *rq;
+			struct mm_struct *other_mm;
+			struct task_struct *other_task;
+			long this_weight, other_weight, p_weight;
+			long other_diff, this_diff;
+
+			if (!cpu_online(cpu) || idle_cpu(cpu))
+				continue;
+
+			/* Racy check if a task is running on the other rq */
+			rq = cpu_rq(cpu);
+			other_mm = rq->curr->mm;
+			if (!other_mm || !other_mm->mm_balancenuma)
+				continue;
+
+			/* Effectively pin the other task to get fault stats */
+			raw_spin_lock_irq(&rq->lock);
+			other_task = rq->curr;
+			other_mm = other_task->mm;
+
+			/* Ensure the other task has usable stats */
+			if (!other_task->task_balancenuma ||
+			    !other_task->task_balancenuma->task_numa_fault_tot ||
+			    !other_mm ||
+			    !other_mm->mm_balancenuma ||
+			    !other_mm->mm_balancenuma->mm_numa_fault_tot) {
+				raw_spin_unlock_irq(&rq->lock);
+				continue;
+			}
+
+			/* Ensure the other task can be swapped */
+			if (!cpumask_test_cpu(this_cpu,
+					      tsk_cpus_allowed(other_task))) {
+				raw_spin_unlock_irq(&rq->lock);
+				continue;
+			}
+
+			/*
+			 * Read the fault statistics. If the remote task is a
+			 * thread in the process then use the task statistics.
+			 * Otherwise use the per-mm statistics.
+			 */
+			if (other_mm == p->mm) {
+				this_weight = balancenuma_task_weight(p, nid);
+				other_weight = balancenuma_task_weight(other_task, nid);
+				p_weight = p_task_weight;
+			} else {
+				this_weight = balancenuma_mm_weight(p, nid);
+				other_weight = balancenuma_mm_weight(other_task, nid);
+				p_weight = p_mm_weight;
+			}
+
+			raw_spin_unlock_irq(&rq->lock);
+
+			/*
+			 * other_diff: How much does the current task perfer to
+			 * run on the remote node thn the task that is
+			 * currently running there?
+			 */
+			other_diff = this_weight - other_weight;
+
+			/*
+			 * this_diff: How much does the currrent task prefer to
+			 * run on the remote NUMA node compared to the current
+			 * node?
+			 */
+			this_diff = this_weight - p_weight;
+
+			/*
+			 * Would swapping the tasks reduce the overall
+			 * cross-node NUMA faults?
+			 */
+			if (other_diff > 0 && this_diff > 0) {
+				long weight_diff = other_diff + this_diff;
+
+				/* Remember the best candidate. */
+				if (weight_diff > weight_diff_max) {
+					weight_diff_max = weight_diff;
+					selected_nid = nid;
+					selected_task = other_task;
+				}
+			}
+		}
+	}
+
+	/* Swap the task on the selected target node */
+	if (selected_nid != -1 && selected_nid != this_nid) {
+		sched_setnode(p, selected_nid);
+		sched_setnode(selected_task, this_nid);
+	}
+}
+
 static void task_numa_placement(struct task_struct *p)
 {
+	unsigned long task_total, mm_total;
+	struct mm_balancenuma *mm_balancenuma;
+	struct task_balancenuma *task_balancenuma;
+	unsigned long mm_max_weight, task_max_weight;
+	int this_nid, nid, mm_selected_nid, task_selected_nid;
+
 	int seq = ACCESS_ONCE(p->mm->numa_scan_seq);
 
 	if (p->numa_scan_seq == seq)
 		return;
 	p->numa_scan_seq = seq;
 
-	/* FIXME: Scheduling placement policy hints go here */
+	this_nid = numa_node_id();
+	mm_balancenuma = p->mm->mm_balancenuma;
+	task_balancenuma = p->task_balancenuma;
+
+	/* If the task has no NUMA hinting page faults, use current nid */
+	mm_total = ACCESS_ONCE(mm_balancenuma->mm_numa_fault_tot);
+	if (!mm_total)
+		return;
+	task_total = task_balancenuma->task_numa_fault_tot;
+	if (!task_total)
+		return;
+
+	/*
+	 * Identify the NUMA node where this thread (task_struct), and
+	 * the process (mm_struct) as a whole, has the largest number
+	 * of NUMA faults
+	 */
+	mm_selected_nid = task_selected_nid = -1;
+	mm_max_weight = task_max_weight = 0;
+	for_each_online_node(nid) {
+		unsigned long mm_nid_fault, task_nid_fault;
+		unsigned long mm_numa_weight, task_numa_weight;
+
+		/* Read the number of task and mm faults on node */
+		mm_nid_fault = ACCESS_ONCE(mm_balancenuma->mm_numa_fault[nid]);
+		task_nid_fault = task_balancenuma->task_numa_fault[nid];
+
+		/*
+		 * The weights are the relative number of pte_numa faults that
+		 * were handled on this node in comparison to all pte_numa faults
+		 * overall
+		 */
+		mm_numa_weight = balancenuma_weight(mm_nid_fault, mm_total);
+		task_numa_weight = balancenuma_weight(task_nid_fault, task_total);
+		if (mm_numa_weight > mm_max_weight) {
+			mm_max_weight = mm_numa_weight;
+			mm_selected_nid = nid;
+		}
+		if (task_numa_weight > task_max_weight) {
+			task_max_weight = task_numa_weight;
+			task_selected_nid = nid;
+		}
+
+		/* Decay the stats by a factor of 2 */
+		p->mm->mm_balancenuma->mm_numa_fault[nid] >>= 1;
+	}
+
+	/*
+	 * If this NUMA node is the selected one based on process
+	 * memory and task NUMA faults then set the home node.
+	 * There should be no need to requeue the task.
+	 */
+	if (task_selected_nid == this_nid && mm_selected_nid == this_nid) {
+		p->numa_scan_period = min(sysctl_balance_numa_scan_period_max,
+					  p->numa_scan_period * 2);
+		p->home_node = this_nid;
+		return;
+	}
+
+	p->numa_scan_period = sysctl_balance_numa_scan_period_min;
+	task_numa_find_placement(p);
 }
 
 /*
@@ -896,6 +1110,16 @@ static void reset_ptenuma_scan(struct task_struct *p)
 {
 	ACCESS_ONCE(p->mm->numa_scan_seq)++;
 	p->mm->numa_scan_offset = 0;
+	
+	if (p->mm->mm_balancenuma)
+		p->mm->mm_balancenuma->mm_numa_fault_tot >>= 1;
+	if (p->task_balancenuma) {
+		int nid;
+		p->task_balancenuma->task_numa_fault_tot >>= 1;
+		for_each_online_node(nid) {
+			p->task_balancenuma->task_numa_fault[nid] >>= 1;
+		}
+	}
 }
 
 /*
@@ -985,7 +1209,7 @@ out:
 	 * It is possible to reach the end of the VMA list but the last few VMAs are
 	 * not guaranteed to the vma_migratable. If they are not, we would find the
 	 * !migratable VMA on the next scan but not reset the scanner to the start
-	 * so check it now.
+	 * so we must check it now.
 	 */
 	if (vma)
 		mm->numa_scan_offset = start;
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
