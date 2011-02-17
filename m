Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id DE1C28D0051
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 12:10:51 -0500 (EST)
Message-Id: <20110217170854.837277180@chello.nl>
Date: Thu, 17 Feb 2011 18:05:23 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 3/8] mm: Convert i_mmap_lock to a mutex
References: <20110217170520.229881980@chello.nl>
Content-Disposition: inline; filename=peter_zijlstra-mm-convert_i_mmap_lock_to_mutexes.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>, Hugh Dickins <hughd@google.com>

Straight fwd conversion of i_mmap_lock to a mutex

Acked-by: Hugh Dickins <hughd@google.com>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 Documentation/lockstat.txt   |    2 +-
 Documentation/vm/locking     |    2 +-
 arch/x86/mm/hugetlbpage.c    |    4 ++--
 fs/gfs2/main.c               |    2 +-
 fs/hugetlbfs/inode.c         |    4 ++--
 fs/inode.c                   |    2 +-
 fs/nilfs2/page.c             |    2 +-
 include/linux/fs.h           |    2 +-
 include/linux/mm.h           |    1 +
 include/linux/mmu_notifier.h |    2 +-
 kernel/fork.c                |    4 ++--
 mm/filemap.c                 |   10 +++++-----
 mm/filemap_xip.c             |    4 ++--
 mm/fremap.c                  |    4 ++--
 mm/hugetlb.c                 |   14 +++++++-------
 mm/memory-failure.c          |    4 ++--
 mm/memory.c                  |    4 ++--
 mm/mmap.c                    |   22 +++++++++++-----------
 mm/mremap.c                  |    4 ++--
 mm/rmap.c                    |   28 ++++++++++++++--------------
 20 files changed, 61 insertions(+), 60 deletions(-)

Index: linux-2.6/arch/x86/mm/hugetlbpage.c
===================================================================
--- linux-2.6.orig/arch/x86/mm/hugetlbpage.c
+++ linux-2.6/arch/x86/mm/hugetlbpage.c
@@ -72,7 +72,7 @@ static void huge_pmd_share(struct mm_str
 	if (!vma_shareable(vma, addr))
 		return;
 
-	spin_lock(&mapping->i_mmap_lock);
+	mutex_lock(&mapping->i_mmap_mutex);
 	vma_prio_tree_foreach(svma, &iter, &mapping->i_mmap, idx, idx) {
 		if (svma == vma)
 			continue;
@@ -97,7 +97,7 @@ static void huge_pmd_share(struct mm_str
 		put_page(virt_to_page(spte));
 	spin_unlock(&mm->page_table_lock);
 out:
-	spin_unlock(&mapping->i_mmap_lock);
+	mutex_unlock(&mapping->i_mmap_mutex);
 }
 
 /*
Index: linux-2.6/fs/hugetlbfs/inode.c
===================================================================
--- linux-2.6.orig/fs/hugetlbfs/inode.c
+++ linux-2.6/fs/hugetlbfs/inode.c
@@ -413,10 +413,10 @@ static int hugetlb_vmtruncate(struct ino
 	pgoff = offset >> PAGE_SHIFT;
 
 	i_size_write(inode, offset);
-	spin_lock(&mapping->i_mmap_lock);
+	mutex_lock(&mapping->i_mmap_mutex);
 	if (!prio_tree_empty(&mapping->i_mmap))
 		hugetlb_vmtruncate_list(&mapping->i_mmap, pgoff);
-	spin_unlock(&mapping->i_mmap_lock);
+	mutex_unlock(&mapping->i_mmap_mutex);
 	truncate_hugepages(inode, offset);
 	return 0;
 }
Index: linux-2.6/fs/inode.c
===================================================================
--- linux-2.6.orig/fs/inode.c
+++ linux-2.6/fs/inode.c
@@ -310,7 +310,7 @@ void inode_init_once(struct inode *inode
 	INIT_LIST_HEAD(&inode->i_lru);
 	INIT_RADIX_TREE(&inode->i_data.page_tree, GFP_ATOMIC);
 	spin_lock_init(&inode->i_data.tree_lock);
-	spin_lock_init(&inode->i_data.i_mmap_lock);
+	mutex_init(&inode->i_data.i_mmap_mutex);
 	INIT_LIST_HEAD(&inode->i_data.private_list);
 	spin_lock_init(&inode->i_data.private_lock);
 	INIT_RAW_PRIO_TREE_ROOT(&inode->i_data.i_mmap);
Index: linux-2.6/include/linux/fs.h
===================================================================
--- linux-2.6.orig/include/linux/fs.h
+++ linux-2.6/include/linux/fs.h
@@ -639,7 +639,7 @@ struct address_space {
 	unsigned int		i_mmap_writable;/* count VM_SHARED mappings */
 	struct prio_tree_root	i_mmap;		/* tree of private and shared mappings */
 	struct list_head	i_mmap_nonlinear;/*list VM_NONLINEAR mappings */
-	spinlock_t		i_mmap_lock;	/* protect tree, count, list */
+	struct mutex		i_mmap_mutex;	/* protect tree, count, list */
 	unsigned long		nrpages;	/* number of total pages */
 	pgoff_t			writeback_index;/* writeback starts here */
 	const struct address_space_operations *a_ops;	/* methods */
Index: linux-2.6/kernel/fork.c
===================================================================
--- linux-2.6.orig/kernel/fork.c
+++ linux-2.6/kernel/fork.c
@@ -376,14 +376,14 @@ static int dup_mmap(struct mm_struct *mm
 			get_file(file);
 			if (tmp->vm_flags & VM_DENYWRITE)
 				atomic_dec(&inode->i_writecount);
-			spin_lock(&mapping->i_mmap_lock);
+			mutex_lock(&mapping->i_mmap_mutex);
 			if (tmp->vm_flags & VM_SHARED)
 				mapping->i_mmap_writable++;
 			flush_dcache_mmap_lock(mapping);
 			/* insert tmp into the share list, just after mpnt */
 			vma_prio_tree_add(tmp, mpnt);
 			flush_dcache_mmap_unlock(mapping);
-			spin_unlock(&mapping->i_mmap_lock);
+			mutex_unlock(&mapping->i_mmap_mutex);
 		}
 
 		/*
Index: linux-2.6/mm/filemap_xip.c
===================================================================
--- linux-2.6.orig/mm/filemap_xip.c
+++ linux-2.6/mm/filemap_xip.c
@@ -183,7 +183,7 @@ __xip_unmap (struct address_space * mapp
 		return;
 
 retry:
-	spin_lock(&mapping->i_mmap_lock);
+	mutex_lock(&mapping->i_mmap_mutex);
 	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
 		mm = vma->vm_mm;
 		address = vma->vm_start +
@@ -201,7 +201,7 @@ __xip_unmap (struct address_space * mapp
 			page_cache_release(page);
 		}
 	}
-	spin_unlock(&mapping->i_mmap_lock);
+	mutex_unlock(&mapping->i_mmap_mutex);
 
 	if (locked) {
 		mutex_unlock(&xip_sparse_mutex);
Index: linux-2.6/mm/fremap.c
===================================================================
--- linux-2.6.orig/mm/fremap.c
+++ linux-2.6/mm/fremap.c
@@ -211,13 +211,13 @@ SYSCALL_DEFINE5(remap_file_pages, unsign
 			}
 			goto out;
 		}
-		spin_lock(&mapping->i_mmap_lock);
+		mutex_lock(&mapping->i_mmap_mutex);
 		flush_dcache_mmap_lock(mapping);
 		vma->vm_flags |= VM_NONLINEAR;
 		vma_prio_tree_remove(vma, &mapping->i_mmap);
 		vma_nonlinear_insert(vma, &mapping->i_mmap_nonlinear);
 		flush_dcache_mmap_unlock(mapping);
-		spin_unlock(&mapping->i_mmap_lock);
+		mutex_unlock(&mapping->i_mmap_mutex);
 	}
 
 	if (vma->vm_flags & VM_LOCKED) {
Index: linux-2.6/mm/hugetlb.c
===================================================================
--- linux-2.6.orig/mm/hugetlb.c
+++ linux-2.6/mm/hugetlb.c
@@ -2207,7 +2207,7 @@ void __unmap_hugepage_range(struct vm_ar
 	unsigned long sz = huge_page_size(h);
 
 	/*
-	 * A page gathering list, protected by per file i_mmap_lock. The
+	 * A page gathering list, protected by per file i_mmap_mutex. The
 	 * lock is used to avoid list corruption from multiple unmapping
 	 * of the same page since we are using page->lru.
 	 */
@@ -2276,9 +2276,9 @@ void __unmap_hugepage_range(struct vm_ar
 void unmap_hugepage_range(struct vm_area_struct *vma, unsigned long start,
 			  unsigned long end, struct page *ref_page)
 {
-	spin_lock(&vma->vm_file->f_mapping->i_mmap_lock);
+	mutex_lock(&vma->vm_file->f_mapping->i_mmap_mutex);
 	__unmap_hugepage_range(vma, start, end, ref_page);
-	spin_unlock(&vma->vm_file->f_mapping->i_mmap_lock);
+	mutex_unlock(&vma->vm_file->f_mapping->i_mmap_mutex);
 }
 
 /*
@@ -2310,7 +2310,7 @@ static int unmap_ref_private(struct mm_s
 	 * this mapping should be shared between all the VMAs,
 	 * __unmap_hugepage_range() is called as the lock is already held
 	 */
-	spin_lock(&mapping->i_mmap_lock);
+	mutex_lock(&mapping->i_mmap_mutex);
 	vma_prio_tree_foreach(iter_vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
 		/* Do not unmap the current VMA */
 		if (iter_vma == vma)
@@ -2328,7 +2328,7 @@ static int unmap_ref_private(struct mm_s
 				address, address + huge_page_size(h),
 				page);
 	}
-	spin_unlock(&mapping->i_mmap_lock);
+	mutex_unlock(&mapping->i_mmap_mutex);
 
 	return 1;
 }
@@ -2812,7 +2812,7 @@ void hugetlb_change_protection(struct vm
 	BUG_ON(address >= end);
 	flush_cache_range(vma, address, end);
 
-	spin_lock(&vma->vm_file->f_mapping->i_mmap_lock);
+	mutex_lock(&vma->vm_file->f_mapping->i_mmap_mutex);
 	spin_lock(&mm->page_table_lock);
 	for (; address < end; address += huge_page_size(h)) {
 		ptep = huge_pte_offset(mm, address);
@@ -2827,7 +2827,7 @@ void hugetlb_change_protection(struct vm
 		}
 	}
 	spin_unlock(&mm->page_table_lock);
-	spin_unlock(&vma->vm_file->f_mapping->i_mmap_lock);
+	mutex_unlock(&vma->vm_file->f_mapping->i_mmap_mutex);
 
 	flush_tlb_range(vma, start, end);
 }
Index: linux-2.6/mm/memory-failure.c
===================================================================
--- linux-2.6.orig/mm/memory-failure.c
+++ linux-2.6/mm/memory-failure.c
@@ -429,7 +429,7 @@ static void collect_procs_file(struct pa
 	 */
 
 	read_lock(&tasklist_lock);
-	spin_lock(&mapping->i_mmap_lock);
+	mutex_lock(&mapping->i_mmap_mutex);
 	for_each_process(tsk) {
 		pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
 
@@ -449,7 +449,7 @@ static void collect_procs_file(struct pa
 				add_to_kill(tsk, page, vma, to_kill, tkc);
 		}
 	}
-	spin_unlock(&mapping->i_mmap_lock);
+	mutex_unlock(&mapping->i_mmap_mutex);
 	read_unlock(&tasklist_lock);
 }
 
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -2588,12 +2588,12 @@ void unmap_mapping_range(struct address_
 	if (details.last_index < details.first_index)
 		details.last_index = ULONG_MAX;
 
-	spin_lock(&mapping->i_mmap_lock);
+	mutex_lock(&mapping->i_mmap_mutex);
 	if (unlikely(!prio_tree_empty(&mapping->i_mmap)))
 		unmap_mapping_range_tree(&mapping->i_mmap, &details);
 	if (unlikely(!list_empty(&mapping->i_mmap_nonlinear)))
 		unmap_mapping_range_list(&mapping->i_mmap_nonlinear, &details);
-	spin_unlock(&mapping->i_mmap_lock);
+	mutex_unlock(&mapping->i_mmap_mutex);
 }
 EXPORT_SYMBOL(unmap_mapping_range);
 
Index: linux-2.6/mm/mmap.c
===================================================================
--- linux-2.6.orig/mm/mmap.c
+++ linux-2.6/mm/mmap.c
@@ -190,7 +190,7 @@ int __vm_enough_memory(struct mm_struct 
 }
 
 /*
- * Requires inode->i_mapping->i_mmap_lock
+ * Requires inode->i_mapping->i_mmap_mutex
  */
 static void __remove_shared_vm_struct(struct vm_area_struct *vma,
 		struct file *file, struct address_space *mapping)
@@ -218,9 +218,9 @@ void unlink_file_vma(struct vm_area_stru
 
 	if (file) {
 		struct address_space *mapping = file->f_mapping;
-		spin_lock(&mapping->i_mmap_lock);
+		mutex_lock(&mapping->i_mmap_mutex);
 		__remove_shared_vm_struct(vma, file, mapping);
-		spin_unlock(&mapping->i_mmap_lock);
+		mutex_unlock(&mapping->i_mmap_mutex);
 	}
 }
 
@@ -465,13 +465,13 @@ static void vma_link(struct mm_struct *m
 		mapping = vma->vm_file->f_mapping;
 
 	if (mapping)
-		spin_lock(&mapping->i_mmap_lock);
+		mutex_lock(&mapping->i_mmap_mutex);
 
 	__vma_link(mm, vma, prev, rb_link, rb_parent);
 	__vma_link_file(vma);
 
 	if (mapping)
-		spin_unlock(&mapping->i_mmap_lock);
+		mutex_unlock(&mapping->i_mmap_mutex);
 
 	mm->map_count++;
 	validate_mm(mm);
@@ -574,7 +574,7 @@ again:			remove_next = 1 + (end > next->
 		mapping = file->f_mapping;
 		if (!(vma->vm_flags & VM_NONLINEAR))
 			root = &mapping->i_mmap;
-		spin_lock(&mapping->i_mmap_lock);
+		mutex_lock(&mapping->i_mmap_mutex);
 		if (insert) {
 			/*
 			 * Put into prio_tree now, so instantiated pages
@@ -641,7 +641,7 @@ again:			remove_next = 1 + (end > next->
 	if (anon_vma)
 		anon_vma_unlock(anon_vma);
 	if (mapping)
-		spin_unlock(&mapping->i_mmap_lock);
+		mutex_unlock(&mapping->i_mmap_mutex);
 
 	if (remove_next) {
 		if (file) {
@@ -2300,7 +2300,7 @@ void exit_mmap(struct mm_struct *mm)
 
 /* Insert vm structure into process list sorted by address
  * and into the inode's i_mmap tree.  If vm_file is non-NULL
- * then i_mmap_lock is taken here.
+ * then i_mmap_mutex is taken here.
  */
 int insert_vm_struct(struct mm_struct * mm, struct vm_area_struct * vma)
 {
@@ -2542,7 +2542,7 @@ static void vm_lock_mapping(struct mm_st
 		 */
 		if (test_and_set_bit(AS_MM_ALL_LOCKS, &mapping->flags))
 			BUG();
-		spin_lock_nest_lock(&mapping->i_mmap_lock, &mm->mmap_sem);
+		mutex_lock_nest_lock(&mapping->i_mmap_mutex, &mm->mmap_sem);
 	}
 }
 
@@ -2569,7 +2569,7 @@ static void vm_lock_mapping(struct mm_st
  * vma in this mm is backed by the same anon_vma or address_space.
  *
  * We can take all the locks in random order because the VM code
- * taking i_mmap_lock or anon_vma->lock outside the mmap_sem never
+ * taking i_mmap_mutex or anon_vma->lock outside the mmap_sem never
  * takes more than one of them in a row. Secondly we're protected
  * against a concurrent mm_take_all_locks() by the mm_all_locks_mutex.
  *
@@ -2641,7 +2641,7 @@ static void vm_unlock_mapping(struct add
 		 * AS_MM_ALL_LOCKS can't change to 0 from under us
 		 * because we hold the mm_all_locks_mutex.
 		 */
-		spin_unlock(&mapping->i_mmap_lock);
+		mutex_unlock(&mapping->i_mmap_mutex);
 		if (!test_and_clear_bit(AS_MM_ALL_LOCKS,
 					&mapping->flags))
 			BUG();
Index: linux-2.6/mm/mremap.c
===================================================================
--- linux-2.6.orig/mm/mremap.c
+++ linux-2.6/mm/mremap.c
@@ -93,7 +93,7 @@ static void move_ptes(struct vm_area_str
 		 * and we propagate stale pages into the dst afterward.
 		 */
 		mapping = vma->vm_file->f_mapping;
-		spin_lock(&mapping->i_mmap_lock);
+		mutex_lock(&mapping->i_mmap_mutex);
 	}
 
 	/*
@@ -122,7 +122,7 @@ static void move_ptes(struct vm_area_str
 	pte_unmap(new_pte - 1);
 	pte_unmap_unlock(old_pte - 1, old_ptl);
 	if (mapping)
-		spin_unlock(&mapping->i_mmap_lock);
+		mutex_unlock(&mapping->i_mmap_mutex);
 	mmu_notifier_invalidate_range_end(vma->vm_mm, old_start, old_end);
 }
 
Index: linux-2.6/mm/rmap.c
===================================================================
--- linux-2.6.orig/mm/rmap.c
+++ linux-2.6/mm/rmap.c
@@ -24,7 +24,7 @@
  *   inode->i_alloc_sem (vmtruncate_range)
  *   mm->mmap_sem
  *     page->flags PG_locked (lock_page)
- *       mapping->i_mmap_lock
+ *       mapping->i_mmap_mutex
  *         anon_vma->lock
  *           mm->page_table_lock or pte_lock
  *             zone->lru_lock (in mark_page_accessed, isolate_lru_page)
@@ -629,14 +629,14 @@ static int page_referenced_file(struct p
 	 * The page lock not only makes sure that page->mapping cannot
 	 * suddenly be NULLified by truncation, it makes sure that the
 	 * structure at mapping cannot be freed and reused yet,
-	 * so we can safely take mapping->i_mmap_lock.
+	 * so we can safely take mapping->i_mmap_mutex.
 	 */
 	BUG_ON(!PageLocked(page));
 
-	spin_lock(&mapping->i_mmap_lock);
+	mutex_lock(&mapping->i_mmap_mutex);
 
 	/*
-	 * i_mmap_lock does not stabilize mapcount at all, but mapcount
+	 * i_mmap_mutex does not stabilize mapcount at all, but mapcount
 	 * is more likely to be accurate if we note it after spinning.
 	 */
 	mapcount = page_mapcount(page);
@@ -658,7 +658,7 @@ static int page_referenced_file(struct p
 			break;
 	}
 
-	spin_unlock(&mapping->i_mmap_lock);
+	mutex_unlock(&mapping->i_mmap_mutex);
 	return referenced;
 }
 
@@ -745,7 +745,7 @@ static int page_mkclean_file(struct addr
 
 	BUG_ON(PageAnon(page));
 
-	spin_lock(&mapping->i_mmap_lock);
+	mutex_lock(&mapping->i_mmap_mutex);
 	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
 		if (vma->vm_flags & VM_SHARED) {
 			unsigned long address = vma_address(page, vma);
@@ -754,7 +754,7 @@ static int page_mkclean_file(struct addr
 			ret += page_mkclean_one(page, vma, address);
 		}
 	}
-	spin_unlock(&mapping->i_mmap_lock);
+	mutex_unlock(&mapping->i_mmap_mutex);
 	return ret;
 }
 
@@ -1105,7 +1105,7 @@ int try_to_unmap_one(struct page *page, 
 	/*
 	 * We need mmap_sem locking, Otherwise VM_LOCKED check makes
 	 * unstable result and race. Plus, We can't wait here because
-	 * we now hold anon_vma->lock or mapping->i_mmap_lock.
+	 * we now hold anon_vma->lock or mapping->i_mmap_mutex.
 	 * if trylock failed, the page remain in evictable lru and later
 	 * vmscan could retry to move the page to unevictable lru if the
 	 * page is actually mlocked.
@@ -1331,7 +1331,7 @@ static int try_to_unmap_file(struct page
 	unsigned long max_nl_size = 0;
 	unsigned int mapcount;
 
-	spin_lock(&mapping->i_mmap_lock);
+	mutex_lock(&mapping->i_mmap_mutex);
 	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
 		unsigned long address = vma_address(page, vma);
 		if (address == -EFAULT)
@@ -1377,7 +1377,7 @@ static int try_to_unmap_file(struct page
 	mapcount = page_mapcount(page);
 	if (!mapcount)
 		goto out;
-	cond_resched_lock(&mapping->i_mmap_lock);
+	cond_resched();
 
 	max_nl_size = (max_nl_size + CLUSTER_SIZE - 1) & CLUSTER_MASK;
 	if (max_nl_cursor == 0)
@@ -1399,7 +1399,7 @@ static int try_to_unmap_file(struct page
 			}
 			vma->vm_private_data = (void *) max_nl_cursor;
 		}
-		cond_resched_lock(&mapping->i_mmap_lock);
+		cond_resched();
 		max_nl_cursor += CLUSTER_SIZE;
 	} while (max_nl_cursor <= max_nl_size);
 
@@ -1411,7 +1411,7 @@ static int try_to_unmap_file(struct page
 	list_for_each_entry(vma, &mapping->i_mmap_nonlinear, shared.vm_set.list)
 		vma->vm_private_data = NULL;
 out:
-	spin_unlock(&mapping->i_mmap_lock);
+	mutex_unlock(&mapping->i_mmap_mutex);
 	return ret;
 }
 
@@ -1527,7 +1527,7 @@ static int rmap_walk_file(struct page *p
 
 	if (!mapping)
 		return ret;
-	spin_lock(&mapping->i_mmap_lock);
+	mutex_lock(&mapping->i_mmap_mutex);
 	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
 		unsigned long address = vma_address(page, vma);
 		if (address == -EFAULT)
@@ -1541,7 +1541,7 @@ static int rmap_walk_file(struct page *p
 	 * never contain migration ptes.  Decide what to do about this
 	 * limitation to linear when we need rmap_walk() on nonlinear.
 	 */
-	spin_unlock(&mapping->i_mmap_lock);
+	mutex_unlock(&mapping->i_mmap_mutex);
 	return ret;
 }
 
Index: linux-2.6/fs/gfs2/main.c
===================================================================
--- linux-2.6.orig/fs/gfs2/main.c
+++ linux-2.6/fs/gfs2/main.c
@@ -62,7 +62,7 @@ static void gfs2_init_gl_aspace_once(voi
 	memset(mapping, 0, sizeof(*mapping));
 	INIT_RADIX_TREE(&mapping->page_tree, GFP_ATOMIC);
 	spin_lock_init(&mapping->tree_lock);
-	spin_lock_init(&mapping->i_mmap_lock);
+	mutex_init(&mapping->i_mmap_mutex);
 	INIT_LIST_HEAD(&mapping->private_list);
 	spin_lock_init(&mapping->private_lock);
 	INIT_RAW_PRIO_TREE_ROOT(&mapping->i_mmap);
Index: linux-2.6/fs/nilfs2/page.c
===================================================================
--- linux-2.6.orig/fs/nilfs2/page.c
+++ linux-2.6/fs/nilfs2/page.c
@@ -500,7 +500,7 @@ void nilfs_mapping_init_once(struct addr
 	INIT_LIST_HEAD(&mapping->private_list);
 	spin_lock_init(&mapping->private_lock);
 
-	spin_lock_init(&mapping->i_mmap_lock);
+	mutex_init(&mapping->i_mmap_mutex);
 	INIT_RAW_PRIO_TREE_ROOT(&mapping->i_mmap);
 	INIT_LIST_HEAD(&mapping->i_mmap_nonlinear);
 }
Index: linux-2.6/Documentation/lockstat.txt
===================================================================
--- linux-2.6.orig/Documentation/lockstat.txt
+++ linux-2.6/Documentation/lockstat.txt
@@ -136,7 +136,7 @@ The integer part of the time values is i
                              dcache_lock:          1037           1161           0.38          45.32         774.51           6611         243371           0.15         306.48       77387.24
                          &inode->i_mutex:           161            286 18446744073709       62882.54     1244614.55           3653          20598 18446744073709       62318.60     1693822.74
                          &zone->lru_lock:            94             94           0.53           7.33          92.10           4366          32690           0.29          59.81       16350.06
-              &inode->i_data.i_mmap_lock:            79             79           0.40           3.77          53.03          11779          87755           0.28         116.93       29898.44
+              &inode->i_data.i_mmap_mutex:            79             79           0.40           3.77          53.03          11779          87755           0.28         116.93       29898.44
                         &q->__queue_lock:            48             50           0.52          31.62          86.31            774          13131           0.17         113.08       12277.52
                         &rq->rq_lock_key:            43             47           0.74          68.50         170.63           3706          33929           0.22         107.99       17460.62
                       &rq->rq_lock_key#2:            39             46           0.75           6.68          49.03           2979          32292           0.17         125.17       17137.63
Index: linux-2.6/Documentation/vm/locking
===================================================================
--- linux-2.6.orig/Documentation/vm/locking
+++ linux-2.6/Documentation/vm/locking
@@ -66,7 +66,7 @@ in some cases it is not really needed. E
 expand_stack(), it is hard to come up with a destructive scenario without 
 having the vmlist protection in this case.
 
-The page_table_lock nests with the inode i_mmap_lock and the kmem cache
+The page_table_lock nests with the inode i_mmap_mutex and the kmem cache
 c_spinlock spinlocks.  This is okay, since the kmem code asks for pages after
 dropping c_spinlock.  The page_table_lock also nests with pagecache_lock and
 pagemap_lru_lock spinlocks, and no code asks for memory with these locks
Index: linux-2.6/include/linux/mmu_notifier.h
===================================================================
--- linux-2.6.orig/include/linux/mmu_notifier.h
+++ linux-2.6/include/linux/mmu_notifier.h
@@ -150,7 +150,7 @@ struct mmu_notifier_ops {
  * Therefore notifier chains can only be traversed when either
  *
  * 1. mmap_sem is held.
- * 2. One of the reverse map locks is held (i_mmap_lock or anon_vma->lock).
+ * 2. One of the reverse map locks is held (i_mmap_mutex or anon_vma->lock).
  * 3. No other concurrent thread can access the list (release)
  */
 struct mmu_notifier {
Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c
+++ linux-2.6/mm/filemap.c
@@ -58,16 +58,16 @@
 /*
  * Lock ordering:
  *
- *  ->i_mmap_lock		(truncate_pagecache)
+ *  ->i_mmap_mutex		(truncate_pagecache)
  *    ->private_lock		(__free_pte->__set_page_dirty_buffers)
  *      ->swap_lock		(exclusive_swap_page, others)
  *        ->mapping->tree_lock
  *
  *  ->i_mutex
- *    ->i_mmap_lock		(truncate->unmap_mapping_range)
+ *    ->i_mmap_mutex		(truncate->unmap_mapping_range)
  *
  *  ->mmap_sem
- *    ->i_mmap_lock
+ *    ->i_mmap_mutex
  *      ->page_table_lock or pte_lock	(various, mainly in memory.c)
  *        ->mapping->tree_lock	(arch-dependent flush_dcache_mmap_lock)
  *
@@ -84,7 +84,7 @@
  *    ->sb_lock			(fs/fs-writeback.c)
  *    ->mapping->tree_lock	(__sync_single_inode)
  *
- *  ->i_mmap_lock
+ *  ->i_mmap_mutex
  *    ->anon_vma.lock		(vma_adjust)
  *
  *  ->anon_vma.lock
@@ -104,7 +104,7 @@
  *
  *  (code doesn't rely on that order, so you could switch it around)
  *  ->tasklist_lock             (memory_failure, collect_procs_ao)
- *    ->i_mmap_lock
+ *    ->i_mmap_mutex
  */
 
 /*


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
