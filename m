Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f199.google.com (mail-ob0-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id A05756B0261
	for <linux-mm@kvack.org>; Tue, 24 May 2016 04:49:43 -0400 (EDT)
Received: by mail-ob0-f199.google.com with SMTP id g6so14125783obn.0
        for <linux-mm@kvack.org>; Tue, 24 May 2016 01:49:43 -0700 (PDT)
Received: from emea01-db3-obe.outbound.protection.outlook.com (mail-db3on0101.outbound.protection.outlook.com. [157.55.234.101])
        by mx.google.com with ESMTPS id r65si1257767oia.96.2016.05.24.01.49.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 24 May 2016 01:49:42 -0700 (PDT)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH RESEND 3/8] mm: memcontrol: cleanup kmem charge functions
Date: Tue, 24 May 2016 11:49:25 +0300
Message-ID: <52882a28b542c1979fd9a033b4dc8637fc347399.1464079537.git.vdavydov@virtuozzo.com>
In-Reply-To: <cover.1464079537.git.vdavydov@virtuozzo.com>
References: <cover.1464079537.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org

 - Handle memcg_kmem_enabled check out to the caller. This reduces the
   number of function definitions making the code easier to follow. At
   the same time it doesn't result in code bloat, because all of these
   functions are used only in one or two places.
 - Move __GFP_ACCOUNT check to the caller as well so that one wouldn't
   have to dive deep into memcg implementation to see which allocations
   are charged and which are not.
 - Refresh comments.

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
 include/linux/memcontrol.h | 103 +++------------------------------------------
 mm/memcontrol.c            |  75 ++++++++++++++++++++++++---------
 mm/page_alloc.c            |   9 ++--
 mm/slab.h                  |  16 +++++--
 4 files changed, 80 insertions(+), 123 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index a805474df4ab..2d03975c7dc0 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -754,6 +754,13 @@ static inline bool mem_cgroup_under_socket_pressure(struct mem_cgroup *memcg)
 }
 #endif
 
+struct kmem_cache *memcg_kmem_get_cache(struct kmem_cache *cachep);
+void memcg_kmem_put_cache(struct kmem_cache *cachep);
+int memcg_kmem_charge_memcg(struct page *page, gfp_t gfp, int order,
+			    struct mem_cgroup *memcg);
+int memcg_kmem_charge(struct page *page, gfp_t gfp, int order);
+void memcg_kmem_uncharge(struct page *page, int order);
+
 #if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
 extern struct static_key_false memcg_kmem_enabled_key;
 
@@ -775,22 +782,6 @@ static inline bool memcg_kmem_enabled(void)
 }
 
 /*
- * In general, we'll do everything in our power to not incur in any overhead
- * for non-memcg users for the kmem functions. Not even a function call, if we
- * can avoid it.
- *
- * Therefore, we'll inline all those functions so that in the best case, we'll
- * see that kmemcg is off for everybody and proceed quickly.  If it is on,
- * we'll still do most of the flag checking inline. We check a lot of
- * conditions, but because they are pretty simple, they are expected to be
- * fast.
- */
-int __memcg_kmem_charge_memcg(struct page *page, gfp_t gfp, int order,
-			      struct mem_cgroup *memcg);
-int __memcg_kmem_charge(struct page *page, gfp_t gfp, int order);
-void __memcg_kmem_uncharge(struct page *page, int order);
-
-/*
  * helper for accessing a memcg's index. It will be used as an index in the
  * child cache array in kmem_cache, and also to derive its name. This function
  * will return -1 when this is not a kmem-limited memcg.
@@ -800,67 +791,6 @@ static inline int memcg_cache_id(struct mem_cgroup *memcg)
 	return memcg ? memcg->kmemcg_id : -1;
 }
 
-struct kmem_cache *__memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp);
-void __memcg_kmem_put_cache(struct kmem_cache *cachep);
-
-static inline bool __memcg_kmem_bypass(void)
-{
-	if (!memcg_kmem_enabled())
-		return true;
-	if (in_interrupt() || (!current->mm) || (current->flags & PF_KTHREAD))
-		return true;
-	return false;
-}
-
-/**
- * memcg_kmem_charge: charge a kmem page
- * @page: page to charge
- * @gfp: reclaim mode
- * @order: allocation order
- *
- * Returns 0 on success, an error code on failure.
- */
-static __always_inline int memcg_kmem_charge(struct page *page,
-					     gfp_t gfp, int order)
-{
-	if (__memcg_kmem_bypass())
-		return 0;
-	if (!(gfp & __GFP_ACCOUNT))
-		return 0;
-	return __memcg_kmem_charge(page, gfp, order);
-}
-
-/**
- * memcg_kmem_uncharge: uncharge a kmem page
- * @page: page to uncharge
- * @order: allocation order
- */
-static __always_inline void memcg_kmem_uncharge(struct page *page, int order)
-{
-	if (memcg_kmem_enabled())
-		__memcg_kmem_uncharge(page, order);
-}
-
-/**
- * memcg_kmem_get_cache: selects the correct per-memcg cache for allocation
- * @cachep: the original global kmem cache
- *
- * All memory allocated from a per-memcg cache is charged to the owner memcg.
- */
-static __always_inline struct kmem_cache *
-memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp)
-{
-	if (__memcg_kmem_bypass())
-		return cachep;
-	return __memcg_kmem_get_cache(cachep, gfp);
-}
-
-static __always_inline void memcg_kmem_put_cache(struct kmem_cache *cachep)
-{
-	if (memcg_kmem_enabled())
-		__memcg_kmem_put_cache(cachep);
-}
-
 /**
  * memcg_kmem_update_page_stat - update kmem page state statistics
  * @page: the page
@@ -883,15 +813,6 @@ static inline bool memcg_kmem_enabled(void)
 	return false;
 }
 
-static inline int memcg_kmem_charge(struct page *page, gfp_t gfp, int order)
-{
-	return 0;
-}
-
-static inline void memcg_kmem_uncharge(struct page *page, int order)
-{
-}
-
 static inline int memcg_cache_id(struct mem_cgroup *memcg)
 {
 	return -1;
@@ -905,16 +826,6 @@ static inline void memcg_put_cache_ids(void)
 {
 }
 
-static inline struct kmem_cache *
-memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp)
-{
-	return cachep;
-}
-
-static inline void memcg_kmem_put_cache(struct kmem_cache *cachep)
-{
-}
-
 static inline void memcg_kmem_update_page_stat(struct page *page,
 				enum mem_cgroup_stat_index idx, int val)
 {
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b3f16ab4b431..482b4a0c97e4 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2268,20 +2268,30 @@ static void memcg_schedule_kmem_cache_create(struct mem_cgroup *memcg,
 	current->memcg_kmem_skip_account = 0;
 }
 
-/*
+static inline bool memcg_kmem_bypass(void)
+{
+	if (in_interrupt() || !current->mm || (current->flags & PF_KTHREAD))
+		return true;
+	return false;
+}
+
+/**
+ * memcg_kmem_get_cache: select the correct per-memcg cache for allocation
+ * @cachep: the original global kmem cache
+ *
  * Return the kmem_cache we're supposed to use for a slab allocation.
  * We try to use the current memcg's version of the cache.
  *
- * If the cache does not exist yet, if we are the first user of it,
- * we either create it immediately, if possible, or create it asynchronously
- * in a workqueue.
- * In the latter case, we will let the current allocation go through with
- * the original cache.
+ * If the cache does not exist yet, if we are the first user of it, we
+ * create it asynchronously in a workqueue and let the current allocation
+ * go through with the original cache.
  *
- * Can't be called in interrupt context or from kernel threads.
- * This function needs to be called with rcu_read_lock() held.
+ * This function takes a reference to the cache it returns to assure it
+ * won't get destroyed while we are working with it. Once the caller is
+ * done with it, memcg_kmem_put_cache() must be called to release the
+ * reference.
  */
-struct kmem_cache *__memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp)
+struct kmem_cache *memcg_kmem_get_cache(struct kmem_cache *cachep)
 {
 	struct mem_cgroup *memcg;
 	struct kmem_cache *memcg_cachep;
@@ -2289,10 +2299,7 @@ struct kmem_cache *__memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp)
 
 	VM_BUG_ON(!is_root_cache(cachep));
 
-	if (cachep->flags & SLAB_ACCOUNT)
-		gfp |= __GFP_ACCOUNT;
-
-	if (!(gfp & __GFP_ACCOUNT))
+	if (memcg_kmem_bypass())
 		return cachep;
 
 	if (current->memcg_kmem_skip_account)
@@ -2325,14 +2332,27 @@ out:
 	return cachep;
 }
 
-void __memcg_kmem_put_cache(struct kmem_cache *cachep)
+/**
+ * memcg_kmem_put_cache: drop reference taken by memcg_kmem_get_cache
+ * @cachep: the cache returned by memcg_kmem_get_cache
+ */
+void memcg_kmem_put_cache(struct kmem_cache *cachep)
 {
 	if (!is_root_cache(cachep))
 		css_put(&cachep->memcg_params.memcg->css);
 }
 
-int __memcg_kmem_charge_memcg(struct page *page, gfp_t gfp, int order,
-			      struct mem_cgroup *memcg)
+/**
+ * memcg_kmem_charge: charge a kmem page
+ * @page: page to charge
+ * @gfp: reclaim mode
+ * @order: allocation order
+ * @memcg: memory cgroup to charge
+ *
+ * Returns 0 on success, an error code on failure.
+ */
+int memcg_kmem_charge_memcg(struct page *page, gfp_t gfp, int order,
+			    struct mem_cgroup *memcg)
 {
 	unsigned int nr_pages = 1 << order;
 	struct page_counter *counter;
@@ -2353,19 +2373,34 @@ int __memcg_kmem_charge_memcg(struct page *page, gfp_t gfp, int order,
 	return 0;
 }
 
-int __memcg_kmem_charge(struct page *page, gfp_t gfp, int order)
+/**
+ * memcg_kmem_charge: charge a kmem page to the current memory cgroup
+ * @page: page to charge
+ * @gfp: reclaim mode
+ * @order: allocation order
+ *
+ * Returns 0 on success, an error code on failure.
+ */
+int memcg_kmem_charge(struct page *page, gfp_t gfp, int order)
 {
 	struct mem_cgroup *memcg;
 	int ret = 0;
 
+	if (memcg_kmem_bypass())
+		return 0;
+
 	memcg = get_mem_cgroup_from_mm(current->mm);
 	if (!mem_cgroup_is_root(memcg))
-		ret = __memcg_kmem_charge_memcg(page, gfp, order, memcg);
+		ret = memcg_kmem_charge_memcg(page, gfp, order, memcg);
 	css_put(&memcg->css);
 	return ret;
 }
-
-void __memcg_kmem_uncharge(struct page *page, int order)
+/**
+ * memcg_kmem_uncharge: uncharge a kmem page
+ * @page: page to uncharge
+ * @order: allocation order
+ */
+void memcg_kmem_uncharge(struct page *page, int order)
 {
 	struct mem_cgroup *memcg = page->mem_cgroup;
 	unsigned int nr_pages = 1 << order;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 520c3576249b..f948f4e02e89 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4001,7 +4001,8 @@ struct page *alloc_kmem_pages(gfp_t gfp_mask, unsigned int order)
 	struct page *page;
 
 	page = alloc_pages(gfp_mask, order);
-	if (page && memcg_kmem_charge(page, gfp_mask, order) != 0) {
+	if (memcg_kmem_enabled() && (gfp_mask & __GFP_ACCOUNT) &&
+	    page && memcg_kmem_charge(page, gfp_mask, order) != 0) {
 		__free_pages(page, order);
 		page = NULL;
 	}
@@ -4013,7 +4014,8 @@ struct page *alloc_kmem_pages_node(int nid, gfp_t gfp_mask, unsigned int order)
 	struct page *page;
 
 	page = alloc_pages_node(nid, gfp_mask, order);
-	if (page && memcg_kmem_charge(page, gfp_mask, order) != 0) {
+	if (memcg_kmem_enabled() && (gfp_mask & __GFP_ACCOUNT) &&
+	    page && memcg_kmem_charge(page, gfp_mask, order) != 0) {
 		__free_pages(page, order);
 		page = NULL;
 	}
@@ -4026,7 +4028,8 @@ struct page *alloc_kmem_pages_node(int nid, gfp_t gfp_mask, unsigned int order)
  */
 void __free_kmem_pages(struct page *page, unsigned int order)
 {
-	memcg_kmem_uncharge(page, order);
+	if (memcg_kmem_enabled())
+		memcg_kmem_uncharge(page, order);
 	__free_pages(page, order);
 }
 
diff --git a/mm/slab.h b/mm/slab.h
index dedb1a920fb8..a98859400bc0 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -253,8 +253,7 @@ static __always_inline int memcg_charge_slab(struct page *page,
 	if (is_root_cache(s))
 		return 0;
 
-	ret = __memcg_kmem_charge_memcg(page, gfp, order,
-					s->memcg_params.memcg);
+	ret = memcg_kmem_charge_memcg(page, gfp, order, s->memcg_params.memcg);
 	if (ret)
 		return ret;
 
@@ -268,6 +267,9 @@ static __always_inline int memcg_charge_slab(struct page *page,
 static __always_inline void memcg_uncharge_slab(struct page *page, int order,
 						struct kmem_cache *s)
 {
+	if (!memcg_kmem_enabled())
+		return;
+
 	memcg_kmem_update_page_stat(page,
 			(s->flags & SLAB_RECLAIM_ACCOUNT) ?
 			MEMCG_SLAB_RECLAIMABLE : MEMCG_SLAB_UNRECLAIMABLE,
@@ -390,7 +392,11 @@ static inline struct kmem_cache *slab_pre_alloc_hook(struct kmem_cache *s,
 	if (should_failslab(s, flags))
 		return NULL;
 
-	return memcg_kmem_get_cache(s, flags);
+	if (memcg_kmem_enabled() &&
+	    ((flags & __GFP_ACCOUNT) || (s->flags & SLAB_ACCOUNT)))
+		return memcg_kmem_get_cache(s);
+
+	return s;
 }
 
 static inline void slab_post_alloc_hook(struct kmem_cache *s, gfp_t flags,
@@ -407,7 +413,9 @@ static inline void slab_post_alloc_hook(struct kmem_cache *s, gfp_t flags,
 					 s->flags, flags);
 		kasan_slab_alloc(s, object, flags);
 	}
-	memcg_kmem_put_cache(s);
+
+	if (memcg_kmem_enabled())
+		memcg_kmem_put_cache(s);
 }
 
 #ifndef CONFIG_SLOB
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
