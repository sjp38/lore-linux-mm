Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id B978D6B006E
	for <linux-mm@kvack.org>; Tue,  9 Dec 2014 12:11:56 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id p10so917714pdj.27
        for <linux-mm@kvack.org>; Tue, 09 Dec 2014 09:11:56 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id tt9si2825503pac.51.2014.12.09.09.11.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Dec 2014 09:11:54 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm] memcg: zap memcg_name argument of memcg_create_kmem_cache
Date: Tue, 9 Dec 2014 20:11:44 +0300
Message-ID: <1418145104-31179-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Instead of passing the name of the memory cgroup which the cache is
created for in the memcg_name_argument, let's obtain it immediately in
memcg_create_kmem_cache.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/slab.h |    3 +--
 mm/memcontrol.c      |    5 +----
 mm/slab_common.c     |    9 +++++----
 3 files changed, 7 insertions(+), 10 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 9a139b637069..eca9ed303a1b 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -117,8 +117,7 @@ struct kmem_cache *kmem_cache_create(const char *, size_t, size_t,
 			void (*)(void *));
 #ifdef CONFIG_MEMCG_KMEM
 struct kmem_cache *memcg_create_kmem_cache(struct mem_cgroup *,
-					   struct kmem_cache *,
-					   const char *);
+					   struct kmem_cache *);
 #endif
 void kmem_cache_destroy(struct kmem_cache *);
 int kmem_cache_shrink(struct kmem_cache *);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e9086513a42f..e4263e10456c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2606,8 +2606,6 @@ void memcg_update_array_size(int num)
 static void memcg_register_cache(struct mem_cgroup *memcg,
 				 struct kmem_cache *root_cache)
 {
-	static char memcg_name_buf[NAME_MAX + 1]; /* protected by
-						     memcg_slab_mutex */
 	struct kmem_cache *cachep;
 	int id;
 
@@ -2623,8 +2621,7 @@ static void memcg_register_cache(struct mem_cgroup *memcg,
 	if (cache_from_memcg_idx(root_cache, id))
 		return;
 
-	cgroup_name(memcg->css.cgroup, memcg_name_buf, NAME_MAX + 1);
-	cachep = memcg_create_kmem_cache(memcg, root_cache, memcg_name_buf);
+	cachep = memcg_create_kmem_cache(memcg, root_cache);
 	/*
 	 * If we could not create a memcg cache, do not complain, because
 	 * that's not critical at all as we can always proceed with the root
diff --git a/mm/slab_common.c b/mm/slab_common.c
index e03dd6f2a272..b958f27d1833 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -430,16 +430,15 @@ EXPORT_SYMBOL(kmem_cache_create);
  * memcg_create_kmem_cache - Create a cache for a memory cgroup.
  * @memcg: The memory cgroup the new cache is for.
  * @root_cache: The parent of the new cache.
- * @memcg_name: The name of the memory cgroup (used for naming the new cache).
  *
  * This function attempts to create a kmem cache that will serve allocation
  * requests going from @memcg to @root_cache. The new cache inherits properties
  * from its parent.
  */
 struct kmem_cache *memcg_create_kmem_cache(struct mem_cgroup *memcg,
-					   struct kmem_cache *root_cache,
-					   const char *memcg_name)
+					   struct kmem_cache *root_cache)
 {
+	static char memcg_name_buf[NAME_MAX + 1]; /* protected by slab_mutex */
 	struct kmem_cache *s = NULL;
 	char *cache_name;
 
@@ -448,8 +447,10 @@ struct kmem_cache *memcg_create_kmem_cache(struct mem_cgroup *memcg,
 
 	mutex_lock(&slab_mutex);
 
+	cgroup_name(mem_cgroup_css(memcg)->cgroup,
+		    memcg_name_buf, sizeof(memcg_name_buf));
 	cache_name = kasprintf(GFP_KERNEL, "%s(%d:%s)", root_cache->name,
-			       memcg_cache_id(memcg), memcg_name);
+			       memcg_cache_id(memcg), memcg_name_buf);
 	if (!cache_name)
 		goto out_unlock;
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
