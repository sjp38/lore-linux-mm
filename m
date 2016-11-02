Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 93FFA6B028E
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 15:34:10 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id i34so24641675qkh.1
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 12:34:10 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p20si1941501qki.47.2016.11.02.12.34.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Nov 2016 12:34:10 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 09/33] userfaultfd: non-cooperative: Add fork() event, build warning fix
Date: Wed,  2 Nov 2016 20:33:41 +0100
Message-Id: <1478115245-32090-10-git-send-email-aarcange@redhat.com>
In-Reply-To: <1478115245-32090-1-git-send-email-aarcange@redhat.com>
References: <1478115245-32090-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert"@v2.random, " <dgilbert@redhat.com>,  Mike Kravetz <mike.kravetz@oracle.com>,  Shaohua Li <shli@fb.com>,  Pavel Emelyanov <xemul@parallels.com>"@v2.random

It was harmless, but 32bit kernel builds would emit warnings if not
passing through an (unsigned long) cast of the pointer, before storing
it in a __u64.

Warning found by the kbuild test robot.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 fs/userfaultfd.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 1de16c9..07b1c25 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -543,7 +543,7 @@ static int dup_fctx(struct userfaultfd_fork_ctx *fctx)
 	msg_init(&ewq.msg);
 
 	ewq.msg.event = UFFD_EVENT_FORK;
-	ewq.msg.arg.reserved.reserved1 = (__u64)fctx->new;
+	ewq.msg.arg.reserved.reserved1 = (unsigned long)fctx->new;
 
 	return userfaultfd_event_wait_completion(ctx, &ewq);
 }
@@ -797,7 +797,9 @@ static ssize_t userfaultfd_ctx_read(struct userfaultfd_ctx *ctx, int no_wait,
 			*msg = uwq->msg;
 
 			if (uwq->msg.event == UFFD_EVENT_FORK) {
-				fork_nctx = (struct userfaultfd_ctx *)uwq->msg.arg.reserved.reserved1;
+				fork_nctx = (struct userfaultfd_ctx *)
+					(unsigned long)
+					uwq->msg.arg.reserved.reserved1;
 				list_move(&uwq->wq.task_list, &fork_event);
 				spin_unlock(&ctx->event_wqh.lock);
 				ret = 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
