Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 82A5B6B0253
	for <linux-mm@kvack.org>; Sun,  4 Dec 2016 22:06:45 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id x23so339360826pgx.6
        for <linux-mm@kvack.org>; Sun, 04 Dec 2016 19:06:45 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id 197si13012756pfy.74.2016.12.04.19.06.44
        for <linux-mm@kvack.org>;
        Sun, 04 Dec 2016 19:06:44 -0800 (PST)
Date: Mon, 5 Dec 2016 12:10:14 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 2/2] mm: page_alloc: High-order per-cpu page allocator v5
Message-ID: <20161205031013.GB1378@js1304-P5Q-DELUXE>
References: <20161202002244.18453-1-mgorman@techsingularity.net>
 <20161202002244.18453-3-mgorman@techsingularity.net>
 <20161202060346.GA21434@js1304-P5Q-DELUXE>
 <20161202082108.GB6830@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161202082108.GB6830@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>

On Fri, Dec 02, 2016 at 09:21:08AM +0100, Michal Hocko wrote:
> On Fri 02-12-16 15:03:46, Joonsoo Kim wrote:
> [...]
> > > o pcp accounting during free is now confined to free_pcppages_bulk as it's
> > >   impossible for the caller to know exactly how many pages were freed.
> > >   Due to the high-order caches, the number of pages drained for a request
> > >   is no longer precise.
> > > 
> > > o The high watermark for per-cpu pages is increased to reduce the probability
> > >   that a single refill causes a drain on the next free.
> [...]
> > I guess that this patch would cause following problems.
> > 
> > 1. If pcp->batch is too small, high order page will not be freed
> > easily and survive longer. Think about following situation.
> > 
> > Batch count: 7
> > MIGRATE_UNMOVABLE -> MIGRATE_MOVABLE -> MIGRATE_RECLAIMABLE -> order 1
> > -> order 2...
> > 
> > free count: 1 + 1 + 1 + 2 + 4 = 9
> > so order 3 would not be freed.
> 
> I guess the second paragraph above in the changelog tries to clarify
> that...

It doesn't perfectly clarify my concern. This is a different problem.

>  
> > 2. And, It seems that this logic penalties high order pages. One free
> > to high order page means 1 << order pages free rather than just
> > one page free. This logic do round-robin to choose the target page so
> > amount of freed page will be different by the order.
> 
> Yes this is indeed possible. The first paragraph above mentions this
> problem.

Yes, it is mentioned simply but we cannot easily notice that the above
penalty for high order page is there.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
