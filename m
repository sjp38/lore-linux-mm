Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 9FCA86B0031
	for <linux-mm@kvack.org>; Tue,  6 Aug 2013 14:51:06 -0400 (EDT)
Date: Tue, 6 Aug 2013 13:51:04 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH 1/4] zbud: use page ref counter for zbud pages
Message-ID: <20130806185104.GD5765@medulla.variantweb.net>
References: <1375771361-8388-1-git-send-email-k.kozlowski@samsung.com>
 <1375771361-8388-2-git-send-email-k.kozlowski@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1375771361-8388-2-git-send-email-k.kozlowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Tomasz Stanislawski <t.stanislaws@samsung.com>

On Tue, Aug 06, 2013 at 08:42:38AM +0200, Krzysztof Kozlowski wrote:
> Use page reference counter for zbud pages. The ref counter replaces
> zbud_header.under_reclaim flag and ensures that zbud page won't be freed
> when zbud_free() is called during reclaim. It allows implementation of
> additional reclaim paths.
> 
> The page count is incremented when:
>  - a handle is created and passed to zswap (in zbud_alloc()),
>  - user-supplied eviction callback is called (in zbud_reclaim_page()).

I like the idea.  I few things below.  Also agree with Bob the
s/rebalance/adjust/ for rebalance_lists().

> 
> Signed-off-by: Krzysztof Kozlowski <k.kozlowski@samsung.com>
> Signed-off-by: Tomasz Stanislawski <t.stanislaws@samsung.com>
> ---
>  mm/zbud.c |  150 +++++++++++++++++++++++++++++++++++--------------------------
>  1 file changed, 86 insertions(+), 64 deletions(-)
> 
> diff --git a/mm/zbud.c b/mm/zbud.c
> index ad1e781..a8e986f 100644
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
> @@ -188,6 +180,65 @@ static int num_free_chunks(struct zbud_header *zhdr)
>  	return NCHUNKS - zhdr->first_chunks - zhdr->last_chunks - 1;
>  }
> 
> +/*
> + * Called after zbud_free() or zbud_alloc().
> + * Checks whether given zbud page has to be:
> + *  - removed from buddied/unbuddied/LRU lists completetely (zbud_free).
> + *  - moved from buddied to unbuddied list
> + *    and to beginning of LRU (zbud_alloc, zbud_free),
> + *  - added to buddied list and LRU (zbud_alloc),
> + *
> + * The page must be already removed from buddied/unbuddied lists.
> + * Must be called under pool->lock.
> + */
> +static void rebalance_lists(struct zbud_pool *pool, struct zbud_header *zhdr)
> +{
> +	if (zhdr->first_chunks == 0 && zhdr->last_chunks == 0) {
> +		/* zbud_free() */
> +		list_del(&zhdr->lru);
> +		return;
> +	} else if (zhdr->first_chunks == 0 || zhdr->last_chunks == 0) {

s/else if/if/ since the if above returns if true.

> +		/* zbud_free() or zbud_alloc() */
> +		int freechunks = num_free_chunks(zhdr);
> +		list_add(&zhdr->buddy, &pool->unbuddied[freechunks]);
> +	} else {
> +		/* zbud_alloc() */
> +		list_add(&zhdr->buddy, &pool->buddied);
> +	}
> +	/* Add/move zbud page to beginning of LRU */
> +	if (!list_empty(&zhdr->lru))
> +		list_del(&zhdr->lru);

We don't want to reinsert to the LRU list if we have called zbud_free()
on a zbud page that previously had two buddies.  This code causes the
zbud page to move to the front of the LRU list which is not what we want.

> +	list_add(&zhdr->lru, &pool->lru);
> +}
> +
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
> + * Must be called under pool->lock.
> + *
> + * Returns 1 if page was freed and 0 otherwise.
> + */
> +static int put_zbud_page(struct zbud_pool *pool, struct zbud_header *zhdr)
> +{
> +	struct page *page = virt_to_page(zhdr);
> +	if (put_page_testzero(page)) {
> +		free_hot_cold_page(page, 0);
> +		pool->pages_nr--;
> +		return 1;
> +	}
> +	return 0;
> +}
> +
> +
>  /*****************
>   * API Functions
>  *****************/
> @@ -250,7 +301,7 @@ void zbud_destroy_pool(struct zbud_pool *pool)
>  int zbud_alloc(struct zbud_pool *pool, int size, gfp_t gfp,
>  			unsigned long *handle)
>  {
> -	int chunks, i, freechunks;
> +	int chunks, i;
>  	struct zbud_header *zhdr = NULL;
>  	enum buddy bud;
>  	struct page *page;
> @@ -273,6 +324,7 @@ int zbud_alloc(struct zbud_pool *pool, int size, gfp_t gfp,
>  				bud = FIRST;
>  			else
>  				bud = LAST;
> +			get_zbud_page(zhdr);
>  			goto found;
>  		}
>  	}
> @@ -284,6 +336,10 @@ int zbud_alloc(struct zbud_pool *pool, int size, gfp_t gfp,
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
> @@ -293,19 +349,7 @@ found:
>  	else
>  		zhdr->last_chunks = chunks;
> 
> -	if (zhdr->first_chunks == 0 || zhdr->last_chunks == 0) {
> -		/* Add to unbuddied list */
> -		freechunks = num_free_chunks(zhdr);
> -		list_add(&zhdr->buddy, &pool->unbuddied[freechunks]);
> -	} else {
> -		/* Add to buddied list */
> -		list_add(&zhdr->buddy, &pool->buddied);
> -	}
> -
> -	/* Add/move zbud page to beginning of LRU */
> -	if (!list_empty(&zhdr->lru))
> -		list_del(&zhdr->lru);
> -	list_add(&zhdr->lru, &pool->lru);
> +	rebalance_lists(pool, zhdr);
> 
>  	*handle = encode_handle(zhdr, bud);
>  	spin_unlock(&pool->lock);
> @@ -326,10 +370,10 @@ found:
>  void zbud_free(struct zbud_pool *pool, unsigned long handle)
>  {
>  	struct zbud_header *zhdr;
> -	int freechunks;
> 
>  	spin_lock(&pool->lock);
>  	zhdr = handle_to_zbud_header(handle);
> +	BUG_ON(zhdr->last_chunks == 0 && zhdr->first_chunks == 0);

Not sure we need this.  Maybe, at most, VM_BUG_ON()?

> 
>  	/* If first buddy, handle will be page aligned */
>  	if ((handle - ZHDR_SIZE_ALIGNED) & ~PAGE_MASK)
> @@ -337,26 +381,9 @@ void zbud_free(struct zbud_pool *pool, unsigned long handle)
>  	else
>  		zhdr->first_chunks = 0;
> 
> -	if (zhdr->under_reclaim) {
> -		/* zbud page is under reclaim, reclaim will free */
> -		spin_unlock(&pool->lock);
> -		return;
> -	}
> -
> -	/* Remove from existing buddy list */
>  	list_del(&zhdr->buddy);
> -
> -	if (zhdr->first_chunks == 0 && zhdr->last_chunks == 0) {
> -		/* zbud page is empty, free */
> -		list_del(&zhdr->lru);
> -		free_zbud_page(zhdr);
> -		pool->pages_nr--;
> -	} else {
> -		/* Add to unbuddied list */
> -		freechunks = num_free_chunks(zhdr);
> -		list_add(&zhdr->buddy, &pool->unbuddied[freechunks]);
> -	}
> -
> +	rebalance_lists(pool, zhdr);
> +	put_zbud_page(pool, zhdr);
>  	spin_unlock(&pool->lock);
>  }
> 
> @@ -400,7 +427,7 @@ void zbud_free(struct zbud_pool *pool, unsigned long handle)
>   */
>  int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries)
>  {
> -	int i, ret, freechunks;
> +	int i, ret;
>  	struct zbud_header *zhdr;
>  	unsigned long first_handle = 0, last_handle = 0;
> 
> @@ -411,11 +438,24 @@ int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries)
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
> +			return 0;
> +		}
>  		zhdr = list_tail_entry(&pool->lru, struct zbud_header, lru);
> +		BUG_ON(zhdr->first_chunks == 0 && zhdr->last_chunks == 0);

Again here.

Thanks,
Seth

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
> @@ -441,28 +481,10 @@ int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries)
>  		}
>  next:
>  		spin_lock(&pool->lock);
> -		zhdr->under_reclaim = false;
> -		if (zhdr->first_chunks == 0 && zhdr->last_chunks == 0) {
> -			/*
> -			 * Both buddies are now free, free the zbud page and
> -			 * return success.
> -			 */
> -			free_zbud_page(zhdr);
> -			pool->pages_nr--;
> +		if (put_zbud_page(pool, zhdr)) {
>  			spin_unlock(&pool->lock);
>  			return 0;
> -		} else if (zhdr->first_chunks == 0 ||
> -				zhdr->last_chunks == 0) {
> -			/* add to unbuddied list */
> -			freechunks = num_free_chunks(zhdr);
> -			list_add(&zhdr->buddy, &pool->unbuddied[freechunks]);
> -		} else {
> -			/* add to buddied list */
> -			list_add(&zhdr->buddy, &pool->buddied);
>  		}
> -
> -		/* add to beginning of LRU */
> -		list_add(&zhdr->lru, &pool->lru);
>  	}
>  	spin_unlock(&pool->lock);
>  	return -EAGAIN;
> -- 
> 1.7.9.5
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
