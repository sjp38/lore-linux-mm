Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id BA2376B0273
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 08:53:14 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id c73so240423938pfb.7
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 05:53:14 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id t125si19235643pgb.150.2017.01.24.05.53.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jan 2017 05:53:13 -0800 (PST)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0ODi2ul009544
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 08:53:12 -0500
Received: from e06smtp06.uk.ibm.com (e06smtp06.uk.ibm.com [195.75.94.102])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2865sj6hfg-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 08:53:12 -0500
Received: from localhost
	by e06smtp06.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 24 Jan 2017 13:53:10 -0000
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [RFC PATCH 4/5] userfaultfd: mcopy_atomic: return -ENOENT when no compatible VMA found
Date: Tue, 24 Jan 2017 15:52:02 +0200
In-Reply-To: <1485265923-20256-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1485265923-20256-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1485265923-20256-5-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@virtuozzo.com>, LKML <linux-kernel@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

The memory mapping of a process may change between #PF event and the call
to mcopy_atomic that comes to resolve the page fault. In such case, there
will be no VMA covering the range passed to mcopy_atomic or the VMA will
not have userfaultfd context.
To allow uffd monitor to distinguish those case from other errors, let's
return -ENOENT instead of -EINVAL.

Note, that despite availability of UFFD_EVENT_UNMAP there still might be
race between the processing of UFFD_EVENT_UNMAP and outstanding
mcopy_atomic in case of non-cooperative uffd usage.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 mm/userfaultfd.c | 42 ++++++++++++++++++++++--------------------
 1 file changed, 22 insertions(+), 20 deletions(-)

diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
index a0817cc..b861cf9 100644
--- a/mm/userfaultfd.c
+++ b/mm/userfaultfd.c
@@ -195,11 +195,18 @@ static __always_inline ssize_t __mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
 	 * retry, dst_vma will be set to NULL and we must lookup again.
 	 */
 	if (!dst_vma) {
-		err = -EINVAL;
+		err = -ENOENT;
 		dst_vma = find_vma(dst_mm, dst_start);
 		if (!dst_vma || !is_vm_hugetlb_page(dst_vma))
 			goto out_unlock;
+		/*
+		 * Only allow __mcopy_atomic_hugetlb on userfaultfd
+		 * registered ranges.
+		 */
+		if (!dst_vma->vm_userfaultfd_ctx.ctx)
+			goto out_unlock;
 
+		err = -EINVAL;
 		if (vma_hpagesize != vma_kernel_pagesize(dst_vma))
 			goto out_unlock;
 
@@ -219,12 +226,6 @@ static __always_inline ssize_t __mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
 		goto out_unlock;
 
 	/*
-	 * Only allow __mcopy_atomic_hugetlb on userfaultfd registered ranges.
-	 */
-	if (!dst_vma->vm_userfaultfd_ctx.ctx)
-		goto out_unlock;
-
-	/*
 	 * Ensure the dst_vma has a anon_vma.
 	 */
 	err = -ENOMEM;
@@ -368,10 +369,23 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
 	 * Make sure the vma is not shared, that the dst range is
 	 * both valid and fully within a single existing vma.
 	 */
-	err = -EINVAL;
+	err = -ENOENT;
 	dst_vma = find_vma(dst_mm, dst_start);
 	if (!dst_vma)
 		goto out_unlock;
+	/*
+	 * Be strict and only allow __mcopy_atomic on userfaultfd
+	 * registered ranges to prevent userland errors going
+	 * unnoticed. As far as the VM consistency is concerned, it
+	 * would be perfectly safe to remove this check, but there's
+	 * no useful usage for __mcopy_atomic ouside of userfaultfd
+	 * registered ranges. This is after all why these are ioctls
+	 * belonging to the userfaultfd and not syscalls.
+	 */
+	if (!dst_vma->vm_userfaultfd_ctx.ctx)
+		goto out_unlock;
+
+	err = -EINVAL;
 	if (!vma_is_shmem(dst_vma) && dst_vma->vm_flags & VM_SHARED)
 		goto out_unlock;
 	if (dst_start < dst_vma->vm_start ||
@@ -385,18 +399,6 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
 		return  __mcopy_atomic_hugetlb(dst_mm, dst_vma, dst_start,
 						src_start, len, zeropage);
 
-	/*
-	 * Be strict and only allow __mcopy_atomic on userfaultfd
-	 * registered ranges to prevent userland errors going
-	 * unnoticed. As far as the VM consistency is concerned, it
-	 * would be perfectly safe to remove this check, but there's
-	 * no useful usage for __mcopy_atomic ouside of userfaultfd
-	 * registered ranges. This is after all why these are ioctls
-	 * belonging to the userfaultfd and not syscalls.
-	 */
-	if (!dst_vma->vm_userfaultfd_ctx.ctx)
-		goto out_unlock;
-
 	if (!vma_is_anonymous(dst_vma) && !vma_is_shmem(dst_vma))
 		goto out_unlock;
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
