Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id EEB0D6B0263
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 07:18:58 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id a2so24183857lfe.0
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 04:18:58 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z10si4768622wjj.209.2016.06.16.04.18.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Jun 2016 04:18:57 -0700 (PDT)
From: Petr Mladek <pmladek@suse.com>
Subject: [PATCH v9 06/12] kthread: Add kthread_drain_worker()
Date: Thu, 16 Jun 2016 13:17:25 +0200
Message-Id: <1466075851-24013-7-git-send-email-pmladek@suse.com>
In-Reply-To: <1466075851-24013-1-git-send-email-pmladek@suse.com>
References: <1466075851-24013-1-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>

kthread_flush_worker() returns when the currently queued works are proceed.
But some other works might have been queued in the meantime.

This patch adds kthread_drain_worker() that is inspired by
drain_workqueue(). It returns when the queue is completely
empty and warns when it takes too long.

The initial implementation does not block queuing new works when
draining. It makes things much easier. The blocking would be useful
to debug potential problems but it is not clear if it is worth
the complication at the moment.

Signed-off-by: Petr Mladek <pmladek@suse.com>
---
 include/linux/kthread.h |  1 +
 kernel/kthread.c        | 34 ++++++++++++++++++++++++++++++++++
 2 files changed, 35 insertions(+)

diff --git a/include/linux/kthread.h b/include/linux/kthread.h
index f68041837dd6..c889b653f8cb 100644
--- a/include/linux/kthread.h
+++ b/include/linux/kthread.h
@@ -135,5 +135,6 @@ bool kthread_queue_work(struct kthread_worker *worker,
 			struct kthread_work *work);
 void kthread_flush_work(struct kthread_work *work);
 void kthread_flush_worker(struct kthread_worker *worker);
+void kthread_drain_worker(struct kthread_worker *worker);
 
 #endif /* _LINUX_KTHREAD_H */
diff --git a/kernel/kthread.c b/kernel/kthread.c
index 590b9f699e9d..4454b1267718 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -819,3 +819,37 @@ void kthread_flush_worker(struct kthread_worker *worker)
 	wait_for_completion(&fwork.done);
 }
 EXPORT_SYMBOL_GPL(kthread_flush_worker);
+
+/**
+ * kthread_drain_worker - drain a kthread worker
+ * @worker: worker to be drained
+ *
+ * Wait until there is no work queued for the given kthread worker.
+ * @worker is flushed repeatedly until it becomes empty.  The number
+ * of flushing is determined by the depth of chaining and should
+ * be relatively short.  Whine if it takes too long.
+ *
+ * The caller is responsible for blocking all users of this kthread
+ * worker from queuing new works. Also it is responsible for blocking
+ * the already queued works from an infinite re-queuing!
+ */
+void kthread_drain_worker(struct kthread_worker *worker)
+{
+	int flush_cnt = 0;
+
+	spin_lock_irq(&worker->lock);
+
+	while (!list_empty(&worker->work_list)) {
+		spin_unlock_irq(&worker->lock);
+
+		kthread_flush_worker(worker);
+		WARN_ONCE(flush_cnt++ > 10,
+			  "kthread worker %s: kthread_drain_worker() isn't complete after %u tries\n",
+			  worker->task->comm, flush_cnt);
+
+		spin_lock_irq(&worker->lock);
+	}
+
+	spin_unlock_irq(&worker->lock);
+}
+EXPORT_SYMBOL(kthread_drain_worker);
-- 
1.8.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
