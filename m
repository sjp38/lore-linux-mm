Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5666E6B027F
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 10:37:31 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id t124so132120561pfb.1
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 07:37:31 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id 77si11496472pfq.237.2016.04.14.07.37.28
        for <linux-mm@kvack.org>;
        Thu, 14 Apr 2016 07:37:28 -0700 (PDT)
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH 03/19] radix-tree: Split node->path into offset and height
Date: Thu, 14 Apr 2016 10:37:06 -0400
Message-Id: <1460644642-30642-4-git-send-email-willy@linux.intel.com>
In-Reply-To: <1460644642-30642-1-git-send-email-willy@linux.intel.com>
References: <1460644642-30642-1-git-send-email-willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Neil Brown <neilb@suse.de>, Ross Zwisler <ross.zwisler@linux.intel.com>

Neither piece of information we're storing in node->path can be larger
than 64, so store each in its own unsigned char instead of shifting
and masking to store them both in an unsigned int.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 include/linux/radix-tree.h |  7 ++-----
 lib/radix-tree.c           | 38 +++++++++++++++++---------------------
 2 files changed, 19 insertions(+), 26 deletions(-)

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index 8558d52..2d2ad9d 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -84,16 +84,13 @@ static inline int radix_tree_is_indirect_ptr(void *ptr)
 #define RADIX_TREE_MAX_PATH (DIV_ROUND_UP(RADIX_TREE_INDEX_BITS, \
 					  RADIX_TREE_MAP_SHIFT))
 
-/* Height component in node->path */
-#define RADIX_TREE_HEIGHT_SHIFT	(RADIX_TREE_MAX_PATH + 1)
-#define RADIX_TREE_HEIGHT_MASK	((1UL << RADIX_TREE_HEIGHT_SHIFT) - 1)
-
 /* Internally used bits of node->count */
 #define RADIX_TREE_COUNT_SHIFT	(RADIX_TREE_MAP_SHIFT + 1)
 #define RADIX_TREE_COUNT_MASK	((1UL << RADIX_TREE_COUNT_SHIFT) - 1)
 
 struct radix_tree_node {
-	unsigned int	path;	/* Offset in parent & height from the bottom */
+	unsigned char	height;	/* From the bottom */
+	unsigned char	offset;	/* Slot offset in parent */
 	unsigned int	count;
 	union {
 		struct {
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 746a240..d42c5b5 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -218,15 +218,15 @@ radix_tree_find_next_bit(const unsigned long *addr,
 }
 
 #ifndef __KERNEL__
-static void dump_node(struct radix_tree_node *node, unsigned offset,
+static void dump_node(struct radix_tree_node *node,
 				unsigned shift, unsigned long index)
 {
 	unsigned long i;
 
-	pr_debug("radix node: %p offset %d tags %lx %lx %lx path %x count %d parent %p\n",
-		node, offset,
+	pr_debug("radix node: %p offset %d tags %lx %lx %lx height %d count %d parent %p\n",
+		node, node->offset,
 		node->tags[0][0], node->tags[1][0], node->tags[2][0],
-		node->path, node->count, node->parent);
+		node->height, node->count, node->parent);
 
 	for (i = 0; i < RADIX_TREE_MAP_SIZE; i++) {
 		unsigned long first = index | (i << shift);
@@ -243,7 +243,7 @@ static void dump_node(struct radix_tree_node *node, unsigned offset,
 			pr_debug("radix entry %p offset %ld indices %ld-%ld\n",
 					entry, i, first, last);
 		} else {
-			dump_node(indirect_to_ptr(entry), i,
+			dump_node(indirect_to_ptr(entry),
 					shift - RADIX_TREE_MAP_SHIFT, first);
 		}
 	}
@@ -257,7 +257,7 @@ static void radix_tree_dump(struct radix_tree_root *root)
 			root->gfp_mask >> __GFP_BITS_SHIFT);
 	if (!radix_tree_is_indirect_ptr(root->rnode))
 		return;
-	dump_node(indirect_to_ptr(root->rnode), 0,
+	dump_node(indirect_to_ptr(root->rnode),
 				(root->height - 1) * RADIX_TREE_MAP_SHIFT, 0);
 }
 #endif
@@ -421,7 +421,7 @@ static inline unsigned long radix_tree_maxindex(unsigned int height)
 
 static inline unsigned long node_maxindex(struct radix_tree_node *node)
 {
-	return radix_tree_maxindex(node->path & RADIX_TREE_HEIGHT_MASK);
+	return radix_tree_maxindex(node->height);
 }
 
 static unsigned radix_tree_load_root(struct radix_tree_root *root,
@@ -434,8 +434,7 @@ static unsigned radix_tree_load_root(struct radix_tree_root *root,
 	if (likely(radix_tree_is_indirect_ptr(node))) {
 		node = indirect_to_ptr(node);
 		*maxindex = node_maxindex(node);
-		return (node->path & RADIX_TREE_HEIGHT_MASK) *
-			RADIX_TREE_MAP_SHIFT;
+		return node->height * RADIX_TREE_MAP_SHIFT;
 	}
 
 	*maxindex = 0;
@@ -476,9 +475,10 @@ static int radix_tree_extend(struct radix_tree_root *root,
 		}
 
 		/* Increase the height.  */
-		newheight = root->height+1;
-		BUG_ON(newheight & ~RADIX_TREE_HEIGHT_MASK);
-		node->path = newheight;
+		newheight = root->height + 1;
+		BUG_ON(newheight > BITS_PER_LONG);
+		node->height = newheight;
+		node->offset = 0;
 		node->count = 1;
 		node->parent = NULL;
 		slot = root->rnode;
@@ -546,13 +546,13 @@ int __radix_tree_create(struct radix_tree_root *root, unsigned long index,
 			slot = radix_tree_node_alloc(root);
 			if (!slot)
 				return -ENOMEM;
-			slot->path = height;
+			slot->height = height;
+			slot->offset = offset;
 			slot->parent = node;
 			if (node) {
 				rcu_assign_pointer(node->slots[offset],
 							ptr_to_indirect(slot));
 				node->count++;
-				slot->path |= offset << RADIX_TREE_HEIGHT_SHIFT;
 			} else
 				rcu_assign_pointer(root->rnode,
 							ptr_to_indirect(slot));
@@ -1319,11 +1319,10 @@ struct locate_info {
 static unsigned long __locate(struct radix_tree_node *slot, void *item,
 			      unsigned long index, struct locate_info *info)
 {
-	unsigned int shift, height;
+	unsigned int shift;
 	unsigned long base, i;
 
-	height = slot->path & RADIX_TREE_HEIGHT_MASK;
-	shift = height * RADIX_TREE_MAP_SHIFT;
+	shift = slot->height * RADIX_TREE_MAP_SHIFT;
 
 	do {
 		shift -= RADIX_TREE_MAP_SHIFT;
@@ -1509,10 +1508,7 @@ bool __radix_tree_delete_node(struct radix_tree_root *root,
 
 		parent = node->parent;
 		if (parent) {
-			unsigned int offset;
-
-			offset = node->path >> RADIX_TREE_HEIGHT_SHIFT;
-			parent->slots[offset] = NULL;
+			parent->slots[node->offset] = NULL;
 			parent->count--;
 		} else {
 			root_tag_clear_all(root);
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
