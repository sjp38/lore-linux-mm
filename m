Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2BA656B0266
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 14:08:12 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id s63so46466554wms.7
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 11:08:12 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id g142si12143704wmg.53.2016.11.07.11.08.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Nov 2016 11:08:10 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 5/6] mm: workingset: switch shadow entry tracking to radix tree exceptional counting
Date: Mon,  7 Nov 2016 14:07:40 -0500
Message-Id: <20161107190741.3619-6-hannes@cmpxchg.org>
In-Reply-To: <20161107190741.3619-1-hannes@cmpxchg.org>
References: <20161107190741.3619-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Currently, we track the shadow entries in the page cache in the upper
bits of the radix_tree_node->count, behind the back of the radix tree
implementation. Because the radix tree code has no awareness of them,
we rely on random subtleties throughout the implementation (such as
the node->count != 1 check in the shrinking code which is meant to
exclude multi-entry nodes, but also happens to skip nodes with only
one shadow entry since it's accounted in the upper bits). This is
error prone and has, in fact, caused the bug fixed in d3798ae8c6f3
("mm: filemap: don't plant shadow entries without radix tree node").

To remove these subtleties, this patch moves shadow entry tracking
from the upper bits of node->count to the existing counter for
exceptional entries. node->count goes back to being a simple counter
of valid entries in the tree node and can be shrunk to a single byte.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/radix-tree.h |  6 +-----
 include/linux/swap.h       | 32 --------------------------------
 mm/filemap.c               | 30 +++++++++++-------------------
 mm/truncate.c              |  4 +---
 mm/workingset.c            | 11 +++++++----
 5 files changed, 20 insertions(+), 63 deletions(-)

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index 2d1b9b8be983..56619703ae7a 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -80,14 +80,10 @@ static inline bool radix_tree_is_internal_node(void *ptr)
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
 	unsigned char	exceptional;	/* Exceptional entry count */
 	union {
 		struct {
diff --git a/include/linux/swap.h b/include/linux/swap.h
index a56523cefb9b..660a11de0186 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -248,38 +248,6 @@ bool workingset_refault(void *shadow);
 void workingset_activation(struct page *page);
 extern struct list_lru workingset_shadow_nodes;
 
-static inline unsigned int workingset_node_pages(struct radix_tree_node *node)
-{
-	return node->count & RADIX_TREE_COUNT_MASK;
-}
-
-static inline void workingset_node_pages_inc(struct radix_tree_node *node)
-{
-	node->count++;
-}
-
-static inline void workingset_node_pages_dec(struct radix_tree_node *node)
-{
-	VM_WARN_ON_ONCE(!workingset_node_pages(node));
-	node->count--;
-}
-
-static inline unsigned int workingset_node_shadows(struct radix_tree_node *node)
-{
-	return node->count >> RADIX_TREE_COUNT_SHIFT;
-}
-
-static inline void workingset_node_shadows_inc(struct radix_tree_node *node)
-{
-	node->count += 1U << RADIX_TREE_COUNT_SHIFT;
-}
-
-static inline void workingset_node_shadows_dec(struct radix_tree_node *node)
-{
-	VM_WARN_ON_ONCE(!workingset_node_shadows(node));
-	node->count -= 1U << RADIX_TREE_COUNT_SHIFT;
-}
-
 /* linux/mm/page_alloc.c */
 extern unsigned long totalram_pages;
 extern unsigned long totalreserve_pages;
diff --git a/mm/filemap.c b/mm/filemap.c
index eb463156f29a..438f0b54f8fd 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -132,25 +132,19 @@ static int page_cache_tree_insert(struct address_space *mapping,
 		if (!dax_mapping(mapping)) {
 			if (shadowp)
 				*shadowp = p;
-			if (node)
-				workingset_node_shadows_dec(node);
 		} else {
 			/* DAX can replace empty locked entry with a hole */
 			WARN_ON_ONCE(p !=
 				(void *)(RADIX_TREE_EXCEPTIONAL_ENTRY |
 					 RADIX_DAX_ENTRY_LOCK));
-			/* DAX accounts exceptional entries as normal pages */
-			if (node)
-				workingset_node_pages_dec(node);
 			/* Wakeup waiters for exceptional entry lock */
 			dax_wake_mapping_entry_waiter(mapping, page->index,
 						      false);
 		}
 	}
-	radix_tree_replace_slot(&mapping->page_tree, slot, page);
+	__radix_tree_replace(&mapping->page_tree, node, slot, page);
 	mapping->nrpages++;
 	if (node) {
-		workingset_node_pages_inc(node);
 		/*
 		 * Don't track node that contains actual pages.
 		 *
@@ -193,29 +187,27 @@ static void page_cache_tree_delete(struct address_space *mapping,
 			shadow = NULL;
 		}
 
-		radix_tree_replace_slot(&mapping->page_tree, slot, shadow);
+		__radix_tree_replace(&mapping->page_tree, node, slot, shadow);
 
 		if (!node)
 			break;
 
-		workingset_node_pages_dec(node);
-		if (shadow)
-			workingset_node_shadows_inc(node);
-		else
-			if (__radix_tree_delete_node(&mapping->page_tree, node))
-				continue;
+		if (!shadow &&
+		    __radix_tree_delete_node(&mapping->page_tree, node))
+			continue;
 
 		/*
-		 * Track node that only contains shadow entries. DAX mappings
-		 * contain no shadow entries and may contain other exceptional
-		 * entries so skip those.
+		 * Track node that only contains shadow entries. DAX and SHMEM
+		 * mappings contain no shadow entries and may contain other
+		 * exceptional entries so skip those.
 		 *
 		 * Avoid acquiring the list_lru lock if already tracked.
 		 * The list_empty() test is safe as node->private_list is
 		 * protected by mapping->tree_lock.
 		 */
-		if (!dax_mapping(mapping) && !workingset_node_pages(node) &&
-				list_empty(&node->private_list)) {
+		if (!dax_mapping(mapping) && !shmem_mapping(mapping) &&
+		    node->count == node->exceptional &&
+		    list_empty(&node->private_list)) {
 			node->private_data = mapping;
 			list_lru_add(&workingset_shadow_nodes,
 					&node->private_list);
diff --git a/mm/truncate.c b/mm/truncate.c
index 6ae44571d4c7..d3ce5f261f47 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -53,7 +53,6 @@ static void clear_exceptional_entry(struct address_space *mapping,
 	mapping->nrexceptional--;
 	if (!node)
 		goto unlock;
-	workingset_node_shadows_dec(node);
 	/*
 	 * Don't track node without shadow entries.
 	 *
@@ -61,8 +60,7 @@ static void clear_exceptional_entry(struct address_space *mapping,
 	 * The list_empty() test is safe as node->private_list is
 	 * protected by mapping->tree_lock.
 	 */
-	if (!workingset_node_shadows(node) &&
-	    !list_empty(&node->private_list))
+	if (!node->exceptional && !list_empty(&node->private_list))
 		list_lru_del(&workingset_shadow_nodes,
 				&node->private_list);
 	__radix_tree_delete_node(&mapping->page_tree, node);
diff --git a/mm/workingset.c b/mm/workingset.c
index 3cfc61d84a52..ca92d0f70d9a 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -418,22 +418,25 @@ static enum lru_status shadow_lru_isolate(struct list_head *item,
 	 * no pages, so we expect to be able to remove them all and
 	 * delete and free the empty node afterwards.
 	 */
-	if (WARN_ON_ONCE(!workingset_node_shadows(node)))
+	if (WARN_ON_ONCE(!node->exceptional))
 		goto out_invalid;
-	if (WARN_ON_ONCE(workingset_node_pages(node)))
+	if (WARN_ON_ONCE(node->count != node->exceptional))
 		goto out_invalid;
 	for (i = 0; i < RADIX_TREE_MAP_SIZE; i++) {
 		if (node->slots[i]) {
 			if (WARN_ON_ONCE(!radix_tree_exceptional_entry(node->slots[i])))
 				goto out_invalid;
+			if (WARN_ON_ONCE(!node->exceptional))
+				goto out_invalid;
 			if (WARN_ON_ONCE(!mapping->nrexceptional))
 				goto out_invalid;
 			node->slots[i] = NULL;
-			workingset_node_shadows_dec(node);
+			node->exceptional--;
+			node->count--;
 			mapping->nrexceptional--;
 		}
 	}
-	if (WARN_ON_ONCE(workingset_node_shadows(node)))
+	if (WARN_ON_ONCE(node->exceptional))
 		goto out_invalid;
 	inc_node_state(page_pgdat(virt_to_page(node)), WORKINGSET_NODERECLAIM);
 	__radix_tree_delete_node(&mapping->page_tree, node);
-- 
2.10.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
