Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 7FEBF6B0257
	for <linux-mm@kvack.org>; Tue, 19 Jan 2016 09:25:56 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id yy13so359549088pab.3
        for <linux-mm@kvack.org>; Tue, 19 Jan 2016 06:25:56 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id pg10si3296620pac.16.2016.01.19.06.25.44
        for <linux-mm@kvack.org>;
        Tue, 19 Jan 2016 06:25:45 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH 5/8] radix_tree: Tag all internal tree nodes as indirect pointers
Date: Tue, 19 Jan 2016 09:25:30 -0500
Message-Id: <1453213533-6040-6-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1453213533-6040-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1453213533-6040-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

From: Matthew Wilcox <willy@linux.intel.com>

Set the 'indirect_ptr' bit on all the pointers to internal nodes, not
just on the root node.  This enables the following patches to support
multi-order entries in the radix tree.  This patch is split out for ease
of bisection.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 lib/radix-tree.c                | 24 ++++++++++++++++++------
 tools/testing/radix-tree/test.c |  5 +++--
 2 files changed, 21 insertions(+), 8 deletions(-)

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 7a984ad..422a92a 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -360,9 +360,10 @@ static int radix_tree_extend(struct radix_tree_root *root, unsigned long index)
 		node->count = 1;
 		node->parent = NULL;
 		slot = root->rnode;
-		if (newheight > 1) {
+		if (radix_tree_is_indirect_ptr(slot) && newheight > 1) {
 			slot = indirect_to_ptr(slot);
 			slot->parent = node;
+			slot = ptr_to_indirect(slot);
 		}
 		node->slots[0] = slot;
 		node = ptr_to_indirect(node);
@@ -418,17 +419,20 @@ int __radix_tree_create(struct radix_tree_root *root, unsigned long index,
 			slot->path = height;
 			slot->parent = node;
 			if (node) {
-				rcu_assign_pointer(node->slots[offset], slot);
+				rcu_assign_pointer(node->slots[offset],
+							ptr_to_indirect(slot));
 				node->count++;
 				slot->path |= offset << RADIX_TREE_HEIGHT_SHIFT;
 			} else
-				rcu_assign_pointer(root->rnode, ptr_to_indirect(slot));
+				rcu_assign_pointer(root->rnode,
+							ptr_to_indirect(slot));
 		}
 
 		/* Go a level down */
 		offset = (index >> shift) & RADIX_TREE_MAP_MASK;
 		node = slot;
 		slot = node->slots[offset];
+		slot = indirect_to_ptr(slot);
 		shift -= RADIX_TREE_MAP_SHIFT;
 		height--;
 	}
@@ -526,6 +530,7 @@ void *__radix_tree_lookup(struct radix_tree_root *root, unsigned long index,
 		node = rcu_dereference_raw(*slot);
 		if (node == NULL)
 			return NULL;
+		node = indirect_to_ptr(node);
 
 		shift -= RADIX_TREE_MAP_SHIFT;
 		height--;
@@ -612,6 +617,7 @@ void *radix_tree_tag_set(struct radix_tree_root *root,
 			tag_set(slot, tag, offset);
 		slot = slot->slots[offset];
 		BUG_ON(slot == NULL);
+		slot = indirect_to_ptr(slot);
 		shift -= RADIX_TREE_MAP_SHIFT;
 		height--;
 	}
@@ -651,11 +657,12 @@ void *radix_tree_tag_clear(struct radix_tree_root *root,
 		goto out;
 
 	shift = height * RADIX_TREE_MAP_SHIFT;
-	slot = indirect_to_ptr(root->rnode);
+	slot = root->rnode;
 
 	while (shift) {
 		if (slot == NULL)
 			goto out;
+		slot = indirect_to_ptr(slot);
 
 		shift -= RADIX_TREE_MAP_SHIFT;
 		offset = (index >> shift) & RADIX_TREE_MAP_MASK;
@@ -731,6 +738,7 @@ int radix_tree_tag_get(struct radix_tree_root *root,
 
 		if (node == NULL)
 			return 0;
+		node = indirect_to_ptr(node);
 
 		offset = (index >> shift) & RADIX_TREE_MAP_MASK;
 		if (!tag_get(node, tag, offset))
@@ -831,6 +839,7 @@ restart:
 		node = rcu_dereference_raw(node->slots[offset]);
 		if (node == NULL)
 			goto restart;
+		node = indirect_to_ptr(node);
 		shift -= RADIX_TREE_MAP_SHIFT;
 		offset = (index >> shift) & RADIX_TREE_MAP_MASK;
 	}
@@ -932,6 +941,7 @@ unsigned long radix_tree_range_tag_if_tagged(struct radix_tree_root *root,
 			shift -= RADIX_TREE_MAP_SHIFT;
 			node = slot;
 			slot = slot->slots[offset];
+			slot = indirect_to_ptr(slot);
 			continue;
 		}
 
@@ -1181,6 +1191,7 @@ static unsigned long __locate(struct radix_tree_node *slot, void *item,
 		slot = rcu_dereference_raw(slot->slots[i]);
 		if (slot == NULL)
 			goto out;
+		slot = indirect_to_ptr(slot);
 	}
 
 	/* Bottom level: check items */
@@ -1264,7 +1275,8 @@ static inline void radix_tree_shrink(struct radix_tree_root *root)
 		 */
 		if (to_free->count != 1)
 			break;
-		if (!to_free->slots[0])
+		slot = to_free->slots[0];
+		if (!slot)
 			break;
 
 		/*
@@ -1274,8 +1286,8 @@ static inline void radix_tree_shrink(struct radix_tree_root *root)
 		 * (to_free->slots[0]), it will be safe to dereference the new
 		 * one (root->rnode) as far as dependent read barriers go.
 		 */
-		slot = to_free->slots[0];
 		if (root->height > 1) {
+			slot = indirect_to_ptr(slot);
 			slot->parent = NULL;
 			slot = ptr_to_indirect(slot);
 		}
diff --git a/tools/testing/radix-tree/test.c b/tools/testing/radix-tree/test.c
index c9b0bd7..2bebf34 100644
--- a/tools/testing/radix-tree/test.c
+++ b/tools/testing/radix-tree/test.c
@@ -142,6 +142,8 @@ static int verify_node(struct radix_tree_node *slot, unsigned int tag,
 	int i;
 	int j;
 
+	slot = indirect_to_ptr(slot);
+
 	/* Verify consistency at this level */
 	for (i = 0; i < RADIX_TREE_TAG_LONGS; i++) {
 		if (slot->tags[tag][i]) {
@@ -184,8 +186,7 @@ void verify_tag_consistency(struct radix_tree_root *root, unsigned int tag)
 {
 	if (!root->height)
 		return;
-	verify_node(indirect_to_ptr(root->rnode),
-			tag, root->height, !!root_tag_get(root, tag));
+	verify_node(root->rnode, tag, root->height, !!root_tag_get(root, tag));
 }
 
 void item_kill_tree(struct radix_tree_root *root)
-- 
2.7.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
