Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 554594405CC
	for <linux-mm@kvack.org>; Thu, 16 Feb 2017 03:10:42 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id x4so2083686wme.3
        for <linux-mm@kvack.org>; Thu, 16 Feb 2017 00:10:42 -0800 (PST)
Received: from outbound-smtp07.blacknight.com (outbound-smtp07.blacknight.com. [46.22.139.12])
        by mx.google.com with ESMTPS id i3si8337294wrb.104.2017.02.16.00.10.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Feb 2017 00:10:40 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp07.blacknight.com (Postfix) with ESMTPS id 4E1EB1C1FF3
	for <linux-mm@kvack.org>; Thu, 16 Feb 2017 08:10:40 +0000 (GMT)
Date: Thu, 16 Feb 2017 08:10:39 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 3/3] mm, vmscan: Prevent kswapd sleeping prematurely due
 to mismatched classzone_idx
Message-ID: <20170216081039.ukbxl2b4khnwwbic@techsingularity.net>
References: <20170215092247.15989-1-mgorman@techsingularity.net>
 <20170215092247.15989-4-mgorman@techsingularity.net>
 <001501d2881d$242aa790$6c7ff6b0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <001501d2881d$242aa790$6c7ff6b0$@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, 'Shantanu Goel' <sgoel01@yahoo.com>, 'Chris Mason' <clm@fb.com>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Vlastimil Babka' <vbabka@suse.cz>, 'LKML' <linux-kernel@vger.kernel.org>, 'Linux-MM' <linux-mm@kvack.org>

On Thu, Feb 16, 2017 at 02:23:08PM +0800, Hillf Danton wrote:
> On February 15, 2017 5:23 PM Mel Gorman wrote: 
> >   */
> >  static int kswapd(void *p)
> >  {
> > -	unsigned int alloc_order, reclaim_order, classzone_idx;
> > +	unsigned int alloc_order, reclaim_order;
> > +	unsigned int classzone_idx = MAX_NR_ZONES - 1;
> >  	pg_data_t *pgdat = (pg_data_t*)p;
> >  	struct task_struct *tsk = current;
> > 
> > @@ -3447,20 +3466,23 @@ static int kswapd(void *p)
> >  	tsk->flags |= PF_MEMALLOC | PF_SWAPWRITE | PF_KSWAPD;
> >  	set_freezable();
> > 
> > -	pgdat->kswapd_order = alloc_order = reclaim_order = 0;
> > -	pgdat->kswapd_classzone_idx = classzone_idx = 0;
> > +	pgdat->kswapd_order = 0;
> > +	pgdat->kswapd_classzone_idx = MAX_NR_ZONES;
> >  	for ( ; ; ) {
> >  		bool ret;
> > 
> > +		alloc_order = reclaim_order = pgdat->kswapd_order;
> > +		classzone_idx = kswapd_classzone_idx(pgdat, classzone_idx);
> > +
> >  kswapd_try_sleep:
> >  		kswapd_try_to_sleep(pgdat, alloc_order, reclaim_order,
> >  					classzone_idx);
> > 
> >  		/* Read the new order and classzone_idx */
> >  		alloc_order = reclaim_order = pgdat->kswapd_order;
> > -		classzone_idx = pgdat->kswapd_classzone_idx;
> > +		classzone_idx = kswapd_classzone_idx(pgdat, 0);
> >  		pgdat->kswapd_order = 0;
> > -		pgdat->kswapd_classzone_idx = 0;
> > +		pgdat->kswapd_classzone_idx = MAX_NR_ZONES;
> > 
> >  		ret = try_to_freeze();
> >  		if (kthread_should_stop())
> > @@ -3486,9 +3508,6 @@ static int kswapd(void *p)
> >  		reclaim_order = balance_pgdat(pgdat, alloc_order, classzone_idx);
> >  		if (reclaim_order < alloc_order)
> >  			goto kswapd_try_sleep;
> 
> If we fail order-5 request,  can we then give up order-5, and
> try order-3 if requested, after napping?
> 

That has no bearing upon this patch. At this point, kswapd has stopped
reclaiming at the requested order and is preparing to sleep. If there is
a parallel request for order-3 while it's sleeping, it'll wake and start
reclaiming at order-3 as requested.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
