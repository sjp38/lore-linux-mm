Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id CCDFA680DC6
	for <linux-mm@kvack.org>; Sun,  4 Oct 2015 18:21:57 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so159722953pac.2
        for <linux-mm@kvack.org>; Sun, 04 Oct 2015 15:21:57 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id bz4si35149674pbd.70.2015.10.04.15.21.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Oct 2015 15:21:56 -0700 (PDT)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH 2/3] memcg: unify slab and other kmem pages charging
Date: Mon, 5 Oct 2015 01:21:42 +0300
Message-ID: <41bbfbf1268f7cce22ac9e1656ddc196ae56a409.1443996201.git.vdavydov@virtuozzo.com>
In-Reply-To: <9be67d8528d316ce90d78980bce9ed76b00ffd22.1443996201.git.vdavydov@virtuozzo.com>
References: <9be67d8528d316ce90d78980bce9ed76b00ffd22.1443996201.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

We have memcg_kmem_charge and memcg_kmem_uncharge methods for charging
and uncharging kmem pages to memcg, but currently they are not used for
charging slab pages (i.e. they are only used for charging pages
allocated with alloc_kmem_pages). The only reason why the slab subsystem
uses special helpers, memcg_charge_slab and memcg_uncharge_slab, is that
it needs to charge to the memcg of kmem cache while memcg_charge_kmem
charges to the memcg that the current task belongs to.

To remove this diversity, this patch adds an extra argument to
__memcg_kmem_charge that can be a pointer to a memcg or NULL. If it is
not NULL, the function tries to charge to the memcg it points to,
otherwise it charge to the current context. Next, it makes the slab
subsystem use this function to charge slab pages.

Since memcg_charge_kmem and memcg_uncharge_kmem helpers are now used
only in __memcg_kmem_charge and __memcg_kmem_uncharge, they are inlined.
Since __memcg_kmem_charge stores a pointer to the memcg in the page
struct, we don't need memcg_uncharge_slab anymore and can use
free_kmem_pages. Besides, one can now detect which memcg a slab page
belongs to by reading /proc/kpagecgroup.

Note, this patch switches slab to charge-after-alloc design. Since this
design is already used for all other memcg charges, it should not make
any difference.

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
 include/linux/memcontrol.h |  9 ++----
 mm/memcontrol.c            | 73 +++++++++++++++++++++-------------------------
 mm/slab.c                  | 12 ++++----
 mm/slab.h                  | 24 +++++----------
 mm/slub.c                  | 12 ++++----
 5 files changed, 55 insertions(+), 75 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 9e1f4d5efc56..8a9b7a798f14 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -752,7 +752,8 @@ static inline bool memcg_kmem_is_active(struct mem_cgroup *memcg)
  * conditions, but because they are pretty simple, they are expected to be
  * fast.
  */
-int __memcg_kmem_charge(struct page *page, gfp_t gfp, int order);
+int __memcg_kmem_charge(struct page *page, gfp_t gfp, int order,
+			struct mem_cgroup *memcg);
 void __memcg_kmem_uncharge(struct page *page, int order);
 
 /*
@@ -770,10 +771,6 @@ void __memcg_kmem_put_cache(struct kmem_cache *cachep);
 
 struct mem_cgroup *__mem_cgroup_from_kmem(void *ptr);
 
-int memcg_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp,
-		      unsigned long nr_pages);
-void memcg_uncharge_kmem(struct mem_cgroup *memcg, unsigned long nr_pages);
-
 static inline bool __memcg_kmem_bypass(gfp_t gfp)
 {
 	if (!memcg_kmem_enabled())
@@ -798,7 +795,7 @@ static __always_inline int memcg_kmem_charge(struct page *page,
 {
 	if (__memcg_kmem_bypass(gfp))
 		return 0;
-	return __memcg_kmem_charge(page, gfp, order);
+	return __memcg_kmem_charge(page, gfp, order, NULL);
 }
 
 /**
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 7c0af36fc8d0..1d6413e0dd29 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2215,34 +2215,6 @@ static void commit_charge(struct page *page, struct mem_cgroup *memcg,
 }
 
 #ifdef CONFIG_MEMCG_KMEM
-int memcg_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp,
-		      unsigned long nr_pages)
-{
-	struct page_counter *counter;
-	int ret = 0;
-
-	ret = page_counter_try_charge(&memcg->kmem, nr_pages, &counter);
-	if (ret < 0)
-		return ret;
-
-	ret = try_charge(memcg, gfp, nr_pages);
-	if (ret)
-		page_counter_uncharge(&memcg->kmem, nr_pages);
-
-	return ret;
-}
-
-void memcg_uncharge_kmem(struct mem_cgroup *memcg, unsigned long nr_pages)
-{
-	page_counter_uncharge(&memcg->memory, nr_pages);
-	if (do_swap_account)
-		page_counter_uncharge(&memcg->memsw, nr_pages);
-
-	page_counter_uncharge(&memcg->kmem, nr_pages);
-
-	css_put_many(&memcg->css, nr_pages);
-}
-
 static int memcg_alloc_cache_id(void)
 {
 	int id, size;
@@ -2404,36 +2376,59 @@ void __memcg_kmem_put_cache(struct kmem_cache *cachep)
 		css_put(&cachep->memcg_params.memcg->css);
 }
 
-int __memcg_kmem_charge(struct page *page, gfp_t gfp, int order)
+/*
+ * If @memcg != NULL, charge to @memcg, otherwise charge to the memcg the
+ * current task belongs to.
+ */
+int __memcg_kmem_charge(struct page *page, gfp_t gfp, int order,
+			struct mem_cgroup *memcg)
 {
-	struct mem_cgroup *memcg;
-	int ret;
-
-	memcg = get_mem_cgroup_from_mm(current->mm);
+	struct page_counter *counter;
+	unsigned int nr_pages = 1 << order;
+	bool put = false;
+	int ret = 0;
 
-	if (!memcg_kmem_is_active(memcg)) {
-		css_put(&memcg->css);
-		return 0;
+	if (!memcg) {
+		memcg = get_mem_cgroup_from_mm(current->mm);
+		put = true;
 	}
+	if (!memcg_kmem_is_active(memcg))
+		goto out;
 
-	ret = memcg_charge_kmem(memcg, gfp, 1 << order);
+	ret = page_counter_try_charge(&memcg->kmem, nr_pages, &counter);
+	if (ret)
+		goto out;
+
+	ret = try_charge(memcg, gfp, nr_pages);
+	if (ret) {
+		page_counter_uncharge(&memcg->kmem, nr_pages);
+		goto out;
+	}
 
-	css_put(&memcg->css);
 	page->mem_cgroup = memcg;
+out:
+	if (put)
+		css_put(&memcg->css);
 	return ret;
 }
 
 void __memcg_kmem_uncharge(struct page *page, int order)
 {
 	struct mem_cgroup *memcg = page->mem_cgroup;
+	unsigned int nr_pages = 1 << order;
 
 	if (!memcg)
 		return;
 
 	VM_BUG_ON_PAGE(mem_cgroup_is_root(memcg), page);
 
-	memcg_uncharge_kmem(memcg, 1 << order);
+	page_counter_uncharge(&memcg->kmem, nr_pages);
+	page_counter_uncharge(&memcg->memory, nr_pages);
+	if (do_swap_account)
+		page_counter_uncharge(&memcg->memsw, nr_pages);
+
 	page->mem_cgroup = NULL;
+	css_put_many(&memcg->css, nr_pages);
 }
 
 struct mem_cgroup *__mem_cgroup_from_kmem(void *ptr)
diff --git a/mm/slab.c b/mm/slab.c
index ad6c6f8385d9..037d9d71633a 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1592,16 +1592,17 @@ static struct page *kmem_getpages(struct kmem_cache *cachep, gfp_t flags,
 	if (cachep->flags & SLAB_RECLAIM_ACCOUNT)
 		flags |= __GFP_RECLAIMABLE;
 
-	if (memcg_charge_slab(cachep, flags, cachep->gfporder))
-		return NULL;
-
 	page = __alloc_pages_node(nodeid, flags | __GFP_NOTRACK, cachep->gfporder);
 	if (!page) {
-		memcg_uncharge_slab(cachep, cachep->gfporder);
 		slab_out_of_memory(cachep, flags, nodeid);
 		return NULL;
 	}
 
+	if (memcg_charge_slab(page, flags, cachep->gfporder, cachep)) {
+		__free_pages(page, cachep->gfporder);
+		return NULL;
+	}
+
 	/* Record if ALLOC_NO_WATERMARKS was set when allocating the slab */
 	if (page_is_pfmemalloc(page))
 		pfmemalloc_active = true;
@@ -1653,8 +1654,7 @@ static void kmem_freepages(struct kmem_cache *cachep, struct page *page)
 
 	if (current->reclaim_state)
 		current->reclaim_state->reclaimed_slab += nr_freed;
-	__free_pages(page, cachep->gfporder);
-	memcg_uncharge_slab(cachep, cachep->gfporder);
+	__free_kmem_pages(page, cachep->gfporder);
 }
 
 static void kmem_rcu_free(struct rcu_head *head)
diff --git a/mm/slab.h b/mm/slab.h
index a3a967d7d7c2..16cc5b0de1d8 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -240,23 +240,16 @@ static inline struct kmem_cache *memcg_root_cache(struct kmem_cache *s)
 	return s->memcg_params.root_cache;
 }
 
-static __always_inline int memcg_charge_slab(struct kmem_cache *s,
-					     gfp_t gfp, int order)
+static __always_inline int memcg_charge_slab(struct page *page,
+					     gfp_t gfp, int order,
+					     struct kmem_cache *s)
 {
 	if (!memcg_kmem_enabled())
 		return 0;
 	if (is_root_cache(s))
 		return 0;
-	return memcg_charge_kmem(s->memcg_params.memcg, gfp, 1 << order);
-}
-
-static __always_inline void memcg_uncharge_slab(struct kmem_cache *s, int order)
-{
-	if (!memcg_kmem_enabled())
-		return;
-	if (is_root_cache(s))
-		return;
-	memcg_uncharge_kmem(s->memcg_params.memcg, 1 << order);
+	return __memcg_kmem_charge(page, gfp, order,
+				   s->memcg_params.memcg);
 }
 
 extern void slab_init_memcg_params(struct kmem_cache *);
@@ -295,15 +288,12 @@ static inline struct kmem_cache *memcg_root_cache(struct kmem_cache *s)
 	return s;
 }
 
-static inline int memcg_charge_slab(struct kmem_cache *s, gfp_t gfp, int order)
+static inline int memcg_charge_slab(struct page *page, gfp_t gfp, int order,
+				    struct kmem_cache *s)
 {
 	return 0;
 }
 
-static inline void memcg_uncharge_slab(struct kmem_cache *s, int order)
-{
-}
-
 static inline void slab_init_memcg_params(struct kmem_cache *s)
 {
 }
diff --git a/mm/slub.c b/mm/slub.c
index 2b40c186e941..a05388e8a80f 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1330,16 +1330,15 @@ static inline struct page *alloc_slab_page(struct kmem_cache *s,
 
 	flags |= __GFP_NOTRACK;
 
-	if (memcg_charge_slab(s, flags, order))
-		return NULL;
-
 	if (node == NUMA_NO_NODE)
 		page = alloc_pages(flags, order);
 	else
 		page = __alloc_pages_node(node, flags, order);
 
-	if (!page)
-		memcg_uncharge_slab(s, order);
+	if (page && memcg_charge_slab(page, flags, order, s)) {
+		__free_pages(page, order);
+		page = NULL;
+	}
 
 	return page;
 }
@@ -1478,8 +1477,7 @@ static void __free_slab(struct kmem_cache *s, struct page *page)
 	page_mapcount_reset(page);
 	if (current->reclaim_state)
 		current->reclaim_state->reclaimed_slab += pages;
-	__free_pages(page, order);
-	memcg_uncharge_slab(s, order);
+	__free_kmem_pages(page, order);
 }
 
 #define need_reserve_slab_rcu						\
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
