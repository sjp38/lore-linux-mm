Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id D8F956B005A
	for <linux-mm@kvack.org>; Fri,  4 Jan 2013 09:52:23 -0500 (EST)
Date: Fri, 4 Jan 2013 15:52:16 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -repost] memcg,vmscan: do not break out targeted reclaim
 without reclaimed pages
Message-ID: <20130104145216.GC22073@dhcp22.suse.cz>
References: <20130103180901.GA22067@dhcp22.suse.cz>
 <20130103122404.033eeb20.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130103122404.033eeb20.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <htejun@gmail.com>, Glauber Costa <glommer@parallels.com>, Li Zefan <lizefan@huawei.com>

On Thu 03-01-13 12:24:04, Andrew Morton wrote:
> On Thu, 3 Jan 2013 19:09:01 +0100
> Michal Hocko <mhocko@suse.cz> wrote:
> 
> > Hi,
> > I have posted this quite some time ago
> > (https://lkml.org/lkml/2012/12/14/102) but it probably slipped through
> > ---
> > >From 28b4e10bc3c18b82bee695b76f4bf25c03baa5f8 Mon Sep 17 00:00:00 2001
> > From: Michal Hocko <mhocko@suse.cz>
> > Date: Fri, 14 Dec 2012 11:12:43 +0100
> > Subject: [PATCH] memcg,vmscan: do not break out targeted reclaim without
> >  reclaimed pages
> > 
> > Targeted (hard resp. soft) reclaim has traditionally tried to scan one
> > group with decreasing priority until nr_to_reclaim (SWAP_CLUSTER_MAX
> > pages) is reclaimed or all priorities are exhausted. The reclaim is
> > then retried until the limit is met.
> > 
> > This approach, however, doesn't work well with deeper hierarchies where
> > groups higher in the hierarchy do not have any or only very few pages
> > (this usually happens if those groups do not have any tasks and they
> > have only re-parented pages after some of their children is removed).
> > Those groups are reclaimed with decreasing priority pointlessly as there
> > is nothing to reclaim from them.
> > 
> > An easiest fix is to break out of the memcg iteration loop in shrink_zone
> > only if the whole hierarchy has been visited or sufficient pages have
> > been reclaimed. This is also more natural because the reclaimer expects
> > that the hierarchy under the given root is reclaimed. As a result we can
> > simplify the soft limit reclaim which does its own iteration.
> > 
> > Reported-by: Ying Han <yinghan@google.com>
> 
> But what was in that report?

Well, Ying was complaining that targeted reclaim differs a lot from
the global one regarding iteration because we reclaim each group in at
the same priority because falling to lower one which targeted reclaim
hammers one group for each zone and priority first before it visits a
next group.
More on that here: https://lkml.org/lkml/2012/12/13/712

> My guess would be "excessive CPU consumption", and perhaps "excessive
> reclaim in the higher-level memcgs".
> IOW, what are the user-visible effects of this change?

I would expect a smaller CPU consumption because save a lot of
per-zone-in-zonelist * per-prio loops without any useful work to do with
deeper hierarchies. I haven't measured that though. I do not expect the
win would be huge because shrink_lruvec should be mostly noop for groups
without any pages (after Johannes recent changes in that area). The
patch is more trying to make it more consistent with the global reclaim.

> (And congrats - you're the first person I've sent that sentence to this
> year!  But not, I fear, the last)
>
> I don't really understand what prevents limit reclaim from stealing
> lots of pages from the top-level groups.  How do we ensure
> balancing/fairness in this case?

All groups in a hierarchy (with root_mem_cgroup for the global
reclaim) are visited in the round robin fashion (per-node
per-zone per-priority).  Last visited group is cached in iterator
(mem_cgroup_per_zone::mem_cgroup_reclaim_iter) and the following reclaim
will start with the next one.
Over reclaim is not an issue because of nr_to_reclaim checks both up the
way in do_try_to_free_pages and shrink_lruvec which make sure we back
off after SWAP_CLUSTER_MAX have been reclaimed.

> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -1973,18 +1973,17 @@ static void shrink_zone(struct zone *zone, struct scan_control *sc)
> 
> shrink_zone() might be getting a bit bloaty for CONFIG_MEMCG=n kernels.

Most of the code should be compiled out because global_reclaim is
compile time true and mem_cgroup_iter returns NULL right away. So all we
do is we waste mem_cgroup_reclaim_cookie on the stack but I guess gcc
should be able to optimize that one out as well (mine does that).

If you are talking about uncompiled code then yes it is getting messy.
Maybe we want to have something like mem_cgroup_shrink_zone and keep
only:
	do {
		mem_cgroup_shrink_zone();
	} while (should_continue_reclaim(...));

here. Dunno if that is a huge win though.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
