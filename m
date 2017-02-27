Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id C4BC36B0038
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 01:16:50 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id t184so163410165pgt.1
        for <linux-mm@kvack.org>; Sun, 26 Feb 2017 22:16:50 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id v1si14328681plk.19.2017.02.26.22.16.49
        for <linux-mm@kvack.org>;
        Sun, 26 Feb 2017 22:16:49 -0800 (PST)
Date: Mon, 27 Feb 2017 15:16:47 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 1/3] mm, vmscan: fix zone balance check in
 prepare_kswapd_sleep
Message-ID: <20170227061647.GA23612@bbox>
References: <20170215092247.15989-1-mgorman@techsingularity.net>
 <20170215092247.15989-2-mgorman@techsingularity.net>
 <20170222070036.GA17962@bbox>
 <20170223150534.64fpsvlse33rj2aa@techsingularity.net>
 <20170224011706.GA9818@bbox>
 <20170224091127.nbkmyrrnhhdrpuaa@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170224091127.nbkmyrrnhhdrpuaa@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Shantanu Goel <sgoel01@yahoo.com>, Chris Mason <clm@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

Hi Mel,

On Fri, Feb 24, 2017 at 09:11:28AM +0000, Mel Gorman wrote:
> On Fri, Feb 24, 2017 at 10:17:06AM +0900, Minchan Kim wrote:
> > Hi Mel,
> > 
> > On Thu, Feb 23, 2017 at 03:05:34PM +0000, Mel Gorman wrote:
> > > On Wed, Feb 22, 2017 at 04:00:36PM +0900, Minchan Kim wrote:
> > > > > There are also more allocation stalls. One of the largest impacts was due
> > > > > to pages written back from kswapd context rising from 0 pages to 4516642
> > > > > pages during the hour the workload ran for. By and large, the patch has very
> > > > > bad behaviour but easily missed as the impact on a UMA machine is negligible.
> > > > > 
> > > > > This patch is included with the data in case a bisection leads to this area.
> > > > > This patch is also a pre-requisite for the rest of the series.
> > > > > 
> > > > > Signed-off-by: Shantanu Goel <sgoel01@yahoo.com>
> > > > > Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> > > > 
> > > > Hmm, I don't understand why we should bind wakeup_kcompactd to kswapd's
> > > > short sleep point where every eligible zones are balanced.
> > > > What's the correlation between them?
> > > > 
> > > 
> > > If kswapd is ready for a short sleep, eligible zones are balanced for
> > > order-0 but not necessarily the originally requested order if kswapd
> > > gave up reclaiming as compaction was ready to start. As kswapd is ready
> > > to sleep for a short period, it's a suitable time for kcompactd to decide
> > > if it should start working or not. There is no need for kswapd to be aware
> > > of kcompactd's wakeup criteria.
> > 
> > If all eligible zones are balanced for order-0, I agree it's good timing
> > because high-order alloc's ratio would be higher since kcompactd can compact
> > eligible zones, not that only classzone.
> > However, this patch breaks it as well as long time kswapd behavior which
> > continues to balance eligible zones for order-0.
> > Is it really okay now?
> > 
> 
> Reclaim stops in balance_pgdat() if any eligible zone for the requested
> classzone is free. The initial sleep for kswapd is very different because
> it'll sleep if all zones are balanced for order-0 which is a bad disconnect.
> The way node balancing works means there is no guarantee at all that all
> zones will be balanced even if there is little or no memory pressure and
> one large zone in a node with multiple zones can be balanced quickly.

Indeed but it would tip toward direct relcaim more so it could make more
failure for allocation relies on kswapd like atomic allocation
However, if VM balance all of zones for order-0, it would make excessive
reclaim with node-based LRU unlike zone-based, which is bad, too.

> 
> The short-sleep logic that kswapd uses to decide whether to go to sleep
> is shortcut and it does not properly try the short sleep checking if the
> high watermarks are quickly reached or not. Instead, it quickly fails the
> first attempt at sleep, reenters balance_pgdat(), finds nothing to do and
> rechecks sleeping based on order-0, classzone-0 which it can easily sleep
> for but is *not* what kswapd was woken for in the first place.
> 
> For many allocation requests that initially woke kswapd, the impact is
> marginal. kswapd sleeps early and is woken in the near future if there
> is a continual stream of allocations with a risk that direct reclaim is
> required. While the motivation for the patch was that kcompact is not woken
> up, the existing behaviour is just wrong -- kswapd should be deciding to
> sleep based on the classzone it was woken for and if possible, the order
> it was woken for but the classzone is more important in the common case
> for order-0 allocations.

I agree but I think it's rather risky to paper over order-0 zone-balancing
problem by kcompactd missing problem so at least, it should be documented.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
