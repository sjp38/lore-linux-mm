Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4F6146B0044
	for <linux-mm@kvack.org>; Wed, 21 Jan 2009 09:59:35 -0500 (EST)
Date: Wed, 21 Jan 2009 15:59:18 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch] SLQB slab allocator
Message-ID: <20090121145918.GA11311@elte.hu>
References: <20090121143008.GV24891@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090121143008.GV24891@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Christoph Lameter <clameter@engr.sgi.com>
List-ID: <linux-mm.kvack.org>


* Nick Piggin <npiggin@suse.de> wrote:

> +/*
> + * Management object for a slab cache.
> + */
> +struct kmem_cache {
> +	unsigned long flags;
> +	int hiwater;		/* LIFO list high watermark */
> +	int freebatch;		/* LIFO freelist batch flush size */
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

Mind if i nitpick a bit about minor style issues? Since this is going to 
be the next Linux SLAB allocator we might as well do it perfectly :-)

When intoducing new structures it makes sense to properly vertical align 
them, like:

> +	unsigned long		flags;
> +	int			hiwater;	/* LIFO list high watermark  */
> +	int			freebatch;	/* LIFO freelist batch flush size */
> +	int			objsize;	/* Object size without meta data  */
> +	int			offset;		/* Free pointer offset       */
> +	int			objects;	/* Number of objects in slab */
> +	const char		*name;		/* Name (only for display!)  */
> +	struct list_head	list;		/* List of slab caches       */
> +
> +	int			align;		/* Alignment                 */
> +	int			inuse;		/* Offset to metadata        */

because proper vertical alignment/lineup can really help readability.
Like you do it yourself here:

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

> +static void slab_err(struct kmem_cache *s, struct slqb_page *page, char *fmt, ...)
> +{
> +	va_list args;
> +	char buf[100];

magic constant.

> +	if (s->flags & SLAB_RED_ZONE)
> +		memset(p + s->objsize,
> +			active ? SLUB_RED_ACTIVE : SLUB_RED_INACTIVE,
> +			s->inuse - s->objsize);

We tend to add curly braces in such multi-line statement situations i 
guess.

> +static void trace(struct kmem_cache *s, struct slqb_page *page, void *object, int alloc)
> +{
> +	if (s->flags & SLAB_TRACE) {
> +		printk(KERN_INFO "TRACE %s %s 0x%p inuse=%d fp=0x%p\n",
> +			s->name,
> +			alloc ? "alloc" : "free",
> +			object, page->inuse,
> +			page->freelist);

Could use ftrace_printk() here i guess. That way it goes into a fast 
ringbuffer and not printk and it also gets embedded into whatever tracer 
plugin there is active. (for example kmemtrace)


> +static void setup_object_debug(struct kmem_cache *s, struct slqb_page *page,
> +								void *object)

there's a trick that can be done here to avoid the col-80 artifact:

static void
setup_object_debug(struct kmem_cache *s, struct slqb_page *page, void *object)

ditto all these prototypes:

> +static int alloc_debug_processing(struct kmem_cache *s, void *object, void *addr)
> +static int free_debug_processing(struct kmem_cache *s, void *object, void *addr)
> +static unsigned long kmem_cache_flags(unsigned long objsize,
> +	unsigned long flags, const char *name,
> +	void (*ctor)(void *))
> +static inline void setup_object_debug(struct kmem_cache *s,
> +			struct slqb_page *page, void *object) {}
> +static inline int alloc_debug_processing(struct kmem_cache *s,
> +	void *object, void *addr) { return 0; }
> +static inline int free_debug_processing(struct kmem_cache *s,
> +	void *object, void *addr) { return 0; }
> +static inline int check_object(struct kmem_cache *s, struct slqb_page *page,
> +			void *object, int active) { return 1; }
> +static inline unsigned long kmem_cache_flags(unsigned long objsize,
> +	unsigned long flags, const char *name, void (*ctor)(void *))

> +#define slqb_debug 0

should be 'static const int slqb_debug;' i guess?

more function prototype inconsistencies:

> +static struct slqb_page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
> +static void setup_object(struct kmem_cache *s, struct slqb_page *page,
> +				void *object)
> +static struct slqb_page *new_slab_page(struct kmem_cache *s, gfp_t flags, int node, unsigned int colour)
> +static int free_object_to_page(struct kmem_cache *s, struct kmem_cache_list *l, struct slqb_page *page, void *object)

> +#ifdef CONFIG_SMP
> +static noinline void slab_free_to_remote(struct kmem_cache *s, struct slqb_page *page, void *object, struct kmem_cache_cpu *c);
> +#endif

does noline have to be declared?

i almost missed the lock taking here:

> +	spin_lock(&l->remote_free.lock);
> +	l->remote_free.list.head = NULL;
> +	tail = l->remote_free.list.tail;
> +	l->remote_free.list.tail = NULL;
> +	nr = l->remote_free.list.nr;
> +	l->remote_free.list.nr = 0;
> +	spin_unlock(&l->remote_free.lock);

Putting an extra newline after the spin_lock() and one extra newline 
before the spin_unlock() really helps raise attention to critical 
sections.

various leftover bits:

> +//		if (next)
> +//			prefetchw(next);

> +//			if (next)
> +//				prefetchw(next);

> +		list_del(&page->lru);
> +/*XXX		list_move(&page->lru, &l->full); */

> +//	VM_BUG_ON(node != -1 && node != slqb_page_to_nid(page));

overlong prototype:

> +static noinline void *__slab_alloc_page(struct kmem_cache *s, gfp_t gfpflags, int node)

putting the newline elsewhere would improve this too:

> +static noinline void *__remote_slab_alloc(struct kmem_cache *s,
> +		gfp_t gfpflags, int node)

leftover:

> +//	if (unlikely(!(l->freelist.nr | l->nr_partial | l->remote_free_check)))
> +//		return NULL;

newline in wrong place:

> +static __always_inline void *__slab_alloc(struct kmem_cache *s,
> +		gfp_t gfpflags, int node)

> +static __always_inline void *slab_alloc(struct kmem_cache *s,
> +		gfp_t gfpflags, int node, void *addr)

> +static __always_inline void *__kmem_cache_alloc(struct kmem_cache *s, gfp_t gfpflags, void *caller)

> +#ifdef CONFIG_SLQB_STATS
> +	{
> +		struct kmem_cache_list *l = &c->list;
> +		slqb_stat_inc(l, FLUSH_RFREE_LIST);
> +		slqb_stat_add(l, FLUSH_RFREE_LIST_OBJECTS, nr);

Please put a newline after local variable declarations.

newline in another place could improve this:

> +static __always_inline void __slab_free(struct kmem_cache *s,
> +		struct slqb_page *page, void *object)

> +#ifdef CONFIG_NUMA
> +	} else {
> +		/*
> +		 * Freeing an object that was allocated on a remote node.
> +		 */
> +		slab_free_to_remote(s, page, object, c);
> +		slqb_stat_inc(l, FREE_REMOTE);
> +#endif
> +	}

while it's correct code, the CONFIG_NUMA ifdef begs to be placed one line 
further down.

newline in another place could improve this:

> +static __always_inline void slab_free(struct kmem_cache *s,
> +		struct slqb_page *page, void *object)

> +void kmem_cache_free(struct kmem_cache *s, void *object)
> +{
> +	struct slqb_page *page = NULL;
> +	if (numa_platform)
> +		page = virt_to_head_slqb_page(object);

newline after local variable definition please.

> +static inline int slab_order(int size, int max_order, int frac)
> +{
> +	int order;
> +
> +	if (fls(size - 1) <= PAGE_SHIFT)
> +		order = 0;
> +	else
> +		order = fls(size - 1) - PAGE_SHIFT;
> +	while (order <= max_order) {

Please put a newline before loops, so that they stand out better.

> +static inline int calculate_order(int size)
> +{
> +	int order;
> +
> +	/*
> +	 * Attempt to find best configuration for a slab. This
> +	 * works by first attempting to generate a layout with
> +	 * the best configuration and backing off gradually.
> +	 */
> +	order = slab_order(size, 1, 4);
> +	if (order <= 1)
> +		return order;
> +
> +	/*
> +	 * This size cannot fit in order-1. Allow bigger orders, but
> +	 * forget about trying to save space.
> +	 */
> +	order = slab_order(size, MAX_ORDER, 0);
> +	if (order <= MAX_ORDER)
> +		return order;
> +
> +	return -ENOSYS;
> +}

function with very nice typographics. All should be like this.

> +	if (flags & SLAB_HWCACHE_ALIGN) {
> +		unsigned long ralign = cache_line_size();
> +		while (size <= ralign / 2)
> +			ralign /= 2;

newline after variables please.

> +static void init_kmem_cache_list(struct kmem_cache *s, struct kmem_cache_list *l)
> +{
> +	l->cache = s;
> +	l->freelist.nr = 0;
> +	l->freelist.head = NULL;
> +	l->freelist.tail = NULL;
> +	l->nr_partial = 0;
> +	l->nr_slabs = 0;
> +	INIT_LIST_HEAD(&l->partial);
> +//	INIT_LIST_HEAD(&l->full);

leftover. Also, initializations tend to read nicer if they are aligned 
like this:

> +	l->cache			= s;
> +	l->freelist.nr			= 0;
> +	l->freelist.head		= NULL;
> +	l->freelist.tail		= NULL;
> +	l->nr_partial			= 0;
> +	l->nr_slabs			= 0;
> +
> +#ifdef CONFIG_SMP
> +	l->remote_free_check		= 0;
> +	spin_lock_init(&l->remote_free.lock);
> +	l->remote_free.list.nr		= 0;
> +	l->remote_free.list.head	= NULL;
> +	l->remote_free.list.tail	= NULL;
> +#endif

As this way it really stands out that the only relevant non-zero 
initializations are l->cache and the spinlock init.

> +static void init_kmem_cache_cpu(struct kmem_cache *s,
> +			struct kmem_cache_cpu *c)

prototype newline.

dead code:

> +#if 0 // XXX: see cpu offline comment
> +	down_read(&slqb_lock);
> +	list_for_each_entry(s, &slab_caches, list) {
> +		struct kmem_cache_node *n;
> +		n = s->node[nid];
> +		if (n) {
> +			s->node[nid] = NULL;
> +			kmem_cache_free(&kmem_node_cache, n);
> +		}
> +	}
> +	up_read(&slqb_lock);
> +#endif

... and many more similar instances are in the patch in other places.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
