Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 04C606B0275
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 09:48:29 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id f73so92506973ioe.1
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 06:48:29 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p186si2949402itc.56.2016.12.16.06.48.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 06:48:28 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 21/42] userfaultfd: hugetlbfs: allow registration of ranges containing huge pages
Date: Fri, 16 Dec 2016 15:48:00 +0100
Message-Id: <20161216144821.5183-22-aarcange@redhat.com>
In-Reply-To: <20161216144821.5183-1-aarcange@redhat.com>
References: <20161216144821.5183-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@parallels.com>, Hillf Danton <hillf.zj@alibaba-inc.com>

From: Mike Kravetz <mike.kravetz@oracle.com>

Expand the userfaultfd_register/unregister routines to allow VM_HUGETLB
vmas.  huge page alignment checking is performed after a VM_HUGETLB
vma is encountered.

Also, since there is no UFFDIO_ZEROPAGE support for huge pages do not
return that as a valid ioctl method for huge page ranges.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 fs/userfaultfd.c                 | 55 ++++++++++++++++++++++++++++++++++++----
 include/uapi/linux/userfaultfd.h |  3 +++
 2 files changed, 53 insertions(+), 5 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 22f978d..1268496 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -27,6 +27,7 @@
 #include <linux/mempolicy.h>
 #include <linux/ioctl.h>
 #include <linux/security.h>
+#include <linux/hugetlb.h>
 
 static struct kmem_cache *userfaultfd_ctx_cachep __read_mostly;
 
@@ -1025,6 +1026,7 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 	struct uffdio_register __user *user_uffdio_register;
 	unsigned long vm_flags, new_flags;
 	bool found;
+	bool huge_pages;
 	unsigned long start, end, vma_end;
 
 	user_uffdio_register = (struct uffdio_register __user *) arg;
@@ -1076,6 +1078,17 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 		goto out_unlock;
 
 	/*
+	 * If the first vma contains huge pages, make sure start address
+	 * is aligned to huge page size.
+	 */
+	if (is_vm_hugetlb_page(vma)) {
+		unsigned long vma_hpagesize = vma_kernel_pagesize(vma);
+
+		if (start & (vma_hpagesize - 1))
+			goto out_unlock;
+	}
+
+	/*
 	 * Search for not compatible vmas.
 	 *
 	 * FIXME: this shall be relaxed later so that it doesn't fail
@@ -1083,6 +1096,7 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 	 * on anonymous vmas).
 	 */
 	found = false;
+	huge_pages = false;
 	for (cur = vma; cur && cur->vm_start < end; cur = cur->vm_next) {
 		cond_resched();
 
@@ -1091,8 +1105,21 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 
 		/* check not compatible vmas */
 		ret = -EINVAL;
-		if (!vma_is_anonymous(cur))
+		if (!vma_is_anonymous(cur) && !is_vm_hugetlb_page(cur))
 			goto out_unlock;
+		/*
+		 * If this vma contains ending address, and huge pages
+		 * check alignment.
+		 */
+		if (is_vm_hugetlb_page(cur) && end <= cur->vm_end &&
+		    end > cur->vm_start) {
+			unsigned long vma_hpagesize = vma_kernel_pagesize(cur);
+
+			ret = -EINVAL;
+
+			if (end & (vma_hpagesize - 1))
+				goto out_unlock;
+		}
 
 		/*
 		 * Check that this vma isn't already owned by a
@@ -1105,6 +1132,12 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 		    cur->vm_userfaultfd_ctx.ctx != ctx)
 			goto out_unlock;
 
+		/*
+		 * Note vmas containing huge pages
+		 */
+		if (is_vm_hugetlb_page(cur))
+			huge_pages = true;
+
 		found = true;
 	}
 	BUG_ON(!found);
@@ -1116,7 +1149,7 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 	do {
 		cond_resched();
 
-		BUG_ON(!vma_is_anonymous(vma));
+		BUG_ON(!vma_is_anonymous(vma) && !is_vm_hugetlb_page(vma));
 		BUG_ON(vma->vm_userfaultfd_ctx.ctx &&
 		       vma->vm_userfaultfd_ctx.ctx != ctx);
 
@@ -1174,7 +1207,8 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 		 * userland which ioctls methods are guaranteed to
 		 * succeed on this range.
 		 */
-		if (put_user(UFFD_API_RANGE_IOCTLS,
+		if (put_user(huge_pages ? UFFD_API_RANGE_IOCTLS_HPAGE :
+			     UFFD_API_RANGE_IOCTLS,
 			     &user_uffdio_register->ioctls))
 			ret = -EFAULT;
 	}
@@ -1221,6 +1255,17 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
 		goto out_unlock;
 
 	/*
+	 * If the first vma contains huge pages, make sure start address
+	 * is aligned to huge page size.
+	 */
+	if (is_vm_hugetlb_page(vma)) {
+		unsigned long vma_hpagesize = vma_kernel_pagesize(vma);
+
+		if (start & (vma_hpagesize - 1))
+			goto out_unlock;
+	}
+
+	/*
 	 * Search for not compatible vmas.
 	 *
 	 * FIXME: this shall be relaxed later so that it doesn't fail
@@ -1242,7 +1287,7 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
 		 * provides for more strict behavior to notice
 		 * unregistration errors.
 		 */
-		if (!vma_is_anonymous(cur))
+		if (!vma_is_anonymous(cur) && !is_vm_hugetlb_page(cur))
 			goto out_unlock;
 
 		found = true;
@@ -1256,7 +1301,7 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
 	do {
 		cond_resched();
 
-		BUG_ON(!vma_is_anonymous(vma));
+		BUG_ON(!vma_is_anonymous(vma) && !is_vm_hugetlb_page(vma));
 
 		/*
 		 * Nothing to do: this vma is already registered into this
diff --git a/include/uapi/linux/userfaultfd.h b/include/uapi/linux/userfaultfd.h
index 2bbf323..a3828a9 100644
--- a/include/uapi/linux/userfaultfd.h
+++ b/include/uapi/linux/userfaultfd.h
@@ -29,6 +29,9 @@
 	((__u64)1 << _UFFDIO_WAKE |		\
 	 (__u64)1 << _UFFDIO_COPY |		\
 	 (__u64)1 << _UFFDIO_ZEROPAGE)
+#define UFFD_API_RANGE_IOCTLS_HPAGE		\
+	((__u64)1 << _UFFDIO_WAKE |		\
+	 (__u64)1 << _UFFDIO_COPY)
 
 /*
  * Valid ioctl command number range with this API is from 0x00 to

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
