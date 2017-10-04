Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7FFF56B0033
	for <linux-mm@kvack.org>; Wed,  4 Oct 2017 12:16:16 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id g62so4998227pfk.6
        for <linux-mm@kvack.org>; Wed, 04 Oct 2017 09:16:16 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b46sor3440443otd.125.2017.10.04.09.16.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 04 Oct 2017 09:16:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171004125447.15195-1-boris.brezillon@free-electrons.com>
References: <20171004125447.15195-1-boris.brezillon@free-electrons.com>
From: Jaewon Kim <jaewon31.kim@gmail.com>
Date: Thu, 5 Oct 2017 01:16:14 +0900
Message-ID: <CAJrd-Ut0jjDrf-+04CKEVx9+8St6fGA4BEtm5=Wdt43ygXyx4A@mail.gmail.com>
Subject: Re: [PATCH] cma: Take __GFP_NOWARN into account in cma_alloc()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boris Brezillon <boris.brezillon@free-electrons.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Laura Abbott <labbott@redhat.com>, Jaewon Kim <jaewon31.kim@samsung.com>, David Airlie <airlied@linux.ie>, Daniel Vetter <daniel@ffwll.ch>, dri-devel@lists.freedesktop.org, Eric Anholt <eric@anholt.net>

Hello

2017-10-04 21:54 GMT+09:00 Boris Brezillon <boris.brezillon@free-electrons.com>:
> cma_alloc() unconditionally prints an INFO message when the CMA
> allocation fails. Make this message conditional on the non-presence of
> __GFP_NOWARN in gfp_mask.
>
> Signed-off-by: Boris Brezillon <boris.brezillon@free-electrons.com>
> ---
> Hello,
>
> This patch aims at removing INFO messages that are displayed when the
> VC4 driver tries to allocate buffer objects. From the driver perspective
> an allocation failure is acceptable, and the driver can possibly do
> something to make following allocation succeed (like flushing the VC4
> internal cache).
When I made the patch, there was no GFP.
In my opinion, it is a good idea removing log in case of __GFP_NOWARN.
>
> Also, I don't understand why this message is only an INFO message, and
> not a WARN (pr_warn()). Please let me know if you have good reasons to
> keep it as an unconditional pr_info().
Thank to Michal Hocko, I changed to pr_info rather than just printk in
my first patch code.
https://marc.info/?l=linux-mm&m=148300462103801&w=2
I thought it is just info. It can be pr_warn if need.

Thank you
Jaewon Kim
>
> Thanks,
>
> Boris
> ---
>  mm/cma.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/cma.c b/mm/cma.c
> index c0da318c020e..022e52bd8370 100644
> --- a/mm/cma.c
> +++ b/mm/cma.c
> @@ -460,7 +460,7 @@ struct page *cma_alloc(struct cma *cma, size_t count, unsigned int align,
>
>         trace_cma_alloc(pfn, page, count, align);
>
> -       if (ret) {
> +       if (ret && !(gfp_mask & __GFP_NOWARN)) {
>                 pr_info("%s: alloc failed, req-size: %zu pages, ret: %d\n",
>                         __func__, count, ret);
>                 cma_debug_show_areas(cma);
> --
> 2.11.0
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
