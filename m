Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f44.google.com (mail-ee0-f44.google.com [74.125.83.44])
	by kanga.kvack.org (Postfix) with ESMTP id 7C9616B0035
	for <linux-mm@kvack.org>; Wed, 30 Apr 2014 05:09:34 -0400 (EDT)
Received: by mail-ee0-f44.google.com with SMTP id c41so1093876eek.3
        for <linux-mm@kvack.org>; Wed, 30 Apr 2014 02:09:33 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x46si30012314eea.329.2014.04.30.02.09.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 30 Apr 2014 02:09:32 -0700 (PDT)
Date: Wed, 30 Apr 2014 11:09:28 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC PATCH] vmscan: memcg: Always use swappiness of the
 reclaimed memcg swappiness and oom_control
Message-ID: <20140430090928.GC4357@dhcp22.suse.cz>
References: <1397682798-22906-1-git-send-email-hannes@cmpxchg.org>
 <20140418113611.GA7568@dhcp22.suse.cz>
 <20140424121917.GB4107@cmpxchg.org>
 <20140424142704.GC7644@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140424142704.GC7644@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

ping

On Thu 24-04-14 16:27:04, Michal Hocko wrote:
> On Thu 24-04-14 08:19:17, Johannes Weiner wrote:
> > On Fri, Apr 18, 2014 at 01:36:11PM +0200, Michal Hocko wrote:
> > > On Wed 16-04-14 17:13:18, Johannes Weiner wrote:
> > > > Per-memcg swappiness and oom killing can currently not be tweaked on a
> > > > memcg that is part of a hierarchy, but not the root of that hierarchy.
> > > > Users have complained that they can't configure this when they turned
> > > > on hierarchy mode.  In fact, with hierarchy mode becoming the default,
> > > > this restriction disables the tunables entirely.
> > > 
> > > Except when we would handle the first level under root differently,
> > > which is ugly.
> > > 
> > > > But there is no good reason for this restriction. 
> > > 
> > > I had a patch for this somewhere on the think_more pile. I wasn't
> > > particularly happy about the semantic so I haven't posted it.
> > > 
> > > > The settings for
> > > > swappiness and OOM killing are taken from whatever memcg whose limit
> > > > triggered reclaim and OOM invocation, regardless of its position in
> > > > the hierarchy tree.
> > > 
> > > This is OK for the OOM knob because the memory pressure cannot be
> > > handled at that level in hierarchy and that is where the OOM happens.
> > > 
> > > I am not so sure about the swappiness though. The swappiness tells us
> > > how to proportionally scan anon vs. file LRUs and those are per-memcg,
> > > not per-hierarchy (unlike the charge) so it makes sense to use it
> > > per-memcg IMO.
> > > 
> > > Besides that using the reclaim target value might be quite confusing.
> > > Say, somebody wants to prevent from swapping in a certain group and
> > > yet the pages find their way to swap depending on where the reclaim is
> > > triggered from.
> > > Another thing would be that setting swappiness on an unlimited group has
> > > no effect although I would argue it makes some sense in configuration
> > > when parent is controlled by somebody else. I would like to tell how
> > > to reclaim me when I cannot say how much memory I can have. 
> > > 
> > > It is true that we have a different behavior for the global reclaim
> > > already but I am not entirely happy about that. Having a different
> > > behavior for the global vs. limit reclaims just calls for troubles and
> > > should be avoided as much as possible.
> > > 
> > > So let's think what is the best semantic before we merge this. I would
> > > be more inclined for using per-memcg swappiness all the time (root using
> > > the global knob) for all reclaims.
> > 
> > Yeah, we've always used the triggering group's swappiness value but at
> > the same time forced the whole hierarchy to have the same setting as
> > the root.
> > 
> > I don't really feel strongly about this.  If you prefer the per-memcg
> > swappiness I can send a followup patch - or you can.
> 
> OK, I originally thought this would be in the same patch but now that I
> think about it some more it would be better to have it separate in case
> it turns out this will cause some issues (at least
> global_reclaim-always-use-global-vm_swappiness is a behavior change).
> So what do you think about this?
> ---
> From 3a865b7b53aed96d93bbcf865028e63fd6f582ab Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.cz>
> Date: Thu, 24 Apr 2014 15:28:05 +0200
> Subject: [RFC PATCH] vmscan: memcg: Always use swappiness of the reclaimed memcg
> 
> The memory reclaim always uses swappiness of the reclaim target memcg
> (origin of the memory pressure) or vm_swappiness for the global memory
> reclaim. This behavior was consistent (except for difference between
> global and hard limit reclaim) because swappiness was enforced to be
> consistent within each memcg hierarchy.
> 
> After "mm: memcontrol: remove hierarchy restrictions for swappiness
> and oom_control" each memcg can have its own swappiness independent on
> hierarchical parents, though, so the consistency guarantee is gone.
> This can lead to an unexpected behavior. Say that a group is explicitly
> configured to not swapout by memory.swappiness=0 but its memory gets
> swapped out anyway when the memory pressure comes from its parent with a
> different swapping policy.
> It is also unexpected that the knob is meaningless without setting the
> hard limit which would trigger the reclaim and enforce the swappiness.
> There are setups where the hard limit is configured higher in the
> hierarchy by an administrator and children groups are under control of
> somebody else who is interested in the swapout behavior but not
> necessarily about the memory limit.
> 
> From a semantic point of view swappiness is an attribute defining
> anon vs. file proportional scanning of LRU which is memcg specific
> (unlike charges which are propagated up the hierarchy) so it should be
> applied to the particular memcg's LRU regardless where the memory
> pressure comes from.
> 
> This patch removes vmscan_swappiness() and stores the swappiness into
> the scan_control structure. mem_cgroup_swappiness is then used to
> provide the correct value before shrink_lruvec is called.  The global
> vm_swappiness is used for the root memcg.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> ---
>  Documentation/cgroups/memory.txt | 15 +++++++--------
>  mm/vmscan.c                      | 18 ++++++++----------
>  2 files changed, 15 insertions(+), 18 deletions(-)
> 
> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> index 4937e6fff9b4..b3429aec444c 100644
> --- a/Documentation/cgroups/memory.txt
> +++ b/Documentation/cgroups/memory.txt
> @@ -540,14 +540,13 @@ Note:
>  
>  5.3 swappiness
>  
> -Similar to /proc/sys/vm/swappiness, but only affecting reclaim that is
> -triggered by this cgroup's hard limit.  The tunable in the root cgroup
> -corresponds to the global swappiness setting.
> -
> -Please note that unlike the global swappiness, memcg knob set to 0
> -really prevents from any swapping even if there is a swap storage
> -available. This might lead to memcg OOM killer if there are no file
> -pages to reclaim.
> +Overrides /proc/sys/vm/swappiness for the particular group. The tunable
> +in the root cgroup corresponds to the global swappiness setting.
> +
> +Please note that unlike during the global reclaim, limit reclaim
> +enforces that 0 swappiness really prevents from any swapping even if
> +there is a swap storage available. This might lead to memcg OOM killer
> +if there are no file pages to reclaim.
>  
>  5.4 failcnt
>  
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 310e1f67625e..7d2f8226cbd0 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -86,6 +86,9 @@ struct scan_control {
>  	/* Scan (total_size >> priority) pages at once */
>  	int priority;
>  
> +	/* anon vs. file LRUs scanning "ratio" */
> +	int swappiness;
> +
>  	/*
>  	 * The memory cgroup that hit its limit and as a result is the
>  	 * primary target of this reclaim invocation.
> @@ -1833,13 +1836,6 @@ static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
>  	return shrink_inactive_list(nr_to_scan, lruvec, sc, lru);
>  }
>  
> -static int vmscan_swappiness(struct scan_control *sc)
> -{
> -	if (global_reclaim(sc))
> -		return vm_swappiness;
> -	return mem_cgroup_swappiness(sc->target_mem_cgroup);
> -}
> -
>  enum scan_balance {
>  	SCAN_EQUAL,
>  	SCAN_FRACT,
> @@ -1900,7 +1896,7 @@ static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
>  	 * using the memory controller's swap limit feature would be
>  	 * too expensive.
>  	 */
> -	if (!global_reclaim(sc) && !vmscan_swappiness(sc)) {
> +	if (!global_reclaim(sc) && !sc->swappiness) {
>  		scan_balance = SCAN_FILE;
>  		goto out;
>  	}
> @@ -1910,7 +1906,7 @@ static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
>  	 * system is close to OOM, scan both anon and file equally
>  	 * (unless the swappiness setting disagrees with swapping).
>  	 */
> -	if (!sc->priority && vmscan_swappiness(sc)) {
> +	if (!sc->priority && sc->swappiness) {
>  		scan_balance = SCAN_EQUAL;
>  		goto out;
>  	}
> @@ -1935,7 +1931,7 @@ static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
>  	 * With swappiness at 100, anonymous and file have the same priority.
>  	 * This scanning priority is essentially the inverse of IO cost.
>  	 */
> -	anon_prio = vmscan_swappiness(sc);
> +	anon_prio = sc->swappiness;
>  	file_prio = 200 - anon_prio;
>  
>  	/*
> @@ -2221,6 +2217,7 @@ static void shrink_zone(struct zone *zone, struct scan_control *sc)
>  
>  			lruvec = mem_cgroup_zone_lruvec(zone, memcg);
>  
> +			sc->swappiness = mem_cgroup_swappiness(memcg);
>  			shrink_lruvec(lruvec, sc);
>  
>  			/*
> @@ -2678,6 +2675,7 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *memcg,
>  		.may_swap = !noswap,
>  		.order = 0,
>  		.priority = 0,
> +		.swappiness = mem_cgroup_swappiness(memcg),
>  		.target_mem_cgroup = memcg,
>  	};
>  	struct lruvec *lruvec = mem_cgroup_zone_lruvec(zone, memcg);
> -- 
> 1.9.2
> 
> -- 
> Michal Hocko
> SUSE Labs
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
