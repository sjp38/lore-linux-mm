Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id BC3266B008A
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 20:29:53 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oBE1Tofo008267
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 14 Dec 2010 10:29:50 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5B6C645DE5D
	for <linux-mm@kvack.org>; Tue, 14 Dec 2010 10:29:50 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3BD1645DE5A
	for <linux-mm@kvack.org>; Tue, 14 Dec 2010 10:29:50 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2C8431DB8038
	for <linux-mm@kvack.org>; Tue, 14 Dec 2010 10:29:50 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C3FE5E08004
	for <linux-mm@kvack.org>; Tue, 14 Dec 2010 10:29:49 +0900 (JST)
Date: Tue, 14 Dec 2010 10:24:01 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCHv7 08/10] mm: cma: Contiguous Memory Allocator added
Message-Id: <20101214102401.37bf812d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <fc8aa07ac71d554ba10af4943fdb05197c681fa2.1292004520.git.m.nazarewicz@samsung.com>
References: <cover.1292004520.git.m.nazarewicz@samsung.com>
	<fc8aa07ac71d554ba10af4943fdb05197c681fa2.1292004520.git.m.nazarewicz@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Michal Nazarewicz <m.nazarewicz@samsung.com>
Cc: Michal Nazarewicz <mina86@mina86.com>, Andrew Morton <akpm@linux-foundation.org>, Ankita Garg <ankita@in.ibm.com>, BooJin Kim <boojin.kim@samsung.com>, Daniel Walker <dwalker@codeaurora.org>, Johan MOSSBERG <johan.xx.mossberg@stericsson.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mel@csn.ul.ie>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>
List-ID: <linux-mm.kvack.org>

On Mon, 13 Dec 2010 12:26:49 +0100
Michal Nazarewicz <m.nazarewicz@samsung.com> wrote:

> The Contiguous Memory Allocator is a set of functions that lets
> one initialise a region of memory which then can be used to perform
> allocations of contiguous memory chunks from.  The implementation
> uses MIGRATE_CMA migration type which means that the memory is
> shared with standard page allocator, ie. when CMA is not using
> the memory, page allocator can allocate movable pages from the
> region.
> 
> Signed-off-by: Michal Nazarewicz <m.nazarewicz@samsung.com>
> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> ---
>  include/linux/cma.h |  223 ++++++++++++++++++++++++
>  mm/Kconfig          |   32 ++++
>  mm/Makefile         |    1 +
>  mm/cma.c            |  477 +++++++++++++++++++++++++++++++++++++++++++++++++++
>  4 files changed, 733 insertions(+), 0 deletions(-)
>  create mode 100644 include/linux/cma.h
>  create mode 100644 mm/cma.c
> 
> diff --git a/include/linux/cma.h b/include/linux/cma.h
> new file mode 100644
> index 0000000..25728a3
> --- /dev/null
> +++ b/include/linux/cma.h
> @@ -0,0 +1,223 @@
> +#ifndef __LINUX_CMA_H
> +#define __LINUX_CMA_H
> +
> +/*
> + * Contiguous Memory Allocator
> + * Copyright (c) 2010 by Samsung Electronics.
> + * Written by Michal Nazarewicz (m.nazarewicz@samsung.com)
> + */
> +
> +/*
> + * Contiguous Memory Allocator
> + *
> + *   The Contiguous Memory Allocator (CMA) makes it possible for
> + *   device drivers to allocate big contiguous chunks of memory after
> + *   the system has booted.
> + *
> + *   It requires some machine- and/or platform-specific initialisation
> + *   code which prepares memory ranges to be used with CMA and later,
> + *   device drivers can allocate memory from those ranges.
> + *
> + * Why is it needed?
> + *
> + *   Various devices on embedded systems have no scatter-getter and/or
> + *   IO map support and require contiguous blocks of memory to
> + *   operate.  They include devices such as cameras, hardware video
> + *   coders, etc.
> + *
> + *   Such devices often require big memory buffers (a full HD frame
> + *   is, for instance, more then 2 mega pixels large, i.e. more than 6
> + *   MB of memory), which makes mechanisms such as kmalloc() or
> + *   alloc_page() ineffective.
> + *
> + *   At the same time, a solution where a big memory region is
> + *   reserved for a device is suboptimal since often more memory is
> + *   reserved then strictly required and, moreover, the memory is
> + *   inaccessible to page system even if device drivers don't use it.
> + *
> + *   CMA tries to solve this issue by operating on memory regions
> + *   where only movable pages can be allocated from.  This way, kernel
> + *   can use the memory for pagecache and when device driver requests
> + *   it, allocated pages can be migrated.
> + *
> + * Driver usage
> + *
> + *   For device driver to use CMA it needs to have a pointer to a CMA
> + *   context represented by a struct cma (which is an opaque data
> + *   type).
> + *
> + *   Once such pointer is obtained, device driver may allocate
> + *   contiguous memory chunk using the following function:
> + *
> + *     cm_alloc()
> + *
> + *   This function returns a pointer to struct cm (another opaque data
> + *   type) which represent a contiguous memory chunk.  This pointer
> + *   may be used with the following functions:
> + *
> + *     cm_free()    -- frees allocated contiguous memory
> + *     cm_pin()     -- pins memory
> + *     cm_unpin()   -- unpins memory
> + *     cm_vmap()    -- maps memory in kernel space
> + *     cm_vunmap()  -- unmaps memory from kernel space
> + *
> + *   See the respective functions for more information.
> + *
> + * Platform/machine integration
> + *
> + *   For device drivers to be able to use CMA platform or machine
> + *   initialisation code must create a CMA context and pass it to
> + *   device drivers.  The latter may be done by a global variable or
> + *   a platform/machine specific function.  For the former CMA
> + *   provides the following functions:
> + *
> + *     cma_init()
> + *     cma_reserve()
> + *     cma_create()
> + *
> + *   The first one initialises a portion of reserved memory so that it
> + *   can be used with CMA.  The second first tries to reserve memory
> + *   (using memblock) and then initialise it.
> + *
> + *   The cma_reserve() function must be called when memblock is still
> + *   operational and reserving memory with it is still possible.  On
> + *   ARM platform the "reserve" machine callback is a perfect place to
> + *   call it.
> + *
> + *   The last function creates a CMA context on a range of previously
> + *   initialised memory addresses.  Because it uses kmalloc() it needs
> + *   to be called after SLAB is initialised.
> + */
> +
> +/***************************** Kernel level API *****************************/
> +
> +#if defined __KERNEL__ && defined CONFIG_CMA
> +
> +/* CMA context */
> +struct cma;
> +/* Contiguous Memory chunk */
> +struct cm;
> +
> +/**
> + * cma_init() - initialises range of physical memory to be used with CMA.
> + * @start:	start address of the memory range in bytes.
> + * @size:	size of the memory range in bytes.
> + *
> + * The range must be MAX_ORDER-1 aligned and it must have been already
> + * reserved (eg. with memblock).
> + *
> + * Returns zero on success or negative error.
> + */
> +int cma_init(unsigned long start, unsigned long end);
> +
> +/**
> + * cma_reserve() - reserves and initialises memory to be used with CMA.
> + * @start:	start address of the memory range in bytes hint; if unsure
> + *		pass zero (will be down-aligned to MAX_ORDER-1).
> + * @size:	size of the memory to reserve in bytes (will be up-aligned
> + *		to MAX_ORDER-1).
> + * @alignment:	desired alignment in bytes (must be power of two or zero).
> + *
> + * It will use memblock to allocate memory and then initialise it for
> + * use with CMA by invoking cma_init().  It must be called early in
> + * boot process while memblock is still operational.
> + *
> + * Returns reserved's area physical address or value that yields true
> + * when checked with IS_ERR_VALUE().
> + */
> +unsigned long cma_reserve(unsigned long start, unsigned long size,
> +			  unsigned long alignment);
> +
> +/**
> + * cma_create() - creates CMA context.
> + * @start:	start address of the context in bytes.
> + * @size:	size of the context in bytes.
> + *
> + * The range must be page aligned.  The range must have been already
> + * initialised with cma_init().  Different contexts cannot overlap.
> + *
> + * Because this function uses kmalloc() it must be called after SLAB
> + * is initialised.  This in particular means that it cannot be called
> + * just after cma_reserve() since the former needs to be run way
> + * earlier.
> + *
> + * Returns pointer to CMA context or a pointer-error on error.
> + */
> +struct cma *cma_create(unsigned long start, unsigned long size);
> +
> +/**
> + * cma_destroy() - destroys CMA context.
> + * @cma:	context to destroy.
> + */
> +void cma_destroy(struct cma *cma);
> +
> +/**
> + * cm_alloc() - allocates contiguous memory.
> + * @cma:	CMA context to use.
> + * @size:	desired chunk size in bytes (must be non-zero).
> + * @alignent:	desired minimal alignment in bytes (must be power of two
> + *		or zero).
> + *
> + * Returns pointer to structure representing contiguous memory or
> + * a pointer-error on error.
> + */
> +struct cm *cm_alloc(struct cma *cma, unsigned long size,
> +		    unsigned long alignment);
> +
> +/**
> + * cm_free() - frees contiguous memory.
> + * @cm:	contiguous memory to free.
> + *
> + * The contiguous memory must be not be pinned (see cma_pin()) and
> + * must not be mapped to kernel space (cma_vmap()).
> + */
> +void cm_free(struct cm *cm);
> +
> +/**
> + * cm_pin() - pins contiguous memory.
> + * @cm: contiguous memory to pin.
> + *
> + * Pinning is required to obtain contiguous memory's physical address.
> + * While memory is pinned the memory will remain valid it may change
> + * if memory is unpinned and then pinned again.  This facility is
> + * provided so that memory defragmentation can be implemented inside
> + * CMA.
> + *
> + * Each call to cm_pin() must be accompanied by call to cm_unpin() and
> + * the calls may be nested.
> + *
> + * Returns chunk's physical address or a value that yields true when
> + * tested with IS_ERR_VALUE().
> + */
> +unsigned long cm_pin(struct cm *cm);
> +
> +/**
> + * cm_unpin() - unpins contiguous memory.
> + * @cm: contiguous memory to unpin.
> + *
> + * See cm_pin().
> + */
> +void cm_unpin(struct cm *cm);
> +
> +/**
> + * cm_vmap() - maps memory to kernel space (or returns existing mapping).
> + * @cm: contiguous memory to map.
> + *
> + * Each call to cm_vmap() must be accompanied with call to cm_vunmap()
> + * and the calls may be nested.
> + *
> + * Returns kernel virtual address or a pointer-error.
> + */
> +void *cm_vmap(struct cm *cm);
> +
> +/**
> + * cm_vunmap() - unmpas memory from kernel space.
> + * @cm:	contiguous memory to unmap.
> + *
> + * See cm_vmap().
> + */
> +void cm_vunmap(struct cm *cm);
> +
> +#endif
> +
> +#endif
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 7818b07..743893b 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -339,3 +339,35 @@ config CLEANCACHE
>  	  in a negligible performance hit.
>  
>  	  If unsure, say Y to enable cleancache
> +
> +
> +config CMA
> +	bool "Contiguous Memory Allocator framework"
> +	# Currently there is only one allocator so force it on
> +	select MIGRATION
> +	select MIGRATE_CMA
> +	select GENERIC_ALLOCATOR
> +	help
> +	  This enables the Contiguous Memory Allocator framework which
> +	  allows drivers to allocate big physically-contiguous blocks of
> +	  memory for use with hardware components that do not support I/O
> +	  map nor scatter-gather.
> +
> +	  If you select this option you will also have to select at least
> +	  one allocator algorithm below.
> +
> +	  To make use of CMA you need to specify the regions and
> +	  driver->region mapping on command line when booting the kernel.
> +
> +	  For more information see <include/linux/cma.h>.  If unsure, say "n".
> +
> +config CMA_DEBUG
> +	bool "CMA debug messages (DEVELOPEMENT)"
> +	depends on CMA
> +	help
> +	  Turns on debug messages in CMA.  This produces KERN_DEBUG
> +	  messages for every CMA call as well as various messages while
> +	  processing calls such as cma_alloc().  This option does not
> +	  affect warning and error messages.
> +
> +	  This is mostly used during development.  If unsure, say "n".
> diff --git a/mm/Makefile b/mm/Makefile
> index 0b08d1c..c6a84f1 100644
> --- a/mm/Makefile
> +++ b/mm/Makefile
> @@ -43,3 +43,4 @@ obj-$(CONFIG_HWPOISON_INJECT) += hwpoison-inject.o
>  obj-$(CONFIG_DEBUG_KMEMLEAK) += kmemleak.o
>  obj-$(CONFIG_DEBUG_KMEMLEAK_TEST) += kmemleak-test.o
>  obj-$(CONFIG_CLEANCACHE) += cleancache.o
> +obj-$(CONFIG_CMA) += cma.o
> diff --git a/mm/cma.c b/mm/cma.c
> new file mode 100644
> index 0000000..401e604
> --- /dev/null
> +++ b/mm/cma.c
> @@ -0,0 +1,477 @@
> +/*
> + * Contiguous Memory Allocator framework
> + * Copyright (c) 2010 by Samsung Electronics.
> + * Written by Michal Nazarewicz (m.nazarewicz@samsung.com)
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License as
> + * published by the Free Software Foundation; either version 2 of the
> + * License or (at your optional) any later version of the license.
> + */
> +
> +/*
> + * See include/linux/cma.h for details.
> + */
> +
> +#define pr_fmt(fmt) "cma: " fmt
> +
> +#ifdef CONFIG_CMA_DEBUG
> +#  define DEBUG
> +#endif
> +
> +#include <linux/cma.h>
> +
> +#ifndef CONFIG_NO_BOOTMEM
> +#  include <linux/bootmem.h>
> +#endif
> +#ifdef CONFIG_HAVE_MEMBLOCK
> +#  include <linux/memblock.h>
> +#endif
> +
> +#include <linux/err.h>
> +#include <linux/genalloc.h>
> +#include <linux/mm.h>
> +#include <linux/module.h>
> +#include <linux/mutex.h>
> +#include <linux/page-isolation.h>
> +#include <linux/slab.h>
> +#include <linux/swap.h>
> +
> +#include <asm/page.h>
> +
> +#include "internal.h"
> +
> +
> +/************************* Initialise CMA *************************/
> +
> +static struct cma_grabbed {
> +	unsigned long start;
> +	unsigned long size;
> +} cma_grabbed[8] __initdata;
> +static unsigned cma_grabbed_count __initdata;
> +
> +int cma_init(unsigned long start, unsigned long size)
> +{
> +	pr_debug("%s(%p+%p)\n", __func__, (void *)start, (void *)size);
> +
> +	if (!size)
> +		return -EINVAL;
> +	if ((start | size) & ((MAX_ORDER_NR_PAGES << PAGE_SHIFT) - 1))
> +		return -EINVAL;
> +	if (start + size < start)
> +		return -EOVERFLOW;
> +
> +	if (cma_grabbed_count == ARRAY_SIZE(cma_grabbed))
> +		return -ENOSPC;
> +
> +	cma_grabbed[cma_grabbed_count].start = start;
> +	cma_grabbed[cma_grabbed_count].size  = size;
> +	++cma_grabbed_count;
> +	return 0;
> +}
> +

Is it guaranteed that there are no memory holes, or zone overlap
in the range ? I think correctness of the range must be checked.




> +unsigned long cma_reserve(unsigned long start, unsigned long size,
> +			  unsigned long alignment)
> +{
> +	u64 addr;
> +	int ret;
> +
> +	pr_debug("%s(%p+%p/%p)\n", __func__, (void *)start, (void *)size,
> +		 (void *)alignment);
> +
> +	/* Sanity checks */
> +	if (!size || (alignment & (alignment - 1)))
> +		return (unsigned long)-EINVAL;
> +
> +	/* Sanitise input arguments */
> +	start = ALIGN(start, MAX_ORDER_NR_PAGES << PAGE_SHIFT);
> +	size &= ~((MAX_ORDER_NR_PAGES << PAGE_SHIFT) - 1);
> +	if (alignment < (MAX_ORDER_NR_PAGES << PAGE_SHIFT))
> +		alignment = MAX_ORDER_NR_PAGES << PAGE_SHIFT;
> +
> +	/* Reserve memory */
> +	if (start) {
> +		if (memblock_is_region_reserved(start, size) ||
> +		    memblock_reserve(start, size) < 0)
> +			return (unsigned long)-EBUSY;
> +	} else {
> +		/*
> +		 * Use __memblock_alloc_base() since
> +		 * memblock_alloc_base() panic()s.
> +		 */
> +		addr = __memblock_alloc_base(size, alignment, 0);
> +		if (!addr) {
> +			return (unsigned long)-ENOMEM;
> +		} else if (addr + size > ~(unsigned long)0) {
> +			memblock_free(addr, size);
> +			return (unsigned long)-EOVERFLOW;
> +		} else {
> +			start = addr;
> +		}
> +	}
> +
> +	/* CMA Initialise */
> +	ret = cma_init(start, size);
> +	if (ret < 0) {
> +		memblock_free(start, size);
> +		return ret;
> +	}
> +	return start;
> +}
> +
> +static int __init cma_give_back(void)
> +{
> +	struct cma_grabbed *r = cma_grabbed;
> +	unsigned i = cma_grabbed_count;
> +
> +	pr_debug("%s(): will give %u range(s)\n", __func__, i);
> +
> +	for (; i; --i, ++r) {
> +		struct page *p = phys_to_page(r->start);
> +		unsigned j = r->size >> (PAGE_SHIFT + pageblock_order);
> +
> +		pr_debug("%s():   giving (%p+%p)\n", __func__,
> +			 (void *)r->start, (void *)r->size);
> +
> +		do {
> +			__free_pageblock_cma(p);
> +			p += pageblock_nr_pages;
> +		} while (--j);
> +	}
> +
> +	return 0;
> +}
> +subsys_initcall(cma_give_back);
> +
> +
> +/************************** CMA context ***************************/
> +
> +/* struct cma is just an alias for struct gen_alloc */
> +
> +struct cma *cma_create(unsigned long start, unsigned long size)
> +{
> +	struct gen_pool *pool;
> +	int ret;
> +
> +	pr_debug("%s(%p+%p)\n", __func__, (void *)start, (void *)size);
> +
> +	if (!size)
> +		return ERR_PTR(-EINVAL);
> +	if ((start | size) & (PAGE_SIZE - 1))
> +		return ERR_PTR(-EINVAL);
> +	if (start + size < start)
> +		return ERR_PTR(-EOVERFLOW);
> +
> +	pool = gen_pool_create(PAGE_SHIFT, -1);
> +	if (unlikely(!pool))
> +		return ERR_PTR(-ENOMEM);
> +
> +	ret = gen_pool_add(pool, start, size, -1);
> +	if (unlikely(ret)) {
> +		gen_pool_destroy(pool);
> +		return ERR_PTR(ret);
> +	}
> +
> +	pr_debug("%s: returning <%p>\n", __func__, (void *)pool);
> +	return (void *)pool;
> +}
> +
> +void cma_destroy(struct cma *cma)
> +{
> +	pr_debug("%s(<%p>)\n", __func__, (void *)cma);
> +	gen_pool_destroy((void *)cma);
> +}
> +
> +
> +/************************* Allocate and free *************************/
> +
> +struct cm {
> +	struct gen_pool *pool;
> +	unsigned long phys, size;
> +	atomic_t pinned, mapped;
> +};
> +
> +/* Protects cm_alloc(), cm_free(), __cm_alloc() and __cm_free(). */
> +static DEFINE_MUTEX(cma_mutex);
> +
> +/* Must hold cma_mutex to call these. */
> +static int  __cm_alloc(unsigned long start, unsigned long size);
> +static void __cm_free(unsigned long start, unsigned long size);
> +
> +struct cm *cm_alloc(struct cma *cma, unsigned long size,
> +		    unsigned long alignment)
> +{
> +	unsigned long start;
> +	int ret = -ENOMEM;
> +	struct cm *cm;
> +
> +	pr_debug("%s(<%p>, %p/%p)\n", __func__, (void *)cma,
> +		 (void *)size, (void *)alignment);
> +
> +	if (!size || (alignment & (alignment - 1)))
> +		return ERR_PTR(-EINVAL);
> +	size = PAGE_ALIGN(size);
> +
> +	cm = kmalloc(sizeof *cm, GFP_KERNEL);
> +	if (!cm)
> +		return ERR_PTR(-ENOMEM);
> +
> +	mutex_lock(&cma_mutex);
> +
> +	start = gen_pool_alloc_aligned((void *)cma, size,
> +				       alignment ? ffs(alignment) - 1 : 0);
> +	if (!start)
> +		goto error1;
> +
> +	ret = __cm_alloc(start, size);
> +	if (ret)
> +		goto error2;
> +
> +	mutex_unlock(&cma_mutex);
> +
> +	cm->pool = (void *)cma;
> +	cm->phys = start;
> +	cm->size = size;
> +	atomic_set(&cm->pinned, 0);
> +	atomic_set(&cm->mapped, 0);
> +
> +	pr_debug("%s(): returning [%p]\n", __func__, (void *)cm);
> +	return cm;
> +
> +error2:
> +	gen_pool_free((void *)cma, start, size);
> +error1:
> +	mutex_unlock(&cma_mutex);
> +	kfree(cm);
> +	return ERR_PTR(ret);
> +}
> +EXPORT_SYMBOL_GPL(cm_alloc);
> +
> +void cm_free(struct cm *cm)
> +{
> +	pr_debug("%s([%p])\n", __func__, (void *)cm);
> +
> +	if (WARN_ON(atomic_read(&cm->pinned) || atomic_read(&cm->mapped)))
> +		return;
> +
> +	mutex_lock(&cma_mutex);
> +
> +	gen_pool_free(cm->pool, cm->phys, cm->size);
> +	__cm_free(cm->phys, cm->size);
> +
> +	mutex_unlock(&cma_mutex);
> +
> +	kfree(cm);
> +}
> +EXPORT_SYMBOL_GPL(cm_free);
> +
> +
> +/************************* Mapping and addresses *************************/
> +
> +/*
> + * Currently no-operations but keep reference counters for error
> + * checking.
> + */
> +
> +unsigned long cm_pin(struct cm *cm)
> +{
> +	pr_debug("%s([%p])\n", __func__, (void *)cm);
> +	atomic_inc(&cm->pinned);
> +	return cm->phys;
> +}
> +EXPORT_SYMBOL_GPL(cm_pin);
> +
> +void cm_unpin(struct cm *cm)
> +{
> +	pr_debug("%s([%p])\n", __func__, (void *)cm);
> +	WARN_ON(!atomic_add_unless(&cm->pinned, -1, 0));
> +}
> +EXPORT_SYMBOL_GPL(cm_unpin);
> +
> +void *cm_vmap(struct cm *cm)
> +{
> +	pr_debug("%s([%p])\n", __func__, (void *)cm);
> +	atomic_inc(&cm->mapped);
> +	/*
> +	 * Keep it simple...  We should do something more clever in
> +	 * the future.
> +	 */
> +	return phys_to_virt(cm->phys);
> +}
> +EXPORT_SYMBOL_GPL(cm_vmap);
> +
> +void cm_vunmap(struct cm *cm)
> +{
> +	pr_debug("%s([%p])\n", __func__, (void *)cm);
> +	WARN_ON(!atomic_add_unless(&cm->mapped, -1, 0));
> +}
> +EXPORT_SYMBOL_GPL(cm_vunmap);
> +
> +
> +/************************* Migration stuff *************************/
> +
> +/* XXX Revisit */
> +#ifdef phys_to_pfn
> +/* nothing to do */
> +#elif defined __phys_to_pfn
> +#  define phys_to_pfn __phys_to_pfn
> +#else
> +#  warning correct phys_to_pfn implementation needed
> +static unsigned long phys_to_pfn(phys_addr_t phys)
> +{
> +	return virt_to_pfn(phys_to_virt(phys));
> +}
> +#endif
> +
> +static unsigned long pfn_to_maxpage(unsigned long pfn)
> +{
> +	return pfn & ~(MAX_ORDER_NR_PAGES - 1);
> +}
> +
> +static unsigned long pfn_to_maxpage_up(unsigned long pfn)
> +{
> +	return ALIGN(pfn, MAX_ORDER_NR_PAGES);
> +}
> +
> +#define MIGRATION_RETRY	5
> +static int __cm_migrate(unsigned long start, unsigned long end)
> +{
> +	int migration_failed = 0, ret;
> +	unsigned long pfn = start;
> +
> +	pr_debug("%s(%p..%p)\n", __func__, (void *)start, (void *)end);
> +
> +	/*
> +	 * Some code "borrowed" from KAMEZAWA Hiroyuki's
> +	 * __alloc_contig_pages().
> +	 */
> +
> +	for (;;) {
> +		pfn = scan_lru_pages(pfn, end);
> +		if (!pfn || pfn >= end)
> +			break;
> +
> +		ret = do_migrate_range(pfn, end);
> +		if (!ret) {
> +			migration_failed = 0;
> +		} else if (ret != -EBUSY
> +			|| ++migration_failed >= MIGRATION_RETRY) {
> +			return ret;
> +		} else {
> +			/* There are unstable pages.on pagevec. */
> +			lru_add_drain_all();
> +			/*
> +			 * there may be pages on pcplist before
> +			 * we mark the range as ISOLATED.
> +			 */
> +			drain_all_pages();
> +		}
> +		cond_resched();
> +	}
> +
> +	if (!migration_failed) {
> +		/* drop all pages in pagevec and pcp list */
> +		lru_add_drain_all();
> +		drain_all_pages();
> +	}
> +
> +	/* Make sure all pages are isolated */
> +	if (WARN_ON(test_pages_isolated(start, end)))
> +		return -EBUSY;
> +
> +	return 0;
> +}
> +
> +static int __cm_alloc(unsigned long start, unsigned long size)
> +{
> +	unsigned long end, _start, _end;
> +	int ret;
> +
> +	pr_debug("%s(%p+%p)\n", __func__, (void *)start, (void *)size);
> +
> +	/*
> +	 * What we do here is we mark all pageblocks in range as
> +	 * MIGRATE_ISOLATE.  Because of the way page allocator work, we
> +	 * align the range to MAX_ORDER pages so that page allocator
> +	 * won't try to merge buddies from different pageblocks and
> +	 * change MIGRATE_ISOLATE to some other migration type.
> +	 *
> +	 * Once the pageblocks are marked as MIGRATE_ISOLATE, we
> +	 * migrate the pages from an unaligned range (ie. pages that
> +	 * we are interested in).  This will put all the pages in
> +	 * range back to page allocator as MIGRATE_ISOLATE.
> +	 *
> +	 * When this is done, we take the pages in range from page
> +	 * allocator removing them from the buddy system.  This way
> +	 * page allocator will never consider using them.
> +	 *
> +	 * This lets us mark the pageblocks back as MIGRATE_CMA so
> +	 * that free pages in the MAX_ORDER aligned range but not in
> +	 * the unaligned, original range are put back to page
> +	 * allocator so that buddy can use them.
> +	 */
> +
> +	start = phys_to_pfn(start);
> +	end   = start + (size >> PAGE_SHIFT);
> +
> +	pr_debug("\tisolate range(%lx, %lx)\n",
> +		 pfn_to_maxpage(start), pfn_to_maxpage_up(end));
> +	ret = __start_isolate_page_range(pfn_to_maxpage(start),
> +					 pfn_to_maxpage_up(end), MIGRATE_CMA);
> +	if (ret)
> +		goto done;
> +
> +	pr_debug("\tmigrate range(%lx, %lx)\n", start, end);
> +	ret = __cm_migrate(start, end);
> +	if (ret)
> +		goto done;
> +
> +	/*
> +	 * Pages from [start, end) are within a MAX_ORDER aligned
> +	 * blocks that are marked as MIGRATE_ISOLATE.  What's more,
> +	 * all pages in [start, end) are free in page allocator.  What
> +	 * we are going to do is to allocate all pages from [start,
> +	 * end) (that is remove them from page allocater).
> +	 *
> +	 * The only problem is that pages at the beginning and at the
> +	 * end of interesting range may be not aligned with pages that
> +	 * page allocator holds, ie. they can be part of higher order
> +	 * pages.  Because of this, we reserve the bigger range and
> +	 * once this is done free the pages we are not interested in.
> +	 */
> +
> +	pr_debug("\tfinding buddy\n");
> +	ret = 0;
> +	while (!PageBuddy(pfn_to_page(start & (~0UL << ret))))
> +		if (WARN_ON(++ret >= MAX_ORDER))
> +			return -EINVAL;
> +
> +	_start = start & (~0UL << ret);
> +	pr_debug("\talloc freed(%lx, %lx)\n", _start, end);
> +	_end   = alloc_contig_freed_pages(_start, end, 0);
> +
> +	/* Free head and tail (if any) */
> +	pr_debug("\tfree contig(%lx, %lx)\n", _start, start);
> +	free_contig_pages(pfn_to_page(_start), start - _start);
> +	pr_debug("\tfree contig(%lx, %lx)\n", end, _end);
> +	free_contig_pages(pfn_to_page(end), _end - end);
> +
> +	ret = 0;
> +
> +done:
> +	pr_debug("\tundo isolate range(%lx, %lx)\n",
> +		 pfn_to_maxpage(start), pfn_to_maxpage_up(end));
> +	__undo_isolate_page_range(pfn_to_maxpage(start),
> +				  pfn_to_maxpage_up(end), MIGRATE_CMA);
> +
> +	pr_debug("ret = %d\n", ret);
> +	return ret;
> +}
> +
> +static void __cm_free(unsigned long start, unsigned long size)
> +{
> +	pr_debug("%s(%p+%p)\n", __func__, (void *)start, (void *)size);
> +
> +	free_contig_pages(pfn_to_page(phys_to_pfn(start)),
> +			  size >> PAGE_SHIFT);
> +}

Hmm, it seems __cm_alloc() and __cm_migrate() has no special codes for CMA.
I'd like reuse this for my own contig page allocator.
So, could you make these function be more generic (name) ?
as
	__alloc_range(start, size, mirate_type);

Then, what I have to do is only to add "search range" functions.

Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
