Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id A73726B005D
	for <linux-mm@kvack.org>; Tue,  7 Aug 2012 03:26:02 -0400 (EDT)
Received: by pbbjt11 with SMTP id jt11so3954334pbb.14
        for <linux-mm@kvack.org>; Tue, 07 Aug 2012 00:26:02 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 2/5] mm: replace vma prio_tree with an interval tree
Date: Tue,  7 Aug 2012 00:25:40 -0700
Message-Id: <1344324343-3817-3-git-send-email-walken@google.com>
In-Reply-To: <1344324343-3817-1-git-send-email-walken@google.com>
References: <1344324343-3817-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: riel@redhat.com, peterz@infradead.org, vrajesh@umich.edu, daniel.santos@pobox.com, aarcange@redhat.com, dwmw2@infradead.org, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

Implement an interval tree as a replacement for the VMA prio_tree.
The algorithms are similar to lib/interval_tree.c; however that code
can't be directly reused as the interval endpoints are not explicitly
stored in the VMA. So instead, the common algorithm is moved into
a template and the details (node type, how to get interval endpoints
from the node, etc) are filled in using the C preprocessor.

Once the interval tree functions are available, using them as a replacement
to the VMA prio tree is a relatively simple, mechanical job.

Signed-off-by: Michel Lespinasse <walken@google.com>
---
 arch/arm/mm/fault-armv.c           |    3 +-
 arch/arm/mm/flush.c                |    3 +-
 arch/parisc/kernel/cache.c         |    3 +-
 arch/x86/mm/hugetlbpage.c          |    3 +-
 fs/hugetlbfs/inode.c               |    9 +-
 fs/inode.c                         |    2 +-
 include/linux/fs.h                 |    6 +-
 include/linux/interval_tree_tmpl.h |  215 ++++++++++++++++++++++++++++++++++++
 include/linux/mm.h                 |   30 +++--
 include/linux/mm_types.h           |   14 +--
 kernel/events/uprobes.c            |    3 +-
 kernel/fork.c                      |    2 +-
 lib/interval_tree.c                |  166 ++--------------------------
 lib/prio_tree.c                    |   19 +---
 mm/Makefile                        |    4 +-
 mm/filemap_xip.c                   |    3 +-
 mm/fremap.c                        |    2 +-
 mm/hugetlb.c                       |    3 +-
 mm/interval_tree.c                 |   61 ++++++++++
 mm/memory-failure.c                |    3 +-
 mm/memory.c                        |    9 +-
 mm/mmap.c                          |   22 ++--
 mm/nommu.c                         |   12 +-
 mm/prio_tree.c                     |  208 ----------------------------------
 mm/rmap.c                          |   18 +--
 25 files changed, 357 insertions(+), 466 deletions(-)
 create mode 100644 include/linux/interval_tree_tmpl.h
 create mode 100644 mm/interval_tree.c
 delete mode 100644 mm/prio_tree.c

diff --git a/arch/arm/mm/fault-armv.c b/arch/arm/mm/fault-armv.c
index 7599e26..2a5907b 100644
--- a/arch/arm/mm/fault-armv.c
+++ b/arch/arm/mm/fault-armv.c
@@ -134,7 +134,6 @@ make_coherent(struct address_space *mapping, struct vm_area_struct *vma,
 {
 	struct mm_struct *mm = vma->vm_mm;
 	struct vm_area_struct *mpnt;
-	struct prio_tree_iter iter;
 	unsigned long offset;
 	pgoff_t pgoff;
 	int aliases = 0;
@@ -147,7 +146,7 @@ make_coherent(struct address_space *mapping, struct vm_area_struct *vma,
 	 * cache coherency.
 	 */
 	flush_dcache_mmap_lock(mapping);
-	vma_prio_tree_foreach(mpnt, &iter, &mapping->i_mmap, pgoff, pgoff) {
+	vma_interval_tree_foreach(mpnt, &mapping->i_mmap, pgoff, pgoff) {
 		/*
 		 * If this VMA is not in our MM, we can ignore it.
 		 * Note that we intentionally mask out the VMA
diff --git a/arch/arm/mm/flush.c b/arch/arm/mm/flush.c
index 7745854..ad174f6 100644
--- a/arch/arm/mm/flush.c
+++ b/arch/arm/mm/flush.c
@@ -196,7 +196,6 @@ static void __flush_dcache_aliases(struct address_space *mapping, struct page *p
 {
 	struct mm_struct *mm = current->active_mm;
 	struct vm_area_struct *mpnt;
-	struct prio_tree_iter iter;
 	pgoff_t pgoff;
 
 	/*
@@ -208,7 +207,7 @@ static void __flush_dcache_aliases(struct address_space *mapping, struct page *p
 	pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
 
 	flush_dcache_mmap_lock(mapping);
-	vma_prio_tree_foreach(mpnt, &iter, &mapping->i_mmap, pgoff, pgoff) {
+	vma_interval_tree_foreach(mpnt, &mapping->i_mmap, pgoff, pgoff) {
 		unsigned long offset;
 
 		/*
diff --git a/arch/parisc/kernel/cache.c b/arch/parisc/kernel/cache.c
index 9d18189..48e16dc 100644
--- a/arch/parisc/kernel/cache.c
+++ b/arch/parisc/kernel/cache.c
@@ -276,7 +276,6 @@ void flush_dcache_page(struct page *page)
 {
 	struct address_space *mapping = page_mapping(page);
 	struct vm_area_struct *mpnt;
-	struct prio_tree_iter iter;
 	unsigned long offset;
 	unsigned long addr, old_addr = 0;
 	pgoff_t pgoff;
@@ -299,7 +298,7 @@ void flush_dcache_page(struct page *page)
 	 * to flush one address here for them all to become coherent */
 
 	flush_dcache_mmap_lock(mapping);
-	vma_prio_tree_foreach(mpnt, &iter, &mapping->i_mmap, pgoff, pgoff) {
+	vma_interval_tree_foreach(mpnt, &mapping->i_mmap, pgoff, pgoff) {
 		offset = (pgoff - mpnt->vm_pgoff) << PAGE_SHIFT;
 		addr = mpnt->vm_start + offset;
 
diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
index f6679a7..b396cc1 100644
--- a/arch/x86/mm/hugetlbpage.c
+++ b/arch/x86/mm/hugetlbpage.c
@@ -64,7 +64,6 @@ static void huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
 	struct address_space *mapping = vma->vm_file->f_mapping;
 	pgoff_t idx = ((addr - vma->vm_start) >> PAGE_SHIFT) +
 			vma->vm_pgoff;
-	struct prio_tree_iter iter;
 	struct vm_area_struct *svma;
 	unsigned long saddr;
 	pte_t *spte = NULL;
@@ -73,7 +72,7 @@ static void huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
 		return;
 
 	mutex_lock(&mapping->i_mmap_mutex);
-	vma_prio_tree_foreach(svma, &iter, &mapping->i_mmap, idx, idx) {
+	vma_interval_tree_foreach(svma, &mapping->i_mmap, idx, idx) {
 		if (svma == vma)
 			continue;
 
diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index cc9281b..e011215 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -397,17 +397,16 @@ static void hugetlbfs_evict_inode(struct inode *inode)
 }
 
 static inline void
-hugetlb_vmtruncate_list(struct prio_tree_root *root, pgoff_t pgoff)
+hugetlb_vmtruncate_list(struct rb_root *root, pgoff_t pgoff)
 {
 	struct vm_area_struct *vma;
-	struct prio_tree_iter iter;
 
-	vma_prio_tree_foreach(vma, &iter, root, pgoff, ULONG_MAX) {
+	vma_interval_tree_foreach(vma, root, pgoff, ULONG_MAX) {
 		unsigned long v_offset;
 
 		/*
 		 * Can the expression below overflow on 32-bit arches?
-		 * No, because the prio_tree returns us only those vmas
+		 * No, because the interval tree returns us only those vmas
 		 * which overlap the truncated area starting at pgoff,
 		 * and no vma on a 32-bit arch can span beyond the 4GB.
 		 */
@@ -432,7 +431,7 @@ static int hugetlb_vmtruncate(struct inode *inode, loff_t offset)
 
 	i_size_write(inode, offset);
 	mutex_lock(&mapping->i_mmap_mutex);
-	if (!prio_tree_empty(&mapping->i_mmap))
+	if (!RB_EMPTY_ROOT(&mapping->i_mmap))
 		hugetlb_vmtruncate_list(&mapping->i_mmap, pgoff);
 	mutex_unlock(&mapping->i_mmap_mutex);
 	truncate_hugepages(inode, offset);
diff --git a/fs/inode.c b/fs/inode.c
index c99163b..0db8553 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -348,7 +348,7 @@ void address_space_init_once(struct address_space *mapping)
 	mutex_init(&mapping->i_mmap_mutex);
 	INIT_LIST_HEAD(&mapping->private_list);
 	spin_lock_init(&mapping->private_lock);
-	INIT_RAW_PRIO_TREE_ROOT(&mapping->i_mmap);
+	mapping->i_mmap = RB_ROOT;
 	INIT_LIST_HEAD(&mapping->i_mmap_nonlinear);
 }
 EXPORT_SYMBOL(address_space_init_once);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 17fd887..f33145c 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -399,7 +399,7 @@ struct inodes_stat_t {
 #include <linux/cache.h>
 #include <linux/list.h>
 #include <linux/radix-tree.h>
-#include <linux/prio_tree.h>
+#include <linux/rbtree.h>
 #include <linux/init.h>
 #include <linux/pid.h>
 #include <linux/bug.h>
@@ -658,7 +658,7 @@ struct address_space {
 	struct radix_tree_root	page_tree;	/* radix tree of all pages */
 	spinlock_t		tree_lock;	/* and lock protecting it */
 	unsigned int		i_mmap_writable;/* count VM_SHARED mappings */
-	struct prio_tree_root	i_mmap;		/* tree of private and shared mappings */
+	struct rb_root		i_mmap;		/* tree of private and shared mappings */
 	struct list_head	i_mmap_nonlinear;/*list VM_NONLINEAR mappings */
 	struct mutex		i_mmap_mutex;	/* protect tree, count, list */
 	/* Protected by tree_lock together with the radix tree */
@@ -730,7 +730,7 @@ int mapping_tagged(struct address_space *mapping, int tag);
  */
 static inline int mapping_mapped(struct address_space *mapping)
 {
-	return	!prio_tree_empty(&mapping->i_mmap) ||
+	return	!RB_EMPTY_ROOT(&mapping->i_mmap) ||
 		!list_empty(&mapping->i_mmap_nonlinear);
 }
 
diff --git a/include/linux/interval_tree_tmpl.h b/include/linux/interval_tree_tmpl.h
new file mode 100644
index 0000000..c65deda
--- /dev/null
+++ b/include/linux/interval_tree_tmpl.h
@@ -0,0 +1,215 @@
+/*
+  Interval Trees
+  (C) 2012  Michel Lespinasse <walken@google.com>
+
+  This program is free software; you can redistribute it and/or modify
+  it under the terms of the GNU General Public License as published by
+  the Free Software Foundation; either version 2 of the License, or
+  (at your option) any later version.
+
+  This program is distributed in the hope that it will be useful,
+  but WITHOUT ANY WARRANTY; without even the implied warranty of
+  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+  GNU General Public License for more details.
+
+  You should have received a copy of the GNU General Public License
+  along with this program; if not, write to the Free Software
+  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+  include/linux/interval_tree_tmpl.h
+*/
+
+/*
+ * Template for implementing interval trees
+ *
+ * ITSTRUCT:   struct type of the interval tree nodes
+ * ITRB:       name of struct rb_node field within ITSTRUCT
+ * ITTYPE:     type of the interval endpoints
+ * ITSUBTREE:  name of ITTYPE field within ITSTRUCT holding last-in-subtree
+ * ITSTART(n): start endpoint of ITSTRUCT node n
+ * ITLAST(n):  last endpoing of ITSTRUCT node n
+ * ITSTATIC:   'static' or empty
+ * ITPREFIX:   prefix to use for the inline tree definitions
+ */
+
+/* IT(name) -> ITPREFIX_name */
+#define _ITNAME(prefix, name) prefix ## _ ## name
+#define ITNAME(prefix, name) _ITNAME(prefix, name)
+#define IT(name) ITNAME(ITPREFIX, name)
+
+/* Callbacks for augmented rbtree insert and remove */
+
+static inline ITTYPE IT(compute_subtree_last)(ITSTRUCT *node)
+{
+	ITTYPE max = ITLAST(node), subtree_last;
+	if (node->ITRB.rb_left) {
+		subtree_last = rb_entry(node->ITRB.rb_left,
+					ITSTRUCT, ITRB)->ITSUBTREE;
+		if (max < subtree_last)
+			max = subtree_last;
+	}
+	if (node->ITRB.rb_right) {
+		subtree_last = rb_entry(node->ITRB.rb_right,
+					ITSTRUCT, ITRB)->ITSUBTREE;
+		if (max < subtree_last)
+			max = subtree_last;
+	}
+	return max;
+}
+
+static void IT(augment_propagate)(struct rb_node *rb, struct rb_node *stop)
+{
+	while (rb != stop) {
+		ITSTRUCT *node = rb_entry(rb, ITSTRUCT, ITRB);
+		ITTYPE subtree_last = IT(compute_subtree_last)(node);
+		if (node->ITSUBTREE == subtree_last)
+			break;
+		node->ITSUBTREE = subtree_last;
+		rb = rb_parent(&node->ITRB);
+	}
+}
+
+static void IT(augment_copy)(struct rb_node *rb_old, struct rb_node *rb_new)
+{
+	ITSTRUCT *old = rb_entry(rb_old, ITSTRUCT, ITRB);
+	ITSTRUCT *new = rb_entry(rb_new, ITSTRUCT, ITRB);
+
+	new->ITSUBTREE = old->ITSUBTREE;
+}
+
+static void IT(augment_rotate)(struct rb_node *rb_old, struct rb_node *rb_new)
+{
+	ITSTRUCT *old = rb_entry(rb_old, ITSTRUCT, ITRB);
+	ITSTRUCT *new = rb_entry(rb_new, ITSTRUCT, ITRB);
+
+	new->ITSUBTREE = old->ITSUBTREE;
+	old->ITSUBTREE = IT(compute_subtree_last)(old);
+}
+
+static const struct rb_augment_callbacks IT(augment_callbacks) = {
+	IT(augment_propagate), IT(augment_copy), IT(augment_rotate)
+};
+
+/* Insert / remove interval nodes from the tree */
+
+ITSTATIC void IT(insert)(ITSTRUCT *node, struct rb_root *root)
+{
+	struct rb_node **link = &root->rb_node, *rb_parent = NULL;
+	ITTYPE start = ITSTART(node), last = ITLAST(node);
+	ITSTRUCT *parent;
+
+	while (*link) {
+		rb_parent = *link;
+		parent = rb_entry(rb_parent, ITSTRUCT, ITRB);
+		if (parent->ITSUBTREE < last)
+			parent->ITSUBTREE = last;
+		if (start < ITSTART(parent))
+			link = &parent->ITRB.rb_left;
+		else
+			link = &parent->ITRB.rb_right;
+	}
+
+	node->ITSUBTREE = last;
+	rb_link_node(&node->ITRB, rb_parent, link);
+	rb_insert_augmented(&node->ITRB, root, &IT(augment_callbacks));
+}
+
+ITSTATIC void IT(remove)(ITSTRUCT *node, struct rb_root *root)
+{
+	rb_erase_augmented(&node->ITRB, root, &IT(augment_callbacks));
+}
+
+/*
+ * Iterate over intervals intersecting [start;last]
+ *
+ * Note that a node's interval intersects [start;last] iff:
+ *   Cond1: ITSTART(node) <= last
+ * and
+ *   Cond2: start <= ITLAST(node)
+ */
+
+static ITSTRUCT *IT(subtree_search)(ITSTRUCT *node, ITTYPE start, ITTYPE last)
+{
+	while (true) {
+		/*
+		 * Loop invariant: start <= node->ITSUBTREE
+		 * (Cond2 is satisfied by one of the subtree nodes)
+		 */
+		if (node->ITRB.rb_left) {
+			ITSTRUCT *left = rb_entry(node->ITRB.rb_left,
+						  ITSTRUCT, ITRB);
+			if (start <= left->ITSUBTREE) {
+				/*
+				 * Some nodes in left subtree satisfy Cond2.
+				 * Iterate to find the leftmost such node N.
+				 * If it also satisfies Cond1, that's the match
+				 * we are looking for. Otherwise, there is no
+				 * matching interval as nodes to the right of N
+				 * can't satisfy Cond1 either.
+				 */
+				node = left;
+				continue;
+			}
+		}
+		if (ITSTART(node) <= last) {		/* Cond1 */
+			if (start <= ITLAST(node))	/* Cond2 */
+				return node;	/* node is leftmost match */
+			if (node->ITRB.rb_right) {
+				node = rb_entry(node->ITRB.rb_right,
+						ITSTRUCT, ITRB);
+				if (start <= node->ITSUBTREE)
+					continue;
+			}
+		}
+		return NULL;	/* No match */
+	}
+}
+
+ITSTATIC ITSTRUCT *IT(iter_first)(struct rb_root *root,
+				  ITTYPE start, ITTYPE last)
+{
+	ITSTRUCT *node;
+
+	if (!root->rb_node)
+		return NULL;
+	node = rb_entry(root->rb_node, ITSTRUCT, ITRB);
+	if (node->ITSUBTREE < start)
+		return NULL;
+	return IT(subtree_search)(node, start, last);
+}
+
+ITSTATIC ITSTRUCT *IT(iter_next)(ITSTRUCT *node, ITTYPE start, ITTYPE last)
+{
+	struct rb_node *rb = node->ITRB.rb_right, *prev;
+
+	while (true) {
+		/*
+		 * Loop invariants:
+		 *   Cond1: ITSTART(node) <= last
+		 *   rb == node->ITRB.rb_right
+		 *
+		 * First, search right subtree if suitable
+		 */
+		if (rb) {
+			ITSTRUCT *right = rb_entry(rb, ITSTRUCT, ITRB);
+			if (start <= right->ITSUBTREE)
+				return IT(subtree_search)(right, start, last);
+		}
+
+		/* Move up the tree until we come from a node's left child */
+		do {
+			rb = rb_parent(&node->ITRB);
+			if (!rb)
+				return NULL;
+			prev = &node->ITRB;
+			node = rb_entry(rb, ITSTRUCT, ITRB);
+			rb = node->ITRB.rb_right;
+		} while (prev == rb);
+
+		/* Check if the node intersects [start;last] */
+		if (last < ITSTART(node))		/* !Cond1 */
+			return NULL;
+		else if (start <= ITLAST(node))		/* Cond2 */
+			return node;
+	}
+}
diff --git a/include/linux/mm.h b/include/linux/mm.h
index b36d08c..dc504c7 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -10,7 +10,6 @@
 #include <linux/list.h>
 #include <linux/mmzone.h>
 #include <linux/rbtree.h>
-#include <linux/prio_tree.h>
 #include <linux/atomic.h>
 #include <linux/debug_locks.h>
 #include <linux/mm_types.h>
@@ -1336,22 +1335,27 @@ extern void zone_pcp_update(struct zone *zone);
 extern atomic_long_t mmap_pages_allocated;
 extern int nommu_shrink_inode_mappings(struct inode *, size_t, size_t);
 
-/* prio_tree.c */
-void vma_prio_tree_add(struct vm_area_struct *, struct vm_area_struct *old);
-void vma_prio_tree_insert(struct vm_area_struct *, struct prio_tree_root *);
-void vma_prio_tree_remove(struct vm_area_struct *, struct prio_tree_root *);
-struct vm_area_struct *vma_prio_tree_next(struct vm_area_struct *vma,
-	struct prio_tree_iter *iter);
-
-#define vma_prio_tree_foreach(vma, iter, root, begin, end)	\
-	for (prio_tree_iter_init(iter, root, begin, end), vma = NULL;	\
-		(vma = vma_prio_tree_next(vma, iter)); )
+/* interval_tree.c */
+void vma_interval_tree_add(struct vm_area_struct *vma,
+			   struct vm_area_struct *old,
+			   struct address_space *mapping);
+void vma_interval_tree_insert(struct vm_area_struct *node,
+			      struct rb_root *root);
+void vma_interval_tree_remove(struct vm_area_struct *node,
+			      struct rb_root *root);
+struct vm_area_struct *vma_interval_tree_iter_first(struct rb_root *root,
+				unsigned long start, unsigned long last);
+struct vm_area_struct *vma_interval_tree_iter_next(struct vm_area_struct *node,
+				unsigned long start, unsigned long last);
+
+#define vma_interval_tree_foreach(vma, root, start, last)		\
+	for (vma = vma_interval_tree_iter_first(root, start, last);	\
+	     vma; vma = vma_interval_tree_iter_next(vma, start, last))
 
 static inline void vma_nonlinear_insert(struct vm_area_struct *vma,
 					struct list_head *list)
 {
-	vma->shared.vm_set.parent = NULL;
-	list_add_tail(&vma->shared.vm_set.list, list);
+	list_add_tail(&vma->shared.nonlinear, list);
 }
 
 /* mmap.c */
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 704a626..a198a40 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -6,7 +6,6 @@
 #include <linux/threads.h>
 #include <linux/list.h>
 #include <linux/spinlock.h>
-#include <linux/prio_tree.h>
 #include <linux/rbtree.h>
 #include <linux/rwsem.h>
 #include <linux/completion.h>
@@ -224,18 +223,15 @@ struct vm_area_struct {
 
 	/*
 	 * For areas with an address space and backing store,
-	 * linkage into the address_space->i_mmap prio tree, or
-	 * linkage to the list of like vmas hanging off its node, or
+	 * linkage into the address_space->i_mmap interval tree, or
 	 * linkage of vma in the address_space->i_mmap_nonlinear list.
 	 */
 	union {
 		struct {
-			struct list_head list;
-			void *parent;	/* aligns with prio_tree_node parent */
-			struct vm_area_struct *head;
-		} vm_set;
-
-		struct raw_prio_tree_node prio_tree_node;
+			struct rb_node rb;
+			unsigned long rb_subtree_last;
+		} linear;
+		struct list_head nonlinear;
 	} shared;
 
 	/*
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 985be4d..c06930e 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -754,7 +754,6 @@ static struct vma_info *
 __find_next_vma_info(struct address_space *mapping, struct list_head *head,
 			struct vma_info *vi, loff_t offset, bool is_register)
 {
-	struct prio_tree_iter iter;
 	struct vm_area_struct *vma;
 	struct vma_info *tmpvi;
 	unsigned long pgoff;
@@ -763,7 +762,7 @@ __find_next_vma_info(struct address_space *mapping, struct list_head *head,
 
 	pgoff = offset >> PAGE_SHIFT;
 
-	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
+	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
 		if (!valid_vma(vma, is_register))
 			continue;
 
diff --git a/kernel/fork.c b/kernel/fork.c
index f00e319..1a5a355 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -425,7 +425,7 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 				mapping->i_mmap_writable++;
 			flush_dcache_mmap_lock(mapping);
 			/* insert tmp into the share list, just after mpnt */
-			vma_prio_tree_add(tmp, mpnt);
+			vma_interval_tree_add(tmp, mpnt, mapping);
 			flush_dcache_mmap_unlock(mapping);
 			mutex_unlock(&mapping->i_mmap_mutex);
 		}
diff --git a/lib/interval_tree.c b/lib/interval_tree.c
index 6fd540b..77a793e 100644
--- a/lib/interval_tree.c
+++ b/lib/interval_tree.c
@@ -1,159 +1,13 @@
 #include <linux/init.h>
 #include <linux/interval_tree.h>
 
-/* Callbacks for augmented rbtree insert and remove */
-
-static inline unsigned long
-compute_subtree_last(struct interval_tree_node *node)
-{
-	unsigned long max = node->last, subtree_last;
-	if (node->rb.rb_left) {
-		subtree_last = rb_entry(node->rb.rb_left,
-			struct interval_tree_node, rb)->__subtree_last;
-		if (max < subtree_last)
-			max = subtree_last;
-	}
-	if (node->rb.rb_right) {
-		subtree_last = rb_entry(node->rb.rb_right,
-			struct interval_tree_node, rb)->__subtree_last;
-		if (max < subtree_last)
-			max = subtree_last;
-	}
-	return max;
-}
-
-RB_DECLARE_CALLBACKS(static, augment_callbacks, struct interval_tree_node, rb,
-		     unsigned long, __subtree_last, compute_subtree_last)
-
-/* Insert / remove interval nodes from the tree */
-
-void interval_tree_insert(struct interval_tree_node *node,
-			  struct rb_root *root)
-{
-	struct rb_node **link = &root->rb_node, *rb_parent = NULL;
-	unsigned long start = node->start, last = node->last;
-	struct interval_tree_node *parent;
-
-	while (*link) {
-		rb_parent = *link;
-		parent = rb_entry(rb_parent, struct interval_tree_node, rb);
-		if (parent->__subtree_last < last)
-			parent->__subtree_last = last;
-		if (start < parent->start)
-			link = &parent->rb.rb_left;
-		else
-			link = &parent->rb.rb_right;
-	}
-
-	node->__subtree_last = last;
-	rb_link_node(&node->rb, rb_parent, link);
-	rb_insert_augmented(&node->rb, root, &augment_callbacks);
-}
-
-void interval_tree_remove(struct interval_tree_node *node,
-			  struct rb_root *root)
-{
-	rb_erase_augmented(&node->rb, root, &augment_callbacks);
-}
-
-/*
- * Iterate over intervals intersecting [start;last]
- *
- * Note that a node's interval intersects [start;last] iff:
- *   Cond1: node->start <= last
- * and
- *   Cond2: start <= node->last
- */
-
-static struct interval_tree_node *
-subtree_search(struct interval_tree_node *node,
-	       unsigned long start, unsigned long last)
-{
-	while (true) {
-		/*
-		 * Loop invariant: start <= node->__subtree_last
-		 * (Cond2 is satisfied by one of the subtree nodes)
-		 */
-		if (node->rb.rb_left) {
-			struct interval_tree_node *left =
-				rb_entry(node->rb.rb_left,
-					 struct interval_tree_node, rb);
-			if (start <= left->__subtree_last) {
-				/*
-				 * Some nodes in left subtree satisfy Cond2.
-				 * Iterate to find the leftmost such node N.
-				 * If it also satisfies Cond1, that's the match
-				 * we are looking for. Otherwise, there is no
-				 * matching interval as nodes to the right of N
-				 * can't satisfy Cond1 either.
-				 */
-				node = left;
-				continue;
-			}
-		}
-		if (node->start <= last) {		/* Cond1 */
-			if (start <= node->last)	/* Cond2 */
-				return node;	/* node is leftmost match */
-			if (node->rb.rb_right) {
-				node = rb_entry(node->rb.rb_right,
-					struct interval_tree_node, rb);
-				if (start <= node->__subtree_last)
-					continue;
-			}
-		}
-		return NULL;	/* No match */
-	}
-}
-
-struct interval_tree_node *
-interval_tree_iter_first(struct rb_root *root,
-			 unsigned long start, unsigned long last)
-{
-	struct interval_tree_node *node;
-
-	if (!root->rb_node)
-		return NULL;
-	node = rb_entry(root->rb_node, struct interval_tree_node, rb);
-	if (node->__subtree_last < start)
-		return NULL;
-	return subtree_search(node, start, last);
-}
-
-struct interval_tree_node *
-interval_tree_iter_next(struct interval_tree_node *node,
-			unsigned long start, unsigned long last)
-{
-	struct rb_node *rb = node->rb.rb_right, *prev;
-
-	while (true) {
-		/*
-		 * Loop invariants:
-		 *   Cond1: node->start <= last
-		 *   rb == node->rb.rb_right
-		 *
-		 * First, search right subtree if suitable
-		 */
-		if (rb) {
-			struct interval_tree_node *right =
-				rb_entry(rb, struct interval_tree_node, rb);
-			if (start <= right->__subtree_last)
-				return subtree_search(right, start, last);
-		}
-
-		/* Move up the tree until we come from a node's left child */
-		do {
-			rb = rb_parent(&node->rb);
-			if (!rb)
-				return NULL;
-			prev = &node->rb;
-			node = rb_entry(rb, struct interval_tree_node, rb);
-			rb = node->rb.rb_right;
-		} while (prev == rb);
-
-		/* Check if the node intersects [start;last] */
-		if (last < node->start)		/* !Cond1 */
-			return NULL;
-		else if (start <= node->last)	/* Cond2 */
-			return node;
-	}
-}
+#define ITSTRUCT   struct interval_tree_node
+#define ITRB       rb
+#define ITTYPE     unsigned long
+#define ITSUBTREE  __subtree_last
+#define ITSTART(n) ((n)->start)
+#define ITLAST(n)  ((n)->last)
+#define ITSTATIC
+#define ITPREFIX   interval_tree
+
+#include <linux/interval_tree_tmpl.h>
diff --git a/lib/prio_tree.c b/lib/prio_tree.c
index 4e0d2ed..bba3714 100644
--- a/lib/prio_tree.c
+++ b/lib/prio_tree.c
@@ -44,27 +44,12 @@
  * The following macros are used for implementing prio_tree for i_mmap
  */
 
-#define RADIX_INDEX(vma)  ((vma)->vm_pgoff)
-#define VMA_SIZE(vma)	  (((vma)->vm_end - (vma)->vm_start) >> PAGE_SHIFT)
-/* avoid overflow */
-#define HEAP_INDEX(vma)	  ((vma)->vm_pgoff + (VMA_SIZE(vma) - 1))
-
-
 static void get_index(const struct prio_tree_root *root,
     const struct prio_tree_node *node,
     unsigned long *radix, unsigned long *heap)
 {
-	if (root->raw) {
-		struct vm_area_struct *vma = prio_tree_entry(
-		    node, struct vm_area_struct, shared.prio_tree_node);
-
-		*radix = RADIX_INDEX(vma);
-		*heap = HEAP_INDEX(vma);
-	}
-	else {
-		*radix = node->start;
-		*heap = node->last;
-	}
+	*radix = node->start;
+	*heap = node->last;
 }
 
 static unsigned long index_bits_to_maxindex[BITS_PER_LONG];
diff --git a/mm/Makefile b/mm/Makefile
index 2e2fbbe..fd9cc64 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -14,9 +14,9 @@ endif
 obj-y			:= filemap.o mempool.o oom_kill.o fadvise.o \
 			   maccess.o page_alloc.o page-writeback.o \
 			   readahead.o swap.o truncate.o vmscan.o shmem.o \
-			   prio_tree.o util.o mmzone.o vmstat.o backing-dev.o \
+			   util.o mmzone.o vmstat.o backing-dev.o \
 			   page_isolation.o mm_init.o mmu_context.o percpu.o \
-			   compaction.o $(mmu-y)
+			   compaction.o interval_tree.o $(mmu-y)
 obj-y += init-mm.o
 
 ifdef CONFIG_NO_BOOTMEM
diff --git a/mm/filemap_xip.c b/mm/filemap_xip.c
index 213ca1f..c126d3e 100644
--- a/mm/filemap_xip.c
+++ b/mm/filemap_xip.c
@@ -167,7 +167,6 @@ __xip_unmap (struct address_space * mapping,
 {
 	struct vm_area_struct *vma;
 	struct mm_struct *mm;
-	struct prio_tree_iter iter;
 	unsigned long address;
 	pte_t *pte;
 	pte_t pteval;
@@ -184,7 +183,7 @@ __xip_unmap (struct address_space * mapping,
 
 retry:
 	mutex_lock(&mapping->i_mmap_mutex);
-	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
+	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
 		mm = vma->vm_mm;
 		address = vma->vm_start +
 			((pgoff - vma->vm_pgoff) << PAGE_SHIFT);
diff --git a/mm/fremap.c b/mm/fremap.c
index 9ed4fd4..2e582fe 100644
--- a/mm/fremap.c
+++ b/mm/fremap.c
@@ -213,7 +213,7 @@ SYSCALL_DEFINE5(remap_file_pages, unsigned long, start, unsigned long, size,
 		mutex_lock(&mapping->i_mmap_mutex);
 		flush_dcache_mmap_lock(mapping);
 		vma->vm_flags |= VM_NONLINEAR;
-		vma_prio_tree_remove(vma, &mapping->i_mmap);
+		vma_interval_tree_remove(vma, &mapping->i_mmap);
 		vma_nonlinear_insert(vma, &mapping->i_mmap_nonlinear);
 		flush_dcache_mmap_unlock(mapping);
 		mutex_unlock(&mapping->i_mmap_mutex);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index e198831..ec50883 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2408,7 +2408,6 @@ static int unmap_ref_private(struct mm_struct *mm, struct vm_area_struct *vma,
 	struct hstate *h = hstate_vma(vma);
 	struct vm_area_struct *iter_vma;
 	struct address_space *mapping;
-	struct prio_tree_iter iter;
 	pgoff_t pgoff;
 
 	/*
@@ -2425,7 +2424,7 @@ static int unmap_ref_private(struct mm_struct *mm, struct vm_area_struct *vma,
 	 * __unmap_hugepage_range() is called as the lock is already held
 	 */
 	mutex_lock(&mapping->i_mmap_mutex);
-	vma_prio_tree_foreach(iter_vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
+	vma_interval_tree_foreach(iter_vma, &mapping->i_mmap, pgoff, pgoff) {
 		/* Do not unmap the current VMA */
 		if (iter_vma == vma)
 			continue;
diff --git a/mm/interval_tree.c b/mm/interval_tree.c
new file mode 100644
index 0000000..7dc56566
--- /dev/null
+++ b/mm/interval_tree.c
@@ -0,0 +1,61 @@
+/*
+ * mm/interval_tree.c - interval tree for mapping->i_mmap
+ *
+ * Copyright (C) 2012, Michel Lespinasse <walken@google.com>
+ *
+ * This file is released under the GPL v2.
+ */
+
+#include <linux/mm.h>
+#include <linux/fs.h>
+
+#define ITSTRUCT   struct vm_area_struct
+#define ITRB       shared.linear.rb
+#define ITTYPE     unsigned long
+#define ITSUBTREE  shared.linear.rb_subtree_last
+#define ITSTART(n) ((n)->vm_pgoff)
+#define ITLAST(n)  ((n)->vm_pgoff + \
+		    (((n)->vm_end - (n)->vm_start) >> PAGE_SHIFT) - 1)
+#define ITSTATIC
+#define ITPREFIX   vma_interval_tree
+
+#include <linux/interval_tree_tmpl.h>
+
+/* Insert old immediately after vma in the interval tree */
+void vma_interval_tree_add(struct vm_area_struct *vma,
+			   struct vm_area_struct *old,
+			   struct address_space *mapping)
+{
+	struct rb_node **link;
+	struct vm_area_struct *parent;
+	unsigned long last;
+
+	if (unlikely(vma->vm_flags & VM_NONLINEAR)) {
+		list_add(&vma->shared.nonlinear, &old->shared.nonlinear);
+		return;
+	}
+
+	last = ITLAST(vma);
+
+	if (!old->shared.linear.rb.rb_right) {
+		parent = old;
+		link = &old->shared.linear.rb.rb_right;
+	} else {
+		parent = rb_entry(old->shared.linear.rb.rb_right,
+				  struct vm_area_struct, shared.linear.rb);
+		if (parent->shared.linear.rb_subtree_last < last)
+			parent->shared.linear.rb_subtree_last = last;
+		while (parent->shared.linear.rb.rb_left) {
+			parent = rb_entry(parent->shared.linear.rb.rb_left,
+				struct vm_area_struct, shared.linear.rb);
+			if (parent->shared.linear.rb_subtree_last < last)
+				parent->shared.linear.rb_subtree_last = last;
+		}
+		link = &parent->shared.linear.rb.rb_left;
+	}
+
+	vma->shared.linear.rb_subtree_last = last;
+	rb_link_node(&vma->shared.linear.rb, &parent->shared.linear.rb, link);
+	rb_insert_augmented(&vma->shared.linear.rb, &mapping->i_mmap,
+			    &vma_interval_tree_augment_callbacks);
+}
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index ab1e714..65d5e8d 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -431,7 +431,6 @@ static void collect_procs_file(struct page *page, struct list_head *to_kill,
 {
 	struct vm_area_struct *vma;
 	struct task_struct *tsk;
-	struct prio_tree_iter iter;
 	struct address_space *mapping = page->mapping;
 
 	mutex_lock(&mapping->i_mmap_mutex);
@@ -442,7 +441,7 @@ static void collect_procs_file(struct page *page, struct list_head *to_kill,
 		if (!task_early_kill(tsk))
 			continue;
 
-		vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff,
+		vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff,
 				      pgoff) {
 			/*
 			 * Send early kill signal to tasks where a vma covers
diff --git a/mm/memory.c b/mm/memory.c
index 2466d12..51dd129 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2790,14 +2790,13 @@ static void unmap_mapping_range_vma(struct vm_area_struct *vma,
 	zap_page_range_single(vma, start_addr, end_addr - start_addr, details);
 }
 
-static inline void unmap_mapping_range_tree(struct prio_tree_root *root,
+static inline void unmap_mapping_range_tree(struct rb_root *root,
 					    struct zap_details *details)
 {
 	struct vm_area_struct *vma;
-	struct prio_tree_iter iter;
 	pgoff_t vba, vea, zba, zea;
 
-	vma_prio_tree_foreach(vma, &iter, root,
+	vma_interval_tree_foreach(vma, root,
 			details->first_index, details->last_index) {
 
 		vba = vma->vm_pgoff;
@@ -2828,7 +2827,7 @@ static inline void unmap_mapping_range_list(struct list_head *head,
 	 * across *all* the pages in each nonlinear VMA, not just the pages
 	 * whose virtual address lies outside the file truncation point.
 	 */
-	list_for_each_entry(vma, head, shared.vm_set.list) {
+	list_for_each_entry(vma, head, shared.nonlinear) {
 		details->nonlinear_vma = vma;
 		unmap_mapping_range_vma(vma, vma->vm_start, vma->vm_end, details);
 	}
@@ -2872,7 +2871,7 @@ void unmap_mapping_range(struct address_space *mapping,
 
 
 	mutex_lock(&mapping->i_mmap_mutex);
-	if (unlikely(!prio_tree_empty(&mapping->i_mmap)))
+	if (unlikely(!RB_EMPTY_ROOT(&mapping->i_mmap)))
 		unmap_mapping_range_tree(&mapping->i_mmap, &details);
 	if (unlikely(!list_empty(&mapping->i_mmap_nonlinear)))
 		unmap_mapping_range_list(&mapping->i_mmap_nonlinear, &details);
diff --git a/mm/mmap.c b/mm/mmap.c
index 3edfcdf..cebc346 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -199,14 +199,14 @@ static void __remove_shared_vm_struct(struct vm_area_struct *vma,
 
 	flush_dcache_mmap_lock(mapping);
 	if (unlikely(vma->vm_flags & VM_NONLINEAR))
-		list_del_init(&vma->shared.vm_set.list);
+		list_del_init(&vma->shared.nonlinear);
 	else
-		vma_prio_tree_remove(vma, &mapping->i_mmap);
+		vma_interval_tree_remove(vma, &mapping->i_mmap);
 	flush_dcache_mmap_unlock(mapping);
 }
 
 /*
- * Unlink a file-based vm structure from its prio_tree, to hide
+ * Unlink a file-based vm structure from its interval tree, to hide
  * vma from rmap and vmtruncate before freeing its page tables.
  */
 void unlink_file_vma(struct vm_area_struct *vma)
@@ -417,7 +417,7 @@ static void __vma_link_file(struct vm_area_struct *vma)
 		if (unlikely(vma->vm_flags & VM_NONLINEAR))
 			vma_nonlinear_insert(vma, &mapping->i_mmap_nonlinear);
 		else
-			vma_prio_tree_insert(vma, &mapping->i_mmap);
+			vma_interval_tree_insert(vma, &mapping->i_mmap);
 		flush_dcache_mmap_unlock(mapping);
 	}
 }
@@ -455,7 +455,7 @@ static void vma_link(struct mm_struct *mm, struct vm_area_struct *vma,
 
 /*
  * Helper for vma_adjust() in the split_vma insert case: insert a vma into the
- * mm's list and rbtree.  It has already been inserted into the prio_tree.
+ * mm's list and rbtree.  It has already been inserted into the interval tree.
  */
 static void __insert_vm_struct(struct mm_struct *mm, struct vm_area_struct *vma)
 {
@@ -496,7 +496,7 @@ int vma_adjust(struct vm_area_struct *vma, unsigned long start,
 	struct vm_area_struct *next = vma->vm_next;
 	struct vm_area_struct *importer = NULL;
 	struct address_space *mapping = NULL;
-	struct prio_tree_root *root = NULL;
+	struct rb_root *root = NULL;
 	struct anon_vma *anon_vma = NULL;
 	struct file *file = vma->vm_file;
 	long adjust_next = 0;
@@ -559,7 +559,7 @@ again:			remove_next = 1 + (end > next->vm_end);
 		mutex_lock(&mapping->i_mmap_mutex);
 		if (insert) {
 			/*
-			 * Put into prio_tree now, so instantiated pages
+			 * Put into interval tree now, so instantiated pages
 			 * are visible to arm/parisc __flush_dcache_page
 			 * throughout; but we cannot insert into address
 			 * space until vma start or end is updated.
@@ -583,9 +583,9 @@ again:			remove_next = 1 + (end > next->vm_end);
 
 	if (root) {
 		flush_dcache_mmap_lock(mapping);
-		vma_prio_tree_remove(vma, root);
+		vma_interval_tree_remove(vma, root);
 		if (adjust_next)
-			vma_prio_tree_remove(next, root);
+			vma_interval_tree_remove(next, root);
 	}
 
 	vma->vm_start = start;
@@ -598,8 +598,8 @@ again:			remove_next = 1 + (end > next->vm_end);
 
 	if (root) {
 		if (adjust_next)
-			vma_prio_tree_insert(next, root);
-		vma_prio_tree_insert(vma, root);
+			vma_interval_tree_insert(next, root);
+		vma_interval_tree_insert(vma, root);
 		flush_dcache_mmap_unlock(mapping);
 	}
 
diff --git a/mm/nommu.c b/mm/nommu.c
index d4b0c10..935de1a 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -698,7 +698,7 @@ static void add_vma_to_mm(struct mm_struct *mm, struct vm_area_struct *vma)
 
 		mutex_lock(&mapping->i_mmap_mutex);
 		flush_dcache_mmap_lock(mapping);
-		vma_prio_tree_insert(vma, &mapping->i_mmap);
+		vma_interval_tree_insert(vma, &mapping->i_mmap);
 		flush_dcache_mmap_unlock(mapping);
 		mutex_unlock(&mapping->i_mmap_mutex);
 	}
@@ -764,7 +764,7 @@ static void delete_vma_from_mm(struct vm_area_struct *vma)
 
 		mutex_lock(&mapping->i_mmap_mutex);
 		flush_dcache_mmap_lock(mapping);
-		vma_prio_tree_remove(vma, &mapping->i_mmap);
+		vma_interval_tree_remove(vma, &mapping->i_mmap);
 		flush_dcache_mmap_unlock(mapping);
 		mutex_unlock(&mapping->i_mmap_mutex);
 	}
@@ -2047,7 +2047,6 @@ int nommu_shrink_inode_mappings(struct inode *inode, size_t size,
 				size_t newsize)
 {
 	struct vm_area_struct *vma;
-	struct prio_tree_iter iter;
 	struct vm_region *region;
 	pgoff_t low, high;
 	size_t r_size, r_top;
@@ -2059,8 +2058,7 @@ int nommu_shrink_inode_mappings(struct inode *inode, size_t size,
 	mutex_lock(&inode->i_mapping->i_mmap_mutex);
 
 	/* search for VMAs that fall within the dead zone */
-	vma_prio_tree_foreach(vma, &iter, &inode->i_mapping->i_mmap,
-			      low, high) {
+	vma_interval_tree_foreach(vma, &inode->i_mapping->i_mmap, low, high) {
 		/* found one - only interested if it's shared out of the page
 		 * cache */
 		if (vma->vm_flags & VM_SHARED) {
@@ -2076,8 +2074,8 @@ int nommu_shrink_inode_mappings(struct inode *inode, size_t size,
 	 * we don't check for any regions that start beyond the EOF as there
 	 * shouldn't be any
 	 */
-	vma_prio_tree_foreach(vma, &iter, &inode->i_mapping->i_mmap,
-			      0, ULONG_MAX) {
+	vma_interval_tree_foreach(vma, &inode->i_mapping->i_mmap,
+				  0, ULONG_MAX) {
 		if (!(vma->vm_flags & VM_SHARED))
 			continue;
 
diff --git a/mm/prio_tree.c b/mm/prio_tree.c
deleted file mode 100644
index 799dcfd..0000000
--- a/mm/prio_tree.c
+++ /dev/null
@@ -1,208 +0,0 @@
-/*
- * mm/prio_tree.c - priority search tree for mapping->i_mmap
- *
- * Copyright (C) 2004, Rajesh Venkatasubramanian <vrajesh@umich.edu>
- *
- * This file is released under the GPL v2.
- *
- * Based on the radix priority search tree proposed by Edward M. McCreight
- * SIAM Journal of Computing, vol. 14, no.2, pages 257-276, May 1985
- *
- * 02Feb2004	Initial version
- */
-
-#include <linux/mm.h>
-#include <linux/prio_tree.h>
-#include <linux/prefetch.h>
-
-/*
- * See lib/prio_tree.c for details on the general radix priority search tree
- * code.
- */
-
-/*
- * The following #defines are mirrored from lib/prio_tree.c. They're only used
- * for debugging, and should be removed (along with the debugging code using
- * them) when switching also VMAs to the regular prio_tree code.
- */
-
-#define RADIX_INDEX(vma)  ((vma)->vm_pgoff)
-#define VMA_SIZE(vma)	  (((vma)->vm_end - (vma)->vm_start) >> PAGE_SHIFT)
-/* avoid overflow */
-#define HEAP_INDEX(vma)   ((vma)->vm_pgoff + (VMA_SIZE(vma) - 1))
-
-/*
- * Radix priority search tree for address_space->i_mmap
- *
- * For each vma that map a unique set of file pages i.e., unique [radix_index,
- * heap_index] value, we have a corresponding priority search tree node. If
- * multiple vmas have identical [radix_index, heap_index] value, then one of
- * them is used as a tree node and others are stored in a vm_set list. The tree
- * node points to the first vma (head) of the list using vm_set.head.
- *
- * prio_tree_root
- *      |
- *      A       vm_set.head
- *     / \      /
- *    L   R -> H-I-J-K-M-N-O-P-Q-S
- *    ^   ^    <-- vm_set.list -->
- *  tree nodes
- *
- * We need some way to identify whether a vma is a tree node, head of a vm_set
- * list, or just a member of a vm_set list. We cannot use vm_flags to store
- * such information. The reason is, in the above figure, it is possible that
- * vm_flags' of R and H are covered by the different mmap_sems. When R is
- * removed under R->mmap_sem, H replaces R as a tree node. Since we do not hold
- * H->mmap_sem, we cannot use H->vm_flags for marking that H is a tree node now.
- * That's why some trick involving shared.vm_set.parent is used for identifying
- * tree nodes and list head nodes.
- *
- * vma radix priority search tree node rules:
- *
- * vma->shared.vm_set.parent != NULL    ==> a tree node
- *      vma->shared.vm_set.head != NULL ==> list of others mapping same range
- *      vma->shared.vm_set.head == NULL ==> no others map the same range
- *
- * vma->shared.vm_set.parent == NULL
- * 	vma->shared.vm_set.head != NULL ==> list head of vmas mapping same range
- * 	vma->shared.vm_set.head == NULL ==> a list node
- */
-
-/*
- * Add a new vma known to map the same set of pages as the old vma:
- * useful for fork's dup_mmap as well as vma_prio_tree_insert below.
- * Note that it just happens to work correctly on i_mmap_nonlinear too.
- */
-void vma_prio_tree_add(struct vm_area_struct *vma, struct vm_area_struct *old)
-{
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
-	else {
-		INIT_LIST_HEAD(&vma->shared.vm_set.list);
-		vma->shared.vm_set.head = old;
-		old->shared.vm_set.head = vma;
-	}
-}
-
-void vma_prio_tree_insert(struct vm_area_struct *vma,
-			  struct prio_tree_root *root)
-{
-	struct prio_tree_node *ptr;
-	struct vm_area_struct *old;
-
-	vma->shared.vm_set.head = NULL;
-
-	ptr = raw_prio_tree_insert(root, &vma->shared.prio_tree_node);
-	if (ptr != (struct prio_tree_node *) &vma->shared.prio_tree_node) {
-		old = prio_tree_entry(ptr, struct vm_area_struct,
-					shared.prio_tree_node);
-		vma_prio_tree_add(vma, old);
-	}
-}
-
-void vma_prio_tree_remove(struct vm_area_struct *vma,
-			  struct prio_tree_root *root)
-{
-	struct vm_area_struct *node, *head, *new_head;
-
-	if (!vma->shared.vm_set.head) {
-		if (!vma->shared.vm_set.parent)
-			list_del_init(&vma->shared.vm_set.list);
-		else
-			raw_prio_tree_remove(root, &vma->shared.prio_tree_node);
-	} else {
-		/* Leave this BUG_ON till prio_tree patch stabilizes */
-		BUG_ON(vma->shared.vm_set.head->shared.vm_set.head != vma);
-		if (vma->shared.vm_set.parent) {
-			head = vma->shared.vm_set.head;
-			if (!list_empty(&head->shared.vm_set.list)) {
-				new_head = list_entry(
-					head->shared.vm_set.list.next,
-					struct vm_area_struct,
-					shared.vm_set.list);
-				list_del_init(&head->shared.vm_set.list);
-			} else
-				new_head = NULL;
-
-			raw_prio_tree_replace(root, &vma->shared.prio_tree_node,
-					&head->shared.prio_tree_node);
-			head->shared.vm_set.head = new_head;
-			if (new_head)
-				new_head->shared.vm_set.head = head;
-
-		} else {
-			node = vma->shared.vm_set.head;
-			if (!list_empty(&vma->shared.vm_set.list)) {
-				new_head = list_entry(
-					vma->shared.vm_set.list.next,
-					struct vm_area_struct,
-					shared.vm_set.list);
-				list_del_init(&vma->shared.vm_set.list);
-				node->shared.vm_set.head = new_head;
-				new_head->shared.vm_set.head = node;
-			} else
-				node->shared.vm_set.head = NULL;
-		}
-	}
-}
-
-/*
- * Helper function to enumerate vmas that map a given file page or a set of
- * contiguous file pages. The function returns vmas that at least map a single
- * page in the given range of contiguous file pages.
- */
-struct vm_area_struct *vma_prio_tree_next(struct vm_area_struct *vma,
-					struct prio_tree_iter *iter)
-{
-	struct prio_tree_node *ptr;
-	struct vm_area_struct *next;
-
-	if (!vma) {
-		/*
-		 * First call is with NULL vma
-		 */
-		ptr = prio_tree_next(iter);
-		if (ptr) {
-			next = prio_tree_entry(ptr, struct vm_area_struct,
-						shared.prio_tree_node);
-			prefetch(next->shared.vm_set.head);
-			return next;
-		} else
-			return NULL;
-	}
-
-	if (vma->shared.vm_set.parent) {
-		if (vma->shared.vm_set.head) {
-			next = vma->shared.vm_set.head;
-			prefetch(next->shared.vm_set.list.next);
-			return next;
-		}
-	} else {
-		next = list_entry(vma->shared.vm_set.list.next,
-				struct vm_area_struct, shared.vm_set.list);
-		if (!next->shared.vm_set.head) {
-			prefetch(next->shared.vm_set.list.next);
-			return next;
-		}
-	}
-
-	ptr = prio_tree_next(iter);
-	if (ptr) {
-		next = prio_tree_entry(ptr, struct vm_area_struct,
-					shared.prio_tree_node);
-		prefetch(next->shared.vm_set.head);
-		return next;
-	} else
-		return NULL;
-}
diff --git a/mm/rmap.c b/mm/rmap.c
index 0f3b7cd..7b5b51d 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -820,7 +820,6 @@ static int page_referenced_file(struct page *page,
 	struct address_space *mapping = page->mapping;
 	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
 	struct vm_area_struct *vma;
-	struct prio_tree_iter iter;
 	int referenced = 0;
 
 	/*
@@ -846,7 +845,7 @@ static int page_referenced_file(struct page *page,
 	 */
 	mapcount = page_mapcount(page);
 
-	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
+	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
 		unsigned long address = vma_address(page, vma);
 		if (address == -EFAULT)
 			continue;
@@ -945,13 +944,12 @@ static int page_mkclean_file(struct address_space *mapping, struct page *page)
 {
 	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
 	struct vm_area_struct *vma;
-	struct prio_tree_iter iter;
 	int ret = 0;
 
 	BUG_ON(PageAnon(page));
 
 	mutex_lock(&mapping->i_mmap_mutex);
-	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
+	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
 		if (vma->vm_flags & VM_SHARED) {
 			unsigned long address = vma_address(page, vma);
 			if (address == -EFAULT)
@@ -1547,7 +1545,6 @@ static int try_to_unmap_file(struct page *page, enum ttu_flags flags)
 	struct address_space *mapping = page->mapping;
 	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
 	struct vm_area_struct *vma;
-	struct prio_tree_iter iter;
 	int ret = SWAP_AGAIN;
 	unsigned long cursor;
 	unsigned long max_nl_cursor = 0;
@@ -1555,7 +1552,7 @@ static int try_to_unmap_file(struct page *page, enum ttu_flags flags)
 	unsigned int mapcount;
 
 	mutex_lock(&mapping->i_mmap_mutex);
-	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
+	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
 		unsigned long address = vma_address(page, vma);
 		if (address == -EFAULT)
 			continue;
@@ -1576,7 +1573,7 @@ static int try_to_unmap_file(struct page *page, enum ttu_flags flags)
 		goto out;
 
 	list_for_each_entry(vma, &mapping->i_mmap_nonlinear,
-						shared.vm_set.list) {
+							shared.nonlinear) {
 		cursor = (unsigned long) vma->vm_private_data;
 		if (cursor > max_nl_cursor)
 			max_nl_cursor = cursor;
@@ -1608,7 +1605,7 @@ static int try_to_unmap_file(struct page *page, enum ttu_flags flags)
 
 	do {
 		list_for_each_entry(vma, &mapping->i_mmap_nonlinear,
-						shared.vm_set.list) {
+							shared.nonlinear) {
 			cursor = (unsigned long) vma->vm_private_data;
 			while ( cursor < max_nl_cursor &&
 				cursor < vma->vm_end - vma->vm_start) {
@@ -1631,7 +1628,7 @@ static int try_to_unmap_file(struct page *page, enum ttu_flags flags)
 	 * in locked vmas).  Reset cursor on all unreserved nonlinear
 	 * vmas, now forgetting on which ones it had fallen behind.
 	 */
-	list_for_each_entry(vma, &mapping->i_mmap_nonlinear, shared.vm_set.list)
+	list_for_each_entry(vma, &mapping->i_mmap_nonlinear, shared.nonlinear)
 		vma->vm_private_data = NULL;
 out:
 	mutex_unlock(&mapping->i_mmap_mutex);
@@ -1748,13 +1745,12 @@ static int rmap_walk_file(struct page *page, int (*rmap_one)(struct page *,
 	struct address_space *mapping = page->mapping;
 	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
 	struct vm_area_struct *vma;
-	struct prio_tree_iter iter;
 	int ret = SWAP_AGAIN;
 
 	if (!mapping)
 		return ret;
 	mutex_lock(&mapping->i_mmap_mutex);
-	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
+	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
 		unsigned long address = vma_address(page, vma);
 		if (address == -EFAULT)
 			continue;
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
