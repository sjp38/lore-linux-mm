Message-Id: <20070418201606.090997479@chello.nl>
References: <20070418201248.468050288@chello.nl>
Date: Wed, 18 Apr 2007 22:12:53 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 5/6] radix-tree: optimistic locking
Content-Disposition: inline; filename=radix-tree-optimistic.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: npiggin@suse.de, akpm@linux-foundation.org, clameter@sgi.com, a.p.zijlstra@chello.nl
List-ID: <linux-mm.kvack.org>

Implement optimistic locking for the concurrent radix tree.

Optimistic locking is aimed at avoiding taking higher level node locks to
reduce cache-line bouncing (and lock contention). We descent the tree using an
RCU lookup, looking for the lowest modification termination point.

If found, we try to acquire the lock of that node. After we have obtained this
lock, we will need to validate if the initial conditions still hold true.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/radix-tree.h |   27 +++++-
 init/Kconfig               |    6 +
 lib/radix-tree.c           |  175 ++++++++++++++++++++++++++++++++++++++++-----
 3 files changed, 187 insertions(+), 21 deletions(-)

Index: linux-2.6/lib/radix-tree.c
===================================================================
--- linux-2.6.orig/lib/radix-tree.c	2007-04-18 09:56:20.000000000 +0200
+++ linux-2.6/lib/radix-tree.c	2007-04-18 09:56:42.000000000 +0200
@@ -362,6 +362,117 @@ static inline void radix_path_unlock(str
 #define radix_path_unlock(context, punlock) do { } while (0)
 #endif
 
+#ifdef CONFIG_RADIX_TREE_OPTIMISTIC
+typedef int (*radix_valid_fn)(struct radix_tree_node *, int, int);
+
+static struct radix_tree_node *
+radix_optimistic_lookup(struct radix_tree_context *context, unsigned long index,
+		int tag, radix_valid_fn valid)
+{
+	unsigned int height, shift;
+	struct radix_tree_node *node, *ret = NULL, **slot;
+	struct radix_tree_root *root = context->root;
+
+	node = rcu_dereference(root->rnode);
+	if (node == NULL)
+		return NULL;
+
+	if (!radix_tree_is_indirect_ptr(node))
+			return NULL;
+
+	node = radix_tree_indirect_to_ptr(node);
+
+	height = node->height;
+	if (index > radix_tree_maxindex(height))
+		return NULL;
+
+	shift = (height-1) * RADIX_TREE_MAP_SHIFT;
+	do {
+		int offset = (index >> shift) & RADIX_TREE_MAP_MASK;
+		if ((*valid)(node, offset, tag))
+			ret = node;
+		slot = (struct radix_tree_node **)(node->slots + offset);
+		node = rcu_dereference(*slot);
+		if (!node)
+			break;
+
+		shift -= RADIX_TREE_MAP_SHIFT;
+		height--;
+	} while (height > 0);
+
+	return ret;
+}
+
+static struct radix_tree_node *
+__radix_optimistic_lock(struct radix_tree_context *context, unsigned long index,
+	       	int tag, radix_valid_fn valid)
+{
+	struct radix_tree_node *node;
+	spinlock_t *locked;
+	unsigned int shift, offset;
+
+	node = radix_optimistic_lookup(context, index, tag, valid);
+	if (!node)
+		goto out;
+
+	locked = radix_node_lock(context->root, node);
+	if (!locked)
+		goto out;
+
+#if 0
+	if (node != radix_optimistic_lookup(context, index, tag, valid))
+		goto out_unlock;
+#else
+	/* check if the node got freed */
+	if (!node->count)
+		goto out_unlock;
+
+	/* check if the node is still a valid termination point */
+	shift = (node->height - 1) * RADIX_TREE_MAP_SHIFT;
+	offset = (index >> shift) & RADIX_TREE_MAP_MASK;
+	if (!(*valid)(node, offset, tag))
+		goto out_unlock;
+#endif
+
+	context->locked = locked;
+	return node;
+
+out_unlock:
+	spin_unlock(locked);
+out:
+	return NULL;
+}
+
+static struct radix_tree_node *
+radix_optimistic_lock(struct radix_tree_context *context, unsigned long index,
+		int tag, radix_valid_fn valid)
+{
+	struct radix_tree_node *node = NULL;
+
+	if (context) {
+		node = __radix_optimistic_lock(context, index, tag, valid);
+		if (!node) {
+			BUG_ON(context->locked);
+			spin_lock(&context->root->lock);
+			context->locked = &context->root->lock;
+		}
+	}
+	return node;
+}
+
+static int radix_valid_always(struct radix_tree_node *node, int offset, int tag)
+{
+	return 1;
+}
+
+static int radix_valid_tag(struct radix_tree_node *node, int offset, int tag)
+{
+	return tag_get(node, tag, offset);
+}
+#else
+#define radix_optimistic_lock(context, index, tag, valid) NULL
+#endif
+
 /**
  *	radix_tree_insert    -    insert into a radix tree
  *	@root:		radix tree root
@@ -382,6 +493,13 @@ int radix_tree_insert(struct radix_tree_
 
 	BUG_ON(radix_tree_is_indirect_ptr(item));
 
+	node = radix_optimistic_lock(context, index, 0, radix_valid_always);
+	if (node) {
+		height = node->height;
+		shift = (height-1) * RADIX_TREE_MAP_SHIFT;
+		goto optimistic;
+	}
+
 	/* Make sure the tree is high enough.  */
 	if (index > radix_tree_maxindex(root->height)) {
 		error = radix_tree_extend(root, index);
@@ -390,7 +508,6 @@ int radix_tree_insert(struct radix_tree_
 	}
 
 	slot = radix_tree_indirect_to_ptr(root->rnode);
-
 	height = root->height;
 	shift = (height-1) * RADIX_TREE_MAP_SHIFT;
 
@@ -409,11 +526,11 @@ int radix_tree_insert(struct radix_tree_
 		}
 
 		/* Go a level down */
-		offset = (index >> shift) & RADIX_TREE_MAP_MASK;
 		node = slot;
-
 		radix_ladder_lock(context, node);
 
+optimistic:
+		offset = (index >> shift) & RADIX_TREE_MAP_MASK;
 		slot = node->slots[offset];
 		shift -= RADIX_TREE_MAP_SHIFT;
 		height--;
@@ -456,6 +573,10 @@ void **radix_tree_lookup_slot(struct rad
 	struct radix_tree_node *node, **slot;
 	RADIX_TREE_CONTEXT(context, root);
 
+	node = radix_optimistic_lock(context, index, 0, radix_valid_always);
+	if (node)
+		goto optimistic;
+
 	node = rcu_dereference(root->rnode);
 	if (node == NULL)
 		return NULL;
@@ -467,6 +588,7 @@ void **radix_tree_lookup_slot(struct rad
 	}
 	node = radix_tree_indirect_to_ptr(node);
 
+optimistic:
 	height = node->height;
 	if (index > radix_tree_maxindex(height))
 		return NULL;
@@ -559,6 +681,13 @@ void *radix_tree_tag_set(struct radix_tr
 	struct radix_tree_node *slot;
 	RADIX_TREE_CONTEXT(context, root);
 
+	slot = radix_optimistic_lock(context, index, tag, radix_valid_tag);
+	if (slot) {
+		height = slot->height;
+		shift = (height - 1) * RADIX_TREE_MAP_SHIFT;
+		goto optimistic;
+	}
+
 	height = root->height;
 	BUG_ON(index > radix_tree_maxindex(height));
 
@@ -574,6 +703,7 @@ void *radix_tree_tag_set(struct radix_tr
 
 		radix_ladder_lock(context, slot);
 
+optimistic:
 		offset = (index >> shift) & RADIX_TREE_MAP_MASK;
 		if (!tag_get(slot, tag, offset))
 			tag_set(slot, tag, offset);
@@ -590,13 +720,13 @@ EXPORT_SYMBOL(radix_tree_tag_set);
 /*
  * the change can never propagate upwards from here.
  */
-static inline int radix_tree_unlock_tag(struct radix_tree_root *root,
-		struct radix_tree_path *pathp, int tag)
+static
+int radix_valid_tag_clear(struct radix_tree_node *node, int offset, int tag)
 {
 	int this, other;
 
-	this = tag_get(pathp->node, tag, pathp->offset);
-	other = any_tag_set_but(pathp->node, tag, pathp->offset);
+	this = tag_get(node, tag, offset);
+	other = any_tag_set_but(node, tag, offset);
 
 	return !this || other;
 }
@@ -621,9 +751,22 @@ void *radix_tree_tag_clear(struct radix_
 	struct radix_tree_path path[RADIX_TREE_MAX_PATH], *pathp = path;
 	struct radix_tree_path *punlock = path, *piter;
 	struct radix_tree_node *slot = NULL;
-	unsigned int height, shift;
+	unsigned int height, shift, offset;
+
 	RADIX_TREE_CONTEXT(context, root);
 
+	slot = radix_optimistic_lock(context, index, tag,
+			radix_valid_tag_clear);
+	if (slot) {
+		height = slot->height;
+		shift = (height - 1) * RADIX_TREE_MAP_SHIFT;
+		offset = (index >> shift) & RADIX_TREE_MAP_MASK;
+		pathp->offset = offset;
+		pathp->node = slot;
+		radix_path_init(context, pathp);
+		goto optimistic;
+	}
+
 	pathp->node = NULL;
 	radix_path_init(context, pathp);
 
@@ -635,8 +778,6 @@ void *radix_tree_tag_clear(struct radix_
 	slot = radix_tree_indirect_to_ptr(root->rnode);
 
 	while (height > 0) {
-		int offset;
-
 		if (slot == NULL)
 			goto out;
 
@@ -646,11 +787,12 @@ void *radix_tree_tag_clear(struct radix_
 		pathp->node = slot;
 		radix_path_lock(context, pathp, slot);
 
-		if (radix_tree_unlock_tag(root, pathp, tag)) {
+		if (radix_valid_tag_clear(slot, offset, tag)) {
 			for (; punlock < pathp; punlock++)
 				radix_path_unlock(context, punlock);
 		}
 
+optimistic:
 		slot = slot->slots[offset];
 		shift -= RADIX_TREE_MAP_SHIFT;
 		height--;
@@ -1160,14 +1302,20 @@ static inline void radix_tree_shrink(str
 	}
 }
 
-static inline int radix_tree_unlock_all(struct radix_tree_root *root,
-		struct radix_tree_path *pathp)
+static
+int radix_valid_delete(struct radix_tree_node *node, int offset, int tag)
 {
-	int tag;
-	int unlock = 1;
+	/*
+	 * we need to check for > 2, because nodes with a single child
+	 * can still be deleted, see radix_tree_shrink().
+	 */
+	int unlock = (node->count > 2);
+
+	if (!unlock)
+		return unlock;
 
 	for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++) {
-		if (!radix_tree_unlock_tag(root, pathp, tag)) {
+		if (!radix_valid_tag_clear(node, offset, tag)) {
 			unlock = 0;
 			break;
 		}
@@ -1195,6 +1343,17 @@ void *radix_tree_delete(struct radix_tre
 	int offset;
 	RADIX_TREE_CONTEXT(context, root);
 
+	slot = radix_optimistic_lock(context, index, 0, radix_valid_delete);
+	if (slot) {
+		height = slot->height;
+		shift = (height - 1) * RADIX_TREE_MAP_SHIFT;
+		offset = (index >> shift) & RADIX_TREE_MAP_MASK;
+		pathp->offset = offset;
+		pathp->node = slot;
+		radix_path_init(context, pathp);
+		goto optimistic;
+	}
+
 	pathp->node = NULL;
 	radix_path_init(context, pathp);
 
@@ -1222,11 +1381,12 @@ void *radix_tree_delete(struct radix_tre
 		pathp->node = slot;
 		radix_path_lock(context, pathp, slot);
 
-		if (slot->count > 2 && radix_tree_unlock_all(root, pathp)) {
+		if (radix_valid_delete(slot, offset, 0)) {
 			for (; punlock < pathp; punlock++)
 				radix_path_unlock(context, punlock);
 		}
 
+optimistic:
 		slot = slot->slots[offset];
 		shift -= RADIX_TREE_MAP_SHIFT;
 		height--;
Index: linux-2.6/init/Kconfig
===================================================================
--- linux-2.6.orig/init/Kconfig	2007-04-18 09:56:20.000000000 +0200
+++ linux-2.6/init/Kconfig	2007-04-18 09:56:27.000000000 +0200
@@ -344,8 +344,14 @@ config SYSCTL
 
 config RADIX_TREE_CONCURRENT
 	bool "Enable concurrent radix tree operations (EXPERIMENTAL)"
+	depends on EXPERIMENTAL
 	default y if SMP
 
+config RADIX_TREE_OPTIMISTIC
+	bool "Enabled optimistic locking (EXPERIMENTAL)"
+	depends on RADIX_TREE_CONCURRENT
+	default y
+
 menuconfig EMBEDDED
 	bool "Configure standard kernel features (for small systems)"
 	help
Index: linux-2.6/include/linux/radix-tree.h
===================================================================
--- linux-2.6.orig/include/linux/radix-tree.h	2007-04-18 09:56:20.000000000 +0200
+++ linux-2.6/include/linux/radix-tree.h	2007-04-18 09:56:27.000000000 +0200
@@ -197,28 +197,47 @@ static inline void radix_tree_replace_sl
 	rcu_assign_pointer(*pslot, item);
 }
 
+#if defined(CONFIG_RADIX_TREE_OPTIMISTIC)
+static inline void radix_tree_lock(struct radix_tree_context *context)
+{
+	rcu_read_lock();
+	BUG_ON(context->locked);
+}
+#elif defined(CONFIG_RADIX_TREE_CONCURRENT)
 static inline void radix_tree_lock(struct radix_tree_context *context)
 {
 	struct radix_tree_root *root = context->root;
+
 	rcu_read_lock();
 	spin_lock(&root->lock);
-#ifdef CONFIG_RADIX_TREE_CONCURRENT
 	BUG_ON(context->locked);
 	context->locked = &root->lock;
-#endif
 }
+#else
+static inline void radix_tree_lock(struct radix_tree_context *context)
+{
+	struct radix_tree_root *root = context->root;
+
+	rcu_read_lock();
+	spin_lock(&root->lock);
+}
+#endif
 
+#if defined(CONFIG_RADIX_TREE_CONCURRENT)
 static inline void radix_tree_unlock(struct radix_tree_context *context)
 {
-#ifdef CONFIG_RADIX_TREE_CONCURRENT
 	BUG_ON(!context->locked);
 	spin_unlock(context->locked);
 	context->locked = NULL;
+	rcu_read_unlock();
+}
 #else
+static inline void radix_tree_unlock(struct radix_tree_context *context)
+{
 	spin_unlock(&context->root->lock);
-#endif
 	rcu_read_unlock();
 }
+#endif
 
 int radix_tree_insert(struct radix_tree_root *, unsigned long, void *);
 void *radix_tree_lookup(struct radix_tree_root *, unsigned long);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
