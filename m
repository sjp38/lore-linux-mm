Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 1E2A06B0062
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 09:31:52 -0400 (EDT)
Date: Mon, 18 Jun 2012 15:31:50 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 2/2] memcg: clean up force_empty_list() return value check
Message-ID: <20120618133149.GC2313@tiehlicka.suse.cz>
References: <4FDF17A3.9060202@jp.fujitsu.com>
 <4FDF1830.1000504@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FDF1830.1000504@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>

On Mon 18-06-12 20:59:44, KAMEZAWA Hiroyuki wrote:
> 
> By commit "memcg: move charges to root cgroup if use_hierarchy=0"
> mem_cgroup_move_parent() only returns -EBUSY, -EINVAL.
> So, we can remove -ENOMEM and -EINTR checks.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/memcontrol.c |    5 -----
>  1 files changed, 0 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index cf8a0f6..726b7c6 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3847,8 +3847,6 @@ static int mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
>  		pc = lookup_page_cgroup(page);
>  
>  		ret = mem_cgroup_move_parent(page, pc, memcg, GFP_KERNEL);
> -		if (ret == -ENOMEM || ret == -EINTR)
> -			break;
>  
>  		if (ret == -EBUSY || ret == -EINVAL) {
>  			/* found lock contention or "pc" is obsolete. */
> @@ -3910,9 +3908,6 @@ move_account:
>  		}
>  		mem_cgroup_end_move(memcg);
>  		memcg_oom_recover(memcg);
> -		/* it seems parent cgroup doesn't have enough mem */
> -		if (ret == -ENOMEM)
> -			goto try_to_free;
>  		cond_resched();
>  	/* "ret" should also be checked to ensure all lists are empty. */
>  	} while (res_counter_read_u64(&memcg->res, RES_USAGE) > 0 || ret);
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
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
