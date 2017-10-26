Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id E0A786B0033
	for <linux-mm@kvack.org>; Thu, 26 Oct 2017 19:49:09 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id u27so3416994pfg.12
        for <linux-mm@kvack.org>; Thu, 26 Oct 2017 16:49:09 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id z28si4034287pgc.445.2017.10.26.16.49.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Oct 2017 16:49:08 -0700 (PDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH] mm: Simplify and batch working set shadow pages LRU isolation locking
Date: Thu, 26 Oct 2017 16:48:54 -0700
Message-Id: <20171026234854.25764-1-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>

From: Andi Kleen <ak@linux.intel.com>

When shrinking the working set shadow pages LRU we currently
use a complicated hand-over locking scheme. The isolation
function runs under the local lru lock for the list, but
it also needs to take the tree_lock for the address space.

This is done by releasing the lru lock, and then trying
to get the tree_lock and retrying on failure. This happens
for every shadow node.

This pattern is fairly inefficient under contention. The
critical regions are rather small, so when the locks
are contended the cache lines of the locks bounce around a lot,
but there is not enough work to ammortize the communication costs.

We saw some regression on this for post 3.14 kernels compared
to 3.10, where the system time for workloads that thrash mmap
working set went up significantly.

This patch replaces the handover locking with a simpler two-pass
scheme. The isolation function links the shadow nodes into
a private list, which is then processed separately.

The separate processing can also batch tree lock aquisition
if multiple objects in the list are for the same mapping.
This results in more efficient locking, and also avoids
needing to use try lock.

The processing is naturally limited by the scan size of
the shrinker.

The resulting code is simpler (-5 lines total) and faster.

On a microbenchmark that thrashes the working set of a mmap'ed
file on a 2S system with very fast SSDs I see an improvement
of 5% less system time, near all of it spinlock time.

Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 mm/workingset.c | 75 +++++++++++++++++++++++++++------------------------------
 1 file changed, 35 insertions(+), 40 deletions(-)

diff --git a/mm/workingset.c b/mm/workingset.c
index 7119cd745ace..9df9b01dbaf4 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -417,35 +417,34 @@ static enum lru_status shadow_lru_isolate(struct list_head *item,
 					  spinlock_t *lru_lock,
 					  void *arg)
 {
+	struct list_head *list = arg;
+
+	list_lru_isolate(lru, item);
+	list_add(item, list);
+
+	return LRU_REMOVED;
+}
+
+static void free_shadow_node(struct list_head *item, spinlock_t **lock)
+{
+	unsigned int i;
 	struct address_space *mapping;
 	struct radix_tree_node *node;
-	unsigned int i;
-	int ret;
-
-	/*
-	 * Page cache insertions and deletions synchroneously maintain
-	 * the shadow node LRU under the mapping->tree_lock and the
-	 * lru_lock.  Because the page cache tree is emptied before
-	 * the inode can be destroyed, holding the lru_lock pins any
-	 * address_space that has radix tree nodes on the LRU.
-	 *
-	 * We can then safely transition to the mapping->tree_lock to
-	 * pin only the address_space of the particular node we want
-	 * to reclaim, take the node off-LRU, and drop the lru_lock.
-	 */
 
 	node = container_of(item, struct radix_tree_node, private_list);
 	mapping = container_of(node->root, struct address_space, page_tree);
 
-	/* Coming from the list, invert the lock order */
-	if (!spin_trylock(&mapping->tree_lock)) {
-		spin_unlock(lru_lock);
-		ret = LRU_RETRY;
-		goto out;
-	}
+	list_del_init(item);
 
-	list_lru_isolate(lru, item);
-	spin_unlock(lru_lock);
+	/*
+	 * Batch the locks if they are for the same mapping.
+	 */
+	if (*lock != &mapping->tree_lock) {
+		if (*lock)
+			spin_unlock(*lock);
+		*lock = &mapping->tree_lock;
+		spin_lock(*lock);
+	}
 
 	/*
 	 * The nodes should only contain one or more shadow entries,
@@ -453,17 +452,17 @@ static enum lru_status shadow_lru_isolate(struct list_head *item,
 	 * delete and free the empty node afterwards.
 	 */
 	if (WARN_ON_ONCE(!node->exceptional))
-		goto out_invalid;
+		return;
 	if (WARN_ON_ONCE(node->count != node->exceptional))
-		goto out_invalid;
+		return;
 	for (i = 0; i < RADIX_TREE_MAP_SIZE; i++) {
 		if (node->slots[i]) {
 			if (WARN_ON_ONCE(!radix_tree_exceptional_entry(node->slots[i])))
-				goto out_invalid;
+				return;
 			if (WARN_ON_ONCE(!node->exceptional))
-				goto out_invalid;
+				return;
 			if (WARN_ON_ONCE(!mapping->nrexceptional))
-				goto out_invalid;
+				return;
 			node->slots[i] = NULL;
 			node->exceptional--;
 			node->count--;
@@ -471,30 +470,26 @@ static enum lru_status shadow_lru_isolate(struct list_head *item,
 		}
 	}
 	if (WARN_ON_ONCE(node->exceptional))
-		goto out_invalid;
+		return;
 	inc_lruvec_page_state(virt_to_page(node), WORKINGSET_NODERECLAIM);
 	__radix_tree_delete_node(&mapping->page_tree, node,
 				 workingset_update_node, mapping);
-
-out_invalid:
-	spin_unlock(&mapping->tree_lock);
-	ret = LRU_REMOVED_RETRY;
-out:
-	local_irq_enable();
-	cond_resched();
-	local_irq_disable();
-	spin_lock(lru_lock);
-	return ret;
 }
 
 static unsigned long scan_shadow_nodes(struct shrinker *shrinker,
 				       struct shrink_control *sc)
 {
+	struct list_head *tmp, *pos;
 	unsigned long ret;
+	LIST_HEAD(nodes);
+	spinlock_t *lock = NULL;
 
-	/* list_lru lock nests inside IRQ-safe mapping->tree_lock */
+	ret = list_lru_shrink_walk(&shadow_nodes, sc, shadow_lru_isolate, &nodes);
 	local_irq_disable();
-	ret = list_lru_shrink_walk(&shadow_nodes, sc, shadow_lru_isolate, NULL);
+	list_for_each_safe (pos, tmp, &nodes)
+		free_shadow_node(pos, &lock);
+	if (lock)
+		spin_unlock(lock);
 	local_irq_enable();
 	return ret;
 }
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
