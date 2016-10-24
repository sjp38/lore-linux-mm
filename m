Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6C7A86B0261
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 11:27:22 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id b80so34373900wme.5
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 08:27:22 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id m63si12614763wma.64.2016.10.24.08.27.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Oct 2016 08:27:21 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id o81so10305403wma.2
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 08:27:21 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [Stable 4.4 - NEEDS REVIEW - 1/3] mm: workingset: fix crash in shadow node shrinker caused by replace_page_cache_page()
Date: Mon, 24 Oct 2016 17:26:03 +0200
Message-Id: <20161024152605.11707-2-mhocko@kernel.org>
In-Reply-To: <20161024152605.11707-1-mhocko@kernel.org>
References: <20161024152605.11707-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Stable tree <stable@vger.kernel.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Antonio SJ Musumeci <trapexit@spawn.link>, Miklos Szeredi <miklos@szeredi.hu>

From: Johannes Weiner <hannes@cmpxchg.org>

Commit 22f2ac51b6d643666f4db093f13144f773ff3f3a upstream.

Antonio reports the following crash when using fuse under memory pressure:

  kernel BUG at /build/linux-a2WvEb/linux-4.4.0/mm/workingset.c:346!
  invalid opcode: 0000 [#1] SMP
  Modules linked in: all of them
  CPU: 2 PID: 63 Comm: kswapd0 Not tainted 4.4.0-36-generic #55-Ubuntu
  Hardware name: System manufacturer System Product Name/P8H67-M PRO, BIOS 3904 04/27/2013
  task: ffff88040cae6040 ti: ffff880407488000 task.ti: ffff880407488000
  RIP: shadow_lru_isolate+0x181/0x190
  Call Trace:
    __list_lru_walk_one.isra.3+0x8f/0x130
    list_lru_walk_one+0x23/0x30
    scan_shadow_nodes+0x34/0x50
    shrink_slab.part.40+0x1ed/0x3d0
    shrink_zone+0x2ca/0x2e0
    kswapd+0x51e/0x990
    kthread+0xd8/0xf0
    ret_from_fork+0x3f/0x70

which corresponds to the following sanity check in the shadow node
tracking:

  BUG_ON(node->count & RADIX_TREE_COUNT_MASK);

The workingset code tracks radix tree nodes that exclusively contain
shadow entries of evicted pages in them, and this (somewhat obscure)
line checks whether there are real pages left that would interfere with
reclaim of the radix tree node under memory pressure.

While discussing ways how fuse might sneak pages into the radix tree
past the workingset code, Miklos pointed to replace_page_cache_page(),
and indeed there is a problem there: it properly accounts for the old
page being removed - __delete_from_page_cache() does that - but then
does a raw raw radix_tree_insert(), not accounting for the replacement
page.  Eventually the page count bits in node->count underflow while
leaving the node incorrectly linked to the shadow node LRU.

To address this, make sure replace_page_cache_page() uses the tracked
page insertion code, page_cache_tree_insert().  This fixes the page
accounting and makes sure page-containing nodes are properly unlinked
from the shadow node LRU again.

Also, make the sanity checks a bit less obscure by using the helpers for
checking the number of pages and shadows in a radix tree node.

Fixes: 449dd6984d0e ("mm: keep page cache radix tree nodes in check")
Link: http://lkml.kernel.org/r/20160919155822.29498-1-hannes@cmpxchg.org
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Reported-by: Antonio SJ Musumeci <trapexit@spawn.link>
Debugged-by: Miklos Szeredi <miklos@szeredi.hu>
Cc: <stable@vger.kernel.org>	[3.15+]
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/swap.h |  2 ++
 mm/filemap.c         | 86 ++++++++++++++++++++++++++--------------------------
 mm/workingset.c      | 10 +++---
 3 files changed, 49 insertions(+), 49 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 7ba7dccaf0e7..b28de19aadbf 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -266,6 +266,7 @@ static inline void workingset_node_pages_inc(struct radix_tree_node *node)
 
 static inline void workingset_node_pages_dec(struct radix_tree_node *node)
 {
+	VM_BUG_ON(!workingset_node_pages(node));
 	node->count--;
 }
 
@@ -281,6 +282,7 @@ static inline void workingset_node_shadows_inc(struct radix_tree_node *node)
 
 static inline void workingset_node_shadows_dec(struct radix_tree_node *node)
 {
+	VM_BUG_ON(!workingset_node_shadows(node));
 	node->count -= 1U << RADIX_TREE_COUNT_SHIFT;
 }
 
diff --git a/mm/filemap.c b/mm/filemap.c
index 1bb007624b53..4cfe423d3e8a 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -109,6 +109,48 @@
  *   ->tasklist_lock            (memory_failure, collect_procs_ao)
  */
 
+static int page_cache_tree_insert(struct address_space *mapping,
+				  struct page *page, void **shadowp)
+{
+	struct radix_tree_node *node;
+	void **slot;
+	int error;
+
+	error = __radix_tree_create(&mapping->page_tree, page->index,
+				    &node, &slot);
+	if (error)
+		return error;
+	if (*slot) {
+		void *p;
+
+		p = radix_tree_deref_slot_protected(slot, &mapping->tree_lock);
+		if (!radix_tree_exceptional_entry(p))
+			return -EEXIST;
+		if (shadowp)
+			*shadowp = p;
+		mapping->nrshadows--;
+		if (node)
+			workingset_node_shadows_dec(node);
+	}
+	radix_tree_replace_slot(slot, page);
+	mapping->nrpages++;
+	if (node) {
+		workingset_node_pages_inc(node);
+		/*
+		 * Don't track node that contains actual pages.
+		 *
+		 * Avoid acquiring the list_lru lock if already
+		 * untracked.  The list_empty() test is safe as
+		 * node->private_list is protected by
+		 * mapping->tree_lock.
+		 */
+		if (!list_empty(&node->private_list))
+			list_lru_del(&workingset_shadow_nodes,
+				     &node->private_list);
+	}
+	return 0;
+}
+
 static void page_cache_tree_delete(struct address_space *mapping,
 				   struct page *page, void *shadow)
 {
@@ -538,7 +580,7 @@ int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
 		memcg = mem_cgroup_begin_page_stat(old);
 		spin_lock_irqsave(&mapping->tree_lock, flags);
 		__delete_from_page_cache(old, NULL, memcg);
-		error = radix_tree_insert(&mapping->page_tree, offset, new);
+		error = page_cache_tree_insert(mapping, new, NULL);
 		BUG_ON(error);
 		mapping->nrpages++;
 
@@ -562,48 +604,6 @@ int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
 }
 EXPORT_SYMBOL_GPL(replace_page_cache_page);
 
-static int page_cache_tree_insert(struct address_space *mapping,
-				  struct page *page, void **shadowp)
-{
-	struct radix_tree_node *node;
-	void **slot;
-	int error;
-
-	error = __radix_tree_create(&mapping->page_tree, page->index,
-				    &node, &slot);
-	if (error)
-		return error;
-	if (*slot) {
-		void *p;
-
-		p = radix_tree_deref_slot_protected(slot, &mapping->tree_lock);
-		if (!radix_tree_exceptional_entry(p))
-			return -EEXIST;
-		if (shadowp)
-			*shadowp = p;
-		mapping->nrshadows--;
-		if (node)
-			workingset_node_shadows_dec(node);
-	}
-	radix_tree_replace_slot(slot, page);
-	mapping->nrpages++;
-	if (node) {
-		workingset_node_pages_inc(node);
-		/*
-		 * Don't track node that contains actual pages.
-		 *
-		 * Avoid acquiring the list_lru lock if already
-		 * untracked.  The list_empty() test is safe as
-		 * node->private_list is protected by
-		 * mapping->tree_lock.
-		 */
-		if (!list_empty(&node->private_list))
-			list_lru_del(&workingset_shadow_nodes,
-				     &node->private_list);
-	}
-	return 0;
-}
-
 static int __add_to_page_cache_locked(struct page *page,
 				      struct address_space *mapping,
 				      pgoff_t offset, gfp_t gfp_mask,
diff --git a/mm/workingset.c b/mm/workingset.c
index aa017133744b..df66f426fdcf 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -341,21 +341,19 @@ static enum lru_status shadow_lru_isolate(struct list_head *item,
 	 * no pages, so we expect to be able to remove them all and
 	 * delete and free the empty node afterwards.
 	 */
-
-	BUG_ON(!node->count);
-	BUG_ON(node->count & RADIX_TREE_COUNT_MASK);
+	BUG_ON(!workingset_node_shadows(node));
+	BUG_ON(workingset_node_pages(node));
 
 	for (i = 0; i < RADIX_TREE_MAP_SIZE; i++) {
 		if (node->slots[i]) {
 			BUG_ON(!radix_tree_exceptional_entry(node->slots[i]));
 			node->slots[i] = NULL;
-			BUG_ON(node->count < (1U << RADIX_TREE_COUNT_SHIFT));
-			node->count -= 1U << RADIX_TREE_COUNT_SHIFT;
+			workingset_node_shadows_dec(node);
 			BUG_ON(!mapping->nrshadows);
 			mapping->nrshadows--;
 		}
 	}
-	BUG_ON(node->count);
+	BUG_ON(workingset_node_shadows(node));
 	inc_zone_state(page_zone(virt_to_page(node)), WORKINGSET_NODERECLAIM);
 	if (!__radix_tree_delete_node(&mapping->page_tree, node))
 		BUG();
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
