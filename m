Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 69E646B0078
	for <linux-mm@kvack.org>; Tue, 28 May 2013 17:59:14 -0400 (EDT)
Date: Tue, 28 May 2013 14:59:11 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCHv12 2/4] zbud: add to mm/
Message-Id: <20130528145911.bd484cbb0bb7a27c1623c520@linux-foundation.org>
In-Reply-To: <1369067168-12291-3-git-send-email-sjenning@linux.vnet.ibm.com>
References: <1369067168-12291-1-git-send-email-sjenning@linux.vnet.ibm.com>
	<1369067168-12291-3-git-send-email-sjenning@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@sr71.net>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Hugh Dickens <hughd@google.com>, Paul Mackerras <paulus@samba.org>, Heesub Shin <heesub.shin@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On Mon, 20 May 2013 11:26:06 -0500 Seth Jennings <sjenning@linux.vnet.ibm.com> wrote:

> zbud is an special purpose allocator for storing compressed pages. It is
> designed to store up to two compressed pages per physical page.  While this
> design limits storage density, it has simple and deterministic reclaim
> properties that make it preferable to a higher density approach when reclaim
> will be used.
> 
> zbud works by storing compressed pages, or "zpages", together in pairs in a
> single memory page called a "zbud page".  The first buddy is "left
> justifed" at the beginning of the zbud page, and the last buddy is "right
> justified" at the end of the zbud page.  The benefit is that if either
> buddy is freed, the freed buddy space, coalesced with whatever slack space
> that existed between the buddies, results in the largest possible free region
> within the zbud page.
> 
> zbud also provides an attractive lower bound on density. The ratio of zpages
> to zbud pages can not be less than 1.  This ensures that zbud can never "do
> harm" by using more pages to store zpages than the uncompressed zpages would
> have used on their own.
> 
> This implementation is a rewrite of the zbud allocator internally used
> by zcache in the driver/staging tree.  The rewrite was necessary to
> remove some of the zcache specific elements that were ingrained throughout
> and provide a generic allocation interface that can later be used by
> zsmalloc and others.
> 
> This patch adds zbud to mm/ for later use by zswap.
> 
> ...
>
> +/**
> + * struct zbud_page - zbud page metadata overlay
> + * @page:	typed reference to the underlying struct page
> + * @donotuse:	this overlays the page flags and should not be used
> + * @first_chunks:	the size of the first buddy in chunks, 0 if free
> + * @last_chunks:	the size of the last buddy in chunks, 0 if free
> + * @buddy:	links the zbud page into the unbuddied/buddied lists in the pool
> + * @lru:	links the zbud page into the lru list in the pool
> + *
> + * This structure overlays the struct page to store metadata needed for a
> + * single storage page in for zbud.  There is a BUILD_BUG_ON in zbud_init()
> + * that ensures this structure is not larger that struct page.
> + *
> + * The PG_reclaim flag of the underlying page is used for indicating
> + * that this zbud page is under reclaim (see zbud_reclaim_page())
> + */
> +struct zbud_page {
> +	union {
> +		struct page page;
> +		struct {
> +			unsigned long donotuse;
> +			u16 first_chunks;
> +			u16 last_chunks;
> +			struct list_head buddy;
> +			struct list_head lru;
> +		};
> +	};
> +};

Whoa.  So zbud scribbles on existing pageframes?

Please tell us about this, in some detail.  How is it done and why is
this necessary?

Presumably the pageframe must be restored at some stage, so this code
has to be kept in sync with external unrelated changes to core MM?

Why was it implemented in this fashion rather than going into the main
`struct page' definition and adding the appropriate unionised fields?

I worry about any code which independently looks at the pageframe
tables and expects to find page struts there.  One example is probably
memory_failure() but there are probably others.

> 
> ...
>
> +int zbud_alloc(struct zbud_pool *pool, int size, gfp_t gfp,
> +			unsigned long *handle)
> +{
> +	int chunks, i, freechunks;
> +	struct zbud_page *zbpage = NULL;
> +	enum buddy bud;
> +	struct page *page;
> +
> +	if (size <= 0 || gfp & __GFP_HIGHMEM)
> +		return -EINVAL;
> +	if (size > PAGE_SIZE)
> +		return -E2BIG;

Means "Argument list too long" and isn't appropriate here.

> +	chunks = size_to_chunks(size);
> +	spin_lock(&pool->lock);
> +
> +	/* First, try to find an unbuddied zbpage. */
> +	zbpage = NULL;
> +	for_each_unbuddied_list(i, chunks) {
> +		if (!list_empty(&pool->unbuddied[i])) {
> +			zbpage = list_first_entry(&pool->unbuddied[i],
> +					struct zbud_page, buddy);
> +			list_del(&zbpage->buddy);
> +			if (zbpage->first_chunks == 0)
> +				bud = FIRST;
> +			else
> +				bud = LAST;
> +			goto found;
> +		}
> +	}
> +
> +	/* Couldn't find unbuddied zbpage, create new one */
> +	spin_unlock(&pool->lock);
> +	page = alloc_page(gfp);
> +	if (!page)
> +		return -ENOMEM;
> +	spin_lock(&pool->lock);
> +	pool->pages_nr++;
> +	zbpage = init_zbud_page(page);
> +	bud = FIRST;
> +
> +found:
> +	if (bud == FIRST)
> +		zbpage->first_chunks = chunks;
> +	else
> +		zbpage->last_chunks = chunks;
> +
> +	if (zbpage->first_chunks == 0 || zbpage->last_chunks == 0) {
> +		/* Add to unbuddied list */
> +		freechunks = num_free_chunks(zbpage);
> +		list_add(&zbpage->buddy, &pool->unbuddied[freechunks]);
> +	} else {
> +		/* Add to buddied list */
> +		list_add(&zbpage->buddy, &pool->buddied);
> +	}
> +
> +	/* Add/move zbpage to beginning of LRU */
> +	if (!list_empty(&zbpage->lru))
> +		list_del(&zbpage->lru);
> +	list_add(&zbpage->lru, &pool->lru);
> +
> +	*handle = encode_handle(zbpage, bud);
> +	spin_unlock(&pool->lock);
> +
> +	return 0;
> +}
> 
> ...
>
> +int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries)
> +{
> +	int i, ret, freechunks;
> +	struct zbud_page *zbpage;
> +	unsigned long first_handle = 0, last_handle = 0;
> +
> +	spin_lock(&pool->lock);
> +	if (!pool->ops || !pool->ops->evict || list_empty(&pool->lru) ||
> +			retries == 0) {
> +		spin_unlock(&pool->lock);
> +		return -EINVAL;
> +	}
> +	for (i = 0; i < retries; i++) {
> +		zbpage = list_tail_entry(&pool->lru, struct zbud_page, lru);
> +		list_del(&zbpage->lru);
> +		list_del(&zbpage->buddy);
> +		/* Protect zbpage against free */

Against free by who?  What other code paths can access this page at
this time?

> +		SetPageReclaim(&zbpage->page);
> +		/*
> +		 * We need encode the handles before unlocking, since we can
> +		 * race with free that will set (first|last)_chunks to 0
> +		 */
> +		first_handle = 0;
> +		last_handle = 0;
> +		if (zbpage->first_chunks)
> +			first_handle = encode_handle(zbpage, FIRST);
> +		if (zbpage->last_chunks)
> +			last_handle = encode_handle(zbpage, LAST);
> +		spin_unlock(&pool->lock);
> +
> +		/* Issue the eviction callback(s) */
> +		if (first_handle) {
> +			ret = pool->ops->evict(pool, first_handle);
> +			if (ret)
> +				goto next;
> +		}
> +		if (last_handle) {
> +			ret = pool->ops->evict(pool, last_handle);
> +			if (ret)
> +				goto next;
> +		}
> +next:
> +		spin_lock(&pool->lock);
> +		ClearPageReclaim(&zbpage->page);
> +		if (zbpage->first_chunks == 0 && zbpage->last_chunks == 0) {
> +			/*
> +			 * Both buddies are now free, free the zbpage and
> +			 * return success.
> +			 */
> +			free_zbud_page(zbpage);
> +			pool->pages_nr--;
> +			spin_unlock(&pool->lock);
> +			return 0;
> +		} else if (zbpage->first_chunks == 0 ||
> +				zbpage->last_chunks == 0) {
> +			/* add to unbuddied list */
> +			freechunks = num_free_chunks(zbpage);
> +			list_add(&zbpage->buddy, &pool->unbuddied[freechunks]);
> +		} else {
> +			/* add to buddied list */
> +			list_add(&zbpage->buddy, &pool->buddied);
> +		}
> +
> +		/* add to beginning of LRU */
> +		list_add(&zbpage->lru, &pool->lru);
> +	}
> +	spin_unlock(&pool->lock);
> +	return -EAGAIN;
> +}
> 
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
