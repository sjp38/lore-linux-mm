Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id B0B7B6B0255
	for <linux-mm@kvack.org>; Tue, 28 Jul 2015 10:40:04 -0400 (EDT)
Received: by wibud3 with SMTP id ud3so183893001wib.1
        for <linux-mm@kvack.org>; Tue, 28 Jul 2015 07:40:04 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fm10si37495758wjc.203.2015.07.28.07.40.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Jul 2015 07:40:03 -0700 (PDT)
From: Petr Mladek <pmladek@suse.com>
Subject: [RFC PATCH 02/14] kthread: Add create_kthread_worker*()
Date: Tue, 28 Jul 2015 16:39:19 +0200
Message-Id: <1438094371-8326-3-git-send-email-pmladek@suse.com>
In-Reply-To: <1438094371-8326-1-git-send-email-pmladek@suse.com>
References: <1438094371-8326-1-git-send-email-pmladek@suse.com>
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

The naming is inspired by the workqueues API like the reset of the
kthread worker API.

This patch does _not_ convert existing kthread workers. The kthread worker
API need more improvements first, e.g. a function to destroy the worker.
We should not need to access @worker->task and other struct kthread_worker
members directly.

Signed-off-by: Petr Mladek <pmladek@suse.com>
---
 include/linux/kthread.h |  8 ++++++++
 kernel/kthread.c        | 43 ++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 50 insertions(+), 1 deletion(-)

diff --git a/include/linux/kthread.h b/include/linux/kthread.h
index 13d55206ccf6..fc8a7d253c40 100644
--- a/include/linux/kthread.h
+++ b/include/linux/kthread.h
@@ -123,6 +123,14 @@ extern void __init_kthread_worker(struct kthread_worker *worker,
 
 int kthread_worker_fn(void *worker_ptr);
 
+__printf(3, 4)
+int create_kthread_worker_on_node(struct kthread_worker *worker,
+				  int node,
+				  const char namefmt[], ...);
+
+#define create_kthread_worker(worker, namefmt, arg...)			\
+	create_kthread_worker_on_node(worker, -1, namefmt, ##arg)
+
 bool queue_kthread_work(struct kthread_worker *worker,
 			struct kthread_work *work);
 void flush_kthread_work(struct kthread_work *work);
diff --git a/kernel/kthread.c b/kernel/kthread.c
index fca7cd124512..fe9421728f76 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -561,7 +561,11 @@ int kthread_worker_fn(void *worker_ptr)
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
@@ -595,6 +599,43 @@ repeat:
 }
 EXPORT_SYMBOL_GPL(kthread_worker_fn);
 
+/**
+ * create_kthread_worker_on_node - create a kthread worker.
+ * @worker: initialized kthread worker struct.
+ * @node: memory node number.
+ * @namefmt: printf-style name for the kthread worker (task).
+ *
+ * If the worker is going to be bound on a particular CPU, give its node
+ * in @node, to get NUMA affinity for kthread stack, or else give -1.
+ */
+int create_kthread_worker_on_node(struct kthread_worker *worker,
+				  int node,
+				  const char namefmt[], ...)
+{
+	struct task_struct *task;
+	va_list args;
+
+	if (worker->task)
+		return -EINVAL;
+
+	va_start(args, namefmt);
+	task = __kthread_create_on_node(kthread_worker_fn, worker, node,
+					namefmt, args);
+	va_end(args);
+
+	if (IS_ERR(task))
+		return PTR_ERR(task);
+
+	spin_lock_irq(&worker->lock);
+	worker->task = task;
+	spin_unlock_irq(&worker->lock);
+
+	wake_up_process(task);
+
+	return 0;
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
