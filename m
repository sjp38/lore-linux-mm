Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id DFEC4828E2
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 10:48:05 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id r129so69547955wmr.0
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 07:48:05 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l10si29116663wjx.231.2016.01.25.07.48.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 25 Jan 2016 07:48:04 -0800 (PST)
From: Petr Mladek <pmladek@suse.com>
Subject: [PATCH v4 10/22] kthread: Allow to modify delayed kthread work
Date: Mon, 25 Jan 2016 16:44:59 +0100
Message-Id: <1453736711-6703-11-git-send-email-pmladek@suse.com>
In-Reply-To: <1453736711-6703-1-git-send-email-pmladek@suse.com>
References: <1453736711-6703-1-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>

There are situations when we need to modify the delay of a delayed kthread
work. For example, when the work depends on an event and the initial delay
means a timeout. Then we want to queue the work immediately when the event
happens.

This patch implements mod_delayed_kthread_work() as inspired workqueues.
It tries to cancel the pending work and queue it again with the
given timeout.

A very special case is when the work is being canceled at the same time.
cancel_*kthread_work_sync() operation blocks queuing until the running
work finishes. Therefore we do nothing and let cancel() win. This should
not normally happen as the caller is supposed to synchronize these
operations a reasonable way.

Signed-off-by: Petr Mladek <pmladek@suse.com>
---
 include/linux/kthread.h |  4 ++++
 kernel/kthread.c        | 50 +++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 54 insertions(+)

diff --git a/include/linux/kthread.h b/include/linux/kthread.h
index dd2a587a2bd7..f501dfeaa0e3 100644
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
index 6e2eeca08d5f..ebb91848685f 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -1013,6 +1013,56 @@ out:
 	return ret;
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
+ * Return: %false if @dwork was idle and queued. Return %true if @dwork was
+ * pending and its timer was modified.
+ *
+ * A special case is when cancel_work_sync() is running in parallel.
+ * It blocks further queuing. We let the cancel() win and return %false.
+ * The caller is supposed to synchronize these operations a reasonable way.
+ *
+ * This function is safe to call from any context including IRQ handler.
+ * See try_to_grab_pending_kthread_work() for details.
+ */
+bool mod_delayed_kthread_work(struct kthread_worker *worker,
+			      struct delayed_kthread_work *dwork,
+			      unsigned long delay)
+{
+	struct kthread_work *work = &dwork->work;
+	unsigned long flags;
+	int ret = 0;
+
+try_again:
+	spin_lock_irqsave(&worker->lock, flags);
+	WARN_ON_ONCE(work->worker && work->worker != worker);
+
+	if (work->canceling)
+		goto out;
+
+	ret = try_to_cancel_kthread_work(work, &worker->lock, &flags);
+	if (ret == -EAGAIN)
+		goto try_again;
+
+	if (work->canceling)
+		ret = 0;
+	else
+		__queue_delayed_kthread_work(worker, dwork, delay);
+
+out:
+	spin_unlock_irqrestore(&worker->lock, flags);
+	return ret;
+}
+EXPORT_SYMBOL_GPL(mod_delayed_kthread_work);
+
 static bool __cancel_kthread_work_sync(struct kthread_work *work)
 {
 	struct kthread_worker *worker;
-- 
1.8.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
