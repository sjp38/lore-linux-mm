Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 13B33828F2
	for <linux-mm@kvack.org>; Tue,  9 Aug 2016 10:56:15 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id l4so24965567wml.0
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 07:56:15 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id jo1si26146251wjb.272.2016.08.09.07.56.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 09 Aug 2016 07:56:00 -0700 (PDT)
From: Petr Mladek <pmladek@suse.com>
Subject: [PATCH v10 06/11] kthread: Add kthread_destroy_worker()
Date: Tue,  9 Aug 2016 16:55:40 +0200
Message-Id: <1470754545-17632-7-git-send-email-pmladek@suse.com>
In-Reply-To: <1470754545-17632-1-git-send-email-pmladek@suse.com>
References: <1470754545-17632-1-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>

The current kthread worker users call flush() and stop() explicitly.
This function does the same plus it frees the kthread_worker struct
in one call.

It is supposed to be used together with kthread_create_worker*() that
allocates struct kthread_worker.

Signed-off-by: Petr Mladek <pmladek@suse.com>
---
 include/linux/kthread.h |  2 ++
 kernel/kthread.c        | 23 +++++++++++++++++++++++
 2 files changed, 25 insertions(+)

diff --git a/include/linux/kthread.h b/include/linux/kthread.h
index daeb2befbabf..afc8939da861 100644
--- a/include/linux/kthread.h
+++ b/include/linux/kthread.h
@@ -136,4 +136,6 @@ bool kthread_queue_work(struct kthread_worker *worker,
 void kthread_flush_work(struct kthread_work *work);
 void kthread_flush_worker(struct kthread_worker *worker);
 
+void kthread_destroy_worker(struct kthread_worker *worker);
+
 #endif /* _LINUX_KTHREAD_H */
diff --git a/kernel/kthread.c b/kernel/kthread.c
index d9ba5e229cd3..3dc7f26d84d7 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -819,3 +819,26 @@ void kthread_flush_worker(struct kthread_worker *worker)
 	wait_for_completion(&fwork.done);
 }
 EXPORT_SYMBOL_GPL(kthread_flush_worker);
+
+/**
+ * kthread_destroy_worker - destroy a kthread worker
+ * @worker: worker to be destroyed
+ *
+ * Flush and destroy @worker.  The simple flush is enough because the kthread
+ * worker API is used only in trivial scenarios.  There are no multi-step state
+ * machines needed.
+ */
+void kthread_destroy_worker(struct kthread_worker *worker)
+{
+	struct task_struct *task;
+
+	task = worker->task;
+	if (WARN_ON(!task))
+		return;
+
+	kthread_flush_worker(worker);
+	kthread_stop(task);
+	WARN_ON(!list_empty(&worker->work_list));
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
