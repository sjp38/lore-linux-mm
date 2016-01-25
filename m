Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 0E5E2828E2
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 10:47:58 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id l65so69411458wmf.1
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 07:47:58 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b6si25073375wmh.122.2016.01.25.07.47.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 25 Jan 2016 07:47:57 -0800 (PST)
From: Petr Mladek <pmladek@suse.com>
Subject: [PATCH v4 07/22] kthread: Detect when a kthread work is used by more workers
Date: Mon, 25 Jan 2016 16:44:56 +0100
Message-Id: <1453736711-6703-8-git-send-email-pmladek@suse.com>
In-Reply-To: <1453736711-6703-1-git-send-email-pmladek@suse.com>
References: <1453736711-6703-1-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>

Nothing currently prevents a work from queuing for a kthread worker
when it is already running on another one. This means that the work
might run in parallel on more workers. Also some operations, e.g.
flush or drain are not reliable.

This problem will be even more visible after we add cancel_kthread_work()
function. It will only have "work" as the parameter and will use
worker->lock to synchronize with others.

Well, normally this is not a problem because the API users are sane.
But bugs might happen and users also might be crazy.

This patch adds a warning when we try to insert the work for another
worker. It does not fully prevent the misuse because it would make the
code much more complicated without a big benefit.

A side effect is that one needs to explicitely reinitialize the work
if it must be queued into another worker. This is needed, for example,
when the worker is stopped and started again. It is a bit inconvenient.
But it looks like a good compromise between the stability and complexity.

Just for completeness, the patch adds a check for disabled interrupts
and an empty queue.

The patch also puts all the checks into a separate function. It will
be reused when implementing delayed works.

Signed-off-by: Petr Mladek <pmladek@suse.com>
---
 kernel/kthread.c | 28 +++++++++++++++++++++++++---
 1 file changed, 25 insertions(+), 3 deletions(-)

diff --git a/kernel/kthread.c b/kernel/kthread.c
index 1d41e0faef2d..e12576bc0e39 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -574,6 +574,9 @@ EXPORT_SYMBOL_GPL(__init_kthread_worker);
  * The works are not allowed to keep any locks, disable preemption or interrupts
  * when they finish. There is defined a safe point for freezing when one work
  * finishes and before a new one is started.
+ *
+ * Also the works must not be handled by more workers at the same time, see also
+ * queue_kthread_work().
  */
 int kthread_worker_fn(void *worker_ptr)
 {
@@ -696,12 +699,22 @@ create_kthread_worker_on_cpu(int cpu, const char namefmt[])
 }
 EXPORT_SYMBOL(create_kthread_worker_on_cpu);
 
+static void insert_kthread_work_sanity_check(struct kthread_worker *worker,
+					       struct kthread_work *work)
+{
+	lockdep_assert_held(&worker->lock);
+	WARN_ON_ONCE(!irqs_disabled());
+	WARN_ON_ONCE(!list_empty(&work->node));
+	/* Do not use a work with more workers, see queue_kthread_work() */
+	WARN_ON_ONCE(work->worker && work->worker != worker);
+}
+
 /* insert @work before @pos in @worker */
 static void insert_kthread_work(struct kthread_worker *worker,
-			       struct kthread_work *work,
-			       struct list_head *pos)
+				struct kthread_work *work,
+				struct list_head *pos)
 {
-	lockdep_assert_held(&worker->lock);
+	insert_kthread_work_sanity_check(worker, work);
 
 	list_add_tail(&work->node, pos);
 	work->worker = worker;
@@ -717,6 +730,15 @@ static void insert_kthread_work(struct kthread_worker *worker,
  * Queue @work to work processor @task for async execution.  @task
  * must have been created with kthread_worker_create().  Returns %true
  * if @work was successfully queued, %false if it was already pending.
+ *
+ * Never queue a work into a worker when it is being processed by another
+ * one. Otherwise, some operations, e.g. cancel or flush, will not work
+ * correctly or the work might run in parallel. This is not enforced
+ * because it would make the code too complex. There are only warnings
+ * printed when such a situation is detected.
+ *
+ * Reinitialize the work if it needs to be used by another worker.
+ * For example, when the worker was stopped and started again.
  */
 bool queue_kthread_work(struct kthread_worker *worker,
 			struct kthread_work *work)
-- 
1.8.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
