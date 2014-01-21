Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id 3F58D6B0036
	for <linux-mm@kvack.org>; Mon, 20 Jan 2014 20:24:32 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id up15so7203455pbc.0
        for <linux-mm@kvack.org>; Mon, 20 Jan 2014 17:24:31 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id eb3si3121399pbd.137.2014.01.20.17.24.27
        for <linux-mm@kvack.org>;
        Mon, 20 Jan 2014 17:24:28 -0800 (PST)
Subject: [PATCH v8 1/6] MCS Lock: Barrier corrections
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <cover.1390239879.git.tim.c.chen@linux.intel.com>
References: <cover.1390239879.git.tim.c.chen@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 20 Jan 2014 17:24:20 -0800
Message-ID: <1390267460.3138.35.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, Will Deacon <will.deacon@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-arch@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Tim Chen <tim.c.chen@linux.intel.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

From: Waiman Long <Waiman.Long@hp.com>

This patch corrects the way memory barriers are used in the MCS lock
with smp_load_acquire and smp_store_release fucnction.
It removes ones that are not needed.

Suggested-by: Michel Lespinasse <walken@google.com>
Signed-off-by: Waiman Long <Waiman.Long@hp.com>
Signed-off-by: Jason Low <jason.low2@hp.com>
Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
---
 kernel/locking/mutex.c | 18 +++++++++++++-----
 1 file changed, 13 insertions(+), 5 deletions(-)

diff --git a/kernel/locking/mutex.c b/kernel/locking/mutex.c
index 4dd6e4c..fbbd2ed 100644
--- a/kernel/locking/mutex.c
+++ b/kernel/locking/mutex.c
@@ -136,9 +136,12 @@ void mspin_lock(struct mspin_node **lock, struct mspin_node *node)
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
 
@@ -156,8 +159,13 @@ static void mspin_unlock(struct mspin_node **lock, struct mspin_node *node)
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
 
 /*
-- 
1.7.11.7



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
