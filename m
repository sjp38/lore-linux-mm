Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f53.google.com (mail-oa0-f53.google.com [209.85.219.53])
	by kanga.kvack.org (Postfix) with ESMTP id 075106B0036
	for <linux-mm@kvack.org>; Wed, 28 May 2014 03:04:19 -0400 (EDT)
Received: by mail-oa0-f53.google.com with SMTP id m1so10783214oag.40
        for <linux-mm@kvack.org>; Wed, 28 May 2014 00:04:19 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id q11si29066346oey.29.2014.05.28.00.04.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 28 May 2014 00:04:19 -0700 (PDT)
Message-ID: <53858A06.8080507@huawei.com>
Date: Wed, 28 May 2014 15:02:30 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] page_alloc: skip cpuset enforcement for lower zone allocations
 (v2)
References: <20140523193706.GA22854@amt.cnet> <20140526185344.GA19976@amt.cnet>
In-Reply-To: <20140526185344.GA19976@amt.cnet>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marcelo Tosatti <mtosatti@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Lai Jiangshan <laijs@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>

On 2014/5/27 2:53, Marcelo Tosatti wrote:
> 
> Zone specific allocations, such as GFP_DMA32, should not be restricted
> to cpusets allowed node list: the zones which such allocations demand
> might be contained in particular nodes outside the cpuset node list.
> 
> The alternative would be to not perform such allocations from
> applications which are cpuset restricted, which is unrealistic.
> 
> Fixes KVM's alloc_page(gfp_mask=GFP_DMA32) with cpuset as explained.
> 

Could you add the use case that you described in a previous email to
the changelog?

> Signed-off-by: Marcelo Tosatti <mtosatti@redhat.com>
> 
> v2: fix slowpath as well (David Rientjes)
> 
> diff --git a/kernel/cpuset.c b/kernel/cpuset.c
> index 3d54c41..b70a336 100644
> --- a/kernel/cpuset.c
> +++ b/kernel/cpuset.c
> @@ -2392,6 +2392,10 @@ int __cpuset_node_allowed_softwall(int node, gfp_t gfp_mask)
>  

Add a comment accordingly?

	 *      in_interrupt - any node ok (current task context irrelevant)
	 *      GFP_ATOMIC   - any node ok
	 *      TIF_MEMDIE   - any node ok
	 *      GFP_KERNEL   - any node in enclosing hardwalled cpuset ok
	 *      GFP_USER     - only nodes in current tasks mems allowed ok.

>  	if (in_interrupt() || (gfp_mask & __GFP_THISNODE))
>  		return 1;
> +#ifdef CONFIG_NUMA
> +	if (gfp_zone(gfp_mask) < policy_zone)
> +		return 1;
> +#endif
>  	might_sleep_if(!(gfp_mask & __GFP_HARDWALL));
>  	if (node_isset(node, current->mems_allowed))
>  		return 1;
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 5dba293..dfea3dc 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2698,6 +2698,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
>  	unsigned int cpuset_mems_cookie;
>  	int alloc_flags = ALLOC_WMARK_LOW|ALLOC_CPUSET|ALLOC_FAIR;
>  	struct mem_cgroup *memcg = NULL;
> +	nodemask_t *cpuset_mems_allowed = &cpuset_current_mems_allowed;
>  
>  	gfp_mask &= gfp_allowed_mask;
>  
> @@ -2726,9 +2727,14 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
>  retry_cpuset:
>  	cpuset_mems_cookie = read_mems_allowed_begin();
>  
> +#ifdef CONFIG_NUMA
> +	if (gfp_zone(gfp_mask) < policy_zone)
> +		cpuset_mems_allowed = NULL;
> +#endif
> +
>  	/* The preferred zone is used for statistics later */
>  	first_zones_zonelist(zonelist, high_zoneidx,
> -				nodemask ? : &cpuset_current_mems_allowed,
> +				nodemask ? : cpuset_mems_allowed,
>  				&preferred_zone);
>  	if (!preferred_zone)
>  		goto out;
> .
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
