Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 45C249000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 20:05:23 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 55C033EE0C2
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 09:05:18 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0095B45DE58
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 09:05:18 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id DA12945DE55
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 09:05:17 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id CBC6BEF8001
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 09:05:17 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 88B711DB8044
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 09:05:17 +0900 (JST)
Date: Wed, 27 Apr 2011 08:58:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] fix get_scan_count for working well with small targets
Message-Id: <20110427085842.877ca83b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <BANLkTikACmxYqczKtJjO_FVWCy2=rVjUMA@mail.gmail.com>
References: <20110426181724.f8cdad57.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTikACmxYqczKtJjO_FVWCy2=rVjUMA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "mgorman@suse.de" <mgorman@suse.de>

On Tue, 26 Apr 2011 10:36:51 -0700
Ying Han <yinghan@google.com> wrote:

> On Tue, Apr 26, 2011 at 2:17 AM, KAMEZAWA Hiroyuki <
> kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > At memory reclaim, we determine the number of pages to be scanned
> > per zone as
> >        (anon + file) >> priority.
> > Assume
> >        scan = (anon + file) >> priority.
> >
> > If scan < SWAP_CLUSTER_MAX, shlink_list will be skipped for this
> > priority and results no-sacn.  This has some problems.
> >
> >  1. This increases priority as 1 without any scan.
> >     To do scan in DEF_PRIORITY always, amount of pages should be larger
> > than
> >     512M. If pages>>priority < SWAP_CLUSTER_MAX, it's recorded and scan
> > will be
> >     batched, later. (But we lose 1 priority.)
> >     But if the amount of pages is smaller than 16M, no scan at priority==0
> >     forever.
> >
> >  2. If zone->all_unreclaimabe==true, it's scanned only when priority==0.
> >     So, x86's ZONE_DMA will never be recoverred until the user of pages
> >     frees memory by itself.
> >
> >  3. With memcg, the limit of memory can be small. When using small memcg,
> >     it gets priority < DEF_PRIORITY-2 very easily and need to call
> >     wait_iff_congested().
> >     For doing scan before priorty=9, 64MB of memory should be used.
> >
> > This patch tries to scan SWAP_CLUSTER_MAX of pages in force...when
> >
> >  1. the target is enough small.
> >  2. it's kswapd or memcg reclaim.
> >
> > Then we can avoid rapid priority drop and may be able to recover
> > all_unreclaimable in a small zones.
> >
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> >  mm/vmscan.c |   31 ++++++++++++++++++++++++++-----
> >  1 file changed, 26 insertions(+), 5 deletions(-)
> >
> > Index: memcg/mm/vmscan.c
> > ===================================================================
> > --- memcg.orig/mm/vmscan.c
> > +++ memcg/mm/vmscan.c
> > @@ -1737,6 +1737,16 @@ static void get_scan_count(struct zone *
> >        u64 fraction[2], denominator;
> >        enum lru_list l;
> >        int noswap = 0;
> > +       int may_noscan = 0;
> > +
> > +
> >
> extra line?
> 
will fix.

> 
> > +       anon  = zone_nr_lru_pages(zone, sc, LRU_ACTIVE_ANON) +
> > +               zone_nr_lru_pages(zone, sc, LRU_INACTIVE_ANON);
> > +       file  = zone_nr_lru_pages(zone, sc, LRU_ACTIVE_FILE) +
> > +               zone_nr_lru_pages(zone, sc, LRU_INACTIVE_FILE);
> > +
> > +       if (((anon + file) >> priority) < SWAP_CLUSTER_MAX)
> > +               may_noscan = 1;
> >
> >        /* If we have no swap space, do not bother scanning anon pages. */
> >        if (!sc->may_swap || (nr_swap_pages <= 0)) {
> > @@ -1747,11 +1757,6 @@ static void get_scan_count(struct zone *
> >                goto out;
> >        }
> >
> > -       anon  = zone_nr_lru_pages(zone, sc, LRU_ACTIVE_ANON) +
> > -               zone_nr_lru_pages(zone, sc, LRU_INACTIVE_ANON);
> > -       file  = zone_nr_lru_pages(zone, sc, LRU_ACTIVE_FILE) +
> > -               zone_nr_lru_pages(zone, sc, LRU_INACTIVE_FILE);
> > -
> >        if (scanning_global_lru(sc)) {
> >                free  = zone_page_state(zone, NR_FREE_PAGES);
> >                /* If we have very few page cache pages,
> > @@ -1814,10 +1819,26 @@ out:
> >                unsigned long scan;
> >
> >                scan = zone_nr_lru_pages(zone, sc, l);
> > +
> >
> extra line?
> 
will fix.

> >                if (priority || noswap) {
> >                        scan >>= priority;
> >                        scan = div64_u64(scan * fraction[file],
> > denominator);
> >                }
> > +
> > +               if (!scan &&
> > +                   may_noscan &&
> > +                   (current_is_kswapd() || !scanning_global_lru(sc))) {
> > +                       /*
> > +                        * if we do target scan, the whole amount of memory
> > +                        * can be too small to scan with low priority
> > value.
> > +                        * This raise up priority rapidly without any scan.
> > +                        * Avoid that and give some scan.
> > +                        */
> > +                       if (file)
> > +                               scan = SWAP_CLUSTER_MAX;
> > +                       else if (!noswap && (fraction[anon] >
> > fraction[file]*16))
> > +                               scan = SWAP_CLUSTER_MAX;
> > +               }
> >
> Ok, so we are changing the global kswapd, and per-memcg bg and direct
> reclaim both. Just to be clear here.

and softlimit reclaim.

> Also, how did we calculated the "16" to be the fraction of anon vs file?
> 
I intended that it implies if file cache is lower than 5-6% of scan target.

With current implementation, which has been used for some long time, we made no
swapout because we do no scan. After this, we may do swapouts which has been
unseen .....I felt it as regression. This check is only for very small zones
or small memcgs. So, I thought it was ok to to limit scanning of anon only when
we needed it. 

Thanks,
-Kame











--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
