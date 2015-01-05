Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 1C3736B0074
	for <linux-mm@kvack.org>; Sun,  4 Jan 2015 20:37:53 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id g10so26995760pdj.6
        for <linux-mm@kvack.org>; Sun, 04 Jan 2015 17:37:52 -0800 (PST)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id be9si66113694pad.219.2015.01.04.17.37.46
        for <linux-mm@kvack.org>;
        Sun, 04 Jan 2015 17:37:49 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 6/6] mm/slab: allocation fastpath without disabling irq
Date: Mon,  5 Jan 2015 10:37:31 +0900
Message-Id: <1420421851-3281-7-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1420421851-3281-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1420421851-3281-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>

SLAB always disable irq before executing any object alloc/free operation.
This is really painful in terms of performance. Benchmark result that does
alloc/free repeatedly shows that each alloc/free is rougly 2 times slower
than SLUB's one (27 ns : 14 ns). To improve performance, this patch
implements allocation fastpath without disable irq.

Transaction id is introduced and updated on every operation. In allocation
fastpath, object in array cache is read speculartively. And then, pointer
pointing object position in array cache and transaction id are updated
simultaneously through this_cpu_cmpxchg_double(). If tid is unchanged
until this updating, it ensures that there is no concurrent clients
allocating/freeing object to this slab. So allocation could succeed
without disabling irq.

This is a similar way to implement allocation fastpath in SLUB.

Above mentioned benchmark shows that alloc/free fastpath performance
is improved roughly 22%. (27 ns -> 21 ns).

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/slab.c |  151 +++++++++++++++++++++++++++++++++++++++++++++++--------------
 1 file changed, 118 insertions(+), 33 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 449fc6b..54656f0 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -168,6 +168,41 @@ typedef unsigned short freelist_idx_t;
 
 #define SLAB_OBJ_MAX_NUM ((1 << sizeof(freelist_idx_t) * BITS_PER_BYTE) - 1)
 
+#ifdef CONFIG_PREEMPT
+/*
+ * Calculate the next globally unique transaction for disambiguiation
+ * during cmpxchg. The transactions start with the cpu number and are then
+ * incremented by CONFIG_NR_CPUS.
+ */
+#define TID_STEP  roundup_pow_of_two(CONFIG_NR_CPUS)
+#else
+/*
+ * No preemption supported therefore also no need to check for
+ * different cpus.
+ */
+#define TID_STEP 1
+#endif
+
+static inline unsigned long next_tid(unsigned long tid)
+{
+	return tid + TID_STEP;
+}
+
+static inline unsigned int tid_to_cpu(unsigned long tid)
+{
+	return tid % TID_STEP;
+}
+
+static inline unsigned long tid_to_event(unsigned long tid)
+{
+	return tid / TID_STEP;
+}
+
+static inline unsigned int init_tid(int cpu)
+{
+	return cpu;
+}
+
 /*
  * true if a page was allocated from pfmemalloc reserves for network-based
  * swap
@@ -187,7 +222,8 @@ static bool pfmemalloc_active __read_mostly;
  *
  */
 struct array_cache {
-	unsigned int avail;
+	unsigned long avail;
+	unsigned long tid;
 	unsigned int limit;
 	unsigned int batchcount;
 	unsigned int touched;
@@ -657,7 +693,8 @@ static void start_cpu_timer(int cpu)
 	}
 }
 
-static void init_arraycache(struct array_cache *ac, int limit, int batch)
+static void init_arraycache(struct array_cache *ac, int limit,
+				int batch, int cpu)
 {
 	/*
 	 * The array_cache structures contain pointers to free object.
@@ -669,6 +706,7 @@ static void init_arraycache(struct array_cache *ac, int limit, int batch)
 	kmemleak_no_scan(ac);
 	if (ac) {
 		ac->avail = 0;
+		ac->tid = init_tid(cpu);
 		ac->limit = limit;
 		ac->batchcount = batch;
 		ac->touched = 0;
@@ -676,13 +714,13 @@ static void init_arraycache(struct array_cache *ac, int limit, int batch)
 }
 
 static struct array_cache *alloc_arraycache(int node, int entries,
-					    int batchcount, gfp_t gfp)
+					    int batchcount, gfp_t gfp, int cpu)
 {
 	size_t memsize = sizeof(void *) * entries + sizeof(struct array_cache);
 	struct array_cache *ac = NULL;
 
 	ac = kmalloc_node(memsize, gfp, node);
-	init_arraycache(ac, entries, batchcount);
+	init_arraycache(ac, entries, batchcount, cpu);
 	return ac;
 }
 
@@ -721,22 +759,36 @@ out:
 }
 
 static void *get_obj_from_pfmemalloc_obj(struct kmem_cache *cachep,
-				struct array_cache *ac, void *objp,
-				gfp_t flags, bool force_refill)
+				void *objp, gfp_t flags, bool force_refill)
 {
 	int i;
 	struct kmem_cache_node *n;
+	struct array_cache *ac;
 	LIST_HEAD(list);
-	int node;
-
-	BUG_ON(ac->avail >= ac->limit);
-	BUG_ON(objp != ac->entry[ac->avail]);
+	int page_node, node;
+	unsigned long save_flags;
 
 	if (gfp_pfmemalloc_allowed(flags)) {
 		clear_obj_pfmemalloc(&objp);
 		return objp;
 	}
 
+	local_irq_save(save_flags);
+	page_node = page_to_nid(virt_to_page(objp));
+	node = numa_mem_id();
+
+	/*
+	 * Because we disable irq just now, cpu can be changed
+	 * and we are on different node with object node. In this rare
+	 * case, just return pfmemalloc object for simplicity.
+	 */
+	if (unlikely(node != page_node)) {
+		clear_obj_pfmemalloc(&objp);
+		goto out;
+	}
+
+	ac = cpu_cache_get(cachep);
+
 	/* The caller cannot use PFMEMALLOC objects, find another one */
 	for (i = 0; i < ac->avail; i++) {
 		if (is_obj_pfmemalloc(ac->entry[i]))
@@ -747,7 +799,7 @@ static void *get_obj_from_pfmemalloc_obj(struct kmem_cache *cachep,
 		ac->entry[i] = ac->entry[ac->avail];
 		ac->entry[ac->avail] = objp;
 
-		return objp;
+		goto out;
 	}
 
 	/*
@@ -763,7 +815,7 @@ static void *get_obj_from_pfmemalloc_obj(struct kmem_cache *cachep,
 		clear_obj_pfmemalloc(&objp);
 		recheck_pfmemalloc_active(cachep, ac);
 
-		return objp;
+		goto out;
 	}
 
 	/* No !PFMEMALLOC objects available */
@@ -776,6 +828,8 @@ static void *get_obj_from_pfmemalloc_obj(struct kmem_cache *cachep,
 	}
 	objp = NULL;
 
+out:
+	local_irq_restore(save_flags);
 	return objp;
 }
 
@@ -784,9 +838,10 @@ static inline void *ac_get_obj(struct kmem_cache *cachep,
 {
 	void *objp;
 
+	ac->tid = next_tid(ac->tid);
 	objp = ac->entry[--ac->avail];
 	if (unlikely(sk_memalloc_socks()) && is_obj_pfmemalloc(objp)) {
-		objp = get_obj_from_pfmemalloc_obj(cachep, ac, objp,
+		objp = get_obj_from_pfmemalloc_obj(cachep, objp,
 						flags, force_refill);
 	}
 
@@ -812,6 +867,7 @@ static inline void ac_put_obj(struct kmem_cache *cachep, struct array_cache *ac,
 	if (unlikely(sk_memalloc_socks()))
 		objp = __ac_put_obj(cachep, ac, objp);
 
+	ac->tid = next_tid(ac->tid);
 	ac->entry[ac->avail++] = objp;
 }
 
@@ -825,7 +881,8 @@ static int transfer_objects(struct array_cache *to,
 		struct array_cache *from, unsigned int max)
 {
 	/* Figure out how many entries to transfer */
-	int nr = min3(from->avail, max, to->limit - to->avail);
+	int nr = min3(from->avail, (unsigned long)max,
+			(unsigned long)to->limit - to->avail);
 
 	if (!nr)
 		return 0;
@@ -882,7 +939,7 @@ static struct alien_cache *__alloc_alien_cache(int node, int entries,
 	struct alien_cache *alc = NULL;
 
 	alc = kmalloc_node(memsize, gfp, node);
-	init_arraycache(&alc->ac, entries, batch);
+	init_arraycache(&alc->ac, entries, batch, 0);
 	spin_lock_init(&alc->lock);
 	return alc;
 }
@@ -1117,6 +1174,7 @@ static void cpuup_canceled(long cpu)
 		nc = per_cpu_ptr(cachep->cpu_cache, cpu);
 		if (nc) {
 			free_block(cachep, nc->entry, nc->avail, node, &list);
+			nc->tid = next_tid(nc->tid);
 			nc->avail = 0;
 		}
 
@@ -1187,7 +1245,7 @@ static int cpuup_prepare(long cpu)
 		if (cachep->shared) {
 			shared = alloc_arraycache(node,
 				cachep->shared * cachep->batchcount,
-				0xbaadf00d, GFP_KERNEL);
+				0xbaadf00d, GFP_KERNEL, cpu);
 			if (!shared)
 				goto bad;
 		}
@@ -2008,14 +2066,14 @@ static struct array_cache __percpu *alloc_kmem_cache_cpus(
 	size = sizeof(void *) * entries + sizeof(struct array_cache);
 	if (slab_state < FULL)
 		gfp_flags = GFP_NOWAIT;
-	cpu_cache = __alloc_percpu_gfp(size, sizeof(void *), gfp_flags);
+	cpu_cache = __alloc_percpu_gfp(size, 2 * sizeof(void *), gfp_flags);
 
 	if (!cpu_cache)
 		return NULL;
 
 	for_each_possible_cpu(cpu) {
 		init_arraycache(per_cpu_ptr(cpu_cache, cpu),
-				entries, batchcount);
+				entries, batchcount, cpu);
 	}
 
 	return cpu_cache;
@@ -2051,6 +2109,7 @@ static int __init_refok setup_cpu_cache(struct kmem_cache *cachep, gfp_t gfp)
 			jiffies + REAPTIMEOUT_NODE +
 			((unsigned long)cachep) % REAPTIMEOUT_NODE;
 
+	cpu_cache_get(cachep)->tid = init_tid(smp_processor_id());
 	cpu_cache_get(cachep)->avail = 0;
 	cpu_cache_get(cachep)->limit = BOOT_CPUCACHE_ENTRIES;
 	cpu_cache_get(cachep)->batchcount = 1;
@@ -2339,6 +2398,7 @@ static void do_drain(void *arg)
 	free_block(cachep, ac->entry, ac->avail, node, &list);
 	spin_unlock(&n->list_lock);
 	slabs_destroy(cachep, &list);
+	ac->tid = next_tid(ac->tid);
 	ac->avail = 0;
 }
 
@@ -2774,6 +2834,9 @@ static void *cache_alloc_refill(struct kmem_cache *cachep, gfp_t flags,
 		goto force_grow;
 retry:
 	ac = cpu_cache_get(cachep);
+	if (ac->avail)
+		goto avail;
+
 	batchcount = ac->batchcount;
 	if (!ac->touched && batchcount > BATCHREFILL_LIMIT) {
 		/*
@@ -2790,6 +2853,7 @@ retry:
 
 	/* See if we can refill from the shared array */
 	if (n->shared && transfer_objects(ac, n->shared, batchcount)) {
+		ac->tid = next_tid(ac->tid);
 		n->shared->touched = 1;
 		goto alloc_done;
 	}
@@ -2854,6 +2918,8 @@ force_grow:
 		if (!ac->avail)		/* objects refilled by interrupt? */
 			goto retry;
 	}
+
+avail:
 	ac->touched = 1;
 
 	return ac_get_obj(cachep, ac, flags, force_refill);
@@ -2935,31 +3001,48 @@ static inline void *____cache_alloc(struct kmem_cache *cachep, gfp_t flags)
 	struct array_cache *ac;
 	bool force_refill = false;
 	unsigned long save_flags;
+	unsigned long tid;
+	unsigned long avail;
 
-	local_irq_save(save_flags);
-
+redo:
+	preempt_disable();
 	ac = cpu_cache_get(cachep);
-	if (unlikely(!ac->avail))
+	tid = ac->tid;
+	preempt_enable();
+
+	avail = ac->avail;
+	if (unlikely(!avail))
 		goto slowpath;
 
 	ac->touched = 1;
-	objp = ac_get_obj(cachep, ac, flags, false);
-
-	/*
-	 * Allow for the possibility all avail objects are not allowed
-	 * by the current flags
-	 */
-	if (likely(objp)) {
-		STATS_INC_ALLOCHIT(cachep);
-		goto out;
+	objp = ac->entry[avail - 1];
+	if (unlikely(!this_cpu_cmpxchg_double(
+		cachep->cpu_cache->avail, cachep->cpu_cache->tid,
+		avail, tid,
+		avail - 1, next_tid(tid))))
+		goto redo;
+
+	if (unlikely(sk_memalloc_socks() && is_obj_pfmemalloc(objp))) {
+		/*
+		 * Allow for the possibility all avail objects are not
+		 * allowed by the current flags
+		 */
+		objp = get_obj_from_pfmemalloc_obj(cachep, objp,
+						flags, force_refill);
+		if (!objp) {
+			force_refill = true;
+			goto slowpath;
+		}
 	}
-	force_refill = true;
+
+	STATS_INC_ALLOCHIT(cachep);
+	return objp;
 
 slowpath:
+	local_irq_save(save_flags);
 	STATS_INC_ALLOCMISS(cachep);
 	objp = cache_alloc_refill(cachep, flags, force_refill);
 
-out:
 	local_irq_restore(save_flags);
 
 	return objp;
@@ -3353,6 +3436,7 @@ free_done:
 #endif
 	spin_unlock(&n->list_lock);
 	slabs_destroy(cachep, &list);
+	ac->tid = next_tid(ac->tid);
 	ac->avail -= batchcount;
 	memmove(ac->entry, &(ac->entry[batchcount]), sizeof(void *)*ac->avail);
 }
@@ -3605,7 +3689,7 @@ static int alloc_kmem_cache_node(struct kmem_cache *cachep, gfp_t gfp)
 		if (cachep->shared) {
 			new_shared = alloc_arraycache(node,
 				cachep->shared*cachep->batchcount,
-					0xbaadf00d, gfp);
+					0xbaadf00d, gfp, 0);
 			if (!new_shared) {
 				free_alien_cache(new_alien);
 				goto fail;
@@ -3829,6 +3913,7 @@ static void drain_array(struct kmem_cache *cachep, struct kmem_cache_node *n,
 			if (tofree > ac->avail)
 				tofree = (ac->avail + 1) / 2;
 			free_block(cachep, ac->entry, tofree, node, &list);
+			ac->tid = next_tid(ac->tid);
 			ac->avail -= tofree;
 			memmove(ac->entry, &(ac->entry[tofree]),
 				sizeof(void *) * ac->avail);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
