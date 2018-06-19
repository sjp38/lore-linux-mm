Return-Path: <linux-kernel-owner@vger.kernel.org>
Subject: Re: [PATCH 1/2] arm64: avoid alloc memory on offline node
References: <5ed798a0-6c9c-086e-e5e8-906f593ca33e@huawei.com>
 <20180607122152.GP32433@dhcp22.suse.cz>
 <a880df29-b656-d98d-3037-b04761c7ed78@huawei.com>
 <20180611085237.GI13364@dhcp22.suse.cz>
 <16c4db2f-bc70-d0f2-fb38-341d9117ff66@huawei.com>
 <20180611134303.GC75679@bhelgaas-glaptop.roam.corp.google.com>
 <20180611145330.GO13364@dhcp22.suse.cz>
 <87lgbk59gs.fsf@e105922-lin.cambridge.arm.com>
 <87bmce60y3.fsf@e105922-lin.cambridge.arm.com>
 <8b715082-14d4-f10b-d2d6-b23be7e4bf7e@huawei.com>
 <20180619120714.GE13685@dhcp22.suse.cz>
From: Xie XiuQi <xiexiuqi@huawei.com>
Message-ID: <1f5ec805-483d-8781-7bc9-4d040d4a33ce@huawei.com>
Date: Tue, 19 Jun 2018 20:40:03 +0800
MIME-Version: 1.0
In-Reply-To: <20180619120714.GE13685@dhcp22.suse.cz>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: linux-kernel-owner@vger.kernel.org
To: Michal Hocko <mhocko@kernel.org>
Cc: Punit Agrawal <punit.agrawal@arm.com>, Hanjun Guo <guohanjun@huawei.com>, Bjorn Helgaas <helgaas@kernel.org>, tnowicki@caviumnetworks.com, linux-pci@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Will Deacon <will.deacon@arm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Jarkko Sakkinen <jarkko.sakkinen@linux.intel.com>, linux-mm@kvack.org, wanghuiqiang@huawei.com, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Bjorn Helgaas <bhelgaas@google.com>, Andrew Morton <akpm@linux-foundation.org>, zhongjiang <zhongjiang@huawei.com>, linux-arm <linux-arm-kernel@lists.infradead.org>
List-ID: <linux-mm.kvack.org>

Hi Michal,

On 2018/6/19 20:07, Michal Hocko wrote:
> On Tue 19-06-18 20:03:07, Xie XiuQi wrote:
> [...]
>> I tested on a arm board with 128 cores 4 numa nodes, but I set CONFIG_NR_CPUS=72.
>> Then node 3 is not be created, because node 3 has no memory, and no cpu.
>> But some pci device may related to node 3, which be set in ACPI table.
> 
> Could you double check that zonelists for node 3 are generated
> correctly?
> 

zonelists for node 3 is not created at all.

Kernel parse SRAT table to create node info, but in this case,
SRAT table is parsed not completed. Only the first 72 items are parsed.
In SRAT table, we haven't seen node 3 information yet, because cpu_to_node_map[72] is too small.

[    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x30000 -> Node 0
[    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x30001 -> Node 0
[    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x30002 -> Node 0
[    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x30003 -> Node 0
[    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x30100 -> Node 0
[    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x30101 -> Node 0
[    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x30102 -> Node 0
[    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x30103 -> Node 0
[    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x30200 -> Node 0
[    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x30201 -> Node 0
[    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x30202 -> Node 0
[    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x30203 -> Node 0
[    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x30300 -> Node 0
[    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x30301 -> Node 0
[    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x30302 -> Node 0
[    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x30303 -> Node 0
[    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x30400 -> Node 0
[    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x30401 -> Node 0
[    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x30402 -> Node 0
[    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x30403 -> Node 0
[    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x30500 -> Node 0
[    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x30501 -> Node 0
[    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x30502 -> Node 0
[    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x30503 -> Node 0
[    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x30600 -> Node 0
[    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x30601 -> Node 0
[    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x30602 -> Node 0
[    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x30603 -> Node 0
[    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x30700 -> Node 0
[    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x30701 -> Node 0
[    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x30702 -> Node 0
[    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x30703 -> Node 0
[    0.000000] ACPI: NUMA: SRAT: PXM 1 -> MPIDR 0x10000 -> Node 1
[    0.000000] ACPI: NUMA: SRAT: PXM 1 -> MPIDR 0x10001 -> Node 1
[    0.000000] ACPI: NUMA: SRAT: PXM 1 -> MPIDR 0x10002 -> Node 1
[    0.000000] ACPI: NUMA: SRAT: PXM 1 -> MPIDR 0x10003 -> Node 1
[    0.000000] ACPI: NUMA: SRAT: PXM 1 -> MPIDR 0x10100 -> Node 1
[    0.000000] ACPI: NUMA: SRAT: PXM 1 -> MPIDR 0x10101 -> Node 1
[    0.000000] ACPI: NUMA: SRAT: PXM 1 -> MPIDR 0x10102 -> Node 1
[    0.000000] ACPI: NUMA: SRAT: PXM 1 -> MPIDR 0x10103 -> Node 1
[    0.000000] ACPI: NUMA: SRAT: PXM 1 -> MPIDR 0x10200 -> Node 1
[    0.000000] ACPI: NUMA: SRAT: PXM 1 -> MPIDR 0x10201 -> Node 1
[    0.000000] ACPI: NUMA: SRAT: PXM 1 -> MPIDR 0x10202 -> Node 1
[    0.000000] ACPI: NUMA: SRAT: PXM 1 -> MPIDR 0x10203 -> Node 1
[    0.000000] ACPI: NUMA: SRAT: PXM 1 -> MPIDR 0x10300 -> Node 1
[    0.000000] ACPI: NUMA: SRAT: PXM 1 -> MPIDR 0x10301 -> Node 1
[    0.000000] ACPI: NUMA: SRAT: PXM 1 -> MPIDR 0x10302 -> Node 1
[    0.000000] ACPI: NUMA: SRAT: PXM 1 -> MPIDR 0x10303 -> Node 1
[    0.000000] ACPI: NUMA: SRAT: PXM 1 -> MPIDR 0x10400 -> Node 1
[    0.000000] ACPI: NUMA: SRAT: PXM 1 -> MPIDR 0x10401 -> Node 1
[    0.000000] ACPI: NUMA: SRAT: PXM 1 -> MPIDR 0x10402 -> Node 1
[    0.000000] ACPI: NUMA: SRAT: PXM 1 -> MPIDR 0x10403 -> Node 1
[    0.000000] ACPI: NUMA: SRAT: PXM 1 -> MPIDR 0x10500 -> Node 1
[    0.000000] ACPI: NUMA: SRAT: PXM 1 -> MPIDR 0x10501 -> Node 1
[    0.000000] ACPI: NUMA: SRAT: PXM 1 -> MPIDR 0x10502 -> Node 1
[    0.000000] ACPI: NUMA: SRAT: PXM 1 -> MPIDR 0x10503 -> Node 1
[    0.000000] ACPI: NUMA: SRAT: PXM 1 -> MPIDR 0x10600 -> Node 1
[    0.000000] ACPI: NUMA: SRAT: PXM 1 -> MPIDR 0x10601 -> Node 1
[    0.000000] ACPI: NUMA: SRAT: PXM 1 -> MPIDR 0x10602 -> Node 1
[    0.000000] ACPI: NUMA: SRAT: PXM 1 -> MPIDR 0x10603 -> Node 1
[    0.000000] ACPI: NUMA: SRAT: PXM 1 -> MPIDR 0x10700 -> Node 1
[    0.000000] ACPI: NUMA: SRAT: PXM 1 -> MPIDR 0x10701 -> Node 1
[    0.000000] ACPI: NUMA: SRAT: PXM 1 -> MPIDR 0x10702 -> Node 1
[    0.000000] ACPI: NUMA: SRAT: PXM 1 -> MPIDR 0x10703 -> Node 1
[    0.000000] ACPI: NUMA: SRAT: PXM 2 -> MPIDR 0x70000 -> Node 2
[    0.000000] ACPI: NUMA: SRAT: PXM 2 -> MPIDR 0x70001 -> Node 2
[    0.000000] ACPI: NUMA: SRAT: PXM 2 -> MPIDR 0x70002 -> Node 2
[    0.000000] ACPI: NUMA: SRAT: PXM 2 -> MPIDR 0x70003 -> Node 2
[    0.000000] ACPI: NUMA: SRAT: PXM 2 -> MPIDR 0x70100 -> Node 2
[    0.000000] ACPI: NUMA: SRAT: PXM 2 -> MPIDR 0x70101 -> Node 2
[    0.000000] ACPI: NUMA: SRAT: PXM 2 -> MPIDR 0x70102 -> Node 2
[    0.000000] ACPI: NUMA: SRAT: PXM 2 -> MPIDR 0x70103 -> Node 2
[    0.000000] ACPI: NUMA: SRAT: cpu_to_node_map[72] is too small, may not be able to use all cpus
[    0.000000] ACPI: SRAT: Node 0 PXM 0 [mem 0x2080000000-0x23ffffffff]
[    0.000000] ACPI: SRAT: Node 0 PXM 0 [mem 0x00000000-0x7fffffff]
[    0.000000] ACPI: SRAT: Node 2 PXM 2 [mem 0x402000000000-0x4023ffffffff]
[    0.000000] NUMA: NODE_DATA [mem 0x23ffffe780-0x23ffffffff]
[    0.000000] NUMA: Initmem setup node 1 [<memory-less node>]
[    0.000000] NUMA: NODE_DATA [mem 0x4023fffed780-0x4023fffeefff]
[    0.000000] NUMA: NODE_DATA(1) on node 2
[    0.000000] NUMA: NODE_DATA [mem 0x4023fffebf00-0x4023fffed77f]
[    0.000000] Zone ranges:
[    0.000000]   DMA32    [mem 0x0000000000000000-0x00000000ffffffff]
[    0.000000]   Normal   [mem 0x0000000100000000-0x00004023ffffffff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000000000000-0x000000003942ffff]
[    0.000000]   node   0: [mem 0x0000000039430000-0x000000003956ffff]
[    0.000000]   node   0: [mem 0x0000000039570000-0x000000003963ffff]
[    0.000000]   node   0: [mem 0x0000000039640000-0x00000000396fffff]
[    0.000000]   node   0: [mem 0x0000000039700000-0x000000003971ffff]
[    0.000000]   node   0: [mem 0x0000000039720000-0x0000000039b6ffff]
[    0.000000]   node   0: [mem 0x0000000039b70000-0x000000003eb5ffff]
[    0.000000]   node   0: [mem 0x000000003eb60000-0x000000003eb8ffff]
[    0.000000]   node   0: [mem 0x000000003eb90000-0x000000003fbfffff]
[    0.000000]   node   0: [mem 0x0000002080000000-0x00000023ffffffff]
[    0.000000]   node   2: [mem 0x0000402000000000-0x00004023ffffffff]
[    0.000000] Initmem setup node 0 [mem 0x0000000000000000-0x00000023ffffffff]
[    0.000000] Could not find start_pfn for node 1
[    0.000000] Initmem setup node 1 [mem 0x0000000000000000-0x0000000000000000]
[    0.000000] Initmem setup node 2 [mem 0x0000402000000000-0x00004023ffffffff]



-- 
Thanks,
Xie XiuQi
