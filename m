Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 97C706B0032
	for <linux-mm@kvack.org>; Fri, 17 May 2013 12:54:30 -0400 (EDT)
Date: Fri, 17 May 2013 17:54:18 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCHv11 3/4] zswap: add to mm/
Message-ID: <20130517165418.GP11497@suse.de>
References: <1368448803-2089-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1368448803-2089-4-git-send-email-sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1368448803-2089-4-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@sr71.net>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Hugh Dickens <hughd@google.com>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On Mon, May 13, 2013 at 07:40:02AM -0500, Seth Jennings wrote:
> zswap is a thin compression backend for frontswap. It receives pages from
> frontswap and attempts to store them in a compressed memory pool, resulting in
> an effective partial memory reclaim and dramatically reduced swap device I/O.
> 

potentially reduces IO. No guarantees.

> Additionally, in most cases, pages can be retrieved from this compressed store
> much more quickly than reading from tradition swap devices resulting in faster
> performance for many workloads.
> 

While this is likely, it's also not necessarily true if the swap device
is particularly fast. Also, swap devices can be asynchronously written,
is the same true for zswap? I doubt it as I would expect the compression
operation to slow down pages being added to swap cache.

> It also has support for evicting swap pages that are currently compressed in
> zswap to the swap device on an LRU(ish) basis.

I know I initially suggested an LRU but don't worry about this thing
being an LRU too much. A FIFO list would be just fine as the pages are
presumably idle if they ended up in zswap in the first place.

> This functionality is very
> important and make zswap a true cache in that, once the cache is full or can't
> grow due to memory pressure, the oldest pages can be moved out of zswap to the
> swap device so newer pages can be compressed and stored in zswap.
> 
> This patch adds the zswap driver to mm/
> 
> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
> ---
>  mm/Kconfig  |   15 +
>  mm/Makefile |    1 +
>  mm/zswap.c  |  952 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 968 insertions(+)
>  create mode 100644 mm/zswap.c
> 
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 908f41b..4042e07 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -487,3 +487,18 @@ config ZBUD
>  	  While this design limits storage density, it has simple and
>  	  deterministic reclaim properties that make it preferable to a higher
>  	  density approach when reclaim will be used.  
> +
> +config ZSWAP
> +	bool "In-kernel swap page compression"
> +	depends on FRONTSWAP && CRYPTO
> +	select CRYPTO_LZO
> +	select ZBUD
> +	default n
> +	help
> +	  Zswap is a backend for the frontswap mechanism in the VMM.
> +	  It receives pages from frontswap and attempts to store them
> +	  in a compressed memory pool, resulting in an effective
> +	  partial memory reclaim.  In addition, pages and be retrieved
> +	  from this compressed store much faster than most tradition
> +	  swap devices resulting in reduced I/O and faster performance
> +	  for many workloads.
> diff --git a/mm/Makefile b/mm/Makefile
> index 95f0197..f008033 100644
> --- a/mm/Makefile
> +++ b/mm/Makefile
> @@ -32,6 +32,7 @@ obj-$(CONFIG_HAVE_MEMBLOCK) += memblock.o
>  obj-$(CONFIG_BOUNCE)	+= bounce.o
>  obj-$(CONFIG_SWAP)	+= page_io.o swap_state.o swapfile.o
>  obj-$(CONFIG_FRONTSWAP)	+= frontswap.o
> +obj-$(CONFIG_ZSWAP)	+= zswap.o
>  obj-$(CONFIG_HAS_DMA)	+= dmapool.o
>  obj-$(CONFIG_HUGETLBFS)	+= hugetlb.o
>  obj-$(CONFIG_NUMA) 	+= mempolicy.o
> diff --git a/mm/zswap.c b/mm/zswap.c
> new file mode 100644
> index 0000000..b1070ca
> --- /dev/null
> +++ b/mm/zswap.c
> @@ -0,0 +1,952 @@
> +/*
> + * zswap.c - zswap driver file
> + *
> + * zswap is a backend for frontswap that takes pages that are in the
> + * process of being swapped out and attempts to compress them and store
> + * them in a RAM-based memory pool.  This results in a significant I/O
> + * reduction on the real swap device and, in the case of a slow swap
> + * device, can also improve workload performance.
> + *
> + * Copyright (C) 2012  Seth Jennings <sjenning@linux.vnet.ibm.com>
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License
> + * as published by the Free Software Foundation; either version 2
> + * of the License, or (at your option) any later version.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> +*/
> +
> +#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> +
> +#include <linux/module.h>
> +#include <linux/cpu.h>
> +#include <linux/highmem.h>
> +#include <linux/slab.h>
> +#include <linux/spinlock.h>
> +#include <linux/types.h>
> +#include <linux/atomic.h>
> +#include <linux/frontswap.h>
> +#include <linux/rbtree.h>
> +#include <linux/swap.h>
> +#include <linux/crypto.h>
> +#include <linux/mempool.h>
> +#include <linux/zbud.h>
> +
> +#include <linux/mm_types.h>
> +#include <linux/page-flags.h>
> +#include <linux/swapops.h>
> +#include <linux/writeback.h>
> +#include <linux/pagemap.h>
> +
> +/*********************************
> +* statistics
> +**********************************/
> +/* Number of memory pages used by the compressed pool */
> +static atomic_t zswap_pool_pages = ATOMIC_INIT(0);

They underlying allocator should be tracking the number of physical
pages used, not this layer.

> +/* The number of compressed pages currently stored in zswap */
> +static atomic_t zswap_stored_pages = ATOMIC_INIT(0);
> +
> +/*
> + * The statistics below are not protected from concurrent access for
> + * performance reasons so they may not be a 100% accurate.  However,
> + * they do provide useful information on roughly how many times a
> + * certain event is occurring.
> +*/
> +static u64 zswap_pool_limit_hit;
> +static u64 zswap_written_back_pages;
> +static u64 zswap_reject_reclaim_fail;
> +static u64 zswap_reject_compress_poor;
> +static u64 zswap_reject_alloc_fail;
> +static u64 zswap_reject_kmemcache_fail;
> +static u64 zswap_duplicate_entry;
> +

Document what these mean.

> +/*********************************
> +* tunables
> +**********************************/
> +/* Enable/disable zswap (disabled by default, fixed at boot for now) */
> +static bool zswap_enabled;

read_mostly

> +module_param_named(enabled, zswap_enabled, bool, 0);
> +
> +/* Compressor to be used by zswap (fixed at boot for now) */
> +#define ZSWAP_COMPRESSOR_DEFAULT "lzo"
> +static char *zswap_compressor = ZSWAP_COMPRESSOR_DEFAULT;
> +module_param_named(compressor, zswap_compressor, charp, 0);
> +
> +/* The maximum percentage of memory that the compressed pool can occupy */
> +static unsigned int zswap_max_pool_percent = 20;
> +module_param_named(max_pool_percent,
> +			zswap_max_pool_percent, uint, 0644);
> +

This will need additional love in the future. If you have an 8 node machine
then zswap pool could completely exhaust a single NUMA node with this
parameter. This is pretty much a big fat hammer that stops zswap getting
compltely out of control and taking over the system but it'll need some
sort of sensible automatic resizing based on system activity in the future.
It's not an obstacle to merging because you have to start somewhere but
the fixed-pool size thing is fugly and you should plan on putting it down
in the future.

> +/*
> + * Maximum compression ratio, as as percentage, for an acceptable
> + * compressed page. Any pages that do not compress by at least
> + * this ratio will be rejected.
> +*/
> +static unsigned int zswap_max_compression_ratio = 80;
> +module_param_named(max_compression_ratio,
> +			zswap_max_compression_ratio, uint, 0644);
> +

I would be very surprised if a user wanted to tune this. What is a sensible
recommendation for it? I don't think you can give one because it depends
entirely on the workload and the current system state. A good value for
one day may be a bad choice the next day if a backup takes place or the
workload changes pattern frequently.  As there is no sensible recommendation
for this value, just don't expose it to userspace at all.

I guess you could apply the same critism to the suggestion that NCHUNKS
be tunable but that has only two settings really. The default and 2 if
the pool is continually fragmented.

> +/*********************************
> +* compression functions
> +**********************************/
> <SNIP>

I'm glossed over a lot of this. It looks fairly similar to what was reviewed
before and I'm assuming there are no major changes. Much of it is in the
category of "it'll either work or fail spectacularly early in the lifetime
of the system" and I'm assuming you tested this. Note that the comments
are out of sync with the structures. Fix that.

> +/*********************************
> +* helpers
> +**********************************/
> +static inline bool zswap_is_full(void)
> +{
> +	int pool_pages = atomic_read(&zswap_pool_pages);

Does this thing really have to be an atomic? Why not move it into the tree
structure, protect it with the tree lock and then sum the individual counts
when checking if zswap_is_full? It'll be a little race but not much more
so than using atomics outside of a lock like this.

> +	return (totalram_pages * zswap_max_pool_percent / 100 < pool_pages);
> +}
> +
> +/*
> + * Carries out the common pattern of freeing and entry's zsmalloc allocation,
> + * freeing the entry itself, and decrementing the number of stored pages.
> + */
> +static void zswap_free_entry(struct zswap_tree *tree, struct zswap_entry *entry)
> +{
> +	zbud_free(tree->pool, entry->handle);
> +	zswap_entry_cache_free(entry);
> +	atomic_dec(&zswap_stored_pages);
> +	atomic_set(&zswap_pool_pages, zbud_get_pool_size(tree->pool));
> +}
> +
> +/*********************************
> +* writeback code
> +**********************************/
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

Still not massively happy that this is duplicating code from
read_swap_cache_async(). It's just begging for trouble. I do not have
suggestions on how it can be done cleanly at this time because I haven't
put the effort in.

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
> +static int zswap_writeback_entry(struct zbud_pool *pool, unsigned long handle)
> +{
> +	struct zswap_header *zhdr;
> +	swp_entry_t swpentry;
> +	struct zswap_tree *tree;
> +	pgoff_t offset;
> +	struct zswap_entry *entry;
> +	struct page *page;
> +	u8 *src, *dst;
> +	unsigned int dlen;
> +	int ret, refcount;
> +	struct writeback_control wbc = {
> +		.sync_mode = WB_SYNC_NONE,
> +	};
> +
> +	/* extract swpentry from data */
> +	zhdr = zbud_map(pool, handle);
> +	swpentry = zhdr->swpentry; /* here */
> +	zbud_unmap(pool, handle);
> +	tree = zswap_trees[swp_type(swpentry)];

This is going to further solidify the use of PTEs to store the swap file
and offset for swap pages that Hugh complained about at LSF/MM. It's
unfortunate but it's not like there is queue of people waiting to fix
that particular problem :(

> +	offset = swp_offset(swpentry);
> +	BUG_ON(pool != tree->pool);
> +
> +	/* find and ref zswap entry */
> +	spin_lock(&tree->lock);
> +	entry = zswap_rb_search(&tree->rbroot, offset);
> +	if (!entry) {
> +		/* entry was invalidated */
> +		spin_unlock(&tree->lock);
> +		return 0;
> +	}
> +	zswap_entry_get(entry);
> +	spin_unlock(&tree->lock);
> +	BUG_ON(offset != entry->offset);
> +
> +	/* try to allocate swap cache page */
> +	switch (zswap_get_swap_cache_page(swpentry, &page)) {
> +	case ZSWAP_SWAPCACHE_NOMEM: /* no memory */
> +		ret = -ENOMEM;
> +		goto fail;
> +

Yikes. So it's possible to fail a zpage writeback? Can this livelock? I
expect you are protected by a combination of the 20% memory limitation
and that it is likely that *some* file pages can be reclaimed but this
is going to cause a bug report eventually. Consider using a mempool to
guarantee that some writeback progress can always be made.

> +	case ZSWAP_SWAPCACHE_EXIST: /* page is unlocked */
> +		/* page is already in the swap cache, ignore for now */
> +		page_cache_release(page);
> +		ret = -EEXIST;
> +		goto fail;
> +
> +	case ZSWAP_SWAPCACHE_NEW: /* page is locked */
> +		/* decompress */
> +		dlen = PAGE_SIZE;
> +		src = (u8 *)zbud_map(tree->pool, entry->handle) +
> +			sizeof(struct zswap_header);
> +		dst = kmap_atomic(page);
> +		ret = zswap_comp_op(ZSWAP_COMPOP_DECOMPRESS, src,
> +				entry->length, dst, &dlen);
> +		kunmap_atomic(dst);
> +		zbud_unmap(tree->pool, entry->handle);
> +		BUG_ON(ret);
> +		BUG_ON(dlen != PAGE_SIZE);
> +
> +		/* page is up to date */
> +		SetPageUptodate(page);
> +	}
> +
> +	/* start writeback */
> +	SetPageReclaim(page);
> +	__swap_writepage(page, &wbc, end_swap_bio_write);
> +	page_cache_release(page);
> +	zswap_written_back_pages++;
> +

SetPageReclaim? Why?. If the page is under writeback then why do you not
mark it as that? Do not free pages that are currently under writeback
obviously. It's likely that it was PageWriteback you wanted in zbud.c too.


> +	spin_lock(&tree->lock);
> +
> +	/* drop local reference */
> +	zswap_entry_put(entry);
> +	/* drop the initial reference from entry creation */
> +	refcount = zswap_entry_put(entry);
> +
> +	/*
> +	 * There are three possible values for refcount here:
> +	 * (1) refcount is 1, load is in progress, unlink from rbtree,
> +	 *     load will free
> +	 * (2) refcount is 0, (normal case) entry is valid,
> +	 *     remove from rbtree and free entry
> +	 * (3) refcount is -1, invalidate happened during writeback,
> +	 *     free entry
> +	 */
> +	if (refcount >= 0) {
> +		/* no invalidate yet, remove from rbtree */
> +		rb_erase(&entry->rbnode, &tree->rbroot);
> +	}
> +	spin_unlock(&tree->lock);
> +	if (refcount <= 0) {
> +		/* free the entry */
> +		zswap_free_entry(tree, entry);
> +		return 0;
> +	}
> +	return -EAGAIN;
> +
> +fail:
> +	spin_lock(&tree->lock);
> +	zswap_entry_put(entry);
> +	spin_unlock(&tree->lock);
> +	return ret;
> +}
> +
> +/*********************************
> +* frontswap hooks
> +**********************************/
> +/* attempts to compress and store an single page */
> +static int zswap_frontswap_store(unsigned type, pgoff_t offset,
> +				struct page *page)
> +{
> +	struct zswap_tree *tree = zswap_trees[type];
> +	struct zswap_entry *entry, *dupentry;
> +	int ret;
> +	unsigned int dlen = PAGE_SIZE, len;
> +	unsigned long handle;
> +	char *buf;
> +	u8 *src, *dst;
> +	struct zswap_header *zhdr;
> +
> +	if (!tree) {
> +		ret = -ENODEV;
> +		goto reject;
> +	}
> +
> +	/* reclaim space if needed */
> +	if (zswap_is_full()) {
> +		zswap_pool_limit_hit++;
> +		if (zbud_reclaim_page(tree->pool, 8)) {
> +			zswap_reject_reclaim_fail++;
> +			ret = -ENOMEM;
> +			goto reject;
> +		}
> +	}
> +

If the allocator layer handled the sizing limitations then you could defer
the size checks until it calls alloc_page. From a layering perspective
this would be a hell of a lot cleaner. As it is, this layer has excessive
knowledge of the zbud layer which feels wrong.

> +	/* allocate entry */
> +	entry = zswap_entry_cache_alloc(GFP_KERNEL);
> +	if (!entry) {
> +		zswap_reject_kmemcache_fail++;
> +		ret = -ENOMEM;
> +		goto reject;
> +	}
> +
> +	/* compress */
> +	dst = get_cpu_var(zswap_dstmem);
> +	src = kmap_atomic(page);
> +	ret = zswap_comp_op(ZSWAP_COMPOP_COMPRESS, src, PAGE_SIZE, dst, &dlen);
> +	kunmap_atomic(src);
> +	if (ret) {
> +		ret = -EINVAL;
> +		goto freepage;
> +	}
> +	len = dlen + sizeof(struct zswap_header);
> +	if ((len * 100 / PAGE_SIZE) > zswap_max_compression_ratio) {
> +		zswap_reject_compress_poor++;
> +		ret = -E2BIG;
> +		goto freepage;
> +	}
> +
> +	/* store */
> +	ret = zbud_alloc(tree->pool, len, __GFP_NORETRY | __GFP_NOWARN,
> +		&handle);

You do all the compression work and then check if you can store it?
It's harmless, but it's a little silly. Do the alloc work first and push
the sizing checks down a layer to the time you call alloc_pages.

> +	if (ret) {
> +		zswap_reject_alloc_fail++;
> +		goto freepage;
> +	}
> +	zhdr = zbud_map(tree->pool, handle);
> +	zhdr->swpentry = swp_entry(type, offset);
> +	buf = (u8 *)(zhdr + 1);
> +	memcpy(buf, dst, dlen);
> +	zbud_unmap(tree->pool, handle);
> +	put_cpu_var(zswap_dstmem);
> +
> +	/* populate entry */
> +	entry->offset = offset;
> +	entry->handle = handle;
> +	entry->length = dlen;
> +
> +	/* map */
> +	spin_lock(&tree->lock);
> +	do {
> +		ret = zswap_rb_insert(&tree->rbroot, entry, &dupentry);
> +		if (ret == -EEXIST) {
> +			zswap_duplicate_entry++;
> +			/* remove from rbtree */
> +			rb_erase(&dupentry->rbnode, &tree->rbroot);
> +			if (!zswap_entry_put(dupentry)) {
> +				/* free */
> +				zswap_free_entry(tree, dupentry);
> +			}
> +		}
> +	} while (ret == -EEXIST);
> +	spin_unlock(&tree->lock);
> +
> +	/* update stats */
> +	atomic_inc(&zswap_stored_pages);
> +	atomic_set(&zswap_pool_pages, zbud_get_pool_size(tree->pool));
> +
> +	return 0;
> +
> +freepage:
> +	put_cpu_var(zswap_dstmem);
> +	zswap_entry_cache_free(entry);
> +reject:
> +	return ret;
> +}
> +
> +/*
> + * returns 0 if the page was successfully decompressed
> + * return -1 on entry not found or error
> +*/
> +static int zswap_frontswap_load(unsigned type, pgoff_t offset,
> +				struct page *page)
> +{
> +	struct zswap_tree *tree = zswap_trees[type];
> +	struct zswap_entry *entry;
> +	u8 *src, *dst;
> +	unsigned int dlen;
> +	int refcount, ret;
> +
> +	/* find */
> +	spin_lock(&tree->lock);
> +	entry = zswap_rb_search(&tree->rbroot, offset);
> +	if (!entry) {
> +		/* entry was written back */
> +		spin_unlock(&tree->lock);
> +		return -1;
> +	}
> +	zswap_entry_get(entry);
> +	spin_unlock(&tree->lock);
> +
> +	/* decompress */
> +	dlen = PAGE_SIZE;
> +	src = (u8 *)zbud_map(tree->pool, entry->handle) +
> +			sizeof(struct zswap_header);
> +	dst = kmap_atomic(page);
> +	ret = zswap_comp_op(ZSWAP_COMPOP_DECOMPRESS, src, entry->length,
> +		dst, &dlen);
> +	kunmap_atomic(dst);
> +	zbud_unmap(tree->pool, entry->handle);
> +	BUG_ON(ret);
> +
> +	spin_lock(&tree->lock);
> +	refcount = zswap_entry_put(entry);
> +	if (likely(refcount)) {
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
> +	return 0;
> +}
> +
> +/* invalidates a single page */
> +static void zswap_frontswap_invalidate_page(unsigned type, pgoff_t offset)
> +{
> +	struct zswap_tree *tree = zswap_trees[type];
> +	struct zswap_entry *entry;
> +	int refcount;
> +
> +	/* find */
> +	spin_lock(&tree->lock);
> +	entry = zswap_rb_search(&tree->rbroot, offset);
> +	if (!entry) {
> +		/* entry was written back */
> +		spin_unlock(&tree->lock);
> +		return;
> +	}
> +
> +	/* remove from rbtree */
> +	rb_erase(&entry->rbnode, &tree->rbroot);
> +
> +	/* drop the initial reference from entry creation */
> +	refcount = zswap_entry_put(entry);
> +
> +	spin_unlock(&tree->lock);
> +
> +	if (refcount) {
> +		/* writeback in progress, writeback will free */
> +		return;
> +	}
> +
> +	/* free */
> +	zswap_free_entry(tree, entry);
> +}
> +
> +/* invalidates all pages for the given swap type */
> +static void zswap_frontswap_invalidate_area(unsigned type)
> +{
> +	struct zswap_tree *tree = zswap_trees[type];
> +	struct rb_node *node;
> +	struct zswap_entry *entry;
> +
> +	if (!tree)
> +		return;
> +
> +	/* walk the tree and free everything */
> +	spin_lock(&tree->lock);
> +	/*
> +	 * TODO: Even though this code should not be executed because
> +	 * the try_to_unuse() in swapoff should have emptied the tree,
> +	 * it is very wasteful to rebalance the tree after every
> +	 * removal when we are freeing the whole tree.
> +	 *
> +	 * If post-order traversal code is ever added to the rbtree
> +	 * implementation, it should be used here.
> +	 */
> +	while ((node = rb_first(&tree->rbroot))) {
> +		entry = rb_entry(node, struct zswap_entry, rbnode);
> +		rb_erase(&entry->rbnode, &tree->rbroot);
> +		zbud_free(tree->pool, entry->handle);
> +		zswap_entry_cache_free(entry);
> +		atomic_dec(&zswap_stored_pages);
> +	}
> +	tree->rbroot = RB_ROOT;
> +	spin_unlock(&tree->lock);
> +}
> +
> +static struct zbud_ops zswap_zbud_ops = {
> +	.evict = zswap_writeback_entry
> +};
> +
> +/* NOTE: this is called in atomic context from swapon and must not sleep */
> +static void zswap_frontswap_init(unsigned type)
> +{
> +	struct zswap_tree *tree;
> +
> +	tree = kzalloc(sizeof(struct zswap_tree), GFP_ATOMIC);
> +	if (!tree)
> +		goto err;
> +	tree->pool = zbud_create_pool(GFP_NOWAIT, &zswap_zbud_ops);
> +	if (!tree->pool)
> +		goto freetree;
> +	tree->rbroot = RB_ROOT;
> +	spin_lock_init(&tree->lock);
> +	tree->type = type;
> +	zswap_trees[type] = tree;
> +	return;
> +
> +freetree:
> +	kfree(tree);
> +err:
> +	pr_err("alloc failed, zswap disabled for swap type %d\n", type);
> +}
> +
> +static struct frontswap_ops zswap_frontswap_ops = {
> +	.store = zswap_frontswap_store,
> +	.load = zswap_frontswap_load,
> +	.invalidate_page = zswap_frontswap_invalidate_page,
> +	.invalidate_area = zswap_frontswap_invalidate_area,
> +	.init = zswap_frontswap_init
> +};
> +
> +/*********************************
> +* debugfs functions
> +**********************************/
> +#ifdef CONFIG_DEBUG_FS
> +#include <linux/debugfs.h>
> +
> +static struct dentry *zswap_debugfs_root;
> +
> +static int __init zswap_debugfs_init(void)
> +{
> +	if (!debugfs_initialized())
> +		return -ENODEV;
> +
> +	zswap_debugfs_root = debugfs_create_dir("zswap", NULL);
> +	if (!zswap_debugfs_root)
> +		return -ENOMEM;
> +
> +	debugfs_create_u64("pool_limit_hit", S_IRUGO,
> +			zswap_debugfs_root, &zswap_pool_limit_hit);
> +	debugfs_create_u64("reject_reclaim_fail", S_IRUGO,
> +			zswap_debugfs_root, &zswap_reject_reclaim_fail);
> +	debugfs_create_u64("reject_alloc_fail", S_IRUGO,
> +			zswap_debugfs_root, &zswap_reject_alloc_fail);
> +	debugfs_create_u64("reject_kmemcache_fail", S_IRUGO,
> +			zswap_debugfs_root, &zswap_reject_kmemcache_fail);
> +	debugfs_create_u64("reject_compress_poor", S_IRUGO,
> +			zswap_debugfs_root, &zswap_reject_compress_poor);
> +	debugfs_create_u64("written_back_pages", S_IRUGO,
> +			zswap_debugfs_root, &zswap_written_back_pages);
> +	debugfs_create_u64("duplicate_entry", S_IRUGO,
> +			zswap_debugfs_root, &zswap_duplicate_entry);
> +	debugfs_create_atomic_t("pool_pages", S_IRUGO,
> +			zswap_debugfs_root, &zswap_pool_pages);
> +	debugfs_create_atomic_t("stored_pages", S_IRUGO,
> +			zswap_debugfs_root, &zswap_stored_pages);
> +
> +	return 0;
> +}
> +
> +static void __exit zswap_debugfs_exit(void)
> +{
> +	debugfs_remove_recursive(zswap_debugfs_root);
> +}
> +#else
> +static inline int __init zswap_debugfs_init(void)
> +{
> +	return 0;
> +}
> +
> +static inline void __exit zswap_debugfs_exit(void) { }
> +#endif
> +
> +/*********************************
> +* module init and exit
> +**********************************/
> +static int __init init_zswap(void)
> +{
> +	if (!zswap_enabled)
> +		return 0;
> +
> +	pr_info("loading zswap\n");
> +	if (zswap_entry_cache_create()) {
> +		pr_err("entry cache creation failed\n");
> +		goto error;
> +	}
> +	if (zswap_comp_init()) {
> +		pr_err("compressor initialization failed\n");
> +		goto compfail;
> +	}
> +	if (zswap_cpu_init()) {
> +		pr_err("per-cpu initialization failed\n");
> +		goto pcpufail;
> +	}
> +	frontswap_register_ops(&zswap_frontswap_ops);
> +	if (zswap_debugfs_init())
> +		pr_warn("debugfs initialization failed\n");
> +	return 0;
> +pcpufail:
> +	zswap_comp_exit();
> +compfail:
> +	zswap_entry_cache_destory();
> +error:
> +	return -ENOMEM;
> +}
> +/* must be late so crypto has time to come up */
> +late_initcall(init_zswap);
> +
> +MODULE_LICENSE("GPL");
> +MODULE_AUTHOR("Seth Jennings <sjenning@linux.vnet.ibm.com>");
> +MODULE_DESCRIPTION("Compressed cache for swap pages");

I think there is still a lot of ugly in here so see what you can fix up
quickly. It's not mandatory to me that you get all this fixed up prior
to merging because it's long gone past the point where dealing with it
out-of-tree or in staging is going to work. By the time you address all the
concerns, it will have reached the point where it's too complex to review
and back to square one. At least if it's in mm/ it can be incrementally
developed but it should certainly start with a big fat warning that it's
a WIP. I wouldn't slap "ready for production" sticker on this just yet :/

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
