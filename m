Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 40F6A6B02C3
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 02:21:09 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id g6so1680240wmc.8
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 23:21:09 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id s71si8807692wma.14.2017.06.19.23.21.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Jun 2017 23:21:07 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5K6ImC8140369
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 02:21:06 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2b6kusq5yb-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 02:21:06 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 20 Jun 2017 07:21:04 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 2/7] shmem: introduce shmem_inode_acct_block
Date: Tue, 20 Jun 2017 09:20:47 +0300
In-Reply-To: <1497939652-16528-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1497939652-16528-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1497939652-16528-3-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

The shmem_acct_block and the update of used_blocks are following one
another in all the places they are used. Combine these two into a helper
function.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 mm/shmem.c | 102 ++++++++++++++++++++++++++++---------------------------------
 1 file changed, 46 insertions(+), 56 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 40a43ae..a92e3d7 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -187,6 +187,38 @@ static inline void shmem_unacct_blocks(unsigned long flags, long pages)
 		vm_unacct_memory(pages * VM_ACCT(PAGE_SIZE));
 }
 
+static inline bool shmem_inode_acct_block(struct inode *inode, long pages)
+{
+	struct shmem_inode_info *info = SHMEM_I(inode);
+	struct shmem_sb_info *sbinfo = SHMEM_SB(inode->i_sb);
+
+	if (shmem_acct_block(info->flags, pages))
+		return false;
+
+	if (sbinfo->max_blocks) {
+		if (percpu_counter_compare(&sbinfo->used_blocks,
+					   sbinfo->max_blocks - pages) > 0)
+			goto unacct;
+		percpu_counter_add(&sbinfo->used_blocks, pages);
+	}
+
+	return true;
+
+unacct:
+	shmem_unacct_blocks(info->flags, pages);
+	return false;
+}
+
+static inline void shmem_inode_unacct_blocks(struct inode *inode, long pages)
+{
+	struct shmem_inode_info *info = SHMEM_I(inode);
+	struct shmem_sb_info *sbinfo = SHMEM_SB(inode->i_sb);
+
+	if (sbinfo->max_blocks)
+		percpu_counter_sub(&sbinfo->used_blocks, pages);
+	shmem_unacct_blocks(info->flags, pages);
+}
+
 static const struct super_operations shmem_ops;
 static const struct address_space_operations shmem_aops;
 static const struct file_operations shmem_file_operations;
@@ -248,31 +280,20 @@ static void shmem_recalc_inode(struct inode *inode)
 
 	freed = info->alloced - info->swapped - inode->i_mapping->nrpages;
 	if (freed > 0) {
-		struct shmem_sb_info *sbinfo = SHMEM_SB(inode->i_sb);
-		if (sbinfo->max_blocks)
-			percpu_counter_add(&sbinfo->used_blocks, -freed);
 		info->alloced -= freed;
 		inode->i_blocks -= freed * BLOCKS_PER_PAGE;
-		shmem_unacct_blocks(info->flags, freed);
+		shmem_inode_unacct_blocks(inode, freed);
 	}
 }
 
 bool shmem_charge(struct inode *inode, long pages)
 {
 	struct shmem_inode_info *info = SHMEM_I(inode);
-	struct shmem_sb_info *sbinfo = SHMEM_SB(inode->i_sb);
 	unsigned long flags;
 
-	if (shmem_acct_block(info->flags, pages))
+	if (!shmem_inode_acct_block(inode, pages))
 		return false;
 
-	if (sbinfo->max_blocks) {
-		if (percpu_counter_compare(&sbinfo->used_blocks,
-					   sbinfo->max_blocks - pages) > 0)
-			goto unacct;
-		percpu_counter_add(&sbinfo->used_blocks, pages);
-	}
-
 	spin_lock_irqsave(&info->lock, flags);
 	info->alloced += pages;
 	inode->i_blocks += pages * BLOCKS_PER_PAGE;
@@ -281,16 +302,11 @@ bool shmem_charge(struct inode *inode, long pages)
 	inode->i_mapping->nrpages += pages;
 
 	return true;
-
-unacct:
-	shmem_unacct_blocks(info->flags, pages);
-	return false;
 }
 
 void shmem_uncharge(struct inode *inode, long pages)
 {
 	struct shmem_inode_info *info = SHMEM_I(inode);
-	struct shmem_sb_info *sbinfo = SHMEM_SB(inode->i_sb);
 	unsigned long flags;
 
 	spin_lock_irqsave(&info->lock, flags);
@@ -299,9 +315,7 @@ void shmem_uncharge(struct inode *inode, long pages)
 	shmem_recalc_inode(inode);
 	spin_unlock_irqrestore(&info->lock, flags);
 
-	if (sbinfo->max_blocks)
-		percpu_counter_sub(&sbinfo->used_blocks, pages);
-	shmem_unacct_blocks(info->flags, pages);
+	shmem_inode_unacct_blocks(inode, pages);
 }
 
 /*
@@ -1446,9 +1460,10 @@ static struct page *shmem_alloc_page(gfp_t gfp,
 }
 
 static struct page *shmem_alloc_and_acct_page(gfp_t gfp,
-		struct shmem_inode_info *info, struct shmem_sb_info *sbinfo,
+		struct inode *inode,
 		pgoff_t index, bool huge)
 {
+	struct shmem_inode_info *info = SHMEM_I(inode);
 	struct page *page;
 	int nr;
 	int err = -ENOSPC;
@@ -1457,14 +1472,8 @@ static struct page *shmem_alloc_and_acct_page(gfp_t gfp,
 		huge = false;
 	nr = huge ? HPAGE_PMD_NR : 1;
 
-	if (shmem_acct_block(info->flags, nr))
+	if (!shmem_inode_acct_block(inode, nr))
 		goto failed;
-	if (sbinfo->max_blocks) {
-		if (percpu_counter_compare(&sbinfo->used_blocks,
-					sbinfo->max_blocks - nr) > 0)
-			goto unacct;
-		percpu_counter_add(&sbinfo->used_blocks, nr);
-	}
 
 	if (huge)
 		page = shmem_alloc_hugepage(gfp, info, index);
@@ -1477,10 +1486,7 @@ static struct page *shmem_alloc_and_acct_page(gfp_t gfp,
 	}
 
 	err = -ENOMEM;
-	if (sbinfo->max_blocks)
-		percpu_counter_add(&sbinfo->used_blocks, -nr);
-unacct:
-	shmem_unacct_blocks(info->flags, nr);
+	shmem_inode_unacct_blocks(inode, nr);
 failed:
 	return ERR_PTR(err);
 }
@@ -1746,10 +1752,9 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 		}
 
 alloc_huge:
-		page = shmem_alloc_and_acct_page(gfp, info, sbinfo,
-				index, true);
+		page = shmem_alloc_and_acct_page(gfp, inode, index, true);
 		if (IS_ERR(page)) {
-alloc_nohuge:		page = shmem_alloc_and_acct_page(gfp, info, sbinfo,
+alloc_nohuge:		page = shmem_alloc_and_acct_page(gfp, inode,
 					index, false);
 		}
 		if (IS_ERR(page)) {
@@ -1867,10 +1872,7 @@ alloc_nohuge:		page = shmem_alloc_and_acct_page(gfp, info, sbinfo,
 	 * Error recovery.
 	 */
 unacct:
-	if (sbinfo->max_blocks)
-		percpu_counter_sub(&sbinfo->used_blocks,
-				1 << compound_order(page));
-	shmem_unacct_blocks(info->flags, 1 << compound_order(page));
+	shmem_inode_unacct_blocks(inode, 1 << compound_order(page));
 
 	if (PageTransHuge(page)) {
 		unlock_page(page);
@@ -2204,7 +2206,6 @@ int shmem_mcopy_atomic_pte(struct mm_struct *dst_mm,
 {
 	struct inode *inode = file_inode(dst_vma->vm_file);
 	struct shmem_inode_info *info = SHMEM_I(inode);
-	struct shmem_sb_info *sbinfo = SHMEM_SB(inode->i_sb);
 	struct address_space *mapping = inode->i_mapping;
 	gfp_t gfp = mapping_gfp_mask(mapping);
 	pgoff_t pgoff = linear_page_index(dst_vma, dst_addr);
@@ -2216,19 +2217,13 @@ int shmem_mcopy_atomic_pte(struct mm_struct *dst_mm,
 	int ret;
 
 	ret = -ENOMEM;
-	if (shmem_acct_block(info->flags, 1))
+	if (!shmem_inode_acct_block(inode, 1))
 		goto out;
-	if (sbinfo->max_blocks) {
-		if (percpu_counter_compare(&sbinfo->used_blocks,
-					   sbinfo->max_blocks) >= 0)
-			goto out_unacct_blocks;
-		percpu_counter_inc(&sbinfo->used_blocks);
-	}
 
 	if (!*pagep) {
 		page = shmem_alloc_page(gfp, info, pgoff);
 		if (!page)
-			goto out_dec_used_blocks;
+			goto out_unacct_blocks;
 
 		page_kaddr = kmap_atomic(page);
 		ret = copy_from_user(page_kaddr, (const void __user *)src_addr,
@@ -2238,9 +2233,7 @@ int shmem_mcopy_atomic_pte(struct mm_struct *dst_mm,
 		/* fallback to copy_from_user outside mmap_sem */
 		if (unlikely(ret)) {
 			*pagep = page;
-			if (sbinfo->max_blocks)
-				percpu_counter_add(&sbinfo->used_blocks, -1);
-			shmem_unacct_blocks(info->flags, 1);
+			shmem_inode_unacct_blocks(inode, 1);
 			/* don't free the page */
 			return -EFAULT;
 		}
@@ -2303,11 +2296,8 @@ int shmem_mcopy_atomic_pte(struct mm_struct *dst_mm,
 out_release:
 	unlock_page(page);
 	put_page(page);
-out_dec_used_blocks:
-	if (sbinfo->max_blocks)
-		percpu_counter_add(&sbinfo->used_blocks, -1);
 out_unacct_blocks:
-	shmem_unacct_blocks(info->flags, 1);
+	shmem_inode_unacct_blocks(inode, 1);
 	goto out;
 }
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
