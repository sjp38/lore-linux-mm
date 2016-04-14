Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id AE0738295A
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 10:38:08 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id t124so132147542pfb.1
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 07:38:08 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id e65si7776846pfd.212.2016.04.14.07.38.04
        for <linux-mm@kvack.org>;
        Thu, 14 Apr 2016 07:38:04 -0700 (PDT)
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH 14/19] radix-tree: Tidy up range_tag_if_tagged
Date: Thu, 14 Apr 2016 10:37:17 -0400
Message-Id: <1460644642-30642-15-git-send-email-willy@linux.intel.com>
In-Reply-To: <1460644642-30642-1-git-send-email-willy@linux.intel.com>
References: <1460644642-30642-1-git-send-email-willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Neil Brown <neilb@suse.de>, Ross Zwisler <ross.zwisler@linux.intel.com>

Convert radix_tree_range_tag_if_tagged to name the nodes parent, node and
child instead of node & slot.

Use parent->offset instead of playing games with 'upindex'.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 lib/radix-tree.c | 39 +++++++++++++++++----------------------
 1 file changed, 17 insertions(+), 22 deletions(-)

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index fab4485..412dc35 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -1009,9 +1009,9 @@ unsigned long radix_tree_range_tag_if_tagged(struct radix_tree_root *root,
 		unsigned long nr_to_tag,
 		unsigned int iftag, unsigned int settag)
 {
-	struct radix_tree_node *slot, *node = NULL;
+	struct radix_tree_node *parent, *node, *child;
 	unsigned long maxindex;
-	unsigned int shift = radix_tree_load_root(root, &slot, &maxindex);
+	unsigned int shift = radix_tree_load_root(root, &child, &maxindex);
 	unsigned long tagged = 0;
 	unsigned long index = *first_indexp;
 
@@ -1024,28 +1024,25 @@ unsigned long radix_tree_range_tag_if_tagged(struct radix_tree_root *root,
 		*first_indexp = last_index + 1;
 		return 0;
 	}
-	if (!radix_tree_is_internal_node(slot)) {
+	if (!radix_tree_is_internal_node(child)) {
 		*first_indexp = last_index + 1;
 		root_tag_set(root, settag);
 		return 1;
 	}
 
-	node = entry_to_node(slot);
+	node = entry_to_node(child);
 	shift -= RADIX_TREE_MAP_SHIFT;
 
 	for (;;) {
-		unsigned long upindex;
-		unsigned offset;
-
-		offset = (index >> shift) & RADIX_TREE_MAP_MASK;
-		offset = radix_tree_descend(node, &slot, offset);
-		if (!slot)
+		unsigned offset = (index >> shift) & RADIX_TREE_MAP_MASK;
+		offset = radix_tree_descend(node, &child, offset);
+		if (!child)
 			goto next;
 		if (!tag_get(node, iftag, offset))
 			goto next;
 		/* Sibling slots never have tags set on them */
-		if (radix_tree_is_internal_node(slot)) {
-			node = entry_to_node(slot);
+		if (radix_tree_is_internal_node(child)) {
+			node = entry_to_node(child);
 			shift -= RADIX_TREE_MAP_SHIFT;
 			continue;
 		}
@@ -1054,20 +1051,18 @@ unsigned long radix_tree_range_tag_if_tagged(struct radix_tree_root *root,
 		tagged++;
 		tag_set(node, settag, offset);
 
-		slot = node->parent;
 		/* walk back up the path tagging interior nodes */
-		upindex = index >> shift;
-		while (slot) {
-			upindex >>= RADIX_TREE_MAP_SHIFT;
-			offset = upindex & RADIX_TREE_MAP_MASK;
-
+		parent = node;
+		for (;;) {
+			offset = parent->offset;
+			parent = parent->parent;
+			if (!parent)
+				break;
 			/* stop if we find a node with the tag already set */
-			if (tag_get(slot, settag, offset))
+			if (tag_get(parent, settag, offset))
 				break;
-			tag_set(slot, settag, offset);
-			slot = slot->parent;
+			tag_set(parent, settag, offset);
 		}
-
  next:
 		/* Go to next item at level determined by 'shift' */
 		index = ((index >> shift) + 1) << shift;
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
