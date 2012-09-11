Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id C4A7A6B0082
	for <linux-mm@kvack.org>; Mon, 10 Sep 2012 21:43:59 -0400 (EDT)
Date: Tue, 11 Sep 2012 10:45:55 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [patch 1/2 v2]compaction: abort compaction loop if lock is
 contended or run too long
Message-ID: <20120911014555.GA14331@bbox>
References: <20120910011830.GC3715@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120910011830.GC3715@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mgorman@suse.de, aarcange@redhat.com

On Mon, Sep 10, 2012 at 09:18:30AM +0800, Shaohua Li wrote:
> isolate_migratepages_range() might isolate none pages, for example, when
> zone->lru_lock is contended and compaction is async. In this case, we should
> abort compaction, otherwise, compact_zone will run a useless loop and make
> zone->lru_lock is even contended.
> 

As I read old thread, you have the scenario and number.
Please include them in this description.

> V2:
> only abort the compaction if lock is contended or run too long
> Rearranged the code by Andrea Arcangeli.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> Signed-off-by: Shaohua Li <shli@fusionio.com>

Acked-by: Minchan Kim <minchan@kernel.org>

Other than some nitpicks, looks good to me.

> ---
>  mm/compaction.c |   12 +++++++-----
>  mm/internal.h   |    2 +-
>  2 files changed, 8 insertions(+), 6 deletions(-)
> 
> Index: linux/mm/compaction.c
> ===================================================================
> --- linux.orig/mm/compaction.c	2012-09-06 18:37:52.636413761 +0800
> +++ linux/mm/compaction.c	2012-09-10 08:49:40.377869710 +0800
> @@ -70,8 +70,7 @@ static bool compact_checklock_irqsave(sp
>  
>  		/* async aborts if taking too long or contended */
>  		if (!cc->sync) {
> -			if (cc->contended)
> -				*cc->contended = true;
> +			cc->contended = true;
>  			return false;
>  		}
>  
> @@ -634,7 +633,7 @@ static isolate_migrate_t isolate_migrate
>  
>  	/* Perform the isolation */
>  	low_pfn = isolate_migratepages_range(zone, cc, low_pfn, end_pfn);
> -	if (!low_pfn)
> +	if (!low_pfn || cc->contended)
>  		return ISOLATE_ABORT;
>  
>  	cc->migrate_pfn = low_pfn;
> @@ -831,6 +830,7 @@ static unsigned long compact_zone_order(
>  				 int order, gfp_t gfp_mask,
>  				 bool sync, bool *contended)
>  {
> +	unsigned long ret;
>  	struct compact_control cc = {
>  		.nr_freepages = 0,
>  		.nr_migratepages = 0,
> @@ -838,12 +838,14 @@ static unsigned long compact_zone_order(
>  		.migratetype = allocflags_to_migratetype(gfp_mask),
>  		.zone = zone,
>  		.sync = sync,
> -		.contended = contended,
>  	};
>  	INIT_LIST_HEAD(&cc.freepages);
>  	INIT_LIST_HEAD(&cc.migratepages);
>  
> -	return compact_zone(zone, &cc);
> +	ret = compact_zone(zone, &cc);
> +	if (contended)
> +		*contended = cc.contended;
> +	return ret;
>  }
>  
>  int sysctl_extfrag_threshold = 500;
> Index: linux/mm/internal.h
> ===================================================================
> --- linux.orig/mm/internal.h	2012-09-03 15:16:30.566299444 +0800
> +++ linux/mm/internal.h	2012-09-10 08:45:41.980866645 +0800
> @@ -131,7 +131,7 @@ struct compact_control {
>  	int order;			/* order a direct compactor needs */
>  	int migratetype;		/* MOVABLE, RECLAIMABLE etc */
>  	struct zone *zone;
> -	bool *contended;		/* True if a lock was contended */
> +	bool contended;			/* True if a lock was contended */

I would like to add more specific condition.
/* True if a lock was contended in case of async compaction */

>  };
>  
>  unsigned long
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
