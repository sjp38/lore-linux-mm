Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id CBFEF6B0033
	for <linux-mm@kvack.org>; Fri, 20 Jan 2017 04:26:04 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id yr2so13693832wjc.4
        for <linux-mm@kvack.org>; Fri, 20 Jan 2017 01:26:04 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 135si2718000wmq.95.2017.01.20.01.26.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 20 Jan 2017 01:26:03 -0800 (PST)
Date: Fri, 20 Jan 2017 09:25:58 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH 1/2] mm, vmscan: account the number of isolated pages
 per zone
Message-ID: <20170120092558.phi37tvpsb4g5isv@suse.de>
References: <20170118134453.11725-1-mhocko@kernel.org>
 <20170118134453.11725-2-mhocko@kernel.org>
 <20170118144655.3lra7xgdcl2awgjd@suse.de>
 <20170118151530.GR7015@dhcp22.suse.cz>
 <20170118155430.kimzqkur5c3te2at@suse.de>
 <20170118161731.GT7015@dhcp22.suse.cz>
 <20170118170010.agpd4njpv5log3xe@suse.de>
 <20170118172944.GA17135@dhcp22.suse.cz>
 <20170119100755.rs6erdiz5u5by2pu@suse.de>
 <000501d272e8$5bfcf7d0$13f6e770$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <000501d272e8$5bfcf7d0$13f6e770$@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: 'Michal Hocko' <mhocko@kernel.org>, linux-mm@kvack.org, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Tetsuo Handa' <penguin-kernel@I-love.SAKURA.ne.jp>, 'LKML' <linux-kernel@vger.kernel.org>

On Fri, Jan 20, 2017 at 02:42:24PM +0800, Hillf Danton wrote:
> > @@ -1603,16 +1603,16 @@ int isolate_lru_page(struct page *page)
> >   * the LRU list will go small and be scanned faster than necessary, leading to
> >   * unnecessary swapping, thrashing and OOM.
> >   */
> > -static int too_many_isolated(struct pglist_data *pgdat, int file,
> > +static bool safe_to_isolate(struct pglist_data *pgdat, int file,
> >  		struct scan_control *sc)
> 
> I prefer the current function name.
> 

The restructure is to work with the workqueue api.

> >  {
> >  	unsigned long inactive, isolated;
> > 
> >  	if (current_is_kswapd())
> > -		return 0;
> > +		return true;
> > 
> > -	if (!sane_reclaim(sc))
> > -		return 0;
> > +	if (sane_reclaim(sc))
> > +		return true;
> 
> We only need a one-line change.

It's bool so the conversion is made to bool while it's being changed
anyway.

> > 
> >  	if (file) {
> >  		inactive = node_page_state(pgdat, NR_INACTIVE_FILE);
> > @@ -1630,7 +1630,7 @@ static int too_many_isolated(struct pglist_data *pgdat, int file,
> >  	if ((sc->gfp_mask & (__GFP_IO | __GFP_FS)) == (__GFP_IO | __GFP_FS))
> >  		inactive >>= 3;
> > 
> > -	return isolated > inactive;
> > +	return isolated < inactive;
> >  }
> > 
> >  static noinline_for_stack void
> > @@ -1719,12 +1719,28 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
> >  	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
> >  	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
> > 
> > -	while (unlikely(too_many_isolated(pgdat, file, sc))) {
> > -		congestion_wait(BLK_RW_ASYNC, HZ/10);
> > +	while (!safe_to_isolate(pgdat, file, sc)) {
> > +		long ret;
> > +
> > +		ret = wait_event_interruptible_timeout(pgdat->isolated_wait,
> > +			safe_to_isolate(pgdat, file, sc), HZ/10);
> > 
> >  		/* We are about to die and free our memory. Return now. */
> > -		if (fatal_signal_pending(current))
> > -			return SWAP_CLUSTER_MAX;
> > +		if (fatal_signal_pending(current)) {
> > +			nr_reclaimed = SWAP_CLUSTER_MAX;
> > +			goto out;
> > +		}
> > +
> > +		/*
> > +		 * If we reached the timeout, this is direct reclaim, and
> > +		 * pages cannot be isolated then return. If the situation
> 
> Please add something that we would rather shrink slab than go
> another round of nap.
> 

That's not necessarily true or even a good idea. It could result in
excessive slab shrinking that is no longer in proportion to LRU scanning
and increased contention within shrinkers.

> > +		 * persists for a long time then it'll eventually reach
> > +		 * the no_progress limit in should_reclaim_retry and consider
> > +		 * going OOM. In this case, do not wake the isolated_wait
> > +		 * queue as the wakee will still not be able to make progress.
> > +		 */
> > +		if (!ret && !current_is_kswapd() && !safe_to_isolate(pgdat, file, sc))
> > +			return 0;
> >  	}
> > 
> >  	lru_add_drain();
> > @@ -1839,6 +1855,10 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
> >  			stat.nr_activate, stat.nr_ref_keep,
> >  			stat.nr_unmap_fail,
> >  			sc->priority, file);
> > +
> > +out:
> > +	if (waitqueue_active(&pgdat->isolated_wait))
> > +		wake_up(&pgdat->isolated_wait);
> >  	return nr_reclaimed;
> >  }
> > 
> Is it also needed to check isolated_wait active before kswapd 
> takes nap?
> 

No because this is where pages were isolated and there is no putback
event that would justify waking the queue. There is a race between
waitqueue_active() and going to sleep that we rely on the timeout to
recover from.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
