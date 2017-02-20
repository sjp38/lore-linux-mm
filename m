Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id D81086B0038
	for <linux-mm@kvack.org>; Mon, 20 Feb 2017 11:34:27 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id n39so7902599wrn.0
        for <linux-mm@kvack.org>; Mon, 20 Feb 2017 08:34:27 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z64si586747wrc.201.2017.02.20.08.34.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 20 Feb 2017 08:34:26 -0800 (PST)
Subject: Re: [PATCH 3/3] mm, vmscan: Prevent kswapd sleeping prematurely due
 to mismatched classzone_idx
References: <20170215092247.15989-1-mgorman@techsingularity.net>
 <20170215092247.15989-4-mgorman@techsingularity.net>
 <001501d2881d$242aa790$6c7ff6b0$@alibaba-inc.com>
 <20170216081039.ukbxl2b4khnwwbic@techsingularity.net>
 <001f01d2882d$9dd14850$d973d8f0$@alibaba-inc.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <d4e3317b-5ae8-f61c-4d71-5a74a4014cc7@suse.cz>
Date: Mon, 20 Feb 2017 17:34:21 +0100
MIME-Version: 1.0
In-Reply-To: <001f01d2882d$9dd14850$d973d8f0$@alibaba-inc.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>, 'Mel Gorman' <mgorman@techsingularity.net>
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, 'Shantanu Goel' <sgoel01@yahoo.com>, 'Chris Mason' <clm@fb.com>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'LKML' <linux-kernel@vger.kernel.org>, 'Linux-MM' <linux-mm@kvack.org>

On 02/16/2017 09:21 AM, Hillf Danton wrote:
> 
> On February 16, 2017 4:11 PM Mel Gorman wrote:
>> On Thu, Feb 16, 2017 at 02:23:08PM +0800, Hillf Danton wrote:
>> > On February 15, 2017 5:23 PM Mel Gorman wrote:
>> > >   */
>> > >  static int kswapd(void *p)
>> > >  {
>> > > -	unsigned int alloc_order, reclaim_order, classzone_idx;
>> > > +	unsigned int alloc_order, reclaim_order;
>> > > +	unsigned int classzone_idx = MAX_NR_ZONES - 1;
>> > >  	pg_data_t *pgdat = (pg_data_t*)p;
>> > >  	struct task_struct *tsk = current;
>> > >
>> > > @@ -3447,20 +3466,23 @@ static int kswapd(void *p)
>> > >  	tsk->flags |= PF_MEMALLOC | PF_SWAPWRITE | PF_KSWAPD;
>> > >  	set_freezable();
>> > >
>> > > -	pgdat->kswapd_order = alloc_order = reclaim_order = 0;
>> > > -	pgdat->kswapd_classzone_idx = classzone_idx = 0;
>> > > +	pgdat->kswapd_order = 0;
>> > > +	pgdat->kswapd_classzone_idx = MAX_NR_ZONES;
>> > >  	for ( ; ; ) {
>> > >  		bool ret;
>> > >
>> > > +		alloc_order = reclaim_order = pgdat->kswapd_order;
>> > > +		classzone_idx = kswapd_classzone_idx(pgdat, classzone_idx);
>> > > +
>> > >  kswapd_try_sleep:
>> > >  		kswapd_try_to_sleep(pgdat, alloc_order, reclaim_order,
>> > >  					classzone_idx);
>> > >
>> > >  		/* Read the new order and classzone_idx */
>> > >  		alloc_order = reclaim_order = pgdat->kswapd_order;
>> > > -		classzone_idx = pgdat->kswapd_classzone_idx;
>> > > +		classzone_idx = kswapd_classzone_idx(pgdat, 0);
>> > >  		pgdat->kswapd_order = 0;
>> > > -		pgdat->kswapd_classzone_idx = 0;
>> > > +		pgdat->kswapd_classzone_idx = MAX_NR_ZONES;
>> > >
>> > >  		ret = try_to_freeze();
>> > >  		if (kthread_should_stop())
>> > > @@ -3486,9 +3508,6 @@ static int kswapd(void *p)
>> > >  		reclaim_order = balance_pgdat(pgdat, alloc_order, classzone_idx);
>> > >  		if (reclaim_order < alloc_order)
>> > >  			goto kswapd_try_sleep;
>> >
>> > If we fail order-5 request,  can we then give up order-5, and
>> > try order-3 if requested, after napping?
>> >
>> 
>> That has no bearing upon this patch. At this point, kswapd has stopped
>> reclaiming at the requested order and is preparing to sleep. If there is
>> a parallel request for order-3 while it's sleeping, it'll wake and start
>> reclaiming at order-3 as requested.
>> 
> Right, but the order-3 request can also come up while kswapd is active and
> gives up order-5.

"Giving up on order-5" means it will set sc.order to 0, go to sleep (assuming
order-0 watermarks are OK) and wakeup kcompactd for order-5. There's no way how
kswapd could help an order-3 allocation at that point - it's up to kcompactd.

> thanks
> Hillf
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
