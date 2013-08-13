Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id C40D86B0032
	for <linux-mm@kvack.org>; Tue, 13 Aug 2013 19:06:56 -0400 (EDT)
Message-ID: <201308132306.r7DN6stA029051@farm-0021.internal.tilera.com>
From: Chris Metcalf <cmetcalf@tilera.com>
In-Reply-To: <520AAF9C.1050702@tilera.com>
Date: Tue, 13 Aug 2013 18:51:44 -0400
Subject: [PATCH v7 1/2] workqueue: add schedule_on_each_cpu_cond
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Frederic Weisbecker <fweisbec@gmail.com>, Cody P Schafer <cody@linux.vnet.ibm.com>

This API supports running work on a subset of the online
cpus determined by a callback function.

Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
---
v7: try a version with callbacks instead of cpu masks.
Either this or v6 seem like reasonable solutions.

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
 kernel/workqueue.c        | 54 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 57 insertions(+)

diff --git a/include/linux/workqueue.h b/include/linux/workqueue.h
index a0ed78a..c5ee29f 100644
--- a/include/linux/workqueue.h
+++ b/include/linux/workqueue.h
@@ -17,6 +17,7 @@ struct workqueue_struct;
 
 struct work_struct;
 typedef void (*work_func_t)(struct work_struct *work);
+typedef bool (*work_cond_func_t)(void *data, int cpu);
 void delayed_work_timer_fn(unsigned long __data);
 
 /*
@@ -471,6 +472,8 @@ extern void drain_workqueue(struct workqueue_struct *wq);
 extern void flush_scheduled_work(void);
 
 extern int schedule_on_each_cpu(work_func_t func);
+extern int schedule_on_each_cpu_cond(work_func_t func, work_cond_func_t cond,
+				     void *data);
 
 int execute_in_process_context(work_func_t fn, struct execute_work *);
 
diff --git a/kernel/workqueue.c b/kernel/workqueue.c
index f02c4a4..5c5b534 100644
--- a/kernel/workqueue.c
+++ b/kernel/workqueue.c
@@ -2999,6 +2999,60 @@ int schedule_on_each_cpu(work_func_t func)
 }
 
 /**
+ * schedule_on_each_cpu_cond - execute a function synchronously on each
+ *   online CPU if requested by a condition callback.
+ * @func: the function to call
+ * @cond: the callback function to determine whether to schedule the work
+ * @data: opaque data passed to the callback function
+ *
+ * schedule_on_each_cpu_cond() calls @cond for each online cpu (in the
+ * context of the current cpu), and for each cpu for which @cond returns
+ * true, it executes @func using the system workqueue.  The function
+ * blocks until all CPUs on which work was scheduled have completed.
+ * schedule_on_each_cpu_cond() is very slow.
+ *
+ * The @cond callback is called in the same context as the original
+ * call to schedule_on_each_cpu_cond().
+ *
+ * RETURNS:
+ * 0 on success, -errno on failure.
+ */
+int schedule_on_each_cpu_cond(work_func_t func,
+			      work_cond_func_t cond, void *data)
+{
+	int cpu;
+	struct work_struct __percpu *works;
+
+	works = alloc_percpu(struct work_struct);
+	if (!works)
+		return -ENOMEM;
+
+	get_online_cpus();
+
+	for_each_online_cpu(cpu) {
+		struct work_struct *work = per_cpu_ptr(works, cpu);
+
+		if (cond(data, cpu)) {
+			INIT_WORK(work, func);
+			schedule_work_on(cpu, work);
+		} else {
+			work->entry.next = NULL;
+		}
+	}
+
+	for_each_online_cpu(cpu) {
+		struct work_struct *work = per_cpu_ptr(works, cpu);
+
+		if (work->entry.next)
+			flush_work(work);
+	}
+
+	put_online_cpus();
+	free_percpu(works);
+	return 0;
+}
+
+/**
  * flush_scheduled_work - ensure that any scheduled work has run to completion.
  *
  * Forces execution of the kernel-global workqueue and blocks until its
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
