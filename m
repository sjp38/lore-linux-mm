Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id B9C446B42CB
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 12:34:59 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id v64so20113795qka.5
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 09:34:59 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 36si531307qta.249.2018.11.26.09.34.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Nov 2018 09:34:58 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 3/5] userfaultfd: shmem/hugetlbfs: only allow to register VM_MAYWRITE vmas
Date: Mon, 26 Nov 2018 12:34:50 -0500
Message-Id: <20181126173452.26955-4-aarcange@redhat.com>
In-Reply-To: <20181126173452.26955-1-aarcange@redhat.com>
References: <20181126173452.26955-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mike Kravetz <mike.kravetz@oracle.com>, Jann Horn <jannh@google.com>, Peter Xu <peterx@redhat.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>

After the VMA to register the uffd onto is found, check that it has
VM_MAYWRITE set before allowing registration. This way we inherit all
common code checks before allowing to fill file holes in shmem and
hugetlbfs with UFFDIO_COPY.

The userfaultfd memory model is not applicable for readonly files
unless it's a MAP_PRIVATE.

Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>
Reviewed-by: Hugh Dickins <hughd@google.com>
Reported-by: Jann Horn <jannh@google.com>
Fixes: 4c27fe4c4c84 ("userfaultfd: shmem: add shmem_mcopy_atomic_pte for userfaultfd support")
Fixes: ff62a3421044 ("hugetlb: implement memfd sealing")
Cc: stable@vger.kernel.org
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 fs/userfaultfd.c | 15 +++++++++++++++
 mm/userfaultfd.c | 15 ++++++---------
 2 files changed, 21 insertions(+), 9 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 356d2b8568c1..cd58939dc977 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -1361,6 +1361,19 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 		ret = -EINVAL;
 		if (!vma_can_userfault(cur))
 			goto out_unlock;
+
+		/*
+		 * UFFDIO_COPY will fill file holes even without
+		 * PROT_WRITE. This check enforces that if this is a
+		 * MAP_SHARED, the process has write permission to the backing
+		 * file. If VM_MAYWRITE is set it also enforces that on a
+		 * MAP_SHARED vma: there is no F_WRITE_SEAL and no further
+		 * F_WRITE_SEAL can be taken until the vma is destroyed.
+		 */
+		ret = -EPERM;
+		if (unlikely(!(cur->vm_flags & VM_MAYWRITE)))
+			goto out_unlock;
+
 		/*
 		 * If this vma contains ending address, and huge pages
 		 * check alignment.
@@ -1406,6 +1419,7 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 		BUG_ON(!vma_can_userfault(vma));
 		BUG_ON(vma->vm_userfaultfd_ctx.ctx &&
 		       vma->vm_userfaultfd_ctx.ctx != ctx);
+		WARN_ON(!(vma->vm_flags & VM_MAYWRITE));
 
 		/*
 		 * Nothing to do: this vma is already registered into this
@@ -1552,6 +1566,7 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
 		cond_resched();
 
 		BUG_ON(!vma_can_userfault(vma));
+		WARN_ON(!(vma->vm_flags & VM_MAYWRITE));
 
 		/*
 		 * Nothing to do: this vma is already registered into this
diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
index 471b6457f95f..43cf314cfddd 100644
--- a/mm/userfaultfd.c
+++ b/mm/userfaultfd.c
@@ -205,8 +205,9 @@ static __always_inline ssize_t __mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
 		if (!dst_vma || !is_vm_hugetlb_page(dst_vma))
 			goto out_unlock;
 		/*
-		 * Only allow __mcopy_atomic_hugetlb on userfaultfd
-		 * registered ranges.
+		 * Check the vma is registered in uffd, this is
+		 * required to enforce the VM_MAYWRITE check done at
+		 * uffd registration time.
 		 */
 		if (!dst_vma->vm_userfaultfd_ctx.ctx)
 			goto out_unlock;
@@ -459,13 +460,9 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
 	if (!dst_vma)
 		goto out_unlock;
 	/*
-	 * Be strict and only allow __mcopy_atomic on userfaultfd
-	 * registered ranges to prevent userland errors going
-	 * unnoticed. As far as the VM consistency is concerned, it
-	 * would be perfectly safe to remove this check, but there's
-	 * no useful usage for __mcopy_atomic ouside of userfaultfd
-	 * registered ranges. This is after all why these are ioctls
-	 * belonging to the userfaultfd and not syscalls.
+	 * Check the vma is registered in uffd, this is required to
+	 * enforce the VM_MAYWRITE check done at uffd registration
+	 * time.
 	 */
 	if (!dst_vma->vm_userfaultfd_ctx.ctx)
 		goto out_unlock;
