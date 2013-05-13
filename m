Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 0BD566B0096
	for <linux-mm@kvack.org>; Mon, 13 May 2013 18:32:01 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <15c5b1da-132a-4c9e-9f24-bc272d3865d5@default>
Date: Mon, 13 May 2013 15:31:42 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCHv11 3/4] zswap: add to mm/
References: <<1368448803-2089-1-git-send-email-sjenning@linux.vnet.ibm.com>>
 <<1368448803-2089-4-git-send-email-sjenning@linux.vnet.ibm.com>>
In-Reply-To: <<1368448803-2089-4-git-send-email-sjenning@linux.vnet.ibm.com>>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@sr71.net>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Hugh Dickens <hughd@google.com>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> Subject: [PATCHv11 3/4] zswap: add to mm/
>=20
> zswap is a thin compression backend for frontswap. It receives pages from
> frontswap and attempts to store them in a compressed memory pool, resulti=
ng in
> an effective partial memory reclaim and dramatically reduced swap device =
I/O.
>=20
> Additionally, in most cases, pages can be retrieved from this compressed =
store
> much more quickly than reading from tradition swap devices resulting in f=
aster
> performance for many workloads.
>=20
> It also has support for evicting swap pages that are currently compressed=
 in
> zswap to the swap device on an LRU(ish) basis. This functionality is very
> important and make zswap a true cache in that, once the cache is full or =
can't
> grow due to memory pressure, the oldest pages can be moved out of zswap t=
o the
> swap device so newer pages can be compressed and stored in zswap.
>=20
> This patch adds the zswap driver to mm/
>=20
> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>

A couple of comments below...

> ---
>  mm/Kconfig  |   15 +
>  mm/Makefile |    1 +
>  mm/zswap.c  |  952 +++++++++++++++++++++++++++++++++++++++++++++++++++++=
++++++
>  3 files changed, 968 insertions(+)
>  create mode 100644 mm/zswap.c
>=20
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 908f41b..4042e07 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -487,3 +487,18 @@ config ZBUD
>  =09  While this design limits storage density, it has simple and
>  =09  deterministic reclaim properties that make it preferable to a highe=
r
>  =09  density approach when reclaim will be used.
> +
> +config ZSWAP
> +=09bool "In-kernel swap page compression"
> +=09depends on FRONTSWAP && CRYPTO
> +=09select CRYPTO_LZO
> +=09select ZBUD
> +=09default n
> +=09help
> +=09  Zswap is a backend for the frontswap mechanism in the VMM.
> +=09  It receives pages from frontswap and attempts to store them
> +=09  in a compressed memory pool, resulting in an effective
> +=09  partial memory reclaim.  In addition, pages and be retrieved
> +=09  from this compressed store much faster than most tradition
> +=09  swap devices resulting in reduced I/O and faster performance
> +=09  for many workloads.
> diff --git a/mm/Makefile b/mm/Makefile
> index 95f0197..f008033 100644
> --- a/mm/Makefile
> +++ b/mm/Makefile
> @@ -32,6 +32,7 @@ obj-$(CONFIG_HAVE_MEMBLOCK) +=3D memblock.o
>  obj-$(CONFIG_BOUNCE)=09+=3D bounce.o
>  obj-$(CONFIG_SWAP)=09+=3D page_io.o swap_state.o swapfile.o
>  obj-$(CONFIG_FRONTSWAP)=09+=3D frontswap.o
> +obj-$(CONFIG_ZSWAP)=09+=3D zswap.o
>  obj-$(CONFIG_HAS_DMA)=09+=3D dmapool.o
>  obj-$(CONFIG_HUGETLBFS)=09+=3D hugetlb.o
>  obj-$(CONFIG_NUMA) =09+=3D mempolicy.o
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
> +static atomic_t zswap_pool_pages =3D ATOMIC_INIT(0);
> +/* The number of compressed pages currently stored in zswap */
> +static atomic_t zswap_stored_pages =3D ATOMIC_INIT(0);
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
> +/*********************************
> +* tunables
> +**********************************/
> +/* Enable/disable zswap (disabled by default, fixed at boot for now) */
> +static bool zswap_enabled;
> +module_param_named(enabled, zswap_enabled, bool, 0);
> +
> +/* Compressor to be used by zswap (fixed at boot for now) */
> +#define ZSWAP_COMPRESSOR_DEFAULT "lzo"
> +static char *zswap_compressor =3D ZSWAP_COMPRESSOR_DEFAULT;
> +module_param_named(compressor, zswap_compressor, charp, 0);
> +
> +/* The maximum percentage of memory that the compressed pool can occupy =
*/
> +static unsigned int zswap_max_pool_percent =3D 20;
> +module_param_named(max_pool_percent,
> +=09=09=09zswap_max_pool_percent, uint, 0644);

This limit, along with the code that enforces it (by calling reclaim
when the limit is reached), is IMHO questionable.  Is there any
other kernel memory allocation that is constrained by a percentage
of total memory rather than dynamically according to current
system conditions?  As Mel pointed out (approx.), if this limit
is reached by a zswap-storm and filled with pages of long-running,
rarely-used processes, 20% of RAM (by default here) becomes forever
clogged.

Zswap reclaim/writeback needs to be cognizant of (and perhaps driven
by) system memory pressure, not some user-settable percentage.
There's some tough policy questions that need to be answered here,
perhaps not before zswap gets merged, but certainly before it
gets enabled by default by distros.

> +/*
> + * Maximum compression ratio, as as percentage, for an acceptable
> + * compressed page. Any pages that do not compress by at least
> + * this ratio will be rejected.
> +*/
> +static unsigned int zswap_max_compression_ratio =3D 80;
> +module_param_named(max_compression_ratio,
> +=09=09=09zswap_max_compression_ratio, uint, 0644);

Per earlier discussion, this number is actually derived
from a zsmalloc constraint and doesn't necessarily apply
to zbud.  And I don't think any mortal user or system
administrator would have any idea what value to change
this to or the potential impact of changing it.  IMHO
it should be removed, or at least moved to and enforced
by the specific allocator code.

> +/*********************************
> +* compression functions
> +**********************************/
> +/* per-cpu compression transforms */
> +static struct crypto_comp * __percpu *zswap_comp_pcpu_tfms;
> +
> +enum comp_op {
> +=09ZSWAP_COMPOP_COMPRESS,
> +=09ZSWAP_COMPOP_DECOMPRESS
> +};
> +
> +static int zswap_comp_op(enum comp_op op, const u8 *src, unsigned int sl=
en,
> +=09=09=09=09u8 *dst, unsigned int *dlen)
> +{
> +=09struct crypto_comp *tfm;
> +=09int ret;
> +
> +=09tfm =3D *per_cpu_ptr(zswap_comp_pcpu_tfms, get_cpu());
> +=09switch (op) {
> +=09case ZSWAP_COMPOP_COMPRESS:
> +=09=09ret =3D crypto_comp_compress(tfm, src, slen, dst, dlen);
> +=09=09break;
> +=09case ZSWAP_COMPOP_DECOMPRESS:
> +=09=09ret =3D crypto_comp_decompress(tfm, src, slen, dst, dlen);
> +=09=09break;
> +=09default:
> +=09=09ret =3D -EINVAL;
> +=09}
> +
> +=09put_cpu();
> +=09return ret;
> +}
> +
> +static int __init zswap_comp_init(void)
> +{
> +=09if (!crypto_has_comp(zswap_compressor, 0, 0)) {
> +=09=09pr_info("%s compressor not available\n", zswap_compressor);
> +=09=09/* fall back to default compressor */
> +=09=09zswap_compressor =3D ZSWAP_COMPRESSOR_DEFAULT;
> +=09=09if (!crypto_has_comp(zswap_compressor, 0, 0))
> +=09=09=09/* can't even load the default compressor */
> +=09=09=09return -ENODEV;
> +=09}
> +=09pr_info("using %s compressor\n", zswap_compressor);
> +
> +=09/* alloc percpu transforms */
> +=09zswap_comp_pcpu_tfms =3D alloc_percpu(struct crypto_comp *);
> +=09if (!zswap_comp_pcpu_tfms)
> +=09=09return -ENOMEM;
> +=09return 0;
> +}
> +
> +static void zswap_comp_exit(void)
> +{
> +=09/* free percpu transforms */
> +=09if (zswap_comp_pcpu_tfms)
> +=09=09free_percpu(zswap_comp_pcpu_tfms);
> +}
> +
> +/*********************************
> +* data structures
> +**********************************/
> +/*
> + * struct zswap_entry
> + *
> + * This structure contains the metadata for tracking a single compressed
> + * page within zswap.
> + *
> + * rbnode - links the entry into red-black tree for the appropriate swap=
 type
> + * refcount - the number of outstanding reference to the entry. This is =
needed
> + *            to protect against premature freeing of the entry by code
> + *            concurent calls to load, invalidate, and writeback.  The l=
ock
> + *            for the zswap_tree structure that contains the entry must
> + *            be held while changing the refcount.  Since the lock must
> + *            be held, there is no reason to also make refcount atomic.
> + * type - the swap type for the entry.  Used to map back to the zswap_tr=
ee
> + *        structure that contains the entry.
> + * offset - the swap offset for the entry.  Index into the red-black tre=
e.
> + * handle - zsmalloc allocation handle that stores the compressed page d=
ata
> + * length - the length in bytes of the compressed page data.  Needed dur=
ing
> + *           decompression
> + */
> +struct zswap_entry {
> +=09struct rb_node rbnode;
> +=09pgoff_t offset;
> +=09int refcount;
> +=09unsigned int length;
> +=09unsigned long handle;
> +};
> +
> +struct zswap_header {
> +=09swp_entry_t swpentry;
> +};
> +
> +/*
> + * The tree lock in the zswap_tree struct protects a few things:
> + * - the rbtree
> + * - the refcount field of each entry in the tree
> + */
> +struct zswap_tree {
> +=09struct rb_root rbroot;
> +=09spinlock_t lock;
> +=09struct zbud_pool *pool;
> +=09unsigned type;
> +};
> +
> +static struct zswap_tree *zswap_trees[MAX_SWAPFILES];
> +
> +/*********************************
> +* zswap entry functions
> +**********************************/
> +#define ZSWAP_KMEM_CACHE_NAME "zswap_entry_cache"
> +static struct kmem_cache *zswap_entry_cache;
> +
> +static inline int zswap_entry_cache_create(void)
> +{
> +=09zswap_entry_cache =3D
> +=09=09kmem_cache_create(ZSWAP_KMEM_CACHE_NAME,
> +=09=09=09sizeof(struct zswap_entry), 0, 0, NULL);
> +=09return (zswap_entry_cache =3D=3D NULL);
> +}
> +
> +static inline void zswap_entry_cache_destory(void)
> +{
> +=09kmem_cache_destroy(zswap_entry_cache);
> +}
> +
> +static inline struct zswap_entry *zswap_entry_cache_alloc(gfp_t gfp)
> +{
> +=09struct zswap_entry *entry;
> +=09entry =3D kmem_cache_alloc(zswap_entry_cache, gfp);
> +=09if (!entry)
> +=09=09return NULL;
> +=09entry->refcount =3D 1;
> +=09return entry;
> +}
> +
> +static inline void zswap_entry_cache_free(struct zswap_entry *entry)
> +{
> +=09kmem_cache_free(zswap_entry_cache, entry);
> +}
> +
> +static inline void zswap_entry_get(struct zswap_entry *entry)
> +{
> +=09entry->refcount++;
> +}
> +
> +static inline int zswap_entry_put(struct zswap_entry *entry)
> +{
> +=09entry->refcount--;
> +=09return entry->refcount;
> +}
> +
> +/*********************************
> +* rbtree functions
> +**********************************/
> +static struct zswap_entry *zswap_rb_search(struct rb_root *root, pgoff_t=
 offset)
> +{
> +=09struct rb_node *node =3D root->rb_node;
> +=09struct zswap_entry *entry;
> +
> +=09while (node) {
> +=09=09entry =3D rb_entry(node, struct zswap_entry, rbnode);
> +=09=09if (entry->offset > offset)
> +=09=09=09node =3D node->rb_left;
> +=09=09else if (entry->offset < offset)
> +=09=09=09node =3D node->rb_right;
> +=09=09else
> +=09=09=09return entry;
> +=09}
> +=09return NULL;
> +}
> +
> +/*
> + * In the case that a entry with the same offset is found, it a pointer =
to
> + * the existing entry is stored in dupentry and the function returns -EE=
XIST
> +*/
> +static int zswap_rb_insert(struct rb_root *root, struct zswap_entry *ent=
ry,
> +=09=09=09struct zswap_entry **dupentry)
> +{
> +=09struct rb_node **link =3D &root->rb_node, *parent =3D NULL;
> +=09struct zswap_entry *myentry;
> +
> +=09while (*link) {
> +=09=09parent =3D *link;
> +=09=09myentry =3D rb_entry(parent, struct zswap_entry, rbnode);
> +=09=09if (myentry->offset > entry->offset)
> +=09=09=09link =3D &(*link)->rb_left;
> +=09=09else if (myentry->offset < entry->offset)
> +=09=09=09link =3D &(*link)->rb_right;
> +=09=09else {
> +=09=09=09*dupentry =3D myentry;
> +=09=09=09return -EEXIST;
> +=09=09}
> +=09}
> +=09rb_link_node(&entry->rbnode, parent, link);
> +=09rb_insert_color(&entry->rbnode, root);
> +=09return 0;
> +}
> +
> +/*********************************
> +* per-cpu code
> +**********************************/
> +static DEFINE_PER_CPU(u8 *, zswap_dstmem);
> +
> +static int __zswap_cpu_notifier(unsigned long action, unsigned long cpu)
> +{
> +=09struct crypto_comp *tfm;
> +=09u8 *dst;
> +
> +=09switch (action) {
> +=09case CPU_UP_PREPARE:
> +=09=09tfm =3D crypto_alloc_comp(zswap_compressor, 0, 0);
> +=09=09if (IS_ERR(tfm)) {
> +=09=09=09pr_err("can't allocate compressor transform\n");
> +=09=09=09return NOTIFY_BAD;
> +=09=09}
> +=09=09*per_cpu_ptr(zswap_comp_pcpu_tfms, cpu) =3D tfm;
> +=09=09dst =3D kmalloc(PAGE_SIZE * 2, GFP_KERNEL);
> +=09=09if (!dst) {
> +=09=09=09pr_err("can't allocate compressor buffer\n");
> +=09=09=09crypto_free_comp(tfm);
> +=09=09=09*per_cpu_ptr(zswap_comp_pcpu_tfms, cpu) =3D NULL;
> +=09=09=09return NOTIFY_BAD;
> +=09=09}
> +=09=09per_cpu(zswap_dstmem, cpu) =3D dst;
> +=09=09break;
> +=09case CPU_DEAD:
> +=09case CPU_UP_CANCELED:
> +=09=09tfm =3D *per_cpu_ptr(zswap_comp_pcpu_tfms, cpu);
> +=09=09if (tfm) {
> +=09=09=09crypto_free_comp(tfm);
> +=09=09=09*per_cpu_ptr(zswap_comp_pcpu_tfms, cpu) =3D NULL;
> +=09=09}
> +=09=09dst =3D per_cpu(zswap_dstmem, cpu);
> +=09=09kfree(dst);
> +=09=09per_cpu(zswap_dstmem, cpu) =3D NULL;
> +=09=09break;
> +=09default:
> +=09=09break;
> +=09}
> +=09return NOTIFY_OK;
> +}
> +
> +static int zswap_cpu_notifier(struct notifier_block *nb,
> +=09=09=09=09unsigned long action, void *pcpu)
> +{
> +=09unsigned long cpu =3D (unsigned long)pcpu;
> +=09return __zswap_cpu_notifier(action, cpu);
> +}
> +
> +static struct notifier_block zswap_cpu_notifier_block =3D {
> +=09.notifier_call =3D zswap_cpu_notifier
> +};
> +
> +static int zswap_cpu_init(void)
> +{
> +=09unsigned long cpu;
> +
> +=09get_online_cpus();
> +=09for_each_online_cpu(cpu)
> +=09=09if (__zswap_cpu_notifier(CPU_UP_PREPARE, cpu) !=3D NOTIFY_OK)
> +=09=09=09goto cleanup;
> +=09register_cpu_notifier(&zswap_cpu_notifier_block);
> +=09put_online_cpus();
> +=09return 0;
> +
> +cleanup:
> +=09for_each_online_cpu(cpu)
> +=09=09__zswap_cpu_notifier(CPU_UP_CANCELED, cpu);
> +=09put_online_cpus();
> +=09return -ENOMEM;
> +}
> +
> +/*********************************
> +* helpers
> +**********************************/
> +static inline bool zswap_is_full(void)
> +{
> +=09int pool_pages =3D atomic_read(&zswap_pool_pages);
> +=09return (totalram_pages * zswap_max_pool_percent / 100 < pool_pages);
> +}
> +
> +/*
> + * Carries out the common pattern of freeing and entry's zsmalloc alloca=
tion,
> + * freeing the entry itself, and decrementing the number of stored pages=
.
> + */
> +static void zswap_free_entry(struct zswap_tree *tree, struct zswap_entry=
 *entry)
> +{
> +=09zbud_free(tree->pool, entry->handle);
> +=09zswap_entry_cache_free(entry);
> +=09atomic_dec(&zswap_stored_pages);
> +=09atomic_set(&zswap_pool_pages, zbud_get_pool_size(tree->pool));
> +}
> +
> +/*********************************
> +* writeback code
> +**********************************/
> +/* return enum for zswap_get_swap_cache_page */
> +enum zswap_get_swap_ret {
> +=09ZSWAP_SWAPCACHE_NEW,
> +=09ZSWAP_SWAPCACHE_EXIST,
> +=09ZSWAP_SWAPCACHE_NOMEM
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
> +=09=09=09=09struct page **retpage)
> +{
> +=09struct page *found_page, *new_page =3D NULL;
> +=09struct address_space *swapper_space =3D &swapper_spaces[swp_type(entr=
y)];
> +=09int err;
> +
> +=09*retpage =3D NULL;
> +=09do {
> +=09=09/*
> +=09=09 * First check the swap cache.  Since this is normally
> +=09=09 * called after lookup_swap_cache() failed, re-calling
> +=09=09 * that would confuse statistics.
> +=09=09 */
> +=09=09found_page =3D find_get_page(swapper_space, entry.val);
> +=09=09if (found_page)
> +=09=09=09break;
> +
> +=09=09/*
> +=09=09 * Get a new page to read into from swap.
> +=09=09 */
> +=09=09if (!new_page) {
> +=09=09=09new_page =3D alloc_page(GFP_KERNEL);
> +=09=09=09if (!new_page)
> +=09=09=09=09break; /* Out of memory */
> +=09=09}
> +
> +=09=09/*
> +=09=09 * call radix_tree_preload() while we can wait.
> +=09=09 */
> +=09=09err =3D radix_tree_preload(GFP_KERNEL);
> +=09=09if (err)
> +=09=09=09break;
> +
> +=09=09/*
> +=09=09 * Swap entry may have been freed since our caller observed it.
> +=09=09 */
> +=09=09err =3D swapcache_prepare(entry);
> +=09=09if (err =3D=3D -EEXIST) { /* seems racy */
> +=09=09=09radix_tree_preload_end();
> +=09=09=09continue;
> +=09=09}
> +=09=09if (err) { /* swp entry is obsolete ? */
> +=09=09=09radix_tree_preload_end();
> +=09=09=09break;
> +=09=09}
> +
> +=09=09/* May fail (-ENOMEM) if radix-tree node allocation failed. */
> +=09=09__set_page_locked(new_page);
> +=09=09SetPageSwapBacked(new_page);
> +=09=09err =3D __add_to_swap_cache(new_page, entry);
> +=09=09if (likely(!err)) {
> +=09=09=09radix_tree_preload_end();
> +=09=09=09lru_cache_add_anon(new_page);
> +=09=09=09*retpage =3D new_page;
> +=09=09=09return ZSWAP_SWAPCACHE_NEW;
> +=09=09}
> +=09=09radix_tree_preload_end();
> +=09=09ClearPageSwapBacked(new_page);
> +=09=09__clear_page_locked(new_page);
> +=09=09/*
> +=09=09 * add_to_swap_cache() doesn't return -EEXIST, so we can safely
> +=09=09 * clear SWAP_HAS_CACHE flag.
> +=09=09 */
> +=09=09swapcache_free(entry, NULL);
> +=09} while (err !=3D -ENOMEM);
> +
> +=09if (new_page)
> +=09=09page_cache_release(new_page);
> +=09if (!found_page)
> +=09=09return ZSWAP_SWAPCACHE_NOMEM;
> +=09*retpage =3D found_page;
> +=09return ZSWAP_SWAPCACHE_EXIST;
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
> +static int zswap_writeback_entry(struct zbud_pool *pool, unsigned long h=
andle)
> +{
> +=09struct zswap_header *zhdr;
> +=09swp_entry_t swpentry;
> +=09struct zswap_tree *tree;
> +=09pgoff_t offset;
> +=09struct zswap_entry *entry;
> +=09struct page *page;
> +=09u8 *src, *dst;
> +=09unsigned int dlen;
> +=09int ret, refcount;
> +=09struct writeback_control wbc =3D {
> +=09=09.sync_mode =3D WB_SYNC_NONE,
> +=09};
> +
> +=09/* extract swpentry from data */
> +=09zhdr =3D zbud_map(pool, handle);
> +=09swpentry =3D zhdr->swpentry; /* here */
> +=09zbud_unmap(pool, handle);
> +=09tree =3D zswap_trees[swp_type(swpentry)];
> +=09offset =3D swp_offset(swpentry);
> +=09BUG_ON(pool !=3D tree->pool);
> +
> +=09/* find and ref zswap entry */
> +=09spin_lock(&tree->lock);
> +=09entry =3D zswap_rb_search(&tree->rbroot, offset);
> +=09if (!entry) {
> +=09=09/* entry was invalidated */
> +=09=09spin_unlock(&tree->lock);
> +=09=09return 0;
> +=09}
> +=09zswap_entry_get(entry);
> +=09spin_unlock(&tree->lock);
> +=09BUG_ON(offset !=3D entry->offset);
> +
> +=09/* try to allocate swap cache page */
> +=09switch (zswap_get_swap_cache_page(swpentry, &page)) {
> +=09case ZSWAP_SWAPCACHE_NOMEM: /* no memory */
> +=09=09ret =3D -ENOMEM;
> +=09=09goto fail;
> +
> +=09case ZSWAP_SWAPCACHE_EXIST: /* page is unlocked */
> +=09=09/* page is already in the swap cache, ignore for now */
> +=09=09page_cache_release(page);
> +=09=09ret =3D -EEXIST;
> +=09=09goto fail;
> +
> +=09case ZSWAP_SWAPCACHE_NEW: /* page is locked */
> +=09=09/* decompress */
> +=09=09dlen =3D PAGE_SIZE;
> +=09=09src =3D (u8 *)zbud_map(tree->pool, entry->handle) +
> +=09=09=09sizeof(struct zswap_header);
> +=09=09dst =3D kmap_atomic(page);
> +=09=09ret =3D zswap_comp_op(ZSWAP_COMPOP_DECOMPRESS, src,
> +=09=09=09=09entry->length, dst, &dlen);
> +=09=09kunmap_atomic(dst);
> +=09=09zbud_unmap(tree->pool, entry->handle);
> +=09=09BUG_ON(ret);
> +=09=09BUG_ON(dlen !=3D PAGE_SIZE);
> +
> +=09=09/* page is up to date */
> +=09=09SetPageUptodate(page);
> +=09}
> +
> +=09/* start writeback */
> +=09SetPageReclaim(page);
> +=09__swap_writepage(page, &wbc, end_swap_bio_write);
> +=09page_cache_release(page);
> +=09zswap_written_back_pages++;
> +
> +=09spin_lock(&tree->lock);
> +
> +=09/* drop local reference */
> +=09zswap_entry_put(entry);
> +=09/* drop the initial reference from entry creation */
> +=09refcount =3D zswap_entry_put(entry);
> +
> +=09/*
> +=09 * There are three possible values for refcount here:
> +=09 * (1) refcount is 1, load is in progress, unlink from rbtree,
> +=09 *     load will free
> +=09 * (2) refcount is 0, (normal case) entry is valid,
> +=09 *     remove from rbtree and free entry
> +=09 * (3) refcount is -1, invalidate happened during writeback,
> +=09 *     free entry
> +=09 */
> +=09if (refcount >=3D 0) {
> +=09=09/* no invalidate yet, remove from rbtree */
> +=09=09rb_erase(&entry->rbnode, &tree->rbroot);
> +=09}
> +=09spin_unlock(&tree->lock);
> +=09if (refcount <=3D 0) {
> +=09=09/* free the entry */
> +=09=09zswap_free_entry(tree, entry);
> +=09=09return 0;
> +=09}
> +=09return -EAGAIN;
> +
> +fail:
> +=09spin_lock(&tree->lock);
> +=09zswap_entry_put(entry);
> +=09spin_unlock(&tree->lock);
> +=09return ret;
> +}
> +
> +/*********************************
> +* frontswap hooks
> +**********************************/
> +/* attempts to compress and store an single page */
> +static int zswap_frontswap_store(unsigned type, pgoff_t offset,
> +=09=09=09=09struct page *page)
> +{
> +=09struct zswap_tree *tree =3D zswap_trees[type];
> +=09struct zswap_entry *entry, *dupentry;
> +=09int ret;
> +=09unsigned int dlen =3D PAGE_SIZE, len;
> +=09unsigned long handle;
> +=09char *buf;
> +=09u8 *src, *dst;
> +=09struct zswap_header *zhdr;
> +
> +=09if (!tree) {
> +=09=09ret =3D -ENODEV;
> +=09=09goto reject;
> +=09}
> +
> +=09/* reclaim space if needed */
> +=09if (zswap_is_full()) {
> +=09=09zswap_pool_limit_hit++;
> +=09=09if (zbud_reclaim_page(tree->pool, 8)) {
> +=09=09=09zswap_reject_reclaim_fail++;
> +=09=09=09ret =3D -ENOMEM;
> +=09=09=09goto reject;
> +=09=09}
> +=09}

See comment above about enforcing "full".

(No further comments below... Thanks, Dan)

> +=09/* allocate entry */
> +=09entry =3D zswap_entry_cache_alloc(GFP_KERNEL);
> +=09if (!entry) {
> +=09=09zswap_reject_kmemcache_fail++;
> +=09=09ret =3D -ENOMEM;
> +=09=09goto reject;
> +=09}
> +
> +=09/* compress */
> +=09dst =3D get_cpu_var(zswap_dstmem);
> +=09src =3D kmap_atomic(page);
> +=09ret =3D zswap_comp_op(ZSWAP_COMPOP_COMPRESS, src, PAGE_SIZE, dst, &dl=
en);
> +=09kunmap_atomic(src);
> +=09if (ret) {
> +=09=09ret =3D -EINVAL;
> +=09=09goto freepage;
> +=09}
> +=09len =3D dlen + sizeof(struct zswap_header);
> +=09if ((len * 100 / PAGE_SIZE) > zswap_max_compression_ratio) {
> +=09=09zswap_reject_compress_poor++;
> +=09=09ret =3D -E2BIG;
> +=09=09goto freepage;
> +=09}
> +
> +=09/* store */
> +=09ret =3D zbud_alloc(tree->pool, len, __GFP_NORETRY | __GFP_NOWARN,
> +=09=09&handle);
> +=09if (ret) {
> +=09=09zswap_reject_alloc_fail++;
> +=09=09goto freepage;
> +=09}
> +=09zhdr =3D zbud_map(tree->pool, handle);
> +=09zhdr->swpentry =3D swp_entry(type, offset);
> +=09buf =3D (u8 *)(zhdr + 1);
> +=09memcpy(buf, dst, dlen);
> +=09zbud_unmap(tree->pool, handle);
> +=09put_cpu_var(zswap_dstmem);
> +
> +=09/* populate entry */
> +=09entry->offset =3D offset;
> +=09entry->handle =3D handle;
> +=09entry->length =3D dlen;
> +
> +=09/* map */
> +=09spin_lock(&tree->lock);
> +=09do {
> +=09=09ret =3D zswap_rb_insert(&tree->rbroot, entry, &dupentry);
> +=09=09if (ret =3D=3D -EEXIST) {
> +=09=09=09zswap_duplicate_entry++;
> +=09=09=09/* remove from rbtree */
> +=09=09=09rb_erase(&dupentry->rbnode, &tree->rbroot);
> +=09=09=09if (!zswap_entry_put(dupentry)) {
> +=09=09=09=09/* free */
> +=09=09=09=09zswap_free_entry(tree, dupentry);
> +=09=09=09}
> +=09=09}
> +=09} while (ret =3D=3D -EEXIST);
> +=09spin_unlock(&tree->lock);
> +
> +=09/* update stats */
> +=09atomic_inc(&zswap_stored_pages);
> +=09atomic_set(&zswap_pool_pages, zbud_get_pool_size(tree->pool));
> +
> +=09return 0;
> +
> +freepage:
> +=09put_cpu_var(zswap_dstmem);
> +=09zswap_entry_cache_free(entry);
> +reject:
> +=09return ret;
> +}
> +
> +/*
> + * returns 0 if the page was successfully decompressed
> + * return -1 on entry not found or error
> +*/
> +static int zswap_frontswap_load(unsigned type, pgoff_t offset,
> +=09=09=09=09struct page *page)
> +{
> +=09struct zswap_tree *tree =3D zswap_trees[type];
> +=09struct zswap_entry *entry;
> +=09u8 *src, *dst;
> +=09unsigned int dlen;
> +=09int refcount, ret;
> +
> +=09/* find */
> +=09spin_lock(&tree->lock);
> +=09entry =3D zswap_rb_search(&tree->rbroot, offset);
> +=09if (!entry) {
> +=09=09/* entry was written back */
> +=09=09spin_unlock(&tree->lock);
> +=09=09return -1;
> +=09}
> +=09zswap_entry_get(entry);
> +=09spin_unlock(&tree->lock);
> +
> +=09/* decompress */
> +=09dlen =3D PAGE_SIZE;
> +=09src =3D (u8 *)zbud_map(tree->pool, entry->handle) +
> +=09=09=09sizeof(struct zswap_header);
> +=09dst =3D kmap_atomic(page);
> +=09ret =3D zswap_comp_op(ZSWAP_COMPOP_DECOMPRESS, src, entry->length,
> +=09=09dst, &dlen);
> +=09kunmap_atomic(dst);
> +=09zbud_unmap(tree->pool, entry->handle);
> +=09BUG_ON(ret);
> +
> +=09spin_lock(&tree->lock);
> +=09refcount =3D zswap_entry_put(entry);
> +=09if (likely(refcount)) {
> +=09=09spin_unlock(&tree->lock);
> +=09=09return 0;
> +=09}
> +=09spin_unlock(&tree->lock);
> +
> +=09/*
> +=09 * We don't have to unlink from the rbtree because
> +=09 * zswap_writeback_entry() or zswap_frontswap_invalidate page()
> +=09 * has already done this for us if we are the last reference.
> +=09 */
> +=09/* free */
> +
> +=09zswap_free_entry(tree, entry);
> +
> +=09return 0;
> +}
> +
> +/* invalidates a single page */
> +static void zswap_frontswap_invalidate_page(unsigned type, pgoff_t offse=
t)
> +{
> +=09struct zswap_tree *tree =3D zswap_trees[type];
> +=09struct zswap_entry *entry;
> +=09int refcount;
> +
> +=09/* find */
> +=09spin_lock(&tree->lock);
> +=09entry =3D zswap_rb_search(&tree->rbroot, offset);
> +=09if (!entry) {
> +=09=09/* entry was written back */
> +=09=09spin_unlock(&tree->lock);
> +=09=09return;
> +=09}
> +
> +=09/* remove from rbtree */
> +=09rb_erase(&entry->rbnode, &tree->rbroot);
> +
> +=09/* drop the initial reference from entry creation */
> +=09refcount =3D zswap_entry_put(entry);
> +
> +=09spin_unlock(&tree->lock);
> +
> +=09if (refcount) {
> +=09=09/* writeback in progress, writeback will free */
> +=09=09return;
> +=09}
> +
> +=09/* free */
> +=09zswap_free_entry(tree, entry);
> +}
> +
> +/* invalidates all pages for the given swap type */
> +static void zswap_frontswap_invalidate_area(unsigned type)
> +{
> +=09struct zswap_tree *tree =3D zswap_trees[type];
> +=09struct rb_node *node;
> +=09struct zswap_entry *entry;
> +
> +=09if (!tree)
> +=09=09return;
> +
> +=09/* walk the tree and free everything */
> +=09spin_lock(&tree->lock);
> +=09/*
> +=09 * TODO: Even though this code should not be executed because
> +=09 * the try_to_unuse() in swapoff should have emptied the tree,
> +=09 * it is very wasteful to rebalance the tree after every
> +=09 * removal when we are freeing the whole tree.
> +=09 *
> +=09 * If post-order traversal code is ever added to the rbtree
> +=09 * implementation, it should be used here.
> +=09 */
> +=09while ((node =3D rb_first(&tree->rbroot))) {
> +=09=09entry =3D rb_entry(node, struct zswap_entry, rbnode);
> +=09=09rb_erase(&entry->rbnode, &tree->rbroot);
> +=09=09zbud_free(tree->pool, entry->handle);
> +=09=09zswap_entry_cache_free(entry);
> +=09=09atomic_dec(&zswap_stored_pages);
> +=09}
> +=09tree->rbroot =3D RB_ROOT;
> +=09spin_unlock(&tree->lock);
> +}
> +
> +static struct zbud_ops zswap_zbud_ops =3D {
> +=09.evict =3D zswap_writeback_entry
> +};
> +
> +/* NOTE: this is called in atomic context from swapon and must not sleep=
 */
> +static void zswap_frontswap_init(unsigned type)
> +{
> +=09struct zswap_tree *tree;
> +
> +=09tree =3D kzalloc(sizeof(struct zswap_tree), GFP_ATOMIC);
> +=09if (!tree)
> +=09=09goto err;
> +=09tree->pool =3D zbud_create_pool(GFP_NOWAIT, &zswap_zbud_ops);
> +=09if (!tree->pool)
> +=09=09goto freetree;
> +=09tree->rbroot =3D RB_ROOT;
> +=09spin_lock_init(&tree->lock);
> +=09tree->type =3D type;
> +=09zswap_trees[type] =3D tree;
> +=09return;
> +
> +freetree:
> +=09kfree(tree);
> +err:
> +=09pr_err("alloc failed, zswap disabled for swap type %d\n", type);
> +}
> +
> +static struct frontswap_ops zswap_frontswap_ops =3D {
> +=09.store =3D zswap_frontswap_store,
> +=09.load =3D zswap_frontswap_load,
> +=09.invalidate_page =3D zswap_frontswap_invalidate_page,
> +=09.invalidate_area =3D zswap_frontswap_invalidate_area,
> +=09.init =3D zswap_frontswap_init
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
> +=09if (!debugfs_initialized())
> +=09=09return -ENODEV;
> +
> +=09zswap_debugfs_root =3D debugfs_create_dir("zswap", NULL);
> +=09if (!zswap_debugfs_root)
> +=09=09return -ENOMEM;
> +
> +=09debugfs_create_u64("pool_limit_hit", S_IRUGO,
> +=09=09=09zswap_debugfs_root, &zswap_pool_limit_hit);
> +=09debugfs_create_u64("reject_reclaim_fail", S_IRUGO,
> +=09=09=09zswap_debugfs_root, &zswap_reject_reclaim_fail);
> +=09debugfs_create_u64("reject_alloc_fail", S_IRUGO,
> +=09=09=09zswap_debugfs_root, &zswap_reject_alloc_fail);
> +=09debugfs_create_u64("reject_kmemcache_fail", S_IRUGO,
> +=09=09=09zswap_debugfs_root, &zswap_reject_kmemcache_fail);
> +=09debugfs_create_u64("reject_compress_poor", S_IRUGO,
> +=09=09=09zswap_debugfs_root, &zswap_reject_compress_poor);
> +=09debugfs_create_u64("written_back_pages", S_IRUGO,
> +=09=09=09zswap_debugfs_root, &zswap_written_back_pages);
> +=09debugfs_create_u64("duplicate_entry", S_IRUGO,
> +=09=09=09zswap_debugfs_root, &zswap_duplicate_entry);
> +=09debugfs_create_atomic_t("pool_pages", S_IRUGO,
> +=09=09=09zswap_debugfs_root, &zswap_pool_pages);
> +=09debugfs_create_atomic_t("stored_pages", S_IRUGO,
> +=09=09=09zswap_debugfs_root, &zswap_stored_pages);
> +
> +=09return 0;
> +}
> +
> +static void __exit zswap_debugfs_exit(void)
> +{
> +=09debugfs_remove_recursive(zswap_debugfs_root);
> +}
> +#else
> +static inline int __init zswap_debugfs_init(void)
> +{
> +=09return 0;
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
> +=09if (!zswap_enabled)
> +=09=09return 0;
> +
> +=09pr_info("loading zswap\n");
> +=09if (zswap_entry_cache_create()) {
> +=09=09pr_err("entry cache creation failed\n");
> +=09=09goto error;
> +=09}
> +=09if (zswap_comp_init()) {
> +=09=09pr_err("compressor initialization failed\n");
> +=09=09goto compfail;
> +=09}
> +=09if (zswap_cpu_init()) {
> +=09=09pr_err("per-cpu initialization failed\n");
> +=09=09goto pcpufail;
> +=09}
> +=09frontswap_register_ops(&zswap_frontswap_ops);
> +=09if (zswap_debugfs_init())
> +=09=09pr_warn("debugfs initialization failed\n");
> +=09return 0;
> +pcpufail:
> +=09zswap_comp_exit();
> +compfail:
> +=09zswap_entry_cache_destory();
> +error:
> +=09return -ENOMEM;
> +}
> +/* must be late so crypto has time to come up */
> +late_initcall(init_zswap);
> +
> +MODULE_LICENSE("GPL");
> +MODULE_AUTHOR("Seth Jennings <sjenning@linux.vnet.ibm.com>");
> +MODULE_DESCRIPTION("Compressed cache for swap pages");
> --
> 1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
