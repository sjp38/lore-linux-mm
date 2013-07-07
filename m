Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 63AD46B003B
	for <linux-mm@kvack.org>; Sun,  7 Jul 2013 11:57:20 -0400 (EDT)
Received: by mail-lb0-f177.google.com with SMTP id 10so3053235lbf.22
        for <linux-mm@kvack.org>; Sun, 07 Jul 2013 08:57:18 -0700 (PDT)
From: Glauber Costa <glommer@gmail.com>
Subject: [PATCH v10 06/16] lru: add an element to a memcg list
Date: Sun,  7 Jul 2013 11:56:46 -0400
Message-Id: <1373212616-11713-7-git-send-email-glommer@openvz.org>
In-Reply-To: <1373212616-11713-1-git-send-email-glommer@openvz.org>
References: <1373212616-11713-1-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, mgorman@suse.de, david@fromorbit.com, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suze.cz, hannes@cmpxchg.org, hughd@google.com, gthelen@google.com, akpm@linux-foundation.org, Glauber Costa <glommer@openvz.org>, Dave Chinner <dchinner@redhat.com>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>

With the infrastructure we now have, we can add an element to a memcg
LRU list instead of the global list. The memcg lists are still
per-node.

Technically, we will never trigger per-node shrinking if the memcg is
short of memory. Therefore an alternative to this would be to add the
element to *both* a single-node memcg array and a per-node global array.

There are two main reasons for this design choice:

1) adding an extra list_head to each of the objects would waste 16-bytes
per object, always remembering that we are talking about 1 dentry + 1
inode in the common case. This means a close to 10 % increase in the
dentry size, and a lower yet significant increase in the inode size. In
terms of total memory, this design pays 32-byte per-superblock-per-node
(size of struct list_lru_node), which means that in any scenario where
we have more than 10 dentries + inodes, we would already be paying more
memory in the two-list-heads approach than we will here with 1 node x 10
superblocks. The turning point of course depends on the workload, but I
hope the figures above would convince you that the memory footprint is
in my side in any workload that matters.

2) The main drawback of this, namely, that we lose global LRU order, is
not really seen by me as a disadvantage: if we are using memcg to
isolate the workloads, global pressure should try to balance the amount
reclaimed from all memcgs the same way the shrinkers will already
naturally balance the amount reclaimed from each superblock. (This
patchset needs some love in this regard, btw).

To help us easily track down which nodes have and which nodes don't
have elements in the list, we will use an auxiliary node bitmap at
the global level.

[ v11: correctly deal with compound pages ]
[ v8: create LRUs before creating caches, and avoid races in which
  elements are added to a non existing LRU ]
[ v2: move memcg_kmem_lru_of_page to list_lru.c and then unpublish the
  auxiliary functions it uses ]
Signed-off-by: Glauber Costa <glommer@openvz.org>
Cc: Dave Chinner <dchinner@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Hugh Dickins <hughd@google.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 include/linux/list_lru.h   |  11 +++++
 include/linux/memcontrol.h |   7 +++
 mm/list_lru.c              | 110 +++++++++++++++++++++++++++++++++++++++++----
 mm/memcontrol.c            |  28 +++++++++++-
 4 files changed, 146 insertions(+), 10 deletions(-)

diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
index 24a6d58..e7a1199 100644
--- a/include/linux/list_lru.h
+++ b/include/linux/list_lru.h
@@ -46,11 +46,22 @@ struct list_lru_array {
 struct list_lru {
 	struct list_lru_node	*node;
 	nodemask_t		active_nodes;
+	atomic_long_t		node_totals[MAX_NUMNODES];
 #ifdef CONFIG_MEMCG_KMEM
 	/* All memcg-aware LRUs will be chained in the lrus list */
 	struct list_head	lrus;
 	/* M x N matrix as described above */
 	struct list_lru_array	**memcg_lrus;
+	/*
+	 * The memcg_lrus is RCU protected, so we need to keep the previous
+	 * array around when we update it. But we can only do that after
+	 * synchronize_rcu(). A typical system has many LRUs, which means
+	 * that if we call synchronize_rcu after each LRU update, this
+	 * will become very expensive. We add this pointer here, and then
+	 * after all LRUs are updated, we call synchronize_rcu() once, and
+	 * free all the old_arrays.
+	 */
+	void *old_array;
 #endif
 };
 
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 0015ba4..e069d53 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -473,6 +473,8 @@ __memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp);
 
 int memcg_init_lru(struct list_lru *lru, bool memcg_enabled);
 
+struct mem_cgroup *mem_cgroup_from_kmem_page(struct page *page);
+
 int memcg_kmem_update_lru_size(struct list_lru *lru, int num_groups,
 			       bool new_lru);
 
@@ -644,6 +646,11 @@ static inline int memcg_init_lru(struct list_lru *lru, bool memcg_enabled)
 {
 	return 0;
 }
+
+static inline struct mem_cgroup *mem_cgroup_from_kmem_page(struct page *page)
+{
+	return NULL;
+}
 #endif /* CONFIG_MEMCG_KMEM */
 #endif /* _LINUX_MEMCONTROL_H */
 
diff --git a/mm/list_lru.c b/mm/list_lru.c
index 96b0c1e..bdd97cf 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -11,16 +11,90 @@
 #include <linux/slab.h>
 #include <linux/memcontrol.h>
 
+/*
+ * lru_node_of_index - returns the node-lru of a specific lru
+ * @lru: the global lru we are operating at
+ * @index: if positive, the memcg id. If negative, means global lru.
+ * @nid: node id of the corresponding node we want to manipulate
+ */
+static struct list_lru_node *
+lru_node_of_index(struct list_lru *lru, int index, int nid)
+{
+#ifdef CONFIG_MEMCG_KMEM
+	struct list_lru_node *nlru;
+
+	if (index < 0)
+		return &lru->node[nid];
+
+	/*
+	 * If we reach here with index >= 0, it means the page where the object
+	 * comes from is associated with a memcg. Because memcg_lrus is
+	 * populated before the caches, we can be sure that this request is
+	 * truly for an LRU list that does not have memcg caches.
+	 */
+	if (!lru->memcg_lrus)
+		return &lru->node[nid];
+
+	/*
+	 * Because we will only ever free the memcg_lrus after synchronize_rcu,
+	 * we are safe with the rcu lock here: even if we are operating in the
+	 * stale version of the array, the data is still valid and we are not
+	 * risking anything.
+	 *
+	 * The read barrier is needed to make sure that we see the pointer
+	 * assigment for the specific memcg
+	 */
+	rcu_read_lock();
+	rmb();
+	/*
+	 * The array exists, but the particular memcg does not. That is an
+	 * impossible situation: it would mean we are trying to add to a list
+	 * belonging to a memcg that does not exist. Either it wasn't created or
+	 * has been already freed. In both cases it should no longer have
+	 * objects. BUG_ON to avoid a NULL dereference.
+	 */
+	BUG_ON(!lru->memcg_lrus[index]);
+	nlru = &lru->memcg_lrus[index]->node[nid];
+	rcu_read_unlock();
+	return nlru;
+#else
+	BUG_ON(index >= 0); /* nobody should be passing index < 0 with !KMEM */
+	return &lru->node[nid];
+#endif
+}
+
+struct list_lru_node *
+memcg_kmem_lru_of_page(struct list_lru *lru, struct page *page)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_kmem_page(page);
+	int nid = page_to_nid(page);
+	int memcg_id;
+
+	if (!memcg || !memcg_kmem_is_active(memcg))
+		return &lru->node[nid];
+
+	memcg_id = memcg_cache_id(memcg);
+	return lru_node_of_index(lru, memcg_id, nid);
+}
+
 bool list_lru_add(struct list_lru *lru, struct list_head *item)
 {
-	int nid = page_to_nid(virt_to_page(item));
-	struct list_lru_node *nlru = &lru->node[nid];
+	struct page *page = virt_to_page(item);
+	int nid = page_to_nid(page);
+	struct list_lru_node *nlru;
+
+	nlru = memcg_kmem_lru_of_page(lru, page);
 
 	spin_lock(&nlru->lock);
 	WARN_ON_ONCE(nlru->nr_items < 0);
 	if (list_empty(item)) {
 		list_add_tail(item, &nlru->list);
-		if (nlru->nr_items++ == 0)
+		nlru->nr_items++;
+		/*
+		 * We only consider a node active or inactive based on the
+		 * total figure for all memcg list_lrus in this node.
+		 */
+		if (atomic_long_add_return(1, &lru->node_totals[nid]) == 1)
 			node_set(nid, lru->active_nodes);
 		spin_unlock(&nlru->lock);
 		return true;
@@ -32,13 +106,17 @@ EXPORT_SYMBOL_GPL(list_lru_add);
 
 bool list_lru_del(struct list_lru *lru, struct list_head *item)
 {
-	int nid = page_to_nid(virt_to_page(item));
-	struct list_lru_node *nlru = &lru->node[nid];
+	struct page *page = virt_to_page(item);
+	struct list_lru_node *nlru;
+	int nid = page_to_nid(page);
+
+	nlru = memcg_kmem_lru_of_page(lru, page);
 
 	spin_lock(&nlru->lock);
 	if (!list_empty(item)) {
 		list_del_init(item);
-		if (--nlru->nr_items == 0)
+		nlru->nr_items--;
+		if (atomic_long_dec_and_test(&lru->node_totals[nid]))
 			node_clear(nid, lru->active_nodes);
 		WARN_ON_ONCE(nlru->nr_items < 0);
 		spin_unlock(&nlru->lock);
@@ -88,9 +166,10 @@ restart:
 		ret = isolate(item, &nlru->lock, cb_arg);
 		switch (ret) {
 		case LRU_REMOVED:
-			if (--nlru->nr_items == 0)
-				node_clear(nid, lru->active_nodes);
+			nlru->nr_items--;
 			WARN_ON_ONCE(nlru->nr_items < 0);
+			if (atomic_long_dec_and_test(&lru->node_totals[nid]))
+				node_clear(nid, lru->active_nodes);
 			isolated++;
 			break;
 		case LRU_ROTATE:
@@ -171,6 +250,17 @@ int memcg_update_all_lrus(unsigned long num)
 			goto out;
 	}
 out:
+	/*
+	 * Even if we were to use call_rcu, we still have to keep the old array
+	 * pointer somewhere. It is easier for us to just synchronize rcu here.
+	 * Now we guarantee that there are no more users of old_array, and
+	 * proceed freeing it for all LRUs.
+	 */
+	synchronize_rcu();
+	list_for_each_entry(lru, &all_memcg_lrus, lrus) {
+		kfree(lru->old_array);
+		lru->old_array = NULL;
+	}
 	mutex_unlock(&all_memcg_lrus_mutex);
 	return ret;
 }
@@ -219,8 +309,10 @@ int __list_lru_init(struct list_lru *lru, bool memcg_enabled)
 		return -ENOMEM;
 
 	nodes_clear(lru->active_nodes);
-	for (i = 0; i < nr_node_ids; i++)
+	for (i = 0; i < nr_node_ids; i++) {
 		list_lru_init_one(&lru->node[i]);
+		atomic_long_set(&lru->node_totals[i], 0);
+	}
 
 	/*
 	 * We need the memcg_create_mutex and the all_memcgs_lrus_mutex held
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 9d71e60..f6b64e8 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3332,9 +3332,15 @@ int memcg_kmem_update_lru_size(struct list_lru *lru, int num_groups,
 		 * either follow the new array or the old one and they contain
 		 * exactly the same information. The new space at the end is
 		 * always empty anyway.
+		 *
+		 * We do have to make sure that no more users of the old
+		 * memcg_lrus array exist before we free, and this is achieved
+		 * by rcu. Since it would be too slow to synchronize RCU for
+		 * every LRU, we store the pointer and let the LRU code free
+		 * all of them when all LRUs are updated.
 		 */
 		if (lru->memcg_lrus)
-			kfree(old_array);
+			lru->old_array = old_array;
 	}
 
 	if (lru->memcg_lrus) {
@@ -3442,6 +3448,26 @@ out:
 	kfree(s->memcg_params);
 }
 
+struct mem_cgroup *mem_cgroup_from_kmem_page(struct page *page)
+{
+	struct page_cgroup *pc;
+	struct mem_cgroup *memcg = NULL;
+
+	/*
+	 * Because we mark the page at commit time after the allocation has
+	 * succeeded, only the head page of a compound page will be marked
+	 */
+	pc = lookup_page_cgroup(compound_head(page));
+	if (!PageCgroupUsed(pc))
+		return NULL;
+
+	lock_page_cgroup(pc);
+	if (PageCgroupUsed(pc))
+		memcg = pc->mem_cgroup;
+	unlock_page_cgroup(pc);
+	return memcg;
+}
+
 static void kmem_cache_destroy_work_func(struct work_struct *w)
 {
 	struct kmem_cache *cachep;
-- 
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
