Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8F2786B0069
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 09:48:25 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id 81so92923489iog.0
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 06:48:25 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i206si2943140ita.70.2016.12.16.06.48.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 06:48:24 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 04/42] userfaultfd: use vma_is_anonymous
Date: Fri, 16 Dec 2016 15:47:43 +0100
Message-Id: <20161216144821.5183-5-aarcange@redhat.com>
In-Reply-To: <20161216144821.5183-1-aarcange@redhat.com>
References: <20161216144821.5183-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@parallels.com>, Hillf Danton <hillf.zj@alibaba-inc.com>

Cleanup the vma->vm_ops usage.

Side note: it would be more robust if vma_is_anonymous() would also
check that vm_flags hasn't VM_PFNMAP set.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 fs/userfaultfd.c | 8 ++++----
 mm/userfaultfd.c | 2 +-
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 4edbd99..0f998d1 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -797,7 +797,7 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 
 		/* check not compatible vmas */
 		ret = -EINVAL;
-		if (cur->vm_ops)
+		if (!vma_is_anonymous(cur))
 			goto out_unlock;
 
 		/*
@@ -822,7 +822,7 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 	do {
 		cond_resched();
 
-		BUG_ON(vma->vm_ops);
+		BUG_ON(!vma_is_anonymous(vma));
 		BUG_ON(vma->vm_userfaultfd_ctx.ctx &&
 		       vma->vm_userfaultfd_ctx.ctx != ctx);
 
@@ -948,7 +948,7 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
 		 * provides for more strict behavior to notice
 		 * unregistration errors.
 		 */
-		if (cur->vm_ops)
+		if (!vma_is_anonymous(cur))
 			goto out_unlock;
 
 		found = true;
@@ -962,7 +962,7 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
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
