Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 97579828DF
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 11:15:32 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id l6so55527932wml.3
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 08:15:32 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gy10si45779645wjc.115.2016.04.14.08.15.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 14 Apr 2016 08:15:31 -0700 (PDT)
From: Petr Mladek <pmladek@suse.com>
Subject: [PATCH v6 09/20] kthread: Allow to modify delayed kthread work
Date: Thu, 14 Apr 2016 17:14:28 +0200
Message-Id: <1460646879-617-10-git-send-email-pmladek@suse.com>
In-Reply-To: <1460646879-617-1-git-send-email-pmladek@suse.com>
References: <1460646879-617-1-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>

There are situations when we need to modify the delay of a delayed kthread
work. For example, when the work depends on an event and the initial delay
means a timeout. Then we want to queue the work immediately when the event
happens.

This patch implements mod_delayed_kthread_work() as inspired workqueues.
It cancels the timer, removes the work from any worker list and queues it
again with the given timeout.

A very special case is when the work is being canceled at the same time.
It might happen because of the regular cancel_delayed_kthread_work_sync()
or by another mod_delayed_kthread_work(). In this case, we do nothing and
let the other operation win. This should not normally happen as the caller
is supposed to synchronize these operations a reasonable way.

Signed-off-by: Petr Mladek <pmladek@suse.com>
---
 include/linux/kthread.h |  4 ++++
 kernel/kthread.c        | 53 +++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 57 insertions(+)

diff --git a/include/linux/kthread.h b/include/linux/kthread.h
index 49f59b087b6b..1d5ca191562f 100644
--- a/include/linux/kthread.h
+++ b/include/linux/kthread.h
@@ -168,6 +168,10 @@ bool queue_delayed_kthread_work(struct kthread_worker *worker,
 				struct delayed_kthread_work *dwork,
 				unsigned long delay);
 
+bool mod_delayed_kthread_work(struct kthread_worker *worker,
+			      struct delayed_kthread_work *dwork,
+			      unsigned long delay);
+
 void flush_kthread_work(struct kthread_work *work);
 void flush_kthread_worker(struct kthread_worker *worker);
 
diff --git a/kernel/kthread.c b/kernel/kthread.c
index 10129fdd4f3b..2cc32cad66ef 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -970,6 +970,59 @@ static bool __cancel_kthread_work(struct kthread_work *work, bool is_dwork,
 	return false;
 }
 
+/**
+ * mod_delayed_kthread_work - modify delay of or queue a delayed kthread work
+ * @worker: kthread worker to use
+ * @dwork: delayed kthread work to queue
+ * @delay: number of jiffies to wait before queuing
+ *
+ * If @dwork is idle, equivalent to queue_delayed_kthread work(). Otherwise,
+ * modify @dwork's timer so that it expires after @delay. If @delay is zero,
+ * @work is guaranteed to be queued immediately.
+ *
+ * Return: %true if @dwork was pending and its timer was modified,
+ * %false otherwise.
+ *
+ * A special case is when the work is being canceled in parallel.
+ * It might be caused either by the real cancel_delayed_kthread_work_sync()
+ * or yet another mod_delayed_kthread_work() call. We let the other command
+ * win and return %false here. The caller is supposed to synchronize these
+ * operations a reasonable way.
+ *
+ * This function is safe to call from any context including IRQ handler.
+ * See __cancel_kthread_work() and delayed_kthread_work_timer_fn()
+ * for details.
+ */
+bool mod_delayed_kthread_work(struct kthread_worker *worker,
+			      struct delayed_kthread_work *dwork,
+			      unsigned long delay)
+{
+	struct kthread_work *work = &dwork->work;
+	unsigned long flags;
+	int ret = false;
+
+	spin_lock_irqsave(&worker->lock, flags);
+
+	/* Do not bother with canceling when never queued. */
+	if (!work->worker)
+		goto fast_queue;
+
+	/* Work must not be used with more workers, see queue_kthread_work() */
+	WARN_ON_ONCE(work->worker != worker);
+
+	/* Do not fight with another command that is canceling this work. */
+	if (work->canceling)
+		goto out;
+
+	ret = __cancel_kthread_work(work, true, &flags);
+fast_queue:
+	__queue_delayed_kthread_work(worker, dwork, delay);
+out:
+	spin_unlock_irqrestore(&worker->lock, flags);
+	return ret;
+}
+EXPORT_SYMBOL_GPL(mod_delayed_kthread_work);
+
 static bool __cancel_kthread_work_sync(struct kthread_work *work, bool is_dwork)
 {
 	struct kthread_worker *worker = work->worker;
-- 
1.8.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
