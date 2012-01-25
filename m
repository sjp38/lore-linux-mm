Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 635716B004D
	for <linux-mm@kvack.org>; Wed, 25 Jan 2012 10:19:43 -0500 (EST)
Date: Wed, 25 Jan 2012 15:19:40 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH v2 -mm 2/3] mm: kswapd carefully call compaction
Message-ID: <20120125151940.GC3901@csn.ul.ie>
References: <20120124131822.4dc03524@annuminas.surriel.com>
 <20120124132243.56ce423e@annuminas.surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120124132243.56ce423e@annuminas.surriel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>

On Tue, Jan 24, 2012 at 01:22:43PM -0500, Rik van Riel wrote:
> With CONFIG_COMPACTION enabled, kswapd does not try to free
> contiguous free pages, even when it is woken for a higher order
> request.
> 
> This could be bad for eg. jumbo frame network allocations, which
> are done from interrupt context and cannot compact memory themselves.
> Higher than before allocation failure rates in the network receive
> path have been observed in kernels with compaction enabled.
> 
> Teach kswapd to defragment the memory zones in a node, but only
> if required and compaction is not deferred in a zone.
> 

We used to do something vaguely like this in the past and it was
reverted because compaction was stalling for too long. With the
merging of sync-light, this should be less of an issue but we should
be watchful of high CPU usage from kswapd with too much time spent
in memory compaction even though I recognise that compaction takes
places in kswapds exit path. In 3.3-rc1, there is a risk of high
CPU usage anyway because kswapd may be scanning over large numbers
of dirty pages it is no longer writing so care will be needed to
disguish between different high CPU usage problems.

That said, I didn't spot any obvious problems so;

Acked-by: Mel Gorman <mel@csn.ul.ie>

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
