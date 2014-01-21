Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id ED83D6B00B6
	for <linux-mm@kvack.org>; Tue, 21 Jan 2014 18:36:09 -0500 (EST)
Received: by mail-pb0-f44.google.com with SMTP id rq2so9019580pbb.17
        for <linux-mm@kvack.org>; Tue, 21 Jan 2014 15:36:09 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id l8si7292700pao.65.2014.01.21.15.36.08
        for <linux-mm@kvack.org>;
        Tue, 21 Jan 2014 15:36:08 -0800 (PST)
Subject: [PATCH v9 3/6] MCS Lock: Optimizations and extra comments
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <cover.1390320729.git.tim.c.chen@linux.intel.com>
References: <cover.1390320729.git.tim.c.chen@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 21 Jan 2014 15:36:05 -0800
Message-ID: <1390347365.3138.64.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, Will Deacon <will.deacon@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-arch@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Tim Chen <tim.c.chen@linux.intel.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

From: Jason Low <jason.low2@hp.com>

Remove unnecessary operation to assign locked status to 1 if lock is
acquired without contention. Lock status will not be checked by lock
holder again once it is acquired and any lock
contenders will not be looking at the lock holder's lock status.

Make the cmpxchg(lock, node, NULL) == node check in mcs_spin_unlock()
likely() as it is likely that a race did not occur most of the time.

Also add in more comments describing how the local node is used in MCS locks.

Reviewed-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Reviewed-by: Tim Chen <tim.c.chen@linux.intel.com>
Signed-off-by: Jason Low <jason.low2@hp.com>
Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
---
 include/linux/mcs_spinlock.h | 27 ++++++++++++++++++++++++---
 1 file changed, 24 insertions(+), 3 deletions(-)

diff --git a/include/linux/mcs_spinlock.h b/include/linux/mcs_spinlock.h
index 9578ef8..143fa42 100644
--- a/include/linux/mcs_spinlock.h
+++ b/include/linux/mcs_spinlock.h
@@ -25,6 +25,17 @@ struct mcs_spinlock {
  * with mcs_unlock and mcs_lock pair, smp_mb__after_unlock_lock() should be
  * used after mcs_lock.
  */
+
+/*
+ * In order to acquire the lock, the caller should declare a local node and
+ * pass a reference of the node to this function in addition to the lock.
+ * If the lock has already been acquired, then this will proceed to spin
+ * on this node->locked until the previous lock holder sets the node->locked
+ * in mcs_spin_unlock().
+ *
+ * We don't inline mcs_spin_lock() so that perf can correctly account for the
+ * time spent in this lock function.
+ */
 static inline
 void mcs_spin_lock(struct mcs_spinlock **lock, struct mcs_spinlock *node)
 {
@@ -36,8 +47,14 @@ void mcs_spin_lock(struct mcs_spinlock **lock, struct mcs_spinlock *node)
 
 	prev = xchg(lock, node);
 	if (likely(prev == NULL)) {
-		/* Lock acquired */
-		node->locked = 1;
+		/*
+		 * Lock acquired, don't need to set node->locked to 1. Threads
+		 * only spin on its own node->locked value for lock acquisition.
+		 * However, since this thread can immediately acquire the lock
+		 * and does not proceed to spin on its own node->locked, this
+		 * value won't be used. If a debug mode is needed to
+		 * audit lock status, then set node->locked value here.
+		 */
 		return;
 	}
 	ACCESS_ONCE(prev->next) = node;
@@ -50,6 +67,10 @@ void mcs_spin_lock(struct mcs_spinlock **lock, struct mcs_spinlock *node)
 		arch_mutex_cpu_relax();
 }
 
+/*
+ * Releases the lock. The caller should pass in the corresponding node that
+ * was used to acquire the lock.
+ */
 static inline
 void mcs_spin_unlock(struct mcs_spinlock **lock, struct mcs_spinlock *node)
 {
@@ -59,7 +80,7 @@ void mcs_spin_unlock(struct mcs_spinlock **lock, struct mcs_spinlock *node)
 		/*
 		 * Release the lock by setting it to NULL
 		 */
-		if (cmpxchg(lock, node, NULL) == node)
+		if (likely(cmpxchg(lock, node, NULL) == node))
 			return;
 		/* Wait until the next pointer is set */
 		while (!(next = ACCESS_ONCE(node->next)))
-- 
1.7.11.7



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
