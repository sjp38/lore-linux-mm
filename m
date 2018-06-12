Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 66D9D6B027E
	for <linux-mm@kvack.org>; Tue, 12 Jun 2018 11:08:07 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id k62-v6so15698447oiy.1
        for <linux-mm@kvack.org>; Tue, 12 Jun 2018 08:08:07 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id d206-v6si104182oif.428.2018.06.12.08.08.05
        for <linux-mm@kvack.org>;
        Tue, 12 Jun 2018 08:08:05 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: Re: [PATCH 1/2] arm64: avoid alloc memory on offline node
References: <1527768879-88161-2-git-send-email-xiexiuqi@huawei.com>
	<20180606154516.GL6631@arm.com>
	<CAErSpo6S0qtR42tjGZrFu4aMFFyThx1hkHTSowTt6t3XerpHnA@mail.gmail.com>
	<20180607105514.GA13139@dhcp22.suse.cz>
	<5ed798a0-6c9c-086e-e5e8-906f593ca33e@huawei.com>
	<20180607122152.GP32433@dhcp22.suse.cz>
	<a880df29-b656-d98d-3037-b04761c7ed78@huawei.com>
	<20180611085237.GI13364@dhcp22.suse.cz>
	<16c4db2f-bc70-d0f2-fb38-341d9117ff66@huawei.com>
	<20180611134303.GC75679@bhelgaas-glaptop.roam.corp.google.com>
	<20180611145330.GO13364@dhcp22.suse.cz>
Date: Tue, 12 Jun 2018 16:08:03 +0100
In-Reply-To: <20180611145330.GO13364@dhcp22.suse.cz> (Michal Hocko's message
	of "Mon, 11 Jun 2018 16:53:30 +0200")
Message-ID: <87lgbk59gs.fsf@e105922-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Bjorn Helgaas <helgaas@kernel.org>, Xie XiuQi <xiexiuqi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, tnowicki@caviumnetworks.com, linux-pci@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Will Deacon <will.deacon@arm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Jarkko Sakkinen <jarkko.sakkinen@linux.intel.com>, linux-mm@kvack.org, wanghuiqiang@huawei.com, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Bjorn Helgaas <bhelgaas@google.com>, Andrew Morton <akpm@linux-foundation.org>, zhongjiang <zhongjiang@huawei.com>, linux-arm <linux-arm-kernel@lists.infradead.org>

Michal Hocko <mhocko@kernel.org> writes:

> On Mon 11-06-18 08:43:03, Bjorn Helgaas wrote:
>> On Mon, Jun 11, 2018 at 08:32:10PM +0800, Xie XiuQi wrote:
>> > Hi Michal,
>> > 
>> > On 2018/6/11 16:52, Michal Hocko wrote:
>> > > On Mon 11-06-18 11:23:18, Xie XiuQi wrote:
>> > >> Hi Michal,
>> > >>
>> > >> On 2018/6/7 20:21, Michal Hocko wrote:
>> > >>> On Thu 07-06-18 19:55:53, Hanjun Guo wrote:
>> > >>>> On 2018/6/7 18:55, Michal Hocko wrote:
>> > >>> [...]
>> > >>>>> I am not sure I have the full context but pci_acpi_scan_root calls
>> > >>>>> kzalloc_node(sizeof(*info), GFP_KERNEL, node)
>> > >>>>> and that should fall back to whatever node that is online. Offline node
>> > >>>>> shouldn't keep any pages behind. So there must be something else going
>> > >>>>> on here and the patch is not the right way to handle it. What does
>> > >>>>> faddr2line __alloc_pages_nodemask+0xf0 tells on this kernel?
>> > >>>>
>> > >>>> The whole context is:
>> > >>>>
>> > >>>> The system is booted with a NUMA node has no memory attaching to it
>> > >>>> (memory-less NUMA node), also with NR_CPUS less than CPUs presented
>> > >>>> in MADT, so CPUs on this memory-less node are not brought up, and
>> > >>>> this NUMA node will not be online (but SRAT presents this NUMA node);
>> > >>>>
>> > >>>> Devices attaching to this NUMA node such as PCI host bridge still
>> > >>>> return the valid NUMA node via _PXM, but actually that valid NUMA node
>> > >>>> is not online which lead to this issue.
>> > >>>
>> > >>> But we should have other numa nodes on the zonelists so the allocator
>> > >>> should fall back to other node. If the zonelist is not intiailized
>> > >>> properly, though, then this can indeed show up as a problem. Knowing
>> > >>> which exact place has blown up would help get a better picture...
>> > >>>
>> > >>
>> > >> I specific a non-exist node to allocate memory using kzalloc_node,
>> > >> and got this following error message.
>> > >>
>> > >> And I found out there is just a VM_WARN, but it does not prevent the memory
>> > >> allocation continue.
>> > >>
>> > >> This nid would be use to access NODE_DADA(nid), so if nid is invalid,
>> > >> it would cause oops here.
>> > >>
>> > >> 459 /*
>> > >> 460  * Allocate pages, preferring the node given as nid. The node must be valid and
>> > >> 461  * online. For more general interface, see alloc_pages_node().
>> > >> 462  */
>> > >> 463 static inline struct page *
>> > >> 464 __alloc_pages_node(int nid, gfp_t gfp_mask, unsigned int order)
>> > >> 465 {
>> > >> 466         VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES);
>> > >> 467         VM_WARN_ON(!node_online(nid));
>> > >> 468
>> > >> 469         return __alloc_pages(gfp_mask, order, nid);
>> > >> 470 }
>> > >> 471
>> > >>
>> > >> (I wrote a ko, to allocate memory on a non-exist node using kzalloc_node().)
>> > > 
>> > > OK, so this is an artificialy broken code, right. You shouldn't get a
>> > > non-existent node via standard APIs AFAICS. The original report was
>> > > about an existing node which is offline AFAIU. That would be a different
>> > > case. If I am missing something and there are legitimate users that try
>> > > to allocate from non-existing nodes then we should handle that in
>> > > node_zonelist.
>> > 
>> > I think hanjun's comments may help to understood this question:
>> >  - NUMA node will be built if CPUs and (or) memory are valid on this NUMA
>> >  node;
>> > 
>> >  - But if we boot the system with memory-less node and also with
>> >  CONFIG_NR_CPUS less than CPUs in SRAT, for example, 64 CPUs total with 4
>> >  NUMA nodes, 16 CPUs on each NUMA node, if we boot with
>> >  CONFIG_NR_CPUS=48, then we will not built numa node for node 3, but with
>> >  devices on that numa node, alloc memory will be panic because NUMA node
>> >  3 is not a valid node.
>
> Hmm, but this is not a memory-less node. It sounds like a misconfigured
> kernel to me or the broken initialization. Each CPU should have a
> fallback numa node to be used.
>
>> > I triggered this BUG on arm64 platform, and I found a similar bug has
>> > been fixed on x86 platform. So I sent a similar patch for this bug.
>> > 
>> > Or, could we consider to fix it in the mm subsystem?
>> 
>> The patch below (b755de8dfdfe) seems like totally the wrong direction.
>> I don't think we want every caller of kzalloc_node() to have check for
>> node_online().
>
> absolutely.
>
>> Why would memory on an off-line node even be in the allocation pool?
>> I wouldn't expect that memory to be put in the pool until the node
>> comes online and the memory is accessible, so this sounds like some
>> kind of setup issue.
>> 
>> But I'm definitely not an mm person.
>
> Well, the standard way to handle memory less NUMA nodes is to simply
> fallback to the closest NUMA node. We even have an API for that
> (numa_mem_id).

CONFIG_HAVE_MEMORYLESS node is not enabled on arm64 which means we end
up returning the original node in the fallback path.

Xie, does the below patch help? I can submit a proper patch if this
fixes the issue for you.

-- >8 --
Subject: [PATCH] arm64/numa: Enable memoryless numa nodes

Signed-off-by: Punit Agrawal <punit.agrawal@arm.com>
---
 arch/arm64/Kconfig   | 4 ++++
 arch/arm64/mm/numa.c | 2 ++
 2 files changed, 6 insertions(+)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index eb2cf4938f6d..5317e9aa93ab 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -756,6 +756,10 @@ config USE_PERCPU_NUMA_NODE_ID
 	def_bool y
 	depends on NUMA
 
+config HAVE_MEMORYLESS_NODES
+       def_bool y
+       depends on NUMA
+
 config HAVE_SETUP_PER_CPU_AREA
 	def_bool y
 	depends on NUMA
diff --git a/arch/arm64/mm/numa.c b/arch/arm64/mm/numa.c
index dad128ba98bf..c699dcfe93de 100644
--- a/arch/arm64/mm/numa.c
+++ b/arch/arm64/mm/numa.c
@@ -73,6 +73,8 @@ EXPORT_SYMBOL(cpumask_of_node);
 static void map_cpu_to_node(unsigned int cpu, int nid)
 {
 	set_cpu_numa_node(cpu, nid);
+	set_numa_mem(local_memory_node(nid));
+
 	if (nid >= 0)
 		cpumask_set_cpu(cpu, node_to_cpumask_map[nid]);
 }
-- 
2.17.0
