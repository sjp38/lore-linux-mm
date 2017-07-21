Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9F31A6B02B4
	for <linux-mm@kvack.org>; Fri, 21 Jul 2017 19:01:07 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 65so6584515wmf.2
        for <linux-mm@kvack.org>; Fri, 21 Jul 2017 16:01:07 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id w2si4856247wra.504.2017.07.21.16.01.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jul 2017 16:01:06 -0700 (PDT)
Date: Fri, 21 Jul 2017 16:01:04 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm, vmscan: do not loop on too_many_isolated for ever
Message-Id: <20170721160104.9f6101b9e8de53638b3b853a@linux-foundation.org>
In-Reply-To: <20170720065625.GB9058@dhcp22.suse.cz>
References: <20170710074842.23175-1-mhocko@kernel.org>
	<20170719152014.53a861c57bcb636d6cd9d002@linux-foundation.org>
	<20170720065625.GB9058@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu, 20 Jul 2017 08:56:26 +0200 Michal Hocko <mhocko@kernel.org> wrote:
> 
> > > --- a/mm/vmscan.c
> > > +++ b/mm/vmscan.c
> > > @@ -1713,9 +1713,15 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
> > >  	int file = is_file_lru(lru);
> > >  	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
> > >  	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
> > > +	bool stalled = false;
> > >  
> > >  	while (unlikely(too_many_isolated(pgdat, file, sc))) {
> > > -		congestion_wait(BLK_RW_ASYNC, HZ/10);
> > > +		if (stalled)
> > > +			return 0;
> > > +
> > > +		/* wait a bit for the reclaimer. */
> > > +		schedule_timeout_interruptible(HZ/10);
> > 
> > a) if this task has signal_pending(), this falls straight through
> >    and I suspect the code breaks?
> 
> It will not break. It will return to the allocation path more quickly
> but no over-reclaim will happen and it will/should get throttled there.
> So nothing critical.
> 
> > b) replacing congestion_wait() with schedule_timeout_interruptible()
> >    means this task no longer contributes to load average here and it's
> >    a (slightly) user-visible change.
> 
> you are right. I am not sure it matters but it might be visible.
>  
> > c) msleep_interruptible() is nicer
> > 
> > d) IOW, methinks we should be using msleep() here?
> 
> OK, I do not have objections. Are you going to squash this in or want a
> separate patch explaining all the above?

I'd prefer to have a comment explaining why interruptible sleep is
being used, because that "what if signal_pending()" case is rather a
red flag.

Is it the case that fall-through-if-signal_pending() is the
*preferred* behaviour?  If so, the comment should explain this.  If it
isn't the preferred behaviour then using uninterruptible sleep sounds
better to me, if only because it saves us from having to test a rather
tricky and rare case.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
