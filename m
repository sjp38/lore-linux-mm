Message-Id: <20061207162734.240076000@chello.nl>
References: <20061207161800.426936000@chello.nl>
Date: Thu, 07 Dec 2006 17:18:04 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 04/16] radix-tree: gang_lookup_tag_slot
Content-Disposition: inline; filename=radix-tree-gang_lookup_tag_slot.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Simple implementation of radix_tree_gang_lookup_tag_slot()

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/radix-tree.h |    5 ++
 lib/radix-tree.c           |   81 ++++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 82 insertions(+), 4 deletions(-)

Index: linux-2.6-rt/include/linux/radix-tree.h
===================================================================
--- linux-2.6-rt.orig/include/linux/radix-tree.h	2006-11-30 13:47:17.000000000 +0100
+++ linux-2.6-rt/include/linux/radix-tree.h	2006-11-30 16:56:44.000000000 +0100
@@ -105,6 +105,7 @@ do {									\
  * radix_tree_gang_lookup
  * radix_tree_gang_lookup_slot
  * radix_tree_gang_lookup_tag
+ * radix_tree_gang_lookup_tag_slot
  * radix_tree_tagged
  *
  * The first 6 functions are able to be called locklessly, using RCU. The
@@ -188,6 +189,10 @@ unsigned int
 radix_tree_gang_lookup_tag(struct radix_tree_root *root, void **results,
 		unsigned long first_index, unsigned int max_items,
 		unsigned int tag);
+unsigned int
+radix_tree_gang_lookup_tag_slot(struct radix_tree_root *root, void ***results,
+		unsigned long first_index, unsigned int max_items,
+		unsigned int tag);
 int radix_tree_tagged(struct radix_tree_root *root, unsigned int tag);
 
 static inline void radix_tree_preload_end(void)
Index: linux-2.6-rt/lib/radix-tree.c
===================================================================
--- linux-2.6-rt.orig/lib/radix-tree.c	2006-11-30 13:47:16.000000000 +0100
+++ linux-2.6-rt/lib/radix-tree.c	2006-11-30 16:55:57.000000000 +0100
@@ -788,7 +788,7 @@ EXPORT_SYMBOL(radix_tree_gang_lookup_slo
  * open-coding the search.
  */
 static unsigned int
-__lookup_tag(struct radix_tree_node *slot, void **results, unsigned long index,
+__lookup_tag(struct radix_tree_node *slot, void ***results, unsigned long index,
 	unsigned int max_items, unsigned long *next_index, unsigned int tag)
 {
 	unsigned int nr_found = 0;
@@ -834,8 +834,7 @@ __lookup_tag(struct radix_tree_node *slo
 				 * rely on its value remaining the same).
 				 */
 				if (node) {
-					node = rcu_dereference(node);
-					results[nr_found++] = node;
+					results[nr_found++] = &(slot->slots[j]);
 					if (nr_found == max_items)
 						goto out;
 				}
@@ -894,6 +893,80 @@ radix_tree_gang_lookup_tag(struct radix_
 
 	ret = 0;
 	while (ret < max_items) {
+		unsigned int nr_found, i, j;
+		unsigned long next_index;	/* Index of next search */
+
+		if (cur_index > max_index)
+			break;
+		nr_found = __lookup_tag(node, (void ***)results + ret, cur_index,
+					max_items - ret, &next_index, tag);
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
+EXPORT_SYMBOL(radix_tree_gang_lookup_tag);
+
+/**
+ *	radix_tree_gang_lookup_tag_slot - perform multiple slot lookup on a
+ *	                                  radix tree based on a tag
+ *	@root:		radix tree root
+ *	@results:	where the results of the lookup are placed
+ *	@first_index:	start the lookup from this key
+ *	@max_items:	place up to this many items at *results
+ *	@tag:		the tag index (< RADIX_TREE_MAX_TAGS)
+ *
+ *	Performs an index-ascending scan of the tree for present items which
+ *	have the tag indexed by @tag set.  Places their slots at *@results and
+ *	returns the number of items which were placed at *@results.
+ *
+ *	The implementation is naive.
+ *
+ *	Like radix_tree_gang_lookup_tag as far as RCU and locking goes. Slots
+ *	must be dereferenced with radix_tree_deref_slot, and if using only RCU
+ *	protection, radix_tree_deref_slot may fail requiring a retry.
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
+		results[0] = node;
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
 
@@ -909,7 +982,7 @@ radix_tree_gang_lookup_tag(struct radix_
 
 	return ret;
 }
-EXPORT_SYMBOL(radix_tree_gang_lookup_tag);
+EXPORT_SYMBOL(radix_tree_gang_lookup_tag_slot);
 
 /**
  *	radix_tree_shrink    -    shrink height of a radix tree to minimal

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
