Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 559F36B009F
	for <linux-mm@kvack.org>; Tue, 14 May 2013 12:38:11 -0400 (EDT)
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Tue, 14 May 2013 10:38:05 -0600
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id B8A9C19D8067
	for <linux-mm@kvack.org>; Tue, 14 May 2013 10:36:06 -0600 (MDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4EGa3Z6141458
	for <linux-mm@kvack.org>; Tue, 14 May 2013 10:36:03 -0600
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4EGd1F0020855
	for <linux-mm@kvack.org>; Tue, 14 May 2013 10:39:02 -0600
Date: Tue, 14 May 2013 11:35:41 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: Re: [PATCHv11 3/4] zswap: add to mm/
Message-ID: <20130514163541.GC4024@medulla>
References: <1368448803-2089-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1368448803-2089-4-git-send-email-sjenning@linux.vnet.ibm.com>
 <15c5b1da-132a-4c9e-9f24-bc272d3865d5@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <15c5b1da-132a-4c9e-9f24-bc272d3865d5@default>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@sr71.net>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Hugh Dickens <hughd@google.com>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On Mon, May 13, 2013 at 03:31:42PM -0700, Dan Magenheimer wrote:
> > From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> > Subject: [PATCHv11 3/4] zswap: add to mm/
> > 
> > zswap is a thin compression backend for frontswap. It receives pages from
> > frontswap and attempts to store them in a compressed memory pool, resulting in
> > an effective partial memory reclaim and dramatically reduced swap device I/O.
> > 
> > Additionally, in most cases, pages can be retrieved from this compressed store
> > much more quickly than reading from tradition swap devices resulting in faster
> > performance for many workloads.
> > 
> > It also has support for evicting swap pages that are currently compressed in
> > zswap to the swap device on an LRU(ish) basis. This functionality is very
> > important and make zswap a true cache in that, once the cache is full or can't
> > grow due to memory pressure, the oldest pages can be moved out of zswap to the
> > swap device so newer pages can be compressed and stored in zswap.
> > 
> > This patch adds the zswap driver to mm/
> > 
> > Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
> 
> A couple of comments below...

Thanks for the review!

> 
> > ---
> >  mm/Kconfig  |   15 +
> >  mm/Makefile |    1 +
> >  mm/zswap.c  |  952 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
> >  3 files changed, 968 insertions(+)
> >  create mode 100644 mm/zswap.c
> > 
> > diff --git a/mm/Kconfig b/mm/Kconfig
> > index 908f41b..4042e07 100644
> > --- a/mm/Kconfig
> > +++ b/mm/Kconfig
> > @@ -487,3 +487,18 @@ config ZBUD
> >  	  While this design limits storage density, it has simple and
> >  	  deterministic reclaim properties that make it preferable to a higher
> >  	  density approach when reclaim will be used.
> > +
> > +config ZSWAP
> > +	bool "In-kernel swap page compression"
> > +	depends on FRONTSWAP && CRYPTO
> > +	select CRYPTO_LZO
> > +	select ZBUD
> > +	default n
> > +	help
> > +	  Zswap is a backend for the frontswap mechanism in the VMM.
> > +	  It receives pages from frontswap and attempts to store them
> > +	  in a compressed memory pool, resulting in an effective
> > +	  partial memory reclaim.  In addition, pages and be retrieved
> > +	  from this compressed store much faster than most tradition
> > +	  swap devices resulting in reduced I/O and faster performance
> > +	  for many workloads.
> > diff --git a/mm/Makefile b/mm/Makefile
> > index 95f0197..f008033 100644
> > --- a/mm/Makefile
> > +++ b/mm/Makefile
> > @@ -32,6 +32,7 @@ obj-$(CONFIG_HAVE_MEMBLOCK) += memblock.o
> >  obj-$(CONFIG_BOUNCE)	+= bounce.o
> >  obj-$(CONFIG_SWAP)	+= page_io.o swap_state.o swapfile.o
> >  obj-$(CONFIG_FRONTSWAP)	+= frontswap.o
> > +obj-$(CONFIG_ZSWAP)	+= zswap.o
> >  obj-$(CONFIG_HAS_DMA)	+= dmapool.o
> >  obj-$(CONFIG_HUGETLBFS)	+= hugetlb.o
> >  obj-$(CONFIG_NUMA) 	+= mempolicy.o
> > diff --git a/mm/zswap.c b/mm/zswap.c
> > new file mode 100644
> > index 0000000..b1070ca
> > --- /dev/null
> > +++ b/mm/zswap.c
> > @@ -0,0 +1,952 @@
> > +/*
> > + * zswap.c - zswap driver file
> > + *
> > + * zswap is a backend for frontswap that takes pages that are in the
> > + * process of being swapped out and attempts to compress them and store
> > + * them in a RAM-based memory pool.  This results in a significant I/O
> > + * reduction on the real swap device and, in the case of a slow swap
> > + * device, can also improve workload performance.
> > + *
> > + * Copyright (C) 2012  Seth Jennings <sjenning@linux.vnet.ibm.com>
> > + *
> > + * This program is free software; you can redistribute it and/or
> > + * modify it under the terms of the GNU General Public License
> > + * as published by the Free Software Foundation; either version 2
> > + * of the License, or (at your option) any later version.
> > + *
> > + * This program is distributed in the hope that it will be useful,
> > + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> > + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> > + * GNU General Public License for more details.
> > +*/
> > +
> > +#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> > +
> > +#include <linux/module.h>
> > +#include <linux/cpu.h>
> > +#include <linux/highmem.h>
> > +#include <linux/slab.h>
> > +#include <linux/spinlock.h>
> > +#include <linux/types.h>
> > +#include <linux/atomic.h>
> > +#include <linux/frontswap.h>
> > +#include <linux/rbtree.h>
> > +#include <linux/swap.h>
> > +#include <linux/crypto.h>
> > +#include <linux/mempool.h>
> > +#include <linux/zbud.h>
> > +
> > +#include <linux/mm_types.h>
> > +#include <linux/page-flags.h>
> > +#include <linux/swapops.h>
> > +#include <linux/writeback.h>
> > +#include <linux/pagemap.h>
> > +
> > +/*********************************
> > +* statistics
> > +**********************************/
> > +/* Number of memory pages used by the compressed pool */
> > +static atomic_t zswap_pool_pages = ATOMIC_INIT(0);
> > +/* The number of compressed pages currently stored in zswap */
> > +static atomic_t zswap_stored_pages = ATOMIC_INIT(0);
> > +
> > +/*
> > + * The statistics below are not protected from concurrent access for
> > + * performance reasons so they may not be a 100% accurate.  However,
> > + * they do provide useful information on roughly how many times a
> > + * certain event is occurring.
> > +*/
> > +static u64 zswap_pool_limit_hit;
> > +static u64 zswap_written_back_pages;
> > +static u64 zswap_reject_reclaim_fail;
> > +static u64 zswap_reject_compress_poor;
> > +static u64 zswap_reject_alloc_fail;
> > +static u64 zswap_reject_kmemcache_fail;
> > +static u64 zswap_duplicate_entry;
> > +
> > +/*********************************
> > +* tunables
> > +**********************************/
> > +/* Enable/disable zswap (disabled by default, fixed at boot for now) */
> > +static bool zswap_enabled;
> > +module_param_named(enabled, zswap_enabled, bool, 0);
> > +
> > +/* Compressor to be used by zswap (fixed at boot for now) */
> > +#define ZSWAP_COMPRESSOR_DEFAULT "lzo"
> > +static char *zswap_compressor = ZSWAP_COMPRESSOR_DEFAULT;
> > +module_param_named(compressor, zswap_compressor, charp, 0);
> > +
> > +/* The maximum percentage of memory that the compressed pool can occupy */
> > +static unsigned int zswap_max_pool_percent = 20;
> > +module_param_named(max_pool_percent,
> > +			zswap_max_pool_percent, uint, 0644);
> 
> This limit, along with the code that enforces it (by calling reclaim
> when the limit is reached), is IMHO questionable.  Is there any
> other kernel memory allocation that is constrained by a percentage
> of total memory rather than dynamically according to current
> system conditions?  As Mel pointed out (approx.), if this limit
> is reached by a zswap-storm and filled with pages of long-running,
> rarely-used processes, 20% of RAM (by default here) becomes forever
> clogged.

So there are two comments here 1) dynamic pool limit and 2) writeback
of pages in zswap that won't be faulted in or forced out by pressure.

Comment 1 feeds from the point of view that compressed pages should just be
another type of memory managed by the core MM.  While ideal, very hard to
implement in practice.  We are starting to realize that even the policy
governing to active vs inactive list is very hard to get right. Then shrinkers
add more complexity to the policy problem.  Throwing another type in the mix
would just that much more complex and hard to get right (assuming there even
_is_ a "right" policy for everyone in such a complex system).

This max_pool_percent policy is simple, works well, and provides a
deterministic policy that users can understand. Users can be assured that a
dynamic policy heuristic won't go nuts and allow the compressed pool to grow
unbounded or be so aggressively reclaimed that it offers no value.

Comment 2 I agree is an issue. I already have patches for a "periodic
writeback" functionality that starts to shrink the zswap pool via
writeback if zswap goes idle for a period of time.  This addresses
the issue with long-lived, never-accessed pages getting stuck in
zswap forever.

> 
> Zswap reclaim/writeback needs to be cognizant of (and perhaps driven
> by) system memory pressure, not some user-settable percentage.
> There's some tough policy questions that need to be answered here,
> perhaps not before zswap gets merged, but certainly before it
> gets enabled by default by distros.

Agreed that it shouldn't block merging.  I guess the distros will
have to make the call if the policy is good enough.

> 
> > +/*
> > + * Maximum compression ratio, as as percentage, for an acceptable
> > + * compressed page. Any pages that do not compress by at least
> > + * this ratio will be rejected.
> > +*/
> > +static unsigned int zswap_max_compression_ratio = 80;
> > +module_param_named(max_compression_ratio,
> > +			zswap_max_compression_ratio, uint, 0644);
> 
> Per earlier discussion, this number is actually derived
> from a zsmalloc constraint and doesn't necessarily apply
> to zbud.  And I don't think any mortal user or system
> administrator would have any idea what value to change
> this to or the potential impact of changing it.  IMHO
> it should be removed, or at least moved to and enforced
> by the specific allocator code.

Yes,  Bob pointed this out too.  I'm removing it.

Can I get your ack pending this change?

Thanks,
Seth

> 
> > +/*********************************
> > +* compression functions
> > +**********************************/
> > +/* per-cpu compression transforms */
> > +static struct crypto_comp * __percpu *zswap_comp_pcpu_tfms;
> > +
> > +enum comp_op {
> > +	ZSWAP_COMPOP_COMPRESS,
> > +	ZSWAP_COMPOP_DECOMPRESS
> > +};
> > +
> > +static int zswap_comp_op(enum comp_op op, const u8 *src, unsigned int slen,
> > +				u8 *dst, unsigned int *dlen)
> > +{
> > +	struct crypto_comp *tfm;
> > +	int ret;
> > +
> > +	tfm = *per_cpu_ptr(zswap_comp_pcpu_tfms, get_cpu());
> > +	switch (op) {
> > +	case ZSWAP_COMPOP_COMPRESS:
> > +		ret = crypto_comp_compress(tfm, src, slen, dst, dlen);
> > +		break;
> > +	case ZSWAP_COMPOP_DECOMPRESS:
> > +		ret = crypto_comp_decompress(tfm, src, slen, dst, dlen);
> > +		break;
> > +	default:
> > +		ret = -EINVAL;
> > +	}
> > +
> > +	put_cpu();
> > +	return ret;
> > +}
> > +
> > +static int __init zswap_comp_init(void)
> > +{
> > +	if (!crypto_has_comp(zswap_compressor, 0, 0)) {
> > +		pr_info("%s compressor not available\n", zswap_compressor);
> > +		/* fall back to default compressor */
> > +		zswap_compressor = ZSWAP_COMPRESSOR_DEFAULT;
> > +		if (!crypto_has_comp(zswap_compressor, 0, 0))
> > +			/* can't even load the default compressor */
> > +			return -ENODEV;
> > +	}
> > +	pr_info("using %s compressor\n", zswap_compressor);
> > +
> > +	/* alloc percpu transforms */
> > +	zswap_comp_pcpu_tfms = alloc_percpu(struct crypto_comp *);
> > +	if (!zswap_comp_pcpu_tfms)
> > +		return -ENOMEM;
> > +	return 0;
> > +}
> > +
> > +static void zswap_comp_exit(void)
> > +{
> > +	/* free percpu transforms */
> > +	if (zswap_comp_pcpu_tfms)
> > +		free_percpu(zswap_comp_pcpu_tfms);
> > +}
> > +
> > +/*********************************
> > +* data structures
> > +**********************************/
> > +/*
> > + * struct zswap_entry
> > + *
> > + * This structure contains the metadata for tracking a single compressed
> > + * page within zswap.
> > + *
> > + * rbnode - links the entry into red-black tree for the appropriate swap type
> > + * refcount - the number of outstanding reference to the entry. This is needed
> > + *            to protect against premature freeing of the entry by code
> > + *            concurent calls to load, invalidate, and writeback.  The lock
> > + *            for the zswap_tree structure that contains the entry must
> > + *            be held while changing the refcount.  Since the lock must
> > + *            be held, there is no reason to also make refcount atomic.
> > + * type - the swap type for the entry.  Used to map back to the zswap_tree
> > + *        structure that contains the entry.
> > + * offset - the swap offset for the entry.  Index into the red-black tree.
> > + * handle - zsmalloc allocation handle that stores the compressed page data
> > + * length - the length in bytes of the compressed page data.  Needed during
> > + *           decompression
> > + */
> > +struct zswap_entry {
> > +	struct rb_node rbnode;
> > +	pgoff_t offset;
> > +	int refcount;
> > +	unsigned int length;
> > +	unsigned long handle;
> > +};
> > +
> > +struct zswap_header {
> > +	swp_entry_t swpentry;
> > +};
> > +
> > +/*
> > + * The tree lock in the zswap_tree struct protects a few things:
> > + * - the rbtree
> > + * - the refcount field of each entry in the tree
> > + */
> > +struct zswap_tree {
> > +	struct rb_root rbroot;
> > +	spinlock_t lock;
> > +	struct zbud_pool *pool;
> > +	unsigned type;
> > +};
> > +
> > +static struct zswap_tree *zswap_trees[MAX_SWAPFILES];
> > +
> > +/*********************************
> > +* zswap entry functions
> > +**********************************/
> > +#define ZSWAP_KMEM_CACHE_NAME "zswap_entry_cache"
> > +static struct kmem_cache *zswap_entry_cache;
> > +
> > +static inline int zswap_entry_cache_create(void)
> > +{
> > +	zswap_entry_cache =
> > +		kmem_cache_create(ZSWAP_KMEM_CACHE_NAME,
> > +			sizeof(struct zswap_entry), 0, 0, NULL);
> > +	return (zswap_entry_cache == NULL);
> > +}
> > +
> > +static inline void zswap_entry_cache_destory(void)
> > +{
> > +	kmem_cache_destroy(zswap_entry_cache);
> > +}
> > +
> > +static inline struct zswap_entry *zswap_entry_cache_alloc(gfp_t gfp)
> > +{
> > +	struct zswap_entry *entry;
> > +	entry = kmem_cache_alloc(zswap_entry_cache, gfp);
> > +	if (!entry)
> > +		return NULL;
> > +	entry->refcount = 1;
> > +	return entry;
> > +}
> > +
> > +static inline void zswap_entry_cache_free(struct zswap_entry *entry)
> > +{
> > +	kmem_cache_free(zswap_entry_cache, entry);
> > +}
> > +
> > +static inline void zswap_entry_get(struct zswap_entry *entry)
> > +{
> > +	entry->refcount++;
> > +}
> > +
> > +static inline int zswap_entry_put(struct zswap_entry *entry)
> > +{
> > +	entry->refcount--;
> > +	return entry->refcount;
> > +}
> > +
> > +/*********************************
> > +* rbtree functions
> > +**********************************/
> > +static struct zswap_entry *zswap_rb_search(struct rb_root *root, pgoff_t offset)
> > +{
> > +	struct rb_node *node = root->rb_node;
> > +	struct zswap_entry *entry;
> > +
> > +	while (node) {
> > +		entry = rb_entry(node, struct zswap_entry, rbnode);
> > +		if (entry->offset > offset)
> > +			node = node->rb_left;
> > +		else if (entry->offset < offset)
> > +			node = node->rb_right;
> > +		else
> > +			return entry;
> > +	}
> > +	return NULL;
> > +}
> > +
> > +/*
> > + * In the case that a entry with the same offset is found, it a pointer to
> > + * the existing entry is stored in dupentry and the function returns -EEXIST
> > +*/
> > +static int zswap_rb_insert(struct rb_root *root, struct zswap_entry *entry,
> > +			struct zswap_entry **dupentry)
> > +{
> > +	struct rb_node **link = &root->rb_node, *parent = NULL;
> > +	struct zswap_entry *myentry;
> > +
> > +	while (*link) {
> > +		parent = *link;
> > +		myentry = rb_entry(parent, struct zswap_entry, rbnode);
> > +		if (myentry->offset > entry->offset)
> > +			link = &(*link)->rb_left;
> > +		else if (myentry->offset < entry->offset)
> > +			link = &(*link)->rb_right;
> > +		else {
> > +			*dupentry = myentry;
> > +			return -EEXIST;
> > +		}
> > +	}
> > +	rb_link_node(&entry->rbnode, parent, link);
> > +	rb_insert_color(&entry->rbnode, root);
> > +	return 0;
> > +}
> > +
> > +/*********************************
> > +* per-cpu code
> > +**********************************/
> > +static DEFINE_PER_CPU(u8 *, zswap_dstmem);
> > +
> > +static int __zswap_cpu_notifier(unsigned long action, unsigned long cpu)
> > +{
> > +	struct crypto_comp *tfm;
> > +	u8 *dst;
> > +
> > +	switch (action) {
> > +	case CPU_UP_PREPARE:
> > +		tfm = crypto_alloc_comp(zswap_compressor, 0, 0);
> > +		if (IS_ERR(tfm)) {
> > +			pr_err("can't allocate compressor transform\n");
> > +			return NOTIFY_BAD;
> > +		}
> > +		*per_cpu_ptr(zswap_comp_pcpu_tfms, cpu) = tfm;
> > +		dst = kmalloc(PAGE_SIZE * 2, GFP_KERNEL);
> > +		if (!dst) {
> > +			pr_err("can't allocate compressor buffer\n");
> > +			crypto_free_comp(tfm);
> > +			*per_cpu_ptr(zswap_comp_pcpu_tfms, cpu) = NULL;
> > +			return NOTIFY_BAD;
> > +		}
> > +		per_cpu(zswap_dstmem, cpu) = dst;
> > +		break;
> > +	case CPU_DEAD:
> > +	case CPU_UP_CANCELED:
> > +		tfm = *per_cpu_ptr(zswap_comp_pcpu_tfms, cpu);
> > +		if (tfm) {
> > +			crypto_free_comp(tfm);
> > +			*per_cpu_ptr(zswap_comp_pcpu_tfms, cpu) = NULL;
> > +		}
> > +		dst = per_cpu(zswap_dstmem, cpu);
> > +		kfree(dst);
> > +		per_cpu(zswap_dstmem, cpu) = NULL;
> > +		break;
> > +	default:
> > +		break;
> > +	}
> > +	return NOTIFY_OK;
> > +}
> > +
> > +static int zswap_cpu_notifier(struct notifier_block *nb,
> > +				unsigned long action, void *pcpu)
> > +{
> > +	unsigned long cpu = (unsigned long)pcpu;
> > +	return __zswap_cpu_notifier(action, cpu);
> > +}
> > +
> > +static struct notifier_block zswap_cpu_notifier_block = {
> > +	.notifier_call = zswap_cpu_notifier
> > +};
> > +
> > +static int zswap_cpu_init(void)
> > +{
> > +	unsigned long cpu;
> > +
> > +	get_online_cpus();
> > +	for_each_online_cpu(cpu)
> > +		if (__zswap_cpu_notifier(CPU_UP_PREPARE, cpu) != NOTIFY_OK)
> > +			goto cleanup;
> > +	register_cpu_notifier(&zswap_cpu_notifier_block);
> > +	put_online_cpus();
> > +	return 0;
> > +
> > +cleanup:
> > +	for_each_online_cpu(cpu)
> > +		__zswap_cpu_notifier(CPU_UP_CANCELED, cpu);
> > +	put_online_cpus();
> > +	return -ENOMEM;
> > +}
> > +
> > +/*********************************
> > +* helpers
> > +**********************************/
> > +static inline bool zswap_is_full(void)
> > +{
> > +	int pool_pages = atomic_read(&zswap_pool_pages);
> > +	return (totalram_pages * zswap_max_pool_percent / 100 < pool_pages);
> > +}
> > +
> > +/*
> > + * Carries out the common pattern of freeing and entry's zsmalloc allocation,
> > + * freeing the entry itself, and decrementing the number of stored pages.
> > + */
> > +static void zswap_free_entry(struct zswap_tree *tree, struct zswap_entry *entry)
> > +{
> > +	zbud_free(tree->pool, entry->handle);
> > +	zswap_entry_cache_free(entry);
> > +	atomic_dec(&zswap_stored_pages);
> > +	atomic_set(&zswap_pool_pages, zbud_get_pool_size(tree->pool));
> > +}
> > +
> > +/*********************************
> > +* writeback code
> > +**********************************/
> > +/* return enum for zswap_get_swap_cache_page */
> > +enum zswap_get_swap_ret {
> > +	ZSWAP_SWAPCACHE_NEW,
> > +	ZSWAP_SWAPCACHE_EXIST,
> > +	ZSWAP_SWAPCACHE_NOMEM
> > +};
> > +
> > +/*
> > + * zswap_get_swap_cache_page
> > + *
> > + * This is an adaption of read_swap_cache_async()
> > + *
> > + * This function tries to find a page with the given swap entry
> > + * in the swapper_space address space (the swap cache).  If the page
> > + * is found, it is returned in retpage.  Otherwise, a page is allocated,
> > + * added to the swap cache, and returned in retpage.
> > + *
> > + * If success, the swap cache page is returned in retpage
> > + * Returns 0 if page was already in the swap cache, page is not locked
> > + * Returns 1 if the new page needs to be populated, page is locked
> > + * Returns <0 on error
> > + */
> > +static int zswap_get_swap_cache_page(swp_entry_t entry,
> > +				struct page **retpage)
> > +{
> > +	struct page *found_page, *new_page = NULL;
> > +	struct address_space *swapper_space = &swapper_spaces[swp_type(entry)];
> > +	int err;
> > +
> > +	*retpage = NULL;
> > +	do {
> > +		/*
> > +		 * First check the swap cache.  Since this is normally
> > +		 * called after lookup_swap_cache() failed, re-calling
> > +		 * that would confuse statistics.
> > +		 */
> > +		found_page = find_get_page(swapper_space, entry.val);
> > +		if (found_page)
> > +			break;
> > +
> > +		/*
> > +		 * Get a new page to read into from swap.
> > +		 */
> > +		if (!new_page) {
> > +			new_page = alloc_page(GFP_KERNEL);
> > +			if (!new_page)
> > +				break; /* Out of memory */
> > +		}
> > +
> > +		/*
> > +		 * call radix_tree_preload() while we can wait.
> > +		 */
> > +		err = radix_tree_preload(GFP_KERNEL);
> > +		if (err)
> > +			break;
> > +
> > +		/*
> > +		 * Swap entry may have been freed since our caller observed it.
> > +		 */
> > +		err = swapcache_prepare(entry);
> > +		if (err == -EEXIST) { /* seems racy */
> > +			radix_tree_preload_end();
> > +			continue;
> > +		}
> > +		if (err) { /* swp entry is obsolete ? */
> > +			radix_tree_preload_end();
> > +			break;
> > +		}
> > +
> > +		/* May fail (-ENOMEM) if radix-tree node allocation failed. */
> > +		__set_page_locked(new_page);
> > +		SetPageSwapBacked(new_page);
> > +		err = __add_to_swap_cache(new_page, entry);
> > +		if (likely(!err)) {
> > +			radix_tree_preload_end();
> > +			lru_cache_add_anon(new_page);
> > +			*retpage = new_page;
> > +			return ZSWAP_SWAPCACHE_NEW;
> > +		}
> > +		radix_tree_preload_end();
> > +		ClearPageSwapBacked(new_page);
> > +		__clear_page_locked(new_page);
> > +		/*
> > +		 * add_to_swap_cache() doesn't return -EEXIST, so we can safely
> > +		 * clear SWAP_HAS_CACHE flag.
> > +		 */
> > +		swapcache_free(entry, NULL);
> > +	} while (err != -ENOMEM);
> > +
> > +	if (new_page)
> > +		page_cache_release(new_page);
> > +	if (!found_page)
> > +		return ZSWAP_SWAPCACHE_NOMEM;
> > +	*retpage = found_page;
> > +	return ZSWAP_SWAPCACHE_EXIST;
> > +}
> > +
> > +/*
> > + * Attempts to free and entry by adding a page to the swap cache,
> > + * decompressing the entry data into the page, and issuing a
> > + * bio write to write the page back to the swap device.
> > + *
> > + * This can be thought of as a "resumed writeback" of the page
> > + * to the swap device.  We are basically resuming the same swap
> > + * writeback path that was intercepted with the frontswap_store()
> > + * in the first place.  After the page has been decompressed into
> > + * the swap cache, the compressed version stored by zswap can be
> > + * freed.
> > + */
> > +static int zswap_writeback_entry(struct zbud_pool *pool, unsigned long handle)
> > +{
> > +	struct zswap_header *zhdr;
> > +	swp_entry_t swpentry;
> > +	struct zswap_tree *tree;
> > +	pgoff_t offset;
> > +	struct zswap_entry *entry;
> > +	struct page *page;
> > +	u8 *src, *dst;
> > +	unsigned int dlen;
> > +	int ret, refcount;
> > +	struct writeback_control wbc = {
> > +		.sync_mode = WB_SYNC_NONE,
> > +	};
> > +
> > +	/* extract swpentry from data */
> > +	zhdr = zbud_map(pool, handle);
> > +	swpentry = zhdr->swpentry; /* here */
> > +	zbud_unmap(pool, handle);
> > +	tree = zswap_trees[swp_type(swpentry)];
> > +	offset = swp_offset(swpentry);
> > +	BUG_ON(pool != tree->pool);
> > +
> > +	/* find and ref zswap entry */
> > +	spin_lock(&tree->lock);
> > +	entry = zswap_rb_search(&tree->rbroot, offset);
> > +	if (!entry) {
> > +		/* entry was invalidated */
> > +		spin_unlock(&tree->lock);
> > +		return 0;
> > +	}
> > +	zswap_entry_get(entry);
> > +	spin_unlock(&tree->lock);
> > +	BUG_ON(offset != entry->offset);
> > +
> > +	/* try to allocate swap cache page */
> > +	switch (zswap_get_swap_cache_page(swpentry, &page)) {
> > +	case ZSWAP_SWAPCACHE_NOMEM: /* no memory */
> > +		ret = -ENOMEM;
> > +		goto fail;
> > +
> > +	case ZSWAP_SWAPCACHE_EXIST: /* page is unlocked */
> > +		/* page is already in the swap cache, ignore for now */
> > +		page_cache_release(page);
> > +		ret = -EEXIST;
> > +		goto fail;
> > +
> > +	case ZSWAP_SWAPCACHE_NEW: /* page is locked */
> > +		/* decompress */
> > +		dlen = PAGE_SIZE;
> > +		src = (u8 *)zbud_map(tree->pool, entry->handle) +
> > +			sizeof(struct zswap_header);
> > +		dst = kmap_atomic(page);
> > +		ret = zswap_comp_op(ZSWAP_COMPOP_DECOMPRESS, src,
> > +				entry->length, dst, &dlen);
> > +		kunmap_atomic(dst);
> > +		zbud_unmap(tree->pool, entry->handle);
> > +		BUG_ON(ret);
> > +		BUG_ON(dlen != PAGE_SIZE);
> > +
> > +		/* page is up to date */
> > +		SetPageUptodate(page);
> > +	}
> > +
> > +	/* start writeback */
> > +	SetPageReclaim(page);
> > +	__swap_writepage(page, &wbc, end_swap_bio_write);
> > +	page_cache_release(page);
> > +	zswap_written_back_pages++;
> > +
> > +	spin_lock(&tree->lock);
> > +
> > +	/* drop local reference */
> > +	zswap_entry_put(entry);
> > +	/* drop the initial reference from entry creation */
> > +	refcount = zswap_entry_put(entry);
> > +
> > +	/*
> > +	 * There are three possible values for refcount here:
> > +	 * (1) refcount is 1, load is in progress, unlink from rbtree,
> > +	 *     load will free
> > +	 * (2) refcount is 0, (normal case) entry is valid,
> > +	 *     remove from rbtree and free entry
> > +	 * (3) refcount is -1, invalidate happened during writeback,
> > +	 *     free entry
> > +	 */
> > +	if (refcount >= 0) {
> > +		/* no invalidate yet, remove from rbtree */
> > +		rb_erase(&entry->rbnode, &tree->rbroot);
> > +	}
> > +	spin_unlock(&tree->lock);
> > +	if (refcount <= 0) {
> > +		/* free the entry */
> > +		zswap_free_entry(tree, entry);
> > +		return 0;
> > +	}
> > +	return -EAGAIN;
> > +
> > +fail:
> > +	spin_lock(&tree->lock);
> > +	zswap_entry_put(entry);
> > +	spin_unlock(&tree->lock);
> > +	return ret;
> > +}
> > +
> > +/*********************************
> > +* frontswap hooks
> > +**********************************/
> > +/* attempts to compress and store an single page */
> > +static int zswap_frontswap_store(unsigned type, pgoff_t offset,
> > +				struct page *page)
> > +{
> > +	struct zswap_tree *tree = zswap_trees[type];
> > +	struct zswap_entry *entry, *dupentry;
> > +	int ret;
> > +	unsigned int dlen = PAGE_SIZE, len;
> > +	unsigned long handle;
> > +	char *buf;
> > +	u8 *src, *dst;
> > +	struct zswap_header *zhdr;
> > +
> > +	if (!tree) {
> > +		ret = -ENODEV;
> > +		goto reject;
> > +	}
> > +
> > +	/* reclaim space if needed */
> > +	if (zswap_is_full()) {
> > +		zswap_pool_limit_hit++;
> > +		if (zbud_reclaim_page(tree->pool, 8)) {
> > +			zswap_reject_reclaim_fail++;
> > +			ret = -ENOMEM;
> > +			goto reject;
> > +		}
> > +	}
> 
> See comment above about enforcing "full".
> 
> (No further comments below... Thanks, Dan)
> 
> > +	/* allocate entry */
> > +	entry = zswap_entry_cache_alloc(GFP_KERNEL);
> > +	if (!entry) {
> > +		zswap_reject_kmemcache_fail++;
> > +		ret = -ENOMEM;
> > +		goto reject;
> > +	}
> > +
> > +	/* compress */
> > +	dst = get_cpu_var(zswap_dstmem);
> > +	src = kmap_atomic(page);
> > +	ret = zswap_comp_op(ZSWAP_COMPOP_COMPRESS, src, PAGE_SIZE, dst, &dlen);
> > +	kunmap_atomic(src);
> > +	if (ret) {
> > +		ret = -EINVAL;
> > +		goto freepage;
> > +	}
> > +	len = dlen + sizeof(struct zswap_header);
> > +	if ((len * 100 / PAGE_SIZE) > zswap_max_compression_ratio) {
> > +		zswap_reject_compress_poor++;
> > +		ret = -E2BIG;
> > +		goto freepage;
> > +	}
> > +
> > +	/* store */
> > +	ret = zbud_alloc(tree->pool, len, __GFP_NORETRY | __GFP_NOWARN,
> > +		&handle);
> > +	if (ret) {
> > +		zswap_reject_alloc_fail++;
> > +		goto freepage;
> > +	}
> > +	zhdr = zbud_map(tree->pool, handle);
> > +	zhdr->swpentry = swp_entry(type, offset);
> > +	buf = (u8 *)(zhdr + 1);
> > +	memcpy(buf, dst, dlen);
> > +	zbud_unmap(tree->pool, handle);
> > +	put_cpu_var(zswap_dstmem);
> > +
> > +	/* populate entry */
> > +	entry->offset = offset;
> > +	entry->handle = handle;
> > +	entry->length = dlen;
> > +
> > +	/* map */
> > +	spin_lock(&tree->lock);
> > +	do {
> > +		ret = zswap_rb_insert(&tree->rbroot, entry, &dupentry);
> > +		if (ret == -EEXIST) {
> > +			zswap_duplicate_entry++;
> > +			/* remove from rbtree */
> > +			rb_erase(&dupentry->rbnode, &tree->rbroot);
> > +			if (!zswap_entry_put(dupentry)) {
> > +				/* free */
> > +				zswap_free_entry(tree, dupentry);
> > +			}
> > +		}
> > +	} while (ret == -EEXIST);
> > +	spin_unlock(&tree->lock);
> > +
> > +	/* update stats */
> > +	atomic_inc(&zswap_stored_pages);
> > +	atomic_set(&zswap_pool_pages, zbud_get_pool_size(tree->pool));
> > +
> > +	return 0;
> > +
> > +freepage:
> > +	put_cpu_var(zswap_dstmem);
> > +	zswap_entry_cache_free(entry);
> > +reject:
> > +	return ret;
> > +}
> > +
> > +/*
> > + * returns 0 if the page was successfully decompressed
> > + * return -1 on entry not found or error
> > +*/
> > +static int zswap_frontswap_load(unsigned type, pgoff_t offset,
> > +				struct page *page)
> > +{
> > +	struct zswap_tree *tree = zswap_trees[type];
> > +	struct zswap_entry *entry;
> > +	u8 *src, *dst;
> > +	unsigned int dlen;
> > +	int refcount, ret;
> > +
> > +	/* find */
> > +	spin_lock(&tree->lock);
> > +	entry = zswap_rb_search(&tree->rbroot, offset);
> > +	if (!entry) {
> > +		/* entry was written back */
> > +		spin_unlock(&tree->lock);
> > +		return -1;
> > +	}
> > +	zswap_entry_get(entry);
> > +	spin_unlock(&tree->lock);
> > +
> > +	/* decompress */
> > +	dlen = PAGE_SIZE;
> > +	src = (u8 *)zbud_map(tree->pool, entry->handle) +
> > +			sizeof(struct zswap_header);
> > +	dst = kmap_atomic(page);
> > +	ret = zswap_comp_op(ZSWAP_COMPOP_DECOMPRESS, src, entry->length,
> > +		dst, &dlen);
> > +	kunmap_atomic(dst);
> > +	zbud_unmap(tree->pool, entry->handle);
> > +	BUG_ON(ret);
> > +
> > +	spin_lock(&tree->lock);
> > +	refcount = zswap_entry_put(entry);
> > +	if (likely(refcount)) {
> > +		spin_unlock(&tree->lock);
> > +		return 0;
> > +	}
> > +	spin_unlock(&tree->lock);
> > +
> > +	/*
> > +	 * We don't have to unlink from the rbtree because
> > +	 * zswap_writeback_entry() or zswap_frontswap_invalidate page()
> > +	 * has already done this for us if we are the last reference.
> > +	 */
> > +	/* free */
> > +
> > +	zswap_free_entry(tree, entry);
> > +
> > +	return 0;
> > +}
> > +
> > +/* invalidates a single page */
> > +static void zswap_frontswap_invalidate_page(unsigned type, pgoff_t offset)
> > +{
> > +	struct zswap_tree *tree = zswap_trees[type];
> > +	struct zswap_entry *entry;
> > +	int refcount;
> > +
> > +	/* find */
> > +	spin_lock(&tree->lock);
> > +	entry = zswap_rb_search(&tree->rbroot, offset);
> > +	if (!entry) {
> > +		/* entry was written back */
> > +		spin_unlock(&tree->lock);
> > +		return;
> > +	}
> > +
> > +	/* remove from rbtree */
> > +	rb_erase(&entry->rbnode, &tree->rbroot);
> > +
> > +	/* drop the initial reference from entry creation */
> > +	refcount = zswap_entry_put(entry);
> > +
> > +	spin_unlock(&tree->lock);
> > +
> > +	if (refcount) {
> > +		/* writeback in progress, writeback will free */
> > +		return;
> > +	}
> > +
> > +	/* free */
> > +	zswap_free_entry(tree, entry);
> > +}
> > +
> > +/* invalidates all pages for the given swap type */
> > +static void zswap_frontswap_invalidate_area(unsigned type)
> > +{
> > +	struct zswap_tree *tree = zswap_trees[type];
> > +	struct rb_node *node;
> > +	struct zswap_entry *entry;
> > +
> > +	if (!tree)
> > +		return;
> > +
> > +	/* walk the tree and free everything */
> > +	spin_lock(&tree->lock);
> > +	/*
> > +	 * TODO: Even though this code should not be executed because
> > +	 * the try_to_unuse() in swapoff should have emptied the tree,
> > +	 * it is very wasteful to rebalance the tree after every
> > +	 * removal when we are freeing the whole tree.
> > +	 *
> > +	 * If post-order traversal code is ever added to the rbtree
> > +	 * implementation, it should be used here.
> > +	 */
> > +	while ((node = rb_first(&tree->rbroot))) {
> > +		entry = rb_entry(node, struct zswap_entry, rbnode);
> > +		rb_erase(&entry->rbnode, &tree->rbroot);
> > +		zbud_free(tree->pool, entry->handle);
> > +		zswap_entry_cache_free(entry);
> > +		atomic_dec(&zswap_stored_pages);
> > +	}
> > +	tree->rbroot = RB_ROOT;
> > +	spin_unlock(&tree->lock);
> > +}
> > +
> > +static struct zbud_ops zswap_zbud_ops = {
> > +	.evict = zswap_writeback_entry
> > +};
> > +
> > +/* NOTE: this is called in atomic context from swapon and must not sleep */
> > +static void zswap_frontswap_init(unsigned type)
> > +{
> > +	struct zswap_tree *tree;
> > +
> > +	tree = kzalloc(sizeof(struct zswap_tree), GFP_ATOMIC);
> > +	if (!tree)
> > +		goto err;
> > +	tree->pool = zbud_create_pool(GFP_NOWAIT, &zswap_zbud_ops);
> > +	if (!tree->pool)
> > +		goto freetree;
> > +	tree->rbroot = RB_ROOT;
> > +	spin_lock_init(&tree->lock);
> > +	tree->type = type;
> > +	zswap_trees[type] = tree;
> > +	return;
> > +
> > +freetree:
> > +	kfree(tree);
> > +err:
> > +	pr_err("alloc failed, zswap disabled for swap type %d\n", type);
> > +}
> > +
> > +static struct frontswap_ops zswap_frontswap_ops = {
> > +	.store = zswap_frontswap_store,
> > +	.load = zswap_frontswap_load,
> > +	.invalidate_page = zswap_frontswap_invalidate_page,
> > +	.invalidate_area = zswap_frontswap_invalidate_area,
> > +	.init = zswap_frontswap_init
> > +};
> > +
> > +/*********************************
> > +* debugfs functions
> > +**********************************/
> > +#ifdef CONFIG_DEBUG_FS
> > +#include <linux/debugfs.h>
> > +
> > +static struct dentry *zswap_debugfs_root;
> > +
> > +static int __init zswap_debugfs_init(void)
> > +{
> > +	if (!debugfs_initialized())
> > +		return -ENODEV;
> > +
> > +	zswap_debugfs_root = debugfs_create_dir("zswap", NULL);
> > +	if (!zswap_debugfs_root)
> > +		return -ENOMEM;
> > +
> > +	debugfs_create_u64("pool_limit_hit", S_IRUGO,
> > +			zswap_debugfs_root, &zswap_pool_limit_hit);
> > +	debugfs_create_u64("reject_reclaim_fail", S_IRUGO,
> > +			zswap_debugfs_root, &zswap_reject_reclaim_fail);
> > +	debugfs_create_u64("reject_alloc_fail", S_IRUGO,
> > +			zswap_debugfs_root, &zswap_reject_alloc_fail);
> > +	debugfs_create_u64("reject_kmemcache_fail", S_IRUGO,
> > +			zswap_debugfs_root, &zswap_reject_kmemcache_fail);
> > +	debugfs_create_u64("reject_compress_poor", S_IRUGO,
> > +			zswap_debugfs_root, &zswap_reject_compress_poor);
> > +	debugfs_create_u64("written_back_pages", S_IRUGO,
> > +			zswap_debugfs_root, &zswap_written_back_pages);
> > +	debugfs_create_u64("duplicate_entry", S_IRUGO,
> > +			zswap_debugfs_root, &zswap_duplicate_entry);
> > +	debugfs_create_atomic_t("pool_pages", S_IRUGO,
> > +			zswap_debugfs_root, &zswap_pool_pages);
> > +	debugfs_create_atomic_t("stored_pages", S_IRUGO,
> > +			zswap_debugfs_root, &zswap_stored_pages);
> > +
> > +	return 0;
> > +}
> > +
> > +static void __exit zswap_debugfs_exit(void)
> > +{
> > +	debugfs_remove_recursive(zswap_debugfs_root);
> > +}
> > +#else
> > +static inline int __init zswap_debugfs_init(void)
> > +{
> > +	return 0;
> > +}
> > +
> > +static inline void __exit zswap_debugfs_exit(void) { }
> > +#endif
> > +
> > +/*********************************
> > +* module init and exit
> > +**********************************/
> > +static int __init init_zswap(void)
> > +{
> > +	if (!zswap_enabled)
> > +		return 0;
> > +
> > +	pr_info("loading zswap\n");
> > +	if (zswap_entry_cache_create()) {
> > +		pr_err("entry cache creation failed\n");
> > +		goto error;
> > +	}
> > +	if (zswap_comp_init()) {
> > +		pr_err("compressor initialization failed\n");
> > +		goto compfail;
> > +	}
> > +	if (zswap_cpu_init()) {
> > +		pr_err("per-cpu initialization failed\n");
> > +		goto pcpufail;
> > +	}
> > +	frontswap_register_ops(&zswap_frontswap_ops);
> > +	if (zswap_debugfs_init())
> > +		pr_warn("debugfs initialization failed\n");
> > +	return 0;
> > +pcpufail:
> > +	zswap_comp_exit();
> > +compfail:
> > +	zswap_entry_cache_destory();
> > +error:
> > +	return -ENOMEM;
> > +}
> > +/* must be late so crypto has time to come up */
> > +late_initcall(init_zswap);
> > +
> > +MODULE_LICENSE("GPL");
> > +MODULE_AUTHOR("Seth Jennings <sjenning@linux.vnet.ibm.com>");
> > +MODULE_DESCRIPTION("Compressed cache for swap pages");
> > --
> > 1.7.9.5
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
