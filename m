Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0859D6B0253
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 07:19:26 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id na2so25999993lbb.1
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 04:19:25 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ec11si4806253wjb.99.2016.06.16.04.19.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Jun 2016 04:19:24 -0700 (PDT)
From: Petr Mladek <pmladek@suse.com>
Subject: [PATCH v9 09/12] kthread: Initial support for delayed kthread work
Date: Thu, 16 Jun 2016 13:17:28 +0200
Message-Id: <1466075851-24013-10-git-send-email-pmladek@suse.com>
In-Reply-To: <1466075851-24013-1-git-send-email-pmladek@suse.com>
References: <1466075851-24013-1-git-send-email-pmladek@suse.com>
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
index b2c4dcea8f51..98d167187013 100644
--- a/include/linux/kthread.h
+++ b/include/linux/kthread.h
@@ -63,10 +63,12 @@ extern int tsk_fork_get_node(struct task_struct *tsk);
  */
 struct kthread_work;
 typedef void (*kthread_work_func_t)(struct kthread_work *work);
+void kthread_delayed_work_timer_fn(unsigned long __data);
 
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
 
+struct kthread_delayed_work {
+	struct kthread_work work;
+	struct timer_list timer;
+};
+
 #define INIT_KTHREAD_WORKER(worker)	{				\
 	.lock = __SPIN_LOCK_UNLOCKED((worker).lock),			\
 	.work_list = LIST_HEAD_INIT((worker).work_list),		\
+	.delayed_work_list = LIST_HEAD_INIT((worker).delayed_work_list),\
 	}
 
 #define INIT_KTHREAD_WORK(work, fn)	{				\
@@ -87,12 +95,23 @@ struct kthread_work {
 	.func = (fn),							\
 	}
 
+#define INIT_KTHREAD_DELAYED_WORK(dwork, fn) {				\
+	.work = INIT_KTHREAD_WORK((dwork).work, (fn)),			\
+	.timer = __TIMER_INITIALIZER(kthread_delayed_work_timer_fn,	\
+				     0, (unsigned long)&(dwork),	\
+				     TIMER_IRQSAFE),			\
+	}
+
 #define DEFINE_KTHREAD_WORKER(worker)					\
 	struct kthread_worker worker = INIT_KTHREAD_WORKER(worker)
 
 #define DEFINE_KTHREAD_WORK(work, fn)					\
 	struct kthread_work work = INIT_KTHREAD_WORK(work, fn)
 
+#define DEFINE_KTHREAD_DELAYED_WORK(dwork, fn)				\
+	struct kthread_delayed_work dwork =				\
+		INIT_KTHREAD_DELAYED_WORK(dwork, fn)
+
 /*
  * kthread_worker.lock needs its own lockdep class key when defined on
  * stack with lockdep enabled.  Use the following macros in such cases.
@@ -122,6 +141,15 @@ extern void __kthread_init_worker(struct kthread_worker *worker,
 		(work)->func = (fn);					\
 	} while (0)
 
+#define kthread_init_delayed_work(dwork, fn)				\
+	do {								\
+		kthread_init_work(&(dwork)->work, (fn));		\
+		__setup_timer(&(dwork)->timer,				\
+			      kthread_delayed_work_timer_fn,		\
+			      (unsigned long)(dwork),			\
+			      TIMER_IRQSAFE);				\
+	} while (0)
+
 int kthread_worker_fn(void *worker_ptr);
 
 __printf(1, 2)
@@ -133,6 +161,11 @@ kthread_create_worker_on_cpu(int cpu, const char namefmt[], ...);
 
 bool kthread_queue_work(struct kthread_worker *worker,
 			struct kthread_work *work);
+
+bool kthread_queue_delayed_work(struct kthread_worker *worker,
+				struct kthread_delayed_work *dwork,
+				unsigned long delay);
+
 void kthread_flush_work(struct kthread_work *work);
 void kthread_flush_worker(struct kthread_worker *worker);
 void kthread_drain_worker(struct kthread_worker *worker);
diff --git a/kernel/kthread.c b/kernel/kthread.c
index 8e9548649c86..0336b378a5b9 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -559,6 +559,7 @@ void __kthread_init_worker(struct kthread_worker *worker,
 	spin_lock_init(&worker->lock);
 	lockdep_set_class_and_name(&worker->lock, key, name);
 	INIT_LIST_HEAD(&worker->work_list);
+	INIT_LIST_HEAD(&worker->delayed_work_list);
 	worker->task = NULL;
 }
 EXPORT_SYMBOL_GPL(__kthread_init_worker);
@@ -763,6 +764,107 @@ bool kthread_queue_work(struct kthread_worker *worker,
 }
 EXPORT_SYMBOL_GPL(kthread_queue_work);
 
+/**
+ * kthread_delayed_work_timer_fn - callback that queues the associated kthread
+ *	delayed work when the timer expires.
+ * @__data: pointer to the data associated with the timer
+ *
+ * The format of the function is defined by struct timer_list.
+ * It should have been called from irqsafe timer with irq already off.
+ */
+void kthread_delayed_work_timer_fn(unsigned long __data)
+{
+	struct kthread_delayed_work *dwork =
+		(struct kthread_delayed_work *)__data;
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
+	/* Work must not be used with more workers, see kthread_queue_work(). */
+	WARN_ON_ONCE(work->worker != worker);
+
+	/* Move the work from worker->delayed_work_list. */
+	WARN_ON_ONCE(list_empty(&work->node));
+	list_del_init(&work->node);
+	kthread_insert_work(worker, work, &worker->work_list);
+
+	spin_unlock(&worker->lock);
+}
+EXPORT_SYMBOL(kthread_delayed_work_timer_fn);
+
+void __kthread_queue_delayed_work(struct kthread_worker *worker,
+				  struct kthread_delayed_work *dwork,
+				  unsigned long delay)
+{
+	struct timer_list *timer = &dwork->timer;
+	struct kthread_work *work = &dwork->work;
+
+	WARN_ON_ONCE(timer->function != kthread_delayed_work_timer_fn ||
+		     timer->data != (unsigned long)dwork);
+
+	/*
+	 * If @delay is 0, queue @dwork->work immediately.  This is for
+	 * both optimization and correctness.  The earliest @timer can
+	 * expire is on the closest next tick and delayed_work users depend
+	 * on that there's no such delay when @delay is 0.
+	 */
+	if (!delay) {
+		kthread_insert_work(worker, work, &worker->work_list);
+		return;
+	}
+
+	/* Be paranoid and try to detect possible races already now. */
+	kthread_insert_work_sanity_check(worker, work);
+
+	list_add(&work->node, &worker->delayed_work_list);
+	work->worker = worker;
+	timer_stats_timer_set_start_info(&dwork->timer);
+	timer->expires = jiffies + delay;
+	add_timer(timer);
+}
+
+/**
+ * kthread_queue_delayed_work - queue the associated kthread work
+ *	after a delay.
+ * @worker: target kthread_worker
+ * @dwork: kthread_delayed_work to queue
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
+bool kthread_queue_delayed_work(struct kthread_worker *worker,
+				struct kthread_delayed_work *dwork,
+				unsigned long delay)
+{
+	struct kthread_work *work = &dwork->work;
+	unsigned long flags;
+	bool ret = false;
+
+	spin_lock_irqsave(&worker->lock, flags);
+
+	if (list_empty(&work->node)) {
+		__kthread_queue_delayed_work(worker, dwork, delay);
+		ret = true;
+	}
+
+	spin_unlock_irqrestore(&worker->lock, flags);
+	return ret;
+}
+EXPORT_SYMBOL_GPL(kthread_queue_delayed_work);
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
