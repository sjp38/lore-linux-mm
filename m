Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f49.google.com (mail-la0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id F062D6B0032
	for <linux-mm@kvack.org>; Thu,  9 Apr 2015 00:27:30 -0400 (EDT)
Received: by lagv1 with SMTP id v1so80817386lag.3
        for <linux-mm@kvack.org>; Wed, 08 Apr 2015 21:27:30 -0700 (PDT)
Received: from mail-lb0-x230.google.com (mail-lb0-x230.google.com. [2a00:1450:4010:c04::230])
        by mx.google.com with ESMTPS id i2si10448818lbz.68.2015.04.08.21.27.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Apr 2015 21:27:29 -0700 (PDT)
Received: by lbbzk7 with SMTP id zk7so82182788lbb.0
        for <linux-mm@kvack.org>; Wed, 08 Apr 2015 21:27:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150408230740.GB53918@linux.vnet.ibm.com>
References: <20150408165920.25007.6869.stgit@buzz>
	<55255F84.6060608@yandex-team.ru>
	<20150408230740.GB53918@linux.vnet.ibm.com>
Date: Thu, 9 Apr 2015 07:27:28 +0300
Message-ID: <CALYGNiP_Ru0PpWoXOYPbviiNuY+9JHDqzL0jDNJeZAtmYZGFUg@mail.gmail.com>
Subject: Re: [PATCH] of: return NUMA_NO_NODE from fallback of_node_to_nid()
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Grant Likely <grant.likely@linaro.org>, devicetree@vger.kernel.org, Rob Herring <robh+dt@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, sparclinux@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, linuxppc-dev@lists.ozlabs.org

On Thu, Apr 9, 2015 at 2:07 AM, Nishanth Aravamudan
<nacc@linux.vnet.ibm.com> wrote:
> On 08.04.2015 [20:04:04 +0300], Konstantin Khlebnikov wrote:
>> On 08.04.2015 19:59, Konstantin Khlebnikov wrote:
>> >Node 0 might be offline as well as any other numa node,
>> >in this case kernel cannot handle memory allocation and crashes.
>
> Isn't the bug that numa_node_id() returned an offline node? That
> shouldn't happen.

Offline node 0 came from static-inline copy of that function from of.h
I've patched weak function for keeping consistency.

>
> #ifdef CONFIG_USE_PERCPU_NUMA_NODE_ID
> ...
> #ifndef numa_node_id
> /* Returns the number of the current Node. */
> static inline int numa_node_id(void)
> {
>         return raw_cpu_read(numa_node);
> }
> #endif
> ...
> #else   /* !CONFIG_USE_PERCPU_NUMA_NODE_ID */
>
> /* Returns the number of the current Node. */
> #ifndef numa_node_id
> static inline int numa_node_id(void)
> {
>         return cpu_to_node(raw_smp_processor_id());
> }
> #endif
> ...
>
> So that's either the per-cpu numa_node value, right? Or the result of
> cpu_to_node on the current processor.
>
>> Example:
>>
>> [    0.027133] ------------[ cut here ]------------
>> [    0.027938] kernel BUG at include/linux/gfp.h:322!
>
> This is
>
> VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES || !node_online(nid));
>
> in
>
> alloc_pages_exact_node().
>
> And based on the trace below, that's
>
> __slab_alloc -> alloc
>
> alloc_pages_exact_node
>         <- alloc_slab_page
>                 <- allocate_slab
>                         <- new_slab
>                                 <- new_slab_objects
>                                         < __slab_alloc?
>
> which is just passing the node value down, right? Which I think was
> from:
>
>         domain = kzalloc_node(sizeof(*domain) + (sizeof(unsigned int) * size),
>                               GFP_KERNEL, of_node_to_nid(of_node));
>
> ?
>
>
> What platform is this on, looks to be x86? qemu emulation of a
> pathological topology? What was the topology?

qemu x86_64, 2 cpu, 2 numa nodes, all memory in second.
 I've slightly patched it to allow that setup (in qemu hardcoded 1Mb
of memory connected to node 0) And i've found unrelated bug --
if numa node has less that 4Mb ram then kernel crashes even
earlier because numa code ignores that node
but buddy allocator still tries to use that pages.

>
> Note that there is a ton of code that seems to assume node 0 is online.
> I started working on removing this assumption myself and it just led
> down a rathole (on power, we always have node 0 online, even if it is
> memoryless and cpuless, as a result).
>
> I am guessing this is just happening early in boot before the per-cpu
> areas are setup? That's why (I think) x86 has the early_cpu_to_node()
> function...
>
> Or do you not have CONFIG_OF set? So isn't the only change necessary to
> the include file, and it should just return first_online_node rather
> than 0?
>
> Ah and there's more of those node 0 assumptions :)

That was x86 where is no CONFIG_OF at all.

I don't know what's wrong with that machine but ACPI reports that
cpus and memory from node 0 as connected to node 1 and everything
seems worked fine until lates upgrade -- seems like buggy static-inline
of_node_to_nid was intoduced in 3.13 but x86 ioapic uses it during
early allocations only in since 3.17. Machine owner teells that 3.15
worked fine.

>
> #define first_online_node       0
> #define first_memory_node       0
>
> if MAX_NUMODES == 1...
>
> -Nish
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
