Date: Tue, 22 Jan 2008 22:45:05 +0100
From: Olaf Hering <olaf@aepfle.de>
Subject: Re: crash in kmem_cache_init
Message-ID: <20080122214505.GA15674@aepfle.de>
References: <84144f020801170414q7d408a74uf47a84b777c36a4a@mail.gmail.com> <Pine.LNX.4.64.0801170628580.19208@schroedinger.engr.sgi.com> <20080117181222.GA24411@aepfle.de> <Pine.LNX.4.64.0801171049190.21058@schroedinger.engr.sgi.com> <20080117211511.GA25320@aepfle.de> <Pine.LNX.4.64.0801181043290.30348@schroedinger.engr.sgi.com> <20080118213011.GC10491@csn.ul.ie> <Pine.LNX.4.64.0801181414200.8924@schroedinger.engr.sgi.com> <20080118225713.GA31128@aepfle.de> <20080122195448.GA15567@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20080122195448.GA15567@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Christoph Lameter <clameter@sgi.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, hanth Aravamudan <nacc@us.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, lee.schermerhorn@hp.com, Linux MM <linux-mm@kvack.org>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 22, Mel Gorman wrote:

> http://www.csn.ul.ie/~mel/postings/slab-20080122/partial-revert-slab-changes.patch
> .. Can you please check on your machine if it fixes your problem?

It does not fix or change the nature of the crash.

> Olaf, please confirm whether you need the patch below as well as the
> revert to make your machine boot.

It crashes now in a different way if the patch below is applied:

Linux version 2.6.24-rc8-ppc64 (olaf@lingonberry) (gcc version 4.1.2 20070115 (prerelease) (SUSE Linux)) #43 SMP Tue Jan 22 22:39:05 CET 2008
[boot]0012 Setup Arch
EEH: PCI Enhanced I/O Error Handling Enabled
PPC64 nvram contains 8192 bytes
Zone PFN ranges:
  DMA             0 ->   892928
  Normal     892928 ->   892928
Movable zone start PFN for each node
early_node_map[1] active PFN ranges
    1:        0 ->   892928
Could not find start_pfn for node 0
[boot]0015 Setup Done
Built 2 zonelists in Node order, mobility grouping on.  Total pages: 880720
Policy zone: DMA
Kernel command line: debug xmon=on panic=1  
[boot]0020 XICS Init
xics: no ISA interrupt controller
[boot]0021 XICS Done
PID hash table entries: 4096 (order: 12, 32768 bytes)
time_init: decrementer frequency = 275.070000 MHz
time_init: processor frequency   = 2197.800000 MHz
clocksource: timebase mult[e8ab05] shift[22] registered
clockevent: decrementer mult[466a] shift[16] cpu[0]
Console: colour dummy device 80x25
console handover: boot [udbg-1] -> real [hvc0]
Dentry cache hash table entries: 524288 (order: 10, 4194304 bytes)
Inode-cache hash table entries: 262144 (order: 9, 2097152 bytes)
freeing bootmem node 1
Memory: 3496632k/3571712k available (6188k kernel code, 75080k reserved, 1324k data, 1220k bss, 304k init)
Unable to handle kernel paging request for data at address 0x00000058
Faulting instruction address: 0xc0000000000fe018
cpu 0x0: Vector: 300 (Data Access) at [c00000000075bac0]
    pc: c0000000000fe018: .setup_cpu_cache+0x184/0x1f4
    lr: c0000000000fdfa8: .setup_cpu_cache+0x114/0x1f4
    sp: c00000000075bd40
   msr: 8000000000009032
   dar: 58
 dsisr: 42000000
  current = 0xc000000000665a50
  paca    = 0xc000000000666380
    pid   = 0, comm = swapper
enter ? for help
[c00000000075bd40] c0000000000fb368 .kmem_cache_create+0x3c0/0x478 (unreliable)
[c00000000075be20] c0000000005e6780 .kmem_cache_init+0x284/0x4f4
[c00000000075bee0] c0000000005bf8ec .start_kernel+0x2f8/0x3fc
[c00000000075bf90] c000000000008590 .start_here_common+0x60/0xd0
0:mon> 

0xc0000000000fe018 is in setup_cpu_cache (/home/olaf/kernel/git/linux-2.6-numa/mm/slab.c:2111).
2106                                    BUG_ON(!cachep->nodelists[node]);
2107                                    kmem_list3_init(cachep->nodelists[node]);
2108                            }
2109                    }
2110            }
2111            cachep->nodelists[numa_node_id()]->next_reap =
2112                            jiffies + REAPTIMEOUT_LIST3 +
2113                            ((unsigned long)cachep) % REAPTIMEOUT_LIST3;
2114
2115            cpu_cache_get(cachep)->avail = 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
