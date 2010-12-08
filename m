Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2F2616B0087
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 01:57:04 -0500 (EST)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp02.in.ibm.com (8.14.4/8.13.1) with ESMTP id oB86urt3018300
	for <linux-mm@kvack.org>; Wed, 8 Dec 2010 12:26:53 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oB86uqO84489334
	for <linux-mm@kvack.org>; Wed, 8 Dec 2010 12:26:53 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oB86upfF025610
	for <linux-mm@kvack.org>; Wed, 8 Dec 2010 17:56:52 +1100
Date: Wed, 8 Dec 2010 12:26:50 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH v4 2/7] deactivate invalidated pages
Message-ID: <20101208065650.GP3158@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20101207144923.GB2356@cmpxchg.org>
 <20101207150710.GA26613@barrios-desktop>
 <20101207151939.GF2356@cmpxchg.org>
 <20101207152625.GB608@barrios-desktop>
 <20101207155645.GG2356@cmpxchg.org>
 <AANLkTi=iNGT_p_VfW9GxdaKXLt2xBHM2jdwmCbF_u8uh@mail.gmail.com>
 <20101208095642.8128ab33.kamezawa.hiroyu@jp.fujitsu.com>
 <AANLkTimtkb7Nczhads4u3r21RJauZvviLFkXjaL1ErDb@mail.gmail.com>
 <20101208105637.5103de75.kamezawa.hiroyu@jp.fujitsu.com>
 <AANLkTim9to0Wa_iWyVA4FSV6sfT4tcR2bmV7t54HOQ1c@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <AANLkTim9to0Wa_iWyVA4FSV6sfT4tcR2bmV7t54HOQ1c@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, Nick Piggin <npiggin@kernel.dk>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

* MinChan Kim <minchan.kim@gmail.com> [2010-12-08 11:15:19]:

> On Wed, Dec 8, 2010 at 10:56 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Wed, 8 Dec 2010 10:43:08 +0900
> > Minchan Kim <minchan.kim@gmail.com> wrote:
> >
> >> Hi Kame,
> >>
> > Hi,
> >
> >> > I wonder ...how about adding "victim" list for "Reclaim" pages ? Then, we don't need
> >> > extra LRU rotation.
> >>
> >> It can make the code clean.
> >> As far as I think, victim list does following as.
> >>
> >> 1. select victim pages by strong hint
> >> 2. move the page from LRU to victim
> >> 3. reclaimer always peeks victim list before diving into LRU list.
> >> 4-1. If the victim pages is used by others or dirty, it can be moved
> >> into LRU, again or remain the page in victim list.
> >> If the page is remained victim, when do we move it into LRU again if
> >> the reclaimer continues to fail the page?
> > When sometone touches it.
> >
> >> We have to put the new rule.
> >> 4-2. If the victim pages isn't used by others and clean, we can
> >> reclaim the page asap.
> >>
> >> AFAIK, strong hints are just two(invalidation, readahead max window heuristic).
> >> I am not sure it's valuable to add new hierarchy(ie, LRU, victim,
> >> unevictable) for cleaning the minor codes.
> >> In addition, we have to put the new rule so it would make the LRU code
> >> complicated.
> >> I remember how unevictable feature merge is hard.
> >>
> > yes, it was hard.
> >
> >> But I am not against if we have more usecases. In this case, it's
> >> valuable to implement it although it's not easy.
> >>
> >
> > I wonder "victim list" can be used for something like Cleancache, when
> > we have very-low-latency backend devices.
> > And we may able to have page-cache-limit, which Balbir proposed as.
> 
> Yes, I thought that, too. I think it would be a good feature in embedded system.
> 
> >
> >  - kvictimed? will move unmappedd page caches to victim list
> > This may work like a InactiveClean list which we had before and make
> > sizing easy.
> >
> 
> Before further discuss, we need customer's confirm.
> We know very well it is very hard to merge if anyone doesn't use.
> 
> Balbir, What do think about it?
> 

The idea seems interesting, I am in the process of refreshing my
patches for unmapped page cache control. I presume the process of
filling the victim list will be similar to what I have or unmapped
page cache isolation.

> 
> > Thanks,
> > -Kame
> >
> >
> >
> >
> 
> 
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
