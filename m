Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp01.au.ibm.com (8.13.1/8.13.1) with ESMTP id l9MAkdF2000933
	for <linux-mm@kvack.org>; Mon, 22 Oct 2007 20:46:39 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9MAlQOe215970
	for <linux-mm@kvack.org>; Mon, 22 Oct 2007 20:47:26 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9MAhZgt002771
	for <linux-mm@kvack.org>; Mon, 22 Oct 2007 20:43:35 +1000
Message-Id: <20071022104530.595611021@linux.vnet.ibm.com>>
References: <20071022104518.985992030@linux.vnet.ibm.com>>
Date: Mon, 22 Oct 2007 16:15:21 +0530
From: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
Subject: [PATCH/RFC 2/9] lib: RCU friendly B+tree
Content-Disposition: inline; filename=2_btree.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Alexis Bruemmer <alexisb@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Introduce an RCU friendly B+tree in lib

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/btree.h |  151 ++++++
 init/main.c           |    2 
 lib/Makefile          |    3 
 lib/btree.c           | 1189 ++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 1344 insertions(+), 1 deletion(-)

--- /dev/null
+++ linux-2.6.23-rc6/include/linux/btree.h
@@ -0,0 +1,151 @@
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
+	void *data;
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
+ * Max depth of the tree.
+ * Assumes BTREE_ITEM_MAX is power of two.
+ */
+#define BTREE_MAX_DEPTH \
+	(1 + DIV_ROUND_UP(BITS_PER_LONG, ilog2(BTREE_ITEM_MAX)))
+
+/*
+ * Max number of nodes to be RCUed per modification.
+ */
+#define BTREE_NODE_REPLACE (2 * BTREE_MAX_DEPTH)
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
+static inline void *btree_item_deref(struct btree_item *itemp)
+{
+	void *ptr = rcu_dereference(itemp->data);
+	__clear_bit(0, (void *)&ptr);
+	return ptr;
+}
+
+static inline unsigned long btree_item_key(struct btree_item *itemp)
+{
+	unsigned long key = itemp->key;
+	/*
+	 * match the smp_wmb() in btree_item_key_set()
+	 */
+	smp_rmb();
+	return key;
+}
+
+extern struct btree_item *btree_search_next(struct btree_root *root,
+		unsigned long index, struct btree_item **nextp);
+
+static inline void *btree_lookup(struct btree_root *root, unsigned long index)
+{
+	struct btree_item *item;
+
+	item = btree_search_next(root, index, NULL);
+	if (!item || btree_item_key(item) != index)
+		return NULL;
+
+	return item->data;
+}
+
+static inline void *btree_lookup_next(struct btree_root *root,
+		unsigned long index, void **nextp)
+{
+	struct btree_item *next = NULL, *item;
+
+	item = btree_search_next(root, index, &next);
+	if (next)
+		*nextp = next->data;
+	if (!item || btree_item_key(item) != index)
+		return NULL;
+
+	return item->data;
+}
+
+static inline void *btree_stab(struct btree_root *root, unsigned long index)
+{
+	struct btree_item *item;
+
+	item = btree_search_next(root, index, NULL);
+	if (!item)
+		return NULL;
+
+	return item->data;
+}
+
+static inline void *btree_stab_next(struct btree_root *root,
+		unsigned long index, void **nextp)
+{
+	struct btree_item *next = NULL, *item;
+
+	item = btree_search_next(root, index, &next);
+	if (next)
+		*nextp = next->data;
+	if (!item)
+		return NULL;
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
--- linux-2.6.23-rc6.orig/init/main.c
+++ linux-2.6.23-rc6/init/main.c
@@ -55,6 +55,7 @@
 #include <linux/pid_namespace.h>
 #include <linux/device.h>
 #include <linux/kthread.h>
+#include <linux/btree.h>
 
 #include <asm/io.h>
 #include <asm/bugs.h>
@@ -613,6 +614,7 @@ asmlinkage void __init start_kernel(void
 	cpuset_init_early();
 	mem_init();
 	kmem_cache_init();
+	btree_init();
 	setup_per_cpu_pageset();
 	numa_policy_init();
 	if (late_time_init)
--- linux-2.6.23-rc6.orig/lib/Makefile
+++ linux-2.6.23-rc6/lib/Makefile
@@ -5,7 +5,8 @@
 lib-y := ctype.o string.o vsprintf.o kasprintf.o cmdline.o \
 	 rbtree.o radix-tree.o dump_stack.o \
 	 idr.o int_sqrt.o bitmap.o extable.o prio_tree.o \
-	 sha1.o irq_regs.o reciprocal_div.o argv_split.o
+	 sha1.o irq_regs.o reciprocal_div.o argv_split.o \
+	 btree.o
 
 lib-$(CONFIG_MMU) += ioremap.o
 lib-$(CONFIG_SMP) += cpumask.o
--- /dev/null
+++ linux-2.6.23-rc6/lib/btree.c
@@ -0,0 +1,1189 @@
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
+		void **nodep, void *new)
+{
+	void *old = rcu_dereference(*nodep);
+	rcu_assign_pointer(*nodep, new);
+	__clear_bit(0, (void *)&old);
+	btree_free(root, old);
+}
+
+/*
+ * node pointers have bit 0 set.
+ */
+static inline int btree_item_node(struct btree_item *itemp)
+{
+	return test_bit(0, (void *)&itemp->data);
+}
+
+static inline struct btree_node *btree_node_ptr(struct btree_node *nodep)
+{
+	__set_bit(0, (void *)&nodep);
+	return nodep;
+}
+
+static inline void btree_item_key_set(struct btree_item *itemp,
+		unsigned long index)
+{
+	/*
+	 * we can only tighten when the new node is linked in
+	 */
+	smp_wmb();
+	itemp->key = index;
+}
+
+static void btree_item_flip(struct btree_root *root,
+		struct btree_item *itemp, struct btree_node *new)
+{
+	unsigned long index;
+
+	btree_ptr_flip(root, &itemp->data, btree_node_ptr(new));
+
+	/* possibly tighten */
+	index = btree_item_key(&new->item[0]);
+	if (btree_item_key(itemp) != index)
+		btree_item_key_set(itemp, index);
+}
+
+static inline void btree_item_copy(void *dst, void *src, int nr)
+{
+	memcpy(dst, src, nr*sizeof(struct btree_item));
+}
+
+static inline int btree_item_count(struct btree_node *node)
+{
+	int j;
+
+	for (j = 0; j < BTREE_ITEM_MAX &&
+			node->item[j].data ; j++)
+		;
+
+	return j;
+}
+
+static struct btree_node *btree_node_alloc(struct btree_root *root)
+{
+	struct btree_node *node;
+
+	node = mempool_alloc(root->mempool, root->gfp_mask);
+	memset(node, 0, sizeof(struct btree_node));
+
+	return node;
+}
+
+static inline void btree_item_free(struct btree_root *root,
+		struct btree_item *itemp)
+{
+	if (btree_item_node(itemp))
+		btree_free(root, btree_item_deref(itemp));
+}
+
+/*
+ * node storage; expose interface to claim all the needed memory in advance
+ * this avoids getting stuck in a situation where going bad is as impossible
+ * as going forward.
+ */
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
+static int btree_mod_finish(struct btree_root *root, unsigned long index,
+		char *op)
+{
+	int ret = 0;
+	if (root->mempool)
+		ret = mempool_resize(root->mempool, 1, root->gfp_mask);
+
+	if (btree_validate(root)) {
+		printk(KERN_DEBUG "modified(%s): %lu\n", op, index);
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
+/*
+ * stack, to store traversal path.
+ */
+struct btree_path {
+	struct btree_node *node;
+	int offset;
+};
+
+struct btree_stack {
+	int p;
+	struct btree_path path[BTREE_MAX_DEPTH];
+};
+
+static inline void btree_stack_init(struct btree_stack *stack)
+{
+	memset(stack, 0, sizeof(*stack));
+}
+
+static inline void btree_stack_push(struct btree_stack *stack,
+		struct btree_node *node, int offset)
+{
+	stack->path[stack->p].node = node;
+	stack->path[stack->p].offset = offset;
+	stack->p++;
+
+	BUG_ON(stack->p > ARRAY_SIZE(stack->path));
+}
+
+static inline void btree_stack_pop(struct btree_stack *stack,
+		struct btree_node **nodep, int *offsetp)
+{
+	stack->p--;
+	*nodep = stack->path[stack->p].node;
+	*offsetp = stack->path[stack->p].offset;
+
+	BUG_ON(stack->p < 0);
+}
+
+static inline int btree_stack_size(struct btree_stack *stack)
+{
+	return stack->p;
+}
+
+static struct btree_node *btree_stack_peek_left(struct btree_stack *stack)
+{
+	struct btree_node *node;
+	struct btree_item *item;
+	int offset;
+
+	if (!btree_stack_size(stack))
+		return NULL;
+
+	node = stack->path[stack->p - 1].node;
+	offset = stack->path[stack->p - 1].offset;
+
+	if (offset == 0)
+		return NULL;
+
+	offset--;
+	item = &node->item[offset];
+	return btree_item_deref(item);
+}
+
+static struct btree_node *btree_stack_peek_right(struct btree_stack *stack)
+{
+	struct btree_node *node;
+	struct btree_item *item;
+	int offset;
+
+	if (!btree_stack_size(stack))
+		return NULL;
+
+	node = stack->path[stack->p - 1].node;
+	offset = stack->path[stack->p - 1].offset;
+
+	offset++;
+	if (offset == BTREE_ITEM_MAX)
+		return NULL;
+
+	item = &node->item[offset];
+	return btree_item_deref(item);
+}
+
+/* ------ search ------- */
+
+/*
+ * Since we can re-adjust the space partitioning in delete and update a
+ * lockless lookup might hit a wrong branch once in a while, hence we might
+ * need to backtrack.
+ *
+ * Because we do a search for a less than or equal index we can only backtrack
+ * to the left. So the split can be off to the left but never to the right.
+ * Hence we need to move splits left on descend and right on ascend of the
+ * tree. See update and remove.
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
+
+	for (i = 1; i < BTREE_ITEM_MAX; i++)
+		if (node->item[i].data == NULL ||
+				index < btree_item_key(&node->item[i]))
+			break;
+	i--;
+	return i;
+}
+
+/*
+ * find item and the path to it.
+ */
+static struct btree_item *__btree_search(struct btree_root *root,
+		struct btree_stack *stack, unsigned long index)
+{
+	struct btree_node *node = rcu_dereference(root->root);
+	struct btree_item *item;
+	int offset;
+
+	btree_stack_init(stack);
+
+	if (!node)
+		return NULL;
+
+	do {
+		/*
+		 * if the split was too low, back-track and take the previous
+		 * branch
+		 */
+		if (unlikely(btree_item_key(&node->item[0]) > index)) {
+			if (!btree_stack_size(stack))
+				return NULL;
+
+			do {
+				btree_stack_pop(stack, &node, &offset);
+			} while (btree_stack_size(stack) && offset == 0);
+
+			if (!btree_stack_size(stack) && offset == 0)
+				return NULL;
+
+			offset--;
+		} else
+			offset = __btree_item_search(root, node, index);
+
+		btree_stack_push(stack, node, offset);
+
+		item = &node->item[offset];
+		if (!btree_item_node(item))
+			break;
+
+		node = btree_item_deref(item);
+	} while (node);
+
+	return item;
+}
+
+/*
+ * find the left-most item in a sub-tree, and the path to it.
+ */
+static struct btree_item *__btree_find_first(struct btree_root *root,
+		struct btree_stack *stack, struct btree_node *node, int offset)
+{
+	struct btree_item *item;
+
+	do {
+		btree_stack_push(stack, node, offset);
+
+		item = &node->item[offset];
+		if (!btree_item_node(item))
+			break;
+
+		node = btree_item_deref(item);
+		offset = 0;
+	} while (node);
+
+	return item;
+}
+
+/*
+ * find the item with a lesser or equal index
+ * and optionally the next item.
+ */
+struct btree_item *btree_search_next(struct btree_root *root,
+		unsigned long index, struct btree_item **nextp)
+{
+	struct btree_stack stack;
+	struct btree_node *node;
+	struct btree_item *item, *next;
+	int offset;
+
+	item = __btree_search(root, &stack, index);
+
+	if (item && nextp) {
+		do {
+			btree_stack_pop(&stack, &node, &offset);
+		} while (btree_stack_size(&stack) &&
+				offset == BTREE_ITEM_MAX-1);
+
+		if (offset != BTREE_ITEM_MAX-1) {
+			offset++;
+			next = __btree_find_first(root, &stack, node, offset);
+		} else
+			next = NULL;
+
+		*nextp = next;
+	} else if (nextp) {
+		node = rcu_dereference(root->root);
+		offset = 0;
+
+		if (node) {
+			next = __btree_find_first(root, &stack, node, offset);
+			*nextp = next;
+		}
+	}
+
+	return item;
+}
+
+/* ------ insert ------- */
+
+/*
+ * insert item; split nodes when needed
+ */
+int btree_insert(struct btree_root *root,
+		unsigned long index, void *data)
+{
+	struct btree_stack stack;
+	struct btree_node *node = NULL,
+			  *old_node,
+			  *update,
+			  *new = NULL,
+			  *split = NULL,
+			  *uleft,
+			  *uright,
+			  *left = NULL,
+			  *right = NULL;
+	struct btree_item *item;
+	struct btree_item nitem = {
+		.key = index,
+		.data = data,
+	};
+	unsigned long key;
+	int i, j, n, ret = 0;
+
+	ret = btree_mod_init(root);
+	if (ret)
+		return ret;
+
+	item = __btree_search(root, &stack, index);
+	if (!item) {
+		if (!root->root) {
+			root->root = btree_node_alloc(root);
+			root->height = 1;
+			btree_stack_push(&stack, root->root, 0);
+		} else
+			__btree_find_first(root, &stack, root->root, 0);
+	} else if (btree_item_key(item) == index) {
+		ret = -EEXIST;
+		goto out;
+	}
+
+	do {
+		old_node = node;
+		btree_stack_pop(&stack, &node, &i);
+		item = &node->item[i];
+
+		update = NULL;
+		if (btree_item_node(item)) {
+			/* no change */
+			if (!new && !split && !left && !right) {
+				BUG_ON(btree_item_deref(item) != old_node);
+
+				/* possibly tighten the split on our way back up  */
+				key = btree_item_key(&old_node->item[0]);
+				if (btree_item_key(item) != key)
+					btree_item_key_set(item, key);
+				continue;
+			}
+
+			/* single change */
+			if (new && !split && !left && !right) {
+				btree_item_flip(root, item, new);
+				new = NULL;
+				continue;
+			}
+
+			/* merge left */
+			if (new && !split && left && !right) {
+				update = btree_node_alloc(root);
+				btree_item_copy(update->item, node->item,
+						BTREE_ITEM_MAX);
+				update->item[i-1] = (struct btree_item){
+					.key = btree_item_key(&left->item[0]),
+					.data = btree_node_ptr(left),
+				};
+				update->item[i] = (struct btree_item){
+					.key = btree_item_key(&new->item[0]),
+					.data = btree_node_ptr(new),
+				};
+				btree_item_free(root, &node->item[i-1]);
+				btree_item_free(root, &node->item[i]);
+
+				left = NULL;
+				new = update;
+				continue;
+			}
+
+			/* merge right */
+			if (new && !split && !left && right) {
+				update = btree_node_alloc(root);
+				btree_item_copy(update->item, node->item,
+						BTREE_ITEM_MAX);
+				update->item[i] = (struct btree_item){
+					.key = btree_item_key(&new->item[0]),
+					.data = btree_node_ptr(new),
+				};
+				update->item[i+1] = (struct btree_item){
+					.key = btree_item_key(&right->item[0]),
+					.data = btree_node_ptr(right),
+				};
+				btree_item_free(root, &node->item[i]);
+				btree_item_free(root, &node->item[i+1]);
+
+				new = update;
+				right = NULL;
+				continue;
+			}
+
+			/* split */
+			BUG_ON(left || right);
+			update = new;
+		}
+
+		if (btree_item_deref(item) &&
+				btree_item_key(item) < nitem.key)
+			i++;
+
+		split = NULL;
+		left = NULL;
+		right = NULL;
+		new = btree_node_alloc(root);
+		/* insert has room */
+		if (node->item[BTREE_ITEM_MAX-1].data == NULL) {
+			btree_item_copy(new->item, node->item, i);
+			new->item[i] = nitem;
+			btree_item_copy(new->item + i + 1, node->item + i,
+					BTREE_ITEM_MAX - i - 1);
+
+			if (update)
+				btree_item_flip(root, &new->item[i-1], update);
+
+			continue;
+		}
+
+#if 0	/* there be dragons here ! */
+
+		/* insert overflows */
+
+		/* see if left sibling will take some overflow */
+		uleft = btree_stack_peek_left(&stack);
+		if (uleft && uleft->item[BTREE_ITEM_MAX-1].data == NULL) {
+
+			j = btree_item_count(uleft);
+			n = (BTREE_ITEM_MAX - j + 1)/2;
+
+			left = btree_node_alloc(root);
+			/*
+			 * LLLLl... CCCCcccc
+			 * LLLLlC.. CCCcc*cc
+			 */
+			btree_item_copy(left->item, uleft->item, j);
+			if (i < n) {
+				btree_item_copy(left->item+j, node->item, i);
+				left->item[j+i] = nitem;
+				btree_item_copy(left->item+j+i+1, node->item+i,
+						n-i);
+				btree_item_copy(new->item, node->item+n,
+						BTREE_ITEM_MAX-n);
+			} else {
+				btree_item_copy(left->item+j, node->item, n);
+				btree_item_copy(new->item, node->item+n, i-n);
+				new->item[i-n] = nitem;
+				btree_item_copy(new->item+i-n+1, node->item+i,
+						BTREE_ITEM_MAX-i);
+			}
+
+			if (update) {
+				if (i-1 < n)
+					btree_item_flip(root,
+							&left->item[j+i-1],
+							update);
+				else
+					btree_item_flip(root, &new->item[i-n-1],
+							update);
+			}
+
+			continue;
+		}
+
+		/* see if right sibling will take some overflow */
+		uright = btree_stack_peek_right(&stack);
+		if (uright && uright->item[BTREE_ITEM_MAX-1].data == NULL) {
+
+			j = btree_item_count(uright);
+			n = (BTREE_ITEM_MAX - j + 1)/2;
+
+			right = btree_node_alloc(root);
+			/*
+			 * CCCCcccc RRRR....
+			 * CCCC*cc. ccRRRR..
+			 */
+			if (i <= BTREE_ITEM_MAX-n) {
+				btree_item_copy(new->item, node->item, i);
+				new->item[i] = nitem;
+				btree_item_copy(new->item+i+1, node->item+i,
+						BTREE_ITEM_MAX-n-i);
+				btree_item_copy(right->item,
+						node->item+BTREE_ITEM_MAX-n, n);
+				btree_item_copy(right->item+n, uright->item, j);
+			} else {
+				btree_item_copy(new->item, node->item,
+					       	BTREE_ITEM_MAX-n);
+
+				btree_item_copy(right->item,
+						node->item+(BTREE_ITEM_MAX-n),
+						i-(BTREE_ITEM_MAX-n));
+				right->item[i-(BTREE_ITEM_MAX-n)] = nitem;
+				btree_item_copy(right->item+i-(BTREE_ITEM_MAX-n)+1,
+						node->item+i, BTREE_ITEM_MAX-i);
+				btree_item_copy(right->item+n+1, uright->item,
+						j);
+			}
+
+			if (update) {
+				if (i-1 <= BTREE_ITEM_MAX-n)
+					btree_item_flip(root, &new->item[i-1],
+							update);
+				else
+					btree_item_flip(root,
+						&right->item[i-1-BTREE_ITEM_MAX-n],
+							update);
+			}
+
+			continue;
+		}
+#endif
+
+		/* split node */
+		split = btree_node_alloc(root);
+		if (i < BTREE_ITEM_HALF) {
+			btree_item_copy(new->item, node->item, i);
+			new->item[i] = nitem;
+			btree_item_copy(new->item + i + 1, node->item + i,
+					BTREE_ITEM_HALF - i);
+			btree_item_copy(split->item,
+					node->item + BTREE_ITEM_HALF,
+					BTREE_ITEM_HALF);
+		} else {
+			btree_item_copy(new->item, node->item,
+					BTREE_ITEM_HALF);
+			btree_item_copy(split->item,
+					node->item + BTREE_ITEM_HALF,
+					i - BTREE_ITEM_HALF);
+			split->item[i - BTREE_ITEM_HALF] = nitem;
+			btree_item_copy(split->item + i - BTREE_ITEM_HALF + 1,
+					node->item + i,
+					BTREE_ITEM_MAX - i);
+		}
+
+		if (update) {
+			if (i-1 < BTREE_ITEM_HALF)
+				btree_item_flip(root, &new->item[i-1], update);
+			else
+				btree_item_flip(root,
+					&split->item[i-1-BTREE_ITEM_HALF],
+						update);
+		}
+
+		nitem.key = split->item[0].key;
+		nitem.data = btree_node_ptr(split);
+	} while (btree_stack_size(&stack));
+
+	if (new) {
+		if (!split) {
+			btree_ptr_flip(root, (void **)&root->root, new);
+		} else {
+			update = btree_node_alloc(root);
+			update->item[0] = (struct btree_item){
+				.key = new->item[0].key,
+				.data = btree_node_ptr(new),
+			};
+			update->item[1] = (struct btree_item){
+				.key = split->item[0].key,
+				.data = btree_node_ptr(split),
+			};
+			btree_ptr_flip(root, (void **)&root->root, update);
+			root->height++;
+		}
+	}
+
+out:
+	btree_mod_finish(root, index, "insert");
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
+ * _MUST_ be free, otherwise remove and re-insert.
+ *
+ * see the search comment for lockless lookup constraints
+ */
+int btree_update(struct btree_root *root,
+		unsigned long index, unsigned long new_index)
+{
+	struct btree_stack stack;
+	struct btree_node *node = rcu_dereference(root->root);
+	struct btree_item *item;
+	unsigned long key;
+	int offset, ret = 0;
+
+	if (index == new_index)
+		return 0;
+
+	if (!node)
+		return -EINVAL;
+
+	btree_stack_init(&stack);
+
+	do {
+		offset = __btree_item_search(root, node, index);
+		btree_stack_push(&stack, node, offset);
+		item = &node->item[offset];
+		if (btree_item_node(item)) {
+			/* loosen downwards */
+			if (index > new_index && btree_item_key(item) == index)
+				btree_item_key_set(item, new_index);
+			node = btree_item_deref(item);
+		} else
+			node = NULL;
+	} while (node);
+
+	if (btree_item_key(item) == index)
+		btree_item_key_set(item, new_index);
+	else
+		ret = -EINVAL;
+
+	do {
+		btree_stack_pop(&stack, &node, &offset);
+		item = &node->item[offset];
+		if (!btree_item_node(item))
+			continue;
+
+		key = btree_item_key(item);
+		/* undo on error */
+		if (ret && index > new_index && key == new_index)
+			btree_item_key_set(item, index);
+		/* tighten upwards */
+		if (!ret && index < new_index && key == index)
+			btree_item_key_set(item, new_index);
+	} while (btree_stack_size(&stack));
+
+	if (btree_validate(root)) {
+		printk(KERN_DEBUG "btree_update: index: %lu new_index: %lu\n",
+				index, new_index);
+		btree_print(root);
+		BUG();
+	}
+
+	return 0;
+}
+
+/* ------ delete ------- */
+
+/*
+ * delete an item; borrow items or merge nodes when needed.
+ */
+void *btree_remove(struct btree_root *root, unsigned long index)
+{
+	struct btree_stack stack;
+	struct btree_node *node = NULL,
+			  *old_node,
+			  *left = NULL,
+			  *new = NULL,
+			  *right = NULL,
+			  *update,
+			  *uleft,
+			  *uright;
+	struct btree_item *item;
+	void *ret = NULL;
+	unsigned long key;
+	int i, j, n;
+	int err;
+
+	if (!root->root)
+		return ERR_PTR(-EINVAL);
+
+	err = btree_mod_init(root);
+	if (err)
+		return ERR_PTR(err);
+
+	item = __btree_search(root, &stack, index);
+	if (!item || btree_item_key(item) != index) {
+		ret = ERR_PTR(-EINVAL);
+		goto out;
+	} else
+		ret = item->data;
+
+	do {
+		old_node = node;
+		btree_stack_pop(&stack, &node, &i);
+		item = &node->item[i];
+
+		update = NULL;
+		if (btree_item_node(item)) {
+			/* no change */
+			if (!new && !left && !right) {
+				BUG_ON(btree_item_deref(item) != old_node);
+
+				/* tighten the split on our way back up */
+				key = btree_item_key(&old_node->item[0]);
+				if (btree_item_key(item) != key)
+					btree_item_key_set(item, key);
+				continue;
+			}
+
+			/* single change */
+			if (!left && new && !right) {
+				btree_item_flip(root, &node->item[i], new);
+				new = NULL;
+				continue;
+			}
+
+			/* borrowed left */
+			if (left && new && !right) {
+				update = btree_node_alloc(root);
+				btree_item_copy(update->item, node->item,
+						BTREE_ITEM_MAX);
+				update->item[i-1] = (struct btree_item){
+					.key = btree_item_key(&left->item[0]),
+					.data = btree_node_ptr(left),
+				};
+				update->item[i] = (struct btree_item){
+					.key = btree_item_key(&new->item[0]),
+					.data = btree_node_ptr(new),
+				};
+				btree_item_free(root, &node->item[i-1]);
+				btree_item_free(root, &node->item[i]);
+
+				left = NULL;
+				new = update;
+				continue;
+			}
+
+			/* borrowed right */
+			if (!left && new && right) {
+				update = btree_node_alloc(root);
+				btree_item_copy(update->item, node->item,
+						BTREE_ITEM_MAX);
+				update->item[i] = (struct btree_item){
+					.key = btree_item_key(&new->item[0]),
+					.data = btree_node_ptr(new),
+				};
+				update->item[i+1] = (struct btree_item){
+					.key = btree_item_key(&right->item[0]),
+					.data = btree_node_ptr(right),
+				};
+				btree_item_free(root, &node->item[i]);
+				btree_item_free(root, &node->item[i+1]);
+
+				new = update;
+				right = NULL;
+				continue;
+			}
+
+			/* merged left */
+			if (left && !new && !right) {
+				update = left;
+			}
+			/* merged right */
+			else if (!left && !new && right) {
+				update = right;
+				i++;
+			}
+			/* impossible */
+			else {
+				printk("%p %p %p\n", left, new, right);
+				BUG();
+			}
+		}
+
+		/* delete */
+		left = NULL;
+		right = NULL;
+		new = btree_node_alloc(root);
+		if (node->item[BTREE_ITEM_HALF].data) {
+delete_one:
+			/*
+			 * CCCxcc..
+			 * CCCcc...
+			 */
+			btree_item_copy(new->item, node->item, i);
+			btree_item_copy(new->item+i, node->item+i+1,
+					BTREE_ITEM_MAX-i-1);
+
+			if (update)
+				btree_item_flip(root, &new->item[i-1], update);
+
+			btree_item_free(root, &node->item[i]);
+			continue;
+		}
+
+		/* delete underflows */
+
+		/* borrow left */
+		uleft = btree_stack_peek_left(&stack);
+		if (uleft && uleft->item[BTREE_ITEM_HALF].data) {
+			left = btree_node_alloc(root);
+
+			j = btree_item_count(uleft);
+			n = (j-BTREE_ITEM_HALF+1)/2;
+
+			/*
+			 * LLLLlll. CxCC....
+			 * LLLLl... llCCC...
+			 */
+			btree_item_copy(left->item, uleft->item, (j-n));
+			btree_item_copy(new->item, uleft->item+(j-n), n);
+			btree_item_copy(new->item+n, node->item, i);
+			btree_item_copy(new->item+n+i, node->item+i+1,
+					BTREE_ITEM_HALF-i);
+
+			if (update)
+				btree_item_flip(root, &new->item[n+i-1],
+						update);
+
+			btree_item_free(root, &node->item[i]);
+
+			continue;
+		}
+
+		/* borrow right */
+		uright = btree_stack_peek_right(&stack);
+		if (uright && uright->item[BTREE_ITEM_HALF].data) {
+			right = btree_node_alloc(root);
+
+			j = btree_item_count(uright);
+			n = (j-BTREE_ITEM_HALF+1)/2;
+
+			/*
+			 * CCxC.... RRRRrrr.
+			 * CCCRR... RRrrr...
+			 */
+			btree_item_copy(new->item, node->item, i);
+			btree_item_copy(new->item+i, node->item+i+1,
+					BTREE_ITEM_HALF-i-1);
+			btree_item_copy(new->item+BTREE_ITEM_HALF-1,
+					uright->item, n);
+			btree_item_copy(right->item, uright->item+n,
+					BTREE_ITEM_MAX-n);
+
+			if (update)
+				btree_item_flip(root, &new->item[i-1], update);
+
+			btree_item_free(root, &node->item[i]);
+
+			continue;
+		}
+
+		/* merge left */
+		if (uleft) {
+			/*
+			 * LLLL.... CCCxc...
+			 * LLLLCCCc
+			 */
+			btree_item_copy(new->item, uleft->item,
+					BTREE_ITEM_HALF);
+			btree_item_copy(new->item+BTREE_ITEM_HALF,
+					node->item, i);
+			btree_item_copy(new->item+BTREE_ITEM_HALF+i,
+				       	node->item+i+1, BTREE_ITEM_HALF-i-1);
+
+			if (update)
+				btree_item_flip(root,
+						&new->item[BTREE_ITEM_HALF+i-1],
+						update);
+
+			btree_item_free(root, &node->item[i]);
+
+			left = new;
+			new = NULL;
+			continue;
+		}
+
+		/* merge right */
+		if (uright) {
+			/*
+			 * CCxCc... RRRR....
+			 * CCCcRRRR
+			 */
+			btree_item_copy(new->item, node->item, i);
+			btree_item_copy(new->item+i, node->item+i+1,
+					BTREE_ITEM_HALF-i-1);
+			btree_item_copy(new->item+BTREE_ITEM_HALF-1,
+				       	uright->item, BTREE_ITEM_HALF);
+
+			if (update)
+				btree_item_flip(root, &new->item[i-1], update);
+
+			btree_item_free(root, &node->item[i]);
+
+			/*
+			 * use right to carry the new node to avoid having
+			 * the same pattern as single change
+			 */
+			right = new;
+			new = NULL;
+			continue;
+		}
+
+		/* only the root may underflow */
+		BUG_ON(root->root != node);
+		goto delete_one;
+
+	} while (btree_stack_size(&stack));
+
+	BUG_ON(left || right);
+
+	if (new)
+		btree_ptr_flip(root, (void **)&root->root, new);
+
+	if (!root->root->item[1].data &&
+			btree_item_node(&root->root->item[0])) {
+		btree_ptr_flip(root, (void **)&root->root,
+				btree_item_deref(&root->root->item[0]));
+		root->height--;
+	}
+
+	if (!root->root->item[0].data) {
+		btree_ptr_flip(root, (void **)&root->root, NULL);
+		root->height = 0;
+	}
+
+out:
+	btree_mod_finish(root, index, "remove");
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
+	btree_cachep = KMEM_CACHE(btree_node, SLAB_HWCACHE_ALIGN);
+
+}
+
+#ifdef BTREE_DEBUG
+static void __btree_node_print(struct btree_root *root,
+		struct btree_node *node, int recurse)
+{
+	int i, j;
+	for (i = 0; i < BTREE_ITEM_MAX; i++) {
+		if (node->item[i].data) {
+			printk(KERN_DEBUG);
+			for (j=0; j<recurse; j++)
+				printk(" ");
+			if (!btree_item_node(&node->item[i])) {
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
+	printk(KERN_DEBUG "[%p] root: %p, height: %d\n",
+			root, root->root, root->height);
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
