Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 311BC830CD
	for <linux-mm@kvack.org>; Sat, 27 Aug 2016 10:16:29 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id e7so70526289lfe.0
        for <linux-mm@kvack.org>; Sat, 27 Aug 2016 07:16:29 -0700 (PDT)
Received: from mail-lf0-x241.google.com (mail-lf0-x241.google.com. [2a00:1450:4010:c07::241])
        by mx.google.com with ESMTPS id p80si11533552lfi.216.2016.08.27.07.16.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 27 Aug 2016 07:16:27 -0700 (PDT)
Received: by mail-lf0-x241.google.com with SMTP id f93so5069887lfi.0
        for <linux-mm@kvack.org>; Sat, 27 Aug 2016 07:16:27 -0700 (PDT)
Subject: [PATCH RFC 3/4] testing/radix-tree: replace multi-order with range
 operations
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Sat, 27 Aug 2016 17:16:21 +0300
Message-ID: <147230737440.10044.477174670700890206.stgit@zurg>
In-Reply-To: <147230727479.9957.1087787722571077339.stgit@zurg>
References: <147230727479.9957.1087787722571077339.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

This patch updates test for multi-order operations according to changes
in radix-tree: huge entry now must remember its range.

Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
---
 tools/testing/radix-tree/linux/bug.h      |    2 -
 tools/testing/radix-tree/linux/err.h      |   31 ++++++++
 tools/testing/radix-tree/linux/kernel.h   |    3 +
 tools/testing/radix-tree/linux/rcupdate.h |    6 ++
 tools/testing/radix-tree/multiorder.c     |  113 ++++++++++++++++-------------
 tools/testing/radix-tree/test.c           |   49 ++++++++++---
 tools/testing/radix-tree/test.h           |   15 ++--
 7 files changed, 151 insertions(+), 68 deletions(-)
 create mode 100644 tools/testing/radix-tree/linux/err.h

diff --git a/tools/testing/radix-tree/linux/bug.h b/tools/testing/radix-tree/linux/bug.h
index ccbe444977df..7a77fa971e91 100644
--- a/tools/testing/radix-tree/linux/bug.h
+++ b/tools/testing/radix-tree/linux/bug.h
@@ -1 +1 @@
-#define WARN_ON_ONCE(x)		assert(x)
+#define WARN_ON_ONCE(x)		assert(!(x))
diff --git a/tools/testing/radix-tree/linux/err.h b/tools/testing/radix-tree/linux/err.h
new file mode 100644
index 000000000000..6fd3e608d4d7
--- /dev/null
+++ b/tools/testing/radix-tree/linux/err.h
@@ -0,0 +1,31 @@
+#ifndef _LINUX_ERR_H
+#define _LINUX_ERR_H
+
+#define MAX_ERRNO       4095
+
+#define IS_ERR_VALUE(x) unlikely((unsigned long)(void *)(x) >= (unsigned long)-MAX_ERRNO)
+
+static inline void *ERR_PTR(long error)
+{
+	return (void *) error;
+}
+
+static inline long PTR_ERR(const void *ptr)
+{
+	return (long) ptr;
+}
+
+static inline bool IS_ERR(const void *ptr)
+{
+	return IS_ERR_VALUE((unsigned long)ptr);
+}
+
+static inline int PTR_ERR_OR_ZERO(const void *ptr)
+{
+	if (IS_ERR(ptr))
+		return PTR_ERR(ptr);
+	else
+		return 0;
+}
+
+#endif /* _LINUX_ERR_H */
diff --git a/tools/testing/radix-tree/linux/kernel.h b/tools/testing/radix-tree/linux/kernel.h
index be98a47b4e1b..52714e86991b 100644
--- a/tools/testing/radix-tree/linux/kernel.h
+++ b/tools/testing/radix-tree/linux/kernel.h
@@ -32,6 +32,9 @@
 
 #define ARRAY_SIZE(arr) (sizeof(arr) / sizeof((arr)[0]))
 
+#define IS_ALIGNED(x, a)	(((x) & ((typeof(x))(a) - 1)) == 0)
+#define is_power_of_2(n)	((n) != 0 && (((n) & ((n) - 1)) == 0))
+
 #define container_of(ptr, type, member) ({                      \
 	const typeof( ((type *)0)->member ) *__mptr = (ptr);    \
 	(type *)( (char *)__mptr - offsetof(type, member) );})
diff --git a/tools/testing/radix-tree/linux/rcupdate.h b/tools/testing/radix-tree/linux/rcupdate.h
index f7129ea2a899..8c4ae8173778 100644
--- a/tools/testing/radix-tree/linux/rcupdate.h
+++ b/tools/testing/radix-tree/linux/rcupdate.h
@@ -3,6 +3,12 @@
 
 #include <urcu.h>
 
+/* urcu.h includes errno.h which undefines ERANGE */
+#ifndef ERANGE
+#define ERANGE 34
+#endif
+
+#define RCU_INIT_POINTER(p, v) rcu_assign_pointer(p, v)
 #define rcu_dereference_raw(p) rcu_dereference(p)
 #define rcu_dereference_protected(p, cond) rcu_dereference(p)
 
diff --git a/tools/testing/radix-tree/multiorder.c b/tools/testing/radix-tree/multiorder.c
index 39d9b9568fe2..f73a3bfa83d8 100644
--- a/tools/testing/radix-tree/multiorder.c
+++ b/tools/testing/radix-tree/multiorder.c
@@ -29,7 +29,7 @@ static void __multiorder_tag_test(int index, int order)
 	unsigned long first = 0;
 
 	/* our canonical entry */
-	base = index & ~((1 << order) - 1);
+	base = index;
 
 	printf("Multiorder tag test with index %d, canonical entry %d\n",
 			index, base);
@@ -43,7 +43,7 @@ static void __multiorder_tag_test(int index, int order)
 	 * item_insert_order().
 	 */
 	for_each_index(i, base, order) {
-		err = __radix_tree_insert(&tree, i, order,
+		err = radix_tree_insert(&tree, i,
 				(void *)(0xA0 | RADIX_TREE_EXCEPTIONAL_ENTRY));
 		assert(err == -EEXIST);
 	}
@@ -55,18 +55,18 @@ static void __multiorder_tag_test(int index, int order)
 
 	assert(radix_tree_tag_set(&tree, index, 0));
 
-	for_each_index(i, base, order) {
-		assert(radix_tree_tag_get(&tree, i, 0));
+	assert(radix_tree_tag_get(&tree, index, 0));
+
+	for_each_index(i, base, order)
 		assert(!radix_tree_tag_get(&tree, i, 1));
-	}
 
 	assert(radix_tree_range_tag_if_tagged(&tree, &first, ~0UL, 10, 0, 1) == 1);
 	assert(radix_tree_tag_clear(&tree, index, 0));
 
-	for_each_index(i, base, order) {
+	assert(radix_tree_tag_get(&tree, index, 1));
+
+	for_each_index(i, base, order)
 		assert(!radix_tree_tag_get(&tree, i, 0));
-		assert(radix_tree_tag_get(&tree, i, 1));
-	}
 
 	assert(radix_tree_tag_clear(&tree, index, 1));
 
@@ -122,7 +122,7 @@ static void multiorder_tag_tests(void)
 static void multiorder_check(unsigned long index, int order)
 {
 	unsigned long i;
-	unsigned long min = index & ~((1UL << order) - 1);
+	unsigned long min = index;
 	unsigned long max = min + (1UL << order);
 	RADIX_TREE(tree, GFP_KERNEL);
 
@@ -145,7 +145,7 @@ static void multiorder_check(unsigned long index, int order)
 		assert(radix_tree_insert(&tree, i, entry) == -EEXIST);
 	}
 
-	assert(item_delete(&tree, index) != 0);
+	assert(item_delete_order(&tree, index, order) != 0);
 
 	for (i = 0; i < 2*max; i++)
 		item_check_absent(&tree, i);
@@ -178,7 +178,7 @@ static void multiorder_shrink(unsigned long index, int order)
 	for (i = max; i < 2*max; i++)
 		item_check_absent(&tree, i);
 
-	if (!item_delete(&tree, 0)) {
+	if (!item_delete_order(&tree, 0, order)) {
 		printf("failed to delete index %ld (order %d)\n", index, order);		abort();
 	}
 
@@ -221,14 +221,12 @@ void multiorder_iteration(void)
 				break;
 
 		radix_tree_for_each_slot(slot, &tree, &iter, j) {
-			int height = order[i] / RADIX_TREE_MAP_SHIFT;
-			int shift = height * RADIX_TREE_MAP_SHIFT;
 			int mask = (1 << order[i]) - 1;
 
 			assert(iter.index >= (index[i] &~ mask));
 			assert(iter.index <= (index[i] | mask));
-			assert(iter.shift == shift);
-			i++;
+			if (iter.index == (index[i] | mask))
+				i++;
 		}
 	}
 
@@ -248,36 +246,48 @@ void multiorder_tagged_iteration(void)
 #define MT_NUM_ENTRIES 9
 	int index[MT_NUM_ENTRIES] = {0, 2, 4, 16, 32, 40, 64, 72, 128};
 	int order[MT_NUM_ENTRIES] = {1, 0, 2, 4,  3,  1,  3,  0,   7};
-
-#define TAG_ENTRIES 7
-	int tag_index[TAG_ENTRIES] = {0, 4, 16, 40, 64, 72, 128};
+	int tag[MT_NUM_ENTRIES]   = {1, 0, 1, 1,  0,  1,  1,  1,   1};
 
 	for (i = 0; i < MT_NUM_ENTRIES; i++)
 		assert(!item_insert_order(&tree, index[i], order[i]));
 
 	assert(!radix_tree_tagged(&tree, 1));
 
-	for (i = 0; i < TAG_ENTRIES; i++)
-		assert(radix_tree_tag_set(&tree, tag_index[i], 1));
+	for (i = 0; i < MT_NUM_ENTRIES; i++) {
+		unsigned long end = item_order_end(index[i], order[i]);
+
+		assert(!radix_tree_tag_get(&tree, index[i], 1));
+		assert(!radix_tree_tag_get(&tree, end, 1));
+		if (tag[i])
+			assert(radix_tree_tag_set(&tree, end, 1));
+	}
+
+	for (i = 0; i < MT_NUM_ENTRIES; i++) {
+		unsigned long end = item_order_end(index[i], order[i]);
+
+		if (tag[i])
+			assert(radix_tree_tag_get(&tree, end, 1));
+		else
+			assert(!radix_tree_tag_get(&tree, end, 1));
+	}
 
 	for (j = 0; j < 256; j++) {
-		int mask, k;
+		int k;
 
-		for (i = 0; i < TAG_ENTRIES; i++) {
-			for (k = i; index[k] < tag_index[i]; k++)
-				;
-			if (j <= (index[k] | ((1 << order[k]) - 1)))
+		for (k = 0; k < MT_NUM_ENTRIES; k++)
+			if (tag[k] && j <= item_order_end(index[k], order[k]))
 				break;
-		}
 
 		radix_tree_for_each_tagged(slot, &tree, &iter, j, 1) {
-			for (k = i; index[k] < tag_index[i]; k++)
-				;
-			mask = (1 << order[k]) - 1;
-
-			assert(iter.index >= (tag_index[i] &~ mask));
-			assert(iter.index <= (tag_index[i] | mask));
-			i++;
+			unsigned long end = item_order_end(index[k], order[k]);
+
+			assert(k < MT_NUM_ENTRIES);
+			assert(radix_tree_tag_get(&tree, iter.index, 1));
+			assert(iter.index >= index[k]);
+			assert(iter.index <= end);
+			if (iter.index == end)
+				while (++k < MT_NUM_ENTRIES && !tag[k])
+					;
 		}
 	}
 
@@ -285,33 +295,36 @@ void multiorder_tagged_iteration(void)
 					MT_NUM_ENTRIES, 1, 2);
 
 	for (j = 0; j < 256; j++) {
-		int mask, k;
+		int k;
 
-		for (i = 0; i < TAG_ENTRIES; i++) {
-			for (k = i; index[k] < tag_index[i]; k++)
-				;
-			if (j <= (index[k] | ((1 << order[k]) - 1)))
+		for (k = 0; k < MT_NUM_ENTRIES; k++)
+			if (tag[k] && j <= item_order_end(index[k], order[k]))
 				break;
-		}
 
 		radix_tree_for_each_tagged(slot, &tree, &iter, j, 2) {
-			for (k = i; index[k] < tag_index[i]; k++)
-				;
-			mask = (1 << order[k]) - 1;
-
-			assert(iter.index >= (tag_index[i] &~ mask));
-			assert(iter.index <= (tag_index[i] | mask));
-			i++;
+			unsigned long end = item_order_end(index[k], order[k]);
+
+			assert(k < MT_NUM_ENTRIES);
+			assert(radix_tree_tag_get(&tree, iter.index, 2));
+			assert(iter.index >= index[k]);
+			assert(iter.index <= end);
+			if (iter.index == end)
+				while (++k < MT_NUM_ENTRIES && !tag[k])
+					;
 		}
 	}
 
-	first = 1;
+	assert(!radix_tree_tagged(&tree, 0));
+
+	first = index[1];
 	radix_tree_range_tag_if_tagged(&tree, &first, ~0UL,
 					MT_NUM_ENTRIES, 1, 0);
-	i = 0;
+
 	radix_tree_for_each_tagged(slot, &tree, &iter, 0, 0) {
-		assert(iter.index == tag_index[i]);
-		i++;
+		assert(radix_tree_tag_get(&tree, iter.index, 0));
+		assert(iter.index >= index[2]);
+		assert(iter.index <= item_order_end(index[2], order[2]));
+		break;
 	}
 
 	item_kill_tree(&tree);
diff --git a/tools/testing/radix-tree/test.c b/tools/testing/radix-tree/test.c
index a6e8099eaf4f..d6761d1a157a 100644
--- a/tools/testing/radix-tree/test.c
+++ b/tools/testing/radix-tree/test.c
@@ -4,6 +4,7 @@
 #include <linux/types.h>
 #include <linux/kernel.h>
 #include <linux/bitops.h>
+#include <linux/err.h>
 
 #include "test.h"
 
@@ -24,21 +25,23 @@ int item_tag_get(struct radix_tree_root *root, unsigned long index, int tag)
 	return radix_tree_tag_get(root, index, tag);
 }
 
-int __item_insert(struct radix_tree_root *root, struct item *item,
-			unsigned order)
+int item_insert(struct radix_tree_root *root, unsigned long index)
 {
-	return __radix_tree_insert(root, item->index, order, item);
+	return radix_tree_insert(root, index, item_create(index, index));
 }
 
-int item_insert(struct radix_tree_root *root, unsigned long index)
+unsigned long item_order_end(unsigned long index, unsigned int order)
 {
-	return __item_insert(root, item_create(index), 0);
+	return index + (1ul << order) - 1;
 }
 
 int item_insert_order(struct radix_tree_root *root, unsigned long index,
-			unsigned order)
+			unsigned int order)
 {
-	return __item_insert(root, item_create(index), order);
+	unsigned long end = item_order_end(index, order);
+
+	return PTR_ERR_OR_ZERO(radix_tree_fill_range(root, index, end,
+				item_create(index, end), 0));
 }
 
 int item_delete(struct radix_tree_root *root, unsigned long index)
@@ -47,17 +50,34 @@ int item_delete(struct radix_tree_root *root, unsigned long index)
 
 	if (item) {
 		assert(item->index == index);
+		assert(item->end == index);
 		free(item);
 		return 1;
 	}
 	return 0;
 }
 
-struct item *item_create(unsigned long index)
+int item_delete_order(struct radix_tree_root *root, unsigned long index,
+			unsigned int order)
+{
+	struct item *item = radix_tree_lookup(root, index);
+	unsigned long end = item_order_end(index, order);
+
+	if (item) {
+		assert(item->index == index);
+		assert(item->end == end);
+	}
+	radix_tree_truncate_range(root, index, end);
+	free(item);
+	return !!item;
+}
+
+struct item *item_create(unsigned long index, unsigned long end)
 {
 	struct item *ret = malloc(sizeof(*ret));
 
 	ret->index = index;
+	ret->end = end;
 	return ret;
 }
 
@@ -207,10 +227,17 @@ void item_kill_tree(struct radix_tree_root *root)
 		int i;
 
 		for (i = 0; i < nfound; i++) {
-			void *ret;
+			void *item;
+
+			if (items[i]->index != items[i]->end) {
+				radix_tree_truncate_range(root, items[i]->index,
+								items[i]->end);
+				free(items[i]);
+				break;
+			}
 
-			ret = radix_tree_delete(root, items[i]->index);
-			assert(ret == items[i]);
+			item = radix_tree_delete(root, items[i]->index);
+			assert(item == items[i]);
 			free(items[i]);
 		}
 	}
diff --git a/tools/testing/radix-tree/test.h b/tools/testing/radix-tree/test.h
index 217fb2403f09..93a6ce5e5a59 100644
--- a/tools/testing/radix-tree/test.h
+++ b/tools/testing/radix-tree/test.h
@@ -4,16 +4,19 @@
 #include <linux/rcupdate.h>
 
 struct item {
-	unsigned long index;
+	unsigned long index, end;
 };
 
-struct item *item_create(unsigned long index);
-int __item_insert(struct radix_tree_root *root, struct item *item,
-			unsigned order);
+struct item *item_create(unsigned long index, unsigned long end);
 int item_insert(struct radix_tree_root *root, unsigned long index);
-int item_insert_order(struct radix_tree_root *root, unsigned long index,
-			unsigned order);
 int item_delete(struct radix_tree_root *root, unsigned long index);
+
+unsigned long item_order_end(unsigned long index, unsigned int order);
+int item_insert_order(struct radix_tree_root *root, unsigned long index,
+			unsigned int order);
+int item_delete_order(struct radix_tree_root *root, unsigned long index,
+			unsigned int order);
+
 struct item *item_lookup(struct radix_tree_root *root, unsigned long index);
 
 void item_check_present(struct radix_tree_root *root, unsigned long index);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
