Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6EA7C6B004F
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 06:47:12 -0500 (EST)
Date: Wed, 14 Jan 2009 12:47:07 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] SLQB slab allocator
Message-ID: <20090114114707.GA24673@wotan.suse.de>
References: <20090114090449.GE2942@wotan.suse.de> <84144f020901140253s72995188vb35a79501c38eaa3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <84144f020901140253s72995188vb35a79501c38eaa3@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Lin Ming <ming.m.lin@intel.com>, Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 14, 2009 at 12:53:18PM +0200, Pekka Enberg wrote:
> Hi Nick,
> 
> On Wed, Jan 14, 2009 at 11:04 AM, Nick Piggin <npiggin@suse.de> wrote:
> > This is the latest SLQB patch. Since last time, we have imported the sysfs
> > framework from SLUB, and added specific event counters things for SLQB. I
> > had initially been somewhat against this because it makes SLQB depend on
> > another complex subsystem (which itself depends back on the slab allocator).
> > But I guess it is not fundamentally different than /proc, and there needs to
> > be some reporting somewhere. The individual per-slab counters really do make
> > performance analysis much easier. There is a Documentation/vm/slqbinfo.c
> > file, which is a parser adapted from slabinfo.c for SLUB.
> >
> > Fixed some bugs, including a nasty one that was causing remote objects to
> > sneak onto local freelist, which would mean NUMA allocation was basically
> > broken.
> >
> > The NUMA side of things is now much more complete. NUMA policies are obeyed.
> > There is still a known bug where it won't run on a system with CPU-only
> > nodes.
> >
> > CONFIG options are improved.
> >
> > Credit to some of the engineers at Intel for helping run tests, contributing
> > ideas and patches to improve performance and fix bugs.
> >
> > I think it is getting to the point where it is stable and featureful. It
> > really needs to be further proven in the performance area. We'd welcome
> > any performance results or suggestions for tests to run.
> >
> > After this round of review/feedback, I plan to set about getting SLQB merged.
> 
> The code looks sane but I am still bit unhappy it's not a patchset on top of
> SLUB. We've discussed this in the past and you mentioned that the design is
> "completely different." Looking at it, I don't see any fundamental reason we
> can't do a struct kmem_cache_list layer on top of SLUB which would make
> merging of all this much less painful. I mean, at least in the past Linus hasn't
> been too keen on adding yet another slab allocator to the kernel and I must
> say judging from the SLAB -> SLUB experience, I'm not looking forward to it
> either.

Well SLUB has all this stuff in it to attempt to make it "unqueued", or
semi unqueued. None of that is required with SLQB; after the object
queues go away, the rest of SLQB is little more than a per-CPU SLOB with
individual slabs. But also has important differences. It is per-cpu, obeys
NUMA policies strongly, frees unused pages immediately (after they drop
off the object lists done via periodic reaping). Another one of the major
things I specifically avoid for example is higher order allocations.

The core allocator algorithms are so completely different that it is
obviously as different from SLUB as SLUB is from SLAB (apart from peripheral
support code and code structure). So it may as well be a patch against
SLAB.

I will also prefer to maintain it myself because as I've said I don't
really agree with choices made in SLUB (and ergo SLUB developers don't
agree with SLQB).

Note that I'm not trying to be nasty here. Of course I raised objections
to things I don't like, and I don't think I'm right by default. Just IMO
SLUB has some problems. As do SLAB and SLQB of course. Nothing is
perfect.

Also, I don't want to propose replacing any of the other allocators yet,
until more performance data is gathered. People need to compare each one.
SLQB definitely is not a clear winner in all tests. At the moment I want
to see healthy competition and hopefully one day decide on just one of
the main 3.


> Also, to merge this, we need to see numbers. I assume SLQB fixes the
> long-standing SLUB vs. SLAB regression reported by Intel and doesn't
> introduce new performance regressions? Also, it would be nice for me to
> be able to reproduce the numbers, especially for those tests where SLUB
> performs worse.

It is comparable to SLAB on Intel's OLTP test. I don't know exactly
where SLUB lies, but I think it is several % below that.

No big obvious new regressions yet, but of course we won't know that
without a lot more testing. SLQB isn't outright winner in all cases.
For example, on machine A, tbench may be faster with SLAB, but on
machine B it turns out to be faster on SLQB. Another test might show
SLUB is better.

 
> One thing that puzzles me a bit is that in addition to the struct
> kmem_cache_list caching, I also see things like cache coloring, avoiding
> page allocator pass-through, and lots of prefetch hints in the code
> which makes evaluating the performance differences quite difficult. If
> these optimizations *are* a win, then why don't we add them to SLUB?

I don't know. I don't have enough time of day to work on SLQB enough,
let alone attempt to do all this for SLUB as well. Especially when I
think there are fundamental problems with the basic design of it.

None of those optimisations you mention really showed a noticable win
anywhere (except avoiding page allocator pass-through perhaps, simply
because that is not an optimisation, rather it would be a de-optimisation
to *add* page allocator pass-through for SLQB, so maybe it would aslow
down some loads).

Cache colouring was just brought over from SLAB. prefetching was done
by looking at cache misses generally, and attempting to reduce them.
But you end up barely making a significant difference or just pushing
the cost elsewhere really. Down to the level of prefetching it is
going to hugely depend on the exact behaviour of the workload and
the allocator.


> A completely different topic is memory efficiency of SLQB. The current
> situation is that SLOB out-performs SLAB by huge margin whereas SLUB is
> usually quite close. With the introduction of kmemtrace, I'm hopeful
> that we will be able to fix up many of the badly fitting allocations in
> the kernel to narrow the gap between SLUB and SLOB even more and I worry
> SLQB will take us back to the SLAB numbers.

Fundamentally it is more like SLOB and SLUB in that it uses object
pointers and can allocate down to very small sizes. It doesn't have
O(NR_CPUS^2) type behaviours or preallocated array caches like SLAB.
I didn't look closely at memory efficiency, but I have no reason to
think it would be a problem.


> > +/*
> > + * Primary per-cpu, per-kmem_cache structure.
> > + */
> > +struct kmem_cache_cpu {
> > +	struct kmem_cache_list list; /* List for node-local slabs. */
> > +
> > +	unsigned int colour_next;
> 
> Do you see a performance improvement with cache coloring? IIRC,
> Christoph has stated in the past that SLUB doesn't do it because newer
> associative cache designs take care of the issue.

No I haven't seen an improvement.

> > +/*
> > + * Constant size allocations use this path to find index into kmalloc caches
> > + * arrays. get_slab() function is used for non-constant sizes.
> > + */
> > +static __always_inline int kmalloc_index(size_t size)
> > +{
> > +	if (unlikely(!size))
> > +		return 0;
> > +	if (unlikely(size > 1UL << KMALLOC_SHIFT_SLQB_HIGH))
> > +		return 0;
> 
> SLUB doesn't have the above check. Does it fix an actual bug? Should we
> add that to SLUB as well?

I think it is OK because of page allocator passthrough.

 
> > +	if (size <=	 64) return 6;
> > +	if (size <=	128) return 7;
> > +	if (size <=	256) return 8;
> > +	if (size <=	512) return 9;
> > +	if (size <=       1024) return 10;
> > +	if (size <=   2 * 1024) return 11;
> > +	if (size <=   4 * 1024) return 12;
> > +	if (size <=   8 * 1024) return 13;
> > +	if (size <=  16 * 1024) return 14;
> > +	if (size <=  32 * 1024) return 15;
> > +	if (size <=  64 * 1024) return 16;
> > +	if (size <= 128 * 1024) return 17;
> > +	if (size <= 256 * 1024) return 18;
> > +	if (size <= 512 * 1024) return 19;
> > +	if (size <= 1024 * 1024) return 20;
> > +	if (size <=  2 * 1024 * 1024) return 21;
> > +	return -1;
> 
> I suppose we could just make this one return zero and drop the above
> check?

I guess so... although this is for the constant folded path anyway,
so efficiency is not an issue.

 
> > +#define KMALLOC_HEADER (ARCH_KMALLOC_MINALIGN < sizeof(void *) ? sizeof(void *) : ARCH_KMALLOC_MINALIGN)
> > +
> > +static __always_inline void *kmalloc(size_t size, gfp_t flags)
> > +{
> 
> So no page allocator pass-through, why is that? Looking at commit
> aadb4bc4a1f9108c1d0fbd121827c936c2ed4217 ("SLUB: direct pass through of
> page size or higher kmalloc requests"), I'd assume SQLB would get many
> of the same benefits as well? It seems like a bad idea to hang on onto
> large chuncks of pages in caches, no?

I don't think so. From that commit:

   Advantages:
    - Reduces memory overhead for kmalloc array

Fair point. But I'm attempting to compete primarily with SLAB than SLOB.

    - Large kmalloc operations are faster since they do not
      need to pass through the slab allocator to get to the
      page allocator.

SLQB is faster than the page allocator.

    - Performance increase of 10%-20% on alloc and 50% on free for
      PAGE_SIZEd allocations.
      SLUB must call page allocator for each alloc anyways since
      the higher order pages which that allowed avoiding the page alloc calls
      are not available in a reliable way anymore. So we are basically removing
      useless slab allocator overhead.

SLQB is more like SLAB in this regard so it doesn't have this problme.

    - Large kmallocs yields page aligned object which is what
      SLAB did. Bad things like using page sized kmalloc allocations to
      stand in for page allocate allocs can be transparently handled and are not
      distinguishable from page allocator uses.

I don't understand this one. Definitely SLQB should give page aligned
objects for large kmallocs too.

    - Checking for too large objects can be removed since
      it is done by the page allocator.

But the check is made for size > PAGE_SIZE anyway, so I don't see the
win.

    Drawbacks:
    - No accounting for large kmalloc slab allocations anymore
    - No debugging of large kmalloc slab allocations.

And doesn't suffer these drawbacks either of course.

> > +/*
> > + * slqb_page overloads struct page, and is used to manage some slob allocation
> > + * aspects, however to avoid the horrible mess in include/linux/mm_types.h,
> > + * we'll just define our own struct slqb_page type variant here.
> > + */
> 
> You say horrible mess, I say convenient. I think it's good that core vm
> hackers who have no interest in the slab allocator can clearly see we're
> overloading some of the struct page fields.

Yeah, but you can't really. There are so many places that overload them
for different things and don't tell you about it right in that file. But
it mostly works because we have nice layering and compartmentalisation.

Anyway IIRC my initial patches to do some of these conversions actually
either put the definitions into mm_types.h or at least added references
to them in mm_types.h. It is the better way to go really because you get
better type checking and it is readable. You may say the horrible mess is
readable. Barely. Imagine how it would be if we put everything in there.


> But as SLOB does it like
> this as well, I suppose we can keep it as-is.

I added that ;)

 
> > +struct slqb_page {
> > +	union {
> > +		struct {
> > +			unsigned long flags;	/* mandatory */
> > +			atomic_t _count;	/* mandatory */
> > +			unsigned int inuse;	/* Nr of objects */
> > +		   	struct kmem_cache_list *list; /* Pointer to list */
> > +			void **freelist;	/* freelist req. slab lock */
> > +			union {
> > +				struct list_head lru; /* misc. list */
> > +				struct rcu_head rcu_head; /* for rcu freeing */
> > +			};
> > +		};
> > +		struct page page;
> > +	};
> > +};
> > +static inline void struct_slqb_page_wrong_size(void)
> > +{ BUILD_BUG_ON(sizeof(struct slqb_page) != sizeof(struct page)); }
> > +
> > +#define PG_SLQB_BIT (1 << PG_slab)
> > +
> > +static int kmem_size __read_mostly;
> > +#ifdef CONFIG_NUMA
> > +static int numa_platform __read_mostly;
> > +#else
> > +#define numa_platform 0
> > +#endif
> 
> Hmm, why do we want to do this? If someone is running a CONFIG_NUMA
> kernel on an UMA machine, let them suffer?

Distros, mainly. SLAB does the same thing of course. There is a tiny
downside for the NUMA case (not measurable, but obviously another branch).
Not worth another config option, although I guess there could be a
config option to basically say "this config is exactly my machine; not
the maximum capabilities of a machine intended to run on this kernel".
That could be useful to everyone, including here.


> And if we *do* need to do this, can we move numa_platform() logic out of
> the memory allocator?

Possible. If it is moved out of SLAB it would make my life (slightly)
easier

 
> > +#ifdef CONFIG_SMP
> > +/*
> > + * If enough objects have been remotely freed back to this list,
> > + * remote_free_check will be set. In which case, we'll eventually come here
> > + * to take those objects off our remote_free list and onto our LIFO freelist.
> > + *
> > + * Caller must be the owner CPU in the case of per-CPU list, or hold the node's
> > + * list_lock in the case of per-node list.
> > + */
> > +static void claim_remote_free_list(struct kmem_cache *s, struct kmem_cache_list *l)
> > +{
> > +	void **head, **tail;
> > +	int nr;
> > +
> > +	VM_BUG_ON(!l->remote_free.list.head != !l->remote_free.list.tail);
> > +
> > +	if (!l->remote_free.list.nr)
> > +		return;
> > +
> > +	l->remote_free_check = 0;
> > +	head = l->remote_free.list.head;
> > +	prefetchw(head);
> 
> So this prefetchw() is for flush_free_list(), right? A comment would be
> nice.

Either the flush or the next allocation, whichever comes first.

Added a comment.
 

> > +static __always_inline void *__cache_list_get_object(struct kmem_cache *s, struct kmem_cache_list *l)
> > +{
> > +	void *object;
> > +
> > +	object = l->freelist.head;
> > +	if (likely(object)) {
> > +		void *next = get_freepointer(s, object);
> > +		VM_BUG_ON(!l->freelist.nr);
> > +		l->freelist.nr--;
> > +		l->freelist.head = next;
> > +		if (next)
> > +			prefetchw(next);
> 
> Why do we need this prefetchw() here?

For the next allocation call. But TBH I have not seen a significant
difference in any test. I alternate from commenting it out and not.
I guess when in doubt there should be less code and complexity...

> > +			if (next)
> > +				prefetchw(next);
> 
> Or here?

Ditto.

 
> > +
> > +	object = page->freelist;
> > +	page->freelist = get_freepointer(s, object);
> > +	if (page->freelist)
> > +		prefetchw(page->freelist);
> 
> I don't understand this prefetchw(). Who exactly is going to be updating
> contents of page->freelist?

Again, it is for the next allocation. This was shown to reduce cache
misses here in IIRC tbench, but I'm not sure if that translated to a
significant performance improvement.

An alternate approach I have is a patch called "batchfeed", which
basically loads the entire page freelist in this path. But it cost
complexity and the last free word in struct page (which could be
gained back at the cost of yet more complexity). So I'm still on
the fence with this. I will have to take reports of regressions and
see if things like this help.


> > +/*
> > + * Perform some interrupts-on processing around the main allocation path
> > + * (debug checking and memset()ing).
> > + */
> > +static __always_inline void *slab_alloc(struct kmem_cache *s,
> > +		gfp_t gfpflags, int node, void *addr)
> > +{
> > +	void *object;
> > +	unsigned long flags;
> > +
> > +again:
> > +	local_irq_save(flags);
> > +	object = __slab_alloc(s, gfpflags, node);
> > +	local_irq_restore(flags);
> > +
> 
> As a cleanup, you could just do:
> 
>     if (unlikely(object == NULL))
>             return NULL;
> 
> here to avoid the double comparison. Maybe it even generates better asm.

Sometimes the stupid compiler loads a new literal to return with code
like this. I'll see.

> 
> > +	if (unlikely(slab_debug(s)) && likely(object)) {
> > +		if (unlikely(!alloc_debug_processing(s, object, addr)))
> > +			goto again;
> > +	}
> > +
> > +	if (unlikely(gfpflags & __GFP_ZERO) && likely(object))
> > +		memset(object, 0, s->objsize);
> > +
> > +	return object;
> > +}
> > +
> > +void *kmem_cache_alloc(struct kmem_cache *s, gfp_t gfpflags)
> > +{
> > +	int node = -1;
> > +#ifdef CONFIG_NUMA
> > +	if (unlikely(current->flags & (PF_SPREAD_SLAB | PF_MEMPOLICY)))
> > +		node = alternate_nid(s, gfpflags, node);
> > +#endif
> > +	return slab_alloc(s, gfpflags, node, __builtin_return_address(0));
> 
> The return address is wrong when kmem_cache_alloc() is called through
> __kmalloc().

Ah, good catch.

 
> As a side note, you can use the shorter _RET_IP_ instead of
> builtin_return_address(0) everywhere.

OK.

Thanks for the comments and discussion so far.

Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
