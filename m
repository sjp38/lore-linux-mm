Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id 3EAE36B003B
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 18:10:55 -0400 (EDT)
Received: by mail-pb0-f50.google.com with SMTP id uo5so247386pbc.23
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 15:10:54 -0700 (PDT)
Subject: [PATCH v6 5/6] MCS Lock: Restructure the MCS lock defines and
 locking code into its own file
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <cover.1380144003.git.tim.c.chen@linux.intel.com>
References: <cover.1380144003.git.tim.c.chen@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 25 Sep 2013 15:10:49 -0700
Message-ID: <1380147049.3467.67.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Tim Chen <tim.c.chen@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

We will need the MCS lock code for doing optimistic spinning for rwsem.
Extracting the MCS code from mutex.c and put into its own file allow us
to reuse this code easily for rwsem.

Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
---
 include/linux/mcslock.h |   58 +++++++++++++++++++++++++++++++++++++++++++++++
 kernel/mutex.c          |   58 +++++-----------------------------------------
 2 files changed, 65 insertions(+), 51 deletions(-)
 create mode 100644 include/linux/mcslock.h

diff --git a/include/linux/mcslock.h b/include/linux/mcslock.h
new file mode 100644
index 0000000..20fd3f0
--- /dev/null
+++ b/include/linux/mcslock.h
@@ -0,0 +1,58 @@
+/*
+ * MCS lock defines
+ *
+ * This file contains the main data structure and API definitions of MCS lock.
+ */
+#ifndef __LINUX_MCSLOCK_H
+#define __LINUX_MCSLOCK_H
+
+struct mcs_spin_node {
+	struct mcs_spin_node *next;
+	int		  locked;	/* 1 if lock acquired */
+};
+
+/*
+ * We don't inline mcs_spin_lock() so that perf can correctly account for the
+ * time spent in this lock function.
+ */
+static noinline
+void mcs_spin_lock(struct mcs_spin_node **lock, struct mcs_spin_node *node)
+{
+	struct mcs_spin_node *prev;
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
+static void mcs_spin_unlock(struct mcs_spin_node **lock, struct mcs_spin_node *node)
+{
+	struct mcs_spin_node *next = ACCESS_ONCE(node->next);
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
+#endif
diff --git a/kernel/mutex.c b/kernel/mutex.c
index 6d647ae..1b6ba3f 100644
--- a/kernel/mutex.c
+++ b/kernel/mutex.c
@@ -25,6 +25,7 @@
 #include <linux/spinlock.h>
 #include <linux/interrupt.h>
 #include <linux/debug_locks.h>
+#include <linux/mcslock.h>
 
 /*
  * In the DEBUG case we are using the "NULL fastpath" for mutexes,
@@ -111,54 +112,9 @@ EXPORT_SYMBOL(mutex_lock);
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
+#define	MLOCK(mutex)	((struct mcs_spin_node **)&((mutex)->spin_mlock))
 
 /*
  * Mutex spinning code migrated from kernel/sched/core.c
@@ -448,7 +404,7 @@ __mutex_lock_common(struct mutex *lock, long state, unsigned int subclass,
 
 	for (;;) {
 		struct task_struct *owner;
-		struct mspin_node  node;
+		struct mcs_spin_node  node;
 
 		if (!__builtin_constant_p(ww_ctx == NULL) && ww_ctx->acquired > 0) {
 			struct ww_mutex *ww;
@@ -470,10 +426,10 @@ __mutex_lock_common(struct mutex *lock, long state, unsigned int subclass,
 		 * If there's an owner, wait for it to either
 		 * release the lock or go to sleep.
 		 */
-		mspin_lock(MLOCK(lock), &node);
+		mcs_spin_lock(MLOCK(lock), &node);
 		owner = ACCESS_ONCE(lock->owner);
 		if (owner && !mutex_spin_on_owner(lock, owner)) {
-			mspin_unlock(MLOCK(lock), &node);
+			mcs_spin_unlock(MLOCK(lock), &node);
 			goto slowpath;
 		}
 
@@ -488,11 +444,11 @@ __mutex_lock_common(struct mutex *lock, long state, unsigned int subclass,
 			}
 
 			mutex_set_owner(lock);
-			mspin_unlock(MLOCK(lock), &node);
+			mcs_spin_unlock(MLOCK(lock), &node);
 			preempt_enable();
 			return 0;
 		}
-		mspin_unlock(MLOCK(lock), &node);
+		mcs_spin_unlock(MLOCK(lock), &node);
 
 		/*
 		 * When there's no owner, we might have preempted between the
-- 
1.7.4.4



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
