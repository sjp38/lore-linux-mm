Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 8178C6B0031
	for <linux-mm@kvack.org>; Tue,  6 Aug 2013 05:00:20 -0400 (EDT)
Message-ID: <5200BB18.9010105@oracle.com>
Date: Tue, 06 Aug 2013 17:00:08 +0800
From: Bob Liu <bob.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 1/4] zbud: use page ref counter for zbud pages
References: <1375771361-8388-1-git-send-email-k.kozlowski@samsung.com> <1375771361-8388-2-git-send-email-k.kozlowski@samsung.com>
In-Reply-To: <1375771361-8388-2-git-send-email-k.kozlowski@samsung.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Tomasz Stanislawski <t.stanislaws@samsung.com>

Hi Krzysztof,

On 08/06/2013 02:42 PM, Krzysztof Kozlowski wrote:
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

Looks good to me.
Reviewed-by: Bob Liu <bob.liu@oracle.com>

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

Nit picker, how about change the name to adjust_lists() or something
like this because we don't do any rebalancing.

-- 
Regards,
-Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
