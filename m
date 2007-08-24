Date: Fri, 24 Aug 2007 09:58:47 +0100
Subject: Re: [BUG] 2.6.23-rc3-mm1 kernel BUG at mm/page_alloc.c:2876!
Message-ID: <20070824085846.GA30592@skynet.ie>
References: <46CC9A7A.2030404@linux.vnet.ibm.com> <20070822134800.ce5a5a69.akpm@linux-foundation.org> <20070822135024.dde8ef5a.akpm@linux-foundation.org> <20070823130732.GC18456@skynet.ie> <46CDC11E.2010008@linux.vnet.ibm.com> <Pine.LNX.4.64.0708231303050.14720@schroedinger.engr.sgi.com> <46CE776D.2010408@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <46CE776D.2010408@linux.vnet.ibm.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Cc: Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On (24/08/07 11:45), Kamalesh Babulal didst pronounce:
> Christoph Lameter wrote:
> >On Thu, 23 Aug 2007, Kamalesh Babulal wrote:
> >
> >  
> >>After applying the patch, the call trace is gone but the kernel bug
> >>is still hit
> >>    
> >
> >Yes that is what we expected. We need more information to figure out why 
> >the kmalloc_node fails there. It should walk through all nodes to find 
> >memory.
> >
> >I see that you have 4 cpus and 16 nodes. How are the cpus assigned to 
> >nodes? If a cpu would be assigned to a nonexisting node then this could be 
> >the result.
> >
> >Could you post the full boot log?
> >
> >  
> boot log with the andrew patch applied
> 
> Welcome to yaboot version 1.3.13
> Enter "help" to get some basic usage information
> boot: autobench
> Please wait, loading kernel...
> Elf64 kernel loaded...
> Loading ramdisk...
> ramdisk loaded at 02400000, size: 1191 Kbytes
> OF stdout device is: /vdevice/vty@30000000
> Hypertas detected, assuming LPAR !
> command line: ro console=hvc0 autobench_args: root=/dev/sda6 
> ABAT:1187885681
> memory layout at init:
> alloc_bottom : 000000000252a000
> alloc_top : 0000000008000000
> alloc_top_hi : 0000000100000000
> rmo_top : 0000000008000000
> ram_top : 0000000100000000
> Looking for displays
> instantiating rtas at 0x00000000077d9000 ... done
> 0000000000000000 : boot cpu 0000000000000000
> 0000000000000002 : starting cpu hw idx 0000000000000002... done
> copying OF device tree ...
> Building dt strings...
> Building dt structure...
> Device tree strings 0x000000000262b000 -> 0x000000000262c1d3
> Device tree struct 0x000000000262d000 -> 0x0000000002635000
> Calling quiesce ...
> returning from prom_init
> Partition configured for 4 cpus.
> 
> 
> Starting Linux PPC64 #1 SMP Thu Aug 23 11:54:44 EDT 2007
> -----------------------------------------------------
> ppc64_pft_size = 0x1a
> physicalMemorySize = 0x100000000
> ppc64_caches.dcache_line_size = 0x80
> ppc64_caches.icache_line_size = 0x80
> htab_address = 0x0000000000000000
> htab_hash_mask = 0x7ffff
> -----------------------------------------------------
> Linux version 2.6.23-rc3-mm1-autokern1 
> (root@gekko-lp3.ltc.austin.ibm.com) (gcc version 3.4.6 20060404 (Red Hat 
> 3.4.6-3)) #1 SMP Thu Aug 23 11:54:44 EDT 2007
> [boot]0012 Setup Arch
> vmemmap cf00000000000000 allocated at c000000001000000, physical 
> 0000000001000000.
> vmemmap cf00000001000000 allocated at c000000004000000, physical 
> 0000000004000000.
> vmemmap cf00000002000000 allocated at c000000005000000, physical 
> 0000000005000000.
> vmemmap cf00000003000000 allocated at c000000006000000, physical 
> 0000000006000000.
> EEH: PCI Enhanced I/O Error Handling Enabled
> PPC64 nvram contains 7168 bytes
> Zone PFN ranges:
> DMA 0 -> 1048576
> Normal 1048576 -> 1048576
> Movable zone start PFN for each node
> early_node_map[1] active PFN ranges
> 2: 0 -> 1048576
> Could not find start_pfn for node 0
> [boot]0015 Setup Done
> Built 2 zonelists in Node order, mobility grouping off. Total pages: 0

This indicates to me that the zonelists are trashed. All memory is on
zone 2 according to early_node_map[] and the CPU is most likely part of
node 0 that doesn't have a proper fallback list

> Policy zone: DMA
> Kernel command line: ro console=hvc0 autobench_args: root=/dev/sda6 
> ABAT:1187885681
> [boot]0020 XICS Init
> [boot]0021 XICS Done
> PID hash table entries: 4096 (order: 12, 32768 bytes)
> Console: colour dummy device 80x25
> console handover: boot [udbg0] -> real [hvc0]
> Dentry cache hash table entries: 524288 (order: 10, 4194304 bytes)
> Inode-cache hash table entries: 262144 (order: 9, 2097152 bytes)
> freeing bootmem node 2
> Memory: 4105840k/4194304k available (4964k kernel code, 88464k reserved, 
> 948k data, 571k bss, 264k init)
> SLUB: Genslabs=12, HWalign=128, Order=0-1, MinObjects=4, CPUs=4, Nodes=16
> ------------[ cut here ]------------
> kernel BUG at mm/page_alloc.c:2878!
> cpu 0x0: Vector: 700 (Program Check) at [c0000000005cbbe0]
> pc: c0000000004b5160: .setup_per_cpu_pageset+0x24/0x48
> lr: c0000000004b5160: .setup_per_cpu_pageset+0x24/0x48
> sp: c0000000005cbe60
> msr: 8000000000029032
> current = 0xc0000000004fd1b0
> paca = 0xc0000000004fdd80
> pid = 0, comm = swapper
> kernel BUG at mm/page_alloc.c:2878!
> enter ? for help
> [c0000000005cbee0] c0000000004978d8 .start_kernel+0x304/0x3f4
> [c0000000005cbf90] c0000000003bef1c .start_here_common+0x54/0x58
> 
> -
> Kamalesh Babulal.
> 
> 
> 

-- 
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
