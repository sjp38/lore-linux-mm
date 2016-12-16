Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id E84E26B0270
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 09:48:28 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id f73so92506951ioe.1
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 06:48:28 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u29si6178146iou.165.2016.12.16.06.48.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 06:48:28 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 28/42] userfaultfd: shmem: add shmem_mcopy_atomic_pte for userfaultfd support
Date: Fri, 16 Dec 2016 15:48:07 +0100
Message-Id: <20161216144821.5183-29-aarcange@redhat.com>
In-Reply-To: <20161216144821.5183-1-aarcange@redhat.com>
References: <20161216144821.5183-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@parallels.com>, Hillf Danton <hillf.zj@alibaba-inc.com>

From: Mike Rapoport <rppt@linux.vnet.ibm.com>

shmem_mcopy_atomic_pte is the low level routine that implements
the userfaultfd UFFDIO_COPY command.  It is based on the existing
mcopy_atomic_pte routine with modifications for shared memory pages.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/shmem_fs.h |  11 +++++
 mm/shmem.c               | 110 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 121 insertions(+)

diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
index ff078e7..fdaac9d4 100644
--- a/include/linux/shmem_fs.h
+++ b/include/linux/shmem_fs.h
@@ -124,4 +124,15 @@ static inline bool shmem_huge_enabled(struct vm_area_struct *vma)
 }
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
index 54287d44..11b24a8 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -70,6 +70,7 @@ static struct vfsmount *shm_mnt;
 #include <linux/syscalls.h>
 #include <linux/fcntl.h>
 #include <uapi/linux/memfd.h>
+#include <linux/rmap.h>
 
 #include <asm/uaccess.h>
 #include <asm/pgtable.h>
@@ -2174,6 +2175,115 @@ bool shmem_mapping(struct address_space *mapping)
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
+		if (shmem_acct_block(info->flags, 1))
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
+	ret = mem_cgroup_try_charge(page, dst_mm, gfp, &memcg, false);
+	if (ret)
+		goto out_release;
+
+	ret = radix_tree_maybe_preload(gfp & GFP_RECLAIM_MASK);
+	if (!ret) {
+		ret = shmem_add_to_page_cache(page, mapping, pgoff, NULL);
+		radix_tree_preload_end();
+	}
+	if (ret)
+		goto out_release_uncharge;
+
+	mem_cgroup_commit_charge(page, memcg, false, false);
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
+	lru_cache_add_anon(page);
+
+	spin_lock(&info->lock);
+	info->alloced++;
+	inode->i_blocks += BLOCKS_PER_PAGE;
+	shmem_recalc_inode(inode);
+	spin_unlock(&info->lock);
+
+	inc_mm_counter(dst_mm, mm_counter_file(page));
+	page_add_file_rmap(page, false);
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
+out_release_uncharge:
+	mem_cgroup_cancel_charge(page, memcg, false);
+out_release:
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
