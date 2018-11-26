Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1B2636B42C9
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 12:34:58 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id c7so19848287qkg.16
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 09:34:58 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s80si776260qka.18.2018.11.26.09.34.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Nov 2018 09:34:56 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 1/5] userfaultfd: use ENOENT instead of EFAULT if the atomic copy user fails
Date: Mon, 26 Nov 2018 12:34:48 -0500
Message-Id: <20181126173452.26955-2-aarcange@redhat.com>
In-Reply-To: <20181126173452.26955-1-aarcange@redhat.com>
References: <20181126173452.26955-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mike Kravetz <mike.kravetz@oracle.com>, Jann Horn <jannh@google.com>, Peter Xu <peterx@redhat.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>

We internally used EFAULT to communicate with the caller, switch to
ENOENT, so EFAULT can be used as a non internal retval.

Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>
Reviewed-by: Hugh Dickins <hughd@google.com>
Cc: stable@vger.kernel.org
Fixes: 4c27fe4c4c84 ("userfaultfd: shmem: add shmem_mcopy_atomic_pte for userfaultfd support")
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/hugetlb.c     | 2 +-
 mm/shmem.c       | 2 +-
 mm/userfaultfd.c | 6 +++---
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 7f2a28ab46d5..705a3e9cc910 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -4080,7 +4080,7 @@ int hugetlb_mcopy_atomic_pte(struct mm_struct *dst_mm,
 
 		/* fallback to copy_from_user outside mmap_sem */
 		if (unlikely(ret)) {
-			ret = -EFAULT;
+			ret = -ENOENT;
 			*pagep = page;
 			/* don't free the page */
 			goto out;
diff --git a/mm/shmem.c b/mm/shmem.c
index d44991ea5ed4..353287412c25 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2236,7 +2236,7 @@ static int shmem_mfill_atomic_pte(struct mm_struct *dst_mm,
 				*pagep = page;
 				shmem_inode_unacct_blocks(inode, 1);
 				/* don't free the page */
-				return -EFAULT;
+				return -ENOENT;
 			}
 		} else {		/* mfill_zeropage_atomic */
 			clear_highpage(page);
diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
index 5029f241908f..46c8949e5f8f 100644
--- a/mm/userfaultfd.c
+++ b/mm/userfaultfd.c
@@ -48,7 +48,7 @@ static int mcopy_atomic_pte(struct mm_struct *dst_mm,
 
 		/* fallback to copy_from_user outside mmap_sem */
 		if (unlikely(ret)) {
-			ret = -EFAULT;
+			ret = -ENOENT;
 			*pagep = page;
 			/* don't free the page */
 			goto out;
@@ -274,7 +274,7 @@ static __always_inline ssize_t __mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
 
 		cond_resched();
 
-		if (unlikely(err == -EFAULT)) {
+		if (unlikely(err == -ENOENT)) {
 			up_read(&dst_mm->mmap_sem);
 			BUG_ON(!page);
 
@@ -530,7 +530,7 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
 				       src_addr, &page, zeropage);
 		cond_resched();
 
-		if (unlikely(err == -EFAULT)) {
+		if (unlikely(err == -ENOENT)) {
 			void *page_kaddr;
 
 			up_read(&dst_mm->mmap_sem);
