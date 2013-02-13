Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id D050B6B0005
	for <linux-mm@kvack.org>; Wed, 13 Feb 2013 01:24:47 -0500 (EST)
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Tue, 12 Feb 2013 23:24:47 -0700
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id BF81C1FF0043
	for <linux-mm@kvack.org>; Tue, 12 Feb 2013 23:24:44 -0700 (MST)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1D6OiBV239404
	for <linux-mm@kvack.org>; Tue, 12 Feb 2013 23:24:44 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1D6Ohdl006500
	for <linux-mm@kvack.org>; Tue, 12 Feb 2013 23:24:44 -0700
Message-ID: <511B31A6.1080500@linux.vnet.ibm.com>
Date: Wed, 13 Feb 2013 00:24:38 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCHv4 6/7] zswap: add flushing support
References: <1359495627-30285-1-git-send-email-sjenning@linux.vnet.ibm.com> <1359495627-30285-7-git-send-email-sjenning@linux.vnet.ibm.com> <20130201072721.GC6262@blaptop>
In-Reply-To: <20130201072721.GC6262@blaptop>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On 02/01/2013 01:27 AM, Minchan Kim wrote:
> On Tue, Jan 29, 2013 at 03:40:26PM -0600, Seth Jennings wrote:
>> This patchset adds support for flush pages out of the compressed
>> pool to the swap device
>>

Thanks for the review Minchan! Sorry for the delayed response.  I'm
prepping v5 for posting.

> 
> I know you don't have a enough time since you sent previous patch.
> Please add lots of words next time.
> 
> 1. advertise "awesome feature", which igrate from zswap to real swap device
> 2. What's the tmppage?
> 3. frontswap_load/store/invalidate/flush race and object life time
> 4. policy to reclaim.

Will do.

> 
>> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
>> ---
>>  mm/zswap.c | 451 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++---
>>  1 file changed, 434 insertions(+), 17 deletions(-)
>>
>> diff --git a/mm/zswap.c b/mm/zswap.c
>> index a6c2928..b8e5673 100644
>> --- a/mm/zswap.c
>> +++ b/mm/zswap.c
>> @@ -34,6 +34,12 @@
>>  #include <linux/mempool.h>
>>  #include <linux/zsmalloc.h>
>>  
>> +#include <linux/mm_types.h>
>> +#include <linux/page-flags.h>
>> +#include <linux/swapops.h>
>> +#include <linux/writeback.h>
>> +#include <linux/pagemap.h>
>> +
>>  /*********************************
>>  * statistics
>>  **********************************/
>> @@ -41,6 +47,8 @@
>>  static atomic_t zswap_pool_pages = ATOMIC_INIT(0);
>>  /* The number of compressed pages currently stored in zswap */
>>  static atomic_t zswap_stored_pages = ATOMIC_INIT(0);
>> +/* The number of outstanding pages awaiting writeback */
>> +static atomic_t zswap_outstanding_flushes = ATOMIC_INIT(0);
>>  
>>  /*
>>   * The statistics below are not protected from concurrent access for
>> @@ -49,9 +57,14 @@ static atomic_t zswap_stored_pages = ATOMIC_INIT(0);
>>   * certain event is occurring.
>>  */
>>  static u64 zswap_pool_limit_hit;
>> +static u64 zswap_flushed_pages;
>>  static u64 zswap_reject_compress_poor;
>> +static u64 zswap_flush_attempted;
>> +static u64 zswap_reject_tmppage_fail;
> 
> What's does it mean? Hmm, I looked at the code.
> It means fail to allocator for tmppage.

I'll add a comment for this and additional information about the roll of
the tmppage mechanism in the code since it's a little unusual.

> 
> How about "zswap_tmppage_alloc_fail"?

The method to my naming madness was that any stat that counted a reason
for a failed store started with zswap_reject_*

> 
>> +static u64 zswap_reject_flush_fail;
> 
> I am confused, too so looked at code but fail to find usecase.
> Remove?

Good call. I'll remove.  Must have been left over from something else.

> 
>>  static u64 zswap_reject_zsmalloc_fail;
> 
> We can remove this because get it by (zswap_flush_attempted - zswap_saved_by_flush)
> 

This is true.  I'll keep it in for now since it's not completely obvious
is can be derived from other stats without looking at the code.

>>  static u64 zswap_reject_kmemcache_fail;
>> +static u64 zswap_saved_by_flush;
> 
> I can't think better naming but need a comment at a minimum.

Yeah...

> 
>>  static u64 zswap_duplicate_entry;
>>  
>>  /*********************************
>> @@ -80,6 +93,14 @@ static unsigned int zswap_max_compression_ratio = 80;
>>  module_param_named(max_compression_ratio,
>>  			zswap_max_compression_ratio, uint, 0644);
>>  
>> +/*
>> + * Maximum number of outstanding flushes allowed at any given time.
>> + * This is to prevent decompressing an unbounded number of compressed
>> + * pages into the swap cache all at once, and to help with writeback
>> + * congestion.
>> +*/
>> +#define ZSWAP_MAX_OUTSTANDING_FLUSHES 64
>> +
>>  /*********************************
>>  * compression functions
>>  **********************************/
>> @@ -145,14 +166,23 @@ static void zswap_comp_exit(void)
>>  **********************************/
> 
> Please introduce why we need LRU and refcount.

Will do.

> 
>>  struct zswap_entry {
>>  	struct rb_node rbnode;
>> +	struct list_head lru;
>> +	int refcount;
> 
> Just nit,
> I understand why you don't use atomic but it would be nice to
> write down it in description of patch for preventing unnecessary
> arguing.

Yes.  For the record, the reason is that we must take the tree lock in
order to change the refcount of an entry contained in the tree.
Incrementing an atomic under lock would be redundantly atomic.

> 
>>  	unsigned type;
>>  	pgoff_t offset;
>>  	unsigned long handle;
>>  	unsigned int length;
>>  };
>>  
>> +/*
>> + * The tree lock in the zswap_tree struct protects a few things:
>> + * - the rbtree
>> + * - the lru list
>> + * - the refcount field of each entry in the tree
>> + */
>>  struct zswap_tree {
>>  	struct rb_root rbroot;
>> +	struct list_head lru;
>>  	spinlock_t lock;
>>  	struct zs_pool *pool;
>>  };
>> @@ -184,6 +214,8 @@ static inline struct zswap_entry *zswap_entry_cache_alloc(gfp_t gfp)
>>  	entry = kmem_cache_alloc(zswap_entry_cache, gfp);
>>  	if (!entry)
>>  		return NULL;
>> +	INIT_LIST_HEAD(&entry->lru);
>> +	entry->refcount = 1;
>>  	return entry;
>>  }
>>  
>> @@ -192,6 +224,17 @@ static inline void zswap_entry_cache_free(struct zswap_entry *entry)
>>  	kmem_cache_free(zswap_entry_cache, entry);
>>  }
>>  
>> +static inline void zswap_entry_get(struct zswap_entry *entry)
>> +{
>> +	entry->refcount++;
>> +}
>> +
>> +static inline int zswap_entry_put(struct zswap_entry *entry)
>> +{
>> +	entry->refcount--;
>> +	return entry->refcount;
>> +}
>> +
>>  /*********************************
>>  * rbtree functions
>>  **********************************/
>> @@ -367,6 +410,278 @@ static struct zs_ops zswap_zs_ops = {
>>  };
>>  
>>  /*********************************
>> +* flush code
>> +**********************************/
> 
> As Andrew pointed out, let's change the naming.
> I'd like to imply "send back to original seat" instead of flush because
> the page is just intercepted by frontswap on the way.
> More thining about it, current implentation go with it but we can
> add indirection layer of swap so frontswap page could be migrated other
> swap slot to enhance swapout bandwidth so "migrate the swap page to elsewhere"
> is more proper. I'd like to depend on native speakers. :)

I'm going to use "writeback" for now since "resumed writeback" is what
I'm naming this process in zswap.
> 
>> +static void zswap_end_swap_write(struct bio *bio, int err)
>> +{
>> +	end_swap_bio_write(bio, err);
>> +	atomic_dec(&zswap_outstanding_flushes);
>> +	zswap_flushed_pages++;
>> +}
>> +
>> +/*
>> + * zswap_get_swap_cache_page
>> + *
>> + * This is an adaption of read_swap_cache_async()
> 
> Please write down what's this function's goal and why we need it
> if need because of function's complexity.

Will do.

> 
>> + *
>> + * If success, page is returned in retpage
>> + * Returns 0 if page was already in the swap cache, page is not locked
>> + * Returns 1 if the new page needs to be populated, page is locked
> 
>       Return -ENOMEM if the allocation is failed.
> 
>> + */
>> +static int zswap_get_swap_cache_page(swp_entry_t entry,
>> +				struct page **retpage)
>> +{
>> +	struct page *found_page, *new_page = NULL;
>> +	int err;
>> +
>> +	*retpage = NULL;
>> +	do {
>> +		/*
>> +		 * First check the swap cache.  Since this is normally
>> +		 * called after lookup_swap_cache() failed, re-calling
>> +		 * that would confuse statistics.
>> +		 */
>> +		found_page = find_get_page(&swapper_space, entry.val);
>> +		if (found_page)
>> +			break;
>> +
>> +		/*
>> +		 * Get a new page to read into from swap.
>> +		 */
>> +		if (!new_page) {
>> +			new_page = alloc_page(GFP_KERNEL);
>> +			if (!new_page)
>> +				break; /* Out of memory */
>> +		}
>> +
>> +		/*
>> +		 * call radix_tree_preload() while we can wait.
>> +		 */
>> +		err = radix_tree_preload(GFP_KERNEL);
>> +		if (err)
>> +			break;
>> +
>> +		/*
>> +		 * Swap entry may have been freed since our caller observed it.
>> +		 */
>> +		err = swapcache_prepare(entry);
>> +		if (err == -EEXIST) { /* seems racy */
>> +			radix_tree_preload_end();
>> +			continue;
>> +		}
>> +		if (err) { /* swp entry is obsolete ? */
>> +			radix_tree_preload_end();
>> +			break;
>> +		}
>> +
>> +		/* May fail (-ENOMEM) if radix-tree node allocation failed. */
>> +		__set_page_locked(new_page);
>> +		SetPageSwapBacked(new_page);
>> +		err = __add_to_swap_cache(new_page, entry);
>> +		if (likely(!err)) {
>> +			radix_tree_preload_end();
>> +			lru_cache_add_anon(new_page);
>> +			*retpage = new_page;
>> +			return 1;
>> +		}
>> +		radix_tree_preload_end();
>> +		ClearPageSwapBacked(new_page);
>> +		__clear_page_locked(new_page);
>> +		/*
>> +		 * add_to_swap_cache() doesn't return -EEXIST, so we can safely
>> +		 * clear SWAP_HAS_CACHE flag.
>> +		 */
>> +		swapcache_free(entry, NULL);
>> +	} while (err != -ENOMEM);
>> +
>> +	if (new_page)
>> +		page_cache_release(new_page);
>> +	if (!found_page)
>> +		return -ENOMEM;
>> +	*retpage = found_page;
>> +	return 0;
>> +}
>> +
>> +static int zswap_flush_entry(struct zswap_entry *entry)
>> +{
>> +	unsigned long type = entry->type;
>> +	struct zswap_tree *tree = zswap_trees[type];
>> +	struct page *page;
>> +	swp_entry_t swpentry;
>> +	u8 *src, *dst;
>> +	unsigned int dlen;
>> +	int ret, refcount;
>> +	struct writeback_control wbc = {
>> +		.sync_mode = WB_SYNC_NONE,
>> +	};
>> +
>> +	/* get/allocate page in the swap cache */
>> +	swpentry = swp_entry(type, entry->offset);
>> +	ret = zswap_get_swap_cache_page(swpentry, &page);
> 
> IMHO, zswap_get_swap_cache_page have to ruturn meaningful enum type
> so we have to use switch instead of if-else series.

Yes, that would be cleaner.  During development, I was hoping I could
find a way to use the existing read_swap_cache_async(), but I couldn't
figure out a clean way to do it.

> 
>> +	if (ret < 0)
>> +		return ret;
>> +	else if (ret) {
>> +		/* decompress */
>> +		dlen = PAGE_SIZE;
>> +		src = zs_map_object(tree->pool, entry->handle, ZS_MM_RO);
>> +		dst = kmap_atomic(page);
>> +		ret = zswap_comp_op(ZSWAP_COMPOP_DECOMPRESS, src, entry->length,
>> +				dst, &dlen);
>> +		kunmap_atomic(dst);
>> +		zs_unmap_object(tree->pool, entry->handle);
>> +		BUG_ON(ret);
>> +		BUG_ON(dlen != PAGE_SIZE);
>> +		SetPageUptodate(page);
>> +	} else {
>> +		/* page is already in the swap cache, ignore for now */
>> +		spin_lock(&tree->lock);
>> +		refcount = zswap_entry_put(entry);
>> +		spin_unlock(&tree->lock);
>> +
>> +		if (likely(refcount))
>> +			return 0;
> 
> It doesn't mean we are writing out and migrated so it would be better
> to return non-zero.
> 
>> +
>> +		/* if the refcount is zero, invalidate must have come in */
>> +		/* free */
>> +		zs_free(tree->pool, entry->handle);
>> +		zswap_entry_cache_free(entry);
>> +		atomic_dec(&zswap_stored_pages);
> 
> It would be better to factor out these functions.

Yes. I'll add this.

> 
> void free_or_destroy_or_something_zswap_entry(...)
> {
>         zs_free
>         zswap_entry_cache_free
>         atomic_dec
> }
> 
>> +
>> +		return 0;
>> +	}
>> +
>> +	/* start writeback */
>> +	SetPageReclaim(page);
>> +	/*
>> +	 * Return value is ignored here because it doesn't change anything
>> +	 * for us.  Page is returned unlocked.
>> +	 */
>> +	(void)__swap_writepage(page, &wbc, zswap_end_swap_write);
>> +	page_cache_release(page);
>> +	atomic_inc(&zswap_outstanding_flushes);
>> +
>> +	/* remove */
>> +	spin_lock(&tree->lock);
>> +	refcount = zswap_entry_put(entry);
>> +	if (refcount > 1) {
> 
> Let's be a kind.
>                 /* If the race happens with zswap_frontswap_load,
>                  * we move the zswap_entry into tail again because
>                  * it used recenlty so there is no point to remove
>                  * it in memory.
>                  * It could be duplicated copy between in-memory and
>                  * real swap device but no biggie.
>                  */

I didn't follow this one :-/

> 
>> +		/* load in progress, load will free */
>> +		spin_unlock(&tree->lock);
>> +		return 0;
>> +	}
>> +	if (refcount == 1)
>> +		/* no invalidate yet, remove from rbtree */
>> +		rb_erase(&entry->rbnode, &tree->rbroot);
>> +	spin_unlock(&tree->lock);
>> +
>> +	/* free */
>> +	zs_free(tree->pool, entry->handle);
>> +	zswap_entry_cache_free(entry);
>> +	atomic_dec(&zswap_stored_pages);
>> +
>> +	return 0;
>> +}
>> +
>> +static void zswap_flush_entries(unsigned type, int nr)
> 
> Just nit,
> It would be useful to return the number of migrated pages

I can do that.  Wouldn't be used though (for now).

> 
>> +{
>> +	struct zswap_tree *tree = zswap_trees[type];
>> +	struct zswap_entry *entry;
>> +	int i, ret;
>> +
>> +/*
>> + * This limits is arbitrary for now until a better
>> + * policy can be implemented. This is so we don't
>> + * eat all of RAM decompressing pages for writeback.
>> + */
> 
> Indent.

Yes.

> 
>> +	if (atomic_read(&zswap_outstanding_flushes) >
>> +		ZSWAP_MAX_OUTSTANDING_FLUSHES)
>> +		return;
>> +
>> +	for (i = 0; i < nr; i++) {
> 
> As other people already pointed out, LRU reclaim could be a
> problem because of spreading object across several slab.
> Just an idea. I'd like to reclaim per SLAB instead of object.
> For it, we have to add some age facility into zsmalloc, could
> be enalbed optionally by Kconfig.
> 
> The zsmalloc gives an age every allocated object.
> For example, we allocate some object following as
> 
> Object allocation orer : O(A), O(B), O(C), O(D), O(E)
> 
> so lru ordering is same.
> 
> LRU ordering : head-O(A)->O(B)->O(C)->O(D)->O(E)->tail
> (tail is recent used object)
> 
> The zsmalloc could give an age following as,
> 
> O(A,1), O(B,2), O(C,3), O(D,4), O(E, 5)
> 
> They are located in following as.
> 
>      zspage 1:4         zspage 2:5          zspage 3:6
> | O(A, 1), O(C, 3) | -- | O(E, 5) | -- | O(B, 2), O(D, 4) |
> 
> 
> When zswap try to reclaim, it needs smallest age's zspage
> so it is zspage 1 as age 4.
> It is likely to include less recently used object and we surely get a free page
> for us.
> 
>> +		/* dequeue from lru */
>> +		spin_lock(&tree->lock);
>> +		if (list_empty(&tree->lru)) {
>> +			spin_unlock(&tree->lock);
>> +			break;
>> +		}
>> +		entry = list_first_entry(&tree->lru,
>> +				struct zswap_entry, lru);
>> +		list_del(&entry->lru);
> 
> Use list_del_init and list_empty.

Ah yes, very good.

> 
>> +		zswap_entry_get(entry);
> 
> When do you decrease ref count if zswap_flush_entry fails by alloc fail?

Good catch.  I'll fix it up.

> 
>> +		spin_unlock(&tree->lock);
>> +		ret = zswap_flush_entry(entry);
>> +		if (ret) {
>> +			/* put back on the lru */
>> +			spin_lock(&tree->lock);
>> +			list_add(&entry->lru, &tree->lru);
>> +			spin_unlock(&tree->lock);
>> +		} else {
>> +			if (atomic_read(&zswap_outstanding_flushes) >
>> +				ZSWAP_MAX_OUTSTANDING_FLUSHES)
>> +				break;
>> +		}
>> +	}
>> +}
>> +
>> +/*******************************************
>> +* page pool for temporary compression result
>> +********************************************/
>> +#define ZSWAP_TMPPAGE_POOL_PAGES 16
>> +static LIST_HEAD(zswap_tmppage_list);
>> +static DEFINE_SPINLOCK(zswap_tmppage_lock);
>> +
>> +static void zswap_tmppage_pool_destroy(void)
>> +{
>> +	struct page *page, *tmppage;
>> +
>> +	spin_lock(&zswap_tmppage_lock);
>> +	list_for_each_entry_safe(page, tmppage, &zswap_tmppage_list, lru) {
>> +		list_del(&page->lru);
>> +		__free_pages(page, 1);
>> +	}
>> +	spin_unlock(&zswap_tmppage_lock);
>> +}
>> +
>> +static int zswap_tmppage_pool_create(void)
>> +{
>> +	int i;
>> +	struct page *page;
>> +
>> +	for (i = 0; i < ZSWAP_TMPPAGE_POOL_PAGES; i++) {
>> +		page = alloc_pages(GFP_KERNEL, 1);
>> +		if (!page) {
>> +			zswap_tmppage_pool_destroy();
>> +			return -ENOMEM;
>> +		}
>> +		spin_lock(&zswap_tmppage_lock);
>> +		list_add(&page->lru, &zswap_tmppage_list);
>> +		spin_unlock(&zswap_tmppage_lock);
>> +	}
>> +	return 0;
>> +}
>> +
>> +static inline struct page *zswap_tmppage_alloc(void)
>> +{
>> +	struct page *page;
>> +
>> +	spin_lock(&zswap_tmppage_lock);
>> +	if (list_empty(&zswap_tmppage_list)) {
>> +		spin_unlock(&zswap_tmppage_lock);
>> +		return NULL;
>> +	}
>> +	page = list_first_entry(&zswap_tmppage_list, struct page, lru);
>> +	list_del(&page->lru);
>> +	spin_unlock(&zswap_tmppage_lock);
>> +	return page;
>> +}
>> +
>> +static inline void zswap_tmppage_free(struct page *page)
>> +{
>> +	spin_lock(&zswap_tmppage_lock);
>> +	list_add(&page->lru, &zswap_tmppage_list);
>> +	spin_unlock(&zswap_tmppage_lock);
>> +}
>> +
>> +/*********************************
>>  * frontswap hooks
>>  **********************************/
>>  /* attempts to compress and store an single page */
>> @@ -378,7 +693,9 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset, struct page *pag
>>  	unsigned int dlen = PAGE_SIZE;
>>  	unsigned long handle;
>>  	char *buf;
>> -	u8 *src, *dst;
>> +	u8 *src, *dst, *tmpdst;
>> +	struct page *tmppage;
>> +	bool flush_attempted = 0;
>>  
>>  	if (!tree) {
>>  		ret = -ENODEV;
>> @@ -392,12 +709,12 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset, struct page *pag
>>  	kunmap_atomic(src);
>>  	if (ret) {
>>  		ret = -EINVAL;
>> -		goto putcpu;
>> +		goto freepage;
>>  	}
>>  	if ((dlen * 100 / PAGE_SIZE) > zswap_max_compression_ratio) {
>>  		zswap_reject_compress_poor++;
>>  		ret = -E2BIG;
>> -		goto putcpu;
>> +		goto freepage;
>>  	}
>>  
>>  	/* store */
>> @@ -405,15 +722,46 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset, struct page *pag
>>  		__GFP_NORETRY | __GFP_HIGHMEM | __GFP_NOMEMALLOC |
>>  			__GFP_NOWARN);
>>  	if (!handle) {
>> -		zswap_reject_zsmalloc_fail++;
>> -		ret = -ENOMEM;
>> -		goto putcpu;
>> +		zswap_flush_attempted++;
>> +		/*
>> +		 * Copy compressed buffer out of per-cpu storage so
>> +		 * we can re-enable preemption.
>> +		*/
>> +		tmppage = zswap_tmppage_alloc();
>> +		if (!tmppage) {
>> +			zswap_reject_tmppage_fail++;
>> +			ret = -ENOMEM;
>> +			goto freepage;
>> +		}
>> +		flush_attempted = 1;
>> +		tmpdst = page_address(tmppage);
>> +		memcpy(tmpdst, dst, dlen);
>> +		dst = tmpdst;
>> +		put_cpu_var(zswap_dstmem);
> 
> Just use copy for enabling preemption? I don't have a good idea but surely
> we could have better approach at the end. Let's think about it.
> 
>> +
>> +		/* try to free up some space */
>> +		/* TODO: replace with more targeted policy */
>> +		zswap_flush_entries(type, 16);
>> +		/* try again, allowing wait */
>> +		handle = zs_malloc(tree->pool, dlen,
>> +			__GFP_NORETRY | __GFP_HIGHMEM | __GFP_NOMEMALLOC |
>> +				__GFP_NOWARN);
>> +		if (!handle) {
>> +			/* still no space, fail */
>> +			zswap_reject_zsmalloc_fail++;
>> +			ret = -ENOMEM;
>> +			goto freepage;
>> +		}
>> +		zswap_saved_by_flush++;
>>  	}
>>  
>>  	buf = zs_map_object(tree->pool, handle, ZS_MM_WO);
>>  	memcpy(buf, dst, dlen);
>>  	zs_unmap_object(tree->pool, handle);
>> -	put_cpu_var(zswap_dstmem);
>> +	if (flush_attempted)
>> +		zswap_tmppage_free(tmppage);
>> +	else
>> +		put_cpu_var(zswap_dstmem);
>>  
>>  	/* allocate entry */
>>  	entry = zswap_entry_cache_alloc(GFP_KERNEL);
>> @@ -436,16 +784,19 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset, struct page *pag
>>  		ret = zswap_rb_insert(&tree->rbroot, entry, &dupentry);
>>  		if (ret == -EEXIST) {
>>  			zswap_duplicate_entry++;
>> -
>> -			/* remove from rbtree */
>> +			/* remove from rbtree and lru */
>>  			rb_erase(&dupentry->rbnode, &tree->rbroot);
>> -			
>> -			/* free */
>> -			zs_free(tree->pool, dupentry->handle);
>> -			zswap_entry_cache_free(dupentry);
>> -			atomic_dec(&zswap_stored_pages);
>> +			if (dupentry->lru.next != LIST_POISON1)
>> +				list_del(&dupentry->lru);
>> +			if (!zswap_entry_put(dupentry)) {
>> +				/* free */
>> +				zs_free(tree->pool, dupentry->handle);
>> +				zswap_entry_cache_free(dupentry);
>> +				atomic_dec(&zswap_stored_pages);
>> +			}
>>  		}
>>  	} while (ret == -EEXIST);
>> +	list_add_tail(&entry->lru, &tree->lru);
>>  	spin_unlock(&tree->lock);
>>  
>>  	/* update stats */
>> @@ -453,8 +804,11 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset, struct page *pag
>>  
>>  	return 0;
>>  
>> -putcpu:
>> -	put_cpu_var(zswap_dstmem);
>> +freepage:
>> +	if (flush_attempted)
>> +		zswap_tmppage_free(tmppage);
>> +	else
>> +		put_cpu_var(zswap_dstmem);
>>  reject:
>>  	return ret;
>>  }
>> @@ -469,10 +823,21 @@ static int zswap_frontswap_load(unsigned type, pgoff_t offset, struct page *page
>>  	struct zswap_entry *entry;
>>  	u8 *src, *dst;
>>  	unsigned int dlen;
>> +	int refcount;
>>  
>>  	/* find */
>>  	spin_lock(&tree->lock);
>>  	entry = zswap_rb_search(&tree->rbroot, offset);
>> +	if (!entry) {
>> +		/* entry was flushed */
>> +		spin_unlock(&tree->lock);
>> +		return -1;
>> +	}
> 
> Let's be a kind.
> 
>         /* flusher/invalidate can destroy entry under us */

Sure :)

Thanks Minchan!

Seth

>> +	zswap_entry_get(entry);
>> +
>> +	/* remove from lru */
>> +	if (entry->lru.next != LIST_POISON1)
>> +		list_del(&entry->lru);
> 
>         if (!list_empty(&entry->lru))
>                 list_del_init(&entry->lru);
> 
>>  	spin_unlock(&tree->lock);
>>  
>>  	/* decompress */
>> @@ -484,6 +849,25 @@ static int zswap_frontswap_load(unsigned type, pgoff_t offset, struct page *page
>>  	kunmap_atomic(dst);
>>  	zs_unmap_object(tree->pool, entry->handle);
>>  
>> +	spin_lock(&tree->lock);
>> +	refcount = zswap_entry_put(entry);
>> +	if (likely(refcount)) {
>> +		list_add_tail(&entry->lru, &tree->lru);
>> +		spin_unlock(&tree->lock);
>> +		return 0;
>> +	}
>> +	spin_unlock(&tree->lock);
>> +
>> +	/*
>> +	 * We don't have to unlink from the rbtree because zswap_flush_entry()
>> +	 * or zswap_frontswap_invalidate page() has already done this for us if we
>> +	 * are the last reference.
>> +	 */
>> +	/* free */
>> +	zs_free(tree->pool, entry->handle);
>> +	zswap_entry_cache_free(entry);
>> +	atomic_dec(&zswap_stored_pages);
>> +
>>  	return 0;
>>  }
>>  
>> @@ -492,14 +876,27 @@ static void zswap_frontswap_invalidate_page(unsigned type, pgoff_t offset)
>>  {
>>  	struct zswap_tree *tree = zswap_trees[type];
>>  	struct zswap_entry *entry;
>> +	int refcount;
>>  
>>  	/* find */
>>  	spin_lock(&tree->lock);
>>  	entry = zswap_rb_search(&tree->rbroot, offset);
>> +	if (!entry) {
>> +		/* entry was flushed */
>> +		spin_unlock(&tree->lock);
>> +		return;
>> +	}
>>  
>> -	/* remove from rbtree */
>> +	/* remove from rbtree and lru */
>>  	rb_erase(&entry->rbnode, &tree->rbroot);
>> +	if (entry->lru.next != LIST_POISON1)
>> +		list_del(&entry->lru);
>> +	refcount = zswap_entry_put(entry);
>>  	spin_unlock(&tree->lock);
>> +	if (refcount) {
>> +		/* must be flushing */
>> +		return;
>> +	}
>>  
>>  	/* free */
>>  	zs_free(tree->pool, entry->handle);
>> @@ -528,6 +925,7 @@ static void zswap_frontswap_invalidate_area(unsigned type)
>>  		node = next;
>>  	}
>>  	tree->rbroot = RB_ROOT;
>> +	INIT_LIST_HEAD(&tree->lru);
>>  	spin_unlock(&tree->lock);
>>  }
>>  
>> @@ -543,6 +941,7 @@ static void zswap_frontswap_init(unsigned type)
>>  	if (!tree->pool)
>>  		goto freetree;
>>  	tree->rbroot = RB_ROOT;
>> +	INIT_LIST_HEAD(&tree->lru);
>>  	spin_lock_init(&tree->lock);
>>  	zswap_trees[type] = tree;
>>  	return;
>> @@ -578,20 +977,32 @@ static int __init zswap_debugfs_init(void)
>>  	if (!zswap_debugfs_root)
>>  		return -ENOMEM;
>>  
>> +	debugfs_create_u64("saved_by_flush", S_IRUGO,
>> +			zswap_debugfs_root, &zswap_saved_by_flush);
>>  	debugfs_create_u64("pool_limit_hit", S_IRUGO,
>>  			zswap_debugfs_root, &zswap_pool_limit_hit);
>> +	debugfs_create_u64("reject_flush_attempted", S_IRUGO,
>> +			zswap_debugfs_root, &zswap_flush_attempted);
>> +	debugfs_create_u64("reject_tmppage_fail", S_IRUGO,
>> +			zswap_debugfs_root, &zswap_reject_tmppage_fail);
>> +	debugfs_create_u64("reject_flush_fail", S_IRUGO,
>> +			zswap_debugfs_root, &zswap_reject_flush_fail);
>>  	debugfs_create_u64("reject_zsmalloc_fail", S_IRUGO,
>>  			zswap_debugfs_root, &zswap_reject_zsmalloc_fail);
>>  	debugfs_create_u64("reject_kmemcache_fail", S_IRUGO,
>>  			zswap_debugfs_root, &zswap_reject_kmemcache_fail);
>>  	debugfs_create_u64("reject_compress_poor", S_IRUGO,
>>  			zswap_debugfs_root, &zswap_reject_compress_poor);
>> +	debugfs_create_u64("flushed_pages", S_IRUGO,
>> +			zswap_debugfs_root, &zswap_flushed_pages);
>>  	debugfs_create_u64("duplicate_entry", S_IRUGO,
>>  			zswap_debugfs_root, &zswap_duplicate_entry);
>>  	debugfs_create_atomic_t("pool_pages", S_IRUGO,
>>  			zswap_debugfs_root, &zswap_pool_pages);
>>  	debugfs_create_atomic_t("stored_pages", S_IRUGO,
>>  			zswap_debugfs_root, &zswap_stored_pages);
>> +	debugfs_create_atomic_t("outstanding_flushes", S_IRUGO,
>> +			zswap_debugfs_root, &zswap_outstanding_flushes);
>>  
>>  	return 0;
>>  }
>> @@ -627,6 +1038,10 @@ static int __init init_zswap(void)
>>  		pr_err("zswap: page pool initialization failed\n");
>>  		goto pagepoolfail;
>>  	}
>> +	if (zswap_tmppage_pool_create()) {
>> +		pr_err("zswap: workmem pool initialization failed\n");
>> +		goto tmppoolfail;
>> +	}
>>  	if (zswap_comp_init()) {
>>  		pr_err("zswap: compressor initialization failed\n");
>>  		goto compfail;
>> @@ -642,6 +1057,8 @@ static int __init init_zswap(void)
>>  pcpufail:
>>  	zswap_comp_exit();
>>  compfail:
>> +	zswap_tmppage_pool_destroy();
>> +tmppoolfail:
>>  	zswap_page_pool_destroy();
>>  pagepoolfail:
>>  	zswap_entry_cache_destory();
>> -- 
>> 1.8.1.1
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
