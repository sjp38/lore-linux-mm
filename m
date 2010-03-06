Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id F00AA6B0047
	for <linux-mm@kvack.org>; Fri,  5 Mar 2010 20:02:17 -0500 (EST)
Date: Sat, 6 Mar 2010 02:02:12 +0100
From: Christian Ehrhardt <uni@c--e.de>
Subject: Re: [PATCH] rmap: Fix Bugzilla Bug #5493
Message-ID: <20100306010212.GH17078@lisa.in-ulm.de>
References: <20100305093834.GG17078@lisa.in-ulm.de> <4B9110ED.5000703@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4B9110ED.5000703@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Christian Ehrhardt <lk@c--e.de>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Hi Rik,

On Fri, Mar 05, 2010 at 09:10:53AM -0500, Rik van Riel wrote:
> Your patch will not apply against a current -mm, because it
> conflicts with my anon_vma linking patches (which attacks
> another "rmap walks too many vmas" failure mode).
> 
> Please rediff your patch against the latest -mm tree.

Conflict resolution turned out to be somewhat difficult. The following
is a patch agains the -mm tree from git://zen-kernel.org/kernel/mmotm.git
of today.

It compiles but I probably won't have time to test the -mm version
before next week.

There is one caveat: I had to remove the debugging patch from
mm/prio_tree.c because this check can no longer be done at that place.
If it is still required, it should be done in a macro inside the
callers that pass vmas and not anon_vma_chains to this function.

       regards     Christian

Signed-off-by: Christian Ehrhardt <lk@c--e.de>

 arch/arm/mm/fault-armv.c   |    3 +-
 arch/arm/mm/flush.c        |    3 +-
 arch/parisc/kernel/cache.c |    3 +-
 arch/x86/mm/hugetlbpage.c  |    3 +-
 fs/hugetlbfs/inode.c       |    3 +-
 fs/inode.c                 |    2 +-
 include/linux/mm.h         |   28 ++++++--
 include/linux/mm_types.h   |   10 +---
 include/linux/prio_tree.h  |   17 ++++-
 include/linux/rmap.h       |   11 ++--
 kernel/fork.c              |    2 +-
 lib/prio_tree.c            |   14 +++-
 mm/filemap_xip.c           |    3 +-
 mm/fremap.c                |    2 +-
 mm/hugetlb.c               |    3 +-
 mm/ksm.c                   |   21 +++++-
 mm/memory-failure.c        |    9 ++-
 mm/memory.c                |    5 +-
 mm/mmap.c                  |   26 ++++----
 mm/nommu.c                 |   12 ++--
 mm/prio_tree.c             |  161 ++++++++++++++++++--------------------------
 mm/rmap.c                  |   38 +++++++---
 22 files changed, 208 insertions(+), 171 deletions(-)

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
index d054f3d..bf9890b 100644
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
index 2800597..3a27f74 100644
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
 #ifdef CONFIG_FSNOTIFY
diff --git a/include/linux/mm.h b/include/linux/mm.h
index cb1144f..632d4c5 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1200,15 +1200,29 @@ extern atomic_long_t mmap_pages_allocated;
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
+#define vma_prio_tree_first_entry(iter, type, field) ({			\
+	union vma_prio_tree_node *__t;					\
+	__t = vma_prio_tree_next(NULL, iter);				\
+	__t ? prio_tree_entry(__t, type, field) : NULL;\
+})
+
+#define vma_prio_tree_next_entry(obj, iter, type, field) ({		\
+	union vma_prio_tree_node *__t;					\
+	__t = vma_prio_tree_next(&(obj)->field, iter);			\
+	__t ? prio_tree_entry(__t, type, field) : NULL;			\
+})
+
+#define vma_prio_tree_foreach(obj, type, field, iter, root, begin, end)	\
+	prio_tree_iter_init(iter, root, begin, end);			\
+	for (obj = vma_prio_tree_first_entry(iter, type, field); obj ;	\
+		(obj = vma_prio_tree_next_entry(obj, iter, type, field)))
 
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
diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index d25bd22..9e9a521 100644
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
-	struct list_head head;	/* Chain of private "related" vmas */
+	struct prio_tree_root head;
 };
 
 /*
@@ -57,7 +58,7 @@ struct anon_vma_chain {
 	struct vm_area_struct *vma;
 	struct anon_vma *anon_vma;
 	struct list_head same_vma;   /* locked by mmap_sem & page_table_lock */
-	struct list_head same_anon_vma;	/* locked by anon_vma->lock */
+	union vma_prio_tree_node same_anon_vma; /* locked by anon_vma->lock */
 };
 
 #ifdef CONFIG_MMU
diff --git a/kernel/fork.c b/kernel/fork.c
index b54abc4..51b16ea 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -355,7 +355,7 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 			tmp->vm_truncate_count = mpnt->vm_truncate_count;
 			flush_dcache_mmap_lock(mapping);
 			/* insert tmp into the share list, just after mpnt */
-			vma_prio_tree_add(tmp, mpnt);
+			vma_prio_tree_add(&tmp->shared, &mpnt->shared);
 			flush_dcache_mmap_unlock(mapping);
 			spin_unlock(&mapping->i_mmap_lock);
 		}
diff --git a/lib/prio_tree.c b/lib/prio_tree.c
index ccfd850..1d48709 100644
--- a/lib/prio_tree.c
+++ b/lib/prio_tree.c
@@ -14,6 +14,7 @@
 #include <linux/init.h>
 #include <linux/mm.h>
 #include <linux/prio_tree.h>
+#include <linux/rmap.h>
 
 /*
  * A clever mix of heap and radix trees forms a radix priority search tree (PST)
@@ -53,14 +54,21 @@ static void get_index(const struct prio_tree_root *root,
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
+		struct vm_area_struct *vma;
+
+		vma  = prio_tree_entry(node, struct anon_vma_chain,
+		    same_anon_vma.prio_tree_node)->vma;
+
+		*radix = RADIX_INDEX(vma);
+		*heap = HEAP_INDEX(vma);
+	} else {
 		*radix = node->start;
 		*heap = node->last;
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
diff --git a/mm/ksm.c b/mm/ksm.c
index a93f1b7..2eded1e 100644
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
@@ -1562,12 +1562,17 @@ int page_referenced_ksm(struct page *page, struct mem_cgroup *memcg,
 		return 0;
 again:
 	hlist_for_each_entry(rmap_item, hlist, &stable_node->hlist, hlist) {
+		pgoff_t pgoff = rmap_item->address >> PAGE_SHIFT;
 		struct anon_vma *anon_vma = rmap_item->anon_vma;
 		struct anon_vma_chain *vmac;
 		struct vm_area_struct *vma;
+		struct prio_tree_iter iter;
 
 		spin_lock(&anon_vma->lock);
-		list_for_each_entry(vmac, &anon_vma->head, same_anon_vma) {
+
+		vma_prio_tree_foreach(vmac, struct anon_vma_chain,
+				      same_anon_vma, &iter,
+				      &anon_vma->head, pgoff, pgoff) {
 			vma = vmac->vma;
 			if (rmap_item->address < vma->vm_start ||
 			    rmap_item->address >= vma->vm_end)
@@ -1615,12 +1620,16 @@ int try_to_unmap_ksm(struct page *page, enum ttu_flags flags)
 		return SWAP_FAIL;
 again:
 	hlist_for_each_entry(rmap_item, hlist, &stable_node->hlist, hlist) {
+		pgoff_t pgoff = rmap_item->address >> PAGE_SHIFT;
 		struct anon_vma *anon_vma = rmap_item->anon_vma;
 		struct anon_vma_chain *vmac;
 		struct vm_area_struct *vma;
+		struct prio_tree_iter iter;
 
 		spin_lock(&anon_vma->lock);
-		list_for_each_entry(vmac, &anon_vma->head, same_anon_vma) {
+		vma_prio_tree_foreach(vmac, struct anon_vma_chain,
+				      same_anon_vma, &iter,
+				      &anon_vma->head, pgoff, pgoff) {
 			vma = vmac->vma;
 			if (rmap_item->address < vma->vm_start ||
 			    rmap_item->address >= vma->vm_end)
@@ -1667,12 +1676,16 @@ int rmap_walk_ksm(struct page *page, int (*rmap_one)(struct page *,
 		return ret;
 again:
 	hlist_for_each_entry(rmap_item, hlist, &stable_node->hlist, hlist) {
+		pgoff_t pgoff = rmap_item->address >> PAGE_SHIFT;
 		struct anon_vma *anon_vma = rmap_item->anon_vma;
 		struct anon_vma_chain *vmac;
 		struct vm_area_struct *vma;
+		struct prio_tree_iter iter;
 
 		spin_lock(&anon_vma->lock);
-		list_for_each_entry(vmac, &anon_vma->head, same_anon_vma) {
+		vma_prio_tree_foreach(vmac, struct anon_vma_chain,
+				      same_anon_vma, &iter,
+				      &anon_vma->head, pgoff, pgoff) {
 			vma = vmac->vma;
 			if (rmap_item->address < vma->vm_start ||
 			    rmap_item->address >= vma->vm_end)
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index d1f3351..9ebe34c 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -383,11 +383,14 @@ static void collect_procs_anon(struct page *page, struct list_head *to_kill,
 	if (av == NULL)	/* Not actually mapped anymore */
 		goto out;
 	for_each_process (tsk) {
+		struct prio_tree_iter iter;
+		pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
 		struct anon_vma_chain *vmac;
 
 		if (!task_early_kill(tsk))
 			continue;
-		list_for_each_entry(vmac, &av->head, same_anon_vma) {
+		vma_prio_tree_foreach(vmac, struct anon_vma_chain,
+			      same_anon_vma, &iter, &av->head, pgoff, pgoff) {
 			vma = vmac->vma;
 			if (!page_mapped_in_vma(page, vma))
 				continue;
@@ -428,8 +431,8 @@ static void collect_procs_file(struct page *page, struct list_head *to_kill,
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
index f531087..af760c1 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2411,7 +2411,8 @@ static void reset_vma_truncate_counts(struct address_space *mapping)
 	struct vm_area_struct *vma;
 	struct prio_tree_iter iter;
 
-	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, 0, ULONG_MAX)
+	vma_prio_tree_foreach(vma, struct vm_area_struct, shared,
+				&iter, &mapping->i_mmap, 0, ULONG_MAX)
 		vma->vm_truncate_count = 0;
 	list_for_each_entry(vma, &mapping->i_mmap_nonlinear, shared.vm_set.list)
 		vma->vm_truncate_count = 0;
@@ -2472,7 +2473,7 @@ static inline void unmap_mapping_range_tree(struct prio_tree_root *root,
 	pgoff_t vba, vea, zba, zea;
 
 restart:
-	vma_prio_tree_foreach(vma, &iter, root,
+	vma_prio_tree_foreach(vma, struct vm_area_struct, shared, &iter, root,
 			details->first_index, details->last_index) {
 		/* Skip quickly over those we have already dealt with */
 		if (vma->vm_truncate_count == details->truncate_count)
diff --git a/mm/mmap.c b/mm/mmap.c
index 6cfd507..4497e79 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -207,7 +207,7 @@ static void __remove_shared_vm_struct(struct vm_area_struct *vma,
 	if (unlikely(vma->vm_flags & VM_NONLINEAR))
 		list_del_init(&vma->shared.vm_set.list);
 	else
-		vma_prio_tree_remove(vma, &mapping->i_mmap);
+		vma_prio_tree_remove(&vma->shared, &mapping->i_mmap);
 	flush_dcache_mmap_unlock(mapping);
 }
 
@@ -430,7 +430,7 @@ static void __vma_link_file(struct vm_area_struct *vma)
 		if (unlikely(vma->vm_flags & VM_NONLINEAR))
 			vma_nonlinear_insert(vma, &mapping->i_mmap_nonlinear);
 		else
-			vma_prio_tree_insert(vma, &mapping->i_mmap);
+			vma_prio_tree_insert(&vma->shared, &mapping->i_mmap);
 		flush_dcache_mmap_unlock(mapping);
 	}
 }
@@ -593,9 +593,9 @@ again:			remove_next = 1 + (end > next->vm_end);
 
 	if (root) {
 		flush_dcache_mmap_lock(mapping);
-		vma_prio_tree_remove(vma, root);
+		vma_prio_tree_remove(&vma->shared, root);
 		if (adjust_next)
-			vma_prio_tree_remove(next, root);
+			vma_prio_tree_remove(&next->shared, root);
 	}
 
 	vma->vm_start = start;
@@ -608,8 +608,8 @@ again:			remove_next = 1 + (end > next->vm_end);
 
 	if (root) {
 		if (adjust_next)
-			vma_prio_tree_insert(next, root);
-		vma_prio_tree_insert(vma, root);
+			vma_prio_tree_insert(&next->shared, root);
+		vma_prio_tree_insert(&vma->shared, root);
 		flush_dcache_mmap_unlock(mapping);
 	}
 
@@ -866,7 +866,7 @@ try_prev:
 	 * It is potentially slow to have to call find_vma_prev here.
 	 * But it's only on the first write fault on the vma, not
 	 * every time, and we could devise a way to avoid it later
-	 * (e.g. stash info in next's anon_vma_node when assigning
+	 * (e.g. stash info in next's anon node when assigning
 	 * an anon_vma, or when trying vma_merge).  Another time.
 	 */
 	BUG_ON(find_vma_prev(vma->vm_mm, vma->vm_start, &near) != vma);
@@ -2440,7 +2440,7 @@ static DEFINE_MUTEX(mm_all_locks_mutex);
 
 static void vm_lock_anon_vma(struct mm_struct *mm, struct anon_vma *anon_vma)
 {
-	if (!test_bit(0, (unsigned long *) &anon_vma->head.next)) {
+	if (!test_bit(0, (unsigned long *) &anon_vma->head.prio_tree_node)) {
 		/*
 		 * The LSB of head.next can't change from under us
 		 * because we hold the mm_all_locks_mutex.
@@ -2456,7 +2456,7 @@ static void vm_lock_anon_vma(struct mm_struct *mm, struct anon_vma *anon_vma)
 		 * anon_vma->lock.
 		 */
 		if (__test_and_set_bit(0, (unsigned long *)
-				       &anon_vma->head.next))
+				       &anon_vma->head.prio_tree_node))
 			BUG();
 	}
 }
@@ -2497,8 +2497,8 @@ static void vm_lock_mapping(struct mm_struct *mm, struct address_space *mapping)
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
@@ -2547,7 +2547,7 @@ out_unlock:
 
 static void vm_unlock_anon_vma(struct anon_vma *anon_vma)
 {
-	if (test_bit(0, (unsigned long *) &anon_vma->head.next)) {
+	if (test_bit(0, (unsigned long *) &anon_vma->head.prio_tree_node)) {
 		/*
 		 * The LSB of head.next can't change to 0 from under
 		 * us because we hold the mm_all_locks_mutex.
@@ -2561,7 +2561,7 @@ static void vm_unlock_anon_vma(struct anon_vma *anon_vma)
 		 * anon_vma->lock.
 		 */
 		if (!__test_and_clear_bit(0, (unsigned long *)
-					  &anon_vma->head.next))
+					  &anon_vma->head.prio_tree_node))
 			BUG();
 		spin_unlock(&anon_vma->lock);
 	}
diff --git a/mm/nommu.c b/mm/nommu.c
index 605ace8..aa4f77a 100644
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
 
@@ -1965,8 +1965,8 @@ int nommu_shrink_inode_mappings(struct inode *inode, size_t size,
 	down_write(&nommu_region_sem);
 
 	/* search for VMAs that fall within the dead zone */
-	vma_prio_tree_foreach(vma, &iter, &inode->i_mapping->i_mmap,
-			      low, high) {
+	vma_prio_tree_foreach(vma, struct vm_area_struct, shared, &iter,
+				&inode->i_mapping->i_mmap, low, high) {
 		/* found one - only interested if it's shared out of the page
 		 * cache */
 		if (vma->vm_flags & VM_SHARED) {
@@ -1981,8 +1981,8 @@ int nommu_shrink_inode_mappings(struct inode *inode, size_t size,
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
index c297a46..8e9194f 100644
--- a/mm/prio_tree.c
+++ b/mm/prio_tree.c
@@ -67,114 +67,85 @@
  * 	vma->shared.vm_set.head == NULL ==> a list node
  */
 
-static void dump_vma(struct vm_area_struct *vma)
-{
-	void **ptr = (void **) vma;
-	int i;
-
-	printk("vm_area_struct at %p:", ptr);
-	for (i = 0; i < sizeof(*vma)/sizeof(*ptr); i++, ptr++) {
-		if (!(i & 3))
-			printk("\n");
-		printk(" %p", *ptr);
-	}
-	printk("\n");
-}
-
 /*
  * Add a new vma known to map the same set of pages as the old vma:
  * useful for fork's dup_mmap as well as vma_prio_tree_insert below.
  * Note that it just happens to work correctly on i_mmap_nonlinear too.
  */
-void vma_prio_tree_add(struct vm_area_struct *vma, struct vm_area_struct *old)
+void vma_prio_tree_add(union vma_prio_tree_node *node,
+		       union vma_prio_tree_node *old)
 {
-	vma->shared.vm_set.head = NULL;
-	vma->shared.vm_set.parent = NULL;
-
-	if (WARN_ON(RADIX_INDEX(vma) != RADIX_INDEX(old) ||
-		    HEAP_INDEX(vma)  != HEAP_INDEX(old))) {
-		/*
-		 * This should never happen, yet it has been seen a few times:
-		 * we cannot say much about it without seeing the vma contents.
-		 */
-		dump_vma(vma);
-		dump_vma(old);
-		/*
-		 * Don't try to link this (corrupt?) vma into the (corrupt?)
-		 * prio_tree, but arrange for its removal to succeed later.
-		 */
-		INIT_LIST_HEAD(&vma->shared.vm_set.list);
-	} else if (!old->shared.vm_set.parent)
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
@@ -184,46 +155,46 @@ void vma_prio_tree_remove(struct vm_area_struct *vma,
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
index fcd593c..34391d4 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -142,7 +142,8 @@ int anon_vma_prepare(struct vm_area_struct *vma)
 			avc->anon_vma = anon_vma;
 			avc->vma = vma;
 			list_add(&avc->same_vma, &vma->anon_vma_chain);
-			list_add(&avc->same_anon_vma, &anon_vma->head);
+			vma_prio_tree_insert(&avc->same_anon_vma,
+						&anon_vma->head);
 			allocated = NULL;
 		}
 		spin_unlock(&mm->page_table_lock);
@@ -170,7 +171,7 @@ static void anon_vma_chain_link(struct vm_area_struct *vma,
 	list_add(&avc->same_vma, &vma->anon_vma_chain);
 
 	spin_lock(&anon_vma->lock);
-	list_add_tail(&avc->same_anon_vma, &anon_vma->head);
+	vma_prio_tree_insert(&avc->same_anon_vma, &anon_vma->head);
 	spin_unlock(&anon_vma->lock);
 }
 
@@ -245,10 +246,10 @@ static void anon_vma_unlink(struct anon_vma_chain *anon_vma_chain)
 		return;
 
 	spin_lock(&anon_vma->lock);
-	list_del(&anon_vma_chain->same_anon_vma);
+	vma_prio_tree_remove(&anon_vma_chain->same_anon_vma, &anon_vma->head);
 
 	/* We must garbage collect the anon_vma if it's empty */
-	empty = list_empty(&anon_vma->head) && !ksm_refcount(anon_vma);
+	empty = prio_tree_empty(&anon_vma->head) && !ksm_refcount(anon_vma);
 	spin_unlock(&anon_vma->lock);
 
 	if (empty)
@@ -273,7 +274,7 @@ static void anon_vma_ctor(void *data)
 
 	spin_lock_init(&anon_vma->lock);
 	ksm_refcount_init(anon_vma);
-	INIT_LIST_HEAD(&anon_vma->head);
+	INIT_ANON_PRIO_TREE_ROOT(&anon_vma->head);
 }
 
 void __init anon_vma_init(void)
@@ -483,9 +484,11 @@ static int page_referenced_anon(struct page *page,
 				struct mem_cgroup *mem_cont,
 				unsigned long *vm_flags)
 {
+	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
 	unsigned int mapcount;
 	struct anon_vma *anon_vma;
 	struct anon_vma_chain *avc;
+	struct prio_tree_iter iter;
 	int referenced = 0;
 
 	anon_vma = page_lock_anon_vma(page);
@@ -493,7 +496,8 @@ static int page_referenced_anon(struct page *page,
 		return referenced;
 
 	mapcount = page_mapcount(page);
-	list_for_each_entry(avc, &anon_vma->head, same_anon_vma) {
+	vma_prio_tree_foreach(avc, struct anon_vma_chain, same_anon_vma,
+				&iter, &anon_vma->head, pgoff, pgoff) {
 		struct vm_area_struct *vma = avc->vma;
 		unsigned long address = vma_address(page, vma);
 		if (address == -EFAULT)
@@ -562,7 +566,8 @@ static int page_referenced_file(struct page *page,
 	 */
 	mapcount = page_mapcount(page);
 
-	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
+	vma_prio_tree_foreach(vma, struct vm_area_struct, shared, &iter,
+					&mapping->i_mmap, pgoff, pgoff) {
 		unsigned long address = vma_address(page, vma);
 		if (address == -EFAULT)
 			continue;
@@ -667,7 +672,8 @@ static int page_mkclean_file(struct address_space *mapping, struct page *page)
 	BUG_ON(PageAnon(page));
 
 	spin_lock(&mapping->i_mmap_lock);
-	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
+	vma_prio_tree_foreach(vma, struct vm_area_struct, shared, &iter,
+					&mapping->i_mmap, pgoff, pgoff) {
 		if (vma->vm_flags & VM_SHARED) {
 			unsigned long address = vma_address(page, vma);
 			if (address == -EFAULT)
@@ -1132,15 +1138,18 @@ static int try_to_unmap_cluster(unsigned long cursor, unsigned int *mapcount,
  */
 static int try_to_unmap_anon(struct page *page, enum ttu_flags flags)
 {
+	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
 	struct anon_vma *anon_vma;
 	struct anon_vma_chain *avc;
+	struct prio_tree_iter iter;
 	int ret = SWAP_AGAIN;
 
 	anon_vma = page_lock_anon_vma(page);
 	if (!anon_vma)
 		return ret;
 
-	list_for_each_entry(avc, &anon_vma->head, same_anon_vma) {
+	vma_prio_tree_foreach(avc, struct anon_vma_chain, same_anon_vma,
+				&iter, &anon_vma->head, pgoff, pgoff) {
 		struct vm_area_struct *vma = avc->vma;
 		unsigned long address = vma_address(page, vma);
 		if (address == -EFAULT)
@@ -1182,7 +1191,8 @@ static int try_to_unmap_file(struct page *page, enum ttu_flags flags)
 	unsigned int mapcount;
 
 	spin_lock(&mapping->i_mmap_lock);
-	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
+	vma_prio_tree_foreach(vma, struct vm_area_struct, shared, &iter,
+					&mapping->i_mmap, pgoff, pgoff) {
 		unsigned long address = vma_address(page, vma);
 		if (address == -EFAULT)
 			continue;
@@ -1331,9 +1341,11 @@ int try_to_munlock(struct page *page)
 static int rmap_walk_anon(struct page *page, int (*rmap_one)(struct page *,
 		struct vm_area_struct *, unsigned long, void *), void *arg)
 {
+	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
 	struct anon_vma *anon_vma;
 	struct anon_vma_chain *avc;
 	int ret = SWAP_AGAIN;
+	struct prio_tree_iter iter;
 
 	/*
 	 * Note: remove_migration_ptes() cannot use page_lock_anon_vma()
@@ -1347,7 +1359,8 @@ static int rmap_walk_anon(struct page *page, int (*rmap_one)(struct page *,
 	if (!anon_vma)
 		return ret;
 	spin_lock(&anon_vma->lock);
-	list_for_each_entry(avc, &anon_vma->head, same_anon_vma) {
+	vma_prio_tree_foreach(avc, struct anon_vma_chain, same_anon_vma,
+				&iter, &anon_vma->head, pgoff, pgoff) {
 		struct vm_area_struct *vma = avc->vma;
 		unsigned long address = vma_address(page, vma);
 		if (address == -EFAULT)
@@ -1372,7 +1385,8 @@ static int rmap_walk_file(struct page *page, int (*rmap_one)(struct page *,
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
