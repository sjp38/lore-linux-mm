Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f169.google.com (mail-qk0-f169.google.com [209.85.220.169])
	by kanga.kvack.org (Postfix) with ESMTP id 23CC46B0038
	for <linux-mm@kvack.org>; Wed,  8 Jul 2015 06:50:13 -0400 (EDT)
Received: by qkei195 with SMTP id i195so159669662qke.3
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 03:50:12 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r76si2158676qha.128.2015.07.08.03.50.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jul 2015 03:50:12 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 4/5] userfaultfd: avoid missing wakeups during refile in userfaultfd_read
Date: Wed,  8 Jul 2015 12:50:07 +0200
Message-Id: <1436352608-8455-5-git-send-email-aarcange@redhat.com>
In-Reply-To: <1436352608-8455-1-git-send-email-aarcange@redhat.com>
References: <1436352608-8455-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill@shutemov.name>, Pavel Emelyanov <xemul@parallels.com>, Dave Hansen <dave.hansen@intel.com>

During the refile in userfaultfd_read both waitqueues could look empty
to the lockless wake_userfault(). Use a seqcount to prevent this false
negative that could leave an userfault blocked.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 fs/userfaultfd.c | 26 ++++++++++++++++++++++++--
 1 file changed, 24 insertions(+), 2 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 851d575..6a117f8 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -45,6 +45,8 @@ struct userfaultfd_ctx {
 	wait_queue_head_t fault_wqh;
 	/* waitqueue head for the pseudo fd to wakeup poll/read */
 	wait_queue_head_t fd_wqh;
+	/* a refile sequence protected by fault_pending_wqh lock */
+	struct seqcount refile_seq;
 	/* pseudo fd refcounting */
 	atomic_t refcount;
 	/* userfaultfd syscall flags */
@@ -547,6 +549,15 @@ static ssize_t userfaultfd_ctx_read(struct userfaultfd_ctx *ctx, int no_wait,
 		uwq = find_userfault(ctx);
 		if (uwq) {
 			/*
+			 * Use a seqcount to repeat the lockless check
+			 * in wake_userfault() to avoid missing
+			 * wakeups because during the refile both
+			 * waitqueue could become empty if this is the
+			 * only userfault.
+			 */
+			write_seqcount_begin(&ctx->refile_seq);
+
+			/*
 			 * The fault_pending_wqh.lock prevents the uwq
 			 * to disappear from under us.
 			 *
@@ -570,6 +581,8 @@ static ssize_t userfaultfd_ctx_read(struct userfaultfd_ctx *ctx, int no_wait,
 			list_del(&uwq->wq.task_list);
 			__add_wait_queue(&ctx->fault_wqh, &uwq->wq);
 
+			write_seqcount_end(&ctx->refile_seq);
+
 			/* careful to always initialize msg if ret == 0 */
 			*msg = uwq->msg;
 			spin_unlock(&ctx->fault_pending_wqh.lock);
@@ -647,6 +660,9 @@ static void __wake_userfault(struct userfaultfd_ctx *ctx,
 static __always_inline void wake_userfault(struct userfaultfd_ctx *ctx,
 					   struct userfaultfd_wake_range *range)
 {
+	unsigned seq;
+	bool need_wakeup;
+
 	/*
 	 * To be sure waitqueue_active() is not reordered by the CPU
 	 * before the pagetable update, use an explicit SMP memory
@@ -662,8 +678,13 @@ static __always_inline void wake_userfault(struct userfaultfd_ctx *ctx,
 	 * userfaults yet. So we take the spinlock only when we're
 	 * sure we've userfaults to wake.
 	 */
-	if (waitqueue_active(&ctx->fault_pending_wqh) ||
-	    waitqueue_active(&ctx->fault_wqh))
+	do {
+		seq = read_seqcount_begin(&ctx->refile_seq);
+		need_wakeup = waitqueue_active(&ctx->fault_pending_wqh) ||
+			waitqueue_active(&ctx->fault_wqh);
+		cond_resched();
+	} while (read_seqcount_retry(&ctx->refile_seq, seq));
+	if (need_wakeup)
 		__wake_userfault(ctx, range);
 }
 
@@ -1219,6 +1240,7 @@ static void init_once_userfaultfd_ctx(void *mem)
 	init_waitqueue_head(&ctx->fault_pending_wqh);
 	init_waitqueue_head(&ctx->fault_wqh);
 	init_waitqueue_head(&ctx->fd_wqh);
+	seqcount_init(&ctx->refile_seq);
 }
 
 /**

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
