Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5F8D76B0262
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 13:24:53 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id b81so13255892lfe.1
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 10:24:53 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id p83si4279260lfa.94.2016.10.19.10.24.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Oct 2016 10:24:51 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 4/5] mm: workingset: restore single-page file refault tracking
Date: Wed, 19 Oct 2016 13:24:27 -0400
Message-Id: <20161019172428.7649-5-hannes@cmpxchg.org>
In-Reply-To: <20161019172428.7649-1-hannes@cmpxchg.org>
References: <20161019172428.7649-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Dave Jones <davej@codemonkey.org.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Currently, we account shadow entries in the page cache in the upper
bits of the radix_tree_node->count, behind the back of the radix tree
implementation. Because the radix tree code has no awareness of them,
we have to prevent shadow entries from going through operations where
the tree implementation relies on or modifies node->count: extending
and shrinking the tree from and to a single direct root->rnode entry.

As a consequence, we cannot store shadow entries for files that only
have index 0 populated, and thus cannot detect refaults from them,
which in turn degrades the thrashing compensation in LRU reclaim.

Another consequence is that we rely on subtleties throughout the radix
tree code, such as the node->count != 1 check in the shrinking code,
which is meant to exclude multi-entry nodes but also skips nodes with
only one shadow entry since they are accounted in the upper bits. This
is error prone, and has in fact caused the bug fixed in d3798ae8c6f3
("mm: filemap: don't plant shadow entries without radix tree node").

To fix this, this patch moves the shadow counter from the upper bits
of node->count into the new node->special counter and tags shadow
entries RADIX_TREE_TAG_SPECIAL so the radix tree code handles them
properly. node->count then counts all tree entries again, including
shadows, and becomes a superset of node->special.

Switching from a magic node->count to a special entry tracking scheme
that is native to the radix tree code removes the fragile subtleties
mentioned above. By being able to tag special entries even when
they're a direct pointer in the tree root, we can store shadow entries
for single-page files again, and thus restore refault detection and
thrashing compensation for them.

As the upper bits of node->count are no longer used, we can shrink it
down to an unsigned char, which reverts the size increase of the radix
tree node caused by the previous patch.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/radix-tree.h |  6 +-----
 include/linux/swap.h       | 16 ++++++++++------
 mm/filemap.c               | 23 +++++++++++------------
 mm/truncate.c              |  2 ++
 4 files changed, 24 insertions(+), 23 deletions(-)

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index 2e1c9added23..f6dbbd2eb4e0 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -86,14 +86,10 @@ enum radix_tree_tags {
 #define RADIX_TREE_MAX_PATH (DIV_ROUND_UP(RADIX_TREE_INDEX_BITS, \
 					  RADIX_TREE_MAP_SHIFT))
 
-/* Internally used bits of node->count */
-#define RADIX_TREE_COUNT_SHIFT	(RADIX_TREE_MAP_SHIFT + 1)
-#define RADIX_TREE_COUNT_MASK	((1UL << RADIX_TREE_COUNT_SHIFT) - 1)
-
 struct radix_tree_node {
 	unsigned char	shift;		/* Bits remaining in each slot */
 	unsigned char	offset;		/* Slot offset in parent */
-	unsigned int	count;		/* Total entry count */
+	unsigned char	count;		/* Total entry count */
 	unsigned char	special;	/* Special entry count */
 	union {
 		struct {
diff --git a/include/linux/swap.h b/include/linux/swap.h
index a56523cefb9b..22786f2334fb 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -250,7 +250,7 @@ extern struct list_lru workingset_shadow_nodes;
 
 static inline unsigned int workingset_node_pages(struct radix_tree_node *node)
 {
-	return node->count & RADIX_TREE_COUNT_MASK;
+	return node->count - node->special;
 }
 
 static inline void workingset_node_pages_inc(struct radix_tree_node *node)
@@ -260,24 +260,28 @@ static inline void workingset_node_pages_inc(struct radix_tree_node *node)
 
 static inline void workingset_node_pages_dec(struct radix_tree_node *node)
 {
-	VM_WARN_ON_ONCE(!workingset_node_pages(node));
+	VM_WARN_ON_ONCE(node->count == node->special);
+	VM_WARN_ON_ONCE(!node->count);
 	node->count--;
 }
 
 static inline unsigned int workingset_node_shadows(struct radix_tree_node *node)
 {
-	return node->count >> RADIX_TREE_COUNT_SHIFT;
+	return node->special;
 }
 
 static inline void workingset_node_shadows_inc(struct radix_tree_node *node)
 {
-	node->count += 1U << RADIX_TREE_COUNT_SHIFT;
+	node->special++;
+	node->count++;
 }
 
 static inline void workingset_node_shadows_dec(struct radix_tree_node *node)
 {
-	VM_WARN_ON_ONCE(!workingset_node_shadows(node));
-	node->count -= 1U << RADIX_TREE_COUNT_SHIFT;
+	VM_WARN_ON_ONCE(!node->special);
+	VM_WARN_ON_ONCE(!node->count);
+	node->special--;
+	node->count--;
 }
 
 /* linux/mm/page_alloc.c */
diff --git a/mm/filemap.c b/mm/filemap.c
index 42e1f006aa3d..f684bd3c0838 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -130,10 +130,12 @@ static int page_cache_tree_insert(struct address_space *mapping,
 
 		mapping->nrexceptional--;
 		if (!dax_mapping(mapping)) {
-			if (shadowp)
-				*shadowp = p;
+			__radix_tree_tag_clear(&mapping->page_tree, node, slot,
+					       RADIX_TREE_TAG_SPECIAL);
 			if (node)
 				workingset_node_shadows_dec(node);
+			if (shadowp)
+				*shadowp = p;
 		} else {
 			/* DAX can replace empty locked entry with a hole */
 			WARN_ON_ONCE(p !=
@@ -184,19 +186,16 @@ static void page_cache_tree_delete(struct address_space *mapping,
 
 		__radix_tree_clear_tags(&mapping->page_tree, node, slot);
 
-		if (!node) {
-			VM_BUG_ON_PAGE(nr != 1, page);
-			/*
-			 * We need a node to properly account shadow
-			 * entries. Don't plant any without. XXX
-			 */
-			shadow = NULL;
-		}
-
 		radix_tree_replace_slot(slot, shadow);
 
-		if (!node)
+		if (shadow)
+			__radix_tree_tag_set(&mapping->page_tree, node, slot,
+					     RADIX_TREE_TAG_SPECIAL);
+
+		if (!node) {
+			VM_BUG_ON_PAGE(nr != 1, page);
 			break;
+		}
 
 		workingset_node_pages_dec(node);
 		if (shadow)
diff --git a/mm/truncate.c b/mm/truncate.c
index a01cce450a26..bec210e5ee4b 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -50,6 +50,8 @@ static void clear_exceptional_entry(struct address_space *mapping,
 	if (*slot != entry)
 		goto unlock;
 	radix_tree_replace_slot(slot, NULL);
+	__radix_tree_tag_clear(&mapping->page_tree, node, slot,
+			       RADIX_TREE_TAG_SPECIAL);
 	mapping->nrexceptional--;
 	if (!node)
 		goto unlock;
-- 
2.10.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
