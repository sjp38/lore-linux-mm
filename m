Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f178.google.com (mail-io0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 2F9EA6B0253
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 17:50:19 -0400 (EDT)
Received: by ioii196 with SMTP id i196so28124463ioi.3
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 14:50:19 -0700 (PDT)
Received: from mail-io0-x233.google.com (mail-io0-x233.google.com. [2607:f8b0:4001:c06::233])
        by mx.google.com with ESMTPS id d204si4284050iod.66.2015.09.22.14.50.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Sep 2015 14:50:18 -0700 (PDT)
Received: by ioiz6 with SMTP id z6so27969506ioi.2
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 14:50:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150922141733.d7d97f59f207d0655c3b881d@gmail.com>
References: <20150922141733.d7d97f59f207d0655c3b881d@gmail.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Tue, 22 Sep 2015 17:49:36 -0400
Message-ID: <CALZtONAhARM8FkxLpNQ9-jx4TOU-RyLm2c8suyOY3iN2yvWvLQ@mail.gmail.com>
Subject: Re: [PATCH v2] zbud: allow up to PAGE_SIZE allocations
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Seth Jennings <sjennings@variantweb.net>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Tue, Sep 22, 2015 at 8:17 AM, Vitaly Wool <vitalywool@gmail.com> wrote:
> Currently zbud is only capable of allocating not more than
> PAGE_SIZE - ZHDR_SIZE_ALIGNED - CHUNK_SIZE. This is okay as
> long as only zswap is using it, but other users of zbud may
> (and likely will) want to allocate up to PAGE_SIZE. This patch
> addresses that by skipping the creation of zbud internal
> structure in the beginning of an allocated page (such pages are
> then called 'headless').
>
> As a zbud page is no longer guaranteed to contain zbud header, the
> following changes had to be applied throughout the code:
> * page->lru to be used for zbud page lists
> * page->private to hold 'under_reclaim' flag
>
> page->private will also be used to indicate if this page contains
> a zbud header in the beginning or not ('headless' flag).
>
> Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
> ---
>  mm/zbud.c | 194 +++++++++++++++++++++++++++++++++++++++++---------------------
>  1 file changed, 128 insertions(+), 66 deletions(-)
>
> diff --git a/mm/zbud.c b/mm/zbud.c
> index fa48bcdf..7b51eb6 100644
> --- a/mm/zbud.c
> +++ b/mm/zbud.c
> @@ -105,18 +105,25 @@ struct zbud_pool {
>
>  /*
>   * struct zbud_header - zbud page metadata occupying the first chunk of each
> - *                     zbud page.
> + *                     zbud page, except for HEADLESS pages

hmm, personally I like "FULL" better than HEADLESS...it's only
headless because it's a full page.

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
> -       bool under_reclaim;
> +};
> +
> +/*
> + * struct zbud_page_priv - zbud flags to be stored in page->private
> + * @under_reclaim: if a zbud page is under reclaim
> + * @headless: indicates a page where zbud header didn't fit
> + */
> +struct zbud_page_priv {
> +       bool under_reclaim:1;
> +       bool headless:1;
>  };

Hmm, this is just my personal opinion, but I'm not a fan of casting
->private as a struct, if we're only using it as a bitmap.  I'd
suggest just defining bits as an enum (like page flags), e.g.

enum zbud_flags {
  ZBUD_UNDER_RECLAIM,
  ZBUD_FULL_PAGE,
};

or some names similar to that.  then it can be checked with a simple
test_bit() call, and set_bit()/clear_bit().

alternately, there are the already-existing PG_private and
PG_private_2 bits in the page flags...but unless we need ->private for
something else, it probably makes more sense to just use it instead of
the PG_private flags.

>
>  /*****************
> @@ -221,6 +228,7 @@ MODULE_ALIAS("zpool-zbud");
>  *****************/
>  /* Just to make the code easier to read */
>  enum buddy {
> +       HEADLESS,
>         FIRST,
>         LAST
>  };
> @@ -237,12 +245,15 @@ static int size_to_chunks(size_t size)
>  /* Initializes the zbud header of a newly allocated zbud page */
>  static struct zbud_header *init_zbud_page(struct page *page)
>  {
> +       struct zbud_page_priv *ppriv = (struct zbud_page_priv *)page->private;
>         struct zbud_header *zhdr = page_address(page);
> +
> +       INIT_LIST_HEAD(&page->lru);
> +       ppriv->under_reclaim = 0;

don't forget to initialize the headless/full bit too.  (I'll mention
that the page allocation code does clear ->private before handing it
to us, so it should already be 0.  but let's not rely on that)

> +
>         zhdr->first_chunks = 0;
>         zhdr->last_chunks = 0;
>         INIT_LIST_HEAD(&zhdr->buddy);
> -       INIT_LIST_HEAD(&zhdr->lru);
> -       zhdr->under_reclaim = 0;
>         return zhdr;
>  }
>
> @@ -267,11 +278,22 @@ static unsigned long encode_handle(struct zbud_header *zhdr, enum buddy bud)
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
> +       case HEADLESS:
> +               break;
> +       default:
> +               /* this should never happen */
> +               pr_err("zbud: invalid buddy value %d\n", bud);
> +               handle = 0;
> +               break;
> +       }
>         return handle;
>  }
>
> @@ -287,6 +309,7 @@ static int num_free_chunks(struct zbud_header *zhdr)
>         /*
>          * Rather than branch for different situations, just use the fact that
>          * free buddies have a length of zero to simplify everything.
> +        * NB: can't be used with HEADLESS pages.
>          */
>         return NCHUNKS - zhdr->first_chunks - zhdr->last_chunks;
>  }
> @@ -353,31 +376,40 @@ void zbud_destroy_pool(struct zbud_pool *pool)
>  int zbud_alloc(struct zbud_pool *pool, size_t size, gfp_t gfp,
>                         unsigned long *handle)
>  {
> -       int chunks, i, freechunks;
> +       int chunks = 0, i, freechunks;
>         struct zbud_header *zhdr = NULL;
> +       struct zbud_page_priv *ppriv;
>         enum buddy bud;
>         struct page *page;
>
>         if (!size || (gfp & __GFP_HIGHMEM))
>                 return -EINVAL;
> -       if (size > PAGE_SIZE - ZHDR_SIZE_ALIGNED - CHUNK_SIZE)
> +
> +       if (size > PAGE_SIZE)
>                 return -ENOSPC;
> -       chunks = size_to_chunks(size);
> -       spin_lock(&pool->lock);
>
> -       /* First, try to find an unbuddied zbud page. */
> -       zhdr = NULL;
> -       for_each_unbuddied_list(i, chunks) {
> -               if (!list_empty(&pool->unbuddied[i])) {
> -                       zhdr = list_first_entry(&pool->unbuddied[i],
> -                                       struct zbud_header, buddy);
> -                       list_del(&zhdr->buddy);
> -                       if (zhdr->first_chunks == 0)
> -                               bud = FIRST;
> -                       else
> -                               bud = LAST;
> -                       goto found;
> +       if (size > PAGE_SIZE - ZHDR_SIZE_ALIGNED - CHUNK_SIZE)
> +               bud = HEADLESS;
> +       else {
> +               chunks = size_to_chunks(size);
> +               spin_lock(&pool->lock);
> +
> +               /* First, try to find an unbuddied zbud page. */
> +               zhdr = NULL;
> +               for_each_unbuddied_list(i, chunks) {
> +                       if (!list_empty(&pool->unbuddied[i])) {
> +                               zhdr = list_first_entry(&pool->unbuddied[i],
> +                                               struct zbud_header, buddy);
> +                               list_del(&zhdr->buddy);
> +                               page = virt_to_page(zhdr);
> +                               if (zhdr->first_chunks == 0)
> +                                       bud = FIRST;
> +                               else
> +                                       bud = LAST;
> +                               goto found;
> +                       }
>                 }
> +               bud = FIRST;
>         }
>
>         /* Couldn't find unbuddied zbud page, create new one */
> @@ -388,27 +420,31 @@ int zbud_alloc(struct zbud_pool *pool, size_t size, gfp_t gfp,
>         spin_lock(&pool->lock);
>         pool->pages_nr++;
>         zhdr = init_zbud_page(page);
> -       bud = FIRST;
>
>  found:
> -       if (bud == FIRST)
> -               zhdr->first_chunks = chunks;
> -       else
> -               zhdr->last_chunks = chunks;
> +       ppriv = (struct zbud_page_priv *)page->private;
> +       if (bud != HEADLESS) {

another personal opinion...it might look simpler if you just do:

if (bud == FULL) {
  set_bit(ZBUD_FULL_PAGE, &page->private);
  goto full;
}

> +               if (bud == FIRST)
> +                       zhdr->first_chunks = chunks;
> +               else
> +                       zhdr->last_chunks = chunks;
> +
> +               if (zhdr->first_chunks == 0 || zhdr->last_chunks == 0) {
> +                       /* Add to unbuddied list */
> +                       freechunks = num_free_chunks(zhdr);
> +                       list_add(&zhdr->buddy, &pool->unbuddied[freechunks]);
> +               } else {
> +                       /* Add to buddied list */
> +                       list_add(&zhdr->buddy, &pool->buddied);
> +               }
>
> -       if (zhdr->first_chunks == 0 || zhdr->last_chunks == 0) {
> -               /* Add to unbuddied list */
> -               freechunks = num_free_chunks(zhdr);
> -               list_add(&zhdr->buddy, &pool->unbuddied[freechunks]);
> -       } else {
> -               /* Add to buddied list */
> -               list_add(&zhdr->buddy, &pool->buddied);
> -       }
> +               /* Add/move zbud page to beginning of LRU */
> +               if (!list_empty(&page->lru))
> +                       list_del(&page->lru);
> +       } else
> +               ppriv->headless = true;
>

insert label here...

full:

> -       /* Add/move zbud page to beginning of LRU */
> -       if (!list_empty(&zhdr->lru))
> -               list_del(&zhdr->lru);

no matter the case, this is safe; leave it here for simplicity.  a
full page will have a empty list head.

> -       list_add(&zhdr->lru, &pool->lru);
> +       list_add(&page->lru, &pool->lru);
>
>         *handle = encode_handle(zhdr, bud);
>         spin_unlock(&pool->lock);
> @@ -430,28 +466,41 @@ void zbud_free(struct zbud_pool *pool, unsigned long handle)
>  {
>         struct zbud_header *zhdr;
>         int freechunks;
> +       struct page *page;
> +       enum buddy bud;
> +       struct zbud_page_priv *ppriv;
>
>         spin_lock(&pool->lock);
>         zhdr = handle_to_zbud_header(handle);
> +       page = virt_to_page(zhdr);
> +       ppriv = (struct zbud_page_priv *)page->private;
>
> -       /* If first buddy, handle will be page aligned */
> -       if ((handle - ZHDR_SIZE_ALIGNED) & ~PAGE_MASK)
> +       if (!(handle & ~PAGE_MASK)) /* HEADLESS page stored */
> +               bud = HEADLESS;
> +       else if ((handle - ZHDR_SIZE_ALIGNED) & ~PAGE_MASK) {
> +               bud = LAST;
>                 zhdr->last_chunks = 0;
> -       else
> +       } else {
> +               /* If first buddy, handle will be page aligned */
> +               bud = FIRST;
>                 zhdr->first_chunks = 0;
> +       }
>
> -       if (zhdr->under_reclaim) {
> +       if (ppriv->under_reclaim) {
>                 /* zbud page is under reclaim, reclaim will free */
>                 spin_unlock(&pool->lock);
>                 return;
>         }
>
> -       /* Remove from existing buddy list */
> -       list_del(&zhdr->buddy);
> +       if (bud != HEADLESS) {
> +               /* Remove from existing buddy list */
> +               list_del(&zhdr->buddy);
> +       }
>
> -       if (zhdr->first_chunks == 0 && zhdr->last_chunks == 0) {
> +       if (bud == HEADLESS ||
> +           (zhdr->first_chunks == 0 && zhdr->last_chunks == 0)) {
>                 /* zbud page is empty, free */
> -               list_del(&zhdr->lru);
> +               list_del(&page->lru);
>                 free_zbud_page(zhdr);
>                 pool->pages_nr--;
>         } else {
> @@ -505,6 +554,8 @@ int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries)
>  {
>         int i, ret, freechunks;
>         struct zbud_header *zhdr;
> +       struct page *page;
> +       struct zbud_page_priv *ppriv;
>         unsigned long first_handle = 0, last_handle = 0;
>
>         spin_lock(&pool->lock);
> @@ -514,21 +565,31 @@ int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries)
>                 return -EINVAL;
>         }
>         for (i = 0; i < retries; i++) {
> -               zhdr = list_tail_entry(&pool->lru, struct zbud_header, lru);
> -               list_del(&zhdr->lru);
> -               list_del(&zhdr->buddy);
> +               page = list_tail_entry(&pool->lru, struct page, lru);
> +               ppriv = (struct zbud_page_priv *)page->private;
> +               list_del(&page->lru);
> +
>                 /* Protect zbud page against free */
> -               zhdr->under_reclaim = true;
> -               /*
> -                * We need encode the handles before unlocking, since we can
> -                * race with free that will set (first|last)_chunks to 0
> -                */
> -               first_handle = 0;
> -               last_handle = 0;
> -               if (zhdr->first_chunks)
> -                       first_handle = encode_handle(zhdr, FIRST);
> -               if (zhdr->last_chunks)
> -                       last_handle = encode_handle(zhdr, LAST);
> +               ppriv->under_reclaim = true;
> +               zhdr = page_address(page);
> +               if (!ppriv->headless) {
> +                       list_del(&zhdr->buddy);
> +                       /*
> +                        * We need encode the handles before unlocking, since
> +                        * we can race with free that will set
> +                        * (first|last)_chunks to 0
> +                        */
> +                       first_handle = 0;
> +                       last_handle = 0;
> +                       if (zhdr->first_chunks)
> +                               first_handle = encode_handle(zhdr, FIRST);
> +                       if (zhdr->last_chunks)
> +                               last_handle = encode_handle(zhdr, LAST);
> +               } else {
> +                       first_handle = encode_handle(zhdr, HEADLESS);
> +                       last_handle = 0;
> +               }
> +
>                 spin_unlock(&pool->lock);
>
>                 /* Issue the eviction callback(s) */
> @@ -544,8 +605,9 @@ int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries)
>                 }
>  next:
>                 spin_lock(&pool->lock);
> -               zhdr->under_reclaim = false;
> -               if (zhdr->first_chunks == 0 && zhdr->last_chunks == 0) {
> +               ppriv->under_reclaim = false;
> +               if (ppriv->headless ||
> +                   (zhdr->first_chunks == 0 && zhdr->last_chunks == 0)) {

oops, this isn't right.  you're assuming ->headless means the eviction
succeeded.  However if pool->ops->evict() failed, that isn't true.

>                         /*
>                          * Both buddies are now free, free the zbud page and
>                          * return success.
> @@ -565,7 +627,7 @@ next:
>                 }
>
>                 /* add to beginning of LRU */
> -               list_add(&zhdr->lru, &pool->lru);
> +               list_add(&page->lru, &pool->lru);
>         }
>         spin_unlock(&pool->lock);
>         return -EAGAIN;
> --
> 2.4.2
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
