Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id 61B5682F64
	for <linux-mm@kvack.org>; Fri, 30 Oct 2015 05:22:18 -0400 (EDT)
Received: by lbbwb3 with SMTP id wb3so46229363lbb.1
        for <linux-mm@kvack.org>; Fri, 30 Oct 2015 02:22:17 -0700 (PDT)
Received: from mail-lb0-x233.google.com (mail-lb0-x233.google.com. [2a00:1450:4010:c04::233])
        by mx.google.com with ESMTPS id d189si4158656lfe.94.2015.10.30.02.22.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Oct 2015 02:22:16 -0700 (PDT)
Received: by lbbes7 with SMTP id es7so46155392lbb.2
        for <linux-mm@kvack.org>; Fri, 30 Oct 2015 02:22:16 -0700 (PDT)
Subject: Re: [PATCH 2/2] mm: kasan: unified support for SLUB and SLAB
 allocators
References: <1446050504-40376-1-git-send-email-glider@google.com>
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Message-ID: <563336DF.5050706@gmail.com>
Date: Fri, 30 Oct 2015 12:22:39 +0300
MIME-Version: 1.0
In-Reply-To: <1446050504-40376-1-git-send-email-glider@google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Christoph Lameter <cl@linux.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dmitriy Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 10/28/2015 07:41 PM, Alexander Potapenko wrote:
> With this patch kasan can be compiled with both SLAB and SLUB allocators,
> using minimal dependencies on allocator internal structures and minimum
> allocator-dependent code.
> 
> Dependency from SLUB_DEBUG is also removed. The metadata storage is made
> more efficient, so the redzones aren't as large for small objects. The
> redzone size is calculated based on the object size.
> 
> This is the second part of the "mm: kasan: unified support for SLUB and
> SLAB allocators" patch originally prepared by Dmitry Chernenkov.
> 
> Signed-off-by: Dmitry Chernenkov <dmitryc@google.com>
> Signed-off-by: Alexander Potapenko <glider@google.com>
> 

Besides adding SLAB support, this patch seriously messes up SLUB-KASAN part.
Changelog doesn't mention why this was done and what was done.
So this patch should be split into two patches at least, 1 - mess up SLUB part,
2 - add SLAB support.
And "mess up SLUB part" patch should very well explain why doing what you are doing.
E.g. you just removed user tracking (object's Alloc/Free backtraces), and I'm failing
to see, how this is an improvement.
Therefore I didn't look into details, just commented some evident things, see below.

> + ==================================================================
> + BUG: KASan: out of bounds access in kmalloc_oob_right+0xce/0x117 [test_kasan] at addr ffff8800b91250fb
> + Read of size 1 by task insmod/2754
> + CPU: 0 PID: 2754 Comm: insmod Not tainted 4.0.0-rc4+ #1
> + Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> +  ffff8800b9125080 ffff8800b9aff958 ffffffff82c97b9e 0000000000000022
> +  ffff8800b9affa00 ffff8800b9aff9e8 ffffffff813fc8c9 ffff8800b9aff988
> +  ffffffff813fb3ff ffff8800b9aff998 0000000000000296 000000000000007b
> + Call Trace:
> +  [<ffffffff82c97b9e>] dump_stack+0x45/0x57
> +  [<ffffffff813fc8c9>] kasan_report_error+0x129/0x420
> +  [<ffffffff813fb3ff>] ? kasan_poison_shadow+0x2f/0x40
> +  [<ffffffff813fb3ff>] ? kasan_poison_shadow+0x2f/0x40
> +  [<ffffffff813fbeff>] ? kasan_kmalloc+0x5f/0x100
> +  [<ffffffffa0008f3d>] ? kmalloc_node_oob_right+0x11f/0x11f [test_kasan]
> +  [<ffffffff813fcc05>] __asan_report_load1_noabort+0x45/0x50
> +  [<ffffffffa0008f00>] ? kmalloc_node_oob_right+0xe2/0x11f [test_kasan]
> +  [<ffffffffa00087bf>] ? kmalloc_oob_right+0xce/0x117 [test_kasan]
> +  [<ffffffffa00087bf>] kmalloc_oob_right+0xce/0x117 [test_kasan]
> +  [<ffffffffa00086f1>] ? kmalloc_oob_left+0xe9/0xe9 [test_kasan]
> +  [<ffffffff819cc140>] ? kvasprintf+0xf0/0xf0
> +  [<ffffffffa00086f1>] ? kmalloc_oob_left+0xe9/0xe9 [test_kasan]
> +  [<ffffffffa000001e>] run_test+0x1e/0x40 [test_kasan]
> +  [<ffffffffa0008f54>] init_module+0x17/0x128 [test_kasan]
> +  [<ffffffff81000351>] do_one_initcall+0x111/0x2b0
> +  [<ffffffff81000240>] ? try_to_run_init_process+0x40/0x40
> +  [<ffffffff813fb3ff>] ? kasan_poison_shadow+0x2f/0x40
> +  [<ffffffff813fbeff>] ? kasan_kmalloc+0x5f/0x100
> +  [<ffffffff813fb3ff>] ? kasan_poison_shadow+0x2f/0x40
> +  [<ffffffff813fbde4>] ? kasan_unpoison_shadow+0x14/0x40
> +  [<ffffffff813fb3ff>] ? kasan_poison_shadow+0x2f/0x40
> +  [<ffffffff813fbe80>] ? __asan_register_globals+0x70/0x90
> +  [<ffffffff82c934a4>] do_init_module+0x1d2/0x531
> +  [<ffffffff8122d5bf>] load_module+0x55cf/0x73e0
> +  [<ffffffff81224020>] ? symbol_put_addr+0x50/0x50
> +  [<ffffffff81227ff0>] ? module_frob_arch_sections+0x20/0x20
> +  [<ffffffff810c213a>] ? trace_do_page_fault+0x6a/0x1d0
> +  [<ffffffff810b5454>] ? do_async_page_fault+0x14/0x80
> +  [<ffffffff82cb0c88>] ? async_page_fault+0x28/0x30
> +  [<ffffffff8122f4da>] SyS_init_module+0x10a/0x140
> +  [<ffffffff8122f3d0>] ? load_module+0x73e0/0x73e0
> +  [<ffffffff82caef89>] system_call_fastpath+0x12/0x17
> + Object at ffff8800b9125080, in cache kmalloc-128
> + Object allocated with size 123 bytes.
> + Allocation:
> + PID = 2754, CPU = 0, timestamp = 4294707705

Really? Just this instead of Alloc/Free backtraces?


> + Memory state around the buggy address:
> +  ffff8800b9124f80: fc fc fc fc fc fc fc fc 00 00 00 00 00 00 00 00
> +  ffff8800b9125000: 00 00 00 00 00 fc fc fc fc fc fc fc fc fc fc fc
> + >ffff8800b9125080: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 03
> +                                                                 ^
> +  ffff8800b9125100: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
> +  ffff8800b9125180: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
> + ==================================================================
>  
>  In the last section the report shows memory state around the accessed address.
>  Reading this part requires some more understanding of how KASAN works.
> diff --git a/include/linux/kasan.h b/include/linux/kasan.h
> index e1ce960..e37d934 100644
> --- a/include/linux/kasan.h
> +++ b/include/linux/kasan.h
> @@ -7,6 +7,12 @@ struct kmem_cache;
>  struct page;
>  struct vm_struct;
>  
> +#ifdef SLAB
> +#define cache_size_t size_t
> +#else
> +#define cache_size_t unsigned long
> +#endif
> +

Ugh... Why we can't use same type in all allocators?

>  #ifdef CONFIG_KASAN
>  
>  #define KASAN_SHADOW_SCALE_SHIFT 3
> @@ -46,6 +52,9 @@ void kasan_unpoison_shadow(const void *address, size_t size);
>  void kasan_alloc_pages(struct page *page, unsigned int order);
>  void kasan_free_pages(struct page *page, unsigned int order);
>  
> +void kasan_cache_create(struct kmem_cache *cache, cache_size_t *size,
> +			unsigned long *flags);
> +
>  void kasan_poison_slab(struct page *page);
>  void kasan_unpoison_object_data(struct kmem_cache *cache, void *object);
>  void kasan_poison_object_data(struct kmem_cache *cache, void *object);
> @@ -60,6 +69,11 @@ void kasan_krealloc(const void *object, size_t new_size, gfp_t flags);
>  void kasan_slab_alloc(struct kmem_cache *s, void *object, gfp_t flags);
>  void kasan_slab_free(struct kmem_cache *s, void *object);
>  
> +struct kasan_cache {
> +	int alloc_meta_offset;
> +	int free_meta_offset;
> +};
> +
>  int kasan_module_alloc(void *addr, size_t size);
>  void kasan_free_shadow(const struct vm_struct *vm);
>  
> @@ -73,6 +87,10 @@ static inline void kasan_disable_current(void) {}
>  static inline void kasan_alloc_pages(struct page *page, unsigned int order) {}
>  static inline void kasan_free_pages(struct page *page, unsigned int order) {}
>  
> +static inline void kasan_cache_create(struct kmem_cache *cache,
> +				      cache_size_t *size,
> +				      unsigned long *flags) {}
> +
>  static inline void kasan_poison_slab(struct page *page) {}
>  static inline void kasan_unpoison_object_data(struct kmem_cache *cache,
>  					void *object) {}
> diff --git a/include/linux/slab.h b/include/linux/slab.h
> index 7e37d44..b4de362 100644
> --- a/include/linux/slab.h
> +++ b/include/linux/slab.h
> @@ -87,6 +87,12 @@
>  # define SLAB_FAILSLAB		0x00000000UL
>  #endif
>  
> +#ifdef CONFIG_KASAN
> +#define SLAB_KASAN		0x08000000UL
> +#else
> +#define SLAB_KASAN		0x00000000UL
> +#endif
> +

What's this for? KASAN tracks all kmem_caches, so why we need the runtime flag?


> diff --git a/lib/test_kasan.c b/lib/test_kasan.c
> index c1efb1b..0ae338c 100644
> --- a/lib/test_kasan.c
> +++ b/lib/test_kasan.c
> @@ -259,7 +259,9 @@ static int __init kmalloc_tests_init(void)
>  	kmalloc_oob_right();
>  	kmalloc_oob_left();
>  	kmalloc_node_oob_right();
> +#ifdef CONFIG_SLUB
>  	kmalloc_large_oob_right();
> +#endif

I don't understand this.


>  
> diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
> index c242adf..6530880 100644
> --- a/mm/kasan/kasan.h
> +++ b/mm/kasan/kasan.h
> @@ -54,6 +54,39 @@ struct kasan_global {
>  #endif
>  };
>  
> +/**
> + * Structures to keep alloc and free tracks *
> + */
> +
> +enum kasan_state {
> +	KASAN_STATE_INIT,
> +	KASAN_STATE_ALLOC,
> +	KASAN_STATE_FREE
> +};
> +
> +/* TODO: rethink the structs and field sizes */
> +struct kasan_track {
> +	u64 cpu : 6;			/* for NR_CPUS = 64 */
> +	u64 pid : 16;			/* 65536 processes */
> +	u64 when : 48;			/* ~9000 years */
> +};
> +
> +struct kasan_alloc_meta {
> +	enum kasan_state state : 2;
> +	size_t alloc_size : 30;
> +	struct kasan_track track;
> +};
> +
> +struct kasan_free_meta {
> +	void **freelist;

This field is unused.


> +	struct kasan_track track;
> +};
> +
> +struct kasan_alloc_meta *get_alloc_info(struct kmem_cache *cache,
> +				   const void *object);
> +struct kasan_free_meta *get_free_info(struct kmem_cache *cache,
> +				 const void *object);
> +
>  void kasan_report_error(struct kasan_access_info *info);
>  void kasan_report_user_access(struct kasan_access_info *info);
>  
> diff --git a/mm/kasan/report.c b/mm/kasan/report.c
> index e07c94f..7dbe5be 100644
> --- a/mm/kasan/report.c
> +++ b/mm/kasan/report.c
> @@ -97,6 +97,58 @@ static inline bool init_task_stack_addr(const void *addr)
>  			sizeof(init_thread_union.stack));
>  }
>  
> +static void print_track(struct kasan_track *track)
> +{
> +	pr_err("PID = %lu, CPU = %lu, timestamp = %lu\n", track->pid,
> +	       track->cpu, track->when);
> +}
> +
> +static void print_object(struct kmem_cache *cache, void *object)
> +{
> +	struct kasan_alloc_meta *alloc_info = get_alloc_info(cache, object);
> +	struct kasan_free_meta *free_info;
> +
> +	pr_err("Object at %p, in cache %s\n", object, cache->name);
> +	if (!(cache->flags & SLAB_KASAN))
> +		return;
> +	switch (alloc_info->state) {
> +	case KASAN_STATE_INIT:
> +		pr_err("Object not allocated yet\n");
> +		break;
> +	case KASAN_STATE_ALLOC:
> +		pr_err("Object allocated with size %lu bytes.\n",
> +		       alloc_info->alloc_size);
> +		pr_err("Allocation:\n");
> +		print_track(&alloc_info->track);
> +		break;
> +	case KASAN_STATE_FREE:
> +		pr_err("Object freed, allocated with size %lu bytes\n",
> +		       alloc_info->alloc_size);
> +		free_info = get_free_info(cache, object);
> +		pr_err("Allocation:\n");
> +		print_track(&alloc_info->track);
> +		pr_err("Deallocation:\n");
> +		print_track(&free_info->track);
> +		break;
> +	}
> +}
> +
> +static inline void *nearest_obj(struct kmem_cache *cache, struct page *page,
> +				void *x) {
> +#if defined(CONFIG_SLUB)
> +	void *object = x - (x - page_address(page)) % cache->size;
> +	void *last_object = page_address(page) +
> +		(page->objects - 1) * cache->size;
> +#elif defined(CONFIG_SLAB)
> +	void *object = x - (x - page->s_mem) % cache->size;
> +	void *last_object = page->s_mem + (cache->num - 1) * cache->size;
> +#endif

Instead of ifdefs, provide functions per allocator in respective headers (include/linux/sl?b_def.h).

> +	if (unlikely(object > last_object))
> +		return last_object;
> +	else
> +		return object;
> +}
> +
>  static void print_address_description(struct kasan_access_info *info)
>  {
>  	const void *addr = info->access_addr;
> @@ -108,17 +160,10 @@ static void print_address_description(struct kasan_access_info *info)
>  		if (PageSlab(page)) {
>  			void *object;
>  			struct kmem_cache *cache = page->slab_cache;
> -			void *last_object;
> -
> -			object = virt_to_obj(cache, page_address(page), addr);
> -			last_object = page_address(page) +
> -				page->objects * cache->size;
>  
> -			if (unlikely(object > last_object))
> -				object = last_object; /* we hit into padding */
> -
> -			object_err(cache, page, object,
> -				"kasan: bad access detected");
> +			object = nearest_obj(cache, page,
> +					(void *)info->access_addr);
> +			print_object(cache, object);
>  			return;
>  		}
>  		dump_page(page, "kasan: bad access detected");
> @@ -128,8 +173,6 @@ static void print_address_description(struct kasan_access_info *info)
>  		if (!init_task_stack_addr(addr))
>  			pr_err("Address belongs to variable %pS\n", addr);
>  	}
> -
> -	dump_stack();
>  }
>  
>  static bool row_is_guilty(const void *row, const void *guilty)
> @@ -186,21 +229,25 @@ void kasan_report_error(struct kasan_access_info *info)
>  {
>  	unsigned long flags;
>  
> +	kasan_disable_current();

We already have patch doing this in -mm tree.

>  	spin_lock_irqsave(&report_lock, flags);
>  	pr_err("================================="
>  		"=================================\n");
>  	print_error_description(info);
> +	dump_stack();
>  	print_address_description(info);
>  	print_shadow_for_address(info->first_bad_addr);
>  	pr_err("================================="
>  		"=================================\n");
>  	spin_unlock_irqrestore(&report_lock, flags);
> +	kasan_enable_current();
>  }
>  



>  	slab_bug(s, "%s", reason);
> @@ -1303,7 +1308,6 @@ static inline void slab_free_hook(struct kmem_cache *s, void *x)
>  	if (!(s->flags & SLAB_DEBUG_OBJECTS))
>  		debug_check_no_obj_freed(x, s->object_size);
>  
> -	kasan_slab_free(s, x);
>  }
>  

...

> @@ -2698,6 +2703,15 @@ slab_empty:
>  static __always_inline void slab_free(struct kmem_cache *s,
>  			struct page *page, void *x, unsigned long addr)
>  {
> +#ifdef CONFIG_KASAN
> +	kasan_slab_free(s, x);
> +	nokasan_free(s, x, addr);
> +}
> +
> +void nokasan_free(struct kmem_cache *s, void *x, unsigned long addr)
> +{
> +	struct page *page = virt_to_head_page(x);
> +#endif

What is this? The only reason I could imagine for this crap is, to make
this code ugly. This change has no any functional effect.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
