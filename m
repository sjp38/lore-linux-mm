Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0CF5C6B0273
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 10:21:58 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id dx6so49965699pad.0
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 07:21:58 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id 128si12390657pfu.156.2016.04.14.07.21.57
        for <linux-mm@kvack.org>;
        Thu, 14 Apr 2016 07:21:57 -0700 (PDT)
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH v2 03/29] radix tree test suite: Add tests for radix_tree_locate_item()
Date: Thu, 14 Apr 2016 10:16:24 -0400
Message-Id: <1460643410-30196-4-git-send-email-willy@linux.intel.com>
In-Reply-To: <1460643410-30196-1-git-send-email-willy@linux.intel.com>
References: <1460643410-30196-1-git-send-email-willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Neil Brown <neilb@suse.de>, Ross Zwisler <ross.zwisler@linux.intel.com>

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
index 6d0cdf6..76a88f3 100644
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
index 0e83cad..71c5272 100644
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
