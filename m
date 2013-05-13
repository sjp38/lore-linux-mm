Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id CEB966B0002
	for <linux-mm@kvack.org>; Mon, 13 May 2013 11:43:54 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <3dfa0c20-ab39-4839-aaeb-46d51314afd4@default>
Date: Mon, 13 May 2013 08:43:36 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCHv11 2/4] zbud: add to mm/
References: <<1368448803-2089-1-git-send-email-sjenning@linux.vnet.ibm.com>>
 <<1368448803-2089-3-git-send-email-sjenning@linux.vnet.ibm.com>>
In-Reply-To: <<1368448803-2089-3-git-send-email-sjenning@linux.vnet.ibm.com>>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@sr71.net>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Hugh Dickens <hughd@google.com>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> Sent: Monday, May 13, 2013 6:40 AM
> Subject: [PATCHv11 2/4] zbud: add to mm/

One comment about a questionable algorithm change (vs my original zbud code=
)
below... I'll leave the detailed code review to others.

Dan

> zbud is an special purpose allocator for storing compressed pages. It is
> designed to store up to two compressed pages per physical page.  While th=
is
> design limits storage density, it has simple and deterministic reclaim
> properties that make it preferable to a higher density approach when recl=
aim
> will be used.
>=20
> zbud works by storing compressed pages, or "zpages", together in pairs in=
 a
> single memory page called a "zbud page".  The first buddy is "left
> justifed" at the beginning of the zbud page, and the last buddy is "right
> justified" at the end of the zbud page.  The benefit is that if either
> buddy is freed, the freed buddy space, coalesced with whatever slack spac=
e
> that existed between the buddies, results in the largest possible free re=
gion
> within the zbud page.
>=20
> zbud also provides an attractive lower bound on density. The ratio of zpa=
ges
> to zbud pages can not be less than 1.  This ensures that zbud can never "=
do
> harm" by using more pages to store zpages than the uncompressed zpages wo=
uld
> have used on their own.
>=20
> This patch adds zbud to mm/ for later use by zswap.
>=20
> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
> ---
>  include/linux/zbud.h |   22 ++
>  mm/Kconfig           |   10 +
>  mm/Makefile          |    1 +
>  mm/zbud.c            |  564 ++++++++++++++++++++++++++++++++++++++++++++=
++++++
>  4 files changed, 597 insertions(+)
>  create mode 100644 include/linux/zbud.h
>  create mode 100644 mm/zbud.c
>=20
> diff --git a/include/linux/zbud.h b/include/linux/zbud.h
> new file mode 100644
> index 0000000..954252b
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
> +=09int (*evict)(struct zbud_pool *pool, unsigned long handle);
> +};
> +
> +struct zbud_pool *zbud_create_pool(gfp_t gfp, struct zbud_ops *ops);
> +void zbud_destroy_pool(struct zbud_pool *pool);
> +int zbud_alloc(struct zbud_pool *pool, int size, gfp_t gfp,
> +=09unsigned long *handle);
> +void zbud_free(struct zbud_pool *pool, unsigned long handle);
> +int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries);
> +void *zbud_map(struct zbud_pool *pool, unsigned long handle);
> +void zbud_unmap(struct zbud_pool *pool, unsigned long handle);
> +int zbud_get_pool_size(struct zbud_pool *pool);
> +
> +#endif /* _ZBUD_H_ */
> diff --git a/mm/Kconfig b/mm/Kconfig
> index e742d06..908f41b 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -477,3 +477,13 @@ config FRONTSWAP
>  =09  and swap data is stored as normal on the matching swap device.
>=20
>  =09  If unsure, say Y to enable frontswap.
> +
> +config ZBUD
> +=09tristate "Buddy allocator for compressed pages"
> +=09default n
> +=09help
> +=09  zbud is an special purpose allocator for storing compressed pages.
> +=09  It is designed to store up to two compressed pages per physical pag=
e.
> +=09  While this design limits storage density, it has simple and
> +=09  deterministic reclaim properties that make it preferable to a highe=
r
> +=09  density approach when reclaim will be used.
> diff --git a/mm/Makefile b/mm/Makefile
> index 72c5acb..95f0197 100644
> --- a/mm/Makefile
> +++ b/mm/Makefile
> @@ -58,3 +58,4 @@ obj-$(CONFIG_DEBUG_KMEMLEAK) +=3D kmemleak.o
>  obj-$(CONFIG_DEBUG_KMEMLEAK_TEST) +=3D kmemleak-test.o
>  obj-$(CONFIG_CLEANCACHE) +=3D cleancache.o
>  obj-$(CONFIG_MEMORY_ISOLATION) +=3D page_isolation.o
> +obj-$(CONFIG_ZBUD)=09+=3D zbud.o
> diff --git a/mm/zbud.c b/mm/zbud.c
> new file mode 100644
> index 0000000..e5bd0e6
> --- /dev/null
> +++ b/mm/zbud.c
> @@ -0,0 +1,564 @@
> +/*
> + * zbud.c - Buddy Allocator for Compressed Pages
> + *
> + * Copyright (C) 2013, Seth Jennings, IBM
> + *
> + * Concepts based on zcache internal zbud allocator by Dan Magenheimer.
> + *
> + * zbud is an special purpose allocator for storing compressed pages. It=
 is
> + * designed to store up to two compressed pages per physical page.  Whil=
e this
> + * design limits storage density, it has simple and deterministic reclai=
m
> + * properties that make it preferable to a higher density approach when =
reclaim
> + * will be used.
> + *
> + * zbud works by storing compressed pages, or "zpages", together in pair=
s in a
> + * single memory page called a "zbud page".  The first buddy is "left
> + * justifed" at the beginning of the zbud page, and the last buddy is "r=
ight
> + * justified" at the end of the zbud page.  The benefit is that if eithe=
r
> + * buddy is freed, the freed buddy space, coalesced with whatever slack =
space
> + * that existed between the buddies, results in the largest possible fre=
e region
> + * within the zbud page.
> + *
> + * zbud also provides an attractive lower bound on density. The ratio of=
 zpages
> + * to zbud pages can not be less than 1.  This ensures that zbud can nev=
er "do
> + * harm" by using more pages to store zpages than the uncompressed zpage=
s would
> + * have used on their own.
> + *
> + * zbud pages are divided into "chunks".  The size of the chunks is fixe=
d at
> + * compile time and determined by NCHUNKS_ORDER below.  Dividing zbud pa=
ges
> + * into chunks allows organizing unbuddied zbud pages into a manageable =
number
> + * of unbuddied lists according to the number of free chunks available i=
n the
> + * zbud page.
> + *
> + * The zbud API differs from that of conventional allocators in that the
> + * allocation function, zbud_alloc(), returns an opaque handle to the us=
er,
> + * not a dereferenceable pointer.  The user must map the handle using
> + * zbud_map() in order to get a usable pointer by which to access the
> + * allocation data and unmap the handle with zbud_unmap() when operation=
s
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
> +/**
> + * struct zbud_page - zbud page metadata overlay
> + * @page:=09typed reference to the underlying struct page
> + * @donotuse:=09this overlays the page flags and should not be used
> + * @first_chunks:=09the size of the first buddy in chunks, 0 if free
> + * @last_chunks:=09the size of the last buddy in chunks, 0 if free
> + * @buddy:=09links the zbud page into the unbuddied/buddied lists in the=
 pool
> + * @lru:=09links the zbud page into the lru list in the pool
> + *
> + * This structure overlays the struct page to store metadata needed for =
a
> + * single storage page in for zbud.  There is a BUILD_BUG_ON in zbud_ini=
t()
> + * that ensures this structure is not larger that struct page.
> + *
> + * The PG_reclaim flag of the underlying page is used for indicating
> + * that this zbud page is under reclaim (see zbud_reclaim_page())
> + */
> +struct zbud_page {
> +=09union {
> +=09=09struct page page;
> +=09=09struct {
> +=09=09=09unsigned long donotuse;
> +=09=09=09u16 first_chunks;
> +=09=09=09u16 last_chunks;
> +=09=09=09struct list_head buddy;
> +=09=09=09struct list_head lru;
> +=09=09};
> +=09};
> +};
> +
> +/*
> + * NCHUNKS_ORDER determines the internal allocation granularity, effecti=
vely
> + * adjusting internal fragmentation.  It also determines the number of
> + * freelists maintained in each pool. NCHUNKS_ORDER of 6 means that the
> + * allocation granularity will be in chunks of size PAGE_SIZE/64, and th=
ere
> + * will be 64 freelists per pool.
> + */
> +#define NCHUNKS_ORDER=096
> +
> +#define CHUNK_SHIFT=09(PAGE_SHIFT - NCHUNKS_ORDER)
> +#define CHUNK_SIZE=09(1 << CHUNK_SHIFT)
> +#define NCHUNKS=09=09(PAGE_SIZE >> CHUNK_SHIFT)
> +
> +/**
> + * struct zbud_pool - stores metadata for each zbud pool
> + * @lock:=09protects all pool lists and first|last_chunk fields of any
> + *=09=09zbud page in the pool
> + * @unbuddied:=09array of lists tracking zbud pages that only contain on=
e buddy;
> + *=09=09the lists each zbud page is added to depends on the size of
> + *=09=09its free region.
> + * @buddied:=09list tracking the zbud pages that contain two buddies;
> + *=09=09these zbud pages are full
> + * @pages_nr:=09number of zbud pages in the pool.
> + * @ops:=09pointer to a structure of user defined operations specified a=
t
> + *=09=09pool creation time.
> + *
> + * This structure is allocated at pool creation time and maintains metad=
ata
> + * pertaining to a particular zbud pool.
> + */
> +struct zbud_pool {
> +=09spinlock_t lock;
> +=09struct list_head unbuddied[NCHUNKS];
> +=09struct list_head buddied;
> +=09struct list_head lru;
> +=09atomic_t pages_nr;
> +=09struct zbud_ops *ops;
> +};
> +
> +/*****************
> + * Helpers
> +*****************/
> +/* Just to make the code easier to read */
> +enum buddy {
> +=09FIRST,
> +=09LAST
> +};
> +
> +/* Converts an allocation size in bytes to size in zbud chunks */
> +static inline int size_to_chunks(int size)
> +{
> +=09return (size + CHUNK_SIZE - 1) >> CHUNK_SHIFT;
> +}
> +
> +#define for_each_unbuddied_list(_iter, _begin) \
> +=09for ((_iter) =3D (_begin); (_iter) < NCHUNKS; (_iter)++)
> +
> +/* Initializes a zbud page from a newly allocated page */
> +static inline struct zbud_page *init_zbud_page(struct page *page)
> +{
> +=09struct zbud_page *zbpage =3D (struct zbud_page *)page;
> +=09zbpage->first_chunks =3D 0;
> +=09zbpage->last_chunks =3D 0;
> +=09INIT_LIST_HEAD(&zbpage->buddy);
> +=09INIT_LIST_HEAD(&zbpage->lru);
> +=09return zbpage;
> +}
> +
> +/* Resets a zbud page so that it can be properly freed  */
> +static inline struct page *reset_zbud_page(struct zbud_page *zbpage)
> +{
> +=09struct page *page =3D &zbpage->page;
> +=09set_page_private(page, 0);
> +=09page->mapping =3D NULL;
> +=09page->index =3D 0;
> +=09page_mapcount_reset(page);
> +=09init_page_count(page);
> +=09INIT_LIST_HEAD(&page->lru);
> +=09return page;
> +}
> +
> +/*
> + * Encodes the handle of a particular buddy within a zbud page
> + * Pool lock should be held as this function accesses first|last_chunks
> + */
> +static inline unsigned long encode_handle(struct zbud_page *zbpage,
> +=09=09=09=09=09enum buddy bud)
> +{
> +=09unsigned long handle;
> +
> +=09/*
> +=09 * For now, the encoded handle is actually just the pointer to the da=
ta
> +=09 * but this might not always be the case.  A little information hidin=
g.
> +=09 */
> +=09handle =3D (unsigned long)page_address(&zbpage->page);
> +=09if (bud =3D=3D FIRST)
> +=09=09return handle;
> +=09handle +=3D PAGE_SIZE - (zbpage->last_chunks  << CHUNK_SHIFT);
> +=09return handle;
> +}
> +
> +/* Returns the zbud page where a given handle is stored */
> +static inline struct zbud_page *handle_to_zbud_page(unsigned long handle=
)
> +{
> +=09return (struct zbud_page *)(virt_to_page(handle));
> +}
> +
> +/* Returns the number of free chunks in a zbud page */
> +static inline int num_free_chunks(struct zbud_page *zbpage)
> +{
> +=09/*
> +=09 * Rather than branch for different situations, just use the fact tha=
t
> +=09 * free buddies have a length of zero to simplify everything.
> +=09 */
> +=09return NCHUNKS - zbpage->first_chunks - zbpage->last_chunks;
> +}
> +
> +/*****************
> + * API Functions
> +*****************/
> +/**
> + * zbud_create_pool() - create a new zbud pool
> + * @gfp:=09gfp flags when allocating the zbud pool structure
> + * @ops:=09user-defined operations for the zbud pool
> + *
> + * Return: pointer to the new zbud pool or NULL if the metadata allocati=
on
> + * failed.
> + */
> +struct zbud_pool *zbud_create_pool(gfp_t gfp, struct zbud_ops *ops)
> +{
> +=09struct zbud_pool *pool;
> +=09int i;
> +
> +=09pool =3D kmalloc(sizeof(struct zbud_pool), gfp);
> +=09if (!pool)
> +=09=09return NULL;
> +=09spin_lock_init(&pool->lock);
> +=09for_each_unbuddied_list(i, 0)
> +=09=09INIT_LIST_HEAD(&pool->unbuddied[i]);
> +=09INIT_LIST_HEAD(&pool->buddied);
> +=09INIT_LIST_HEAD(&pool->lru);
> +=09atomic_set(&pool->pages_nr, 0);
> +=09pool->ops =3D ops;
> +=09return pool;
> +}
> +EXPORT_SYMBOL_GPL(zbud_create_pool);
> +
> +/**
> + * zbud_destroy_pool() - destroys an existing zbud pool
> + * @pool:=09the zbud pool to be destroyed
> + */
> +void zbud_destroy_pool(struct zbud_pool *pool)
> +{
> +=09kfree(pool);
> +}
> +EXPORT_SYMBOL_GPL(zbud_destroy_pool);
> +
> +/**
> + * zbud_alloc() - allocates a region of a given size
> + * @pool:=09zbud pool from which to allocate
> + * @size:=09size in bytes of the desired allocation
> + * @gfp:=09gfp flags used if the pool needs to grow
> + * @handle:=09handle of the new allocation
> + *
> + * This function will attempt to find a free region in the pool large
> + * enough to satisfy the allocation request.  First, it tries to use
> + * free space in the most recently used zbud page, at the beginning of
> + * the pool LRU list.  If that zbud page is full or doesn't have the
> + * required free space, a best fit search of the unbuddied lists is
> + * performed. If no suitable free region is found, then a new page
> + * is allocated and added to the pool to satisfy the request.
> + *
> + * gfp should not set __GFP_HIGHMEM as highmem pages cannot be used
> + * as zbud pool pages.
> + *
> + * Return: 0 if success and handle is set, otherwise -EINVAL is the size=
 or
> + * gfp arguments are invalid or -ENOMEM if the pool was unable to alloca=
te
> + * a new page.
> + */
> +int zbud_alloc(struct zbud_pool *pool, int size, gfp_t gfp,
> +=09=09=09unsigned long *handle)
> +{
> +=09int chunks, i, freechunks;
> +=09struct zbud_page *zbpage =3D NULL;
> +=09enum buddy bud;
> +=09struct page *page;
> +
> +=09if (size <=3D 0 || size > PAGE_SIZE || gfp & __GFP_HIGHMEM)
> +=09=09return -EINVAL;
> +=09chunks =3D size_to_chunks(size);
> +=09spin_lock(&pool->lock);
> +
> +=09/*
> +=09 * First, try to use the zbpage we last used (at the head of the
> +=09 * LRU) to increase LRU locality of the buddies. This is first fit.
> +=09 */
> +=09if (!list_empty(&pool->lru)) {
> +=09=09zbpage =3D list_first_entry(&pool->lru, struct zbud_page, lru);
> +=09=09if (num_free_chunks(zbpage) >=3D chunks) {
> +=09=09=09if (zbpage->first_chunks =3D=3D 0) {
> +=09=09=09=09list_del(&zbpage->buddy);
> +=09=09=09=09bud =3D FIRST;
> +=09=09=09=09goto found;
> +=09=09=09}
> +=09=09=09if (zbpage->last_chunks =3D=3D 0) {
> +=09=09=09=09list_del(&zbpage->buddy);
> +=09=09=09=09bud =3D LAST;
> +=09=09=09=09goto found;
> +=09=09=09}
> +=09=09}
> +=09}

The above appears to be a new addition to my original zbud design.
While it may appear to be a good idea for improving LRU-ness, I
suspect it may have unexpected side effects in that I think far
fewer "fat" zpages will be buddied, which will result in many more
unbuddied pages containing a single fat zpage, which means much worse
overall density on many workloads.

This may not be apparent in kernbench or specjbb or any workload
where the vast majority of zpages compress to less than PAGE_SIZE/2,
but for a zsize distribution that is symmetric or "skews fat",
it may become very apparent.

> +=09/* Second, try to find an unbuddied zbpage. This is best fit. */
> +=09zbpage =3D NULL;
> +=09for_each_unbuddied_list(i, chunks) {
> +=09=09if (!list_empty(&pool->unbuddied[i])) {
> +=09=09=09zbpage =3D list_first_entry(&pool->unbuddied[i],
> +=09=09=09=09=09struct zbud_page, buddy);
> +=09=09=09list_del(&zbpage->buddy);
> +=09=09=09if (zbpage->first_chunks =3D=3D 0)
> +=09=09=09=09bud =3D FIRST;
> +=09=09=09else
> +=09=09=09=09bud =3D LAST;
> +=09=09=09goto found;
> +=09=09}
> +=09}
> +
> +=09/* Lastly, couldn't find unbuddied zbpage, create new one */
> +=09spin_unlock(&pool->lock);
> +=09page =3D alloc_page(gfp);
> +=09if (!page)
> +=09=09return -ENOMEM;
> +=09spin_lock(&pool->lock);
> +=09atomic_inc(&pool->pages_nr);
> +=09zbpage =3D init_zbud_page(page);
> +=09bud =3D FIRST;
> +
> +found:
> +=09if (bud =3D=3D FIRST)
> +=09=09zbpage->first_chunks =3D chunks;
> +=09else
> +=09=09zbpage->last_chunks =3D chunks;
> +
> +=09if (zbpage->first_chunks =3D=3D 0 || zbpage->last_chunks =3D=3D 0) {
> +=09=09/* Add to unbuddied list */
> +=09=09freechunks =3D num_free_chunks(zbpage);
> +=09=09list_add(&zbpage->buddy, &pool->unbuddied[freechunks]);
> +=09} else {
> +=09=09/* Add to buddied list */
> +=09=09list_add(&zbpage->buddy, &pool->buddied);
> +=09}
> +
> +=09/* Add/move zbpage to beginning of LRU */
> +=09if (!list_empty(&zbpage->lru))
> +=09=09list_del(&zbpage->lru);
> +=09list_add(&zbpage->lru, &pool->lru);
> +
> +=09*handle =3D encode_handle(zbpage, bud);
> +=09spin_unlock(&pool->lock);
> +
> +=09return 0;
> +}
> +EXPORT_SYMBOL_GPL(zbud_alloc);
> +
> +/**
> + * zbud_free() - frees the allocation associated with the given handle
> + * @pool:=09pool in which the allocation resided
> + * @handle:=09handle associated with the allocation returned by zbud_all=
oc()
> + *
> + * In the case that the zbud page in which the allocation resides is und=
er
> + * reclaim, as indicated by the PG_reclaim flag being set, this function
> + * only sets the first|last_chunks to 0.  The page is actually freed
> + * once both buddies are evicted (see zbud_reclaim_page() below).
> + */
> +void zbud_free(struct zbud_pool *pool, unsigned long handle)
> +{
> +=09struct zbud_page *zbpage;
> +=09int freechunks;
> +
> +=09spin_lock(&pool->lock);
> +=09zbpage =3D handle_to_zbud_page(handle);
> +
> +=09/* If first buddy, handle will be page aligned */
> +=09if (handle & ~PAGE_MASK)
> +=09=09zbpage->last_chunks =3D 0;
> +=09else
> +=09=09zbpage->first_chunks =3D 0;
> +
> +=09if (PageReclaim(&zbpage->page)) {
> +=09=09/* zbpage is under reclaim, reclaim will free */
> +=09=09spin_unlock(&pool->lock);
> +=09=09return;
> +=09}
> +
> +=09/* Remove from existing buddy list */
> +=09list_del(&zbpage->buddy);
> +
> +=09if (zbpage->first_chunks =3D=3D 0 && zbpage->last_chunks =3D=3D 0) {
> +=09=09/* zbpage is empty, free */
> +=09=09list_del(&zbpage->lru);
> +=09=09__free_page(reset_zbud_page(zbpage));
> +=09=09atomic_dec(&pool->pages_nr);
> +=09} else {
> +=09=09/* Add to unbuddied list */
> +=09=09freechunks =3D num_free_chunks(zbpage);
> +=09=09list_add(&zbpage->buddy, &pool->unbuddied[freechunks]);
> +=09}
> +
> +=09spin_unlock(&pool->lock);
> +}
> +EXPORT_SYMBOL_GPL(zbud_free);
> +
> +#define list_tail_entry(ptr, type, member) \
> +=09list_entry((ptr)->prev, type, member)
> +
> +/**
> + * zbud_reclaim_page() - evicts allocations from a pool page and frees i=
t
> + * @pool:=09pool from which a page will attempt to be evicted
> + * @retires:=09number of pages on the LRU list for which eviction will
> + *=09=09be attempted before failing
> + *
> + * zbud reclaim is different from normal system reclaim in that the recl=
aim is
> + * done from the bottom, up.  This is because only the bottom layer, zbu=
d, has
> + * information on how the allocations are organized within each zbud pag=
e. This
> + * has the potential to create interesting locking situations between zb=
ud and
> + * the user, however.
> + *
> + * To avoid these, this is how zbud_reclaim_page() should be called:
> +
> + * The user detects a page should be reclaimed and calls zbud_reclaim_pa=
ge().
> + * zbud_reclaim_page() will remove a zbud page from the pool LRU list an=
d call
> + * the user-defined eviction handler with the pool and handle as argumen=
ts.
> + *
> + * If the handle can not be evicted, the eviction handler should return
> + * non-zero. zbud_reclaim_page() will add the zbud page back to the
> + * appropriate list and try the next zbud page on the LRU up to
> + * a user defined number of retries.
> + *
> + * If the handle is successfully evicted, the eviction handler should
> + * return 0 _and_ should have called zbud_free() on the handle. zbud_fre=
e()
> + * contains logic to delay freeing the page if the page is under reclaim=
,
> + * as indicated by the setting of the PG_reclaim flag on the underlying =
page.
> + *
> + * If all buddies in the zbud page are successfully evicted, then the
> + * zbud page can be freed.
> + *
> + * Returns: 0 if page is successfully freed, otherwise -EINVAL if there =
are
> + * no pages to evict or an eviction handler is not registered, -EAGAIN i=
f
> + * the retry limit was hit.
> + */
> +int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries)
> +{
> +=09int i, ret, freechunks;
> +=09struct zbud_page *zbpage;
> +=09unsigned long first_handle =3D 0, last_handle =3D 0;
> +
> +=09spin_lock(&pool->lock);
> +=09if (!pool->ops || !pool->ops->evict || list_empty(&pool->lru) ||
> +=09=09=09retries =3D=3D 0) {
> +=09=09spin_unlock(&pool->lock);
> +=09=09return -EINVAL;
> +=09}
> +=09for (i =3D 0; i < retries; i++) {
> +=09=09zbpage =3D list_tail_entry(&pool->lru, struct zbud_page, lru);
> +=09=09list_del(&zbpage->lru);
> +=09=09list_del(&zbpage->buddy);
> +=09=09/* Protect zbpage against free */
> +=09=09SetPageReclaim(&zbpage->page);
> +=09=09/*
> +=09=09 * We need encode the handles before unlocking, since we can
> +=09=09 * race with free that will set (first|last)_chunks to 0
> +=09=09 */
> +=09=09first_handle =3D 0;
> +=09=09last_handle =3D 0;
> +=09=09if (zbpage->first_chunks)
> +=09=09=09first_handle =3D encode_handle(zbpage, FIRST);
> +=09=09if (zbpage->last_chunks)
> +=09=09=09last_handle =3D encode_handle(zbpage, LAST);
> +=09=09spin_unlock(&pool->lock);
> +
> +=09=09/* Issue the eviction callback(s) */
> +=09=09if (first_handle) {
> +=09=09=09ret =3D pool->ops->evict(pool, first_handle);
> +=09=09=09if (ret)
> +=09=09=09=09goto next;
> +=09=09}
> +=09=09if (last_handle) {
> +=09=09=09ret =3D pool->ops->evict(pool, last_handle);
> +=09=09=09if (ret)
> +=09=09=09=09goto next;
> +=09=09}
> +next:
> +=09=09spin_lock(&pool->lock);
> +=09=09ClearPageReclaim(&zbpage->page);
> +=09=09if (zbpage->first_chunks =3D=3D 0 && zbpage->last_chunks =3D=3D 0)=
 {
> +=09=09=09/*
> +=09=09=09 * Both buddies are now free, free the zbpage and
> +=09=09=09 * return success.
> +=09=09=09 */
> +=09=09=09__free_page(reset_zbud_page(zbpage));
> +=09=09=09atomic_dec(&pool->pages_nr);
> +=09=09=09spin_unlock(&pool->lock);
> +=09=09=09return 0;
> +=09=09} else if (zbpage->first_chunks =3D=3D 0 ||
> +=09=09=09=09zbpage->last_chunks =3D=3D 0) {
> +=09=09=09/* add to unbuddied list */
> +=09=09=09freechunks =3D num_free_chunks(zbpage);
> +=09=09=09list_add(&zbpage->buddy, &pool->unbuddied[freechunks]);
> +=09=09} else {
> +=09=09=09/* add to buddied list */
> +=09=09=09list_add(&zbpage->buddy, &pool->buddied);
> +=09=09}
> +
> +=09=09/* add to beginning of LRU */
> +=09=09list_add(&zbpage->lru, &pool->lru);
> +=09}
> +=09spin_unlock(&pool->lock);
> +=09return -EAGAIN;
> +}
> +EXPORT_SYMBOL_GPL(zbud_reclaim_page);
> +
> +/**
> + * zbud_map() - maps the allocation associated with the given handle
> + * @pool:=09pool in which the allocation resides
> + * @handle:=09handle associated with the allocation to be mapped
> + *
> + * While trivial for zbud, the mapping functions for others allocators
> + * implementing this allocation API could have more complex information =
encoded
> + * in the handle and could create temporary mappings to make the data
> + * accessible to the user.
> + *
> + * Returns: a pointer to the mapped allocation
> + */
> +void *zbud_map(struct zbud_pool *pool, unsigned long handle)
> +{
> +=09return (void *)(handle);
> +}
> +EXPORT_SYMBOL_GPL(zbud_map);
> +
> +/**
> + * zbud_unmap() - maps the allocation associated with the given handle
> + * @pool:=09pool in which the allocation resides
> + * @handle:=09handle associated with the allocation to be unmapped
> + */
> +void zbud_unmap(struct zbud_pool *pool, unsigned long handle)
> +{
> +}
> +EXPORT_SYMBOL_GPL(zbud_unmap);
> +
> +/**
> + * zbud_get_pool_size() - gets the zbud pool size in pages
> + * @pool:=09pool whose size is being queried
> + *
> + * Returns: size in pages of the given pool
> + */
> +int zbud_get_pool_size(struct zbud_pool *pool)
> +{
> +=09return atomic_read(&pool->pages_nr);
> +}
> +EXPORT_SYMBOL_GPL(zbud_get_pool_size);
> +
> +static int __init init_zbud(void)
> +{
> +=09/* Make sure we aren't overflowing the underlying struct page */
> +=09BUILD_BUG_ON(sizeof(struct zbud_page) !=3D sizeof(struct page));
> +=09/* Make sure we can represent any chunk offset with a u16 */
> +=09BUILD_BUG_ON(sizeof(u16) * BITS_PER_BYTE < PAGE_SHIFT - CHUNK_SHIFT);
> +=09pr_info("loaded\n");
> +=09return 0;
> +}
> +
> +static void __exit exit_zbud(void)
> +{
> +=09pr_info("unloaded\n");
> +}
> +
> +module_init(init_zbud);
> +module_exit(exit_zbud);
> +
> +MODULE_LICENSE("GPL");
> +MODULE_AUTHOR("Seth Jennings <sjenning@linux.vnet.ibm.com>");
> +MODULE_DESCRIPTION("Buddy Allocator for Compressed Pages");
> --
> 1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
