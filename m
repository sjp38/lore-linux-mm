Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id E4931828F2
	for <linux-mm@kvack.org>; Tue,  9 Aug 2016 10:56:21 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 1so24966049wmz.2
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 07:56:21 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i71si3432940wme.14.2016.08.09.07.56.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 09 Aug 2016 07:56:01 -0700 (PDT)
From: Petr Mladek <pmladek@suse.com>
Subject: [PATCH v10 09/11] kthread: Allow to cancel kthread work
Date: Tue,  9 Aug 2016 16:55:43 +0200
Message-Id: <1470754545-17632-10-git-send-email-pmladek@suse.com>
In-Reply-To: <1470754545-17632-1-git-send-email-pmladek@suse.com>
References: <1470754545-17632-1-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>

We are going to use kthread workers more widely and sometimes we will need
to make sure that the work is neither pending nor running.

This patch implements cancel_*_sync() operations as inspired by
workqueues. Well, we are synchronized against the other operations
via the worker lock, we use del_timer_sync() and a counter to count
parallel cancel operations. Therefore the implementation might be easier.

First, we check if a worker is assigned. If not, the work has newer
been queued after it was initialized.

Second, we take the worker lock. It must be the right one. The work must
not be assigned to another worker unless it is initialized in between.

Third, we try to cancel the timer when it exists. The timer is deleted
synchronously to make sure that the timer call back is not running.
We need to temporary release the worker->lock to avoid a possible
deadlock with the callback. In the meantime, we set work->canceling
counter to avoid any queuing.

Fourth, we try to remove the work from a worker list. It might be
the list of either normal or delayed works.

Fifth, if the work is running, we call kthread_flush_work(). It might
take an arbitrary time. We need to release the worker-lock again.
In the meantime, we again block any queuing by the canceling counter.

As already mentioned, the check for a pending kthread work is done under
a lock. In compare with workqueues, we do not need to fight for a single
PENDING bit to block other operations. Therefore we do not suffer from
the thundering storm problem and all parallel canceling jobs might use
kthread_flush_work(). Any queuing is blocked until the counter gets zero.

Signed-off-by: Petr Mladek <pmladek@suse.com>
Acked-by: Tejun Heo <tj@kernel.org>
---
 include/linux/kthread.h |   5 ++
 kernel/kthread.c        | 132 +++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 135 insertions(+), 2 deletions(-)

diff --git a/include/linux/kthread.h b/include/linux/kthread.h
index 4acde1ae2228..77435dcde707 100644
--- a/include/linux/kthread.h
+++ b/include/linux/kthread.h
@@ -77,6 +77,8 @@ struct kthread_work {
 	struct list_head	node;
 	kthread_work_func_t	func;
 	struct kthread_worker	*worker;
+	/* Number of canceling calls that are running at the moment. */
+	int			canceling;
 };
 
 struct kthread_delayed_work {
@@ -169,6 +171,9 @@ bool kthread_queue_delayed_work(struct kthread_worker *worker,
 void kthread_flush_work(struct kthread_work *work);
 void kthread_flush_worker(struct kthread_worker *worker);
 
+bool kthread_cancel_work_sync(struct kthread_work *work);
+bool kthread_cancel_delayed_work_sync(struct kthread_delayed_work *work);
+
 void kthread_destroy_worker(struct kthread_worker *worker);
 
 #endif /* _LINUX_KTHREAD_H */
diff --git a/kernel/kthread.c b/kernel/kthread.c
index 647b60cc5f90..526646971ec1 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -714,6 +714,19 @@ kthread_create_worker_on_cpu(int cpu, const char namefmt[], ...)
 }
 EXPORT_SYMBOL(kthread_create_worker_on_cpu);
 
+/*
+ * Returns true when the work could not be queued at the moment.
+ * It happens when it is already pending in a worker list
+ * or when it is being cancelled.
+ */
+static inline bool queuing_blocked(struct kthread_worker *worker,
+				   struct kthread_work *work)
+{
+	lockdep_assert_held(&worker->lock);
+
+	return !list_empty(&work->node) || work->canceling;
+}
+
 static void kthread_insert_work_sanity_check(struct kthread_worker *worker,
 					     struct kthread_work *work)
 {
@@ -755,7 +768,7 @@ bool kthread_queue_work(struct kthread_worker *worker,
 	unsigned long flags;
 
 	spin_lock_irqsave(&worker->lock, flags);
-	if (list_empty(&work->node)) {
+	if (!queuing_blocked(worker, work)) {
 		kthread_insert_work(worker, work, &worker->work_list);
 		ret = true;
 	}
@@ -855,7 +868,7 @@ bool kthread_queue_delayed_work(struct kthread_worker *worker,
 
 	spin_lock_irqsave(&worker->lock, flags);
 
-	if (list_empty(&work->node)) {
+	if (!queuing_blocked(worker, work)) {
 		__kthread_queue_delayed_work(worker, dwork, delay);
 		ret = true;
 	}
@@ -915,6 +928,121 @@ void kthread_flush_work(struct kthread_work *work)
 }
 EXPORT_SYMBOL_GPL(kthread_flush_work);
 
+/*
+ * This function removes the work from the worker queue. Also it makes sure
+ * that it won't get queued later via the delayed work's timer.
+ *
+ * The work might still be in use when this function finishes. See the
+ * current_work proceed by the worker.
+ *
+ * Return: %true if @work was pending and successfully canceled,
+ *	%false if @work was not pending
+ */
+static bool __kthread_cancel_work(struct kthread_work *work, bool is_dwork,
+				  unsigned long *flags)
+{
+	/* Try to cancel the timer if exists. */
+	if (is_dwork) {
+		struct kthread_delayed_work *dwork =
+			container_of(work, struct kthread_delayed_work, work);
+		struct kthread_worker *worker = work->worker;
+
+		/*
+		 * del_timer_sync() must be called to make sure that the timer
+		 * callback is not running. The lock must be temporary released
+		 * to avoid a deadlock with the callback. In the meantime,
+		 * any queuing is blocked by setting the canceling counter.
+		 */
+		work->canceling++;
+		spin_unlock_irqrestore(&worker->lock, *flags);
+		del_timer_sync(&dwork->timer);
+		spin_lock_irqsave(&worker->lock, *flags);
+		work->canceling--;
+	}
+
+	/*
+	 * Try to remove the work from a worker list. It might either
+	 * be from worker->work_list or from worker->delayed_work_list.
+	 */
+	if (!list_empty(&work->node)) {
+		list_del_init(&work->node);
+		return true;
+	}
+
+	return false;
+}
+
+static bool __kthread_cancel_work_sync(struct kthread_work *work, bool is_dwork)
+{
+	struct kthread_worker *worker = work->worker;
+	unsigned long flags;
+	int ret = false;
+
+	if (!worker)
+		goto out;
+
+	spin_lock_irqsave(&worker->lock, flags);
+	/* Work must not be used with >1 worker, see kthread_queue_work(). */
+	WARN_ON_ONCE(work->worker != worker);
+
+	ret = __kthread_cancel_work(work, is_dwork, &flags);
+
+	if (worker->current_work != work)
+		goto out_fast;
+
+	/*
+	 * The work is in progress and we need to wait with the lock released.
+	 * In the meantime, block any queuing by setting the canceling counter.
+	 */
+	work->canceling++;
+	spin_unlock_irqrestore(&worker->lock, flags);
+	kthread_flush_work(work);
+	spin_lock_irqsave(&worker->lock, flags);
+	work->canceling--;
+
+out_fast:
+	spin_unlock_irqrestore(&worker->lock, flags);
+out:
+	return ret;
+}
+
+/**
+ * kthread_cancel_work_sync - cancel a kthread work and wait for it to finish
+ * @work: the kthread work to cancel
+ *
+ * Cancel @work and wait for its execution to finish.  This function
+ * can be used even if the work re-queues itself. On return from this
+ * function, @work is guaranteed to be not pending or executing on any CPU.
+ *
+ * kthread_cancel_work_sync(&delayed_work->work) must not be used for
+ * delayed_work's. Use kthread_cancel_delayed_work_sync() instead.
+ *
+ * The caller must ensure that the worker on which @work was last
+ * queued can't be destroyed before this function returns.
+ *
+ * Return: %true if @work was pending, %false otherwise.
+ */
+bool kthread_cancel_work_sync(struct kthread_work *work)
+{
+	return __kthread_cancel_work_sync(work, false);
+}
+EXPORT_SYMBOL_GPL(kthread_cancel_work_sync);
+
+/**
+ * kthread_cancel_delayed_work_sync - cancel a kthread delayed work and
+ *	wait for it to finish.
+ * @dwork: the kthread delayed work to cancel
+ *
+ * This is kthread_cancel_work_sync() for delayed works.
+ *
+ * Return: %true if @dwork was pending, %false otherwise.
+ */
+bool kthread_cancel_delayed_work_sync(struct kthread_delayed_work *dwork)
+{
+	return __kthread_cancel_work_sync(&dwork->work, true);
+}
+EXPORT_SYMBOL_GPL(kthread_cancel_delayed_work_sync);
+
 /**
  * kthread_flush_worker - flush all current works on a kthread_worker
  * @worker: worker to flush
-- 
1.8.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
