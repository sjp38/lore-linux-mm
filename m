Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 86DF46B0387
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 12:37:42 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id n127so108252525qkf.3
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 09:37:42 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i20si5302693qta.138.2017.03.02.09.37.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Mar 2017 09:37:41 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 1/3] userfaultfd: non-cooperative: fix fork fctx->new memleak
Date: Thu,  2 Mar 2017 18:37:36 +0100
Message-Id: <20170302173738.18994-2-aarcange@redhat.com>
In-Reply-To: <20170302173738.18994-1-aarcange@redhat.com>
References: <20170302173738.18994-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@parallels.com>, Hillf Danton <hillf.zj@alibaba-inc.com>

From: Mike Rapoport <rppt@linux.vnet.ibm.com>

We have a memleak in the ->new ctx if the uffd of the parent is closed
before the fork event is read, nothing frees the new context.

Reported-by: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 fs/userfaultfd.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index d2f15a6..5087a69 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -548,6 +548,15 @@ static void userfaultfd_event_wait_completion(struct userfaultfd_ctx *ctx,
 		if (ACCESS_ONCE(ctx->released) ||
 		    fatal_signal_pending(current)) {
 			__remove_wait_queue(&ctx->event_wqh, &ewq->wq);
+			if (ewq->msg.event == UFFD_EVENT_FORK) {
+				struct userfaultfd_ctx *new;
+
+				new = (struct userfaultfd_ctx *)
+					(unsigned long)
+					ewq->msg.arg.reserved.reserved1;
+
+				userfaultfd_ctx_put(new);
+			}
 			break;
 		}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
