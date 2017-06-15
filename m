Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id AE3776B0279
	for <linux-mm@kvack.org>; Thu, 15 Jun 2017 17:48:42 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id o45so20984932qto.5
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 14:48:42 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 127si378682qkm.159.2017.06.15.14.48.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Jun 2017 14:48:41 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 1/1] userfaultfd: shmem: handle coredumping in handle_userfault()
Date: Thu, 15 Jun 2017 23:48:38 +0200
Message-Id: <20170615214838.27429-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mike Kravetz <mike.kravetz@oracle.com>, Hillf Danton <hillf.zj@alibaba-inc.com>

Anon and hugetlbfs handle FOLL_DUMP set by get_dump_page() internally
to __get_user_pages().

shmem as opposed has no special FOLL_DUMP handling there so
handle_mm_fault() is invoked without mmap_sem and ends up calling
handle_userfault() that isn't expecting to be invoked without mmap_sem
held.

This makes handle_userfault() fail immediately if invoked through
shmem_vm_ops->fault during coredumping and solves the problem.

It's zero cost as we already had a check for current->flags to prevent
futex to trigger userfaults during exit (PF_EXITING).

Reported-by: "Dr. David Alan Gilbert" <dgilbert@redhat.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 fs/userfaultfd.c | 29 +++++++++++++++++++++--------
 1 file changed, 21 insertions(+), 8 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index f7555fc25877..1d622f276e3a 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -340,9 +340,28 @@ int handle_userfault(struct vm_fault *vmf, unsigned long reason)
 	bool must_wait, return_to_userland;
 	long blocking_state;
 
-	BUG_ON(!rwsem_is_locked(&mm->mmap_sem));
-
 	ret = VM_FAULT_SIGBUS;
+
+	/*
+	 * We don't do userfault handling for the final child pid update.
+	 *
+	 * We also don't do userfault handling during
+	 * coredumping. hugetlbfs has the special
+	 * follow_hugetlb_page() to skip missing pages in the
+	 * FOLL_DUMP case, anon memory also checks for FOLL_DUMP with
+	 * the no_page_table() helper in follow_page_mask(), but the
+	 * shmem_vm_ops->fault method is invoked even during
+	 * coredumping without mmap_sem and it ends up here.
+	 */
+	if (current->flags & (PF_EXITING|PF_DUMPCORE))
+		goto out;
+
+	/*
+	 * Coredumping runs without mmap_sem so we can only check that
+	 * the mmap_sem is held, if PF_DUMPCORE was not set.
+	 */
+	WARN_ON_ONCE(!rwsem_is_locked(&mm->mmap_sem));
+
 	ctx = vmf->vma->vm_userfaultfd_ctx.ctx;
 	if (!ctx)
 		goto out;
@@ -361,12 +380,6 @@ int handle_userfault(struct vm_fault *vmf, unsigned long reason)
 		goto out;
 
 	/*
-	 * We don't do userfault handling for the final child pid update.
-	 */
-	if (current->flags & PF_EXITING)
-		goto out;
-
-	/*
 	 * Check that we can return VM_FAULT_RETRY.
 	 *
 	 * NOTE: it should become possible to return VM_FAULT_RETRY

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
