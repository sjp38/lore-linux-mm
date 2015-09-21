Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id EED546B0258
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 09:05:23 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so110276956wic.0
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 06:05:23 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ph6si16970165wic.113.2015.09.21.06.05.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 21 Sep 2015 06:05:19 -0700 (PDT)
From: Petr Mladek <pmladek@suse.com>
Subject: [RFC v2 05/18] kthread: Add pending flag to kthread work
Date: Mon, 21 Sep 2015 15:03:46 +0200
Message-Id: <1442840639-6963-6-git-send-email-pmladek@suse.com>
In-Reply-To: <1442840639-6963-1-git-send-email-pmladek@suse.com>
References: <1442840639-6963-1-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, live-patching@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>

This is a preparation step for delayed kthread works. It will use
a timer to queue the work with the requested delay. We need to
somehow mark the work in the meantime.

The implementation is inspired by workqueues. It adds a flag that
is manipulated using bit operations. If the flag is set, it means
that the work is going to be queued and any new attempts to queue
the work should fail. As a side effect, queue_kthread_work() could
test pending work even without the lock.

In compare with workqueues, the flag is stored in a separate bitmap
instead of sharing with the worker pointer. Kthread worker does not
use pools of kthreads and the handling is much easier here. I did
not fix a situation where we would need to manipulate both the flag
and the worker pointer atomically.

Signed-off-by: Petr Mladek <pmladek@suse.com>
---
 include/linux/kthread.h |  6 ++++++
 kernel/kthread.c        | 30 ++++++++++++++++++++++++++----
 2 files changed, 32 insertions(+), 4 deletions(-)

diff --git a/include/linux/kthread.h b/include/linux/kthread.h
index bef97e06d2b6..aabb105d3d4b 100644
--- a/include/linux/kthread.h
+++ b/include/linux/kthread.h
@@ -71,7 +71,13 @@ struct kthread_worker {
 	struct kthread_work	*current_work;
 };
 
+enum {
+	/* work item is pending execution */
+	KTHREAD_WORK_PENDING_BIT	= 0,
+};
+
 struct kthread_work {
+	DECLARE_BITMAP(flags, 8);
 	struct list_head	node;
 	kthread_work_func_t	func;
 	struct kthread_worker	*worker;
diff --git a/kernel/kthread.c b/kernel/kthread.c
index 65c263336b8b..fe1510e7ad04 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -602,6 +602,7 @@ repeat:
 		work = list_first_entry(&worker->work_list,
 					struct kthread_work, node);
 		list_del_init(&work->node);
+		clear_bit(KTHREAD_WORK_PENDING_BIT, work->flags);
 	}
 	worker->current_work = work;
 	spin_unlock_irq(&worker->lock);
@@ -675,6 +676,27 @@ static void insert_kthread_work(struct kthread_worker *worker,
 		wake_up_process(worker->task);
 }
 
+/*
+ * Queue @work without the check for the pending flag.
+ * Must be called with IRQs disabled.
+ */
+static void __queue_kthread_work(struct kthread_worker *worker,
+			  struct kthread_work *work)
+{
+	/*
+	 * While a work item is PENDING && off queue, a task trying to
+	 * steal the PENDING will busy-loop waiting for it to either get
+	 * queued or lose PENDING.  Grabbing PENDING and queuing should
+	 * happen with IRQ disabled.
+	 */
+	WARN_ON_ONCE(!irqs_disabled());
+	WARN_ON_ONCE(!list_empty(&work->node));
+
+	spin_lock(&worker->lock);
+	insert_kthread_work(worker, work, &worker->work_list);
+	spin_unlock(&worker->lock);
+}
+
 /**
  * queue_kthread_work - queue a kthread_work
  * @worker: target kthread_worker
@@ -690,12 +712,12 @@ bool queue_kthread_work(struct kthread_worker *worker,
 	bool ret = false;
 	unsigned long flags;
 
-	spin_lock_irqsave(&worker->lock, flags);
-	if (list_empty(&work->node)) {
-		insert_kthread_work(worker, work, &worker->work_list);
+	local_irq_save(flags);
+	if (!test_and_set_bit(KTHREAD_WORK_PENDING_BIT, work->flags)) {
+		__queue_kthread_work(worker, work);
 		ret = true;
 	}
-	spin_unlock_irqrestore(&worker->lock, flags);
+	local_irq_restore(flags);
 	return ret;
 }
 EXPORT_SYMBOL_GPL(queue_kthread_work);
-- 
1.8.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
