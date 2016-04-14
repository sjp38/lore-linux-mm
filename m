Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id D6F8D828DF
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 10:17:55 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id vv3so93329231pab.2
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 07:17:55 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id 78si7713939pfq.236.2016.04.14.07.17.34
        for <linux-mm@kvack.org>;
        Thu, 14 Apr 2016 07:17:35 -0700 (PDT)
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH v2 24/29] radix-tree test suite: add multi-order tag test
Date: Thu, 14 Apr 2016 10:16:45 -0400
Message-Id: <1460643410-30196-25-git-send-email-willy@linux.intel.com>
In-Reply-To: <1460643410-30196-1-git-send-email-willy@linux.intel.com>
References: <1460643410-30196-1-git-send-email-willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Neil Brown <neilb@suse.de>, Matthew Wilcox <willy@linux.intel.com>

From: Ross Zwisler <ross.zwisler@linux.intel.com>

Add a generic test for multi-order tag verification, and call it using
several different configurations.

This test creates a multi-order radix tree using the given index and order,
and then sets, checks and clears tags using the indices covered by the
single multi-order radix tree entry.

With the various calls done by this test we verify root multi-order entries
without siblings, multi-order entries without siblings in a radix tree
node, as well as multi-order entries with siblings of various sizes.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 tools/testing/radix-tree/multiorder.c | 97 +++++++++++++++++++++++++++++++++++
 1 file changed, 97 insertions(+)

diff --git a/tools/testing/radix-tree/multiorder.c b/tools/testing/radix-tree/multiorder.c
index ba27fe0..1b6fc9b 100644
--- a/tools/testing/radix-tree/multiorder.c
+++ b/tools/testing/radix-tree/multiorder.c
@@ -19,6 +19,102 @@
 
 #include "test.h"
 
+#define for_each_index(i, base, order) \
+	for (i = base; i < base + (1 << order); i++)
+
+static void __multiorder_tag_test(int index, int order)
+{
+	RADIX_TREE(tree, GFP_KERNEL);
+	int base, err, i;
+
+	/* our canonical entry */
+	base = index & ~((1 << order) - 1);
+
+	printf("Multiorder tag test with index %d, canonical entry %d\n",
+			index, base);
+
+	err = item_insert_order(&tree, index, order);
+	assert(!err);
+
+	/*
+	 * Verify we get collisions for covered indices.  We try and fail to
+	 * insert an exceptional entry so we don't leak memory via
+	 * item_insert_order().
+	 */
+	for_each_index(i, base, order) {
+		err = __radix_tree_insert(&tree, i, order,
+				(void *)(0xA0 | RADIX_TREE_EXCEPTIONAL_ENTRY));
+		assert(err == -EEXIST);
+	}
+
+	for_each_index(i, base, order) {
+		assert(!radix_tree_tag_get(&tree, i, 0));
+		assert(!radix_tree_tag_get(&tree, i, 1));
+	}
+
+	assert(radix_tree_tag_set(&tree, index, 0));
+
+	for_each_index(i, base, order) {
+		assert(radix_tree_tag_get(&tree, i, 0));
+		assert(!radix_tree_tag_get(&tree, i, 1));
+	}
+
+	assert(radix_tree_tag_clear(&tree, index, 0));
+
+	for_each_index(i, base, order) {
+		assert(!radix_tree_tag_get(&tree, i, 0));
+		assert(!radix_tree_tag_get(&tree, i, 1));
+	}
+
+	assert(!radix_tree_tagged(&tree, 0));
+	assert(!radix_tree_tagged(&tree, 1));
+
+	item_kill_tree(&tree);
+}
+
+static void multiorder_tag_tests(void)
+{
+	/* test multi-order entry for indices 0-7 with no sibling pointers */
+	__multiorder_tag_test(0, 3);
+	__multiorder_tag_test(5, 3);
+
+	/* test multi-order entry for indices 8-15 with no sibling pointers */
+	__multiorder_tag_test(8, 3);
+	__multiorder_tag_test(15, 3);
+
+	/*
+	 * Our order 5 entry covers indices 0-31 in a tree with height=2.
+	 * This is broken up as follows:
+	 * 0-7:		canonical entry
+	 * 8-15:	sibling 1
+	 * 16-23:	sibling 2
+	 * 24-31:	sibling 3
+	 */
+	__multiorder_tag_test(0, 5);
+	__multiorder_tag_test(29, 5);
+
+	/* same test, but with indices 32-63 */
+	__multiorder_tag_test(32, 5);
+	__multiorder_tag_test(44, 5);
+
+	/*
+	 * Our order 8 entry covers indices 0-255 in a tree with height=3.
+	 * This is broken up as follows:
+	 * 0-63:	canonical entry
+	 * 64-127:	sibling 1
+	 * 128-191:	sibling 2
+	 * 192-255:	sibling 3
+	 */
+	__multiorder_tag_test(0, 8);
+	__multiorder_tag_test(190, 8);
+
+	/* same test, but with indices 256-511 */
+	__multiorder_tag_test(256, 8);
+	__multiorder_tag_test(300, 8);
+
+	__multiorder_tag_test(0x12345678UL, 8);
+}
+
 static void multiorder_check(unsigned long index, int order)
 {
 	unsigned long i;
@@ -196,6 +292,7 @@ void multiorder_checks(void)
 		multiorder_shrink((1UL << (i + RADIX_TREE_MAP_SHIFT)), i);
 
 	multiorder_insert_bug();
+	multiorder_tag_tests();
 	multiorder_iteration();
 	multiorder_tagged_iteration();
 }
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
