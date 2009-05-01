Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 3D4696B003D
	for <linux-mm@kvack.org>; Fri,  1 May 2009 12:21:49 -0400 (EDT)
Subject: Re: [BUG] 2.6.30-rc3-mmotm-090428-1814 -- bogus pointer deref
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Reply-To: lts@ldl.fc.hp.com
In-Reply-To: <20090501094910.GA22785@csn.ul.ie>
References: <1241037299.6693.97.camel@lts-notebook>
	 <20090430113146.GA21997@csn.ul.ie> <1241140489.6656.14.camel@lts-notebook>
	 <20090501094910.GA22785@csn.ul.ie>
Content-Type: text/plain
Date: Fri, 01 May 2009 12:22:02 -0400
Message-Id: <1241194922.13666.199.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, linux-numa <linux-numa@vger.kernel.org>, Doug Chapman <doug.chapman@hp.com>, Eric Whitney <eric.whitney@hp.com>, Bjorn Helgaas <bjorn.helgaas@hp.com>, Miao Xie <miaox@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

[Note:  we're experiencing some e-mail problems at HP today.  I've added
a Reply-to: that should work, but my normal hp address will probably
bounce until this gets resolved.]

On Fri, 2009-05-01 at 10:49 +0100, Mel Gorman wrote:
> On Thu, Apr 30, 2009 at 09:14:49PM -0400, Lee Schermerhorn wrote:
> > On Thu, 2009-04-30 at 12:31 +0100, Mel Gorman wrote:
> > > On Wed, Apr 29, 2009 at 04:34:59PM -0400, Lee Schermerhorn wrote:
> > > > I'm seeing this on an ia64 platform--HP rx8640--running the numactl
> > > > package regression test.  On ia64 a "NaT Consumption" [NaT = "not a
> > > > thing"] usually means a bogus pointer.  I verified that it also occurs
> > > > on 2.6.30-rc3-mmotm-090424-1814.  The regression test runs to completion
> > > > on a 4-node x86_64 platform for both the 04/27 and 04/28 mmotm kernels.
> > > > 
> > > > The bug occurs right after the test suite issues the message:
> > > > 
> > > > "testing numactl --interleave=all memhog 15728640"
> > > > 
> > > > -------------------------------
> > > > Console log:
> > > > 
> > > > numactl[7821]: NaT consumption 2216203124768 [2]
> > > > Modules linked in: ipv6 nfs lockd fscache nfs_acl auth_rpcgss sunrpc vfat fat dm_mirror dm_multipath scsi_dh pci_slot parport_pc lp parport sg sr_mod cdrom button e1000 tg3 libphy dm_region_hash dm_log dm_mod sym53c8xx mptspi mptscsih mptbase scsi_transport_spi sd_mod scsi_mod ext3 jbd uhci_hcd ohci_hcd ehci_hcd [last unloaded: freq_table]
> > > > 
> > > > Pid: 7821, CPU 25, comm:              numactl
> > > > psr : 0000121008022038 ifs : 8000000000000004 ip  : [<a00000010014ec91>]    Not tainted (2.6.30-rc3-mmotm-090428-1631)
> > > > ip is at next_zones_zonelist+0x31/0x120
> > <snip>
> > > > 
> > > > I'll try to bisect to specific patch--probably tomorrow.
> > 
> > Mel:  I think you can rest easy.  I've duplicated the problem with a
> > kernel that truncates the mmotm 04/28 series just before your patches.
> 
> Ok, I can rest a little easier but I won't that much. I've mucked around
> enough in there over the last while that it might still be something I
> did.
> 
> > Hope it's not my cpuset-mm fix that occurs just before that!  I'll let
> > you know.
> > 
> 
> I don't think so because it was in mmotm before my patchset was and you
> didn't spot any problems.
> 
> > Did hit one or your BUG_ON's, tho'.  See below.
> > 
> > > > 
> > > 
> > > Can you also try with this minimal debugging patch applied and the full
> > > console log please? I'll keep thinking on it and hopefully I'll get inspired
> > > 
> > > diff --git a/mm/mm_init.c b/mm/mm_init.c
> > > index 4e0e265..82e17bb 100644
> > > --- a/mm/mm_init.c
> > > +++ b/mm/mm_init.c
> > > @@ -41,8 +41,6 @@ void mminit_verify_zonelist(void)
> > >  			listid = i / MAX_NR_ZONES;
> > >  			zonelist = &pgdat->node_zonelists[listid];
> > >  			zone = &pgdat->node_zones[zoneid];
> > > -			if (!populated_zone(zone))
> > > -				continue;
> > >  
> > >  			/* Print information about the zonelist */
> > >  			printk(KERN_DEBUG "mminit::zonelist %s %d:%s = ",
> > > diff --git a/mm/mmzone.c b/mm/mmzone.c
> > > index 16ce8b9..c8c54d1 100644
> > > --- a/mm/mmzone.c
> > > +++ b/mm/mmzone.c
> > > @@ -57,6 +57,10 @@ struct zoneref *next_zones_zonelist(struct zoneref *z,
> > >  					nodemask_t *nodes,
> > >  					struct zone **zone)
> > >  {
> > > +	/* Should be impossible, check for NULL or near-NULL values for z */
> > > +	BUG_ON(!z);
> > > +	BUG_ON((unsigned long )z < PAGE_SIZE);
> > 
> > The test w/o your patches hit the second BUG_ON().
> > 
> 
> This implies that z was NULL when it was passed to the iterator
> 
> #define for_each_zone_zonelist_nodemask(zone, z, zlist, highidx, nodemask) \
>         for (z = first_zones_zonelist(zlist, highidx, nodemask, &zone); \
>                 zone; \
>                 z = next_zones_zonelist(++z, highidx, nodemask, &zone)) \
> 
> and we ended up with z == ++NULL;
> 
> Can you send the full dmesg and what your bisection point was? Maybe I
> can spot something. The implication is that a corrupt or badly constructed
> zonelist is being passed into the page allocator so I'd like to see where
> it is coming from.

Mel:

I've tracked it down to this patch:

	cpusetmm-update-tasks-mems_allowed-in-time.patch

Without that patch, the numademo command:

	numactl --interleave=all ./memhog $(scale 16G)
	
runs to completion w/o error.  With this patch pushed, I capture this
trace today:

numactl[7408]: NaT consumption 17179869216 [1]
Modules linked in: ipv6 nfs lockd fscache nfs_acl auth_rpcgss sunrpc vfat fat dm_mirror dm_multipath scsi_dh pci_slot parport_pc lp parport sg sr_mod cdrom button tg3 e1000 libphy dm_region_hash dm_log dm_mod sym53c8xx mptspi mptscsih mptbase scsi_transport_spi sd_mod scsi_mod ext3 jbd uhci_hcd ohci_hcd ehci_hcd [last unloaded: freq_table]

Pid: 7408, CPU 2, comm:              numactl
psr : 0000101008526030 ifs : 8000000000000897 ip  : [<a0000001001335f0>]    Not tainted (2.6.30-rc3-mmotm-090428-1631+zonelist-debug-7)
ip is at __alloc_pages_internal+0x110/0x720
unat: 0000000000000000 pfs : 0000000000000897 rsc : 0000000000000003
rnat: 0000000000000000 bsps: 00000000001cca31 pr  : 0000000500555a69
ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c8a70433f
csd : 0000000000000000 ssd : 0000000000000000
b0  : a0000001001335d0 b6  : a000000100038fa0 b7  : a00000010000bbc0
f6  : 1003e000000000000003e f7  : 1003e000000003ffffffe
f8  : 100178208141befbf5f00 f9  : 1003effffffffffffffc1
f10 : 1003e00000000001dbeff f11 : 1003e0044b82fa09b5a53
r1  : a000000100c844c0 r2  : e00007038a7a0ce0 r3  : e00007038a7a0cd0
r8  : 0000000000000000 r9  : 0000000000020000 r10 : 0000000000000000
r11 : 0000000000000000 r12 : e00007038a7a7de0 r13 : e00007038a7a0000
r14 : 0000000000000000 r15 : e00007038a7a0cf8 r16 : e000070020103b88
r17 : 0000000000000000 r18 : e000070020103b80 r19 : 0000000000000000
r20 : 0000000000000018 r21 : a000000100a22ec8 r22 : a000000100a22ec0
r23 : a000000100a852f0 r24 : e000070380031808 r25 : e00007038003180c
r26 : 0000000000000000 r27 : 0000000000000000 r28 : 0000000000004000
r29 : 0000000000004000 r30 : 0000000000000000 r31 : e0000783821c9900

Call Trace:
 [<a000000100015720>] show_stack+0x40/0xa0
                                sp=e00007038a7a7830 bsp=e00007038a7a13d0
 [<a000000100016050>] show_regs+0x870/0x8c0
                                sp=e00007038a7a7a00 bsp=e00007038a7a1378
 [<a0000001000399d0>] die+0x1b0/0x2c0
                                sp=e00007038a7a7a00 bsp=e00007038a7a1330
 [<a000000100039b30>] die_if_kernel+0x50/0x80
                                sp=e00007038a7a7a00 bsp=e00007038a7a1300
 [<a000000100733980>] ia64_fault+0x1140/0x1260
                                sp=e00007038a7a7a00 bsp=e00007038a7a12a8
 [<a00000010000c3c0>] ia64_native_leave_kernel+0x0/0x270
                                sp=e00007038a7a7c10 bsp=e00007038a7a12a8
 [<a0000001001335f0>] __alloc_pages_internal+0x110/0x720
                                sp=e00007038a7a7de0 bsp=e00007038a7a11e8
 [<a000000100181b60>] alloc_page_interleave+0xa0/0x160
                                sp=e00007038a7a7df0 bsp=e00007038a7a11a8
 [<a000000100182060>] alloc_page_vma+0x120/0x220
                                sp=e00007038a7a7df0 bsp=e00007038a7a1170
 [<a000000100156a50>] handle_mm_fault+0x330/0xf60
                                sp=e00007038a7a7df0 bsp=e00007038a7a1100
 [<a000000100157b80>] __get_user_pages+0x500/0x820
                                sp=e00007038a7a7e00 bsp=e00007038a7a1090
 [<a000000100157f00>] get_user_pages+0x60/0x80
                                sp=e00007038a7a7e10 bsp=e00007038a7a1038
 [<a0000001001ad3d0>] get_arg_page+0x50/0x160
                                sp=e00007038a7a7e10 bsp=e00007038a7a1008
 [<a0000001001ad940>] copy_strings+0x200/0x3a0
                                sp=e00007038a7a7e20 bsp=e00007038a7a0f78
 [<a0000001001adb20>] copy_strings_kernel+0x40/0x60
                                sp=e00007038a7a7e20 bsp=e00007038a7a0f40
 [<a0000001001b0b80>] do_execve+0x320/0x5e0
                                sp=e00007038a7a7e20 bsp=e00007038a7a0ee0
 [<a000000100014780>] sys_execve+0x60/0xa0
                                sp=e00007038a7a7e30 bsp=e00007038a7a0ea8
 [<a00000010000b910>] ia64_execve+0x30/0x140
                                sp=e00007038a7a7e30 bsp=e00007038a7a0e58
 [<a00000010000c240>] ia64_ret_from_syscall+0x0/0x20
                                sp=e00007038a7a7e30 bsp=e00007038a7a0e58
 [<a000000000010720>] _stext+0xffffffff00010720/0x400
                                sp=e00007038a7a8000 bsp=e00007038a7a0e58
---------------------------------------------------------

So, I'm off trying to figure what's happening with interleaved
allocations with this patch.

Later,
Lee




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
