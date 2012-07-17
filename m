Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 5B95F6B005A
	for <linux-mm@kvack.org>; Tue, 17 Jul 2012 06:56:45 -0400 (EDT)
Date: Tue, 17 Jul 2012 12:56:40 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm/memcg: remove redundant checking on root memcg
Message-ID: <20120717105640.GB25435@tiehlicka.suse.cz>
References: <1342518147-10406-1-git-send-email-liwanp@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1342518147-10406-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Gavin Shan <shangw@linux.vnet.ibm.com>

On Tue 17-07-12 17:42:27, Wanpeng Li wrote:
> Function __mem_cgroup_cancel_local_charge is only called by
> mem_cgroup_move_parent. For this case, root memcg has been
> checked by mem_cgroup_move_parent. So we needn't check that
> again in function __mem_cgroup_cancel_local_charge and just
> remove the check in function __mem_cgroup_cancel_local_charge.

It's true that the check is not necessary but on the other hand
__mem_cgroup_cancel_charge does check it and it would be unfortunate to
have two very similar functions with different expectations (one can be
called for the root cgroup while other one cannot).

> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> ---
>  mm/memcontrol.c |    3 ---
>  1 files changed, 0 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 6392c0a..d346347 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2404,9 +2404,6 @@ static void __mem_cgroup_cancel_local_charge(struct mem_cgroup *memcg,
>  {
>  	unsigned long bytes = nr_pages * PAGE_SIZE;
>  
> -	if (mem_cgroup_is_root(memcg))
> -		return;
> -
>  	res_counter_uncharge_until(&memcg->res, memcg->res.parent, bytes);
>  	if (do_swap_account)
>  		res_counter_uncharge_until(&memcg->memsw,
> -- 
> 1.7.5.4
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
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
