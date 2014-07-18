Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id E3EA06B0036
	for <linux-mm@kvack.org>; Fri, 18 Jul 2014 04:10:15 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id w10so4628143pde.32
        for <linux-mm@kvack.org>; Fri, 18 Jul 2014 01:10:15 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id 1si2523325pdf.153.2014.07.18.01.10.14
        for <linux-mm@kvack.org>;
        Fri, 18 Jul 2014 01:10:14 -0700 (PDT)
Message-ID: <53C8D6A8.3040400@cn.fujitsu.com>
Date: Fri, 18 Jul 2014 16:11:20 +0800
From: Lai Jiangshan <laijs@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC 1/2] workqueue: use the nearest NUMA node, not the local
 one
References: <20140717230923.GA32660@linux.vnet.ibm.com> <20140717230958.GB32660@linux.vnet.ibm.com>
In-Reply-To: <20140717230958.GB32660@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Jiang Liu <jiang.liu@linux.intel.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>

Hi,

I'm curious about what will it happen when alloc_pages_node(memoryless_node).

If the memory is allocated from the most preferable node for the @memoryless_node,
why we need to bother and use cpu_to_mem() in the caller site?

If not, why the memory allocation subsystem refuses to find a preferable node
for @memoryless_node in this case? Does it intend on some purpose or
it can't find in some cases?

Thanks,
Lai

Added CC to Tejun (workqueue maintainer).

On 07/18/2014 07:09 AM, Nishanth Aravamudan wrote:
> In the presence of memoryless nodes, the workqueue code incorrectly uses
> cpu_to_node() to determine what node to prefer memory allocations come
> from. cpu_to_mem() should be used instead, which will use the nearest
> NUMA node with memory.
> 
> Signed-off-by: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
> 
> diff --git a/kernel/workqueue.c b/kernel/workqueue.c
> index 35974ac..0bba022 100644
> --- a/kernel/workqueue.c
> +++ b/kernel/workqueue.c
> @@ -3547,7 +3547,12 @@ static struct worker_pool *get_unbound_pool(const struct workqueue_attrs *attrs)
>  		for_each_node(node) {
>  			if (cpumask_subset(pool->attrs->cpumask,
>  					   wq_numa_possible_cpumask[node])) {
> -				pool->node = node;
> +				/*
> +				 * We could use local_memory_node(node) here,
> +				 * but it is expensive and the following caches
> +				 * the same value.
> +				 */
> +				pool->node = cpu_to_mem(cpumask_first(pool->attrs->cpumask));
>  				break;
>  			}
>  		}
> @@ -4921,7 +4926,7 @@ static int __init init_workqueues(void)
>  			pool->cpu = cpu;
>  			cpumask_copy(pool->attrs->cpumask, cpumask_of(cpu));
>  			pool->attrs->nice = std_nice[i++];
> -			pool->node = cpu_to_node(cpu);
> +			pool->node = cpu_to_mem(cpu);
>  
>  			/* alloc pool ID */
>  			mutex_lock(&wq_pool_mutex);
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
