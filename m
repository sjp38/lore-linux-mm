Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7D0F16B02BA
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 15:34:13 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id g193so23147516qke.2
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 12:34:13 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q65si102814qkb.299.2016.11.02.12.34.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Nov 2016 12:34:12 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 26/33] userfaultfd: shmem: allow registration of shared memory ranges
Date: Wed,  2 Nov 2016 20:33:58 +0100
Message-Id: <1478115245-32090-27-git-send-email-aarcange@redhat.com>
In-Reply-To: <1478115245-32090-1-git-send-email-aarcange@redhat.com>
References: <1478115245-32090-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert"@v2.random, " <dgilbert@redhat.com>,  Mike Kravetz <mike.kravetz@oracle.com>,  Shaohua Li <shli@fb.com>,  Pavel Emelyanov <xemul@parallels.com>"@v2.random

From: Mike Rapoport <rppt@linux.vnet.ibm.com>

Expand the userfaultfd_register/unregister routines to allow shared memory
VMAs. Currently, there is no UFFDIO_ZEROPAGE and write-protection support
for shared memory VMAs, which is reflected in ioctl methods supported by
uffdio_register.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 fs/userfaultfd.c                         | 21 +++++++--------------
 include/uapi/linux/userfaultfd.h         |  2 +-
 tools/testing/selftests/vm/userfaultfd.c |  2 +-
 3 files changed, 9 insertions(+), 16 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 387fe77..53de9e7 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -1062,7 +1062,8 @@ static __always_inline int validate_range(struct mm_struct *mm,
 
 static inline bool vma_can_userfault(struct vm_area_struct *vma)
 {
-	return vma_is_anonymous(vma) || is_vm_hugetlb_page(vma);
+	return vma_is_anonymous(vma) || is_vm_hugetlb_page(vma) ||
+		vma_is_shmem(vma);
 }
 
 static int userfaultfd_register(struct userfaultfd_ctx *ctx,
@@ -1075,7 +1076,7 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 	struct uffdio_register __user *user_uffdio_register;
 	unsigned long vm_flags, new_flags;
 	bool found;
-	bool huge_pages;
+	bool non_anon_pages;
 	unsigned long start, end, vma_end;
 
 	user_uffdio_register = (struct uffdio_register __user *) arg;
@@ -1139,13 +1140,9 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 
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
 
@@ -1184,8 +1181,8 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 		/*
 		 * Note vmas containing huge pages
 		 */
-		if (is_vm_hugetlb_page(cur))
-			huge_pages = true;
+		if (is_vm_hugetlb_page(cur) || vma_is_shmem(cur))
+			non_anon_pages = true;
 
 		found = true;
 	}
@@ -1256,7 +1253,7 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 		 * userland which ioctls methods are guaranteed to
 		 * succeed on this range.
 		 */
-		if (put_user(huge_pages ? UFFD_API_RANGE_IOCTLS_HPAGE :
+		if (put_user(non_anon_pages ? UFFD_API_RANGE_IOCTLS_BASIC :
 			     UFFD_API_RANGE_IOCTLS,
 			     &user_uffdio_register->ioctls))
 			ret = -EFAULT;
@@ -1316,10 +1313,6 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
 
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
index a3828a9..378dd27 100644
--- a/include/uapi/linux/userfaultfd.h
+++ b/include/uapi/linux/userfaultfd.h
@@ -29,7 +29,7 @@
 	((__u64)1 << _UFFDIO_WAKE |		\
 	 (__u64)1 << _UFFDIO_COPY |		\
 	 (__u64)1 << _UFFDIO_ZEROPAGE)
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
