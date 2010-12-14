Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A4CEA6B008A
	for <linux-mm@kvack.org>; Tue, 14 Dec 2010 06:45:50 -0500 (EST)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp07.in.ibm.com (8.14.4/8.13.1) with ESMTP id oBEBji8r012550
	for <linux-mm@kvack.org>; Tue, 14 Dec 2010 17:15:44 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oBEBjihR4124724
	for <linux-mm@kvack.org>; Tue, 14 Dec 2010 17:15:44 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oBEBjh8I001911
	for <linux-mm@kvack.org>; Tue, 14 Dec 2010 22:45:44 +1100
Date: Tue, 14 Dec 2010 17:15:42 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/3] Refactor zone_reclaim (v2)
Message-ID: <20101214114542.GE14178@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20101210142745.29934.29186.stgit@localhost6.localdomain6>
 <20101210143018.29934.11893.stgit@localhost6.localdomain6>
 <AANLkTimeecObDMQMbWzNhL1mE+UT9D3o1WWS4bmxtR4U@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AANLkTimeecObDMQMbWzNhL1mE+UT9D3o1WWS4bmxtR4U@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, npiggin@kernel.dk, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, cl@linux.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

* MinChan Kim <minchan.kim@gmail.com> [2010-12-14 19:01:26]:

> Hi Balbir,
> 
> On Fri, Dec 10, 2010 at 11:31 PM, Balbir Singh
> <balbir@linux.vnet.ibm.com> wrote:
> > Move reusable functionality outside of zone_reclaim.
> > Make zone_reclaim_unmapped_pages modular
> >
> > Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> > ---
> >  mm/vmscan.c |   35 +++++++++++++++++++++++------------
> >  1 files changed, 23 insertions(+), 12 deletions(-)
> >
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index e841cae..4e2ad05 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -2815,6 +2815,27 @@ static long zone_pagecache_reclaimable(struct zone *zone)
> >  }
> >
> >  /*
> > + * Helper function to reclaim unmapped pages, we might add something
> > + * similar to this for slab cache as well. Currently this function
> > + * is shared with __zone_reclaim()
> > + */
> > +static inline void
> > +zone_reclaim_unmapped_pages(struct zone *zone, struct scan_control *sc,
> > +                               unsigned long nr_pages)
> > +{
> > +       int priority;
> > +       /*
> > +        * Free memory by calling shrink zone with increasing
> > +        * priorities until we have enough memory freed.
> > +        */
> > +       priority = ZONE_RECLAIM_PRIORITY;
> > +       do {
> > +               shrink_zone(priority, zone, sc);
> > +               priority--;
> > +       } while (priority >= 0 && sc->nr_reclaimed < nr_pages);
> > +}
> 
> As I said previous version, zone_reclaim_unmapped_pages doesn't have
> any functions related to reclaim unmapped pages.

The scan control point has the right arguments for implementing
reclaim of unmapped pages.

> The function name is rather strange.
> It would be better to add scan_control setup in function inner to
> reclaim only unmapped pages.
> 
> -- 
> Kind regards,
> Minchan Kim

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
