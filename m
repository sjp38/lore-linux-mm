Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f41.google.com (mail-la0-f41.google.com [209.85.215.41])
	by kanga.kvack.org (Postfix) with ESMTP id 27A166B0044
	for <linux-mm@kvack.org>; Mon,  6 Jan 2014 03:45:40 -0500 (EST)
Received: by mail-la0-f41.google.com with SMTP id c6so4491330lan.14
        for <linux-mm@kvack.org>; Mon, 06 Jan 2014 00:45:39 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id g3si35752009lbd.79.2014.01.06.00.45.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 06 Jan 2014 00:45:38 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH RESEND 02/11] memcg, slab: kmem_cache_create_memcg(): fix memleak on fail path
Date: Mon, 6 Jan 2014 12:44:53 +0400
Message-ID: <f8c4bec814e348f3992b73abc3b0af89a481f5ee.1388996525.git.vdavydov@parallels.com>
In-Reply-To: <cover.1388996525.git.vdavydov@parallels.com>
References: <cover.1388996525.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz, akpm@linux-foundation.org
Cc: glommer@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>

We do not free the cache's memcg_params if __kmem_cache_create fails.
Fix this.

Plus, rename memcg_register_cache() to memcg_alloc_cache_params(),
because it actually does not register the cache anywhere, but simply
initialize kmem_cache::memcg_params.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Glauber Costa <glommer@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Balbir Singh <bsingharora@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 include/linux/memcontrol.h |   14 +++++++++-----
 mm/memcontrol.c            |   11 ++++++++---
 mm/slab_common.c           |    3 ++-
 3 files changed, 19 insertions(+), 9 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index b3e7a66..5e6541f 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -497,8 +497,9 @@ void __memcg_kmem_commit_charge(struct page *page,
 void __memcg_kmem_uncharge_pages(struct page *page, int order);
 
 int memcg_cache_id(struct mem_cgroup *memcg);
-int memcg_register_cache(struct mem_cgroup *memcg, struct kmem_cache *s,
-			 struct kmem_cache *root_cache);
+int memcg_alloc_cache_params(struct mem_cgroup *memcg, struct kmem_cache *s,
+			     struct kmem_cache *root_cache);
+void memcg_free_cache_params(struct kmem_cache *s);
 void memcg_release_cache(struct kmem_cache *cachep);
 void memcg_cache_list_add(struct mem_cgroup *memcg, struct kmem_cache *cachep);
 
@@ -640,13 +641,16 @@ static inline int memcg_cache_id(struct mem_cgroup *memcg)
 	return -1;
 }
 
-static inline int
-memcg_register_cache(struct mem_cgroup *memcg, struct kmem_cache *s,
-		     struct kmem_cache *root_cache)
+static inline int memcg_alloc_cache_params(struct mem_cgroup *memcg,
+		struct kmem_cache *s, struct kmem_cache *root_cache)
 {
 	return 0;
 }
 
+static inline void memcg_free_cache_params(struct kmem_cache *s);
+{
+}
+
 static inline void memcg_release_cache(struct kmem_cache *cachep)
 {
 }
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index bf5e894..8c47910 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3195,8 +3195,8 @@ int memcg_update_cache_size(struct kmem_cache *s, int num_groups)
 	return 0;
 }
 
-int memcg_register_cache(struct mem_cgroup *memcg, struct kmem_cache *s,
-			 struct kmem_cache *root_cache)
+int memcg_alloc_cache_params(struct mem_cgroup *memcg, struct kmem_cache *s,
+			     struct kmem_cache *root_cache)
 {
 	size_t size;
 
@@ -3224,6 +3224,11 @@ int memcg_register_cache(struct mem_cgroup *memcg, struct kmem_cache *s,
 	return 0;
 }
 
+void memcg_free_cache_params(struct kmem_cache *s)
+{
+	kfree(s->memcg_params);
+}
+
 void memcg_release_cache(struct kmem_cache *s)
 {
 	struct kmem_cache *root;
@@ -3252,7 +3257,7 @@ void memcg_release_cache(struct kmem_cache *s)
 
 	css_put(&memcg->css);
 out:
-	kfree(s->memcg_params);
+	memcg_free_cache_params(s);
 }
 
 /*
diff --git a/mm/slab_common.c b/mm/slab_common.c
index f70df3e..70f9e24 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -205,7 +205,7 @@ kmem_cache_create_memcg(struct mem_cgroup *memcg, const char *name, size_t size,
 	if (!s->name)
 		goto out_free_cache;
 
-	err = memcg_register_cache(memcg, s, parent_cache);
+	err = memcg_alloc_cache_params(memcg, s, parent_cache);
 	if (err)
 		goto out_free_cache;
 
@@ -235,6 +235,7 @@ out_unlock:
 	return s;
 
 out_free_cache:
+	memcg_free_cache_params(s);
 	kfree(s->name);
 	kmem_cache_free(kmem_cache, s);
 	goto out_unlock;
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
