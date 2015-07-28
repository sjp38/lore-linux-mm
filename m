Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 4F7606B0256
	for <linux-mm@kvack.org>; Tue, 28 Jul 2015 10:40:06 -0400 (EDT)
Received: by wibud3 with SMTP id ud3so183894078wib.1
        for <linux-mm@kvack.org>; Tue, 28 Jul 2015 07:40:05 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j8si1179977wjn.105.2015.07.28.07.40.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Jul 2015 07:40:04 -0700 (PDT)
From: Petr Mladek <pmladek@suse.com>
Subject: [RFC PATCH 03/14] kthread: Add drain_kthread_worker()
Date: Tue, 28 Jul 2015 16:39:20 +0200
Message-Id: <1438094371-8326-4-git-send-email-pmladek@suse.com>
In-Reply-To: <1438094371-8326-1-git-send-email-pmladek@suse.com>
References: <1438094371-8326-1-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, live-patching@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>

flush_kthread_worker() returns when the currently queued works are proceed.
But some other works might have been queued in the meantime.

This patch adds drain_kthread_work() that is inspired by drain_workqueue().
It returns when the queue is completely empty. Also it affects the behavior
of queue_kthread_work(). Only currently running work is allowed to queue
another work when the draining is in progress. A warning is printed when
some work is being queued from other context or when the draining takes
too long.

Note that drain() will typically be called when the queue should stay
empty, e.g. when the worker is going to be destroyed. In this case,
the caller should block all users from producing more work. This is
why the warning is printed. But some more works might be needed
to proceed the already existing works. This is why re-queuing
is allowed.

Callers also have to block existing works from an infinite re-queuing.

Signed-off-by: Petr Mladek <pmladek@suse.com>
---
 include/linux/kthread.h |   1 +
 kernel/kthread.c        | 121 ++++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 117 insertions(+), 5 deletions(-)

diff --git a/include/linux/kthread.h b/include/linux/kthread.h
index fc8a7d253c40..974d70193907 100644
--- a/include/linux/kthread.h
+++ b/include/linux/kthread.h
@@ -68,6 +68,7 @@ struct kthread_worker {
 	struct list_head	work_list;
 	struct task_struct	*task;
 	struct kthread_work	*current_work;
+	int			nr_drainers;
 };
 
 struct kthread_work {
diff --git a/kernel/kthread.c b/kernel/kthread.c
index fe9421728f76..872f17e383c4 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -51,6 +51,7 @@ enum KTHREAD_BITS {
 	KTHREAD_SHOULD_STOP,
 	KTHREAD_SHOULD_PARK,
 	KTHREAD_IS_PARKED,
+	KTHREAD_IS_WORKER,
 };
 
 #define __to_kthread(vfork)	\
@@ -538,6 +539,7 @@ void __init_kthread_worker(struct kthread_worker *worker,
 	lockdep_set_class_and_name(&worker->lock, key, name);
 	INIT_LIST_HEAD(&worker->work_list);
 	worker->task = NULL;
+	worker->nr_drainers = 0;
 }
 EXPORT_SYMBOL_GPL(__init_kthread_worker);
 
@@ -613,6 +615,7 @@ int create_kthread_worker_on_node(struct kthread_worker *worker,
 				  const char namefmt[], ...)
 {
 	struct task_struct *task;
+	struct kthread *kthread;
 	va_list args;
 
 	if (worker->task)
@@ -626,6 +629,9 @@ int create_kthread_worker_on_node(struct kthread_worker *worker,
 	if (IS_ERR(task))
 		return PTR_ERR(task);
 
+	kthread = to_kthread(task);
+	set_bit(KTHREAD_IS_WORKER, &kthread->flags);
+
 	spin_lock_irq(&worker->lock);
 	worker->task = task;
 	spin_unlock_irq(&worker->lock);
@@ -649,6 +655,56 @@ static void insert_kthread_work(struct kthread_worker *worker,
 		wake_up_process(worker->task);
 }
 
+/*
+ * Queue @work without the check for drainers.
+ * Must be called under @worker->lock.
+ */
+static bool __queue_kthread_work(struct kthread_worker *worker,
+			  struct kthread_work *work)
+{
+	lockdep_assert_held(&worker->lock);
+
+	if (list_empty(&work->node)) {
+		insert_kthread_work(worker, work, &worker->work_list);
+		return true;
+	}
+
+	return false;
+}
+
+/* return struct kthread_worker if %current is a kthread worker */
+static struct kthread_worker *current_kthread_worker(void)
+{
+	struct kthread *k;
+
+	if (!(current->flags & PF_KTHREAD))
+		goto fail;
+
+	k = to_kthread(current);
+	if (test_bit(KTHREAD_IS_WORKER, &k->flags))
+		return k->data;
+
+fail:
+	return NULL;
+}
+
+
+/*
+ * Test whether @work is being queued from another work
+ * executing on the same kthread.
+ */
+static bool is_chained_work(struct kthread_worker *worker)
+{
+	struct kthread_worker *current_worker;
+
+	current_worker = current_kthread_worker();
+	/*
+	 * Return %true if I'm a kthread worker executing a work item on
+	 * the given @worker.
+	 */
+	return current_worker && current_worker == worker;
+}
+
 /**
  * queue_kthread_work - queue a kthread_work
  * @worker: target kthread_worker
@@ -665,10 +721,14 @@ bool queue_kthread_work(struct kthread_worker *worker,
 	unsigned long flags;
 
 	spin_lock_irqsave(&worker->lock, flags);
-	if (list_empty(&work->node)) {
-		insert_kthread_work(worker, work, &worker->work_list);
-		ret = true;
-	}
+
+	/* if draining, only works from the same kthread worker are allowed */
+	if (unlikely(worker->nr_drainers) &&
+	    WARN_ON_ONCE(!is_chained_work(worker)))
+		goto fail;
+
+	ret = __queue_kthread_work(worker, work);
+fail:
 	spin_unlock_irqrestore(&worker->lock, flags);
 	return ret;
 }
@@ -740,7 +800,58 @@ void flush_kthread_worker(struct kthread_worker *worker)
 		COMPLETION_INITIALIZER_ONSTACK(fwork.done),
 	};
 
-	queue_kthread_work(worker, &fwork.work);
+	/* flush() is and can be used when draining */
+	spin_lock_irq(&worker->lock);
+	__queue_kthread_work(worker, &fwork.work);
+	spin_unlock_irq(&worker->lock);
+
 	wait_for_completion(&fwork.done);
 }
 EXPORT_SYMBOL_GPL(flush_kthread_worker);
+
+/**
+ * drain_kthread_worker - drain a kthread worker
+ * @worker: worker to be drained
+ *
+ * Wait until there is none work queued for the given kthread worker.
+ * Only currently running work on @worker can queue further work items
+ * on it.  @worker is flushed repeatedly until it becomes empty.
+ * The number of flushing is determined by the depth of chaining
+ * and should be relatively short.  Whine if it takes too long.
+ *
+ * The caller is responsible for blocking all existing works
+ * from an infinite re-queuing!
+ *
+ * Also the caller is responsible for blocking all the kthread
+ * worker users from queuing any new work. It is especially
+ * important if the queue has to stay empty once this function
+ * finishes.
+ */
+void drain_kthread_worker(struct kthread_worker *worker)
+{
+	int flush_cnt = 0;
+
+	spin_lock_irq(&worker->lock);
+	worker->nr_drainers++;
+
+	while (!list_empty(&worker->work_list)) {
+		/*
+		 * Unlock, so we could move forward. Note that queuing
+		 * is limited by @nr_drainers > 0.
+		 */
+		spin_unlock_irq(&worker->lock);
+
+		flush_kthread_worker(worker);
+
+		if (++flush_cnt == 10 ||
+		    (flush_cnt % 100 == 0 && flush_cnt <= 1000))
+			pr_warn("kthread worker %s: drain_kthread_worker() isn't complete after %u tries\n",
+				worker->task->comm, flush_cnt);
+
+		spin_lock_irq(&worker->lock);
+	}
+
+	worker->nr_drainers--;
+	spin_unlock_irq(&worker->lock);
+}
+EXPORT_SYMBOL(drain_kthread_worker);
-- 
1.8.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
