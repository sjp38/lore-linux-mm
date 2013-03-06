Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 27F916B0005
	for <linux-mm@kvack.org>; Tue,  5 Mar 2013 19:05:21 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 3218C3EE0C3
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 09:05:19 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1848645DEC0
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 09:05:19 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D6E4B45DEBE
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 09:05:18 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C5CA81DB8041
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 09:05:18 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7ACB71DB803B
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 09:05:18 +0900 (JST)
Message-ID: <51368824.7050601@jp.fujitsu.com>
Date: Wed, 06 Mar 2013 09:04:52 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 1/5] memcg: make nocpu_base available for non hotplug
References: <1362489058-3455-1-git-send-email-glommer@parallels.com> <1362489058-3455-2-git-send-email-glommer@parallels.com>
In-Reply-To: <1362489058-3455-2-git-send-email-glommer@parallels.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, handai.szj@gmail.com, anton.vorontsov@linaro.org, Johannes Weiner <hannes@cmpxchg.org>

(2013/03/05 22:10), Glauber Costa wrote:
> We are using nocpu_base to accumulate charges on the main counters
> during cpu hotplug. I have a similar need, which is transferring charges
> to the root cgroup when lazily enabling memcg. Because system wide
> information is not kept per-cpu, it is hard to distribute it. This field
> works well for this. So we need to make it available for all usages, not
> only hotplug cases.
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Tejun Heo <tj@kernel.org>

Acked-by: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>

Hmm..comments on nocpu_base definition will be updated in later patch ?

> ---
>   mm/memcontrol.c | 8 ++++----
>   1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 669d16a..b8b363f 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -921,11 +921,11 @@ static long mem_cgroup_read_stat(struct mem_cgroup *memcg,
>   	get_online_cpus();
>   	for_each_online_cpu(cpu)
>   		val += per_cpu(memcg->stat->count[idx], cpu);
> -#ifdef CONFIG_HOTPLUG_CPU
> +
>   	spin_lock(&memcg->pcp_counter_lock);
>   	val += memcg->nocpu_base.count[idx];
>   	spin_unlock(&memcg->pcp_counter_lock);
> -#endif
> +
>   	put_online_cpus();
>   	return val;
>   }
> @@ -945,11 +945,11 @@ static unsigned long mem_cgroup_read_events(struct mem_cgroup *memcg,
>   
>   	for_each_online_cpu(cpu)
>   		val += per_cpu(memcg->stat->events[idx], cpu);
> -#ifdef CONFIG_HOTPLUG_CPU
> +
>   	spin_lock(&memcg->pcp_counter_lock);
>   	val += memcg->nocpu_base.events[idx];
>   	spin_unlock(&memcg->pcp_counter_lock);
> -#endif
> +
>   	return val;
>   }
>   
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
