Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f173.google.com (mail-lb0-f173.google.com [209.85.217.173])
	by kanga.kvack.org (Postfix) with ESMTP id 4B15B6B0037
	for <linux-mm@kvack.org>; Fri,  6 Jun 2014 09:22:53 -0400 (EDT)
Received: by mail-lb0-f173.google.com with SMTP id 10so1505232lbg.4
        for <linux-mm@kvack.org>; Fri, 06 Jun 2014 06:22:52 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id po5si10726958lac.68.2014.06.06.06.22.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jun 2014 06:22:51 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm v2 1/8] memcg: cleanup memcg_cache_params refcnt usage
Date: Fri, 6 Jun 2014 17:22:38 +0400
Message-ID: <178605c7465356f9cf00ee0f2cb52e554085abc0.1402060096.git.vdavydov@parallels.com>
In-Reply-To: <cover.1402060096.git.vdavydov@parallels.com>
References: <cover.1402060096.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: cl@linux.com, iamjoonsoo.kim@lge.com, rientjes@google.com, penberg@kernel.org, hannes@cmpxchg.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Currently, we count the number of pages allocated to a per memcg cache
in memcg_cache_params->nr_pages. We only use this counter to find out if
the cache is empty and can be destroyed. So let's rename it to refcnt
and make it count not pages, but slabs so that we can use atomic_inc/dec
instead of atomic_add/sub in memcg_charge/uncharge_slab.

Also, as the number of slabs theoretically can be greater than INT_MAX,
let's use atomic_long for the counter.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Acked-by: Christoph Lameter <cl@linux.com>
---
 include/linux/slab.h |    4 ++--
 mm/memcontrol.c      |    6 +++---
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 1d9abb7d22a0..1985bd9bec7d 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -526,7 +526,7 @@ static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
  * @memcg: pointer to the memcg this cache belongs to
  * @list: list_head for the list of all caches in this memcg
  * @root_cache: pointer to the global, root cache, this cache was derived from
- * @nr_pages: number of pages that belongs to this cache.
+ * @refcnt: reference counter
  */
 struct memcg_cache_params {
 	bool is_root_cache;
@@ -539,7 +539,7 @@ struct memcg_cache_params {
 			struct mem_cgroup *memcg;
 			struct list_head list;
 			struct kmem_cache *root_cache;
-			atomic_t nr_pages;
+			atomic_long_t refcnt;
 		};
 	};
 };
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 15bda8133ff9..98a24e5ea4b5 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3279,7 +3279,7 @@ static void memcg_unregister_all_caches(struct mem_cgroup *memcg)
 	list_for_each_entry_safe(params, tmp, &memcg->memcg_slab_caches, list) {
 		cachep = memcg_params_to_cache(params);
 		kmem_cache_shrink(cachep);
-		if (atomic_read(&cachep->memcg_params->nr_pages) == 0)
+		if (atomic_long_read(&cachep->memcg_params->refcnt) == 0)
 			memcg_unregister_cache(cachep);
 	}
 	mutex_unlock(&memcg_slab_mutex);
@@ -3353,14 +3353,14 @@ int __memcg_charge_slab(struct kmem_cache *cachep, gfp_t gfp, int order)
 	res = memcg_charge_kmem(cachep->memcg_params->memcg, gfp,
 				PAGE_SIZE << order);
 	if (!res)
-		atomic_add(1 << order, &cachep->memcg_params->nr_pages);
+		atomic_long_inc(&cachep->memcg_params->refcnt);
 	return res;
 }
 
 void __memcg_uncharge_slab(struct kmem_cache *cachep, int order)
 {
 	memcg_uncharge_kmem(cachep->memcg_params->memcg, PAGE_SIZE << order);
-	atomic_sub(1 << order, &cachep->memcg_params->nr_pages);
+	atomic_long_dec(&cachep->memcg_params->refcnt);
 }
 
 /*
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
