Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 1CD106B0033
	for <linux-mm@kvack.org>; Fri,  9 Aug 2013 14:47:47 -0400 (EDT)
Message-ID: <201308091847.r79IlimS015092@farm-0021.internal.tilera.com>
From: Chris Metcalf <cmetcalf@tilera.com>
In-Reply-To: <20130809174009.GV20515@mtj.dyndns.org>
Date: Fri, 9 Aug 2013 13:49:44 -0400
Subject: [PATCH v6 1/2] workqueue: add new schedule_on_cpu_mask() API
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Frederic Weisbecker <fweisbec@gmail.com>, Cody P Schafer <cody@linux.vnet.ibm.com>

This primitive allows scheduling work to run on a particular set of
cpus described by a "struct cpumask".  This can be useful, for example,
if you have a per-cpu variable that requires code execution only if the
per-cpu variable has a certain value (for example, is a non-empty list).

Acked-by: Tejun Heo <tj@kernel.org>
Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
---
v6: add Tejun's Acked-by, and add missing get/put_cpu_online to
lru_add_drain_all().

v5: provide validity checking on the cpumask for schedule_on_cpu_mask.
By providing an all-or-nothing EINVAL check, we impose the requirement
that the calling code actually know clearly what it's trying to do.
(Note: no change to the mm/swap.c commit)

v4: don't lose possible -ENOMEM in schedule_on_each_cpu()
(Note: no change to the mm/swap.c commit)

v3: split commit into two, one for workqueue and one for mm, though both
should probably be taken through -mm.

 include/linux/workqueue.h |  3 +++
 kernel/workqueue.c        | 51 ++++++++++++++++++++++++++++++++++++++---------
 2 files changed, 45 insertions(+), 9 deletions(-)

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
index f02c4a4..63d504a 100644
--- a/kernel/workqueue.c
+++ b/kernel/workqueue.c
@@ -292,6 +292,9 @@ static DEFINE_SPINLOCK(wq_mayday_lock);	/* protects wq->maydays list */
 static LIST_HEAD(workqueues);		/* PL: list of all workqueues */
 static bool workqueue_freezing;		/* PL: have wqs started freezing? */
 
+/* set of cpus that are valid for per-cpu workqueue scheduling */
+static struct cpumask wq_valid_cpus;
+
 /* the per-cpu worker pools */
 static DEFINE_PER_CPU_SHARED_ALIGNED(struct worker_pool [NR_STD_WORKER_POOLS],
 				     cpu_worker_pools);
@@ -2962,43 +2965,66 @@ bool cancel_delayed_work_sync(struct delayed_work *dwork)
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
+ * schedule_on_cpu_mask() is very slow.  You may only specify CPUs
+ * that are online or have previously been online; specifying an
+ * invalid CPU mask will return -EINVAL without scheduling any work.
  *
  * RETURNS:
  * 0 on success, -errno on failure.
  */
-int schedule_on_each_cpu(work_func_t func)
+int schedule_on_cpu_mask(work_func_t func, const struct cpumask *mask)
 {
 	int cpu;
 	struct work_struct __percpu *works;
 
+	if (!cpumask_subset(mask, &wq_valid_cpus))
+		return -EINVAL;
+
 	works = alloc_percpu(struct work_struct);
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
+	int ret;
+	get_online_cpus();
+	ret = schedule_on_cpu_mask(func, cpu_online_mask);
+	put_online_cpus();
+	return ret;
+}
+
+/**
  * flush_scheduled_work - ensure that any scheduled work has run to completion.
  *
  * Forces execution of the kernel-global workqueue and blocks until its
@@ -4687,6 +4713,9 @@ static int __cpuinit workqueue_cpu_up_callback(struct notifier_block *nfb,
 		list_for_each_entry(wq, &workqueues, list)
 			wq_update_unbound_numa(wq, cpu, true);
 
+		/* track the set of cpus that have ever been online */
+		cpumask_set_cpu(cpu, &wq_valid_cpus);
+
 		mutex_unlock(&wq_pool_mutex);
 		break;
 	}
@@ -5011,6 +5040,10 @@ static int __init init_workqueues(void)
 	       !system_unbound_wq || !system_freezable_wq ||
 	       !system_power_efficient_wq ||
 	       !system_freezable_power_efficient_wq);
+
+	/* mark startup cpu as valid */
+	cpumask_set_cpu(smp_processor_id(), &wq_valid_cpus);
+
 	return 0;
 }
 early_initcall(init_workqueues);
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
