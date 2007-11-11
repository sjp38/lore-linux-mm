Date: Sun, 11 Nov 2007 09:49:21 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: [patch 2/6] radix-tree: gang_lookup_slot
Message-ID: <20071111084921.GE19816@wotan.suse.de>
References: <20071111084556.GC19816@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071111084556.GC19816@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Hugh Dickins <hugh@veritas.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Introduce gang_lookup_slot and gang_lookup_slot_tag functions, which are used
by lockless pagecache.

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/include/linux/radix-tree.h
===================================================================
--- linux-2.6.orig/include/linux/radix-tree.h
+++ linux-2.6/include/linux/radix-tree.h
@@ -99,12 +99,15 @@ do {									\
  *
  * The notable exceptions to this rule are the following functions:
  * radix_tree_lookup
+ * radix_tree_lookup_slot
  * radix_tree_tag_get
  * radix_tree_gang_lookup
+ * radix_tree_gang_lookup_slot
  * radix_tree_gang_lookup_tag
+ * radix_tree_gang_lookup_tag_slot
  * radix_tree_tagged
  *
- * The first 4 functions are able to be called locklessly, using RCU. The
+ * The first 7 functions are able to be called locklessly, using RCU. The
  * caller must ensure calls to these functions are made within rcu_read_lock()
  * regions. Other readers (lock-free or otherwise) and modifications may be
  * running concurrently.
@@ -159,6 +162,9 @@ void *radix_tree_delete(struct radix_tre
 unsigned int
 radix_tree_gang_lookup(struct radix_tree_root *root, void **results,
 			unsigned long first_index, unsigned int max_items);
+unsigned int
+radix_tree_gang_lookup_slot(struct radix_tree_root *root, void ***results,
+			unsigned long first_index, unsigned int max_items);
 unsigned long radix_tree_next_hole(struct radix_tree_root *root,
 				unsigned long index, unsigned long max_scan);
 int radix_tree_preload(gfp_t gfp_mask);
@@ -173,6 +179,10 @@ unsigned int
 radix_tree_gang_lookup_tag(struct radix_tree_root *root, void **results,
 		unsigned long first_index, unsigned int max_items,
 		unsigned int tag);
+unsigned int
+radix_tree_gang_lookup_tag_slot(struct radix_tree_root *root, void ***results,
+		unsigned long first_index, unsigned int max_items,
+		unsigned int tag);
 int radix_tree_tagged(struct radix_tree_root *root, unsigned int tag);
 
 static inline void radix_tree_preload_end(void)
Index: linux-2.6/lib/radix-tree.c
===================================================================
--- linux-2.6.orig/lib/radix-tree.c
+++ linux-2.6/lib/radix-tree.c
@@ -345,18 +345,17 @@ EXPORT_SYMBOL(radix_tree_insert);
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
 
@@ -376,7 +375,7 @@ void **radix_tree_lookup_slot(struct rad
 	do {
 		slot = (struct radix_tree_node **)
 			(node->slots + ((index>>shift) & RADIX_TREE_MAP_MASK));
-		node = *slot;
+		node = rcu_dereference(*slot);
 		if (node == NULL)
 			return NULL;
 
@@ -653,7 +652,7 @@ unsigned long radix_tree_next_hole(struc
 EXPORT_SYMBOL(radix_tree_next_hole);
 
 static unsigned int
-__lookup(struct radix_tree_node *slot, void **results, unsigned long index,
+__lookup(struct radix_tree_node *slot, void ***results, unsigned long index,
 	unsigned int max_items, unsigned long *next_index)
 {
 	unsigned int nr_found = 0;
@@ -687,11 +686,9 @@ __lookup(struct radix_tree_node *slot, v
 
 	/* Bottom level: grab some items */
 	for (i = index & RADIX_TREE_MAP_MASK; i < RADIX_TREE_MAP_SIZE; i++) {
-		struct radix_tree_node *node;
 		index++;
-		node = slot->slots[i];
-		if (node) {
-			results[nr_found++] = rcu_dereference(node);
+		if (slot->slots[i]) {
+			results[nr_found++] = &(slot->slots[i]);
 			if (nr_found == max_items)
 				goto out;
 		}
@@ -745,13 +742,22 @@ radix_tree_gang_lookup(struct radix_tree
 
 	ret = 0;
 	while (ret < max_items) {
-		unsigned int nr_found;
+		unsigned int nr_found, slots_found, i;
 		unsigned long next_index;	/* Index of next search */
 
 		if (cur_index > max_index)
 			break;
-		nr_found = __lookup(node, results + ret, cur_index,
+		slots_found = __lookup(node, (void ***)results + ret, cur_index,
 					max_items - ret, &next_index);
+		nr_found = 0;
+		for (i = 0; i < slots_found; i++) {
+			struct radix_tree_node *slot;
+			slot = *(((void ***)results)[ret + i]);
+			if (!slot)
+				continue;
+			results[ret + nr_found] = rcu_dereference(slot);
+			nr_found++;
+		}
 		ret += nr_found;
 		if (next_index == 0)
 			break;
@@ -762,12 +768,71 @@ radix_tree_gang_lookup(struct radix_tree
 }
 EXPORT_SYMBOL(radix_tree_gang_lookup);
 
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
+		unsigned int slots_found;
+		unsigned long next_index;	/* Index of next search */
+
+		if (cur_index > max_index)
+			break;
+		slots_found = __lookup(node, results + ret, cur_index,
+					max_items - ret, &next_index);
+		ret += slots_found;
+		if (next_index == 0)
+			break;
+		cur_index = next_index;
+	}
+
+	return ret;
+}
+EXPORT_SYMBOL(radix_tree_gang_lookup_slot);
+
 /*
  * FIXME: the two tag_get()s here should use find_next_bit() instead of
  * open-coding the search.
  */
 static unsigned int
-__lookup_tag(struct radix_tree_node *slot, void **results, unsigned long index,
+__lookup_tag(struct radix_tree_node *slot, void ***results, unsigned long index,
 	unsigned int max_items, unsigned long *next_index, unsigned int tag)
 {
 	unsigned int nr_found = 0;
@@ -797,11 +862,9 @@ __lookup_tag(struct radix_tree_node *slo
 			unsigned long j = index & RADIX_TREE_MAP_MASK;
 
 			for ( ; j < RADIX_TREE_MAP_SIZE; j++) {
-				struct radix_tree_node *node;
 				index++;
 				if (!tag_get(slot, tag, j))
 					continue;
-				node = slot->slots[j];
 				/*
 				 * Even though the tag was found set, we need to
 				 * recheck that we have a non-NULL node, because
@@ -812,9 +875,8 @@ __lookup_tag(struct radix_tree_node *slo
 				 * lookup ->slots[x] without a lock (ie. can't
 				 * rely on its value remaining the same).
 				 */
-				if (node) {
-					node = rcu_dereference(node);
-					results[nr_found++] = node;
+				if (slot->slots[j]) {
+					results[nr_found++] = &(slot->slots[j]);
 					if (nr_found == max_items)
 						goto out;
 				}
@@ -873,13 +935,22 @@ radix_tree_gang_lookup_tag(struct radix_
 
 	ret = 0;
 	while (ret < max_items) {
-		unsigned int nr_found;
+		unsigned int nr_found, slots_found, i;
 		unsigned long next_index;	/* Index of next search */
 
 		if (cur_index > max_index)
 			break;
-		nr_found = __lookup_tag(node, results + ret, cur_index,
-					max_items - ret, &next_index, tag);
+		slots_found = __lookup_tag(node, (void ***)results + ret,
+				cur_index, max_items - ret, &next_index, tag);
+		nr_found = 0;
+		for (i = 0; i < slots_found; i++) {
+			struct radix_tree_node *slot;
+			slot = *(((void ***)results)[ret + i]);
+			if (!slot)
+				continue;
+			results[ret + nr_found] = rcu_dereference(slot);
+			nr_found++;
+		}
 		ret += nr_found;
 		if (next_index == 0)
 			break;
@@ -891,6 +962,67 @@ radix_tree_gang_lookup_tag(struct radix_
 EXPORT_SYMBOL(radix_tree_gang_lookup_tag);
 
 /**
+ *	radix_tree_gang_lookup_tag_slot - perform multiple slot lookup on a
+ *					  radix tree based on a tag
+ *	@root:		radix tree root
+ *	@results:	where the results of the lookup are placed
+ *	@first_index:	start the lookup from this key
+ *	@max_items:	place up to this many items at *results
+ *	@tag:		the tag index (< RADIX_TREE_MAX_TAGS)
+ *
+ *	Performs an index-ascending scan of the tree for present items which
+ *	have the tag indexed by @tag set.  Places the slots at *@results and
+ *	returns the number of slots which were placed at *@results.
+ */
+unsigned int
+radix_tree_gang_lookup_tag_slot(struct radix_tree_root *root, void ***results,
+		unsigned long first_index, unsigned int max_items,
+		unsigned int tag)
+{
+	struct radix_tree_node *node;
+	unsigned long max_index;
+	unsigned long cur_index = first_index;
+	unsigned int ret;
+
+	/* check the root's tag bit */
+	if (!root_tag_get(root, tag))
+		return 0;
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
+		unsigned int slots_found;
+		unsigned long next_index;	/* Index of next search */
+
+		if (cur_index > max_index)
+			break;
+		slots_found = __lookup_tag(node, results + ret,
+				cur_index, max_items - ret, &next_index, tag);
+		ret += slots_found;
+		if (next_index == 0)
+			break;
+		cur_index = next_index;
+	}
+
+	return ret;
+}
+EXPORT_SYMBOL(radix_tree_gang_lookup_tag_slot);
+
+
+/**
  *	radix_tree_shrink    -    shrink height of a radix tree to minimal
  *	@root		radix tree root
  */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
