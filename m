Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id E9F186B0037
	for <linux-mm@kvack.org>; Fri,  6 Sep 2013 02:31:49 -0400 (EDT)
Message-ID: <522976CB.8060306@oracle.com>
Date: Fri, 06 Sep 2013 14:31:39 +0800
From: Bob Liu <bob.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 2/4] mm/zswap: bugfix: memory leak when invalidate
 and reclaim occur concurrently
References: <000801ceaac0$8d1f6210$a75e2630$%yang@samsung.com>
In-Reply-To: <000801ceaac0$8d1f6210$a75e2630$%yang@samsung.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang@samsung.com>
Cc: sjenning@linux.vnet.ibm.com, minchan@kernel.org, weijie.yang.kh@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org


On 09/06/2013 01:16 PM, Weijie Yang wrote:
> Consider the following scenario:
> thread 0: reclaim entry x (get refcount, but not call zswap_get_swap_cache_page)
> thread 1: call zswap_frontswap_invalidate_page to invalidate entry x.
> 	finished, entry x and its zbud is not freed as its refcount != 0
> 	now, the swap_map[x] = 0
> thread 0: now call zswap_get_swap_cache_page
> 	swapcache_prepare return -ENOENT because entry x is not used any more
> 	zswap_get_swap_cache_page return ZSWAP_SWAPCACHE_NOMEM
> 	zswap_writeback_entry do nothing except put refcount
> Now, the memory of zswap_entry x and its zpage leak.
> 
> Modify:
> - check the refcount in fail path, free memory if it is not referenced.
> - use ZSWAP_SWAPCACHE_FAIL instead of ZSWAP_SWAPCACHE_NOMEM as the fail path
> can be not only caused by nomem but also by invalidate.
> 
> Signed-off-by: Weijie Yang <weijie.yang@samsung.com>

Reviewed-by: Bob Liu <bob.liu@oracle.com>

> ---
>  mm/zswap.c |   21 +++++++++++++--------
>  1 file changed, 13 insertions(+), 8 deletions(-)
> 
> diff --git a/mm/zswap.c b/mm/zswap.c
> index cbd9578..1be7b90 100644
> --- a/mm/zswap.c
> +++ b/mm/zswap.c
> @@ -387,7 +387,7 @@ static void zswap_free_entry(struct zswap_tree *tree, struct zswap_entry *entry)
>  enum zswap_get_swap_ret {
>  	ZSWAP_SWAPCACHE_NEW,
>  	ZSWAP_SWAPCACHE_EXIST,
> -	ZSWAP_SWAPCACHE_NOMEM
> +	ZSWAP_SWAPCACHE_FAIL,
>  };
>  
>  /*
> @@ -401,9 +401,9 @@ enum zswap_get_swap_ret {
>   * added to the swap cache, and returned in retpage.
>   *
>   * If success, the swap cache page is returned in retpage
> - * Returns 0 if page was already in the swap cache, page is not locked
> - * Returns 1 if the new page needs to be populated, page is locked
> - * Returns <0 on error
> + * Returns ZSWAP_SWAPCACHE_EXIST if page was already in the swap cache
> + * Returns ZSWAP_SWAPCACHE_NEW if the new page needs to be populated, page is locked
> + * Returns ZSWAP_SWAPCACHE_FAIL on error
>   */
>  static int zswap_get_swap_cache_page(swp_entry_t entry,
>  				struct page **retpage)
> @@ -475,7 +475,7 @@ static int zswap_get_swap_cache_page(swp_entry_t entry,
>  	if (new_page)
>  		page_cache_release(new_page);
>  	if (!found_page)
> -		return ZSWAP_SWAPCACHE_NOMEM;
> +		return ZSWAP_SWAPCACHE_FAIL;
>  	*retpage = found_page;
>  	return ZSWAP_SWAPCACHE_EXIST;
>  }
> @@ -529,11 +529,11 @@ static int zswap_writeback_entry(struct zbud_pool *pool, unsigned long handle)
>  
>  	/* try to allocate swap cache page */
>  	switch (zswap_get_swap_cache_page(swpentry, &page)) {
> -	case ZSWAP_SWAPCACHE_NOMEM: /* no memory */
> +	case ZSWAP_SWAPCACHE_FAIL: /* no memory or invalidate happened */
>  		ret = -ENOMEM;
>  		goto fail;
>  
> -	case ZSWAP_SWAPCACHE_EXIST: /* page is unlocked */
> +	case ZSWAP_SWAPCACHE_EXIST:
>  		/* page is already in the swap cache, ignore for now */
>  		page_cache_release(page);
>  		ret = -EEXIST;
> @@ -591,7 +591,12 @@ static int zswap_writeback_entry(struct zbud_pool *pool, unsigned long handle)
>  
>  fail:
>  	spin_lock(&tree->lock);
> -	zswap_entry_put(entry);
> +	refcount = zswap_entry_put(entry);
> +	if (refcount <= 0) {
> +		/* invalidate happened, consider writeback as success */
> +		zswap_free_entry(tree, entry);
> +		ret = 0;
> +	}
>  	spin_unlock(&tree->lock);
>  	return ret;
>  }
> 

-- 
Regards,
-Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
