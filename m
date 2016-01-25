Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id C7C4F828E2
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 10:47:47 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id b14so86729940wmb.1
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 07:47:47 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id pd7si29208091wjb.47.2016.01.25.07.47.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 25 Jan 2016 07:47:46 -0800 (PST)
From: Petr Mladek <pmladek@suse.com>
Subject: [PATCH v4 04/22] kthread: Add create_kthread_worker*()
Date: Mon, 25 Jan 2016 16:44:53 +0100
Message-Id: <1453736711-6703-5-git-send-email-pmladek@suse.com>
In-Reply-To: <1453736711-6703-1-git-send-email-pmladek@suse.com>
References: <1453736711-6703-1-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>

Kthread workers are currently created using the classic kthread API,
namely kthread_run(). kthread_worker_fn() is passed as the @threadfn
parameter.

This patch defines create_kthread_worker() and
create_kthread_worker_on_cpu() functions that hide implementation details.

They enforce using kthread_worker_fn() for the main thread. But I doubt
that there are any plans to create any alternative. In fact, I think
that we do not want any alternative main thread because it would be
hard to support consistency with the rest of the kthread worker API.

The naming and function is inspired by the workqueues API like the rest
of the kthread worker API.

Note that we need to bind per-CPU kthread workers already when they are
created. It makes the life easier. kthread_bind() could not be used later
for an already running worker.

This patch does _not_ convert existing kthread workers. The kthread worker
API need more improvements first, e.g. a function to destroy the worker.

Signed-off-by: Petr Mladek <pmladek@suse.com>
---
 include/linux/kthread.h |  7 ++++
 kernel/kthread.c        | 99 ++++++++++++++++++++++++++++++++++++++++++++-----
 2 files changed, 96 insertions(+), 10 deletions(-)

diff --git a/include/linux/kthread.h b/include/linux/kthread.h
index e691b6a23f72..943900c7ce35 100644
--- a/include/linux/kthread.h
+++ b/include/linux/kthread.h
@@ -124,6 +124,13 @@ extern void __init_kthread_worker(struct kthread_worker *worker,
 
 int kthread_worker_fn(void *worker_ptr);
 
+__printf(1, 2)
+struct kthread_worker *
+create_kthread_worker(const char namefmt[], ...);
+
+struct kthread_worker *
+create_kthread_worker_on_cpu(int cpu, const char namefmt[]);
+
 bool queue_kthread_work(struct kthread_worker *worker,
 			struct kthread_work *work);
 void flush_kthread_work(struct kthread_work *work);
diff --git a/kernel/kthread.c b/kernel/kthread.c
index bfe8742c4217..df402e18bb5a 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -567,23 +567,24 @@ EXPORT_SYMBOL_GPL(__init_kthread_worker);
  * kthread_worker_fn - kthread function to process kthread_worker
  * @worker_ptr: pointer to initialized kthread_worker
  *
- * This function can be used as @threadfn to kthread_create() or
- * kthread_run() with @worker_ptr argument pointing to an initialized
- * kthread_worker.  The started kthread will process work_list until
- * the it is stopped with kthread_stop().  A kthread can also call
- * this function directly after extra initialization.
+ * This function implements the main cycle of kthread worker. It processes
+ * work_list until it is stopped with kthread_stop(). It sleeps when the queue
+ * is empty.
  *
- * Different kthreads can be used for the same kthread_worker as long
- * as there's only one kthread attached to it at any given time.  A
- * kthread_worker without an attached kthread simply collects queued
- * kthread_works.
+ * The works are not allowed to keep any locks, disable preemption or interrupts
+ * when they finish. There is defined a safe point for freezing when one work
+ * finishes and before a new one is started.
  */
 int kthread_worker_fn(void *worker_ptr)
 {
 	struct kthread_worker *worker = worker_ptr;
 	struct kthread_work *work;
 
-	WARN_ON(worker->task);
+	/*
+	 * FIXME: Update the check and remove the assignment when all kthread
+	 * worker users are created using create_kthread_worker*() functions.
+	 */
+	WARN_ON(worker->task && worker->task != current);
 	worker->task = current;
 repeat:
 	set_current_state(TASK_INTERRUPTIBLE);	/* mb paired w/ kthread_stop */
@@ -617,6 +618,84 @@ repeat:
 }
 EXPORT_SYMBOL_GPL(kthread_worker_fn);
 
+static struct kthread_worker *
+__create_kthread_worker(int cpu, const char namefmt[], va_list args)
+{
+	struct kthread_worker *worker;
+	struct task_struct *task;
+
+	worker = kzalloc(sizeof(*worker), GFP_KERNEL);
+	if (!worker)
+		return ERR_PTR(-ENOMEM);
+
+	init_kthread_worker(worker);
+
+	if (cpu >= 0)
+		task = kthread_create_on_cpu(kthread_worker_fn, worker,
+					     cpu, namefmt);
+	else
+		task = __kthread_create_on_node(kthread_worker_fn, worker,
+						-1, namefmt, args);
+	if (IS_ERR(task))
+		goto fail_task;
+
+	worker->task = task;
+	wake_up_process(task);
+	return worker;
+
+fail_task:
+	kfree(worker);
+	return ERR_CAST(task);
+}
+
+/**
+ * create_kthread_worker - create a kthread worker
+ * @namefmt: printf-style name for the kthread worker (task).
+ *
+ * Returns pointer to an allocated worker on success, ERR_PTR(-ENOMEM) when
+ * the needed structures could not get allocated, and ERR_PTR(-EINTR) when
+ * the worker was SIGKILLed.
+ */
+struct kthread_worker *
+create_kthread_worker(const char namefmt[], ...)
+{
+	struct kthread_worker *worker;
+	va_list args;
+
+	va_start(args, namefmt);
+	worker = __create_kthread_worker(-1, namefmt, args);
+	va_end(args);
+
+	return worker;
+}
+EXPORT_SYMBOL(create_kthread_worker);
+
+/**
+ * create_kthread_worker_on_cpu - create a kthread worker and bind it
+ *	it to a given CPU and the associated NUMA node.
+ * @cpu: CPU number
+ * @namefmt: printf-style name for the kthread worker (task).
+ *
+ * Use a valid CPU number if you want to bind the kthread worker
+ * to the given CPU and the associated NUMA node.
+ *
+ * @namefmt might include one "%d" that will get replaced by CPU number.
+ *
+ * Returns pointer to allocated worker on success, ERR_PTR when the CPU
+ * number is not valid, ERR_PTR(-ENOMEM) when the needed structures could
+ * not get allocated, ERR_PTR(-EINTR) when the worker was SIGKILLed, and
+ * ERR_PTR(-EINVAL) on invalid @cpu.
+ */
+struct kthread_worker *
+create_kthread_worker_on_cpu(int cpu, const char namefmt[])
+{
+	if (cpu < 0 || cpu > num_possible_cpus())
+		return ERR_PTR(-EINVAL);
+
+	return __create_kthread_worker(cpu, namefmt, NULL);
+}
+EXPORT_SYMBOL(create_kthread_worker_on_cpu);
+
 /* insert @work before @pos in @worker */
 static void insert_kthread_work(struct kthread_worker *worker,
 			       struct kthread_work *work,
-- 
1.8.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
