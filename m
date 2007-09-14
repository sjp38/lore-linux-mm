From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Fri, 14 Sep 2007 16:54:12 -0400
Message-Id: <20070914205412.6536.34898.sendpatchset@localhost>
In-Reply-To: <20070914205359.6536.98017.sendpatchset@localhost>
References: <20070914205359.6536.98017.sendpatchset@localhost>
Subject: [PATCH/RFC 2/14] Reclaim Scalability:  convert inode i_mmap_lock to reader/writer lock
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, mel@csn.ul.ie, clameter@sgi.com, riel@redhat.com, balbir@linux.vnet.ibm.com, andrea@suse.de, a.p.zijlstra@chello.nl, eric.whitney@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

PATCH/RFC 02/14 Reclaim Scalability:  make the inode i_mmap_lock a reader/writer lock

Against:  2.6.23-rc4-mm1

I have seen soft cpu lockups in page_referenced_file() due to 
contention on i_mmap_lock() for different pages.  Making the
i_mmap_lock a reader/writer lock should increase parallelism
in vmscan for file back pages mapped into many address spaces.

Read lock the i_mmap_lock for all usage except:

1) mmap/munmap:  linking vma into i_mmap prio_tree or removing
2) unmap_mapping_range:   protecting vm_truncate_count

rmap:  try_to_unmap_file() required new cond_resched_rwlock().
To reduce code duplication, I recast cond_resched_lock() as a
[static inline] wrapper around reworked cond_sched_lock() =>
__cond_resched_lock(void *lock, int type). 
New cond_resched_rwlock() implemented as another wrapper.  

Note:  This patch is meant to address a situation I've seen
running large Oracle OLTP workload--1000s of users--on an
large HP ia64 NUMA platform.  The system hung, spitting out
"soft lockup" messages on the console.  Stack traces showed
that all cpus were in page_referenced(), as mentioned above.
I let the system run overnight in this state--it never
recovered before I decided to reboot.

TODO:  I've yet to test this patch with the same workload
to see what happens.  Don't have access to the system now.


Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 fs/hugetlbfs/inode.c  |    7 +++--
 fs/inode.c            |    2 -
 fs/revoke.c           |   18 +++++++-------
 include/linux/fs.h    |    2 -
 include/linux/mm.h    |    2 -
 include/linux/sched.h |   17 ++++++++++---
 kernel/fork.c         |    4 +--
 kernel/sched.c        |   64 ++++++++++++++++++++++++++++++++++++++++++--------
 mm/filemap_xip.c      |    4 +--
 mm/fremap.c           |    4 +--
 mm/hugetlb.c          |    8 +++---
 mm/memory.c           |   13 +++++-----
 mm/migrate.c          |    4 +--
 mm/mmap.c             |   18 +++++++-------
 mm/mremap.c           |    4 +--
 mm/rmap.c             |   16 ++++++------
 16 files changed, 123 insertions(+), 64 deletions(-)

Index: Linux/include/linux/fs.h
===================================================================
--- Linux.orig/include/linux/fs.h	2007-09-10 10:09:47.000000000 -0400
+++ Linux/include/linux/fs.h	2007-09-10 11:43:26.000000000 -0400
@@ -506,7 +506,7 @@ struct address_space {
 	unsigned int		i_mmap_writable;/* count VM_SHARED mappings */
 	struct prio_tree_root	i_mmap;		/* tree of private and shared mappings */
 	struct list_head	i_mmap_nonlinear;/*list VM_NONLINEAR mappings */
-	spinlock_t		i_mmap_lock;	/* protect tree, count, list */
+	rwlock_t		i_mmap_lock;	/* protect tree, count, list */
 	unsigned int		truncate_count;	/* Cover race condition with truncate */
 	unsigned long		nrpages;	/* number of total pages */
 	pgoff_t			writeback_index;/* writeback starts here */
Index: Linux/include/linux/mm.h
===================================================================
--- Linux.orig/include/linux/mm.h	2007-09-10 10:09:47.000000000 -0400
+++ Linux/include/linux/mm.h	2007-09-10 11:43:26.000000000 -0400
@@ -684,7 +684,7 @@ struct zap_details {
 	struct address_space *check_mapping;	/* Check page->mapping if set */
 	pgoff_t	first_index;			/* Lowest page->index to unmap */
 	pgoff_t last_index;			/* Highest page->index to unmap */
-	spinlock_t *i_mmap_lock;		/* For unmap_mapping_range: */
+	rwlock_t *i_mmap_lock;			/* For unmap_mapping_range: */
 	unsigned long truncate_count;		/* Compare vm_truncate_count */
 };
 
Index: Linux/fs/inode.c
===================================================================
--- Linux.orig/fs/inode.c	2007-09-10 10:09:43.000000000 -0400
+++ Linux/fs/inode.c	2007-09-10 11:43:26.000000000 -0400
@@ -203,7 +203,7 @@ void inode_init_once(struct inode *inode
 	init_rwsem(&inode->i_alloc_sem);
 	INIT_RADIX_TREE(&inode->i_data.page_tree, GFP_ATOMIC);
 	rwlock_init(&inode->i_data.tree_lock);
-	spin_lock_init(&inode->i_data.i_mmap_lock);
+	rwlock_init(&inode->i_data.i_mmap_lock);
 	INIT_LIST_HEAD(&inode->i_data.private_list);
 	spin_lock_init(&inode->i_data.private_lock);
 	INIT_RAW_PRIO_TREE_ROOT(&inode->i_data.i_mmap);
Index: Linux/fs/hugetlbfs/inode.c
===================================================================
--- Linux.orig/fs/hugetlbfs/inode.c	2007-09-10 10:09:43.000000000 -0400
+++ Linux/fs/hugetlbfs/inode.c	2007-09-10 11:43:26.000000000 -0400
@@ -411,6 +411,9 @@ static void hugetlbfs_drop_inode(struct 
 		hugetlbfs_forget_inode(inode);
 }
 
+/*
+ * LOCKING:  __unmap_hugepage_range() requires write lock on i_mmap_lock
+ */
 static inline void
 hugetlb_vmtruncate_list(struct prio_tree_root *root, pgoff_t pgoff)
 {
@@ -445,10 +448,10 @@ static int hugetlb_vmtruncate(struct ino
 	pgoff = offset >> PAGE_SHIFT;
 
 	i_size_write(inode, offset);
-	spin_lock(&mapping->i_mmap_lock);
+	write_lock(&mapping->i_mmap_lock);
 	if (!prio_tree_empty(&mapping->i_mmap))
 		hugetlb_vmtruncate_list(&mapping->i_mmap, pgoff);
-	spin_unlock(&mapping->i_mmap_lock);
+	write_unlock(&mapping->i_mmap_lock);
 	truncate_hugepages(inode, offset);
 	return 0;
 }
Index: Linux/fs/revoke.c
===================================================================
--- Linux.orig/fs/revoke.c	2007-09-10 10:09:44.000000000 -0400
+++ Linux/fs/revoke.c	2007-09-10 11:43:26.000000000 -0400
@@ -272,7 +272,7 @@ static int revoke_break_cow(struct files
 
 /*
  *	 LOCKING: down_write(&mm->mmap_sem)
- *	 	    -> spin_lock(&mapping->i_mmap_lock)
+ *	 	    -> write_lock(&mapping->i_mmap_lock)
  */
 static int revoke_vma(struct vm_area_struct *vma, struct zap_details *details)
 {
@@ -298,14 +298,14 @@ static int revoke_vma(struct vm_area_str
 	return 0;
 
   out_need_break:
-	spin_unlock(details->i_mmap_lock);
+	write_unlock(details->i_mmap_lock);
 	cond_resched();
-	spin_lock(details->i_mmap_lock);
+	write_lock(details->i_mmap_lock);
 	return -EINTR;
 }
 
 /*
- *	LOCKING: spin_lock(&mapping->i_mmap_lock)
+ *	LOCKING: write_lock(&mapping->i_mmap_lock)
  */
 static int revoke_mm(struct mm_struct *mm, struct address_space *mapping,
 		     struct file *to_exclude)
@@ -335,7 +335,7 @@ static int revoke_mm(struct mm_struct *m
 		if (err)
 			break;
 
-		__unlink_file_vma(vma);
+		__unlink_file_vma(vma);	/* requires write_lock(i_mmap_lock) */
 		fput(vma->vm_file);
 		vma->vm_file = NULL;
 	}
@@ -345,7 +345,7 @@ static int revoke_mm(struct mm_struct *m
 }
 
 /*
- *	LOCKING: spin_lock(&mapping->i_mmap_lock)
+ *	LOCKING: write_lock(&mapping->i_mmap_lock)
  */
 static void revoke_mapping_tree(struct address_space *mapping,
 				struct file *to_exclude)
@@ -377,7 +377,7 @@ static void revoke_mapping_tree(struct a
 }
 
 /*
- *	LOCKING: spin_lock(&mapping->i_mmap_lock)
+ *	LOCKING: write_lock(&mapping->i_mmap_lock)
  */
 static void revoke_mapping_list(struct address_space *mapping,
 				struct file *to_exclude)
@@ -408,12 +408,12 @@ static void revoke_mapping_list(struct a
 
 static void revoke_mapping(struct address_space *mapping, struct file *to_exclude)
 {
-	spin_lock(&mapping->i_mmap_lock);
+	write_lock(&mapping->i_mmap_lock);
 	if (unlikely(!prio_tree_empty(&mapping->i_mmap)))
 		revoke_mapping_tree(mapping, to_exclude);
 	if (unlikely(!list_empty(&mapping->i_mmap_nonlinear)))
 		revoke_mapping_list(mapping, to_exclude);
-	spin_unlock(&mapping->i_mmap_lock);
+	write_unlock(&mapping->i_mmap_lock);
 }
 
 static void restore_file(struct revokefs_inode_info *info)
Index: Linux/kernel/fork.c
===================================================================
--- Linux.orig/kernel/fork.c	2007-09-10 10:09:47.000000000 -0400
+++ Linux/kernel/fork.c	2007-09-10 11:43:26.000000000 -0400
@@ -262,12 +262,12 @@ static inline int dup_mmap(struct mm_str
 				atomic_dec(&inode->i_writecount);
 
 			/* insert tmp into the share list, just after mpnt */
-			spin_lock(&file->f_mapping->i_mmap_lock);
+			write_lock(&file->f_mapping->i_mmap_lock);
 			tmp->vm_truncate_count = mpnt->vm_truncate_count;
 			flush_dcache_mmap_lock(file->f_mapping);
 			vma_prio_tree_add(tmp, mpnt);
 			flush_dcache_mmap_unlock(file->f_mapping);
-			spin_unlock(&file->f_mapping->i_mmap_lock);
+			write_unlock(&file->f_mapping->i_mmap_lock);
 		}
 
 		/*
Index: Linux/mm/filemap_xip.c
===================================================================
--- Linux.orig/mm/filemap_xip.c	2007-09-10 10:09:47.000000000 -0400
+++ Linux/mm/filemap_xip.c	2007-09-10 11:43:26.000000000 -0400
@@ -182,7 +182,7 @@ __xip_unmap (struct address_space * mapp
 	if (!page)
 		return;
 
-	spin_lock(&mapping->i_mmap_lock);
+	read_lock(&mapping->i_mmap_lock);
 	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
 		mm = vma->vm_mm;
 		address = vma->vm_start +
@@ -200,7 +200,7 @@ __xip_unmap (struct address_space * mapp
 			page_cache_release(page);
 		}
 	}
-	spin_unlock(&mapping->i_mmap_lock);
+	read_unlock(&mapping->i_mmap_lock);
 }
 
 /*
Index: Linux/mm/fremap.c
===================================================================
--- Linux.orig/mm/fremap.c	2007-09-10 10:09:47.000000000 -0400
+++ Linux/mm/fremap.c	2007-09-10 11:43:26.000000000 -0400
@@ -200,13 +200,13 @@ asmlinkage long sys_remap_file_pages(uns
 			}
 			goto out;
 		}
-		spin_lock(&mapping->i_mmap_lock);
+		write_lock(&mapping->i_mmap_lock);
 		flush_dcache_mmap_lock(mapping);
 		vma->vm_flags |= VM_NONLINEAR;
 		vma_prio_tree_remove(vma, &mapping->i_mmap);
 		vma_nonlinear_insert(vma, &mapping->i_mmap_nonlinear);
 		flush_dcache_mmap_unlock(mapping);
-		spin_unlock(&mapping->i_mmap_lock);
+		write_unlock(&mapping->i_mmap_lock);
 	}
 
 	err = populate_range(mm, vma, start, size, pgoff);
Index: Linux/mm/hugetlb.c
===================================================================
--- Linux.orig/mm/hugetlb.c	2007-09-10 10:09:47.000000000 -0400
+++ Linux/mm/hugetlb.c	2007-09-10 11:43:26.000000000 -0400
@@ -451,9 +451,9 @@ void unmap_hugepage_range(struct vm_area
 	 * do nothing in this case.
 	 */
 	if (vma->vm_file) {
-		spin_lock(&vma->vm_file->f_mapping->i_mmap_lock);
+		write_lock(&vma->vm_file->f_mapping->i_mmap_lock);
 		__unmap_hugepage_range(vma, start, end);
-		spin_unlock(&vma->vm_file->f_mapping->i_mmap_lock);
+		write_unlock(&vma->vm_file->f_mapping->i_mmap_lock);
 	}
 }
 
@@ -693,7 +693,7 @@ void hugetlb_change_protection(struct vm
 	BUG_ON(address >= end);
 	flush_cache_range(vma, address, end);
 
-	spin_lock(&vma->vm_file->f_mapping->i_mmap_lock);
+	read_lock(&vma->vm_file->f_mapping->i_mmap_lock);
 	spin_lock(&mm->page_table_lock);
 	for (; address < end; address += HPAGE_SIZE) {
 		ptep = huge_pte_offset(mm, address);
@@ -708,7 +708,7 @@ void hugetlb_change_protection(struct vm
 		}
 	}
 	spin_unlock(&mm->page_table_lock);
-	spin_unlock(&vma->vm_file->f_mapping->i_mmap_lock);
+	read_unlock(&vma->vm_file->f_mapping->i_mmap_lock);
 
 	flush_tlb_range(vma, start, end);
 }
Index: Linux/mm/memory.c
===================================================================
--- Linux.orig/mm/memory.c	2007-09-10 10:09:47.000000000 -0400
+++ Linux/mm/memory.c	2007-09-10 11:43:26.000000000 -0400
@@ -816,7 +816,7 @@ unsigned long unmap_vmas(struct mmu_gath
 	unsigned long tlb_start = 0;	/* For tlb_finish_mmu */
 	int tlb_start_valid = 0;
 	unsigned long start = start_addr;
-	spinlock_t *i_mmap_lock = details? details->i_mmap_lock: NULL;
+	rwlock_t *i_mmap_lock = details? details->i_mmap_lock: NULL;
 	int fullmm = (*tlbp)->fullmm;
 
 	for ( ; vma && vma->vm_start < end_addr; vma = vma->vm_next) {
@@ -1728,7 +1728,7 @@ unwritable_page:
  * can't efficiently keep all vmas in step with mapping->truncate_count:
  * so instead reset them all whenever it wraps back to 0 (then go to 1).
  * mapping->truncate_count and vma->vm_truncate_count are protected by
- * i_mmap_lock.
+ * write locked i_mmap_lock.
  *
  * In order to make forward progress despite repeatedly restarting some
  * large vma, note the restart_addr from unmap_vmas when it breaks out:
@@ -1793,9 +1793,10 @@ again:
 			goto again;
 	}
 
-	spin_unlock(details->i_mmap_lock);
+//TODO:  why not cond_resched_lock() here [rwlock version]?
+	write_unlock(details->i_mmap_lock);
 	cond_resched();
-	spin_lock(details->i_mmap_lock);
+	write_lock(details->i_mmap_lock);
 	return -EINTR;
 }
 
@@ -1891,7 +1892,7 @@ void unmap_mapping_range(struct address_
 		details.last_index = ULONG_MAX;
 	details.i_mmap_lock = &mapping->i_mmap_lock;
 
-	spin_lock(&mapping->i_mmap_lock);
+	write_lock(&mapping->i_mmap_lock);
 
 	/* Protect against endless unmapping loops */
 	mapping->truncate_count++;
@@ -1906,7 +1907,7 @@ void unmap_mapping_range(struct address_
 		unmap_mapping_range_tree(&mapping->i_mmap, &details);
 	if (unlikely(!list_empty(&mapping->i_mmap_nonlinear)))
 		unmap_mapping_range_list(&mapping->i_mmap_nonlinear, &details);
-	spin_unlock(&mapping->i_mmap_lock);
+	write_unlock(&mapping->i_mmap_lock);
 }
 EXPORT_SYMBOL(unmap_mapping_range);
 
Index: Linux/mm/migrate.c
===================================================================
--- Linux.orig/mm/migrate.c	2007-09-10 11:43:11.000000000 -0400
+++ Linux/mm/migrate.c	2007-09-10 11:43:26.000000000 -0400
@@ -207,12 +207,12 @@ static void remove_file_migration_ptes(s
 	if (!mapping)
 		return;
 
-	spin_lock(&mapping->i_mmap_lock);
+	read_lock(&mapping->i_mmap_lock);
 
 	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff)
 		remove_migration_pte(vma, old, new);
 
-	spin_unlock(&mapping->i_mmap_lock);
+	read_unlock(&mapping->i_mmap_lock);
 }
 
 /*
Index: Linux/mm/mmap.c
===================================================================
--- Linux.orig/mm/mmap.c	2007-09-10 11:43:11.000000000 -0400
+++ Linux/mm/mmap.c	2007-09-10 11:43:26.000000000 -0400
@@ -182,7 +182,7 @@ error:
 }
 
 /*
- * Requires inode->i_mapping->i_mmap_lock
+ * Requires write locked inode->i_mapping->i_mmap_lock
  */
 static void __remove_shared_vm_struct(struct vm_area_struct *vma,
 		struct file *file, struct address_space *mapping)
@@ -201,7 +201,7 @@ static void __remove_shared_vm_struct(st
 }
 
 /*
- * Requires inode->i_mapping->i_mmap_lock
+ * Requires write locked inode->i_mapping->i_mmap_lock
  */
 void __unlink_file_vma(struct vm_area_struct *vma)
 {
@@ -221,9 +221,9 @@ void unlink_file_vma(struct vm_area_stru
 
 	if (file) {
 		struct address_space *mapping = file->f_mapping;
-		spin_lock(&mapping->i_mmap_lock);
+		write_lock(&mapping->i_mmap_lock);
 		__remove_shared_vm_struct(vma, file, mapping);
-		spin_unlock(&mapping->i_mmap_lock);
+		write_unlock(&mapping->i_mmap_lock);
 	}
 }
 
@@ -445,7 +445,7 @@ static void vma_link(struct mm_struct *m
 		mapping = vma->vm_file->f_mapping;
 
 	if (mapping) {
-		spin_lock(&mapping->i_mmap_lock);
+		write_lock(&mapping->i_mmap_lock);
 		vma->vm_truncate_count = mapping->truncate_count;
 	}
 	anon_vma_lock(vma);
@@ -455,7 +455,7 @@ static void vma_link(struct mm_struct *m
 
 	anon_vma_unlock(vma);
 	if (mapping)
-		spin_unlock(&mapping->i_mmap_lock);
+		write_unlock(&mapping->i_mmap_lock);
 
 	mm->map_count++;
 	validate_mm(mm);
@@ -542,7 +542,7 @@ again:			remove_next = 1 + (end > next->
 		mapping = file->f_mapping;
 		if (!(vma->vm_flags & VM_NONLINEAR))
 			root = &mapping->i_mmap;
-		spin_lock(&mapping->i_mmap_lock);
+		write_lock(&mapping->i_mmap_lock);
 		if (importer &&
 		    vma->vm_truncate_count != next->vm_truncate_count) {
 			/*
@@ -626,7 +626,7 @@ again:			remove_next = 1 + (end > next->
 	if (anon_vma)
 		write_unlock(&anon_vma->rwlock);
 	if (mapping)
-		spin_unlock(&mapping->i_mmap_lock);
+		write_unlock(&mapping->i_mmap_lock);
 
 	if (remove_next) {
 		if (file)
@@ -2064,7 +2064,7 @@ void exit_mmap(struct mm_struct *mm)
 
 /* Insert vm structure into process list sorted by address
  * and into the inode's i_mmap tree.  If vm_file is non-NULL
- * then i_mmap_lock is taken here.
+ * then i_mmap_lock is write locked here.
  */
 int insert_vm_struct(struct mm_struct * mm, struct vm_area_struct * vma)
 {
Index: Linux/mm/mremap.c
===================================================================
--- Linux.orig/mm/mremap.c	2007-09-10 10:09:38.000000000 -0400
+++ Linux/mm/mremap.c	2007-09-10 11:43:26.000000000 -0400
@@ -83,7 +83,7 @@ static void move_ptes(struct vm_area_str
 		 * and we propagate stale pages into the dst afterward.
 		 */
 		mapping = vma->vm_file->f_mapping;
-		spin_lock(&mapping->i_mmap_lock);
+		read_lock(&mapping->i_mmap_lock);
 		if (new_vma->vm_truncate_count &&
 		    new_vma->vm_truncate_count != vma->vm_truncate_count)
 			new_vma->vm_truncate_count = 0;
@@ -115,7 +115,7 @@ static void move_ptes(struct vm_area_str
 	pte_unmap_nested(new_pte - 1);
 	pte_unmap_unlock(old_pte - 1, old_ptl);
 	if (mapping)
-		spin_unlock(&mapping->i_mmap_lock);
+		read_unlock(&mapping->i_mmap_lock);
 }
 
 #define LATENCY_LIMIT	(64 * PAGE_SIZE)
Index: Linux/mm/rmap.c
===================================================================
--- Linux.orig/mm/rmap.c	2007-09-10 11:43:11.000000000 -0400
+++ Linux/mm/rmap.c	2007-09-10 11:43:26.000000000 -0400
@@ -365,7 +365,7 @@ static int page_referenced_file(struct p
 	 */
 	BUG_ON(!PageLocked(page));
 
-	spin_lock(&mapping->i_mmap_lock);
+	read_lock(&mapping->i_mmap_lock);
 
 	/*
 	 * i_mmap_lock does not stabilize mapcount at all, but mapcount
@@ -391,7 +391,7 @@ static int page_referenced_file(struct p
 			break;
 	}
 
-	spin_unlock(&mapping->i_mmap_lock);
+	read_unlock(&mapping->i_mmap_lock);
 	return referenced;
 }
 
@@ -472,12 +472,12 @@ static int page_mkclean_file(struct addr
 
 	BUG_ON(PageAnon(page));
 
-	spin_lock(&mapping->i_mmap_lock);
+	read_lock(&mapping->i_mmap_lock);
 	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
 		if (vma->vm_flags & VM_SHARED)
 			ret += page_mkclean_one(page, vma);
 	}
-	spin_unlock(&mapping->i_mmap_lock);
+	read_unlock(&mapping->i_mmap_lock);
 	return ret;
 }
 
@@ -904,7 +904,7 @@ static int try_to_unmap_file(struct page
 	unsigned long max_nl_size = 0;
 	unsigned int mapcount;
 
-	spin_lock(&mapping->i_mmap_lock);
+	read_lock(&mapping->i_mmap_lock);
 	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
 		ret = try_to_unmap_one(page, vma, migration);
 		if (ret == SWAP_FAIL || !page_mapped(page))
@@ -941,7 +941,7 @@ static int try_to_unmap_file(struct page
 	mapcount = page_mapcount(page);
 	if (!mapcount)
 		goto out;
-	cond_resched_lock(&mapping->i_mmap_lock);
+	cond_resched_rwlock(&mapping->i_mmap_lock, 0);
 
 	max_nl_size = (max_nl_size + CLUSTER_SIZE - 1) & CLUSTER_MASK;
 	if (max_nl_cursor == 0)
@@ -963,7 +963,7 @@ static int try_to_unmap_file(struct page
 			}
 			vma->vm_private_data = (void *) max_nl_cursor;
 		}
-		cond_resched_lock(&mapping->i_mmap_lock);
+		cond_resched_rwlock(&mapping->i_mmap_lock, 0);
 		max_nl_cursor += CLUSTER_SIZE;
 	} while (max_nl_cursor <= max_nl_size);
 
@@ -975,7 +975,7 @@ static int try_to_unmap_file(struct page
 	list_for_each_entry(vma, &mapping->i_mmap_nonlinear, shared.vm_set.list)
 		vma->vm_private_data = NULL;
 out:
-	spin_unlock(&mapping->i_mmap_lock);
+	read_unlock(&mapping->i_mmap_lock);
 	return ret;
 }
 
Index: Linux/include/linux/sched.h
===================================================================
--- Linux.orig/include/linux/sched.h	2007-09-10 10:09:47.000000000 -0400
+++ Linux/include/linux/sched.h	2007-09-10 11:43:26.000000000 -0400
@@ -1823,12 +1823,23 @@ static inline int need_resched(void)
  * cond_resched() and cond_resched_lock(): latency reduction via
  * explicit rescheduling in places that are safe. The return
  * value indicates whether a reschedule was done in fact.
- * cond_resched_lock() will drop the spinlock before scheduling,
- * cond_resched_softirq() will enable bhs before scheduling.
+ * cond_resched_softirq() will enable bhs before scheduling,
+ * cond_resched_*lock() will drop the *lock before scheduling.
  */
 extern int cond_resched(void);
-extern int cond_resched_lock(spinlock_t * lock);
 extern int cond_resched_softirq(void);
+extern int __cond_resched_lock(void * lock, int lock_type);
+
+#define COND_RESCHED_SPIN  2
+static inline int cond_resched_lock(spinlock_t * lock)
+{
+	return __cond_resched_lock(lock, COND_RESCHED_SPIN);
+}
+
+static inline int cond_resched_rwlock(rwlock_t * lock, int write_lock)
+{
+	return __cond_resched_lock(lock, !!write_lock);
+}
 
 /*
  * Does a critical section need to be broken due to another
Index: Linux/kernel/sched.c
===================================================================
--- Linux.orig/kernel/sched.c	2007-09-10 10:09:47.000000000 -0400
+++ Linux/kernel/sched.c	2007-09-10 11:43:26.000000000 -0400
@@ -4635,34 +4635,78 @@ int __sched cond_resched(void)
 EXPORT_SYMBOL(cond_resched);
 
 /*
- * cond_resched_lock() - if a reschedule is pending, drop the given lock,
+ * helper functions for __cond_resched_lock()
+ */
+static int __need_lockbreak(void *lock, int type)
+{
+	if (likely(type == COND_RESCHED_SPIN))
+		return need_lockbreak((spinlock_t *)lock);
+	else
+		return need_lockbreak((rwlock_t *)lock);
+}
+
+static void __reacquire_lock(void *lock, int type)
+{
+	if (likely(type == COND_RESCHED_SPIN))
+		spin_lock((spinlock_t *)lock);
+	else if (type)
+		write_unlock((rwlock_t *)lock);
+	else
+		read_unlock((rwlock_t *)lock);
+}
+
+static void __drop_lock(void *lock, int type)
+{
+	if (likely(type == COND_RESCHED_SPIN))
+		spin_unlock((spinlock_t *)lock);
+	else if (type)
+		write_unlock((rwlock_t *)lock);
+	else
+		read_unlock((rwlock_t *)lock);
+}
+
+static void __release_lock(void *lock, int type)
+{
+	if (likely(type == COND_RESCHED_SPIN))
+		spin_release(&(spinlock_t *)lock->dep_map, 1, _RET_IP_);
+	else
+		rwlock_release(&(rwlock_t *)lock->dep_map, 1, _RET_IP_);
+}
+
+/*
+ * __cond_resched_lock() - if a reschedule is pending, drop the given lock,
  * call schedule, and on return reacquire the lock.
  *
+ * Lock type:
+ *  0 = rwlock held for read
+ *  1 = rwlock held for write
+ *  2 = COND_RESCHED_SPIN = spinlock
+ *
  * This works OK both with and without CONFIG_PREEMPT.  We do strange low-level
  * operations here to prevent schedule() from being called twice (once via
- * spin_unlock(), once by hand).
+ * *_unlock(), once by hand).
  */
-int cond_resched_lock(spinlock_t *lock)
+int __cond_resched_lock(void *lock, int type)
 {
 	int ret = 0;
 
-	if (need_lockbreak(lock)) {
-		spin_unlock(lock);
+	if (__need_lockbreak(lock, type)) {
+		__drop_lock(lock, type);
 		cpu_relax();
 		ret = 1;
-		spin_lock(lock);
+		__reacquire_lock(lock, type);
 	}
 	if (need_resched() && system_state == SYSTEM_RUNNING) {
-		spin_release(&lock->dep_map, 1, _THIS_IP_);
-		_raw_spin_unlock(lock);
+		__release_lock(lock, type);
+		__drop_lock(lock, type);
 		preempt_enable_no_resched();
 		__cond_resched();
 		ret = 1;
-		spin_lock(lock);
+		__reacquire_lock(lock, type);
 	}
 	return ret;
 }
-EXPORT_SYMBOL(cond_resched_lock);
+EXPORT_SYMBOL(__cond_resched_lock);
 
 int __sched cond_resched_softirq(void)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
