Message-Id: <20070128132436.925766000@programming.kicks-ass.net>
References: <20070128131343.628722000@programming.kicks-ass.net>
Date: Sun, 28 Jan 2007 14:13:53 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 10/14] radix-tree: concurrent write side support
Content-Disposition: inline; filename=radix-tree-concurrent.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Andrew Morton <akpm@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Christoph Lameter <clameter@sgi.com>, Ingo Molnar <mingo@elte.hu>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Provide support for concurrent write side operations without changing the API
for all current uses.

Concurrency is realized by means of two locking models; the simple one is 
ladder locking, the more complex one is path locking.

Ladder locking is like walking down a ladder, you place your foot on a spoke
below the one your other foot finds support etc.. There is no walking with both
feet in the air. Likewise with walking a tree, you lock a node below the 
current node before releasing it.

This allows other modifying operations to start as soon as you release the
lock on the root node and even complete before you if they walk another path
downward.

The modifying operations: insert, lookup_slot and set_tag, use this simple
method.

The more complex path locking method is needed for operations that need to
walk upwards again after they walked down, those are: tag_clear and delete.

These lock their whole path downwards and release whole sections at points
where it can be determined the walk upwards will stop, thus also allowing
concurrency.

Finding the conditions for the terminated walk upwards while doing the downward
walk is the 'interesting' part of this approach.

The remaining - unmodified - operations will have exclusive locking (since
they're unmodified, they never move the lock downwards from the root node).

The API for this looks like:

  DECLARE_RADIX_TREE_CONTEXT(ctx, &mapping->page_tree)

  radix_tree_lock(&ctx)
  ... do _1_ modifying operation ...
  radix_tree_unlock(&ctx)

Note that before the radix operation the root node is held and will provide
exclusive locking, after the operation the held lock might only be enough to
protect a single item.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/radix-tree.h |   87 ++++++++++++-
 init/Kconfig               |    4 
 lib/radix-tree.c           |  282 +++++++++++++++++++++++++++++++++++----------
 3 files changed, 310 insertions(+), 63 deletions(-)

Index: linux-2.6/include/linux/radix-tree.h
===================================================================
--- linux-2.6.orig/include/linux/radix-tree.h
+++ linux-2.6/include/linux/radix-tree.h
@@ -62,23 +62,73 @@ struct radix_tree_root {
 	unsigned int		height;
 	gfp_t			gfp_mask;
 	struct radix_tree_node	*rnode;
+	spinlock_t		lock;
+#ifdef CONFIG_RADIX_TREE_CONCURRENT
+	struct radix_tree_context *context;
+	struct task_struct	*owner;
+#endif
 };
 
+#ifdef CONFIG_RADIX_TREE_CONCURRENT
+#define __RADIX_TREE_CONCURRENT_INIT					\
+	.context = NULL,						\
+	.owner = NULL,
+#else
+#define __RADIX_TREE_CONCURRENT_INIT
+#endif
+
 #define RADIX_TREE_INIT(mask)	{					\
 	.height = 0,							\
 	.gfp_mask = (mask),						\
 	.rnode = NULL,							\
+	.lock = __SPIN_LOCK_UNLOCKED(radix_tree_root.lock),		\
+	__RADIX_TREE_CONCURRENT_INIT					\
 }
 
 #define RADIX_TREE(name, mask) \
 	struct radix_tree_root name = RADIX_TREE_INIT(mask)
 
-#define INIT_RADIX_TREE(root, mask)					\
-do {									\
-	(root)->height = 0;						\
-	(root)->gfp_mask = (mask);					\
-	(root)->rnode = NULL;						\
-} while (0)
+static inline void INIT_RADIX_TREE(struct radix_tree_root *root, gfp_t gfp_mask)
+{
+	root->height = 0;
+	root->gfp_mask = gfp_mask;
+	root->rnode = NULL;
+	spin_lock_init(&root->lock);
+#ifdef CONFIG_RADIX_TREE_CONCURRENT
+	root->context = NULL;
+	root->owner = NULL;
+#endif
+}
+
+struct radix_tree_context {
+	struct radix_tree_root	*root;
+#ifdef CONFIG_RADIX_TREE_CONCURRENT
+	spinlock_t		*locked;
+#endif
+};
+
+#ifdef CONFIG_RADIX_TREE_CONCURRENT
+#define __RADIX_TREE_CONTEXT_INIT					\
+		.locked = NULL,
+#else
+#define __RADIX_TREE_CONTEXT_INIT
+#endif
+
+#define DECLARE_RADIX_TREE_CONTEXT(context, tree) 			\
+	struct radix_tree_context context = { 				\
+		.root = (tree), 					\
+		__RADIX_TREE_CONTEXT_INIT				\
+       	}
+
+static inline void
+init_radix_tree_context(struct radix_tree_context *wctx,
+		struct radix_tree_root *root)
+{
+	wctx->root = root;
+#ifdef CONFIG_RADIX_TREE_CONCURRENT
+	wctx->locked = NULL;
+#endif
+}
 
 /**
  * Radix-tree synchronization
@@ -155,6 +205,31 @@ static inline void radix_tree_replace_sl
 	rcu_assign_pointer(*pslot, item);
 }
 
+static inline void radix_tree_lock(struct radix_tree_context *context)
+{
+	struct radix_tree_root *root = context->root;
+	rcu_read_lock();
+	spin_lock(&root->lock);
+#ifdef CONFIG_RADIX_TREE_CONCURRENT
+	BUG_ON(context->locked);
+	context->locked = &root->lock;
+	root->owner = current;
+	root->context = context;
+#endif
+}
+
+static inline void radix_tree_unlock(struct radix_tree_context *context)
+{
+#ifdef CONFIG_RADIX_TREE_CONCURRENT
+	BUG_ON(!context->locked);
+	spin_unlock(context->locked);
+	context->locked = NULL;
+#else
+	spin_unlock(&context->root->lock);
+#endif
+	rcu_read_unlock();
+}
+
 int radix_tree_insert(struct radix_tree_root *, unsigned long, void *);
 void *radix_tree_lookup(struct radix_tree_root *, unsigned long);
 void **radix_tree_lookup_slot(struct radix_tree_root *, unsigned long);
Index: linux-2.6/lib/radix-tree.c
===================================================================
--- linux-2.6.orig/lib/radix-tree.c
+++ linux-2.6/lib/radix-tree.c
@@ -32,6 +32,7 @@
 #include <linux/string.h>
 #include <linux/bitops.h>
 #include <linux/rcupdate.h>
+#include <linux/spinlock.h>
 
 
 #ifdef __KERNEL__
@@ -52,11 +53,17 @@ struct radix_tree_node {
 	struct rcu_head	rcu_head;
 	void		*slots[RADIX_TREE_MAP_SIZE];
 	unsigned long	tags[RADIX_TREE_MAX_TAGS][RADIX_TREE_TAG_LONGS];
+#ifdef CONFIG_RADIX_TREE_CONCURRENT
+	spinlock_t	lock;
+#endif
 };
 
 struct radix_tree_path {
 	struct radix_tree_node *node;
 	int offset;
+#ifdef CONFIG_RADIX_TREE_CONCURRENT
+	spinlock_t *locked;
+#endif
 };
 
 #define RADIX_TREE_INDEX_BITS  (8 /* CHAR_BIT */ * sizeof(unsigned long))
@@ -64,6 +71,10 @@ struct radix_tree_path {
 
 static unsigned long height_to_maxindex[RADIX_TREE_MAX_PATH] __read_mostly;
 
+#ifdef CONFIG_RADIX_TREE_CONCURRENT
+static struct lock_class_key radix_node_class[RADIX_TREE_MAX_PATH];
+#endif
+
 /*
  * Radix tree node cache.
  */
@@ -88,7 +99,7 @@ static inline gfp_t root_gfp_mask(struct
  * that the caller has pinned this thread of control to the current CPU.
  */
 static struct radix_tree_node *
-radix_tree_node_alloc(struct radix_tree_root *root)
+radix_tree_node_alloc(struct radix_tree_root *root, int height)
 {
 	struct radix_tree_node *ret;
 	gfp_t gfp_mask = root_gfp_mask(root);
@@ -105,6 +116,11 @@ radix_tree_node_alloc(struct radix_tree_
 		}
 	}
 	BUG_ON(radix_tree_is_indirect_ptr(ret));
+#ifdef CONFIG_RADIX_TREE_CONCURRENT
+	spin_lock_init(&ret->lock);
+	lockdep_set_class(&ret->lock, &radix_node_class[height]);
+#endif
+	ret->height = height;
 	return ret;
 }
 
@@ -205,6 +221,22 @@ static inline int any_tag_set(struct rad
 	return 0;
 }
 
+static inline int any_tag_set_but(struct radix_tree_node *node,
+		unsigned int tag, int offset)
+{
+	int idx;
+	int offset_idx = offset / BITS_PER_LONG;
+	unsigned long offset_mask = ~(1UL << (offset % BITS_PER_LONG));
+	for (idx = 0; idx < RADIX_TREE_TAG_LONGS; idx++) {
+		unsigned long mask = ~0UL;
+		if (idx == offset_idx)
+			mask = offset_mask;
+		if (node->tags[tag][idx] & mask)
+			return 1;
+	}
+	return 0;
+}
+
 /*
  *	Return the maximum key which can be store into a
  *	radix tree with height HEIGHT.
@@ -234,8 +266,8 @@ static int radix_tree_extend(struct radi
 	}
 
 	do {
-		unsigned int newheight;
-		if (!(node = radix_tree_node_alloc(root)))
+		unsigned int newheight = root->height + 1;
+		if (!(node = radix_tree_node_alloc(root, newheight)))
 			return -ENOMEM;
 
 		/* Increase the height.  */
@@ -247,8 +279,6 @@ static int radix_tree_extend(struct radi
 				tag_set(node, tag, 0);
 		}
 
-		newheight = root->height+1;
-		node->height = newheight;
 		node->count = 1;
 		node = radix_tree_ptr_to_indirect(node);
 		rcu_assign_pointer(root->rnode, node);
@@ -258,6 +288,77 @@ out:
 	return 0;
 }
 
+#ifdef CONFIG_RADIX_TREE_CONCURRENT
+static inline struct radix_tree_context *
+radix_tree_get_context(struct radix_tree_root *root)
+{
+	struct radix_tree_context *context = NULL;
+
+	if (root->owner == current && root->context) {
+		context = root->context;
+		root->context = NULL;
+	}
+	return context;
+}
+
+#define RADIX_TREE_CONTEXT(context, root) \
+	struct radix_tree_context *context = radix_tree_get_context(root)
+
+static inline spinlock_t *radix_node_lock(struct radix_tree_root *root,
+		struct radix_tree_node *node)
+{
+	spinlock_t *locked = &node->lock;
+	spin_lock(locked);
+	return locked;
+}
+
+static inline void radix_ladder_lock(struct radix_tree_context *context,
+		struct radix_tree_node *node)
+{
+	if (context) {
+		struct radix_tree_root *root = context->root;
+		spinlock_t *locked = radix_node_lock(root, node);
+		if (locked) {
+			spin_unlock(context->locked);
+			context->locked = locked;
+		}
+	}
+}
+
+static inline void radix_path_init(struct radix_tree_context *context,
+		struct radix_tree_path *pathp)
+{
+	pathp->locked = context ? context->locked : NULL;
+}
+
+static inline void radix_path_lock(struct radix_tree_context *context,
+		struct radix_tree_path *pathp, struct radix_tree_node *node)
+{
+	if (context) {
+		struct radix_tree_root *root = context->root;
+		spinlock_t *locked = radix_node_lock(root, node);
+		if (locked)
+			context->locked = locked;
+		pathp->locked = locked;
+	} else
+		pathp->locked = NULL;
+}
+
+static inline void radix_path_unlock(struct radix_tree_context *context,
+		struct radix_tree_path *punlock)
+{
+	if (context && punlock->locked &&
+			context->locked != punlock->locked)
+		spin_unlock(punlock->locked);
+}
+#else
+#define RADIX_TREE_CONTEXT(context, root) do { } while (0)
+#define radix_ladder_lock(context, node) do { } while (0)
+#define radix_path_init(context, pathp) do { } while (0)
+#define radix_path_lock(context, pathp, node) do { } while (0)
+#define radix_path_unlock(context, punlock) do { } while (0)
+#endif
+
 /**
  *	radix_tree_insert    -    insert into a radix tree
  *	@root:		radix tree root
@@ -273,6 +374,8 @@ int radix_tree_insert(struct radix_tree_
 	unsigned int height, shift;
 	int offset;
 	int error;
+	int tag;
+	RADIX_TREE_CONTEXT(context, root);
 
 	BUG_ON(radix_tree_is_indirect_ptr(item));
 
@@ -292,9 +395,8 @@ int radix_tree_insert(struct radix_tree_
 	while (height > 0) {
 		if (slot == NULL) {
 			/* Have to add a child node.  */
-			if (!(slot = radix_tree_node_alloc(root)))
+			if (!(slot = radix_tree_node_alloc(root, height)))
 				return -ENOMEM;
-			slot->height = height;
 			if (node) {
 				rcu_assign_pointer(node->slots[offset], slot);
 				node->count++;
@@ -306,6 +408,9 @@ int radix_tree_insert(struct radix_tree_
 		/* Go a level down */
 		offset = (index >> shift) & RADIX_TREE_MAP_MASK;
 		node = slot;
+
+		radix_ladder_lock(context, node);
+
 		slot = node->slots[offset];
 		shift -= RADIX_TREE_MAP_SHIFT;
 		height--;
@@ -317,12 +422,12 @@ int radix_tree_insert(struct radix_tree_
 	if (node) {
 		node->count++;
 		rcu_assign_pointer(node->slots[offset], item);
-		BUG_ON(tag_get(node, 0, offset));
-		BUG_ON(tag_get(node, 1, offset));
+		for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++)
+			BUG_ON(tag_get(node, tag, offset));
 	} else {
 		rcu_assign_pointer(root->rnode, item);
-		BUG_ON(root_tag_get(root, 0));
-		BUG_ON(root_tag_get(root, 1));
+		for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++)
+			BUG_ON(root_tag_get(root, tag));
 	}
 
 	return 0;
@@ -346,6 +451,7 @@ void **radix_tree_lookup_slot(struct rad
 {
 	unsigned int height, shift;
 	struct radix_tree_node *node, **slot;
+	RADIX_TREE_CONTEXT(context, root);
 
 	node = rcu_dereference(root->rnode);
 	if (node == NULL)
@@ -371,6 +477,8 @@ void **radix_tree_lookup_slot(struct rad
 		if (node == NULL)
 			return NULL;
 
+		radix_ladder_lock(context, node);
+
 		shift -= RADIX_TREE_MAP_SHIFT;
 		height--;
 	} while (height > 0);
@@ -446,6 +554,7 @@ void *radix_tree_tag_set(struct radix_tr
 {
 	unsigned int height, shift;
 	struct radix_tree_node *slot;
+	RADIX_TREE_CONTEXT(context, root);
 
 	height = root->height;
 	BUG_ON(index > radix_tree_maxindex(height));
@@ -453,9 +562,15 @@ void *radix_tree_tag_set(struct radix_tr
 	slot = radix_tree_indirect_to_ptr(root->rnode);
 	shift = (height - 1) * RADIX_TREE_MAP_SHIFT;
 
+	/* set the root's tag bit */
+	if (slot && !root_tag_get(root, tag))
+		root_tag_set(root, tag);
+
 	while (height > 0) {
 		int offset;
 
+		radix_ladder_lock(context, slot);
+
 		offset = (index >> shift) & RADIX_TREE_MAP_MASK;
 		if (!tag_get(slot, tag, offset))
 			tag_set(slot, tag, offset);
@@ -465,14 +580,24 @@ void *radix_tree_tag_set(struct radix_tr
 		height--;
 	}
 
-	/* set the root's tag bit */
-	if (slot && !root_tag_get(root, tag))
-		root_tag_set(root, tag);
-
 	return slot;
 }
 EXPORT_SYMBOL(radix_tree_tag_set);
 
+/*
+ * the change can never propagate upwards from here.
+ */
+static inline int radix_tree_unlock_tag(struct radix_tree_root *root,
+		struct radix_tree_path *pathp, int tag)
+{
+	int this, other;
+
+	this = tag_get(pathp->node, tag, pathp->offset);
+	other = any_tag_set_but(pathp->node, tag, pathp->offset);
+
+	return !this || other;
+}
+
 /**
  *	radix_tree_tag_clear - clear a tag on a radix tree node
  *	@root:		radix tree root
@@ -491,15 +616,19 @@ void *radix_tree_tag_clear(struct radix_
 			unsigned long index, unsigned int tag)
 {
 	struct radix_tree_path path[RADIX_TREE_MAX_PATH], *pathp = path;
+	struct radix_tree_path *punlock = path, *piter;
 	struct radix_tree_node *slot = NULL;
 	unsigned int height, shift;
+	RADIX_TREE_CONTEXT(context, root);
+
+	pathp->node = NULL;
+	radix_path_init(context, pathp);
 
 	height = root->height;
 	if (index > radix_tree_maxindex(height))
 		goto out;
 
 	shift = (height - 1) * RADIX_TREE_MAP_SHIFT;
-	pathp->node = NULL;
 	slot = radix_tree_indirect_to_ptr(root->rnode);
 
 	while (height > 0) {
@@ -509,10 +638,17 @@ void *radix_tree_tag_clear(struct radix_
 			goto out;
 
 		offset = (index >> shift) & RADIX_TREE_MAP_MASK;
-		pathp[1].offset = offset;
-		pathp[1].node = slot;
-		slot = slot->slots[offset];
 		pathp++;
+		pathp->offset = offset;
+		pathp->node = slot;
+		radix_path_lock(context, pathp, slot);
+
+		if (radix_tree_unlock_tag(root, pathp, tag)) {
+			for (; punlock < pathp; punlock++)
+				radix_path_unlock(context, punlock);
+		}
+
+		slot = slot->slots[offset];
 		shift -= RADIX_TREE_MAP_SHIFT;
 		height--;
 	}
@@ -520,20 +656,22 @@ void *radix_tree_tag_clear(struct radix_
 	if (slot == NULL)
 		goto out;
 
-	while (pathp->node) {
-		if (!tag_get(pathp->node, tag, pathp->offset))
-			goto out;
-		tag_clear(pathp->node, tag, pathp->offset);
-		if (any_tag_set(pathp->node, tag))
-			goto out;
-		pathp--;
+	for (piter = pathp; piter >= punlock; piter--) {
+		if (piter->node) {
+			if (!tag_get(piter->node, tag, piter->offset))
+				break;
+			tag_clear(piter->node, tag, piter->offset);
+			if (any_tag_set(piter->node, tag))
+				break;
+		} else {
+			if (root_tag_get(root, tag))
+				root_tag_clear(root, tag);
+		}
 	}
 
-	/* clear the root's tag bit */
-	if (root_tag_get(root, tag))
-		root_tag_clear(root, tag);
-
 out:
+	for (; punlock < pathp; punlock++)
+		radix_path_unlock(context, punlock);
 	return slot;
 }
 EXPORT_SYMBOL(radix_tree_tag_clear);
@@ -955,7 +1093,7 @@ radix_tree_gang_lookup_tag_slot(struct r
 	if (!radix_tree_is_indirect_ptr(node)) {
 		if (first_index > 0)
 			return 0;
-		results[0] = node;
+		results[0] = (void **)&root->rnode;
 		return 1;
 	}
 	node = radix_tree_indirect_to_ptr(node);
@@ -991,6 +1129,7 @@ static inline void radix_tree_shrink(str
 	while (root->height > 0) {
 		struct radix_tree_node *to_free = root->rnode;
 		void *newptr;
+		int tag;
 
 		BUG_ON(!radix_tree_is_indirect_ptr(to_free));
 		to_free = radix_tree_indirect_to_ptr(to_free);
@@ -1017,14 +1156,29 @@ static inline void radix_tree_shrink(str
 		root->rnode = newptr;
 		root->height--;
 		/* must only free zeroed nodes into the slab */
-		tag_clear(to_free, 0, 0);
-		tag_clear(to_free, 1, 0);
+		for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++)
+			tag_clear(to_free, tag, 0);
 		to_free->slots[0] = NULL;
 		to_free->count = 0;
-		radix_tree_node_free(to_free);
 	}
 }
 
+static inline int radix_tree_unlock_all(struct radix_tree_root *root,
+		struct radix_tree_path *pathp)
+{
+	int tag;
+	int unlock = 1;
+
+	for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++) {
+		if (!radix_tree_unlock_tag(root, pathp, tag)) {
+			unlock = 0;
+			break;
+		}
+	}
+
+	return unlock;
+}
+
 /**
  *	radix_tree_delete    -    delete an item from a radix tree
  *	@root:		radix tree root
@@ -1037,11 +1191,15 @@ static inline void radix_tree_shrink(str
 void *radix_tree_delete(struct radix_tree_root *root, unsigned long index)
 {
 	struct radix_tree_path path[RADIX_TREE_MAX_PATH], *pathp = path;
+	struct radix_tree_path *punlock = path, *piter;
 	struct radix_tree_node *slot = NULL;
-	struct radix_tree_node *to_free;
 	unsigned int height, shift;
 	int tag;
 	int offset;
+	RADIX_TREE_CONTEXT(context, root);
+
+	pathp->node = NULL;
+	radix_path_init(context, pathp);
 
 	height = root->height;
 	if (index > radix_tree_maxindex(height))
@@ -1056,7 +1214,6 @@ void *radix_tree_delete(struct radix_tre
 	slot = radix_tree_indirect_to_ptr(slot);
 
 	shift = (height - 1) * RADIX_TREE_MAP_SHIFT;
-	pathp->node = NULL;
 
 	do {
 		if (slot == NULL)
@@ -1066,6 +1223,13 @@ void *radix_tree_delete(struct radix_tre
 		offset = (index >> shift) & RADIX_TREE_MAP_MASK;
 		pathp->offset = offset;
 		pathp->node = slot;
+		radix_path_lock(context, pathp, slot);
+
+		if (slot->count > 2 && radix_tree_unlock_all(root, pathp)) {
+			for (; punlock < pathp; punlock++)
+				radix_path_unlock(context, punlock);
+		}
+
 		slot = slot->slots[offset];
 		shift -= RADIX_TREE_MAP_SHIFT;
 		height--;
@@ -1078,41 +1242,45 @@ void *radix_tree_delete(struct radix_tre
 	 * Clear all tags associated with the just-deleted item
 	 */
 	for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++) {
-		if (tag_get(pathp->node, tag, pathp->offset))
-			radix_tree_tag_clear(root, index, tag);
+		for (piter = pathp; piter >= punlock; piter--) {
+			if (piter->node) {
+				if (!tag_get(piter->node, tag, piter->offset))
+					break;
+				tag_clear(piter->node, tag, piter->offset);
+				if (any_tag_set(piter->node, tag))
+					break;
+			} else {
+				if (root_tag_get(root, tag))
+					root_tag_clear(root, tag);
+			}
+		}
 	}
 
-	to_free = NULL;
-	/* Now free the nodes we do not need anymore */
-	while (pathp->node) {
-		pathp->node->slots[pathp->offset] = NULL;
-		pathp->node->count--;
-		/*
-		 * Queue the node for deferred freeing after the
-		 * last reference to it disappears (set NULL, above).
-		 */
-		if (to_free)
-			radix_tree_node_free(to_free);
+	/* Now unhook the nodes we do not need anymore */
+	for (piter = pathp; piter >= punlock && piter->node; piter--) {
+		piter->node->slots[piter->offset] = NULL;
+		piter->node->count--;
 
-		if (pathp->node->count) {
-			if (pathp->node ==
+		if (piter->node->count) {
+			if (piter->node ==
 					radix_tree_indirect_to_ptr(root->rnode))
 				radix_tree_shrink(root);
 			goto out;
 		}
+	}
 
-		/* Node with zero slots in use so free it */
-		to_free = pathp->node;
-		pathp--;
+	BUG_ON(piter->node);
 
-	}
 	root_tag_clear_all(root);
 	root->height = 0;
 	root->rnode = NULL;
-	if (to_free)
-		radix_tree_node_free(to_free);
 
 out:
+	for (; punlock <= pathp; punlock++) {
+		radix_path_unlock(context, punlock);
+		if (punlock->node && punlock->node->count == 0)
+			radix_tree_node_free(punlock->node);
+	}
 	return slot;
 }
 EXPORT_SYMBOL(radix_tree_delete);
Index: linux-2.6/init/Kconfig
===================================================================
--- linux-2.6.orig/init/Kconfig
+++ linux-2.6/init/Kconfig
@@ -316,6 +316,10 @@ config TASK_IO_ACCOUNTING
 config SYSCTL
 	bool
 
+config RADIX_TREE_CONCURRENT
+	bool "Enable concurrent radix tree operations (EXPERIMENTAL)"
+	default y if SMP
+
 menuconfig EMBEDDED
 	bool "Configure standard kernel features (for small systems)"
 	help

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
