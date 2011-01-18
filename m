Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id F073E8D003A
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 12:22:36 -0500 (EST)
Date: Tue, 18 Jan 2011 17:21:09 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [patch] mm: compaction: prevent division-by-zero during
	user-requested compaction
Message-ID: <20110118172109.GA18984@csn.ul.ie>
References: <1295370412-2645-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1295370412-2645-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 18, 2011 at 06:06:52PM +0100, Johannes Weiner wrote:
> Up until '3e7d344 mm: vmscan: reclaim order-0 and use compaction
> instead of lumpy reclaim', compaction skipped calculating the
> fragmentation index of a zone when compaction was explicitely
> requested through the procfs knob.
> 
> However, when compaction_suitable was introduced, it did not come with
> an extra check for order == -1, set on explicit compaction requests,
> and passed this order on to the fragmentation index calculation, where
> it overshifts the number of requested pages, leading to a division by
> zero.
> 
> This patch makes sure that order == -1 is recognized as the flag it is
> rather than passing it along as valid order parameter.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

It could do with a comment saying that order == -1 is expected when
compacting via /proc/sys/vm/compact_memory but otherwise;

Reviewed-by: Mel Gorman <mel@csn.ul.ie>

> ---
>  mm/compaction.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 6d592a0..114c145 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -453,6 +453,9 @@ unsigned long compaction_suitable(struct zone *zone, int order)
>  	if (!zone_watermark_ok(zone, 0, watermark, 0, 0))
>  		return COMPACT_SKIPPED;
>  
> +	if (order == -1)
> +		return COMPACT_CONTINUE;
> +
>  	/*
>  	 * fragmentation index determines if allocation failures are due to
>  	 * low memory or external fragmentation
> -- 
> 1.7.3.4
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
