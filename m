Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 57AEA6B00CF
	for <linux-mm@kvack.org>; Tue, 17 Jan 2012 10:26:38 -0500 (EST)
Date: Tue, 17 Jan 2012 16:26:35 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC] [PATCH 2/7 v2] memcg: add memory barrier for checking
 account move.
Message-ID: <20120117152635.GA22142@tiehlicka.suse.cz>
References: <20120113173001.ee5260ca.kamezawa.hiroyu@jp.fujitsu.com>
 <20120113173347.6231f510.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120113173347.6231f510.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Ying Han <yinghan@google.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, cgroups@vger.kernel.org, "bsingharora@gmail.com" <bsingharora@gmail.com>

On Fri 13-01-12 17:33:47, KAMEZAWA Hiroyuki wrote:
> I think this bugfix is needed before going ahead. thoughts?
> ==
> From 2cb491a41782b39aae9f6fe7255b9159ac6c1563 Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Fri, 13 Jan 2012 14:27:20 +0900
> Subject: [PATCH 2/7] memcg: add memory barrier for checking account move.
> 
> At starting move_account(), source memcg's per-cpu variable
> MEM_CGROUP_ON_MOVE is set. The page status update
> routine check it under rcu_read_lock(). But there is no memory
> barrier. This patch adds one.

OK this would help to enforce that the CPU would see the current value
but what prevents us from the race with the value update without the
lock? This is as racy as it was before AFAICS.

> 
> Signed-off-by: KAMAZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  mm/memcontrol.c |    5 ++++-
>  1 files changed, 4 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 08b988d..9019069 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1256,8 +1256,10 @@ static void mem_cgroup_start_move(struct mem_cgroup *memcg)
>  
>  	get_online_cpus();
>  	spin_lock(&memcg->pcp_counter_lock);
> -	for_each_online_cpu(cpu)
> +	for_each_online_cpu(cpu) {
>  		per_cpu(memcg->stat->count[MEM_CGROUP_ON_MOVE], cpu) += 1;
> +		smp_wmb();
> +	}
>  	memcg->nocpu_base.count[MEM_CGROUP_ON_MOVE] += 1;
>  	spin_unlock(&memcg->pcp_counter_lock);
>  	put_online_cpus();
> @@ -1294,6 +1296,7 @@ static void mem_cgroup_end_move(struct mem_cgroup *memcg)
>  static bool mem_cgroup_stealed(struct mem_cgroup *memcg)
>  {
>  	VM_BUG_ON(!rcu_read_lock_held());
> +	smp_rmb();
>  	return this_cpu_read(memcg->stat->count[MEM_CGROUP_ON_MOVE]) > 0;
>  }
>  
> -- 
> 1.7.4.1
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe cgroups" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

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
