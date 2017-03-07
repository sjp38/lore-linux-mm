Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9E1BC6B038E
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 12:02:30 -0500 (EST)
Received: by mail-lf0-f69.google.com with SMTP id a6so5015285lfa.1
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 09:02:30 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id h130si211081lfh.408.2017.03.07.09.02.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Mar 2017 09:02:25 -0800 (PST)
Date: Tue, 7 Mar 2017 11:56:31 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/9] mm: fix 100% CPU kswapd busyloop on unreclaimable
 nodes
Message-ID: <20170307165631.GA21425@cmpxchg.org>
References: <20170228214007.5621-1-hannes@cmpxchg.org>
 <20170228214007.5621-2-hannes@cmpxchg.org>
 <20170303012609.GA3394@bbox>
 <20170303075954.GA31499@dhcp22.suse.cz>
 <20170306013740.GA8779@bbox>
 <20170306162410.GB2090@cmpxchg.org>
 <20170307101702.GD28642@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170307101702.GD28642@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jia He <hejianet@gmail.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Vlastimil Babka <vbabka@suse.cz>

On Tue, Mar 07, 2017 at 11:17:02AM +0100, Michal Hocko wrote:
> On Mon 06-03-17 11:24:10, Johannes Weiner wrote:
> > @@ -3271,7 +3271,8 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
> >  		 * Raise priority if scanning rate is too low or there was no
> >  		 * progress in reclaiming pages
> >  		 */
> > -		if (raise_priority || !sc.nr_reclaimed)
> > +		nr_reclaimed = sc.nr_reclaimed - nr_reclaimed;
> > +		if (raise_priority || !nr_reclaimed)
> >  			sc.priority--;
> >  	} while (sc.priority >= 1);
> >  
> 
> I would rather not play with the sc state here. From a quick look at
> least 
> 	/*
> 	 * Fragmentation may mean that the system cannot be rebalanced for
> 	 * high-order allocations. If twice the allocation size has been
> 	 * reclaimed then recheck watermarks only at order-0 to prevent
> 	 * excessive reclaim. Assume that a process requested a high-order
> 	 * can direct reclaim/compact.
> 	 */
> 	if (sc->order && sc->nr_reclaimed >= compact_gap(sc->order))
> 		sc->order = 0;
> 
> does rely on the value. Wouldn't something like the following be safer?

Well, what behavior is correct, though? This check looks like an
argument *against* resetting sc.nr_reclaimed.

If kswapd is woken up for a higher order, this check sets a reclaim
cutoff beyond which it should give up on the order and balance for 0.

That's on the scope of the kswapd invocation. Applying this threshold
to the outcome of just the preceeding priority seems like a mistake.

Mel? Vlastimil?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
