Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 03CB26B0087
	for <linux-mm@kvack.org>; Thu,  2 Dec 2010 10:35:35 -0500 (EST)
Received: by pzk27 with SMTP id 27so1714012pzk.14
        for <linux-mm@kvack.org>; Thu, 02 Dec 2010 07:35:33 -0800 (PST)
Date: Fri, 3 Dec 2010 00:35:26 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [patch]vmscan: make kswapd use a correct order
Message-ID: <20101202153526.GB1735@barrios-desktop>
References: <1291172911.12777.58.camel@sli10-conroe>
 <20101201132730.ABC2.A69D9226@jp.fujitsu.com>
 <20101201155854.GA3372@barrios-desktop>
 <20101202101234.GR13268@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101202101234.GR13268@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Dec 02, 2010 at 10:12:34AM +0000, Mel Gorman wrote:
> On Thu, Dec 02, 2010 at 12:58:54AM +0900, Minchan Kim wrote:
> > How about this?
> > If you want it, feel free to use it.
> > If you insist on your coding style, I don't have any objection.
> > Then add My Reviewed-by.
> > 
> > Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> > ---
> >  mm/vmscan.c |   21 +++++++++++++++++----
> >  1 files changed, 17 insertions(+), 4 deletions(-)
> > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 42a4859..e48a612 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -2447,13 +2447,18 @@ out:
> >  	return sc.nr_reclaimed;
> >  }
> >  
> > -static void kswapd_try_to_sleep(pg_data_t *pgdat, int order)
> > +/*
> > + * Return true if we sleep enough. Othrewise, return false
> > + */
> 
> s/Othrewise/Otherwise/
> 
> Maybe

Will fix.

> 
> > +static bool kswapd_try_to_sleep(pg_data_t *pgdat, int order)
> >  {
> >  	long remaining = 0;
> > +	bool sleep = 0;
> > +
> 
> sleep is a boolean, it's true or false, not 0 or !0

I was out of my mind. :(

> 
> The term "sleep" implies present or future tense - i.e. I am going to sleep or
> will go to sleep in the future.  The event this variable cares about in the
> past so "slept" or finished_sleeping might be a more appropriate term. Sorry
> to be picky about the English but there is an important distinction here.

Never mind. You pointed a very important thing.
Non-native speaker like me always suffer from writing some comment or naming
variable name so such a point can help very much.

It's a very desirable, I think.

> 
> >  	DEFINE_WAIT(wait);
> >  
> >  	if (freezing(current) || kthread_should_stop())
> > -		return;
> > +		return sleep;
> >  
> >  	prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
> >  
> > @@ -2482,6 +2487,7 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int order)
> >  		set_pgdat_percpu_threshold(pgdat, calculate_normal_threshold);
> >  		schedule();
> >  		set_pgdat_percpu_threshold(pgdat, calculate_pressure_threshold);
> > +		sleep = 1;
> >  	} else {
> >  		if (remaining)
> >  			count_vm_event(KSWAPD_LOW_WMARK_HIT_QUICKLY);
> > @@ -2489,6 +2495,8 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int order)
> >  			count_vm_event(KSWAPD_HIGH_WMARK_HIT_QUICKLY);
> >  	}
> >  	finish_wait(&pgdat->kswapd_wait, &wait);
> > +
> > +	return sleep;
> >  }
> >  
> >  /*
> > @@ -2550,8 +2558,13 @@ static int kswapd(void *p)
> >  			 */
> >  			order = new_order;
> >  		} else {
> > -			kswapd_try_to_sleep(pgdat, order);
> > -			order = pgdat->kswapd_max_order;
> > +			/*
> > +			 * If we wake up after enough sleeping, let's
> > +			 * start new order. Otherwise, it was a premature
> > +			 * sleep so we keep going on.
> > +			 */
> > +			if (kswapd_try_to_sleep(pgdat, order))
> > +				order = pgdat->kswapd_max_order;
> 
> Ok, we lose the old order if we slept enough. That is fine because if we
> slept enough it implies that reclaiming at that order was no longer
> necessary.
> 
> This needs a repost with a full changelog explaining why order has to be
> preserved if kswapd fails to go to sleep. There will be merge difficulties
> with the series aimed at fixing Simon's problem but it's unavoidable.
> Rebasing on top of my series isn't an option as I'm still patching
> against mainline until that issue is resolved.

So what's your point? Do you want me to send this patch alone
regardless of your series for Simon's problem?

Thanks for the review, Mel.

> 
> -- 
> Mel Gorman
> Part-time Phd Student                          Linux Technology Center
> University of Limerick                         IBM Dublin Software Lab

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
