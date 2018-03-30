Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 35A0E6B0285
	for <linux-mm@kvack.org>; Thu, 29 Mar 2018 23:44:19 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id t2so716277pgb.19
        for <linux-mm@kvack.org>; Thu, 29 Mar 2018 20:44:19 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g26si5476778pfi.310.2018.03.29.20.42.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 29 Mar 2018 20:42:54 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v10 26/62] mm: Convert workingset to XArray
Date: Thu, 29 Mar 2018 20:42:09 -0700
Message-Id: <20180330034245.10462-27-willy@infradead.org>
In-Reply-To: <20180330034245.10462-1-willy@infradead.org>
References: <20180330034245.10462-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

We construct a fake XA_STATE and use it to delete the node with xa_store()
rather than adding a special function for this unique use case.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/swap.h |  9 ---------
 mm/workingset.c      | 51 ++++++++++++++++++++++-----------------------------
 2 files changed, 22 insertions(+), 38 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index a0ebb5deea2d..dab96af23d96 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -307,15 +307,6 @@ void workingset_update_node(struct xa_node *node);
 		xas_set_update(xas, workingset_update_node);		\
 } while (0)
 
-/* Returns workingset_update_node() if the mapping has shadow entries. */
-#define workingset_lookup_update(mapping)				\
-({									\
-	radix_tree_update_node_t __helper = workingset_update_node;	\
-	if (dax_mapping(mapping) || shmem_mapping(mapping))		\
-		__helper = NULL;					\
-	__helper;							\
-})
-
 /* linux/mm/page_alloc.c */
 extern unsigned long totalram_pages;
 extern unsigned long totalreserve_pages;
diff --git a/mm/workingset.c b/mm/workingset.c
index bad4e58881cd..564e97bd5934 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -148,7 +148,7 @@
  * and activations is maintained (node->inactive_age).
  *
  * On eviction, a snapshot of this counter (along with some bits to
- * identify the node) is stored in the now empty page cache radix tree
+ * identify the node) is stored in the now empty page cache
  * slot of the evicted page.  This is called a shadow entry.
  *
  * On cache misses for which there are shadow entries, an eligible
@@ -162,7 +162,7 @@
 
 /*
  * Eviction timestamps need to be able to cover the full range of
- * actionable refaults. However, bits are tight in the radix tree
+ * actionable refaults. However, bits are tight in the xarray
  * entry, and after storing the identifier for the lruvec there might
  * not be enough left to represent every single actionable refault. In
  * that case, we have to sacrifice granularity for distance, and group
@@ -338,7 +338,7 @@ void workingset_activation(struct page *page)
 
 static struct list_lru shadow_nodes;
 
-void workingset_update_node(struct radix_tree_node *node)
+void workingset_update_node(struct xa_node *node)
 {
 	/*
 	 * Track non-empty nodes that contain only shadow entries;
@@ -370,7 +370,7 @@ static unsigned long count_shadow_nodes(struct shrinker *shrinker,
 	local_irq_enable();
 
 	/*
-	 * Approximate a reasonable limit for the radix tree nodes
+	 * Approximate a reasonable limit for the nodes
 	 * containing shadow entries. We don't need to keep more
 	 * shadow entries than possible pages on the active list,
 	 * since refault distances bigger than that are dismissed.
@@ -385,11 +385,11 @@ static unsigned long count_shadow_nodes(struct shrinker *shrinker,
 	 * worst-case density of 1/8th. Below that, not all eligible
 	 * refaults can be detected anymore.
 	 *
-	 * On 64-bit with 7 radix_tree_nodes per page and 64 slots
+	 * On 64-bit with 7 xa_nodes per page and 64 slots
 	 * each, this will reclaim shadow entries when they consume
 	 * ~1.8% of available memory:
 	 *
-	 * PAGE_SIZE / radix_tree_nodes / node_entries * 8 / PAGE_SIZE
+	 * PAGE_SIZE / xa_nodes / node_entries * 8 / PAGE_SIZE
 	 */
 	if (sc->memcg) {
 		cache = mem_cgroup_node_nr_lru_pages(sc->memcg, sc->nid,
@@ -398,7 +398,7 @@ static unsigned long count_shadow_nodes(struct shrinker *shrinker,
 		cache = node_page_state(NODE_DATA(sc->nid), NR_ACTIVE_FILE) +
 			node_page_state(NODE_DATA(sc->nid), NR_INACTIVE_FILE);
 	}
-	max_nodes = cache >> (RADIX_TREE_MAP_SHIFT - 3);
+	max_nodes = cache >> (XA_CHUNK_SHIFT - 3);
 
 	if (nodes <= max_nodes)
 		return 0;
@@ -408,11 +408,11 @@ static unsigned long count_shadow_nodes(struct shrinker *shrinker,
 static enum lru_status shadow_lru_isolate(struct list_head *item,
 					  struct list_lru_one *lru,
 					  spinlock_t *lru_lock,
-					  void *arg)
+					  void *arg) __must_hold(lru_lock)
 {
+	XA_STATE(xas, NULL, 0);
 	struct address_space *mapping;
-	struct radix_tree_node *node;
-	unsigned int i;
+	struct xa_node *node;
 	int ret;
 
 	/*
@@ -420,7 +420,7 @@ static enum lru_status shadow_lru_isolate(struct list_head *item,
 	 * the shadow node LRU under the i_pages lock and the
 	 * lru_lock.  Because the page cache tree is emptied before
 	 * the inode can be destroyed, holding the lru_lock pins any
-	 * address_space that has radix tree nodes on the LRU.
+	 * address_space that has nodes on the LRU.
 	 *
 	 * We can then safely transition to the i_pages lock to
 	 * pin only the address_space of the particular node we want
@@ -449,25 +449,18 @@ static enum lru_status shadow_lru_isolate(struct list_head *item,
 		goto out_invalid;
 	if (WARN_ON_ONCE(node->count != node->nr_values))
 		goto out_invalid;
-	for (i = 0; i < RADIX_TREE_MAP_SIZE; i++) {
-		if (node->slots[i]) {
-			if (WARN_ON_ONCE(!xa_is_value(node->slots[i])))
-				goto out_invalid;
-			if (WARN_ON_ONCE(!node->nr_values))
-				goto out_invalid;
-			if (WARN_ON_ONCE(!mapping->nrexceptional))
-				goto out_invalid;
-			node->slots[i] = NULL;
-			node->nr_values--;
-			node->count--;
-			mapping->nrexceptional--;
-		}
-	}
-	if (WARN_ON_ONCE(node->nr_values))
-		goto out_invalid;
+	mapping->nrexceptional -= node->nr_values;
+	xas.xa = node->array;
+	xas.xa_node = rcu_dereference_protected(node->parent,
+				lockdep_is_held(&mapping->i_pages.xa_lock));
+	xas.xa_offset = node->offset;
+	xas.xa_update = workingset_update_node;
+	/*
+	 * We could store a shadow entry here which was the minimum of the
+	 * shadow entries we were tracking ...
+	 */
+	xas_store(&xas, NULL);
 	inc_lruvec_page_state(virt_to_page(node), WORKINGSET_NODERECLAIM);
-	__radix_tree_delete_node(&mapping->i_pages, node,
-				 workingset_lookup_update(mapping));
 
 out_invalid:
 	xa_unlock(&mapping->i_pages);
-- 
2.16.2
