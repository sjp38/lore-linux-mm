Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f177.google.com (mail-lb0-f177.google.com [209.85.217.177])
	by kanga.kvack.org (Postfix) with ESMTP id 16AD26B006E
	for <linux-mm@kvack.org>; Thu, 20 Feb 2014 02:22:15 -0500 (EST)
Received: by mail-lb0-f177.google.com with SMTP id 10so1030654lbg.8
        for <linux-mm@kvack.org>; Wed, 19 Feb 2014 23:22:15 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id e8si2522769lbc.132.2014.02.19.23.22.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Feb 2014 23:22:14 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm v3 1/7] memcg, slab: never try to merge memcg caches
Date: Thu, 20 Feb 2014 11:22:03 +0400
Message-ID: <7d7793c8d542d799af0cb797be19a60567d042e1.1392879001.git.vdavydov@parallels.com>
In-Reply-To: <cover.1392879001.git.vdavydov@parallels.com>
References: <cover.1392879001.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz, akpm@linux-foundation.org
Cc: rientjes@google.com, penberg@kernel.org, cl@linux.com, glommer@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@openvz.org

When a kmem cache is created (kmem_cache_create_memcg()), we first try
to find a compatible cache that already exists and can handle requests
from the new cache, i.e. has the same object size, alignment, ctor, etc.
If there is such a cache, we do not create any new caches, instead we
simply increment the refcount of the cache found and return it.

Currently we do this procedure not only when creating root caches, but
also for memcg caches. However, there is no point in that, because, as
every memcg cache has exactly the same parameters as its parent and
cache merging cannot be turned off in runtime (only on boot by passing
"slub_nomerge"), the root caches of any two potentially mergeable memcg
caches should be merged already, i.e. it must be the same root cache,
and therefore we couldn't even get to the memcg cache creation, because
it already exists.

The only exception is boot caches - they are explicitly forbidden to be
merged by setting their refcount to -1. There are currently only two of
them - kmem_cache and kmem_cache_node, which are used in slab internals
(I do not count kmalloc caches as their refcount is set to 1 immediately
after creation). Since they are prevented from merging preliminary I
guess we should avoid to merge their children too.

So let's remove the useless code responsible for merging memcg caches.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 mm/slab.h        |   21 ++++-----------------
 mm/slab_common.c |    8 +++++---
 mm/slub.c        |   19 +++++++++----------
 3 files changed, 18 insertions(+), 30 deletions(-)

diff --git a/mm/slab.h b/mm/slab.h
index 8184a7cde272..3045316b7c9d 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -55,12 +55,12 @@ extern void create_boot_cache(struct kmem_cache *, const char *name,
 struct mem_cgroup;
 #ifdef CONFIG_SLUB
 struct kmem_cache *
-__kmem_cache_alias(struct mem_cgroup *memcg, const char *name, size_t size,
-		   size_t align, unsigned long flags, void (*ctor)(void *));
+__kmem_cache_alias(const char *name, size_t size, size_t align,
+		   unsigned long flags, void (*ctor)(void *));
 #else
 static inline struct kmem_cache *
-__kmem_cache_alias(struct mem_cgroup *memcg, const char *name, size_t size,
-		   size_t align, unsigned long flags, void (*ctor)(void *))
+__kmem_cache_alias(const char *name, size_t size, size_t align,
+		   unsigned long flags, void (*ctor)(void *))
 { return NULL; }
 #endif
 
@@ -119,13 +119,6 @@ static inline bool is_root_cache(struct kmem_cache *s)
 	return !s->memcg_params || s->memcg_params->is_root_cache;
 }
 
-static inline bool cache_match_memcg(struct kmem_cache *cachep,
-				     struct mem_cgroup *memcg)
-{
-	return (is_root_cache(cachep) && !memcg) ||
-				(cachep->memcg_params->memcg == memcg);
-}
-
 static inline void memcg_bind_pages(struct kmem_cache *s, int order)
 {
 	if (!is_root_cache(s))
@@ -204,12 +197,6 @@ static inline bool is_root_cache(struct kmem_cache *s)
 	return true;
 }
 
-static inline bool cache_match_memcg(struct kmem_cache *cachep,
-				     struct mem_cgroup *memcg)
-{
-	return true;
-}
-
 static inline void memcg_bind_pages(struct kmem_cache *s, int order)
 {
 }
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 1ec3c619ba04..e77b51eb7347 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -200,9 +200,11 @@ kmem_cache_create_memcg(struct mem_cgroup *memcg, const char *name, size_t size,
 	 */
 	flags &= CACHE_CREATE_MASK;
 
-	s = __kmem_cache_alias(memcg, name, size, align, flags, ctor);
-	if (s)
-		goto out_unlock;
+	if (!memcg) {
+		s = __kmem_cache_alias(name, size, align, flags, ctor);
+		if (s)
+			goto out_unlock;
+	}
 
 	err = -ENOMEM;
 	s = kmem_cache_zalloc(kmem_cache, GFP_KERNEL);
diff --git a/mm/slub.c b/mm/slub.c
index fe6d7be22ef0..2f40e615368f 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3685,6 +3685,9 @@ static int slab_unmergeable(struct kmem_cache *s)
 	if (slub_nomerge || (s->flags & SLUB_NEVER_MERGE))
 		return 1;
 
+	if (!is_root_cache(s))
+		return 1;
+
 	if (s->ctor)
 		return 1;
 
@@ -3697,9 +3700,8 @@ static int slab_unmergeable(struct kmem_cache *s)
 	return 0;
 }
 
-static struct kmem_cache *find_mergeable(struct mem_cgroup *memcg, size_t size,
-		size_t align, unsigned long flags, const char *name,
-		void (*ctor)(void *))
+static struct kmem_cache *find_mergeable(size_t size, size_t align,
+		unsigned long flags, const char *name, void (*ctor)(void *))
 {
 	struct kmem_cache *s;
 
@@ -3722,7 +3724,7 @@ static struct kmem_cache *find_mergeable(struct mem_cgroup *memcg, size_t size,
 			continue;
 
 		if ((flags & SLUB_MERGE_SAME) != (s->flags & SLUB_MERGE_SAME))
-				continue;
+			continue;
 		/*
 		 * Check if alignment is compatible.
 		 * Courtesy of Adrian Drzewiecki
@@ -3733,21 +3735,18 @@ static struct kmem_cache *find_mergeable(struct mem_cgroup *memcg, size_t size,
 		if (s->size - size >= sizeof(void *))
 			continue;
 
-		if (!cache_match_memcg(s, memcg))
-			continue;
-
 		return s;
 	}
 	return NULL;
 }
 
 struct kmem_cache *
-__kmem_cache_alias(struct mem_cgroup *memcg, const char *name, size_t size,
-		   size_t align, unsigned long flags, void (*ctor)(void *))
+__kmem_cache_alias(const char *name, size_t size, size_t align,
+		   unsigned long flags, void (*ctor)(void *))
 {
 	struct kmem_cache *s;
 
-	s = find_mergeable(memcg, size, align, flags, name, ctor);
+	s = find_mergeable(size, align, flags, name, ctor);
 	if (s) {
 		s->refcount++;
 		/*
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
