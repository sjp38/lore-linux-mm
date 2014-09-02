Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f45.google.com (mail-la0-f45.google.com [209.85.215.45])
	by kanga.kvack.org (Postfix) with ESMTP id F3B3F6B0036
	for <linux-mm@kvack.org>; Tue,  2 Sep 2014 18:26:59 -0400 (EDT)
Received: by mail-la0-f45.google.com with SMTP id pn19so8690317lab.4
        for <linux-mm@kvack.org>; Tue, 02 Sep 2014 15:26:59 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id m3si355486laf.79.2014.09.02.15.26.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 02 Sep 2014 15:26:58 -0700 (PDT)
Date: Tue, 2 Sep 2014 18:26:53 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch] mm: clean up zone flags
Message-ID: <20140902222653.GA20186@cmpxchg.org>
References: <1409668074-16875-1-git-send-email-hannes@cmpxchg.org>
 <alpine.DEB.2.02.1409021437160.28054@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1409021437160.28054@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Sep 02, 2014 at 02:42:14PM -0700, David Rientjes wrote:
> On Tue, 2 Sep 2014, Johannes Weiner wrote:
> > @@ -631,7 +631,7 @@ long wait_iff_congested(struct zone *zone, int sync, long timeout)
> >  	 * of sleeping on the congestion queue
> >  	 */
> >  	if (atomic_read(&nr_bdi_congested[sync]) == 0 ||
> > -			!zone_is_reclaim_congested(zone)) {
> > +	    test_bit(ZONE_CONGESTED, &zone->flags)) {
> >  		cond_resched();
> >  
> >  		/* In case we scheduled, work out time remaining */
> 
> That's not equivalent.
> 
> [snip]
> 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 2836b5373b2e..590a92bec6a4 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -920,7 +920,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
> >  			/* Case 1 above */
> >  			if (current_is_kswapd() &&
> >  			    PageReclaim(page) &&
> > -			    zone_is_reclaim_writeback(zone)) {
> > +			    test_bit(ZONE_WRITEBACK, &zone->flags)) {
> >  				nr_immediate++;
> >  				goto keep_locked;
> >  
> > @@ -1002,7 +1002,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
> >  			 */
> >  			if (page_is_file_cache(page) &&
> >  					(!current_is_kswapd() ||
> > -					 !zone_is_reclaim_dirty(zone))) {
> > +					 test_bit(ZONE_DIRTY, &zone->flags))) {
> >  				/*
> >  				 * Immediately reclaim when written back.
> >  				 * Similar in principal to deactivate_page()
> 
> Nor is this.
>
> After fixed, for the oom killer bits:
> 
> 	Acked-by: David Rientjes <rientjes@google.com>
> 
> since this un-obscurification is most welcome.

Yikes, thanks for catching those and acking.  Updated patch:

---
