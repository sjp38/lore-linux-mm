Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f180.google.com (mail-lb0-f180.google.com [209.85.217.180])
	by kanga.kvack.org (Postfix) with ESMTP id 8B774828DF
	for <linux-mm@kvack.org>; Sat, 27 Feb 2016 06:42:58 -0500 (EST)
Received: by mail-lb0-f180.google.com with SMTP id x1so58847927lbj.3
        for <linux-mm@kvack.org>; Sat, 27 Feb 2016 03:42:58 -0800 (PST)
Received: from mail-lf0-x232.google.com (mail-lf0-x232.google.com. [2a00:1450:4010:c07::232])
        by mx.google.com with ESMTPS id n66si1231531lfb.86.2016.02.27.03.42.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 27 Feb 2016 03:42:57 -0800 (PST)
Received: by mail-lf0-x232.google.com with SMTP id l143so67363739lfe.2
        for <linux-mm@kvack.org>; Sat, 27 Feb 2016 03:42:57 -0800 (PST)
Subject: [PATCH 3/3] radix-tree tests: add test for radix_tree_iter_next
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Sat, 27 Feb 2016 14:42:54 +0300
Message-ID: <145657337431.9016.5746594400200475943.stgit@zurg>
In-Reply-To: <145657336413.9016.2011291702664991604.stgit@zurg>
References: <145657336413.9016.2011291702664991604.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org

Without fix test crashes inside tagged iteration.

Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
---
 tools/testing/radix-tree/regression3.c |   47 +++++++++++++++++++++++++++-----
 1 file changed, 39 insertions(+), 8 deletions(-)

diff --git a/tools/testing/radix-tree/regression3.c b/tools/testing/radix-tree/regression3.c
index 17d3ba5f4a0a..1f06ed73d0a8 100644
--- a/tools/testing/radix-tree/regression3.c
+++ b/tools/testing/radix-tree/regression3.c
@@ -5,6 +5,10 @@
  * In following radix_tree_next_slot current chunk size becomes zero.
  * This isn't checked and it tries to dereference null pointer in slot.
  *
+ * Helper radix_tree_iter_next reset slot to NULL and next_index to index + 1,
+ * for tagger iteraction it also must reset cached tags in iterator to abort
+ * next radix_tree_next_slot and go to slow-path into radix_tree_next_chunk.
+ *
  * Running:
  * This test should run to completion immediately. The above bug would
  * cause it to segfault.
@@ -24,26 +28,27 @@
 void regression3_test(void)
 {
 	RADIX_TREE(root, GFP_KERNEL);
-	void *ptr = (void *)4ul;
+	void *ptr0 = (void *)4ul;
+	void *ptr = (void *)8ul;
 	struct radix_tree_iter iter;
 	void **slot;
 	bool first;
 
 	printf("running regression test 3 (should take milliseconds)\n");
 
-	radix_tree_insert(&root, 0, ptr);
+	radix_tree_insert(&root, 0, ptr0);
 	radix_tree_tag_set(&root, 0, 0);
 
 	first = true;
 	radix_tree_for_each_tagged(slot, &root, &iter, 0, 0) {
-//		printk("tagged %ld %p\n", iter.index, *slot);
+		printf("tagged %ld %p\n", iter.index, *slot);
 		if (first) {
 			radix_tree_insert(&root, 1, ptr);
 			radix_tree_tag_set(&root, 1, 0);
 			first = false;
 		}
 		if (radix_tree_deref_retry(*slot)) {
-//			printk("retry %ld\n", iter.index);
+			printf("retry at %ld\n", iter.index);
 			slot = radix_tree_iter_retry(&iter);
 			continue;
 		}
@@ -52,13 +57,13 @@ void regression3_test(void)
 
 	first = true;
 	radix_tree_for_each_slot(slot, &root, &iter, 0) {
-//		printk("slot %ld %p\n", iter.index, *slot);
+		printf("slot %ld %p\n", iter.index, *slot);
 		if (first) {
 			radix_tree_insert(&root, 1, ptr);
 			first = false;
 		}
 		if (radix_tree_deref_retry(*slot)) {
-//			printk("retry %ld\n", iter.index);
+			printk("retry at %ld\n", iter.index);
 			slot = radix_tree_iter_retry(&iter);
 			continue;
 		}
@@ -67,18 +72,44 @@ void regression3_test(void)
 
 	first = true;
 	radix_tree_for_each_contig(slot, &root, &iter, 0) {
-//		printk("contig %ld %p\n", iter.index, *slot);
+		printk("contig %ld %p\n", iter.index, *slot);
 		if (first) {
 			radix_tree_insert(&root, 1, ptr);
 			first = false;
 		}
 		if (radix_tree_deref_retry(*slot)) {
-//			printk("retry %ld\n", iter.index);
+			printk("retry at %ld\n", iter.index);
 			slot = radix_tree_iter_retry(&iter);
 			continue;
 		}
 	}
 
+	radix_tree_for_each_slot(slot, &root, &iter, 0) {
+		printf("slot %ld %p\n", iter.index, *slot);
+		if (!iter.index) {
+			printf("next at %ld\n", iter.index);
+			slot = radix_tree_iter_next(&iter);
+		}
+	}
+
+	radix_tree_for_each_contig(slot, &root, &iter, 0) {
+		printf("contig %ld %p\n", iter.index, *slot);
+		if (!iter.index) {
+			printf("next at %ld\n", iter.index);
+			slot = radix_tree_iter_next(&iter);
+		}
+	}
+
+	radix_tree_tag_set(&root, 0, 0);
+	radix_tree_tag_set(&root, 1, 0);
+	radix_tree_for_each_tagged(slot, &root, &iter, 0, 0) {
+		printf("tagged %ld %p\n", iter.index, *slot);
+		if (!iter.index) {
+			printf("next at %ld\n", iter.index);
+			slot = radix_tree_iter_next(&iter);
+		}
+	}
+
 	radix_tree_delete(&root, 0);
 	radix_tree_delete(&root, 1);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
