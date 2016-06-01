Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9925C6B0005
	for <linux-mm@kvack.org>; Tue, 31 May 2016 21:37:29 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id v125so15646985itc.0
        for <linux-mm@kvack.org>; Tue, 31 May 2016 18:37:29 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id w73si11535357iod.51.2016.05.31.18.37.27
        for <linux-mm@kvack.org>;
        Tue, 31 May 2016 18:37:28 -0700 (PDT)
Date: Wed, 1 Jun 2016 10:38:06 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: shrink_active_list/try_to_release_page bug? (was Re: xfs trace
 in 4.4.2 / also in 4.3.3 WARNING fs/xfs/xfs_aops.c:1232 xfs_vm_releasepage)
Message-ID: <20160601013806.GK19976@bbox>
References: <5738576B.4010208@profihost.ag>
 <20160515115017.GA6433@laptop.bfoster>
 <57386E84.3090606@profihost.ag>
 <20160516010602.GA24980@bfoster.bfoster>
 <57420A47.2000700@profihost.ag>
 <20160522213850.GE26977@dastard>
 <574BEA84.3010206@profihost.ag>
 <20160530223657.GP26977@dastard>
 <20160531010724.GA9616@bbox>
 <20160531095031.GA5912@quack2.suse.cz>
MIME-Version: 1.0
In-Reply-To: <20160531095031.GA5912@quack2.suse.cz>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, Brian Foster <bfoster@redhat.com>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, linux-kernel@vger.kernel.org, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>

On Tue, May 31, 2016 at 11:50:31AM +0200, Jan Kara wrote:
> On Tue 31-05-16 10:07:24, Minchan Kim wrote:
> > On Tue, May 31, 2016 at 08:36:57AM +1000, Dave Chinner wrote:
> > > [adding lkml and linux-mm to the cc list]
> > > 
> > > On Mon, May 30, 2016 at 09:23:48AM +0200, Stefan Priebe - Profihost AG wrote:
> > > > Hi Dave,
> > > >   Hi Brian,
> > > > 
> > > > below are the results with a vanilla 4.4.11 kernel.
> > > 
> > > Thanks for persisting with the testing, Stefan.
> > > 
> > > ....
> > > 
> > > > i've now used a vanilla 4.4.11 Kernel and the issue remains. After a
> > > > fresh reboot it has happened again on the root FS for a debian apt file:
> > > > 
> > > > XFS (md127p3): ino 0x41221d1 delalloc 1 unwritten 0 pgoff 0x0 size 0x12b990
> > > > ------------[ cut here ]------------
> > > > WARNING: CPU: 1 PID: 111 at fs/xfs/xfs_aops.c:1239
> > > > xfs_vm_releasepage+0x10f/0x140()
> > > > Modules linked in: netconsole ipt_REJECT nf_reject_ipv4 xt_multiport
> > > > iptable_filter ip_tables x_tables bonding coretemp 8021q garp fuse
> > > > sb_edac edac_core i2c_i801 i40e(O) xhci_pci xhci_hcd shpchp vxlan
> > > > ip6_udp_tunnel udp_tunnel ipmi_si ipmi_msghandler button btrfs xor
> > > > raid6_pq dm_mod raid1 md_mod usbhid usb_storage ohci_hcd sg sd_mod
> > > > ehci_pci ehci_hcd usbcore usb_common igb ahci i2c_algo_bit libahci
> > > > i2c_core mpt3sas ptp pps_core raid_class scsi_transport_sas
> > > > CPU: 1 PID: 111 Comm: kswapd0 Tainted: G           O    4.4.11 #1
> > > > Hardware name: Supermicro Super Server/X10SRH-CF, BIOS 1.0b 05/18/2015
> > > >  0000000000000000 ffff880c4dacfa88 ffffffffa23c5b8f 0000000000000000
> > > >  ffffffffa2a51ab4 ffff880c4dacfac8 ffffffffa20837a7 ffff880c4dacfae8
> > > >  0000000000000001 ffffea00010c3640 ffff8802176b49d0 ffffea00010c3660
> > > > Call Trace:
> > > >  [<ffffffffa23c5b8f>] dump_stack+0x63/0x84
> > > >  [<ffffffffa20837a7>] warn_slowpath_common+0x97/0xe0
> > > >  [<ffffffffa208380a>] warn_slowpath_null+0x1a/0x20
> > > >  [<ffffffffa2326caf>] xfs_vm_releasepage+0x10f/0x140
> > > >  [<ffffffffa218c680>] ? page_mkclean_one+0xd0/0xd0
> > > >  [<ffffffffa218d3a0>] ? anon_vma_prepare+0x150/0x150
> > > >  [<ffffffffa21521c2>] try_to_release_page+0x32/0x50
> > > >  [<ffffffffa2166b2e>] shrink_active_list+0x3ce/0x3e0
> > > >  [<ffffffffa21671c7>] shrink_lruvec+0x687/0x7d0
> > > >  [<ffffffffa21673ec>] shrink_zone+0xdc/0x2c0
> > > >  [<ffffffffa2168539>] kswapd+0x4f9/0x970
> > > >  [<ffffffffa2168040>] ? mem_cgroup_shrink_node_zone+0x1a0/0x1a0
> > > >  [<ffffffffa20a0d99>] kthread+0xc9/0xe0
> > > >  [<ffffffffa20a0cd0>] ? kthread_stop+0x100/0x100
> > > >  [<ffffffffa26b404f>] ret_from_fork+0x3f/0x70
> > > >  [<ffffffffa20a0cd0>] ? kthread_stop+0x100/0x100
> > > > ---[ end trace c9d679f8ed4d7610 ]---
> > > > XFS (md127p3): ino 0x41221d1 delalloc 1 unwritten 0 pgoff 0x1000 size
> > > > 0x12b990
> > > > XFS (md127p3): ino 0x41221d1 delalloc 1 unwritten 0 pgoff 0x2000 size
> > > .....
> > > 
> > > Ok, I suspect this may be a VM bug. I've been looking at the 4.6
> > > code (so please try to reproduce on that kernel!) but it looks to me
> > > like the only way we can get from shrink_active_list() direct to
> > > try_to_release_page() is if we are over the maximum bufferhead
> > > threshold (i.e buffer_heads_over_limit = true) and we are trying to
> > > reclaim pages direct from the active list.
> > > 
> > > Because we are called from kswapd()->balance_pgdat(), we have:
> > > 
> > >         struct scan_control sc = {
> > >                 .gfp_mask = GFP_KERNEL,
> > >                 .order = order,
> > >                 .priority = DEF_PRIORITY,
> > >                 .may_writepage = !laptop_mode,
> > >                 .may_unmap = 1,
> > >                 .may_swap = 1,
> > >         };
> > > 
> > > The key point here is reclaim is being run with .may_writepage =
> > > true for default configuration kernels. when we get to
> > > shrink_active_list():
> > > 
> > > 	if (!sc->may_writepage)
> > > 		isolate_mode |= ISOLATE_CLEAN;
> > > 
> > > But sc->may_writepage = true and this allows isolate_lru_pages() to
> > > isolate dirty pages from the active list. Normally this isn't a
> > > problem, because the isolated active list pages are rotated to the
> > > inactive list, and nothing else happens to them. *Except when
> > > buffer_heads_over_limit = true*. This special condition would
> > > explain why I have never seen apt/dpkg cause this problem on any of
> > > my (many) Debian systems that all use XFS....
> > > 
> > > In that case, shrink_active_list() runs:
> > > 
> > > 	if (unlikely(buffer_heads_over_limit)) {
> > > 		if (page_has_private(page) && trylock_page(page)) {
> > > 			if (page_has_private(page))
> > > 				try_to_release_page(page, 0);
> > > 			unlock_page(page);
> > > 		}
> > > 	}
> > > 
> > > i.e. it locks the page, and if it has buffer heads it trys to get
> > > the bufferheads freed from the page.
> > > 
> > > But this is a dirty page, which means it may have delalloc or
> > > unwritten state on it's buffers, both of which indicate that there
> > > is dirty data in teh page that hasn't been written. XFS issues a
> > > warning on this because neither shrink_active_list nor
> > > try_to_release_page() check for whether the page is dirty or not.
> > > 
> > > Hence it seems to me that shrink_active_list() is calling
> > > try_to_release_page() inappropriately, and XFS is just the
> > > messenger. If you turn laptop mode on, it is likely the problem will
> > > go away as kswapd will run with .may_writepage = false, but that
> > > will also cause other behavioural changes relating to writeback and
> > > memory reclaim. It might be worth trying as a workaround for now.
> > > 
> > > MM-folk - is this analysis correct? If so, why is
> > > shrink_active_list() calling try_to_release_page() on dirty pages?
> > > Is this just an oversight or is there some problem that this is
> > > trying to work around? It seems trivial to fix to me (add a
> > > !PageDirty check), but I don't know why the check is there in the
> > > first place...
> > 
> > It seems to be latter.
> > Below commit seems to be related.
> > [ecdfc9787fe527, Resurrect 'try_to_free_buffers()' VM hackery.]
> > 
> > At that time, even shrink_page_list works like this.
> > 
> > shrink_page_list
> >         while (!list_empty(page_list)) {
> >                 ..
> >                 ..
> >                 if (PageDirty(page)) {
> >                         ..
> >                 }
> > 
> >                 /*
> >                  * If the page has buffers, try to free the buffer mappings
> >                  * associated with this page. If we succeed we try to free
> >                  * the page as well.
> >                  *
> >                  * We do this even if the page is PageDirty().
> >                  * try_to_release_page() does not perform I/O, but it is
> >                  * possible for a page to have PageDirty set, but it is actually
> >                  * clean (all its buffers are clean).  This happens if the
> >                  * buffers were written out directly, with submit_bh(). ext3
> >                  * will do this, as well as the blockdev mapping. 
> >                  * try_to_release_page() will discover that cleanness and will
> >                  * drop the buffers and mark the page clean - it can be freed.
> >                  * ..
> >                  */
> >                 if (PagePrivate(page)) {
> >                         if (!try_to_release_page(page, sc->gfp_mask))
> >                                 goto activate_locked;
> >                         if (!mapping && page_count(page) == 1)
> >                                 goto free_it;
> >                 }
> >                 ..
> >         }
> > 
> > I wonder whether it's valid or not with on ext4.
> 
> Actually, we've already discussed this about an year ago:
> http://oss.sgi.com/archives/xfs/2015-06/msg00119.html
> 
> And it was the last drop that made me remove ext3 from the tree. ext4 can
> also clean dirty buffers while keeping pages dirty but it is limited only
> to metadata (and data in data=journal mode) so the scope of the problem is
> much smaller. So just avoiding calling ->releasepage for dirty pages may
> work fine these days.
> 
> Also it is possible to change ext4 checkpointing code to completely avoid
> doing this but I never got to rewriting that code. Probably I should give
> it higher priority on my todo list...

Hah, you already noticed. Thanks for the information.

At a first glance, it seems to fix it in /mm with checking PageDirty but
it might be risky for other out-of-tree FSes without full understanding
of internal and block_invalidatepage users can make such clean buffers
but dirty page although there is no one in mainline now so I will leave
the fix to FS guys.

Thanks.

> 
> 								Honza
> -- 
> Jan Kara <jack@suse.com>
> SUSE Labs, CR
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
