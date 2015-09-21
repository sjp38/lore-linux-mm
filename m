Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f170.google.com (mail-io0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id 6E7C36B0253
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 12:18:02 -0400 (EDT)
Received: by iofb144 with SMTP id b144so125819127iof.1
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 09:18:02 -0700 (PDT)
Received: from mail-ig0-x22f.google.com (mail-ig0-x22f.google.com. [2607:f8b0:4001:c05::22f])
        by mx.google.com with ESMTPS id f194si17661055ioe.72.2015.09.21.09.18.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Sep 2015 09:18:01 -0700 (PDT)
Received: by igbkq10 with SMTP id kq10so82327091igb.0
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 09:18:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150916135048.fbd50fac5e91244ab9731b82@gmail.com>
References: <20150916134857.e4a71f601a1f68cfa16cb361@gmail.com> <20150916135048.fbd50fac5e91244ab9731b82@gmail.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Mon, 21 Sep 2015 12:17:21 -0400
Message-ID: <CALZtONCF6mSU1dKkv2bX+koM4LHciQ0TJciQx4k-PZzs8_mTNQ@mail.gmail.com>
Subject: Re: [PATCH 1/2] zbud: allow PAGE_SIZE allocations
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Seth Jennings <sjennings@variantweb.net>

Please make sure to cc Seth also, he's the owner of zbud.

On Wed, Sep 16, 2015 at 7:50 AM, Vitaly Wool <vitalywool@gmail.com> wrote:
> For zram to be able to use zbud via the common zpool API,
> allocations of size PAGE_SIZE should be allowed by zpool.
> zbud uses the beginning of an allocated page for its internal
> structure but it is not a problem as long as we keep track of
> such special pages using a newly introduced page flag.
> To be able to keep track of zbud pages in any case, struct page's
> lru pointer will be used for zbud page lists instead of the one
> that used to be part of the aforementioned internal structure.
>
> Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
> ---
>  include/linux/page-flags.h |  3 ++
>  mm/zbud.c                  | 71 ++++++++++++++++++++++++++++++++++++++--------
>  2 files changed, 62 insertions(+), 12 deletions(-)
>
> diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> index 416509e..dd47cf0 100644
> --- a/include/linux/page-flags.h
> +++ b/include/linux/page-flags.h
> @@ -134,6 +134,9 @@ enum pageflags {
>
>         /* SLOB */
>         PG_slob_free = PG_private,
> +
> +       /* ZBUD */
> +       PG_uncompressed = PG_owner_priv_1,

you don't need a new page flag.  and there's 0% chance it would be
accepted even if you did.

>  };
>
>  #ifndef __GENERATING_BOUNDS_H
> diff --git a/mm/zbud.c b/mm/zbud.c
> index fa48bcdf..ee8b5d6 100644
> --- a/mm/zbud.c
> +++ b/mm/zbud.c
> @@ -107,13 +107,11 @@ struct zbud_pool {
>   * struct zbud_header - zbud page metadata occupying the first chunk of each
>   *                     zbud page.
>   * @buddy:     links the zbud page into the unbuddied/buddied lists in the pool
> - * @lru:       links the zbud page into the lru list in the pool
>   * @first_chunks:      the size of the first buddy in chunks, 0 if free
>   * @last_chunks:       the size of the last buddy in chunks, 0 if free
>   */
>  struct zbud_header {
>         struct list_head buddy;
> -       struct list_head lru;
>         unsigned int first_chunks;
>         unsigned int last_chunks;
>         bool under_reclaim;
> @@ -221,6 +219,7 @@ MODULE_ALIAS("zpool-zbud");
>  *****************/
>  /* Just to make the code easier to read */
>  enum buddy {
> +       FULL,
>         FIRST,
>         LAST
>  };
> @@ -241,7 +240,7 @@ static struct zbud_header *init_zbud_page(struct page *page)
>         zhdr->first_chunks = 0;
>         zhdr->last_chunks = 0;
>         INIT_LIST_HEAD(&zhdr->buddy);
> -       INIT_LIST_HEAD(&zhdr->lru);
> +       INIT_LIST_HEAD(&page->lru);
>         zhdr->under_reclaim = 0;
>         return zhdr;
>  }
> @@ -267,11 +266,18 @@ static unsigned long encode_handle(struct zbud_header *zhdr, enum buddy bud)
>          * over the zbud header in the first chunk.
>          */
>         handle = (unsigned long)zhdr;
> -       if (bud == FIRST)
> +       switch (bud) {
> +       case FIRST:
>                 /* skip over zbud header */
>                 handle += ZHDR_SIZE_ALIGNED;
> -       else /* bud == LAST */
> +               break;
> +       case LAST:
>                 handle += PAGE_SIZE - (zhdr->last_chunks  << CHUNK_SHIFT);
> +               break;
> +       case FULL:
> +       default:

Hmm, while it should be ok to treat a default (invalid) bud value as a
full page (assuming the caller treats it as such), you should at least
add a pr_warn() or pr_warn_ratelimited(), or maybe a WARN_ON() or
WARN_ON_ONCE().  the default case should never happen, and a warning
should be printed if it does.

> +               break;
> +       }
>         return handle;
>  }
>
> @@ -360,6 +366,24 @@ int zbud_alloc(struct zbud_pool *pool, size_t size, gfp_t gfp,
>
>         if (!size || (gfp & __GFP_HIGHMEM))
>                 return -EINVAL;
> +
> +       if (size == PAGE_SIZE) {
> +               /*
> +                * This is a special case. The page will be allocated
> +                * and used to store uncompressed data
> +                */

well you shouldn't special case only PAGE_SIZE.  If zram increases its
max_zpage_size to a value > (PAGE_SIZE - ZHDR_SIZE_ALIGNED -
CHUNK_SIZE) then those compressed pages will fail to store here.

I think it would be better to change the size check to a simple
if (size > PAGE_SIZE)
  return -ENOSPC;

then use the existing
>         if (size > PAGE_SIZE - ZHDR_SIZE_ALIGNED - CHUNK_SIZE)

to store the object (which is either a large compressed page, or an
uncompressed page) into the full zbud page.  And don't duplicate
everything the function does inside an if (), just update the function
to handle PAGE_SIZE storage.

> +               page = alloc_page(gfp);
> +               if (!page)
> +                       return -ENOMEM;
> +               spin_lock(&pool->lock);
> +               pool->pages_nr++;
> +               INIT_LIST_HEAD(&page->lru);
> +               page->flags |= PG_uncompressed;
> +               list_add(&page->lru, &pool->lru);
> +               spin_unlock(&pool->lock);
> +               *handle = encode_handle(page_address(page), FULL);
> +               return 0;
> +       }
>         if (size > PAGE_SIZE - ZHDR_SIZE_ALIGNED - CHUNK_SIZE)
>                 return -ENOSPC;
>         chunks = size_to_chunks(size);
> @@ -372,6 +396,7 @@ int zbud_alloc(struct zbud_pool *pool, size_t size, gfp_t gfp,
>                         zhdr = list_first_entry(&pool->unbuddied[i],
>                                         struct zbud_header, buddy);
>                         list_del(&zhdr->buddy);
> +                       page = virt_to_page(zhdr);
>                         if (zhdr->first_chunks == 0)
>                                 bud = FIRST;
>                         else
> @@ -406,9 +431,9 @@ found:
>         }
>
>         /* Add/move zbud page to beginning of LRU */
> -       if (!list_empty(&zhdr->lru))
> -               list_del(&zhdr->lru);
> -       list_add(&zhdr->lru, &pool->lru);
> +       if (!list_empty(&page->lru))
> +               list_del(&page->lru);
> +       list_add(&page->lru, &pool->lru);
>
>         *handle = encode_handle(zhdr, bud);
>         spin_unlock(&pool->lock);
> @@ -430,9 +455,21 @@ void zbud_free(struct zbud_pool *pool, unsigned long handle)
>  {
>         struct zbud_header *zhdr;
>         int freechunks;
> +       struct page *page;
>
>         spin_lock(&pool->lock);
>         zhdr = handle_to_zbud_header(handle);
> +       page = virt_to_page(zhdr);
> +
> +       /* If it was an uncompressed full page, just free it */
> +       if (page->flags & PG_uncompressed) {
> +               page->flags &= ~PG_uncompressed;
> +               list_del(&page->lru);
> +               __free_page(page);
> +               pool->pages_nr--;
> +               spin_unlock(&pool->lock);
> +               return;
> +       }

don't repeat this function inside an if() block.  update the actual
function to handle the new case.

and you don't need a new page flag.  you have 3 distinct cases:

switch (handle & ~PAGE_MASK) {
case 0: /* this is a full-sized page */
case ZHDR_SIZE_ALIGNED: /* this is the first buddy */
default: /* this is the last buddy */
}


>
>         /* If first buddy, handle will be page aligned */
>         if ((handle - ZHDR_SIZE_ALIGNED) & ~PAGE_MASK)
> @@ -451,7 +488,7 @@ void zbud_free(struct zbud_pool *pool, unsigned long handle)
>
>         if (zhdr->first_chunks == 0 && zhdr->last_chunks == 0) {
>                 /* zbud page is empty, free */
> -               list_del(&zhdr->lru);
> +               list_del(&page->lru);
>                 free_zbud_page(zhdr);
>                 pool->pages_nr--;
>         } else {
> @@ -505,6 +542,7 @@ int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries)
>  {
>         int i, ret, freechunks;
>         struct zbud_header *zhdr;
> +       struct page *page;
>         unsigned long first_handle = 0, last_handle = 0;
>
>         spin_lock(&pool->lock);
> @@ -514,8 +552,17 @@ int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries)
>                 return -EINVAL;
>         }
>         for (i = 0; i < retries; i++) {
> -               zhdr = list_tail_entry(&pool->lru, struct zbud_header, lru);
> -               list_del(&zhdr->lru);
> +               page = list_tail_entry(&pool->lru, struct page, lru);
> +               zhdr = page_address(page);
> +               list_del(&page->lru);
> +               /* Uncompressed zbud page? just run eviction and free it */
> +               if (page->flags & PG_uncompressed) {
> +                       page->flags &= ~PG_uncompressed;
> +                       spin_unlock(&pool->lock);
> +                       pool->ops->evict(pool, encode_handle(zhdr, FULL));
> +                       __free_page(page);
> +                       return 0;

again, don't be redundant.  change the function to handle full-sized
pages, don't repeat the function in an if() block for a special case.

> +               }
>                 list_del(&zhdr->buddy);
>                 /* Protect zbud page against free */
>                 zhdr->under_reclaim = true;
> @@ -565,7 +612,7 @@ next:
>                 }
>
>                 /* add to beginning of LRU */
> -               list_add(&zhdr->lru, &pool->lru);
> +               list_add(&page->lru, &pool->lru);
>         }
>         spin_unlock(&pool->lock);
>         return -EAGAIN;
> --
> 1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
