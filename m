Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 85DE160021B
	for <linux-mm@kvack.org>; Wed, 30 Dec 2009 08:07:13 -0500 (EST)
Date: Wed, 30 Dec 2009 22:06:46 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/4] vmscan: get_scan_ratio cleanup
In-Reply-To: <20091229073412.GN3601@balbir.in.ibm.com>
References: <20091228164733.A68A.A69D9226@jp.fujitsu.com> <20091229073412.GN3601@balbir.in.ibm.com>
Message-Id: <20091230214955.1A10.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> * KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> [2009-12-28 16:48:06]:
> 
> > The get_scan_ratio() should have all scan-ratio related calculations.
> > Thus, this patch move some calculation into get_scan_ratio.
> > 
> > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > ---
> >  mm/vmscan.c |   23 ++++++++++++++---------
> >  1 files changed, 14 insertions(+), 9 deletions(-)
> > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 2bbee91..640486b 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -1501,6 +1501,13 @@ static void get_scan_ratio(struct zone *zone, struct scan_control *sc,
> >  	unsigned long ap, fp;
> >  	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
> > 
> > +	/* If we have no swap space, do not bother scanning anon pages. */
> > +	if (!sc->may_swap || (nr_swap_pages <= 0)) {
> > +		percent[0] = 0;
> > +		percent[1] = 100;
> > +		return;
> > +	}
> > +
> 
> 
> >  	anon  = zone_nr_lru_pages(zone, sc, LRU_ACTIVE_ANON) +
> >  		zone_nr_lru_pages(zone, sc, LRU_INACTIVE_ANON);
> >  	file  = zone_nr_lru_pages(zone, sc, LRU_ACTIVE_FILE) +
> > @@ -1598,22 +1605,20 @@ static void shrink_zone(int priority, struct zone *zone,
> >  	unsigned long nr_reclaimed = sc->nr_reclaimed;
> >  	unsigned long nr_to_reclaim = sc->nr_to_reclaim;
> >  	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
> > -	int noswap = 0;
> > 
> > -	/* If we have no swap space, do not bother scanning anon pages. */
> > -	if (!sc->may_swap || (nr_swap_pages <= 0)) {
> > -		noswap = 1;
> > -		percent[0] = 0;
> > -		percent[1] = 100;
> > -	} else
> > -		get_scan_ratio(zone, sc, percent);
> > +	get_scan_ratio(zone, sc, percent);
> 
> Where do we set noswap? Is percent[0] == 0 used to indicate noswap =
> 1?

Yes, I intended so. I guess your question can convert next sentence.

	following case makes different result, is it intentional?
	  - there are free swap
	  - sc->may_swap == 1
	  - priority == 0
	  - percent[0] == 0

My answer is, it isn't happen on practical workload. if priority reach to 0, vmscan always
scan and reclaim some anon (please recall, now vmscan automatically enable lumpy_reclaim
if priority < 10), then recent_rotated_anon isn't 0 always.. practically.

Do you think this is wrong assumption?


> >  	for_each_evictable_lru(l) {
> >  		int file = is_file_lru(l);
> >  		unsigned long scan;
> > 
> > +		if (percent[file] == 0) {
> > +			nr[l] = 0;
> > +			continue;
> > +		}
> > +
> 
> Is this really needed? Won't nr_scan_try_batch handle it correctly?

this two if branch is nicer than "priority || noswap", I think.
it clearly explain what do it.

> 
> >  		scan = zone_nr_lru_pages(zone, sc, l);
> > -		if (priority || noswap) {
> > +		if (priority) {
> >  			scan >>= priority;
> >  			scan = (scan * percent[file]) / 100;
> >  		}
> 
> -- 
> 	Balbir



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
