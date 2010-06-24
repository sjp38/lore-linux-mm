Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1CF2E6B01AD
	for <linux-mm@kvack.org>; Thu, 24 Jun 2010 09:58:31 -0400 (EDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 1/2] radix-tree: Implement function radix_tree_range_tag_if_tagged
Date: Thu, 24 Jun 2010 15:57:46 +0200
Message-Id: <1277387867-5525-2-git-send-email-jack@suse.cz>
In-Reply-To: <1277387867-5525-1-git-send-email-jack@suse.cz>
References: <1277387867-5525-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: inux-fsdevel@vger.kernel.org, linux-mm@kvack.org, npiggin@suse.de, david@fromorbit.com, Jan Kara <jack@suse.cz>
List-ID: <linux-mm.kvack.org>

Implement function for setting one tag if another tag is set
for each item in given range.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 include/linux/radix-tree.h |    4 ++
 lib/radix-tree.c           |   94 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 98 insertions(+), 0 deletions(-)

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index 55ca73c..a4b00e9 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -192,6 +192,10 @@ unsigned int
 radix_tree_gang_lookup_tag_slot(struct radix_tree_root *root, void ***results,
 		unsigned long first_index, unsigned int max_items,
 		unsigned int tag);
+unsigned long radix_tree_range_tag_if_tagged(struct radix_tree_root *root,
+		unsigned long *first_indexp, unsigned long last_index,
+		unsigned long nr_to_tag,
+		unsigned int fromtag, unsigned int totag);
 int radix_tree_tagged(struct radix_tree_root *root, unsigned int tag);
 
 static inline void radix_tree_preload_end(void)
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 05da38b..e907858 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -609,6 +609,100 @@ int radix_tree_tag_get(struct radix_tree_root *root,
 EXPORT_SYMBOL(radix_tree_tag_get);
 
 /**
+ * radix_tree_range_tag_if_tagged - for each item in given range set given
+ *				   tag if item has another tag set
+ * @root:		radix tree root
+ * @first_indexp:	pointer to a starting index of a range to scan
+ * @last_index:		last index of a range to scan
+ * @nr_to_tag:		maximum number items to tag
+ * @iftag:		tag index to test
+ * @settag:		tag index to set if tested tag is set
+ *
+ * This function scans range of radix tree from first_index to last_index
+ * (inclusive).  For each item in the range if iftag is set, the function sets
+ * also settag. The function stops either after tagging nr_to_tag items or
+ * after reaching last_index.
+ *
+ * The function returns number of leaves where the tag was set and sets
+ * *first_indexp to the first unscanned index.
+ */
+unsigned long radix_tree_range_tag_if_tagged(struct radix_tree_root *root,
+		unsigned long *first_indexp, unsigned long last_index,
+		unsigned long nr_to_tag,
+		unsigned int iftag, unsigned int settag)
+{
+	unsigned int height = root->height, shift;
+	unsigned long tagged = 0, index = *first_indexp;
+	struct radix_tree_node *open_slots[height], *slot;
+
+	last_index = min(last_index, radix_tree_maxindex(height));
+	if (index > last_index)
+		return 0;
+	if (!nr_to_tag)
+		return 0;
+	if (!root_tag_get(root, iftag)) {
+		*first_indexp = last_index + 1;
+		return 0;
+	}
+	if (height == 0) {
+		*first_indexp = last_index + 1;
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
+		if (tagged >= nr_to_tag)
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
+	*first_indexp = index;
+
+	return tagged;
+}
+EXPORT_SYMBOL(radix_tree_range_tag_if_tagged);
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
