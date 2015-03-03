Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 6D1D26B0038
	for <linux-mm@kvack.org>; Tue,  3 Mar 2015 03:55:59 -0500 (EST)
Received: by paceu11 with SMTP id eu11so8327997pac.1
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 00:55:59 -0800 (PST)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id l9si203298pdp.89.2015.03.03.00.55.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Tue, 03 Mar 2015 00:55:58 -0800 (PST)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NKM00H66OZZDS50@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 03 Mar 2015 08:59:59 +0000 (GMT)
Message-id: <54F57716.80809@samsung.com>
Date: Tue, 03 Mar 2015 11:55:50 +0300
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: [RFC] slub memory quarantine
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Sasha Levin <sasha.levin@oracle.com>, Dmitry Vyukov <dvyukov@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Konstantin Khlebnikov <koct9i@gmail.com>, linux-kernel@vger.kernel.org

Hi.

One of the main problems in detecting use after free bugs is memory reuse.
Freed could be quickly reallocated.
Neither KASan nor slub poisoning could detect use after free after reallocation.
Memory quarantine is aimed to solve this problem by delaying as much as possible
actual freeing of object.

The patch below implements quarantine for SLUB. Currently it has couple known issues:
 - runtime quarantine on/off switcher doesn't work well.
 - for some reason shrinker doesn't work well.
    Allocations with order > 3 may not succeed and lead to OOM
    even though we have a lot of in quarantine memory which could be freed.

Before digging into those issues, I would like to hear you opinions about this patch.


------------------------------------------------------
From: Konstantin Khlebnikov <koct9i@gmail.com>

Quarantine isolates freed objects for some  period of time in place of
reusing  them instantly.  It  helps in  catching vague  use-after-free
bugs, especially when combined with kernel address sanitizer.

This patch adds quarantine for slub. Like other slub debug features it
might be enabled in command line: slub_debug=Q or in runtime via sysfs
for individual slabs. All freed  objects goes into quarantine and then
completely  quarantined slubs  might be  reclaimed by  memory shinker.
Thus quarantine consumes all available  memory and doesn't require any
tuning.

Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
---
 Documentation/vm/slub.txt |   1 +
 include/linux/mm_types.h  |   1 +
 include/linux/slab.h      |   2 +
 include/linux/slub_def.h  |   5 +-
 mm/slab.h                 |   8 +-
 mm/slab_common.c          |   2 +-
 mm/slub.c                 | 388 +++++++++++++++++++++++++++++++++++++++++++++-
 7 files changed, 396 insertions(+), 11 deletions(-)

diff --git a/Documentation/vm/slub.txt b/Documentation/vm/slub.txt
index b0c6d1b..08d90da 100644
--- a/Documentation/vm/slub.txt
+++ b/Documentation/vm/slub.txt
@@ -44,6 +44,7 @@ Possible debug options are
 	A		Toggle failslab filter mark for the cache
 	O		Switch debugging off for caches that would have
 			caused higher minimum slab orders
+	Q		put freed objects into Quarantine
 	-		Switch all debugging off (useful if the kernel is
 			configured with CONFIG_SLUB_DEBUG_ON)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 199a03a..5d89578 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -56,6 +56,7 @@ struct page {
 						 * see PAGE_MAPPING_ANON below.
 						 */
 		void *s_mem;			/* slab first object */
+		void *quarantine;		/* slub quarantine list */
 	};

 	/* Second double word */
diff --git a/include/linux/slab.h b/include/linux/slab.h
index 76f1fee..0e8e8f2 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -87,6 +87,8 @@
 # define SLAB_FAILSLAB		0x00000000UL
 #endif

+#define SLAB_QUARANTINE		0x04000000UL
+
 /* The following flags affect the page allocator grouping pages by mobility */
 #define SLAB_RECLAIM_ACCOUNT	0x00020000UL		/* Objects are reclaimable */
 #define SLAB_TEMPORARY		SLAB_RECLAIM_ACCOUNT	/* Objects are short-lived */
diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index 3388511..bb13fcd 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -35,6 +35,7 @@ enum stat_item {
 	CPU_PARTIAL_FREE,	/* Refill cpu partial on free */
 	CPU_PARTIAL_NODE,	/* Refill cpu partial from node partial */
 	CPU_PARTIAL_DRAIN,	/* Drain cpu partial to node partial */
+	QUARANTINE_BREACH,	/* Slab left quarantine via reclaimer */
 	NR_SLUB_STAT_ITEMS };

 struct kmem_cache_cpu {
@@ -91,7 +92,9 @@ struct kmem_cache {
 	struct kset *memcg_kset;
 #endif
 #endif
-
+#ifdef CONFIG_SLUB_DEBUG
+	struct kmem_cache_quarantine_shrinker *quarantine_shrinker;
+#endif
 #ifdef CONFIG_NUMA
 	/*
 	 * Defragmentation by allocating from a remote node.
diff --git a/mm/slab.h b/mm/slab.h
index 4c3ac12..f6d5c61 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -120,7 +120,7 @@ static inline unsigned long kmem_cache_flags(unsigned long object_size,
 #define SLAB_DEBUG_FLAGS (SLAB_RED_ZONE | SLAB_POISON | SLAB_STORE_USER)
 #elif defined(CONFIG_SLUB_DEBUG)
 #define SLAB_DEBUG_FLAGS (SLAB_RED_ZONE | SLAB_POISON | SLAB_STORE_USER | \
-			  SLAB_TRACE | SLAB_DEBUG_FREE)
+			  SLAB_TRACE | SLAB_DEBUG_FREE | SLAB_QUARANTINE)
 #else
 #define SLAB_DEBUG_FLAGS (0)
 #endif
@@ -352,6 +352,12 @@ struct kmem_cache_node {
 	atomic_long_t nr_slabs;
 	atomic_long_t total_objects;
 	struct list_head full;
+
+	struct {
+		unsigned long nr_objects;
+		unsigned long nr_slabs;
+		struct list_head slabs;
+	} quarantine;
 #endif
 #endif

diff --git a/mm/slab_common.c b/mm/slab_common.c
index 999bb34..05e317d 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -35,7 +35,7 @@ struct kmem_cache *kmem_cache;
  */
 #define SLAB_NEVER_MERGE (SLAB_RED_ZONE | SLAB_POISON | SLAB_STORE_USER | \
 		SLAB_TRACE | SLAB_DESTROY_BY_RCU | SLAB_NOLEAKTRACE | \
-		SLAB_FAILSLAB)
+		SLAB_FAILSLAB | SLAB_QUARANTINE)

 #define SLAB_MERGE_SAME (SLAB_DEBUG_FREE | SLAB_RECLAIM_ACCOUNT | \
 		SLAB_CACHE_DMA | SLAB_NOTRACK)
diff --git a/mm/slub.c b/mm/slub.c
index 6832c4e..27ab842 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -161,7 +161,7 @@ static inline bool kmem_cache_has_cpu_partial(struct kmem_cache *s)
 #define MAX_PARTIAL 10

 #define DEBUG_DEFAULT_FLAGS (SLAB_DEBUG_FREE | SLAB_RED_ZONE | \
-				SLAB_POISON | SLAB_STORE_USER)
+		SLAB_POISON | SLAB_STORE_USER | SLAB_QUARANTINE)

 /*
  * Debugging flags that require metadata to be stored in the slab.  These get
@@ -454,6 +454,8 @@ static void get_map(struct kmem_cache *s, struct page *page, unsigned long *map)

 	for (p = page->freelist; p; p = get_freepointer(s, p))
 		set_bit(slab_index(p, s, addr), map);
+	for (p = page->quarantine; p; p = get_freepointer(s, p))
+		set_bit(slab_index(p, s, addr), map);
 }

 /*
@@ -921,6 +923,30 @@ static int on_freelist(struct kmem_cache *s, struct page *page, void *search)
 		nr++;
 	}

+	fp = page->quarantine;
+	while (fp && nr <= page->objects) {
+		if (fp == search)
+			return 1;
+		if (!check_valid_pointer(s, page, fp)) {
+			if (object) {
+				object_err(s, page, object,
+					"Quarantine corrupt");
+				set_freepointer(s, object, NULL);
+			} else {
+				slab_err(s, page, "Quarantine corrupt");
+				page->quarantine = NULL;
+				slab_fix(s, "Quarantine cleared");
+				return 0;
+			}
+			break;
+		}
+		object = fp;
+		fp = get_freepointer(s, object);
+		/* In frozen slubs qurantine included into inuse */
+		if (!page->frozen)
+			nr++;
+	}
+
 	max_objects = order_objects(compound_order(page), s->size, s->reserved);
 	if (max_objects > MAX_OBJS_PER_PAGE)
 		max_objects = MAX_OBJS_PER_PAGE;
@@ -980,6 +1006,219 @@ static void remove_full(struct kmem_cache *s, struct kmem_cache_node *n, struct
 	list_del(&page->lru);
 }

+/*
+ * Quarantine management.
+ */
+static void add_quarantine(struct kmem_cache *s, struct kmem_cache_node *n,
+			   struct page *page)
+{
+	list_add_tail(&page->lru, &n->quarantine.slabs);
+	n->quarantine.nr_slabs++;
+
+	if (!(s->flags & SLAB_RECLAIM_ACCOUNT)) {
+		struct zone *zone = page_zone(page);
+		int size = 1 << compound_order(page);
+
+		mod_zone_page_state(zone, NR_SLAB_UNRECLAIMABLE, -size);
+		mod_zone_page_state(zone, NR_SLAB_RECLAIMABLE, size);
+	}
+}
+
+static void remove_quarantine(struct kmem_cache *s, struct kmem_cache_node *n,
+			      struct page *page)
+{
+	list_del(&page->lru);
+	n->quarantine.nr_slabs--;
+
+	if (!(s->flags & SLAB_RECLAIM_ACCOUNT)) {
+		struct zone *zone = page_zone(page);
+		int size = 1 << compound_order(page);
+
+		mod_zone_page_state(zone, NR_SLAB_RECLAIMABLE, -size);
+		mod_zone_page_state(zone, NR_SLAB_UNRECLAIMABLE, size);
+	}
+}
+
+static inline void dec_slabs_node(struct kmem_cache *s, int node, int objects);
+
+static bool put_in_qurantine(struct kmem_cache *s, struct kmem_cache_node *n,
+			     struct page *page, void *object)
+{
+	unsigned long counters;
+	struct page new;
+
+	if (!(s->flags & SLAB_QUARANTINE))
+		return false;
+
+	set_freepointer(s, object, page->quarantine);
+	page->quarantine = object;
+	n->quarantine.nr_objects++;
+
+	/* deactivate_slab takes care about updating inuse */
+	if (page->frozen)
+		return true;
+
+	do {
+		new.freelist = page->freelist;
+		counters = page->counters;
+		new.counters = counters;
+		new.inuse--;
+	} while (!cmpxchg_double_slab(s, page,
+				new.freelist, counters,
+				new.freelist, new.counters,
+				"put_in_qurantine"));
+
+	/* All objects in quarantine, move slab into quarantine */
+	if (!new.inuse && !new.freelist) {
+		remove_full(s, n, page);
+		dec_slabs_node(s, page_to_nid(page), page->objects);
+		add_quarantine(s, n, page);
+	}
+
+	return true;
+}
+
+/* Moves objects from quarantine into freelist */
+static void __flush_quarantine(struct kmem_cache *s, struct kmem_cache_node *n,
+			       struct page *page)
+{
+	void *object, *next;
+
+	for (object = page->quarantine; object; object = next) {
+		next = get_freepointer(s, object);
+		set_freepointer(s, object, page->freelist);
+		page->freelist = object;
+		n->quarantine.nr_objects--;
+	}
+	page->quarantine = NULL;
+}
+
+static void free_slab(struct kmem_cache *s, struct page *page);
+
+static void free_quarantine(struct kmem_cache *s, struct kmem_cache_node *n)
+{
+	struct page *page, *next;
+
+	list_for_each_entry_safe(page, next, &n->quarantine.slabs, lru) {
+		__flush_quarantine(s, n, page);
+		remove_quarantine(s, n, page);
+		free_slab(s, page);
+		stat(s, FREE_SLAB);
+	}
+}
+
+static void free_partial(struct kmem_cache *s, struct kmem_cache_node *n,
+			 bool close);
+
+static void flush_quarantine(struct kmem_cache *s)
+{
+	struct kmem_cache_node *n;
+	unsigned long flags;
+	int node;
+
+	for_each_kmem_cache_node(s, node, n) {
+		spin_lock_irqsave(&n->list_lock, flags);
+		free_quarantine(s, n);
+		free_partial(s, n, false);
+		spin_unlock_irqrestore(&n->list_lock, flags);
+	}
+}
+
+struct kmem_cache_quarantine_shrinker {
+	struct shrinker shrinker;
+	struct kmem_cache *cache;
+};
+
+static struct kmem_cache *quarantine_shrinker_to_cache(struct shrinker *s)
+{
+	return container_of(s, struct kmem_cache_quarantine_shrinker,
+			    shrinker)->cache;
+}
+
+static unsigned long count_quarantine(struct shrinker *shrinker,
+				      struct shrink_control *sc)
+{
+	struct kmem_cache *s = quarantine_shrinker_to_cache(shrinker);
+	struct kmem_cache_node *n = get_node(s, sc->nid);
+
+	return n ? n->quarantine.nr_slabs : 0;
+}
+
+/*
+ * This reclaims only completely quarantined slabs.
+ */
+static unsigned long shrink_quarantine(struct shrinker *shrinker,
+				       struct shrink_control *sc)
+{
+	struct kmem_cache *s = quarantine_shrinker_to_cache(shrinker);
+	struct kmem_cache_node *n = get_node(s, sc->nid);
+	unsigned long flags, freed = 0;
+	struct page *page, *next;
+
+	if (list_empty(&n->quarantine.slabs))
+		return SHRINK_STOP;
+
+	spin_lock_irqsave(&n->list_lock, flags);
+	list_for_each_entry_safe(page, next, &n->quarantine.slabs, lru) {
+		if (!sc->nr_to_scan--)
+			break;
+
+		/* A half goes to another round after examination */
+		if (sc->nr_to_scan & 1) {
+			void *p;
+
+			check_slab(s, page);
+			on_freelist(s, page, NULL);
+			for_each_object(p, s, page_address(page), page->objects)
+				check_object(s, page, p, SLUB_RED_INACTIVE);
+			list_move(&page->lru, &n->quarantine.slabs);
+			continue;
+		}
+
+		__flush_quarantine(s, n, page);
+		remove_quarantine(s, n, page);
+		free_slab(s, page);
+		stat(s, QUARANTINE_BREACH);
+		stat(s, FREE_SLAB);
+		freed++;
+	}
+	spin_unlock_irqrestore(&n->list_lock, flags);
+
+	return freed;
+}
+
+static int register_quarantine_shrinker(struct kmem_cache *s)
+{
+	if ((slab_state >= FULL) && (s->flags & SLAB_QUARANTINE)) {
+		struct kmem_cache_quarantine_shrinker *qs;
+
+		qs = kmalloc(sizeof(*qs), GFP_KERNEL);
+		if (!qs)
+			return -ENOMEM;
+
+		s->quarantine_shrinker = qs;
+		qs->cache = s;
+
+		qs->shrinker.count_objects = count_quarantine;
+		qs->shrinker.scan_objects = shrink_quarantine;
+		qs->shrinker.flags = SHRINKER_NUMA_AWARE;
+		qs->shrinker.seeks = DEFAULT_SEEKS; /* make it tunable? */
+		qs->shrinker.batch = 0;
+
+		return register_shrinker(&qs->shrinker);
+	}
+	return 0;
+}
+
+static void unregister_quarantine_shrinker(struct kmem_cache *s)
+{
+	if (s->flags & SLAB_QUARANTINE) {
+		unregister_shrinker(&s->quarantine_shrinker->shrinker);
+		kfree(s->quarantine_shrinker);
+		s->quarantine_shrinker = NULL;
+	}
+}
+
 /* Tracking of the number of slabs for debugging purposes */
 static inline unsigned long slabs_node(struct kmem_cache *s, int node)
 {
@@ -1108,6 +1347,12 @@ static noinline struct kmem_cache_node *free_debug_processing(
 	init_object(s, object, SLUB_RED_INACTIVE);
 out:
 	slab_unlock(page);
+
+	if (put_in_qurantine(s, n, page, object)) {
+		spin_unlock_irqrestore(&n->list_lock, *flags);
+		n = NULL;
+	}
+
 	/*
 	 * Keep node_lock to preserve integrity
 	 * until the object is actually freed
@@ -1176,6 +1421,9 @@ static int __init setup_slub_debug(char *str)
 		case 'a':
 			slub_debug |= SLAB_FAILSLAB;
 			break;
+		case 'q':
+			slub_debug |= SLAB_QUARANTINE;
+			break;
 		default:
 			pr_err("slub_debug option '%c' unknown. skipped\n",
 			       *str);
@@ -1241,7 +1489,13 @@ static inline void inc_slabs_node(struct kmem_cache *s, int node,
 							int objects) {}
 static inline void dec_slabs_node(struct kmem_cache *s, int node,
 							int objects) {}
-
+static inline int register_quarantine_shrinker(struct kmem_cache *s)
+							{ return 0; }
+static inline void unregister_quarantine_shrinker(struct kmem_cache *s) {}
+static inline void free_quarantine(struct kmem_cache *s,
+		struct kmem_cache_node *n) {}
+static inline void __flush_quarantine(struct kmem_cache *s,
+		struct kmem_cache_node *n, struct page *page) {}
 #endif /* CONFIG_SLUB_DEBUG */

 /*
@@ -1448,6 +1702,7 @@ static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
 	}

 	page->freelist = start;
+	page->quarantine = NULL;
 	page->inuse = page->objects;
 	page->frozen = 1;
 out:
@@ -1525,6 +1780,9 @@ static void free_slab(struct kmem_cache *s, struct page *page)

 static void discard_slab(struct kmem_cache *s, struct page *page)
 {
+	/* FIXME race with quarantine_store('0')
+	 * n->quarantine.nr_objects isn't uptodate */
+	page->quarantine = NULL;
 	dec_slabs_node(s, page_to_nid(page), page->objects);
 	free_slab(s, page);
 }
@@ -1861,6 +2119,29 @@ static void deactivate_slab(struct kmem_cache *s, struct page *page,
 		freelist = nextfree;
 	}

+	if (IS_ENABLED(CONFIG_SLUB_DEBUG) &&
+	    unlikely(s->flags & SLAB_QUARANTINE)) {
+		int objects = 0;
+
+		lock = 1;
+		spin_lock(&n->list_lock);
+
+		for (nextfree = page->quarantine; nextfree;
+		     nextfree = get_freepointer(s, nextfree))
+			objects++;
+
+		do {
+			old.freelist = page->freelist;
+			old.counters = page->counters;
+			new.counters = old.counters;
+			VM_BUG_ON(objects > new.inuse);
+			new.inuse -= objects;
+		} while (!__cmpxchg_double_slab(s, page,
+			old.freelist, old.counters,
+			old.freelist, new.counters,
+			"commit quarantine"));
+	}
+
 	/*
 	 * Stage two: Ensure that the page is unfrozen while the
 	 * list presence reflects the actual number of objects
@@ -2887,6 +3168,9 @@ init_kmem_cache_node(struct kmem_cache_node *n)
 	atomic_long_set(&n->nr_slabs, 0);
 	atomic_long_set(&n->total_objects, 0);
 	INIT_LIST_HEAD(&n->full);
+	n->quarantine.nr_slabs = 0;
+	n->quarantine.nr_objects = 0;
+	INIT_LIST_HEAD(&n->quarantine.slabs);
 #endif
 }

@@ -2939,6 +3223,7 @@ static void early_kmem_cache_node_alloc(int node)
 	n = page->freelist;
 	BUG_ON(!n);
 	page->freelist = get_freepointer(kmem_cache_node, n);
+	page->quarantine = NULL;
 	page->inuse = 1;
 	page->frozen = 0;
 	kmem_cache_node->node[node] = n;
@@ -3186,9 +3471,17 @@ static int kmem_cache_open(struct kmem_cache *s, unsigned long flags)
 	if (!init_kmem_cache_nodes(s))
 		goto error;

-	if (alloc_kmem_cache_cpus(s))
-		return 0;
+	if (!alloc_kmem_cache_cpus(s))
+		goto error_cpus;
+
+	if (register_quarantine_shrinker(s))
+		goto error_shrinker;
+
+	return 0;

+error_shrinker:
+	free_percpu(s->cpu_slab);
+error_cpus:
 	free_kmem_cache_nodes(s);
 error:
 	if (flags & SLAB_PANIC)
@@ -3230,15 +3523,17 @@ static void list_slab_objects(struct kmem_cache *s, struct page *page,
  * This is called from kmem_cache_close(). We must be the last thread
  * using the cache and therefore we do not need to lock anymore.
  */
-static void free_partial(struct kmem_cache *s, struct kmem_cache_node *n)
+static void free_partial(struct kmem_cache *s, struct kmem_cache_node *n,
+			 bool close)
 {
 	struct page *page, *h;

 	list_for_each_entry_safe(page, h, &n->partial, lru) {
+		__flush_quarantine(s, n, page);
 		if (!page->inuse) {
 			__remove_partial(n, page);
 			discard_slab(s, page);
-		} else {
+		} else if (close) {
 			list_slab_objects(s, page,
 			"Objects remaining in %s on kmem_cache_close()");
 		}
@@ -3254,9 +3549,11 @@ static inline int kmem_cache_close(struct kmem_cache *s)
 	struct kmem_cache_node *n;

 	flush_all(s);
+	unregister_quarantine_shrinker(s);
 	/* Attempt to free all objects */
 	for_each_kmem_cache_node(s, node, n) {
-		free_partial(s, n);
+		free_quarantine(s, n);
+		free_partial(s, n, true);
 		if (n->nr_partial || slabs_node(s, node))
 			return 1;
 	}
@@ -4247,7 +4544,8 @@ enum slab_stat_type {
 	SL_PARTIAL,		/* Only partially allocated slabs */
 	SL_CPU,			/* Only slabs used for cpu caches */
 	SL_OBJECTS,		/* Determine allocated objects not slabs */
-	SL_TOTAL		/* Determine object capacity not slabs */
+	SL_TOTAL,		/* Determine object capacity not slabs */
+	SL_QUARANTINE,		/* Determine objects in quarantine */
 };

 #define SO_ALL		(1 << SL_ALL)
@@ -4255,6 +4553,7 @@ enum slab_stat_type {
 #define SO_CPU		(1 << SL_CPU)
 #define SO_OBJECTS	(1 << SL_OBJECTS)
 #define SO_TOTAL	(1 << SL_TOTAL)
+#define SO_QUARANTINE	(1 << SL_QUARANTINE)

 static ssize_t show_slab_objects(struct kmem_cache *s,
 			    char *buf, unsigned long flags)
@@ -4325,6 +4624,17 @@ static ssize_t show_slab_objects(struct kmem_cache *s,
 			nodes[node] += x;
 		}

+	} else if (flags & SO_QUARANTINE) {
+		struct kmem_cache_node *n;
+
+		for_each_kmem_cache_node(s, node, n) {
+			if (flags & SO_OBJECTS)
+				x = n->quarantine.nr_objects;
+			else
+				x = n->quarantine.nr_slabs;
+			total += x;
+			nodes[node] += x;
+		}
 	} else
 #endif
 	if (flags & SO_PARTIAL) {
@@ -4597,6 +4907,58 @@ static ssize_t total_objects_show(struct kmem_cache *s, char *buf)
 }
 SLAB_ATTR_RO(total_objects);

+static ssize_t quarantine_slabs_show(struct kmem_cache *s, char *buf)
+{
+	return show_slab_objects(s, buf, SO_QUARANTINE);
+}
+SLAB_ATTR_RO(quarantine_slabs);
+
+static ssize_t quarantine_objects_show(struct kmem_cache *s, char *buf)
+{
+	return show_slab_objects(s, buf, SO_QUARANTINE|SO_OBJECTS);
+}
+
+static ssize_t quarantine_objects_store(struct kmem_cache *s,
+				const char *buf, size_t length)
+{
+	if (buf[0] == '0')
+		flush_quarantine(s);
+	return length;
+}
+SLAB_ATTR(quarantine_objects);
+
+static ssize_t quarantine_show(struct kmem_cache *s, char *buf)
+{
+	return sprintf(buf, "%d\n", !!(s->flags & SLAB_QUARANTINE));
+}
+
+static ssize_t quarantine_store(struct kmem_cache *s,
+				const char *buf, size_t length)
+{
+	if (buf[0] == '1') {
+		if (!(s->flags & SLAB_QUARANTINE)) {
+			s->flags &= ~__CMPXCHG_DOUBLE;
+			s->flags |= SLAB_QUARANTINE;
+			flush_all(s); /* FIXME stil racy? */
+			if (register_quarantine_shrinker(s)) {
+				s->flags &= ~SLAB_QUARANTINE;
+				flush_quarantine(s);
+				return -ENOMEM;
+			}
+		}
+	} else {
+		if (s->flags & SLAB_QUARANTINE) {
+			unregister_quarantine_shrinker(s);
+			s->flags &= ~SLAB_QUARANTINE;
+			/* FIXME race with deactivate_slab */
+			flush_all(s);
+			flush_quarantine(s);
+		}
+	}
+	return length;
+}
+SLAB_ATTR(quarantine);
+
 static ssize_t sanity_checks_show(struct kmem_cache *s, char *buf)
 {
 	return sprintf(buf, "%d\n", !!(s->flags & SLAB_DEBUG_FREE));
@@ -4877,6 +5239,7 @@ STAT_ATTR(CPU_PARTIAL_ALLOC, cpu_partial_alloc);
 STAT_ATTR(CPU_PARTIAL_FREE, cpu_partial_free);
 STAT_ATTR(CPU_PARTIAL_NODE, cpu_partial_node);
 STAT_ATTR(CPU_PARTIAL_DRAIN, cpu_partial_drain);
+STAT_ATTR(QUARANTINE_BREACH, quarantine_breach);
 #endif

 static struct attribute *slab_attrs[] = {
@@ -4910,6 +5273,9 @@ static struct attribute *slab_attrs[] = {
 	&validate_attr.attr,
 	&alloc_calls_attr.attr,
 	&free_calls_attr.attr,
+	&quarantine_attr.attr,
+	&quarantine_slabs_attr.attr,
+	&quarantine_objects_attr.attr,
 #endif
 #ifdef CONFIG_ZONE_DMA
 	&cache_dma_attr.attr,
@@ -4944,6 +5310,7 @@ static struct attribute *slab_attrs[] = {
 	&cpu_partial_free_attr.attr,
 	&cpu_partial_node_attr.attr,
 	&cpu_partial_drain_attr.attr,
+	&quarantine_breach_attr.attr,
 #endif
 #ifdef CONFIG_FAILSLAB
 	&failslab_attr.attr,
@@ -5285,6 +5652,11 @@ static int __init slab_sysfs_init(void)
 		if (err)
 			pr_err("SLUB: Unable to add boot slab %s to sysfs\n",
 			       s->name);
+
+		err = register_quarantine_shrinker(s);
+		if (err)
+			pr_err("SLUB: Unable to register quarantine shrinker %s",
+			       s->name);
 	}

 	while (alias_list) {
-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
