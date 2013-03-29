Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id B445C6B0087
	for <linux-mm@kvack.org>; Fri, 29 Mar 2013 05:15:10 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v2 23/28] lru: add an element to a memcg list
Date: Fri, 29 Mar 2013 13:14:05 +0400
Message-Id: <1364548450-28254-24-git-send-email-glommer@parallels.com>
In-Reply-To: <1364548450-28254-1-git-send-email-glommer@parallels.com>
References: <1364548450-28254-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, containers@lists.linux-foundation.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Dave Shrinnker <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, hughd@google.com, yinghan@google.com, Glauber Costa <glommer@parallels.com>, Dave Chinner <dchinner@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>

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

Signed-off-by: Glauber Costa <glommer@parallels.com>
Cc: Dave Chinner <dchinner@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Hugh Dickins <hughd@google.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 include/linux/list_lru.h   | 10 +++++++
 include/linux/memcontrol.h | 10 +++++++
 lib/list_lru.c             | 68 +++++++++++++++++++++++++++++++++++++++-------
 mm/memcontrol.c            | 38 +++++++++++++++++++++++++-
 4 files changed, 115 insertions(+), 11 deletions(-)

diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
index d6cf126..0856899 100644
--- a/include/linux/list_lru.h
+++ b/include/linux/list_lru.h
@@ -26,6 +26,7 @@ struct list_lru_array {
 
 struct list_lru {
 	struct list_lru_node	node[MAX_NUMNODES];
+	atomic_long_t		node_totals[MAX_NUMNODES];
 	nodemask_t		active_nodes;
 #ifdef CONFIG_MEMCG_KMEM
 	struct list_head	lrus;
@@ -40,10 +41,19 @@ int memcg_update_all_lrus(unsigned long num);
 void list_lru_destroy(struct list_lru *lru);
 void list_lru_destroy_memcg(struct mem_cgroup *memcg);
 int __memcg_init_lru(struct list_lru *lru);
+struct list_lru_node *
+lru_node_of_index(struct list_lru *lru, int index, int nid);
 #else
 static inline void list_lru_destroy(struct list_lru *lru)
 {
 }
+
+static inline struct list_lru_node *
+lru_node_of_index(struct list_lru *lru, int index, int nid)
+{
+	BUG_ON(index < 0); /* index != -1 with !MEMCG_KMEM. Impossible */
+	return &lru->node[nid];
+}
 #endif
 
 int __list_lru_init(struct list_lru *lru, bool memcg_enabled);
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index ee3199d..f55f875 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -24,6 +24,7 @@
 #include <linux/hardirq.h>
 #include <linux/jump_label.h>
 #include <linux/list_lru.h>
+#include <linux/mm.h>
 
 struct mem_cgroup;
 struct page_cgroup;
@@ -473,6 +474,9 @@ __memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp);
 int memcg_new_lru(struct list_lru *lru);
 int memcg_init_lru(struct list_lru *lru);
 
+struct list_lru_node *
+memcg_kmem_lru_of_page(struct list_lru *lru, struct page *page);
+
 int memcg_kmem_update_lru_size(struct list_lru *lru, int num_groups,
 			       bool new_lru);
 
@@ -644,6 +648,12 @@ static inline int memcg_init_lru(struct list_lru *lru)
 {
 	return 0;
 }
+
+static inline struct list_lru_node *
+memcg_kmem_lru_of_page(struct list_lru *lru, struct page *page)
+{
+	return &lru->node[page_to_nid(page)];
+}
 #endif /* CONFIG_MEMCG_KMEM */
 #endif /* _LINUX_MEMCONTROL_H */
 
diff --git a/lib/list_lru.c b/lib/list_lru.c
index a9616a0..734ff91 100644
--- a/lib/list_lru.c
+++ b/lib/list_lru.c
@@ -15,14 +15,22 @@ list_lru_add(
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
@@ -37,14 +45,20 @@ list_lru_del(
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
@@ -97,7 +111,9 @@ restart:
 		ret = isolate(item, &nlru->lock, cb_arg);
 		switch (ret) {
 		case 0:	/* item removed from list */
-			if (--nlru->nr_items == 0)
+			nlru->nr_items--;
+
+			if (atomic_long_dec_and_test(&lru->node_totals[nid]))
 				node_clear(nid, lru->active_nodes);
 			BUG_ON(nlru->nr_items < 0);
 			isolated++;
@@ -245,11 +261,41 @@ out:
 	return ret;
 }
 
-void list_lru_destroy(struct list_lru *lru)
+struct list_lru_node *
+lru_node_of_index(struct list_lru *lru, int index, int nid)
 {
+	struct list_lru_node *nlru;
+
+	if (index < 0)
+		return &lru->node[nid];
+
 	if (!lru->memcg_lrus)
-		return;
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
+}
 
+void list_lru_destroy(struct list_lru *lru)
+{
 	mutex_lock(&all_memcg_lrus_mutex);
 	list_del(&lru->lrus);
 	mutex_unlock(&all_memcg_lrus_mutex);
@@ -274,8 +320,10 @@ int __list_lru_init(struct list_lru *lru, bool memcg_enabled)
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
index c6c90d8..89b7ffb 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3160,9 +3160,15 @@ int memcg_kmem_update_lru_size(struct list_lru *lru, int num_groups,
 		 * either follow the new array or the old one and they contain
 		 * exactly the same information. The new space in the end is
 		 * always empty anyway.
+		 *
+		 * We do have to make sure that no more users of the old
+		 * memcg_lrus array exist before we free, and this is achieved
+		 * by the synchronize_lru below.
 		 */
-		if (lru->memcg_lrus)
+		if (lru->memcg_lrus) {
+			synchronize_rcu();
 			kfree(old_array);
+		}
 	}
 
 	if (lru->memcg_lrus) {
@@ -3306,6 +3312,36 @@ static inline void memcg_resume_kmem_account(void)
 	current->memcg_kmem_skip_account--;
 }
 
+static struct mem_cgroup *mem_cgroup_from_kmem_page(struct page *page)
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
+struct list_lru_node *
+memcg_kmem_lru_of_page(struct list_lru *lru, struct page *page)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_kmem_page(page);
+	int nid = page_to_nid(page);
+	int memcg_id;
+
+	if (!memcg_kmem_enabled())
+		return &lru->node[nid];
+
+	memcg_id = memcg_cache_id(memcg);
+	return lru_node_of_index(lru, memcg_id, nid);
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
