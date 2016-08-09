Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id B6FCF828F2
	for <linux-mm@kvack.org>; Tue,  9 Aug 2016 10:56:12 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id l4so24964398wml.0
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 07:56:12 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o198si3403582wmd.84.2016.08.09.07.56.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 09 Aug 2016 07:56:00 -0700 (PDT)
From: Petr Mladek <pmladek@suse.com>
Subject: [PATCH v10 05/11] kthread: Add kthread_create_worker*()
Date: Tue,  9 Aug 2016 16:55:39 +0200
Message-Id: <1470754545-17632-6-git-send-email-pmladek@suse.com>
In-Reply-To: <1470754545-17632-1-git-send-email-pmladek@suse.com>
References: <1470754545-17632-1-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>

Kthread workers are currently created using the classic kthread API,
namely kthread_run(). kthread_worker_fn() is passed as the @threadfn
parameter.

This patch defines kthread_create_worker() and
kthread_create_worker_on_cpu() functions that hide implementation details.

They enforce using kthread_worker_fn() for the main thread. But I doubt
that there are any plans to create any alternative. In fact, I think
that we do not want any alternative main thread because it would be
hard to support consistency with the rest of the kthread worker API.

The naming and function of kthread_create_worker() is inspired by
the workqueues API like the rest of the kthread worker API.

The kthread_create_worker_on_cpu() variant is motivated by the original
kthread_create_on_cpu(). Note that we need to bind per-CPU kthread
workers already when they are created. It makes the life easier.
kthread_bind() could not be used later for an already running worker.

This patch does _not_ convert existing kthread workers. The kthread worker
API need more improvements first, e.g. a function to destroy the worker.

IMPORTANT:

kthread_create_worker_on_cpu() allows to use any format of the
worker name, in compare with kthread_create_on_cpu(). The good thing
is that it is more generic. The bad thing is that most users will
need to pass the cpu number in two parameters, e.g.
kthread_create_worker_on_cpu(cpu, "helper/%d", cpu).

To be honest, the main motivation was to avoid the need for an
empty va_list. The only legal way was to create a helper function that
would be called with an empty list. Other attempts caused compilation
warnings or even errors on different architectures.

There were also other alternatives, for example, using #define or
splitting __kthread_create_worker(). The used solution looked
like the least ugly.

Signed-off-by: Petr Mladek <pmladek@suse.com>
Acked-by: Tejun Heo <tj@kernel.org>
---
 include/linux/kthread.h |   7 +++
 kernel/kthread.c        | 113 +++++++++++++++++++++++++++++++++++++++++++-----
 2 files changed, 110 insertions(+), 10 deletions(-)

diff --git a/include/linux/kthread.h b/include/linux/kthread.h
index e2b095b8ca47..daeb2befbabf 100644
--- a/include/linux/kthread.h
+++ b/include/linux/kthread.h
@@ -124,6 +124,13 @@ extern void __kthread_init_worker(struct kthread_worker *worker,
 
 int kthread_worker_fn(void *worker_ptr);
 
+__printf(1, 2)
+struct kthread_worker *
+kthread_create_worker(const char namefmt[], ...);
+
+struct kthread_worker *
+kthread_create_worker_on_cpu(int cpu, const char namefmt[], ...);
+
 bool kthread_queue_work(struct kthread_worker *worker,
 			struct kthread_work *work);
 void kthread_flush_work(struct kthread_work *work);
diff --git a/kernel/kthread.c b/kernel/kthread.c
index b7a7675b6e84..d9ba5e229cd3 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -567,23 +567,24 @@ EXPORT_SYMBOL_GPL(__kthread_init_worker);
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
+	 * worker users are created using kthread_create_worker*() functions.
+	 */
+	WARN_ON(worker->task && worker->task != current);
 	worker->task = current;
 repeat:
 	set_current_state(TASK_INTERRUPTIBLE);	/* mb paired w/ kthread_stop */
@@ -617,6 +618,98 @@ repeat:
 }
 EXPORT_SYMBOL_GPL(kthread_worker_fn);
 
+static struct kthread_worker *
+__kthread_create_worker(int cpu, const char namefmt[], va_list args)
+{
+	struct kthread_worker *worker;
+	struct task_struct *task;
+
+	worker = kzalloc(sizeof(*worker), GFP_KERNEL);
+	if (!worker)
+		return ERR_PTR(-ENOMEM);
+
+	kthread_init_worker(worker);
+
+	if (cpu >= 0) {
+		char name[TASK_COMM_LEN];
+
+		/*
+		 * kthread_create_worker_on_cpu() allows to pass a generic
+		 * namefmt in compare with kthread_create_on_cpu. We need
+		 * to format it here.
+		 */
+		vsnprintf(name, sizeof(name), namefmt, args);
+		task = kthread_create_on_cpu(kthread_worker_fn, worker,
+					     cpu, name);
+	} else {
+		task = __kthread_create_on_node(kthread_worker_fn, worker,
+						-1, namefmt, args);
+	}
+
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
+ * kthread_create_worker - create a kthread worker
+ * @namefmt: printf-style name for the kthread worker (task).
+ *
+ * Returns a pointer to the allocated worker on success, ERR_PTR(-ENOMEM)
+ * when the needed structures could not get allocated, and ERR_PTR(-EINTR)
+ * when the worker was SIGKILLed.
+ */
+struct kthread_worker *
+kthread_create_worker(const char namefmt[], ...)
+{
+	struct kthread_worker *worker;
+	va_list args;
+
+	va_start(args, namefmt);
+	worker = __kthread_create_worker(-1, namefmt, args);
+	va_end(args);
+
+	return worker;
+}
+EXPORT_SYMBOL(kthread_create_worker);
+
+/**
+ * kthread_create_worker_on_cpu - create a kthread worker and bind it
+ *	it to a given CPU and the associated NUMA node.
+ * @cpu: CPU number
+ * @namefmt: printf-style name for the kthread worker (task).
+ *
+ * Use a valid CPU number if you want to bind the kthread worker
+ * to the given CPU and the associated NUMA node.
+ *
+ * A good practice is to add the cpu number also into the worker name.
+ * For example, use kthread_create_worker_on_cpu(cpu, "helper/%d", cpu).
+ *
+ * Returns a pointer to the allocated worker on success, ERR_PTR(-ENOMEM)
+ * when the needed structures could not get allocated, and ERR_PTR(-EINTR)
+ * when the worker was SIGKILLed.
+ */
+struct kthread_worker *
+kthread_create_worker_on_cpu(int cpu, const char namefmt[], ...)
+{
+	struct kthread_worker *worker;
+	va_list args;
+
+	va_start(args, namefmt);
+	worker = __kthread_create_worker(cpu, namefmt, args);
+	va_end(args);
+
+	return worker;
+}
+EXPORT_SYMBOL(kthread_create_worker_on_cpu);
+
 /* insert @work before @pos in @worker */
 static void kthread_insert_work(struct kthread_worker *worker,
 			       struct kthread_work *work,
-- 
1.8.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
