Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 979B36B0005
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 22:25:24 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e189so70291909pfa.2
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 19:25:24 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id c10si1186259pan.75.2016.07.07.19.25.22
        for <linux-mm@kvack.org>;
        Thu, 07 Jul 2016 19:25:23 -0700 (PDT)
Date: Fri, 8 Jul 2016 11:28:52 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 04/31] mm, vmscan: begin reclaiming pages on a per-node
 basis
Message-ID: <20160708022852.GA2370@js1304-P5Q-DELUXE>
References: <1467403299-25786-1-git-send-email-mgorman@techsingularity.net>
 <1467403299-25786-5-git-send-email-mgorman@techsingularity.net>
 <20160707011211.GA27987@js1304-P5Q-DELUXE>
 <20160707094808.GP11498@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160707094808.GP11498@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jul 07, 2016 at 10:48:08AM +0100, Mel Gorman wrote:
> On Thu, Jul 07, 2016 at 10:12:12AM +0900, Joonsoo Kim wrote:
> > > @@ -1402,6 +1406,11 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
> > >  
> > >  		VM_BUG_ON_PAGE(!PageLRU(page), page);
> > >  
> > > +		if (page_zonenum(page) > sc->reclaim_idx) {
> > > +			list_move(&page->lru, &pages_skipped);
> > > +			continue;
> > > +		}
> > > +
> > 
> > I think that we don't need to skip LRU pages in active list. What we'd
> > like to do is just skipping actual reclaim since it doesn't make
> > freepage that we need. It's unrelated to skip the page in active list.
> > 
> 
> Why?
> 
> The active aging is sometimes about simply aging the LRU list. Aging the
> active list based on the timing of when a zone-constrained allocation arrives
> potentially introduces the same zone-balancing problems we currently have
> and applying them to node-lru.

Could you explain more? I don't understand why aging the active list
based on the timing of when a zone-constrained allocation arrives
introduces the zone-balancing problem again.

I think that if above logic is applied to both the active/inactive
list, it could cause zone-balancing problem. LRU pages on lower zone
can be resident on memory with more chance. What we want to do with
node-lru is aging all the lru pages equally as much as possible. So,
basically, we need to age active/inactive list regardless allocation
type. But, there is a possibility that zone-constrained allocation
would reclaim too many LRU pages unnecessarily to satisfy zone-constrained
allocation, so we need to implement skipping such a page. It can be
done by just skipping the page in inactive list.

> 
> > And, I have a concern that if inactive LRU is full with higher zone's
> > LRU pages, reclaim with low reclaim_idx could be stuck.
> 
> That is an outside possibility but unlikely given that it would require
> that all outstanding allocation requests are zone-contrained. If it happens

I'm not sure that it is outside possibility. It can also happens if there
is zone-contrained allocation requestor and parallel memory hogger. In
this case, memory would be reclaimed by memory hogger but memory hogger would
consume them again so inactive LRU is continually full with higher
zone's LRU pages and zone-contrained allocation requestor cannot
progress.

> that a premature OOM is encountered while the active list is large then
> inactive_list_is_low could take scan_control as a parameter and use a
> different ratio for zone-contrained allocations if scan priority is elevated.

It would work.

> It would be preferred to have an actual test case for this so the
> altered ratio can be tested instead of introducing code that may be
> useless or dead.

Yes, actual test case would be preferred. I will try to implement
an artificial test case by myself but I'm not sure when I can do it.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
