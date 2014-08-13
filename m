Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 636586B0038
	for <linux-mm@kvack.org>; Wed, 13 Aug 2014 10:16:17 -0400 (EDT)
Received: by mail-wg0-f41.google.com with SMTP id z12so11310127wgg.0
        for <linux-mm@kvack.org>; Wed, 13 Aug 2014 07:16:16 -0700 (PDT)
Received: from mail-we0-x22d.google.com (mail-we0-x22d.google.com [2a00:1450:400c:c03::22d])
        by mx.google.com with ESMTPS id qh12si26219130wic.54.2014.08.13.07.16.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 13 Aug 2014 07:16:16 -0700 (PDT)
Received: by mail-we0-f173.google.com with SMTP id q58so11491042wes.18
        for <linux-mm@kvack.org>; Wed, 13 Aug 2014 07:16:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140812190629.GA7179@www.outflux.net>
References: <20140812190629.GA7179@www.outflux.net>
From: Dan Streetman <ddstreet@ieee.org>
Date: Wed, 13 Aug 2014 10:15:55 -0400
Message-ID: <CALZtONC498exv09fcrO12MOn3wtpUavDRrb4RtWkO+FtKaUzbQ@mail.gmail.com>
Subject: Re: [PATCH v2] mm/zpool: use prefixed module loading
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, Seth Jennings <sjennings@variantweb.net>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>

On Tue, Aug 12, 2014 at 3:06 PM, Kees Cook <keescook@chromium.org> wrote:
> To avoid potential format string expansion via module parameters,
> do not use the zpool type directly in request_module() without a
> format string. Additionally, to avoid arbitrary modules being loaded
> via zpool API (e.g. via the zswap_zpool_type module parameter) add a
> "zpool-" prefix to the requested module, as well as module aliases for
> the existing zpool types (zbud and zsmalloc).

Looks good and tested ok.  Thanks!

Acked-by: Dan Streetman <ddstreet@ieee.org>

>
> Signed-off-by: Kees Cook <keescook@chromium.org>
> ---
> v2:
> - moved module aliases into ifdefs (ddstreet)
> ---
>  mm/zbud.c     | 1 +
>  mm/zpool.c    | 2 +-
>  mm/zsmalloc.c | 1 +
>  3 files changed, 3 insertions(+), 1 deletion(-)
>
> diff --git a/mm/zbud.c b/mm/zbud.c
> index a05790b1915e..f26e7fcc7fa2 100644
> --- a/mm/zbud.c
> +++ b/mm/zbud.c
> @@ -195,6 +195,7 @@ static struct zpool_driver zbud_zpool_driver = {
>         .total_size =   zbud_zpool_total_size,
>  };
>
> +MODULE_ALIAS("zpool-zbud");
>  #endif /* CONFIG_ZPOOL */
>
>  /*****************
> diff --git a/mm/zpool.c b/mm/zpool.c
> index e40612a1df00..739cdf0d183a 100644
> --- a/mm/zpool.c
> +++ b/mm/zpool.c
> @@ -150,7 +150,7 @@ struct zpool *zpool_create_pool(char *type, gfp_t gfp, struct zpool_ops *ops)
>         driver = zpool_get_driver(type);
>
>         if (!driver) {
> -               request_module(type);
> +               request_module("zpool-%s", type);
>                 driver = zpool_get_driver(type);
>         }
>
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index 4e2fc83cb394..94f38fac5e81 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -315,6 +315,7 @@ static struct zpool_driver zs_zpool_driver = {
>         .total_size =   zs_zpool_total_size,
>  };
>
> +MODULE_ALIAS("zpool-zsmalloc");
>  #endif /* CONFIG_ZPOOL */
>
>  /* per-cpu VM mapping areas for zspage accesses that cross page boundaries */
> --
> 1.9.1
>
>
> --
> Kees Cook
> Chrome OS Security
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
