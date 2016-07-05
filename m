Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id D6FD66B0005
	for <linux-mm@kvack.org>; Tue,  5 Jul 2016 06:26:42 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id w130so47886143lfd.3
        for <linux-mm@kvack.org>; Tue, 05 Jul 2016 03:26:42 -0700 (PDT)
Received: from outbound-smtp05.blacknight.com (outbound-smtp05.blacknight.com. [81.17.249.38])
        by mx.google.com with ESMTPS id 78si446871wmw.25.2016.07.05.03.26.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 05 Jul 2016 03:26:41 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id B571698FE2
	for <linux-mm@kvack.org>; Tue,  5 Jul 2016 10:26:40 +0000 (UTC)
Date: Tue, 5 Jul 2016 11:26:39 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 08/31] mm, vmscan: simplify the logic deciding whether
 kswapd sleeps
Message-ID: <20160705102639.GG11498@techsingularity.net>
References: <1467403299-25786-1-git-send-email-mgorman@techsingularity.net>
 <1467403299-25786-9-git-send-email-mgorman@techsingularity.net>
 <20160705055931.GC28164@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160705055931.GC28164@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jul 05, 2016 at 02:59:31PM +0900, Minchan Kim wrote:
> > @@ -3249,9 +3249,19 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int order,
> >  
> >  	prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
> >  
> > +	/*
> > +	 * If kswapd has not been woken recently, then kswapd goes fully
> > +	 * to sleep. kcompactd may still need to wake if the original
> > +	 * request was high-order.
> > +	 */
> > +	if (classzone_idx == -1) {
> > +		wakeup_kcompactd(pgdat, alloc_order, classzone_idx);
> > +		classzone_idx = MAX_NR_ZONES - 1;
> > +		goto full_sleep;
> > +	}
> > +
> >  	/* Try to sleep for a short interval */
> > -	if (prepare_kswapd_sleep(pgdat, order, remaining,
> > -						balanced_classzone_idx)) {
> > +	if (prepare_kswapd_sleep(pgdat, reclaim_order, remaining, classzone_idx)) {
> 
> 
> Just trivial but this is clean up patch so I suggest one.
> If it doesn't help readability, just ignore, please.
> 
> This(ie, first prepare_kswapd_sleep always get 0 remaining value so
> it's pointless argument for the function. We could remove it and
> check it before second prepare_kswapd_sleep call.
> 

Yeah, fair point. I added a new patch that does this near the end of
the series with the other patches that avoid unnecessarily passing
parameters.

> > @@ -3418,10 +3426,10 @@ void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
> >  	if (!cpuset_zone_allowed(zone, GFP_KERNEL | __GFP_HARDWALL))
> >  		return;
> >  	pgdat = zone->zone_pgdat;
> > -	if (pgdat->kswapd_max_order < order) {
> > -		pgdat->kswapd_max_order = order;
> > -		pgdat->classzone_idx = min(pgdat->classzone_idx, classzone_idx);
> > -	}
> > +	if (pgdat->kswapd_classzone_idx == -1)
> > +		pgdat->kswapd_classzone_idx = classzone_idx;
> 
> It's tricky. Couldn't we change kswapd_classzone_idx to integer type
> and remove if above if condition?
> 

It's tricky and not necessarily better overall. It's perfectly possible
to be woken up for zone index 0 so it's changing -1 to another magic
value.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
