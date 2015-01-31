Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f180.google.com (mail-qc0-f180.google.com [209.85.216.180])
	by kanga.kvack.org (Postfix) with ESMTP id C473F6B0032
	for <linux-mm@kvack.org>; Sat, 31 Jan 2015 02:50:00 -0500 (EST)
Received: by mail-qc0-f180.google.com with SMTP id r5so23841506qcx.11
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 23:50:00 -0800 (PST)
Received: from BLU004-OMC2S20.hotmail.com (blu004-omc2s20.hotmail.com. [65.55.111.95])
        by mx.google.com with ESMTPS id v109si17154232qge.78.2015.01.30.23.49.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 30 Jan 2015 23:49:59 -0800 (PST)
Message-ID: <BLU436-SMTP105DFBF63EAF672F3272FFA833E0@phx.gbl>
Date: Sat, 31 Jan 2015 15:49:38 +0800
From: Zhang Yanfei <zhangyanfei.ok@hotmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 2/4] mm/compaction: stop the isolation when we isolate
 enough freepage
References: <1422621252-29859-1-git-send-email-iamjoonsoo.kim@lge.com> <1422621252-29859-3-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1422621252-29859-3-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Hello,

At 2015/1/30 20:34, Joonsoo Kim wrote:
> From: Joonsoo <iamjoonsoo.kim@lge.com>
> 
> Currently, freepage isolation in one pageblock doesn't consider how many
> freepages we isolate. When I traced flow of compaction, compaction
> sometimes isolates more than 256 freepages to migrate just 32 pages.
> 
> In this patch, freepage isolation is stopped at the point that we
> have more isolated freepage than isolated page for migration. This
> results in slowing down free page scanner and make compaction success
> rate higher.
> 
> stress-highalloc test in mmtests with non movable order 7 allocation shows
> increase of compaction success rate.
> 
> Compaction success rate (Compaction success * 100 / Compaction stalls, %)
> 27.13 : 31.82
> 
> pfn where both scanners meets on compaction complete
> (separate test due to enormous tracepoint buffer)
> (zone_start=4096, zone_end=1048576)
> 586034 : 654378
> 
> In fact, I didn't fully understand why this patch results in such good
> result. There was a guess that not used freepages are released to pcp list
> and on next compaction trial we won't isolate them again so compaction
> success rate would decrease. To prevent this effect, I tested with adding
> pcp drain code on release_freepages(), but, it has no good effect.
> 
> Anyway, this patch reduces waste time to isolate unneeded freepages so
> seems reasonable.

Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

IMHO, the patch making the free scanner move slower makes both scanners
meet further. Before this patch, if we isolate too many free pages and even 
after we release the unneeded free pages later the free scanner still already
be there and will be moved forward again next time -- the free scanner just
cannot be moved back to grab the free pages we released before no matter where
the free pages in, pcp or buddy. 

> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>  mm/compaction.c | 17 ++++++++++-------
>  1 file changed, 10 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 4954e19..782772d 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -490,6 +490,13 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
>  
>  		/* If a page was split, advance to the end of it */
>  		if (isolated) {
> +			cc->nr_freepages += isolated;
> +			if (!strict &&
> +				cc->nr_migratepages <= cc->nr_freepages) {
> +				blockpfn += isolated;
> +				break;
> +			}
> +
>  			blockpfn += isolated - 1;
>  			cursor += isolated - 1;
>  			continue;
> @@ -899,7 +906,6 @@ static void isolate_freepages(struct compact_control *cc)
>  	unsigned long isolate_start_pfn; /* exact pfn we start at */
>  	unsigned long block_end_pfn;	/* end of current pageblock */
>  	unsigned long low_pfn;	     /* lowest pfn scanner is able to scan */
> -	int nr_freepages = cc->nr_freepages;
>  	struct list_head *freelist = &cc->freepages;
>  
>  	/*
> @@ -924,11 +930,11 @@ static void isolate_freepages(struct compact_control *cc)
>  	 * pages on cc->migratepages. We stop searching if the migrate
>  	 * and free page scanners meet or enough free pages are isolated.
>  	 */
> -	for (; block_start_pfn >= low_pfn && cc->nr_migratepages > nr_freepages;
> +	for (; block_start_pfn >= low_pfn &&
> +			cc->nr_migratepages > cc->nr_freepages;
>  				block_end_pfn = block_start_pfn,
>  				block_start_pfn -= pageblock_nr_pages,
>  				isolate_start_pfn = block_start_pfn) {
> -		unsigned long isolated;
>  
>  		/*
>  		 * This can iterate a massively long zone without finding any
> @@ -953,9 +959,8 @@ static void isolate_freepages(struct compact_control *cc)
>  			continue;
>  
>  		/* Found a block suitable for isolating free pages from. */
> -		isolated = isolate_freepages_block(cc, &isolate_start_pfn,
> +		isolate_freepages_block(cc, &isolate_start_pfn,
>  					block_end_pfn, freelist, false);
> -		nr_freepages += isolated;
>  
>  		/*
>  		 * Remember where the free scanner should restart next time,
> @@ -987,8 +992,6 @@ static void isolate_freepages(struct compact_control *cc)
>  	 */
>  	if (block_start_pfn < low_pfn)
>  		cc->free_pfn = cc->migrate_pfn;
> -
> -	cc->nr_freepages = nr_freepages;
>  }
>  
>  /*
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
