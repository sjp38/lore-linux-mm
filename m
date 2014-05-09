Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f46.google.com (mail-oa0-f46.google.com [209.85.219.46])
	by kanga.kvack.org (Postfix) with ESMTP id 85BA36B0145
	for <linux-mm@kvack.org>; Fri,  9 May 2014 00:13:57 -0400 (EDT)
Received: by mail-oa0-f46.google.com with SMTP id i4so4216732oah.19
        for <linux-mm@kvack.org>; Thu, 08 May 2014 21:13:56 -0700 (PDT)
Received: from mail-ob0-x22c.google.com (mail-ob0-x22c.google.com [2607:f8b0:4003:c01::22c])
        by mx.google.com with ESMTPS id q10si1888652oep.110.2014.05.08.21.13.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 08 May 2014 21:13:55 -0700 (PDT)
Received: by mail-ob0-f172.google.com with SMTP id wp18so4165429obc.17
        for <linux-mm@kvack.org>; Thu, 08 May 2014 21:13:55 -0700 (PDT)
Date: Thu, 8 May 2014 23:13:52 -0500
From: Seth Jennings <sjennings@variantweb.net>
Subject: Re: [PATCHv2 3/4] mm/zpool: implement common zpool api to
 zbud/zsmalloc
Message-ID: <20140509041352.GC2274@cerebellum.variantweb.net>
References: <1397922764-1512-1-git-send-email-ddstreet@ieee.org>
 <1399499496-3216-1-git-send-email-ddstreet@ieee.org>
 <1399499496-3216-4-git-send-email-ddstreet@ieee.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1399499496-3216-4-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Weijie Yang <weijie.yang@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <bob.liu@oracle.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Wed, May 07, 2014 at 05:51:35PM -0400, Dan Streetman wrote:
> Add zpool api.
> 
> zpool provides an interface for memory storage, typically of compressed
> memory.  Users can select what backend to use; currently the only
> implementations are zbud, a low density implementation with up to
> two compressed pages per storage page, and zsmalloc, a higher density
> implementation with multiple compressed pages per storage page.

This is the wrong design methinks.  There are a bunch of #ifdefs for each
driver in the zpool.c code.  Available drivers (zbud, zsmalloc) should
register _up_ to the zpool layer.  That way the zpool layer doesn't have
to add a bunch of new code for each driver.

This zpool layer should be _really_ thin, stateless from the user point
of view, basically just wrapping the driver ops call.

New functions for driver registration:
zpool_register_driver()
zpool_unregister_driver()

Something like this (note the "void *" type of the pool):

struct zpool_driver_ops {
	void (*destroy)(void *pool);
	int (*malloc)(void *pool, size_t size, unsigned long *handle);
	....
}

Each driver can cast the void *pool to the driver pool type on the
driver side.

struct zpool_driver {
	char *driver_name;
	struct zpool_driver *ops;
}

Then drivers create a struct zpool_driver suitable for them and register
with zpool_register_driver().

struct zpool {
	void *driver_pool;
	struct zpool_driver *driver;
}

zpool_create() is:

struct zpool *zpool_create(char *driver_name, gfp_t flags, void *ops)
{
	[search for backend driver with name driver_name]
	[alloc new zpool]
	zpool->driver = driver;
	zpool->driver_pool = driver->ops->create(flags, ops);
	return zpool;
}

A user function like zpool_free() is just:

void zpool_free(struct zpool *pool, unsigned long handle)
{
	pool->driver->free(pool->driver_pool, handle);
}

Hopefully this makes sense.  Obviously, I didn't rewrite this whole
thing to see how it works end to end so there may be some pitfalls I'm
not considering.

Seth

> 
> Signed-off-by: Dan Streetman <ddstreet@ieee.org>
> Cc: Seth Jennings <sjennings@variantweb.net>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Nitin Gupta <ngupta@vflare.org>
> Cc: Weijie Yang <weijie.yang@samsung.com>
> ---
> 
> Changes since v1 https://lkml.org/lkml/2014/4/19/101
>  -add some pr_info() during creation and pr_err() on errors
>  -remove zpool code to call zs_shrink(), since zsmalloc shrinking
>   was removed from this patchset
>  -remove fallback; only specified pool type will be tried
>  -pr_fmt() is defined in zpool to prefix zpool: in any pr_XXX() calls
> 
>  include/linux/zpool.h | 160 +++++++++++++++++++++++
>  mm/Kconfig            |  43 ++++---
>  mm/Makefile           |   1 +
>  mm/zpool.c            | 349 ++++++++++++++++++++++++++++++++++++++++++++++++++
>  4 files changed, 535 insertions(+), 18 deletions(-)
>  create mode 100644 include/linux/zpool.h
>  create mode 100644 mm/zpool.c
> 
> diff --git a/include/linux/zpool.h b/include/linux/zpool.h
> new file mode 100644
> index 0000000..08f5468
> --- /dev/null
> +++ b/include/linux/zpool.h
> @@ -0,0 +1,160 @@
> +/*
> + * zpool memory storage api
> + *
> + * Copyright (C) 2014 Dan Streetman
> + *
> + * This is a common frontend for the zbud and zsmalloc memory
> + * storage pool implementations.  Typically, this is used to
> + * store compressed memory.
> + */
> +
> +#ifndef _ZPOOL_H_
> +#define _ZPOOL_H_
> +
> +struct zpool;
> +
> +struct zpool_ops {
> +	int (*evict)(struct zpool *pool, unsigned long handle);
> +};
> +
> +#define ZPOOL_TYPE_ZSMALLOC "zsmalloc"
> +#define ZPOOL_TYPE_ZBUD "zbud"
> +
> +/*
> + * Control how a handle is mapped.  It will be ignored if the
> + * implementation does not support it.  Its use is optional.
> + * Note that this does not refer to memory protection, it
> + * refers to how the memory will be copied in/out if copying
> + * is necessary during mapping; read-write is the safest as
> + * it copies the existing memory in on map, and copies the
> + * changed memory back out on unmap.  Write-only does not copy
> + * in the memory and should only be used for initialization.
> + * If in doubt, use ZPOOL_MM_DEFAULT which is read-write.
> + */
> +enum zpool_mapmode {
> +	ZPOOL_MM_RW, /* normal read-write mapping */
> +	ZPOOL_MM_RO, /* read-only (no copy-out at unmap time) */
> +	ZPOOL_MM_WO, /* write-only (no copy-in at map time) */
> +
> +	ZPOOL_MM_DEFAULT = ZPOOL_MM_RW
> +};
> +
> +/**
> + * zpool_create_pool() - Create a new zpool
> + * @type	The type of the zpool to create (e.g. zbud, zsmalloc)
> + * @flags	What GFP flags should be used when the zpool allocates memory.
> + * @ops		The optional ops callback.
> + *
> + * This creates a new zpool of the specified type.  The zpool will use the
> + * given flags when allocating any memory.  If the ops param is NULL, then
> + * the created zpool will not be shrinkable.
> + *
> + * Returns: New zpool on success, NULL on failure.
> + */
> +struct zpool *zpool_create_pool(char *type, gfp_t flags,
> +			struct zpool_ops *ops);
> +
> +/**
> + * zpool_get_type() - Get the type of the zpool
> + * @pool	The zpool to check
> + *
> + * This returns the type of the pool, which will match one of the
> + * ZPOOL_TYPE_* defined values.
> + *
> + * Returns: The type of zpool.
> + */
> +char *zpool_get_type(struct zpool *pool);
> +
> +/**
> + * zpool_destroy_pool() - Destroy a zpool
> + * @pool	The zpool to destroy.
> + *
> + * This destroys an existing zpool.  The zpool should not be in use.
> + */
> +void zpool_destroy_pool(struct zpool *pool);
> +
> +/**
> + * zpool_malloc() - Allocate memory
> + * @pool	The zpool to allocate from.
> + * @size	The amount of memory to allocate.
> + * @handle	Pointer to the handle to set
> + *
> + * This allocates the requested amount of memory from the pool.
> + * The provided @handle will be set to the allocated object handle.
> + *
> + * Returns: 0 on success, negative value on error.
> + */
> +int zpool_malloc(struct zpool *pool, size_t size, unsigned long *handle);
> +
> +/**
> + * zpool_free() - Free previously allocated memory
> + * @pool	The zpool that allocated the memory.
> + * @handle	The handle to the memory to free.
> + *
> + * This frees previously allocated memory.  This does not guarantee
> + * that the pool will actually free memory, only that the memory
> + * in the pool will become available for use by the pool.
> + */
> +void zpool_free(struct zpool *pool, unsigned long handle);
> +
> +/**
> + * zpool_shrink() - Shrink the pool size
> + * @pool	The zpool to shrink.
> + * @size	The minimum amount to shrink the pool.
> + *
> + * This attempts to shrink the actual memory size of the pool
> + * by evicting currently used handle(s).  If the pool was
> + * created with no zpool_ops, or the evict call fails for any
> + * of the handles, this will fail.
> + *
> + * Returns: 0 on success, negative value on error/failure.
> + */
> +int zpool_shrink(struct zpool *pool, size_t size);
> +
> +/**
> + * zpool_map_handle() - Map a previously allocated handle into memory
> + * @pool	The zpool that the handle was allocated from
> + * @handle	The handle to map
> + * @mm	How the memory should be mapped
> + *
> + * This maps a previously allocated handle into memory.  The @mm
> + * param indicates to the implemenation how the memory will be
> + * used, i.e. read-only, write-only, read-write.  If the
> + * implementation does not support it, the memory will be treated
> + * as read-write.
> + *
> + * This may hold locks, disable interrupts, and/or preemption,
> + * and the zpool_unmap_handle() must be called to undo those
> + * actions.  The code that uses the mapped handle should complete
> + * its operatons on the mapped handle memory quickly and unmap
> + * as soon as possible.  Multiple handles should not be mapped
> + * concurrently on a cpu.
> + *
> + * Returns: A pointer to the handle's mapped memory area.
> + */
> +void *zpool_map_handle(struct zpool *pool, unsigned long handle,
> +			enum zpool_mapmode mm);
> +
> +/**
> + * zpool_unmap_handle() - Unmap a previously mapped handle
> + * @pool	The zpool that the handle was allocated from
> + * @handle	The handle to unmap
> + *
> + * This unmaps a previously mapped handle.  Any locks or other
> + * actions that the implemenation took in zpool_map_handle()
> + * will be undone here.  The memory area returned from
> + * zpool_map_handle() should no longer be used after this.
> + */
> +void zpool_unmap_handle(struct zpool *pool, unsigned long handle);
> +
> +/**
> + * zpool_get_total_size() - The total size of the pool
> + * @pool	The zpool to check
> + *
> + * This returns the total size in bytes of the pool.
> + *
> + * Returns: Total size of the zpool in bytes.
> + */
> +u64 zpool_get_total_size(struct zpool *pool);
> +
> +#endif
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 30cb6cb..bdb4cb2 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -515,21 +515,23 @@ config CMA_DEBUG
>  	  processing calls such as dma_alloc_from_contiguous().
>  	  This option does not affect warning and error messages.
>  
> -config ZBUD
> -	tristate
> -	default n
> +config MEM_SOFT_DIRTY
> +	bool "Track memory changes"
> +	depends on CHECKPOINT_RESTORE && HAVE_ARCH_SOFT_DIRTY && PROC_FS
> +	select PROC_PAGE_MONITOR
>  	help
> -	  A special purpose allocator for storing compressed pages.
> -	  It is designed to store up to two compressed pages per physical
> -	  page.  While this design limits storage density, it has simple and
> -	  deterministic reclaim properties that make it preferable to a higher
> -	  density approach when reclaim will be used.
> +	  This option enables memory changes tracking by introducing a
> +	  soft-dirty bit on pte-s. This bit it set when someone writes
> +	  into a page just as regular dirty bit, but unlike the latter
> +	  it can be cleared by hands.
> +
> +	  See Documentation/vm/soft-dirty.txt for more details.
>  
>  config ZSWAP
>  	bool "Compressed cache for swap pages (EXPERIMENTAL)"
>  	depends on FRONTSWAP && CRYPTO=y
>  	select CRYPTO_LZO
> -	select ZBUD
> +	select ZPOOL
>  	default n
>  	help
>  	  A lightweight compressed cache for swap pages.  It takes
> @@ -545,17 +547,22 @@ config ZSWAP
>  	  they have not be fully explored on the large set of potential
>  	  configurations and workloads that exist.
>  
> -config MEM_SOFT_DIRTY
> -	bool "Track memory changes"
> -	depends on CHECKPOINT_RESTORE && HAVE_ARCH_SOFT_DIRTY && PROC_FS
> -	select PROC_PAGE_MONITOR
> +config ZPOOL
> +	tristate "Common API for compressed memory storage"
> +	default n
>  	help
> -	  This option enables memory changes tracking by introducing a
> -	  soft-dirty bit on pte-s. This bit it set when someone writes
> -	  into a page just as regular dirty bit, but unlike the latter
> -	  it can be cleared by hands.
> +	  Compressed memory storage API.  This allows using either zbud or
> +	  zsmalloc.
>  
> -	  See Documentation/vm/soft-dirty.txt for more details.
> +config ZBUD
> +	tristate "Low density storage for compressed pages"
> +	default n
> +	help
> +	  A special purpose allocator for storing compressed pages.
> +	  It is designed to store up to two compressed pages per physical
> +	  page.  While this design limits storage density, it has simple and
> +	  deterministic reclaim properties that make it preferable to a higher
> +	  density approach when reclaim will be used.
>  
>  config ZSMALLOC
>  	bool "Memory allocator for compressed pages"
> diff --git a/mm/Makefile b/mm/Makefile
> index 9b75a4d..f64a5d4 100644
> --- a/mm/Makefile
> +++ b/mm/Makefile
> @@ -61,6 +61,7 @@ obj-$(CONFIG_DEBUG_KMEMLEAK_TEST) += kmemleak-test.o
>  obj-$(CONFIG_CLEANCACHE) += cleancache.o
>  obj-$(CONFIG_MEMORY_ISOLATION) += page_isolation.o
>  obj-$(CONFIG_PAGE_OWNER) += pageowner.o
> +obj-$(CONFIG_ZPOOL)	+= zpool.o
>  obj-$(CONFIG_ZBUD)	+= zbud.o
>  obj-$(CONFIG_ZSMALLOC)	+= zsmalloc.o
>  obj-$(CONFIG_GENERIC_EARLY_IOREMAP) += early_ioremap.o
> diff --git a/mm/zpool.c b/mm/zpool.c
> new file mode 100644
> index 0000000..2bda300
> --- /dev/null
> +++ b/mm/zpool.c
> @@ -0,0 +1,349 @@
> +/*
> + * zpool memory storage api
> + *
> + * Copyright (C) 2014 Dan Streetman
> + *
> + * This is a common frontend for the zbud and zsmalloc memory
> + * storage pool implementations.  Typically, this is used to
> + * store compressed memory.
> + */
> +
> +#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> +
> +#include <linux/list.h>
> +#include <linux/types.h>
> +#include <linux/mm.h>
> +#include <linux/slab.h>
> +#include <linux/spinlock.h>
> +#include <linux/zpool.h>
> +#include <linux/zbud.h>
> +#include <linux/zsmalloc.h>
> +
> +struct zpool_imp {
> +	void (*destroy)(struct zpool *pool);
> +
> +	int (*malloc)(struct zpool *pool, size_t size, unsigned long *handle);
> +	void (*free)(struct zpool *pool, unsigned long handle);
> +
> +	int (*shrink)(struct zpool *pool, size_t size);
> +
> +	void *(*map)(struct zpool *pool, unsigned long handle,
> +				enum zpool_mapmode mm);
> +	void (*unmap)(struct zpool *pool, unsigned long handle);
> +
> +	u64 (*total_size)(struct zpool *pool);
> +};
> +
> +struct zpool {
> +	char *type;
> +
> +	union {
> +#ifdef CONFIG_ZSMALLOC
> +	struct zs_pool *zsmalloc_pool;
> +#endif
> +#ifdef CONFIG_ZBUD
> +	struct zbud_pool *zbud_pool;
> +#endif
> +	};
> +
> +	struct zpool_imp *imp;
> +	struct zpool_ops *ops;
> +
> +	struct list_head list;
> +};
> +
> +static LIST_HEAD(zpools);
> +static DEFINE_SPINLOCK(zpools_lock);
> +
> +static int zpool_noop_evict(struct zpool *pool, unsigned long handle)
> +{
> +	return -EINVAL;
> +}
> +static struct zpool_ops zpool_noop_ops = {
> +	.evict = zpool_noop_evict
> +};
> +
> +
> +/* zsmalloc */
> +
> +#ifdef CONFIG_ZSMALLOC
> +
> +static void zpool_zsmalloc_destroy(struct zpool *zpool)
> +{
> +	spin_lock(&zpools_lock);
> +	list_del(&zpool->list);
> +	spin_unlock(&zpools_lock);
> +
> +	zs_destroy_pool(zpool->zsmalloc_pool);
> +	kfree(zpool);
> +}
> +
> +static int zpool_zsmalloc_malloc(struct zpool *pool, size_t size,
> +			unsigned long *handle)
> +{
> +	*handle = zs_malloc(pool->zsmalloc_pool, size);
> +	return *handle ? 0 : -1;
> +}
> +
> +static void zpool_zsmalloc_free(struct zpool *pool, unsigned long handle)
> +{
> +	zs_free(pool->zsmalloc_pool, handle);
> +}
> +
> +static int zpool_zsmalloc_shrink(struct zpool *pool, size_t size)
> +{
> +	/* Not yet supported */
> +	return -EINVAL;
> +}
> +
> +static void *zpool_zsmalloc_map(struct zpool *pool, unsigned long handle,
> +			enum zpool_mapmode zpool_mapmode)
> +{
> +	enum zs_mapmode zs_mapmode;
> +
> +	switch (zpool_mapmode) {
> +	case ZPOOL_MM_RO:
> +		zs_mapmode = ZS_MM_RO; break;
> +	case ZPOOL_MM_WO:
> +		zs_mapmode = ZS_MM_WO; break;
> +	case ZPOOL_MM_RW: /* fallthrough */
> +	default:
> +		zs_mapmode = ZS_MM_RW; break;
> +	}
> +	return zs_map_object(pool->zsmalloc_pool, handle, zs_mapmode);
> +}
> +
> +static void zpool_zsmalloc_unmap(struct zpool *pool, unsigned long handle)
> +{
> +	zs_unmap_object(pool->zsmalloc_pool, handle);
> +}
> +
> +static u64 zpool_zsmalloc_total_size(struct zpool *pool)
> +{
> +	return zs_get_total_size_bytes(pool->zsmalloc_pool);
> +}
> +
> +static struct zpool_imp zpool_zsmalloc_imp = {
> +	.destroy = zpool_zsmalloc_destroy,
> +	.malloc = zpool_zsmalloc_malloc,
> +	.free = zpool_zsmalloc_free,
> +	.shrink = zpool_zsmalloc_shrink,
> +	.map = zpool_zsmalloc_map,
> +	.unmap = zpool_zsmalloc_unmap,
> +	.total_size = zpool_zsmalloc_total_size
> +};
> +
> +static struct zpool *zpool_zsmalloc_create(gfp_t flags, struct zpool_ops *ops)
> +{
> +	struct zpool *zpool;
> +
> +	zpool = kmalloc(sizeof(*zpool), GFP_KERNEL);
> +	if (!zpool) {
> +		pr_err("couldn't create zpool - out of memory\n");
> +		return NULL;
> +	}
> +
> +	zpool->zsmalloc_pool = zs_create_pool(flags);
> +	if (!zpool->zsmalloc_pool) {
> +		kfree(zpool);
> +		pr_err("zs_create_pool() failed\n");
> +		return NULL;
> +	}
> +
> +	zpool->type = ZPOOL_TYPE_ZSMALLOC;
> +	zpool->imp = &zpool_zsmalloc_imp;
> +	zpool->ops = &zpool_noop_ops;
> +	spin_lock(&zpools_lock);
> +	list_add(&zpool->list, &zpools);
> +	spin_unlock(&zpools_lock);
> +
> +	return zpool;
> +}
> +
> +#else
> +
> +static struct zpool *zpool_zsmalloc_create(gfp_t flags, struct zpool_ops *ops)
> +{
> +	pr_info("no zsmalloc in this kernel\n");
> +	return NULL;
> +}
> +
> +#endif /* CONFIG_ZSMALLOC */
> +
> +
> +/* zbud */
> +
> +#ifdef CONFIG_ZBUD
> +
> +static void zpool_zbud_destroy(struct zpool *zpool)
> +{
> +	spin_lock(&zpools_lock);
> +	list_del(&zpool->list);
> +	spin_unlock(&zpools_lock);
> +
> +	zbud_destroy_pool(zpool->zbud_pool);
> +	kfree(zpool);
> +}
> +
> +static int zpool_zbud_malloc(struct zpool *pool, size_t size,
> +			unsigned long *handle)
> +{
> +	return zbud_alloc(pool->zbud_pool, size, handle);
> +}
> +
> +static void zpool_zbud_free(struct zpool *pool, unsigned long handle)
> +{
> +	zbud_free(pool->zbud_pool, handle);
> +}
> +
> +static int zpool_zbud_shrink(struct zpool *pool, size_t size)
> +{
> +	return zbud_reclaim_page(pool->zbud_pool, 3);
> +}
> +
> +static void *zpool_zbud_map(struct zpool *pool, unsigned long handle,
> +			enum zpool_mapmode zpool_mapmode)
> +{
> +	return zbud_map(pool->zbud_pool, handle);
> +}
> +
> +static void zpool_zbud_unmap(struct zpool *pool, unsigned long handle)
> +{
> +	zbud_unmap(pool->zbud_pool, handle);
> +}
> +
> +static u64 zpool_zbud_total_size(struct zpool *pool)
> +{
> +	return zbud_get_pool_size(pool->zbud_pool) * PAGE_SIZE;
> +}
> +
> +static int zpool_zbud_evict(struct zbud_pool *zbud_pool, unsigned long handle)
> +{
> +	struct zpool *zpool;
> +
> +	spin_lock(&zpools_lock);
> +	list_for_each_entry(zpool, &zpools, list) {
> +		if (zpool->zbud_pool == zbud_pool) {
> +			spin_unlock(&zpools_lock);
> +			return zpool->ops->evict(zpool, handle);
> +		}
> +	}
> +	spin_unlock(&zpools_lock);
> +	return -EINVAL;
> +}
> +
> +static struct zpool_imp zpool_zbud_imp = {
> +	.destroy = zpool_zbud_destroy,
> +	.malloc = zpool_zbud_malloc,
> +	.free = zpool_zbud_free,
> +	.shrink = zpool_zbud_shrink,
> +	.map = zpool_zbud_map,
> +	.unmap = zpool_zbud_unmap,
> +	.total_size = zpool_zbud_total_size
> +};
> +
> +static struct zbud_ops zpool_zbud_ops = {
> +	.evict = zpool_zbud_evict
> +};
> +
> +static struct zpool *zpool_zbud_create(gfp_t flags, struct zpool_ops *ops)
> +{
> +	struct zpool *zpool;
> +	struct zbud_ops *zbud_ops = (ops ? &zpool_zbud_ops : NULL);
> +
> +	zpool = kmalloc(sizeof(*zpool), GFP_KERNEL);
> +	if (!zpool) {
> +		pr_err("couldn't create zpool - out of memory\n");
> +		return NULL;
> +	}
> +
> +	zpool->zbud_pool = zbud_create_pool(flags, zbud_ops);
> +	if (!zpool->zbud_pool) {
> +		kfree(zpool);
> +		pr_err("zbud_create_pool() failed\n");
> +		return NULL;
> +	}
> +
> +	zpool->type = ZPOOL_TYPE_ZBUD;
> +	zpool->imp = &zpool_zbud_imp;
> +	zpool->ops = (ops ? ops : &zpool_noop_ops);
> +	spin_lock(&zpools_lock);
> +	list_add(&zpool->list, &zpools);
> +	spin_unlock(&zpools_lock);
> +
> +	return zpool;
> +}
> +
> +#else
> +
> +static struct zpool *zpool_zbud_create(gfp_t flags, struct zpool_ops *ops)
> +{
> +	pr_info("no zbud in this kernel\n");
> +	return NULL;
> +}
> +
> +#endif /* CONFIG_ZBUD */
> +
> +
> +struct zpool *zpool_create_pool(char *type, gfp_t flags,
> +			struct zpool_ops *ops)
> +{
> +	struct zpool *pool = NULL;
> +
> +	pr_info("creating pool type %s\n", type);
> +
> +	if (!strcmp(type, ZPOOL_TYPE_ZSMALLOC))
> +		pool = zpool_zsmalloc_create(flags, ops);
> +	else if (!strcmp(type, ZPOOL_TYPE_ZBUD))
> +		pool = zpool_zbud_create(flags, ops);
> +	else
> +		pr_err("unknown type %s\n", type);
> +
> +	if (pool)
> +		pr_info("created %s pool\n", type);
> +	else
> +		pr_err("couldn't create %s pool\n", type);
> +
> +	return pool;
> +}
> +
> +char *zpool_get_type(struct zpool *pool)
> +{
> +	return pool->type;
> +}
> +
> +void zpool_destroy_pool(struct zpool *pool)
> +{
> +	pool->imp->destroy(pool);
> +}
> +
> +int zpool_malloc(struct zpool *pool, size_t size, unsigned long *handle)
> +{
> +	return pool->imp->malloc(pool, size, handle);
> +}
> +
> +void zpool_free(struct zpool *pool, unsigned long handle)
> +{
> +	pool->imp->free(pool, handle);
> +}
> +
> +int zpool_shrink(struct zpool *pool, size_t size)
> +{
> +	return pool->imp->shrink(pool, size);
> +}
> +
> +void *zpool_map_handle(struct zpool *pool, unsigned long handle,
> +			enum zpool_mapmode mapmode)
> +{
> +	return pool->imp->map(pool, handle, mapmode);
> +}
> +
> +void zpool_unmap_handle(struct zpool *pool, unsigned long handle)
> +{
> +	pool->imp->unmap(pool, handle);
> +}
> +
> +u64 zpool_get_total_size(struct zpool *pool)
> +{
> +	return pool->imp->total_size(pool);
> +}
> -- 
> 1.8.3.1
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
