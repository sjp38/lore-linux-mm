Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id DE90D828F3
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 10:37:43 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id c20so131994091pfc.2
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 07:37:43 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id ui4si2771828pab.203.2016.04.14.07.37.31
        for <linux-mm@kvack.org>;
        Thu, 14 Apr 2016 07:37:31 -0700 (PDT)
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH 16/19] radix-tree: Introduce radix_tree_replace_clear_tags()
Date: Thu, 14 Apr 2016 10:37:19 -0400
Message-Id: <1460644642-30642-17-git-send-email-willy@linux.intel.com>
In-Reply-To: <1460644642-30642-1-git-send-email-willy@linux.intel.com>
References: <1460644642-30642-1-git-send-email-willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Neil Brown <neilb@suse.de>, Ross Zwisler <ross.zwisler@linux.intel.com>

In addition to replacing the entry, we also clear all associated tags.
This is really a one-off special for page_cache_tree_delete() which had
far too much detailed knowledge about how the radix tree works.

For efficiency, factor node_tag_clear() out of radix_tree_tag_clear()
It can be used by radix_tree_delete_item() as well as
radix_tree_replace_clear_tags().

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 include/linux/radix-tree.h |  9 ++++--
 lib/radix-tree.c           | 76 ++++++++++++++++++++++++++++------------------
 mm/filemap.c               | 23 ++------------
 3 files changed, 56 insertions(+), 52 deletions(-)

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index bad6310..11c8e7c 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -281,9 +281,12 @@ bool __radix_tree_delete_node(struct radix_tree_root *root,
 			      struct radix_tree_node *node);
 void *radix_tree_delete_item(struct radix_tree_root *, unsigned long, void *);
 void *radix_tree_delete(struct radix_tree_root *, unsigned long);
-unsigned int
-radix_tree_gang_lookup(struct radix_tree_root *root, void **results,
-			unsigned long first_index, unsigned int max_items);
+struct radix_tree_node *radix_tree_replace_clear_tags(
+				struct radix_tree_root *root,
+				unsigned long index, void *entry);
+unsigned int radix_tree_gang_lookup(struct radix_tree_root *root,
+			void **results, unsigned long first_index,
+			unsigned int max_items);
 unsigned int radix_tree_gang_lookup_slot(struct radix_tree_root *root,
 			void ***results, unsigned long *indices,
 			unsigned long first_index, unsigned int max_items);
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 9a57b70..4574848 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -740,6 +740,26 @@ void *radix_tree_tag_set(struct radix_tree_root *root,
 }
 EXPORT_SYMBOL(radix_tree_tag_set);
 
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
 /**
  *	radix_tree_tag_clear - clear a tag on a radix tree node
  *	@root:		radix tree root
@@ -776,28 +796,9 @@ void *radix_tree_tag_clear(struct radix_tree_root *root,
 		offset = radix_tree_descend(parent, &node, offset);
 	}
 
-	if (node == NULL)
-		goto out;
+	if (node)
+		node_tag_clear(root, parent, tag, offset);
 
-	index >>= shift;
-
-	while (parent) {
-		if (!tag_get(parent, tag, offset))
-			goto out;
-		tag_clear(parent, tag, offset);
-		if (any_tag_set(parent, tag))
-			goto out;
-
-		index >>= RADIX_TREE_MAP_SHIFT;
-		offset = index & RADIX_TREE_MAP_MASK;
-		parent = parent->parent;
-	}
-
-	/* clear the root's tag bit */
-	if (root_tag_get(root, tag))
-		root_tag_clear(root, tag);
-
-out:
 	return node;
 }
 EXPORT_SYMBOL(radix_tree_tag_clear);
@@ -1526,14 +1527,9 @@ void *radix_tree_delete_item(struct radix_tree_root *root,
 
 	offset = get_slot_offset(node, slot);
 
-	/*
-	 * Clear all tags associated with the item to be deleted.
-	 * This way of doing it would be inefficient, but seldom is any set.
-	 */
-	for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++) {
-		if (tag_get(node, tag, offset))
-			radix_tree_tag_clear(root, index, tag);
-	}
+	/* Clear all tags associated with the item to be deleted.  */
+	for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++)
+		node_tag_clear(root, node, tag, offset);
 
 	delete_sibling_entries(node, node_to_entry(slot), offset);
 	node->slots[offset] = NULL;
@@ -1560,6 +1556,28 @@ void *radix_tree_delete(struct radix_tree_root *root, unsigned long index)
 }
 EXPORT_SYMBOL(radix_tree_delete);
 
+struct radix_tree_node *radix_tree_replace_clear_tags(
+			struct radix_tree_root *root,
+			unsigned long index, void *entry)
+{
+	struct radix_tree_node *node;
+	void **slot;
+
+	__radix_tree_lookup(root, index, &node, &slot);
+
+	if (node) {
+		unsigned int tag, offset = get_slot_offset(node, slot);
+		for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++)
+			node_tag_clear(root, node, tag, offset);
+	} else {
+		/* Clear root node tags */
+		root->gfp_mask &= __GFP_BITS_MASK;
+	}
+
+	radix_tree_replace_slot(slot, entry);
+	return node;
+}
+
 /**
  *	radix_tree_tagged - test whether any items in the tree are tagged
  *	@root:		radix tree root
diff --git a/mm/filemap.c b/mm/filemap.c
index a8c69c8..027ea96 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -114,14 +114,11 @@ static void page_cache_tree_delete(struct address_space *mapping,
 				   struct page *page, void *shadow)
 {
 	struct radix_tree_node *node;
-	unsigned long index;
-	unsigned int offset;
-	unsigned int tag;
-	void **slot;
 
 	VM_BUG_ON(!PageLocked(page));
 
-	__radix_tree_lookup(&mapping->page_tree, page->index, &node, &slot);
+	node = radix_tree_replace_clear_tags(&mapping->page_tree, page->index,
+								shadow);
 
 	if (shadow) {
 		mapping->nrexceptional++;
@@ -135,23 +132,9 @@ static void page_cache_tree_delete(struct address_space *mapping,
 	}
 	mapping->nrpages--;
 
-	if (!node) {
-		/* Clear direct pointer tags in root node */
-		mapping->page_tree.gfp_mask &= __GFP_BITS_MASK;
-		radix_tree_replace_slot(slot, shadow);
+	if (!node)
 		return;
-	}
-
-	/* Clear tree tags for the removed page */
-	index = page->index;
-	offset = index & RADIX_TREE_MAP_MASK;
-	for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++) {
-		if (test_bit(offset, node->tags[tag]))
-			radix_tree_tag_clear(&mapping->page_tree, index, tag);
-	}
 
-	/* Delete page, swap shadow entry */
-	radix_tree_replace_slot(slot, shadow);
 	workingset_node_pages_dec(node);
 	if (shadow)
 		workingset_node_shadows_inc(node);
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
