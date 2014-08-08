Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 749996B0036
	for <linux-mm@kvack.org>; Fri,  8 Aug 2014 13:12:18 -0400 (EDT)
Received: by mail-wg0-f47.google.com with SMTP id b13so5729794wgh.6
        for <linux-mm@kvack.org>; Fri, 08 Aug 2014 10:12:17 -0700 (PDT)
Received: from mail-we0-x22f.google.com (mail-we0-x22f.google.com [2a00:1450:400c:c03::22f])
        by mx.google.com with ESMTPS id h1si12630307wjw.67.2014.08.08.10.12.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 08 Aug 2014 10:12:16 -0700 (PDT)
Received: by mail-we0-f175.google.com with SMTP id t60so5966702wes.20
        for <linux-mm@kvack.org>; Fri, 08 Aug 2014 10:12:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140808075316.GA21919@www.outflux.net>
References: <20140808075316.GA21919@www.outflux.net>
From: Dan Streetman <ddstreet@ieee.org>
Date: Fri, 8 Aug 2014 13:11:55 -0400
Message-ID: <CALZtONBNEg7kzUtwKihQuAU48MNh5NjhZcWoOxe-1-vgWqSLiw@mail.gmail.com>
Subject: Re: [PATCH] mm/zpool: use prefixed module loading
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, Seth Jennings <sjennings@variantweb.net>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Carpenter <dan.carpenter@oracle.com>, Linux-MM <linux-mm@kvack.org>

On Fri, Aug 8, 2014 at 3:53 AM, Kees Cook <keescook@chromium.org> wrote:
> To avoid potential format string expansion via module parameters,
> do not use the zpool type directly in request_module() without a
> format string. Additionally, to avoid arbitrary modules being loaded
> via zpool API (e.g. via the zswap_zpool_type module parameter) add a
> "zpool-" prefix to the requested module, as well as module aliases for
> the existing zpool types (zbud and zsmalloc).
>
> Signed-off-by: Kees Cook <keescook@chromium.org>
> ---
>  mm/zbud.c     | 1 +
>  mm/zpool.c    | 2 +-
>  mm/zsmalloc.c | 1 +
>  3 files changed, 3 insertions(+), 1 deletion(-)
>
> diff --git a/mm/zbud.c b/mm/zbud.c
> index a05790b1915e..aa74f7addab1 100644
> --- a/mm/zbud.c
> +++ b/mm/zbud.c
> @@ -619,3 +619,4 @@ module_exit(exit_zbud);
>  MODULE_LICENSE("GPL");
>  MODULE_AUTHOR("Seth Jennings <sjenning@linux.vnet.ibm.com>");
>  MODULE_DESCRIPTION("Buddy Allocator for Compressed Pages");
> +MODULE_ALIAS("zpool-zbud");

If we keep this, I'd recommend putting this inside the #ifdef
CONFIG_ZPOOL section, to keep all the zpool stuff together in zbud and
zsmalloc.

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

I agree with a change of (type) to ("%s", type), but what's the need
to prefix "zpool-"?  Anyone who has access to modify the
zswap_zpool_type parameter is already root and can just as easily load
any module they want.  Additionally, the zswap_compressor parameter
also runs through request_module() (in crypto/api.c) and could be used
to load any kernel module.

I'd prefer to leave out the "zpool-" prefix unless there is a specific
reason to include it.

>                 driver = zpool_get_driver(type);
>         }
>
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index 4e2fc83cb394..36af729eb3f6 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -1199,3 +1199,4 @@ module_exit(zs_exit);
>
>  MODULE_LICENSE("Dual BSD/GPL");
>  MODULE_AUTHOR("Nitin Gupta <ngupta@vflare.org>");
> +MODULE_ALIAS("zpool-zsmalloc");
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
