Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f177.google.com (mail-lb0-f177.google.com [209.85.217.177])
	by kanga.kvack.org (Postfix) with ESMTP id D6B13900002
	for <linux-mm@kvack.org>; Mon,  7 Jul 2014 08:00:31 -0400 (EDT)
Received: by mail-lb0-f177.google.com with SMTP id u10so2778532lbd.36
        for <linux-mm@kvack.org>; Mon, 07 Jul 2014 05:00:31 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id sp4si68676892lbb.9.2014.07.07.05.00.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Jul 2014 05:00:30 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 3/8] slab: guarantee unique kmem cache naming
Date: Mon, 7 Jul 2014 16:00:08 +0400
Message-ID: <ac370bc33134b5f6df0b9a343a854b9e153793ce.1404733720.git.vdavydov@parallels.com>
In-Reply-To: <cover.1404733720.git.vdavydov@parallels.com>
References: <cover.1404733720.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.cz, hannes@cmpxchg.org, cl@linux.com, glommer@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Unique names are necessary to avoid sysfs name clashes in SLUB's
implementation. Currently we give per memcg caches unique names by
appending memcg name and id to the root cache's name. However, it won't
be enough when kmem cache re-parenting is introduced, because then memcg
id and name can be reused resulting in a name conflict. To solve it,
let's allocate a unique id for each per memcg cache and use it in cache
names.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/slab.h |    2 ++
 mm/slab_common.c     |   36 ++++++++++++++++++++++++++++++------
 2 files changed, 32 insertions(+), 6 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 640e6a655d51..c6680a885910 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -529,6 +529,7 @@ static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
  * @root_cache: pointer to the global, root cache, this cache was derived from
  * @siblings: list_head for the list of all child caches of the root_cache
  * @refcnt: reference counter
+ * @id: unique id
  * @dead: set to true when owner memcg is turned offline
  * @unregister_work: worker to destroy the cache
  */
@@ -547,6 +548,7 @@ struct memcg_cache_params {
 			struct kmem_cache *root_cache;
 			struct list_head siblings;
 			atomic_long_t refcnt;
+			int id;
 			bool dead;
 			struct work_struct unregister_work;
 		};
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 95a8f772b0d1..20ec4d47c161 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -261,6 +261,15 @@ EXPORT_SYMBOL(kmem_cache_create);
 
 #ifdef CONFIG_MEMCG_KMEM
 /*
+ * To avoid sysfs name conflicts all kmem caches must be uniquely named.
+ * Appending cgroup id and name to per memcg caches is not enough, because they
+ * can be reused before cache is destroyed. So we assign a unique id to each
+ * per memcg cache. The ids are used for creating unique names and are
+ * allocated by the ida defined below.
+ */
+static DEFINE_IDA(memcg_cache_ida);
+
+/*
  * memcg_create_kmem_cache - Create a cache for a memory cgroup.
  * @memcg: The memory cgroup the new cache is for.
  * @root_cache: The parent of the new cache.
@@ -276,27 +285,32 @@ struct kmem_cache *memcg_create_kmem_cache(struct mem_cgroup *memcg,
 {
 	struct kmem_cache *s = NULL;
 	char *cache_name;
+	int id;
 
 	get_online_cpus();
 	get_online_mems();
 
 	mutex_lock(&slab_mutex);
 
-	cache_name = kasprintf(GFP_KERNEL, "%s(%d:%s)", root_cache->name,
-			       memcg_cache_id(memcg), memcg_name);
-	if (!cache_name)
+	id = ida_simple_get(&memcg_cache_ida, 0, 0, GFP_KERNEL);
+	if (id < 0)
 		goto out_unlock;
 
+	cache_name = kasprintf(GFP_KERNEL, "%s(%d:%s)(%d)", root_cache->name,
+			       memcg_cache_id(memcg), memcg_name, id);
+	if (!cache_name)
+		goto out_free_id;
+
 	s = do_kmem_cache_create(cache_name, root_cache->object_size,
 				 root_cache->size, root_cache->align,
 				 root_cache->flags, root_cache->ctor,
 				 memcg, root_cache);
 	if (IS_ERR(s)) {
-		kfree(cache_name);
 		s = NULL;
-		goto out_unlock;
+		goto out_free_name;
 	}
 
+	s->memcg_params->id = id;
 	list_add(&s->memcg_params->siblings,
 		 &root_cache->memcg_params->children);
 
@@ -307,6 +321,12 @@ out_unlock:
 	put_online_cpus();
 
 	return s;
+
+out_free_name:
+	kfree(cache_name);
+out_free_id:
+	ida_simple_remove(&memcg_cache_ida, id);
+	goto out_unlock;
 }
 
 static int memcg_cleanup_cache_params(struct kmem_cache *s)
@@ -330,6 +350,11 @@ static int memcg_cleanup_cache_params(struct kmem_cache *s)
 
 void slab_kmem_cache_release(struct kmem_cache *s)
 {
+#ifdef CONFIG_MEMCG_KMEM
+	if (!is_root_cache(s))
+		ida_simple_remove(&memcg_cache_ida, s->memcg_params->id);
+#endif
+	memcg_free_cache_params(s);
 	kfree(s->name);
 	kmem_cache_free(kmem_cache, s);
 }
@@ -365,7 +390,6 @@ void kmem_cache_destroy(struct kmem_cache *s)
 	if (s->flags & SLAB_DESTROY_BY_RCU)
 		rcu_barrier();
 
-	memcg_free_cache_params(s);
 #ifdef SLAB_SUPPORTS_SYSFS
 	sysfs_slab_remove(s);
 #else
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
