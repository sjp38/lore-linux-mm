Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id C113B6B0035
	for <linux-mm@kvack.org>; Thu,  6 Feb 2014 03:52:52 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id v10so1432381pde.41
        for <linux-mm@kvack.org>; Thu, 06 Feb 2014 00:52:52 -0800 (PST)
Received: from mail-pd0-x22c.google.com (mail-pd0-x22c.google.com [2607:f8b0:400e:c02::22c])
        by mx.google.com with ESMTPS id vb2si320221pbc.67.2014.02.06.00.52.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 06 Feb 2014 00:52:51 -0800 (PST)
Received: by mail-pd0-f172.google.com with SMTP id p10so1439677pdj.31
        for <linux-mm@kvack.org>; Thu, 06 Feb 2014 00:52:50 -0800 (PST)
Date: Thu, 6 Feb 2014 00:52:35 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC PATCH 2/3] topology: support node_numa_mem() for determining
 the fallback node
In-Reply-To: <1391674026-20092-2-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.02.1402060041040.21148@chino.kir.corp.google.com>
References: <20140206020757.GC5433@linux.vnet.ibm.com> <1391674026-20092-1-git-send-email-iamjoonsoo.kim@lge.com> <1391674026-20092-2-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, penberg@kernel.org, linux-mm@kvack.org, paulus@samba.org, Anton Blanchard <anton@samba.org>, mpm@selenic.com, Christoph Lameter <cl@linux.com>, linuxppc-dev@lists.ozlabs.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On Thu, 6 Feb 2014, Joonsoo Kim wrote:

> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 

I may be misunderstanding this patch and there's no help because there's 
no changelog.

> diff --git a/include/linux/topology.h b/include/linux/topology.h
> index 12ae6ce..a6d5438 100644
> --- a/include/linux/topology.h
> +++ b/include/linux/topology.h
> @@ -233,11 +233,20 @@ static inline int numa_node_id(void)
>   * Use the accessor functions set_numa_mem(), numa_mem_id() and cpu_to_mem().
>   */
>  DECLARE_PER_CPU(int, _numa_mem_);
> +int _node_numa_mem_[MAX_NUMNODES];
>  
>  #ifndef set_numa_mem
>  static inline void set_numa_mem(int node)
>  {
>  	this_cpu_write(_numa_mem_, node);
> +	_node_numa_mem_[numa_node_id()] = node;
> +}
> +#endif
> +
> +#ifndef get_numa_mem
> +static inline int get_numa_mem(int node)
> +{
> +	return _node_numa_mem_[node];
>  }
>  #endif
>  
> @@ -260,6 +269,7 @@ static inline int cpu_to_mem(int cpu)
>  static inline void set_cpu_numa_mem(int cpu, int node)
>  {
>  	per_cpu(_numa_mem_, cpu) = node;
> +	_node_numa_mem_[numa_node_id()] = node;

The intention seems to be that _node_numa_mem_[X] for a node X will return 
a node Y with memory that has the nearest distance?  In other words, 
caching the value returned by local_memory_node(X)?

That doesn't seem to be what it's doing since numa_node_id() is the node 
of the cpu that current is running on so this ends up getting initialized 
to whatever local_memory_node(cpu_to_node(cpu)) is for the last bit set in 
cpu_possible_mask.

>  }
>  #endif
>  
> @@ -273,6 +283,13 @@ static inline int numa_mem_id(void)
>  }
>  #endif
>  
> +#ifndef get_numa_mem
> +static inline int get_numa_mem(int node)
> +{
> +	return node;
> +}
> +#endif
> +
>  #ifndef cpu_to_mem
>  static inline int cpu_to_mem(int cpu)
>  {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
