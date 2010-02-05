Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 82D3F6B0047
	for <linux-mm@kvack.org>; Fri,  5 Feb 2010 16:29:16 -0500 (EST)
Received: from kpbe15.cbf.corp.google.com (kpbe15.cbf.corp.google.com [172.25.105.79])
	by smtp-out.google.com with ESMTP id o15LTDmf002206
	for <linux-mm@kvack.org>; Fri, 5 Feb 2010 13:29:13 -0800
Received: from pxi5 (pxi5.prod.google.com [10.243.27.5])
	by kpbe15.cbf.corp.google.com with ESMTP id o15LSR7t014116
	for <linux-mm@kvack.org>; Fri, 5 Feb 2010 13:29:12 -0800
Received: by pxi5 with SMTP id 5so4791384pxi.12
        for <linux-mm@kvack.org>; Fri, 05 Feb 2010 13:29:09 -0800 (PST)
Date: Fri, 5 Feb 2010 13:29:07 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] [3/4] SLAB: Separate node initialization into separate
 function
In-Reply-To: <20100203213914.D8654B1620@basil.firstfloor.org>
Message-ID: <alpine.DEB.2.00.1002051324370.2376@chino.kir.corp.google.com>
References: <201002031039.710275915@firstfloor.org> <20100203213914.D8654B1620@basil.firstfloor.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: submit@firstfloor.org, linux-kernel@vger.kernel.org, haicheng.li@intel.com, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 3 Feb 2010, Andi Kleen wrote:

> 
> No functional changes.
> 
> Needed for next patch.
> 
> Signed-off-by: Andi Kleen <ak@linux.intel.com>
> 
> ---
>  mm/slab.c |   34 +++++++++++++++++++++-------------
>  1 file changed, 21 insertions(+), 13 deletions(-)
> 
> Index: linux-2.6.33-rc3-ak/mm/slab.c
> ===================================================================
> --- linux-2.6.33-rc3-ak.orig/mm/slab.c
> +++ linux-2.6.33-rc3-ak/mm/slab.c
> @@ -1171,19 +1171,9 @@ free_array_cache:
>  	}
>  }
>  
> -static int __cpuinit cpuup_prepare(long cpu)
> +static int slab_node_prepare(int node)
>  {
>  	struct kmem_cache *cachep;
> -	struct kmem_list3 *l3 = NULL;
> -	int node = cpu_to_node(cpu);
> -	const int memsize = sizeof(struct kmem_list3);
> -
> -	/*
> -	 * We need to do this right in the beginning since
> -	 * alloc_arraycache's are going to use this list.
> -	 * kmalloc_node allows us to add the slab to the right
> -	 * kmem_list3 and not this cpu's kmem_list3
> -	 */
>  
>  	list_for_each_entry(cachep, &cache_chain, next) {
>  		/*

As Christoph mentioned, this patch is out of order with the previous one 
in the series; slab_node_prepare() is called in that previous patch by a 
memory hotplug callback without holding cache_chain_mutex (it's taken by 
the cpu hotplug callback prior to calling cpuup_prepare() currently).  So 
slab_node_prepare() should note that we require the mutex and the memory 
hotplug callback should take it in the previous patch.

> @@ -1192,9 +1182,10 @@ static int __cpuinit cpuup_prepare(long
>  		 * node has not already allocated this
>  		 */
>  		if (!cachep->nodelists[node]) {
> -			l3 = kmalloc_node(memsize, GFP_KERNEL, node);
> +			struct kmem_list3 *l3;
> +			l3 = kmalloc_node(sizeof(struct kmem_list3), GFP_KERNEL, node);
>  			if (!l3)
> -				goto bad;
> +				return -1;
>  			kmem_list3_init(l3);
>  			l3->next_reap = jiffies + REAPTIMEOUT_LIST3 +
>  			    ((unsigned long)cachep) % REAPTIMEOUT_LIST3;
> @@ -1213,6 +1204,23 @@ static int __cpuinit cpuup_prepare(long
>  			cachep->batchcount + cachep->num;
>  		spin_unlock_irq(&cachep->nodelists[node]->list_lock);
>  	}
> +	return 0;
> +}
> +
> +static int __cpuinit cpuup_prepare(long cpu)
> +{
> +	struct kmem_cache *cachep;
> +	struct kmem_list3 *l3 = NULL;
> +	int node = cpu_to_node(cpu);
> +
> +	/*
> +	 * We need to do this right in the beginning since
> +	 * alloc_arraycache's are going to use this list.
> +	 * kmalloc_node allows us to add the slab to the right
> +	 * kmem_list3 and not this cpu's kmem_list3
> +	 */
> +	if (slab_node_prepare(node) < 0)
> +		goto bad;
>  
>  	/*
>  	 * Now we can go ahead with allocating the shared arrays and

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
