Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id C3CDD8D0003
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 05:23:11 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 45/46] balancenuma: no task swap in finding placement
Date: Wed, 21 Nov 2012 10:21:51 +0000
Message-Id: <1353493312-8069-46-git-send-email-mgorman@suse.de>
In-Reply-To: <1353493312-8069-1-git-send-email-mgorman@suse.de>
References: <1353493312-8069-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Hillf Danton <dhillf@gmail.com>

Node is selected on behalf of given task, but no reason to punish
the currently running tasks on other nodes. That punishment maybe benifit,
who knows. Better if they are treated not in random way.

Signed-off-by: Hillf Danton <dhillf@gmail.com>
---
 kernel/sched/fair.c |   15 ++-------------
 1 file changed, 2 insertions(+), 13 deletions(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 2c9300f..5cc5b60 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -873,7 +873,7 @@ static inline unsigned long balancenuma_mm_weight(struct task_struct *p,
 
 /*
  * Examines all other nodes examining remote tasks to see if there would
- * be fewer remote numa faults if tasks swapped home nodes
+ * be fewer remote numa faults
  */
 static void task_numa_find_placement(struct task_struct *p)
 {
@@ -932,13 +932,6 @@ static void task_numa_find_placement(struct task_struct *p)
 				continue;
 			}
 
-			/* Ensure the other task can be swapped */
-			if (!cpumask_test_cpu(this_cpu,
-					      tsk_cpus_allowed(other_task))) {
-				raw_spin_unlock_irq(&rq->lock);
-				continue;
-			}
-
 			/*
 			 * Read the fault statistics. If the remote task is a
 			 * thread in the process then use the task statistics.
@@ -972,8 +965,7 @@ compare_other:
 			this_diff = this_weight - p_weight;
 
 			/*
-			 * Would swapping the tasks reduce the overall
-			 * cross-node NUMA faults?
+			 * Would nid reduce the overall cross-node NUMA faults?
 			 */
 			if (other_diff > 0 && this_diff > 0) {
 				long weight_diff = other_diff + this_diff;
@@ -994,11 +986,8 @@ compare_other:
 		}
 	}
 
-	/* Swap the task on the selected target node */
 	if (selected_nid != -1 && selected_nid != this_nid) {
 		sched_setnode(p, selected_nid);
-		if (selected_task)
-			sched_setnode(selected_task, this_nid);
 	}
 }
 
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
