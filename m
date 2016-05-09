Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1B4CD6B0005
	for <linux-mm@kvack.org>; Mon,  9 May 2016 08:08:06 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id s63so97620208wme.2
        for <linux-mm@kvack.org>; Mon, 09 May 2016 05:08:06 -0700 (PDT)
Received: from mail-wm0-x22d.google.com (mail-wm0-x22d.google.com. [2a00:1450:400c:c09::22d])
        by mx.google.com with ESMTPS id h3si33319286wjp.176.2016.05.09.05.08.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 May 2016 05:08:04 -0700 (PDT)
Received: by mail-wm0-x22d.google.com with SMTP id e201so134350173wme.0
        for <linux-mm@kvack.org>; Mon, 09 May 2016 05:08:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALZtONBkSZF1QuK2QNb=QCg7tfWWaPDC5VH0DvSwdbLQdTOtFQ@mail.gmail.com>
References: <20160425162937.a35104265d4adaa59e6fa3ca@gmail.com>
	<CALZtONBkSZF1QuK2QNb=QCg7tfWWaPDC5VH0DvSwdbLQdTOtFQ@mail.gmail.com>
Date: Mon, 9 May 2016 14:08:03 +0200
Message-ID: <CAMJBoFOdzUas6HC=aT4WxptMch+K_1tyrZ3aC1JumLudfA-b-g@mail.gmail.com>
Subject: Re: [PATCH v3] z3fold: the 3-fold allocator for compressed pages
From: Vitaly Wool <vitalywool@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Seth Jennings <sjenning@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>

Hi Dan,

On Thu, May 5, 2016 at 12:44 AM, Dan Streetman <ddstreet@ieee.org> wrote:

<snip>
> sorry for commenting so late, at v3 :-)

Thanks for jumping in! :)

> in general the patch looks good, i have a few comments below.  I also
> agree that while there is some code duplicated between zbud and
> z3fold, there's enough differences to warrant keeping them separate.
>
> One general suggestion (which I mention some below) is if you don't
> intend for the api to be used directly - which seems fine, as nobody
> uses zbud's api directly now - it would be simpler to just put the
> implementations into the zpool functions, instead of keeping the zpool
> functions as pass-thru to the actual implementation functions.
> There's no need for that, if everyone is expected to use zpool to
> access this.
>
>>
>> [1] https://openiotelc2016.sched.org/event/6DAC/swapping-and-embedded-compression-relieves-the-pressure-vitaly-wool-softprise-consulting-ou
>> [2] https://lkml.org/lkml/2016/4/21/799
>>
>> Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
>> ---
>>  Documentation/vm/z3fold.txt |  27 ++
>>  mm/Kconfig                  |  10 +
>>  mm/Makefile                 |   1 +
>>  mm/z3fold.c                 | 818 ++++++++++++++++++++++++++++++++++++++++++++
>>  4 files changed, 856 insertions(+)
>>  create mode 100644 Documentation/vm/z3fold.txt
>>  create mode 100644 mm/z3fold.c
>>
>> diff --git a/Documentation/vm/z3fold.txt b/Documentation/vm/z3fold.txt
>> new file mode 100644
>> index 0000000..3afff6e
>> --- /dev/null
>> +++ b/Documentation/vm/z3fold.txt
>> @@ -0,0 +1,27 @@
>> +z3fold
>> +------
>> +
>> +z3fold is a special purpose allocator for storing compressed pages.
>> +It is designed to store up to three compressed pages per physical page.
>> +It is a zbud derivative which allows for higher compression
>> +ratio keeping the simplicity and determinism of its predecessor.
>> +
>> +The main differences between z3fold and zbud are:
>> +* unlike zbud, z3fold allows for up to PAGE_SIZE allocations
>> +* z3fold can hold up to 3 compressed pages in its page
>> +* z3fold doesn't export any API itself and is thus intended to be used
>> +  via the zpool API.
>> +
>> +To keep the determinism and simplicity, z3fold, just like zbud, always
>> +stores an integral number of compressed pages per page, but it can store
>> +up to 3 pages unlike zbud which can store at most 2. Therefore the
>> +compression ratio goes to around 2.7x while zbud's one is around 1.7x.
>> +
>> +Unlike zbud (but like zsmalloc for that matter) z3fold_alloc() does not
>> +return a dereferenceable pointer. Instead, it returns an unsigned long
>> +handle which encodes actual location of the allocated object.
>> +
>> +Keeping effective compression ratio close to zsmalloc's, z3fold doesn't
>> +depend on MMU enabled and provides more predictable reclaim behavior
>> +which makes it a better fit for small and response-critical systems.
>> +
>> diff --git a/mm/Kconfig b/mm/Kconfig
>> index 989f8f3..1dde74c 100644
>> --- a/mm/Kconfig
>> +++ b/mm/Kconfig
>> @@ -565,6 +565,16 @@ config ZBUD
>>           deterministic reclaim properties that make it preferable to a higher
>>           density approach when reclaim will be used.
>>
>> +config Z3FOLD
>> +       tristate "Higher density storage for compressed pages"
>
> I think the "higher" and "lower" adjectives no longer apply, as
> there's not just 2 to compare (zbud "lower" than zsmalloc).  Instead
> I'd change zbud's title to something like "2:1 density storage for
> compressed pages" and z3fold's to something like "3:1 density storage
> for compressed pages".

Thanks, I'll put it as "up to 2x" and "up to 3x" or something alike.

>
>> +       depends on ZPOOL
>> +       default n
>> +       help
>> +         A special purpose allocator for storing compressed pages.
>> +         It is designed to store up to three compressed pages per physical
>> +         page. It is a ZBUD derivative so the simplicity and determinism are
>> +         still there.
>> +
>>  config ZSMALLOC
>>         tristate "Memory allocator for compressed pages"
>>         depends on MMU
>> diff --git a/mm/Makefile b/mm/Makefile
>> index deb467e..78c6f7d 100644
>> --- a/mm/Makefile
>> +++ b/mm/Makefile
>> @@ -89,6 +89,7 @@ obj-$(CONFIG_MEMORY_ISOLATION) += page_isolation.o
>>  obj-$(CONFIG_ZPOOL)    += zpool.o
>>  obj-$(CONFIG_ZBUD)     += zbud.o
>>  obj-$(CONFIG_ZSMALLOC) += zsmalloc.o
>> +obj-$(CONFIG_Z3FOLD)   += z3fold.o
>>  obj-$(CONFIG_GENERIC_EARLY_IOREMAP) += early_ioremap.o
>>  obj-$(CONFIG_CMA)      += cma.o
>>  obj-$(CONFIG_MEMORY_BALLOON) += balloon_compaction.o
>> diff --git a/mm/z3fold.c b/mm/z3fold.c
>> new file mode 100644
>> index 0000000..24dc960
>> --- /dev/null
>> +++ b/mm/z3fold.c
>> @@ -0,0 +1,818 @@
>> +/*
>> + * z3fold.c
>> + *
>> + * Author: Vitaly Wool <vitalywool@gmail.com>
>> + * Copyright (C) 2016, Sony Mobile Communications Inc.
>> + *
>> + * This implementation is heavily based on zbud written by Seth Jennings.
>> + *
>> + * z3fold is an special purpose allocator for storing compressed pages. It
>> + * can store up to three compressed pages per page which improves the
>> + * compression ratio of zbud while retaining its main concepts (e. g. always
>> + * storing an integral number of objects per page) and simplicity.
>> + * It still has simple and deterministic reclaim properties that make it
>> + * preferable to a higher density approach (with no requirement on integral
>> + * number of object per page) when reclaim is used.
>> + *
>> + * As in zbud, pages are divided into "chunks".  The size of the chunks is
>> + * fixed at compile time and is determined by NCHUNKS_ORDER below.
>> + *
>> + * The z3fold API doesn't differ from zbud API and zpool is also supported.
>
> z3fold doesn't export any API at all, it's only available via zpool;
> this comment is confusing.
>
>> + */
>> +
>> +#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
>> +
>> +#include <linux/atomic.h>
>> +#include <linux/list.h>
>> +#include <linux/mm.h>
>> +#include <linux/module.h>
>> +#include <linux/preempt.h>
>> +#include <linux/slab.h>
>> +#include <linux/spinlock.h>
>> +#include <linux/zpool.h>
>> +
>> +/*****************
>> + * Structures
>> +*****************/
>> +/*
>> + * NCHUNKS_ORDER determines the internal allocation granularity, effectively
>> + * adjusting internal fragmentation.  It also determines the number of
>> + * freelists maintained in each pool. NCHUNKS_ORDER of 6 means that the
>> + * allocation granularity will be in chunks of size PAGE_SIZE/64. As one chunk
>> + * in allocated page is occupied by z3fold header, NCHUNKS will be calculated
>> + * to 63 which shows the max number of free chunks in z3fold page, also there
>> + * will be 63 freelists per pool.
>> + */
>> +#define NCHUNKS_ORDER  6
>> +
>> +#define CHUNK_SHIFT    (PAGE_SHIFT - NCHUNKS_ORDER)
>> +#define CHUNK_SIZE     (1 << CHUNK_SHIFT)
>> +#define ZHDR_SIZE_ALIGNED CHUNK_SIZE
>> +#define NCHUNKS                ((PAGE_SIZE - ZHDR_SIZE_ALIGNED) >> CHUNK_SHIFT)
>> +
>> +#define BUDDY_MASK     ((1 << NCHUNKS_ORDER) - 1)
>> +
>> +struct z3fold_pool;
>> +struct z3fold_ops {
>> +       int (*evict)(struct z3fold_pool *pool, unsigned long handle);
>> +};
>> +
>> +/**
>> + * struct z3fold_pool - stores metadata for each z3fold pool
>> + * @lock:      protects all pool fields and first|last_chunk fields of any
>> + *             z3fold page in the pool
>> + * @unbuddied: array of lists tracking z3fold pages that contain 2- buddies;
>> + *             the lists each z3fold page is added to depends on the size of
>> + *             its free region.
>> + * @buddied:   list tracking the z3fold pages that contain 3 buddies;
>> + *             these z3fold pages are full
>> + * @lru:       list tracking the z3fold pages in LRU order by most recently
>> + *             added buddy.
>> + * @pages_nr:  number of z3fold pages in the pool.
>> + * @ops:       pointer to a structure of user defined operations specified at
>> + *             pool creation time.
>> + *
>> + * This structure is allocated at pool creation time and maintains metadata
>> + * pertaining to a particular z3fold pool.
>> + */
>> +struct z3fold_pool {
>> +       spinlock_t lock;
>> +       struct list_head unbuddied[NCHUNKS];
>> +       struct list_head buddied;
>> +       struct list_head lru;
>> +       u64 pages_nr;
>> +       const struct z3fold_ops *ops;
>> +#ifdef CONFIG_ZPOOL
>> +       struct zpool *zpool;
>> +       const struct zpool_ops *zpool_ops;
>> +#endif
>> +};
>> +
>> +enum buddy {
>> +       HEADLESS = 0,
>> +       FIRST,
>> +       MIDDLE,
>> +       LAST,
>> +       BUDDIES_MAX
>> +};
>> +
>> +/*
>> + * struct z3fold_header - z3fold page metadata occupying the first chunk of each
>> + *                     z3fold page, except for HEADLESS pages
>> + * @buddy:     links the z3fold page into the relevant list in the pool
>> + * @first_chunks:      the size of the first buddy in chunks, 0 if free
>> + * @middle_chunks:     the size of the middle buddy in chunks, 0 if free
>> + * @last_chunks:       the size of the last buddy in chunks, 0 if free
>> + * @first_num:         the starting number (for the first handle)
>> + */
>> +struct z3fold_header {
>> +       struct list_head buddy;
>> +       unsigned short first_chunks;
>> +       unsigned short middle_chunks;
>> +       unsigned short last_chunks;
>> +       unsigned short start_middle;
>> +       unsigned short first_num:NCHUNKS_ORDER;
>> +};
>> +
>> +/*
>> + * Internal z3fold page flags
>> + */
>> +enum z3fold_page_flags {
>> +       UNDER_RECLAIM = 0,
>> +       PAGE_HEADLESS,
>> +       MIDDLE_CHUNK_MAPPED,
>> +};
>> +
>> +/*****************
>> + * Helpers
>> +*****************/
>> +
>> +/* Converts an allocation size in bytes to size in z3fold chunks */
>> +static int size_to_chunks(size_t size)
>> +{
>> +       return (size + CHUNK_SIZE - 1) >> CHUNK_SHIFT;
>> +}
>> +
>> +#define for_each_unbuddied_list(_iter, _begin) \
>> +       for ((_iter) = (_begin); (_iter) < NCHUNKS; (_iter)++)
>> +
>> +/* Initializes the z3fold header of a newly allocated z3fold page */
>> +static struct z3fold_header *init_z3fold_page(struct page *page)
>> +{
>> +       struct z3fold_header *zhdr = page_address(page);
>> +
>> +       INIT_LIST_HEAD(&page->lru);
>> +       clear_bit(UNDER_RECLAIM, &page->private);
>> +       clear_bit(PAGE_HEADLESS, &page->private);
>> +       clear_bit(MIDDLE_CHUNK_MAPPED, &page->private);
>> +
>> +       zhdr->first_chunks = 0;
>> +       zhdr->middle_chunks = 0;
>> +       zhdr->last_chunks = 0;
>> +       zhdr->first_num = 0;
>> +       zhdr->start_middle = 0;
>> +       INIT_LIST_HEAD(&zhdr->buddy);
>> +       return zhdr;
>> +}
>> +
>> +/* Resets the struct page fields and frees the page */
>> +static void free_z3fold_page(struct z3fold_header *zhdr)
>> +{
>> +       __free_page(virt_to_page(zhdr));
>> +}
>> +
>> +/*
>> + * Encodes the handle of a particular buddy within a z3fold page
>> + * Pool lock should be held as this function accesses first_num
>> + */
>> +static unsigned long encode_handle(struct z3fold_header *zhdr, enum buddy bud)
>> +{
>> +       unsigned long handle;
>> +
>> +       handle = (unsigned long)zhdr;
>> +       if (bud != HEADLESS)
>> +               handle += (bud + zhdr->first_num) & BUDDY_MASK;
>
> ugh, first_num is awfully confusing.  It would be better if there was
> a more obivous map between the handle number and the bud position.
> I'll think about it a bit.

Why? This mechanism works and it is kind of simple.
Would it be better to call 'first_num' something like 'numbering_shift'?

>> +       return handle;
>> +}
>> +
>> +/* Returns the z3fold page where a given handle is stored */
>> +static struct z3fold_header *handle_to_z3fold_header(unsigned long handle)
>> +{
>> +       return (struct z3fold_header *)(handle & PAGE_MASK);
>> +}
>> +
>> +/*
>> + * Returns the number of free chunks in a z3fold page.
>> + * NB: can't be used with HEADLESS pages.
>> + */
>> +static int num_free_chunks(struct z3fold_header *zhdr)
>> +{
>> +       int nfree;
>> +       /*
>> +        * If there is a middle object, pick up the bigger free space
>> +        * either before or after it. Otherwise just subtract the number
>> +        * of chunks occupied by the first and the last objects.
>> +        */
>> +       if (zhdr->middle_chunks != 0) {
>> +               int nfree_before = zhdr->first_chunks ?
>> +                       0 : zhdr->start_middle - 1;
>> +               int nfree_after = zhdr->last_chunks ?
>> +                       0 : NCHUNKS - zhdr->start_middle - zhdr->middle_chunks;
>> +               nfree = max(nfree_before, nfree_after);
>> +       } else
>> +               nfree = NCHUNKS - zhdr->first_chunks - zhdr->last_chunks;
>> +       return nfree;
>> +}
>> +
>> +/*****************
>> + * API Functions
>> +*****************/
>> +/**
>> + * z3fold_create_pool() - create a new z3fold pool
>> + * @gfp:       gfp flags when allocating the z3fold pool structure
>> + * @ops:       user-defined operations for the z3fold pool
>> + *
>> + * Return: pointer to the new z3fold pool or NULL if the metadata allocation
>> + * failed.
>> + */
>> +struct z3fold_pool *z3fold_create_pool(gfp_t gfp, const struct z3fold_ops *ops)
>
> as none of this api is exported, all these functions should be static.
> they'll be accessed via zpool.
>
> or, create a header file and export them (although it seems unlikely
> zbud or z3fold would ever be used outside of zpool)

Yep, I belive having them static is the way to go, thanks.

>> +{
>> +       struct z3fold_pool *pool;
>> +       int i;
>> +
>> +       pool = kzalloc(sizeof(struct z3fold_pool), gfp);
>> +       if (!pool)
>> +               return NULL;
>> +       spin_lock_init(&pool->lock);
>> +       for_each_unbuddied_list(i, 0)
>> +               INIT_LIST_HEAD(&pool->unbuddied[i]);
>> +       INIT_LIST_HEAD(&pool->buddied);
>> +       INIT_LIST_HEAD(&pool->lru);
>> +       pool->pages_nr = 0;
>> +       pool->ops = ops;
>> +       return pool;
>> +}
>> +
>> +/**
>> + * z3fold_destroy_pool() - destroys an existing z3fold pool
>> + * @pool:      the z3fold pool to be destroyed
>> + *
>> + * The pool should be emptied before this function is called.
>> + */
>> +void z3fold_destroy_pool(struct z3fold_pool *pool)
>> +{
>> +       kfree(pool);
>> +}
>> +
>> +/* Has to be called with lock held */
>> +static int z3fold_compact_page(struct z3fold_header *zhdr)
>> +{
>> +       struct page *page = virt_to_page(zhdr);
>> +       void *beg = zhdr;
>> +
>> +       if (!test_bit(MIDDLE_CHUNK_MAPPED, &page->private) &&
>> +           zhdr->middle_chunks != 0) {
>> +               if (zhdr->first_chunks == 0 && zhdr->last_chunks == 0) {
>> +                       memmove(beg + ZHDR_SIZE_ALIGNED,
>> +                               beg + (zhdr->start_middle << CHUNK_SHIFT),
>> +                               zhdr->middle_chunks << CHUNK_SHIFT);
>> +                       zhdr->first_chunks = zhdr->middle_chunks;
>> +                       zhdr->middle_chunks = 0;
>> +                       zhdr->start_middle = 0;
>> +                       zhdr->first_num++;
>> +                       return 1;
>> +               } else if (zhdr->first_chunks != 0 &&
>> +                          zhdr->start_middle != zhdr->first_chunks + 1) {
>> +                       memmove(beg + ((zhdr->first_chunks+1) << CHUNK_SHIFT),
>> +                               beg + (zhdr->start_middle << CHUNK_SHIFT),
>> +                               zhdr->middle_chunks << CHUNK_SHIFT);
>> +                       zhdr->start_middle = zhdr->first_chunks + 1;
>> +                       return 1;
>> +               }
>
> This could be better; the first case of only a middle page is ok to
> move it to first page, and the second case of compacting the first and
> middle pages together is ok, but you're leaving out the case of a
> middle and last page - those should be compacted together, too.

I've done some performance and ratio measurements and it looks surely
like I'm better off only handling middle page.
I think I'll leave only that case at this point, first/middle and
middle/last compaction cases can be added later if there is a need for
that.

>> +       }
>> +       return 0;
>> +}
>> +
>> +/**
>> + * z3fold_alloc() - allocates a region of a given size
>> + * @pool:      z3fold pool from which to allocate
>> + * @size:      size in bytes of the desired allocation
>> + * @gfp:       gfp flags used if the pool needs to grow
>> + * @handle:    handle of the new allocation
>> + *
>> + * This function will attempt to find a free region in the pool large enough to
>> + * satisfy the allocation request.  A search of the unbuddied lists is
>> + * performed first. If no suitable free region is found, then a new page is
>> + * allocated and added to the pool to satisfy the request.
>> + *
>> + * gfp should not set __GFP_HIGHMEM as highmem pages cannot be used
>> + * as z3fold pool pages.
>> + *
>> + * Return: 0 if success and handle is set, otherwise -EINVAL if the size or
>> + * gfp arguments are invalid or -ENOMEM if the pool was unable to allocate
>> + * a new page.
>> + */
>> +int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
>> +                       unsigned long *handle)
>> +{
>> +       int chunks = 0, i, freechunks;
>> +       struct z3fold_header *zhdr = NULL;
>> +       enum buddy bud;
>> +       struct page *page;
>> +
>> +       if (!size || (gfp & __GFP_HIGHMEM))
>> +               return -EINVAL;
>> +
>> +       if (size > PAGE_SIZE)
>> +               return -ENOSPC;
>> +
>> +       if (size > PAGE_SIZE - ZHDR_SIZE_ALIGNED - CHUNK_SIZE)
>> +               bud = HEADLESS;
>> +       else {
>> +               chunks = size_to_chunks(size);
>> +               spin_lock(&pool->lock);
>> +
>> +               /* First, try to find an unbuddied z3fold page. */
>> +               zhdr = NULL;
>> +               for_each_unbuddied_list(i, chunks) {
>> +                       if (!list_empty(&pool->unbuddied[i])) {
>> +                               zhdr = list_first_entry(&pool->unbuddied[i],
>> +                                               struct z3fold_header, buddy);
>> +                               page = virt_to_page(zhdr);
>> +                               if (zhdr->first_chunks == 0) {
>> +                                       if (zhdr->middle_chunks == 0)
>> +                                               bud = FIRST;
>> +                                       else if (chunks >= zhdr->start_middle)
>> +                                               bud = LAST;
>> +                                       else if (test_bit(MIDDLE_CHUNK_MAPPED,
>> +                                                    &page->private))
>> +                                               continue;
>
> why skip this if the middle bud is mapped?  we can still allocate from
> the first bud right?

Because then we can't avoid the gap between the first and the middle
objects and the implementation couldn't handle it at the v3 point of
time :)
Now it works so the v4 will have something more comprehensible.

>> +                                       else
>> +                                               bud = FIRST;
>> +                               } else if (zhdr->last_chunks == 0)
>> +                                       bud = LAST;
>> +                               else if (zhdr->middle_chunks == 0)
>> +                                       bud = MIDDLE;
>> +                               else {
>> +                                       pr_err("No free chunks in unbuddied\n");
>> +                                       WARN_ON(1);
>> +                                       continue;
>> +                               }
>> +                               list_del(&zhdr->buddy);
>> +                               goto found;
>> +                       }
>> +               }
>> +               bud = FIRST;
>> +               spin_unlock(&pool->lock);
>> +       }
>> +
>> +       /* Couldn't find unbuddied z3fold page, create new one */
>> +       page = alloc_page(gfp);
>> +       if (!page)
>> +               return -ENOMEM;
>> +       spin_lock(&pool->lock);
>> +       pool->pages_nr++;
>> +       zhdr = init_z3fold_page(page);
>> +
>> +       if (bud == HEADLESS) {
>> +               set_bit(PAGE_HEADLESS, &page->private);
>> +               goto headless;
>> +       }
>> +
>> +found:
>> +       if (zhdr->middle_chunks != 0)
>> +               z3fold_compact_page(zhdr);
>
> compacting is not needed here; it was already compacted in z3fold_free
> before being put on the unbuddied list.

Or it wasn't if MIDDLE_CHUNK_MAPPED bit was set.

>> +
>> +       if (bud == FIRST)
>> +               zhdr->first_chunks = chunks;
>> +       else if (bud == LAST)
>> +               zhdr->last_chunks = chunks;
>> +       else {
>> +               zhdr->middle_chunks = chunks;
>> +               zhdr->start_middle = zhdr->first_chunks + 1;
>> +       }
>> +
>> +       if (zhdr->first_chunks == 0 || zhdr->last_chunks == 0 ||
>> +                       zhdr->middle_chunks == 0) {
>> +               /* Add to unbuddied list */
>> +               freechunks = num_free_chunks(zhdr);
>> +               list_add(&zhdr->buddy, &pool->unbuddied[freechunks]);
>> +       } else {
>> +               /* Add to buddied list */
>> +               list_add(&zhdr->buddy, &pool->buddied);
>> +       }
>> +
>> +headless:
>> +       /* Add/move z3fold page to beginning of LRU */
>> +       if (!list_empty(&page->lru))
>> +               list_del(&page->lru);
>> +
>> +       list_add(&page->lru, &pool->lru);
>> +
>> +       *handle = encode_handle(zhdr, bud);
>> +       spin_unlock(&pool->lock);
>> +
>> +       return 0;
>> +}
>> +
>> +/**
>> + * z3fold_free() - frees the allocation associated with the given handle
>> + * @pool:      pool in which the allocation resided
>> + * @handle:    handle associated with the allocation returned by z3fold_alloc()
>> + *
>> + * In the case that the z3fold page in which the allocation resides is under
>> + * reclaim, as indicated by the PG_reclaim flag being set, this function
>> + * only sets the first|last_chunks to 0.  The page is actually freed
>> + * once both buddies are evicted (see z3fold_reclaim_page() below).
>> + */
>> +void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
>> +{
>> +       struct z3fold_header *zhdr;
>> +       int freechunks;
>> +       struct page *page;
>> +       enum buddy bud;
>> +
>> +       spin_lock(&pool->lock);
>> +       zhdr = handle_to_z3fold_header(handle);
>> +       page = virt_to_page(zhdr);
>> +
>> +       if (test_bit(PAGE_HEADLESS, &page->private)) {
>> +               /* HEADLESS page stored */
>> +               bud = HEADLESS;
>> +       } else {
>> +               bud = (handle - zhdr->first_num) & BUDDY_MASK;
>
> even if the "first_num" approach is kept, converting between
> handle<->bud needs to be abstracted into functions or defines.

Yep, I'll come up with some helpers.

>> +
>> +               switch (bud) {
>> +               case FIRST:
>> +                       zhdr->first_chunks = 0;
>> +                       break;
>> +               case MIDDLE:
>> +                       zhdr->middle_chunks = 0;
>> +                       zhdr->start_middle = 0;
>> +                       break;
>> +               case LAST:
>> +                       zhdr->last_chunks = 0;
>> +                       break;
>> +               default:
>> +                       pr_err("%s: unknown bud %d\n", __func__, bud);
>> +                       WARN_ON(1);
>> +                       spin_unlock(&pool->lock);
>> +                       return;
>> +               }
>> +       }
>> +
>> +       if (test_bit(UNDER_RECLAIM, &page->private)) {
>> +               /* z3fold page is under reclaim, reclaim will free */
>> +               spin_unlock(&pool->lock);
>> +               return;
>> +       }
>> +
>> +       if (bud != HEADLESS) {
>> +               /* Remove from existing buddy list */
>> +               list_del(&zhdr->buddy);
>> +       }
>> +
>> +       if (bud == HEADLESS ||
>> +           (zhdr->first_chunks == 0 && zhdr->middle_chunks == 0 &&
>> +                       zhdr->last_chunks == 0)) {
>> +               /* z3fold page is empty, free */
>> +               list_del(&page->lru);
>> +               clear_bit(PAGE_HEADLESS, &page->private);
>> +               free_z3fold_page(zhdr);
>> +               pool->pages_nr--;
>> +       } else {
>> +               z3fold_compact_page(zhdr);
>> +               /* Add to the unbuddied list */
>> +               freechunks = num_free_chunks(zhdr);
>> +               list_add(&zhdr->buddy, &pool->unbuddied[freechunks]);
>> +       }
>> +
>> +       spin_unlock(&pool->lock);
>> +}
>> +
>> +#define list_tail_entry(ptr, type, member) \
>> +       list_entry((ptr)->prev, type, member)
>
> what's wrong with list_last_entry()?

Nothing; I believe this is just a piece of legacy code. I'll fix that.

>> +
>> +/**
>> + * z3fold_reclaim_page() - evicts allocations from a pool page and frees it
>> + * @pool:      pool from which a page will attempt to be evicted
>> + * @retires:   number of pages on the LRU list for which eviction will
>> + *             be attempted before failing
>> + *
>> + * z3fold reclaim is different from normal system reclaim in that it is done
>> + * from the bottom, up. This is because only the bottom layer, z3fold, has
>> + * information on how the allocations are organized within each z3fold page.
>> + * This has the potential to create interesting locking situations between
>> + * z3fold and the user, however.
>> + *
>> + * To avoid these, this is how z3fold_reclaim_page() should be called:
>> +
>> + * The user detects a page should be reclaimed and calls z3fold_reclaim_page().
>> + * z3fold_reclaim_page() will remove a z3fold page from the pool LRU list and
>> + * call the user-defined eviction handler with the pool and handle as
>> + * arguments.
>> + *
>> + * If the handle can not be evicted, the eviction handler should return
>> + * non-zero. z3fold_reclaim_page() will add the z3fold page back to the
>> + * appropriate list and try the next z3fold page on the LRU up to
>> + * a user defined number of retries.
>> + *
>> + * If the handle is successfully evicted, the eviction handler should
>> + * return 0 _and_ should have called z3fold_free() on the handle. z3fold_free()
>> + * contains logic to delay freeing the page if the page is under reclaim,
>> + * as indicated by the setting of the PG_reclaim flag on the underlying page.
>> + *
>> + * If all buddies in the z3fold page are successfully evicted, then the
>> + * z3fold page can be freed.
>> + *
>> + * Returns: 0 if page is successfully freed, otherwise -EINVAL if there are
>> + * no pages to evict or an eviction handler is not registered, -EAGAIN if
>> + * the retry limit was hit.
>> + */
>> +int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
>> +{
>> +       int i, ret = 0, freechunks;
>> +       struct z3fold_header *zhdr;
>> +       struct page *page;
>> +       unsigned long first_handle = 0, middle_handle = 0, last_handle = 0;
>> +
>> +       spin_lock(&pool->lock);
>> +       if (!pool->ops || !pool->ops->evict || list_empty(&pool->lru) ||
>> +                       retries == 0) {
>> +               spin_unlock(&pool->lock);
>> +               return -EINVAL;
>> +       }
>> +       for (i = 0; i < retries; i++) {
>> +               page = list_tail_entry(&pool->lru, struct page, lru);
>> +               list_del(&page->lru);
>> +
>> +               /* Protect z3fold page against free */
>> +               set_bit(UNDER_RECLAIM, &page->private);
>> +               zhdr = page_address(page);
>> +               if (!test_bit(PAGE_HEADLESS, &page->private)) {
>> +                       list_del(&zhdr->buddy);
>> +                       /*
>> +                        * We need encode the handles before unlocking, since
>> +                        * we can race with free that will set
>> +                        * (first|last)_chunks to 0
>> +                        */
>> +                       first_handle = 0;
>> +                       last_handle = 0;
>> +                       middle_handle = 0;
>> +                       if (zhdr->first_chunks)
>> +                               first_handle = encode_handle(zhdr, FIRST);
>> +                       if (zhdr->middle_chunks)
>> +                               middle_handle = encode_handle(zhdr, MIDDLE);
>> +                       if (zhdr->last_chunks)
>> +                               last_handle = encode_handle(zhdr, LAST);
>> +               } else {
>> +                       first_handle = encode_handle(zhdr, HEADLESS);
>> +                       last_handle = middle_handle = 0;
>> +               }
>> +
>> +               spin_unlock(&pool->lock);
>> +
>> +               /* Issue the eviction callback(s) */
>> +               if (middle_handle) {
>> +                       ret = pool->ops->evict(pool, middle_handle);
>> +                       if (ret)
>> +                               goto next;
>> +               }
>> +               if (first_handle) {
>> +                       ret = pool->ops->evict(pool, first_handle);
>> +                       if (ret)
>> +                               goto next;
>> +               }
>> +               if (last_handle) {
>> +                       ret = pool->ops->evict(pool, last_handle);
>> +                       if (ret)
>> +                               goto next;
>> +               }
>> +next:
>> +               spin_lock(&pool->lock);
>> +               clear_bit(UNDER_RECLAIM, &page->private);
>> +               if (test_bit(PAGE_HEADLESS, &page->private)) {
>> +                       if (ret == 0) {
>> +                               clear_bit(PAGE_HEADLESS, &page->private);
>> +                               free_z3fold_page(zhdr);
>> +                               pool->pages_nr--;
>> +                               spin_unlock(&pool->lock);
>> +                               return 0;
>> +                       }
>> +               } else if (zhdr->middle_chunks != 0) {
>> +                       /* Full, add to buddied list */
>> +                       freechunks = num_free_chunks(zhdr);
>> +                       list_add(&zhdr->buddy, &pool->buddied);
>
> how do you know it's full just because the middle bud is present?  it
> didn't necessarily start this function full.

Right, I've reworked this function for v4.

>> +               } else if (zhdr->first_chunks == 0 &&
>> +                               zhdr->last_chunks == 0 &&
>> +                               zhdr->middle_chunks == 0) {
>> +                       /*
>> +                        * All buddies are now free, free the z3fold page and
>> +                        * return success.
>> +                        */
>> +                       free_z3fold_page(zhdr);
>> +                       pool->pages_nr--;
>> +                       spin_unlock(&pool->lock);
>> +                       return 0;
>> +               } else {
>> +                       /* add to unbuddied list */
>
> some of the buds might have been freed, but since it's in reclaim the
> page wasn't compacted; it should be compacted here.

Thanks, I'll add that.

Best regards,
   Vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
