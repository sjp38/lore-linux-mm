Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2DDF76B0292
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 02:50:53 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id w63so23563348wrc.5
        for <linux-mm@kvack.org>; Sun, 23 Jul 2017 23:50:53 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w67si1684573wmg.179.2017.07.23.23.50.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 23 Jul 2017 23:50:51 -0700 (PDT)
Date: Mon, 24 Jul 2017 08:50:49 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, vmscan: do not loop on too_many_isolated for ever
Message-ID: <20170724065048.GB25221@dhcp22.suse.cz>
References: <20170710074842.23175-1-mhocko@kernel.org>
 <20170719152014.53a861c57bcb636d6cd9d002@linux-foundation.org>
 <20170720065625.GB9058@dhcp22.suse.cz>
 <20170721160104.9f6101b9e8de53638b3b853a@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170721160104.9f6101b9e8de53638b3b853a@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri 21-07-17 16:01:04, Andrew Morton wrote:
> On Thu, 20 Jul 2017 08:56:26 +0200 Michal Hocko <mhocko@kernel.org> wrote:
> > 
> > > > --- a/mm/vmscan.c
> > > > +++ b/mm/vmscan.c
> > > > @@ -1713,9 +1713,15 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
> > > >  	int file = is_file_lru(lru);
> > > >  	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
> > > >  	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
> > > > +	bool stalled = false;
> > > >  
> > > >  	while (unlikely(too_many_isolated(pgdat, file, sc))) {
> > > > -		congestion_wait(BLK_RW_ASYNC, HZ/10);
> > > > +		if (stalled)
> > > > +			return 0;
> > > > +
> > > > +		/* wait a bit for the reclaimer. */
> > > > +		schedule_timeout_interruptible(HZ/10);
> > > 
> > > a) if this task has signal_pending(), this falls straight through
> > >    and I suspect the code breaks?
> > 
> > It will not break. It will return to the allocation path more quickly
> > but no over-reclaim will happen and it will/should get throttled there.
> > So nothing critical.
> > 
> > > b) replacing congestion_wait() with schedule_timeout_interruptible()
> > >    means this task no longer contributes to load average here and it's
> > >    a (slightly) user-visible change.
> > 
> > you are right. I am not sure it matters but it might be visible.
> >  
> > > c) msleep_interruptible() is nicer
> > > 
> > > d) IOW, methinks we should be using msleep() here?
> > 
> > OK, I do not have objections. Are you going to squash this in or want a
> > separate patch explaining all the above?
> 
> I'd prefer to have a comment explaining why interruptible sleep is
> being used, because that "what if signal_pending()" case is rather a
> red flag.

I didn't really consider interruptible vs. uninterruptible sleep so it
wasn't really a deliberate decision. Now, that you have brought up the
above points I am OK changing that the uninterruptible.

Here is a fix up. I am fine with this either folded in or as a separate
patch.
---
