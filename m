Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id B08596B0031
	for <linux-mm@kvack.org>; Sun,  8 Sep 2013 05:05:16 -0400 (EDT)
Message-ID: <522C3DB8.3060002@oracle.com>
Date: Sun, 08 Sep 2013 17:04:56 +0800
From: Bob Liu <bob.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 1/4] zbud: use page ref counter for zbud pages
References: <1377852176-30970-1-git-send-email-k.kozlowski@samsung.com> <1377852176-30970-2-git-send-email-k.kozlowski@samsung.com>
In-Reply-To: <1377852176-30970-2-git-send-email-k.kozlowski@samsung.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Dave Hansen <dave.hansen@intel.com>, Minchan Kim <minchan@kernel.org>, Tomasz Stanislawski <t.stanislaws@samsung.com>

Hi Krzysztof,

On 08/30/2013 04:42 PM, Krzysztof Kozlowski wrote:
> Use page reference counter for zbud pages. The ref counter replaces
> zbud_header.under_reclaim flag and ensures that zbud page won't be freed
> when zbud_free() is called during reclaim. It allows implementation of
> additional reclaim paths.
> 
> The page count is incremented when:
>  - a handle is created and passed to zswap (in zbud_alloc()),
>  - user-supplied eviction callback is called (in zbud_reclaim_page()).
> 
> Signed-off-by: Krzysztof Kozlowski <k.kozlowski@samsung.com>
> Signed-off-by: Tomasz Stanislawski <t.stanislaws@samsung.com>
> Reviewed-by: Bob Liu <bob.liu@oracle.com>

AFAIR, the previous version you sent out has a function  called
rebalance_lists() which I think is a good clean up.
But I didn't see that function any more in this version.

Thanks,
-Bob


> ---
>  mm/zbud.c |   97 +++++++++++++++++++++++++++++++++----------------------------
>  1 file changed, 52 insertions(+), 45 deletions(-)
> 
> diff --git a/mm/zbud.c b/mm/zbud.c
> index ad1e781..aa9a15c 100644
> --- a/mm/zbud.c
> +++ b/mm/zbud.c
> @@ -109,7 +109,6 @@ struct zbud_header {
>  	struct list_head lru;
>  	unsigned int first_chunks;
>  	unsigned int last_chunks;
> -	bool under_reclaim;
>  };
>  
>  /*****************
> @@ -138,16 +137,9 @@ static struct zbud_header *init_zbud_page(struct page *page)
>  	zhdr->last_chunks = 0;
>  	INIT_LIST_HEAD(&zhdr->buddy);
>  	INIT_LIST_HEAD(&zhdr->lru);
> -	zhdr->under_reclaim = 0;
>  	return zhdr;
>  }
>  
> -/* Resets the struct page fields and frees the page */
> -static void free_zbud_page(struct zbud_header *zhdr)
> -{
> -	__free_page(virt_to_page(zhdr));
> -}
> -
>  /*
>   * Encodes the handle of a particular buddy within a zbud page
>   * Pool lock should be held as this function accesses first|last_chunks
> @@ -188,6 +180,31 @@ static int num_free_chunks(struct zbud_header *zhdr)
>  	return NCHUNKS - zhdr->first_chunks - zhdr->last_chunks - 1;
>  }
>  
> +/*
> + * Increases ref count for zbud page.
> + */
> +static void get_zbud_page(struct zbud_header *zhdr)
> +{
> +	get_page(virt_to_page(zhdr));
> +}
> +
> +/*
> + * Decreases ref count for zbud page and frees the page if it reaches 0
> + * (no external references, e.g. handles).
> + *
> + * Returns 1 if page was freed and 0 otherwise.
> + */
> +static int put_zbud_page(struct zbud_header *zhdr)
> +{
> +	struct page *page = virt_to_page(zhdr);
> +	if (put_page_testzero(page)) {
> +		free_hot_cold_page(page, 0);
> +		return 1;
> +	}
> +	return 0;
> +}
> +
> +
>  /*****************
>   * API Functions
>  *****************/
> @@ -250,7 +267,7 @@ void zbud_destroy_pool(struct zbud_pool *pool)
>  int zbud_alloc(struct zbud_pool *pool, int size, gfp_t gfp,
>  			unsigned long *handle)
>  {
> -	int chunks, i, freechunks;
> +	int chunks, i;
>  	struct zbud_header *zhdr = NULL;
>  	enum buddy bud;
>  	struct page *page;
> @@ -273,6 +290,7 @@ int zbud_alloc(struct zbud_pool *pool, int size, gfp_t gfp,
>  				bud = FIRST;
>  			else
>  				bud = LAST;
> +			get_zbud_page(zhdr);
>  			goto found;
>  		}
>  	}
> @@ -284,6 +302,10 @@ int zbud_alloc(struct zbud_pool *pool, int size, gfp_t gfp,
>  		return -ENOMEM;
>  	spin_lock(&pool->lock);
>  	pool->pages_nr++;
> +	/*
> +	 * We will be using zhdr instead of page, so
> +	 * don't increase the page count.
> +	 */
>  	zhdr = init_zbud_page(page);
>  	bud = FIRST;
>  
> @@ -295,7 +317,7 @@ found:
>  
>  	if (zhdr->first_chunks == 0 || zhdr->last_chunks == 0) {
>  		/* Add to unbuddied list */
> -		freechunks = num_free_chunks(zhdr);
> +		int freechunks = num_free_chunks(zhdr);
>  		list_add(&zhdr->buddy, &pool->unbuddied[freechunks]);
>  	} else {
>  		/* Add to buddied list */
> @@ -326,7 +348,6 @@ found:
>  void zbud_free(struct zbud_pool *pool, unsigned long handle)
>  {
>  	struct zbud_header *zhdr;
> -	int freechunks;
>  
>  	spin_lock(&pool->lock);
>  	zhdr = handle_to_zbud_header(handle);
> @@ -337,26 +358,19 @@ void zbud_free(struct zbud_pool *pool, unsigned long handle)
>  	else
>  		zhdr->first_chunks = 0;
>  
> -	if (zhdr->under_reclaim) {
> -		/* zbud page is under reclaim, reclaim will free */
> -		spin_unlock(&pool->lock);
> -		return;
> -	}
> -
>  	/* Remove from existing buddy list */
>  	list_del(&zhdr->buddy);
>  
>  	if (zhdr->first_chunks == 0 && zhdr->last_chunks == 0) {
> -		/* zbud page is empty, free */
>  		list_del(&zhdr->lru);
> -		free_zbud_page(zhdr);
>  		pool->pages_nr--;
>  	} else {
>  		/* Add to unbuddied list */
> -		freechunks = num_free_chunks(zhdr);
> +		int freechunks = num_free_chunks(zhdr);
>  		list_add(&zhdr->buddy, &pool->unbuddied[freechunks]);
>  	}
>  
> +	put_zbud_page(zhdr);
>  	spin_unlock(&pool->lock);
>  }
>  
> @@ -400,7 +414,7 @@ void zbud_free(struct zbud_pool *pool, unsigned long handle)
>   */
>  int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries)
>  {
> -	int i, ret, freechunks;
> +	int i, ret;
>  	struct zbud_header *zhdr;
>  	unsigned long first_handle = 0, last_handle = 0;
>  
> @@ -411,11 +425,24 @@ int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries)
>  		return -EINVAL;
>  	}
>  	for (i = 0; i < retries; i++) {
> +		if (list_empty(&pool->lru)) {
> +			/*
> +			 * LRU was emptied during evict calls in previous
> +			 * iteration but put_zbud_page() returned 0 meaning
> +			 * that someone still holds the page. This may
> +			 * happen when some other mm mechanism increased
> +			 * the page count.
> +			 * In such case we succedded with reclaim.
> +			 */
> +			spin_unlock(&pool->lock);
> +			return 0;
> +		}
>  		zhdr = list_tail_entry(&pool->lru, struct zbud_header, lru);
> +		/* Move this last element to beginning of LRU */
>  		list_del(&zhdr->lru);
> -		list_del(&zhdr->buddy);
> +		list_add(&zhdr->lru, &pool->lru);
>  		/* Protect zbud page against free */
> -		zhdr->under_reclaim = true;
> +		get_zbud_page(zhdr);
>  		/*
>  		 * We need encode the handles before unlocking, since we can
>  		 * race with free that will set (first|last)_chunks to 0
> @@ -440,29 +467,9 @@ int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries)
>  				goto next;
>  		}
>  next:
> -		spin_lock(&pool->lock);
> -		zhdr->under_reclaim = false;
> -		if (zhdr->first_chunks == 0 && zhdr->last_chunks == 0) {
> -			/*
> -			 * Both buddies are now free, free the zbud page and
> -			 * return success.
> -			 */
> -			free_zbud_page(zhdr);
> -			pool->pages_nr--;
> -			spin_unlock(&pool->lock);
> +		if (put_zbud_page(zhdr))
>  			return 0;
> -		} else if (zhdr->first_chunks == 0 ||
> -				zhdr->last_chunks == 0) {
> -			/* add to unbuddied list */
> -			freechunks = num_free_chunks(zhdr);
> -			list_add(&zhdr->buddy, &pool->unbuddied[freechunks]);
> -		} else {
> -			/* add to buddied list */
> -			list_add(&zhdr->buddy, &pool->buddied);
> -		}
> -
> -		/* add to beginning of LRU */
> -		list_add(&zhdr->lru, &pool->lru);
> +		spin_lock(&pool->lock);
>  	}
>  	spin_unlock(&pool->lock);
>  	return -EAGAIN;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
