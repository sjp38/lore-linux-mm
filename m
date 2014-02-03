Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f44.google.com (mail-la0-f44.google.com [209.85.215.44])
	by kanga.kvack.org (Postfix) with ESMTP id 2BB896B0037
	for <linux-mm@kvack.org>; Mon,  3 Feb 2014 10:54:47 -0500 (EST)
Received: by mail-la0-f44.google.com with SMTP id hr13so1852301lab.17
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 07:54:46 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id e6si10646297lam.114.2014.02.03.07.54.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Feb 2014 07:54:44 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH v2 1/7] memcg, slab: never try to merge memcg caches
Date: Mon, 3 Feb 2014 19:54:36 +0400
Message-ID: <e01955ecb281ec635869830e45e6a16f90a760f0.1391441746.git.vdavydov@parallels.com>
In-Reply-To: <cover.1391441746.git.vdavydov@parallels.com>
References: <cover.1391441746.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.cz, rientjes@google.com, penberg@kernel.org, cl@linux.com, glommer@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@openvz.org

Suppose we are creating memcg cache A that could be merged with cache B
of the same memcg. Since any memcg cache has the same parameters as its
parent cache, parent caches PA and PB of memcg caches A and B must be
mergeable too. That means PA was merged with PB on creation or vice
versa, i.e. PA = PB. From that it follows that A = B, and we couldn't
even try to create cache B, because it already exists - a contradiction.

So let's remove unused code responsible for merging memcg caches.

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
index 7e3e0458bce4..8659e7184338 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3692,9 +3692,8 @@ static int slab_unmergeable(struct kmem_cache *s)
 	return 0;
 }
 
-static struct kmem_cache *find_mergeable(struct mem_cgroup *memcg, size_t size,
-		size_t align, unsigned long flags, const char *name,
-		void (*ctor)(void *))
+static struct kmem_cache *find_mergeable(size_t size, size_t align,
+		unsigned long flags, const char *name, void (*ctor)(void *))
 {
 	struct kmem_cache *s;
 
@@ -3713,11 +3712,14 @@ static struct kmem_cache *find_mergeable(struct mem_cgroup *memcg, size_t size,
 		if (slab_unmergeable(s))
 			continue;
 
+		if (!is_root_cache(s))
+			continue;
+
 		if (size > s->size)
 			continue;
 
 		if ((flags & SLUB_MERGE_SAME) != (s->flags & SLUB_MERGE_SAME))
-				continue;
+			continue;
 		/*
 		 * Check if alignment is compatible.
 		 * Courtesy of Adrian Drzewiecki
@@ -3728,21 +3730,18 @@ static struct kmem_cache *find_mergeable(struct mem_cgroup *memcg, size_t size,
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
