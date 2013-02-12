Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id B172E6B0005
	for <linux-mm@kvack.org>; Tue, 12 Feb 2013 09:56:39 -0500 (EST)
Date: Tue, 12 Feb 2013 15:56:35 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: fix kmemcg registration for late caches
Message-ID: <20130212145635.GF4863@dhcp22.suse.cz>
References: <1360600797-27793-1-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1360600797-27793-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, cgroups@vger.kernel.org

On Mon 11-02-13 20:39:57, Glauber Costa wrote:
> The designed workflow for the caches in kmemcg is: register it with
> memcg_register_cache() if kmemcg is already available or later on when a
> new kmemcg appears at memcg_update_cache_sizes() which will handle all
> caches in the system. The caches created at boot time will be handled by
> the later, and the memcg-caches as well as any system caches that are
> registered later on by the former.
> 
> There is a bug, however, in memcg_register_cache: we correctly set up
> the array size, but do not mark the cache as a root cache. This means
> that allocations for any cache appearing late in the game will see
> memcg->memcg_params->is_root_cache == false, and in particular, trigger
> VM_BUG_ON(!cachep->memcg_params->is_root_cache) in
> __memcg_kmem_cache_get.
> 
> The obvious fix is to include the missing assignment.
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>

Reviewed-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/memcontrol.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 03ebf68..d4e83d0 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3147,7 +3147,9 @@ int memcg_register_cache(struct mem_cgroup *memcg, struct kmem_cache *s,
>  	if (memcg) {
>  		s->memcg_params->memcg = memcg;
>  		s->memcg_params->root_cache = root_cache;
> -	}
> +	} else
> +		s->memcg_params->is_root_cache = true;
> +
>  	return 0;
>  }
>  
> -- 
> 1.8.1.2
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
