Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 70E3F6B025F
	for <linux-mm@kvack.org>; Tue, 28 Jul 2015 10:40:28 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so160499469wib.0
        for <linux-mm@kvack.org>; Tue, 28 Jul 2015 07:40:28 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id jc5si13315087wic.74.2015.07.28.07.40.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Jul 2015 07:40:18 -0700 (PDT)
From: Petr Mladek <pmladek@suse.com>
Subject: [RFC PATCH 12/14] kthread_worker: Better support freezable kthread workers
Date: Tue, 28 Jul 2015 16:39:29 +0200
Message-Id: <1438094371-8326-13-git-send-email-pmladek@suse.com>
In-Reply-To: <1438094371-8326-1-git-send-email-pmladek@suse.com>
References: <1438094371-8326-1-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, live-patching@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>

This patch allows to make kthread worker freezable via a new @flags
parameter. It will allow to avoid an init work in some kthreads.

It currently does not affect the function of kthread_worker_fn()
but it might help to do some optimization or fixes eventually.

I currently do not know about any other use for the @flags
parameter but I believe that we will want more flags
in the future.

Finally, I hope that it will not cause confusion with @flags member
in struct kthread. Well, I guess that we will want to rework the
basic kthreads implementation once all kthreads are converted into
kthread workers or workqueues. It is possible that we will merge
the two structures.

Signed-off-by: Petr Mladek <pmladek@suse.com>
---
 include/linux/kthread.h              | 13 +++++++++----
 kernel/kthread.c                     |  8 +++++++-
 kernel/rcu/tree.c                    |  3 ++-
 kernel/trace/ring_buffer_benchmark.c |  2 +-
 mm/huge_memory.c                     |  2 +-
 5 files changed, 20 insertions(+), 8 deletions(-)

diff --git a/include/linux/kthread.h b/include/linux/kthread.h
index 02d3cc9ad923..d916b024e986 100644
--- a/include/linux/kthread.h
+++ b/include/linux/kthread.h
@@ -63,7 +63,12 @@ extern int tsk_fork_get_node(struct task_struct *tsk);
 struct kthread_work;
 typedef void (*kthread_work_func_t)(struct kthread_work *work);
 
+enum {
+	KTW_FREEZABLE		= 1 << 2,	/* freeze during suspend */
+};
+
 struct kthread_worker {
+	unsigned int		flags;
 	spinlock_t		lock;
 	struct list_head	work_list;
 	struct task_struct	*task;
@@ -129,13 +134,13 @@ static inline bool kthread_worker_created(struct kthread_worker *worker)
 
 int kthread_worker_fn(void *worker_ptr);
 
-__printf(3, 4)
+__printf(4, 5)
 int create_kthread_worker_on_node(struct kthread_worker *worker,
-				  int node,
+				  unsigned int flags, int node,
 				  const char namefmt[], ...);
 
-#define create_kthread_worker(worker, namefmt, arg...)			\
-	create_kthread_worker_on_node(worker, -1, namefmt, ##arg)
+#define create_kthread_worker(worker, flags, namefmt, arg...)		\
+	create_kthread_worker_on_node(worker, flags, -1, namefmt, ##arg)
 
 bool queue_kthread_work(struct kthread_worker *worker,
 			struct kthread_work *work);
diff --git a/kernel/kthread.c b/kernel/kthread.c
index 053c9dfa58ac..d02509e17f7e 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -535,6 +535,7 @@ void __init_kthread_worker(struct kthread_worker *worker,
 				const char *name,
 				struct lock_class_key *key)
 {
+	worker->flags = 0;
 	spin_lock_init(&worker->lock);
 	lockdep_set_class_and_name(&worker->lock, key, name);
 	INIT_LIST_HEAD(&worker->work_list);
@@ -569,6 +570,10 @@ int kthread_worker_fn(void *worker_ptr)
 	 */
 	WARN_ON(worker->task && worker->task != current);
 	worker->task = current;
+
+	if (worker->flags & KTW_FREEZABLE)
+		set_freezable();
+
 repeat:
 	set_current_state(TASK_INTERRUPTIBLE);	/* mb paired w/ kthread_stop */
 
@@ -611,7 +616,7 @@ EXPORT_SYMBOL_GPL(kthread_worker_fn);
  * in @node, to get NUMA affinity for kthread stack, or else give -1.
  */
 int create_kthread_worker_on_node(struct kthread_worker *worker,
-				  int node,
+				  unsigned int flags, int node,
 				  const char namefmt[], ...)
 {
 	struct task_struct *task;
@@ -633,6 +638,7 @@ int create_kthread_worker_on_node(struct kthread_worker *worker,
 	set_bit(KTHREAD_IS_WORKER, &kthread->flags);
 
 	spin_lock_irq(&worker->lock);
+	worker->flags = flags;
 	worker->task = task;
 	spin_unlock_irq(&worker->lock);
 
diff --git a/kernel/rcu/tree.c b/kernel/rcu/tree.c
index 475bd59509ed..3a286f3b8b3c 100644
--- a/kernel/rcu/tree.c
+++ b/kernel/rcu/tree.c
@@ -3935,7 +3935,8 @@ static int __init rcu_spawn_gp_kthread(void)
 		init_kthread_worker(&rsp->gp_worker);
 		init_kthread_work(&rsp->gp_init_work, rcu_gp_kthread_init_func);
 		init_kthread_work(&rsp->gp_work, rcu_gp_kthread_func);
-		ret = create_kthread_worker(&rsp->gp_worker, "%s", rsp->name);
+		ret = create_kthread_worker(&rsp->gp_worker, 0,
+					    "%s", rsp->name);
 		BUG_ON(ret);
 		rnp = rcu_get_root(rsp);
 		raw_spin_lock_irqsave(&rnp->lock, flags);
diff --git a/kernel/trace/ring_buffer_benchmark.c b/kernel/trace/ring_buffer_benchmark.c
index 86514babe07f..5036d284885c 100644
--- a/kernel/trace/ring_buffer_benchmark.c
+++ b/kernel/trace/ring_buffer_benchmark.c
@@ -450,7 +450,7 @@ static int __init ring_buffer_benchmark_init(void)
 			goto out_fail;
 	}
 
-	ret = create_kthread_worker(&rb_producer_worker, "rb_producer");
+	ret = create_kthread_worker(&rb_producer_worker, 0, "rb_producer");
 	if (ret)
 		goto out_kill;
 
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 55733735a487..51a514161f2b 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -159,6 +159,7 @@ static int start_stop_khugepaged(void)
 			goto out;
 
 		err = create_kthread_worker(&khugepaged_worker,
+					    KTW_FREEZABLE,
 					    "khugepaged");
 
 		if (unlikely(err)) {
@@ -2804,7 +2805,6 @@ static int khugepaged_wait_event(void)
 
 static void khugepaged_init_func(struct kthread_work *dummy)
 {
-	set_freezable();
 	set_user_nice(current, MAX_NICE);
 }
 
-- 
1.8.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
