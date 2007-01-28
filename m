Message-Id: <20070128132433.596289000@programming.kicks-ass.net>
References: <20070128131343.628722000@programming.kicks-ass.net>
Date: Sun, 28 Jan 2007 14:13:44 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 01/14] radix-tree: use indirect bit
Content-Disposition: inline; filename=radix-tree-use-indirect-bit.patch
Sender: owner-linux-mm@kvack.org
From: Nick Piggin <npiggin@suse.de>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Andrew Morton <akpm@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Christoph Lameter <clameter@sgi.com>, Ingo Molnar <mingo@elte.hu>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Rather than sign direct radix-tree pointers with a special bit, sign
the indirect one that hangs off the root. This means that, given a
lookup_slot operation, the invalid result will be differentiated from
the valid (previously, valid results could have the bit either set or
clear).

This does not affect slot lookups which occur under lock -- they
can never return an invalid result. Is needed in future for lockless
pagecache.

Signed-off-by: Nick Piggin <npiggin@suse.de>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/radix-tree.h |   40 ++++++++++++++------------
 lib/radix-tree.c           |   69 ++++++++++++++++++++++++++++-----------------
 2 files changed, 65 insertions(+), 44 deletions(-)

Index: linux-2.6/include/linux/radix-tree.h
===================================================================
--- linux-2.6.orig/include/linux/radix-tree.h	2007-01-22 20:09:50.000000000 +0100
+++ linux-2.6/include/linux/radix-tree.h	2007-01-22 20:09:53.000000000 +0100
@@ -26,28 +26,31 @@
 #include <linux/rcupdate.h>
 
 /*
- * A direct pointer (root->rnode pointing directly to a data item,
- * rather than another radix_tree_node) is signalled by the low bit
- * set in the root->rnode pointer.
- *
- * In this case root->height is also NULL, but the direct pointer tests are
- * needed for RCU lookups when root->height is unreliable.
+ * An indirect pointer (root->rnode pointing to a radix_tree_node, rather
+ * than a data item) is signalled by the low bit set in the root->rnode
+ * pointer.
+ *
+ * In this case root->height is > 0, but the indirect pointer tests are
+ * needed for RCU lookups (because root->height is unreliable). The only
+ * time callers need worry about this is when doing a lookup_slot under
+ * RCU.
  */
-#define RADIX_TREE_DIRECT_PTR	1
+#define RADIX_TREE_INDIRECT_PTR	1
+#define RADIX_TREE_RETRY ((void *)-1UL)
 
-static inline void *radix_tree_ptr_to_direct(void *ptr)
+static inline void *radix_tree_ptr_to_indirect(void *ptr)
 {
-	return (void *)((unsigned long)ptr | RADIX_TREE_DIRECT_PTR);
+	return (void *)((unsigned long)ptr | RADIX_TREE_INDIRECT_PTR);
 }
 
-static inline void *radix_tree_direct_to_ptr(void *ptr)
+static inline void *radix_tree_indirect_to_ptr(void *ptr)
 {
-	return (void *)((unsigned long)ptr & ~RADIX_TREE_DIRECT_PTR);
+	return (void *)((unsigned long)ptr & ~RADIX_TREE_INDIRECT_PTR);
 }
 
-static inline int radix_tree_is_direct_ptr(void *ptr)
+static inline int radix_tree_is_indirect_ptr(void *ptr)
 {
-	return (int)((unsigned long)ptr & RADIX_TREE_DIRECT_PTR);
+	return (int)((unsigned long)ptr & RADIX_TREE_INDIRECT_PTR);
 }
 
 /*** radix-tree API starts here ***/
@@ -130,7 +133,10 @@ do {									\
  */
 static inline void *radix_tree_deref_slot(void **pslot)
 {
-	return radix_tree_direct_to_ptr(*pslot);
+	void *ret = *pslot;
+	if (unlikely(radix_tree_is_indirect_ptr(ret)))
+		ret = RADIX_TREE_RETRY;
+	return ret;
 }
 /**
  * radix_tree_replace_slot	- replace item in a slot
@@ -142,10 +148,8 @@ static inline void *radix_tree_deref_slo
  */
 static inline void radix_tree_replace_slot(void **pslot, void *item)
 {
-	BUG_ON(radix_tree_is_direct_ptr(item));
-	rcu_assign_pointer(*pslot,
-		(void *)((unsigned long)item |
-			((unsigned long)*pslot & RADIX_TREE_DIRECT_PTR)));
+	BUG_ON(radix_tree_is_indirect_ptr(item));
+	rcu_assign_pointer(*pslot, item);
 }
 
 int radix_tree_insert(struct radix_tree_root *, unsigned long, void *);
Index: linux-2.6/lib/radix-tree.c
===================================================================
--- linux-2.6.orig/lib/radix-tree.c	2007-01-22 20:09:50.000000000 +0100
+++ linux-2.6/lib/radix-tree.c	2007-01-22 20:09:53.000000000 +0100
@@ -104,7 +104,7 @@ radix_tree_node_alloc(struct radix_tree_
 			rtp->nr--;
 		}
 	}
-	BUG_ON(radix_tree_is_direct_ptr(ret));
+	BUG_ON(radix_tree_is_indirect_ptr(ret));
 	return ret;
 }
 
@@ -239,7 +239,7 @@ static int radix_tree_extend(struct radi
 			return -ENOMEM;
 
 		/* Increase the height.  */
-		node->slots[0] = radix_tree_direct_to_ptr(root->rnode);
+		node->slots[0] = radix_tree_indirect_to_ptr(root->rnode);
 
 		/* Propagate the aggregated tag info into the new root */
 		for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++) {
@@ -250,6 +250,7 @@ static int radix_tree_extend(struct radi
 		newheight = root->height+1;
 		node->height = newheight;
 		node->count = 1;
+		node = radix_tree_ptr_to_indirect(node);
 		rcu_assign_pointer(root->rnode, node);
 		root->height = newheight;
 	} while (height > root->height);
@@ -273,7 +274,7 @@ int radix_tree_insert(struct radix_tree_
 	int offset;
 	int error;
 
-	BUG_ON(radix_tree_is_direct_ptr(item));
+	BUG_ON(radix_tree_is_indirect_ptr(item));
 
 	/* Make sure the tree is high enough.  */
 	if (index > radix_tree_maxindex(root->height)) {
@@ -282,7 +283,8 @@ int radix_tree_insert(struct radix_tree_
 			return error;
 	}
 
-	slot = root->rnode;
+	slot = radix_tree_indirect_to_ptr(root->rnode);
+
 	height = root->height;
 	shift = (height-1) * RADIX_TREE_MAP_SHIFT;
 
@@ -297,7 +299,8 @@ int radix_tree_insert(struct radix_tree_
 				rcu_assign_pointer(node->slots[offset], slot);
 				node->count++;
 			} else
-				rcu_assign_pointer(root->rnode, slot);
+				rcu_assign_pointer(root->rnode,
+					radix_tree_ptr_to_indirect(slot));
 		}
 
 		/* Go a level down */
@@ -317,7 +320,7 @@ int radix_tree_insert(struct radix_tree_
 		BUG_ON(tag_get(node, 0, offset));
 		BUG_ON(tag_get(node, 1, offset));
 	} else {
-		rcu_assign_pointer(root->rnode, radix_tree_ptr_to_direct(item));
+		rcu_assign_pointer(root->rnode, item);
 		BUG_ON(root_tag_get(root, 0));
 		BUG_ON(root_tag_get(root, 1));
 	}
@@ -349,11 +352,12 @@ void **radix_tree_lookup_slot(struct rad
 	if (node == NULL)
 		return NULL;
 
-	if (radix_tree_is_direct_ptr(node)) {
+	if (!radix_tree_is_indirect_ptr(node)) {
 		if (index > 0)
 			return NULL;
 		return (void **)&root->rnode;
 	}
+	node = radix_tree_indirect_to_ptr(node);
 
 	height = node->height;
 	if (index > radix_tree_maxindex(height))
@@ -397,11 +401,12 @@ void *radix_tree_lookup(struct radix_tre
 	if (node == NULL)
 		return NULL;
 
-	if (radix_tree_is_direct_ptr(node)) {
+	if (!radix_tree_is_indirect_ptr(node)) {
 		if (index > 0)
 			return NULL;
-		return radix_tree_direct_to_ptr(node);
+		return node;
 	}
+	node = radix_tree_indirect_to_ptr(node);
 
 	height = node->height;
 	if (index > radix_tree_maxindex(height))
@@ -446,7 +451,7 @@ void *radix_tree_tag_set(struct radix_tr
 	height = root->height;
 	BUG_ON(index > radix_tree_maxindex(height));
 
-	slot = root->rnode;
+	slot = radix_tree_indirect_to_ptr(root->rnode);
 	shift = (height - 1) * RADIX_TREE_MAP_SHIFT;
 
 	while (height > 0) {
@@ -496,7 +501,7 @@ void *radix_tree_tag_clear(struct radix_
 
 	shift = (height - 1) * RADIX_TREE_MAP_SHIFT;
 	pathp->node = NULL;
-	slot = root->rnode;
+	slot = radix_tree_indirect_to_ptr(root->rnode);
 
 	while (height > 0) {
 		int offset;
@@ -561,8 +566,9 @@ int radix_tree_tag_get(struct radix_tree
 	if (node == NULL)
 		return 0;
 
-	if (radix_tree_is_direct_ptr(node))
+	if (!radix_tree_is_indirect_ptr(node))
 		return (index == 0);
+	node = radix_tree_indirect_to_ptr(node);
 
 	height = node->height;
 	if (index > radix_tree_maxindex(height))
@@ -679,13 +685,13 @@ radix_tree_gang_lookup(struct radix_tree
 	if (!node)
 		return 0;
 
-	if (radix_tree_is_direct_ptr(node)) {
+	if (!radix_tree_is_indirect_ptr(node)) {
 		if (first_index > 0)
 			return 0;
-		node = radix_tree_direct_to_ptr(node);
-		results[0] = rcu_dereference(node);
+		results[0] = node;
 		return 1;
 	}
+	node = radix_tree_indirect_to_ptr(node);
 
 	max_index = radix_tree_maxindex(node->height);
 
@@ -807,13 +813,13 @@ radix_tree_gang_lookup_tag(struct radix_
 	if (!node)
 		return 0;
 
-	if (radix_tree_is_direct_ptr(node)) {
+	if (!radix_tree_is_indirect_ptr(node)) {
 		if (first_index > 0)
 			return 0;
-		node = radix_tree_direct_to_ptr(node);
-		results[0] = rcu_dereference(node);
+		results[0] = node;
 		return 1;
 	}
+	node = radix_tree_indirect_to_ptr(node);
 
 	max_index = radix_tree_maxindex(node->height);
 
@@ -843,12 +849,22 @@ EXPORT_SYMBOL(radix_tree_gang_lookup_tag
 static inline void radix_tree_shrink(struct radix_tree_root *root)
 {
 	/* try to shrink tree height */
-	while (root->height > 0 &&
-			root->rnode->count == 1 &&
-			root->rnode->slots[0]) {
+	while (root->height > 0) {
 		struct radix_tree_node *to_free = root->rnode;
 		void *newptr;
 
+		BUG_ON(!radix_tree_is_indirect_ptr(to_free));
+		to_free = radix_tree_indirect_to_ptr(to_free);
+
+		/*
+		 * The candidate node has more than one child, or its child
+		 * is not at the leftmost slot, we cannot shrink.
+		 */
+		if (to_free->count != 1)
+			break;
+		if (!to_free->slots[0])
+			break;
+
 		/*
 		 * We don't need rcu_assign_pointer(), since we are simply
 		 * moving the node from one part of the tree to another. If
@@ -857,8 +873,8 @@ static inline void radix_tree_shrink(str
 		 * one (root->rnode).
 		 */
 		newptr = to_free->slots[0];
-		if (root->height == 1)
-			newptr = radix_tree_ptr_to_direct(newptr);
+		if (root->height > 1)
+			newptr = radix_tree_ptr_to_indirect(newptr);
 		root->rnode = newptr;
 		root->height--;
 		/* must only free zeroed nodes into the slab */
@@ -893,12 +909,12 @@ void *radix_tree_delete(struct radix_tre
 		goto out;
 
 	slot = root->rnode;
-	if (height == 0 && root->rnode) {
-		slot = radix_tree_direct_to_ptr(slot);
+	if (height == 0 /* XXX: bugfix? */) {
 		root_tag_clear_all(root);
 		root->rnode = NULL;
 		goto out;
 	}
+	slot = radix_tree_indirect_to_ptr(slot);
 
 	shift = (height - 1) * RADIX_TREE_MAP_SHIFT;
 	pathp->node = NULL;
@@ -940,7 +956,8 @@ void *radix_tree_delete(struct radix_tre
 			radix_tree_node_free(to_free);
 
 		if (pathp->node->count) {
-			if (pathp->node == root->rnode)
+			if (pathp->node ==
+					radix_tree_indirect_to_ptr(root->rnode))
 				radix_tree_shrink(root);
 			goto out;
 		}

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
