Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2FDD6680FE7
	for <linux-mm@kvack.org>; Thu, 16 Feb 2017 04:32:35 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id kq3so2195901wjc.1
        for <linux-mm@kvack.org>; Thu, 16 Feb 2017 01:32:35 -0800 (PST)
Received: from outbound-smtp06.blacknight.com (outbound-smtp06.blacknight.com. [81.17.249.39])
        by mx.google.com with ESMTPS id 33si8603167wri.15.2017.02.16.01.32.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Feb 2017 01:32:33 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp06.blacknight.com (Postfix) with ESMTPS id 6E54899798
	for <linux-mm@kvack.org>; Thu, 16 Feb 2017 09:32:33 +0000 (UTC)
Date: Thu, 16 Feb 2017 09:32:32 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 3/3] mm, vmscan: Prevent kswapd sleeping prematurely due
 to mismatched classzone_idx
Message-ID: <20170216093232.bx3inec7qngvu7qh@techsingularity.net>
References: <20170215092247.15989-1-mgorman@techsingularity.net>
 <20170215092247.15989-4-mgorman@techsingularity.net>
 <001501d2881d$242aa790$6c7ff6b0$@alibaba-inc.com>
 <20170216081039.ukbxl2b4khnwwbic@techsingularity.net>
 <001f01d2882d$9dd14850$d973d8f0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <001f01d2882d$9dd14850$d973d8f0$@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, 'Shantanu Goel' <sgoel01@yahoo.com>, 'Chris Mason' <clm@fb.com>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Vlastimil Babka' <vbabka@suse.cz>, 'LKML' <linux-kernel@vger.kernel.org>, 'Linux-MM' <linux-mm@kvack.org>

On Thu, Feb 16, 2017 at 04:21:04PM +0800, Hillf Danton wrote:
> 
> On February 16, 2017 4:11 PM Mel Gorman wrote:
> > On Thu, Feb 16, 2017 at 02:23:08PM +0800, Hillf Danton wrote:
> > > On February 15, 2017 5:23 PM Mel Gorman wrote:
> > > >   */
> > > >  static int kswapd(void *p)
> > > >  {
> > > > -	unsigned int alloc_order, reclaim_order, classzone_idx;
> > > > +	unsigned int alloc_order, reclaim_order;
> > > > +	unsigned int classzone_idx = MAX_NR_ZONES - 1;
> > > >  	pg_data_t *pgdat = (pg_data_t*)p;
> > > >  	struct task_struct *tsk = current;
> > > >
> > > > @@ -3447,20 +3466,23 @@ static int kswapd(void *p)
> > > >  	tsk->flags |= PF_MEMALLOC | PF_SWAPWRITE | PF_KSWAPD;
> > > >  	set_freezable();
> > > >
> > > > -	pgdat->kswapd_order = alloc_order = reclaim_order = 0;
> > > > -	pgdat->kswapd_classzone_idx = classzone_idx = 0;
> > > > +	pgdat->kswapd_order = 0;
> > > > +	pgdat->kswapd_classzone_idx = MAX_NR_ZONES;
> > > >  	for ( ; ; ) {
> > > >  		bool ret;
> > > >
> > > > +		alloc_order = reclaim_order = pgdat->kswapd_order;
> > > > +		classzone_idx = kswapd_classzone_idx(pgdat, classzone_idx);
> > > > +
> > > >  kswapd_try_sleep:
> > > >  		kswapd_try_to_sleep(pgdat, alloc_order, reclaim_order,
> > > >  					classzone_idx);
> > > >
> > > >  		/* Read the new order and classzone_idx */
> > > >  		alloc_order = reclaim_order = pgdat->kswapd_order;
> > > > -		classzone_idx = pgdat->kswapd_classzone_idx;
> > > > +		classzone_idx = kswapd_classzone_idx(pgdat, 0);
> > > >  		pgdat->kswapd_order = 0;
> > > > -		pgdat->kswapd_classzone_idx = 0;
> > > > +		pgdat->kswapd_classzone_idx = MAX_NR_ZONES;
> > > >
> > > >  		ret = try_to_freeze();
> > > >  		if (kthread_should_stop())
> > > > @@ -3486,9 +3508,6 @@ static int kswapd(void *p)
> > > >  		reclaim_order = balance_pgdat(pgdat, alloc_order, classzone_idx);
> > > >  		if (reclaim_order < alloc_order)
> > > >  			goto kswapd_try_sleep;
> > >
> > > If we fail order-5 request,  can we then give up order-5, and
> > > try order-3 if requested, after napping?
> > >
> > 
> > That has no bearing upon this patch. At this point, kswapd has stopped
> > reclaiming at the requested order and is preparing to sleep. If there is
> > a parallel request for order-3 while it's sleeping, it'll wake and start
> > reclaiming at order-3 as requested.
> > 
>
> Right, but the order-3 request can also come up while kswapd is active and
> gives up order-5.
> 

And then it'll be in pgdat->kswapd_order and be picked up on the next
wakeup. It won't be immediate but it's also unlikely to be worth picking
up immediately. The context here is that a high-order reclaim request
failed and rather keeping kswapd awake reclaiming the world, go to sleep
until another wakeup request comes in. Staying awake continually for
high orders caused problems with excessive reclaim in the past.

It could be revisited again but it's not related to what this patch is
aimed for -- avoiding reclaim going to sleep because ZONE_DMA is balanced
for a GFP_DMA request which is nowhere in the request stream.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
