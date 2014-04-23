Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f180.google.com (mail-lb0-f180.google.com [209.85.217.180])
	by kanga.kvack.org (Postfix) with ESMTP id 6E8446B0071
	for <linux-mm@kvack.org>; Wed, 23 Apr 2014 03:13:25 -0400 (EDT)
Received: by mail-lb0-f180.google.com with SMTP id 10so415500lbg.25
        for <linux-mm@kvack.org>; Wed, 23 Apr 2014 00:13:24 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id g7si45584lag.186.2014.04.23.00.13.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Apr 2014 00:13:23 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm v3 2/3] memcg, slab: merge memcg_{bind,release}_pages to memcg_{un}charge_slab
Date: Wed, 23 Apr 2014 11:13:14 +0400
Message-ID: <bab7cdfd154630e45b9c834d962e8ff0764e5f78.1398235153.git.vdavydov@parallels.com>
In-Reply-To: <cover.1398235153.git.vdavydov@parallels.com>
References: <cover.1398235153.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: hannes@cmpxchg.org, mhocko@suse.cz, glommer@gmail.com, cl@linux-foundation.org, penberg@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

Currently we have two pairs of kmemcg-related functions that are called
on slab alloc/free. The first is memcg_{bind,release}_pages that count
the total number of pages allocated on a kmem cache. The second is
memcg_{un}charge_slab that {un}charge slab pages to kmemcg resource
counter. Let's just merge them to keep the code clean.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/memcontrol.h |    4 ++--
 mm/memcontrol.c            |   22 ++++++++++++++++++++--
 mm/slab.c                  |    2 --
 mm/slab.h                  |   25 ++-----------------------
 mm/slub.c                  |    2 --
 5 files changed, 24 insertions(+), 31 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 087a45314181..d38d190f4cec 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -506,8 +506,8 @@ void memcg_update_array_size(int num_groups);
 struct kmem_cache *
 __memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp);
 
-int memcg_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp, u64 size);
-void memcg_uncharge_kmem(struct mem_cgroup *memcg, u64 size);
+int __memcg_charge_slab(struct kmem_cache *cachep, gfp_t gfp, int order);
+void __memcg_uncharge_slab(struct kmem_cache *cachep, int order);
 
 int __kmem_cache_destroy_memcg_children(struct kmem_cache *s);
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 4c9b0cbd06ed..73fe4db2cecd 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2951,7 +2951,7 @@ static int mem_cgroup_slabinfo_read(struct seq_file *m, void *v)
 }
 #endif
 
-int memcg_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp, u64 size)
+static int memcg_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp, u64 size)
 {
 	struct res_counter *fail_res;
 	int ret = 0;
@@ -2989,7 +2989,7 @@ int memcg_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp, u64 size)
 	return ret;
 }
 
-void memcg_uncharge_kmem(struct mem_cgroup *memcg, u64 size)
+static void memcg_uncharge_kmem(struct mem_cgroup *memcg, u64 size)
 {
 	res_counter_uncharge(&memcg->res, size);
 	if (do_swap_account)
@@ -3387,6 +3387,24 @@ static void memcg_create_cache_enqueue(struct mem_cgroup *memcg,
 	__memcg_create_cache_enqueue(memcg, cachep);
 	memcg_resume_kmem_account();
 }
+
+int __memcg_charge_slab(struct kmem_cache *cachep, gfp_t gfp, int order)
+{
+	int res;
+
+	res = memcg_charge_kmem(cachep->memcg_params->memcg, gfp,
+				PAGE_SIZE << order);
+	if (!res)
+		atomic_add(1 << order, &cachep->memcg_params->nr_pages);
+	return res;
+}
+
+void __memcg_uncharge_slab(struct kmem_cache *cachep, int order)
+{
+	memcg_uncharge_kmem(cachep->memcg_params->memcg, PAGE_SIZE << order);
+	atomic_sub(1 << order, &cachep->memcg_params->nr_pages);
+}
+
 /*
  * Return the kmem_cache we're supposed to use for a slab allocation.
  * We try to use the current memcg's version of the cache.
diff --git a/mm/slab.c b/mm/slab.c
index bae9c32d4c8e..3e152b28f27a 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1706,7 +1706,6 @@ static struct page *kmem_getpages(struct kmem_cache *cachep, gfp_t flags,
 	__SetPageSlab(page);
 	if (page->pfmemalloc)
 		SetPageSlabPfmemalloc(page);
-	memcg_bind_pages(cachep, cachep->gfporder);
 
 	if (kmemcheck_enabled && !(cachep->flags & SLAB_NOTRACK)) {
 		kmemcheck_alloc_shadow(page, cachep->gfporder, flags, nodeid);
@@ -1742,7 +1741,6 @@ static void kmem_freepages(struct kmem_cache *cachep, struct page *page)
 	page_mapcount_reset(page);
 	page->mapping = NULL;
 
-	memcg_release_pages(cachep, cachep->gfporder);
 	if (current->reclaim_state)
 		current->reclaim_state->reclaimed_slab += nr_freed;
 	__free_pages(page, cachep->gfporder);
diff --git a/mm/slab.h b/mm/slab.h
index b60c0a30f75f..ba834860fbfd 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -120,18 +120,6 @@ static inline bool is_root_cache(struct kmem_cache *s)
 	return !s->memcg_params || s->memcg_params->is_root_cache;
 }
 
-static inline void memcg_bind_pages(struct kmem_cache *s, int order)
-{
-	if (!is_root_cache(s))
-		atomic_add(1 << order, &s->memcg_params->nr_pages);
-}
-
-static inline void memcg_release_pages(struct kmem_cache *s, int order)
-{
-	if (!is_root_cache(s))
-		atomic_sub(1 << order, &s->memcg_params->nr_pages);
-}
-
 static inline bool slab_equal_or_root(struct kmem_cache *s,
 					struct kmem_cache *p)
 {
@@ -197,8 +185,7 @@ static __always_inline int memcg_charge_slab(struct kmem_cache *s,
 		return 0;
 	if (is_root_cache(s))
 		return 0;
-	return memcg_charge_kmem(s->memcg_params->memcg, gfp,
-				 PAGE_SIZE << order);
+	return __memcg_charge_slab(s, gfp, order);
 }
 
 static __always_inline void memcg_uncharge_slab(struct kmem_cache *s, int order)
@@ -207,7 +194,7 @@ static __always_inline void memcg_uncharge_slab(struct kmem_cache *s, int order)
 		return;
 	if (is_root_cache(s))
 		return;
-	memcg_uncharge_kmem(s->memcg_params->memcg, PAGE_SIZE << order);
+	__memcg_uncharge_slab(s, order);
 }
 #else
 static inline bool is_root_cache(struct kmem_cache *s)
@@ -215,14 +202,6 @@ static inline bool is_root_cache(struct kmem_cache *s)
 	return true;
 }
 
-static inline void memcg_bind_pages(struct kmem_cache *s, int order)
-{
-}
-
-static inline void memcg_release_pages(struct kmem_cache *s, int order)
-{
-}
-
 static inline bool slab_equal_or_root(struct kmem_cache *s,
 				      struct kmem_cache *p)
 {
diff --git a/mm/slub.c b/mm/slub.c
index 521167b1a96a..aa30932c5190 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1427,7 +1427,6 @@ static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
 
 	order = compound_order(page);
 	inc_slabs_node(s, page_to_nid(page), page->objects);
-	memcg_bind_pages(s, order);
 	page->slab_cache = s;
 	__SetPageSlab(page);
 	if (page->pfmemalloc)
@@ -1478,7 +1477,6 @@ static void __free_slab(struct kmem_cache *s, struct page *page)
 	__ClearPageSlabPfmemalloc(page);
 	__ClearPageSlab(page);
 
-	memcg_release_pages(s, order);
 	page_mapcount_reset(page);
 	if (current->reclaim_state)
 		current->reclaim_state->reclaimed_slab += pages;
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
