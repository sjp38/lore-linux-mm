Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 5DECB6B0032
	for <linux-mm@kvack.org>; Fri,  7 Jun 2013 05:21:35 -0400 (EDT)
Date: Fri, 7 Jun 2013 11:21:32 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: do not account memory used for cache creation
Message-ID: <20130607092132.GE8117@dhcp22.suse.cz>
References: <1370355059-24968-1-git-send-email-glommer@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1370355059-24968-1-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@openvz.org>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com

On Tue 04-06-13 18:10:59, Glauber Costa wrote:
> The memory we used to hold the memcg arrays is currently accounted to
> the current memcg.

Maybe I have missed a train but I thought that only some caches are
tracked and those have to be enabled explicitly by using __GFP_KMEMCG in
gfp flags.

But d79923fa "sl[au]b: allocate objects from memcg cache" seems to be
setting gfp unconditionally for large caches. The changelog doesn't
explain why, though? This is really confusing.

> But that creates a problem, because that memory can
> only be freed after the last user is gone. Our only way to know which is
> the last user, is to hook up to freeing time, but the fact that we still
> have some in flight kmallocs will prevent freeing to happen. I believe
> therefore to be just easier to account this memory as global overhead.

No internal allocations for memcg can be tracked otherwise we call for a
problem. How do we know that others are safe?

> Signed-off-by: Glauber Costa <glommer@openvz.org>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> ---
> I noticed this while testing nuances of the shrinker patches. The
> caches would basically stay present forever, even if we managed to
> flush all of the actual memory being used. With this patch applied,
> they would go away all right.
> ---
>  mm/memcontrol.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 5d8b93a..aa1cbd4 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -5642,7 +5642,9 @@ static int memcg_propagate_kmem(struct mem_cgroup *memcg)
>  	static_key_slow_inc(&memcg_kmem_enabled_key);
>  
>  	mutex_lock(&set_limit_mutex);
> +	memcg_stop_kmem_account();
>  	ret = memcg_update_cache_sizes(memcg);
> +	memcg_resume_kmem_account();
>  	mutex_unlock(&set_limit_mutex);
>  out:
>  	return ret;
> -- 
> 1.8.1.4
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
