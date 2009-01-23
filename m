Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4DD696B0055
	for <linux-mm@kvack.org>; Fri, 23 Jan 2009 06:26:06 -0500 (EST)
Date: Fri, 23 Jan 2009 12:25:55 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] SLQB slab allocator
Message-ID: <20090123112555.GF19986@wotan.suse.de>
References: <20090121143008.GV24891@wotan.suse.de> <87hc3qcpo1.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87hc3qcpo1.fsf@basil.nowhere.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Christoph Lameter <clameter@engr.sgi.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 23, 2009 at 10:55:26AM +0100, Andi Kleen wrote:
> Nick Piggin <npiggin@suse.de> writes:
> 
> Not a full review, just some things i noticed.
> 
> The code is very readable thanks (that's imho the main reason slab.c
> should go btw, it's really messy and hard to get through)

Thanks, appreciated. It is very helpful.

 
> > Using lists rather than arrays can reduce the cacheline footprint. When moving
> > objects around, SLQB can move a list of objects from one CPU to another by
> > simply manipulating a head pointer, wheras SLAB needs to memcpy arrays. Some
> > SLAB per-CPU arrays can be up to 1K in size, which is a lot of cachelines that
> > can be touched during alloc/free. Newly freed objects tend to be cache hot,
> > and newly allocated ones tend to soon be touched anyway, so often there is
> > little cost to using metadata in the objects.
> 
> You're probably aware of that, but the obvious counter argument
> is that for manipulating a single object a double linked
> list will always require touching three cache lines
> (prev, current, next), while an array access only a single one.
> A possible alternative would be a list of shorter arrays.

That's true, but SLQB doesn't use double linked lists, but single.
An allocation needs to load a "head" pointer to the first object, then
load a "next" pointer from that object and assign it to "head". The
2nd load touches memory which should be subsequently touched bythe
caller anyway. A free just has to assign a pointer in the to-be-freed
object to point to the old head, and then update the head to the new
object. So this 1st touch should usually be cache hot memory.

But yes there are situations where SLAB scheme could result in
fewer cache misses. I haven't yet noticed it is a problem.


> > +	const char *name;	/* Name (only for display!) */
> > +	struct list_head list;	/* List of slab caches */
> > +
> > +	int align;		/* Alignment */
> > +	int inuse;		/* Offset to metadata */
> 
> I suspect some of these fields could be short or char (E.g. alignment),
> possibly lowering cache line impact.

Good point. I'll have to do a pass through all structures and
make sure sizes and alignments etc are optimal. I have somewhat
ordered it eg. so that LIFO freelist allocations only have to
touch the first few fields in structures, then partial page
list allocations touch the next few, then page allocator etc.

But that might have gone out of date a little bit.


> > +#ifdef CONFIG_SLQB_SYSFS
> > +	struct kobject kobj;	/* For sysfs */
> > +#endif
> > +#ifdef CONFIG_NUMA
> > +	struct kmem_cache_node *node[MAX_NUMNODES];
> > +#endif
> > +#ifdef CONFIG_SMP
> > +	struct kmem_cache_cpu *cpu_slab[NR_CPUS];
> 
> Those both really need to be dynamically allocated, otherwise
> it wastes a lot of memory in the common case
> (e.g. NR_CPUS==128 kernel on dual core system). And of course
> on the proposed NR_CPUS==4096 kernels it becomes prohibitive.
> 
> You could use alloc_percpu? There's no alloc_pernode 
> unfortunately, perhaps there should be one. 

cpu_slab is dynamically allocated, by just changing the size of
the kmem_cache cache at boot time. Probably the best way would
be to have dynamic cpu and node allocs for them, I agree.

Any plans for an alloc_pernode?


> > +	if (size <=  2 * 1024 * 1024) return 21;
> 
> Have you looked into other binsizes?  iirc the original slab paper
> mentioned that power of two is usually not the best.

No I haven't. Although I have been spending most effort at this
point just to improve SLQB versus the other allocators without
changing things like this. But it would be fine to investigate
when SLQB is more mature or for somebody else to look at it.

> > +/*
> > + * Find the kmalloc slab cache for a given combination of allocation flags and
> > + * size.
> 
> You should mention that this would be a very bad idea to call for !__builtin_constant_p(size)

OK. It's not meant to be used outside slqb_def.h, however.


> > +static __always_inline struct kmem_cache *kmalloc_slab(size_t size, gfp_t flags)
> > +{
> > +	int index = kmalloc_index(size);
> > +
> > +	if (unlikely(index == 0))
> > +		return NULL;
> > +
> > +	if (likely(!(flags & SLQB_DMA)))
> > +		return &kmalloc_caches[index];
> > +	else
> > +		return &kmalloc_caches_dma[index];
> 
> BTW i had an old patchkit to kill all GFP_DMA slab users. Perhaps should
> warm that up again. That would lower the inline footprint.

That would be excellent. It would also reduce constant data overheads
for SLAB and SLQB, and some nasty code from SLUB.


> > +#ifdef CONFIG_NUMA
> > +void *__kmalloc_node(size_t size, gfp_t flags, int node);
> > +void *kmem_cache_alloc_node(struct kmem_cache *, gfp_t flags, int node);
> > +
> > +static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
> 
> kmalloc_node should be infrequent, i suspect it can be safely out of lined.

Hmm... I wonder how much it increases code size...


> > + * - investiage performance with memoryless nodes. Perhaps CPUs can be given
> > + *   a default closest home node via which it can use fastpath functions.
> 
> FWIW that is what x86-64 always did. Perhaps you can just fix ia64 to do 
> that too and be happy.

What if the node is possible but not currently online?

 
> > + * aspects, however to avoid the horrible mess in include/linux/mm_types.h,
> > + * we'll just define our own struct slqb_page type variant here.
> 
> Hopefully this works for the crash dumpers. Do they have a way to distingush
> slub/slqb/slab kernels with different struct page usage?

Beyond looking at configs or hacks like looking at symbols, I don't
think so... It probably should go into vermagic I guess.


> > +#define PG_SLQB_BIT (1 << PG_slab)
> > +
> > +static int kmem_size __read_mostly;
> > +#ifdef CONFIG_NUMA
> > +static int numa_platform __read_mostly;
> > +#else
> > +#define numa_platform 0
> > +#endif
> 
> It would be cheaper if you put that as a flag into the kmem_caches flags, this
> way you avoid an additional cache line touched.

Ok, that works.

 
> > +static inline int slqb_page_to_nid(struct slqb_page *page)
> > +{
> > +	return page_to_nid(&page->page);
> > +}
> 
> etc. you got a lot of wrappers...

I think they're not too bad though.

 
> > +static inline struct slqb_page *alloc_slqb_pages_node(int nid, gfp_t flags,
> > +						unsigned int order)
> > +{
> > +	struct page *p;
> > +
> > +	if (nid == -1)
> > +		p = alloc_pages(flags, order);
> > +	else
> > +		p = alloc_pages_node(nid, flags, order);
> 
> alloc_pages_nodes does that check anyways.

OK, I rip out that wrapper completely.


> > +/* Not all arches define cache_line_size */
> > +#ifndef cache_line_size
> > +#define cache_line_size()	L1_CACHE_BYTES
> > +#endif
> > +
> 
> They should. better fix them?

git grep -l -e cache_line_size arch/ | egrep '\.h$'

Only ia64, mips, powerpc, sparc, x86...

> > +	/*
> > +	 * Determine which debug features should be switched on
> > +	 */
> 
> It would be nicer if you could use long options. At least for me
> that would increase the probability that I could remember them
> without having to look them up.

I haven't looked closely at the debug code which is mostly straight
out of SLUB and minimal changes to get it working. Of course it is
very important, but useless if the core allocator isn't good. I
also don't want to diverge from SLUB in these areas if possible until
we reduce the number of allocators in the tree...

Long options is probably not a bad idea, though.


> > +	if (unlikely(slab_poison(s)))
> > +		memset(start, POISON_INUSE, PAGE_SIZE << s->order);
> > +
> > +	start += colour;
> 
> One thing i was wondering. Did you try to disable the colouring and see
> if it makes much difference on modern systems? They tend to have either
> larger caches or higher associativity caches.

I have tried, but I don't think I found a test where it made a
statistically significant difference. It is not very costly to
implement, though.

 
> Or perhaps it could be made optional based on CPU type?

It could easily be changed, yes.


 
> > +
> > +again:
> > +	local_irq_save(flags);
> > +	object = __slab_alloc(s, gfpflags, node);
> > +	local_irq_restore(flags);
> 
> At least on P4 you could get some win by avoiding the local_irq_save() up in the fast
> path when __GFP_WAIT is set (because storing the eflags is very expensive there)

That's a good point, although also something trivially applicable to
all allocators and as such I prefer not to add such differences to
the SLQB patch if we are going into an evaluation phase.


> > +/* Initial slabs */
> > +#ifdef CONFIG_SMP
> > +static struct kmem_cache_cpu kmem_cache_cpus[NR_CPUS];
> > +#endif
> > +#ifdef CONFIG_NUMA
> > +static struct kmem_cache_node kmem_cache_nodes[MAX_NUMNODES];
> > +#endif
> > +
> > +#ifdef CONFIG_SMP
> > +static struct kmem_cache kmem_cpu_cache;
> > +static struct kmem_cache_cpu kmem_cpu_cpus[NR_CPUS];
> > +#ifdef CONFIG_NUMA
> > +static struct kmem_cache_node kmem_cpu_nodes[MAX_NUMNODES];
> > +#endif
> > +#endif
> > +
> > +#ifdef CONFIG_NUMA
> > +static struct kmem_cache kmem_node_cache;
> > +static struct kmem_cache_cpu kmem_node_cpus[NR_CPUS];
> > +static struct kmem_cache_node kmem_node_nodes[MAX_NUMNODES];
> > +#endif
> 
> That all needs fixing too of course.

Hmm. I was hoping it could stay simple as it is just a static constant
(for a given NR_CPUS) overhead. I wonder if bootmem is still up here?
How fine grained is it these days? 

Could bite the bullet and do a multi-stage bootstap like SLUB, but I
want to try avoiding that (but init code is also of course much less
important than core code and total overheads). 


> > +static void free_kmem_cache_cpus(struct kmem_cache *s)
> > +{
> > +	int cpu;
> > +
> > +	for_each_online_cpu(cpu) {
> 
> Is this protected against racing cpu hotplugs? Doesn't look like it. Multiple occurrences.

I think you're right.

 
> > +static void cache_trim_worker(struct work_struct *w)
> > +{
> > +	struct delayed_work *work =
> > +		container_of(w, struct delayed_work, work);
> > +	struct kmem_cache *s;
> > +	int node;
> > +
> > +	if (!down_read_trylock(&slqb_lock))
> > +		goto out;
> 
> No counter for this?

It's quite unimportant. It will only race with creating or destroying
actual kmem caches, and cache trimming is infrequent too.


> > +	down_read(&slqb_lock);
> > +	list_for_each_entry(s, &slab_caches, list) {
> > +		/*
> > +		 * XXX: kmem_cache_alloc_node will fallback to other nodes
> > +		 *      since memory is not yet available from the node that
> > +		 *      is brought up.
> > +		 */
> > +		if (s->node[nid]) /* could be lefover from last online */
> > +			continue;
> > +		n = kmem_cache_alloc(&kmem_node_cache, GFP_KERNEL);
> > +		if (!n) {
> > +			ret = -ENOMEM;
> 
> Surely that should panic? I don't think a slab less node will
> be very useful later.

Returning error here I think will just fail the online operation?
Better than a panic :)


> > +static ssize_t align_show(struct kmem_cache *s, char *buf)
> > +{
> > +	return sprintf(buf, "%d\n", s->align);
> > +}
> > +SLAB_ATTR_RO(align);
> > +
> 
> When you map back to the attribute you can use a index into a table
> for the field, saving that many functions?
> 
> > +STAT_ATTR(CLAIM_REMOTE_LIST, claim_remote_list);
> > +STAT_ATTR(CLAIM_REMOTE_LIST_OBJECTS, claim_remote_list_objects);
> 
> This really should be table driven, shouldn't it? That would give much
> smaller code.

Tables probably would help. I will keep it close to SLUB for now,
though.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
