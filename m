Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f170.google.com (mail-ea0-f170.google.com [209.85.215.170])
	by kanga.kvack.org (Postfix) with ESMTP id 9D14A6B003B
	for <linux-mm@kvack.org>; Mon,  3 Feb 2014 19:58:43 -0500 (EST)
Received: by mail-ea0-f170.google.com with SMTP id k10so4093811eaj.29
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 16:58:43 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id w5si16934270eef.172.2014.02.03.16.58.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 03 Feb 2014 16:58:42 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 09/10] lib: radix_tree: tree node interface
Date: Mon,  3 Feb 2014 19:53:41 -0500
Message-Id: <1391475222-1169-10-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1391475222-1169-1-git-send-email-hannes@cmpxchg.org>
References: <1391475222-1169-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Bob Liu <bob.liu@oracle.com>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Luigi Semenzato <semenzato@google.com>, Mel Gorman <mgorman@suse.de>, Metin Doslu <metin@citusdata.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan.kim@gmail.com>, Ozgun Erdogan <ozgun@citusdata.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Roman Gushchin <klamm@yandex-team.ru>, Ryan Mallon <rmallon@gmail.com>, Tejun Heo <tj@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Make struct radix_tree_node part of the public interface and provide
API functions to create, look up, and delete whole nodes.  Refactor
the existing insert, look up, delete functions on top of these new
node primitives.

This will allow the VM to track and garbage collect page cache radix
tree nodes.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Reviewed-by: Rik van Riel <riel@redhat.com>
---
 include/linux/radix-tree.h |  34 ++++++
 lib/radix-tree.c           | 261 +++++++++++++++++++++++++--------------------
 2 files changed, 180 insertions(+), 115 deletions(-)

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index e8be53ecfc45..13636c40bc42 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -60,6 +60,33 @@ static inline int radix_tree_is_indirect_ptr(void *ptr)
 
 #define RADIX_TREE_MAX_TAGS 3
 
+#ifdef __KERNEL__
+#define RADIX_TREE_MAP_SHIFT	(CONFIG_BASE_SMALL ? 4 : 6)
+#else
+#define RADIX_TREE_MAP_SHIFT	3	/* For more stressful testing */
+#endif
+
+#define RADIX_TREE_MAP_SIZE	(1UL << RADIX_TREE_MAP_SHIFT)
+#define RADIX_TREE_MAP_MASK	(RADIX_TREE_MAP_SIZE-1)
+
+#define RADIX_TREE_TAG_LONGS	\
+	((RADIX_TREE_MAP_SIZE + BITS_PER_LONG - 1) / BITS_PER_LONG)
+
+struct radix_tree_node {
+	unsigned int	height;		/* Height from the bottom */
+	unsigned int	count;
+	union {
+		struct radix_tree_node *parent;	/* Used when ascending tree */
+		struct rcu_head	rcu_head;	/* Used when freeing node */
+	};
+	void __rcu	*slots[RADIX_TREE_MAP_SIZE];
+	unsigned long	tags[RADIX_TREE_MAX_TAGS][RADIX_TREE_TAG_LONGS];
+};
+
+#define RADIX_TREE_INDEX_BITS  (8 /* CHAR_BIT */ * sizeof(unsigned long))
+#define RADIX_TREE_MAX_PATH (DIV_ROUND_UP(RADIX_TREE_INDEX_BITS, \
+					  RADIX_TREE_MAP_SHIFT))
+
 /* root tags are stored in gfp_mask, shifted by __GFP_BITS_SHIFT */
 struct radix_tree_root {
 	unsigned int		height;
@@ -101,6 +128,7 @@ do {									\
  *   concurrently with other readers.
  *
  * The notable exceptions to this rule are the following functions:
+ * __radix_tree_lookup
  * radix_tree_lookup
  * radix_tree_lookup_slot
  * radix_tree_tag_get
@@ -216,9 +244,15 @@ static inline void radix_tree_replace_slot(void **pslot, void *item)
 	rcu_assign_pointer(*pslot, item);
 }
 
+int __radix_tree_create(struct radix_tree_root *root, unsigned long index,
+			struct radix_tree_node **nodep, void ***slotp);
 int radix_tree_insert(struct radix_tree_root *, unsigned long, void *);
+void *__radix_tree_lookup(struct radix_tree_root *root, unsigned long index,
+			  struct radix_tree_node **nodep, void ***slotp);
 void *radix_tree_lookup(struct radix_tree_root *, unsigned long);
 void **radix_tree_lookup_slot(struct radix_tree_root *, unsigned long);
+bool __radix_tree_delete_node(struct radix_tree_root *root, unsigned long index,
+			      struct radix_tree_node *node);
 void *radix_tree_delete_item(struct radix_tree_root *, unsigned long, void *);
 void *radix_tree_delete(struct radix_tree_root *, unsigned long);
 unsigned int
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index e8adb5d8a184..e601c56a43d0 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -35,33 +35,6 @@
 #include <linux/hardirq.h>		/* in_interrupt() */
 
 
-#ifdef __KERNEL__
-#define RADIX_TREE_MAP_SHIFT	(CONFIG_BASE_SMALL ? 4 : 6)
-#else
-#define RADIX_TREE_MAP_SHIFT	3	/* For more stressful testing */
-#endif
-
-#define RADIX_TREE_MAP_SIZE	(1UL << RADIX_TREE_MAP_SHIFT)
-#define RADIX_TREE_MAP_MASK	(RADIX_TREE_MAP_SIZE-1)
-
-#define RADIX_TREE_TAG_LONGS	\
-	((RADIX_TREE_MAP_SIZE + BITS_PER_LONG - 1) / BITS_PER_LONG)
-
-struct radix_tree_node {
-	unsigned int	height;		/* Height from the bottom */
-	unsigned int	count;
-	union {
-		struct radix_tree_node *parent;	/* Used when ascending tree */
-		struct rcu_head	rcu_head;	/* Used when freeing node */
-	};
-	void __rcu	*slots[RADIX_TREE_MAP_SIZE];
-	unsigned long	tags[RADIX_TREE_MAX_TAGS][RADIX_TREE_TAG_LONGS];
-};
-
-#define RADIX_TREE_INDEX_BITS  (8 /* CHAR_BIT */ * sizeof(unsigned long))
-#define RADIX_TREE_MAX_PATH (DIV_ROUND_UP(RADIX_TREE_INDEX_BITS, \
-					  RADIX_TREE_MAP_SHIFT))
-
 /*
  * The height_to_maxindex array needs to be one deeper than the maximum
  * path as height 0 holds only 1 entry.
@@ -387,23 +360,28 @@ out:
 }
 
 /**
- *	radix_tree_insert    -    insert into a radix tree
+ *	__radix_tree_create	-	create a slot in a radix tree
  *	@root:		radix tree root
  *	@index:		index key
- *	@item:		item to insert
+ *	@nodep:		returns node
+ *	@slotp:		returns slot
  *
- *	Insert an item into the radix tree at position @index.
+ *	Create, if necessary, and return the node and slot for an item
+ *	at position @index in the radix tree @root.
+ *
+ *	Until there is more than one item in the tree, no nodes are
+ *	allocated and @root->rnode is used as a direct slot instead of
+ *	pointing to a node, in which case *@nodep will be NULL.
+ *
+ *	Returns -ENOMEM, or 0 for success.
  */
-int radix_tree_insert(struct radix_tree_root *root,
-			unsigned long index, void *item)
+int __radix_tree_create(struct radix_tree_root *root, unsigned long index,
+			struct radix_tree_node **nodep, void ***slotp)
 {
 	struct radix_tree_node *node = NULL, *slot;
-	unsigned int height, shift;
-	int offset;
+	unsigned int height, shift, offset;
 	int error;
 
-	BUG_ON(radix_tree_is_indirect_ptr(item));
-
 	/* Make sure the tree is high enough.  */
 	if (index > radix_tree_maxindex(root->height)) {
 		error = radix_tree_extend(root, index);
@@ -439,16 +417,40 @@ int radix_tree_insert(struct radix_tree_root *root,
 		height--;
 	}
 
-	if (slot != NULL)
+	if (nodep)
+		*nodep = node;
+	if (slotp)
+		*slotp = node ? node->slots + offset : (void **)&root->rnode;
+	return 0;
+}
+
+/**
+ *	radix_tree_insert    -    insert into a radix tree
+ *	@root:		radix tree root
+ *	@index:		index key
+ *	@item:		item to insert
+ *
+ *	Insert an item into the radix tree at position @index.
+ */
+int radix_tree_insert(struct radix_tree_root *root,
+			unsigned long index, void *item)
+{
+	struct radix_tree_node *node;
+	void **slot;
+	int error;
+
+	BUG_ON(radix_tree_is_indirect_ptr(item));
+
+	error = __radix_tree_create(root, index, &node, &slot);
+	if (*slot != NULL)
 		return -EEXIST;
+	rcu_assign_pointer(*slot, item);
 
 	if (node) {
 		node->count++;
-		rcu_assign_pointer(node->slots[offset], item);
-		BUG_ON(tag_get(node, 0, offset));
-		BUG_ON(tag_get(node, 1, offset));
+		BUG_ON(tag_get(node, 0, index & RADIX_TREE_MAP_MASK));
+		BUG_ON(tag_get(node, 1, index & RADIX_TREE_MAP_MASK));
 	} else {
-		rcu_assign_pointer(root->rnode, item);
 		BUG_ON(root_tag_get(root, 0));
 		BUG_ON(root_tag_get(root, 1));
 	}
@@ -457,15 +459,26 @@ int radix_tree_insert(struct radix_tree_root *root,
 }
 EXPORT_SYMBOL(radix_tree_insert);
 
-/*
- * is_slot == 1 : search for the slot.
- * is_slot == 0 : search for the node.
+/**
+ *	__radix_tree_lookup	-	lookup an item in a radix tree
+ *	@root:		radix tree root
+ *	@index:		index key
+ *	@nodep:		returns node
+ *	@slotp:		returns slot
+ *
+ *	Lookup and return the item at position @index in the radix
+ *	tree @root.
+ *
+ *	Until there is more than one item in the tree, no nodes are
+ *	allocated and @root->rnode is used as a direct slot instead of
+ *	pointing to a node, in which case *@nodep will be NULL.
  */
-static void *radix_tree_lookup_element(struct radix_tree_root *root,
-				unsigned long index, int is_slot)
+void *__radix_tree_lookup(struct radix_tree_root *root, unsigned long index,
+			  struct radix_tree_node **nodep, void ***slotp)
 {
+	struct radix_tree_node *node, *parent;
 	unsigned int height, shift;
-	struct radix_tree_node *node, **slot;
+	void **slot;
 
 	node = rcu_dereference_raw(root->rnode);
 	if (node == NULL)
@@ -474,7 +487,12 @@ static void *radix_tree_lookup_element(struct radix_tree_root *root,
 	if (!radix_tree_is_indirect_ptr(node)) {
 		if (index > 0)
 			return NULL;
-		return is_slot ? (void *)&root->rnode : node;
+
+		if (nodep)
+			*nodep = NULL;
+		if (slotp)
+			*slotp = (void **)&root->rnode;
+		return node;
 	}
 	node = indirect_to_ptr(node);
 
@@ -485,8 +503,8 @@ static void *radix_tree_lookup_element(struct radix_tree_root *root,
 	shift = (height-1) * RADIX_TREE_MAP_SHIFT;
 
 	do {
-		slot = (struct radix_tree_node **)
-			(node->slots + ((index>>shift) & RADIX_TREE_MAP_MASK));
+		parent = node;
+		slot = node->slots + ((index >> shift) & RADIX_TREE_MAP_MASK);
 		node = rcu_dereference_raw(*slot);
 		if (node == NULL)
 			return NULL;
@@ -495,7 +513,11 @@ static void *radix_tree_lookup_element(struct radix_tree_root *root,
 		height--;
 	} while (height > 0);
 
-	return is_slot ? (void *)slot : indirect_to_ptr(node);
+	if (nodep)
+		*nodep = parent;
+	if (slotp)
+		*slotp = slot;
+	return node;
 }
 
 /**
@@ -513,7 +535,11 @@ static void *radix_tree_lookup_element(struct radix_tree_root *root,
  */
 void **radix_tree_lookup_slot(struct radix_tree_root *root, unsigned long index)
 {
-	return (void **)radix_tree_lookup_element(root, index, 1);
+	void **slot;
+
+	if (!__radix_tree_lookup(root, index, NULL, &slot))
+		return NULL;
+	return slot;
 }
 EXPORT_SYMBOL(radix_tree_lookup_slot);
 
@@ -531,7 +557,7 @@ EXPORT_SYMBOL(radix_tree_lookup_slot);
  */
 void *radix_tree_lookup(struct radix_tree_root *root, unsigned long index)
 {
-	return radix_tree_lookup_element(root, index, 0);
+	return __radix_tree_lookup(root, index, NULL, NULL);
 }
 EXPORT_SYMBOL(radix_tree_lookup);
 
@@ -1260,6 +1286,56 @@ static inline void radix_tree_shrink(struct radix_tree_root *root)
 }
 
 /**
+ *	__radix_tree_delete_node    -    try to free node after clearing a slot
+ *	@root:		radix tree root
+ *	@index:		index key
+ *	@node:		node containing @index
+ *
+ *	After clearing the slot at @index in @node from radix tree
+ *	rooted at @root, call this function to attempt freeing the
+ *	node and shrinking the tree.
+ *
+ *	Returns %true if @node was freed, %false otherwise.
+ */
+bool __radix_tree_delete_node(struct radix_tree_root *root, unsigned long index,
+			      struct radix_tree_node *node)
+{
+	bool deleted = false;
+
+	do {
+		struct radix_tree_node *parent;
+
+		if (node->count) {
+			if (node == indirect_to_ptr(root->rnode)) {
+				radix_tree_shrink(root);
+				if (root->height == 0)
+					deleted = true;
+			}
+			return deleted;
+		}
+
+		parent = node->parent;
+		if (parent) {
+			index >>= RADIX_TREE_MAP_SHIFT;
+
+			parent->slots[index & RADIX_TREE_MAP_MASK] = NULL;
+			parent->count--;
+		} else {
+			root_tag_clear_all(root);
+			root->height = 0;
+			root->rnode = NULL;
+		}
+
+		radix_tree_node_free(node);
+		deleted = true;
+
+		node = parent;
+	} while (node);
+
+	return deleted;
+}
+
+/**
  *	radix_tree_delete_item    -    delete an item from a radix tree
  *	@root:		radix tree root
  *	@index:		index key
@@ -1273,43 +1349,26 @@ static inline void radix_tree_shrink(struct radix_tree_root *root)
 void *radix_tree_delete_item(struct radix_tree_root *root,
 			     unsigned long index, void *item)
 {
-	struct radix_tree_node *node = NULL;
-	struct radix_tree_node *slot = NULL;
-	struct radix_tree_node *to_free;
-	unsigned int height, shift;
+	struct radix_tree_node *node;
+	unsigned int offset;
+	void **slot;
+	void *entry;
 	int tag;
-	int uninitialized_var(offset);
 
-	height = root->height;
-	if (index > radix_tree_maxindex(height))
-		goto out;
+	entry = __radix_tree_lookup(root, index, &node, &slot);
+	if (!entry)
+		return NULL;
 
-	slot = root->rnode;
-	if (height == 0) {
+	if (item && entry != item)
+		return NULL;
+
+	if (!node) {
 		root_tag_clear_all(root);
 		root->rnode = NULL;
-		goto out;
+		return entry;
 	}
-	slot = indirect_to_ptr(slot);
-	shift = height * RADIX_TREE_MAP_SHIFT;
-
-	do {
-		if (slot == NULL)
-			goto out;
-
-		shift -= RADIX_TREE_MAP_SHIFT;
-		offset = (index >> shift) & RADIX_TREE_MAP_MASK;
-		node = slot;
-		slot = slot->slots[offset];
-	} while (shift);
-
-	if (slot == NULL)
-		goto out;
 
-	if (item && slot != item) {
-		slot = NULL;
-		goto out;
-	}
+	offset = index & RADIX_TREE_MAP_MASK;
 
 	/*
 	 * Clear all tags associated with the item to be deleted.
@@ -1320,40 +1379,12 @@ void *radix_tree_delete_item(struct radix_tree_root *root,
 			radix_tree_tag_clear(root, index, tag);
 	}
 
-	to_free = NULL;
-	/* Now free the nodes we do not need anymore */
-	while (node) {
-		node->slots[offset] = NULL;
-		node->count--;
-		/*
-		 * Queue the node for deferred freeing after the
-		 * last reference to it disappears (set NULL, above).
-		 */
-		if (to_free)
-			radix_tree_node_free(to_free);
-
-		if (node->count) {
-			if (node == indirect_to_ptr(root->rnode))
-				radix_tree_shrink(root);
-			goto out;
-		}
-
-		/* Node with zero slots in use so free it */
-		to_free = node;
-
-		index >>= RADIX_TREE_MAP_SHIFT;
-		offset = index & RADIX_TREE_MAP_MASK;
-		node = node->parent;
-	}
+	node->slots[offset] = NULL;
+	node->count--;
 
-	root_tag_clear_all(root);
-	root->height = 0;
-	root->rnode = NULL;
-	if (to_free)
-		radix_tree_node_free(to_free);
+	__radix_tree_delete_node(root, index, node);
 
-out:
-	return slot;
+	return entry;
 }
 EXPORT_SYMBOL(radix_tree_delete_item);
 
-- 
1.8.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
