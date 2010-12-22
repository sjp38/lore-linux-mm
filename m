Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id E8F326B0087
	for <linux-mm@kvack.org>; Thu, 23 Dec 2010 05:13:59 -0500 (EST)
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp08.in.ibm.com (8.14.4/8.13.1) with ESMTP id oBN9Vijt006163
	for <linux-mm@kvack.org>; Thu, 23 Dec 2010 15:01:44 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oBNADsQG2588784
	for <linux-mm@kvack.org>; Thu, 23 Dec 2010 15:43:54 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oBNADrLt012893
	for <linux-mm@kvack.org>; Thu, 23 Dec 2010 21:13:54 +1100
Date: Wed, 22 Dec 2010 11:40:08 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/3] Refactor zone_reclaim (v2)
Message-ID: <20101222061008.GJ7237@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20101210142745.29934.29186.stgit@localhost6.localdomain6>
 <20101210143018.29934.11893.stgit@localhost6.localdomain6>
 <AANLkTimeecObDMQMbWzNhL1mE+UT9D3o1WWS4bmxtR4U@mail.gmail.com>
 <20101214114542.GE14178@balbir.in.ibm.com>
 <AANLkTimy2wKPGxMsO0d_CxUNiDcc+8HWRBctOTrkbbjX@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AANLkTimy2wKPGxMsO0d_CxUNiDcc+8HWRBctOTrkbbjX@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, npiggin@kernel.dk, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, cl@linux.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

* MinChan Kim <minchan.kim@gmail.com> [2010-12-15 07:38:42]:

> On Tue, Dec 14, 2010 at 8:45 PM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > * MinChan Kim <minchan.kim@gmail.com> [2010-12-14 19:01:26]:
> >
> >> Hi Balbir,
> >>
> >> On Fri, Dec 10, 2010 at 11:31 PM, Balbir Singh
> >> <balbir@linux.vnet.ibm.com> wrote:
> >> > Move reusable functionality outside of zone_reclaim.
> >> > Make zone_reclaim_unmapped_pages modular
> >> >
> >> > Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> >> > ---
> >> >  mm/vmscan.c |   35 +++++++++++++++++++++++------------
> >> >  1 files changed, 23 insertions(+), 12 deletions(-)
> >> >
> >> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> >> > index e841cae..4e2ad05 100644
> >> > --- a/mm/vmscan.c
> >> > +++ b/mm/vmscan.c
> >> > @@ -2815,6 +2815,27 @@ static long zone_pagecache_reclaimable(struct zone *zone)
> >> >  }
> >> >
> >> >  /*
> >> > + * Helper function to reclaim unmapped pages, we might add something
> >> > + * similar to this for slab cache as well. Currently this function
> >> > + * is shared with __zone_reclaim()
> >> > + */
> >> > +static inline void
> >> > +zone_reclaim_unmapped_pages(struct zone *zone, struct scan_control *sc,
> >> > +                               unsigned long nr_pages)
> >> > +{
> >> > +       int priority;
> >> > +       /*
> >> > +        * Free memory by calling shrink zone with increasing
> >> > +        * priorities until we have enough memory freed.
> >> > +        */
> >> > +       priority = ZONE_RECLAIM_PRIORITY;
> >> > +       do {
> >> > +               shrink_zone(priority, zone, sc);
> >> > +               priority--;
> >> > +       } while (priority >= 0 && sc->nr_reclaimed < nr_pages);
> >> > +}
> >>
> >> As I said previous version, zone_reclaim_unmapped_pages doesn't have
> >> any functions related to reclaim unmapped pages.
> >
> > The scan control point has the right arguments for implementing
> > reclaim of unmapped pages.
> 
> I mean you should set up scan_control setup in this function.
> Current zone_reclaim_unmapped_pages doesn't have any specific routine
> related to reclaim unmapped pages.
> Otherwise, change the function name with just "zone_reclaim_pages". I
> think you don't want it.

Done, I renamed the function to zone_reclaim_pages.

Thanks!

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
