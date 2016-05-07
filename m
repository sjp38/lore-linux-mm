Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id F248A6B0005
	for <linux-mm@kvack.org>; Sat,  7 May 2016 06:29:35 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id r185so13437437qkf.1
        for <linux-mm@kvack.org>; Sat, 07 May 2016 03:29:35 -0700 (PDT)
Received: from na01-by2-obe.outbound.protection.outlook.com (mail-by2on0096.outbound.protection.outlook.com. [207.46.100.96])
        by mx.google.com with ESMTPS id b32si4606604qkh.62.2016.05.07.03.29.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sat, 07 May 2016 03:29:35 -0700 (PDT)
Date: Sat, 7 May 2016 13:25:05 +0300
From: Yury Norov <ynorov@caviumnetworks.com>
Subject: Re: [PATCH v2 1/2] mm, kasan: improve double-free detection
Message-ID: <20160507102505.GA27794@yury-N73SV>
References: <20160506114727.GA2571@cherokee.in.rdlabs.hpecorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20160506114727.GA2571@cherokee.in.rdlabs.hpecorp.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kuthonuzo Luruo <kuthonuzo.luruo@hpe.com>
Cc: aryabinin@virtuozzo.com, glider@google.com, dvyukov@google.com, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, klimov.linux@gmail.com

On Fri, May 06, 2016 at 05:17:27PM +0530, Kuthonuzo Luruo wrote:
> Currently, KASAN may fail to detect concurrent deallocations of the same
> object due to a race in kasan_slab_free(). This patch makes double-free
> detection more reliable by serializing access to KASAN object metadata.
> New functions kasan_meta_lock() and kasan_meta_unlock() are provided to
> lock/unlock per-object metadata. Double-free errors are now reported via
> kasan_report().
> 
> Testing:
> - Tested with a modified version of the 'slab_test' microbenchmark where
>   allocs occur on CPU 0; then all other CPUs concurrently attempt to free
>   the same object.
> - Tested with new 'test_kasan' kasan_double_free() test in accompanying
>   patch.
> 
> Signed-off-by: Kuthonuzo Luruo <kuthonuzo.luruo@hpe.com>
> ---
> 
> Changes in v2:
> - Incorporated suggestions from Dmitry Vyukov. New per-object metadata
>   lock/unlock functions; kasan_alloc_meta modified to add new state while
>   using fewer bits overall.
> - Double-free pr_err promoted to kasan_report().
> - kasan_init_object() introduced to initialize KASAN object metadata
>   during slab creation. KASAN_STATE_INIT initialization removed from
>   kasan_poison_object_data().
>  
> ---
>  include/linux/kasan.h |    8 +++
>  mm/kasan/kasan.c      |  118 ++++++++++++++++++++++++++++++++++++-------------
>  mm/kasan/kasan.h      |   15 +++++-
>  mm/kasan/quarantine.c |    7 +++-
>  mm/kasan/report.c     |   31 +++++++++++--
>  mm/slab.c             |    1 +
>  6 files changed, 142 insertions(+), 38 deletions(-)
> 
> diff --git a/include/linux/kasan.h b/include/linux/kasan.h
> index 645c280..c7bf625 100644
> --- a/include/linux/kasan.h
> +++ b/include/linux/kasan.h
> @@ -78,6 +78,10 @@ struct kasan_cache {
>  int kasan_module_alloc(void *addr, size_t size);
>  void kasan_free_shadow(const struct vm_struct *vm);
>  
> +#ifdef CONFIG_SLAB
> +void kasan_init_object(struct kmem_cache *cache, void *object);
> +#endif
> +
>  #else /* CONFIG_KASAN */
>  
>  static inline void kasan_unpoison_shadow(const void *address, size_t size) {}
> @@ -124,6 +128,10 @@ static inline void kasan_poison_slab_free(struct kmem_cache *s, void *object) {}
>  static inline int kasan_module_alloc(void *addr, size_t size) { return 0; }
>  static inline void kasan_free_shadow(const struct vm_struct *vm) {}
>  
> +#ifdef CONFIG_SLAB
> +static inline void kasan_init_object(struct kmem_cache *cache, void *object) {}
> +#endif
> +
>  #endif /* CONFIG_KASAN */
>  
>  #endif /* LINUX_KASAN_H */
> diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
> index ef2e87b..a840b49 100644
> --- a/mm/kasan/kasan.c
> +++ b/mm/kasan/kasan.c
> @@ -34,6 +34,7 @@
>  #include <linux/string.h>
>  #include <linux/types.h>
>  #include <linux/vmalloc.h>
> +#include <linux/atomic.h>
>  
>  #include "kasan.h"
>  #include "../slab.h"
> @@ -419,13 +420,6 @@ void kasan_poison_object_data(struct kmem_cache *cache, void *object)
>  	kasan_poison_shadow(object,
>  			round_up(cache->object_size, KASAN_SHADOW_SCALE_SIZE),
>  			KASAN_KMALLOC_REDZONE);
> -#ifdef CONFIG_SLAB
> -	if (cache->flags & SLAB_KASAN) {
> -		struct kasan_alloc_meta *alloc_info =
> -			get_alloc_info(cache, object);
> -		alloc_info->state = KASAN_STATE_INIT;
> -	}
> -#endif
>  }
>  
>  #ifdef CONFIG_SLAB
> @@ -470,6 +464,18 @@ static inline depot_stack_handle_t save_stack(gfp_t flags)
>  	return depot_save_stack(&trace, flags);
>  }
>  
> +void kasan_init_object(struct kmem_cache *cache, void *object)
> +{
> +	struct kasan_alloc_meta *alloc_info;
> +
> +	if (cache->flags & SLAB_KASAN) {
> +		kasan_unpoison_object_data(cache, object);
> +		alloc_info = get_alloc_info(cache, object);
> +		__memset(alloc_info, 0, sizeof(*alloc_info));
> +		kasan_poison_object_data(cache, object);
> +	}
> +}
> +
>  static inline void set_track(struct kasan_track *track, gfp_t flags)
>  {
>  	track->pid = current->pid;
> @@ -489,6 +495,39 @@ struct kasan_free_meta *get_free_info(struct kmem_cache *cache,
>  	BUILD_BUG_ON(sizeof(struct kasan_free_meta) > 32);
>  	return (void *)object + cache->kasan_info.free_meta_offset;
>  }
> +
> +/* acquire per-object lock for access to KASAN metadata. */

I believe there's strong reason not to use standard spin_lock() or
similar. I think it's proper place to explain it.

> +void kasan_meta_lock(struct kasan_alloc_meta *alloc_info)
> +{
> +	union kasan_alloc_data old, new;
> +
> +	preempt_disable();

It's better to disable and enable preemption inside the loop
on each iteration, to decrease contention.

> +	for (;;) {
> +		old.packed = READ_ONCE(alloc_info->data);
> +		if (unlikely(old.lock)) {
> +			cpu_relax();
> +			continue;
> +		}
> +		new.packed = old.packed;
> +		new.lock = 1;
> +		if (likely(cmpxchg(&alloc_info->data, old.packed, new.packed)
> +					== old.packed))
> +			break;
> +	}
> +}
> +
> +/* release lock after a kasan_meta_lock(). */
> +void kasan_meta_unlock(struct kasan_alloc_meta *alloc_info)
> +{
> +	union kasan_alloc_data alloc_data;
> +
> +	alloc_data.packed = READ_ONCE(alloc_info->data);
> +	alloc_data.lock = 0;
> +	if (unlikely(xchg(&alloc_info->data, alloc_data.packed) !=
> +				(alloc_data.packed | 0x1U)))
> +		WARN_ONCE(1, "%s: lock not held!\n", __func__);

Nitpick. It never happens in normal case, correct?. Why don't you place it under
some developer config, or even leave at dev branch? The function will
be twice shorter without it.

> +	preempt_enable();
> +}
>  #endif
>  
>  void kasan_slab_alloc(struct kmem_cache *cache, void *object, gfp_t flags)
> @@ -511,32 +550,41 @@ void kasan_poison_slab_free(struct kmem_cache *cache, void *object)
>  bool kasan_slab_free(struct kmem_cache *cache, void *object)
>  {
>  #ifdef CONFIG_SLAB
> +	struct kasan_alloc_meta *alloc_info;
> +	struct kasan_free_meta *free_info;
> +	union kasan_alloc_data alloc_data;
> +
>  	/* RCU slabs could be legally used after free within the RCU period */
>  	if (unlikely(cache->flags & SLAB_DESTROY_BY_RCU))
>  		return false;
>  
> -	if (likely(cache->flags & SLAB_KASAN)) {
> -		struct kasan_alloc_meta *alloc_info =
> -			get_alloc_info(cache, object);
> -		struct kasan_free_meta *free_info =
> -			get_free_info(cache, object);
> -
> -		switch (alloc_info->state) {
> -		case KASAN_STATE_ALLOC:
> -			alloc_info->state = KASAN_STATE_QUARANTINE;
> -			quarantine_put(free_info, cache);
> -			set_track(&free_info->track, GFP_NOWAIT);
> -			kasan_poison_slab_free(cache, object);
> -			return true;
> -		case KASAN_STATE_QUARANTINE:
> -		case KASAN_STATE_FREE:
> -			pr_err("Double free");
> -			dump_stack();
> -			break;
> -		default:
> -			break;
> -		}
> +	if (unlikely(!(cache->flags & SLAB_KASAN)))
> +		return false;
> +
> +	alloc_info = get_alloc_info(cache, object);
> +	kasan_meta_lock(alloc_info);
> +	alloc_data.packed = alloc_info->data;
> +	if (alloc_data.state == KASAN_STATE_ALLOC) {
> +		free_info = get_free_info(cache, object);
> +		quarantine_put(free_info, cache);

I just pulled master and didn't find this function. If your patchset
is based on other branch, please notice it.

> +		set_track(&free_info->track, GFP_NOWAIT);

It may fail for many reasons. Is it OK to ignore it? If OK, I think it
should be explained.

> +		kasan_poison_slab_free(cache, object);
> +		alloc_data.state = KASAN_STATE_QUARANTINE;
> +		alloc_info->data = alloc_data.packed;
> +		kasan_meta_unlock(alloc_info);
> +		return true;
>  	}
> +	switch (alloc_data.state) {
> +	case KASAN_STATE_QUARANTINE:
> +	case KASAN_STATE_FREE:
> +		kasan_report((unsigned long)object, 0, false,
> +				(unsigned long)__builtin_return_address(1));

__builtin_return_address() is unsafe if argument is non-zero. Use
return_address() instead.

> +		kasan_meta_unlock(alloc_info);
> +		return true;
> +	default:
> +		break;
> +	}
> +	kasan_meta_unlock(alloc_info);
>  	return false;
>  #else
>  	kasan_poison_slab_free(cache, object);
> @@ -568,12 +616,20 @@ void kasan_kmalloc(struct kmem_cache *cache, const void *object, size_t size,
>  		KASAN_KMALLOC_REDZONE);
>  #ifdef CONFIG_SLAB
>  	if (cache->flags & SLAB_KASAN) {
> +		union kasan_alloc_data alloc_data;
>  		struct kasan_alloc_meta *alloc_info =
>  			get_alloc_info(cache, object);
> -
> -		alloc_info->state = KASAN_STATE_ALLOC;
> -		alloc_info->alloc_size = size;
> +		unsigned long flags;
> +
> +		local_irq_save(flags);
> +		kasan_meta_lock(alloc_info);
> +		alloc_data.packed = alloc_info->data;
> +		alloc_data.state = KASAN_STATE_ALLOC;
> +		alloc_data.size_delta = cache->object_size - size;
> +		alloc_info->data = alloc_data.packed;
>  		set_track(&alloc_info->track, flags);

Same as above

> +		kasan_meta_unlock(alloc_info);
> +		local_irq_restore(flags);
>  	}
>  #endif
>  }
> diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
> index 7da78a6..df2724d 100644
> --- a/mm/kasan/kasan.h
> +++ b/mm/kasan/kasan.h
> @@ -73,10 +73,19 @@ struct kasan_track {
>  	depot_stack_handle_t stack;
>  };
>  
> +union kasan_alloc_data {
> +	struct {
> +		u32 lock : 1;
> +		u32 state : 2;		/* enum kasan_state */
> +		u32 size_delta : 24;	/* object_size - alloc size */
> +		u32 unused : 5;
> +	};
> +	u32 packed;
> +};
> +
>  struct kasan_alloc_meta {
>  	struct kasan_track track;
> -	u32 state : 2;	/* enum kasan_state */
> -	u32 alloc_size : 30;
> +	u32 data;	/* encoded as union kasan_alloc_data */
>  	u32 reserved;
>  };
>  
> @@ -112,4 +121,6 @@ void quarantine_put(struct kasan_free_meta *info, struct kmem_cache *cache);
>  void quarantine_reduce(void);
>  void quarantine_remove_cache(struct kmem_cache *cache);
>  
> +void kasan_meta_lock(struct kasan_alloc_meta *alloc_info);
> +void kasan_meta_unlock(struct kasan_alloc_meta *alloc_info);
>  #endif
> diff --git a/mm/kasan/quarantine.c b/mm/kasan/quarantine.c
> index 40159a6..d59a569 100644
> --- a/mm/kasan/quarantine.c
> +++ b/mm/kasan/quarantine.c
> @@ -144,10 +144,15 @@ static void qlink_free(void **qlink, struct kmem_cache *cache)
>  {
>  	void *object = qlink_to_object(qlink, cache);
>  	struct kasan_alloc_meta *alloc_info = get_alloc_info(cache, object);
> +	union kasan_alloc_data alloc_data;
>  	unsigned long flags;
>  
>  	local_irq_save(flags);
> -	alloc_info->state = KASAN_STATE_FREE;
> +	kasan_meta_lock(alloc_info);
> +	alloc_data.packed = alloc_info->data;
> +	alloc_data.state = KASAN_STATE_FREE;
> +	alloc_info->data = alloc_data.packed;
> +	kasan_meta_unlock(alloc_info);
>  	___cache_free(cache, object, _THIS_IP_);
>  	local_irq_restore(flags);
>  }
> diff --git a/mm/kasan/report.c b/mm/kasan/report.c
> index b3c122d..cecf2fa 100644
> --- a/mm/kasan/report.c
> +++ b/mm/kasan/report.c
> @@ -53,6 +53,17 @@ static void print_error_description(struct kasan_access_info *info)
>  	const char *bug_type = "unknown-crash";
>  	u8 *shadow_addr;
>  
> +#ifdef CONFIG_SLAB
> +	if (!info->access_size) {
> +		pr_err("BUG: KASAN: double-free attempt in %pS on object at addr %p\n",
> +				(void *)info->ip, info->access_addr);
> +		pr_err("Double free by task %s/%d\n",
> +				current->comm, task_pid_nr(current));
> +		info->first_bad_addr = info->access_addr;
> +		return;
> +	}
> +#endif
> +
>  	info->first_bad_addr = find_first_bad_addr(info->access_addr,
>  						info->access_size);
>  
> @@ -131,29 +142,34 @@ static void print_track(struct kasan_track *track)
>  }
>  
>  static void object_err(struct kmem_cache *cache, struct page *page,
> -			void *object, char *unused_reason)
> +		void *object, char *unused_reason,
> +		struct kasan_access_info *info)
>  {
>  	struct kasan_alloc_meta *alloc_info = get_alloc_info(cache, object);
>  	struct kasan_free_meta *free_info;
> +	union kasan_alloc_data alloc_data;
>  
>  	dump_stack();
>  	pr_err("Object at %p, in cache %s\n", object, cache->name);
>  	if (!(cache->flags & SLAB_KASAN))
>  		return;
> -	switch (alloc_info->state) {
> +	if (info->access_size)
> +		kasan_meta_lock(alloc_info);
> +	alloc_data.packed = alloc_info->data;
> +	switch (alloc_data.state) {
>  	case KASAN_STATE_INIT:
>  		pr_err("Object not allocated yet\n");
>  		break;
>  	case KASAN_STATE_ALLOC:
>  		pr_err("Object allocated with size %u bytes.\n",
> -		       alloc_info->alloc_size);
> +				(cache->object_size - alloc_data.size_delta));
>  		pr_err("Allocation:\n");
>  		print_track(&alloc_info->track);
>  		break;
>  	case KASAN_STATE_FREE:
>  	case KASAN_STATE_QUARANTINE:
>  		pr_err("Object freed, allocated with size %u bytes\n",
> -		       alloc_info->alloc_size);
> +				(cache->object_size - alloc_data.size_delta));
>  		free_info = get_free_info(cache, object);
>  		pr_err("Allocation:\n");
>  		print_track(&alloc_info->track);
> @@ -161,6 +177,8 @@ static void object_err(struct kmem_cache *cache, struct page *page,
>  		print_track(&free_info->track);
>  		break;
>  	}
> +	if (info->access_size)
> +		kasan_meta_unlock(alloc_info);
>  }
>  #endif
>  
> @@ -177,8 +195,13 @@ static void print_address_description(struct kasan_access_info *info)
>  			struct kmem_cache *cache = page->slab_cache;
>  			object = nearest_obj(cache, page,
>  						(void *)info->access_addr);
> +#ifdef CONFIG_SLAB
> +			object_err(cache, page, object,
> +					"kasan: bad access detected", info);
> +#else
>  			object_err(cache, page, object,
>  					"kasan: bad access detected");
> +#endif
>  			return;
>  		}
>  		dump_page(page, "kasan: bad access detected");
> diff --git a/mm/slab.c b/mm/slab.c
> index 3f20800..110d586 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -2651,6 +2651,7 @@ static void cache_init_objs(struct kmem_cache *cachep,
>  			cachep->ctor(objp);
>  			kasan_poison_object_data(cachep, objp);
>  		}
> +		kasan_init_object(cachep, index_to_obj(cachep, page, i));
>  
>  		if (!shuffled)
>  			set_free_obj(page, i, i);
> -- 
> 1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
