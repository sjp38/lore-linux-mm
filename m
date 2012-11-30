Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 05ABD6B00E1
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 14:58:54 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so657952eek.14
        for <linux-mm@kvack.org>; Fri, 30 Nov 2012 11:58:53 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 01/10] sched: Add "task flipping" support
Date: Fri, 30 Nov 2012 20:58:32 +0100
Message-Id: <1354305521-11583-2-git-send-email-mingo@kernel.org>
In-Reply-To: <1354305521-11583-1-git-send-email-mingo@kernel.org>
References: <1354305521-11583-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

NUMA balancing will make use of the new sched_rebalance_to() mode:
the ability to 'flip' two tasks.

When two tasks have a similar weight but one of them executes on
the wrong CPU or node, then it's beneficial to do a quick flipping
operation. This will not change the general load of the source
and the target CPUs, so it won't disturb the scheduling balance.

With this we can do NUMA placement while the system is otherwise
in equilibrium.

The code has to be careful about races and whether the source and
target CPUs are allowed for the tasks in question.

This method is also faster: it can execute two migrations via one
migration-thread call in essence - instead of two such calls. The
thread on the target CPU acts as the 'migration thread' for the
replaced task.

Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 include/linux/sched.h |  1 -
 kernel/sched/core.c   | 68 +++++++++++++++++++++++++++++++++++++--------------
 kernel/sched/fair.c   |  2 +-
 kernel/sched/sched.h  |  6 +++++
 4 files changed, 57 insertions(+), 20 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 8bc3a03..696492e 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -2020,7 +2020,6 @@ task_sched_runtime(struct task_struct *task);
 /* sched_exec is called by processes performing an exec */
 #ifdef CONFIG_SMP
 extern void sched_exec(void);
-extern void sched_rebalance_to(int dest_cpu);
 #else
 #define sched_exec()   {}
 #endif
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 93f2561..cad6c89 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -963,8 +963,8 @@ void set_task_cpu(struct task_struct *p, unsigned int new_cpu)
 }
 
 struct migration_arg {
-	struct task_struct *task;
-	int dest_cpu;
+	struct task_struct	*task;
+	int			dest_cpu;
 };
 
 static int migration_cpu_stop(void *data);
@@ -2596,22 +2596,6 @@ unlock:
 	raw_spin_unlock_irqrestore(&p->pi_lock, flags);
 }
 
-/*
- * sched_rebalance_to()
- *
- * Active load-balance to a target CPU.
- */
-void sched_rebalance_to(int dest_cpu)
-{
-	struct task_struct *p = current;
-	struct migration_arg arg = { p, dest_cpu };
-
-	if (!cpumask_test_cpu(dest_cpu, tsk_cpus_allowed(p)))
-		return;
-
-	stop_one_cpu(raw_smp_processor_id(), migration_cpu_stop, &arg);
-}
-
 #endif
 
 DEFINE_PER_CPU(struct kernel_stat, kstat);
@@ -4778,6 +4762,54 @@ fail:
 }
 
 /*
+ * sched_rebalance_to()
+ *
+ * Active load-balance to a target CPU.
+ */
+void sched_rebalance_to(int dst_cpu, int flip_tasks)
+{
+	struct task_struct *p_src = current;
+	struct task_struct *p_dst;
+	int src_cpu = raw_smp_processor_id();
+	struct migration_arg arg = { p_src, dst_cpu };
+	struct rq *dst_rq;
+
+	if (!cpumask_test_cpu(dst_cpu, tsk_cpus_allowed(p_src)))
+		return;
+
+	if (flip_tasks) {
+		dst_rq = cpu_rq(dst_cpu);
+
+		local_irq_disable();
+		raw_spin_lock(&dst_rq->lock);
+
+		p_dst = dst_rq->curr;
+		get_task_struct(p_dst);
+
+		raw_spin_unlock(&dst_rq->lock);
+		local_irq_enable();
+	}
+
+	stop_one_cpu(src_cpu, migration_cpu_stop, &arg);
+	/*
+	 * Task-flipping.
+	 *
+	 * We are now on the new CPU - check whether we can migrate
+	 * the task we just preempted, to where we came from:
+	 */
+	if (flip_tasks) {
+		local_irq_disable();
+		if (raw_smp_processor_id() == dst_cpu) {
+ 			/* Note that the arguments flip: */
+			__migrate_task(p_dst, dst_cpu, src_cpu);
+		}
+		local_irq_enable();
+
+		put_task_struct(p_dst);
+	}
+}
+
+/*
  * migration_cpu_stop - this will be executed by a highprio stopper thread
  * and performs thread migration by bumping thread off CPU then
  * 'pushing' onto another runqueue.
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 5cc3620..54c1e7b 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -1176,7 +1176,7 @@ static void task_numa_placement(struct task_struct *p)
 		struct rq *rq = cpu_rq(p->ideal_cpu);
 
 		rq->curr_buddy = p;
-		sched_rebalance_to(p->ideal_cpu);
+		sched_rebalance_to(p->ideal_cpu, 0);
 	}
 }
 
diff --git a/kernel/sched/sched.h b/kernel/sched/sched.h
index 810a1a0..f3a284e 100644
--- a/kernel/sched/sched.h
+++ b/kernel/sched/sched.h
@@ -1259,4 +1259,10 @@ static inline u64 irq_time_read(int cpu)
 	return per_cpu(cpu_softirq_time, cpu) + per_cpu(cpu_hardirq_time, cpu);
 }
 #endif /* CONFIG_64BIT */
+#ifdef CONFIG_SMP
+extern void sched_rebalance_to(int dest_cpu, int flip_tasks);
+#else
+static inline void sched_rebalance_to(int dest_cpu, int flip_tasks) { }
+#endif
+
 #endif /* CONFIG_IRQ_TIME_ACCOUNTING */
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
