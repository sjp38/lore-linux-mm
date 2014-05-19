Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id 80E186B0039
	for <linux-mm@kvack.org>; Mon, 19 May 2014 14:24:15 -0400 (EDT)
Received: by mail-qg0-f41.google.com with SMTP id j5so9488147qga.14
        for <linux-mm@kvack.org>; Mon, 19 May 2014 11:24:15 -0700 (PDT)
Received: from e9.ny.us.ibm.com (e9.ny.us.ibm.com. [32.97.182.139])
        by mx.google.com with ESMTPS id w18si9233300qgd.128.2014.05.19.11.24.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 19 May 2014 11:24:15 -0700 (PDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Mon, 19 May 2014 14:24:14 -0400
Received: from b01cxnp22033.gho.pok.ibm.com (b01cxnp22033.gho.pok.ibm.com [9.57.198.23])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 30DFFC90046
	for <linux-mm@kvack.org>; Mon, 19 May 2014 14:24:07 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by b01cxnp22033.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s4JIOCCl6947254
	for <linux-mm@kvack.org>; Mon, 19 May 2014 18:24:12 GMT
Received: from d01av03.pok.ibm.com (localhost [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s4JIOBnq006641
	for <linux-mm@kvack.org>; Mon, 19 May 2014 14:24:12 -0400
Date: Mon, 19 May 2014 11:24:00 -0700
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: Node 0 not necessary for powerpc?
Message-ID: <20140519182400.GM8941@linux.vnet.ibm.com>
References: <20140311195632.GA946@linux.vnet.ibm.com>
 <alpine.DEB.2.10.1403120839110.6865@nuc>
 <20140313164949.GC22247@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140313164949.GC22247@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, anton@samba.org, rientjes@google.com, benh@kernel.crashing.org

On 13.03.2014 [09:49:49 -0700], Nishanth Aravamudan wrote:
> On 12.03.2014 [08:41:40 -0500], Christoph Lameter wrote:
> > On Tue, 11 Mar 2014, Nishanth Aravamudan wrote:
> > > I have a P7 system that has no node0, but a node0 shows up in numactl
> > > --hardware, which has no cpus and no memory (and no PCI devices):
> > 
> > Well as you see from the code there has been so far the assumption that
> > node 0 has memory. I have never run a machine that has no node 0 memory.
> 
> Do you mean beyond the initialization? I didn't see anything obvious so
> far in the code itself that assumes a given node has memory (in the
> sense of the nid). What are your thoughts about how best to support
> this?

Ah, I found one path that is problematic on powerpc:

I'm seeing a panic at boot with this change on an LPAR which actually
has no Node 0. Here's what I think is happening:

start_kernel
    ...
    -> setup_per_cpu_areas
        -> pcpu_embed_first_chunk
            -> pcpu_fc_alloc
                -> ___alloc_bootmem_node(NODE_DATA(cpu_to_node(cpu), ...
    -> smp_prepare_boot_cpu
        -> set_numa_node(boot_cpuid)

So we panic on the NODE_DATA call. It seems that ia64, at least, uses
pcpu_alloc_first_chunk rather than embed. x86 has some code to handle
early calls of cpu_to_node (early_cpu_to_node) and sets the mapping for
all CPUs in setup_per_cpu_areas().

Thoughts? Does that mean we need something similar to x86 for powerpc?

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
