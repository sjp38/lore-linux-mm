Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id D97BA6B003D
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 18:39:00 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id fb1so1689106pad.9
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 15:39:00 -0700 (PDT)
Subject: [PATCH v8 7/9] MCS Lock: Barrier corrections
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <cover.1380748401.git.tim.c.chen@linux.intel.com>
References: <cover.1380748401.git.tim.c.chen@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 02 Oct 2013 15:38:38 -0700
Message-ID: <1380753518.11046.89.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, Tim Chen <tim.c.chen@linux.intel.com>, Jason Low <jason.low2@hp.com>, Waiman Long <Waiman.Long@hp.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

This patch corrects the way memory barriers are used in the MCS lock
and removes ones that are not needed. Also add comments on all barriers.

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
