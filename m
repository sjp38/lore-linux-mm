Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 617AD6B026B
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 17:28:49 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id zm5so40606691pac.0
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 14:28:49 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id r86si6878769pfb.219.2016.04.06.14.21.54
        for <linux-mm@kvack.org>;
        Wed, 06 Apr 2016 14:21:54 -0700 (PDT)
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH 23/30] radix-tree: Rewrite radix_tree_tag_clear
Date: Wed,  6 Apr 2016 17:21:32 -0400
Message-Id: <1459977699-2349-24-git-send-email-willy@linux.intel.com>
In-Reply-To: <1459977699-2349-1-git-send-email-willy@linux.intel.com>
References: <1459977699-2349-1-git-send-email-willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Neil Brown <neilb@suse.de>, Matthew Wilcox <willy@linux.intel.com>

From: Ross Zwisler <ross.zwisler@linux.intel.com>

Use the new multi-order support functions to rewrite
radix_tree_tag_clear()

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 lib/radix-tree.c | 44 ++++++++++++++++++++------------------------
 1 file changed, 20 insertions(+), 24 deletions(-)

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 6d9b328705a1..aca7b2814d26 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -775,44 +775,40 @@ EXPORT_SYMBOL(radix_tree_tag_set);
 void *radix_tree_tag_clear(struct radix_tree_root *root,
 			unsigned long index, unsigned int tag)
 {
-	struct radix_tree_node *node = NULL;
-	struct radix_tree_node *slot = NULL;
-	unsigned int height, shift;
+	struct radix_tree_node *node, *parent;
+	unsigned long maxindex;
+	unsigned int shift;
 	int uninitialized_var(offset);
 
-	height = root->height;
-	if (index > radix_tree_maxindex(height))
-		goto out;
-
-	shift = height * RADIX_TREE_MAP_SHIFT;
-	slot = root->rnode;
+	shift = radix_tree_load_root(root, &node, &maxindex);
+	if (index > maxindex)
+		return NULL;
 
-	while (shift) {
-		if (slot == NULL)
-			goto out;
-		if (!radix_tree_is_indirect_ptr(slot))
-			break;
-		slot = indirect_to_ptr(slot);
+	parent = NULL;
 
+	while (radix_tree_is_indirect_ptr(node)) {
 		shift -= RADIX_TREE_MAP_SHIFT;
 		offset = (index >> shift) & RADIX_TREE_MAP_MASK;
-		node = slot;
-		slot = slot->slots[offset];
+
+		parent = indirect_to_ptr(node);
+		offset = radix_tree_descend(parent, &node, offset);
 	}
 
-	if (slot == NULL)
+	if (node == NULL)
 		goto out;
 
-	while (node) {
-		if (!tag_get(node, tag, offset))
+	index >>= shift;
+
+	while (parent) {
+		if (!tag_get(parent, tag, offset))
 			goto out;
-		tag_clear(node, tag, offset);
-		if (any_tag_set(node, tag))
+		tag_clear(parent, tag, offset);
+		if (any_tag_set(parent, tag))
 			goto out;
 
 		index >>= RADIX_TREE_MAP_SHIFT;
 		offset = index & RADIX_TREE_MAP_MASK;
-		node = node->parent;
+		parent = parent->parent;
 	}
 
 	/* clear the root's tag bit */
@@ -820,7 +816,7 @@ void *radix_tree_tag_clear(struct radix_tree_root *root,
 		root_tag_clear(root, tag);
 
 out:
-	return slot;
+	return node;
 }
 EXPORT_SYMBOL(radix_tree_tag_clear);
 
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
