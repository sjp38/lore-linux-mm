Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3DE776B0261
	for <linux-mm@kvack.org>; Mon, 30 May 2016 11:00:42 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id h68so51685137lfh.2
        for <linux-mm@kvack.org>; Mon, 30 May 2016 08:00:42 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 201si31162877wmf.118.2016.05.30.08.00.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 30 May 2016 08:00:41 -0700 (PDT)
From: Petr Mladek <pmladek@suse.com>
Subject: [PATCH v7 05/10] kthread: Add destroy_kthread_worker()
Date: Mon, 30 May 2016 16:59:26 +0200
Message-Id: <1464620371-31346-6-git-send-email-pmladek@suse.com>
In-Reply-To: <1464620371-31346-1-git-send-email-pmladek@suse.com>
References: <1464620371-31346-1-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>

The current kthread worker users call flush() and stop() explicitly.
This function drains the worker, stops it, and frees the kthread_worker
struct in one call.

It is supposed to be used together with create_kthread_worker*() that
allocates struct kthread_worker.

Also note that drain() correctly handles self-queuing works in compare
with flush().

Signed-off-by: Petr Mladek <pmladek@suse.com>
---
 include/linux/kthread.h |  2 ++
 kernel/kthread.c        | 21 +++++++++++++++++++++
 2 files changed, 23 insertions(+)

diff --git a/include/linux/kthread.h b/include/linux/kthread.h
index 468011efa68d..a36604fa8aa2 100644
--- a/include/linux/kthread.h
+++ b/include/linux/kthread.h
@@ -136,4 +136,6 @@ bool queue_kthread_work(struct kthread_worker *worker,
 void flush_kthread_work(struct kthread_work *work);
 void flush_kthread_worker(struct kthread_worker *worker);
 
+void destroy_kthread_worker(struct kthread_worker *worker);
+
 #endif /* _LINUX_KTHREAD_H */
diff --git a/kernel/kthread.c b/kernel/kthread.c
index 6051aa9d93c6..441651765f08 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -852,3 +852,24 @@ void drain_kthread_worker(struct kthread_worker *worker)
 	spin_unlock_irq(&worker->lock);
 }
 EXPORT_SYMBOL(drain_kthread_worker);
+
+/**
+ * destroy_kthread_worker - destroy a kthread worker
+ * @worker: worker to be destroyed
+ *
+ * Drain and destroy @worker.  It has the same conditions
+ * for use as drain_kthread_worker(), see above.
+ */
+void destroy_kthread_worker(struct kthread_worker *worker)
+{
+	struct task_struct *task;
+
+	task = worker->task;
+	if (WARN_ON(!task))
+		return;
+
+	drain_kthread_worker(worker);
+	kthread_stop(task);
+	kfree(worker);
+}
+EXPORT_SYMBOL(destroy_kthread_worker);
-- 
1.8.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
