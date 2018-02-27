Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7656F6B0007
	for <linux-mm@kvack.org>; Tue, 27 Feb 2018 03:20:06 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id s8so2847627qtn.6
        for <linux-mm@kvack.org>; Tue, 27 Feb 2018 00:20:06 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id k24si10781674qkl.389.2018.02.27.00.20.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Feb 2018 00:20:05 -0800 (PST)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w1R8JGYc092370
	for <linux-mm@kvack.org>; Tue, 27 Feb 2018 03:20:04 -0500
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2gd1yav3kr-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 27 Feb 2018 03:20:04 -0500
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 27 Feb 2018 08:20:01 -0000
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 1/3] userfaultfd: introduce userfaultfd_init_waitqueue helper
Date: Tue, 27 Feb 2018 10:19:50 +0200
In-Reply-To: <1519719592-22668-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1519719592-22668-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1519719592-22668-2-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm <linux-mm@kvack.org>, linux-api <linux-api@vger.kernel.org>, lkml <linux-kernel@vger.kernel.org>, crml <criu@openvz.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

The helper can be used for initialization of wait queue entries for both
page-fault and non-cooperative events

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 fs/userfaultfd.c | 14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index cec550c8468f..b32c7aaeca6b 100644
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
@@ -444,12 +453,9 @@ int handle_userfault(struct vm_fault *vmf, unsigned long reason)
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
