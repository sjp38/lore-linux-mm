Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 61364828E2
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 10:48:08 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id b14so86747487wmb.1
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 07:48:08 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d71si25195206wmi.16.2016.01.25.07.48.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 25 Jan 2016 07:48:07 -0800 (PST)
From: Petr Mladek <pmladek@suse.com>
Subject: [PATCH v4 11/22] kthread: Better support freezable kthread workers
Date: Mon, 25 Jan 2016 16:45:00 +0100
Message-Id: <1453736711-6703-12-git-send-email-pmladek@suse.com>
In-Reply-To: <1453736711-6703-1-git-send-email-pmladek@suse.com>
References: <1453736711-6703-1-git-send-email-pmladek@suse.com>
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
 include/linux/kthread.h | 11 ++++++++---
 kernel/kthread.c        | 17 ++++++++++++-----
 2 files changed, 20 insertions(+), 8 deletions(-)

diff --git a/include/linux/kthread.h b/include/linux/kthread.h
index f501dfeaa0e3..2dad7020047f 100644
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
@@ -154,12 +159,12 @@ extern void __init_kthread_worker(struct kthread_worker *worker,
 
 int kthread_worker_fn(void *worker_ptr);
 
-__printf(1, 2)
+__printf(2, 3)
 struct kthread_worker *
-create_kthread_worker(const char namefmt[], ...);
+create_kthread_worker(unsigned int flags, const char namefmt[], ...);
 
 struct kthread_worker *
-create_kthread_worker_on_cpu(int cpu, const char namefmt[]);
+create_kthread_worker_on_cpu(unsigned int flags, int cpu, const char namefmt[]);
 
 bool queue_kthread_work(struct kthread_worker *worker,
 			struct kthread_work *work);
diff --git a/kernel/kthread.c b/kernel/kthread.c
index ebb91848685f..53c4d5a7c723 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -556,6 +556,7 @@ void __init_kthread_worker(struct kthread_worker *worker,
 				const char *name,
 				struct lock_class_key *key)
 {
+	worker->flags = 0;
 	spin_lock_init(&worker->lock);
 	lockdep_set_class_and_name(&worker->lock, key, name);
 	INIT_LIST_HEAD(&worker->work_list);
@@ -605,6 +606,10 @@ int kthread_worker_fn(void *worker_ptr)
 	 */
 	WARN_ON(worker->task && worker->task != current);
 	worker->task = current;
+
+	if (worker->flags & KTW_FREEZABLE)
+		set_freezable();
+
 repeat:
 	set_current_state(TASK_INTERRUPTIBLE);	/* mb paired w/ kthread_stop */
 
@@ -638,7 +643,8 @@ repeat:
 EXPORT_SYMBOL_GPL(kthread_worker_fn);
 
 static struct kthread_worker *
-__create_kthread_worker(int cpu, const char namefmt[], va_list args)
+__create_kthread_worker(unsigned int flags, int cpu,
+			const char namefmt[], va_list args)
 {
 	struct kthread_worker *worker;
 	struct task_struct *task;
@@ -658,6 +664,7 @@ __create_kthread_worker(int cpu, const char namefmt[], va_list args)
 	if (IS_ERR(task))
 		goto fail_task;
 
+	worker->flags = flags;
 	worker->task = task;
 	wake_up_process(task);
 	return worker;
@@ -676,13 +683,13 @@ fail_task:
  * the worker was SIGKILLed.
  */
 struct kthread_worker *
-create_kthread_worker(const char namefmt[], ...)
+create_kthread_worker(unsigned int flags, const char namefmt[], ...)
 {
 	struct kthread_worker *worker;
 	va_list args;
 
 	va_start(args, namefmt);
-	worker = __create_kthread_worker(-1, namefmt, args);
+	worker = __create_kthread_worker(flags, -1, namefmt, args);
 	va_end(args);
 
 	return worker;
@@ -706,12 +713,12 @@ EXPORT_SYMBOL(create_kthread_worker);
  * ERR_PTR(-EINVAL) on invalid @cpu.
  */
 struct kthread_worker *
-create_kthread_worker_on_cpu(int cpu, const char namefmt[])
+create_kthread_worker_on_cpu(unsigned int flags, int cpu, const char namefmt[])
 {
 	if (cpu < 0 || cpu > num_possible_cpus())
 		return ERR_PTR(-EINVAL);
 
-	return __create_kthread_worker(cpu, namefmt, NULL);
+	return __create_kthread_worker(flags, cpu, namefmt, NULL);
 }
 EXPORT_SYMBOL(create_kthread_worker_on_cpu);
 
-- 
1.8.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
