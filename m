Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp02.au.ibm.com (8.13.1/8.13.1) with ESMTP id m8I12Smt019185
	for <linux-mm@kvack.org>; Thu, 18 Sep 2008 11:02:28 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m8I12PrQ3055868
	for <linux-mm@kvack.org>; Thu, 18 Sep 2008 11:03:01 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m8I12PmY024931
	for <linux-mm@kvack.org>; Thu, 18 Sep 2008 11:02:25 +1000
Date: Wed, 17 Sep 2008 16:28:26 -0700
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: [RFC][PATCH] Remove cgroup member from struct page (v3)
Message-ID: <20080917232826.GA19256@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <200809091500.10619.nickpiggin@yahoo.com.au> <20080909141244.721dfd39.kamezawa.hiroyu@jp.fujitsu.com> <30229398.1220963412858.kamezawa.hiroyu@jp.fujitsu.com> <20080910012048.GA32752@balbir.in.ibm.com> <1221085260.6781.69.camel@nimitz> <48C84C0A.30902@linux.vnet.ibm.com> <1221087408.6781.73.camel@nimitz> <20080911103500.d22d0ea1.kamezawa.hiroyu@jp.fujitsu.com> <48C878AD.4040404@linux.vnet.ibm.com> <20080911105638.1581db90.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20080911105638.1581db90.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, hugh@veritas.com, menage@google.com, xemul@openvz.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Before trying the sparsemem approach, I tried a radix tree per node,
per zone and I seemed to actually get some performance
improvement.(1.5% (noise maybe))

But please do see and review (tested on my x86_64 box with unixbench
and some other simple tests)

v4..v3
1. Use a radix tree per node, per zone

v3...v2
1. Convert flags to unsigned long
2. Move page_cgroup->lock to a bit spin lock in flags

v2...v1

1. Fix a small bug, don't call radix_tree_preload_end(), if preload fails

This is a rewrite of a patch I had written long back to remove struct page
(I shared the patches with Kamezawa, but never posted them anywhere else).
I spent the weekend, cleaning them up for 2.6.27-rc5-mmotm (29 Aug 2008).

I've tested the patches on an x86_64 box, I've run a simple test running
under the memory control group and the same test running concurrently under
two different groups (and creating pressure within their groups).

Advantages of the patch

1. It removes the extra pointer in struct page

Disadvantages

1. Radix tree lookup is not an O(1) operation, once the page is known
   getting to the page_cgroup (pc) is a little more expensive now.

This is an initial RFC (version 3) for comments

TODOs

1. Test the page migration changes

Performance

In a unixbench run, these patches had a performance impact of 2% (slowdown).

Comments/Reviews?

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 include/linux/memcontrol.h |   23 +++
 include/linux/mm_types.h   |    4 
 mm/memcontrol.c            |  264 ++++++++++++++++++++++++++++++++++-----------
 3 files changed, 221 insertions(+), 70 deletions(-)

diff -puN mm/memcontrol.c~memcg_move_to_radix_tree mm/memcontrol.c
--- linux-2.6.27-rc5/mm/memcontrol.c~memcg_move_to_radix_tree	2008-09-16 17:10:15.000000000 -0700
+++ linux-2.6.27-rc5-balbir/mm/memcontrol.c	2008-09-17 16:15:01.000000000 -0700
@@ -24,6 +24,7 @@
 #include <linux/smp.h>
 #include <linux/page-flags.h>
 #include <linux/backing-dev.h>
+#include <linux/radix-tree.h>
 #include <linux/bit_spinlock.h>
 #include <linux/rcupdate.h>
 #include <linux/slab.h>
@@ -41,6 +42,24 @@ static struct kmem_cache *page_cgroup_ca
 #define MEM_CGROUP_RECLAIM_RETRIES	5
 
 /*
+ * MAX_NR_ZONES might be an invalid optimization, since we don't use
+ * allocations from __GFP_HIGHMEM
+ */
+
+struct mem_cgroup_radix_tree_per_zone {
+	struct radix_tree_root tree;
+	spinlock_t lock;
+};
+
+struct mem_cgroup_radix_tree_per_node {
+	struct mem_cgroup_radix_tree_per_zone per_zone[MAX_NR_ZONES];
+};
+
+static struct mem_cgroup_radix_tree_per_node
+*mem_cgroup_radix_tree_info[MAX_NUMNODES];
+static int radix_tree_initialized;
+
+/*
  * Statistics for memory cgroup.
  */
 enum mem_cgroup_stat_index {
@@ -137,20 +156,6 @@ struct mem_cgroup {
 static struct mem_cgroup init_mem_cgroup;
 
 /*
- * We use the lower bit of the page->page_cgroup pointer as a bit spin
- * lock.  We need to ensure that page->page_cgroup is at least two
- * byte aligned (based on comments from Nick Piggin).  But since
- * bit_spin_lock doesn't actually set that lock bit in a non-debug
- * uniprocessor kernel, we should avoid setting it here too.
- */
-#define PAGE_CGROUP_LOCK_BIT 	0x0
-#if defined(CONFIG_SMP) || defined(CONFIG_DEBUG_SPINLOCK)
-#define PAGE_CGROUP_LOCK 	(1 << PAGE_CGROUP_LOCK_BIT)
-#else
-#define PAGE_CGROUP_LOCK	0x0
-#endif
-
-/*
  * A page_cgroup page is associated with every page descriptor. The
  * page_cgroup helps us identify information about the cgroup
  */
@@ -158,12 +163,17 @@ struct page_cgroup {
 	struct list_head lru;		/* per cgroup LRU list */
 	struct page *page;
 	struct mem_cgroup *mem_cgroup;
-	int flags;
+	unsigned long flags;
 };
-#define PAGE_CGROUP_FLAG_CACHE	   (0x1)	/* charged as cache */
-#define PAGE_CGROUP_FLAG_ACTIVE    (0x2)	/* page is active in this cgroup */
-#define PAGE_CGROUP_FLAG_FILE	   (0x4)	/* page is file system backed */
-#define PAGE_CGROUP_FLAG_UNEVICTABLE (0x8)	/* page is unevictableable */
+
+/*
+ * LOCK_BIT is 0, with value 1
+ */
+#define PAGE_CGROUP_FLAG_LOCK_BIT  (0x0)    /* lock bit */
+#define PAGE_CGROUP_FLAG_CACHE	   (0x2)    /* charged as cache */
+#define PAGE_CGROUP_FLAG_ACTIVE    (0x4)    /* page is active in this cgroup */
+#define PAGE_CGROUP_FLAG_FILE	   (0x8)    /* page is file system backed */
+#define PAGE_CGROUP_FLAG_UNEVICTABLE (0x10) /* page is unevictableable */
 
 static int page_cgroup_nid(struct page_cgroup *pc)
 {
@@ -248,35 +258,103 @@ struct mem_cgroup *mem_cgroup_from_task(
 				struct mem_cgroup, css);
 }
 
-static inline int page_cgroup_locked(struct page *page)
+static inline void lock_page_cgroup(struct page_cgroup *pc)
 {
-	return bit_spin_is_locked(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
+	BUG_ON(!pc);
+	bit_spin_lock(PAGE_CGROUP_FLAG_LOCK_BIT, &pc->flags);
 }
 
-static void page_assign_page_cgroup(struct page *page, struct page_cgroup *pc)
+static inline int trylock_page_cgroup(struct page_cgroup *pc)
 {
-	VM_BUG_ON(!page_cgroup_locked(page));
-	page->page_cgroup = ((unsigned long)pc | PAGE_CGROUP_LOCK);
+	BUG_ON(!pc);
+	return bit_spin_trylock(PAGE_CGROUP_FLAG_LOCK_BIT, &pc->flags);
 }
 
-struct page_cgroup *page_get_page_cgroup(struct page *page)
+static inline void unlock_page_cgroup(struct page_cgroup *pc)
 {
-	return (struct page_cgroup *) (page->page_cgroup & ~PAGE_CGROUP_LOCK);
+	BUG_ON(!pc);
+	BUG_ON(!bit_spin_is_locked(PAGE_CGROUP_FLAG_LOCK_BIT, &pc->flags));
+	bit_spin_unlock(PAGE_CGROUP_FLAG_LOCK_BIT, &pc->flags);
 }
 
-static void lock_page_cgroup(struct page *page)
+static int page_assign_page_cgroup(struct page *page, struct page_cgroup *pc,
+					gfp_t gfp_mask)
 {
-	bit_spin_lock(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
-}
+	unsigned long pfn = page_to_pfn(page);
+	unsigned long flags;
+	int err = 0;
+	struct page_cgroup *old_pc;
+	int node = page_to_nid(page);
+	int zone = page_zonenum(page);
+	struct mem_cgroup_radix_tree_per_node *pn;
 
-static int try_lock_page_cgroup(struct page *page)
-{
-	return bit_spin_trylock(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
+	if (pc) {
+		err = radix_tree_preload(gfp_mask & ~__GFP_HIGHMEM);
+		if (err) {
+			printk(KERN_WARNING "could not preload radix tree "
+				"in %s\n", __func__);
+			goto done;
+		}
+	}
+
+	pn = mem_cgroup_radix_tree_info[node];
+	spin_lock_irqsave(&pn->per_zone[zone].lock, flags);
+	old_pc = radix_tree_lookup(&pn->per_zone[zone].tree, pfn);
+	if (pc && old_pc) {
+		err = -EEXIST;
+		goto pc_race;
+	}
+	if (pc) {
+		err = radix_tree_insert(&pn->per_zone[zone].tree, pfn, pc);
+		if (err)
+			printk(KERN_WARNING "Inserting into radix tree failed "
+				"in %s\n", __func__);
+	} else
+		radix_tree_delete(&pn->per_zone[zone].tree, pfn);
+pc_race:
+	spin_unlock_irqrestore(&pn->per_zone[zone].lock, flags);
+	if (pc)
+		radix_tree_preload_end();
+done:
+	return err;
 }
 
-static void unlock_page_cgroup(struct page *page)
+struct page_cgroup *__page_get_page_cgroup(struct page *page, bool lock,
+						bool trylock)
 {
-	bit_spin_unlock(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
+	unsigned long pfn = page_to_pfn(page);
+	struct page_cgroup *pc;
+	int ret;
+	int node = page_to_nid(page);
+	int zone = page_zonenum(page);
+	struct mem_cgroup_radix_tree_per_node *pn;
+
+	/*
+	 * If radix tree is not initialized, then there is no association
+	 * between page_cgroups and pages. This is likely to occur at
+	 * boot time (from free_all_bootmem... leading to free_hot_cold_page)
+	 */
+	if (!radix_tree_initialized)
+		return NULL;
+
+	BUG_ON(lock && trylock);
+
+	pn = mem_cgroup_radix_tree_info[node];
+	rcu_read_lock();
+	pc = radix_tree_lookup(&pn->per_zone[zone].tree, pfn);
+
+	if (pc && lock)
+		lock_page_cgroup(pc);
+
+	if (pc && trylock) {
+		ret = trylock_page_cgroup(pc);
+		if (!ret)
+			pc = NULL;
+	}
+
+	rcu_read_unlock();
+
+	return pc;
 }
 
 static void __mem_cgroup_remove_list(struct mem_cgroup_per_zone *mz,
@@ -377,17 +455,15 @@ void mem_cgroup_move_lists(struct page *
 	 * safely get to page_cgroup without it, so just try_lock it:
 	 * mem_cgroup_isolate_pages allows for page left on wrong list.
 	 */
-	if (!try_lock_page_cgroup(page))
+	pc = page_get_page_cgroup_trylock(page);
+	if (!pc)
 		return;
 
-	pc = page_get_page_cgroup(page);
-	if (pc) {
-		mz = page_cgroup_zoneinfo(pc);
-		spin_lock_irqsave(&mz->lru_lock, flags);
-		__mem_cgroup_move_lists(pc, lru);
-		spin_unlock_irqrestore(&mz->lru_lock, flags);
-	}
-	unlock_page_cgroup(page);
+	mz = page_cgroup_zoneinfo(pc);
+	spin_lock_irqsave(&mz->lru_lock, flags);
+	__mem_cgroup_move_lists(pc, lru);
+	spin_unlock_irqrestore(&mz->lru_lock, flags);
+	unlock_page_cgroup(pc);
 }
 
 /*
@@ -516,7 +592,7 @@ static int mem_cgroup_charge_common(stru
 				struct mem_cgroup *memcg)
 {
 	struct mem_cgroup *mem;
-	struct page_cgroup *pc;
+	struct page_cgroup *pc, *old_pc;
 	unsigned long flags;
 	unsigned long nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
 	struct mem_cgroup_per_zone *mz;
@@ -569,35 +645,49 @@ static int mem_cgroup_charge_common(stru
 
 	pc->mem_cgroup = mem;
 	pc->page = page;
+	pc->flags = 0;		/* No lock, no other bits either */
+
 	/*
 	 * If a page is accounted as a page cache, insert to inactive list.
 	 * If anon, insert to active list.
 	 */
 	if (ctype == MEM_CGROUP_CHARGE_TYPE_CACHE) {
-		pc->flags = PAGE_CGROUP_FLAG_CACHE;
+		pc->flags |= PAGE_CGROUP_FLAG_CACHE;
 		if (page_is_file_cache(page))
 			pc->flags |= PAGE_CGROUP_FLAG_FILE;
 		else
 			pc->flags |= PAGE_CGROUP_FLAG_ACTIVE;
 	} else
-		pc->flags = PAGE_CGROUP_FLAG_ACTIVE;
+		pc->flags |= PAGE_CGROUP_FLAG_ACTIVE;
 
-	lock_page_cgroup(page);
-	if (unlikely(page_get_page_cgroup(page))) {
-		unlock_page_cgroup(page);
+	old_pc = page_get_page_cgroup_locked(page);
+	if (old_pc) {
+		unlock_page_cgroup(old_pc);
+		res_counter_uncharge(&mem->res, PAGE_SIZE);
+		css_put(&mem->css);
+		kmem_cache_free(page_cgroup_cache, pc);
+		goto done;
+	}
+
+	lock_page_cgroup(pc);
+	/*
+	 * page_get_page_cgroup() does not necessarily guarantee that
+	 * there will be no race in checking for pc, page_assign_page_pc()
+	 * will definitely catch it.
+	 */
+	if (page_assign_page_cgroup(page, pc, gfp_mask)) {
+		unlock_page_cgroup(pc);
 		res_counter_uncharge(&mem->res, PAGE_SIZE);
 		css_put(&mem->css);
 		kmem_cache_free(page_cgroup_cache, pc);
 		goto done;
 	}
-	page_assign_page_cgroup(page, pc);
 
 	mz = page_cgroup_zoneinfo(pc);
 	spin_lock_irqsave(&mz->lru_lock, flags);
 	__mem_cgroup_add_list(mz, pc);
 	spin_unlock_irqrestore(&mz->lru_lock, flags);
-
-	unlock_page_cgroup(page);
+	unlock_page_cgroup(pc);
 done:
 	return 0;
 out:
@@ -645,15 +735,13 @@ int mem_cgroup_cache_charge(struct page 
 	if (!(gfp_mask & __GFP_WAIT)) {
 		struct page_cgroup *pc;
 
-		lock_page_cgroup(page);
-		pc = page_get_page_cgroup(page);
+		pc = page_get_page_cgroup_locked(page);
 		if (pc) {
 			VM_BUG_ON(pc->page != page);
 			VM_BUG_ON(!pc->mem_cgroup);
-			unlock_page_cgroup(page);
+			unlock_page_cgroup(pc);
 			return 0;
 		}
-		unlock_page_cgroup(page);
 	}
 
 	if (unlikely(!mm))
@@ -673,6 +761,7 @@ __mem_cgroup_uncharge_common(struct page
 	struct mem_cgroup *mem;
 	struct mem_cgroup_per_zone *mz;
 	unsigned long flags;
+	int ret;
 
 	if (mem_cgroup_subsys.disabled)
 		return;
@@ -680,8 +769,7 @@ __mem_cgroup_uncharge_common(struct page
 	/*
 	 * Check if our page_cgroup is valid
 	 */
-	lock_page_cgroup(page);
-	pc = page_get_page_cgroup(page);
+	pc = page_get_page_cgroup_locked(page);
 	if (unlikely(!pc))
 		goto unlock;
 
@@ -697,8 +785,9 @@ __mem_cgroup_uncharge_common(struct page
 	__mem_cgroup_remove_list(mz, pc);
 	spin_unlock_irqrestore(&mz->lru_lock, flags);
 
-	page_assign_page_cgroup(page, NULL);
-	unlock_page_cgroup(page);
+	ret = page_assign_page_cgroup(page, NULL, GFP_KERNEL);
+	VM_BUG_ON(ret);
+	unlock_page_cgroup(pc);
 
 	mem = pc->mem_cgroup;
 	res_counter_uncharge(&mem->res, PAGE_SIZE);
@@ -707,7 +796,14 @@ __mem_cgroup_uncharge_common(struct page
 	kmem_cache_free(page_cgroup_cache, pc);
 	return;
 unlock:
-	unlock_page_cgroup(page);
+	unlock_page_cgroup(pc);
+}
+
+void page_reset_bad_cgroup(struct page *page)
+{
+	int ret;
+	ret = page_assign_page_cgroup(page, NULL, GFP_KERNEL);
+	VM_BUG_ON(ret);
 }
 
 void mem_cgroup_uncharge_page(struct page *page)
@@ -734,15 +830,14 @@ int mem_cgroup_prepare_migration(struct 
 	if (mem_cgroup_subsys.disabled)
 		return 0;
 
-	lock_page_cgroup(page);
-	pc = page_get_page_cgroup(page);
+	pc = page_get_page_cgroup_locked(page);
 	if (pc) {
 		mem = pc->mem_cgroup;
 		css_get(&mem->css);
 		if (pc->flags & PAGE_CGROUP_FLAG_CACHE)
 			ctype = MEM_CGROUP_CHARGE_TYPE_CACHE;
+		unlock_page_cgroup(pc);
 	}
-	unlock_page_cgroup(page);
 	if (mem) {
 		ret = mem_cgroup_charge_common(newpage, NULL, GFP_KERNEL,
 			ctype, mem);
@@ -1038,6 +1133,38 @@ static struct cftype mem_cgroup_files[] 
 	},
 };
 
+/**
+ *
+ * @node: node for which we intend to alloc radix tree info
+ *
+ * NOTE: using per zone radix trees might not be such a great idea, since
+ * we don't allocate any of the page cgroups using __GFP_HIGHMEM
+ */
+static int alloc_mem_cgroup_per_zone_radix_tree_info(int node)
+{
+	struct mem_cgroup_radix_tree_per_node *pn;
+	int n = node;
+	int zone;
+
+	if (!node_state(node, N_NORMAL_MEMORY))
+		n = -1;
+
+	pn = kzalloc_node(sizeof(*pn), GFP_KERNEL, n);
+	if (!pn)
+		return -ENOMEM;
+
+	mem_cgroup_radix_tree_info[node] = pn;
+
+	for (zone = 0; zone < MAX_NR_ZONES; zone++)
+		spin_lock_init(&pn->per_zone[zone].lock);
+	return 0;
+}
+
+static void free_mem_cgroup_per_zone_radix_tree_info(int node)
+{
+	kfree(mem_cgroup_radix_tree_info[node]);
+}
+
 static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *mem, int node)
 {
 	struct mem_cgroup_per_node *pn;
@@ -1103,10 +1230,16 @@ mem_cgroup_create(struct cgroup_subsys *
 {
 	struct mem_cgroup *mem;
 	int node;
+	bool radix_tree_info_allocated = false;
 
 	if (unlikely((cont->parent) == NULL)) {
 		mem = &init_mem_cgroup;
 		page_cgroup_cache = KMEM_CACHE(page_cgroup, SLAB_PANIC);
+		radix_tree_info_allocated = true;
+		for_each_node_state(node, N_POSSIBLE)
+			if (alloc_mem_cgroup_per_zone_radix_tree_info(node))
+				goto cleanup_radix_tree;
+		radix_tree_initialized = 1;
 	} else {
 		mem = mem_cgroup_alloc();
 		if (!mem)
@@ -1120,6 +1253,9 @@ mem_cgroup_create(struct cgroup_subsys *
 			goto free_out;
 
 	return &mem->css;
+cleanup_radix_tree:
+	free_mem_cgroup_per_zone_radix_tree_info(node);
+	return ERR_PTR(-ENOMEM);
 free_out:
 	for_each_node_state(node, N_POSSIBLE)
 		free_mem_cgroup_per_zone_info(mem, node);
diff -puN include/linux/memcontrol.h~memcg_move_to_radix_tree include/linux/memcontrol.h
--- linux-2.6.27-rc5/include/linux/memcontrol.h~memcg_move_to_radix_tree	2008-09-16 17:10:15.000000000 -0700
+++ linux-2.6.27-rc5-balbir/include/linux/memcontrol.h	2008-09-16 17:10:15.000000000 -0700
@@ -27,9 +27,28 @@ struct mm_struct;
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
 
-#define page_reset_bad_cgroup(page)	((page)->page_cgroup = 0)
+extern void page_reset_bad_cgroup(struct page *page);
+extern struct page_cgroup *__page_get_page_cgroup(struct page *page, bool lock,
+							bool trylock);
+
+static __always_inline
+struct page_cgroup *page_get_page_cgroup(struct page *page)
+{
+	return __page_get_page_cgroup(page, false, false);
+}
+
+static __always_inline
+struct page_cgroup *page_get_page_cgroup_trylock(struct page *page)
+{
+	return __page_get_page_cgroup(page, false, true);
+}
+
+static __always_inline
+struct page_cgroup *page_get_page_cgroup_locked(struct page *page)
+{
+	return __page_get_page_cgroup(page, true, false);
+}
 
-extern struct page_cgroup *page_get_page_cgroup(struct page *page);
 extern int mem_cgroup_charge(struct page *page, struct mm_struct *mm,
 				gfp_t gfp_mask);
 extern int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
diff -puN include/linux/mm_types.h~memcg_move_to_radix_tree include/linux/mm_types.h
--- linux-2.6.27-rc5/include/linux/mm_types.h~memcg_move_to_radix_tree	2008-09-16 17:10:15.000000000 -0700
+++ linux-2.6.27-rc5-balbir/include/linux/mm_types.h	2008-09-16 17:10:15.000000000 -0700
@@ -92,10 +92,6 @@ struct page {
 	void *virtual;			/* Kernel virtual address (NULL if
 					   not kmapped, ie. highmem) */
 #endif /* WANT_PAGE_VIRTUAL */
-#ifdef CONFIG_CGROUP_MEM_RES_CTLR
-	unsigned long page_cgroup;
-#endif
-
 #ifdef CONFIG_KMEMCHECK
 	void *shadow;
 #endif
diff -puN mm/page_alloc.c~memcg_move_to_radix_tree mm/page_alloc.c
diff -puN include/linux/mmzone.h~memcg_move_to_radix_tree include/linux/mmzone.h
_

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
