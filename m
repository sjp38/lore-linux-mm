Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 90FAD6B0389
	for <linux-mm@kvack.org>; Fri, 24 Feb 2017 13:20:03 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id j30so16934325qta.2
        for <linux-mm@kvack.org>; Fri, 24 Feb 2017 10:20:03 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u68si6173217qkl.117.2017.02.24.10.20.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Feb 2017 10:20:02 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 2/3] userfaultfd: non-cooperative: robustness check
Date: Fri, 24 Feb 2017 19:19:56 +0100
Message-Id: <20170224181957.19736-3-aarcange@redhat.com>
In-Reply-To: <20170224181957.19736-1-aarcange@redhat.com>
References: <20170224181957.19736-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@parallels.com>, Hillf Danton <hillf.zj@alibaba-inc.com>

Similar to the handle_userfault() case, also make sure to never
attempt to send any event past the PF_EXITING point of no return.

This is purely a robustness check.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 fs/userfaultfd.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 52733a7..3d7c248 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -529,8 +529,13 @@ int handle_userfault(struct vm_fault *vmf, unsigned long reason)
 static int userfaultfd_event_wait_completion(struct userfaultfd_ctx *ctx,
 					     struct userfaultfd_wait_queue *ewq)
 {
-	int ret = 0;
+	int ret;
+
+	ret = -1;
+	if (WARN_ON_ONCE(current->flags & PF_EXITING))
+		goto out;
 
+	ret = 0;
 	ewq->ctx = ctx;
 	init_waitqueue_entry(&ewq->wq, current);
 
@@ -565,7 +570,7 @@ static int userfaultfd_event_wait_completion(struct userfaultfd_ctx *ctx,
 	 * ctx may go away after this if the userfault pseudo fd is
 	 * already released.
 	 */
-
+out:
 	userfaultfd_ctx_put(ctx);
 	return ret;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
