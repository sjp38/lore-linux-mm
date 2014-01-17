Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id B72986B0039
	for <linux-mm@kvack.org>; Thu, 16 Jan 2014 19:08:32 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id p10so3272330pdj.32
        for <linux-mm@kvack.org>; Thu, 16 Jan 2014 16:08:32 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id k3si8490788pbb.24.2014.01.16.16.08.30
        for <linux-mm@kvack.org>;
        Thu, 16 Jan 2014 16:08:31 -0800 (PST)
Subject: [PATCH v7 4/6] MCS Lock: Barrier corrections
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <cover.1389890175.git.tim.c.chen@linux.intel.com>
References: <cover.1389890175.git.tim.c.chen@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 16 Jan 2014 16:08:28 -0800
Message-ID: <1389917308.3138.14.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, Will Deacon <will.deacon@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-arch@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Tim Chen <tim.c.chen@linux.intel.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

This patch corrects the way memory barriers are used in the MCS lock
with smp_load_acquire and smp_store_release fucnction.
It removes ones that are not needed.

Note that using the smp_load_acquire/smp_store_release pair is not
sufficient to form a full memory barrier across
cpus for many architectures (except x86) for mcs_unlock and mcs_lock.
For applications that absolutely need a full barrier across multiple cpus
with mcs_unlock and mcs_lock pair, smp_mb__after_unlock_lock() should be
used after mcs_lock if a full memory barrier needs to be guaranteed.

From: Waiman Long <Waiman.Long@hp.com>
Suggested-by: Michel Lespinasse <walken@google.com>
Signed-off-by: Waiman Long <Waiman.Long@hp.com>
Signed-off-by: Jason Low <jason.low2@hp.com>
Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
---
 kernel/locking/mcs_spinlock.c | 18 +++++++++++++-----
 1 file changed, 13 insertions(+), 5 deletions(-)

diff --git a/kernel/locking/mcs_spinlock.c b/kernel/locking/mcs_spinlock.c
index 44fb092..6cdc730 100644
--- a/kernel/locking/mcs_spinlock.c
+++ b/kernel/locking/mcs_spinlock.c
@@ -43,9 +43,12 @@ void mcs_spin_lock(struct mcs_spinlock **lock, struct mcs_spinlock *node)
 		return;
 	}
 	ACCESS_ONCE(prev->next) = node;
-	smp_wmb();
-	/* Wait until the lock holder passes the lock down */
-	while (!ACCESS_ONCE(node->locked))
+	/*
+	 * Wait until the lock holder passes the lock down.
+	 * Using smp_load_acquire() provides a memory barrier that
+	 * ensures subsequent operations happen after the lock is acquired.
+	 */
+	while (!(smp_load_acquire(&node->locked)))
 		arch_mutex_cpu_relax();
 }
 EXPORT_SYMBOL_GPL(mcs_spin_lock);
@@ -68,7 +71,12 @@ void mcs_spin_unlock(struct mcs_spinlock **lock, struct mcs_spinlock *node)
 		while (!(next = ACCESS_ONCE(node->next)))
 			arch_mutex_cpu_relax();
 	}
-	ACCESS_ONCE(next->locked) = 1;
-	smp_wmb();
+	/*
+	 * Pass lock to next waiter.
+	 * smp_store_release() provides a memory barrier to ensure
+	 * all operations in the critical section has been completed
+	 * before unlocking.
+	 */
+	smp_store_release(&next->locked, 1);
 }
 EXPORT_SYMBOL_GPL(mcs_spin_unlock);
-- 
1.7.11.7



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
