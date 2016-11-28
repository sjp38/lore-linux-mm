Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id EBAEF6B02D5
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 14:58:41 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id r101so261720275ioi.3
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 11:58:41 -0800 (PST)
Received: from p3plsmtps2ded02.prod.phx3.secureserver.net (p3plsmtps2ded02.prod.phx3.secureserver.net. [208.109.80.59])
        by mx.google.com with ESMTPS id v5si19934450ith.59.2016.11.28.11.56.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Nov 2016 11:56:38 -0800 (PST)
From: Matthew Wilcox <mawilcox@linuxonhyperv.com>
Subject: [PATCH v3 11/33] radix tree test suite: record order in each item
Date: Mon, 28 Nov 2016 13:50:15 -0800
Message-Id: <1480369871-5271-12-git-send-email-mawilcox@linuxonhyperv.com>
In-Reply-To: <1480369871-5271-1-git-send-email-mawilcox@linuxonhyperv.com>
References: <1480369871-5271-1-git-send-email-mawilcox@linuxonhyperv.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

This probably doubles the size of each item allocated by the test suite
but it lets us check a few more things, and may be needed for upcoming
API changes that require the caller pass in the order of the entry.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 tools/testing/radix-tree/multiorder.c |  2 +-
 tools/testing/radix-tree/test.c       | 29 +++++++++++++++++++----------
 tools/testing/radix-tree/test.h       |  6 +++---
 3 files changed, 23 insertions(+), 14 deletions(-)

diff --git a/tools/testing/radix-tree/multiorder.c b/tools/testing/radix-tree/multiorder.c
index d1be946..8d5865c 100644
--- a/tools/testing/radix-tree/multiorder.c
+++ b/tools/testing/radix-tree/multiorder.c
@@ -125,7 +125,7 @@ static void multiorder_check(unsigned long index, int order)
 	unsigned long min = index & ~((1UL << order) - 1);
 	unsigned long max = min + (1UL << order);
 	void **slot;
-	struct item *item2 = item_create(min);
+	struct item *item2 = item_create(min, order);
 	RADIX_TREE(tree, GFP_KERNEL);
 
 	printf("Multiorder index %ld, order %d\n", index, order);
diff --git a/tools/testing/radix-tree/test.c b/tools/testing/radix-tree/test.c
index 6f8dafc..0de5489 100644
--- a/tools/testing/radix-tree/test.c
+++ b/tools/testing/radix-tree/test.c
@@ -24,21 +24,29 @@ int item_tag_get(struct radix_tree_root *root, unsigned long index, int tag)
 	return radix_tree_tag_get(root, index, tag);
 }
 
-int __item_insert(struct radix_tree_root *root, struct item *item,
-			unsigned order)
+int __item_insert(struct radix_tree_root *root, struct item *item)
 {
-	return __radix_tree_insert(root, item->index, order, item);
+	return __radix_tree_insert(root, item->index, item->order, item);
 }
 
 int item_insert(struct radix_tree_root *root, unsigned long index)
 {
-	return __item_insert(root, item_create(index), 0);
+	return __item_insert(root, item_create(index, 0));
 }
 
 int item_insert_order(struct radix_tree_root *root, unsigned long index,
 			unsigned order)
 {
-	return __item_insert(root, item_create(index), order);
+	return __item_insert(root, item_create(index, order));
+}
+
+void item_sanity(struct item *item, unsigned long index)
+{
+	unsigned long mask;
+	assert(!radix_tree_is_internal_node(item));
+	assert(item->order < BITS_PER_LONG);
+	mask = (1UL << item->order) - 1;
+	assert((item->index | mask) == (index | mask));
 }
 
 int item_delete(struct radix_tree_root *root, unsigned long index)
@@ -46,18 +54,19 @@ int item_delete(struct radix_tree_root *root, unsigned long index)
 	struct item *item = radix_tree_delete(root, index);
 
 	if (item) {
-		assert(item->index == index);
+		item_sanity(item, index);
 		free(item);
 		return 1;
 	}
 	return 0;
 }
 
-struct item *item_create(unsigned long index)
+struct item *item_create(unsigned long index, unsigned int order)
 {
 	struct item *ret = malloc(sizeof(*ret));
 
 	ret->index = index;
+	ret->order = order;
 	return ret;
 }
 
@@ -66,8 +75,8 @@ void item_check_present(struct radix_tree_root *root, unsigned long index)
 	struct item *item;
 
 	item = radix_tree_lookup(root, index);
-	assert(item != 0);
-	assert(item->index == index);
+	assert(item != NULL);
+	item_sanity(item, index);
 }
 
 struct item *item_lookup(struct radix_tree_root *root, unsigned long index)
@@ -80,7 +89,7 @@ void item_check_absent(struct radix_tree_root *root, unsigned long index)
 	struct item *item;
 
 	item = radix_tree_lookup(root, index);
-	assert(item == 0);
+	assert(item == NULL);
 }
 
 /*
diff --git a/tools/testing/radix-tree/test.h b/tools/testing/radix-tree/test.h
index 215ab77..423c528 100644
--- a/tools/testing/radix-tree/test.h
+++ b/tools/testing/radix-tree/test.h
@@ -5,11 +5,11 @@
 
 struct item {
 	unsigned long index;
+	unsigned int order;
 };
 
-struct item *item_create(unsigned long index);
-int __item_insert(struct radix_tree_root *root, struct item *item,
-			unsigned order);
+struct item *item_create(unsigned long index, unsigned int order);
+int __item_insert(struct radix_tree_root *root, struct item *item);
 int item_insert(struct radix_tree_root *root, unsigned long index);
 int item_insert_order(struct radix_tree_root *root, unsigned long index,
 			unsigned order);
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
