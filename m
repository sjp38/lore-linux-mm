Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f181.google.com (mail-lb0-f181.google.com [209.85.217.181])
	by kanga.kvack.org (Postfix) with ESMTP id 274E06B00AF
	for <linux-mm@kvack.org>; Wed, 26 Feb 2014 10:05:43 -0500 (EST)
Received: by mail-lb0-f181.google.com with SMTP id c11so699552lbj.26
        for <linux-mm@kvack.org>; Wed, 26 Feb 2014 07:05:42 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id w9si1818087laj.103.2014.02.26.07.05.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Feb 2014 07:05:41 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 10/12] memcg: kill GFP_KMEMCG and stuff
Date: Wed, 26 Feb 2014 19:05:15 +0400
Message-ID: <2d22758b4cfea1eff247a65bb26f6179674ed6dc.1393423762.git.vdavydov@parallels.com>
In-Reply-To: <cover.1393423762.git.vdavydov@parallels.com>
References: <cover.1393423762.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: hannes@cmpxchg.org, mhocko@suse.cz, glommer@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

No one uses it any more. Just get rid of it.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Glauber Costa <glommer@gmail.com>
---
 include/linux/gfp.h             |    5 --
 include/linux/memcontrol.h      |   90 ----------------------------
 include/trace/events/gfpflags.h |    1 -
 mm/memcontrol.c                 |  125 ---------------------------------------
 mm/page_alloc.c                 |   35 -----------
 5 files changed, 256 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 39b81dc7d01a..e37b662cd869 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -31,7 +31,6 @@ struct vm_area_struct;
 #define ___GFP_HARDWALL		0x20000u
 #define ___GFP_THISNODE		0x40000u
 #define ___GFP_RECLAIMABLE	0x80000u
-#define ___GFP_KMEMCG		0x100000u
 #define ___GFP_NOTRACK		0x200000u
 #define ___GFP_NO_KSWAPD	0x400000u
 #define ___GFP_OTHER_NODE	0x800000u
@@ -91,7 +90,6 @@ struct vm_area_struct;
 
 #define __GFP_NO_KSWAPD	((__force gfp_t)___GFP_NO_KSWAPD)
 #define __GFP_OTHER_NODE ((__force gfp_t)___GFP_OTHER_NODE) /* On behalf of other node */
-#define __GFP_KMEMCG	((__force gfp_t)___GFP_KMEMCG) /* Allocation comes from a memcg-accounted resource */
 #define __GFP_WRITE	((__force gfp_t)___GFP_WRITE)	/* Allocator intends to dirty page */
 
 /*
@@ -372,9 +370,6 @@ extern void free_pages(unsigned long addr, unsigned int order);
 extern void free_hot_cold_page(struct page *page, int cold);
 extern void free_hot_cold_page_list(struct list_head *list, int cold);
 
-extern void __free_memcg_kmem_pages(struct page *page, unsigned int order);
-extern void free_memcg_kmem_pages(unsigned long addr, unsigned int order);
-
 #define __free_page(page) __free_pages((page), 0)
 #define free_page(addr) free_pages((addr), 0)
 
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 3f0ff043ba94..f6fa5726b1a7 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -490,12 +490,6 @@ static inline bool memcg_kmem_enabled(void)
  * conditions, but because they are pretty simple, they are expected to be
  * fast.
  */
-bool __memcg_kmem_newpage_charge(gfp_t gfp, struct mem_cgroup **memcg,
-					int order);
-void __memcg_kmem_commit_charge(struct page *page,
-				       struct mem_cgroup *memcg, int order);
-void __memcg_kmem_uncharge_pages(struct page *page, int order);
-
 struct kmem_cache *__memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp);
 int __memcg_kmem_charge_slab(struct kmem_cache *s, gfp_t gfp, int nr_pages);
 void __memcg_kmem_uncharge_slab(struct kmem_cache *s, int nr_pages);
@@ -516,75 +510,6 @@ void memcg_update_array_size(int num_groups);
 void kmem_cache_destroy_memcg_children(struct kmem_cache *s);
 
 /**
- * memcg_kmem_newpage_charge: verify if a new kmem allocation is allowed.
- * @gfp: the gfp allocation flags.
- * @memcg: a pointer to the memcg this was charged against.
- * @order: allocation order.
- *
- * returns true if the memcg where the current task belongs can hold this
- * allocation.
- *
- * We return true automatically if this allocation is not to be accounted to
- * any memcg.
- */
-static inline bool
-memcg_kmem_newpage_charge(gfp_t gfp, struct mem_cgroup **memcg, int order)
-{
-	if (!memcg_kmem_enabled())
-		return true;
-
-	/*
-	 * __GFP_NOFAIL allocations will move on even if charging is not
-	 * possible. Therefore we don't even try, and have this allocation
-	 * unaccounted. We could in theory charge it with
-	 * res_counter_charge_nofail, but we hope those allocations are rare,
-	 * and won't be worth the trouble.
-	 */
-	if (!(gfp & __GFP_KMEMCG) || (gfp & __GFP_NOFAIL))
-		return true;
-	if (in_interrupt() || (!current->mm) || (current->flags & PF_KTHREAD))
-		return true;
-
-	/* If the test is dying, just let it go. */
-	if (unlikely(fatal_signal_pending(current)))
-		return true;
-
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
-}
-
-/**
- * memcg_kmem_commit_charge: embeds correct memcg in a page
- * @page: pointer to struct page recently allocated
- * @memcg: the memcg structure we charged against
- * @order: allocation order.
- *
- * Needs to be called after memcg_kmem_newpage_charge, regardless of success or
- * failure of the allocation. if @page is NULL, this function will revert the
- * charges. Otherwise, it will commit the memcg given by @memcg to the
- * corresponding page_cgroup.
- */
-static inline void
-memcg_kmem_commit_charge(struct page *page, struct mem_cgroup *memcg, int order)
-{
-	if (memcg_kmem_enabled() && memcg)
-		__memcg_kmem_commit_charge(page, memcg, order);
-}
-
-/**
  * memcg_kmem_get_cache: selects the correct per-memcg cache for allocation
  * @cachep: the original global kmem cache
  * @gfp: allocation flags.
@@ -627,21 +552,6 @@ static inline bool memcg_kmem_enabled(void)
 	return false;
 }
 
-static inline bool
-memcg_kmem_newpage_charge(gfp_t gfp, struct mem_cgroup **memcg, int order)
-{
-	return true;
-}
-
-static inline void memcg_kmem_uncharge_pages(struct page *page, int order)
-{
-}
-
-static inline void
-memcg_kmem_commit_charge(struct page *page, struct mem_cgroup *memcg, int order)
-{
-}
-
 static inline int memcg_cache_id(struct mem_cgroup *memcg)
 {
 	return -1;
diff --git a/include/trace/events/gfpflags.h b/include/trace/events/gfpflags.h
index 1eddbf1557f2..d6fd8e5b14b7 100644
--- a/include/trace/events/gfpflags.h
+++ b/include/trace/events/gfpflags.h
@@ -34,7 +34,6 @@
 	{(unsigned long)__GFP_HARDWALL,		"GFP_HARDWALL"},	\
 	{(unsigned long)__GFP_THISNODE,		"GFP_THISNODE"},	\
 	{(unsigned long)__GFP_RECLAIMABLE,	"GFP_RECLAIMABLE"},	\
-	{(unsigned long)__GFP_KMEMCG,		"GFP_KMEMCG"},		\
 	{(unsigned long)__GFP_MOVABLE,		"GFP_MOVABLE"},		\
 	{(unsigned long)__GFP_NOTRACK,		"GFP_NOTRACK"},		\
 	{(unsigned long)__GFP_NO_KSWAPD,	"GFP_NO_KSWAPD"},	\
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d60080812060..dad455a911d5 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3531,131 +3531,6 @@ out:
 	rcu_read_unlock();
 	return cachep;
 }
-EXPORT_SYMBOL(__memcg_kmem_get_cache);
-
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
-{
-	struct mem_cgroup *memcg;
-	int ret;
-
-	*_memcg = NULL;
-
-	/*
-	 * Disabling accounting is only relevant for some specific memcg
-	 * internal allocations. Therefore we would initially not have such
-	 * check here, since direct calls to the page allocator that are marked
-	 * with GFP_KMEMCG only happen outside memcg core. We are mostly
-	 * concerned with cache allocations, and by having this test at
-	 * memcg_kmem_get_cache, we are already able to relay the allocation to
-	 * the root cache and bypass the memcg cache altogether.
-	 *
-	 * There is one exception, though: the SLUB allocator does not create
-	 * large order caches, but rather service large kmallocs directly from
-	 * the page allocator. Therefore, the following sequence when backed by
-	 * the SLUB allocator:
-	 *
-	 *	memcg_stop_kmem_account();
-	 *	kmalloc(<large_number>)
-	 *	memcg_resume_kmem_account();
-	 *
-	 * would effectively ignore the fact that we should skip accounting,
-	 * since it will drive us directly to this function without passing
-	 * through the cache selector memcg_kmem_get_cache. Such large
-	 * allocations are extremely rare but can happen, for instance, for the
-	 * cache arrays. We bring this test here.
-	 */
-	if (!current->mm || current->memcg_kmem_skip_account)
-		return true;
-
-	memcg = try_get_mem_cgroup_from_mm(current->mm);
-
-	/*
-	 * very rare case described in mem_cgroup_from_task. Unfortunately there
-	 * isn't much we can do without complicating this too much, and it would
-	 * be gfp-dependent anyway. Just let it go
-	 */
-	if (unlikely(!memcg))
-		return true;
-
-	if (!memcg_can_account_kmem(memcg)) {
-		css_put(&memcg->css);
-		return true;
-	}
-
-	ret = memcg_charge_kmem(memcg, gfp, PAGE_SIZE << order);
-	if (!ret)
-		*_memcg = memcg;
-
-	css_put(&memcg->css);
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
-
-	pc = lookup_page_cgroup(page);
-	lock_page_cgroup(pc);
-	pc->mem_cgroup = memcg;
-	SetPageCgroupUsed(pc);
-	unlock_page_cgroup(pc);
-}
-
-void __memcg_kmem_uncharge_pages(struct page *page, int order)
-{
-	struct mem_cgroup *memcg = NULL;
-	struct page_cgroup *pc;
-
-
-	pc = lookup_page_cgroup(page);
-	/*
-	 * Fast unlocked return. Theoretically might have changed, have to
-	 * check again after locking.
-	 */
-	if (!PageCgroupUsed(pc))
-		return;
-
-	lock_page_cgroup(pc);
-	if (PageCgroupUsed(pc)) {
-		memcg = pc->mem_cgroup;
-		ClearPageCgroupUsed(pc);
-	}
-	unlock_page_cgroup(pc);
-
-	/*
-	 * We trust that only if there is a memcg associated with the page, it
-	 * is a valid allocation
-	 */
-	if (!memcg)
-		return;
-
-	VM_BUG_ON_PAGE(mem_cgroup_is_root(memcg), page);
-	memcg_uncharge_kmem(memcg, PAGE_SIZE << order);
-}
 
 static void __init memcg_kmem_init(void)
 {
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 9d6892c3527d..a7acceb00770 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2717,7 +2717,6 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	int migratetype = allocflags_to_migratetype(gfp_mask);
 	unsigned int cpuset_mems_cookie;
 	int alloc_flags = ALLOC_WMARK_LOW|ALLOC_CPUSET;
-	struct mem_cgroup *memcg = NULL;
 
 	gfp_mask &= gfp_allowed_mask;
 
@@ -2736,13 +2735,6 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	if (unlikely(!zonelist->_zonerefs->zone))
 		return NULL;
 
-	/*
-	 * Will only have any effect when __GFP_KMEMCG is set.  This is
-	 * verified in the (always inline) callee
-	 */
-	if (!memcg_kmem_newpage_charge(gfp_mask, &memcg, order))
-		return NULL;
-
 retry_cpuset:
 	cpuset_mems_cookie = read_mems_allowed_begin();
 
@@ -2785,8 +2777,6 @@ out:
 	if (unlikely(!page && read_mems_allowed_retry(cpuset_mems_cookie)))
 		goto retry_cpuset;
 
-	memcg_kmem_commit_charge(page, memcg, order);
-
 	if (page)
 		set_page_owner(page, order, gfp_mask);
 
@@ -2842,31 +2832,6 @@ void free_pages(unsigned long addr, unsigned int order)
 
 EXPORT_SYMBOL(free_pages);
 
-/*
- * __free_memcg_kmem_pages and free_memcg_kmem_pages will free
- * pages allocated with __GFP_KMEMCG.
- *
- * Those pages are accounted to a particular memcg, embedded in the
- * corresponding page_cgroup. To avoid adding a hit in the allocator to search
- * for that information only to find out that it is NULL for users who have no
- * interest in that whatsoever, we provide these functions.
- *
- * The caller knows better which flags it relies on.
- */
-void __free_memcg_kmem_pages(struct page *page, unsigned int order)
-{
-	memcg_kmem_uncharge_pages(page, order);
-	__free_pages(page, order);
-}
-
-void free_memcg_kmem_pages(unsigned long addr, unsigned int order)
-{
-	if (addr != 0) {
-		VM_BUG_ON(!virt_addr_valid((void *)addr));
-		__free_memcg_kmem_pages(virt_to_page((void *)addr), order);
-	}
-}
-
 static void *make_alloc_exact(unsigned long addr, unsigned order, size_t size)
 {
 	if (addr) {
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
