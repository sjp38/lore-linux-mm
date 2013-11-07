Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 967D06B0131
	for <linux-mm@kvack.org>; Wed,  6 Nov 2013 20:26:52 -0500 (EST)
Received: by mail-pd0-f178.google.com with SMTP id x10so320156pdj.37
        for <linux-mm@kvack.org>; Wed, 06 Nov 2013 17:26:52 -0800 (PST)
Received: from psmtp.com ([74.125.245.176])
        by mx.google.com with SMTP id y7si677855pbi.23.2013.11.06.17.26.50
        for <linux-mm@kvack.org>;
        Wed, 06 Nov 2013 17:26:50 -0800 (PST)
Subject: [PATCH v4 1/5] MCS Lock: Restructure the MCS lock defines and
 locking code into its own file
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <cover.1383783691.git.tim.c.chen@linux.intel.com>
References: <cover.1383783691.git.tim.c.chen@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 06 Nov 2013 17:26:44 -0800
Message-ID: <1383787604.11046.364.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-arch@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, "Paul
 E.McKenney" <paulmck@linux.vnet.ibm.com>, Tim Chen <tim.c.chen@linux.intel.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, Will Deacon <will.deacon@arm.com>, "Figo.zhang" <figo1802@gmail.com>

We will need the MCS lock code for doing optimistic spinning for rwsem
and queue rwlock.  Extracting the MCS code from mutex.c and put into
its own file allow us to reuse this code easily.

Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
---
 include/linux/mcs_spinlock.h |   64 ++++++++++++++++++++++++++++++++++++++++++
 include/linux/mutex.h        |    5 ++-
 kernel/locking/mutex.c       |   60 ++++----------------------------------
 3 files changed, 74 insertions(+), 55 deletions(-)
 create mode 100644 include/linux/mcs_spinlock.h

diff --git a/include/linux/mcs_spinlock.h b/include/linux/mcs_spinlock.h
new file mode 100644
index 0000000..b5de3b0
--- /dev/null
+++ b/include/linux/mcs_spinlock.h
@@ -0,0 +1,64 @@
+/*
+ * MCS lock defines
+ *
+ * This file contains the main data structure and API definitions of MCS lock.
+ *
+ * The MCS lock (proposed by Mellor-Crummey and Scott) is a simple spin-lock
+ * with the desirable properties of being fair, and with each cpu trying
+ * to acquire the lock spinning on a local variable.
+ * It avoids expensive cache bouncings that common test-and-set spin-lock
+ * implementations incur.
+ */
+#ifndef __LINUX_MCS_SPINLOCK_H
+#define __LINUX_MCS_SPINLOCK_H
+
+struct mcs_spinlock {
+	struct mcs_spinlock *next;
+	int locked; /* 1 if lock acquired */
+};
+
+/*
+ * We don't inline mcs_spin_lock() so that perf can correctly account for the
+ * time spent in this lock function.
+ */
+static noinline
+void mcs_spin_lock(struct mcs_spinlock **lock, struct mcs_spinlock *node)
+{
+	struct mcs_spinlock *prev;
+
+	/* Init node */
+	node->locked = 0;
+	node->next   = NULL;
+
+	prev = xchg(lock, node);
+	if (likely(prev == NULL)) {
+		/* Lock acquired */
+		node->locked = 1;
+		return;
+	}
+	ACCESS_ONCE(prev->next) = node;
+	smp_wmb();
+	/* Wait until the lock holder passes the lock down */
+	while (!ACCESS_ONCE(node->locked))
+		arch_mutex_cpu_relax();
+}
+
+static void mcs_spin_unlock(struct mcs_spinlock **lock, struct mcs_spinlock *node)
+{
+	struct mcs_spinlock *next = ACCESS_ONCE(node->next);
+
+	if (likely(!next)) {
+		/*
+		 * Release the lock by setting it to NULL
+		 */
+		if (cmpxchg(lock, node, NULL) == node)
+			return;
+		/* Wait until the next pointer is set */
+		while (!(next = ACCESS_ONCE(node->next)))
+			arch_mutex_cpu_relax();
+	}
+	ACCESS_ONCE(next->locked) = 1;
+	smp_wmb();
+}
+
+#endif /* __LINUX_MCS_SPINLOCK_H */
diff --git a/include/linux/mutex.h b/include/linux/mutex.h
index bab49da..32a32e6 100644
--- a/include/linux/mutex.h
+++ b/include/linux/mutex.h
@@ -46,6 +46,7 @@
  * - detects multi-task circular deadlocks and prints out all affected
  *   locks and tasks (and only those tasks)
  */
+struct mcs_spinlock;
 struct mutex {
 	/* 1: unlocked, 0: locked, negative: locked, possible waiters */
 	atomic_t		count;
@@ -55,7 +56,7 @@ struct mutex {
 	struct task_struct	*owner;
 #endif
 #ifdef CONFIG_MUTEX_SPIN_ON_OWNER
-	void			*spin_mlock;	/* Spinner MCS lock */
+	struct mcs_spinlock	*mcs_lock;	/* Spinner MCS lock */
 #endif
 #ifdef CONFIG_DEBUG_MUTEXES
 	const char 		*name;
@@ -179,4 +180,4 @@ extern int atomic_dec_and_mutex_lock(atomic_t *cnt, struct mutex *lock);
 # define arch_mutex_cpu_relax() cpu_relax()
 #endif
 
-#endif
+#endif /* __LINUX_MUTEX_H */
diff --git a/kernel/locking/mutex.c b/kernel/locking/mutex.c
index d24105b..e08b183 100644
--- a/kernel/locking/mutex.c
+++ b/kernel/locking/mutex.c
@@ -25,6 +25,7 @@
 #include <linux/spinlock.h>
 #include <linux/interrupt.h>
 #include <linux/debug_locks.h>
+#include <linux/mcs_spinlock.h>
 
 /*
  * In the DEBUG case we are using the "NULL fastpath" for mutexes,
@@ -52,7 +53,7 @@ __mutex_init(struct mutex *lock, const char *name, struct lock_class_key *key)
 	INIT_LIST_HEAD(&lock->wait_list);
 	mutex_clear_owner(lock);
 #ifdef CONFIG_MUTEX_SPIN_ON_OWNER
-	lock->spin_mlock = NULL;
+	lock->mcs_lock = NULL;
 #endif
 
 	debug_mutex_init(lock, name, key);
@@ -111,54 +112,7 @@ EXPORT_SYMBOL(mutex_lock);
  * more or less simultaneously, the spinners need to acquire a MCS lock
  * first before spinning on the owner field.
  *
- * We don't inline mspin_lock() so that perf can correctly account for the
- * time spent in this lock function.
  */
-struct mspin_node {
-	struct mspin_node *next ;
-	int		  locked;	/* 1 if lock acquired */
-};
-#define	MLOCK(mutex)	((struct mspin_node **)&((mutex)->spin_mlock))
-
-static noinline
-void mspin_lock(struct mspin_node **lock, struct mspin_node *node)
-{
-	struct mspin_node *prev;
-
-	/* Init node */
-	node->locked = 0;
-	node->next   = NULL;
-
-	prev = xchg(lock, node);
-	if (likely(prev == NULL)) {
-		/* Lock acquired */
-		node->locked = 1;
-		return;
-	}
-	ACCESS_ONCE(prev->next) = node;
-	smp_wmb();
-	/* Wait until the lock holder passes the lock down */
-	while (!ACCESS_ONCE(node->locked))
-		arch_mutex_cpu_relax();
-}
-
-static void mspin_unlock(struct mspin_node **lock, struct mspin_node *node)
-{
-	struct mspin_node *next = ACCESS_ONCE(node->next);
-
-	if (likely(!next)) {
-		/*
-		 * Release the lock by setting it to NULL
-		 */
-		if (cmpxchg(lock, node, NULL) == node)
-			return;
-		/* Wait until the next pointer is set */
-		while (!(next = ACCESS_ONCE(node->next)))
-			arch_mutex_cpu_relax();
-	}
-	ACCESS_ONCE(next->locked) = 1;
-	smp_wmb();
-}
 
 /*
  * Mutex spinning code migrated from kernel/sched/core.c
@@ -448,7 +402,7 @@ __mutex_lock_common(struct mutex *lock, long state, unsigned int subclass,
 
 	for (;;) {
 		struct task_struct *owner;
-		struct mspin_node  node;
+		struct mcs_spinlock  node;
 
 		if (use_ww_ctx && ww_ctx->acquired > 0) {
 			struct ww_mutex *ww;
@@ -470,10 +424,10 @@ __mutex_lock_common(struct mutex *lock, long state, unsigned int subclass,
 		 * If there's an owner, wait for it to either
 		 * release the lock or go to sleep.
 		 */
-		mspin_lock(MLOCK(lock), &node);
+		mcs_spin_lock(&lock->mcs_lock, &node);
 		owner = ACCESS_ONCE(lock->owner);
 		if (owner && !mutex_spin_on_owner(lock, owner)) {
-			mspin_unlock(MLOCK(lock), &node);
+			mcs_spin_unlock(&lock->mcs_lock, &node);
 			goto slowpath;
 		}
 
@@ -488,11 +442,11 @@ __mutex_lock_common(struct mutex *lock, long state, unsigned int subclass,
 			}
 
 			mutex_set_owner(lock);
-			mspin_unlock(MLOCK(lock), &node);
+			mcs_spin_unlock(&lock->mcs_lock, &node);
 			preempt_enable();
 			return 0;
 		}
-		mspin_unlock(MLOCK(lock), &node);
+		mcs_spin_unlock(&lock->mcs_lock, &node);
 
 		/*
 		 * When there's no owner, we might have preempted between the
-- 
1.7.4.4



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
