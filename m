Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id B30AA6B0035
	for <linux-mm@kvack.org>; Wed, 28 May 2014 19:45:08 -0400 (EDT)
Received: by mail-qg0-f48.google.com with SMTP id i50so19826178qgf.21
        for <linux-mm@kvack.org>; Wed, 28 May 2014 16:45:08 -0700 (PDT)
Received: from qmta05.emeryville.ca.mail.comcast.net (qmta05.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:48])
        by mx.google.com with ESMTP id k10si22590269qaj.33.2014.05.28.16.45.07
        for <linux-mm@kvack.org>;
        Wed, 28 May 2014 16:45:07 -0700 (PDT)
Date: Wed, 28 May 2014 18:45:04 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH] page_alloc: skip cpuset enforcement for lower zone
 allocations (v3)
In-Reply-To: <20140528224324.GA1132@amt.cnet>
Message-ID: <alpine.DEB.2.10.1405281838370.6096@gentwo.org>
References: <20140523193706.GA22854@amt.cnet> <20140526185344.GA19976@amt.cnet> <53858A06.8080507@huawei.com> <20140528224324.GA1132@amt.cnet>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marcelo Tosatti <mtosatti@redhat.com>
Cc: Li Zefan <lizefan@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Lai Jiangshan <laijs@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed, 28 May 2014, Marcelo Tosatti wrote:

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 5dba293..dfea3dc 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2698,6 +2698,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
>  	unsigned int cpuset_mems_cookie;
>  	int alloc_flags = ALLOC_WMARK_LOW|ALLOC_CPUSET|ALLOC_FAIR;
>  	struct mem_cgroup *memcg = NULL;
> +	nodemask_t *cpuset_mems_allowed = &cpuset_current_mems_allowed;

Why do you need this one?

>  	gfp_mask &= gfp_allowed_mask;
>
> @@ -2726,9 +2727,14 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
>  retry_cpuset:
>  	cpuset_mems_cookie = read_mems_allowed_begin();
>
> +#ifdef CONFIG_NUMA
> +	if (gfp_zone(gfp_mask) < policy_zone)
> +		cpuset_mems_allowed = NULL;

nodemask = &node_states[N_ONLINE];

> +#endif


> +
>  	/* The preferred zone is used for statistics later */
>  	first_zones_zonelist(zonelist, high_zoneidx,
> -				nodemask ? : &cpuset_current_mems_allowed,
> +				nodemask ? : cpuset_mems_allowed,

Skip this?

>  				&preferred_zone);
>  	if (!preferred_zone)
>  		goto out;
>

Why call __alloc_pages_nodemask at all if you want to skip the node
handling? Punt to alloc_pages()

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
