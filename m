Date: Tue, 30 Oct 2007 11:30:05 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 08/10] SLUB: Optional fast path using cmpxchg_local
Message-Id: <20071030113005.30d4aa4e.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0710281502480.4207@sbz-30.cs.Helsinki.FI>
References: <20071028033156.022983073@sgi.com>
	<20071028033300.240703208@sgi.com>
	<Pine.LNX.4.64.0710281502480.4207@sbz-30.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka J Enberg <penberg@cs.helsinki.fi>
Cc: clameter@sgi.com, matthew@wil.cx, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 28 Oct 2007 15:05:50 +0200 (EET)
Pekka J Enberg <penberg@cs.helsinki.fi> wrote:

> On Sat, 27 Oct 2007, Christoph Lameter wrote:
> > The alternate path is realized using #ifdef's. Several attempts to do the
> > same with macros and in line functions resulted in a mess (in particular due
> > to the strange way that local_interrupt_save() handles its argument and due
> > to the need to define macros/functions that sometimes disable interrupts
> > and sometimes do something else. The macro based approaches made it also
> > difficult to preserve the optimizations for the non cmpxchg paths).
> 
> I think at least slub_alloc() and slub_free() can be made simpler. See the 
> included patch below.

Both versions look pretty crappy to me.  The code duplication in the two
version of do_slab_alloc() could be tidied up considerably.

> +#ifdef CONFIG_FAST_CMPXHG_LOCAL
> +static __always_inline void *do_slab_alloc(struct kmem_cache *s,
> +		struct kmem_cache_cpu *c, gfp_t gfpflags, int node, void *addr)
> +{
> +	unsigned long flags;
> +	void **object;
> +
> +	do {
> +		object = c->freelist;
> +		if (unlikely(is_end(object) || !node_match(c, node))) {
> +			object = __slab_alloc(s, gfpflags, node, addr, c);
> +			break;
> +		}
> +	} while (cmpxchg_local(&c->freelist, object, object[c->offset])
> +								!= object);
> +	put_cpu();
> +
> +	return object;
> +}

Unmatched put_cpu() 

> +
> +static __always_inline void *do_slab_alloc(struct kmem_cache *s,
> +		struct kmem_cache_cpu *c, gfp_t gfpflags, int node, void *addr)
> +{
> +	unsigned long flags;
> +	void **object;
> +
> +	local_irq_save(flags);
> +	if (unlikely((is_end(c->freelist)) || !node_match(c, node))) {
> +		object = __slab_alloc(s, gfpflags, node, addr, c);
> +	} else {
> +		object = c->freelist;
> +		c->freelist = object[c->offset];
> +	}
> +	local_irq_restore(flags);
> +	return object;
> +}
> +#endif
> +
>  /*
>   * Inlined fastpath so that allocation functions (kmalloc, kmem_cache_alloc)
>   * have the fastpath folded into their functions. So no function call
> @@ -1591,24 +1639,13 @@ debug:
>  static void __always_inline *slab_alloc(struct kmem_cache *s,
>  		gfp_t gfpflags, int node, void *addr)
>  {
> -	void **object;
> -	unsigned long flags;
>  	struct kmem_cache_cpu *c;
> +	void **object;
>  
> -	local_irq_save(flags);
>  	c = get_cpu_slab(s, smp_processor_id());

smp_processor_id() in preemptible code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
