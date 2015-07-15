Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id 3CAE128029C
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 13:05:03 -0400 (EDT)
Received: by igbpg9 with SMTP id pg9so41220776igb.0
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 10:05:03 -0700 (PDT)
Received: from mail-ig0-x236.google.com (mail-ig0-x236.google.com. [2607:f8b0:4001:c05::236])
        by mx.google.com with ESMTPS id s73si4151017ioi.137.2015.07.15.10.05.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jul 2015 10:05:02 -0700 (PDT)
Received: by igcqs7 with SMTP id qs7so111976555igc.0
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 10:05:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1435916413-6475-1-git-send-email-k.kozlowski@samsung.com>
References: <1435916413-6475-1-git-send-email-k.kozlowski@samsung.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Wed, 15 Jul 2015 13:04:42 -0400
Message-ID: <CALZtONCW=LE0v66o71KuZpFkaRMx+EcT1tpQq=MFsDcerP6SWg@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm: zpool: Constify the zpool_ops
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Cc: Seth Jennings <sjennings@variantweb.net>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Fri, Jul 3, 2015 at 5:40 AM, Krzysztof Kozlowski
<k.kozlowski@samsung.com> wrote:
> The structure zpool_ops is not modified so make the pointer to it as
> pointer to const.
>
> Signed-off-by: Krzysztof Kozlowski <k.kozlowski@samsung.com>

Acked-by: Dan Streetman <ddstreet@ieee.org>

> ---
>  include/linux/zpool.h | 4 ++--
>  mm/zbud.c             | 4 ++--
>  mm/zpool.c            | 4 ++--
>  mm/zsmalloc.c         | 3 ++-
>  mm/zswap.c            | 2 +-
>  5 files changed, 9 insertions(+), 8 deletions(-)
>
> diff --git a/include/linux/zpool.h b/include/linux/zpool.h
> index d30eff3d84d5..c924a28d9805 100644
> --- a/include/linux/zpool.h
> +++ b/include/linux/zpool.h
> @@ -37,7 +37,7 @@ enum zpool_mapmode {
>  };
>
>  struct zpool *zpool_create_pool(char *type, char *name,
> -                       gfp_t gfp, struct zpool_ops *ops);
> +                       gfp_t gfp, const struct zpool_ops *ops);
>
>  char *zpool_get_type(struct zpool *pool);
>
> @@ -81,7 +81,7 @@ struct zpool_driver {
>         atomic_t refcount;
>         struct list_head list;
>
> -       void *(*create)(char *name, gfp_t gfp, struct zpool_ops *ops,
> +       void *(*create)(char *name, gfp_t gfp, const struct zpool_ops *ops,
>                         struct zpool *zpool);
>         void (*destroy)(void *pool);
>
> diff --git a/mm/zbud.c b/mm/zbud.c
> index f3bf6f7627d8..6f8158d64864 100644
> --- a/mm/zbud.c
> +++ b/mm/zbud.c
> @@ -99,7 +99,7 @@ struct zbud_pool {
>         struct zbud_ops *ops;
>  #ifdef CONFIG_ZPOOL
>         struct zpool *zpool;
> -       struct zpool_ops *zpool_ops;
> +       const struct zpool_ops *zpool_ops;
>  #endif
>  };
>
> @@ -138,7 +138,7 @@ static struct zbud_ops zbud_zpool_ops = {
>  };
>
>  static void *zbud_zpool_create(char *name, gfp_t gfp,
> -                              struct zpool_ops *zpool_ops,
> +                              const struct zpool_ops *zpool_ops,
>                                struct zpool *zpool)
>  {
>         struct zbud_pool *pool;
> diff --git a/mm/zpool.c b/mm/zpool.c
> index 722a4f60e90b..951db32b833f 100644
> --- a/mm/zpool.c
> +++ b/mm/zpool.c
> @@ -22,7 +22,7 @@ struct zpool {
>
>         struct zpool_driver *driver;
>         void *pool;
> -       struct zpool_ops *ops;
> +       const struct zpool_ops *ops;
>
>         struct list_head list;
>  };
> @@ -115,7 +115,7 @@ static void zpool_put_driver(struct zpool_driver *driver)
>   * Returns: New zpool on success, NULL on failure.
>   */
>  struct zpool *zpool_create_pool(char *type, char *name, gfp_t gfp,
> -               struct zpool_ops *ops)
> +               const struct zpool_ops *ops)
>  {
>         struct zpool_driver *driver;
>         struct zpool *zpool;
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index 0a7f81aa2249..6e139d381d80 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -309,7 +309,8 @@ static void record_obj(unsigned long handle, unsigned long obj)
>
>  #ifdef CONFIG_ZPOOL
>
> -static void *zs_zpool_create(char *name, gfp_t gfp, struct zpool_ops *zpool_ops,
> +static void *zs_zpool_create(char *name, gfp_t gfp,
> +                            const struct zpool_ops *zpool_ops,
>                              struct zpool *zpool)
>  {
>         return zs_create_pool(name, gfp);
> diff --git a/mm/zswap.c b/mm/zswap.c
> index 2d5727baed59..017a3f50725d 100644
> --- a/mm/zswap.c
> +++ b/mm/zswap.c
> @@ -816,7 +816,7 @@ static void zswap_frontswap_invalidate_area(unsigned type)
>         zswap_trees[type] = NULL;
>  }
>
> -static struct zpool_ops zswap_zpool_ops = {
> +static const struct zpool_ops zswap_zpool_ops = {
>         .evict = zswap_writeback_entry
>  };
>
> --
> 1.9.1
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
