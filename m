Message-Id: <20061207162733.195932000@chello.nl>
References: <20061207161800.426936000@chello.nl>
Date: Thu, 07 Dec 2006 17:18:01 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: [PATCH 01/16] radix-tree: RCU lockless readside
Content-Disposition: inline; filename=radix-tree-rcu-lockless-readside.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Make radix tree lookups safe to be performed without locks.  Readers are
protected against nodes being deleted by using RCU based freeing.  Readers
are protected against new node insertion by using memory barriers to ensure
the node itself will be properly written before it is visible in the radix
tree.

Each radix tree node keeps a record of their height (above leaf nodes). 
This height does not change after insertion -- when the radix tree is
extended, higher nodes are only inserted in the top.  So a lookup can take
the pointer to what is *now* the root node, and traverse down it even if
the tree is concurrently extended and this node becomes a subtree of a new
root.

"Direct" pointers (tree height of 0, where root->rnode points directly to
the data item) are handled by using the low bit of the pointer to signal
whether rnode is a direct pointer or a pointer to a radix tree node.

When a reader wants to traverse the next branch, they will take a copy of
the pointer.  This pointer will be either NULL (and the branch is empty) or
non-NULL (and will point to a valid node).

[akpm@osdl.org: cleanups]
[Lee.Schermerhorn@hp.com: bugfixes, comments, simplifications]
[clameter@sgi.com: build fix]
Signed-off-by: Nick Piggin <npiggin@suse.de>
Cc: "Paul E. McKenney" <paulmck@us.ibm.com>
Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: Christoph Lameter <clameter@engr.sgi.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 include/linux/radix-tree.h |  101 +++++++++++++
 lib/radix-tree.c           |  327 +++++++++++++++++++++++++++++++--------------
 mm/migrate.c               |   19 +-
 3 files changed, 340 insertions(+), 107 deletions(-)

Index: linux-2.6-rt/include/linux/radix-tree.h
===================================================================
--- linux-2.6-rt.orig/include/linux/radix-tree.h	2006-11-29 14:20:37.000000000 +0100
+++ linux-2.6-rt/include/linux/radix-tree.h	2006-11-29 14:20:39.000000000 +0100
@@ -1,6 +1,7 @@
 /*
  * Copyright (C) 2001 Momchil Velikov
  * Portions Copyright (C) 2001 Christoph Hellwig
+ * Copyright (C) 2006 Nick Piggin
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License as
@@ -22,6 +23,35 @@
 #include <linux/sched.h>
 #include <linux/preempt.h>
 #include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/rcupdate.h>
+
+/*
+ * A direct pointer (root->rnode pointing directly to a data item,
+ * rather than another radix_tree_node) is signalled by the low bit
+ * set in the root->rnode pointer.
+ *
+ * In this case root->height is also NULL, but the direct pointer tests are
+ * needed for RCU lookups when root->height is unreliable.
+ */
+#define RADIX_TREE_DIRECT_PTR	1
+
+static inline void *radix_tree_ptr_to_direct(void *ptr)
+{
+	return (void *)((unsigned long)ptr | RADIX_TREE_DIRECT_PTR);
+}
+
+static inline void *radix_tree_direct_to_ptr(void *ptr)
+{
+	return (void *)((unsigned long)ptr & ~RADIX_TREE_DIRECT_PTR);
+}
+
+static inline int radix_tree_is_direct_ptr(void *ptr)
+{
+	return (int)((unsigned long)ptr & RADIX_TREE_DIRECT_PTR);
+}
+
+/*** radix-tree API starts here ***/
 
 #define RADIX_TREE_MAX_TAGS 2
 
@@ -48,6 +78,77 @@ do {									\
 	(root)->rnode = NULL;						\
 } while (0)
 
+/**
+ * Radix-tree synchronization
+ *
+ * The radix-tree API requires that users provide all synchronisation (with
+ * specific exceptions, noted below).
+ *
+ * Synchronization of access to the data items being stored in the tree, and
+ * management of their lifetimes must be completely managed by API users.
+ *
+ * For API usage, in general,
+ * - any function _modifying_ the the tree or tags (inserting or deleting
+ *   items, setting or clearing tags must exclude other modifications, and
+ *   exclude any functions reading the tree.
+ * - any function _reading_ the the tree or tags (looking up items or tags,
+ *   gang lookups) must exclude modifications to the tree, but may occur
+ *   concurrently with other readers.
+ *
+ * The notable exceptions to this rule are the following functions:
+ * radix_tree_lookup
+ * radix_tree_tag_get
+ * radix_tree_gang_lookup
+ * radix_tree_gang_lookup_tag
+ * radix_tree_tagged
+ *
+ * The first 4 functions are able to be called locklessly, using RCU. The
+ * caller must ensure calls to these functions are made within rcu_read_lock()
+ * regions. Other readers (lock-free or otherwise) and modifications may be
+ * running concurrently.
+ *
+ * It is still required that the caller manage the synchronization and lifetimes
+ * of the items. So if RCU lock-free lookups are used, typically this would mean
+ * that the items have their own locks, or are amenable to lock-free access; and
+ * that the items are freed by RCU (or only freed after having been deleted from
+ * the radix tree *and* a synchronize_rcu() grace period).
+ *
+ * (Note, rcu_assign_pointer and rcu_dereference are not needed to control
+ * access to data items when inserting into or looking up from the radix tree)
+ *
+ * radix_tree_tagged is able to be called without locking or RCU.
+ */
+
+/**
+ * radix_tree_deref_slot	- dereference a slot
+ * @pslot:	pointer to slot, returned by radix_tree_lookup_slot
+ * Returns:	item that was stored in that slot with any direct pointer flag
+ *		removed.
+ *
+ * For use with radix_tree_lookup_slot().  Caller must hold tree at least read
+ * locked across slot lookup and dereference.  More likely, will be used with
+ * radix_tree_replace_slot(), as well, so caller will hold tree write locked.
+ */
+static inline void *radix_tree_deref_slot(void **pslot)
+{
+	return radix_tree_direct_to_ptr(*pslot);
+}
+/**
+ * radix_tree_replace_slot	- replace item in a slot
+ * @pslot:	pointer to slot, returned by radix_tree_lookup_slot
+ * @item:	new item to store in the slot.
+ *
+ * For use with radix_tree_lookup_slot().  Caller must hold tree write locked
+ * across slot lookup and replacement.
+ */
+static inline void radix_tree_replace_slot(void **pslot, void *item)
+{
+	BUG_ON(radix_tree_is_direct_ptr(item));
+	rcu_assign_pointer(*pslot,
+		(void *)((unsigned long)item |
+			((unsigned long)*pslot & RADIX_TREE_DIRECT_PTR)));
+}
+
 int radix_tree_insert(struct radix_tree_root *, unsigned long, void *);
 void *radix_tree_lookup(struct radix_tree_root *, unsigned long);
 void **radix_tree_lookup_slot(struct radix_tree_root *, unsigned long);
Index: linux-2.6-rt/lib/radix-tree.c
===================================================================
--- linux-2.6-rt.orig/lib/radix-tree.c	2006-11-29 14:20:37.000000000 +0100
+++ linux-2.6-rt/lib/radix-tree.c	2006-11-29 14:20:39.000000000 +0100
@@ -2,6 +2,7 @@
  * Copyright (C) 2001 Momchil Velikov
  * Portions Copyright (C) 2001 Christoph Hellwig
  * Copyright (C) 2005 SGI, Christoph Lameter <clameter@sgi.com>
+ * Copyright (C) 2006 Nick Piggin
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License as
@@ -30,6 +31,7 @@
 #include <linux/gfp.h>
 #include <linux/string.h>
 #include <linux/bitops.h>
+#include <linux/rcupdate.h>
 
 
 #ifdef __KERNEL__
@@ -45,7 +47,9 @@
 	((RADIX_TREE_MAP_SIZE + BITS_PER_LONG - 1) / BITS_PER_LONG)
 
 struct radix_tree_node {
+	unsigned int	height;		/* Height from the bottom */
 	unsigned int	count;
+	struct rcu_head	rcu_head;
 	void		*slots[RADIX_TREE_MAP_SIZE];
 	unsigned long	tags[RADIX_TREE_MAX_TAGS][RADIX_TREE_TAG_LONGS];
 };
@@ -100,13 +104,21 @@ radix_tree_node_alloc(struct radix_tree_
 			rtp->nr--;
 		}
 	}
+	BUG_ON(radix_tree_is_direct_ptr(ret));
 	return ret;
 }
 
+static void radix_tree_node_rcu_free(struct rcu_head *head)
+{
+	struct radix_tree_node *node =
+			container_of(head, struct radix_tree_node, rcu_head);
+	kmem_cache_free(radix_tree_node_cachep, node);
+}
+
 static inline void
 radix_tree_node_free(struct radix_tree_node *node)
 {
-	kmem_cache_free(radix_tree_node_cachep, node);
+	call_rcu(&node->rcu_head, radix_tree_node_rcu_free);
 }
 
 #ifndef CONFIG_PREEMPT_RT
@@ -225,11 +237,12 @@ static int radix_tree_extend(struct radi
 	}
 
 	do {
+		unsigned int newheight;
 		if (!(node = radix_tree_node_alloc(root)))
 			return -ENOMEM;
 
 		/* Increase the height.  */
-		node->slots[0] = root->rnode;
+		node->slots[0] = radix_tree_direct_to_ptr(root->rnode);
 
 		/* Propagate the aggregated tag info into the new root */
 		for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++) {
@@ -237,9 +250,11 @@ static int radix_tree_extend(struct radi
 				tag_set(node, tag, 0);
 		}
 
+		newheight = root->height+1;
+		node->height = newheight;
 		node->count = 1;
-		root->rnode = node;
-		root->height++;
+		rcu_assign_pointer(root->rnode, node);
+		root->height = newheight;
 	} while (height > root->height);
 out:
 	return 0;
@@ -261,6 +276,8 @@ int radix_tree_insert(struct radix_tree_
 	int offset;
 	int error;
 
+	BUG_ON(radix_tree_is_direct_ptr(item));
+
 	/* Make sure the tree is high enough.  */
 	if (index > radix_tree_maxindex(root->height)) {
 		error = radix_tree_extend(root, index);
@@ -278,11 +295,12 @@ int radix_tree_insert(struct radix_tree_
 			/* Have to add a child node.  */
 			if (!(slot = radix_tree_node_alloc(root)))
 				return -ENOMEM;
+			slot->height = height;
 			if (node) {
-				node->slots[offset] = slot;
+				rcu_assign_pointer(node->slots[offset], slot);
 				node->count++;
 			} else
-				root->rnode = slot;
+				rcu_assign_pointer(root->rnode, slot);
 		}
 
 		/* Go a level down */
@@ -298,11 +316,11 @@ int radix_tree_insert(struct radix_tree_
 
 	if (node) {
 		node->count++;
-		node->slots[offset] = item;
+		rcu_assign_pointer(node->slots[offset], item);
 		BUG_ON(tag_get(node, 0, offset));
 		BUG_ON(tag_get(node, 1, offset));
 	} else {
-		root->rnode = item;
+		rcu_assign_pointer(root->rnode, radix_tree_ptr_to_direct(item));
 		BUG_ON(root_tag_get(root, 0));
 		BUG_ON(root_tag_get(root, 1));
 	}
@@ -311,49 +329,54 @@ int radix_tree_insert(struct radix_tree_
 }
 EXPORT_SYMBOL(radix_tree_insert);
 
-static inline void **__lookup_slot(struct radix_tree_root *root,
-				   unsigned long index)
+/**
+ *	radix_tree_lookup_slot    -    lookup a slot in a radix tree
+ *	@root:		radix tree root
+ *	@index:		index key
+ *
+ *	Returns:  the slot corresponding to the position @index in the
+ *	radix tree @root. This is useful for update-if-exists operations.
+ *
+ *	This function cannot be called under rcu_read_lock, it must be
+ *	excluded from writers, as must the returned slot for subsequent
+ *	use by radix_tree_deref_slot() and radix_tree_replace slot.
+ *	Caller must hold tree write locked across slot lookup and
+ *	replace.
+ */
+void **radix_tree_lookup_slot(struct radix_tree_root *root, unsigned long index)
 {
 	unsigned int height, shift;
-	struct radix_tree_node **slot;
-
-	height = root->height;
+	struct radix_tree_node *node, **slot;
 
-	if (index > radix_tree_maxindex(height))
+	node = root->rnode;
+	if (node == NULL)
 		return NULL;
 
-	if (height == 0 && root->rnode)
+	if (radix_tree_is_direct_ptr(node)) {
+		if (index > 0)
+			return NULL;
 		return (void **)&root->rnode;
+	}
+
+	height = node->height;
+	if (index > radix_tree_maxindex(height))
+		return NULL;
 
 	shift = (height-1) * RADIX_TREE_MAP_SHIFT;
-	slot = &root->rnode;
 
-	while (height > 0) {
-		if (*slot == NULL)
+	do {
+		slot = (struct radix_tree_node **)
+			(node->slots + ((index>>shift) & RADIX_TREE_MAP_MASK));
+		node = *slot;
+		if (node == NULL)
 			return NULL;
 
-		slot = (struct radix_tree_node **)
-			((*slot)->slots +
-				((index >> shift) & RADIX_TREE_MAP_MASK));
 		shift -= RADIX_TREE_MAP_SHIFT;
 		height--;
-	}
+	} while (height > 0);
 
 	return (void **)slot;
 }
-
-/**
- *	radix_tree_lookup_slot    -    lookup a slot in a radix tree
- *	@root:		radix tree root
- *	@index:		index key
- *
- *	Lookup the slot corresponding to the position @index in the radix tree
- *	@root. This is useful for update-if-exists operations.
- */
-void **radix_tree_lookup_slot(struct radix_tree_root *root, unsigned long index)
-{
-	return __lookup_slot(root, index);
-}
 EXPORT_SYMBOL(radix_tree_lookup_slot);
 
 /**
@@ -362,13 +385,45 @@ EXPORT_SYMBOL(radix_tree_lookup_slot);
  *	@index:		index key
  *
  *	Lookup the item at the position @index in the radix tree @root.
+ *
+ *	This function can be called under rcu_read_lock, however the caller
+ *	must manage lifetimes of leaf nodes (eg. RCU may also be used to free
+ *	them safely). No RCU barriers are required to access or modify the
+ *	returned item, however.
  */
 void *radix_tree_lookup(struct radix_tree_root *root, unsigned long index)
 {
-	void **slot;
+	unsigned int height, shift;
+	struct radix_tree_node *node, **slot;
+
+	node = rcu_dereference(root->rnode);
+	if (node == NULL)
+		return NULL;
+
+	if (radix_tree_is_direct_ptr(node)) {
+		if (index > 0)
+			return NULL;
+		return radix_tree_direct_to_ptr(node);
+	}
+
+	height = node->height;
+	if (index > radix_tree_maxindex(height))
+		return NULL;
+
+	shift = (height-1) * RADIX_TREE_MAP_SHIFT;
 
-	slot = __lookup_slot(root, index);
-	return slot != NULL ? *slot : NULL;
+	do {
+		slot = (struct radix_tree_node **)
+			(node->slots + ((index>>shift) & RADIX_TREE_MAP_MASK));
+		node = rcu_dereference(*slot);
+		if (node == NULL)
+			return NULL;
+
+		shift -= RADIX_TREE_MAP_SHIFT;
+		height--;
+	} while (height > 0);
+
+	return node;
 }
 EXPORT_SYMBOL(radix_tree_lookup);
 
@@ -498,27 +553,30 @@ int radix_tree_tag_get(struct radix_tree
 			unsigned long index, unsigned int tag)
 {
 	unsigned int height, shift;
-	struct radix_tree_node *slot;
+	struct radix_tree_node *node;
 	int saw_unset_tag = 0;
 
-	height = root->height;
-	if (index > radix_tree_maxindex(height))
-		return 0;
-
 	/* check the root's tag bit */
 	if (!root_tag_get(root, tag))
 		return 0;
 
-	if (height == 0)
-		return 1;
+	node = rcu_dereference(root->rnode);
+	if (node == NULL)
+		return 0;
+
+	if (radix_tree_is_direct_ptr(node))
+		return (index == 0);
+
+	height = node->height;
+	if (index > radix_tree_maxindex(height))
+		return 0;
 
 	shift = (height - 1) * RADIX_TREE_MAP_SHIFT;
-	slot = root->rnode;
 
 	for ( ; ; ) {
 		int offset;
 
-		if (slot == NULL)
+		if (node == NULL)
 			return 0;
 
 		offset = (index >> shift) & RADIX_TREE_MAP_MASK;
@@ -527,15 +585,15 @@ int radix_tree_tag_get(struct radix_tree
 		 * This is just a debug check.  Later, we can bale as soon as
 		 * we see an unset tag.
 		 */
-		if (!tag_get(slot, tag, offset))
+		if (!tag_get(node, tag, offset))
 			saw_unset_tag = 1;
 		if (height == 1) {
-			int ret = tag_get(slot, tag, offset);
+			int ret = tag_get(node, tag, offset);
 
 			BUG_ON(ret && saw_unset_tag);
 			return !!ret;
 		}
-		slot = slot->slots[offset];
+		node = rcu_dereference(node->slots[offset]);
 		shift -= RADIX_TREE_MAP_SHIFT;
 		height--;
 	}
@@ -544,47 +602,45 @@ EXPORT_SYMBOL(radix_tree_tag_get);
 #endif
 
 static unsigned int
-__lookup(struct radix_tree_root *root, void **results, unsigned long index,
+__lookup(struct radix_tree_node *slot, void **results, unsigned long index,
 	unsigned int max_items, unsigned long *next_index)
 {
 	unsigned int nr_found = 0;
 	unsigned int shift, height;
-	struct radix_tree_node *slot;
 	unsigned long i;
 
-	height = root->height;
-	if (height == 0) {
-		if (root->rnode && index == 0)
-			results[nr_found++] = root->rnode;
+	height = slot->height;
+	if (height == 0)
 		goto out;
-	}
-
 	shift = (height-1) * RADIX_TREE_MAP_SHIFT;
-	slot = root->rnode;
 
 	for ( ; height > 1; height--) {
-
-		for (i = (index >> shift) & RADIX_TREE_MAP_MASK ;
-				i < RADIX_TREE_MAP_SIZE; i++) {
+		i = (index >> shift) & RADIX_TREE_MAP_MASK;
+		for (;;) {
 			if (slot->slots[i] != NULL)
 				break;
 			index &= ~((1UL << shift) - 1);
 			index += 1UL << shift;
 			if (index == 0)
 				goto out;	/* 32-bit wraparound */
+			i++;
+			if (i == RADIX_TREE_MAP_SIZE)
+				goto out;
 		}
-		if (i == RADIX_TREE_MAP_SIZE)
-			goto out;
 
 		shift -= RADIX_TREE_MAP_SHIFT;
-		slot = slot->slots[i];
+		slot = rcu_dereference(slot->slots[i]);
+		if (slot == NULL)
+			goto out;
 	}
 
 	/* Bottom level: grab some items */
 	for (i = index & RADIX_TREE_MAP_MASK; i < RADIX_TREE_MAP_SIZE; i++) {
+		struct radix_tree_node *node;
 		index++;
-		if (slot->slots[i]) {
-			results[nr_found++] = slot->slots[i];
+		node = slot->slots[i];
+		if (node) {
+			results[nr_found++] = rcu_dereference(node);
 			if (nr_found == max_items)
 				goto out;
 		}
@@ -606,28 +662,51 @@ out:
  *	*@results.
  *
  *	The implementation is naive.
+ *
+ *	Like radix_tree_lookup, radix_tree_gang_lookup may be called under
+ *	rcu_read_lock. In this case, rather than the returned results being
+ *	an atomic snapshot of the tree at a single point in time, the semantics
+ *	of an RCU protected gang lookup are as though multiple radix_tree_lookups
+ *	have been issued in individual locks, and results stored in 'results'.
  */
 unsigned int
 radix_tree_gang_lookup(struct radix_tree_root *root, void **results,
 			unsigned long first_index, unsigned int max_items)
 {
-	const unsigned long max_index = radix_tree_maxindex(root->height);
+	unsigned long max_index;
+	struct radix_tree_node *node;
 	unsigned long cur_index = first_index;
-	unsigned int ret = 0;
+	unsigned int ret;
+
+	node = rcu_dereference(root->rnode);
+	if (!node)
+		return 0;
 
+	if (radix_tree_is_direct_ptr(node)) {
+		if (first_index > 0)
+			return 0;
+		node = radix_tree_direct_to_ptr(node);
+		results[0] = rcu_dereference(node);
+		return 1;
+	}
+
+	max_index = radix_tree_maxindex(node->height);
+
+	ret = 0;
 	while (ret < max_items) {
 		unsigned int nr_found;
 		unsigned long next_index;	/* Index of next search */
 
 		if (cur_index > max_index)
 			break;
-		nr_found = __lookup(root, results + ret, cur_index,
+		nr_found = __lookup(node, results + ret, cur_index,
 					max_items - ret, &next_index);
 		ret += nr_found;
 		if (next_index == 0)
 			break;
 		cur_index = next_index;
 	}
+
 	return ret;
 }
 EXPORT_SYMBOL(radix_tree_gang_lookup);
@@ -637,55 +716,64 @@ EXPORT_SYMBOL(radix_tree_gang_lookup);
  * open-coding the search.
  */
 static unsigned int
-__lookup_tag(struct radix_tree_root *root, void **results, unsigned long index,
+__lookup_tag(struct radix_tree_node *slot, void **results, unsigned long index,
 	unsigned int max_items, unsigned long *next_index, unsigned int tag)
 {
 	unsigned int nr_found = 0;
-	unsigned int shift;
-	unsigned int height = root->height;
-	struct radix_tree_node *slot;
+	unsigned int shift, height;
 
-	if (height == 0) {
-		if (root->rnode && index == 0)
-			results[nr_found++] = root->rnode;
+	height = slot->height;
+	if (height == 0)
 		goto out;
-	}
-
-	shift = (height - 1) * RADIX_TREE_MAP_SHIFT;
-	slot = root->rnode;
+	shift = (height-1) * RADIX_TREE_MAP_SHIFT;
 
-	do {
-		unsigned long i = (index >> shift) & RADIX_TREE_MAP_MASK;
+	while (height > 0) {
+		unsigned long i = (index >> shift) & RADIX_TREE_MAP_MASK ;
 
-		for ( ; i < RADIX_TREE_MAP_SIZE; i++) {
-			if (tag_get(slot, tag, i)) {
-				BUG_ON(slot->slots[i] == NULL);
+		for (;;) {
+			if (tag_get(slot, tag, i))
 				break;
-			}
 			index &= ~((1UL << shift) - 1);
 			index += 1UL << shift;
 			if (index == 0)
 				goto out;	/* 32-bit wraparound */
+			i++;
+			if (i == RADIX_TREE_MAP_SIZE)
+				goto out;
 		}
-		if (i == RADIX_TREE_MAP_SIZE)
-			goto out;
 		height--;
 		if (height == 0) {	/* Bottom level: grab some items */
 			unsigned long j = index & RADIX_TREE_MAP_MASK;
 
 			for ( ; j < RADIX_TREE_MAP_SIZE; j++) {
+				struct radix_tree_node *node;
 				index++;
-				if (tag_get(slot, tag, j)) {
-					BUG_ON(slot->slots[j] == NULL);
-					results[nr_found++] = slot->slots[j];
+				if (!tag_get(slot, tag, j))
+					continue;
+				node = slot->slots[j];
+				/*
+				 * Even though the tag was found set, we need to
+				 * recheck that we have a non-NULL node, because
+				 * if this lookup is lockless, it may have been
+				 * subsequently deleted.
+				 *
+				 * Similar care must be taken in any place that
+				 * lookup ->slots[x] without a lock (ie. can't
+				 * rely on its value remaining the same).
+				 */
+				if (node) {
+					node = rcu_dereference(node);
+					results[nr_found++] = node;
 					if (nr_found == max_items)
 						goto out;
 				}
 			}
 		}
 		shift -= RADIX_TREE_MAP_SHIFT;
-		slot = slot->slots[i];
-	} while (height > 0);
+		slot = rcu_dereference(slot->slots[i]);
+		if (slot == NULL)
+			break;
+	}
 out:
 	*next_index = index;
 	return nr_found;
@@ -709,27 +797,44 @@ radix_tree_gang_lookup_tag(struct radix_
 		unsigned long first_index, unsigned int max_items,
 		unsigned int tag)
 {
-	const unsigned long max_index = radix_tree_maxindex(root->height);
+	struct radix_tree_node *node;
+	unsigned long max_index;
 	unsigned long cur_index = first_index;
-	unsigned int ret = 0;
+	unsigned int ret;
 
 	/* check the root's tag bit */
 	if (!root_tag_get(root, tag))
 		return 0;
 
+	node = rcu_dereference(root->rnode);
+	if (!node)
+		return 0;
+
+	if (radix_tree_is_direct_ptr(node)) {
+		if (first_index > 0)
+			return 0;
+		node = radix_tree_direct_to_ptr(node);
+		results[0] = rcu_dereference(node);
+		return 1;
+	}
+
+	max_index = radix_tree_maxindex(node->height);
+
+	ret = 0;
 	while (ret < max_items) {
 		unsigned int nr_found;
 		unsigned long next_index;	/* Index of next search */
 
 		if (cur_index > max_index)
 			break;
-		nr_found = __lookup_tag(root, results + ret, cur_index,
+		nr_found = __lookup_tag(node, results + ret, cur_index,
 					max_items - ret, &next_index, tag);
 		ret += nr_found;
 		if (next_index == 0)
 			break;
 		cur_index = next_index;
 	}
+
 	return ret;
 }
 EXPORT_SYMBOL(radix_tree_gang_lookup_tag);
@@ -745,8 +850,19 @@ static inline void radix_tree_shrink(str
 			root->rnode->count == 1 &&
 			root->rnode->slots[0]) {
 		struct radix_tree_node *to_free = root->rnode;
+		void *newptr;
 
-		root->rnode = to_free->slots[0];
+		/*
+		 * We don't need rcu_assign_pointer(), since we are simply
+		 * moving the node from one part of the tree to another. If
+		 * it was safe to dereference the old pointer to it
+		 * (to_free->slots[0]), it will be safe to dereference the new
+		 * one (root->rnode).
+		 */
+		newptr = to_free->slots[0];
+		if (root->height == 1)
+			newptr = radix_tree_ptr_to_direct(newptr);
+		root->rnode = newptr;
 		root->height--;
 		/* must only free zeroed nodes into the slab */
 		tag_clear(to_free, 0, 0);
@@ -770,6 +886,7 @@ void *radix_tree_delete(struct radix_tre
 {
 	struct radix_tree_path path[RADIX_TREE_MAX_PATH], *pathp = path;
 	struct radix_tree_node *slot = NULL;
+	struct radix_tree_node *to_free;
 	unsigned int height, shift;
 	int tag;
 	int offset;
@@ -780,6 +897,7 @@ void *radix_tree_delete(struct radix_tre
 
 	slot = root->rnode;
 	if (height == 0 && root->rnode) {
+		slot = radix_tree_direct_to_ptr(slot);
 		root_tag_clear_all(root);
 		root->rnode = NULL;
 		goto out;
@@ -812,10 +930,17 @@ void *radix_tree_delete(struct radix_tre
 			radix_tree_tag_clear(root, index, tag);
 	}
 
+	to_free = NULL;
 	/* Now free the nodes we do not need anymore */
 	while (pathp->node) {
 		pathp->node->slots[pathp->offset] = NULL;
 		pathp->node->count--;
+		/*
+		 * Queue the node for deferred freeing after the
+		 * last reference to it disappears (set NULL, above).
+		 */
+		if (to_free)
+			radix_tree_node_free(to_free);
 
 		if (pathp->node->count) {
 			if (pathp->node == root->rnode)
@@ -824,13 +949,15 @@ void *radix_tree_delete(struct radix_tre
 		}
 
 		/* Node with zero slots in use so free it */
-		radix_tree_node_free(pathp->node);
-
+		to_free = pathp->node;
 		pathp--;
+
 	}
 	root_tag_clear_all(root);
 	root->height = 0;
 	root->rnode = NULL;
+	if (to_free)
+		radix_tree_node_free(to_free);
 
 out:
 	return slot;
Index: linux-2.6-rt/mm/migrate.c
===================================================================
--- linux-2.6-rt.orig/mm/migrate.c	2006-11-29 14:20:37.000000000 +0100
+++ linux-2.6-rt/mm/migrate.c	2006-11-29 14:20:39.000000000 +0100
@@ -294,7 +294,7 @@ out:
 static int migrate_page_move_mapping(struct address_space *mapping,
 		struct page *newpage, struct page *page)
 {
-	struct page **radix_pointer;
+	void **pslot;
 
 	if (!mapping) {
 		/* Anonymous page */
@@ -305,12 +305,11 @@ static int migrate_page_move_mapping(str
 
 	write_lock_irq(&mapping->tree_lock);
 
-	radix_pointer = (struct page **)radix_tree_lookup_slot(
-						&mapping->page_tree,
-						page_index(page));
+	pslot = radix_tree_lookup_slot(&mapping->page_tree,
+ 					page_index(page));
 
 	if (page_count(page) != 2 + !!PagePrivate(page) ||
-			*radix_pointer != page) {
+			(struct page *)radix_tree_deref_slot(pslot) != page) {
 		write_unlock_irq(&mapping->tree_lock);
 		return -EAGAIN;
 	}
@@ -318,7 +317,7 @@ static int migrate_page_move_mapping(str
 	/*
 	 * Now we know that no one else is looking at the page.
 	 */
-	get_page(newpage);
+	get_page(newpage);	/* add cache reference */
 #ifdef CONFIG_SWAP
 	if (PageSwapCache(page)) {
 		SetPageSwapCache(newpage);
@@ -326,8 +325,14 @@ static int migrate_page_move_mapping(str
 	}
 #endif
 
-	*radix_pointer = newpage;
+	radix_tree_replace_slot(pslot, newpage);
+
+	/*
+	 * Drop cache reference from old page.
+	 * We know this isn't the last reference.
+	 */
 	__put_page(page);
+
 	write_unlock_irq(&mapping->tree_lock);
 
 	return 0;

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
