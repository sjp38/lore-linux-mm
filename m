Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 05D726B0031
	for <linux-mm@kvack.org>; Sun,  9 Feb 2014 20:29:11 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id kl14so5515133pab.29
        for <linux-mm@kvack.org>; Sun, 09 Feb 2014 17:29:11 -0800 (PST)
Received: from LGEMRELSE1Q.lge.com (LGEMRELSE1Q.lge.com. [156.147.1.111])
        by mx.google.com with ESMTP id bf5si13339130pad.233.2014.02.09.17.29.10
        for <linux-mm@kvack.org>;
        Sun, 09 Feb 2014 17:29:11 -0800 (PST)
Date: Mon, 10 Feb 2014 10:29:18 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC PATCH 2/3] topology: support node_numa_mem() for
 determining the fallback node
Message-ID: <20140210012918.GD12574@lge.com>
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
Cc: David Rientjes <rientjes@google.com>, Nishanth Aravamudan <nacc@linux.vnet.ibm.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Paul Mackerras <paulus@samba.org>, Anton Blanchard <anton@samba.org>, Matt Mackall <mpm@selenic.com>, linuxppc-dev@lists.ozlabs.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On Fri, Feb 07, 2014 at 12:51:07PM -0600, Christoph Lameter wrote:
> Here is a draft of a patch to make this work with memoryless nodes.
> 
> The first thing is that we modify node_match to also match if we hit an
> empty node. In that case we simply take the current slab if its there.

Why not inspecting whether we can get the page on the best node such as
numa_mem_id() node?

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
> 
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

empty_node cannot be set on memoryless node, since page allocation would
succeed on different node.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
