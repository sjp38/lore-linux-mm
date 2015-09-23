Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f174.google.com (mail-qk0-f174.google.com [209.85.220.174])
	by kanga.kvack.org (Postfix) with ESMTP id 616E46B0253
	for <linux-mm@kvack.org>; Wed, 23 Sep 2015 18:41:31 -0400 (EDT)
Received: by qkfq186 with SMTP id q186so23374120qkf.1
        for <linux-mm@kvack.org>; Wed, 23 Sep 2015 15:41:31 -0700 (PDT)
Received: from smtp.variantweb.net (smtp.variantweb.net. [104.131.104.118])
        by mx.google.com with ESMTPS id b144si8980874qhc.26.2015.09.23.15.41.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Sep 2015 15:41:30 -0700 (PDT)
Date: Wed, 23 Sep 2015 17:41:27 -0500
From: Seth Jennings <sjennings@variantweb.net>
Subject: Re: [PATCH v2] zbud: allow up to PAGE_SIZE allocations
Message-ID: <20150923224127.GB17171@cerebellum.local.variantweb.net>
References: <20150922141733.d7d97f59f207d0655c3b881d@gmail.com>
 <CALZtONAhARM8FkxLpNQ9-jx4TOU-RyLm2c8suyOY3iN2yvWvLQ@mail.gmail.com>
 <20150923225900.64293d4c2c534f00bfa60435@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150923225900.64293d4c2c534f00bfa60435@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Wed, Sep 23, 2015 at 10:59:00PM +0200, Vitaly Wool wrote:
> Okay, how about this? It's gotten smaller BTW :)
> 
> zbud: allow up to PAGE_SIZE allocations
> 
> Currently zbud is only capable of allocating not more than
> PAGE_SIZE - ZHDR_SIZE_ALIGNED - CHUNK_SIZE. This is okay as
> long as only zswap is using it, but other users of zbud may
> (and likely will) want to allocate up to PAGE_SIZE. This patch
> addresses that by skipping the creation of zbud internal
> structure in the beginning of an allocated page. As a zbud page
> is no longer guaranteed to contain zbud header, the following
> changes have to be applied throughout the code:
> * page->lru to be used for zbud page lists
> * page->private to hold 'under_reclaim' flag
> 
> page->private will also be used to indicate if this page contains
> a zbud header in the beginning or not ('headless' flag).
> 
> Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
> ---
>  mm/zbud.c | 167 ++++++++++++++++++++++++++++++++++++++++++--------------------
>  1 file changed, 113 insertions(+), 54 deletions(-)
> 
> diff --git a/mm/zbud.c b/mm/zbud.c
> index fa48bcdf..3946fba 100644
> --- a/mm/zbud.c
> +++ b/mm/zbud.c
> @@ -105,18 +105,20 @@ struct zbud_pool {
>  
>  /*
>   * struct zbud_header - zbud page metadata occupying the first chunk of each
> - *			zbud page.
> + *			zbud page, except for HEADLESS pages
>   * @buddy:	links the zbud page into the unbuddied/buddied lists in the pool
> - * @lru:	links the zbud page into the lru list in the pool
>   * @first_chunks:	the size of the first buddy in chunks, 0 if free
>   * @last_chunks:	the size of the last buddy in chunks, 0 if free
>   */
>  struct zbud_header {
>  	struct list_head buddy;
> -	struct list_head lru;
>  	unsigned int first_chunks;
>  	unsigned int last_chunks;
> -	bool under_reclaim;
> +};
> +
> +enum zbud_page_flags {
> +	UNDER_RECLAIM = 0,

Don't need the "= 0"

> +	PAGE_HEADLESS,

Also I think we should prefix the enum values here. With ZPF_ ?

>  };
>  
>  /*****************
> @@ -221,6 +223,7 @@ MODULE_ALIAS("zpool-zbud");
>  *****************/
>  /* Just to make the code easier to read */
>  enum buddy {
> +	HEADLESS,
>  	FIRST,
>  	LAST
>  };
> @@ -238,11 +241,14 @@ static int size_to_chunks(size_t size)
>  static struct zbud_header *init_zbud_page(struct page *page)
>  {
>  	struct zbud_header *zhdr = page_address(page);
> +
> +	INIT_LIST_HEAD(&page->lru);
> +	clear_bit(UNDER_RECLAIM, &page->private);
> +	clear_bit(HEADLESS, &page->private);

I know we are using private in a bitwise flags mode, but maybe we
should just init with page->private = 0

> +
>  	zhdr->first_chunks = 0;
>  	zhdr->last_chunks = 0;
>  	INIT_LIST_HEAD(&zhdr->buddy);
> -	INIT_LIST_HEAD(&zhdr->lru);
> -	zhdr->under_reclaim = 0;
>  	return zhdr;
>  }
>  
> @@ -267,11 +273,22 @@ static unsigned long encode_handle(struct zbud_header *zhdr, enum buddy bud)
>  	 * over the zbud header in the first chunk.
>  	 */
>  	handle = (unsigned long)zhdr;
> -	if (bud == FIRST)
> +	switch (bud) {
> +	case FIRST:
>  		/* skip over zbud header */
>  		handle += ZHDR_SIZE_ALIGNED;
> -	else /* bud == LAST */
> +		break;
> +	case LAST:
>  		handle += PAGE_SIZE - (zhdr->last_chunks  << CHUNK_SHIFT);
> +		break;
> +	case HEADLESS:
> +		break;
> +	default:
> +		/* this should never happen */
> +		pr_err("zbud: invalid buddy value %d\n", bud);
> +		handle = 0;
> +		break;
> +	}

Don't need this default case since we have a case for each valid value
of the enum.

Also, I think we want to add some code to free_zbud_page() to clear
page->private and init page->lru so we don't leave dangling pointers.

Looks good though :)

Thanks,
Seth

>  	return handle;
>  }
>  
> @@ -287,6 +304,7 @@ static int num_free_chunks(struct zbud_header *zhdr)
>  	/*
>  	 * Rather than branch for different situations, just use the fact that
>  	 * free buddies have a length of zero to simplify everything.
> +	 * NB: can't be used with HEADLESS pages.
>  	 */
>  	return NCHUNKS - zhdr->first_chunks - zhdr->last_chunks;
>  }
> @@ -353,31 +371,39 @@ void zbud_destroy_pool(struct zbud_pool *pool)
>  int zbud_alloc(struct zbud_pool *pool, size_t size, gfp_t gfp,
>  			unsigned long *handle)
>  {
> -	int chunks, i, freechunks;
> +	int chunks = 0, i, freechunks;
>  	struct zbud_header *zhdr = NULL;
>  	enum buddy bud;
>  	struct page *page;
>  
>  	if (!size || (gfp & __GFP_HIGHMEM))
>  		return -EINVAL;
> -	if (size > PAGE_SIZE - ZHDR_SIZE_ALIGNED - CHUNK_SIZE)
> +
> +	if (size > PAGE_SIZE)
>  		return -ENOSPC;
> -	chunks = size_to_chunks(size);
> -	spin_lock(&pool->lock);
>  
> -	/* First, try to find an unbuddied zbud page. */
> -	zhdr = NULL;
> -	for_each_unbuddied_list(i, chunks) {
> -		if (!list_empty(&pool->unbuddied[i])) {
> -			zhdr = list_first_entry(&pool->unbuddied[i],
> -					struct zbud_header, buddy);
> -			list_del(&zhdr->buddy);
> -			if (zhdr->first_chunks == 0)
> -				bud = FIRST;
> -			else
> -				bud = LAST;
> -			goto found;
> +	if (size > PAGE_SIZE - ZHDR_SIZE_ALIGNED - CHUNK_SIZE)

Nit, maybe we should set chunks = 0 here so that in both branches,
chunks is obviously set.

> +		bud = HEADLESS;
> +	else {
> +		chunks = size_to_chunks(size);
> +		spin_lock(&pool->lock);
> +
> +		/* First, try to find an unbuddied zbud page. */
> +		zhdr = NULL;
> +		for_each_unbuddied_list(i, chunks) {
> +			if (!list_empty(&pool->unbuddied[i])) {
> +				zhdr = list_first_entry(&pool->unbuddied[i],
> +						struct zbud_header, buddy);
> +				list_del(&zhdr->buddy);
> +				page = virt_to_page(zhdr);
> +				if (zhdr->first_chunks == 0)
> +					bud = FIRST;
> +				else
> +					bud = LAST;
> +				goto found;
> +			}
>  		}
> +		bud = FIRST;
>  	}
>  
>  	/* Couldn't find unbuddied zbud page, create new one */
> @@ -388,7 +414,11 @@ int zbud_alloc(struct zbud_pool *pool, size_t size, gfp_t gfp,
>  	spin_lock(&pool->lock);
>  	pool->pages_nr++;
>  	zhdr = init_zbud_page(page);
> -	bud = FIRST;
> +
> +	if (bud == HEADLESS) {	
> +		set_bit(PAGE_HEADLESS, &page->private);
> +		goto headless;
> +	}
>  
>  found:
>  	if (bud == FIRST)
> @@ -405,10 +435,12 @@ found:
>  		list_add(&zhdr->buddy, &pool->buddied);
>  	}
>  
> +headless:
>  	/* Add/move zbud page to beginning of LRU */
> -	if (!list_empty(&zhdr->lru))
> -		list_del(&zhdr->lru);
> -	list_add(&zhdr->lru, &pool->lru);
> +	if (!list_empty(&page->lru))
> +		list_del(&page->lru);
> +
> +	list_add(&page->lru, &pool->lru);
>  
>  	*handle = encode_handle(zhdr, bud);
>  	spin_unlock(&pool->lock);
> @@ -430,28 +462,39 @@ void zbud_free(struct zbud_pool *pool, unsigned long handle)
>  {
>  	struct zbud_header *zhdr;
>  	int freechunks;
> +	struct page *page;
> +	enum buddy bud;
>  
>  	spin_lock(&pool->lock);
>  	zhdr = handle_to_zbud_header(handle);
> +	page = virt_to_page(zhdr);
>  
> -	/* If first buddy, handle will be page aligned */
> -	if ((handle - ZHDR_SIZE_ALIGNED) & ~PAGE_MASK)
> +	if (!(handle & ~PAGE_MASK)) /* HEADLESS page stored */
> +		bud = HEADLESS;
> +	else if ((handle - ZHDR_SIZE_ALIGNED) & ~PAGE_MASK) {
> +		bud = LAST;
>  		zhdr->last_chunks = 0;
> -	else
> +	} else {
> +		/* If first buddy, handle will be page aligned */
> +		bud = FIRST;
>  		zhdr->first_chunks = 0;
> +	}
>  
> -	if (zhdr->under_reclaim) {
> +	if (test_bit(UNDER_RECLAIM, &page->private)) {
>  		/* zbud page is under reclaim, reclaim will free */
>  		spin_unlock(&pool->lock);
>  		return;
>  	}
>  
> -	/* Remove from existing buddy list */
> -	list_del(&zhdr->buddy);
> +	if (bud != HEADLESS) {
> +		/* Remove from existing buddy list */
> +		list_del(&zhdr->buddy);
> +	}
>  
> -	if (zhdr->first_chunks == 0 && zhdr->last_chunks == 0) {
> +	if (bud == HEADLESS ||
> +	    (zhdr->first_chunks == 0 && zhdr->last_chunks == 0)) {
>  		/* zbud page is empty, free */
> -		list_del(&zhdr->lru);
> +		list_del(&page->lru);
>  		free_zbud_page(zhdr);
>  		pool->pages_nr--;
>  	} else {
> @@ -503,8 +546,9 @@ void zbud_free(struct zbud_pool *pool, unsigned long handle)
>   */
>  int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries)
>  {
> -	int i, ret, freechunks;
> +	int i, ret = 0, freechunks;
>  	struct zbud_header *zhdr;
> +	struct page *page;
>  	unsigned long first_handle = 0, last_handle = 0;
>  
>  	spin_lock(&pool->lock);
> @@ -514,21 +558,30 @@ int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries)
>  		return -EINVAL;
>  	}
>  	for (i = 0; i < retries; i++) {
> -		zhdr = list_tail_entry(&pool->lru, struct zbud_header, lru);
> -		list_del(&zhdr->lru);
> -		list_del(&zhdr->buddy);
> +		page = list_tail_entry(&pool->lru, struct page, lru);
> +		list_del(&page->lru);
> +
>  		/* Protect zbud page against free */
> -		zhdr->under_reclaim = true;
> -		/*
> -		 * We need encode the handles before unlocking, since we can
> -		 * race with free that will set (first|last)_chunks to 0
> -		 */
> -		first_handle = 0;
> -		last_handle = 0;
> -		if (zhdr->first_chunks)
> -			first_handle = encode_handle(zhdr, FIRST);
> -		if (zhdr->last_chunks)
> -			last_handle = encode_handle(zhdr, LAST);
> +		set_bit(UNDER_RECLAIM, &page->private);
> +		zhdr = page_address(page);
> +		if (!test_bit(PAGE_HEADLESS, &page->private)) {
> +			list_del(&zhdr->buddy);
> +			/*
> +			 * We need encode the handles before unlocking, since
> +			 * we can race with free that will set
> +			 * (first|last)_chunks to 0
> +			 */
> +			first_handle = 0;
> +			last_handle = 0;
> +			if (zhdr->first_chunks)
> +				first_handle = encode_handle(zhdr, FIRST);
> +			if (zhdr->last_chunks)
> +				last_handle = encode_handle(zhdr, LAST);
> +		} else {
> +			first_handle = encode_handle(zhdr, HEADLESS);
> +			last_handle = 0;
> +		}
> +
>  		spin_unlock(&pool->lock);
>  
>  		/* Issue the eviction callback(s) */
> @@ -544,8 +597,14 @@ int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries)
>  		}
>  next:
>  		spin_lock(&pool->lock);
> -		zhdr->under_reclaim = false;
> -		if (zhdr->first_chunks == 0 && zhdr->last_chunks == 0) {
> +		clear_bit(UNDER_RECLAIM, &page->private);
> +		if (test_bit(PAGE_HEADLESS, &page->private)) {
> +			if (ret == 0) {
> +				free_zbud_page(zhdr);
> +				pool->pages_nr--;
> +				spin_unlock(&pool->lock);
> +			}
> +		} else if (zhdr->first_chunks == 0 && zhdr->last_chunks == 0) {
>  			/*
>  			 * Both buddies are now free, free the zbud page and
>  			 * return success.
> @@ -565,7 +624,7 @@ next:
>  		}
>  
>  		/* add to beginning of LRU */
> -		list_add(&zhdr->lru, &pool->lru);
> +		list_add(&page->lru, &pool->lru);
>  	}
>  	spin_unlock(&pool->lock);
>  	return -EAGAIN;
> -- 
> 2.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
