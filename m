Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 20052828F3
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 06:06:34 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id cy9so319928201pac.0
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 03:06:34 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id i79si13969656pfj.103.2016.01.11.03.06.33
        for <linux-mm@kvack.org>;
        Mon, 11 Jan 2016 03:06:33 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] mm: fix locking order in mm_take_all_locks()
Date: Mon, 11 Jan 2016 14:05:28 +0300
Message-Id: <1452510328-93955-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>

Dmitry Vyukov has reported[1] possible deadlock (triggered by his syzkaller
fuzzer):

 Possible unsafe locking scenario:

       CPU0                    CPU1
       ----                    ----
  lock(&hugetlbfs_i_mmap_rwsem_key);
                               lock(&mapping->i_mmap_rwsem);
                               lock(&hugetlbfs_i_mmap_rwsem_key);
  lock(&mapping->i_mmap_rwsem);

Both traces points to mm_take_all_locks() as a source of the problem.
It doesn't take care about ordering or hugetlbfs_i_mmap_rwsem_key (aka
mapping->i_mmap_rwsem for hugetlb mapping) vs. i_mmap_rwsem.

huge_pmd_share() does memory allocation under hugetlbfs_i_mmap_rwsem_key
and allocator can take i_mmap_rwsem if it hit reclaim. So we need to
take i_mmap_rwsem from all hugetlb VMAs before taking i_mmap_rwsem from
rest of VMAs.

The patch also documents locking order for hugetlbfs_i_mmap_rwsem_key.

[1] http://lkml.kernel.org/r/CACT4Y+Zu95tBs-0EvdiAKzUOsb4tczRRfCRTpLr4bg_OP9HuVg@mail.gmail.com

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reported-by: Dmitry Vyukov <dvyukov@google.com>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>
---
 fs/hugetlbfs/inode.c |  2 +-
 mm/mmap.c            | 25 ++++++++++++++++++++-----
 mm/rmap.c            | 31 ++++++++++++++++---------------
 3 files changed, 37 insertions(+), 21 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 47789292a582..bbc333b01ca3 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -708,7 +708,7 @@ static struct inode *hugetlbfs_get_root(struct super_block *sb,
 /*
  * Hugetlbfs is not reclaimable; therefore its i_mmap_rwsem will never
  * be taken from reclaim -- unlike regular filesystems. This needs an
- * annotation because huge_pmd_share() does an allocation under
+ * annotation because huge_pmd_share() does an allocation under hugetlb's
  * i_mmap_rwsem.
  */
 static struct lock_class_key hugetlbfs_i_mmap_rwsem_key;
diff --git a/mm/mmap.c b/mm/mmap.c
index b3f00b616b81..84b12624ceb0 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -3184,10 +3184,16 @@ static void vm_lock_mapping(struct mm_struct *mm, struct address_space *mapping)
  * mapping->flags avoid to take the same lock twice, if more than one
  * vma in this mm is backed by the same anon_vma or address_space.
  *
- * We can take all the locks in random order because the VM code
- * taking i_mmap_rwsem or anon_vma->rwsem outside the mmap_sem never
- * takes more than one of them in a row. Secondly we're protected
- * against a concurrent mm_take_all_locks() by the mm_all_locks_mutex.
+ * We take locks in following order, accordingly to comment at beginning
+ * of mm/rmap.c:
+ *   - all hugetlbfs_i_mmap_rwsem_key locks (aka mapping->i_mmap_rwsem for
+ *     hugetlb mapping);
+ *   - all i_mmap_rwsem locks;
+ *   - all anon_vma->rwseml
+ *
+ * We can take all locks within these types randomly because the VM code
+ * doesn't nest them and we protected from parallel mm_take_all_locks() by
+ * mm_all_locks_mutex.
  *
  * mm_take_all_locks() and mm_drop_all_locks are expensive operations
  * that may have to take thousand of locks.
@@ -3206,7 +3212,16 @@ int mm_take_all_locks(struct mm_struct *mm)
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
 		if (signal_pending(current))
 			goto out_unlock;
-		if (vma->vm_file && vma->vm_file->f_mapping)
+		if (vma->vm_file && vma->vm_file->f_mapping &&
+				is_vm_hugetlb_page(vma))
+			vm_lock_mapping(mm, vma->vm_file->f_mapping);
+	}
+
+	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+		if (signal_pending(current))
+			goto out_unlock;
+		if (vma->vm_file && vma->vm_file->f_mapping &&
+				!is_vm_hugetlb_page(vma))
 			vm_lock_mapping(mm, vma->vm_file->f_mapping);
 	}
 
diff --git a/mm/rmap.c b/mm/rmap.c
index 68af2e32f7ed..79f3bf047f38 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -23,21 +23,22 @@
  * inode->i_mutex	(while writing or truncating, not reading or faulting)
  *   mm->mmap_sem
  *     page->flags PG_locked (lock_page)
- *       mapping->i_mmap_rwsem
- *         anon_vma->rwsem
- *           mm->page_table_lock or pte_lock
- *             zone->lru_lock (in mark_page_accessed, isolate_lru_page)
- *             swap_lock (in swap_duplicate, swap_info_get)
- *               mmlist_lock (in mmput, drain_mmlist and others)
- *               mapping->private_lock (in __set_page_dirty_buffers)
- *                 mem_cgroup_{begin,end}_page_stat (memcg->move_lock)
- *                   mapping->tree_lock (widely used)
- *               inode->i_lock (in set_page_dirty's __mark_inode_dirty)
- *               bdi.wb->list_lock (in set_page_dirty's __mark_inode_dirty)
- *                 sb_lock (within inode_lock in fs/fs-writeback.c)
- *                 mapping->tree_lock (widely used, in set_page_dirty,
- *                           in arch-dependent flush_dcache_mmap_lock,
- *                           within bdi.wb->list_lock in __sync_single_inode)
+ *       hugetlbfs_i_mmap_rwsem_key (in huge_pmd_share)
+ *         mapping->i_mmap_rwsem
+ *           anon_vma->rwsem
+ *             mm->page_table_lock or pte_lock
+ *               zone->lru_lock (in mark_page_accessed, isolate_lru_page)
+ *               swap_lock (in swap_duplicate, swap_info_get)
+ *                 mmlist_lock (in mmput, drain_mmlist and others)
+ *                 mapping->private_lock (in __set_page_dirty_buffers)
+ *                   mem_cgroup_{begin,end}_page_stat (memcg->move_lock)
+ *                     mapping->tree_lock (widely used)
+ *                 inode->i_lock (in set_page_dirty's __mark_inode_dirty)
+ *                 bdi.wb->list_lock (in set_page_dirty's __mark_inode_dirty)
+ *                   sb_lock (within inode_lock in fs/fs-writeback.c)
+ *                   mapping->tree_lock (widely used, in set_page_dirty,
+ *                             in arch-dependent flush_dcache_mmap_lock,
+ *                             within bdi.wb->list_lock in __sync_single_inode)
  *
  * anon_vma->rwsem,mapping->i_mutex      (memory_failure, collect_procs_anon)
  *   ->tasklist_lock
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
