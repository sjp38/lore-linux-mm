Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id 3865D6B003A
	for <linux-mm@kvack.org>; Tue, 19 Nov 2013 20:37:54 -0500 (EST)
Received: by mail-pb0-f49.google.com with SMTP id jt11so4644566pbb.36
        for <linux-mm@kvack.org>; Tue, 19 Nov 2013 17:37:53 -0800 (PST)
Received: from psmtp.com ([74.125.245.143])
        by mx.google.com with SMTP id yj7si6691446pab.25.2013.11.19.17.37.51
        for <linux-mm@kvack.org>;
        Tue, 19 Nov 2013 17:37:53 -0800 (PST)
Subject: [PATCH v6 5/5] MCS Lock: Allows for architecture specific mcs lock
 and unlock
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <cover.1384885312.git.tim.c.chen@linux.intel.com>
References: <cover.1384885312.git.tim.c.chen@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 19 Nov 2013 17:37:47 -0800
Message-ID: <1384911467.11046.455.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-arch@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, "Paul
 E.McKenney" <paulmck@linux.vnet.ibm.com>, Tim Chen <tim.c.chen@linux.intel.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, Will Deacon <will.deacon@arm.com>, "Figo.zhang" <figo1802@gmail.com>

Restructure code to allow for architecture specific defines
of the arch_mcs_spin_lock and arch_mcs_spin_unlock funtion
that can be optimized for specific architecture.  These
arch specific functions can be placed in asm/mcs_spinlock.h.
Otherwise the default arch_mcs_spin_lock and arch_mcs_spin_unlock
will be used.

Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
---
 arch/Kconfig                  |  3 ++
 include/linux/mcs_spinlock.h  |  5 +++
 kernel/locking/mcs_spinlock.c | 93 +++++++++++++++++++++++++------------------
 3 files changed, 62 insertions(+), 39 deletions(-)

diff --git a/arch/Kconfig b/arch/Kconfig
index ded747c..c96c696 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -306,6 +306,9 @@ config HAVE_CMPXCHG_LOCAL
 config HAVE_CMPXCHG_DOUBLE
 	bool
 
+config HAVE_ARCH_MCS_LOCK
+	bool
+
 config ARCH_WANT_IPC_PARSE_VERSION
 	bool
 
diff --git a/include/linux/mcs_spinlock.h b/include/linux/mcs_spinlock.h
index d54bb23..d64786a 100644
--- a/include/linux/mcs_spinlock.h
+++ b/include/linux/mcs_spinlock.h
@@ -12,6 +12,11 @@
 #ifndef __LINUX_MCS_SPINLOCK_H
 #define __LINUX_MCS_SPINLOCK_H
 
+/* arch specific mcs lock and unlock functions defined here */
+#ifdef CONFIG_HAVE_ARCH_MCS_LOCK
+#include <asm/mcs_spinlock.h>
+#endif
+
 struct mcs_spinlock {
 	struct mcs_spinlock *next;
 	int locked; /* 1 if lock acquired */
diff --git a/kernel/locking/mcs_spinlock.c b/kernel/locking/mcs_spinlock.c
index 6f2ce8e..582584a 100644
--- a/kernel/locking/mcs_spinlock.c
+++ b/kernel/locking/mcs_spinlock.c
@@ -29,28 +29,36 @@
  * on this node->locked until the previous lock holder sets the node->locked
  * in mcs_spin_unlock().
  */
+#ifndef arch_mcs_spin_lock
+#define arch_mcs_spin_lock(lock, node)					\
+{									\
+	struct mcs_spinlock *prev;					\
+									\
+	/* Init node */							\
+	node->locked = 0;						\
+	node->next   = NULL;						\
+									\
+	/* xchg() provides a memory barrier */				\
+	prev = xchg(lock, node);					\
+	if (likely(prev == NULL)) {					\
+		/* Lock acquired */					\
+		return;							\
+	}								\
+	ACCESS_ONCE(prev->next) = node;					\
+	/*								\
+	 * Wait until the lock holder passes the lock down.		\
+	 * Using smp_load_acquire() provides a memory barrier that	\
+	 * ensures subsequent operations happen after the lock is	\
+	 * acquired.							\
+	 */								\
+	while (!(smp_load_acquire(&node->locked)))			\
+		arch_mutex_cpu_relax();					\
+}
+#endif
+
 void mcs_spin_lock(struct mcs_spinlock **lock, struct mcs_spinlock *node)
 {
-	struct mcs_spinlock *prev;
-
-	/* Init node */
-	node->locked = 0;
-	node->next   = NULL;
-
-	/* xchg() provides a memory barrier */
-	prev = xchg(lock, node);
-	if (likely(prev == NULL)) {
-		/* Lock acquired */
-		return;
-	}
-	ACCESS_ONCE(prev->next) = node;
-	/*
-	 * Wait until the lock holder passes the lock down.
-	 * Using smp_load_acquire() provides a memory barrier that
-	 * ensures subsequent operations happen after the lock is acquired.
-	 */
-	while (!(smp_load_acquire(&node->locked)))
-		arch_mutex_cpu_relax();
+	arch_mcs_spin_lock(lock, node);
 }
 EXPORT_SYMBOL_GPL(mcs_spin_lock);
 
@@ -58,26 +66,33 @@ EXPORT_SYMBOL_GPL(mcs_spin_lock);
  * Releases the lock. The caller should pass in the corresponding node that
  * was used to acquire the lock.
  */
+#ifndef arch_mcs_spin_unlock
+#define arch_mcs_spin_unlock(lock, node)				\
+{									\
+	struct mcs_spinlock *next = ACCESS_ONCE(node->next);		\
+									\
+	if (likely(!next)) {						\
+		/*							\
+		 * Release the lock by setting it to NULL               \
+		 */							\
+		if (likely(cmpxchg(lock, node, NULL) == node))          \
+			return;                                         \
+		/* Wait until the next pointer is set */		\
+		while (!(next = ACCESS_ONCE(node->next)))		\
+			arch_mutex_cpu_relax();				\
+	}								\
+	/*								\
+	 * Pass lock to next waiter.					\
+	 * smp_store_release() provides a memory barrier to ensure	\
+	 * all operations in the critical section has been completed	\
+	 * before unlocking.						\
+	 */								\
+	smp_store_release(&next->locked, 1);				\
+}
+#endif
+
 void mcs_spin_unlock(struct mcs_spinlock **lock, struct mcs_spinlock *node)
 {
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
-	/*
-	 * Pass lock to next waiter.
-	 * smp_store_release() provides a memory barrier to ensure
-	 * all operations in the critical section has been completed
-	 * before unlocking.
-	 */
-	smp_store_release(&next->locked, 1);
+	arch_mcs_spin_unlock(lock, node);
 }
 EXPORT_SYMBOL_GPL(mcs_spin_unlock);
-- 
1.7.11.7


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
