Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id ED0946B0072
	for <linux-mm@kvack.org>; Wed, 24 Dec 2014 07:23:13 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id kq14so10001708pab.40
        for <linux-mm@kvack.org>; Wed, 24 Dec 2014 04:23:13 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id mm8si17586481pbc.198.2014.12.24.04.23.04
        for <linux-mm@kvack.org>;
        Wed, 24 Dec 2014 04:23:05 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 05/38] rmap: drop support of non-linear mappings
Date: Wed, 24 Dec 2014 14:22:13 +0200
Message-Id: <1419423766-114457-6-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: peterz@infradead.org, mingo@kernel.org, davej@redhat.com, sasha.levin@oracle.com, hughd@google.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We don't create non-linear mappings anymore. Let's drop code which
handles them in rmap.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 Documentation/cachetlb.txt |   8 +-
 fs/inode.c                 |   1 -
 include/linux/fs.h         |   4 +-
 include/linux/mm.h         |   6 --
 include/linux/mm_types.h   |   4 +-
 include/linux/rmap.h       |   2 -
 kernel/fork.c              |   8 +-
 mm/migrate.c               |  32 -------
 mm/mmap.c                  |  24 ++---
 mm/rmap.c                  | 225 +--------------------------------------------
 mm/swap.c                  |   4 +-
 11 files changed, 18 insertions(+), 300 deletions(-)

diff --git a/Documentation/cachetlb.txt b/Documentation/cachetlb.txt
index d79b008e4a32..3f9f808b5119 100644
--- a/Documentation/cachetlb.txt
+++ b/Documentation/cachetlb.txt
@@ -317,10 +317,10 @@ maps this page at its virtual address.
 	about doing this.
 
 	The idea is, first at flush_dcache_page() time, if
-	page->mapping->i_mmap is an empty tree and ->i_mmap_nonlinear
-	an empty list, just mark the architecture private page flag bit.
-	Later, in update_mmu_cache(), a check is made of this flag bit,
-	and if set the flush is done and the flag bit is cleared.
+	page->mapping->i_mmap is an empty tree, just mark the architecture
+	private page flag bit.  Later, in update_mmu_cache(), a check is
+	made of this flag bit, and if set the flush is done and the flag
+	bit is cleared.
 
 	IMPORTANT NOTE: It is often important, if you defer the flush,
 			that the actual flush occurs on the same CPU
diff --git a/fs/inode.c b/fs/inode.c
index aa149e7262ac..c760fac33c92 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -355,7 +355,6 @@ void address_space_init_once(struct address_space *mapping)
 	INIT_LIST_HEAD(&mapping->private_list);
 	spin_lock_init(&mapping->private_lock);
 	mapping->i_mmap = RB_ROOT;
-	INIT_LIST_HEAD(&mapping->i_mmap_nonlinear);
 }
 EXPORT_SYMBOL(address_space_init_once);
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 84b661f7a5ba..cbe3b73b4fab 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -401,7 +401,6 @@ struct address_space {
 	spinlock_t		tree_lock;	/* and lock protecting it */
 	atomic_t		i_mmap_writable;/* count VM_SHARED mappings */
 	struct rb_root		i_mmap;		/* tree of private and shared mappings */
-	struct list_head	i_mmap_nonlinear;/*list VM_NONLINEAR mappings */
 	struct rw_semaphore	i_mmap_rwsem;	/* protect tree, count, list */
 	/* Protected by tree_lock together with the radix tree */
 	unsigned long		nrpages;	/* number of total pages */
@@ -493,8 +492,7 @@ static inline void i_mmap_unlock_read(struct address_space *mapping)
  */
 static inline int mapping_mapped(struct address_space *mapping)
 {
-	return	!RB_EMPTY_ROOT(&mapping->i_mmap) ||
-		!list_empty(&mapping->i_mmap_nonlinear);
+	return	!RB_EMPTY_ROOT(&mapping->i_mmap);
 }
 
 /*
diff --git a/include/linux/mm.h b/include/linux/mm.h
index c6338ab35dc6..6840c0dc8a06 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1769,12 +1769,6 @@ struct vm_area_struct *vma_interval_tree_iter_next(struct vm_area_struct *node,
 	for (vma = vma_interval_tree_iter_first(root, start, last);	\
 	     vma; vma = vma_interval_tree_iter_next(vma, start, last))
 
-static inline void vma_nonlinear_insert(struct vm_area_struct *vma,
-					struct list_head *list)
-{
-	list_add_tail(&vma->shared.nonlinear, list);
-}
-
 void anon_vma_interval_tree_insert(struct anon_vma_chain *node,
 				   struct rb_root *root);
 void anon_vma_interval_tree_remove(struct anon_vma_chain *node,
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 6d34aa266a8c..3b1d20fb0848 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -273,15 +273,13 @@ struct vm_area_struct {
 
 	/*
 	 * For areas with an address space and backing store,
-	 * linkage into the address_space->i_mmap interval tree, or
-	 * linkage of vma in the address_space->i_mmap_nonlinear list.
+	 * linkage into the address_space->i_mmap interval tree.
 	 */
 	union {
 		struct {
 			struct rb_node rb;
 			unsigned long rb_subtree_last;
 		} linear;
-		struct list_head nonlinear;
 	} shared;
 
 	/*
diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 94d5bcacc83e..7d79d9b56a71 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -238,7 +238,6 @@ int page_mapped_in_vma(struct page *page, struct vm_area_struct *vma);
  * arg: passed to rmap_one() and invalid_vma()
  * rmap_one: executed on each vma where page is mapped
  * done: for checking traversing termination condition
- * file_nonlinear: for handling file nonlinear mapping
  * anon_lock: for getting anon_lock by optimized way rather than default
  * invalid_vma: for skipping uninterested vma
  */
@@ -247,7 +246,6 @@ struct rmap_walk_control {
 	int (*rmap_one)(struct page *page, struct vm_area_struct *vma,
 					unsigned long addr, void *arg);
 	int (*done)(struct page *page);
-	int (*file_nonlinear)(struct page *, struct address_space *, void *arg);
 	struct anon_vma *(*anon_lock)(struct page *page);
 	bool (*invalid_vma)(struct vm_area_struct *vma, void *arg);
 };
diff --git a/kernel/fork.c b/kernel/fork.c
index 4dc2ddade9f1..b379d9abddc7 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -438,12 +438,8 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 				atomic_inc(&mapping->i_mmap_writable);
 			flush_dcache_mmap_lock(mapping);
 			/* insert tmp into the share list, just after mpnt */
-			if (unlikely(tmp->vm_flags & VM_NONLINEAR))
-				vma_nonlinear_insert(tmp,
-						&mapping->i_mmap_nonlinear);
-			else
-				vma_interval_tree_insert_after(tmp, mpnt,
-							&mapping->i_mmap);
+			vma_interval_tree_insert_after(tmp, mpnt,
+					&mapping->i_mmap);
 			flush_dcache_mmap_unlock(mapping);
 			i_mmap_unlock_write(mapping);
 		}
diff --git a/mm/migrate.c b/mm/migrate.c
index 344cdf692fc8..6e284bcca8bb 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -179,37 +179,6 @@ out:
 }
 
 /*
- * Congratulations to trinity for discovering this bug.
- * mm/fremap.c's remap_file_pages() accepts any range within a single vma to
- * convert that vma to VM_NONLINEAR; and generic_file_remap_pages() will then
- * replace the specified range by file ptes throughout (maybe populated after).
- * If page migration finds a page within that range, while it's still located
- * by vma_interval_tree rather than lost to i_mmap_nonlinear list, no problem:
- * zap_pte() clears the temporary migration entry before mmap_sem is dropped.
- * But if the migrating page is in a part of the vma outside the range to be
- * remapped, then it will not be cleared, and remove_migration_ptes() needs to
- * deal with it.  Fortunately, this part of the vma is of course still linear,
- * so we just need to use linear location on the nonlinear list.
- */
-static int remove_linear_migration_ptes_from_nonlinear(struct page *page,
-		struct address_space *mapping, void *arg)
-{
-	struct vm_area_struct *vma;
-	/* hugetlbfs does not support remap_pages, so no huge pgoff worries */
-	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
-	unsigned long addr;
-
-	list_for_each_entry(vma,
-		&mapping->i_mmap_nonlinear, shared.nonlinear) {
-
-		addr = vma->vm_start + ((pgoff - vma->vm_pgoff) << PAGE_SHIFT);
-		if (addr >= vma->vm_start && addr < vma->vm_end)
-			remove_migration_pte(page, vma, addr, arg);
-	}
-	return SWAP_AGAIN;
-}
-
-/*
  * Get rid of all migration entries and replace them by
  * references to the indicated page.
  */
@@ -218,7 +187,6 @@ static void remove_migration_ptes(struct page *old, struct page *new)
 	struct rmap_walk_control rwc = {
 		.rmap_one = remove_migration_pte,
 		.arg = old,
-		.file_nonlinear = remove_linear_migration_ptes_from_nonlinear,
 	};
 
 	rmap_walk(new, &rwc);
diff --git a/mm/mmap.c b/mm/mmap.c
index e996cfd802bb..e58a3b453a2a 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -243,10 +243,7 @@ static void __remove_shared_vm_struct(struct vm_area_struct *vma,
 		mapping_unmap_writable(mapping);
 
 	flush_dcache_mmap_lock(mapping);
-	if (unlikely(vma->vm_flags & VM_NONLINEAR))
-		list_del_init(&vma->shared.nonlinear);
-	else
-		vma_interval_tree_remove(vma, &mapping->i_mmap);
+	vma_interval_tree_remove(vma, &mapping->i_mmap);
 	flush_dcache_mmap_unlock(mapping);
 }
 
@@ -649,10 +646,7 @@ static void __vma_link_file(struct vm_area_struct *vma)
 			atomic_inc(&mapping->i_mmap_writable);
 
 		flush_dcache_mmap_lock(mapping);
-		if (unlikely(vma->vm_flags & VM_NONLINEAR))
-			vma_nonlinear_insert(vma, &mapping->i_mmap_nonlinear);
-		else
-			vma_interval_tree_insert(vma, &mapping->i_mmap);
+		vma_interval_tree_insert(vma, &mapping->i_mmap);
 		flush_dcache_mmap_unlock(mapping);
 	}
 }
@@ -787,14 +781,11 @@ again:			remove_next = 1 + (end > next->vm_end);
 
 	if (file) {
 		mapping = file->f_mapping;
-		if (!(vma->vm_flags & VM_NONLINEAR)) {
-			root = &mapping->i_mmap;
-			uprobe_munmap(vma, vma->vm_start, vma->vm_end);
+		root = &mapping->i_mmap;
+		uprobe_munmap(vma, vma->vm_start, vma->vm_end);
 
-			if (adjust_next)
-				uprobe_munmap(next, next->vm_start,
-							next->vm_end);
-		}
+		if (adjust_next)
+			uprobe_munmap(next, next->vm_start, next->vm_end);
 
 		i_mmap_lock_write(mapping);
 		if (insert) {
@@ -3172,8 +3163,7 @@ static void vm_lock_mapping(struct mm_struct *mm, struct address_space *mapping)
  *
  * mmap_sem in write mode is required in order to block all operations
  * that could modify pagetables and free pages without need of
- * altering the vma layout (for example populate_range() with
- * nonlinear vmas). It's also needed in write mode to avoid new
+ * altering the vma layout. It's also needed in write mode to avoid new
  * anon_vmas to be associated with existing vmas.
  *
  * A single task can't take more than one mm_take_all_locks() in a row
diff --git a/mm/rmap.c b/mm/rmap.c
index b4047838da0d..130314e43d60 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -550,9 +550,8 @@ unsigned long page_address_in_vma(struct page *page, struct vm_area_struct *vma)
 		if (!vma->anon_vma || !page__anon_vma ||
 		    vma->anon_vma->root != page__anon_vma->root)
 			return -EFAULT;
-	} else if (page->mapping && !(vma->vm_flags & VM_NONLINEAR)) {
-		if (!vma->vm_file ||
-		    vma->vm_file->f_mapping != page->mapping)
+	} else if (page->mapping) {
+		if (!vma->vm_file || vma->vm_file->f_mapping != page->mapping)
 			return -EFAULT;
 	} else
 		return -EFAULT;
@@ -1275,7 +1274,6 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 		if (pte_soft_dirty(pteval))
 			swp_pte = pte_swp_mksoft_dirty(swp_pte);
 		set_pte_at(mm, address, pte, swp_pte);
-		BUG_ON(pte_file(*pte));
 	} else if (IS_ENABLED(CONFIG_MIGRATION) &&
 		   (flags & TTU_MIGRATION)) {
 		/* Establish migration entry for a file page */
@@ -1318,211 +1316,6 @@ out_mlock:
 	return ret;
 }
 
-/*
- * objrmap doesn't work for nonlinear VMAs because the assumption that
- * offset-into-file correlates with offset-into-virtual-addresses does not hold.
- * Consequently, given a particular page and its ->index, we cannot locate the
- * ptes which are mapping that page without an exhaustive linear search.
- *
- * So what this code does is a mini "virtual scan" of each nonlinear VMA which
- * maps the file to which the target page belongs.  The ->vm_private_data field
- * holds the current cursor into that scan.  Successive searches will circulate
- * around the vma's virtual address space.
- *
- * So as more replacement pressure is applied to the pages in a nonlinear VMA,
- * more scanning pressure is placed against them as well.   Eventually pages
- * will become fully unmapped and are eligible for eviction.
- *
- * For very sparsely populated VMAs this is a little inefficient - chances are
- * there there won't be many ptes located within the scan cluster.  In this case
- * maybe we could scan further - to the end of the pte page, perhaps.
- *
- * Mlocked pages:  check VM_LOCKED under mmap_sem held for read, if we can
- * acquire it without blocking.  If vma locked, mlock the pages in the cluster,
- * rather than unmapping them.  If we encounter the "check_page" that vmscan is
- * trying to unmap, return SWAP_MLOCK, else default SWAP_AGAIN.
- */
-#define CLUSTER_SIZE	min(32*PAGE_SIZE, PMD_SIZE)
-#define CLUSTER_MASK	(~(CLUSTER_SIZE - 1))
-
-static int try_to_unmap_cluster(unsigned long cursor, unsigned int *mapcount,
-		struct vm_area_struct *vma, struct page *check_page)
-{
-	struct mm_struct *mm = vma->vm_mm;
-	pmd_t *pmd;
-	pte_t *pte;
-	pte_t pteval;
-	spinlock_t *ptl;
-	struct page *page;
-	unsigned long address;
-	unsigned long mmun_start;	/* For mmu_notifiers */
-	unsigned long mmun_end;		/* For mmu_notifiers */
-	unsigned long end;
-	int ret = SWAP_AGAIN;
-	int locked_vma = 0;
-
-	address = (vma->vm_start + cursor) & CLUSTER_MASK;
-	end = address + CLUSTER_SIZE;
-	if (address < vma->vm_start)
-		address = vma->vm_start;
-	if (end > vma->vm_end)
-		end = vma->vm_end;
-
-	pmd = mm_find_pmd(mm, address);
-	if (!pmd)
-		return ret;
-
-	mmun_start = address;
-	mmun_end   = end;
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
-
-	/*
-	 * If we can acquire the mmap_sem for read, and vma is VM_LOCKED,
-	 * keep the sem while scanning the cluster for mlocking pages.
-	 */
-	if (down_read_trylock(&vma->vm_mm->mmap_sem)) {
-		locked_vma = (vma->vm_flags & VM_LOCKED);
-		if (!locked_vma)
-			up_read(&vma->vm_mm->mmap_sem); /* don't need it */
-	}
-
-	pte = pte_offset_map_lock(mm, pmd, address, &ptl);
-
-	/* Update high watermark before we lower rss */
-	update_hiwater_rss(mm);
-
-	for (; address < end; pte++, address += PAGE_SIZE) {
-		if (!pte_present(*pte))
-			continue;
-		page = vm_normal_page(vma, address, *pte);
-		BUG_ON(!page || PageAnon(page));
-
-		if (locked_vma) {
-			if (page == check_page) {
-				/* we know we have check_page locked */
-				mlock_vma_page(page);
-				ret = SWAP_MLOCK;
-			} else if (trylock_page(page)) {
-				/*
-				 * If we can lock the page, perform mlock.
-				 * Otherwise leave the page alone, it will be
-				 * eventually encountered again later.
-				 */
-				mlock_vma_page(page);
-				unlock_page(page);
-			}
-			continue;	/* don't unmap */
-		}
-
-		/*
-		 * No need for _notify because we're within an
-		 * mmu_notifier_invalidate_range_ {start|end} scope.
-		 */
-		if (ptep_clear_flush_young(vma, address, pte))
-			continue;
-
-		/* Nuke the page table entry. */
-		flush_cache_page(vma, address, pte_pfn(*pte));
-		pteval = ptep_clear_flush_notify(vma, address, pte);
-
-		/* If nonlinear, store the file page offset in the pte. */
-		if (page->index != linear_page_index(vma, address)) {
-			pte_t ptfile = pgoff_to_pte(page->index);
-			if (pte_soft_dirty(pteval))
-				ptfile = pte_file_mksoft_dirty(ptfile);
-			set_pte_at(mm, address, pte, ptfile);
-		}
-
-		/* Move the dirty bit to the physical page now the pte is gone. */
-		if (pte_dirty(pteval))
-			set_page_dirty(page);
-
-		page_remove_rmap(page);
-		page_cache_release(page);
-		dec_mm_counter(mm, MM_FILEPAGES);
-		(*mapcount)--;
-	}
-	pte_unmap_unlock(pte - 1, ptl);
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
-	if (locked_vma)
-		up_read(&vma->vm_mm->mmap_sem);
-	return ret;
-}
-
-static int try_to_unmap_nonlinear(struct page *page,
-		struct address_space *mapping, void *arg)
-{
-	struct vm_area_struct *vma;
-	int ret = SWAP_AGAIN;
-	unsigned long cursor;
-	unsigned long max_nl_cursor = 0;
-	unsigned long max_nl_size = 0;
-	unsigned int mapcount;
-
-	list_for_each_entry(vma,
-		&mapping->i_mmap_nonlinear, shared.nonlinear) {
-
-		cursor = (unsigned long) vma->vm_private_data;
-		if (cursor > max_nl_cursor)
-			max_nl_cursor = cursor;
-		cursor = vma->vm_end - vma->vm_start;
-		if (cursor > max_nl_size)
-			max_nl_size = cursor;
-	}
-
-	if (max_nl_size == 0) {	/* all nonlinears locked or reserved ? */
-		return SWAP_FAIL;
-	}
-
-	/*
-	 * We don't try to search for this page in the nonlinear vmas,
-	 * and page_referenced wouldn't have found it anyway.  Instead
-	 * just walk the nonlinear vmas trying to age and unmap some.
-	 * The mapcount of the page we came in with is irrelevant,
-	 * but even so use it as a guide to how hard we should try?
-	 */
-	mapcount = page_mapcount(page);
-	if (!mapcount)
-		return ret;
-
-	cond_resched();
-
-	max_nl_size = (max_nl_size + CLUSTER_SIZE - 1) & CLUSTER_MASK;
-	if (max_nl_cursor == 0)
-		max_nl_cursor = CLUSTER_SIZE;
-
-	do {
-		list_for_each_entry(vma,
-			&mapping->i_mmap_nonlinear, shared.nonlinear) {
-
-			cursor = (unsigned long) vma->vm_private_data;
-			while (cursor < max_nl_cursor &&
-				cursor < vma->vm_end - vma->vm_start) {
-				if (try_to_unmap_cluster(cursor, &mapcount,
-						vma, page) == SWAP_MLOCK)
-					ret = SWAP_MLOCK;
-				cursor += CLUSTER_SIZE;
-				vma->vm_private_data = (void *) cursor;
-				if ((int)mapcount <= 0)
-					return ret;
-			}
-			vma->vm_private_data = (void *) max_nl_cursor;
-		}
-		cond_resched();
-		max_nl_cursor += CLUSTER_SIZE;
-	} while (max_nl_cursor <= max_nl_size);
-
-	/*
-	 * Don't loop forever (perhaps all the remaining pages are
-	 * in locked vmas).  Reset cursor on all unreserved nonlinear
-	 * vmas, now forgetting on which ones it had fallen behind.
-	 */
-	list_for_each_entry(vma, &mapping->i_mmap_nonlinear, shared.nonlinear)
-		vma->vm_private_data = NULL;
-
-	return ret;
-}
-
 bool is_vma_temporary_stack(struct vm_area_struct *vma)
 {
 	int maybe_stack = vma->vm_flags & (VM_GROWSDOWN | VM_GROWSUP);
@@ -1568,7 +1361,6 @@ int try_to_unmap(struct page *page, enum ttu_flags flags)
 		.rmap_one = try_to_unmap_one,
 		.arg = (void *)flags,
 		.done = page_not_mapped,
-		.file_nonlinear = try_to_unmap_nonlinear,
 		.anon_lock = page_lock_anon_vma_read,
 	};
 
@@ -1614,12 +1406,6 @@ int try_to_munlock(struct page *page)
 		.rmap_one = try_to_unmap_one,
 		.arg = (void *)TTU_MUNLOCK,
 		.done = page_not_mapped,
-		/*
-		 * We don't bother to try to find the munlocked page in
-		 * nonlinears. It's costly. Instead, later, page reclaim logic
-		 * may call try_to_unmap() and recover PG_mlocked lazily.
-		 */
-		.file_nonlinear = NULL,
 		.anon_lock = page_lock_anon_vma_read,
 
 	};
@@ -1750,13 +1536,6 @@ static int rmap_walk_file(struct page *page, struct rmap_walk_control *rwc)
 			goto done;
 	}
 
-	if (!rwc->file_nonlinear)
-		goto done;
-
-	if (list_empty(&mapping->i_mmap_nonlinear))
-		goto done;
-
-	ret = rwc->file_nonlinear(page, mapping, rwc->arg);
 done:
 	i_mmap_unlock_read(mapping);
 	return ret;
diff --git a/mm/swap.c b/mm/swap.c
index 8a12b33936b4..5b3087228b99 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -1140,10 +1140,8 @@ void __init swap_setup(void)
 
 	if (bdi_init(swapper_spaces[0].backing_dev_info))
 		panic("Failed to init swap bdi");
-	for (i = 0; i < MAX_SWAPFILES; i++) {
+	for (i = 0; i < MAX_SWAPFILES; i++)
 		spin_lock_init(&swapper_spaces[i].tree_lock);
-		INIT_LIST_HEAD(&swapper_spaces[i].i_mmap_nonlinear);
-	}
 #endif
 
 	/* Use a smaller cluster for small-memory machines */
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
