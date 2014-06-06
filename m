Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id C474C6B003B
	for <linux-mm@kvack.org>; Fri,  6 Jun 2014 09:22:54 -0400 (EDT)
Received: by mail-lb0-f179.google.com with SMTP id c11so1528799lbj.10
        for <linux-mm@kvack.org>; Fri, 06 Jun 2014 06:22:54 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id na5si21364404lbb.7.2014.06.06.06.22.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jun 2014 06:22:53 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm v2 6/8] memcg: wait for kfree's to finish before destroying cache
Date: Fri, 6 Jun 2014 17:22:43 +0400
Message-ID: <07a2c0a9d898a68a7c8593c398d428aa16be9fd5.1402060096.git.vdavydov@parallels.com>
In-Reply-To: <cover.1402060096.git.vdavydov@parallels.com>
References: <cover.1402060096.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: cl@linux.com, iamjoonsoo.kim@lge.com, rientjes@google.com, penberg@kernel.org, hannes@cmpxchg.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

kmem_cache_free doesn't expect that the cache can be destroyed as soon
as the object is freed, e.g. SLUB's implementation may want to update
cache stats after putting the object to the free list.

Therefore we should wait for all kmem_cache_free's to finish before
proceeding to cache destruction. Since both SLAB and SLUB versions of
kmem_cache_free are non-preemptable, we wait for rcu-sched grace period
to elapse.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/slab.h |    6 ++----
 mm/memcontrol.c      |   34 ++++++++++++++++++++++++++++++++--
 2 files changed, 34 insertions(+), 6 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index d99d5212b815..68b1feaba9d6 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -532,11 +532,9 @@ static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
  */
 struct memcg_cache_params {
 	bool is_root_cache;
+	struct rcu_head rcu_head;
 	union {
-		struct {
-			struct rcu_head rcu_head;
-			struct kmem_cache *memcg_caches[0];
-		};
+		struct kmem_cache *memcg_caches[0];
 		struct {
 			struct mem_cgroup *memcg;
 			struct list_head list;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ed42fd1105a5..5b3543a9257e 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3232,6 +3232,14 @@ static void memcg_unregister_cache_func(struct work_struct *work)
 	mutex_unlock(&memcg_slab_mutex);
 }
 
+static void memcg_unregister_cache_rcu_func(struct rcu_head *rcu)
+{
+	struct memcg_cache_params *params =
+		container_of(rcu, struct memcg_cache_params, rcu_head);
+
+	schedule_work(&params->unregister_work);
+}
+
 /*
  * During the creation a new cache, we need to disable our accounting mechanism
  * altogether. This is true even if we are not creating, but rather just
@@ -3287,6 +3295,7 @@ static void memcg_unregister_all_caches(struct mem_cgroup *memcg)
 {
 	struct kmem_cache *cachep;
 	struct memcg_cache_params *params, *tmp;
+	LIST_HEAD(empty_caches);
 
 	if (!memcg_kmem_is_active(memcg))
 		return;
@@ -3297,7 +3306,26 @@ static void memcg_unregister_all_caches(struct mem_cgroup *memcg)
 		cachep->memcg_params->dead = true;
 		kmem_cache_shrink(cachep);
 		if (atomic_long_dec_and_test(&cachep->memcg_params->refcnt))
-			memcg_unregister_cache(cachep);
+			list_move(&cachep->memcg_params->list, &empty_caches);
+	}
+
+	/*
+	 * kmem_cache_free doesn't expect that the cache can be destroyed as
+	 * soon as the object is freed, e.g. SLUB's implementation may want to
+	 * update cache stats after putting the object to the free list.
+	 *
+	 * Therefore we should wait for all kmem_cache_free's to finish before
+	 * proceeding to cache destruction. Since both SLAB and SLUB versions
+	 * of kmem_cache_free are non-preemptable, we wait for rcu-sched grace
+	 * period to elapse.
+	 */
+	synchronize_sched();
+
+	while (!list_empty(&empty_caches)) {
+		params = list_first_entry(&empty_caches,
+					  struct memcg_cache_params, list);
+		cachep = memcg_params_to_cache(params);
+		memcg_unregister_cache(cachep);
 	}
 	mutex_unlock(&memcg_slab_mutex);
 }
@@ -3379,7 +3407,9 @@ void __memcg_uncharge_slab(struct kmem_cache *cachep, int order)
 	memcg_uncharge_kmem(cachep->memcg_params->memcg, PAGE_SIZE << order);
 
 	if (unlikely(atomic_long_dec_and_test(&cachep->memcg_params->refcnt)))
-		schedule_work(&cachep->memcg_params->unregister_work);
+		/* see memcg_unregister_all_caches */
+		call_rcu_sched(&cachep->memcg_params->rcu_head,
+			       memcg_unregister_cache_rcu_func);
 }
 
 /*
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
