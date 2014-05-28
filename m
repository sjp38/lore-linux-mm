Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id D37696B0036
	for <linux-mm@kvack.org>; Tue, 27 May 2014 20:06:51 -0400 (EDT)
Received: by mail-wg0-f52.google.com with SMTP id l18so10225732wgh.23
        for <linux-mm@kvack.org>; Tue, 27 May 2014 17:06:50 -0700 (PDT)
Received: from mail-we0-x229.google.com (mail-we0-x229.google.com [2a00:1450:400c:c03::229])
        by mx.google.com with ESMTPS id f2si28191227wjx.79.2014.05.27.17.06.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 27 May 2014 17:06:49 -0700 (PDT)
Received: by mail-we0-f169.google.com with SMTP id u56so10550326wes.0
        for <linux-mm@kvack.org>; Tue, 27 May 2014 17:06:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140527220639.GA25781@cerebellum.variantweb.net>
References: <1399499496-3216-1-git-send-email-ddstreet@ieee.org>
 <1400958369-3588-1-git-send-email-ddstreet@ieee.org> <1400958369-3588-4-git-send-email-ddstreet@ieee.org>
 <20140527220639.GA25781@cerebellum.variantweb.net>
From: Dan Streetman <ddstreet@ieee.org>
Date: Tue, 27 May 2014 20:06:28 -0400
Message-ID: <CALZtONBp+ckT222fcXQgGOx4AgNBLA7D6ZOKB4Zg_RqX1do0vw@mail.gmail.com>
Subject: Re: [PATCHv3 3/6] mm/zpool: implement common zpool api to zbud/zsmalloc
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjennings@variantweb.net>
Cc: Minchan Kim <minchan@kernel.org>, Weijie Yang <weijie.yang@samsung.com>, Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <bob.liu@oracle.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Tue, May 27, 2014 at 6:06 PM, Seth Jennings <sjennings@variantweb.net> wrote:
> On Sat, May 24, 2014 at 03:06:06PM -0400, Dan Streetman wrote:
>> Add zpool api.
>>
>> zpool provides an interface for memory storage, typically of compressed
>> memory.  Users can select what backend to use; currently the only
>> implementations are zbud, a low density implementation with up to
>> two compressed pages per storage page, and zsmalloc, a higher density
>> implementation with multiple compressed pages per storage page.
>>
>> Signed-off-by: Dan Streetman <ddstreet@ieee.org>
>> Cc: Seth Jennings <sjennings@variantweb.net>
>> Cc: Minchan Kim <minchan@kernel.org>
>> Cc: Nitin Gupta <ngupta@vflare.org>
>> Cc: Weijie Yang <weijie.yang@samsung.com>
>> ---
>>
>> Note this patch set is against the mmotm tree at
>> git://git.cmpxchg.org/linux-mmotm.git
>> This patch may need context changes to the -next or other trees.
>>
>> Changes since v2 : https://lkml.org/lkml/2014/5/7/733
>>   -Remove hardcoded zbud/zsmalloc implementations
>>   -Add driver (un)register functions
>>
>> Changes since v1 https://lkml.org/lkml/2014/4/19/101
>>  -add some pr_info() during creation and pr_err() on errors
>>  -remove zpool code to call zs_shrink(), since zsmalloc shrinking
>>   was removed from this patchset
>>  -remove fallback; only specified pool type will be tried
>>  -pr_fmt() is defined in zpool to prefix zpool: in any pr_XXX() calls
>>
>>
>>  include/linux/zpool.h | 214 ++++++++++++++++++++++++++++++++++++++++++++++++++
>>  mm/Kconfig            |  41 ++++++----
>>  mm/Makefile           |   1 +
>>  mm/zpool.c            | 197 ++++++++++++++++++++++++++++++++++++++++++++++
>>  4 files changed, 436 insertions(+), 17 deletions(-)
>>  create mode 100644 include/linux/zpool.h
>>  create mode 100644 mm/zpool.c
>>
>> diff --git a/include/linux/zpool.h b/include/linux/zpool.h
>> new file mode 100644
>> index 0000000..699ac9b
>> --- /dev/null
>> +++ b/include/linux/zpool.h
>> @@ -0,0 +1,214 @@
>> +/*
>> + * zpool memory storage api
>> + *
>> + * Copyright (C) 2014 Dan Streetman
>> + *
>> + * This is a common frontend for the zbud and zsmalloc memory
>> + * storage pool implementations.  Typically, this is used to
>> + * store compressed memory.
>> + */
>> +
>> +#ifndef _ZPOOL_H_
>> +#define _ZPOOL_H_
>> +
>> +struct zpool;
>> +
>> +struct zpool_ops {
>> +     int (*evict)(struct zpool *pool, unsigned long handle);
>> +};
>> +
>> +/*
>> + * Control how a handle is mapped.  It will be ignored if the
>> + * implementation does not support it.  Its use is optional.
>> + * Note that this does not refer to memory protection, it
>> + * refers to how the memory will be copied in/out if copying
>> + * is necessary during mapping; read-write is the safest as
>> + * it copies the existing memory in on map, and copies the
>> + * changed memory back out on unmap.  Write-only does not copy
>> + * in the memory and should only be used for initialization.
>> + * If in doubt, use ZPOOL_MM_DEFAULT which is read-write.
>> + */
>> +enum zpool_mapmode {
>> +     ZPOOL_MM_RW, /* normal read-write mapping */
>> +     ZPOOL_MM_RO, /* read-only (no copy-out at unmap time) */
>> +     ZPOOL_MM_WO, /* write-only (no copy-in at map time) */
>> +
>> +     ZPOOL_MM_DEFAULT = ZPOOL_MM_RW
>> +};
>> +
>> +/**
>> + * zpool_create_pool() - Create a new zpool
>> + * @type     The type of the zpool to create (e.g. zbud, zsmalloc)
>> + * @flags    What GFP flags should be used when the zpool allocates memory.
>> + * @ops              The optional ops callback.
>> + *
>> + * This creates a new zpool of the specified type.  The zpool will use the
>> + * given flags when allocating any memory.  If the ops param is NULL, then
>> + * the created zpool will not be shrinkable.
>> + *
>> + * Returns: New zpool on success, NULL on failure.
>> + */
>> +struct zpool *zpool_create_pool(char *type, gfp_t flags,
>> +                     struct zpool_ops *ops);
>> +
>> +/**
>> + * zpool_get_type() - Get the type of the zpool
>> + * @pool     The zpool to check
>> + *
>> + * This returns the type of the pool.
>> + *
>> + * Returns: The type of zpool.
>> + */
>> +char *zpool_get_type(struct zpool *pool);
>> +
>> +/**
>> + * zpool_destroy_pool() - Destroy a zpool
>> + * @pool     The zpool to destroy.
>> + *
>> + * This destroys an existing zpool.  The zpool should not be in use.
>> + */
>> +void zpool_destroy_pool(struct zpool *pool);
>> +
>> +/**
>> + * zpool_malloc() - Allocate memory
>> + * @pool     The zpool to allocate from.
>> + * @size     The amount of memory to allocate.
>> + * @handle   Pointer to the handle to set
>> + *
>> + * This allocates the requested amount of memory from the pool.
>> + * The provided @handle will be set to the allocated object handle.
>> + *
>> + * Returns: 0 on success, negative value on error.
>> + */
>> +int zpool_malloc(struct zpool *pool, size_t size, unsigned long *handle);
>> +
>> +/**
>> + * zpool_free() - Free previously allocated memory
>> + * @pool     The zpool that allocated the memory.
>> + * @handle   The handle to the memory to free.
>> + *
>> + * This frees previously allocated memory.  This does not guarantee
>> + * that the pool will actually free memory, only that the memory
>> + * in the pool will become available for use by the pool.
>> + */
>> +void zpool_free(struct zpool *pool, unsigned long handle);
>> +
>> +/**
>> + * zpool_shrink() - Shrink the pool size
>> + * @pool     The zpool to shrink.
>> + * @size     The minimum amount to shrink the pool.
>> + *
>> + * This attempts to shrink the actual memory size of the pool
>> + * by evicting currently used handle(s).  If the pool was
>> + * created with no zpool_ops, or the evict call fails for any
>> + * of the handles, this will fail.
>> + *
>> + * Returns: 0 on success, negative value on error/failure.
>> + */
>> +int zpool_shrink(struct zpool *pool, size_t size);
>
> This should take a number of pages to be reclaimed, not a size.  The
> user can evict their own object to reclaim a certain number of bytes
> from the pool.  What the user can't do is reclaim a page since it is not
> aware of the arrangement of the stored objects in the memory pages.

Yes I suppose that's true, I'll update it for v4...

>
> Also in patch 5/6 of six I see:
>
> -               if (zbud_reclaim_page(zswap_pool, 8)) {
> +               if (zpool_shrink(zswap_pool, PAGE_SIZE)) {
>
> but then in 4/6 I see:
>
> +int zbud_zpool_shrink(void *pool, size_t size)
> +{
> +       return zbud_reclaim_page(pool, 8);
> +}
>
> That is why it didn't completely explode on you since the zbud logic
> is still reclaiming pages.

Ha, yes clearly I neglected to translate between the size and the
number of pages there, oops!

On this topic - 8 retries seems very arbitrary.  Does it make sense to
include retrying in zbud and/or zpool at all?  The caller can easily
retry any number of times themselves, especially since zbud (and
eventually zsmalloc) will return -EAGAIN if the caller should retry.

>
>> +
>> +/**
>> + * zpool_map_handle() - Map a previously allocated handle into memory
>> + * @pool     The zpool that the handle was allocated from
>> + * @handle   The handle to map
>> + * @mm       How the memory should be mapped
>> + *
>> + * This maps a previously allocated handle into memory.  The @mm
>> + * param indicates to the implemenation how the memory will be
>> + * used, i.e. read-only, write-only, read-write.  If the
>> + * implementation does not support it, the memory will be treated
>> + * as read-write.
>> + *
>> + * This may hold locks, disable interrupts, and/or preemption,
>> + * and the zpool_unmap_handle() must be called to undo those
>> + * actions.  The code that uses the mapped handle should complete
>> + * its operatons on the mapped handle memory quickly and unmap
>> + * as soon as possible.  Multiple handles should not be mapped
>> + * concurrently on a cpu.
>> + *
>> + * Returns: A pointer to the handle's mapped memory area.
>> + */
>> +void *zpool_map_handle(struct zpool *pool, unsigned long handle,
>> +                     enum zpool_mapmode mm);
>> +
>> +/**
>> + * zpool_unmap_handle() - Unmap a previously mapped handle
>> + * @pool     The zpool that the handle was allocated from
>> + * @handle   The handle to unmap
>> + *
>> + * This unmaps a previously mapped handle.  Any locks or other
>> + * actions that the implemenation took in zpool_map_handle()
>> + * will be undone here.  The memory area returned from
>> + * zpool_map_handle() should no longer be used after this.
>> + */
>> +void zpool_unmap_handle(struct zpool *pool, unsigned long handle);
>> +
>> +/**
>> + * zpool_get_total_size() - The total size of the pool
>> + * @pool     The zpool to check
>> + *
>> + * This returns the total size in bytes of the pool.
>> + *
>> + * Returns: Total size of the zpool in bytes.
>> + */
>> +u64 zpool_get_total_size(struct zpool *pool);
>> +
>> +
>> +/**
>> + * struct zpool_driver - driver implementation for zpool
>> + * @type:    name of the driver.
>> + * @list:    entry in the list of zpool drivers.
>> + * @create:  create a new pool.
>> + * @destroy: destroy a pool.
>> + * @malloc:  allocate mem from a pool.
>> + * @free:    free mem from a pool.
>> + * @shrink:  shrink the pool.
>> + * @map:     map a handle.
>> + * @unmap:   unmap a handle.
>> + * @total_size:      get total size of a pool.
>> + *
>> + * This is created by a zpool implementation and registered
>> + * with zpool.
>> + */
>> +struct zpool_driver {
>> +     char *type;
>> +     struct list_head list;
>> +
>> +     void *(*create)(gfp_t gfp, struct zpool_ops *ops);
>> +     void (*destroy)(void *pool);
>> +
>> +     int (*malloc)(void *pool, size_t size, unsigned long *handle);
>> +     void (*free)(void *pool, unsigned long handle);
>> +
>> +     int (*shrink)(void *pool, size_t size);
>> +
>> +     void *(*map)(void *pool, unsigned long handle,
>> +                             enum zpool_mapmode mm);
>> +     void (*unmap)(void *pool, unsigned long handle);
>> +
>> +     u64 (*total_size)(void *pool);
>> +};
>> +
>> +/**
>> + * zpool_register_driver() - register a zpool implementation.
>> + * @driver:  driver to register
>> + */
>> +void zpool_register_driver(struct zpool_driver *driver);
>> +
>> +/**
>> + * zpool_unregister_driver() - unregister a zpool implementation.
>> + * @driver:  driver to unregister.
>> + */
>> +void zpool_unregister_driver(struct zpool_driver *driver);
>> +
>> +/**
>> + * zpool_evict() - evict callback from a zpool implementation.
>> + * @pool:    pool to evict from.
>> + * @handle:  handle to evict.
>> + *
>> + * This can be used by zpool implementations to call the
>> + * user's evict zpool_ops struct evict callback.
>> + */
>> +int zpool_evict(void *pool, unsigned long handle);
>> +
>> +#endif
>> diff --git a/mm/Kconfig b/mm/Kconfig
>> index 7511b4a..00f7720 100644
>> --- a/mm/Kconfig
>> +++ b/mm/Kconfig
>> @@ -515,15 +515,17 @@ config CMA_DEBUG
>>         processing calls such as dma_alloc_from_contiguous().
>>         This option does not affect warning and error messages.
>>
>> -config ZBUD
>> -     tristate
>> -     default n
>> +config MEM_SOFT_DIRTY
>> +     bool "Track memory changes"
>> +     depends on CHECKPOINT_RESTORE && HAVE_ARCH_SOFT_DIRTY && PROC_FS
>> +     select PROC_PAGE_MONITOR
>>       help
>> -       A special purpose allocator for storing compressed pages.
>> -       It is designed to store up to two compressed pages per physical
>> -       page.  While this design limits storage density, it has simple and
>> -       deterministic reclaim properties that make it preferable to a higher
>> -       density approach when reclaim will be used.
>> +       This option enables memory changes tracking by introducing a
>> +       soft-dirty bit on pte-s. This bit it set when someone writes
>> +       into a page just as regular dirty bit, but unlike the latter
>> +       it can be cleared by hands.
>> +
>> +       See Documentation/vm/soft-dirty.txt for more details.
>>
>>  config ZSWAP
>>       bool "Compressed cache for swap pages (EXPERIMENTAL)"
>> @@ -545,17 +547,22 @@ config ZSWAP
>>         they have not be fully explored on the large set of potential
>>         configurations and workloads that exist.
>>
>> -config MEM_SOFT_DIRTY
>> -     bool "Track memory changes"
>> -     depends on CHECKPOINT_RESTORE && HAVE_ARCH_SOFT_DIRTY && PROC_FS
>> -     select PROC_PAGE_MONITOR
>> +config ZPOOL
>> +     tristate "Common API for compressed memory storage"
>> +     default n
>>       help
>> -       This option enables memory changes tracking by introducing a
>> -       soft-dirty bit on pte-s. This bit it set when someone writes
>> -       into a page just as regular dirty bit, but unlike the latter
>> -       it can be cleared by hands.
>> +       Compressed memory storage API.  This allows using either zbud or
>> +       zsmalloc.
>>
>> -       See Documentation/vm/soft-dirty.txt for more details.
>> +config ZBUD
>> +     tristate "Low density storage for compressed pages"
>> +     default n
>> +     help
>> +       A special purpose allocator for storing compressed pages.
>> +       It is designed to store up to two compressed pages per physical
>> +       page.  While this design limits storage density, it has simple and
>> +       deterministic reclaim properties that make it preferable to a higher
>> +       density approach when reclaim will be used.
>>
>>  config ZSMALLOC
>>       tristate "Memory allocator for compressed pages"
>> diff --git a/mm/Makefile b/mm/Makefile
>> index 2b6fff2..759db04 100644
>> --- a/mm/Makefile
>> +++ b/mm/Makefile
>> @@ -61,6 +61,7 @@ obj-$(CONFIG_DEBUG_KMEMLEAK_TEST) += kmemleak-test.o
>>  obj-$(CONFIG_CLEANCACHE) += cleancache.o
>>  obj-$(CONFIG_MEMORY_ISOLATION) += page_isolation.o
>>  obj-$(CONFIG_PAGE_OWNER) += pageowner.o
>> +obj-$(CONFIG_ZPOOL)  += zpool.o
>>  obj-$(CONFIG_ZBUD)   += zbud.o
>>  obj-$(CONFIG_ZSMALLOC)       += zsmalloc.o
>>  obj-$(CONFIG_GENERIC_EARLY_IOREMAP) += early_ioremap.o
>> diff --git a/mm/zpool.c b/mm/zpool.c
>> new file mode 100644
>> index 0000000..89ed71f
>> --- /dev/null
>> +++ b/mm/zpool.c
>> @@ -0,0 +1,197 @@
>> +/*
>> + * zpool memory storage api
>> + *
>> + * Copyright (C) 2014 Dan Streetman
>> + *
>> + * This is a common frontend for memory storage pool implementations.
>> + * Typically, this is used to store compressed memory.
>> + */
>> +
>> +#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
>> +
>> +#include <linux/list.h>
>> +#include <linux/types.h>
>> +#include <linux/mm.h>
>> +#include <linux/slab.h>
>> +#include <linux/spinlock.h>
>> +#include <linux/module.h>
>> +#include <linux/zpool.h>
>> +
>> +struct zpool {
>> +     char *type;
>> +
>> +     struct zpool_driver *driver;
>> +     void *pool;
>> +     struct zpool_ops *ops;
>> +
>> +     struct list_head list;
>> +};
>> +
>> +static LIST_HEAD(drivers_head);
>> +static DEFINE_SPINLOCK(drivers_lock);
>> +
>> +static LIST_HEAD(pools_head);
>> +static DEFINE_SPINLOCK(pools_lock);
>> +
>> +void zpool_register_driver(struct zpool_driver *driver)
>> +{
>> +     spin_lock(&drivers_lock);
>> +     list_add(&driver->list, &drivers_head);
>> +     spin_unlock(&drivers_lock);
>> +}
>> +EXPORT_SYMBOL(zpool_register_driver);
>> +
>> +void zpool_unregister_driver(struct zpool_driver *driver)
>> +{
>> +     spin_lock(&drivers_lock);
>> +     list_del(&driver->list);
>> +     spin_unlock(&drivers_lock);
>> +}
>> +EXPORT_SYMBOL(zpool_unregister_driver);
>> +
>> +int zpool_evict(void *pool, unsigned long handle)
>> +{
>> +     struct zpool *zpool;
>> +
>> +     spin_lock(&pools_lock);
>> +     list_for_each_entry(zpool, &pools_head, list) {
>
> You can do a container_of() here:
>
> zpool = container_of(pool, struct zpool, pool);

unfortunately, that's not true, since the driver pool isn't actually a
member of the struct zpool.  The struct zpool only has a pointer to
the driver pool.

I really wanted to use container_of(), but I think zbud/zsmalloc would
need alternate pool creation functions that create struct zpools of
the appropriate size with their pool embedded, and the
driver->create() function would need to alloc and return the entire
struct zpool, instead of just the driver pool.  Do you think that's a
better approach?  Or is there another better way I'm missing?


>
> Seth
>
>> +             if (zpool->pool == pool) {
>> +                     spin_unlock(&pools_lock);
>> +                     if (!zpool->ops || !zpool->ops->evict)
>> +                             return -EINVAL;
>> +                     return zpool->ops->evict(zpool, handle);
>> +             }
>> +     }
>> +     spin_unlock(&pools_lock);
>> +
>> +     return -ENOENT;
>> +}
>> +EXPORT_SYMBOL(zpool_evict);
>> +
>> +static struct zpool_driver *zpool_get_driver(char *type)
>> +{
>> +     struct zpool_driver *driver;
>> +
>> +     assert_spin_locked(&drivers_lock);
>> +     list_for_each_entry(driver, &drivers_head, list) {
>> +             if (!strcmp(driver->type, type))
>> +                     return driver;
>> +     }
>> +
>> +     return NULL;
>> +}
>> +
>> +struct zpool *zpool_create_pool(char *type, gfp_t flags,
>> +                     struct zpool_ops *ops)
>> +{
>> +     struct zpool_driver *driver;
>> +     struct zpool *zpool;
>> +
>> +     pr_info("creating pool type %s\n", type);
>> +
>> +     spin_lock(&drivers_lock);
>> +     driver = zpool_get_driver(type);
>> +     spin_unlock(&drivers_lock);
>> +
>> +     if (!driver) {
>> +             request_module(type);
>> +             spin_lock(&drivers_lock);
>> +             driver = zpool_get_driver(type);
>> +             spin_unlock(&drivers_lock);
>> +     }
>> +
>> +     if (!driver) {
>> +             pr_err("no driver for type %s\n", type);
>> +             return NULL;
>> +     }
>> +
>> +     zpool = kmalloc(sizeof(*zpool), GFP_KERNEL);
>> +     if (!zpool) {
>> +             pr_err("couldn't create zpool - out of memory\n");
>> +             return NULL;
>> +     }
>> +
>> +     zpool->type = driver->type;
>> +     zpool->driver = driver;
>> +     zpool->pool = driver->create(flags, ops);
>> +     zpool->ops = ops;
>> +
>> +     if (!zpool->pool) {
>> +             pr_err("couldn't create %s pool\n", type);
>> +             kfree(zpool);
>> +             return NULL;
>> +     }
>> +
>> +     pr_info("created %s pool\n", type);
>> +
>> +     spin_lock(&pools_lock);
>> +     list_add(&zpool->list, &pools_head);
>> +     spin_unlock(&pools_lock);
>> +
>> +     return zpool;
>> +}
>> +
>> +void zpool_destroy_pool(struct zpool *zpool)
>> +{
>> +     pr_info("destroying pool type %s\n", zpool->type);
>> +
>> +     spin_lock(&pools_lock);
>> +     list_del(&zpool->list);
>> +     spin_unlock(&pools_lock);
>> +     zpool->driver->destroy(zpool->pool);
>> +     kfree(zpool);
>> +}
>> +
>> +char *zpool_get_type(struct zpool *zpool)
>> +{
>> +     return zpool->type;
>> +}
>> +
>> +int zpool_malloc(struct zpool *zpool, size_t size, unsigned long *handle)
>> +{
>> +     return zpool->driver->malloc(zpool->pool, size, handle);
>> +}
>> +
>> +void zpool_free(struct zpool *zpool, unsigned long handle)
>> +{
>> +     zpool->driver->free(zpool->pool, handle);
>> +}
>> +
>> +int zpool_shrink(struct zpool *zpool, size_t size)
>> +{
>> +     return zpool->driver->shrink(zpool->pool, size);
>> +}
>> +
>> +void *zpool_map_handle(struct zpool *zpool, unsigned long handle,
>> +                     enum zpool_mapmode mapmode)
>> +{
>> +     return zpool->driver->map(zpool->pool, handle, mapmode);
>> +}
>> +
>> +void zpool_unmap_handle(struct zpool *zpool, unsigned long handle)
>> +{
>> +     zpool->driver->unmap(zpool->pool, handle);
>> +}
>> +
>> +u64 zpool_get_total_size(struct zpool *zpool)
>> +{
>> +     return zpool->driver->total_size(zpool->pool);
>> +}
>> +
>> +static int __init init_zpool(void)
>> +{
>> +     pr_info("loaded\n");
>> +     return 0;
>> +}
>> +
>> +static void __exit exit_zpool(void)
>> +{
>> +     pr_info("unloaded\n");
>> +}
>> +
>> +module_init(init_zpool);
>> +module_exit(exit_zpool);
>> +
>> +MODULE_LICENSE("GPL");
>> +MODULE_AUTHOR("Dan Streetman <ddstreet@ieee.org>");
>> +MODULE_DESCRIPTION("Common API for compressed memory storage");
>> --
>> 1.8.3.1
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
