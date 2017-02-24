Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4BFE26B0038
	for <linux-mm@kvack.org>; Fri, 24 Feb 2017 13:20:02 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id r90so25974747qki.0
        for <linux-mm@kvack.org>; Fri, 24 Feb 2017 10:20:02 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p13si6184448qtg.6.2017.02.24.10.20.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Feb 2017 10:20:01 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 3/3] userfaultfd: non-cooperative: release all ctx in dup_userfaultfd_complete
Date: Fri, 24 Feb 2017 19:19:57 +0100
Message-Id: <20170224181957.19736-4-aarcange@redhat.com>
In-Reply-To: <20170224181957.19736-1-aarcange@redhat.com>
References: <20170224181957.19736-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@parallels.com>, Hillf Danton <hillf.zj@alibaba-inc.com>

Don't stop running dup_fctx() even if
userfaultfd_event_wait_completion fails as it has to run
userfaultfd_ctx_put on all ctx to pair against the userfaultfd_ctx_get
that was run on all fctx->orig in dup_userfaultfd.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 fs/userfaultfd.c | 18 +++++-------------
 1 file changed, 5 insertions(+), 13 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 3d7c248..0072f04 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -526,16 +526,12 @@ int handle_userfault(struct vm_fault *vmf, unsigned long reason)
 	return ret;
 }
 
-static int userfaultfd_event_wait_completion(struct userfaultfd_ctx *ctx,
-					     struct userfaultfd_wait_queue *ewq)
+static void userfaultfd_event_wait_completion(struct userfaultfd_ctx *ctx,
+					      struct userfaultfd_wait_queue *ewq)
 {
-	int ret;
-
-	ret = -1;
 	if (WARN_ON_ONCE(current->flags & PF_EXITING))
 		goto out;
 
-	ret = 0;
 	ewq->ctx = ctx;
 	init_waitqueue_entry(&ewq->wq, current);
 
@@ -551,7 +547,6 @@ static int userfaultfd_event_wait_completion(struct userfaultfd_ctx *ctx,
 			break;
 		if (ACCESS_ONCE(ctx->released) ||
 		    fatal_signal_pending(current)) {
-			ret = -1;
 			__remove_wait_queue(&ctx->event_wqh, &ewq->wq);
 			break;
 		}
@@ -572,7 +567,6 @@ static int userfaultfd_event_wait_completion(struct userfaultfd_ctx *ctx,
 	 */
 out:
 	userfaultfd_ctx_put(ctx);
-	return ret;
 }
 
 static void userfaultfd_event_complete(struct userfaultfd_ctx *ctx,
@@ -630,7 +624,7 @@ int dup_userfaultfd(struct vm_area_struct *vma, struct list_head *fcs)
 	return 0;
 }
 
-static int dup_fctx(struct userfaultfd_fork_ctx *fctx)
+static void dup_fctx(struct userfaultfd_fork_ctx *fctx)
 {
 	struct userfaultfd_ctx *ctx = fctx->orig;
 	struct userfaultfd_wait_queue ewq;
@@ -640,17 +634,15 @@ static int dup_fctx(struct userfaultfd_fork_ctx *fctx)
 	ewq.msg.event = UFFD_EVENT_FORK;
 	ewq.msg.arg.reserved.reserved1 = (unsigned long)fctx->new;
 
-	return userfaultfd_event_wait_completion(ctx, &ewq);
+	userfaultfd_event_wait_completion(ctx, &ewq);
 }
 
 void dup_userfaultfd_complete(struct list_head *fcs)
 {
-	int ret = 0;
 	struct userfaultfd_fork_ctx *fctx, *n;
 
 	list_for_each_entry_safe(fctx, n, fcs, list) {
-		if (!ret)
-			ret = dup_fctx(fctx);
+		dup_fctx(fctx);
 		list_del(&fctx->list);
 		kfree(fctx);
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
