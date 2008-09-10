Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28esmtp01.in.ibm.com (8.13.1/8.13.1) with ESMTP id m8A1LqfM020170
	for <linux-mm@kvack.org>; Wed, 10 Sep 2008 06:51:52 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m8A1Kra21765426
	for <linux-mm@kvack.org>; Wed, 10 Sep 2008 06:51:52 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id m8A1KqLr015233
	for <linux-mm@kvack.org>; Wed, 10 Sep 2008 06:50:52 +0530
Date: Tue, 9 Sep 2008 18:20:48 -0700
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: [Approach #2] [RFC][PATCH] Remove cgroup member from struct page
Message-ID: <20080910012048.GA32752@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <48C66AF8.5070505@linux.vnet.ibm.com> <20080901161927.a1fe5afc.kamezawa.hiroyu@jp.fujitsu.com> <200809091358.28350.nickpiggin@yahoo.com.au> <20080909135317.cbff4871.kamezawa.hiroyu@jp.fujitsu.com> <200809091500.10619.nickpiggin@yahoo.com.au> <20080909141244.721dfd39.kamezawa.hiroyu@jp.fujitsu.com> <30229398.1220963412858.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <30229398.1220963412858.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, hugh@veritas.com, menage@google.com, xemul@openvz.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2008-09-09 21:30:12]:

> ----- Original Message -----
> >> Balbir, are you ok to CONFIG_CGROUP_MEM_RES_CTLR depends on CONFIG_SPARSEME
> M ?
> >> I thinks SPARSEMEM(SPARSEMEM_VMEMMAP) is widely used in various archs now.
> >
> >Can't we make it more generic. I was thinking of allocating memory for each n
> ode
> >for page_cgroups (of the size of spanned_pages) at initialization time. I've 
> not
> >yet prototyped the idea. BTW, even with your approach I fail to see why we ne
> ed
> >to add a dependency on CONFIG_SPARSEMEM (but again it is 4:30 in the morning 
> and
> >I might be missing the obvious)
> 
> Doesn't have big issue without CONFIG_SPARSEMEM, maybe.
> Sorry for my confusion.
>

OK, here is approach #2, it works for me and gives me really good
performance (surpassing even the current memory controller). I am
seeing almost a 7% increase

Caveats

1. Uses more memory (since it allocates memory for each node based on
   spanned_pages. Ignores holes, so might not be the most efficient,
   but it is a tradeoff of complexity versus space. I propose refining it
   as we go along.
2. Does not currently handle alloc_bootmem failure
3. Needs lots of testing/tuning and polishing

I've tested it on an x86_64 box with 4G of memory

Again, this is an early RFC patch, please review test. 

Comments/Reviews?

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 include/linux/memcontrol.h |   32 ++++++
 include/linux/mm_types.h   |    4 
 mm/memcontrol.c            |  212 +++++++++++++++++++++++++++------------------
 mm/page_alloc.c            |   10 --
 4 files changed, 162 insertions(+), 96 deletions(-)

diff -puN mm/memcontrol.c~memcg_move_to_radix_tree mm/memcontrol.c
--- linux-2.6.27-rc5/mm/memcontrol.c~memcg_move_to_radix_tree	2008-09-04 03:15:54.000000000 -0700
+++ linux-2.6.27-rc5-balbir/mm/memcontrol.c	2008-09-09 17:56:54.000000000 -0700
@@ -18,6 +18,7 @@
  */
 
 #include <linux/res_counter.h>
+#include <linux/bootmem.h>
 #include <linux/memcontrol.h>
 #include <linux/cgroup.h>
 #include <linux/mm.h>
@@ -37,9 +38,10 @@
 #include <asm/uaccess.h>
 
 struct cgroup_subsys mem_cgroup_subsys __read_mostly;
-static struct kmem_cache *page_cgroup_cache __read_mostly;
 #define MEM_CGROUP_RECLAIM_RETRIES	5
 
+static struct page_cgroup *pcg_map[MAX_NUMNODES];
+
 /*
  * Statistics for memory cgroup.
  */
@@ -137,20 +139,6 @@ struct mem_cgroup {
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
@@ -158,12 +146,26 @@ struct page_cgroup {
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
+#define PAGE_CGROUP_FLAG_LOCK_BIT  (0x0)  /* lock bit */
+
+#if defined(CONFIG_SMP) || defined(CONFIG_DEBUG_SPINLOCK)
+#define PAGE_CGROUP_FLAG_LOCK      (0x1)  /* lock value */
+#else
+#define PAGE_CGROUP_FLAG_LOCK      (0x0)  /* lock value */
+#endif
+
+#define PAGE_CGROUP_FLAG_CACHE	   (0x2)   /* charged as cache */
+#define PAGE_CGROUP_FLAG_ACTIVE    (0x4)   /* page is active in this cgroup */
+#define PAGE_CGROUP_FLAG_FILE	   (0x8)   /* page is file system backed */
+#define PAGE_CGROUP_FLAG_UNEVICTABLE (0x10)/* page is unevictableable */
+#define PAGE_CGROUP_FLAG_INUSE     (0x20)/* pc is allocated and in use */
+#define PAGE_CGROUP_FLAG_VALID     (0x40)/* pc is allocated and in use */
 
 static int page_cgroup_nid(struct page_cgroup *pc)
 {
@@ -248,35 +250,99 @@ struct mem_cgroup *mem_cgroup_from_task(
 				struct mem_cgroup, css);
 }
 
-static inline int page_cgroup_locked(struct page *page)
+static inline void lock_page_cgroup(struct page_cgroup *pc)
 {
-	return bit_spin_is_locked(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
+	bit_spin_lock(PAGE_CGROUP_FLAG_LOCK_BIT, &pc->flags);
 }
 
-static void page_assign_page_cgroup(struct page *page, struct page_cgroup *pc)
+static inline int trylock_page_cgroup(struct page_cgroup *pc)
 {
-	VM_BUG_ON(!page_cgroup_locked(page));
-	page->page_cgroup = ((unsigned long)pc | PAGE_CGROUP_LOCK);
+	return bit_spin_trylock(PAGE_CGROUP_FLAG_LOCK_BIT, &pc->flags);
 }
 
-struct page_cgroup *page_get_page_cgroup(struct page *page)
+static inline void unlock_page_cgroup(struct page_cgroup *pc)
 {
-	return (struct page_cgroup *) (page->page_cgroup & ~PAGE_CGROUP_LOCK);
+	bit_spin_unlock(PAGE_CGROUP_FLAG_LOCK_BIT, &pc->flags);
 }
 
-static void lock_page_cgroup(struct page *page)
+/*
+ * Called from memmap_init_zone(), has the advantage of dealing with
+ * memory_hotplug (Addition of memory)
+ */
+int page_cgroup_alloc(int n)
 {
-	bit_spin_lock(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
+	struct pglist_data *pgdat;
+	unsigned long size, start, end;
+
+	if (mem_cgroup_subsys.disabled)
+		return;
+
+	pgdat = NODE_DATA(n);
+	/*
+	 * Already allocated, leave
+	 */
+	if (pcg_map[n])
+		return 0;
+
+	start = pgdat->node_start_pfn;
+	end = pgdat->node_start_pfn + pgdat->node_spanned_pages;
+	size = (end - start) * sizeof(struct page_cgroup);
+	printk("Allocating %lu bytes for node %d\n", size, n);
+	pcg_map[n] = alloc_bootmem_node(pgdat, size);
+	/*
+	 * We can do smoother recovery
+	 */
+	BUG_ON(!pcg_map[n]);
+	return 0;
 }
 
-static int try_lock_page_cgroup(struct page *page)
+void page_cgroup_init(int nid, unsigned long pfn)
 {
-	return bit_spin_trylock(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
+	unsigned long node_pfn;
+	struct page_cgroup *pc;
+
+	if (mem_cgroup_subsys.disabled)
+		return;
+
+	node_pfn = pfn - NODE_DATA(nid)->node_start_pfn;
+	pc = &pcg_map[nid][node_pfn];
+
+	BUG_ON(!pc);
+	pc->flags = PAGE_CGROUP_FLAG_VALID;
+	INIT_LIST_HEAD(&pc->lru);
+	pc->page = NULL;
+	pc->mem_cgroup = NULL;
 }
 
-static void unlock_page_cgroup(struct page *page)
+struct page_cgroup *__page_get_page_cgroup(struct page *page, bool lock,
+						bool trylock)
 {
-	bit_spin_unlock(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
+	struct page_cgroup *pc;
+	int ret;
+	int node = page_to_nid(page);
+	unsigned long pfn;
+
+	pfn = page_to_pfn(page) - NODE_DATA(node)->node_start_pfn;
+	pc = &pcg_map[node][pfn];
+	BUG_ON(!(pc->flags & PAGE_CGROUP_FLAG_VALID));
+	if (lock)
+		lock_page_cgroup(pc);
+	else if (trylock) {
+		ret = trylock_page_cgroup(pc);
+		if (!ret)
+			pc = NULL;
+	}
+
+	return pc;
+}
+
+/*
+ * Should be called with page_cgroup lock held. Any additions to pc->flags
+ * should be reflected here. This might seem ugly, refine it later.
+ */
+void page_clear_page_cgroup(struct page_cgroup *pc)
+{
+	pc->flags &= ~PAGE_CGROUP_FLAG_INUSE;
 }
 
 static void __mem_cgroup_remove_list(struct mem_cgroup_per_zone *mz,
@@ -377,17 +443,15 @@ void mem_cgroup_move_lists(struct page *
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
@@ -521,10 +585,6 @@ static int mem_cgroup_charge_common(stru
 	unsigned long nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
 	struct mem_cgroup_per_zone *mz;
 
-	pc = kmem_cache_alloc(page_cgroup_cache, gfp_mask);
-	if (unlikely(pc == NULL))
-		goto err;
-
 	/*
 	 * We always charge the cgroup the mm_struct belongs to.
 	 * The mm_struct's mem_cgroup changes on task migration if the
@@ -567,43 +627,40 @@ static int mem_cgroup_charge_common(stru
 		}
 	}
 
+	pc = page_get_page_cgroup_locked(page);
+	if (pc->flags & PAGE_CGROUP_FLAG_INUSE) {
+		unlock_page_cgroup(pc);
+		res_counter_uncharge(&mem->res, PAGE_SIZE);
+		css_put(&mem->css);
+		goto done;
+	}
+
 	pc->mem_cgroup = mem;
 	pc->page = page;
+	pc->flags |= PAGE_CGROUP_FLAG_INUSE;
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
-
-	lock_page_cgroup(page);
-	if (unlikely(page_get_page_cgroup(page))) {
-		unlock_page_cgroup(page);
-		res_counter_uncharge(&mem->res, PAGE_SIZE);
-		css_put(&mem->css);
-		kmem_cache_free(page_cgroup_cache, pc);
-		goto done;
-	}
-	page_assign_page_cgroup(page, pc);
+		pc->flags |= PAGE_CGROUP_FLAG_ACTIVE;
 
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
 	css_put(&mem->css);
-	kmem_cache_free(page_cgroup_cache, pc);
-err:
 	return -ENOMEM;
 }
 
@@ -645,15 +702,14 @@ int mem_cgroup_cache_charge(struct page 
 	if (!(gfp_mask & __GFP_WAIT)) {
 		struct page_cgroup *pc;
 
-		lock_page_cgroup(page);
-		pc = page_get_page_cgroup(page);
-		if (pc) {
+		pc = page_get_page_cgroup_locked(page);
+		if (pc->flags & PAGE_CGROUP_FLAG_INUSE) {
 			VM_BUG_ON(pc->page != page);
 			VM_BUG_ON(!pc->mem_cgroup);
-			unlock_page_cgroup(page);
+			unlock_page_cgroup(pc);
 			return 0;
 		}
-		unlock_page_cgroup(page);
+		unlock_page_cgroup(pc);
 	}
 
 	if (unlikely(!mm))
@@ -680,34 +736,30 @@ __mem_cgroup_uncharge_common(struct page
 	/*
 	 * Check if our page_cgroup is valid
 	 */
-	lock_page_cgroup(page);
-	pc = page_get_page_cgroup(page);
-	if (unlikely(!pc))
-		goto unlock;
-
+	pc = page_get_page_cgroup_locked(page);
 	VM_BUG_ON(pc->page != page);
+	VM_BUG_ON(!(pc->flags & PAGE_CGROUP_FLAG_INUSE));
 
 	if ((ctype == MEM_CGROUP_CHARGE_TYPE_MAPPED)
 	    && ((pc->flags & PAGE_CGROUP_FLAG_CACHE)
 		|| page_mapped(page)))
 		goto unlock;
 
+	page_clear_page_cgroup(pc);
 	mz = page_cgroup_zoneinfo(pc);
 	spin_lock_irqsave(&mz->lru_lock, flags);
 	__mem_cgroup_remove_list(mz, pc);
 	spin_unlock_irqrestore(&mz->lru_lock, flags);
 
-	page_assign_page_cgroup(page, NULL);
-	unlock_page_cgroup(page);
+	unlock_page_cgroup(pc);
 
 	mem = pc->mem_cgroup;
 	res_counter_uncharge(&mem->res, PAGE_SIZE);
 	css_put(&mem->css);
 
-	kmem_cache_free(page_cgroup_cache, pc);
 	return;
 unlock:
-	unlock_page_cgroup(page);
+	unlock_page_cgroup(pc);
 }
 
 void mem_cgroup_uncharge_page(struct page *page)
@@ -734,15 +786,14 @@ int mem_cgroup_prepare_migration(struct 
 	if (mem_cgroup_subsys.disabled)
 		return 0;
 
-	lock_page_cgroup(page);
-	pc = page_get_page_cgroup(page);
-	if (pc) {
+	pc = page_get_page_cgroup_locked(page);
+	if (pc->flags & PAGE_CGROUP_FLAG_INUSE) {
 		mem = pc->mem_cgroup;
 		css_get(&mem->css);
 		if (pc->flags & PAGE_CGROUP_FLAG_CACHE)
 			ctype = MEM_CGROUP_CHARGE_TYPE_CACHE;
 	}
-	unlock_page_cgroup(page);
+	unlock_page_cgroup(pc);
 	if (mem) {
 		ret = mem_cgroup_charge_common(newpage, NULL, GFP_KERNEL,
 			ctype, mem);
@@ -1106,7 +1157,6 @@ mem_cgroup_create(struct cgroup_subsys *
 
 	if (unlikely((cont->parent) == NULL)) {
 		mem = &init_mem_cgroup;
-		page_cgroup_cache = KMEM_CACHE(page_cgroup, SLAB_PANIC);
 	} else {
 		mem = mem_cgroup_alloc();
 		if (!mem)
diff -puN include/linux/memcontrol.h~memcg_move_to_radix_tree include/linux/memcontrol.h
--- linux-2.6.27-rc5/include/linux/memcontrol.h~memcg_move_to_radix_tree	2008-09-04 03:15:54.000000000 -0700
+++ linux-2.6.27-rc5-balbir/include/linux/memcontrol.h	2008-09-09 13:02:29.000000000 -0700
@@ -27,9 +27,29 @@ struct mm_struct;
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
 
-#define page_reset_bad_cgroup(page)	((page)->page_cgroup = 0)
+extern void page_cgroup_init(int nid, unsigned long pfn);
+extern int page_cgroup_alloc(int n);
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
@@ -73,7 +93,13 @@ extern long mem_cgroup_calc_reclaim(stru
 					int priority, enum lru_list lru);
 
 #else /* CONFIG_CGROUP_MEM_RES_CTLR */
-static inline void page_reset_bad_cgroup(struct page *page)
+
+static inline int page_cgroup_alloc(int n)
+{
+	return 0;
+}
+
+static inline void page_cgroup_init(int nid, unsigned long pfn)
 {
 }
 
diff -puN include/linux/mm_types.h~memcg_move_to_radix_tree include/linux/mm_types.h
--- linux-2.6.27-rc5/include/linux/mm_types.h~memcg_move_to_radix_tree	2008-09-04 03:15:54.000000000 -0700
+++ linux-2.6.27-rc5-balbir/include/linux/mm_types.h	2008-09-04 03:15:54.000000000 -0700
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
--- linux-2.6.27-rc5/mm/page_alloc.c~memcg_move_to_radix_tree	2008-09-04 03:15:54.000000000 -0700
+++ linux-2.6.27-rc5-balbir/mm/page_alloc.c	2008-09-09 13:02:50.000000000 -0700
@@ -223,17 +223,11 @@ static inline int bad_range(struct zone 
 
 static void bad_page(struct page *page)
 {
-	void *pc = page_get_page_cgroup(page);
-
 	printk(KERN_EMERG "Bad page state in process '%s'\n" KERN_EMERG
 		"page:%p flags:0x%0*lx mapping:%p mapcount:%d count:%d\n",
 		current->comm, page, (int)(2*sizeof(unsigned long)),
 		(unsigned long)page->flags, page->mapping,
 		page_mapcount(page), page_count(page));
-	if (pc) {
-		printk(KERN_EMERG "cgroup:%p\n", pc);
-		page_reset_bad_cgroup(page);
-	}
 	printk(KERN_EMERG "Trying to fix it up, but a reboot is needed\n"
 		KERN_EMERG "Backtrace:\n");
 	dump_stack();
@@ -472,7 +466,6 @@ static inline void free_pages_check(stru
 	free_page_mlock(page);
 	if (unlikely(page_mapcount(page) |
 		(page->mapping != NULL)  |
-		(page_get_page_cgroup(page) != NULL) |
 		(page_count(page) != 0)  |
 		(page->flags & PAGE_FLAGS_CHECK_AT_FREE)))
 		bad_page(page);
@@ -609,7 +602,6 @@ static void prep_new_page(struct page *p
 {
 	if (unlikely(page_mapcount(page) |
 		(page->mapping != NULL)  |
-		(page_get_page_cgroup(page) != NULL) |
 		(page_count(page) != 0)  |
 		(page->flags & PAGE_FLAGS_CHECK_AT_PREP)))
 		bad_page(page);
@@ -2652,6 +2644,7 @@ void __meminit memmap_init_zone(unsigned
 	unsigned long pfn;
 	struct zone *z;
 
+	page_cgroup_alloc(nid);
 	z = &NODE_DATA(nid)->node_zones[zone];
 	for (pfn = start_pfn; pfn < end_pfn; pfn++) {
 		/*
@@ -2670,6 +2663,7 @@ void __meminit memmap_init_zone(unsigned
 		mminit_verify_page_links(page, zone, nid, pfn);
 		init_page_count(page);
 		reset_page_mapcount(page);
+		page_cgroup_init(nid, pfn);
 		SetPageReserved(page);
 		/*
 		 * Mark the block movable so that blocks are reserved for
_

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
