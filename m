Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 83DC76B13F7
	for <linux-mm@kvack.org>; Fri, 10 Feb 2012 10:36:50 -0500 (EST)
Received: from euspt1 (mailout2.w1.samsung.com [210.118.77.12])
 by mailout2.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LZ6006FFOPCVA@mailout2.w1.samsung.com> for linux-mm@kvack.org;
 Fri, 10 Feb 2012 15:36:48 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LZ600K4GOPCXJ@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 10 Feb 2012 15:36:48 +0000 (GMT)
Date: Fri, 10 Feb 2012 16:36:43 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCH 11/15] mm: trigger page reclaim in alloc_contig_range() to
 stabilize watermarks
In-reply-to: <20120210111913.GP5796@csn.ul.ie>
Message-id: <00d101cce809$cabaa100$602fe300$%szyprowski@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-language: pl
Content-transfer-encoding: 7BIT
References: <1328271538-14502-1-git-send-email-m.szyprowski@samsung.com>
 <1328271538-14502-12-git-send-email-m.szyprowski@samsung.com>
 <20120203140428.GG5796@csn.ul.ie>
 <000001cce674$64bb67e0$2e3237a0$%szyprowski@samsung.com>
 <20120210111913.GP5796@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Mel Gorman' <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, 'Michal Nazarewicz' <mina86@mina86.com>, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Russell King' <linux@arm.linux.org.uk>, 'Andrew Morton' <akpm@linux-foundation.org>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, 'Daniel Walker' <dwalker@codeaurora.org>, 'Arnd Bergmann' <arnd@arndb.de>, 'Jesse Barker' <jesse.barker@linaro.org>, 'Jonathan Corbet' <corbet@lwn.net>, 'Shariq Hasnain' <shariq.hasnain@linaro.org>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, 'Dave Hansen' <dave@linux.vnet.ibm.com>, 'Benjamin Gaignard' <benjamin.gaignard@linaro.org>, 'Rob Clark' <rob.clark@linaro.org>, 'Ohad Ben-Cohen' <ohad@wizery.com>

Hello,

On Friday, February 10, 2012 12:19 PM Mel Gorman wrote:

> On Wed, Feb 08, 2012 at 04:14:46PM +0100, Marek Szyprowski wrote:
> > > > <SNIP>
> > > > +static int __reclaim_pages(struct zone *zone, gfp_t gfp_mask, int count)
> > > > +{
> > > > +	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
> > > > +	struct zonelist *zonelist = node_zonelist(0, gfp_mask);
> > > > +	int did_some_progress = 0;
> > > > +	int order = 1;
> > > > +	unsigned long watermark;
> > > > +
> > > > +	/*
> > > > +	 * Increase level of watermarks to force kswapd do his job
> > > > +	 * to stabilize at new watermark level.
> > > > +	 */
> > > > +	min_free_kbytes += count * PAGE_SIZE / 1024;
> > >
> > > There is a risk of overflow here although it is incredibly
> > > small. Still, a potentially nicer way of doing this was
> > >
> > > count << (PAGE_SHIFT - 10)
> > >
> > > > +	setup_per_zone_wmarks();
> > > > +
> > >
> > > Nothing prevents two or more processes updating the wmarks at the same
> > > time which is racy and unpredictable. Today it is not much of a problem
> > > but CMA makes this path hotter than it was and you may see weirdness
> > > if two processes are updating zonelists at the same time. Swap-over-NFS
> > > actually starts with a patch that serialises setup_per_zone_wmarks()
> > >
> > > You also potentially have a BIG problem here if this happens
> > >
> > > min_free_kbytes = 32768
> > > Process a: min_free_kbytes  += 65536
> > > Process a: start direct reclaim
> > > echo 16374 > /proc/sys/vm/min_free_kbytes
> > > Process a: exit direct_reclaim
> > > Process a: min_free_kbytes -= 65536
> > >
> > > min_free_kbytes now wraps negative and the machine hangs.
> > >
> > > The damage is confined to CMA though so I am not going to lose sleep
> > > over it but you might want to consider at least preventing parallel
> > > updates to min_free_kbytes from proc.
> >
> > Right. This approach was definitely too hacky. What do you think about replacing
> > it with the following code (I assume that setup_per_zone_wmarks() serialization
> > patch will be merged anyway so I skipped it here):
> >
> 
> It's part of a larger series and the rest of that series is
> controversial. That single patch can be split out obviously so feel free
> to add it to your series and stick your Signed-off-by on the end of it.

Ok, I will grab it from that series.

> > diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> > index 82f4fa5..bb9ae41 100644
> > --- a/include/linux/mmzone.h
> > +++ b/include/linux/mmzone.h
> > @@ -371,6 +371,13 @@ struct zone {
> >         /* see spanned/present_pages for more description */
> >         seqlock_t               span_seqlock;
> >  #endif
> > +#ifdef CONFIG_CMA
> > +       /*
> > +        * CMA needs to increase watermark levels during the allocation
> > +        * process to make sure that the system is not starved.
> > +        */
> > +       unsigned long           min_cma_pages;
> > +#endif
> >         struct free_area        free_area[MAX_ORDER];
> >
> >  #ifndef CONFIG_SPARSEMEM
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 824fb37..1ca52f0 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -5044,6 +5044,11 @@ void setup_per_zone_wmarks(void)
> >
> >                 zone->watermark[WMARK_LOW]  = min_wmark_pages(zone) + (tmp >> 2);
> >                 zone->watermark[WMARK_HIGH] = min_wmark_pages(zone) + (tmp >> 1);
> > +#ifdef CONFIG_CMA
> > +               zone->watermark[WMARK_MIN] += zone->min_cma_pages;
> > +               zone->watermark[WMARK_LOW] += zone->min_cma_pages;
> > +               zone->watermark[WMARK_HIGH] += zone->min_cma_pages;
> > +#endif
> >                 setup_zone_migrate_reserve(zone);
> >                 spin_unlock_irqrestore(&zone->lock, flags);
> >         }
> 
> This is better in that it is not vunerable to parallel updates of
> min_free_kbytes. It would be slightly tidier to introduce something
> like cma_wmark_pages() that returns min_cma_pages if CONFIG_CMA and 0
> otherwise. Use the helper to get right of this ifdef CONFIG_CMA within
> setup_per_zone_wmarks().

Thanks for the hint. I will submit this change soon.
 
> You'll still have the problem of kswapd not taking CMA pages properly into
> account when deciding whether to reclaim or not though.

This will only affect CMA clients, I hope we can fix this later once the patches
get merged. I would really like to get it into v3.4, what means that it should be
tested in next asap.

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
