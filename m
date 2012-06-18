Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id 84EF66B0071
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 08:10:01 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 1EDF43EE0BB
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 21:10:00 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id F178A45DE56
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 21:09:59 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id CD19845DE52
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 21:09:59 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 511461DB803E
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 21:09:59 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7052CE18007
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 21:09:58 +0900 (JST)
Message-ID: <4FDF1A0D.6080204@jp.fujitsu.com>
Date: Mon, 18 Jun 2012 21:07:41 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 05/25] memcg: Always free struct memcg through schedule_work()
References: <1340015298-14133-1-git-send-email-glommer@parallels.com> <1340015298-14133-6-git-send-email-glommer@parallels.com>
In-Reply-To: <1340015298-14133-6-git-send-email-glommer@parallels.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Cristoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, cgroups@vger.kernel.org, devel@openvz.org, linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, Suleiman Souhlal <suleiman@google.com>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>

(2012/06/18 19:27), Glauber Costa wrote:
> Right now we free struct memcg with kfree right after a
> rcu grace period, but defer it if we need to use vfree() to get
> rid of that memory area. We do that by need, because we need vfree
> to be called in a process context.
> 
> This patch unifies this behavior, by ensuring that even kfree will
> happen in a separate thread. The goal is to have a stable place to
> call the upcoming jump label destruction function outside the realm
> of the complicated and quite far-reaching cgroup lock (that can't be
> held when calling neither the cpu_hotplug.lock nor the jump_label_mutex)
> 
> Signed-off-by: Glauber Costa<glommer@parallels.com>
> CC: Tejun Heo<tj@kernel.org>
> CC: Li Zefan<lizefan@huawei.com>
> CC: Kamezawa Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
> CC: Johannes Weiner<hannes@cmpxchg.org>
> CC: Michal Hocko<mhocko@suse.cz>

How about cut out this patch and merge first as simple cleanu up and
to reduce patch stack on your side ?

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

> ---
>   mm/memcontrol.c |   24 +++++++++++++-----------
>   1 file changed, 13 insertions(+), 11 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index e3b528e..ce15be4 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -245,8 +245,8 @@ struct mem_cgroup {
>   		 */
>   		struct rcu_head rcu_freeing;
>   		/*
> -		 * But when using vfree(), that cannot be done at
> -		 * interrupt time, so we must then queue the work.
> +		 * We also need some space for a worker in deferred freeing.
> +		 * By the time we call it, rcu_freeing is not longer in use.
>   		 */
>   		struct work_struct work_freeing;
>   	};
> @@ -4826,23 +4826,28 @@ out_free:
>   }
> 
>   /*
> - * Helpers for freeing a vzalloc()ed mem_cgroup by RCU,
> + * Helpers for freeing a kmalloc()ed/vzalloc()ed mem_cgroup by RCU,
>    * but in process context.  The work_freeing structure is overlaid
>    * on the rcu_freeing structure, which itself is overlaid on memsw.
>    */
> -static void vfree_work(struct work_struct *work)
> +static void free_work(struct work_struct *work)
>   {
>   	struct mem_cgroup *memcg;
> +	int size = sizeof(struct mem_cgroup);
> 
>   	memcg = container_of(work, struct mem_cgroup, work_freeing);
> -	vfree(memcg);
> +	if (size<  PAGE_SIZE)
> +		kfree(memcg);
> +	else
> +		vfree(memcg);
>   }
> -static void vfree_rcu(struct rcu_head *rcu_head)
> +
> +static void free_rcu(struct rcu_head *rcu_head)
>   {
>   	struct mem_cgroup *memcg;
> 
>   	memcg = container_of(rcu_head, struct mem_cgroup, rcu_freeing);
> -	INIT_WORK(&memcg->work_freeing, vfree_work);
> +	INIT_WORK(&memcg->work_freeing, free_work);
>   	schedule_work(&memcg->work_freeing);
>   }
> 
> @@ -4868,10 +4873,7 @@ static void __mem_cgroup_free(struct mem_cgroup *memcg)
>   		free_mem_cgroup_per_zone_info(memcg, node);
> 
>   	free_percpu(memcg->stat);
> -	if (sizeof(struct mem_cgroup)<  PAGE_SIZE)
> -		kfree_rcu(memcg, rcu_freeing);
> -	else
> -		call_rcu(&memcg->rcu_freeing, vfree_rcu);
> +	call_rcu(&memcg->rcu_freeing, free_rcu);
>   }
> 
>   static void mem_cgroup_get(struct mem_cgroup *memcg)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
