Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 3314D6B006C
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 15:06:19 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id w10so6876017pde.40
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 12:06:18 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id gh9si19909654pac.62.2014.09.10.12.06.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Sep 2014 12:06:18 -0700 (PDT)
Date: Wed, 10 Sep 2014 12:06:16 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3] topology: add support for node_to_mem_node() to
 determine the fallback node
Message-Id: <20140910120616.4aa03ed0c0c88fdd1b3fd6c2@linux-foundation.org>
In-Reply-To: <20140910004723.GH22906@linux.vnet.ibm.com>
References: <20140909190154.GC22906@linux.vnet.ibm.com>
	<20140909190326.GD22906@linux.vnet.ibm.com>
	<20140909171115.75c7702c37dfb23b9e053636@linux-foundation.org>
	<20140910004723.GH22906@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Paul Mackerras <paulus@samba.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Anton Blanchard <anton@samba.org>, Matt Mackall <mpm@selenic.com>, Christoph Lameter <cl@linux.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linuxppc-dev@lists.ozlabs.org

On Tue, 9 Sep 2014 17:47:23 -0700 Nishanth Aravamudan <nacc@linux.vnet.ibm.com> wrote:

> On 09.09.2014 [17:11:15 -0700], Andrew Morton wrote:
> > On Tue, 9 Sep 2014 12:03:27 -0700 Nishanth Aravamudan <nacc@linux.vnet.ibm.com> wrote:
> > 
> > > From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > > 
> > > We need to determine the fallback node in slub allocator if the
> > > allocation target node is memoryless node. Without it, the SLUB wrongly
> > > select the node which has no memory and can't use a partial slab,
> > > because of node mismatch. Introduced function, node_to_mem_node(X), will
> > > return a node Y with memory that has the nearest distance. If X is
> > > memoryless node, it will return nearest distance node, but, if X is
> > > normal node, it will return itself.
> > > 
> > > We will use this function in following patch to determine the fallback
> > > node.
> > > 
> > > ...
> > >
> > > --- a/include/linux/topology.h
> > > +++ b/include/linux/topology.h
> > > @@ -119,11 +119,20 @@ static inline int numa_node_id(void)
> > >   * Use the accessor functions set_numa_mem(), numa_mem_id() and cpu_to_mem().
> > 
> > This comment could be updated.
> 
> Will do, do you prefer a follow-on patch or one that replaces this one?

Either is OK for me.  I always turn replacement patches into
incrementals so I (and others) can see what changed.

> > >   */
> > >  DECLARE_PER_CPU(int, _numa_mem_);
> > > +extern int _node_numa_mem_[MAX_NUMNODES];
> > >  
> > >  #ifndef set_numa_mem
> > >  static inline void set_numa_mem(int node)
> > >  {
> > >  	this_cpu_write(_numa_mem_, node);
> > > +	_node_numa_mem_[numa_node_id()] = node;
> > > +}
> > > +#endif
> > > +
> > > +#ifndef node_to_mem_node
> > > +static inline int node_to_mem_node(int node)
> > > +{
> > > +	return _node_numa_mem_[node];
> > >  }
> > 
> > A wee bit of documentation wouldn't hurt.

This?

> > > --- a/mm/page_alloc.c
> > > +++ b/mm/page_alloc.c
> > > @@ -85,6 +85,7 @@ EXPORT_PER_CPU_SYMBOL(numa_node);
> > >   */
> > >  DEFINE_PER_CPU(int, _numa_mem_);		/* Kernel "local memory" node */
> > >  EXPORT_PER_CPU_SYMBOL(_numa_mem_);
> > > +int _node_numa_mem_[MAX_NUMNODES];
> > 
> > How does this get updated as CPUs, memory and nodes are hot-added and
> > removed?
> 
> As CPUs are added, the architecture code in the CPU bringup will update
> the NUMA topology. Memory and node hotplug are still open issues, I
> mentioned the former in the cover letter. I should have mentioned it in
> this commit message as well.

Please define "open issue".  The computer will crash and catch fire?
If not that, then what?

> I do notice that Lee's commit message from 7aac78988551 ("numa:
> introduce numa_mem_id()- effective local memory node id"):
> 
> "Generic initialization of 'numa_mem' occurs in __build_all_zonelists().
> This will initialize the boot cpu at boot time, and all cpus on change
> of numa_zonelist_order, or when node or memory hot-plug requires
> zonelist rebuild.  Archs that support memoryless nodes will need to
> initialize 'numa_mem' for secondary cpus as they're brought on-line."
> 
> And since we update the _node_numa_mem_ value on set_cpu_numa_mem()
> calls, which were already needed for numa_mem_id(), we might be covered.
> Testing these cases (hotplug) is next in my plans.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
