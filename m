Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C84426B003D
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 07:31:22 -0400 (EDT)
Date: Thu, 30 Apr 2009 12:31:47 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [BUG] 2.6.30-rc3-mmotm-090428-1814 -- bogus pointer deref
Message-ID: <20090430113146.GA21997@csn.ul.ie>
References: <1241037299.6693.97.camel@lts-notebook>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1241037299.6693.97.camel@lts-notebook>
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, linux-numa <linux-numa@vger.kernel.org>, Doug Chapman <doug.chapman@hp.com>, Eric Whitney <eric.whitney@hp.com>, Bjorn Helgaas <bjorn.helgaas@hp.com>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 29, 2009 at 04:34:59PM -0400, Lee Schermerhorn wrote:
> I'm seeing this on an ia64 platform--HP rx8640--running the numactl
> package regression test.  On ia64 a "NaT Consumption" [NaT = "not a
> thing"] usually means a bogus pointer.  I verified that it also occurs
> on 2.6.30-rc3-mmotm-090424-1814.  The regression test runs to completion
> on a 4-node x86_64 platform for both the 04/27 and 04/28 mmotm kernels.
> 
> The bug occurs right after the test suite issues the message:
> 
> "testing numactl --interleave=all memhog 15728640"
> 
> -------------------------------
> Console log:
> 
> numactl[7821]: NaT consumption 2216203124768 [2]
> Modules linked in: ipv6 nfs lockd fscache nfs_acl auth_rpcgss sunrpc vfat fat dm_mirror dm_multipath scsi_dh pci_slot parport_pc lp parport sg sr_mod cdrom button e1000 tg3 libphy dm_region_hash dm_log dm_mod sym53c8xx mptspi mptscsih mptbase scsi_transport_spi sd_mod scsi_mod ext3 jbd uhci_hcd ohci_hcd ehci_hcd [last unloaded: freq_table]
> 
> Pid: 7821, CPU 25, comm:              numactl
> psr : 0000121008022038 ifs : 8000000000000004 ip  : [<a00000010014ec91>]    Not tainted (2.6.30-rc3-mmotm-090428-1631)
> ip is at next_zones_zonelist+0x31/0x120

What line is this?

> unat: 0000000000000000 pfs : 000000000000038b rsc : 0000000000000003
> rnat: 0000001008022038 bsps: e0000702c094e000 pr  : 0000000000659a65
> ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c0270033f
> csd : 0000000000000000 ssd : 0000000000000000
> b0  : a00000010018dd30 b6  : a0000001000414c0 b7  : a000000100474660
> f6  : 1003e3d64d824615cef9c f7  : 1003e9e3779b97f4a7c16
> f8  : 1003e0a00000010071e2a f9  : 1003e0000000000000001
> f10 : 1003e0000000000000003 f11 : 1003e8208208208208209
> r1  : a000000100c647c0 r2  : 0000000000001f90 r3  : 0000000000000000
> r8  : 0000000000001f88 r9  : 0000000000000000 r10 : 0000000000000000
> r11 : 0000000000000000 r12 : e0000803859eaad0 r13 : e0000803859e8000
> r14 : 0000000000000000 r15 : ffffffffffffff80 r16 : e000078000113c38
> r17 : 0000000000000000 r18 : 0000000000000006 r19 : e000078000113c08
> r20 : 0000000000000000 r21 : e000078000113c00 r22 : 0000000000000000
> r23 : ffffffffffff04d8 r24 : e0000803859e8cb8 r25 : 000000000000033c
> r26 : e0000803859eab60 r27 : e0000803859eab54 r28 : e0000803859eab58
> r29 : 000000007fffffff r30 : 000000000000033c r31 : 000000000000033c
> 
> Call Trace:
>  [<a000000100015660>] show_stack+0x40/0xa0
>                                 sp=e0000803859ec690 bsp=e0000803859ec670
>  [<a000000100015f90>] show_regs+0x870/0x8c0
>                                 sp=e0000803859ec860 bsp=e0000803859ec618
>  [<a0000001000398b0>] die+0x1b0/0x2c0
>                                 sp=e0000803859ec860 bsp=e0000803859ec5c8
>  [<a000000100039a10>] die_if_kernel+0x50/0x80
>                                 sp=e0000803859ec860 bsp=e0000803859ec598
> 
> 
> This is all I see.  Apparently system locked up. 
> 
> ------------------
> 
> Here's the memory init debug info:
> 
> Zone PFN ranges:
>   DMA      0x00000001 -> 0x00040000
>   Normal   0x00040000 -> 0x220ff000
> Movable zone start PFN for each node
> early_node_map[6] active PFN ranges
>     4: 0x00000001 -> 0x00007ffa
>     0: 0x1c008000 -> 0x1c0fec00
>     1: 0x1e000000 -> 0x1e0ff000
>     2: 0x20000000 -> 0x200ff000
>     3: 0x22000000 -> 0x220fef67
>     3: 0x220fefa0 -> 0x220feff6
> mminit::pageflags_layout_widths Section 0 Node 6 Zone 2 Flags 23
> mminit::pageflags_layout_shifts Section 20 Node 6 Zone 2
> mminit::pageflags_layout_offsets Section 0 Node 58 Zone 56
> mminit::pageflags_layout_zoneid Zone ID: 56 -> 64
> mminit::pageflags_layout_usage location: 64 -> 56 unused 56 -> 23 flags 23 -> 0
> On node 0 totalpages: 1010688
>   Normal zone: 3948 pages used for memmap
>   Normal zone: 1006740 pages, LIFO batch:7
> mminit::memmap_init Initialising map node 0 zone 1 pfns 469794816 -> 470805504
> On node 1 totalpages: 1044480
>   Normal zone: 4080 pages used for memmap
>   Normal zone: 1040400 pages, LIFO batch:7
> mminit::memmap_init Initialising map node 1 zone 1 pfns 503316480 -> 504360960
> On node 2 totalpages: 1044480
>   Normal zone: 4080 pages used for memmap
>   Normal zone: 1040400 pages, LIFO batch:7
> mminit::memmap_init Initialising map node 2 zone 1 pfns 536870912 -> 537915392
> On node 3 totalpages: 1044413
>   Normal zone: 4080 pages used for memmap
>   Normal zone: 1040333 pages, LIFO batch:7
> mminit::memmap_init Initialising map node 3 zone 1 pfns 570425344 -> 571469814
> On node 4 totalpages: 32761
>   DMA zone: 128 pages used for memmap
>   DMA zone: 0 pages reserved
>   DMA zone: 32633 pages, LIFO batch:7
> mminit::memmap_init Initialising map node 4 zone 0 pfns 1 -> 32762
> mminit::zonelist general 0:Normal = 0:Normal 1:Normal 2:Normal 3:Normal 4:DMA
> mminit::zonelist thisnode 0:Normal = 0:Normal
> mminit::zonelist general 1:Normal = 1:Normal 2:Normal 3:Normal 0:Normal 4:DMA
> mminit::zonelist thisnode 1:Normal = 1:Normal
> mminit::zonelist general 2:Normal = 2:Normal 3:Normal 0:Normal 1:Normal 4:DMA
> mminit::zonelist thisnode 2:Normal = 2:Normal
> mminit::zonelist general 3:Normal = 3:Normal 0:Normal 1:Normal 2:Normal 4:DMA
> mminit::zonelist thisnode 3:Normal = 3:Normal
> mminit::zonelist general 4:DMA = 4:DMA
> mminit::zonelist thisnode 4:DMA = 4:DMA
> Built 5 zonelists in Zone order, mobility grouping on.  Total pages: 4160506
> 
> Note that this platform has a small [~512MB] pseudo-node #4 that
> contains DMA only.  Here's the 'numactl --hardware' output:
> 

What is a pseudo-node?

> available: 5 nodes (0-4)
> node 0 size: 15792 MB
> node 0 free: 14908 MB
> node 1 size: 16320 MB
> node 1 free: 15985 MB
> node 2 size: 16320 MB
> node 2 free: 16106 MB
> node 3 size: 16318 MB
> node 3 free: 16146 MB
> node 4 size: 511 MB
> node 4 free: 495 MB
> node distances:
> node   0   1   2   3   4 
>   0:  10  17  17  17  14 
>   1:  17  10  17  17  14 
>   2:  17  17  10  17  14 
>   3:  17  17  17  10  14 
>   4:  14  14  14  14  10 
> 
> If I create a cpuset with "mems" 0-3 -- i.e., eliminate the dma-only
> node 4 -- I do not hit the this "Nat Consumption" bug.  The x86_64 test
> platform doesn't have this "feature".
> 
> I suspect that the page alloc optimizations are making assumptions that
> aren't true for this platform. 

Based on the timing of the bug, the most likely explanation
is that there is a problem in there.  I went through the
zonelist-walker changes but didn't spot anything. Could you try reverting
page-allocator-do-not-check-numa-node-id-when-the-caller-knows-the-node-is-valid
please? It has a few changes with repect to NUMA and ia-64 and the error
might be in there somewhere.

Is it only the interleave policy that is affected or are other NUMA
placement policies with node 4 causing trouble as well? If it's only
interleave, are you aware of any recent changes to the interleave policy
in -mm that might also explain this problem?

> I know we had to muck around quite a
> bit to get this all to work in the "memoryless nodes" and "two zonelist"
> patches a while back. 
> 
> I'll try to bisect to specific patch--probably tomorrow.
> 

Can you also try with this minimal debugging patch applied and the full
console log please? I'll keep thinking on it and hopefully I'll get inspired

diff --git a/mm/mm_init.c b/mm/mm_init.c
index 4e0e265..82e17bb 100644
--- a/mm/mm_init.c
+++ b/mm/mm_init.c
@@ -41,8 +41,6 @@ void mminit_verify_zonelist(void)
 			listid = i / MAX_NR_ZONES;
 			zonelist = &pgdat->node_zonelists[listid];
 			zone = &pgdat->node_zones[zoneid];
-			if (!populated_zone(zone))
-				continue;
 
 			/* Print information about the zonelist */
 			printk(KERN_DEBUG "mminit::zonelist %s %d:%s = ",
diff --git a/mm/mmzone.c b/mm/mmzone.c
index 16ce8b9..c8c54d1 100644
--- a/mm/mmzone.c
+++ b/mm/mmzone.c
@@ -57,6 +57,10 @@ struct zoneref *next_zones_zonelist(struct zoneref *z,
 					nodemask_t *nodes,
 					struct zone **zone)
 {
+	/* Should be impossible, check for NULL or near-NULL values for z */
+	BUG_ON(!z);
+	BUG_ON((unsigned long )z < PAGE_SIZE);
+
 	/*
 	 * Find the next suitable zone to use for the allocation.
 	 * Only filter based on nodemask if it's set

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
