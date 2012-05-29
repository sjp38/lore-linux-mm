Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 718B56B005C
	for <linux-mm@kvack.org>; Tue, 29 May 2012 05:35:39 -0400 (EDT)
Date: Tue, 29 May 2012 11:35:11 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC -mm] memcg: prevent from OOM with too many dirty pages
Message-ID: <20120529093511.GE1734@cmpxchg.org>
References: <1338219535-7874-1-git-send-email-mhocko@suse.cz>
 <20120529030857.GA7762@localhost>
 <20120529072853.GD1734@cmpxchg.org>
 <20120529084848.GC10469@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120529084848.GC10469@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujtisu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>

On Tue, May 29, 2012 at 04:48:48PM +0800, Fengguang Wu wrote:
> On Tue, May 29, 2012 at 09:28:53AM +0200, Johannes Weiner wrote:
> > On Tue, May 29, 2012 at 11:08:57AM +0800, Fengguang Wu wrote:
> > > Hi Michal,
> > > 
> > > On Mon, May 28, 2012 at 05:38:55PM +0200, Michal Hocko wrote:
> > > > Current implementation of dirty pages throttling is not memcg aware which makes
> > > > it easy to have LRUs full of dirty pages which might lead to memcg OOM if the
> > > > hard limit is small and so the lists are scanned faster than pages written
> > > > back.
> > > > 
> > > > This patch fixes the problem by throttling the allocating process (possibly
> > > > a writer) during the hard limit reclaim by waiting on PageReclaim pages.
> > > > We are waiting only for PageReclaim pages because those are the pages
> > > > that made one full round over LRU and that means that the writeback is much
> > > > slower than scanning.
> > > > The solution is far from being ideal - long term solution is memcg aware
> > > > dirty throttling - but it is meant to be a band aid until we have a real
> > > > fix.
> > > 
> > > IMHO it's still an important "band aid" -- perhaps worthwhile for
> > > sending to Greg's stable trees. Because it fixes a really important
> > > use case: it enables the users to put backups into a small memcg.
> > > 
> > > The users visible changes are:
> > > 
> > >         the backup program get OOM killed
> > > =>
> > >         it runs now, although being a bit slow and bumpy
> > 
> > The problem is workloads that /don't/ have excessive dirty pages, but
> > instantiate clean page cache at a much faster rate than writeback can
> > clean the few dirties.  The dirty/writeback pages reach the end of the
> > lru several times while there are always easily reclaimable pages
> > around.
> 
> Good point!
> 
> > This was the rationale for introducing the backoff function that
> > considers the dirty page percentage of all pages looked at (bottom of
> > shrink_active_list) and removing all other sleeps that didn't look at
> > the bigger picture and made problems.  I'd hate for them to come back.
> > 
> > On the other hand, is there a chance to make this backoff function
> > work for memcgs?  Right now it only applies to the global case to not
> > mark a whole zone congested because of some dirty pages on a single
> > memcg LRU.  But maybe it can work by considering congestion on a
> > per-lruvec basis rather than per-zone?
> 
> Johannes, would you paste the backoff code? Sorry I'm not sure about
> the exact logic you are talking.

Sure, it's this guy here:

        /*
         * If reclaim is isolating dirty pages under writeback, it implies
         * that the long-lived page allocation rate is exceeding the page
         * laundering rate. Either the global limits are not being effective
         * at throttling processes due to the page distribution throughout
         * zones or there is heavy usage of a slow backing device. The
         * only option is to throttle from reclaim context which is not ideal
         * as there is no guarantee the dirtying process is throttled in the
         * same way balance_dirty_pages() manages.
         *
         * This scales the number of dirty pages that must be under writeback
         * before throttling depending on priority. It is a simple backoff
         * function that has the most effect in the range DEF_PRIORITY to
         * DEF_PRIORITY-2 which is the priority reclaim is considered to be
         * in trouble and reclaim is considered to be in trouble.
         *
         * DEF_PRIORITY   100% isolated pages must be PageWriteback to throttle
         * DEF_PRIORITY-1  50% must be PageWriteback
         * DEF_PRIORITY-2  25% must be PageWriteback, kswapd in trouble
         * ...
         * DEF_PRIORITY-6 For SWAP_CLUSTER_MAX isolated pages, throttle if any
         *                     isolated page is PageWriteback
         */
        if (nr_writeback && nr_writeback >= (nr_taken >> (DEF_PRIORITY-priority)))
                wait_iff_congested(zone, BLK_RW_ASYNC, HZ/10);

But the problem is the part declaring the zone congested:

        /*
         * Tag a zone as congested if all the dirty pages encountered were
         * backed by a congested BDI. In this case, reclaimers should just
         * back off and wait for congestion to clear because further reclaim
         * will encounter the same problem
         */
        if (nr_dirty && nr_dirty == nr_congested && global_reclaim(sc))
                zone_set_flag(mz->zone, ZONE_CONGESTED);

Note the global_reclaim().  It would be nice to have these two operate
against the lruvec of sc->target_mem_cgroup and mz->zone instead.  The
problem is that ZONE_CONGESTED clearing happens in kswapd alone, which
is not necessarily involved in a memcg-constrained load, so we need to
find clearing sites that work for both global and memcg reclaim.

> As for this patch, can it be improved by adding some test like
> (priority < DEF_PRIORITY/2)? That should reasonably filter out the
> "fast read rotating dirty pages fast" situation and still avoid OOM
> for "heavy write inside small memcg".

I think we tried these thresholds for global sync reclaim, too, but
couldn't find the right value.  IIRC, we tried to strike a balance
between excessive stalls and wasting CPU, but obviously the CPU
wasting is not a concern because that is completely uninhibited right
now for memcg reclaim.  So it may be an improvement if I didn't miss
anything.  Maybe Mel remembers more?

It'd still be preferrable to keep the differences between memcg and
global reclaim at a minimum, though, and extend the dirty throttling
we already have.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
