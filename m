Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id F19556B0029
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 09:22:51 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id v17so2643085pff.9
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 06:22:51 -0700 (PDT)
Received: from EUR03-DB5-obe.outbound.protection.outlook.com (mail-eopbgr40094.outbound.protection.outlook.com. [40.107.4.94])
        by mx.google.com with ESMTPS id 34-v6si3864089plm.543.2018.03.21.06.22.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 21 Mar 2018 06:22:51 -0700 (PDT)
Subject: [PATCH 08/10] mm: Set bit in memcg shrinker bitmap on first
 list_lru item apearance
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Wed, 21 Mar 2018 16:22:40 +0300
Message-ID: <152163856059.21546.11414341109878480074.stgit@localhost.localdomain>
In-Reply-To: <152163840790.21546.980703278415599202.stgit@localhost.localdomain>
References: <152163840790.21546.980703278415599202.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com, ktkhai@virtuozzo.com, akpm@linux-foundation.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, hillf.zj@alibaba-inc.com, ying.huang@intel.com, mgorman@techsingularity.net, shakeelb@google.com, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org

Introduce set_shrinker_bit() function to set shrinker-related
bit in memcg shrinker bitmap, and set the bit after the first
item is added and in case of reparenting destroyed memcg's items.

This will allow next patch to make shrinkers be called only,
in case of they have charged objects at the moment, and
to improve shrink_slab() performance.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 include/linux/shrinker.h |    7 +++++++
 mm/list_lru.c            |   22 ++++++++++++++++++++--
 mm/vmscan.c              |    7 +++++++
 3 files changed, 34 insertions(+), 2 deletions(-)

diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
index 738de8ef5246..24aeed1bc332 100644
--- a/include/linux/shrinker.h
+++ b/include/linux/shrinker.h
@@ -78,4 +78,11 @@ struct shrinker {
 
 extern __must_check int register_shrinker(struct shrinker *);
 extern void unregister_shrinker(struct shrinker *);
+#if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
+extern void set_shrinker_bit(struct mem_cgroup *, int, int);
+#else
+static inline void set_shrinker_bit(struct mem_cgroup *memcg, int node, int id)
+{
+}
+#endif
 #endif
diff --git a/mm/list_lru.c b/mm/list_lru.c
index 85a0988154aa..9a331c790bfb 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -30,6 +30,11 @@ static void list_lru_unregister(struct list_lru *lru)
 	list_del(&lru->list);
 	mutex_unlock(&list_lrus_mutex);
 }
+
+static int lru_shrk_id(struct list_lru *lru)
+{
+	return lru->shrk_id;
+}
 #else
 static void list_lru_register(struct list_lru *lru)
 {
@@ -38,6 +43,11 @@ static void list_lru_register(struct list_lru *lru)
 static void list_lru_unregister(struct list_lru *lru)
 {
 }
+
+static int lru_shrk_id(struct list_lru *lru)
+{
+	return -1;
+}
 #endif /* CONFIG_MEMCG && !CONFIG_SLOB */
 
 #if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
@@ -120,13 +130,15 @@ bool list_lru_add(struct list_lru *lru, struct list_head *item)
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
+		if (!l->nr_items++ && lru_shrk_id(lru) >= 0)
+			set_shrinker_bit(memcg, nid, lru_shrk_id(lru));
 		nlru->nr_items++;
 		spin_unlock(&nlru->lock);
 		return true;
@@ -521,6 +533,7 @@ static void memcg_drain_list_lru_node(struct list_lru *lru, int nid,
 	struct list_lru_node *nlru = &lru->node[nid];
 	int dst_idx = dst_memcg->kmemcg_id;
 	struct list_lru_one *src, *dst;
+	bool set;
 
 	/*
 	 * Since list_lru_{add,del} may be called under an IRQ-safe lock,
@@ -532,9 +545,14 @@ static void memcg_drain_list_lru_node(struct list_lru *lru, int nid,
 	dst = list_lru_from_memcg_idx(nlru, dst_idx);
 
 	list_splice_init(&src->list, &dst->list);
+
+	set = (src->nr_items && !dst->nr_items);
 	dst->nr_items += src->nr_items;
 	src->nr_items = 0;
 
+	if (set && lru->shrk_id >= 0)
+		set_shrinker_bit(dst_memcg, nid, lru->shrk_id);
+
 	spin_unlock_irq(&nlru->lock);
 }
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 9d1df5d90eca..265cf069b470 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -378,6 +378,13 @@ static void del_shrinker(struct shrinker *shrinker)
 	list_del(&shrinker->list);
 	up_write(&shrinker_rwsem);
 }
+
+void set_shrinker_bit(struct mem_cgroup *memcg, int nid, int nr)
+{
+	struct shrinkers_map *map = SHRINKERS_MAP(memcg);
+
+	set_bit(nr, map->map[nid]);
+}
 #else /* CONFIG_MEMCG && !CONFIG_SLOB */
 static int alloc_shrinker_id(struct shrinker *shrinker)
 {
