Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 04DA16B004D
	for <linux-mm@kvack.org>; Sun, 24 May 2009 23:54:08 -0400 (EDT)
Received: by pxi37 with SMTP id 37so3246157pxi.12
        for <linux-mm@kvack.org>; Sun, 24 May 2009 20:54:59 -0700 (PDT)
From: Huang Shijie <shijie8@gmail.com>
Subject: [PATCH] lib : provide a more precise radix_tree_gang_lookup_slot
Date: Mon, 25 May 2009 11:53:55 +0800
Message-Id: <1243223635-3449-1-git-send-email-shijie8@gmail.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Shijie <shijie8@gmail.com>
List-ID: <linux-mm.kvack.org>

	The origin radix_tree_gang_lookup_slot() tries to
lookup max_items slots.But there are maybe holes for
find_get_pages_contig() which will only use the contiguous part.

	So a more precise radix_tree_gang_lookup_slot() is needed
to avoid unneccessary search work.

Signed-off-by: Huang Shijie <shijie8@gmail.com>
---
 include/linux/radix-tree.h |    3 ++-
 lib/radix-tree.c           |   27 +++++++++++++++++++++++----
 mm/filemap.c               |    4 ++--
 3 files changed, 27 insertions(+), 7 deletions(-)

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index 355f6e8..03e25f4 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -164,7 +164,8 @@ radix_tree_gang_lookup(struct radix_tree_root *root, void **results,
 			unsigned long first_index, unsigned int max_items);
 unsigned int
 radix_tree_gang_lookup_slot(struct radix_tree_root *root, void ***results,
-			unsigned long first_index, unsigned int max_items);
+			unsigned long first_index, unsigned int max_items,
+			int contig);
 unsigned long radix_tree_next_hole(struct radix_tree_root *root,
 				unsigned long index, unsigned long max_scan);
 int radix_tree_preload(gfp_t gfp_mask);
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 4bb42a0..f81c21c 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -666,9 +666,13 @@ unsigned long radix_tree_next_hole(struct radix_tree_root *root,
 }
 EXPORT_SYMBOL(radix_tree_next_hole);
 
+/*
+ * contig == 0 : next_index is index for next search
+ * contig == 1 : next_index is MAYBE the index of the first NULL slot
+ */
 static unsigned int
 __lookup(struct radix_tree_node *slot, void ***results, unsigned long index,
-	unsigned int max_items, unsigned long *next_index)
+	unsigned int max_items, unsigned long *next_index, int contig)
 {
 	unsigned int nr_found = 0;
 	unsigned int shift, height;
@@ -684,6 +688,9 @@ __lookup(struct radix_tree_node *slot, void ***results, unsigned long index,
 		for (;;) {
 			if (slot->slots[i] != NULL)
 				break;
+			if (contig)
+				goto out;
+
 			index &= ~((1UL << shift) - 1);
 			index += 1UL << shift;
 			if (index == 0)
@@ -706,6 +713,9 @@ __lookup(struct radix_tree_node *slot, void ***results, unsigned long index,
 			results[nr_found++] = &(slot->slots[i]);
 			if (nr_found == max_items)
 				goto out;
+		} else if (contig) {
+			index--;
+			goto out;
 		}
 	}
 out:
@@ -763,7 +773,7 @@ radix_tree_gang_lookup(struct radix_tree_root *root, void **results,
 		if (cur_index > max_index)
 			break;
 		slots_found = __lookup(node, (void ***)results + ret, cur_index,
-					max_items - ret, &next_index);
+					max_items - ret, &next_index, 0);
 		nr_found = 0;
 		for (i = 0; i < slots_found; i++) {
 			struct radix_tree_node *slot;
@@ -789,6 +799,7 @@ EXPORT_SYMBOL(radix_tree_gang_lookup);
  *	@results:	where the results of the lookup are placed
  *	@first_index:	start the lookup from this key
  *	@max_items:	place up to this many items at *results
+ *	@contig:	if the indexes of slots are required to be contiguous
  *
  *	Performs an index-ascending scan of the tree for present items.  Places
  *	their slots at *@results and returns the number of items which were
@@ -802,7 +813,8 @@ EXPORT_SYMBOL(radix_tree_gang_lookup);
  */
 unsigned int
 radix_tree_gang_lookup_slot(struct radix_tree_root *root, void ***results,
-			unsigned long first_index, unsigned int max_items)
+			unsigned long first_index, unsigned int max_items,
+			int contig)
 {
 	unsigned long max_index;
 	struct radix_tree_node *node;
@@ -831,11 +843,18 @@ radix_tree_gang_lookup_slot(struct radix_tree_root *root, void ***results,
 		if (cur_index > max_index)
 			break;
 		slots_found = __lookup(node, results + ret, cur_index,
-					max_items - ret, &next_index);
+					max_items - ret, &next_index, contig);
 		ret += slots_found;
 		if (next_index == 0)
 			break;
 		cur_index = next_index;
+
+		if (contig) {
+			if (slots_found == 0)
+				break;
+			if (next_index & RADIX_TREE_MAP_MASK)
+				break;
+		}
 	}
 
 	return ret;
diff --git a/mm/filemap.c b/mm/filemap.c
index 379ff0b..ec17645 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -807,7 +807,7 @@ unsigned find_get_pages(struct address_space *mapping, pgoff_t start,
 	rcu_read_lock();
 restart:
 	nr_found = radix_tree_gang_lookup_slot(&mapping->page_tree,
-				(void ***)pages, start, nr_pages);
+				(void ***)pages, start, nr_pages, 0);
 	ret = 0;
 	for (i = 0; i < nr_found; i++) {
 		struct page *page;
@@ -860,7 +860,7 @@ unsigned find_get_pages_contig(struct address_space *mapping, pgoff_t index,
 	rcu_read_lock();
 restart:
 	nr_found = radix_tree_gang_lookup_slot(&mapping->page_tree,
-				(void ***)pages, index, nr_pages);
+				(void ***)pages, index, nr_pages, 1);
 	ret = 0;
 	for (i = 0; i < nr_found; i++) {
 		struct page *page;
-- 
1.6.0.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
