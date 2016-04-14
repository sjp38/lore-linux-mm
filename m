Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 793696B0262
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 10:17:45 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id hb4so92710609pac.3
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 07:17:45 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id w13si4753111pas.206.2016.04.14.07.17.32
        for <linux-mm@kvack.org>;
        Thu, 14 Apr 2016 07:17:32 -0700 (PDT)
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH v2 27/29] radix-tree: Fix radix_tree_range_tag_if_tagged() for multiorder entries
Date: Thu, 14 Apr 2016 10:16:48 -0400
Message-Id: <1460643410-30196-28-git-send-email-willy@linux.intel.com>
In-Reply-To: <1460643410-30196-1-git-send-email-willy@linux.intel.com>
References: <1460643410-30196-1-git-send-email-willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Neil Brown <neilb@suse.de>, Ross Zwisler <ross.zwisler@linux.intel.com>

I had previously decided that tagging a single multiorder entry would
count as tagging 2^order entries for the purposes of 'nr_to_tag'.
I now believe that decision to be a mistake, and it should count as a
single entry.  That's more likely to be what callers expect.

When walking back up the tree from a newly-tagged entry, the current
code assumed we were starting from the lowest level of the tree; if we
have a multiorder entry with an order at least RADIX_TREE_MAP_SHIFT in
size then we need to shift the index by 'shift' before we start walking
back up the tree, or we will end up not setting tags on higher entries,
and then mistakenly thinking that entries below a certain point in the
tree are not tagged.

If the first index we examine is a sibling entry of a tagged multiorder
entry, we were not tagging it.  We need to examine the canonical entry,
and the easiest way to do that is to use radix_tree_descend().  We
then have to skip over sibling slots when looking for the next entry
in the tree or we will end up walking back to the canonical entry.

Add several tests for radix_tree_range_tag_if_tagged().

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 lib/radix-tree.c                      | 76 +++++++++++++++--------------------
 tools/testing/radix-tree/multiorder.c | 25 +++++++++++-
 tools/testing/radix-tree/tag_check.c  | 10 +++++
 3 files changed, 67 insertions(+), 44 deletions(-)

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index c08b1b6..4113ae2 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -1033,14 +1033,13 @@ unsigned long radix_tree_range_tag_if_tagged(struct radix_tree_root *root,
 		unsigned long nr_to_tag,
 		unsigned int iftag, unsigned int settag)
 {
-	unsigned int height = root->height;
-	struct radix_tree_node *node = NULL;
-	struct radix_tree_node *slot;
-	unsigned int shift;
+	struct radix_tree_node *slot, *node = NULL;
+	unsigned long maxindex;
+	unsigned int shift = radix_tree_load_root(root, &slot, &maxindex);
 	unsigned long tagged = 0;
 	unsigned long index = *first_indexp;
 
-	last_index = min(last_index, radix_tree_maxindex(height));
+	last_index = min(last_index, maxindex);
 	if (index > last_index)
 		return 0;
 	if (!nr_to_tag)
@@ -1049,80 +1048,71 @@ unsigned long radix_tree_range_tag_if_tagged(struct radix_tree_root *root,
 		*first_indexp = last_index + 1;
 		return 0;
 	}
-	if (height == 0) {
+	if (!radix_tree_is_indirect_ptr(slot)) {
 		*first_indexp = last_index + 1;
 		root_tag_set(root, settag);
 		return 1;
 	}
 
-	shift = (height - 1) * RADIX_TREE_MAP_SHIFT;
-	slot = indirect_to_ptr(root->rnode);
+	node = indirect_to_ptr(slot);
+	shift -= RADIX_TREE_MAP_SHIFT;
 
 	for (;;) {
 		unsigned long upindex;
-		int offset;
+		unsigned offset;
 
 		offset = (index >> shift) & RADIX_TREE_MAP_MASK;
-		if (!slot->slots[offset])
+		offset = radix_tree_descend(node, &slot, offset);
+		if (!slot)
 			goto next;
-		if (!tag_get(slot, iftag, offset))
+		if (!tag_get(node, iftag, offset))
 			goto next;
-		if (shift) {
-			node = slot;
-			slot = slot->slots[offset];
-			if (radix_tree_is_indirect_ptr(slot)) {
-				slot = indirect_to_ptr(slot);
-				shift -= RADIX_TREE_MAP_SHIFT;
-				continue;
-			} else {
-				slot = node;
-				node = node->parent;
-			}
+		/* Sibling slots never have tags set on them */
+		if (radix_tree_is_indirect_ptr(slot)) {
+			node = indirect_to_ptr(slot);
+			shift -= RADIX_TREE_MAP_SHIFT;
+			continue;
 		}
 
 		/* tag the leaf */
-		tagged += 1 << shift;
-		tag_set(slot, settag, offset);
+		tagged++;
+		tag_set(node, settag, offset);
 
+		slot = node->parent;
 		/* walk back up the path tagging interior nodes */
-		upindex = index;
-		while (node) {
+		upindex = index >> shift;
+		while (slot) {
 			upindex >>= RADIX_TREE_MAP_SHIFT;
 			offset = upindex & RADIX_TREE_MAP_MASK;
 
 			/* stop if we find a node with the tag already set */
-			if (tag_get(node, settag, offset))
+			if (tag_get(slot, settag, offset))
 				break;
-			tag_set(node, settag, offset);
-			node = node->parent;
+			tag_set(slot, settag, offset);
+			slot = slot->parent;
 		}
 
-		/*
-		 * Small optimization: now clear that node pointer.
-		 * Since all of this slot's ancestors now have the tag set
-		 * from setting it above, we have no further need to walk
-		 * back up the tree setting tags, until we update slot to
-		 * point to another radix_tree_node.
-		 */
-		node = NULL;
-
-next:
+ next:
 		/* Go to next item at level determined by 'shift' */
 		index = ((index >> shift) + 1) << shift;
 		/* Overflow can happen when last_index is ~0UL... */
 		if (index > last_index || !index)
 			break;
-		if (tagged >= nr_to_tag)
-			break;
-		while (((index >> shift) & RADIX_TREE_MAP_MASK) == 0) {
+		offset = (index >> shift) & RADIX_TREE_MAP_MASK;
+		while (offset == 0) {
 			/*
 			 * We've fully scanned this node. Go up. Because
 			 * last_index is guaranteed to be in the tree, what
 			 * we do below cannot wander astray.
 			 */
-			slot = slot->parent;
+			node = node->parent;
 			shift += RADIX_TREE_MAP_SHIFT;
+			offset = (index >> shift) & RADIX_TREE_MAP_MASK;
 		}
+		if (is_sibling_entry(node, node->slots[offset]))
+			goto next;
+		if (tagged >= nr_to_tag)
+			break;
 	}
 	/*
 	 * We need not to tag the root tag if there is no tag which is set with
diff --git a/tools/testing/radix-tree/multiorder.c b/tools/testing/radix-tree/multiorder.c
index fc93457..c061f4b 100644
--- a/tools/testing/radix-tree/multiorder.c
+++ b/tools/testing/radix-tree/multiorder.c
@@ -26,6 +26,7 @@ static void __multiorder_tag_test(int index, int order)
 {
 	RADIX_TREE(tree, GFP_KERNEL);
 	int base, err, i;
+	unsigned long first = 0;
 
 	/* our canonical entry */
 	base = index & ~((1 << order) - 1);
@@ -59,13 +60,16 @@ static void __multiorder_tag_test(int index, int order)
 		assert(!radix_tree_tag_get(&tree, i, 1));
 	}
 
+	assert(radix_tree_range_tag_if_tagged(&tree, &first, ~0UL, 10, 0, 1) == 1);
 	assert(radix_tree_tag_clear(&tree, index, 0));
 
 	for_each_index(i, base, order) {
 		assert(!radix_tree_tag_get(&tree, i, 0));
-		assert(!radix_tree_tag_get(&tree, i, 1));
+		assert(radix_tree_tag_get(&tree, i, 1));
 	}
 
+	assert(radix_tree_tag_clear(&tree, index, 1));
+
 	assert(!radix_tree_tagged(&tree, 0));
 	assert(!radix_tree_tagged(&tree, 1));
 
@@ -244,6 +248,7 @@ void multiorder_tagged_iteration(void)
 	RADIX_TREE(tree, GFP_KERNEL);
 	struct radix_tree_iter iter;
 	void **slot;
+	unsigned long first = 0;
 	int i;
 
 	printf("Multiorder tagged iteration test\n");
@@ -280,6 +285,24 @@ void multiorder_tagged_iteration(void)
 		i++;
 	}
 
+	radix_tree_range_tag_if_tagged(&tree, &first, ~0UL,
+					MT_NUM_ENTRIES, 1, 2);
+
+	i = 0;
+	radix_tree_for_each_tagged(slot, &tree, &iter, 1, 2) {
+		assert(iter.index == tag_index[i]);
+		i++;
+	}
+
+	first = 1;
+	radix_tree_range_tag_if_tagged(&tree, &first, ~0UL,
+					MT_NUM_ENTRIES, 1, 0);
+	i = 0;
+	radix_tree_for_each_tagged(slot, &tree, &iter, 0, 0) {
+		assert(iter.index == tag_index[i]);
+		i++;
+	}
+
 	item_kill_tree(&tree);
 }
 
diff --git a/tools/testing/radix-tree/tag_check.c b/tools/testing/radix-tree/tag_check.c
index 83136be..b7447ce 100644
--- a/tools/testing/radix-tree/tag_check.c
+++ b/tools/testing/radix-tree/tag_check.c
@@ -12,6 +12,7 @@
 static void
 __simple_checks(struct radix_tree_root *tree, unsigned long index, int tag)
 {
+	unsigned long first = 0;
 	int ret;
 
 	item_check_absent(tree, index);
@@ -22,6 +23,10 @@ __simple_checks(struct radix_tree_root *tree, unsigned long index, int tag)
 	item_tag_set(tree, index, tag);
 	ret = item_tag_get(tree, index, tag);
 	assert(ret != 0);
+	ret = radix_tree_range_tag_if_tagged(tree, &first, ~0UL, 10, tag, !tag);
+	assert(ret == 1);
+	ret = item_tag_get(tree, index, !tag);
+	assert(ret != 0);
 	ret = item_delete(tree, index);
 	assert(ret != 0);
 	item_insert(tree, index);
@@ -304,6 +309,7 @@ static void single_check(void)
 	struct item *items[BATCH];
 	RADIX_TREE(tree, GFP_KERNEL);
 	int ret;
+	unsigned long first = 0;
 
 	item_insert(&tree, 0);
 	item_tag_set(&tree, 0, 0);
@@ -313,6 +319,10 @@ static void single_check(void)
 	assert(ret == 0);
 	verify_tag_consistency(&tree, 0);
 	verify_tag_consistency(&tree, 1);
+	ret = radix_tree_range_tag_if_tagged(&tree, &first, 10, 10, 0, 1);
+	assert(ret == 1);
+	ret = radix_tree_gang_lookup_tag(&tree, (void **)items, 0, BATCH, 1);
+	assert(ret == 1);
 	item_kill_tree(&tree);
 }
 
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
