Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id D01166B0069
	for <linux-mm@kvack.org>; Thu, 20 Oct 2016 16:17:51 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id w69so68780019qka.6
        for <linux-mm@kvack.org>; Thu, 20 Oct 2016 13:17:51 -0700 (PDT)
Received: from mail-vk0-x241.google.com (mail-vk0-x241.google.com. [2607:f8b0:400c:c05::241])
        by mx.google.com with ESMTPS id b124si28156151qke.101.2016.10.20.13.17.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Oct 2016 13:17:50 -0700 (PDT)
Received: by mail-vk0-x241.google.com with SMTP id 2so3679729vkb.1
        for <linux-mm@kvack.org>; Thu, 20 Oct 2016 13:17:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20161019183506.d25ef094d89331b812eabc4f@gmail.com>
References: <20161019183340.9e3738b403ddda1a04c8f906@gmail.com> <20161019183506.d25ef094d89331b812eabc4f@gmail.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Thu, 20 Oct 2016 16:17:09 -0400
Message-ID: <CALZtONB0k=Q+uaS6oqso8=b2awFyFb0B8jEjE9F9cNuWXm+R7Q@mail.gmail.com>
Subject: Re: [PATCH 1/3] z3fold: make counters atomic
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Wed, Oct 19, 2016 at 12:35 PM, Vitaly Wool <vitalywool@gmail.com> wrote:
> This patch converts pages_nr per-pool counter to atomic64_t.
> It also introduces a new counter, unbuddied_nr, which is
> atomic64_t, too, to track the number of unbuddied (compactable)
> z3fold pages.
>
> Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
> ---
>  mm/z3fold.c | 33 +++++++++++++++++++++++++--------
>  1 file changed, 25 insertions(+), 8 deletions(-)
>
> diff --git a/mm/z3fold.c b/mm/z3fold.c
> index 8f9e89c..5ac325a 100644
> --- a/mm/z3fold.c
> +++ b/mm/z3fold.c
> @@ -69,6 +69,7 @@ struct z3fold_ops {
>   * @lru:       list tracking the z3fold pages in LRU order by most recently
>   *             added buddy.
>   * @pages_nr:  number of z3fold pages in the pool.
> + * @unbuddied_nr:      number of unbuddied z3fold pages in the pool.
>   * @ops:       pointer to a structure of user defined operations specified at
>   *             pool creation time.
>   *
> @@ -80,7 +81,8 @@ struct z3fold_pool {
>         struct list_head unbuddied[NCHUNKS];
>         struct list_head buddied;
>         struct list_head lru;
> -       u64 pages_nr;
> +       atomic64_t pages_nr;
> +       atomic64_t unbuddied_nr;
>         const struct z3fold_ops *ops;
>         struct zpool *zpool;
>         const struct zpool_ops *zpool_ops;
> @@ -234,7 +236,8 @@ static struct z3fold_pool *z3fold_create_pool(gfp_t gfp,
>                 INIT_LIST_HEAD(&pool->unbuddied[i]);
>         INIT_LIST_HEAD(&pool->buddied);
>         INIT_LIST_HEAD(&pool->lru);
> -       pool->pages_nr = 0;
> +       atomic64_set(&pool->pages_nr, 0);
> +       atomic64_set(&pool->unbuddied_nr, 0);
>         pool->ops = ops;
>         return pool;
>  }
> @@ -334,6 +337,7 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
>                                         continue;
>                                 }
>                                 list_del(&zhdr->buddy);
> +                               atomic64_dec(&pool->unbuddied_nr);
>                                 goto found;
>                         }
>                 }
> @@ -346,7 +350,7 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
>         if (!page)
>                 return -ENOMEM;
>         spin_lock(&pool->lock);
> -       pool->pages_nr++;
> +       atomic64_inc(&pool->pages_nr);
>         zhdr = init_z3fold_page(page);
>
>         if (bud == HEADLESS) {
> @@ -369,6 +373,7 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
>                 /* Add to unbuddied list */
>                 freechunks = num_free_chunks(zhdr);
>                 list_add(&zhdr->buddy, &pool->unbuddied[freechunks]);
> +               atomic64_inc(&pool->unbuddied_nr);
>         } else {
>                 /* Add to buddied list */
>                 list_add(&zhdr->buddy, &pool->buddied);
> @@ -412,6 +417,10 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
>                 /* HEADLESS page stored */
>                 bud = HEADLESS;
>         } else {
> +               bool is_unbuddied = zhdr->first_chunks == 0 ||
> +                               zhdr->middle_chunks == 0 ||
> +                               zhdr->last_chunks == 0;
> +
>                 bud = handle_to_buddy(handle);
>
>                 switch (bud) {
> @@ -431,6 +440,8 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
>                         spin_unlock(&pool->lock);
>                         return;
>                 }
> +               if (is_unbuddied)
> +                       atomic64_dec(&pool->unbuddied_nr);

this should be below, where it's removed from its buddy list.  If it's
under reclaim, it's already been removd from the buddy list and we
shouldn't dec the counter.

>         }
>
>         if (test_bit(UNDER_RECLAIM, &page->private)) {
> @@ -451,12 +462,13 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
>                 list_del(&page->lru);
>                 clear_bit(PAGE_HEADLESS, &page->private);
>                 free_z3fold_page(zhdr);
> -               pool->pages_nr--;
> +               atomic64_dec(&pool->pages_nr);
>         } else {
>                 z3fold_compact_page(zhdr);
>                 /* Add to the unbuddied list */
>                 freechunks = num_free_chunks(zhdr);
>                 list_add(&zhdr->buddy, &pool->unbuddied[freechunks]);
> +               atomic64_inc(&pool->unbuddied_nr);
>         }
>
>         spin_unlock(&pool->lock);
> @@ -520,6 +532,11 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
>                 zhdr = page_address(page);
>                 if (!test_bit(PAGE_HEADLESS, &page->private)) {
>                         list_del(&zhdr->buddy);
> +                       if (zhdr->first_chunks == 0 ||
> +                           zhdr->middle_chunks == 0 ||
> +                           zhdr->last_chunks == 0)
> +                               atomic64_dec(&pool->unbuddied_nr);
> +
>                         /*
>                          * We need encode the handles before unlocking, since
>                          * we can race with free that will set
> @@ -569,7 +586,7 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
>                          */
>                         clear_bit(PAGE_HEADLESS, &page->private);
>                         free_z3fold_page(zhdr);
> -                       pool->pages_nr--;
> +                       atomic64_dec(&pool->pages_nr);
>                         spin_unlock(&pool->lock);
>                         return 0;
>                 }  else if (!test_bit(PAGE_HEADLESS, &page->private)) {
> @@ -584,6 +601,7 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
>                                 freechunks = num_free_chunks(zhdr);
>                                 list_add(&zhdr->buddy,
>                                          &pool->unbuddied[freechunks]);
> +                               atomic64_inc(&pool->unbuddied_nr);
>                         }
>                 }
>
> @@ -672,12 +690,11 @@ static void z3fold_unmap(struct z3fold_pool *pool, unsigned long handle)
>   * z3fold_get_pool_size() - gets the z3fold pool size in pages
>   * @pool:      pool whose size is being queried
>   *
> - * Returns: size in pages of the given pool.  The pool lock need not be
> - * taken to access pages_nr.
> + * Returns: size in pages of the given pool.
>   */
>  static u64 z3fold_get_pool_size(struct z3fold_pool *pool)
>  {
> -       return pool->pages_nr;
> +       return atomic64_read(&pool->pages_nr);
>  }
>
>  /*****************
> --
> 2.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
