Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id C1A696B028C
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 15:34:09 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id p16so10706690qta.5
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 12:34:09 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c74si1942865qkg.55.2016.11.02.12.34.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Nov 2016 12:34:09 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 04/33] userfaultfd: use vma_is_anonymous
Date: Wed,  2 Nov 2016 20:33:36 +0100
Message-Id: <1478115245-32090-5-git-send-email-aarcange@redhat.com>
In-Reply-To: <1478115245-32090-1-git-send-email-aarcange@redhat.com>
References: <1478115245-32090-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert"@v2.random, " <dgilbert@redhat.com>,  Mike Kravetz <mike.kravetz@oracle.com>,  Shaohua Li <shli@fb.com>,  Pavel Emelyanov <xemul@parallels.com>"@v2.random

Cleanup the vma->vm_ops usage.

Side note: it would be more robust if vma_is_anonymous() would also
check that vm_flags hasn't VM_PFNMAP set.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 fs/userfaultfd.c | 8 ++++----
 mm/userfaultfd.c | 2 +-
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 5a1c3cf..4161f99 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -795,7 +795,7 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 
 		/* check not compatible vmas */
 		ret = -EINVAL;
-		if (cur->vm_ops)
+		if (!vma_is_anonymous(cur))
 			goto out_unlock;
 
 		/*
@@ -820,7 +820,7 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 	do {
 		cond_resched();
 
-		BUG_ON(vma->vm_ops);
+		BUG_ON(!vma_is_anonymous(vma));
 		BUG_ON(vma->vm_userfaultfd_ctx.ctx &&
 		       vma->vm_userfaultfd_ctx.ctx != ctx);
 
@@ -946,7 +946,7 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
 		 * provides for more strict behavior to notice
 		 * unregistration errors.
 		 */
-		if (cur->vm_ops)
+		if (!vma_is_anonymous(cur))
 			goto out_unlock;
 
 		found = true;
@@ -960,7 +960,7 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
 	do {
 		cond_resched();
 
-		BUG_ON(vma->vm_ops);
+		BUG_ON(!vma_is_anonymous(vma));
 
 		/*
 		 * Nothing to do: this vma is already registered into this
diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
index af817e5..9c2ed70 100644
--- a/mm/userfaultfd.c
+++ b/mm/userfaultfd.c
@@ -197,7 +197,7 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
 	 * FIXME: only allow copying on anonymous vmas, tmpfs should
 	 * be added.
 	 */
-	if (dst_vma->vm_ops)
+	if (!vma_is_anonymous(dst_vma))
 		goto out_unlock;
 
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
