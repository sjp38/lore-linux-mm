Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 269596B0258
	for <linux-mm@kvack.org>; Tue, 28 Jul 2015 10:40:11 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so160487223wib.0
        for <linux-mm@kvack.org>; Tue, 28 Jul 2015 07:40:10 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w2si20809515wiy.40.2015.07.28.07.40.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Jul 2015 07:40:06 -0700 (PDT)
From: Petr Mladek <pmladek@suse.com>
Subject: [RFC PATCH 05/14] kthread: Add wakeup_and_destroy_kthread_worker()
Date: Tue, 28 Jul 2015 16:39:22 +0200
Message-Id: <1438094371-8326-6-git-send-email-pmladek@suse.com>
In-Reply-To: <1438094371-8326-1-git-send-email-pmladek@suse.com>
References: <1438094371-8326-1-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, live-patching@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>

Most kthreads are sleeping lots of time. They do some job either
in regular intervals or when there is an event. Many of them combine
the two approaches.

The job is either a "single" operation, e.g. check and make a huge page.
Or the kthread is serving several requests, e.g. handling several NFS
callbacks.

Anyway, the single thread could process only one request at a time
and there might be more pending requests. Some kthreads use a more
complex algorithms to prioritize the pending work, e.g. a red-black
tree used by dmcrypt_write().

I want to say that only some kthreads can be solved the "ideal" way
when a work is queued when it is needed. Instead, many kthreads will
use self-queuing works that will monitor the state and wait for
the job inside the work. It means that we will need to wakeup
the currently processing job when the worker is going to be
destroyed. This is where this function will be useful.

Signed-off-by: Petr Mladek <pmladek@suse.com>
---
 include/linux/kthread.h |  1 +
 kernel/kthread.c        | 25 +++++++++++++++++++++++++
 2 files changed, 26 insertions(+)

diff --git a/include/linux/kthread.h b/include/linux/kthread.h
index a0b811c95c75..24d72bac27db 100644
--- a/include/linux/kthread.h
+++ b/include/linux/kthread.h
@@ -138,5 +138,6 @@ void flush_kthread_work(struct kthread_work *work);
 void flush_kthread_worker(struct kthread_worker *worker);
 
 void destroy_kthread_worker(struct kthread_worker *worker);
+void wakeup_and_destroy_kthread_worker(struct kthread_worker *worker);
 
 #endif /* _LINUX_KTHREAD_H */
diff --git a/kernel/kthread.c b/kernel/kthread.c
index 4f6b20710eb3..053c9dfa58ac 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -875,3 +875,28 @@ void destroy_kthread_worker(struct kthread_worker *worker)
 	WARN_ON(kthread_stop(task));
 }
 EXPORT_SYMBOL(destroy_kthread_worker);
+
+/**
+ * wakeup_and_destroy_kthread_worker - wake up and destroy a kthread worker
+ * @worker: worker to be destroyed
+ *
+ * Wakeup potentially sleeping work and destroy the @worker. All users should
+ * be aware that they should not produce more work anymore. It is especially
+ * useful for self-queuing works that are waiting for some job inside the work.
+ * They are supposed to wake up, check the situation, and stop re-queuing.
+ */
+void wakeup_and_destroy_kthread_worker(struct kthread_worker *worker)
+{
+	struct task_struct *task = worker->task;
+
+	if (WARN_ON(!task))
+		return;
+
+	spin_lock_irq(&worker->lock);
+	if (worker->current_work)
+		wake_up_process(worker->task);
+	spin_unlock_irq(&worker->lock);
+
+	destroy_kthread_worker(worker);
+}
+EXPORT_SYMBOL(wakeup_and_destroy_kthread_worker);
-- 
1.8.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
