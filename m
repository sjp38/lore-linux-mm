Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m7IIHD6p032373
	for <linux-mm@kvack.org>; Mon, 18 Aug 2008 14:17:13 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m7IIGrFB231414
	for <linux-mm@kvack.org>; Mon, 18 Aug 2008 14:16:53 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m7IIGqm0006239
	for <linux-mm@kvack.org>; Mon, 18 Aug 2008 14:16:53 -0400
Subject: Re: [BUG] __GFP_THISNODE is not always honored
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <20080818105918.GD32113@csn.ul.ie>
References: <1218837685.12953.11.camel@localhost.localdomain>
	 <20080818105918.GD32113@csn.ul.ie>
Content-Type: multipart/mixed; boundary="=-qNQjZzlx+a0TScHAYAQG"
Date: Mon, 18 Aug 2008 13:16:52 -0500
Message-Id: <1219083412.29323.36.camel@localhost.localdomain>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, nacc <nacc@linux.vnet.ibm.com>, apw <apw@shadowen.org>, agl <agl@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

--=-qNQjZzlx+a0TScHAYAQG
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Mon, 2008-08-18 at 11:59 +0100, Mel Gorman wrote:
> On (15/08/08 17:01), Adam Litke didst pronounce:
> > While running the libhugetlbfs test suite on a NUMA machine with 2.6.27-rc3, I
> > discovered some strange behavior with __GFP_THISNODE.  The hugetlb function
> > alloc_fresh_huge_page_node() calls alloc_pages_node() with __GFP_THISNODE but
> > occasionally a page that is not on the requested node is returned. 
> 
> That's bad in itself and has wider reaching consequences than hugetlb
> getting its counters wrong. I believe SLUB depends on __GFP_THISNODE
> being obeyed for example. Can you boot the machine in question with
> mminit_loglevel=4 and loglevel=8 set on the command line and send me the
> dmesg please? It should output the zonelists and I might be able to
> figure out what's going wrong. Thanks

dmesg output is attached.

> > Since the
> > hugetlb code assumes that the page will be on the requested node, badness follows
> > when the page is added to the wrong node's free_list.
> > 
> > There is clearly something wrong with the buddy allocator since __GFP_THISNODE
> > cannot be trusted.  Until that is fixed, the hugetlb code should not assume
> > that the newly allocated page is on the node asked for.  This patch prevents
> > the hugetlb pool counters from being corrupted and allows the code to cope with
> > unbalanced numa allocations.
> > 
> > So far my debugging has led me to get_page_from_freelist() inside the
> > for_each_zone_zonelist() loop.  When buffered_rmqueue() returns a page I
> > compare the value of page_to_nid(page), zone->node and the node that the
> > hugetlb code requested with __GFP_THISNODE.  These all match -- except when the
> > problem triggers.  In that case, zone->node matches the node we asked for but
> > page_to_nid() does not.
> > 
> 
> Feels like the wrong zonelist is being used. The dmesg with
> mminit_loglevel may tell.
> 
> > Workaround patch:
> > diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> > index 67a7119..7a30a61 100644
> > --- a/mm/hugetlb.c
> > +++ b/mm/hugetlb.c
> > @@ -568,7 +568,7 @@ static struct page *alloc_fresh_huge_page_node(struct hstate *h, int nid)
> >  			__free_pages(page, huge_page_order(h));
> >  			return NULL;
> >  		}
> > -		prep_new_huge_page(h, page, nid);
> > +		prep_new_huge_page(h, page, page_to_nid(page));
> >  	}
> 
> This will mask the bug for hugetlb but I wonder if this should be a
> VM_BUG_ON(page_to_nid(page) != nid) ?

Yeah, the patch was provided for illustrative purposes only.

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--=-qNQjZzlx+a0TScHAYAQG
Content-Disposition: attachment; filename=dmesg.out
Content-Type: text/plain; name=dmesg.out; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Using pSeries machine description
Page orders: linear mapping = 24, virtual = 12, io = 12, vmemmap = 24
Using 1TB segments
Found initrd at 0xc000000002c00000:0xc000000002f0fc00
console [udbg0] enabled
Partition configured for 8 cpus.
CPU maps initialized for 2 threads per core
 (thread shift is 1)
Starting Linux PPC64 #1 SMP Mon Aug 18 16:19:50 UTC 2008
-----------------------------------------------------
ppc64_pft_size                = 0x19
physicalMemorySize            = 0x80000000
htab_hash_mask                = 0x3ffff
-----------------------------------------------------
Initializing cgroup subsys cpuset
Linux version 2.6.27-rc3-autokern1 (root@tundro5.rchland.ibm.com) (gcc version 4.1.3 20070929 (prerelease) (Ubuntu 4.1.2-16ubuntu2)) #1 SMP Mon Aug 18 16:19:50 UTC 2008
[boot]0012 Setup Arch
mminit::memory_register Entering add_active_range(1, 0x0, 0x8000) 0 entries of 256 used
mminit::memory_register Entering add_active_range(0, 0x8000, 0xc000) 1 entries of 256 used
mminit::memory_register Entering add_active_range(0, 0xc000, 0x10000) 2 entries of 256 used
mminit::memory_register Entering add_active_range(0, 0x10000, 0x14000) 2 entries of 256 used
mminit::memory_register Entering add_active_range(0, 0x14000, 0x18000) 2 entries of 256 used
mminit::memory_register Entering add_active_range(0, 0x18000, 0x1c000) 2 entries of 256 used
mminit::memory_register Entering add_active_range(0, 0x1c000, 0x20000) 2 entries of 256 used
mminit::memory_register Entering add_active_range(0, 0x20000, 0x24000) 2 entries of 256 used
mminit::memory_register Entering add_active_range(0, 0x24000, 0x28000) 2 entries of 256 used
mminit::memory_register Entering add_active_range(0, 0x28000, 0x2c000) 2 entries of 256 used
mminit::memory_register Entering add_active_range(0, 0x2c000, 0x30000) 2 entries of 256 used
mminit::memory_register Entering add_active_range(0, 0x30000, 0x34000) 2 entries of 256 used
mminit::memory_register Entering add_active_range(0, 0x34000, 0x38000) 2 entries of 256 used
mminit::memory_register Entering add_active_range(0, 0x38000, 0x3c000) 2 entries of 256 used
mminit::memory_register Entering add_active_range(0, 0x3c000, 0x40000) 2 entries of 256 used
mminit::memory_register Entering add_active_range(0, 0x40000, 0x44000) 2 entries of 256 used
mminit::memory_register Entering add_active_range(1, 0x44000, 0x48000) 2 entries of 256 used
mminit::memory_register Entering add_active_range(1, 0x48000, 0x4c000) 3 entries of 256 used
mminit::memory_register Entering add_active_range(1, 0x4c000, 0x50000) 3 entries of 256 used
mminit::memory_register Entering add_active_range(1, 0x50000, 0x54000) 3 entries of 256 used
mminit::memory_register Entering add_active_range(1, 0x54000, 0x58000) 3 entries of 256 used
mminit::memory_register Entering add_active_range(1, 0x58000, 0x5c000) 3 entries of 256 used
mminit::memory_register Entering add_active_range(1, 0x5c000, 0x60000) 3 entries of 256 used
mminit::memory_register Entering add_active_range(1, 0x60000, 0x64000) 3 entries of 256 used
mminit::memory_register Entering add_active_range(1, 0x64000, 0x68000) 3 entries of 256 used
mminit::memory_register Entering add_active_range(1, 0x68000, 0x6c000) 3 entries of 256 used
mminit::memory_register Entering add_active_range(1, 0x6c000, 0x70000) 3 entries of 256 used
mminit::memory_register Entering add_active_range(1, 0x70000, 0x74000) 3 entries of 256 used
mminit::memory_register Entering add_active_range(1, 0x74000, 0x78000) 3 entries of 256 used
mminit::memory_register Entering add_active_range(1, 0x78000, 0x7c000) 3 entries of 256 used
mminit::memory_register Entering add_active_range(1, 0x7c000, 0x80000) 3 entries of 256 used
Node 0 Memory: 0x8000000-0x44000000
Node 1 Memory: 0x0-0x8000000 0x44000000-0x80000000
EEH: No capable adapters found
PPC64 nvram contains 15360 bytes
Using shared processor idle loop
Zone PFN ranges:
  DMA      0x00000000 -> 0x00080000
  Normal   0x00080000 -> 0x00080000
Movable zone start PFN for each node
early_node_map[3] active PFN ranges
    1: 0x00000000 -> 0x00008000
    0: 0x00008000 -> 0x00044000
    1: 0x00044000 -> 0x00080000
mminit::pageflags_layout_widths Section 0 Node 4 Zone 2 Flags 19
mminit::pageflags_layout_shifts Section 20 Node 4 Zone 2
mminit::pageflags_layout_offsets Section 0 Node 60 Zone 58
mminit::pageflags_layout_zoneid Zone ID: 58 -> 64
mminit::pageflags_layout_usage location: 64 -> 58 unused 58 -> 19 flags 19 -> 0
On node 0 totalpages: 245760
mminit::memmap_init DMA zone: 3360 pages used for memmap
mminit::memmap_init DMA zone: 0 pages reserved
  DMA zone: 242400 pages, LIFO batch:31
mminit::memmap_init Initialising map node 0 zone 0 pfns 32768 -> 278528
mminit::memmap_init Normal zone: 0 pages used for memmap
mminit::memmap_init Movable zone: 0 pages used for memmap
On node 1 totalpages: 278528
mminit::memmap_init DMA zone: 7168 pages used for memmap
mminit::memmap_init DMA zone: 0 pages reserved
  DMA zone: 271360 pages, LIFO batch:31
mminit::memmap_init Initialising map node 1 zone 0 pfns 0 -> 524288
mminit::memmap_init Normal zone: 0 pages used for memmap
mminit::memmap_init Movable zone: 0 pages used for memmap
[boot]0015 Setup Done
mminit::zonelist general 0:DMA = 0:DMA 1:DMA 
mminit::zonelist thisnode 0:DMA = 0:DMA 
mminit::zonelist general 1:DMA = 1:DMA 0:DMA 
mminit::zonelist thisnode 1:DMA = 1:DMA 
Built 2 zonelists in Node order, mobility grouping on.  Total pages: 513760
Policy zone: DMA
Kernel command line: ro console=hvc0 autobench_args: root=/dev/sda6 ABAT:1219080427 mminit_loglevel=4 loglevel=8 
[boot]0020 XICS Init
[boot]0021 XICS Done
pic: no ISA interrupt controller
PID hash table entries: 4096 (order: 12, 32768 bytes)
time_init: decrementer frequency = 512.000000 MHz
time_init: processor frequency   = 4208.000000 MHz
clocksource: timebase mult[7d0000] shift[22] registered
clockevent: decrementer mult[8312] shift[16] cpu[0]
Console: colour dummy device 80x25
console handover: boot [udbg0] -> real [hvc0]
Dentry cache hash table entries: 262144 (order: 9, 2097152 bytes)
Inode-cache hash table entries: 131072 (order: 8, 1048576 bytes)
freeing bootmem node 0
freeing bootmem node 1
Memory: 2036920k/2097152k available (7204k kernel code, 60876k reserved, 1328k data, 607k bss, 292k init)
SLUB: Genslabs=13, HWalign=128, Order=0-3, MinObjects=0, CPUs=8, Nodes=16
Calibrating delay loop... 1021.95 BogoMIPS (lpj=2043904)
Mount-cache hash table entries: 256
Initializing cgroup subsys ns
Initializing cgroup subsys cpuacct
clockevent: decrementer mult[8312] shift[16] cpu[1]
Processor 1 found.
clockevent: decrementer mult[8312] shift[16] cpu[2]
Processor 2 found.
clockevent: decrementer mult[8312] shift[16] cpu[3]
Processor 3 found.
clockevent: decrementer mult[8312] shift[16] cpu[4]
Processor 4 found.
clockevent: decrementer mult[8312] shift[16] cpu[5]
Processor 5 found.
clockevent: decrementer mult[8312] shift[16] cpu[6]
Processor 6 found.
clockevent: decrementer mult[8312] shift[16] cpu[7]
Processor 7 found.
Brought up 8 CPUs
Node 0 CPUs: 0-7
Node 1 CPUs:
CPU0 attaching sched-domain:
 domain 0: span 0-1 level SIBLING
  groups: 0 1
  domain 1: span 0-7 level CPU
   groups: 0-1 2-3 4-5 6-7
   domain 2: span 0-7 level NODE
    groups: 0-7
CPU1 attaching sched-domain:
 domain 0: span 0-1 level SIBLING
  groups: 1 0
  domain 1: span 0-7 level CPU
   groups: 0-1 2-3 4-5 6-7
   domain 2: span 0-7 level NODE
    groups: 0-7
CPU2 attaching sched-domain:
 domain 0: span 2-3 level SIBLING
  groups: 2 3
  domain 1: span 0-7 level CPU
   groups: 2-3 4-5 6-7 0-1
   domain 2: span 0-7 level NODE
    groups: 0-7
CPU3 attaching sched-domain:
 domain 0: span 2-3 level SIBLING
  groups: 3 2
  domain 1: span 0-7 level CPU
   groups: 2-3 4-5 6-7 0-1
   domain 2: span 0-7 level NODE
    groups: 0-7
CPU4 attaching sched-domain:
 domain 0: span 4-5 level SIBLING
  groups: 4 5
  domain 1: span 0-7 level CPU
   groups: 4-5 6-7 0-1 2-3
   domain 2: span 0-7 level NODE
    groups: 0-7
CPU5 attaching sched-domain:
 domain 0: span 4-5 level SIBLING
  groups: 5 4
  domain 1: span 0-7 level CPU
   groups: 4-5 6-7 0-1 2-3
   domain 2: span 0-7 level NODE
    groups: 0-7
CPU6 attaching sched-domain:
 domain 0: span 6-7 level SIBLING
  groups: 6 7
  domain 1: span 0-7 level CPU
   groups: 6-7 0-1 2-3 4-5
   domain 2: span 0-7 level NODE
    groups: 0-7
CPU7 attaching sched-domain:
 domain 0: span 6-7 level SIBLING
  groups: 7 6
  domain 1: span 0-7 level CPU
   groups: 6-7 0-1 2-3 4-5
   domain 2: span 0-7 level NODE
    groups: 0-7
net_namespace: 1152 bytes
NET: Registered protocol family 16
IBM eBus Device Driver
PCI: Probing PCI hardware
PCI: Probing PCI hardware done
SCSI subsystem initialized
libata version 3.00 loaded.
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
NET: Registered protocol family 2
Switched to high resolution mode on CPU 0
Switched to high resolution mode on CPU 1
Switched to high resolution mode on CPU 2
Switched to high resolution mode on CPU 3
Switched to high resolution mode on CPU 4
Switched to high resolution mode on CPU 5
Switched to high resolution mode on CPU 6
Switched to high resolution mode on CPU 7
IP route cache hash table entries: 65536 (order: 7, 524288 bytes)
TCP established hash table entries: 262144 (order: 10, 4194304 bytes)
TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
TCP: Hash tables configured (established 262144 bind 65536)
TCP reno registered
NET: Registered protocol family 1
checking if image is initramfs... it is
Freeing initrd memory: 3135k freed
IOMMU table initialized, virtual merging enabled
RTAS daemon started
audit: initializing netlink socket (disabled)
type=2000 audit(1219080539.432:1): initialized
RTAS: event: 952, Type: Platform Error, Severity: 2
HugeTLB registered 16 MB page size, pre-allocated 0 pages
HugeTLB registered 16 GB page size, pre-allocated 0 pages
HugeTLB registered 64 KB page size, pre-allocated 0 pages
Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
msgmni has been set to 3984
Block layer SCSI generic (bsg) driver version 0.4 loaded (major 254)
io scheduler noop registered
io scheduler anticipatory registered (default)
io scheduler deadline registered
io scheduler cfq registered
vio_register_driver: driver hvc_console registering
HVSI: registered 0 devices
Generic RTC Driver v1.07
Serial: 8250/16550 driver4 ports, IRQ sharing disabled
brd: module loaded
loop: module loaded
Intel(R) PRO/1000 Network Driver - version 7.3.20-k3-NAPI
Copyright (c) 1999-2006 Intel Corporation.
pcnet32.c:v1.35 21.Apr.2008 tsbogend@alpha.franken.de
e100: Intel(R) PRO/100 Network Driver, 3.5.23-k4-NAPI
e100: Copyright(c) 1999-2006 Intel Corporation
drivers/net/ibmveth.c: ibmveth: IBM i/pSeries Virtual Ethernet Driver 1.03
vio_register_driver: driver ibmveth registering
console [netcon0] enabled
netconsole: network logging started
Uniform Multi-Platform E-IDE driver
ipr: IBM Power RAID SCSI Device Driver version: 2.4.1 (April 24, 2007)
vio_register_driver: driver ibmvscsi registering
ibmvscsi 30000003: SRP_VERSION: 16.a
scsi0 : IBM POWER Virtual SCSI Adapter 1.5.8
ibmvscsi 30000003: partner initialization complete
ibmvscsi 30000003: sent SRP login
ibmvscsi 30000003: SRP_LOGIN succeeded
ibmvscsi 30000003: host srp version: 16.a, host partition tundro1 (1), OS 2, max io 262144
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi 0:0:1:0: Direct-Access     IBM      VDASD blkdev     0001 PQ: 0 ANSI: 4
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
scsi scan: INQUIRY result too short (5), using 36
st: Version 20080504, fixed bufsize 32768, s/g segs 256
Driver 'st' needs updating - please use bus_type methods
Driver 'sd' needs updating - please use bus_type methods
sd 0:0:1:0: [sda] 73400922 512-byte hardware sectors (37581 MB)
sd 0:0:1:0: [sda] Write Protect is off
sd 0:0:1:0: [sda] Mode Sense: 0c 00 00 08
sd 0:0:1:0: [sda] Write cache: disabled, read cache: disabled, doesn't support DPO or FUA
sd 0:0:1:0: [sda] 73400922 512-byte hardware sectors (37581 MB)
sd 0:0:1:0: [sda] Write Protect is off
sd 0:0:1:0: [sda] Mode Sense: 0c 00 00 08
sd 0:0:1:0: [sda] Write cache: disabled, read cache: disabled, doesn't support DPO or FUA
 sda: sda1 sda2 sda3 sda4 < sda5 sda6 sda7 >
sd 0:0:1:0: [sda] Attached SCSI disk
Driver 'sr' needs updating - please use bus_type methods
sd 0:0:1:0: Attached scsi generic sg0 type 0
ohci_hcd: 2006 August 04 USB 1.1 'Open' Host Controller (OHCI) Driver
Initializing USB Mass Storage driver...
usbcore: registered new interface driver usb-storage
USB Mass Storage support registered.
mice: PS/2 mouse device common for all mice
md: linear personality registered for level -1
md: raid0 personality registered for level 0
md: raid1 personality registered for level 1
device-mapper: ioctl: 4.14.0-ioctl (2008-04-23) initialised: dm-devel@redhat.com
usbcore: registered new interface driver hiddev
usbcore: registered new interface driver usbhid
usbhid: v2.6:USB HID core driver
oprofile: using ppc64/power6 performance monitoring.
IPv4 over IPv4 tunneling driver
TCP cubic registered
NET: Registered protocol family 17
RPC: Registered udp transport module.
RPC: Registered tcp transport module.
registered taskstats version 1
Freeing unused kernel memory: 292k freed
IBM eHEA ethernet device driver (Release EHEA_0092)
ehea: eth1: Jumbo frames are disabled
ehea: eth1 -> logical port id #2
kjournald starting.  Commit interval 5 seconds
EXT3-fs: mounted filesystem with ordered data mode.
Unable to find swap-space signature
EXT3 FS on sda6, internal journal
Unable to find swap-space signature
ehea: lan0: Physical port up
ehea: External switch port is backup port

--=-qNQjZzlx+a0TScHAYAQG--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
