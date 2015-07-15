Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f171.google.com (mail-yk0-f171.google.com [209.85.160.171])
	by kanga.kvack.org (Postfix) with ESMTP id 8EFEA28027E
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 17:48:07 -0400 (EDT)
Received: by ykay190 with SMTP id y190so48602156yka.3
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 14:48:07 -0700 (PDT)
Received: from mail-yk0-x229.google.com (mail-yk0-x229.google.com. [2607:f8b0:4002:c07::229])
        by mx.google.com with ESMTPS id g193si4051077ywb.75.2015.07.15.14.48.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jul 2015 14:48:06 -0700 (PDT)
Received: by ykay190 with SMTP id y190so48601778yka.3
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 14:48:06 -0700 (PDT)
Date: Wed, 15 Jul 2015 17:48:02 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 1/5] x86, gfp: Cache best near node for memory allocation.
Message-ID: <20150715214802.GL15934@mtj.duckdns.org>
References: <1436261425-29881-1-git-send-email-tangchen@cn.fujitsu.com>
 <1436261425-29881-2-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1436261425-29881-2-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: mingo@redhat.com, akpm@linux-foundation.org, rjw@rjwysocki.net, hpa@zytor.com, laijs@cn.fujitsu.com, yasu.isimatu@gmail.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, gongzhaogang@inspur.com, qiaonuohan@cn.fujitsu.com, x86@kernel.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Gu Zheng <guz.fnst@cn.fujitsu.com>

Hello,

On Tue, Jul 07, 2015 at 05:30:21PM +0800, Tang Chen wrote:
...
> Why doing this is to prevent memory allocation failure if the cpu is

"The reason for doing this ..."

> online but there is no memory on that node.
> 
> But since cpuid <-> nodeid mapping will fix after this patch-set, doing

"But since cpuid <-> nodeid mapping is planned to be made static, ..."

> so in initialization pharse makes no sense any more. The best near online
> node for each cpu should be cached somewhere.

I'm not really following.  Is this because the now offline node can
later come online and we'd have to break the constant mapping
invariant if we update the mapping later?  If so, it'd be nice to
spell that out.

>  void numa_set_node(int cpu, int node)
>  {
>  	int *cpu_to_node_map = early_per_cpu_ptr(x86_cpu_to_node_map);
> @@ -95,7 +121,11 @@ void numa_set_node(int cpu, int node)
>  		return;
>  	}
>  #endif
> +
> +	per_cpu(x86_cpu_to_near_online_node, cpu) =
> +			find_near_online_node(numa_cpu_node(cpu));
>  	per_cpu(x86_cpu_to_node_map, cpu) = node;
> +	cpumask_set_cpu(cpu, &node_to_cpuid_mask_map[numa_cpu_node(cpu)]);
>  
>  	set_cpu_numa_node(cpu, node);
>  }
> @@ -105,6 +135,13 @@ void numa_clear_node(int cpu)
>  	numa_set_node(cpu, NUMA_NO_NODE);
>  }
>  
> +int get_near_online_node(int node)
> +{
> +	return per_cpu(x86_cpu_to_near_online_node,
> +		       cpumask_first(&node_to_cpuid_mask_map[node]));
> +}
> +EXPORT_SYMBOL(get_near_online_node);

Umm... this function is sitting on a fairly hot path and scanning a
cpumask each time.  Why not just build a numa node -> numa node array?

> @@ -702,24 +739,6 @@ void __init x86_numa_init(void)
>  	numa_init(dummy_numa_init);
>  }
>  
> -static __init int find_near_online_node(int node)
> -{
> -	int n, val;
> -	int min_val = INT_MAX;
> -	int best_node = -1;
> -
> -	for_each_online_node(n) {
> -		val = node_distance(node, n);
> -
> -		if (val < min_val) {
> -			min_val = val;
> -			best_node = n;
> -		}
> -	}
> -
> -	return best_node;
> -}

It's usually better to not mix code movement with actual changes.

> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 6ba7cf2..4a18b21 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -307,13 +307,23 @@ static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
>  	if (nid < 0)
>  		nid = numa_node_id();
>  
> +#if IS_ENABLED(CONFIG_X86) && IS_ENABLED(CONFIG_NUMA)
> +	if (!node_online(nid))
> +		nid = get_near_online_node(nid);
> +#endif

Can you please introduce a wrapper function to do the above so that we
don't open code ifdefs?

> +
>  	return __alloc_pages(gfp_mask, order, node_zonelist(nid, gfp_mask));
>  }
>  
>  static inline struct page *alloc_pages_exact_node(int nid, gfp_t gfp_mask,
>  						unsigned int order)
>  {
> -	VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES || !node_online(nid));
> +	VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES);
> +
> +#if IS_ENABLED(CONFIG_X86) && IS_ENABLED(CONFIG_NUMA)
> +	if (!node_online(nid))
> +		nid = get_near_online_node(nid);
> +#endif
>  
>  	return __alloc_pages(gfp_mask, order, node_zonelist(nid, gfp_mask));
>  }

Ditto.  Also, what's the synchronization rules for NUMA node
on/offlining.  If you end up updating the mapping later, how would
that be synchronized against the above usages?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
