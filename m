Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 3C7DA6B0088
	for <linux-mm@kvack.org>; Tue,  6 Dec 2011 21:14:44 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id E17BA3EE0BD
	for <linux-mm@kvack.org>; Wed,  7 Dec 2011 11:14:42 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id CA7AF45DE4E
	for <linux-mm@kvack.org>; Wed,  7 Dec 2011 11:14:42 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id AFD4E45DE4D
	for <linux-mm@kvack.org>; Wed,  7 Dec 2011 11:14:42 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 60A911DB8037
	for <linux-mm@kvack.org>; Wed,  7 Dec 2011 11:14:42 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id ECE06E08002
	for <linux-mm@kvack.org>; Wed,  7 Dec 2011 11:14:41 +0900 (JST)
Date: Wed, 7 Dec 2011 11:13:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/3] memcg: rework softlimit reclaim
Message-Id: <20111207111334.b21fef3c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1323215999-29164-2-git-send-email-yinghan@google.com>
References: <1323215999-29164-1-git-send-email-yinghan@google.com>
	<1323215999-29164-2-git-send-email-yinghan@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, Pavel Emelyanov <xemul@openvz.org>, linux-mm@kvack.org

On Tue,  6 Dec 2011 15:59:57 -0800
Ying Han <yinghan@google.com> wrote:

> Under the shrink_zone, we examine whether or not to reclaim from a memcg
> based on its softlimit. We skip scanning the memcg for the first 3 priority.
> This is to balance between isolation and efficiency. we don't want to halt
> the system by skipping memcgs with low-hanging fruits forever.
> 
> Another change is to set soft_limit_in_bytes to 0 by default. This is needed
> for both functional and performance:
> 
> 1. If soft_limit are all set to MAX, it wastes first three periority iterations
> without scanning anything.
> 
> 2. By default every memcg is eligibal for softlimit reclaim, and we can also
> set the value to MAX for special memcg which is immune to soft limit reclaim.
> 

Could you update softlimit doc ?



> Signed-off-by: Ying Han <yinghan@google.com>
> ---
>  include/linux/memcontrol.h |    7 ++++
>  kernel/res_counter.c       |    1 -
>  mm/memcontrol.c            |    8 +++++
>  mm/vmscan.c                |   67 ++++++++++++++++++++++++++-----------------
>  4 files changed, 55 insertions(+), 28 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 81aabfb..53d483b 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -107,6 +107,8 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *,
>  				   struct mem_cgroup_reclaim_cookie *);
>  void mem_cgroup_iter_break(struct mem_cgroup *, struct mem_cgroup *);
>  
> +bool mem_cgroup_soft_limit_exceeded(struct mem_cgroup *);
> +
>  /*
>   * For memory reclaim.
>   */
> @@ -293,6 +295,11 @@ static inline void mem_cgroup_iter_break(struct mem_cgroup *root,
>  {
>  }
>  
> +static inline bool mem_cgroup_soft_limit_exceeded(struct mem_cgroup *mem)
> +{
> +	return true;
> +}
> +
>  static inline int mem_cgroup_get_reclaim_priority(struct mem_cgroup *memcg)
>  {
>  	return 0;
> diff --git a/kernel/res_counter.c b/kernel/res_counter.c
> index b814d6c..92afdc1 100644
> --- a/kernel/res_counter.c
> +++ b/kernel/res_counter.c
> @@ -18,7 +18,6 @@ void res_counter_init(struct res_counter *counter, struct res_counter *parent)
>  {
>  	spin_lock_init(&counter->lock);
>  	counter->limit = RESOURCE_MAX;
> -	counter->soft_limit = RESOURCE_MAX;
>  	counter->parent = parent;
>  }
>  
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 4425f62..7c6cade 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -926,6 +926,14 @@ out:
>  }
>  EXPORT_SYMBOL(mem_cgroup_count_vm_event);
>  
> +bool mem_cgroup_soft_limit_exceeded(struct mem_cgroup *mem)
> +{
> +	if (mem_cgroup_disabled() || mem_cgroup_is_root(mem))
> +		return true;
> +
> +	return res_counter_soft_limit_excess(&mem->res) > 0;
> +}
> +
>  /**
>   * mem_cgroup_zone_lruvec - get the lru list vector for a zone and memcg
>   * @zone: zone of the wanted lruvec
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 0ba7d35..b36d91b 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2091,6 +2091,17 @@ restart:
>  	throttle_vm_writeout(sc->gfp_mask);
>  }
>  
> +static bool should_reclaim_mem_cgroup(struct scan_control *sc,
> +				      struct mem_cgroup *mem,
> +				      int priority)
> +{
> +	if (!global_reclaim(sc) || priority <= DEF_PRIORITY - 3 ||
> +			mem_cgroup_soft_limit_exceeded(mem))
> +		return true;
> +
> +	return false;
> +}
> +

Why "priority <= DEF_PRIORTY - 3" is selected ?
It seems there is no reason. Could you justify this check ?

Thinking briefly, can't we caluculate the ratio as

	number of pages in reclaimable memcg / number of reclaimable pages

And use 'priorty' ? If 

total_reclaimable_pages >> priority > number of pages in reclaimabe memcg

memcg under softlimit should be scanned..then, we can avoid scanning pages
twice.

Hmm, please give reason of the magic value here, anyway.

>  static void shrink_zone(int priority, struct zone *zone,
>  			struct scan_control *sc)
>  {
> @@ -2108,7 +2119,9 @@ static void shrink_zone(int priority, struct zone *zone,
>  			.zone = zone,
>  		};
>  
> -		shrink_mem_cgroup_zone(priority, &mz, sc);
> +		if (should_reclaim_mem_cgroup(sc, memcg, priority))
> +			shrink_mem_cgroup_zone(priority, &mz, sc);
> +
>  		/*
>  		 * Limit reclaim has historically picked one memcg and
>  		 * scanned it with decreasing priority levels until
> @@ -2152,8 +2165,8 @@ static bool shrink_zones(int priority, struct zonelist *zonelist,
>  {
>  	struct zoneref *z;
>  	struct zone *zone;
> -	unsigned long nr_soft_reclaimed;
> -	unsigned long nr_soft_scanned;
> +//	unsigned long nr_soft_reclaimed;
> +//	unsigned long nr_soft_scanned;

Why do you leave these things ?

Hmm, but the whole logic seems clean to me except for magic number.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
