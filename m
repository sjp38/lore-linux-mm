Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1E7446B0261
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 04:14:59 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id p85so128650877lfg.3
        for <linux-mm@kvack.org>; Thu, 04 Aug 2016 01:14:59 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id o198si2757327wmd.84.2016.08.04.01.14.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Aug 2016 01:14:57 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u748Dwx0065184
	for <linux-mm@kvack.org>; Thu, 4 Aug 2016 04:14:56 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0b-001b2d01.pphosted.com with ESMTP id 24kkamxv58-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 04 Aug 2016 04:14:56 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 4 Aug 2016 09:14:54 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 2DF691B08023
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 09:16:23 +0100 (BST)
Received: from d06av05.portsmouth.uk.ibm.com (d06av05.portsmouth.uk.ibm.com [9.149.37.229])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u748EqZg10420706
	for <linux-mm@kvack.org>; Thu, 4 Aug 2016 08:14:52 GMT
Received: from d06av05.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av05.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u748EqfG023991
	for <linux-mm@kvack.org>; Thu, 4 Aug 2016 02:14:52 -0600
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 4/7] userfaultfd: shmem: use shmem_mcopy_atomic_pte for shared memory
Date: Thu,  4 Aug 2016 11:14:15 +0300
In-Reply-To: <1470298458-9925-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1470298458-9925-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1470298458-9925-5-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

The shmem_mcopy_atomic_pte implements low lever part of UFFDIO_COPY
operation for shared memory VMAs. It's based on mcopy_atomic_pte with
adjustments necessary for shared memory pages.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 mm/userfaultfd.c | 31 ++++++++++++++++++-------------
 1 file changed, 18 insertions(+), 13 deletions(-)

diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
index ae4a976..d9259ba 100644
--- a/mm/userfaultfd.c
+++ b/mm/userfaultfd.c
@@ -16,6 +16,7 @@
 #include <linux/mmu_notifier.h>
 #include <linux/hugetlb.h>
 #include <linux/pagemap.h>
+#include <linux/shmem_fs.h>
 #include <asm/tlbflush.h>
 #include "internal.h"
 
@@ -348,7 +349,9 @@ retry:
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
@@ -373,11 +376,7 @@ retry:
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
@@ -386,7 +385,7 @@ retry:
 	 * dst_vma.
 	 */
 	err = -ENOMEM;
-	if (unlikely(anon_vma_prepare(dst_vma)))
+	if (vma_is_anonymous(dst_vma) && unlikely(anon_vma_prepare(dst_vma)))
 		goto out_unlock;
 
 	while (src_addr < src_start + len) {
@@ -423,12 +422,18 @@ retry:
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
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
