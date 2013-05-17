Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 76DBA6B0033
	for <linux-mm@kvack.org>; Fri, 17 May 2013 11:48:50 -0400 (EDT)
Date: Fri, 17 May 2013 16:48:37 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCHv11 2/4] zbud: add to mm/
Message-ID: <20130517154837.GN11497@suse.de>
References: <1368448803-2089-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1368448803-2089-3-git-send-email-sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1368448803-2089-3-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@sr71.net>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Hugh Dickens <hughd@google.com>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On Mon, May 13, 2013 at 07:40:01AM -0500, Seth Jennings wrote:
> zbud is an special purpose allocator for storing compressed pages. It is
> designed to store up to two compressed pages per physical page.  While this
> design limits storage density, it has simple and deterministic reclaim
> properties that make it preferable to a higher density approach when reclaim
> will be used.
> 
> zbud works by storing compressed pages, or "zpages", together in pairs in a
> single memory page called a "zbud page".  The first buddy is "left
> justifed" at the beginning of the zbud page, and the last buddy is "right
> justified" at the end of the zbud page.  The benefit is that if either
> buddy is freed, the freed buddy space, coalesced with whatever slack space
> that existed between the buddies, results in the largest possible free region
> within the zbud page.
> 
> zbud also provides an attractive lower bound on density. The ratio of zpages
> to zbud pages can not be less than 1.  This ensures that zbud can never "do
> harm" by using more pages to store zpages than the uncompressed zpages would
> have used on their own.
> 
> This patch adds zbud to mm/ for later use by zswap.
> 
> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>

I'm not familiar with the code in staging/zcache/zbud.c and this looks
like a rewrite but I'm curious, why was an almost complete rewrite
necessary? The staging code looks like it had debugfs statistics and
the like that would help figure how well the packing was working and so
on. I guess it was probably because it was integrated tightly with other
components in staging but could that not be torn out? I'm guessing you
have a good reason but it'd be nice to see that in the changelog.

> ---
>  include/linux/zbud.h |   22 ++
>  mm/Kconfig           |   10 +
>  mm/Makefile          |    1 +
>  mm/zbud.c            |  564 ++++++++++++++++++++++++++++++++++++++++++++++++++
>  4 files changed, 597 insertions(+)
>  create mode 100644 include/linux/zbud.h
>  create mode 100644 mm/zbud.c
> 
> diff --git a/include/linux/zbud.h b/include/linux/zbud.h
> new file mode 100644
> index 0000000..954252b
> --- /dev/null
> +++ b/include/linux/zbud.h
> @@ -0,0 +1,22 @@
> +#ifndef _ZBUD_H_
> +#define _ZBUD_H_
> +
> +#include <linux/types.h>
> +
> +struct zbud_pool;
> +
> +struct zbud_ops {
> +	int (*evict)(struct zbud_pool *pool, unsigned long handle);
> +};
> +
> +struct zbud_pool *zbud_create_pool(gfp_t gfp, struct zbud_ops *ops);
> +void zbud_destroy_pool(struct zbud_pool *pool);
> +int zbud_alloc(struct zbud_pool *pool, int size, gfp_t gfp,
> +	unsigned long *handle);
> +void zbud_free(struct zbud_pool *pool, unsigned long handle);
> +int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries);
> +void *zbud_map(struct zbud_pool *pool, unsigned long handle);
> +void zbud_unmap(struct zbud_pool *pool, unsigned long handle);
> +int zbud_get_pool_size(struct zbud_pool *pool);
> +
> +#endif /* _ZBUD_H_ */
> diff --git a/mm/Kconfig b/mm/Kconfig
> index e742d06..908f41b 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -477,3 +477,13 @@ config FRONTSWAP
>  	  and swap data is stored as normal on the matching swap device.
>  
>  	  If unsure, say Y to enable frontswap.
> +
> +config ZBUD
> +	tristate "Buddy allocator for compressed pages"
> +	default n
> +	help
> +	  zbud is an special purpose allocator for storing compressed pages.
> +	  It is designed to store up to two compressed pages per physical page.
> +	  While this design limits storage density, it has simple and
> +	  deterministic reclaim properties that make it preferable to a higher
> +	  density approach when reclaim will be used.  
> diff --git a/mm/Makefile b/mm/Makefile
> index 72c5acb..95f0197 100644
> --- a/mm/Makefile
> +++ b/mm/Makefile
> @@ -58,3 +58,4 @@ obj-$(CONFIG_DEBUG_KMEMLEAK) += kmemleak.o
>  obj-$(CONFIG_DEBUG_KMEMLEAK_TEST) += kmemleak-test.o
>  obj-$(CONFIG_CLEANCACHE) += cleancache.o
>  obj-$(CONFIG_MEMORY_ISOLATION) += page_isolation.o
> +obj-$(CONFIG_ZBUD)	+= zbud.o
> diff --git a/mm/zbud.c b/mm/zbud.c
> new file mode 100644
> index 0000000..e5bd0e6
> --- /dev/null
> +++ b/mm/zbud.c
> @@ -0,0 +1,564 @@
> +/*
> + * zbud.c - Buddy Allocator for Compressed Pages
> + *
> + * Copyright (C) 2013, Seth Jennings, IBM
> + *
> + * Concepts based on zcache internal zbud allocator by Dan Magenheimer.
> + *
> + * zbud is an special purpose allocator for storing compressed pages. It is
> + * designed to store up to two compressed pages per physical page.  While this
> + * design limits storage density, it has simple and deterministic reclaim
> + * properties that make it preferable to a higher density approach when reclaim
> + * will be used.
> + *
> + * zbud works by storing compressed pages, or "zpages", together in pairs in a
> + * single memory page called a "zbud page".  The first buddy is "left
> + * justifed" at the beginning of the zbud page, and the last buddy is "right
> + * justified" at the end of the zbud page.  The benefit is that if either
> + * buddy is freed, the freed buddy space, coalesced with whatever slack space
> + * that existed between the buddies, results in the largest possible free region
> + * within the zbud page.
> + *
> + * zbud also provides an attractive lower bound on density. The ratio of zpages
> + * to zbud pages can not be less than 1.  This ensures that zbud can never "do
> + * harm" by using more pages to store zpages than the uncompressed zpages would
> + * have used on their own.
> + *
> + * zbud pages are divided into "chunks".  The size of the chunks is fixed at
> + * compile time and determined by NCHUNKS_ORDER below.  Dividing zbud pages
> + * into chunks allows organizing unbuddied zbud pages into a manageable number
> + * of unbuddied lists according to the number of free chunks available in the
> + * zbud page.
> + *

Fixing the size of the chunks at compile time is a very strict
limitation! Distributions will have to make that decision for all workloads
that might conceivably use zswap. Having the allocator only deal with pairs
of pages limits the worst-case behaviour where reclaim can generate lots of
IO to free a single physical page. However, the chunk size directly affects
the fragmentation properties, both internal and external, of this thing.
Once NCHUNKS is > 2 it is possible to create a workload that externally
fragments this allocator such that each physical page only holds one
compressed page. If this is a problem for a user then their only option
is to rebuild the kernel which is not always possible.

Please make this configurable by a kernel boot parameter at least. At
a glance it looks like only problem would be that you have to kmalloc
unbuddied[NCHUNKS] in the pool structure but that is hardly of earth
shattering difficulty. Make the variables read_mostly to avoid cache-line
bouncing problems.

Finally, because a review would never be complete without a bitching
session about names -- I don't like the name zbud. Buddy allocators take
a large block of memory and split it iteratively (by halves for binary
buddy allocators but there are variations) until it's a best fit for the
allocation request. A key advantage of such schemes is fast searching for
free holes. That's not what this allocator does and as the page allocator
is a binary buddy allocator in Linux, calling this this a buddy allocator
is a bit misleading. Looks like the existing zbud.c also has this problem
but hey.  This thing is a first-fit segmented free list allocator with
sub-allocator properties in that it takes fixed-sized blocks as inputs and
splits them into pairs, not a buddy allocator. That characterisation does
not lend itself to a snappy name but calling it zpair or something would
be slightly less misleading than calling it a buddy allocator.

First Fit Segmented-list Allocator for in-Kernel comprEssion (FFSAKE)? :/

> + * The zbud API differs from that of conventional allocators in that the
> + * allocation function, zbud_alloc(), returns an opaque handle to the user,
> + * not a dereferenceable pointer.  The user must map the handle using
> + * zbud_map() in order to get a usable pointer by which to access the
> + * allocation data and unmap the handle with zbud_unmap() when operations
> + * on the allocation data are complete.
> + */
> +
> +#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> +
> +#include <linux/atomic.h>
> +#include <linux/list.h>
> +#include <linux/mm.h>
> +#include <linux/module.h>
> +#include <linux/preempt.h>
> +#include <linux/slab.h>
> +#include <linux/spinlock.h>
> +#include <linux/zbud.h>
> +
> +/*****************
> + * Structures
> +*****************/
> +/**
> + * struct zbud_page - zbud page metadata overlay
> + * @page:	typed reference to the underlying struct page
> + * @donotuse:	this overlays the page flags and should not be used
> + * @first_chunks:	the size of the first buddy in chunks, 0 if free
> + * @last_chunks:	the size of the last buddy in chunks, 0 if free
> + * @buddy:	links the zbud page into the unbuddied/buddied lists in the pool
> + * @lru:	links the zbud page into the lru list in the pool
> + *
> + * This structure overlays the struct page to store metadata needed for a
> + * single storage page in for zbud.  There is a BUILD_BUG_ON in zbud_init()
> + * that ensures this structure is not larger that struct page.
> + *
> + * The PG_reclaim flag of the underlying page is used for indicating
> + * that this zbud page is under reclaim (see zbud_reclaim_page())
> + */
> +struct zbud_page {
> +	union {
> +		struct page page;
> +		struct {
> +			unsigned long donotuse;
> +			u16 first_chunks;
> +			u16 last_chunks;
> +			struct list_head buddy;
> +			struct list_head lru;
> +		};
> +	};
> +};
> +
> +/*
> + * NCHUNKS_ORDER determines the internal allocation granularity, effectively
> + * adjusting internal fragmentation.  It also determines the number of
> + * freelists maintained in each pool. NCHUNKS_ORDER of 6 means that the
> + * allocation granularity will be in chunks of size PAGE_SIZE/64, and there
> + * will be 64 freelists per pool.
> + */
> +#define NCHUNKS_ORDER	6
> +
> +#define CHUNK_SHIFT	(PAGE_SHIFT - NCHUNKS_ORDER)
> +#define CHUNK_SIZE	(1 << CHUNK_SHIFT)
> +#define NCHUNKS		(PAGE_SIZE >> CHUNK_SHIFT)
> +
> +/**
> + * struct zbud_pool - stores metadata for each zbud pool
> + * @lock:	protects all pool lists and first|last_chunk fields of any
> + *		zbud page in the pool
> + * @unbuddied:	array of lists tracking zbud pages that only contain one buddy;
> + *		the lists each zbud page is added to depends on the size of
> + *		its free region.
> + * @buddied:	list tracking the zbud pages that contain two buddies;
> + *		these zbud pages are full
> + * @pages_nr:	number of zbud pages in the pool.
> + * @ops:	pointer to a structure of user defined operations specified at
> + *		pool creation time.
> + *
> + * This structure is allocated at pool creation time and maintains metadata
> + * pertaining to a particular zbud pool.
> + */
> +struct zbud_pool {
> +	spinlock_t lock;
> +	struct list_head unbuddied[NCHUNKS];
> +	struct list_head buddied;
> +	struct list_head lru;
> +	atomic_t pages_nr;

There is no need for pages_nr to be atomic. It's always manipulated
under the lock. I see that the atomic is exported so someone can read it
that is outside the lock but they are goign to have to deal with races
anyway. atomic does not magically protect them

Also, pages_nr does not appear to be the number of zbud pages in the pool,
it's the number of zpages. You may want to report both for debugging
purposes as if nr_zpages != 2 * nr_zbud_pages then zswap is using more
physical pages than it should be.

> +	struct zbud_ops *ops;
> +};
> +
> +/*****************
> + * Helpers
> +*****************/
> +/* Just to make the code easier to read */
> +enum buddy {
> +	FIRST,
> +	LAST
> +};
> +
> +/* Converts an allocation size in bytes to size in zbud chunks */
> +static inline int size_to_chunks(int size)
> +{
> +	return (size + CHUNK_SIZE - 1) >> CHUNK_SHIFT;
> +}
> +
> +#define for_each_unbuddied_list(_iter, _begin) \
> +	for ((_iter) = (_begin); (_iter) < NCHUNKS; (_iter)++)
> +
> +/* Initializes a zbud page from a newly allocated page */
> +static inline struct zbud_page *init_zbud_page(struct page *page)
> +{
> +	struct zbud_page *zbpage = (struct zbud_page *)page;
> +	zbpage->first_chunks = 0;
> +	zbpage->last_chunks = 0;
> +	INIT_LIST_HEAD(&zbpage->buddy);
> +	INIT_LIST_HEAD(&zbpage->lru);
> +	return zbpage;
> +}

No need to inline. Only has one caller so the compiler will figure it
out.

> +
> +/* Resets a zbud page so that it can be properly freed  */
> +static inline struct page *reset_zbud_page(struct zbud_page *zbpage)
> +{
> +	struct page *page = &zbpage->page;
> +	set_page_private(page, 0);
> +	page->mapping = NULL;
> +	page->index = 0;
> +	page_mapcount_reset(page);
> +	init_page_count(page);
> +	INIT_LIST_HEAD(&page->lru);
> +	return page;
> +}

This is only used for freeing so call it free_zbud_page and have it call
__free_page for clarity. Also, this is a bit long for inlining.

> +
> +/*
> + * Encodes the handle of a particular buddy within a zbud page
> + * Pool lock should be held as this function accesses first|last_chunks
> + */
> +static inline unsigned long encode_handle(struct zbud_page *zbpage,
> +					enum buddy bud)
> +{
> +	unsigned long handle;
> +
> +	/*
> +	 * For now, the encoded handle is actually just the pointer to the data
> +	 * but this might not always be the case.  A little information hiding.
> +	 */
> +	handle = (unsigned long)page_address(&zbpage->page);
> +	if (bud == FIRST)
> +		return handle;
> +	handle += PAGE_SIZE - (zbpage->last_chunks  << CHUNK_SHIFT);
> +	return handle;
> +}

Your handles are unsigned long and are addresses. Consider making it an
opaque type so someone deferencing it would take a special kind of
stupid.

> +
> +/* Returns the zbud page where a given handle is stored */
> +static inline struct zbud_page *handle_to_zbud_page(unsigned long handle)
> +{
> +	return (struct zbud_page *)(virt_to_page(handle));
> +}
> +
> +/* Returns the number of free chunks in a zbud page */
> +static inline int num_free_chunks(struct zbud_page *zbpage)
> +{
> +	/*
> +	 * Rather than branch for different situations, just use the fact that
> +	 * free buddies have a length of zero to simplify everything.
> +	 */
> +	return NCHUNKS - zbpage->first_chunks - zbpage->last_chunks;
> +}
> +
> +/*****************
> + * API Functions
> +*****************/
> +/**
> + * zbud_create_pool() - create a new zbud pool
> + * @gfp:	gfp flags when allocating the zbud pool structure
> + * @ops:	user-defined operations for the zbud pool
> + *
> + * Return: pointer to the new zbud pool or NULL if the metadata allocation
> + * failed.
> + */
> +struct zbud_pool *zbud_create_pool(gfp_t gfp, struct zbud_ops *ops)
> +{
> +	struct zbud_pool *pool;
> +	int i;
> +
> +	pool = kmalloc(sizeof(struct zbud_pool), gfp);
> +	if (!pool)
> +		return NULL;
> +	spin_lock_init(&pool->lock);
> +	for_each_unbuddied_list(i, 0)
> +		INIT_LIST_HEAD(&pool->unbuddied[i]);
> +	INIT_LIST_HEAD(&pool->buddied);
> +	INIT_LIST_HEAD(&pool->lru);
> +	atomic_set(&pool->pages_nr, 0);
> +	pool->ops = ops;
> +	return pool;
> +}
> +EXPORT_SYMBOL_GPL(zbud_create_pool);
> +

Why the export? It doesn't look like this thing is going to be consumed
by modules.

> +/**
> + * zbud_destroy_pool() - destroys an existing zbud pool
> + * @pool:	the zbud pool to be destroyed
> + */
> +void zbud_destroy_pool(struct zbud_pool *pool)
> +{
> +	kfree(pool);
> +}
> +EXPORT_SYMBOL_GPL(zbud_destroy_pool);
> +
> +/**
> + * zbud_alloc() - allocates a region of a given size
> + * @pool:	zbud pool from which to allocate
> + * @size:	size in bytes of the desired allocation
> + * @gfp:	gfp flags used if the pool needs to grow
> + * @handle:	handle of the new allocation
> + *
> + * This function will attempt to find a free region in the pool large
> + * enough to satisfy the allocation request.  First, it tries to use
> + * free space in the most recently used zbud page, at the beginning of
> + * the pool LRU list.  If that zbud page is full or doesn't have the
> + * required free space, a best fit search of the unbuddied lists is
> + * performed. If no suitable free region is found, then a new page
> + * is allocated and added to the pool to satisfy the request.
> + *
> + * gfp should not set __GFP_HIGHMEM as highmem pages cannot be used
> + * as zbud pool pages.
> + *
> + * Return: 0 if success and handle is set, otherwise -EINVAL is the size or
> + * gfp arguments are invalid or -ENOMEM if the pool was unable to allocate
> + * a new page.
> + */
> +int zbud_alloc(struct zbud_pool *pool, int size, gfp_t gfp,
> +			unsigned long *handle)
> +{
> +	int chunks, i, freechunks;
> +	struct zbud_page *zbpage = NULL;
> +	enum buddy bud;
> +	struct page *page;
> +
> +	if (size <= 0 || size > PAGE_SIZE || gfp & __GFP_HIGHMEM)
> +		return -EINVAL;
> +	chunks = size_to_chunks(size);
> +	spin_lock(&pool->lock);
> +
> +	/*
> +	 * First, try to use the zbpage we last used (at the head of the
> +	 * LRU) to increase LRU locality of the buddies. This is first fit.
> +	 */
> +	if (!list_empty(&pool->lru)) {
> +		zbpage = list_first_entry(&pool->lru, struct zbud_page, lru);
> +		if (num_free_chunks(zbpage) >= chunks) {
> +			if (zbpage->first_chunks == 0) {
> +				list_del(&zbpage->buddy);
> +				bud = FIRST;
> +				goto found;
> +			}
> +			if (zbpage->last_chunks == 0) {
> +				list_del(&zbpage->buddy);
> +				bud = LAST;
> +				goto found;
> +			}
> +		}
> +	}
> +
> +	/* Second, try to find an unbuddied zbpage. This is best fit. */

No it isn't, it's also first fit.

Give for_each_unbuddied_list() additional smarts to always start with
the last zbpage that was used and collapse these two block of code
together and call it first-fit.

> +	zbpage = NULL;
> +	for_each_unbuddied_list(i, chunks) {
> +		if (!list_empty(&pool->unbuddied[i])) {
> +			zbpage = list_first_entry(&pool->unbuddied[i],
> +					struct zbud_page, buddy);
> +			list_del(&zbpage->buddy);
> +			if (zbpage->first_chunks == 0)
> +				bud = FIRST;
> +			else
> +				bud = LAST;
> +			goto found;
> +		}
> +	}
> +
> +	/* Lastly, couldn't find unbuddied zbpage, create new one */
> +	spin_unlock(&pool->lock);
> +	page = alloc_page(gfp);
> +	if (!page)
> +		return -ENOMEM;
> +	spin_lock(&pool->lock);
> +	atomic_inc(&pool->pages_nr);
> +	zbpage = init_zbud_page(page);
> +	bud = FIRST;
> +

What bounds the size of the pool? Maybe a higher layer does but should the
higher layer set the maximum size and enforce it here instead? That way the
higher layer does not need to know that the allocator is dealing with pages.

> +found:
> +	if (bud == FIRST)
> +		zbpage->first_chunks = chunks;
> +	else
> +		zbpage->last_chunks = chunks;
> +
> +	if (zbpage->first_chunks == 0 || zbpage->last_chunks == 0) {
> +		/* Add to unbuddied list */
> +		freechunks = num_free_chunks(zbpage);
> +		list_add(&zbpage->buddy, &pool->unbuddied[freechunks]);
> +	} else {
> +		/* Add to buddied list */
> +		list_add(&zbpage->buddy, &pool->buddied);
> +	}
> +
> +	/* Add/move zbpage to beginning of LRU */
> +	if (!list_empty(&zbpage->lru))
> +		list_del(&zbpage->lru);
> +	list_add(&zbpage->lru, &pool->lru);
> +
> +	*handle = encode_handle(zbpage, bud);
> +	spin_unlock(&pool->lock);
> +
> +	return 0;
> +}
> +EXPORT_SYMBOL_GPL(zbud_alloc);
> +
> +/**
> + * zbud_free() - frees the allocation associated with the given handle
> + * @pool:	pool in which the allocation resided
> + * @handle:	handle associated with the allocation returned by zbud_alloc()
> + *
> + * In the case that the zbud page in which the allocation resides is under
> + * reclaim, as indicated by the PG_reclaim flag being set, this function
> + * only sets the first|last_chunks to 0.  The page is actually freed
> + * once both buddies are evicted (see zbud_reclaim_page() below).
> + */
> +void zbud_free(struct zbud_pool *pool, unsigned long handle)
> +{
> +	struct zbud_page *zbpage;
> +	int freechunks;
> +
> +	spin_lock(&pool->lock);
> +	zbpage = handle_to_zbud_page(handle);
> +
> +	/* If first buddy, handle will be page aligned */
> +	if (handle & ~PAGE_MASK)
> +		zbpage->last_chunks = 0;
> +	else
> +		zbpage->first_chunks = 0;
> +
> +	if (PageReclaim(&zbpage->page)) {
> +		/* zbpage is under reclaim, reclaim will free */
> +		spin_unlock(&pool->lock);
> +		return;
> +	}
> +

This implies that it is possible for a zpage to get freed twice. That
sounds wrong. It sounds like a page being reclaimed should be isolated
from other lists that makes it accessible similar to how normal pages are
isolated from the LRU and then freed.

> +	/* Remove from existing buddy list */
> +	list_del(&zbpage->buddy);
> +
> +	if (zbpage->first_chunks == 0 && zbpage->last_chunks == 0) {
> +		/* zbpage is empty, free */
> +		list_del(&zbpage->lru);
> +		__free_page(reset_zbud_page(zbpage));
> +		atomic_dec(&pool->pages_nr);
> +	} else {
> +		/* Add to unbuddied list */
> +		freechunks = num_free_chunks(zbpage);
> +		list_add(&zbpage->buddy, &pool->unbuddied[freechunks]);
> +	}
> +
> +	spin_unlock(&pool->lock);
> +}
> +EXPORT_SYMBOL_GPL(zbud_free);
> +
> +#define list_tail_entry(ptr, type, member) \
> +	list_entry((ptr)->prev, type, member)
> +
> +/**
> + * zbud_reclaim_page() - evicts allocations from a pool page and frees it
> + * @pool:	pool from which a page will attempt to be evicted
> + * @retires:	number of pages on the LRU list for which eviction will
> + *		be attempted before failing
> + *
> + * zbud reclaim is different from normal system reclaim in that the reclaim is
> + * done from the bottom, up.  This is because only the bottom layer, zbud, has
> + * information on how the allocations are organized within each zbud page. This
> + * has the potential to create interesting locking situations between zbud and
> + * the user, however.
> + *
> + * To avoid these, this is how zbud_reclaim_page() should be called:
> +
> + * The user detects a page should be reclaimed and calls zbud_reclaim_page().
> + * zbud_reclaim_page() will remove a zbud page from the pool LRU list and call
> + * the user-defined eviction handler with the pool and handle as arguments.
> + *
> + * If the handle can not be evicted, the eviction handler should return
> + * non-zero. zbud_reclaim_page() will add the zbud page back to the
> + * appropriate list and try the next zbud page on the LRU up to
> + * a user defined number of retries.
> + *
> + * If the handle is successfully evicted, the eviction handler should
> + * return 0 _and_ should have called zbud_free() on the handle. zbud_free()
> + * contains logic to delay freeing the page if the page is under reclaim,
> + * as indicated by the setting of the PG_reclaim flag on the underlying page.
> + *
> + * If all buddies in the zbud page are successfully evicted, then the
> + * zbud page can be freed.
> + *
> + * Returns: 0 if page is successfully freed, otherwise -EINVAL if there are
> + * no pages to evict or an eviction handler is not registered, -EAGAIN if
> + * the retry limit was hit.
> + */
> +int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries)
> +{
> +	int i, ret, freechunks;
> +	struct zbud_page *zbpage;
> +	unsigned long first_handle = 0, last_handle = 0;
> +
> +	spin_lock(&pool->lock);
> +	if (!pool->ops || !pool->ops->evict || list_empty(&pool->lru) ||
> +			retries == 0) {
> +		spin_unlock(&pool->lock);
> +		return -EINVAL;
> +	}
> +	for (i = 0; i < retries; i++) {
> +		zbpage = list_tail_entry(&pool->lru, struct zbud_page, lru);
> +		list_del(&zbpage->lru);
> +		list_del(&zbpage->buddy);
> +		/* Protect zbpage against free */
> +		SetPageReclaim(&zbpage->page);

Why not isolated it instead of using a page flag?

> +		/*
> +		 * We need encode the handles before unlocking, since we can
> +		 * race with free that will set (first|last)_chunks to 0
> +		 */
> +		first_handle = 0;
> +		last_handle = 0;
> +		if (zbpage->first_chunks)
> +			first_handle = encode_handle(zbpage, FIRST);
> +		if (zbpage->last_chunks)
> +			last_handle = encode_handle(zbpage, LAST);
> +		spin_unlock(&pool->lock);
> +
> +		/* Issue the eviction callback(s) */
> +		if (first_handle) {
> +			ret = pool->ops->evict(pool, first_handle);
> +			if (ret)
> +				goto next;
> +		}
> +		if (last_handle) {
> +			ret = pool->ops->evict(pool, last_handle);
> +			if (ret)
> +				goto next;
> +		}
> +next:
> +		spin_lock(&pool->lock);
> +		ClearPageReclaim(&zbpage->page);
> +		if (zbpage->first_chunks == 0 && zbpage->last_chunks == 0) {
> +			/*
> +			 * Both buddies are now free, free the zbpage and
> +			 * return success.
> +			 */
> +			__free_page(reset_zbud_page(zbpage));
> +			atomic_dec(&pool->pages_nr);
> +			spin_unlock(&pool->lock);
> +			return 0;
> +		} else if (zbpage->first_chunks == 0 ||
> +				zbpage->last_chunks == 0) {
> +			/* add to unbuddied list */
> +			freechunks = num_free_chunks(zbpage);
> +			list_add(&zbpage->buddy, &pool->unbuddied[freechunks]);
> +		} else {
> +			/* add to buddied list */
> +			list_add(&zbpage->buddy, &pool->buddied);
> +		}
> +
> +		/* add to beginning of LRU */
> +		list_add(&zbpage->lru, &pool->lru);
> +	}
> +	spin_unlock(&pool->lock);
> +	return -EAGAIN;
> +}
> +EXPORT_SYMBOL_GPL(zbud_reclaim_page);
> +
> +/**
> + * zbud_map() - maps the allocation associated with the given handle
> + * @pool:	pool in which the allocation resides
> + * @handle:	handle associated with the allocation to be mapped
> + *
> + * While trivial for zbud, the mapping functions for others allocators
> + * implementing this allocation API could have more complex information encoded
> + * in the handle and could create temporary mappings to make the data
> + * accessible to the user.
> + *
> + * Returns: a pointer to the mapped allocation
> + */
> +void *zbud_map(struct zbud_pool *pool, unsigned long handle)
> +{
> +	return (void *)(handle);
> +}
> +EXPORT_SYMBOL_GPL(zbud_map);
> +
> +/**
> + * zbud_unmap() - maps the allocation associated with the given handle
> + * @pool:	pool in which the allocation resides
> + * @handle:	handle associated with the allocation to be unmapped
> + */
> +void zbud_unmap(struct zbud_pool *pool, unsigned long handle)
> +{
> +}
> +EXPORT_SYMBOL_GPL(zbud_unmap);
> +
> +/**
> + * zbud_get_pool_size() - gets the zbud pool size in pages
> + * @pool:	pool whose size is being queried
> + *
> + * Returns: size in pages of the given pool
> + */
> +int zbud_get_pool_size(struct zbud_pool *pool)
> +{
> +	return atomic_read(&pool->pages_nr);
> +}
> +EXPORT_SYMBOL_GPL(zbud_get_pool_size);
> +
> +static int __init init_zbud(void)
> +{
> +	/* Make sure we aren't overflowing the underlying struct page */
> +	BUILD_BUG_ON(sizeof(struct zbud_page) != sizeof(struct page));
> +	/* Make sure we can represent any chunk offset with a u16 */
> +	BUILD_BUG_ON(sizeof(u16) * BITS_PER_BYTE < PAGE_SHIFT - CHUNK_SHIFT);
> +	pr_info("loaded\n");
> +	return 0;
> +}
> +
> +static void __exit exit_zbud(void)
> +{
> +	pr_info("unloaded\n");
> +}
> +
> +module_init(init_zbud);
> +module_exit(exit_zbud);
> +
> +MODULE_LICENSE("GPL");
> +MODULE_AUTHOR("Seth Jennings <sjenning@linux.vnet.ibm.com>");
> +MODULE_DESCRIPTION("Buddy Allocator for Compressed Pages");
> -- 
> 1.7.9.5
> 

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
