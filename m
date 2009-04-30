Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 48E206B003D
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 14:59:01 -0400 (EDT)
Subject: Re: [BUG] 2.6.30-rc3-mmotm-090428-1814 -- bogus pointer deref
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20090430113146.GA21997@csn.ul.ie>
References: <1241037299.6693.97.camel@lts-notebook>
	 <20090430113146.GA21997@csn.ul.ie>
Content-Type: text/plain
Date: Thu, 30 Apr 2009 14:59:53 -0400
Message-Id: <1241117993.6248.78.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, linux-numa <linux-numa@vger.kernel.org>, Doug Chapman <doug.chapman@hp.com>, Eric Whitney <eric.whitney@hp.com>, Bjorn Helgaas <bjorn.helgaas@hp.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2009-04-30 at 12:31 +0100, Mel Gorman wrote: 
> On Wed, Apr 29, 2009 at 04:34:59PM -0400, Lee Schermerhorn wrote:
> > I'm seeing this on an ia64 platform--HP rx8640--running the numactl
> > package regression test.  On ia64 a "NaT Consumption" [NaT = "not a
> > thing"] usually means a bogus pointer.  I verified that it also occurs
> > on 2.6.30-rc3-mmotm-090424-1814.  The regression test runs to completion
> > on a 4-node x86_64 platform for both the 04/27 and 04/28 mmotm kernels.
> > 
> > The bug occurs right after the test suite issues the message:
> > 
> > "testing numactl --interleave=all memhog 15728640"
> > 
> > -------------------------------
> > Console log:
> > 
> > numactl[7821]: NaT consumption 2216203124768 [2]
> > Modules linked in: ipv6 nfs lockd fscache nfs_acl auth_rpcgss sunrpc vfat fat dm_mirror dm_multipath scsi_dh pci_slot parport_pc lp parport sg sr_mod cdrom button e1000 tg3 libphy dm_region_hash dm_log dm_mod sym53c8xx mptspi mptscsih mptbase scsi_transport_spi sd_mod scsi_mod ext3 jbd uhci_hcd ohci_hcd ehci_hcd [last unloaded: freq_table]
> > 
> > Pid: 7821, CPU 25, comm:              numactl
> > psr : 0000121008022038 ifs : 8000000000000004 ip  : [<a00000010014ec91>]    Not tainted (2.6.30-rc3-mmotm-090428-1631)
> > ip is at next_zones_zonelist+0x31/0x120
> 
> What line is this?

Hi, Mel:

Sorry for the delay.  Swamped.  Was building incrementally patched
kernels and took a while to get back to where I could [sort of] answer
this.  Below I've included part of the disassembly of the mmzone.o for
this kernel.


<snip> 
> > mminit::zonelist general 4:DMA = 4:DMA
> > mminit::zonelist thisnode 4:DMA = 4:DMA
> > Built 5 zonelists in Zone order, mobility grouping on.  Total pages: 4160506
> > 
> > Note that this platform has a small [~512MB] pseudo-node #4 that
> > contains DMA only.  Here's the 'numactl --hardware' output:
> > 
> 
> What is a pseudo-node?

It's an artifact of the firmware and platform architecture.  It's a
memory-only node at physical address zero that contains memory that is
hardware-interleaved across a small slice of the real, physical nodes'
memory.  It shows up in the ACPI SRAT/SLIT tables as a separate
'PXM' [proximity domain] that Linux treats as a "node".  Because it's
<4G [on my test platform], it's all ia64 dma zone.

> 
> > available: 5 nodes (0-4)
> > node 0 size: 15792 MB
> > node 0 free: 14908 MB
> > node 1 size: 16320 MB
> > node 1 free: 15985 MB
> > node 2 size: 16320 MB
> > node 2 free: 16106 MB
> > node 3 size: 16318 MB
> > node 3 free: 16146 MB
> > node 4 size: 511 MB
> > node 4 free: 495 MB
> > node distances:
> > node   0   1   2   3   4 
> >   0:  10  17  17  17  14 
> >   1:  17  10  17  17  14 
> >   2:  17  17  10  17  14 
> >   3:  17  17  17  10  14 
> >   4:  14  14  14  14  10 
> > 
> > If I create a cpuset with "mems" 0-3 -- i.e., eliminate the dma-only
> > node 4 -- I do not hit the this "Nat Consumption" bug.  The x86_64 test
> > platform doesn't have this "feature".
> > 
> > I suspect that the page alloc optimizations are making assumptions that
> > aren't true for this platform. 
> 
> Based on the timing of the bug, the most likely explanation
> is that there is a problem in there.  I went through the
> zonelist-walker changes but didn't spot anything. Could you try reverting
> page-allocator-do-not-check-numa-node-id-when-the-caller-knows-the-node-is-valid
> please? It has a few changes with repect to NUMA and ia-64 and the error
> might be in there somewhere.

Yeah, I've built some kernels to test.  Best to build them all at once,
since it takes a while to reboot this beast.  I'll let you know.

> 
> Is it only the interleave policy that is affected or are other NUMA
> placement policies with node 4 causing trouble as well? If it's only
> interleave, are you aware of any recent changes to the interleave policy
> in -mm that might also explain this problem?

I've tried to find a simple reproducer using memtoy, but haven't found
one yet.  The numactl package regression test hit is every time.  I
tried running a 'membind' test, and it doesn't seem to occur, altho I do
hit oom:

numactl --membind=4 ./memhog $(scale 16G)

But, when I try interleave, it hits the bug:

numactl --interleave=all ./memhog $(scale 16G)

That hits the bug.


> 
> > I know we had to muck around quite a
> > bit to get this all to work in the "memoryless nodes" and "two zonelist"
> > patches a while back. 
> > 
> > I'll try to bisect to specific patch--probably tomorrow.
> > 
> 
> Can you also try with this minimal debugging patch applied and the full
> console log please? I'll keep thinking on it and hopefully I'll get inspired

Will do.  I'll send the results.

Here's a section of the disassembly of mmzone.o.  Looks like the fault
is in the inlined zonelist_zone_idx() -- 0x1a0 + 0x31 ~= 0x1d0/1d6.
Dereferencing the zoneref pointer.


mm/mmzone.o:     file format elf64-ia64-little

Disassembly of section .text:

0000000000000000 <next_online_pgdat>:
	return NODE_DATA(first_online_node);
}

<snip>


00000000000001a0 <next_zones_zonelist>:

static inline int zref_in_nodemask(struct zoneref *zref, nodemask_t *nodes)
{
#ifdef CONFIG_NUMA
	return node_isset(zonelist_node_idx(zref), *nodes);
#else
	return 1;
#endif /* CONFIG_NUMA */
}

/* Returns the next zone at or below highest_zoneidx in a zonelist */
struct zoneref *next_zones_zonelist(struct zoneref *z,
					enum zone_type highest_zoneidx,
					nodemask_t *nodes,
					struct zone **zone)
{
 1a0:	10 40 00 40 00 21 	[MIB]       mov r8=r32
	/*
	 * Find the next suitable zone to use for the allocation.
	 * Only filter based on nodemask if it's set
	 */
	if (likely(nodes == NULL))
 1a6:	60 00 88 0e 72 03 	            cmp.eq p6,p7=0,r34
 1ac:	30 00 00 40       	      (p06) br.cond.sptk.few 1d0 <next_zones_zonelist+0x30>
 1b0:	11 00 00 00 01 00 	[MIB]       nop.m 0x0
 1b6:	00 00 00 02 00 00 	            nop.i 0x0
 1bc:	60 00 00 40       	            br.few 210 <next_zones_zonelist+0x70>;;
		while (zonelist_zone_idx(z) > highest_zoneidx)
			z++;
 1c0:	09 40 40 10 00 21 	[MMI]       adds r8=16,r8
 1c6:	00 00 00 02 00 00 	            nop.m 0x0
 1cc:	00 00 04 00       	            nop.i 0x0;;
}

static inline int zonelist_zone_idx(struct zoneref *zoneref)
{
	return zoneref->zone_idx;
 1d0:	0b 10 20 10 00 21 	[MMI]       adds r2=8,r8;;
 1d6:	e0 00 08 20 20 00 	            ld4 r14=[r2]	<<<< ???
 1dc:	00 00 04 00       	            nop.i 0x0;;
 1e0:	10 00 00 00 01 00 	[MIB]       nop.m 0x0
 1e6:	80 08 39 12 69 04 	            cmp4.ltu p8,p9=r33,r14
 1ec:	e0 ff ff 4a       	      (p08) br.cond.dptk.few 1c0 <next_zones_zonelist+0x20>
 1f0:	10 00 00 00 01 00 	[MIB]       nop.m 0x0
 1f6:	00 00 00 02 00 00 	            nop.i 0x0
 1fc:	b0 00 00 40       	            br.few 2a0 <next_zones_zonelist+0x100>
	else
		while (zonelist_zone_idx(z) > highest_zoneidx ||
				(z->zone && !zref_in_nodemask(z, nodes)))
			z++;
 200:	09 40 40 10 00 21 	[MMI]       adds r8=16,r8
 206:	00 00 00 02 00 00 	            nop.m 0x0
 20c:	00 00 04 00       	            nop.i 0x0;;
}

static inline int zonelist_zone_idx(struct zoneref *zoneref)
{
	return zoneref->zone_idx;
 210:	0b 48 20 10 00 21 	[MMI]       adds r9=8,r8;;
 216:	30 00 24 20 20 00 	            ld4 r3=[r9]
 21c:	00 00 04 00       	            nop.i 0x0;;
 220:	10 00 00 00 01 00 	[MIB]       nop.m 0x0
 226:	a0 08 0d 16 69 05 	            cmp4.ltu p10,p11=r33,r3
 22c:	e0 ff ff 4a       	      (p10) br.cond.dptk.few 200 <next_zones_zonelist+0x60>
 230:	09 00 00 00 01 00 	[MMI]       nop.m 0x0
static inline int zonelist_node_idx(struct zoneref *zoneref)
{
#ifdef CONFIG_NUMA
	/* zone_to_nid not available in this context */
	return zoneref->zone->node;
 236:	a0 00 20 30 20 00 	            ld8 r10=[r8]
 23c:	00 00 04 00       	            nop.i 0x0;;
 240:	11 78 c0 14 00 21 	[MIB]       adds r15=48,r10
 246:	c0 00 28 1a 72 06 	            cmp.eq p12,p13=0,r10
 24c:	60 00 00 43       	      (p12) br.cond.dpnt.few 2a0 <next_zones_zonelist+0x100>;;
static inline int zonelist_node_idx(struct zoneref *zoneref)
{
#ifdef CONFIG_NUMA
	/* zone_to_nid not available in this context */
	return zoneref->zone->node;
 250:	02 a0 00 1e 10 10 	[MII]       ld4 r20=[r15]

static __inline__ int
test_bit (int nr, const volatile void *addr)
{
	return 1 & (((const volatile __u32 *) addr)[nr >> 5] >> (nr & 31));
 256:	00 00 00 02 00 60 	            nop.i 0x0;;
 25c:	b2 a0 68 52       	            extr r19=r20,5,27
 260:	02 00 00 00 01 00 	[MII]       nop.m 0x0

static __inline__ int
test_bit (int nr, const volatile void *addr)
{
	return 1 & (((const volatile __u32 *) addr)[nr >> 5] >> (nr & 31));
 266:	f0 f8 50 58 40 00 	            and r15=31,r20;;
 26c:	00 00 04 00       	            nop.i 0x0
 270:	0b 90 4c 44 11 20 	[MMI]       shladd r18=r19,2,r34;;
 276:	10 01 48 60 21 00 	            ld4.acq r17=[r18]
 27c:	00 00 04 00       	            nop.i 0x0;;
 280:	03 00 00 00 01 00 	[MII]       nop.m 0x0
 286:	00 89 00 10 40 60 	            addp4 r16=r17,r0;;
 28c:	f1 80 00 79       	            shr.u r11=r16,r15;;
 290:	10 00 00 00 01 00 	[MIB]       nop.m 0x0
 296:	e0 00 2c 1e 28 07 	            tbit.z p14,p15=r11,0
 29c:	70 ff ff 4a       	      (p14) br.cond.dptk.few 200 <next_zones_zonelist+0x60>
		else

static inline struct zone *zonelist_zone(struct zoneref *zoneref)
{
	return zoneref->zone;
 2a0:	09 00 00 00 01 00 	[MMI]       nop.m 0x0

	*zone = zonelist_zone(z);
 2a6:	50 01 20 30 20 00 	            ld8 r21=[r8]
 2ac:	00 00 04 00       	            nop.i 0x0;;
 2b0:	11 00 54 46 98 11 	[MIB]       st8 [r35]=r21
	return z;
}
 2b6:	00 00 00 02 00 80 	            nop.i 0x0
 2bc:	08 00 84 00       	            br.ret.sptk.many b0;;




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
