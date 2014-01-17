Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id D966B6B0038
	for <linux-mm@kvack.org>; Thu, 16 Jan 2014 19:08:29 -0500 (EST)
Received: by mail-pd0-f180.google.com with SMTP id x10so1970947pdj.11
        for <linux-mm@kvack.org>; Thu, 16 Jan 2014 16:08:29 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id k3si8490788pbb.24.2014.01.16.16.08.28
        for <linux-mm@kvack.org>;
        Thu, 16 Jan 2014 16:08:28 -0800 (PST)
Subject: [PATCH v7 3/6] MCS Lock: Move mcs_lock/unlock function into its
 own file
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <cover.1389890175.git.tim.c.chen@linux.intel.com>
References: <cover.1389890175.git.tim.c.chen@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 16 Jan 2014 16:08:24 -0800
Message-ID: <1389917304.3138.13.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, Will Deacon <will.deacon@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-arch@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Tim Chen <tim.c.chen@linux.intel.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

The following changes are made:

1) Create a new mcs_spinlock.c file to contain the
   mcs_spin_lock() and mcs_spin_unlock() function.
2) Include a number of prerequisite header files and define
   arch_mutex_cpu_relax(), if not previously defined so the
   mcs functions can be compiled for multiple architecture without
   causing problems.

From: Waiman Long <Waiman.Long@hp.com>
Signed-off-by: Waiman Long <Waiman.Long@hp.com>
Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
---
 include/linux/mcs_spinlock.h                       | 56 ++--------------------
 kernel/locking/Makefile                            |  6 +--
 .../locking/mcs_spinlock.c                         | 33 ++++++-------
 3 files changed, 24 insertions(+), 71 deletions(-)
 copy include/linux/mcs_spinlock.h => kernel/locking/mcs_spinlock.c (75%)

diff --git a/include/linux/mcs_spinlock.h b/include/linux/mcs_spinlock.h
index 96f14299..d54bb23 100644
--- a/include/linux/mcs_spinlock.h
+++ b/include/linux/mcs_spinlock.h
@@ -17,57 +17,9 @@ struct mcs_spinlock {
 	int locked; /* 1 if lock acquired */
 };
 
-/*
- * In order to acquire the lock, the caller should declare a local node and
- * pass a reference of the node to this function in addition to the lock.
- * If the lock has already been acquired, then this will proceed to spin
- * on this node->locked until the previous lock holder sets the node->locked
- * in mcs_spin_unlock().
- *
- * We don't inline mcs_spin_lock() so that perf can correctly account for the
- * time spent in this lock function.
- */
-static noinline
-void mcs_spin_lock(struct mcs_spinlock **lock, struct mcs_spinlock *node)
-{
-	struct mcs_spinlock *prev;
-
-	/* Init node */
-	node->locked = 0;
-	node->next   = NULL;
-
-	prev = xchg(lock, node);
-	if (likely(prev == NULL)) {
-		/* Lock acquired */
-		return;
-	}
-	ACCESS_ONCE(prev->next) = node;
-	smp_wmb();
-	/* Wait until the lock holder passes the lock down */
-	while (!ACCESS_ONCE(node->locked))
-		arch_mutex_cpu_relax();
-}
-
-/*
- * Releases the lock. The caller should pass in the corresponding node that
- * was used to acquire the lock.
- */
-static void mcs_spin_unlock(struct mcs_spinlock **lock, struct mcs_spinlock *node)
-{
-	struct mcs_spinlock *next = ACCESS_ONCE(node->next);
-
-	if (likely(!next)) {
-		/*
-		 * Release the lock by setting it to NULL
-		 */
-		if (likely(cmpxchg(lock, node, NULL) == node))
-			return;
-		/* Wait until the next pointer is set */
-		while (!(next = ACCESS_ONCE(node->next)))
-			arch_mutex_cpu_relax();
-	}
-	ACCESS_ONCE(next->locked) = 1;
-	smp_wmb();
-}
+extern
+void mcs_spin_lock(struct mcs_spinlock **lock, struct mcs_spinlock *node);
+extern
+void mcs_spin_unlock(struct mcs_spinlock **lock, struct mcs_spinlock *node);
 
 #endif /* __LINUX_MCS_SPINLOCK_H */
diff --git a/kernel/locking/Makefile b/kernel/locking/Makefile
index baab8e5..20d9d5c 100644
--- a/kernel/locking/Makefile
+++ b/kernel/locking/Makefile
@@ -13,12 +13,12 @@ obj-$(CONFIG_LOCKDEP) += lockdep.o
 ifeq ($(CONFIG_PROC_FS),y)
 obj-$(CONFIG_LOCKDEP) += lockdep_proc.o
 endif
-obj-$(CONFIG_SMP) += spinlock.o
-obj-$(CONFIG_PROVE_LOCKING) += spinlock.o
+obj-$(CONFIG_SMP) += spinlock.o mcs_spinlock.o
+obj-$(CONFIG_PROVE_LOCKING) += spinlock.o mcs_spinlock.o
 obj-$(CONFIG_RT_MUTEXES) += rtmutex.o
 obj-$(CONFIG_DEBUG_RT_MUTEXES) += rtmutex-debug.o
 obj-$(CONFIG_RT_MUTEX_TESTER) += rtmutex-tester.o
-obj-$(CONFIG_DEBUG_SPINLOCK) += spinlock.o
+obj-$(CONFIG_DEBUG_SPINLOCK) += spinlock.o mcs_spinlock.o
 obj-$(CONFIG_DEBUG_SPINLOCK) += spinlock_debug.o
 obj-$(CONFIG_RWSEM_GENERIC_SPINLOCK) += rwsem-spinlock.o
 obj-$(CONFIG_RWSEM_XCHGADD_ALGORITHM) += rwsem-xadd.o
diff --git a/include/linux/mcs_spinlock.h b/kernel/locking/mcs_spinlock.c
similarity index 75%
copy from include/linux/mcs_spinlock.h
copy to kernel/locking/mcs_spinlock.c
index 96f14299..44fb092 100644
--- a/include/linux/mcs_spinlock.h
+++ b/kernel/locking/mcs_spinlock.c
@@ -1,7 +1,5 @@
 /*
- * MCS lock defines
- *
- * This file contains the main data structure and API definitions of MCS lock.
+ * MCS lock
  *
  * The MCS lock (proposed by Mellor-Crummey and Scott) is a simple spin-lock
  * with the desirable properties of being fair, and with each cpu trying
@@ -9,13 +7,20 @@
  * It avoids expensive cache bouncings that common test-and-set spin-lock
  * implementations incur.
  */
-#ifndef __LINUX_MCS_SPINLOCK_H
-#define __LINUX_MCS_SPINLOCK_H
+/*
+ * asm/processor.h may define arch_mutex_cpu_relax().
+ * If it is not defined, cpu_relax() will be used.
+ */
+#include <asm/barrier.h>
+#include <asm/cmpxchg.h>
+#include <asm/processor.h>
+#include <linux/compiler.h>
+#include <linux/mcs_spinlock.h>
+#include <linux/export.h>
 
-struct mcs_spinlock {
-	struct mcs_spinlock *next;
-	int locked; /* 1 if lock acquired */
-};
+#ifndef arch_mutex_cpu_relax
+# define arch_mutex_cpu_relax() cpu_relax()
+#endif
 
 /*
  * In order to acquire the lock, the caller should declare a local node and
@@ -23,11 +28,7 @@ struct mcs_spinlock {
  * If the lock has already been acquired, then this will proceed to spin
  * on this node->locked until the previous lock holder sets the node->locked
  * in mcs_spin_unlock().
- *
- * We don't inline mcs_spin_lock() so that perf can correctly account for the
- * time spent in this lock function.
  */
-static noinline
 void mcs_spin_lock(struct mcs_spinlock **lock, struct mcs_spinlock *node)
 {
 	struct mcs_spinlock *prev;
@@ -47,12 +48,13 @@ void mcs_spin_lock(struct mcs_spinlock **lock, struct mcs_spinlock *node)
 	while (!ACCESS_ONCE(node->locked))
 		arch_mutex_cpu_relax();
 }
+EXPORT_SYMBOL_GPL(mcs_spin_lock);
 
 /*
  * Releases the lock. The caller should pass in the corresponding node that
  * was used to acquire the lock.
  */
-static void mcs_spin_unlock(struct mcs_spinlock **lock, struct mcs_spinlock *node)
+void mcs_spin_unlock(struct mcs_spinlock **lock, struct mcs_spinlock *node)
 {
 	struct mcs_spinlock *next = ACCESS_ONCE(node->next);
 
@@ -69,5 +71,4 @@ static void mcs_spin_unlock(struct mcs_spinlock **lock, struct mcs_spinlock *nod
 	ACCESS_ONCE(next->locked) = 1;
 	smp_wmb();
 }
-
-#endif /* __LINUX_MCS_SPINLOCK_H */
+EXPORT_SYMBOL_GPL(mcs_spin_unlock);
-- 
1.7.11.7



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
