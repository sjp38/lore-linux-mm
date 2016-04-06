Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 782486B0278
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 17:29:53 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id zm5so40620341pac.0
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 14:29:53 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id xw5si6886661pab.189.2016.04.06.14.21.55
        for <linux-mm@kvack.org>;
        Wed, 06 Apr 2016 14:21:55 -0700 (PDT)
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH 28/30] radix-tree: Fix two bugs in radix_tree_range_tag_if_tagged()
Date: Wed,  6 Apr 2016 17:21:37 -0400
Message-Id: <1459977699-2349-29-git-send-email-willy@linux.intel.com>
In-Reply-To: <1459977699-2349-1-git-send-email-willy@linux.intel.com>
References: <1459977699-2349-1-git-send-email-willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Neil Brown <neilb@suse.de>

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

Also convert to using radix_tree_load_root(), and add several tests for
radix_tree_range_tag_if_tagged().  At least one of these tests would
fail without the changes to the radix tree in this commit.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 lib/radix-tree.c                      | 20 ++++++++++----------
 tools/testing/radix-tree/multiorder.c | 16 +++++++++++++++-
 tools/testing/radix-tree/tag_check.c  | 10 ++++++++++
 3 files changed, 35 insertions(+), 11 deletions(-)

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 3ff25745896d..fa7842cb814e 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -1036,14 +1036,13 @@ unsigned long radix_tree_range_tag_if_tagged(struct radix_tree_root *root,
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
@@ -1052,14 +1051,14 @@ unsigned long radix_tree_range_tag_if_tagged(struct radix_tree_root *root,
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
+	shift -= RADIX_TREE_MAP_SHIFT;
+	slot = indirect_to_ptr(slot);
 
 	for (;;) {
 		unsigned long upindex;
@@ -1075,6 +1074,7 @@ unsigned long radix_tree_range_tag_if_tagged(struct radix_tree_root *root,
 			slot = slot->slots[offset];
 			if (radix_tree_is_indirect_ptr(slot)) {
 				slot = indirect_to_ptr(slot);
+				/* Sibling slots are never tagged */
 				shift -= RADIX_TREE_MAP_SHIFT;
 				continue;
 			} else {
@@ -1084,11 +1084,11 @@ unsigned long radix_tree_range_tag_if_tagged(struct radix_tree_root *root,
 		}
 
 		/* tag the leaf */
-		tagged += 1 << shift;
+		tagged++;
 		tag_set(slot, settag, offset);
 
 		/* walk back up the path tagging interior nodes */
-		upindex = index;
+		upindex = index >> shift;
 		while (node) {
 			upindex >>= RADIX_TREE_MAP_SHIFT;
 			offset = upindex & RADIX_TREE_MAP_MASK;
diff --git a/tools/testing/radix-tree/multiorder.c b/tools/testing/radix-tree/multiorder.c
index 0229e6fb590f..5bc8870c13a8 100644
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
@@ -280,6 +285,15 @@ void multiorder_tagged_iteration(void)
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
 	item_kill_tree(&tree);
 }
 
diff --git a/tools/testing/radix-tree/tag_check.c b/tools/testing/radix-tree/tag_check.c
index 83136be552a0..b7447ceb75e9 100644
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
