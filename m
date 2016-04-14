Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4FC036B0281
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 10:37:37 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id t124so132125347pfb.1
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 07:37:37 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id ui4si2771828pab.203.2016.04.14.07.37.29
        for <linux-mm@kvack.org>;
        Thu, 14 Apr 2016 07:37:29 -0700 (PDT)
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH 09/19] radix-tree: Rename ptr_to_indirect() to node_to_entry()
Date: Thu, 14 Apr 2016 10:37:12 -0400
Message-Id: <1460644642-30642-10-git-send-email-willy@linux.intel.com>
In-Reply-To: <1460644642-30642-1-git-send-email-willy@linux.intel.com>
References: <1460644642-30642-1-git-send-email-willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Neil Brown <neilb@suse.de>, Ross Zwisler <ross.zwisler@linux.intel.com>

ptr_to_indirect() was a bad name.  What it really means is "Convert this
pointer to a node into an entry suitable for storing in the radix tree".
So node_to_entry() seemed like a better name.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 lib/radix-tree.c | 21 ++++++++++-----------
 1 file changed, 10 insertions(+), 11 deletions(-)

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 1fe546c..f7a0cf7 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -66,12 +66,12 @@ struct radix_tree_preload {
 };
 static DEFINE_PER_CPU(struct radix_tree_preload, radix_tree_preloads) = { 0, };
 
-static inline void *ptr_to_indirect(void *ptr)
+static inline void *node_to_entry(void *ptr)
 {
 	return (void *)((unsigned long)ptr | RADIX_TREE_INTERNAL_NODE);
 }
 
-#define RADIX_TREE_RETRY	ptr_to_indirect(NULL)
+#define RADIX_TREE_RETRY	node_to_entry(NULL)
 
 #ifdef CONFIG_RADIX_TREE_MULTIORDER
 /* Sibling slots point directly to another slot in the same node */
@@ -470,13 +470,12 @@ static int radix_tree_extend(struct radix_tree_root *root,
 		if (radix_tree_is_indirect_ptr(slot)) {
 			slot = indirect_to_ptr(slot);
 			slot->parent = node;
-			slot = ptr_to_indirect(slot);
+			slot = node_to_entry(slot);
 		}
 		node->slots[0] = slot;
-		node = ptr_to_indirect(node);
-		rcu_assign_pointer(root->rnode, node);
+		slot = node_to_entry(node);
+		rcu_assign_pointer(root->rnode, slot);
 		shift += RADIX_TREE_MAP_SHIFT;
-		slot = node;
 	} while (shift <= maxshift);
 out:
 	return maxshift + RADIX_TREE_MAP_SHIFT;
@@ -534,11 +533,11 @@ int __radix_tree_create(struct radix_tree_root *root, unsigned long index,
 			slot->parent = node;
 			if (node) {
 				rcu_assign_pointer(node->slots[offset],
-							ptr_to_indirect(slot));
+							node_to_entry(slot));
 				node->count++;
 			} else
 				rcu_assign_pointer(root->rnode,
-							ptr_to_indirect(slot));
+							node_to_entry(slot));
 		} else if (!radix_tree_is_indirect_ptr(slot))
 			break;
 
@@ -553,7 +552,7 @@ int __radix_tree_create(struct radix_tree_root *root, unsigned long index,
 	if (order > shift) {
 		int i, n = 1 << (order - shift);
 		offset = offset & ~(n - 1);
-		slot = ptr_to_indirect(&node->slots[offset]);
+		slot = node_to_entry(&node->slots[offset]);
 		for (i = 0; i < n; i++) {
 			if (node->slots[offset + i])
 				return -EEXIST;
@@ -1423,7 +1422,7 @@ static inline bool radix_tree_shrink(struct radix_tree_root *root)
 		if (radix_tree_is_indirect_ptr(slot)) {
 			slot = indirect_to_ptr(slot);
 			slot->parent = NULL;
-			slot = ptr_to_indirect(slot);
+			slot = node_to_entry(slot);
 		}
 
 		/*
@@ -1564,7 +1563,7 @@ void *radix_tree_delete_item(struct radix_tree_root *root,
 			radix_tree_tag_clear(root, index, tag);
 	}
 
-	delete_sibling_entries(node, ptr_to_indirect(slot), offset);
+	delete_sibling_entries(node, node_to_entry(slot), offset);
 	node->slots[offset] = NULL;
 	node->count--;
 
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
