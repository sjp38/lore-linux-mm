Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 219AA6B0389
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 20:17:09 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 68so11992692pfx.1
        for <linux-mm@kvack.org>; Thu, 23 Feb 2017 17:17:09 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id y22si5777127pli.233.2017.02.23.17.17.07
        for <linux-mm@kvack.org>;
        Thu, 23 Feb 2017 17:17:08 -0800 (PST)
Date: Fri, 24 Feb 2017 10:17:06 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 1/3] mm, vmscan: fix zone balance check in
 prepare_kswapd_sleep
Message-ID: <20170224011706.GA9818@bbox>
References: <20170215092247.15989-1-mgorman@techsingularity.net>
 <20170215092247.15989-2-mgorman@techsingularity.net>
 <20170222070036.GA17962@bbox>
 <20170223150534.64fpsvlse33rj2aa@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170223150534.64fpsvlse33rj2aa@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Shantanu Goel <sgoel01@yahoo.com>, Chris Mason <clm@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

Hi Mel,

On Thu, Feb 23, 2017 at 03:05:34PM +0000, Mel Gorman wrote:
> On Wed, Feb 22, 2017 at 04:00:36PM +0900, Minchan Kim wrote:
> > > There are also more allocation stalls. One of the largest impacts was due
> > > to pages written back from kswapd context rising from 0 pages to 4516642
> > > pages during the hour the workload ran for. By and large, the patch has very
> > > bad behaviour but easily missed as the impact on a UMA machine is negligible.
> > > 
> > > This patch is included with the data in case a bisection leads to this area.
> > > This patch is also a pre-requisite for the rest of the series.
> > > 
> > > Signed-off-by: Shantanu Goel <sgoel01@yahoo.com>
> > > Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> > 
> > Hmm, I don't understand why we should bind wakeup_kcompactd to kswapd's
> > short sleep point where every eligible zones are balanced.
> > What's the correlation between them?
> > 
> 
> If kswapd is ready for a short sleep, eligible zones are balanced for
> order-0 but not necessarily the originally requested order if kswapd
> gave up reclaiming as compaction was ready to start. As kswapd is ready
> to sleep for a short period, it's a suitable time for kcompactd to decide
> if it should start working or not. There is no need for kswapd to be aware
> of kcompactd's wakeup criteria.

If all eligible zones are balanced for order-0, I agree it's good timing
because high-order alloc's ratio would be higher since kcompactd can compact
eligible zones, not that only classzone.
However, this patch breaks it as well as long time kswapd behavior which
continues to balance eligible zones for order-0.
Is it really okay now?

> 
> > Can't we wake up kcompactd once we found a zone has enough free pages
> > above high watermark like this?
> > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 26c3b405ef34..f4f0ad0e9ede 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -3346,13 +3346,6 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int alloc_order, int reclaim_o
> >  		 * that pages and compaction may succeed so reset the cache.
> >  		 */
> >  		reset_isolation_suitable(pgdat);
> > -
> > -		/*
> > -		 * We have freed the memory, now we should compact it to make
> > -		 * allocation of the requested order possible.
> > -		 */
> > -		wakeup_kcompactd(pgdat, alloc_order, classzone_idx);
> > -
> >  		remaining = schedule_timeout(HZ/10);
> >  
> >  		/*
> > @@ -3451,6 +3444,14 @@ static int kswapd(void *p)
> >  		bool ret;
> >  
> >  kswapd_try_sleep:
> > +		/*
> > +		 * We have freed the memory, now we should compact it to make
> > +		 * allocation of the requested order possible.
> > +		 */
> > +		if (alloc_order > 0 && zone_balanced(zone, reclaim_order,
> > +							classzone_idx))
> > +			wakeup_kcompactd(pgdat, alloc_order, classzone_idx);
> > +
> >  		kswapd_try_to_sleep(pgdat, alloc_order, reclaim_order,
> >  					classzone_idx);
> 
> That's functionally very similar to what happens already.  wakeup_kcompactd
> checks the order and does not wake for order-0. It also makes its own
> decisions that include zone_balanced on whether it is safe to wakeup.

Agree.

> 
> I doubt there would be any measurable difference from a patch like this
> and to my mind at least, it does not improve the readability or flow of
> the code.

However, my concern is premature kswapd sleep for order-0 which has been
long time behavior so I hope it should be documented why it's okay now.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
