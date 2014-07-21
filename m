Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id CE2B26B0037
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 07:47:32 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id z10so9037621pdj.2
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 04:47:32 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id f17si7000932pdm.451.2014.07.21.04.47.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Jul 2014 04:47:31 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 2/6] slab: use mem_cgroup_id for per memcg cache naming
Date: Mon, 21 Jul 2014 15:47:12 +0400
Message-ID: <38af6ca12228013f57ae96bee04fba831fad1e21.1405941342.git.vdavydov@parallels.com>
In-Reply-To: <cover.1405941342.git.vdavydov@parallels.com>
References: <cover.1405941342.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.cz, hannes@cmpxchg.org, cl@linux.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Currently, we use memcg_cache_id as a part of a per memcg cache name.
Since memcg_cache_id is released only on css free, this guarantees cache
name uniqueness.

However, it's a bad practice to keep memcg_cache_id till css free,
because it occupies a slot in kmem_cache->memcg_params->memcg_caches
arrays. So I'm going to make memcg release memcg_cache_id on css
offline. As a result, memcg_cache_id won't guarantee cache name
uniqueness any more.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/slab.h |    2 +-
 mm/memcontrol.c      |   13 +++++++++++--
 mm/slab_common.c     |   15 +++------------
 3 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 1d9abb7d22a0..14888328e96b 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -118,7 +118,7 @@ struct kmem_cache *kmem_cache_create(const char *, size_t, size_t,
 #ifdef CONFIG_MEMCG_KMEM
 struct kmem_cache *memcg_create_kmem_cache(struct mem_cgroup *,
 					   struct kmem_cache *,
-					   const char *);
+					   char *);
 #endif
 void kmem_cache_destroy(struct kmem_cache *);
 int kmem_cache_shrink(struct kmem_cache *);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 85dd94f2ecce..7d5c4a5e4c74 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3003,6 +3003,7 @@ static void memcg_register_cache(struct mem_cgroup *memcg,
 	static char memcg_name_buf[NAME_MAX + 1]; /* protected by
 						     memcg_slab_mutex */
 	struct kmem_cache *cachep;
+	char *cache_name;
 	int id;
 
 	lockdep_assert_held(&memcg_slab_mutex);
@@ -3018,14 +3019,22 @@ static void memcg_register_cache(struct mem_cgroup *memcg,
 		return;
 
 	cgroup_name(memcg->css.cgroup, memcg_name_buf, NAME_MAX + 1);
-	cachep = memcg_create_kmem_cache(memcg, root_cache, memcg_name_buf);
+
+	cache_name = kasprintf(GFP_KERNEL, "%s(%d:%s)", root_cache->name,
+			       mem_cgroup_id(memcg), memcg_name_buf);
+	if (!cache_name)
+		return;
+
+	cachep = memcg_create_kmem_cache(memcg, root_cache, cache_name);
 	/*
 	 * If we could not create a memcg cache, do not complain, because
 	 * that's not critical at all as we can always proceed with the root
 	 * cache.
 	 */
-	if (!cachep)
+	if (!cachep) {
+		kfree(cache_name);
 		return;
+	}
 
 	list_add(&cachep->memcg_params->list, &memcg->memcg_slab_caches);
 
diff --git a/mm/slab_common.c b/mm/slab_common.c
index d319502b2403..a847fc86ac32 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -266,7 +266,7 @@ EXPORT_SYMBOL(kmem_cache_create);
  * memcg_create_kmem_cache - Create a cache for a memory cgroup.
  * @memcg: The memory cgroup the new cache is for.
  * @root_cache: The parent of the new cache.
- * @memcg_name: The name of the memory cgroup (used for naming the new cache).
+ * @cache_name: The string to be used as the new cache name.
  *
  * This function attempts to create a kmem cache that will serve allocation
  * requests going from @memcg to @root_cache. The new cache inherits properties
@@ -274,31 +274,22 @@ EXPORT_SYMBOL(kmem_cache_create);
  */
 struct kmem_cache *memcg_create_kmem_cache(struct mem_cgroup *memcg,
 					   struct kmem_cache *root_cache,
-					   const char *memcg_name)
+					   char *cache_name)
 {
 	struct kmem_cache *s = NULL;
-	char *cache_name;
 
 	get_online_cpus();
 	get_online_mems();
 
 	mutex_lock(&slab_mutex);
 
-	cache_name = kasprintf(GFP_KERNEL, "%s(%d:%s)", root_cache->name,
-			       memcg_cache_id(memcg), memcg_name);
-	if (!cache_name)
-		goto out_unlock;
-
 	s = do_kmem_cache_create(cache_name, root_cache->object_size,
 				 root_cache->size, root_cache->align,
 				 root_cache->flags, root_cache->ctor,
 				 memcg, root_cache);
-	if (IS_ERR(s)) {
-		kfree(cache_name);
+	if (IS_ERR(s))
 		s = NULL;
-	}
 
-out_unlock:
 	mutex_unlock(&slab_mutex);
 
 	put_online_mems();
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
