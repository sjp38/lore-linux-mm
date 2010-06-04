Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 16A036B01B0
	for <linux-mm@kvack.org>; Fri,  4 Jun 2010 14:41:22 -0400 (EDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 1/2] radix-tree: Implement function radix_tree_gang_tag_if_tagged
Date: Fri,  4 Jun 2010 20:40:53 +0200
Message-Id: <1275676854-15461-2-git-send-email-jack@suse.cz>
In-Reply-To: <1275676854-15461-1-git-send-email-jack@suse.cz>
References: <1275676854-15461-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
To: linux-fsdevel@kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, npiggin@suse.de, david@fromorbit.com, linux-mm@kvack.org, Jan Kara <jack@suse.cz>
List-ID: <linux-mm.kvack.org>

Implement function for setting one tag if another tag is set
for each item in given range.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 include/linux/radix-tree.h |    3 ++
 lib/radix-tree.c           |   82 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 85 insertions(+), 0 deletions(-)

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index 55ca73c..efdfb07 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -192,6 +192,9 @@ unsigned int
 radix_tree_gang_lookup_tag_slot(struct radix_tree_root *root, void ***results,
 		unsigned long first_index, unsigned int max_items,
 		unsigned int tag);
+unsigned long radix_tree_gang_tag_if_tagged(struct radix_tree_root *root,
+		unsigned long first_index, unsigned long last_index,
+		unsigned int fromtag, unsigned int totag);
 int radix_tree_tagged(struct radix_tree_root *root, unsigned int tag);
 
 static inline void radix_tree_preload_end(void)
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 05da38b..c4595b2 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -609,6 +609,88 @@ int radix_tree_tag_get(struct radix_tree_root *root,
 EXPORT_SYMBOL(radix_tree_tag_get);
 
 /**
+ * radix_tree_gang_tag_if_tagged - for each item in given range set given
+ *				   tag if item has another tag set
+ * @root:		radix tree root
+ * @first_index:	starting index of a range to scan
+ * @last_index:		last index of a range to scan
+ * @iftag: 		tag index to test
+ * @settag:		tag index to set if tested tag is set
+ *
+ * This function scans range of radix tree from first_index to last_index.
+ * For each item in the range if iftag is set, the function sets also
+ * settag.
+ *
+ * The function returns number of leaves where the tag was set.
+ */
+unsigned long radix_tree_gang_tag_if_tagged(struct radix_tree_root *root,
+                unsigned long first_index, unsigned long last_index,
+                unsigned int iftag, unsigned int settag)
+{
+	unsigned int height = root->height, shift;
+	unsigned long tagged = 0, index = first_index;
+	struct radix_tree_node *open_slots[height], *slot;
+
+	last_index = min(last_index, radix_tree_maxindex(height));
+	if (first_index > last_index)
+		return 0;
+	if (!root_tag_get(root, iftag))
+		return 0;
+	if (height == 0) {
+		root_tag_set(root, settag);
+		return 1;
+	}
+
+	shift = (height - 1) * RADIX_TREE_MAP_SHIFT;
+	slot = radix_tree_indirect_to_ptr(root->rnode);
+
+	for (;;) {
+		int offset;
+
+		offset = (index >> shift) & RADIX_TREE_MAP_MASK;
+		if (!slot->slots[offset])
+			goto next;
+		if (!tag_get(slot, iftag, offset))
+			goto next;
+		tag_set(slot, settag, offset);
+		if (height == 1) {
+			tagged++;
+			goto next;
+		}
+		/* Go down one level */
+		height--;
+		shift -= RADIX_TREE_MAP_SHIFT;
+		open_slots[height] = slot;
+		slot = slot->slots[offset];
+		continue;
+next:
+		/* Go to next item at level determined by 'shift' */
+		index = ((index >> shift) + 1) << shift;
+		if (index > last_index)
+			break;
+		while (((index >> shift) & RADIX_TREE_MAP_MASK) == 0) {
+			/*
+			 * We've fully scanned this node. Go up. Because
+			 * last_index is guaranteed to be in the tree, what
+			 * we do below cannot wander astray.
+			 */
+			slot = open_slots[height];
+			height++;
+			shift += RADIX_TREE_MAP_SHIFT;
+		}
+	}
+	/*
+	 * The iftag must have been set somewhere because otherwise
+	 * we would return immediated at the beginning of the function
+	 */
+	root_tag_set(root, settag);
+
+	return tagged;
+}
+EXPORT_SYMBOL(radix_tree_gang_tag_if_tagged);
+
+
+/**
  *	radix_tree_next_hole    -    find the next hole (not-present entry)
  *	@root:		tree root
  *	@index:		index key
-- 
1.6.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
