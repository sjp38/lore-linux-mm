Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 099176B025E
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 17:21:56 -0400 (EDT)
Received: by mail-pf0-f173.google.com with SMTP id 184so41230771pff.0
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 14:21:56 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id yk5si6891850pab.160.2016.04.06.14.21.50
        for <linux-mm@kvack.org>;
        Wed, 06 Apr 2016 14:21:50 -0700 (PDT)
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH 03/30] radix tree test suite: Add tests for radix_tree_locate_item()
Date: Wed,  6 Apr 2016 17:21:12 -0400
Message-Id: <1459977699-2349-4-git-send-email-willy@linux.intel.com>
In-Reply-To: <1459977699-2349-1-git-send-email-willy@linux.intel.com>
References: <1459977699-2349-1-git-send-email-willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Neil Brown <neilb@suse.de>

Fairly simple tests; add various items to the tree, then make sure we
can find them again.  Also check that a pointer that we know isn't in
the tree is not found.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 tools/testing/radix-tree/linux/kernel.h |  3 +++
 tools/testing/radix-tree/main.c         | 41 +++++++++++++++++++++++++++++++++
 2 files changed, 44 insertions(+)

diff --git a/tools/testing/radix-tree/linux/kernel.h b/tools/testing/radix-tree/linux/kernel.h
index 6d0cdf618084..76a88f35fdc4 100644
--- a/tools/testing/radix-tree/linux/kernel.h
+++ b/tools/testing/radix-tree/linux/kernel.h
@@ -9,6 +9,9 @@
 
 #include "../../include/linux/compiler.h"
 
+#define CONFIG_SHMEM
+#define CONFIG_SWAP
+
 #ifndef NULL
 #define NULL	0
 #endif
diff --git a/tools/testing/radix-tree/main.c b/tools/testing/radix-tree/main.c
index 0e83cad27a9f..71c5272443b1 100644
--- a/tools/testing/radix-tree/main.c
+++ b/tools/testing/radix-tree/main.c
@@ -232,10 +232,51 @@ void copy_tag_check(void)
 	item_kill_tree(&tree);
 }
 
+void __locate_check(struct radix_tree_root *tree, unsigned long index)
+{
+	struct item *item;
+	unsigned long index2;
+
+	item_insert(tree, index);
+	item = item_lookup(tree, index);
+	index2 = radix_tree_locate_item(tree, item);
+	if (index != index2) {
+		printf("index %ld inserted; found %ld\n",
+			index, index2);
+		abort();
+	}
+}
+
+static void locate_check(void)
+{
+	RADIX_TREE(tree, GFP_KERNEL);
+	unsigned long offset, index;
+
+	for (offset = 0; offset < (1 << 3); offset++) {
+		for (index = 0; index < (1UL << 5); index++) {
+			__locate_check(&tree, index + offset);
+		}
+		if (radix_tree_locate_item(&tree, &tree) != -1)
+			abort();
+
+		item_kill_tree(&tree);
+	}
+
+	if (radix_tree_locate_item(&tree, &tree) != -1)
+		abort();
+	__locate_check(&tree, -1);
+	if (radix_tree_locate_item(&tree, &tree) != -1)
+		abort();
+	item_kill_tree(&tree);
+}
+
 static void single_thread_tests(void)
 {
 	int i;
 
+	printf("starting single_thread_tests: %d allocated\n", nr_allocated);
+	locate_check();
+	printf("after locate_check: %d allocated\n", nr_allocated);
 	tag_check();
 	printf("after tag_check: %d allocated\n", nr_allocated);
 	gang_check();
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
