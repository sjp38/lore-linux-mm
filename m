Message-Id: <20061207162733.812071000@chello.nl>
References: <20061207161800.426936000@chello.nl>
Date: Thu, 07 Dec 2006 17:18:03 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: [PATCH 03/16] radix-tree: gang_lookup_slot
Content-Disposition: inline; filename=radix-tree-gang_lookup_slot.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Introduce a gang_lookup_slot function which is used by lockless pagecache.

Signed-off-by: Nick Piggin <npiggin@suse.de>
---
 include/linux/radix-tree.h |    7 +++
 lib/radix-tree.c           |   86 +++++++++++++++++++++++++++++++++++++++------
 2 files changed, 82 insertions(+), 11 deletions(-)

Index: linux-2.6-rt/include/linux/radix-tree.h
===================================================================
--- linux-2.6-rt.orig/include/linux/radix-tree.h	2006-11-29 14:20:42.000000000 +0100
+++ linux-2.6-rt/include/linux/radix-tree.h	2006-11-29 14:20:45.000000000 +0100
@@ -100,12 +100,14 @@ do {									\
  *
  * The notable exceptions to this rule are the following functions:
  * radix_tree_lookup
+ * radix_tree_lookup_slot
  * radix_tree_tag_get
  * radix_tree_gang_lookup
+ * radix_tree_gang_lookup_slot
  * radix_tree_gang_lookup_tag
  * radix_tree_tagged
  *
- * The first 4 functions are able to be called locklessly, using RCU. The
+ * The first 6 functions are able to be called locklessly, using RCU. The
  * caller must ensure calls to these functions are made within rcu_read_lock()
  * regions. Other readers (lock-free or otherwise) and modifications may be
  * running concurrently.
@@ -160,6 +162,9 @@ void *radix_tree_delete(struct radix_tre
 unsigned int
 radix_tree_gang_lookup(struct radix_tree_root *root, void **results,
 			unsigned long first_index, unsigned int max_items);
+unsigned int
+radix_tree_gang_lookup_slot(struct radix_tree_root *root, void ***results,
+			unsigned long first_index, unsigned int max_items);
 /*
  * On a mutex based kernel we can freely schedule within the radix code:
  */
Index: linux-2.6-rt/lib/radix-tree.c
===================================================================
--- linux-2.6-rt.orig/lib/radix-tree.c	2006-11-29 14:20:42.000000000 +0100
+++ linux-2.6-rt/lib/radix-tree.c	2006-11-29 14:20:45.000000000 +0100
@@ -340,18 +340,17 @@ EXPORT_SYMBOL(radix_tree_insert);
  *	Returns:  the slot corresponding to the position @index in the
  *	radix tree @root. This is useful for update-if-exists operations.
  *
- *	This function cannot be called under rcu_read_lock, it must be
- *	excluded from writers, as must the returned slot for subsequent
- *	use by radix_tree_deref_slot() and radix_tree_replace slot.
- *	Caller must hold tree write locked across slot lookup and
- *	replace.
+ *	This function can be called under rcu_read_lock iff the slot is not
+ *	modified by radix_tree_replace_slot, otherwise it must be called
+ *	exclusive from other writers. Any dereference of the slot must be done
+ *	using radix_tree_deref_slot.
  */
 void **radix_tree_lookup_slot(struct radix_tree_root *root, unsigned long index)
 {
 	unsigned int height, shift;
 	struct radix_tree_node *node, **slot;
 
-	node = root->rnode;
+	node = rcu_dereference(root->rnode);
 	if (node == NULL)
 		return NULL;
 
@@ -371,7 +370,7 @@ void **radix_tree_lookup_slot(struct rad
 	do {
 		slot = (struct radix_tree_node **)
 			(node->slots + ((index>>shift) & RADIX_TREE_MAP_MASK));
-		node = *slot;
+		node = rcu_dereference(*slot);
 		if (node == NULL)
 			return NULL;
 
@@ -608,7 +607,7 @@ EXPORT_SYMBOL(radix_tree_tag_get);
 #endif
 
 static unsigned int
-__lookup(struct radix_tree_node *slot, void **results, unsigned long index,
+__lookup(struct radix_tree_node *slot, void ***results, unsigned long index,
 	unsigned int max_items, unsigned long *next_index)
 {
 	unsigned int nr_found = 0;
@@ -646,7 +645,7 @@ __lookup(struct radix_tree_node *slot, v
 		index++;
 		node = slot->slots[i];
 		if (node) {
-			results[nr_found++] = rcu_dereference(node);
+			results[nr_found++] = &(slot->slots[i]);
 			if (nr_found == max_items)
 				goto out;
 		}
@@ -700,6 +699,73 @@ radix_tree_gang_lookup(struct radix_tree
 
 	ret = 0;
 	while (ret < max_items) {
+		unsigned int nr_found, i, j;
+		unsigned long next_index;	/* Index of next search */
+
+		if (cur_index > max_index)
+			break;
+		nr_found = __lookup(node, (void ***)results + ret, cur_index,
+					max_items - ret, &next_index);
+		for (i = j = 0; i < nr_found; i++) {
+			struct radix_tree_node *slot;
+			slot = rcu_dereference(*(((void ***)results)[ret + i]));
+			if (!slot)
+				continue;
+			results[ret + j] = slot;
+			j++;
+		}
+		ret += j;
+		if (next_index == 0)
+			break;
+		cur_index = next_index;
+	}
+
+	return ret;
+}
+EXPORT_SYMBOL(radix_tree_gang_lookup);
+
+/**
+ *	radix_tree_gang_lookup_slot - perform multiple slot lookup on radix tree
+ *	@root:		radix tree root
+ *	@results:	where the results of the lookup are placed
+ *	@first_index:	start the lookup from this key
+ *	@max_items:	place up to this many items at *results
+ *
+ *	Performs an index-ascending scan of the tree for present items.  Places
+ *	their slots at *@results and returns the number of items which were
+ *	placed at *@results.
+ *
+ *	The implementation is naive.
+ *
+ *	Like radix_tree_gang_lookup as far as RCU and locking goes. Slots must
+ *	be dereferenced with radix_tree_deref_slot, and if using only RCU
+ *	protection, radix_tree_deref_slot may fail requiring a retry.
+ */
+unsigned int
+radix_tree_gang_lookup_slot(struct radix_tree_root *root, void ***results,
+			unsigned long first_index, unsigned int max_items)
+{
+	unsigned long max_index;
+	struct radix_tree_node *node;
+	unsigned long cur_index = first_index;
+	unsigned int ret;
+
+	node = rcu_dereference(root->rnode);
+	if (!node)
+		return 0;
+
+	if (!radix_tree_is_indirect_ptr(node)) {
+		if (first_index > 0)
+			return 0;
+		results[0] = (void **)&root->rnode;
+		return 1;
+	}
+	node = radix_tree_indirect_to_ptr(node);
+
+	max_index = radix_tree_maxindex(node->height);
+
+	ret = 0;
+	while (ret < max_items) {
 		unsigned int nr_found;
 		unsigned long next_index;	/* Index of next search */
 
@@ -715,7 +781,7 @@ radix_tree_gang_lookup(struct radix_tree
 
 	return ret;
 }
-EXPORT_SYMBOL(radix_tree_gang_lookup);
+EXPORT_SYMBOL(radix_tree_gang_lookup_slot);
 
 /*
  * FIXME: the two tag_get()s here should use find_next_bit() instead of

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
