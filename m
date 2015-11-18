Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 8219A82F6C
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 08:26:47 -0500 (EST)
Received: by wmvv187 with SMTP id v187so278169331wmv.1
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 05:26:47 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u7si2706997wmu.12.2015.11.18.05.26.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 18 Nov 2015 05:26:46 -0800 (PST)
From: Petr Mladek <pmladek@suse.com>
Subject: [PATCH v3 08/22] kthread: Initial support for delayed kthread work
Date: Wed, 18 Nov 2015 14:25:13 +0100
Message-Id: <1447853127-3461-9-git-send-email-pmladek@suse.com>
In-Reply-To: <1447853127-3461-1-git-send-email-pmladek@suse.com>
References: <1447853127-3461-1-git-send-email-pmladek@suse.com>
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
In particular, we use the worker->lock to synchronized all the
operations with the work. And we do not use any flags variable.

On the other hand, we add a pointer[*] to the timer into the struct
kthread_work. The kthread worker need to know if the work is used
and if it could clear work->worker. For this, it needs to know
whether the timer is active or not.

Finally, the timer callback knows only about the struct work.
It is better be paranoid and try to get the worker->lock carefully.
The try_lock_thread_work() function will be later useful also when
canceling the work.

[*] I considered also adding the entire struct timer_list into
    struct kthread_work. But it would increase the size from
    40 to 120 bytes on x86_64 with an often unused stuff.

    Another alternative was to add a flags variable. But this
    would add an extra code to synchronize it with the state
    of the timer.

Signed-off-by: Petr Mladek <pmladek@suse.com>
---
 include/linux/kthread.h |  34 +++++++++++++
 kernel/kthread.c        | 130 +++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 162 insertions(+), 2 deletions(-)

diff --git a/include/linux/kthread.h b/include/linux/kthread.h
index c4a95a3ba500..1a5738dcdf8d 100644
--- a/include/linux/kthread.h
+++ b/include/linux/kthread.h
@@ -63,6 +63,7 @@ extern int tsk_fork_get_node(struct task_struct *tsk);
  */
 struct kthread_work;
 typedef void (*kthread_work_func_t)(struct kthread_work *work);
+void delayed_kthread_work_timer_fn(unsigned long __data);
 
 struct kthread_worker {
 	spinlock_t		lock;
@@ -75,6 +76,12 @@ struct kthread_work {
 	struct list_head	node;
 	kthread_work_func_t	func;
 	struct kthread_worker	*worker;
+	struct timer_list	*timer;
+};
+
+struct delayed_kthread_work {
+	struct kthread_work work;
+	struct timer_list timer;
 };
 
 #define KTHREAD_WORKER_INIT(worker)	{				\
@@ -87,12 +94,24 @@ struct kthread_work {
 	.func = (fn),							\
 	}
 
+#define DELAYED_KTHREAD_WORK_INIT(dwork, fn) {				\
+	.work = KTHREAD_WORK_INIT((dwork).work, (fn)),			\
+	.timer = __TIMER_INITIALIZER(delayed_kthread_work_timer_fn,	\
+				     0, (unsigned long)&(dwork),	\
+				     TIMER_IRQSAFE),			\
+	.work.timer = &(dwork).timer,			\
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
@@ -122,6 +141,16 @@ extern void __init_kthread_worker(struct kthread_worker *worker,
 		(work)->func = (fn);					\
 	} while (0)
 
+#define init_delayed_kthread_work(dwork, fn)				\
+	do {								\
+		init_kthread_work(&(dwork)->work, (fn));		\
+		__setup_timer(&(dwork)->timer,				\
+			      delayed_kthread_work_timer_fn,		\
+			      (unsigned long)(dwork),			\
+			      TIMER_IRQSAFE);				\
+		(dwork)->work.timer = &(dwork)->timer;			\
+	} while (0)
+
 int kthread_worker_fn(void *worker_ptr);
 
 __printf(1, 2)
@@ -133,6 +162,11 @@ create_kthread_worker_on_cpu(int cpu, const char namefmt[]);
 
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
index 378d2203c8b0..0f4b348c2c7e 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -567,12 +567,14 @@ EXPORT_SYMBOL_GPL(__init_kthread_worker);
  * Returns true when there is a pending operation for this work.
  * In particular, it checks if the work is:
  *	- queued
+ *	- a timer is running to queue this delayed work
  *
  * This function must be called with locked work.
  */
 static inline bool kthread_work_pending(const struct kthread_work *work)
 {
-	return !list_empty(&work->node);
+	return !list_empty(&work->node) ||
+	       (work->timer && timer_active(work->timer));
 }
 
 /**
@@ -740,6 +742,15 @@ static void insert_kthread_work(struct kthread_worker *worker,
 		wake_up_process(worker->task);
 }
 
+/*
+ * Queue @work right into the worker queue.
+ */
+static void __queue_kthread_work(struct kthread_worker *worker,
+			  struct kthread_work *work)
+{
+	insert_kthread_work(worker, work, &worker->work_list);
+}
+
 /**
  * queue_kthread_work - queue a kthread_work
  * @worker: target kthread_worker
@@ -763,7 +774,7 @@ bool queue_kthread_work(struct kthread_worker *worker,
 
 	spin_lock_irqsave(&worker->lock, flags);
 	if (!kthread_work_pending(work)) {
-		insert_kthread_work(worker, work, &worker->work_list);
+		__queue_kthread_work(worker, work);
 		ret = true;
 	}
 	spin_unlock_irqrestore(&worker->lock, flags);
@@ -771,6 +782,121 @@ bool queue_kthread_work(struct kthread_worker *worker,
 }
 EXPORT_SYMBOL_GPL(queue_kthread_work);
 
+static bool try_lock_kthread_work(struct kthread_work *work)
+{
+	struct kthread_worker *worker;
+	int ret = false;
+
+try_again:
+	worker = work->worker;
+
+	if (!worker)
+		goto out;
+
+	spin_lock(&worker->lock);
+	if (worker != work->worker) {
+		spin_unlock(&worker->lock);
+		goto try_again;
+	}
+	ret = true;
+
+out:
+	return ret;
+}
+
+static inline void unlock_kthread_work(struct kthread_work *work)
+{
+	spin_unlock(&work->worker->lock);
+}
+
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
+
+	if (WARN_ON(!try_lock_kthread_work(work)))
+		return;
+
+	__queue_kthread_work(work->worker, work);
+	unlock_kthread_work(work);
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
+	/* Be paranoid and try to detect possible races already now. */
+	insert_kthread_work_sanity_check(worker, work);
+
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
+	spin_lock_irqsave(&worker->lock, flags);
+
+	if (!kthread_work_pending(work)) {
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
