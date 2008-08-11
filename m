Message-ID: <48A046F5.2000505@linux-foundation.org>
Date: Mon, 11 Aug 2008 09:04:37 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [PATCH 4/5] kmemtrace: SLUB hooks.
References: <1218388447-5578-1-git-send-email-eduard.munteanu@linux360.ro> <1218388447-5578-2-git-send-email-eduard.munteanu@linux360.ro> <1218388447-5578-3-git-send-email-eduard.munteanu@linux360.ro> <1218388447-5578-4-git-send-email-eduard.munteanu@linux360.ro> <1218388447-5578-5-git-send-email-eduard.munteanu@linux360.ro>
In-Reply-To: <1218388447-5578-5-git-send-email-eduard.munteanu@linux360.ro>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Cc: penberg@cs.helsinki.fi, mathieu.desnoyers@polymtl.ca, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rdunlap@xenotime.net, mpm@selenic.com, rostedt@goodmis.org, tglx@linutronix.de
List-ID: <linux-mm.kvack.org>

Eduard - Gabriel Munteanu wrote:



>  static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
>  {
> +	void *ret;
> +
>  	if (__builtin_constant_p(size) &&
>  		size <= PAGE_SIZE && !(flags & SLUB_DMA)) {
>  			struct kmem_cache *s = kmalloc_slab(size);
> @@ -239,7 +280,13 @@ static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
>  		if (!s)
>  			return ZERO_SIZE_PTR;
>  
> -		return kmem_cache_alloc_node(s, flags, node);
> +		ret = kmem_cache_alloc_node_notrace(s, flags, node);
> +
> +		kmemtrace_mark_alloc_node(KMEMTRACE_TYPE_KMALLOC,
> +					  _THIS_IP_, ret,
> +					  size, s->size, flags, node);
> +
> +		return ret;

You could simplify the stuff in slub.h if you would fall back to the uninlined
functions in the case that kmemtrace is enabled. IMHO adding additional inline
code here does grow these function to a size where inlining is not useful anymore.


> diff --git a/mm/slub.c b/mm/slub.c
> index 315c392..940145f 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -23,6 +23,7 @@
>  #include <linux/kallsyms.h>
>  #include <linux/memory.h>
>  #include <linux/math64.h>
> +#include <linux/kmemtrace.h>
>  
>  /*
>   * Lock order:
> @@ -1652,18 +1653,47 @@ static __always_inline void *slab_alloc(struct kmem_cache *s,
>  
>  void *kmem_cache_alloc(struct kmem_cache *s, gfp_t gfpflags)
>  {
> -	return slab_alloc(s, gfpflags, -1, __builtin_return_address(0));
> +	void *ret = slab_alloc(s, gfpflags, -1, __builtin_return_address(0));
> +
> +	kmemtrace_mark_alloc(KMEMTRACE_TYPE_CACHE, _RET_IP_, ret,
> +			     s->objsize, s->size, gfpflags);
> +
> +	return ret;
>  }

_RET_IP == __builtin_return_address(0) right? Put that into a local variable?
At least we need consistent usage within one function. Maybe convert
__builtin_return_address(0) to _RET_IP_ within slub?

>  EXPORT_SYMBOL(kmem_cache_alloc);
>  
> +#ifdef CONFIG_KMEMTRACE
> +void *kmem_cache_alloc_notrace(struct kmem_cache *s, gfp_t gfpflags)
> +{
> +	return slab_alloc(s, gfpflags, -1, __builtin_return_address(0));
> +}
> +EXPORT_SYMBOL(kmem_cache_alloc_notrace);
> +#endif
> +
>  #ifdef CONFIG_NUMA
>  void *kmem_cache_alloc_node(struct kmem_cache *s, gfp_t gfpflags, int node)
>  {
> -	return slab_alloc(s, gfpflags, node, __builtin_return_address(0));
> +	void *ret = slab_alloc(s, gfpflags, node,
> +			       __builtin_return_address(0));
> +
> +	kmemtrace_mark_alloc_node(KMEMTRACE_TYPE_CACHE, _RET_IP_, ret,
> +				  s->objsize, s->size, gfpflags, node);
> +
> +	return ret;

Same here.

>  }
>  EXPORT_SYMBOL(kmem_cache_alloc_node);
>  #endif
>  
> +#ifdef CONFIG_KMEMTRACE
> +void *kmem_cache_alloc_node_notrace(struct kmem_cache *s,
> +				    gfp_t gfpflags,
> +				    int node)
> +{
> +	return slab_alloc(s, gfpflags, node, __builtin_return_address(0));
> +}
> +EXPORT_SYMBOL(kmem_cache_alloc_node_notrace);
> +#endif
> +
>  /*
>   * Slow patch handling. This may still be called frequently since objects
>   * have a longer lifetime than the cpu slabs in most processing loads.
> @@ -1771,6 +1801,8 @@ void kmem_cache_free(struct kmem_cache *s, void *x)
>  	page = virt_to_head_page(x);
>  
>  	slab_free(s, page, x, __builtin_return_address(0));
> +
> +	kmemtrace_mark_free(KMEMTRACE_TYPE_CACHE, _RET_IP_, x);
>  }
>  EXPORT_SYMBOL(kmem_cache_free);

And again.

>  
> @@ -2676,6 +2708,7 @@ static struct kmem_cache *get_slab(size_t size, gfp_t flags)
>  void *__kmalloc(size_t size, gfp_t flags)
>  {
>  	struct kmem_cache *s;
> +	void *ret;
>  
>  	if (unlikely(size > PAGE_SIZE))
>  		return kmalloc_large(size, flags);
> @@ -2685,7 +2718,12 @@ void *__kmalloc(size_t size, gfp_t flags)
>  	if (unlikely(ZERO_OR_NULL_PTR(s)))
>  		return s;
>  
> -	return slab_alloc(s, flags, -1, __builtin_return_address(0));
> +	ret = slab_alloc(s, flags, -1, __builtin_return_address(0));
> +
> +	kmemtrace_mark_alloc(KMEMTRACE_TYPE_KMALLOC, _RET_IP_, ret,
> +			     size, s->size, flags);
> +
> +	return ret;
>  }
>  EXPORT_SYMBOL(__kmalloc);
>  

And again.

;
>  #endif
> @@ -2771,6 +2823,8 @@ void kfree(const void *x)
>  		return;
>  	}
>  	slab_free(page->slab, page, object, __builtin_return_address(0));
> +
> +	kmemtrace_mark_free(KMEMTRACE_TYPE_KMALLOC, _RET_IP_, x);

And another one.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
