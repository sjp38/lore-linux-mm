Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f199.google.com (mail-lb0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 312C76B0260
	for <linux-mm@kvack.org>; Mon, 30 May 2016 11:00:35 -0400 (EDT)
Received: by mail-lb0-f199.google.com with SMTP id rs7so86813981lbb.2
        for <linux-mm@kvack.org>; Mon, 30 May 2016 08:00:35 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y128si31139202wmg.30.2016.05.30.08.00.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 30 May 2016 08:00:34 -0700 (PDT)
From: Petr Mladek <pmladek@suse.com>
Subject: [PATCH v7 04/10] kthread: Add drain_kthread_worker()
Date: Mon, 30 May 2016 16:59:25 +0200
Message-Id: <1464620371-31346-5-git-send-email-pmladek@suse.com>
In-Reply-To: <1464620371-31346-1-git-send-email-pmladek@suse.com>
References: <1464620371-31346-1-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>

flush_kthread_worker() returns when the currently queued works are proceed.
But some other works might have been queued in the meantime.

This patch adds drain_kthread_worker() that is inspired by
drain_workqueue(). It returns when the queue is completely
empty and warns when it takes too long.

The initial implementation does not block queuing new works when
draining. It makes things much easier. The blocking would be useful
to debug potential problems but it is not clear if it is worth
the complication at the moment.

Signed-off-by: Petr Mladek <pmladek@suse.com>
---
 kernel/kthread.c | 34 ++++++++++++++++++++++++++++++++++
 1 file changed, 34 insertions(+)

diff --git a/kernel/kthread.c b/kernel/kthread.c
index 76364374ff98..6051aa9d93c6 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -818,3 +818,37 @@ void flush_kthread_worker(struct kthread_worker *worker)
 	wait_for_completion(&fwork.done);
 }
 EXPORT_SYMBOL_GPL(flush_kthread_worker);
+
+/**
+ * drain_kthread_worker - drain a kthread worker
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
+void drain_kthread_worker(struct kthread_worker *worker)
+{
+	int flush_cnt = 0;
+
+	spin_lock_irq(&worker->lock);
+
+	while (!list_empty(&worker->work_list)) {
+		spin_unlock_irq(&worker->lock);
+
+		flush_kthread_worker(worker);
+		WARN_ONCE(flush_cnt++ > 10,
+			  "kthread worker %s: drain_kthread_worker() isn't complete after %u tries\n",
+			  worker->task->comm, flush_cnt);
+
+		spin_lock_irq(&worker->lock);
+	}
+
+	spin_unlock_irq(&worker->lock);
+}
+EXPORT_SYMBOL(drain_kthread_worker);
-- 
1.8.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
