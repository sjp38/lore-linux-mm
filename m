Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id C278B4403D8
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 22:41:00 -0500 (EST)
Received: by mail-pf0-f179.google.com with SMTP id n128so60732733pfn.3
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 19:41:00 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id fm8si20896396pad.29.2016.02.04.19.40.59
        for <linux-mm@kvack.org>;
        Thu, 04 Feb 2016 19:40:59 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH 1/2] radix-tree tests: Add regression3 test
Date: Thu,  4 Feb 2016 22:40:47 -0500
Message-Id: <1454643648-10002-2-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1454643648-10002-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1454643648-10002-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Matthew Wilcox <matthew.r.wilcox@intel.com>

From: Konstantin Khlebnikov <koct9i@gmail.com>

After calling radix_tree_iter_retry(), 'slot' will be set to NULL.
This can cause radix_tree_next_slot() to dereference the NULL pointer.
Add Konstantin Khlebnikov's test to the regression framework.

Reported-by: Konstantin Khlebnikov <koct9i@gmail.com>
Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
---
 tools/testing/radix-tree/Makefile       |  2 +-
 tools/testing/radix-tree/linux/kernel.h |  1 +
 tools/testing/radix-tree/main.c         |  1 +
 tools/testing/radix-tree/regression.h   |  1 +
 tools/testing/radix-tree/regression3.c  | 86 +++++++++++++++++++++++++++++++++
 5 files changed, 90 insertions(+), 1 deletion(-)
 create mode 100644 tools/testing/radix-tree/regression3.c

diff --git a/tools/testing/radix-tree/Makefile b/tools/testing/radix-tree/Makefile
index 582c8c6..3698a1a 100644
--- a/tools/testing/radix-tree/Makefile
+++ b/tools/testing/radix-tree/Makefile
@@ -3,7 +3,7 @@ CFLAGS += -I. -g -Wall -D_LGPL_SOURCE
 LDFLAGS += -lpthread -lurcu
 TARGETS = main
 OFILES = main.o radix-tree.o linux.o test.o tag_check.o find_next_bit.o \
-	 regression1.o regression2.o
+	 regression1.o regression2.o regression3.o
 
 targets: $(TARGETS)
 
diff --git a/tools/testing/radix-tree/linux/kernel.h b/tools/testing/radix-tree/linux/kernel.h
index 27d5fe4..ae013b0 100644
--- a/tools/testing/radix-tree/linux/kernel.h
+++ b/tools/testing/radix-tree/linux/kernel.h
@@ -13,6 +13,7 @@
 
 #define BUG_ON(expr)	assert(!(expr))
 #define __init
+#define __must_check
 #define panic(expr)
 #define printk printf
 #define __force
diff --git a/tools/testing/radix-tree/main.c b/tools/testing/radix-tree/main.c
index 6b8a412..0e83cad 100644
--- a/tools/testing/radix-tree/main.c
+++ b/tools/testing/radix-tree/main.c
@@ -261,6 +261,7 @@ int main(void)
 
 	regression1_test();
 	regression2_test();
+	regression3_test();
 	single_thread_tests();
 
 	sleep(1);
diff --git a/tools/testing/radix-tree/regression.h b/tools/testing/radix-tree/regression.h
index bb1c2ab..e018c48 100644
--- a/tools/testing/radix-tree/regression.h
+++ b/tools/testing/radix-tree/regression.h
@@ -3,5 +3,6 @@
 
 void regression1_test(void);
 void regression2_test(void);
+void regression3_test(void);
 
 #endif
diff --git a/tools/testing/radix-tree/regression3.c b/tools/testing/radix-tree/regression3.c
new file mode 100644
index 0000000..17d3ba5
--- /dev/null
+++ b/tools/testing/radix-tree/regression3.c
@@ -0,0 +1,86 @@
+/*
+ * Regression3
+ * Description:
+ * Helper radix_tree_iter_retry resets next_index to the current index.
+ * In following radix_tree_next_slot current chunk size becomes zero.
+ * This isn't checked and it tries to dereference null pointer in slot.
+ *
+ * Running:
+ * This test should run to completion immediately. The above bug would
+ * cause it to segfault.
+ *
+ * Upstream commit:
+ * Not yet
+ */
+#include <linux/kernel.h>
+#include <linux/gfp.h>
+#include <linux/slab.h>
+#include <linux/radix-tree.h>
+#include <stdlib.h>
+#include <stdio.h>
+
+#include "regression.h"
+
+void regression3_test(void)
+{
+	RADIX_TREE(root, GFP_KERNEL);
+	void *ptr = (void *)4ul;
+	struct radix_tree_iter iter;
+	void **slot;
+	bool first;
+
+	printf("running regression test 3 (should take milliseconds)\n");
+
+	radix_tree_insert(&root, 0, ptr);
+	radix_tree_tag_set(&root, 0, 0);
+
+	first = true;
+	radix_tree_for_each_tagged(slot, &root, &iter, 0, 0) {
+//		printk("tagged %ld %p\n", iter.index, *slot);
+		if (first) {
+			radix_tree_insert(&root, 1, ptr);
+			radix_tree_tag_set(&root, 1, 0);
+			first = false;
+		}
+		if (radix_tree_deref_retry(*slot)) {
+//			printk("retry %ld\n", iter.index);
+			slot = radix_tree_iter_retry(&iter);
+			continue;
+		}
+	}
+	radix_tree_delete(&root, 1);
+
+	first = true;
+	radix_tree_for_each_slot(slot, &root, &iter, 0) {
+//		printk("slot %ld %p\n", iter.index, *slot);
+		if (first) {
+			radix_tree_insert(&root, 1, ptr);
+			first = false;
+		}
+		if (radix_tree_deref_retry(*slot)) {
+//			printk("retry %ld\n", iter.index);
+			slot = radix_tree_iter_retry(&iter);
+			continue;
+		}
+	}
+	radix_tree_delete(&root, 1);
+
+	first = true;
+	radix_tree_for_each_contig(slot, &root, &iter, 0) {
+//		printk("contig %ld %p\n", iter.index, *slot);
+		if (first) {
+			radix_tree_insert(&root, 1, ptr);
+			first = false;
+		}
+		if (radix_tree_deref_retry(*slot)) {
+//			printk("retry %ld\n", iter.index);
+			slot = radix_tree_iter_retry(&iter);
+			continue;
+		}
+	}
+
+	radix_tree_delete(&root, 0);
+	radix_tree_delete(&root, 1);
+
+	printf("regression test 3 passed\n");
+}
-- 
2.7.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
