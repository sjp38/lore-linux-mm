Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 50A916B0038
	for <linux-mm@kvack.org>; Mon, 24 Jun 2013 20:21:48 -0400 (EDT)
From: Davidlohr Bueso <davidlohr.bueso@hp.com>
Subject: [PATCH 2/5] mm: use new helper functions around the i_mmap_mutex
Date: Mon, 24 Jun 2013 17:21:35 -0700
Message-Id: <1372119698-13147-3-git-send-email-davidlohr.bueso@hp.com>
In-Reply-To: <1372119698-13147-1-git-send-email-davidlohr.bueso@hp.com>
References: <1372119698-13147-1-git-send-email-davidlohr.bueso@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mingo@kernel.org, akpm@linux-foundation.org
Cc: walken@google.com, alex.shi@intel.com, tim.c.chen@linux.intel.com, a.p.zijlstra@chello.nl, riel@redhat.com, peter@hurleysoftware.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Davidlohr Bueso <davidlohr.bueso@hp.com>

Convert all open coded mutex_lock/unlock calls to the
i_mmap_[lock/unlock]_write() helpers.

Signed-off-by: Davidlohr Bueso <davidlohr.bueso@hp.com>
---
 arch/x86/mm/hugetlbpage.c |  4 ++--
 fs/hugetlbfs/inode.c      |  4 ++--
 kernel/events/uprobes.c   |  4 ++--
 kernel/fork.c             |  4 ++--
 mm/filemap_xip.c          |  4 ++--
 mm/fremap.c               |  4 ++--
 mm/hugetlb.c              |  8 ++++----
 mm/memory-failure.c       |  4 ++--
 mm/memory.c               |  8 ++++----
 mm/mmap.c                 | 14 +++++++-------
 mm/mremap.c               |  4 ++--
 mm/nommu.c                | 14 +++++++-------
 mm/rmap.c                 | 16 ++++++++--------
 13 files changed, 46 insertions(+), 46 deletions(-)

diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
index ae1aa71..9c61a1e 100644
--- a/arch/x86/mm/hugetlbpage.c
+++ b/arch/x86/mm/hugetlbpage.c
@@ -79,7 +79,7 @@ huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
 	if (!vma_shareable(vma, addr))
 		return (pte_t *)pmd_alloc(mm, pud, addr);
 
-	mutex_lock(&mapping->i_mmap_mutex);
+	i_mmap_lock_write(mapping);
 	vma_interval_tree_foreach(svma, &mapping->i_mmap, idx, idx) {
 		if (svma == vma)
 			continue;
@@ -105,7 +105,7 @@ huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
 	spin_unlock(&mm->page_table_lock);
 out:
 	pte = (pte_t *)pmd_alloc(mm, pud, addr);
-	mutex_unlock(&mapping->i_mmap_mutex);
+	i_mmap_unlock_write(mapping);
 	return pte;
 }
 
diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index a3f868a..35eebfc 100644
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
index f356974..c7b9f45 100644
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
@@ -724,7 +724,7 @@ build_map_info(struct address_space *mapping, loff_t offset, bool is_register)
 		info->mm = vma->vm_mm;
 		info->vaddr = offset_to_vaddr(vma, offset);
 	}
-	mutex_unlock(&mapping->i_mmap_mutex);
+	i_mmap_unlock_write(mapping);
 
 	if (!more)
 		goto out;
diff --git a/kernel/fork.c b/kernel/fork.c
index 987b28a..13226f1 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -420,7 +420,7 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 			get_file(file);
 			if (tmp->vm_flags & VM_DENYWRITE)
 				atomic_dec(&inode->i_writecount);
-			mutex_lock(&mapping->i_mmap_mutex);
+			i_mmap_lock_write(mapping);
 			if (tmp->vm_flags & VM_SHARED)
 				mapping->i_mmap_writable++;
 			flush_dcache_mmap_lock(mapping);
@@ -432,7 +432,7 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
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
index 87da359..fa49f3d 100644
--- a/mm/fremap.c
+++ b/mm/fremap.c
@@ -215,13 +215,13 @@ get_write_lock:
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
index e2bfbf7..1becd0a 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2506,7 +2506,7 @@ static int unmap_ref_private(struct mm_struct *mm, struct vm_area_struct *vma,
 	 * this mapping should be shared between all the VMAs,
 	 * __unmap_hugepage_range() is called as the lock is already held
 	 */
-	mutex_lock(&mapping->i_mmap_mutex);
+	i_mmap_lock_write(mapping);
 	vma_interval_tree_foreach(iter_vma, &mapping->i_mmap, pgoff, pgoff) {
 		/* Do not unmap the current VMA */
 		if (iter_vma == vma)
@@ -2523,7 +2523,7 @@ static int unmap_ref_private(struct mm_struct *mm, struct vm_area_struct *vma,
 			unmap_hugepage_range(iter_vma, address,
 					     address + huge_page_size(h), page);
 	}
-	mutex_unlock(&mapping->i_mmap_mutex);
+	i_mmap_unlock_write(mapping);
 
 	return 1;
 }
@@ -3047,7 +3047,7 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 	BUG_ON(address >= end);
 	flush_cache_range(vma, address, end);
 
-	mutex_lock(&vma->vm_file->f_mapping->i_mmap_mutex);
+	i_mmap_lock_write(vma->vm_file->f_mapping);
 	spin_lock(&mm->page_table_lock);
 	for (; address < end; address += huge_page_size(h)) {
 		ptep = huge_pte_offset(mm, address);
@@ -3073,7 +3073,7 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 	 * and that page table be reused and filled with junk.
 	 */
 	flush_tlb_range(vma, start, end);
-	mutex_unlock(&vma->vm_file->f_mapping->i_mmap_mutex);
+	i_mmap_unlock_write(vma->vm_file->f_mapping);
 
 	return pages << h->order;
 }
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index ceb0c7f..e7e0f90 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -436,7 +436,7 @@ static void collect_procs_file(struct page *page, struct list_head *to_kill,
 	struct task_struct *tsk;
 	struct address_space *mapping = page->mapping;
 
-	mutex_lock(&mapping->i_mmap_mutex);
+	i_mmap_lock_write(mapping);
 	read_lock(&tasklist_lock);
 	for_each_process(tsk) {
 		pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
@@ -458,7 +458,7 @@ static void collect_procs_file(struct page *page, struct list_head *to_kill,
 		}
 	}
 	read_unlock(&tasklist_lock);
-	mutex_unlock(&mapping->i_mmap_mutex);
+	i_mmap_unlock_write(mapping);
 }
 
 /*
diff --git a/mm/memory.c b/mm/memory.c
index 61a262b..344b4cf 100644
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
@@ -2974,12 +2974,12 @@ void unmap_mapping_range(struct address_space *mapping,
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
index f681e18..01a9876 100644
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
@@ -3112,7 +3112,7 @@ static void vm_unlock_mapping(struct address_space *mapping)
 		 * AS_MM_ALL_LOCKS can't change to 0 from under us
 		 * because we hold the mm_all_locks_mutex.
 		 */
-		mutex_unlock(&mapping->i_mmap_mutex);
+		i_mmap_unlock_write(mapping);
 		if (!test_and_clear_bit(AS_MM_ALL_LOCKS,
 					&mapping->flags))
 			BUG();
diff --git a/mm/mremap.c b/mm/mremap.c
index 463a257..02fc5df 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -101,7 +101,7 @@ static void move_ptes(struct vm_area_struct *vma, pmd_t *old_pmd,
 	if (need_rmap_locks) {
 		if (vma->vm_file) {
 			mapping = vma->vm_file->f_mapping;
-			mutex_lock(&mapping->i_mmap_mutex);
+			i_mmap_lock_write(mapping);
 		}
 		if (vma->anon_vma) {
 			anon_vma = vma->anon_vma;
@@ -137,7 +137,7 @@ static void move_ptes(struct vm_area_struct *vma, pmd_t *old_pmd,
 	if (anon_vma)
 		anon_vma_unlock_write(anon_vma);
 	if (mapping)
-		mutex_unlock(&mapping->i_mmap_mutex);
+		i_mmap_unlock_write(mapping);
 }
 
 #define LATENCY_LIMIT	(64 * PAGE_SIZE)
diff --git a/mm/nommu.c b/mm/nommu.c
index 298884d..5a11e45 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -714,11 +714,11 @@ static void add_vma_to_mm(struct mm_struct *mm, struct vm_area_struct *vma)
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
@@ -780,11 +780,11 @@ static void delete_vma_from_mm(struct vm_area_struct *vma)
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
@@ -2087,14 +2087,14 @@ int nommu_shrink_inode_mappings(struct inode *inode, size_t size,
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
@@ -2122,7 +2122,7 @@ int nommu_shrink_inode_mappings(struct inode *inode, size_t size,
 		}
 	}
 
-	mutex_unlock(&inode->i_mapping->i_mmap_mutex);
+	i_mmap_unlock_write(inode->i_mapping);
 	up_write(&nommu_region_sem);
 	return 0;
 }
diff --git a/mm/rmap.c b/mm/rmap.c
index 6280da8..bc8eeb5 100644
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
 
@@ -920,14 +920,14 @@ static int page_mkclean_file(struct address_space *mapping, struct page *page)
 
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
 
@@ -1516,7 +1516,7 @@ static int try_to_unmap_file(struct page *page, enum ttu_flags flags)
 	if (PageHuge(page))
 		pgoff = page->index << compound_order(page);
 
-	mutex_lock(&mapping->i_mmap_mutex);
+	i_mmap_lock_write(mapping);
 	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
 		unsigned long address = vma_address(page, vma);
 		ret = try_to_unmap_one(page, vma, address, flags);
@@ -1594,7 +1594,7 @@ static int try_to_unmap_file(struct page *page, enum ttu_flags flags)
 	list_for_each_entry(vma, &mapping->i_mmap_nonlinear, shared.nonlinear)
 		vma->vm_private_data = NULL;
 out:
-	mutex_unlock(&mapping->i_mmap_mutex);
+	i_mmap_unlock_write(mapping);
 	return ret;
 }
 
@@ -1711,7 +1711,7 @@ static int rmap_walk_file(struct page *page, int (*rmap_one)(struct page *,
 
 	if (!mapping)
 		return ret;
-	mutex_lock(&mapping->i_mmap_mutex);
+	i_mmap_lock_write(mapping);
 	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
 		unsigned long address = vma_address(page, vma);
 		ret = rmap_one(page, vma, address, arg);
@@ -1723,7 +1723,7 @@ static int rmap_walk_file(struct page *page, int (*rmap_one)(struct page *,
 	 * never contain migration ptes.  Decide what to do about this
 	 * limitation to linear when we need rmap_walk() on nonlinear.
 	 */
-	mutex_unlock(&mapping->i_mmap_mutex);
+	i_mmap_unlock_write(mapping);
 	return ret;
 }
 
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
