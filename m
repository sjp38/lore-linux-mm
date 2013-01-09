Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 19B9C6B005D
	for <linux-mm@kvack.org>; Wed,  9 Jan 2013 16:29:08 -0500 (EST)
Date: Wed, 9 Jan 2013 21:29:07 +0000
From: Eric Wong <normalperson@yhbt.net>
Subject: Re: ppoll() stuck on POLLIN while TCP peer is sending
Message-ID: <20130109212907.GA27361@dcvr.yhbt.net>
References: <20121228014503.GA5017@dcvr.yhbt.net>
 <20130102200848.GA4500@dcvr.yhbt.net>
 <20130104160148.GB3885@suse.de>
 <20130106120700.GA24671@dcvr.yhbt.net>
 <20130107122516.GC3885@suse.de>
 <20130107223850.GA21311@dcvr.yhbt.net>
 <20130108224313.GA13304@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130108224313.GA13304@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

Mel Gorman <mgorman@suse.de> wrote:
> When I looked at it for long enough I found a number of problems. Most
> affect timing but two serious issues are in there. One affects how long
> kswapd spends compacting versus reclaiming and the other increases lock
> contention meaning that async compaction can abort early. Both are serious
> and could explain why a driver would fail high-order allocations.
> 
> Please try the following patch. However, even if it works the benefit of
> capture may be so marginal that partially reverting it and simplifying
> compaction.c is the better decision.

Btw, I'm still testing this patch with the "page->pfemalloc = false"
change on top of it.

> diff --git a/mm/compaction.c b/mm/compaction.c
> index 6b807e4..03c82c0 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -857,7 +857,8 @@ static int compact_finished(struct zone *zone,
>  	} else {
>  		unsigned int order;
>  		for (order = cc->order; order < MAX_ORDER; order++) {
> -			struct free_area *area = &zone->free_area[cc->order];
> +			struct free_area *area = &zone->free_area[order];

I noticed something like this hunk wasn't in your latest partial revert
(<20130109135010.GB13475@suse.de>)
I admit I don't understand this code, but this jumped out at me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
