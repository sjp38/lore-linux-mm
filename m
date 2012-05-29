Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 79CAF6B005C
	for <linux-mm@kvack.org>; Tue, 29 May 2012 09:32:42 -0400 (EDT)
Date: Tue, 29 May 2012 14:32:36 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC -mm] memcg: prevent from OOM with too many dirty pages
Message-ID: <20120529133236.GA29157@suse.de>
References: <1338219535-7874-1-git-send-email-mhocko@suse.cz>
 <20120529030857.GA7762@localhost>
 <20120529072853.GD1734@cmpxchg.org>
 <20120529084848.GC10469@localhost>
 <20120529093511.GE1734@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120529093511.GE1734@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Fengguang Wu <fengguang.wu@intel.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujtisu.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>

I'm afraid this response will be a little rushed. I'm offline from
Thursday for almost a week and trying to get other bits and pieces tied
up before then.

On Tue, May 29, 2012 at 11:35:11AM +0200, Johannes Weiner wrote:
> > > <SNIP>
> > > This was the rationale for introducing the backoff function that
> > > considers the dirty page percentage of all pages looked at (bottom of
> > > shrink_active_list) and removing all other sleeps that didn't look at
> > > the bigger picture and made problems.  I'd hate for them to come back.
> > > 
> > > On the other hand, is there a chance to make this backoff function
> > > work for memcgs?  Right now it only applies to the global case to not
> > > mark a whole zone congested because of some dirty pages on a single
> > > memcg LRU.  But maybe it can work by considering congestion on a
> > > per-lruvec basis rather than per-zone?
> > 
> > Johannes, would you paste the backoff code? Sorry I'm not sure about
> > the exact logic you are talking.
> 
> Sure, it's this guy here:
> 
>         /*
>          * If reclaim is isolating dirty pages under writeback, it implies
>          * that the long-lived page allocation rate is exceeding the page
>          * laundering rate. Either the global limits are not being effective
>          * at throttling processes due to the page distribution throughout
>          * zones or there is heavy usage of a slow backing device. The
>          * only option is to throttle from reclaim context which is not ideal
>          * as there is no guarantee the dirtying process is throttled in the
>          * same way balance_dirty_pages() manages.
>          *
>          * This scales the number of dirty pages that must be under writeback
>          * before throttling depending on priority. It is a simple backoff
>          * function that has the most effect in the range DEF_PRIORITY to
>          * DEF_PRIORITY-2 which is the priority reclaim is considered to be
>          * in trouble and reclaim is considered to be in trouble.
>          *
>          * DEF_PRIORITY   100% isolated pages must be PageWriteback to throttle
>          * DEF_PRIORITY-1  50% must be PageWriteback
>          * DEF_PRIORITY-2  25% must be PageWriteback, kswapd in trouble
>          * ...
>          * DEF_PRIORITY-6 For SWAP_CLUSTER_MAX isolated pages, throttle if any
>          *                     isolated page is PageWriteback
>          */
>         if (nr_writeback && nr_writeback >= (nr_taken >> (DEF_PRIORITY-priority)))
>                 wait_iff_congested(zone, BLK_RW_ASYNC, HZ/10);
> 
> But the problem is the part declaring the zone congested:
> 
>         /*
>          * Tag a zone as congested if all the dirty pages encountered were
>          * backed by a congested BDI. In this case, reclaimers should just
>          * back off and wait for congestion to clear because further reclaim
>          * will encounter the same problem
>          */
>         if (nr_dirty && nr_dirty == nr_congested && global_reclaim(sc))
>                 zone_set_flag(mz->zone, ZONE_CONGESTED);
> 
> Note the global_reclaim().  It would be nice to have these two operate
> against the lruvec of sc->target_mem_cgroup and mz->zone instead.  The
> problem is that ZONE_CONGESTED clearing happens in kswapd alone, which
> is not necessarily involved in a memcg-constrained load, so we need to
> find clearing sites that work for both global and memcg reclaim.
> 

I talked with Michal about this a bit offline and I hope I represent the
discussion fairly.

In my opinion it would be quite complex but you could create
a MEMCG_CONGESTED that is set under similar circumstances to
ZONE_CONGESTED. The ideal would be to clear it when enough writeback had
happened within a memcg to be below the limits but the accounting for
that just isn't there. An alternative would be to clear the flag if *any*
page within that memcg gets cleaned which is clumsy but better than nothing
when we cannot depend on kswapd.

On that is in place I can see two ways of acting based on the congestion
information

1. wait_on_page_writeback iff MEMCG_CONGESTED as Michal's patch does

2 Teach wait_iff_congested() about sleeping based on either the zone or
  the memcg. i.e. sleep for either HZ/10 or until the MEMCG_CONGESTED flag
  gets cleared. It would then need to loop again after sleeping to ensure
  it didn't go OOM.

Of course, an important thing to remember is that even *if* this works
better that it shouldn't stop us starting with Michal's patch as a
not-very-pretty-but-avoids-KABLAMO solution and merge that to mainline and
-stable. Then either build upon it or revert it when a proper solution is
found. Don't ignore something that works and fixes a serious problem just
because something better may or may not exist :)

> > As for this patch, can it be improved by adding some test like
> > (priority < DEF_PRIORITY/2)? That should reasonably filter out the
> > "fast read rotating dirty pages fast" situation and still avoid OOM
> > for "heavy write inside small memcg".
> 
> I think we tried these thresholds for global sync reclaim, too, but
> couldn't find the right value. 

Yes.

> IIRC, we tried to strike a balance
> between excessive stalls and wasting CPU, but obviously the CPU
> wasting is not a concern because that is completely uninhibited right
> now for memcg reclaim.  So it may be an improvement if I didn't miss
> anything.  Maybe Mel remembers more?
> 

I think that would just be fiddling around with thresholds and how effective
would depend on too many factors such as memcg size and the speed of the
backing storage. It is preferable to me that memcgs would behave like
global reclaim in this respect by setting a congested flag and blocking
iff it is set and if it does block, wake up again when that flag is cleared.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
