Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id B0C278D0001
	for <linux-mm@kvack.org>; Fri, 26 Nov 2010 10:01:20 -0500 (EST)
Message-Id: <20101126145411.331356698@chello.nl>
Date: Fri, 26 Nov 2010 15:39:02 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 19/21] mm: Convert i_mmap_lock and anon_vma->lock to mutexes
References: <20101126143843.801484792@chello.nl>
Content-Disposition: inline; filename=mm-mutex.patch
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>
List-ID: <linux-mm.kvack.org>

Straight fwd conversion of i_mmap_lock and anon_vma->lock to mutexes.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 arch/x86/mm/hugetlbpage.c |    4 ++--
 fs/gfs2/main.c            |    2 +-
 fs/hugetlbfs/inode.c      |    4 ++--
 fs/inode.c                |    2 +-
 fs/nilfs2/page.c          |    2 +-
 include/linux/fs.h        |    2 +-
 include/linux/mm.h        |    2 +-
 include/linux/rmap.h      |   12 ++++++------
 kernel/fork.c             |    4 ++--
 mm/filemap_xip.c          |    4 ++--
 mm/fremap.c               |    4 ++--
 mm/hugetlb.c              |   12 ++++++------
 mm/memory-failure.c       |    4 ++--
 mm/memory.c               |   14 +++++++-------
 mm/migrate.c              |    4 ++--
 mm/mmap.c                 |   18 +++++++++---------
 mm/mremap.c               |    4 ++--
 mm/rmap.c                 |   22 +++++++++++-----------
 18 files changed, 60 insertions(+), 60 deletions(-)

Index: linux-2.6/arch/x86/mm/hugetlbpage.c
===================================================================
--- linux-2.6.orig/arch/x86/mm/hugetlbpage.c
+++ linux-2.6/arch/x86/mm/hugetlbpage.c
@@ -72,7 +72,7 @@ static void huge_pmd_share(struct mm_str
 	if (!vma_shareable(vma, addr))
 		return;
 
-	spin_lock(&mapping->i_mmap_lock);
+	mutex_lock(&mapping->i_mmap_lock);
 	vma_prio_tree_foreach(svma, &iter, &mapping->i_mmap, idx, idx) {
 		if (svma == vma)
 			continue;
@@ -97,7 +97,7 @@ static void huge_pmd_share(struct mm_str
 		put_page(virt_to_page(spte));
 	spin_unlock(&mm->page_table_lock);
 out:
-	spin_unlock(&mapping->i_mmap_lock);
+	mutex_unlock(&mapping->i_mmap_lock);
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
+	mutex_lock(&mapping->i_mmap_lock);
 	if (!prio_tree_empty(&mapping->i_mmap))
 		hugetlb_vmtruncate_list(&mapping->i_mmap, pgoff);
-	spin_unlock(&mapping->i_mmap_lock);
+	mutex_unlock(&mapping->i_mmap_lock);
 	truncate_hugepages(inode, offset);
 	return 0;
 }
Index: linux-2.6/fs/inode.c
===================================================================
--- linux-2.6.orig/fs/inode.c
+++ linux-2.6/fs/inode.c
@@ -295,7 +295,7 @@ void inode_init_once(struct inode *inode
 	INIT_LIST_HEAD(&inode->i_lru);
 	INIT_RADIX_TREE(&inode->i_data.page_tree, GFP_ATOMIC);
 	spin_lock_init(&inode->i_data.tree_lock);
-	spin_lock_init(&inode->i_data.i_mmap_lock);
+	mutex_init(&inode->i_data.i_mmap_lock);
 	INIT_LIST_HEAD(&inode->i_data.private_list);
 	spin_lock_init(&inode->i_data.private_lock);
 	INIT_RAW_PRIO_TREE_ROOT(&inode->i_data.i_mmap);
Index: linux-2.6/include/linux/fs.h
===================================================================
--- linux-2.6.orig/include/linux/fs.h
+++ linux-2.6/include/linux/fs.h
@@ -635,7 +635,7 @@ struct address_space {
 	unsigned int		i_mmap_writable;/* count VM_SHARED mappings */
 	struct prio_tree_root	i_mmap;		/* tree of private and shared mappings */
 	struct list_head	i_mmap_nonlinear;/*list VM_NONLINEAR mappings */
-	spinlock_t		i_mmap_lock;	/* protect tree, count, list */
+	struct mutex		i_mmap_lock;	/* protect tree, count, list */
 	unsigned int		truncate_count;	/* Cover race condition with truncate */
 	unsigned long		nrpages;	/* number of total pages */
 	pgoff_t			writeback_index;/* writeback starts here */
Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h
+++ linux-2.6/include/linux/mm.h
@@ -768,7 +768,7 @@ struct zap_details {
 	struct address_space *check_mapping;	/* Check page->mapping if set */
 	pgoff_t	first_index;			/* Lowest page->index to unmap */
 	pgoff_t last_index;			/* Highest page->index to unmap */
-	spinlock_t *i_mmap_lock;		/* For unmap_mapping_range: */
+	struct mutex *i_mmap_lock;		/* For unmap_mapping_range: */
 	unsigned long truncate_count;		/* Compare vm_truncate_count */
 };
 
Index: linux-2.6/include/linux/rmap.h
===================================================================
--- linux-2.6.orig/include/linux/rmap.h
+++ linux-2.6/include/linux/rmap.h
@@ -7,7 +7,7 @@
 #include <linux/list.h>
 #include <linux/slab.h>
 #include <linux/mm.h>
-#include <linux/spinlock.h>
+#include <linux/mutex.h>
 #include <linux/memcontrol.h>
 
 /*
@@ -26,7 +26,7 @@
  */
 struct anon_vma {
 	struct anon_vma *root;	/* Root of this anon_vma tree */
-	spinlock_t lock;	/* Serialize access to vma list */
+	struct mutex lock;	/* Serialize access to vma list */
 	/*
 	 * The refcount is taken on an anon_vma when there is no
 	 * guarantee that the vma of page tables will exist for
@@ -93,24 +93,24 @@ static inline void vma_lock_anon_vma(str
 {
 	struct anon_vma *anon_vma = vma->anon_vma;
 	if (anon_vma)
-		spin_lock(&anon_vma->root->lock);
+		mutex_lock(&anon_vma->root->lock);
 }
 
 static inline void vma_unlock_anon_vma(struct vm_area_struct *vma)
 {
 	struct anon_vma *anon_vma = vma->anon_vma;
 	if (anon_vma)
-		spin_unlock(&anon_vma->root->lock);
+		mutex_unlock(&anon_vma->root->lock);
 }
 
 static inline void anon_vma_lock(struct anon_vma *anon_vma)
 {
-	spin_lock(&anon_vma->root->lock);
+	mutex_lock(&anon_vma->root->lock);
 }
 
 static inline void anon_vma_unlock(struct anon_vma *anon_vma)
 {
-	spin_unlock(&anon_vma->root->lock);
+	mutex_unlock(&anon_vma->root->lock);
 }
 
 /*
Index: linux-2.6/kernel/fork.c
===================================================================
--- linux-2.6.orig/kernel/fork.c
+++ linux-2.6/kernel/fork.c
@@ -370,7 +370,7 @@ static int dup_mmap(struct mm_struct *mm
 			get_file(file);
 			if (tmp->vm_flags & VM_DENYWRITE)
 				atomic_dec(&inode->i_writecount);
-			spin_lock(&mapping->i_mmap_lock);
+			mutex_lock(&mapping->i_mmap_lock);
 			if (tmp->vm_flags & VM_SHARED)
 				mapping->i_mmap_writable++;
 			tmp->vm_truncate_count = mpnt->vm_truncate_count;
@@ -378,7 +378,7 @@ static int dup_mmap(struct mm_struct *mm
 			/* insert tmp into the share list, just after mpnt */
 			vma_prio_tree_add(tmp, mpnt);
 			flush_dcache_mmap_unlock(mapping);
-			spin_unlock(&mapping->i_mmap_lock);
+			mutex_unlock(&mapping->i_mmap_lock);
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
+	mutex_lock(&mapping->i_mmap_lock);
 	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
 		mm = vma->vm_mm;
 		address = vma->vm_start +
@@ -201,7 +201,7 @@ __xip_unmap (struct address_space * mapp
 			page_cache_release(page);
 		}
 	}
-	spin_unlock(&mapping->i_mmap_lock);
+	mutex_unlock(&mapping->i_mmap_lock);
 
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
+		mutex_lock(&mapping->i_mmap_lock);
 		flush_dcache_mmap_lock(mapping);
 		vma->vm_flags |= VM_NONLINEAR;
 		vma_prio_tree_remove(vma, &mapping->i_mmap);
 		vma_nonlinear_insert(vma, &mapping->i_mmap_nonlinear);
 		flush_dcache_mmap_unlock(mapping);
-		spin_unlock(&mapping->i_mmap_lock);
+		mutex_unlock(&mapping->i_mmap_lock);
 	}
 
 	if (vma->vm_flags & VM_LOCKED) {
Index: linux-2.6/mm/hugetlb.c
===================================================================
--- linux-2.6.orig/mm/hugetlb.c
+++ linux-2.6/mm/hugetlb.c
@@ -2316,9 +2316,9 @@ void __unmap_hugepage_range(struct vm_ar
 void unmap_hugepage_range(struct vm_area_struct *vma, unsigned long start,
 			  unsigned long end, struct page *ref_page)
 {
-	spin_lock(&vma->vm_file->f_mapping->i_mmap_lock);
+	mutex_lock(&vma->vm_file->f_mapping->i_mmap_lock);
 	__unmap_hugepage_range(vma, start, end, ref_page);
-	spin_unlock(&vma->vm_file->f_mapping->i_mmap_lock);
+	mutex_unlock(&vma->vm_file->f_mapping->i_mmap_lock);
 }
 
 /*
@@ -2350,7 +2350,7 @@ static int unmap_ref_private(struct mm_s
 	 * this mapping should be shared between all the VMAs,
 	 * __unmap_hugepage_range() is called as the lock is already held
 	 */
-	spin_lock(&mapping->i_mmap_lock);
+	mutex_lock(&mapping->i_mmap_lock);
 	vma_prio_tree_foreach(iter_vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
 		/* Do not unmap the current VMA */
 		if (iter_vma == vma)
@@ -2368,7 +2368,7 @@ static int unmap_ref_private(struct mm_s
 				address, address + huge_page_size(h),
 				page);
 	}
-	spin_unlock(&mapping->i_mmap_lock);
+	mutex_unlock(&mapping->i_mmap_lock);
 
 	return 1;
 }
@@ -2850,7 +2850,7 @@ void hugetlb_change_protection(struct vm
 	BUG_ON(address >= end);
 	flush_cache_range(vma, address, end);
 
-	spin_lock(&vma->vm_file->f_mapping->i_mmap_lock);
+	mutex_lock(&vma->vm_file->f_mapping->i_mmap_lock);
 	spin_lock(&mm->page_table_lock);
 	for (; address < end; address += huge_page_size(h)) {
 		ptep = huge_pte_offset(mm, address);
@@ -2865,7 +2865,7 @@ void hugetlb_change_protection(struct vm
 		}
 	}
 	spin_unlock(&mm->page_table_lock);
-	spin_unlock(&vma->vm_file->f_mapping->i_mmap_lock);
+	mutex_unlock(&vma->vm_file->f_mapping->i_mmap_lock);
 
 	flush_tlb_range(vma, start, end);
 }
Index: linux-2.6/mm/memory-failure.c
===================================================================
--- linux-2.6.orig/mm/memory-failure.c
+++ linux-2.6/mm/memory-failure.c
@@ -428,7 +428,7 @@ static void collect_procs_file(struct pa
 	 */
 
 	read_lock(&tasklist_lock);
-	spin_lock(&mapping->i_mmap_lock);
+	mutex_lock(&mapping->i_mmap_lock);
 	for_each_process(tsk) {
 		pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
 
@@ -448,7 +448,7 @@ static void collect_procs_file(struct pa
 				add_to_kill(tsk, page, vma, to_kill, tkc);
 		}
 	}
-	spin_unlock(&mapping->i_mmap_lock);
+	mutex_unlock(&mapping->i_mmap_lock);
 	read_unlock(&tasklist_lock);
 }
 
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -1177,7 +1177,7 @@ unsigned long unmap_vmas(struct mmu_gath
 {
 	long zap_work = ZAP_BLOCK_SIZE;
 	unsigned long start = start_addr;
-	spinlock_t *i_mmap_lock = details? details->i_mmap_lock: NULL;
+	struct mutex *i_mmap_lock = details ? details->i_mmap_lock : NULL;
 	struct mm_struct *mm = vma->vm_mm;
 
 	mmu_notifier_invalidate_range_start(mm, start_addr, end_addr);
@@ -1227,7 +1227,7 @@ unsigned long unmap_vmas(struct mmu_gath
 			}
 
 			if (need_resched() ||
-				(i_mmap_lock && spin_needbreak(i_mmap_lock))) {
+				(i_mmap_lock && mutex_is_contended(i_mmap_lock))) {
 				if (i_mmap_lock)
 					goto out;
 				cond_resched();
@@ -2522,7 +2522,7 @@ static int unmap_mapping_range_vma(struc
 
 	restart_addr = zap_page_range(vma, start_addr,
 					end_addr - start_addr, details);
-	need_break = need_resched() || spin_needbreak(details->i_mmap_lock);
+	need_break = need_resched() || mutex_is_contended(details->i_mmap_lock);
 
 	if (restart_addr >= end_addr) {
 		/* We have now completed this vma: mark it so */
@@ -2536,9 +2536,9 @@ static int unmap_mapping_range_vma(struc
 			goto again;
 	}
 
-	spin_unlock(details->i_mmap_lock);
+	mutex_unlock(details->i_mmap_lock);
 	cond_resched();
-	spin_lock(details->i_mmap_lock);
+	mutex_lock(details->i_mmap_lock);
 	return -EINTR;
 }
 
@@ -2634,7 +2634,7 @@ void unmap_mapping_range(struct address_
 		details.last_index = ULONG_MAX;
 	details.i_mmap_lock = &mapping->i_mmap_lock;
 
-	spin_lock(&mapping->i_mmap_lock);
+	mutex_lock(&mapping->i_mmap_lock);
 
 	/* Protect against endless unmapping loops */
 	mapping->truncate_count++;
@@ -2649,7 +2649,7 @@ void unmap_mapping_range(struct address_
 		unmap_mapping_range_tree(&mapping->i_mmap, &details);
 	if (unlikely(!list_empty(&mapping->i_mmap_nonlinear)))
 		unmap_mapping_range_list(&mapping->i_mmap_nonlinear, &details);
-	spin_unlock(&mapping->i_mmap_lock);
+	mutex_unlock(&mapping->i_mmap_lock);
 }
 EXPORT_SYMBOL(unmap_mapping_range);
 
Index: linux-2.6/mm/mmap.c
===================================================================
--- linux-2.6.orig/mm/mmap.c
+++ linux-2.6/mm/mmap.c
@@ -217,9 +217,9 @@ void unlink_file_vma(struct vm_area_stru
 
 	if (file) {
 		struct address_space *mapping = file->f_mapping;
-		spin_lock(&mapping->i_mmap_lock);
+		mutex_lock(&mapping->i_mmap_lock);
 		__remove_shared_vm_struct(vma, file, mapping);
-		spin_unlock(&mapping->i_mmap_lock);
+		mutex_unlock(&mapping->i_mmap_lock);
 	}
 }
 
@@ -456,7 +456,7 @@ static void vma_link(struct mm_struct *m
 		mapping = vma->vm_file->f_mapping;
 
 	if (mapping) {
-		spin_lock(&mapping->i_mmap_lock);
+		mutex_lock(&mapping->i_mmap_lock);
 		vma->vm_truncate_count = mapping->truncate_count;
 	}
 
@@ -464,7 +464,7 @@ static void vma_link(struct mm_struct *m
 	__vma_link_file(vma);
 
 	if (mapping)
-		spin_unlock(&mapping->i_mmap_lock);
+		mutex_unlock(&mapping->i_mmap_lock);
 
 	mm->map_count++;
 	validate_mm(mm);
@@ -567,7 +567,7 @@ again:			remove_next = 1 + (end > next->
 		mapping = file->f_mapping;
 		if (!(vma->vm_flags & VM_NONLINEAR))
 			root = &mapping->i_mmap;
-		spin_lock(&mapping->i_mmap_lock);
+		mutex_lock(&mapping->i_mmap_lock);
 		if (importer &&
 		    vma->vm_truncate_count != next->vm_truncate_count) {
 			/*
@@ -641,7 +641,7 @@ again:			remove_next = 1 + (end > next->
 	if (anon_vma)
 		anon_vma_unlock(anon_vma);
 	if (mapping)
-		spin_unlock(&mapping->i_mmap_lock);
+		mutex_unlock(&mapping->i_mmap_lock);
 
 	if (remove_next) {
 		if (file) {
@@ -2500,7 +2500,7 @@ static void vm_lock_anon_vma(struct mm_s
 		 * The LSB of head.next can't change from under us
 		 * because we hold the mm_all_locks_mutex.
 		 */
-		spin_lock_nest_lock(&anon_vma->root->lock, &mm->mmap_sem);
+		mutex_lock_nest_lock(&anon_vma->root->lock, &mm->mmap_sem);
 		/*
 		 * We can safely modify head.next after taking the
 		 * anon_vma->root->lock. If some other vma in this mm shares
@@ -2530,7 +2530,7 @@ static void vm_lock_mapping(struct mm_st
 		 */
 		if (test_and_set_bit(AS_MM_ALL_LOCKS, &mapping->flags))
 			BUG();
-		spin_lock_nest_lock(&mapping->i_mmap_lock, &mm->mmap_sem);
+		mutex_lock_nest_lock(&mapping->i_mmap_lock, &mm->mmap_sem);
 	}
 }
 
@@ -2629,7 +2629,7 @@ static void vm_unlock_mapping(struct add
 		 * AS_MM_ALL_LOCKS can't change to 0 from under us
 		 * because we hold the mm_all_locks_mutex.
 		 */
-		spin_unlock(&mapping->i_mmap_lock);
+		mutex_unlock(&mapping->i_mmap_lock);
 		if (!test_and_clear_bit(AS_MM_ALL_LOCKS,
 					&mapping->flags))
 			BUG();
Index: linux-2.6/mm/mremap.c
===================================================================
--- linux-2.6.orig/mm/mremap.c
+++ linux-2.6/mm/mremap.c
@@ -90,7 +90,7 @@ static void move_ptes(struct vm_area_str
 		 * and we propagate stale pages into the dst afterward.
 		 */
 		mapping = vma->vm_file->f_mapping;
-		spin_lock(&mapping->i_mmap_lock);
+		mutex_lock(&mapping->i_mmap_lock);
 		if (new_vma->vm_truncate_count &&
 		    new_vma->vm_truncate_count != vma->vm_truncate_count)
 			new_vma->vm_truncate_count = 0;
@@ -122,7 +122,7 @@ static void move_ptes(struct vm_area_str
 	pte_unmap(new_pte - 1);
 	pte_unmap_unlock(old_pte - 1, old_ptl);
 	if (mapping)
-		spin_unlock(&mapping->i_mmap_lock);
+		mutex_unlock(&mapping->i_mmap_lock);
 	mmu_notifier_invalidate_range_end(vma->vm_mm, old_start, old_end);
 }
 
Index: linux-2.6/mm/rmap.c
===================================================================
--- linux-2.6.orig/mm/rmap.c
+++ linux-2.6/mm/rmap.c
@@ -302,7 +302,7 @@ static void anon_vma_ctor(void *data)
 {
 	struct anon_vma *anon_vma = data;
 
-	spin_lock_init(&anon_vma->lock);
+	mutex_init(&anon_vma->lock);
 	atomic_set(&anon_vma->refcount, 0);
 	INIT_LIST_HEAD(&anon_vma->head);
 }
@@ -641,7 +641,7 @@ static int page_referenced_file(struct p
 	 */
 	BUG_ON(!PageLocked(page));
 
-	spin_lock(&mapping->i_mmap_lock);
+	mutex_lock(&mapping->i_mmap_lock);
 
 	/*
 	 * i_mmap_lock does not stabilize mapcount at all, but mapcount
@@ -666,7 +666,7 @@ static int page_referenced_file(struct p
 			break;
 	}
 
-	spin_unlock(&mapping->i_mmap_lock);
+	mutex_unlock(&mapping->i_mmap_lock);
 	return referenced;
 }
 
@@ -753,7 +753,7 @@ static int page_mkclean_file(struct addr
 
 	BUG_ON(PageAnon(page));
 
-	spin_lock(&mapping->i_mmap_lock);
+	mutex_lock(&mapping->i_mmap_lock);
 	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
 		if (vma->vm_flags & VM_SHARED) {
 			unsigned long address = vma_address(page, vma);
@@ -762,7 +762,7 @@ static int page_mkclean_file(struct addr
 			ret += page_mkclean_one(page, vma, address);
 		}
 	}
-	spin_unlock(&mapping->i_mmap_lock);
+	mutex_unlock(&mapping->i_mmap_lock);
 	return ret;
 }
 
@@ -1327,7 +1327,7 @@ static int try_to_unmap_file(struct page
 	unsigned long max_nl_size = 0;
 	unsigned int mapcount;
 
-	spin_lock(&mapping->i_mmap_lock);
+	mutex_lock(&mapping->i_mmap_lock);
 	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
 		unsigned long address = vma_address(page, vma);
 		if (address == -EFAULT)
@@ -1373,7 +1373,7 @@ static int try_to_unmap_file(struct page
 	mapcount = page_mapcount(page);
 	if (!mapcount)
 		goto out;
-	cond_resched_lock(&mapping->i_mmap_lock);
+	cond_resched();
 
 	max_nl_size = (max_nl_size + CLUSTER_SIZE - 1) & CLUSTER_MASK;
 	if (max_nl_cursor == 0)
@@ -1395,7 +1395,7 @@ static int try_to_unmap_file(struct page
 			}
 			vma->vm_private_data = (void *) max_nl_cursor;
 		}
-		cond_resched_lock(&mapping->i_mmap_lock);
+		cond_resched();
 		max_nl_cursor += CLUSTER_SIZE;
 	} while (max_nl_cursor <= max_nl_size);
 
@@ -1407,7 +1407,7 @@ static int try_to_unmap_file(struct page
 	list_for_each_entry(vma, &mapping->i_mmap_nonlinear, shared.vm_set.list)
 		vma->vm_private_data = NULL;
 out:
-	spin_unlock(&mapping->i_mmap_lock);
+	mutex_unlock(&mapping->i_mmap_lock);
 	return ret;
 }
 
@@ -1522,7 +1522,7 @@ static int rmap_walk_file(struct page *p
 
 	if (!mapping)
 		return ret;
-	spin_lock(&mapping->i_mmap_lock);
+	mutex_lock(&mapping->i_mmap_lock);
 	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
 		unsigned long address = vma_address(page, vma);
 		if (address == -EFAULT)
@@ -1536,7 +1536,7 @@ static int rmap_walk_file(struct page *p
 	 * never contain migration ptes.  Decide what to do about this
 	 * limitation to linear when we need rmap_walk() on nonlinear.
 	 */
-	spin_unlock(&mapping->i_mmap_lock);
+	mutex_unlock(&mapping->i_mmap_lock);
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
+	mutex_init(&mapping->i_mmap_lock);
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
+	mutex_init(&mapping->i_mmap_lock);
 	INIT_RAW_PRIO_TREE_ROOT(&mapping->i_mmap);
 	INIT_LIST_HEAD(&mapping->i_mmap_nonlinear);
 }
Index: linux-2.6/mm/migrate.c
===================================================================
--- linux-2.6.orig/mm/migrate.c
+++ linux-2.6/mm/migrate.c
@@ -845,10 +845,10 @@ static int unmap_and_move_huge_page(new_
 	if (rc)
 		remove_migration_ptes(hpage, hpage);
 
-	if (anon_vma && atomic_dec_and_lock(&anon_vma->refcount,
+	if (anon_vma && atomic_dec_and_mutex_lock(&anon_vma->refcount,
 					    &anon_vma->lock)) {
 		int empty = list_empty(&anon_vma->head);
-		spin_unlock(&anon_vma->lock);
+		mutex_unlock(&anon_vma->lock);
 		if (empty)
 			put_anon_vma(anon_vma);
 	}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
