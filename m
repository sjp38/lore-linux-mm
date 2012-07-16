Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 495286B004D
	for <linux-mm@kvack.org>; Mon, 16 Jul 2012 04:48:20 -0400 (EDT)
Date: Mon, 16 Jul 2012 10:48:16 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2 -mm] memcg: prevent from OOM with too many dirty pages
Message-ID: <20120716084816.GB14664@tiehlicka.suse.cz>
References: <1340117404-30348-1-git-send-email-mhocko@suse.cz>
 <20120619150014.1ebc108c.akpm@linux-foundation.org>
 <20120620101119.GC5541@tiehlicka.suse.cz>
 <alpine.LSU.2.00.1207111818380.1299@eggly.anvils>
 <20120712070501.GB21013@tiehlicka.suse.cz>
 <alpine.LSU.2.00.1207160044070.3936@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1207160044070.3936@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Fengguang Wu <fengguang.wu@intel.com>

On Mon 16-07-12 01:10:47, Hugh Dickins wrote:
> On Thu, 12 Jul 2012, Michal Hocko wrote:
> > On Wed 11-07-12 18:57:43, Hugh Dickins wrote:
> > > 
> > > I mentioned in Johannes's [03/11] thread a couple of days ago, that
> > > I was having a problem with your wait_on_page_writeback() in mmotm.
> > > 
> > > It turns out that your original patch was fine, but you let dark angels
> > > whisper into your ear, to persuade you to remove the "&& may_enter_fs".
> > > 
> > > Part of my load builds kernels on extN over loop over tmpfs: loop does
> > > mapping_set_gfp_mask(mapping, lo->old_gfp_mask & ~(__GFP_IO|__GFP_FS))
> > > because it knows it will deadlock, if the loop thread enters reclaim,
> > > and reclaim tries to write back a dirty page, one which needs the loop
> > > thread to perform the write.
> > 
> > Good catch! I have totally missed the loop driver.
> > 
> > > With the may_enter_fs check restored, all is well.
> 
> Not as well as I thought when I wrote that: but those issues I'll deal
> with in separate mail (and my alternative patch was no better).
> 
> > > I don't entirely
> > > like your patch: I think it would be much better to wait in the same
> > > place as the wait_iff_congested(), when the pages gathered have been
> > > sent for writing and unlocked and putback and freed; 
> > 
> > I guess you mean
> > 	if (nr_writeback && nr_writeback >=
> >                         (nr_taken >> (DEF_PRIORITY - sc->priority)))
> >                 wait_iff_congested(zone, BLK_RW_ASYNC, HZ/10);
> 
> Yes, I've appended the patch I was meaning below; but although it's
> the way I had approached the issue, I don't in practice see any better
> behaviour from mine than from yours.  So unless a good reason appears
> later, to do it my way instead of yours, let's just forget about mine.

OK

> > I have tried to hook here but it has some issues. First of all we do not
> > know how long we should wait. Waiting for specific pages sounded more
> > event based and more precise.
> > 
> > We can surely do better but I wanted to stop the OOM first without any
> > other possible side effects on the global reclaim. I have tried to make
> > the band aid as simple as possible. Memcg dirty pages accounting is
> > forming already so we are one (tiny) step closer to the throttling.
> >  
> > > and I also wonder if it should go beyond the !global_reclaim case for
> > > swap pages, because they don't participate in dirty limiting.
> > 
> > Worth a separate patch?
> 
> If I could ever generate a suitable testcase, yes.  But in practice,
> the only way I've managed to generate such a preponderance of swapping
> over file reclaim, is by using memcgs, which your patch already catches.
> And if there actually is the swapping issue I suggest, then it's been
> around for a very long time, apparently without complaint.
> 
> Here is the patch I had in mind: I'm posting it as illustration, so we
> can look back to it in the archives if necessary; but it's definitely
> not signed-off, I've seen no practical advantage over yours, probably
> we just forget about this one below now.
> 
> But more mail to follow, returning to yours...
> 
> Hugh
> 
> p.s. KAMEZAWA-san, if you wonder why you're suddenly brought into this
> conversation, it's because there was a typo in your email address before.

Sorry, my fault. I misspelled the domain (jp.fujtisu.com).

> --- 3.5-rc6/vmscan.c	2012-06-03 06:42:11.000000000 -0700
> +++ linux/vmscan.c	2012-07-13 11:53:20.372087273 -0700
> @@ -675,7 +675,8 @@ static unsigned long shrink_page_list(st
>  				      struct zone *zone,
>  				      struct scan_control *sc,
>  				      unsigned long *ret_nr_dirty,
> -				      unsigned long *ret_nr_writeback)
> +				      unsigned long *ret_nr_writeback,
> +				      struct page **slow_page)
>  {
>  	LIST_HEAD(ret_pages);
>  	LIST_HEAD(free_pages);
> @@ -720,6 +721,27 @@ static unsigned long shrink_page_list(st
>  			(PageSwapCache(page) && (sc->gfp_mask & __GFP_IO));
>  
>  		if (PageWriteback(page)) {
> +			/*
> +			 * memcg doesn't have any dirty pages throttling so we
> +			 * could easily OOM just because too many pages are in
> +			 * writeback from reclaim and there is nothing else to
> +			 * reclaim.  Nor is swap subject to dirty throttling.
> +			 *
> +			 * Check may_enter_fs, certainly because a loop driver
> +			 * thread might enter reclaim, and deadlock if it waits
> +			 * on a page for which it is needed to do the write
> +			 * (loop masks off __GFP_IO|__GFP_FS for this reason);
> +			 * but more thought would probably show more reasons.
> +			 *
> +			 * Just use one page per shrink for this: wait on its
> +			 * writeback once we have done the rest.  If device is
> +			 * slow, in due course we shall choose one of its pages.
> +			 */
> +			if (!*slow_page && may_enter_fs && PageReclaim(page) &&
> +			    (PageSwapCache(page) || !global_reclaim(sc))) {
> +				*slow_page = page;
> +				get_page(page);
> +			}
>  			nr_writeback++;
>  			unlock_page(page);
>  			goto keep;
> @@ -1208,6 +1230,7 @@ shrink_inactive_list(unsigned long nr_to
>  	int file = is_file_lru(lru);
>  	struct zone *zone = lruvec_zone(lruvec);
>  	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
> +	struct page *slow_page = NULL;
>  
>  	while (unlikely(too_many_isolated(zone, file, sc))) {
>  		congestion_wait(BLK_RW_ASYNC, HZ/10);
> @@ -1245,7 +1268,7 @@ shrink_inactive_list(unsigned long nr_to
>  		return 0;
>  
>  	nr_reclaimed = shrink_page_list(&page_list, zone, sc,
> -						&nr_dirty, &nr_writeback);
> +					&nr_dirty, &nr_writeback, &slow_page);
>  
>  	spin_lock_irq(&zone->lru_lock);
>  
> @@ -1292,8 +1315,13 @@ shrink_inactive_list(unsigned long nr_to
>  	 *                     isolated page is PageWriteback
>  	 */
>  	if (nr_writeback && nr_writeback >=
> -			(nr_taken >> (DEF_PRIORITY - sc->priority)))
> +			(nr_taken >> (DEF_PRIORITY - sc->priority))) {
>  		wait_iff_congested(zone, BLK_RW_ASYNC, HZ/10);
> +		if (slow_page && PageReclaim(slow_page))
> +			wait_on_page_writeback(slow_page);
> +	}
> +	if (slow_page)
> +		put_page(slow_page);

Hmm. This relies on another round of shrinking because even if we wait
for the page it doesn't add up to nr_reclaimed. Not a big deal in
practice I guess because those will be rotated and seen in the next
loop. We are reclaiming with priority 0 so the whole list so we should
gather SWAP_CLUSTER pages sooner or later so the patch seems to be
correct.
It should even cope with the sudden latency issue when seeing a random
PageReclaim page in the middle of the LRU mentioned by Johannes. I
wasn't able to trigger this issue though and I think it is more a
theoretical than real one.

Anyway, thanks for looking into this. It's good to see there is other
approach as well so that we can compare.

>  	trace_mm_vmscan_lru_shrink_inactive(zone->zone_pgdat->node_id,
>  		zone_idx(zone),

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
