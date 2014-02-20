Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f182.google.com (mail-lb0-f182.google.com [209.85.217.182])
	by kanga.kvack.org (Postfix) with ESMTP id 883036B0073
	for <linux-mm@kvack.org>; Thu, 20 Feb 2014 02:22:17 -0500 (EST)
Received: by mail-lb0-f182.google.com with SMTP id w7so1029069lbi.41
        for <linux-mm@kvack.org>; Wed, 19 Feb 2014 23:22:16 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id z2si2580166lal.151.2014.02.19.23.22.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Feb 2014 23:22:15 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm v3 4/7] memcg, slab: unregister cache from memcg before starting to destroy it
Date: Thu, 20 Feb 2014 11:22:06 +0400
Message-ID: <afa760bb49b2f7fbbefd46e26a739387120a645c.1392879001.git.vdavydov@parallels.com>
In-Reply-To: <cover.1392879001.git.vdavydov@parallels.com>
References: <cover.1392879001.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz, akpm@linux-foundation.org
Cc: rientjes@google.com, penberg@kernel.org, cl@linux.com, glommer@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@openvz.org

Currently, memcg_unregister_cache(), which deletes the cache being
destroyed from the memcg_slab_caches list, is called after
__kmem_cache_shutdown() (see kmem_cache_destroy()), which starts to
destroy the cache. As a result, one can access a partially destroyed
cache while traversing a memcg_slab_caches list, which can have deadly
consequences (for instance, cache_show() called for each cache on a
memcg_slab_caches list from mem_cgroup_slabinfo_read() will dereference
pointers to already freed data).

To fix this, let's move memcg_unregister_cache() before the cache
destruction process beginning, issuing memcg_register_cache() on
failure.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 mm/memcontrol.c  |   12 ++++++------
 mm/slab_common.c |    3 ++-
 2 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 0e11c72047d0..b07e08f97460 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3205,6 +3205,7 @@ int memcg_alloc_cache_params(struct mem_cgroup *memcg, struct kmem_cache *s,
 		s->memcg_params->root_cache = root_cache;
 		INIT_WORK(&s->memcg_params->destroy,
 				kmem_cache_destroy_work_func);
+		css_get(&memcg->css);
 	} else
 		s->memcg_params->is_root_cache = true;
 
@@ -3213,6 +3214,10 @@ int memcg_alloc_cache_params(struct mem_cgroup *memcg, struct kmem_cache *s,
 
 void memcg_free_cache_params(struct kmem_cache *s)
 {
+	if (!s->memcg_params)
+		return;
+	if (!s->memcg_params->is_root_cache)
+		css_put(&s->memcg_params->memcg->css);
 	kfree(s->memcg_params);
 }
 
@@ -3235,9 +3240,6 @@ void memcg_register_cache(struct kmem_cache *s)
 	memcg = s->memcg_params->memcg;
 	id = memcg_cache_id(memcg);
 
-	css_get(&memcg->css);
-
-
 	/*
 	 * Since readers won't lock (see cache_from_memcg_idx()), we need a
 	 * barrier here to ensure nobody will see the kmem_cache partially
@@ -3286,10 +3288,8 @@ void memcg_unregister_cache(struct kmem_cache *s)
 	 * after removing it from the memcg_slab_caches list, otherwise we can
 	 * fail to convert memcg_params_to_cache() while traversing the list.
 	 */
-	VM_BUG_ON(!root->memcg_params->memcg_caches[id]);
+	VM_BUG_ON(root->memcg_params->memcg_caches[id] != s);
 	root->memcg_params->memcg_caches[id] = NULL;
-
-	css_put(&memcg->css);
 }
 
 /*
diff --git a/mm/slab_common.c b/mm/slab_common.c
index ccc012f00126..0c2879ff414c 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -313,9 +313,9 @@ void kmem_cache_destroy(struct kmem_cache *s)
 	s->refcount--;
 	if (!s->refcount) {
 		list_del(&s->list);
+		memcg_unregister_cache(s);
 
 		if (!__kmem_cache_shutdown(s)) {
-			memcg_unregister_cache(s);
 			mutex_unlock(&slab_mutex);
 			if (s->flags & SLAB_DESTROY_BY_RCU)
 				rcu_barrier();
@@ -325,6 +325,7 @@ void kmem_cache_destroy(struct kmem_cache *s)
 			kmem_cache_free(kmem_cache, s);
 		} else {
 			list_add(&s->list, &slab_caches);
+			memcg_register_cache(s);
 			mutex_unlock(&slab_mutex);
 			printk(KERN_ERR "kmem_cache_destroy %s: Slab cache still has objects\n",
 				s->name);
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
