Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id A3DCD6B0257
	for <linux-mm@kvack.org>; Tue, 28 Jul 2015 10:40:08 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so160485314wib.0
        for <linux-mm@kvack.org>; Tue, 28 Jul 2015 07:40:08 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p2si37553344wjf.71.2015.07.28.07.40.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Jul 2015 07:40:05 -0700 (PDT)
From: Petr Mladek <pmladek@suse.com>
Subject: [RFC PATCH 04/14] kthread: Add destroy_kthread_worker()
Date: Tue, 28 Jul 2015 16:39:21 +0200
Message-Id: <1438094371-8326-5-git-send-email-pmladek@suse.com>
In-Reply-To: <1438094371-8326-1-git-send-email-pmladek@suse.com>
References: <1438094371-8326-1-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, live-patching@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>

The current kthread worker users call flush() and stop() explicitly.
The new function will make it easier and will do it better.

Note that flush() does not guarantee that the queue is empty. drain()
is more safe. It returns when the queue is empty. Also is causes
that queue() ignores unexpected works and warns about it.

Signed-off-by: Petr Mladek <pmladek@suse.com>
---
 include/linux/kthread.h |  2 ++
 kernel/kthread.c        | 20 ++++++++++++++++++++
 2 files changed, 22 insertions(+)

diff --git a/include/linux/kthread.h b/include/linux/kthread.h
index 974d70193907..a0b811c95c75 100644
--- a/include/linux/kthread.h
+++ b/include/linux/kthread.h
@@ -137,4 +137,6 @@ bool queue_kthread_work(struct kthread_worker *worker,
 void flush_kthread_work(struct kthread_work *work);
 void flush_kthread_worker(struct kthread_worker *worker);
 
+void destroy_kthread_worker(struct kthread_worker *worker);
+
 #endif /* _LINUX_KTHREAD_H */
diff --git a/kernel/kthread.c b/kernel/kthread.c
index 872f17e383c4..4f6b20710eb3 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -855,3 +855,23 @@ void drain_kthread_worker(struct kthread_worker *worker)
 	spin_unlock_irq(&worker->lock);
 }
 EXPORT_SYMBOL(drain_kthread_worker);
+
+/**
+ * destroy_kthread_worker - destroy a kthread worker
+ * @worker: worker to be destroyed
+ *
+ * Destroy @worker. It should be idle when this is called.
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
+
+	WARN_ON(kthread_stop(task));
+}
+EXPORT_SYMBOL(destroy_kthread_worker);
-- 
1.8.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
