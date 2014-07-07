Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f51.google.com (mail-la0-f51.google.com [209.85.215.51])
	by kanga.kvack.org (Postfix) with ESMTP id 04360900002
	for <linux-mm@kvack.org>; Mon,  7 Jul 2014 08:00:39 -0400 (EDT)
Received: by mail-la0-f51.google.com with SMTP id mc6so2736231lab.24
        for <linux-mm@kvack.org>; Mon, 07 Jul 2014 05:00:39 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id h7si1379339laa.109.2014.07.07.05.00.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Jul 2014 05:00:38 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 6/8] memcg: introduce kmem context
Date: Mon, 7 Jul 2014 16:00:11 +0400
Message-ID: <ce378975f0a853948d4089f8268ac9634afa0a10.1404733720.git.vdavydov@parallels.com>
In-Reply-To: <cover.1404733720.git.vdavydov@parallels.com>
References: <cover.1404733720.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.cz, hannes@cmpxchg.org, cl@linux.com, glommer@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Currently, each kmem allocation keeps a pointer to the memcg which it
was charged to. It's kmem_cache->memcg_params->memcg in case of kmalloc
and page->memcg in case of alloc_kmem_pages. As a result, to re-parent
those charges on memcg offline we have to fix all the pointers so that
they would point to the parent memcg. However, we can't always iterate
over all kmem allocations, e.g. pages allocated with alloc_kmem_pages
are not tracked. We could link all such allocations to per memcg lists,
but there's a simpler solution.

This patch introduces the mem_cgroup_kmem_context struct, which works as
a proxy between kmem objects and the memcg which they are charged
against. It has a pointer to the owner memcg and a reference counter.
Each kmem allocation holds a reference to the kmem context object
instead of pointing directly to the memcg, so that to re-parent all kmem
charges it's enough to change the memcg pointer in the kmem context
struct.

kmem context also allows us to get rid of the KMEM_ACCOUNTED_DEAD flag,
which was used to initiate memcg destruction on last uncharge, because
now each charge (each kmem cache and each non-slab kmem page) holds a
reference to the context, which in turn holds a reference to the memcg
preventing it from going away.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/memcontrol.h |   31 ++++++----
 include/linux/mm_types.h   |    6 +-
 include/linux/slab.h       |    6 +-
 mm/memcontrol.c            |  143 +++++++++++++++++++++++++-------------------
 mm/page_alloc.c            |   18 +++---
 5 files changed, 113 insertions(+), 91 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 33077215b8d4..5a38c9c49392 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -29,6 +29,7 @@ struct page_cgroup;
 struct page;
 struct mm_struct;
 struct kmem_cache;
+struct mem_cgroup_kmem_context;
 
 /*
  * The corresponding mem_cgroup_stat_names is defined in mm/memcontrol.c,
@@ -440,8 +441,10 @@ static inline bool memcg_kmem_enabled(void)
  * conditions, but because they are pretty simple, they are expected to be
  * fast.
  */
-int __memcg_charge_kmem_pages(gfp_t gfp, int order, struct mem_cgroup **memcg);
-void __memcg_uncharge_kmem_pages(struct mem_cgroup *memcg, int order);
+int __memcg_charge_kmem_pages(gfp_t gfp, int order,
+			      struct mem_cgroup_kmem_context **ctxp);
+void __memcg_uncharge_kmem_pages(struct mem_cgroup_kmem_context *ctx,
+				 int order);
 
 int memcg_cache_id(struct mem_cgroup *memcg);
 
@@ -464,7 +467,7 @@ void __memcg_cleanup_cache_params(struct kmem_cache *s);
  * memcg_charge_kmem_pages: verify if a kmem page allocation is allowed.
  * @gfp: the gfp allocation flags.
  * @order: allocation order.
- * @memcg: a pointer to the memcg this was charged against.
+ * @ctxp: a pointer to the memcg kmem context this was charged against.
  *
  * The function tries to charge a kmem page allocation to the memory cgroup
  * which the current task belongs to. It should be used for accounting non-slab
@@ -475,9 +478,10 @@ void __memcg_cleanup_cache_params(struct kmem_cache *s);
  * if this allocation is not to be accounted to any memcg.
  */
 static inline int
-memcg_charge_kmem_pages(gfp_t gfp, int order, struct mem_cgroup **memcg)
+memcg_charge_kmem_pages(gfp_t gfp, int order,
+			struct mem_cgroup_kmem_context **ctxp)
 {
-	*memcg = NULL;
+	*ctxp = NULL;
 
 	if (!memcg_kmem_enabled())
 		return 0;
@@ -498,22 +502,22 @@ memcg_charge_kmem_pages(gfp_t gfp, int order, struct mem_cgroup **memcg)
 	if (unlikely(fatal_signal_pending(current)))
 		return 0;
 
-	return __memcg_charge_kmem_pages(gfp, order, memcg);
+	return __memcg_charge_kmem_pages(gfp, order, ctxp);
 }
 
 /**
  * memcg_uncharge_kmem_pages: uncharge a kmem page allocation
- * @memcg: the memcg the allocation is charged to.
+ * @ctx: the memcg kmem context the allocation was charged against.
  * @order: allocation order.
  *
  * The function is used to uncharge kmem page allocations charged using
  * memcg_charge_kmem_pages.
  */
 static inline void
-memcg_uncharge_kmem_pages(struct mem_cgroup *memcg, int order)
+memcg_uncharge_kmem_pages(struct mem_cgroup_kmem_context *ctx, int order)
 {
-	if (memcg_kmem_enabled() && memcg)
-		__memcg_uncharge_kmem_pages(memcg, order);
+	if (memcg_kmem_enabled() && ctx)
+		__memcg_uncharge_kmem_pages(ctx, order);
 }
 
 /**
@@ -547,14 +551,15 @@ static inline bool memcg_kmem_enabled(void)
 }
 
 static inline int
-memcg_charge_kmem_pages(gfp_t gfp, int order, struct mem_cgroup **memcg)
+memcg_charge_kmem_pages(gfp_t gfp, int order,
+			struct mem_cgroup_kmem_context **ctxp)
 {
-	*memcg = NULL;
+	*ctxp = NULL;
 	return 0;
 }
 
 static inline void
-memcg_uncharge_kmem_pages(struct mem_cgroup *memcg, int order)
+memcg_uncharge_kmem_pages(struct mem_cgroup_kmem_context *ctx, int order)
 {
 }
 
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 4656c02fcd1d..e1c8466c8d90 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -23,7 +23,7 @@
 #define AT_VECTOR_SIZE (2*(AT_VECTOR_SIZE_ARCH + AT_VECTOR_SIZE_BASE + 1))
 
 struct address_space;
-struct mem_cgroup;
+struct mem_cgroup_kmem_context;
 
 #define USE_SPLIT_PTE_PTLOCKS	(NR_CPUS >= CONFIG_SPLIT_PTLOCK_CPUS)
 #define USE_SPLIT_PMD_PTLOCKS	(USE_SPLIT_PTE_PTLOCKS && \
@@ -168,8 +168,8 @@ struct page {
 		struct kmem_cache *slab_cache;	/* SL[AU]B: Pointer to slab */
 
 		/* for non-slab kmem pages (see alloc_kmem_pages):
-		 * memcg which the page is charged to */
-		struct mem_cgroup *memcg;
+		 * memcg kmem context which the page was charged against */
+		struct mem_cgroup_kmem_context *memcg_kmem_ctx;
 
 		struct page *first_page;	/* Compound tail pages */
 	};
diff --git a/include/linux/slab.h b/include/linux/slab.h
index c6680a885910..c3e85aeeb556 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -524,8 +524,8 @@ static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
  * Child caches will hold extra metadata needed for its operation. Fields are:
  *
  * @cachep: cache which this struct is for
- * @memcg: pointer to the memcg this cache belongs to
- * @list: list_head for the list of all caches in this memcg
+ * @ctx: pointer to the memcg kmem context this cache belongs to
+ * @list: list_head for the list of all caches in the context
  * @root_cache: pointer to the global, root cache, this cache was derived from
  * @siblings: list_head for the list of all child caches of the root_cache
  * @refcnt: reference counter
@@ -543,7 +543,7 @@ struct memcg_cache_params {
 		};
 		struct {
 			struct kmem_cache *cachep;
-			struct mem_cgroup *memcg;
+			struct mem_cgroup_kmem_context *ctx;
 			struct list_head list;
 			struct kmem_cache *root_cache;
 			struct list_head siblings;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 4b155ebf1973..fb25575bdb22 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -268,6 +268,20 @@ struct mem_cgroup_event {
 	struct work_struct remove;
 };
 
+struct mem_cgroup_kmem_context {
+	struct mem_cgroup *memcg;
+	atomic_long_t refcnt;
+	/*
+	 * true if accounting is enabled
+	 */
+	bool active;
+	/*
+	 * analogous to slab_common's slab_caches list, but per-memcg;
+	 * protected by memcg_slab_mutex
+	 */
+	struct list_head slab_caches;
+};
+
 static void mem_cgroup_threshold(struct mem_cgroup *memcg);
 static void mem_cgroup_oom_notify(struct mem_cgroup *memcg);
 
@@ -305,7 +319,6 @@ struct mem_cgroup {
 	 * Should the accounting and control be hierarchical, per subtree?
 	 */
 	bool use_hierarchy;
-	unsigned long kmem_account_flags; /* See KMEM_ACCOUNTED_*, below */
 
 	bool		oom_lock;
 	atomic_t	under_oom;
@@ -357,11 +370,9 @@ struct mem_cgroup {
 	struct cg_proto tcp_mem;
 #endif
 #if defined(CONFIG_MEMCG_KMEM)
-	/* analogous to slab_common's slab_caches list, but per-memcg;
-	 * protected by memcg_slab_mutex */
-	struct list_head memcg_slab_caches;
         /* Index in the kmem_cache->memcg_params->memcg_caches array */
 	int kmemcg_id;
+	struct mem_cgroup_kmem_context *kmem_ctx;
 #endif
 
 	int last_scanned_node;
@@ -379,40 +390,59 @@ struct mem_cgroup {
 	/* WARNING: nodeinfo must be the last member here */
 };
 
-/* internal only representation about the status of kmem accounting. */
-enum {
-	KMEM_ACCOUNTED_ACTIVE, /* accounted by this cgroup itself */
-	KMEM_ACCOUNTED_DEAD, /* dead memcg with pending kmem charges */
-};
-
 #ifdef CONFIG_MEMCG_KMEM
-static inline void memcg_kmem_set_active(struct mem_cgroup *memcg)
+static bool memcg_kmem_is_active(struct mem_cgroup *memcg)
 {
-	set_bit(KMEM_ACCOUNTED_ACTIVE, &memcg->kmem_account_flags);
+	return memcg->kmem_ctx->active;
 }
 
-static bool memcg_kmem_is_active(struct mem_cgroup *memcg)
+static inline struct mem_cgroup_kmem_context *
+memcg_get_kmem_context(struct mem_cgroup *memcg)
 {
-	return test_bit(KMEM_ACCOUNTED_ACTIVE, &memcg->kmem_account_flags);
+	struct mem_cgroup_kmem_context *ctx = memcg->kmem_ctx;
+
+	atomic_long_inc(&ctx->refcnt);
+	return ctx;
 }
 
-static void memcg_kmem_mark_dead(struct mem_cgroup *memcg)
+static inline void memcg_put_kmem_context(struct mem_cgroup_kmem_context *ctx)
 {
-	/*
-	 * Our caller must use css_get() first, because memcg_uncharge_kmem()
-	 * will call css_put() if it sees the memcg is dead.
-	 */
-	smp_wmb();
-	if (test_bit(KMEM_ACCOUNTED_ACTIVE, &memcg->kmem_account_flags))
-		set_bit(KMEM_ACCOUNTED_DEAD, &memcg->kmem_account_flags);
+	if (unlikely(atomic_long_dec_and_test(&ctx->refcnt)))
+		css_put(&ctx->memcg->css);	/* drop the reference taken in
+						 * kmem_cgroup_css_offline */
 }
 
-static bool memcg_kmem_test_and_clear_dead(struct mem_cgroup *memcg)
+static int memcg_alloc_kmem_context(struct mem_cgroup *memcg)
 {
-	return test_and_clear_bit(KMEM_ACCOUNTED_DEAD,
-				  &memcg->kmem_account_flags);
+	struct mem_cgroup_kmem_context *ctx;
+
+	ctx = kmalloc(sizeof(*ctx), GFP_KERNEL);
+	if (!ctx)
+		return -ENOMEM;
+
+	ctx->memcg = memcg;
+	atomic_long_set(&ctx->refcnt, 1);
+	ctx->active = false;
+	INIT_LIST_HEAD(&ctx->slab_caches);
+
+	memcg->kmem_ctx = ctx;
+	return 0;
 }
-#endif
+
+static void memcg_release_kmem_context(struct mem_cgroup *memcg)
+{
+	kfree(memcg->kmem_ctx);
+}
+#else
+static int memcg_alloc_kmem_context(struct mem_cgroup *memcg)
+{
+	return 0;
+}
+
+static void memcg_release_kmem_context(struct mem_cgroup *memcg)
+{
+}
+#endif /* CONFIG_MEMCG_KMEM */
 
 /* Stuffs for move charges at task migration. */
 /*
@@ -2793,7 +2823,7 @@ static int mem_cgroup_slabinfo_read(struct seq_file *m, void *v)
 	print_slabinfo_header(m);
 
 	mutex_lock(&memcg_slab_mutex);
-	list_for_each_entry(params, &memcg->memcg_slab_caches, list)
+	list_for_each_entry(params, &memcg->kmem_ctx->slab_caches, list)
 		cache_show(params->cachep, m);
 	mutex_unlock(&memcg_slab_mutex);
 
@@ -2843,21 +2873,7 @@ static void memcg_uncharge_kmem(struct mem_cgroup *memcg, u64 size)
 	res_counter_uncharge(&memcg->res, size);
 	if (do_swap_account)
 		res_counter_uncharge(&memcg->memsw, size);
-
-	/* Not down to 0 */
-	if (res_counter_uncharge(&memcg->kmem, size))
-		return;
-
-	/*
-	 * Releases a reference taken in kmem_cgroup_css_offline in case
-	 * this last uncharge is racing with the offlining code or it is
-	 * outliving the memcg existence.
-	 *
-	 * The memory barrier imposed by test&clear is paired with the
-	 * explicit one in memcg_kmem_mark_dead().
-	 */
-	if (memcg_kmem_test_and_clear_dead(memcg))
-		css_put(&memcg->css);
+	res_counter_uncharge(&memcg->kmem, size);
 }
 
 /*
@@ -2974,12 +2990,11 @@ int memcg_alloc_cache_params(struct mem_cgroup *memcg, struct kmem_cache *s,
 
 	if (memcg) {
 		s->memcg_params->cachep = s;
-		s->memcg_params->memcg = memcg;
+		s->memcg_params->ctx = memcg_get_kmem_context(memcg);
 		s->memcg_params->root_cache = root_cache;
 		atomic_long_set(&s->memcg_params->refcnt, 1);
 		INIT_WORK(&s->memcg_params->unregister_work,
 			  memcg_unregister_cache_func);
-		css_get(&memcg->css);
 	} else {
 		s->memcg_params->is_root_cache = true;
 		INIT_LIST_HEAD(&s->memcg_params->children);
@@ -2993,7 +3008,7 @@ void memcg_free_cache_params(struct kmem_cache *s)
 	if (!s->memcg_params)
 		return;
 	if (!s->memcg_params->is_root_cache)
-		css_put(&s->memcg_params->memcg->css);
+		memcg_put_kmem_context(s->memcg_params->ctx);
 	kfree(s->memcg_params);
 }
 
@@ -3027,7 +3042,7 @@ static void memcg_register_cache(struct mem_cgroup *memcg,
 	if (!cachep)
 		return;
 
-	list_add(&cachep->memcg_params->list, &memcg->memcg_slab_caches);
+	list_add(&cachep->memcg_params->list, &memcg->kmem_ctx->slab_caches);
 
 	/*
 	 * Since readers won't lock (see cache_from_memcg_idx()), we need a
@@ -3051,7 +3066,7 @@ static void memcg_unregister_cache(struct kmem_cache *cachep)
 	BUG_ON(is_root_cache(cachep));
 
 	root_cache = cachep->memcg_params->root_cache;
-	memcg = cachep->memcg_params->memcg;
+	memcg = cachep->memcg_params->ctx->memcg;
 	id = memcg_cache_id(memcg);
 
 	BUG_ON(root_cache->memcg_params->memcg_caches[id] != cachep);
@@ -3131,7 +3146,8 @@ static void memcg_unregister_all_caches(struct mem_cgroup *memcg)
 		return;
 
 	mutex_lock(&memcg_slab_mutex);
-	list_for_each_entry_safe(params, tmp, &memcg->memcg_slab_caches, list) {
+	list_for_each_entry_safe(params, tmp,
+				 &memcg->kmem_ctx->slab_caches, list) {
 		struct kmem_cache *cachep = params->cachep;
 
 		memcg_cache_mark_dead(cachep);
@@ -3226,7 +3242,7 @@ int __memcg_charge_slab(struct kmem_cache *cachep, gfp_t gfp, int order)
 {
 	int res;
 
-	res = memcg_charge_kmem(cachep->memcg_params->memcg, gfp,
+	res = memcg_charge_kmem(cachep->memcg_params->ctx->memcg, gfp,
 				PAGE_SIZE << order);
 	if (!res)
 		atomic_long_inc(&cachep->memcg_params->refcnt);
@@ -3235,7 +3251,8 @@ int __memcg_charge_slab(struct kmem_cache *cachep, gfp_t gfp, int order)
 
 void __memcg_uncharge_slab(struct kmem_cache *cachep, int order)
 {
-	memcg_uncharge_kmem(cachep->memcg_params->memcg, PAGE_SIZE << order);
+	memcg_uncharge_kmem(cachep->memcg_params->ctx->memcg,
+			    PAGE_SIZE << order);
 
 	if (unlikely(atomic_long_dec_and_test(&cachep->memcg_params->refcnt)))
 		/* see memcg_unregister_all_caches */
@@ -3304,7 +3321,8 @@ out:
 	return cachep;
 }
 
-int __memcg_charge_kmem_pages(gfp_t gfp, int order, struct mem_cgroup **_memcg)
+int __memcg_charge_kmem_pages(gfp_t gfp, int order,
+			      struct mem_cgroup_kmem_context **ctxp)
 {
 	struct mem_cgroup *memcg;
 	int ret;
@@ -3345,15 +3363,16 @@ int __memcg_charge_kmem_pages(gfp_t gfp, int order, struct mem_cgroup **_memcg)
 
 	ret = memcg_charge_kmem(memcg, gfp, PAGE_SIZE << order);
 	if (!ret)
-		*_memcg = memcg;
+		*ctxp = memcg_get_kmem_context(memcg);
 
 	css_put(&memcg->css);
 	return ret;
 }
 
-void __memcg_uncharge_kmem_pages(struct mem_cgroup *memcg, int order)
+void __memcg_uncharge_kmem_pages(struct mem_cgroup_kmem_context *ctx, int order)
 {
-	memcg_uncharge_kmem(memcg, PAGE_SIZE << order);
+	memcg_uncharge_kmem(ctx->memcg, PAGE_SIZE << order);
+	memcg_put_kmem_context(ctx);
 }
 #else
 static inline void memcg_unregister_all_caches(struct mem_cgroup *memcg)
@@ -4182,7 +4201,6 @@ static int __memcg_activate_kmem(struct mem_cgroup *memcg,
 		goto out_rmid;
 
 	memcg->kmemcg_id = memcg_id;
-	INIT_LIST_HEAD(&memcg->memcg_slab_caches);
 
 	/*
 	 * We couldn't have accounted to this cgroup, because it hasn't got the
@@ -4197,7 +4215,7 @@ static int __memcg_activate_kmem(struct mem_cgroup *memcg,
 	 * guarantee no one starts accounting before all call sites are
 	 * patched.
 	 */
-	memcg_kmem_set_active(memcg);
+	memcg->kmem_ctx->active = true;
 out:
 	memcg_resume_kmem_account();
 	return err;
@@ -4957,13 +4975,7 @@ static void kmem_cgroup_css_offline(struct mem_cgroup *memcg)
 	 */
 	css_get(&memcg->css);
 
-	memcg_kmem_mark_dead(memcg);
-
-	if (res_counter_read_u64(&memcg->kmem, RES_USAGE) != 0)
-		return;
-
-	if (memcg_kmem_test_and_clear_dead(memcg))
-		css_put(&memcg->css);
+	memcg_put_kmem_context(memcg->kmem_ctx);
 }
 #else
 static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
@@ -5433,6 +5445,8 @@ static void __mem_cgroup_free(struct mem_cgroup *memcg)
 	 * the cgroup_lock.
 	 */
 	disarm_static_keys(memcg);
+
+	memcg_release_kmem_context(memcg);
 	kfree(memcg);
 }
 
@@ -5481,6 +5495,9 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 	if (!memcg)
 		return ERR_PTR(error);
 
+	if (memcg_alloc_kmem_context(memcg))
+		goto free_out;
+
 	for_each_node(node)
 		if (alloc_mem_cgroup_per_zone_info(memcg, node))
 			goto free_out;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f4090a582caf..39097a46b60c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2902,32 +2902,32 @@ EXPORT_SYMBOL(free_pages);
 struct page *alloc_kmem_pages(gfp_t gfp_mask, unsigned int order)
 {
 	struct page *page;
-	struct mem_cgroup *memcg;
+	struct mem_cgroup_kmem_context *ctx;
 
-	if (memcg_charge_kmem_pages(gfp_mask, order, &memcg) != 0)
+	if (memcg_charge_kmem_pages(gfp_mask, order, &ctx) != 0)
 		return NULL;
 	page = alloc_pages(gfp_mask, order);
 	if (!page) {
-		memcg_uncharge_kmem_pages(memcg, order);
+		memcg_uncharge_kmem_pages(ctx, order);
 		return NULL;
 	}
-	page->memcg = memcg;
+	page->memcg_kmem_ctx = ctx;
 	return page;
 }
 
 struct page *alloc_kmem_pages_node(int nid, gfp_t gfp_mask, unsigned int order)
 {
 	struct page *page;
-	struct mem_cgroup *memcg;
+	struct mem_cgroup_kmem_context *ctx;
 
-	if (memcg_charge_kmem_pages(gfp_mask, order, &memcg) != 0)
+	if (memcg_charge_kmem_pages(gfp_mask, order, &ctx) != 0)
 		return NULL;
 	page = alloc_pages_node(nid, gfp_mask, order);
 	if (!page) {
-		memcg_uncharge_kmem_pages(memcg, order);
+		memcg_uncharge_kmem_pages(ctx, order);
 		return NULL;
 	}
-	page->memcg = memcg;
+	page->memcg_kmem_ctx = ctx;
 	return page;
 }
 
@@ -2937,7 +2937,7 @@ struct page *alloc_kmem_pages_node(int nid, gfp_t gfp_mask, unsigned int order)
  */
 void __free_kmem_pages(struct page *page, unsigned int order)
 {
-	memcg_uncharge_kmem_pages(page->memcg, order);
+	memcg_uncharge_kmem_pages(page->memcg_kmem_ctx, order);
 	__free_pages(page, order);
 }
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
