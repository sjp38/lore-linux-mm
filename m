Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id C2C586B0062
	for <linux-mm@kvack.org>; Wed, 19 Sep 2012 15:51:03 -0400 (EDT)
Date: Wed, 19 Sep 2012 12:51:02 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 4/4] cma: fix watermark checking
Message-Id: <20120919125102.4a45e27c.akpm@linux-foundation.org>
In-Reply-To: <1347632974-20465-5-git-send-email-b.zolnierkie@samsung.com>
References: <1347632974-20465-1-git-send-email-b.zolnierkie@samsung.com>
	<1347632974-20465-5-git-send-email-b.zolnierkie@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: linux-mm@kvack.org, m.szyprowski@samsung.com, mina86@mina86.com, minchan@kernel.org, mgorman@suse.de, hughd@google.com, kyungmin.park@samsung.com

On Fri, 14 Sep 2012 16:29:34 +0200
Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com> wrote:

> * Add ALLOC_CMA alloc flag and pass it to [__]zone_watermark_ok()
>   (from Minchan Kim).

What is its meaning and why was it added.

> * During watermark check decrease available free pages number by
>   free CMA pages number if necessary (unmovable allocations cannot
>   use pages from CMA areas).
> 
> ...
>
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -231,6 +231,21 @@ enum zone_watermarks {
>  #define low_wmark_pages(z) (z->watermark[WMARK_LOW])
>  #define high_wmark_pages(z) (z->watermark[WMARK_HIGH])
>  
> +/* The ALLOC_WMARK bits are used as an index to zone->watermark */
> +#define ALLOC_WMARK_MIN		WMARK_MIN
> +#define ALLOC_WMARK_LOW		WMARK_LOW
> +#define ALLOC_WMARK_HIGH	WMARK_HIGH
> +#define ALLOC_NO_WATERMARKS	0x04 /* don't check watermarks at all */
> +
> +/* Mask to get the watermark bits */
> +#define ALLOC_WMARK_MASK	(ALLOC_NO_WATERMARKS-1)
> +
> +#define ALLOC_HARDER		0x10 /* try to alloc harder */
> +#define ALLOC_HIGH		0x20 /* __GFP_HIGH set */
> +#define ALLOC_CPUSET		0x40 /* check for correct cpuset */
> +

Unneeded newline.

> +#define ALLOC_CMA		0x80

All the other enumerations were documented.  ALLOC_CMA was left
undocumented, despite sorely needing documentation.

>  struct per_cpu_pages {
>  	int count;		/* number of pages in the list */
>  	int high;		/* high watermark, emptying needed */
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 4b902aa..36d79ea 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -868,6 +868,7 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
>  	struct zoneref *z;
>  	struct zone *zone;
>  	int rc = COMPACT_SKIPPED;
> +	int alloc_flags = 0;
>  
>  	/*
>  	 * Check whether it is worth even starting compaction. The order check is
> @@ -879,6 +880,10 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
>  
>  	count_vm_event(COMPACTSTALL);
>  
> +#ifdef CONFIG_CMA
> +	if (allocflags_to_migratetype(gfp_mask) == MIGRATE_MOVABLE)
> +		alloc_flags |= ALLOC_CMA;

I find this rather obscure.  What is the significance of
MIGRATE_MOVABLE here?  If it had been 

:	if (allocflags_to_migratetype(gfp_mask) == MIGRATE_CMA)
:		alloc_flags |= ALLOC_CMA;

then I'd have read straight past it.  But it's unclear what's happening
here.  If we didn't have to resort to telepathy to understand the
meaning of ALLOC_CMA, this wouldn't be so hard.

> +#endif
>  	/* Compact each zone in the list */
>  	for_each_zone_zonelist_nodemask(zone, z, zonelist, high_zoneidx,
>  								nodemask) {
> @@ -889,7 +894,8 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
>  		rc = max(status, rc);
>  
>  		/* If a normal allocation would succeed, stop compacting */
> -		if (zone_watermark_ok(zone, order, low_wmark_pages(zone), 0, 0))
> +		if (zone_watermark_ok(zone, order, low_wmark_pages(zone), 0,
> +				      alloc_flags))
>  			break;
>  	}
>  
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 287f79d..5985cbf 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1519,19 +1519,6 @@ failed:
>  	return NULL;
>  }
>  
> -/* The ALLOC_WMARK bits are used as an index to zone->watermark */
> -#define ALLOC_WMARK_MIN		WMARK_MIN
> -#define ALLOC_WMARK_LOW		WMARK_LOW
> -#define ALLOC_WMARK_HIGH	WMARK_HIGH
> -#define ALLOC_NO_WATERMARKS	0x04 /* don't check watermarks at all */
> -
> -/* Mask to get the watermark bits */
> -#define ALLOC_WMARK_MASK	(ALLOC_NO_WATERMARKS-1)
> -
> -#define ALLOC_HARDER		0x10 /* try to alloc harder */
> -#define ALLOC_HIGH		0x20 /* __GFP_HIGH set */
> -#define ALLOC_CPUSET		0x40 /* check for correct cpuset */

Perhaps mm/internal.h wouild have been a better place to move these.

>  #ifdef CONFIG_FAIL_PAGE_ALLOC
>  
>  static struct {
> @@ -1626,7 +1613,10 @@ static bool __zone_watermark_ok(struct zone *z, int order, unsigned long mark,
>  		min -= min / 2;
>  	if (alloc_flags & ALLOC_HARDER)
>  		min -= min / 4;
> -
> +#ifdef CONFIG_CMA
> +	if (!(alloc_flags & ALLOC_CMA))
> +		free_pages -= zone_page_state(z, NR_FREE_CMA_PAGES);

Again, the negated test looks weird or just wrong.



Please do something to make this code more understandable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
