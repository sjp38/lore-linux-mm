Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3BAB96B0039
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 18:21:11 -0400 (EDT)
Received: by mail-pb0-f51.google.com with SMTP id jt11so1712378pbb.24
        for <linux-mm@kvack.org>; Thu, 26 Sep 2013 15:21:10 -0700 (PDT)
Subject: [PATCH v7 2/6] rwsem: remove 'out' label in do_wake
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <cover.1380231690.git.tim.c.chen@linux.intel.com>
References: <cover.1380231690.git.tim.c.chen@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 26 Sep 2013 15:21:05 -0700
Message-ID: <1380234065.3467.88.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Tim Chen <tim.c.chen@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

That make code simple and more readable.

Signed-off-by: Alex Shi <alex.shi@intel.com>
---
 lib/rwsem.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/lib/rwsem.c b/lib/rwsem.c
index 19c5fa9..42f1b1a 100644
--- a/lib/rwsem.c
+++ b/lib/rwsem.c
@@ -75,7 +75,7 @@ __rwsem_do_wake(struct rw_semaphore *sem, enum rwsem_wake_type wake_type)
 			 * will block as they will notice the queued writer.
 			 */
 			wake_up_process(waiter->task);
-		goto out;
+		return sem;
 	}
 
 	/* Writers might steal the lock before we grant it to the next reader.
@@ -91,7 +91,7 @@ __rwsem_do_wake(struct rw_semaphore *sem, enum rwsem_wake_type wake_type)
 			/* A writer stole the lock. Undo our reader grant. */
 			if (rwsem_atomic_update(-adjustment, sem) &
 						RWSEM_ACTIVE_MASK)
-				goto out;
+				return sem;
 			/* Last active locker left. Retry waking readers. */
 			goto try_reader_grant;
 		}
@@ -136,7 +136,6 @@ __rwsem_do_wake(struct rw_semaphore *sem, enum rwsem_wake_type wake_type)
 	sem->wait_list.next = next;
 	next->prev = &sem->wait_list;
 
- out:
 	return sem;
 }
 
-- 
1.7.4.4



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
