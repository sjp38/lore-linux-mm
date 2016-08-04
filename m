Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id B3A4A6B0262
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 04:15:04 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id w128so442651491pfd.3
        for <linux-mm@kvack.org>; Thu, 04 Aug 2016 01:15:04 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id ux1si13474677pac.84.2016.08.04.01.15.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Aug 2016 01:15:03 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u748Ds1V130415
	for <linux-mm@kvack.org>; Thu, 4 Aug 2016 04:15:03 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 24kngchmhr-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 04 Aug 2016 04:15:03 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 4 Aug 2016 09:15:01 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 6F4081B0805F
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 09:16:28 +0100 (BST)
Received: from d06av08.portsmouth.uk.ibm.com (d06av08.portsmouth.uk.ibm.com [9.149.37.249])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u748EvQH15204596
	for <linux-mm@kvack.org>; Thu, 4 Aug 2016 08:14:57 GMT
Received: from d06av08.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av08.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u748Ev1q000727
	for <linux-mm@kvack.org>; Thu, 4 Aug 2016 02:14:57 -0600
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 6/7] userfaultfd: shmem: allow registration of shared memory ranges
Date: Thu,  4 Aug 2016 11:14:17 +0300
In-Reply-To: <1470298458-9925-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1470298458-9925-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1470298458-9925-7-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Expand the userfaultfd_register/unregister routines to allow shared memory
VMAs. Currently, there is no UFFDIO_ZEROPAGE and write-protection support
for shared memory VMAs, which is reflected in ioctl methods supported by
uffdio_register.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 fs/userfaultfd.c                         | 21 +++++++--------------
 include/uapi/linux/userfaultfd.h         |  2 +-
 tools/testing/selftests/vm/userfaultfd.c |  2 +-
 3 files changed, 9 insertions(+), 16 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 2aab2e1..2f9c87e 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -1068,7 +1068,8 @@ static __always_inline int validate_range(struct mm_struct *mm,
 
 static inline bool vma_can_userfault(struct vm_area_struct *vma)
 {
-	return vma_is_anonymous(vma) || is_vm_hugetlb_page(vma);
+	return vma_is_anonymous(vma) || is_vm_hugetlb_page(vma) ||
+		vma_is_shmem(vma);
 }
 
 static int userfaultfd_register(struct userfaultfd_ctx *ctx,
@@ -1081,7 +1082,7 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 	struct uffdio_register __user *user_uffdio_register;
 	unsigned long vm_flags, new_flags;
 	bool found;
-	bool huge_pages;
+	bool non_anon_pages;
 	unsigned long start, end, vma_end;
 
 	user_uffdio_register = (struct uffdio_register __user *) arg;
@@ -1138,13 +1139,9 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 
 	/*
 	 * Search for not compatible vmas.
-	 *
-	 * FIXME: this shall be relaxed later so that it doesn't fail
-	 * on tmpfs backed vmas (in addition to the current allowance
-	 * on anonymous vmas).
 	 */
 	found = false;
-	huge_pages = false;
+	non_anon_pages = false;
 	for (cur = vma; cur && cur->vm_start < end; cur = cur->vm_next) {
 		cond_resched();
 
@@ -1188,8 +1185,8 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 		/*
 		 * Note vmas containing huge pages
 		 */
-		if (is_vm_hugetlb_page(cur))
-			huge_pages = true;
+		if (is_vm_hugetlb_page(cur) || vma_is_shmem(cur))
+			non_anon_pages = true;
 
 		found = true;
 	}
@@ -1260,7 +1257,7 @@ out_unlock:
 		 * userland which ioctls methods are guaranteed to
 		 * succeed on this range.
 		 */
-		if (put_user(huge_pages ? UFFD_API_RANGE_IOCTLS_HPAGE :
+		if (put_user(non_anon_pages ? UFFD_API_RANGE_IOCTLS_BASIC :
 			     UFFD_API_RANGE_IOCTLS,
 			     &user_uffdio_register->ioctls))
 			ret = -EFAULT;
@@ -1320,10 +1317,6 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
 
 	/*
 	 * Search for not compatible vmas.
-	 *
-	 * FIXME: this shall be relaxed later so that it doesn't fail
-	 * on tmpfs backed vmas (in addition to the current allowance
-	 * on anonymous vmas).
 	 */
 	found = false;
 	ret = -EINVAL;
diff --git a/include/uapi/linux/userfaultfd.h b/include/uapi/linux/userfaultfd.h
index 7a386c5..a9c3389 100644
--- a/include/uapi/linux/userfaultfd.h
+++ b/include/uapi/linux/userfaultfd.h
@@ -31,7 +31,7 @@
 	 (__u64)1 << _UFFDIO_COPY |		\
 	 (__u64)1 << _UFFDIO_ZEROPAGE |		\
 	 (__u64)1 << _UFFDIO_WRITEPROTECT)
-#define UFFD_API_RANGE_IOCTLS_HPAGE		\
+#define UFFD_API_RANGE_IOCTLS_BASIC		\
 	((__u64)1 << _UFFDIO_WAKE |		\
 	 (__u64)1 << _UFFDIO_COPY)
 
diff --git a/tools/testing/selftests/vm/userfaultfd.c b/tools/testing/selftests/vm/userfaultfd.c
index 3011711..d753a91 100644
--- a/tools/testing/selftests/vm/userfaultfd.c
+++ b/tools/testing/selftests/vm/userfaultfd.c
@@ -129,7 +129,7 @@ static void allocate_area(void **alloc_area)
 
 #else /* HUGETLB_TEST */
 
-#define EXPECTED_IOCTLS		UFFD_API_RANGE_IOCTLS_HPAGE
+#define EXPECTED_IOCTLS		UFFD_API_RANGE_IOCTLS_BASIC
 
 static int release_pages(char *rel_area)
 {
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
