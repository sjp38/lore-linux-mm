Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 66FF86B0062
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 07:29:26 -0400 (EDT)
Date: Tue, 19 Jun 2012 13:29:01 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH V5 1/5] mm: memcg softlimit reclaim rework
Message-ID: <20120619112901.GC27816@cmpxchg.org>
References: <1340038051-29502-1-git-send-email-yinghan@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1340038051-29502-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Mon, Jun 18, 2012 at 09:47:27AM -0700, Ying Han wrote:
> This patch reverts all the existing softlimit reclaim implementations and
> instead integrates the softlimit reclaim into existing global reclaim logic.
> 
> The new softlimit reclaim includes the following changes:
> 
> 1. add function should_reclaim_mem_cgroup()
> 
> Add the filter function should_reclaim_mem_cgroup() under the common function
> shrink_zone(). The later one is being called both from per-memcg reclaim as
> well as global reclaim.
> 
> Today the softlimit takes effect only under global memory pressure. The memcgs
> get free run above their softlimit until there is a global memory contention.
> This patch doesn't change the semantics.

But it's quite a performance regression.  Maybe it would be better
after all to combine this change with 'make 0 the default'?

Yes, I was the one asking for the changes to be separated, if
possible, but I didn't mean regressing in between.  No forward
dependencies in patch series, please.

> Under the global reclaim, we try to skip reclaiming from a memcg under its
> softlimit. To prevent reclaim from trying too hard on hitting memcgs
> (above softlimit) w/ only hard-to-reclaim pages, the reclaim priority is used
> to skip the softlimit check. This is a trade-off of system performance and
> resource isolation.
> 
> 2. "hierarchical" softlimit reclaim
>
> This is consistant to how softlimit was previously implemented, where the
> pressure is put for the whole hiearchy as long as the "root" of the hierarchy
> over its softlimit.
> 
> This part is not in my previous posts, and is quite different from my
> understanding of softlimit reclaim. After quite a lot of discussions with
> Johannes and Michal, i decided to go with it for now. And this is designed
> to work with both trusted setups and untrusted setups.

This may be really confusing to someone uninvolved reading the
changelog as it doesn't have anything to do with what the patch
actually does.

It may be better to include past discussion outcomes in the
introductary email of a series.

> @@ -870,8 +672,6 @@ static void memcg_check_events(struct mem_cgroup *memcg, struct page *page)
>  		preempt_enable();
>  
>  		mem_cgroup_threshold(memcg);
> -		if (unlikely(do_softlimit))
> -			mem_cgroup_update_tree(memcg, page);
>  #if MAX_NUMNODES > 1
>  		if (unlikely(do_numainfo))
>  			atomic_inc(&memcg->numainfo_events);
> @@ -922,6 +722,31 @@ struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm)
>  	return memcg;
>  }
>  
> +bool should_reclaim_mem_cgroup(struct mem_cgroup *memcg)

I'm not too fond of the magical name.  The API provides an information
about soft limits, the decision should rest with vmscan.c.

mem_cgroup_over_soft_limit() e.g.?

> +{
> +	if (mem_cgroup_disabled())
> +		return true;
> +
> +	/*
> +	 * We treat the root cgroup special here to always reclaim pages.
> +	 * Now root cgroup has its own lru, and the only chance to reclaim
> +	 * pages from it is through global reclaim. note, root cgroup does
> +	 * not trigger targeted reclaim.
> +	 */
> +	if (mem_cgroup_is_root(memcg))
> +		return true;

With the soft limit at 0, the comment is no longer accurate because
this check turns into a simple optimization.  We could check the
res_counter soft limit, which would always result in the root group
being above the limit, but we take the short cut.

> +	for (; memcg; memcg = parent_mem_cgroup(memcg)) {
> +		/* This is global reclaim, stop at root cgroup */
> +		if (mem_cgroup_is_root(memcg))
> +			break;

I don't see why you add this check and the comment does not help.

> +		if (res_counter_soft_limit_excess(&memcg->res))
> +			return true;
> +	}
> +
> +	return false;
> +}
> +
>  /**
>   * mem_cgroup_iter - iterate over memory cgroup hierarchy
>   * @root: hierarchy root

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
