Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f171.google.com (mail-ob0-f171.google.com [209.85.214.171])
	by kanga.kvack.org (Postfix) with ESMTP id BBCD76B0032
	for <linux-mm@kvack.org>; Mon, 15 Dec 2014 23:08:04 -0500 (EST)
Received: by mail-ob0-f171.google.com with SMTP id uz6so21188457obc.2
        for <linux-mm@kvack.org>; Mon, 15 Dec 2014 20:08:04 -0800 (PST)
Received: from mail-ob0-x233.google.com (mail-ob0-x233.google.com. [2607:f8b0:4003:c01::233])
        by mx.google.com with ESMTPS id im2si7063845oeb.14.2014.12.15.20.08.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 15 Dec 2014 20:08:03 -0800 (PST)
Received: by mail-ob0-f179.google.com with SMTP id va2so21339114obc.10
        for <linux-mm@kvack.org>; Mon, 15 Dec 2014 20:08:02 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20141216003941.GA17665@blaptop>
References: <1418478203-17687-1-git-send-email-opensource.ganesh@gmail.com>
	<20141216003941.GA17665@blaptop>
Date: Tue, 16 Dec 2014 12:08:02 +0800
Message-ID: <CADAEsF99yOT0ZHD3yDxT_tOM-48=3gut+-GB6SR5BBZxZ_XY6w@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm/zsmalloc: adjust order of functions
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

Hello Minchan,


2014-12-16 8:40 GMT+08:00 Minchan Kim <minchan@kernel.org>:
> Hello Ganesh,
>
> On Sat, Dec 13, 2014 at 09:43:23PM +0800, Ganesh Mahendran wrote:
>> Currently functions in zsmalloc.c does not arranged in a readable
>> and reasonable sequence. With the more and more functions added,
>> we may meet below inconvenience. For example:
>>
>> Current functions:
>>     void zs_init()
>>     {
>>     }
>>
>>     static void get_maxobj_per_zspage()
>>     {
>>     }
>>
>> Then I want to add a func_1() which is called from zs_init(), and this new added
>> function func_1() will used get_maxobj_per_zspage() which is defined below zs_init().
>>
>>     void func_1()
>>     {
>>         get_maxobj_per_zspage()
>>     }
>>
>>     void zs_init()
>>     {
>>         func_1()
>>     }
>>
>>     static void get_maxobj_per_zspage()
>>     {
>>     }
>>
>> This will cause compiling issue. So we must add a declaration:
>>     static void get_maxobj_per_zspage();
>> before func_1() if we do not put get_maxobj_per_zspage() before func_1().
>
> Yes, I suffered from that when I made compaction but was not sure
> it's it was obviously wrong.
> Stupid question:
> What's the problem if we should put function declaration on top of
> source code?

There is no problem if we do this. But if we obey to some coding
style, then it will
be convenient for the later developers.
Normally I put the global or important interface function at the
bottom of the file, and
the static or helper functions on the top. Because usually global
functions is the caller, and
static functions is the callee.

>
>>
>> In addition, puting module_[init|exit] functions at the bottom of the file
>> conforms to our habit.
>
> Normally, we do but without any strong reason, I don't want to rub git-blame
> by clean up patches.

Sorry, I did not consider this when I made this patch.:)

>
> In summary, I like this patch but don't like to churn git-blame by clean-up
> patchset without strong reason so I need something I am sure.

Now, zsmalloc module is active in development. More and more changes
will be included.
If we do not clean up, then this file may looks messy.

Thanks a lot.

>
>>
>> So, this patch ajusts function sequence as:
>>     /* helper functions */
>>     ...
>>     obj_location_to_handle()
>>     ...
>>
>>     /* Some exported functions */
>>     ...
>>
>>     zs_map_object()
>>     zs_unmap_object()
>>
>>     zs_malloc()
>>     zs_free()
>>
>>     zs_init()
>>     zs_exit()
>>
>> Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
>> ---
>>  mm/zsmalloc.c |  374 ++++++++++++++++++++++++++++-----------------------------
>>  1 file changed, 187 insertions(+), 187 deletions(-)
>>
>> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
>> index 4d0a063..b724039 100644
>> --- a/mm/zsmalloc.c
>> +++ b/mm/zsmalloc.c
>> @@ -884,19 +884,6 @@ static struct notifier_block zs_cpu_nb = {
>>       .notifier_call = zs_cpu_notifier
>>  };
>>
>> -static void zs_unregister_cpu_notifier(void)
>> -{
>> -     int cpu;
>> -
>> -     cpu_notifier_register_begin();
>> -
>> -     for_each_online_cpu(cpu)
>> -             zs_cpu_notifier(NULL, CPU_DEAD, (void *)(long)cpu);
>> -     __unregister_cpu_notifier(&zs_cpu_nb);
>> -
>> -     cpu_notifier_register_done();
>> -}
>> -
>>  static int zs_register_cpu_notifier(void)
>>  {
>>       int cpu, uninitialized_var(ret);
>> @@ -914,40 +901,28 @@ static int zs_register_cpu_notifier(void)
>>       return notifier_to_errno(ret);
>>  }
>>
>> -static void init_zs_size_classes(void)
>> +static void zs_unregister_cpu_notifier(void)
>>  {
>> -     int nr;
>> +     int cpu;
>>
>> -     nr = (ZS_MAX_ALLOC_SIZE - ZS_MIN_ALLOC_SIZE) / ZS_SIZE_CLASS_DELTA + 1;
>> -     if ((ZS_MAX_ALLOC_SIZE - ZS_MIN_ALLOC_SIZE) % ZS_SIZE_CLASS_DELTA)
>> -             nr += 1;
>> +     cpu_notifier_register_begin();
>>
>> -     zs_size_classes = nr;
>> -}
>> +     for_each_online_cpu(cpu)
>> +             zs_cpu_notifier(NULL, CPU_DEAD, (void *)(long)cpu);
>> +     __unregister_cpu_notifier(&zs_cpu_nb);
>>
>> -static void __exit zs_exit(void)
>> -{
>> -#ifdef CONFIG_ZPOOL
>> -     zpool_unregister_driver(&zs_zpool_driver);
>> -#endif
>> -     zs_unregister_cpu_notifier();
>> +     cpu_notifier_register_done();
>>  }
>>
>> -static int __init zs_init(void)
>> +static void init_zs_size_classes(void)
>>  {
>> -     int ret = zs_register_cpu_notifier();
>> -
>> -     if (ret) {
>> -             zs_unregister_cpu_notifier();
>> -             return ret;
>> -     }
>> +     int nr;
>>
>> -     init_zs_size_classes();
>> +     nr = (ZS_MAX_ALLOC_SIZE - ZS_MIN_ALLOC_SIZE) / ZS_SIZE_CLASS_DELTA + 1;
>> +     if ((ZS_MAX_ALLOC_SIZE - ZS_MIN_ALLOC_SIZE) % ZS_SIZE_CLASS_DELTA)
>> +             nr += 1;
>>
>> -#ifdef CONFIG_ZPOOL
>> -     zpool_register_driver(&zs_zpool_driver);
>> -#endif
>> -     return 0;
>> +     zs_size_classes = nr;
>>  }
>>
>>  static unsigned int get_maxobj_per_zspage(int size, int pages_per_zspage)
>> @@ -967,113 +942,101 @@ static bool can_merge(struct size_class *prev, int size, int pages_per_zspage)
>>       return true;
>>  }
>>
>> +unsigned long zs_get_total_pages(struct zs_pool *pool)
>> +{
>> +     return atomic_long_read(&pool->pages_allocated);
>> +}
>> +EXPORT_SYMBOL_GPL(zs_get_total_pages);
>> +
>>  /**
>> - * zs_create_pool - Creates an allocation pool to work from.
>> - * @flags: allocation flags used to allocate pool metadata
>> + * zs_map_object - get address of allocated object from handle.
>> + * @pool: pool from which the object was allocated
>> + * @handle: handle returned from zs_malloc
>>   *
>> - * This function must be called before anything when using
>> - * the zsmalloc allocator.
>> + * Before using an object allocated from zs_malloc, it must be mapped using
>> + * this function. When done with the object, it must be unmapped using
>> + * zs_unmap_object.
>>   *
>> - * On success, a pointer to the newly created pool is returned,
>> - * otherwise NULL.
>> + * Only one object can be mapped per cpu at a time. There is no protection
>> + * against nested mappings.
>> + *
>> + * This function returns with preemption and page faults disabled.
>>   */
>> -struct zs_pool *zs_create_pool(gfp_t flags)
>> +void *zs_map_object(struct zs_pool *pool, unsigned long handle,
>> +                     enum zs_mapmode mm)
>>  {
>> -     int i;
>> -     struct zs_pool *pool;
>> -     struct size_class *prev_class = NULL;
>> +     struct page *page;
>> +     unsigned long obj_idx, off;
>>
>> -     pool = kzalloc(sizeof(*pool), GFP_KERNEL);
>> -     if (!pool)
>> -             return NULL;
>> +     unsigned int class_idx;
>> +     enum fullness_group fg;
>> +     struct size_class *class;
>> +     struct mapping_area *area;
>> +     struct page *pages[2];
>>
>> -     pool->size_class = kcalloc(zs_size_classes, sizeof(struct size_class *),
>> -                     GFP_KERNEL);
>> -     if (!pool->size_class) {
>> -             kfree(pool);
>> -             return NULL;
>> -     }
>> +     BUG_ON(!handle);
>>
>>       /*
>> -      * Iterate reversly, because, size of size_class that we want to use
>> -      * for merging should be larger or equal to current size.
>> +      * Because we use per-cpu mapping areas shared among the
>> +      * pools/users, we can't allow mapping in interrupt context
>> +      * because it can corrupt another users mappings.
>>        */
>> -     for (i = zs_size_classes - 1; i >= 0; i--) {
>> -             int size;
>> -             int pages_per_zspage;
>> -             struct size_class *class;
>> -
>> -             size = ZS_MIN_ALLOC_SIZE + i * ZS_SIZE_CLASS_DELTA;
>> -             if (size > ZS_MAX_ALLOC_SIZE)
>> -                     size = ZS_MAX_ALLOC_SIZE;
>> -             pages_per_zspage = get_pages_per_zspage(size);
>> -
>> -             /*
>> -              * size_class is used for normal zsmalloc operation such
>> -              * as alloc/free for that size. Although it is natural that we
>> -              * have one size_class for each size, there is a chance that we
>> -              * can get more memory utilization if we use one size_class for
>> -              * many different sizes whose size_class have same
>> -              * characteristics. So, we makes size_class point to
>> -              * previous size_class if possible.
>> -              */
>> -             if (prev_class) {
>> -                     if (can_merge(prev_class, size, pages_per_zspage)) {
>> -                             pool->size_class[i] = prev_class;
>> -                             continue;
>> -                     }
>> -             }
>> -
>> -             class = kzalloc(sizeof(struct size_class), GFP_KERNEL);
>> -             if (!class)
>> -                     goto err;
>> +     BUG_ON(in_interrupt());
>>
>> -             class->size = size;
>> -             class->index = i;
>> -             class->pages_per_zspage = pages_per_zspage;
>> -             spin_lock_init(&class->lock);
>> -             pool->size_class[i] = class;
>> +     obj_handle_to_location(handle, &page, &obj_idx);
>> +     get_zspage_mapping(get_first_page(page), &class_idx, &fg);
>> +     class = pool->size_class[class_idx];
>> +     off = obj_idx_to_offset(page, obj_idx, class->size);
>>
>> -             prev_class = class;
>> +     area = &get_cpu_var(zs_map_area);
>> +     area->vm_mm = mm;
>> +     if (off + class->size <= PAGE_SIZE) {
>> +             /* this object is contained entirely within a page */
>> +             area->vm_addr = kmap_atomic(page);
>> +             return area->vm_addr + off;
>>       }
>>
>> -     pool->flags = flags;
>> -
>> -     return pool;
>> +     /* this object spans two pages */
>> +     pages[0] = page;
>> +     pages[1] = get_next_page(page);
>> +     BUG_ON(!pages[1]);
>>
>> -err:
>> -     zs_destroy_pool(pool);
>> -     return NULL;
>> +     return __zs_map_object(area, pages, off, class->size);
>>  }
>> -EXPORT_SYMBOL_GPL(zs_create_pool);
>> +EXPORT_SYMBOL_GPL(zs_map_object);
>>
>> -void zs_destroy_pool(struct zs_pool *pool)
>> +void zs_unmap_object(struct zs_pool *pool, unsigned long handle)
>>  {
>> -     int i;
>> +     struct page *page;
>> +     unsigned long obj_idx, off;
>>
>> -     for (i = 0; i < zs_size_classes; i++) {
>> -             int fg;
>> -             struct size_class *class = pool->size_class[i];
>> +     unsigned int class_idx;
>> +     enum fullness_group fg;
>> +     struct size_class *class;
>> +     struct mapping_area *area;
>>
>> -             if (!class)
>> -                     continue;
>> +     BUG_ON(!handle);
>>
>> -             if (class->index != i)
>> -                     continue;
>> +     obj_handle_to_location(handle, &page, &obj_idx);
>> +     get_zspage_mapping(get_first_page(page), &class_idx, &fg);
>> +     class = pool->size_class[class_idx];
>> +     off = obj_idx_to_offset(page, obj_idx, class->size);
>>
>> -             for (fg = 0; fg < _ZS_NR_FULLNESS_GROUPS; fg++) {
>> -                     if (class->fullness_list[fg]) {
>> -                             pr_info("Freeing non-empty class with size %db, fullness group %d\n",
>> -                                     class->size, fg);
>> -                     }
>> -             }
>> -             kfree(class);
>> -     }
>> +     area = this_cpu_ptr(&zs_map_area);
>> +     if (off + class->size <= PAGE_SIZE)
>> +             kunmap_atomic(area->vm_addr);
>> +     else {
>> +             struct page *pages[2];
>>
>> -     kfree(pool->size_class);
>> -     kfree(pool);
>> +             pages[0] = page;
>> +             pages[1] = get_next_page(page);
>> +             BUG_ON(!pages[1]);
>> +
>> +             __zs_unmap_object(area, pages, off, class->size);
>> +     }
>> +     put_cpu_var(zs_map_area);
>>  }
>> -EXPORT_SYMBOL_GPL(zs_destroy_pool);
>> +EXPORT_SYMBOL_GPL(zs_unmap_object);
>>
>>  /**
>>   * zs_malloc - Allocate block of given size from pool.
>> @@ -1176,100 +1139,137 @@ void zs_free(struct zs_pool *pool, unsigned long obj)
>>  EXPORT_SYMBOL_GPL(zs_free);
>>
>>  /**
>> - * zs_map_object - get address of allocated object from handle.
>> - * @pool: pool from which the object was allocated
>> - * @handle: handle returned from zs_malloc
>> - *
>> - * Before using an object allocated from zs_malloc, it must be mapped using
>> - * this function. When done with the object, it must be unmapped using
>> - * zs_unmap_object.
>> + * zs_create_pool - Creates an allocation pool to work from.
>> + * @flags: allocation flags used to allocate pool metadata
>>   *
>> - * Only one object can be mapped per cpu at a time. There is no protection
>> - * against nested mappings.
>> + * This function must be called before anything when using
>> + * the zsmalloc allocator.
>>   *
>> - * This function returns with preemption and page faults disabled.
>> + * On success, a pointer to the newly created pool is returned,
>> + * otherwise NULL.
>>   */
>> -void *zs_map_object(struct zs_pool *pool, unsigned long handle,
>> -                     enum zs_mapmode mm)
>> +struct zs_pool *zs_create_pool(gfp_t flags)
>>  {
>> -     struct page *page;
>> -     unsigned long obj_idx, off;
>> +     int i;
>> +     struct zs_pool *pool;
>> +     struct size_class *prev_class = NULL;
>>
>> -     unsigned int class_idx;
>> -     enum fullness_group fg;
>> -     struct size_class *class;
>> -     struct mapping_area *area;
>> -     struct page *pages[2];
>> +     pool = kzalloc(sizeof(*pool), GFP_KERNEL);
>> +     if (!pool)
>> +             return NULL;
>>
>> -     BUG_ON(!handle);
>> +     pool->size_class = kcalloc(zs_size_classes, sizeof(struct size_class *),
>> +                     GFP_KERNEL);
>> +     if (!pool->size_class) {
>> +             kfree(pool);
>> +             return NULL;
>> +     }
>>
>>       /*
>> -      * Because we use per-cpu mapping areas shared among the
>> -      * pools/users, we can't allow mapping in interrupt context
>> -      * because it can corrupt another users mappings.
>> +      * Iterate reversly, because, size of size_class that we want to use
>> +      * for merging should be larger or equal to current size.
>>        */
>> -     BUG_ON(in_interrupt());
>> +     for (i = zs_size_classes - 1; i >= 0; i--) {
>> +             int size;
>> +             int pages_per_zspage;
>> +             struct size_class *class;
>>
>> -     obj_handle_to_location(handle, &page, &obj_idx);
>> -     get_zspage_mapping(get_first_page(page), &class_idx, &fg);
>> -     class = pool->size_class[class_idx];
>> -     off = obj_idx_to_offset(page, obj_idx, class->size);
>> +             size = ZS_MIN_ALLOC_SIZE + i * ZS_SIZE_CLASS_DELTA;
>> +             if (size > ZS_MAX_ALLOC_SIZE)
>> +                     size = ZS_MAX_ALLOC_SIZE;
>> +             pages_per_zspage = get_pages_per_zspage(size);
>>
>> -     area = &get_cpu_var(zs_map_area);
>> -     area->vm_mm = mm;
>> -     if (off + class->size <= PAGE_SIZE) {
>> -             /* this object is contained entirely within a page */
>> -             area->vm_addr = kmap_atomic(page);
>> -             return area->vm_addr + off;
>> +             /*
>> +              * size_class is used for normal zsmalloc operation such
>> +              * as alloc/free for that size. Although it is natural that we
>> +              * have one size_class for each size, there is a chance that we
>> +              * can get more memory utilization if we use one size_class for
>> +              * many different sizes whose size_class have same
>> +              * characteristics. So, we makes size_class point to
>> +              * previous size_class if possible.
>> +              */
>> +             if (prev_class) {
>> +                     if (can_merge(prev_class, size, pages_per_zspage)) {
>> +                             pool->size_class[i] = prev_class;
>> +                             continue;
>> +                     }
>> +             }
>> +
>> +             class = kzalloc(sizeof(struct size_class), GFP_KERNEL);
>> +             if (!class)
>> +                     goto err;
>> +
>> +             class->size = size;
>> +             class->index = i;
>> +             class->pages_per_zspage = pages_per_zspage;
>> +             spin_lock_init(&class->lock);
>> +             pool->size_class[i] = class;
>> +
>> +             prev_class = class;
>>       }
>>
>> -     /* this object spans two pages */
>> -     pages[0] = page;
>> -     pages[1] = get_next_page(page);
>> -     BUG_ON(!pages[1]);
>> +     pool->flags = flags;
>>
>> -     return __zs_map_object(area, pages, off, class->size);
>> +     return pool;
>> +
>> +err:
>> +     zs_destroy_pool(pool);
>> +     return NULL;
>>  }
>> -EXPORT_SYMBOL_GPL(zs_map_object);
>> +EXPORT_SYMBOL_GPL(zs_create_pool);
>>
>> -void zs_unmap_object(struct zs_pool *pool, unsigned long handle)
>> +void zs_destroy_pool(struct zs_pool *pool)
>>  {
>> -     struct page *page;
>> -     unsigned long obj_idx, off;
>> +     int i;
>>
>> -     unsigned int class_idx;
>> -     enum fullness_group fg;
>> -     struct size_class *class;
>> -     struct mapping_area *area;
>> +     for (i = 0; i < zs_size_classes; i++) {
>> +             int fg;
>> +             struct size_class *class = pool->size_class[i];
>>
>> -     BUG_ON(!handle);
>> +             if (!class)
>> +                     continue;
>>
>> -     obj_handle_to_location(handle, &page, &obj_idx);
>> -     get_zspage_mapping(get_first_page(page), &class_idx, &fg);
>> -     class = pool->size_class[class_idx];
>> -     off = obj_idx_to_offset(page, obj_idx, class->size);
>> +             if (class->index != i)
>> +                     continue;
>>
>> -     area = this_cpu_ptr(&zs_map_area);
>> -     if (off + class->size <= PAGE_SIZE)
>> -             kunmap_atomic(area->vm_addr);
>> -     else {
>> -             struct page *pages[2];
>> +             for (fg = 0; fg < _ZS_NR_FULLNESS_GROUPS; fg++) {
>> +                     if (class->fullness_list[fg]) {
>> +                             pr_info("Freeing non-empty class with size %db, fullness group %d\n",
>> +                                     class->size, fg);
>> +                     }
>> +             }
>> +             kfree(class);
>> +     }
>>
>> -             pages[0] = page;
>> -             pages[1] = get_next_page(page);
>> -             BUG_ON(!pages[1]);
>> +     kfree(pool->size_class);
>> +     kfree(pool);
>> +}
>> +EXPORT_SYMBOL_GPL(zs_destroy_pool);
>>
>> -             __zs_unmap_object(area, pages, off, class->size);
>> +static int __init zs_init(void)
>> +{
>> +     int ret = zs_register_cpu_notifier();
>> +
>> +     if (ret) {
>> +             zs_unregister_cpu_notifier();
>> +             return ret;
>>       }
>> -     put_cpu_var(zs_map_area);
>> +
>> +     init_zs_size_classes();
>> +
>> +#ifdef CONFIG_ZPOOL
>> +     zpool_register_driver(&zs_zpool_driver);
>> +#endif
>> +     return 0;
>>  }
>> -EXPORT_SYMBOL_GPL(zs_unmap_object);
>>
>> -unsigned long zs_get_total_pages(struct zs_pool *pool)
>> +static void __exit zs_exit(void)
>>  {
>> -     return atomic_long_read(&pool->pages_allocated);
>> +#ifdef CONFIG_ZPOOL
>> +     zpool_unregister_driver(&zs_zpool_driver);
>> +#endif
>> +     zs_unregister_cpu_notifier();
>>  }
>> -EXPORT_SYMBOL_GPL(zs_get_total_pages);
>>
>>  module_init(zs_init);
>>  module_exit(zs_exit);
>> --
>> 1.7.9.5
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
