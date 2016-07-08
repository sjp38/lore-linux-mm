Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3D528828E5
	for <linux-mm@kvack.org>; Fri,  8 Jul 2016 06:05:36 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id x83so5759835wma.2
        for <linux-mm@kvack.org>; Fri, 08 Jul 2016 03:05:36 -0700 (PDT)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id d8si2215922wjq.12.2016.07.08.03.05.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 08 Jul 2016 03:05:35 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id A9DAB9902A
	for <linux-mm@kvack.org>; Fri,  8 Jul 2016 10:05:34 +0000 (UTC)
Date: Fri, 8 Jul 2016 11:05:32 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 04/31] mm, vmscan: begin reclaiming pages on a per-node
 basis
Message-ID: <20160708100532.GC11498@techsingularity.net>
References: <1467403299-25786-1-git-send-email-mgorman@techsingularity.net>
 <1467403299-25786-5-git-send-email-mgorman@techsingularity.net>
 <20160707011211.GA27987@js1304-P5Q-DELUXE>
 <20160707094808.GP11498@techsingularity.net>
 <20160708022852.GA2370@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160708022852.GA2370@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jul 08, 2016 at 11:28:52AM +0900, Joonsoo Kim wrote:
> On Thu, Jul 07, 2016 at 10:48:08AM +0100, Mel Gorman wrote:
> > On Thu, Jul 07, 2016 at 10:12:12AM +0900, Joonsoo Kim wrote:
> > > > @@ -1402,6 +1406,11 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
> > > >  
> > > >  		VM_BUG_ON_PAGE(!PageLRU(page), page);
> > > >  
> > > > +		if (page_zonenum(page) > sc->reclaim_idx) {
> > > > +			list_move(&page->lru, &pages_skipped);
> > > > +			continue;
> > > > +		}
> > > > +
> > > 
> > > I think that we don't need to skip LRU pages in active list. What we'd
> > > like to do is just skipping actual reclaim since it doesn't make
> > > freepage that we need. It's unrelated to skip the page in active list.
> > > 
> > 
> > Why?
> > 
> > The active aging is sometimes about simply aging the LRU list. Aging the
> > active list based on the timing of when a zone-constrained allocation arrives
> > potentially introduces the same zone-balancing problems we currently have
> > and applying them to node-lru.
> 
> Could you explain more? I don't understand why aging the active list
> based on the timing of when a zone-constrained allocation arrives
> introduces the zone-balancing problem again.
> 

I mispoke. Avoid rotation of the active list based on the timing of a
zone-constrained allocation is what I think potentially introduces problems.
If there are zone-constrained allocations aging the active list then I worry
that pages would be artificially preserved on the active list.  No matter
what we do, there is distortion of the aging for zone-constrained allocation
because right now, it may deactivate high zone pages sooner than expected.

> I think that if above logic is applied to both the active/inactive
> list, it could cause zone-balancing problem. LRU pages on lower zone
> can be resident on memory with more chance.

If anything, with node-based LRU, it's high zone pages that can be resident
on memory for longer but only if there are zone-constrained allocations.
If we always reclaim based on age regardless of allocation requirements
then there is a risk that high zones are reclaimed far earlier than expected.

Basically, whether we skip pages in the active list or not there are
distortions with page aging and the impact is workload dependent. Right now,
I see no clear advantage to special casing active aging.

If we suspect this is a problem in the future, it would be a simple matter
of adding an additional bool parameter to isolate_lru_pages.

> > > And, I have a concern that if inactive LRU is full with higher zone's
> > > LRU pages, reclaim with low reclaim_idx could be stuck.
> > 
> > That is an outside possibility but unlikely given that it would require
> > that all outstanding allocation requests are zone-contrained. If it happens
> 
> I'm not sure that it is outside possibility. It can also happens if there
> is zone-contrained allocation requestor and parallel memory hogger. In
> this case, memory would be reclaimed by memory hogger but memory hogger would
> consume them again so inactive LRU is continually full with higher
> zone's LRU pages and zone-contrained allocation requestor cannot
> progress.
> 

The same memory hogger will also be reclaiming the highmem pages and
reallocating highmem pages.

> > It would be preferred to have an actual test case for this so the
> > altered ratio can be tested instead of introducing code that may be
> > useless or dead.
> 
> Yes, actual test case would be preferred. I will try to implement
> an artificial test case by myself but I'm not sure when I can do it.
> 

That would be appreciated.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
