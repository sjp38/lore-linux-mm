Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 93DA06B0044
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 03:23:13 -0400 (EDT)
Received: by mail-bk0-f41.google.com with SMTP id jm1so2730064bkc.14
        for <linux-mm@kvack.org>; Tue, 16 Oct 2012 00:23:12 -0700 (PDT)
Subject: Re: [Q] Default SLAB allocator
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <CAAmzW4M8drwRPy_qWxnkG3-GKGPq+m24me+pGOWNtPzA15iVfg@mail.gmail.com>
References: 
	 <CALF0-+XGn5=QSE0bpa4RTag9CAJ63MKz1kvaYbpw34qUhViaZA@mail.gmail.com>
	 <m27gqwtyu9.fsf@firstfloor.org>
	 <alpine.DEB.2.00.1210111558290.6409@chino.kir.corp.google.com>
	 <m2391ktxjj.fsf@firstfloor.org>
	 <alpine.DEB.2.00.1210130249070.7462@chino.kir.corp.google.com>
	 <1350141021.21172.14949.camel@edumazet-glaptop>
	 <CAAmzW4M8drwRPy_qWxnkG3-GKGPq+m24me+pGOWNtPzA15iVfg@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 16 Oct 2012 09:23:07 +0200
Message-ID: <1350372187.3954.636.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: JoonSoo Kim <js1304@gmail.com>
Cc: David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, Ezequiel Garcia <elezegarcia@gmail.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Tim Bird <tim.bird@am.sony.com>, celinux-dev@lists.celinuxforum.org

On Tue, 2012-10-16 at 10:28 +0900, JoonSoo Kim wrote:
> Hello, Eric.
> 
> 2012/10/14 Eric Dumazet <eric.dumazet@gmail.com>:
> > SLUB was really bad in the common workload you describe (allocations
> > done by one cpu, freeing done by other cpus), because all kfree() hit
> > the slow path and cpus contend in __slab_free() in the loop guarded by
> > cmpxchg_double_slab(). SLAB has a cache for this, while SLUB directly
> > hit the main "struct page" to add the freed object to freelist.
> 
> Could you elaborate more on how 'netperf RR' makes kernel "allocations
> done by one cpu, freeling done by other cpus", please?
> I don't have enough background network subsystem, so I'm just curious.
> 

Common network load is to have one cpu A handling device interrupts
doing the memory allocations to hold incoming frames,
and queueing skbs to various sockets.

These sockets are read by other cpus (if the cpu A is fully used to
service softirqs under high load), so the kfree() are done by other
cpus.

Each incoming frame uses one sk_buff, allocated from skbuff_head_cache
kmemcache (256 bytes on x86_64)

# ls -l /sys/kernel/slab/skbuff_head_cache
lrwxrwxrwx 1 root root 0 oct.  16
08:50 /sys/kernel/slab/skbuff_head_cache -> :t-0000256

# cat /sys/kernel/slab/skbuff_head_cache/objs_per_slab 
32

On a configuration with 24 cpus and one cpu servicing network, we may
have 23 cpus doing the frees roughly at the same time, all competing in 
__slab_free() on the same page. This increases if we increase slub page
order (as recommended by SLUB hackers)

To reproduce this kind of workload without a real NIC, we probably need
some test module, using one thread doing allocations, and other threads
doing the free.

> > I played some months ago adding a percpu associative cache to SLUB, then
> > just moved on other strategy.
> >
> > (Idea for this per cpu cache was to build a temporary free list of
> > objects to batch accesses to struct page)
> 
> Is this implemented and submitted?
> If it is, could you tell me the link for the patches?

It was implemented in february and not submitted at that time.

The following rebase has probably some issues with slab debug, but seems
to work.

 include/linux/slub_def.h |   22 ++++++
 mm/slub.c                |  127 +++++++++++++++++++++++++++++++------
 2 files changed, 131 insertions(+), 18 deletions(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index df448ad..9e5b91c 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -41,8 +41,30 @@ enum stat_item {
 	CPU_PARTIAL_FREE,	/* Refill cpu partial on free */
 	CPU_PARTIAL_NODE,	/* Refill cpu partial from node partial */
 	CPU_PARTIAL_DRAIN,	/* Drain cpu partial to node partial */
+	FREE_CACHED,		/* free delayed in secondary freelist, cumulative counter */
+	FREE_CACHED_ITEMS,	/* items in victim cache */
 	NR_SLUB_STAT_ITEMS };
 
+/**
+ * struct slub_cache_desc - victim cache descriptor 
+ * @page: slab page
+ * @objects_head: head of freed objects list
+ * @objects_tail: tail of freed objects list
+ * @count: number of objects in list
+ *
+ * freed objects in slow path are managed into an associative cache,
+ * to reduce contention on @page->freelist
+ */
+struct slub_cache_desc {
+	struct page	*page;
+	void		**objects_head;
+	void		**objects_tail;
+	int		count;
+};
+
+#define NR_SLUB_PCPU_CACHE_SHIFT 6
+#define NR_SLUB_PCPU_CACHE (1 << NR_SLUB_PCPU_CACHE_SHIFT)
+
 struct kmem_cache_cpu {
 	void **freelist;	/* Pointer to next available object */
 	unsigned long tid;	/* Globally unique transaction id */
diff --git a/mm/slub.c b/mm/slub.c
index a0d6984..30a6d72 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -31,6 +31,7 @@
 #include <linux/fault-inject.h>
 #include <linux/stacktrace.h>
 #include <linux/prefetch.h>
+#include <linux/hash.h>
 
 #include <trace/events/kmem.h>
 
@@ -221,6 +222,14 @@ static inline void stat(const struct kmem_cache *s, enum stat_item si)
 #endif
 }
 
+static inline void stat_add(const struct kmem_cache *s, enum stat_item si,
+			    int cnt)
+{
+#ifdef CONFIG_SLUB_STATS
+	__this_cpu_add(s->cpu_slab->stat[si], cnt);
+#endif
+}
+
 /********************************************************************
  * 			Core slab cache functions
  *******************************************************************/
@@ -1993,6 +2002,8 @@ static inline void flush_slab(struct kmem_cache *s, struct kmem_cache_cpu *c)
 	c->freelist = NULL;
 }
 
+static void victim_cache_flush(struct kmem_cache *s, int cpu);
+
 /*
  * Flush cpu slab.
  *
@@ -2006,6 +2017,7 @@ static inline void __flush_cpu_slab(struct kmem_cache *s, int cpu)
 		if (c->page)
 			flush_slab(s, c);
 
+		victim_cache_flush(s, cpu);
 		unfreeze_partials(s);
 	}
 }
@@ -2446,38 +2458,34 @@ EXPORT_SYMBOL(kmem_cache_alloc_node_trace);
 #endif
 
 /*
- * Slow patch handling. This may still be called frequently since objects
+ * Slow path handling. This may still be called frequently since objects
  * have a longer lifetime than the cpu slabs in most processing loads.
  *
  * So we still attempt to reduce cache line usage. Just take the slab
- * lock and free the item. If there is no additional partial page
+ * lock and free the items. If there is no additional partial page
  * handling required then we can return immediately.
  */
-static void __slab_free(struct kmem_cache *s, struct page *page,
-			void *x, unsigned long addr)
+static void slub_cache_flush(const struct slub_cache_desc *cache)
 {
 	void *prior;
-	void **object = (void *)x;
 	int was_frozen;
 	int inuse;
 	struct page new;
 	unsigned long counters;
 	struct kmem_cache_node *n = NULL;
-	unsigned long uninitialized_var(flags);
-
-	stat(s, FREE_SLOWPATH);
+	struct page *page = cache->page;
+	struct kmem_cache *s = page->slab;
 
-	if (kmem_cache_debug(s) &&
-		!(n = free_debug_processing(s, page, x, addr, &flags)))
-		return;
+	stat_add(s, FREE_CACHED, cache->count - 1);
+	stat_add(s, FREE_CACHED_ITEMS, -cache->count);
 
 	do {
 		prior = page->freelist;
 		counters = page->counters;
-		set_freepointer(s, object, prior);
+		set_freepointer(s, cache->objects_tail, prior);
 		new.counters = counters;
 		was_frozen = new.frozen;
-		new.inuse--;
+		new.inuse -= cache->count;
 		if ((!new.inuse || !prior) && !was_frozen && !n) {
 
 			if (!kmem_cache_debug(s) && !prior)
@@ -2499,7 +2507,7 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
 				 * Otherwise the list_lock will synchronize with
 				 * other processors updating the list of slabs.
 				 */
-				spin_lock_irqsave(&n->list_lock, flags);
+				spin_lock(&n->list_lock);
 
 			}
 		}
@@ -2507,8 +2515,8 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
 
 	} while (!cmpxchg_double_slab(s, page,
 		prior, counters,
-		object, new.counters,
-		"__slab_free"));
+		cache->objects_head, new.counters,
+		"slab_free_objects"));
 
 	if (likely(!n)) {
 
@@ -2549,7 +2557,7 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
 			stat(s, FREE_ADD_PARTIAL);
 		}
 	}
-	spin_unlock_irqrestore(&n->list_lock, flags);
+	spin_unlock(&n->list_lock);
 	return;
 
 slab_empty:
@@ -2563,11 +2571,90 @@ slab_empty:
 		/* Slab must be on the full list */
 		remove_full(s, page);
 
-	spin_unlock_irqrestore(&n->list_lock, flags);
+	spin_unlock(&n->list_lock);
 	stat(s, FREE_SLAB);
 	discard_slab(s, page);
 }
 
+DEFINE_PER_CPU_ALIGNED(struct slub_cache_desc, victim_cache[NR_SLUB_PCPU_CACHE]);
+
+static void victim_cache_flush(struct kmem_cache *s, int cpu)
+{
+	int i;
+	struct slub_cache_desc *cache = per_cpu(victim_cache, cpu);
+
+	for (i = 0; i < NR_SLUB_PCPU_CACHE; i++,cache++) {
+		if (cache->page && cache->page->slab == s) {
+			slub_cache_flush(cache);
+			cache->page = NULL;
+		}
+			
+	}
+}
+
+static unsigned int slub_page_hash(const struct page *page)
+{
+	u32 val = hash32_ptr(page);
+
+	/* ID : add coloring, so that cpus dont flush a slab at same time ?
+	 *	val += raw_smp_processor_id();
+	 */
+	return hash_32(val, NR_SLUB_PCPU_CACHE_SHIFT);
+}
+
+/*
+ * Instead of pushing individual objects into page freelist,
+ * dirtying page->freelist/counters for each object, we build percpu private
+ * lists of objects belonging to same slab.
+ */
+static void __slab_free(struct kmem_cache *s, struct page *page,
+			void *x, unsigned long addr)
+{
+	void **object = (void *)x;
+	struct slub_cache_desc *cache;
+	unsigned int hash;
+	struct kmem_cache_node *n = NULL;
+	unsigned long flags;
+
+	stat(s, FREE_SLOWPATH);
+
+	if (kmem_cache_debug(s)) {
+		n = free_debug_processing(s, page, x, addr, &flags);
+		if (!n)
+			return;
+		spin_unlock_irqrestore(&n->list_lock, flags);
+	}
+
+	hash = slub_page_hash(page);
+
+	local_irq_save(flags);
+
+	cache = __this_cpu_ptr(&victim_cache[hash]);
+	if (cache->page == page) {
+		/*
+		 * Nice, we have a private freelist for this page,
+		 * add this object in it. Since we are in slow path,
+		 * we add this 'hot' object at tail, to let a chance old
+		 * objects being evicted from our cache before another cpu
+		 * need them later. This also helps the final
+		 * slab_free_objects() call to access objects_tail
+		 * without a cache miss (object_tail being hot)
+		 */
+		set_freepointer(s, cache->objects_tail, object);
+		cache->count++;
+	} else {
+		if (likely(cache->page))
+			slub_cache_flush(cache);
+
+		cache->page = page;
+		cache->objects_head = object;
+		cache->count = 1;
+	}
+	cache->objects_tail = object;
+	stat(s, FREE_CACHED_ITEMS);
+	local_irq_restore(flags);
+}
+
 /*
  * Fastpath with forced inlining to produce a kfree and kmem_cache_free that
  * can perform fastpath freeing without additional function calls.
@@ -5084,6 +5171,8 @@ STAT_ATTR(CPU_PARTIAL_ALLOC, cpu_partial_alloc);
 STAT_ATTR(CPU_PARTIAL_FREE, cpu_partial_free);
 STAT_ATTR(CPU_PARTIAL_NODE, cpu_partial_node);
 STAT_ATTR(CPU_PARTIAL_DRAIN, cpu_partial_drain);
+STAT_ATTR(FREE_CACHED, free_cached);
+STAT_ATTR(FREE_CACHED_ITEMS, free_cached_items);
 #endif
 
 static struct attribute *slab_attrs[] = {
@@ -5151,6 +5240,8 @@ static struct attribute *slab_attrs[] = {
 	&cpu_partial_free_attr.attr,
 	&cpu_partial_node_attr.attr,
 	&cpu_partial_drain_attr.attr,
+	&free_cached_attr.attr,
+	&free_cached_items_attr.attr,
 #endif
 #ifdef CONFIG_FAILSLAB
 	&failslab_attr.attr,


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
