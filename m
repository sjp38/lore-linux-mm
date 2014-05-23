Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f50.google.com (mail-oa0-f50.google.com [209.85.219.50])
	by kanga.kvack.org (Postfix) with ESMTP id 24A296B003A
	for <linux-mm@kvack.org>; Thu, 22 May 2014 23:33:42 -0400 (EDT)
Received: by mail-oa0-f50.google.com with SMTP id i7so5033222oag.23
        for <linux-mm@kvack.org>; Thu, 22 May 2014 20:33:41 -0700 (PDT)
Received: from g4t3425.houston.hp.com (g4t3425.houston.hp.com. [15.201.208.53])
        by mx.google.com with ESMTPS id bg6si2170123oec.77.2014.05.22.20.33.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 22 May 2014 20:33:41 -0700 (PDT)
From: Davidlohr Bueso <davidlohr@hp.com>
Subject: [PATCH 2/5] mm: use new helper functions around the i_mmap_mutex
Date: Thu, 22 May 2014 20:33:23 -0700
Message-Id: <1400816006-3083-3-git-send-email-davidlohr@hp.com>
In-Reply-To: <1400816006-3083-1-git-send-email-davidlohr@hp.com>
References: <1400816006-3083-1-git-send-email-davidlohr@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mingo@kernel.org, peterz@infradead.org, riel@redhat.com, mgorman@suse.de, davidlohr@hp.com, aswin@hp.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Convert all open coded mutex_lock/unlock calls to the
i_mmap_[lock/unlock]_write() helpers.

Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
---
 fs/hugetlbfs/inode.c    |  4 ++--
 kernel/events/uprobes.c |  4 ++--
 kernel/fork.c           |  4 ++--
 mm/filemap_xip.c        |  4 ++--
 mm/hugetlb.c            | 12 ++++++------
 mm/memory-failure.c     |  4 ++--
 mm/memory.c             |  8 ++++----
 mm/mmap.c               | 14 +++++++-------
 mm/mremap.c             |  4 ++--
 mm/nommu.c              | 14 +++++++-------
 mm/rmap.c               |  4 ++--
 11 files changed, 38 insertions(+), 38 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 93fc531..bcaf4df 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -412,10 +412,10 @@ static int hugetlb_vmtruncate(struct inode *inode, loff_t offset)
 	pgoff = offset >> PAGE_SHIFT;
 
 	i_size_write(inode, offset);
-	mutex_lock(&mapping->i_mmap_mutex);
+	i_mmap_lock_write(mapping);
 	if (!RB_EMPTY_ROOT(&mapping->i_mmap))
 		hugetlb_vmtruncate_list(&mapping->i_mmap, pgoff);
-	mutex_unlock(&mapping->i_mmap_mutex);
+	i_mmap_unlock_write(mapping);
 	truncate_hugepages(inode, offset);
 	return 0;
 }
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 7716c40..ccf793c 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -722,7 +722,7 @@ build_map_info(struct address_space *mapping, loff_t offset, bool is_register)
 	int more = 0;
 
  again:
-	mutex_lock(&mapping->i_mmap_mutex);
+	i_mmap_lock_write(mapping);
 	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
 		if (!valid_vma(vma, is_register))
 			continue;
@@ -753,7 +753,7 @@ build_map_info(struct address_space *mapping, loff_t offset, bool is_register)
 		info->mm = vma->vm_mm;
 		info->vaddr = offset_to_vaddr(vma, offset);
 	}
-	mutex_unlock(&mapping->i_mmap_mutex);
+	i_mmap_unlock_write(mapping);
 
 	if (!more)
 		goto out;
diff --git a/kernel/fork.c b/kernel/fork.c
index d2799d1..76b1483 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -419,7 +419,7 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 			get_file(file);
 			if (tmp->vm_flags & VM_DENYWRITE)
 				atomic_dec(&inode->i_writecount);
-			mutex_lock(&mapping->i_mmap_mutex);
+			i_mmap_lock_write(mapping);
 			if (tmp->vm_flags & VM_SHARED)
 				mapping->i_mmap_writable++;
 			flush_dcache_mmap_lock(mapping);
@@ -431,7 +431,7 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 				vma_interval_tree_insert_after(tmp, mpnt,
 							&mapping->i_mmap);
 			flush_dcache_mmap_unlock(mapping);
-			mutex_unlock(&mapping->i_mmap_mutex);
+			i_mmap_unlock_write(mapping);
 		}
 
 		/*
diff --git a/mm/filemap_xip.c b/mm/filemap_xip.c
index d8d9fe3..bad746b 100644
--- a/mm/filemap_xip.c
+++ b/mm/filemap_xip.c
@@ -182,7 +182,7 @@ __xip_unmap (struct address_space * mapping,
 		return;
 
 retry:
-	mutex_lock(&mapping->i_mmap_mutex);
+	i_mmap_lock_write(mapping);
 	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
 		mm = vma->vm_mm;
 		address = vma->vm_start +
@@ -202,7 +202,7 @@ retry:
 			page_cache_release(page);
 		}
 	}
-	mutex_unlock(&mapping->i_mmap_mutex);
+	i_mmap_unlock_write(mapping);
 
 	if (locked) {
 		mutex_unlock(&xip_sparse_mutex);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 9519cde..161f98d 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2761,7 +2761,7 @@ static int unmap_ref_private(struct mm_struct *mm, struct vm_area_struct *vma,
 	 * this mapping should be shared between all the VMAs,
 	 * __unmap_hugepage_range() is called as the lock is already held
 	 */
-	mutex_lock(&mapping->i_mmap_mutex);
+	i_mmap_lock_write(mapping);
 	vma_interval_tree_foreach(iter_vma, &mapping->i_mmap, pgoff, pgoff) {
 		/* Do not unmap the current VMA */
 		if (iter_vma == vma)
@@ -2778,7 +2778,7 @@ static int unmap_ref_private(struct mm_struct *mm, struct vm_area_struct *vma,
 			unmap_hugepage_range(iter_vma, address,
 					     address + huge_page_size(h), page);
 	}
-	mutex_unlock(&mapping->i_mmap_mutex);
+	i_mmap_unlock_write(mapping);
 
 	return 1;
 }
@@ -3342,7 +3342,7 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 	flush_cache_range(vma, address, end);
 
 	mmu_notifier_invalidate_range_start(mm, start, end);
-	mutex_lock(&vma->vm_file->f_mapping->i_mmap_mutex);
+	i_mmap_lock_write(vma->vm_file->f_mapping);
 	for (; address < end; address += huge_page_size(h)) {
 		spinlock_t *ptl;
 		ptep = huge_pte_offset(mm, address);
@@ -3370,7 +3370,7 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 	 * and that page table be reused and filled with junk.
 	 */
 	flush_tlb_range(vma, start, end);
-	mutex_unlock(&vma->vm_file->f_mapping->i_mmap_mutex);
+	i_mmap_unlock_write(vma->vm_file->f_mapping);
 	mmu_notifier_invalidate_range_end(mm, start, end);
 
 	return pages << h->order;
@@ -3538,7 +3538,7 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
 	if (!vma_shareable(vma, addr))
 		return (pte_t *)pmd_alloc(mm, pud, addr);
 
-	mutex_lock(&mapping->i_mmap_mutex);
+	i_mmap_lock_write(mapping);
 	vma_interval_tree_foreach(svma, &mapping->i_mmap, idx, idx) {
 		if (svma == vma)
 			continue;
@@ -3566,7 +3566,7 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
 	spin_unlock(ptl);
 out:
 	pte = (pte_t *)pmd_alloc(mm, pud, addr);
-	mutex_unlock(&mapping->i_mmap_mutex);
+	i_mmap_unlock_write(mapping);
 	return pte;
 }
 
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index e3154d9..1389a28 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -434,7 +434,7 @@ static void collect_procs_file(struct page *page, struct list_head *to_kill,
 	struct task_struct *tsk;
 	struct address_space *mapping = page->mapping;
 
-	mutex_lock(&mapping->i_mmap_mutex);
+	i_mmap_lock_write(mapping);
 	read_lock(&tasklist_lock);
 	for_each_process(tsk) {
 		pgoff_t pgoff = page_pgoff(page);
@@ -456,7 +456,7 @@ static void collect_procs_file(struct page *page, struct list_head *to_kill,
 		}
 	}
 	read_unlock(&tasklist_lock);
-	mutex_unlock(&mapping->i_mmap_mutex);
+	i_mmap_unlock_write(mapping);
 }
 
 /*
diff --git a/mm/memory.c b/mm/memory.c
index e9a3c0f..815bcd9 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1340,9 +1340,9 @@ static void unmap_single_vma(struct mmu_gather *tlb,
 			 * safe to do nothing in this case.
 			 */
 			if (vma->vm_file) {
-				mutex_lock(&vma->vm_file->f_mapping->i_mmap_mutex);
+				i_mmap_lock_write(vma->vm_file->f_mapping);
 				__unmap_hugepage_range_final(tlb, vma, start, end, NULL);
-				mutex_unlock(&vma->vm_file->f_mapping->i_mmap_mutex);
+				i_mmap_unlock_write(vma->vm_file->f_mapping);
 			}
 		} else
 			unmap_page_range(tlb, vma, start, end, details);
@@ -2387,12 +2387,12 @@ void unmap_mapping_range(struct address_space *mapping,
 		details.last_index = ULONG_MAX;
 
 
-	mutex_lock(&mapping->i_mmap_mutex);
+	i_mmap_lock_write(mapping);
 	if (unlikely(!RB_EMPTY_ROOT(&mapping->i_mmap)))
 		unmap_mapping_range_tree(&mapping->i_mmap, &details);
 	if (unlikely(!list_empty(&mapping->i_mmap_nonlinear)))
 		unmap_mapping_range_list(&mapping->i_mmap_nonlinear, &details);
-	mutex_unlock(&mapping->i_mmap_mutex);
+	i_mmap_unlock_write(mapping);
 }
 EXPORT_SYMBOL(unmap_mapping_range);
 
diff --git a/mm/mmap.c b/mm/mmap.c
index da3c212..41a0083 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -236,9 +236,9 @@ void unlink_file_vma(struct vm_area_struct *vma)
 
 	if (file) {
 		struct address_space *mapping = file->f_mapping;
-		mutex_lock(&mapping->i_mmap_mutex);
+		i_mmap_lock_write(mapping);
 		__remove_shared_vm_struct(vma, file, mapping);
-		mutex_unlock(&mapping->i_mmap_mutex);
+		i_mmap_unlock_write(mapping);
 	}
 }
 
@@ -645,14 +645,14 @@ static void vma_link(struct mm_struct *mm, struct vm_area_struct *vma,
 
 	if (vma->vm_file) {
 		mapping = vma->vm_file->f_mapping;
-		mutex_lock(&mapping->i_mmap_mutex);
+		i_mmap_lock_write(mapping);
 	}
 
 	__vma_link(mm, vma, prev, rb_link, rb_parent);
 	__vma_link_file(vma);
 
 	if (mapping)
-		mutex_unlock(&mapping->i_mmap_mutex);
+		i_mmap_unlock_write(mapping);
 
 	mm->map_count++;
 	validate_mm(mm);
@@ -764,7 +764,7 @@ again:			remove_next = 1 + (end > next->vm_end);
 							next->vm_end);
 		}
 
-		mutex_lock(&mapping->i_mmap_mutex);
+		i_mmap_lock_write(mapping);
 		if (insert) {
 			/*
 			 * Put into interval tree now, so instantiated pages
@@ -851,7 +851,7 @@ again:			remove_next = 1 + (end > next->vm_end);
 		anon_vma_unlock_write(anon_vma);
 	}
 	if (mapping)
-		mutex_unlock(&mapping->i_mmap_mutex);
+		i_mmap_unlock_write(mapping);
 
 	if (root) {
 		uprobe_mmap(vma);
@@ -3174,7 +3174,7 @@ static void vm_unlock_mapping(struct address_space *mapping)
 		 * AS_MM_ALL_LOCKS can't change to 0 from under us
 		 * because we hold the mm_all_locks_mutex.
 		 */
-		mutex_unlock(&mapping->i_mmap_mutex);
+		i_mmap_unlock_write(mapping);
 		if (!test_and_clear_bit(AS_MM_ALL_LOCKS,
 					&mapping->flags))
 			BUG();
diff --git a/mm/mremap.c b/mm/mremap.c
index 05f1180..60259a2 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -119,7 +119,7 @@ static void move_ptes(struct vm_area_struct *vma, pmd_t *old_pmd,
 	if (need_rmap_locks) {
 		if (vma->vm_file) {
 			mapping = vma->vm_file->f_mapping;
-			mutex_lock(&mapping->i_mmap_mutex);
+			i_mmap_lock_write(mapping);
 		}
 		if (vma->anon_vma) {
 			anon_vma = vma->anon_vma;
@@ -156,7 +156,7 @@ static void move_ptes(struct vm_area_struct *vma, pmd_t *old_pmd,
 	if (anon_vma)
 		anon_vma_unlock_write(anon_vma);
 	if (mapping)
-		mutex_unlock(&mapping->i_mmap_mutex);
+		i_mmap_unlock_write(mapping);
 }
 
 #define LATENCY_LIMIT	(64 * PAGE_SIZE)
diff --git a/mm/nommu.c b/mm/nommu.c
index e6ced9d..52047c4 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -722,11 +722,11 @@ static void add_vma_to_mm(struct mm_struct *mm, struct vm_area_struct *vma)
 	if (vma->vm_file) {
 		mapping = vma->vm_file->f_mapping;
 
-		mutex_lock(&mapping->i_mmap_mutex);
+		i_mmap_lock_write(mapping);
 		flush_dcache_mmap_lock(mapping);
 		vma_interval_tree_insert(vma, &mapping->i_mmap);
 		flush_dcache_mmap_unlock(mapping);
-		mutex_unlock(&mapping->i_mmap_mutex);
+		i_mmap_unlock_write(mapping);
 	}
 
 	/* add the VMA to the tree */
@@ -795,11 +795,11 @@ static void delete_vma_from_mm(struct vm_area_struct *vma)
 	if (vma->vm_file) {
 		mapping = vma->vm_file->f_mapping;
 
-		mutex_lock(&mapping->i_mmap_mutex);
+		i_mmap_lock_write(mapping);
 		flush_dcache_mmap_lock(mapping);
 		vma_interval_tree_remove(vma, &mapping->i_mmap);
 		flush_dcache_mmap_unlock(mapping);
-		mutex_unlock(&mapping->i_mmap_mutex);
+		i_mmap_unlock_write(mapping);
 	}
 
 	/* remove from the MM's tree and list */
@@ -2091,14 +2091,14 @@ int nommu_shrink_inode_mappings(struct inode *inode, size_t size,
 	high = (size + PAGE_SIZE - 1) >> PAGE_SHIFT;
 
 	down_write(&nommu_region_sem);
-	mutex_lock(&inode->i_mapping->i_mmap_mutex);
+	i_mmap_lock_write(inode->i_mapping);
 
 	/* search for VMAs that fall within the dead zone */
 	vma_interval_tree_foreach(vma, &inode->i_mapping->i_mmap, low, high) {
 		/* found one - only interested if it's shared out of the page
 		 * cache */
 		if (vma->vm_flags & VM_SHARED) {
-			mutex_unlock(&inode->i_mapping->i_mmap_mutex);
+			i_mmap_unlock_write(inode->i_mapping);
 			up_write(&nommu_region_sem);
 			return -ETXTBSY; /* not quite true, but near enough */
 		}
@@ -2126,7 +2126,7 @@ int nommu_shrink_inode_mappings(struct inode *inode, size_t size,
 		}
 	}
 
-	mutex_unlock(&inode->i_mapping->i_mmap_mutex);
+	i_mmap_unlock_write(inode->i_mapping);
 	up_write(&nommu_region_sem);
 	return 0;
 }
diff --git a/mm/rmap.c b/mm/rmap.c
index 3333baa..9a56e4f 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1685,7 +1685,7 @@ static int rmap_walk_file(struct page *page, struct rmap_walk_control *rwc)
 
 	if (!mapping)
 		return ret;
-	mutex_lock(&mapping->i_mmap_mutex);
+	i_mmap_lock_write(mapping);
 	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
 		unsigned long address = vma_address(page, vma);
 
@@ -1708,7 +1708,7 @@ static int rmap_walk_file(struct page *page, struct rmap_walk_control *rwc)
 	ret = rwc->file_nonlinear(page, mapping, rwc->arg);
 
 done:
-	mutex_unlock(&mapping->i_mmap_mutex);
+	i_mmap_unlock_write(mapping);
 	return ret;
 }
 
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
