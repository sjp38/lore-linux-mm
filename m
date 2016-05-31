Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0A4B36B0005
	for <linux-mm@kvack.org>; Mon, 30 May 2016 22:55:15 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id h5so20442389ioh.1
        for <linux-mm@kvack.org>; Mon, 30 May 2016 19:55:15 -0700 (PDT)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id 65si38509172ioi.158.2016.05.30.19.55.12
        for <linux-mm@kvack.org>;
        Mon, 30 May 2016 19:55:14 -0700 (PDT)
Date: Tue, 31 May 2016 12:55:09 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: shrink_active_list/try_to_release_page bug? (was Re: xfs trace
 in 4.4.2 / also in 4.3.3 WARNING fs/xfs/xfs_aops.c:1232 xfs_vm_releasepage)
Message-ID: <20160531025509.GA12670@dastard>
References: <20160511155951.GF42410@bfoster.bfoster>
 <5738576B.4010208@profihost.ag>
 <20160515115017.GA6433@laptop.bfoster>
 <57386E84.3090606@profihost.ag>
 <20160516010602.GA24980@bfoster.bfoster>
 <57420A47.2000700@profihost.ag>
 <20160522213850.GE26977@dastard>
 <574BEA84.3010206@profihost.ag>
 <20160530223657.GP26977@dastard>
 <20160531010724.GA9616@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160531010724.GA9616@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>, Brian Foster <bfoster@redhat.com>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, May 31, 2016 at 10:07:24AM +0900, Minchan Kim wrote:
> On Tue, May 31, 2016 at 08:36:57AM +1000, Dave Chinner wrote:
> > [adding lkml and linux-mm to the cc list]
> > 
> > On Mon, May 30, 2016 at 09:23:48AM +0200, Stefan Priebe - Profihost AG wrote:
> > > Hi Dave,
> > >   Hi Brian,
> > > 
> > > below are the results with a vanilla 4.4.11 kernel.
> > 
> > Thanks for persisting with the testing, Stefan.
> > 
> > ....
> > 
> > > i've now used a vanilla 4.4.11 Kernel and the issue remains. After a
> > > fresh reboot it has happened again on the root FS for a debian apt file:
> > > 
> > > XFS (md127p3): ino 0x41221d1 delalloc 1 unwritten 0 pgoff 0x0 size 0x12b990
> > > ------------[ cut here ]------------
> > > WARNING: CPU: 1 PID: 111 at fs/xfs/xfs_aops.c:1239
> > > xfs_vm_releasepage+0x10f/0x140()
> > > Modules linked in: netconsole ipt_REJECT nf_reject_ipv4 xt_multiport
> > > iptable_filter ip_tables x_tables bonding coretemp 8021q garp fuse
> > > sb_edac edac_core i2c_i801 i40e(O) xhci_pci xhci_hcd shpchp vxlan
> > > ip6_udp_tunnel udp_tunnel ipmi_si ipmi_msghandler button btrfs xor
> > > raid6_pq dm_mod raid1 md_mod usbhid usb_storage ohci_hcd sg sd_mod
> > > ehci_pci ehci_hcd usbcore usb_common igb ahci i2c_algo_bit libahci
> > > i2c_core mpt3sas ptp pps_core raid_class scsi_transport_sas
> > > CPU: 1 PID: 111 Comm: kswapd0 Tainted: G           O    4.4.11 #1
> > > Hardware name: Supermicro Super Server/X10SRH-CF, BIOS 1.0b 05/18/2015
> > >  0000000000000000 ffff880c4dacfa88 ffffffffa23c5b8f 0000000000000000
> > >  ffffffffa2a51ab4 ffff880c4dacfac8 ffffffffa20837a7 ffff880c4dacfae8
> > >  0000000000000001 ffffea00010c3640 ffff8802176b49d0 ffffea00010c3660
> > > Call Trace:
> > >  [<ffffffffa23c5b8f>] dump_stack+0x63/0x84
> > >  [<ffffffffa20837a7>] warn_slowpath_common+0x97/0xe0
> > >  [<ffffffffa208380a>] warn_slowpath_null+0x1a/0x20
> > >  [<ffffffffa2326caf>] xfs_vm_releasepage+0x10f/0x140
> > >  [<ffffffffa218c680>] ? page_mkclean_one+0xd0/0xd0
> > >  [<ffffffffa218d3a0>] ? anon_vma_prepare+0x150/0x150
> > >  [<ffffffffa21521c2>] try_to_release_page+0x32/0x50
> > >  [<ffffffffa2166b2e>] shrink_active_list+0x3ce/0x3e0
> > >  [<ffffffffa21671c7>] shrink_lruvec+0x687/0x7d0
> > >  [<ffffffffa21673ec>] shrink_zone+0xdc/0x2c0
> > >  [<ffffffffa2168539>] kswapd+0x4f9/0x970
> > >  [<ffffffffa2168040>] ? mem_cgroup_shrink_node_zone+0x1a0/0x1a0
> > >  [<ffffffffa20a0d99>] kthread+0xc9/0xe0
> > >  [<ffffffffa20a0cd0>] ? kthread_stop+0x100/0x100
> > >  [<ffffffffa26b404f>] ret_from_fork+0x3f/0x70
> > >  [<ffffffffa20a0cd0>] ? kthread_stop+0x100/0x100
> > > ---[ end trace c9d679f8ed4d7610 ]---
> > > XFS (md127p3): ino 0x41221d1 delalloc 1 unwritten 0 pgoff 0x1000 size
> > > 0x12b990
> > > XFS (md127p3): ino 0x41221d1 delalloc 1 unwritten 0 pgoff 0x2000 size
> > .....
> > 
> > Ok, I suspect this may be a VM bug. I've been looking at the 4.6
> > code (so please try to reproduce on that kernel!) but it looks to me
> > like the only way we can get from shrink_active_list() direct to
> > try_to_release_page() is if we are over the maximum bufferhead
> > threshold (i.e buffer_heads_over_limit = true) and we are trying to
> > reclaim pages direct from the active list.
> > 
> > Because we are called from kswapd()->balance_pgdat(), we have:
> > 
> >         struct scan_control sc = {
> >                 .gfp_mask = GFP_KERNEL,
> >                 .order = order,
> >                 .priority = DEF_PRIORITY,
> >                 .may_writepage = !laptop_mode,
> >                 .may_unmap = 1,
> >                 .may_swap = 1,
> >         };
> > 
> > The key point here is reclaim is being run with .may_writepage =
> > true for default configuration kernels. when we get to
> > shrink_active_list():
> > 
> > 	if (!sc->may_writepage)
> > 		isolate_mode |= ISOLATE_CLEAN;
> > 
> > But sc->may_writepage = true and this allows isolate_lru_pages() to
> > isolate dirty pages from the active list. Normally this isn't a
> > problem, because the isolated active list pages are rotated to the
> > inactive list, and nothing else happens to them. *Except when
> > buffer_heads_over_limit = true*. This special condition would
> > explain why I have never seen apt/dpkg cause this problem on any of
> > my (many) Debian systems that all use XFS....
> > 
> > In that case, shrink_active_list() runs:
> > 
> > 	if (unlikely(buffer_heads_over_limit)) {
> > 		if (page_has_private(page) && trylock_page(page)) {
> > 			if (page_has_private(page))
> > 				try_to_release_page(page, 0);
> > 			unlock_page(page);
> > 		}
> > 	}
> > 
> > i.e. it locks the page, and if it has buffer heads it trys to get
> > the bufferheads freed from the page.
> > 
> > But this is a dirty page, which means it may have delalloc or
> > unwritten state on it's buffers, both of which indicate that there
> > is dirty data in teh page that hasn't been written. XFS issues a
> > warning on this because neither shrink_active_list nor
> > try_to_release_page() check for whether the page is dirty or not.
> > 
> > Hence it seems to me that shrink_active_list() is calling
> > try_to_release_page() inappropriately, and XFS is just the
> > messenger. If you turn laptop mode on, it is likely the problem will
> > go away as kswapd will run with .may_writepage = false, but that
> > will also cause other behavioural changes relating to writeback and
> > memory reclaim. It might be worth trying as a workaround for now.
> > 
> > MM-folk - is this analysis correct? If so, why is
> > shrink_active_list() calling try_to_release_page() on dirty pages?
> > Is this just an oversight or is there some problem that this is
> > trying to work around? It seems trivial to fix to me (add a
> > !PageDirty check), but I don't know why the check is there in the
> > first place...
> 
> It seems to be latter.
> Below commit seems to be related.
> [ecdfc9787fe527, Resurrect 'try_to_free_buffers()' VM hackery.]

Okay, that's been there a long, long time (2007), and it covers a
case where the filesystem cleans pages without the VM knowing about
it (i.e. it marks bufferheads clean without clearing the PageDirty
state).

That does not explain the code in shrink_active_list().

> At that time, even shrink_page_list works like this.

The current code in shrink_page_list still works this way - the
PageDirty code will *jump over the PagePrivate case* if the page is
to remain dirty or pageout() fails to make it clean.  Hence it never
gets to try_to_release_page() on a dirty page.

Seems like this really needs a dirty check in shrink_active_list()
and to leave the stripping of bufferheads from dirty pages in the
ext3 corner case to shrink_inactive_list() once the dirty pages have
been rotated off the active list...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
