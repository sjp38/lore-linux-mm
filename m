Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 074D46B0005
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 23:44:48 -0500 (EST)
Date: Wed, 30 Jan 2013 13:44:47 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCHv3 5/6] zswap: add to mm/
Message-ID: <20130130044447.GD2580@blaptop>
References: <1359409767-30092-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1359409767-30092-6-git-send-email-sjenning@linux.vnet.ibm.com>
 <20130129062756.GH4752@blaptop>
 <51080658.7060709@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51080658.7060709@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On Tue, Jan 29, 2013 at 11:26:48AM -0600, Seth Jennings wrote:
> On 01/29/2013 12:27 AM, Minchan Kim wrote:
> > First feeling is it's simple and nice approach.
> > Although we have some problems to decide policy, it could solve by later patch
> > so I hope we make basic infrasture more solid by lots of comment.
> 
> Thanks very much for the review!
> 
> > 
> > There are two things to review hard.
> > 
> > 1. data structure life - when any data structure is died by whom?
> >    Please write down it in changelog or header of zswap.c
> > 
> > 2. Flush routine - I hope it would be nice to separate it as another
> >    incremental patches if it is possible. If it's impossible, let's add
> >    lots of words.
> 
> It seems like it would be difficult to break the flushing
> functionality into it's own patch, but I can start the process and
> see.  As long as people keep in mind that some of the design rationale
> in the version without the flush code is dictated by the addition of
> the flush code.
> 
> But yes, more comments.
> 
> > On Mon, Jan 28, 2013 at 03:49:26PM -0600, Seth Jennings wrote:
> >> zswap is a thin compression backend for frontswap. It receives
> >> pages from frontswap and attempts to store them in a compressed
> >> memory pool, resulting in an effective partial memory reclaim and
> >> dramatically reduced swap device I/O.
> >>
> >> Additional, in most cases, pages can be retrieved from this
> >> compressed store much more quickly than reading from tradition
> >> swap devices resulting in faster performance for many workloads.
> >>
> >> This patch adds the zswap driver to mm/
> >>
> >> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
> >> ---
> >>  mm/Kconfig  |   15 +
> >>  mm/Makefile |    1 +
> >>  mm/zswap.c  | 1073 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
> >>  3 files changed, 1089 insertions(+)
> >>  create mode 100644 mm/zswap.c
> >>
> >> diff --git a/mm/Kconfig b/mm/Kconfig
> >> index 278e3ab..14b9acb 100644
> >> --- a/mm/Kconfig
> >> +++ b/mm/Kconfig
> >> @@ -446,3 +446,18 @@ config FRONTSWAP
> >>  	  and swap data is stored as normal on the matching swap device.
> >>  
> >>  	  If unsure, say Y to enable frontswap.
> >> +
> >> +config ZSWAP
> >> +	bool "In-kernel swap page compression"
> >> +	depends on FRONTSWAP && CRYPTO
> > 
> > Couldn't we support CRYPTO optionally?
> 
> No.  zswap depends on the cryptographic API for access to the
> compression modules.

I meant I don't want to enable CONFIG_CRYPTO for just using zswap.
In case of zram, we didn't need it.
Is there any reason we must use encryption for using zswap?

> 
> > 
> >> +	select CRYPTO_LZO
> >> +	select ZSMALLOC
> >> +	default n
> >> +	help
> >> +	  Zswap is a backend for the frontswap mechanism in the VMM.
> >> +	  It receives pages from frontswap and attempts to store them
> >> +	  in a compressed memory pool, resulting in an effective
> >> +	  partial memory reclaim.  In addition, pages and be retrieved
> >> +	  from this compressed store much faster than most tradition
> >> +	  swap devices resulting in reduced I/O and faster performance
> >> +	  for many workloads.
> >> index 3a46287..1b1ed5c 100644
> >> --- a/mm/Makefile
> >> +++ b/mm/Makefile
> >> @@ -32,6 +32,7 @@ obj-$(CONFIG_HAVE_MEMBLOCK) += memblock.o
> >>  obj-$(CONFIG_BOUNCE)	+= bounce.o
> >>  obj-$(CONFIG_SWAP)	+= page_io.o swap_state.o swapfile.o
> >>  obj-$(CONFIG_FRONTSWAP)	+= frontswap.o
> >> +obj-$(CONFIG_ZSWAP)	+= zswap.o
> >>  obj-$(CONFIG_HAS_DMA)	+= dmapool.o
> >>  obj-$(CONFIG_HUGETLBFS)	+= hugetlb.o
> >>  obj-$(CONFIG_NUMA) 	+= mempolicy.o
> >> diff --git a/mm/zswap.c b/mm/zswap.c
> >> new file mode 100644
> >> index 0000000..050b6db
> >> --- /dev/null
> >> +++ b/mm/zswap.c
> >> @@ -0,0 +1,1073 @@
> >> +/*
> >> + * zswap-drv.c - zswap driver file
> >> + *
> >> + * zswap is a backend for frontswap that takes pages that are in the
> >> + * process of being swapped out and attempts to compress them and store
> >> + * them in a RAM-based memory pool.  This results in a significant I/O
> >> + * reduction on the real swap device and, in the case of a slow swap
> >> + * device, can also improve workload performance.
> >> + *
> >> + * Copyright (C) 2012  Seth Jennings <sjenning@linux.vnet.ibm.com>
> >> + *
> >> + * This program is free software; you can redistribute it and/or
> >> + * modify it under the terms of the GNU General Public License
> >> + * as published by the Free Software Foundation; either version 2
> >> + * of the License, or (at your option) any later version.
> >> + *
> >> + * This program is distributed in the hope that it will be useful,
> >> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> >> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> >> + * GNU General Public License for more details.
> >> +*/
> >> +
> >> +#include <linux/module.h>
> >> +#include <linux/cpu.h>
> >> +#include <linux/highmem.h>
> >> +#include <linux/slab.h>
> >> +#include <linux/spinlock.h>
> >> +#include <linux/types.h>
> >> +#include <linux/atomic.h>
> >> +#include <linux/frontswap.h>
> >> +#include <linux/rbtree.h>
> >> +#include <linux/swap.h>
> >> +#include <linux/crypto.h>
> >> +#include <linux/mempool.h>
> >> +#include <linux/zsmalloc.h>
> >> +
> >> +#include <linux/mm_types.h>
> >> +#include <linux/page-flags.h>
> >> +#include <linux/swapops.h>
> >> +#include <linux/writeback.h>
> >> +#include <linux/pagemap.h>
> >> +
> >> +/*********************************
> >> +* statistics
> >> +**********************************/
> >> +/* Number of memory pages used by the compressed pool */
> >> +static atomic_t zswap_pool_pages = ATOMIC_INIT(0);
> >> +/* The number of compressed pages currently stored in zswap */
> >> +static atomic_t zswap_stored_pages = ATOMIC_INIT(0);
> >> +/* The number of outstanding pages awaiting writeback */
> >> +static atomic_t zswap_outstanding_flushes = ATOMIC_INIT(0);
> >> +
> >> +/*
> >> + * The statistics below are not protected from concurrent access for
> >> + * performance reasons so they may not be a 100% accurate.  However,
> >> + * the do provide useful information on roughly how many times a
> >> + * certain event is occurring.
> >> +*/
> >> +static u64 zswap_flushed_pages;
> >> +static u64 zswap_reject_compress_poor;
> >> +static u64 zswap_flush_attempted;
> >> +static u64 zswap_reject_tmppage_fail;
> >> +static u64 zswap_reject_flush_fail;
> >> +static u64 zswap_reject_zsmalloc_fail;
> >> +static u64 zswap_reject_kmemcache_fail;
> >> +static u64 zswap_saved_by_flush;
> >> +static u64 zswap_duplicate_entry;
> >> +
> >> +/*********************************
> >> +* tunables
> >> +**********************************/
> >> +/* Enable/disable zswap (enabled by default, fixed at boot for now) */
> >> +static bool zswap_enabled;
> >> +module_param_named(enabled, zswap_enabled, bool, 0);
> > 
> > It seems default is disable at the moment?
> 
> Yes, that's right.  While zswap should be always-on safe (i.e. no
> impact if swap isn't being used), I thought this would be the safe way
> for now.
> 
> > 
> >> +
> >> +/* Compressor to be used by zswap (fixed at boot for now) */
> >> +#define ZSWAP_COMPRESSOR_DEFAULT "lzo"
> >> +static char *zswap_compressor = ZSWAP_COMPRESSOR_DEFAULT;
> >> +module_param_named(compressor, zswap_compressor, charp, 0);
> >> +
> >> +/* The maximum percentage of memory that the compressed pool can occupy */
> >> +static unsigned int zswap_max_pool_percent = 20;
> >> +module_param_named(max_pool_percent,
> >> +			zswap_max_pool_percent, uint, 0644);
> >> +
> >> +/*
> >> + * Maximum compression ratio, as as percentage, for an acceptable
> >> + * compressed page. Any pages that do not compress by at least
> >> + * this ratio will be rejected.
> >> +*/
> >> +static unsigned int zswap_max_compression_ratio = 80;
> >> +module_param_named(max_compression_ratio,
> >> +			zswap_max_compression_ratio, uint, 0644);
> >> +
> >> +/*
> >> + * Maximum number of outstanding flushes allowed at any given time.
> >> + * This is to prevent decompressing an unbounded number of compressed
> >> + * pages into the swap cache all at once, and to help with writeback
> >> + * congestion.
> >> +*/
> >> +#define ZSWAP_MAX_OUTSTANDING_FLUSHES 64
> >> +
> >> +/*********************************
> >> +* compression functions
> >> +**********************************/
> >> +/* per-cpu compression transforms */
> >> +static struct crypto_comp * __percpu *zswap_comp_pcpu_tfms;
> >> +
> >> +enum comp_op {
> >> +	ZSWAP_COMPOP_COMPRESS,
> >> +	ZSWAP_COMPOP_DECOMPRESS
> >> +};
> >> +
> >> +static int zswap_comp_op(enum comp_op op, const u8 *src, unsigned int slen,
> >> +				u8 *dst, unsigned int *dlen)
> >> +{
> >> +	struct crypto_comp *tfm;
> >> +	int ret;
> >> +
> >> +	tfm = *per_cpu_ptr(zswap_comp_pcpu_tfms, get_cpu());
> >> +	switch (op) {
> >> +	case ZSWAP_COMPOP_COMPRESS:
> >> +		ret = crypto_comp_compress(tfm, src, slen, dst, dlen);
> >> +		break;
> >> +	case ZSWAP_COMPOP_DECOMPRESS:
> >> +		ret = crypto_comp_decompress(tfm, src, slen, dst, dlen);
> >> +		break;
> >> +	default:
> >> +		ret = -EINVAL;
> >> +	}
> >> +
> >> +	put_cpu();
> >> +	return ret;
> >> +}
> >> +
> >> +static int __init zswap_comp_init(void)
> >> +{
> >> +	if (!crypto_has_comp(zswap_compressor, 0, 0)) {
> >> +		pr_info("zswap: %s compressor not available\n",
> >> +			zswap_compressor);
> >> +		/* fall back to default compressor */
> >> +		zswap_compressor = ZSWAP_COMPRESSOR_DEFAULT;
> >> +		if (!crypto_has_comp(zswap_compressor, 0, 0))
> >> +			/* can't even load the default compressor */
> >> +			return -ENODEV;
> >> +	}
> >> +	pr_info("zswap: using %s compressor\n", zswap_compressor);
> >> +
> >> +	/* alloc percpu transforms */
> >> +	zswap_comp_pcpu_tfms = alloc_percpu(struct crypto_comp *);
> >> +	if (!zswap_comp_pcpu_tfms)
> >> +		return -ENOMEM;
> >> +	return 0;
> >> +}
> >> +
> >> +static void zswap_comp_exit(void)
> >> +{
> >> +	/* free percpu transforms */
> >> +	if (zswap_comp_pcpu_tfms)
> >> +		free_percpu(zswap_comp_pcpu_tfms);
> >> +}
> >> +
> >> +/*********************************
> >> +* data structures
> >> +**********************************/
> >> +struct zswap_entry {
> >> +	struct rb_node rbnode;
> >> +	struct list_head lru;
> >> +	int refcount;
> >> +	unsigned type;
> >> +	pgoff_t offset;
> >> +	unsigned long handle;
> >> +	unsigned int length;
> >> +};
> >> +
> >> +/*
> >> + * The tree lock in the zswap_tree struct protects a few things:
> >> + * - the rbtree
> >> + * - the lru list
> >> + * - the refcount field of each entry in the tree
> >> + */
> >> +struct zswap_tree {
> >> +	struct rb_root rbroot;
> >> +	struct list_head lru;
> >> +	spinlock_t lock;
> >> +	struct zs_pool *pool;
> >> +};
> >> +
> >> +static struct zswap_tree *zswap_trees[MAX_SWAPFILES];
> >> +
> >> +/*********************************
> >> +* zswap entry functions
> >> +**********************************/
> >> +#define ZSWAP_KMEM_CACHE_NAME "zswap_entry_cache"
> >> +static struct kmem_cache *zswap_entry_cache;
> >> +
> >> +static inline int zswap_entry_cache_create(void)
> >> +{
> >> +	zswap_entry_cache =
> >> +		kmem_cache_create(ZSWAP_KMEM_CACHE_NAME,
> >> +			sizeof(struct zswap_entry), 0, 0, NULL);
> >> +	return (zswap_entry_cache == NULL);
> >> +}
> >> +
> >> +static inline void zswap_entry_cache_destory(void)
> >> +{
> >> +	kmem_cache_destroy(zswap_entry_cache);
> >> +}
> >> +
> >> +static inline struct zswap_entry *zswap_entry_cache_alloc(gfp_t gfp)
> >> +{
> >> +	struct zswap_entry *entry;
> >> +	entry = kmem_cache_alloc(zswap_entry_cache, gfp);
> >> +	if (!entry)
> >> +		return NULL;
> >> +	INIT_LIST_HEAD(&entry->lru);
> >> +	entry->refcount = 1;
> >> +	return entry;
> >> +}
> >> +
> >> +static inline void zswap_entry_cache_free(struct zswap_entry *entry)
> >> +{
> >> +	kmem_cache_free(zswap_entry_cache, entry);
> >> +}
> >> +
> >> +static inline void zswap_entry_get(struct zswap_entry *entry)
> >> +{
> >> +	entry->refcount++;
> >> +}
> >> +
> >> +static inline int zswap_entry_put(struct zswap_entry *entry)
> >> +{
> >> +	entry->refcount--;
> >> +	return entry->refcount;
> >> +}
> >> +
> >> +/*********************************
> >> +* rbtree functions
> >> +**********************************/
> >> +static struct zswap_entry *zswap_rb_search(struct rb_root *root, pgoff_t offset)
> >> +{
> >> +	struct rb_node *node = root->rb_node;
> >> +	struct zswap_entry *entry;
> >> +
> >> +	while (node) {
> >> +		entry = rb_entry(node, struct zswap_entry, rbnode);
> >> +		if (entry->offset > offset)
> >> +			node = node->rb_left;
> >> +		else if (entry->offset < offset)
> >> +			node = node->rb_right;
> >> +		else
> >> +			return entry;
> >> +	}
> >> +	return NULL;
> >> +}
> >> +
> >> +/*
> >> + * In the case that a entry with the same offset is found, it a pointer to
> >> + * the existing entry is stored in dupentry and the function returns -EEXIST
> >> +*/
> >> +static int zswap_rb_insert(struct rb_root *root, struct zswap_entry *entry,
> >> +			struct zswap_entry **dupentry)
> >> +{
> >> +	struct rb_node **link = &root->rb_node, *parent = NULL;
> >> +	struct zswap_entry *myentry;
> >> +
> >> +	while (*link) {
> >> +		parent = *link;
> >> +		myentry = rb_entry(parent, struct zswap_entry, rbnode);
> >> +		if (myentry->offset > entry->offset)
> >> +			link = &(*link)->rb_left;
> >> +		else if (myentry->offset < entry->offset)
> >> +			link = &(*link)->rb_right;
> >> +		else {
> >> +			*dupentry = myentry;
> >> +			return -EEXIST;
> >> +		}
> >> +	}
> >> +	rb_link_node(&entry->rbnode, parent, link);
> >> +	rb_insert_color(&entry->rbnode, root);
> >> +	return 0;
> >> +}
> >> +
> >> +/*********************************
> >> +* per-cpu code
> >> +**********************************/
> >> +static DEFINE_PER_CPU(u8 *, zswap_dstmem);
> >> +
> >> +static int __zswap_cpu_notifier(unsigned long action, unsigned long cpu)
> >> +{
> >> +	struct crypto_comp *tfm;
> >> +	u8 *dst;
> >> +
> >> +	switch (action) {
> >> +	case CPU_UP_PREPARE:
> >> +		tfm = crypto_alloc_comp(zswap_compressor, 0, 0);
> >> +		if (IS_ERR(tfm)) {
> >> +			pr_err("zswap: can't allocate compressor transform\n");
> >> +			return NOTIFY_BAD;
> >> +		}
> >> +		*per_cpu_ptr(zswap_comp_pcpu_tfms, cpu) = tfm;
> >> +		dst = (u8 *)__get_free_pages(GFP_KERNEL, 1);
> >> +		if (!dst) {
> >> +			pr_err("zswap: can't allocate compressor buffer\n");
> >> +			crypto_free_comp(tfm);
> >> +			*per_cpu_ptr(zswap_comp_pcpu_tfms, cpu) = NULL;
> >> +			return NOTIFY_BAD;
> >> +		}
> >> +		per_cpu(zswap_dstmem, cpu) = dst;
> >> +		break;
> >> +	case CPU_DEAD:
> >> +	case CPU_UP_CANCELED:
> >> +		tfm = *per_cpu_ptr(zswap_comp_pcpu_tfms, cpu);
> >> +		if (tfm) {
> >> +			crypto_free_comp(tfm);
> >> +			*per_cpu_ptr(zswap_comp_pcpu_tfms, cpu) = NULL;
> >> +		}
> >> +		dst = per_cpu(zswap_dstmem, cpu);
> >> +		if (dst) {
> >> +			free_pages((unsigned long)dst, 1);
> >> +			per_cpu(zswap_dstmem, cpu) = NULL;
> >> +		}
> >> +		break;
> >> +	default:
> >> +		break;
> >> +	}
> >> +	return NOTIFY_OK;
> >> +}
> >> +
> >> +static int zswap_cpu_notifier(struct notifier_block *nb,
> >> +				unsigned long action, void *pcpu)
> >> +{
> >> +	unsigned long cpu = (unsigned long)pcpu;
> >> +	return __zswap_cpu_notifier(action, cpu);
> >> +}
> >> +
> >> +static struct notifier_block zswap_cpu_notifier_block = {
> >> +	.notifier_call = zswap_cpu_notifier
> >> +};
> >> +
> >> +static int zswap_cpu_init(void)
> >> +{
> >> +	unsigned long cpu;
> >> +
> >> +	get_online_cpus();
> >> +	for_each_online_cpu(cpu)
> >> +		if (__zswap_cpu_notifier(CPU_UP_PREPARE, cpu) != NOTIFY_OK)
> >> +			goto cleanup;
> >> +	register_cpu_notifier(&zswap_cpu_notifier_block);
> >> +	put_online_cpus();
> >> +	return 0;
> >> +
> >> +cleanup:
> >> +	for_each_online_cpu(cpu)
> >> +		__zswap_cpu_notifier(CPU_UP_CANCELED, cpu);
> >> +	put_online_cpus();
> >> +	return -ENOMEM;
> >> +}
> >> +
> >> +/*********************************
> >> +* zsmalloc callbacks
> >> +**********************************/
> >> +static mempool_t *zswap_page_pool;
> >> +
> >> +static u64 zswap_pool_limit_hit;
> >> +
> >> +static inline unsigned int zswap_max_pool_pages(void)
> >> +{
> >> +	return zswap_max_pool_percent * totalram_pages / 100;
> >> +}
> >> +
> >> +static inline int zswap_page_pool_create(void)
> >> +{
> >> +	zswap_page_pool = mempool_create_page_pool(256, 0);
> > 
> > Could you write down why you select pool to 256?
> > If you have a plan, please write down it as TODO.
> > I think it could be a function of zswap_max_pool_pages with min/max.
> 
> Yes, that would probably be better.
> 
> >
> > Another question.
> > 
> > What's the benefit of using mempool for zsmalloc?
> > As you know, zsmalloc doesn't use mempool as default.
> > I guess you see some benefit. if so, zram could be changed.
> > If we can change zsmalloc's default scheme to use mempool,
> > all of customer of zsmalloc could be enhanced, too.
> 
> In the case of zswap, through experimentation, I found that adding a
> mempool behind the zsmalloc pool added some elasticity to the pool.
> Fewer stores failed if we kept a small reserve of pages around instead
> of having to go back to the buddy allocator who, under memory
> pressure, is more likely to reject our request.
> 
> I don't see this situation being applicable to all zsmalloc users
> however.  I don't think we want incorporate it directly into zsmalloc
> for now.  The ability to register custom page alloc/free functions at
> pool creation time allows users to do something special, like back
> with a mempool, if they want to do that.

Okay. I'd like to test this approach with zram later and if it makes sense
for everything, I will try to change zsmalloc's inside.

Thanks!

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
