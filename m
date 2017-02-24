Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9CBE56B0387
	for <linux-mm@kvack.org>; Fri, 24 Feb 2017 04:11:30 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id w37so8647573wrc.0
        for <linux-mm@kvack.org>; Fri, 24 Feb 2017 01:11:30 -0800 (PST)
Received: from outbound-smtp05.blacknight.com (outbound-smtp05.blacknight.com. [81.17.249.38])
        by mx.google.com with ESMTPS id 198si1610348wml.100.2017.02.24.01.11.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 24 Feb 2017 01:11:29 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id A9F1799351
	for <linux-mm@kvack.org>; Fri, 24 Feb 2017 09:11:28 +0000 (UTC)
Date: Fri, 24 Feb 2017 09:11:28 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 1/3] mm, vmscan: fix zone balance check in
 prepare_kswapd_sleep
Message-ID: <20170224091127.nbkmyrrnhhdrpuaa@techsingularity.net>
References: <20170215092247.15989-1-mgorman@techsingularity.net>
 <20170215092247.15989-2-mgorman@techsingularity.net>
 <20170222070036.GA17962@bbox>
 <20170223150534.64fpsvlse33rj2aa@techsingularity.net>
 <20170224011706.GA9818@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170224011706.GA9818@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Shantanu Goel <sgoel01@yahoo.com>, Chris Mason <clm@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Fri, Feb 24, 2017 at 10:17:06AM +0900, Minchan Kim wrote:
> Hi Mel,
> 
> On Thu, Feb 23, 2017 at 03:05:34PM +0000, Mel Gorman wrote:
> > On Wed, Feb 22, 2017 at 04:00:36PM +0900, Minchan Kim wrote:
> > > > There are also more allocation stalls. One of the largest impacts was due
> > > > to pages written back from kswapd context rising from 0 pages to 4516642
> > > > pages during the hour the workload ran for. By and large, the patch has very
> > > > bad behaviour but easily missed as the impact on a UMA machine is negligible.
> > > > 
> > > > This patch is included with the data in case a bisection leads to this area.
> > > > This patch is also a pre-requisite for the rest of the series.
> > > > 
> > > > Signed-off-by: Shantanu Goel <sgoel01@yahoo.com>
> > > > Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> > > 
> > > Hmm, I don't understand why we should bind wakeup_kcompactd to kswapd's
> > > short sleep point where every eligible zones are balanced.
> > > What's the correlation between them?
> > > 
> > 
> > If kswapd is ready for a short sleep, eligible zones are balanced for
> > order-0 but not necessarily the originally requested order if kswapd
> > gave up reclaiming as compaction was ready to start. As kswapd is ready
> > to sleep for a short period, it's a suitable time for kcompactd to decide
> > if it should start working or not. There is no need for kswapd to be aware
> > of kcompactd's wakeup criteria.
> 
> If all eligible zones are balanced for order-0, I agree it's good timing
> because high-order alloc's ratio would be higher since kcompactd can compact
> eligible zones, not that only classzone.
> However, this patch breaks it as well as long time kswapd behavior which
> continues to balance eligible zones for order-0.
> Is it really okay now?
> 

Reclaim stops in balance_pgdat() if any eligible zone for the requested
classzone is free. The initial sleep for kswapd is very different because
it'll sleep if all zones are balanced for order-0 which is a bad disconnect.
The way node balancing works means there is no guarantee at all that all
zones will be balanced even if there is little or no memory pressure and
one large zone in a node with multiple zones can be balanced quickly.

The short-sleep logic that kswapd uses to decide whether to go to sleep
is shortcut and it does not properly try the short sleep checking if the
high watermarks are quickly reached or not. Instead, it quickly fails the
first attempt at sleep, reenters balance_pgdat(), finds nothing to do and
rechecks sleeping based on order-0, classzone-0 which it can easily sleep
for but is *not* what kswapd was woken for in the first place.

For many allocation requests that initially woke kswapd, the impact is
marginal. kswapd sleeps early and is woken in the near future if there
is a continual stream of allocations with a risk that direct reclaim is
required. While the motivation for the patch was that kcompact is not woken
up, the existing behaviour is just wrong -- kswapd should be deciding to
sleep based on the classzone it was woken for and if possible, the order
it was woken for but the classzone is more important in the common case
for order-0 allocations.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
