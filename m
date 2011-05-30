Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id BD5216B0012
	for <linux-mm@kvack.org>; Mon, 30 May 2011 11:16:41 -0400 (EDT)
Received: by pzk4 with SMTP id 4so2047614pzk.14
        for <linux-mm@kvack.org>; Mon, 30 May 2011 08:16:40 -0700 (PDT)
Date: Tue, 31 May 2011 00:16:33 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH] mm: fix special case -1 order check in compact_finished
Message-ID: <20110530151633.GB1505@barrios-laptop>
References: <20110530123831.GG20166@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110530123831.GG20166@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Sorry for breaking thread.
I resend.

On Mon, May 30, 2011 at 02:38:31PM +0200, Michal Hocko wrote:
> 56de7263 (mm: compaction: direct compact when a high-order allocation
> fails) introduced a check for cc->order == -1 in compact_finished. We
> should continue compacting in that case because the request came from
> userspace and there is no particular order to compact for.
> 
> The check is, however, done after zone_watermark_ok which uses order as
> a right hand argument for shifts. Not only watermark check is pointless
> if we can break out without it but it also uses 1 << -1 which is not
> well defined (at least from C standard). Let's move the -1 check above
> zone_watermark_ok.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> Cc: Mel Gorman <mgorman@suse.de>
> ---
>  compaction.c |   14 +++++++-------
>  1 file changed, 7 insertions(+), 7 deletions(-)
> Index: linus_tree/mm/compaction.c
> ===================================================================
> --- linus_tree.orig/mm/compaction.c	2011-05-30 14:19:58.000000000 +0200
> +++ linus_tree/mm/compaction.c	2011-05-30 14:20:40.000000000 +0200
> @@ -420,13 +420,6 @@ static int compact_finished(struct zone
>  	if (cc->free_pfn <= cc->migrate_pfn)
>  		return COMPACT_COMPLETE;
>  
> -	/* Compaction run is not finished if the watermark is not met */
> -	watermark = low_wmark_pages(zone);
> -	watermark += (1 << cc->order);
> -
> -	if (!zone_watermark_ok(zone, cc->order, watermark, 0, 0))
> -		return COMPACT_CONTINUE;
> -
>  	/*
>  	 * order == -1 is expected when compacting via
>  	 * /proc/sys/vm/compact_memory
> @@ -434,6 +427,13 @@ static int compact_finished(struct zone
>  	if (cc->order == -1)
>  		return COMPACT_CONTINUE;
>  
> +	/* Compaction run is not finished if the watermark is not met */
> +	watermark = low_wmark_pages(zone);
> +	watermark += (1 << cc->order);
> +
> +	if (!zone_watermark_ok(zone, cc->order, watermark, 0, 0))
> +		return COMPACT_CONTINUE;
> +
>  	/* Direct compactor: Is a suitable page free? */
>  	for (order = cc->order; order < MAX_ORDER; order++) {
>  		/* Job done if page is free of the right migratetype */

It looks good to me.
Let's think about another place, compaction_suitable.
It has same problem so we can move the check right before zone_watermark_ok.
As I look it more, I thought we need free pages for compaction so we would 
be better to give up early if we can't get enough free pages. But I changed
my mind. It's a totally user request and we can get free pages in migration
progress(ex, other big memory hogger might free his big rss). 
So my conclusion is that we should do *best effort* than early give up.
If you agree with me, how about resending patch with compaction_suitable fix?


> -- 
> Michal Hocko
> SUSE Labs
> SUSE LINUX s.r.o.
> Lihovarska 1060/12
> 190 00 Praha 9    
> Czech Republic
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
