Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id CFCC36B0037
	for <linux-mm@kvack.org>; Wed, 21 May 2014 15:58:02 -0400 (EDT)
Received: by mail-qg0-f53.google.com with SMTP id f51so4015515qge.12
        for <linux-mm@kvack.org>; Wed, 21 May 2014 12:58:02 -0700 (PDT)
Received: from e34.co.us.ibm.com (e34.co.us.ibm.com. [32.97.110.152])
        by mx.google.com with ESMTPS id q65si2714115qga.96.2014.05.21.12.58.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 21 May 2014 12:58:02 -0700 (PDT)
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Wed, 21 May 2014 13:58:00 -0600
Received: from b03cxnp08026.gho.boulder.ibm.com (b03cxnp08026.gho.boulder.ibm.com [9.17.130.18])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 9C3221FF003B
	for <linux-mm@kvack.org>; Wed, 21 May 2014 13:57:58 -0600 (MDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by b03cxnp08026.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s4LJv5BM5439888
	for <linux-mm@kvack.org>; Wed, 21 May 2014 21:57:05 +0200
Received: from d03av01.boulder.ibm.com (localhost [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s4LJvwRP015699
	for <linux-mm@kvack.org>; Wed, 21 May 2014 13:57:58 -0600
Date: Wed, 21 May 2014 12:57:43 -0700
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: Node 0 not necessary for powerpc?
Message-ID: <20140521195743.GA5755@linux.vnet.ibm.com>
References: <20140311195632.GA946@linux.vnet.ibm.com>
 <alpine.DEB.2.10.1403120839110.6865@nuc>
 <20140313164949.GC22247@linux.vnet.ibm.com>
 <20140519182400.GM8941@linux.vnet.ibm.com>
 <alpine.DEB.2.10.1405210915170.7859@gentwo.org>
 <20140521185812.GA5259@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140521185812.GA5259@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <htejun@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, anton@samba.org, David Rientjes <rientjes@google.com>, benh@kernel.crashing.org, tony.luck@intel.com

Hi Tejun,

On 21.05.2014 [14:58:12 -0400], Tejun Heo wrote:
> Hello,
> 
> On Wed, May 21, 2014 at 09:16:27AM -0500, Christoph Lameter wrote:
> > On Mon, 19 May 2014, Nishanth Aravamudan wrote:
> > > I'm seeing a panic at boot with this change on an LPAR which actually
> > > has no Node 0. Here's what I think is happening:
> > >
> > > start_kernel
> > >     ...
> > >     -> setup_per_cpu_areas
> > >         -> pcpu_embed_first_chunk
> > >             -> pcpu_fc_alloc
> > >                 -> ___alloc_bootmem_node(NODE_DATA(cpu_to_node(cpu), ...
> > >     -> smp_prepare_boot_cpu
> > >         -> set_numa_node(boot_cpuid)
> > >
> > > So we panic on the NODE_DATA call. It seems that ia64, at least, uses
> > > pcpu_alloc_first_chunk rather than embed. x86 has some code to handle
> > > early calls of cpu_to_node (early_cpu_to_node) and sets the mapping for
> > > all CPUs in setup_per_cpu_areas().
> > 
> > Maybe we can switch ia64 too embed? Tejun: Why are there these
> > dependencies?
> > 
> > > Thoughts? Does that mean we need something similar to x86 for powerpc?
> 
> I'm missing context to properly understand what's going on but the
> specific allocator in use shouldn't matter.  e.g. x86 can use both
> embed and page allocators.  If the problem is that the arch is
> accessing percpu memory before percpu allocator is initialized and the
> problem was masked before somehow, the right thing to do would be
> removing those premature percpu accesses.  If early percpu variables
> are really necessary, doing similar early_percpu thing as in x86 would
> be necessary.

For context: I was looking at why N_ONLINE was statically setting Node 0
to be online, whether or not the topology is that way -- I've been
getting several bugs lately where Node 0 is online, but has no CPUs and
no memory on it, on powerpc. 

On powerpc, setup_per_cpu_areas calls into ___alloc_bootmem_node using
NODE_DATA(cpu_to_node(cpu)).

Currently, cpu_to_node() in arch/powerpc/include/asm/topology.h does:

        /*
         * During early boot, the numa-cpu lookup table might not have been
         * setup for all CPUs yet. In such cases, default to node 0.
         */
        return (nid < 0) ? 0 : nid;

And so early at boot, if node 0 is not present, we end up accessing an
unitialized NODE_DATA(). So this seems buggy (I'll contact the powerpc
deveopers separately on that).

I recently submitted patches to have powerpc turn on
USE_PERCPU_NUMA_NODEID and HAVE_MEMORYLESS_NODES. But then, cpu_to_node
will be accessing percpu data in setup_per_cpu_areas, which seems like a
no-no. And more specifically, since we haven't yet run
smp_prepare_boot_cpu() at this point, cpu_to_node has not yet been
initialized to provide a sane value.

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
