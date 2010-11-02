Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 5805C6B009F
	for <linux-mm@kvack.org>; Mon,  1 Nov 2010 22:05:14 -0400 (EDT)
Date: Tue, 2 Nov 2010 10:04:32 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 4/7] vmscan: narrowing synchrounous lumply reclaim
 condition
Message-ID: <20101102020432.GA4829@localhost>
References: <20100805150624.31B7.A69D9226@jp.fujitsu.com>
 <20100805151341.31C3.A69D9226@jp.fujitsu.com>
 <20101027164138.GD29304@random.random>
 <20101027171643.GA4896@csn.ul.ie>
 <20101027180333.GE29304@random.random>
 <20101028102048.GD4896@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101028102048.GD4896@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

> To make compaction a full replacement for lumpy, reclaim would have to
> know how to reclaim order-9 worth of pages and then compact properly.
> It's not setup for this and a naive algorithm would spend a lot of time
> in the compaction scanning code (which is pretty inefficient). A possible
> alternative would be to lumpy-compact i.e. select a page from the LRU and
> move all pages around it elsewhere. Again, this is not what we are currently
> doing but it's a direction that could be taken.

Agreed. The more lumpy reclaim, the more young pages being wrongly
evicted. THP could trigger lumpy reclaims heavily, that's why Andreas
need to disable it. Lumpy migration looks much better.  Compaction
looks like some pre/batched lumpy-migration. We may also do on demand
lumpy migration in future.

> +static void set_lumpy_reclaim_mode(int priority, struct scan_control *sc,
> +                                bool sync)
> +{
> +     enum lumpy_mode mode = sync ? LUMPY_MODE_SYNC : LUMPY_MODE_ASYNC;
> +
> +     /*
> +      * Some reclaim have alredy been failed. No worth to try synchronous
> +      * lumpy reclaim.
> +      */
> +     if (sync && sc->lumpy_reclaim_mode == LUMPY_MODE_NONE)
> +             return;
> +
> +     /*
> +      * If we need a large contiguous chunk of memory, or have
> +      * trouble getting a small set of contiguous pages, we
> +      * will reclaim both active and inactive pages.
> +      */
> +     if (sc->order > PAGE_ALLOC_COSTLY_ORDER)
> +             sc->lumpy_reclaim_mode = mode;
> +     else if (sc->order && priority < DEF_PRIORITY - 2)
> +             sc->lumpy_reclaim_mode = mode;
> +     else
> +             sc->lumpy_reclaim_mode = LUMPY_MODE_NONE;
> +}

Andrea, I don't see the conflicts in doing lumpy reclaim improvements
in parallel to compaction and THP. If lumpy reclaim hurts THP, it can
be trivially disabled in your tree for huge page order allocations?

+       if (sc->order > 9)
+               sc->lumpy_reclaim_mode = LUMPY_MODE_NONE;

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
