Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f176.google.com (mail-ie0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id 1B93C6B0036
	for <linux-mm@kvack.org>; Sat, 26 Apr 2014 04:37:33 -0400 (EDT)
Received: by mail-ie0-f176.google.com with SMTP id rd18so4630148iec.7
        for <linux-mm@kvack.org>; Sat, 26 Apr 2014 01:37:32 -0700 (PDT)
Received: from mail-ig0-x229.google.com (mail-ig0-x229.google.com [2607:f8b0:4001:c05::229])
        by mx.google.com with ESMTPS id ng1si7034853icc.52.2014.04.26.01.37.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 26 Apr 2014 01:37:32 -0700 (PDT)
Received: by mail-ig0-f169.google.com with SMTP id h18so3077678igc.0
        for <linux-mm@kvack.org>; Sat, 26 Apr 2014 01:37:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1397922764-1512-3-git-send-email-ddstreet@ieee.org>
References: <1397922764-1512-1-git-send-email-ddstreet@ieee.org>
	<1397922764-1512-3-git-send-email-ddstreet@ieee.org>
Date: Sat, 26 Apr 2014 16:37:31 +0800
Message-ID: <CAL1ERfMPcfyUeACnmZ2QF5WxJUQ2PaKbtRzis8sPbQsjnvf_GQ@mail.gmail.com>
Subject: Re: [PATCH 2/4] mm: zpool: implement zsmalloc shrinking
From: Weijie Yang <weijie.yang.kh@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Seth Jennings <sjennings@variantweb.net>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <bob.liu@oracle.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Weijie Yang <weijie.yang@samsung.com>, Johannes Weiner <hannes@cmpxchg.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Sat, Apr 19, 2014 at 11:52 PM, Dan Streetman <ddstreet@ieee.org> wrote:
> Add zs_shrink() and helper functions to zsmalloc.  Update zsmalloc
> zs_create_pool() creation function to include ops param that provides
> an evict() function for use during shrinking.  Update helper function
> fix_fullness_group() to always reinsert changed zspages even if the
> fullness group did not change, so they are updated in the fullness
> group lru.  Also update zram to use the new zsmalloc pool creation
> function but pass NULL as the ops param, since zram does not use
> pool shrinking.
>

I only review the code without test, however, I think this patch is
not acceptable.

The biggest problem is it will call zswap_writeback_entry() under lock,
zswap_writeback_entry() may sleep, so it is a bug. see below

The 3/4 patch has a lot of #ifdef, I don't think it's a good kind of
abstract way.

What about just disable zswap reclaim when using zsmalloc?
There is a long way to optimize writeback reclaim(both zswap and zram) ,
Maybe a small and simple step forward is better.

Regards,

> Signed-off-by: Dan Streetman <ddstreet@ieee.org>
>
> ---
>
> To find all the used objects inside a zspage, I had to do a full scan
> of the zspage->freelist for each object, since there's no list of used
> objects, and no way to keep a list of used objects without allocating
> more memory for each zspage (that I could see).  Of course, by taking
> a byte (or really only a bit) out of each object's memory area to use
> as a flag, we could just check that instead of scanning ->freelist
> for each zspage object, but that would (slightly) reduce the available
> size of each zspage object.
>
>
>  drivers/block/zram/zram_drv.c |   2 +-
>  include/linux/zsmalloc.h      |   7 +-
>  mm/zsmalloc.c                 | 168 ++++++++++++++++++++++++++++++++++++++----
>  3 files changed, 160 insertions(+), 17 deletions(-)
>
> diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
> index 9849b52..dacf343 100644
> --- a/drivers/block/zram/zram_drv.c
> +++ b/drivers/block/zram/zram_drv.c
> @@ -249,7 +249,7 @@ static struct zram_meta *zram_meta_alloc(u64 disksize)
>                 goto free_meta;
>         }
>
> -       meta->mem_pool = zs_create_pool(GFP_NOIO | __GFP_HIGHMEM);
> +       meta->mem_pool = zs_create_pool(GFP_NOIO | __GFP_HIGHMEM, NULL);
>         if (!meta->mem_pool) {
>                 pr_err("Error creating memory pool\n");
>                 goto free_table;
> diff --git a/include/linux/zsmalloc.h b/include/linux/zsmalloc.h
> index e44d634..a75ab6e 100644
> --- a/include/linux/zsmalloc.h
> +++ b/include/linux/zsmalloc.h
> @@ -36,11 +36,16 @@ enum zs_mapmode {
>
>  struct zs_pool;
>
> -struct zs_pool *zs_create_pool(gfp_t flags);
> +struct zs_ops {
> +       int (*evict)(struct zs_pool *pool, unsigned long handle);
> +};
> +
> +struct zs_pool *zs_create_pool(gfp_t flags, struct zs_ops *ops);
>  void zs_destroy_pool(struct zs_pool *pool);
>
>  unsigned long zs_malloc(struct zs_pool *pool, size_t size);
>  void zs_free(struct zs_pool *pool, unsigned long obj);
> +int zs_shrink(struct zs_pool *pool, size_t size);
>
>  void *zs_map_object(struct zs_pool *pool, unsigned long handle,
>                         enum zs_mapmode mm);
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index 36b4591..b99bec0 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -219,6 +219,8 @@ struct zs_pool {
>         struct size_class size_class[ZS_SIZE_CLASSES];
>
>         gfp_t flags;    /* allocation flags used when growing pool */
> +
> +       struct zs_ops *ops;
>  };
>
>  /*
> @@ -389,16 +391,14 @@ static enum fullness_group fix_fullness_group(struct zs_pool *pool,
>         BUG_ON(!is_first_page(page));
>
>         get_zspage_mapping(page, &class_idx, &currfg);
> -       newfg = get_fullness_group(page);
> -       if (newfg == currfg)
> -               goto out;
> -
>         class = &pool->size_class[class_idx];
> +       newfg = get_fullness_group(page);
> +       /* Need to do this even if currfg == newfg, to update lru */
>         remove_zspage(page, class, currfg);
>         insert_zspage(page, class, newfg);
> -       set_zspage_mapping(page, class_idx, newfg);
> +       if (currfg != newfg)
> +               set_zspage_mapping(page, class_idx, newfg);
>
> -out:
>         return newfg;
>  }
>
> @@ -438,6 +438,36 @@ static int get_pages_per_zspage(int class_size)
>  }
>
>  /*
> + * To determine which class to use when shrinking, we find the
> + * first zspage class that is greater than the requested shrink
> + * size, and has at least one zspage.  This returns the class
> + * with the class lock held, or NULL.
> + */
> +static struct size_class *get_class_to_shrink(struct zs_pool *pool,
> +                       size_t size)
> +{
> +       struct size_class *class;
> +       int i;
> +       bool in_use, large_enough;
> +
> +       for (i = 0; i <= ZS_SIZE_CLASSES; i++) {
> +               class = &pool->size_class[i];
> +
> +               spin_lock(&class->lock);
> +
> +               in_use = class->pages_allocated > 0;
> +               large_enough = class->pages_per_zspage * PAGE_SIZE >= size;
> +
> +               if (in_use && large_enough)
> +                       return class;
> +
> +               spin_unlock(&class->lock);
> +       }
> +
> +       return NULL;
> +}
> +
> +/*
>   * A single 'zspage' is composed of many system pages which are
>   * linked together using fields in struct page. This function finds
>   * the first/head page, given any component page of a zspage.
> @@ -508,6 +538,48 @@ static unsigned long obj_idx_to_offset(struct page *page,
>         return off + obj_idx * class_size;
>  }
>
> +static bool obj_handle_is_free(struct page *first_page,
> +                       struct size_class *class, unsigned long handle)
> +{
> +       unsigned long obj, idx, offset;
> +       struct page *page;
> +       struct link_free *link;
> +
> +       BUG_ON(!is_first_page(first_page));
> +
> +       obj = (unsigned long)first_page->freelist;
> +
> +       while (obj) {
> +               if (obj == handle)
> +                       return true;
> +
> +               obj_handle_to_location(obj, &page, &idx);
> +               offset = obj_idx_to_offset(page, idx, class->size);
> +
> +               link = (struct link_free *)kmap_atomic(page) +
> +                                       offset / sizeof(*link);
> +               obj = (unsigned long)link->next;
> +               kunmap_atomic(link);
> +       }
> +
> +       return false;
> +}
> +
> +static void obj_free(unsigned long obj, struct page *page, unsigned long offset)
> +{
> +       struct page *first_page = get_first_page(page);
> +       struct link_free *link;
> +
> +       /* Insert this object in containing zspage's freelist */
> +       link = (struct link_free *)((unsigned char *)kmap_atomic(page)
> +                                                       + offset);
> +       link->next = first_page->freelist;
> +       kunmap_atomic(link);
> +       first_page->freelist = (void *)obj;
> +
> +       first_page->inuse--;
> +}
> +
>  static void reset_page(struct page *page)
>  {
>         clear_bit(PG_private, &page->flags);
> @@ -651,6 +723,39 @@ cleanup:
>         return first_page;
>  }
>
> +static int reclaim_zspage(struct zs_pool *pool, struct size_class *class,
> +                       struct page *first_page)
> +{
> +       struct page *page = first_page;
> +       unsigned long offset = 0, handle, idx, objs;
> +       int ret = 0;
> +
> +       BUG_ON(!is_first_page(page));
> +       BUG_ON(!pool->ops);
> +       BUG_ON(!pool->ops->evict);
> +
> +       while (page) {
> +               objs = DIV_ROUND_UP(PAGE_SIZE - offset, class->size);
> +
> +               for (idx = 0; idx < objs; idx++) {
> +                       handle = (unsigned long)obj_location_to_handle(page,
> +                                                                       idx);
> +                       if (!obj_handle_is_free(first_page, class, handle))
> +                               ret = pool->ops->evict(pool, handle);

call zswap_writeback_entry() under class->lock.

> +                       if (ret)
> +                               return ret;
> +                       else
> +                               obj_free(handle, page, offset);
> +               }
> +
> +               page = get_next_page(page);
> +               if (page)
> +                       offset = page->index;
> +       }
> +
> +       return 0;
> +}
> +
>  static struct page *find_get_zspage(struct size_class *class)
>  {
>         int i;
> @@ -856,7 +961,7 @@ fail:
>   * On success, a pointer to the newly created pool is returned,
>   * otherwise NULL.
>   */
> -struct zs_pool *zs_create_pool(gfp_t flags)
> +struct zs_pool *zs_create_pool(gfp_t flags, struct zs_ops *ops)
>  {
>         int i, ovhd_size;
>         struct zs_pool *pool;
> @@ -883,6 +988,7 @@ struct zs_pool *zs_create_pool(gfp_t flags)
>         }
>
>         pool->flags = flags;
> +       pool->ops = ops;
>
>         return pool;
>  }
> @@ -968,7 +1074,6 @@ EXPORT_SYMBOL_GPL(zs_malloc);
>
>  void zs_free(struct zs_pool *pool, unsigned long obj)
>  {
> -       struct link_free *link;
>         struct page *first_page, *f_page;
>         unsigned long f_objidx, f_offset;
>
> @@ -988,14 +1093,8 @@ void zs_free(struct zs_pool *pool, unsigned long obj)
>
>         spin_lock(&class->lock);
>
> -       /* Insert this object in containing zspage's freelist */
> -       link = (struct link_free *)((unsigned char *)kmap_atomic(f_page)
> -                                                       + f_offset);
> -       link->next = first_page->freelist;
> -       kunmap_atomic(link);
> -       first_page->freelist = (void *)obj;
> +       obj_free(obj, f_page, f_offset);
>
> -       first_page->inuse--;
>         fullness = fix_fullness_group(pool, first_page);
>
>         if (fullness == ZS_EMPTY)
> @@ -1008,6 +1107,45 @@ void zs_free(struct zs_pool *pool, unsigned long obj)
>  }
>  EXPORT_SYMBOL_GPL(zs_free);
>
> +int zs_shrink(struct zs_pool *pool, size_t size)
> +{
> +       struct size_class *class;
> +       struct page *first_page;
> +       enum fullness_group fullness;
> +       int ret;
> +
> +       if (!pool->ops || !pool->ops->evict)
> +               return -EINVAL;
> +
> +       /* the class is returned locked */
> +       class = get_class_to_shrink(pool, size);
> +       if (!class)
> +               return -ENOENT;
> +
> +       first_page = find_get_zspage(class);
> +       if (!first_page) {
> +               spin_unlock(&class->lock);
> +               return -ENOENT;
> +       }
> +
> +       ret = reclaim_zspage(pool, class, first_page);
> +
> +       if (ret) {
> +               fullness = fix_fullness_group(pool, first_page);
> +
> +               if (fullness == ZS_EMPTY)
> +                       class->pages_allocated -= class->pages_per_zspage;
> +       }
> +
> +       spin_unlock(&class->lock);
> +
> +       if (!ret || fullness == ZS_EMPTY)
> +               free_zspage(first_page);
> +
> +       return ret;
> +}
> +EXPORT_SYMBOL_GPL(zs_shrink);
> +
>  /**
>   * zs_map_object - get address of allocated object from handle.
>   * @pool: pool from which the object was allocated
> --
> 1.8.3.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
