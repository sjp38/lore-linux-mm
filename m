Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id 9D0BD6B0069
	for <linux-mm@kvack.org>; Tue, 25 Nov 2014 10:40:37 -0500 (EST)
Received: by mail-ig0-f177.google.com with SMTP id z20so889513igj.10
        for <linux-mm@kvack.org>; Tue, 25 Nov 2014 07:40:37 -0800 (PST)
Received: from mail-ig0-x22f.google.com (mail-ig0-x22f.google.com. [2607:f8b0:4001:c05::22f])
        by mx.google.com with ESMTPS id l5si1530106icc.38.2014.11.25.07.40.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 25 Nov 2014 07:40:36 -0800 (PST)
Received: by mail-ig0-f175.google.com with SMTP id h15so5191065igd.14
        for <linux-mm@kvack.org>; Tue, 25 Nov 2014 07:40:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1416920444-4181-1-git-send-email-opensource.ganesh@gmail.com>
References: <1416920444-4181-1-git-send-email-opensource.ganesh@gmail.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Tue, 25 Nov 2014 10:40:14 -0500
Message-ID: <CALZtONBMKGDrs7NuMW1d7gMFeZ6GFAjCCzrGTFyYOEW9zzHk8Q@mail.gmail.com>
Subject: Re: [PATCH v3] mm/zsmalloc: avoid duplicate assignment of prev_class
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Tue, Nov 25, 2014 at 8:00 AM, Ganesh Mahendran
<opensource.ganesh@gmail.com> wrote:
> In zs_create_pool(), prev_class is assigned (ZS_SIZE_CLASSES - 1)
> times. And the prev_class only references to the previous size_class.
> So we do not need unnecessary assignement.
>
> This patch assigns *prev_class* when a new size_class structure
> is allocated and uses prev_class to check whether the first class
> has been allocated.
>
> Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Nitin Gupta <ngupta@vflare.org>
> Cc: Dan Streetman <ddstreet@ieee.org>

Reviewed-by: Dan Streetman <ddstreet@ieee.org>

>
> ---
> v1 -> v2:
>   - follow Dan Streetman's advise to use prev_class to
>     check whether the first class has been allocated
>   - follow Minchan Kim's advise to remove uninitialized_var()
>
> v2 -> v3:
>   - move *prev_class* definition out of the loop - Dan
> ---
>  mm/zsmalloc.c |    7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
>
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index 83ecdb6..de1320e 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -966,6 +966,7 @@ struct zs_pool *zs_create_pool(gfp_t flags)
>  {
>         int i, ovhd_size;
>         struct zs_pool *pool;
> +       struct size_class *prev_class = NULL;
>
>         ovhd_size = roundup(sizeof(*pool), PAGE_SIZE);
>         pool = kzalloc(ovhd_size, GFP_KERNEL);
> @@ -980,7 +981,6 @@ struct zs_pool *zs_create_pool(gfp_t flags)
>                 int size;
>                 int pages_per_zspage;
>                 struct size_class *class;
> -               struct size_class *prev_class;
>
>                 size = ZS_MIN_ALLOC_SIZE + i * ZS_SIZE_CLASS_DELTA;
>                 if (size > ZS_MAX_ALLOC_SIZE)
> @@ -996,8 +996,7 @@ struct zs_pool *zs_create_pool(gfp_t flags)
>                  * characteristics. So, we makes size_class point to
>                  * previous size_class if possible.
>                  */
> -               if (i < ZS_SIZE_CLASSES - 1) {
> -                       prev_class = pool->size_class[i + 1];
> +               if (prev_class) {
>                         if (can_merge(prev_class, size, pages_per_zspage)) {
>                                 pool->size_class[i] = prev_class;
>                                 continue;
> @@ -1013,6 +1012,8 @@ struct zs_pool *zs_create_pool(gfp_t flags)
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
