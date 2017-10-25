Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 22F9F6B0253
	for <linux-mm@kvack.org>; Wed, 25 Oct 2017 12:24:01 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id n8so649940wmg.4
        for <linux-mm@kvack.org>; Wed, 25 Oct 2017 09:24:01 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id u37si1829582edm.140.2017.10.25.09.23.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Oct 2017 09:23:59 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9PGHJCh071744
	for <linux-mm@kvack.org>; Wed, 25 Oct 2017 12:23:58 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2dtua6jagq-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 25 Oct 2017 12:23:58 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 25 Oct 2017 17:23:56 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [RFC PATCH 1/3] userfaultfd: introduce userfaultfd_init_waitqueue helper
Date: Wed, 25 Oct 2017 19:23:35 +0300
In-Reply-To: <1508948617-22505-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1508948617-22505-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1508948617-22505-2-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Pavel Emelyanov <xemul@virtuozzo.com>, Mike Kravetz <mike.kravetz@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, linux-api <linux-api@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

The helper can be used for initialization of wait queue entries for both
page-fault and non-cooperative events

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 fs/userfaultfd.c | 14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 1c713fd5b3e6..efa8b4240039 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -131,6 +131,15 @@ static int userfaultfd_wake_function(wait_queue_entry_t *wq, unsigned mode,
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
@@ -441,12 +450,9 @@ int handle_userfault(struct vm_fault *vmf, unsigned long reason)
 	/* take the reference before dropping the mmap_sem */
 	userfaultfd_ctx_get(ctx);
 
-	init_waitqueue_func_entry(&uwq.wq, userfaultfd_wake_function);
-	uwq.wq.private = current;
+	userfaultfd_init_waitqueue(ctx, &uwq);
 	uwq.msg = userfault_msg(vmf->address, vmf->flags, reason,
 			ctx->features);
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
