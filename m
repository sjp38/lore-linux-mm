Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 978746B0274
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 17:29:38 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id bx7so24375636pad.3
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 14:29:38 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id xd4si6912209pab.110.2016.04.06.14.21.54
        for <linux-mm@kvack.org>;
        Wed, 06 Apr 2016 14:21:54 -0700 (PDT)
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH 21/30] radix tree test suite: Add multiorder shrinking test
Date: Wed,  6 Apr 2016 17:21:30 -0400
Message-Id: <1459977699-2349-22-git-send-email-willy@linux.intel.com>
In-Reply-To: <1459977699-2349-1-git-send-email-willy@linux.intel.com>
References: <1459977699-2349-1-git-send-email-willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Neil Brown <neilb@suse.de>

Ensure that the tree goes back down to the same height when an item is
inserted & removed from the tree at a higher index.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 tools/testing/radix-tree/multiorder.c | 38 +++++++++++++++++++++++++++++++++++
 1 file changed, 38 insertions(+)

diff --git a/tools/testing/radix-tree/multiorder.c b/tools/testing/radix-tree/multiorder.c
index 583c5127fbcf..10b9708a71f9 100644
--- a/tools/testing/radix-tree/multiorder.c
+++ b/tools/testing/radix-tree/multiorder.c
@@ -46,6 +46,41 @@ static void multiorder_check(unsigned long index, int order)
 		item_check_absent(&tree, i);
 }
 
+static void multiorder_shrink(unsigned long index, int order)
+{
+	unsigned long i;
+	unsigned long max = 1 << order;
+	RADIX_TREE(tree, GFP_KERNEL);
+	struct radix_tree_node *node;
+
+	printf("Multiorder shrink index %ld, order %d\n", index, order);
+
+	assert(item_insert_order(&tree, 0, order) == 0);
+
+	node = tree.rnode;
+
+	assert(item_insert(&tree, index) == 0);
+	assert(node != tree.rnode);
+
+	assert(item_delete(&tree, index) != 0);
+	assert(node == tree.rnode);
+
+	for (i = 0; i < max; i++) {
+		struct item *item = item_lookup(&tree, i);
+		assert(item != 0);
+		assert(item->index == 0);
+	}
+	for (i = max; i < 2*max; i++)
+		item_check_absent(&tree, i);
+
+	if (!item_delete(&tree, 0)) {
+		printf("failed to delete index %ld (order %d)\n", index, order);		abort();
+	}
+
+	for (i = 0; i < 2*max; i++)
+		item_check_absent(&tree, i);
+}
+
 static void multiorder_insert_bug(void)
 {
 	RADIX_TREE(tree, GFP_KERNEL);
@@ -157,6 +192,9 @@ void multiorder_checks(void)
 		multiorder_check((1UL << i) + 1, i);
 	}
 
+	for (i = 0; i < 15; i++)
+		multiorder_shrink((1UL << (i + RADIX_TREE_MAP_SHIFT)), i);
+
 	multiorder_iteration();
 	multiorder_tagged_iteration();
 	multiorder_insert_bug();
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
