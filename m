Return-Path: <linux-kernel-owner+w=401wt.eu-S1755731AbYLMCe6@vger.kernel.org>
Date: Fri, 12 Dec 2008 20:34:35 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [rfc][patch] SLQB slab allocator
In-Reply-To: <20081212002518.GH8294@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0812122013390.15781@quilx.com>
References: <20081212002518.GH8294@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-kernel-owner@vger.kernel.org
List-Archive: <https://lore.kernel.org/lkml/>
List-Post: <mailto:linux-kernel@vger.kernel.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, bcrl@kvack.org, list-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 12 Dec 2008, Nick Piggin wrote:

> + * SLQB : A slab allocator with object queues.
> + *
> + * (C) 2008 Nick Piggin <npiggin@suse.de>

My copyright notice is missing. Most of this is directly copied from SLUB.
And I am not CCed? What should I be thinking?

> +/*
> + * SLQB: A slab allocator that focuses on per-CPU scaling, and good performance
> + * with order-0 allocations. Fastpaths emphasis is placed on local allocaiton
> + * and freeing, but with a secondary goal of good remote freeing (freeing on
> + * another CPU from that which allocated).

Good idea. I like new ideas based on SLUB.

> + *
> + * Using ideas and code from mm/slab.c, mm/slob.c, and mm/slub.c.

Thats not right. The code was copied from mm/slub.c and then modified.

It seems that the SLUB skeleton is very useful. Maybe we could abstract
the common code out in order to make more creative variants possible in
the future?

> +/*
> + * Issues still to be resolved:
> + *
> + * - Support PAGE_ALLOC_DEBUG. Should be easy to do.
> + *
> + * - Variable sizing of the per node arrays
> + */

These are outdated SLUB comments....

> +	/* XXX: might disobey node parameter here */
> +	if (!NUMA_BUILD || likely(slqb_page_to_nid(page) == numa_node_id())) {

You can only decide not to obey if __GFP_THISNODE is not set.

> +static __always_inline void *__slab_alloc(struct kmem_cache *s,
> +		gfp_t gfpflags, int node)
> +{
> +	void *object;
> +	struct kmem_cache_cpu *c;
> +	struct kmem_cache_list *l;
> +
> +again:
> +#ifdef CONFIG_NUMA
> +	if (unlikely(node != -1) && unlikely(node != numa_node_id())) {
> +		object = __remote_slab_alloc(s, node);
> +		if (unlikely(!object))
> +			goto alloc_new;
> +		return object;
> +	}
> +#endif

Does this mean that SLQB is less efficient than SLUB for off node
allocations? SLUB can do off node allocations from the per cpu objects. It
does not need to make the distinction for allocation.


> +	c = get_cpu_slab(s, smp_processor_id());
> +	VM_BUG_ON(!c);

if c = NULL then the deref will fail anyways with a NULL deref error. No
need to have a VM_BUG_ON here.


> +	l = &c->list;
> +	object = __cache_list_get_object(s, l);

Hmmm... __cache_list_get_object() is quite a bunch of heavy processing.
This is all inline?


> +static __always_inline void __slab_free(struct kmem_cache *s, struct slqb_page *page, void *object)
> +{
> +	struct kmem_cache_cpu *c;
> +	struct kmem_cache_list *l;
> +	int thiscpu = smp_processor_id();
> +
> +	__count_slqb_event(SLQB_FREE);
> +
> +	c = get_cpu_slab(s, thiscpu);
> +	l = &c->list;
> +
> +	if (!NUMA_BUILD || !numa_platform ||
> +			likely(slqb_page_to_nid(page) == numa_node_id())) {

SLUB does not need a node check. The page struct pointer comparison is
enough.

This also means that SLQB cannot do fast frees to remote node objects that
were just allocated. per cpu queue is bound to the local numa node which
is quite bad for memoryless nodes. In that case you always need to do
remote allocs.

In general I am a bit concerned that you kept the linked object list. You
may be able to do much better by creating arrays of object pointers. That
way you can allocate and free multiple objects by only accessing the
cacheline that contains the object pointers. Only works if the objects are
not immediately writen to before and after free.

AFAICT this is the special case that matters in terms of the database
test you are trying to improve. The case there is likely  the result
of bad cache unfriendly programming. You may actually improve the
benchmark more if the cachelines would be kept hot there in the right
way.
