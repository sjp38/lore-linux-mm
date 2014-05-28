Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f176.google.com (mail-we0-f176.google.com [74.125.82.176])
	by kanga.kvack.org (Postfix) with ESMTP id B20306B0035
	for <linux-mm@kvack.org>; Wed, 28 May 2014 10:21:53 -0400 (EDT)
Received: by mail-we0-f176.google.com with SMTP id q59so11058548wes.7
        for <linux-mm@kvack.org>; Wed, 28 May 2014 07:21:52 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m2si14031318wiz.34.2014.05.28.07.21.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 28 May 2014 07:21:49 -0700 (PDT)
Date: Wed, 28 May 2014 16:21:44 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2 0/4] memcg: Low-limit reclaim
Message-ID: <20140528142144.GL9895@dhcp22.suse.cz>
References: <1398688005-26207-1-git-send-email-mhocko@suse.cz>
 <20140528121023.GA10735@dhcp22.suse.cz>
 <20140528134905.GF2878@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140528134905.GF2878@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Roman Gushchin <klamm@yandex-team.ru>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>

On Wed 28-05-14 09:49:05, Johannes Weiner wrote:
> On Wed, May 28, 2014 at 02:10:23PM +0200, Michal Hocko wrote:
> > Hi Andrew, Johannes,
> > 
> > On Mon 28-04-14 14:26:41, Michal Hocko wrote:
> > > This patchset introduces such low limit that is functionally similar
> > > to a minimum guarantee. Memcgs which are under their lowlimit are not
> > > considered eligible for the reclaim (both global and hardlimit) unless
> > > all groups under the reclaimed hierarchy are below the low limit when
> > > all of them are considered eligible.
> > > 
> > > The previous version of the patchset posted as a RFC
> > > (http://marc.info/?l=linux-mm&m=138677140628677&w=2) suggested a
> > > hard guarantee without any fallback. More discussions led me to
> > > reconsidering the default behavior and come up a more relaxed one. The
> > > hard requirement can be added later based on a use case which really
> > > requires. It would be controlled by memory.reclaim_flags knob which
> > > would specify whether to OOM or fallback (default) when all groups are
> > > bellow low limit.
> > 
> > It seems that we are not in a full agreement about the default behavior
> > yet. Johannes seems to be more for hard guarantee while I would like to
> > see the weaker approach first and move to the stronger model later.
> > Johannes, is this absolutely no-go for you? Do you think it is seriously
> > handicapping the semantic of the new knob?
> 
> Well we certainly can't start OOMing where we previously didn't,
> that's called a regression and automatically limits our options.
> 
> Any unexpected OOMs will be much more acceptable from a new feature
> than from configuration that previously "worked" and then stopped.

Yes and we are not talking about regressions, are we?

> > My main motivation for the weaker model is that it is hard to see all
> > the corner case right now and once we hit them I would like to see a
> > graceful fallback rather than fatal action like OOM killer. Besides that
> > the usaceses I am mostly interested in are OK with fallback when the
> > alternative would be OOM killer. I also feel that introducing a knob
> > with a weaker semantic which can be made stronger later is a sensible
> > way to go.
> 
> We can't make it stronger, but we can make it weaker. 

Why cannot we make it stronger by a knob/configuration option?

> Stronger is the simpler definition, it's simpler code,

The code is not really that much simpler. The one you have posted will
not work I am afraid. I haven't tested it yet but I remember I had to do
some tweaks to the reclaim path to not end up in an endless loop in the
direct reclaim (http://marc.info/?l=linux-mm&m=138677140828678&w=2 and
http://marc.info/?l=linux-mm&m=138677141328682&w=2).

> your usecases are fine with it,

my usecases do not overcommit low_limit on the available memory, so far
so good, but once we hit a corner cases when limits are set properly but
we end up not being able to reclaim anybody in a zone then OOM sounds
too brutal.

> Greg and I prefer it too.  I don't even know what we are arguing about
> here.
> 
> Patch applies on top of mmots.
> 
> ---
> From ced6ac70bb274cdaa4c5d78b53420d84fb803dd7 Mon Sep 17 00:00:00 2001
> From: Johannes Weiner <hannes@cmpxchg.org>
> Date: Wed, 28 May 2014 09:37:05 -0400
> Subject: [patch] mm: vmscan: treat memcg low limit as hard guarantee
> 
> Don't hide low limit configuration problems behind weak semantics and
> quietly breach the set-up guarantees.
> 
> Make it simple: memcg guarantees are equivalent to mlocked memory,
> anonymous memory without swap, kernel memory, pinned memory etc. -
> unreclaimable.  If no memory can be reclaimed without otherwise
> breaching guarantees, it's a real problem, so let the machine OOM and
> dump the memory state in that situation.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  include/linux/memcontrol.h |  5 -----
>  mm/memcontrol.c            | 15 ---------------
>  mm/vmscan.c                | 41 +++++------------------------------------
>  3 files changed, 5 insertions(+), 56 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index a5cf853129ec..c3a53cbb88eb 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -94,7 +94,6 @@ bool task_in_mem_cgroup(struct task_struct *task,
>  
>  extern bool mem_cgroup_within_guarantee(struct mem_cgroup *memcg,
>  		struct mem_cgroup *root);
> -extern bool mem_cgroup_all_within_guarantee(struct mem_cgroup *root);
>  
>  extern struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page);
>  extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
> @@ -297,10 +296,6 @@ static inline bool mem_cgroup_within_guarantee(struct mem_cgroup *memcg,
>  {
>  	return false;
>  }
> -static inline bool mem_cgroup_all_within_guarantee(struct mem_cgroup *root)
> -{
> -	return false;
> -}
>  
>  static inline struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
>  {
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 4df733e13727..85fdef53fcf1 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2788,7 +2788,6 @@ static struct mem_cgroup *mem_cgroup_lookup(unsigned short id)
>   *
>   * The given group is within its reclaim gurantee if it is below its low limit
>   * or the same applies for any parent up the hierarchy until root (including).
> - * Such a group might be excluded from the reclaim.
>   */
>  bool mem_cgroup_within_guarantee(struct mem_cgroup *memcg,
>  		struct mem_cgroup *root)
> @@ -2801,25 +2800,11 @@ bool mem_cgroup_within_guarantee(struct mem_cgroup *memcg,
>  			return true;
>  		if (memcg == root)
>  			break;
> -
>  	} while ((memcg = parent_mem_cgroup(memcg)));
>  
>  	return false;
>  }
>  
> -bool mem_cgroup_all_within_guarantee(struct mem_cgroup *root)
> -{
> -	struct mem_cgroup *iter;
> -
> -	for_each_mem_cgroup_tree(iter, root)
> -		if (!mem_cgroup_within_guarantee(iter, root)) {
> -			mem_cgroup_iter_break(root, iter);
> -			return false;
> -		}
> -
> -	return true;
> -}
> -
>  struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
>  {
>  	struct mem_cgroup *memcg = NULL;
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index a8ffe4e616fe..c72493e8fb53 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2244,20 +2244,14 @@ static inline bool should_continue_reclaim(struct zone *zone,
>  }
>  
>  /**
> - * __shrink_zone - shrinks a given zone
> + * shrink_zone - shrinks a given zone
>   *
>   * @zone: zone to shrink
>   * @sc: scan control with additional reclaim parameters
> - * @honor_memcg_guarantee: do not reclaim memcgs which are within their memory
> - * guarantee
> - *
> - * Returns the number of reclaimed memcgs.
>   */
> -static unsigned __shrink_zone(struct zone *zone, struct scan_control *sc,
> -		bool honor_memcg_guarantee)
> +static void shrink_zone(struct zone *zone, struct scan_control *sc)
>  {
>  	unsigned long nr_reclaimed, nr_scanned;
> -	unsigned nr_scanned_groups = 0;
>  
>  	do {
>  		struct mem_cgroup *root = sc->target_mem_cgroup;
> @@ -2274,20 +2268,16 @@ static unsigned __shrink_zone(struct zone *zone, struct scan_control *sc,
>  		do {
>  			struct lruvec *lruvec;
>  
> -			/* Memcg might be protected from the reclaim */
> -			if (honor_memcg_guarantee &&
> -					mem_cgroup_within_guarantee(memcg, root)) {
> +			/* Don't reclaim guaranteed memory */
> +			if (mem_cgroup_within_guarantee(memcg, root)) {
>  				/*
> -				 * It would be more optimal to skip the memcg
> -				 * subtree now but we do not have a memcg iter
> -				 * helper for that. Anyone?
> +				 * XXX: skip the entire subtree here
>  				 */
>  				memcg = mem_cgroup_iter(root, memcg, &reclaim);
>  				continue;
>  			}
>  
>  			lruvec = mem_cgroup_zone_lruvec(zone, memcg);
> -			nr_scanned_groups++;
>  
>  			sc->swappiness = mem_cgroup_swappiness(memcg);
>  			shrink_lruvec(lruvec, sc);
> @@ -2316,27 +2306,6 @@ static unsigned __shrink_zone(struct zone *zone, struct scan_control *sc,
>  
>  	} while (should_continue_reclaim(zone, sc->nr_reclaimed - nr_reclaimed,
>  					 sc->nr_scanned - nr_scanned, sc));
> -
> -	return nr_scanned_groups;
> -}
> -
> -static void shrink_zone(struct zone *zone, struct scan_control *sc)
> -{
> -	bool honor_guarantee = true;
> -
> -	while (!__shrink_zone(zone, sc, honor_guarantee)) {
> -		/*
> -		 * The previous round of reclaim didn't find anything to scan
> -		 * because
> -		 * a) the whole reclaimed hierarchy is within guarantee so
> -		 *    we fallback to ignore the guarantee because other option
> -		 *    would be the OOM
> -		 * b) multiple reclaimers are racing and so the first round
> -		 *    should be retried
> -		 */
> -		if (mem_cgroup_all_within_guarantee(sc->target_mem_cgroup))
> -			honor_guarantee = false;
> -	}
>  }
>  
>  /* Returns true if compaction should go ahead for a high-order request */
> -- 
> 1.9.3
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
