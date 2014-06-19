Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f41.google.com (mail-qa0-f41.google.com [209.85.216.41])
	by kanga.kvack.org (Postfix) with ESMTP id 44BE66B0031
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 13:14:39 -0400 (EDT)
Received: by mail-qa0-f41.google.com with SMTP id cm18so2240485qab.0
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 10:14:38 -0700 (PDT)
Received: from e39.co.us.ibm.com (e39.co.us.ibm.com. [32.97.110.160])
        by mx.google.com with ESMTPS id u10si7119955qca.33.2014.06.19.10.14.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 19 Jun 2014 10:14:38 -0700 (PDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Thu, 19 Jun 2014 11:14:36 -0600
Received: from b03cxnp08026.gho.boulder.ibm.com (b03cxnp08026.gho.boulder.ibm.com [9.17.130.18])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 9647AC40001
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 11:14:26 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by b03cxnp08026.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s5JHDJqX64225444
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 19:13:24 +0200
Received: from d03av03.boulder.ibm.com (localhost [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s5JHEK0k007234
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 11:14:21 -0600
Date: Thu, 19 Jun 2014 10:14:01 -0700
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: Node 0 not necessary for powerpc?
Message-ID: <20140619171401.GU16644@linux.vnet.ibm.com>
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

The early access is in the arch's pcpu_alloc_bootmem. On x86, rather
than using NODE_DATA(cpu_to_node), it uses (in pcpu_alloc_bootmem),
early_cpu_to_node(cpu) with their custom logic.

The issue is that cpu_to_node, if USE_PERCPU_NUMA_NODE_ID is defined
(which it is for NUMA powerpc, x86, ia64), is that cpu_to_node uses the
percpu area, which data isn't initialized yet.

So I guess powerpc needs the same treatment as x86.

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
