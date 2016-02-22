Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id BB3E5828F2
	for <linux-mm@kvack.org>; Mon, 22 Feb 2016 09:58:22 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id a4so166600793wme.1
        for <linux-mm@kvack.org>; Mon, 22 Feb 2016 06:58:22 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 131si28540856wmg.123.2016.02.22.06.58.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 22 Feb 2016 06:58:21 -0800 (PST)
From: Petr Mladek <pmladek@suse.com>
Subject: [PATCH v5 09/20] kthread: Allow to modify delayed kthread work
Date: Mon, 22 Feb 2016 15:56:59 +0100
Message-Id: <1456153030-12400-10-git-send-email-pmladek@suse.com>
In-Reply-To: <1456153030-12400-1-git-send-email-pmladek@suse.com>
References: <1456153030-12400-1-git-send-email-pmladek@suse.com>
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
cancel_*kthread_work_sync() operation blocks queuing until the running
work finishes. Therefore we do nothing and let cancel() win. This should
not normally happen as the caller is supposed to synchronize these
operations a reasonable way.

Signed-off-by: Petr Mladek <pmladek@suse.com>
---
 include/linux/kthread.h |  4 ++++
 kernel/kthread.c        | 45 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 49 insertions(+)

diff --git a/include/linux/kthread.h b/include/linux/kthread.h
index 28ea12942878..531730f8a8a7 100644
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
index 7e6c921b2a9a..686bdd5b6936 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -959,6 +959,51 @@ static bool __cancel_kthread_work(struct kthread_work *work, bool is_dwork)
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
+ * A special case is when cancel_work_sync() is running in parallel.
+ * It blocks further queuing. We let the cancel() win and return %false.
+ * The caller is supposed to synchronize these operations a reasonable way.
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
+	/* Work must not be used with more workers, see queue_kthread_work() */
+	WARN_ON_ONCE(work->worker && work->worker != worker);
+
+	if (work->canceling)
+		goto out;
+
+	ret = __cancel_kthread_work(work, true);
+	__queue_delayed_kthread_work(worker, dwork, delay);
+
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
