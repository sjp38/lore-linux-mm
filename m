Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id 4BE086B0036
	for <linux-mm@kvack.org>; Tue,  9 Sep 2014 20:47:33 -0400 (EDT)
Received: by mail-qg0-f53.google.com with SMTP id q108so1120090qgd.40
        for <linux-mm@kvack.org>; Tue, 09 Sep 2014 17:47:33 -0700 (PDT)
Received: from e38.co.us.ibm.com (e38.co.us.ibm.com. [32.97.110.159])
        by mx.google.com with ESMTPS id b10si17205461qat.61.2014.09.09.17.47.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 09 Sep 2014 17:47:32 -0700 (PDT)
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Tue, 9 Sep 2014 18:47:31 -0600
Received: from b03cxnp08026.gho.boulder.ibm.com (b03cxnp08026.gho.boulder.ibm.com [9.17.130.18])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 9F3EB3E4003D
	for <linux-mm@kvack.org>; Tue,  9 Sep 2014 18:47:30 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by b03cxnp08026.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id s8A0lUI050200578
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 02:47:30 +0200
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s8A0lT5U021676
	for <linux-mm@kvack.org>; Tue, 9 Sep 2014 18:47:30 -0600
Date: Tue, 9 Sep 2014 17:47:23 -0700
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: [PATCH v3] topology: add support for node_to_mem_node() to
 determine the fallback node
Message-ID: <20140910004723.GH22906@linux.vnet.ibm.com>
References: <20140909190154.GC22906@linux.vnet.ibm.com>
 <20140909190326.GD22906@linux.vnet.ibm.com>
 <20140909171115.75c7702c37dfb23b9e053636@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140909171115.75c7702c37dfb23b9e053636@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Paul Mackerras <paulus@samba.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Anton Blanchard <anton@samba.org>, Matt Mackall <mpm@selenic.com>, Christoph Lameter <cl@linux.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linuxppc-dev@lists.ozlabs.org

On 09.09.2014 [17:11:15 -0700], Andrew Morton wrote:
> On Tue, 9 Sep 2014 12:03:27 -0700 Nishanth Aravamudan <nacc@linux.vnet.ibm.com> wrote:
> 
> > From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > 
> > We need to determine the fallback node in slub allocator if the
> > allocation target node is memoryless node. Without it, the SLUB wrongly
> > select the node which has no memory and can't use a partial slab,
> > because of node mismatch. Introduced function, node_to_mem_node(X), will
> > return a node Y with memory that has the nearest distance. If X is
> > memoryless node, it will return nearest distance node, but, if X is
> > normal node, it will return itself.
> > 
> > We will use this function in following patch to determine the fallback
> > node.
> > 
> > ...
> >
> > --- a/include/linux/topology.h
> > +++ b/include/linux/topology.h
> > @@ -119,11 +119,20 @@ static inline int numa_node_id(void)
> >   * Use the accessor functions set_numa_mem(), numa_mem_id() and cpu_to_mem().
> 
> This comment could be updated.

Will do, do you prefer a follow-on patch or one that replaces this one?

> >   */
> >  DECLARE_PER_CPU(int, _numa_mem_);
> > +extern int _node_numa_mem_[MAX_NUMNODES];
> >  
> >  #ifndef set_numa_mem
> >  static inline void set_numa_mem(int node)
> >  {
> >  	this_cpu_write(_numa_mem_, node);
> > +	_node_numa_mem_[numa_node_id()] = node;
> > +}
> > +#endif
> > +
> > +#ifndef node_to_mem_node
> > +static inline int node_to_mem_node(int node)
> > +{
> > +	return _node_numa_mem_[node];
> >  }
> 
> A wee bit of documentation wouldn't hurt.
> 
> How does node_to_mem_node(numa_node_id()) differ from numa_mem_id()? 
> If I'm reading things correctly, they should both always return the
> same thing.  If so, do we need both?

That seems correct to me. The nearest memory node of this cpu's NUMA
node (node_to_mem_node(numa_node_id()) is always equal to the nearest
memory node (numa_mem_id()).

> Will node_to_mem_node() ever actually be called with a node !=
> numa_node_id()?

Well, it's a layering problem. The eventual callers of
node_to_mem_node() only have the requested NUMA node (if any) available.
I think because get_partial() __slab_alloc() allow for allocations for
any node, and that's where we see the slab deactivation issues, we need
to support this in the API.

In practice, it's probably that the node parameter is often
numa_node_id(), but we can't be sure of that in these call-paths,
afaict.
 
> >  #endif
> >  
> > @@ -146,6 +155,7 @@ static inline int cpu_to_mem(int cpu)
> >  static inline void set_cpu_numa_mem(int cpu, int node)
> >  {
> >  	per_cpu(_numa_mem_, cpu) = node;
> > +	_node_numa_mem_[cpu_to_node(cpu)] = node;
> >  }
> >  #endif
> >  
> > @@ -159,6 +169,13 @@ static inline int numa_mem_id(void)
> >  }
> >  #endif
> >  
> > +#ifndef node_to_mem_node
> > +static inline int node_to_mem_node(int node)
> > +{
> > +	return node;
> > +}
> > +#endif
> > +
> >  #ifndef cpu_to_mem
> >  static inline int cpu_to_mem(int cpu)
> >  {
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 18cee0d4c8a2..0883c42936d4 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -85,6 +85,7 @@ EXPORT_PER_CPU_SYMBOL(numa_node);
> >   */
> >  DEFINE_PER_CPU(int, _numa_mem_);		/* Kernel "local memory" node */
> >  EXPORT_PER_CPU_SYMBOL(_numa_mem_);
> > +int _node_numa_mem_[MAX_NUMNODES];
> 
> How does this get updated as CPUs, memory and nodes are hot-added and
> removed?

As CPUs are added, the architecture code in the CPU bringup will update
the NUMA topology. Memory and node hotplug are still open issues, I
mentioned the former in the cover letter. I should have mentioned it in
this commit message as well.

I do notice that Lee's commit message from 7aac78988551 ("numa:
introduce numa_mem_id()- effective local memory node id"):

"Generic initialization of 'numa_mem' occurs in __build_all_zonelists().
This will initialize the boot cpu at boot time, and all cpus on change
of numa_zonelist_order, or when node or memory hot-plug requires
zonelist rebuild.  Archs that support memoryless nodes will need to
initialize 'numa_mem' for secondary cpus as they're brought on-line."

And since we update the _node_numa_mem_ value on set_cpu_numa_mem()
calls, which were already needed for numa_mem_id(), we might be covered.
Testing these cases (hotplug) is next in my plans.

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
