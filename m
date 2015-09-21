Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 792066B0265
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 09:05:59 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so145416233wic.0
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 06:05:59 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gg16si17020466wic.95.2015.09.21.06.05.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 21 Sep 2015 06:05:58 -0700 (PDT)
From: Petr Mladek <pmladek@suse.com>
Subject: [RFC v2 18/18] kthread: Better support freezable kthread workers
Date: Mon, 21 Sep 2015 15:03:59 +0200
Message-Id: <1442840639-6963-19-git-send-email-pmladek@suse.com>
In-Reply-To: <1442840639-6963-1-git-send-email-pmladek@suse.com>
References: <1442840639-6963-1-git-send-email-pmladek@suse.com>
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
 include/linux/kthread.h              | 14 ++++++++++----
 kernel/kthread.c                     |  9 ++++++++-
 kernel/rcu/tree.c                    |  2 +-
 kernel/trace/ring_buffer_benchmark.c |  4 ++--
 mm/huge_memory.c                     |  4 ++--
 5 files changed, 23 insertions(+), 10 deletions(-)

diff --git a/include/linux/kthread.h b/include/linux/kthread.h
index 2110a55bd769..5f27013edd29 100644
--- a/include/linux/kthread.h
+++ b/include/linux/kthread.h
@@ -65,7 +65,12 @@ struct kthread_work;
 typedef void (*kthread_work_func_t)(struct kthread_work *work);
 void delayed_kthread_work_timer_fn(unsigned long __data);
 
+enum {
+	KTW_FREEZABLE		= 1 << 2,	/* freeze during suspend */
+};
+
 struct kthread_worker {
+	unsigned int		flags;
 	spinlock_t		lock;
 	struct list_head	work_list;
 	struct task_struct	*task;
@@ -164,12 +169,13 @@ extern void __init_kthread_worker(struct kthread_worker *worker,
 
 int kthread_worker_fn(void *worker_ptr);
 
-__printf(2, 3)
+__printf(3, 4)
 struct kthread_worker *
-create_kthread_worker_on_node(int node, const char namefmt[], ...);
+create_kthread_worker_on_node(unsigned int flags, int node,
+			      const char namefmt[], ...);
 
-#define create_kthread_worker(namefmt, arg...)				\
-	create_kthread_worker_on_node(-1, namefmt, ##arg)
+#define create_kthread_worker(flags, namefmt, arg...)			\
+	create_kthread_worker_on_node(flags, -1, namefmt, ##arg)
 
 bool queue_kthread_work(struct kthread_worker *worker,
 			struct kthread_work *work);
diff --git a/kernel/kthread.c b/kernel/kthread.c
index 27bf242064d1..3d726acb3103 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -552,6 +552,7 @@ void __init_kthread_worker(struct kthread_worker *worker,
 				const char *name,
 				struct lock_class_key *key)
 {
+	worker->flags = 0;
 	spin_lock_init(&worker->lock);
 	lockdep_set_class_and_name(&worker->lock, key, name);
 	INIT_LIST_HEAD(&worker->work_list);
@@ -585,6 +586,10 @@ int kthread_worker_fn(void *worker_ptr)
 	 */
 	WARN_ON(worker->task && worker->task != current);
 	worker->task = current;
+
+	if (worker->flags & KTW_FREEZABLE)
+		set_freezable();
+
 repeat:
 	set_current_state(TASK_INTERRUPTIBLE);	/* mb paired w/ kthread_stop */
 
@@ -631,7 +636,8 @@ EXPORT_SYMBOL_GPL(kthread_worker_fn);
  * when the worker was SIGKILLed.
  */
 struct kthread_worker *
-create_kthread_worker_on_node(int node, const char namefmt[], ...)
+create_kthread_worker_on_node(unsigned int flags, int node,
+			      const char namefmt[], ...)
 {
 	struct kthread_worker *worker;
 	struct task_struct *task;
@@ -651,6 +657,7 @@ create_kthread_worker_on_node(int node, const char namefmt[], ...)
 	if (IS_ERR(task))
 		goto fail_task;
 
+	worker->flags = flags;
 	worker->task = task;
 	wake_up_process(task);
 
diff --git a/kernel/rcu/tree.c b/kernel/rcu/tree.c
index e115c3aee65d..211a473e295b 100644
--- a/kernel/rcu/tree.c
+++ b/kernel/rcu/tree.c
@@ -4154,7 +4154,7 @@ static int __init rcu_spawn_gp_kthread(void)
 		init_kthread_work(&rsp->gp_start_work, rcu_gp_start_func);
 		init_delayed_kthread_work(&rsp->gp_handle_qs_work,
 					  rcu_gp_handle_qs_func);
-		w = create_kthread_worker("%s", rsp->name);
+		w = create_kthread_worker(0, "%s", rsp->name);
 		BUG_ON(IS_ERR(w));
 		rnp = rcu_get_root(rsp);
 		raw_spin_lock_irqsave(&rnp->lock, flags);
diff --git a/kernel/trace/ring_buffer_benchmark.c b/kernel/trace/ring_buffer_benchmark.c
index 3f27ff6debd3..1613c40f636b 100644
--- a/kernel/trace/ring_buffer_benchmark.c
+++ b/kernel/trace/ring_buffer_benchmark.c
@@ -416,14 +416,14 @@ static int __init ring_buffer_benchmark_init(void)
 		return -ENOMEM;
 
 	if (!disable_reader) {
-		rb_consumer_worker = create_kthread_worker("rb_consumer");
+		rb_consumer_worker = create_kthread_worker(0, "rb_consumer");
 		if (IS_ERR(rb_consumer_worker)) {
 			ret = PTR_ERR(rb_consumer_worker);
 			goto out_fail;
 		}
 	}
 
-	rb_producer_worker = create_kthread_worker("rb_producer");
+		rb_producer_worker = create_kthread_worker(0, "rb_producer");
 	if (IS_ERR(rb_producer_worker)) {
 		ret = PTR_ERR(rb_producer_worker);
 		goto out_kill;
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index d5030fe7b687..8651c822c3cd 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -165,7 +165,8 @@ static int start_stop_khugepaged(void)
 		if (khugepaged_worker)
 			goto out;
 
-		khugepaged_worker = create_kthread_worker("khugepaged");
+		khugepaged_worker =
+			create_kthread_worker(KTW_FREEZABLE, "khugepaged");
 
 		if (unlikely(IS_ERR(khugepaged_worker))) {
 			pr_err("khugepaged: failed to create kthread worker\n");
@@ -2878,7 +2879,6 @@ breakouterloop_mmap_sem:
 
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
