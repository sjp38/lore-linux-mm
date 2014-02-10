Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id 1DF136B0037
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 14:13:44 -0500 (EST)
Received: by mail-ob0-f178.google.com with SMTP id wn1so7675439obc.37
        for <linux-mm@kvack.org>; Mon, 10 Feb 2014 11:13:43 -0800 (PST)
Received: from e7.ny.us.ibm.com (e7.ny.us.ibm.com. [32.97.182.137])
        by mx.google.com with ESMTPS id ws6si8319631oeb.149.2014.02.10.11.13.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 10 Feb 2014 11:13:42 -0800 (PST)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Mon, 10 Feb 2014 14:13:41 -0500
Received: from b01cxnp22035.gho.pok.ibm.com (b01cxnp22035.gho.pok.ibm.com [9.57.198.25])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 5456F38C8047
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 14:13:39 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by b01cxnp22035.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s1AJDdVZ6488532
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 19:13:39 GMT
Received: from d01av04.pok.ibm.com (localhost [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s1AJDcbp011008
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 14:13:39 -0500
Date: Mon, 10 Feb 2014 11:13:21 -0800
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH 2/3] topology: support node_numa_mem() for
 determining the fallback node
Message-ID: <20140210191321.GD1558@linux.vnet.ibm.com>
References: <20140206020757.GC5433@linux.vnet.ibm.com>
 <1391674026-20092-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1391674026-20092-2-git-send-email-iamjoonsoo.kim@lge.com>
 <alpine.DEB.2.02.1402060041040.21148@chino.kir.corp.google.com>
 <CAAmzW4PXkdpNi5pZ=4BzdXNvqTEAhcuw-x0pWidqrxzdePxXxA@mail.gmail.com>
 <alpine.DEB.2.02.1402061248450.9567@chino.kir.corp.google.com>
 <20140207054819.GC28952@lge.com>
 <alpine.DEB.2.10.1402071150090.15168@nuc>
 <alpine.DEB.2.10.1402071245040.20246@nuc>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1402071245040.20246@nuc>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Paul Mackerras <paulus@samba.org>, Anton Blanchard <anton@samba.org>, Matt Mackall <mpm@selenic.com>, linuxppc-dev@lists.ozlabs.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Hi Christoph,

On 07.02.2014 [12:51:07 -0600], Christoph Lameter wrote:
> Here is a draft of a patch to make this work with memoryless nodes.
> 
> The first thing is that we modify node_match to also match if we hit an
> empty node. In that case we simply take the current slab if its there.
> 
> If there is no current slab then a regular allocation occurs with the
> memoryless node. The page allocator will fallback to a possible node and
> that will become the current slab. Next alloc from a memoryless node
> will then use that slab.
> 
> For that we also add some tracking of allocations on nodes that were not
> satisfied using the empty_node[] array. A successful alloc on a node
> clears that flag.
> 
> I would rather avoid the empty_node[] array since its global and there may
> be thread specific allocation restrictions but it would be expensive to do
> an allocation attempt via the page allocator to make sure that there is
> really no page available from the page allocator.

With this patch on our test system (I pulled out the numa_mem_id()
change, since you Acked Joonsoo's already), on top of 3.13.0 + my
kthread locality change + CONFIG_HAVE_MEMORYLESS_NODES + Joonsoo's RFC
patch 1):

MemTotal:        8264704 kB
MemFree:         5924608 kB
...
Slab:            1402496 kB
SReclaimable:     102848 kB
SUnreclaim:      1299648 kB

And Anton's slabusage reports:

slab                                   mem     objs    slabs
                                      used   active   active
------------------------------------------------------------
kmalloc-16384                       207 MB   98.60%  100.00%
task_struct                         134 MB   97.82%  100.00%
kmalloc-8192                        117 MB  100.00%  100.00%
pgtable-2^12                        111 MB  100.00%  100.00%
pgtable-2^10                        104 MB  100.00%  100.00%

For comparison, Anton's patch applied at the same point in the series:

meminfo:

MemTotal:        8264704 kB
MemFree:         4150464 kB
...
Slab:            1590336 kB
SReclaimable:     208768 kB
SUnreclaim:      1381568 kB

slabusage:

slab                                   mem     objs    slabs
                                      used   active   active
------------------------------------------------------------
kmalloc-16384                       227 MB   98.63%  100.00%
kmalloc-8192                        130 MB  100.00%  100.00%
task_struct                         129 MB   97.73%  100.00%
pgtable-2^12                        112 MB  100.00%  100.00%
pgtable-2^10                        106 MB  100.00%  100.00%


Consider this patch:

Acked-by: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Tested-by: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>

I was thinking about your concerns about empty_node[]. Would it make
sense to use a helper function, rather than direct access to
direct_node, such as:

	bool is_node_empty(int nid)

	void set_node_empty(int nid, bool empty)

which we stub out if !HAVE_MEMORYLESS_NODES to return false and noop
respectively?

That way only architectures that have memoryless nodes pay the penalty
of the array allocation?

Thanks,
Nish

> Index: linux/mm/slub.c
> ===================================================================
> --- linux.orig/mm/slub.c	2014-02-03 13:19:22.896853227 -0600
> +++ linux/mm/slub.c	2014-02-07 12:44:49.311494806 -0600
> @@ -132,6 +132,8 @@ static inline bool kmem_cache_has_cpu_pa
>  #endif
>  }
> 
> +static int empty_node[MAX_NUMNODES];
> +
>  /*
>   * Issues still to be resolved:
>   *
> @@ -1405,16 +1407,22 @@ static struct page *new_slab(struct kmem
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
> +		if (node != NUMA_NO_NODE)
> +			empty_node[node] = 1;
>  		goto out;
> +	}
> 
>  	order = compound_order(page);
> -	inc_slabs_node(s, page_to_nid(page), page->objects);
> +	alloc_node = page_to_nid(page);
> +	empty_node[alloc_node] = 0;
> +	inc_slabs_node(s, alloc_node, page->objects);
>  	memcg_bind_pages(s, order);
>  	page->slab_cache = s;
>  	__SetPageSlab(page);
> @@ -1712,7 +1720,7 @@ static void *get_partial(struct kmem_cac
>  		struct kmem_cache_cpu *c)
>  {
>  	void *object;
> -	int searchnode = (node == NUMA_NO_NODE) ? numa_node_id() : node;
> +	int searchnode = (node == NUMA_NO_NODE) ? numa_mem_id() : node;
> 
>  	object = get_partial_node(s, get_node(s, searchnode), c, flags);
>  	if (object || node != NUMA_NO_NODE)
> @@ -2107,8 +2115,25 @@ static void flush_all(struct kmem_cache
>  static inline int node_match(struct page *page, int node)
>  {
>  #ifdef CONFIG_NUMA
> -	if (!page || (node != NUMA_NO_NODE && page_to_nid(page) != node))
> +	int page_node;
> +
> +	/* No data means no match */
> +	if (!page)
>  		return 0;
> +
> +	/* Node does not matter. Therefore anything is a match */
> +	if (node == NUMA_NO_NODE)
> +		return 1;
> +
> +	/* Did we hit the requested node ? */
> +	page_node = page_to_nid(page);
> +	if (page_node == node)
> +		return 1;
> +
> +	/* If the node has available data then we can use it. Mismatch */
> +	return !empty_node[page_node];
> +
> +	/* Target node empty so just take anything */
>  #endif
>  	return 1;
>  }
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
