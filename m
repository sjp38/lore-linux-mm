Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 436E5828F2
	for <linux-mm@kvack.org>; Mon, 22 Feb 2016 09:58:13 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id c200so175489759wme.0
        for <linux-mm@kvack.org>; Mon, 22 Feb 2016 06:58:13 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w19si33135334wmd.62.2016.02.22.06.58.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 22 Feb 2016 06:58:12 -0800 (PST)
From: Petr Mladek <pmladek@suse.com>
Subject: [PATCH v5 08/20] kthread: Allow to cancel kthread work
Date: Mon, 22 Feb 2016 15:56:58 +0100
Message-Id: <1456153030-12400-9-git-send-email-pmladek@suse.com>
In-Reply-To: <1456153030-12400-1-git-send-email-pmladek@suse.com>
References: <1456153030-12400-1-git-send-email-pmladek@suse.com>
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
We hold the worker->lock at this point. To avoid a possible deadlock,
the timer callback need to check work->canceling counter and give up
when it has a non-zero value.

Fourth, we try to remove the work from a worker list. It might be
the list of normal or delayed works. Note that the work is in
the delayed list when the timer callback raced with del_timer_sync()
and was unable to move the work.

Fifth, if the work is running, we call flush_kthread_work(). It might
take an arbitrary time. In the meantime, queuing of the work is blocked
by the new canceling counter.

As already mentioned, the check for a pending kthread work is done under
a lock. In compare with workqueues, we do not need to fight for a single
PENDING bit to block other operations. Therefore do not suffer from
the thundering storm problem and all parallel canceling jobs might use
kthread_work_flush(). Any queuing is blocked until the counter is zero.

Signed-off-by: Petr Mladek <pmladek@suse.com>
---
 include/linux/kthread.h |   5 ++
 kernel/kthread.c        | 146 +++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 148 insertions(+), 3 deletions(-)

diff --git a/include/linux/kthread.h b/include/linux/kthread.h
index 6e37b169e8b6..28ea12942878 100644
--- a/include/linux/kthread.h
+++ b/include/linux/kthread.h
@@ -77,6 +77,8 @@ struct kthread_work {
 	struct list_head	node;
 	kthread_work_func_t	func;
 	struct kthread_worker	*worker;
+	/* Number of canceling calls that are running at the moment. */
+	int			canceling;
 };
 
 struct delayed_kthread_work {
@@ -169,6 +171,9 @@ bool queue_delayed_kthread_work(struct kthread_worker *worker,
 void flush_kthread_work(struct kthread_work *work);
 void flush_kthread_worker(struct kthread_worker *worker);
 
+bool cancel_kthread_work_sync(struct kthread_work *work);
+bool cancel_delayed_kthread_work_sync(struct delayed_kthread_work *work);
+
 void destroy_kthread_worker(struct kthread_worker *worker);
 
 #endif /* _LINUX_KTHREAD_H */
diff --git a/kernel/kthread.c b/kernel/kthread.c
index 44c675f3bf8e..7e6c921b2a9a 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -696,6 +696,18 @@ create_kthread_worker_on_cpu(int cpu, const char namefmt[])
 }
 EXPORT_SYMBOL(create_kthread_worker_on_cpu);
 
+/*
+ * Returns true when the work could not be queued at the moment.
+ * It happens when it is already pending in a worker list
+ * or when it is being cancelled.
+ *
+ * This function must be called under work->worker->lock.
+ */
+static inline bool queuing_blocked(const struct kthread_work *work)
+{
+	return !list_empty(&work->node) || work->canceling;
+}
+
 static void insert_kthread_work_sanity_check(struct kthread_worker *worker,
 					       struct kthread_work *work)
 {
@@ -737,7 +749,7 @@ bool queue_kthread_work(struct kthread_worker *worker,
 	unsigned long flags;
 
 	spin_lock_irqsave(&worker->lock, flags);
-	if (list_empty(&work->node)) {
+	if (!queuing_blocked(work)) {
 		insert_kthread_work(worker, work, &worker->work_list);
 		ret = true;
 	}
@@ -768,7 +780,22 @@ void delayed_kthread_work_timer_fn(unsigned long __data)
 	if (WARN_ON_ONCE(!worker))
 		return;
 
-	spin_lock(&worker->lock);
+	/*
+	 * We might be unable to take the lock if someone is trying to
+	 * cancel this work and calls del_timer_sync() when this callback
+	 * has already been removed from the timer list.
+	 */
+	while (!spin_trylock(&worker->lock)) {
+		/*
+		 * Busy wait with spin_is_locked() to avoid cache bouncing.
+		 * Break when canceling is set to avoid a deadlock.
+		 */
+		do {
+			if (work->canceling)
+				return;
+			cpu_relax();
+		} while (spin_is_locked(&worker->lock));
+	}
 	/* Work must not be used with more workers, see queue_kthread_work(). */
 	WARN_ON_ONCE(work->worker != worker);
 
@@ -837,7 +864,7 @@ bool queue_delayed_kthread_work(struct kthread_worker *worker,
 
 	spin_lock_irqsave(&worker->lock, flags);
 
-	if (list_empty(&work->node)) {
+	if (!queuing_blocked(work)) {
 		__queue_delayed_kthread_work(worker, dwork, delay);
 		ret = true;
 	}
@@ -896,6 +923,119 @@ void flush_kthread_work(struct kthread_work *work)
 }
 EXPORT_SYMBOL_GPL(flush_kthread_work);
 
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
+static bool __cancel_kthread_work(struct kthread_work *work, bool is_dwork)
+{
+	/* Try to cancel the timer if exists. */
+	if (is_dwork) {
+		struct delayed_kthread_work *dwork =
+			container_of(work, struct delayed_kthread_work, work);
+
+		del_timer_sync(&dwork->timer);
+	}
+
+	/*
+	 * Try to remove the work from a worker list. It might either
+	 * be from worker->work_list or from worker->delayed_work_list.
+	 *
+	 * Note that the work is still in the delayed list when del_timer_sync()
+	 * raced with the timer callback. In this case the callback was not able
+	 * to take the lock and move the work to the normal list.
+	 */
+	if (!list_empty(&work->node)) {
+		list_del_init(&work->node);
+		return true;
+	}
+
+	return false;
+}
+
+static bool __cancel_kthread_work_sync(struct kthread_work *work, bool is_dwork)
+{
+	struct kthread_worker *worker = work->worker;
+	unsigned long flags;
+	int ret = false;
+
+	if (!worker)
+		goto out;
+
+	spin_lock_irqsave(&worker->lock, flags);
+	/* Work must not be used with more workers, see queue_kthread_work(). */
+	WARN_ON_ONCE(worker != work->worker);
+
+	/*
+	 * work->canceling has two functions here. It blocks queueing until
+	 * the cancel operation is complete. Also it tells the timer callback
+	 * that it cannot take the worker lock. It prevents a deadlock between
+	 * the callback and del_timer_sync().
+	 */
+	work->canceling++;
+	ret = __cancel_kthread_work(work, is_dwork);
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
+ * cancel_kthread_work_sync(&delayed_work->work) must not be used for
+ * delayed_work's. Use cancel_delayed_kthread_work_sync() instead.
+
+ * The caller must ensure that the worker on which @work was last
+ * queued can't be destroyed before this function returns.
+ *
+ * Return: %true if @work was pending, %false otherwise.
+ */
+bool cancel_kthread_work_sync(struct kthread_work *work)
+{
+	return __cancel_kthread_work_sync(work, false);
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
+ * Return: %true if @dwork was pending, %false otherwise.
+ */
+bool cancel_delayed_kthread_work_sync(struct delayed_kthread_work *dwork)
+{
+	return __cancel_kthread_work_sync(&dwork->work, true);
+}
+EXPORT_SYMBOL_GPL(cancel_delayed_kthread_work_sync);
+
 /**
  * flush_kthread_worker - flush all current works on a kthread_worker
  * @worker: worker to flush
-- 
1.8.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
