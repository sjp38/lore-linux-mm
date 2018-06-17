Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id AA5256B02C4
	for <linux-mm@kvack.org>; Sat, 16 Jun 2018 22:02:35 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id i1-v6so7669668pld.11
        for <linux-mm@kvack.org>; Sat, 16 Jun 2018 19:02:35 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id n3-v6si11537762pld.116.2018.06.16.19.01.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 16 Jun 2018 19:01:04 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v14 36/74] mm: Convert workingset to XArray
Date: Sat, 16 Jun 2018 19:00:14 -0700
Message-Id: <20180617020052.4759-37-willy@infradead.org>
In-Reply-To: <20180617020052.4759-1-willy@infradead.org>
References: <20180617020052.4759-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net

We construct an XA_STATE and use it to delete the node with
xas_store() rather than adding a special function for this unique
use case.  Includes a test that simulates this usage for the
test suite.

Signed-off-by: Matthew Wilcox <willy@infradead.org>
---
 include/linux/swap.h |  9 -------
 lib/test_xarray.c    | 61 ++++++++++++++++++++++++++++++++++++++++++++
 mm/workingset.c      | 51 +++++++++++++++---------------------
 3 files changed, 82 insertions(+), 39 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 1b91e7f7bdeb..a450a1d40b19 100644
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
diff --git a/lib/test_xarray.c b/lib/test_xarray.c
index 818cfd8746ba..0ac0c8108ef4 100644
--- a/lib/test_xarray.c
+++ b/lib/test_xarray.c
@@ -554,6 +554,63 @@ static void check_move(struct xarray *xa)
 		check_move_small(xa, (1UL << i) - 1);
 }
 
+static LIST_HEAD(shadow_nodes);
+
+static void test_update_node(struct xa_node *node)
+{
+	if (node->count && node->count == node->nr_values) {
+		if (list_empty(&node->private_list))
+			list_add(&shadow_nodes, &node->private_list);
+	} else {
+		if (!list_empty(&node->private_list))
+			list_del_init(&node->private_list);
+	}
+}
+
+static void shadow_remove(struct xarray *xa)
+{
+	struct xa_node *node;
+
+	while ((node = list_first_entry_or_null(&shadow_nodes,
+					struct xa_node, private_list))) {
+		XA_STATE(xas, node->array, 0);
+		XA_BUG_ON(xa, node->array != xa);
+		list_del_init(&node->private_list);
+		xas.xa_node = xa_parent_locked(node->array, node);
+		xas.xa_offset = node->offset;
+		xas.xa_shift = node->shift + XA_CHUNK_SHIFT;
+		xas_set_update(&xas, test_update_node);
+		xas_store(&xas, NULL);
+	}
+}
+
+static void check_workingset(struct xarray *xa, unsigned long index)
+{
+	XA_STATE(xas, xa, index);
+	xas_set_update(&xas, test_update_node);
+
+	do {
+		xas_store(&xas, xa_mk_value(0));
+	} while (xas_nomem(&xas, GFP_KERNEL));
+
+	xas_next(&xas);
+	do {
+		xas_store(&xas, xa_mk_value(1));
+	} while (xas_nomem(&xas, GFP_KERNEL));
+	XA_BUG_ON(xa, list_empty(&shadow_nodes));
+
+	xas_next(&xas);
+	xas_store(&xas, &xas);
+	XA_BUG_ON(xa, !list_empty(&shadow_nodes));
+
+	xas_store(&xas, xa_mk_value(2));
+	XA_BUG_ON(xa, list_empty(&shadow_nodes));
+
+	shadow_remove(xa);
+	XA_BUG_ON(xa, !list_empty(&shadow_nodes));
+	XA_BUG_ON(xa, !xa_empty(xa));
+}
+
 static int xarray_checks(void)
 {
 	DEFINE_XARRAY(array);
@@ -570,6 +627,10 @@ static int xarray_checks(void)
 	check_move(&array);
 	check_store_iter(&array);
 
+	check_workingset(&array, 0);
+	check_workingset(&array, 64);
+	check_workingset(&array, 4096);
+
 	printk("XArray: %u of %u tests passed\n", tests_passed, tests_run);
 	return (tests_run != tests_passed) ? 0 : -EINVAL;
 }
diff --git a/mm/workingset.c b/mm/workingset.c
index bad4e58881cd..f7fc5456fa77 100644
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
+	struct xa_node *node = container_of(item, struct xa_node, private_list);
+	XA_STATE(xas, node->array, 0);
 	struct address_space *mapping;
-	struct radix_tree_node *node;
-	unsigned int i;
 	int ret;
 
 	/*
@@ -420,14 +420,13 @@ static enum lru_status shadow_lru_isolate(struct list_head *item,
 	 * the shadow node LRU under the i_pages lock and the
 	 * lru_lock.  Because the page cache tree is emptied before
 	 * the inode can be destroyed, holding the lru_lock pins any
-	 * address_space that has radix tree nodes on the LRU.
+	 * address_space that has nodes on the LRU.
 	 *
 	 * We can then safely transition to the i_pages lock to
 	 * pin only the address_space of the particular node we want
 	 * to reclaim, take the node off-LRU, and drop the lru_lock.
 	 */
 
-	node = container_of(item, struct xa_node, private_list);
 	mapping = container_of(node->array, struct address_space, i_pages);
 
 	/* Coming from the list, invert the lock order */
@@ -449,25 +448,17 @@ static enum lru_status shadow_lru_isolate(struct list_head *item,
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
+	xas.xa_node = xa_parent_locked(&mapping->i_pages, node);
+	xas.xa_offset = node->offset;
+	xas.xa_shift = node->shift + XA_CHUNK_SHIFT;
+	xas_set_update(&xas, workingset_update_node);
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
2.17.1
