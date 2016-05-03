Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6BEC96B0005
	for <linux-mm@kvack.org>; Tue,  3 May 2016 16:28:03 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id yl2so42009434pac.2
        for <linux-mm@kvack.org>; Tue, 03 May 2016 13:28:03 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id 6si173952paj.187.2016.05.03.13.28.02
        for <linux-mm@kvack.org>;
        Tue, 03 May 2016 13:28:02 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH] radix-tree: add test for radix_tree_locate_item()
Date: Tue,  3 May 2016 14:27:43 -0600
Message-Id: <1462307263-20623-1-git-send-email-ross.zwisler@linux.intel.com>
In-Reply-To: <alpine.LSU.2.11.1605012108490.1166@eggly.anvils>
References: <alpine.LSU.2.11.1605012108490.1166@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org

Add a unit test that provides coverage for the bug fixed in the commit
entitled "radix-tree: rewrite radix_tree_locate_item fix" from Hugh
Dickins.  I've verified that this test fails before his patch due to
miscalculated 'index' values in __locate() in lib/radix-tree.c, and passes
with his fix.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 tools/testing/radix-tree/linux/init.h |  1 +
 tools/testing/radix-tree/main.c       | 15 ++++++++++++++-
 2 files changed, 15 insertions(+), 1 deletion(-)
 create mode 100644 tools/testing/radix-tree/linux/init.h

diff --git a/tools/testing/radix-tree/linux/init.h b/tools/testing/radix-tree/linux/init.h
new file mode 100644
index 0000000..360cabb
--- /dev/null
+++ b/tools/testing/radix-tree/linux/init.h
@@ -0,0 +1 @@
+/* An empty file stub that allows radix-tree.c to compile. */
diff --git a/tools/testing/radix-tree/main.c b/tools/testing/radix-tree/main.c
index 65231e9..b7619ff 100644
--- a/tools/testing/radix-tree/main.c
+++ b/tools/testing/radix-tree/main.c
@@ -232,7 +232,7 @@ void copy_tag_check(void)
 	item_kill_tree(&tree);
 }
 
-void __locate_check(struct radix_tree_root *tree, unsigned long index,
+static void __locate_check(struct radix_tree_root *tree, unsigned long index,
 			unsigned order)
 {
 	struct item *item;
@@ -248,12 +248,25 @@ void __locate_check(struct radix_tree_root *tree, unsigned long index,
 	}
 }
 
+static void __order_0_locate_check(void)
+{
+	RADIX_TREE(tree, GFP_KERNEL);
+	int i;
+
+	for (i = 0; i < 50; i++)
+		__locate_check(&tree, rand() % INT_MAX, 0);
+
+	item_kill_tree(&tree);
+}
+
 static void locate_check(void)
 {
 	RADIX_TREE(tree, GFP_KERNEL);
 	unsigned order;
 	unsigned long offset, index;
 
+	__order_0_locate_check();
+
 	for (order = 0; order < 20; order++) {
 		for (offset = 0; offset < (1 << (order + 3));
 		     offset += (1UL << order)) {
-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
