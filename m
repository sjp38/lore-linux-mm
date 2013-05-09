Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id E525E6B009A
	for <linux-mm@kvack.org>; Thu,  9 May 2013 02:07:26 -0400 (EDT)
From: Glauber Costa <glommer@openvz.org>
Subject: [PATCH v5 23/31] lru: add an element to a memcg list
Date: Thu,  9 May 2013 10:06:40 +0400
Message-Id: <1368079608-5611-24-git-send-email-glommer@openvz.org>
In-Reply-To: <1368079608-5611-1-git-send-email-glommer@openvz.org>
References: <1368079608-5611-1-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, hughd@google.com, Greg Thelen <gthelen@google.com>, linux-fsdevel@vger.kernel.org, Glauber Costa <glommer@openvz.org>, Dave Chinner <dchinner@redhat.com>, Rik van Riel <riel@redhat.com>

With the infrastructure we now have, we can add an element to a memcg
LRU list instead of the global list. The memcg lists are still
per-node.

Technically, we will never trigger per-node shrinking in the memcg is
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

2) The main drawback of this, namely, that we loose global LRU order, is
not really seen by me as a disadvantage: if we are using memcg to
isolate the workloads, global pressure should try to balance the amount
reclaimed from all memcgs the same way the shrinkers will already
naturally balance the amount reclaimed from each superblock. (This
patchset needs some love in this regard, btw).

To help us easily tracking down which nodes have and which nodes doesn't
have elements in the list, we will count on an auxiliary node bitmap in
the global level.

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
 include/linux/memcontrol.h |   8 ++++
 lib/list_lru.c             | 104 +++++++++++++++++++++++++++++++++++++++++----
 mm/memcontrol.c            |  24 ++++++++++-
 4 files changed, 137 insertions(+), 10 deletions(-)

diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
index 7eb562c..1d2a618 100644
--- a/include/linux/list_lru.h
+++ b/include/linux/list_lru.h
@@ -43,12 +43,23 @@ struct list_lru_array {
 
 struct list_lru {
 	struct list_lru_node	node[MAX_NUMNODES];
+	atomic_long_t		node_totals[MAX_NUMNODES];
 	nodemask_t		active_nodes;
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
+	 * after all LRUs are update, we call synchronize_rcu() once, and
+	 * free all the old_arrays.
+	 */
+	void *old_array;
 #endif
 };
 
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index ee3199d..1e74610 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -24,6 +24,7 @@
 #include <linux/hardirq.h>
 #include <linux/jump_label.h>
 #include <linux/list_lru.h>
+#include <linux/mm.h>
 
 struct mem_cgroup;
 struct page_cgroup;
@@ -473,6 +474,8 @@ __memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp);
 int memcg_new_lru(struct list_lru *lru);
 int memcg_init_lru(struct list_lru *lru);
 
+struct mem_cgroup *mem_cgroup_from_kmem_page(struct page *page);
+
 int memcg_kmem_update_lru_size(struct list_lru *lru, int num_groups,
 			       bool new_lru);
 
@@ -644,6 +647,11 @@ static inline int memcg_init_lru(struct list_lru *lru)
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
 
diff --git a/lib/list_lru.c b/lib/list_lru.c
index 1cefd6c..b65e48d 100644
--- a/lib/list_lru.c
+++ b/lib/list_lru.c
@@ -14,19 +14,85 @@
 #include <linux/list_lru.h>
 #include <linux/memcontrol.h>
 
+/*
+ * lru_node_of_index - returns the node-lru of a specific lru
+ * @lru: the global lru we are operating at
+ * @index: if positive, the memcg id. If negative, means global lru.
+ * @nid: node id of the corresponding node we want to manipulate
+ */
+struct list_lru_node *
+lru_node_of_index(struct list_lru *lru, int index, int nid)
+{
+#ifdef CONFIG_MEMCG_KMEM
+	struct list_lru_node *nlru;
+
+	if (index < 0)
+		return &lru->node[nid];
+
+	if (!lru->memcg_lrus)
+		return NULL;
+
+	/*
+	 * because we will only ever free the memcg_lrus after synchronize_rcu,
+	 * we are safe with the rcu lock here: even if we are operating in the
+	 * stale version of the array, the data is still valid and we are not
+	 * risking anything.
+	 *
+	 * The read barrier is needed to make sure that we see the pointer
+	 * assigment for the specific memcg
+	 */
+	rcu_read_lock();
+	rmb();
+	/* The array exist, but the particular memcg does not */
+	if (!lru->memcg_lrus[index]) {
+		nlru = NULL;
+		goto out;
+	}
+	nlru = &lru->memcg_lrus[index]->node[nid];
+out:
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
 int
 list_lru_add(
 	struct list_lru	*lru,
 	struct list_head *item)
 {
-	int nid = page_to_nid(virt_to_page(item));
-	struct list_lru_node *nlru = &lru->node[nid];
+	struct page *page = virt_to_page(item);
+	struct list_lru_node *nlru;
+	int nid = page_to_nid(page);
+
+	nlru = memcg_kmem_lru_of_page(lru, page);
 
 	spin_lock(&nlru->lock);
 	BUG_ON(nlru->nr_items < 0);
 	if (list_empty(item)) {
 		list_add_tail(item, &nlru->list);
-		if (nlru->nr_items++ == 0)
+		nlru->nr_items++;
+		/*
+		 * We only consider a node active or inactive based on the
+		 * total figure for all involved children.
+		 */
+		if (atomic_long_add_return(1, &lru->node_totals[nid]) == 1)
 			node_set(nid, lru->active_nodes);
 		spin_unlock(&nlru->lock);
 		return 1;
@@ -41,14 +107,20 @@ list_lru_del(
 	struct list_lru	*lru,
 	struct list_head *item)
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
+
+		if (atomic_long_dec_and_test(&lru->node_totals[nid]))
 			node_clear(nid, lru->active_nodes);
+
 		BUG_ON(nlru->nr_items < 0);
 		spin_unlock(&nlru->lock);
 		return 1;
@@ -102,9 +174,10 @@ restart:
 		ret = isolate(item, &nlru->lock, cb_arg);
 		switch (ret) {
 		case LRU_REMOVED:
-			if (--nlru->nr_items == 0)
-				node_clear(nid, lru->active_nodes);
+			nlru->nr_items--;
 			BUG_ON(nlru->nr_items < 0);
+			if (atomic_long_dec_and_test(&lru->node_totals[nid]))
+				node_clear(nid, lru->active_nodes);
 			isolated++;
 			break;
 		case LRU_ROTATE:
@@ -246,6 +319,17 @@ int memcg_update_all_lrus(unsigned long num)
 			goto out;
 	}
 out:
+	/*
+	 * Even if we were to use call_rcu, we still have to keep the old array
+	 * pointer somewhere. It is easier for us to just synchronize rcu here
+	 * since we are in a fine context. Now we guarantee that there are no
+	 * more users of old_array, and proceed freeing it for all LRUs
+	 */
+	synchronize_rcu();
+	list_for_each_entry(lru, &all_memcg_lrus, lrus) {
+		kfree(lru->old_array);
+		lru->old_array = NULL;
+	}
 	mutex_unlock(&all_memcg_lrus_mutex);
 	return ret;
 }
@@ -276,8 +360,10 @@ int __list_lru_init(struct list_lru *lru, bool memcg_enabled)
 	int i;
 
 	nodes_clear(lru->active_nodes);
-	for (i = 0; i < MAX_NUMNODES; i++)
+	for (i = 0; i < MAX_NUMNODES; i++) {
 		list_lru_init_one(&lru->node[i]);
+		atomic_long_set(&lru->node_totals[i], 0);
+	}
 
 	if (memcg_enabled)
 		return memcg_init_lru(lru);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 8a9a898..21e0ace 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3261,9 +3261,15 @@ int memcg_kmem_update_lru_size(struct list_lru *lru, int num_groups,
 		 * either follow the new array or the old one and they contain
 		 * exactly the same information. The new space in the end is
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
@@ -3407,6 +3413,22 @@ static inline void memcg_resume_kmem_account(void)
 	current->memcg_kmem_skip_account--;
 }
 
+struct mem_cgroup *mem_cgroup_from_kmem_page(struct page *page)
+{
+	struct page_cgroup *pc;
+	struct mem_cgroup *memcg = NULL;
+
+	pc = lookup_page_cgroup(page);
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
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
