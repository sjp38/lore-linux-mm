Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f176.google.com (mail-lb0-f176.google.com [209.85.217.176])
	by kanga.kvack.org (Postfix) with ESMTP id E8B88900002
	for <linux-mm@kvack.org>; Mon,  7 Jul 2014 08:00:36 -0400 (EDT)
Received: by mail-lb0-f176.google.com with SMTP id w7so2782091lbi.35
        for <linux-mm@kvack.org>; Mon, 07 Jul 2014 05:00:36 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id ao7si34273068lac.134.2014.07.07.05.00.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Jul 2014 05:00:35 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 5/8] memcg: rework non-slab kmem pages charge path
Date: Mon, 7 Jul 2014 16:00:10 +0400
Message-ID: <b9680999dbbdadcc9e58139d87356c7f958d6eb1.1404733720.git.vdavydov@parallels.com>
In-Reply-To: <cover.1404733720.git.vdavydov@parallels.com>
References: <cover.1404733720.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.cz, hannes@cmpxchg.org, cl@linux.com, glommer@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Currently we have two functions for that: memcg_kmem_newpage_charge and
memcg_kmem_commit_charge. The former is called before allocating a page
to charge it to the current cgroup, while the latter saves the memcg the
new page was charged to in its page_cgroup.

Actually, there's no need to use page_cgroups for kmem pages, because
such pages are allocated when the user actually would like to kmalloc,
but falls back to alloc_page due to the allocation order is too large,
so the user won't use internal page struct fields and we can safely use
one to save a pointer to the memcg holding the charge instead of using
page_cgorups, just like SL[AU]B does.

This will make the code cleaner and allow us to get rid of
memcg_kmem_commit_charge.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/memcontrol.h |   79 +++++++++++++++++---------------------------
 include/linux/mm_types.h   |    6 ++++
 mm/memcontrol.c            |   70 ++++-----------------------------------
 mm/page_alloc.c            |   22 ++++++++----
 4 files changed, 57 insertions(+), 120 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 5b0fbba00b01..33077215b8d4 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -440,11 +440,8 @@ static inline bool memcg_kmem_enabled(void)
  * conditions, but because they are pretty simple, they are expected to be
  * fast.
  */
-bool __memcg_kmem_newpage_charge(gfp_t gfp, struct mem_cgroup **memcg,
-					int order);
-void __memcg_kmem_commit_charge(struct page *page,
-				       struct mem_cgroup *memcg, int order);
-void __memcg_kmem_uncharge_pages(struct page *page, int order);
+int __memcg_charge_kmem_pages(gfp_t gfp, int order, struct mem_cgroup **memcg);
+void __memcg_uncharge_kmem_pages(struct mem_cgroup *memcg, int order);
 
 int memcg_cache_id(struct mem_cgroup *memcg);
 
@@ -464,22 +461,26 @@ void __memcg_uncharge_slab(struct kmem_cache *cachep, int order);
 void __memcg_cleanup_cache_params(struct kmem_cache *s);
 
 /**
- * memcg_kmem_newpage_charge: verify if a new kmem allocation is allowed.
+ * memcg_charge_kmem_pages: verify if a kmem page allocation is allowed.
  * @gfp: the gfp allocation flags.
- * @memcg: a pointer to the memcg this was charged against.
  * @order: allocation order.
+ * @memcg: a pointer to the memcg this was charged against.
  *
- * returns true if the memcg where the current task belongs can hold this
- * allocation.
+ * The function tries to charge a kmem page allocation to the memory cgroup
+ * which the current task belongs to. It should be used for accounting non-slab
+ * kmem pages allocations (see alloc_kmem_pages). For slab allocations
+ * memcg_charge_slab is used.
  *
- * We return true automatically if this allocation is not to be accounted to
- * any memcg.
+ * Returns 0 on success, -ENOMEM on failure. Note we skip charging and return 0
+ * if this allocation is not to be accounted to any memcg.
  */
-static inline bool
-memcg_kmem_newpage_charge(gfp_t gfp, struct mem_cgroup **memcg, int order)
+static inline int
+memcg_charge_kmem_pages(gfp_t gfp, int order, struct mem_cgroup **memcg)
 {
+	*memcg = NULL;
+
 	if (!memcg_kmem_enabled())
-		return true;
+		return 0;
 
 	/*
 	 * __GFP_NOFAIL allocations will move on even if charging is not
@@ -489,47 +490,30 @@ memcg_kmem_newpage_charge(gfp_t gfp, struct mem_cgroup **memcg, int order)
 	 * and won't be worth the trouble.
 	 */
 	if (gfp & __GFP_NOFAIL)
-		return true;
+		return 0;
 	if (in_interrupt() || (!current->mm) || (current->flags & PF_KTHREAD))
-		return true;
+		return 0;
 
 	/* If the test is dying, just let it go. */
 	if (unlikely(fatal_signal_pending(current)))
-		return true;
+		return 0;
 
-	return __memcg_kmem_newpage_charge(gfp, memcg, order);
-}
-
-/**
- * memcg_kmem_uncharge_pages: uncharge pages from memcg
- * @page: pointer to struct page being freed
- * @order: allocation order.
- *
- * there is no need to specify memcg here, since it is embedded in page_cgroup
- */
-static inline void
-memcg_kmem_uncharge_pages(struct page *page, int order)
-{
-	if (memcg_kmem_enabled())
-		__memcg_kmem_uncharge_pages(page, order);
+	return __memcg_charge_kmem_pages(gfp, order, memcg);
 }
 
 /**
- * memcg_kmem_commit_charge: embeds correct memcg in a page
- * @page: pointer to struct page recently allocated
- * @memcg: the memcg structure we charged against
+ * memcg_uncharge_kmem_pages: uncharge a kmem page allocation
+ * @memcg: the memcg the allocation is charged to.
  * @order: allocation order.
  *
- * Needs to be called after memcg_kmem_newpage_charge, regardless of success or
- * failure of the allocation. if @page is NULL, this function will revert the
- * charges. Otherwise, it will commit the memcg given by @memcg to the
- * corresponding page_cgroup.
+ * The function is used to uncharge kmem page allocations charged using
+ * memcg_charge_kmem_pages.
  */
 static inline void
-memcg_kmem_commit_charge(struct page *page, struct mem_cgroup *memcg, int order)
+memcg_uncharge_kmem_pages(struct mem_cgroup *memcg, int order)
 {
 	if (memcg_kmem_enabled() && memcg)
-		__memcg_kmem_commit_charge(page, memcg, order);
+		__memcg_uncharge_kmem_pages(memcg, order);
 }
 
 /**
@@ -562,18 +546,15 @@ static inline bool memcg_kmem_enabled(void)
 	return false;
 }
 
-static inline bool
-memcg_kmem_newpage_charge(gfp_t gfp, struct mem_cgroup **memcg, int order)
-{
-	return true;
-}
-
-static inline void memcg_kmem_uncharge_pages(struct page *page, int order)
+static inline int
+memcg_charge_kmem_pages(gfp_t gfp, int order, struct mem_cgroup **memcg)
 {
+	*memcg = NULL;
+	return 0;
 }
 
 static inline void
-memcg_kmem_commit_charge(struct page *page, struct mem_cgroup *memcg, int order)
+memcg_uncharge_kmem_pages(struct mem_cgroup *memcg, int order)
 {
 }
 
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index a6236cff3c31..4656c02fcd1d 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -23,6 +23,7 @@
 #define AT_VECTOR_SIZE (2*(AT_VECTOR_SIZE_ARCH + AT_VECTOR_SIZE_BASE + 1))
 
 struct address_space;
+struct mem_cgroup;
 
 #define USE_SPLIT_PTE_PTLOCKS	(NR_CPUS >= CONFIG_SPLIT_PTLOCK_CPUS)
 #define USE_SPLIT_PMD_PTLOCKS	(USE_SPLIT_PTE_PTLOCKS && \
@@ -165,6 +166,11 @@ struct page {
 #endif
 #endif
 		struct kmem_cache *slab_cache;	/* SL[AU]B: Pointer to slab */
+
+		/* for non-slab kmem pages (see alloc_kmem_pages):
+		 * memcg which the page is charged to */
+		struct mem_cgroup *memcg;
+
 		struct page *first_page;	/* Compound tail pages */
 	};
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 4dedb67787c7..4b155ebf1973 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3304,28 +3304,11 @@ out:
 	return cachep;
 }
 
-/*
- * We need to verify if the allocation against current->mm->owner's memcg is
- * possible for the given order. But the page is not allocated yet, so we'll
- * need a further commit step to do the final arrangements.
- *
- * It is possible for the task to switch cgroups in this mean time, so at
- * commit time, we can't rely on task conversion any longer.  We'll then use
- * the handle argument to return to the caller which cgroup we should commit
- * against. We could also return the memcg directly and avoid the pointer
- * passing, but a boolean return value gives better semantics considering
- * the compiled-out case as well.
- *
- * Returning true means the allocation is possible.
- */
-bool
-__memcg_kmem_newpage_charge(gfp_t gfp, struct mem_cgroup **_memcg, int order)
+int __memcg_charge_kmem_pages(gfp_t gfp, int order, struct mem_cgroup **_memcg)
 {
 	struct mem_cgroup *memcg;
 	int ret;
 
-	*_memcg = NULL;
-
 	/*
 	 * Disabling accounting is only relevant for some specific memcg
 	 * internal allocations. Therefore we would initially not have such
@@ -3351,14 +3334,13 @@ __memcg_kmem_newpage_charge(gfp_t gfp, struct mem_cgroup **_memcg, int order)
 	 * allocations are extremely rare but can happen, for instance, for the
 	 * cache arrays. We bring this test here.
 	 */
-	if (!current->mm || current->memcg_kmem_skip_account)
-		return true;
+	if (current->memcg_kmem_skip_account)
+		return 0;
 
 	memcg = get_mem_cgroup_from_mm(current->mm);
-
 	if (!memcg_can_account_kmem(memcg)) {
 		css_put(&memcg->css);
-		return true;
+		return 0;
 	}
 
 	ret = memcg_charge_kmem(memcg, gfp, PAGE_SIZE << order);
@@ -3366,51 +3348,11 @@ __memcg_kmem_newpage_charge(gfp_t gfp, struct mem_cgroup **_memcg, int order)
 		*_memcg = memcg;
 
 	css_put(&memcg->css);
-	return (ret == 0);
-}
-
-void __memcg_kmem_commit_charge(struct page *page, struct mem_cgroup *memcg,
-			      int order)
-{
-	struct page_cgroup *pc;
-
-	VM_BUG_ON(mem_cgroup_is_root(memcg));
-
-	/* The page allocation failed. Revert */
-	if (!page) {
-		memcg_uncharge_kmem(memcg, PAGE_SIZE << order);
-		return;
-	}
-	/*
-	 * The page is freshly allocated and not visible to any
-	 * outside callers yet.  Set up pc non-atomically.
-	 */
-	pc = lookup_page_cgroup(page);
-	pc->mem_cgroup = memcg;
-	pc->flags = PCG_USED;
+	return ret;
 }
 
-void __memcg_kmem_uncharge_pages(struct page *page, int order)
+void __memcg_uncharge_kmem_pages(struct mem_cgroup *memcg, int order)
 {
-	struct mem_cgroup *memcg = NULL;
-	struct page_cgroup *pc;
-
-
-	pc = lookup_page_cgroup(page);
-	if (!PageCgroupUsed(pc))
-		return;
-
-	memcg = pc->mem_cgroup;
-	pc->flags = 0;
-
-	/*
-	 * We trust that only if there is a memcg associated with the page, it
-	 * is a valid allocation
-	 */
-	if (!memcg)
-		return;
-
-	VM_BUG_ON_PAGE(mem_cgroup_is_root(memcg), page);
 	memcg_uncharge_kmem(memcg, PAGE_SIZE << order);
 }
 #else
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4351dd972803..f4090a582caf 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2902,24 +2902,32 @@ EXPORT_SYMBOL(free_pages);
 struct page *alloc_kmem_pages(gfp_t gfp_mask, unsigned int order)
 {
 	struct page *page;
-	struct mem_cgroup *memcg = NULL;
+	struct mem_cgroup *memcg;
 
-	if (!memcg_kmem_newpage_charge(gfp_mask, &memcg, order))
+	if (memcg_charge_kmem_pages(gfp_mask, order, &memcg) != 0)
 		return NULL;
 	page = alloc_pages(gfp_mask, order);
-	memcg_kmem_commit_charge(page, memcg, order);
+	if (!page) {
+		memcg_uncharge_kmem_pages(memcg, order);
+		return NULL;
+	}
+	page->memcg = memcg;
 	return page;
 }
 
 struct page *alloc_kmem_pages_node(int nid, gfp_t gfp_mask, unsigned int order)
 {
 	struct page *page;
-	struct mem_cgroup *memcg = NULL;
+	struct mem_cgroup *memcg;
 
-	if (!memcg_kmem_newpage_charge(gfp_mask, &memcg, order))
+	if (memcg_charge_kmem_pages(gfp_mask, order, &memcg) != 0)
 		return NULL;
 	page = alloc_pages_node(nid, gfp_mask, order);
-	memcg_kmem_commit_charge(page, memcg, order);
+	if (!page) {
+		memcg_uncharge_kmem_pages(memcg, order);
+		return NULL;
+	}
+	page->memcg = memcg;
 	return page;
 }
 
@@ -2929,7 +2937,7 @@ struct page *alloc_kmem_pages_node(int nid, gfp_t gfp_mask, unsigned int order)
  */
 void __free_kmem_pages(struct page *page, unsigned int order)
 {
-	memcg_kmem_uncharge_pages(page, order);
+	memcg_uncharge_kmem_pages(page->memcg, order);
 	__free_pages(page, order);
 }
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
