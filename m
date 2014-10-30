Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 6A2BF280011
	for <linux-mm@kvack.org>; Thu, 30 Oct 2014 15:34:45 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id lf10so6064792pab.19
        for <linux-mm@kvack.org>; Thu, 30 Oct 2014 12:34:45 -0700 (PDT)
Received: from theshire.emacs.cl (theshire.emacs.cl. [192.155.80.235])
        by mx.google.com with ESMTP id dt17si7341356pdb.181.2014.10.30.12.34.38
        for <linux-mm@kvack.org>;
        Thu, 30 Oct 2014 12:34:38 -0700 (PDT)
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: [PATCH 03/10] mm: convert i_mmap_mutex to rwsem
Date: Thu, 30 Oct 2014 12:34:10 -0700
Message-Id: <1414697657-1678-4-git-send-email-dave@stgolabs.net>
In-Reply-To: <1414697657-1678-1-git-send-email-dave@stgolabs.net>
References: <1414697657-1678-1-git-send-email-dave@stgolabs.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: hughd@google.com, riel@redhat.com, mgorman@suse.de, peterz@infradead.org, mingo@kernel.org, linux-kernel@vger.kernel.org, dbueso@suse.de, linux-mm@kvack.org, Davidlohr Bueso <dave@stgolabs.net>

The i_mmap_mutex is a close cousin of the anon vma lock,
both protecting similar data, one for file backed pages
and the other for anon memory. To this end, this lock can
also be a rwsem. In addition, there are some important
opportunities to share the lock when there are no tree
modifications.

This conversion is straightforward. For now, all users take
the write lock.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
Reviewed-by: Rik van Riel <riel@redhat.com>
Acked-by: Kirill A. Shutemov <kirill.shutemov@intel.linux.com>
---
 fs/hugetlbfs/inode.c         | 10 +++++-----
 fs/inode.c                   |  2 +-
 include/linux/fs.h           |  7 ++++---
 include/linux/mmu_notifier.h |  2 +-
 kernel/events/uprobes.c      |  2 +-
 mm/filemap.c                 | 10 +++++-----
 mm/hugetlb.c                 | 10 +++++-----
 mm/mmap.c                    |  8 ++++----
 mm/mremap.c                  |  2 +-
 mm/rmap.c                    |  6 +++---
 10 files changed, 30 insertions(+), 29 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index a082709..5eba47f 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -472,12 +472,12 @@ static struct inode *hugetlbfs_get_root(struct super_block *sb,
 }
 
 /*
- * Hugetlbfs is not reclaimable; therefore its i_mmap_mutex will never
+ * Hugetlbfs is not reclaimable; therefore its i_mmap_rwsem will never
  * be taken from reclaim -- unlike regular filesystems. This needs an
  * annotation because huge_pmd_share() does an allocation under
- * i_mmap_mutex.
+ * i_mmap_rwsem.
  */
-static struct lock_class_key hugetlbfs_i_mmap_mutex_key;
+static struct lock_class_key hugetlbfs_i_mmap_rwsem_key;
 
 static struct inode *hugetlbfs_get_inode(struct super_block *sb,
 					struct inode *dir,
@@ -495,8 +495,8 @@ static struct inode *hugetlbfs_get_inode(struct super_block *sb,
 		struct hugetlbfs_inode_info *info;
 		inode->i_ino = get_next_ino();
 		inode_init_owner(inode, dir, mode);
-		lockdep_set_class(&inode->i_mapping->i_mmap_mutex,
-				&hugetlbfs_i_mmap_mutex_key);
+		lockdep_set_class(&inode->i_mapping->i_mmap_rwsem,
+				&hugetlbfs_i_mmap_rwsem_key);
 		inode->i_mapping->a_ops = &hugetlbfs_aops;
 		inode->i_mapping->backing_dev_info =&hugetlbfs_backing_dev_info;
 		inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
diff --git a/fs/inode.c b/fs/inode.c
index 26753ba..1732d6b 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -349,7 +349,7 @@ void address_space_init_once(struct address_space *mapping)
 	memset(mapping, 0, sizeof(*mapping));
 	INIT_RADIX_TREE(&mapping->page_tree, GFP_ATOMIC);
 	spin_lock_init(&mapping->tree_lock);
-	mutex_init(&mapping->i_mmap_mutex);
+	init_rwsem(&mapping->i_mmap_rwsem);
 	INIT_LIST_HEAD(&mapping->private_list);
 	spin_lock_init(&mapping->private_lock);
 	mapping->i_mmap = RB_ROOT;
diff --git a/include/linux/fs.h b/include/linux/fs.h
index f3a2372..648a77e 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -18,6 +18,7 @@
 #include <linux/pid.h>
 #include <linux/bug.h>
 #include <linux/mutex.h>
+#include <linux/rwsem.h>
 #include <linux/capability.h>
 #include <linux/semaphore.h>
 #include <linux/fiemap.h>
@@ -401,7 +402,7 @@ struct address_space {
 	atomic_t		i_mmap_writable;/* count VM_SHARED mappings */
 	struct rb_root		i_mmap;		/* tree of private and shared mappings */
 	struct list_head	i_mmap_nonlinear;/*list VM_NONLINEAR mappings */
-	struct mutex		i_mmap_mutex;	/* protect tree, count, list */
+	struct rw_semaphore	i_mmap_rwsem;	/* protect tree, count, list */
 	/* Protected by tree_lock together with the radix tree */
 	unsigned long		nrpages;	/* number of total pages */
 	unsigned long		nrshadows;	/* number of shadow entries */
@@ -469,12 +470,12 @@ int mapping_tagged(struct address_space *mapping, int tag);
 
 static inline void i_mmap_lock_write(struct address_space *mapping)
 {
-	mutex_lock(&mapping->i_mmap_mutex);
+	down_write(&mapping->i_mmap_rwsem);
 }
 
 static inline void i_mmap_unlock_write(struct address_space *mapping)
 {
-	mutex_unlock(&mapping->i_mmap_mutex);
+	up_write(&mapping->i_mmap_rwsem);
 }
 
 /*
diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index 94d19f6..95243d2 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -177,7 +177,7 @@ struct mmu_notifier_ops {
  * Therefore notifier chains can only be traversed when either
  *
  * 1. mmap_sem is held.
- * 2. One of the reverse map locks is held (i_mmap_mutex or anon_vma->rwsem).
+ * 2. One of the reverse map locks is held (i_mmap_rwsem or anon_vma->rwsem).
  * 3. No other concurrent thread can access the list (release)
  */
 struct mmu_notifier {
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index a1d99e3..e1bb60d 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -731,7 +731,7 @@ build_map_info(struct address_space *mapping, loff_t offset, bool is_register)
 
 		if (!prev && !more) {
 			/*
-			 * Needs GFP_NOWAIT to avoid i_mmap_mutex recursion through
+			 * Needs GFP_NOWAIT to avoid i_mmap_rwsem recursion through
 			 * reclaim. This is optimistic, no harm done if it fails.
 			 */
 			prev = kmalloc(sizeof(struct map_info),
diff --git a/mm/filemap.c b/mm/filemap.c
index 14b4642..e8905bc 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -62,16 +62,16 @@
 /*
  * Lock ordering:
  *
- *  ->i_mmap_mutex		(truncate_pagecache)
+ *  ->i_mmap_rwsem		(truncate_pagecache)
  *    ->private_lock		(__free_pte->__set_page_dirty_buffers)
  *      ->swap_lock		(exclusive_swap_page, others)
  *        ->mapping->tree_lock
  *
  *  ->i_mutex
- *    ->i_mmap_mutex		(truncate->unmap_mapping_range)
+ *    ->i_mmap_rwsem		(truncate->unmap_mapping_range)
  *
  *  ->mmap_sem
- *    ->i_mmap_mutex
+ *    ->i_mmap_rwsem
  *      ->page_table_lock or pte_lock	(various, mainly in memory.c)
  *        ->mapping->tree_lock	(arch-dependent flush_dcache_mmap_lock)
  *
@@ -85,7 +85,7 @@
  *    sb_lock			(fs/fs-writeback.c)
  *    ->mapping->tree_lock	(__sync_single_inode)
  *
- *  ->i_mmap_mutex
+ *  ->i_mmap_rwsem
  *    ->anon_vma.lock		(vma_adjust)
  *
  *  ->anon_vma.lock
@@ -105,7 +105,7 @@
  *    ->inode->i_lock		(zap_pte_range->set_page_dirty)
  *    ->private_lock		(zap_pte_range->__set_page_dirty_buffers)
  *
- * ->i_mmap_mutex
+ * ->i_mmap_rwsem
  *   ->tasklist_lock            (memory_failure, collect_procs_ao)
  */
 
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 5d8758f..2071cf4 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2727,9 +2727,9 @@ void __unmap_hugepage_range_final(struct mmu_gather *tlb,
 	 * on its way out.  We're lucky that the flag has such an appropriate
 	 * name, and can in fact be safely cleared here. We could clear it
 	 * before the __unmap_hugepage_range above, but all that's necessary
-	 * is to clear it before releasing the i_mmap_mutex. This works
+	 * is to clear it before releasing the i_mmap_rwsem. This works
 	 * because in the context this is called, the VMA is about to be
-	 * destroyed and the i_mmap_mutex is held.
+	 * destroyed and the i_mmap_rwsem is held.
 	 */
 	vma->vm_flags &= ~VM_MAYSHARE;
 }
@@ -3372,9 +3372,9 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 		spin_unlock(ptl);
 	}
 	/*
-	 * Must flush TLB before releasing i_mmap_mutex: x86's huge_pmd_unshare
+	 * Must flush TLB before releasing i_mmap_rwsem: x86's huge_pmd_unshare
 	 * may have cleared our pud entry and done put_page on the page table:
-	 * once we release i_mmap_mutex, another task can do the final put_page
+	 * once we release i_mmap_rwsem, another task can do the final put_page
 	 * and that page table be reused and filled with junk.
 	 */
 	flush_tlb_range(vma, start, end);
@@ -3528,7 +3528,7 @@ static int vma_shareable(struct vm_area_struct *vma, unsigned long addr)
  * and returns the corresponding pte. While this is not necessary for the
  * !shared pmd case because we can allocate the pmd later as well, it makes the
  * code much cleaner. pmd allocation is essential for the shared case because
- * pud has to be populated inside the same i_mmap_mutex section - otherwise
+ * pud has to be populated inside the same i_mmap_rwsem section - otherwise
  * racing tasks could either miss the sharing (see huge_pte_offset) or select a
  * bad pmd for sharing.
  */
diff --git a/mm/mmap.c b/mm/mmap.c
index 136f4c8..db4ceac 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -232,7 +232,7 @@ error:
 }
 
 /*
- * Requires inode->i_mapping->i_mmap_mutex
+ * Requires inode->i_mapping->i_mmap_rwsem
  */
 static void __remove_shared_vm_struct(struct vm_area_struct *vma,
 		struct file *file, struct address_space *mapping)
@@ -2854,7 +2854,7 @@ void exit_mmap(struct mm_struct *mm)
 
 /* Insert vm structure into process list sorted by address
  * and into the inode's i_mmap tree.  If vm_file is non-NULL
- * then i_mmap_mutex is taken here.
+ * then i_mmap_rwsem is taken here.
  */
 int insert_vm_struct(struct mm_struct *mm, struct vm_area_struct *vma)
 {
@@ -3149,7 +3149,7 @@ static void vm_lock_mapping(struct mm_struct *mm, struct address_space *mapping)
 		 */
 		if (test_and_set_bit(AS_MM_ALL_LOCKS, &mapping->flags))
 			BUG();
-		mutex_lock_nest_lock(&mapping->i_mmap_mutex, &mm->mmap_sem);
+		down_write_nest_lock(&mapping->i_mmap_rwsem, &mm->mmap_sem);
 	}
 }
 
@@ -3176,7 +3176,7 @@ static void vm_lock_mapping(struct mm_struct *mm, struct address_space *mapping)
  * vma in this mm is backed by the same anon_vma or address_space.
  *
  * We can take all the locks in random order because the VM code
- * taking i_mmap_mutex or anon_vma->rwsem outside the mmap_sem never
+ * taking i_mmap_rwsem or anon_vma->rwsem outside the mmap_sem never
  * takes more than one of them in a row. Secondly we're protected
  * against a concurrent mm_take_all_locks() by the mm_all_locks_mutex.
  *
diff --git a/mm/mremap.c b/mm/mremap.c
index fa7c432..c929324 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -99,7 +99,7 @@ static void move_ptes(struct vm_area_struct *vma, pmd_t *old_pmd,
 	spinlock_t *old_ptl, *new_ptl;
 
 	/*
-	 * When need_rmap_locks is true, we take the i_mmap_mutex and anon_vma
+	 * When need_rmap_locks is true, we take the i_mmap_rwsem and anon_vma
 	 * locks to ensure that rmap will always observe either the old or the
 	 * new ptes. This is the easiest way to avoid races with
 	 * truncate_pagecache(), page migration, etc...
diff --git a/mm/rmap.c b/mm/rmap.c
index ae72965..e0c0e90 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -23,7 +23,7 @@
  * inode->i_mutex	(while writing or truncating, not reading or faulting)
  *   mm->mmap_sem
  *     page->flags PG_locked (lock_page)
- *       mapping->i_mmap_mutex
+ *       mapping->i_mmap_rwsem
  *         anon_vma->rwsem
  *           mm->page_table_lock or pte_lock
  *             zone->lru_lock (in mark_page_accessed, isolate_lru_page)
@@ -1258,7 +1258,7 @@ out_mlock:
 	/*
 	 * We need mmap_sem locking, Otherwise VM_LOCKED check makes
 	 * unstable result and race. Plus, We can't wait here because
-	 * we now hold anon_vma->rwsem or mapping->i_mmap_mutex.
+	 * we now hold anon_vma->rwsem or mapping->i_mmap_rwsem.
 	 * if trylock failed, the page remain in evictable lru and later
 	 * vmscan could retry to move the page to unevictable lru if the
 	 * page is actually mlocked.
@@ -1682,7 +1682,7 @@ static int rmap_walk_file(struct page *page, struct rmap_walk_control *rwc)
 	 * The page lock not only makes sure that page->mapping cannot
 	 * suddenly be NULLified by truncation, it makes sure that the
 	 * structure at mapping cannot be freed and reused yet,
-	 * so we can safely take mapping->i_mmap_mutex.
+	 * so we can safely take mapping->i_mmap_rwsem.
 	 */
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
