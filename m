Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 063C56B010D
	for <linux-mm@kvack.org>; Wed,  6 Nov 2013 16:37:44 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id x10so96503pdj.26
        for <linux-mm@kvack.org>; Wed, 06 Nov 2013 13:37:44 -0800 (PST)
Received: from psmtp.com ([74.125.245.131])
        by mx.google.com with SMTP id hb3si511410pac.94.2013.11.06.13.37.42
        for <linux-mm@kvack.org>;
        Wed, 06 Nov 2013 13:37:43 -0800 (PST)
Subject: [PATCH v3 2/5] MCS Lock: optimizations and extra comments
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <cover.1383771175.git.tim.c.chen@linux.intel.com>
References: <cover.1383771175.git.tim.c.chen@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 06 Nov 2013 13:37:04 -0800
Message-ID: <1383773824.11046.354.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-arch@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, "Paul
 E.McKenney" <paulmck@linux.vnet.ibm.com>, Tim Chen <tim.c.chen@linux.intel.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, Will Deacon <will.deacon@arm.com>, "Figo.zhang" <figo1802@gmail.com>

Remove unnecessary operation and make the cmpxchg(lock, node, NULL) == node
check in mcs_spin_unlock() likely() as it is likely that a race did not occur
most of the time.

Also add in more comments describing how the local node is used in MCS locks.

Reviewed-by: Tim Chen <tim.c.chen@linux.intel.com>
Signed-off-by: Jason Low <jason.low2@hp.com>
Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
---
 include/linux/mcs_spinlock.h |   13 +++++++++++--
 1 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/include/linux/mcs_spinlock.h b/include/linux/mcs_spinlock.h
index b5de3b0..96f14299 100644
--- a/include/linux/mcs_spinlock.h
+++ b/include/linux/mcs_spinlock.h
@@ -18,6 +18,12 @@ struct mcs_spinlock {
 };
 
 /*
+ * In order to acquire the lock, the caller should declare a local node and
+ * pass a reference of the node to this function in addition to the lock.
+ * If the lock has already been acquired, then this will proceed to spin
+ * on this node->locked until the previous lock holder sets the node->locked
+ * in mcs_spin_unlock().
+ *
  * We don't inline mcs_spin_lock() so that perf can correctly account for the
  * time spent in this lock function.
  */
@@ -33,7 +39,6 @@ void mcs_spin_lock(struct mcs_spinlock **lock, struct mcs_spinlock *node)
 	prev = xchg(lock, node);
 	if (likely(prev == NULL)) {
 		/* Lock acquired */
-		node->locked = 1;
 		return;
 	}
 	ACCESS_ONCE(prev->next) = node;
@@ -43,6 +48,10 @@ void mcs_spin_lock(struct mcs_spinlock **lock, struct mcs_spinlock *node)
 		arch_mutex_cpu_relax();
 }
 
+/*
+ * Releases the lock. The caller should pass in the corresponding node that
+ * was used to acquire the lock.
+ */
 static void mcs_spin_unlock(struct mcs_spinlock **lock, struct mcs_spinlock *node)
 {
 	struct mcs_spinlock *next = ACCESS_ONCE(node->next);
@@ -51,7 +60,7 @@ static void mcs_spin_unlock(struct mcs_spinlock **lock, struct mcs_spinlock *nod
 		/*
 		 * Release the lock by setting it to NULL
 		 */
-		if (cmpxchg(lock, node, NULL) == node)
+		if (likely(cmpxchg(lock, node, NULL) == node))
 			return;
 		/* Wait until the next pointer is set */
 		while (!(next = ACCESS_ONCE(node->next)))
-- 
1.7.4.4



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
