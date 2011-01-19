Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 3F21E6B0092
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 20:53:29 -0500 (EST)
Received: from kpbe18.cbf.corp.google.com (kpbe18.cbf.corp.google.com [172.25.105.82])
	by smtp-out.google.com with ESMTP id p0J1rNwJ014875
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 17:53:24 -0800
Received: from pvc30 (pvc30.prod.google.com [10.241.209.158])
	by kpbe18.cbf.corp.google.com with ESMTP id p0J1rL2T014194
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 17:53:22 -0800
Received: by pvc30 with SMTP id 30so64653pvc.14
        for <linux-mm@kvack.org>; Tue, 18 Jan 2011 17:53:21 -0800 (PST)
Date: Tue, 18 Jan 2011 17:53:19 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm: fix deferred congestion timeout if preferred zone
 is not allowed
In-Reply-To: <AANLkTin036LNAJ053ByMRmQUnsBpRcv1s5uX1j_2c_Ds@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1101181751420.25382@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1101172108380.29048@chino.kir.corp.google.com> <AANLkTin036LNAJ053ByMRmQUnsBpRcv1s5uX1j_2c_Ds@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="531368966-429837500-1295402000=:25382"
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>
List-ID: <linux-mm.kvack.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--531368966-429837500-1295402000=:25382
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Wed, 19 Jan 2011, Minchan Kim wrote:

> >
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -2034,6 +2034,18 @@ restart:
> >         */
> >        alloc_flags = gfp_to_alloc_flags(gfp_mask);
> >
> > +       /*
> > +        * If preferred_zone cannot be allocated from in this context, find the
> > +        * first allowable zone instead.
> > +        */
> > +       if ((alloc_flags & ALLOC_CPUSET) &&
> > +           !cpuset_zone_allowed_softwall(preferred_zone, gfp_mask)) {
> > +               first_zones_zonelist(zonelist, high_zoneidx,
> > +                               &cpuset_current_mems_allowed, &preferred_zone);
> 
> This patch is one we need. but I have a nitpick.
> I am not familiar with CPUSET so I might be wrong.
> 
> I think it could make side effect of statistics of ZVM on
> buffered_rmqueue since you intercept and change preferred_zone.
> It could make NUMA_HIT instead of NUMA_MISS.
> Is it your intention?
> 

It depends on the semantics of NUMA_MISS: if no local nodes are allowed by 
current's cpuset (a pretty poor cpuset config :), then it seems logical 
that all allocations would be a miss.
--531368966-429837500-1295402000=:25382--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
