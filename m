Message-Id: <200405222211.i4MMB2r14021@mail.osdl.org>
Subject: [patch 38/57] rmap 20 i_mmap_shared into i_mmap
From: akpm@osdl.org
Date: Sat, 22 May 2004 15:10:31 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@osdl.org
Cc: linux-mm@kvack.org, akpm@osdl.org, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

From: Hugh Dickins <hugh@veritas.com>

Why should struct address_space have separate i_mmap and i_mmap_shared
prio_trees (separating !VM_SHARED and VM_SHARED vmas)?  No good reason, the
same processing is usually needed on both.  Merge i_mmap_shared into i_mmap,
but keep i_mmap_writable count of VM_SHARED vmas (those capable of dirtying
the underlying file) for the mapping_writably_mapped test.

The VM_MAYSHARE test in the arm and parisc loops is not necessarily what they
will want to use in the end: it's provided as a harmless example of what might
be appropriate, but maintainers are likely to revise it later (that parisc
loop is currently being changed in the parisc tree anyway).

On the way, remove the now out-of-date comments on vm_area_struct size.


---

 25-akpm/Documentation/cachetlb.txt |    8 +++----
 25-akpm/arch/arm/mm/fault-armv.c   |    8 +++++--
 25-akpm/arch/parisc/kernel/cache.c |   42 ++++++++-----------------------------
 25-akpm/fs/hugetlbfs/inode.c       |    4 ---
 25-akpm/fs/inode.c                 |    1 
 25-akpm/include/linux/fs.h         |   12 ++++------
 25-akpm/include/linux/mm.h         |    4 ++-
 25-akpm/mm/fremap.c                |    2 -
 25-akpm/mm/memory.c                |   10 +-------
 25-akpm/mm/mmap.c                  |   22 ++++++++-----------
 25-akpm/mm/prio_tree.c             |    6 ++---
 25-akpm/mm/rmap.c                  |   26 ----------------------
 12 files changed, 45 insertions(+), 100 deletions(-)

diff -puN arch/arm/mm/fault-armv.c~rmap-20-i_mmap_shared-into-i_mmap arch/arm/mm/fault-armv.c
--- 25/arch/arm/mm/fault-armv.c~rmap-20-i_mmap_shared-into-i_mmap	2004-05-22 14:56:27.534905584 -0700
+++ 25-akpm/arch/arm/mm/fault-armv.c	2004-05-22 14:59:37.972954600 -0700
@@ -94,13 +94,15 @@ void __flush_dcache_page(struct page *pa
 	 * and invalidate any user data.
 	 */
 	pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
-	while ((mpnt = vma_prio_tree_next(mpnt, &mapping->i_mmap_shared,
+	while ((mpnt = vma_prio_tree_next(mpnt, &mapping->i_mmap,
 					&iter, pgoff, pgoff)) != NULL) {
 		/*
 		 * If this VMA is not in our MM, we can ignore it.
 		 */
 		if (mpnt->vm_mm != mm)
 			continue;
+		if (!(mpnt->vm_flags & VM_MAYSHARE))
+			continue;
 		offset = (pgoff - mpnt->vm_pgoff) << PAGE_SHIFT;
 		flush_cache_page(mpnt, mpnt->vm_start + offset);
 	}
@@ -127,7 +129,7 @@ make_coherent(struct vm_area_struct *vma
 	 * space, then we need to handle them specially to maintain
 	 * cache coherency.
 	 */
-	while ((mpnt = vma_prio_tree_next(mpnt, &mapping->i_mmap_shared,
+	while ((mpnt = vma_prio_tree_next(mpnt, &mapping->i_mmap,
 					&iter, pgoff, pgoff)) != NULL) {
 		/*
 		 * If this VMA is not in our MM, we can ignore it.
@@ -136,6 +138,8 @@ make_coherent(struct vm_area_struct *vma
 		 */
 		if (mpnt->vm_mm != mm || mpnt == vma)
 			continue;
+		if (!(mpnt->vm_flags & VM_MAYSHARE))
+			continue;
 		offset = (pgoff - mpnt->vm_pgoff) << PAGE_SHIFT;
 		aliases += adjust_pte(mpnt, mpnt->vm_start + offset);
 	}
diff -puN arch/parisc/kernel/cache.c~rmap-20-i_mmap_shared-into-i_mmap arch/parisc/kernel/cache.c
--- 25/arch/parisc/kernel/cache.c~rmap-20-i_mmap_shared-into-i_mmap	2004-05-22 14:56:27.536905280 -0700
+++ 25-akpm/arch/parisc/kernel/cache.c	2004-05-22 14:59:37.973954448 -0700
@@ -244,46 +244,24 @@ void __flush_dcache_page(struct page *pa
 
 	pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
 
-	/* We have ensured in arch_get_unmapped_area() that all shared
-	 * mappings are mapped at equivalent addresses, so we only need
-	 * to flush one for them all to become coherent */
-
-	while ((mpnt = vma_prio_tree_next(mpnt, &mapping->i_mmap_shared,
-					&iter, pgoff, pgoff)) != NULL) {
-		offset = (pgoff - mpnt->vm_pgoff) << PAGE_SHIFT;
-		addr = mpnt->vm_start + offset;
-
-		/* flush instructions produce non access tlb misses.
-		 * On PA, we nullify these instructions rather than 
-		 * taking a page fault if the pte doesn't exist, so we
-		 * have to find a congruent address with an existing
-		 * translation */
-
-		if (!translation_exists(mpnt, addr))
-			continue;
-
-		__flush_cache_page(mpnt, addr);
-
-		/* If we find an address to flush, that will also
-		 * bring all the private mappings up to date (see
-		 * comment below) */
-		return;
-	}
-
-	/* we have carefully arranged in arch_get_unmapped_area() that
+	/* We have carefully arranged in arch_get_unmapped_area() that
 	 * *any* mappings of a file are always congruently mapped (whether
 	 * declared as MAP_PRIVATE or MAP_SHARED), so we only need
-	 * to flush one address here too */
+	 * to flush one address here for them all to become coherent */
 
 	while ((mpnt = vma_prio_tree_next(mpnt, &mapping->i_mmap,
 					&iter, pgoff, pgoff)) != NULL) {
 		offset = (pgoff - mpnt->vm_pgoff) << PAGE_SHIFT;
 		addr = mpnt->vm_start + offset;
 
-		/* This is just for speed.  If the page translation isn't
-		 * there there's no point exciting the nadtlb handler into
-		 * a nullification frenzy */
-		if(!translation_exists(mpnt, addr))
+		/* Flush instructions produce non access tlb misses.
+		 * On PA, we nullify these instructions rather than
+		 * taking a page fault if the pte doesn't exist.
+		 * This is just for speed.  If the page translation
+		 * isn't there, there's no point exciting the
+		 * nadtlb handler into a nullification frenzy */
+
+		if (!translation_exists(mpnt, addr))
 			continue;
 
 		__flush_cache_page(mpnt, addr);
diff -puN Documentation/cachetlb.txt~rmap-20-i_mmap_shared-into-i_mmap Documentation/cachetlb.txt
--- 25/Documentation/cachetlb.txt~rmap-20-i_mmap_shared-into-i_mmap	2004-05-22 14:56:27.537905128 -0700
+++ 25-akpm/Documentation/cachetlb.txt	2004-05-22 14:56:27.555902392 -0700
@@ -322,10 +322,10 @@ maps this page at its virtual address.
 	about doing this.
 
 	The idea is, first at flush_dcache_page() time, if
-	page->mapping->i_mmap{,_shared} are empty lists, just mark the
-	architecture private page flag bit.  Later, in
-	update_mmu_cache(), a check is made of this flag bit, and if
-	set the flush is done and the flag bit is cleared.
+	page->mapping->i_mmap is an empty tree and ->i_mmap_nonlinear
+	an empty list, just mark the architecture private page flag bit.
+	Later, in update_mmu_cache(), a check is made of this flag bit,
+	and if set the flush is done and the flag bit is cleared.
 
 	IMPORTANT NOTE: It is often important, if you defer the flush,
 			that the actual flush occurs on the same CPU
diff -puN fs/hugetlbfs/inode.c~rmap-20-i_mmap_shared-into-i_mmap fs/hugetlbfs/inode.c
--- 25/fs/hugetlbfs/inode.c~rmap-20-i_mmap_shared-into-i_mmap	2004-05-22 14:56:27.539904824 -0700
+++ 25-akpm/fs/hugetlbfs/inode.c	2004-05-22 14:56:27.555902392 -0700
@@ -266,7 +266,7 @@ static void hugetlbfs_drop_inode(struct 
  * h_pgoff is in HPAGE_SIZE units.
  * vma->vm_pgoff is in PAGE_SIZE units.
  */
-static void
+static inline void
 hugetlb_vmtruncate_list(struct prio_tree_root *root, unsigned long h_pgoff)
 {
 	struct vm_area_struct *vma = NULL;
@@ -312,8 +312,6 @@ static int hugetlb_vmtruncate(struct ino
 	spin_lock(&mapping->i_mmap_lock);
 	if (!prio_tree_empty(&mapping->i_mmap))
 		hugetlb_vmtruncate_list(&mapping->i_mmap, pgoff);
-	if (!prio_tree_empty(&mapping->i_mmap_shared))
-		hugetlb_vmtruncate_list(&mapping->i_mmap_shared, pgoff);
 	spin_unlock(&mapping->i_mmap_lock);
 	truncate_hugepages(mapping, offset);
 	return 0;
diff -puN fs/inode.c~rmap-20-i_mmap_shared-into-i_mmap fs/inode.c
--- 25/fs/inode.c~rmap-20-i_mmap_shared-into-i_mmap	2004-05-22 14:56:27.541904520 -0700
+++ 25-akpm/fs/inode.c	2004-05-22 14:56:27.557902088 -0700
@@ -201,7 +201,6 @@ void inode_init_once(struct inode *inode
 	INIT_LIST_HEAD(&inode->i_data.private_list);
 	spin_lock_init(&inode->i_data.private_lock);
 	INIT_PRIO_TREE_ROOT(&inode->i_data.i_mmap);
-	INIT_PRIO_TREE_ROOT(&inode->i_data.i_mmap_shared);
 	INIT_LIST_HEAD(&inode->i_data.i_mmap_nonlinear);
 	spin_lock_init(&inode->i_lock);
 	i_size_ordered_init(inode);
diff -puN include/linux/fs.h~rmap-20-i_mmap_shared-into-i_mmap include/linux/fs.h
--- 25/include/linux/fs.h~rmap-20-i_mmap_shared-into-i_mmap	2004-05-22 14:56:27.542904368 -0700
+++ 25-akpm/include/linux/fs.h	2004-05-22 14:56:27.558901936 -0700
@@ -331,9 +331,9 @@ struct address_space {
 	pgoff_t			writeback_index;/* writeback starts here */
 	struct address_space_operations *a_ops;	/* methods */
 	struct prio_tree_root	i_mmap;		/* tree of private mappings */
-	struct prio_tree_root	i_mmap_shared;	/* tree of shared mappings */
-	struct list_head	i_mmap_nonlinear;/*list of nonlinear mappings */
-	spinlock_t		i_mmap_lock;	/* protect trees & list above */
+	unsigned int		i_mmap_writable;/* count VM_SHARED mappings */
+	struct list_head	i_mmap_nonlinear;/*list VM_NONLINEAR mappings */
+	spinlock_t		i_mmap_lock;	/* protect tree, count, list */
 	atomic_t		truncate_count;	/* Cover race condition with truncate */
 	unsigned long		flags;		/* error bits/gfp mask */
 	struct backing_dev_info *backing_dev_info; /* device readahead, etc */
@@ -383,20 +383,18 @@ int mapping_tagged(struct address_space 
 static inline int mapping_mapped(struct address_space *mapping)
 {
 	return	!prio_tree_empty(&mapping->i_mmap) ||
-		!prio_tree_empty(&mapping->i_mmap_shared) ||
 		!list_empty(&mapping->i_mmap_nonlinear);
 }
 
 /*
  * Might pages of this file have been modified in userspace?
- * Note that i_mmap_shared holds all the VM_SHARED vmas: do_mmap_pgoff
+ * Note that i_mmap_writable counts all VM_SHARED vmas: do_mmap_pgoff
  * marks vma as VM_SHARED if it is shared, and the file was opened for
  * writing i.e. vma may be mprotected writable even if now readonly.
  */
 static inline int mapping_writably_mapped(struct address_space *mapping)
 {
-	return	!prio_tree_empty(&mapping->i_mmap_shared) ||
-		!list_empty(&mapping->i_mmap_nonlinear);
+	return mapping->i_mmap_writable != 0;
 }
 
 /*
diff -puN include/linux/mm.h~rmap-20-i_mmap_shared-into-i_mmap include/linux/mm.h
--- 25/include/linux/mm.h~rmap-20-i_mmap_shared-into-i_mmap	2004-05-22 14:56:27.544904064 -0700
+++ 25-akpm/include/linux/mm.h	2004-05-22 14:59:36.589164968 -0700
@@ -64,7 +64,9 @@ struct vm_area_struct {
 
 	/*
 	 * For areas with an address space and backing store,
-	 * one of the address_space->i_mmap{,shared} trees.
+	 * linkage into the address_space->i_mmap prio tree, or
+	 * linkage to the list of like vmas hanging off its node, or
+	 * linkage of vma in the address_space->i_mmap_nonlinear list.
 	 */
 	union {
 		struct {
diff -puN mm/fremap.c~rmap-20-i_mmap_shared-into-i_mmap mm/fremap.c
--- 25/mm/fremap.c~rmap-20-i_mmap_shared-into-i_mmap	2004-05-22 14:56:27.545903912 -0700
+++ 25-akpm/mm/fremap.c	2004-05-22 14:59:37.979953536 -0700
@@ -203,7 +203,7 @@ asmlinkage long sys_remap_file_pages(uns
 			mapping = vma->vm_file->f_mapping;
 			spin_lock(&mapping->i_mmap_lock);
 			vma->vm_flags |= VM_NONLINEAR;
-			vma_prio_tree_remove(vma, &mapping->i_mmap_shared);
+			vma_prio_tree_remove(vma, &mapping->i_mmap);
 			vma_prio_tree_init(vma);
 			list_add_tail(&vma->shared.vm_set.list,
 					&mapping->i_mmap_nonlinear);
diff -puN mm/memory.c~rmap-20-i_mmap_shared-into-i_mmap mm/memory.c
--- 25/mm/memory.c~rmap-20-i_mmap_shared-into-i_mmap	2004-05-22 14:56:27.546903760 -0700
+++ 25-akpm/mm/memory.c	2004-05-22 14:59:36.849125448 -0700
@@ -1107,8 +1107,8 @@ no_new_page:
 /*
  * Helper function for unmap_mapping_range().
  */
-static void unmap_mapping_range_list(struct prio_tree_root *root,
-				     struct zap_details *details)
+static inline void unmap_mapping_range_list(struct prio_tree_root *root,
+					    struct zap_details *details)
 {
 	struct vm_area_struct *vma = NULL;
 	struct prio_tree_iter iter;
@@ -1177,12 +1177,6 @@ void unmap_mapping_range(struct address_
 	if (unlikely(!prio_tree_empty(&mapping->i_mmap)))
 		unmap_mapping_range_list(&mapping->i_mmap, &details);
 
-	/* Don't waste time to check mapping on fully shared vmas */
-	details.check_mapping = NULL;
-
-	if (unlikely(!prio_tree_empty(&mapping->i_mmap_shared)))
-		unmap_mapping_range_list(&mapping->i_mmap_shared, &details);
-
 	/*
 	 * In nonlinear VMAs there is no correspondence between virtual address
 	 * offset and file offset.  So we must perform an exhaustive search
diff -puN mm/mmap.c~rmap-20-i_mmap_shared-into-i_mmap mm/mmap.c
--- 25/mm/mmap.c~rmap-20-i_mmap_shared-into-i_mmap	2004-05-22 14:56:27.548903456 -0700
+++ 25-akpm/mm/mmap.c	2004-05-22 14:59:37.980953384 -0700
@@ -71,11 +71,11 @@ static inline void __remove_shared_vm_st
 {
 	if (vma->vm_flags & VM_DENYWRITE)
 		atomic_inc(&file->f_dentry->d_inode->i_writecount);
+	if (vma->vm_flags & VM_SHARED)
+		mapping->i_mmap_writable--;
 
 	if (unlikely(vma->vm_flags & VM_NONLINEAR))
 		list_del_init(&vma->shared.vm_set.list);
-	else if (vma->vm_flags & VM_SHARED)
-		vma_prio_tree_remove(vma, &mapping->i_mmap_shared);
 	else
 		vma_prio_tree_remove(vma, &mapping->i_mmap);
 }
@@ -263,12 +263,12 @@ static inline void __vma_link_file(struc
 
 		if (vma->vm_flags & VM_DENYWRITE)
 			atomic_dec(&file->f_dentry->d_inode->i_writecount);
+		if (vma->vm_flags & VM_SHARED)
+			mapping->i_mmap_writable++;
 
 		if (unlikely(vma->vm_flags & VM_NONLINEAR))
 			list_add_tail(&vma->shared.vm_set.list,
 					&mapping->i_mmap_nonlinear);
-		else if (vma->vm_flags & VM_SHARED)
-			vma_prio_tree_insert(vma, &mapping->i_mmap_shared);
 		else
 			vma_prio_tree_insert(vma, &mapping->i_mmap);
 	}
@@ -308,8 +308,8 @@ static void vma_link(struct mm_struct *m
 }
 
 /*
- * Insert vm structure into process list sorted by address and into the inode's
- * i_mmap ring. The caller should hold mm->page_table_lock and
+ * Insert vm structure into process list sorted by address and into the
+ * inode's i_mmap tree. The caller should hold mm->page_table_lock and
  * ->f_mappping->i_mmap_lock if vm_file is non-NULL.
  */
 static void
@@ -328,8 +328,8 @@ __insert_vm_struct(struct mm_struct * mm
 }
 
 /*
- * We cannot adjust vm_start, vm_end, vm_pgoff fields of a vma that is
- * already present in an i_mmap{_shared} tree without adjusting the tree.
+ * We cannot adjust vm_start, vm_end, vm_pgoff fields of a vma that
+ * is already present in an i_mmap tree without adjusting the tree.
  * The following helper function should be used when such adjustments
  * are necessary.  The "next" vma (if any) is to be removed or inserted
  * before we drop the necessary locks.
@@ -344,10 +344,8 @@ void vma_adjust(struct vm_area_struct *v
 
 	if (file) {
 		mapping = file->f_mapping;
-		if (!(vma->vm_flags & VM_SHARED))
+		if (!(vma->vm_flags & VM_NONLINEAR))
 			root = &mapping->i_mmap;
-		else if (!(vma->vm_flags & VM_NONLINEAR))
-			root = &mapping->i_mmap_shared;
 		spin_lock(&mapping->i_mmap_lock);
 	}
 	spin_lock(&mm->page_table_lock);
@@ -1516,7 +1514,7 @@ void exit_mmap(struct mm_struct *mm)
 }
 
 /* Insert vm structure into process list sorted by address
- * and into the inode's i_mmap ring.  If vm_file is non-NULL
+ * and into the inode's i_mmap tree.  If vm_file is non-NULL
  * then i_mmap_lock is taken here.
  */
 void insert_vm_struct(struct mm_struct * mm, struct vm_area_struct * vma)
diff -puN mm/prio_tree.c~rmap-20-i_mmap_shared-into-i_mmap mm/prio_tree.c
--- 25/mm/prio_tree.c~rmap-20-i_mmap_shared-into-i_mmap	2004-05-22 14:56:27.549903304 -0700
+++ 25-akpm/mm/prio_tree.c	2004-05-22 14:59:35.233371080 -0700
@@ -1,5 +1,5 @@
 /*
- * mm/prio_tree.c - priority search tree for mapping->i_mmap{,_shared}
+ * mm/prio_tree.c - priority search tree for mapping->i_mmap
  *
  * Copyright (C) 2004, Rajesh Venkatasubramanian <vrajesh@umich.edu>
  *
@@ -41,7 +41,7 @@
  */
 
 /*
- * The following macros are used for implementing prio_tree for i_mmap{_shared}
+ * The following macros are used for implementing prio_tree for i_mmap
  */
 
 #define RADIX_INDEX(vma)  ((vma)->vm_pgoff)
@@ -491,7 +491,7 @@ repeat:
 }
 
 /*
- * Radix priority search tree for address_space->i_mmap_{_shared}
+ * Radix priority search tree for address_space->i_mmap
  *
  * For each vma that map a unique set of file pages i.e., unique [radix_index,
  * heap_index] value, we have a corresponing priority search tree node. If
diff -puN mm/rmap.c~rmap-20-i_mmap_shared-into-i_mmap mm/rmap.c
--- 25/mm/rmap.c~rmap-20-i_mmap_shared-into-i_mmap	2004-05-22 14:56:27.550903152 -0700
+++ 25-akpm/mm/rmap.c	2004-05-22 14:59:38.116932712 -0700
@@ -328,21 +328,6 @@ static inline int page_referenced_file(s
 		}
 	}
 
-	while ((vma = vma_prio_tree_next(vma, &mapping->i_mmap_shared,
-					&iter, pgoff, pgoff)) != NULL) {
-		if (vma->vm_flags & (VM_LOCKED|VM_RESERVED)) {
-			referenced++;
-			goto out;
-		}
-		if (vma->vm_mm->rss) {
-			address = vma_address(vma, pgoff);
-			referenced += page_referenced_one(page,
-				vma->vm_mm, address, &mapcount, &failed);
-			if (!mapcount)
-				goto out;
-		}
-	}
-
 	if (list_empty(&mapping->i_mmap_nonlinear))
 		WARN_ON(!failed);
 out:
@@ -745,17 +730,6 @@ static inline int try_to_unmap_file(stru
 		}
 	}
 
-	while ((vma = vma_prio_tree_next(vma, &mapping->i_mmap_shared,
-					&iter, pgoff, pgoff)) != NULL) {
-		if (vma->vm_mm->rss) {
-			address = vma_address(vma, pgoff);
-			ret = try_to_unmap_one(page,
-				vma->vm_mm, address, &mapcount, vma);
-			if (ret == SWAP_FAIL || !mapcount)
-				goto out;
-		}
-	}
-
 	if (list_empty(&mapping->i_mmap_nonlinear))
 		goto out;
 

_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
