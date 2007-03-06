Message-Id: <20070306014211.048104000@taijtu.programming.kicks-ass.net>
References: <20070306013815.951032000@taijtu.programming.kicks-ass.net>
Date: Tue, 06 Mar 2007 02:38:16 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 1/5] RCU friendly B+tree
Content-Disposition: inline; filename=btree.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Christoph Lameter <clameter@engr.sgi.com>, "Paul E. McKenney" <paulmck@us.ibm.com>, Nick Piggin <npiggin@suse.de>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

A RCU friendly B+tree

TODO:
 - review memory barriers
 - at least rewrite search using an iterative approach
 - more documentation

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/btree.h |  198 ++++++++++
 lib/Makefile          |    2 
 lib/btree.c           |  924 ++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 1123 insertions(+), 1 deletion(-)

Index: linux-2.6/include/linux/btree.h
===================================================================
--- /dev/null
+++ linux-2.6/include/linux/btree.h
@@ -0,0 +1,198 @@
+#ifndef _LINUX_BTREE_H
+#define _LINUX_BTREE_H
+
+#define BTREE_DEBUG	1
+
+#include <linux/mempool.h>
+#include <linux/log2.h>
+#include <linux/rcupdate.h>
+#include <asm/cache.h>
+#include <asm/bitops.h>
+
+struct btree_item {
+	unsigned long key;
+	union {
+		struct btree_node *child;
+		void *data;
+	};
+};
+
+#define BTREE_ITEM_CACHELINE (L1_CACHE_BYTES / sizeof(struct btree_item))
+#define BTREE_ITEM_MAX (BTREE_ITEM_CACHELINE < 16 ? 16 : BTREE_ITEM_CACHELINE)
+#define BTREE_ITEM_HALF (BTREE_ITEM_MAX/2)
+
+struct btree_node {
+	struct btree_item item[BTREE_ITEM_MAX];
+};
+
+/*
+ * Max number of nodes to be RCUed per modification.
+ * Assumes BTREE_ITEM_MAX is power of two.
+ */
+#define BTREE_NODE_REPLACE \
+	(2 * (1 + DIV_ROUND_UP(BITS_PER_LONG, ilog2(BTREE_ITEM_MAX))))
+
+struct btree_freevec {
+	struct rcu_head rcu_head;
+	int pos;
+	void *slot[BTREE_NODE_REPLACE];
+};
+
+struct btree_root {
+	struct btree_node *root;
+	int height;
+	mempool_t *mempool;
+	struct btree_freevec *freevec;
+	gfp_t gfp_mask;
+	void (*flush)(struct btree_freevec *);
+};
+
+#ifdef BTREE_DEBUG
+void btree_print(struct btree_root *);
+#else
+#define btree_print(root) do { } while (0)
+#endif
+
+static inline int btree_item_leaf(struct btree_item *itemp)
+{
+	return !test_bit(0, (void *)&itemp->child);
+}
+
+static inline struct btree_node *btree_item_deref(struct btree_item *itemp)
+{
+	struct btree_node *child = rcu_dereference(itemp->child);
+	__clear_bit(0, (void *)&child);
+	return child;
+}
+
+extern struct btree_item *__btree_search(struct btree_root *,
+		struct btree_node *, unsigned long, int, int *);
+
+extern struct btree_item *__btree_search_next(struct btree_root *,
+		struct btree_node *, struct btree_item **,
+		unsigned long, int, int *);
+
+static inline void *btree_lookup(struct btree_root *root, unsigned long index)
+{
+	int retry = 0;
+	struct btree_item *item;
+
+
+	if (!root->root)
+		return NULL;
+
+	item = __btree_search(root, root->root, index,
+			root->height - 1, &retry);
+
+	if (retry || item->key != index)
+		return NULL;
+
+	return item->data;
+}
+
+static inline void *btree_lookup_next(struct btree_root *root,
+		unsigned long index, void **nextp)
+{
+	int retry = 0;
+	struct btree_item *next = NULL, *item;
+
+	*nextp = NULL;
+	if (!root->root)
+		return NULL;
+
+	item = __btree_search_next(root, root->root, &next,
+			index, root->height - 1, &retry);
+
+	switch (retry) {
+		case -1:
+			*nextp = next->data;
+			return NULL;
+
+		case 0:
+			*nextp = next->data;
+			/* fall through */
+		case 1:
+			if (item->key != index)
+				return NULL;
+			break;
+	}
+
+	return item->data;
+}
+
+static inline void *btree_stab(struct btree_root *root, unsigned long index)
+{
+	int retry = 0;
+	struct btree_item *item;
+
+
+	if (!root->root)
+		return NULL;
+
+	item = __btree_search(root, root->root, index,
+			root->height - 1, &retry);
+
+	if (retry)
+		return NULL;
+
+	return item->data;
+}
+
+static inline void *btree_stab_next(struct btree_root *root,
+		unsigned long index, void **nextp)
+{
+	int retry = 0;
+	struct btree_item *next = NULL, *item;
+
+	*nextp = NULL;
+	if (!root->root)
+		return NULL;
+
+	item = __btree_search_next(root, root->root, &next,
+			index, root->height - 1, &retry);
+
+	switch (retry) {
+		case -1:
+			*nextp = next->data;
+			return NULL;
+
+		case 0:
+			*nextp = next->data;
+			/* fall through */
+		case 1:
+			break;
+	}
+
+	if (!item) {
+		printk(KERN_DEBUG "stab_next: %lu next: %p\n", index, *nextp);
+		btree_print(root);
+		BUG();
+	}
+
+	return item->data;
+}
+
+extern int btree_preload(struct btree_root *, gfp_t);
+extern int btree_insert(struct btree_root *, unsigned long, void *);
+extern int btree_update(struct btree_root *, unsigned long, unsigned long);
+extern void *btree_remove(struct btree_root *, unsigned long);
+
+extern void btree_root_init(struct btree_root *, gfp_t);
+extern void btree_root_destroy(struct btree_root *);
+
+extern void btree_freevec_flush(struct btree_freevec *);
+
+#define BTREE_INIT_FLUSH(gfp, f) (struct btree_root){ 	\
+	.root = NULL, 					\
+	.height = 0,					\
+	.mempool = NULL,				\
+	.freevec = NULL,				\
+	.gfp_mask = (gfp),				\
+	.flush = (f),					\
+}
+
+#define BTREE_INIT(gfp) BTREE_INIT_FLUSH(gfp, btree_freevec_flush)
+
+extern void __init btree_init(void);
+
+#endif /* _LINUX_BTREE_H */
Index: linux-2.6/lib/Makefile
===================================================================
--- linux-2.6.orig/lib/Makefile
+++ linux-2.6/lib/Makefile
@@ -5,7 +5,7 @@
 lib-y := ctype.o string.o vsprintf.o cmdline.o \
 	 bust_spinlocks.o rbtree.o radix-tree.o dump_stack.o \
 	 idr.o div64.o int_sqrt.o bitmap.o extable.o prio_tree.o \
-	 sha1.o irq_regs.o reciprocal_div.o
+	 sha1.o irq_regs.o reciprocal_div.o btree.o
 
 lib-$(CONFIG_MMU) += ioremap.o
 lib-$(CONFIG_SMP) += cpumask.o
Index: linux-2.6/lib/btree.c
===================================================================
--- /dev/null
+++ linux-2.6/lib/btree.c
@@ -0,0 +1,924 @@
+/*
+ * Copyright 2007, Red Hat Inc. Peter Zijlstra <pzijlstr@redhat.com>
+ * GPLv2
+ *
+ * Something that started out as an RCU friendly B+tree.
+ *
+ * Contrairy to most B-trees the nodes have an even number of slots.  This can
+ * be done because we carry all the children in the leafs and thus we don't
+ * need to push one up on a split.  We can just duplicate the first.
+ *
+ * The inner nodes are basically an N-way space partition.
+ *
+ * Another difference to the typical B+tree is that this implementation does
+ * not thread the leafs, this is left up to the user if so desired.
+ *
+ *
+ *   [------------------------------>[------------------------------>
+ *   |                               |
+ *   [------------------->[--------->[-------------->[-------------->
+ *   |                    |          |               |
+ *   [..) [..) [..) [..)  [..) [..)  [..) [..) [..)  [..) [..) [..)
+ *
+ *
+ */
+#include <linux/btree.h>
+#include <linux/slab.h>
+#include <linux/log2.h>
+#include <linux/err.h>
+
+#ifdef BTREE_DEBUG
+void btree_print(struct btree_root *root);
+int btree_validate(struct btree_root *root);
+#else
+#define btree_print(root) do { } while (0)
+#define btree_validate(root) (0)
+#endif
+
+static struct kmem_cache *btree_cachep;
+
+static inline void btree_free(struct btree_root *root, void *ptr)
+{
+	root->freevec->slot[root->freevec->pos++] = ptr;
+}
+
+static inline void btree_ptr_flip(struct btree_root *root,
+		struct btree_node **nodep, struct btree_node *new)
+{
+	struct btree_node *old = rcu_dereference(*nodep);
+	rcu_assign_pointer(*nodep, new);
+	__clear_bit(0, (void *)&old);
+	btree_free(root, old);
+}
+
+static inline struct btree_node *btree_node_child(struct btree_node *nodep)
+{
+	__set_bit(0, (void *)&nodep);
+	return nodep;
+}
+
+static inline void btree_item_flip(struct btree_root *root,
+		struct btree_item *itemp, struct btree_node *new)
+{
+	btree_ptr_flip(root, &itemp->child, btree_node_child(new));
+	/* possibly tighten */
+	if (itemp->key != new->item[0].key) {
+		/*
+		 * we can only tighten when the new node is linked in
+		 */
+		smp_wmb();
+		itemp->key = new->item[0].key;
+	}
+}
+
+static inline void btree_item_free(struct btree_root *root,
+		struct btree_item *itemp)
+{
+	if (!btree_item_leaf(itemp))
+		btree_free(root, btree_item_deref(itemp));
+}
+
+int btree_preload(struct btree_root *root, gfp_t gfp_mask)
+{
+	int ret = 0;
+
+	if (!root->mempool) {
+		root->mempool = mempool_create_slab_pool(0, btree_cachep);
+		if (!root->mempool)
+			return -ENOMEM;
+	}
+
+	if (!root->freevec) {
+		root->freevec = kzalloc(sizeof(struct btree_freevec), gfp_mask);
+		if (!root->freevec)
+			return -ENOMEM;
+	}
+
+	ret = mempool_resize(root->mempool, 1+2*root->height, gfp_mask);
+
+	return ret;
+}
+
+static int btree_mod_init(struct btree_root *root)
+{
+	return btree_preload(root, root->gfp_mask);
+}
+
+static int btree_mod_finish(struct btree_root *root, unsigned long index)
+{
+	int ret = 0;
+	if (root->mempool)
+		ret = mempool_resize(root->mempool, 1, root->gfp_mask);
+
+	if (btree_validate(root)) {
+		printk(KERN_DEBUG "modified: %lu\n", index);
+		btree_print(root);
+		BUG();
+	}
+
+	root->flush(root->freevec);
+	root->freevec = NULL;
+
+	return ret;
+}
+
+/* ------ search ------- */
+
+/*
+ * Since we can re-adjust the space partitioning in delete and update a
+ * lockless lookup might hit a wrong branch once in a while, hence we might
+ * need to backtrack.
+ *
+ * Because we do a search for a less than or equal index we can only backtrack.
+ * That is a split might over estimate (too loose) but never under estimate
+ * (too tight).  Thus we can loosen on our way down, but have to tighten on
+ * our way up.  See update and remove.
+ *
+ * NOTE the backtrack should be limited to one entry so worst time is:
+ *   O(2*log(n)-1)
+ */
+
+/*
+ * find which branch to take
+ */
+static inline
+int __btree_item_search(struct btree_root *root,
+		struct btree_node *node, unsigned long index)
+{
+	int i;
+	/*
+	 * match for the wmb in btree_item_flip() (??)
+	 */
+	smp_rmb();
+	for (i = 1; i < BTREE_ITEM_MAX; i++)
+		if (node->item[i].child == NULL ||
+				index < node->item[i].key)
+			break;
+	i--;
+	return i;
+}
+
+/*
+ * find the item with a lesser or equal index
+ */
+struct btree_item *__btree_search(struct btree_root *root,
+		struct btree_node *node, unsigned long index, int height,
+		int *retryp)
+{
+	struct btree_item *ret;
+	int i, retry;
+
+	i = __btree_item_search(root, node, index);
+
+	if (height == 0) {
+		retry = (node->item[i].key <= index) ? 0 : -1;
+		if (unlikely(retry)) {
+			i += retry;
+			if (i < 0) {
+				*retryp = retry;
+				return NULL;
+			}
+		}
+		return &node->item[i];
+	}
+
+again:
+	retry = 0;
+	ret = __btree_search(root, btree_item_deref(&node->item[i]),
+			index, height - 1, &retry);
+
+	if (unlikely(retry)) {
+		i += retry;
+		if (i < 0) {
+			*retryp = retry;
+			return NULL;
+		}
+		goto again;
+	}
+
+	return ret;
+}
+
+/*
+ * get the first item for a sub-tree
+ */
+static
+struct btree_item *__btree_search_first(struct btree_root *root,
+		struct btree_node *node, int height)
+{
+	if (height == 0)
+		return &node->item[0];
+
+	return __btree_search_first(root, btree_item_deref(&node->item[0]),
+			height - 1);
+}
+
+/*
+ * find the item with a lesser or equal index and the next item.
+ */
+struct btree_item *__btree_search_next(struct btree_root *root,
+		struct btree_node *node, struct btree_item **nextp,
+		unsigned long index, int height, int *retryp)
+{
+	struct btree_item *ret;
+	int i, retry;
+
+	i = __btree_item_search(root, node, index);
+
+	if (height == 0) {
+		retry = (node->item[i].key <= index) ? 0 : -1;
+		if (retry) {
+			*nextp = &node->item[i];
+			i += retry;
+			if (i < 0) {
+				*retryp = retry;
+				return NULL;
+			}
+		} else if (!*nextp) {
+			if ((i + 1) >= BTREE_ITEM_MAX || !node->item[i+1].data)
+				*retryp = 1;
+			else
+				*nextp = &node->item[i+1];
+		}
+		return &node->item[i];
+	}
+
+again:
+	retry = 0;
+	ret = __btree_search_next(root,
+			btree_item_deref(&node->item[i]),
+			nextp, index, height - 1, &retry);
+
+	i += retry;
+	switch (retry) {
+	case -1:
+		if (i < 0) {
+			*retryp = retry;
+			return NULL;
+		}
+		goto again;
+
+	case 1:
+		if (i >= BTREE_ITEM_MAX || !node->item[i].child)
+			*retryp = retry;
+		else
+			*nextp = __btree_search_first(root,
+					btree_item_deref(&node->item[i]),
+					height - 1);
+		break;
+
+	case 0:
+		break;
+	}
+
+	return ret;
+}
+
+/* ------ insert ------- */
+
+/*
+ * recusrive insert item; split nodes when needed
+ */
+static int __btree_insert(struct btree_root *root,
+		struct btree_node **nodep, struct btree_node **splitp,
+		struct btree_item *itemp, int height)
+{
+	struct btree_node *node = *nodep;
+	struct btree_node *new, *split;
+	struct btree_node *update = NULL;
+	int i, j, ret;
+
+	i = __btree_item_search(root, node, itemp->key);
+
+	if (height == 0) {
+		if (node->item[i].child && node->item[i].key == itemp->key)
+			return -EEXIST;
+
+		if (node->item[i].child && node->item[i].key < itemp->key)
+			i++; /* insert after */
+	} else {
+		struct btree_node *child = btree_item_deref(&node->item[i]);
+		new = child;
+		split = NULL;
+		ret = __btree_insert(root, &new, &split, itemp, height - 1);
+		if (ret)
+			return ret;
+
+		if (new == child)
+			return 0;
+
+		if (split == NULL) {
+			btree_item_flip(root, &node->item[i], new);
+			return 0;
+		}
+		update = new;
+
+		i++; /* insert after */
+	}
+
+	new = mempool_alloc(root->mempool, root->gfp_mask);
+	memset(new, 0, sizeof(struct btree_node));
+	/* insert has room */
+	if (node->item[BTREE_ITEM_MAX-1].data == NULL) {
+		for (j = 0; j < i; j++)
+			new->item[j] = node->item[j];
+		new->item[j] = *itemp;
+		for (; j < BTREE_ITEM_MAX-1; j++)
+			new->item[j+1] = node->item[j];
+
+		if (update)
+			btree_item_flip(root, &new->item[i-1], update);
+
+		*nodep = new;
+		return 0;
+	}
+
+	split = mempool_alloc(root->mempool, root->gfp_mask);
+	memset(split, 0, sizeof(struct btree_node));
+	/* insert overflows - split */
+	if (i < BTREE_ITEM_HALF) {
+		for (j = 0; j < i; j++)
+			new->item[j] = node->item[j];
+		new->item[j] = *itemp;
+		for (; j < BTREE_ITEM_HALF; j++)
+			new->item[j+1] = node->item[j];
+
+		for (; j < BTREE_ITEM_MAX; j++)
+			split->item[j - BTREE_ITEM_HALF] = node->item[j];
+	} else {
+		for (j = 0; j < BTREE_ITEM_HALF; j++)
+			new->item[j] = node->item[j];
+
+		for (; j < i; j++)
+			split->item[j - BTREE_ITEM_HALF] = node->item[j];
+		split->item[j - BTREE_ITEM_HALF] = *itemp;
+		for (; j < BTREE_ITEM_MAX; j++)
+			split->item[j + 1 - BTREE_ITEM_HALF] = node->item[j];
+	}
+
+	if (update) {
+		if (i-1 < BTREE_ITEM_HALF)
+			btree_item_flip(root, &new->item[i-1], update);
+		else
+			btree_item_flip(root, &split->item[i-1-BTREE_ITEM_HALF], update);
+	}
+
+	*nodep = new;
+	*splitp = split;
+	*itemp = (struct btree_item){
+		.key = split->item[0].key,
+		{ .child = btree_node_child(split) }
+	};
+	return 0;
+}
+
+/*
+ * handle root updates
+ */
+int btree_insert(struct btree_root *root, unsigned long index, void *data)
+{
+	struct btree_item item = (struct btree_item){
+		.key = index,
+		{ .data = data }
+	};
+	struct btree_node *new, *node, *split = NULL;
+	int ret = btree_mod_init(root);
+	if (ret)
+		return ret;
+
+	if (!root->root) {
+		root->root = mempool_alloc(root->mempool, root->gfp_mask);
+		memset(root->root, 0, sizeof(struct btree_node));
+		root->height = 1;
+	}
+
+	node = root->root;
+	ret = __btree_insert(root, &node, &split, &item, root->height - 1);
+	if (ret)
+		goto out;
+
+	if (node == root->root)
+		goto out;
+
+	if (split == NULL) {
+		btree_ptr_flip(root, &root->root, node);
+		goto out;
+	}
+
+	new = mempool_alloc(root->mempool, root->gfp_mask);
+	memset(new, 0, sizeof(struct btree_node));
+	new->item[0] = (struct btree_item){
+		.key = node->item[0].key,
+		{ .child = btree_node_child(node) }
+	};
+	new->item[1] = (struct btree_item){
+		.key = split->item[0].key,
+		{ .child = btree_node_child(split) }
+	};
+	root->height++;
+
+	btree_ptr_flip(root, &root->root, new);
+
+out:
+	btree_mod_finish(root, index);
+	return ret;
+}
+
+/* ------ update ------- */
+
+/*
+ * update the index of an item
+ *
+ * be careful the range:
+ *   [min(index, new_index), max(index, new_index]
+ * _MUST_ be free, otherwise remove and reinsert.
+ *
+ * see the search comment for lockless lookup constraints
+ */
+static int __btree_update(struct btree_root *root, struct btree_node *node,
+		unsigned long index, unsigned long new_index, int height)
+{
+	struct btree_node *child;
+	unsigned long key;
+	int i, ret;
+
+	i = __btree_item_search(root, node, index);
+	key = node->item[i].key;
+
+	if (height == 0) {
+		if (key != index)
+			return -EINVAL;
+		node->item[i].key = new_index;
+		return 0;
+	}
+
+	child = btree_item_deref(&node->item[i]);
+	/* loosen downwards */
+	if (index > new_index && key == index)
+		key = node->item[i].key = new_index;
+	ret = __btree_update(root, child, index, new_index, height - 1);
+	/* undo on error */
+	if (ret && index > new_index && key == new_index)
+		node->item[i].key = index;
+	/* tighten upwards */
+	if (!ret && index < new_index && key == index)
+		node->item[i].key = new_index;
+
+	return ret;
+}
+
+int btree_update(struct btree_root *root, unsigned long index, unsigned long new_index)
+{
+	int ret;
+
+	if (!root->root)
+		return 0;
+	if (index == new_index)
+		return 0;
+	ret = __btree_update(root, root->root, index, new_index,
+			root->height - 1);
+	if (btree_validate(root)) {
+		printk(KERN_DEBUG "btree_update: index: %lu new_index: %lu\n",
+				index, new_index);
+		btree_print(root);
+		BUG();
+	}
+	return ret;
+}
+
+/* ------ delete ------- */
+
+/*
+ * delete an item; borrow items or merge nodes when needed.
+ */
+static void *__btree_remove(struct btree_root *root,
+		struct btree_node **leftp,
+		struct btree_node **nodep,
+		struct btree_node **rightp,
+		unsigned long index, int height)
+{
+	struct btree_node *node = *nodep;
+	struct btree_node *new;
+	struct btree_node *update = NULL;
+	int i, j, k, n;
+	void *ret = NULL;
+
+	i = __btree_item_search(root, node, index);
+
+	if (height == 0) {
+		if (node->item[i].key != index) {
+			ret = ERR_PTR(-EINVAL);
+			goto done;
+		}
+		ret = node->item[i].data;
+	} else {
+		struct btree_node *oleft,  *left = NULL;
+		struct btree_node *ochild, *child;
+		struct btree_node *oright, *right = NULL;
+
+		if (i > 0)
+			left = btree_item_deref(&node->item[i-1]);
+		child = btree_item_deref(&node->item[i]);
+		if (i + 1 < BTREE_ITEM_MAX)
+			right = btree_item_deref(&node->item[i+1]);
+
+		oleft = left; ochild = child; oright = right;
+
+		ret = __btree_remove(root, &left, &child, &right,
+				index, height - 1);
+
+		/* no change */
+		if (child == ochild) {
+			/* possibly tighten the split on our way back up */
+			if (node->item[i].key != child->item[0].key)
+				node->item[i].key = child->item[0].key;
+			goto done;
+		}
+
+		/* single change */
+		if (left == oleft && right == oright) {
+			btree_item_flip(root, &node->item[i], child);
+			goto done;
+		}
+
+		/* borrowed left  */
+		if (oleft && left && left != oleft && child) {
+			new = mempool_alloc(root->mempool, root->gfp_mask);
+			memset(new, 0, sizeof(struct btree_node));
+			for (j = 0; j < i-1; j++)
+				new->item[j] = node->item[j];
+			new->item[j++] = (struct btree_item){
+				.key = left->item[0].key,
+				{ .child = btree_node_child(left) }
+			};
+			new->item[j++] = (struct btree_item){
+				.key = child->item[0].key,
+				{ .child = btree_node_child(child) }
+			};
+			for (; j < BTREE_ITEM_MAX; j++)
+				new->item[j] = node->item[j];
+
+			btree_item_free(root, &node->item[i-1]);
+			btree_item_free(root, &node->item[i]);
+
+			*nodep = new;
+			goto done;
+		}
+
+		/* borrowed right */
+		if (oright && right && right != oright && child) {
+			new = mempool_alloc(root->mempool, root->gfp_mask);
+			memset(new, 0, sizeof(struct btree_node));
+			for (j = 0; j < i; j++)
+				new->item[j] = node->item[j];
+			new->item[j++] = (struct btree_item){
+				.key = child->item[0].key,
+				{ .child = btree_node_child(child) }
+			};
+			new->item[j++] = (struct btree_item){
+				.key = right->item[0].key,
+				{ .child = btree_node_child(right) }
+			};
+			for (; j < BTREE_ITEM_MAX; j++)
+				new->item[j] = node->item[j];
+
+			btree_item_free(root, &node->item[i]);
+			btree_item_free(root, &node->item[i+1]);
+
+			*nodep = new;
+			goto done;
+		}
+
+		/* merged left */
+		if (!child)
+			update = left;
+
+		/* merged right */
+		else if (oright && !right) {
+			update = child;
+			i++;
+		}
+	}
+
+	/* delete */
+	new = mempool_alloc(root->mempool, root->gfp_mask);
+	memset(new, 0, sizeof(struct btree_node));
+	if (node->item[BTREE_ITEM_HALF].child) {
+delete_one:
+		for (j = 0; j < i; j++)
+			new->item[j] = node->item[j];
+		for (j++; j < BTREE_ITEM_MAX; j++)
+			new->item[j-1] = node->item[j];
+
+		if (update)
+			btree_item_flip(root, &new->item[i-1], update);
+
+		btree_item_free(root, &node->item[i]);
+
+		*nodep = new;
+		goto done;
+	}
+
+	/* delete underflows */
+
+	/* borrow left */
+	if (*leftp && (*leftp)->item[BTREE_ITEM_HALF].child) {
+		struct btree_node *new_left;
+
+		new_left = mempool_alloc(root->mempool, root->gfp_mask);
+		memset(new_left, 0, sizeof(struct btree_node));
+
+		for (j = 0; j < BTREE_ITEM_MAX && (*leftp)->item[j].child; j++)
+			;
+		n = (j-BTREE_ITEM_HALF+1)/2;
+
+		for (k = 0; k < j-n; k++)
+			new_left->item[k] = (*leftp)->item[k];
+		for (j = 0; j < n; j++)
+			new->item[j] = (*leftp)->item[k+j];
+		for (j = 0; j < i; j++)
+			new->item[n+j] = node->item[j];
+		for (j++; j < BTREE_ITEM_HALF; j++)
+			new->item[n+j-1] = node->item[j];
+
+		if (update)
+			btree_item_flip(root, &new->item[n+i-1], update);
+
+		btree_item_free(root, &node->item[i]);
+
+		*leftp = new_left;
+		*nodep = new;
+		goto done;
+	}
+
+	/* borrow right */
+	if (*rightp && (*rightp)->item[BTREE_ITEM_HALF].child) {
+		struct btree_node *new_right;
+
+		new_right = mempool_alloc(root->mempool, root->gfp_mask);
+		memset(new_right, 0, sizeof(struct btree_node));
+
+		for (j = 0; j < BTREE_ITEM_MAX && (*rightp)->item[j].child ; j++)
+			;
+		n = (j-BTREE_ITEM_HALF+1)/2;
+
+		for (k = 0; k < i; k++)
+			new->item[k] = node->item[k];
+		for (k++; k < BTREE_ITEM_HALF; k++)
+			new->item[k-1] = node->item[k];
+		for (j = 0; j < n; j++)
+			new->item[k-1+j] = (*rightp)->item[j];
+		for (; j < BTREE_ITEM_MAX; j++)
+			new_right->item[j-n] = (*rightp)->item[j];
+
+		if (update)
+			btree_item_flip(root, &new->item[i-1], update);
+
+		btree_item_free(root, &node->item[i]);
+
+		*nodep = new;
+		*rightp = new_right;
+		goto done;
+	}
+
+	/* merge left */
+	if (*leftp) {
+		for (j = 0; j < BTREE_ITEM_HALF; j++)
+			new->item[j] = (*leftp)->item[j];
+		for (k = 0; k < i; k++)
+			new->item[j+k] = node->item[k];
+		for (k++; k < BTREE_ITEM_HALF; k++)
+			new->item[j+k-1] = node->item[k];
+
+		if (update)
+			btree_item_flip(root, &new->item[j+i-1], update);
+
+		btree_item_free(root, &node->item[i]);
+
+		*leftp = new;
+		*nodep = NULL;
+		goto done;
+	}
+
+	/* merge right */
+	if (*rightp) {
+		for (j = 0; j < i; j++)
+			new->item[j] = node->item[j];
+		for (j++; node->item[j].child; j++)
+			new->item[j-1] = node->item[j];
+		for (k = 0; (*rightp)->item[k].child; k++)
+			new->item[j-1+k] = (*rightp)->item[k];
+
+		if (update)
+			btree_item_flip(root, &new->item[i-1], update);
+
+		btree_item_free(root, &node->item[i]);
+
+		*nodep = new;
+		*rightp = NULL;
+		goto done;
+	}
+
+	/* only the root may underflow */
+	BUG_ON(root->root != node);
+	goto delete_one;
+
+done:
+	return ret;
+}
+
+void *btree_remove(struct btree_root *root, unsigned long index)
+{
+	void *ret = NULL;
+	int err = btree_mod_init(root);
+	if (err)
+		return ERR_PTR(err);
+
+	if (root->root) {
+		struct btree_node *left = NULL, *right = NULL;
+		struct btree_node *node = root->root;
+
+		ret = __btree_remove(root,
+				&left, &node, &right,
+				index, root->height - 1);
+
+		if (node != root->root) {
+			btree_ptr_flip(root, &root->root, node);
+		}
+
+		if (!root->root->item[1].child &&
+				!btree_item_leaf(&root->root->item[0])) {
+			root->height--;
+			btree_ptr_flip(root, &root->root,
+					btree_item_deref(&root->root->item[0]));
+		}
+
+		if (!root->root->item[0].child) {
+			btree_ptr_flip(root, &root->root, NULL);
+			root->height = 0;
+		}
+	}
+
+	btree_mod_finish(root, index);
+	return ret;
+}
+
+/* ------ */
+
+void btree_root_init(struct btree_root *root, gfp_t gfp_mask)
+{
+	*root = BTREE_INIT(gfp_mask);
+}
+
+void btree_freevec_flush(struct btree_freevec *freevec)
+{
+	int i;
+	for (i = 0; i < freevec->pos; i++)
+		kmem_cache_free(btree_cachep, freevec->slot[i]);
+	kfree(freevec);
+}
+
+void btree_root_destroy(struct btree_root *root)
+{
+	/* assume the tree is empty */
+	BUG_ON(root->height);
+	BUG_ON(root->freevec);
+	if (root->mempool)
+		mempool_destroy(root->mempool);
+}
+
+void __init btree_init(void)
+{
+	btree_cachep = kmem_cache_create("btree_node",
+			sizeof(struct btree_node),
+			0, SLAB_HWCACHE_ALIGN,
+			NULL, NULL);
+}
+
+#ifdef BTREE_DEBUG
+static void __btree_node_print(struct btree_root *root,
+		struct btree_node *node, int recurse)
+{
+	int i, j;
+	for (i = 0; i < BTREE_ITEM_MAX; i++) {
+		if (node->item[i].child) {
+			printk(KERN_DEBUG);
+			for (j=0; j<recurse; j++)
+				printk(" ");
+			if (btree_item_leaf(&node->item[i])) {
+
+	printk("-> leaf: %p, item: %d, key: %lu, data: %p\n",
+		node, i, node->item[i].key, node->item[i].data);
+
+			} else {
+
+	printk("node: %p, item: %d, key: %lu, child: %p\n",
+		node, i, node->item[i].key, btree_item_deref(&node->item[i]));
+				if (recurse)
+	__btree_node_print(root, btree_item_deref(&node->item[i]), recurse+1);
+
+			}
+		}
+	}
+}
+
+void btree_node_print(struct btree_root *root, struct btree_node *node)
+{
+	printk(KERN_DEBUG "node: %p\n", node);
+	__btree_node_print(root, node, 0);
+}
+
+void btree_print(struct btree_root *root)
+{
+	printk(KERN_DEBUG "[] root: %p, height: %d\n",
+			root->root, root->height);
+	if (root->root)
+		__btree_node_print(root, root->root, 1);
+}
+
+static unsigned long __btree_key(struct btree_root *root,
+	       	struct btree_node *node, int height)
+{
+	if (height == 0)
+		return node->item[0].key;
+
+	return __btree_key(root, btree_item_deref(&node->item[0]), height - 1);
+}
+
+static int __btree_validate(struct btree_root *root, struct btree_node *node,
+		unsigned long *pindex, int height)
+{
+	unsigned long parent_key = *pindex;
+	unsigned long node_key = 0;
+	unsigned long child_key = 0;
+
+	int i;
+	unsigned long key;
+	int nr = 0;
+	int bug = 0;
+
+	for (i = 0; i < BTREE_ITEM_MAX; i++) {
+		struct btree_node *child = btree_item_deref(&node->item[i]);
+		if (!child)
+			continue;
+
+		nr++;
+
+		key = node->item[i].key;
+		if (key < parent_key || (!i && key != parent_key) ||
+				(i && key == parent_key)) {
+			printk(KERN_DEBUG
+	"wrong parent split: key: %lu parent_key: %lu index: %d\n",
+				       key, parent_key, i);
+			bug++;
+		}
+
+		if (key < node_key || (i && key == node_key)) {
+			printk(KERN_DEBUG
+	"wrong order: key: %lu node_key: %lu index: %d\n",
+				       key, node_key, i);
+			bug++;
+		}
+		node_key = key;
+
+		if (key < child_key || (i && key == child_key)) {
+			printk(KERN_DEBUG
+	"wrong child split: key: %lu child_key: %lu index: %d\n",
+					key, child_key, i);
+			bug++;
+		}
+
+		child_key = max(node_key, child_key);
+
+		if (height)
+			bug += __btree_validate(root, child,
+					&child_key, height - 1);
+
+		*pindex = max(node_key, child_key);
+	}
+
+	if (node != root->root && nr < BTREE_ITEM_HALF) {
+		printk(KERN_DEBUG "node short\n");
+		bug++;
+	}
+
+	if (bug) {
+		printk(KERN_DEBUG "bug in node: %p\n", node);
+	}
+
+	return bug;
+}
+
+int btree_validate(struct btree_root *root)
+{
+	unsigned long key;
+
+	if (root->root) {
+		key = __btree_key(root, root->root, root->height - 1);
+		return __btree_validate(root, root->root, &key,
+				root->height - 1);
+	}
+
+	return 0;
+}
+#endif

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
