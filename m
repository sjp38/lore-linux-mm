Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id DC60B6B003B
	for <linux-mm@kvack.org>; Sun, 21 Sep 2014 11:15:29 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id eu11so1274209pac.10
        for <linux-mm@kvack.org>; Sun, 21 Sep 2014 08:15:29 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id cg3si11849393pdb.224.2014.09.21.08.15.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Sep 2014 08:15:26 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 05/14] memcg: add pointer to owner cache to memcg_cache_params
Date: Sun, 21 Sep 2014 19:14:37 +0400
Message-ID: <acf095a7af0c7538bec8f119cf4ed9a913e4d036.1411301245.git.vdavydov@parallels.com>
In-Reply-To: <cover.1411301245.git.vdavydov@parallels.com>
References: <cover.1411301245.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Dave Chinner <david@fromorbit.com>, Glauber Costa <glommer@gmail.com>, Suleiman Souhlal <suleiman@google.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

We don't keep a pointer to the owner kmem cache in the
memcg_cache_params struct, because we can always get the cache by
reading the slot corresponding to the owner memcg in the root cache's
memcg_caches array (see memcg_params_to_cache).

However, this means that offline css's, which can be zombieing around
for quite a long time, will occupy slots in memcg_caches arrays, making
them grow larger and larger, which doesn't sound good. Therefore I'm
going to make memcg release the slots on offline, which will render
memcg_params_to_cache invalid. So I'm removing it and adding a back
pointer to memcg_cache_params instead.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/slab.h |    2 ++
 mm/memcontrol.c      |   19 +++----------------
 mm/slab_common.c     |    1 +
 3 files changed, 6 insertions(+), 16 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index f4d489aee6cb..c61344074c11 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -490,6 +490,7 @@ static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
  *
  * Child caches will hold extra metadata needed for its operation. Fields are:
  *
+ * @cachep: cache which this struct is for
  * @memcg: pointer to the memcg this cache belongs to
  * @list: list_head for the list of all caches in this memcg
  * @root_cache: pointer to the global, root cache, this cache was derived from
@@ -503,6 +504,7 @@ struct memcg_cache_params {
 			struct kmem_cache *memcg_caches[0];
 		};
 		struct {
+			struct kmem_cache *cachep;
 			struct mem_cgroup *memcg;
 			struct list_head list;
 			struct kmem_cache *root_cache;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 16fcdbef1b7d..9cb311c199be 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2836,19 +2836,6 @@ static inline bool memcg_can_account_kmem(struct mem_cgroup *memcg)
 		memcg_kmem_is_active(memcg);
 }
 
-/*
- * This is a bit cumbersome, but it is rarely used and avoids a backpointer
- * in the memcg_cache_params struct.
- */
-static struct kmem_cache *memcg_params_to_cache(struct memcg_cache_params *p)
-{
-	struct kmem_cache *cachep;
-
-	VM_BUG_ON(p->is_root_cache);
-	cachep = p->root_cache;
-	return cache_from_memcg_idx(cachep, memcg_cache_id(p->memcg));
-}
-
 #ifdef CONFIG_SLABINFO
 static int mem_cgroup_slabinfo_read(struct seq_file *m, void *v)
 {
@@ -2862,7 +2849,7 @@ static int mem_cgroup_slabinfo_read(struct seq_file *m, void *v)
 
 	mutex_lock(&memcg_slab_mutex);
 	list_for_each_entry(params, &memcg->memcg_slab_caches, list)
-		cache_show(memcg_params_to_cache(params), m);
+		cache_show(params->cachep, m);
 	mutex_unlock(&memcg_slab_mutex);
 
 	return 0;
@@ -3120,7 +3107,6 @@ int __memcg_cleanup_cache_params(struct kmem_cache *s)
 
 static void memcg_unregister_all_caches(struct mem_cgroup *memcg)
 {
-	struct kmem_cache *cachep;
 	struct memcg_cache_params *params, *tmp;
 
 	if (!memcg_kmem_is_active(memcg))
@@ -3128,7 +3114,8 @@ static void memcg_unregister_all_caches(struct mem_cgroup *memcg)
 
 	mutex_lock(&memcg_slab_mutex);
 	list_for_each_entry_safe(params, tmp, &memcg->memcg_slab_caches, list) {
-		cachep = memcg_params_to_cache(params);
+		struct kmem_cache *cachep = params->cachep;
+
 		kmem_cache_shrink(cachep);
 		if (atomic_read(&cachep->memcg_params->nr_pages) == 0)
 			memcg_unregister_cache(cachep);
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 8b486f05c414..b5c9d90535af 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -107,6 +107,7 @@ static int memcg_alloc_cache_params(struct mem_cgroup *memcg,
 		return -ENOMEM;
 
 	if (memcg) {
+		s->memcg_params->cachep = s;
 		s->memcg_params->memcg = memcg;
 		s->memcg_params->root_cache = root_cache;
 	} else
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
