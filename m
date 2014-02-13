Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f46.google.com (mail-qa0-f46.google.com [209.85.216.46])
	by kanga.kvack.org (Postfix) with ESMTP id 75DFF6B0035
	for <linux-mm@kvack.org>; Wed, 12 Feb 2014 22:54:21 -0500 (EST)
Received: by mail-qa0-f46.google.com with SMTP id k15so2073223qaq.33
        for <linux-mm@kvack.org>; Wed, 12 Feb 2014 19:54:21 -0800 (PST)
Received: from e36.co.us.ibm.com (e36.co.us.ibm.com. [32.97.110.154])
        by mx.google.com with ESMTPS id a51si304321qge.110.2014.02.12.19.54.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 12 Feb 2014 19:54:20 -0800 (PST)
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Wed, 12 Feb 2014 20:54:19 -0700
Received: from b03cxnp08027.gho.boulder.ibm.com (b03cxnp08027.gho.boulder.ibm.com [9.17.130.19])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 9087F3E40045
	for <linux-mm@kvack.org>; Wed, 12 Feb 2014 20:54:17 -0700 (MST)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by b03cxnp08027.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s1D3rpto7995706
	for <linux-mm@kvack.org>; Thu, 13 Feb 2014 04:53:56 +0100
Received: from d03av03.boulder.ibm.com (localhost [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s1D3rvmV000772
	for <linux-mm@kvack.org>; Wed, 12 Feb 2014 20:53:57 -0700
Date: Wed, 12 Feb 2014 19:53:42 -0800
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH 2/3] topology: support node_numa_mem() for
 determining the fallback node
Message-ID: <20140213035342.GA32205@linux.vnet.ibm.com>
References: <1391674026-20092-2-git-send-email-iamjoonsoo.kim@lge.com>
 <alpine.DEB.2.02.1402060041040.21148@chino.kir.corp.google.com>
 <CAAmzW4PXkdpNi5pZ=4BzdXNvqTEAhcuw-x0pWidqrxzdePxXxA@mail.gmail.com>
 <alpine.DEB.2.02.1402061248450.9567@chino.kir.corp.google.com>
 <20140207054819.GC28952@lge.com>
 <alpine.DEB.2.10.1402071150090.15168@nuc>
 <alpine.DEB.2.10.1402071245040.20246@nuc>
 <20140210191321.GD1558@linux.vnet.ibm.com>
 <20140211074159.GB27870@lge.com>
 <alpine.DEB.2.10.1402121612270.8183@nuc>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1402121612270.8183@nuc>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Paul Mackerras <paulus@samba.org>, Anton Blanchard <anton@samba.org>, Matt Mackall <mpm@selenic.com>, linuxppc-dev@lists.ozlabs.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On 12.02.2014 [16:16:11 -0600], Christoph Lameter wrote:
> Here is another patch with some fixes. The additional logic is only
> compiled in if CONFIG_HAVE_MEMORYLESS_NODES is set.
> 
> Subject: slub: Memoryless node support
> 
> Support memoryless nodes by tracking which allocations are failing.
> Allocations targeted to the nodes without memory fall back to the
> current available per cpu objects and if that is not available will
> create a new slab using the page allocator to fallback from the
> memoryless node to some other node.

I'll try and retest this once the LPAR in question comes free. Hopefully
in the next day or two.

Thanks,
Nish

> Signed-off-by: Christoph Lameter <cl@linux.com>
> 
> Index: linux/mm/slub.c
> ===================================================================
> --- linux.orig/mm/slub.c	2014-02-12 16:07:48.957869570 -0600
> +++ linux/mm/slub.c	2014-02-12 16:09:22.198928260 -0600
> @@ -134,6 +134,10 @@ static inline bool kmem_cache_has_cpu_pa
>  #endif
>  }
> 
> +#ifdef CONFIG_HAVE_MEMORYLESS_NODES
> +static nodemask_t empty_nodes;
> +#endif
> +
>  /*
>   * Issues still to be resolved:
>   *
> @@ -1405,16 +1409,28 @@ static struct page *new_slab(struct kmem
>  	void *last;
>  	void *p;
>  	int order;
> +	int alloc_node;
> 
>  	BUG_ON(flags & GFP_SLAB_BUG_MASK);
> 
>  	page = allocate_slab(s,
>  		flags & (GFP_RECLAIM_MASK | GFP_CONSTRAINT_MASK), node);
> -	if (!page)
> +	if (!page) {
> +#ifdef CONFIG_HAVE_MEMORYLESS_NODES
> +		if (node != NUMA_NO_NODE)
> +			node_set(node, empty_nodes);
> +#endif
>  		goto out;
> +	}
> 
>  	order = compound_order(page);
> -	inc_slabs_node(s, page_to_nid(page), page->objects);
> +	alloc_node = page_to_nid(page);
> +#ifdef CONFIG_HAVE_MEMORYLESS_NODES
> +	node_clear(alloc_node, empty_nodes);
> +	if (node != NUMA_NO_NODE && alloc_node != node)
> +		node_set(node, empty_nodes);
> +#endif
> +	inc_slabs_node(s, alloc_node, page->objects);
>  	memcg_bind_pages(s, order);
>  	page->slab_cache = s;
>  	__SetPageSlab(page);
> @@ -1722,7 +1738,7 @@ static void *get_partial(struct kmem_cac
>  		struct kmem_cache_cpu *c)
>  {
>  	void *object;
> -	int searchnode = (node == NUMA_NO_NODE) ? numa_node_id() : node;
> +	int searchnode = (node == NUMA_NO_NODE) ? numa_mem_id() : node;
> 
>  	object = get_partial_node(s, get_node(s, searchnode), c, flags);
>  	if (object || node != NUMA_NO_NODE)
> @@ -2117,8 +2133,19 @@ static void flush_all(struct kmem_cache
>  static inline int node_match(struct page *page, int node)
>  {
>  #ifdef CONFIG_NUMA
> -	if (!page || (node != NUMA_NO_NODE && page_to_nid(page) != node))
> +	int page_node = page_to_nid(page);
> +
> +	if (!page)
>  		return 0;
> +
> +	if (node != NUMA_NO_NODE) {
> +#ifdef CONFIG_HAVE_MEMORYLESS_NODES
> +		if (node_isset(node, empty_nodes))
> +			return 1;
> +#endif
> +		if (page_node != node)
> +			return 0;
> +	}
>  #endif
>  	return 1;
>  }
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
