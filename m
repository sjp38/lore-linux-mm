Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id B9A6E828DF
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 10:17:51 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id dx6so49833969pad.0
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 07:17:51 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id 78si7713939pfq.236.2016.04.14.07.17.34
        for <linux-mm@kvack.org>;
        Thu, 14 Apr 2016 07:17:34 -0700 (PDT)
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH v2 22/29] radix-tree: Rewrite radix_tree_tag_clear
Date: Thu, 14 Apr 2016 10:16:43 -0400
Message-Id: <1460643410-30196-23-git-send-email-willy@linux.intel.com>
In-Reply-To: <1460643410-30196-1-git-send-email-willy@linux.intel.com>
References: <1460643410-30196-1-git-send-email-willy@linux.intel.com>
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
index 5234a95..ee56562 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -768,44 +768,40 @@ EXPORT_SYMBOL(radix_tree_tag_set);
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
@@ -813,7 +809,7 @@ void *radix_tree_tag_clear(struct radix_tree_root *root,
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
