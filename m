Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id D627F6B0072
	for <linux-mm@kvack.org>; Tue,  5 Nov 2013 12:42:41 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id kx10so9256932pab.12
        for <linux-mm@kvack.org>; Tue, 05 Nov 2013 09:42:41 -0800 (PST)
Received: from psmtp.com ([74.125.245.151])
        by mx.google.com with SMTP id hb3si14547095pac.152.2013.11.05.09.42.40
        for <linux-mm@kvack.org>;
        Tue, 05 Nov 2013 09:42:40 -0800 (PST)
Subject: [PATCH v2 3/4] MCS Lock: Barrier corrections
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <cover.1383670202.git.tim.c.chen@linux.intel.com>
References: <cover.1383670202.git.tim.c.chen@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 05 Nov 2013 09:42:36 -0800
Message-ID: <1383673356.11046.279.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-arch@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, "Paul
 E.McKenney" <paulmck@linux.vnet.ibm.com>, Tim Chen <tim.c.chen@linux.intel.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, Will Deacon <will.deacon@arm.com>

This patch corrects the way memory barriers are used in the MCS lock
and removes ones that are not needed. Also add comments on all barriers.

Reviewed-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Reviewed-by: Tim Chen <tim.c.chen@linux.intel.com>
Signed-off-by: Jason Low <jason.low2@hp.com>
---
 include/linux/mcs_spinlock.h |   13 +++++++++++--
 1 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/include/linux/mcs_spinlock.h b/include/linux/mcs_spinlock.h
index 96f14299..93d445d 100644
--- a/include/linux/mcs_spinlock.h
+++ b/include/linux/mcs_spinlock.h
@@ -36,16 +36,19 @@ void mcs_spin_lock(struct mcs_spinlock **lock, struct mcs_spinlock *node)
 	node->locked = 0;
 	node->next   = NULL;
 
+	/* xchg() provides a memory barrier */
 	prev = xchg(lock, node);
 	if (likely(prev == NULL)) {
 		/* Lock acquired */
 		return;
 	}
 	ACCESS_ONCE(prev->next) = node;
-	smp_wmb();
 	/* Wait until the lock holder passes the lock down */
 	while (!ACCESS_ONCE(node->locked))
 		arch_mutex_cpu_relax();
+
+	/* Make sure subsequent operations happen after the lock is acquired */
+	smp_rmb();
 }
 
 /*
@@ -58,6 +61,7 @@ static void mcs_spin_unlock(struct mcs_spinlock **lock, struct mcs_spinlock *nod
 
 	if (likely(!next)) {
 		/*
+		 * cmpxchg() provides a memory barrier.
 		 * Release the lock by setting it to NULL
 		 */
 		if (likely(cmpxchg(lock, node, NULL) == node))
@@ -65,9 +69,14 @@ static void mcs_spin_unlock(struct mcs_spinlock **lock, struct mcs_spinlock *nod
 		/* Wait until the next pointer is set */
 		while (!(next = ACCESS_ONCE(node->next)))
 			arch_mutex_cpu_relax();
+	} else {
+		/*
+		 * Make sure all operations within the critical section
+		 * happen before the lock is released.
+		 */
+		smp_wmb();
 	}
 	ACCESS_ONCE(next->locked) = 1;
-	smp_wmb();
 }
 
 #endif /* __LINUX_MCS_SPINLOCK_H */
-- 
1.7.4.4



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
