Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id C6FFE6B018B
	for <linux-mm@kvack.org>; Fri, 14 Oct 2011 20:39:09 -0400 (EDT)
From: Suleiman Souhlal <ssouhlal@FreeBSD.org>
Subject: [RFC] [PATCH 3/4] memcg: Slab accounting.
Date: Fri, 14 Oct 2011 17:38:29 -0700
Message-Id: <1318639110-27714-4-git-send-email-ssouhlal@FreeBSD.org>
In-Reply-To: <1318639110-27714-3-git-send-email-ssouhlal@FreeBSD.org>
References: <1318639110-27714-1-git-send-email-ssouhlal@FreeBSD.org>
 <1318639110-27714-2-git-send-email-ssouhlal@FreeBSD.org>
 <1318639110-27714-3-git-send-email-ssouhlal@FreeBSD.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: glommer@parallels.com
Cc: gthelen@google.com, yinghan@google.com, kamezawa.hiroyu@jp.fujitsu.com, jbottomley@parallels.com, suleiman@google.com, linux-mm@kvack.org, Suleiman Souhlal <ssouhlal@FreeBSD.org>

Introduce per-cgroup kmem_caches for memcg slab accounting, that.
get created the first time we do an allocation of that type in the
cgroup.
If we are not permitted to sleep in that allocation, the cache
gets created asynchronously.
The cgroup cache gets used in subsequent allocations, and permits
accounting of slab on a per-page basis.

Allocations that cannot be attributed to a cgroup get charged to
the root cgroup.

Signed-off-by: Suleiman Souhlal <suleiman@google.com>
---
 include/linux/memcontrol.h |   35 ++++++
 include/linux/slab.h       |    1 +
 include/linux/slab_def.h   |   47 +++++++-
 mm/memcontrol.c            |  263 ++++++++++++++++++++++++++++++++++++++++
 mm/slab.c                  |  284 ++++++++++++++++++++++++++++++++++++++++----
 5 files changed, 603 insertions(+), 27 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 343bd76..23c1960 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -158,6 +158,7 @@ void mem_cgroup_split_huge_fixup(struct page *head, struct page *tail);
 bool mem_cgroup_bad_page_check(struct page *page);
 void mem_cgroup_print_bad_page(struct page *page);
 #endif
+
 #else /* CONFIG_CGROUP_MEM_RES_CTLR */
 struct mem_cgroup;
 
@@ -361,6 +362,7 @@ static inline
 void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx)
 {
 }
+
 #endif /* CONFIG_CGROUP_MEM_CONT */
 
 #if !defined(CONFIG_CGROUP_MEM_RES_CTLR) || !defined(CONFIG_DEBUG_VM)
@@ -376,5 +378,38 @@ mem_cgroup_print_bad_page(struct page *page)
 }
 #endif
 
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KERNEL_MEMORY
+
+struct kmem_cache *mem_cgroup_select_kmem_cache(struct kmem_cache *cachep,
+    gfp_t gfp);
+bool mem_cgroup_charge_slab(struct kmem_cache *cachep, gfp_t gfp, size_t size);
+void mem_cgroup_uncharge_slab(struct kmem_cache *cachep, size_t size);
+void mem_cgroup_flush_cache_create_queue(void);
+
+#else /* CONFIG_CGROUP_MEM_RES_CTLR_KERNEL_MEMORY */
+
+static inline bool
+mem_cgroup_charge_slab(struct kmem_cache *cachep, gfp_t gfp, size_t size)
+{
+	return true;
+}
+
+static inline void
+mem_cgroup_uncharge_slab(struct kmem_cache *cachep, size_t size)
+{
+}
+
+static inline struct kmem_cache *
+mem_cgroup_select_kmem_cache(struct kmem_cache *cachep, gfp_t gfp)
+{
+	return cachep;
+}
+
+static inline void
+mem_cgroup_flush_cache_create_queue(void)
+{
+}
+#endif /* CONFIG_CGROUP_MEM_RES_CTLR_KERNEL_MEMORY */
+
 #endif /* _LINUX_MEMCONTROL_H */
 
diff --git a/include/linux/slab.h b/include/linux/slab.h
index 573c809..7a6cf1a 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -21,6 +21,7 @@
 #define SLAB_POISON		0x00000800UL	/* DEBUG: Poison objects */
 #define SLAB_HWCACHE_ALIGN	0x00002000UL	/* Align objs on cache lines */
 #define SLAB_CACHE_DMA		0x00004000UL	/* Use GFP_DMA memory */
+#define	SLAB_MEMCG		0x00008000UL	/* memcg kmem_cache */
 #define SLAB_STORE_USER		0x00010000UL	/* DEBUG: Store the last owner for bug hunting */
 #define SLAB_PANIC		0x00040000UL	/* Panic if kmem_cache_create() fails */
 /*
diff --git a/include/linux/slab_def.h b/include/linux/slab_def.h
index d00e0ba..8a800b1 100644
--- a/include/linux/slab_def.h
+++ b/include/linux/slab_def.h
@@ -43,6 +43,10 @@ struct kmem_cache {
 	/* force GFP flags, e.g. GFP_DMA */
 	gfp_t gfpflags;
 
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KERNEL_MEMORY
+	int id;				/* id used for slab accounting */
+#endif
+
 	size_t colour;			/* cache colouring range */
 	unsigned int colour_off;	/* colour offset */
 	struct kmem_cache *slabp_cache;
@@ -53,7 +57,7 @@ struct kmem_cache {
 	void (*ctor)(void *obj);
 
 /* 4) cache creation/removal */
-	const char *name;
+	char *name;
 	struct list_head next;
 
 /* 5) statistics */
@@ -80,9 +84,24 @@ struct kmem_cache {
 	 * variables contain the offset to the user object and its size.
 	 */
 	int obj_offset;
-	int obj_size;
 #endif /* CONFIG_DEBUG_SLAB */
 
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KERNEL_MEMORY
+	/* Original cache parameters, used when creating a memcg cache */
+	int obj_size;
+	size_t orig_align;
+	unsigned long orig_flags;
+
+	struct mem_cgroup *memcg;
+
+	/* Who we copied from when creating cpuset cache */
+	struct kmem_cache *orig_cache;
+
+	atomic_t refcnt;
+	struct list_head destroyed_list; /* Used when deleting cpuset cache */
+	struct list_head sibling_list;
+#endif /* CONFIG_CGROUP_MEM_RES_CTLR_KERNEL_MEMORY */
+
 /* 6) per-cpu/per-node data, touched during every alloc/free */
 	/*
 	 * We put array[] at the end of kmem_cache, because we want to size
@@ -214,4 +233,28 @@ found:
 
 #endif	/* CONFIG_NUMA */
 
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KERNEL_MEMORY
+
+#define MAX_KMEM_CACHE_TYPES 300
+
+struct kmem_cache *kmem_cache_create_memcg(struct kmem_cache *cachep,
+    char *name);
+void kmem_cache_destroy_cpuset(struct kmem_cache *cachep);
+void kmem_cache_get_ref(struct kmem_cache *cachep);
+void kmem_cache_drop_ref(struct kmem_cache *cachep);
+
+#else /* CONFIG_CGROUP_MEM_RES_CTLR_KERNEL_MEMORY */
+
+static inline void
+kmem_cache_get_ref(struct kmem_cache *cachep)
+{
+}
+
+static inline void
+kmem_cache_drop_ref(struct kmem_cache *cachep)
+{
+}
+
+#endif /* CONFIG_CGROUP_MEM_RES_CTLR_KERNEL_MEMORY */
+
 #endif	/* _LINUX_SLAB_DEF_H */
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 52b18ed..d45832c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -291,6 +291,10 @@ struct mem_cgroup {
 	spinlock_t pcp_counter_lock;
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_KERNEL_MEMORY
+#ifdef CONFIG_SLAB
+	/* Slab accounting */
+	struct kmem_cache *slabs[MAX_KMEM_CACHE_TYPES];
+#endif
 	atomic64_t kmem_bypassed;
 	atomic64_t kmem_bytes;
 #endif
@@ -5575,9 +5579,248 @@ memcg_unaccount_kmem(struct mem_cgroup *memcg, long long delta)
 		res_counter_uncharge(&memcg->res, delta);
 }
 
+#ifdef CONFIG_SLAB
+static struct kmem_cache *
+memcg_create_kmem_cache(struct mem_cgroup *memcg, int idx,
+    struct kmem_cache *cachep, gfp_t gfp)
+{
+	struct kmem_cache *new_cachep;
+	struct dentry *dentry;
+	char *name;
+	int len;
+
+	if ((gfp & GFP_KERNEL) != GFP_KERNEL)
+		return cachep;
+
+	dentry = memcg->css.cgroup->dentry;
+	BUG_ON(dentry == NULL);
+	len = strlen(cachep->name);
+	len += dentry->d_name.len;
+	len += 7; /* Space for "()", NUL and appending "dead" */
+	name = kmalloc(len, GFP_KERNEL | __GFP_NOACCOUNT);
+
+	if (name == NULL)
+		return cachep;
+
+	snprintf(name, len, "%s(%s)", cachep->name,
+	    dentry ? (const char *)dentry->d_name.name : "/");
+	name[len - 5] = '\0'; /* Make sure we can append "dead" later */
+
+	new_cachep = kmem_cache_create_memcg(cachep, name);
+
+	/*
+	 * Another CPU is creating the same cache?
+	 * We'll use it next time.
+	 */
+	if (new_cachep == NULL) {
+		kfree(name);
+		return cachep;
+	}
+
+	new_cachep->memcg = memcg;
+
+	/*
+	 * Make sure someone else hasn't created the new cache in the
+	 * meantime.
+	 * This should behave as a write barrier, so we should be fine
+	 * with RCU.
+	 */
+	if (cmpxchg(&memcg->slabs[idx], NULL, new_cachep) != NULL) {
+		kmem_cache_destroy(new_cachep);
+		return cachep;
+	}
+
+	return new_cachep;
+}
+
+struct create_work {
+	struct mem_cgroup *memcg;
+	struct kmem_cache *cachep;
+	struct list_head list;
+};
+
+static DEFINE_SPINLOCK(create_queue_lock);
+static LIST_HEAD(create_queue);
+
+void
+mem_cgroup_flush_cache_create_queue(void)
+{
+	struct create_work *cw, *tmp;
+	unsigned long flags;
+
+	spin_lock_irqsave(&create_queue_lock, flags);
+	list_for_each_entry_safe(cw, tmp, &create_queue, list) {
+		list_del(&cw->list);
+		kfree(cw);
+	}
+	spin_unlock_irqrestore(&create_queue_lock, flags);
+}
+
+static void
+memcg_create_cache_work_func(struct work_struct *w)
+{
+	struct kmem_cache *cachep;
+	struct create_work *cw;
+
+	spin_lock_irq(&create_queue_lock);
+	while (!list_empty(&create_queue)) {
+		cw = list_first_entry(&create_queue, struct create_work, list);
+		list_del(&cw->list);
+		spin_unlock_irq(&create_queue_lock);
+		cachep = memcg_create_kmem_cache(cw->memcg, cw->cachep->id,
+		    cw->cachep, GFP_KERNEL);
+		if (cachep == NULL && printk_ratelimit())
+			printk(KERN_ALERT "%s: Couldn't create cpuset-cache for"
+			    " %s cpuset %s\n", __func__, cw->cachep->name,
+			    cw->memcg->css.cgroup->dentry->d_name.name);
+		kfree(cw);
+		spin_lock_irq(&create_queue_lock);
+	}
+	spin_unlock_irq(&create_queue_lock);
+}
+
+static DECLARE_WORK(memcg_create_cache_work, memcg_create_cache_work_func);
+
+static void
+memcg_create_cache_enqueue(struct mem_cgroup *memcg, struct kmem_cache *cachep)
+{
+	struct create_work *cw;
+	unsigned long flags;
+
+	spin_lock_irqsave(&create_queue_lock, flags);
+	list_for_each_entry(cw, &create_queue, list) {
+		if (cw->memcg == memcg && cw->cachep == cachep) {
+			spin_unlock_irqrestore(&create_queue_lock, flags);
+			return;
+		}
+	}
+	spin_unlock_irqrestore(&create_queue_lock, flags);
+
+	cw = kmalloc(sizeof(struct create_work), GFP_NOWAIT | __GFP_NOACCOUNT);
+	if (cw == NULL)
+		return;
+
+	cw->memcg = memcg;
+	cw->cachep = cachep;
+	spin_lock_irqsave(&create_queue_lock, flags);
+	list_add_tail(&cw->list, &create_queue);
+	spin_unlock_irqrestore(&create_queue_lock, flags);
+
+	schedule_work(&memcg_create_cache_work);
+}
+
+struct kmem_cache *
+mem_cgroup_select_kmem_cache(struct kmem_cache *cachep, gfp_t gfp)
+{
+	struct kmem_cache *ret;
+	struct mem_cgroup *memcg;
+	int idx;
+
+	if (in_interrupt())
+		return cachep;
+	if (current == NULL)
+		return cachep;
+
+	gfp |= cachep->gfpflags;
+	if ((gfp & __GFP_NOACCOUNT) || (gfp & __GFP_NOFAIL))
+		return cachep;
+
+	if (cachep->flags & SLAB_MEMCG)
+		return cachep;
+
+	memcg = mem_cgroup_from_task(current);
+	idx = cachep->id;
+
+	if (memcg == NULL || memcg == root_mem_cgroup)
+		return cachep;
+
+	BUG_ON(idx == -1);
+
+	if (rcu_access_pointer(memcg->slabs[idx]) == NULL) {
+		if ((gfp & GFP_KERNEL) == GFP_KERNEL) {
+			if (!css_tryget(&memcg->css))
+				return cachep;
+			rcu_read_unlock();
+			ret = memcg_create_kmem_cache(memcg, idx, cachep, gfp);
+			rcu_read_lock();
+			css_put(&memcg->css);
+			return ret;
+		} else {
+			memcg_create_cache_enqueue(memcg, cachep);
+			return cachep;
+		}
+	}
+
+	return rcu_dereference(memcg->slabs[idx]);
+}
+
+bool
+mem_cgroup_charge_slab(struct kmem_cache *cachep, gfp_t gfp, size_t size)
+{
+	struct mem_cgroup *memcg, *_memcg;
+	int may_oom;
+
+	may_oom = (gfp & __GFP_WAIT) && (gfp & __GFP_FS) &&
+	    !(gfp & __GFP_NORETRY);
+
+	rcu_read_lock();
+	if (cachep->flags & SLAB_MEMCG)
+		memcg = cachep->memcg;
+	else
+		memcg = NULL;
+
+	if (memcg && !css_tryget(&memcg->css))
+		memcg = NULL;
+	rcu_read_unlock();
+
+	/*
+	 * __mem_cgroup_try_charge may decide to bypass the charge and set
+	 * _memcg to NULL, in which case we need to account to the root.
+	 */
+	_memcg = memcg;
+	if (memcg && __mem_cgroup_try_charge(NULL, gfp, size / PAGE_SIZE,
+	    &_memcg, may_oom) != 0) {
+		css_put(&memcg->css);
+		return false;
+	}
+	memcg_account_kmem(memcg, size, !_memcg);
+	if (memcg)
+		css_put(&memcg->css);
+
+	return true;
+}
+
+void
+mem_cgroup_uncharge_slab(struct kmem_cache *cachep, size_t size)
+{
+	struct mem_cgroup *memcg;
+
+	rcu_read_lock();
+	if (cachep->flags & SLAB_MEMCG)
+		memcg = cachep->memcg;
+	else
+		memcg = NULL;
+
+	if (memcg && !css_tryget(&memcg->css))
+		memcg = NULL;
+	rcu_read_unlock();
+
+	memcg_unaccount_kmem(memcg, size);
+	if (memcg)
+		css_put(&memcg->css);
+}
+#endif /* CONFIG_SLAB */
+
 static void
 memcg_kmem_init(struct mem_cgroup *memcg)
 {
+#ifdef CONFIG_SLAB
+	int i;
+
+	for (i = 0; i < MAX_KMEM_CACHE_TYPES; i++)
+		rcu_assign_pointer(memcg->slabs[i], NULL);
+#endif
+
 	if (memcg == root_mem_cgroup) {
 		long kmem_bytes;
 
@@ -5593,6 +5836,26 @@ memcg_kmem_move(struct mem_cgroup *memcg)
 {
 	long kmem_bytes;
 
+#ifdef CONFIG_SLAB
+	struct kmem_cache *cachep;
+	int i;
+
+	mem_cgroup_flush_cache_create_queue();
+
+	for (i = 0; i < MAX_KMEM_CACHE_TYPES; i++) {
+		cachep = memcg->slabs[i];
+		if (cachep != NULL) {
+			rcu_assign_pointer(memcg->slabs[i], NULL);
+			cachep->memcg = root_mem_cgroup;
+
+			/* The space for this is already allocated */
+			strcat((char *)cachep->name, "dead");
+
+			kmem_cache_drop_ref(cachep);
+		}
+	}
+#endif
+
 	atomic64_set(&memcg->kmem_bypassed, 0);
 	kmem_bytes = atomic64_xchg(&memcg->kmem_bytes, 0);
 	res_counter_uncharge(&memcg->res, kmem_bytes);
diff --git a/mm/slab.c b/mm/slab.c
index 6d90a09..e263b25 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -299,6 +299,8 @@ static void free_block(struct kmem_cache *cachep, void **objpp, int len,
 			int node);
 static int enable_cpucache(struct kmem_cache *cachep, gfp_t gfp);
 static void cache_reap(struct work_struct *unused);
+static int do_tune_cpucache(struct kmem_cache *cachep, int limit,
+    int batchcount, int shared, gfp_t gfp);
 
 /*
  * This function must be completely optimized away if a constant is passed to
@@ -324,6 +326,10 @@ static __always_inline int index_of(const size_t size)
 	return 0;
 }
 
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KERNEL_MEMORY
+static DECLARE_BITMAP(cache_types, MAX_KMEM_CACHE_TYPES);
+#endif
+
 static int slab_early_init = 1;
 
 #define INDEX_AC index_of(sizeof(struct arraycache_init))
@@ -1737,17 +1743,23 @@ static void *kmem_getpages(struct kmem_cache *cachep, gfp_t flags, int nodeid)
 	if (cachep->flags & SLAB_RECLAIM_ACCOUNT)
 		flags |= __GFP_RECLAIMABLE;
 
+	nr_pages = (1 << cachep->gfporder);
 	page = alloc_pages_exact_node(nodeid, flags | __GFP_NOTRACK, cachep->gfporder);
-	if (!page)
+	if (!page) {
+		mem_cgroup_uncharge_slab(cachep, nr_pages * PAGE_SIZE);
+		return NULL;
+	}
+
+	if (!mem_cgroup_charge_slab(cachep, flags, nr_pages * PAGE_SIZE))
 		return NULL;
 
-	nr_pages = (1 << cachep->gfporder);
 	if (cachep->flags & SLAB_RECLAIM_ACCOUNT)
 		add_zone_page_state(page_zone(page),
 			NR_SLAB_RECLAIMABLE, nr_pages);
 	else
 		add_zone_page_state(page_zone(page),
 			NR_SLAB_UNRECLAIMABLE, nr_pages);
+	kmem_cache_get_ref(cachep);
 	for (i = 0; i < nr_pages; i++)
 		__SetPageSlab(page + i);
 
@@ -1780,6 +1792,8 @@ static void kmem_freepages(struct kmem_cache *cachep, void *addr)
 	else
 		sub_zone_page_state(page_zone(page),
 				NR_SLAB_UNRECLAIMABLE, nr_freed);
+	mem_cgroup_uncharge_slab(cachep, i * PAGE_SIZE);
+	kmem_cache_drop_ref(cachep);
 	while (i--) {
 		BUG_ON(!PageSlab(page));
 		__ClearPageSlab(page);
@@ -2206,13 +2220,16 @@ static int __init_refok setup_cpu_cache(struct kmem_cache *cachep, gfp_t gfp)
  * as davem.
  */
 struct kmem_cache *
-kmem_cache_create (const char *name, size_t size, size_t align,
-	unsigned long flags, void (*ctor)(void *))
+__kmem_cache_create (const char *name, size_t size, size_t align,
+	unsigned long flags, void (*ctor)(void *), bool memcg)
 {
-	size_t left_over, slab_size, ralign;
+	size_t left_over, orig_align, ralign, slab_size;
 	struct kmem_cache *cachep = NULL, *pc;
+	unsigned long orig_flags;
 	gfp_t gfp;
 
+	orig_align = align;
+	orig_flags = flags;
 	/*
 	 * Sanity checks... these are all serious usage bugs.
 	 */
@@ -2229,7 +2246,6 @@ kmem_cache_create (const char *name, size_t size, size_t align,
 	 */
 	if (slab_is_available()) {
 		get_online_cpus();
-		mutex_lock(&cache_chain_mutex);
 	}
 
 	list_for_each_entry(pc, &cache_chain, next) {
@@ -2250,10 +2266,12 @@ kmem_cache_create (const char *name, size_t size, size_t align,
 		}
 
 		if (!strcmp(pc->name, name)) {
-			printk(KERN_ERR
-			       "kmem_cache_create: duplicate cache %s\n", name);
-			dump_stack();
-			goto oops;
+			if (!memcg) {
+				printk(KERN_ERR "kmem_cache_create: duplicate"
+				    " cache %s\n", name);
+				dump_stack();
+				goto oops;
+			}
 		}
 	}
 
@@ -2340,9 +2358,9 @@ kmem_cache_create (const char *name, size_t size, size_t align,
 	align = ralign;
 
 	if (slab_is_available())
-		gfp = GFP_KERNEL;
+		gfp = GFP_KERNEL | __GFP_NOACCOUNT;
 	else
-		gfp = GFP_NOWAIT;
+		gfp = GFP_NOWAIT | __GFP_NOACCOUNT;
 
 	/* Get cache's description obj. */
 	cachep = kmem_cache_zalloc(&cache_cache, gfp);
@@ -2350,9 +2368,15 @@ kmem_cache_create (const char *name, size_t size, size_t align,
 		goto oops;
 
 	cachep->nodelists = (struct kmem_list3 **)&cachep->array[nr_cpu_ids];
-#if DEBUG
+
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KERNEL_MEMORY
 	cachep->obj_size = size;
+	cachep->orig_align = orig_align;
+	cachep->orig_flags = orig_flags;
+#endif
 
+#if DEBUG
+	cachep->obj_size = size;
 	/*
 	 * Both debugging options require word-alignment which is calculated
 	 * into align above.
@@ -2458,7 +2482,24 @@ kmem_cache_create (const char *name, size_t size, size_t align,
 		BUG_ON(ZERO_OR_NULL_PTR(cachep->slabp_cache));
 	}
 	cachep->ctor = ctor;
-	cachep->name = name;
+	cachep->name = (char *)name;
+
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KERNEL_MEMORY
+	cachep->orig_cache = NULL;
+	atomic_set(&cachep->refcnt, 1);
+	INIT_LIST_HEAD(&cachep->destroyed_list);
+	INIT_LIST_HEAD(&cachep->sibling_list);
+
+	if (!memcg) {
+		int id;
+
+		id = find_first_zero_bit(cache_types, MAX_KMEM_CACHE_TYPES);
+		BUG_ON(id < 0 || id >= MAX_KMEM_CACHE_TYPES);
+		__set_bit(id, cache_types);
+		cachep->id = id;
+	} else
+		cachep->id = -1;
+#endif
 
 	if (setup_cpu_cache(cachep, gfp)) {
 		__kmem_cache_destroy(cachep);
@@ -2483,13 +2524,55 @@ oops:
 		panic("kmem_cache_create(): failed to create slab `%s'\n",
 		      name);
 	if (slab_is_available()) {
-		mutex_unlock(&cache_chain_mutex);
 		put_online_cpus();
 	}
 	return cachep;
 }
+
+struct kmem_cache *
+kmem_cache_create(const char *name, size_t size, size_t align,
+    unsigned long flags, void (*ctor)(void *))
+{
+	struct kmem_cache *cachep;
+
+	mutex_lock(&cache_chain_mutex);
+	cachep = __kmem_cache_create(name, size, align, flags, ctor, false);
+	mutex_unlock(&cache_chain_mutex);
+
+	return cachep;
+}
 EXPORT_SYMBOL(kmem_cache_create);
 
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KERNEL_MEMORY
+struct kmem_cache *
+kmem_cache_create_memcg(struct kmem_cache *cachep, char *name)
+{
+	struct kmem_cache *new;
+	int flags;
+
+	flags = cachep->orig_flags & ~SLAB_PANIC;
+	mutex_lock(&cache_chain_mutex);
+	new = __kmem_cache_create(name, cachep->obj_size, cachep->orig_align,
+	    flags, cachep->ctor, 1);
+	if (new == NULL) {
+		mutex_unlock(&cache_chain_mutex);
+		return NULL;
+	}
+	new->flags |= SLAB_MEMCG;
+	new->orig_cache = cachep;
+
+	list_add(&new->sibling_list, &cachep->sibling_list);
+	if ((cachep->limit != new->limit) ||
+	    (cachep->batchcount != new->batchcount) ||
+	    (cachep->shared != new->shared))
+		do_tune_cpucache(new, cachep->limit, cachep->batchcount,
+		    cachep->shared, GFP_KERNEL | __GFP_NOACCOUNT);
+	mutex_unlock(&cache_chain_mutex);
+
+	return new;
+}
+#endif /* CONFIG_CGROUP_MEM_RES_CTLR_KERNEL_MEMORY */
+
 #if DEBUG
 static void check_irq_off(void)
 {
@@ -2673,6 +2756,9 @@ void kmem_cache_destroy(struct kmem_cache *cachep)
 	 * the chain is never empty, cache_cache is never destroyed
 	 */
 	list_del(&cachep->next);
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KERNEL_MEMORY
+	list_del(&cachep->sibling_list);
+#endif
 	if (__cache_shrink(cachep)) {
 		slab_error(cachep, "Can't free all objects");
 		list_add(&cachep->next, &cache_chain);
@@ -2684,12 +2770,77 @@ void kmem_cache_destroy(struct kmem_cache *cachep)
 	if (unlikely(cachep->flags & SLAB_DESTROY_BY_RCU))
 		rcu_barrier();
 
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KERNEL_MEMORY
+	/* Not a memcg cache */
+	if (cachep->id != -1) {
+		__clear_bit(cachep->id, cache_types);
+		mem_cgroup_flush_cache_create_queue();
+	}
+#endif
 	__kmem_cache_destroy(cachep);
 	mutex_unlock(&cache_chain_mutex);
 	put_online_cpus();
 }
 EXPORT_SYMBOL(kmem_cache_destroy);
 
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KERNEL_MEMORY
+static DEFINE_SPINLOCK(destroy_lock);
+static LIST_HEAD(destroyed_caches);
+
+static void
+kmem_cache_destroy_work_func(struct work_struct *w)
+{
+	struct kmem_cache *cachep;
+	char *name;
+
+	spin_lock_irq(&destroy_lock);
+	while (!list_empty(&destroyed_caches)) {
+		cachep = list_first_entry(&destroyed_caches, struct kmem_cache,
+		    destroyed_list);
+		name = (char *)cachep->name;
+		list_del(&cachep->destroyed_list);
+		spin_unlock_irq(&destroy_lock);
+		synchronize_rcu();
+		kmem_cache_destroy(cachep);
+		kfree(name);
+		spin_lock_irq(&destroy_lock);
+	}
+	spin_unlock_irq(&destroy_lock);
+}
+
+static DECLARE_WORK(kmem_cache_destroy_work, kmem_cache_destroy_work_func);
+
+void
+kmem_cache_destroy_memcg(struct kmem_cache *cachep)
+{
+	unsigned long flags;
+
+	BUG_ON(!(cachep->flags & SLAB_MEMCG));
+
+	spin_lock_irqsave(&destroy_lock, flags);
+	list_add(&cachep->destroyed_list, &destroyed_caches);
+	spin_unlock_irqrestore(&destroy_lock, flags);
+
+	schedule_work(&kmem_cache_destroy_work);
+}
+
+void
+kmem_cache_get_ref(struct kmem_cache *cachep)
+{
+	if ((cachep->flags & SLAB_MEMCG) &&
+	    !atomic_add_unless(&cachep->refcnt, 1, 0))
+		BUG();
+}
+
+void
+kmem_cache_drop_ref(struct kmem_cache *cachep)
+{
+	if ((cachep->flags & SLAB_MEMCG) &&
+	    atomic_dec_and_test(&cachep->refcnt))
+		kmem_cache_destroy_memcg(cachep);
+}
+#endif /* CONFIG_CGROUP_MEM_RES_CTLR_KERNEL_MEMORY */
+
 /*
  * Get the memory for a slab management obj.
  * For a slab cache when the slab descriptor is off-slab, slab descriptors
@@ -2889,8 +3040,15 @@ static int cache_grow(struct kmem_cache *cachep,
 
 	offset *= cachep->colour_off;
 
-	if (local_flags & __GFP_WAIT)
+	if (local_flags & __GFP_WAIT) {
 		local_irq_enable();
+		/*
+		 * Get a reference to the cache, to make sure it doesn't get
+		 * freed while we have interrupts enabled.
+		 */
+		kmem_cache_get_ref(cachep);
+		rcu_read_unlock();
+	}
 
 	/*
 	 * The test for missing atomic flag is performed here, rather than
@@ -2901,6 +3059,13 @@ static int cache_grow(struct kmem_cache *cachep,
 	kmem_flagcheck(cachep, flags);
 
 	/*
+	 * alloc_slabmgmt() might invoke the slab allocator itself, so
+	 * make sure we don't recurse in slab accounting.
+	 */
+	if (flags & __GFP_NOACCOUNT)
+		local_flags |= __GFP_NOACCOUNT;
+
+	/*
 	 * Get mem for the objs.  Attempt to allocate a physical page from
 	 * 'nodeid'.
 	 */
@@ -2919,8 +3084,11 @@ static int cache_grow(struct kmem_cache *cachep,
 
 	cache_init_objs(cachep, slabp);
 
-	if (local_flags & __GFP_WAIT)
+	if (local_flags & __GFP_WAIT) {
 		local_irq_disable();
+		rcu_read_lock();
+		kmem_cache_drop_ref(cachep);
+	}
 	check_irq_off();
 	spin_lock(&l3->list_lock);
 
@@ -2933,8 +3101,11 @@ static int cache_grow(struct kmem_cache *cachep,
 opps1:
 	kmem_freepages(cachep, objp);
 failed:
-	if (local_flags & __GFP_WAIT)
+	if (local_flags & __GFP_WAIT) {
 		local_irq_disable();
+		rcu_read_lock();
+		kmem_cache_drop_ref(cachep);
+	}
 	return 0;
 }
 
@@ -3697,10 +3868,15 @@ static inline void __cache_free(struct kmem_cache *cachep, void *objp,
  */
 void *kmem_cache_alloc(struct kmem_cache *cachep, gfp_t flags)
 {
-	void *ret = __cache_alloc(cachep, flags, __builtin_return_address(0));
+	void *ret;
+
+	rcu_read_lock();
+	cachep = mem_cgroup_select_kmem_cache(cachep, flags);
+	ret = __cache_alloc(cachep, flags, __builtin_return_address(0));
 
 	trace_kmem_cache_alloc(_RET_IP_, ret,
 			       obj_size(cachep), cachep->buffer_size, flags);
+	rcu_read_unlock();
 
 	return ret;
 }
@@ -3712,10 +3888,13 @@ kmem_cache_alloc_trace(size_t size, struct kmem_cache *cachep, gfp_t flags)
 {
 	void *ret;
 
+	rcu_read_lock();
+	cachep = mem_cgroup_select_kmem_cache(cachep, flags);
 	ret = __cache_alloc(cachep, flags, __builtin_return_address(0));
 
 	trace_kmalloc(_RET_IP_, ret,
 		      size, slab_buffer_size(cachep), flags);
+	rcu_read_unlock();
 	return ret;
 }
 EXPORT_SYMBOL(kmem_cache_alloc_trace);
@@ -3724,12 +3903,17 @@ EXPORT_SYMBOL(kmem_cache_alloc_trace);
 #ifdef CONFIG_NUMA
 void *kmem_cache_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid)
 {
-	void *ret = __cache_alloc_node(cachep, flags, nodeid,
+	void *ret;
+
+	rcu_read_lock();
+	cachep = mem_cgroup_select_kmem_cache(cachep, flags);
+	ret  = __cache_alloc_node(cachep, flags, nodeid,
 				       __builtin_return_address(0));
 
 	trace_kmem_cache_alloc_node(_RET_IP_, ret,
 				    obj_size(cachep), cachep->buffer_size,
 				    flags, nodeid);
+	rcu_read_unlock();
 
 	return ret;
 }
@@ -3743,11 +3927,14 @@ void *kmem_cache_alloc_node_trace(size_t size,
 {
 	void *ret;
 
+	rcu_read_lock();
+	cachep = mem_cgroup_select_kmem_cache(cachep, flags);
 	ret = __cache_alloc_node(cachep, flags, nodeid,
 				  __builtin_return_address(0));
 	trace_kmalloc_node(_RET_IP_, ret,
 			   size, slab_buffer_size(cachep),
 			   flags, nodeid);
+	rcu_read_unlock();
 	return ret;
 }
 EXPORT_SYMBOL(kmem_cache_alloc_node_trace);
@@ -3757,11 +3944,17 @@ static __always_inline void *
 __do_kmalloc_node(size_t size, gfp_t flags, int node, void *caller)
 {
 	struct kmem_cache *cachep;
+	void *ret;
 
 	cachep = kmem_find_general_cachep(size, flags);
 	if (unlikely(ZERO_OR_NULL_PTR(cachep)))
 		return cachep;
-	return kmem_cache_alloc_node_trace(size, cachep, flags, node);
+	rcu_read_lock();
+	cachep = mem_cgroup_select_kmem_cache(cachep, flags);
+	ret = kmem_cache_alloc_node_trace(size, cachep, flags, node);
+	rcu_read_unlock();
+
+	return ret;
 }
 
 #if defined(CONFIG_DEBUG_SLAB) || defined(CONFIG_TRACING)
@@ -3807,10 +4000,13 @@ static __always_inline void *__do_kmalloc(size_t size, gfp_t flags,
 	cachep = __find_general_cachep(size, flags);
 	if (unlikely(ZERO_OR_NULL_PTR(cachep)))
 		return cachep;
+	rcu_read_lock();
+	cachep = mem_cgroup_select_kmem_cache(cachep, flags);
 	ret = __cache_alloc(cachep, flags, caller);
 
 	trace_kmalloc((unsigned long) caller, ret,
 		      size, cachep->buffer_size, flags);
+	rcu_read_unlock();
 
 	return ret;
 }
@@ -3851,9 +4047,27 @@ void kmem_cache_free(struct kmem_cache *cachep, void *objp)
 
 	local_irq_save(flags);
 	debug_check_no_locks_freed(objp, obj_size(cachep));
+
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KERNEL_MEMORY
+	struct kmem_cache *actual_cachep, *old_cachep;
+
+	actual_cachep = virt_to_cache(objp);
+	old_cachep = NULL;
+	if (actual_cachep != cachep) {
+		BUG_ON(!(actual_cachep->flags & SLAB_MEMCG));
+		BUG_ON(actual_cachep->orig_cache != cachep);
+		old_cachep = cachep;
+		cachep = actual_cachep;
+	}
+	kmem_cache_get_ref(cachep);
+#endif
+
 	if (!(cachep->flags & SLAB_DEBUG_OBJECTS))
 		debug_check_no_obj_freed(objp, obj_size(cachep));
 	__cache_free(cachep, objp, __builtin_return_address(0));
+
+	kmem_cache_drop_ref(cachep);
+
 	local_irq_restore(flags);
 
 	trace_kmem_cache_free(_RET_IP_, objp);
@@ -3881,9 +4095,13 @@ void kfree(const void *objp)
 	local_irq_save(flags);
 	kfree_debugcheck(objp);
 	c = virt_to_cache(objp);
+
+	kmem_cache_get_ref(c);
+
 	debug_check_no_locks_freed(objp, obj_size(c));
 	debug_check_no_obj_freed(objp, obj_size(c));
 	__cache_free(c, (void *)objp, __builtin_return_address(0));
+	kmem_cache_drop_ref(c);
 	local_irq_restore(flags);
 }
 EXPORT_SYMBOL(kfree);
@@ -4152,6 +4370,12 @@ static void cache_reap(struct work_struct *w)
 	list_for_each_entry(searchp, &cache_chain, next) {
 		check_irq_on();
 
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KERNEL_MEMORY
+		if ((searchp->flags & SLAB_MEMCG) &&
+		    !atomic_add_unless(&searchp->refcnt, 1, 0))
+			continue;
+#endif
+
 		/*
 		 * We only take the l3 lock if absolutely necessary and we
 		 * have established with reasonable certainty that
@@ -4184,6 +4408,7 @@ static void cache_reap(struct work_struct *w)
 			STATS_ADD_REAPED(searchp, freed);
 		}
 next:
+		kmem_cache_drop_ref(searchp);
 		cond_resched();
 	}
 	check_irq_on();
@@ -4395,11 +4620,20 @@ static ssize_t slabinfo_write(struct file *file, const char __user *buffer,
 			if (limit < 1 || batchcount < 1 ||
 					batchcount > limit || shared < 0) {
 				res = 0;
-			} else {
-				res = do_tune_cpucache(cachep, limit,
-						       batchcount, shared,
-						       GFP_KERNEL);
+				break;
 			}
+
+			res = do_tune_cpucache(cachep, limit, batchcount,
+			    shared, GFP_KERNEL | __GFP_NOACCOUNT);
+
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KERNEL_MEMORY
+			struct kmem_cache *c;
+
+			list_for_each_entry(c, &cachep->sibling_list,
+			    sibling_list)
+				do_tune_cpucache(c, limit, batchcount, shared,
+				    GFP_KERNEL | __GFP_NOACCOUNT);
+#endif
 			break;
 		}
 	}
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
