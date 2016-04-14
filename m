Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 78C2A828DF
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 11:15:34 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id k200so48871530lfg.1
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 08:15:34 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gi5si45749913wjb.102.2016.04.14.08.15.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 14 Apr 2016 08:15:33 -0700 (PDT)
From: Petr Mladek <pmladek@suse.com>
Subject: [PATCH v6 10/20] kthread: Better support freezable kthread workers
Date: Thu, 14 Apr 2016 17:14:29 +0200
Message-Id: <1460646879-617-11-git-send-email-pmladek@suse.com>
In-Reply-To: <1460646879-617-1-git-send-email-pmladek@suse.com>
References: <1460646879-617-1-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>

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
 include/linux/kthread.h | 12 +++++++++---
 kernel/kthread.c        | 21 +++++++++++++++------
 2 files changed, 24 insertions(+), 9 deletions(-)

diff --git a/include/linux/kthread.h b/include/linux/kthread.h
index 1d5ca191562f..edad163b26d0 100644
--- a/include/linux/kthread.h
+++ b/include/linux/kthread.h
@@ -65,7 +65,12 @@ struct kthread_work;
 typedef void (*kthread_work_func_t)(struct kthread_work *work);
 void delayed_kthread_work_timer_fn(unsigned long __data);
 
+enum {
+	KTW_FREEZABLE		= 1 << 0,	/* freeze during suspend */
+};
+
 struct kthread_worker {
+	unsigned int		flags;
 	spinlock_t		lock;
 	struct list_head	work_list;
 	struct list_head	delayed_work_list;
@@ -154,12 +159,13 @@ extern void __init_kthread_worker(struct kthread_worker *worker,
 
 int kthread_worker_fn(void *worker_ptr);
 
-__printf(1, 2)
+__printf(2, 3)
 struct kthread_worker *
-create_kthread_worker(const char namefmt[], ...);
+create_kthread_worker(unsigned int flags, const char namefmt[], ...);
 
 struct kthread_worker *
-create_kthread_worker_on_cpu(int cpu, const char namefmt[], ...);
+create_kthread_worker_on_cpu(int cpu, unsigned int flags,
+			     const char namefmt[], ...);
 
 bool queue_kthread_work(struct kthread_worker *worker,
 			struct kthread_work *work);
diff --git a/kernel/kthread.c b/kernel/kthread.c
index 2cc32cad66ef..4ee4c05f8bf7 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -556,11 +556,11 @@ void __init_kthread_worker(struct kthread_worker *worker,
 				const char *name,
 				struct lock_class_key *key)
 {
+	memset(worker, 0, sizeof(struct kthread_worker));
 	spin_lock_init(&worker->lock);
 	lockdep_set_class_and_name(&worker->lock, key, name);
 	INIT_LIST_HEAD(&worker->work_list);
 	INIT_LIST_HEAD(&worker->delayed_work_list);
-	worker->task = NULL;
 }
 EXPORT_SYMBOL_GPL(__init_kthread_worker);
 
@@ -590,6 +590,10 @@ int kthread_worker_fn(void *worker_ptr)
 	 */
 	WARN_ON(worker->task && worker->task != current);
 	worker->task = current;
+
+	if (worker->flags & KTW_FREEZABLE)
+		set_freezable();
+
 repeat:
 	set_current_state(TASK_INTERRUPTIBLE);	/* mb paired w/ kthread_stop */
 
@@ -623,7 +627,8 @@ repeat:
 EXPORT_SYMBOL_GPL(kthread_worker_fn);
 
 static struct kthread_worker *
-__create_kthread_worker(int cpu, const char namefmt[], va_list args)
+__create_kthread_worker(int cpu, unsigned int flags,
+			const char namefmt[], va_list args)
 {
 	struct kthread_worker *worker;
 	struct task_struct *task;
@@ -653,6 +658,7 @@ __create_kthread_worker(int cpu, const char namefmt[], va_list args)
 	if (IS_ERR(task))
 		goto fail_task;
 
+	worker->flags = flags;
 	worker->task = task;
 	wake_up_process(task);
 	return worker;
@@ -664,6 +670,7 @@ fail_task:
 
 /**
  * create_kthread_worker - create a kthread worker
+ * @flags: flags modifying the default behavior of the worker
  * @namefmt: printf-style name for the kthread worker (task).
  *
  * Returns a pointer to the allocated worker on success, ERR_PTR(-ENOMEM)
@@ -671,13 +678,13 @@ fail_task:
  * when the worker was SIGKILLed.
  */
 struct kthread_worker *
-create_kthread_worker(const char namefmt[], ...)
+create_kthread_worker(unsigned int flags, const char namefmt[], ...)
 {
 	struct kthread_worker *worker;
 	va_list args;
 
 	va_start(args, namefmt);
-	worker = __create_kthread_worker(-1, namefmt, args);
+	worker = __create_kthread_worker(-1, flags, namefmt, args);
 	va_end(args);
 
 	return worker;
@@ -688,6 +695,7 @@ EXPORT_SYMBOL(create_kthread_worker);
  * create_kthread_worker_on_cpu - create a kthread worker and bind it
  *	it to a given CPU and the associated NUMA node.
  * @cpu: CPU number
+ * @flags: flags modifying the default behavior of the worker
  * @namefmt: printf-style name for the kthread worker (task).
  *
  * Use a valid CPU number if you want to bind the kthread worker
@@ -701,13 +709,14 @@ EXPORT_SYMBOL(create_kthread_worker);
  * when the worker was SIGKILLed.
  */
 struct kthread_worker *
-create_kthread_worker_on_cpu(int cpu, const char namefmt[], ...)
+create_kthread_worker_on_cpu(int cpu, unsigned int flags,
+			     const char namefmt[], ...)
 {
 	struct kthread_worker *worker;
 	va_list args;
 
 	va_start(args, namefmt);
-	worker = __create_kthread_worker(cpu, namefmt, args);
+	worker = __create_kthread_worker(cpu, flags, namefmt, args);
 	va_end(args);
 
 	return worker;
-- 
1.8.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
