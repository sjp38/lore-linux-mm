From: Nick Piggin <npiggin@suse.de>
Message-Id: <20061004123036.5637.5151.sendpatchset@linux.site>
In-Reply-To: <20061004123018.5637.93004.sendpatchset@linux.site>
References: <20061004123018.5637.93004.sendpatchset@linux.site>
Subject: [patch 2/4] radix-tree: gang_lookup_slot
Date: Wed,  4 Oct 2006 16:37:15 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Nick Piggin <npiggin@suse.de>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Introduce a gang_lookup_slot function which is used by lockless pagecache.

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/include/linux/radix-tree.h
===================================================================
--- linux-2.6.orig/include/linux/radix-tree.h
+++ linux-2.6/include/linux/radix-tree.h
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
 unsigned long radix_tree_scan_hole_backward(struct radix_tree_root *root,
 				unsigned long index, unsigned long max_scan);
 unsigned long radix_tree_scan_hole(struct radix_tree_root *root,
Index: linux-2.6/lib/radix-tree.c
===================================================================
--- linux-2.6.orig/lib/radix-tree.c
+++ linux-2.6/lib/radix-tree.c
@@ -338,18 +338,17 @@ EXPORT_SYMBOL(radix_tree_insert);
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
 
@@ -369,7 +368,7 @@ void **radix_tree_lookup_slot(struct rad
 	do {
 		slot = (struct radix_tree_node **)
 			(node->slots + ((index>>shift) & RADIX_TREE_MAP_MASK));
-		node = *slot;
+		node = rcu_dereference(*slot);
 		if (node == NULL)
 			return NULL;
 
@@ -677,7 +676,7 @@ unsigned long radix_tree_scan_hole_backw
 EXPORT_SYMBOL(radix_tree_scan_hole_backward);
 
 static unsigned int
-__lookup(struct radix_tree_node *slot, void **results, unsigned long index,
+__lookup(struct radix_tree_node *slot, void ***results, unsigned long index,
 	unsigned int max_items, unsigned long *next_index)
 {
 	unsigned int nr_found = 0;
@@ -715,7 +714,7 @@ __lookup(struct radix_tree_node *slot, v
 		index++;
 		node = slot->slots[i];
 		if (node) {
-			results[nr_found++] = rcu_dereference(node);
+			results[nr_found++] = &(slot->slots[i]);
 			if (nr_found == max_items)
 				goto out;
 		}
@@ -769,6 +768,73 @@ radix_tree_gang_lookup(struct radix_tree
 
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
 
@@ -784,7 +850,7 @@ radix_tree_gang_lookup(struct radix_tree
 
 	return ret;
 }
-EXPORT_SYMBOL(radix_tree_gang_lookup);
+EXPORT_SYMBOL(radix_tree_gang_lookup_slot);
 
 /*
  * FIXME: the two tag_get()s here should use find_next_bit() instead of

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
