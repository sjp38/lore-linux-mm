Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 7A8AA6B007B
	for <linux-mm@kvack.org>; Mon, 23 Nov 2009 09:09:28 -0500 (EST)
From: Gleb Natapov <gleb@redhat.com>
Subject: [PATCH v2 10/12] Maintain preemptability count even for !CONFIG_PREEMPT kernels
Date: Mon, 23 Nov 2009 16:06:05 +0200
Message-Id: <1258985167-29178-11-git-send-email-gleb@redhat.com>
In-Reply-To: <1258985167-29178-1-git-send-email-gleb@redhat.com>
References: <1258985167-29178-1-git-send-email-gleb@redhat.com>
Sender: owner-linux-mm@kvack.org
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com
List-ID: <linux-mm.kvack.org>

Do not preempt kernel. Just maintain counter to know if task can be rescheduled.
Asynchronous page fault may be delivered while spinlock is held or current
process can't be preempted for other reasons. KVM uses preempt_count() to check if preemptions is allowed and schedule other process if possible. This works
with preemptable kernels since they maintain accurate information about
preemptability in preempt_count. This patch make non-preemptable kernel
maintain accurate information in preempt_count too.

Signed-off-by: Gleb Natapov <gleb@redhat.com>
---
 include/linux/hardirq.h |   14 +++-----------
 include/linux/preempt.h |   22 ++++++++++++++++------
 include/linux/sched.h   |    4 ----
 kernel/sched.c          |    6 ------
 lib/kernel_lock.c       |    1 +
 5 files changed, 20 insertions(+), 27 deletions(-)

diff --git a/include/linux/hardirq.h b/include/linux/hardirq.h
index 6d527ee..484ba38 100644
--- a/include/linux/hardirq.h
+++ b/include/linux/hardirq.h
@@ -2,9 +2,7 @@
 #define LINUX_HARDIRQ_H
 
 #include <linux/preempt.h>
-#ifdef CONFIG_PREEMPT
 #include <linux/smp_lock.h>
-#endif
 #include <linux/lockdep.h>
 #include <linux/ftrace_irq.h>
 #include <asm/hardirq.h>
@@ -92,13 +90,8 @@
  */
 #define in_nmi()	(preempt_count() & NMI_MASK)
 
-#if defined(CONFIG_PREEMPT)
-# define PREEMPT_INATOMIC_BASE kernel_locked()
-# define PREEMPT_CHECK_OFFSET 1
-#else
-# define PREEMPT_INATOMIC_BASE 0
-# define PREEMPT_CHECK_OFFSET 0
-#endif
+#define PREEMPT_CHECK_OFFSET 1
+#define PREEMPT_INATOMIC_BASE kernel_locked()
 
 /*
  * Are we running in atomic context?  WARNING: this macro cannot
@@ -116,12 +109,11 @@
 #define in_atomic_preempt_off() \
 		((preempt_count() & ~PREEMPT_ACTIVE) != PREEMPT_CHECK_OFFSET)
 
+#define IRQ_EXIT_OFFSET (HARDIRQ_OFFSET-1)
 #ifdef CONFIG_PREEMPT
 # define preemptible()	(preempt_count() == 0 && !irqs_disabled())
-# define IRQ_EXIT_OFFSET (HARDIRQ_OFFSET-1)
 #else
 # define preemptible()	0
-# define IRQ_EXIT_OFFSET HARDIRQ_OFFSET
 #endif
 
 #if defined(CONFIG_SMP) || defined(CONFIG_GENERIC_HARDIRQS)
diff --git a/include/linux/preempt.h b/include/linux/preempt.h
index 72b1a10..7d039ca 100644
--- a/include/linux/preempt.h
+++ b/include/linux/preempt.h
@@ -82,14 +82,24 @@ do { \
 
 #else
 
-#define preempt_disable()		do { } while (0)
-#define preempt_enable_no_resched()	do { } while (0)
-#define preempt_enable()		do { } while (0)
+#define preempt_disable() \
+do { \
+	inc_preempt_count(); \
+	barrier(); \
+} while (0)
+
+#define preempt_enable() \
+do { \
+	barrier(); \
+	dec_preempt_count(); \
+} while (0)
+
+#define preempt_enable_no_resched()	preempt_enable()
 #define preempt_check_resched()		do { } while (0)
 
-#define preempt_disable_notrace()		do { } while (0)
-#define preempt_enable_no_resched_notrace()	do { } while (0)
-#define preempt_enable_notrace()		do { } while (0)
+#define preempt_disable_notrace()		preempt_disable()
+#define preempt_enable_no_resched_notrace()	preempt_enable()
+#define preempt_enable_notrace()		preempt_enable()
 
 #endif
 
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 75e6e60..1895486 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -2379,11 +2379,7 @@ extern int _cond_resched(void);
 
 extern int __cond_resched_lock(spinlock_t *lock);
 
-#ifdef CONFIG_PREEMPT
 #define PREEMPT_LOCK_OFFSET	PREEMPT_OFFSET
-#else
-#define PREEMPT_LOCK_OFFSET	0
-#endif
 
 #define cond_resched_lock(lock) ({				\
 	__might_sleep(__FILE__, __LINE__, PREEMPT_LOCK_OFFSET);	\
diff --git a/kernel/sched.c b/kernel/sched.c
index 3c11ae0..92ce282 100644
--- a/kernel/sched.c
+++ b/kernel/sched.c
@@ -2590,10 +2590,8 @@ void sched_fork(struct task_struct *p, int clone_flags)
 #if defined(CONFIG_SMP) && defined(__ARCH_WANT_UNLOCKED_CTXSW)
 	p->oncpu = 0;
 #endif
-#ifdef CONFIG_PREEMPT
 	/* Want to start with kernel preemption disabled. */
 	task_thread_info(p)->preempt_count = 1;
-#endif
 	plist_node_init(&p->pushable_tasks, MAX_PRIO);
 
 	put_cpu();
@@ -6973,11 +6971,7 @@ void __cpuinit init_idle(struct task_struct *idle, int cpu)
 	spin_unlock_irqrestore(&rq->lock, flags);
 
 	/* Set the preempt count _outside_ the spinlocks! */
-#if defined(CONFIG_PREEMPT)
 	task_thread_info(idle)->preempt_count = (idle->lock_depth >= 0);
-#else
-	task_thread_info(idle)->preempt_count = 0;
-#endif
 	/*
 	 * The idle tasks have their own, simple scheduling class:
 	 */
diff --git a/lib/kernel_lock.c b/lib/kernel_lock.c
index 39f1029..6e2659d 100644
--- a/lib/kernel_lock.c
+++ b/lib/kernel_lock.c
@@ -93,6 +93,7 @@ static inline void __lock_kernel(void)
  */
 static inline void __lock_kernel(void)
 {
+	preempt_disable();
 	_raw_spin_lock(&kernel_flag);
 }
 #endif
-- 
1.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
