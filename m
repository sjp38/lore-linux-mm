Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8BBA76B0007
	for <linux-mm@kvack.org>; Wed,  4 Jul 2018 00:51:02 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id c19-v6so1717093edt.4
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 21:51:02 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id y8-v6si2572896edk.335.2018.07.03.21.51.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jul 2018 21:51:00 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w644miv5080655
	for <linux-mm@kvack.org>; Wed, 4 Jul 2018 00:50:58 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2k0k43ry9q-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 04 Jul 2018 00:50:58 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 4 Jul 2018 05:50:56 +0100
Date: Wed, 4 Jul 2018 07:50:48 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/3] m68k: switch to MEMBLOCK + NO_BOOTMEM
References: <1530613795-6956-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1530613795-6956-4-git-send-email-rppt@linux.vnet.ibm.com>
 <5388c6eb-2159-b103-51f9-2a211c54b4bc@linux-m68k.org>
 <0614f397-d9c9-cc99-69bc-25b7d0361af4@linux-m68k.org>
 <20180704042221.GG4809@rapoport-lnx>
 <6403bb73-2c86-cf44-180e-58019b776ca3@linux-m68k.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6403bb73-2c86-cf44-180e-58019b776ca3@linux-m68k.org>
Message-Id: <20180704045047.GH4809@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Ungerer <gerg@linux-m68k.org>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>, Sam Creasey <sammy@sammy.net>, Michal Hocko <mhocko@kernel.org>, linux-m68k@lists.linux-m68k.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Greg,

On Wed, Jul 04, 2018 at 02:39:05PM +1000, Greg Ungerer wrote:
> Hi Mike,
> 
> On 04/07/18 14:22, Mike Rapoport wrote:
> >On Wed, Jul 04, 2018 at 12:02:52PM +1000, Greg Ungerer wrote:
> >>On 04/07/18 11:39, Greg Ungerer wrote:
> >>>On 03/07/18 20:29, Mike Rapoport wrote:
> >>>>In m68k the physical memory is described by [memory_start, memory_end] for
> >>>>!MMU variant and by m68k_memory array of memory ranges for the MMU version.
> >>>>This information is directly used to register the physical memory with
> >>>>memblock.
> >>>>
> >>>>The reserve_bootmem() calls are replaced with memblock_reserve() and the
> >>>>bootmap bitmap allocation is simply dropped.
> >>>>
> >>>>Since the MMU variant creates early mappings only for the small part of the
> >>>>memory we force bottom-up allocations in memblock because otherwise we will
> >>>>attempt to access memory that not yet mapped
> >>>>
> >>>>Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> >>>
> >>>This builds cleanly for me with a m5475_defconfig, but it fails
> >>>to boot on real hardware. No console, no nothing on startup.
> >>>I haven't debugged any further yet.
> >>>
> >>>The M5475 is a ColdFire with MMU enabled target.
> >>
> >>With some early serial debug trace I see:
> >>
> >>Linux version 4.18.0-rc3-00003-g109f5e551b18-dirty (gerg@goober) (gcc version 5.4.0 (GCC)) #5 Wed Jul 4 12:00:03 AEST 2018
> >>On node 0 totalpages: 4096
> >>   DMA zone: 18 pages used for memmap
> >>   DMA zone: 0 pages reserved
> >>   DMA zone: 4096 pages, LIFO batch:0
> >>pcpu-alloc: s0 r0 d32768 u32768 alloc=1*32768
> >>pcpu-alloc: [0] 0
> >>Built 1 zonelists, mobility grouping off.  Total pages: 4078
> >>Kernel command line: root=/dev/mtdblock0
> >>Dentry cache hash table entries: 4096 (order: 1, 16384 bytes)
> >>Inode-cache hash table entries: 2048 (order: 0, 8192 bytes)
> >>Sorting __ex_table...
> >>Memory: 3032K/32768K available (1489K kernel code, 96K rwdata, 240K rodata, 56K init, 77K bss, 29736K reserved, 0K cma-reserved)
> >                                                                                                  ^^^^^^
> >It seems I was over enthusiastic when I reserved the memory for the kernel.
> >Can you please try with the below patch:
> >
> >diff --git a/arch/m68k/mm/mcfmmu.c b/arch/m68k/mm/mcfmmu.c
> >index e9e60e1..18c7bf6 100644
> >--- a/arch/m68k/mm/mcfmmu.c
> >+++ b/arch/m68k/mm/mcfmmu.c
> >@@ -174,7 +174,7 @@ void __init cf_bootmem_alloc(void)
> >  	high_memory = (void *)_ramend;
> >  	/* Reserve kernel text/data/bss */
> >-	memblock_reserve(memstart, _ramend - memstart);
> >+	memblock_reserve(memstart, memstart - _rambase);
> >  	m68k_virt_to_node_shift = fls(_ramend - 1) - 6;
> >  	module_fixup(NULL, __start_fixup, __stop_fixup);
> >diff --git a/mm/memblock.c b/mm/memblock.c
> >index 03d48d8..98661be 100644
> >--- a/mm/memblock.c
> >+++ b/mm/memblock.c
> >@@ -54,7 +54,7 @@ struct memblock memblock __initdata_memblock = {
> >  	.current_limit		= MEMBLOCK_ALLOC_ANYWHERE,
> >  };
> >-int memblock_debug __initdata_memblock;
> >+int memblock_debug __initdata_memblock = 1;
> >  static bool system_has_some_mirror __initdata_memblock = false;
> >  static int memblock_can_resize __initdata_memblock;
> >  static int memblock_memory_in_slab __initdata_memblock = 0;
> >
> >
> >The memblock hunk is needed to see early memblock debug messages as all the
> >setup happens before parsing of the command line.
> 
> Ok, that works, boots all the way up now.

Thanks for testing. 
I'll send v2 later on today.
 
> Linux version 4.18.0-rc3-00003-g109f5e551b18-dirty (gerg@goober) (gcc version 5.4.0 (GCC)) #7 Wed Jul 4 14:34:48 AEST 2018
> memblock_add: [0x00000000-0x01ffffff] 0x001ebaa0
> memblock_reserve: [0x00332000-0x00663fff] 0x001ebafa
> memblock_reserve: [0x01ffe000-0x01ffffff] 0x001efd38
> memblock_reserve: [0x01ff8000-0x01ffdfff] 0x001efd38
> memblock_virt_alloc_try_nid_nopanic: 147456 bytes align=0x0 nid=0 from=0x0 max_addr=0x0 0x00190dea
> memblock_reserve: [0x01fd4000-0x01ff7fff] 0x001f0466
> memblock_virt_alloc_try_nid_nopanic: 4 bytes align=0x0 nid=0 from=0x0 max_addr=0x0 0x001ee234
> memblock_reserve: [0x01fd3ff0-0x01fd3ff3] 0x001f0466
> memblock_virt_alloc_try_nid: 20 bytes align=0x0 nid=-1 from=0x0 max_addr=0x0 0x001ea488
> memblock_reserve: [0x01fd3fd0-0x01fd3fe3] 0x001f0466
> memblock_virt_alloc_try_nid: 20 bytes align=0x0 nid=-1 from=0x0 max_addr=0x0 0x001ea4a8
> memblock_reserve: [0x01fd3fb0-0x01fd3fc3] 0x001f0466
> memblock_virt_alloc_try_nid: 20 bytes align=0x0 nid=-1 from=0x0 max_addr=0x0 0x001ea4c0
> memblock_reserve: [0x01fd3f90-0x01fd3fa3] 0x001f0466
> memblock_virt_alloc_try_nid_nopanic: 8192 bytes align=0x2000 nid=-1 from=0x0 max_addr=0x0 0x001eef30
> memblock_reserve: [0x01fd0000-0x01fd1fff] 0x001f0466
> memblock_virt_alloc_try_nid_nopanic: 32768 bytes align=0x2000 nid=-1 from=0x0 max_addr=0x0 0x001ef5d6
> memblock_reserve: [0x01fc8000-0x01fcffff] 0x001f0466
> memblock_virt_alloc_try_nid: 4 bytes align=0x0 nid=-1 from=0x0 max_addr=0x0 0x001ef2ac
> memblock_reserve: [0x01fd3f80-0x01fd3f83] 0x001f0466
> memblock_virt_alloc_try_nid: 4 bytes align=0x0 nid=-1 from=0x0 max_addr=0x0 0x001ef2c2
> memblock_reserve: [0x01fd3f70-0x01fd3f73] 0x001f0466
> memblock_virt_alloc_try_nid: 4 bytes align=0x0 nid=-1 from=0x0 max_addr=0x0 0x001ef2d6
> memblock_reserve: [0x01fd3f60-0x01fd3f63] 0x001f0466
> memblock_virt_alloc_try_nid: 4 bytes align=0x0 nid=-1 from=0x0 max_addr=0x0 0x001ef2e6
> memblock_reserve: [0x01fd3f50-0x01fd3f53] 0x001f0466
> memblock_virt_alloc_try_nid: 120 bytes align=0x0 nid=-1 from=0x0 max_addr=0x0 0x001ef506
> memblock_reserve: [0x01fd3ed0-0x01fd3f47] 0x001f0466
> memblock_virt_alloc_try_nid: 67 bytes align=0x0 nid=-1 from=0x0 max_addr=0x0 0x001eece0
> memblock_reserve: [0x01fd3e80-0x01fd3ec2] 0x001f0466
> memblock_virt_alloc_try_nid: 1024 bytes align=0x0 nid=-1 from=0x0 max_addr=0x0 0x001eed0e
> memblock_reserve: [0x01fd3a80-0x01fd3e7f] 0x001f0466
> memblock_virt_alloc_try_nid: 1028 bytes align=0x0 nid=-1 from=0x0 max_addr=0x0 0x001eed2c
> memblock_reserve: [0x01fd3670-0x01fd3a73] 0x001f0466
> memblock_virt_alloc_try_nid: 80 bytes align=0x0 nid=-1 from=0x0 max_addr=0x0 0x001eed4e
> memblock_reserve: [0x01fd3620-0x01fd366f] 0x001f0466
> __memblock_free_early: [0x00000001fd0000-0x00000001fd1fff] 0x001eef80
> Built 1 zonelists, mobility grouping off.  Total pages: 4078
> Kernel command line: root=/dev/mtdblock0
> memblock_virt_alloc_try_nid_nopanic: 16384 bytes align=0x0 nid=-1 from=0x0 max_addr=0x0 0x001ee828
> memblock_reserve: [0x01fc4000-0x01fc7fff] 0x001f0466
> Dentry cache hash table entries: 4096 (order: 1, 16384 bytes)
> memblock_virt_alloc_try_nid_nopanic: 8192 bytes align=0x0 nid=-1 from=0x0 max_addr=0x0 0x001ee828
> memblock_reserve: [0x01fd1620-0x01fd361f] 0x001f0466
> Inode-cache hash table entries: 2048 (order: 0, 8192 bytes)
> Sorting __ex_table...
> Memory: 29256K/32768K available (1489K kernel code, 96K rwdata, 240K rodata, 56K init, 77K bss, 3512K reserved, 0K cma-reserved)
> SLUB: HWalign=16, Order=0-3, MinObjects=0, CPUs=1, Nodes=8
> NR_IRQS: 256
> clocksource: slt: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 14370379300 ns
> Calibrating delay loop... 264.19 BogoMIPS (lpj=1320960)
> pid_max: default: 32768 minimum: 301
> Mount-cache hash table entries: 2048 (order: 0, 8192 bytes)
> Mountpoint-cache hash table entries: 2048 (order: 0, 8192 bytes)
> clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 19112604462750000 ns
> ColdFire: PCI bus initialization...
> Coldfire: PCI IO/config window mapped to 0xe0000000
> PCI host bridge to bus 0000:00
> pci_bus 0000:00: root bus resource [io  0x0000-0xffff]
> pci_bus 0000:00: root bus resource [mem 0x00000000-0xffffffff]
> pci_bus 0000:00: root bus resource [bus 00-ff]
> pci 0000:00:14.0: BAR 2: assigned [mem 0xf0000000-0xf00fffff]
> pci 0000:00:14.0: BAR 6: assigned [mem 0xf0100000-0xf01fffff pref]
> pci 0000:00:14.0: BAR 0: assigned [mem 0xf0200000-0xf0200fff]
> pci 0000:00:14.0: BAR 1: assigned [io  0x0400-0x043f]
> vgaarb: loaded
> clocksource: Switched to clocksource slt
> workingset: timestamp_bits=27 max_order=12 bucket_order=0
> romfs: ROMFS MTD (C) 2007 Red Hat, Inc.
> io scheduler noop registered (default)
> io scheduler mq-deadline registered
> io scheduler kyber registered
> ColdFire internal UART serial driver
> mcfuart.0: ttyS0 at MMIO 0xff008600 (irq = 99, base_baud = 8312500) is a ColdFire UART
> console [ttyS0] enabled
> mcfuart.0: ttyS1 at MMIO 0xff008700 (irq = 98, base_baud = 8312500) is a ColdFire UART
> mcfuart.0: ttyS2 at MMIO 0xff008800 (irq = 97, base_baud = 8312500) is a ColdFire UART
> mcfuart.0: ttyS3 at MMIO 0xff008900 (irq = 96, base_baud = 8312500) is a ColdFire UART
> brd: module loaded
> uclinux[mtd]: probe address=0x20bb84 size=0x126000
> Creating 1 MTD partitions on "ram":
> 0x000000000000-0x000000126000 : "ROMfs"
> random: get_random_bytes called from 0x000283b6 with crng_init=0
> VFS: Mounted root (romfs filesystem) readonly on device 31:0.
> Freeing unused kernel memory: 56K
> This architecture does not have kernel memory protection.
> 
> Regards
> Greg
> 

-- 
Sincerely yours,
Mike.
