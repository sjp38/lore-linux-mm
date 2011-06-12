Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A87D76B0012
	for <linux-mm@kvack.org>; Sun, 12 Jun 2011 07:22:37 -0400 (EDT)
Date: Sun, 12 Jun 2011 13:22:28 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [BUGFIX][PATCH] memcg: fix wrong decision of noswap with
 softlimit.
Message-ID: <20110612112228.GC19493@tiehlicka.suse.cz>
References: <20110609095445.5f98b752.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110609095445.5f98b752.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "bsingharora@gmail.com" <bsingharora@gmail.com>

On Thu 09-06-11 09:54:45, KAMEZAWA Hiroyuki wrote:
> I wonder this should go stable...
> ==
> From e2565de1c764057b75b4d9a1674d163b6c873cdd Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Thu, 9 Jun 2011 09:54:32 +0900
> Subject: [PATCH 2/2] Fix softlimit wrong check of noswap
> 
> Now, hierarchical reclaim doesn't make swap if memory's limit is
> equal to mem+swap limit. Because if reclaim does swap-out,
> it still hits mem+swap limit and there will be no progress.
> WHEN HITTING HARD LIMIT.
> 
> When it comes to softlimit, it works for kswapd. noswap is nonsense.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Maybe the changelog should be more clear. What about something like:
"
Hierarchical reclaim doesn't swap out if memsw and resource limits are
same (memsw_is_minimum == true) because we would hit mem+swap limit
anyway (during hard limit reclaim).
If it comes to the solft limit we shouldn't consider memsw_is_minimum at
all because it doesn't make much sense. Either the soft limit is bellow
the hard limit and then we cannot hit mem+swap limit or the direct
reclaim takes a precedence.
"
Reviewed-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/memcontrol.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 3baddcb..06825be 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1663,7 +1663,7 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
>  	excess = res_counter_soft_limit_excess(&root_mem->res) >> PAGE_SHIFT;
>  
>  	/* If memsw_is_minimum==1, swap-out is of-no-use. */
> -	if (root_mem->memsw_is_minimum)
> +	if (!check_soft && root_mem->memsw_is_minimum)
>  		noswap = true;
>  
>  	while (1) {
> -- 
> 1.7.4.1
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

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
