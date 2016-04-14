Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3D0D66B025F
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 10:17:39 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id zy2so92836905pac.1
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 07:17:39 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id w13si4753111pas.206.2016.04.14.07.17.31
        for <linux-mm@kvack.org>;
        Thu, 14 Apr 2016 07:17:31 -0700 (PDT)
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH v2 15/29] radix tree test suite: Start adding multiorder tests
Date: Thu, 14 Apr 2016 10:16:36 -0400
Message-Id: <1460643410-30196-16-git-send-email-willy@linux.intel.com>
In-Reply-To: <1460643410-30196-1-git-send-email-willy@linux.intel.com>
References: <1460643410-30196-1-git-send-email-willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Neil Brown <neilb@suse.de>, Ross Zwisler <ross.zwisler@linux.intel.com>

Test suite infrastructure for working with multiorder entries.

The test itself is pretty basic: Add an entry, check that all expected
indices return that entry and that indices around that entry don't return
an entry. Then delete the entry and check no index returns that entry.
Tests a few edge conditions including the multiorder entry at index 0
and at a higher index.  Also tests deleting through an alias as well as
through the canonical index.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 tools/testing/radix-tree/Makefile     |  2 +-
 tools/testing/radix-tree/main.c       |  2 ++
 tools/testing/radix-tree/multiorder.c | 58 +++++++++++++++++++++++++++++++++++
 tools/testing/radix-tree/test.c       | 13 ++++++--
 tools/testing/radix-tree/test.h       |  6 +++-
 5 files changed, 76 insertions(+), 5 deletions(-)
 create mode 100644 tools/testing/radix-tree/multiorder.c

diff --git a/tools/testing/radix-tree/Makefile b/tools/testing/radix-tree/Makefile
index 43febba..3b53046 100644
--- a/tools/testing/radix-tree/Makefile
+++ b/tools/testing/radix-tree/Makefile
@@ -3,7 +3,7 @@ CFLAGS += -I. -g -Wall -D_LGPL_SOURCE
 LDFLAGS += -lpthread -lurcu
 TARGETS = main
 OFILES = main.o radix-tree.o linux.o test.o tag_check.o find_next_bit.o \
-	 regression1.o regression2.o regression3.o
+	 regression1.o regression2.o regression3.o multiorder.o
 
 targets: $(TARGETS)
 
diff --git a/tools/testing/radix-tree/main.c b/tools/testing/radix-tree/main.c
index 122c8b9..b6a700b 100644
--- a/tools/testing/radix-tree/main.c
+++ b/tools/testing/radix-tree/main.c
@@ -275,6 +275,8 @@ static void single_thread_tests(bool long_run)
 	int i;
 
 	printf("starting single_thread_tests: %d allocated\n", nr_allocated);
+	multiorder_checks();
+	printf("after multiorder_check: %d allocated\n", nr_allocated);
 	locate_check();
 	printf("after locate_check: %d allocated\n", nr_allocated);
 	tag_check();
diff --git a/tools/testing/radix-tree/multiorder.c b/tools/testing/radix-tree/multiorder.c
new file mode 100644
index 0000000..cfe718c
--- /dev/null
+++ b/tools/testing/radix-tree/multiorder.c
@@ -0,0 +1,58 @@
+/*
+ * multiorder.c: Multi-order radix tree entry testing
+ * Copyright (c) 2016 Intel Corporation
+ * Author: Ross Zwisler <ross.zwisler@linux.intel.com>
+ * Author: Matthew Wilcox <matthew.r.wilcox@intel.com>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ */
+#include <linux/radix-tree.h>
+#include <linux/slab.h>
+#include <linux/errno.h>
+
+#include "test.h"
+
+static void multiorder_check(unsigned long index, int order)
+{
+	unsigned long i;
+	unsigned long min = index & ~((1UL << order) - 1);
+	unsigned long max = min + (1UL << order);
+	RADIX_TREE(tree, GFP_KERNEL);
+
+	printf("Multiorder index %ld, order %d\n", index, order);
+
+	assert(item_insert_order(&tree, index, order) == 0);
+
+	for (i = min; i < max; i++) {
+		struct item *item = item_lookup(&tree, i);
+		assert(item != 0);
+		assert(item->index == index);
+	}
+	for (i = 0; i < min; i++)
+		item_check_absent(&tree, i);
+	for (i = max; i < 2*max; i++)
+		item_check_absent(&tree, i);
+
+	assert(item_delete(&tree, index) != 0);
+
+	for (i = 0; i < 2*max; i++)
+		item_check_absent(&tree, i);
+}
+
+void multiorder_checks(void)
+{
+	int i;
+
+	for (i = 0; i < 20; i++) {
+		multiorder_check(200, i);
+		multiorder_check(0, i);
+		multiorder_check((1UL << i) + 1, i);
+	}
+}
diff --git a/tools/testing/radix-tree/test.c b/tools/testing/radix-tree/test.c
index 2bebf34..da54f11 100644
--- a/tools/testing/radix-tree/test.c
+++ b/tools/testing/radix-tree/test.c
@@ -24,14 +24,21 @@ int item_tag_get(struct radix_tree_root *root, unsigned long index, int tag)
 	return radix_tree_tag_get(root, index, tag);
 }
 
-int __item_insert(struct radix_tree_root *root, struct item *item)
+int __item_insert(struct radix_tree_root *root, struct item *item,
+			unsigned order)
 {
-	return radix_tree_insert(root, item->index, item);
+	return __radix_tree_insert(root, item->index, order, item);
 }
 
 int item_insert(struct radix_tree_root *root, unsigned long index)
 {
-	return __item_insert(root, item_create(index));
+	return __item_insert(root, item_create(index), 0);
+}
+
+int item_insert_order(struct radix_tree_root *root, unsigned long index,
+			unsigned order)
+{
+	return __item_insert(root, item_create(index), order);
 }
 
 int item_delete(struct radix_tree_root *root, unsigned long index)
diff --git a/tools/testing/radix-tree/test.h b/tools/testing/radix-tree/test.h
index 4e1d95f..53cb595 100644
--- a/tools/testing/radix-tree/test.h
+++ b/tools/testing/radix-tree/test.h
@@ -8,8 +8,11 @@ struct item {
 };
 
 struct item *item_create(unsigned long index);
-int __item_insert(struct radix_tree_root *root, struct item *item);
+int __item_insert(struct radix_tree_root *root, struct item *item,
+			unsigned order);
 int item_insert(struct radix_tree_root *root, unsigned long index);
+int item_insert_order(struct radix_tree_root *root, unsigned long index,
+			unsigned order);
 int item_delete(struct radix_tree_root *root, unsigned long index);
 struct item *item_lookup(struct radix_tree_root *root, unsigned long index);
 
@@ -23,6 +26,7 @@ void item_full_scan(struct radix_tree_root *root, unsigned long start,
 void item_kill_tree(struct radix_tree_root *root);
 
 void tag_check(void);
+void multiorder_checks(void);
 
 struct item *
 item_tag_set(struct radix_tree_root *root, unsigned long index, int tag);
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
