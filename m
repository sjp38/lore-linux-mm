Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9DBB48295A
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 10:38:04 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id dx6so50542964pad.0
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 07:38:04 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id e65si7776846pfd.212.2016.04.14.07.38.01
        for <linux-mm@kvack.org>;
        Thu, 14 Apr 2016 07:38:01 -0700 (PDT)
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH 04/19] radix-tree: Replace node->height with node->shift
Date: Thu, 14 Apr 2016 10:37:07 -0400
Message-Id: <1460644642-30642-5-git-send-email-willy@linux.intel.com>
In-Reply-To: <1460644642-30642-1-git-send-email-willy@linux.intel.com>
References: <1460644642-30642-1-git-send-email-willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Neil Brown <neilb@suse.de>, Ross Zwisler <ross.zwisler@linux.intel.com>

node->shift represents the shift necessary for looking in the slots
array at this level.  It is equal to the old
(node->height - 1) * RADIX_TREE_MAP_SHIFT.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 include/linux/radix-tree.h |  2 +-
 lib/radix-tree.c           | 30 ++++++++++++++++--------------
 2 files changed, 17 insertions(+), 15 deletions(-)

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index 2d2ad9d..0374582 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -89,7 +89,7 @@ static inline int radix_tree_is_indirect_ptr(void *ptr)
 #define RADIX_TREE_COUNT_MASK	((1UL << RADIX_TREE_COUNT_SHIFT) - 1)
 
 struct radix_tree_node {
-	unsigned char	height;	/* From the bottom */
+	unsigned char	shift;	/* Bits remaining in each slot */
 	unsigned char	offset;	/* Slot offset in parent */
 	unsigned int	count;
 	union {
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index d42c5b5..e963823 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -223,10 +223,10 @@ static void dump_node(struct radix_tree_node *node,
 {
 	unsigned long i;
 
-	pr_debug("radix node: %p offset %d tags %lx %lx %lx height %d count %d parent %p\n",
+	pr_debug("radix node: %p offset %d tags %lx %lx %lx shift %d count %d parent %p\n",
 		node, node->offset,
 		node->tags[0][0], node->tags[1][0], node->tags[2][0],
-		node->height, node->count, node->parent);
+		node->shift, node->count, node->parent);
 
 	for (i = 0; i < RADIX_TREE_MAP_SIZE; i++) {
 		unsigned long first = index | (i << shift);
@@ -419,9 +419,14 @@ static inline unsigned long radix_tree_maxindex(unsigned int height)
 	return height_to_maxindex[height];
 }
 
+static inline unsigned long shift_maxindex(unsigned int shift)
+{
+	return (RADIX_TREE_MAP_SIZE << shift) - 1;
+}
+
 static inline unsigned long node_maxindex(struct radix_tree_node *node)
 {
-	return radix_tree_maxindex(node->height);
+	return shift_maxindex(node->shift);
 }
 
 static unsigned radix_tree_load_root(struct radix_tree_root *root,
@@ -434,7 +439,7 @@ static unsigned radix_tree_load_root(struct radix_tree_root *root,
 	if (likely(radix_tree_is_indirect_ptr(node))) {
 		node = indirect_to_ptr(node);
 		*maxindex = node_maxindex(node);
-		return node->height * RADIX_TREE_MAP_SHIFT;
+		return node->shift + RADIX_TREE_MAP_SHIFT;
 	}
 
 	*maxindex = 0;
@@ -475,9 +480,9 @@ static int radix_tree_extend(struct radix_tree_root *root,
 		}
 
 		/* Increase the height.  */
-		newheight = root->height + 1;
+		newheight = root->height;
 		BUG_ON(newheight > BITS_PER_LONG);
-		node->height = newheight;
+		node->shift = newheight * RADIX_TREE_MAP_SHIFT;
 		node->offset = 0;
 		node->count = 1;
 		node->parent = NULL;
@@ -490,7 +495,7 @@ static int radix_tree_extend(struct radix_tree_root *root,
 		node->slots[0] = slot;
 		node = ptr_to_indirect(node);
 		rcu_assign_pointer(root->rnode, node);
-		root->height = newheight;
+		root->height = ++newheight;
 	} while (height > root->height);
 out:
 	return height * RADIX_TREE_MAP_SHIFT;
@@ -519,7 +524,7 @@ int __radix_tree_create(struct radix_tree_root *root, unsigned long index,
 {
 	struct radix_tree_node *node = NULL, *slot;
 	unsigned long maxindex;
-	unsigned int height, shift, offset;
+	unsigned int shift, offset;
 	unsigned long max = index | ((1UL << order) - 1);
 
 	shift = radix_tree_load_root(root, &slot, &maxindex);
@@ -537,16 +542,15 @@ int __radix_tree_create(struct radix_tree_root *root, unsigned long index,
 		}
 	}
 
-	height = root->height;
-
 	offset = 0;			/* uninitialised var warning */
 	while (shift > order) {
+		shift -= RADIX_TREE_MAP_SHIFT;
 		if (slot == NULL) {
 			/* Have to add a child node.  */
 			slot = radix_tree_node_alloc(root);
 			if (!slot)
 				return -ENOMEM;
-			slot->height = height;
+			slot->shift = shift;
 			slot->offset = offset;
 			slot->parent = node;
 			if (node) {
@@ -560,8 +564,6 @@ int __radix_tree_create(struct radix_tree_root *root, unsigned long index,
 			break;
 
 		/* Go a level down */
-		height--;
-		shift -= RADIX_TREE_MAP_SHIFT;
 		node = indirect_to_ptr(slot);
 		offset = (index >> shift) & RADIX_TREE_MAP_MASK;
 		offset = radix_tree_descend(node, &slot, offset);
@@ -1322,7 +1324,7 @@ static unsigned long __locate(struct radix_tree_node *slot, void *item,
 	unsigned int shift;
 	unsigned long base, i;
 
-	shift = slot->height * RADIX_TREE_MAP_SHIFT;
+	shift = slot->shift + RADIX_TREE_MAP_SHIFT;
 
 	do {
 		shift -= RADIX_TREE_MAP_SHIFT;
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
