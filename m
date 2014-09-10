Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id 6B41A6B004D
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 18:50:03 -0400 (EDT)
Received: by mail-ig0-f170.google.com with SMTP id l13so300505iga.1
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 15:50:03 -0700 (PDT)
Received: from e38.co.us.ibm.com (e38.co.us.ibm.com. [32.97.110.159])
        by mx.google.com with ESMTPS id s5si3260819igh.44.2014.09.10.15.50.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Sep 2014 15:50:02 -0700 (PDT)
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Wed, 10 Sep 2014 16:50:01 -0600
Received: from b03cxnp07029.gho.boulder.ibm.com (b03cxnp07029.gho.boulder.ibm.com [9.17.130.16])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 5AB7219D803F
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 16:49:46 -0600 (MDT)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by b03cxnp07029.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id s8AKjuaI524672
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 22:45:56 +0200
Received: from d03av02.boulder.ibm.com (localhost [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s8AMnwrR022043
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 16:49:59 -0600
Date: Wed, 10 Sep 2014 15:49:50 -0700
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: [PATCH v3] topology: add support for node_to_mem_node() to
 determine the fallback node
Message-ID: <20140910224950.GC9333@linux.vnet.ibm.com>
References: <20140909190154.GC22906@linux.vnet.ibm.com>
 <20140909190326.GD22906@linux.vnet.ibm.com>
 <20140909171115.75c7702c37dfb23b9e053636@linux-foundation.org>
 <20140910004723.GH22906@linux.vnet.ibm.com>
 <20140910120616.4aa03ed0c0c88fdd1b3fd6c2@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140910120616.4aa03ed0c0c88fdd1b3fd6c2@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Paul Mackerras <paulus@samba.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Anton Blanchard <anton@samba.org>, Matt Mackall <mpm@selenic.com>, Christoph Lameter <cl@linux.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linuxppc-dev@lists.ozlabs.org

On 10.09.2014 [12:06:16 -0700], Andrew Morton wrote:
> On Tue, 9 Sep 2014 17:47:23 -0700 Nishanth Aravamudan <nacc@linux.vnet.ibm.com> wrote:
> 
> > On 09.09.2014 [17:11:15 -0700], Andrew Morton wrote:
> > > On Tue, 9 Sep 2014 12:03:27 -0700 Nishanth Aravamudan <nacc@linux.vnet.ibm.com> wrote:
> > > 
> > > > From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > > > 
> > > > We need to determine the fallback node in slub allocator if the
> > > > allocation target node is memoryless node. Without it, the SLUB wrongly
> > > > select the node which has no memory and can't use a partial slab,
> > > > because of node mismatch. Introduced function, node_to_mem_node(X), will
> > > > return a node Y with memory that has the nearest distance. If X is
> > > > memoryless node, it will return nearest distance node, but, if X is
> > > > normal node, it will return itself.
> > > > 
> > > > We will use this function in following patch to determine the fallback
> > > > node.
> > > > 
> > > > ...
> > > >
> > > > --- a/include/linux/topology.h
> > > > +++ b/include/linux/topology.h
> > > > @@ -119,11 +119,20 @@ static inline int numa_node_id(void)
> > > >   * Use the accessor functions set_numa_mem(), numa_mem_id() and cpu_to_mem().
> > > 
> > > This comment could be updated.
> > 
> > Will do, do you prefer a follow-on patch or one that replaces this one?
> 
> Either is OK for me.  I always turn replacement patches into
> incrementals so I (and others) can see what changed.

Ok, I'll probably send you just an incremental then myself.

> > > >   */
> > > >  DECLARE_PER_CPU(int, _numa_mem_);
> > > > +extern int _node_numa_mem_[MAX_NUMNODES];
> > > >  
> > > >  #ifndef set_numa_mem
> > > >  static inline void set_numa_mem(int node)
> > > >  {
> > > >  	this_cpu_write(_numa_mem_, node);
> > > > +	_node_numa_mem_[numa_node_id()] = node;
> > > > +}
> > > > +#endif
> > > > +
> > > > +#ifndef node_to_mem_node
> > > > +static inline int node_to_mem_node(int node)
> > > > +{
> > > > +	return _node_numa_mem_[node];
> > > >  }
> > > 
> > > A wee bit of documentation wouldn't hurt.
> 
> This?

Yep, I'll make sure it gets added.

> > > > --- a/mm/page_alloc.c
> > > > +++ b/mm/page_alloc.c
> > > > @@ -85,6 +85,7 @@ EXPORT_PER_CPU_SYMBOL(numa_node);
> > > >   */
> > > >  DEFINE_PER_CPU(int, _numa_mem_);		/* Kernel "local memory" node */
> > > >  EXPORT_PER_CPU_SYMBOL(_numa_mem_);
> > > > +int _node_numa_mem_[MAX_NUMNODES];
> > > 
> > > How does this get updated as CPUs, memory and nodes are hot-added and
> > > removed?
> > 
> > As CPUs are added, the architecture code in the CPU bringup will update
> > the NUMA topology. Memory and node hotplug are still open issues, I
> > mentioned the former in the cover letter. I should have mentioned it in
> > this commit message as well.
> 
> Please define "open issue".  The computer will crash and catch fire?
> If not that, then what?

Umm, let's call it "undefined" (untested?). Which is no different than
where we are today, afaict, with memoryless nodes. I think going from
memoryless->memoryful probably works, but the other direction may not
(and may not be possible in the common case).

-Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
