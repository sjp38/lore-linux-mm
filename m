Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 907EC6B0038
	for <linux-mm@kvack.org>; Thu,  9 Apr 2015 18:58:22 -0400 (EDT)
Received: by ignm3 with SMTP id m3so4304437ign.0
        for <linux-mm@kvack.org>; Thu, 09 Apr 2015 15:58:22 -0700 (PDT)
Received: from e33.co.us.ibm.com (e33.co.us.ibm.com. [32.97.110.151])
        by mx.google.com with ESMTPS id d197si132697ioe.54.2015.04.09.15.58.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 09 Apr 2015 15:58:22 -0700 (PDT)
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Thu, 9 Apr 2015 16:58:21 -0600
Received: from b03cxnp08028.gho.boulder.ibm.com (b03cxnp08028.gho.boulder.ibm.com [9.17.130.20])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 119801FF001E
	for <linux-mm@kvack.org>; Thu,  9 Apr 2015 16:49:30 -0600 (MDT)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by b03cxnp08028.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t39Mw4CF40763538
	for <linux-mm@kvack.org>; Thu, 9 Apr 2015 15:58:04 -0700
Received: from d03av05.boulder.ibm.com (localhost [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t39MwIw3004490
	for <linux-mm@kvack.org>; Thu, 9 Apr 2015 16:58:19 -0600
Date: Thu, 9 Apr 2015 15:58:17 -0700
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: [PATCH] of: return NUMA_NO_NODE from fallback of_node_to_nid()
Message-ID: <20150409225817.GI53918@linux.vnet.ibm.com>
References: <20150408165920.25007.6869.stgit@buzz>
 <55255F84.6060608@yandex-team.ru>
 <20150408230740.GB53918@linux.vnet.ibm.com>
 <CALYGNiP_Ru0PpWoXOYPbviiNuY+9JHDqzL0jDNJeZAtmYZGFUg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALYGNiP_Ru0PpWoXOYPbviiNuY+9JHDqzL0jDNJeZAtmYZGFUg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Grant Likely <grant.likely@linaro.org>, devicetree@vger.kernel.org, Rob Herring <robh+dt@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, sparclinux@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, linuxppc-dev@lists.ozlabs.org

On 09.04.2015 [07:27:28 +0300], Konstantin Khlebnikov wrote:
> On Thu, Apr 9, 2015 at 2:07 AM, Nishanth Aravamudan
> <nacc@linux.vnet.ibm.com> wrote:
> > On 08.04.2015 [20:04:04 +0300], Konstantin Khlebnikov wrote:
> >> On 08.04.2015 19:59, Konstantin Khlebnikov wrote:
> >> >Node 0 might be offline as well as any other numa node,
> >> >in this case kernel cannot handle memory allocation and crashes.
> >
> > Isn't the bug that numa_node_id() returned an offline node? That
> > shouldn't happen.
> 
> Offline node 0 came from static-inline copy of that function from of.h
> I've patched weak function for keeping consistency.

Got it, that's not necessarily clear in the original commit message.

> > #ifdef CONFIG_USE_PERCPU_NUMA_NODE_ID
> > ...
> > #ifndef numa_node_id
> > /* Returns the number of the current Node. */
> > static inline int numa_node_id(void)
> > {
> >         return raw_cpu_read(numa_node);
> > }
> > #endif
> > ...
> > #else   /* !CONFIG_USE_PERCPU_NUMA_NODE_ID */
> >
> > /* Returns the number of the current Node. */
> > #ifndef numa_node_id
> > static inline int numa_node_id(void)
> > {
> >         return cpu_to_node(raw_smp_processor_id());
> > }
> > #endif
> > ...
> >
> > So that's either the per-cpu numa_node value, right? Or the result of
> > cpu_to_node on the current processor.
> >
> >> Example:
> >>
> >> [    0.027133] ------------[ cut here ]------------
> >> [    0.027938] kernel BUG at include/linux/gfp.h:322!
> >
> > This is
> >
> > VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES || !node_online(nid));
> >
> > in
> >
> > alloc_pages_exact_node().
> >
> > And based on the trace below, that's
> >
> > __slab_alloc -> alloc
> >
> > alloc_pages_exact_node
> >         <- alloc_slab_page
> >                 <- allocate_slab
> >                         <- new_slab
> >                                 <- new_slab_objects
> >                                         < __slab_alloc?
> >
> > which is just passing the node value down, right? Which I think was
> > from:
> >
> >         domain = kzalloc_node(sizeof(*domain) + (sizeof(unsigned int) * size),
> >                               GFP_KERNEL, of_node_to_nid(of_node));
> >
> > ?
> >
> >
> > What platform is this on, looks to be x86? qemu emulation of a
> > pathological topology? What was the topology?
> 
> qemu x86_64, 2 cpu, 2 numa nodes, all memory in second.

Ok, this worked before? That is, this is a regression?

>  I've slightly patched it to allow that setup (in qemu hardcoded 1Mb
> of memory connected to node 0) And i've found unrelated bug --
> if numa node has less that 4Mb ram then kernel crashes even
> earlier because numa code ignores that node
> but buddy allocator still tries to use that pages.

So this isn't an actually supported topology by qemu?

> > Note that there is a ton of code that seems to assume node 0 is online.
> > I started working on removing this assumption myself and it just led
> > down a rathole (on power, we always have node 0 online, even if it is
> > memoryless and cpuless, as a result).
> >
> > I am guessing this is just happening early in boot before the per-cpu
> > areas are setup? That's why (I think) x86 has the early_cpu_to_node()
> > function...
> >
> > Or do you not have CONFIG_OF set? So isn't the only change necessary to
> > the include file, and it should just return first_online_node rather
> > than 0?
> >
> > Ah and there's more of those node 0 assumptions :)
> 
> That was x86 where is no CONFIG_OF at all.
>
> I don't know what's wrong with that machine but ACPI reports that
> cpus and memory from node 0 as connected to node 1 and everything
> seems worked fine until lates upgrade -- seems like buggy static-inline
> of_node_to_nid was intoduced in 3.13 but x86 ioapic uses it during
> early allocations only in since 3.17. Machine owner teells that 3.15
> worked fine.

So, this was a qemu emulation of this actual physical machine without a
node 0?

As I mentioned, there are lots of node 0 assumptions through the kernel.
You might run into more issues at runtime.

-Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
