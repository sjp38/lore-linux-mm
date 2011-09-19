Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id A22669000BD
	for <linux-mm@kvack.org>; Mon, 19 Sep 2011 08:53:42 -0400 (EDT)
Date: Mon, 19 Sep 2011 14:53:33 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 01/11] mm: memcg: consolidate hierarchy iteration
 primitives
Message-ID: <20110919125333.GC21847@tiehlicka.suse.cz>
References: <1315825048-3437-1-git-send-email-jweiner@redhat.com>
 <1315825048-3437-2-git-send-email-jweiner@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1315825048-3437-2-git-send-email-jweiner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,

On Mon 12-09-11 12:57:18, Johannes Weiner wrote:
> Memory control groups are currently bolted onto the side of
> traditional memory management in places where better integration would
> be preferrable.  To reclaim memory, for example, memory control groups
> maintain their own LRU list and reclaim strategy aside from the global
> per-zone LRU list reclaim.  But an extra list head for each existing
> page frame is expensive and maintaining it requires additional code.
> 
> This patchset disables the global per-zone LRU lists on memory cgroup
> configurations and converts all its users to operate on the per-memory
> cgroup lists instead.  As LRU pages are then exclusively on one list,
> this saves two list pointers for each page frame in the system:
> 
> page_cgroup array size with 4G physical memory
> 
>   vanilla: [    0.000000] allocated 31457280 bytes of page_cgroup
>   patched: [    0.000000] allocated 15728640 bytes of page_cgroup
> 
> At the same time, system performance for various workloads is
> unaffected:
> 
> 100G sparse file cat, 4G physical memory, 10 runs, to test for code
> bloat in the traditional LRU handling and kswapd & direct reclaim
> paths, without/with the memory controller configured in
> 
>   vanilla: 71.603(0.207) seconds
>   patched: 71.640(0.156) seconds
> 
>   vanilla: 79.558(0.288) seconds
>   patched: 77.233(0.147) seconds
> 
> 100G sparse file cat in 1G memory cgroup, 10 runs, to test for code
> bloat in the traditional memory cgroup LRU handling and reclaim path
> 
>   vanilla: 96.844(0.281) seconds
>   patched: 94.454(0.311) seconds
> 
> 4 unlimited memcgs running kbuild -j32 each, 4G physical memory, 500M
> swap on SSD, 10 runs, to test for regressions in kswapd & direct
> reclaim using per-memcg LRU lists with multiple memcgs and multiple
> allocators within each memcg
> 
>   vanilla: 717.722(1.440) seconds [ 69720.100(11600.835) majfaults ]
>   patched: 714.106(2.313) seconds [ 71109.300(14886.186) majfaults ]
> 
> 16 unlimited memcgs running kbuild, 1900M hierarchical limit, 500M
> swap on SSD, 10 runs, to test for regressions in hierarchical memcg
> setups
> 
>   vanilla: 2742.058(1.992) seconds [ 26479.600(1736.737) majfaults ]
>   patched: 2743.267(1.214) seconds [ 27240.700(1076.063) majfaults ]

I guess you want to have this in the first patch to have it for
reference once it gets to the tree, right? I have no objections but it
seems unrelated to the patch and so it might be confusing a bit. I
haven't seen other patches in the series so there is probably no better
place to put this.

> 
> This patch:
> 
> There are currently two different implementations of iterating over a
> memory cgroup hierarchy tree.
> 
> Consolidate them into one worker function and base the convenience
> looping-macros on top of it.
> 
> Signed-off-by: Johannes Weiner <jweiner@redhat.com>

Looks mostly good. There is just one issue I spotted and I guess we
want some comments. After the issue is fixed:
Reviewed-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/memcontrol.c |  196 ++++++++++++++++++++----------------------------------
>  1 files changed, 73 insertions(+), 123 deletions(-)

Nice diet.

> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index b76011a..912c7c7 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -781,83 +781,75 @@ struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm)
>  	return memcg;
>  }
>  
> -/* The caller has to guarantee "mem" exists before calling this */

Shouldn't we have a similar comment that we have to keep a reference to
root if non-NULL. A mention about remember parameter and what is it used
for (hierarchical reclaim) would be helpful as well.

/*
 * Find a next cgroup under the hierarchy tree with the given root (or
 * root_mem_cgroup if NULL) starting from the given prev (iterator)
 * position and releasing a reference to it. Start from the root if
 * iterator is NULL.
 * Ignore iterator position if remember is true and follow with the
 * last_scanned_child instead and remember the new value (used during
 * hierarchical reclaim).
 * Caller is supposed to grab a reference to the root (if non NULL) before
 * it calls us for the first time.
 *
 * Returns a cgroup with increased reference count (except for the root)
 * or NULL if there are no more groups to visit.
 *
 * Use for_each_mem_cgroup_tree and for_each_mem_cgroup instead and
 * mem_cgroup_iter_break for the final clean up if you are using this
 * function directly.
 */
> -static struct mem_cgroup *mem_cgroup_start_loop(struct mem_cgroup *memcg)
> +static struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
> +					  struct mem_cgroup *prev,
> +					  bool remember)
[...]
> @@ -1656,7 +1611,7 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_memcg,
>  						unsigned long reclaim_options,
>  						unsigned long *total_scanned)
>  {
> -	struct mem_cgroup *victim;
> +	struct mem_cgroup *victim = NULL;
>  	int ret, total = 0;
>  	int loop = 0;
>  	bool noswap = reclaim_options & MEM_CGROUP_RECLAIM_NOSWAP;
> @@ -1672,8 +1627,8 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_memcg,
>  		noswap = true;
>  
>  	while (1) {
> -		victim = mem_cgroup_select_victim(root_memcg);
> -		if (victim == root_memcg) {
> +		victim = mem_cgroup_iter(root_memcg, victim, true);
> +		if (!victim) {
>  			loop++;
>  			/*
>  			 * We are not draining per cpu cached charges during
> @@ -1689,10 +1644,8 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_memcg,
>  				 * anything, it might because there are
>  				 * no reclaimable pages under this hierarchy
>  				 */
> -				if (!check_soft || !total) {
> -					css_put(&victim->css);
> +				if (!check_soft || !total)
>  					break;
> -				}
>  				/*
>  				 * We want to do more targeted reclaim.
>  				 * excess >> 2 is not to excessive so as to
> @@ -1700,15 +1653,13 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_memcg,
>  				 * coming back to reclaim from this cgroup
>  				 */
>  				if (total >= (excess >> 2) ||
> -					(loop > MEM_CGROUP_MAX_RECLAIM_LOOPS)) {
> -					css_put(&victim->css);
> +					(loop > MEM_CGROUP_MAX_RECLAIM_LOOPS))
>  					break;
> -				}
>  			}
> +			continue;
>  		}
>  		if (!mem_cgroup_reclaimable(victim, noswap)) {
>  			/* this cgroup's local usage == 0 */
> -			css_put(&victim->css);
>  			continue;
>  		}
>  		/* we use swappiness of local cgroup */
> @@ -1719,21 +1670,21 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_memcg,
>  		} else
>  			ret = try_to_free_mem_cgroup_pages(victim, gfp_mask,
>  						noswap);
> -		css_put(&victim->css);
>  		/*
>  		 * At shrinking usage, we can't check we should stop here or
>  		 * reclaim more. It's depends on callers. last_scanned_child
>  		 * will work enough for keeping fairness under tree.
>  		 */
>  		if (shrink)
> -			return ret;
> +			break;

Hmm, we are returning total but it doesn't get set to ret for shrinking
case so we are alway returning 0. You want to move the line bellow up.

>  		total += ret;
>  		if (check_soft) {
>  			if (!res_counter_soft_limit_excess(&root_memcg->res))
> -				return total;
> +				break;
>  		} else if (mem_cgroup_margin(root_memcg))
> -			return total;
> +			break;
>  	}
> +	mem_cgroup_iter_break(root_memcg, victim);
>  	return total;
>  }

[...]

Thanks
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
