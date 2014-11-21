Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id CED3A6B006E
	for <linux-mm@kvack.org>; Thu, 20 Nov 2014 22:54:38 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id kx10so3969541pab.30
        for <linux-mm@kvack.org>; Thu, 20 Nov 2014 19:54:38 -0800 (PST)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id ic2si2869064pad.205.2014.11.20.19.54.36
        for <linux-mm@kvack.org>;
        Thu, 20 Nov 2014 19:54:37 -0800 (PST)
Date: Fri, 21 Nov 2014 12:54:42 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC PATCH] mm/zsmalloc: remove unnecessary check
Message-ID: <20141121035442.GB10123@bbox>
References: <1416489716-9967-1-git-send-email-opensource.ganesh@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1416489716-9967-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mahendran Ganesh <opensource.ganesh@gmail.com>
Cc: ngupta@vflare.org, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Nov 20, 2014 at 09:21:56PM +0800, Mahendran Ganesh wrote:
> ZS_SIZE_CLASSES is calc by:
>   ((ZS_MAX_ALLOC_SIZE - ZS_MIN_ALLOC_SIZE) / ZS_SIZE_CLASS_DELTA + 1)
> 
> So when i is in [0, ZS_SIZE_CLASSES - 1), the size:
>   size = ZS_MIN_ALLOC_SIZE + i * ZS_SIZE_CLASS_DELTA
> will not be greater than ZS_MAX_ALLOC_SIZE
> 
> This patch removes the unnecessary check.

It depends on ZS_MIN_ALLOC_SIZE.
For example, we would change min to 8 but MAX is still 4096.
ZS_SIZE_CLASSES is (4096 - 8) / 16 + 1 = 256 so 8 + 255 * 16 = 4088,
which exceeds the max.

> 
> Signed-off-by: Mahendran Ganesh <opensource.ganesh@gmail.com>
> ---
>  mm/zsmalloc.c |    2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index b3b57ef..f2279e2 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -973,8 +973,6 @@ struct zs_pool *zs_create_pool(gfp_t flags)
>  		struct size_class *prev_class;
>  
>  		size = ZS_MIN_ALLOC_SIZE + i * ZS_SIZE_CLASS_DELTA;
> -		if (size > ZS_MAX_ALLOC_SIZE)
> -			size = ZS_MAX_ALLOC_SIZE;
>  		pages_per_zspage = get_pages_per_zspage(size);
>  
>  		/*
> -- 
> 1.7.9.5
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
