Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id B1C856B0089
	for <linux-mm@kvack.org>; Tue, 10 Sep 2013 05:33:12 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 37/50] sched: Introduce migrate_swap()
Date: Tue, 10 Sep 2013 10:32:17 +0100
Message-Id: <1378805550-29949-38-git-send-email-mgorman@suse.de>
In-Reply-To: <1378805550-29949-1-git-send-email-mgorman@suse.de>
References: <1378805550-29949-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Peter Zijlstra <peterz@infradead.org>

Use the new stop_two_cpus() to implement migrate_swap(), a function that
flips two tasks between their respective cpus.

I'm fairly sure there's a less crude way than employing the stop_two_cpus()
method, but everything I tried either got horribly fragile and/or complex. So
keep it simple for now.

The notable detail is how we 'migrate' tasks that aren't runnable
anymore. We'll make it appear like we migrated them before they went to
sleep. The sole difference is the previous cpu in the wakeup path, so we
override this.

TODO: I'm fairly sure we can get rid of the wake_cpu != -1 test by keeping
wake_cpu to the actual task cpu; just couldn't be bothered to think through
all the cases.

Signed-off-by: Peter Zijlstra <peterz@infradead.org>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/sched.h    |   1 +
 kernel/sched/core.c      | 103 ++++++++++++++++++++++++++++++++++++++++++++---
 kernel/sched/fair.c      |   3 +-
 kernel/sched/idle_task.c |   2 +-
 kernel/sched/rt.c        |   5 +--
 kernel/sched/sched.h     |   3 +-
 kernel/sched/stop_task.c |   2 +-
 7 files changed, 105 insertions(+), 14 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 3418b0b..3e8c547 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1035,6 +1035,7 @@ struct task_struct {
 #ifdef CONFIG_SMP
 	struct llist_node wake_entry;
 	int on_cpu;
+	int wake_cpu;
 #endif
 	int on_rq;
 
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 374da2b..67f2b7b 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -1032,6 +1032,90 @@ void set_task_cpu(struct task_struct *p, unsigned int new_cpu)
 	__set_task_cpu(p, new_cpu);
 }
 
+static void __migrate_swap_task(struct task_struct *p, int cpu)
+{
+	if (p->on_rq) {
+		struct rq *src_rq, *dst_rq;
+
+		src_rq = task_rq(p);
+		dst_rq = cpu_rq(cpu);
+
+		deactivate_task(src_rq, p, 0);
+		set_task_cpu(p, cpu);
+		activate_task(dst_rq, p, 0);
+		check_preempt_curr(dst_rq, p, 0);
+	} else {
+		/*
+		 * Task isn't running anymore; make it appear like we migrated
+		 * it before it went to sleep. This means on wakeup we make the
+		 * previous cpu or targer instead of where it really is.
+		 */
+		p->wake_cpu = cpu;
+	}
+}
+
+struct migration_swap_arg {
+	struct task_struct *src_task, *dst_task;
+	int src_cpu, dst_cpu;
+};
+
+static int migrate_swap_stop(void *data)
+{
+	struct migration_swap_arg *arg = data;
+	struct rq *src_rq, *dst_rq;
+	int ret = -EAGAIN;
+
+	src_rq = cpu_rq(arg->src_cpu);
+	dst_rq = cpu_rq(arg->dst_cpu);
+
+	double_rq_lock(src_rq, dst_rq);
+	if (task_cpu(arg->dst_task) != arg->dst_cpu)
+		goto unlock;
+
+	if (task_cpu(arg->src_task) != arg->src_cpu)
+		goto unlock;
+
+	if (!cpumask_test_cpu(arg->dst_cpu, tsk_cpus_allowed(arg->src_task)))
+		goto unlock;
+
+	if (!cpumask_test_cpu(arg->src_cpu, tsk_cpus_allowed(arg->dst_task)))
+		goto unlock;
+
+	__migrate_swap_task(arg->src_task, arg->dst_cpu);
+	__migrate_swap_task(arg->dst_task, arg->src_cpu);
+
+	ret = 0;
+
+unlock:
+	double_rq_unlock(src_rq, dst_rq);
+
+	return ret;
+}
+
+/*
+ * XXX worry about hotplug
+ */
+int migrate_swap(struct task_struct *cur, struct task_struct *p)
+{
+	struct migration_swap_arg arg = {
+		.src_task = cur,
+		.src_cpu = task_cpu(cur),
+		.dst_task = p,
+		.dst_cpu = task_cpu(p),
+	};
+
+	if (arg.src_cpu == arg.dst_cpu)
+		return -EINVAL;
+
+	if (!cpumask_test_cpu(arg.dst_cpu, tsk_cpus_allowed(arg.src_task)))
+		return -EINVAL;
+
+	if (!cpumask_test_cpu(arg.src_cpu, tsk_cpus_allowed(arg.dst_task)))
+		return -EINVAL;
+
+	return stop_two_cpus(arg.dst_cpu, arg.src_cpu, migrate_swap_stop, &arg);
+}
+
 struct migration_arg {
 	struct task_struct *task;
 	int dest_cpu;
@@ -1251,9 +1335,9 @@ out:
  * The caller (fork, wakeup) owns p->pi_lock, ->cpus_allowed is stable.
  */
 static inline
-int select_task_rq(struct task_struct *p, int sd_flags, int wake_flags)
+int select_task_rq(struct task_struct *p, int cpu, int sd_flags, int wake_flags)
 {
-	int cpu = p->sched_class->select_task_rq(p, sd_flags, wake_flags);
+	cpu = p->sched_class->select_task_rq(p, cpu, sd_flags, wake_flags);
 
 	/*
 	 * In order not to call set_task_cpu() on a blocking task we need
@@ -1528,7 +1612,12 @@ try_to_wake_up(struct task_struct *p, unsigned int state, int wake_flags)
 	if (p->sched_class->task_waking)
 		p->sched_class->task_waking(p);
 
-	cpu = select_task_rq(p, SD_BALANCE_WAKE, wake_flags);
+	if (p->wake_cpu != -1) {	/* XXX make this condition go away */
+		cpu = p->wake_cpu;
+		p->wake_cpu = -1;
+	}
+
+	cpu = select_task_rq(p, cpu, SD_BALANCE_WAKE, wake_flags);
 	if (task_cpu(p) != cpu) {
 		wake_flags |= WF_MIGRATED;
 		set_task_cpu(p, cpu);
@@ -1614,6 +1703,10 @@ static void __sched_fork(struct task_struct *p)
 {
 	p->on_rq			= 0;
 
+#ifdef CONFIG_SMP
+	p->wake_cpu			= -1;
+#endif
+
 	p->se.on_rq			= 0;
 	p->se.exec_start		= 0;
 	p->se.sum_exec_runtime		= 0;
@@ -1765,7 +1858,7 @@ void wake_up_new_task(struct task_struct *p)
 	 *  - cpus_allowed can change in the fork path
 	 *  - any previously selected cpu might disappear through hotplug
 	 */
-	set_task_cpu(p, select_task_rq(p, SD_BALANCE_FORK, 0));
+	set_task_cpu(p, select_task_rq(p, task_cpu(p), SD_BALANCE_FORK, 0));
 #endif
 
 	/* Initialize new task's runnable average */
@@ -2093,7 +2186,7 @@ void sched_exec(void)
 	int dest_cpu;
 
 	raw_spin_lock_irqsave(&p->pi_lock, flags);
-	dest_cpu = p->sched_class->select_task_rq(p, SD_BALANCE_EXEC, 0);
+	dest_cpu = p->sched_class->select_task_rq(p, task_cpu(p), SD_BALANCE_EXEC, 0);
 	if (dest_cpu == smp_processor_id())
 		goto unlock;
 
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 5d244d0..cf16c1a 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -3655,11 +3655,10 @@ done:
  * preempt must be disabled.
  */
 static int
-select_task_rq_fair(struct task_struct *p, int sd_flag, int wake_flags)
+select_task_rq_fair(struct task_struct *p, int prev_cpu, int sd_flag, int wake_flags)
 {
 	struct sched_domain *tmp, *affine_sd = NULL, *sd = NULL;
 	int cpu = smp_processor_id();
-	int prev_cpu = task_cpu(p);
 	int new_cpu = cpu;
 	int want_affine = 0;
 	int sync = wake_flags & WF_SYNC;
diff --git a/kernel/sched/idle_task.c b/kernel/sched/idle_task.c
index d8da010..516c3d9 100644
--- a/kernel/sched/idle_task.c
+++ b/kernel/sched/idle_task.c
@@ -9,7 +9,7 @@
 
 #ifdef CONFIG_SMP
 static int
-select_task_rq_idle(struct task_struct *p, int sd_flag, int flags)
+select_task_rq_idle(struct task_struct *p, int cpu, int sd_flag, int flags)
 {
 	return task_cpu(p); /* IDLE tasks as never migrated */
 }
diff --git a/kernel/sched/rt.c b/kernel/sched/rt.c
index 01970c8..d81866d 100644
--- a/kernel/sched/rt.c
+++ b/kernel/sched/rt.c
@@ -1169,13 +1169,10 @@ static void yield_task_rt(struct rq *rq)
 static int find_lowest_rq(struct task_struct *task);
 
 static int
-select_task_rq_rt(struct task_struct *p, int sd_flag, int flags)
+select_task_rq_rt(struct task_struct *p, int cpu, int sd_flag, int flags)
 {
 	struct task_struct *curr;
 	struct rq *rq;
-	int cpu;
-
-	cpu = task_cpu(p);
 
 	if (p->nr_cpus_allowed == 1)
 		goto out;
diff --git a/kernel/sched/sched.h b/kernel/sched/sched.h
index 778f875..99b1ecd 100644
--- a/kernel/sched/sched.h
+++ b/kernel/sched/sched.h
@@ -556,6 +556,7 @@ static inline u64 rq_clock_task(struct rq *rq)
 
 #ifdef CONFIG_NUMA_BALANCING
 extern int migrate_task_to(struct task_struct *p, int cpu);
+extern int migrate_swap(struct task_struct *, struct task_struct *);
 static inline void task_numa_free(struct task_struct *p)
 {
 	kfree(p->numa_faults);
@@ -988,7 +989,7 @@ struct sched_class {
 	void (*put_prev_task) (struct rq *rq, struct task_struct *p);
 
 #ifdef CONFIG_SMP
-	int  (*select_task_rq)(struct task_struct *p, int sd_flag, int flags);
+	int  (*select_task_rq)(struct task_struct *p, int task_cpu, int sd_flag, int flags);
 	void (*migrate_task_rq)(struct task_struct *p, int next_cpu);
 
 	void (*pre_schedule) (struct rq *this_rq, struct task_struct *task);
diff --git a/kernel/sched/stop_task.c b/kernel/sched/stop_task.c
index e08fbee..47197de 100644
--- a/kernel/sched/stop_task.c
+++ b/kernel/sched/stop_task.c
@@ -11,7 +11,7 @@
 
 #ifdef CONFIG_SMP
 static int
-select_task_rq_stop(struct task_struct *p, int sd_flag, int flags)
+select_task_rq_stop(struct task_struct *p, int cpu, int sd_flag, int flags)
 {
 	return task_cpu(p); /* stop tasks as never migrate */
 }
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
