Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id B6B4A6B0038
	for <linux-mm@kvack.org>; Fri, 10 Apr 2015 15:48:46 -0400 (EDT)
Received: by qgfi89 with SMTP id i89so1611324qgf.1
        for <linux-mm@kvack.org>; Fri, 10 Apr 2015 12:48:46 -0700 (PDT)
Received: from e18.ny.us.ibm.com (e18.ny.us.ibm.com. [129.33.205.208])
        by mx.google.com with ESMTPS id f53si2793923qge.68.2015.04.10.12.48.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 10 Apr 2015 12:48:45 -0700 (PDT)
Received: from /spool/local
	by e18.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Fri, 10 Apr 2015 15:48:44 -0400
Received: from b01cxnp22033.gho.pok.ibm.com (b01cxnp22033.gho.pok.ibm.com [9.57.198.23])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id F2BABC90046
	for <linux-mm@kvack.org>; Fri, 10 Apr 2015 15:39:49 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by b01cxnp22033.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t3AJme8331457478
	for <linux-mm@kvack.org>; Fri, 10 Apr 2015 19:48:40 GMT
Received: from d01av04.pok.ibm.com (localhost [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t3AJmeH2025779
	for <linux-mm@kvack.org>; Fri, 10 Apr 2015 15:48:40 -0400
Date: Fri, 10 Apr 2015 12:48:39 -0700
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: [PATCH] of: return NUMA_NO_NODE from fallback of_node_to_nid()
Message-ID: <20150410194839.GA31621@linux.vnet.ibm.com>
References: <20150408165920.25007.6869.stgit@buzz>
 <55255F84.6060608@yandex-team.ru>
 <20150408230740.GB53918@linux.vnet.ibm.com>
 <CALYGNiP_Ru0PpWoXOYPbviiNuY+9JHDqzL0jDNJeZAtmYZGFUg@mail.gmail.com>
 <20150409225817.GI53918@linux.vnet.ibm.com>
 <5527B5EF.8090401@yandex-team.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5527B5EF.8090401@yandex-team.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>, Grant Likely <grant.likely@linaro.org>, devicetree@vger.kernel.org, Rob Herring <robh+dt@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, sparclinux@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, linuxppc-dev@lists.ozlabs.org

On 10.04.2015 [14:37:19 +0300], Konstantin Khlebnikov wrote:
> On 10.04.2015 01:58, Tanisha Aravamudan wrote:
> >On 09.04.2015 [07:27:28 +0300], Konstantin Khlebnikov wrote:
> >>On Thu, Apr 9, 2015 at 2:07 AM, Nishanth Aravamudan
> >><nacc@linux.vnet.ibm.com> wrote:
> >>>On 08.04.2015 [20:04:04 +0300], Konstantin Khlebnikov wrote:
> >>>>On 08.04.2015 19:59, Konstantin Khlebnikov wrote:
> >>>>>Node 0 might be offline as well as any other numa node,
> >>>>>in this case kernel cannot handle memory allocation and crashes.
> >>>
> >>>Isn't the bug that numa_node_id() returned an offline node? That
> >>>shouldn't happen.
> >>
> >>Offline node 0 came from static-inline copy of that function from of.h
> >>I've patched weak function for keeping consistency.
> >
> >Got it, that's not necessarily clear in the original commit message.
> 
> Sorry.
> 
> >
> >>>#ifdef CONFIG_USE_PERCPU_NUMA_NODE_ID
> >>>...
> >>>#ifndef numa_node_id
> >>>/* Returns the number of the current Node. */
> >>>static inline int numa_node_id(void)
> >>>{
> >>>         return raw_cpu_read(numa_node);
> >>>}
> >>>#endif
> >>>...
> >>>#else   /* !CONFIG_USE_PERCPU_NUMA_NODE_ID */
> >>>
> >>>/* Returns the number of the current Node. */
> >>>#ifndef numa_node_id
> >>>static inline int numa_node_id(void)
> >>>{
> >>>         return cpu_to_node(raw_smp_processor_id());
> >>>}
> >>>#endif
> >>>...
> >>>
> >>>So that's either the per-cpu numa_node value, right? Or the result of
> >>>cpu_to_node on the current processor.
> >>>
> >>>>Example:
> >>>>
> >>>>[    0.027133] ------------[ cut here ]------------
> >>>>[    0.027938] kernel BUG at include/linux/gfp.h:322!
> >>>
> >>>This is
> >>>
> >>>VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES || !node_online(nid));
> >>>
> >>>in
> >>>
> >>>alloc_pages_exact_node().
> >>>
> >>>And based on the trace below, that's
> >>>
> >>>__slab_alloc -> alloc
> >>>
> >>>alloc_pages_exact_node
> >>>         <- alloc_slab_page
> >>>                 <- allocate_slab
> >>>                         <- new_slab
> >>>                                 <- new_slab_objects
> >>>                                         < __slab_alloc?
> >>>
> >>>which is just passing the node value down, right? Which I think was
> >>>from:
> >>>
> >>>         domain = kzalloc_node(sizeof(*domain) + (sizeof(unsigned int) * size),
> >>>                               GFP_KERNEL, of_node_to_nid(of_node));
> >>>
> >>>?
> >>>
> >>>
> >>>What platform is this on, looks to be x86? qemu emulation of a
> >>>pathological topology? What was the topology?
> >>
> >>qemu x86_64, 2 cpu, 2 numa nodes, all memory in second.
> >
> >Ok, this worked before? That is, this is a regression?
> 
> Seems like that worked before 3.17 where
> bug was exposed by commit 44767bfaaed782d6d635ecbb13f3980041e6f33e
> (x86, irq: Enhance mp_register_ioapic() to support irqdomain)
> this is first usage of  *irq_domain_add*() in x86.

Ok.

> >>  I've slightly patched it to allow that setup (in qemu hardcoded 1Mb
> >>of memory connected to node 0) And i've found unrelated bug --
> >>if numa node has less that 4Mb ram then kernel crashes even
> >>earlier because numa code ignores that node
> >>but buddy allocator still tries to use that pages.
> >
> >So this isn't an actually supported topology by qemu?
> 
> Qemu easily created memoryless numa nodes but node 0 have hardcoded
> 1Mb of ram. This seems like legacy prop for DOS era software.

Well, the problem is that x86 doesn't support memoryless nodes.

git grep MEMORYLESS_NODES
arch/ia64/Kconfig:config HAVE_MEMORYLESS_NODES
arch/powerpc/Kconfig:config HAVE_MEMORYLESS_NODES

> >>>Note that there is a ton of code that seems to assume node 0 is online.
> >>>I started working on removing this assumption myself and it just led
> >>>down a rathole (on power, we always have node 0 online, even if it is
> >>>memoryless and cpuless, as a result).
> >>>
> >>>I am guessing this is just happening early in boot before the per-cpu
> >>>areas are setup? That's why (I think) x86 has the early_cpu_to_node()
> >>>function...
> >>>
> >>>Or do you not have CONFIG_OF set? So isn't the only change necessary to
> >>>the include file, and it should just return first_online_node rather
> >>>than 0?
> >>>
> >>>Ah and there's more of those node 0 assumptions :)
> >>
> >>That was x86 where is no CONFIG_OF at all.
> >>
> >>I don't know what's wrong with that machine but ACPI reports that
> >>cpus and memory from node 0 as connected to node 1 and everything
> >>seems worked fine until lates upgrade -- seems like buggy static-inline
> >>of_node_to_nid was intoduced in 3.13 but x86 ioapic uses it during
> >>early allocations only in since 3.17. Machine owner teells that 3.15
> >>worked fine.
> >
> >So, this was a qemu emulation of this actual physical machine without a
> >node 0?
> 
> Yep. Also I have crash from real machine but that stacktrace is messy
> because CONFIG_DEBUG_VM wasn't enabled and kernel crashed inside
> buddy allocator when tried to touch unallocated numa node structure.
> 
> >
> >As I mentioned, there are lots of node 0 assumptions through the kernel.
> >You might run into more issues at runtime.
> 
> I think it's possible to trigger kernel crash for any memoryless numa
> node (not just for 0) if some device (like ioapic in my case) points to
> it in its acpi tables. In runtime numa affinity configured by user
> usually validated by the kernel, while numbers from firmware might
> be used without proper validation.
> 
> Anyway seems like at least one x86 machines works fine without
> memory in node 0.

You're going to run into more issues, without adding proper memoryless
node support, I think.

-Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
