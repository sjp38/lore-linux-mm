Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id C03C78295A
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 10:38:10 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id u190so132308920pfb.0
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 07:38:10 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id e65si7776846pfd.212.2016.04.14.07.38.05
        for <linux-mm@kvack.org>;
        Thu, 14 Apr 2016 07:38:05 -0700 (PDT)
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH 15/19] radix-tree: Tidy up __radix_tree_create()
Date: Thu, 14 Apr 2016 10:37:18 -0400
Message-Id: <1460644642-30642-16-git-send-email-willy@linux.intel.com>
In-Reply-To: <1460644642-30642-1-git-send-email-willy@linux.intel.com>
References: <1460644642-30642-1-git-send-email-willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Neil Brown <neilb@suse.de>, Ross Zwisler <ross.zwisler@linux.intel.com>

1. Rename the existing variable 'slot' to 'child'.
2. Introduce a new variable called 'slot' which is the address of the
   slot we're dealing with.  This lets us simplify the tree insertion,
   and removes the recalculation of 'slot' at the end of the function.
3. Using 'slot' in the sibling pointer insertion part makes the code
   more readable.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 lib/radix-tree.c | 48 +++++++++++++++++++++++-------------------------
 1 file changed, 23 insertions(+), 25 deletions(-)

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 412dc35..9a57b70 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -499,12 +499,13 @@ int __radix_tree_create(struct radix_tree_root *root, unsigned long index,
 			unsigned order, struct radix_tree_node **nodep,
 			void ***slotp)
 {
-	struct radix_tree_node *node = NULL, *slot;
+	struct radix_tree_node *node = NULL, *child;
+	void **slot = (void **)&root->rnode;
 	unsigned long maxindex;
-	unsigned int shift, offset;
+	unsigned int shift, offset = 0;
 	unsigned long max = index | ((1UL << order) - 1);
 
-	shift = radix_tree_load_root(root, &slot, &maxindex);
+	shift = radix_tree_load_root(root, &child, &maxindex);
 
 	/* Make sure the tree is high enough.  */
 	if (max > maxindex) {
@@ -512,51 +513,48 @@ int __radix_tree_create(struct radix_tree_root *root, unsigned long index,
 		if (error < 0)
 			return error;
 		shift = error;
-		slot = root->rnode;
+		child = root->rnode;
 		if (order == shift)
 			shift += RADIX_TREE_MAP_SHIFT;
 	}
 
-	offset = 0;			/* uninitialised var warning */
 	while (shift > order) {
 		shift -= RADIX_TREE_MAP_SHIFT;
-		if (slot == NULL) {
+		if (child == NULL) {
 			/* Have to add a child node.  */
-			slot = radix_tree_node_alloc(root);
-			if (!slot)
+			child = radix_tree_node_alloc(root);
+			if (!child)
 				return -ENOMEM;
-			slot->shift = shift;
-			slot->offset = offset;
-			slot->parent = node;
-			if (node) {
-				rcu_assign_pointer(node->slots[offset],
-							node_to_entry(slot));
+			child->shift = shift;
+			child->offset = offset;
+			child->parent = node;
+			rcu_assign_pointer(*slot, node_to_entry(child));
+			if (node)
 				node->count++;
-			} else
-				rcu_assign_pointer(root->rnode,
-							node_to_entry(slot));
-		} else if (!radix_tree_is_internal_node(slot))
+		} else if (!radix_tree_is_internal_node(child))
 			break;
 
 		/* Go a level down */
-		node = entry_to_node(slot);
+		node = entry_to_node(child);
 		offset = (index >> shift) & RADIX_TREE_MAP_MASK;
-		offset = radix_tree_descend(node, &slot, offset);
+		offset = radix_tree_descend(node, &child, offset);
+		slot = &node->slots[offset];
 	}
 
 #ifdef CONFIG_RADIX_TREE_MULTIORDER
 	/* Insert pointers to the canonical entry */
 	if (order > shift) {
-		int i, n = 1 << (order - shift);
+		unsigned i, n = 1 << (order - shift);
 		offset = offset & ~(n - 1);
-		slot = node_to_entry(&node->slots[offset]);
+		slot = &node->slots[offset];
+		child = node_to_entry(slot);
 		for (i = 0; i < n; i++) {
-			if (node->slots[offset + i])
+			if (slot[i])
 				return -EEXIST;
 		}
 
 		for (i = 1; i < n; i++) {
-			rcu_assign_pointer(node->slots[offset + i], slot);
+			rcu_assign_pointer(slot[i], child);
 			node->count++;
 		}
 	}
@@ -565,7 +563,7 @@ int __radix_tree_create(struct radix_tree_root *root, unsigned long index,
 	if (nodep)
 		*nodep = node;
 	if (slotp)
-		*slotp = node ? node->slots + offset : (void **)&root->rnode;
+		*slotp = slot;
 	return 0;
 }
 
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
