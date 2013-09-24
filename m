Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f172.google.com (mail-ie0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id 03B856B0031
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 21:02:44 -0400 (EDT)
Received: by mail-ie0-f172.google.com with SMTP id x13so7853699ief.17
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 18:02:44 -0700 (PDT)
Date: Tue, 24 Sep 2013 10:03:08 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v3 2/3] mm/zswap: bugfix: memory leak when invalidate and
 reclaim occur concurrently
Message-ID: <20130924010308.GG17725@bbox>
References: <000201ceb836$4c549740$e4fdc5c0$%yang@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <000201ceb836$4c549740$e4fdc5c0$%yang@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang@samsung.com>
Cc: akpm@linux-foundation.org, sjenning@linux.vnet.ibm.com, bob.liu@oracle.com, weijie.yang.kh@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org, d.j.shin@samsung.com, heesub.shin@samsung.com, kyungmin.park@samsung.com, hau.chen@samsung.com, bifeng.tong@samsung.com, rui.xie@samsung.com

On Mon, Sep 23, 2013 at 04:21:49PM +0800, Weijie Yang wrote:
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
>  - check the refcount in fail path, free memory if it is not referenced.

Hmm, I don't like this because zswap refcount routine is already mess for me.
I'm not sure why it was designed from the beginning. I hope we should fix it first.

1. zswap_rb_serach could include zswap_entry_get semantic if it founds a entry from
   the tree. Of course, we should ranme it as find_get_zswap_entry like find_get_page.
2. zswap_entry_put could hide resource free function like zswap_free_entry so that
   all of caller can use it easily following pattern.
   
  find_get_zswap_entry
  ...
  ...
  zswap_entry_put

Of course, zswap_entry_put have to check the entry is in the tree or not
so if someone already removes it from the tree, it should avoid double remove.

One of the concern I can think is that approach extends critical section
but I think it would be no problem because more bottleneck would be [de]compress
functions. If it were really problem, we can mitigate a problem with moving
unnecessary functions out of zswap_free_entry because it seem to be rather
over-enginnering.

>  - use ZSWAP_SWAPCACHE_FAIL instead of ZSWAP_SWAPCACHE_NOMEM as the fail path
> can be not only caused by nomem but also by invalidate.
> 
> Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
> Reviewed-by: Bob Liu <bob.liu@oracle.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: stable@vger.kernel.org
> Acked-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
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
> -- 
> 1.7.10.4
> 
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
