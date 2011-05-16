Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 0F74990010B
	for <linux-mm@kvack.org>; Mon, 16 May 2011 19:11:02 -0400 (EDT)
Date: Tue, 17 May 2011 01:10:28 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [rfc patch 4/6] memcg: reclaim statistics
Message-ID: <20110516231028.GV16531@cmpxchg.org>
References: <1305212038-15445-1-git-send-email-hannes@cmpxchg.org>
 <1305212038-15445-5-git-send-email-hannes@cmpxchg.org>
 <BANLkTi=yCyAsOc_uTQLp1kWp5w0i9gomxg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BANLkTi=yCyAsOc_uTQLp1kWp5w0i9gomxg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, May 12, 2011 at 12:33:50PM -0700, Ying Han wrote:
> On Thu, May 12, 2011 at 7:53 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > TODO: write proper changelog.  Here is an excerpt from
> > http://lkml.kernel.org/r/20110428123652.GM12437@cmpxchg.org:
> >
> > : 1. Limit-triggered direct reclaim
> > :
> > : The memory cgroup hits its limit and the task does direct reclaim from
> > : its own memcg.  We probably want statistics for this separately from
> > : background reclaim to see how successful background reclaim is, the
> > : same reason we have this separation in the global vmstat as well.
> > :
> > :       pgscan_direct_limit
> > :       pgfree_direct_limit
> >
> 
> Can we use "pgsteal_" instead? Not big fan of the naming but want to make
> them consistent to other stats.

Actually, I thought what KAME-san said made sense.  'Stealing' is a
good fit for reclaim due to outside pressure.  But if the memcg is
target-reclaimed from the inside because it hit the limit, is
'stealing' the appropriate term?

> > : 2. Limit-triggered background reclaim
> > :
> > : This is the watermark-based asynchroneous reclaim that is currently in
> > : discussion.  It's triggered by the memcg breaching its watermark,
> > : which is relative to its hard-limit.  I named it kswapd because I
> > : still think kswapd should do this job, but it is all open for
> > : discussion, obviously.  Treat it as meaning 'background' or
> > : 'asynchroneous'.
> > :
> > :       pgscan_kswapd_limit
> > :       pgfree_kswapd_limit
> >
> 
> Kame might have this stats on the per-memcg bg reclaim patch. Just mention
> here since it will make later merge
> a bit harder

I'll have a look, thanks for the heads up.

> > : 3. Hierarchy-triggered direct reclaim
> > :
> > : A condition outside the memcg leads to a task directly reclaiming from
> > : this memcg.  This could be global memory pressure for example, but
> > : also a parent cgroup hitting its limit.  It's probably helpful to
> > : assume global memory pressure meaning that the root cgroup hit its
> > : limit, conceptually.  We don't have that yet, but this could be the
> > : direct softlimit reclaim Ying mentioned above.
> > :
> > :       pgscan_direct_hierarchy
> > :       pgsteal_direct_hierarchy
> >
> 
>  The stats for soft_limit reclaim from global ttfp have been merged in mmotm
> i believe as the following:
> 
> "soft_direct_steal"
> "soft_direct_scan"
> 
> I wonder we might want to separate that out from the other case where the
> reclaim is from the parent triggers its limit.

The way I implemented soft limits in 6/6 is to increase pressure on
exceeding children whenever hierarchical reclaim is taking place.

This changes soft limit from

	Global memory pressure: reclaim from exceeding memcg(s) first

to

	Memory pressure on a memcg: reclaim from all its children,
	with increased pressure on those exceeding their soft limit
	(where global memory pressure means root_mem_cgroup and all
	existing memcgs are considered its children)

which makes the soft limit much more generic and more powerful, as it
allows the admin to prioritize reclaim throughout the hierarchy, not
only for global memory pressure.  Consider one memcg with two
subgroups.  You can now prioritize reclaim to prefer one subgroup over
another through soft limiting.

This is one reason why I think that the approach of maintaining a
global list of memcgs that exceed their soft limits is an inferior
approach; it does not take the hierarchy into account at all.

This scheme would not provide a natural way of counting pages that
were reclaimed because of the soft limit, and thus I still oppose the
merging of soft limit counters.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
