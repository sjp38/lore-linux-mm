Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 283606B0130
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 05:44:02 -0400 (EDT)
Date: Mon, 21 Sep 2009 10:44:06 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/3] slqb: Do not use DEFINE_PER_CPU for per-node data
Message-ID: <20090921094406.GI12726@csn.ul.ie>
References: <1253302451-27740-1-git-send-email-mel@csn.ul.ie> <1253302451-27740-2-git-send-email-mel@csn.ul.ie> <84144f020909200145w74037ab9vb66dae65d3b8a048@mail.gmail.com> <4AB5FD4D.3070005@kernel.org> <4AB5FFF8.7000602@cs.helsinki.fi> <4AB6508C.4070602@kernel.org> <4AB739A6.5060807@in.ibm.com> <20090921084248.GC12726@csn.ul.ie> <4AB740A6.6010008@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4AB740A6.6010008@kernel.org>
Sender: owner-linux-mm@kvack.org
To: Tejun Heo <tj@kernel.org>
Cc: Sachin Sant <sachinp@in.ibm.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Nick Piggin <npiggin@suse.de>, Christoph Lameter <cl@linux-foundation.org>, heiko.carstens@de.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Mon, Sep 21, 2009 at 06:00:22PM +0900, Tejun Heo wrote:
> Hello,
> 
> Mel Gorman wrote:
> >>> Can you please post full dmesg showing the corruption? 
> > 
> > There isn't a useful dmesg available and my evidence that it's within the
> > pcpu allocator is a bit weak.
> 
> I'd really like to see the memory layout, especially how far apart the
> nodes are.
> 

Here is the console log with just your patch applied. The node layouts
are included in the log although I note they are not far apart. What is
also important is that the exact location of the bug is not reliable
although it's always in accessing the same structure. This time it was a
bad data access. The time after that, a BUG_ON triggered when locking a
spinlock in the same structure. The third time, it locked up silently.
Forth time, it was a data access error but a different address and so
on.

Please wait, loading kernel...
Allocated 01000000 bytes for kernel @ 02300000
   Elf64 kernel loaded...
Loading ramdisk...
ramdisk loaded 00795000 @ 03300000
OF stdout device is: /vdevice/vty@30000000
Preparing to boot Linux version 2.6.31-autokern1 (root@mpower6lp5) (gcc version 4.3.2 [gcc-4_3-branch revision 141291] (SUSE Linux) ) #2 SMP Mon Sep 21 14:47:34 IST 2009
Calling ibm,client-architecture... done
command line: root=/dev/sda3 sysrq=8 insmod=sym53c8xx insmod=ipr crashkernel=512M-:256M autobench_args: root=/dev/sda3 ABAT:1253523570
memory layout at init:
  alloc_bottom : 0000000003aa0000
  alloc_top    : 0000000008000000
  alloc_top_hi : 0000000008000000
  rmo_top      : 0000000008000000
  ram_top      : 0000000008000000
instantiating rtas at 0x00000000074e0000... done
boot cpu hw idx 0000000000000000
copying OF device tree...
Building dt strings...
Building dt structure...
Device tree strings 0x0000000003db0000 -> 0x0000000003db15c2
Device tree struct  0x0000000003dc0000 -> 0x0000000003de0000
Calling quiesce...
returning from prom_init
Crash kernel location must be 0x2000000
Reserving 256MB of memory at 32MB for crashkernel (System RAM: 4096MB)
Phyp-dump disabled at boot time
Using pSeries machine description
Using 1TB segments
Found initrd at 0xc000000003300000:0xc000000003a95000
bootconsole [udbg0] enabled
Partition configured for 2 cpus.
CPU maps initialized for 2 threads per core
Starting Linux PPC64 #2 SMP Mon Sep 21 14:47:34 IST 2009
-----------------------------------------------------
ppc64_pft_size                = 0x1a
physicalMemorySize            = 0x100000000
htab_hash_mask                = 0x7ffff
-----------------------------------------------------
Initializing cgroup subsys cpuset
Initializing cgroup subsys cpu
Linux version 2.6.31-autokern1 (root@mpower6lp5) (gcc version 4.3.2 [gcc-4_3-branch revision 141291] (SUSE Linux) ) #2 SMP Mon Sep 21 14:47:34 IST 2009
[boot]0012 Setup Arch
EEH: No capable adapters found
PPC64 nvram contains 15360 bytes
Zone PFN ranges:
  DMA      0x00000000 -> 0x00010000
  Normal   0x00010000 -> 0x00010000
Movable zone start PFN for each node
early_node_map[2] active PFN ranges
    2: 0x00000000 -> 0x0000e000
    3: 0x0000e000 -> 0x00010000
Could not find start_pfn for node 0
[boot]0015 Setup Done
Built 3 zonelists in Node order, mobility grouping on.  Total pages: 65480
Policy zone: DMA
Kernel command line: root=/dev/sda3 sysrq=8 insmod=sym53c8xx insmod=ipr crashkernel=512M-:256M autobench_args: root=/dev/sda3 ABAT:1253523570
PID hash table entries: 4096 (order: 12, 32768 bytes)
freeing bootmem node 2
freeing bootmem node 3
Memory: 3899712k/4194304k available (7616k kernel code, 294592k reserved, 1984k data, 4256k bss, 512k init)
Hierarchical RCU implementation.
RCU-based detection of stalled CPUs is enabled.
NR_IRQS:512
[boot]0020 XICS Init
[boot]0021 XICS Done
clocksource: timebase mult[7d0000] shift[22] registered
Console: colour dummy device 80x25
console [hvc0] enabled, bootconsole disabled
console [hvc0] enabled, bootconsole disabled
allocated 2621440 bytes of page_cgroup
please try 'cgroup_disable=memory' option if you don't want memory cgroups
Security Framework initialized
SELinux:  Disabled at boot.
Dentry cache hash table entries: 524288 (order: 6, 4194304 bytes)
Inode-cache hash table entries: 262144 (order: 5, 2097152 bytes)
Mount-cache hash table entries: 4096
Initializing cgroup subsys ns
Initializing cgroup subsys cpuacct
Initializing cgroup subsys memory
Initializing cgroup subsys devices
Initializing cgroup subsys freezer
Processor 1 found.
Brought up 2 CPUs
NET: Registered protocol family 16
IBM eBus Device Driver
POWER6 performance monitor hardware support registered
PCI: Probing PCI hardware
bio: create slab <bio-0> at 0
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
NET: Registered protocol family 2
IP route cache hash table entries: 32768 (order: 2, 262144 bytes)
TCP established hash table entries: 131072 (order: 5, 2097152 bytes)
TCP bind hash table entries: 65536 (order: 4, 1048576 bytes)
TCP: Hash tables configured (established 131072 bind 65536)
TCP reno registered
NET: Registered protocol family 1
Unpacking initramfs...
IOMMU table initialized, virtual merging enabled
audit: initializing netlink socket (disabled)
type=2000 audit(1253525186.227:1): initialized
HugeTLB registered 16 MB page size, pre-allocated 0 pages
HugeTLB registered 16 GB page size, pre-allocated 0 pages
VFS: Disk quotas dquot_6.5.2
Dquot-cache hash table entries: 8192 (order 0, 65536 bytes)
msgmni has been set to 7616
alg: No test for stdrng (krng)
Block layer SCSI generic (bsg) driver version 0.4 loaded (major 254)
io scheduler noop registered
io scheduler anticipatory registered
io scheduler deadline registered
io scheduler cfq registered (default)
Generic RTC Driver v1.07
Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
pmac_zilog: 0.6 (Benjamin Herrenschmidt <benh@kernel.crashing.org>)
input: Macintosh mouse button emulation as /class/input/input0
Uniform Multi-Platform E-IDE driver
ide-gd driver 1.18
Intel(R) PRO/1000 Network Driver - version 7.3.21-k3-NAPI
Copyright (c) 1999-2006 Intel Corporation.
ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
mice: PS/2 mouse device common for all mice
EDAC MC: Ver: 2.1.0 Sep 21 2009
usbcore: registered new interface driver hiddev
usbcore: registered new interface driver usbhid
usbhid: v2.6:USB HID core driver
TCP cubic registered
NET: Registered protocol family 15
registered taskstats version 1
Freeing unused kernel memory: 512k freed
doing fast boot
boot/02-start.sh: line 72: cmd_autobench_args:=autobench_args:: command not found
boot/02-start.sh: line 72: cmd_ABAT:1253523570=ABAT:1253523570: command not found
SysRq : Changing Loglevel
Loglevel set to 8
Unable to handle kernel paging request for data at address 0x3c34a500
Faulting instruction address: 0xc000000000157304
Oops: Kernel access of bad area, sig: 11 [#1]
SMP NR_CPUS=1024 NUMA pSeries
Modules linked in: scsi_mod(+)
NIP: c000000000157304 LR: c0000000001572d4 CTR: 0000000000000000
REGS: c0000000c72336e0 TRAP: 0300   Not tainted  (2.6.31-autokern1)
MSR: 8000000000009032 <EE,ME,IR,DR>  CR: 24222422  XER: 00000003
DAR: 000000003c34a500, DSISR: 0000000042000000
TASK = c0000000c7220680[61] 'modprobe' THREAD: c0000000c7230000 CPU: 0
GPR00: c0000000001572d4 c0000000c7233960 c000000000961310 c000000000e0fb00
GPR04: c000000000766b00 0000000000000001 c0000000dfc60a38 c0000000dfff8800
GPR08: 000000003c34a4f8 000000003c3900a9 c000000000766b30 000000003c34b549
GPR12: 0000000044222428 c000000000a32600 0000000000000000 0000000000000000
GPR16: 0000000000000000 0000000000000000 000000001002c550 0000000000000000
GPR20: 0000000000000000 0000000000000018 ffffffffffffffff 0000000000000010
GPR24: 0000000000210d00 c0000000c52eff80 c0000000c52e0000 c000000000e0fb00
GPR28: c0000000dfc60a10 c0000000dfc60a30 c0000000008e0a08 c000000000766b00
NIP [c000000000157304] .__slab_alloc_page+0x3e8/0x470
LR [c0000000001572d4] .__slab_alloc_page+0x3b8/0x470
Call Trace:
[c0000000c7233960] [c0000000001572d4] .__slab_alloc_page+0x3b8/0x470 (unreliable)
[c0000000c7233a20] [c0000000001588c4] .kmem_cache_alloc+0x14c/0x22c
[c0000000c7233ae0] [c000000000159274] .kmem_cache_create+0x280/0x28c
[c0000000c7233bd0] [d000000000db1a54] .scsi_init_queue+0x38/0x170 [scsi_mod]
[c0000000c7233c60] [d000000000db1950] .init_scsi+0x1c/0xe8 [scsi_mod]
[c0000000c7233ce0] [c0000000000097a8] .do_one_initcall+0x88/0x1bc
[c0000000c7233d90] [c0000000000cd0a0] .SyS_init_module+0x11c/0x298
[c0000000c7233e30] [c000000000008534] syscall_exit+0x0/0x40
Instruction dump:
60000000 7feafb78 e93f0040 e97f0028 7f63db78 39290001 396b0001 7fe4fb78
f93f0040 e90a0031 f97f0028 f91c0020 <fba80008> fbbf0030 f95c0028 4bffd7ad
---[ end trace c99de4a1f41d4e1e ]---
/init: line 21:    61 Segmentation fault      modprobe $file

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
