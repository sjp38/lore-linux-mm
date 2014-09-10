Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id CD6D96B0037
	for <linux-mm@kvack.org>; Tue,  9 Sep 2014 20:11:18 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id hz1so9131667pad.21
        for <linux-mm@kvack.org>; Tue, 09 Sep 2014 17:11:18 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ro4si1427034pbc.109.2014.09.09.17.11.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Sep 2014 17:11:17 -0700 (PDT)
Date: Tue, 9 Sep 2014 17:11:15 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3] topology: add support for node_to_mem_node() to
 determine the fallback node
Message-Id: <20140909171115.75c7702c37dfb23b9e053636@linux-foundation.org>
In-Reply-To: <20140909190326.GD22906@linux.vnet.ibm.com>
References: <20140909190154.GC22906@linux.vnet.ibm.com>
	<20140909190326.GD22906@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Paul Mackerras <paulus@samba.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Anton Blanchard <anton@samba.org>, Matt Mackall <mpm@selenic.com>, Christoph Lameter <cl@linux.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linuxppc-dev@lists.ozlabs.org

On Tue, 9 Sep 2014 12:03:27 -0700 Nishanth Aravamudan <nacc@linux.vnet.ibm.com> wrote:

> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> We need to determine the fallback node in slub allocator if the
> allocation target node is memoryless node. Without it, the SLUB wrongly
> select the node which has no memory and can't use a partial slab,
> because of node mismatch. Introduced function, node_to_mem_node(X), will
> return a node Y with memory that has the nearest distance. If X is
> memoryless node, it will return nearest distance node, but, if X is
> normal node, it will return itself.
> 
> We will use this function in following patch to determine the fallback
> node.
> 
> ...
>
> --- a/include/linux/topology.h
> +++ b/include/linux/topology.h
> @@ -119,11 +119,20 @@ static inline int numa_node_id(void)
>   * Use the accessor functions set_numa_mem(), numa_mem_id() and cpu_to_mem().

This comment could be updated.

>   */
>  DECLARE_PER_CPU(int, _numa_mem_);
> +extern int _node_numa_mem_[MAX_NUMNODES];
>  
>  #ifndef set_numa_mem
>  static inline void set_numa_mem(int node)
>  {
>  	this_cpu_write(_numa_mem_, node);
> +	_node_numa_mem_[numa_node_id()] = node;
> +}
> +#endif
> +
> +#ifndef node_to_mem_node
> +static inline int node_to_mem_node(int node)
> +{
> +	return _node_numa_mem_[node];
>  }

A wee bit of documentation wouldn't hurt.

How does node_to_mem_node(numa_node_id()) differ from numa_mem_id()? 
If I'm reading things correctly, they should both always return the
same thing.  If so, do we need both?

Will node_to_mem_node() ever actually be called with a node !=
numa_node_id()?


>  #endif
>  
> @@ -146,6 +155,7 @@ static inline int cpu_to_mem(int cpu)
>  static inline void set_cpu_numa_mem(int cpu, int node)
>  {
>  	per_cpu(_numa_mem_, cpu) = node;
> +	_node_numa_mem_[cpu_to_node(cpu)] = node;
>  }
>  #endif
>  
> @@ -159,6 +169,13 @@ static inline int numa_mem_id(void)
>  }
>  #endif
>  
> +#ifndef node_to_mem_node
> +static inline int node_to_mem_node(int node)
> +{
> +	return node;
> +}
> +#endif
> +
>  #ifndef cpu_to_mem
>  static inline int cpu_to_mem(int cpu)
>  {
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 18cee0d4c8a2..0883c42936d4 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -85,6 +85,7 @@ EXPORT_PER_CPU_SYMBOL(numa_node);
>   */
>  DEFINE_PER_CPU(int, _numa_mem_);		/* Kernel "local memory" node */
>  EXPORT_PER_CPU_SYMBOL(_numa_mem_);
> +int _node_numa_mem_[MAX_NUMNODES];

How does this get updated as CPUs, memory and nodes are hot-added and
removed?


>  #endif
>  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
