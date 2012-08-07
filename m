Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 1454B6B0072
	for <linux-mm@kvack.org>; Tue,  7 Aug 2012 03:26:06 -0400 (EDT)
Received: by ghrr18 with SMTP id r18so1675012ghr.14
        for <linux-mm@kvack.org>; Tue, 07 Aug 2012 00:26:05 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 4/5] prio_tree: remove
Date: Tue,  7 Aug 2012 00:25:42 -0700
Message-Id: <1344324343-3817-5-git-send-email-walken@google.com>
In-Reply-To: <1344324343-3817-1-git-send-email-walken@google.com>
References: <1344324343-3817-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: riel@redhat.com, peterz@infradead.org, vrajesh@umich.edu, daniel.santos@pobox.com, aarcange@redhat.com, dwmw2@infradead.org, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

After both prio_tree users have been converted to use red-black trees,
there is no need to keep around the prio tree library anymore.

Signed-off-by: Michel Lespinasse <walken@google.com>
---
 Documentation/00-INDEX      |    2 -
 Documentation/prio_tree.txt |  107 ----------
 include/linux/prio_tree.h   |  120 ------------
 init/main.c                 |    2 -
 lib/Kconfig.debug           |    6 -
 lib/Makefile                |    3 +-
 lib/prio_tree.c             |  455 -------------------------------------------
 lib/prio_tree_test.c        |  106 ----------
 8 files changed, 1 insertions(+), 800 deletions(-)
 delete mode 100644 Documentation/prio_tree.txt
 delete mode 100644 include/linux/prio_tree.h
 delete mode 100644 lib/prio_tree.c
 delete mode 100644 lib/prio_tree_test.c

diff --git a/Documentation/00-INDEX b/Documentation/00-INDEX
index 49c0513..f54273e 100644
--- a/Documentation/00-INDEX
+++ b/Documentation/00-INDEX
@@ -270,8 +270,6 @@ preempt-locking.txt
 	- info on locking under a preemptive kernel.
 printk-formats.txt
 	- how to get printk format specifiers right
-prio_tree.txt
-	- info on radix-priority-search-tree use for indexing vmas.
 ramoops.txt
 	- documentation of the ramoops oops/panic logging module.
 rbtree.txt
diff --git a/Documentation/prio_tree.txt b/Documentation/prio_tree.txt
deleted file mode 100644
index 3aa68f9..0000000
--- a/Documentation/prio_tree.txt
+++ /dev/null
@@ -1,107 +0,0 @@
-The prio_tree.c code indexes vmas using 3 different indexes:
-	* heap_index  = vm_pgoff + vm_size_in_pages : end_vm_pgoff
-	* radix_index = vm_pgoff : start_vm_pgoff
-	* size_index = vm_size_in_pages
-
-A regular radix-priority-search-tree indexes vmas using only heap_index and
-radix_index. The conditions for indexing are:
-	* ->heap_index >= ->left->heap_index &&
-		->heap_index >= ->right->heap_index
-	* if (->heap_index == ->left->heap_index)
-		then ->radix_index < ->left->radix_index;
-	* if (->heap_index == ->right->heap_index)
-		then ->radix_index < ->right->radix_index;
-	* nodes are hashed to left or right subtree using radix_index
-	  similar to a pure binary radix tree.
-
-A regular radix-priority-search-tree helps to store and query
-intervals (vmas). However, a regular radix-priority-search-tree is only
-suitable for storing vmas with different radix indices (vm_pgoff).
-
-Therefore, the prio_tree.c extends the regular radix-priority-search-tree
-to handle many vmas with the same vm_pgoff. Such vmas are handled in
-2 different ways: 1) All vmas with the same radix _and_ heap indices are
-linked using vm_set.list, 2) if there are many vmas with the same radix
-index, but different heap indices and if the regular radix-priority-search
-tree cannot index them all, we build an overflow-sub-tree that indexes such
-vmas using heap and size indices instead of heap and radix indices. For
-example, in the figure below some vmas with vm_pgoff = 0 (zero) are
-indexed by regular radix-priority-search-tree whereas others are pushed
-into an overflow-subtree. Note that all vmas in an overflow-sub-tree have
-the same vm_pgoff (radix_index) and if necessary we build different
-overflow-sub-trees to handle each possible radix_index. For example,
-in figure we have 3 overflow-sub-trees corresponding to radix indices
-0, 2, and 4.
-
-In the final tree the first few (prio_tree_root->index_bits) levels
-are indexed using heap and radix indices whereas the overflow-sub-trees below
-those levels (i.e. levels prio_tree_root->index_bits + 1 and higher) are
-indexed using heap and size indices. In overflow-sub-trees the size_index
-is used for hashing the nodes to appropriate places.
-
-Now, an example prio_tree:
-
-  vmas are represented [radix_index, size_index, heap_index]
-                 i.e., [start_vm_pgoff, vm_size_in_pages, end_vm_pgoff]
-
-level  prio_tree_root->index_bits = 3
------
-												_
-  0			 				[0,7,7]					 |
-  							/     \					 |
-				      ------------------       ------------			 |     Regular
-  				     /					   \			 |  radix priority
-  1		 		[1,6,7]					  [4,3,7]		 |   search tree
-  				/     \					  /     \		 |
-			 -------       -----			    ------       -----		 |  heap-and-radix
-			/		    \			   /		      \		 |      indexed
-  2		    [0,6,6]	 	   [2,5,7]		[5,2,7]		    [6,1,7]	 |
-		    /     \		   /     \		/     \		    /     \	 |
-  3		[0,5,5]	[1,5,6]		[2,4,6]	[3,4,7]	    [4,2,6] [5,1,6]	[6,0,6]	[7,0,7]	 |
-		   /			   /		       /		   		_
-                  /		          /		      /					_
-  4	      [0,4,4]		      [2,3,5]		   [4,1,5]				 |
-  		 /			 /		      /					 |
-  5	     [0,3,3]		     [2,2,4]		  [4,0,4]				 |  Overflow-sub-trees
-  		/			/							 |
-  6	    [0,2,2]		    [2,1,3]							 |    heap-and-size
-  	       /		       /							 |       indexed
-  7	   [0,1,1]		   [2,0,2]							 |
-  	      /											 |
-  8	  [0,0,0]										 |
-  												_
-
-Note that we use prio_tree_root->index_bits to optimize the height
-of the heap-and-radix indexed tree. Since prio_tree_root->index_bits is
-set according to the maximum end_vm_pgoff mapped, we are sure that all
-bits (in vm_pgoff) above prio_tree_root->index_bits are 0 (zero). Therefore,
-we only use the first prio_tree_root->index_bits as radix_index.
-Whenever index_bits is increased in prio_tree_expand, we shuffle the tree
-to make sure that the first prio_tree_root->index_bits levels of the tree
-is indexed properly using heap and radix indices.
-
-We do not optimize the height of overflow-sub-trees using index_bits.
-The reason is: there can be many such overflow-sub-trees and all of
-them have to be suffled whenever the index_bits increases. This may involve
-walking the whole prio_tree in prio_tree_insert->prio_tree_expand code
-path which is not desirable. Hence, we do not optimize the height of the
-heap-and-size indexed overflow-sub-trees using prio_tree->index_bits.
-Instead the overflow sub-trees are indexed using full BITS_PER_LONG bits
-of size_index. This may lead to skewed sub-trees because most of the
-higher significant bits of the size_index are likely to be 0 (zero). In
-the example above, all 3 overflow-sub-trees are skewed. This may marginally
-affect the performance. However, processes rarely map many vmas with the
-same start_vm_pgoff but different end_vm_pgoffs. Therefore, we normally
-do not require overflow-sub-trees to index all vmas.
-
-From the above discussion it is clear that the maximum height of
-a prio_tree can be prio_tree_root->index_bits + BITS_PER_LONG.
-However, in most of the common cases we do not need overflow-sub-trees,
-so the tree height in the common cases will be prio_tree_root->index_bits.
-
-It is fair to mention here that the prio_tree_root->index_bits
-is increased on demand, however, the index_bits is not decreased when
-vmas are removed from the prio_tree. That's tricky to do. Hence, it's
-left as a home work problem.
-
-
diff --git a/include/linux/prio_tree.h b/include/linux/prio_tree.h
deleted file mode 100644
index db04abb..0000000
--- a/include/linux/prio_tree.h
+++ /dev/null
@@ -1,120 +0,0 @@
-#ifndef _LINUX_PRIO_TREE_H
-#define _LINUX_PRIO_TREE_H
-
-/*
- * K&R 2nd ed. A8.3 somewhat obliquely hints that initial sequences of struct
- * fields with identical types should end up at the same location. We'll use
- * this until we can scrap struct raw_prio_tree_node.
- *
- * Note: all this could be done more elegantly by using unnamed union/struct
- * fields. However, gcc 2.95.3 and apparently also gcc 3.0.4 don't support this
- * language extension.
- */
-
-struct raw_prio_tree_node {
-	struct prio_tree_node	*left;
-	struct prio_tree_node	*right;
-	struct prio_tree_node	*parent;
-};
-
-struct prio_tree_node {
-	struct prio_tree_node	*left;
-	struct prio_tree_node	*right;
-	struct prio_tree_node	*parent;
-	unsigned long		start;
-	unsigned long		last;	/* last location _in_ interval */
-};
-
-struct prio_tree_root {
-	struct prio_tree_node	*prio_tree_node;
-	unsigned short 		index_bits;
-	unsigned short		raw;
-		/*
-		 * 0: nodes are of type struct prio_tree_node
-		 * 1: nodes are of type raw_prio_tree_node
-		 */
-};
-
-struct prio_tree_iter {
-	struct prio_tree_node	*cur;
-	unsigned long		mask;
-	unsigned long		value;
-	int			size_level;
-
-	struct prio_tree_root	*root;
-	pgoff_t			r_index;
-	pgoff_t			h_index;
-};
-
-static inline void prio_tree_iter_init(struct prio_tree_iter *iter,
-		struct prio_tree_root *root, pgoff_t r_index, pgoff_t h_index)
-{
-	iter->root = root;
-	iter->r_index = r_index;
-	iter->h_index = h_index;
-	iter->cur = NULL;
-}
-
-#define __INIT_PRIO_TREE_ROOT(ptr, _raw)	\
-do {					\
-	(ptr)->prio_tree_node = NULL;	\
-	(ptr)->index_bits = 1;		\
-	(ptr)->raw = (_raw);		\
-} while (0)
-
-#define INIT_PRIO_TREE_ROOT(ptr)	__INIT_PRIO_TREE_ROOT(ptr, 0)
-#define INIT_RAW_PRIO_TREE_ROOT(ptr)	__INIT_PRIO_TREE_ROOT(ptr, 1)
-
-#define INIT_PRIO_TREE_NODE(ptr)				\
-do {								\
-	(ptr)->left = (ptr)->right = (ptr)->parent = (ptr);	\
-} while (0)
-
-#define INIT_PRIO_TREE_ITER(ptr)	\
-do {					\
-	(ptr)->cur = NULL;		\
-	(ptr)->mask = 0UL;		\
-	(ptr)->value = 0UL;		\
-	(ptr)->size_level = 0;		\
-} while (0)
-
-#define prio_tree_entry(ptr, type, member) \
-       ((type *)((char *)(ptr)-(unsigned long)(&((type *)0)->member)))
-
-static inline int prio_tree_empty(const struct prio_tree_root *root)
-{
-	return root->prio_tree_node == NULL;
-}
-
-static inline int prio_tree_root(const struct prio_tree_node *node)
-{
-	return node->parent == node;
-}
-
-static inline int prio_tree_left_empty(const struct prio_tree_node *node)
-{
-	return node->left == node;
-}
-
-static inline int prio_tree_right_empty(const struct prio_tree_node *node)
-{
-	return node->right == node;
-}
-
-
-struct prio_tree_node *prio_tree_replace(struct prio_tree_root *root,
-                struct prio_tree_node *old, struct prio_tree_node *node);
-struct prio_tree_node *prio_tree_insert(struct prio_tree_root *root,
-                struct prio_tree_node *node);
-void prio_tree_remove(struct prio_tree_root *root, struct prio_tree_node *node);
-struct prio_tree_node *prio_tree_next(struct prio_tree_iter *iter);
-
-#define raw_prio_tree_replace(root, old, node) \
-	prio_tree_replace(root, (struct prio_tree_node *) (old), \
-	    (struct prio_tree_node *) (node))
-#define raw_prio_tree_insert(root, node) \
-	prio_tree_insert(root, (struct prio_tree_node *) (node))
-#define raw_prio_tree_remove(root, node) \
-	prio_tree_remove(root, (struct prio_tree_node *) (node))
-
-#endif /* _LINUX_PRIO_TREE_H */
diff --git a/init/main.c b/init/main.c
index b5cc0a7..04fad8c 100644
--- a/init/main.c
+++ b/init/main.c
@@ -85,7 +85,6 @@ extern void init_IRQ(void);
 extern void fork_init(unsigned long);
 extern void mca_init(void);
 extern void sbus_init(void);
-extern void prio_tree_init(void);
 extern void radix_tree_init(void);
 #ifndef CONFIG_DEBUG_RODATA
 static inline void mark_rodata_ro(void) { }
@@ -546,7 +545,6 @@ asmlinkage void __init start_kernel(void)
 	/* init some links before init_ISA_irqs() */
 	early_irq_init();
 	init_IRQ();
-	prio_tree_init();
 	init_timers();
 	hrtimers_init();
 	softirq_init();
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index 331c64d..eba4b09 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -1185,12 +1185,6 @@ config RBTREE_TEST
 	  A benchmark measuring the performance of the rbtree library.
 	  Also includes rbtree invariant checks.
 
-config PRIO_TREE_TEST
-	tristate "Prio tree test"
-	depends on m && DEBUG_KERNEL
-	help
-	  A benchmark measuring the performance of the prio tree library
-
 config INTERVAL_TREE_TEST
 	tristate "Interval tree test"
 	depends on m && DEBUG_KERNEL
diff --git a/lib/Makefile b/lib/Makefile
index e1f109f..eb0e62b 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -9,7 +9,7 @@ endif
 
 lib-y := ctype.o string.o vsprintf.o cmdline.o \
 	 rbtree.o radix-tree.o dump_stack.o timerqueue.o\
-	 idr.o int_sqrt.o extable.o prio_tree.o \
+	 idr.o int_sqrt.o extable.o \
 	 sha1.o md5.o irq_regs.o reciprocal_div.o argv_split.o \
 	 proportions.o prio_heap.o ratelimit.o show_mem.o \
 	 is_single_threaded.o plist.o decompress.o
@@ -131,7 +131,6 @@ obj-$(CONFIG_GENERIC_STRNLEN_USER) += strnlen_user.o
 obj-$(CONFIG_STMP_DEVICE) += stmp_device.o
 
 obj-$(CONFIG_RBTREE_TEST) += rbtree_test.o
-obj-$(CONFIG_PRIO_TREE_TEST) += prio_tree_test.o
 obj-$(CONFIG_INTERVAL_TREE_TEST) += interval_tree_test.o
 
 interval_tree_test-objs := interval_tree_test_main.o interval_tree.o
diff --git a/lib/prio_tree.c b/lib/prio_tree.c
deleted file mode 100644
index bba3714..0000000
--- a/lib/prio_tree.c
+++ /dev/null
@@ -1,455 +0,0 @@
-/*
- * lib/prio_tree.c - priority search tree
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
-#include <linux/init.h>
-#include <linux/mm.h>
-#include <linux/prio_tree.h>
-#include <linux/export.h>
-
-/*
- * A clever mix of heap and radix trees forms a radix priority search tree (PST)
- * which is useful for storing intervals, e.g, we can consider a vma as a closed
- * interval of file pages [offset_begin, offset_end], and store all vmas that
- * map a file in a PST. Then, using the PST, we can answer a stabbing query,
- * i.e., selecting a set of stored intervals (vmas) that overlap with (map) a
- * given input interval X (a set of consecutive file pages), in "O(log n + m)"
- * time where 'log n' is the height of the PST, and 'm' is the number of stored
- * intervals (vmas) that overlap (map) with the input interval X (the set of
- * consecutive file pages).
- *
- * In our implementation, we store closed intervals of the form [radix_index,
- * heap_index]. We assume that always radix_index <= heap_index. McCreight's PST
- * is designed for storing intervals with unique radix indices, i.e., each
- * interval have different radix_index. However, this limitation can be easily
- * overcome by using the size, i.e., heap_index - radix_index, as part of the
- * index, so we index the tree using [(radix_index,size), heap_index].
- *
- * When the above-mentioned indexing scheme is used, theoretically, in a 32 bit
- * machine, the maximum height of a PST can be 64. We can use a balanced version
- * of the priority search tree to optimize the tree height, but the balanced
- * tree proposed by McCreight is too complex and memory-hungry for our purpose.
- */
-
-/*
- * The following macros are used for implementing prio_tree for i_mmap
- */
-
-static void get_index(const struct prio_tree_root *root,
-    const struct prio_tree_node *node,
-    unsigned long *radix, unsigned long *heap)
-{
-	*radix = node->start;
-	*heap = node->last;
-}
-
-static unsigned long index_bits_to_maxindex[BITS_PER_LONG];
-
-void __init prio_tree_init(void)
-{
-	unsigned int i;
-
-	for (i = 0; i < ARRAY_SIZE(index_bits_to_maxindex) - 1; i++)
-		index_bits_to_maxindex[i] = (1UL << (i + 1)) - 1;
-	index_bits_to_maxindex[ARRAY_SIZE(index_bits_to_maxindex) - 1] = ~0UL;
-}
-
-/*
- * Maximum heap_index that can be stored in a PST with index_bits bits
- */
-static inline unsigned long prio_tree_maxindex(unsigned int bits)
-{
-	return index_bits_to_maxindex[bits - 1];
-}
-
-static void prio_set_parent(struct prio_tree_node *parent,
-			    struct prio_tree_node *child, bool left)
-{
-	if (left)
-		parent->left = child;
-	else
-		parent->right = child;
-
-	child->parent = parent;
-}
-
-/*
- * Extend a priority search tree so that it can store a node with heap_index
- * max_heap_index. In the worst case, this algorithm takes O((log n)^2).
- * However, this function is used rarely and the common case performance is
- * not bad.
- */
-static struct prio_tree_node *prio_tree_expand(struct prio_tree_root *root,
-		struct prio_tree_node *node, unsigned long max_heap_index)
-{
-	struct prio_tree_node *prev;
-
-	if (max_heap_index > prio_tree_maxindex(root->index_bits))
-		root->index_bits++;
-
-	prev = node;
-	INIT_PRIO_TREE_NODE(node);
-
-	while (max_heap_index > prio_tree_maxindex(root->index_bits)) {
-		struct prio_tree_node *tmp = root->prio_tree_node;
-
-		root->index_bits++;
-
-		if (prio_tree_empty(root))
-			continue;
-
-		prio_tree_remove(root, root->prio_tree_node);
-		INIT_PRIO_TREE_NODE(tmp);
-
-		prio_set_parent(prev, tmp, true);
-		prev = tmp;
-	}
-
-	if (!prio_tree_empty(root))
-		prio_set_parent(prev, root->prio_tree_node, true);
-
-	root->prio_tree_node = node;
-	return node;
-}
-
-/*
- * Replace a prio_tree_node with a new node and return the old node
- */
-struct prio_tree_node *prio_tree_replace(struct prio_tree_root *root,
-		struct prio_tree_node *old, struct prio_tree_node *node)
-{
-	INIT_PRIO_TREE_NODE(node);
-
-	if (prio_tree_root(old)) {
-		BUG_ON(root->prio_tree_node != old);
-		/*
-		 * We can reduce root->index_bits here. However, it is complex
-		 * and does not help much to improve performance (IMO).
-		 */
-		root->prio_tree_node = node;
-	} else
-		prio_set_parent(old->parent, node, old->parent->left == old);
-
-	if (!prio_tree_left_empty(old))
-		prio_set_parent(node, old->left, true);
-
-	if (!prio_tree_right_empty(old))
-		prio_set_parent(node, old->right, false);
-
-	return old;
-}
-
-/*
- * Insert a prio_tree_node @node into a radix priority search tree @root. The
- * algorithm typically takes O(log n) time where 'log n' is the number of bits
- * required to represent the maximum heap_index. In the worst case, the algo
- * can take O((log n)^2) - check prio_tree_expand.
- *
- * If a prior node with same radix_index and heap_index is already found in
- * the tree, then returns the address of the prior node. Otherwise, inserts
- * @node into the tree and returns @node.
- */
-struct prio_tree_node *prio_tree_insert(struct prio_tree_root *root,
-		struct prio_tree_node *node)
-{
-	struct prio_tree_node *cur, *res = node;
-	unsigned long radix_index, heap_index;
-	unsigned long r_index, h_index, index, mask;
-	int size_flag = 0;
-
-	get_index(root, node, &radix_index, &heap_index);
-
-	if (prio_tree_empty(root) ||
-			heap_index > prio_tree_maxindex(root->index_bits))
-		return prio_tree_expand(root, node, heap_index);
-
-	cur = root->prio_tree_node;
-	mask = 1UL << (root->index_bits - 1);
-
-	while (mask) {
-		get_index(root, cur, &r_index, &h_index);
-
-		if (r_index == radix_index && h_index == heap_index)
-			return cur;
-
-                if (h_index < heap_index ||
-		    (h_index == heap_index && r_index > radix_index)) {
-			struct prio_tree_node *tmp = node;
-			node = prio_tree_replace(root, cur, node);
-			cur = tmp;
-			/* swap indices */
-			index = r_index;
-			r_index = radix_index;
-			radix_index = index;
-			index = h_index;
-			h_index = heap_index;
-			heap_index = index;
-		}
-
-		if (size_flag)
-			index = heap_index - radix_index;
-		else
-			index = radix_index;
-
-		if (index & mask) {
-			if (prio_tree_right_empty(cur)) {
-				INIT_PRIO_TREE_NODE(node);
-				prio_set_parent(cur, node, false);
-				return res;
-			} else
-				cur = cur->right;
-		} else {
-			if (prio_tree_left_empty(cur)) {
-				INIT_PRIO_TREE_NODE(node);
-				prio_set_parent(cur, node, true);
-				return res;
-			} else
-				cur = cur->left;
-		}
-
-		mask >>= 1;
-
-		if (!mask) {
-			mask = 1UL << (BITS_PER_LONG - 1);
-			size_flag = 1;
-		}
-	}
-	/* Should not reach here */
-	BUG();
-	return NULL;
-}
-EXPORT_SYMBOL(prio_tree_insert);
-
-/*
- * Remove a prio_tree_node @node from a radix priority search tree @root. The
- * algorithm takes O(log n) time where 'log n' is the number of bits required
- * to represent the maximum heap_index.
- */
-void prio_tree_remove(struct prio_tree_root *root, struct prio_tree_node *node)
-{
-	struct prio_tree_node *cur;
-	unsigned long r_index, h_index_right, h_index_left;
-
-	cur = node;
-
-	while (!prio_tree_left_empty(cur) || !prio_tree_right_empty(cur)) {
-		if (!prio_tree_left_empty(cur))
-			get_index(root, cur->left, &r_index, &h_index_left);
-		else {
-			cur = cur->right;
-			continue;
-		}
-
-		if (!prio_tree_right_empty(cur))
-			get_index(root, cur->right, &r_index, &h_index_right);
-		else {
-			cur = cur->left;
-			continue;
-		}
-
-		/* both h_index_left and h_index_right cannot be 0 */
-		if (h_index_left >= h_index_right)
-			cur = cur->left;
-		else
-			cur = cur->right;
-	}
-
-	if (prio_tree_root(cur)) {
-		BUG_ON(root->prio_tree_node != cur);
-		__INIT_PRIO_TREE_ROOT(root, root->raw);
-		return;
-	}
-
-	if (cur->parent->right == cur)
-		cur->parent->right = cur->parent;
-	else
-		cur->parent->left = cur->parent;
-
-	while (cur != node)
-		cur = prio_tree_replace(root, cur->parent, cur);
-}
-EXPORT_SYMBOL(prio_tree_remove);
-
-static void iter_walk_down(struct prio_tree_iter *iter)
-{
-	iter->mask >>= 1;
-	if (iter->mask) {
-		if (iter->size_level)
-			iter->size_level++;
-		return;
-	}
-
-	if (iter->size_level) {
-		BUG_ON(!prio_tree_left_empty(iter->cur));
-		BUG_ON(!prio_tree_right_empty(iter->cur));
-		iter->size_level++;
-		iter->mask = ULONG_MAX;
-	} else {
-		iter->size_level = 1;
-		iter->mask = 1UL << (BITS_PER_LONG - 1);
-	}
-}
-
-static void iter_walk_up(struct prio_tree_iter *iter)
-{
-	if (iter->mask == ULONG_MAX)
-		iter->mask = 1UL;
-	else if (iter->size_level == 1)
-		iter->mask = 1UL;
-	else
-		iter->mask <<= 1;
-	if (iter->size_level)
-		iter->size_level--;
-	if (!iter->size_level && (iter->value & iter->mask))
-		iter->value ^= iter->mask;
-}
-
-/*
- * Following functions help to enumerate all prio_tree_nodes in the tree that
- * overlap with the input interval X [radix_index, heap_index]. The enumeration
- * takes O(log n + m) time where 'log n' is the height of the tree (which is
- * proportional to # of bits required to represent the maximum heap_index) and
- * 'm' is the number of prio_tree_nodes that overlap the interval X.
- */
-
-static struct prio_tree_node *prio_tree_left(struct prio_tree_iter *iter,
-		unsigned long *r_index, unsigned long *h_index)
-{
-	if (prio_tree_left_empty(iter->cur))
-		return NULL;
-
-	get_index(iter->root, iter->cur->left, r_index, h_index);
-
-	if (iter->r_index <= *h_index) {
-		iter->cur = iter->cur->left;
-		iter_walk_down(iter);
-		return iter->cur;
-	}
-
-	return NULL;
-}
-
-static struct prio_tree_node *prio_tree_right(struct prio_tree_iter *iter,
-		unsigned long *r_index, unsigned long *h_index)
-{
-	unsigned long value;
-
-	if (prio_tree_right_empty(iter->cur))
-		return NULL;
-
-	if (iter->size_level)
-		value = iter->value;
-	else
-		value = iter->value | iter->mask;
-
-	if (iter->h_index < value)
-		return NULL;
-
-	get_index(iter->root, iter->cur->right, r_index, h_index);
-
-	if (iter->r_index <= *h_index) {
-		iter->cur = iter->cur->right;
-		iter_walk_down(iter);
-		return iter->cur;
-	}
-
-	return NULL;
-}
-
-static struct prio_tree_node *prio_tree_parent(struct prio_tree_iter *iter)
-{
-	iter->cur = iter->cur->parent;
-	iter_walk_up(iter);
-	return iter->cur;
-}
-
-static inline int overlap(struct prio_tree_iter *iter,
-		unsigned long r_index, unsigned long h_index)
-{
-	return iter->h_index >= r_index && iter->r_index <= h_index;
-}
-
-/*
- * prio_tree_first:
- *
- * Get the first prio_tree_node that overlaps with the interval [radix_index,
- * heap_index]. Note that always radix_index <= heap_index. We do a pre-order
- * traversal of the tree.
- */
-static struct prio_tree_node *prio_tree_first(struct prio_tree_iter *iter)
-{
-	struct prio_tree_root *root;
-	unsigned long r_index, h_index;
-
-	INIT_PRIO_TREE_ITER(iter);
-
-	root = iter->root;
-	if (prio_tree_empty(root))
-		return NULL;
-
-	get_index(root, root->prio_tree_node, &r_index, &h_index);
-
-	if (iter->r_index > h_index)
-		return NULL;
-
-	iter->mask = 1UL << (root->index_bits - 1);
-	iter->cur = root->prio_tree_node;
-
-	while (1) {
-		if (overlap(iter, r_index, h_index))
-			return iter->cur;
-
-		if (prio_tree_left(iter, &r_index, &h_index))
-			continue;
-
-		if (prio_tree_right(iter, &r_index, &h_index))
-			continue;
-
-		break;
-	}
-	return NULL;
-}
-
-/*
- * prio_tree_next:
- *
- * Get the next prio_tree_node that overlaps with the input interval in iter
- */
-struct prio_tree_node *prio_tree_next(struct prio_tree_iter *iter)
-{
-	unsigned long r_index, h_index;
-
-	if (iter->cur == NULL)
-		return prio_tree_first(iter);
-
-repeat:
-	while (prio_tree_left(iter, &r_index, &h_index))
-		if (overlap(iter, r_index, h_index))
-			return iter->cur;
-
-	while (!prio_tree_right(iter, &r_index, &h_index)) {
-	    	while (!prio_tree_root(iter->cur) &&
-				iter->cur->parent->right == iter->cur)
-			prio_tree_parent(iter);
-
-		if (prio_tree_root(iter->cur))
-			return NULL;
-
-		prio_tree_parent(iter);
-	}
-
-	if (overlap(iter, r_index, h_index))
-		return iter->cur;
-
-	goto repeat;
-}
-EXPORT_SYMBOL(prio_tree_next);
diff --git a/lib/prio_tree_test.c b/lib/prio_tree_test.c
deleted file mode 100644
index c26084d..0000000
--- a/lib/prio_tree_test.c
+++ /dev/null
@@ -1,106 +0,0 @@
-#include <linux/module.h>
-#include <linux/prio_tree.h>
-#include <linux/random.h>
-#include <asm/timex.h>
-
-#define NODES        100
-#define PERF_LOOPS   100000
-#define SEARCHES     100
-#define SEARCH_LOOPS 10000
-
-static struct prio_tree_root root;
-static struct prio_tree_node nodes[NODES];
-static u32 queries[SEARCHES];
-
-static struct rnd_state rnd;
-
-static inline unsigned long
-search(unsigned long query, struct prio_tree_root *root)
-{
-	struct prio_tree_iter iter;
-	unsigned long results = 0;
-
-	prio_tree_iter_init(&iter, root, query, query);
-	while (prio_tree_next(&iter))
-		results++;
-	return results;
-}
-
-static void init(void)
-{
-	int i;
-	for (i = 0; i < NODES; i++) {
-		u32 a = prandom32(&rnd), b = prandom32(&rnd);
-		if (a <= b) {
-			nodes[i].start = a;
-			nodes[i].last = b;
-		} else {
-			nodes[i].start = b;
-			nodes[i].last = a;
-		}
-	}
-	for (i = 0; i < SEARCHES; i++)
-		queries[i] = prandom32(&rnd);
-}
-
-static int prio_tree_test_init(void)
-{
-	int i, j;
-	unsigned long results;
-	cycles_t time1, time2, time;
-
-	printk(KERN_ALERT "prio tree insert/remove");
-
-	prandom32_seed(&rnd, 3141592653589793238ULL);
-	INIT_PRIO_TREE_ROOT(&root);
-	init();
-
-	time1 = get_cycles();
-
-	for (i = 0; i < PERF_LOOPS; i++) {
-		for (j = 0; j < NODES; j++)
-			prio_tree_insert(&root, nodes + j);
-		for (j = 0; j < NODES; j++)
-			prio_tree_remove(&root, nodes + j);
-	}
-
-	time2 = get_cycles();
-	time = time2 - time1;
-
-	time = div_u64(time, PERF_LOOPS);
-	printk(" -> %llu cycles\n", (unsigned long long)time);
-
-	printk(KERN_ALERT "prio tree search");
-
-	for (j = 0; j < NODES; j++)
-		prio_tree_insert(&root, nodes + j);
-
-	time1 = get_cycles();
-
-	results = 0;
-	for (i = 0; i < SEARCH_LOOPS; i++)
-		for (j = 0; j < SEARCHES; j++)
-			results += search(queries[j], &root);
-
-	time2 = get_cycles();
-	time = time2 - time1;
-
-	time = div_u64(time, SEARCH_LOOPS);
-	results = div_u64(results, SEARCH_LOOPS);
-	printk(" -> %llu cycles (%lu results)\n",
-	       (unsigned long long)time, results);
-
-	return -EAGAIN; /* Fail will directly unload the module */
-}
-
-static void prio_tree_test_exit(void)
-{
-	printk(KERN_ALERT "test exit\n");
-}
-
-module_init(prio_tree_test_init)
-module_exit(prio_tree_test_exit)
-
-MODULE_LICENSE("GPL");
-MODULE_AUTHOR("Michel Lespinasse");
-MODULE_DESCRIPTION("Prio Tree test");
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
