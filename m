Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 375E26B00EE
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 06:00:48 -0400 (EDT)
Date: Wed, 10 Aug 2011 12:00:42 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v5 1/6]  memg: better numa scanning
Message-ID: <20110810100042.GA15007@tiehlicka.suse.cz>
References: <20110809190450.16d7f845.kamezawa.hiroyu@jp.fujitsu.com>
 <20110809190824.99347a0f.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110809190824.99347a0f.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>

On Tue 09-08-11 19:08:24, KAMEZAWA Hiroyuki wrote:
> 
> Making memcg numa's scanning information update by schedule_work().
> 
> Now, memcg's numa information is updated under a thread doing
> memory reclaim. It's not very heavy weight now. But upcoming updates
> around numa scanning will add more works. This patch makes
> the update be done by schedule_work() and reduce latency caused
> by this updates.

I am not sure whether this pays off. Anyway, I think it would be better
to place this patch somewhere at the end of the series so that we can
measure its impact separately.

> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Otherwise looks good to me.
Reviewed-by: Michal Hocko <mhocko@suse.cz>

Just a minor nit bellow.

> ---
>  mm/memcontrol.c |   42 ++++++++++++++++++++++++++++++------------
>  1 file changed, 30 insertions(+), 12 deletions(-)
> 
> Index: mmotm-Aug3/mm/memcontrol.c
> ===================================================================
> --- mmotm-Aug3.orig/mm/memcontrol.c
> +++ mmotm-Aug3/mm/memcontrol.c
> @@ -285,6 +285,7 @@ struct mem_cgroup {
>  	nodemask_t	scan_nodes;
>  	atomic_t	numainfo_events;
>  	atomic_t	numainfo_updating;
> +	struct work_struct	numainfo_update_work;
>  #endif
>  	/*
>  	 * Should the accounting and control be hierarchical, per subtree?
> @@ -1567,6 +1568,23 @@ static bool test_mem_cgroup_node_reclaim
>  }
>  #if MAX_NUMNODES > 1
>  
> +static void mem_cgroup_numainfo_update_work(struct work_struct *work)
> +{
> +	struct mem_cgroup *memcg;
> +	int nid;
> +
> +	memcg = container_of(work, struct mem_cgroup, numainfo_update_work);
> +
> +	memcg->scan_nodes = node_states[N_HIGH_MEMORY];
> +	for_each_node_mask(nid, node_states[N_HIGH_MEMORY]) {
> +		if (!test_mem_cgroup_node_reclaimable(memcg, nid, false))
> +			node_clear(nid, memcg->scan_nodes);
> +	}
> +	atomic_set(&memcg->numainfo_updating, 0);
> +	css_put(&memcg->css);
> +}
> +
> +
>  /*
>   * Always updating the nodemask is not very good - even if we have an empty
>   * list or the wrong list here, we can start from some node and traverse all
> @@ -1575,7 +1593,6 @@ static bool test_mem_cgroup_node_reclaim
>   */

Would be good to update the function comment as well (we still have 10s
period there).

>  static void mem_cgroup_may_update_nodemask(struct mem_cgroup *mem)
>  {
> -	int nid;
>  	/*
>  	 * numainfo_events > 0 means there was at least NUMAINFO_EVENTS_TARGET
>  	 * pagein/pageout changes since the last update.
[...]

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
