Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id E4F526B4175
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 04:39:41 -0500 (EST)
Received: by mail-lj1-f199.google.com with SMTP id w5-v6so5293645ljh.13
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 01:39:41 -0800 (PST)
Received: from mx2.cyber.ee (mx2.cyber.ee. [193.40.6.72])
        by mx.google.com with ESMTPS id z2-v6si23476804ljk.199.2018.11.26.01.39.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Nov 2018 01:39:38 -0800 (PST)
Subject: Re: NO_BOOTMEM breaks alpha pc164
References: <8c8e3dba-7adf-96c6-195c-311050256743@linux.ee>
 <20181123071448.GE5704@rapoport-lnx>
 <78de90df-d88b-d82f-baf1-f0218af7a341@linux.ee>
 <20181124114507.GC28634@rapoport-lnx>
From: Meelis Roos <mroos@linux.ee>
Message-ID: <3916b9f1-76a3-c20d-6e2d-ff62a73a0b4a@linux.ee>
Date: Mon, 26 Nov 2018 11:39:37 +0200
MIME-Version: 1.0
In-Reply-To: <20181124114507.GC28634@rapoport-lnx>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: et-EE
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-alpha@vger.kernel.org, linux-mm@kvack.org

> Two things that might cause the hang.
> First, memblock_add() is called after node_min_pfn has been rounded down to
> the nearest 8Mb and in your case this cases memblock to see more memory that
> is actually present in the system.
> I'm not sure why the 8Mb alignment is required, I've just made sure that
> memblock_add() will use exact available memory (the first patch below).
> 
> Another thing is that memblock allocates memory from high addresses while
> bootmem was using low memory. It may happen that an allocation from high
> memory is not accessible by the hardware, although it should be. The second
> patch below addresses this issue.
> 
> It would be really great if you could test with each patch separately and
> with both patches applied :)

Tested separateöy and together, with the previous debug patch applied.

debug+patch1 caused no visible change cmpared to just debug - same crash before starting init as with plain debug patch.

debug+patch2 caused a change - now instead of hang before starting init, it hangs after starting init as with no patch applied.

debug+patch1+patch2: works, dmesg attached:

[    0.000000] Linux version 4.20.0-rc2-00068-gda5322e65940-dirty (mroos@pc164) (gcc version 7.3.0 (Gentoo 7.3.0-r3 p1.4)) #118 Mon Nov 26 12:24:51 EET 2018
[    0.000000] Booting on EB164 variation PC164 using machine vector PC164 from SRM
[    0.000000] Major Options: EV56 LEGACY_START VERBOSE_MCHECK DISCONTIGMEM MAGIC_SYSRQ
[    0.000000] Command line: root=/dev/sda2 console=ttyS0
[    0.000000] Raw memory layout:
[    0.000000]  memcluster  0, usage 1, start        0, end      192
[    0.000000]  memcluster  1, usage 0, start      192, end    32651
[    0.000000]  memcluster  2, usage 1, start    32651, end    32768
[    0.000000] Initializing bootmem allocator on Node ID 0
[    0.000000]  memcluster  1, usage 0, start      192, end    32651
[    0.000000]  Detected node memory:   start      192, end    32651
[    0.000000] memblock_add: [0x0000000000180000-0x000000000ff15fff] setup_memory+0x38c/0x470
[    0.000000] memblock_reserve: [0x0000000000300000-0x0000000000c11fff] setup_memory+0x43c/0x470
[    0.000000] 1024K Bcache detected; load hit latency 30 cycles, load miss latency 212 cycles
[    0.000000] pci: cia revision 2
[    0.000000] memblock_alloc_try_nid: 104 bytes align=0x20 nid=-1 from=0x0000000000000000 max_addr=0x0000000000000000 alloc_pci_controller+0x2c/0x50
[    0.000000] memblock_reserve: [0x0000000000c12000-0x0000000000c12067] memblock_alloc_internal+0x170/0x278
[    0.000000] memblock_alloc_try_nid: 64 bytes align=0x20 nid=-1 from=0x0000000000000000 max_addr=0x0000000000000000 alloc_resource+0x2c/0x40
[    0.000000] memblock_reserve: [0x0000000000c12080-0x0000000000c120bf] memblock_alloc_internal+0x170/0x278
[    0.000000] memblock_alloc_try_nid: 40 bytes align=0x8000 nid=0 from=0x0000000000000000 max_addr=0x0000000000000000 iommu_arena_new_node+0x74/0x1b0
[    0.000000] memblock_reserve: [0x0000000000c18000-0x0000000000c18027] memblock_alloc_internal+0x170/0x278
[    0.000000] memblock_alloc_try_nid: 40 bytes align=0x8000 nid=0 from=0x0000000000000000 max_addr=0x0000000000000000 iommu_arena_new_node+0x104/0x1b0
[    0.000000] memblock_reserve: [0x0000000000c20000-0x0000000000c20027] memblock_alloc_internal+0x170/0x278
[    0.000000] memblock_alloc_try_nid: 1024 bytes align=0x8000 nid=-1 from=0x0000000000000000 max_addr=0x0000000000000000 do_init_arch+0x37c/0x448
[    0.000000] memblock_reserve: [0x0000000000c28000-0x0000000000c283ff] memblock_alloc_internal+0x170/0x278
[    0.000000] On node 0 totalpages: 32651
[    0.000000] memblock_alloc_try_nid_nopanic: 1835008 bytes align=0x20 nid=0 from=0x0000000000000000 max_addr=0x0000000000000000 alloc_node_mem_map+0x7c/0xa8
[    0.000000] memblock_reserve: [0x0000000000c28400-0x0000000000de83ff] memblock_alloc_internal+0x170/0x278
[    0.000000]   DMA zone: 224 pages used for memmap
[    0.000000]   DMA zone: 0 pages reserved
[    0.000000]   DMA zone: 32651 pages, LIFO batch:7
[    0.000000] memblock_alloc_try_nid_nopanic: 16 bytes align=0x20 nid=0 from=0x0000000000000000 max_addr=0x0000000000000000 setup_usemap.isra.111+0x5c/0x78
[    0.000000] memblock_reserve: [0x0000000000c120c0-0x0000000000c120cf] memblock_alloc_internal+0x170/0x278
[    0.000000] memblock_alloc_try_nid: 29 bytes align=0x20 nid=-1 from=0x0000000000000000 max_addr=0x0000000000000000 memblock_alloc.constprop.14+0x28/0x40
[    0.000000] memblock_reserve: [0x0000000000c120e0-0x0000000000c120fc] memblock_alloc_internal+0x170/0x278
[    0.000000] memblock_alloc_try_nid: 29 bytes align=0x20 nid=-1 from=0x0000000000000000 max_addr=0x0000000000000000 memblock_alloc.constprop.14+0x28/0x40
[    0.000000] memblock_reserve: [0x0000000000c12100-0x0000000000c1211c] memblock_alloc_internal+0x170/0x278
[    0.000000] memblock_alloc_try_nid: 29 bytes align=0x20 nid=-1 from=0x0000000000000000 max_addr=0x0000000000000000 memblock_alloc.constprop.14+0x28/0x40
[    0.000000] memblock_reserve: [0x0000000000c12120-0x0000000000c1213c] memblock_alloc_internal+0x170/0x278
[    0.000000] memblock_alloc_try_nid_nopanic: 8192 bytes align=0x2000 nid=-1 from=0x0000000000000000 max_addr=0x0000000000000000 pcpu_alloc_alloc_info+0x5c/0xc8
[    0.000000] memblock_reserve: [0x0000000000c14000-0x0000000000c15fff] memblock_alloc_internal+0x170/0x278
[    0.000000] memblock_alloc_try_nid_nopanic: 32768 bytes align=0x2000 nid=-1 from=0x000003ffffffffff max_addr=0x0000000000000000 setup_per_cpu_areas+0x70/0x118
[    0.000000] memblock_reserve: [0x0000000000dea000-0x0000000000df1fff] memblock_alloc_internal+0x170/0x278
[    0.000000] memblock_alloc_try_nid: 8 bytes align=0x20 nid=-1 from=0x0000000000000000 max_addr=0x0000000000000000 memblock_alloc.constprop.29+0x28/0x40
[    0.000000] memblock_reserve: [0x0000000000c12140-0x0000000000c12147] memblock_alloc_internal+0x170/0x278
[    0.000000] memblock_alloc_try_nid: 8 bytes align=0x20 nid=-1 from=0x0000000000000000 max_addr=0x0000000000000000 memblock_alloc.constprop.29+0x28/0x40
[    0.000000] memblock_reserve: [0x0000000000c12160-0x0000000000c12167] memblock_alloc_internal+0x170/0x278
[    0.000000] memblock_alloc_try_nid: 4 bytes align=0x20 nid=-1 from=0x0000000000000000 max_addr=0x0000000000000000 memblock_alloc.constprop.29+0x28/0x40
[    0.000000] memblock_reserve: [0x0000000000c12180-0x0000000000c12183] memblock_alloc_internal+0x170/0x278
[    0.000000] memblock_alloc_try_nid: 8 bytes align=0x20 nid=-1 from=0x0000000000000000 max_addr=0x0000000000000000 memblock_alloc.constprop.29+0x28/0x40
[    0.000000] memblock_reserve: [0x0000000000c121a0-0x0000000000c121a7] memblock_alloc_internal+0x170/0x278
[    0.000000] pcpu-alloc: s0 r0 d32768 u32768 alloc=1*32768
[    0.000000] pcpu-alloc: [0] 0
[    0.000000] memblock_alloc_try_nid: 240 bytes align=0x20 nid=-1 from=0x0000000000000000 max_addr=0x0000000000000000 memblock_alloc.constprop.29+0x28/0x40
[    0.000000] memblock_reserve: [0x0000000000c121c0-0x0000000000c122af] memblock_alloc_internal+0x170/0x278
[    0.000000] memblock_alloc_try_nid: 105 bytes align=0x20 nid=-1 from=0x0000000000000000 max_addr=0x0000000000000000 memblock_alloc.constprop.29+0x28/0x40
[    0.000000] memblock_reserve: [0x0000000000c122c0-0x0000000000c12328] memblock_alloc_internal+0x170/0x278
[    0.000000] memblock_alloc_try_nid: 1024 bytes align=0x20 nid=-1 from=0x0000000000000000 max_addr=0x0000000000000000 memblock_alloc.constprop.29+0x28/0x40
[    0.000000] memblock_reserve: [0x0000000000c12340-0x0000000000c1273f] memblock_alloc_internal+0x170/0x278
[    0.000000] memblock_alloc_try_nid: 1032 bytes align=0x20 nid=-1 from=0x0000000000000000 max_addr=0x0000000000000000 memblock_alloc.constprop.29+0x28/0x40
[    0.000000] memblock_reserve: [0x0000000000c12740-0x0000000000c12b47] memblock_alloc_internal+0x170/0x278
[    0.000000] memblock_alloc_try_nid: 80 bytes align=0x20 nid=-1 from=0x0000000000000000 max_addr=0x0000000000000000 memblock_alloc.constprop.29+0x28/0x40
[    0.000000] memblock_reserve: [0x0000000000c12b60-0x0000000000c12baf] memblock_alloc_internal+0x170/0x278
[    0.000000] __memblock_free_early: [0x0000000000c14000-0x0000000000c15fff] pcpu_free_alloc_info+0x2c/0x40
[    0.000000] Built 1 zonelists, mobility grouping on.  Total pages: 32427
[    0.000000] Kernel command line: root=/dev/sda2 console=ttyS0
[    0.000000] memblock_alloc_try_nid_nopanic: 262144 bytes align=0x20 nid=-1 from=0x0000000000000000 max_addr=0x0000000000000000 alloc_large_system_hash+0x258/0x3dc
[    0.000000] memblock_reserve: [0x0000000000df2000-0x0000000000e31fff] memblock_alloc_internal+0x170/0x278
[    0.000000] Dentry cache hash table entries: 32768 (order: 5, 262144 bytes)
[    0.000000] memblock_alloc_try_nid_nopanic: 131072 bytes align=0x20 nid=-1 from=0x0000000000000000 max_addr=0x0000000000000000 alloc_large_system_hash+0x258/0x3dc
[    0.000000] memblock_reserve: [0x0000000000e32000-0x0000000000e51fff] memblock_alloc_internal+0x170/0x278
[    0.000000] Inode-cache hash table entries: 16384 (order: 4, 131072 bytes)
[    0.000000] Sorting __ex_table...
[    0.000000] Memory: 248144K/261208K available (5455K kernel code, 372K rwdata, 1740K rodata, 200K init, 1425K bss, 13064K reserved, 0K cma-reserved)
[    0.000000] SLUB: HWalign=32, Order=0-3, MinObjects=0, CPUs=1, Nodes=128
[    0.000000] NR_IRQS: 35
[    0.000000] clocksource: rpcc: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 3822520893 ns
[    0.001953] Console: colour VGA+ 80x25
[    0.073242] printk: console [ttyS0] enabled
[    0.074218] Calibrating delay loop... 985.92 BogoMIPS (lpj=480768)
[    0.083007] pid_max: default: 32768 minimum: 301
[    0.084960] Mount-cache hash table entries: 1024 (order: 0, 8192 bytes)
[    0.085937] Mountpoint-cache hash table entries: 1024 (order: 0, 8192 bytes)
[    0.096679] devtmpfs: initialized
[    0.098632] random: get_random_u32 called from bucket_table_alloc.isra.19+0xbc/0x280 with crng_init=0
[    0.101562] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 1866466235866741 ns
[    0.102539] futex hash table entries: 256 (order: -1, 6144 bytes)
[    0.104492] NET: Registered protocol family 16
[    0.106445] pci: passed tb register update test
[    0.108398] pci: passed sg loopback i/o read test
[    0.109374] pci: passed tbia test
[    0.110351] pci: passed pte write cache snoop test
[    0.111328] pci: failed valid tag invalid pte reload test (mcheck; workaround available)
[    0.112304] pci: passed pci machine check test
[    0.113281] PCI host bridge to bus 0000:00
[    0.114257] pci_bus 0000:00: root bus resource [io  0x0000-0xffff]
[    0.115234] pci_bus 0000:00: root bus resource [mem 0x00000000-0x1fffffff]
[    0.116210] pci_bus 0000:00: No busn resource found for root bus, will use [bus 00-ff]
[    0.117187] pci 0000:00:05.0: [1000:000f] type 00 class 0x010000
[    0.117187] pci 0000:00:05.0: reg 0x10: [io  0x10000-0x100ff]
[    0.117187] pci 0000:00:05.0: reg 0x14: [mem 0x82875000-0x828750ff]
[    0.117187] pci 0000:00:05.0: reg 0x18: [mem 0x82874000-0x82874fff]
[    0.118164] pci 0000:00:05.0: reg 0x30: [mem 0x82840000-0x8285ffff pref]
[    0.118164] pci 0000:00:06.0: [102b:051b] type 00 class 0x030000
[    0.118164] pci 0000:00:06.0: reg 0x10: [mem 0x88000000-0x88ffffff pref]
[    0.118164] pci 0000:00:06.0: reg 0x14: [mem 0x82870000-0x82873fff]
[    0.118164] pci 0000:00:06.0: reg 0x18: [mem 0x82000000-0x827fffff]
[    0.118164] pci 0000:00:06.0: reg 0x30: [mem 0x82860000-0x8286ffff pref]
[    0.119140] pci 0000:00:08.0: [8086:0484] type 00 class 0x000000
[    0.119140] pci 0000:00:09.0: [1011:0009] type 00 class 0x020000
[    0.119140] pci 0000:00:09.0: reg 0x10: [io  0x10100-0x1017f]
[    0.119140] pci 0000:00:09.0: reg 0x14: [mem 0x82875100-0x8287517f]
[    0.119140] pci 0000:00:09.0: reg 0x30: [mem 0x82800000-0x8283ffff pref]
[    0.120117] pci 0000:00:0b.0: [1095:0646] type 00 class 0x010180
[    0.120117] pci 0000:00:0b.0: reg 0x20: [io  0x10180-0x1018f]
[    0.120117] pci 0000:00:0b.0: legacy IDE quirk: reg 0x10: [io  0x01f0-0x01f7]
[    0.121093] pci 0000:00:0b.0: legacy IDE quirk: reg 0x14: [io  0x03f6]
[    0.122070] pci 0000:00:0b.0: legacy IDE quirk: reg 0x18: [io  0x0170-0x0177]
[    0.123046] pci 0000:00:0b.0: legacy IDE quirk: reg 0x1c: [io  0x0376]
[    0.124023] pci: enabling save/restore of SRM state
[    0.124999] pci_bus 0000:00: busn_res: [bus 00-ff] end is updated to 00
[    0.124999] pci 0000:00:06.0: BAR 0: assigned [mem 0x03000000-0x03ffffff pref]
[    0.125976] pci 0000:00:06.0: BAR 2: assigned [mem 0x02800000-0x02ffffff]
[    0.126953] pci 0000:00:09.0: BAR 6: assigned [mem 0x02200000-0x0223ffff pref]
[    0.127929] pci 0000:00:05.0: BAR 6: assigned [mem 0x02240000-0x0225ffff pref]
[    0.128906] pci 0000:00:06.0: BAR 6: assigned [mem 0x02260000-0x0226ffff pref]
[    0.130859] pci 0000:00:06.0: BAR 1: assigned [mem 0x02270000-0x02273fff]
[    0.131835] pci 0000:00:05.0: BAR 2: assigned [mem 0x02274000-0x02274fff]
[    0.132812] pci 0000:00:05.0: BAR 0: assigned [io  0x8000-0x80ff]
[    0.133788] pci 0000:00:05.0: BAR 1: assigned [mem 0x02275000-0x022750ff]
[    0.134765] pci 0000:00:09.0: BAR 0: assigned [io  0x8400-0x847f]
[    0.135742] pci 0000:00:09.0: BAR 1: assigned [mem 0x02276000-0x0227607f]
[    0.136718] pci 0000:00:0b.0: BAR 4: assigned [io  0x8480-0x848f]
[    0.137695] pci_bus 0000:00: resource 4 [io  0x0000-0xffff]
[    0.137695] pci_bus 0000:00: resource 5 [mem 0x00000000-0x1fffffff]
[    0.138671] SMC FDC37C93X Ultra I/O Controller found @ 0x370
[    0.149413] pci 0000:00:06.0: vgaarb: setting as boot VGA device
[    0.149413] pci 0000:00:06.0: vgaarb: VGA device added: decodes=io+mem,owns=io+mem,locks=none
[    0.150390] pci 0000:00:06.0: vgaarb: bridge control possible
[    0.151367] vgaarb: loaded
[    0.153320] SCSI subsystem initialized
[    0.157226] clocksource: Switched to clocksource rpcc
[    0.182617] NET: Registered protocol family 2
[    0.185546] tcp_listen_portaddr_hash hash table entries: 512 (order: 0, 8192 bytes)
[    0.186523] TCP established hash table entries: 2048 (order: 1, 16384 bytes)
[    0.187499] TCP bind hash table entries: 2048 (order: 1, 16384 bytes)
[    0.188476] TCP: Hash tables configured (established 2048 bind 2048)
[    0.190429] UDP hash table entries: 256 (order: 0, 8192 bytes)
[    0.191406] UDP-Lite hash table entries: 256 (order: 0, 8192 bytes)
[    0.193359] NET: Registered protocol family 1
[    0.194335] PCI: CLS 0 bytes, default 32
[    0.196288] srm_env: version 0.0.6 loaded successfully
[    0.197265] Using epoch 2000 for rtc year 18
[    0.200195] platform rtc-alpha: rtc core: registered rtc-alpha as rtc0
[    0.203124] workingset: timestamp_bits=55 max_order=15 bucket_order=0
[    0.241210] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 252)
[    0.242187] io scheduler noop registered
[    0.244140] io scheduler cfq registered (default)
[    0.247070] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[    0.249023] serial8250: ttyS0 at I/O 0x3f8 (irq = 4, base_baud = 115200) is a 16550A
[    0.249999] random: fast init done
[    0.252929] serial8250: ttyS1 at I/O 0x2f8 (irq = 3, base_baud = 115200) is a 16550A
[    0.406249] sym0: <875> rev 0x3 at pci 0000:00:05.0 irq 18
[    0.410156] Floppy drive(s): fd0 is 2.88M
[    0.499999] sym0: Symbios NVRAM, ID 7, Fast-20, SE, parity checking
[    0.500976] sym0: open drain IRQ line driver, using on-chip SRAM
[    0.501952] sym0: using LOAD/STORE-based firmware.
[    0.502929] sym0: SCSI BUS has been reset.
[    0.503905] scsi host0: sym-2.2.3
[    0.506835] Linux Tulip driver version 1.1.15-NAPI (Feb 27, 2007)
[    0.511718] tulip0: Old format EEPROM on 'Accton EN1207' board.  Using substitute media control info
[    0.512695] tulip0: EEPROM default media type Autosense
[    0.513671] tulip0: Index #0 - Media 10base2 (#1) described by a 21140 non-MII (0) block
[    0.514648] tulip0: Index #1 - Media 10baseT (#0) described by a 21140 non-MII (0) block
[    0.516601] tulip0: Index #2 - Media 10baseT-FDX (#4) described by a 21140 non-MII (0) block
[    0.517577] tulip0: Index #3 - Media 100baseTx (#3) described by a 21140 non-MII (0) block
[    0.518554] tulip0: Index #4 - Media 100baseTx-FDX (#5) described by a 21140 non-MII (0) block
[    0.520507] net eth0: Digital DS21140 Tulip rev 34 at MMIO 0x2276000, 00:00:e8:3c:4e:c2, IRQ 19
[    0.527343] serio: i8042 KBD port at 0x60,0x64 irq 1
[    0.528320] serio: i8042 AUX port at 0x60,0x64 irq 12
[    0.532226] NET: Registered protocol family 10
[    0.536132] FDC 0 is a post-1991 82077
[    0.546874] Segment Routing with IPv6
[    0.547851] NET: Registered protocol family 17
[    0.549804] atkbd serio0: keyboard reset failed on isa0060/serio0
[    0.553710] platform rtc-alpha: setting system clock to 2018-11-26 10:35:27 UTC (1543228527)
[    0.609374] atkbd serio1: keyboard reset failed on isa0060/serio1
[    0.685546] atkbd serio0: keyboard reset failed on isa0060/serio0
[    0.750976] atkbd serio1: keyboard reset failed on isa0060/serio1
[    3.902341] scsi 0:0:0:0: Direct-Access     COMPAQ   BF0369A4BC       HPB7 PQ: 0 ANSI: 3
[    3.903318] scsi target0:0:0: tagged command queuing enabled, command queue depth 16.
[    3.904294] scsi target0:0:0: Beginning Domain Validation
[    3.911130] scsi target0:0:0: FAST-20 WIDE SCSI 40.0 MB/s ST (50 ns, offset 15)
[    3.915037] scsi target0:0:0: Domain Validation skipping write tests
[    3.916013] scsi target0:0:0: Ending Domain Validation
[    3.917966] scsi 0:0:0:0: Power-on or device reset occurred
[    8.038081] sd 0:0:0:0: Attached scsi generic sg0 type 0
[    8.039058] sd 0:0:0:0: [sda] 71132000 512-byte logical blocks: (36.4 GB/33.9 GiB)
[    8.041011] sd 0:0:0:0: [sda] Write Protect is off
[    8.041988] sd 0:0:0:0: [sda] Mode Sense: cf 00 10 08
[    8.042964] sd 0:0:0:0: [sda] Write cache: disabled, read cache: enabled, supports DPO and FUA
[    8.058589]  sda: sda1 sda2 sda4
[    8.067378] sd 0:0:0:0: [sda] Attached SCSI disk
[    8.096675] EXT4-fs (sda2): mounted filesystem with ordered data mode. Opts: (null)
[    8.098628] VFS: Mounted root (ext4 filesystem) readonly on device 8:2.
[    8.114253] devtmpfs: mounted
[    8.116206] Freeing unused kernel memory: 200K
[    8.118159] This architecture does not have kernel memory protection.
[    8.119136] Run /sbin/init as init process
[    8.398433] random: crng init done
[   21.775379] udevd[477]: starting version 3.2.5
[   21.947254] udevd[478]: starting eudev-3.2.5
[   23.135730] tulip 0000:00:09.0 enp0s9: renamed from eth0
[   23.919909] libata version 3.00 loaded.
[   24.090807] scsi host1: pata_cmd64x
[   24.114245] scsi host2: pata_cmd64x
[   24.115222] ata1: PATA max MWDMA2 cmd 0x1f0 ctl 0x3f6 bmdma 0x8480 irq 14
[   24.115222] ata2: PATA max MWDMA2 cmd 0x170 ctl 0x376 bmdma 0x8488 irq 15
[   24.116198] pata_cmd64x: active 10 recovery 10 setup 3.
[   24.116198] pata_cmd64x: active 10 recovery 10 setup 3.
[   24.293932] ata1.00: ATAPI: SONY    CD-RW  CRX140E, 1.2a, max UDMA/33
[   24.293932] pata_cmd64x: active 3 recovery 1 setup 1.
[   24.293932] pata_cmd64x: active 3 recovery 1 setup 1.
[   24.324206] scsi 1:0:0:0: CD-ROM            SONY     CD-RW  CRX140E   1.2a PQ: 0 ANSI: 5
[   24.341784] sr 1:0:0:0: [sr0] scsi3-mmc drive: 32x/32x writer cd/rw xa/form2 cdda tray
[   24.341784] cdrom: Uniform CD-ROM driver Revision: 3.20
[   24.346667] sr 1:0:0:0: Attached scsi CD-ROM sr0
[   24.349596] sr 1:0:0:0: Attached scsi generic sg1 type 5
[   24.351550] pata_cmd64x: active 10 recovery 10 setup 3.
[   24.351550] pata_cmd64x: active 10 recovery 10 setup 3.
[   29.886703] EXT4-fs (sda2): re-mounted. Opts: errors=remount-ro
[   31.499983] Adding 1697208k swap on /dev/sda4.  Priority:-2 extents:1 across:1697208k
[   32.217756] EXT4-fs (sda1): mounting ext2 file system using the ext4 subsystem
[   32.240217] EXT4-fs (sda1): mounted filesystem without journal. Opts: (null)


-- 
Meelis Roos <mroos@linux.ee>
