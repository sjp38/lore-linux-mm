Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id B57946B003B
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 18:21:25 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id bj1so1919603pad.21
        for <linux-mm@kvack.org>; Thu, 26 Sep 2013 15:21:25 -0700 (PDT)
Subject: [PATCH v7 4/6] rwsem/wake: check lock before do atomic update
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <cover.1380231690.git.tim.c.chen@linux.intel.com>
References: <cover.1380231690.git.tim.c.chen@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 26 Sep 2013 15:21:13 -0700
Message-ID: <1380234073.3467.90.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Tim Chen <tim.c.chen@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

Atomic update lock and roll back will cause cache bouncing in large
machine. A lock status pre-read can relieve this problem

Suggested-by: Davidlohr bueso <davidlohr.bueso@hp.com>
Suggested-by: Tim Chen <tim.c.chen@linux.intel.com>
Signed-off-by: Alex Shi <alex.shi@intel.com>
---
 lib/rwsem.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/lib/rwsem.c b/lib/rwsem.c
index a8055cf..1d6e6e8 100644
--- a/lib/rwsem.c
+++ b/lib/rwsem.c
@@ -64,7 +64,7 @@ __rwsem_do_wake(struct rw_semaphore *sem, enum rwsem_wake_type wake_type)
 	struct rwsem_waiter *waiter;
 	struct task_struct *tsk;
 	struct list_head *next;
-	long oldcount, woken, loop, adjustment;
+	long woken, loop, adjustment;
 
 	waiter = list_entry(sem->wait_list.next, struct rwsem_waiter, list);
 	if (waiter->type == RWSEM_WAITING_FOR_WRITE) {
@@ -86,6 +86,12 @@ __rwsem_do_wake(struct rw_semaphore *sem, enum rwsem_wake_type wake_type)
 	if (wake_type != RWSEM_WAKE_READ_OWNED) {
 		adjustment = RWSEM_ACTIVE_READ_BIAS;
 		while (1) {
+			long oldcount;
+
+			/* A writer stole the lock. */
+			if (unlikely(sem->count < RWSEM_WAITING_BIAS))
+				return sem;
+
 			oldcount = rwsem_atomic_update(adjustment, sem)
 								- adjustment;
 			if (likely(oldcount >= RWSEM_WAITING_BIAS))
-- 
1.7.4.4



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
