Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id AA6D86B02B1
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 15:34:12 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id h201so24505673qke.7
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 12:34:12 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t29si1915337qkl.236.2016.11.02.12.34.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Nov 2016 12:34:11 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 24/33] userfaultfd: shmem: use shmem_mcopy_atomic_pte for shared memory
Date: Wed,  2 Nov 2016 20:33:56 +0100
Message-Id: <1478115245-32090-25-git-send-email-aarcange@redhat.com>
In-Reply-To: <1478115245-32090-1-git-send-email-aarcange@redhat.com>
References: <1478115245-32090-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert"@v2.random, " <dgilbert@redhat.com>,  Mike Kravetz <mike.kravetz@oracle.com>,  Shaohua Li <shli@fb.com>,  Pavel Emelyanov <xemul@parallels.com>"@v2.random

From: Mike Rapoport <rppt@linux.vnet.ibm.com>

The shmem_mcopy_atomic_pte implements low lever part of UFFDIO_COPY
operation for shared memory VMAs. It's based on mcopy_atomic_pte with
adjustments necessary for shared memory pages.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/userfaultfd.c | 31 ++++++++++++++++++-------------
 1 file changed, 18 insertions(+), 13 deletions(-)

diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
index ba9adff..7b27d1e 100644
--- a/mm/userfaultfd.c
+++ b/mm/userfaultfd.c
@@ -16,6 +16,7 @@
 #include <linux/mmu_notifier.h>
 #include <linux/hugetlb.h>
 #include <linux/pagemap.h>
+#include <linux/shmem_fs.h>
 #include <asm/tlbflush.h>
 #include "internal.h"
 
@@ -348,7 +349,9 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
 	 */
 	err = -EINVAL;
 	dst_vma = find_vma(dst_mm, dst_start);
-	if (!dst_vma || (dst_vma->vm_flags & VM_SHARED))
+	if (!dst_vma)
+		goto out_unlock;
+	if (!vma_is_shmem(dst_vma) && dst_vma->vm_flags & VM_SHARED)
 		goto out_unlock;
 	if (dst_start < dst_vma->vm_start ||
 	    dst_start + len > dst_vma->vm_end)
@@ -373,11 +376,7 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
 	if (!dst_vma->vm_userfaultfd_ctx.ctx)
 		goto out_unlock;
 
-	/*
-	 * FIXME: only allow copying on anonymous vmas, tmpfs should
-	 * be added.
-	 */
-	if (!vma_is_anonymous(dst_vma))
+	if (!vma_is_anonymous(dst_vma) && !vma_is_shmem(dst_vma))
 		goto out_unlock;
 
 	/*
@@ -386,7 +385,7 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
 	 * dst_vma.
 	 */
 	err = -ENOMEM;
-	if (unlikely(anon_vma_prepare(dst_vma)))
+	if (vma_is_anonymous(dst_vma) && unlikely(anon_vma_prepare(dst_vma)))
 		goto out_unlock;
 
 	while (src_addr < src_start + len) {
@@ -423,12 +422,18 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
 		BUG_ON(pmd_none(*dst_pmd));
 		BUG_ON(pmd_trans_huge(*dst_pmd));
 
-		if (!zeropage)
-			err = mcopy_atomic_pte(dst_mm, dst_pmd, dst_vma,
-					       dst_addr, src_addr, &page);
-		else
-			err = mfill_zeropage_pte(dst_mm, dst_pmd, dst_vma,
-						 dst_addr);
+		if (vma_is_anonymous(dst_vma)) {
+			if (!zeropage)
+				err = mcopy_atomic_pte(dst_mm, dst_pmd, dst_vma,
+						       dst_addr, src_addr,
+						       &page);
+			else
+				err = mfill_zeropage_pte(dst_mm, dst_pmd,
+							 dst_vma, dst_addr);
+		} else {
+			err = shmem_mcopy_atomic_pte(dst_mm, dst_pmd, dst_vma,
+						     dst_addr, src_addr, &page);
+		}
 
 		cond_resched();
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
