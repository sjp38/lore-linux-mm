Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 07F096B0036
	for <linux-mm@kvack.org>; Sat, 13 Apr 2013 20:56:55 -0400 (EDT)
Date: Sun, 14 Apr 2013 01:45:28 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCHv9 7/8] zswap: add swap page writeback support
Message-ID: <20130414004528.GE1330@suse.de>
References: <1365617940-21623-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1365617940-21623-8-git-send-email-sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1365617940-21623-8-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Hugh Dickens <hughd@google.com>, Paul Mackerras <paulus@samba.org>, Heesub Shin <heesub.shin@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On Wed, Apr 10, 2013 at 01:18:59PM -0500, Seth Jennings wrote:
> This patch adds support for evicting swap pages that are currently
> compressed in zswap to the swap device.  This functionality is very
> important and make zswap a true cache in that, once the cache is full
> or can't grow due to memory pressure, the oldest pages can be moved
> out of zswap to the swap device so newer pages can be compressed and
> stored in zswap.
> 

Oh great, this may cover one of my larger objections from an earlier patch!
I had not guessed from the leader mail or the subject that this patch
implemented zswap page aging of some sort.

> This introduces a good amount of new code to guarantee coherency.
> Most notably, and LRU list is added to the zswap_tree structure,
> and refcounts are added to each entry to ensure that one code path
> doesn't free then entry while another code path is operating on it.
> 
> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
> ---
>  mm/zswap.c | 530 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++---
>  1 file changed, 508 insertions(+), 22 deletions(-)
> 
> diff --git a/mm/zswap.c b/mm/zswap.c
> index db283c4..edb354b 100644
> --- a/mm/zswap.c
> +++ b/mm/zswap.c
> @@ -36,6 +36,12 @@
>  #include <linux/mempool.h>
>  #include <linux/zsmalloc.h>
>  
> +#include <linux/mm_types.h>
> +#include <linux/page-flags.h>
> +#include <linux/swapops.h>
> +#include <linux/writeback.h>
> +#include <linux/pagemap.h>
> +
>  /*********************************
>  * statistics
>  **********************************/
> @@ -43,6 +49,8 @@
>  static atomic_t zswap_pool_pages = ATOMIC_INIT(0);
>  /* The number of compressed pages currently stored in zswap */
>  static atomic_t zswap_stored_pages = ATOMIC_INIT(0);
> +/* The number of outstanding pages awaiting writeback */
> +static atomic_t zswap_outstanding_writebacks = ATOMIC_INIT(0);
>  
>  /*
>   * The statistics below are not protected from concurrent access for
> @@ -51,9 +59,13 @@ static atomic_t zswap_stored_pages = ATOMIC_INIT(0);
>   * certain event is occurring.
>  */
>  static u64 zswap_pool_limit_hit;
> +static u64 zswap_written_back_pages;
>  static u64 zswap_reject_compress_poor;
> +static u64 zswap_writeback_attempted;
> +static u64 zswap_reject_tmppage_fail;
>  static u64 zswap_reject_zsmalloc_fail;
>  static u64 zswap_reject_kmemcache_fail;
> +static u64 zswap_saved_by_writeback;
>  static u64 zswap_duplicate_entry;
>  

At some point it would be nice to document what these mean. I know what
they mean now because I read the code recently but I'll have forgotten in
6 months time.

>  /*********************************
> @@ -82,6 +94,14 @@ static unsigned int zswap_max_compression_ratio = 80;
>  module_param_named(max_compression_ratio,
>  			zswap_max_compression_ratio, uint, 0644);
>  
> +/*
> + * Maximum number of outstanding writebacks allowed at any given time.
> + * This is to prevent decompressing an unbounded number of compressed
> + * pages into the swap cache all at once, and to help with writeback
> + * congestion.
> +*/
> +#define ZSWAP_MAX_OUTSTANDING_FLUSHES 64
> +

Why 64?

>  /*********************************
>  * compression functions
>  **********************************/
> @@ -144,18 +164,49 @@ static void zswap_comp_exit(void)
>  /*********************************
>  * data structures
>  **********************************/
> +
> +/*
> + * struct zswap_entry
> + *
> + * This structure contains the metadata for tracking a single compressed
> + * page within zswap.
> + *
> + * rbnode - links the entry into red-black tree for the appropriate swap type
> + * lru - links the entry into the lru list for the appropriate swap type
> + * refcount - the number of outstanding reference to the entry. This is needed
> + *            to protect against premature freeing of the entry by code
> + *            concurent calls to load, invalidate, and writeback.  The lock

s/concurent/concurrent/

> + *            for the zswap_tree structure that contains the entry must
> + *            be held while changing the refcount.  Since the lock must
> + *            be held, there is no reason to also make refcount atomic.
> + * type - the swap type for the entry.  Used to map back to the zswap_tree
> + *        structure that contains the entry.
> + * offset - the swap offset for the entry.  Index into the red-black tree.
> + * handle - zsmalloc allocation handle that stores the compressed page data
> + * length - the length in bytes of the compressed page data.  Needed during
> + *           decompression
> + */

It's good that you document the fields but from a review perspective it
would be easier if the documentation was introduced in an earlier patch
and then update it here. Note for example that you document "type" here
even though this patch removes it.

>  struct zswap_entry {
>  	struct rb_node rbnode;
> -	unsigned type;
> +	struct list_head lru;
> +	int refcount;

Any particular reason you did not use struct kref (include/linux/kref.h)
for the refcount? I suppose it's because your refcount is protected by
the lock and the atomics are unnecessary but it seems unfortunate to
roll your own refcounting unless there is a good reason for it.

There is a place later where the refcount looks like it's used like a
state machine which is a bit weird.

>  	pgoff_t offset;
>  	unsigned long handle;
>  	unsigned int length;
>  };
>  
> +/*
> + * The tree lock in the zswap_tree struct protects a few things:
> + * - the rbtree
> + * - the lru list
> + * - the refcount field of each entry in the tree
> + */
>  struct zswap_tree {
>  	struct rb_root rbroot;
> +	struct list_head lru;
>  	spinlock_t lock;
>  	struct zs_pool *pool;
> +	unsigned type;
>  };
>  
>  static struct zswap_tree *zswap_trees[MAX_SWAPFILES];
> @@ -185,6 +236,8 @@ static inline struct zswap_entry *zswap_entry_cache_alloc(gfp_t gfp)
>  	entry = kmem_cache_alloc(zswap_entry_cache, gfp);
>  	if (!entry)
>  		return NULL;
> +	INIT_LIST_HEAD(&entry->lru);
> +	entry->refcount = 1;
>  	return entry;
>  }
>  
> @@ -193,6 +246,17 @@ static inline void zswap_entry_cache_free(struct zswap_entry *entry)
>  	kmem_cache_free(zswap_entry_cache, entry);
>  }
>  
> +static inline void zswap_entry_get(struct zswap_entry *entry)
> +{
> +	entry->refcount++;
> +}
> +
> +static inline int zswap_entry_put(struct zswap_entry *entry)
> +{
> +	entry->refcount--;
> +	return entry->refcount;
> +}
> +

I find it surprising to have a put-like interface that returns the
count. Ordinarily this would raise alarm bells because a decision could
be made based on a stale read of a refcount. In this case I expect you
are protected  by the tree lock but if you ever want to make that lock
more fine-grained then you are already backed into a corner.

>  /*********************************
>  * rbtree functions
>  **********************************/
> @@ -367,6 +431,328 @@ static struct zs_ops zswap_zs_ops = {
>  	.free = zswap_free_page
>  };
>  
> +
> +/*********************************
> +* helpers
> +**********************************/
> +
> +/*
> + * Carries out the common pattern of freeing and entry's zsmalloc allocation,
> + * freeing the entry itself, and decrementing the number of stored pages.
> + */
> +static void zswap_free_entry(struct zswap_tree *tree, struct zswap_entry *entry)
> +{
> +	zs_free(tree->pool, entry->handle);
> +	zswap_entry_cache_free(entry);
> +	atomic_dec(&zswap_stored_pages);
> +}
> +
> +/*********************************
> +* writeback code
> +**********************************/
> +static void zswap_end_swap_write(struct bio *bio, int err)
> +{
> +	end_swap_bio_write(bio, err);
> +	atomic_dec(&zswap_outstanding_writebacks);
> +	zswap_written_back_pages++;
> +}
> +
> +/* return enum for zswap_get_swap_cache_page */
> +enum zswap_get_swap_ret {
> +	ZSWAP_SWAPCACHE_NEW,
> +	ZSWAP_SWAPCACHE_EXIST,
> +	ZSWAP_SWAPCACHE_NOMEM
> +};
> +
> +/*
> + * zswap_get_swap_cache_page
> + *
> + * This is an adaption of read_swap_cache_async()
> + *

This in fact looks almost identical to read_swap_cache_async(). Can the
code not be reused or the function split up in some fashion to it can be
shared between swap_state.c and zswap.c? As it is, this is just begging
to get out of sync if read_swap_cache_async() ever gets any sort of
enhancement or fix.

> + * This function tries to find a page with the given swap entry
> + * in the swapper_space address space (the swap cache).  If the page
> + * is found, it is returned in retpage.  Otherwise, a page is allocated,
> + * added to the swap cache, and returned in retpage.
> + *
> + * If success, the swap cache page is returned in retpage
> + * Returns 0 if page was already in the swap cache, page is not locked
> + * Returns 1 if the new page needs to be populated, page is locked
> + * Returns <0 on error
> + */
> +static int zswap_get_swap_cache_page(swp_entry_t entry,
> +				struct page **retpage)
> +{
> +	struct page *found_page, *new_page = NULL;
> +	struct address_space *swapper_space = &swapper_spaces[swp_type(entry)];
> +	int err;
> +
> +	*retpage = NULL;
> +	do {
> +		/*
> +		 * First check the swap cache.  Since this is normally
> +		 * called after lookup_swap_cache() failed, re-calling
> +		 * that would confuse statistics.
> +		 */
> +		found_page = find_get_page(swapper_space, entry.val);
> +		if (found_page)
> +			break;
> +
> +		/*
> +		 * Get a new page to read into from swap.
> +		 */
> +		if (!new_page) {
> +			new_page = alloc_page(GFP_KERNEL);
> +			if (!new_page)
> +				break; /* Out of memory */
> +		}
> +
> +		/*
> +		 * call radix_tree_preload() while we can wait.
> +		 */
> +		err = radix_tree_preload(GFP_KERNEL);
> +		if (err)
> +			break;
> +
> +		/*
> +		 * Swap entry may have been freed since our caller observed it.
> +		 */
> +		err = swapcache_prepare(entry);
> +		if (err == -EEXIST) { /* seems racy */
> +			radix_tree_preload_end();
> +			continue;
> +		}
> +		if (err) { /* swp entry is obsolete ? */
> +			radix_tree_preload_end();
> +			break;
> +		}
> +
> +		/* May fail (-ENOMEM) if radix-tree node allocation failed. */
> +		__set_page_locked(new_page);
> +		SetPageSwapBacked(new_page);
> +		err = __add_to_swap_cache(new_page, entry);
> +		if (likely(!err)) {
> +			radix_tree_preload_end();
> +			lru_cache_add_anon(new_page);
> +			*retpage = new_page;
> +			return ZSWAP_SWAPCACHE_NEW;
> +		}
> +		radix_tree_preload_end();
> +		ClearPageSwapBacked(new_page);
> +		__clear_page_locked(new_page);
> +		/*
> +		 * add_to_swap_cache() doesn't return -EEXIST, so we can safely
> +		 * clear SWAP_HAS_CACHE flag.
> +		 */
> +		swapcache_free(entry, NULL);
> +	} while (err != -ENOMEM);
> +
> +	if (new_page)
> +		page_cache_release(new_page);
> +	if (!found_page)
> +		return ZSWAP_SWAPCACHE_NOMEM;
> +	*retpage = found_page;
> +	return ZSWAP_SWAPCACHE_EXIST;
> +}
> +
> +/*
> + * Attempts to free and entry by adding a page to the swap cache,
> + * decompressing the entry data into the page, and issuing a
> + * bio write to write the page back to the swap device.
> + *
> + * This can be thought of as a "resumed writeback" of the page
> + * to the swap device.  We are basically resuming the same swap
> + * writeback path that was intercepted with the frontswap_store()
> + * in the first place.  After the page has been decompressed into
> + * the swap cache, the compressed version stored by zswap can be
> + * freed.
> + */
> +static int zswap_writeback_entry(struct zswap_tree *tree,
> +				struct zswap_entry *entry)
> +{
> +	unsigned long type = tree->type;
> +	struct page *page;
> +	swp_entry_t swpentry;
> +	u8 *src, *dst;
> +	unsigned int dlen;
> +	int ret;
> +	struct writeback_control wbc = {
> +		.sync_mode = WB_SYNC_NONE,
> +	};
> +
> +	/* get/allocate page in the swap cache */
> +	swpentry = swp_entry(type, entry->offset);
> +
> +	/* try to allocate swap cache page */
> +	switch (zswap_get_swap_cache_page(swpentry, &page)) {
> +
> +	case ZSWAP_SWAPCACHE_NOMEM: /* no memory */
> +		return -ENOMEM;
> +		break; /* not reached */
> +

Can leave out the break

> +	case ZSWAP_SWAPCACHE_EXIST: /* page is unlocked */
> +		/* page is already in the swap cache, ignore for now */
> +		return -EEXIST;
> +		break; /* not reached */
> +

Can leave out the break.

> +	case ZSWAP_SWAPCACHE_NEW: /* page is locked */
> +		/* decompress */
> +		dlen = PAGE_SIZE;
> +		src = zs_map_object(tree->pool, entry->handle, ZS_MM_RO);
> +		dst = kmap_atomic(page);
> +		ret = zswap_comp_op(ZSWAP_COMPOP_DECOMPRESS, src, entry->length,
> +				dst, &dlen);
> +		kunmap_atomic(dst);
> +		zs_unmap_object(tree->pool, entry->handle);
> +		BUG_ON(ret);
> +		BUG_ON(dlen != PAGE_SIZE);
> +
> +		/* page is up to date */
> +		SetPageUptodate(page);
> +	}
> +
> +	/* start writeback */
> +	SetPageReclaim(page);
> +	if (!__swap_writepage(page, &wbc, zswap_end_swap_write))
> +		atomic_inc(&zswap_outstanding_writebacks);

humm, you queue something and then increment the writebacks. That looks
like it would be vulnerable to a race of

1. 10 processes read counter see it's ZSWAP_MAX_OUTSTANDING_FLUSHES-1
2. 10 processes queue IO
3. 10 processes increment the counter

We've now gone over the max number of outstanding flushes. It still
sortof gets limited but it's still a bit sloppy.

> +	page_cache_release(page);
> +
> +	return 0;
> +}
> +
> +/*
> + * Attempts to free nr of entries via writeback to the swap device.
> + * The number of entries that were actually freed is returned.
> + */
> +static int zswap_writeback_entries(struct zswap_tree *tree, int nr)
> +{
> +	struct zswap_entry *entry;
> +	int i, ret, refcount, freed_nr = 0;
> +
> +	for (i = 0; i < nr; i++) {
> +		/*
> +		 * This limits is arbitrary for now until a better
> +		 * policy can be implemented. This is so we don't
> +		 * eat all of RAM decompressing pages for writeback.
> +		 */
> +		if (atomic_read(&zswap_outstanding_writebacks) >
> +				ZSWAP_MAX_OUTSTANDING_FLUSHES)
> +			break;
> +

This is handled a bit badly. If the max outstanding flushes are reached at
i == 0 then we return. The caller does not check the return value and if
it fails the zsmalloc again then it just fails to store the page entirely.
This means that when the maximum allowed number of pages are in flight that
new pages go straight to swap and it's again an age inversion problem. The
performance cliff when zswap full is still there although it may be harder
to hit.

You need to go on a waitqueue here until the in-flight pages are written
and it gets woken up. You will likely need to make sure it can make forward
progress even if it's crude as just sleeping here until it's woken and
returning. If it fails still then zswap writeback is congested and it
might as well just go straight to swap and take the age inversion hit.

> +		spin_lock(&tree->lock);
> +
> +		/* dequeue from lru */
> +		if (list_empty(&tree->lru)) {
> +			spin_unlock(&tree->lock);
> +			break;
> +		}
> +		entry = list_first_entry(&tree->lru,
> +				struct zswap_entry, lru);
> +		list_del_init(&entry->lru);
> +
> +		/* so invalidate doesn't free the entry from under us */
> +		zswap_entry_get(entry);
> +
> +		spin_unlock(&tree->lock);
> +
> +		/* attempt writeback */
> +		ret = zswap_writeback_entry(tree, entry);
> +
> +		spin_lock(&tree->lock);
> +
> +		/* drop reference from above */
> +		refcount = zswap_entry_put(entry);
> +
> +		if (!ret)
> +			/* drop the initial reference from entry creation */
> +			refcount = zswap_entry_put(entry);
> +

zswap_writeback_entry returns an enum but here you make assumptions on
the meaning of 0. While it's correct, it's vulnerable to bugs if someone
adds a new enum state at position 0. Compare ret to ZSWAP_SWAPCACHE_NEW.

> +		/*
> +		 * There are four possible values for refcount here:
> +		 * (1) refcount is 2, writeback failed and load is in progress;
> +		 *     do nothing, load will add us back to the LRU
> +		 * (2) refcount is 1, writeback failed; do not free entry,
> +		 *     add back to LRU
> +		 * (3) refcount is 0, (normal case) not invalidate yet;
> +		 *     remove from rbtree and free entry
> +		 * (4) refcount is -1, invalidate happened during writeback;
> +		 *     free entry
> +		 */
> +		if (refcount == 1)
> +			list_add(&entry->lru, &tree->lru);
> +
> +		if (refcount == 0) {
> +			/* no invalidate yet, remove from rbtree */
> +			rb_erase(&entry->rbnode, &tree->rbroot);
> +		}
> +		spin_unlock(&tree->lock);
> +		if (refcount <= 0) {
> +			/* free the entry */
> +			zswap_free_entry(tree, entry);
> +			freed_nr++;
> +		}
> +	}
> +	return freed_nr;
> +}
> +
> +/*******************************************
> +* page pool for temporary compression result
> +********************************************/
> +#define ZSWAP_TMPPAGE_POOL_PAGES 16

It's strange to me that the number of pages queued in a writeback at the
same time, the size of the the tmp page pool and the maximum allowed number
of pages under writeback are independent. It seems like it should be

MAX_FLUSHES		64
WRITEBACK_BATCH		(MAX_FLUSHES >> 2)
TMPPAGE_PAGES		MAX_FLUSHES / WRITEBACK_BATCH

or something similar. 

> +static LIST_HEAD(zswap_tmppage_list);
> +static DEFINE_SPINLOCK(zswap_tmppage_lock);
> +
> +static void zswap_tmppage_pool_destroy(void)
> +{
> +	struct page *page, *tmppage;
> +
> +	spin_lock(&zswap_tmppage_lock);
> +	list_for_each_entry_safe(page, tmppage, &zswap_tmppage_list, lru) {
> +		list_del(&page->lru);
> +		__free_pages(page, 1);
> +	}
> +	spin_unlock(&zswap_tmppage_lock);
> +}

This looks very like a mempool but is a custom implementation. It could
have been a kref-counted pool size with an alloc function that returns
NULL if kref == ZSWAP_TMPPAGE_POOL_PAGES. Granted, that would introduce
atomics into this path but the use of a custom mempool here does not appear
justified. Any particular reason a mempool was avoided?

> +
> +static int zswap_tmppage_pool_create(void)
> +{
> +	int i;
> +	struct page *page;
> +
> +	for (i = 0; i < ZSWAP_TMPPAGE_POOL_PAGES; i++) {
> +		page = alloc_pages(GFP_KERNEL, 1);

The per-cpu compression/decompression buffers are allocated from kmalloc
as kmalloc(PAGE_SIZE*2) but here we allocate an order-1 page.  Functionally
there is no difference but it seems like the order of the buffer be #defined
somewhere and them allocated with one interface or the other, not a mix.

> +		if (!page) {
> +			zswap_tmppage_pool_destroy();
> +			return -ENOMEM;
> +		}
> +		spin_lock(&zswap_tmppage_lock);
> +		list_add(&page->lru, &zswap_tmppage_list);
> +		spin_unlock(&zswap_tmppage_lock);
> +	}
> +	return 0;
> +}
> +
> +static inline struct page *zswap_tmppage_alloc(void)
> +{
> +	struct page *page;
> +
> +	spin_lock(&zswap_tmppage_lock);
> +	if (list_empty(&zswap_tmppage_list)) {
> +		spin_unlock(&zswap_tmppage_lock);
> +		return NULL;
> +	}
> +	page = list_first_entry(&zswap_tmppage_list, struct page, lru);
> +	list_del(&page->lru);
> +	spin_unlock(&zswap_tmppage_lock);
> +	return page;
> +}
> +
> +static inline void zswap_tmppage_free(struct page *page)
> +{
> +	spin_lock(&zswap_tmppage_lock);
> +	list_add(&page->lru, &zswap_tmppage_list);
> +	spin_unlock(&zswap_tmppage_lock);
> +}
> +
>  /*********************************
>  * frontswap hooks
>  **********************************/
> @@ -380,7 +766,9 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
>  	unsigned int dlen = PAGE_SIZE;
>  	unsigned long handle;
>  	char *buf;
> -	u8 *src, *dst;
> +	u8 *src, *dst, *tmpdst;
> +	struct page *tmppage;
> +	bool writeback_attempted = 0;

bool = false.

>  
>  	if (!tree) {
>  		ret = -ENODEV;
> @@ -402,12 +790,12 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
>  	kunmap_atomic(src);
>  	if (ret) {
>  		ret = -EINVAL;
> -		goto putcpu;
> +		goto freepage;
>  	}
>  	if ((dlen * 100 / PAGE_SIZE) > zswap_max_compression_ratio) {
>  		zswap_reject_compress_poor++;
>  		ret = -E2BIG;
> -		goto putcpu;
> +		goto freepage;
>  	}
>  
>  	/* store */
> @@ -415,18 +803,48 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
>  		__GFP_NORETRY | __GFP_HIGHMEM | __GFP_NOMEMALLOC |
>  			__GFP_NOWARN);
>  	if (!handle) {
> -		zswap_reject_zsmalloc_fail++;
> -		ret = -ENOMEM;
> -		goto putcpu;
> +		zswap_writeback_attempted++;
> +		/*
> +		 * Copy compressed buffer out of per-cpu storage so
> +		 * we can re-enable preemption.
> +		*/
> +		tmppage = zswap_tmppage_alloc();
> +		if (!tmppage) {
> +			zswap_reject_tmppage_fail++;
> +			ret = -ENOMEM;
> +			goto freepage;
> +		}

Similar to ZSWAP_MAX_OUTSTANDING_FLUSHES, a failure to allocate a tmppage
should result in the process waiting or it's back again to the age
inversion problem.

> +		writeback_attempted = 1;
> +		tmpdst = page_address(tmppage);
> +		memcpy(tmpdst, dst, dlen);
> +		dst = tmpdst;
> +		put_cpu_var(zswap_dstmem);
> +
> +		/* try to free up some space */
> +		/* TODO: replace with more targeted policy */
> +		zswap_writeback_entries(tree, 16);
> +		/* try again, allowing wait */
> +		handle = zs_malloc(tree->pool, dlen,
> +			__GFP_NORETRY | __GFP_HIGHMEM | __GFP_NOMEMALLOC |
> +				__GFP_NOWARN);
> +		if (!handle) {
> +			/* still no space, fail */
> +			zswap_reject_zsmalloc_fail++;
> +			ret = -ENOMEM;
> +			goto freepage;
> +		}
> +		zswap_saved_by_writeback++;
>  	}
>  
>  	buf = zs_map_object(tree->pool, handle, ZS_MM_WO);
>  	memcpy(buf, dst, dlen);
>  	zs_unmap_object(tree->pool, handle);
> -	put_cpu_var(zswap_dstmem);
> +	if (writeback_attempted)
> +		zswap_tmppage_free(tmppage);
> +	else
> +		put_cpu_var(zswap_dstmem);
>  
>  	/* populate entry */
> -	entry->type = type;
>  	entry->offset = offset;
>  	entry->handle = handle;
>  	entry->length = dlen;
> @@ -437,16 +855,17 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
>  		ret = zswap_rb_insert(&tree->rbroot, entry, &dupentry);
>  		if (ret == -EEXIST) {
>  			zswap_duplicate_entry++;
> -
> -			/* remove from rbtree */
> +			/* remove from rbtree and lru */
>  			rb_erase(&dupentry->rbnode, &tree->rbroot);
> -
> -			/* free */
> -			zs_free(tree->pool, dupentry->handle);
> -			zswap_entry_cache_free(dupentry);
> -			atomic_dec(&zswap_stored_pages);
> +			if (!list_empty(&dupentry->lru))
> +				list_del_init(&dupentry->lru);
> +			if (!zswap_entry_put(dupentry)) {
> +				/* free */
> +				zswap_free_entry(tree, dupentry);
> +			}
>  		}
>  	} while (ret == -EEXIST);
> +	list_add_tail(&entry->lru, &tree->lru);
>  	spin_unlock(&tree->lock);
>  
>  	/* update stats */
> @@ -454,8 +873,11 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
>  
>  	return 0;
>  
> -putcpu:
> -	put_cpu_var(zswap_dstmem);
> +freepage:
> +	if (writeback_attempted)
> +		zswap_tmppage_free(tmppage);
> +	else
> +		put_cpu_var(zswap_dstmem);
>  	zswap_entry_cache_free(entry);
>  reject:
>  	return ret;
> @@ -472,10 +894,21 @@ static int zswap_frontswap_load(unsigned type, pgoff_t offset,
>  	struct zswap_entry *entry;
>  	u8 *src, *dst;
>  	unsigned int dlen;
> +	int refcount;
>  
>  	/* find */
>  	spin_lock(&tree->lock);
>  	entry = zswap_rb_search(&tree->rbroot, offset);
> +	if (!entry) {
> +		/* entry was written back */
> +		spin_unlock(&tree->lock);
> +		return -1;
> +	}
> +	zswap_entry_get(entry);
> +
> +	/* remove from lru */
> +	if (!list_empty(&entry->lru))
> +		list_del_init(&entry->lru);
>  	spin_unlock(&tree->lock);
>  
>  	/* decompress */
> @@ -487,6 +920,24 @@ static int zswap_frontswap_load(unsigned type, pgoff_t offset,
>  	kunmap_atomic(dst);
>  	zs_unmap_object(tree->pool, entry->handle);
>  
> +	spin_lock(&tree->lock);
> +	refcount = zswap_entry_put(entry);
> +	if (likely(refcount)) {
> +		list_add_tail(&entry->lru, &tree->lru);
> +		spin_unlock(&tree->lock);
> +		return 0;
> +	}
> +	spin_unlock(&tree->lock);
> +
> +	/*
> +	 * We don't have to unlink from the rbtree because
> +	 * zswap_writeback_entry() or zswap_frontswap_invalidate page()
> +	 * has already done this for us if we are the last reference.
> +	 */
> +	/* free */
> +
> +	zswap_free_entry(tree, entry);
> +
>  	return 0;
>  }
>  
> @@ -495,19 +946,34 @@ static void zswap_frontswap_invalidate_page(unsigned type, pgoff_t offset)
>  {
>  	struct zswap_tree *tree = zswap_trees[type];
>  	struct zswap_entry *entry;
> +	int refcount;
>  
>  	/* find */
>  	spin_lock(&tree->lock);
>  	entry = zswap_rb_search(&tree->rbroot, offset);
> +	if (!entry) {
> +		/* entry was written back */
> +		spin_unlock(&tree->lock);
> +		return;
> +	}
>  
> -	/* remove from rbtree */
> +	/* remove from rbtree and lru */
>  	rb_erase(&entry->rbnode, &tree->rbroot);
> +	if (!list_empty(&entry->lru))
> +		list_del_init(&entry->lru);
> +
> +	/* drop the initial reference from entry creation */
> +	refcount = zswap_entry_put(entry);
> +
>  	spin_unlock(&tree->lock);
>  
> +	if (refcount) {
> +		/* writeback in progress, writeback will free */
> +		return;
> +	}
> +

I'm not keen on a refcount check, lock drop and then action based on
the stale read even though I do not see it causing a problem here as
such. Still, if at all possible I'd prefer to see the usual pattern of an
atomic_sub_and_test calling a release function like what kref_sub does to
avoid any potential problems with stale refcount checks in the future.


>  	/* free */
> -	zs_free(tree->pool, entry->handle);
> -	zswap_entry_cache_free(entry);
> -	atomic_dec(&zswap_stored_pages);
> +	zswap_free_entry(tree, entry);
>  }
>  
>  /* invalidates all pages for the given swap type */
> @@ -536,8 +1002,10 @@ static void zswap_frontswap_invalidate_area(unsigned type)
>  		rb_erase(&entry->rbnode, &tree->rbroot);
>  		zs_free(tree->pool, entry->handle);
>  		zswap_entry_cache_free(entry);
> +		atomic_dec(&zswap_stored_pages);
>  	}
>  	tree->rbroot = RB_ROOT;
> +	INIT_LIST_HEAD(&tree->lru);
>  	spin_unlock(&tree->lock);
>  }
>  
> @@ -553,7 +1021,9 @@ static void zswap_frontswap_init(unsigned type)
>  	if (!tree->pool)
>  		goto freetree;
>  	tree->rbroot = RB_ROOT;
> +	INIT_LIST_HEAD(&tree->lru);
>  	spin_lock_init(&tree->lock);
> +	tree->type = type;
>  	zswap_trees[type] = tree;
>  	return;
>  
> @@ -588,20 +1058,30 @@ static int __init zswap_debugfs_init(void)
>  	if (!zswap_debugfs_root)
>  		return -ENOMEM;
>  
> +	debugfs_create_u64("saved_by_writeback", S_IRUGO,
> +			zswap_debugfs_root, &zswap_saved_by_writeback);
>  	debugfs_create_u64("pool_limit_hit", S_IRUGO,
>  			zswap_debugfs_root, &zswap_pool_limit_hit);
> +	debugfs_create_u64("reject_writeback_attempted", S_IRUGO,
> +			zswap_debugfs_root, &zswap_writeback_attempted);
> +	debugfs_create_u64("reject_tmppage_fail", S_IRUGO,
> +			zswap_debugfs_root, &zswap_reject_tmppage_fail);
>  	debugfs_create_u64("reject_zsmalloc_fail", S_IRUGO,
>  			zswap_debugfs_root, &zswap_reject_zsmalloc_fail);
>  	debugfs_create_u64("reject_kmemcache_fail", S_IRUGO,
>  			zswap_debugfs_root, &zswap_reject_kmemcache_fail);
>  	debugfs_create_u64("reject_compress_poor", S_IRUGO,
>  			zswap_debugfs_root, &zswap_reject_compress_poor);
> +	debugfs_create_u64("written_back_pages", S_IRUGO,
> +			zswap_debugfs_root, &zswap_written_back_pages);
>  	debugfs_create_u64("duplicate_entry", S_IRUGO,
>  			zswap_debugfs_root, &zswap_duplicate_entry);
>  	debugfs_create_atomic_t("pool_pages", S_IRUGO,
>  			zswap_debugfs_root, &zswap_pool_pages);
>  	debugfs_create_atomic_t("stored_pages", S_IRUGO,
>  			zswap_debugfs_root, &zswap_stored_pages);
> +	debugfs_create_atomic_t("outstanding_writebacks", S_IRUGO,
> +			zswap_debugfs_root, &zswap_outstanding_writebacks);
>  
>  	return 0;
>  }
> @@ -636,6 +1116,10 @@ static int __init init_zswap(void)
>  		pr_err("page pool initialization failed\n");
>  		goto pagepoolfail;
>  	}
> +	if (zswap_tmppage_pool_create()) {
> +		pr_err("workmem pool initialization failed\n");
> +		goto tmppoolfail;
> +	}
>  	if (zswap_comp_init()) {
>  		pr_err("compressor initialization failed\n");
>  		goto compfail;
> @@ -651,6 +1135,8 @@ static int __init init_zswap(void)
>  pcpufail:
>  	zswap_comp_exit();
>  compfail:
> +	zswap_tmppage_pool_destroy();
> +tmppoolfail:
>  	zswap_page_pool_destroy();
>  pagepoolfail:
>  	zswap_entry_cache_destory();

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
