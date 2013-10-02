Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id 39F126B003C
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 16:18:09 -0400 (EDT)
Received: by mail-pb0-f47.google.com with SMTP id rr4so1390389pbb.34
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 13:18:08 -0700 (PDT)
From: Davidlohr Bueso <davidlohr@hp.com>
Subject: [PATCH 2/2] fs,mm: use new helper functions around the i_mmap_mutex
Date: Wed,  2 Oct 2013 13:17:46 -0700
Message-Id: <1380745066-9925-3-git-send-email-davidlohr@hp.com>
In-Reply-To: <1380745066-9925-1-git-send-email-davidlohr@hp.com>
References: <1380745066-9925-1-git-send-email-davidlohr@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, aswin@hp.com, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Davidlohr Bueso <davidlohr@hp.com>

Convert all open coded mutex_lock/unlock calls to the
i_mmap_[lock/unlock]_write() helpers.

Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
---
 fs/hugetlbfs/inode.c    |  4 ++--
 kernel/events/uprobes.c |  4 ++--
 kernel/fork.c           |  4 ++--
 mm/filemap_xip.c        |  4 ++--
 mm/fremap.c             |  4 ++--
 mm/hugetlb.c            | 12 ++++++------
 mm/memory-failure.c     |  4 ++--
 mm/memory.c             |  8 ++++----
 mm/mmap.c               | 14 +++++++-------
 mm/mremap.c             |  4 ++--
 mm/nommu.c              | 14 +++++++-------
 mm/rmap.c               | 16 ++++++++--------
 12 files changed, 46 insertions(+), 46 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index d19b30a..526319f 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -404,10 +404,10 @@ static int hugetlb_vmtruncate(struct inode *inode, loff_t offset)
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
index ad8e1bd..96dd9dc 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -693,7 +693,7 @@ build_map_info(struct address_space *mapping, loff_t offset, bool is_register)
 	int more = 0;
 
  again:
-	mutex_lock(&mapping->i_mmap_mutex);
+	i_mmap_lock_write(mapping);
 	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
 		if (!valid_vma(vma, is_register))
 			continue;
@@ -724,8 +724,8 @@ build_map_info(struct address_space *mapping, loff_t offset, bool is_register)
 		info->mm = vma->vm_mm;
 		info->vaddr = offset_to_vaddr(vma, offset);
 	}
-	mutex_unlock(&mapping->i_mmap_mutex);
 
+	i_mmap_unlock_write(mapping);
 	if (!more)
 		goto out;
 
diff --git a/kernel/fork.c b/kernel/fork.c
index 086fe73..36971d7 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -415,7 +415,7 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 			get_file(file);
 			if (tmp->vm_flags & VM_DENYWRITE)
 				atomic_dec(&inode->i_writecount);
-			mutex_lock(&mapping->i_mmap_mutex);
+			i_mmap_lock_write(mapping);
 			if (tmp->vm_flags & VM_SHARED)
 				mapping->i_mmap_writable++;
 			flush_dcache_mmap_lock(mapping);
@@ -427,7 +427,7 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 				vma_interval_tree_insert_after(tmp, mpnt,
 							&mapping->i_mmap);
 			flush_dcache_mmap_unlock(mapping);
-			mutex_unlock(&mapping->i_mmap_mutex);
+			i_mmap_unlock_write(mapping);
 		}
 
 		/*
diff --git a/mm/filemap_xip.c b/mm/filemap_xip.c
index 28fe26b..c851586 100644
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
diff --git a/mm/fremap.c b/mm/fremap.c
index 5bff081..7d28bcf 100644
--- a/mm/fremap.c
+++ b/mm/fremap.c
@@ -220,13 +220,13 @@ get_write_lock:
 			}
 			goto out;
 		}
-		mutex_lock(&mapping->i_mmap_mutex);
+		i_mmap_lock_write(mapping);
 		flush_dcache_mmap_lock(mapping);
 		vma->vm_flags |= VM_NONLINEAR;
 		vma_interval_tree_remove(vma, &mapping->i_mmap);
 		vma_nonlinear_insert(vma, &mapping->i_mmap_nonlinear);
 		flush_dcache_mmap_unlock(mapping);
-		mutex_unlock(&mapping->i_mmap_mutex);
+		i_mmap_unlock_write(mapping);
 	}
 
 	if (vma->vm_flags & VM_LOCKED) {
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index b49579c..22a673d 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2568,7 +2568,7 @@ static int unmap_ref_private(struct mm_struct *mm, struct vm_area_struct *vma,
 	 * this mapping should be shared between all the VMAs,
 	 * __unmap_hugepage_range() is called as the lock is already held
 	 */
-	mutex_lock(&mapping->i_mmap_mutex);
+	i_mmap_lock_write(mapping);
 	vma_interval_tree_foreach(iter_vma, &mapping->i_mmap, pgoff, pgoff) {
 		/* Do not unmap the current VMA */
 		if (iter_vma == vma)
@@ -2585,7 +2585,7 @@ static int unmap_ref_private(struct mm_struct *mm, struct vm_area_struct *vma,
 			unmap_hugepage_range(iter_vma, address,
 					     address + huge_page_size(h), page);
 	}
-	mutex_unlock(&mapping->i_mmap_mutex);
+	i_mmap_unlock_write(mapping);
 
 	return 1;
 }
@@ -3102,7 +3102,7 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 	BUG_ON(address >= end);
 	flush_cache_range(vma, address, end);
 
-	mutex_lock(&vma->vm_file->f_mapping->i_mmap_mutex);
+	i_mmap_lock_write(vma->vm_file->f_mapping);
 	spin_lock(&mm->page_table_lock);
 	for (; address < end; address += huge_page_size(h)) {
 		ptep = huge_pte_offset(mm, address);
@@ -3128,7 +3128,7 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 	 * and that page table be reused and filled with junk.
 	 */
 	flush_tlb_range(vma, start, end);
-	mutex_unlock(&vma->vm_file->f_mapping->i_mmap_mutex);
+	i_mmap_unlock_write(vma->vm_file->f_mapping);
 
 	return pages << h->order;
 }
@@ -3287,7 +3287,7 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
 	if (!vma_shareable(vma, addr))
 		return (pte_t *)pmd_alloc(mm, pud, addr);
 
-	mutex_lock(&mapping->i_mmap_mutex);
+	i_mmap_lock_write(mapping);
 	vma_interval_tree_foreach(svma, &mapping->i_mmap, idx, idx) {
 		if (svma == vma)
 			continue;
@@ -3314,7 +3314,7 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
 	spin_unlock(&mm->page_table_lock);
 out:
 	pte = (pte_t *)pmd_alloc(mm, pud, addr);
-	mutex_unlock(&mapping->i_mmap_mutex);
+	i_mmap_unlock_write(mapping);
 	return pte;
 }
 
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index bf3351b..7ba8819 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -438,7 +438,7 @@ static void collect_procs_file(struct page *page, struct list_head *to_kill,
 	struct task_struct *tsk;
 	struct address_space *mapping = page->mapping;
 
-	mutex_lock(&mapping->i_mmap_mutex);
+	i_mmap_lock_write(mapping);
 	read_lock(&tasklist_lock);
 	for_each_process(tsk) {
 		pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
@@ -460,7 +460,7 @@ static void collect_procs_file(struct page *page, struct list_head *to_kill,
 		}
 	}
 	read_unlock(&tasklist_lock);
-	mutex_unlock(&mapping->i_mmap_mutex);
+	i_mmap_unlock_write(mapping);
 }
 
 /*
diff --git a/mm/memory.c b/mm/memory.c
index ca00039..9f54a90 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1326,9 +1326,9 @@ static void unmap_single_vma(struct mmu_gather *tlb,
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
@@ -2973,12 +2973,12 @@ void unmap_mapping_range(struct address_space *mapping,
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
index 9d54851..e727a3a 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -233,9 +233,9 @@ void unlink_file_vma(struct vm_area_struct *vma)
 
 	if (file) {
 		struct address_space *mapping = file->f_mapping;
-		mutex_lock(&mapping->i_mmap_mutex);
+		i_mmap_lock_write(mapping);
 		__remove_shared_vm_struct(vma, file, mapping);
-		mutex_unlock(&mapping->i_mmap_mutex);
+		i_mmap_unlock_write(mapping);
 	}
 }
 
@@ -644,13 +644,13 @@ static void vma_link(struct mm_struct *mm, struct vm_area_struct *vma,
 		mapping = vma->vm_file->f_mapping;
 
 	if (mapping)
-		mutex_lock(&mapping->i_mmap_mutex);
+		i_mmap_lock_write(mapping);
 
 	__vma_link(mm, vma, prev, rb_link, rb_parent);
 	__vma_link_file(vma);
 
 	if (mapping)
-		mutex_unlock(&mapping->i_mmap_mutex);
+		i_mmap_unlock_write(mapping);
 
 	mm->map_count++;
 	validate_mm(mm);
@@ -761,7 +761,7 @@ again:			remove_next = 1 + (end > next->vm_end);
 							next->vm_end);
 		}
 
-		mutex_lock(&mapping->i_mmap_mutex);
+		i_mmap_lock_write(mapping);
 		if (insert) {
 			/*
 			 * Put into interval tree now, so instantiated pages
@@ -848,7 +848,7 @@ again:			remove_next = 1 + (end > next->vm_end);
 		anon_vma_unlock_write(anon_vma);
 	}
 	if (mapping)
-		mutex_unlock(&mapping->i_mmap_mutex);
+		i_mmap_unlock_write(mapping);
 
 	if (root) {
 		uprobe_mmap(vma);
@@ -3081,7 +3081,7 @@ static void vm_unlock_mapping(struct address_space *mapping)
 		 * AS_MM_ALL_LOCKS can't change to 0 from under us
 		 * because we hold the mm_all_locks_mutex.
 		 */
-		mutex_unlock(&mapping->i_mmap_mutex);
+		i_mmap_unlock_write(mapping);
 		if (!test_and_clear_bit(AS_MM_ALL_LOCKS,
 					&mapping->flags))
 			BUG();
diff --git a/mm/mremap.c b/mm/mremap.c
index 91b13d6..e8de648 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -122,7 +122,7 @@ static void move_ptes(struct vm_area_struct *vma, pmd_t *old_pmd,
 	if (need_rmap_locks) {
 		if (vma->vm_file) {
 			mapping = vma->vm_file->f_mapping;
-			mutex_lock(&mapping->i_mmap_mutex);
+			i_mmap_lock_write(mapping);
 		}
 		if (vma->anon_vma) {
 			anon_vma = vma->anon_vma;
@@ -159,7 +159,7 @@ static void move_ptes(struct vm_area_struct *vma, pmd_t *old_pmd,
 	if (anon_vma)
 		anon_vma_unlock_write(anon_vma);
 	if (mapping)
-		mutex_unlock(&mapping->i_mmap_mutex);
+		i_mmap_unlock_write(mapping);
 }
 
 #define LATENCY_LIMIT	(64 * PAGE_SIZE)
diff --git a/mm/nommu.c b/mm/nommu.c
index ecd1f15..28361cf 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -716,11 +716,11 @@ static void add_vma_to_mm(struct mm_struct *mm, struct vm_area_struct *vma)
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
@@ -782,11 +782,11 @@ static void delete_vma_from_mm(struct vm_area_struct *vma)
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
@@ -2085,14 +2085,14 @@ int nommu_shrink_inode_mappings(struct inode *inode, size_t size,
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
@@ -2120,7 +2120,7 @@ int nommu_shrink_inode_mappings(struct inode *inode, size_t size,
 		}
 	}
 
-	mutex_unlock(&inode->i_mapping->i_mmap_mutex);
+	i_mmap_unlock_write(inode->i_mapping);
 	up_write(&nommu_region_sem);
 	return 0;
 }
diff --git a/mm/rmap.c b/mm/rmap.c
index fd3ee7a..29548e5 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -808,7 +808,7 @@ static int page_referenced_file(struct page *page,
 	 */
 	BUG_ON(!PageLocked(page));
 
-	mutex_lock(&mapping->i_mmap_mutex);
+	i_mmap_lock_write(mapping);
 
 	/*
 	 * i_mmap_mutex does not stabilize mapcount at all, but mapcount
@@ -831,7 +831,7 @@ static int page_referenced_file(struct page *page,
 			break;
 	}
 
-	mutex_unlock(&mapping->i_mmap_mutex);
+	i_mmap_unlock_write(mapping);
 	return referenced;
 }
 
@@ -917,14 +917,14 @@ static int page_mkclean_file(struct address_space *mapping, struct page *page)
 
 	BUG_ON(PageAnon(page));
 
-	mutex_lock(&mapping->i_mmap_mutex);
+	i_mmap_lock_write(mapping);
 	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
 		if (vma->vm_flags & VM_SHARED) {
 			unsigned long address = vma_address(page, vma);
 			ret += page_mkclean_one(page, vma, address);
 		}
 	}
-	mutex_unlock(&mapping->i_mmap_mutex);
+	i_mmap_unlock_write(mapping);
 	return ret;
 }
 
@@ -1522,7 +1522,7 @@ static int try_to_unmap_file(struct page *page, enum ttu_flags flags)
 	if (PageHuge(page))
 		pgoff = page->index << compound_order(page);
 
-	mutex_lock(&mapping->i_mmap_mutex);
+	i_mmap_lock_write(mapping);
 	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
 		unsigned long address = vma_address(page, vma);
 		ret = try_to_unmap_one(page, vma, address, flags);
@@ -1600,7 +1600,7 @@ static int try_to_unmap_file(struct page *page, enum ttu_flags flags)
 	list_for_each_entry(vma, &mapping->i_mmap_nonlinear, shared.nonlinear)
 		vma->vm_private_data = NULL;
 out:
-	mutex_unlock(&mapping->i_mmap_mutex);
+	i_mmap_unlock_write(mapping);
 	return ret;
 }
 
@@ -1717,7 +1717,7 @@ static int rmap_walk_file(struct page *page, int (*rmap_one)(struct page *,
 
 	if (!mapping)
 		return ret;
-	mutex_lock(&mapping->i_mmap_mutex);
+	i_mmap_lock_write(mapping);
 	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
 		unsigned long address = vma_address(page, vma);
 		ret = rmap_one(page, vma, address, arg);
@@ -1729,7 +1729,7 @@ static int rmap_walk_file(struct page *page, int (*rmap_one)(struct page *,
 	 * never contain migration ptes.  Decide what to do about this
 	 * limitation to linear when we need rmap_walk() on nonlinear.
 	 */
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
