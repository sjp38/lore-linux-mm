Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6742F6B0003
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 10:08:40 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id n63-v6so11694589oig.21
        for <linux-mm@kvack.org>; Tue, 19 Jun 2018 07:08:40 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id l73-v6si6128401otl.457.2018.06.19.07.08.39
        for <linux-mm@kvack.org>;
        Tue, 19 Jun 2018 07:08:39 -0700 (PDT)
Date: Tue, 19 Jun 2018 15:08:26 +0100
From: Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>
Subject: Re: [PATCH 1/2] arm64: avoid alloc memory on offline node
Message-ID: <20180619140818.GA16927@e107981-ln.cambridge.arm.com>
References: <a880df29-b656-d98d-3037-b04761c7ed78@huawei.com>
 <20180611085237.GI13364@dhcp22.suse.cz>
 <16c4db2f-bc70-d0f2-fb38-341d9117ff66@huawei.com>
 <20180611134303.GC75679@bhelgaas-glaptop.roam.corp.google.com>
 <20180611145330.GO13364@dhcp22.suse.cz>
 <87lgbk59gs.fsf@e105922-lin.cambridge.arm.com>
 <87bmce60y3.fsf@e105922-lin.cambridge.arm.com>
 <8b715082-14d4-f10b-d2d6-b23be7e4bf7e@huawei.com>
 <20180619120714.GE13685@dhcp22.suse.cz>
 <874lhz3pmn.fsf@e105922-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <874lhz3pmn.fsf@e105922-lin.cambridge.arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Punit Agrawal <punit.agrawal@arm.com>
Cc: Michal Hocko <mhocko@kernel.org>, Xie XiuQi <xiexiuqi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Bjorn Helgaas <helgaas@kernel.org>, tnowicki@caviumnetworks.com, linux-pci@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Will Deacon <will.deacon@arm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Jarkko Sakkinen <jarkko.sakkinen@linux.intel.com>, linux-mm@kvack.org, wanghuiqiang@huawei.com, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Bjorn Helgaas <bhelgaas@google.com>, Andrew Morton <akpm@linux-foundation.org>, zhongjiang <zhongjiang@huawei.com>, linux-arm <linux-arm-kernel@lists.infradead.org>

On Tue, Jun 19, 2018 at 01:52:16PM +0100, Punit Agrawal wrote:
> Michal Hocko <mhocko@kernel.org> writes:
> 
> > On Tue 19-06-18 20:03:07, Xie XiuQi wrote:
> > [...]
> >> I tested on a arm board with 128 cores 4 numa nodes, but I set CONFIG_NR_CPUS=72.
> >> Then node 3 is not be created, because node 3 has no memory, and no cpu.
> >> But some pci device may related to node 3, which be set in ACPI table.
> >
> > Could you double check that zonelists for node 3 are generated
> > correctly?
> 
> The cpus in node 3 aren't onlined and there's no memory attached - I
> suspect that no zonelists are built for this node.
> 
> We skip creating a node, if the number of SRAT entries parsed exceeds
> NR_CPUS[0]. This in turn prevents onlining the numa node and so no
> zonelists will be created for it.
> 
> I think the problem will go away if the cpus are restricted via the
> kernel command line by setting nr_cpus.
> 
> Xie, can you try the below patch on top of the one enabling memoryless
> nodes? I'm not sure this is the right solution but at least it'll
> confirm the problem.

This issue looks familiar (or at least related):

git log d3bd058826aa

The reason why the NR_CPUS guard is there is to avoid overflowing
the early_node_cpu_hwid array. IA64 does something different in
that respect compared to x86, we have to have a look into this.

Regardless, AFAICS the proximity domains to nodes mappings should not
depend on CONFIG_NR_CPUS, it seems that there is something wrong in that
in ARM64 ACPI SRAT parsing.

Lorenzo

> 
> Thanks,
> Punit
> 
> [0] https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/arm64/kernel/acpi_numa.c?h=v4.18-rc1#n73
> 
> -- >8 --
> diff --git a/arch/arm64/kernel/acpi_numa.c b/arch/arm64/kernel/acpi_numa.c
> index d190a7b231bf..fea0f7164f1a 100644
> --- a/arch/arm64/kernel/acpi_numa.c
> +++ b/arch/arm64/kernel/acpi_numa.c
> @@ -70,11 +70,9 @@ void __init acpi_numa_gicc_affinity_init(struct acpi_srat_gicc_affinity *pa)
>         if (!(pa->flags & ACPI_SRAT_GICC_ENABLED))
>                 return;
> 
> -   if (cpus_in_srat >= NR_CPUS) {
> + if (cpus_in_srat >= NR_CPUS)
>                 pr_warn_once("SRAT: cpu_to_node_map[%d] is too small, may not be able to use all cpus\n",
>                              NR_CPUS);
> -           return;
> -   }
> 
>         pxm = pa->proximity_domain;
>         node = acpi_map_pxm_to_node(pxm);
