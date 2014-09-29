Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f172.google.com (mail-we0-f172.google.com [74.125.82.172])
	by kanga.kvack.org (Postfix) with ESMTP id B9F676B0035
	for <linux-mm@kvack.org>; Mon, 29 Sep 2014 11:42:07 -0400 (EDT)
Received: by mail-we0-f172.google.com with SMTP id q58so4391452wes.3
        for <linux-mm@kvack.org>; Mon, 29 Sep 2014 08:42:06 -0700 (PDT)
Received: from mail-we0-x229.google.com (mail-we0-x229.google.com [2a00:1450:400c:c03::229])
        by mx.google.com with ESMTPS id xb6si17220932wjc.57.2014.09.29.08.42.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 29 Sep 2014 08:42:05 -0700 (PDT)
Received: by mail-we0-f169.google.com with SMTP id w61so535144wes.14
        for <linux-mm@kvack.org>; Mon, 29 Sep 2014 08:42:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1411714395-18115-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1411714395-18115-1-git-send-email-iamjoonsoo.kim@lge.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Mon, 29 Sep 2014 11:41:45 -0400
Message-ID: <CALZtONArbej7s-FKqur2HyGQ0idp6wnsAW29OUTNzqkX3dNmPg@mail.gmail.com>
Subject: Re: [RFC PATCH 1/2] mm/afmalloc: introduce anti-fragmentation memory allocator
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Jerome Marchand <jmarchan@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Luigi Semenzato <semenzato@google.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>

On Fri, Sep 26, 2014 at 2:53 AM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> WARNING: This is just RFC patchset. patch 2/2 is only for testing.
> If you know useful place to use this allocator, please let me know.
>
> This is brand-new allocator, called anti-fragmentation memory allocator
> (aka afmalloc), in order to deal with arbitrary sized object allocation
> efficiently. zram and zswap uses arbitrary sized object to store
> compressed data so they can use this allocator. If there are any other
> use cases, they can use it, too.
>
> This work is motivated by observation of fragmentation on zsmalloc which
> intended for storing arbitrary sized object with low fragmentation.
> Although it works well on allocation-intensive workload, memory could be
> highly fragmented after many free occurs. In some cases, unused memory due
> to fragmentation occupy 20% ~ 50% amount of real used memory. The other
> problem is that other subsystem cannot use these unused memory. These
> fragmented memory are zsmalloc specific, so most of other subsystem cannot
> use it until zspage is freed to page allocator.
>
> I guess that there are similar fragmentation problem in zbud, but, I
> didn't deeply investigate it.
>
> This new allocator uses SLAB allocator to solve above problems. When
> request comes, it returns handle that is pointer of metatdata to point
> many small chunks. These small chunks are in power of 2 size and
> build up whole requested memory. We can easily acquire these chunks
> using SLAB allocator. Following is conceptual represetation of metadata
> used in this allocator to help understanding of this allocator.
>
> Handle A for 400 bytes
> {
>         Pointer for 256 bytes chunk
>         Pointer for 128 bytes chunk
>         Pointer for 16 bytes chunk
>
>         (256 + 128 + 16 = 400)
> }
>
> As you can see, 400 bytes memory are not contiguous in afmalloc so that
> allocator specific store/load functions are needed. These require some
> computation overhead and I guess that this is the only drawback this
> allocator has.

This also requires additional memory copying, for each map/unmap, no?

>
> For optimization, it uses another approach for power of 2 sized request.
> Instead of returning handle for metadata, it adds tag on pointer from
> SLAB allocator and directly returns this value as handle. With this tag,
> afmalloc can recognize whether handle is for metadata or not and do proper
> processing on it. This optimization can save some memory.
>
> Although afmalloc use some memory for metadata, overall utilization of
> memory is really good due to zero internal fragmentation by using power
> of 2 sized object. Although zsmalloc has many size class, there is
> considerable internal fragmentation in zsmalloc.
>
> In workload that needs many free, memory could be fragmented like
> zsmalloc, but, there is big difference. These unused portion of memory
> are SLAB specific memory so that other subsystem can use it. Therefore,
> fragmented memory could not be a big problem in this allocator.
>
> Extra benefit of this allocator design is NUMA awareness. This allocator
> allocates real memory from SLAB allocator. SLAB considers client's NUMA
> affinity, so these allocated memory is NUMA-friendly. Currently, zsmalloc
> and zbud which are backend of zram and zswap, respectively, are not NUMA
> awareness so that remote node's memory could be returned to requestor.
> I think that it could be solved easily if NUMA awareness turns out to be
> real problem. But, it may enlarge fragmentation depending on number of
> nodes. Anyway, there is no NUMA awareness issue in this allocator.
>
> Although I'd like to replace zsmalloc with this allocator, it cannot be
> possible, because zsmalloc supports HIGHMEM. In 32-bits world, SLAB memory
> would be very limited so supporting HIGHMEM would be really good advantage
> of zsmalloc. Because there is no HIGHMEM in 32-bits low memory device or
> 64-bits world, this allocator may be good option for this system. I
> didn't deeply consider whether this allocator can replace zbud or not.

While it looks like there may be some situations that benefit from
this, this won't work for all cases (as you mention), so maybe zpool
can allow zram to choose between zsmalloc and afmalloc.

>
> Below is the result of my simple test.
> (zsmalloc used in experiments is patched with my previous patch:
> zsmalloc: merge size_class to reduce fragmentation)
>
> TEST ENV: EXT4 on zram, mount with discard option
> WORKLOAD: untar kernel source, remove dir in descending order in size.
> (drivers arch fs sound include)
>
> Each line represents orig_data_size, compr_data_size, mem_used_total,
> fragmentation overhead (mem_used - compr_data_size) and overhead ratio
> (overhead to compr_data_size), respectively, after untar and remove
> operation is executed. In afmalloc case, overhead is calculated by
> before/after 'SUnreclaim' on /proc/meminfo.
> And there are two more columns
> in afmalloc, one is real_overhead which represents metadata usage and
> overhead of internal fragmentation, and the other is a ratio,
> real_overhead to compr_data_size. Unlike zsmalloc, only metadata and
> internal fragmented memory cannot be used by other subsystem. So,
> comparing real_overhead in afmalloc with overhead on zsmalloc seems to
> be proper comparison.
>
> * untar-merge.out
>
> orig_size compr_size used_size overhead overhead_ratio
> 526.23MB 199.18MB 209.81MB  10.64MB 5.34%
> 288.68MB  97.45MB 104.08MB   6.63MB 6.80%
> 177.68MB  61.14MB  66.93MB   5.79MB 9.47%
> 146.83MB  47.34MB  52.79MB   5.45MB 11.51%
> 124.52MB  38.87MB  44.30MB   5.43MB 13.96%
> 104.29MB  31.70MB  36.83MB   5.13MB 16.19%
>
> * untar-afmalloc.out
>
> orig_size compr_size used_size overhead overhead_ratio real real-ratio
> 526.27MB 199.18MB 206.37MB   8.00MB 4.02%   7.19MB 3.61%
> 288.71MB  97.45MB 101.25MB   5.86MB 6.01%   3.80MB 3.90%
> 177.71MB  61.14MB  63.44MB   4.39MB 7.19%   2.30MB 3.76%
> 146.86MB  47.34MB  49.20MB   3.97MB 8.39%   1.86MB 3.93%
> 124.55MB  38.88MB  40.41MB   3.71MB 9.54%   1.53MB 3.95%
> 104.32MB  31.70MB  32.96MB   3.43MB 10.81%   1.26MB 3.96%
>
> As you can see above result, real_overhead_ratio in afmalloc is
> just 3% ~ 4% while overhead_ratio on zsmalloc varies 5% ~ 17%.
>
> And, 4% ~ 11% overhead_ratio in afmalloc is also slightly better
> than overhead_ratio in zsmalloc which is 5% ~ 17%.

I think the key will be scaling up this test more.  What does it look
like when using 20G or more?

It certainly looks better when using (relatively) small amounts of data, though.

>
> Below is another simple test to check fragmentation effect in alloc/free
> repetition workload.
>
> TEST ENV: EXT4 on zram, mount with discard option
> WORKLOAD: untar kernel source, remove dir in descending order in size
> (drivers arch fs sound include). Repeat this untar and remove 10 times.
>
> * untar-merge.out
>
> orig_size compr_size used_size overhead overhead_ratio
> 526.24MB 199.18MB 209.79MB  10.61MB 5.33%
> 288.69MB  97.45MB 104.09MB   6.64MB 6.81%
> 177.69MB  61.14MB  66.89MB   5.75MB 9.40%
> 146.84MB  47.34MB  52.77MB   5.43MB 11.46%
> 124.53MB  38.88MB  44.28MB   5.40MB 13.90%
> 104.29MB  31.71MB  36.87MB   5.17MB 16.29%
> 535.59MB 200.30MB 211.77MB  11.47MB 5.73%
> 294.84MB  98.28MB 106.24MB   7.97MB 8.11%
> 179.99MB  61.58MB  69.34MB   7.76MB 12.60%
> 148.67MB  47.75MB  55.19MB   7.43MB 15.57%
> 125.98MB  39.26MB  46.62MB   7.36MB 18.75%
> 105.05MB  32.03MB  39.18MB   7.15MB 22.32%
> (snip...)
> 535.59MB 200.31MB 211.88MB  11.57MB 5.77%
> 294.84MB  98.28MB 106.62MB   8.34MB 8.49%
> 179.99MB  61.59MB  73.83MB  12.24MB 19.88%
> 148.67MB  47.76MB  59.58MB  11.82MB 24.76%
> 125.98MB  39.27MB  51.10MB  11.84MB 30.14%
> 105.05MB  32.04MB  43.68MB  11.64MB 36.31%
> 535.59MB 200.31MB 211.89MB  11.58MB 5.78%
> 294.84MB  98.28MB 106.68MB   8.40MB 8.55%
> 179.99MB  61.59MB  74.14MB  12.55MB 20.37%
> 148.67MB  47.76MB  59.94MB  12.18MB 25.50%
> 125.98MB  39.27MB  51.46MB  12.19MB 31.04%
> 105.05MB  32.04MB  44.01MB  11.97MB 37.35%
>
> * untar-afmalloc.out
>
> orig_size compr_size used_size overhead overhead_ratio real real-ratio
> 526.23MB 199.17MB 206.36MB   8.02MB 4.03%   7.19MB 3.61%
> 288.68MB  97.45MB 101.25MB   5.42MB 5.56%   3.80MB 3.90%
> 177.68MB  61.14MB  63.43MB   4.00MB 6.54%   2.30MB 3.76%
> 146.83MB  47.34MB  49.20MB   3.66MB 7.74%   1.86MB 3.93%
> 124.52MB  38.87MB  40.41MB   3.33MB 8.57%   1.54MB 3.96%
> 104.29MB  31.70MB  32.95MB   3.23MB 10.19%   1.26MB 3.97%
> 535.59MB 200.30MB 207.59MB   9.21MB 4.60%   7.29MB 3.64%
> 294.84MB  98.27MB 102.14MB   6.23MB 6.34%   3.87MB 3.94%
> 179.99MB  61.58MB  63.91MB   4.98MB 8.09%   2.33MB 3.78%
> 148.67MB  47.75MB  49.64MB   4.48MB 9.37%   1.89MB 3.95%
> 125.98MB  39.26MB  40.82MB   4.23MB 10.78%   1.56MB 3.97%
> 105.05MB  32.03MB  33.30MB   4.10MB 12.81%   1.27MB 3.98%
> (snip...)
> 535.59MB 200.30MB 207.60MB   8.94MB 4.46%   7.29MB 3.64%
> 294.84MB  98.27MB 102.14MB   6.19MB 6.29%   3.87MB 3.94%
> 179.99MB  61.58MB  63.91MB   8.25MB 13.39%   2.33MB 3.79%
> 148.67MB  47.75MB  49.64MB   7.98MB 16.71%   1.89MB 3.96%
> 125.98MB  39.26MB  40.82MB   7.52MB 19.15%   1.56MB 3.98%
> 105.05MB  32.03MB  33.31MB   7.04MB 21.97%   1.28MB 3.98%
> 535.59MB 200.31MB 207.60MB   9.26MB 4.62%   7.30MB 3.64%
> 294.84MB  98.28MB 102.15MB   6.85MB 6.97%   3.87MB 3.94%
> 179.99MB  61.58MB  63.91MB   9.08MB 14.74%   2.33MB 3.79%
> 148.67MB  47.75MB  49.64MB   8.77MB 18.36%   1.89MB 3.96%
> 125.98MB  39.26MB  40.82MB   8.35MB 21.28%   1.56MB 3.98%
> 105.05MB  32.03MB  33.31MB   8.24MB 25.71%   1.28MB 3.98%
>
> As you can see above result, fragmentation grows continuously at each run.
> But, real_overhead_ratio in afmalloc is always just 3% ~ 4%,
> while overhead_ratio on zsmalloc varies 5% ~ 38%.
> Fragmented slab memory can be used for other system, so we don't
> have to much worry about overhead metric in afmalloc. Anyway, overhead
> metric is also better in afmalloc, 4% ~ 26%.
>
> As a result, I think that afmalloc is better than zsmalloc in terms of
> memory efficiency. But, I could be wrong so any comments are welcome. :)
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>  include/linux/afmalloc.h |   21 ++
>  mm/Kconfig               |    7 +
>  mm/Makefile              |    1 +
>  mm/afmalloc.c            |  590 ++++++++++++++++++++++++++++++++++++++++++++++
>  4 files changed, 619 insertions(+)
>  create mode 100644 include/linux/afmalloc.h
>  create mode 100644 mm/afmalloc.c
>
> diff --git a/include/linux/afmalloc.h b/include/linux/afmalloc.h
> new file mode 100644
> index 0000000..751ae56
> --- /dev/null
> +++ b/include/linux/afmalloc.h
> @@ -0,0 +1,21 @@
> +#define AFMALLOC_MIN_LEVEL (1)
> +#ifdef CONFIG_64BIT
> +#define AFMALLOC_MAX_LEVEL (7) /* 4 + 4 + 8 * 7 = 64 */
> +#else
> +#define AFMALLOC_MAX_LEVEL (6) /* 4 + 4 + 4 * 6 = 32 */
> +#endif
> +
> +extern struct afmalloc_pool *afmalloc_create_pool(int max_level,
> +                       size_t max_size, gfp_t flags);
> +extern void afmalloc_destroy_pool(struct afmalloc_pool *pool);
> +extern size_t afmalloc_get_used_pages(struct afmalloc_pool *pool);
> +extern unsigned long afmalloc_alloc(struct afmalloc_pool *pool, size_t len);
> +extern void afmalloc_free(struct afmalloc_pool *pool, unsigned long handle);
> +extern size_t afmalloc_store(struct afmalloc_pool *pool, unsigned long handle,
> +                       void *src, size_t len);
> +extern size_t afmalloc_load(struct afmalloc_pool *pool, unsigned long handle,
> +                       void *dst, size_t len);
> +extern void *afmalloc_map_handle(struct afmalloc_pool *pool,
> +                       unsigned long handle, size_t len, bool read_only);
> +extern void afmalloc_unmap_handle(struct afmalloc_pool *pool,
> +                       unsigned long handle);
> diff --git a/mm/Kconfig b/mm/Kconfig
> index e09cf0a..7869768 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -585,6 +585,13 @@ config ZSMALLOC
>           returned by an alloc().  This handle must be mapped in order to
>           access the allocated space.
>
> +config ANTI_FRAGMENTATION_MALLOC
> +       boolean "Anti-fragmentation memory allocator"
> +       help
> +         Select this to store data into anti-fragmentation memory
> +         allocator. This helps to reduce internal/external
> +         fragmentation caused by storing arbitrary sized data.
> +
>  config PGTABLE_MAPPING
>         bool "Use page table mapping to access object in zsmalloc"
>         depends on ZSMALLOC
> diff --git a/mm/Makefile b/mm/Makefile
> index b2f18dc..d47b147 100644
> --- a/mm/Makefile
> +++ b/mm/Makefile
> @@ -62,6 +62,7 @@ obj-$(CONFIG_MEMORY_ISOLATION) += page_isolation.o
>  obj-$(CONFIG_ZPOOL)    += zpool.o
>  obj-$(CONFIG_ZBUD)     += zbud.o
>  obj-$(CONFIG_ZSMALLOC) += zsmalloc.o
> +obj-$(CONFIG_ANTI_FRAGMENTATION_MALLOC) += afmalloc.o
>  obj-$(CONFIG_GENERIC_EARLY_IOREMAP) += early_ioremap.o
>  obj-$(CONFIG_CMA)      += cma.o
>  obj-$(CONFIG_MEMORY_BALLOON) += balloon_compaction.o
> diff --git a/mm/afmalloc.c b/mm/afmalloc.c
> new file mode 100644
> index 0000000..83a5c61
> --- /dev/null
> +++ b/mm/afmalloc.c
> @@ -0,0 +1,590 @@
> +/*
> + * Anti Fragmentation Memory allocator
> + *
> + * Copyright (C) 2014 Joonsoo Kim
> + *
> + * Anti Fragmentation Memory allocator(aka afmalloc) is special purpose
> + * allocator in order to deal with arbitrary sized object allocation
> + * efficiently in terms of memory utilization.
> + *
> + * Overall design is too simple.
> + *
> + * If request is for power of 2 sized object, afmalloc allocate object
> + * from the SLAB, add tag on it and return it to requestor. This tag will be
> + * used for determining whether it is a handle for metadata or not.
> + *
> + * If request isn't for power of 2 sized object, afmalloc divides size
> + * into elements in power of 2 size. For example, 400 byte request, 256,
> + * 128, 16 bytes build up 400 bytes. afmalloc allocates these size memory
> + * from the SLAB and allocates memory for metadata to keep the pointer of
> + * these chunks. Conceptual representation of metadata structure is below.
> + *
> + * Metadata for 400 bytes
> + * - Pointer for 256 bytes chunk
> + * - Pointer for 128 bytes chunk
> + * - Pointer for 16 bytes chunk
> + *
> + * After allocation all of them, afmalloc returns handle for this metadata to
> + * requestor. Requestor can load/store from/into this memory via this handle.
> + *
> + * Returned memory from afmalloc isn't contiguous so using this memory needs
> + * special APIs. afmalloc_(load/store) handles load/store requests according
> + * to afmalloc's internal structure, so you can use it without any anxiety.
> + *
> + * If you may want to use this memory like as normal memory, you need to call
> + * afmalloc_map_object before using it. This returns contiguous memory for
> + * this handle so that you could use it with normal memory operation.
> + * Unfortunately, only one object can be mapped per cpu at a time and to
> + * contruct this mapping has some overhead.
> + */
> +
> +#include <linux/kernel.h>
> +#include <linux/types.h>
> +#include <linux/spinlock.h>
> +#include <linux/slab.h>
> +#include <linux/afmalloc.h>
> +#include <linux/highmem.h>
> +#include <linux/sizes.h>
> +#include <linux/module.h>
> +
> +#define afmalloc_OBJ_MIN_SIZE (32)
> +
> +#define DIRECT_ENTRY (0x1)
> +
> +struct afmalloc_pool {
> +       spinlock_t lock;
> +       gfp_t flags;
> +       int max_level;
> +       size_t max_size;
> +       size_t size;
> +};
> +
> +struct afmalloc_entry {
> +       int level;
> +       int alloced;
> +       void *mem[];
> +};
> +
> +struct afmalloc_mapped_info {
> +       struct page *page;
> +       size_t len;
> +       bool read_only;
> +};
> +
> +static struct afmalloc_mapped_info __percpu *mapped_info;
> +
> +static struct afmalloc_entry *mem_to_direct_entry(void *mem)
> +{
> +       return (struct afmalloc_entry *)((unsigned long)mem | DIRECT_ENTRY);
> +}
> +
> +static void *direct_entry_to_mem(struct afmalloc_entry *entry)
> +{
> +       return (void *)((unsigned long)entry & ~DIRECT_ENTRY);
> +}
> +
> +static bool is_direct_entry(struct afmalloc_entry *entry)
> +{
> +       return (unsigned long)entry & DIRECT_ENTRY;
> +}
> +
> +static unsigned long entry_to_handle(struct afmalloc_entry *entry)
> +{
> +       return (unsigned long)entry;
> +}
> +
> +static struct afmalloc_entry *handle_to_entry(unsigned long handle)
> +{
> +       return (struct afmalloc_entry *)handle;
> +}
> +
> +static bool valid_level(int max_level)
> +{
> +       if (max_level < AFMALLOC_MIN_LEVEL)
> +               return false;
> +
> +       if (max_level > AFMALLOC_MAX_LEVEL)
> +               return false;
> +
> +       return true;
> +}
> +
> +static bool valid_flags(gfp_t flags)
> +{
> +       if (flags & __GFP_HIGHMEM)
> +               return false;
> +
> +       return true;
> +}
> +
> +/**
> + * afmalloc_create_pool - Creates an allocation pool to work from.
> + * @max_level: limit on number of chunks that is part of requested memory
> + * @max_size: limit on total allocation size from this pool
> + * @flags: allocation flags used to allocate memory
> + *
> + * This function must be called before anything when using
> + * the afmalloc allocator.
> + *
> + * On success, a pointer to the newly created pool is returned,
> + * otherwise NULL.
> + */
> +struct afmalloc_pool *afmalloc_create_pool(int max_level, size_t max_size,
> +                                       gfp_t flags)
> +{
> +       struct afmalloc_pool *pool;
> +
> +       if (!valid_level(max_level))
> +               return NULL;
> +
> +       if (!valid_flags(flags))
> +               return NULL;
> +
> +       pool = kzalloc(sizeof(*pool), GFP_KERNEL);
> +       if (!pool)
> +               return NULL;
> +
> +       spin_lock_init(&pool->lock);
> +       pool->flags = flags;
> +       pool->max_level = max_level;
> +       pool->max_size = max_size;
> +       pool->size = 0;
> +
> +       return pool;
> +}
> +EXPORT_SYMBOL(afmalloc_create_pool);
> +
> +void afmalloc_destroy_pool(struct afmalloc_pool *pool)
> +{
> +       kfree(pool);
> +}
> +EXPORT_SYMBOL(afmalloc_destroy_pool);
> +
> +size_t afmalloc_get_used_pages(struct afmalloc_pool *pool)
> +{
> +       size_t size;
> +
> +       spin_lock(&pool->lock);
> +       size = pool->size >> PAGE_SHIFT;
> +       spin_unlock(&pool->lock);
> +
> +       return size;
> +}
> +EXPORT_SYMBOL(afmalloc_get_used_pages);
> +
> +static void free_entry(struct afmalloc_pool *pool, struct afmalloc_entry *entry,
> +                       bool calc_size)
> +{
> +       int i;
> +       int level;
> +       int alloced;
> +
> +       if (is_direct_entry(entry)) {
> +               void *mem = direct_entry_to_mem(entry);
> +
> +               alloced = ksize(mem);
> +               kfree(mem);
> +               goto out;
> +       }
> +
> +       level = entry->level;
> +       alloced = entry->alloced;
> +       for (i = 0; i < level; i++)
> +               kfree(entry->mem[i]);
> +
> +       kfree(entry);
> +
> +out:
> +       if (calc_size && alloced) {
> +               spin_lock(&pool->lock);
> +               pool->size -= alloced;
> +               spin_unlock(&pool->lock);
> +       }
> +}
> +
> +static int calculate_level(struct afmalloc_pool *pool, size_t len)
> +{
> +       int level = 0;
> +       size_t down_size, up_size;
> +
> +       if (len <= afmalloc_OBJ_MIN_SIZE)
> +               goto out;
> +
> +       while (1) {
> +               down_size = rounddown_pow_of_two(len);
> +               if (down_size >= len)
> +                       break;
> +
> +               up_size = roundup_pow_of_two(len);
> +               if (up_size - len <= afmalloc_OBJ_MIN_SIZE)
> +                       break;
> +
> +               len -= down_size;
> +               level++;
> +       }
> +
> +out:
> +       level++;
> +       return min(level, pool->max_level);
> +}
> +
> +static int estimate_alloced(struct afmalloc_pool *pool, int level, size_t len)
> +{
> +       int i, alloced = 0;
> +       size_t size;
> +
> +       for (i = 0; i < level - 1; i++) {
> +               size = rounddown_pow_of_two(len);
> +               alloced += size;
> +               len -= size;
> +       }
> +
> +       if (len < afmalloc_OBJ_MIN_SIZE)
> +               size = afmalloc_OBJ_MIN_SIZE;
> +       else
> +               size = roundup_pow_of_two(len);
> +       alloced += size;
> +
> +       return alloced;
> +}
> +
> +static void *alloc_entry(struct afmalloc_pool *pool, size_t len)
> +{
> +       int i, level;
> +       size_t size;
> +       int alloced = 0;
> +       size_t remain = len;
> +       struct afmalloc_entry *entry;
> +       void *mem;
> +
> +       /*
> +        * Determine whether memory is power of 2 or not. If not,
> +        * determine how many chunks are needed.
> +        */
> +       level = calculate_level(pool, len);
> +       if (level == 1)
> +               goto alloc_direct_entry;
> +
> +       size = sizeof(void *) * level + sizeof(struct afmalloc_entry);
> +       entry = kmalloc(size, pool->flags);
> +       if (!entry)
> +               return NULL;
> +
> +       size = ksize(entry);
> +       alloced += size;
> +
> +       /*
> +        * Although request isn't for power of 2 object, sometimes, it is
> +        * better to allocate one power of 2 memory due to waste of metadata.
> +        */
> +       if (size + estimate_alloced(pool, level, len)
> +                               >= roundup_pow_of_two(len)) {
> +               kfree(entry);
> +               goto alloc_direct_entry;
> +       }
> +
> +       entry->level = level;
> +       for (i = 0; i < level - 1; i++) {
> +               size = rounddown_pow_of_two(remain);
> +               entry->mem[i] = kmalloc(size, pool->flags);
> +               if (!entry->mem[i])
> +                       goto err;
> +
> +               alloced += size;
> +               remain -= size;
> +       }
> +
> +       if (remain < afmalloc_OBJ_MIN_SIZE)
> +               size = afmalloc_OBJ_MIN_SIZE;
> +       else
> +               size = roundup_pow_of_two(remain);
> +       entry->mem[i] = kmalloc(size, pool->flags);
> +       if (!entry->mem[i])
> +               goto err;
> +
> +       alloced += size;
> +       entry->alloced = alloced;
> +       goto alloc_complete;
> +
> +alloc_direct_entry:
> +       mem = kmalloc(len, pool->flags);
> +       if (!mem)
> +               return NULL;
> +
> +       alloced = ksize(mem);
> +       entry = mem_to_direct_entry(mem);
> +
> +alloc_complete:
> +       spin_lock(&pool->lock);
> +       if (pool->size + alloced > pool->max_size) {
> +               spin_unlock(&pool->lock);
> +               goto err;
> +       }
> +
> +       pool->size += alloced;
> +       spin_unlock(&pool->lock);
> +
> +       return entry;
> +
> +err:
> +       free_entry(pool, entry, false);
> +
> +       return NULL;
> +}
> +
> +static bool valid_alloc_arg(size_t len)
> +{
> +       if (!len)
> +               return false;
> +
> +       return true;
> +}
> +
> +/**
> + * afmalloc_alloc - Allocate block of given length from pool
> + * @pool: pool from which the object was allocated
> + * @len: length of block to allocate
> + *
> + * On success, handle to the allocated object is returned,
> + * otherwise 0.
> + */
> +unsigned long afmalloc_alloc(struct afmalloc_pool *pool, size_t len)
> +{
> +       struct afmalloc_entry *entry;
> +
> +       if (!valid_alloc_arg(len))
> +               return 0;
> +
> +       entry = alloc_entry(pool, len);
> +       if (!entry)
> +               return 0;
> +
> +       return entry_to_handle(entry);
> +}
> +EXPORT_SYMBOL(afmalloc_alloc);
> +
> +static void __afmalloc_free(struct afmalloc_pool *pool,
> +                       struct afmalloc_entry *entry)
> +{
> +       free_entry(pool, entry, true);
> +}
> +
> +void afmalloc_free(struct afmalloc_pool *pool, unsigned long handle)
> +{
> +       struct afmalloc_entry *entry;
> +
> +       entry = handle_to_entry(handle);
> +       if (!entry)
> +               return;
> +
> +       __afmalloc_free(pool, entry);
> +}
> +EXPORT_SYMBOL(afmalloc_free);
> +
> +static void __afmalloc_store(struct afmalloc_pool *pool,
> +                       struct afmalloc_entry *entry, void *src, size_t len)
> +{
> +       int i, level = entry->level;
> +       size_t size;
> +       size_t offset = 0;
> +
> +       if (is_direct_entry(entry)) {
> +               memcpy(direct_entry_to_mem(entry), src, len);
> +               return;
> +       }
> +
> +       for (i = 0; i < level - 1; i++) {
> +               size = rounddown_pow_of_two(len);
> +               memcpy(entry->mem[i], src + offset, size);
> +               offset += size;
> +               len -= size;
> +       }
> +       memcpy(entry->mem[i], src + offset, len);
> +}
> +
> +static bool valid_store_arg(struct afmalloc_entry *entry, void *src, size_t len)
> +{
> +       if (!entry)
> +               return false;
> +
> +       if (!src || !len)
> +               return false;
> +
> +       return true;
> +}
> +
> +/**
> + * afmalloc_store - store data into allocated object from handle.
> + * @pool: pool from which the object was allocated
> + * @handle: handle returned from afmalloc
> + * @src: memory address of source data
> + * @len: length in bytes of desired store
> + *
> + * To store data into an object allocated from afmalloc, it must be
> + * mapped before using it or accessed through afmalloc-specific
> + * load/store functions. These functions properly handle load/store
> + * request according to afmalloc's internal structure.
> + */
> +size_t afmalloc_store(struct afmalloc_pool *pool, unsigned long handle,
> +                       void *src, size_t len)
> +{
> +       struct afmalloc_entry *entry;
> +
> +       entry = handle_to_entry(handle);
> +       if (!valid_store_arg(entry, src, len))
> +               return 0;
> +
> +       __afmalloc_store(pool, entry, src, len);
> +
> +       return len;
> +}
> +EXPORT_SYMBOL(afmalloc_store);
> +
> +static void __afmalloc_load(struct afmalloc_pool *pool,
> +                       struct afmalloc_entry *entry, void *dst, size_t len)
> +{
> +       int i, level = entry->level;
> +       size_t size;
> +       size_t offset = 0;
> +
> +       if (is_direct_entry(entry)) {
> +               memcpy(dst, direct_entry_to_mem(entry), len);
> +               return;
> +       }
> +
> +       for (i = 0; i < level - 1; i++) {
> +               size = rounddown_pow_of_two(len);
> +               memcpy(dst + offset, entry->mem[i], size);
> +               offset += size;
> +               len -= size;
> +       }
> +       memcpy(dst + offset, entry->mem[i], len);
> +}
> +
> +static bool valid_load_arg(struct afmalloc_entry *entry, void *dst, size_t len)
> +{
> +       if (!entry)
> +               return false;
> +
> +       if (!dst || !len)
> +               return false;
> +
> +       return true;
> +}
> +
> +size_t afmalloc_load(struct afmalloc_pool *pool, unsigned long handle,
> +               void *dst, size_t len)
> +{
> +       struct afmalloc_entry *entry;
> +
> +       entry = handle_to_entry(handle);
> +       if (!valid_load_arg(entry, dst, len))
> +               return 0;
> +
> +       __afmalloc_load(pool, entry, dst, len);
> +
> +       return len;
> +}
> +EXPORT_SYMBOL(afmalloc_load);
> +
> +/**
> + * afmalloc_map_object - get address of allocated object from handle.
> + * @pool: pool from which the object was allocated
> + * @handle: handle returned from afmalloc
> + * @len: length in bytes of desired mapping
> + * @read_only: flag that represents whether data on mapped region is
> + *     written back into an object or not
> + *
> + * Before using an object allocated from afmalloc, it must be mapped using
> + * this function. When done with the object, it must be unmapped using
> + * afmalloc_unmap_handle.
> + *
> + * Only one object can be mapped per cpu at a time. There is no protection
> + * against nested mappings.
> + *
> + * This function returns with preemption and page faults disabled.
> + */
> +void *afmalloc_map_handle(struct afmalloc_pool *pool, unsigned long handle,
> +                       size_t len, bool read_only)
> +{
> +       int cpu;
> +       struct afmalloc_entry *entry;
> +       struct afmalloc_mapped_info *info;
> +       void *addr;
> +
> +       entry = handle_to_entry(handle);
> +       if (!entry)
> +               return NULL;
> +
> +       cpu = get_cpu();
> +       if (is_direct_entry(entry))
> +               return direct_entry_to_mem(entry);
> +
> +       info = per_cpu_ptr(mapped_info, cpu);
> +       addr = page_address(info->page);
> +       info->len = len;
> +       info->read_only = read_only;
> +       __afmalloc_load(pool, entry, addr, len);
> +       return addr;
> +}
> +EXPORT_SYMBOL(afmalloc_map_handle);
> +
> +void afmalloc_unmap_handle(struct afmalloc_pool *pool, unsigned long handle)
> +{
> +       struct afmalloc_entry *entry;
> +       struct afmalloc_mapped_info *info;
> +       void *addr;
> +
> +       entry = handle_to_entry(handle);
> +       if (!entry)
> +               return;
> +
> +       if (is_direct_entry(entry))
> +               goto out;
> +
> +       info = this_cpu_ptr(mapped_info);
> +       if (info->read_only)
> +               goto out;
> +
> +       addr = page_address(info->page);
> +       __afmalloc_store(pool, entry, addr, info->len);
> +
> +out:
> +       put_cpu();
> +}
> +EXPORT_SYMBOL(afmalloc_unmap_handle);
> +
> +static int __init afmalloc_init(void)
> +{
> +       int cpu;
> +
> +       mapped_info = alloc_percpu(struct afmalloc_mapped_info);
> +       if (!mapped_info)
> +               return -ENOMEM;
> +
> +       for_each_possible_cpu(cpu) {
> +               struct page *page;
> +
> +               page = alloc_pages(GFP_KERNEL, 0);
> +               if (!page)
> +                       goto err;
> +
> +               per_cpu_ptr(mapped_info, cpu)->page = page;
> +       }
> +
> +       return 0;
> +
> +err:
> +       for_each_possible_cpu(cpu) {
> +               struct page *page;
> +
> +               page = per_cpu_ptr(mapped_info, cpu)->page;
> +               if (page)
> +                       __free_pages(page, 0);
> +       }
> +       free_percpu(mapped_info);
> +       return -ENOMEM;
> +}
> +module_init(afmalloc_init);
> +
> +MODULE_AUTHOR("Joonsoo Kim <iamjoonsoo.kim@lge.com>");
> --
> 1.7.9.5
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
