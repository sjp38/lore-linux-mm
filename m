Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id AB7416B00B7
	for <linux-mm@kvack.org>; Mon, 24 Nov 2014 11:57:17 -0500 (EST)
Received: by mail-ig0-f176.google.com with SMTP id l13so3702767iga.3
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 08:57:17 -0800 (PST)
Received: from mail-ig0-x235.google.com (mail-ig0-x235.google.com. [2607:f8b0:4001:c05::235])
        by mx.google.com with ESMTPS id zc3si10154769icb.50.2014.11.24.08.57.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 24 Nov 2014 08:57:16 -0800 (PST)
Received: by mail-ig0-f181.google.com with SMTP id l13so3709811iga.8
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 08:57:16 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1416577403-7887-1-git-send-email-opensource.ganesh@gmail.com>
References: <1416577403-7887-1-git-send-email-opensource.ganesh@gmail.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Mon, 24 Nov 2014 11:56:55 -0500
Message-ID: <CALZtONCbto8t_RCpJrfH=ykP1t=AgxnP+4nPORdcf1wNb=6kCQ@mail.gmail.com>
Subject: Re: [PATCH v2] mm/zsmalloc: avoid duplicate assignment of prev_class
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mahendran Ganesh <opensource.ganesh@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Fri, Nov 21, 2014 at 8:43 AM, Mahendran Ganesh
<opensource.ganesh@gmail.com> wrote:
> In zs_create_pool(), prev_class is assigned (ZS_SIZE_CLASSES - 1)
> times. And the prev_class only references to the previous size_class.
> So we do not need unnecessary assignement.
>
> This patch assigns *prev_class* when a new size_class structure
> is allocated and uses prev_class to check whether the first class
> has been allocated.
>
> Signed-off-by: Mahendran Ganesh <opensource.ganesh@gmail.com>
>
> ---
> v1 -> v2:
>   - follow Dan Streetman's advise to use prev_class to
>     check whether the first class has been allocated
>   - follow Minchan Kim's advise to remove uninitialized_var()
> ---
>  mm/zsmalloc.c |    7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
>
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index b3b57ef..810eda1 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -970,7 +970,7 @@ struct zs_pool *zs_create_pool(gfp_t flags)
>                 int size;
>                 int pages_per_zspage;
>                 struct size_class *class;
> -               struct size_class *prev_class;
> +               struct size_class *prev_class = NULL;

Maybe I'm looking at the wrong source tree, but I don't think this
will work?  You have to move
prev_class outside the for loop, or it'll be NULL each iteration.

>
>                 size = ZS_MIN_ALLOC_SIZE + i * ZS_SIZE_CLASS_DELTA;
>                 if (size > ZS_MAX_ALLOC_SIZE)
> @@ -986,8 +986,7 @@ struct zs_pool *zs_create_pool(gfp_t flags)
>                  * characteristics. So, we makes size_class point to
>                  * previous size_class if possible.
>                  */
> -               if (i < ZS_SIZE_CLASSES - 1) {
> -                       prev_class = pool->size_class[i + 1];
> +               if (prev_class) {
>                         if (can_merge(prev_class, size, pages_per_zspage)) {
>                                 pool->size_class[i] = prev_class;
>                                 continue;
> @@ -1003,6 +1002,8 @@ struct zs_pool *zs_create_pool(gfp_t flags)
>                 class->pages_per_zspage = pages_per_zspage;
>                 spin_lock_init(&class->lock);
>                 pool->size_class[i] = class;
> +
> +               prev_class = class;
>         }
>
>         pool->flags = flags;
> --
> 1.7.9.5
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
