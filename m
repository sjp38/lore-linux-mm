Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id CD9476B0265
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 07:19:06 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id r5so25598263wmr.0
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 04:19:06 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id nj9si4767596wjb.213.2016.06.16.04.19.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Jun 2016 04:19:05 -0700 (PDT)
From: Petr Mladek <pmladek@suse.com>
Subject: [PATCH v9 07/12] kthread: Add kthread_destroy_worker()
Date: Thu, 16 Jun 2016 13:17:26 +0200
Message-Id: <1466075851-24013-8-git-send-email-pmladek@suse.com>
In-Reply-To: <1466075851-24013-1-git-send-email-pmladek@suse.com>
References: <1466075851-24013-1-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>

The current kthread worker users call flush() and stop() explicitly.
This function drains the worker, stops it, and frees the kthread_worker
struct in one call.

It is supposed to be used together with kthread_create_worker*() that
allocates struct kthread_worker.

Also note that drain() correctly handles self-queuing works in compare
with flush().

Signed-off-by: Petr Mladek <pmladek@suse.com>
---
 include/linux/kthread.h |  2 ++
 kernel/kthread.c        | 21 +++++++++++++++++++++
 2 files changed, 23 insertions(+)

diff --git a/include/linux/kthread.h b/include/linux/kthread.h
index c889b653f8cb..b2c4dcea8f51 100644
--- a/include/linux/kthread.h
+++ b/include/linux/kthread.h
@@ -137,4 +137,6 @@ void kthread_flush_work(struct kthread_work *work);
 void kthread_flush_worker(struct kthread_worker *worker);
 void kthread_drain_worker(struct kthread_worker *worker);
 
+void kthread_destroy_worker(struct kthread_worker *worker);
+
 #endif /* _LINUX_KTHREAD_H */
diff --git a/kernel/kthread.c b/kernel/kthread.c
index 4454b1267718..567ec49b4872 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -853,3 +853,24 @@ void kthread_drain_worker(struct kthread_worker *worker)
 	spin_unlock_irq(&worker->lock);
 }
 EXPORT_SYMBOL(kthread_drain_worker);
+
+/**
+ * kthread_destroy_worker - destroy a kthread worker
+ * @worker: worker to be destroyed
+ *
+ * Drain and destroy @worker.  It has the same conditions
+ * for use as kthread_drain_worker(), see above.
+ */
+void kthread_destroy_worker(struct kthread_worker *worker)
+{
+	struct task_struct *task;
+
+	task = worker->task;
+	if (WARN_ON(!task))
+		return;
+
+	kthread_drain_worker(worker);
+	kthread_stop(task);
+	kfree(worker);
+}
+EXPORT_SYMBOL(kthread_destroy_worker);
-- 
1.8.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
