Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f169.google.com (mail-qk0-f169.google.com [209.85.220.169])
	by kanga.kvack.org (Postfix) with ESMTP id E6C596B0139
	for <linux-mm@kvack.org>; Wed, 20 May 2015 15:14:04 -0400 (EDT)
Received: by qkdn188 with SMTP id n188so33701666qkd.2
        for <linux-mm@kvack.org>; Wed, 20 May 2015 12:14:04 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h38si56891qga.34.2015.05.20.12.14.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 May 2015 12:14:03 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 2/2] userfaultfd: fs/userfaultfd.c add more comments
Date: Wed, 20 May 2015 21:13:59 +0200
Message-Id: <1432149239-21760-3-git-send-email-aarcange@redhat.com>
In-Reply-To: <1432149239-21760-1-git-send-email-aarcange@redhat.com>
References: <1432149239-21760-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org

Add more commentary.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 fs/userfaultfd.c | 28 +++++++++++++++++++++++++++-
 1 file changed, 27 insertions(+), 1 deletion(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index f601f27..a519f74 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -86,7 +86,20 @@ static int userfaultfd_wake_function(wait_queue_t *wq, unsigned mode,
 		goto out;
 	ret = wake_up_state(wq->private, mode);
 	if (ret)
-		/* wake only once, autoremove behavior */
+		/*
+		 * Wake only once, autoremove behavior.
+		 *
+		 * After the effect of list_del_init is visible to the
+		 * other CPUs, the waitqueue may disappear from under
+		 * us, see the !list_empty_careful() in
+		 * handle_userfault(). try_to_wake_up() has an
+		 * implicit smp_mb__before_spinlock, and the
+		 * wq->private is read before calling the extern
+		 * function "wake_up_state" (which in turns calls
+		 * try_to_wake_up). While the spin_lock;spin_unlock;
+		 * wouldn't be enough, the smp_mb__before_spinlock is
+		 * enough to avoid an explicit smp_mb() here.
+		 */
 		list_del_init(&wq->task_list);
 out:
 	return ret;
@@ -511,6 +524,19 @@ static ssize_t userfaultfd_ctx_read(struct userfaultfd_ctx *ctx, int no_wait,
 			 * Refile this userfault from
 			 * fault_pending_wqh to fault_wqh, it's not
 			 * pending anymore after we read it.
+			 *
+			 * Use list_del() by hand (as
+			 * userfaultfd_wake_function also uses
+			 * list_del_init() by hand) to be sure nobody
+			 * changes __remove_wait_queue() to use
+			 * list_del_init() in turn breaking the
+			 * !list_empty_careful() check in
+			 * handle_userfault(). The uwq->wq.task_list
+			 * must never be empty at any time during the
+			 * refile, or the waitqueue could disappear
+			 * from under us. The "wait_queue_head_t"
+			 * parameter of __remove_wait_queue() is unused
+			 * anyway.
 			 */
 			list_del(&uwq->wq.task_list);
 			__add_wait_queue(&ctx->fault_wqh, &uwq->wq);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
