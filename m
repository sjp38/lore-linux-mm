Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4D1906B005C
	for <linux-mm@kvack.org>; Fri, 23 Jan 2009 04:55:37 -0500 (EST)
Subject: Re: [patch] SLQB slab allocator
From: Andi Kleen <andi@firstfloor.org>
References: <20090121143008.GV24891@wotan.suse.de>
Date: Fri, 23 Jan 2009 10:55:26 +0100
In-Reply-To: <20090121143008.GV24891@wotan.suse.de> (Nick Piggin's message of "Wed, 21 Jan 2009 15:30:08 +0100")
Message-ID: <87hc3qcpo1.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Christoph Lameter <clameter@engr.sgi.com>
List-ID: <linux-mm.kvack.org>

Nick Piggin <npiggin@suse.de> writes:

Not a full review, just some things i noticed.

The code is very readable thanks (that's imho the main reason slab.c
should go btw, it's really messy and hard to get through)

> Using lists rather than arrays can reduce the cacheline footprint. When moving
> objects around, SLQB can move a list of objects from one CPU to another by
> simply manipulating a head pointer, wheras SLAB needs to memcpy arrays. Some
> SLAB per-CPU arrays can be up to 1K in size, which is a lot of cachelines that
> can be touched during alloc/free. Newly freed objects tend to be cache hot,
> and newly allocated ones tend to soon be touched anyway, so often there is
> little cost to using metadata in the objects.

You're probably aware of that, but the obvious counter argument
is that for manipulating a single object a double linked
list will always require touching three cache lines
(prev, current, next), while an array access only a single one.
A possible alternative would be a list of shorter arrays.

> +	int objsize;		/* The size of an object without meta data */
> +	int offset;		/* Free pointer offset. */
> +	int objects;		/* Number of objects in slab */
> +
> +	int size;		/* The size of an object including meta data */
> +	int order;		/* Allocation order */
> +	gfp_t allocflags;	/* gfp flags to use on allocation */
> +	unsigned int colour_range;	/* range of colour counter */
> +	unsigned int colour_off;		/* offset per colour */
> +	void (*ctor)(void *);
> +
> +	const char *name;	/* Name (only for display!) */
> +	struct list_head list;	/* List of slab caches */
> +
> +	int align;		/* Alignment */
> +	int inuse;		/* Offset to metadata */

I suspect some of these fields could be short or char (E.g. alignment),
possibly lowering cache line impact.

> +
> +#ifdef CONFIG_SLQB_SYSFS
> +	struct kobject kobj;	/* For sysfs */
> +#endif
> +#ifdef CONFIG_NUMA
> +	struct kmem_cache_node *node[MAX_NUMNODES];
> +#endif
> +#ifdef CONFIG_SMP
> +	struct kmem_cache_cpu *cpu_slab[NR_CPUS];

Those both really need to be dynamically allocated, otherwise
it wastes a lot of memory in the common case
(e.g. NR_CPUS==128 kernel on dual core system). And of course
on the proposed NR_CPUS==4096 kernels it becomes prohibitive.

You could use alloc_percpu? There's no alloc_pernode 
unfortunately, perhaps there should be one. 

> +#if L1_CACHE_BYTES < 64
> +	if (size > 64 && size <= 96)
> +		return 1;
> +#endif
> +#if L1_CACHE_BYTES < 128
> +	if (size > 128 && size <= 192)
> +		return 2;
> +#endif
> +	if (size <=	  8) return 3;
> +	if (size <=	 16) return 4;
> +	if (size <=	 32) return 5;
> +	if (size <=	 64) return 6;
> +	if (size <=	128) return 7;
> +	if (size <=	256) return 8;
> +	if (size <=	512) return 9;
> +	if (size <=       1024) return 10;
> +	if (size <=   2 * 1024) return 11;
> +	if (size <=   4 * 1024) return 12;
> +	if (size <=   8 * 1024) return 13;
> +	if (size <=  16 * 1024) return 14;
> +	if (size <=  32 * 1024) return 15;
> +	if (size <=  64 * 1024) return 16;
> +	if (size <= 128 * 1024) return 17;
> +	if (size <= 256 * 1024) return 18;
> +	if (size <= 512 * 1024) return 19;
> +	if (size <= 1024 * 1024) return 20;
> +	if (size <=  2 * 1024 * 1024) return 21;

Have you looked into other binsizes?  iirc the original slab paper
mentioned that power of two is usually not the best.

> +	return -1;

> +}
> +
> +#ifdef CONFIG_ZONE_DMA
> +#define SLQB_DMA __GFP_DMA
> +#else
> +/* Disable "DMA slabs" */
> +#define SLQB_DMA (__force gfp_t)0
> +#endif
> +
> +/*
> + * Find the kmalloc slab cache for a given combination of allocation flags and
> + * size.

You should mention that this would be a very bad idea to call for !__builtin_constant_p(size)

> + */
> +static __always_inline struct kmem_cache *kmalloc_slab(size_t size, gfp_t flags)
> +{
> +	int index = kmalloc_index(size);
> +
> +	if (unlikely(index == 0))
> +		return NULL;
> +
> +	if (likely(!(flags & SLQB_DMA)))
> +		return &kmalloc_caches[index];
> +	else
> +		return &kmalloc_caches_dma[index];

BTW i had an old patchkit to kill all GFP_DMA slab users. Perhaps should
warm that up again. That would lower the inline footprint.

> +#ifdef CONFIG_NUMA
> +void *__kmalloc_node(size_t size, gfp_t flags, int node);
> +void *kmem_cache_alloc_node(struct kmem_cache *, gfp_t flags, int node);
> +
> +static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)

kmalloc_node should be infrequent, i suspect it can be safely out of lined.

> + * - investiage performance with memoryless nodes. Perhaps CPUs can be given
> + *   a default closest home node via which it can use fastpath functions.

FWIW that is what x86-64 always did. Perhaps you can just fix ia64 to do 
that too and be happy.

> + *   Perhaps it is not a big problem.
> + */
> +
> +/*
> + * slqb_page overloads struct page, and is used to manage some slob allocation
> + * aspects, however to avoid the horrible mess in include/linux/mm_types.h,
> + * we'll just define our own struct slqb_page type variant here.

Hopefully this works for the crash dumpers. Do they have a way to distingush
slub/slqb/slab kernels with different struct page usage?

> +#define PG_SLQB_BIT (1 << PG_slab)
> +
> +static int kmem_size __read_mostly;
> +#ifdef CONFIG_NUMA
> +static int numa_platform __read_mostly;
> +#else
> +#define numa_platform 0
> +#endif

It would be cheaper if you put that as a flag into the kmem_caches flags, this
way you avoid an additional cache line touched.

> +static inline int slqb_page_to_nid(struct slqb_page *page)
> +{
> +	return page_to_nid(&page->page);
> +}

etc. you got a lot of wrappers...

> +static inline struct slqb_page *alloc_slqb_pages_node(int nid, gfp_t flags,
> +						unsigned int order)
> +{
> +	struct page *p;
> +
> +	if (nid == -1)
> +		p = alloc_pages(flags, order);
> +	else
> +		p = alloc_pages_node(nid, flags, order);

alloc_pages_nodes does that check anyways.


> +/* Not all arches define cache_line_size */
> +#ifndef cache_line_size
> +#define cache_line_size()	L1_CACHE_BYTES
> +#endif
> +

They should. better fix them?


> +
> +	/*
> +	 * Determine which debug features should be switched on
> +	 */

It would be nicer if you could use long options. At least for me
that would increase the probability that I could remember them
without having to look them up.

> +/*
> + * Allocate a new slab, set up its object list.
> + */
> +static struct slqb_page *new_slab_page(struct kmem_cache *s, gfp_t flags, int node, unsigned int colour)
> +{
> +	struct slqb_page *page;
> +	void *start;
> +	void *last;
> +	void *p;
> +
> +	BUG_ON(flags & GFP_SLAB_BUG_MASK);
> +
> +	page = allocate_slab(s,
> +		flags & (GFP_RECLAIM_MASK | GFP_CONSTRAINT_MASK), node);
> +	if (!page)
> +		goto out;
> +
> +	page->flags |= PG_SLQB_BIT;
> +
> +	start = page_address(&page->page);
> +
> +	if (unlikely(slab_poison(s)))
> +		memset(start, POISON_INUSE, PAGE_SIZE << s->order);
> +
> +	start += colour;

One thing i was wondering. Did you try to disable the colouring and see
if it makes much difference on modern systems? They tend to have either
larger caches or higher associativity caches.

Or perhaps it could be made optional based on CPU type?


> +static noinline void *__slab_alloc_page(struct kmem_cache *s, gfp_t gfpflags, int node)
> +{
> +	struct slqb_page *page;
> +	struct kmem_cache_list *l;
> +	struct kmem_cache_cpu *c;
> +	unsigned int colour;
> +	void *object;
> +
> +	c = get_cpu_slab(s, smp_processor_id());
> +	colour = c->colour_next;
> +	c->colour_next += s->colour_off;
> +	if (c->colour_next >= s->colour_range)
> +		c->colour_next = 0;
> +
> +	/* XXX: load any partial? */
> +
> +	/* Caller handles __GFP_ZERO */
> +	gfpflags &= ~__GFP_ZERO;
> +
> +	if (gfpflags & __GFP_WAIT)
> +		local_irq_enable();

At least on P4 you could get some win by avoiding the local_irq_save() up in the fast
path when __GFP_WAIT is set (because storing the eflags is very expensive there)

> +
> +again:
> +	local_irq_save(flags);
> +	object = __slab_alloc(s, gfpflags, node);
> +	local_irq_restore(flags);
> +
> +	if (unlikely(slab_debug(s)) && likely(object)) {

AFAIK gcc cannot process multiple likelys in a single condition.

> +/* Initial slabs */
> +#ifdef CONFIG_SMP
> +static struct kmem_cache_cpu kmem_cache_cpus[NR_CPUS];
> +#endif
> +#ifdef CONFIG_NUMA
> +static struct kmem_cache_node kmem_cache_nodes[MAX_NUMNODES];
> +#endif
> +
> +#ifdef CONFIG_SMP
> +static struct kmem_cache kmem_cpu_cache;
> +static struct kmem_cache_cpu kmem_cpu_cpus[NR_CPUS];
> +#ifdef CONFIG_NUMA
> +static struct kmem_cache_node kmem_cpu_nodes[MAX_NUMNODES];
> +#endif
> +#endif
> +
> +#ifdef CONFIG_NUMA
> +static struct kmem_cache kmem_node_cache;
> +static struct kmem_cache_cpu kmem_node_cpus[NR_CPUS];
> +static struct kmem_cache_node kmem_node_nodes[MAX_NUMNODES];
> +#endif

That all needs fixing too of course.

> +
> +#ifdef CONFIG_SMP
> +static struct kmem_cache_cpu *alloc_kmem_cache_cpu(struct kmem_cache *s, int cpu)
> +{
> +	struct kmem_cache_cpu *c;
> +
> +	c = kmem_cache_alloc_node(&kmem_cpu_cache, GFP_KERNEL, cpu_to_node(cpu));
> +	if (!c)
> +		return NULL;
> +
> +	init_kmem_cache_cpu(s, c);
> +	return c;
> +}
> +
> +static void free_kmem_cache_cpus(struct kmem_cache *s)
> +{
> +	int cpu;
> +
> +	for_each_online_cpu(cpu) {

Is this protected against racing cpu hotplugs? Doesn't look like it. Multiple occurrences.

> +static void cache_trim_worker(struct work_struct *w)
> +{
> +	struct delayed_work *work =
> +		container_of(w, struct delayed_work, work);
> +	struct kmem_cache *s;
> +	int node;
> +
> +	if (!down_read_trylock(&slqb_lock))
> +		goto out;

No counter for this?

> +
> +	/*
> +	 * We are bringing a node online. No memory is availabe yet. We must
> +	 * allocate a kmem_cache_node structure in order to bring the node
> +	 * online.
> +	 */
> +	down_read(&slqb_lock);
> +	list_for_each_entry(s, &slab_caches, list) {
> +		/*
> +		 * XXX: kmem_cache_alloc_node will fallback to other nodes
> +		 *      since memory is not yet available from the node that
> +		 *      is brought up.
> +		 */
> +		if (s->node[nid]) /* could be lefover from last online */
> +			continue;
> +		n = kmem_cache_alloc(&kmem_node_cache, GFP_KERNEL);
> +		if (!n) {
> +			ret = -ENOMEM;

Surely that should panic? I don't think a slab less node will
be very useful later.

> +#ifdef CONFIG_SLQB_SYSFS
> +/*
> + * sysfs API
> + */
> +#define to_slab_attr(n) container_of(n, struct slab_attribute, attr)
> +#define to_slab(n) container_of(n, struct kmem_cache, kobj);
> +
> +struct slab_attribute {
> +	struct attribute attr;
> +	ssize_t (*show)(struct kmem_cache *s, char *buf);
> +	ssize_t (*store)(struct kmem_cache *s, const char *x, size_t count);
> +};
> +
> +#define SLAB_ATTR_RO(_name) \
> +	static struct slab_attribute _name##_attr = __ATTR_RO(_name)
> +
> +#define SLAB_ATTR(_name) \
> +	static struct slab_attribute _name##_attr =  \
> +	__ATTR(_name, 0644, _name##_show, _name##_store)
> +
> +static ssize_t slab_size_show(struct kmem_cache *s, char *buf)
> +{
> +	return sprintf(buf, "%d\n", s->size);
> +}
> +SLAB_ATTR_RO(slab_size);
> +
> +static ssize_t align_show(struct kmem_cache *s, char *buf)
> +{
> +	return sprintf(buf, "%d\n", s->align);
> +}
> +SLAB_ATTR_RO(align);
> +

When you map back to the attribute you can use a index into a table
for the field, saving that many functions?

> +#define STAT_ATTR(si, text) 					\
> +static ssize_t text##_show(struct kmem_cache *s, char *buf)	\
> +{								\
> +	return show_stat(s, buf, si);				\
> +}								\
> +SLAB_ATTR_RO(text);						\
> +
> +STAT_ATTR(ALLOC, alloc);
> +STAT_ATTR(ALLOC_SLAB_FILL, alloc_slab_fill);
> +STAT_ATTR(ALLOC_SLAB_NEW, alloc_slab_new);
> +STAT_ATTR(FREE, free);
> +STAT_ATTR(FREE_REMOTE, free_remote);
> +STAT_ATTR(FLUSH_FREE_LIST, flush_free_list);
> +STAT_ATTR(FLUSH_FREE_LIST_OBJECTS, flush_free_list_objects);
> +STAT_ATTR(FLUSH_FREE_LIST_REMOTE, flush_free_list_remote);
> +STAT_ATTR(FLUSH_SLAB_PARTIAL, flush_slab_partial);
> +STAT_ATTR(FLUSH_SLAB_FREE, flush_slab_free);
> +STAT_ATTR(FLUSH_RFREE_LIST, flush_rfree_list);
> +STAT_ATTR(FLUSH_RFREE_LIST_OBJECTS, flush_rfree_list_objects);
> +STAT_ATTR(CLAIM_REMOTE_LIST, claim_remote_list);
> +STAT_ATTR(CLAIM_REMOTE_LIST_OBJECTS, claim_remote_list_objects);

This really should be table driven, shouldn't it? That would give much
smaller code.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
