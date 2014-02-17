Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 474796B0031
	for <linux-mm@kvack.org>; Mon, 17 Feb 2014 01:52:50 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id y10so14466647pdj.4
        for <linux-mm@kvack.org>; Sun, 16 Feb 2014 22:52:49 -0800 (PST)
Received: from LGEAMRELO02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id yt9si13675120pab.236.2014.02.16.22.52.47
        for <linux-mm@kvack.org>;
        Sun, 16 Feb 2014 22:52:48 -0800 (PST)
Date: Mon, 17 Feb 2014 15:52:57 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC PATCH 2/3] topology: support node_numa_mem() for
 determining the fallback node
Message-ID: <20140217065257.GD3468@lge.com>
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
Cc: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Paul Mackerras <paulus@samba.org>, Anton Blanchard <anton@samba.org>, Matt Mackall <mpm@selenic.com>, linuxppc-dev@lists.ozlabs.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On Wed, Feb 12, 2014 at 04:16:11PM -0600, Christoph Lameter wrote:
> Here is another patch with some fixes. The additional logic is only
> compiled in if CONFIG_HAVE_MEMORYLESS_NODES is set.
> 
> Subject: slub: Memoryless node support
> 
> Support memoryless nodes by tracking which allocations are failing.

I still don't understand why this tracking is needed.
All we need for allcation targeted to memoryless node is to fallback proper
node, that it, numa_mem_id() node of targeted node. My previous patch
implements it and use proper fallback node on every allocation code path.
Why this tracking is needed? Please elaborate more on this.

> Allocations targeted to the nodes without memory fall back to the
> current available per cpu objects and if that is not available will
> create a new slab using the page allocator to fallback from the
> memoryless node to some other node.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>
> 
> @@ -1722,7 +1738,7 @@ static void *get_partial(struct kmem_cac
>  		struct kmem_cache_cpu *c)
>  {
>  	void *object;
> -	int searchnode = (node == NUMA_NO_NODE) ? numa_node_id() : node;
> +	int searchnode = (node == NUMA_NO_NODE) ? numa_mem_id() : node;
> 
>  	object = get_partial_node(s, get_node(s, searchnode), c, flags);
>  	if (object || node != NUMA_NO_NODE)

This isn't enough.
Consider that allcation targeted to memoryless node.
get_partial_node() always fails even if there are some partial slab on
memoryless node's neareast node.
We should fallback to some proper node in this case, since there is no slab
on memoryless node.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
