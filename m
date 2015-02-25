Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 926C66B0032
	for <linux-mm@kvack.org>; Tue, 24 Feb 2015 20:42:01 -0500 (EST)
Received: by pdjz10 with SMTP id z10so1117896pdj.0
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 17:42:01 -0800 (PST)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id b7si26175222pas.195.2015.02.24.17.42.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Feb 2015 17:42:00 -0800 (PST)
Received: by pabkx10 with SMTP id kx10so1057754pab.13
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 17:42:00 -0800 (PST)
Date: Wed, 25 Feb 2015 10:41:50 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH RFC 4/4] mm: support MADV_FREE in swapless system
Message-ID: <20150225014150.GC6468@blaptop>
References: <1424765897-27377-1-git-send-email-minchan@kernel.org>
 <1424765897-27377-4-git-send-email-minchan@kernel.org>
 <20150224165146.GC14939@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150224165146.GC14939@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Shaohua Li <shli@kernel.org>, Yalin.Wang@sonymobile.com

On Tue, Feb 24, 2015 at 05:51:46PM +0100, Michal Hocko wrote:
> On Tue 24-02-15 17:18:17, Minchan Kim wrote:
> > Historically, we have disabled reclaiming completely with swapoff
> > or non-swap configurable system. It did make sense but problem
> > for lazy free pages is that we couldn't get a chance to discard
> > hinted pages in reclaim path in those systems.
> > 
> > That's why current MADV_FREE implmentation drop pages instantly
> > like MADV_DONTNNED in swapless system so that users on those
> > systems couldn't get the benefit of MADV_FREE.
> > 
> > This patch makes VM try to reclaim anonymous pages on swapless
> > system. Basic strategy is to try reclaim anonymous pages
> > if there are pages in *inactive anon*.
> 
> Nice idea.
> 
> > In non-swap config system, VM doesn't do aging/reclaiming
> > anonymous LRU list so inactive anon LRU list should be always
> > empty. So, if there are some pages in inactive anon LRU,
> > it means they are MADV_FREE hinted pages so VM try to reclaim
> > them and discard or promote them onto active list.
> > 
> > In swap-config-but-not-yet-swapon, VM doesn't do aging/reclaiming
> > anonymous LRU list so inactive anon LRU list would be empty but
> > it might be not always true because some pages could remain
> > inactive anon list if the admin had swapon before. So, if there
> > are some pages in inactive anon LRU, it means they are MADV_FREE
> > hinted pages or non-hinted pages which have stayed before.
> > VM try to reclaim them and discard or promote them onto active list
> > so we could have only hinted pages on inactive anon LRU list
> > after a while.
> > 
> > In swap-enabled-and-full, VM does aging but not try to reclaim
> > in current implementation. However, we try to reclaim them by
> > this patch so reclaim efficiency would be worse than old.
> > I don't know how many such workloads(ie, doing a job with
> > full-swap for a long time)  we should take care of are.
> 
> Talking about performance when the swap is full is a bit funny. The
> system is crawling at the time most probably.
> 
> > Hope the comment.
> > 
> > On swapoff system with 3G ram, there are 10 processes with below
> > 
> > loop = 12;
> > mmap(256M);
> 
> again what is the memory pressure which fills up the rest of the memory.

256M * 10 processes = 2.5G on 3G ram with swapoff

> 
> > while (loop--) {
> > 	memset(256M);
> > 	madvise(MADV_FREE or MADV_DONTNEED);
> > 	sleep(1);
> > }
> > 
> > 1) dontneed: 5.40user 24.75system 0:15.36elapsed
> > 2) madvfree + this patch: 5.18user 6.90system 0:13.39elapsed
> >
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > ---
> >  mm/madvise.c | 21 ++++++++-------------
> >  mm/vmscan.c  | 32 +++++++++++++++++++++-----------
> >  2 files changed, 29 insertions(+), 24 deletions(-)
> > 
> [...]
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 671e47edb584..1574cd783ab9 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -163,16 +163,23 @@ static bool global_reclaim(struct scan_control *sc)
> >  
> >  static unsigned long zone_reclaimable_pages(struct zone *zone)
> >  {
> > -	int nr;
> > +	unsigned long file, anon;
> >  
> > -	nr = zone_page_state(zone, NR_ACTIVE_FILE) +
> > -	     zone_page_state(zone, NR_INACTIVE_FILE);
> > +	file = zone_page_state(zone, NR_ACTIVE_FILE) +
> > +		zone_page_state(zone, NR_INACTIVE_FILE);
> >  
> > -	if (get_nr_swap_pages() > 0)
> > -		nr += zone_page_state(zone, NR_ACTIVE_ANON) +
> > -		      zone_page_state(zone, NR_INACTIVE_ANON);
> > +	/*
> > +	 * Although there is no swap space, we should consider
> > +	 * lazy free pages in inactive anon LRU list.
> > +	 */
> > +	if (total_swap_pages > 0) {
> > +		anon = zone_page_state(zone, NR_ACTIVE_ANON) +
> > +			zone_page_state(zone, NR_INACTIVE_ANON);
> > +	} else {
> > +		anon = zone_page_state(zone, NR_INACTIVE_ANON);
> > +	}
> 
> Hmm, this doesn't look right to me. The zone would be considered
> reclaimable even though it is not in fact. Most of the systems are
> configured with swap and this would break those AFAICS.

Old behavior:

a: active i: inactive f: file a: anon

1) swapoff : af + if
2) swapon + free space on swap : af + if + aa + ia
3) swapon + no free space on swap : af + if

New behavior

1) swapoff : af + if + ia
In here, ia would be zero most of time unless there are
hinted pages in inactive anon LRU so it would be not different with old.
If there are hinted pages in inactive anon LRU, it's reclaimable pages
potentially so we should include those pages for calc.

2) swapon + free space on swap : af + if + aa + ia

Same with old.

3) swapon + no free space on swap : af + if + ia

I agree this case would be different with old so it would have
side effects(ex, more reclaim trying, OOM delaying). But I don't know
how we take care of fullly swap used system.


> 
> > -	return nr;
> > +	return file + anon;
> >  }
> >  
> >  bool zone_reclaimable(struct zone *zone)
> > @@ -2002,8 +2009,11 @@ static void get_scan_count(struct lruvec *lruvec, int swappiness,
> >  	if (!global_reclaim(sc))
> >  		force_scan = true;
> >  
> > -	/* If we have no swap space, do not bother scanning anon pages. */
> > -	if (!sc->may_swap || (get_nr_swap_pages() <= 0)) {
> > +	/*
> > +	 * If we have no inactive anon page, do not bother scanning
> > +	 * anon pages.
> > +	 */
> > +	if (!sc->may_swap || !zone_page_state(zone, NR_INACTIVE_ANON)) {
> >  		scan_balance = SCAN_FILE;
> >  		goto out;
> >  	}
> 
> but later in the function we are considering active anon pages as well.
> Does this work at all?

I don't understand what your concern is. Could you elaborate it more?
What I want is just to try reclaiming of anonymous pages in situation
where no swap but pages in inactive anon.

Thanks.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
