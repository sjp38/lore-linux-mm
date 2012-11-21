Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 5B2716B00BC
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 05:23:13 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 46/46] Simple CPU follow
Date: Wed, 21 Nov 2012 10:21:52 +0000
Message-Id: <1353493312-8069-47-git-send-email-mgorman@suse.de>
In-Reply-To: <1353493312-8069-1-git-send-email-mgorman@suse.de>
References: <1353493312-8069-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

---
 kernel/sched/fair.c |  112 +++++++--------------------------------------------
 1 file changed, 15 insertions(+), 97 deletions(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 5cc5b60..fd53f17 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -877,118 +877,36 @@ static inline unsigned long balancenuma_mm_weight(struct task_struct *p,
  */
 static void task_numa_find_placement(struct task_struct *p)
 {
-	struct cpumask *allowed = tsk_cpus_allowed(p);
-	int this_cpu = smp_processor_id();
 	int this_nid = numa_node_id();
 	long p_task_weight, p_mm_weight;
-	long weight_diff_max = 0;
-	struct task_struct *selected_task = NULL;
+	long max_weight = 0;
 	int selected_nid = -1;
 	int nid;
 
 	p_task_weight = balancenuma_task_weight(p, this_nid);
 	p_mm_weight = balancenuma_mm_weight(p, this_nid);
 
-	/* Examine a task on every other node */
+	/* Check if this task should run on another node */
 	for_each_online_node(nid) {
-		int cpu;
-		for_each_cpu_and(cpu, cpumask_of_node(nid), allowed) {
-			struct rq *rq;
-			struct mm_struct *other_mm;
-			struct task_struct *other_task;
-			long this_weight, other_weight, p_weight;
-			long other_diff, this_diff;
-
-			if (!cpu_online(cpu))
-				continue;
-
-			/* Idle CPU, consider running this task on that node */
- 			if (idle_cpu(cpu)) {
-				this_weight = balancenuma_task_weight(p, nid);
-				other_weight = 0;
-				other_task = NULL;
-				p_weight = p_task_weight;
-				goto compare_other;
-			}
-
-			/* Racy check if a task is running on the other rq */
-			rq = cpu_rq(cpu);
-			other_mm = rq->curr->mm;
-			if (!other_mm || !other_mm->mm_balancenuma)
-				continue;
-
-			/* Effectively pin the other task to get fault stats */
-			raw_spin_lock_irq(&rq->lock);
-			other_task = rq->curr;
-			other_mm = other_task->mm;
-
-			/* Ensure the other task has usable stats */
-			if (!other_task->task_balancenuma ||
-			    !other_task->task_balancenuma->task_numa_fault_tot ||
-			    !other_mm ||
-			    !other_mm->mm_balancenuma ||
-			    !other_mm->mm_balancenuma->mm_numa_fault_tot) {
-				raw_spin_unlock_irq(&rq->lock);
-				continue;
-			}
-
-			/*
-			 * Read the fault statistics. If the remote task is a
-			 * thread in the process then use the task statistics.
-			 * Otherwise use the per-mm statistics.
-			 */
-			if (other_mm == p->mm) {
-				this_weight = balancenuma_task_weight(p, nid);
-				other_weight = balancenuma_task_weight(other_task, nid);
-				p_weight = p_task_weight;
-			} else {
-				this_weight = balancenuma_mm_weight(p, nid);
-				other_weight = balancenuma_mm_weight(other_task, nid);
-				p_weight = p_mm_weight;
-			}
-
-			raw_spin_unlock_irq(&rq->lock);
-
-compare_other:
-			/*
-			 * other_diff: How much does the current task perfer to
-			 * run on the remote node thn the task that is
-			 * currently running there?
-			 */
-			other_diff = this_weight - other_weight;
+		unsigned long nid_weight;
 
-			/*
-			 * this_diff: How much does the currrent task prefer to
-			 * run on the remote NUMA node compared to the current
-			 * node?
-			 */
-			this_diff = this_weight - p_weight;
-
-			/*
-			 * Would nid reduce the overall cross-node NUMA faults?
-			 */
-			if (other_diff > 0 && this_diff > 0) {
-				long weight_diff = other_diff + this_diff;
-
-				/* Remember the best candidate. */
-				if (weight_diff > weight_diff_max) {
-					weight_diff_max = weight_diff;
-					selected_nid = nid;
-					selected_task = other_task;
-				}
-			}
+		/*
+		 * Read the fault statistics. If the remote task is a
+		 * thread in the process then use the task statistics.
+		 * Otherwise use the per-mm statistics.
+		 */
+		nid_weight = balancenuma_task_weight(p, nid) +
+				balancenuma_mm_weight(p, nid); 
 
-			/*
-			 * Examine just one task per node. Examing all tasks
-			 * disrupts the system excessively
-			 */
-			break;
+		/* Remember the best candidate. */
+		if (nid_weight > max_weight) {
+			max_weight = nid_weight;
+			selected_nid = nid;
 		}
 	}
 
-	if (selected_nid != -1 && selected_nid != this_nid) {
+	if (selected_nid != -1 && selected_nid != this_nid)
 		sched_setnode(p, selected_nid);
-	}
 }
 
 static void task_numa_placement(struct task_struct *p)
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
