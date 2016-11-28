Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id F3B816B0277
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 14:56:39 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id m203so260417997iom.6
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 11:56:39 -0800 (PST)
Received: from p3plsmtps2ded02.prod.phx3.secureserver.net (p3plsmtps2ded02.prod.phx3.secureserver.net. [208.109.80.59])
        by mx.google.com with ESMTPS id f4si19953726itg.31.2016.11.28.11.56.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Nov 2016 11:56:39 -0800 (PST)
From: Matthew Wilcox <mawilcox@linuxonhyperv.com>
Subject: [PATCH v3 21/33] radix-tree: Delete radix_tree_locate_item()
Date: Mon, 28 Nov 2016 13:50:59 -0800
Message-Id: <1480369871-5271-56-git-send-email-mawilcox@linuxonhyperv.com>
In-Reply-To: <1480369871-5271-1-git-send-email-mawilcox@linuxonhyperv.com>
References: <1480369871-5271-1-git-send-email-mawilcox@linuxonhyperv.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

This rather complicated function can be better implemented as an iterator.
It has only one caller, so move the functionality to the only place that
needs it.  Update the test suite to follow the same pattern.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
Acked-by: Konstantin Khlebnikov <koct9i@gmail.com>
---
 include/linux/radix-tree.h      |  1 -
 lib/radix-tree.c                | 99 -----------------------------------------
 mm/shmem.c                      | 26 ++++++++++-
 tools/testing/radix-tree/main.c |  8 ++--
 tools/testing/radix-tree/test.c | 22 +++++++++
 tools/testing/radix-tree/test.h |  2 +
 6 files changed, 53 insertions(+), 105 deletions(-)

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index 289d007..a13d3f7c6c 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -296,7 +296,6 @@ unsigned long radix_tree_range_tag_if_tagged(struct radix_tree_root *root,
 		unsigned long nr_to_tag,
 		unsigned int fromtag, unsigned int totag);
 int radix_tree_tagged(struct radix_tree_root *root, unsigned int tag);
-unsigned long radix_tree_locate_item(struct radix_tree_root *root, void *item);
 
 static inline void radix_tree_preload_end(void)
 {
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index f8fab01..54ef055 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -1578,105 +1578,6 @@ radix_tree_gang_lookup_tag_slot(struct radix_tree_root *root, void ***results,
 }
 EXPORT_SYMBOL(radix_tree_gang_lookup_tag_slot);
 
-#if defined(CONFIG_SHMEM) && defined(CONFIG_SWAP)
-#include <linux/sched.h> /* for cond_resched() */
-
-struct locate_info {
-	unsigned long found_index;
-	bool stop;
-};
-
-/*
- * This linear search is at present only useful to shmem_unuse_inode().
- */
-static unsigned long __locate(struct radix_tree_node *slot, void *item,
-			      unsigned long index, struct locate_info *info)
-{
-	unsigned long i;
-
-	do {
-		unsigned int shift = slot->shift;
-
-		for (i = (index >> shift) & RADIX_TREE_MAP_MASK;
-		     i < RADIX_TREE_MAP_SIZE;
-		     i++, index += (1UL << shift)) {
-			struct radix_tree_node *node =
-					rcu_dereference_raw(slot->slots[i]);
-			if (node == RADIX_TREE_RETRY)
-				goto out;
-			if (!radix_tree_is_internal_node(node)) {
-				if (node == item) {
-					info->found_index = index;
-					info->stop = true;
-					goto out;
-				}
-				continue;
-			}
-			node = entry_to_node(node);
-			if (is_sibling_entry(slot, node))
-				continue;
-			slot = node;
-			break;
-		}
-	} while (i < RADIX_TREE_MAP_SIZE);
-
-out:
-	if ((index == 0) && (i == RADIX_TREE_MAP_SIZE))
-		info->stop = true;
-	return index;
-}
-
-/**
- *	radix_tree_locate_item - search through radix tree for item
- *	@root:		radix tree root
- *	@item:		item to be found
- *
- *	Returns index where item was found, or -1 if not found.
- *	Caller must hold no lock (since this time-consuming function needs
- *	to be preemptible), and must check afterwards if item is still there.
- */
-unsigned long radix_tree_locate_item(struct radix_tree_root *root, void *item)
-{
-	struct radix_tree_node *node;
-	unsigned long max_index;
-	unsigned long cur_index = 0;
-	struct locate_info info = {
-		.found_index = -1,
-		.stop = false,
-	};
-
-	do {
-		rcu_read_lock();
-		node = rcu_dereference_raw(root->rnode);
-		if (!radix_tree_is_internal_node(node)) {
-			rcu_read_unlock();
-			if (node == item)
-				info.found_index = 0;
-			break;
-		}
-
-		node = entry_to_node(node);
-
-		max_index = node_maxindex(node);
-		if (cur_index > max_index) {
-			rcu_read_unlock();
-			break;
-		}
-
-		cur_index = __locate(node, item, cur_index, &info);
-		rcu_read_unlock();
-		cond_resched();
-	} while (!info.stop && cur_index <= max_index);
-
-	return info.found_index;
-}
-#else
-unsigned long radix_tree_locate_item(struct radix_tree_root *root, void *item)
-{
-	return -1;
-}
-#endif /* CONFIG_SHMEM && CONFIG_SWAP */
-
 /**
  *	__radix_tree_delete_node    -    try to free node after clearing a slot
  *	@root:		radix tree root
diff --git a/mm/shmem.c b/mm/shmem.c
index b9a785e..0dd83bb 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1049,6 +1049,30 @@ static void shmem_evict_inode(struct inode *inode)
 	clear_inode(inode);
 }
 
+static unsigned long find_swap_entry(struct radix_tree_root *root, void *item)
+{
+	struct radix_tree_iter iter;
+	void **slot;
+	unsigned long found = -1;
+	unsigned int checked = 0;
+
+	rcu_read_lock();
+	radix_tree_for_each_slot(slot, root, &iter, 0) {
+		if (*slot == item) {
+			found = iter.index;
+			break;
+		}
+		checked++;
+		if ((checked % 4096) != 0)
+			continue;
+		slot = radix_tree_iter_resume(slot, &iter);
+		cond_resched_rcu();
+	}
+
+	rcu_read_unlock();
+	return found;
+}
+
 /*
  * If swap found in inode, free it and move page from swapcache to filecache.
  */
@@ -1062,7 +1086,7 @@ static int shmem_unuse_inode(struct shmem_inode_info *info,
 	int error = 0;
 
 	radswap = swp_to_radix_entry(swap);
-	index = radix_tree_locate_item(&mapping->page_tree, radswap);
+	index = find_swap_entry(&mapping->page_tree, radswap);
 	if (index == -1)
 		return -EAGAIN;	/* tell shmem_unuse we found nothing */
 
diff --git a/tools/testing/radix-tree/main.c b/tools/testing/radix-tree/main.c
index 76d9c95..a028dae 100644
--- a/tools/testing/radix-tree/main.c
+++ b/tools/testing/radix-tree/main.c
@@ -239,7 +239,7 @@ static void __locate_check(struct radix_tree_root *tree, unsigned long index,
 
 	item_insert_order(tree, index, order);
 	item = item_lookup(tree, index);
-	index2 = radix_tree_locate_item(tree, item);
+	index2 = find_item(tree, item);
 	if (index != index2) {
 		printf("index %ld order %d inserted; found %ld\n",
 			index, order, index2);
@@ -273,17 +273,17 @@ static void locate_check(void)
 			     index += (1UL << order)) {
 				__locate_check(&tree, index + offset, order);
 			}
-			if (radix_tree_locate_item(&tree, &tree) != -1)
+			if (find_item(&tree, &tree) != -1)
 				abort();
 
 			item_kill_tree(&tree);
 		}
 	}
 
-	if (radix_tree_locate_item(&tree, &tree) != -1)
+	if (find_item(&tree, &tree) != -1)
 		abort();
 	__locate_check(&tree, -1, 0);
-	if (radix_tree_locate_item(&tree, &tree) != -1)
+	if (find_item(&tree, &tree) != -1)
 		abort();
 	item_kill_tree(&tree);
 }
diff --git a/tools/testing/radix-tree/test.c b/tools/testing/radix-tree/test.c
index 0de5489..88bf57f 100644
--- a/tools/testing/radix-tree/test.c
+++ b/tools/testing/radix-tree/test.c
@@ -151,6 +151,28 @@ void item_full_scan(struct radix_tree_root *root, unsigned long start,
 	assert(nfound == 0);
 }
 
+/* Use the same pattern as find_swap_entry() in mm/shmem.c */
+unsigned long find_item(struct radix_tree_root *root, void *item)
+{
+	struct radix_tree_iter iter;
+	void **slot;
+	unsigned long found = -1;
+	unsigned long checked = 0;
+
+	radix_tree_for_each_slot(slot, root, &iter, 0) {
+		if (*slot == item) {
+			found = iter.index;
+			break;
+		}
+		checked++;
+		if ((checked % 4) != 0)
+			continue;
+		slot = radix_tree_iter_resume(slot, &iter);
+	}
+
+	return found;
+}
+
 static int verify_node(struct radix_tree_node *slot, unsigned int tag,
 			int tagged)
 {
diff --git a/tools/testing/radix-tree/test.h b/tools/testing/radix-tree/test.h
index 617416e..3d9d1d3 100644
--- a/tools/testing/radix-tree/test.h
+++ b/tools/testing/radix-tree/test.h
@@ -25,6 +25,8 @@ void item_full_scan(struct radix_tree_root *root, unsigned long start,
 			unsigned long nr, int chunk);
 void item_kill_tree(struct radix_tree_root *root);
 
+unsigned long find_item(struct radix_tree_root *, void *item);
+
 void tag_check(void);
 void multiorder_checks(void);
 void iteration_test(void);
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
