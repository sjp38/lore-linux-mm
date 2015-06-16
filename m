Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 4B3E06B0038
	for <linux-mm@kvack.org>; Tue, 16 Jun 2015 09:37:18 -0400 (EDT)
Received: by pabqy3 with SMTP id qy3so13007109pab.3
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 06:37:18 -0700 (PDT)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id wn3si1478522pab.7.2015.06.16.06.37.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jun 2015 06:37:17 -0700 (PDT)
Received: by pabqy3 with SMTP id qy3so13006871pab.3
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 06:37:17 -0700 (PDT)
Date: Tue, 16 Jun 2015 22:37:08 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC][PATCHv2 3/8] zsmalloc: lower ZS_ALMOST_FULL waterline
Message-ID: <20150616133708.GB31387@blaptop>
References: <1433505838-23058-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1433505838-23058-4-git-send-email-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1433505838-23058-4-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On Fri, Jun 05, 2015 at 09:03:53PM +0900, Sergey Senozhatsky wrote:
> get_fullness_group() considers 3/4 full pages as almost empty.
> That, unfortunately, marks as ALMOST_EMPTY pages that we would
> probably like to keep in ALMOST_FULL lists.
> 
> ALMOST_EMPTY:
> [..]
>   inuse: 3 max_objects: 4
>   inuse: 5 max_objects: 7
>   inuse: 5 max_objects: 7
>   inuse: 2 max_objects: 3
> [..]
> 
> For "inuse: 5 max_objexts: 7" ALMOST_EMPTY page, for example,
> it'll take 2 obj_malloc to make the page FULL and 5 obj_free to
> make it EMPTY. Compaction selects ALMOST_EMPTY pages as source
> pages, which can result in extra object moves.
> 
> In other words, from compaction point of view, it makes more
> sense to fill this page, rather than drain it.
> 
> Decrease ALMOST_FULL waterline to 2/3 of max capacity; which is,
> of course, still imperfect, but can shorten compaction
> execution time.

However, at worst case, once compaction is done, it could remain
33% fragment space while it can remain 25% fragment space in current.
Maybe 25% wouldn't enough so we might need to scan ZS_ALMOST_FULL as
source in future. Anyway, compaction is really slow path now so
I prefer saving memory space by reduce internal fragmentation to
performance caused more copy of objects.

> 
> Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> ---
>  mm/zsmalloc.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index cd37bda..b94e281 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -198,7 +198,7 @@ static int zs_size_classes;
>   *
>   * (see: fix_fullness_group())
>   */
> -static const int fullness_threshold_frac = 4;
> +static const int fullness_threshold_frac = 3;
>  
>  struct size_class {
>  	/*
> @@ -633,7 +633,7 @@ static enum fullness_group get_fullness_group(struct page *page)
>  		fg = ZS_EMPTY;
>  	else if (inuse == max_objects)
>  		fg = ZS_FULL;
> -	else if (inuse <= 3 * max_objects / fullness_threshold_frac)
> +	else if (inuse <= 2 * max_objects / fullness_threshold_frac)
>  		fg = ZS_ALMOST_EMPTY;
>  	else
>  		fg = ZS_ALMOST_FULL;
> -- 
> 2.4.2.387.gf86f31a
> 

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
