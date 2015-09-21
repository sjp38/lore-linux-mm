Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 9B4B36B025A
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 09:05:29 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so115022917wic.0
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 06:05:29 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w17si17008004wij.99.2015.09.21.06.05.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 21 Sep 2015 06:05:27 -0700 (PDT)
From: Petr Mladek <pmladek@suse.com>
Subject: [RFC v2 07/18] kthread: Allow to cancel kthread work
Date: Mon, 21 Sep 2015 15:03:48 +0200
Message-Id: <1442840639-6963-8-git-send-email-pmladek@suse.com>
In-Reply-To: <1442840639-6963-1-git-send-email-pmladek@suse.com>
References: <1442840639-6963-1-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, live-patching@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>

We are going to use kthread workers more widely and we will need
to cancel pending work in some situations.

The implementation is inspired by workqueues. There are four basic
situations. The work might be pending, running, or idle. While a pending
delayer work might have running timer or it might already be in the queue.

In all cases we try to get PENDING flag and protect others from queuing.
Once we have the PENDING flag, we try to remove the pending work from
the queue and we wait for a potentially running work until it finishes.

The most complicated situation is when more cancel_*kthread_work() calls
run in parallel. Only one could grab PENDING flags using a busy wait.
The others need to wait until the first one flush() the work. It might
take arbitrary long time and busy wait is not an option here. This
situation is detected using the new CANCELING flag and the less
successful callers need to sleep in a wait queue. They are
woken when the winner finishes its job.

Signed-off-by: Petr Mladek <pmladek@suse.com>
---
 include/linux/kthread.h |  11 +++
 kernel/kthread.c        | 198 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 209 insertions(+)

diff --git a/include/linux/kthread.h b/include/linux/kthread.h
index 64fb9796ab69..327d82875410 100644
--- a/include/linux/kthread.h
+++ b/include/linux/kthread.h
@@ -75,6 +75,8 @@ struct kthread_worker {
 enum {
 	/* work item is pending execution */
 	KTHREAD_WORK_PENDING_BIT	= 0,
+	/* work item is canceling */
+	KTHREAD_WORK_CANCELING_BIT	= 2,
 };
 
 struct kthread_work {
@@ -89,6 +91,12 @@ struct delayed_kthread_work {
 	struct timer_list timer;
 };
 
+static inline struct delayed_kthread_work *
+to_delayed_kthread_work(struct kthread_work *work)
+{
+	return container_of(work, struct delayed_kthread_work, work);
+}
+
 #define KTHREAD_WORKER_INIT(worker)	{				\
 	.lock = __SPIN_LOCK_UNLOCKED((worker).lock),			\
 	.work_list = LIST_HEAD_INIT((worker).work_list),		\
@@ -173,6 +181,9 @@ bool queue_delayed_kthread_work(struct kthread_worker *worker,
 void flush_kthread_work(struct kthread_work *work);
 void flush_kthread_worker(struct kthread_worker *worker);
 
+bool cancel_kthread_work_sync(struct kthread_work *work);
+bool cancel_delayed_kthread_work_sync(struct delayed_kthread_work *work);
+
 void destroy_kthread_worker(struct kthread_worker *worker);
 
 #endif /* _LINUX_KTHREAD_H */
diff --git a/kernel/kthread.c b/kernel/kthread.c
index eba6e061bda5..8c6160eece72 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -859,6 +859,204 @@ retry:
 EXPORT_SYMBOL_GPL(flush_kthread_work);
 
 /**
+ * try_to_grab_pending_kthread_work - steal kthread work item from worklist,
+ *	and disable irq
+ * @work: work item to steal
+ * @is_dwork: @work is a delayed_work
+ * @flags: place to store irq state
+ *
+ * Try to grab PENDING bit of @work.  This function can handle @work in any
+ * stable state - idle, on timer or on worklist.
+ *
+ * Return:
+ *  1		if @work was pending and we successfully stole PENDING
+ *  0		if @work was idle and we claimed PENDING
+ *  -EAGAIN	if PENDING couldn't be grabbed at the moment, safe to busy-retry
+ *  -ENOENT	if someone else is canceling @work, this state may persist
+ *		for arbitrarily long
+ *
+ * Note:
+ * On >= 0 return, the caller owns @work's PENDING bit.  To avoid getting
+ * interrupted while holding PENDING and @work off queue, irq must be
+ * disabled on return.  This, combined with delayed_work->timer being
+ * irqsafe, ensures that we return -EAGAIN for finite short period of time.
+ *
+ * On successful return, >= 0, irq is disabled and the caller is
+ * responsible for releasing it using local_irq_restore(*@flags).
+ *
+ * This function is safe to call from any context including IRQ handler.
+ */
+static int
+try_to_grab_pending_kthread_work(struct kthread_work *work,  bool is_dwork,
+				 unsigned long *flags)
+{
+	struct kthread_worker *worker;
+
+	local_irq_save(*flags);
+retry:
+	/* try to steal the timer if it exists */
+	if (is_dwork) {
+		struct delayed_kthread_work *dwork =
+			to_delayed_kthread_work(work);
+
+		/*
+		 * dwork->timer is irqsafe.  If del_timer() fails, it's
+		 * guaranteed that the timer is not queued anywhere and not
+		 * running on the local CPU.
+		 */
+		if (likely(del_timer(&dwork->timer)))
+			return 1;
+	}
+
+	/* try to claim PENDING the normal way */
+	if (!test_and_set_bit(KTHREAD_WORK_PENDING_BIT, work->flags))
+		return 0;
+
+	/*
+	 * The queuing is in progress, or it is already queued. Try to
+	 * steal it from ->worklist without clearing KTHREAD_WORK_PENDING.
+	 */
+	worker = work->worker;
+	if (!worker)
+		goto fail;
+
+	spin_lock(&worker->lock);
+
+	if (work->worker != worker) {
+		spin_unlock(&worker->lock);
+		goto retry;
+	}
+
+	/* try to grab queued work before it is being executed */
+	if (!list_empty(&work->node)) {
+		list_del_init(&work->node);
+		spin_unlock(&worker->lock);
+		return 1;
+	}
+
+	spin_unlock(&worker->lock);
+fail:
+	local_irq_restore(*flags);
+	if (test_bit(KTHREAD_WORK_CANCELING_BIT, work->flags))
+		return -ENOENT;
+	cpu_relax();
+	return -EAGAIN;
+}
+
+/* custom wait for canceling a kthread work */
+struct cktw_wait {
+	wait_queue_t		wait;
+	struct kthread_work	*work;
+};
+
+static int cktw_wakefn(wait_queue_t *wait, unsigned mode, int sync, void *key)
+{
+	struct cktw_wait *cwait = container_of(wait, struct cktw_wait, wait);
+
+	if (cwait->work != key)
+		return 0;
+	return autoremove_wake_function(wait, mode, sync, key);
+}
+
+static bool __cancel_kthread_work_sync(struct kthread_work *work, bool is_dwork)
+{
+	static DECLARE_WAIT_QUEUE_HEAD(cancel_waitq);
+	unsigned long flags;
+	int ret;
+
+	do {
+		ret = try_to_grab_pending_kthread_work(work, is_dwork, &flags);
+		/*
+		 * If someone else is already canceling, wait for it to finish.
+		 * flush_work() doesn't work for PREEMPT_NONE because we may
+		 * get scheduled between @work's completion and the other
+		 * canceling task resuming and clearing CANCELING -
+		 * flush_work() will return false immediately as @work is
+		 * no longer busy, try_to_grab_pending_kthread_work() will
+		 * return -ENOENT as @work is still being canceled and the
+		 * other canceling task won't be able to clear CANCELING as
+		 * we're hogging the CPU.
+		 *
+		 * Let's wait for completion using a waitqueue.  As this
+		 * may lead to the thundering herd problem, use a custom
+		 * wake function which matches @work along with exclusive
+		 * wait and wakeup.
+		 */
+		if (unlikely(ret == -ENOENT)) {
+			struct cktw_wait cwait;
+
+			init_wait(&cwait.wait);
+			cwait.wait.func = cktw_wakefn;
+			cwait.work = work;
+
+			prepare_to_wait_exclusive(&cancel_waitq, &cwait.wait,
+						  TASK_UNINTERRUPTIBLE);
+			if (test_bit(KTHREAD_WORK_CANCELING_BIT, work->flags))
+				schedule();
+			finish_wait(&cancel_waitq, &cwait.wait);
+		}
+	} while (unlikely(ret < 0));
+
+	/* tell other tasks trying to grab @work to back off */
+	set_bit(KTHREAD_WORK_CANCELING_BIT, work->flags);
+	local_irq_restore(flags);
+
+	flush_kthread_work(work);
+	/* clear both PENDING and CANCELING flags atomically */
+	memset(work->flags, 0, sizeof(work->flags));
+	/*
+	 * Paired with prepare_to_wait() above so that either
+	 * waitqueue_active() is visible here or CANCELING bit is
+	 * visible there.
+	 */
+	smp_mb();
+	if (waitqueue_active(&cancel_waitq))
+		__wake_up(&cancel_waitq, TASK_NORMAL, 1, work);
+
+	return ret;
+}
+
+/**
+ * cancel_kthread_work_sync - cancel a kthread work and wait for it to finish
+ * @dwork: the delayed kthread work to cancel
+ *
+ * Cancel @work and wait for its execution to finish.  This function
+ * can be used even if the work re-queues itself or migrates to
+ * another workqueue.  On return from this function, @work is
+ * guaranteed to be not pending or executing on any CPU.
+ *
+ * cancel_kthread_work_sync(&delayed_work->work) must not be used for
+ * delayed_work's.  Use cancel_delayed_kthread_work_sync() instead.
+ *
+ * The caller must ensure that the worker on which @work was last
+ * queued can't be destroyed before this function returns.
+ *
+ * Return:
+ * %true if @work was pending, %false otherwise.
+ */
+bool cancel_kthread_work_sync(struct kthread_work *work)
+{
+	return __cancel_kthread_work_sync(work, false);
+}
+EXPORT_SYMBOL_GPL(cancel_kthread_work_sync);
+
+/**
+ * cancel_delayed_kthread_work_sync - cancel a delayed kthread work and
+ *	wait for it to finish
+ * @dwork: the delayed kthread work to cancel
+ *
+ * This is cancel_kthread_work_sync() for delayed works.
+ *
+ * Return:
+ * %true if @dwork was pending, %false otherwise.
+ */
+bool cancel_delayed_kthread_work_sync(struct delayed_kthread_work *dwork)
+{
+	return __cancel_kthread_work_sync(&dwork->work, true);
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
