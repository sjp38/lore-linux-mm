Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id C70BC6B0274
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 00:30:16 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id py6so329409pab.0
        for <linux-mm@kvack.org>; Tue, 25 Oct 2016 21:30:16 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id g6si232498pag.264.2016.10.25.21.30.15
        for <linux-mm@kvack.org>;
        Tue, 25 Oct 2016 21:30:15 -0700 (PDT)
Date: Wed, 26 Oct 2016 13:31:24 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v6 3/6] mm/cma: populate ZONE_CMA
Message-ID: <20161026043123.GA2901@js1304-P5Q-DELUXE>
References: <1476414196-3514-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1476414196-3514-4-git-send-email-iamjoonsoo.kim@lge.com>
 <33f0a8f3-38d1-e527-f71f-839afe0b2ed9@suse.cz>
 <20161018082730.GA20442@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161018082730.GA20442@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Oct 18, 2016 at 05:27:30PM +0900, Joonsoo Kim wrote:
> On Tue, Oct 18, 2016 at 09:42:57AM +0200, Vlastimil Babka wrote:
> > On 10/14/2016 05:03 AM, js1304@gmail.com wrote:
> > >@@ -145,6 +145,35 @@ static int __init cma_activate_area(struct cma *cma)
> > > static int __init cma_init_reserved_areas(void)
> > > {
> > > 	int i;
> > >+	struct zone *zone;
> > >+	pg_data_t *pgdat;
> > >+
> > >+	if (!cma_area_count)
> > >+		return 0;
> > >+
> > >+	for_each_online_pgdat(pgdat) {
> > >+		unsigned long start_pfn = UINT_MAX, end_pfn = 0;
> > >+
> > >+		for (i = 0; i < cma_area_count; i++) {
> > >+			if (pfn_to_nid(cma_areas[i].base_pfn) !=
> > >+				pgdat->node_id)
> > >+				continue;
> > >+
> > >+			start_pfn = min(start_pfn, cma_areas[i].base_pfn);
> > >+			end_pfn = max(end_pfn, cma_areas[i].base_pfn +
> > >+						cma_areas[i].count);
> > >+		}
> > >+
> > >+		if (!end_pfn)
> > >+			continue;
> > >+
> > >+		zone = &pgdat->node_zones[ZONE_CMA];
> > >+
> > >+		/* ZONE_CMA doesn't need to exceed CMA region */
> > >+		zone->zone_start_pfn = max(zone->zone_start_pfn, start_pfn);
> > >+		zone->spanned_pages = min(zone_end_pfn(zone), end_pfn) -
> > >+					zone->zone_start_pfn;
> > 
> > Hmm, do the max/min here work as intended? IIUC the initial
> 
> Yeap.
> 
> > zone_start_pfn is UINT_MAX and zone->spanned_pages is 1? So at least
> > the max/min should be swapped?
> 
> No. CMA zone's start/end pfn are updated as node's start/end pfn.
> 
> > Also the zone_end_pfn(zone) on the second line already sees the
> > changes to zone->zone_start_pfn in the first line, so it's kind of a
> > mess. You should probably cache zone_end_pfn() to a temporary
> > variable before changing zone_start_pfn.
> 
> You're right although it doesn't cause any problem. I look at the code
> again and find that max/min isn't needed. Calculated start/end pfn
> should be inbetween node's start/end pfn so max(zone->zone_start_pfn,
> start_pfn) will return start_pfn and messed up min(zone_end_pfn(zone),
> end_pfn) will return end_pfn in all the cases.
> 
> Anyway, I will fix it as following.
> 
> zone->zone_start_pfn = start_pfn
> zone->spanned_pages = end_pfn - start_pfn

Hello,

Here comes fixed one.

----------->8------------
