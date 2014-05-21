Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id 6C5E76B0036
	for <linux-mm@kvack.org>; Wed, 21 May 2014 09:58:43 -0400 (EDT)
Received: by mail-la0-f43.google.com with SMTP id mc6so1607137lab.2
        for <linux-mm@kvack.org>; Wed, 21 May 2014 06:58:42 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id 8si20320066lao.56.2014.05.21.06.58.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 May 2014 06:58:41 -0700 (PDT)
Date: Wed, 21 May 2014 17:58:28 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH RFC 3/3] slub: reparent memcg caches' slabs on memcg
 offline
Message-ID: <20140521135826.GA23193@esperanza>
References: <cover.1399982635.git.vdavydov@parallels.com>
 <6eafe1e95d9a934228e9af785f5b5de38955aa6a.1399982635.git.vdavydov@parallels.com>
 <alpine.DEB.2.10.1405141119320.16512@gentwo.org>
 <20140515071650.GB32113@esperanza>
 <alpine.DEB.2.10.1405151015330.24665@gentwo.org>
 <20140516132234.GF32113@esperanza>
 <alpine.DEB.2.10.1405160957100.32249@gentwo.org>
 <20140519152437.GB25889@esperanza>
 <alpine.DEB.2.10.1405191056580.22956@gentwo.org>
 <537A4D27.1050909@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <537A4D27.1050909@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: hannes@cmpxchg.org, mhocko@suse.cz, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, May 19, 2014 at 10:27:51PM +0400, Vladimir Davydov wrote:
[...]
> However, there is one thing regarding preemptable kernels. The problem
> is after forbidding the cache store free slabs in per-cpu/node partial
> lists by setting min_partial=0 and kmem_cache_has_cpu_partial=false
> (i.e. marking the cache as dead), we have to make sure that all frees
> that saw the cache as alive are over, otherwise they can occasionally
> add a free slab to a per-cpu/node partial list *after* the cache was
> marked dead.

Seems I've found a better way to avoid this race, which does not involve
messing up free hot paths. The idea is to explicitly zap each per-cpu
partial list by setting it pointing to an invalid ptr. Since
put_cpu_partial(), which is called from __slab_free(), uses atomic
cmpxchg for adding a new partial slab to a per cpu partial list, it is
enough to add a check if partials are zapped there and bail out if so.

The patch doing the trick is attached. Could you please take a look at
it once time permit?

Thank you.

--
diff --git a/include/linux/slab.h b/include/linux/slab.h
index 1d9abb7d22a0..c1e318247248 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -526,7 +526,8 @@ static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
  * @memcg: pointer to the memcg this cache belongs to
  * @list: list_head for the list of all caches in this memcg
  * @root_cache: pointer to the global, root cache, this cache was derived from
- * @nr_pages: number of pages that belongs to this cache.
+ * @count: the ref count; the cache is destroyed as soon as it reaches 0
+ * @unregister_work: the cache destruction work
  */
 struct memcg_cache_params {
 	bool is_root_cache;
@@ -539,11 +540,20 @@ struct memcg_cache_params {
 			struct mem_cgroup *memcg;
 			struct list_head list;
 			struct kmem_cache *root_cache;
-			atomic_t nr_pages;
+			atomic_t count;
+			struct work_struct unregister_work;
 		};
 	};
 };
 
+/*
+ * Each active slab increments the cache's memcg_params->count, and the owner
+ * memcg, while it's online, adds MEMCG_PARAMS_COUNT_BIAS to the count so that
+ * the cache is dead (i.e. belongs to a memcg that was turned offline) iff
+ * memcg_params->count < MEMCG_PARAMS_COUNT_BIAS.
+ */
+#define MEMCG_PARAMS_COUNT_BIAS		(1U << 31)
+
 int memcg_update_all_caches(int num_memcgs);
 
 struct seq_file;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 0fb108e5b905..6c922dd96fd5 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3090,6 +3090,8 @@ int memcg_update_cache_size(struct kmem_cache *s, int num_groups)
 	return 0;
 }
 
+static void memcg_unregister_cache_func(struct work_struct *w);
+
 int memcg_alloc_cache_params(struct mem_cgroup *memcg, struct kmem_cache *s,
 			     struct kmem_cache *root_cache)
 {
@@ -3111,6 +3113,9 @@ int memcg_alloc_cache_params(struct mem_cgroup *memcg, struct kmem_cache *s,
 	if (memcg) {
 		s->memcg_params->memcg = memcg;
 		s->memcg_params->root_cache = root_cache;
+		atomic_set(&s->memcg_params->count, MEMCG_PARAMS_COUNT_BIAS);
+		INIT_WORK(&s->memcg_params->unregister_work,
+			  memcg_unregister_cache_func);
 		css_get(&memcg->css);
 	} else
 		s->memcg_params->is_root_cache = true;
@@ -3192,6 +3197,17 @@ static void memcg_unregister_cache(struct kmem_cache *cachep)
 	kmem_cache_destroy(cachep);
 }
 
+static void memcg_unregister_cache_func(struct work_struct *w)
+{
+	struct memcg_cache_params *params =
+		container_of(w, struct memcg_cache_params, unregister_work);
+	struct kmem_cache *cachep = memcg_params_to_cache(params);
+
+	mutex_lock(&memcg_slab_mutex);
+	memcg_unregister_cache(cachep);
+	mutex_unlock(&memcg_slab_mutex);
+}
+
 /*
  * During the creation a new cache, we need to disable our accounting mechanism
  * altogether. This is true even if we are not creating, but rather just
@@ -3254,8 +3270,14 @@ static void memcg_unregister_all_caches(struct mem_cgroup *memcg)
 	mutex_lock(&memcg_slab_mutex);
 	list_for_each_entry_safe(params, tmp, &memcg->memcg_slab_caches, list) {
 		cachep = memcg_params_to_cache(params);
+
+		/* mark the cache as dead while still holding a ref to it */
+		atomic_sub(MEMCG_PARAMS_COUNT_BIAS - 1, &params->count);
+
 		kmem_cache_shrink(cachep);
-		if (atomic_read(&cachep->memcg_params->nr_pages) == 0)
+
+		/* if nobody except us uses the cache, destroy it immediately */
+		if (atomic_dec_and_test(&params->count))
 			memcg_unregister_cache(cachep);
 	}
 	mutex_unlock(&memcg_slab_mutex);
@@ -3329,14 +3351,15 @@ int __memcg_charge_slab(struct kmem_cache *cachep, gfp_t gfp, int order)
 	res = memcg_charge_kmem(cachep->memcg_params->memcg, gfp,
 				PAGE_SIZE << order);
 	if (!res)
-		atomic_add(1 << order, &cachep->memcg_params->nr_pages);
+		atomic_inc(&cachep->memcg_params->count);
 	return res;
 }
 
 void __memcg_uncharge_slab(struct kmem_cache *cachep, int order)
 {
 	memcg_uncharge_kmem(cachep->memcg_params->memcg, PAGE_SIZE << order);
-	atomic_sub(1 << order, &cachep->memcg_params->nr_pages);
+	if (atomic_dec_and_test(&cachep->memcg_params->count))
+		schedule_work(&cachep->memcg_params->unregister_work);
 }
 
 /*
diff --git a/mm/slab.h b/mm/slab.h
index 961a3fb1f5a2..996968c55222 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -179,6 +179,14 @@ static inline struct kmem_cache *memcg_root_cache(struct kmem_cache *s)
 	return s->memcg_params->root_cache;
 }
 
+/* Returns true if the cache belongs to a memcg that was turned offline. */
+static inline bool memcg_cache_dead(struct kmem_cache *s)
+{
+	return !is_root_cache(s) &&
+		atomic_read(&s->memcg_params->count) < MEMCG_PARAMS_COUNT_BIAS;
+}
+
+
 static __always_inline int memcg_charge_slab(struct kmem_cache *s,
 					     gfp_t gfp, int order)
 {
@@ -225,6 +233,11 @@ static inline struct kmem_cache *memcg_root_cache(struct kmem_cache *s)
 	return s;
 }
 
+static inline bool memcg_cache_dead(struct kmem_cache *s)
+{
+	return false;
+}
+
 static inline int memcg_charge_slab(struct kmem_cache *s, gfp_t gfp, int order)
 {
 	return 0;
diff --git a/mm/slub.c b/mm/slub.c
index fdf0fe4da9a9..21ffae4766e5 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -123,15 +123,6 @@ static inline int kmem_cache_debug(struct kmem_cache *s)
 #endif
 }
 
-static inline bool kmem_cache_has_cpu_partial(struct kmem_cache *s)
-{
-#ifdef CONFIG_SLUB_CPU_PARTIAL
-	return !kmem_cache_debug(s);
-#else
-	return false;
-#endif
-}
-
 /*
  * Issues still to be resolved:
  *
@@ -186,6 +177,24 @@ static inline bool kmem_cache_has_cpu_partial(struct kmem_cache *s)
 /* Internal SLUB flags */
 #define __OBJECT_POISON		0x80000000UL /* Poison object */
 #define __CMPXCHG_DOUBLE	0x40000000UL /* Use cmpxchg_double */
+#define __DISABLE_CPU_PARTIAL	0x20000000UL
+
+static inline bool kmem_cache_has_cpu_partial(struct kmem_cache *s)
+{
+#ifdef CONFIG_SLUB_CPU_PARTIAL
+	return !kmem_cache_debug(s) &&
+		!unlikely(s->flags & __DISABLE_CPU_PARTIAL);
+#else
+	return false;
+#endif
+}
+
+#define CPU_PARTIAL_ZAPPED			((struct page *)~0UL)
+
+static inline bool CPU_PARTIAL_VALID(struct page *page)
+{
+	return page && page != CPU_PARTIAL_ZAPPED;
+}
 
 #ifdef CONFIG_SMP
 static struct notifier_block slab_notifier;
@@ -1947,6 +1956,59 @@ redo:
 	}
 }
 
+#ifdef CONFIG_SLUB_CPU_PARTIAL
+/*
+ * Unfreeze partial slab. Called with n->list_lock held.
+ */
+static void __unfreeze_partial(struct kmem_cache *s, struct kmem_cache_node *n,
+			       struct page *page, struct page **discard_page)
+{
+	struct page new, old;
+
+	do {
+
+		old.freelist = page->freelist;
+		old.counters = page->counters;
+		VM_BUG_ON(!old.frozen);
+
+		new.counters = old.counters;
+		new.freelist = old.freelist;
+
+		new.frozen = 0;
+
+	} while (!__cmpxchg_double_slab(s, page,
+			old.freelist, old.counters,
+			new.freelist, new.counters,
+			"unfreezing slab"));
+
+	if (unlikely(!new.inuse && n->nr_partial > s->min_partial)) {
+		page->next = *discard_page;
+		*discard_page = page;
+	} else {
+		add_partial(n, page, DEACTIVATE_TO_TAIL);
+		stat(s, FREE_ADD_PARTIAL);
+	}
+}
+
+static void cancel_cpu_partial(struct kmem_cache *s, struct page *page)
+{
+	struct page *discard_page = NULL;
+	struct kmem_cache_node *n;
+	unsigned long flags;
+
+	n = get_node(s, page_to_nid(page));
+	spin_lock_irqsave(&n->list_lock, flags);
+	__unfreeze_partial(s, n, page, &discard_page);
+	spin_unlock_irqrestore(&n->list_lock, flags);
+
+	if (discard_page) {
+		stat(s, DEACTIVATE_EMPTY);
+		stat(s, FREE_SLAB);
+		discard_slab(s, page);
+	}
+}
+#endif
+
 /*
  * Unfreeze all the cpu partial slabs.
  *
@@ -1961,12 +2023,12 @@ static void unfreeze_partials(struct kmem_cache *s,
 	struct kmem_cache_node *n = NULL, *n2 = NULL;
 	struct page *page, *discard_page = NULL;
 
-	while ((page = c->partial)) {
-		struct page new;
-		struct page old;
-
+	while (CPU_PARTIAL_VALID(page = c->partial)) {
 		c->partial = page->next;
 
+		if (unlikely(s->flags & __DISABLE_CPU_PARTIAL) && !c->partial)
+			c->partial = CPU_PARTIAL_ZAPPED;
+
 		n2 = get_node(s, page_to_nid(page));
 		if (n != n2) {
 			if (n)
@@ -1976,29 +2038,7 @@ static void unfreeze_partials(struct kmem_cache *s,
 			spin_lock(&n->list_lock);
 		}
 
-		do {
-
-			old.freelist = page->freelist;
-			old.counters = page->counters;
-			VM_BUG_ON(!old.frozen);
-
-			new.counters = old.counters;
-			new.freelist = old.freelist;
-
-			new.frozen = 0;
-
-		} while (!__cmpxchg_double_slab(s, page,
-				old.freelist, old.counters,
-				new.freelist, new.counters,
-				"unfreezing slab"));
-
-		if (unlikely(!new.inuse && n->nr_partial > s->min_partial)) {
-			page->next = discard_page;
-			discard_page = page;
-		} else {
-			add_partial(n, page, DEACTIVATE_TO_TAIL);
-			stat(s, FREE_ADD_PARTIAL);
-		}
+		__unfreeze_partial(s, n, page, &discard_page);
 	}
 
 	if (n)
@@ -2036,6 +2076,11 @@ static void put_cpu_partial(struct kmem_cache *s, struct page *page, int drain)
 		pobjects = 0;
 		oldpage = this_cpu_read(s->cpu_slab->partial);
 
+		if (unlikely(oldpage == CPU_PARTIAL_ZAPPED)) {
+			cancel_cpu_partial(s, page);
+			return;
+		}
+
 		if (oldpage) {
 			pobjects = oldpage->pobjects;
 			pages = oldpage->pages;
@@ -2106,7 +2151,7 @@ static bool has_cpu_slab(int cpu, void *info)
 	struct kmem_cache *s = info;
 	struct kmem_cache_cpu *c = per_cpu_ptr(s->cpu_slab, cpu);
 
-	return c->page || c->partial;
+	return c->page || CPU_PARTIAL_VALID(c->partial);
 }
 
 static void flush_all(struct kmem_cache *s)
@@ -3411,6 +3456,11 @@ int __kmem_cache_shrink(struct kmem_cache *s)
 	if (!slabs_by_inuse)
 		return -ENOMEM;
 
+	if (memcg_cache_dead(s)) {
+		s->flags |= __DISABLE_CPU_PARTIAL;
+		s->min_partial = 0;
+	}
+
 	flush_all(s);
 	for_each_node_state(node, N_NORMAL_MEMORY) {
 		n = get_node(s, node);
@@ -4315,7 +4365,7 @@ static ssize_t show_slab_objects(struct kmem_cache *s,
 			nodes[node] += x;
 
 			page = ACCESS_ONCE(c->partial);
-			if (page) {
+			if (CPU_PARTIAL_VALID(page)) {
 				node = page_to_nid(page);
 				if (flags & SO_TOTAL)
 					WARN_ON_ONCE(1);
@@ -4471,7 +4521,8 @@ static ssize_t min_partial_store(struct kmem_cache *s, const char *buf,
 	if (err)
 		return err;
 
-	set_min_partial(s, min);
+	if (!memcg_cache_dead(s))
+		set_min_partial(s, min);
 	return length;
 }
 SLAB_ATTR(min_partial);
@@ -4547,7 +4598,7 @@ static ssize_t slabs_cpu_partial_show(struct kmem_cache *s, char *buf)
 	for_each_online_cpu(cpu) {
 		struct page *page = per_cpu_ptr(s->cpu_slab, cpu)->partial;
 
-		if (page) {
+		if (CPU_PARTIAL_VALID(page)) {
 			pages += page->pages;
 			objects += page->pobjects;
 		}
@@ -4559,7 +4610,7 @@ static ssize_t slabs_cpu_partial_show(struct kmem_cache *s, char *buf)
 	for_each_online_cpu(cpu) {
 		struct page *page = per_cpu_ptr(s->cpu_slab, cpu) ->partial;
 
-		if (page && len < PAGE_SIZE - 20)
+		if (CPU_PARTIAL_VALID(page) && len < PAGE_SIZE - 20)
 			len += sprintf(buf + len, " C%d=%d(%d)", cpu,
 				page->pobjects, page->pages);
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
