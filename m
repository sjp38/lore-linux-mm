Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 098E76B003A
	for <linux-mm@kvack.org>; Mon, 20 Jan 2014 20:24:40 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id ld10so5418851pab.10
        for <linux-mm@kvack.org>; Mon, 20 Jan 2014 17:24:40 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id ln7si3085653pab.236.2014.01.20.17.24.39
        for <linux-mm@kvack.org>;
        Mon, 20 Jan 2014 17:24:39 -0800 (PST)
Subject: [PATCH v8 5/6] MCS Lock: allow architectures to hook in to
 contended
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <cover.1390239879.git.tim.c.chen@linux.intel.com>
References: <cover.1390239879.git.tim.c.chen@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 20 Jan 2014 17:24:35 -0800
Message-ID: <1390267475.3138.39.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, Will Deacon <will.deacon@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-arch@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Tim Chen <tim.c.chen@linux.intel.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

From: Will Deacon <will.deacon@arm.com>

When contended, architectures may be able to reduce the polling overhead
in ways which aren't expressible using a simple relax() primitive.

This patch allows architectures to hook into the mcs_{lock,unlock}
functions for the contended cases only.

Signed-off-by: Will Deacon <will.deacon@arm.com>
Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
---
 kernel/locking/mcs_spinlock.c | 42 ++++++++++++++++++++++++++++--------------
 1 file changed, 28 insertions(+), 14 deletions(-)

diff --git a/kernel/locking/mcs_spinlock.c b/kernel/locking/mcs_spinlock.c
index c3ee9cf..e12ed32 100644
--- a/kernel/locking/mcs_spinlock.c
+++ b/kernel/locking/mcs_spinlock.c
@@ -16,6 +16,28 @@
 #include <linux/mutex.h>
 #include <linux/export.h>
 
+#ifndef arch_mcs_spin_lock_contended
+/*
+ * Using smp_load_acquire() provides a memory barrier that ensures
+ * subsequent operations happen after the lock is acquired.
+ */
+#define arch_mcs_spin_lock_contended(l)					\
+do {									\
+	while (!(smp_load_acquire(l)))					\
+		arch_mutex_cpu_relax();					\
+} while (0)
+#endif
+
+#ifndef arch_mcs_spin_unlock_contended
+/*
+ * smp_store_release() provides a memory barrier to ensure all
+ * operations in the critical section has been completed before
+ * unlocking.
+ */
+#define arch_mcs_spin_unlock_contended(l)				\
+	smp_store_release((l), 1)
+#endif
+
 /*
  * Note: the smp_load_acquire/smp_store_release pair is not
  * sufficient to form a full memory barrier across
@@ -50,13 +72,9 @@ void mcs_spin_lock(struct mcs_spinlock **lock, struct mcs_spinlock *node)
 		return;
 	}
 	ACCESS_ONCE(prev->next) = node;
-	/*
-	 * Wait until the lock holder passes the lock down.
-	 * Using smp_load_acquire() provides a memory barrier that
-	 * ensures subsequent operations happen after the lock is acquired.
-	 */
-	while (!(smp_load_acquire(&node->locked)))
-		arch_mutex_cpu_relax();
+
+	/* Wait until the lock holder passes the lock down. */
+	arch_mcs_spin_lock_contended(&node->locked);
 }
 EXPORT_SYMBOL_GPL(mcs_spin_lock);
 
@@ -78,12 +96,8 @@ void mcs_spin_unlock(struct mcs_spinlock **lock, struct mcs_spinlock *node)
 		while (!(next = ACCESS_ONCE(node->next)))
 			arch_mutex_cpu_relax();
 	}
-	/*
-	 * Pass lock to next waiter.
-	 * smp_store_release() provides a memory barrier to ensure
-	 * all operations in the critical section has been completed
-	 * before unlocking.
-	 */
-	smp_store_release(&next->locked, 1);
+
+	/* Pass lock to next waiter. */
+	arch_mcs_spin_unlock_contended(&next->locked);
 }
 EXPORT_SYMBOL_GPL(mcs_spin_unlock);
-- 
1.7.11.7



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
