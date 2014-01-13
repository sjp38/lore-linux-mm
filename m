Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 3BD1C6B0036
	for <linux-mm@kvack.org>; Mon, 13 Jan 2014 18:34:26 -0500 (EST)
Received: by mail-pd0-f170.google.com with SMTP id z10so2707726pdj.1
        for <linux-mm@kvack.org>; Mon, 13 Jan 2014 15:34:25 -0800 (PST)
Received: from LGEAMRELO02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id kn7si17057058pbc.6.2014.01.13.15.34.23
        for <linux-mm@kvack.org>;
        Mon, 13 Jan 2014 15:34:24 -0800 (PST)
Date: Tue, 14 Jan 2014 08:35:05 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm/zswap: Check all pool pages instead of one pool pages
Message-ID: <20140113233505.GS1992@bbox>
References: <000101cf0ea0$f4e7c560$deb75020$@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <000101cf0ea0$f4e7c560$deb75020$@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cai Liu <cai.liu@samsung.com>
Cc: sjenning@linux.vnet.ibm.com, akpm@linux-foundation.org, bob.liu@oracle.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, liucai.lfn@gmail.com

Hello,

On Sat, Jan 11, 2014 at 03:43:07PM +0800, Cai Liu wrote:
> zswap can support multiple swapfiles. So we need to check
> all zbud pool pages in zswap.

True but this patch is rather costly that we should iterate
zswap_tree[MAX_SWAPFILES] to check it. SIGH.

How about defining zswap_tress as linked list instead of static
array? Then, we could reduce unnecessary iteration too much.

Other question:
Why do we need to update zswap_pool_pages too frequently?
As I read the code, I think it's okay to update it only when user
want to see it by debugfs and zswap_is_full is called.
So could we optimize it out?

> 
> Signed-off-by: Cai Liu <cai.liu@samsung.com>
> ---
>  mm/zswap.c |   18 +++++++++++++++---
>  1 file changed, 15 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/zswap.c b/mm/zswap.c
> index d93afa6..2438344 100644
> --- a/mm/zswap.c
> +++ b/mm/zswap.c
> @@ -291,7 +291,6 @@ static void zswap_free_entry(struct zswap_tree *tree,
>  	zbud_free(tree->pool, entry->handle);
>  	zswap_entry_cache_free(entry);
>  	atomic_dec(&zswap_stored_pages);
> -	zswap_pool_pages = zbud_get_pool_size(tree->pool);
>  }
>  
>  /* caller must hold the tree lock */
> @@ -405,10 +404,24 @@ cleanup:
>  /*********************************
>  * helpers
>  **********************************/
> +static u64 get_zswap_pool_pages(void)
> +{
> +	int i;
> +	u64 pool_pages = 0;
> +
> +	for (i = 0; i < MAX_SWAPFILES; i++) {
> +		if (zswap_trees[i])
> +			pool_pages += zbud_get_pool_size(zswap_trees[i]->pool);
> +	}
> +	zswap_pool_pages = pool_pages;
> +
> +	return pool_pages;
> +}
> +
>  static bool zswap_is_full(void)
>  {
>  	return (totalram_pages * zswap_max_pool_percent / 100 <
> -		zswap_pool_pages);
> +		get_zswap_pool_pages());
>  }
>  
>  /*********************************
> @@ -716,7 +729,6 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
>  
>  	/* update stats */
>  	atomic_inc(&zswap_stored_pages);
> -	zswap_pool_pages = zbud_get_pool_size(tree->pool);
>  
>  	return 0;
>  
> -- 
> 1.7.10.4
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
