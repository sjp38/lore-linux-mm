Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3987B828F2
	for <linux-mm@kvack.org>; Tue,  9 Aug 2016 10:56:17 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id l4so24966702wml.0
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 07:56:17 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fb6si35165674wjb.196.2016.08.09.07.56.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 09 Aug 2016 07:56:01 -0700 (PDT)
From: Petr Mladek <pmladek@suse.com>
Subject: [PATCH v10 07/11] kthread: Detect when a kthread work is used by more workers
Date: Tue,  9 Aug 2016 16:55:41 +0200
Message-Id: <1470754545-17632-8-git-send-email-pmladek@suse.com>
In-Reply-To: <1470754545-17632-1-git-send-email-pmladek@suse.com>
References: <1470754545-17632-1-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>

Nothing currently prevents a work from queuing for a kthread worker
when it is already running on another one. This means that the work
might run in parallel on more than one worker. Also some operations
are not reliable, e.g. flush.

This problem will be even more visible after we add kthread_cancel_work()
function. It will only have "work" as the parameter and will use
worker->lock to synchronize with others.

Well, normally this is not a problem because the API users are sane.
But bugs might happen and users also might be crazy.

This patch adds a warning when we try to insert the work for another
worker. It does not fully prevent the misuse because it would make the
code much more complicated without a big benefit.

It adds the same warning also into kthread_flush_work() instead of
the repeated attempts to get the right lock.

A side effect is that one needs to explicitly reinitialize the work
if it must be queued into another worker. This is needed, for example,
when the worker is stopped and started again. It is a bit inconvenient.
But it looks like a good compromise between the stability and complexity.

I have double checked all existing users of the kthread worker API
and they all seems to initialize the work after the worker gets
started.

Just for completeness, the patch adds a check that the work is not
already in a queue.

The patch also puts all the checks into a separate function. It will
be reused when implementing delayed works.

Signed-off-by: Petr Mladek <pmladek@suse.com>
---
 kernel/kthread.c | 28 ++++++++++++++++++++--------
 1 file changed, 20 insertions(+), 8 deletions(-)

diff --git a/kernel/kthread.c b/kernel/kthread.c
index 3dc7f26d84d7..48002a46b647 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -574,6 +574,9 @@ EXPORT_SYMBOL_GPL(__kthread_init_worker);
  * The works are not allowed to keep any locks, disable preemption or interrupts
  * when they finish. There is defined a safe point for freezing when one work
  * finishes and before a new one is started.
+ *
+ * Also the works must not be handled by more than one worker at the same time,
+ * see also kthread_queue_work().
  */
 int kthread_worker_fn(void *worker_ptr)
 {
@@ -710,12 +713,21 @@ kthread_create_worker_on_cpu(int cpu, const char namefmt[], ...)
 }
 EXPORT_SYMBOL(kthread_create_worker_on_cpu);
 
+static void kthread_insert_work_sanity_check(struct kthread_worker *worker,
+					     struct kthread_work *work)
+{
+	lockdep_assert_held(&worker->lock);
+	WARN_ON_ONCE(!list_empty(&work->node));
+	/* Do not use a work with >1 worker, see kthread_queue_work() */
+	WARN_ON_ONCE(work->worker && work->worker != worker);
+}
+
 /* insert @work before @pos in @worker */
 static void kthread_insert_work(struct kthread_worker *worker,
-			       struct kthread_work *work,
-			       struct list_head *pos)
+				struct kthread_work *work,
+				struct list_head *pos)
 {
-	lockdep_assert_held(&worker->lock);
+	kthread_insert_work_sanity_check(worker, work);
 
 	list_add_tail(&work->node, pos);
 	work->worker = worker;
@@ -731,6 +743,9 @@ static void kthread_insert_work(struct kthread_worker *worker,
  * Queue @work to work processor @task for async execution.  @task
  * must have been created with kthread_worker_create().  Returns %true
  * if @work was successfully queued, %false if it was already pending.
+ *
+ * Reinitialize the work if it needs to be used by another worker.
+ * For example, when the worker was stopped and started again.
  */
 bool kthread_queue_work(struct kthread_worker *worker,
 			struct kthread_work *work)
@@ -775,16 +790,13 @@ void kthread_flush_work(struct kthread_work *work)
 	struct kthread_worker *worker;
 	bool noop = false;
 
-retry:
 	worker = work->worker;
 	if (!worker)
 		return;
 
 	spin_lock_irq(&worker->lock);
-	if (work->worker != worker) {
-		spin_unlock_irq(&worker->lock);
-		goto retry;
-	}
+	/* Work must not be used with >1 worker, see kthread_queue_work(). */
+	WARN_ON_ONCE(work->worker != worker);
 
 	if (!list_empty(&work->node))
 		kthread_insert_work(worker, &fwork.work, work->node.next);
-- 
1.8.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
