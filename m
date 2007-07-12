Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l6CIXSpP029207
	for <linux-mm@kvack.org>; Thu, 12 Jul 2007 14:33:28 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l6CIXPNX558926
	for <linux-mm@kvack.org>; Thu, 12 Jul 2007 14:33:28 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6CIXO5A029674
	for <linux-mm@kvack.org>; Thu, 12 Jul 2007 14:33:24 -0400
Date: Thu, 12 Jul 2007 11:33:23 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 07/12] Memoryless nodes: SLUB support
Message-ID: <20070712183323.GD10067@us.ibm.com>
References: <20070711182219.234782227@sgi.com> <20070711182251.433134748@sgi.com> <20070711170736.f6c304d3.akpm@linux-foundation.org> <Pine.LNX.4.64.0707111835130.3806@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0707111835130.3806@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, kxr@sgi.com, linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On 11.07.2007 [18:42:52 -0700], Christoph Lameter wrote:
> On Wed, 11 Jul 2007, Andrew Morton wrote:
> 
> > This is as far as I got when a reject storm hit.
> > 
> > > -	for_each_online_node(node)
> > > +	for_each_node_state(node, N_MEMORY)
> > >  		__kmem_cache_shrink(s, get_node(s, node), scratch);
> > 
> > I can find no sign of any __kmem_cache_shrink's anywhere.
> 
> Yup I expected slab defrag to be merged first before you get to this.
> 
> > Let's park all this until post-merge-window please.  Generally, now
> > is not a good time for me to be merging 2.6.24 stuff.
> 
> For SGI this is not important at all since we have no memoryless
> nodes. 

Right the original problem that brought this up again was a power
machine with two empty nodes displaying incorrect interleaving of
hugepages.

> However, these fixes are important for other NUMA users. I think this
> needs to go into 2.6.23 for correctnesses sake. We may have some fun
> with it since the fixed up behavior of GFP_THISNODE may expose
> additional problems in how subsystems handle memoryless nodes (and I
> do not have such a system). There are also patches against hugetlb
> that use this functionality here.

I was waiting for this series to stabilize a bit before rebasing my
patch to fix the hugetlb interleaving with memoryless nodes. I also have
two patches on top of that which add a per-node sysfs nr_hugepages
attribute and also depend on the patch to make THISNODE allocations
stay on the current node from this series.

> Necessary for asymmetric NUMA configs to work right.
> 
> 
> Here is the patch rediffed before slab defrag.
> 
> 
> Memoryless nodes: SLUB support
> 
> Simply switch all for_each_online_node to for_each_memory_node. That way
> SLUB only operates on nodes with memory. Any allocation attempt on a
> memoryless node will fall whereupon SLUB will fetch memory from a nearby
> node (depending on how memory policies and cpuset describe fallback).

This description is out of date. There is no for_each_memory_node() any
more, I think you meant for_each_node_state().

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
