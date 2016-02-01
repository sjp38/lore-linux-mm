Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id 3038A6B0005
	for <linux-mm@kvack.org>; Sun, 31 Jan 2016 21:46:59 -0500 (EST)
Received: by mail-ig0-f177.google.com with SMTP id mw1so23897304igb.1
        for <linux-mm@kvack.org>; Sun, 31 Jan 2016 18:46:59 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTPS id rs9si12320988igb.104.2016.01.31.18.46.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 31 Jan 2016 18:46:58 -0800 (PST)
Date: Mon, 1 Feb 2016 11:47:15 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v1 8/8] mm: kasan: Initial memory quarantine
 implementation
Message-ID: <20160201024715.GC32125@js1304-P5Q-DELUXE>
References: <cover.1453918525.git.glider@google.com>
 <1cec06645310eeb495bcae7bed0807dbf2235f3a.1453918525.git.glider@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1cec06645310eeb495bcae7bed0807dbf2235f3a.1453918525.git.glider@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: adech.fo@gmail.com, cl@linux.com, dvyukov@google.com, akpm@linux-foundation.org, ryabinin.a.a@gmail.com, rostedt@goodmis.org, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Jan 27, 2016 at 07:25:13PM +0100, Alexander Potapenko wrote:
> Quarantine isolates freed objects in a separate queue. The objects are
> returned to the allocator later, which helps to detect use-after-free
> errors.
> 
> Freed objects are first added to per-cpu quarantine queues.
> When a cache is destroyed or memory shrinking is requested, the objects
> are moved into the global quarantine queue. Whenever a kmalloc call
> allows memory reclaiming, the oldest objects are popped out of the
> global queue until the total size of objects in quarantine is less than
> 3/4 of the maximum quarantine size (which is a fraction of installed
> physical memory).

Just wondering why not using time based approach rather than size
based one. In heavy load condition, how much time do the object stay in
quarantine?

> 
> Right now quarantine support is only enabled in SLAB allocator.
> Unification of KASAN features in SLAB and SLUB will be done later.
> 
> This patch is based on the "mm: kasan: quarantine" patch originally
> prepared by Dmitry Chernenkov.
> 
> Signed-off-by: Alexander Potapenko <glider@google.com>
> ---
>  include/linux/kasan.h |  30 ++++--
>  lib/test_kasan.c      |  29 ++++++
>  mm/kasan/Makefile     |   2 +-
>  mm/kasan/kasan.c      |  68 +++++++++++-
>  mm/kasan/kasan.h      |  11 +-
>  mm/kasan/quarantine.c | 284 ++++++++++++++++++++++++++++++++++++++++++++++++++
>  mm/kasan/report.c     |   3 +-
>  mm/mempool.c          |   7 +-
>  mm/page_alloc.c       |   2 +-
>  mm/slab.c             |  12 ++-
>  mm/slab.h             |   4 +
>  mm/slab_common.c      |   2 +
>  mm/slub.c             |   4 +-
>  13 files changed, 435 insertions(+), 23 deletions(-)
> 

...

> +bool kasan_slab_free(struct kmem_cache *cache, void *object)
> +{
> +#ifdef CONFIG_SLAB
> +	/* RCU slabs could be legally used after free within the RCU period */
> +	if (unlikely(cache->flags & SLAB_DESTROY_BY_RCU))
> +		return false;
> +
> +	if (likely(cache->flags & SLAB_KASAN)) {
> +		struct kasan_alloc_meta *alloc_info =
> +			get_alloc_info(cache, object);
> +		struct kasan_free_meta *free_info =
> +			get_free_info(cache, object);
> +
> +		switch (alloc_info->state) {
> +		case KASAN_STATE_ALLOC:
> +			alloc_info->state = KASAN_STATE_QUARANTINE;
> +			quarantine_put(free_info, cache);

quarantine_put() can be called regardless of SLAB_DESTROY_BY_RCU,
although it's not much meaningful without poisoning. But, I have an
idea to poison object on SLAB_DESTROY_BY_RCU cache.

quarantine_put() moves per cpu list to global queue when
list size reaches QUARANTINE_PERCPU_SIZE. If we call synchronize_rcu()
at that time, after then, we can poison objects. With appropriate size
setup, it would not be intrusive.

> +			set_track(&free_info->track, GFP_NOWAIT);

set_track() can be called regardless of SLAB_DESTROY_BY_RCU.

> +			kasan_poison_slab_free(cache, object);
> +			return true;
> +		case KASAN_STATE_QUARANTINE:
> +		case KASAN_STATE_FREE:
> +			pr_err("Double free");
> +			dump_stack();
> +			break;
> +		default:
> +			break;
> +		}
> +	}
> +	return false;
> +#else
> +	kasan_poison_slab_free(cache, object);
> +	return false;
> +#endif
> +}
> +

...

> +void quarantine_reduce(void)
> +{
> +	size_t new_quarantine_size;
> +	unsigned long flags;
> +	struct qlist to_free = QLIST_INIT;
> +	size_t size_to_free = 0;
> +	void **last;
> +
> +	if (likely(ACCESS_ONCE(global_quarantine.bytes) <=
> +		   smp_load_acquire(&quarantine_size)))
> +		return;
> +
> +	spin_lock_irqsave(&quarantine_lock, flags);
> +
> +	/* Update quarantine size in case of hotplug. Allocate a fraction of
> +	 * the installed memory to quarantine minus per-cpu queue limits.
> +	 */
> +	new_quarantine_size = (ACCESS_ONCE(totalram_pages) << PAGE_SHIFT) /
> +		QUARANTINE_FRACTION;
> +	new_quarantine_size -= QUARANTINE_PERCPU_SIZE * num_online_cpus();
> +	smp_store_release(&quarantine_size, new_quarantine_size);
> +
> +	last = global_quarantine.head;
> +	while (last) {
> +		struct kmem_cache *cache = qlink_to_cache(last);
> +
> +		size_to_free += cache->size;
> +		if (!*last || size_to_free >
> +		    global_quarantine.bytes - QUARANTINE_LOW_SIZE)
> +			break;
> +		last = (void **) *last;
> +	}
> +	qlist_move(&global_quarantine, last, &to_free, size_to_free);
> +
> +	spin_unlock_irqrestore(&quarantine_lock, flags);
> +
> +	qlist_free_all(&to_free, NULL);
> +}

Isn't it better to call quarantine_reduce() in shrink_slab()?
It will help to maximize quarantine time.

> +
> +static inline void qlist_move_cache(struct qlist *from,
> +				   struct qlist *to,
> +				   struct kmem_cache *cache)
> +{
> +	void ***prev;
> +
> +	if (unlikely(empty_qlist(from)))
> +		return;
> +
> +	prev = &from->head;
> +	while (*prev) {
> +		void **qlink = *prev;
> +		struct kmem_cache *obj_cache = qlink_to_cache(qlink);
> +
> +		if (obj_cache == cache) {
> +			if (unlikely(from->tail == qlink))
> +				from->tail = (void **) prev;
> +			*prev = (void **) *qlink;
> +			from->bytes -= cache->size;
> +			qlist_put(to, qlink, cache->size);
> +		} else
> +			prev = (void ***) *prev;
> +	}
> +}
> +
> +static void per_cpu_remove_cache(void *arg)
> +{
> +	struct kmem_cache *cache = arg;
> +	struct qlist to_free = QLIST_INIT;
> +	struct qlist *q;
> +	unsigned long flags;
> +
> +	local_irq_save(flags);
> +	q = this_cpu_ptr(&cpu_quarantine);
> +	qlist_move_cache(q, &to_free, cache);
> +	local_irq_restore(flags);
> +
> +	qlist_free_all(&to_free, cache);
> +}
> +
> +void quarantine_remove_cache(struct kmem_cache *cache)
> +{
> +	unsigned long flags;
> +	struct qlist to_free = QLIST_INIT;
> +
> +	on_each_cpu(per_cpu_remove_cache, cache, 0);

Should be called with wait = 1.

> +
> +	spin_lock_irqsave(&quarantine_lock, flags);
> +	qlist_move_cache(&global_quarantine, &to_free, cache);
> +	spin_unlock_irqrestore(&quarantine_lock, flags);
> +
> +	qlist_free_all(&to_free, cache);
> +}
> diff --git a/mm/kasan/report.c b/mm/kasan/report.c
> index 6c4afcd..a4dca25 100644
> --- a/mm/kasan/report.c
> +++ b/mm/kasan/report.c
> @@ -148,7 +148,8 @@ static void print_object(struct kmem_cache *cache, void *object)
>  		print_track(&alloc_info->track);
>  		break;
>  	case KASAN_STATE_FREE:
> -		pr_err("Object freed, allocated with size %u bytes\n",
> +	case KASAN_STATE_QUARANTINE:
> +		pr_err("Object freed, allocated with size %lu bytes\n",
>  		       alloc_info->alloc_size);
>  		free_info = get_free_info(cache, object);
>  		pr_err("Allocation:\n");
> diff --git a/mm/mempool.c b/mm/mempool.c
> index b47c8a7..4beeeef 100644
> --- a/mm/mempool.c
> +++ b/mm/mempool.c
> @@ -105,11 +105,12 @@ static inline void poison_element(mempool_t *pool, void *element)
>  static void kasan_poison_element(mempool_t *pool, void *element)
>  {
>  	if (pool->alloc == mempool_alloc_slab)
> -		kasan_slab_free(pool->pool_data, element);
> +		kasan_poison_slab_free(pool->pool_data, element);
>  	if (pool->alloc == mempool_kmalloc)
> -		kasan_kfree(element);
> +		kasan_poison_kfree(element);
>  	if (pool->alloc == mempool_alloc_pages)
> -		kasan_free_pages(element, (unsigned long)pool->pool_data);
> +		kasan_poison_free_pages(element,
> +					(unsigned long)pool->pool_data);
>  }
>  
>  static void kasan_unpoison_element(mempool_t *pool, void *element, gfp_t flags)
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 63358d9..4f65587 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -980,7 +980,7 @@ static bool free_pages_prepare(struct page *page, unsigned int order)
>  
>  	trace_mm_page_free(page, order);
>  	kmemcheck_free_shadow(page, order);
> -	kasan_free_pages(page, order);
> +	kasan_poison_free_pages(page, order);
>  
>  	if (PageAnon(page))
>  		page->mapping = NULL;
> diff --git a/mm/slab.c b/mm/slab.c
> index 0ec7aa3..e2fac67 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -3374,9 +3374,19 @@ free_done:
>  static inline void __cache_free(struct kmem_cache *cachep, void *objp,
>  				unsigned long caller)
>  {
> +#ifdef CONFIG_KASAN
> +	if (!kasan_slab_free(cachep, objp))
> +		/* The object has been put into the quarantine, don't touch it
> +		 * for now.
> +		 */
> +		nokasan_free(cachep, objp, caller);
> +}
> +
> +void nokasan_free(struct kmem_cache *cachep, void *objp, unsigned long caller)
> +{
> +#endif

It looks not good to me.
Converting __cache_free() to ____cache_free() and making
__cache_free() call ____cache_free() if (!kasan_slab_free()) looks
better to me and less error-prone.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
