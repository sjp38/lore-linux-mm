Date: Thu, 17 Jan 2008 22:15:11 +0100
From: Olaf Hering <olaf@aepfle.de>
Subject: Re: crash in kmem_cache_init
Message-ID: <20080117211511.GA25320@aepfle.de>
References: <20080115150949.GA14089@aepfle.de> <84144f020801170414q7d408a74uf47a84b777c36a4a@mail.gmail.com> <Pine.LNX.4.64.0801170628580.19208@schroedinger.engr.sgi.com> <20080117181222.GA24411@aepfle.de> <Pine.LNX.4.64.0801171049190.21058@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801171049190.21058@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 17, Christoph Lameter wrote:

> On Thu, 17 Jan 2008, Olaf Hering wrote:
> 
> > The patch does not help.
> 
> Duh. We need to know more about the problem.

cache_grow is called from 3 places. The third call has cleared l3 for
some reason.


....
Allocated 00a00000 bytes for kernel @ 00200000
   Elf64 kernel loaded...
OF stdout device is: /vdevice/vty@30000000
Hypertas detected, assuming LPAR !
command line:  xmon=on sysrq=1 debug panic=1 
memory layout at init:
  alloc_bottom : 0000000000ac1000
  alloc_top    : 0000000010000000
  alloc_top_hi : 00000000da000000
  rmo_top      : 0000000010000000
  ram_top      : 00000000da000000
Looking for displays
found display   : /pci@800000020000002/pci@2/pci@1/display@0, opening ... done
instantiating rtas at 0x000000000f6a1000 ... done
0000000000000000 : boot cpu     0000000000000000
0000000000000002 : starting cpu hw idx 0000000000000002... done
0000000000000004 : starting cpu hw idx 0000000000000004... done
0000000000000006 : starting cpu hw idx 0000000000000006... done
copying OF device tree ...
Building dt strings...
Building dt structure...
Device tree strings 0x0000000000cc2000 -> 0x0000000000cc34e4
Device tree struct  0x0000000000cc4000 -> 0x0000000000cd6000
Calling quiesce ...
returning from prom_init
Partition configured for 8 cpus.
Starting Linux PPC64 #34 SMP Thu Jan 17 22:06:41 CET 2008
-----------------------------------------------------
ppc64_pft_size                = 0x1c
physicalMemorySize            = 0xda000000
htab_hash_mask                = 0x1fffff
-----------------------------------------------------
Linux version 2.6.24-rc8-ppc64 (olaf@lingonberry) (gcc version 4.1.2 20070115 (prerelease) (SUSE Linux)) #34 SMP Thu Jan 17 22:06:41 CET 2008
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
Kernel command line:  xmon=on sysrq=1 debug panic=1 
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
Memory: 3496633k/3571712k available (6188k kernel code, 75080k reserved, 1324k data, 1220k bss, 304k init)
cache_grow(2778) swapper(0):c0,j4294937299 cachep c0000000006a4fb8 nodeid 0 l3 c0000000005fddf0
cache_grow(2778) swapper(0):c0,j4294937299 cachep c0000000006a4fb8 nodeid 1 l3 c0000000005fddf0
cache_grow(2778) swapper(0):c0,j4294937299 cachep c0000000006a4fb8 nodeid 2 l3 c0000000005fddf0
cache_grow(2778) swapper(0):c0,j4294937299 cachep c0000000006a4fb8 nodeid 3 l3 c0000000005fddf0
------------[ cut here ]------------
Badness at /home/olaf/kernel/git/linux-2.6.24-rc8/mm/slab.c:2779
NIP: c0000000000f78f4 LR: c0000000000f78e0 CTR: 80000000001af404
REGS: c00000000075b880 TRAP: 0700   Not tainted  (2.6.24-rc8-ppc64)
MSR: 8000000000029032 <EE,ME,IR,DR>  CR: 24000022  XER: 00000001
TASK = c000000000665a50[0] 'swapper' THREAD: c000000000758000 CPU: 0
GPR00: 0000000000000004 c00000000075bb00 c0000000007544c0 0000000000000063 
GPR04: 0000000000000001 0000000000000001 0000000000000000 0000000000000000 
GPR08: ffffffffffffffff c0000000006a19a0 c0000000007a84b0 c0000000007a84a8 
GPR12: 0000000000004000 c000000000666380 0000000000000000 0000000000000000 
GPR16: 0000000000000000 0000000000000000 0000000000000000 4000000000200000 
GPR20: 0000000000000000 00000000007fbd70 c00000000054f6c8 00000000000492d0 
GPR24: 0000000000000000 c0000000006a4fb8 c0000000006a4fb8 c0000000005fdc80 
GPR28: 0000000000000000 00000000000412d0 c0000000006e5b80 0000000000000004 
NIP [c0000000000f78f4] .cache_grow+0xc8/0x39c
LR [c0000000000f78e0] .cache_grow+0xb4/0x39c
Call Trace:
[c00000000075bb00] [c0000000000f78e0] .cache_grow+0xb4/0x39c (unreliable)
[c00000000075bbd0] [c0000000000f82d0] .cache_alloc_refill+0x234/0x2c0
[c00000000075bc90] [c0000000000f842c] .kmem_cache_alloc+0xd0/0x294
[c00000000075bd40] [c0000000000fb4e8] .kmem_cache_create+0x208/0x478
[c00000000075be20] [c0000000005e670c] .kmem_cache_init+0x218/0x4f4
[c00000000075bee0] [c0000000005bf8ec] .start_kernel+0x2f8/0x3fc
[c00000000075bf90] [c000000000008590] .start_here_common+0x60/0xd0
Instruction dump:
e89e80e0 e92a0000 e80b0468 7f4ad378 fbe10070 f8010078 4bf85f01 60000000 
381f0001 7c1f07b4 2f9f0004 409effac <0fe00000> 7b091f24 7d29d214 eb690468 
cache_grow(2778) swapper(0):c0,j4294937299 cachep c0000000006a4fb8 nodeid 0 l3 c0000000005fddf0
cache_grow(2778) swapper(0):c0,j4294937299 cachep c0000000006a4fb8 nodeid 1 l3 c0000000005fddf0
cache_grow(2778) swapper(0):c0,j4294937299 cachep c0000000006a4fb8 nodeid 2 l3 c0000000005fddf0
cache_grow(2778) swapper(0):c0,j4294937299 cachep c0000000006a4fb8 nodeid 3 l3 c0000000005fddf0
------------[ cut here ]------------
Badness at /home/olaf/kernel/git/linux-2.6.24-rc8/mm/slab.c:2779
NIP: c0000000000f78f4 LR: c0000000000f78e0 CTR: 80000000001af404
REGS: c00000000075b890 TRAP: 0700   Not tainted  (2.6.24-rc8-ppc64)
MSR: 8000000000029032 <EE,ME,IR,DR>  CR: 24000022  XER: 00000001
TASK = c000000000665a50[0] 'swapper' THREAD: c000000000758000 CPU: 0
GPR00: 0000000000000004 c00000000075bb10 c0000000007544c0 0000000000000063 
GPR04: 0000000000000001 0000000000000001 0000000000000000 0000000000000000 
GPR08: ffffffffffffffff c0000000006a19a0 c0000000007a84b0 c0000000007a84a8 
GPR12: 0000000000004000 c000000000666380 0000000000000000 0000000000000000 
GPR16: 0000000000000000 0000000000000000 0000000000000000 4000000000200000 
GPR20: 0000000000000000 00000000007fbd70 c00000000054f6c8 00000000000492d0 
GPR24: 0000000000000000 00000000000080d0 c0000000006a4fb8 c0000000006a4fb8 
GPR28: 0000000000000000 00000000000412d0 c0000000006e5b80 0000000000000004 
NIP [c0000000000f78f4] .cache_grow+0xc8/0x39c
LR [c0000000000f78e0] .cache_grow+0xb4/0x39c
Call Trace:
[c00000000075bb10] [c0000000000f78e0] .cache_grow+0xb4/0x39c (unreliable)
[c00000000075bbe0] [c0000000000f7f38] .____cache_alloc_node+0x17c/0x1e8
[c00000000075bc90] [c0000000000f846c] .kmem_cache_alloc+0x110/0x294
[c00000000075bd40] [c0000000000fb4e8] .kmem_cache_create+0x208/0x478
[c00000000075be20] [c0000000005e670c] .kmem_cache_init+0x218/0x4f4
[c00000000075bee0] [c0000000005bf8ec] .start_kernel+0x2f8/0x3fc
[c00000000075bf90] [c000000000008590] .start_here_common+0x60/0xd0
Instruction dump:
e89e80e0 e92a0000 e80b0468 7f4ad378 fbe10070 f8010078 4bf85f01 60000000 
381f0001 7c1f07b4 2f9f0004 409effac <0fe00000> 7b091f24 7d29d214 eb690468 
cache_grow(2778) swapper(0):c0,j4294937299 cachep c0000000006a4fb8 nodeid 0 l3 0000000000000000
cache_grow(2778) swapper(0):c0,j4294937299 cachep c0000000006a4fb8 nodeid 1 l3 0000000000000000
cache_grow(2778) swapper(0):c0,j4294937299 cachep c0000000006a4fb8 nodeid 2 l3 0000000000000000
cache_grow(2778) swapper(0):c0,j4294937299 cachep c0000000006a4fb8 nodeid 3 l3 0000000000000000
------------[ cut here ]------------
Badness at /home/olaf/kernel/git/linux-2.6.24-rc8/mm/slab.c:2779
NIP: c0000000000f78f4 LR: c0000000000f78e0 CTR: 80000000001af404
REGS: c00000000075b890 TRAP: 0700   Not tainted  (2.6.24-rc8-ppc64)
MSR: 8000000000029032 <EE,ME,IR,DR>  CR: 24000022  XER: 00000001
TASK = c000000000665a50[0] 'swapper' THREAD: c000000000758000 CPU: 0
GPR00: 0000000000000004 c00000000075bb10 c0000000007544c0 0000000000000063 
GPR04: 0000000000000001 0000000000000001 0000000000000000 0000000000000000 
GPR08: ffffffffffffffff c0000000006a19a0 c0000000007a84b0 c0000000007a84a8 
GPR12: 0000000000004000 c000000000666380 0000000000000000 0000000000000000 
GPR16: 0000000000000000 0000000000000000 0000000000000000 4000000000200000 
GPR20: 0000000000000000 00000000007fbd70 c00000000054f6c8 00000000000080d0 
GPR24: 0000000000000001 c0000000d9fe4b00 c0000000006a4fb8 0000000000000000 
GPR28: c0000000d8000000 00000000000000d0 c0000000006e5b80 0000000000000004 
NIP [c0000000000f78f4] .cache_grow+0xc8/0x39c
LR [c0000000000f78e0] .cache_grow+0xb4/0x39c
Call Trace:
[c00000000075bb10] [c0000000000f78e0] .cache_grow+0xb4/0x39c (unreliable)
[c00000000075bbe0] [c0000000000f7d68] .fallback_alloc+0x1a0/0x1f4
[c00000000075bc90] [c0000000000f846c] .kmem_cache_alloc+0x110/0x294
[c00000000075bd40] [c0000000000fb4e8] .kmem_cache_create+0x208/0x478
[c00000000075be20] [c0000000005e670c] .kmem_cache_init+0x218/0x4f4
[c00000000075bee0] [c0000000005bf8ec] .start_kernel+0x2f8/0x3fc
[c00000000075bf90] [c000000000008590] .start_here_common+0x60/0xd0
Instruction dump:
e89e80e0 e92a0000 e80b0468 7f4ad378 fbe10070 f8010078 4bf85f01 60000000 
381f0001 7c1f07b4 2f9f0004 409effac <0fe00000> 7b091f24 7d29d214 eb690468 
Unable to handle kernel paging request for data at address 0x00000040
Faulting instruction address: 0xc0000000004377b8
cpu 0x0: Vector: 300 (Data Access) at [c00000000075b810]
    pc: c0000000004377b8: ._spin_lock+0x20/0x88
    lr: c0000000000f790c: .cache_grow+0xe0/0x39c
    sp: c00000000075ba90
   msr: 8000000000009032
   dar: 40
 dsisr: 40000000
  current = 0xc000000000665a50
  paca    = 0xc000000000666380
    pid   = 0, comm = swapper
enter ? for help
[c00000000075bb10] c0000000000f790c .cache_grow+0xe0/0x39c
[c00000000075bbe0] c0000000000f7d68 .fallback_alloc+0x1a0/0x1f4
[c00000000075bc90] c0000000000f846c .kmem_cache_alloc+0x110/0x294
[c00000000075bd40] c0000000000fb4e8 .kmem_cache_create+0x208/0x478
[c00000000075be20] c0000000005e670c .kmem_cache_init+0x218/0x4f4
[c00000000075bee0] c0000000005bf8ec .start_kernel+0x2f8/0x3fc
[c00000000075bf90] c000000000008590 .start_here_common+0x60/0xd0
0:mon> 



-- 
Used patch:

Index: linux-2.6.24-rc8/include/linux/olh.h
===================================================================
--- /dev/null
+++ linux-2.6.24-rc8/include/linux/olh.h
@@ -0,0 +1,6 @@
+#ifndef __LINUX_OLH_H
+#define __LINUX_OLH_H
+#define olh(fmt,args ...) \
+        printk(KERN_DEBUG "%s(%u) %s(%u):c%u,j%lu " fmt "\n",__FUNCTION__,__LINE__,current->comm,current->pid,smp_processor_id(),jiffies,##args)
+#endif
+
Index: linux-2.6.24-rc8/mm/slab.c
===================================================================
--- linux-2.6.24-rc8.orig/mm/slab.c
+++ linux-2.6.24-rc8/mm/slab.c
@@ -110,6 +110,7 @@
 #include       <linux/fault-inject.h>
 #include       <linux/rtmutex.h>
 #include       <linux/reciprocal_div.h>
+#include       <linux/olh.h>

 #include       <asm/cacheflush.h>
 #include       <asm/tlbflush.h>
@@ -2764,6 +2765,7 @@ static int cache_grow(struct kmem_cache 
        size_t offset;
        gfp_t local_flags;
        struct kmem_list3 *l3;
+       int i;
 
        /*
         * Be lazy and only check for valid flags here,  keeping it out of the
@@ -2772,6 +2774,9 @@ static int cache_grow(struct kmem_cache 
        BUG_ON(flags & GFP_SLAB_BUG_MASK);
        local_flags = flags & (GFP_CONSTRAINT_MASK|GFP_RECLAIM_MASK);
 
+       for (i=0;i<4;i++)
+               olh("cachep %p nodeid %d l3 %p",cachep,i,cachep->nodelists[nodeid]);
+       WARN_ON(1);
        /* Take the l3 list lock to change the colour_next on this node */
        check_irq_off();
        l3 = cachep->nodelists[nodeid];

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
