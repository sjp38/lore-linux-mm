Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C5A8B6B0272
	for <linux-mm@kvack.org>; Fri,  9 Dec 2016 00:16:37 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id a8so8641101pfg.0
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 21:16:37 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id w17si31969942pgh.156.2016.12.08.21.16.35
        for <linux-mm@kvack.org>;
        Thu, 08 Dec 2016 21:16:36 -0800 (PST)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v4 10/15] lockdep: Apply crossrelease to completion operation
Date: Fri,  9 Dec 2016 14:12:06 +0900
Message-Id: <1481260331-360-11-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1481260331-360-1-git-send-email-byungchul.park@lge.com>
References: <1481260331-360-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

wait_for_completion() and its family can cause deadlock. Nevertheless,
it cannot use the lock correntness validator because complete() will be
called in different context from the context calling
wait_for_completion(), which violates lockdep's assumption without
crossrelease feature.

However, thanks to CONFIG_LOCKDEP_CROSSRELEASE, we can apply the lockdep
detector to wait_for_completion() and complete(). Applied it.

Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 include/linux/completion.h | 121 +++++++++++++++++++++++++++++++++++++++++----
 kernel/locking/lockdep.c   |  17 +++++++
 kernel/sched/completion.c  |  54 +++++++++++---------
 lib/Kconfig.debug          |   8 +++
 4 files changed, 167 insertions(+), 33 deletions(-)

diff --git a/include/linux/completion.h b/include/linux/completion.h
index 5d5aaae..67a27af 100644
--- a/include/linux/completion.h
+++ b/include/linux/completion.h
@@ -9,6 +9,9 @@
  */
 
 #include <linux/wait.h>
+#ifdef CONFIG_LOCKDEP_COMPLETE
+#include <linux/lockdep.h>
+#endif
 
 /*
  * struct completion - structure used to maintain state for a "completion"
@@ -25,10 +28,53 @@
 struct completion {
 	unsigned int done;
 	wait_queue_head_t wait;
+#ifdef CONFIG_LOCKDEP_COMPLETE
+	struct lockdep_map map;
+	struct cross_lock xlock;
+#endif
 };
 
+#ifdef CONFIG_LOCKDEP_COMPLETE
+static inline void complete_acquire(struct completion *x)
+{
+	lock_acquire_exclusive(&x->map, 0, 0, NULL, _RET_IP_);
+}
+
+static inline void complete_release(struct completion *x)
+{
+	lock_release(&x->map, 0, _RET_IP_);
+}
+
+static inline void complete_release_commit(struct completion *x)
+{
+	lock_commit_crosslock(&x->map);
+}
+
+#define init_completion(x)				\
+do {							\
+	static struct lock_class_key __key;		\
+	lockdep_init_map_crosslock(&(x)->map,		\
+			&(x)->xlock,			\
+			"(complete)" #x,		\
+			&__key, 0);			\
+	__init_completion(x);				\
+} while (0)
+#else
+#define init_completion(x) __init_completion(x)
+static inline void complete_acquire(struct completion *x, int try) {}
+static inline void complete_release(struct completion *x) {}
+static inline void complete_release_commit(struct completion *x) {}
+#endif
+
+#ifdef CONFIG_LOCKDEP_COMPLETE
+#define COMPLETION_INITIALIZER(work) \
+	{ 0, __WAIT_QUEUE_HEAD_INITIALIZER((work).wait), \
+	STATIC_CROSS_LOCKDEP_MAP_INIT("(complete)" #work, &(work), \
+	&(work).xlock), STATIC_CROSS_LOCK_INIT()}
+#else
 #define COMPLETION_INITIALIZER(work) \
 	{ 0, __WAIT_QUEUE_HEAD_INITIALIZER((work).wait) }
+#endif
 
 #define COMPLETION_INITIALIZER_ONSTACK(work) \
 	({ init_completion(&work); work; })
@@ -70,7 +116,7 @@ struct completion {
  * This inline function will initialize a dynamically created completion
  * structure.
  */
-static inline void init_completion(struct completion *x)
+static inline void __init_completion(struct completion *x)
 {
 	x->done = 0;
 	init_waitqueue_head(&x->wait);
@@ -88,18 +134,75 @@ static inline void reinit_completion(struct completion *x)
 	x->done = 0;
 }
 
-extern void wait_for_completion(struct completion *);
-extern void wait_for_completion_io(struct completion *);
-extern int wait_for_completion_interruptible(struct completion *x);
-extern int wait_for_completion_killable(struct completion *x);
-extern unsigned long wait_for_completion_timeout(struct completion *x,
+extern void __wait_for_completion(struct completion *);
+extern void __wait_for_completion_io(struct completion *);
+extern int __wait_for_completion_interruptible(struct completion *x);
+extern int __wait_for_completion_killable(struct completion *x);
+extern unsigned long __wait_for_completion_timeout(struct completion *x,
 						   unsigned long timeout);
-extern unsigned long wait_for_completion_io_timeout(struct completion *x,
+extern unsigned long __wait_for_completion_io_timeout(struct completion *x,
 						    unsigned long timeout);
-extern long wait_for_completion_interruptible_timeout(
+extern long __wait_for_completion_interruptible_timeout(
 	struct completion *x, unsigned long timeout);
-extern long wait_for_completion_killable_timeout(
+extern long __wait_for_completion_killable_timeout(
 	struct completion *x, unsigned long timeout);
+
+static inline void wait_for_completion(struct completion *x)
+{
+	complete_acquire(x);
+	__wait_for_completion(x);
+	complete_release(x);
+}
+
+static inline void wait_for_completion_io(struct completion *x)
+{
+	complete_acquire(x);
+	__wait_for_completion_io(x);
+	complete_release(x);
+}
+
+static inline int wait_for_completion_interruptible(struct completion *x)
+{
+	int ret;
+	complete_acquire(x);
+	ret = __wait_for_completion_interruptible(x);
+	complete_release(x);
+	return ret;
+}
+
+static inline int wait_for_completion_killable(struct completion *x)
+{
+	int ret;
+	complete_acquire(x);
+	ret = __wait_for_completion_killable(x);
+	complete_release(x);
+	return ret;
+}
+
+static inline unsigned long wait_for_completion_timeout(struct completion *x,
+		unsigned long timeout)
+{
+	return __wait_for_completion_timeout(x, timeout);
+}
+
+static inline unsigned long wait_for_completion_io_timeout(struct completion *x,
+		unsigned long timeout)
+{
+	return __wait_for_completion_io_timeout(x, timeout);
+}
+
+static inline long wait_for_completion_interruptible_timeout(
+	struct completion *x, unsigned long timeout)
+{
+	return __wait_for_completion_interruptible_timeout(x, timeout);
+}
+
+static inline long wait_for_completion_killable_timeout(
+	struct completion *x, unsigned long timeout)
+{
+	return __wait_for_completion_killable_timeout(x, timeout);
+}
+
 extern bool try_wait_for_completion(struct completion *x);
 extern bool completion_done(struct completion *x);
 
diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
index cb1a600..fea69ac 100644
--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -4794,6 +4794,12 @@ static void add_plock(struct held_lock *hlock, unsigned int prev_gen_id,
 	}
 }
 
+#ifdef CONFIG_LOCKDEP_COMPLETE
+static int xlock_might_onstack = 1;
+#else
+static int xlock_might_onstack = 0;
+#endif
+
 /*
  * No contention. Irq disable is only required.
  */
@@ -4839,6 +4845,14 @@ static void check_add_plock(struct held_lock *hlock)
 	if (!current->plocks || !depend_before(hlock))
 		return;
 
+	/*
+	 * If a xlock instance is on stack, it can be overwritten randomly
+	 * after escaping the stack frame, so we cannot refer to rcu list
+	 * without holding lock.
+	 */
+	if (xlock_might_onstack && !graph_lock())
+		return;
+
 	gen_id = (unsigned int)atomic_read(&cross_gen_id);
 	gen_id_e = gen_id_done();
 	start = current->held_locks;
@@ -4862,6 +4876,9 @@ static void check_add_plock(struct held_lock *hlock)
 			break;
 		}
 	}
+
+	if (xlock_might_onstack)
+		graph_unlock();
 }
 
 /*
diff --git a/kernel/sched/completion.c b/kernel/sched/completion.c
index 8d0f35d..a8b2167 100644
--- a/kernel/sched/completion.c
+++ b/kernel/sched/completion.c
@@ -31,6 +31,10 @@ void complete(struct completion *x)
 	unsigned long flags;
 
 	spin_lock_irqsave(&x->wait.lock, flags);
+	/*
+	 * Lock dependency should be built here.
+	 */
+	complete_release_commit(x);
 	x->done++;
 	__wake_up_locked(&x->wait, TASK_NORMAL, 1);
 	spin_unlock_irqrestore(&x->wait.lock, flags);
@@ -108,7 +112,7 @@ wait_for_common_io(struct completion *x, long timeout, int state)
 }
 
 /**
- * wait_for_completion: - waits for completion of a task
+ * __wait_for_completion: - waits for completion of a task
  * @x:  holds the state of this particular completion
  *
  * This waits to be signaled for completion of a specific task. It is NOT
@@ -117,14 +121,14 @@ wait_for_common_io(struct completion *x, long timeout, int state)
  * See also similar routines (i.e. wait_for_completion_timeout()) with timeout
  * and interrupt capability. Also see complete().
  */
-void __sched wait_for_completion(struct completion *x)
+void __sched __wait_for_completion(struct completion *x)
 {
 	wait_for_common(x, MAX_SCHEDULE_TIMEOUT, TASK_UNINTERRUPTIBLE);
 }
-EXPORT_SYMBOL(wait_for_completion);
+EXPORT_SYMBOL(__wait_for_completion);
 
 /**
- * wait_for_completion_timeout: - waits for completion of a task (w/timeout)
+ * __wait_for_completion_timeout: - waits for completion of a task (w/timeout)
  * @x:  holds the state of this particular completion
  * @timeout:  timeout value in jiffies
  *
@@ -136,28 +140,28 @@ EXPORT_SYMBOL(wait_for_completion);
  * till timeout) if completed.
  */
 unsigned long __sched
-wait_for_completion_timeout(struct completion *x, unsigned long timeout)
+__wait_for_completion_timeout(struct completion *x, unsigned long timeout)
 {
 	return wait_for_common(x, timeout, TASK_UNINTERRUPTIBLE);
 }
-EXPORT_SYMBOL(wait_for_completion_timeout);
+EXPORT_SYMBOL(__wait_for_completion_timeout);
 
 /**
- * wait_for_completion_io: - waits for completion of a task
+ * __wait_for_completion_io: - waits for completion of a task
  * @x:  holds the state of this particular completion
  *
  * This waits to be signaled for completion of a specific task. It is NOT
  * interruptible and there is no timeout. The caller is accounted as waiting
  * for IO (which traditionally means blkio only).
  */
-void __sched wait_for_completion_io(struct completion *x)
+void __sched __wait_for_completion_io(struct completion *x)
 {
 	wait_for_common_io(x, MAX_SCHEDULE_TIMEOUT, TASK_UNINTERRUPTIBLE);
 }
-EXPORT_SYMBOL(wait_for_completion_io);
+EXPORT_SYMBOL(__wait_for_completion_io);
 
 /**
- * wait_for_completion_io_timeout: - waits for completion of a task (w/timeout)
+ * __wait_for_completion_io_timeout: - waits for completion of a task (w/timeout)
  * @x:  holds the state of this particular completion
  * @timeout:  timeout value in jiffies
  *
@@ -170,14 +174,14 @@ EXPORT_SYMBOL(wait_for_completion_io);
  * till timeout) if completed.
  */
 unsigned long __sched
-wait_for_completion_io_timeout(struct completion *x, unsigned long timeout)
+__wait_for_completion_io_timeout(struct completion *x, unsigned long timeout)
 {
 	return wait_for_common_io(x, timeout, TASK_UNINTERRUPTIBLE);
 }
-EXPORT_SYMBOL(wait_for_completion_io_timeout);
+EXPORT_SYMBOL(__wait_for_completion_io_timeout);
 
 /**
- * wait_for_completion_interruptible: - waits for completion of a task (w/intr)
+ * __wait_for_completion_interruptible: - waits for completion of a task (w/intr)
  * @x:  holds the state of this particular completion
  *
  * This waits for completion of a specific task to be signaled. It is
@@ -185,17 +189,18 @@ EXPORT_SYMBOL(wait_for_completion_io_timeout);
  *
  * Return: -ERESTARTSYS if interrupted, 0 if completed.
  */
-int __sched wait_for_completion_interruptible(struct completion *x)
+int __sched __wait_for_completion_interruptible(struct completion *x)
 {
 	long t = wait_for_common(x, MAX_SCHEDULE_TIMEOUT, TASK_INTERRUPTIBLE);
+
 	if (t == -ERESTARTSYS)
 		return t;
 	return 0;
 }
-EXPORT_SYMBOL(wait_for_completion_interruptible);
+EXPORT_SYMBOL(__wait_for_completion_interruptible);
 
 /**
- * wait_for_completion_interruptible_timeout: - waits for completion (w/(to,intr))
+ * __wait_for_completion_interruptible_timeout: - waits for completion (w/(to,intr))
  * @x:  holds the state of this particular completion
  * @timeout:  timeout value in jiffies
  *
@@ -206,15 +211,15 @@ EXPORT_SYMBOL(wait_for_completion_interruptible);
  * or number of jiffies left till timeout) if completed.
  */
 long __sched
-wait_for_completion_interruptible_timeout(struct completion *x,
+__wait_for_completion_interruptible_timeout(struct completion *x,
 					  unsigned long timeout)
 {
 	return wait_for_common(x, timeout, TASK_INTERRUPTIBLE);
 }
-EXPORT_SYMBOL(wait_for_completion_interruptible_timeout);
+EXPORT_SYMBOL(__wait_for_completion_interruptible_timeout);
 
 /**
- * wait_for_completion_killable: - waits for completion of a task (killable)
+ * __wait_for_completion_killable: - waits for completion of a task (killable)
  * @x:  holds the state of this particular completion
  *
  * This waits to be signaled for completion of a specific task. It can be
@@ -222,17 +227,18 @@ EXPORT_SYMBOL(wait_for_completion_interruptible_timeout);
  *
  * Return: -ERESTARTSYS if interrupted, 0 if completed.
  */
-int __sched wait_for_completion_killable(struct completion *x)
+int __sched __wait_for_completion_killable(struct completion *x)
 {
 	long t = wait_for_common(x, MAX_SCHEDULE_TIMEOUT, TASK_KILLABLE);
+
 	if (t == -ERESTARTSYS)
 		return t;
 	return 0;
 }
-EXPORT_SYMBOL(wait_for_completion_killable);
+EXPORT_SYMBOL(__wait_for_completion_killable);
 
 /**
- * wait_for_completion_killable_timeout: - waits for completion of a task (w/(to,killable))
+ * __wait_for_completion_killable_timeout: - waits for completion of a task (w/(to,killable))
  * @x:  holds the state of this particular completion
  * @timeout:  timeout value in jiffies
  *
@@ -244,12 +250,12 @@ EXPORT_SYMBOL(wait_for_completion_killable);
  * or number of jiffies left till timeout) if completed.
  */
 long __sched
-wait_for_completion_killable_timeout(struct completion *x,
+__wait_for_completion_killable_timeout(struct completion *x,
 				     unsigned long timeout)
 {
 	return wait_for_common(x, timeout, TASK_KILLABLE);
 }
-EXPORT_SYMBOL(wait_for_completion_killable_timeout);
+EXPORT_SYMBOL(__wait_for_completion_killable_timeout);
 
 /**
  *	try_wait_for_completion - try to decrement a completion without blocking
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index ef9ca8d..3466e57 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -1040,6 +1040,14 @@ config LOCKDEP_CROSSRELEASE
 	 or wait_for_complete() can use lock correctness detector using
 	 lockdep.
 
+config LOCKDEP_COMPLETE
+	bool "Lock debugging: allow completions to use deadlock detector"
+	select LOCKDEP_CROSSRELEASE
+	default n
+	help
+	 A deadlock caused by wait_for_completion() and complete() can be
+	 detected by lockdep using crossrelease feature.
+
 config PROVE_LOCKING
 	bool "Lock debugging: prove locking correctness"
 	depends on DEBUG_KERNEL && TRACE_IRQFLAGS_SUPPORT && STACKTRACE_SUPPORT && LOCKDEP_SUPPORT
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
