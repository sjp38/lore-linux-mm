Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2FF378D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 04:54:08 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id D5F763EE0AE
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 17:54:03 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B9D7C45DE69
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 17:54:03 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A1DC745DD74
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 17:54:03 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 94EE51DB803F
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 17:54:03 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 517EA1DB8038
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 17:54:03 +0900 (JST)
Date: Mon, 28 Mar 2011 17:44:21 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/2] check the return value of soft_limit reclaim
Message-Id: <20110328174421.6ac9ada0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110328154033.F068.A69D9226@jp.fujitsu.com>
References: <1301292775-4091-1-git-send-email-yinghan@google.com>
	<1301292775-4091-2-git-send-email-yinghan@google.com>
	<20110328154033.F068.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Ying Han <yinghan@google.com>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Mon, 28 Mar 2011 15:39:59 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> > In the global background reclaim, we do soft reclaim before scanning the
> > per-zone LRU. However, the return value is ignored. This patch adds the logic
> > where no per-zone reclaim happens if the soft reclaim raise the free pages
> > above the zone's high_wmark.
> > 
> > I did notice a similar check exists but instead leaving a "gap" above the
> > high_wmark(the code right after my change in vmscan.c). There are discussions
> > on whether or not removing the "gap" which intends to balance pressures across
> > zones over time. Without fully understand the logic behind, I didn't try to
> > merge them into one, but instead adding the condition only for memcg users
> > who care a lot on memory isolation.
> > 
> > Signed-off-by: Ying Han <yinghan@google.com>
> 
> Looks good to me. But this depend on "memcg soft limit" spec. To be honest,
> I don't know this return value ignorance is intentional or not. So I think 
> you need to get ack from memcg folks.
> 
> 
Hi,


> > ---
> >  mm/vmscan.c |   16 +++++++++++++++-
> >  1 files changed, 15 insertions(+), 1 deletions(-)
> > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 060e4c1..e4601c5 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -2320,6 +2320,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
> >  	int end_zone = 0;	/* Inclusive.  0 = ZONE_DMA */
> >  	unsigned long total_scanned;
> >  	struct reclaim_state *reclaim_state = current->reclaim_state;
> > +	unsigned long nr_soft_reclaimed;
> >  	struct scan_control sc = {
> >  		.gfp_mask = GFP_KERNEL,
> >  		.may_unmap = 1,
> > @@ -2413,7 +2414,20 @@ loop_again:
> >  			 * Call soft limit reclaim before calling shrink_zone.
> >  			 * For now we ignore the return value
> >  			 */
> > -			mem_cgroup_soft_limit_reclaim(zone, order, sc.gfp_mask);
> > +			nr_soft_reclaimed = mem_cgroup_soft_limit_reclaim(zone,
> > +							order, sc.gfp_mask);
> > +
> > +			/*
> > +			 * Check the watermark after the soft limit reclaim. If
> > +			 * the free pages is above the watermark, no need to
> > +			 * proceed to the zone reclaim.
> > +			 */
> > +			if (nr_soft_reclaimed && zone_watermark_ok_safe(zone,
> > +					order, high_wmark_pages(zone),
> > +					end_zone, 0)) {
> > +				__inc_zone_state(zone, NR_SKIP_RECLAIM_GLOBAL);
> 
> NR_SKIP_RECLAIM_GLOBAL is defined by patch 2/2. please don't break bisectability.
> 
> 
> 
> > +				continue;
> > +			}

Hmm, this "continue" seems not good to me. And, IIUC, this was a reason
we ignore the result. But yes, ignore the result is bad.
I think you should just do sc.nr_reclaimed += nr_soft_reclaimed.
Or mem_cgroup_soft_limit_reclaim() should update sc.


And allow kswapd to do some jobs as
 - call shrink_slab()
 - update total_scanned
 - update other flags.. etc...etc..

If extra shink_zone() seems bad, please skip it, if mem_cgroup_soft_limit_reclaim()
did enough jobs.

IOW, mem_cgroup_soft_limit_reclaim() can't do enough jobs to satisfy
==
   2426 			balance_gap = min(low_wmark_pages(zone),
   2427 				(zone->present_pages +
   2428 					KSWAPD_ZONE_BALANCE_GAP_RATIO-1) /
   2429 				KSWAPD_ZONE_BALANCE_GAP_RATIO);
   2430 			if (!zone_watermark_ok_safe(zone, order,
   2431 					high_wmark_pages(zone) + balance_gap,
   2432 					end_zone, 0))
   2433 				shrink_zone(priority, zone, &sc);
==
This condition, you should update mem_cgroup_soft_limit_relcaim() to satisfy this,
rather than continue here.

I guess this is not easy...So, how about starting from updating 'sc' passed to 
mem_cgroup_soft_limit_reclaim() ? Then, we can think of algorithm.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
