Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f170.google.com (mail-lb0-f170.google.com [209.85.217.170])
	by kanga.kvack.org (Postfix) with ESMTP id 20DE46B0035
	for <linux-mm@kvack.org>; Wed,  7 May 2014 04:15:35 -0400 (EDT)
Received: by mail-lb0-f170.google.com with SMTP id w7so835857lbi.15
        for <linux-mm@kvack.org>; Wed, 07 May 2014 01:15:34 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id yp3si6424104lbb.16.2014.05.07.01.15.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 May 2014 01:15:33 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 1/2] memcg: get rid of memcg_create_cache_name
Date: Wed, 7 May 2014 12:15:29 +0400
Message-ID: <a4aa62026c10fc709e8bf13542b29cf771381394.1399450112.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: hannes@cmpxchg.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Instead of calling back to memcontrol.c from kmem_cache_create_memcg in
order to just create the name of a per memcg cache, let's allocate it in
place. We only need to pass the memcg name to kmem_cache_create_memcg
for that - everything else can be done in slab_common.c.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
Initially this was a part of "memcg/kmem: cleanup naming and callflows"
patch set (https://lkml.org/lkml/2014/4/27/345).

 include/linux/memcontrol.h |    2 --
 include/linux/slab.h       |    3 ++-
 mm/memcontrol.c            |   33 +++++++++------------------------
 mm/slab_common.c           |    7 +++++--
 4 files changed, 16 insertions(+), 29 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 6c59056f4bc6..7b639ab48aa8 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -501,8 +501,6 @@ void __memcg_kmem_uncharge_pages(struct page *page, int order);
 
 int memcg_cache_id(struct mem_cgroup *memcg);
 
-char *memcg_create_cache_name(struct mem_cgroup *memcg,
-			      struct kmem_cache *root_cache);
 int memcg_alloc_cache_params(struct mem_cgroup *memcg, struct kmem_cache *s,
 			     struct kmem_cache *root_cache);
 void memcg_free_cache_params(struct kmem_cache *s);
diff --git a/include/linux/slab.h b/include/linux/slab.h
index ecbec9ccb80d..86e5b26fbdab 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -117,7 +117,8 @@ struct kmem_cache *kmem_cache_create(const char *, size_t, size_t,
 			void (*)(void *));
 #ifdef CONFIG_MEMCG_KMEM
 struct kmem_cache *kmem_cache_create_memcg(struct mem_cgroup *,
-					   struct kmem_cache *);
+					   struct kmem_cache *,
+					   const char *);
 #endif
 void kmem_cache_destroy(struct kmem_cache *);
 int kmem_cache_shrink(struct kmem_cache *);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index f381239ab402..f401f227a099 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3101,29 +3101,6 @@ int memcg_update_cache_size(struct kmem_cache *s, int num_groups)
 	return 0;
 }
 
-char *memcg_create_cache_name(struct mem_cgroup *memcg,
-			      struct kmem_cache *root_cache)
-{
-	static char *buf;
-
-	/*
-	 * We need a mutex here to protect the shared buffer. Since this is
-	 * expected to be called only on cache creation, we can employ the
-	 * slab_mutex for that purpose.
-	 */
-	lockdep_assert_held(&slab_mutex);
-
-	if (!buf) {
-		buf = kmalloc(NAME_MAX + 1, GFP_KERNEL);
-		if (!buf)
-			return NULL;
-	}
-
-	cgroup_name(memcg->css.cgroup, buf, NAME_MAX + 1);
-	return kasprintf(GFP_KERNEL, "%s(%d:%s)", root_cache->name,
-			 memcg_cache_id(memcg), buf);
-}
-
 int memcg_alloc_cache_params(struct mem_cgroup *memcg, struct kmem_cache *s,
 			     struct kmem_cache *root_cache)
 {
@@ -3164,6 +3141,7 @@ void memcg_free_cache_params(struct kmem_cache *s)
 static void memcg_kmem_create_cache(struct mem_cgroup *memcg,
 				    struct kmem_cache *root_cache)
 {
+	static char *memcg_name_buf;
 	struct kmem_cache *cachep;
 	int id;
 
@@ -3179,7 +3157,14 @@ static void memcg_kmem_create_cache(struct mem_cgroup *memcg,
 	if (cache_from_memcg_idx(root_cache, id))
 		return;
 
-	cachep = kmem_cache_create_memcg(memcg, root_cache);
+	if (!memcg_name_buf) {
+		memcg_name_buf = kmalloc(NAME_MAX + 1, GFP_KERNEL);
+		if (!memcg_name_buf)
+			return;
+	}
+
+	cgroup_name(memcg->css.cgroup, memcg_name_buf, NAME_MAX + 1);
+	cachep = kmem_cache_create_memcg(memcg, root_cache, memcg_name_buf);
 	/*
 	 * If we could not create a memcg cache, do not complain, because
 	 * that's not critical at all as we can always proceed with the root
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 7e348cff814d..32175617cb75 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -264,13 +264,15 @@ EXPORT_SYMBOL(kmem_cache_create);
  * kmem_cache_create_memcg - Create a cache for a memory cgroup.
  * @memcg: The memory cgroup the new cache is for.
  * @root_cache: The parent of the new cache.
+ * @memcg_name: The name of the memory cgroup (used for naming the new cache).
  *
  * This function attempts to create a kmem cache that will serve allocation
  * requests going from @memcg to @root_cache. The new cache inherits properties
  * from its parent.
  */
 struct kmem_cache *kmem_cache_create_memcg(struct mem_cgroup *memcg,
-					   struct kmem_cache *root_cache)
+					   struct kmem_cache *root_cache,
+					   const char *memcg_name)
 {
 	struct kmem_cache *s = NULL;
 	char *cache_name;
@@ -280,7 +282,8 @@ struct kmem_cache *kmem_cache_create_memcg(struct mem_cgroup *memcg,
 
 	mutex_lock(&slab_mutex);
 
-	cache_name = memcg_create_cache_name(memcg, root_cache);
+	cache_name = kasprintf(GFP_KERNEL, "%s(%d:%s)", root_cache->name,
+			       memcg_cache_id(memcg), memcg_name);
 	if (!cache_name)
 		goto out_unlock;
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
