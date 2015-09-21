Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id A1D036B0259
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 09:05:28 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so110608650wic.1
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 06:05:28 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ub1si17034854wib.30.2015.09.21.06.05.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 21 Sep 2015 06:05:23 -0700 (PDT)
From: Petr Mladek <pmladek@suse.com>
Subject: [RFC v2 06/18] kthread: Initial support for delayed kthread work
Date: Mon, 21 Sep 2015 15:03:47 +0200
Message-Id: <1442840639-6963-7-git-send-email-pmladek@suse.com>
In-Reply-To: <1442840639-6963-1-git-send-email-pmladek@suse.com>
References: <1442840639-6963-1-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, live-patching@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>

We are going to use kthread_worker more widely and delayed works
will be pretty useful.

The implementation is inspired by workqueues. It uses a timer to
queue the work after the requested delay. If the delay is zero,
the work is queued immediately.

In compare with workqueues, the worker is stored in the associated
kthread_work struct directly. Kthread workers do not use pool
of kthreads and the value could stay the same all the time.

Signed-off-by: Petr Mladek <pmladek@suse.com>
---
 include/linux/kthread.h | 31 ++++++++++++++++++
 kernel/kthread.c        | 84 +++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 115 insertions(+)

diff --git a/include/linux/kthread.h b/include/linux/kthread.h
index aabb105d3d4b..64fb9796ab69 100644
--- a/include/linux/kthread.h
+++ b/include/linux/kthread.h
@@ -63,6 +63,7 @@ extern int tsk_fork_get_node(struct task_struct *tsk);
  */
 struct kthread_work;
 typedef void (*kthread_work_func_t)(struct kthread_work *work);
+void delayed_kthread_work_timer_fn(unsigned long __data);
 
 struct kthread_worker {
 	spinlock_t		lock;
@@ -83,6 +84,11 @@ struct kthread_work {
 	struct kthread_worker	*worker;
 };
 
+struct delayed_kthread_work {
+	struct kthread_work work;
+	struct timer_list timer;
+};
+
 #define KTHREAD_WORKER_INIT(worker)	{				\
 	.lock = __SPIN_LOCK_UNLOCKED((worker).lock),			\
 	.work_list = LIST_HEAD_INIT((worker).work_list),		\
@@ -93,12 +99,23 @@ struct kthread_work {
 	.func = (fn),							\
 	}
 
+#define DELAYED_KTHREAD_WORK_INIT(dwork, fn) {				\
+	.work = KTHREAD_WORK_INIT((dwork).work, (fn)),			\
+	.timer = __TIMER_INITIALIZER(delayed_kthread_work_timer_fn,	\
+				     0, (unsigned long)&(dwork),	\
+				     TIMER_IRQSAFE),			\
+	}
+
 #define DEFINE_KTHREAD_WORKER(worker)					\
 	struct kthread_worker worker = KTHREAD_WORKER_INIT(worker)
 
 #define DEFINE_KTHREAD_WORK(work, fn)					\
 	struct kthread_work work = KTHREAD_WORK_INIT(work, fn)
 
+#define DEFINE_DELAYED_KTHREAD_WORK(dwork, fn)				\
+	struct delayed_kthread_work dwork =				\
+		DELAYED_KTHREAD_WORK_INIT(dwork, fn)
+
 /*
  * kthread_worker.lock needs its own lockdep class key when defined on
  * stack with lockdep enabled.  Use the following macros in such cases.
@@ -128,6 +145,15 @@ extern void __init_kthread_worker(struct kthread_worker *worker,
 		(work)->func = (fn);					\
 	} while (0)
 
+#define init_delayed_kthread_work(dwork, fn)				\
+	do {								\
+		init_kthread_work(&(dwork)->work, (fn));		\
+		__setup_timer(&(dwork)->timer,				\
+			      delayed_kthread_work_timer_fn,		\
+			      (unsigned long)(dwork),			\
+			      TIMER_IRQSAFE);				\
+	} while (0)
+
 int kthread_worker_fn(void *worker_ptr);
 
 __printf(2, 3)
@@ -139,6 +165,11 @@ create_kthread_worker_on_node(int node, const char namefmt[], ...);
 
 bool queue_kthread_work(struct kthread_worker *worker,
 			struct kthread_work *work);
+
+bool queue_delayed_kthread_work(struct kthread_worker *worker,
+				struct delayed_kthread_work *dwork,
+				unsigned long delay);
+
 void flush_kthread_work(struct kthread_work *work);
 void flush_kthread_worker(struct kthread_worker *worker);
 
diff --git a/kernel/kthread.c b/kernel/kthread.c
index fe1510e7ad04..eba6e061bda5 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -722,6 +722,90 @@ bool queue_kthread_work(struct kthread_worker *worker,
 }
 EXPORT_SYMBOL_GPL(queue_kthread_work);
 
+/**
+ * delayed_kthread_work_timer_fn - callback that queues the associated delayed
+ *	kthread work when the timer expires.
+ * @__data: pointer to the data associated with the timer
+ *
+ * The format of the function is defined by struct timer_list.
+ */
+void delayed_kthread_work_timer_fn(unsigned long __data)
+{
+	struct delayed_kthread_work *dwork =
+		(struct delayed_kthread_work *)__data;
+
+	/* should have been called from irqsafe timer with irq already off */
+	__queue_kthread_work(dwork->work.worker, &dwork->work);
+}
+EXPORT_SYMBOL(delayed_kthread_work_timer_fn);
+
+void __queue_delayed_kthread_work(struct kthread_worker *worker,
+				struct delayed_kthread_work *dwork,
+				unsigned long delay)
+{
+	struct timer_list *timer = &dwork->timer;
+	struct kthread_work *work = &dwork->work;
+
+	WARN_ON_ONCE(timer->function != delayed_kthread_work_timer_fn ||
+		     timer->data != (unsigned long)dwork);
+	WARN_ON_ONCE(timer_pending(timer));
+	WARN_ON_ONCE(!list_empty(&work->node));
+
+	/*
+	 * If @delay is 0, queue @dwork->work immediately.  This is for
+	 * both optimization and correctness.  The earliest @timer can
+	 * expire is on the closest next tick and delayed_work users depend
+	 * on that there's no such delay when @delay is 0.
+	 */
+	if (!delay) {
+		__queue_kthread_work(worker, work);
+		return;
+	}
+
+	timer_stats_timer_set_start_info(&dwork->timer);
+
+	work->worker = worker;
+	timer->expires = jiffies + delay;
+
+	add_timer(timer);
+}
+
+/**
+ * queue_delayed_kthread_work - queue the associated kthread work
+ *	after a delay.
+ * @worker: target kthread_worker
+ * @work: kthread_work to queue
+ * delay: number of jiffies to wait before queuing
+ *
+ * If the work has not been pending it starts a timer that will queue
+ * the work after the given @delay. If @delay is zero, it queues the
+ * work immediately.
+ *
+ * Return: %false if the @work has already been pending. It means that
+ * either the timer was running or the work was queued. It returns %true
+ * otherwise.
+ */
+bool queue_delayed_kthread_work(struct kthread_worker *worker,
+				struct delayed_kthread_work *dwork,
+				unsigned long delay)
+{
+	struct kthread_work *work = &dwork->work;
+	unsigned long flags;
+	bool ret = false;
+
+	local_irq_save(flags);
+
+	if (!test_and_set_bit(KTHREAD_WORK_PENDING_BIT, work->flags)) {
+		__queue_delayed_kthread_work(worker, dwork, delay);
+		ret = true;
+	}
+
+	local_irq_restore(flags);
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(queue_delayed_kthread_work);
+
 struct kthread_flush_work {
 	struct kthread_work	work;
 	struct completion	done;
-- 
1.8.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
