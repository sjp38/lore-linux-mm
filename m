Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 48C452808C1
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 09:20:49 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id n11so20841178wma.5
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 06:20:49 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n26si4458927wmi.51.2017.03.09.06.20.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 09 Mar 2017 06:20:47 -0800 (PST)
Date: Thu, 9 Mar 2017 14:20:44 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 1/9] mm: fix 100% CPU kswapd busyloop on unreclaimable
 nodes
Message-ID: <20170309142044.5ewlvus6ana6boqp@suse.de>
References: <20170228214007.5621-1-hannes@cmpxchg.org>
 <20170228214007.5621-2-hannes@cmpxchg.org>
 <20170303012609.GA3394@bbox>
 <20170303075954.GA31499@dhcp22.suse.cz>
 <20170306013740.GA8779@bbox>
 <20170306162410.GB2090@cmpxchg.org>
 <20170307101702.GD28642@dhcp22.suse.cz>
 <20170307165631.GA21425@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170307165631.GA21425@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jia He <hejianet@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Vlastimil Babka <vbabka@suse.cz>

On Tue, Mar 07, 2017 at 11:56:31AM -0500, Johannes Weiner wrote:
> On Tue, Mar 07, 2017 at 11:17:02AM +0100, Michal Hocko wrote:
> > On Mon 06-03-17 11:24:10, Johannes Weiner wrote:
> > > @@ -3271,7 +3271,8 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
> > >  		 * Raise priority if scanning rate is too low or there was no
> > >  		 * progress in reclaiming pages
> > >  		 */
> > > -		if (raise_priority || !sc.nr_reclaimed)
> > > +		nr_reclaimed = sc.nr_reclaimed - nr_reclaimed;
> > > +		if (raise_priority || !nr_reclaimed)
> > >  			sc.priority--;
> > >  	} while (sc.priority >= 1);
> > >  
> > 
> > I would rather not play with the sc state here. From a quick look at
> > least 
> > 	/*
> > 	 * Fragmentation may mean that the system cannot be rebalanced for
> > 	 * high-order allocations. If twice the allocation size has been
> > 	 * reclaimed then recheck watermarks only at order-0 to prevent
> > 	 * excessive reclaim. Assume that a process requested a high-order
> > 	 * can direct reclaim/compact.
> > 	 */
> > 	if (sc->order && sc->nr_reclaimed >= compact_gap(sc->order))
> > 		sc->order = 0;
> > 
> > does rely on the value. Wouldn't something like the following be safer?
> 
> Well, what behavior is correct, though? This check looks like an
> argument *against* resetting sc.nr_reclaimed.
> 
> If kswapd is woken up for a higher order, this check sets a reclaim
> cutoff beyond which it should give up on the order and balance for 0.
> 
> That's on the scope of the kswapd invocation. Applying this threshold
> to the outcome of just the preceeding priority seems like a mistake.
> 
> Mel? Vlastimil?

I cannot say which is definitely the correct behaviour. The current
behaviour is conservative due to the historical concerns about kswapd
reclaiming the world. The hazard as I see it is that resetting it *may*
lead to more aggressive reclaim for high-order allocations. That may be a
welcome outcome to some that really want high-order pages and be unwelcome
to others that prefer pages to remain resident.

However, in this case it's a tight window and problems would be tricky to
detect. THP allocations won't trigger the behaviour and with vmalloc'd
stack, I'd expect that only SLUB-intensive workloads using high-order
pages would trigger any adverse behaviour. While I'm mildly concerned, I
would be a little surprised if it actually caused runaway reclaim.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
