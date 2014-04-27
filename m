Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id E6EAE6B006E
	for <linux-mm@kvack.org>; Sun, 27 Apr 2014 05:04:24 -0400 (EDT)
Received: by mail-la0-f43.google.com with SMTP id c6so4300905lan.30
        for <linux-mm@kvack.org>; Sun, 27 Apr 2014 02:04:19 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id q5si2788909lah.122.2014.04.27.02.04.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 Apr 2014 02:04:18 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm v2 1/6] memcg: get rid of memcg_create_cache_name
Date: Sun, 27 Apr 2014 13:04:03 +0400
Message-ID: <5e485fc5c7374726eecace315cad91ff4d8be38f.1398587474.git.vdavydov@parallels.com>
In-Reply-To: <cover.1398587474.git.vdavydov@parallels.com>
References: <cover.1398587474.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.cz, hannes@cmpxchg.org, glommer@gmail.com, cl@linux-foundation.org, penberg@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

Instead of calling back to memcontrol.c from kmem_cache_create_memcg in
order to just create the name of a per memcg cache, let's allocate it in
place. We only need to pass the memcg name to kmem_cache_create_memcg
for that - everything else can be done in slab_common.c.

This patch also turns the buffer used to store memcg names to be
statically allocated while before it was kmalloc'ed on first use.
Saving those 256 bytes isn't worth complicating the code. If someone is
so tight on memory, they'd better disable CONFIG_MEMCG_KMEM altogether.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/memcontrol.h |    2 --
 include/linux/slab.h       |    3 ++-
 mm/memcontrol.c            |   27 +++------------------------
 mm/slab_common.c           |    7 +++++--
 4 files changed, 10 insertions(+), 29 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 1fa23244fe37..dfc2929a3877 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -492,8 +492,6 @@ void __memcg_kmem_uncharge_pages(struct page *page, int order);
 
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
index 19d620b3d69c..605d72044533 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3105,29 +3105,6 @@ int memcg_update_cache_size(struct kmem_cache *s, int num_groups)
 	return 0;
 }
 
-char *memcg_create_cache_name(struct mem_cgroup *memcg,
-			      struct kmem_cache *root_cache)
-{
-	static char *buf = NULL;
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
@@ -3168,6 +3145,7 @@ void memcg_free_cache_params(struct kmem_cache *s)
 static void memcg_kmem_create_cache(struct mem_cgroup *memcg,
 				    struct kmem_cache *root_cache)
 {
+	static char memcg_name[NAME_MAX + 1];
 	struct kmem_cache *cachep;
 	int id;
 
@@ -3183,7 +3161,8 @@ static void memcg_kmem_create_cache(struct mem_cgroup *memcg,
 	if (cache_from_memcg_idx(root_cache, id))
 		return;
 
-	cachep = kmem_cache_create_memcg(memcg, root_cache);
+	cgroup_name(memcg->css.cgroup, memcg_name, NAME_MAX + 1);
+	cachep = kmem_cache_create_memcg(memcg, root_cache, memcg_name);
 	/*
 	 * If we could not create a memcg cache, do not complain, because
 	 * that's not critical at all as we can always proceed with the root
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 4f16f374392a..6b6397d2e05e 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -264,13 +264,15 @@ EXPORT_SYMBOL(kmem_cache_create);
  * kmem_cache_create_memcg - Create a cache for a memory cgroup.
  * @memcg: The memory cgroup the new cache is for.
  * @root_cache: The parent of the new cache.
+ * @memcg_name: The name of the memory cgroup.
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
