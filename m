Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6CDE36B026D
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 10:19:21 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id t124so131249613pfb.1
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 07:19:21 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id o81si7710341pfa.174.2016.04.14.07.19.20
        for <linux-mm@kvack.org>;
        Thu, 14 Apr 2016 07:19:20 -0700 (PDT)
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH v2 26/29] radix-tree: Rewrite radix_tree_locate_item
Date: Thu, 14 Apr 2016 10:16:47 -0400
Message-Id: <1460643410-30196-27-git-send-email-willy@linux.intel.com>
In-Reply-To: <1460643410-30196-1-git-send-email-willy@linux.intel.com>
References: <1460643410-30196-1-git-send-email-willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Neil Brown <neilb@suse.de>, Ross Zwisler <ross.zwisler@linux.intel.com>

Use the new multi-order support functions to rewrite
radix_tree_locate_item().  Modify the locate tests to test multiorder
entries too.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 lib/radix-tree.c                | 90 ++++++++++++++++++++---------------------
 tools/testing/radix-tree/main.c | 30 ++++++++------
 2 files changed, 63 insertions(+), 57 deletions(-)

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 9b5d8a9..c08b1b6 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -1303,58 +1303,55 @@ EXPORT_SYMBOL(radix_tree_gang_lookup_tag_slot);
 #if defined(CONFIG_SHMEM) && defined(CONFIG_SWAP)
 #include <linux/sched.h> /* for cond_resched() */
 
+struct locate_info {
+	unsigned long found_index;
+	bool stop;
+};
+
 /*
  * This linear search is at present only useful to shmem_unuse_inode().
  */
 static unsigned long __locate(struct radix_tree_node *slot, void *item,
-			      unsigned long index, unsigned long *found_index)
+			      unsigned long index, struct locate_info *info)
 {
 	unsigned int shift, height;
-	unsigned long i;
+	unsigned long base, i;
 
 	height = slot->path & RADIX_TREE_HEIGHT_MASK;
-	shift = (height-1) * RADIX_TREE_MAP_SHIFT;
+	shift = height * RADIX_TREE_MAP_SHIFT;
 
-	for ( ; height > 1; height--) {
-		i = (index >> shift) & RADIX_TREE_MAP_MASK;
-		for (;;) {
-			if (slot->slots[i] != NULL)
-				break;
-			index &= ~((1UL << shift) - 1);
-			index += 1UL << shift;
-			if (index == 0)
-				goto out;	/* 32-bit wraparound */
-			i++;
-			if (i == RADIX_TREE_MAP_SIZE)
+	do {
+		shift -= RADIX_TREE_MAP_SHIFT;
+		base = index & ~((1UL << shift) - 1);
+
+		for (i = (index >> shift) & RADIX_TREE_MAP_MASK;
+		     i < RADIX_TREE_MAP_SIZE;
+		     i++, index = base + (i << shift)) {
+			struct radix_tree_node *node =
+					rcu_dereference_raw(slot->slots[i]);
+			if (node == RADIX_TREE_RETRY)
 				goto out;
-		}
-
-		slot = rcu_dereference_raw(slot->slots[i]);
-		if (slot == NULL)
-			goto out;
-		if (!radix_tree_is_indirect_ptr(slot)) {
-			if (slot == item) {
-				*found_index = index + i;
-				index = 0;
-			} else {
-				index += shift;
+			if (!radix_tree_is_indirect_ptr(node)) {
+				if (node == item) {
+					info->found_index = index;
+					info->stop = true;
+					goto out;
+				}
+				continue;
 			}
-			goto out;
+			node = indirect_to_ptr(node);
+			if (is_sibling_entry(slot, node))
+				continue;
+			slot = node;
+			break;
 		}
-		slot = indirect_to_ptr(slot);
-		shift -= RADIX_TREE_MAP_SHIFT;
-	}
+		if (i == RADIX_TREE_MAP_SIZE)
+			break;
+	} while (shift);
 
-	/* Bottom level: check items */
-	for (i = 0; i < RADIX_TREE_MAP_SIZE; i++) {
-		if (slot->slots[i] == item) {
-			*found_index = index + i;
-			index = 0;
-			goto out;
-		}
-	}
-	index += RADIX_TREE_MAP_SIZE;
 out:
+	if ((index == 0) && (i == RADIX_TREE_MAP_SIZE))
+		info->stop = true;
 	return index;
 }
 
@@ -1372,7 +1369,10 @@ unsigned long radix_tree_locate_item(struct radix_tree_root *root, void *item)
 	struct radix_tree_node *node;
 	unsigned long max_index;
 	unsigned long cur_index = 0;
-	unsigned long found_index = -1;
+	struct locate_info info = {
+		.found_index = -1,
+		.stop = false,
+	};
 
 	do {
 		rcu_read_lock();
@@ -1380,24 +1380,24 @@ unsigned long radix_tree_locate_item(struct radix_tree_root *root, void *item)
 		if (!radix_tree_is_indirect_ptr(node)) {
 			rcu_read_unlock();
 			if (node == item)
-				found_index = 0;
+				info.found_index = 0;
 			break;
 		}
 
 		node = indirect_to_ptr(node);
-		max_index = radix_tree_maxindex(node->path &
-						RADIX_TREE_HEIGHT_MASK);
+
+		max_index = node_maxindex(node);
 		if (cur_index > max_index) {
 			rcu_read_unlock();
 			break;
 		}
 
-		cur_index = __locate(node, item, cur_index, &found_index);
+		cur_index = __locate(node, item, cur_index, &info);
 		rcu_read_unlock();
 		cond_resched();
-	} while (cur_index != 0 && cur_index <= max_index);
+	} while (!info.stop && cur_index <= max_index);
 
-	return found_index;
+	return info.found_index;
 }
 #else
 unsigned long radix_tree_locate_item(struct radix_tree_root *root, void *item)
diff --git a/tools/testing/radix-tree/main.c b/tools/testing/radix-tree/main.c
index b6a700b..65231e9 100644
--- a/tools/testing/radix-tree/main.c
+++ b/tools/testing/radix-tree/main.c
@@ -232,17 +232,18 @@ void copy_tag_check(void)
 	item_kill_tree(&tree);
 }
 
-void __locate_check(struct radix_tree_root *tree, unsigned long index)
+void __locate_check(struct radix_tree_root *tree, unsigned long index,
+			unsigned order)
 {
 	struct item *item;
 	unsigned long index2;
 
-	item_insert(tree, index);
+	item_insert_order(tree, index, order);
 	item = item_lookup(tree, index);
 	index2 = radix_tree_locate_item(tree, item);
 	if (index != index2) {
-		printf("index %ld inserted; found %ld\n",
-			index, index2);
+		printf("index %ld order %d inserted; found %ld\n",
+			index, order, index2);
 		abort();
 	}
 }
@@ -250,21 +251,26 @@ void __locate_check(struct radix_tree_root *tree, unsigned long index)
 static void locate_check(void)
 {
 	RADIX_TREE(tree, GFP_KERNEL);
+	unsigned order;
 	unsigned long offset, index;
 
-	for (offset = 0; offset < (1 << 3); offset++) {
-		for (index = 0; index < (1UL << 5); index++) {
-			__locate_check(&tree, index + offset);
-		}
-		if (radix_tree_locate_item(&tree, &tree) != -1)
-			abort();
+	for (order = 0; order < 20; order++) {
+		for (offset = 0; offset < (1 << (order + 3));
+		     offset += (1UL << order)) {
+			for (index = 0; index < (1UL << (order + 5));
+			     index += (1UL << order)) {
+				__locate_check(&tree, index + offset, order);
+			}
+			if (radix_tree_locate_item(&tree, &tree) != -1)
+				abort();
 
-		item_kill_tree(&tree);
+			item_kill_tree(&tree);
+		}
 	}
 
 	if (radix_tree_locate_item(&tree, &tree) != -1)
 		abort();
-	__locate_check(&tree, -1);
+	__locate_check(&tree, -1, 0);
 	if (radix_tree_locate_item(&tree, &tree) != -1)
 		abort();
 	item_kill_tree(&tree);
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
