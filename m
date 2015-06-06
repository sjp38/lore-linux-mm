Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 87CD6900016
	for <linux-mm@kvack.org>; Sat,  6 Jun 2015 09:38:21 -0400 (EDT)
Received: by pdjn11 with SMTP id n11so33076937pdj.0
        for <linux-mm@kvack.org>; Sat, 06 Jun 2015 06:38:21 -0700 (PDT)
Received: from smtp2.provo.novell.com (smtp2.provo.novell.com. [137.65.250.81])
        by mx.google.com with ESMTPS id bx3si15082507pbb.197.2015.06.06.06.38.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 06 Jun 2015 06:38:20 -0700 (PDT)
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: [PATCH 2/5] ipc,msg: provide barrier pairings for lockless receive
Date: Sat,  6 Jun 2015 06:37:57 -0700
Message-Id: <1433597880-8571-3-git-send-email-dave@stgolabs.net>
In-Reply-To: <1433597880-8571-1-git-send-email-dave@stgolabs.net>
References: <1433597880-8571-1-git-send-email-dave@stgolabs.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Manfred Spraul <manfred@colorfullife.com>, dave@stgolabs.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Davidlohr Bueso <dbueso@suse.de>

We currently use a full barrier on the sender side to
to avoid receiver tasks disappearing on us while still
performing on the sender side wakeup. We lack however,
the proper CPU-CPU interactions pairing on the receiver
side which busy-waits for the message. Similarly, we do
not need a full smp_mb, and can relax the semantics for
the writer and reader sides of the message. This is safe
as we are only ordering loads and stores to r_msg. And in
both smp_wmb and smp_rmb, there are no stores after the
calls _anyway_.

This obviously applies for pipelined_send and expunge_all,
for EIRDM when destroying a queue.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 ipc/msg.c | 48 ++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 38 insertions(+), 10 deletions(-)

diff --git a/ipc/msg.c b/ipc/msg.c
index 2b6fdbb..a9c3c51 100644
--- a/ipc/msg.c
+++ b/ipc/msg.c
@@ -196,7 +196,7 @@ static void expunge_all(struct msg_queue *msq, int res)
 		 * or dealing with -EAGAIN cases. See lockless receive part 1
 		 * and 2 in do_msgrcv().
 		 */
-		smp_mb();
+		smp_wmb(); /* barrier (B) */
 		msr->r_msg = ERR_PTR(res);
 	}
 }
@@ -580,7 +580,8 @@ static inline int pipelined_send(struct msg_queue *msq, struct msg_msg *msg)
 				/* initialize pipelined send ordering */
 				msr->r_msg = NULL;
 				wake_up_process(msr->r_tsk);
-				smp_mb(); /* see barrier comment below */
+				/* barrier (B) see barrier comment below */
+				smp_wmb();
 				msr->r_msg = ERR_PTR(-E2BIG);
 			} else {
 				msr->r_msg = NULL;
@@ -589,11 +590,12 @@ static inline int pipelined_send(struct msg_queue *msq, struct msg_msg *msg)
 				wake_up_process(msr->r_tsk);
 				/*
 				 * Ensure that the wakeup is visible before
-				 * setting r_msg, as the receiving end depends
-				 * on it. See lockless receive part 1 and 2 in
-				 * do_msgrcv().
+				 * setting r_msg, as the receiving can otherwise
+				 * exit - once r_msg is set, the receiver can
+				 * continue. See lockless receive part 1 and 2
+				 * in do_msgrcv(). Barrier (B).
 				 */
-				smp_mb();
+				smp_wmb();
 				msr->r_msg = msg;
 
 				return 1;
@@ -932,12 +934,38 @@ long do_msgrcv(int msqid, void __user *buf, size_t bufsz, long msgtyp, int msgfl
 		/* Lockless receive, part 2:
 		 * Wait until pipelined_send or expunge_all are outside of
 		 * wake_up_process(). There is a race with exit(), see
-		 * ipc/mqueue.c for the details.
+		 * ipc/mqueue.c for the details. The correct serialization
+		 * ensures that a receiver cannot continue without the wakeup
+		 * being visibible _before_ setting r_msg:
+		 *
+		 * CPU 0                             CPU 1
+		 * <loop receiver>
+		 *   smp_rmb(); (A) <-- pair -.      <waker thread>
+		 *   <load ->r_msg>           |        msr->r_msg = NULL;
+		 *                            |        wake_up_process();
+		 * <continue>                 `------> smp_wmb(); (B)
+		 *                                     msr->r_msg = msg;
+		 *
+		 * Where (A) orders the message value read and where (B) orders
+		 * the write to the r_msg -- done in both pipelined_send and
+		 * expunge_all.
 		 */
-		msg = (struct msg_msg *)msr_d.r_msg;
-		while (msg == NULL) {
-			cpu_relax();
+		for (;;) {
+			/*
+			 * Pairs with writer barrier in pipelined_send
+			 * or expunge_all.
+			 */
+			smp_rmb(); /* barrier (A) */
 			msg = (struct msg_msg *)msr_d.r_msg;
+			if (msg)
+				break;
+
+			/*
+			 * The cpu_relax() call is a compiler barrier
+			 * which forces everything in this loop to be
+			 * re-loaded.
+			 */
+			cpu_relax();
 		}
 
 		/* Lockless receive, part 3:
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
