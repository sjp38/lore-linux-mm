Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 98AEE2802C9
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 20:20:16 -0400 (EDT)
Received: by pachj5 with SMTP id hj5so32455127pac.3
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 17:20:16 -0700 (PDT)
Received: from mail-pd0-x22d.google.com (mail-pd0-x22d.google.com. [2607:f8b0:400e:c02::22d])
        by mx.google.com with ESMTPS id ve7si10008752pbc.62.2015.07.15.17.20.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jul 2015 17:20:15 -0700 (PDT)
Received: by pdbqm3 with SMTP id qm3so33607179pdb.0
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 17:20:15 -0700 (PDT)
Date: Thu, 16 Jul 2015 09:20:48 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v2] zsmalloc: use class->pages_per_zspage
Message-ID: <20150716002048.GD3970@swordfish>
References: <1437005454-3338-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1437005454-3338-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On (07/16/15 09:10), Minchan Kim wrote:
> There is no need to recalcurate pages_per_zspage in runtime.
> Just use class->pages_per_zspage to avoid unnecessary runtime
> overhead.
> 
> * From v1
>   * fix up __zs_compact - Sergey
> 
> Signed-off-by: Minchan Kim <minchan@kernel.org>

thanks.

Acked-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

	-ss

> ---
>  mm/zsmalloc.c | 5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index 27b9661c8fa6..c9685bb2bb92 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -1711,7 +1711,7 @@ static unsigned long zs_can_compact(struct size_class *class)
>  	obj_wasted /= get_maxobj_per_zspage(class->size,
>  			class->pages_per_zspage);
>  
> -	return obj_wasted * get_pages_per_zspage(class->size);
> +	return obj_wasted * class->pages_per_zspage;
>  }
>  
>  static void __zs_compact(struct zs_pool *pool, struct size_class *class)
> @@ -1749,8 +1749,7 @@ static void __zs_compact(struct zs_pool *pool, struct size_class *class)
>  
>  		putback_zspage(pool, class, dst_page);
>  		if (putback_zspage(pool, class, src_page) == ZS_EMPTY)
> -			pool->stats.pages_compacted +=
> -				get_pages_per_zspage(class->size);
> +			pool->stats.pages_compacted += class->pages_per_zspage;
>  		spin_unlock(&class->lock);
>  		cond_resched();
>  		spin_lock(&class->lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
