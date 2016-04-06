Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 26B9D828DF
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 17:22:18 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id fe3so40464983pab.1
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 14:22:18 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id n69si6945735pfa.4.2016.04.06.14.21.59
        for <linux-mm@kvack.org>;
        Wed, 06 Apr 2016 14:21:59 -0700 (PDT)
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH 24/30] radix-tree: Rewrite radix_tree_tag_get
Date: Wed,  6 Apr 2016 17:21:33 -0400
Message-Id: <1459977699-2349-25-git-send-email-willy@linux.intel.com>
In-Reply-To: <1459977699-2349-1-git-send-email-willy@linux.intel.com>
References: <1459977699-2349-1-git-send-email-willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Neil Brown <neilb@suse.de>, Matthew Wilcox <willy@linux.intel.com>

From: Ross Zwisler <ross.zwisler@linux.intel.com>

Use the new multi-order support functions to rewrite radix_tree_tag_get()

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 lib/radix-tree.c | 44 ++++++++++++++++++--------------------------
 1 file changed, 18 insertions(+), 26 deletions(-)

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index aca7b2814d26..d894654b5ecc 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -838,45 +838,37 @@ EXPORT_SYMBOL(radix_tree_tag_clear);
 int radix_tree_tag_get(struct radix_tree_root *root,
 			unsigned long index, unsigned int tag)
 {
-	unsigned int height, shift;
-	struct radix_tree_node *node;
+	struct radix_tree_node *node, *parent;
+	unsigned long maxindex;
+	unsigned int shift;
 
-	/* check the root's tag bit */
 	if (!root_tag_get(root, tag))
 		return 0;
 
-	node = rcu_dereference_raw(root->rnode);
+	shift = radix_tree_load_root(root, &node, &maxindex);
+	if (index > maxindex)
+		return 0;
 	if (node == NULL)
 		return 0;
 
-	if (!radix_tree_is_indirect_ptr(node))
-		return (index == 0);
-	node = indirect_to_ptr(node);
-
-	height = node->path & RADIX_TREE_HEIGHT_MASK;
-	if (index > radix_tree_maxindex(height))
-		return 0;
+	while (radix_tree_is_indirect_ptr(node)) {
+		int offset;
 
-	shift = (height - 1) * RADIX_TREE_MAP_SHIFT;
+		shift -= RADIX_TREE_MAP_SHIFT;
+		offset = (index >> shift) & RADIX_TREE_MAP_MASK;
 
-	for ( ; ; ) {
-		int offset;
+		parent = indirect_to_ptr(node);
+		offset = radix_tree_descend(parent, &node, offset);
 
-		if (node == NULL)
+		if (!node)
 			return 0;
-		node = indirect_to_ptr(node);
-
-		offset = (index >> shift) & RADIX_TREE_MAP_MASK;
-		if (!tag_get(node, tag, offset))
+		if (!tag_get(parent, tag, offset))
 			return 0;
-		if (height == 1)
-			return 1;
-		node = rcu_dereference_raw(node->slots[offset]);
-		if (!radix_tree_is_indirect_ptr(node))
-			return 1;
-		shift -= RADIX_TREE_MAP_SHIFT;
-		height--;
+		if (node == RADIX_TREE_RETRY)
+			break;
 	}
+
+	return 1;
 }
 EXPORT_SYMBOL(radix_tree_tag_get);
 
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
