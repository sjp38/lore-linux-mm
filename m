Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5D7176B028B
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 11:11:06 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e3-v6so1203265pfn.13
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 08:11:06 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0138.outbound.protection.outlook.com. [104.47.0.138])
        by mx.google.com with ESMTPS id u26-v6si1189063pge.590.2018.07.03.08.11.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 03 Jul 2018 08:11:04 -0700 (PDT)
Subject: [PATCH v8 13/17] mm: Set bit in memcg shrinker bitmap on first
 list_lru item apearance
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Tue, 03 Jul 2018 18:10:56 +0300
Message-ID: <153063065671.1818.15914674956134687268.stgit@localhost.localdomain>
In-Reply-To: <153063036670.1818.16010062622751502.stgit@localhost.localdomain>
References: <153063036670.1818.16010062622751502.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vdavydov.dev@gmail.com, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com, akpm@linux-foundation.org, ktkhai@virtuozzo.com

Introduce set_shrinker_bit() function to set shrinker-related
bit in memcg shrinker bitmap, and set the bit after the first
item is added and in case of reparenting destroyed memcg's items.

This will allow next patch to make shrinkers be called only,
in case of they have charged objects at the moment, and
to improve shrink_slab() performance.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>
Tested-by: Shakeel Butt <shakeelb@google.com>
---
 include/linux/memcontrol.h |   14 ++++++++++++++
 mm/list_lru.c              |   22 ++++++++++++++++++++--
 2 files changed, 34 insertions(+), 2 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 2c52b4313117..c6ea182ca54b 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -1308,6 +1308,18 @@ static inline int memcg_cache_id(struct mem_cgroup *memcg)
 
 extern int memcg_expand_shrinker_maps(int new_id);
 
+static inline void memcg_set_shrinker_bit(struct mem_cgroup *memcg,
+					  int nid, int shrinker_id)
+{
+	if (shrinker_id >= 0 && memcg && !mem_cgroup_is_root(memcg)) {
+		struct memcg_shrinker_map *map;
+
+		rcu_read_lock();
+		map = rcu_dereference(memcg->nodeinfo[nid]->shrinker_map);
+		set_bit(shrinker_id, map->map);
+		rcu_read_unlock();
+	}
+}
 #else
 #define for_each_memcg_cache_index(_idx)	\
 	for (; NULL; )
@@ -1330,6 +1342,8 @@ static inline void memcg_put_cache_ids(void)
 {
 }
 
+static inline void memcg_set_shrinker_bit(struct mem_cgroup *memcg,
+					  int nid, int shrinker_id) { }
 #endif /* CONFIG_MEMCG_KMEM */
 
 #endif /* _LINUX_MEMCONTROL_H */
diff --git a/mm/list_lru.c b/mm/list_lru.c
index fbda35ac5c17..b2d8be96e267 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -31,6 +31,11 @@ static void list_lru_unregister(struct list_lru *lru)
 	mutex_unlock(&list_lrus_mutex);
 }
 
+static int lru_shrinker_id(struct list_lru *lru)
+{
+	return lru->shrinker_id;
+}
+
 static inline bool list_lru_memcg_aware(struct list_lru *lru)
 {
 	/*
@@ -94,6 +99,11 @@ static void list_lru_unregister(struct list_lru *lru)
 {
 }
 
+static int lru_shrinker_id(struct list_lru *lru)
+{
+	return -1;
+}
+
 static inline bool list_lru_memcg_aware(struct list_lru *lru)
 {
 	return false;
@@ -119,13 +129,17 @@ bool list_lru_add(struct list_lru *lru, struct list_head *item)
 {
 	int nid = page_to_nid(virt_to_page(item));
 	struct list_lru_node *nlru = &lru->node[nid];
+	struct mem_cgroup *memcg;
 	struct list_lru_one *l;
 
 	spin_lock(&nlru->lock);
 	if (list_empty(item)) {
-		l = list_lru_from_kmem(nlru, item, NULL);
+		l = list_lru_from_kmem(nlru, item, &memcg);
 		list_add_tail(item, &l->list);
-		l->nr_items++;
+		/* Set shrinker bit if the first element was added */
+		if (!l->nr_items++)
+			memcg_set_shrinker_bit(memcg, nid,
+					       lru_shrinker_id(lru));
 		nlru->nr_items++;
 		spin_unlock(&nlru->lock);
 		return true;
@@ -520,6 +534,7 @@ static void memcg_drain_list_lru_node(struct list_lru *lru, int nid,
 	struct list_lru_node *nlru = &lru->node[nid];
 	int dst_idx = dst_memcg->kmemcg_id;
 	struct list_lru_one *src, *dst;
+	bool set;
 
 	/*
 	 * Since list_lru_{add,del} may be called under an IRQ-safe lock,
@@ -531,7 +546,10 @@ static void memcg_drain_list_lru_node(struct list_lru *lru, int nid,
 	dst = list_lru_from_memcg_idx(nlru, dst_idx);
 
 	list_splice_init(&src->list, &dst->list);
+	set = (!dst->nr_items && src->nr_items);
 	dst->nr_items += src->nr_items;
+	if (set)
+		memcg_set_shrinker_bit(dst_memcg, nid, lru_shrinker_id(lru));
 	src->nr_items = 0;
 
 	spin_unlock_irq(&nlru->lock);
