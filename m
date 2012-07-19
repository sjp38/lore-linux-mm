Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 5F15D6B0069
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 02:09:47 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 3A8A73EE0BB
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 15:09:45 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 20EB545DE50
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 15:09:45 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0938545DE4E
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 15:09:45 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id F23541DB803E
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 15:09:44 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A50351DB8038
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 15:09:44 +0900 (JST)
Message-ID: <5007A418.10801@jp.fujitsu.com>
Date: Thu, 19 Jul 2012 15:07:20 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH RFC] mm/memcg: calculate max hierarchy limit number instead
 of min
References: <a> <1342013081-4096-1-git-send-email-liwp.linux@gmail.com>
In-Reply-To: <1342013081-4096-1-git-send-email-liwp.linux@gmail.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwp.linux@gmail.com>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

(2012/07/11 22:24), Wanpeng Li wrote:
> From: Wanpeng Li <liwp@linux.vnet.ibm.com>
> 
> Since hierachical_memory_limit shows "of bytes of memory limit with
> regard to hierarchy under which the memory cgroup is", the count should
> calculate max hierarchy limit when use_hierarchy in order to show hierarchy
> subtree limit. hierachical_memsw_limit is the same case.
> 
> Signed-off-by: Wanpeng Li <liwp.linux@gmail.com>

Hm ? What is the hierarchical limit for 'C' in following tree ?

A  ---  limit=1G 
 \
  B --  limit=500M
   \
    C - unlimtied

Thanks,
-Kame


> ---
>   mm/memcontrol.c |   14 +++++++-------
>   1 files changed, 7 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 69a7d45..6392c0a 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3929,10 +3929,10 @@ static void memcg_get_hierarchical_limit(struct mem_cgroup *memcg,
>   		unsigned long long *mem_limit, unsigned long long *memsw_limit)
>   {
>   	struct cgroup *cgroup;
> -	unsigned long long min_limit, min_memsw_limit, tmp;
> +	unsigned long long max_limit, max_memsw_limit, tmp;
>   
> -	min_limit = res_counter_read_u64(&memcg->res, RES_LIMIT);
> -	min_memsw_limit = res_counter_read_u64(&memcg->memsw, RES_LIMIT);
> +	max_limit = res_counter_read_u64(&memcg->res, RES_LIMIT);
> +	max_memsw_limit = res_counter_read_u64(&memcg->memsw, RES_LIMIT);
>   	cgroup = memcg->css.cgroup;
>   	if (!memcg->use_hierarchy)
>   		goto out;
> @@ -3943,13 +3943,13 @@ static void memcg_get_hierarchical_limit(struct mem_cgroup *memcg,
>   		if (!memcg->use_hierarchy)
>   			break;
>   		tmp = res_counter_read_u64(&memcg->res, RES_LIMIT);
> -		min_limit = min(min_limit, tmp);
> +		max_limit = max(max_limit, tmp);
>   		tmp = res_counter_read_u64(&memcg->memsw, RES_LIMIT);
> -		min_memsw_limit = min(min_memsw_limit, tmp);
> +		max_memsw_limit = max(max_memsw_limit, tmp);
>   	}
>   out:
> -	*mem_limit = min_limit;
> -	*memsw_limit = min_memsw_limit;
> +	*mem_limit = max_limit;
> +	*memsw_limit = max_memsw_limit;
>   }
>   
>   static int mem_cgroup_reset(struct cgroup *cont, unsigned int event)
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
