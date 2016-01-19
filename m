Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 616BA6B0257
	for <linux-mm@kvack.org>; Tue, 19 Jan 2016 09:25:54 -0500 (EST)
Received: by mail-pf0-f182.google.com with SMTP id n128so176177134pfn.3
        for <linux-mm@kvack.org>; Tue, 19 Jan 2016 06:25:54 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id s7si45978258pfi.10.2016.01.19.06.25.41
        for <linux-mm@kvack.org>;
        Tue, 19 Jan 2016 06:25:41 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH 7/8] radix_tree: Add support for multi-order entries
Date: Tue, 19 Jan 2016 09:25:32 -0500
Message-Id: <1453213533-6040-8-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1453213533-6040-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1453213533-6040-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

From: Matthew Wilcox <willy@linux.intel.com>

With huge pages, it is convenient to have the radix tree be able to
return an entry that covers multiple indices.  Previous attempts to deal
with the problem have involved inserting N duplicate entries, which is
a waste of memory and leads to problems trying to handle aliased tags,
or probing the tree multiple times to find alternative entries which
might cover the requested index.

This approach inserts one canonical entry into the tree for a given
range of indices, and may also insert other entries in order to ensure
that lookups find the canonical entry.

This solution only tolerates inserting powers of two that are greater
than the fanout of the tree.  If we wish to expand the radix tree's
abilities to support large-ish pages that is less than the fanout at the
penultimate level of the tree, then we would need to add one more step
in lookup to ensure that any sibling nodes in the final level of the tree
are dereferenced and we return the canonical entry that they reference.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 include/linux/radix-tree.h |  11 ++++-
 lib/radix-tree.c           | 109 ++++++++++++++++++++++++++++++++++-----------
 mm/filemap.c               |   2 +-
 3 files changed, 93 insertions(+), 29 deletions(-)

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index 35b3d11..f9a3da5 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -271,8 +271,15 @@ static inline void radix_tree_replace_slot(void **pslot, void *item)
 }
 
 int __radix_tree_create(struct radix_tree_root *root, unsigned long index,
-			struct radix_tree_node **nodep, void ***slotp);
-int radix_tree_insert(struct radix_tree_root *, unsigned long, void *);
+			unsigned order, struct radix_tree_node **nodep,
+			void ***slotp);
+int __radix_tree_insert(struct radix_tree_root *, unsigned long index,
+			unsigned order, void *);
+static inline int radix_tree_insert(struct radix_tree_root *root,
+			unsigned long index, void *entry)
+{
+	return __radix_tree_insert(root, index, 0, entry);
+}
 void *__radix_tree_lookup(struct radix_tree_root *root, unsigned long index,
 			  struct radix_tree_node **nodep, void ***slotp);
 void *radix_tree_lookup(struct radix_tree_root *, unsigned long);
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 869be33..be19e4d 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -324,7 +324,8 @@ static inline unsigned long radix_tree_maxindex(unsigned int height)
 /*
  *	Extend a radix tree so it can store key @index.
  */
-static int radix_tree_extend(struct radix_tree_root *root, unsigned long index)
+static int radix_tree_extend(struct radix_tree_root *root,
+				unsigned long index, unsigned order)
 {
 	struct radix_tree_node *node;
 	struct radix_tree_node *slot;
@@ -336,7 +337,7 @@ static int radix_tree_extend(struct radix_tree_root *root, unsigned long index)
 	while (index > radix_tree_maxindex(height))
 		height++;
 
-	if (root->rnode == NULL) {
+	if ((root->rnode == NULL) && (order == 0)) {
 		root->height = height;
 		goto out;
 	}
@@ -378,6 +379,7 @@ out:
  *	__radix_tree_create	-	create a slot in a radix tree
  *	@root:		radix tree root
  *	@index:		index key
+ *	@order:		index occupies 2^order aligned slots
  *	@nodep:		returns node
  *	@slotp:		returns slot
  *
@@ -391,26 +393,29 @@ out:
  *	Returns -ENOMEM, or 0 for success.
  */
 int __radix_tree_create(struct radix_tree_root *root, unsigned long index,
-			struct radix_tree_node **nodep, void ***slotp)
+			unsigned order, struct radix_tree_node **nodep,
+			void ***slotp)
 {
 	struct radix_tree_node *node = NULL, *slot;
 	unsigned int height, shift, offset;
 	int error;
 
+	BUG_ON((0 < order) && (order < RADIX_TREE_MAP_SHIFT));
+
 	/* Make sure the tree is high enough.  */
 	if (index > radix_tree_maxindex(root->height)) {
-		error = radix_tree_extend(root, index);
+		error = radix_tree_extend(root, index, order);
 		if (error)
 			return error;
 	}
 
-	slot = indirect_to_ptr(root->rnode);
+	slot = root->rnode;
 
 	height = root->height;
 	shift = height * RADIX_TREE_MAP_SHIFT;
 
 	offset = 0;			/* uninitialised var warning */
-	while (shift > 0) {
+	while (shift > order) {
 		if (slot == NULL) {
 			/* Have to add a child node.  */
 			slot = radix_tree_node_alloc(root);
@@ -426,15 +431,31 @@ int __radix_tree_create(struct radix_tree_root *root, unsigned long index,
 			} else
 				rcu_assign_pointer(root->rnode,
 							ptr_to_indirect(slot));
-		}
+		} else if (!radix_tree_is_indirect_ptr(slot))
+			break;
 
 		/* Go a level down */
+		height--;
 		shift -= RADIX_TREE_MAP_SHIFT;
 		offset = (index >> shift) & RADIX_TREE_MAP_MASK;
-		node = slot;
+		node = indirect_to_ptr(slot);
 		slot = node->slots[offset];
-		slot = indirect_to_ptr(slot);
-		height--;
+	}
+
+	/* Insert pointers to the canonical entry */
+	if ((shift - order) > 0) {
+		int i, n = 1 << (shift - order);
+		offset = offset & ~(n - 1);
+		slot = ptr_to_indirect(&node->slots[offset]);
+		for (i = 0; i < n; i++) {
+			if (node->slots[offset + i])
+				return -EEXIST;
+		}
+
+		for (i = 1; i < n; i++) {
+			rcu_assign_pointer(node->slots[offset + i], slot);
+			node->count++;
+		}
 	}
 
 	if (nodep)
@@ -445,15 +466,16 @@ int __radix_tree_create(struct radix_tree_root *root, unsigned long index,
 }
 
 /**
- *	radix_tree_insert    -    insert into a radix tree
+ *	__radix_tree_insert    -    insert into a radix tree
  *	@root:		radix tree root
  *	@index:		index key
+ *	@order:		key covers the 2^order indices around index
  *	@item:		item to insert
  *
  *	Insert an item into the radix tree at position @index.
  */
-int radix_tree_insert(struct radix_tree_root *root,
-			unsigned long index, void *item)
+int __radix_tree_insert(struct radix_tree_root *root, unsigned long index,
+			unsigned order, void *item)
 {
 	struct radix_tree_node *node;
 	void **slot;
@@ -461,7 +483,7 @@ int radix_tree_insert(struct radix_tree_root *root,
 
 	BUG_ON(radix_tree_is_indirect_ptr(item));
 
-	error = __radix_tree_create(root, index, &node, &slot);
+	error = __radix_tree_create(root, index, order, &node, &slot);
 	if (error)
 		return error;
 	if (*slot != NULL)
@@ -479,7 +501,7 @@ int radix_tree_insert(struct radix_tree_root *root,
 
 	return 0;
 }
-EXPORT_SYMBOL(radix_tree_insert);
+EXPORT_SYMBOL(__radix_tree_insert);
 
 /**
  *	__radix_tree_lookup	-	lookup an item in a radix tree
@@ -530,6 +552,8 @@ void *__radix_tree_lookup(struct radix_tree_root *root, unsigned long index,
 		node = rcu_dereference_raw(*slot);
 		if (node == NULL)
 			return NULL;
+		if (!radix_tree_is_indirect_ptr(node))
+			break;
 		node = indirect_to_ptr(node);
 
 		shift -= RADIX_TREE_MAP_SHIFT;
@@ -617,6 +641,8 @@ void *radix_tree_tag_set(struct radix_tree_root *root,
 			tag_set(slot, tag, offset);
 		slot = slot->slots[offset];
 		BUG_ON(slot == NULL);
+		if (!radix_tree_is_indirect_ptr(slot))
+			break;
 		slot = indirect_to_ptr(slot);
 		shift -= RADIX_TREE_MAP_SHIFT;
 		height--;
@@ -662,6 +688,8 @@ void *radix_tree_tag_clear(struct radix_tree_root *root,
 	while (shift) {
 		if (slot == NULL)
 			goto out;
+		if (!radix_tree_is_indirect_ptr(slot))
+			break;
 		slot = indirect_to_ptr(slot);
 
 		shift -= RADIX_TREE_MAP_SHIFT;
@@ -746,6 +774,8 @@ int radix_tree_tag_get(struct radix_tree_root *root,
 		if (height == 1)
 			return 1;
 		node = rcu_dereference_raw(node->slots[offset]);
+		if (!radix_tree_is_indirect_ptr(node))
+			return 1;
 		shift -= RADIX_TREE_MAP_SHIFT;
 		height--;
 	}
@@ -806,6 +836,7 @@ restart:
 
 	node = rnode;
 	while (1) {
+		struct radix_tree_node *slot;
 		if ((flags & RADIX_TREE_ITER_TAGGED) ?
 				!test_bit(offset, node->tags[tag]) :
 				!node->slots[offset]) {
@@ -836,10 +867,12 @@ restart:
 		if (!shift)
 			break;
 
-		node = rcu_dereference_raw(node->slots[offset]);
-		if (node == NULL)
+		slot = rcu_dereference_raw(node->slots[offset]);
+		if (slot == NULL)
 			goto restart;
-		node = indirect_to_ptr(node);
+		if (!radix_tree_is_indirect_ptr(slot))
+			break;
+		node = indirect_to_ptr(slot);
 		shift -= RADIX_TREE_MAP_SHIFT;
 		offset = (index >> shift) & RADIX_TREE_MAP_MASK;
 	}
@@ -937,16 +970,20 @@ unsigned long radix_tree_range_tag_if_tagged(struct radix_tree_root *root,
 		if (!tag_get(slot, iftag, offset))
 			goto next;
 		if (shift) {
-			/* Go down one level */
-			shift -= RADIX_TREE_MAP_SHIFT;
 			node = slot;
 			slot = slot->slots[offset];
-			slot = indirect_to_ptr(slot);
-			continue;
+			if (radix_tree_is_indirect_ptr(slot)) {
+				slot = indirect_to_ptr(slot);
+				shift -= RADIX_TREE_MAP_SHIFT;
+				continue;
+			} else {
+				slot = node;
+				node = node->parent;
+			}
 		}
 
 		/* tag the leaf */
-		tagged++;
+		tagged += 1 << shift;
 		tag_set(slot, settag, offset);
 
 		/* walk back up the path tagging interior nodes */
@@ -1187,11 +1224,20 @@ static unsigned long __locate(struct radix_tree_node *slot, void *item,
 				goto out;
 		}
 
-		shift -= RADIX_TREE_MAP_SHIFT;
 		slot = rcu_dereference_raw(slot->slots[i]);
 		if (slot == NULL)
 			goto out;
+		if (!radix_tree_is_indirect_ptr(slot)) {
+			if (slot == item) {
+				*found_index = index + i;
+				index = 0;
+			} else {
+				index += shift;
+			}
+			goto out;
+		}
 		slot = indirect_to_ptr(slot);
+		shift -= RADIX_TREE_MAP_SHIFT;
 	}
 
 	/* Bottom level: check items */
@@ -1271,7 +1317,8 @@ static inline void radix_tree_shrink(struct radix_tree_root *root)
 
 		/*
 		 * The candidate node has more than one child, or its child
-		 * is not at the leftmost slot, we cannot shrink.
+		 * is not at the leftmost slot, or it is a multiorder entry,
+		 * we cannot shrink.
 		 */
 		if (to_free->count != 1)
 			break;
@@ -1287,6 +1334,9 @@ static inline void radix_tree_shrink(struct radix_tree_root *root)
 		 * one (root->rnode) as far as dependent read barriers go.
 		 */
 		if (root->height > 1) {
+			if (!radix_tree_is_indirect_ptr(slot))
+				break;
+
 			slot = indirect_to_ptr(slot);
 			slot->parent = NULL;
 			slot = ptr_to_indirect(slot);
@@ -1385,7 +1435,7 @@ void *radix_tree_delete_item(struct radix_tree_root *root,
 			     unsigned long index, void *item)
 {
 	struct radix_tree_node *node;
-	unsigned int offset;
+	unsigned int offset, i;
 	void **slot;
 	void *entry;
 	int tag;
@@ -1414,6 +1464,13 @@ void *radix_tree_delete_item(struct radix_tree_root *root,
 			radix_tree_tag_clear(root, index, tag);
 	}
 
+	/* Delete any sibling slots pointing to this slot */
+	for (i = 1; offset + i < RADIX_TREE_MAP_SIZE; i++) {
+		if (node->slots[offset + i] != ptr_to_indirect(slot))
+			break;
+		node->slots[offset + i] = NULL;
+		node->count--;
+	}
 	node->slots[offset] = NULL;
 	node->count--;
 
diff --git a/mm/filemap.c b/mm/filemap.c
index b1fc7b6..7705dac 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -576,7 +576,7 @@ static int page_cache_tree_insert(struct address_space *mapping,
 	void **slot;
 	int error;
 
-	error = __radix_tree_create(&mapping->page_tree, page->index,
+	error = __radix_tree_create(&mapping->page_tree, page->index, 0,
 				    &node, &slot);
 	if (error)
 		return error;
-- 
2.7.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
