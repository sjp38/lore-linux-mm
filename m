Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 25FBC6B004D
	for <linux-mm@kvack.org>; Mon, 23 Jan 2012 08:02:24 -0500 (EST)
Date: Mon, 23 Jan 2012 14:02:21 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: memcg: fix over reclaiming mem cgroup
Message-ID: <20120123130221.GA15113@tiehlicka.suse.cz>
References: <CAJd=RBAbFd=MFZZyCKN-Si-Zt=C6dKVUaG-C7s5VKoTWfY00nA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJd=RBAbFd=MFZZyCKN-Si-Zt=C6dKVUaG-C7s5VKoTWfY00nA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Sat 21-01-12 22:49:23, Hillf Danton wrote:
> In soft limit reclaim, overreclaim occurs when pages are reclaimed from mem
> group that is under its soft limit, or when more pages are reclaimd than the
> exceeding amount, then performance of reclaimee goes down accordingly.

First of all soft reclaim is more a help for the global memory pressure
balancing rather than any guarantee about how much we reclaim for the
group.
We need to do more changes in order to make it a guarantee.
For example you implementation will cause severe problems when all
cgroups are soft unlimited (default conf.) or when nobody is above the
limit but the total consumption triggers the global reclaim. Therefore
nobody is in excess and you would skip all groups and only bang on the
root memcg.

Ying Han has a patch which basically skips all cgroups which are under
its limit until we reach a certain reclaim priority but even for this we
need some additional changes - e.g. reverse the current default setting
of the soft limit.

Anyway, I like the nr_to_reclaim reduction idea because we have to do
this in some way because the global reclaim starts with ULONG
nr_to_scan.

> A helper function is added to compute the number of pages that exceed the soft
> limit of given mem cgroup, then the excess pages are used when every reclaimee
> is reclaimed to avoid overreclaim.
> 
> Signed-off-by: Hillf Danton <dhillf@gmail.com>
> ---
> 
> --- a/mm/memcontrol.c	Tue Jan 17 20:41:36 2012
> +++ b/mm/memcontrol.c	Sat Jan 21 21:18:46 2012
> @@ -1662,6 +1662,21 @@ static int mem_cgroup_soft_reclaim(struc
>  	return total;
>  }
> 
> +unsigned long mem_cgroup_excess_pages(struct mem_cgroup *memcg)
> +{
> +	unsigned long pages;
> +
> +	if (mem_cgroup_disabled())
> +		return 0;
> +	if (!memcg)
> +		return 0;
> +	if (mem_cgroup_is_root(memcg))
> +		return 0;
> +
> +	pages = res_counter_soft_limit_excess(&memcg->res) >> PAGE_SHIFT;
> +	return pages;
> +}
> +
>  /*
>   * Check OOM-Killer is already running under our hierarchy.
>   * If someone is running, return false.
> --- a/mm/vmscan.c	Sat Jan 14 14:02:20 2012
> +++ b/mm/vmscan.c	Sat Jan 21 21:30:06 2012
> @@ -2150,8 +2150,34 @@ static void shrink_zone(int priority, st
>  			.mem_cgroup = memcg,
>  			.zone = zone,
>  		};
> +		unsigned long old;
> +		bool clobbered = false;
> +
> +		if (memcg != NULL) {
> +			unsigned long excess;
> +
> +			excess = mem_cgroup_excess_pages(memcg);
> +			/*
> +			 * No bother reclaiming pages from mem cgroup that
> +			 * is under soft limit
> +			 */
> +			if (!excess)
> +				goto next;
> +			/*
> +			 * And reclaim no more pages than excess
> +			 */
> +			if (excess < sc->nr_to_reclaim) {
> +				old = sc->nr_to_reclaim;
> +				sc->nr_to_reclaim = excess;
> +				clobbered = true;
> +			}
> +		}
> 
>  		shrink_mem_cgroup_zone(priority, &mz, sc);
> +
> +		if (clobbered)
> +			sc->nr_to_reclaim = old;
> +next:
>  		/*
>  		 * Limit reclaim has historically picked one memcg and
>  		 * scanned it with decreasing priority levels until
> --- a/include/linux/memcontrol.h	Thu Jan 19 22:03:14 2012
> +++ b/include/linux/memcontrol.h	Sat Jan 21 21:35:50 2012
> @@ -161,6 +161,7 @@ unsigned long mem_cgroup_soft_limit_recl
>  						gfp_t gfp_mask,
>  						unsigned long *total_scanned);
>  u64 mem_cgroup_get_limit(struct mem_cgroup *memcg);
> +unsigned long mem_cgroup_excess_pages(struct mem_cgroup *memcg);
> 
>  void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx);
>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
> @@ -376,6 +377,11 @@ unsigned long mem_cgroup_soft_limit_recl
> 
>  static inline
>  u64 mem_cgroup_get_limit(struct mem_cgroup *memcg)
> +{
> +	return 0;
> +}
> +
> +static inline unsigned long mem_cgroup_excess_pages(struct mem_cgroup *memcg)
>  {
>  	return 0;
>  }
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
