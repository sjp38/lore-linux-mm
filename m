Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C971F6B0044
	for <linux-mm@kvack.org>; Fri, 23 Jan 2009 08:18:05 -0500 (EST)
Date: Fri, 23 Jan 2009 14:18:00 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] SLQB slab allocator
Message-ID: <20090123131800.GH19986@wotan.suse.de>
References: <20090121143008.GV24891@wotan.suse.de> <87hc3qcpo1.fsf@basil.nowhere.org> <20090123112555.GF19986@wotan.suse.de> <20090123115731.GO15750@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090123115731.GO15750@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Christoph Lameter <clameter@engr.sgi.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 23, 2009 at 12:57:31PM +0100, Andi Kleen wrote:
> On Fri, Jan 23, 2009 at 12:25:55PM +0100, Nick Piggin wrote:
> > > > +#ifdef CONFIG_SLQB_SYSFS
> > > > +	struct kobject kobj;	/* For sysfs */
> > > > +#endif
> > > > +#ifdef CONFIG_NUMA
> > > > +	struct kmem_cache_node *node[MAX_NUMNODES];
> > > > +#endif
> > > > +#ifdef CONFIG_SMP
> > > > +	struct kmem_cache_cpu *cpu_slab[NR_CPUS];
> > > 
> > > Those both really need to be dynamically allocated, otherwise
> > > it wastes a lot of memory in the common case
> > > (e.g. NR_CPUS==128 kernel on dual core system). And of course
> > > on the proposed NR_CPUS==4096 kernels it becomes prohibitive.
> > > 
> > > You could use alloc_percpu? There's no alloc_pernode 
> > > unfortunately, perhaps there should be one. 
> > 
> > cpu_slab is dynamically allocated, by just changing the size of
> > the kmem_cache cache at boot time. 
> 
> You'll always have at least the MAX_NUMNODES waste because
> you cannot tell the compiler that the cpu_slab field has 
> moved.

Right. It could go into a completely different per-cpu structure
if needed to work around that (using node is a relatively rare
operation). But an alloc_pernode would be nicer.

 
> > Probably the best way would
> > be to have dynamic cpu and node allocs for them, I agree.
> 
> It's really needed.
> 
> > Any plans for an alloc_pernode?
> 
> It shouldn't be very hard to implement. Or do you ask if I'm volunteering? @)

Just if you knew about plans. I won't get too much time to work on
it next week, so I hope to have something in slab tree in the
meantime. I think it is OK to leave now, with a mind to improving
it before a possible mainline merge (there will possibly be more
serious issues discovered anyway).


> > > > + * - investiage performance with memoryless nodes. Perhaps CPUs can be given
> > > > + *   a default closest home node via which it can use fastpath functions.
> > > 
> > > FWIW that is what x86-64 always did. Perhaps you can just fix ia64 to do 
> > > that too and be happy.
> > 
> > What if the node is possible but not currently online?
> 
> Nobody should allocate on it then.

But then it goes online and what happens? Your numa_node_id() changes?
How does that work? Or you mean x86-64 does not do that same trick for
possible but offline nodes?


> > git grep -l -e cache_line_size arch/ | egrep '\.h$'
> > 
> > Only ia64, mips, powerpc, sparc, x86...
> 
> It's straight forward to that define everywhere.

OK, but this code is just copied straight from SLAB... I don't want
to add such dependency at this point I'm trying to get something
reasonable to merge. But it would be a fine cleanup.


> > > One thing i was wondering. Did you try to disable the colouring and see
> > > if it makes much difference on modern systems? They tend to have either
> > > larger caches or higher associativity caches.
> > 
> > I have tried, but I don't think I found a test where it made a
> > statistically significant difference. It is not very costly to
> > implement, though.
> 
> how about the memory usage?
> 
> also this is all so complicated already that every simplification helps.

Oh, it only uses slack space in the slabs as such, so it should be
almost zero cost. I tried testing extra colour at the cost of space, but
no obvious difference there either. But I think I'll leave in the code
because it might be a win for some embedded or unusual CPUs.


> > Could bite the bullet and do a multi-stage bootstap like SLUB, but I
> > want to try avoiding that (but init code is also of course much less
> > important than core code and total overheads). 
> 
> For DEFINE_PER_CPU you don't need special allocation.
> 
> Probably want a DEFINE_PER_NODE() for this or see above.

Ah yes DEFINE_PER_CPU of course. Not quite correct for per-node data,
but it should be good enough for wider testing in linux-next.


> > Tables probably would help. I will keep it close to SLUB for now,
> > though.
> 
> Hmm, then fix slub? 

That's my plan, but I go about it a different way ;) I don't want to
spend too much time on other allocators or cleanup etc code too much
right now (except cleanups in SLQB, which of course is required).

Here is an incremental patch for your review points. Thanks very much,
it's a big improvement (getting rid of those static arrays vastly
decreases memory consumption with bigger NR_CPUs, so that's a good
start; will need to investigate alloc_percpu / pernode etc, but that
may have to wait until next week.

---
 include/linux/slab.h     |    4 +
 include/linux/slqb_def.h |   10 +++
 mm/slqb.c                |  125 ++++++++++++++++++++++++++---------------------
 3 files changed, 82 insertions(+), 57 deletions(-)

Index: linux-2.6/include/linux/slab.h
===================================================================
--- linux-2.6.orig/include/linux/slab.h
+++ linux-2.6/include/linux/slab.h
@@ -65,6 +65,10 @@
 /* The following flags affect the page allocator grouping pages by mobility */
 #define SLAB_RECLAIM_ACCOUNT	0x00020000UL		/* Objects are reclaimable */
 #define SLAB_TEMPORARY		SLAB_RECLAIM_ACCOUNT	/* Objects are short-lived */
+
+/* Following flags should only be used by allocator specific flags */
+#define SLAB_ALLOC_PRIVATE	0x000000ffUL
+
 /*
  * ZERO_SIZE_PTR will be returned for zero sized kmalloc requests.
  *
Index: linux-2.6/include/linux/slqb_def.h
===================================================================
--- linux-2.6.orig/include/linux/slqb_def.h
+++ linux-2.6/include/linux/slqb_def.h
@@ -15,6 +15,8 @@
 #include <linux/kernel.h>
 #include <linux/kobject.h>
 
+#define SLAB_NUMA		0x00000001UL    /* shortcut */
+
 enum stat_item {
 	ALLOC,			/* Allocation count */
 	ALLOC_SLAB_FILL,	/* Fill freelist from page list */
@@ -224,12 +226,16 @@ static __always_inline int kmalloc_index
 
 /*
  * Find the kmalloc slab cache for a given combination of allocation flags and
- * size.
+ * size. Should really only be used for constant 'size' arguments, due to
+ * bloat.
  */
 static __always_inline struct kmem_cache *kmalloc_slab(size_t size, gfp_t flags)
 {
-	int index = kmalloc_index(size);
+	int index;
+
+	BUILD_BUG_ON(!__builtin_constant_p(size));
 
+	index = kmalloc_index(size);
 	if (unlikely(index == 0))
 		return NULL;
 
Index: linux-2.6/mm/slqb.c
===================================================================
--- linux-2.6.orig/mm/slqb.c
+++ linux-2.6/mm/slqb.c
@@ -58,9 +58,15 @@ static inline void struct_slqb_page_wron
 
 static int kmem_size __read_mostly;
 #ifdef CONFIG_NUMA
-static int numa_platform __read_mostly;
+static inline int slab_numa(struct kmem_cache *s)
+{
+	return s->flags & SLAB_NUMA;
+}
 #else
-static const int numa_platform = 0;
+static inline int slab_numa(struct kmem_cache *s)
+{
+	return 0;
+}
 #endif
 
 static inline int slab_hiwater(struct kmem_cache *s)
@@ -166,19 +172,6 @@ static inline struct slqb_page *virt_to_
 	return (struct slqb_page *)p;
 }
 
-static inline struct slqb_page *alloc_slqb_pages_node(int nid, gfp_t flags,
-						unsigned int order)
-{
-	struct page *p;
-
-	if (nid == -1)
-		p = alloc_pages(flags, order);
-	else
-		p = alloc_pages_node(nid, flags, order);
-
-	return (struct slqb_page *)p;
-}
-
 static inline void __free_slqb_pages(struct slqb_page *page, unsigned int order)
 {
 	struct page *p = &page->page;
@@ -231,8 +224,16 @@ static inline int slab_poison(struct kme
 static struct notifier_block slab_notifier;
 #endif
 
-/* A list of all slab caches on the system */
+/*
+ * slqb_lock protects slab_caches list and serialises hotplug operations.
+ * hotplug operations take lock for write, other operations can hold off
+ * hotplug by taking it for read (or write).
+ */
 static DECLARE_RWSEM(slqb_lock);
+
+/*
+ * A list of all slab caches on the system
+ */
 static LIST_HEAD(slab_caches);
 
 /*
@@ -875,6 +876,9 @@ static unsigned long kmem_cache_flags(un
 		strlen(slqb_debug_slabs)) == 0))
 			flags |= slqb_debug;
 
+	if (num_possible_nodes() > 1)
+		flags |= SLAB_NUMA;
+
 	return flags;
 }
 #else
@@ -913,6 +917,8 @@ static inline void add_full(struct kmem_
 static inline unsigned long kmem_cache_flags(unsigned long objsize,
 	unsigned long flags, const char *name, void (*ctor)(void *))
 {
+	if (num_possible_nodes() > 1)
+		flags |= SLAB_NUMA;
 	return flags;
 }
 
@@ -930,7 +936,7 @@ static struct slqb_page *allocate_slab(s
 
 	flags |= s->allocflags;
 
-	page = alloc_slqb_pages_node(node, flags, s->order);
+	page = (struct slqb_page *)alloc_pages_node(node, flags, s->order);
 	if (!page)
 		return NULL;
 
@@ -1296,8 +1302,6 @@ static noinline void *__slab_alloc_page(
 	if (c->colour_next >= s->colour_range)
 		c->colour_next = 0;
 
-	/* XXX: load any partial? */
-
 	/* Caller handles __GFP_ZERO */
 	gfpflags &= ~__GFP_ZERO;
 
@@ -1622,7 +1626,7 @@ static __always_inline void __slab_free(
 
 	slqb_stat_inc(l, FREE);
 
-	if (!NUMA_BUILD || !numa_platform ||
+	if (!NUMA_BUILD || !slab_numa(s) ||
 			likely(slqb_page_to_nid(page) == numa_node_id())) {
 		/*
 		 * Freeing fastpath. Collects all local-node objects, not
@@ -1676,7 +1680,7 @@ void kmem_cache_free(struct kmem_cache *
 {
 	struct slqb_page *page = NULL;
 
-	if (numa_platform)
+	if (slab_numa(s))
 		page = virt_to_head_slqb_page(object);
 	slab_free(s, page, object);
 }
@@ -1816,26 +1820,28 @@ static void init_kmem_cache_node(struct
 }
 #endif
 
-/* Initial slabs */
+/* Initial slabs. XXX: allocate dynamically (with bootmem maybe) */
 #ifdef CONFIG_SMP
-static struct kmem_cache_cpu kmem_cache_cpus[NR_CPUS];
+static DEFINE_PER_CPU(struct kmem_cache_cpu, kmem_cache_cpus);
 #endif
 #ifdef CONFIG_NUMA
-static struct kmem_cache_node kmem_cache_nodes[MAX_NUMNODES];
+/* XXX: really need a DEFINE_PER_NODE for per-node data, but this is better than
+ * a static array */
+static DEFINE_PER_CPU(struct kmem_cache_node, kmem_cache_nodes);
 #endif
 
 #ifdef CONFIG_SMP
 static struct kmem_cache kmem_cpu_cache;
-static struct kmem_cache_cpu kmem_cpu_cpus[NR_CPUS];
+static DEFINE_PER_CPU(struct kmem_cache_cpu, kmem_cpu_cpus);
 #ifdef CONFIG_NUMA
-static struct kmem_cache_node kmem_cpu_nodes[MAX_NUMNODES];
+static DEFINE_PER_CPU(struct kmem_cache_node, kmem_cpu_nodes); /* XXX per-nid */
 #endif
 #endif
 
 #ifdef CONFIG_NUMA
 static struct kmem_cache kmem_node_cache;
-static struct kmem_cache_cpu kmem_node_cpus[NR_CPUS];
-static struct kmem_cache_node kmem_node_nodes[MAX_NUMNODES];
+static DEFINE_PER_CPU(struct kmem_cache_cpu, kmem_node_cpus);
+static DEFINE_PER_CPU(struct kmem_cache_node, kmem_node_nodes); /*XXX per-nid */
 #endif
 
 #ifdef CONFIG_SMP
@@ -2090,15 +2096,15 @@ static int kmem_cache_open(struct kmem_c
 		s->colour_range = 0;
 	}
 
+	down_write(&slqb_lock);
 	if (likely(alloc)) {
 		if (!alloc_kmem_cache_nodes(s))
-			goto error;
+			goto error_lock;
 
 		if (!alloc_kmem_cache_cpus(s))
 			goto error_nodes;
 	}
 
-	down_write(&slqb_lock);
 	sysfs_slab_add(s);
 	list_add(&s->list, &slab_caches);
 	up_write(&slqb_lock);
@@ -2107,6 +2113,8 @@ static int kmem_cache_open(struct kmem_c
 
 error_nodes:
 	free_kmem_cache_nodes(s);
+error_lock:
+	up_write(&slqb_lock);
 error:
 	if (flags & SLAB_PANIC)
 		panic("kmem_cache_create(): failed to create slab `%s'\n", name);
@@ -2180,7 +2188,6 @@ void kmem_cache_destroy(struct kmem_cach
 
 	down_write(&slqb_lock);
 	list_del(&s->list);
-	up_write(&slqb_lock);
 
 #ifdef CONFIG_SMP
 	for_each_online_cpu(cpu) {
@@ -2230,6 +2237,7 @@ void kmem_cache_destroy(struct kmem_cach
 #endif
 
 	sysfs_slab_remove(s);
+	up_write(&slqb_lock);
 }
 EXPORT_SYMBOL(kmem_cache_destroy);
 
@@ -2603,7 +2611,7 @@ static int slab_mem_going_online_callbac
 	 * allocate a kmem_cache_node structure in order to bring the node
 	 * online.
 	 */
-	down_read(&slqb_lock);
+	down_write(&slqb_lock);
 	list_for_each_entry(s, &slab_caches, list) {
 		/*
 		 * XXX: kmem_cache_alloc_node will fallback to other nodes
@@ -2621,7 +2629,7 @@ static int slab_mem_going_online_callbac
 		s->node[nid] = n;
 	}
 out:
-	up_read(&slqb_lock);
+	up_write(&slqb_lock);
 	return ret;
 }
 
@@ -2665,13 +2673,6 @@ void __init kmem_cache_init(void)
 	 * All the ifdefs are rather ugly here, but it's just the setup code,
 	 * so it doesn't have to be too readable :)
 	 */
-#ifdef CONFIG_NUMA
-	if (num_possible_nodes() == 1)
-		numa_platform = 0;
-	else
-		numa_platform = 1;
-#endif
-
 #ifdef CONFIG_SMP
 	kmem_size = offsetof(struct kmem_cache, cpu_slab) +
 				nr_cpu_ids * sizeof(struct kmem_cache_cpu *);
@@ -2692,15 +2693,20 @@ void __init kmem_cache_init(void)
 
 #ifdef CONFIG_SMP
 	for_each_possible_cpu(i) {
-		init_kmem_cache_cpu(&kmem_cache_cache, &kmem_cache_cpus[i]);
-		kmem_cache_cache.cpu_slab[i] = &kmem_cache_cpus[i];
+		struct kmem_cache_cpu *c;
 
-		init_kmem_cache_cpu(&kmem_cpu_cache, &kmem_cpu_cpus[i]);
-		kmem_cpu_cache.cpu_slab[i] = &kmem_cpu_cpus[i];
+		c = &per_cpu(kmem_cache_cpus, i);
+		init_kmem_cache_cpu(&kmem_cache_cache, c);
+		kmem_cache_cache.cpu_slab[i] = c;
+
+		c = &per_cpu(kmem_cpu_cpus, i);
+		init_kmem_cache_cpu(&kmem_cpu_cache, c);
+		kmem_cpu_cache.cpu_slab[i] = c;
 
 #ifdef CONFIG_NUMA
-		init_kmem_cache_cpu(&kmem_node_cache, &kmem_node_cpus[i]);
-		kmem_node_cache.cpu_slab[i] = &kmem_node_cpus[i];
+		c = &per_cpu(kmem_node_cpus, i);
+		init_kmem_cache_cpu(&kmem_node_cache, c);
+		kmem_node_cache.cpu_slab[i] = c;
 #endif
 	}
 #else
@@ -2709,14 +2715,19 @@ void __init kmem_cache_init(void)
 
 #ifdef CONFIG_NUMA
 	for_each_node_state(i, N_NORMAL_MEMORY) {
-		init_kmem_cache_node(&kmem_cache_cache, &kmem_cache_nodes[i]);
-		kmem_cache_cache.node[i] = &kmem_cache_nodes[i];
-
-		init_kmem_cache_node(&kmem_cpu_cache, &kmem_cpu_nodes[i]);
-		kmem_cpu_cache.node[i] = &kmem_cpu_nodes[i];
+		struct kmem_cache_node *n;
 
-		init_kmem_cache_node(&kmem_node_cache, &kmem_node_nodes[i]);
-		kmem_node_cache.node[i] = &kmem_node_nodes[i];
+		n = &per_cpu(kmem_cache_nodes, i);
+		init_kmem_cache_node(&kmem_cache_cache, n);
+		kmem_cache_cache.node[i] = n;
+
+		n = &per_cpu(kmem_cpu_nodes, i);
+		init_kmem_cache_node(&kmem_cpu_cache, n);
+		kmem_cpu_cache.node[i] = n;
+
+		n = &per_cpu(kmem_node_nodes, i);
+		init_kmem_cache_node(&kmem_node_cache, n);
+		kmem_node_cache.node[i] = n;
 	}
 #endif
 
@@ -2883,7 +2894,7 @@ static int __cpuinit slab_cpuup_callback
 	switch (action) {
 	case CPU_UP_PREPARE:
 	case CPU_UP_PREPARE_FROZEN:
-		down_read(&slqb_lock);
+		down_write(&slqb_lock);
 		list_for_each_entry(s, &slab_caches, list) {
 			if (s->cpu_slab[cpu]) /* could be lefover last online */
 				continue;
@@ -2893,7 +2904,7 @@ static int __cpuinit slab_cpuup_callback
 				return NOTIFY_BAD;
 			}
 		}
-		up_read(&slqb_lock);
+		up_write(&slqb_lock);
 		break;
 
 	case CPU_ONLINE:
@@ -3019,6 +3030,8 @@ static void gather_stats(struct kmem_cac
 	stats->s = s;
 	spin_lock_init(&stats->lock);
 
+	down_read(&slqb_lock); /* hold off hotplug */
+
 	on_each_cpu(__gather_stats, stats, 1);
 
 #ifdef CONFIG_NUMA
@@ -3047,6 +3060,8 @@ static void gather_stats(struct kmem_cac
 	}
 #endif
 
+	up_read(&slqb_lock);
+
 	stats->nr_objects = stats->nr_slabs * s->objects;
 }
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
