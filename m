Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4F1076B03A8
	for <linux-mm@kvack.org>; Tue, 16 May 2017 06:36:17 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id a66so122173773pfl.6
        for <linux-mm@kvack.org>; Tue, 16 May 2017 03:36:17 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id r85si13284992pfa.372.2017.05.16.03.36.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 May 2017 03:36:16 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4GAT4WW126131
	for <linux-mm@kvack.org>; Tue, 16 May 2017 06:36:16 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2afnmhtgy6-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 16 May 2017 06:36:15 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 16 May 2017 11:36:13 +0100
From: "Mike Rapoport" <rppt@linux.vnet.ibm.com>
Subject: [RFC PATCH 1/5] userfaultfd: introduce userfault_init_waitqueue helper
Date: Tue, 16 May 2017 13:35:58 +0300
In-Reply-To: <1494930962-3318-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1494930962-3318-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1494930962-3318-2-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm <linux-mm@kvack.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 fs/userfaultfd.c | 14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 1446e9d..b061e96 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -134,6 +134,15 @@ static int userfaultfd_wake_function(wait_queue_t *wq, unsigned mode,
 	return ret;
 }
 
+static inline void userfaultfd_init_waitqueue(struct userfaultfd_ctx *ctx,
+					      struct userfaultfd_wait_queue *uwq)
+{
+	init_waitqueue_func_entry(&uwq->wq, userfaultfd_wake_function);
+	uwq->wq.private = current;
+	uwq->ctx = ctx;
+	uwq->waken = false;
+}
+
 /**
  * userfaultfd_ctx_get - Acquires a reference to the internal userfaultfd
  * context.
@@ -405,11 +414,8 @@ int handle_userfault(struct vm_fault *vmf, unsigned long reason)
 	/* take the reference before dropping the mmap_sem */
 	userfaultfd_ctx_get(ctx);
 
-	init_waitqueue_func_entry(&uwq.wq, userfaultfd_wake_function);
-	uwq.wq.private = current;
+	userfaultfd_init_waitqueue(ctx, &uwq);
 	uwq.msg = userfault_msg(vmf->address, vmf->flags, reason);
-	uwq.ctx = ctx;
-	uwq.waken = false;
 
 	return_to_userland =
 		(vmf->flags & (FAULT_FLAG_USER|FAULT_FLAG_KILLABLE)) ==
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
