Date: Wed, 23 Jan 2008 15:56:55 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] Fix boot problem in situations where the boot CPU is running on a memoryless node
Message-ID: <20080123155655.GB20156@csn.ul.ie>
References: <20080122214505.GA15674@aepfle.de> <Pine.LNX.4.64.0801221417480.1912@schroedinger.engr.sgi.com> <20080123075821.GA17713@aepfle.de> <20080123105044.GD21455@csn.ul.ie> <20080123121459.GA18631@aepfle.de> <20080123125236.GA18876@aepfle.de> <20080123135513.GA14175@csn.ul.ie> <Pine.LNX.4.64.0801231611160.20050@sbz-30.cs.Helsinki.FI> <Pine.LNX.4.64.0801231626320.21475@sbz-30.cs.Helsinki.FI> <Pine.LNX.4.64.0801231648140.23343@sbz-30.cs.Helsinki.FI>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801231648140.23343@sbz-30.cs.Helsinki.FI>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka J Enberg <penberg@cs.helsinki.fi>
Cc: akpm@linux-foundation.org, Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, hanth Aravamudan <nacc@us.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, lee.schermerhorn@hp.com, Linux MM <linux-mm@kvack.org>, Olaf Hering <olaf@aepfle.de>
List-ID: <linux-mm.kvack.org>

On (23/01/08 16:49), Pekka J Enberg didst pronounce:
> Hi,
> 
> On Wed, 23 Jan 2008, Pekka J Enberg wrote:
> > > I still think Christoph's kmem_getpages() patch is correct (to fix 
> > > cache_grow() oops) but I overlooked the fact that none the callers of 
> > > ____cache_alloc_node() deal with bootstrapping (with the exception of 
> > > __cache_alloc_node() that even has a comment about it).
> > 
> > So something like this (totally untested) patch on top of current git:
> 
> Sorry, removed a BUG_ON() from cache_alloc_refill() by mistake, here's a 
> better one:
> 

Applied in combination with the N_NORMAL_MEMORY revert and it fails to
boot. Console is as follows;

Linux version 2.6.24-rc8-autokern1 (root@gekko-lp3.ltc.austin.ibm.com)
(gcc version 3.4.6 20060404 (Red Hat 3.4.6-3)) #2 SMP Wed Jan 23
10:37:36 EST 2008
[boot]0012 Setup Arch
EEH: PCI Enhanced I/O Error Handling Enabled
PPC64 nvram contains 7168 bytes
Zone PFN ranges:
  DMA             0 ->  1048576
  Normal    1048576 ->  1048576
Movable zone start PFN for each node
early_node_map[1] active PFN ranges
    2:        0 ->  1048576
Could not find start_pfn for node 0
[boot]0015 Setup Done
Built 2 zonelists in Node order, mobility grouping on.  Total pages: 1034240
Policy zone: DMA
Kernel command line: ro console=hvc0 autobench_args: root=/dev/sda6
ABAT:1201101591 loglevel=8 
[boot]0020 XICS Init
xics: no ISA interrupt controller
[boot]0021 XICS Done
PID hash table entries: 4096 (order: 12, 32768 bytes)
time_init: decrementer frequency = 238.059000 MHz
time_init: processor frequency   = 1904.472000 MHz
clocksource: timebase mult[10cd746] shift[22] registered
clockevent: decrementer mult[3cf1] shift[16] cpu[0]
Console: colour dummy device 80x25
console handover: boot [udbg0] -> real [hvc0]
Dentry cache hash table entries: 524288 (order: 10, 4194304 bytes)
Inode-cache hash table entries: 262144 (order: 9, 2097152 bytes)
freeing bootmem node 2
Memory: 4105560k/4194304k available (5004k kernel code, 88744k reserved,
876k data, 559k bss, 272k init)
Unable to handle kernel paging request for data at address 0x00000040
Faulting instruction address: 0xc0000000003c8ae8
cpu 0x0: Vector: 300 (Data Access) at [c0000000005c3840]
    pc: c0000000003c8ae8: __lock_text_start+0x20/0x88
    lr: c0000000000dadb4: .cache_grow+0x7c/0x338
    sp: c0000000005c3ac0
   msr: 8000000000009032
   dar: 40
 dsisr: 40000000
  current = 0xc000000000500f10
  paca    = 0xc000000000501b80
    pid   = 0, comm = swapper
enter ? for help
[c0000000005c3b40] c0000000000dadb4 .cache_grow+0x7c/0x338
[c0000000005c3c00] c0000000000db518 .fallback_alloc+0x1c0/0x224
[c0000000005c3cb0] c0000000000db920 .kmem_cache_alloc+0xe0/0x14c
[c0000000005c3d50] c0000000000dcbd0 .kmem_cache_create+0x230/0x4cc
[c0000000005c3e30] c0000000004c049c .kmem_cache_init+0x1ec/0x51c
[c0000000005c3ee0] c00000000049f8d8 .start_kernel+0x304/0x3fc
[c0000000005c3f90] c000000000008594 .start_here_common+0x54/0xc0

0xc0000000000dadb4 is in cache_grow (mm/slab.c:2782).
2777            local_flags = flags & (GFP_CONSTRAINT_MASK|GFP_RECLAIM_MASK);
2778    
2779            /* Take the l3 list lock to change the colour_next on this node */
2780            check_irq_off();
2781            l3 = cachep->nodelists[nodeid];
2782            spin_lock(&l3->list_lock);
2783    
2784            /* Get colour for the slab, and cal the next value. */
2785            offset = l3->colour_next;
2786            l3->colour_next++;

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
