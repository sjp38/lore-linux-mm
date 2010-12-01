Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id C19676B0088
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 05:28:06 -0500 (EST)
Date: Wed, 1 Dec 2010 11:27:45 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 3/7] mm: vmscan: Reclaim order-0 and use compaction
 instead of lumpy reclaim
Message-ID: <20101201102745.GL15564@cmpxchg.org>
References: <1290440635-30071-1-git-send-email-mel@csn.ul.ie>
 <1290440635-30071-4-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1290440635-30071-4-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Nov 22, 2010 at 03:43:51PM +0000, Mel Gorman wrote:
> Lumpy reclaim is disruptive. It reclaims a large number of pages and ignores
> the age of the pages it reclaims. This can incur significant stalls and
> potentially increase the number of major faults.
> 
> Compaction has reached the point where it is considered reasonably stable
> (meaning it has passed a lot of testing) and is a potential candidate for
> displacing lumpy reclaim. This patch introduces an alternative to lumpy
> reclaim whe compaction is available called reclaim/compaction. The basic
> operation is very simple - instead of selecting a contiguous range of pages
> to reclaim, a number of order-0 pages are reclaimed and then compaction is
> later by either kswapd (compact_zone_order()) or direct compaction
> (__alloc_pages_direct_compact()).
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

> @@ -286,18 +290,20 @@ static void set_lumpy_reclaim_mode(int priority, struct scan_control *sc,
>  	lumpy_mode syncmode = sync ? LUMPY_MODE_SYNC : LUMPY_MODE_ASYNC;
>  
>  	/*
> -	 * Some reclaim have alredy been failed. No worth to try synchronous
> -	 * lumpy reclaim.
> +	 * Initially assume we are entering either lumpy reclaim or
> +	 * reclaim/compaction.Depending on the order, we will either set the
> +	 * sync mode or just reclaim order-0 pages later.
>  	 */
> -	if (sync && sc->lumpy_reclaim_mode & LUMPY_MODE_SINGLE)
> -		return;
> +	if (COMPACTION_BUILD)
> +		sc->lumpy_reclaim_mode = LUMPY_MODE_COMPACTION;
> +	else
> +		sc->lumpy_reclaim_mode = LUMPY_MODE_CONTIGRECLAIM;

Isn't this a regression for !COMPACTION_BUILD in that earlier kernels
would not do sync lumpy reclaim when somebody disabled it during the
async run?

If so, it should be trivial to fix.  Aside from that

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
