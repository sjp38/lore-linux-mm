Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2C21B6B026D
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 09:48:29 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id q186so21187878itb.0
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 06:48:29 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b190si6169838iob.122.2016.12.16.06.48.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 06:48:28 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 27/42] userfaultfd: introduce vma_can_userfault
Date: Fri, 16 Dec 2016 15:48:06 +0100
Message-Id: <20161216144821.5183-28-aarcange@redhat.com>
In-Reply-To: <20161216144821.5183-1-aarcange@redhat.com>
References: <20161216144821.5183-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@parallels.com>, Hillf Danton <hillf.zj@alibaba-inc.com>

From: Mike Rapoport <rppt@linux.vnet.ibm.com>

Check whether a VMA can be used with userfault in more compact way

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 fs/userfaultfd.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 92614c0..eccfc18 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -1063,6 +1063,11 @@ static __always_inline int validate_range(struct mm_struct *mm,
 	return 0;
 }
 
+static inline bool vma_can_userfault(struct vm_area_struct *vma)
+{
+	return vma_is_anonymous(vma) || is_vm_hugetlb_page(vma);
+}
+
 static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 				unsigned long arg)
 {
@@ -1152,7 +1157,7 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 
 		/* check not compatible vmas */
 		ret = -EINVAL;
-		if (!vma_is_anonymous(cur) && !is_vm_hugetlb_page(cur))
+		if (!vma_can_userfault(cur))
 			goto out_unlock;
 		/*
 		 * If this vma contains ending address, and huge pages
@@ -1196,7 +1201,7 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 	do {
 		cond_resched();
 
-		BUG_ON(!vma_is_anonymous(vma) && !is_vm_hugetlb_page(vma));
+		BUG_ON(!vma_can_userfault(vma));
 		BUG_ON(vma->vm_userfaultfd_ctx.ctx &&
 		       vma->vm_userfaultfd_ctx.ctx != ctx);
 
@@ -1334,7 +1339,7 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
 		 * provides for more strict behavior to notice
 		 * unregistration errors.
 		 */
-		if (!vma_is_anonymous(cur) && !is_vm_hugetlb_page(cur))
+		if (!vma_can_userfault(cur))
 			goto out_unlock;
 
 		found = true;
@@ -1348,7 +1353,7 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
 	do {
 		cond_resched();
 
-		BUG_ON(!vma_is_anonymous(vma) && !is_vm_hugetlb_page(vma));
+		BUG_ON(!vma_can_userfault(vma));
 
 		/*
 		 * Nothing to do: this vma is already registered into this

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
