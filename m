Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id C60BD6B0068
	for <linux-mm@kvack.org>; Wed,  8 Aug 2012 04:51:16 -0400 (EDT)
Date: Wed, 8 Aug 2012 09:51:12 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/6] mm: vmscan: Scale number of pages reclaimed by
 reclaim/compaction based on failures
Message-ID: <20120808085112.GJ29814@suse.de>
References: <1344342677-5845-1-git-send-email-mgorman@suse.de>
 <1344342677-5845-3-git-send-email-mgorman@suse.de>
 <20120808014824.GB4247@bbox>
 <20120808075526.GI29814@suse.de>
 <20120808082738.GF4247@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120808082738.GF4247@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Jim Schutt <jaschut@sandia.gov>, LKML <linux-kernel@vger.kernel.org>

On Wed, Aug 08, 2012 at 05:27:38PM +0900, Minchan Kim wrote:
> On Wed, Aug 08, 2012 at 08:55:26AM +0100, Mel Gorman wrote:
> > On Wed, Aug 08, 2012 at 10:48:24AM +0900, Minchan Kim wrote:
> > > Hi Mel,
> > > 
> > > Just out of curiosity.
> > > What's the problem did you see? (ie, What's the problem do this patch solve?)
> > 
> > Everythign in this series is related to the problem in the leader - high
> > order allocation success rates are lower. This patch increases the success
> > rates when allocating under load.
> > 
> > > AFAIUC, it seem to solve consecutive allocation success ratio through
> > > getting several free pageblocks all at once in a process/kswapd
> > > reclaim context. Right?
> > 
> > Only pageblocks if it is order-9 on x86, it reclaims an amount that depends
> > on an allocation size. This only happens during reclaim/compaction context
> > when we know that a high-order allocation has recently failed. The objective
> > is to reclaim enough order-0 pages so that compaction can succeed again.
> 
> Your patch increases the number of pages to be reclaimed with considering
> the number of fail case during deferring period and your test proved it's
> really good. Without your patch, why can't VM reclaim enough pages?

It could reclaim enough pages but it doesn't. nr_to_reclaim is
SWAP_CLUSTER_MAX and that gets short-cutted in direct reclaim at least
by 

                if (sc->nr_reclaimed >= sc->nr_to_reclaim)
                        goto out;

I could set nr_to_reclaim in try_to_free_pages() of course and drive
it from there but that's just different, not better. If driven from
do_try_to_free_pages(), it is also possible that priorities will rise.
When they reach DEF_PRIORITY-2, it will also start stalling and setting
pages for immediate reclaim which is more disruptive than not desirable
in this case. That is a more wide-reaching change than I would expect for
this problem and could cause another regression related to THP requests
causing interactive jitter.

> Other processes steal the pages reclaimed?

Or the page it reclaimed were in pageblocks that could not be used.

> Why I ask a question is that I want to know what's the problem at current
> VM.
> 

We cannot reliably tell in advance whether compaction is going to succeed
in the future without doing a full scan of the zone which would be both
very heavy and race with any allocation requests. Compaction needs free
pages to succeed so the intention is to scale the number of pages reclaimed
with the number of recent compaction failures.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
