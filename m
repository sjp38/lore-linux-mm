Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id 39EF56B0038
	for <linux-mm@kvack.org>; Thu, 29 May 2014 19:54:03 -0400 (EDT)
Received: by mail-ig0-f178.google.com with SMTP id hl10so175370igb.17
        for <linux-mm@kvack.org>; Thu, 29 May 2014 16:54:03 -0700 (PDT)
Received: from mail-ig0-x232.google.com (mail-ig0-x232.google.com [2607:f8b0:4001:c05::232])
        by mx.google.com with ESMTPS id b2si4775177icl.16.2014.05.29.16.54.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 29 May 2014 16:54:02 -0700 (PDT)
Received: by mail-ig0-f178.google.com with SMTP id hl10so175362igb.17
        for <linux-mm@kvack.org>; Thu, 29 May 2014 16:54:02 -0700 (PDT)
Date: Thu, 29 May 2014 16:54:00 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] page_alloc: skip cpuset enforcement for lower zone
 allocations (v5)
In-Reply-To: <20140529232819.GA29803@amt.cnet>
Message-ID: <alpine.DEB.2.02.1405291638300.9336@chino.kir.corp.google.com>
References: <20140523193706.GA22854@amt.cnet> <20140526185344.GA19976@amt.cnet> <53858A06.8080507@huawei.com> <20140528224324.GA1132@amt.cnet> <20140529184303.GA20571@amt.cnet> <alpine.DEB.2.02.1405291555120.9336@chino.kir.corp.google.com>
 <20140529232819.GA29803@amt.cnet>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marcelo Tosatti <mtosatti@redhat.com>
Cc: Li Zefan <lizefan@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Lai Jiangshan <laijs@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>

On Thu, 29 May 2014, Marcelo Tosatti wrote:

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
> index 5dba293..0fd6923 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2723,6 +2723,11 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
>  	if (!memcg_kmem_newpage_charge(gfp_mask, &memcg, order))
>  		return NULL;
>  
> +#ifdef CONFIG_NUMA
> +	if (!nodemask && gfp_zone(gfp_mask) < policy_zone)
> +		nodemask = &node_states[N_MEMORY];
> +#endif
> +
>  retry_cpuset:
>  	cpuset_mems_cookie = read_mems_allowed_begin();
>  

When I said that my point about mempolicies needs more thought, I wasn't 
expecting that there would be no discussion -- at least _something_ that 
would say why we don't care about the mempolicy case.

The motivation here is identical for both cpusets and mempolicies.  What 
is the significant difference between attaching a process to a cpuset 
without access to lowmem and a process doing set_mempolicy(MPOL_BIND) 
without access to lowmem?  Is it because the process should know what it's 
doing if it asks for a mempolicy that doesn't include lowmem?  If so, is 
the cpusets case different because the cpuset attacher isn't held to the 
same standard?

I'd argue that an application may never know if it needs to allocate 
GFP_DMA32 or not since its a property of the hardware that its running on 
and my driver may need to access lowmem while yours may not.  I may even 
configure CONFIG_ZONE_DMA=n and CONFIG_ZONE_DMA32=n because I know the 
_hardware_ requirements of my platforms.

If there is no difference, then why are we allowing the exception for 
cpusets and not mempolicies?

I really think you want to allow both cpusets and mempolicies.  I'd like 
to hear Christoph's thoughts on it as well, though.

Furthermore, I don't know why you're opposed to the comments that Andrew 
added here.  In the first version of this patch, I suggested a comment and 
you referred to a kernel/cpuset.c comment.  Nowhere in the above change to 
the page allocator would make anyone think of cpusets or what it is trying 
to do.  Please comment the code accordingly so your intention is 
understood for everybody else who happens upon your code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
