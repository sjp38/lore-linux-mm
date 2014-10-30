Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 6C3D590008B
	for <linux-mm@kvack.org>; Thu, 30 Oct 2014 15:34:40 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id kx10so6096253pab.40
        for <linux-mm@kvack.org>; Thu, 30 Oct 2014 12:34:40 -0700 (PDT)
Received: from theshire.emacs.cl (theshire.emacs.cl. [192.155.80.235])
        by mx.google.com with ESMTP id rh5si7318769pbc.189.2014.10.30.12.34.38
        for <linux-mm@kvack.org>;
        Thu, 30 Oct 2014 12:34:38 -0700 (PDT)
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: [PATCH 02/10] mm: use new helper functions around the i_mmap_mutex
Date: Thu, 30 Oct 2014 12:34:09 -0700
Message-Id: <1414697657-1678-3-git-send-email-dave@stgolabs.net>
In-Reply-To: <1414697657-1678-1-git-send-email-dave@stgolabs.net>
References: <1414697657-1678-1-git-send-email-dave@stgolabs.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: hughd@google.com, riel@redhat.com, mgorman@suse.de, peterz@infradead.org, mingo@kernel.org, linux-kernel@vger.kernel.org, dbueso@suse.de, linux-mm@kvack.org, Davidlohr Bueso <dave@stgolabs.net>

Convert all open coded mutex_lock/unlock calls to the
i_mmap_[lock/unlock]_write() helpers.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
Acked-by: Rik van Riel <riel@redhat.com>
Acked-by: Kirill A. Shutemov <kirill.shutemov@intel.linux.com>
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
index 1e2872b..a082709 100644
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
index bc143cf..a1d99e3 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -724,7 +724,7 @@ build_map_info(struct address_space *mapping, loff_t offset, bool is_register)
 	int more = 0;
 
  again:
-	mutex_lock(&mapping->i_mmap_mutex);
+	i_mmap_lock_write(mapping);
 	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
 		if (!valid_vma(vma, is_register))
 			continue;
@@ -755,7 +755,7 @@ build_map_info(struct address_space *mapping, loff_t offset, bool is_register)
 		info->mm = vma->vm_mm;
 		info->vaddr = offset_to_vaddr(vma, offset);
 	}
-	mutex_unlock(&mapping->i_mmap_mutex);
+	i_mmap_unlock_write(mapping);
 
 	if (!more)
 		goto out;
diff --git a/kernel/fork.c b/kernel/fork.c
index 9ca8418..4dc2dda 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -433,7 +433,7 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 			get_file(file);
 			if (tmp->vm_flags & VM_DENYWRITE)
 				atomic_dec(&inode->i_writecount);
-			mutex_lock(&mapping->i_mmap_mutex);
+			i_mmap_lock_write(mapping);
 			if (tmp->vm_flags & VM_SHARED)
 				atomic_inc(&mapping->i_mmap_writable);
 			flush_dcache_mmap_lock(mapping);
@@ -445,7 +445,7 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
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
index f0cca62..5d8758f 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2775,7 +2775,7 @@ static void unmap_ref_private(struct mm_struct *mm, struct vm_area_struct *vma,
 	 * this mapping should be shared between all the VMAs,
 	 * __unmap_hugepage_range() is called as the lock is already held
 	 */
-	mutex_lock(&mapping->i_mmap_mutex);
+	i_mmap_lock_write(mapping);
 	vma_interval_tree_foreach(iter_vma, &mapping->i_mmap, pgoff, pgoff) {
 		/* Do not unmap the current VMA */
 		if (iter_vma == vma)
@@ -2792,7 +2792,7 @@ static void unmap_ref_private(struct mm_struct *mm, struct vm_area_struct *vma,
 			unmap_hugepage_range(iter_vma, address,
 					     address + huge_page_size(h), page);
 	}
-	mutex_unlock(&mapping->i_mmap_mutex);
+	i_mmap_unlock_write(mapping);
 }
 
 /*
@@ -3350,7 +3350,7 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 	flush_cache_range(vma, address, end);
 
 	mmu_notifier_invalidate_range_start(mm, start, end);
-	mutex_lock(&vma->vm_file->f_mapping->i_mmap_mutex);
+	i_mmap_lock_write(vma->vm_file->f_mapping);
 	for (; address < end; address += huge_page_size(h)) {
 		spinlock_t *ptl;
 		ptep = huge_pte_offset(mm, address);
@@ -3379,7 +3379,7 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 	 */
 	flush_tlb_range(vma, start, end);
 	mmu_notifier_invalidate_range(mm, start, end);
-	mutex_unlock(&vma->vm_file->f_mapping->i_mmap_mutex);
+	i_mmap_unlock_write(vma->vm_file->f_mapping);
 	mmu_notifier_invalidate_range_end(mm, start, end);
 
 	return pages << h->order;
@@ -3547,7 +3547,7 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
 	if (!vma_shareable(vma, addr))
 		return (pte_t *)pmd_alloc(mm, pud, addr);
 
-	mutex_lock(&mapping->i_mmap_mutex);
+	i_mmap_lock_write(mapping);
 	vma_interval_tree_foreach(svma, &mapping->i_mmap, idx, idx) {
 		if (svma == vma)
 			continue;
@@ -3575,7 +3575,7 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
 	spin_unlock(ptl);
 out:
 	pte = (pte_t *)pmd_alloc(mm, pud, addr);
-	mutex_unlock(&mapping->i_mmap_mutex);
+	i_mmap_unlock_write(mapping);
 	return pte;
 }
 
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 84e7ded..e1646fe 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -466,7 +466,7 @@ static void collect_procs_file(struct page *page, struct list_head *to_kill,
 	struct task_struct *tsk;
 	struct address_space *mapping = page->mapping;
 
-	mutex_lock(&mapping->i_mmap_mutex);
+	i_mmap_lock_write(mapping);
 	read_lock(&tasklist_lock);
 	for_each_process(tsk) {
 		pgoff_t pgoff = page_to_pgoff(page);
@@ -488,7 +488,7 @@ static void collect_procs_file(struct page *page, struct list_head *to_kill,
 		}
 	}
 	read_unlock(&tasklist_lock);
-	mutex_unlock(&mapping->i_mmap_mutex);
+	i_mmap_unlock_write(mapping);
 }
 
 /*
diff --git a/mm/memory.c b/mm/memory.c
index f61d341..22c3089 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1345,9 +1345,9 @@ static void unmap_single_vma(struct mmu_gather *tlb,
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
@@ -2396,12 +2396,12 @@ void unmap_mapping_range(struct address_space *mapping,
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
index ed11b43..136f4c8 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -260,9 +260,9 @@ void unlink_file_vma(struct vm_area_struct *vma)
 
 	if (file) {
 		struct address_space *mapping = file->f_mapping;
-		mutex_lock(&mapping->i_mmap_mutex);
+		i_mmap_lock_write(mapping);
 		__remove_shared_vm_struct(vma, file, mapping);
-		mutex_unlock(&mapping->i_mmap_mutex);
+		i_mmap_unlock_write(mapping);
 	}
 }
 
@@ -674,14 +674,14 @@ static void vma_link(struct mm_struct *mm, struct vm_area_struct *vma,
 
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
@@ -793,7 +793,7 @@ again:			remove_next = 1 + (end > next->vm_end);
 							next->vm_end);
 		}
 
-		mutex_lock(&mapping->i_mmap_mutex);
+		i_mmap_lock_write(mapping);
 		if (insert) {
 			/*
 			 * Put into interval tree now, so instantiated pages
@@ -880,7 +880,7 @@ again:			remove_next = 1 + (end > next->vm_end);
 		anon_vma_unlock_write(anon_vma);
 	}
 	if (mapping)
-		mutex_unlock(&mapping->i_mmap_mutex);
+		i_mmap_unlock_write(mapping);
 
 	if (root) {
 		uprobe_mmap(vma);
@@ -3245,7 +3245,7 @@ static void vm_unlock_mapping(struct address_space *mapping)
 		 * AS_MM_ALL_LOCKS can't change to 0 from under us
 		 * because we hold the mm_all_locks_mutex.
 		 */
-		mutex_unlock(&mapping->i_mmap_mutex);
+		i_mmap_unlock_write(mapping);
 		if (!test_and_clear_bit(AS_MM_ALL_LOCKS,
 					&mapping->flags))
 			BUG();
diff --git a/mm/mremap.c b/mm/mremap.c
index 1e35ba66..fa7c432 100644
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
 		anon_vma_unlock_read(anon_vma);
 	if (mapping)
-		mutex_unlock(&mapping->i_mmap_mutex);
+		i_mmap_unlock_write(mapping);
 }
 
 #define LATENCY_LIMIT	(64 * PAGE_SIZE)
diff --git a/mm/nommu.c b/mm/nommu.c
index bd10aa1..4201a38 100644
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
@@ -2086,14 +2086,14 @@ int nommu_shrink_inode_mappings(struct inode *inode, size_t size,
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
@@ -2121,7 +2121,7 @@ int nommu_shrink_inode_mappings(struct inode *inode, size_t size,
 		}
 	}
 
-	mutex_unlock(&inode->i_mapping->i_mmap_mutex);
+	i_mmap_unlock_write(inode->i_mapping);
 	up_write(&nommu_region_sem);
 	return 0;
 }
diff --git a/mm/rmap.c b/mm/rmap.c
index d3eb1e0..ae72965 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1688,7 +1688,7 @@ static int rmap_walk_file(struct page *page, struct rmap_walk_control *rwc)
 
 	if (!mapping)
 		return ret;
-	mutex_lock(&mapping->i_mmap_mutex);
+	i_mmap_lock_write(mapping);
 	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
 		unsigned long address = vma_address(page, vma);
 
@@ -1711,7 +1711,7 @@ static int rmap_walk_file(struct page *page, struct rmap_walk_control *rwc)
 	ret = rwc->file_nonlinear(page, mapping, rwc->arg);
 
 done:
-	mutex_unlock(&mapping->i_mmap_mutex);
+	i_mmap_unlock_write(mapping);
 	return ret;
 }
 
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
