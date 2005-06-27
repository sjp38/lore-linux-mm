Message-ID: <42BF9DE5.6010701@yahoo.com.au>
Date: Mon, 27 Jun 2005 16:34:13 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: [patch 4] radix tree: lockless readside
References: <42BF9CD1.2030102@yahoo.com.au> <42BF9D67.10509@yahoo.com.au> <42BF9D86.90204@yahoo.com.au> <42BF9DBA.3000607@yahoo.com.au>
In-Reply-To: <42BF9DBA.3000607@yahoo.com.au>
Content-Type: multipart/mixed;
 boundary="------------090403090108030001020801"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------090403090108030001020801
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit


-- 
SUSE Labs, Novell Inc.

--------------090403090108030001020801
Content-Type: text/plain;
 name="radix-tree-lockless-readside.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="radix-tree-lockless-readside.patch"

Make radix tree lookups safe to be performed without locks.

Also introduce a lockfree gang_lookup_slot which will be used
by a future patch.

Index: linux-2.6/lib/radix-tree.c
===================================================================
--- linux-2.6.orig/lib/radix-tree.c
+++ linux-2.6/lib/radix-tree.c
@@ -45,6 +45,7 @@
 	((RADIX_TREE_MAP_SIZE + BITS_PER_LONG - 1) / BITS_PER_LONG)
 
 struct radix_tree_node {
+	unsigned int	height;		/* Height from the bottom */
 	unsigned int	count;
 	void		*slots[RADIX_TREE_MAP_SIZE];
 	unsigned long	tags[RADIX_TREE_TAGS][RADIX_TREE_TAG_LONGS];
@@ -196,6 +197,7 @@ static int radix_tree_extend(struct radi
 	}
 
 	do {
+		unsigned int newheight;
 		if (!(node = radix_tree_node_alloc(root)))
 			return -ENOMEM;
 
@@ -208,9 +210,13 @@ static int radix_tree_extend(struct radi
 				tag_set(node, tag, 0);
 		}
 
+		newheight = root->height+1;
+		node->height = newheight;
 		node->count = 1;
+		/* Make ->height visible before node visible via ->rnode */
+		smp_wmb();
 		root->rnode = node;
-		root->height++;
+		root->height = newheight;
 	} while (height > root->height);
 out:
 	return 0;
@@ -250,6 +256,9 @@ int radix_tree_insert(struct radix_tree_
 			/* Have to add a child node.  */
 			if (!(tmp = radix_tree_node_alloc(root)))
 				return -ENOMEM;
+			tmp->height = height;
+			/* Make ->height visible before node visible via slot */
+			smp_wmb();
 			*slot = tmp;
 			if (node)
 				node->count++;
@@ -282,12 +291,14 @@ static inline void **__lookup_slot(struc
 	unsigned int height, shift;
 	struct radix_tree_node **slot;
 
-	height = root->height;
+	if (root->rnode == NULL)
+		return NULL;
+	slot = &root->rnode;
+	height = (*slot)->height;
 	if (index > radix_tree_maxindex(height))
 		return NULL;
 
 	shift = (height-1) * RADIX_TREE_MAP_SHIFT;
-	slot = &root->rnode;
 
 	while (height > 0) {
 		if (*slot == NULL)
@@ -491,21 +502,24 @@ EXPORT_SYMBOL(radix_tree_tag_get);
 #endif
 
 static unsigned int
-__lookup(struct radix_tree_root *root, void **results, unsigned long index,
+__lookup(struct radix_tree_root *root, void ***results, unsigned long index,
 	unsigned int max_items, unsigned long *next_index)
 {
+	unsigned long i;
 	unsigned int nr_found = 0;
 	unsigned int shift;
-	unsigned int height = root->height;
+	unsigned int height;
 	struct radix_tree_node *slot;
 
-	shift = (height-1) * RADIX_TREE_MAP_SHIFT;
 	slot = root->rnode;
+	if (!slot)
+		goto out;
+	height = slot->height;
+	shift = (height-1) * RADIX_TREE_MAP_SHIFT;
 
-	while (height > 0) {
-		unsigned long i = (index >> shift) & RADIX_TREE_MAP_MASK;
-
-		for ( ; i < RADIX_TREE_MAP_SIZE; i++) {
+	for (;;) {
+		for (i = (index >> shift) & RADIX_TREE_MAP_MASK;
+						i < RADIX_TREE_MAP_SIZE; i++) {
 			if (slot->slots[i] != NULL)
 				break;
 			index &= ~((1UL << shift) - 1);
@@ -516,21 +530,23 @@ __lookup(struct radix_tree_root *root, v
 		if (i == RADIX_TREE_MAP_SIZE)
 			goto out;
 		height--;
-		if (height == 0) {	/* Bottom level: grab some items */
-			unsigned long j = index & RADIX_TREE_MAP_MASK;
-
-			for ( ; j < RADIX_TREE_MAP_SIZE; j++) {
-				index++;
-				if (slot->slots[j]) {
-					results[nr_found++] = slot->slots[j];
-					if (nr_found == max_items)
-						goto out;
-				}
-			}
+		if (height == 0) {
+			/* Bottom level: grab some items */
+			break;
 		}
 		shift -= RADIX_TREE_MAP_SHIFT;
 		slot = slot->slots[i];
 	}
+
+	for (i = index & RADIX_TREE_MAP_MASK; i < RADIX_TREE_MAP_SIZE; i++) {
+		index++;
+		if (slot->slots[i]) {
+			results[nr_found++] = &(slot->slots[i]);
+			if (nr_found == max_items)
+				goto out;
+		}
+	}
+
 out:
 	*next_index = index;
 	return nr_found;
@@ -558,6 +574,43 @@ radix_tree_gang_lookup(struct radix_tree
 	unsigned int ret = 0;
 
 	while (ret < max_items) {
+		unsigned int nr_found, i;
+		unsigned long next_index;	/* Index of next search */
+
+		if (cur_index > max_index)
+			break;
+		nr_found = __lookup(root, (void ***)results + ret, cur_index,
+					max_items - ret, &next_index);
+		for (i = 0; i < nr_found; i++)
+			results[ret + i] = *(((void ***)results)[ret + i]);
+		ret += nr_found;
+		if (next_index == 0)
+			break;
+		cur_index = next_index;
+	}
+	return ret;
+}
+EXPORT_SYMBOL(radix_tree_gang_lookup);
+
+/**
+ *	radix_tree_gang_lookup_slot - perform multiple lookup on a radix tree
+ *	@root:		radix tree root
+ *	@results:	where the results of the lookup are placed
+ *	@first_index:	start the lookup from this key
+ *	@max_items:	place up to this many items at *results
+ *
+ *	Same as radix_tree_gang_lookup, but returns an array of pointers
+ *	(slots) to the stored items instead of the items themselves.
+ */
+unsigned int
+radix_tree_gang_lookup_slot(struct radix_tree_root *root, void ***results,
+			unsigned long first_index, unsigned int max_items)
+{
+	const unsigned long max_index = radix_tree_maxindex(root->height);
+	unsigned long cur_index = first_index;
+	unsigned int ret = 0;
+
+	while (ret < max_items) {
 		unsigned int nr_found;
 		unsigned long next_index;	/* Index of next search */
 
@@ -572,7 +625,8 @@ radix_tree_gang_lookup(struct radix_tree
 	}
 	return ret;
 }
-EXPORT_SYMBOL(radix_tree_gang_lookup);
+EXPORT_SYMBOL(radix_tree_gang_lookup_slot);
+
 
 /*
  * FIXME: the two tag_get()s here should use find_next_bit() instead of
Index: linux-2.6/include/linux/radix-tree.h
===================================================================
--- linux-2.6.orig/include/linux/radix-tree.h
+++ linux-2.6/include/linux/radix-tree.h
@@ -51,6 +51,9 @@ void *radix_tree_delete(struct radix_tre
 unsigned int
 radix_tree_gang_lookup(struct radix_tree_root *root, void **results,
 			unsigned long first_index, unsigned int max_items);
+unsigned int
+radix_tree_gang_lookup_slot(struct radix_tree_root *root, void ***results,
+			unsigned long first_index, unsigned int max_items);
 int radix_tree_preload(int gfp_mask);
 void radix_tree_init(void);
 void *radix_tree_tag_set(struct radix_tree_root *root,

--------------090403090108030001020801--
Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
