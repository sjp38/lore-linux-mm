Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 3B8416B0255
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 09:05:06 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so113875901wic.1
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 06:05:05 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id lc2si30986397wjb.25.2015.09.21.06.05.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 21 Sep 2015 06:05:05 -0700 (PDT)
From: Petr Mladek <pmladek@suse.com>
Subject: [RFC v2 02/18] kthread: Add create_kthread_worker*()
Date: Mon, 21 Sep 2015 15:03:43 +0200
Message-Id: <1442840639-6963-3-git-send-email-pmladek@suse.com>
In-Reply-To: <1442840639-6963-1-git-send-email-pmladek@suse.com>
References: <1442840639-6963-1-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, live-patching@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>

Kthread workers are currently created using the classic kthread API,
namely kthread_run(). kthread_worker_fn() is passed as the @threadfn
parameter.

This patch defines create_kthread_worker_on_node() and
create_kthread_worker() functions that hide implementation details.

It enforces using kthread_worker_fn() for the main thread. But I doubt
that there are any plans to create any alternative. In fact, I think
that we do not want any alternative main thread because it would be
hard to support consistency with the rest of the kthread worker API.

The naming and function is inspired by the workqueues API like
the rest of the kthread worker API.

This patch does _not_ convert existing kthread workers. The kthread worker
API need more improvements first, e.g. a function to destroy the worker.

Signed-off-by: Petr Mladek <pmladek@suse.com>
---
 include/linux/kthread.h |  7 +++++++
 kernel/kthread.c        | 51 ++++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 57 insertions(+), 1 deletion(-)

diff --git a/include/linux/kthread.h b/include/linux/kthread.h
index e691b6a23f72..e390069a3f68 100644
--- a/include/linux/kthread.h
+++ b/include/linux/kthread.h
@@ -124,6 +124,13 @@ extern void __init_kthread_worker(struct kthread_worker *worker,
 
 int kthread_worker_fn(void *worker_ptr);
 
+__printf(2, 3)
+struct kthread_worker *
+create_kthread_worker_on_node(int node, const char namefmt[], ...);
+
+#define create_kthread_worker(namefmt, arg...)				\
+	create_kthread_worker_on_node(-1, namefmt, ##arg)
+
 bool queue_kthread_work(struct kthread_worker *worker,
 			struct kthread_work *work);
 void flush_kthread_work(struct kthread_work *work);
diff --git a/kernel/kthread.c b/kernel/kthread.c
index 1d29e675fe44..8f8813b42632 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -579,7 +579,11 @@ int kthread_worker_fn(void *worker_ptr)
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
@@ -613,6 +617,51 @@ repeat:
 }
 EXPORT_SYMBOL_GPL(kthread_worker_fn);
 
+/**
+ * create_kthread_worker_on_node - create a kthread worker.
+ * @node: memory node number.
+ * @namefmt: printf-style name for the kthread worker (task).
+ *
+ * If the worker is going to be bound on a particular CPU, give its node
+ * in @node, to get NUMA affinity for kthread stack, or else give -1.
+ *
+ * Returns pointer to allocated worker on success, ERR_PTR(-ENOMEM) when
+ * the needed structures could not get allocated, and ERR_PTR(-EINTR)
+ * when the worker was SIGKILLed.
+ */
+struct kthread_worker *
+create_kthread_worker_on_node(int node, const char namefmt[], ...)
+{
+	struct kthread_worker *worker;
+	struct task_struct *task;
+	va_list args;
+
+	worker = kzalloc(sizeof(*worker), GFP_KERNEL);
+	if (!worker)
+		return ERR_PTR(-ENOMEM);
+
+	init_kthread_worker(worker);
+
+	va_start(args, namefmt);
+	task = __kthread_create_on_node(kthread_worker_fn, worker, node,
+					namefmt, args);
+	va_end(args);
+
+	if (IS_ERR(task))
+		goto fail_task;
+
+	worker->task = task;
+	wake_up_process(task);
+
+	return worker;
+
+fail_task:
+	kfree(worker);
+	return ERR_CAST(task);
+
+}
+EXPORT_SYMBOL(create_kthread_worker_on_node);
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
