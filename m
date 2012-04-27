Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id D8F9B6B00E7
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 13:17:57 -0400 (EDT)
Message-ID: <4F9AD455.9030306@parallels.com>
Date: Fri, 27 Apr 2012 14:16:05 -0300
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 4/7 v2] memcg: use res_counter_uncharge_until in
 move_parent
References: <4F9A327A.6050409@jp.fujitsu.com> <4F9A34B2.8080103@jp.fujitsu.com>
In-Reply-To: <4F9A34B2.8080103@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Frederic Weisbecker <fweisbec@gmail.com>, Tejun Heo <tj@kernel.org>, Han Ying <yinghan@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyuki@gmail.com

On 04/27/2012 02:54 AM, KAMEZAWA Hiroyuki wrote:
> By using res_counter_uncharge_until(), we can avoid
> unnecessary charging.
> 
> Signed-off-by: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
> ---
>   mm/memcontrol.c |   63 ++++++++++++++++++++++++++++++++++++------------------
>   1 files changed, 42 insertions(+), 21 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 613bb15..ed53d64 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2420,6 +2420,24 @@ static void __mem_cgroup_cancel_charge(struct mem_cgroup *memcg,
>   }
> 
>   /*
> + * Cancel chages in this cgroup....doesn't propagates to parent cgroup.
> + * This is useful when moving usage to parent cgroup.
> + */
> +static void __mem_cgroup_cancel_local_charge(struct mem_cgroup *memcg,
> +					unsigned int nr_pages)
> +{
> +	if (!mem_cgroup_is_root(memcg)) {
> +		unsigned long bytes = nr_pages * PAGE_SIZE;
> +
> +		res_counter_uncharge_until(&memcg->res,
> +					memcg->res.parent, bytes);
> +		if (do_swap_account)
> +			res_counter_uncharge_until(&memcg->memsw,
> +						memcg->memsw.parent, bytes);
> +	}
> +}

Kame, this is a nitpick, but I usually prefer to write this like:

if (mem_cgroup_is_root(memcg))
   return;

res_counter...

Specially with memcg, where function names are bigger than average, in
comparison.

the code itself seems fine.

> +/*
>    * A helper function to get mem_cgroup from ID. must be called under
>    * rcu_read_lock(). The caller must check css_is_removed() or some if
>    * it's concern. (dropping refcnt from swap can be called against removed
> @@ -2677,16 +2695,28 @@ static int mem_cgroup_move_parent(struct page *page,
>   	nr_pages = hpage_nr_pages(page);
> 
>   	parent = mem_cgroup_from_cont(pcg);
> -	ret = __mem_cgroup_try_charge(NULL, gfp_mask, nr_pages,&parent, false);
> -	if (ret)
> -		goto put_back;
> +	if (!parent->use_hierarchy) {
Can we avoid testing for use hierarchy ?
Specially given this might go away.

parent_mem_cgroup() already bundles this information. So maybe we can
test for parent_mem_cgroup(parent) == NULL. It is the same thing after all.
> +		ret = __mem_cgroup_try_charge(NULL,
> +					gfp_mask, nr_pages,&parent, false);
> +		if (ret)
> +			goto put_back;
> +	}

Why? If we are not hierarchical, we should not charge the parent, right?

>   	if (nr_pages>  1)
>   		flags = compound_lock_irqsave(page);
> 
> -	ret = mem_cgroup_move_account(page, nr_pages, pc, child, parent, true);
> -	if (ret)
> -		__mem_cgroup_cancel_charge(parent, nr_pages);
> +	if (parent->use_hierarchy) {
> +		ret = mem_cgroup_move_account(page, nr_pages,
> +					pc, child, parent, false);
> +		if (!ret)
> +			__mem_cgroup_cancel_local_charge(child, nr_pages);
> +	} else {
> +		ret = mem_cgroup_move_account(page, nr_pages,
> +					pc, child, parent, true);
> +
> +		if (ret)
> +			__mem_cgroup_cancel_charge(parent, nr_pages);
> +	}

Calling move account also seems not necessary to me. If we are not
uncharging + charging, we won't even touch the parent.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
