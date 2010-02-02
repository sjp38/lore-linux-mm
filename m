From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 11/11] radixtree: speed up next/prev hole search
Date: Tue, 02 Feb 2010 23:28:46 +0800
Message-ID: <20100202153317.782857993@intel.com>
References: <20100202152835.683907822@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline; filename=radixtree-scan-hole-fast.patch
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jens Axboe <jens.axboe@oracle.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Wu Fengguang <fengguang.wu@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

Replace the hole scan functions with more fast versions:
	- radix_tree_next_hole(root, index, max_scan)
	- radix_tree_prev_hole(root, index, max_scan)

Cc: Nick Piggin <nickpiggin@yahoo.com.au>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 lib/radix-tree.c |   85 +++++++++++++++++++++++++++++++++++++++------
 1 file changed, 74 insertions(+), 11 deletions(-)

--- linux.orig/lib/radix-tree.c	2010-01-09 21:45:16.000000000 +0800
+++ linux/lib/radix-tree.c	2010-01-21 22:04:22.000000000 +0800
@@ -609,6 +609,24 @@ int radix_tree_tag_get(struct radix_tree
 }
 EXPORT_SYMBOL(radix_tree_tag_get);
 
+/*
+ * Find the bottom radix tree node that contains @index.
+ * Return NULL if @index is hole, or is the special root node.
+ */
+static struct radix_tree_node *
+radix_tree_lookup_node(struct radix_tree_root *root, unsigned long index)
+{
+	void *slot;
+
+	slot = radix_tree_lookup_element(root, index, 1);
+	if (!slot || slot == &root->rnode)
+		return NULL;
+
+	slot -= (index & RADIX_TREE_MAP_MASK) * sizeof(void *);
+
+	return container_of(slot, struct radix_tree_node, slots);
+}
+
 /**
  *	radix_tree_next_hole    -    find the next hole (not-present entry)
  *	@root:		tree root
@@ -630,18 +648,41 @@ EXPORT_SYMBOL(radix_tree_tag_get);
  *	under rcu_read_lock.
  */
 unsigned long radix_tree_next_hole(struct radix_tree_root *root,
-				unsigned long index, unsigned long max_scan)
+				   unsigned long index, unsigned long max_scan)
 {
-	unsigned long i;
+	struct radix_tree_node *node;
+	unsigned long origin = index;
+	int i;
+
+	node = rcu_dereference(root->rnode);
+	if (node == NULL)
+		return index;
+
+	if (!radix_tree_is_indirect_ptr(node))
+		return index ? index : 1;
 
-	for (i = 0; i < max_scan; i++) {
-		if (!radix_tree_lookup(root, index))
+	while (index - origin < max_scan) {
+		node = radix_tree_lookup_node(root, index);
+		if (!node)
 			break;
-		index++;
-		if (index == 0)
+
+		if (node->count == RADIX_TREE_MAP_SIZE) {
+			index = (index | RADIX_TREE_MAP_MASK) + 1;
+			goto check_overflow;
+		}
+
+		for (i = index & RADIX_TREE_MAP_MASK;
+		     i < RADIX_TREE_MAP_SIZE;
+		     i++, index++)
+			if (rcu_dereference(node->slots[i]) == NULL)
+				goto out;
+
+check_overflow:
+		if (unlikely(index == 0))
 			break;
 	}
 
+out:
 	return index;
 }
 EXPORT_SYMBOL(radix_tree_next_hole);
@@ -669,16 +710,38 @@ EXPORT_SYMBOL(radix_tree_next_hole);
 unsigned long radix_tree_prev_hole(struct radix_tree_root *root,
 				   unsigned long index, unsigned long max_scan)
 {
-	unsigned long i;
+	struct radix_tree_node *node;
+	unsigned long origin = index;
+	int i;
+
+	node = rcu_dereference(root->rnode);
+	if (node == NULL)
+		return index;
+
+	if (!radix_tree_is_indirect_ptr(node))
+		return index ? index : ULONG_MAX;
 
-	for (i = 0; i < max_scan; i++) {
-		if (!radix_tree_lookup(root, index))
+	while (origin - index < max_scan) {
+		node = radix_tree_lookup_node(root, index);
+		if (!node)
 			break;
-		index--;
-		if (index == LONG_MAX)
+
+		if (node->count == RADIX_TREE_MAP_SIZE) {
+			index = (index - RADIX_TREE_MAP_SIZE) |
+					 RADIX_TREE_MAP_MASK;
+			goto check_underflow;
+		}
+
+		for (i = index & RADIX_TREE_MAP_MASK; i >= 0; i--, index--)
+			if (rcu_dereference(node->slots[i]) == NULL)
+				goto out;
+
+check_underflow:
+		if (unlikely(index == ULONG_MAX))
 			break;
 	}
 
+out:
 	return index;
 }
 EXPORT_SYMBOL(radix_tree_prev_hole);
