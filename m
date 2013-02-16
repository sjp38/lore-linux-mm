Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 56C686B00AB
	for <linux-mm@kvack.org>; Sat, 16 Feb 2013 01:12:17 -0500 (EST)
Received: by mail-gh0-f180.google.com with SMTP id f13so258531ghb.11
        for <linux-mm@kvack.org>; Fri, 15 Feb 2013 22:12:16 -0800 (PST)
Message-ID: <511F22FB.4010607@gmail.com>
Date: Sat, 16 Feb 2013 14:11:07 +0800
From: Ric Mason <ric.masonn@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCHv5 7/8] zswap: add swap page writeback support
References: <1360780731-11708-1-git-send-email-sjenning@linux.vnet.ibm.com> <1360780731-11708-8-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1360780731-11708-8-git-send-email-sjenning@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Joe Perches <joe@perches.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On 02/14/2013 02:38 AM, Seth Jennings wrote:
> This patch adds support for evicting swap pages that are currently
> compressed in zswap to the swap device.  This functionality is very
> important and make zswap a true cache in that, once the cache is full
> or can't grow due to memory pressure, the oldest pages can be moved
> out of zswap to the swap device so newer pages can be compressed and
> stored in zswap.
>
> This introduces a good amount of new code to guarantee coherency.
> Most notably, and LRU list is added to the zswap_tree structure,
> and refcounts are added to each entry to ensure that one code path
> doesn't free then entry while another code path is operating on it.
>
> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
> ---
>   mm/zswap.c |  530 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++---
>   1 file changed, 510 insertions(+), 20 deletions(-)
>
> diff --git a/mm/zswap.c b/mm/zswap.c
> index e77ab2f..6478262 100644
> --- a/mm/zswap.c
> +++ b/mm/zswap.c
> @@ -36,6 +36,12 @@
>   #include <linux/mempool.h>
>   #include <linux/zsmalloc.h>
>   
> +#include <linux/mm_types.h>
> +#include <linux/page-flags.h>
> +#include <linux/swapops.h>
> +#include <linux/writeback.h>
> +#include <linux/pagemap.h>
> +
>   /*********************************
>   * statistics
>   **********************************/
> @@ -43,6 +49,8 @@
>   static atomic_t zswap_pool_pages = ATOMIC_INIT(0);
>   /* The number of compressed pages currently stored in zswap */
>   static atomic_t zswap_stored_pages = ATOMIC_INIT(0);
> +/* The number of outstanding pages awaiting writeback */
> +static atomic_t zswap_outstanding_writebacks = ATOMIC_INIT(0);
>   
>   /*
>    * The statistics below are not protected from concurrent access for
> @@ -51,9 +59,13 @@ static atomic_t zswap_stored_pages = ATOMIC_INIT(0);
>    * certain event is occurring.
>   */
>   static u64 zswap_pool_limit_hit;
> +static u64 zswap_written_back_pages;
>   static u64 zswap_reject_compress_poor;
> +static u64 zswap_writeback_attempted;
> +static u64 zswap_reject_tmppage_fail;
>   static u64 zswap_reject_zsmalloc_fail;
>   static u64 zswap_reject_kmemcache_fail;
> +static u64 zswap_saved_by_writeback;
>   static u64 zswap_duplicate_entry;
>   
>   /*********************************
> @@ -82,6 +94,14 @@ static unsigned int zswap_max_compression_ratio = 80;
>   module_param_named(max_compression_ratio,
>   			zswap_max_compression_ratio, uint, 0644);
>   
> +/*
> + * Maximum number of outstanding writebacks allowed at any given time.
> + * This is to prevent decompressing an unbounded number of compressed
> + * pages into the swap cache all at once, and to help with writeback
> + * congestion.
> +*/
> +#define ZSWAP_MAX_OUTSTANDING_FLUSHES 64
> +
>   /*********************************
>   * compression functions
>   **********************************/
> @@ -144,16 +164,47 @@ static void zswap_comp_exit(void)
>   /*********************************
>   * data structures
>   **********************************/
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
> + *            for the zswap_tree structure that contains the entry must
> + *            be held while changing the refcount.  Since the lock must
> + *            be held, there is no reason to also make refcount atomic.
> + * type - the swap type for the entry.  Used to map back to the zswap_tree
> + *        structure that contains the entry.
> + * offset - the swap offset for the entry.  Index into the red-black tree.
> + * handle - zsmalloc allocation handle that stores the compressed page data
> + * length - the length in bytes of the compressed page data.  Needed during
> +            decompression
> + */
>   struct zswap_entry {
>   	struct rb_node rbnode;
> +	struct list_head lru;
> +	int refcount;
>   	unsigned type;
>   	pgoff_t offset;
>   	unsigned long handle;
>   	unsigned int length;
>   };
>   
> +/*
> + * The tree lock in the zswap_tree struct protects a few things:
> + * - the rbtree
> + * - the lru list
> + * - the refcount field of each entry in the tree
> + */
>   struct zswap_tree {
>   	struct rb_root rbroot;
> +	struct list_head lru;
>   	spinlock_t lock;
>   	struct zs_pool *pool;
>   };
> @@ -185,6 +236,8 @@ static inline struct zswap_entry *zswap_entry_cache_alloc(gfp_t gfp)
>   	entry = kmem_cache_alloc(zswap_entry_cache, gfp);
>   	if (!entry)
>   		return NULL;
> +	INIT_LIST_HEAD(&entry->lru);
> +	entry->refcount = 1;
>   	return entry;
>   }
>   
> @@ -193,6 +246,17 @@ static inline void zswap_entry_cache_free(struct zswap_entry *entry)
>   	kmem_cache_free(zswap_entry_cache, entry);
>   }
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
>   /*********************************
>   * rbtree functions
>   **********************************/
> @@ -367,6 +431,333 @@ static struct zs_ops zswap_zs_ops = {
>   	.free = zswap_free_page
>   };
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
> +	int err;
> +
> +	*retpage = NULL;
> +	do {
> +		/*
> +		 * First check the swap cache.  Since this is normally
> +		 * called after lookup_swap_cache() failed, re-calling
> +		 * that would confuse statistics.
> +		 */
> +		found_page = find_get_page(&swapper_space, entry.val);
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
> +static int zswap_writeback_entry(struct zswap_entry *entry)
> +{
> +	unsigned long type = entry->type;
> +	struct zswap_tree *tree = zswap_trees[type];
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
> +	case ZSWAP_SWAPCACHE_EXIST: /* page is unlocked */
> +		/* page is already in the swap cache, ignore for now */
> +		return -EEXIST;
> +		break; /* not reached */
> +
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
> +	/*
> +	 * Return value is ignored here because it doesn't change anything
> +	 * for us.  Page is returned unlocked.
> +	 */
> +	(void)__swap_writepage(page, &wbc, zswap_end_swap_write);
> +	page_cache_release(page);
> +	atomic_inc(&zswap_outstanding_writebacks);
> +
> +	return 0;
> +}
> +
> +/*
> + * Attempts to free nr of entries via writeback to the swap device.
> + * The number of entries that were actually freed is returned.
> + */
> +static int zswap_writeback_entries(unsigned type, int nr)
> +{
> +	struct zswap_tree *tree = zswap_trees[type];
> +	struct zswap_entry *entry;
> +	int i, ret, refcount, freed_nr = 0;
> +
> +	/*
> +	 * This limits is arbitrary for now until a better
> +	 * policy can be implemented. This is so we don't
> +	 * eat all of RAM decompressing pages for writeback.
> +	 */
> +	if (atomic_read(&zswap_outstanding_writebacks) >
> +		ZSWAP_MAX_OUTSTANDING_FLUSHES)
> +		return 0;
> +
> +	for (i = 0; i < nr; i++) {
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
> +		ret = zswap_writeback_entry(entry);
> +
> +		spin_lock(&tree->lock);
> +
> +		/* drop reference from above */
> +		refcount = zswap_entry_put(entry);
> +
> +		if (!ret)
> +			 /* drop the initial reference from entry creation */
> +			refcount = zswap_entry_put(entry);
> +
> +		/*
> +		 * There are three possible values for refcount here:
> +		 * (1) refcount is 1, load is in progress or writeback failed;
> +		 *     do not free entry, add back to LRU
> +		 * (2) refcount is 0, (usual case) not invalidate yet;
> +		 *     free entry
> +		 * (3) refcount is -1, invalidate happened during writeback;
> +		 *     free entry
> +		 */
> +		if (refcount > 0)
> +			list_add(&entry->lru, &tree->lru);
> +		spin_unlock(&tree->lock);
> +
> +		if (refcount <= 0) {
> +			/* free the entry */
> +			if (refcount == 0)
> +				/* no invalidate yet, remove from rbtree */
> +				rb_erase(&entry->rbnode, &tree->rbroot);
> +			zswap_free_entry(tree, entry);
> +			freed_nr++;
> +		}
> +			
> +		if (atomic_read(&zswap_outstanding_writebacks) >
> +			ZSWAP_MAX_OUTSTANDING_FLUSHES)
> +			break;
> +	}
> +	return freed_nr++;
> +}
> +
> +/*******************************************
> +* page pool for temporary compression result
> +********************************************/
> +#define ZSWAP_TMPPAGE_POOL_PAGES 16

Why not the number of online cpu?

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
> +
> +static int zswap_tmppage_pool_create(void)
> +{
> +	int i;
> +	struct page *page;
> +
> +	for (i = 0; i < ZSWAP_TMPPAGE_POOL_PAGES; i++) {
> +		page = alloc_pages(GFP_KERNEL, 1);
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
>   /*********************************
>   * frontswap hooks
>   **********************************/
> @@ -380,7 +771,9 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
>   	unsigned int dlen = PAGE_SIZE;
>   	unsigned long handle;
>   	char *buf;
> -	u8 *src, *dst;
> +	u8 *src, *dst, *tmpdst;
> +	struct page *tmppage;
> +	bool writeback_attempted = 0;
>   
>   	if (!tree) {
>   		ret = -ENODEV;
> @@ -394,12 +787,12 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
>   	kunmap_atomic(src);
>   	if (ret) {
>   		ret = -EINVAL;
> -		goto putcpu;
> +		goto freepage;
>   	}
>   	if ((dlen * 100 / PAGE_SIZE) > zswap_max_compression_ratio) {
>   		zswap_reject_compress_poor++;
>   		ret = -E2BIG;
> -		goto putcpu;
> +		goto freepage;
>   	}
>   
>   	/* store */
> @@ -407,15 +800,46 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
>   		__GFP_NORETRY | __GFP_HIGHMEM | __GFP_NOMEMALLOC |
>   			__GFP_NOWARN);
>   	if (!handle) {
> -		zswap_reject_zsmalloc_fail++;
> -		ret = -ENOMEM;
> -		goto putcpu;
> +		zswap_writeback_attempted++;
> +		/*
> +		 * Copy compressed buffer out of per-cpu storage so
> +		 * we can re-enable preemption.
> +		*/

Why re-enable preemption is very important?

> +		tmppage = zswap_tmppage_alloc();
> +		if (!tmppage) {
> +			zswap_reject_tmppage_fail++;
> +			ret = -ENOMEM;
> +			goto freepage;
> +		}
> +		writeback_attempted = 1;
> +		tmpdst = page_address(tmppage);
> +		memcpy(tmpdst, dst, dlen);
> +		dst = tmpdst;
> +		put_cpu_var(zswap_dstmem);
> +
> +		/* try to free up some space */
> +		/* TODO: replace with more targeted policy */
> +		zswap_writeback_entries(type, 16);
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
>   	}
>   
>   	buf = zs_map_object(tree->pool, handle, ZS_MM_WO);
>   	memcpy(buf, dst, dlen);
>   	zs_unmap_object(tree->pool, handle);
> -	put_cpu_var(zswap_dstmem);
> +	if (writeback_attempted)
> +		zswap_tmppage_free(tmppage);
> +	else
> +		put_cpu_var(zswap_dstmem);
>   
>   	/* allocate entry */
>   	entry = zswap_entry_cache_alloc(GFP_KERNEL);
> @@ -438,16 +862,17 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
>   		ret = zswap_rb_insert(&tree->rbroot, entry, &dupentry);
>   		if (ret == -EEXIST) {
>   			zswap_duplicate_entry++;
> -
> -			/* remove from rbtree */
> +			/* remove from rbtree and lru */
>   			rb_erase(&dupentry->rbnode, &tree->rbroot);
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
>   		}
>   	} while (ret == -EEXIST);
> +	list_add_tail(&entry->lru, &tree->lru);
>   	spin_unlock(&tree->lock);
>   
>   	/* update stats */
> @@ -455,8 +880,11 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
>   
>   	return 0;
>   
> -putcpu:
> -	put_cpu_var(zswap_dstmem);
> +freepage:
> +	if (writeback_attempted)
> +		zswap_tmppage_free(tmppage);
> +	else
> +		put_cpu_var(zswap_dstmem);
>   reject:
>   	return ret;
>   }
> @@ -472,10 +900,21 @@ static int zswap_frontswap_load(unsigned type, pgoff_t offset,
>   	struct zswap_entry *entry;
>   	u8 *src, *dst;
>   	unsigned int dlen;
> +	int refcount;
>   
>   	/* find */
>   	spin_lock(&tree->lock);
>   	entry = zswap_rb_search(&tree->rbroot, offset);
> +	if (!entry) {
> +		/* entry was written_back */
> +		spin_unlock(&tree->lock);
> +		return -1;
> +	}
> +	zswap_entry_get(entry);
> +
> +	/* remove from lru */
> +	if (!list_empty(&entry->lru))
> +		list_del_init(&entry->lru);
>   	spin_unlock(&tree->lock);
>   
>   	/* decompress */
> @@ -487,6 +926,24 @@ static int zswap_frontswap_load(unsigned type, pgoff_t offset,
>   	kunmap_atomic(dst);
>   	zs_unmap_object(tree->pool, entry->handle);
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
>   	return 0;
>   }
>   
> @@ -495,19 +952,34 @@ static void zswap_frontswap_invalidate_page(unsigned type, pgoff_t offset)
>   {
>   	struct zswap_tree *tree = zswap_trees[type];
>   	struct zswap_entry *entry;
> +	int refcount;
>   
>   	/* find */
>   	spin_lock(&tree->lock);
>   	entry = zswap_rb_search(&tree->rbroot, offset);
> +	if (!entry) {
> +		/* entry was written back */
> +		spin_unlock(&tree->lock);
> +		return;
> +	}
>   
> -	/* remove from rbtree */
> +	/* remove from rbtree and lru */
>   	rb_erase(&entry->rbnode, &tree->rbroot);
> +	if (!list_empty(&entry->lru))
> +		list_del_init(&entry->lru);
> +
> +	/* drop the initial reference from entry creation */
> +	refcount = zswap_entry_put(entry);
> +
>   	spin_unlock(&tree->lock);
>   
> +	if (refcount) {
> +		/* writeback in progress, writeback will free */
> +		return;
> +	}
> +
>   	/* free */
> -	zs_free(tree->pool, entry->handle);
> -	zswap_entry_cache_free(entry);
> -	atomic_dec(&zswap_stored_pages);
> +	zswap_free_entry(tree, entry);
>   }
>   
>   /* invalidates all pages for the given swap type */
> @@ -531,6 +1003,7 @@ static void zswap_frontswap_invalidate_area(unsigned type)
>   		node = next;
>   	}
>   	tree->rbroot = RB_ROOT;
> +	INIT_LIST_HEAD(&tree->lru);
>   	spin_unlock(&tree->lock);
>   }
>   
> @@ -546,6 +1019,7 @@ static void zswap_frontswap_init(unsigned type)
>   	if (!tree->pool)
>   		goto freetree;
>   	tree->rbroot = RB_ROOT;
> +	INIT_LIST_HEAD(&tree->lru);
>   	spin_lock_init(&tree->lock);
>   	zswap_trees[type] = tree;
>   	return;
> @@ -581,20 +1055,30 @@ static int __init zswap_debugfs_init(void)
>   	if (!zswap_debugfs_root)
>   		return -ENOMEM;
>   
> +	debugfs_create_u64("saved_by_writeback", S_IRUGO,
> +			zswap_debugfs_root, &zswap_saved_by_writeback);
>   	debugfs_create_u64("pool_limit_hit", S_IRUGO,
>   			zswap_debugfs_root, &zswap_pool_limit_hit);
> +	debugfs_create_u64("reject_writeback_attempted", S_IRUGO,
> +			zswap_debugfs_root, &zswap_writeback_attempted);
> +	debugfs_create_u64("reject_tmppage_fail", S_IRUGO,
> +			zswap_debugfs_root, &zswap_reject_tmppage_fail);
>   	debugfs_create_u64("reject_zsmalloc_fail", S_IRUGO,
>   			zswap_debugfs_root, &zswap_reject_zsmalloc_fail);
>   	debugfs_create_u64("reject_kmemcache_fail", S_IRUGO,
>   			zswap_debugfs_root, &zswap_reject_kmemcache_fail);
>   	debugfs_create_u64("reject_compress_poor", S_IRUGO,
>   			zswap_debugfs_root, &zswap_reject_compress_poor);
> +	debugfs_create_u64("written_back_pages", S_IRUGO,
> +			zswap_debugfs_root, &zswap_written_back_pages);
>   	debugfs_create_u64("duplicate_entry", S_IRUGO,
>   			zswap_debugfs_root, &zswap_duplicate_entry);
>   	debugfs_create_atomic_t("pool_pages", S_IRUGO,
>   			zswap_debugfs_root, &zswap_pool_pages);
>   	debugfs_create_atomic_t("stored_pages", S_IRUGO,
>   			zswap_debugfs_root, &zswap_stored_pages);
> +	debugfs_create_atomic_t("outstanding_writebacks", S_IRUGO,
> +			zswap_debugfs_root, &zswap_outstanding_writebacks);
>   
>   	return 0;
>   }
> @@ -629,6 +1113,10 @@ static int __init init_zswap(void)
>   		pr_err("page pool initialization failed\n");
>   		goto pagepoolfail;
>   	}
> +	if (zswap_tmppage_pool_create()) {
> +		pr_err("workmem pool initialization failed\n");
> +		goto tmppoolfail;
> +	}
>   	if (zswap_comp_init()) {
>   		pr_err("compressor initialization failed\n");
>   		goto compfail;
> @@ -644,6 +1132,8 @@ static int __init init_zswap(void)
>   pcpufail:
>   	zswap_comp_exit();
>   compfail:
> +	zswap_tmppage_pool_destroy();
> +tmppoolfail:
>   	zswap_page_pool_destroy();
>   pagepoolfail:
>   	zswap_entry_cache_destory();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
