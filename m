Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f170.google.com (mail-ie0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id 08C7E28029C
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 13:05:26 -0400 (EDT)
Received: by ietj16 with SMTP id j16so38219075iet.0
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 10:05:25 -0700 (PDT)
Received: from mail-ig0-x234.google.com (mail-ig0-x234.google.com. [2607:f8b0:4001:c05::234])
        by mx.google.com with ESMTPS id gc7si4736022icb.40.2015.07.15.10.05.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jul 2015 10:05:25 -0700 (PDT)
Received: by igbij6 with SMTP id ij6so76466377igb.1
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 10:05:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1435916413-6475-2-git-send-email-k.kozlowski@samsung.com>
References: <1435916413-6475-1-git-send-email-k.kozlowski@samsung.com> <1435916413-6475-2-git-send-email-k.kozlowski@samsung.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Wed, 15 Jul 2015 13:05:06 -0400
Message-ID: <CALZtONCeEjtmjNTspKmYy-bZEfTqOK_6BB+8Bxzx6Dn9qLO9kQ@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: zbud: Constify the zbud_ops
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Cc: Seth Jennings <sjennings@variantweb.net>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Fri, Jul 3, 2015 at 5:40 AM, Krzysztof Kozlowski
<k.kozlowski@samsung.com> wrote:
> The structure zbud_ops is not modified so make the pointer to it as
> pointer to const.
>
> Signed-off-by: Krzysztof Kozlowski <k.kozlowski@samsung.com>

Acked-by: Dan Streetman <ddstreet@ieee.org>

> ---
>  include/linux/zbud.h | 2 +-
>  mm/zbud.c            | 6 +++---
>  2 files changed, 4 insertions(+), 4 deletions(-)
>
> diff --git a/include/linux/zbud.h b/include/linux/zbud.h
> index f9d41a6e361f..e183a0a65ac1 100644
> --- a/include/linux/zbud.h
> +++ b/include/linux/zbud.h
> @@ -9,7 +9,7 @@ struct zbud_ops {
>         int (*evict)(struct zbud_pool *pool, unsigned long handle);
>  };
>
> -struct zbud_pool *zbud_create_pool(gfp_t gfp, struct zbud_ops *ops);
> +struct zbud_pool *zbud_create_pool(gfp_t gfp, const struct zbud_ops *ops);
>  void zbud_destroy_pool(struct zbud_pool *pool);
>  int zbud_alloc(struct zbud_pool *pool, size_t size, gfp_t gfp,
>         unsigned long *handle);
> diff --git a/mm/zbud.c b/mm/zbud.c
> index 6f8158d64864..fa48bcdff9d5 100644
> --- a/mm/zbud.c
> +++ b/mm/zbud.c
> @@ -96,7 +96,7 @@ struct zbud_pool {
>         struct list_head buddied;
>         struct list_head lru;
>         u64 pages_nr;
> -       struct zbud_ops *ops;
> +       const struct zbud_ops *ops;
>  #ifdef CONFIG_ZPOOL
>         struct zpool *zpool;
>         const struct zpool_ops *zpool_ops;
> @@ -133,7 +133,7 @@ static int zbud_zpool_evict(struct zbud_pool *pool, unsigned long handle)
>                 return -ENOENT;
>  }
>
> -static struct zbud_ops zbud_zpool_ops = {
> +static const struct zbud_ops zbud_zpool_ops = {
>         .evict =        zbud_zpool_evict
>  };
>
> @@ -302,7 +302,7 @@ static int num_free_chunks(struct zbud_header *zhdr)
>   * Return: pointer to the new zbud pool or NULL if the metadata allocation
>   * failed.
>   */
> -struct zbud_pool *zbud_create_pool(gfp_t gfp, struct zbud_ops *ops)
> +struct zbud_pool *zbud_create_pool(gfp_t gfp, const struct zbud_ops *ops)
>  {
>         struct zbud_pool *pool;
>         int i;
> --
> 1.9.1
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
