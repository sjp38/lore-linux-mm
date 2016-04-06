Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 877FE6B026D
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 17:29:00 -0400 (EDT)
Received: by mail-pf0-f173.google.com with SMTP id n1so41213864pfn.2
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 14:29:00 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id rl12si6929207pab.36.2016.04.06.14.21.54
        for <linux-mm@kvack.org>;
        Wed, 06 Apr 2016 14:21:54 -0700 (PDT)
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH 20/30] radix tree test suite: multi-order iteration test
Date: Wed,  6 Apr 2016 17:21:29 -0400
Message-Id: <1459977699-2349-21-git-send-email-willy@linux.intel.com>
In-Reply-To: <1459977699-2349-1-git-send-email-willy@linux.intel.com>
References: <1459977699-2349-1-git-send-email-willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Neil Brown <neilb@suse.de>, Matthew Wilcox <willy@linux.intel.com>

From: Ross Zwisler <ross.zwisler@linux.intel.com>

Add a unit test to verify that we can iterate over multi-order entries
properly via a radix_tree_for_each_slot() loop.

This was done with a single, somewhat complicated configuration that was
meant to test many of the various corner cases having to do with
multi-order entries:

- An iteration could begin at a sibling entry, and we need to return the
  canonical entry.
- We could have entries of various orders in the same slots[] array.
- We could have multi-order entries at a nonzero height, followed by
  indirect pointers to more radix tree nodes later in that same slots[]
  array.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 tools/testing/radix-tree/multiorder.c | 92 +++++++++++++++++++++++++++++++++++
 1 file changed, 92 insertions(+)

diff --git a/tools/testing/radix-tree/multiorder.c b/tools/testing/radix-tree/multiorder.c
index 606bfe04b104..583c5127fbcf 100644
--- a/tools/testing/radix-tree/multiorder.c
+++ b/tools/testing/radix-tree/multiorder.c
@@ -57,6 +57,96 @@ static void multiorder_insert_bug(void)
 	item_kill_tree(&tree);
 }
 
+void multiorder_iteration(void)
+{
+	RADIX_TREE(tree, GFP_KERNEL);
+	struct radix_tree_iter iter;
+	void **slot;
+	int i, err;
+
+	printf("Multiorder iteration test\n");
+
+#define NUM_ENTRIES 11
+	int index[NUM_ENTRIES] = {0, 2, 4, 8, 16, 32, 34, 36, 64, 72, 128};
+	int order[NUM_ENTRIES] = {1, 1, 2, 3,  4,  1,  0,  1,  3,  0, 7};
+
+	for (i = 0; i < NUM_ENTRIES; i++) {
+		err = item_insert_order(&tree, index[i], order[i]);
+		assert(!err);
+	}
+
+	i = 0;
+	/* start from index 1 to verify we find the multi-order entry at 0 */
+	radix_tree_for_each_slot(slot, &tree, &iter, 1) {
+		int height = order[i] / RADIX_TREE_MAP_SHIFT;
+		int shift = height * RADIX_TREE_MAP_SHIFT;
+
+		assert(iter.index == index[i]);
+		assert(iter.shift == shift);
+		i++;
+	}
+
+	/*
+	 * Now iterate through the tree starting at an elevated multi-order
+	 * entry, beginning at an index in the middle of the range.
+	 */
+	i = 8;
+	radix_tree_for_each_slot(slot, &tree, &iter, 70) {
+		int height = order[i] / RADIX_TREE_MAP_SHIFT;
+		int shift = height * RADIX_TREE_MAP_SHIFT;
+
+		assert(iter.index == index[i]);
+		assert(iter.shift == shift);
+		i++;
+	}
+
+	item_kill_tree(&tree);
+}
+
+void multiorder_tagged_iteration(void)
+{
+	RADIX_TREE(tree, GFP_KERNEL);
+	struct radix_tree_iter iter;
+	void **slot;
+	int i;
+
+	printf("Multiorder tagged iteration test\n");
+
+#define MT_NUM_ENTRIES 9
+	int index[MT_NUM_ENTRIES] = {0, 2, 4, 16, 32, 40, 64, 72, 128};
+	int order[MT_NUM_ENTRIES] = {1, 0, 2, 4,  3,  1,  3,  0,   7};
+
+#define TAG_ENTRIES 7
+	int tag_index[TAG_ENTRIES] = {0, 4, 16, 40, 64, 72, 128};
+
+	for (i = 0; i < MT_NUM_ENTRIES; i++)
+		assert(!item_insert_order(&tree, index[i], order[i]));
+
+	assert(!radix_tree_tagged(&tree, 1));
+
+	for (i = 0; i < TAG_ENTRIES; i++)
+		assert(radix_tree_tag_set(&tree, tag_index[i], 1));
+
+	i = 0;
+	/* start from index 1 to verify we find the multi-order entry at 0 */
+	radix_tree_for_each_tagged(slot, &tree, &iter, 1, 1) {
+		assert(iter.index == tag_index[i]);
+		i++;
+	}
+
+	/*
+	 * Now iterate through the tree starting at an elevated multi-order
+	 * entry, beginning at an index in the middle of the range.
+	 */
+	i = 4;
+	radix_tree_for_each_slot(slot, &tree, &iter, 70) {
+		assert(iter.index == tag_index[i]);
+		i++;
+	}
+
+	item_kill_tree(&tree);
+}
+
 void multiorder_checks(void)
 {
 	int i;
@@ -67,5 +157,7 @@ void multiorder_checks(void)
 		multiorder_check((1UL << i) + 1, i);
 	}
 
+	multiorder_iteration();
+	multiorder_tagged_iteration();
 	multiorder_insert_bug();
 }
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
