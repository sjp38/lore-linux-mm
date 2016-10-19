Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8301E6B0260
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 13:24:46 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id b81so13254347lfe.1
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 10:24:46 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id f6si4318428lfe.316.2016.10.19.10.24.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Oct 2016 10:24:44 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 1/5] lib: radix-tree: provide node-granular interface for radix tree tags
Date: Wed, 19 Oct 2016 13:24:24 -0400
Message-Id: <20161019172428.7649-2-hannes@cmpxchg.org>
In-Reply-To: <20161019172428.7649-1-hannes@cmpxchg.org>
References: <20161019172428.7649-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Dave Jones <davej@codemonkey.org.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Page cache insertion and deletion will need to tag shadow entries, but
these callsites already look up the raw node and slot for accounting.
Provide an interface to modify tags without another tree lookup.

We already have node_tag_clear(); factor node_tag_set() from
radix_tree_tag_set(), then provide node-granular functions for
clearing and setting. We won't be needing a getter for now.

The existing radix_tree_clear_tags() can be implemented on top of
__radix_tree_tag_clear(). Since it's also a node-granular function,
rename and relocate it accordingly.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/radix-tree.h |  12 +++--
 lib/radix-tree.c           | 109 +++++++++++++++++++++++++++------------------
 mm/filemap.c               |   2 +-
 3 files changed, 76 insertions(+), 47 deletions(-)

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index af3581b8a451..dc261da5096c 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -280,9 +280,6 @@ bool __radix_tree_delete_node(struct radix_tree_root *root,
 			      struct radix_tree_node *node);
 void *radix_tree_delete_item(struct radix_tree_root *, unsigned long, void *);
 void *radix_tree_delete(struct radix_tree_root *, unsigned long);
-void radix_tree_clear_tags(struct radix_tree_root *root,
-			   struct radix_tree_node *node,
-			   void **slot);
 unsigned int radix_tree_gang_lookup(struct radix_tree_root *root,
 			void **results, unsigned long first_index,
 			unsigned int max_items);
@@ -293,6 +290,15 @@ int radix_tree_preload(gfp_t gfp_mask);
 int radix_tree_maybe_preload(gfp_t gfp_mask);
 int radix_tree_maybe_preload_order(gfp_t gfp_mask, int order);
 void radix_tree_init(void);
+void __radix_tree_tag_set(struct radix_tree_root *root,
+			  struct radix_tree_node *node,
+			  void **slot, unsigned int tag);
+void __radix_tree_tag_clear(struct radix_tree_root *root,
+			  struct radix_tree_node *node,
+			  void **slot, unsigned int tag);
+void __radix_tree_clear_tags(struct radix_tree_root *root,
+			     struct radix_tree_node *node,
+			     void **slot);
 void *radix_tree_tag_set(struct radix_tree_root *root,
 			unsigned long index, unsigned int tag);
 void *radix_tree_tag_clear(struct radix_tree_root *root,
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 8e6d552c40dd..d04d0938d7b7 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -746,6 +746,67 @@ void *radix_tree_lookup(struct radix_tree_root *root, unsigned long index)
 }
 EXPORT_SYMBOL(radix_tree_lookup);
 
+static void node_tag_set(struct radix_tree_root *root,
+			 struct radix_tree_node *node,
+			 unsigned int tag, unsigned int offset)
+{
+	while (node) {
+		if (tag_get(node, tag, offset))
+			return;
+		tag_set(node, tag, offset);
+
+		offset = node->offset;
+		node = node->parent;
+	}
+
+	if (!root_tag_get(root, tag))
+		root_tag_set(root, tag);
+}
+
+static void node_tag_clear(struct radix_tree_root *root,
+				struct radix_tree_node *node,
+				unsigned int tag, unsigned int offset)
+{
+	while (node) {
+		if (!tag_get(node, tag, offset))
+			return;
+		tag_clear(node, tag, offset);
+		if (any_tag_set(node, tag))
+			return;
+
+		offset = node->offset;
+		node = node->parent;
+	}
+
+	/* clear the root's tag bit */
+	if (root_tag_get(root, tag))
+		root_tag_clear(root, tag);
+}
+
+void __radix_tree_tag_set(struct radix_tree_root *root,
+			  struct radix_tree_node *node,
+			  void **slot, unsigned int tag)
+{
+	node_tag_set(root, node, tag, node ? get_slot_offset(node, slot) : 0);
+}
+
+void __radix_tree_tag_clear(struct radix_tree_root *root,
+			    struct radix_tree_node *node,
+			    void **slot, unsigned int tag)
+{
+	node_tag_clear(root, node, tag, node ? get_slot_offset(node, slot) : 0);
+}
+
+void __radix_tree_clear_tags(struct radix_tree_root *root,
+			     struct radix_tree_node *node,
+			     void **slot)
+{
+	unsigned int tag;
+
+	for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++)
+		__radix_tree_tag_clear(root, node, slot, tag);
+}
+
 /**
  *	radix_tree_tag_set - set a tag on a radix tree node
  *	@root:		radix tree root
@@ -764,49 +825,25 @@ void *radix_tree_tag_set(struct radix_tree_root *root,
 {
 	struct radix_tree_node *node, *parent;
 	unsigned long maxindex;
+	int uninitialized_var(offset);
 
 	radix_tree_load_root(root, &node, &maxindex);
 	BUG_ON(index > maxindex);
 
-	while (radix_tree_is_internal_node(node)) {
-		unsigned offset;
+	parent = NULL;
 
+	while (radix_tree_is_internal_node(node)) {
 		parent = entry_to_node(node);
 		offset = radix_tree_descend(parent, &node, index);
-		BUG_ON(!node);
-
-		if (!tag_get(parent, tag, offset))
-			tag_set(parent, tag, offset);
 	}
 
-	/* set the root's tag bit */
-	if (!root_tag_get(root, tag))
-		root_tag_set(root, tag);
+	if (node)
+		node_tag_set(root, parent, tag, offset);
 
 	return node;
 }
 EXPORT_SYMBOL(radix_tree_tag_set);
 
-static void node_tag_clear(struct radix_tree_root *root,
-				struct radix_tree_node *node,
-				unsigned int tag, unsigned int offset)
-{
-	while (node) {
-		if (!tag_get(node, tag, offset))
-			return;
-		tag_clear(node, tag, offset);
-		if (any_tag_set(node, tag))
-			return;
-
-		offset = node->offset;
-		node = node->parent;
-	}
-
-	/* clear the root's tag bit */
-	if (root_tag_get(root, tag))
-		root_tag_clear(root, tag);
-}
-
 /**
  *	radix_tree_tag_clear - clear a tag on a radix tree node
  *	@root:		radix tree root
@@ -1583,20 +1620,6 @@ void *radix_tree_delete(struct radix_tree_root *root, unsigned long index)
 }
 EXPORT_SYMBOL(radix_tree_delete);
 
-void radix_tree_clear_tags(struct radix_tree_root *root,
-			   struct radix_tree_node *node,
-			   void **slot)
-{
-	if (node) {
-		unsigned int tag, offset = get_slot_offset(node, slot);
-		for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++)
-			node_tag_clear(root, node, tag, offset);
-	} else {
-		/* Clear root node tags */
-		root->gfp_mask &= __GFP_BITS_MASK;
-	}
-}
-
 /**
  *	radix_tree_tagged - test whether any items in the tree are tagged
  *	@root:		radix tree root
diff --git a/mm/filemap.c b/mm/filemap.c
index 849f459ad078..42e1f006aa3d 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -182,7 +182,7 @@ static void page_cache_tree_delete(struct address_space *mapping,
 		__radix_tree_lookup(&mapping->page_tree, page->index + i,
 				    &node, &slot);
 
-		radix_tree_clear_tags(&mapping->page_tree, node, slot);
+		__radix_tree_clear_tags(&mapping->page_tree, node, slot);
 
 		if (!node) {
 			VM_BUG_ON_PAGE(nr != 1, page);
-- 
2.10.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
