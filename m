Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id E34D86B0107
	for <linux-mm@kvack.org>; Mon, 24 Feb 2014 00:08:44 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa1so6036932pad.14
        for <linux-mm@kvack.org>; Sun, 23 Feb 2014 21:08:44 -0800 (PST)
Received: from LGEAMRELO02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id mo4si15363434pbc.21.2014.02.23.21.08.42
        for <linux-mm@kvack.org>;
        Sun, 23 Feb 2014 21:08:43 -0800 (PST)
Date: Mon, 24 Feb 2014 14:08:51 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC PATCH 2/3] topology: support node_numa_mem() for
 determining the fallback node
Message-ID: <20140224050851.GB14814@lge.com>
References: <CAAmzW4PXkdpNi5pZ=4BzdXNvqTEAhcuw-x0pWidqrxzdePxXxA@mail.gmail.com>
 <alpine.DEB.2.02.1402061248450.9567@chino.kir.corp.google.com>
 <20140207054819.GC28952@lge.com>
 <alpine.DEB.2.10.1402071150090.15168@nuc>
 <alpine.DEB.2.10.1402071245040.20246@nuc>
 <20140210191321.GD1558@linux.vnet.ibm.com>
 <20140211074159.GB27870@lge.com>
 <alpine.DEB.2.10.1402121612270.8183@nuc>
 <20140217065257.GD3468@lge.com>
 <alpine.DEB.2.10.1402181033480.28964@nuc>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1402181033480.28964@nuc>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Paul Mackerras <paulus@samba.org>, Anton Blanchard <anton@samba.org>, Matt Mackall <mpm@selenic.com>, linuxppc-dev@lists.ozlabs.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On Tue, Feb 18, 2014 at 10:38:01AM -0600, Christoph Lameter wrote:
> On Mon, 17 Feb 2014, Joonsoo Kim wrote:
> 
> > On Wed, Feb 12, 2014 at 04:16:11PM -0600, Christoph Lameter wrote:
> > > Here is another patch with some fixes. The additional logic is only
> > > compiled in if CONFIG_HAVE_MEMORYLESS_NODES is set.
> > >
> > > Subject: slub: Memoryless node support
> > >
> > > Support memoryless nodes by tracking which allocations are failing.
> >
> > I still don't understand why this tracking is needed.
> 
> Its an optimization to avoid calling the page allocator to figure out if
> there is memory available on a particular node.
> 
> > All we need for allcation targeted to memoryless node is to fallback proper
> > node, that it, numa_mem_id() node of targeted node. My previous patch
> > implements it and use proper fallback node on every allocation code path.
> > Why this tracking is needed? Please elaborate more on this.
> 
> Its too slow to do that on every alloc. One needs to be able to satisfy
> most allocations without switching percpu slabs for optimal performance.

I don't think that we need to switch percpu slabs on every alloc.
Allocation targeted to specific node is rare. And most of these allocations
may be targeted to either numa_node_id() or numa_mem_id(). My patch considers
these cases, so most of allocations are processed by percpu slabs. There is
no suboptimal performance.

> 
> > > Allocations targeted to the nodes without memory fall back to the
> > > current available per cpu objects and if that is not available will
> > > create a new slab using the page allocator to fallback from the
> > > memoryless node to some other node.
> 
> And what about the next alloc? Assuem there are N allocs from a memoryless
> node this means we push back the partial slab on each alloc and then fall
> back?
> 
> > >  {
> > >  	void *object;
> > > -	int searchnode = (node == NUMA_NO_NODE) ? numa_node_id() : node;
> > > +	int searchnode = (node == NUMA_NO_NODE) ? numa_mem_id() : node;
> > >
> > >  	object = get_partial_node(s, get_node(s, searchnode), c, flags);
> > >  	if (object || node != NUMA_NO_NODE)
> >
> > This isn't enough.
> > Consider that allcation targeted to memoryless node.
> 
> It will not common get there because of the tracking. Instead a per cpu
> object will be used.
> > get_partial_node() always fails even if there are some partial slab on
> > memoryless node's neareast node.
> 
> Correct and that leads to a page allocator action whereupon the node will
> be marked as empty.

Why do we need to request to a page allocator if there is partial slab?
Checking whether node is memoryless or not is really easy, so we don't need
to skip this. To skip this is suboptimal solution.

> > We should fallback to some proper node in this case, since there is no slab
> > on memoryless node.
> 
> NUMA is about optimization of memory allocations. It is often *not* about
> correctness but heuristics are used in many cases. F.e. see the zone
> reclaim logic, zone reclaim mode, fallback scenarios in the page allocator
> etc etc.

Okay. But, 'do our best' is preferable to me.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
