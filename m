Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2B7F86B0038
	for <linux-mm@kvack.org>; Wed,  1 Feb 2017 10:04:49 -0500 (EST)
Received: by mail-lf0-f69.google.com with SMTP id z134so159810516lff.5
        for <linux-mm@kvack.org>; Wed, 01 Feb 2017 07:04:49 -0800 (PST)
Received: from mail-lf0-x244.google.com (mail-lf0-x244.google.com. [2a00:1450:4010:c07::244])
        by mx.google.com with ESMTPS id v25si12453781lja.5.2017.02.01.07.04.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Feb 2017 07:04:47 -0800 (PST)
Received: by mail-lf0-x244.google.com with SMTP id x1so36764476lff.0
        for <linux-mm@kvack.org>; Wed, 01 Feb 2017 07:04:47 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170131213946.b828676ab17bbea42022c213@gmail.com>
References: <20170131213829.3d86c07ffd1358019354c937@gmail.com> <20170131213946.b828676ab17bbea42022c213@gmail.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Wed, 1 Feb 2017 10:04:06 -0500
Message-ID: <CALZtONBFoOPb4=T4N0Y2Ryipq_kzgqoFGiy3D=WVgD0aBpp-_w@mail.gmail.com>
Subject: Re: [PATCH/RESEND v3 1/5] z3fold: make pages_nr atomic
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Jan 31, 2017 at 3:39 PM, Vitaly Wool <vitalywool@gmail.com> wrote:
> This patch converts pages_nr per-pool counter to atomic64_t.
>
> Signed-off-by: Vitaly Wool <vitalywool@gmail.com>

Reviewed-by: Dan Streetman <ddstreet@ieee.org>

> ---
>  mm/z3fold.c | 20 +++++++++-----------
>  1 file changed, 9 insertions(+), 11 deletions(-)
>
> diff --git a/mm/z3fold.c b/mm/z3fold.c
> index 207e5dd..2273789 100644
> --- a/mm/z3fold.c
> +++ b/mm/z3fold.c
> @@ -80,7 +80,7 @@ struct z3fold_pool {
>         struct list_head unbuddied[NCHUNKS];
>         struct list_head buddied;
>         struct list_head lru;
> -       u64 pages_nr;
> +       atomic64_t pages_nr;
>         const struct z3fold_ops *ops;
>         struct zpool *zpool;
>         const struct zpool_ops *zpool_ops;
> @@ -238,7 +238,7 @@ static struct z3fold_pool *z3fold_create_pool(gfp_t gfp,
>                 INIT_LIST_HEAD(&pool->unbuddied[i]);
>         INIT_LIST_HEAD(&pool->buddied);
>         INIT_LIST_HEAD(&pool->lru);
> -       pool->pages_nr = 0;
> +       atomic64_set(&pool->pages_nr, 0);
>         pool->ops = ops;
>         return pool;
>  }
> @@ -350,7 +350,7 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
>         if (!page)
>                 return -ENOMEM;
>         spin_lock(&pool->lock);
> -       pool->pages_nr++;
> +       atomic64_inc(&pool->pages_nr);
>         zhdr = init_z3fold_page(page);
>
>         if (bud == HEADLESS) {
> @@ -443,10 +443,9 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
>                 return;
>         }
>
> -       if (bud != HEADLESS) {
> -               /* Remove from existing buddy list */
> +       /* Remove from existing buddy list */
> +       if (bud != HEADLESS)
>                 list_del(&zhdr->buddy);
> -       }
>
>         if (bud == HEADLESS ||
>             (zhdr->first_chunks == 0 && zhdr->middle_chunks == 0 &&
> @@ -455,7 +454,7 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
>                 list_del(&page->lru);
>                 clear_bit(PAGE_HEADLESS, &page->private);
>                 free_z3fold_page(zhdr);
> -               pool->pages_nr--;
> +               atomic64_dec(&pool->pages_nr);
>         } else {
>                 z3fold_compact_page(zhdr);
>                 /* Add to the unbuddied list */
> @@ -573,7 +572,7 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
>                          */
>                         clear_bit(PAGE_HEADLESS, &page->private);
>                         free_z3fold_page(zhdr);
> -                       pool->pages_nr--;
> +                       atomic64_dec(&pool->pages_nr);
>                         spin_unlock(&pool->lock);
>                         return 0;
>                 }  else if (!test_bit(PAGE_HEADLESS, &page->private)) {
> @@ -676,12 +675,11 @@ static void z3fold_unmap(struct z3fold_pool *pool, unsigned long handle)
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
