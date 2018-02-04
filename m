Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 76F416B0005
	for <linux-mm@kvack.org>; Sun,  4 Feb 2018 17:06:37 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id b7so3855732pga.12
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 14:06:37 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id d90-v6si3517753pld.193.2018.02.04.14.06.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 04 Feb 2018 14:06:35 -0800 (PST)
Subject: Re: [PATCH 4/6] Protectable Memory
References: <20180204164732.28241-1-igor.stoppa@huawei.com>
 <20180204164732.28241-5-igor.stoppa@huawei.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <921d4c76-703f-dd41-0451-599441d23c1d@infradead.org>
Date: Sun, 4 Feb 2018 14:06:32 -0800
MIME-Version: 1.0
In-Reply-To: <20180204164732.28241-5-igor.stoppa@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>, jglisse@redhat.com, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, hch@infradead.org, willy@infradead.org
Cc: cl@linux.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On 02/04/2018 08:47 AM, Igor Stoppa wrote:
> The MMU available in many systems running Linux can often provide R/O
> protection to the memory pages it handles.
> 
> However, the MMU-based protection works efficiently only when said pages
> contain exclusively data that will not need further modifications.
> 
> Statically allocated variables can be segregated into a dedicated
> section, but this does not sit very well with dynamically allocated
> ones.
> 
> Dynamic allocation does not provide, currently, any means for grouping
> variables in memory pages that would contain exclusively data suitable
> for conversion to read only access mode.
> 
> The allocator here provided (pmalloc - protectable memory allocator)
> introduces the concept of pools of protectable memory.
> 
> A module can request a pool and then refer any allocation request to the
> pool handler it has received.
> 
> Once all the chunks of memory associated to a specific pool are
> initialized, the pool can be protected.
> 
> After this point, the pool can only be destroyed (it is up to the module
> to avoid any further references to the memory from the pool, after
> the destruction is invoked).
> 
> The latter case is mainly meant for releasing memory, when a module is
> unloaded.
> 
> A module can have as many pools as needed, for example to support the
> protection of data that is initialized in sufficiently distinct phases.
> 
> Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>
> ---
>  include/linux/genalloc.h |   3 +
>  include/linux/pmalloc.h  | 213 ++++++++++++++++++++
>  include/linux/vmalloc.h  |   1 +
>  lib/genalloc.c           |  27 +++
>  mm/Makefile              |   1 +
>  mm/pmalloc.c             | 514 +++++++++++++++++++++++++++++++++++++++++++++++
>  mm/usercopy.c            |  25 ++-
>  7 files changed, 780 insertions(+), 4 deletions(-)
>  create mode 100644 include/linux/pmalloc.h
>  create mode 100644 mm/pmalloc.c
> 
> diff --git a/include/linux/genalloc.h b/include/linux/genalloc.h
> index dcaa33e74b1c..b6c4cea9fbd8 100644
> --- a/include/linux/genalloc.h
> +++ b/include/linux/genalloc.h
> @@ -121,6 +121,9 @@ extern unsigned long gen_pool_alloc_algo(struct gen_pool *, size_t,
>  extern void *gen_pool_dma_alloc(struct gen_pool *pool, size_t size,
>  		dma_addr_t *dma);
>  extern void gen_pool_free(struct gen_pool *, unsigned long, size_t);
> +
> +extern void gen_pool_flush_chunk(struct gen_pool *pool,
> +				 struct gen_pool_chunk *chunk);
>  extern void gen_pool_for_each_chunk(struct gen_pool *,
>  	void (*)(struct gen_pool *, struct gen_pool_chunk *, void *), void *);
>  extern size_t gen_pool_avail(struct gen_pool *);
> diff --git a/include/linux/pmalloc.h b/include/linux/pmalloc.h
> new file mode 100644
> index 000000000000..5fa8a78be819
> --- /dev/null
> +++ b/include/linux/pmalloc.h
> @@ -0,0 +1,213 @@
> +/* SPDX-License-Identifier: GPL-2.0
> + *
> + * pmalloc.h: Header for Protectable Memory Allocator
> + *
> + * (C) Copyright 2017 Huawei Technologies Co. Ltd.
> + * Author: Igor Stoppa <igor.stoppa@huawei.com>
> + */
> +
> +#ifndef _PMALLOC_H
> +#define _PMALLOC_H

use        _LINUX_PMALLOC_H_

> +
> +
> +#include <linux/genalloc.h>
> +#include <linux/string.h>
> +
> +#define PMALLOC_DEFAULT_ALLOC_ORDER (-1)
> +
> +/*
> + * Library for dynamic allocation of pools of memory that can be,
> + * after initialization, marked as read-only.
> + *
> + * This is intended to complement __read_only_after_init, for those cases
> + * where either it is not possible to know the initialization value before
> + * init is completed, or the amount of data is variable and can be
> + * determined only at run-time.
> + *
> + * ***WARNING***
> + * The user of the API is expected to synchronize:
> + * 1) allocation,
> + * 2) writes to the allocated memory,
> + * 3) write protection of the pool,
> + * 4) freeing of the allocated memory, and
> + * 5) destruction of the pool.
> + *
> + * For a non-threaded scenario, this type of locking is not even required.
> + *
> + * Even if the library were to provide support for locking, point 2)
> + * would still depend on the user taking the lock.
> + */
> +
> +
> +/**
> + * pmalloc_create_pool - create a new protectable memory pool -

Drop trailing " -".

> + * @name: the name of the pool, must be unique

Is that enforced?  Will return NULL if @name is duplicated?

> + * @min_alloc_order: log2 of the minimum allocation size obtainable
> + *                   from the pool
> + *
> + * Creates a new (empty) memory pool for allocation of protectable
> + * memory. Memory will be allocated upon request (through pmalloc).
> + *
> + * Returns a pointer to the new pool upon success, otherwise a NULL.
> + */
> +struct gen_pool *pmalloc_create_pool(const char *name,
> +					 int min_alloc_order);
> +
> +
> +int is_pmalloc_object(const void *ptr, const unsigned long n);
> +
> +/**
> + * pmalloc_prealloc - tries to allocate a memory chunk of the requested size
> + * @pool: handler to the pool to be used for memory allocation

             handle (I think)

> + * @size: amount of memory (in bytes) requested
> + *
> + * Prepares a chunk of the requested size.
> + * This is intended to both minimize latency in later memory requests and
> + * avoid sleping during allocation.

            sleeping

> + * Memory allocated with prealloc is stored in one single chunk, as

                       with pmalloc_prealloc()

> + * opposite to what is allocated on-demand when pmalloc runs out of free

      opposed to

> + * space already existing in the pool and has to invoke vmalloc.
> + *
> + * Returns true if the vmalloc call was successful, false otherwise.

Where is the allocated memory (pointer)?  I.e., how does the caller know
where that memory is?
Oh, that memory isn't yet available to the caller until it calls pmalloc(), right?


> + */
> +bool pmalloc_prealloc(struct gen_pool *pool, size_t size);
> +
> +/**
> + * pmalloc - allocate protectable memory from a pool
> + * @pool: handler to the pool to be used for memory allocation

             handle (?)

> + * @size: amount of memory (in bytes) requested
> + * @gfp: flags for page allocation
> + *
> + * Allocates memory from an unprotected pool. If the pool doesn't have
> + * enough memory, and the request did not include GFP_ATOMIC, an attempt
> + * is made to add a new chunk of memory to the pool
> + * (a multiple of PAGE_SIZE), in order to fit the new request.

                                             fill
What if @size is > PAGE_SIZE?

> + * Otherwise, NULL is returned.
> + *
> + * Returns the pointer to the memory requested upon success,
> + * NULL otherwise (either no memory available or pool already read-only).

It would be good to use the
    * Return:
kernel-doc notation for return values.

> + */
> +void *pmalloc(struct gen_pool *pool, size_t size, gfp_t gfp);
> +
> +
> +/**
> + * pzalloc - zero-initialized version of pmalloc
> + * @pool: handler to the pool to be used for memory allocation

             handle (?)

> + * @size: amount of memory (in bytes) requested
> + * @gfp: flags for page allocation
> + *
> + * Executes pmalloc, initializing the memory requested to 0,
> + * before returning the pointer to it.
> + *
> + * Returns the pointer to the zeroed memory requested, upon success,
> + * NULL otherwise (either no memory available or pool already read-only).
> + */
> +static inline void *pzalloc(struct gen_pool *pool, size_t size, gfp_t gfp)
> +{
> +	return pmalloc(pool, size, gfp | __GFP_ZERO);
> +}
> +
> +/**
> + * pmalloc_array - allocates an array according to the parameters
> + * @pool: handler to the pool to be used for memory allocation

             handle

> + * @n: number of elements in the array
> + * @size: amount of memory (in bytes) requested for each element
> + * @flags: flags for page allocation
> + *
> + * Executes pmalloc, if it has a chance to succeed.
> + *
> + * Returns either NULL or the pmalloc result.
> + */
> +static inline void *pmalloc_array(struct gen_pool *pool, size_t n,
> +				  size_t size, gfp_t flags)
> +{
> +	if (unlikely(!(pool && n && size)))
> +		return NULL;
> +	return pmalloc(pool, n * size, flags);
> +}
> +
> +/**
> + * pcalloc - allocates a 0-initialized array according to the parameters
> + * @pool: handler to the pool to be used for memory allocation

             handle

> + * @n: number of elements in the array
> + * @size: amount of memory (in bytes) requested
> + * @flags: flags for page allocation
> + *
> + * Executes pmalloc_array, if it has a chance to succeed.
> + *
> + * Returns either NULL or the pmalloc result.
> + */
> +static inline void *pcalloc(struct gen_pool *pool, size_t n,
> +			    size_t size, gfp_t flags)
> +{
> +	return pmalloc_array(pool, n, size, flags | __GFP_ZERO);
> +}
> +
> +/**
> + * pstrdup - duplicate a string, using pmalloc as allocator
> + * @pool: handler to the pool to be used for memory allocation

             handle

> + * @s: string to duplicate
> + * @gfp: flags for page allocation
> + *
> + * Generates a copy of the given string, allocating sufficient memory
> + * from the given pmalloc pool.
> + *
> + * Returns a pointer to the replica, NULL in case of recoverable error.
> + */
> +static inline char *pstrdup(struct gen_pool *pool, const char *s, gfp_t gfp)
> +{
> +	size_t len;
> +	char *buf;
> +
> +	if (unlikely(pool == NULL || s == NULL))
> +		return NULL;
> +
> +	len = strlen(s) + 1;
> +	buf = pmalloc(pool, len, gfp);
> +	if (likely(buf))
> +		strncpy(buf, s, len);
> +	return buf;
> +}
> +
> +/**
> + * pmalloc_protect_pool - turn a read/write pool read-only
> + * @pool: the pool to protect
> + *
> + * Write-protects all the memory chunks assigned to the pool.
> + * This prevents any further allocation.
> + *
> + * Returns 0 upon success, -EINVAL in abnormal cases.
> + */
> +int pmalloc_protect_pool(struct gen_pool *pool);
> +
> +/**
> + * pfree - mark as unused memory that was previously in use
> + * @pool: handler to the pool to be used for memory allocation

             handle

> + * @addr: the beginning of the memory area to be freed
> + *
> + * The behavior of pfree is different, depending on the state of the
> + * protection.
> + * If the pool is not yet protected, the memory is marked as unused and
> + * will be availabel for further allocations.

              available

> + * If the pool is already protected, the memory is marked as unused, but
> + * it will still be impossible to perform further allocation, because of
> + * the existing protection.
> + * The freed memory, in this case, will be truly released only when the
> + * pool is destroyed.
> + */
> +static inline void pfree(struct gen_pool *pool, const void *addr)
> +{
> +	gen_pool_free(pool, (unsigned long)addr, 0);
> +}
> +
> +/**
> + * pmalloc_destroy_pool - destroys a pool and all the associated memory
> + * @pool: the pool to destroy
> + *
> + * All the memory that was allocated through pmalloc in the pool will be freed.
> + *
> + * Returns 0 upon success, -EINVAL in abnormal cases.
> + */
> +int pmalloc_destroy_pool(struct gen_pool *pool);
> +
> +#endif


> diff --git a/mm/pmalloc.c b/mm/pmalloc.c
> new file mode 100644
> index 000000000000..11daca252589
> --- /dev/null
> +++ b/mm/pmalloc.c
> @@ -0,0 +1,514 @@
> +/* SPDX-License-Identifier: GPL-2.0
> + *
> + * pmalloc.c: Protectable Memory Allocator
> + *
> + * (C) Copyright 2017 Huawei Technologies Co. Ltd.
> + * Author: Igor Stoppa <igor.stoppa@huawei.com>
> + */
> +
> +#include <linux/printk.h>
> +#include <linux/init.h>
> +#include <linux/mm.h>
> +#include <linux/vmalloc.h>
> +#include <linux/genalloc.h>
> +#include <linux/kernel.h>
> +#include <linux/log2.h>
> +#include <linux/slab.h>
> +#include <linux/device.h>
> +#include <linux/atomic.h>
> +#include <linux/rculist.h>
> +#include <linux/set_memory.h>
> +#include <asm/cacheflush.h>
> +#include <asm/page.h>
> +
> +#include "pmalloc-selftest.h"
> +
> +/**

/** means that the following comments are kernel-doc notation, but these
comments are not, so just use /* there, please.

> + * pmalloc_data contains the data specific to a pmalloc pool,
> + * in a format compatible with the design of gen_alloc.
> + * Some of the fields are used for exposing the corresponding parameter
> + * to userspace, through sysfs.
> + */
> +struct pmalloc_data {
> +	struct gen_pool *pool;  /* Link back to the associated pool. */
> +	bool protected;     /* Status of the pool: RO or RW. */
> +	struct kobj_attribute attr_protected; /* Sysfs attribute. */
> +	struct kobj_attribute attr_avail;     /* Sysfs attribute. */
> +	struct kobj_attribute attr_size;      /* Sysfs attribute. */
> +	struct kobj_attribute attr_chunks;    /* Sysfs attribute. */
> +	struct kobject *pool_kobject;
> +	struct list_head node; /* list of pools */
> +};
> +
> +static LIST_HEAD(pmalloc_final_list);
> +static LIST_HEAD(pmalloc_tmp_list);
> +static struct list_head *pmalloc_list = &pmalloc_tmp_list;
> +static DEFINE_MUTEX(pmalloc_mutex);
> +static struct kobject *pmalloc_kobject;

[snip]

> +/**

Just use /* since this is not kernel-doc notation.

> + * Exposes the pool and its attributes through sysfs.
> + */
> +static struct kobject *pmalloc_connect(struct pmalloc_data *data)
> +{
> +	const struct attribute *attrs[] = {
> +		&data->attr_protected.attr,
> +		&data->attr_avail.attr,
> +		&data->attr_size.attr,
> +		&data->attr_chunks.attr,
> +		NULL
> +	};
> +	struct kobject *kobj;
> +
> +	kobj = kobject_create_and_add(data->pool->name, pmalloc_kobject);
> +	if (unlikely(!kobj))
> +		return NULL;
> +
> +	if (unlikely(sysfs_create_files(kobj, attrs) < 0)) {
> +		kobject_put(kobj);
> +		kobj = NULL;
> +	}
> +	return kobj;
> +}
> +
> +/**

Ditto.

> + * Removes the pool and its attributes from sysfs.
> + */
> +static void pmalloc_disconnect(struct pmalloc_data *data,
> +			       struct kobject *kobj)
> +{
> +	const struct attribute *attrs[] = {
> +		&data->attr_protected.attr,
> +		&data->attr_avail.attr,
> +		&data->attr_size.attr,
> +		&data->attr_chunks.attr,
> +		NULL
> +	};
> +
> +	sysfs_remove_files(kobj, attrs);
> +	kobject_put(kobj);
> +}
> +
> +/**

Same.

> + * Declares an attribute of the pool.
> + */
> +
> +#define pmalloc_attr_init(data, attr_name) \
> +do { \
> +	sysfs_attr_init(&data->attr_##attr_name.attr); \
> +	data->attr_##attr_name.attr.name = #attr_name; \
> +	data->attr_##attr_name.attr.mode = VERIFY_OCTAL_PERMISSIONS(0400); \
> +	data->attr_##attr_name.show = pmalloc_pool_show_##attr_name; \
> +} while (0)

[snip]


> +int is_pmalloc_object(const void *ptr, const unsigned long n)
> +{
> +	struct vm_struct *area;
> +	struct page *page;
> +	unsigned long area_start;
> +	unsigned long area_end;
> +	unsigned long object_start;
> +	unsigned long object_end;
> +
> +
> +	/* is_pmalloc_object gets called pretty late, so chances are high
> +	 * that the object is indeed of vmalloc type
> +	 */

Multi-line comment style is
	/*
	 * comment1
	 * comment..N
	 */

> +	if (unlikely(!is_vmalloc_addr(ptr)))
> +		return NOT_PMALLOC_OBJECT;
> +
> +	page = vmalloc_to_page(ptr);
> +	if (unlikely(!page))
> +		return NOT_PMALLOC_OBJECT;
> +
> +	area = page->area;
> +
> +	if (likely(!(area->flags & VM_PMALLOC)))
> +		return NOT_PMALLOC_OBJECT;
> +
> +	area_start = (unsigned long)area->addr;
> +	area_end = area_start + area->nr_pages * PAGE_SIZE - 1;
> +	object_start = (unsigned long)ptr;
> +	object_end = object_start + n - 1;
> +
> +	if (likely((area_start <= object_start) &&
> +		   (object_end <= area_end)))
> +		return VALID_PMALLOC_OBJECT;
> +	else
> +		return INVALID_PMALLOC_OBJECT;
> +}
> +
> +
> +bool pmalloc_prealloc(struct gen_pool *pool, size_t size)
> +{
> +	void *chunk;
> +	size_t chunk_size;
> +	bool add_error;
> +	unsigned int order;
> +
> +	if (check_alloc_params(pool, size))
> +		return false;
> +
> +	order = (unsigned int)pool->min_alloc_order;
> +
> +	/* Expand pool */
> +	chunk_size = roundup(size, PAGE_SIZE);
> +	chunk = vmalloc(chunk_size);
> +	if (unlikely(chunk == NULL))
> +		return false;
> +
> +	/* Locking is already done inside gen_pool_add */
> +	add_error = gen_pool_add(pool, (unsigned long)chunk, chunk_size,
> +				 NUMA_NO_NODE);
> +	if (unlikely(add_error != 0))
> +		goto abort;
> +
> +	return true;
> +abort:
> +	vfree_atomic(chunk);
> +	return false;
> +
> +}
> +
> +void *pmalloc(struct gen_pool *pool, size_t size, gfp_t gfp)
> +{
> +	void *chunk;
> +	size_t chunk_size;
> +	bool add_error;
> +	unsigned long retval;
> +	unsigned int order;
> +
> +	if (check_alloc_params(pool, size))
> +		return NULL;
> +
> +	order = (unsigned int)pool->min_alloc_order;
> +
> +retry_alloc_from_pool:
> +	retval = gen_pool_alloc(pool, size);
> +	if (retval)
> +		goto return_allocation;
> +
> +	if (unlikely((gfp & __GFP_ATOMIC))) {
> +		if (unlikely((gfp & __GFP_NOFAIL)))
> +			goto retry_alloc_from_pool;
> +		else
> +			return NULL;
> +	}
> +
> +	/* Expand pool */
> +	chunk_size = roundup(size, PAGE_SIZE);
> +	chunk = vmalloc(chunk_size);
> +	if (unlikely(!chunk)) {
> +		if (unlikely((gfp & __GFP_NOFAIL)))
> +			goto retry_alloc_from_pool;
> +		else
> +			return NULL;
> +	}
> +	if (unlikely(!tag_chunk(chunk)))
> +		goto free;
> +
> +	/* Locking is already done inside gen_pool_add */
> +	add_error = gen_pool_add(pool, (unsigned long)chunk, chunk_size,
> +				 NUMA_NO_NODE);
> +	if (unlikely(add_error))
> +		goto abort;
> +
> +	retval = gen_pool_alloc(pool, size);
> +	if (retval) {
> +return_allocation:
> +		*(size_t *)retval = size;
> +		if (gfp & __GFP_ZERO)
> +			memset((void *)retval, 0, size);
> +		return (void *)retval;
> +	}
> +	/* Here there is no test for __GFP_NO_FAIL because, in case of
> +	 * concurrent allocation, one thread might add a chunk to the
> +	 * pool and this memory could be allocated by another thread,
> +	 * before the first thread gets a chance to use it.
> +	 * As long as vmalloc succeeds, it's ok to retry.
> +	 */

Fix multi-line comment style.

> +	goto retry_alloc_from_pool;
> +abort:
> +	untag_chunk(chunk);
> +free:
> +	vfree_atomic(chunk);
> +	return NULL;
> +}

[snip]

> +/**

Just use /*

> + * When the sysfs is ready to receive registrations, connect all the
> + * pools previously created. Also enable further pools to be connected
> + * right away.
> + */
> +static int __init pmalloc_late_init(void)
> +{
> +	struct pmalloc_data *data, *n;
> +
> +	pmalloc_kobject = kobject_create_and_add("pmalloc", kernel_kobj);
> +
> +	mutex_lock(&pmalloc_mutex);
> +	pmalloc_list = &pmalloc_final_list;
> +
> +	if (likely(pmalloc_kobject != NULL)) {
> +		list_for_each_entry_safe(data, n, &pmalloc_tmp_list, node) {
> +			list_move(&data->node, &pmalloc_final_list);
> +			pmalloc_connect(data);
> +		}
> +	}
> +	mutex_unlock(&pmalloc_mutex);
> +	pmalloc_selftest();
> +	return 0;
> +}
> +late_initcall(pmalloc_late_init);

> diff --git a/mm/usercopy.c b/mm/usercopy.c
> index a9852b24715d..c3b10298d808 100644
> --- a/mm/usercopy.c
> +++ b/mm/usercopy.c
> @@ -15,6 +15,7 @@
>  #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
>  
>  #include <linux/mm.h>
> +#include <linux/pmalloc.h>
>  #include <linux/slab.h>
>  #include <linux/sched.h>
>  #include <linux/sched/task.h>
> @@ -222,6 +223,7 @@ static inline const char *check_heap_object(const void *ptr, unsigned long n,
>  void __check_object_size(const void *ptr, unsigned long n, bool to_user)
>  {
>  	const char *err;
> +	int retv;
>  
>  	/* Skip all tests if size is zero. */
>  	if (!n)
> @@ -229,12 +231,12 @@ void __check_object_size(const void *ptr, unsigned long n, bool to_user)
>  
>  	/* Check for invalid addresses. */
>  	err = check_bogus_address(ptr, n);
> -	if (err)
> +	if (unlikely(err))
>  		goto report;
>  
>  	/* Check for bad heap object. */
>  	err = check_heap_object(ptr, n, to_user);
> -	if (err)
> +	if (unlikely(err))
>  		goto report;
>  
>  	/* Check for bad stack object. */
> @@ -257,8 +259,23 @@ void __check_object_size(const void *ptr, unsigned long n, bool to_user)
>  
>  	/* Check for object in kernel to avoid text exposure. */
>  	err = check_kernel_text_object(ptr, n);
> -	if (!err)
> -		return;
> +	if (unlikely(err))
> +		goto report;
> +
> +	/* Check if object is from a pmalloc chunk.
> +	 */

Use kernel multi-line comment style.

> +	retv = is_pmalloc_object(ptr, n);
> +	if (unlikely(retv)) {
> +		if (unlikely(!to_user)) {
> +			err = "<trying to write to pmalloc object>";
> +			goto report;
> +		}
> +		if (retv < 0) {
> +			err = "<invalid pmalloc object>";
> +			goto report;
> +		}
> +	}
> +	return;
>  
>  report:
>  	report_usercopy(ptr, n, to_user, err);
> 


-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
