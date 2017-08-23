Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8E5A62803E9
	for <linux-mm@kvack.org>; Wed, 23 Aug 2017 14:12:31 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id n27so3932137qki.2
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 11:12:31 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w41si1956839qtk.104.2017.08.23.11.12.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Aug 2017 11:12:30 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 1/1] userfaultfd: non-cooperative: closing the uffd without triggering SIGBUS
Date: Wed, 23 Aug 2017 20:12:27 +0200
Message-Id: <20170823181227.19926-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@virtuozzo.com>

This is an enhancement to avoid a non cooperative userfaultfd manager
having to unregister all regions before it can close the uffd after
all userfaultfd activity completed.

The UFFDIO_UNREGISTER would serialize against the handle_userfault
by taking the mmap_sem for writing, but we can simply repeat the page
fault if we detect the uffd was closed and so the regular page fault
paths should takeover.

Acked-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 fs/userfaultfd.c | 20 +++++++++++++++++++-
 1 file changed, 19 insertions(+), 1 deletion(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 272c21d8d532..186831c80a75 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -394,8 +394,26 @@ int handle_userfault(struct vm_fault *vmf, unsigned long reason)
 	 * in __get_user_pages if userfaultfd_release waits on the
 	 * caller of handle_userfault to release the mmap_sem.
 	 */
-	if (unlikely(ACCESS_ONCE(ctx->released)))
+	if (unlikely(ACCESS_ONCE(ctx->released))) {
+		/*
+		 * Don't return VM_FAULT_SIGBUS in this case, so a non
+		 * cooperative manager can close the uffd after the
+		 * last UFFDIO_COPY, without risking to trigger an
+		 * involuntary SIGBUS if the process was starting the
+		 * userfaultfd while the userfaultfd was still armed
+		 * (but after the last UFFDIO_COPY). If the uffd
+		 * wasn't already closed when the userfault reached
+		 * this point, that would normally be solved by
+		 * userfaultfd_must_wait returning 'false'.
+		 *
+		 * If we were to return VM_FAULT_SIGBUS here, the non
+		 * cooperative manager would be instead forced to
+		 * always call UFFDIO_UNREGISTER before it can safely
+		 * close the uffd.
+		 */
+		ret = VM_FAULT_NOPAGE;
 		goto out;
+	}
 
 	/*
 	 * Check that we can return VM_FAULT_RETRY.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
