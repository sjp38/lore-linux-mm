Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4C752828E1
	for <linux-mm@kvack.org>; Sun, 15 May 2016 23:15:37 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id zy2so272887515pac.1
        for <linux-mm@kvack.org>; Sun, 15 May 2016 20:15:37 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id h69si42463641pfj.143.2016.05.15.20.15.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 15 May 2016 20:15:36 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id 145so14500938pfz.1
        for <linux-mm@kvack.org>; Sun, 15 May 2016 20:15:36 -0700 (PDT)
Date: Mon, 16 May 2016 12:15:32 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v5 09/12] zsmalloc: separate free_zspage from
 putback_zspage
Message-ID: <20160516031532.GE504@swordfish>
References: <1462760433-32357-1-git-send-email-minchan@kernel.org>
 <1462760433-32357-10-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1462760433-32357-10-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (05/09/16 11:20), Minchan Kim wrote:
> Currently, putback_zspage does free zspage under class->lock
> if fullness become ZS_EMPTY but it makes trouble to implement
> locking scheme for new zspage migration.
> So, this patch is to separate free_zspage from putback_zspage
> and free zspage out of class->lock which is preparation for
> zspage migration.
> 
> Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>


Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

	-ss

> ---
>  mm/zsmalloc.c | 27 +++++++++++----------------
>  1 file changed, 11 insertions(+), 16 deletions(-)
> 
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index 162a598a417a..5ccd83732a14 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -1685,14 +1685,12 @@ static struct zspage *isolate_zspage(struct size_class *class, bool source)
>  
>  /*
>   * putback_zspage - add @zspage into right class's fullness list
> - * @pool: target pool
>   * @class: destination class
>   * @zspage: target page
>   *
>   * Return @zspage's fullness_group
>   */
> -static enum fullness_group putback_zspage(struct zs_pool *pool,
> -			struct size_class *class,
> +static enum fullness_group putback_zspage(struct size_class *class,
>  			struct zspage *zspage)
>  {
>  	enum fullness_group fullness;
> @@ -1701,15 +1699,6 @@ static enum fullness_group putback_zspage(struct zs_pool *pool,
>  	insert_zspage(class, zspage, fullness);
>  	set_zspage_mapping(zspage, class->index, fullness);
>  
> -	if (fullness == ZS_EMPTY) {
> -		zs_stat_dec(class, OBJ_ALLOCATED, get_maxobj_per_zspage(
> -			class->size, class->pages_per_zspage));
> -		atomic_long_sub(class->pages_per_zspage,
> -				&pool->pages_allocated);
> -
> -		free_zspage(pool, zspage);
> -	}
> -
>  	return fullness;
>  }
>  
> @@ -1755,23 +1744,29 @@ static void __zs_compact(struct zs_pool *pool, struct size_class *class)
>  			if (!migrate_zspage(pool, class, &cc))
>  				break;
>  
> -			putback_zspage(pool, class, dst_zspage);
> +			putback_zspage(class, dst_zspage);
>  		}
>  
>  		/* Stop if we couldn't find slot */
>  		if (dst_zspage == NULL)
>  			break;
>  
> -		putback_zspage(pool, class, dst_zspage);
> -		if (putback_zspage(pool, class, src_zspage) == ZS_EMPTY)
> +		putback_zspage(class, dst_zspage);
> +		if (putback_zspage(class, src_zspage) == ZS_EMPTY) {
> +			zs_stat_dec(class, OBJ_ALLOCATED, get_maxobj_per_zspage(
> +					class->size, class->pages_per_zspage));
> +			atomic_long_sub(class->pages_per_zspage,
> +					&pool->pages_allocated);
> +			free_zspage(pool, src_zspage);
>  			pool->stats.pages_compacted += class->pages_per_zspage;
> +		}
>  		spin_unlock(&class->lock);
>  		cond_resched();
>  		spin_lock(&class->lock);
>  	}
>  
>  	if (src_zspage)
> -		putback_zspage(pool, class, src_zspage);
> +		putback_zspage(class, src_zspage);
>  
>  	spin_unlock(&class->lock);
>  }
> -- 
> 1.9.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
