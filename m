Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f45.google.com (mail-yh0-f45.google.com [209.85.213.45])
	by kanga.kvack.org (Postfix) with ESMTP id 691AB6B0031
	for <linux-mm@kvack.org>; Fri, 22 Nov 2013 12:29:23 -0500 (EST)
Received: by mail-yh0-f45.google.com with SMTP id i7so979459yha.18
        for <linux-mm@kvack.org>; Fri, 22 Nov 2013 09:29:23 -0800 (PST)
Received: from mail-oa0-x22e.google.com (mail-oa0-x22e.google.com [2607:f8b0:4003:c02::22e])
        by mx.google.com with ESMTPS id w8si19593565yhd.8.2013.11.22.09.29.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 22 Nov 2013 09:29:22 -0800 (PST)
Received: by mail-oa0-f46.google.com with SMTP id o6so1684776oag.5
        for <linux-mm@kvack.org>; Fri, 22 Nov 2013 09:29:21 -0800 (PST)
Date: Fri, 22 Nov 2013 11:29:16 -0600
From: Seth Jennings <sjennings@variantweb.net>
Subject: Re: [PATCH v2] mm/zswap: change zswap to writethrough cache
Message-ID: <20131122172916.GB6477@cerebellum.variantweb.net>
References: <1384976973-32722-1-git-send-email-ddstreet@ieee.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1384976973-32722-1-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Bob Liu <bob.liu@oracle.com>, Minchan Kim <minchan@kernel.org>, Weijie Yang <weijie.yang@samsung.com>

On Wed, Nov 20, 2013 at 02:49:33PM -0500, Dan Streetman wrote:
> Currently, zswap is writeback cache; stored pages are not sent
> to swap disk, and when zswap wants to evict old pages it must
> first write them back to swap cache/disk manually.  This avoids
> swap out disk I/O up front, but only moves that disk I/O to
> the writeback case (for pages that are evicted), and adds the
> overhead of having to uncompress the evicted pages, and adds the
> need for an additional free page (to store the uncompressed page)
> at a time of likely high memory pressure.  Additionally, being
> writeback adds complexity to zswap by having to perform the
> writeback on page eviction.
> 
> This changes zswap to writethrough cache by enabling
> frontswap_writethrough() before registering, so that any
> successful page store will also be written to swap disk.  All the
> writeback code is removed since it is no longer needed, and the
> only operation during a page eviction is now to remove the entry
> from the tree and free it.

I like it.  It gets rid of a lot of nasty writeback code in zswap.

I'll have to test before I ack, hopefully by the end of the day.

Yes, this will increase writes to the swap device over the delayed
writeback approach.  I think it is a good thing though.  I think it
makes the difference between zswap and zram, both in operation and in
application, more apparent. Zram is the better choice for embedded where
write wear is a concern, and zswap being better if you need more
flexibility to dynamically manage the compressed pool.

Seth

> 
> Signed-off-by: Dan Streetman <ddstreet@ieee.org>
> ---
> 
> This does require the patch just sent to the list
> "mm/zswap: don't allow entry eviction if in use by load"
> is applied.
> 
> Changes since v1:
> update to apply to latest -tip, previous patch missed several recent
> zswap patches.
> 
>  mm/zswap.c | 208 ++++++-------------------------------------------------------
>  1 file changed, 18 insertions(+), 190 deletions(-)
> 
> diff --git a/mm/zswap.c b/mm/zswap.c
> index f4fbbd5..2d209a3 100644
> --- a/mm/zswap.c
> +++ b/mm/zswap.c
> @@ -39,7 +39,6 @@
>  #include <linux/mm_types.h>
>  #include <linux/page-flags.h>
>  #include <linux/swapops.h>
> -#include <linux/writeback.h>
>  #include <linux/pagemap.h>
>  
>  /*********************************
> @@ -59,8 +58,8 @@ static atomic_t zswap_stored_pages = ATOMIC_INIT(0);
>  
>  /* Pool limit was hit (see zswap_max_pool_percent) */
>  static u64 zswap_pool_limit_hit;
> -/* Pages written back when pool limit was reached */
> -static u64 zswap_written_back_pages;
> +/* Pages evicted when pool limit was reached */
> +static u64 zswap_evicted_pages;
>  /* Store failed due to a reclaim failure after pool limit was reached */
>  static u64 zswap_reject_reclaim_fail;
>  /* Compressed page was too big for the allocator to (optimally) store */
> @@ -160,7 +159,7 @@ static void zswap_comp_exit(void)
>   * rbnode - links the entry into red-black tree for the appropriate swap type
>   * refcount - the number of outstanding reference to the entry. This is needed
>   *            to protect against premature freeing of the entry by code
> - *            concurent calls to load, invalidate, and writeback.  The lock
> + *            concurent calls to load, invalidate, and evict.  The lock
>   *            for the zswap_tree structure that contains the entry must
>   *            be held while changing the refcount.  Since the lock must
>   *            be held, there is no reason to also make refcount atomic.
> @@ -412,132 +411,19 @@ static bool zswap_is_full(void)
>  }
>  
>  /*********************************
> -* writeback code
> +* evict
>  **********************************/
> -/* return enum for zswap_get_swap_cache_page */
> -enum zswap_get_swap_ret {
> -	ZSWAP_SWAPCACHE_NEW,
> -	ZSWAP_SWAPCACHE_EXIST,
> -	ZSWAP_SWAPCACHE_FAIL,
> -};
> -
> -/*
> - * zswap_get_swap_cache_page
> - *
> - * This is an adaption of read_swap_cache_async()
> - *
> - * This function tries to find a page with the given swap entry
> - * in the swapper_space address space (the swap cache).  If the page
> - * is found, it is returned in retpage.  Otherwise, a page is allocated,
> - * added to the swap cache, and returned in retpage.
> - *
> - * If success, the swap cache page is returned in retpage
> - * Returns ZSWAP_SWAPCACHE_EXIST if page was already in the swap cache
> - * Returns ZSWAP_SWAPCACHE_NEW if the new page needs to be populated,
> - *     the new page is added to swapcache and locked
> - * Returns ZSWAP_SWAPCACHE_FAIL on error
> - */
> -static int zswap_get_swap_cache_page(swp_entry_t entry,
> -				struct page **retpage)
> -{
> -	struct page *found_page, *new_page = NULL;
> -	struct address_space *swapper_space = swap_address_space(entry);
> -	int err;
> -
> -	*retpage = NULL;
> -	do {
> -		/*
> -		 * First check the swap cache.  Since this is normally
> -		 * called after lookup_swap_cache() failed, re-calling
> -		 * that would confuse statistics.
> -		 */
> -		found_page = find_get_page(swapper_space, entry.val);
> -		if (found_page)
> -			break;
> -
> -		/*
> -		 * Get a new page to read into from swap.
> -		 */
> -		if (!new_page) {
> -			new_page = alloc_page(GFP_KERNEL);
> -			if (!new_page)
> -				break; /* Out of memory */
> -		}
> -
> -		/*
> -		 * call radix_tree_preload() while we can wait.
> -		 */
> -		err = radix_tree_preload(GFP_KERNEL);
> -		if (err)
> -			break;
> -
> -		/*
> -		 * Swap entry may have been freed since our caller observed it.
> -		 */
> -		err = swapcache_prepare(entry);
> -		if (err == -EEXIST) { /* seems racy */
> -			radix_tree_preload_end();
> -			continue;
> -		}
> -		if (err) { /* swp entry is obsolete ? */
> -			radix_tree_preload_end();
> -			break;
> -		}
> -
> -		/* May fail (-ENOMEM) if radix-tree node allocation failed. */
> -		__set_page_locked(new_page);
> -		SetPageSwapBacked(new_page);
> -		err = __add_to_swap_cache(new_page, entry);
> -		if (likely(!err)) {
> -			radix_tree_preload_end();
> -			lru_cache_add_anon(new_page);
> -			*retpage = new_page;
> -			return ZSWAP_SWAPCACHE_NEW;
> -		}
> -		radix_tree_preload_end();
> -		ClearPageSwapBacked(new_page);
> -		__clear_page_locked(new_page);
> -		/*
> -		 * add_to_swap_cache() doesn't return -EEXIST, so we can safely
> -		 * clear SWAP_HAS_CACHE flag.
> -		 */
> -		swapcache_free(entry, NULL);
> -	} while (err != -ENOMEM);
> -
> -	if (new_page)
> -		page_cache_release(new_page);
> -	if (!found_page)
> -		return ZSWAP_SWAPCACHE_FAIL;
> -	*retpage = found_page;
> -	return ZSWAP_SWAPCACHE_EXIST;
> -}
>  
>  /*
> - * Attempts to free an entry by adding a page to the swap cache,
> - * decompressing the entry data into the page, and issuing a
> - * bio write to write the page back to the swap device.
> - *
> - * This can be thought of as a "resumed writeback" of the page
> - * to the swap device.  We are basically resuming the same swap
> - * writeback path that was intercepted with the frontswap_store()
> - * in the first place.  After the page has been decompressed into
> - * the swap cache, the compressed version stored by zswap can be
> - * freed.
> + * This is called from zbud to remove an entry that is being evicted.
>   */
> -static int zswap_writeback_entry(struct zbud_pool *pool, unsigned long handle)
> +static int zswap_evict_entry(struct zbud_pool *pool, unsigned long handle)
>  {
>  	struct zswap_header *zhdr;
>  	swp_entry_t swpentry;
>  	struct zswap_tree *tree;
>  	pgoff_t offset;
>  	struct zswap_entry *entry;
> -	struct page *page;
> -	u8 *src, *dst;
> -	unsigned int dlen;
> -	int ret;
> -	struct writeback_control wbc = {
> -		.sync_mode = WB_SYNC_NONE,
> -	};
>  
>  	/* extract swpentry from data */
>  	zhdr = zbud_map(pool, handle);
> @@ -547,89 +433,30 @@ static int zswap_writeback_entry(struct zbud_pool *pool, unsigned long handle)
>  	offset = swp_offset(swpentry);
>  	BUG_ON(pool != tree->pool);
>  
> -	/* find and ref zswap entry */
> +	/* find zswap entry */
>  	spin_lock(&tree->lock);
> -	entry = zswap_entry_find_get(&tree->rbroot, offset);
> +	entry = zswap_rb_search(&tree->rbroot, offset);
>  	if (!entry) {
>  		/* entry was invalidated */
>  		spin_unlock(&tree->lock);
>  		return 0;
>  	}
> -	spin_unlock(&tree->lock);
>  	BUG_ON(offset != entry->offset);
>  
> -	/* try to allocate swap cache page */
> -	switch (zswap_get_swap_cache_page(swpentry, &page)) {
> -	case ZSWAP_SWAPCACHE_FAIL: /* no memory or invalidate happened */
> -		ret = -ENOMEM;
> -		goto fail;
> -
> -	case ZSWAP_SWAPCACHE_EXIST:
> -		/* page is already in the swap cache, ignore for now */
> -		page_cache_release(page);
> -		ret = -EEXIST;
> -		goto fail;
> -
> -	case ZSWAP_SWAPCACHE_NEW: /* page is locked */
> -		/* decompress */
> -		dlen = PAGE_SIZE;
> -		src = (u8 *)zbud_map(tree->pool, entry->handle) +
> -			sizeof(struct zswap_header);
> -		dst = kmap_atomic(page);
> -		ret = zswap_comp_op(ZSWAP_COMPOP_DECOMPRESS, src,
> -				entry->length, dst, &dlen);
> -		kunmap_atomic(dst);
> -		zbud_unmap(tree->pool, entry->handle);
> -		BUG_ON(ret);
> -		BUG_ON(dlen != PAGE_SIZE);
> -
> -		/* page is up to date */
> -		SetPageUptodate(page);
> -	}
> -
> -	/* move it to the tail of the inactive list after end_writeback */
> -	SetPageReclaim(page);
> -
> -	/* start writeback */
> -	__swap_writepage(page, &wbc, end_swap_bio_write);
> -	page_cache_release(page);
> -	zswap_written_back_pages++;
> -
> -	spin_lock(&tree->lock);
> -	/* drop local reference */
> +	/* drop initial reference */
>  	zswap_entry_put(tree, entry);
>  
> -	/*
> -	* There are three possible situations for entry here:
> -	* (1) refcount is 1(normal case),  entry is valid and on the tree
> -	* (2) refcount is 0, entry is freed and not on the tree
> -	*     because invalidate happened during writeback
> -	* (3) refcount is 2, entry is in use by load, prevent eviction
> -	*/
> -	if (likely(entry->refcount > 0))
> -		zswap_entry_put(tree, entry);
> +	/* if still in use by load(), do not allow eviction */
>  	if (unlikely(entry->refcount > 0)) {
>  		spin_unlock(&tree->lock);
>  		return -EAGAIN;
>  	}
> -	spin_unlock(&tree->lock);
>  
> -	goto end;
> +	zswap_evicted_pages++;
>  
> -	/*
> -	* if we get here due to ZSWAP_SWAPCACHE_EXIST
> -	* a load may happening concurrently
> -	* it is safe and okay to not free the entry
> -	* if we free the entry in the following put
> -	* it it either okay to return !0
> -	*/
> -fail:
> -	spin_lock(&tree->lock);
> -	zswap_entry_put(tree, entry);
>  	spin_unlock(&tree->lock);
>  
> -end:
> -	return ret;
> +	return 0;
>  }
>  
>  /*********************************
> @@ -746,7 +573,7 @@ static int zswap_frontswap_load(unsigned type, pgoff_t offset,
>  	spin_lock(&tree->lock);
>  	entry = zswap_entry_find_get(&tree->rbroot, offset);
>  	if (!entry) {
> -		/* entry was written back */
> +		/* entry was evicted */
>  		spin_unlock(&tree->lock);
>  		return -1;
>  	}
> @@ -780,7 +607,7 @@ static void zswap_frontswap_invalidate_page(unsigned type, pgoff_t offset)
>  	spin_lock(&tree->lock);
>  	entry = zswap_rb_search(&tree->rbroot, offset);
>  	if (!entry) {
> -		/* entry was written back */
> +		/* entry was evicted */
>  		spin_unlock(&tree->lock);
>  		return;
>  	}
> @@ -813,7 +640,7 @@ static void zswap_frontswap_invalidate_area(unsigned type)
>  }
>  
>  static struct zbud_ops zswap_zbud_ops = {
> -	.evict = zswap_writeback_entry
> +	.evict = zswap_evict_entry
>  };
>  
>  static void zswap_frontswap_init(unsigned type)
> @@ -872,8 +699,8 @@ static int __init zswap_debugfs_init(void)
>  			zswap_debugfs_root, &zswap_reject_kmemcache_fail);
>  	debugfs_create_u64("reject_compress_poor", S_IRUGO,
>  			zswap_debugfs_root, &zswap_reject_compress_poor);
> -	debugfs_create_u64("written_back_pages", S_IRUGO,
> -			zswap_debugfs_root, &zswap_written_back_pages);
> +	debugfs_create_u64("evicted_pages", S_IRUGO,
> +			zswap_debugfs_root, &zswap_evicted_pages);
>  	debugfs_create_u64("duplicate_entry", S_IRUGO,
>  			zswap_debugfs_root, &zswap_duplicate_entry);
>  	debugfs_create_u64("pool_pages", S_IRUGO,
> @@ -918,6 +745,7 @@ static int __init init_zswap(void)
>  		pr_err("per-cpu initialization failed\n");
>  		goto pcpufail;
>  	}
> +	frontswap_writethrough(true);
>  	frontswap_register_ops(&zswap_frontswap_ops);
>  	if (zswap_debugfs_init())
>  		pr_warn("debugfs initialization failed\n");
> -- 
> 1.8.3.1
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
