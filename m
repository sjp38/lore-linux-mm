Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id B10BB6B0275
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 18:21:35 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id z194so2504439wmd.3
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 15:21:35 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id t82si12944909wmf.132.2016.10.26.15.21.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Oct 2016 15:21:34 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id m83so442489wmc.0
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 15:21:33 -0700 (PDT)
Date: Thu, 27 Oct 2016 00:21:29 +0200
From: Robert Richter <rric@kernel.org>
Subject: Re: [PATCH 1/2] of, numa: Add function to disable of_node_to_nid().
Message-ID: <20161026222129.GW25086@rric.localdomain>
References: <1477431061-7258-1-git-send-email-ddaney.cavm@gmail.com>
 <1477431061-7258-2-git-send-email-ddaney.cavm@gmail.com>
 <20161026134301.GV25086@rric.localdomain>
 <5810E112.3070908@caviumnetworks.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5810E112.3070908@caviumnetworks.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Daney <ddaney@caviumnetworks.com>
Cc: devicetree@vger.kernel.org, David Daney <david.daney@cavium.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, Gilbert Netzer <noname@pdc.kth.se>, Rob Herring <robh+dt@kernel.org>, Hanjun Guo <hanjun.guo@linaro.org>, Ganapatrao Kulkarni <gkulkarni@caviumnetworks.com>, Frank Rowand <frowand.list@gmail.com>, linux-arm-kernel@lists.infradead.org, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org

There has been some significant rework around
__alloc_pages_nodemask(), adding Mel and linux-mm.

-Robert

On 26.10.16 10:00:02, David Daney wrote:
> On 10/26/2016 06:43 AM, Robert Richter wrote:
> >On 25.10.16 14:31:00, David Daney wrote:
> >>From: David Daney <david.daney@cavium.com>
> >>
> >>On arm64 NUMA kernels we can pass "numa=off" on the command line to
> >>disable NUMA.  A side effect of this is that kmalloc_node() calls to
> >>non-zero nodes will crash the system with an OOPS:
> >>
> >>[    0.000000] [<fffffc00081bba84>] __alloc_pages_nodemask+0xa4/0xe68
> >>[    0.000000] [<fffffc00082163a8>] new_slab+0xd0/0x57c
> >>[    0.000000] [<fffffc000821879c>] ___slab_alloc+0x2e4/0x514
> >>[    0.000000] [<fffffc000823882c>] __slab_alloc+0x48/0x58
> >>[    0.000000] [<fffffc00082195a0>] __kmalloc_node+0xd0/0x2e0
> >>[    0.000000] [<fffffc00081119b8>] __irq_domain_add+0x7c/0x164
> >>[    0.000000] [<fffffc0008b75d30>] its_probe+0x784/0x81c
> >>[    0.000000] [<fffffc0008b75e10>] its_init+0x48/0x1b0
> >>.
> >>.
> >>.
> >>
> >>This is caused by code like this in kernel/irq/irqdomain.c
> >>
> >>     domain = kzalloc_node(sizeof(*domain) + (sizeof(unsigned int) * size),
> >>                   GFP_KERNEL, of_node_to_nid(of_node));
> >>
> >>When NUMA is disabled, the concept of a node is really undefined, so
> >>of_node_to_nid() should unconditionally return NUMA_NO_NODE.
> >>
> >>Add __of_force_no_numa() to allow of_node_to_nid() to be forced to
> >>return NUMA_NO_NODE.
> >>
> >>The follow on patch will call this new function from the arm64 numa
> >>code.
> >
> >Didn't that work before?
> 
> I am fairly certain that it used to work.
> 
> >numa=off just maps all mem to node 0.
> 
> Yes, that is the current behavior.
> 
> >If mem
> >allocation is requested for another node it should just fall back to a
> >node with mem (node 0 then).
> 
> This is the root of the problem.  The ITS code is allocating memory. It
> calls of_node_to_nid() to determine which node it resides on.  The answer in
> the failing case is node-1.  Since we have mapped all the memory to node-0
> the  __kmalloc_node(..., 1) call fails with the OOPS shown.
> 
> It could be that __kmalloc_node() used to allocate memory on a node other
> than the requested node if the request couldn't be met.  But in v4.8 and
> later it produces that OOPS.
> 
> If you pass a node containing free memory or NUMA_NO_NODE to
> __kmalloc_node(), the allocation succeeds.
> 
> When we first did these patches, I advocated removing the numa=off feature,
> and requiring people to install usable firmware on their systems.  That was
> rejected on the grounds that not everybody has the ability to change their
> firmware and we would like to allow NUMA kernels to run on systems with
> defective firmware by supplying this command line parameter.  Now that I
> have seen requests from the wild for this, I think it is a good idea to
> allow numa=off to be used to work around this bad firmware.
> 
> The change in this patch set is fairly small, and seems to get the job done.
> An alternative would be to change __kmalloc_node() to ignore the node
> parameter if the request cannot be made, but I assume that there were good
> reasons to have the current behavior, so that would be a much more
> complicated change to make.
> 
> 
> 
> >I suspect there is something wrong with
> >the page initialization, see:
> >
> >  http://www.spinics.net/lists/arm-kernel/msg535191.html
> >  https://bugzilla.redhat.com/show_bug.cgi?id=1387793
> >
> >What is the complete oops?
> >
> >So I think k*alloc_node() must be able to handle requests to
> >non-existing nodes. Otherwise your fix is incomplete, assume a failed
> >of_numa_init() causing a dummy init but still some devices reporting a
> >node.
> 
> .
> .
> .
> EFI stub: Booting Linux Kernel...
> EFI stub: Using DTB from configuration table
> EFI stub: Exiting boot services and installing virtual address map...
> [    0.000000] Booting Linux on physical CPU 0x0
> [    0.000000] Linux version 4.8.0-rc8-dd (ddaney@localhost.localdomain)
> (gcc version 4.8.5 20150623 (Red Hat 4.8.5-11) (GCC) ) #29 SMP Tue Sep 27
> 15:50:35 PDT 2016
> [    0.000000] Boot CPU: AArch64 Processor [431f0a10]
> [    0.000000] NUMA turned off
> [    0.000000] earlycon: pl11 at MMIO 0x000087e024000000 (options '')
> [    0.000000] bootconsole [pl11] enabled
> [    0.000000] efi: Getting EFI parameters from FDT:
> [    0.000000] efi: EFI v2.40 by Cavium Thunder cn88xx EFI
> jenkins_weekly_build_40-0-ga1f880f Sep 13 2016 17:05:35
> [    0.000000] efi:  ACPI=0xfffff000  ACPI 2.0=0xfffff014  SMBIOS
> 3.0=0x10ffafcf000
> [    0.000000] cma: Reserved 512 MiB at 0x00000000c0000000
> [    0.000000] NUMA disabled
> [    0.000000] NUMA: Faking a node at [mem
> 0x0000000000000000-0x0000010fffffffff]
> [    0.000000] NUMA: Adding memblock [0x1400000 - 0xfffdffff] on node 0
> [    0.000000] NUMA: Adding memblock [0xfffe0000 - 0xffffffff] on node 0
> [    0.000000] NUMA: Adding memblock [0x100000000 - 0xfffffffff] on node 0
> [    0.000000] NUMA: Adding memblock [0x10000400000 - 0x10ffa38ffff] on node
> 0
> [    0.000000] NUMA: Adding memblock [0x10ffa390000 - 0x10ffa41ffff] on node
> 0
> [    0.000000] NUMA: Adding memblock [0x10ffa420000 - 0x10ffaeaffff] on node
> 0
> [    0.000000] NUMA: Adding memblock [0x10ffaeb0000 - 0x10ffaffffff] on node
> 0
> [    0.000000] NUMA: Adding memblock [0x10ffb000000 - 0x10ffffaffff] on node
> 0
> [    0.000000] NUMA: Adding memblock [0x10ffffb0000 - 0x10fffffffff] on node
> 0
> [    0.000000] NUMA: Initmem setup node 0 [mem 0x01400000-0x10fffffffff]
> [    0.000000] NUMA: NODE_DATA [mem 0x10ffffae480-0x10ffffaff7f]
> [    0.000000] Zone ranges:
> [    0.000000]   DMA      [mem 0x0000000001400000-0x00000000ffffffff]
> [    0.000000]   Normal   [mem 0x0000000100000000-0x0000010fffffffff]
> [    0.000000] Movable zone start for each node
> [    0.000000] Early memory node ranges
> [    0.000000]   node   0: [mem 0x0000000001400000-0x00000000fffdffff]
> [    0.000000]   node   0: [mem 0x00000000fffe0000-0x00000000ffffffff]
> [    0.000000]   node   0: [mem 0x0000000100000000-0x0000000fffffffff]
> [    0.000000]   node   0: [mem 0x0000010000400000-0x0000010ffa38ffff]
> [    0.000000]   node   0: [mem 0x0000010ffa390000-0x0000010ffa41ffff]
> [    0.000000]   node   0: [mem 0x0000010ffa420000-0x0000010ffaeaffff]
> [    0.000000]   node   0: [mem 0x0000010ffaeb0000-0x0000010ffaffffff]
> [    0.000000]   node   0: [mem 0x0000010ffb000000-0x0000010ffffaffff]
> [    0.000000]   node   0: [mem 0x0000010ffffb0000-0x0000010fffffffff]
> [    0.000000] Initmem setup node 0 [mem
> 0x0000000001400000-0x0000010fffffffff]
> [    0.000000] psci: probing for conduit method from DT.
> [    0.000000] psci: PSCIv0.2 detected in firmware.
> [    0.000000] psci: Using standard PSCI v0.2 function IDs
> [    0.000000] psci: Trusted OS resident on physical CPU 0x0
> [    0.000000] percpu: Embedded 3 pages/cpu @ffffff0ff6900000 s116736 r8192
> d71680 u196608
> [    0.000000] Detected VIPT I-cache on CPU0
> [    0.000000] CPU features: enabling workaround for Cavium erratum 27456
> [    0.000000] Built 1 zonelists in Node order, mobility grouping on. Total
> pages: 2094720
> [    0.000000] Policy zone: Normal
> [    0.000000] Kernel command line: BOOT_IMAGE=/vmlinuz-4.8.0-rc8-dd
> root=/dev/mapper/rhel-root ro crashkernel=auto rd.lvm.lv=rhel/root
> rd.lvm.lv=rhel/swap LANG=en_US.UTF-8 numa=off console=ttyAMA0,115200n8
> earlycon=pl011,0x87e024000000
> [    0.000000] log_buf_len individual max cpu contribution: 4096 bytes
> [    0.000000] log_buf_len total cpu_extra contributions: 389120 bytes
> [    0.000000] log_buf_len min size: 524288 bytes
> [    0.000000] log_buf_len: 1048576 bytes
> [    0.000000] early log buf free: 519176(99%)
> [    0.000000] PID hash table entries: 4096 (order: -1, 32768 bytes)
> [    0.000000] software IO TLB [mem 0xfbfd0000-0xfffd0000] (64MB) mapped at
> [fffffe00fbfd0000-fffffe00fffcffff]
> [    0.000000] Memory: 133391936K/134193152K available (7356K kernel code,
> 1359K rwdata, 3392K rodata, 1216K init, 6799K bss, 276928K reserved, 524288K
> cma-reserved)
> [    0.000000] Virtual kernel memory layout:
> [    0.000000]     modules : 0xfffffc0000000000 - 0xfffffc0008000000   (
> 128 MB)
> [    0.000000]     vmalloc : 0xfffffc0008000000 - 0xfffffdff5fff0000   (
> 2045 GB)
> [    0.000000]       .text : 0xfffffc0008080000 - 0xfffffc00087b0000   (
> 7360 KB)
> [    0.000000]     .rodata : 0xfffffc00087b0000 - 0xfffffc0008b10000   (
> 3456 KB)
> [    0.000000]       .init : 0xfffffc0008b10000 - 0xfffffc0008c40000   (
> 1216 KB)
> [    0.000000]       .data : 0xfffffc0008c40000 - 0xfffffc0008d93e00   (
> 1360 KB)
> [    0.000000]        .bss : 0xfffffc0008d93e00 - 0xfffffc0009437d48   (
> 6800 KB)
> [    0.000000]     fixed   : 0xfffffdff7e7d0000 - 0xfffffdff7ec00000   (
> 4288 KB)
> [    0.000000]     PCI I/O : 0xfffffdff7ee00000 - 0xfffffdff7fe00000   (
> 16 MB)
> [    0.000000]     vmemmap : 0xfffffdff80000000 - 0xfffffe0000000000   (
> 2 GB maximum)
> [    0.000000]               0xfffffdff80005000 - 0xfffffdffc4000000   (
> 1087 MB actual)
> [    0.000000]     memory  : 0xfffffe0001400000 - 0xffffff1000000000
> (1114092 MB)
> [    0.000000] SLUB: HWalign=128, Order=0-3, MinObjects=0, CPUs=96, Nodes=1
> [    0.000000] Hierarchical RCU implementation.
> [    0.000000] 	Build-time adjustment of leaf fanout to 64.
> [    0.000000] 	RCU restricting CPUs from NR_CPUS=4096 to nr_cpu_ids=96.
> [    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=64, nr_cpu_ids=96
> [    0.000000] NR_IRQS:64 nr_irqs:64 0
> [    0.000000] GICv3: GIC: Using split EOI/Deactivate mode
> [    0.000000] ITS: /interrupt-controller@801000000000/gic-its@801000020000
> [    0.000000] ITS@0x0000801000020000: allocated 2097152 Devices
> @10001000000 (flat, esz 8, psz 64K, shr 1)
> [    0.000000] ITS: /interrupt-controller@801000000000/gic-its@901000020000
> [    0.000000] ITS@0x0000901000020000: allocated 2097152 Devices
> @10002000000 (flat, esz 8, psz 64K, shr 1)
> [    0.000000] Unable to handle kernel NULL pointer dereference at virtual
> address 00001680
> [    0.000000] pgd = fffffc0009470000
> [    0.000000] [00001680] *pgd=0000010ffff90003, *pud=0000010ffff90003,
> *pmd=0000010ffff90003, *pte=0000000000000000
> [    0.000000] Internal error: Oops: 96000006 [#1] SMP
> [    0.000000] Modules linked in:
> [    0.000000] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.8.0-rc8-dd #29
> [    0.000000] Hardware name: Cavium ThunderX CN88XX board (DT)
> [    0.000000] task: fffffc0008c71c80 task.stack: fffffc0008c40000
> [    0.000000] PC is at __alloc_pages_nodemask+0xa4/0xe68
> [    0.000000] LR is at __alloc_pages_nodemask+0x38/0xe68
> [    0.000000] pc : [<fffffc00081c8950>] lr : [<fffffc00081c88e4>] pstate:
> 600000c5
> [    0.000000] sp : fffffc0008c43880
> [    0.000000] x29: fffffc0008c43880 x28: ffffff000041fc00
> [    0.000000] x27: 0000000000201200 x26: 0000000000000000
> [    0.000000] x25: 0000000000000001 x24: 0000000000001680
> [    0.000000] x23: 0000000000201200 x22: fffffc0008c439c8
> [    0.000000] x21: fffffc0008c63000 x20: 0000000000201200
> [    0.000000] x19: 0000000000000000 x18: 0000000000000070
> [    0.000000] x17: 0000000000000008 x16: 0000000000000000
> [    0.000000] x15: 0000000000000000 x14: 2820303030303030
> [    0.000000] x13: 3230303031402073 x12: 6563697665442032
> [    0.000000] x11: 0000000000000020 x10: fffffc0009334000
> [    0.000000] x9 : 0000000001bfff3f x8 : 7f7f7f7f7f7f7f7f
> [    0.000000] x7 : 0000000001210111 x6 : fffffdffc00010a0
> [    0.000000] x5 : 0000000000000000 x4 : 0000000000000000
> [    0.000000] x3 : 0000000000000000 x2 : 0000000000000000
> [    0.000000] x1 : 0000000000000000 x0 : fffffc0008c63bb0
> [    0.000000]
> [    0.000000] Process swapper/0 (pid: 0, stack limit = 0xfffffc0008c40020)
> [    0.000000] Stack: (0xfffffc0008c43880 to 0xfffffc0008c44000)
> [    0.000000] 3880: fffffc0008c439f0 fffffc000821fa70 ffffff000041fc00
> 0000000000000200
> [    0.000000] 38a0: fffffc0008115374 0000000000000000 0000000000000000
> 0000000000000001
> [    0.000000] 38c0: 0000000000000000 0000000000000000 0000000000201200
> ffffff000041fc00
> [    0.000000] 38e0: fffffc0008c43960 fffffc000810bc20 fffffc0008c43960
> fffffc0008c43960
> [    0.000000] 3900: fffffc0008c43930 00000000ffffffd0 fffffc0008c43960
> fffffc0008c43960
> [    0.000000] 3920: fffffc0008c43930 00000000ffffffd0 fffffc0008c43970
> fffffc0008221658
> [    0.000000] 3940: 7f7f7f7f7f7f7f7f 0000000000000002 0101010101010101
> 0000000000000020
> [    0.000000] 3960: fffffc0008c43a70 fffffc0008221c04 0000000000000001
> 00000000024080c0
> [    0.000000] 3980: fffffc0008115374 fffffc0008bf8648 0000000000001000
> 0000000000000000
> [    0.000000] 39a0: ffffff000041fc00 0000000000000001 ffffff0ff691e840
> ffffff000041fc00
> [    0.000000] 39c0: ffffff0ff691e840 0000000000001680 0000000000000000
> 0000000000000000
> [    0.000000] 39e0: 0000000100000000 0000000000000000 fffffc0008c43a70
> fffffc0008221e24
> [    0.000000] 3a00: 0000000000000001 00000000024080c0 fffffc0008115374
> fffffc0008bf8648
> [    0.000000] 3a20: 0000000000001000 0000000000000000 0000000000000000
> 0000000000000001
> [    0.000000] 3a40: ffffff0ff691e840 ffffff000041fc00 fffffc000928a1e8
> 024080c000000006
> [    0.000000] 3a60: fffffc0008ca6a38 000000000000005c fffffc0008c43b90
> fffffc0008239498
> [    0.000000] 3a80: 00000000000000c0 ffffff000041fc00 ffffff0000424f00
> 0000000000000070
> [    0.000000] 3aa0: 0000000000000001 fffffc0008115374 ffffff000041fc00
> fffffc00093f1000
> [    0.000000] 3ac0: ffffff0002000000 ffffff0000433000 fffffc0008c43bd0
> fffffc0008a308f0
> [    0.000000] 3ae0: 0000000000010000 0000020000000000 0000000000000000
> 0000000000000001
> [    0.000000] 3b00: fffffc0008c43b30 fffffc000861f07c fffffc000941efc0
> 00000000000000c0
> [    0.000000] 3b20: ffffff0ffff44e60 00000000000000c0 fffffc0008c43b70
> fffffc000861f234
> [    0.000000] 3b40: ffffff0ffff44e60 0000000000000004 ffffff0ffff44e60
> fffffc0008c43c70
> [    0.000000] 3b60: 0000000000000000 fffffc0008a74460 fffffc0008c43ba0
> fffffc000861f3fc
> [    0.000000] 3b80: fffffc0008c43ba0 fffffc00083ca55c fffffc0008c43bd0
> fffffc0008222c20
> [    0.000000] 3ba0: ffffff000041fc00 00000000024080c0 ffffff0ff691e840
> fffffc0008115374
> [    0.000000] 3bc0: 0000000000000001 00000000024080c0 fffffc0008c43c20
> fffffc0008115374
> [    0.000000] 3be0: 0000000000000070 ffffff0ffff44e80 ffffff0ffff44e60
> 0000000000000000
> [    0.000000] 3c00: fffffc0008849a18 ffffffffffffffff 0000000000000000
> ffffff0000433000
> [    0.000000] 3c20: fffffc0008c43c80 fffffc0008b461dc ffffff0000424e80
> 2800000000000000
> [    0.000000] 3c40: 0000000000010000 0000020000000000 0000000000000000
> 0000000000000400
> [    0.000000] 3c60: 0000000000000400 ffffff00004330f8 0000000000000001
> ffffff0ffffabe00
> [    0.000000] 3c80: fffffc0008c43dc0 fffffc0008b462bc fffffc0008d33488
> fffffc0008d33000
> [    0.000000] 3ca0: ffffff0ffff44e60 fffffc0008c6c840 ffffff0000424b00
> ffffff0000424880
> [    0.000000] 3cc0: 0000000000000002 0000000000000000 0000000001bae074
> 0000000001f1001c
> [    0.000000] 3ce0: 0000000000000000 fffffc0008a30890 ffffff0000424b00
> fffffc0008849940
> [    0.000000] 3d00: ffffff0000433020 fffffc0008a308f0 ffffff0000433008
> ffffff0ffff44e60
> [    0.000000] 3d20: fffffc000ac00000 0000000000000008 0000000000000001
> 8107000000000000
> [    0.000000] 3d40: 00000000000000c0 0000000001000000 00000008fff44e60
> 0000010002000000
> [    0.000000] 3d60: 0000000000000100 81070000000000ff fffffc0008c43dc0
> 0000000008b462cc
> [    0.000000] 3d80: 0000901000020000 000090100021ffff ffffff0ffff44f08
> 0000000000000200
> [    0.000000] 3da0: 0000000000000000 0000000000000000 0000000000000000
> 0000000000000000
> [    0.000000] 3dc0: fffffc0008c43e10 fffffc0008b4543c fffffc0008c6c828
> fffffc0008d32000
> [    0.000000] 3de0: fffffc0008c6c000 ffffff0ffff44470 fffffc0008849000
> ffffff0000424880
> [    0.000000] 3e00: fffffc0008c43e10 fffffc0008b45420 fffffc0008c43e60
> fffffc0008b456bc
> [    0.000000] 3e20: 0000000000000002 0000000000000003 0000000000000030
> ffffff0000424880
> [    0.000000] 3e40: ffffff0ffff44470 0000000000000000 0000000000000018
> fffffc0008000000
> [    0.000000] 3e60: fffffc0008c43f00 fffffc0008b5aec8 ffffff0000424700
> fffffc0008c43f60
> [    0.000000] 3e80: fffffc0008c43f60 0000000000000000 fffffc0008c43f70
> fffffc0008d92000
> [    0.000000] 3ea0: fffffc0008a734e0 fffffc0008a734b8 fffffc0008c43f00
> 0000000208b5ae3c
> [    0.000000] 3ec0: 0000000000000000 00009010805fffff ffffff0ffff44518
> 0000000000000200
> [    0.000000] 3ee0: 0000000000000000 0000000000000000 0000000000000000
> 0000000000000000
> [    0.000000] 3f00: fffffc0008c43f80 fffffc0008b43f9c fffffc0008c60000
> fffffc0008b66628
> [    0.000000] 3f20: fffffc0008b66628 fffffc0008dc0000 fffffc0008c60000
> ffffff0ffffac580
> [    0.000000] 3f40: 0000000002840000 0000000002870000 0000000000000020
> 0000000000000000
> [    0.000000] 3f60: fffffc0008c43f60 fffffc0008c43f60 fffffc0008c43f70
> fffffc0008c43f70
> [    0.000000] 3f80: fffffc0008c43f90 fffffc0008b12d60 fffffc0008c43fa0
> fffffc0008b10a3c
> [    0.000000] 3fa0: 0000000000000000 fffffc0008b101c4 0000010ff7a35218
> 0000000000000e12
> [    0.000000] 3fc0: 0000000021200000 0000000030d00980 0000000000000000
> 0000000001400000
> [    0.000000] 3fe0: 0000000000000000 fffffc0008b66628 0000000000000000
> 0000000000000000
> [    0.000000] Call trace:
> [    0.000000] Exception stack(0xfffffc0008c436b0 to 0xfffffc0008c437e0)
> [    0.000000] 36a0:                                   0000000000000000
> 0000040000000000
> [    0.000000] 36c0: fffffc0008c43880 fffffc00081c8950 ffffff0ffffaf180
> 0000000000000003
> [    0.000000] 36e0: fffffc0008c63000 00000000ffffffff 0000000000000001
> 0000000000000000
> [    0.000000] 3700: fffffc0008c43720 fffffc00081e25cc 0000000000000000
> 0000000001bfff3f
> [    0.000000] 3720: fffffc0008c43750 fffffc00081c8454 0000000000000012
> 0000000000000000
> [    0.000000] 3740: fffffffffffffff8 0000000000000012 fffffc0008c63bb0
> 0000000000000000
> [    0.000000] 3760: 0000000000000000 0000000000000000 0000000000000000
> 0000000000000000
> [    0.000000] 3780: fffffdffc00010a0 0000000001210111 7f7f7f7f7f7f7f7f
> 0000000001bfff3f
> [    0.000000] 37a0: fffffc0009334000 0000000000000020 6563697665442032
> 3230303031402073
> [    0.000000] 37c0: 2820303030303030 0000000000000000 0000000000000000
> 0000000000000008
> [    0.000000] [<fffffc00081c8950>] __alloc_pages_nodemask+0xa4/0xe68
> [    0.000000] [<fffffc000821fa70>] new_slab+0xd0/0x564
> [    0.000000] [<fffffc0008221e24>] ___slab_alloc+0x2e4/0x514
> [    0.000000] [<fffffc0008239498>] __slab_alloc+0x48/0x58
> [    0.000000] [<fffffc0008222c20>] __kmalloc_node+0xd0/0x2dc
> [    0.000000] [<fffffc0008115374>] __irq_domain_add+0x7c/0x164
> [    0.000000] [<fffffc0008b461dc>] its_probe+0x784/0x81c
> [    0.000000] [<fffffc0008b462bc>] its_init+0x48/0x1b0
> [    0.000000] [<fffffc0008b4543c>] gic_init_bases+0x228/0x360
> [    0.000000] [<fffffc0008b456bc>] gic_of_init+0x148/0x1cc
> [    0.000000] [<fffffc0008b5aec8>] of_irq_init+0x184/0x298
> [    0.000000] [<fffffc0008b43f9c>] irqchip_init+0x14/0x38
> [    0.000000] [<fffffc0008b12d60>] init_IRQ+0xc/0x30
> [    0.000000] [<fffffc0008b10a3c>] start_kernel+0x240/0x3b8
> [    0.000000] [<fffffc0008b101c4>] __primary_switched+0x30/0x6c
> [    0.000000] Code: 912ec2a0 b9403809 0a0902fb 37b007db (f9400300)
> [    0.000000] ---[ end trace 0000000000000000 ]---
> [    0.000000] Kernel panic - not syncing: Fatal exception
> [    0.000000] ---[ end Kernel panic - not syncing: Fatal exception
> 
> 
> Same thing on v4.8.x and v4.9-rc?
> 
> 
> 
> 
> >
> >-Robert
> >
> 
> 
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
