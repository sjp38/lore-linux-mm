Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 104986B0255
	for <linux-mm@kvack.org>; Tue,  8 Sep 2015 16:43:38 -0400 (EDT)
Received: by padhk3 with SMTP id hk3so48754520pad.3
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 13:43:37 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id pw1si7485402pbc.28.2015.09.08.13.43.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Sep 2015 13:43:35 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 02/12] userfaultfd: Revert "userfaultfd: waitqueue: add nr wake parameter to __wake_up_locked_key"
Date: Tue,  8 Sep 2015 22:43:20 +0200
Message-Id: <1441745010-14314-3-git-send-email-aarcange@redhat.com>
In-Reply-To: <1441745010-14314-1-git-send-email-aarcange@redhat.com>
References: <1441745010-14314-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: Pavel Emelyanov <xemul@parallels.com>, zhang.zhanghailiang@huawei.com, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Michael Ellerman <mpe@ellerman.id.au>, Bamvor Zhang Jian <bamvor.zhangjian@linaro.org>, Bharata B Rao <bharata@linux.vnet.ibm.com>, Geert Uytterhoeven <geert@linux-m68k.org>

This reverts commit 51360155eccb907ff8635bd10fc7de876408c2e0 and
adapts fs/userfaultfd.c to use the old version of that function.

It didn't look robust to call __wake_up_common with "nr == 1" when we
absolutely require wakeall semantics, but we've full control of what
we insert in the two waitqueue heads of the blocked userfaults. No
exclusive waitqueue risks to be inserted into those two waitqueue
heads so we can as well stick to "nr == 1" of the old code and we can
rely purely on the fact no waitqueue inserted in one of the two
waitqueue heads we must enforce as wakeall, has wait->flags
WQ_FLAG_EXCLUSIVE set.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 fs/userfaultfd.c     | 8 ++++----
 include/linux/wait.h | 5 ++---
 kernel/sched/wait.c  | 7 +++----
 net/sunrpc/sched.c   | 2 +-
 4 files changed, 10 insertions(+), 12 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 634e676..15245e5 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -467,8 +467,8 @@ static int userfaultfd_release(struct inode *inode, struct file *file)
 	 * the fault_*wqh.
 	 */
 	spin_lock(&ctx->fault_pending_wqh.lock);
-	__wake_up_locked_key(&ctx->fault_pending_wqh, TASK_NORMAL, 0, &range);
-	__wake_up_locked_key(&ctx->fault_wqh, TASK_NORMAL, 0, &range);
+	__wake_up_locked_key(&ctx->fault_pending_wqh, TASK_NORMAL, &range);
+	__wake_up_locked_key(&ctx->fault_wqh, TASK_NORMAL, &range);
 	spin_unlock(&ctx->fault_pending_wqh.lock);
 
 	wake_up_poll(&ctx->fd_wqh, POLLHUP);
@@ -650,10 +650,10 @@ static void __wake_userfault(struct userfaultfd_ctx *ctx,
 	spin_lock(&ctx->fault_pending_wqh.lock);
 	/* wake all in the range and autoremove */
 	if (waitqueue_active(&ctx->fault_pending_wqh))
-		__wake_up_locked_key(&ctx->fault_pending_wqh, TASK_NORMAL, 0,
+		__wake_up_locked_key(&ctx->fault_pending_wqh, TASK_NORMAL,
 				     range);
 	if (waitqueue_active(&ctx->fault_wqh))
-		__wake_up_locked_key(&ctx->fault_wqh, TASK_NORMAL, 0, range);
+		__wake_up_locked_key(&ctx->fault_wqh, TASK_NORMAL, range);
 	spin_unlock(&ctx->fault_pending_wqh.lock);
 }
 
diff --git a/include/linux/wait.h b/include/linux/wait.h
index d3d0772..1e1bf9f 100644
--- a/include/linux/wait.h
+++ b/include/linux/wait.h
@@ -147,8 +147,7 @@ __remove_wait_queue(wait_queue_head_t *head, wait_queue_t *old)
 
 typedef int wait_bit_action_f(struct wait_bit_key *);
 void __wake_up(wait_queue_head_t *q, unsigned int mode, int nr, void *key);
-void __wake_up_locked_key(wait_queue_head_t *q, unsigned int mode, int nr,
-			  void *key);
+void __wake_up_locked_key(wait_queue_head_t *q, unsigned int mode, void *key);
 void __wake_up_sync_key(wait_queue_head_t *q, unsigned int mode, int nr, void *key);
 void __wake_up_locked(wait_queue_head_t *q, unsigned int mode, int nr);
 void __wake_up_sync(wait_queue_head_t *q, unsigned int mode, int nr);
@@ -180,7 +179,7 @@ wait_queue_head_t *bit_waitqueue(void *, int);
 #define wake_up_poll(x, m)						\
 	__wake_up(x, TASK_NORMAL, 1, (void *) (m))
 #define wake_up_locked_poll(x, m)					\
-	__wake_up_locked_key((x), TASK_NORMAL, 1, (void *) (m))
+	__wake_up_locked_key((x), TASK_NORMAL, (void *) (m))
 #define wake_up_interruptible_poll(x, m)				\
 	__wake_up(x, TASK_INTERRUPTIBLE, 1, (void *) (m))
 #define wake_up_interruptible_sync_poll(x, m)				\
diff --git a/kernel/sched/wait.c b/kernel/sched/wait.c
index 272d932..052e026 100644
--- a/kernel/sched/wait.c
+++ b/kernel/sched/wait.c
@@ -106,10 +106,9 @@ void __wake_up_locked(wait_queue_head_t *q, unsigned int mode, int nr)
 }
 EXPORT_SYMBOL_GPL(__wake_up_locked);
 
-void __wake_up_locked_key(wait_queue_head_t *q, unsigned int mode, int nr,
-			  void *key)
+void __wake_up_locked_key(wait_queue_head_t *q, unsigned int mode, void *key)
 {
-	__wake_up_common(q, mode, nr, 0, key);
+	__wake_up_common(q, mode, 1, 0, key);
 }
 EXPORT_SYMBOL_GPL(__wake_up_locked_key);
 
@@ -284,7 +283,7 @@ void abort_exclusive_wait(wait_queue_head_t *q, wait_queue_t *wait,
 	if (!list_empty(&wait->task_list))
 		list_del_init(&wait->task_list);
 	else if (waitqueue_active(q))
-		__wake_up_locked_key(q, mode, 1, key);
+		__wake_up_locked_key(q, mode, key);
 	spin_unlock_irqrestore(&q->lock, flags);
 }
 EXPORT_SYMBOL(abort_exclusive_wait);
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index b140c09..337ca85 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -297,7 +297,7 @@ static int rpc_complete_task(struct rpc_task *task)
 	clear_bit(RPC_TASK_ACTIVE, &task->tk_runstate);
 	ret = atomic_dec_and_test(&task->tk_count);
 	if (waitqueue_active(wq))
-		__wake_up_locked_key(wq, TASK_NORMAL, 1, &k);
+		__wake_up_locked_key(wq, TASK_NORMAL, &k);
 	spin_unlock_irqrestore(&wq->lock, flags);
 	return ret;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
