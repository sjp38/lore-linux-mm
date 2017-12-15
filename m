Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 73F856B027D
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 17:05:47 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id x63so3114644ioe.18
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 14:05:47 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id n126si3953519itd.46.2017.12.15.14.05.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Dec 2017 14:05:46 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v5 32/78] mm: Convert workingset to XArray
Date: Fri, 15 Dec 2017 14:04:04 -0800
Message-Id: <20171215220450.7899-33-willy@infradead.org>
In-Reply-To: <20171215220450.7899-1-willy@infradead.org>
References: <20171215220450.7899-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, David Howells <dhowells@redhat.com>, Shaohua Li <shli@kernel.org>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, Marc Zyngier <marc.zyngier@arm.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-raid@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

We construct a fake XA_STATE and use it to delete the node with xa_store()
rather than adding a special function for this unique use case.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/swap.h |  4 ++--
 mm/workingset.c      | 49 +++++++++++++++++++++----------------------------
 2 files changed, 23 insertions(+), 30 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index c2b8128799c1..e4a8afcb214c 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -300,12 +300,12 @@ bool workingset_refault(void *shadow);
 void workingset_activation(struct page *page);
 
 /* Do not use directly, use workingset_lookup_update */
-void workingset_update_node(struct radix_tree_node *node);
+void workingset_update_node(struct xa_node *node);
 
 /* Returns workingset_update_node() if the mapping has shadow entries. */
 #define workingset_lookup_update(mapping)				\
 ({									\
-	radix_tree_update_node_t __helper = workingset_update_node;	\
+	xa_update_node_t __helper = workingset_update_node;		\
 	if (dax_mapping(mapping) || shmem_mapping(mapping))		\
 		__helper = NULL;					\
 	__helper;							\
diff --git a/mm/workingset.c b/mm/workingset.c
index 91b6e16ad4c1..405076233999 100644
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
 	 * the shadow node LRU under the mapping->pages.xa_lock and the
 	 * lru_lock.  Because the page cache tree is emptied before
 	 * the inode can be destroyed, holding the lru_lock pins any
-	 * address_space that has radix tree nodes on the LRU.
+	 * address_space that has nodes on the LRU.
 	 *
 	 * We can then safely transition to the mapping->pages.xa_lock to
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
+				lockdep_is_held(&mapping->pages.xa_lock));
+	xas.xa_offset = node->offset;
+	xas.xa_update = workingset_update_node;
+	/*
+	 * We could store a shadow entry here which was the minimum of the
+	 * shadow entries we were tracking ...
+	 */
+	xas_store(&xas, NULL);
 	inc_lruvec_page_state(virt_to_page(node), WORKINGSET_NODERECLAIM);
-	__radix_tree_delete_node(&mapping->pages, node,
-				 workingset_lookup_update(mapping));
 
 out_invalid:
 	xa_unlock(&mapping->pages);
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
