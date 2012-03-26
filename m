Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id A8ACF6B0044
	for <linux-mm@kvack.org>; Mon, 26 Mar 2012 11:59:39 -0400 (EDT)
Date: Mon, 26 Mar 2012 17:59:35 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v6 7/7] mm/memcg: use vm_swappiness from target memory
 cgroup
Message-ID: <20120326155935.GE22754@tiehlicka.suse.cz>
References: <20120322214944.27814.42039.stgit@zurg>
 <20120322215643.27814.58756.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120322215643.27814.58756.stgit@zurg>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujtisu.com>

On Fri 23-03-12 01:56:43, Konstantin Khlebnikov wrote:
> Use vm_swappiness from memory cgroup which is triggered this memory reclaim.
> This is more reasonable and allows to kill one argument.

Could you be more specific why is this more reasonable? 
I am afraid this might lead to an unexpected behavior when the target
memcg has quite high swappiness while other groups in the hierarchy have
it 0 so we would end up swapping even from those groups.

> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujtisu.com>
> ---
>  mm/vmscan.c |    9 ++++-----
>  1 files changed, 4 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 9de66be..5e2906d 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1840,12 +1840,11 @@ static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
>  	return shrink_inactive_list(nr_to_scan, mz, sc, priority, lru);
>  }
>  
> -static int vmscan_swappiness(struct mem_cgroup_zone *mz,
> -			     struct scan_control *sc)
> +static int vmscan_swappiness(struct scan_control *sc)
>  {
>  	if (global_reclaim(sc))
>  		return vm_swappiness;
> -	return mem_cgroup_swappiness(mz->mem_cgroup);
> +	return mem_cgroup_swappiness(sc->target_mem_cgroup);
>  }
>  
>  /*
> @@ -1913,8 +1912,8 @@ static void get_scan_count(struct mem_cgroup_zone *mz, struct scan_control *sc,
>  	 * With swappiness at 100, anonymous and file have the same priority.
>  	 * This scanning priority is essentially the inverse of IO cost.
>  	 */
> -	anon_prio = vmscan_swappiness(mz, sc);
> -	file_prio = 200 - vmscan_swappiness(mz, sc);
> +	anon_prio = vmscan_swappiness(sc);
> +	file_prio = 200 - vmscan_swappiness(sc);
>  
>  	/*
>  	 * OK, so we have swap space and a fair amount of page cache
> 
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
