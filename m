Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id B86BA6B0037
	for <linux-mm@kvack.org>; Mon, 22 Sep 2014 12:00:59 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id r10so4579335pdi.26
        for <linux-mm@kvack.org>; Mon, 22 Sep 2014 09:00:59 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id ei3si16390124pdb.80.2014.09.22.09.00.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Sep 2014 09:00:58 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH v2 1/3] memcg: move memcg_{alloc,free}_cache_params to slab_common.c
Date: Mon, 22 Sep 2014 20:00:44 +0400
Message-ID: <6dce5fd23f4cdd9f7055474f27d0c35e76251892.1411401021.git.vdavydov@parallels.com>
In-Reply-To: <cover.1411401021.git.vdavydov@parallels.com>
References: <cover.1411401021.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@linux.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

The only reason why they live in memcontrol.c is that we get/put css
reference to the owner memory cgroup in them. However, we can do that in
memcg_{un,}register_cache. OTOH, there are several reasons to move them
to slab_common.c.

First, I think that the less public interface functions we have in
memcontrol.h the better. Since the functions I move don't depend on
memcontrol, I think it's worth making them private to slab, especially
taking into account that the arrays are defined on the slab's side too.

Second, the way how per-memcg arrays are updated looks rather awkward:
it proceeds from memcontrol.c (__memcg_activate_kmem) to slab_common.c
(memcg_update_all_caches) and back to memcontrol.c again
(memcg_update_array_size). In the following patches I move the function
relocating the arrays (memcg_update_array_size) to slab_common.c and
therefore get rid this circular call path. I think we should have the
cache allocation stuff in the same place where we have relocation,
because it's easier to follow the code then. So I move arrays alloc/free
functions to slab_common.c too.

The third point isn't obvious. I'm going to make the list_lru structure
per-memcg to allow targeted kmem reclaim. That means we will have
per-memcg arrays in list_lrus too. It turns out that it's much easier to
update these arrays in list_lru.c rather than in memcontrol.c, because
all the stuff we need is defined there. This patch makes memcg caches
arrays allocation path conform that of the upcoming list_lru.

So let's move these functions to slab_common.c and make them static.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/memcontrol.h |   14 --------------
 mm/memcontrol.c            |   41 ++++-------------------------------------
 mm/slab_common.c           |   44 +++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 47 insertions(+), 52 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index e0752d204d9e..4d17242eeff7 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -440,10 +440,6 @@ void __memcg_kmem_uncharge_pages(struct page *page, int order);
 
 int memcg_cache_id(struct mem_cgroup *memcg);
 
-int memcg_alloc_cache_params(struct mem_cgroup *memcg, struct kmem_cache *s,
-			     struct kmem_cache *root_cache);
-void memcg_free_cache_params(struct kmem_cache *s);
-
 int memcg_update_cache_size(struct kmem_cache *s, int num_groups);
 void memcg_update_array_size(int num_groups);
 
@@ -574,16 +570,6 @@ static inline int memcg_cache_id(struct mem_cgroup *memcg)
 	return -1;
 }
 
-static inline int memcg_alloc_cache_params(struct mem_cgroup *memcg,
-		struct kmem_cache *s, struct kmem_cache *root_cache)
-{
-	return 0;
-}
-
-static inline void memcg_free_cache_params(struct kmem_cache *s)
-{
-}
-
 static inline struct kmem_cache *
 memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp)
 {
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 085dc6d2f876..b6bbb1e3e2ab 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2970,43 +2970,6 @@ int memcg_update_cache_size(struct kmem_cache *s, int num_groups)
 	return 0;
 }
 
-int memcg_alloc_cache_params(struct mem_cgroup *memcg, struct kmem_cache *s,
-			     struct kmem_cache *root_cache)
-{
-	size_t size;
-
-	if (!memcg_kmem_enabled())
-		return 0;
-
-	if (!memcg) {
-		size = offsetof(struct memcg_cache_params, memcg_caches);
-		size += memcg_limited_groups_array_size * sizeof(void *);
-	} else
-		size = sizeof(struct memcg_cache_params);
-
-	s->memcg_params = kzalloc(size, GFP_KERNEL);
-	if (!s->memcg_params)
-		return -ENOMEM;
-
-	if (memcg) {
-		s->memcg_params->memcg = memcg;
-		s->memcg_params->root_cache = root_cache;
-		css_get(&memcg->css);
-	} else
-		s->memcg_params->is_root_cache = true;
-
-	return 0;
-}
-
-void memcg_free_cache_params(struct kmem_cache *s)
-{
-	if (!s->memcg_params)
-		return;
-	if (!s->memcg_params->is_root_cache)
-		css_put(&s->memcg_params->memcg->css);
-	kfree(s->memcg_params);
-}
-
 static void memcg_register_cache(struct mem_cgroup *memcg,
 				 struct kmem_cache *root_cache)
 {
@@ -3037,6 +3000,7 @@ static void memcg_register_cache(struct mem_cgroup *memcg,
 	if (!cachep)
 		return;
 
+	css_get(&memcg->css);
 	list_add(&cachep->memcg_params->list, &memcg->memcg_slab_caches);
 
 	/*
@@ -3070,6 +3034,9 @@ static void memcg_unregister_cache(struct kmem_cache *cachep)
 	list_del(&cachep->memcg_params->list);
 
 	kmem_cache_destroy(cachep);
+
+	/* drop the reference taken in memcg_register_cache */
+	css_put(&memcg->css);
 }
 
 /*
diff --git a/mm/slab_common.c b/mm/slab_common.c
index d7d8ffd0c306..9c29ba792368 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -88,6 +88,38 @@ static inline int kmem_cache_sanity_check(const char *name, size_t size)
 #endif
 
 #ifdef CONFIG_MEMCG_KMEM
+static int memcg_alloc_cache_params(struct mem_cgroup *memcg,
+		struct kmem_cache *s, struct kmem_cache *root_cache)
+{
+	size_t size;
+
+	if (!memcg_kmem_enabled())
+		return 0;
+
+	if (!memcg) {
+		size = offsetof(struct memcg_cache_params, memcg_caches);
+		size += memcg_limited_groups_array_size * sizeof(void *);
+	} else
+		size = sizeof(struct memcg_cache_params);
+
+	s->memcg_params = kzalloc(size, GFP_KERNEL);
+	if (!s->memcg_params)
+		return -ENOMEM;
+
+	if (memcg) {
+		s->memcg_params->memcg = memcg;
+		s->memcg_params->root_cache = root_cache;
+	} else
+		s->memcg_params->is_root_cache = true;
+
+	return 0;
+}
+
+static void memcg_free_cache_params(struct kmem_cache *s)
+{
+	kfree(s->memcg_params);
+}
+
 int memcg_update_all_caches(int num_memcgs)
 {
 	struct kmem_cache *s;
@@ -113,7 +145,17 @@ out:
 	mutex_unlock(&slab_mutex);
 	return ret;
 }
-#endif
+#else
+static inline int memcg_alloc_cache_params(struct mem_cgroup *memcg,
+		struct kmem_cache *s, struct kmem_cache *root_cache)
+{
+	return 0;
+}
+
+static inline void memcg_free_cache_params(struct kmem_cache *s)
+{
+}
+#endif /* CONFIG_MEMCG_KMEM */
 
 /*
  * Figure out what the alignment of the objects will be given a set of
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
