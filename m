Message-Id: <200405222209.i4MM9cr13711@mail.osdl.org>
Subject: [patch 33/57] rmap 18: i_mmap_nonlinear
From: akpm@osdl.org
Date: Sat, 22 May 2004 15:09:08 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@osdl.org
Cc: linux-mm@kvack.org, akpm@osdl.org, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

From: Hugh Dickins <hugh@veritas.com>

The prio_tree is of no use to nonlinear vmas: currently we're having to search
the tree in the most inefficient way to find all its nonlinears.  At the very
least we need an indication of the unlikely case when there are some
nonlinears; but really, we'd do best to take them out of the prio_tree
altogether, into a list of their own - i_mmap_nonlinear.


---

 25-akpm/fs/inode.c         |    1 +
 25-akpm/include/linux/fs.h |    7 +++++--
 25-akpm/mm/fremap.c        |   12 +++++++++++-
 25-akpm/mm/memory.c        |   31 ++++++++++---------------------
 25-akpm/mm/mmap.c          |   15 ++++++++++-----
 25-akpm/mm/prio_tree.c     |    1 +
 25-akpm/mm/rmap.c          |   35 ++++++++++++++---------------------
 7 files changed, 52 insertions(+), 50 deletions(-)

diff -puN fs/inode.c~rmap-18-i_mmap_nonlinear fs/inode.c
--- 25/fs/inode.c~rmap-18-i_mmap_nonlinear	2004-05-22 14:56:26.831012592 -0700
+++ 25-akpm/fs/inode.c	2004-05-22 14:59:38.315902464 -0700
@@ -202,6 +202,7 @@ void inode_init_once(struct inode *inode
 	spin_lock_init(&inode->i_data.private_lock);
 	INIT_PRIO_TREE_ROOT(&inode->i_data.i_mmap);
 	INIT_PRIO_TREE_ROOT(&inode->i_data.i_mmap_shared);
+	INIT_LIST_HEAD(&inode->i_data.i_mmap_nonlinear);
 	spin_lock_init(&inode->i_lock);
 	i_size_ordered_init(inode);
 }
diff -puN include/linux/fs.h~rmap-18-i_mmap_nonlinear include/linux/fs.h
--- 25/include/linux/fs.h~rmap-18-i_mmap_nonlinear	2004-05-22 14:56:26.833012288 -0700
+++ 25-akpm/include/linux/fs.h	2004-05-22 14:59:38.316902312 -0700
@@ -332,6 +332,7 @@ struct address_space {
 	struct address_space_operations *a_ops;	/* methods */
 	struct prio_tree_root	i_mmap;		/* tree of private mappings */
 	struct prio_tree_root	i_mmap_shared;	/* tree of shared mappings */
+	struct list_head	i_mmap_nonlinear;/*list of nonlinear mappings */
 	spinlock_t		i_mmap_lock;	/* protect trees & list above */
 	atomic_t		truncate_count;	/* Cover race condition with truncate */
 	unsigned long		flags;		/* error bits/gfp mask */
@@ -382,7 +383,8 @@ int mapping_tagged(struct address_space 
 static inline int mapping_mapped(struct address_space *mapping)
 {
 	return	!prio_tree_empty(&mapping->i_mmap) ||
-		!prio_tree_empty(&mapping->i_mmap_shared);
+		!prio_tree_empty(&mapping->i_mmap_shared) ||
+		!list_empty(&mapping->i_mmap_nonlinear);
 }
 
 /*
@@ -393,7 +395,8 @@ static inline int mapping_mapped(struct 
  */
 static inline int mapping_writably_mapped(struct address_space *mapping)
 {
-	return	!prio_tree_empty(&mapping->i_mmap_shared);
+	return	!prio_tree_empty(&mapping->i_mmap_shared) ||
+		!list_empty(&mapping->i_mmap_nonlinear);
 }
 
 /*
diff -puN mm/fremap.c~rmap-18-i_mmap_nonlinear mm/fremap.c
--- 25/mm/fremap.c~rmap-18-i_mmap_nonlinear	2004-05-22 14:56:26.834012136 -0700
+++ 25-akpm/mm/fremap.c	2004-05-22 14:59:38.318902008 -0700
@@ -157,6 +157,7 @@ asmlinkage long sys_remap_file_pages(uns
 	unsigned long __prot, unsigned long pgoff, unsigned long flags)
 {
 	struct mm_struct *mm = current->mm;
+	struct address_space *mapping;
 	unsigned long end = start + size;
 	struct vm_area_struct *vma;
 	int err = -EINVAL;
@@ -197,8 +198,17 @@ asmlinkage long sys_remap_file_pages(uns
 				end <= vma->vm_end) {
 
 		/* Must set VM_NONLINEAR before any pages are populated. */
-		if (pgoff != linear_page_index(vma, start))
+		if (pgoff != linear_page_index(vma, start) &&
+		    !(vma->vm_flags & VM_NONLINEAR)) {
+			mapping = vma->vm_file->f_mapping;
+			spin_lock(&mapping->i_mmap_lock);
 			vma->vm_flags |= VM_NONLINEAR;
+			vma_prio_tree_remove(vma, &mapping->i_mmap_shared);
+			vma_prio_tree_init(vma);
+			list_add_tail(&vma->shared.vm_set.list,
+					&mapping->i_mmap_nonlinear);
+			spin_unlock(&mapping->i_mmap_lock);
+		}
 
 		/* ->populate can take a long time, so downgrade the lock. */
 		downgrade_write(&mm->mmap_sem);
diff -puN mm/memory.c~rmap-18-i_mmap_nonlinear mm/memory.c
--- 25/mm/memory.c~rmap-18-i_mmap_nonlinear	2004-05-22 14:56:26.836011832 -0700
+++ 25-akpm/mm/memory.c	2004-05-22 14:59:38.874817496 -0700
@@ -1116,8 +1116,6 @@ static void unmap_mapping_range_list(str
 
 	while ((vma = vma_prio_tree_next(vma, root, &iter,
 			details->first_index, details->last_index)) != NULL) {
-		if (unlikely(vma->vm_flags & VM_NONLINEAR))
-			continue;
 		vba = vma->vm_pgoff;
 		vea = vba + ((vma->vm_end - vma->vm_start) >> PAGE_SHIFT) - 1;
 		/* Assume for now that PAGE_CACHE_SHIFT == PAGE_SHIFT */
@@ -1133,22 +1131,6 @@ static void unmap_mapping_range_list(str
 	}
 }
 
-static void unmap_nonlinear_range_list(struct prio_tree_root *root,
-				       struct zap_details *details)
-{
-	struct vm_area_struct *vma = NULL;
-	struct prio_tree_iter iter;
-
-	while ((vma = vma_prio_tree_next(vma, root, &iter,
-						0, ULONG_MAX)) != NULL) {
-		if (!(vma->vm_flags & VM_NONLINEAR))
-			continue;
-		details->nonlinear_vma = vma;
-		zap_page_range(vma, vma->vm_start,
-				vma->vm_end - vma->vm_start, details);
-	}
-}
-
 /**
  * unmap_mapping_range - unmap the portion of all mmaps
  * in the specified address_space corresponding to the specified
@@ -1198,11 +1180,18 @@ void unmap_mapping_range(struct address_
 	/* Don't waste time to check mapping on fully shared vmas */
 	details.check_mapping = NULL;
 
-	if (unlikely(!prio_tree_empty(&mapping->i_mmap_shared))) {
+	if (unlikely(!prio_tree_empty(&mapping->i_mmap_shared)))
 		unmap_mapping_range_list(&mapping->i_mmap_shared, &details);
-		unmap_nonlinear_range_list(&mapping->i_mmap_shared, &details);
-	}
 
+	if (unlikely(!list_empty(&mapping->i_mmap_nonlinear))) {
+		struct vm_area_struct *vma;
+		list_for_each_entry(vma, &mapping->i_mmap_nonlinear,
+						shared.vm_set.list) {
+			details.nonlinear_vma = vma;
+			zap_page_range(vma, vma->vm_start,
+				vma->vm_end - vma->vm_start, &details);
+		}
+	}
 	spin_unlock(&mapping->i_mmap_lock);
 }
 EXPORT_SYMBOL(unmap_mapping_range);
diff -puN mm/mmap.c~rmap-18-i_mmap_nonlinear mm/mmap.c
--- 25/mm/mmap.c~rmap-18-i_mmap_nonlinear	2004-05-22 14:56:26.838011528 -0700
+++ 25-akpm/mm/mmap.c	2004-05-22 14:59:38.321901552 -0700
@@ -72,7 +72,9 @@ static inline void __remove_shared_vm_st
 	if (vma->vm_flags & VM_DENYWRITE)
 		atomic_inc(&file->f_dentry->d_inode->i_writecount);
 
-	if (vma->vm_flags & VM_SHARED)
+	if (unlikely(vma->vm_flags & VM_NONLINEAR))
+		list_del_init(&vma->shared.vm_set.list);
+	else if (vma->vm_flags & VM_SHARED)
 		vma_prio_tree_remove(vma, &mapping->i_mmap_shared);
 	else
 		vma_prio_tree_remove(vma, &mapping->i_mmap);
@@ -262,7 +264,10 @@ static inline void __vma_link_file(struc
 		if (vma->vm_flags & VM_DENYWRITE)
 			atomic_dec(&file->f_dentry->d_inode->i_writecount);
 
-		if (vma->vm_flags & VM_SHARED)
+		if (unlikely(vma->vm_flags & VM_NONLINEAR))
+			list_add_tail(&vma->shared.vm_set.list,
+					&mapping->i_mmap_nonlinear);
+		else if (vma->vm_flags & VM_SHARED)
 			vma_prio_tree_insert(vma, &mapping->i_mmap_shared);
 		else
 			vma_prio_tree_insert(vma, &mapping->i_mmap);
@@ -339,10 +344,10 @@ void vma_adjust(struct vm_area_struct *v
 
 	if (file) {
 		mapping = file->f_mapping;
-		if (vma->vm_flags & VM_SHARED)
-			root = &mapping->i_mmap_shared;
-		else
+		if (!(vma->vm_flags & VM_SHARED))
 			root = &mapping->i_mmap;
+		else if (!(vma->vm_flags & VM_NONLINEAR))
+			root = &mapping->i_mmap_shared;
 		spin_lock(&mapping->i_mmap_lock);
 	}
 	spin_lock(&mm->page_table_lock);
diff -puN mm/prio_tree.c~rmap-18-i_mmap_nonlinear mm/prio_tree.c
--- 25/mm/prio_tree.c~rmap-18-i_mmap_nonlinear	2004-05-22 14:56:26.839011376 -0700
+++ 25-akpm/mm/prio_tree.c	2004-05-22 14:59:38.321901552 -0700
@@ -530,6 +530,7 @@ repeat:
 /*
  * Add a new vma known to map the same set of pages as the old vma:
  * useful for fork's dup_mmap as well as vma_prio_tree_insert below.
+ * Note that it just happens to work correctly on i_mmap_nonlinear too.
  */
 void vma_prio_tree_add(struct vm_area_struct *vma, struct vm_area_struct *old)
 {
diff -puN mm/rmap.c~rmap-18-i_mmap_nonlinear mm/rmap.c
--- 25/mm/rmap.c~rmap-18-i_mmap_nonlinear	2004-05-22 14:56:26.841011072 -0700
+++ 25-akpm/mm/rmap.c	2004-05-22 14:59:38.459880576 -0700
@@ -335,10 +335,6 @@ static inline int page_referenced_file(s
 
 	while ((vma = vma_prio_tree_next(vma, &mapping->i_mmap_shared,
 					&iter, pgoff, pgoff)) != NULL) {
-		if (unlikely(vma->vm_flags & VM_NONLINEAR)) {
-			failed++;
-			continue;
-		}
 		if (vma->vm_flags & (VM_LOCKED|VM_RESERVED)) {
 			referenced++;
 			goto out;
@@ -352,8 +348,8 @@ static inline int page_referenced_file(s
 		}
 	}
 
-	/* Hmm, but what of the nonlinears which pgoff,pgoff skipped? */
-	WARN_ON(!failed);
+	if (list_empty(&mapping->i_mmap_nonlinear))
+		WARN_ON(!failed);
 out:
 	spin_unlock(&mapping->i_mmap_lock);
 	return referenced;
@@ -757,8 +753,6 @@ static inline int try_to_unmap_file(stru
 
 	while ((vma = vma_prio_tree_next(vma, &mapping->i_mmap_shared,
 					&iter, pgoff, pgoff)) != NULL) {
-		if (unlikely(vma->vm_flags & VM_NONLINEAR))
-			continue;
 		if (vma->vm_mm->rss) {
 			address = vma_address(vma, pgoff);
 			ret = try_to_unmap_one(page,
@@ -768,10 +762,12 @@ static inline int try_to_unmap_file(stru
 		}
 	}
 
-	while ((vma = vma_prio_tree_next(vma, &mapping->i_mmap_shared,
-					&iter, 0, ULONG_MAX)) != NULL) {
-		if (VM_NONLINEAR != (vma->vm_flags &
-		     (VM_NONLINEAR|VM_LOCKED|VM_RESERVED)))
+	if (list_empty(&mapping->i_mmap_nonlinear))
+		goto out;
+
+	list_for_each_entry(vma, &mapping->i_mmap_nonlinear,
+						shared.vm_set.list) {
+		if (vma->vm_flags & (VM_LOCKED|VM_RESERVED))
 			continue;
 		cursor = (unsigned long) vma->vm_private_data;
 		if (cursor > max_nl_cursor)
@@ -799,10 +795,9 @@ static inline int try_to_unmap_file(stru
 		max_nl_cursor = CLUSTER_SIZE;
 
 	do {
-		while ((vma = vma_prio_tree_next(vma, &mapping->i_mmap_shared,
-					&iter, 0, ULONG_MAX)) != NULL) {
-			if (VM_NONLINEAR != (vma->vm_flags &
-		    	     (VM_NONLINEAR|VM_LOCKED|VM_RESERVED)))
+		list_for_each_entry(vma, &mapping->i_mmap_nonlinear,
+						shared.vm_set.list) {
+			if (vma->vm_flags & (VM_LOCKED|VM_RESERVED))
 				continue;
 			cursor = (unsigned long) vma->vm_private_data;
 			while (vma->vm_mm->rss &&
@@ -831,11 +826,9 @@ static inline int try_to_unmap_file(stru
 	 * in locked vmas).  Reset cursor on all unreserved nonlinear
 	 * vmas, now forgetting on which ones it had fallen behind.
 	 */
-	vma = NULL;	/* it is already, but above loop might change */
-	while ((vma = vma_prio_tree_next(vma, &mapping->i_mmap_shared,
-					&iter, 0, ULONG_MAX)) != NULL) {
-		if ((vma->vm_flags & (VM_NONLINEAR|VM_RESERVED)) ==
-				VM_NONLINEAR)
+	list_for_each_entry(vma, &mapping->i_mmap_nonlinear,
+						shared.vm_set.list) {
+		if (!(vma->vm_flags & VM_RESERVED))
 			vma->vm_private_data = 0;
 	}
 relock:

_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
