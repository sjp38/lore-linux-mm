Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0C75D6B02C3
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 02:56:30 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id w63so11844073wrc.5
        for <linux-mm@kvack.org>; Wed, 19 Jul 2017 23:56:30 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k39si5317242wre.233.2017.07.19.23.56.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 19 Jul 2017 23:56:28 -0700 (PDT)
Date: Thu, 20 Jul 2017 08:56:26 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, vmscan: do not loop on too_many_isolated for ever
Message-ID: <20170720065625.GB9058@dhcp22.suse.cz>
References: <20170710074842.23175-1-mhocko@kernel.org>
 <20170719152014.53a861c57bcb636d6cd9d002@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170719152014.53a861c57bcb636d6cd9d002@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 19-07-17 15:20:14, Andrew Morton wrote:
> On Mon, 10 Jul 2017 09:48:42 +0200 Michal Hocko <mhocko@kernel.org> wrote:
> 
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > Tetsuo Handa has reported [1][2][3]that direct reclaimers might get stuck
> > in too_many_isolated loop basically for ever because the last few pages
> > on the LRU lists are isolated by the kswapd which is stuck on fs locks
> > when doing the pageout or slab reclaim. This in turn means that there is
> > nobody to actually trigger the oom killer and the system is basically
> > unusable.
> > 
> > too_many_isolated has been introduced by 35cd78156c49 ("vmscan: throttle
> > direct reclaim when too many pages are isolated already") to prevent
> > from pre-mature oom killer invocations because back then no reclaim
> > progress could indeed trigger the OOM killer too early. But since the
> > oom detection rework 0a0337e0d1d1 ("mm, oom: rework oom detection")
> > the allocation/reclaim retry loop considers all the reclaimable pages
> > and throttles the allocation at that layer so we can loosen the direct
> > reclaim throttling.
> > 
> > Make shrink_inactive_list loop over too_many_isolated bounded and returns
> > immediately when the situation hasn't resolved after the first sleep.
> > Replace congestion_wait by a simple schedule_timeout_interruptible because
> > we are not really waiting on the IO congestion in this path.
> > 
> > Please note that this patch can theoretically cause the OOM killer to
> > trigger earlier while there are many pages isolated for the reclaim
> > which makes progress only very slowly. This would be obvious from the oom
> > report as the number of isolated pages are printed there. If we ever hit
> > this should_reclaim_retry should consider those numbers in the evaluation
> > in one way or another.
> 
> Need to figure out which kernels to patch.  Maybe just 4.13-rc after a
> week or two?

I do not think we need to rush it and the next merge window should be
just OK.

> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -1713,9 +1713,15 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
> >  	int file = is_file_lru(lru);
> >  	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
> >  	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
> > +	bool stalled = false;
> >  
> >  	while (unlikely(too_many_isolated(pgdat, file, sc))) {
> > -		congestion_wait(BLK_RW_ASYNC, HZ/10);
> > +		if (stalled)
> > +			return 0;
> > +
> > +		/* wait a bit for the reclaimer. */
> > +		schedule_timeout_interruptible(HZ/10);
> 
> a) if this task has signal_pending(), this falls straight through
>    and I suspect the code breaks?

It will not break. It will return to the allocation path more quickly
but no over-reclaim will happen and it will/should get throttled there.
So nothing critical.

> b) replacing congestion_wait() with schedule_timeout_interruptible()
>    means this task no longer contributes to load average here and it's
>    a (slightly) user-visible change.

you are right. I am not sure it matters but it might be visible.
 
> c) msleep_interruptible() is nicer
> 
> d) IOW, methinks we should be using msleep() here?

OK, I do not have objections. Are you going to squash this in or want a
separate patch explaining all the above?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
