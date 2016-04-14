Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id D4AC6828DF
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 11:15:28 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id a140so55405875wma.1
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 08:15:28 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m128si35349149wma.6.2016.04.14.08.15.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 14 Apr 2016 08:15:27 -0700 (PDT)
From: Petr Mladek <pmladek@suse.com>
Subject: [PATCH v6 07/20] kthread: Initial support for delayed kthread work
Date: Thu, 14 Apr 2016 17:14:26 +0200
Message-Id: <1460646879-617-8-git-send-email-pmladek@suse.com>
In-Reply-To: <1460646879-617-1-git-send-email-pmladek@suse.com>
References: <1460646879-617-1-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>

We are going to use kthread_worker more widely and delayed works
will be pretty useful.

The implementation is inspired by workqueues. It uses a timer to
queue the work after the requested delay. If the delay is zero,
the work is queued immediately.

In compare with workqueues, each work is associated with a single
worker (kthread). Therefore the implementation could be much easier.
In particular, we use the worker->lock to synchronize all the
operations with the work. We do not need any atomic operation
with a flags variable.

In fact, we do not need any state variable at all. Instead, we
add a list of delayed works into the worker. Then the pending
work is listed either in the list of queued or delayed works.
And the existing check of pending works is the same even for
the delayed ones.

A work must not be assigned to another worker unless reinitialized.
Therefore the timer handler might expect that dwork->work->worker
is valid and it could simply take the lock. We just add some
sanity checks to help with debugging a potential misuse.

Signed-off-by: Petr Mladek <pmladek@suse.com>
---
 include/linux/kthread.h |  33 ++++++++++++++++
 kernel/kthread.c        | 102 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 135 insertions(+)

diff --git a/include/linux/kthread.h b/include/linux/kthread.h
index a36604fa8aa2..b27be55cffa3 100644
--- a/include/linux/kthread.h
+++ b/include/linux/kthread.h
@@ -63,10 +63,12 @@ extern int tsk_fork_get_node(struct task_struct *tsk);
  */
 struct kthread_work;
 typedef void (*kthread_work_func_t)(struct kthread_work *work);
+void delayed_kthread_work_timer_fn(unsigned long __data);
 
 struct kthread_worker {
 	spinlock_t		lock;
 	struct list_head	work_list;
+	struct list_head	delayed_work_list;
 	struct task_struct	*task;
 	struct kthread_work	*current_work;
 };
@@ -77,9 +79,15 @@ struct kthread_work {
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
+	.delayed_work_list = LIST_HEAD_INIT((worker).delayed_work_list),\
 	}
 
 #define KTHREAD_WORK_INIT(work, fn)	{				\
@@ -87,12 +95,23 @@ struct kthread_work {
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
@@ -122,6 +141,15 @@ extern void __init_kthread_worker(struct kthread_worker *worker,
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
 
 __printf(1, 2)
@@ -133,6 +161,11 @@ create_kthread_worker_on_cpu(int cpu, const char namefmt[], ...);
 
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
index 385a7d6b4872..7655357065e1 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -559,6 +559,7 @@ void __init_kthread_worker(struct kthread_worker *worker,
 	spin_lock_init(&worker->lock);
 	lockdep_set_class_and_name(&worker->lock, key, name);
 	INIT_LIST_HEAD(&worker->work_list);
+	INIT_LIST_HEAD(&worker->delayed_work_list);
 	worker->task = NULL;
 }
 EXPORT_SYMBOL_GPL(__init_kthread_worker);
@@ -763,6 +764,107 @@ bool queue_kthread_work(struct kthread_worker *worker,
 }
 EXPORT_SYMBOL_GPL(queue_kthread_work);
 
+/**
+ * delayed_kthread_work_timer_fn - callback that queues the associated delayed
+ *	kthread work when the timer expires.
+ * @__data: pointer to the data associated with the timer
+ *
+ * The format of the function is defined by struct timer_list.
+ * It should have been called from irqsafe timer with irq already off.
+ */
+void delayed_kthread_work_timer_fn(unsigned long __data)
+{
+	struct delayed_kthread_work *dwork =
+		(struct delayed_kthread_work *)__data;
+	struct kthread_work *work = &dwork->work;
+	struct kthread_worker *worker = work->worker;
+
+	/*
+	 * This might happen when a pending work is reinitialized.
+	 * It means that it is used a wrong way.
+	 */
+	if (WARN_ON_ONCE(!worker))
+		return;
+
+	spin_lock(&worker->lock);
+	/* Work must not be used with more workers, see queue_kthread_work(). */
+	WARN_ON_ONCE(work->worker != worker);
+
+	/* Move the work from worker->delayed_work_list. */
+	WARN_ON_ONCE(list_empty(&work->node));
+	list_del_init(&work->node);
+	insert_kthread_work(worker, work, &worker->work_list);
+
+	spin_unlock(&worker->lock);
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
+
+	/*
+	 * If @delay is 0, queue @dwork->work immediately.  This is for
+	 * both optimization and correctness.  The earliest @timer can
+	 * expire is on the closest next tick and delayed_work users depend
+	 * on that there's no such delay when @delay is 0.
+	 */
+	if (!delay) {
+		insert_kthread_work(worker, work, &worker->work_list);
+		return;
+	}
+
+	/* Be paranoid and try to detect possible races already now. */
+	insert_kthread_work_sanity_check(worker, work);
+
+	list_add(&work->node, &worker->delayed_work_list);
+	work->worker = worker;
+	timer_stats_timer_set_start_info(&dwork->timer);
+	timer->expires = jiffies + delay;
+	add_timer(timer);
+}
+
+/**
+ * queue_delayed_kthread_work - queue the associated kthread work
+ *	after a delay.
+ * @worker: target kthread_worker
+ * @dwork: delayed_kthread_work to queue
+ * @delay: number of jiffies to wait before queuing
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
+	spin_lock_irqsave(&worker->lock, flags);
+
+	if (list_empty(&work->node)) {
+		__queue_delayed_kthread_work(worker, dwork, delay);
+		ret = true;
+	}
+
+	spin_unlock_irqrestore(&worker->lock, flags);
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
