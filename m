Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f171.google.com (mail-io0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id 4917C6B025B
	for <linux-mm@kvack.org>; Tue, 29 Sep 2015 12:38:33 -0400 (EDT)
Received: by iofb144 with SMTP id b144so17222760iof.1
        for <linux-mm@kvack.org>; Tue, 29 Sep 2015 09:38:33 -0700 (PDT)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com. [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id w7si16232239iod.51.2015.09.29.09.38.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Sep 2015 09:38:32 -0700 (PDT)
Received: by pablk4 with SMTP id lk4so10517564pab.3
        for <linux-mm@kvack.org>; Tue, 29 Sep 2015 09:38:32 -0700 (PDT)
Subject: Re: [MM PATCH V4 5/6] slub: support for bulk free with SLUB freelists
References: <20150929154605.14465.98995.stgit@canyon>
 <20150929154807.14465.76422.stgit@canyon>
From: Alexander Duyck <alexander.duyck@gmail.com>
Message-ID: <560ABE86.9050508@gmail.com>
Date: Tue, 29 Sep 2015 09:38:30 -0700
MIME-Version: 1.0
In-Reply-To: <20150929154807.14465.76422.stgit@canyon>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>
Cc: netdev@vger.kernel.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 09/29/2015 08:48 AM, Jesper Dangaard Brouer wrote:
> Make it possible to free a freelist with several objects by adjusting
> API of slab_free() and __slab_free() to have head, tail and an objects
> counter (cnt).
>
> Tail being NULL indicate single object free of head object.  This
> allow compiler inline constant propagation in slab_free() and
> slab_free_freelist_hook() to avoid adding any overhead in case of
> single object free.
>
> This allows a freelist with several objects (all within the same
> slab-page) to be free'ed using a single locked cmpxchg_double in
> __slab_free() and with an unlocked cmpxchg_double in slab_free().
>
> Object debugging on the free path is also extended to handle these
> freelists.  When CONFIG_SLUB_DEBUG is enabled it will also detect if
> objects don't belong to the same slab-page.
>
> These changes are needed for the next patch to bulk free the detached
> freelists it introduces and constructs.
>
> Micro benchmarking showed no performance reduction due to this change,
> when debugging is turned off (compiled with CONFIG_SLUB_DEBUG).
>
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
>
> ---
> V4:
>   - Change API per req of Christoph Lameter
>   - Remove comments in init_object.
>
>   mm/slub.c |   87 ++++++++++++++++++++++++++++++++++++++++++++++++-------------
>   1 file changed, 69 insertions(+), 18 deletions(-)
>
> diff --git a/mm/slub.c b/mm/slub.c
> index 1cf98d89546d..7c2abc33fd4e 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -1063,11 +1063,15 @@ bad:
>   	return 0;
>   }
>
> +/* Supports checking bulk free of a constructed freelist */
>   static noinline struct kmem_cache_node *free_debug_processing(
> -	struct kmem_cache *s, struct page *page, void *object,
> +	struct kmem_cache *s, struct page *page,
> +	void *head, void *tail, int bulk_cnt,
>   	unsigned long addr, unsigned long *flags)
>   {
>   	struct kmem_cache_node *n = get_node(s, page_to_nid(page));
> +	void *object = head;
> +	int cnt = 0;
>
>   	spin_lock_irqsave(&n->list_lock, *flags);
>   	slab_lock(page);
> @@ -1075,6 +1079,9 @@ static noinline struct kmem_cache_node *free_debug_processing(
>   	if (!check_slab(s, page))
>   		goto fail;
>
> +next_object:
> +	cnt++;
> +
>   	if (!check_valid_pointer(s, page, object)) {
>   		slab_err(s, page, "Invalid object pointer 0x%p", object);
>   		goto fail;
> @@ -1105,8 +1112,19 @@ static noinline struct kmem_cache_node *free_debug_processing(
>   	if (s->flags & SLAB_STORE_USER)
>   		set_track(s, object, TRACK_FREE, addr);
>   	trace(s, page, object, 0);
> +	/* Freepointer not overwritten by init_object(), SLAB_POISON moved it */
>   	init_object(s, object, SLUB_RED_INACTIVE);
> +
> +	/* Reached end of constructed freelist yet? */
> +	if (object != tail) {
> +		object = get_freepointer(s, object);
> +		goto next_object;
> +	}
>   out:
> +	if (cnt != bulk_cnt)
> +		slab_err(s, page, "Bulk freelist count(%d) invalid(%d)\n",
> +			 bulk_cnt, cnt);
> +
>   	slab_unlock(page);
>   	/*
>   	 * Keep node_lock to preserve integrity
> @@ -1210,7 +1228,8 @@ static inline int alloc_debug_processing(struct kmem_cache *s,
>   	struct page *page, void *object, unsigned long addr) { return 0; }
>
>   static inline struct kmem_cache_node *free_debug_processing(
> -	struct kmem_cache *s, struct page *page, void *object,
> +	struct kmem_cache *s, struct page *page,
> +	void *head, void *tail, int bulk_cnt,
>   	unsigned long addr, unsigned long *flags) { return NULL; }
>
>   static inline int slab_pad_check(struct kmem_cache *s, struct page *page)
> @@ -1306,6 +1325,31 @@ static inline void slab_free_hook(struct kmem_cache *s, void *x)
>   	kasan_slab_free(s, x);
>   }
>
> +/* Compiler cannot detect that slab_free_freelist_hook() can be
> + * removed if slab_free_hook() evaluates to nothing.  Thus, we need to
> + * catch all relevant config debug options here.
> + */

Is it actually generating nothing but a pointer walking loop or is there 
a bit of code cruft that is being evaluated inside the loop?

> +#if defined(CONFIG_KMEMCHECK) ||		\
> +	defined(CONFIG_LOCKDEP)	||		\
> +	defined(CONFIG_DEBUG_KMEMLEAK) ||	\
> +	defined(CONFIG_DEBUG_OBJECTS_FREE) ||	\
> +	defined(CONFIG_KASAN)
> +static inline void slab_free_freelist_hook(struct kmem_cache *s,
> +					   void *head, void *tail)
> +{
> +	void *object = head;
> +	void *tail_obj = tail ? : head;
> +
> +	do {
> +		slab_free_hook(s, object);
> +	} while ((object != tail_obj) &&
> +		 (object = get_freepointer(s, object)));
> +}
> +#else
> +static inline void slab_free_freelist_hook(struct kmem_cache *s, void *obj_tail,
> +					   void *freelist_head) {}
> +#endif
> +

Instead of messing around with an #else you might just wrap the contents 
of slab_free_freelist_hook in the #if/#endif instead of the entire 
function declaration.

>   static void setup_object(struct kmem_cache *s, struct page *page,
>   				void *object)
>   {
> @@ -2586,10 +2630,11 @@ EXPORT_SYMBOL(kmem_cache_alloc_node_trace);
>    * handling required then we can return immediately.
>    */
>   static void __slab_free(struct kmem_cache *s, struct page *page,
> -			void *x, unsigned long addr)
> +			void *head, void *tail, int cnt,
> +			unsigned long addr)
> +
>   {
>   	void *prior;
> -	void **object = (void *)x;
>   	int was_frozen;
>   	struct page new;
>   	unsigned long counters;
> @@ -2599,7 +2644,8 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
>   	stat(s, FREE_SLOWPATH);
>
>   	if (kmem_cache_debug(s) &&
> -		!(n = free_debug_processing(s, page, x, addr, &flags)))
> +	    !(n = free_debug_processing(s, page, head, tail, cnt,
> +					addr, &flags)))
>   		return;
>
>   	do {
> @@ -2609,10 +2655,10 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
>   		}
>   		prior = page->freelist;
>   		counters = page->counters;
> -		set_freepointer(s, object, prior);
> +		set_freepointer(s, tail, prior);
>   		new.counters = counters;
>   		was_frozen = new.frozen;
> -		new.inuse--;
> +		new.inuse -= cnt;
>   		if ((!new.inuse || !prior) && !was_frozen) {
>
>   			if (kmem_cache_has_cpu_partial(s) && !prior) {
> @@ -2643,7 +2689,7 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
>
>   	} while (!cmpxchg_double_slab(s, page,
>   		prior, counters,
> -		object, new.counters,
> +		head, new.counters,
>   		"__slab_free"));
>
>   	if (likely(!n)) {
> @@ -2708,15 +2754,20 @@ slab_empty:
>    *
>    * If fastpath is not possible then fall back to __slab_free where we deal
>    * with all sorts of special processing.
> + *
> + * Bulk free of a freelist with several objects (all pointing to the
> + * same page) possible by specifying head and tail ptr, plus objects
> + * count (cnt). Bulk free indicated by tail pointer being set.
>    */
> -static __always_inline void slab_free(struct kmem_cache *s,
> -			struct page *page, void *x, unsigned long addr)
> +static __always_inline void slab_free(struct kmem_cache *s, struct page *page,
> +				      void *head, void *tail, int cnt,
> +				      unsigned long addr)
>   {
> -	void **object = (void *)x;
> +	void *tail_obj = tail ? : head;
>   	struct kmem_cache_cpu *c;
>   	unsigned long tid;
>
> -	slab_free_hook(s, x);
> +	slab_free_freelist_hook(s, head, tail);
>
>   redo:
>   	/*
> @@ -2735,19 +2786,19 @@ redo:
>   	barrier();
>
>   	if (likely(page == c->page)) {
> -		set_freepointer(s, object, c->freelist);
> +		set_freepointer(s, tail_obj, c->freelist);
>
>   		if (unlikely(!this_cpu_cmpxchg_double(
>   				s->cpu_slab->freelist, s->cpu_slab->tid,
>   				c->freelist, tid,
> -				object, next_tid(tid)))) {
> +				head, next_tid(tid)))) {
>
>   			note_cmpxchg_failure("slab_free", s, tid);
>   			goto redo;
>   		}
>   		stat(s, FREE_FASTPATH);
>   	} else
> -		__slab_free(s, page, x, addr);
> +		__slab_free(s, page, head, tail_obj, cnt, addr);
>
>   }
>
> @@ -2756,7 +2807,7 @@ void kmem_cache_free(struct kmem_cache *s, void *x)
>   	s = cache_from_obj(s, x);
>   	if (!s)
>   		return;
> -	slab_free(s, virt_to_head_page(x), x, _RET_IP_);
> +	slab_free(s, virt_to_head_page(x), x, NULL, 1, _RET_IP_);
>   	trace_kmem_cache_free(_RET_IP_, x);
>   }
>   EXPORT_SYMBOL(kmem_cache_free);
> @@ -2791,7 +2842,7 @@ void kmem_cache_free_bulk(struct kmem_cache *s, size_t size, void **p)
>   			c->tid = next_tid(c->tid);
>   			local_irq_enable();
>   			/* Slowpath: overhead locked cmpxchg_double_slab */
> -			__slab_free(s, page, object, _RET_IP_);
> +			__slab_free(s, page, object, object, 1, _RET_IP_);
>   			local_irq_disable();
>   			c = this_cpu_ptr(s->cpu_slab);
>   		}
> @@ -3531,7 +3582,7 @@ void kfree(const void *x)
>   		__free_kmem_pages(page, compound_order(page));
>   		return;
>   	}
> -	slab_free(page->slab_cache, page, object, _RET_IP_);
> +	slab_free(page->slab_cache, page, object, NULL, 1, _RET_IP_);
>   }
>   EXPORT_SYMBOL(kfree);
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
