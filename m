Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 67A156B00F5
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 10:58:58 -0400 (EDT)
Message-ID: <201308071458.r77EwuJV013106@farm-0012.internal.tilera.com>
From: Chris Metcalf <cmetcalf@tilera.com>
Date: Tue, 6 Aug 2013 16:22:39 -0400
Subject: [PATCH] mm: make lru_add_drain_all() selective
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Frederic Weisbecker <fweisbec@gmail.com>

This change makes lru_add_drain_all() only selectively interrupt
the cpus that have per-cpu free pages that can be drained.

This is important in nohz mode where calling mlockall(), for
example, otherwise will interrupt every core unnecessarily.

Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
---
 include/linux/workqueue.h |  3 +++
 kernel/workqueue.c        | 35 ++++++++++++++++++++++++++---------
 mm/swap.c                 | 38 +++++++++++++++++++++++++++++++++++++-
 3 files changed, 66 insertions(+), 10 deletions(-)

diff --git a/include/linux/workqueue.h b/include/linux/workqueue.h
index a0ed78a..71a3fe7 100644
--- a/include/linux/workqueue.h
+++ b/include/linux/workqueue.h
@@ -13,6 +13,8 @@
 #include <linux/atomic.h>
 #include <linux/cpumask.h>
 
+struct cpumask;
+
 struct workqueue_struct;
 
 struct work_struct;
@@ -470,6 +472,7 @@ extern void flush_workqueue(struct workqueue_struct *wq);
 extern void drain_workqueue(struct workqueue_struct *wq);
 extern void flush_scheduled_work(void);
 
+extern int schedule_on_cpu_mask(work_func_t func, const struct cpumask *mask);
 extern int schedule_on_each_cpu(work_func_t func);
 
 int execute_in_process_context(work_func_t fn, struct execute_work *);
diff --git a/kernel/workqueue.c b/kernel/workqueue.c
index f02c4a4..a6d1809 100644
--- a/kernel/workqueue.c
+++ b/kernel/workqueue.c
@@ -2962,17 +2962,18 @@ bool cancel_delayed_work_sync(struct delayed_work *dwork)
 EXPORT_SYMBOL(cancel_delayed_work_sync);
 
 /**
- * schedule_on_each_cpu - execute a function synchronously on each online CPU
+ * schedule_on_cpu_mask - execute a function synchronously on each listed CPU
  * @func: the function to call
+ * @mask: the cpumask to invoke the function on
  *
- * schedule_on_each_cpu() executes @func on each online CPU using the
+ * schedule_on_cpu_mask() executes @func on each listed CPU using the
  * system workqueue and blocks until all CPUs have completed.
- * schedule_on_each_cpu() is very slow.
+ * schedule_on_cpu_mask() is very slow.
  *
  * RETURNS:
  * 0 on success, -errno on failure.
  */
-int schedule_on_each_cpu(work_func_t func)
+int schedule_on_cpu_mask(work_func_t func, const struct cpumask *mask)
 {
 	int cpu;
 	struct work_struct __percpu *works;
@@ -2981,24 +2982,40 @@ int schedule_on_each_cpu(work_func_t func)
 	if (!works)
 		return -ENOMEM;
 
-	get_online_cpus();
-
-	for_each_online_cpu(cpu) {
+	for_each_cpu(cpu, mask) {
 		struct work_struct *work = per_cpu_ptr(works, cpu);
 
 		INIT_WORK(work, func);
 		schedule_work_on(cpu, work);
 	}
 
-	for_each_online_cpu(cpu)
+	for_each_cpu(cpu, mask)
 		flush_work(per_cpu_ptr(works, cpu));
 
-	put_online_cpus();
 	free_percpu(works);
 	return 0;
 }
 
 /**
+ * schedule_on_each_cpu - execute a function synchronously on each online CPU
+ * @func: the function to call
+ *
+ * schedule_on_each_cpu() executes @func on each online CPU using the
+ * system workqueue and blocks until all CPUs have completed.
+ * schedule_on_each_cpu() is very slow.
+ *
+ * RETURNS:
+ * 0 on success, -errno on failure.
+ */
+int schedule_on_each_cpu(work_func_t func)
+{
+	get_online_cpus();
+	schedule_on_cpu_mask(func, cpu_online_mask);
+	put_online_cpus();
+	return 0;
+}
+
+/**
  * flush_scheduled_work - ensure that any scheduled work has run to completion.
  *
  * Forces execution of the kernel-global workqueue and blocks until its
diff --git a/mm/swap.c b/mm/swap.c
index 4a1d0d2..981b1d9 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -683,7 +683,43 @@ static void lru_add_drain_per_cpu(struct work_struct *dummy)
  */
 int lru_add_drain_all(void)
 {
-	return schedule_on_each_cpu(lru_add_drain_per_cpu);
+	cpumask_var_t mask;
+	int cpu, rc;
+
+	if (!alloc_cpumask_var(&mask, GFP_KERNEL))
+		return -ENOMEM;
+	cpumask_clear(mask);
+
+	/*
+	 * Figure out which cpus need flushing.  It's OK if we race
+	 * with changes to the per-cpu lru pvecs, since it's no worse
+	 * than if we flushed all cpus, since a cpu could still end
+	 * up putting pages back on its pvec before we returned.
+	 * And this avoids interrupting other cpus unnecessarily.
+	 */
+	for_each_online_cpu(cpu) {
+		struct pagevec *pvecs = per_cpu(lru_add_pvecs, cpu);
+		struct pagevec *pvec = &per_cpu(lru_rotate_pvecs, cpu);
+		int count = pagevec_count(pvec);
+		int lru;
+
+		if (!count) {
+			for_each_lru(lru) {
+				pvec = &pvecs[lru - LRU_BASE];
+				count = pagevec_count(pvec);
+				if (count)
+					break;
+			}
+		}
+
+		if (count)
+			cpumask_set_cpu(cpu, mask);
+	}
+
+	rc = schedule_on_cpu_mask(lru_add_drain_per_cpu, mask);
+
+	free_cpumask_var(mask);
+	return rc;
 }
 
 /*
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
