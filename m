Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id D453E6B473A
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 05:00:57 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id y2so23545680plr.8
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 02:00:57 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id i16si3419973pgk.445.2018.11.27.02.00.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Nov 2018 02:00:56 -0800 (PST)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wAR9wtxl117547
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 05:00:55 -0500
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2p12cybv6e-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 05:00:54 -0500
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Tue, 27 Nov 2018 10:00:52 -0000
Date: Tue, 27 Nov 2018 12:00:45 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: Re: [PATCH 4/5] userfaultfd: shmem: add i_size checks
References: <20181126173452.26955-5-aarcange@redhat.com>
 <20181127065733.83FBA208E4@mail.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181127065733.83FBA208E4@mail.kernel.org>
Message-Id: <20181127100044.GA16502@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sashal@kernel.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

Hi,

On Tue, Nov 27, 2018 at 06:57:32AM +0000, Sasha Levin wrote:
> Hi,
> 
> [This is an automated email]
> 
> This commit has been processed because it contains a "Fixes:" tag,
> fixing commit: 4c27fe4c4c84 userfaultfd: shmem: add shmem_mcopy_atomic_pte for userfaultfd support.
> 
> The bot has tested the following trees: v4.19.4, v4.14.83, 
> 
> v4.19.4: Build OK!
> v4.14.83: Failed to apply! Possible dependencies:
>     2a70f6a76bb8 ("memcg, thp: do not invoke oom killer on thp charges")
>     2cf855837b89 ("memcontrol: schedule throttling if we are congested")
> 
> 
> How should we proceed with this patch?

Below is the same patch backported to 4.14.83. With it the patch 5/5 in the
series applies cleanly.

>From 89135f0df0323f38c0b036c87688f5a7e3cfa9e9 Mon Sep 17 00:00:00 2001
From: Andrea Arcangeli <aarcange@redhat.com>
Date: Mon, 26 Nov 2018 12:34:51 -0500
Subject: [PATCH v4.14.83] userfaultfd: shmem: add i_size checks

With MAP_SHARED: recheck the i_size after taking the PT lock, to
serialize against truncate with the PT lock. Delete the page from the
pagecache if the i_size_read check fails.

With MAP_PRIVATE: check the i_size after the PT lock before mapping
anonymous memory or zeropages into the MAP_PRIVATE shmem mapping.

A mostly irrelevant cleanup: like we do the delete_from_page_cache()
pagecache removal after dropping the PT lock, the PT lock is a
spinlock so drop it before the sleepable page lock.

Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>
Reviewed-by: Hugh Dickins <hughd@google.com>
Reported-by: Jann Horn <jannh@google.com>
Fixes: 4c27fe4c4c84 ("userfaultfd: shmem: add shmem_mcopy_atomic_pte for userfaultfd support")
Cc: stable@vger.kernel.org
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 mm/shmem.c       | 18 ++++++++++++++++--
 mm/userfaultfd.c | 26 ++++++++++++++++++++++++--
 2 files changed, 40 insertions(+), 4 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 8019118..70b9fb9 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2238,6 +2238,7 @@ static int shmem_mfill_atomic_pte(struct mm_struct *dst_mm,
 	struct page *page;
 	pte_t _dst_pte, *dst_pte;
 	int ret;
+	pgoff_t offset, max_off;
 
 	ret = -ENOMEM;
 	if (!shmem_inode_acct_block(inode, 1))
@@ -2275,6 +2276,12 @@ static int shmem_mfill_atomic_pte(struct mm_struct *dst_mm,
 	__SetPageSwapBacked(page);
 	__SetPageUptodate(page);
 
+	ret = -EFAULT;
+	offset = linear_page_index(dst_vma, dst_addr);
+	max_off = DIV_ROUND_UP(i_size_read(inode), PAGE_SIZE);
+	if (unlikely(offset >= max_off))
+		goto out_release;
+
 	ret = mem_cgroup_try_charge(page, dst_mm, gfp, &memcg, false);
 	if (ret)
 		goto out_release;
@@ -2293,8 +2300,14 @@ static int shmem_mfill_atomic_pte(struct mm_struct *dst_mm,
 	if (dst_vma->vm_flags & VM_WRITE)
 		_dst_pte = pte_mkwrite(pte_mkdirty(_dst_pte));
 
-	ret = -EEXIST;
 	dst_pte = pte_offset_map_lock(dst_mm, dst_pmd, dst_addr, &ptl);
+
+	ret = -EFAULT;
+	max_off = DIV_ROUND_UP(i_size_read(inode), PAGE_SIZE);
+	if (unlikely(offset >= max_off))
+		goto out_release_uncharge_unlock;
+
+	ret = -EEXIST;
 	if (!pte_none(*dst_pte))
 		goto out_release_uncharge_unlock;
 
@@ -2312,13 +2325,14 @@ static int shmem_mfill_atomic_pte(struct mm_struct *dst_mm,
 
 	/* No need to invalidate - it was non-present before */
 	update_mmu_cache(dst_vma, dst_addr, dst_pte);
-	unlock_page(page);
 	pte_unmap_unlock(dst_pte, ptl);
+	unlock_page(page);
 	ret = 0;
 out:
 	return ret;
 out_release_uncharge_unlock:
 	pte_unmap_unlock(dst_pte, ptl);
+	delete_from_page_cache(page);
 out_release_uncharge:
 	mem_cgroup_cancel_charge(page, memcg, false);
 out_release:
diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
index 5dbfcac0..5d70fdb 100644
--- a/mm/userfaultfd.c
+++ b/mm/userfaultfd.c
@@ -34,6 +34,8 @@ static int mcopy_atomic_pte(struct mm_struct *dst_mm,
 	void *page_kaddr;
 	int ret;
 	struct page *page;
+	pgoff_t offset, max_off;
+	struct inode *inode;
 
 	if (!*pagep) {
 		ret = -ENOMEM;
@@ -74,8 +76,17 @@ static int mcopy_atomic_pte(struct mm_struct *dst_mm,
 	if (dst_vma->vm_flags & VM_WRITE)
 		_dst_pte = pte_mkwrite(pte_mkdirty(_dst_pte));
 
-	ret = -EEXIST;
 	dst_pte = pte_offset_map_lock(dst_mm, dst_pmd, dst_addr, &ptl);
+	if (dst_vma->vm_file) {
+		/* the shmem MAP_PRIVATE case requires checking the i_size */
+		inode = dst_vma->vm_file->f_inode;
+		offset = linear_page_index(dst_vma, dst_addr);
+		max_off = DIV_ROUND_UP(i_size_read(inode), PAGE_SIZE);
+		ret = -EFAULT;
+		if (unlikely(offset >= max_off))
+			goto out_release_uncharge_unlock;
+	}
+	ret = -EEXIST;
 	if (!pte_none(*dst_pte))
 		goto out_release_uncharge_unlock;
 
@@ -109,11 +120,22 @@ static int mfill_zeropage_pte(struct mm_struct *dst_mm,
 	pte_t _dst_pte, *dst_pte;
 	spinlock_t *ptl;
 	int ret;
+	pgoff_t offset, max_off;
+	struct inode *inode;
 
 	_dst_pte = pte_mkspecial(pfn_pte(my_zero_pfn(dst_addr),
 					 dst_vma->vm_page_prot));
-	ret = -EEXIST;
 	dst_pte = pte_offset_map_lock(dst_mm, dst_pmd, dst_addr, &ptl);
+	if (dst_vma->vm_file) {
+		/* the shmem MAP_PRIVATE case requires checking the i_size */
+		inode = dst_vma->vm_file->f_inode;
+		offset = linear_page_index(dst_vma, dst_addr);
+		max_off = DIV_ROUND_UP(i_size_read(inode), PAGE_SIZE);
+		ret = -EFAULT;
+		if (unlikely(offset >= max_off))
+			goto out_unlock;
+	}
+	ret = -EEXIST;
 	if (!pte_none(*dst_pte))
 		goto out_unlock;
 	set_pte_at(dst_mm, dst_addr, dst_pte, _dst_pte);
-- 
2.7.4

 
> --
> Thanks,
> Sasha
> 

-- 
Sincerely yours,
Mike.
