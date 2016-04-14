Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id E05F86B0270
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 10:19:21 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id u190so131387602pfb.0
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 07:19:21 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id wi6si7952603pab.119.2016.04.14.07.19.20
        for <linux-mm@kvack.org>;
        Thu, 14 Apr 2016 07:19:20 -0700 (PDT)
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH v2 21/29] radix-tree: Rewrite radix_tree_tag_set
Date: Thu, 14 Apr 2016 10:16:42 -0400
Message-Id: <1460643410-30196-22-git-send-email-willy@linux.intel.com>
In-Reply-To: <1460643410-30196-1-git-send-email-willy@linux.intel.com>
References: <1460643410-30196-1-git-send-email-willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Neil Brown <neilb@suse.de>, Matthew Wilcox <willy@linux.intel.com>

From: Ross Zwisler <ross.zwisler@linux.intel.com>

Use the new multi-order support functions to rewrite radix_tree_tag_set()

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 lib/radix-tree.c | 37 +++++++++++++++++--------------------
 1 file changed, 17 insertions(+), 20 deletions(-)

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index a4da86e..5234a95 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -722,35 +722,32 @@ EXPORT_SYMBOL(radix_tree_lookup);
 void *radix_tree_tag_set(struct radix_tree_root *root,
 			unsigned long index, unsigned int tag)
 {
-	unsigned int height, shift;
-	struct radix_tree_node *slot;
-
-	height = root->height;
-	BUG_ON(index > radix_tree_maxindex(height));
+	struct radix_tree_node *node, *parent;
+	unsigned long maxindex;
+	unsigned int shift;
 
-	slot = indirect_to_ptr(root->rnode);
-	shift = (height - 1) * RADIX_TREE_MAP_SHIFT;
+	shift = radix_tree_load_root(root, &node, &maxindex);
+	BUG_ON(index > maxindex);
 
-	while (height > 0) {
-		int offset;
+	while (radix_tree_is_indirect_ptr(node)) {
+		unsigned offset;
 
-		offset = (index >> shift) & RADIX_TREE_MAP_MASK;
-		if (!tag_get(slot, tag, offset))
-			tag_set(slot, tag, offset);
-		slot = slot->slots[offset];
-		BUG_ON(slot == NULL);
-		if (!radix_tree_is_indirect_ptr(slot))
-			break;
-		slot = indirect_to_ptr(slot);
 		shift -= RADIX_TREE_MAP_SHIFT;
-		height--;
+		offset = (index >> shift) & RADIX_TREE_MAP_MASK;
+
+		parent = indirect_to_ptr(node);
+		offset = radix_tree_descend(parent, &node, offset);
+		BUG_ON(!node);
+
+		if (!tag_get(parent, tag, offset))
+			tag_set(parent, tag, offset);
 	}
 
 	/* set the root's tag bit */
-	if (slot && !root_tag_get(root, tag))
+	if (!root_tag_get(root, tag))
 		root_tag_set(root, tag);
 
-	return slot;
+	return node;
 }
 EXPORT_SYMBOL(radix_tree_tag_set);
 
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
