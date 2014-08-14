Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id A6AE26B0035
	for <linux-mm@kvack.org>; Wed, 13 Aug 2014 21:14:08 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id fa1so648955pad.13
        for <linux-mm@kvack.org>; Wed, 13 Aug 2014 18:14:08 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id kr6si2730686pab.60.2014.08.13.18.14.06
        for <linux-mm@kvack.org>;
        Wed, 13 Aug 2014 18:14:07 -0700 (PDT)
Date: Thu, 14 Aug 2014 10:14:16 +0900
From: Minchan Kim <minchan.kim@lge.com>
Subject: Re: [PATCH 1/2] zsmalloc: move pages_allocated to zs_pool
Message-ID: <20140814011416.GI9227@bbox>
References: <1407977877-18185-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1407977877-18185-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Jerome Marchand <jmarchan@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, juno.choi@lge.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Streetman <ddstreet@ieee.org>, seungho1.park@lge.com, Luigi Semenzato <semenzato@google.com>, ds2horner@gmail.com, Nitin Gupta <ngupta@vflare.org>

Just resent new one with correcting Seth's mail address and including the one
omitted by mistake in this patchset.

On Thu, Aug 14, 2014 at 09:57:56AM +0900, Minchan Kim wrote:
> Pages_allocated has counted in size_class structure and when user
> want to see total_size_bytes, it gathers all of value from each
> size_class to report the sum.
> 
> It's not bad if user don't see the value often but if user start
> to see the value frequently, it would be not a good deal for
> performance POV.
> 
> Even, this patch moves the variable from size_class to zs_pool
> so it reduces memory footprint (from [255 * 8byte] to
> [sizeof(atomic_t)]) but it introduce new atomic opearation
> but it's not a big deal because atomic operation is called on
> slow path of zsmalloc where it allocates/free zspage unit,
> not object.
> 
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  mm/zsmalloc.c | 21 +++++++--------------
>  1 file changed, 7 insertions(+), 14 deletions(-)
> 
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index 4e2fc83cb394..2f21ea8921dc 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -199,9 +199,6 @@ struct size_class {
>  
>  	spinlock_t lock;
>  
> -	/* stats */
> -	u64 pages_allocated;
> -
>  	struct page *fullness_list[_ZS_NR_FULLNESS_GROUPS];
>  };
>  
> @@ -220,6 +217,7 @@ struct zs_pool {
>  	struct size_class size_class[ZS_SIZE_CLASSES];
>  
>  	gfp_t flags;	/* allocation flags used when growing pool */
> +	atomic_t pages_allocated;
>  };
>  
>  /*
> @@ -1027,8 +1025,8 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size)
>  			return 0;
>  
>  		set_zspage_mapping(first_page, class->index, ZS_EMPTY);
> +		atomic_add(class->pages_per_zspage, &pool->pages_allocated);
>  		spin_lock(&class->lock);
> -		class->pages_allocated += class->pages_per_zspage;
>  	}
>  
>  	obj = (unsigned long)first_page->freelist;
> @@ -1081,14 +1079,12 @@ void zs_free(struct zs_pool *pool, unsigned long obj)
>  
>  	first_page->inuse--;
>  	fullness = fix_fullness_group(pool, first_page);
> -
> -	if (fullness == ZS_EMPTY)
> -		class->pages_allocated -= class->pages_per_zspage;
> -
>  	spin_unlock(&class->lock);
>  
> -	if (fullness == ZS_EMPTY)
> +	if (fullness == ZS_EMPTY) {
> +		atomic_sub(class->pages_per_zspage, &pool->pages_allocated);
>  		free_zspage(first_page);
> +	}
>  }
>  EXPORT_SYMBOL_GPL(zs_free);
>  
> @@ -1184,12 +1180,9 @@ EXPORT_SYMBOL_GPL(zs_unmap_object);
>  
>  u64 zs_get_total_size_bytes(struct zs_pool *pool)
>  {
> -	int i;
> -	u64 npages = 0;
> -
> -	for (i = 0; i < ZS_SIZE_CLASSES; i++)
> -		npages += pool->size_class[i].pages_allocated;
> +	u64 npages;
>  
> +	npages = atomic_read(&pool->pages_allocated);
>  	return npages << PAGE_SHIFT;
>  }
>  EXPORT_SYMBOL_GPL(zs_get_total_size_bytes);
> -- 
> 2.0.0

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
