Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id E1D716B03AC
	for <linux-mm@kvack.org>; Tue, 16 May 2017 06:36:20 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id p74so122068589pfd.11
        for <linux-mm@kvack.org>; Tue, 16 May 2017 03:36:20 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id o4si12743897plb.28.2017.05.16.03.36.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 May 2017 03:36:19 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4GAT4Qa025654
	for <linux-mm@kvack.org>; Tue, 16 May 2017 06:36:19 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2afwhj71tg-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 16 May 2017 06:36:19 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 16 May 2017 11:36:16 +0100
From: "Mike Rapoport" <rppt@linux.vnet.ibm.com>
Subject: [RFC PATCH 4/5] userfaultfd: non-cooperative: use fault_pending_wqh for all events
Date: Tue, 16 May 2017 13:36:01 +0300
In-Reply-To: <1494930962-3318-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1494930962-3318-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1494930962-3318-5-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm <linux-mm@kvack.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

Queuing page faults and non-cooperative events into different wait queues
does not have real value but rather makes the code more complicated.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 fs/userfaultfd.c | 64 +++++++++++++++++++++-----------------------------------
 1 file changed, 24 insertions(+), 40 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 1bd772a..8868229 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -48,8 +48,6 @@ struct userfaultfd_ctx {
 	wait_queue_head_t fault_wqh;
 	/* waitqueue head for the pseudo fd to wakeup poll/read */
 	wait_queue_head_t fd_wqh;
-	/* waitqueue head for events */
-	wait_queue_head_t event_wqh;
 	/* a refile sequence protected by fault_pending_wqh lock */
 	struct seqcount refile_seq;
 	/* pseudo fd refcounting */
@@ -101,6 +99,9 @@ struct userfaultfd_wake_key {
 static bool userfaultfd_should_wake(struct userfaultfd_wait_queue *uwq,
 				    struct userfaultfd_wake_key *key)
 {
+	if (key->event != uwq->msg.event)
+		return false;
+
 	if (key->event == UFFD_EVENT_PAGEFAULT) {
 		unsigned long start, len, address;
 
@@ -188,8 +189,6 @@ static void userfaultfd_ctx_put(struct userfaultfd_ctx *ctx)
 		VM_BUG_ON(waitqueue_active(&ctx->fault_pending_wqh));
 		VM_BUG_ON(spin_is_locked(&ctx->fault_wqh.lock));
 		VM_BUG_ON(waitqueue_active(&ctx->fault_wqh));
-		VM_BUG_ON(spin_is_locked(&ctx->event_wqh.lock));
-		VM_BUG_ON(waitqueue_active(&ctx->event_wqh));
 		VM_BUG_ON(spin_is_locked(&ctx->fd_wqh.lock));
 		VM_BUG_ON(waitqueue_active(&ctx->fd_wqh));
 		mmdrop(ctx->mm);
@@ -560,22 +559,21 @@ static void userfaultfd_event_wait_completion(struct userfaultfd_ctx *ctx,
 	if (WARN_ON_ONCE(current->flags & PF_EXITING))
 		goto out;
 
-	ewq->ctx = ctx;
-	init_waitqueue_entry(&ewq->wq, current);
+	userfaultfd_init_waitqueue(ctx, ewq);
 
-	spin_lock(&ctx->event_wqh.lock);
+	spin_lock(&ctx->fault_pending_wqh.lock);
 	/*
 	 * After the __add_wait_queue the uwq is visible to userland
 	 * through poll/read().
 	 */
-	__add_wait_queue(&ctx->event_wqh, &ewq->wq);
+	__add_wait_queue(&ctx->fault_pending_wqh, &ewq->wq);
 	for (;;) {
 		set_current_state(TASK_KILLABLE);
-		if (ewq->msg.event == 0)
+		if (READ_ONCE(ewq->waken))
 			break;
 		if (ACCESS_ONCE(ctx->released) ||
 		    fatal_signal_pending(current)) {
-			__remove_wait_queue(&ctx->event_wqh, &ewq->wq);
+			__remove_wait_queue(&ctx->fault_pending_wqh, &ewq->wq);
 			if (ewq->msg.event == UFFD_EVENT_FORK) {
 				struct userfaultfd_ctx *new;
 
@@ -588,15 +586,15 @@ static void userfaultfd_event_wait_completion(struct userfaultfd_ctx *ctx,
 			break;
 		}
 
-		spin_unlock(&ctx->event_wqh.lock);
+		spin_unlock(&ctx->fault_pending_wqh.lock);
 
 		wake_up_poll(&ctx->fd_wqh, POLLIN);
 		schedule();
 
-		spin_lock(&ctx->event_wqh.lock);
+		spin_lock(&ctx->fault_pending_wqh.lock);
 	}
 	__set_current_state(TASK_RUNNING);
-	spin_unlock(&ctx->event_wqh.lock);
+	spin_unlock(&ctx->fault_pending_wqh.lock);
 
 	/*
 	 * ctx may go away after this if the userfault pseudo fd is
@@ -609,9 +607,10 @@ static void userfaultfd_event_wait_completion(struct userfaultfd_ctx *ctx,
 static void userfaultfd_event_complete(struct userfaultfd_ctx *ctx,
 				       struct userfaultfd_wait_queue *ewq)
 {
-	ewq->msg.event = 0;
-	wake_up_locked(&ctx->event_wqh);
-	__remove_wait_queue(&ctx->event_wqh, &ewq->wq);
+	struct userfaultfd_wake_key key = { 0 };
+
+	key.event = ewq->msg.event;
+	__wake_up_locked_key(&ctx->fault_pending_wqh, TASK_NORMAL, &key);
 }
 
 int dup_userfaultfd(struct vm_area_struct *vma, struct list_head *fcs)
@@ -898,12 +897,6 @@ static inline struct userfaultfd_wait_queue *find_userfault(
 	return find_userfault_in(&ctx->fault_pending_wqh);
 }
 
-static inline struct userfaultfd_wait_queue *find_userfault_evt(
-		struct userfaultfd_ctx *ctx)
-{
-	return find_userfault_in(&ctx->event_wqh);
-}
-
 static unsigned int userfaultfd_poll(struct file *file, poll_table *wait)
 {
 	struct userfaultfd_ctx *ctx = file->private_data;
@@ -935,8 +928,6 @@ static unsigned int userfaultfd_poll(struct file *file, poll_table *wait)
 		smp_mb();
 		if (waitqueue_active(&ctx->fault_pending_wqh))
 			ret = POLLIN;
-		else if (waitqueue_active(&ctx->event_wqh))
-			ret = POLLIN;
 
 		return ret;
 	default:
@@ -981,7 +972,7 @@ static ssize_t userfaultfd_ctx_read(struct userfaultfd_ctx *ctx, int no_wait,
 	struct userfaultfd_wait_queue *uwq;
 	/*
 	 * Handling fork event requires sleeping operations, so
-	 * we drop the event_wqh lock, then do these ops, then
+	 * we drop the fault_pending_wqh lock, then do these ops, then
 	 * lock it back and wake up the waiter. While the lock is
 	 * dropped the ewq may go away so we keep track of it
 	 * carefully.
@@ -996,7 +987,7 @@ static ssize_t userfaultfd_ctx_read(struct userfaultfd_ctx *ctx, int no_wait,
 		set_current_state(TASK_INTERRUPTIBLE);
 		spin_lock(&ctx->fault_pending_wqh.lock);
 		uwq = find_userfault(ctx);
-		if (uwq) {
+		if (uwq && uwq->msg.event == UFFD_EVENT_PAGEFAULT) {
 			/*
 			 * Use a seqcount to repeat the lockless check
 			 * in wake_userfault() to avoid missing
@@ -1037,12 +1028,7 @@ static ssize_t userfaultfd_ctx_read(struct userfaultfd_ctx *ctx, int no_wait,
 			spin_unlock(&ctx->fault_pending_wqh.lock);
 			ret = 0;
 			break;
-		}
-		spin_unlock(&ctx->fault_pending_wqh.lock);
-
-		spin_lock(&ctx->event_wqh.lock);
-		uwq = find_userfault_evt(ctx);
-		if (uwq) {
+		} else if (uwq) { /* non-pagefault event */
 			*msg = uwq->msg;
 
 			if (uwq->msg.event == UFFD_EVENT_FORK) {
@@ -1050,17 +1036,16 @@ static ssize_t userfaultfd_ctx_read(struct userfaultfd_ctx *ctx, int no_wait,
 					(unsigned long)
 					uwq->msg.arg.reserved.reserved1;
 				list_move(&uwq->wq.task_list, &fork_event);
-				spin_unlock(&ctx->event_wqh.lock);
+				spin_unlock(&ctx->fault_pending_wqh.lock);
 				ret = 0;
 				break;
 			}
-
 			userfaultfd_event_complete(ctx, uwq);
-			spin_unlock(&ctx->event_wqh.lock);
+			spin_unlock(&ctx->fault_pending_wqh.lock);
 			ret = 0;
 			break;
 		}
-		spin_unlock(&ctx->event_wqh.lock);
+		spin_unlock(&ctx->fault_pending_wqh.lock);
 
 		if (signal_pending(current)) {
 			ret = -ERESTARTSYS;
@@ -1082,16 +1067,16 @@ static ssize_t userfaultfd_ctx_read(struct userfaultfd_ctx *ctx, int no_wait,
 		ret = resolve_userfault_fork(ctx, fork_nctx, msg);
 
 		if (!ret) {
-			spin_lock(&ctx->event_wqh.lock);
+			spin_lock(&ctx->fault_pending_wqh.lock);
 			if (!list_empty(&fork_event)) {
 				uwq = list_first_entry(&fork_event,
 						       typeof(*uwq),
 						       wq.task_list);
 				list_del(&uwq->wq.task_list);
-				__add_wait_queue(&ctx->event_wqh, &uwq->wq);
+				__add_wait_queue(&ctx->fault_pending_wqh, &uwq->wq);
 				userfaultfd_event_complete(ctx, uwq);
 			}
-			spin_unlock(&ctx->event_wqh.lock);
+			spin_unlock(&ctx->fault_pending_wqh.lock);
 		}
 	}
 
@@ -1808,7 +1793,6 @@ static void init_once_userfaultfd_ctx(void *mem)
 
 	init_waitqueue_head(&ctx->fault_pending_wqh);
 	init_waitqueue_head(&ctx->fault_wqh);
-	init_waitqueue_head(&ctx->event_wqh);
 	init_waitqueue_head(&ctx->fd_wqh);
 	seqcount_init(&ctx->refile_seq);
 }
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
