Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 5FE06828E2
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 10:48:03 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id u188so71232580wmu.1
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 07:48:03 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id jv3si29145045wjc.149.2016.01.25.07.48.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 25 Jan 2016 07:48:02 -0800 (PST)
From: Petr Mladek <pmladek@suse.com>
Subject: [PATCH v4 09/22] kthread: Allow to cancel kthread work
Date: Mon, 25 Jan 2016 16:44:58 +0100
Message-Id: <1453736711-6703-10-git-send-email-pmladek@suse.com>
In-Reply-To: <1453736711-6703-1-git-send-email-pmladek@suse.com>
References: <1453736711-6703-1-git-send-email-pmladek@suse.com>
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

First, we try to lock the work. If it does not work, it means that
no worker is assigned and that we are done.

Second, we try to cancel the timer when it exists. The timer is deleted
synchronously to make sure that the timer call back is not running.
We hold the worker->lock at this point. To avoid a possible race,
the timer callback need to use a modified variant of try_lock_kthread_work()
and give up spinning when the canceling flag is set.

Third, we try to remove the work from the worker list.

Fourth, if the work is running, we call flush_kthread_work(). It might
take an arbitrary time. In the meantime, queuing of the work is blocked
by the new canceling counter.

As already mentioned, the check for a pending kthread work is done under
a lock. In compare with workqueues, we do not need to fight for a single
PENDING bit to block other operations. Therefore do not suffer from
the thundering storm problem and all parallel canceling jobs might use
kthread_work_flush(). Any queuing is blocked until the counter is zero.

Signed-off-by: Petr Mladek <pmladek@suse.com>
---
 include/linux/kthread.h |   4 ++
 kernel/kthread.c        | 154 ++++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 154 insertions(+), 4 deletions(-)

diff --git a/include/linux/kthread.h b/include/linux/kthread.h
index 1a5738dcdf8d..dd2a587a2bd7 100644
--- a/include/linux/kthread.h
+++ b/include/linux/kthread.h
@@ -77,6 +77,7 @@ struct kthread_work {
 	kthread_work_func_t	func;
 	struct kthread_worker	*worker;
 	struct timer_list	*timer;
+	int			canceling;
 };
 
 struct delayed_kthread_work {
@@ -170,6 +171,9 @@ bool queue_delayed_kthread_work(struct kthread_worker *worker,
 void flush_kthread_work(struct kthread_work *work);
 void flush_kthread_worker(struct kthread_worker *worker);
 
+bool cancel_kthread_work_sync(struct kthread_work *work);
+bool cancel_delayed_kthread_work_sync(struct delayed_kthread_work *work);
+
 void destroy_kthread_worker(struct kthread_worker *worker);
 
 #endif /* _LINUX_KTHREAD_H */
diff --git a/kernel/kthread.c b/kernel/kthread.c
index 6933d90c0fec..6e2eeca08d5f 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -567,6 +567,7 @@ EXPORT_SYMBOL_GPL(__init_kthread_worker);
  * Returns true when there is a pending operation for this work.
  * In particular, it checks if the work is:
  *	- queued
+ *	- being cancelled
  *	- a timer is running to queue this delayed work
  *
  * This function must be called with locked work.
@@ -574,6 +575,7 @@ EXPORT_SYMBOL_GPL(__init_kthread_worker);
 static inline bool kthread_work_pending(const struct kthread_work *work)
 {
 	return !list_empty(&work->node) ||
+	       work->canceling ||
 	       (work->timer && timer_active(work->timer));
 }
 
@@ -779,7 +781,13 @@ bool queue_kthread_work(struct kthread_worker *worker,
 }
 EXPORT_SYMBOL_GPL(queue_kthread_work);
 
-static bool try_lock_kthread_work(struct kthread_work *work)
+/*
+ * Get the worker lock if any worker is associated with the work.
+ * Depending on @check_canceling, it might need to give up the busy
+ * wait when work->canceling gets set.
+ */
+static bool try_lock_kthread_work(struct kthread_work *work,
+				  bool check_canceling)
 {
 	struct kthread_worker *worker;
 	int ret = false;
@@ -790,7 +798,24 @@ try_again:
 	if (!worker)
 		goto out;
 
-	spin_lock(&worker->lock);
+	if (check_canceling) {
+		if (!spin_trylock(&worker->lock)) {
+			/*
+			 * Busy wait with spin_is_locked() to avoid
+			 * cache bouncing. Break when canceling
+			 * is set to avoid a deadlock.
+			 */
+			do {
+				if (READ_ONCE(work->canceling))
+					goto out;
+				cpu_relax();
+			} while (spin_is_locked(&worker->lock));
+			goto try_again;
+		}
+	} else {
+		spin_lock(&worker->lock);
+	}
+
 	if (worker != work->worker) {
 		spin_unlock(&worker->lock);
 		goto try_again;
@@ -820,10 +845,13 @@ void delayed_kthread_work_timer_fn(unsigned long __data)
 		(struct delayed_kthread_work *)__data;
 	struct kthread_work *work = &dwork->work;
 
-	if (!try_lock_kthread_work(work))
+	/* Give up when the work is being canceled. */
+	if (!try_lock_kthread_work(work, true))
 		return;
 
-	__queue_kthread_work(work->worker, work);
+	if (!work->canceling)
+		__queue_kthread_work(work->worker, work);
+
 	unlock_kthread_work(work);
 }
 EXPORT_SYMBOL(delayed_kthread_work_timer_fn);
@@ -947,6 +975,124 @@ retry:
 EXPORT_SYMBOL_GPL(flush_kthread_work);
 
 /**
+ * try_to_cancel_kthread_work - Try to cancel kthread work.
+ * @work: work item to cancel
+ * @lock: lock used to protect the work
+ * @flags: flags stored when the lock was taken
+ *
+ * This function tries to cancel the given kthread work by deleting
+ * the timer and by removing the work from the queue.
+ *
+ * If the timer callback is in progress, it waits until it finishes
+ * but it has to drop the lock to avoid a deadlock.
+ *
+ * Return:
+ *  1		if @work was pending and successfully canceled
+ *  0		if @work was not pending
+ */
+static int
+try_to_cancel_kthread_work(struct kthread_work *work,
+				   spinlock_t *lock,
+				   unsigned long *flags)
+{
+	int ret = 0;
+
+	/* Try to cancel the timer if pending. */
+	if (work->timer && del_timer_sync(work->timer)) {
+		ret = 1;
+		goto out;
+	}
+
+	/* Try to remove queued work before it is being executed. */
+	if (!list_empty(&work->node)) {
+		list_del_init(&work->node);
+		ret = 1;
+	}
+
+out:
+	return ret;
+}
+
+static bool __cancel_kthread_work_sync(struct kthread_work *work)
+{
+	struct kthread_worker *worker;
+	unsigned long flags;
+	int ret;
+
+	local_irq_save(flags);
+	if (!try_lock_kthread_work(work, false)) {
+		local_irq_restore(flags);
+		ret = 0;
+		goto out;
+	}
+	worker = work->worker;
+
+	/*
+	 * Block further queueing. It must be set before trying to cancel
+	 * the kthread work. It avoids a possible deadlock between
+	 * del_timer_sync() and the timer callback.
+	 */
+	work->canceling++;
+	ret = try_to_cancel_kthread_work(work, &worker->lock, &flags);
+
+	if (worker->current_work != work)
+		goto out_fast;
+
+	spin_unlock_irqrestore(&worker->lock, flags);
+	flush_kthread_work(work);
+	/*
+	 * Nobody is allowed to switch the worker or queue the work
+	 * when .canceling is set.
+	 */
+	spin_lock_irqsave(&worker->lock, flags);
+
+out_fast:
+	work->canceling--;
+	spin_unlock_irqrestore(&worker->lock, flags);
+out:
+	return ret;
+}
+
+/**
+ * cancel_kthread_work_sync - cancel a kthread work and wait for it to finish
+ * @work: the kthread work to cancel
+ *
+ * Cancel @work and wait for its execution to finish.  This function
+ * can be used even if the work re-queues itself. On return from this
+ * function, @work is guaranteed to be not pending or executing on any CPU.
+ *
+ * The caller must ensure that the worker on which @work was last
+ * queued can't be destroyed before this function returns.
+ *
+ * Return:
+ * %true if @work was pending, %false otherwise.
+ */
+bool cancel_kthread_work_sync(struct kthread_work *work)
+{
+	/* Rather use cancel_delayed_kthread_work() for delayed works. */
+	WARN_ON_ONCE(work->timer);
+
+	return __cancel_kthread_work_sync(work);
+}
+EXPORT_SYMBOL_GPL(cancel_kthread_work_sync);
+
+/**
+ * cancel_delayed_kthread_work_sync - cancel a delayed kthread work and
+ *	wait for it to finish.
+ * @dwork: the delayed kthread work to cancel
+ *
+ * This is cancel_kthread_work_sync() for delayed works.
+ *
+ * Return:
+ * %true if @dwork was pending, %false otherwise.
+ */
+bool cancel_delayed_kthread_work_sync(struct delayed_kthread_work *dwork)
+{
+	return __cancel_kthread_work_sync(&dwork->work);
+}
+EXPORT_SYMBOL_GPL(cancel_delayed_kthread_work_sync);
+
+/**
  * flush_kthread_worker - flush all current works on a kthread_worker
  * @worker: worker to flush
  *
-- 
1.8.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
