Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3E8A16B42CA
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 12:34:58 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id b16so17025519qtc.22
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 09:34:58 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q15si796478qti.20.2018.11.26.09.34.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Nov 2018 09:34:57 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 4/5] userfaultfd: shmem: add i_size checks
Date: Mon, 26 Nov 2018 12:34:51 -0500
Message-Id: <20181126173452.26955-5-aarcange@redhat.com>
In-Reply-To: <20181126173452.26955-1-aarcange@redhat.com>
References: <20181126173452.26955-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mike Kravetz <mike.kravetz@oracle.com>, Jann Horn <jannh@google.com>, Peter Xu <peterx@redhat.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>

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
---
 mm/shmem.c       | 18 ++++++++++++++++--
 mm/userfaultfd.c | 26 ++++++++++++++++++++++++--
 2 files changed, 40 insertions(+), 4 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 353287412c25..c3ece7a51949 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2214,6 +2214,7 @@ static int shmem_mfill_atomic_pte(struct mm_struct *dst_mm,
 	struct page *page;
 	pte_t _dst_pte, *dst_pte;
 	int ret;
+	pgoff_t offset, max_off;
 
 	ret = -ENOMEM;
 	if (!shmem_inode_acct_block(inode, 1))
@@ -2251,6 +2252,12 @@ static int shmem_mfill_atomic_pte(struct mm_struct *dst_mm,
 	__SetPageSwapBacked(page);
 	__SetPageUptodate(page);
 
+	ret = -EFAULT;
+	offset = linear_page_index(dst_vma, dst_addr);
+	max_off = DIV_ROUND_UP(i_size_read(inode), PAGE_SIZE);
+	if (unlikely(offset >= max_off))
+		goto out_release;
+
 	ret = mem_cgroup_try_charge_delay(page, dst_mm, gfp, &memcg, false);
 	if (ret)
 		goto out_release;
@@ -2266,8 +2273,14 @@ static int shmem_mfill_atomic_pte(struct mm_struct *dst_mm,
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
 
@@ -2285,13 +2298,14 @@ static int shmem_mfill_atomic_pte(struct mm_struct *dst_mm,
 
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
index 43cf314cfddd..458acda96f20 100644
--- a/mm/userfaultfd.c
+++ b/mm/userfaultfd.c
@@ -33,6 +33,8 @@ static int mcopy_atomic_pte(struct mm_struct *dst_mm,
 	void *page_kaddr;
 	int ret;
 	struct page *page;
+	pgoff_t offset, max_off;
+	struct inode *inode;
 
 	if (!*pagep) {
 		ret = -ENOMEM;
@@ -73,8 +75,17 @@ static int mcopy_atomic_pte(struct mm_struct *dst_mm,
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
 
@@ -108,11 +119,22 @@ static int mfill_zeropage_pte(struct mm_struct *dst_mm,
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
