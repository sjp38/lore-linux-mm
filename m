Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 027FD6B0012
	for <linux-mm@kvack.org>; Tue, 31 May 2011 00:55:27 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 0E6813EE0CE
	for <linux-mm@kvack.org>; Tue, 31 May 2011 13:55:24 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E536B45DE93
	for <linux-mm@kvack.org>; Tue, 31 May 2011 13:55:23 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id CCC4045DE91
	for <linux-mm@kvack.org>; Tue, 31 May 2011 13:55:23 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id BE1CD1DB803B
	for <linux-mm@kvack.org>; Tue, 31 May 2011 13:55:23 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7A5671DB8037
	for <linux-mm@kvack.org>; Tue, 31 May 2011 13:55:23 +0900 (JST)
Date: Tue, 31 May 2011 13:48:35 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] mm: compaction: Abort compaction if too many pages are
 isolated and caller is asynchronous
Message-Id: <20110531134835.b7c9edc2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110530131300.GQ5044@csn.ul.ie>
References: <20110530131300.GQ5044@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: akpm@linux-foundation.org, Ury Stankevich <urykhy@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@kernel.org

On Mon, 30 May 2011 14:13:00 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> Asynchronous compaction is used when promoting to huge pages. This is
> all very nice but if there are a number of processes in compacting
> memory, a large number of pages can be isolated. An "asynchronous"
> process can stall for long periods of time as a result with a user
> reporting that firefox can stall for 10s of seconds. This patch aborts
> asynchronous compaction if too many pages are isolated as it's better to
> fail a hugepage promotion than stall a process.
> 
> If accepted, this should also be considered for 2.6.39-stable. It should
> also be considered for 2.6.38-stable but ideally [11bc82d6: mm:
> compaction: Use async migration for __GFP_NO_KSWAPD and enforce no
> writeback] would be applied to 2.6.38 before consideration.
> 
> Reported-and-Tested-by: Ury Stankevich <urykhy@gmail.com>
> Signed-off-by: Mel Gorman <mgorman@suse.de>



Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

BTW, I'm surprised to see both of vmscan.c and compaction.c has too_many_isolated()..
in different logic ;)

BTW, compaction ignores UNEVICTABLE LRU ?

Thanks,
-Kame


> ---
>  mm/compaction.c |   32 ++++++++++++++++++++++++++------
>  1 files changed, 26 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 021a296..331a2ee 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -240,11 +240,20 @@ static bool too_many_isolated(struct zone *zone)
>  	return isolated > (inactive + active) / 2;
>  }
>  
> +/* possible outcome of isolate_migratepages */
> +typedef enum {
> +	ISOLATE_ABORT,		/* Abort compaction now */
> +	ISOLATE_NONE,		/* No pages isolated, continue scanning */
> +	ISOLATE_SUCCESS,	/* Pages isolated, migrate */
> +} isolate_migrate_t;
> +
>  /*
>   * Isolate all pages that can be migrated from the block pointed to by
>   * the migrate scanner within compact_control.
> + *
> + * Returns false if compaction should abort at this point due to congestion.
>   */
> -static unsigned long isolate_migratepages(struct zone *zone,
> +static isolate_migrate_t isolate_migratepages(struct zone *zone,
>  					struct compact_control *cc)
>  {
>  	unsigned long low_pfn, end_pfn;
> @@ -261,7 +270,7 @@ static unsigned long isolate_migratepages(struct zone *zone,
>  	/* Do not cross the free scanner or scan within a memory hole */
>  	if (end_pfn > cc->free_pfn || !pfn_valid(low_pfn)) {
>  		cc->migrate_pfn = end_pfn;
> -		return 0;
> +		return ISOLATE_NONE;
>  	}
>  
>  	/*
> @@ -270,10 +279,14 @@ static unsigned long isolate_migratepages(struct zone *zone,
>  	 * delay for some time until fewer pages are isolated
>  	 */
>  	while (unlikely(too_many_isolated(zone))) {
> +		/* async migration should just abort */
> +		if (!cc->sync)
> +			return ISOLATE_ABORT;
> +
>  		congestion_wait(BLK_RW_ASYNC, HZ/10);
>  
>  		if (fatal_signal_pending(current))
> -			return 0;
> +			return ISOLATE_ABORT;
>  	}
>  
>  	/* Time to isolate some pages for migration */
> @@ -358,7 +371,7 @@ static unsigned long isolate_migratepages(struct zone *zone,
>  
>  	trace_mm_compaction_isolate_migratepages(nr_scanned, nr_isolated);
>  
> -	return cc->nr_migratepages;
> +	return ISOLATE_SUCCESS;
>  }
>  
>  /*
> @@ -522,9 +535,15 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
>  		unsigned long nr_migrate, nr_remaining;
>  		int err;
>  
> -		if (!isolate_migratepages(zone, cc))
> +		switch (isolate_migratepages(zone, cc)) {
> +		case ISOLATE_ABORT:
> +			goto out;
> +		case ISOLATE_NONE:
>  			continue;
> -
> +		case ISOLATE_SUCCESS:
> +			;
> +		}
> +		
>  		nr_migrate = cc->nr_migratepages;
>  		err = migrate_pages(&cc->migratepages, compaction_alloc,
>  				(unsigned long)cc, false,
> @@ -547,6 +566,7 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
>  
>  	}
>  
> +out:
>  	/* Release free pages and check accounting */
>  	cc->nr_freepages -= release_freepages(&cc->freepages);
>  	VM_BUG_ON(cc->nr_freepages != 0);
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
