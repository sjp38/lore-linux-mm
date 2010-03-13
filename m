Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id B6CAD6B0166
	for <linux-mm@kvack.org>; Sat, 13 Mar 2010 05:49:03 -0500 (EST)
Date: Sat, 13 Mar 2010 11:49:00 +0100
From: Christian Ehrhardt <lk@c--e.de>
Subject: [PATCH 1/2] rmap: Fix Bugzilla Bug #5493
Message-ID: <20100313104900.GB16643@lisa.in-ulm.de>
References: <20100313104546.GA16643@lisa.in-ulm.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100313104546.GA16643@lisa.in-ulm.de>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>


Make the vma prio tree resusable.

Signed-off-by: Christian Ehrhardt <lk@c--e.de>

diff --git a/arch/arm/mm/fault-armv.c b/arch/arm/mm/fault-armv.c
index c9b97e9..4b8d01f 100644
--- a/arch/arm/mm/fault-armv.c
+++ b/arch/arm/mm/fault-armv.c
@@ -117,7 +117,8 @@ make_coherent(struct address_space *mapping, struct vm_area_struct *vma,
 	 * cache coherency.
 	 */
 	flush_dcache_mmap_lock(mapping);
-	vma_prio_tree_foreach(mpnt, &iter, &mapping->i_mmap, pgoff, pgoff) {
+	vma_prio_tree_foreach(mpnt, struct vm_area_struct, shared, &iter,
+				&mapping->i_mmap, pgoff, pgoff) {
 		/*
 		 * If this VMA is not in our MM, we can ignore it.
 		 * Note that we intentionally mask out the VMA
diff --git a/arch/arm/mm/flush.c b/arch/arm/mm/flush.c
index e34f095..5264230 100644
--- a/arch/arm/mm/flush.c
+++ b/arch/arm/mm/flush.c
@@ -194,7 +194,8 @@ static void __flush_dcache_aliases(struct address_space *mapping, struct page *p
 	pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
 
 	flush_dcache_mmap_lock(mapping);
-	vma_prio_tree_foreach(mpnt, &iter, &mapping->i_mmap, pgoff, pgoff) {
+	vma_prio_tree_foreach(mpnt, struct vm_area_struct, shared, &iter,
+					&mapping->i_mmap, pgoff, pgoff) {
 		unsigned long offset;
 
 		/*
diff --git a/arch/parisc/kernel/cache.c b/arch/parisc/kernel/cache.c
index 1054baa..79cb608 100644
--- a/arch/parisc/kernel/cache.c
+++ b/arch/parisc/kernel/cache.c
@@ -365,7 +365,8 @@ void flush_dcache_page(struct page *page)
 	 * to flush one address here for them all to become coherent */
 
 	flush_dcache_mmap_lock(mapping);
-	vma_prio_tree_foreach(mpnt, &iter, &mapping->i_mmap, pgoff, pgoff) {
+	vma_prio_tree_foreach(mpnt, struct vm_area_struct, shared, &iter,
+					&mapping->i_mmap, pgoff, pgoff) {
 		offset = (pgoff - mpnt->vm_pgoff) << PAGE_SHIFT;
 		addr = mpnt->vm_start + offset;
 
diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
index f46c340..f7a7954 100644
--- a/arch/x86/mm/hugetlbpage.c
+++ b/arch/x86/mm/hugetlbpage.c
@@ -74,7 +74,8 @@ static void huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
 		return;
 
 	spin_lock(&mapping->i_mmap_lock);
-	vma_prio_tree_foreach(svma, &iter, &mapping->i_mmap, idx, idx) {
+	vma_prio_tree_foreach(svma, struct vm_area_struct, shared, &iter,
+					&mapping->i_mmap, idx, idx) {
 		if (svma == vma)
 			continue;
 
diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index a0bbd3d..1827552 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -400,7 +400,8 @@ hugetlb_vmtruncate_list(struct prio_tree_root *root, pgoff_t pgoff)
 	struct vm_area_struct *vma;
 	struct prio_tree_iter iter;
 
-	vma_prio_tree_foreach(vma, &iter, root, pgoff, ULONG_MAX) {
+	vma_prio_tree_foreach(vma, struct vm_area_struct, shared, &iter, root,
+						pgoff, ULONG_MAX) {
 		unsigned long v_offset;
 
 		/*
diff --git a/fs/inode.c b/fs/inode.c
index 407bf39..2aaf2f4 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -261,7 +261,7 @@ void inode_init_once(struct inode *inode)
 	spin_lock_init(&inode->i_data.i_mmap_lock);
 	INIT_LIST_HEAD(&inode->i_data.private_list);
 	spin_lock_init(&inode->i_data.private_lock);
-	INIT_RAW_PRIO_TREE_ROOT(&inode->i_data.i_mmap);
+	INIT_SHARED_PRIO_TREE_ROOT(&inode->i_data.i_mmap);
 	INIT_LIST_HEAD(&inode->i_data.i_mmap_nonlinear);
 	i_size_ordered_init(inode);
 #ifdef CONFIG_INOTIFY
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 3899395..81e6482 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1197,15 +1197,33 @@ extern atomic_long_t mmap_pages_allocated;
 extern int nommu_shrink_inode_mappings(struct inode *, size_t, size_t);
 
 /* prio_tree.c */
-void vma_prio_tree_add(struct vm_area_struct *, struct vm_area_struct *old);
-void vma_prio_tree_insert(struct vm_area_struct *, struct prio_tree_root *);
-void vma_prio_tree_remove(struct vm_area_struct *, struct prio_tree_root *);
-struct vm_area_struct *vma_prio_tree_next(struct vm_area_struct *vma,
+void vma_prio_tree_add(union vma_prio_tree_node *node,
+	union vma_prio_tree_node *old);
+void vma_prio_tree_insert(union vma_prio_tree_node *, struct prio_tree_root *);
+void vma_prio_tree_remove(union vma_prio_tree_node *, struct prio_tree_root *);
+union vma_prio_tree_node *vma_prio_tree_next(union vma_prio_tree_node *,
 	struct prio_tree_iter *iter);
 
-#define vma_prio_tree_foreach(vma, iter, root, begin, end)	\
-	for (prio_tree_iter_init(iter, root, begin, end), vma = NULL;	\
-		(vma = vma_prio_tree_next(vma, iter)); )
+#define vma_prio_tree_first_entry(iter, type, field, root, begin, end)	\
+({									\
+	union vma_prio_tree_node *__t;					\
+	prio_tree_iter_init(iter, root, begin, end);			\
+	__t = vma_prio_tree_next(NULL, iter);				\
+	__t ? prio_tree_entry(__t, type, field) : NULL;\
+})
+
+#define vma_prio_tree_next_entry(obj, iter, type, field)		\
+({									\
+	union vma_prio_tree_node *__t;					\
+	__t = vma_prio_tree_next(&(obj)->field, iter);			\
+	__t ? prio_tree_entry(__t, type, field) : NULL;			\
+})
+
+#define vma_prio_tree_foreach(obj, type, field, iter, root, begin, end)	\
+	for (obj = vma_prio_tree_first_entry(				\
+				iter, type, field, root, begin, end);	\
+	     obj ;							\
+	     obj = vma_prio_tree_next_entry(obj, iter, type, field))
 
 static inline void vma_nonlinear_insert(struct vm_area_struct *vma,
 					struct list_head *list)
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 048b462..06b74c1 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -147,15 +147,7 @@ struct vm_area_struct {
 	 * linkage to the list of like vmas hanging off its node, or
 	 * linkage of vma in the address_space->i_mmap_nonlinear list.
 	 */
-	union {
-		struct {
-			struct list_head list;
-			void *parent;	/* aligns with prio_tree_node parent */
-			struct vm_area_struct *head;
-		} vm_set;
-
-		struct raw_prio_tree_node prio_tree_node;
-	} shared;
+	union vma_prio_tree_node shared;
 
 	/*
 	 * A file's MAP_PRIVATE vma can be in both i_mmap tree and anon_vma
diff --git a/include/linux/prio_tree.h b/include/linux/prio_tree.h
index db04abb..ae683b2 100644
--- a/include/linux/prio_tree.h
+++ b/include/linux/prio_tree.h
@@ -25,13 +25,25 @@ struct prio_tree_node {
 	unsigned long		last;	/* last location _in_ interval */
 };
 
+union vma_prio_tree_node {
+	struct {
+		struct list_head list;
+		void *parent;
+		union vma_prio_tree_node *head;
+	} vm_set;
+	struct raw_prio_tree_node prio_tree_node;
+};
+
 struct prio_tree_root {
 	struct prio_tree_node	*prio_tree_node;
 	unsigned short 		index_bits;
 	unsigned short		raw;
 		/*
 		 * 0: nodes are of type struct prio_tree_node
-		 * 1: nodes are of type raw_prio_tree_node
+		 * 1: nodes are of type raw_prio_tree_node and the vmas
+		 *    use the shared field.
+		 * 2: nodes are of type raw_prio_tree_node and the vmas
+		 *    use the anon field.
 		 */
 };
 
@@ -63,7 +75,8 @@ do {					\
 } while (0)
 
 #define INIT_PRIO_TREE_ROOT(ptr)	__INIT_PRIO_TREE_ROOT(ptr, 0)
-#define INIT_RAW_PRIO_TREE_ROOT(ptr)	__INIT_PRIO_TREE_ROOT(ptr, 1)
+#define INIT_SHARED_PRIO_TREE_ROOT(ptr)	__INIT_PRIO_TREE_ROOT(ptr, 1)
+#define INIT_ANON_PRIO_TREE_ROOT(ptr)	__INIT_PRIO_TREE_ROOT(ptr, 2)
 
 #define INIT_PRIO_TREE_NODE(ptr)				\
 do {								\
diff --git a/kernel/fork.c b/kernel/fork.c
index b0ec34a..f1362dc 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -354,7 +354,7 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 			tmp->vm_truncate_count = mpnt->vm_truncate_count;
 			flush_dcache_mmap_lock(mapping);
 			/* insert tmp into the share list, just after mpnt */
-			vma_prio_tree_add(tmp, mpnt);
+			vma_prio_tree_add(&tmp->shared, &mpnt->shared);
 			flush_dcache_mmap_unlock(mapping);
 			spin_unlock(&mapping->i_mmap_lock);
 		}
diff --git a/mm/filemap_xip.c b/mm/filemap_xip.c
index 78b94f0..f0e36fe 100644
--- a/mm/filemap_xip.c
+++ b/mm/filemap_xip.c
@@ -183,7 +183,8 @@ __xip_unmap (struct address_space * mapping,
 
 retry:
 	spin_lock(&mapping->i_mmap_lock);
-	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
+	vma_prio_tree_foreach(vma, struct vm_area_struct, shared, &iter,
+					&mapping->i_mmap, pgoff, pgoff) {
 		mm = vma->vm_mm;
 		address = vma->vm_start +
 			((pgoff - vma->vm_pgoff) << PAGE_SHIFT);
diff --git a/mm/fremap.c b/mm/fremap.c
index 46f5dac..dd0853c 100644
--- a/mm/fremap.c
+++ b/mm/fremap.c
@@ -211,7 +211,7 @@ SYSCALL_DEFINE5(remap_file_pages, unsigned long, start, unsigned long, size,
 		spin_lock(&mapping->i_mmap_lock);
 		flush_dcache_mmap_lock(mapping);
 		vma->vm_flags |= VM_NONLINEAR;
-		vma_prio_tree_remove(vma, &mapping->i_mmap);
+		vma_prio_tree_remove(&vma->shared, &mapping->i_mmap);
 		vma_nonlinear_insert(vma, &mapping->i_mmap_nonlinear);
 		flush_dcache_mmap_unlock(mapping);
 		spin_unlock(&mapping->i_mmap_lock);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 3a5aeb3..bbe3c0e 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2245,7 +2245,8 @@ static int unmap_ref_private(struct mm_struct *mm, struct vm_area_struct *vma,
 	 * __unmap_hugepage_range() is called as the lock is already held
 	 */
 	spin_lock(&mapping->i_mmap_lock);
-	vma_prio_tree_foreach(iter_vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
+	vma_prio_tree_foreach(iter_vma, struct vm_area_struct, shared, &iter,
+					&mapping->i_mmap, pgoff, pgoff) {
 		/* Do not unmap the current VMA */
 		if (iter_vma == vma)
 			continue;
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index d1f3351..f4188d9 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -428,8 +428,8 @@ static void collect_procs_file(struct page *page, struct list_head *to_kill,
 		if (!task_early_kill(tsk))
 			continue;
 
-		vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff,
-				      pgoff) {
+		vma_prio_tree_foreach(vma, struct vm_area_struct, shared,
+				      &iter, &mapping->i_mmap, pgoff, pgoff) {
 			/*
 			 * Send early kill signal to tasks where a vma covers
 			 * the page but the corrupted page is not necessarily
diff --git a/mm/memory.c b/mm/memory.c
index d1153e3..be3db11 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2415,7 +2415,8 @@ static void reset_vma_truncate_counts(struct address_space *mapping)
 	struct vm_area_struct *vma;
 	struct prio_tree_iter iter;
 
-	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, 0, ULONG_MAX)
+	vma_prio_tree_foreach(vma, struct vm_area_struct, shared,
+				&iter, &mapping->i_mmap, 0, ULONG_MAX)
 		vma->vm_truncate_count = 0;
 	list_for_each_entry(vma, &mapping->i_mmap_nonlinear, shared.vm_set.list)
 		vma->vm_truncate_count = 0;
@@ -2476,7 +2477,7 @@ static inline void unmap_mapping_range_tree(struct prio_tree_root *root,
 	pgoff_t vba, vea, zba, zea;
 
 restart:
-	vma_prio_tree_foreach(vma, &iter, root,
+	vma_prio_tree_foreach(vma, struct vm_area_struct, shared, &iter, root,
 			details->first_index, details->last_index) {
 		/* Skip quickly over those we have already dealt with */
 		if (vma->vm_truncate_count == details->truncate_count)
diff --git a/mm/mmap.c b/mm/mmap.c
index f1b4448..eb5ffd4 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -202,7 +202,7 @@ static void __remove_shared_vm_struct(struct vm_area_struct *vma,
 	if (unlikely(vma->vm_flags & VM_NONLINEAR))
 		list_del_init(&vma->shared.vm_set.list);
 	else
-		vma_prio_tree_remove(vma, &mapping->i_mmap);
+		vma_prio_tree_remove(&vma->shared, &mapping->i_mmap);
 	flush_dcache_mmap_unlock(mapping);
 }
 
@@ -425,7 +425,7 @@ static void __vma_link_file(struct vm_area_struct *vma)
 		if (unlikely(vma->vm_flags & VM_NONLINEAR))
 			vma_nonlinear_insert(vma, &mapping->i_mmap_nonlinear);
 		else
-			vma_prio_tree_insert(vma, &mapping->i_mmap);
+			vma_prio_tree_insert(&vma->shared, &mapping->i_mmap);
 		flush_dcache_mmap_unlock(mapping);
 	}
 }
@@ -588,9 +588,9 @@ again:			remove_next = 1 + (end > next->vm_end);
 
 	if (root) {
 		flush_dcache_mmap_lock(mapping);
-		vma_prio_tree_remove(vma, root);
+		vma_prio_tree_remove(&vma->shared, root);
 		if (adjust_next)
-			vma_prio_tree_remove(next, root);
+			vma_prio_tree_remove(&next->shared, root);
 	}
 
 	vma->vm_start = start;
@@ -603,8 +603,8 @@ again:			remove_next = 1 + (end > next->vm_end);
 
 	if (root) {
 		if (adjust_next)
-			vma_prio_tree_insert(next, root);
-		vma_prio_tree_insert(vma, root);
+			vma_prio_tree_insert(&next->shared, root);
+		vma_prio_tree_insert(&vma->shared, root);
 		flush_dcache_mmap_unlock(mapping);
 	}
 
diff --git a/mm/nommu.c b/mm/nommu.c
index b9b5cce..c712c4b 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -627,7 +627,7 @@ static void add_vma_to_mm(struct mm_struct *mm, struct vm_area_struct *vma)
 		mapping = vma->vm_file->f_mapping;
 
 		flush_dcache_mmap_lock(mapping);
-		vma_prio_tree_insert(vma, &mapping->i_mmap);
+		vma_prio_tree_insert(&vma->shared, &mapping->i_mmap);
 		flush_dcache_mmap_unlock(mapping);
 	}
 
@@ -695,7 +695,7 @@ static void delete_vma_from_mm(struct vm_area_struct *vma)
 		mapping = vma->vm_file->f_mapping;
 
 		flush_dcache_mmap_lock(mapping);
-		vma_prio_tree_remove(vma, &mapping->i_mmap);
+		vma_prio_tree_remove(&vma->shared, &mapping->i_mmap);
 		flush_dcache_mmap_unlock(mapping);
 	}
 
@@ -1941,8 +1941,8 @@ int nommu_shrink_inode_mappings(struct inode *inode, size_t size,
 	down_write(&nommu_region_sem);
 
 	/* search for VMAs that fall within the dead zone */
-	vma_prio_tree_foreach(vma, &iter, &inode->i_mapping->i_mmap,
-			      low, high) {
+	vma_prio_tree_foreach(vma, struct vm_area_struct, shared, &iter,
+				&inode->i_mapping->i_mmap, low, high) {
 		/* found one - only interested if it's shared out of the page
 		 * cache */
 		if (vma->vm_flags & VM_SHARED) {
@@ -1957,8 +1957,8 @@ int nommu_shrink_inode_mappings(struct inode *inode, size_t size,
 	 * we don't check for any regions that start beyond the EOF as there
 	 * shouldn't be any
 	 */
-	vma_prio_tree_foreach(vma, &iter, &inode->i_mapping->i_mmap,
-			      0, ULONG_MAX) {
+	vma_prio_tree_foreach(vma, struct vm_area_struct, shared, &iter,
+				&inode->i_mapping->i_mmap, 0, ULONG_MAX) {
 		if (!(vma->vm_flags & VM_SHARED))
 			continue;
 
diff --git a/mm/prio_tree.c b/mm/prio_tree.c
index 603ae98..57ba652 100644
--- a/mm/prio_tree.c
+++ b/mm/prio_tree.c
@@ -53,18 +53,18 @@
  * vm_flags' of R and H are covered by the different mmap_sems. When R is
  * removed under R->mmap_sem, H replaces R as a tree node. Since we do not hold
  * H->mmap_sem, we cannot use H->vm_flags for marking that H is a tree node now.
- * That's why some trick involving shared.vm_set.parent is used for identifying
+ * That's why some trick involving vm_set.parent is used for identifying
  * tree nodes and list head nodes.
  *
  * vma radix priority search tree node rules:
  *
- * vma->shared.vm_set.parent != NULL    ==> a tree node
- *      vma->shared.vm_set.head != NULL ==> list of others mapping same range
- *      vma->shared.vm_set.head == NULL ==> no others map the same range
+ * node.vm_set.parent != NULL     ==> a tree node
+ *      node->vm_set.head != NULL ==> list of others mapping same range
+ *      node->vm_set.head == NULL ==> no others map the same range
  *
- * vma->shared.vm_set.parent == NULL
- * 	vma->shared.vm_set.head != NULL ==> list head of vmas mapping same range
- * 	vma->shared.vm_set.head == NULL ==> a list node
+ * node->vm_set.parent == NULL
+ *	node->vm_set.head != NULL ==> list head of vmas mapping same range
+ *	node->vm_set.head == NULL ==> a list node
  */
 
 /*
@@ -72,86 +72,80 @@
  * useful for fork's dup_mmap as well as vma_prio_tree_insert below.
  * Note that it just happens to work correctly on i_mmap_nonlinear too.
  */
-void vma_prio_tree_add(struct vm_area_struct *vma, struct vm_area_struct *old)
+void vma_prio_tree_add(union vma_prio_tree_node *node,
+		       union vma_prio_tree_node *old)
 {
-	/* Leave these BUG_ONs till prio_tree patch stabilizes */
-	BUG_ON(RADIX_INDEX(vma) != RADIX_INDEX(old));
-	BUG_ON(HEAP_INDEX(vma) != HEAP_INDEX(old));
-
-	vma->shared.vm_set.head = NULL;
-	vma->shared.vm_set.parent = NULL;
-
-	if (!old->shared.vm_set.parent)
-		list_add(&vma->shared.vm_set.list,
-				&old->shared.vm_set.list);
-	else if (old->shared.vm_set.head)
-		list_add_tail(&vma->shared.vm_set.list,
-				&old->shared.vm_set.head->shared.vm_set.list);
+	node->vm_set.head = NULL;
+	node->vm_set.parent = NULL;
+
+	if (!old->vm_set.parent)
+		list_add(&node->vm_set.list, &old->vm_set.list);
+	else if (old->vm_set.head)
+		list_add_tail(&node->vm_set.list,
+				&old->vm_set.head->vm_set.list);
 	else {
-		INIT_LIST_HEAD(&vma->shared.vm_set.list);
-		vma->shared.vm_set.head = old;
-		old->shared.vm_set.head = vma;
+		INIT_LIST_HEAD(&node->vm_set.list);
+		node->vm_set.head = old;
+		old->vm_set.head = node;
 	}
 }
 
-void vma_prio_tree_insert(struct vm_area_struct *vma,
+void vma_prio_tree_insert(union vma_prio_tree_node *node,
 			  struct prio_tree_root *root)
 {
 	struct prio_tree_node *ptr;
-	struct vm_area_struct *old;
+	union vma_prio_tree_node *old;
 
-	vma->shared.vm_set.head = NULL;
+	node->vm_set.head = NULL;
 
-	ptr = raw_prio_tree_insert(root, &vma->shared.prio_tree_node);
-	if (ptr != (struct prio_tree_node *) &vma->shared.prio_tree_node) {
-		old = prio_tree_entry(ptr, struct vm_area_struct,
-					shared.prio_tree_node);
-		vma_prio_tree_add(vma, old);
+	ptr = raw_prio_tree_insert(root, &node->prio_tree_node);
+	if (ptr != (struct prio_tree_node *) &node->prio_tree_node) {
+		old = prio_tree_entry(ptr, union vma_prio_tree_node,
+				prio_tree_node);
+		vma_prio_tree_add(node, old);
 	}
 }
 
-void vma_prio_tree_remove(struct vm_area_struct *vma,
+void vma_prio_tree_remove(union vma_prio_tree_node *target,
 			  struct prio_tree_root *root)
 {
-	struct vm_area_struct *node, *head, *new_head;
+	union vma_prio_tree_node *node, *head, *new_head;
 
-	if (!vma->shared.vm_set.head) {
-		if (!vma->shared.vm_set.parent)
-			list_del_init(&vma->shared.vm_set.list);
+	if (!target->vm_set.head) {
+		if (!target->vm_set.parent)
+			list_del_init(&target->vm_set.list);
 		else
-			raw_prio_tree_remove(root, &vma->shared.prio_tree_node);
+			raw_prio_tree_remove(root, &target->prio_tree_node);
 	} else {
 		/* Leave this BUG_ON till prio_tree patch stabilizes */
-		BUG_ON(vma->shared.vm_set.head->shared.vm_set.head != vma);
-		if (vma->shared.vm_set.parent) {
-			head = vma->shared.vm_set.head;
-			if (!list_empty(&head->shared.vm_set.list)) {
+		BUG_ON(target->vm_set.head->vm_set.head != target);
+		if (target->vm_set.parent) {
+			head = target->vm_set.head;
+			if (!list_empty(&head->vm_set.list)) {
 				new_head = list_entry(
-					head->shared.vm_set.list.next,
-					struct vm_area_struct,
-					shared.vm_set.list);
-				list_del_init(&head->shared.vm_set.list);
+					head->vm_set.list.next,
+					union vma_prio_tree_node, vm_set.list);
+				list_del_init(&head->vm_set.list);
 			} else
 				new_head = NULL;
 
-			raw_prio_tree_replace(root, &vma->shared.prio_tree_node,
-					&head->shared.prio_tree_node);
-			head->shared.vm_set.head = new_head;
+			raw_prio_tree_replace(root, &target->prio_tree_node,
+					&head->prio_tree_node);
+			head->vm_set.head = new_head;
 			if (new_head)
-				new_head->shared.vm_set.head = head;
+				new_head->vm_set.head = head;
 
 		} else {
-			node = vma->shared.vm_set.head;
-			if (!list_empty(&vma->shared.vm_set.list)) {
+			node = target->vm_set.head;
+			if (!list_empty(&target->vm_set.list)) {
 				new_head = list_entry(
-					vma->shared.vm_set.list.next,
-					struct vm_area_struct,
-					shared.vm_set.list);
-				list_del_init(&vma->shared.vm_set.list);
-				node->shared.vm_set.head = new_head;
-				new_head->shared.vm_set.head = node;
+					target->vm_set.list.next,
+					union vma_prio_tree_node, vm_set.list);
+				list_del_init(&target->vm_set.list);
+				node->vm_set.head = new_head;
+				new_head->vm_set.head = node;
 			} else
-				node->shared.vm_set.head = NULL;
+				node->vm_set.head = NULL;
 		}
 	}
 }
@@ -161,46 +155,46 @@ void vma_prio_tree_remove(struct vm_area_struct *vma,
  * contiguous file pages. The function returns vmas that at least map a single
  * page in the given range of contiguous file pages.
  */
-struct vm_area_struct *vma_prio_tree_next(struct vm_area_struct *vma,
+union vma_prio_tree_node *vma_prio_tree_next(union vma_prio_tree_node *node,
 					struct prio_tree_iter *iter)
 {
 	struct prio_tree_node *ptr;
-	struct vm_area_struct *next;
+	union vma_prio_tree_node *next;
 
-	if (!vma) {
+	if (!node) {
 		/*
-		 * First call is with NULL vma
+		 * First call is with NULL node
 		 */
 		ptr = prio_tree_next(iter);
 		if (ptr) {
-			next = prio_tree_entry(ptr, struct vm_area_struct,
-						shared.prio_tree_node);
-			prefetch(next->shared.vm_set.head);
+			next = prio_tree_entry(ptr, union vma_prio_tree_node,
+						prio_tree_node);
+			prefetch(next->vm_set.head);
 			return next;
 		} else
 			return NULL;
 	}
 
-	if (vma->shared.vm_set.parent) {
-		if (vma->shared.vm_set.head) {
-			next = vma->shared.vm_set.head;
-			prefetch(next->shared.vm_set.list.next);
+	if (node->vm_set.parent) {
+		if (node->vm_set.head) {
+			next = node->vm_set.head;
+			prefetch(next->vm_set.list.next);
 			return next;
 		}
 	} else {
-		next = list_entry(vma->shared.vm_set.list.next,
-				struct vm_area_struct, shared.vm_set.list);
-		if (!next->shared.vm_set.head) {
-			prefetch(next->shared.vm_set.list.next);
+		next = list_entry(node->vm_set.list.next,
+				union vma_prio_tree_node, vm_set.list);
+		if (!next->vm_set.head) {
+			prefetch(next->vm_set.list.next);
 			return next;
 		}
 	}
 
 	ptr = prio_tree_next(iter);
 	if (ptr) {
-		next = prio_tree_entry(ptr, struct vm_area_struct,
-					shared.prio_tree_node);
-		prefetch(next->shared.vm_set.head);
+		next = prio_tree_entry(ptr, union vma_prio_tree_node,
+					prio_tree_node);
+		prefetch(next->vm_set.head);
 		return next;
 	} else
 		return NULL;
diff --git a/mm/rmap.c b/mm/rmap.c
index fcd593c..deaf691 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -562,7 +562,8 @@ static int page_referenced_file(struct page *page,
 	 */
 	mapcount = page_mapcount(page);
 
-	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
+	vma_prio_tree_foreach(vma, struct vm_area_struct, shared, &iter,
+					&mapping->i_mmap, pgoff, pgoff) {
 		unsigned long address = vma_address(page, vma);
 		if (address == -EFAULT)
 			continue;
@@ -667,7 +668,8 @@ static int page_mkclean_file(struct address_space *mapping, struct page *page)
 	BUG_ON(PageAnon(page));
 
 	spin_lock(&mapping->i_mmap_lock);
-	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
+	vma_prio_tree_foreach(vma, struct vm_area_struct, shared, &iter,
+					&mapping->i_mmap, pgoff, pgoff) {
 		if (vma->vm_flags & VM_SHARED) {
 			unsigned long address = vma_address(page, vma);
 			if (address == -EFAULT)
@@ -1182,7 +1184,8 @@ static int try_to_unmap_file(struct page *page, enum ttu_flags flags)
 	unsigned int mapcount;
 
 	spin_lock(&mapping->i_mmap_lock);
-	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
+	vma_prio_tree_foreach(vma, struct vm_area_struct, shared, &iter,
+					&mapping->i_mmap, pgoff, pgoff) {
 		unsigned long address = vma_address(page, vma);
 		if (address == -EFAULT)
 			continue;
@@ -1372,7 +1375,8 @@ static int rmap_walk_file(struct page *page, int (*rmap_one)(struct page *,
 	if (!mapping)
 		return ret;
 	spin_lock(&mapping->i_mmap_lock);
-	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
+	vma_prio_tree_foreach(vma, struct vm_area_struct, shared, &iter,
+					&mapping->i_mmap, pgoff, pgoff) {
 		unsigned long address = vma_address(page, vma);
 		if (address == -EFAULT)
 			continue;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
