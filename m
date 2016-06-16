Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id A1C1A6B026C
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 07:19:40 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r5so25604491wmr.0
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 04:19:40 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 185si4028249wmc.80.2016.06.16.04.19.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Jun 2016 04:19:39 -0700 (PDT)
From: Petr Mladek <pmladek@suse.com>
Subject: [PATCH v9 11/12] kthread: Allow to modify delayed kthread work
Date: Thu, 16 Jun 2016 13:17:30 +0200
Message-Id: <1466075851-24013-12-git-send-email-pmladek@suse.com>
In-Reply-To: <1466075851-24013-1-git-send-email-pmladek@suse.com>
References: <1466075851-24013-1-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>

There are situations when we need to modify the delay of a delayed kthread
work. For example, when the work depends on an event and the initial delay
means a timeout. Then we want to queue the work immediately when the event
happens.

This patch implements kthread_mod_delayed_work() as inspired workqueues.
It cancels the timer, removes the work from any worker list and queues it
again with the given timeout.

A very special case is when the work is being canceled at the same time.
It might happen because of the regular kthread_cancel_delayed_work_sync()
or by another kthread_mod_delayed_work(). In this case, we do nothing and
let the other operation win. This should not normally happen as the caller
is supposed to synchronize these operations a reasonable way.

Signed-off-by: Petr Mladek <pmladek@suse.com>
---
 include/linux/kthread.h |  4 ++++
 kernel/kthread.c        | 53 +++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 57 insertions(+)

diff --git a/include/linux/kthread.h b/include/linux/kthread.h
index 89d4f188d9fe..4a606767ebf8 100644
--- a/include/linux/kthread.h
+++ b/include/linux/kthread.h
@@ -168,6 +168,10 @@ bool kthread_queue_delayed_work(struct kthread_worker *worker,
 				struct kthread_delayed_work *dwork,
 				unsigned long delay);
 
+bool kthread_mod_delayed_work(struct kthread_worker *worker,
+			      struct kthread_delayed_work *dwork,
+			      unsigned long delay);
+
 void kthread_flush_work(struct kthread_work *work);
 void kthread_flush_worker(struct kthread_worker *worker);
 void kthread_drain_worker(struct kthread_worker *worker);
diff --git a/kernel/kthread.c b/kernel/kthread.c
index 4c29340c8010..3b1d0bfe312d 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -971,6 +971,59 @@ static bool __kthread_cancel_work(struct kthread_work *work, bool is_dwork,
 	return false;
 }
 
+/**
+ * kthread_mod_delayed_work - modify delay of or queue a kthread delayed work
+ * @worker: kthread worker to use
+ * @dwork: kthread delayed work to queue
+ * @delay: number of jiffies to wait before queuing
+ *
+ * If @dwork is idle, equivalent to kthread_queue_delayed_work(). Otherwise,
+ * modify @dwork's timer so that it expires after @delay. If @delay is zero,
+ * @work is guaranteed to be queued immediately.
+ *
+ * Return: %true if @dwork was pending and its timer was modified,
+ * %false otherwise.
+ *
+ * A special case is when the work is being canceled in parallel.
+ * It might be caused either by the real kthread_cancel_delayed_work_sync()
+ * or yet another kthread_mod_delayed_work() call. We let the other command
+ * win and return %false here. The caller is supposed to synchronize these
+ * operations a reasonable way.
+ *
+ * This function is safe to call from any context including IRQ handler.
+ * See __kthread_cancel_work() and kthread_delayed_work_timer_fn()
+ * for details.
+ */
+bool kthread_mod_delayed_work(struct kthread_worker *worker,
+			      struct kthread_delayed_work *dwork,
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
+	/* Work must not be used with more workers, see kthread_queue_work() */
+	WARN_ON_ONCE(work->worker != worker);
+
+	/* Do not fight with another command that is canceling this work. */
+	if (work->canceling)
+		goto out;
+
+	ret = __kthread_cancel_work(work, true, &flags);
+fast_queue:
+	__kthread_queue_delayed_work(worker, dwork, delay);
+out:
+	spin_unlock_irqrestore(&worker->lock, flags);
+	return ret;
+}
+EXPORT_SYMBOL_GPL(kthread_mod_delayed_work);
+
 static bool __kthread_cancel_work_sync(struct kthread_work *work, bool is_dwork)
 {
 	struct kthread_worker *worker = work->worker;
-- 
1.8.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
