Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 320AE6B0035
	for <linux-mm@kvack.org>; Thu, 29 May 2014 19:01:59 -0400 (EDT)
Received: by mail-ig0-f169.google.com with SMTP id hl10so178334igb.0
        for <linux-mm@kvack.org>; Thu, 29 May 2014 16:01:59 -0700 (PDT)
Received: from mail-ig0-x232.google.com (mail-ig0-x232.google.com [2607:f8b0:4001:c05::232])
        by mx.google.com with ESMTPS id k16si4586549icc.52.2014.05.29.16.01.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 29 May 2014 16:01:58 -0700 (PDT)
Received: by mail-ig0-f178.google.com with SMTP id hl10so134649igb.17
        for <linux-mm@kvack.org>; Thu, 29 May 2014 16:01:58 -0700 (PDT)
Date: Thu, 29 May 2014 16:01:55 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] page_alloc: skip cpuset enforcement for lower zone
 allocations (v4)
In-Reply-To: <20140529184303.GA20571@amt.cnet>
Message-ID: <alpine.DEB.2.02.1405291555120.9336@chino.kir.corp.google.com>
References: <20140523193706.GA22854@amt.cnet> <20140526185344.GA19976@amt.cnet> <53858A06.8080507@huawei.com> <20140528224324.GA1132@amt.cnet> <20140529184303.GA20571@amt.cnet>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marcelo Tosatti <mtosatti@redhat.com>
Cc: Li Zefan <lizefan@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Lai Jiangshan <laijs@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>

On Thu, 29 May 2014, Marcelo Tosatti wrote:

> Zone specific allocations, such as GFP_DMA32, should not be restricted
> to cpusets allowed node list: the zones which such allocations demand
> might be contained in particular nodes outside the cpuset node list.
> 
> Necessary for the following usecase:
> - driver which requires zone specific memory (such as KVM, which
> requires root pagetable at paddr < 4GB).
> - user wants to limit allocations of application to nodeX, and nodeX has
> no memory < 4GB.
> 
> Signed-off-by: Marcelo Tosatti <mtosatti@redhat.com>
> 
> diff --git a/kernel/cpuset.c b/kernel/cpuset.c
> index 3d54c41..3bbc23f 100644
> --- a/kernel/cpuset.c
> +++ b/kernel/cpuset.c
> @@ -2374,6 +2374,7 @@ static struct cpuset *nearest_hardwall_ancestor(struct cpuset *cs)
>   * variable 'wait' is not set, and the bit ALLOC_CPUSET is not set
>   * in alloc_flags.  That logic and the checks below have the combined
>   * affect that:
> + *	gfp_zone(mask) < policy_zone - any node ok
>   *	in_interrupt - any node ok (current task context irrelevant)
>   *	GFP_ATOMIC   - any node ok
>   *	TIF_MEMDIE   - any node ok
> @@ -2392,6 +2393,10 @@ int __cpuset_node_allowed_softwall(int node, gfp_t gfp_mask)
>  
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
> index 5dba293..a0ce1ba 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2726,6 +2726,11 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
>  retry_cpuset:
>  	cpuset_mems_cookie = read_mems_allowed_begin();
>  
> +#ifdef CONFIG_NUMA
> +	if (gfp_zone(gfp_mask) < policy_zone)
> +		nodemask = &node_states[N_ONLINE];
> +#endif
> +
>  	/* The preferred zone is used for statistics later */
>  	first_zones_zonelist(zonelist, high_zoneidx,
>  				nodemask ? : &cpuset_current_mems_allowed,

There are still three issues with this, two of which are only minor and 
one that needs more thought:

 (1) this doesn't affect only cpusets which the changelog indicates, it 
     also bypasses mempolicies for GFP_DMA and GFP_DMA32 allocations since
     the nodemask != NULL in the page allocator when there is an effective
     mempolicy.  That may be precisely what you're trying to do (do the
     same for mempolicies as you're doing for cpusets), but the comment 
     now in the code specifically refers to cpusets.  Can you make a case
     for the mempolicies exception as well?  Otherwise, we'll need to do

	if (!nodemask && gfp_zone(gfp_mask) < policy_zone)
		nodemask = &node_states[N_ONLINE];

And the two minors:

 (2) this should be &node_states[N_MEMORY], not &node_states[N_ONLINE] 
     since memoryless nodes should not be included.  Note that
     guarantee_online_mems() looks at N_MEMORY and
     cpuset_current_mems_allowed is defined for N_MEMORY without
     cpusets.

 (3) it's unnecessary for this to be after the "retry_cpuset" label and
     check the gfp mask again if we need to relook at the allowed cpuset
     mask.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
