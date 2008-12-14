Return-Path: <owner-linux-mm@kvack.org>
Date: Mon, 15 Dec 2008 00:04:07 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch] SLQB slab allocator
Message-ID: <20081214230407.GB7318@wotan.suse.de>
References: <20081212002518.GH8294@wotan.suse.de> <Pine.LNX.4.64.0812122013390.15781@quilx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0812122013390.15781@quilx.com>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, bcrl@kvack.org, list-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Dec 12, 2008 at 08:34:35PM -0600, Christoph Lameter wrote:
> On Fri, 12 Dec 2008, Nick Piggin wrote:
> 
> > + * SLQB : A slab allocator with object queues.
> > + *
> > + * (C) 2008 Nick Piggin <npiggin@suse.de>
> 
> My copyright notice is missing. Most of this is directly copied from SLUB.

I did definitely attribute sources.... ah, you noticed further down.


> And I am not CCed? What should I be thinking?

Linux-mm is cc'ed and you're subscribed, right? linux-mm has good S/N,
so I get lazy with cc lists if my audience is subscribed there ;) No
ill intention.


> > +/*
> > + * SLQB: A slab allocator that focuses on per-CPU scaling, and good performance
> > + * with order-0 allocations. Fastpaths emphasis is placed on local allocaiton
> > + * and freeing, but with a secondary goal of good remote freeing (freeing on
> > + * another CPU from that which allocated).
> 
> Good idea. I like new ideas based on SLUB.

Well, thanks. The core allocator is more based on SLAB, but with linked
list of objects from SLOB, rather than arrays. But whatever; it is what
it is.

Actually, the boot-time debugging idea is from SLUB, which is useful. 
 

> > + *
> > + * Using ideas and code from mm/slab.c, mm/slob.c, and mm/slub.c.
> 
> Thats not right. The code was copied from mm/slub.c and then modified.

I definitely took ideas and code from mm/slab.c, and ideas if not
code from mm/slob.c too so I need to attribute them as well.

 
> It seems that the SLUB skeleton is very useful. Maybe we could abstract
> the common code out in order to make more creative variants possible in
> the future?

I think it wasn't hard to take the code and change it.

 
> > +/*
> > + * Issues still to be resolved:
> > + *
> > + * - Support PAGE_ALLOC_DEBUG. Should be easy to do.
> > + *
> > + * - Variable sizing of the per node arrays
> > + */
> 
> These are outdated SLUB comments....

Thanks, probably quite a bit of SLUB cruft  left ;)

 
> > +	/* XXX: might disobey node parameter here */
> > +	if (!NUMA_BUILD || likely(slqb_page_to_nid(page) == numa_node_id())) {
> 
> You can only decide not to obey if __GFP_THISNODE is not set.

I think that's outdated. Basically I think I was previously caching
numa_node_id across the allocation. The code used to be structured
differently...

 
> > +static __always_inline void *__slab_alloc(struct kmem_cache *s,
> > +		gfp_t gfpflags, int node)
> > +{
> > +	void *object;
> > +	struct kmem_cache_cpu *c;
> > +	struct kmem_cache_list *l;
> > +
> > +again:
> > +#ifdef CONFIG_NUMA
> > +	if (unlikely(node != -1) && unlikely(node != numa_node_id())) {
> > +		object = __remote_slab_alloc(s, node);
> > +		if (unlikely(!object))
> > +			goto alloc_new;
> > +		return object;
> > +	}
> > +#endif
> 
> Does this mean that SLQB is less efficient than SLUB for off node
> allocations? SLUB can do off node allocations from the per cpu objects. It
> does not need to make the distinction for allocation.

I haven't measured them, but that could be the case. However I haven't
found a workload that does a lot of off-node allocations (short lived
allocations are better on-node, and long lived ones are not going to
be so numerous).

It's easy to suck up several objects at a time and put them onto a
remote-node list on the per-cpu structure, but I don't want to prematurely
optimise.


> > +	l = &c->list;
> > +	object = __cache_list_get_object(s, l);
> 
> Hmmm... __cache_list_get_object() is quite a bunch of heavy processing.
> This is all inline?

Yes. I've looked at the fastpath assembly and it's pretty good. gcc
can reorder things so the effective icache footprint is pretty small.
That becomes harder if things are out of line.


> > +static __always_inline void __slab_free(struct kmem_cache *s, struct slqb_page *page, void *object)
> > +{
> > +	struct kmem_cache_cpu *c;
> > +	struct kmem_cache_list *l;
> > +	int thiscpu = smp_processor_id();
> > +
> > +	__count_slqb_event(SLQB_FREE);
> > +
> > +	c = get_cpu_slab(s, thiscpu);
> > +	l = &c->list;
> > +
> > +	if (!NUMA_BUILD || !numa_platform ||
> > +			likely(slqb_page_to_nid(page) == numa_node_id())) {
> 
> SLUB does not need a node check. The page struct pointer comparison is
> enough.
> 
> This also means that SLQB cannot do fast frees to remote node objects that
> were just allocated. per cpu queue is bound to the local numa node which
> is quite bad for memoryless nodes. In that case you always need to do
> remote allocs.

I'm not very worried about that case yet. As I said, it's not hard
to add something for it, but I don't know if it is worthwhile yet.

 
> In general I am a bit concerned that you kept the linked object list. You
> may be able to do much better by creating arrays of object pointers. That
> way you can allocate and free multiple objects by only accessing the
> cacheline that contains the object pointers. Only works if the objects are
> not immediately writen to before and after free.

That's more complexity, though. Given that objects are often hot when
they are freed, and need to be touched after they are allocated anyway,
the simple queue seems to be reasonable.

 
> AFAICT this is the special case that matters in terms of the database
> test you are trying to improve. The case there is likely  the result
> of bad cache unfriendly programming. You may actually improve the
> benchmark more if the cachelines would be kept hot there in the right
> way.

This case does improve the database score by around 1.5-2%, yes. I
don't know what you mean exactly, though. What case, and what do you
mean by bad cache unfriendly programming? I would be very interested
in improving that benchmark of course, but I don't know what you
suggest by keeping cachelines hot in the right way?

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
