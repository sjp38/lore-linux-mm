Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id EDD006B0006
	for <linux-mm@kvack.org>; Tue, 19 Mar 2013 07:07:06 -0400 (EDT)
Date: Tue, 19 Mar 2013 12:07:01 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2 1/5] memcg: make nocpu_base available for non hotplug
Message-ID: <20130319110701.GD7869@dhcp22.suse.cz>
References: <1362489058-3455-1-git-send-email-glommer@parallels.com>
 <1362489058-3455-2-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1362489058-3455-2-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyu@jp.fujitsu.com, handai.szj@gmail.com, anton.vorontsov@linaro.org, Johannes Weiner <hannes@cmpxchg.org>

On Tue 05-03-13 17:10:54, Glauber Costa wrote:
> We are using nocpu_base to accumulate charges on the main counters
> during cpu hotplug. I have a similar need, which is transferring charges
> to the root cgroup when lazily enabling memcg. Because system wide
> information is not kept per-cpu, it is hard to distribute it. This field
> works well for this. So we need to make it available for all usages, not
> only hotplug cases.

Could you also rename it to something else while you are at it?
nocpu_base sounds outdated. What about overflow_base or something like
that.

I am also wondering why do wee need pcp_counter_lock there. Doesn't
get_online_cpus prevent from hotplug so mem_cgroup_drain_pcp_counter
doesn't get called? I am sorry for this stupid question but I am lost in
the hotplug callbacks...

Other than that I don't mind pulling nocpu_base outside the hotplug code
and reusing it for something else. So you can add my
Acked-by: Michal Hocko <mhocko@suse.cz>

but I would be happier with a better name of course ;)

> Signed-off-by: Glauber Costa <glommer@parallels.com>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Tejun Heo <tj@kernel.org>
> ---
>  mm/memcontrol.c | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 669d16a..b8b363f 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -921,11 +921,11 @@ static long mem_cgroup_read_stat(struct mem_cgroup *memcg,
>  	get_online_cpus();
>  	for_each_online_cpu(cpu)
>  		val += per_cpu(memcg->stat->count[idx], cpu);
> -#ifdef CONFIG_HOTPLUG_CPU
> +
>  	spin_lock(&memcg->pcp_counter_lock);
>  	val += memcg->nocpu_base.count[idx];
>  	spin_unlock(&memcg->pcp_counter_lock);
> -#endif
> +
>  	put_online_cpus();
>  	return val;
>  }
> @@ -945,11 +945,11 @@ static unsigned long mem_cgroup_read_events(struct mem_cgroup *memcg,
>  
>  	for_each_online_cpu(cpu)
>  		val += per_cpu(memcg->stat->events[idx], cpu);
> -#ifdef CONFIG_HOTPLUG_CPU
> +
>  	spin_lock(&memcg->pcp_counter_lock);
>  	val += memcg->nocpu_base.events[idx];
>  	spin_unlock(&memcg->pcp_counter_lock);
> -#endif
> +
>  	return val;
>  }
>  
> -- 
> 1.8.1.2
> 
> --
> To unsubscribe from this list: send the line "unsubscribe cgroups" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
