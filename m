Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id B55DC6B0009
	for <linux-mm@kvack.org>; Sun, 24 Jan 2016 11:56:27 -0500 (EST)
Received: by mail-pf0-f173.google.com with SMTP id e65so69306771pfe.0
        for <linux-mm@kvack.org>; Sun, 24 Jan 2016 08:56:27 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id fd2si45456pab.194.2016.01.24.08.56.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 24 Jan 2016 08:56:26 -0800 (PST)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH v2] mm: workingset: make workingset detection logic memcg aware
Date: Sun, 24 Jan 2016 19:56:16 +0300
Message-ID: <1453654576-8371-1-git-send-email-vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Currently, inactive_age is maintained per zone, which results in
unexpected file page activations in case memory cgroups are used. For
example, if the total number of active pages is big, a memory cgroup
might get every refaulted file page activated even if refault distance
is much greater than the number of active file pages in the cgroup. This
patch fixes this issue by making inactive_age per lruvec.

The patch is pretty straightforward and self-explaining, but there are
two things that should be noted:

 - workingset_{eviction,activation} need to get lruvec given a page.
   On the default hierarchy one can safely access page->mem_cgroup
   provided the page is pinned, but on the legacy hierarchy a page can
   be migrated from one cgroup to another at any moment, so extra care
   must be taken to assure page->mem_cgroup will stay put.

   workingset_eviction is passed a locked page, so it is safe to use
   page->mem_cgroup in this function. workingset_activation is trickier:
   it is called from mark_page_accessed, where the page is not
   necessarily locked. To protect it against page->mem_cgroup change, we
   move it to __activate_page, which is called by mark_page_accessed
   once there's enough pages on percpu pagevec. This function is called
   with zone->lru_lock held, which rules out page charge migration.

 - To calculate refault distance correctly even in case a page is
   refaulted by a different cgroup, we need to store memcg id in shadow
   entry. There's no problem with it on 64-bit, but on 32-bit there's
   not much space left in radix tree slot after storing information
   about node, zone, and memory cgroup, so we can't just save eviction
   counter as is, because it would trim max refault distance making it
   unusable.

   To overcome this problem, we increase refault distance granularity,
   as proposed by Johannes Weiner. We disregard 10 least significant
   bits of eviction counter. This reduces refault distance accuracy to
   4MB, which is still fine. With the default NODE_SHIFT (3) this leaves
   us 9 bits for storing eviction counter, hence maximal refault
   distance will be 2GB, which should be enough for 32-bit systems.

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
Changes from v1:
 - Handle refaults by different cgroups properly (Johannes).

v1: http://www.spinics.net/lists/linux-mm/msg92466.html

 include/linux/memcontrol.h |  44 ++++++++++++++++
 include/linux/mmzone.h     |   7 +--
 include/linux/swap.h       |   1 +
 mm/memcontrol.c            |  25 ---------
 mm/swap.c                  |   5 +-
 mm/truncate.c              |   1 +
 mm/workingset.c            | 125 ++++++++++++++++++++++++++++++++++++++++-----
 7 files changed, 166 insertions(+), 42 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 9ae48d4aeb5e..fd67027bf2e7 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -366,6 +366,42 @@ static inline bool mem_cgroup_online(struct mem_cgroup *memcg)
 }
 
 /*
+ * We restrict the id in the range of [1, 65535], so it can fit into
+ * an unsigned short.
+ */
+#define MEM_CGROUP_ID_SHIFT	16
+#define MEM_CGROUP_ID_MAX	((1 << MEM_CGROUP_ID_SHIFT) - 1)
+
+static inline unsigned short mem_cgroup_id(struct mem_cgroup *memcg)
+{
+	return memcg->css.id;
+}
+
+/*
+ * A helper function to get mem_cgroup from ID. must be called under
+ * rcu_read_lock().  The caller is responsible for calling
+ * css_tryget_online() if the mem_cgroup is used for charging. (dropping
+ * refcnt from swap can be called against removed memcg.)
+ */
+static inline struct mem_cgroup *mem_cgroup_from_id(unsigned short id)
+{
+	struct cgroup_subsys_state *css;
+
+	css = css_from_id(id, &memory_cgrp_subsys);
+	return mem_cgroup_from_css(css);
+}
+
+static inline void mem_cgroup_get(struct mem_cgroup *memcg)
+{
+	css_get(&memcg->css);
+}
+
+static inline void mem_cgroup_put(struct mem_cgroup *memcg)
+{
+	css_put(&memcg->css);
+}
+
+/*
  * For memory reclaim.
  */
 int mem_cgroup_select_victim_node(struct mem_cgroup *memcg);
@@ -590,6 +626,14 @@ static inline bool mem_cgroup_online(struct mem_cgroup *memcg)
 	return true;
 }
 
+static inline void mem_cgroup_get(struct mem_cgroup *memcg)
+{
+}
+
+static inline void mem_cgroup_put(struct mem_cgroup *memcg)
+{
+}
+
 static inline bool
 mem_cgroup_inactive_anon_is_low(struct lruvec *lruvec)
 {
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 7b6c2cfee390..684368ccea50 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -211,6 +211,10 @@ struct zone_reclaim_stat {
 struct lruvec {
 	struct list_head lists[NR_LRU_LISTS];
 	struct zone_reclaim_stat reclaim_stat;
+
+	/* Evictions & activations on the inactive file list */
+	atomic_long_t		inactive_age;
+
 #ifdef CONFIG_MEMCG
 	struct zone *zone;
 #endif
@@ -487,9 +491,6 @@ struct zone {
 	spinlock_t		lru_lock;
 	struct lruvec		lruvec;
 
-	/* Evictions & activations on the inactive file list */
-	atomic_long_t		inactive_age;
-
 	/*
 	 * When free pages are below this point, additional steps are taken
 	 * when reading the number of free pages to avoid per-cpu counter
diff --git a/include/linux/swap.h b/include/linux/swap.h
index b14a2bb33514..b3713332c754 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -252,6 +252,7 @@ struct swap_info_struct {
 void *workingset_eviction(struct address_space *mapping, struct page *page);
 bool workingset_refault(void *shadow);
 void workingset_activation(struct page *page);
+void workingset_release_shadow(void *shadow);
 extern struct list_lru workingset_shadow_nodes;
 
 static inline unsigned int workingset_node_pages(struct radix_tree_node *node)
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d06cae2de783..4ea79f225fe8 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -268,31 +268,6 @@ static inline bool mem_cgroup_is_root(struct mem_cgroup *memcg)
 	return (memcg == root_mem_cgroup);
 }
 
-/*
- * We restrict the id in the range of [1, 65535], so it can fit into
- * an unsigned short.
- */
-#define MEM_CGROUP_ID_MAX	USHRT_MAX
-
-static inline unsigned short mem_cgroup_id(struct mem_cgroup *memcg)
-{
-	return memcg->css.id;
-}
-
-/*
- * A helper function to get mem_cgroup from ID. must be called under
- * rcu_read_lock().  The caller is responsible for calling
- * css_tryget_online() if the mem_cgroup is used for charging. (dropping
- * refcnt from swap can be called against removed memcg.)
- */
-static inline struct mem_cgroup *mem_cgroup_from_id(unsigned short id)
-{
-	struct cgroup_subsys_state *css;
-
-	css = css_from_id(id, &memory_cgrp_subsys);
-	return mem_cgroup_from_css(css);
-}
-
 #ifndef CONFIG_SLOB
 /*
  * This will be the memcg's index in each cache's ->memcg_params.memcg_caches.
diff --git a/mm/swap.c b/mm/swap.c
index 09fe5e97714a..4b5d7a1f9742 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -270,6 +270,9 @@ static void __activate_page(struct page *page, struct lruvec *lruvec,
 
 		__count_vm_event(PGACTIVATE);
 		update_page_reclaim_stat(lruvec, file, 1);
+
+		if (file)
+			workingset_activation(page);
 	}
 }
 
@@ -375,8 +378,6 @@ void mark_page_accessed(struct page *page)
 		else
 			__lru_cache_activate_page(page);
 		ClearPageReferenced(page);
-		if (page_is_file_cache(page))
-			workingset_activation(page);
 	} else if (!PageReferenced(page)) {
 		SetPageReferenced(page);
 	}
diff --git a/mm/truncate.c b/mm/truncate.c
index e3ee0e27cd17..a8bae846d399 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -52,6 +52,7 @@ static void clear_exceptional_entry(struct address_space *mapping,
 			goto unlock;
 		radix_tree_replace_slot(slot, NULL);
 		mapping->nrexceptional--;
+		workingset_release_shadow(entry);
 		if (!node)
 			goto unlock;
 		workingset_node_shadows_dec(node);
diff --git a/mm/workingset.c b/mm/workingset.c
index 61ead9e5549d..30298eaee397 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -142,7 +142,7 @@
  *		Implementation
  *
  * For each zone's file LRU lists, a counter for inactive evictions
- * and activations is maintained (zone->inactive_age).
+ * and activations is maintained (lruvec->inactive_age).
  *
  * On eviction, a snapshot of this counter (along with some bits to
  * identify the zone) is stored in the now empty page cache radix tree
@@ -152,8 +152,72 @@
  * refault distance will immediately activate the refaulting page.
  */
 
-static void *pack_shadow(unsigned long eviction, struct zone *zone)
+#ifdef CONFIG_MEMCG
+/*
+ * On 32-bit there is not much space left in radix tree slot after
+ * storing information about node, zone, and memory cgroup, so we
+ * disregard 10 least significant bits of eviction counter. This
+ * reduces refault distance accuracy to 4MB, which is still fine.
+ *
+ * With the default NODE_SHIFT (3) this leaves us 9 bits for storing
+ * eviction counter, hence maximal refault distance will be 2GB, which
+ * should be enough for 32-bit systems.
+ */
+#ifdef CONFIG_64BIT
+# define REFAULT_DISTANCE_GRANULARITY		0
+#else
+# define REFAULT_DISTANCE_GRANULARITY		10
+#endif
+
+static unsigned long pack_shadow_memcg(unsigned long eviction,
+				       struct mem_cgroup *memcg)
+{
+	if (mem_cgroup_disabled())
+		return eviction;
+
+	eviction >>= REFAULT_DISTANCE_GRANULARITY;
+	eviction = (eviction << MEM_CGROUP_ID_SHIFT) | mem_cgroup_id(memcg);
+	return eviction;
+}
+
+static unsigned long unpack_shadow_memcg(unsigned long entry,
+					 unsigned long *mask,
+					 struct mem_cgroup **memcg)
+{
+	if (mem_cgroup_disabled()) {
+		*memcg = NULL;
+		return entry;
+	}
+
+	rcu_read_lock();
+	*memcg = mem_cgroup_from_id(entry & MEM_CGROUP_ID_MAX);
+	rcu_read_unlock();
+
+	entry >>= MEM_CGROUP_ID_SHIFT;
+	entry <<= REFAULT_DISTANCE_GRANULARITY;
+	*mask >>= MEM_CGROUP_ID_SHIFT - REFAULT_DISTANCE_GRANULARITY;
+	return entry;
+}
+#else /* !CONFIG_MEMCG */
+static unsigned long pack_shadow_memcg(unsigned long eviction,
+				       struct mem_cgroup *memcg)
+{
+	return eviction;
+}
+
+static unsigned long unpack_shadow_memcg(unsigned long entry,
+					 unsigned long *mask,
+					 struct mem_cgroup **memcg)
+{
+	*memcg = NULL;
+	return entry;
+}
+#endif /* CONFIG_MEMCG */
+
+static void *pack_shadow(unsigned long eviction, struct zone *zone,
+			 struct mem_cgroup *memcg)
 {
+	eviction = pack_shadow_memcg(eviction, memcg);
 	eviction = (eviction << NODES_SHIFT) | zone_to_nid(zone);
 	eviction = (eviction << ZONES_SHIFT) | zone_idx(zone);
 	eviction = (eviction << RADIX_TREE_EXCEPTIONAL_SHIFT);
@@ -163,6 +227,7 @@ static void *pack_shadow(unsigned long eviction, struct zone *zone)
 
 static void unpack_shadow(void *shadow,
 			  struct zone **zone,
+			  struct mem_cgroup **memcg,
 			  unsigned long *distance)
 {
 	unsigned long entry = (unsigned long)shadow;
@@ -170,19 +235,23 @@ static void unpack_shadow(void *shadow,
 	unsigned long refault;
 	unsigned long mask;
 	int zid, nid;
+	struct lruvec *lruvec;
 
 	entry >>= RADIX_TREE_EXCEPTIONAL_SHIFT;
 	zid = entry & ((1UL << ZONES_SHIFT) - 1);
 	entry >>= ZONES_SHIFT;
 	nid = entry & ((1UL << NODES_SHIFT) - 1);
 	entry >>= NODES_SHIFT;
-	eviction = entry;
 
-	*zone = NODE_DATA(nid)->node_zones + zid;
-
-	refault = atomic_long_read(&(*zone)->inactive_age);
 	mask = ~0UL >> (NODES_SHIFT + ZONES_SHIFT +
 			RADIX_TREE_EXCEPTIONAL_SHIFT);
+
+	eviction = unpack_shadow_memcg(entry, &mask, memcg);
+
+	*zone = NODE_DATA(nid)->node_zones + zid;
+	lruvec = mem_cgroup_zone_lruvec(*zone, *memcg);
+
+	refault = atomic_long_read(&lruvec->inactive_age);
 	/*
 	 * The unsigned subtraction here gives an accurate distance
 	 * across inactive_age overflows in most cases.
@@ -213,10 +282,16 @@ static void unpack_shadow(void *shadow,
 void *workingset_eviction(struct address_space *mapping, struct page *page)
 {
 	struct zone *zone = page_zone(page);
+	struct mem_cgroup *memcg = page_memcg(page);
+	struct lruvec *lruvec;
 	unsigned long eviction;
 
-	eviction = atomic_long_inc_return(&zone->inactive_age);
-	return pack_shadow(eviction, zone);
+	if (!mem_cgroup_disabled())
+		mem_cgroup_get(memcg);
+
+	lruvec = mem_cgroup_zone_lruvec(zone, memcg);
+	eviction = atomic_long_inc_return(&lruvec->inactive_age);
+	return pack_shadow(eviction, zone, memcg);
 }
 
 /**
@@ -230,13 +305,22 @@ void *workingset_eviction(struct address_space *mapping, struct page *page)
  */
 bool workingset_refault(void *shadow)
 {
-	unsigned long refault_distance;
+	unsigned long refault_distance, nr_active;
 	struct zone *zone;
+	struct mem_cgroup *memcg;
+	struct lruvec *lruvec;
 
-	unpack_shadow(shadow, &zone, &refault_distance);
+	unpack_shadow(shadow, &zone, &memcg, &refault_distance);
 	inc_zone_state(zone, WORKINGSET_REFAULT);
 
-	if (refault_distance <= zone_page_state(zone, NR_ACTIVE_FILE)) {
+	if (!mem_cgroup_disabled()) {
+		lruvec = mem_cgroup_zone_lruvec(zone, memcg);
+		nr_active = mem_cgroup_get_lru_size(lruvec, LRU_ACTIVE_FILE);
+		mem_cgroup_put(memcg);
+	} else
+		nr_active = zone_page_state(zone, NR_ACTIVE_FILE);
+
+	if (refault_distance <= nr_active) {
 		inc_zone_state(zone, WORKINGSET_ACTIVATE);
 		return true;
 	}
@@ -249,7 +333,23 @@ bool workingset_refault(void *shadow)
  */
 void workingset_activation(struct page *page)
 {
-	atomic_long_inc(&page_zone(page)->inactive_age);
+	struct lruvec *lruvec;
+
+	lruvec = mem_cgroup_page_lruvec(page, page_zone(page));
+	atomic_long_inc(&lruvec->inactive_age);
+}
+
+void workingset_release_shadow(void *shadow)
+{
+	unsigned long refault_distance;
+	struct zone *zone;
+	struct mem_cgroup *memcg;
+
+	if (mem_cgroup_disabled())
+		return;
+
+	unpack_shadow(shadow, &zone, &memcg, &refault_distance);
+	mem_cgroup_put(memcg);
 }
 
 /*
@@ -348,6 +448,7 @@ static enum lru_status shadow_lru_isolate(struct list_head *item,
 	for (i = 0; i < RADIX_TREE_MAP_SIZE; i++) {
 		if (node->slots[i]) {
 			BUG_ON(!radix_tree_exceptional_entry(node->slots[i]));
+			workingset_release_shadow(node->slots[i]);
 			node->slots[i] = NULL;
 			BUG_ON(node->count < (1U << RADIX_TREE_COUNT_SHIFT));
 			node->count -= 1U << RADIX_TREE_COUNT_SHIFT;
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
