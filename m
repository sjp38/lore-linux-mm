Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 36D2B6B0169
	for <linux-mm@kvack.org>; Tue, 16 Aug 2011 21:01:34 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id EDB7D3EE0BC
	for <linux-mm@kvack.org>; Wed, 17 Aug 2011 10:01:30 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D054045DE59
	for <linux-mm@kvack.org>; Wed, 17 Aug 2011 10:01:30 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A471B45DE5A
	for <linux-mm@kvack.org>; Wed, 17 Aug 2011 10:01:30 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 967761DB804F
	for <linux-mm@kvack.org>; Wed, 17 Aug 2011 10:01:30 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4CE241DB8054
	for <linux-mm@kvack.org>; Wed, 17 Aug 2011 10:01:30 +0900 (JST)
Date: Wed, 17 Aug 2011 09:54:05 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v5 2/6]  memcg: stop vmscan when enough done.
Message-Id: <20110817095405.ee3dcd74.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110811145055.GN8023@tiehlicka.suse.cz>
References: <20110809190450.16d7f845.kamezawa.hiroyu@jp.fujitsu.com>
	<20110809190933.d965888b.kamezawa.hiroyu@jp.fujitsu.com>
	<20110810141425.GC15007@tiehlicka.suse.cz>
	<20110811085252.b29081f1.kamezawa.hiroyu@jp.fujitsu.com>
	<20110811145055.GN8023@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>

On Thu, 11 Aug 2011 16:50:55 +0200
Michal Hocko <mhocko@suse.cz> wrote:

> What about this (just compile tested)?
> --- 
> From: Michal Hocko <mhocko@suse.cz>
> Subject: memcg: add nr_pages argument for hierarchical reclaim
> 
> Now that we are doing memcg direct reclaim limited to nr_to_reclaim
> pages (introduced by "memcg: stop vmscan when enough done.") we have to
> be more careful. Currently we are using SWAP_CLUSTER_MAX which is OK for
> most callers but it might cause failures for limit resize or force_empty
> code paths on big NUMA machines.
> 
> Previously we might have reclaimed up to nr_nodes * SWAP_CLUSTER_MAX
> while now we have it at SWAP_CLUSTER_MAX. Both resize and force_empty rely
> on reclaiming a certain amount of pages and retrying if their condition is
> still not met.
> 
> Let's add nr_pages argument to mem_cgroup_hierarchical_reclaim which will
> push it further to try_to_free_mem_cgroup_pages. We still fall back to
> SWAP_CLUSTER_MAX for small requests so the standard code (hot) paths are not
> affected by this.
> 
> Open questions:
> - Should we care about soft limit as well? Currently I am using excess
>   number of pages for the parameter so it can replace direct query for
>   the value in mem_cgroup_hierarchical_reclaim but should we push it to
>   mem_cgroup_shrink_node_zone?
>   I do not think so because we should try to reclaim from more groups in the
>   hierarchy and also it doesn't get to shrink_zones which has been modified
>   by the previous patch.



> - mem_cgroup_force_empty asks for reclaiming all pages. I guess it should be
>   OK but will have to think about it some more.

force_empty/rmdir() is allowed to be stopped by Ctrl-C. I think passing res->usage
is overkilling.


> - Aren't we going to reclaim too much when we hit the limit due to THP?

When we use THP without memcg, failure in memory allocation
just fails and khugepaged will make small pages into hugepage later.

Memcg doesn't need to take special care, I think.
If we change it, it will be performance matter and should be measured.

> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> 
> Index: linus_tree/include/linux/memcontrol.h
> ===================================================================
> --- linus_tree.orig/include/linux/memcontrol.h	2011-08-11 15:44:43.000000000 +0200
> +++ linus_tree/include/linux/memcontrol.h	2011-08-11 15:46:27.000000000 +0200
> @@ -130,7 +130,8 @@ extern void mem_cgroup_print_oom_info(st
>  
>  extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem,
>  						  gfp_t gfp_mask, bool noswap,
> -						  struct memcg_scanrecord *rec);
> +						  struct memcg_scanrecord *rec,
> +						  unsigned long nr_pages);
>  extern unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
>  						gfp_t gfp_mask, bool noswap,
>  						struct zone *zone,
> Index: linus_tree/mm/memcontrol.c
> ===================================================================
> --- linus_tree.orig/mm/memcontrol.c	2011-08-11 15:36:15.000000000 +0200
> +++ linus_tree/mm/memcontrol.c	2011-08-11 16:00:46.000000000 +0200
> @@ -1729,12 +1729,15 @@ static void mem_cgroup_record_scanstat(s
>   * (other groups can be removed while we're walking....)
>   *
>   * If shrink==true, for avoiding to free too much, this returns immedieately.
> + * Given nr_pages tells how many pages are we over the soft limit or how many
> + * pages do we want to reclaim in the direct reclaim mode.
>   */
>  static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
>  						struct zone *zone,
>  						gfp_t gfp_mask,
>  						unsigned long reclaim_options,
> -						unsigned long *total_scanned)
> +						unsigned long *total_scanned,
> +						unsigned long nr_pages)
>  {
>  	struct mem_cgroup *victim;
>  	int ret, total = 0;
> @@ -1743,11 +1746,8 @@ static int mem_cgroup_hierarchical_recla
>  	bool shrink = reclaim_options & MEM_CGROUP_RECLAIM_SHRINK;
>  	bool check_soft = reclaim_options & MEM_CGROUP_RECLAIM_SOFT;
>  	struct memcg_scanrecord rec;
> -	unsigned long excess;
>  	unsigned long scanned;
>  
> -	excess = res_counter_soft_limit_excess(&root_mem->res) >> PAGE_SHIFT;
> -
>  	/* If memsw_is_minimum==1, swap-out is of-no-use. */
>  	if (!check_soft && !shrink && root_mem->memsw_is_minimum)
>  		noswap = true;
> @@ -1785,11 +1785,11 @@ static int mem_cgroup_hierarchical_recla
>  				}
>  				/*
>  				 * We want to do more targeted reclaim.
> -				 * excess >> 2 is not to excessive so as to
> +				 * nr_pages >> 2 is not to excessive so as to
>  				 * reclaim too much, nor too less that we keep
>  				 * coming back to reclaim from this cgroup
>  				 */
> -				if (total >= (excess >> 2) ||
> +				if (total >= (nr_pages >> 2) ||
>  					(loop > MEM_CGROUP_MAX_RECLAIM_LOOPS)) {
>  					css_put(&victim->css);
>  					break;
> @@ -1816,7 +1816,7 @@ static int mem_cgroup_hierarchical_recla
>  			*total_scanned += scanned;
>  		} else
>  			ret = try_to_free_mem_cgroup_pages(victim, gfp_mask,
> -						noswap, &rec);
> +						noswap, &rec, nr_pages);
>  		mem_cgroup_record_scanstat(&rec);
>  		css_put(&victim->css);
>  		/*
> @@ -2332,7 +2332,8 @@ static int mem_cgroup_do_charge(struct m
>  		return CHARGE_WOULDBLOCK;
>  
>  	ret = mem_cgroup_hierarchical_reclaim(mem_over_limit, NULL,
> -					      gfp_mask, flags, NULL);
> +					      gfp_mask, flags, NULL,
> +					      nr_pages);

Hmm, in usual, nr_pages = batch = CHARGE_BATCH = 32 ? At allocating Hugepage,
this nr_pages will be 512 ? I think it's too big...

Thanks,
-Kame



>  	if (mem_cgroup_margin(mem_over_limit) >= nr_pages)
>  		return CHARGE_RETRY;
>  	/*
> @@ -3567,7 +3568,8 @@ static int mem_cgroup_resize_limit(struc
>  
>  		mem_cgroup_hierarchical_reclaim(memcg, NULL, GFP_KERNEL,
>  						MEM_CGROUP_RECLAIM_SHRINK,
> -						NULL);
> +						NULL,
> +						(val-memlimit) >> PAGE_SHIFT);
>  		curusage = res_counter_read_u64(&memcg->res, RES_USAGE);
>  		/* Usage is reduced ? */
>    		if (curusage >= oldusage)
> @@ -3628,7 +3630,8 @@ static int mem_cgroup_resize_memsw_limit
>  		mem_cgroup_hierarchical_reclaim(memcg, NULL, GFP_KERNEL,
>  						MEM_CGROUP_RECLAIM_NOSWAP |
>  						MEM_CGROUP_RECLAIM_SHRINK,
> -						NULL);
> +						NULL,
> +						(val-memswlimit) >> PAGE_SHIFT);
>  		curusage = res_counter_read_u64(&memcg->memsw, RES_USAGE);
>  		/* Usage is reduced ? */
>  		if (curusage >= oldusage)
> @@ -3671,10 +3674,12 @@ unsigned long mem_cgroup_soft_limit_recl
>  			break;
>  
>  		nr_scanned = 0;
> +		excess = res_counter_soft_limit_excess(&mz->mem->res);
>  		reclaimed = mem_cgroup_hierarchical_reclaim(mz->mem, zone,
>  						gfp_mask,
>  						MEM_CGROUP_RECLAIM_SOFT,
> -						&nr_scanned);
> +						&nr_scanned,
> +						excess >> PAGE_SHIFT);
>  		nr_reclaimed += reclaimed;
>  		*total_scanned += nr_scanned;
>  		spin_lock(&mctz->lock);
> @@ -3871,7 +3876,8 @@ try_to_free:
>  		rec.mem = mem;
>  		rec.root = mem;
>  		progress = try_to_free_mem_cgroup_pages(mem, GFP_KERNEL,
> -						false, &rec);
> +						false, &rec,
> +						mem->res.usage >> PAGE_SHIFT);
>  		if (!progress) {
>  			nr_retries--;
>  			/* maybe some writeback is necessary */
> Index: linus_tree/mm/vmscan.c
> ===================================================================
> --- linus_tree.orig/mm/vmscan.c	2011-08-11 15:44:43.000000000 +0200
> +++ linus_tree/mm/vmscan.c	2011-08-11 16:41:22.000000000 +0200
> @@ -2340,7 +2340,8 @@ unsigned long mem_cgroup_shrink_node_zon
>  unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
>  					   gfp_t gfp_mask,
>  					   bool noswap,
> -					   struct memcg_scanrecord *rec)
> +					   struct memcg_scanrecord *rec,
> +					   unsigned long nr_pages)
>  {
>  	struct zonelist *zonelist;
>  	unsigned long nr_reclaimed;
> @@ -2350,7 +2351,7 @@ unsigned long try_to_free_mem_cgroup_pag
>  		.may_writepage = !laptop_mode,
>  		.may_unmap = 1,
>  		.may_swap = !noswap,
> -		.nr_to_reclaim = SWAP_CLUSTER_MAX,
> +		.nr_to_reclaim = max_t(unsigned long, nr_pages, SWAP_CLUSTER_MAX),
>  		.order = 0,
>  		.mem_cgroup = mem_cont,
>  		.memcg_record = rec,
> -- 
> Michal Hocko
> SUSE Labs
> SUSE LINUX s.r.o.
> Lihovarska 1060/12
> 190 00 Praha 9    
> Czech Republic
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
