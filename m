Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 81F496B0031
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 02:43:48 -0400 (EDT)
Message-ID: <51AEDE10.4010108@oracle.com>
Date: Wed, 05 Jun 2013 14:43:28 +0800
From: Bob Liu <bob.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCHv13 2/4] zbud: add to mm/
References: <1370291585-26102-1-git-send-email-sjenning@linux.vnet.ibm.com> <1370291585-26102-3-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1370291585-26102-3-git-send-email-sjenning@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@sr71.net>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Hugh Dickens <hughd@google.com>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

Hi Seth,

On 06/04/2013 04:33 AM, Seth Jennings wrote:
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
> This implementation is a rewrite of the zbud allocator internally used
> by zcache in the driver/staging tree.  The rewrite was necessary to
> remove some of the zcache specific elements that were ingrained throughout
> and provide a generic allocation interface that can later be used by
> zsmalloc and others.
> 
> This patch adds zbud to mm/ for later use by zswap.
> 
> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
> Acked-by: Rik van Riel <riel@redhat.com>
> ---
>  include/linux/zbud.h |   22 +++
>  mm/Kconfig           |   10 +
>  mm/Makefile          |    1 +
>  mm/zbud.c            |  526 ++++++++++++++++++++++++++++++++++++++++++++++++++
>  4 files changed, 559 insertions(+)
>  create mode 100644 include/linux/zbud.h
>  create mode 100644 mm/zbud.c
> 
> diff --git a/include/linux/zbud.h b/include/linux/zbud.h
> new file mode 100644
> index 0000000..2571a5c
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
> +u64 zbud_get_pool_size(struct zbud_pool *pool);
> +
> +#endif /* _ZBUD_H_ */
> diff --git a/mm/Kconfig b/mm/Kconfig
> index e742d06..3367ac3 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -477,3 +477,13 @@ config FRONTSWAP
>  	  and swap data is stored as normal on the matching swap device.
>  
>  	  If unsure, say Y to enable frontswap.
> +
> +config ZBUD
> +	tristate
> +	default n
> +	help
> +	  A special purpose allocator for storing compressed pages.
> +	  It is designed to store up to two compressed pages per physical
> +	  page.  While this design limits storage density, it has simple and
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
> index 0000000..d63ae6e
> --- /dev/null
> +++ b/mm/zbud.c
> @@ -0,0 +1,526 @@
> +/*
> + * zbud.c
> + *
> + * Copyright (C) 2013, Seth Jennings, IBM
> + *
> + * Concepts based on zcache internal zbud allocator by Dan Magenheimer.
> + *
> + * zbud is an special purpose allocator for storing compressed pages.  Contrary
> + * to what its name may suggest, zbud is not a buddy allocator, but rather an
> + * allocator that "buddies" two compressed pages together in a single memory
> + * page.
> + *
> + * While this design limits storage density, it has simple and deterministic
> + * reclaim properties that make it preferable to a higher density approach when
> + * reclaim will be used.
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
> +#define ZHDR_SIZE_ALIGNED CHUNK_SIZE
> +
> +/**
> + * struct zbud_pool - stores metadata for each zbud pool
> + * @lock:	protects all pool fields and first|last_chunk fields of any
> + *		zbud page in the pool
> + * @unbuddied:	array of lists tracking zbud pages that only contain one buddy;
> + *		the lists each zbud page is added to depends on the size of
> + *		its free region.
> + * @buddied:	list tracking the zbud pages that contain two buddies;
> + *		these zbud pages are full
> + * @lru:	list tracking the zbud pages in LRU order by most recently
> + *		added buddy.
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
> +	u64 pages_nr;
> +	struct zbud_ops *ops;
> +};
> +
> +/*
> + * struct zbud_header - zbud page metadata occupying the first chunk of each
> + *			zbud page.
> + * @buddy:	links the zbud page into the unbuddied/buddied lists in the pool
> + * @lru:	links the zbud page into the lru list in the pool
> + * @first_chunks:	the size of the first buddy in chunks, 0 if free
> + * @last_chunks:	the size of the last buddy in chunks, 0 if free

Missing under_reclaim.

> + */
> +struct zbud_header {
> +	struct list_head buddy;
> +	struct list_head lru;
> +	unsigned int first_chunks;
> +	unsigned int last_chunks;
> +	bool under_reclaim;
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
> +static int size_to_chunks(int size)
> +{
> +	return (size + CHUNK_SIZE - 1) >> CHUNK_SHIFT;
> +}
> +
> +#define for_each_unbuddied_list(_iter, _begin) \
> +	for ((_iter) = (_begin); (_iter) < NCHUNKS; (_iter)++)
> +
> +/* Initializes the zbud header of a newly allocated zbud page */
> +static struct zbud_header *init_zbud_page(struct page *page)
> +{
> +	struct zbud_header *zhdr = page_address(page);
> +	zhdr->first_chunks = 0;
> +	zhdr->last_chunks = 0;
> +	INIT_LIST_HEAD(&zhdr->buddy);
> +	INIT_LIST_HEAD(&zhdr->lru);
> +	return zhdr;
> +}
> +
> +/* Resets the struct page fields and frees the page */
> +static void free_zbud_page(struct zbud_header *zhdr)
> +{
> +	__free_page(virt_to_page(zhdr));
> +}
> +
> +/*
> + * Encodes the handle of a particular buddy within a zbud page
> + * Pool lock should be held as this function accesses first|last_chunks
> + */
> +static unsigned long encode_handle(struct zbud_header *zhdr, enum buddy bud)
> +{
> +	unsigned long handle;
> +
> +	/*
> +	 * For now, the encoded handle is actually just the pointer to the data
> +	 * but this might not always be the case.  A little information hiding.
> +	 * Add CHUNK_SIZE to the handle if it is the first allocation to jump
> +	 * over the zbud header in the first chunk.
> +	 */
> +	handle = (unsigned long)zhdr;
> +	if (bud == FIRST)
> +		/* skip over zbud header */
> +		handle += ZHDR_SIZE_ALIGNED;
> +	else /* bud == LAST */
> +		handle += PAGE_SIZE - (zhdr->last_chunks  << CHUNK_SHIFT);
> +	return handle;
> +}
> +
> +/* Returns the zbud page where a given handle is stored */
> +static struct zbud_header *handle_to_zbud_header(unsigned long handle)
> +{
> +	return (struct zbud_header *)(handle & PAGE_MASK);
> +}
> +
> +/* Returns the number of free chunks in a zbud page */
> +static int num_free_chunks(struct zbud_header *zhdr)
> +{
> +	/*
> +	 * Rather than branch for different situations, just use the fact that
> +	 * free buddies have a length of zero to simplify everything. -1 at the
> +	 * end for the zbud header.
> +	 */
> +	return NCHUNKS - zhdr->first_chunks - zhdr->last_chunks - 1;
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
> +	pool->pages_nr = 0;
> +	pool->ops = ops;
> +	return pool;
> +}
> +
> +/**
> + * zbud_destroy_pool() - destroys an existing zbud pool
> + * @pool:	the zbud pool to be destroyed
> + *
> + * The pool should be emptied before this function is called.
> + */
> +void zbud_destroy_pool(struct zbud_pool *pool)
> +{
> +	kfree(pool);
> +}
> +
> +/**
> + * zbud_alloc() - allocates a region of a given size
> + * @pool:	zbud pool from which to allocate
> + * @size:	size in bytes of the desired allocation
> + * @gfp:	gfp flags used if the pool needs to grow
> + * @handle:	handle of the new allocation
> + *
> + * This function will attempt to find a free region in the pool large enough to
> + * satisfy the allocation request.  A search of the unbuddied lists is
> + * performed first. If no suitable free region is found, then a new page is
> + * allocated and added to the pool to satisfy the request.
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
> +	struct zbud_header *zhdr = NULL;
> +	enum buddy bud;
> +	struct page *page;
> +
> +	if (size <= 0 || gfp & __GFP_HIGHMEM)
> +		return -EINVAL;
> +	if (size > PAGE_SIZE - ZHDR_SIZE_ALIGNED)
> +		return -ENOSPC;
> +	chunks = size_to_chunks(size);
> +	spin_lock(&pool->lock);
> +
> +	/* First, try to find an unbuddied zbud page. */
> +	zhdr = NULL;
> +	for_each_unbuddied_list(i, chunks) {
> +		if (!list_empty(&pool->unbuddied[i])) {
> +			zhdr = list_first_entry(&pool->unbuddied[i],
> +					struct zbud_header, buddy);
> +			list_del(&zhdr->buddy);
> +			if (zhdr->first_chunks == 0)
> +				bud = FIRST;
> +			else
> +				bud = LAST;
> +			goto found;
> +		}
> +	}
> +
> +	/* Couldn't find unbuddied zbud page, create new one */

How about moving zswap_is_full() to here.

if (zswap_is_full()) {
	/* Don't alloc any new page, try to reclaim and direct use the
reclaimed page instead */
}

> +	spin_unlock(&pool->lock);
> +	page = alloc_page(gfp);
> +	if (!page)
> +		return -ENOMEM;
> +	spin_lock(&pool->lock);
> +	pool->pages_nr++;
> +	zhdr = init_zbud_page(page);
> +	bud = FIRST;
> +
> +found:
> +	if (bud == FIRST)
> +		zhdr->first_chunks = chunks;
> +	else
> +		zhdr->last_chunks = chunks;
> +
> +	if (zhdr->first_chunks == 0 || zhdr->last_chunks == 0) {
> +		/* Add to unbuddied list */
> +		freechunks = num_free_chunks(zhdr);
> +		list_add(&zhdr->buddy, &pool->unbuddied[freechunks]);
> +	} else {
> +		/* Add to buddied list */
> +		list_add(&zhdr->buddy, &pool->buddied);
> +	}
> +
> +	/* Add/move zbud page to beginning of LRU */
> +	if (!list_empty(&zhdr->lru))
> +		list_del(&zhdr->lru);
> +	list_add(&zhdr->lru, &pool->lru);
> +
> +	*handle = encode_handle(zhdr, bud);
> +	spin_unlock(&pool->lock);
> +
> +	return 0;
> +}
> +

It looks good for me except two things.
One is about what the performance might be after the zswap pool is full.
The other is still about the 20% limit of zswap pool size.
I need more time to test it.

-- 
Regards,
-Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
