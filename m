Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f176.google.com (mail-qc0-f176.google.com [209.85.216.176])
	by kanga.kvack.org (Postfix) with ESMTP id D9D326B0036
	for <linux-mm@kvack.org>; Wed, 21 May 2014 14:58:15 -0400 (EDT)
Received: by mail-qc0-f176.google.com with SMTP id r5so3914265qcx.7
        for <linux-mm@kvack.org>; Wed, 21 May 2014 11:58:15 -0700 (PDT)
Received: from mail-qg0-x233.google.com (mail-qg0-x233.google.com [2607:f8b0:400d:c04::233])
        by mx.google.com with ESMTPS id 69si2531564qgp.59.2014.05.21.11.58.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 21 May 2014 11:58:15 -0700 (PDT)
Received: by mail-qg0-f51.google.com with SMTP id q107so3905987qgd.38
        for <linux-mm@kvack.org>; Wed, 21 May 2014 11:58:15 -0700 (PDT)
Date: Wed, 21 May 2014 14:58:12 -0400
From: Tejun Heo <htejun@gmail.com>
Subject: Re: Node 0 not necessary for powerpc?
Message-ID: <20140521185812.GA5259@htj.dyndns.org>
References: <20140311195632.GA946@linux.vnet.ibm.com>
 <alpine.DEB.2.10.1403120839110.6865@nuc>
 <20140313164949.GC22247@linux.vnet.ibm.com>
 <20140519182400.GM8941@linux.vnet.ibm.com>
 <alpine.DEB.2.10.1405210915170.7859@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1405210915170.7859@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, anton@samba.org, David Rientjes <rientjes@google.com>, benh@kernel.crashing.org, tony.luck@intel.com

Hello,

On Wed, May 21, 2014 at 09:16:27AM -0500, Christoph Lameter wrote:
> On Mon, 19 May 2014, Nishanth Aravamudan wrote:
> > I'm seeing a panic at boot with this change on an LPAR which actually
> > has no Node 0. Here's what I think is happening:
> >
> > start_kernel
> >     ...
> >     -> setup_per_cpu_areas
> >         -> pcpu_embed_first_chunk
> >             -> pcpu_fc_alloc
> >                 -> ___alloc_bootmem_node(NODE_DATA(cpu_to_node(cpu), ...
> >     -> smp_prepare_boot_cpu
> >         -> set_numa_node(boot_cpuid)
> >
> > So we panic on the NODE_DATA call. It seems that ia64, at least, uses
> > pcpu_alloc_first_chunk rather than embed. x86 has some code to handle
> > early calls of cpu_to_node (early_cpu_to_node) and sets the mapping for
> > all CPUs in setup_per_cpu_areas().
> 
> Maybe we can switch ia64 too embed? Tejun: Why are there these
> dependencies?
> 
> > Thoughts? Does that mean we need something similar to x86 for powerpc?

I'm missing context to properly understand what's going on but the
specific allocator in use shouldn't matter.  e.g. x86 can use both
embed and page allocators.  If the problem is that the arch is
accessing percpu memory before percpu allocator is initialized and the
problem was masked before somehow, the right thing to do would be
removing those premature percpu accesses.  If early percpu variables
are really necessary, doing similar early_percpu thing as in x86 would
be necessary.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
