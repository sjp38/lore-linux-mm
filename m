Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id E3E0A6B02B9
	for <linux-mm@kvack.org>; Mon, 11 Jun 2018 10:53:36 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id e39-v6so5010050plb.10
        for <linux-mm@kvack.org>; Mon, 11 Jun 2018 07:53:36 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f13-v6si12446805pgq.138.2018.06.11.07.53.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 11 Jun 2018 07:53:35 -0700 (PDT)
Date: Mon, 11 Jun 2018 16:53:30 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] arm64: avoid alloc memory on offline node
Message-ID: <20180611145330.GO13364@dhcp22.suse.cz>
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
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180611134303.GC75679@bhelgaas-glaptop.roam.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bjorn Helgaas <helgaas@kernel.org>
Cc: Xie XiuQi <xiexiuqi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, tnowicki@caviumnetworks.com, linux-pci@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Will Deacon <will.deacon@arm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Jarkko Sakkinen <jarkko.sakkinen@linux.intel.com>, linux-mm@kvack.org, wanghuiqiang@huawei.com, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Bjorn Helgaas <bhelgaas@google.com>, Andrew Morton <akpm@linux-foundation.org>, zhongjiang <zhongjiang@huawei.com>, linux-arm <linux-arm-kernel@lists.infradead.org>

On Mon 11-06-18 08:43:03, Bjorn Helgaas wrote:
> On Mon, Jun 11, 2018 at 08:32:10PM +0800, Xie XiuQi wrote:
> > Hi Michal,
> > 
> > On 2018/6/11 16:52, Michal Hocko wrote:
> > > On Mon 11-06-18 11:23:18, Xie XiuQi wrote:
> > >> Hi Michal,
> > >>
> > >> On 2018/6/7 20:21, Michal Hocko wrote:
> > >>> On Thu 07-06-18 19:55:53, Hanjun Guo wrote:
> > >>>> On 2018/6/7 18:55, Michal Hocko wrote:
> > >>> [...]
> > >>>>> I am not sure I have the full context but pci_acpi_scan_root calls
> > >>>>> kzalloc_node(sizeof(*info), GFP_KERNEL, node)
> > >>>>> and that should fall back to whatever node that is online. Offline node
> > >>>>> shouldn't keep any pages behind. So there must be something else going
> > >>>>> on here and the patch is not the right way to handle it. What does
> > >>>>> faddr2line __alloc_pages_nodemask+0xf0 tells on this kernel?
> > >>>>
> > >>>> The whole context is:
> > >>>>
> > >>>> The system is booted with a NUMA node has no memory attaching to it
> > >>>> (memory-less NUMA node), also with NR_CPUS less than CPUs presented
> > >>>> in MADT, so CPUs on this memory-less node are not brought up, and
> > >>>> this NUMA node will not be online (but SRAT presents this NUMA node);
> > >>>>
> > >>>> Devices attaching to this NUMA node such as PCI host bridge still
> > >>>> return the valid NUMA node via _PXM, but actually that valid NUMA node
> > >>>> is not online which lead to this issue.
> > >>>
> > >>> But we should have other numa nodes on the zonelists so the allocator
> > >>> should fall back to other node. If the zonelist is not intiailized
> > >>> properly, though, then this can indeed show up as a problem. Knowing
> > >>> which exact place has blown up would help get a better picture...
> > >>>
> > >>
> > >> I specific a non-exist node to allocate memory using kzalloc_node,
> > >> and got this following error message.
> > >>
> > >> And I found out there is just a VM_WARN, but it does not prevent the memory
> > >> allocation continue.
> > >>
> > >> This nid would be use to access NODE_DADA(nid), so if nid is invalid,
> > >> it would cause oops here.
> > >>
> > >> 459 /*
> > >> 460  * Allocate pages, preferring the node given as nid. The node must be valid and
> > >> 461  * online. For more general interface, see alloc_pages_node().
> > >> 462  */
> > >> 463 static inline struct page *
> > >> 464 __alloc_pages_node(int nid, gfp_t gfp_mask, unsigned int order)
> > >> 465 {
> > >> 466         VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES);
> > >> 467         VM_WARN_ON(!node_online(nid));
> > >> 468
> > >> 469         return __alloc_pages(gfp_mask, order, nid);
> > >> 470 }
> > >> 471
> > >>
> > >> (I wrote a ko, to allocate memory on a non-exist node using kzalloc_node().)
> > > 
> > > OK, so this is an artificialy broken code, right. You shouldn't get a
> > > non-existent node via standard APIs AFAICS. The original report was
> > > about an existing node which is offline AFAIU. That would be a different
> > > case. If I am missing something and there are legitimate users that try
> > > to allocate from non-existing nodes then we should handle that in
> > > node_zonelist.
> > 
> > I think hanjun's comments may help to understood this question:
> >  - NUMA node will be built if CPUs and (or) memory are valid on this NUMA
> >  node;
> > 
> >  - But if we boot the system with memory-less node and also with
> >  CONFIG_NR_CPUS less than CPUs in SRAT, for example, 64 CPUs total with 4
> >  NUMA nodes, 16 CPUs on each NUMA node, if we boot with
> >  CONFIG_NR_CPUS=48, then we will not built numa node for node 3, but with
> >  devices on that numa node, alloc memory will be panic because NUMA node
> >  3 is not a valid node.

Hmm, but this is not a memory-less node. It sounds like a misconfigured
kernel to me or the broken initialization. Each CPU should have a
fallback numa node to be used.

> > I triggered this BUG on arm64 platform, and I found a similar bug has
> > been fixed on x86 platform. So I sent a similar patch for this bug.
> > 
> > Or, could we consider to fix it in the mm subsystem?
> 
> The patch below (b755de8dfdfe) seems like totally the wrong direction.
> I don't think we want every caller of kzalloc_node() to have check for
> node_online().

absolutely.

> Why would memory on an off-line node even be in the allocation pool?
> I wouldn't expect that memory to be put in the pool until the node
> comes online and the memory is accessible, so this sounds like some
> kind of setup issue.
> 
> But I'm definitely not an mm person.

Well, the standard way to handle memory less NUMA nodes is to simply
fallback to the closest NUMA node. We even have an API for that
(numa_mem_id).
 
> > From b755de8dfdfef97effaa91379ffafcb81f4d62a1 Mon Sep 17 00:00:00 2001
> > From: Yinghai Lu <Yinghai.Lu@Sun.COM>
> > Date: Wed, 20 Feb 2008 12:41:52 -0800
> > Subject: [PATCH] x86: make dev_to_node return online node
> > 
> > a numa system (with multi HT chains) may return node without ram. Aka it
> > is not online. Try to get an online node, otherwise return -1.
> > 
> > Signed-off-by: Yinghai Lu <yinghai.lu@sun.com>
> > Signed-off-by: Ingo Molnar <mingo@elte.hu>
> > Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
> > ---
> >  arch/x86/pci/acpi.c | 3 +++
> >  1 file changed, 3 insertions(+)
> > 
> > diff --git a/arch/x86/pci/acpi.c b/arch/x86/pci/acpi.c
> > index d95de2f..ea8685f 100644
> > --- a/arch/x86/pci/acpi.c
> > +++ b/arch/x86/pci/acpi.c
> > @@ -172,6 +172,9 @@ struct pci_bus * __devinit pci_acpi_scan_root(struct acpi_device *device, int do
> >  		set_mp_bus_to_node(busnum, node);
> >  	else
> >  		node = get_mp_bus_to_node(busnum);
> > +
> > +	if (node != -1 && !node_online(node))
> > +		node = -1;
> >  #endif
> > 
> >  	/* Allocate per-root-bus (not per bus) arch-specific data.

-- 
Michal Hocko
SUSE Labs
