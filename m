Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id E62F36B0276
	for <linux-mm@kvack.org>; Mon, 19 Feb 2018 14:46:13 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id l1so5845826pga.1
        for <linux-mm@kvack.org>; Mon, 19 Feb 2018 11:46:13 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b127si2481496pgc.220.2018.02.19.11.46.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 19 Feb 2018 11:46:12 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v7 13/61] xarray: Define struct xa_node
Date: Mon, 19 Feb 2018 11:45:08 -0800
Message-Id: <20180219194556.6575-14-willy@infradead.org>
In-Reply-To: <20180219194556.6575-1-willy@infradead.org>
References: <20180219194556.6575-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

This is a direct replacement for struct radix_tree_node.  A couple of
struct members have changed name, so convert those.  Use a #define so
that radix tree users continue to work without change.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/radix-tree.h            | 29 +++------------------
 include/linux/xarray.h                | 24 ++++++++++++++++++
 lib/radix-tree.c                      | 48 +++++++++++++++++------------------
 mm/workingset.c                       | 16 ++++++------
 tools/testing/radix-tree/multiorder.c | 30 +++++++++++-----------
 5 files changed, 74 insertions(+), 73 deletions(-)

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index c8a33e9e9a3c..f64beb9ba175 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -32,6 +32,7 @@
 
 /* Keep unconverted code working */
 #define radix_tree_root		xarray
+#define radix_tree_node		xa_node
 
 /*
  * The bottom two bits of the slot determine how the remaining bits in the
@@ -60,41 +61,17 @@ static inline bool radix_tree_is_internal_node(void *ptr)
 
 /*** radix-tree API starts here ***/
 
-#define RADIX_TREE_MAX_TAGS 3
-
 #define RADIX_TREE_MAP_SHIFT	XA_CHUNK_SHIFT
 #define RADIX_TREE_MAP_SIZE	(1UL << RADIX_TREE_MAP_SHIFT)
 #define RADIX_TREE_MAP_MASK	(RADIX_TREE_MAP_SIZE-1)
 
-#define RADIX_TREE_TAG_LONGS	\
-	((RADIX_TREE_MAP_SIZE + BITS_PER_LONG - 1) / BITS_PER_LONG)
+#define RADIX_TREE_MAX_TAGS	XA_MAX_TAGS
+#define RADIX_TREE_TAG_LONGS	XA_TAG_LONGS
 
 #define RADIX_TREE_INDEX_BITS  (8 /* CHAR_BIT */ * sizeof(unsigned long))
 #define RADIX_TREE_MAX_PATH (DIV_ROUND_UP(RADIX_TREE_INDEX_BITS, \
 					  RADIX_TREE_MAP_SHIFT))
 
-/*
- * @count is the count of every non-NULL element in the ->slots array
- * whether that is a data entry, a retry entry, a user pointer,
- * a sibling entry or a pointer to the next level of the tree.
- * @exceptional is the count of every element in ->slots which is
- * either a data entry or a sibling entry for data.
- */
-struct radix_tree_node {
-	unsigned char	shift;		/* Bits remaining in each slot */
-	unsigned char	offset;		/* Slot offset in parent */
-	unsigned char	count;		/* Total entry count */
-	unsigned char	exceptional;	/* Exceptional entry count */
-	struct radix_tree_node *parent;		/* Used when ascending tree */
-	struct radix_tree_root *root;		/* The tree we belong to */
-	union {
-		struct list_head private_list;	/* For tree user */
-		struct rcu_head	rcu_head;	/* Used when freeing node */
-	};
-	void __rcu	*slots[RADIX_TREE_MAP_SIZE];
-	unsigned long	tags[RADIX_TREE_MAX_TAGS][RADIX_TREE_TAG_LONGS];
-};
-
 /* The IDR tag is stored in the low bits of xa_flags */
 #define ROOT_IS_IDR	((__force gfp_t)4)
 /* The top bits of xa_flags are used to store the root tags */
diff --git a/include/linux/xarray.h b/include/linux/xarray.h
index 9b05b907062b..b51f354dfbf0 100644
--- a/include/linux/xarray.h
+++ b/include/linux/xarray.h
@@ -195,6 +195,30 @@ static inline void xa_init(struct xarray *xa)
 #endif
 #define XA_CHUNK_SIZE		(1UL << XA_CHUNK_SHIFT)
 #define XA_CHUNK_MASK		(XA_CHUNK_SIZE - 1)
+#define XA_MAX_TAGS		3
+#define XA_TAG_LONGS		DIV_ROUND_UP(XA_CHUNK_SIZE, BITS_PER_LONG)
+
+/*
+ * @count is the count of every non-NULL element in the ->slots array
+ * whether that is a value entry, a retry entry, a user pointer,
+ * a sibling entry or a pointer to the next level of the tree.
+ * @nr_values is the count of every element in ->slots which is
+ * either a value entry or a sibling entry to a value entry.
+ */
+struct xa_node {
+	unsigned char	shift;		/* Bits remaining in each slot */
+	unsigned char	offset;		/* Slot offset in parent */
+	unsigned char	count;		/* Total entry count */
+	unsigned char	nr_values;	/* Value entry count */
+	struct xa_node __rcu *parent;	/* NULL at top of tree */
+	struct xarray	*array;		/* The array we belong to */
+	union {
+		struct list_head private_list;	/* For tree user */
+		struct rcu_head	rcu_head;	/* Used when freeing node */
+	};
+	void __rcu	*slots[XA_CHUNK_SIZE];
+	unsigned long	tags[XA_MAX_TAGS][XA_TAG_LONGS];
+};
 
 /* Private */
 static inline bool xa_is_node(const void *entry)
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index ea0b57f35dd6..ed3e8d641cba 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -260,11 +260,11 @@ static void dump_node(struct radix_tree_node *node, unsigned long index)
 {
 	unsigned long i;
 
-	pr_debug("radix node: %p offset %d indices %lu-%lu parent %p tags %lx %lx %lx shift %d count %d exceptional %d\n",
+	pr_debug("radix node: %p offset %d indices %lu-%lu parent %p tags %lx %lx %lx shift %d count %d nr_values %d\n",
 		node, node->offset, index, index | node_maxindex(node),
 		node->parent,
 		node->tags[0][0], node->tags[1][0], node->tags[2][0],
-		node->shift, node->count, node->exceptional);
+		node->shift, node->count, node->nr_values);
 
 	for (i = 0; i < RADIX_TREE_MAP_SIZE; i++) {
 		unsigned long first = index | (i << node->shift);
@@ -354,7 +354,7 @@ static struct radix_tree_node *
 radix_tree_node_alloc(gfp_t gfp_mask, struct radix_tree_node *parent,
 			struct radix_tree_root *root,
 			unsigned int shift, unsigned int offset,
-			unsigned int count, unsigned int exceptional)
+			unsigned int count, unsigned int nr_values)
 {
 	struct radix_tree_node *ret = NULL;
 
@@ -401,9 +401,9 @@ radix_tree_node_alloc(gfp_t gfp_mask, struct radix_tree_node *parent,
 		ret->shift = shift;
 		ret->offset = offset;
 		ret->count = count;
-		ret->exceptional = exceptional;
+		ret->nr_values = nr_values;
 		ret->parent = parent;
-		ret->root = root;
+		ret->array = root;
 	}
 	return ret;
 }
@@ -633,8 +633,8 @@ static int radix_tree_extend(struct radix_tree_root *root, gfp_t gfp,
 		if (radix_tree_is_internal_node(entry)) {
 			entry_to_node(entry)->parent = node;
 		} else if (xa_is_value(entry)) {
-			/* Moving an exceptional root->xa_head to a node */
-			node->exceptional = 1;
+			/* Moving a value entry root->xa_head to a node */
+			node->nr_values = 1;
 		}
 		/*
 		 * entry was already in the radix tree, so we do not need
@@ -920,12 +920,12 @@ static inline int insert_entries(struct radix_tree_node *node,
 		if (xa_is_node(old))
 			radix_tree_free_nodes(old);
 		if (xa_is_value(old))
-			node->exceptional--;
+			node->nr_values--;
 	}
 	if (node) {
 		node->count += n;
 		if (xa_is_value(item))
-			node->exceptional += n;
+			node->nr_values += n;
 	}
 	return n;
 }
@@ -939,7 +939,7 @@ static inline int insert_entries(struct radix_tree_node *node,
 	if (node) {
 		node->count++;
 		if (xa_is_value(item))
-			node->exceptional++;
+			node->nr_values++;
 	}
 	return 1;
 }
@@ -1073,7 +1073,7 @@ void *radix_tree_lookup(const struct radix_tree_root *root, unsigned long index)
 EXPORT_SYMBOL(radix_tree_lookup);
 
 static inline void replace_sibling_entries(struct radix_tree_node *node,
-				void __rcu **slot, int count, int exceptional)
+				void __rcu **slot, int count, int values)
 {
 #ifdef CONFIG_RADIX_TREE_MULTIORDER
 	unsigned offset = get_slot_offset(node, slot);
@@ -1086,21 +1086,21 @@ static inline void replace_sibling_entries(struct radix_tree_node *node,
 			node->slots[offset] = NULL;
 			node->count--;
 		}
-		node->exceptional += exceptional;
+		node->nr_values += values;
 	}
 #endif
 }
 
 static void replace_slot(void __rcu **slot, void *item,
-		struct radix_tree_node *node, int count, int exceptional)
+		struct radix_tree_node *node, int count, int values)
 {
 	if (WARN_ON_ONCE(radix_tree_is_internal_node(item)))
 		return;
 
-	if (node && (count || exceptional)) {
+	if (node && (count || values)) {
 		node->count += count;
-		node->exceptional += exceptional;
-		replace_sibling_entries(node, slot, count, exceptional);
+		node->nr_values += values;
+		replace_sibling_entries(node, slot, count, values);
 	}
 
 	rcu_assign_pointer(*slot, item);
@@ -1154,17 +1154,17 @@ void __radix_tree_replace(struct radix_tree_root *root,
 			  radix_tree_update_node_t update_node)
 {
 	void *old = rcu_dereference_raw(*slot);
-	int exceptional = !!xa_is_value(item) - !!xa_is_value(old);
+	int values = !!xa_is_value(item) - !!xa_is_value(old);
 	int count = calculate_count(root, node, slot, item, old);
 
 	/*
-	 * This function supports replacing exceptional entries and
+	 * This function supports replacing value entries and
 	 * deleting entries, but that needs accounting against the
 	 * node unless the slot is root->xa_head.
 	 */
 	WARN_ON_ONCE(!node && (slot != (void __rcu **)&root->xa_head) &&
-			(count || exceptional));
-	replace_slot(slot, item, node, count, exceptional);
+			(count || values));
+	replace_slot(slot, item, node, count, values);
 
 	if (!node)
 		return;
@@ -1186,7 +1186,7 @@ void __radix_tree_replace(struct radix_tree_root *root,
  * across slot lookup and replacement.
  *
  * NOTE: This cannot be used to switch between non-entries (empty slots),
- * regular entries, and exceptional entries, as that requires accounting
+ * regular entries, and value entries, as that requires accounting
  * inside the radix tree node. When switching from one type of entry or
  * deleting, use __radix_tree_lookup() and __radix_tree_replace() or
  * radix_tree_iter_replace().
@@ -1294,7 +1294,7 @@ int radix_tree_split(struct radix_tree_root *root, unsigned long index,
 		rcu_assign_pointer(parent->slots[end], RADIX_TREE_RETRY);
 	}
 	rcu_assign_pointer(parent->slots[offset], RADIX_TREE_RETRY);
-	parent->exceptional -= (end - offset);
+	parent->nr_values -= (end - offset);
 
 	if (order == parent->shift)
 		return 0;
@@ -1954,7 +1954,7 @@ static bool __radix_tree_delete(struct radix_tree_root *root,
 				struct radix_tree_node *node, void __rcu **slot)
 {
 	void *old = rcu_dereference_raw(*slot);
-	int exceptional = xa_is_value(old) ? -1 : 0;
+	int values = xa_is_value(old) ? -1 : 0;
 	unsigned offset = get_slot_offset(node, slot);
 	int tag;
 
@@ -1964,7 +1964,7 @@ static bool __radix_tree_delete(struct radix_tree_root *root,
 		for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++)
 			node_tag_clear(root, node, tag, offset);
 
-	replace_slot(slot, NULL, node, -1, exceptional);
+	replace_slot(slot, NULL, node, -1, values);
 	return node && delete_node(root, node, NULL);
 }
 
diff --git a/mm/workingset.c b/mm/workingset.c
index 3afeb84720f4..91b6e16ad4c1 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -348,7 +348,7 @@ void workingset_update_node(struct radix_tree_node *node)
 	 * already where they should be. The list_empty() test is safe
 	 * as node->private_list is protected by mapping->pages.xa_lock.
 	 */
-	if (node->count && node->count == node->exceptional) {
+	if (node->count && node->count == node->nr_values) {
 		if (list_empty(&node->private_list))
 			list_lru_add(&shadow_nodes, &node->private_list);
 	} else {
@@ -427,8 +427,8 @@ static enum lru_status shadow_lru_isolate(struct list_head *item,
 	 * to reclaim, take the node off-LRU, and drop the lru_lock.
 	 */
 
-	node = container_of(item, struct radix_tree_node, private_list);
-	mapping = container_of(node->root, struct address_space, pages);
+	node = container_of(item, struct xa_node, private_list);
+	mapping = container_of(node->array, struct address_space, pages);
 
 	/* Coming from the list, invert the lock order */
 	if (!xa_trylock(&mapping->pages)) {
@@ -445,25 +445,25 @@ static enum lru_status shadow_lru_isolate(struct list_head *item,
 	 * no pages, so we expect to be able to remove them all and
 	 * delete and free the empty node afterwards.
 	 */
-	if (WARN_ON_ONCE(!node->exceptional))
+	if (WARN_ON_ONCE(!node->nr_values))
 		goto out_invalid;
-	if (WARN_ON_ONCE(node->count != node->exceptional))
+	if (WARN_ON_ONCE(node->count != node->nr_values))
 		goto out_invalid;
 	for (i = 0; i < RADIX_TREE_MAP_SIZE; i++) {
 		if (node->slots[i]) {
 			if (WARN_ON_ONCE(!xa_is_value(node->slots[i])))
 				goto out_invalid;
-			if (WARN_ON_ONCE(!node->exceptional))
+			if (WARN_ON_ONCE(!node->nr_values))
 				goto out_invalid;
 			if (WARN_ON_ONCE(!mapping->nrexceptional))
 				goto out_invalid;
 			node->slots[i] = NULL;
-			node->exceptional--;
+			node->nr_values--;
 			node->count--;
 			mapping->nrexceptional--;
 		}
 	}
-	if (WARN_ON_ONCE(node->exceptional))
+	if (WARN_ON_ONCE(node->nr_values))
 		goto out_invalid;
 	inc_lruvec_page_state(virt_to_page(node), WORKINGSET_NODERECLAIM);
 	__radix_tree_delete_node(&mapping->pages, node,
diff --git a/tools/testing/radix-tree/multiorder.c b/tools/testing/radix-tree/multiorder.c
index 24293a2fd82d..ed51edc008fd 100644
--- a/tools/testing/radix-tree/multiorder.c
+++ b/tools/testing/radix-tree/multiorder.c
@@ -392,7 +392,7 @@ static void multiorder_join2(unsigned order1, unsigned order2)
 	radix_tree_insert(&tree, 1 << order2, xa_mk_value(5));
 	item2 = __radix_tree_lookup(&tree, 1 << order2, &node, NULL);
 	assert(item2 == xa_mk_value(5));
-	assert(node->exceptional == 1);
+	assert(node->nr_values == 1);
 
 	item2 = radix_tree_lookup(&tree, 0);
 	free(item2);
@@ -400,7 +400,7 @@ static void multiorder_join2(unsigned order1, unsigned order2)
 	radix_tree_join(&tree, 0, order1, item1);
 	item2 = __radix_tree_lookup(&tree, 1 << order2, &node, NULL);
 	assert(item2 == item1);
-	assert(node->exceptional == 0);
+	assert(node->nr_values == 0);
 	item_kill_tree(&tree);
 }
 
@@ -408,7 +408,7 @@ static void multiorder_join2(unsigned order1, unsigned order2)
  * This test revealed an accounting bug for inline data entries at one point.
  * Nodes were being freed back into the pool with an elevated exception count
  * by radix_tree_join() and then radix_tree_split() was failing to zero the
- * count of exceptional entries.
+ * count of value entries.
  */
 static void multiorder_join3(unsigned int order)
 {
@@ -432,7 +432,7 @@ static void multiorder_join3(unsigned int order)
 	}
 
 	__radix_tree_lookup(&tree, 0, &node, NULL);
-	assert(node->exceptional == node->count);
+	assert(node->nr_values == node->count);
 
 	item_kill_tree(&tree);
 }
@@ -519,7 +519,7 @@ static void __multiorder_split2(int old_order, int new_order)
 
 	item = __radix_tree_lookup(&tree, 0, &node, NULL);
 	assert(item == xa_mk_value(5));
-	assert(node->exceptional > 0);
+	assert(node->nr_values > 0);
 
 	radix_tree_split(&tree, 0, new_order);
 	radix_tree_for_each_slot(slot, &tree, &iter, 0) {
@@ -529,7 +529,7 @@ static void __multiorder_split2(int old_order, int new_order)
 
 	item = __radix_tree_lookup(&tree, 0, &node, NULL);
 	assert(item != xa_mk_value(5));
-	assert(node->exceptional == 0);
+	assert(node->nr_values == 0);
 
 	item_kill_tree(&tree);
 }
@@ -546,7 +546,7 @@ static void __multiorder_split3(int old_order, int new_order)
 
 	item = __radix_tree_lookup(&tree, 0, &node, NULL);
 	assert(item == xa_mk_value(5));
-	assert(node->exceptional > 0);
+	assert(node->nr_values > 0);
 
 	radix_tree_split(&tree, 0, new_order);
 	radix_tree_for_each_slot(slot, &tree, &iter, 0) {
@@ -555,7 +555,7 @@ static void __multiorder_split3(int old_order, int new_order)
 
 	item = __radix_tree_lookup(&tree, 0, &node, NULL);
 	assert(item == xa_mk_value(7));
-	assert(node->exceptional > 0);
+	assert(node->nr_values > 0);
 
 	item_kill_tree(&tree);
 
@@ -563,7 +563,7 @@ static void __multiorder_split3(int old_order, int new_order)
 
 	item = __radix_tree_lookup(&tree, 0, &node, NULL);
 	assert(item == xa_mk_value(5));
-	assert(node->exceptional > 0);
+	assert(node->nr_values > 0);
 
 	radix_tree_split(&tree, 0, new_order);
 	radix_tree_for_each_slot(slot, &tree, &iter, 0) {
@@ -576,13 +576,13 @@ static void __multiorder_split3(int old_order, int new_order)
 
 	item = __radix_tree_lookup(&tree, 1 << new_order, &node, NULL);
 	assert(item == xa_mk_value(7));
-	assert(node->count == node->exceptional);
+	assert(node->count == node->nr_values);
 	do {
 		node = node->parent;
 		if (!node)
 			break;
 		assert(node->count == 1);
-		assert(node->exceptional == 0);
+		assert(node->nr_values == 0);
 	} while (1);
 
 	item_kill_tree(&tree);
@@ -610,15 +610,15 @@ static void multiorder_account(void)
 
 	__radix_tree_insert(&tree, 1 << 5, 5, xa_mk_value(5));
 	__radix_tree_lookup(&tree, 0, &node, NULL);
-	assert(node->count == node->exceptional * 2);
+	assert(node->count == node->nr_values * 2);
 	radix_tree_delete(&tree, 1 << 5);
-	assert(node->exceptional == 0);
+	assert(node->nr_values == 0);
 
 	__radix_tree_insert(&tree, 1 << 5, 5, xa_mk_value(5));
 	__radix_tree_lookup(&tree, 1 << 5, &node, &slot);
-	assert(node->count == node->exceptional * 2);
+	assert(node->count == node->nr_values * 2);
 	__radix_tree_replace(&tree, node, slot, NULL, NULL);
-	assert(node->exceptional == 0);
+	assert(node->nr_values == 0);
 
 	item_kill_tree(&tree);
 }
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
