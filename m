Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id E0D4B6B007D
	for <linux-mm@kvack.org>; Fri, 16 Jan 2015 09:13:39 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id lf10so24484021pab.5
        for <linux-mm@kvack.org>; Fri, 16 Jan 2015 06:13:39 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id bc8si5486386pad.237.2015.01.16.06.13.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jan 2015 06:13:38 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 6/6] memcg: reparent list_lrus and free kmemcg_id on css offline
Date: Fri, 16 Jan 2015 17:13:06 +0300
Message-ID: <8a3066a28a960e8fb0169b4318ed476a99376831.1421411661.git.vdavydov@parallels.com>
In-Reply-To: <cover.1421411660.git.vdavydov@parallels.com>
References: <cover.1421411660.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Now, the only reason to keep kmemcg_id till css free is list_lru, which
uses it to distribute elements between per-memcg lists. However, it can
be easily sorted out - we only need to change kmemcg_id of an offline
cgroup to its parent's id, making further list_lru_add()'s add elements
to the parent's list, and then move all elements from the offline
cgroup's list to the one of its parent. It will work, because a racing
list_lru_del() does not need to know the list it is deleting the element
from. It can decrement the wrong nr_items counter though, but the
ongoing reparenting will fix it. After list_lru reparenting is done we
are free to release kmemcg_id saving a valuable slot in a per-memcg
array for new cgroups.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/list_lru.h |    3 ++-
 mm/list_lru.c            |   46 +++++++++++++++++++++++++++++++++++++++++++---
 mm/memcontrol.c          |   39 ++++++++++++++++++++++++++++++++++-----
 mm/vmscan.c              |    2 +-
 4 files changed, 80 insertions(+), 10 deletions(-)

diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
index 7edf9c9ab9eb..2a6b9947aaa3 100644
--- a/include/linux/list_lru.h
+++ b/include/linux/list_lru.h
@@ -26,7 +26,7 @@ enum lru_status {
 
 struct list_lru_one {
 	struct list_head	list;
-	/* kept as signed so we can catch imbalance bugs */
+	/* may become negative during memcg reparenting */
 	long			nr_items;
 };
 
@@ -62,6 +62,7 @@ int __list_lru_init(struct list_lru *lru, bool memcg_aware,
 #define list_lru_init_memcg(lru)	__list_lru_init((lru), true, NULL)
 
 int memcg_update_all_list_lrus(int num_memcgs);
+void memcg_drain_all_list_lrus(int src_idx, int dst_idx);
 
 /**
  * list_lru_add: add an element to the lru list's tail
diff --git a/mm/list_lru.c b/mm/list_lru.c
index 8d9d168c6c38..909eca2c820e 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -100,7 +100,6 @@ bool list_lru_add(struct list_lru *lru, struct list_head *item)
 
 	spin_lock(&nlru->lock);
 	l = list_lru_from_kmem(nlru, item);
-	WARN_ON_ONCE(l->nr_items < 0);
 	if (list_empty(item)) {
 		list_add_tail(item, &l->list);
 		l->nr_items++;
@@ -123,7 +122,6 @@ bool list_lru_del(struct list_lru *lru, struct list_head *item)
 	if (!list_empty(item)) {
 		list_del_init(item);
 		l->nr_items--;
-		WARN_ON_ONCE(l->nr_items < 0);
 		spin_unlock(&nlru->lock);
 		return true;
 	}
@@ -156,7 +154,6 @@ static unsigned long __list_lru_count_one(struct list_lru *lru,
 
 	spin_lock(&nlru->lock);
 	l = list_lru_from_memcg_idx(nlru, memcg_idx);
-	WARN_ON_ONCE(l->nr_items < 0);
 	count = l->nr_items;
 	spin_unlock(&nlru->lock);
 
@@ -458,6 +455,49 @@ fail:
 		memcg_cancel_update_list_lru(lru, old_size, new_size);
 	goto out;
 }
+
+static void memcg_drain_list_lru_node(struct list_lru_node *nlru,
+				      int src_idx, int dst_idx)
+{
+	struct list_lru_one *src, *dst;
+
+	/*
+	 * Since list_lru_{add,del} may be called under an IRQ-safe lock,
+	 * we have to use IRQ-safe primitives here to avoid deadlock.
+	 */
+	spin_lock_irq(&nlru->lock);
+
+	src = list_lru_from_memcg_idx(nlru, src_idx);
+	dst = list_lru_from_memcg_idx(nlru, dst_idx);
+
+	list_splice_init(&src->list, &dst->list);
+	dst->nr_items += src->nr_items;
+	src->nr_items = 0;
+
+	spin_unlock_irq(&nlru->lock);
+}
+
+static void memcg_drain_list_lru(struct list_lru *lru,
+				 int src_idx, int dst_idx)
+{
+	int i;
+
+	if (!list_lru_memcg_aware(lru))
+		return;
+
+	for (i = 0; i < nr_node_ids; i++)
+		memcg_drain_list_lru_node(&lru->node[i], src_idx, dst_idx);
+}
+
+void memcg_drain_all_list_lrus(int src_idx, int dst_idx)
+{
+	struct list_lru *lru;
+
+	mutex_lock(&list_lrus_mutex);
+	list_for_each_entry(lru, &list_lrus, list)
+		memcg_drain_list_lru(lru, src_idx, dst_idx);
+	mutex_unlock(&list_lrus_mutex);
+}
 #else
 static int memcg_init_list_lru(struct list_lru *lru, bool memcg_aware)
 {
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b82ddb68ffd6..850e1fdf3ea9 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -347,6 +347,7 @@ struct mem_cgroup {
 #if defined(CONFIG_MEMCG_KMEM)
         /* Index in the kmem_cache->memcg_params.memcg_caches array */
 	int kmemcg_id;
+	bool kmem_acct_activated;
 	bool kmem_acct_active;
 #endif
 
@@ -608,14 +609,10 @@ void memcg_put_cache_ids(void)
 struct static_key memcg_kmem_enabled_key;
 EXPORT_SYMBOL(memcg_kmem_enabled_key);
 
-static void memcg_free_cache_id(int id);
-
 static void disarm_kmem_keys(struct mem_cgroup *memcg)
 {
-	if (memcg->kmemcg_id >= 0) {
+	if (memcg->kmem_acct_activated)
 		static_key_slow_dec(&memcg_kmem_enabled_key);
-		memcg_free_cache_id(memcg->kmemcg_id);
-	}
 	/*
 	 * This check can't live in kmem destruction function,
 	 * since the charges will outlive the cgroup
@@ -3331,6 +3328,7 @@ static int memcg_activate_kmem(struct mem_cgroup *memcg,
 	int memcg_id;
 
 	BUG_ON(memcg->kmemcg_id >= 0);
+	BUG_ON(memcg->kmem_acct_activated);
 	BUG_ON(memcg->kmem_acct_active);
 
 	/*
@@ -3374,6 +3372,7 @@ static int memcg_activate_kmem(struct mem_cgroup *memcg,
 	 * patched.
 	 */
 	memcg->kmemcg_id = memcg_id;
+	memcg->kmem_acct_activated = true;
 	memcg->kmem_acct_active = true;
 out:
 	return err;
@@ -4052,6 +4051,10 @@ static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
 
 static void memcg_deactivate_kmem(struct mem_cgroup *memcg)
 {
+	struct cgroup_subsys_state *css;
+	struct mem_cgroup *parent, *child;
+	int kmemcg_id;
+
 	if (!memcg->kmem_acct_active)
 		return;
 
@@ -4064,6 +4067,32 @@ static void memcg_deactivate_kmem(struct mem_cgroup *memcg)
 	memcg->kmem_acct_active = false;
 
 	memcg_deactivate_kmem_caches(memcg);
+
+	kmemcg_id = memcg->kmemcg_id;
+	BUG_ON(kmemcg_id < 0);
+
+	parent = parent_mem_cgroup(memcg);
+	if (!parent)
+		parent = root_mem_cgroup;
+
+	/*
+	 * Change kmemcg_id of this cgroup and all its descendants to the
+	 * parent's id, and then move all entries from this cgroup's list_lrus
+	 * to ones of the parent. After we have finished, all list_lrus
+	 * corresponding to this cgroup are guaranteed to remain empty. The
+	 * ordering is imposed by list_lru_node->lock taken by
+	 * memcg_drain_all_list_lrus().
+	 */
+	css_for_each_descendant_pre(css, &memcg->css) {
+		child = mem_cgroup_from_css(css);
+		BUG_ON(child->kmemcg_id != kmemcg_id);
+		child->kmemcg_id = parent->kmemcg_id;
+		if (!memcg->use_hierarchy)
+			break;
+	}
+	memcg_drain_all_list_lrus(kmemcg_id, parent->kmemcg_id);
+
+	memcg_free_cache_id(kmemcg_id);
 }
 
 static void memcg_destroy_kmem(struct mem_cgroup *memcg)
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 87ef846d5709..16f3e45742d6 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -377,7 +377,7 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
 	struct shrinker *shrinker;
 	unsigned long freed = 0;
 
-	if (memcg_cache_id(memcg) < 0)
+	if (memcg && !memcg_kmem_is_active(memcg))
 		return 0;
 
 	if (nr_scanned == 0)
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
