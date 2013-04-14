Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 820346B0037
	for <linux-mm@kvack.org>; Sat, 13 Apr 2013 20:56:26 -0400 (EDT)
Date: Sun, 14 Apr 2013 01:45:06 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCHv9 4/8] zswap: add to mm/
Message-ID: <20130414004506.GD1330@suse.de>
References: <1365617940-21623-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1365617940-21623-5-git-send-email-sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1365617940-21623-5-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Hugh Dickens <hughd@google.com>, Paul Mackerras <paulus@samba.org>, Heesub Shin <heesub.shin@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On Wed, Apr 10, 2013 at 01:18:56PM -0500, Seth Jennings wrote:
> zswap is a thin compression backend for frontswap. It receives
> pages from frontswap and attempts to store them in a compressed
> memory pool, resulting in an effective partial memory reclaim and
> dramatically reduced swap device I/O.
> 
> Additionally, in most cases, pages can be retrieved from this
> compressed store much more quickly than reading from tradition
> swap devices resulting in faster performance for many workloads.
> 

Except in the case where the zswap pool is externally fragmented, occupies
its maximum configured size and a workload that would otherwise have fit
in memory gets pushed to swap.

Yes, it's a corner case but the changelog portrays zswap as an unconditional
win and while it certainly is going to help some cases, it won't help
them all.

> This patch adds the zswap driver to mm/
> 
> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
> ---
>  mm/Kconfig  |  15 ++
>  mm/Makefile |   1 +
>  mm/zswap.c  | 665 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 681 insertions(+)
>  create mode 100644 mm/zswap.c
> 
> diff --git a/mm/Kconfig b/mm/Kconfig
> index aa054fc..36d93b0 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -495,3 +495,18 @@ config PGTABLE_MAPPING
>  
>  	  You can check speed with zsmalloc benchmark[1].
>  	  [1] https://github.com/spartacus06/zsmalloc
> +
> +config ZSWAP
> +	bool "In-kernel swap page compression"
> +	depends on FRONTSWAP && CRYPTO
> +	select CRYPTO_LZO
> +	select ZSMALLOC
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
> index 0f6ef0a..1e0198f 100644
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
> index 0000000..db283c4
> --- /dev/null
> +++ b/mm/zswap.c
> @@ -0,0 +1,665 @@
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
> +#include <linux/zsmalloc.h>
> +
> +/*********************************
> +* statistics
> +**********************************/
> +/* Number of memory pages used by the compressed pool */
> +static atomic_t zswap_pool_pages = ATOMIC_INIT(0);
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
> +static u64 zswap_reject_compress_poor;
> +static u64 zswap_reject_zsmalloc_fail;
> +static u64 zswap_reject_kmemcache_fail;
> +static u64 zswap_duplicate_entry;
> +

Ok. Initially I thought "vmstat" but it would be overkill in this case
and the fact zswap can be a module would be a problem.

> +/*********************************
> +* tunables
> +**********************************/
> +/* Enable/disable zswap (disabled by default, fixed at boot for now) */
> +static bool zswap_enabled;
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

This has some potentially interesting NUMA characteristics.
The location of the allocated pages will depend on the process that first
allocated the page. As the pages can then be used by remote processes,
there may be increased remote accesses when accessing zswap.
Furthermore, if zone_reclaim_mode is enabled and allowed to swap it
could setup a weird situation whereby a process pushes itself fully into
zswap trying to reclaim local memory and instead pushing itself into
zswap on the local node.

If this is every reported as a problem then a workaround is to always
allocate zswap pages round-robin between online nodes.

> +/*
> + * Maximum compression ratio, as as percentage, for an acceptable

s/as as/as a/

> + * compressed page. Any pages that do not compress by at least
> + * this ratio will be rejected.
> +*/
> +static unsigned int zswap_max_compression_ratio = 80;
> +module_param_named(max_compression_ratio,
> +			zswap_max_compression_ratio, uint, 0644);
> +
> +/*********************************
> +* compression functions
> +**********************************/
> +/* per-cpu compression transforms */
> +static struct crypto_comp * __percpu *zswap_comp_pcpu_tfms;
> +
> +enum comp_op {
> +	ZSWAP_COMPOP_COMPRESS,
> +	ZSWAP_COMPOP_DECOMPRESS
> +};
> +
> +static int zswap_comp_op(enum comp_op op, const u8 *src, unsigned int slen,
> +				u8 *dst, unsigned int *dlen)
> +{
> +	struct crypto_comp *tfm;
> +	int ret;
> +
> +	tfm = *per_cpu_ptr(zswap_comp_pcpu_tfms, get_cpu());

It's always the local CPU so why not get_cpu_var()?

> +	switch (op) {
> +	case ZSWAP_COMPOP_COMPRESS:
> +		ret = crypto_comp_compress(tfm, src, slen, dst, dlen);
> +		break;
> +	case ZSWAP_COMPOP_DECOMPRESS:
> +		ret = crypto_comp_decompress(tfm, src, slen, dst, dlen);
> +		break;
> +	default:
> +		ret = -EINVAL;
> +	}
> +
> +	put_cpu();
> +	return ret;
> +}
> +
> +static int __init zswap_comp_init(void)
> +{
> +	if (!crypto_has_comp(zswap_compressor, 0, 0)) {
> +		pr_info("%s compressor not available\n", zswap_compressor);
> +		/* fall back to default compressor */
> +		zswap_compressor = ZSWAP_COMPRESSOR_DEFAULT;
> +		if (!crypto_has_comp(zswap_compressor, 0, 0))
> +			/* can't even load the default compressor */
> +			return -ENODEV;
> +	}
> +	pr_info("using %s compressor\n", zswap_compressor);
> +
> +	/* alloc percpu transforms */
> +	zswap_comp_pcpu_tfms = alloc_percpu(struct crypto_comp *);
> +	if (!zswap_comp_pcpu_tfms)
> +		return -ENOMEM;
> +	return 0;
> +}
> +
> +static void zswap_comp_exit(void)
> +{
> +	/* free percpu transforms */
> +	if (zswap_comp_pcpu_tfms)
> +		free_percpu(zswap_comp_pcpu_tfms);
> +}
> +
> +/*********************************
> +* data structures
> +**********************************/
> +struct zswap_entry {
> +	struct rb_node rbnode;
> +	unsigned type;
> +	pgoff_t offset;
> +	unsigned long handle;
> +	unsigned int length;
> +};

Document that the types and offset are from frontswap and the handle is
an opaque type from zsmalloc. This indicates that zswap is hard-coded
against zsmalloc but so far I do not believe I have seen anything that
forces it to be and allow either zbud or zsmalloc to be pluggable.

> +
> +struct zswap_tree {
> +	struct rb_root rbroot;
> +	spinlock_t lock;
> +	struct zs_pool *pool;
> +};
> +
> +static struct zswap_tree *zswap_trees[MAX_SWAPFILES];
> +
> +/*********************************
> +* zswap entry functions
> +**********************************/
> +#define ZSWAP_KMEM_CACHE_NAME "zswap_entry_cache"

heh, it's only used once and it's not exactly a magic number. Seems
overkill for a #define

> +static struct kmem_cache *zswap_entry_cache;
> +
> +static inline int zswap_entry_cache_create(void)
> +{

No need to declare it inline, compiler will figure it out. Also should
return bool.

> +	zswap_entry_cache =
> +		kmem_cache_create(ZSWAP_KMEM_CACHE_NAME,
> +			sizeof(struct zswap_entry), 0, 0, NULL);
> +	return (zswap_entry_cache == NULL);
> +}
> +
> +static inline void zswap_entry_cache_destory(void)
> +{
> +	kmem_cache_destroy(zswap_entry_cache);
> +}
> +
> +static inline struct zswap_entry *zswap_entry_cache_alloc(gfp_t gfp)
> +{
> +	struct zswap_entry *entry;
> +	entry = kmem_cache_alloc(zswap_entry_cache, gfp);
> +	if (!entry)
> +		return NULL;

No need to check !entry, just return it.

> +	return entry;
> +}
> +
> +static inline void zswap_entry_cache_free(struct zswap_entry *entry)
> +{
> +	kmem_cache_free(zswap_entry_cache, entry);
> +}
> +
> +/*********************************
> +* rbtree functions
> +**********************************/
> +static struct zswap_entry *zswap_rb_search(struct rb_root *root, pgoff_t offset)
> +{
> +	struct rb_node *node = root->rb_node;
> +	struct zswap_entry *entry;
> +
> +	while (node) {
> +		entry = rb_entry(node, struct zswap_entry, rbnode);
> +		if (entry->offset > offset)
> +			node = node->rb_left;
> +		else if (entry->offset < offset)
> +			node = node->rb_right;
> +		else
> +			return entry;
> +	}
> +	return NULL;
> +}
> +
> +/*
> + * In the case that a entry with the same offset is found, it a pointer to
> + * the existing entry is stored in dupentry and the function returns -EEXIST
> +*/
> +static int zswap_rb_insert(struct rb_root *root, struct zswap_entry *entry,
> +			struct zswap_entry **dupentry)
> +{
> +	struct rb_node **link = &root->rb_node, *parent = NULL;
> +	struct zswap_entry *myentry;
> +
> +	while (*link) {
> +		parent = *link;
> +		myentry = rb_entry(parent, struct zswap_entry, rbnode);
> +		if (myentry->offset > entry->offset)
> +			link = &(*link)->rb_left;
> +		else if (myentry->offset < entry->offset)
> +			link = &(*link)->rb_right;
> +		else {
> +			*dupentry = myentry;
> +			return -EEXIST;
> +		}
> +	}
> +	rb_link_node(&entry->rbnode, parent, link);
> +	rb_insert_color(&entry->rbnode, root);
> +	return 0;
> +}
> +
> +/*********************************
> +* per-cpu code
> +**********************************/
> +static DEFINE_PER_CPU(u8 *, zswap_dstmem);
> +

That deserves a comment. It per-cpu buffers for compressing or
decompressing data.


> +static int __zswap_cpu_notifier(unsigned long action, unsigned long cpu)
> +{
> +	struct crypto_comp *tfm;
> +	u8 *dst;
> +
> +	switch (action) {
> +	case CPU_UP_PREPARE:
> +		tfm = crypto_alloc_comp(zswap_compressor, 0, 0);
> +		if (IS_ERR(tfm)) {
> +			pr_err("can't allocate compressor transform\n");
> +			return NOTIFY_BAD;
> +		}
> +		*per_cpu_ptr(zswap_comp_pcpu_tfms, cpu) = tfm;
> +		dst = kmalloc(PAGE_SIZE * 2, GFP_KERNEL);
> +		if (!dst) {
> +			pr_err("can't allocate compressor buffer\n");
> +			crypto_free_comp(tfm);
> +			*per_cpu_ptr(zswap_comp_pcpu_tfms, cpu) = NULL;
> +			return NOTIFY_BAD;
> +		}
> +		per_cpu(zswap_dstmem, cpu) = dst;
> +		break;
> +	case CPU_DEAD:
> +	case CPU_UP_CANCELED:
> +		tfm = *per_cpu_ptr(zswap_comp_pcpu_tfms, cpu);
> +		if (tfm) {
> +			crypto_free_comp(tfm);
> +			*per_cpu_ptr(zswap_comp_pcpu_tfms, cpu) = NULL;
> +		}
> +		dst = per_cpu(zswap_dstmem, cpu);
> +		if (dst) {
> +			kfree(dst);
> +			per_cpu(zswap_dstmem, cpu) = NULL;
> +		}
> +		break;
> +	default:
> +		break;
> +	}
> +	return NOTIFY_OK;
> +}
> +
> +static int zswap_cpu_notifier(struct notifier_block *nb,
> +				unsigned long action, void *pcpu)
> +{
> +	unsigned long cpu = (unsigned long)pcpu;
> +	return __zswap_cpu_notifier(action, cpu);
> +}
> +
> +static struct notifier_block zswap_cpu_notifier_block = {
> +	.notifier_call = zswap_cpu_notifier
> +};
> +
> +static int zswap_cpu_init(void)
> +{
> +	unsigned long cpu;
> +
> +	get_online_cpus();
> +	for_each_online_cpu(cpu)
> +		if (__zswap_cpu_notifier(CPU_UP_PREPARE, cpu) != NOTIFY_OK)
> +			goto cleanup;
> +	register_cpu_notifier(&zswap_cpu_notifier_block);
> +	put_online_cpus();
> +	return 0;
> +
> +cleanup:
> +	for_each_online_cpu(cpu)
> +		__zswap_cpu_notifier(CPU_UP_CANCELED, cpu);
> +	put_online_cpus();
> +	return -ENOMEM;
> +}
> +
> +/*********************************
> +* zsmalloc callbacks
> +**********************************/
> +static mempool_t *zswap_page_pool;
> +
> +static inline unsigned int zswap_max_pool_pages(void)
> +{
> +	return zswap_max_pool_percent * totalram_pages / 100;
> +}
> +
> +static inline int zswap_page_pool_create(void)
> +{
> +	/* TODO: dynamically size mempool */
> +	zswap_page_pool = mempool_create_page_pool(256, 0);
> +	if (!zswap_page_pool)
> +		return -ENOMEM;
> +	return 0;
> +}
> +
> +static inline void zswap_page_pool_destroy(void)
> +{
> +	mempool_destroy(zswap_page_pool);
> +}
> +
> +static struct page *zswap_alloc_page(gfp_t flags)
> +{
> +	struct page *page;
> +
> +	if (atomic_read(&zswap_pool_pages) >= zswap_max_pool_pages()) {
> +		zswap_pool_limit_hit++;
> +		return NULL;
> +	}
> +	page = mempool_alloc(zswap_page_pool, flags);
> +	if (page)
> +		atomic_inc(&zswap_pool_pages);
> +	return page;
> +}
> +
> +static void zswap_free_page(struct page *page)
> +{
> +	if (!page)
> +		return;
> +	mempool_free(page, zswap_page_pool);
> +	atomic_dec(&zswap_pool_pages);
> +}

Again I find it odd that the mempool is here instead of within zsmalloc
itself. It's also not superclear why you used mempool instead of just
alloc_page/free_page


> +
> +static struct zs_ops zswap_zs_ops = {
> +	.alloc = zswap_alloc_page,
> +	.free = zswap_free_page
> +};
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
> +	unsigned int dlen = PAGE_SIZE;
> +	unsigned long handle;
> +	char *buf;
> +	u8 *src, *dst;
> +
> +	if (!tree) {
> +		ret = -ENODEV;
> +		goto reject;
> +	}
> +
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

Why kmap_atomic? We do not appear to be in an atomic context here and
you've already disabled preempt for the compression op.

> +	ret = zswap_comp_op(ZSWAP_COMPOP_COMPRESS, src, PAGE_SIZE, dst, &dlen);
> +	kunmap_atomic(src);
> +	if (ret) {
> +		ret = -EINVAL;
> +		goto putcpu;
> +	}
> +	if ((dlen * 100 / PAGE_SIZE) > zswap_max_compression_ratio) {
> +		zswap_reject_compress_poor++;
> +		ret = -E2BIG;
> +		goto putcpu;
> +	}
> +
> +	/* store */
> +	handle = zs_malloc(tree->pool, dlen,
> +		__GFP_NORETRY | __GFP_HIGHMEM | __GFP_NOMEMALLOC |
> +			__GFP_NOWARN);
> +	if (!handle) {
> +		zswap_reject_zsmalloc_fail++;
> +		ret = -ENOMEM;
> +		goto putcpu;
> +	}
> +

This is an aging inversion problem. Once zswap is full, the newest pages
are written to swap instead of old zswap pages and freeing up some
space. This means two things

1. Once zswap is full, it's performance degrades immediately to just
   being even worst than traditional swap except we're doing all the
   swapping but have 20% (by default) less physical memory to work with.

2. zswap is vunerable to a DOS by a process starting, allocating a
   buffer that is RAM + max zswap size to fill zswap, freeing its remaining
   in-core pages and then sleeping forever

zswap pages should also be maintained on a LRU with old zswap pages written
to backing storage when it's full. A logical follow-on then would be that
the size of the zswap pool can be dynamically shrunk to free physical RAM
if the refault rate between zswap and normal RAM is low.

> +	buf = zs_map_object(tree->pool, handle, ZS_MM_WO);
> +	memcpy(buf, dst, dlen);
> +	zs_unmap_object(tree->pool, handle);
> +	put_cpu_var(zswap_dstmem);
> +
> +	/* populate entry */
> +	entry->type = type;
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
> +
> +			/* remove from rbtree */
> +			rb_erase(&dupentry->rbnode, &tree->rbroot);
> +
> +			/* free */
> +			zs_free(tree->pool, dupentry->handle);
> +			zswap_entry_cache_free(dupentry);
> +			atomic_dec(&zswap_stored_pages);
> +		}
> +	} while (ret == -EEXIST);
> +	spin_unlock(&tree->lock);
> +
> +	/* update stats */
> +	atomic_inc(&zswap_stored_pages);
> +
> +	return 0;
> +
> +putcpu:
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
> +
> +	/* find */
> +	spin_lock(&tree->lock);
> +	entry = zswap_rb_search(&tree->rbroot, offset);
> +	spin_unlock(&tree->lock);
> +
> +	/* decompress */
> +	dlen = PAGE_SIZE;
> +	src = zs_map_object(tree->pool, entry->handle, ZS_MM_RO);
> +	dst = kmap_atomic(page);
> +	zswap_comp_op(ZSWAP_COMPOP_DECOMPRESS, src, entry->length,
> +		dst, &dlen);
> +	kunmap_atomic(dst);
> +	zs_unmap_object(tree->pool, entry->handle);
> +
> +	return 0;
> +}
> +
> +/* invalidates a single page */
> +static void zswap_frontswap_invalidate_page(unsigned type, pgoff_t offset)
> +{
> +	struct zswap_tree *tree = zswap_trees[type];
> +	struct zswap_entry *entry;
> +
> +	/* find */
> +	spin_lock(&tree->lock);
> +	entry = zswap_rb_search(&tree->rbroot, offset);
> +
> +	/* remove from rbtree */
> +	rb_erase(&entry->rbnode, &tree->rbroot);
> +	spin_unlock(&tree->lock);
> +
> +	/* free */
> +	zs_free(tree->pool, entry->handle);
> +	zswap_entry_cache_free(entry);
> +	atomic_dec(&zswap_stored_pages);
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
> +		zs_free(tree->pool, entry->handle);
> +		zswap_entry_cache_free(entry);
> +	}
> +	tree->rbroot = RB_ROOT;
> +	spin_unlock(&tree->lock);
> +}
> +
> +/* NOTE: this is called in atomic context from swapon and must not sleep */
> +static void zswap_frontswap_init(unsigned type)
> +{
> +	struct zswap_tree *tree;
> +
> +	tree = kzalloc(sizeof(struct zswap_tree), GFP_ATOMIC);
> +	if (!tree)
> +		goto err;
> +	tree->pool = zs_create_pool(GFP_NOWAIT, &zswap_zs_ops);
> +	if (!tree->pool)
> +		goto freetree;
> +	tree->rbroot = RB_ROOT;
> +	spin_lock_init(&tree->lock);
> +	zswap_trees[type] = tree;
> +	return;
> +

Ok I think. I didn't read this as carefully because I assumed that it
would either work or blow up spectacularly and there was little scope
for being clever.

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
> +	debugfs_create_u64("reject_zsmalloc_fail", S_IRUGO,
> +			zswap_debugfs_root, &zswap_reject_zsmalloc_fail);
> +	debugfs_create_u64("reject_kmemcache_fail", S_IRUGO,
> +			zswap_debugfs_root, &zswap_reject_kmemcache_fail);
> +	debugfs_create_u64("reject_compress_poor", S_IRUGO,
> +			zswap_debugfs_root, &zswap_reject_compress_poor);
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
> +	if (zswap_page_pool_create()) {
> +		pr_err("page pool initialization failed\n");
> +		goto pagepoolfail;
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
> +	zswap_page_pool_destroy();
> +pagepoolfail:
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

Ok, so there are some problems in there.  For me, the zsmalloc fragmentation
issues are potentially the far scarier problem because unpredictable
performance characteristics tend to generate really painful bug reports
with difficult (if not impossible) to replicate problems. Those reports
are so painful in fact that I'm inclined to dig my heels in and make loud
noises unless an allocator with predictable performance characteritics
can also be used (presumably zbud) -- as a comparison point if nothing
else but also to have as a workaround for performance problems in zsmalloc.

It also looks like performance will fall off a cliff when zswap is full
but at least that's a predictable problem and easily explained to a
user. An LRU for zswap pages could always be implemented later with
bonus points if it uses refault rates to judge when the pool can be
shrunk more agressively to free physical RAM.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
