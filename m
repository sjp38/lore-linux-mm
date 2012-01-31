Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 46D476B002C
	for <linux-mm@kvack.org>; Tue, 31 Jan 2012 12:15:10 -0500 (EST)
Received: from euspt2 (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LYO00CC9AL8A4@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Tue, 31 Jan 2012 17:15:08 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LYO0051IAL8TI@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 31 Jan 2012 17:15:08 +0000 (GMT)
Date: Tue, 31 Jan 2012 18:15:04 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCH 11/15] mm: trigger page reclaim in alloc_contig_range() to
 stabilize watermarks
In-reply-to: <20120130130540.GN25268@csn.ul.ie>
Message-id: <023001cce03b$dfddf760$9f99e620$%szyprowski@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-language: pl
Content-transfer-encoding: 7BIT
References: <1327568457-27734-1-git-send-email-m.szyprowski@samsung.com>
 <1327568457-27734-12-git-send-email-m.szyprowski@samsung.com>
 <20120130130540.GN25268@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Mel Gorman' <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, 'Michal Nazarewicz' <mina86@mina86.com>, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Russell King' <linux@arm.linux.org.uk>, 'Andrew Morton' <akpm@linux-foundation.org>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, 'Daniel Walker' <dwalker@codeaurora.org>, 'Arnd Bergmann' <arnd@arndb.de>, 'Jesse Barker' <jesse.barker@linaro.org>, 'Jonathan Corbet' <corbet@lwn.net>, 'Shariq Hasnain' <shariq.hasnain@linaro.org>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, 'Dave Hansen' <dave@linux.vnet.ibm.com>, 'Benjamin Gaignard' <benjamin.gaignard@linaro.org>

Hello,

On Monday, January 30, 2012 2:06 PM Mel Gorman wrote:

> On Thu, Jan 26, 2012 at 10:00:53AM +0100, Marek Szyprowski wrote:
> > alloc_contig_range() performs memory allocation so it also should keep
> > track on keeping the correct level of memory watermarks. This commit adds
> > a call to *_slowpath style reclaim to grab enough pages to make sure that
> > the final collection of contiguous pages from freelists will not starve
> > the system.
> >
> > Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> > Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> > CC: Michal Nazarewicz <mina86@mina86.com>
> > ---
> >  mm/page_alloc.c |   36 ++++++++++++++++++++++++++++++++++++
> >  1 files changed, 36 insertions(+), 0 deletions(-)
> >
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index e35d06b..05eaa82 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -5613,6 +5613,34 @@ static int __alloc_contig_migrate_range(unsigned long start, unsigned
> long end)
> >  	return ret;
> >  }
> >
> > +/*
> > + * Trigger memory pressure bump to reclaim some pages in order to be able to
> > + * allocate 'count' pages in single page units. Does similar work as
> > + *__alloc_pages_slowpath() function.
> > + */
> > +static int __reclaim_pages(struct zone *zone, gfp_t gfp_mask, int count)
> > +{
> > +	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
> > +	struct zonelist *zonelist = node_zonelist(0, gfp_mask);
> > +	int did_some_progress = 0;
> > +	int order = 1;
> > +	unsigned long watermark;
> > +
> > +	/* Obey watermarks as if the page was being allocated */
> > +	watermark = low_wmark_pages(zone) + count;
> > +	while (!zone_watermark_ok(zone, 0, watermark, 0, 0)) {
> > +		wake_all_kswapd(order, zonelist, high_zoneidx, zone_idx(zone));
> > +
> > +		did_some_progress = __perform_reclaim(gfp_mask, order, zonelist,
> > +						      NULL);
> > +		if (!did_some_progress) {
> > +			/* Exhausted what can be done so it's blamo time */
> > +			out_of_memory(zonelist, gfp_mask, order, NULL);
> > +		}
> 
> There are three problems here
> 
> 1. CMA can trigger the OOM killer.
> 
> That seems like overkill to me but as I do not know the consequences
> of CMA failing, it's your call.

This behavior is intended, we agreed that the contiguous allocations should
have higher priority than others.

> 2. You cannot guarantee that try_to_free_pages will free pages from the
>    zone you care about or that kswapd will do anything
> 
> You check the watermarks and take into account the size of the pending
> CMA allocation. kswapd in vmscan.c on the other hand will simply check
> the watermarks and probably go back to sleep. You should be aware of
> this in case you ever get bugs that CMA takes too long and that it
> appears to be stuck in this loop with kswapd staying asleep.

Right, I experienced this problem today. The simplest workaround I've 
found is to adjust watermark before calling kswapd, but I'm not sure 
that increasing min_free_kbytes and calling setup_per_zone_wmarks() is
the nicest approach for it.

> 3. You reclaim from zones other than your target zone
> 
> try_to_free_pages is not necessarily going to free pages in the
> zone you are checking for. It'll work on ARM in many cases because
> there will be only one zone but on other arches, this logic will
> be problematic and will potentially livelock. You need to pass in
> a zonelist that only contains the zone that CMA cares about. If it
> cannot reclaim, did_some_progress == 0 and it'll exit. Otherwise
> there is a possibility that this will loop forever reclaiming pages
> from the wrong zones.

Right. I tested it on a system with only one zone, so I never experienced 
such problem. For the first version I think we might assume that the buffer
allocated by alloc_contig_range() must fit the single zone. I will add some
comments about it. Later we can extend it for more advanced cases. 

> I won't ack this particular patch but I am not going to insist that
> you fix these prior to merging either. If you leave problem 3 as it
> is, I would really like to see a comment explaning the problem for
> future users of CMA on other arches (if they exist).

I will add more comments about the issues You have pointed out to make
the life easier for other arch developers.

Best regards
-- 
Marek Szyprowski
Samsung Poland R&D Center



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
