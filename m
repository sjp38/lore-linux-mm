Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id 3B5A46B0036
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 11:38:05 -0500 (EST)
Received: by mail-qg0-f48.google.com with SMTP id a108so7324204qge.7
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 08:38:05 -0800 (PST)
Received: from qmta12.emeryville.ca.mail.comcast.net (qmta12.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:227])
        by mx.google.com with ESMTP id fy9si10602881qab.21.2014.02.18.08.38.04
        for <linux-mm@kvack.org>;
        Tue, 18 Feb 2014 08:38:04 -0800 (PST)
Date: Tue, 18 Feb 2014 10:38:01 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC PATCH 2/3] topology: support node_numa_mem() for determining
 the fallback node
In-Reply-To: <20140217065257.GD3468@lge.com>
Message-ID: <alpine.DEB.2.10.1402181033480.28964@nuc>
References: <1391674026-20092-2-git-send-email-iamjoonsoo.kim@lge.com> <alpine.DEB.2.02.1402060041040.21148@chino.kir.corp.google.com> <CAAmzW4PXkdpNi5pZ=4BzdXNvqTEAhcuw-x0pWidqrxzdePxXxA@mail.gmail.com> <alpine.DEB.2.02.1402061248450.9567@chino.kir.corp.google.com>
 <20140207054819.GC28952@lge.com> <alpine.DEB.2.10.1402071150090.15168@nuc> <alpine.DEB.2.10.1402071245040.20246@nuc> <20140210191321.GD1558@linux.vnet.ibm.com> <20140211074159.GB27870@lge.com> <alpine.DEB.2.10.1402121612270.8183@nuc>
 <20140217065257.GD3468@lge.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Paul Mackerras <paulus@samba.org>, Anton Blanchard <anton@samba.org>, Matt Mackall <mpm@selenic.com>, linuxppc-dev@lists.ozlabs.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On Mon, 17 Feb 2014, Joonsoo Kim wrote:

> On Wed, Feb 12, 2014 at 04:16:11PM -0600, Christoph Lameter wrote:
> > Here is another patch with some fixes. The additional logic is only
> > compiled in if CONFIG_HAVE_MEMORYLESS_NODES is set.
> >
> > Subject: slub: Memoryless node support
> >
> > Support memoryless nodes by tracking which allocations are failing.
>
> I still don't understand why this tracking is needed.

Its an optimization to avoid calling the page allocator to figure out if
there is memory available on a particular node.

> All we need for allcation targeted to memoryless node is to fallback proper
> node, that it, numa_mem_id() node of targeted node. My previous patch
> implements it and use proper fallback node on every allocation code path.
> Why this tracking is needed? Please elaborate more on this.

Its too slow to do that on every alloc. One needs to be able to satisfy
most allocations without switching percpu slabs for optimal performance.

> > Allocations targeted to the nodes without memory fall back to the
> > current available per cpu objects and if that is not available will
> > create a new slab using the page allocator to fallback from the
> > memoryless node to some other node.

And what about the next alloc? Assuem there are N allocs from a memoryless
node this means we push back the partial slab on each alloc and then fall
back?

> >  {
> >  	void *object;
> > -	int searchnode = (node == NUMA_NO_NODE) ? numa_node_id() : node;
> > +	int searchnode = (node == NUMA_NO_NODE) ? numa_mem_id() : node;
> >
> >  	object = get_partial_node(s, get_node(s, searchnode), c, flags);
> >  	if (object || node != NUMA_NO_NODE)
>
> This isn't enough.
> Consider that allcation targeted to memoryless node.

It will not common get there because of the tracking. Instead a per cpu
object will be used.

> get_partial_node() always fails even if there are some partial slab on
> memoryless node's neareast node.

Correct and that leads to a page allocator action whereupon the node will
be marked as empty.

> We should fallback to some proper node in this case, since there is no slab
> on memoryless node.

NUMA is about optimization of memory allocations. It is often *not* about
correctness but heuristics are used in many cases. F.e. see the zone
reclaim logic, zone reclaim mode, fallback scenarios in the page allocator
etc etc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
