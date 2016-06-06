Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id B18326B007E
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 13:53:23 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id d191so77613803oig.2
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 10:53:23 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id q16si4421801itc.78.2016.06.06.10.53.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jun 2016 10:53:22 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC PATCH 5/6] fs/userfaultfd: allow registration of ranges containing huge pages
Date: Mon,  6 Jun 2016 10:45:30 -0700
Message-Id: <1465235131-6112-6-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1465235131-6112-1-git-send-email-mike.kravetz@oracle.com>
References: <1465235131-6112-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

Expand the userfaultfd_register/unregister routines to allow VM_HUGETLB
vmas.  huge page alignment checking is performed after a VM_HUGETLB
vma is encountered.

Also, since there is no UFFDIO_ZEROPAGE support for huge pages do not
return that as a valid ioctl method for huge page ranges.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 fs/userfaultfd.c                 | 69 +++++++++++++++++++++++++++++++++++++---
 include/uapi/linux/userfaultfd.h |  3 ++
 2 files changed, 67 insertions(+), 5 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 2d97952..7a1a345 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -26,6 +26,7 @@
 #include <linux/mempolicy.h>
 #include <linux/ioctl.h>
 #include <linux/security.h>
+#include <linux/hugetlb.h>
 
 static struct kmem_cache *userfaultfd_ctx_cachep __read_mostly;
 
@@ -728,6 +729,7 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 	struct uffdio_register __user *user_uffdio_register;
 	unsigned long vm_flags, new_flags;
 	bool found;
+	bool huge_pages;
 	unsigned long start, end, vma_end;
 
 	user_uffdio_register = (struct uffdio_register __user *) arg;
@@ -779,6 +781,17 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 		goto out_unlock;
 
 	/*
+	 * If the first vma contains huge pages, make sure start address
+	 * is aligned to huge page size.
+	 */
+	if (vma->vm_flags & VM_HUGETLB) {
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
@@ -786,6 +799,7 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 	 * on anonymous vmas).
 	 */
 	found = false;
+	huge_pages = false;
 	for (cur = vma; cur && cur->vm_start < end; cur = cur->vm_next) {
 		cond_resched();
 
@@ -794,7 +808,7 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 
 		/* check not compatible vmas */
 		ret = -EINVAL;
-		if (cur->vm_ops)
+		if (cur->vm_ops && !(cur->vm_flags & VM_HUGETLB))
 			goto out_unlock;
 
 		/*
@@ -808,6 +822,25 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 		    cur->vm_userfaultfd_ctx.ctx != ctx)
 			goto out_unlock;
 
+		/*
+		 * Note vmas containing huge pages
+		 */
+		if (cur->vm_flags & VM_HUGETLB) {
+			huge_pages = true;
+
+			/*
+			 * If vma contains end address, check alignment
+			 */
+			ret = -EINVAL;
+			if (end <= cur->vm_end && end > cur->vm_start) {
+				unsigned long vma_hpagesize =
+					vma_kernel_pagesize(cur);
+
+				if (end & (vma_hpagesize - 1))
+					goto out_unlock;
+			}
+		}
+
 		found = true;
 	}
 	BUG_ON(!found);
@@ -819,7 +852,7 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 	do {
 		cond_resched();
 
-		BUG_ON(vma->vm_ops);
+		BUG_ON(vma->vm_ops && !(vma->vm_flags & VM_HUGETLB));
 		BUG_ON(vma->vm_userfaultfd_ctx.ctx &&
 		       vma->vm_userfaultfd_ctx.ctx != ctx);
 
@@ -877,7 +910,8 @@ out_unlock:
 		 * userland which ioctls methods are guaranteed to
 		 * succeed on this range.
 		 */
-		if (put_user(UFFD_API_RANGE_IOCTLS,
+		if (put_user(huge_pages ? UFFD_API_RANGE_IOCTLS_HPAGE :
+			     UFFD_API_RANGE_IOCTLS,
 			     &user_uffdio_register->ioctls))
 			ret = -EFAULT;
 	}
@@ -924,6 +958,17 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
 		goto out_unlock;
 
 	/*
+	 * If the first vma contains huge pages, make sure start address
+	 * is aligned to huge page size.
+	 */
+	if (vma->vm_flags & VM_HUGETLB) {
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
@@ -945,9 +990,23 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
 		 * provides for more strict behavior to notice
 		 * unregistration errors.
 		 */
-		if (cur->vm_ops)
+		if (cur->vm_ops && !(cur->vm_flags & VM_HUGETLB))
 			goto out_unlock;
 
+		/*
+		 * If this vma contains ending address, and huge pages
+		 * check alignment.
+		 */
+		if (cur->vm_flags & VM_HUGETLB && end <= cur->vm_end &&
+							end > cur->vm_start) {
+			unsigned long vma_hpagesize = vma_kernel_pagesize(cur);
+
+			ret = -EINVAL;
+
+			if (end & (vma_hpagesize - 1))
+				goto out_unlock;
+		}
+
 		found = true;
 	}
 	BUG_ON(!found);
@@ -959,7 +1018,7 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
 	do {
 		cond_resched();
 
-		BUG_ON(vma->vm_ops);
+		BUG_ON(vma->vm_ops && !(vma->vm_flags & VM_HUGETLB));
 
 		/*
 		 * Nothing to do: this vma is already registered into this
diff --git a/include/uapi/linux/userfaultfd.h b/include/uapi/linux/userfaultfd.h
index 9057d7a..751d814 100644
--- a/include/uapi/linux/userfaultfd.h
+++ b/include/uapi/linux/userfaultfd.h
@@ -26,6 +26,9 @@
 	((__u64)1 << _UFFDIO_WAKE |		\
 	 (__u64)1 << _UFFDIO_COPY |		\
 	 (__u64)1 << _UFFDIO_ZEROPAGE)
+#define UFFD_API_RANGE_IOCTLS_HPAGE		\
+	((__u64)1 << _UFFDIO_WAKE |		\
+	 (__u64)1 << _UFFDIO_COPY)
 
 /*
  * Valid ioctl command number range with this API is from 0x00 to
-- 
2.4.11

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
