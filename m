Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3A98A6B0253
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 09:50:06 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id g187so21134014itc.2
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 06:50:06 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e125si6180939ioe.47.2016.12.16.06.48.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 06:48:26 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 09/42] userfaultfd: non-cooperative: Add fork() event, build warning fix
Date: Fri, 16 Dec 2016 15:47:48 +0100
Message-Id: <20161216144821.5183-10-aarcange@redhat.com>
In-Reply-To: <20161216144821.5183-1-aarcange@redhat.com>
References: <20161216144821.5183-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@parallels.com>, Hillf Danton <hillf.zj@alibaba-inc.com>

It was harmless, but 32bit kernel builds would emit warnings if not
passing through an (unsigned long) cast of the pointer, before storing
it in a __u64.

Warning found by the kbuild test robot.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 fs/userfaultfd.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 09e8d5b..6fe0efd 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -545,7 +545,7 @@ static int dup_fctx(struct userfaultfd_fork_ctx *fctx)
 	msg_init(&ewq.msg);
 
 	ewq.msg.event = UFFD_EVENT_FORK;
-	ewq.msg.arg.reserved.reserved1 = (__u64)fctx->new;
+	ewq.msg.arg.reserved.reserved1 = (unsigned long)fctx->new;
 
 	return userfaultfd_event_wait_completion(ctx, &ewq);
 }
@@ -799,7 +799,9 @@ static ssize_t userfaultfd_ctx_read(struct userfaultfd_ctx *ctx, int no_wait,
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
