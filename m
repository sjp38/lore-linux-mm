Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 688166B0047
	for <linux-mm@kvack.org>; Fri,  5 Mar 2010 04:38:42 -0500 (EST)
Date: Fri, 5 Mar 2010 10:38:35 +0100
From: Christian Ehrhardt <lk@c--e.de>
Subject: [PATCH] rmap: Fix Bugzilla Bug #5493
Message-ID: <20100305093834.GG17078@lisa.in-ulm.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Hi,

this patch fixes bugzilla Bug

        http://bugzilla.kernel.org/show_bug.cgi?id=5493

This bug describes a search complexity failure in rmap if a single
anon_vma has a huge number of vmas associated with it.

The patch makes the vma prio tree code somewhat more reusable and then uses
that to replace the linked list of vmas in an anon_vma with a prio_tree.

Timings for the test program in the original kernel code and
responsiveness of the system during the test improve dramatically.

NOTE: This needs an Ack from someone who can compile on arm and parisc.

        regards   Christian


Manage vmas of an anon_vma in a prio tree to reduce search times.
Fixes Bug #5493.

Signed-off-by: Christian Ehrhardt <lk@c--e.de>

 arch/arm/mm/fault-armv.c   |    3 +-
 arch/arm/mm/flush.c        |    3 +-
 arch/parisc/kernel/cache.c |    3 +-
 arch/x86/mm/hugetlbpage.c  |    3 +-
 fs/hugetlbfs/inode.c       |    3 +-
 fs/inode.c                 |    2 +-
 include/linux/mm.h         |   28 +++++++--
 include/linux/mm_types.h   |   12 +---
 include/linux/prio_tree.h  |   17 +++++-
 include/linux/rmap.h       |    9 ++-
 kernel/fork.c              |    2 +-
 lib/prio_tree.c            |   11 +++-
 mm/filemap_xip.c           |    3 +-
 mm/fremap.c                |    2 +-
 mm/hugetlb.c               |    3 +-
 mm/ksm.c                   |   17 ++++-
 mm/memory-failure.c        |   10 ++-
 mm/memory.c                |    5 +-
 mm/mmap.c                  |   26 ++++----
 mm/nommu.c                 |   14 ++--
 mm/prio_tree.c             |  138 +++++++++++++++++++++-----------------------
 mm/rmap.c                  |   41 +++++++++-----
 22 files changed, 204 insertions(+), 151 deletions(-)

diff --git a/arch/arm/mm/fault-armv.c b/arch/arm/mm/fault-armv.c
index 56ee153..95ad18d 100644
--- a/arch/arm/mm/fault-armv.c
+++ b/arch/arm/mm/fault-armv.c
@@ -111,7 +111,8 @@ make_coherent(struct address_space *mapping, struct vm_area_struct *vma, unsigne
 	 * cache coherency.
 	 */
 	flush_dcache_mmap_lock(mapping);
-	vma_prio_tree_foreach(mpnt, &iter, &mapping->i_mmap, pgoff, pgoff) {
+	vma_prio_tree_foreach(mpnt, shared, &iter,
+				&mapping->i_mmap, pgoff, pgoff) {
 		/*
 		 * If this VMA is not in our MM, we can ignore it.
 		 * Note that we intentionally mask out the VMA
diff --git a/arch/arm/mm/flush.c b/arch/arm/mm/flush.c
index 6f3a4b7..af155af 100644
--- a/arch/arm/mm/flush.c
+++ b/arch/arm/mm/flush.c
@@ -159,7 +159,8 @@ static void __flush_dcache_aliases(struct address_space *mapping, struct page *p
 	pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
 
 	flush_dcache_mmap_lock(mapping);
-	vma_prio_tree_foreach(mpnt, &iter, &mapping->i_mmap, pgoff, pgoff) {
+	vma_prio_tree_foreach(mpnt, shared, &iter,
+					&mapping->i_mmap, pgoff, pgoff) {
 		unsigned long offset;
 
 		/*
diff --git a/arch/parisc/kernel/cache.c b/arch/parisc/kernel/cache.c
index b6ed34d..c619f64 100644
--- a/arch/parisc/kernel/cache.c
+++ b/arch/parisc/kernel/cache.c
@@ -365,7 +365,8 @@ void flush_dcache_page(struct page *page)
 	 * to flush one address here for them all to become coherent */
 
 	flush_dcache_mmap_lock(mapping);
-	vma_prio_tree_foreach(mpnt, &iter, &mapping->i_mmap, pgoff, pgoff) {
+	vma_prio_tree_foreach(mpnt, shared, &iter,
+					&mapping->i_mmap, pgoff, pgoff) {
 		offset = (pgoff - mpnt->vm_pgoff) << PAGE_SHIFT;
 		addr = mpnt->vm_start + offset;
 
diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
index f46c340..784df0d 100644
--- a/arch/x86/mm/hugetlbpage.c
+++ b/arch/x86/mm/hugetlbpage.c
@@ -74,7 +74,8 @@ static void huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
 		return;
 
 	spin_lock(&mapping->i_mmap_lock);
-	vma_prio_tree_foreach(svma, &iter, &mapping->i_mmap, idx, idx) {
+	vma_prio_tree_foreach(svma, shared, &iter,
+					&mapping->i_mmap, idx, idx) {
 		if (svma == vma)
 			continue;
 
diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index a0bbd3d..c6c6991 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -400,7 +400,8 @@ hugetlb_vmtruncate_list(struct prio_tree_root *root, pgoff_t pgoff)
 	struct vm_area_struct *vma;
 	struct prio_tree_iter iter;
 
-	vma_prio_tree_foreach(vma, &iter, root, pgoff, ULONG_MAX) {
+	vma_prio_tree_foreach(vma, shared, &iter, root,
+						pgoff, ULONG_MAX) {
 		unsigned long v_offset;
 
 		/*
diff --git a/fs/inode.c b/fs/inode.c
index 03dfeb2..b594ae5 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -262,7 +262,7 @@ void inode_init_once(struct inode *inode)
 	spin_lock_init(&inode->i_data.i_mmap_lock);
 	INIT_LIST_HEAD(&inode->i_data.private_list);
 	spin_lock_init(&inode->i_data.private_lock);
-	INIT_RAW_PRIO_TREE_ROOT(&inode->i_data.i_mmap);
+	INIT_SHARED_PRIO_TREE_ROOT(&inode->i_data.i_mmap);
 	INIT_LIST_HEAD(&inode->i_data.i_mmap_nonlinear);
 	i_size_ordered_init(inode);
 #ifdef CONFIG_INOTIFY
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 60c467b..0ecf44f 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1092,15 +1092,29 @@ extern atomic_long_t mmap_pages_allocated;
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
+#define vma_prio_tree_first_entry(iter, field)		({		\
+	union vma_prio_tree_node *__t;					\
+	__t = vma_prio_tree_next(NULL, iter);				\
+	__t ? prio_tree_entry(__t, struct vm_area_struct, field) : NULL;\
+})
+
+#define vma_prio_tree_next_entry(vma, iter, field)	({		\
+	union vma_prio_tree_node *__t;					\
+	__t = vma_prio_tree_next(&(vma)->field, iter);			\
+	__t ? prio_tree_entry(__t, struct vm_area_struct, field) : NULL;\
+})
+
+#define vma_prio_tree_foreach(vma, field, iter, root, begin, end)	\
+	prio_tree_iter_init(iter, root, begin, end);			\
+	for (vma = vma_prio_tree_first_entry(iter, field); vma ;	\
+		(vma = vma_prio_tree_next_entry(vma, iter, field)))
 
 static inline void vma_nonlinear_insert(struct vm_area_struct *vma,
 					struct list_head *list)
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 36f9627..6b77c3c 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -153,15 +153,7 @@ struct vm_area_struct {
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
@@ -169,7 +161,7 @@ struct vm_area_struct {
 	 * can only be in the i_mmap tree.  An anonymous MAP_PRIVATE, stack
 	 * or brk vma (with NULL file) can only be in an anon_vma list.
 	 */
-	struct list_head anon_vma_node;	/* Serialized by anon_vma->lock */
+	union vma_prio_tree_node anon;
 	struct anon_vma *anon_vma;	/* Serialized by page_table_lock */
 
 	/* Function pointers to deal with this struct. */
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
diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index b019ae6..47417e2 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -8,6 +8,7 @@
 #include <linux/slab.h>
 #include <linux/mm.h>
 #include <linux/spinlock.h>
+#include <linux/prio_tree.h>
 #include <linux/memcontrol.h>
 
 /*
@@ -30,14 +31,14 @@ struct anon_vma {
 	atomic_t ksm_refcount;
 #endif
 	/*
-	 * NOTE: the LSB of the head.next is set by
+	 * NOTE: the LSB of the head.prio_tree_node is set by
 	 * mm_take_all_locks() _after_ taking the above lock. So the
 	 * head must only be read/written after taking the above lock
-	 * to be sure to see a valid next pointer. The LSB bit itself
-	 * is serialized by a system wide lock only visible to
+	 * to be sure to see a valid prio_tree_node pointer. The LSB bit
+	 * itself is serialized by a system wide lock only visible to
 	 * mm_take_all_locks() (mm_all_locks_mutex).
 	 */
-	struct list_head head;	/* List of private "related" vmas */
+	struct prio_tree_root head;
 };
 
 #ifdef CONFIG_MMU
diff --git a/kernel/fork.c b/kernel/fork.c
index f88bd98..abe1091 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -351,7 +351,7 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 			tmp->vm_truncate_count = mpnt->vm_truncate_count;
 			flush_dcache_mmap_lock(mapping);
 			/* insert tmp into the share list, just after mpnt */
-			vma_prio_tree_add(tmp, mpnt);
+			vma_prio_tree_add(&tmp->shared, &mpnt->shared);
 			flush_dcache_mmap_unlock(mapping);
 			spin_unlock(&mapping->i_mmap_lock);
 		}
diff --git a/lib/prio_tree.c b/lib/prio_tree.c
index ccfd850..8bdf119 100644
--- a/lib/prio_tree.c
+++ b/lib/prio_tree.c
@@ -53,14 +53,19 @@ static void get_index(const struct prio_tree_root *root,
     const struct prio_tree_node *node,
     unsigned long *radix, unsigned long *heap)
 {
-	if (root->raw) {
+	if (root->raw == 1) {
 		struct vm_area_struct *vma = prio_tree_entry(
 		    node, struct vm_area_struct, shared.prio_tree_node);
 
 		*radix = RADIX_INDEX(vma);
 		*heap = HEAP_INDEX(vma);
-	}
-	else {
+	} else if (root->raw == 2) {
+		struct vm_area_struct *vma = prio_tree_entry(
+		    node, struct vm_area_struct, anon.prio_tree_node);
+
+		*radix = RADIX_INDEX(vma);
+		*heap = HEAP_INDEX(vma);
+	} else {
 		*radix = node->start;
 		*heap = node->last;
 	}
diff --git a/mm/filemap_xip.c b/mm/filemap_xip.c
index 1888b2d..1f559cc 100644
--- a/mm/filemap_xip.c
+++ b/mm/filemap_xip.c
@@ -183,7 +183,8 @@ __xip_unmap (struct address_space * mapping,
 
 retry:
 	spin_lock(&mapping->i_mmap_lock);
-	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
+	vma_prio_tree_foreach(vma, shared, &iter, &mapping->i_mmap,
+							pgoff, pgoff) {
 		mm = vma->vm_mm;
 		address = vma->vm_start +
 			((pgoff - vma->vm_pgoff) << PAGE_SHIFT);
diff --git a/mm/fremap.c b/mm/fremap.c
index b6ec85a..16a05d8 100644
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
index 2d16fa6..de40bec 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2245,7 +2245,8 @@ static int unmap_ref_private(struct mm_struct *mm, struct vm_area_struct *vma,
 	 * __unmap_hugepage_range() is called as the lock is already held
 	 */
 	spin_lock(&mapping->i_mmap_lock);
-	vma_prio_tree_foreach(iter_vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
+	vma_prio_tree_foreach(iter_vma, shared, &iter,
+					&mapping->i_mmap, pgoff, pgoff) {
 		/* Do not unmap the current VMA */
 		if (iter_vma == vma)
 			continue;
diff --git a/mm/ksm.c b/mm/ksm.c
index 56a0da1..eeed374 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -326,7 +326,7 @@ static void drop_anon_vma(struct rmap_item *rmap_item)
 	struct anon_vma *anon_vma = rmap_item->anon_vma;
 
 	if (atomic_dec_and_lock(&anon_vma->ksm_refcount, &anon_vma->lock)) {
-		int empty = list_empty(&anon_vma->head);
+		int empty = prio_tree_empty(&anon_vma->head);
 		spin_unlock(&anon_vma->lock);
 		if (empty)
 			anon_vma_free(anon_vma);
@@ -1562,11 +1562,14 @@ int page_referenced_ksm(struct page *page, struct mem_cgroup *memcg,
 		return 0;
 again:
 	hlist_for_each_entry(rmap_item, hlist, &stable_node->hlist, hlist) {
+		pgoff_t pgoff = rmap_item->address >> PAGE_SHIFT;
 		struct anon_vma *anon_vma = rmap_item->anon_vma;
 		struct vm_area_struct *vma;
+		struct prio_tree_iter iter;
 
 		spin_lock(&anon_vma->lock);
-		list_for_each_entry(vma, &anon_vma->head, anon_vma_node) {
+		vma_prio_tree_foreach(vma, anon, &iter,
+					&anon_vma->head, pgoff, pgoff) {
 			if (rmap_item->address < vma->vm_start ||
 			    rmap_item->address >= vma->vm_end)
 				continue;
@@ -1613,11 +1616,14 @@ int try_to_unmap_ksm(struct page *page, enum ttu_flags flags)
 		return SWAP_FAIL;
 again:
 	hlist_for_each_entry(rmap_item, hlist, &stable_node->hlist, hlist) {
+		pgoff_t pgoff = rmap_item->address >> PAGE_SHIFT;
 		struct anon_vma *anon_vma = rmap_item->anon_vma;
 		struct vm_area_struct *vma;
+		struct prio_tree_iter iter;
 
 		spin_lock(&anon_vma->lock);
-		list_for_each_entry(vma, &anon_vma->head, anon_vma_node) {
+		vma_prio_tree_foreach(vma, anon, &iter,
+					&anon_vma->head, pgoff, pgoff) {
 			if (rmap_item->address < vma->vm_start ||
 			    rmap_item->address >= vma->vm_end)
 				continue;
@@ -1663,11 +1669,14 @@ int rmap_walk_ksm(struct page *page, int (*rmap_one)(struct page *,
 		return ret;
 again:
 	hlist_for_each_entry(rmap_item, hlist, &stable_node->hlist, hlist) {
+		pgoff_t pgoff = rmap_item->address >> PAGE_SHIFT;
 		struct anon_vma *anon_vma = rmap_item->anon_vma;
 		struct vm_area_struct *vma;
+		struct prio_tree_iter iter;
 
 		spin_lock(&anon_vma->lock);
-		list_for_each_entry(vma, &anon_vma->head, anon_vma_node) {
+		vma_prio_tree_foreach(vma, anon, &iter,
+					&anon_vma->head, pgoff, pgoff) {
 			if (rmap_item->address < vma->vm_start ||
 			    rmap_item->address >= vma->vm_end)
 				continue;
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 17299fd..857603a 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -383,9 +383,13 @@ static void collect_procs_anon(struct page *page, struct list_head *to_kill,
 	if (av == NULL)	/* Not actually mapped anymore */
 		goto out;
 	for_each_process (tsk) {
+		struct prio_tree_iter iter;
+		pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+
 		if (!task_early_kill(tsk))
 			continue;
-		list_for_each_entry (vma, &av->head, anon_vma_node) {
+		vma_prio_tree_foreach(vma, anon, &iter,
+						&av->head, pgoff, pgoff) {
 			if (!page_mapped_in_vma(page, vma))
 				continue;
 			if (vma->vm_mm == tsk->mm)
@@ -425,8 +429,8 @@ static void collect_procs_file(struct page *page, struct list_head *to_kill,
 		if (!task_early_kill(tsk))
 			continue;
 
-		vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff,
-				      pgoff) {
+		vma_prio_tree_foreach(vma, shared, &iter,
+					&mapping->i_mmap, pgoff, pgoff) {
 			/*
 			 * Send early kill signal to tasks where a vma covers
 			 * the page but the corrupted page is not necessarily
diff --git a/mm/memory.c b/mm/memory.c
index 09e4b1b..f2ae3f4 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2314,7 +2314,8 @@ static void reset_vma_truncate_counts(struct address_space *mapping)
 	struct vm_area_struct *vma;
 	struct prio_tree_iter iter;
 
-	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, 0, ULONG_MAX)
+	vma_prio_tree_foreach(vma, shared, &iter, &mapping->i_mmap,
+								0, ULONG_MAX)
 		vma->vm_truncate_count = 0;
 	list_for_each_entry(vma, &mapping->i_mmap_nonlinear, shared.vm_set.list)
 		vma->vm_truncate_count = 0;
@@ -2375,7 +2376,7 @@ static inline void unmap_mapping_range_tree(struct prio_tree_root *root,
 	pgoff_t vba, vea, zba, zea;
 
 restart:
-	vma_prio_tree_foreach(vma, &iter, root,
+	vma_prio_tree_foreach(vma, shared, &iter, root,
 			details->first_index, details->last_index) {
 		/* Skip quickly over those we have already dealt with */
 		if (vma->vm_truncate_count == details->truncate_count)
diff --git a/mm/mmap.c b/mm/mmap.c
index ee22989..cc799b4 100644
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
 
@@ -856,7 +856,7 @@ try_prev:
 	 * It is potentially slow to have to call find_vma_prev here.
 	 * But it's only on the first write fault on the vma, not
 	 * every time, and we could devise a way to avoid it later
-	 * (e.g. stash info in next's anon_vma_node when assigning
+	 * (e.g. stash info in next's anon node when assigning
 	 * an anon_vma, or when trying vma_merge).  Another time.
 	 */
 	BUG_ON(find_vma_prev(vma->vm_mm, vma->vm_start, &near) != vma);
@@ -2380,7 +2380,7 @@ static DEFINE_MUTEX(mm_all_locks_mutex);
 
 static void vm_lock_anon_vma(struct mm_struct *mm, struct anon_vma *anon_vma)
 {
-	if (!test_bit(0, (unsigned long *) &anon_vma->head.next)) {
+	if (!test_bit(0, (unsigned long *) &anon_vma->head.prio_tree_node)) {
 		/*
 		 * The LSB of head.next can't change from under us
 		 * because we hold the mm_all_locks_mutex.
@@ -2396,7 +2396,7 @@ static void vm_lock_anon_vma(struct mm_struct *mm, struct anon_vma *anon_vma)
 		 * anon_vma->lock.
 		 */
 		if (__test_and_set_bit(0, (unsigned long *)
-				       &anon_vma->head.next))
+				       &anon_vma->head.prio_tree_node))
 			BUG();
 	}
 }
@@ -2437,8 +2437,8 @@ static void vm_lock_mapping(struct mm_struct *mm, struct address_space *mapping)
  * A single task can't take more than one mm_take_all_locks() in a row
  * or it would deadlock.
  *
- * The LSB in anon_vma->head.next and the AS_MM_ALL_LOCKS bitflag in
- * mapping->flags avoid to take the same lock twice, if more than one
+ * The LSB in anon_vma->head.prio_tree_node and the AS_MM_ALL_LOCKS bitflag
+ * in mapping->flags avoid to take the same lock twice, if more than one
  * vma in this mm is backed by the same anon_vma or address_space.
  *
  * We can take all the locks in random order because the VM code
@@ -2485,7 +2485,7 @@ out_unlock:
 
 static void vm_unlock_anon_vma(struct anon_vma *anon_vma)
 {
-	if (test_bit(0, (unsigned long *) &anon_vma->head.next)) {
+	if (test_bit(0, (unsigned long *) &anon_vma->head.prio_tree_node)) {
 		/*
 		 * The LSB of head.next can't change to 0 from under
 		 * us because we hold the mm_all_locks_mutex.
@@ -2499,7 +2499,7 @@ static void vm_unlock_anon_vma(struct anon_vma *anon_vma)
 		 * anon_vma->lock.
 		 */
 		if (!__test_and_clear_bit(0, (unsigned long *)
-					  &anon_vma->head.next))
+					  &anon_vma->head.prio_tree_node))
 			BUG();
 		spin_unlock(&anon_vma->lock);
 	}
diff --git a/mm/nommu.c b/mm/nommu.c
index 48a2ecf..a88c654 100644
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
 
@@ -1209,7 +1209,7 @@ unsigned long do_mmap_pgoff(struct file *file,
 	region->vm_flags = vm_flags;
 	region->vm_pgoff = pgoff;
 
-	INIT_LIST_HEAD(&vma->anon_vma_node);
+	INIT_PRIO_TREE_NODE(&vma->anon);
 	vma->vm_flags = vm_flags;
 	vma->vm_pgoff = pgoff;
 
@@ -1941,8 +1941,8 @@ int nommu_shrink_inode_mappings(struct inode *inode, size_t size,
 	down_write(&nommu_region_sem);
 
 	/* search for VMAs that fall within the dead zone */
-	vma_prio_tree_foreach(vma, &iter, &inode->i_mapping->i_mmap,
-			      low, high) {
+	vma_prio_tree_foreach(vma, shared, &iter,
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
+	vma_prio_tree_foreach(vma, shared, &iter,
+				&inode->i_mapping->i_mmap, 0, ULONG_MAX) {
 		if (!(vma->vm_flags & VM_SHARED))
 			continue;
 
diff --git a/mm/prio_tree.c b/mm/prio_tree.c
index 603ae98..8e9194f 100644
--- a/mm/prio_tree.c
+++ b/mm/prio_tree.c
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
-				new_head = list_entry(
-					head->shared.vm_set.list.next,
-					struct vm_area_struct,
-					shared.vm_set.list);
-				list_del_init(&head->shared.vm_set.list);
+		BUG_ON(target->vm_set.head->vm_set.head != target);
+		if (target->vm_set.parent) {
+			head = target->vm_set.head;
+			if (!list_empty(&head->vm_set.list)) {
+				new_head = prio_tree_entry(
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
-				new_head = list_entry(
-					vma->shared.vm_set.list.next,
-					struct vm_area_struct,
-					shared.vm_set.list);
-				list_del_init(&vma->shared.vm_set.list);
-				node->shared.vm_set.head = new_head;
-				new_head->shared.vm_set.head = node;
+			node = target->vm_set.head;
+			if (!list_empty(&target->vm_set.list)) {
+				new_head = prio_tree_entry(
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
index 278cd27..1573757 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -123,7 +123,7 @@ int anon_vma_prepare(struct vm_area_struct *vma)
 		spin_lock(&mm->page_table_lock);
 		if (likely(!vma->anon_vma)) {
 			vma->anon_vma = anon_vma;
-			list_add_tail(&vma->anon_vma_node, &anon_vma->head);
+			vma_prio_tree_insert(&vma->anon, &anon_vma->head);
 			allocated = NULL;
 		}
 		spin_unlock(&mm->page_table_lock);
@@ -138,7 +138,7 @@ int anon_vma_prepare(struct vm_area_struct *vma)
 void __anon_vma_merge(struct vm_area_struct *vma, struct vm_area_struct *next)
 {
 	BUG_ON(vma->anon_vma != next->anon_vma);
-	list_del(&next->anon_vma_node);
+	vma_prio_tree_remove(&next->anon, &vma->anon_vma->head);
 }
 
 void __anon_vma_link(struct vm_area_struct *vma)
@@ -146,7 +146,7 @@ void __anon_vma_link(struct vm_area_struct *vma)
 	struct anon_vma *anon_vma = vma->anon_vma;
 
 	if (anon_vma)
-		list_add_tail(&vma->anon_vma_node, &anon_vma->head);
+		vma_prio_tree_insert(&vma->anon, &anon_vma->head);
 }
 
 void anon_vma_link(struct vm_area_struct *vma)
@@ -155,7 +155,7 @@ void anon_vma_link(struct vm_area_struct *vma)
 
 	if (anon_vma) {
 		spin_lock(&anon_vma->lock);
-		list_add_tail(&vma->anon_vma_node, &anon_vma->head);
+		vma_prio_tree_insert(&vma->anon, &anon_vma->head);
 		spin_unlock(&anon_vma->lock);
 	}
 }
@@ -169,10 +169,10 @@ void anon_vma_unlink(struct vm_area_struct *vma)
 		return;
 
 	spin_lock(&anon_vma->lock);
-	list_del(&vma->anon_vma_node);
+	vma_prio_tree_remove(&vma->anon, &anon_vma->head);
 
 	/* We must garbage collect the anon_vma if it's empty */
-	empty = list_empty(&anon_vma->head) && !ksm_refcount(anon_vma);
+	empty = prio_tree_empty(&anon_vma->head) && !ksm_refcount(anon_vma);
 	spin_unlock(&anon_vma->lock);
 
 	if (empty)
@@ -185,7 +185,7 @@ static void anon_vma_ctor(void *data)
 
 	spin_lock_init(&anon_vma->lock);
 	ksm_refcount_init(anon_vma);
-	INIT_LIST_HEAD(&anon_vma->head);
+	INIT_ANON_PRIO_TREE_ROOT(&anon_vma->head);
 }
 
 void __init anon_vma_init(void)
@@ -394,9 +394,11 @@ static int page_referenced_anon(struct page *page,
 				struct mem_cgroup *mem_cont,
 				unsigned long *vm_flags)
 {
+	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
 	unsigned int mapcount;
 	struct anon_vma *anon_vma;
 	struct vm_area_struct *vma;
+	struct prio_tree_iter iter;
 	int referenced = 0;
 
 	anon_vma = page_lock_anon_vma(page);
@@ -404,7 +406,8 @@ static int page_referenced_anon(struct page *page,
 		return referenced;
 
 	mapcount = page_mapcount(page);
-	list_for_each_entry(vma, &anon_vma->head, anon_vma_node) {
+	vma_prio_tree_foreach(vma, anon, &iter,
+					&anon_vma->head, pgoff, pgoff) {
 		unsigned long address = vma_address(page, vma);
 		if (address == -EFAULT)
 			continue;
@@ -472,7 +475,8 @@ static int page_referenced_file(struct page *page,
 	 */
 	mapcount = page_mapcount(page);
 
-	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
+	vma_prio_tree_foreach(vma, shared, &iter,
+					&mapping->i_mmap, pgoff, pgoff) {
 		unsigned long address = vma_address(page, vma);
 		if (address == -EFAULT)
 			continue;
@@ -580,7 +584,8 @@ static int page_mkclean_file(struct address_space *mapping, struct page *page)
 	BUG_ON(PageAnon(page));
 
 	spin_lock(&mapping->i_mmap_lock);
-	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
+	vma_prio_tree_foreach(vma, shared, &iter,
+					&mapping->i_mmap, pgoff, pgoff) {
 		if (vma->vm_flags & VM_SHARED) {
 			unsigned long address = vma_address(page, vma);
 			if (address == -EFAULT)
@@ -1023,15 +1028,18 @@ static int try_to_unmap_cluster(unsigned long cursor, unsigned int *mapcount,
  */
 static int try_to_unmap_anon(struct page *page, enum ttu_flags flags)
 {
+	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
 	struct anon_vma *anon_vma;
 	struct vm_area_struct *vma;
+	struct prio_tree_iter iter;
 	int ret = SWAP_AGAIN;
 
 	anon_vma = page_lock_anon_vma(page);
 	if (!anon_vma)
 		return ret;
 
-	list_for_each_entry(vma, &anon_vma->head, anon_vma_node) {
+	vma_prio_tree_foreach(vma, anon, &iter,
+					&anon_vma->head, pgoff, pgoff) {
 		unsigned long address = vma_address(page, vma);
 		if (address == -EFAULT)
 			continue;
@@ -1072,7 +1080,8 @@ static int try_to_unmap_file(struct page *page, enum ttu_flags flags)
 	unsigned int mapcount;
 
 	spin_lock(&mapping->i_mmap_lock);
-	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
+	vma_prio_tree_foreach(vma, shared, &iter,
+					&mapping->i_mmap, pgoff, pgoff) {
 		unsigned long address = vma_address(page, vma);
 		if (address == -EFAULT)
 			continue;
@@ -1221,9 +1230,11 @@ int try_to_munlock(struct page *page)
 static int rmap_walk_anon(struct page *page, int (*rmap_one)(struct page *,
 		struct vm_area_struct *, unsigned long, void *), void *arg)
 {
+	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
 	struct anon_vma *anon_vma;
 	struct vm_area_struct *vma;
 	int ret = SWAP_AGAIN;
+	struct prio_tree_iter iter;
 
 	/*
 	 * Note: remove_migration_ptes() cannot use page_lock_anon_vma()
@@ -1237,7 +1248,8 @@ static int rmap_walk_anon(struct page *page, int (*rmap_one)(struct page *,
 	if (!anon_vma)
 		return ret;
 	spin_lock(&anon_vma->lock);
-	list_for_each_entry(vma, &anon_vma->head, anon_vma_node) {
+	vma_prio_tree_foreach(vma, anon, &iter,
+					&anon_vma->head, pgoff, pgoff) {
 		unsigned long address = vma_address(page, vma);
 		if (address == -EFAULT)
 			continue;
@@ -1261,7 +1273,8 @@ static int rmap_walk_file(struct page *page, int (*rmap_one)(struct page *,
 	if (!mapping)
 		return ret;
 	spin_lock(&mapping->i_mmap_lock);
-	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
+	vma_prio_tree_foreach(vma, shared, &iter,
+					&mapping->i_mmap, pgoff, pgoff) {
 		unsigned long address = vma_address(page, vma);
 		if (address == -EFAULT)
 			continue;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
