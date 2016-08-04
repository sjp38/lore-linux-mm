Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id B30E26B025F
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 04:14:54 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id w128so442643664pfd.3
        for <linux-mm@kvack.org>; Thu, 04 Aug 2016 01:14:54 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id to7si13425424pac.282.2016.08.04.01.14.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Aug 2016 01:14:54 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u748Dqnj128541
	for <linux-mm@kvack.org>; Thu, 4 Aug 2016 04:14:52 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 24kkagqkx6-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 04 Aug 2016 04:14:52 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 4 Aug 2016 09:14:50 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (d06relay13.portsmouth.uk.ibm.com [9.149.109.198])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id A10E717D8066
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 09:16:24 +0100 (BST)
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u748EloO60686440
	for <linux-mm@kvack.org>; Thu, 4 Aug 2016 08:14:47 GMT
Received: from d06av03.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u748EljT019210
	for <linux-mm@kvack.org>; Thu, 4 Aug 2016 02:14:47 -0600
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 2/7] userfaultfd: shmem: add shmem_mcopy_atomic_pte for userfaultfd support
Date: Thu,  4 Aug 2016 11:14:13 +0300
In-Reply-To: <1470298458-9925-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1470298458-9925-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1470298458-9925-3-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

shmem_mcopy_atomic_pte is the low level routine that implements
the userfaultfd UFFDIO_COPY command.  It is based on the existing
mcopy_atomic_pte routine with modifications for shared memory pages.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 include/linux/shmem_fs.h |  11 +++++
 mm/shmem.c               | 109 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 120 insertions(+)

diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
index 4d4780c..8dcbdfd 100644
--- a/include/linux/shmem_fs.h
+++ b/include/linux/shmem_fs.h
@@ -83,4 +83,15 @@ static inline long shmem_fcntl(struct file *f, unsigned int c, unsigned long a)
 
 #endif
 
+#ifdef CONFIG_SHMEM
+extern int shmem_mcopy_atomic_pte(struct mm_struct *dst_mm, pmd_t *dst_pmd,
+				  struct vm_area_struct *dst_vma,
+				  unsigned long dst_addr,
+				  unsigned long src_addr,
+				  struct page **pagep);
+#else
+#define shmem_mcopy_atomic_pte(dst_mm, dst_pte, dst_vma, dst_addr, \
+			       src_addr, pagep)        ({ BUG(); 0; })
+#endif
+
 #endif
diff --git a/mm/shmem.c b/mm/shmem.c
index a361449..fcf560c 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -69,6 +69,7 @@ static struct vfsmount *shm_mnt;
 #include <linux/syscalls.h>
 #include <linux/fcntl.h>
 #include <uapi/linux/memfd.h>
+#include <linux/rmap.h>
 
 #include <asm/uaccess.h>
 #include <asm/pgtable.h>
@@ -1548,6 +1549,114 @@ bool shmem_mapping(struct address_space *mapping)
 	return mapping->host->i_sb->s_op == &shmem_ops;
 }
 
+int shmem_mcopy_atomic_pte(struct mm_struct *dst_mm,
+			   pmd_t *dst_pmd,
+			   struct vm_area_struct *dst_vma,
+			   unsigned long dst_addr,
+			   unsigned long src_addr,
+			   struct page **pagep)
+{
+	struct inode *inode = file_inode(dst_vma->vm_file);
+	struct shmem_inode_info *info = SHMEM_I(inode);
+	struct shmem_sb_info *sbinfo = SHMEM_SB(inode->i_sb);
+	struct address_space *mapping = inode->i_mapping;
+	gfp_t gfp = mapping_gfp_mask(mapping);
+	pgoff_t pgoff = linear_page_index(dst_vma, dst_addr);
+	struct mem_cgroup *memcg;
+	spinlock_t *ptl;
+	void *page_kaddr;
+	struct page *page;
+	pte_t _dst_pte, *dst_pte;
+	int ret;
+
+	if (!*pagep) {
+		ret = -ENOMEM;
+		if (shmem_acct_block(info->flags))
+			goto out;
+		if (sbinfo->max_blocks) {
+			if (percpu_counter_compare(&sbinfo->used_blocks,
+						   sbinfo->max_blocks) >= 0)
+				goto out_unacct_blocks;
+			percpu_counter_inc(&sbinfo->used_blocks);
+		}
+
+		page = shmem_alloc_page(gfp, info, pgoff);
+		if (!page)
+			goto out_dec_used_blocks;
+
+		page_kaddr = kmap_atomic(page);
+		ret = copy_from_user(page_kaddr, (const void __user *)src_addr,
+				     PAGE_SIZE);
+		kunmap_atomic(page_kaddr);
+
+		/* fallback to copy_from_user outside mmap_sem */
+		if (unlikely(ret)) {
+			*pagep = page;
+			/* don't free the page */
+			return -EFAULT;
+		}
+	} else {
+		page = *pagep;
+		*pagep = NULL;
+	}
+
+	_dst_pte = mk_pte(page, dst_vma->vm_page_prot);
+	if (dst_vma->vm_flags & VM_WRITE)
+		_dst_pte = pte_mkwrite(pte_mkdirty(_dst_pte));
+
+	ret = -EEXIST;
+	dst_pte = pte_offset_map_lock(dst_mm, dst_pmd, dst_addr, &ptl);
+	if (!pte_none(*dst_pte))
+		goto out_release_uncharge_unlock;
+
+	__SetPageUptodate(page);
+
+	ret = mem_cgroup_try_charge(page, dst_mm, gfp, &memcg,
+				    false);
+	if (ret)
+		goto out_release_uncharge_unlock;
+	ret = radix_tree_maybe_preload(gfp & GFP_RECLAIM_MASK);
+	if (!ret) {
+		ret = shmem_add_to_page_cache(page, mapping, pgoff, NULL);
+		radix_tree_preload_end();
+	}
+	if (ret) {
+		mem_cgroup_cancel_charge(page, memcg, false);
+		goto out_release_uncharge_unlock;
+	}
+
+	mem_cgroup_commit_charge(page, memcg, false, false);
+	lru_cache_add_anon(page);
+
+	spin_lock(&info->lock);
+	info->alloced++;
+	inode->i_blocks += BLOCKS_PER_PAGE;
+	shmem_recalc_inode(inode);
+	spin_unlock(&info->lock);
+
+	inc_mm_counter(dst_mm, mm_counter_file(page));
+	page_add_file_rmap(page);
+	set_pte_at(dst_mm, dst_addr, dst_pte, _dst_pte);
+
+	/* No need to invalidate - it was non-present before */
+	update_mmu_cache(dst_vma, dst_addr, dst_pte);
+	unlock_page(page);
+	pte_unmap_unlock(dst_pte, ptl);
+	ret = 0;
+out:
+	return ret;
+out_release_uncharge_unlock:
+	pte_unmap_unlock(dst_pte, ptl);
+	mem_cgroup_cancel_charge(page, memcg, false);
+	put_page(page);
+out_dec_used_blocks:
+	if (sbinfo->max_blocks)
+		percpu_counter_add(&sbinfo->used_blocks, -1);
+out_unacct_blocks:
+	shmem_unacct_blocks(info->flags, 1);
+	goto out;
+}
+
 #ifdef CONFIG_TMPFS
 static const struct inode_operations shmem_symlink_inode_operations;
 static const struct inode_operations shmem_short_symlink_operations;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
