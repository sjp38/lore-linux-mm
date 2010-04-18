Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id C8A656B01EF
	for <linux-mm@kvack.org>; Sun, 18 Apr 2010 04:32:35 -0400 (EDT)
Message-ID: <4BCA78BE.9000904@kernel.org>
Date: Sun, 18 Apr 2010 12:13:02 +0900
From: Tejun Heo <tj@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH 4/8] numa:  Introduce numa_mem_id()- effective local memory
 node id
References: <20100415172950.8801.60358.sendpatchset@localhost.localdomain> <20100415173016.8801.34970.sendpatchset@localhost.localdomain>
In-Reply-To: <20100415173016.8801.34970.sendpatchset@localhost.localdomain>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, Andi@domain.invalid, Kleen@domain.invalid, andi@firstfloor.org, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>, eric.whitney@hp.com, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On 04/16/2010 02:30 AM, Lee Schermerhorn wrote:
> +#ifdef CONFIG_HAVE_MEMORYLESS_NODES
> +
> +DECLARE_PER_CPU(int, numa_mem);
> +
> +#ifndef set_numa_mem
> +#define set_numa_mem(__node) percpu_write(numa_mem, __node)
> +#endif
> +
> +#else	/* !CONFIG_HAVE_MEMORYLESS_NODES */
> +
> +#define numa_mem numa_node

Please make it a macro which takes arguments or an inline function.
Name substitutions like this can easily lead to pretty strange
problems when they end up substituting local variable names.

> +static inline void set_numa_mem(int node) {}

and maybe it's a good idea to make the above one emit warning if the
given node id doesn't match the cpu's numa node id?  Also, in general,
setting numa id (cpu or mem) isn't a hot path and it would be better
to take both cpu and the node id arguments.  ie,

  set_numa_mem(unsigned int cpu, int node).

> +#endif	/* [!]CONFIG_HAVE_MEMORYLESS_NODES */
> +
> +#ifndef numa_mem_id
> +/* Returns the number of the nearest Node with memory */
> +#define numa_mem_id()		__this_cpu_read(numa_mem)
> +#endif
> +
> +#ifndef cpu_to_mem
> +#define cpu_to_mem(__cpu)	per_cpu(numa_mem, (__cpu))
> +#endif

Isn't cpu_to_mem() too generic?  Maybe it's a good idea to put 'numa'
or 'node' in the name?

> +#ifdef CONFIG_HAVE_MEMORYLESS_NODES
> +		/*
> +		 * We now know the "local memory node" for each node--
> +		 * i.e., the node of the first zone in the generic zonelist.
> +		 * Set up numa_mem percpu variable for on-line cpus.  During
> +		 * boot, only the boot cpu should be on-line;  we'll init the
> +		 * secondary cpus' numa_mem as they come on-line.  During
> +		 * node/memory hotplug, we'll fixup all on-line cpus.
> +		 */
> +		if (cpu_online(cpu))
> +			cpu_to_mem(cpu) = local_memory_node(cpu_to_node(cpu));

Please make cpu_to_node() evaluate to a rvalue and use set_numa_mem()
to set node.  The above is a bit too easy to get wrong when archs
override the macro.

> +#ifdef CONFIG_HAVE_MEMORYLESS_NODES
> +int local_memory_node(int node_id);
> +#else
> +static inline int local_memory_node(int node_id) { return node_id; };
> +#endif

Hmmm... can there be local_memory_node() users when MEMORYLESS_NODES
is not enabled?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
