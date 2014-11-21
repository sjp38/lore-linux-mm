Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f53.google.com (mail-la0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id 906CB6B006E
	for <linux-mm@kvack.org>; Thu, 20 Nov 2014 22:22:41 -0500 (EST)
Received: by mail-la0-f53.google.com with SMTP id gm9so578639lab.26
        for <linux-mm@kvack.org>; Thu, 20 Nov 2014 19:22:40 -0800 (PST)
Received: from mail-lb0-x22f.google.com (mail-lb0-x22f.google.com. [2a00:1450:4010:c04::22f])
        by mx.google.com with ESMTPS id p7si3644695lah.114.2014.11.20.19.22.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 20 Nov 2014 19:22:40 -0800 (PST)
Received: by mail-lb0-f175.google.com with SMTP id u10so453666lbd.20
        for <linux-mm@kvack.org>; Thu, 20 Nov 2014 19:22:40 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1416488913-9691-1-git-send-email-opensource.ganesh@gmail.com>
References: <1416488913-9691-1-git-send-email-opensource.ganesh@gmail.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Thu, 20 Nov 2014 22:22:19 -0500
Message-ID: <CALZtONAdpiP+DZfJBYG9EYN+8pTToMnAaUGemZ-r7x8YcQXbCQ@mail.gmail.com>
Subject: Re: [PATCH] mm/zsmalloc: avoid duplicate assignment of prev_class
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mahendran Ganesh <opensource.ganesh@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Thu, Nov 20, 2014 at 8:08 AM, Mahendran Ganesh
<opensource.ganesh@gmail.com> wrote:
> In zs_create_pool(), prev_class is assigned (ZS_SIZE_CLASSES - 1)
> times. And the prev_class only references to the previous alloc
> size_class. So we do not need unnecessary assignement.
>
> This patch modifies *prev_class* to *prev_alloc_class*. And the
> *prev_alloc_class* will only be assigned when a new size_class
> structure is allocated.
>
> Signed-off-by: Mahendran Ganesh <opensource.ganesh@gmail.com>
> ---
>  mm/zsmalloc.c |    9 +++++----
>  1 file changed, 5 insertions(+), 4 deletions(-)
>
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index b3b57ef..ac2b396 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -970,7 +970,7 @@ struct zs_pool *zs_create_pool(gfp_t flags)
>                 int size;
>                 int pages_per_zspage;
>                 struct size_class *class;
> -               struct size_class *prev_class;
> +               struct size_class *uninitialized_var(prev_alloc_class);

+               struct size_class *prev_class = NULL;

Use the fact it's unset below, so set it to NULL here

>
>                 size = ZS_MIN_ALLOC_SIZE + i * ZS_SIZE_CLASS_DELTA;
>                 if (size > ZS_MAX_ALLOC_SIZE)
> @@ -987,9 +987,8 @@ struct zs_pool *zs_create_pool(gfp_t flags)
>                  * previous size_class if possible.
>                  */
>                 if (i < ZS_SIZE_CLASSES - 1) {
> -                       prev_class = pool->size_class[i + 1];
> -                       if (can_merge(prev_class, size, pages_per_zspage)) {
> -                               pool->size_class[i] = prev_class;
> +                       if (can_merge(prev_alloc_class, size, pages_per_zspage)) {
> +                               pool->size_class[i] = prev_alloc_class;

simplify more, we can check if this is the first iteration by looking
at prev_class, e.g.:

                if (prev_class) {
                       if (can_merge(prev_class, size, pages_per_zspage)) {
                               pool->size_class[i] = prev_class;


>                                 continue;
>                         }
>                 }
> @@ -1003,6 +1002,8 @@ struct zs_pool *zs_create_pool(gfp_t flags)
>                 class->pages_per_zspage = pages_per_zspage;
>                 spin_lock_init(&class->lock);
>                 pool->size_class[i] = class;
> +
> +               prev_alloc_class = class;
>         }
>
>         pool->flags = flags;
> --
> 1.7.9.5
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
