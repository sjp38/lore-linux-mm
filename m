Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 580268D003B
	for <linux-mm@kvack.org>; Sun, 27 Mar 2011 19:54:31 -0400 (EDT)
Date: Mon, 28 Mar 2011 10:54:20 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] xfs: flush vmap aliases when mapping fails
Message-ID: <20110327235420.GV26611@dastard>
References: <1299713876-7747-1-git-send-email-david@fromorbit.com>
 <20110310073751.GB25374@infradead.org>
 <20110310224945.GA15097@dastard>
 <20110321122526.GX2140@cmpxchg.org>
 <20110322125736.GZ2140@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110322125736.GZ2140@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Christoph Hellwig <hch@infradead.org>, Nick Piggin <npiggin@kernel.dk>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, xfs@oss.sgi.com, linux-mm@kvack.org

On Tue, Mar 22, 2011 at 01:57:36PM +0100, Johannes Weiner wrote:
> On Mon, Mar 21, 2011 at 01:25:26PM +0100, Johannes Weiner wrote:
> > On Fri, Mar 11, 2011 at 09:49:45AM +1100, Dave Chinner wrote:
> > > FWIW, while the VM folk might be paying attention about vmap realted
> > > stuff, this vmap BUG() also needs triage:
> > > 
> > > https://bugzilla.kernel.org/show_bug.cgi?id=27002
> > 
> > I stared at this bug and the XFS code for a while over the weekend.
> > What you are doing in there is really scary!
> > 
> > So xfs_buf_free() does vm_unmap_ram if the buffer has the XBF_MAPPED
> > flag set and spans multiple pages (b_page_count > 1).
> > 
> > In xlog_sync() you have that split case where you do XFS_BUF_SET_PTR
> > on that in-core log's l_xbuf which changes that buffer to, as far as I
> > could understand, linear kernel memory.  Later in xlog_dealloc_log you
> > call xfs_buf_free() on that buffer.
> > 
> > I was unable to determine if this can ever be more than one page in
> > the buffer for the split case.  But if this is the case, you end up
> > invoking vm_unmap_ram() on something you never vm_map_ram'd, which
> > could explain why this triggers the BUG_ON() for the dirty area map.
> 
> Blech, that's bogus, please pardon my rashness.
> 
> I looked over the vmalloc side several times but could not spot
> anything that would explain this crash.
> 
> However, when you switched from vunmap to vm_unmap_ram you had to add
> the area size parameter.
> 
> I am guessing that the base address was always correct, vunmap would
> have caught an error with it.  But the new size argument could be too
> large and crash the kernel when it would reach into the next area that
> had already been freed (and marked in the dirty bitmap).
> 
> I have given up on verifying that what xlog_sync() does to l_xbuf is
> okay.  It would be good if you could confirm that it leaves the buffer
> in a state so that its b_addr - b_offset, b_page_count are correctly
> describing the exact vmap area.

Thanks for looking at this, Hannes. A fresh set of eyes always
helps. However, I don't think that l_xbuf is the only source of
potential problems w.r.t. the mapped region size when the buffer is
freed.  This was reported on #xfs overnight:

(http://pastebin.com/raw.php?i=P99pjDTn)

[  248.794327] XFS mounting filesystem md0
[  248.970190] Starting XFS recovery on filesystem: md0 (logdev: internal)
[  249.434782] ------------[ cut here ]------------
[  249.434962] kernel BUG at mm/vmalloc.c:942!
[  249.435053] invalid opcode: 0000 [#1] SMP 
[  249.435200] last sysfs file: /sys/devices/virtual/block/dm-5/dm/name
[  249.435291] CPU 1 
[  249.435324] Modules linked in: arc4 ecb ves1820 rt61pci crc_itu_t eeprom_93cx6 rt2x00pci rt2x00lib mac80211 budget budget_core saa7146 ttpci_eeprom dvb_core ftdi_sio usbserial evdev button cfg80211 shpchp pci_hotplug r8168 serio_raw pcspkr e1000e edac_core ohci_hcd
[  249.436509] 
[  249.436597] Pid: 2739, comm: mount Not tainted 2.6.38 #31 System manufacturer System Product Name/M4A785D-M PRO
[  249.436893] RIP: 0010:[<ffffffff810cb44e>]  [<ffffffff810cb44e>] vm_unmap_ram+0x9a/0x133
[  249.437078] RSP: 0018:ffff8801156fba88  EFLAGS: 00010246
[  249.437168] RAX: 0000000000000000 RBX: 0000000000000000 RCX: 0000000000000000
[  249.437260] RDX: 0000000000000000 RSI: 0000000000000041 RDI: 0000000000000001
[  249.437353] RBP: ffff8801156fbaa8 R08: 0000000000000000 R09: ffff8801125c4490
[  249.437445] R10: ffff880114ff5780 R11: dead000000200200 R12: 0000000000000006
[  249.437537] R13: ffffc900106e6000 R14: 0000000000040000 R15: ffff880114ff0dc0
[  249.437631] FS:  00007fba61615740(0000) GS:ffff8800dfd00000(0000) knlGS:0000000000000000
[  249.437777] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  249.437867] CR2: 00007fba61627000 CR3: 0000000114ff3000 CR4: 00000000000006e0
[  249.437959] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  249.438051] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  249.438144] Process mount (pid: 2739, threadinfo ffff8801156fa000, task ffff8801190c4290)
[  249.438288] Stack:
[  249.438374]  ffff880114ff0dc0 ffff880114ff0c80 0000000000000008 0000000000003590
[  249.438637]  ffff8801156fbac8 ffffffff811c167a ffff880119293800 ffff880114ff0c80
[  249.438677]  ffff8801156fbad8 ffffffff811b1b79 ffff8801156fbbf8 ffffffff811b4b37
[  249.438677] Call Trace:
[  249.438677]  [<ffffffff811c167a>] xfs_buf_free+0x38/0x78
[  249.438677]  [<ffffffff811b1b79>] xlog_put_bp+0x9/0xb
[  249.438677]  [<ffffffff811b4b37>] xlog_do_recovery_pass+0x5c8/0x5f4
[  249.438677]  [<ffffffff811b4bbb>] xlog_do_log_recovery+0x58/0x91
[  249.438677]  [<ffffffff811b300a>] ? xlog_find_tail+0x2a6/0x2fb
[  249.438677]  [<ffffffff811b4c07>] xlog_do_recover+0x13/0xed
[  249.438677]  [<ffffffff811b4e1b>] xlog_recover+0x7e/0x89
[  249.438677]  [<ffffffff811aedb0>] xfs_log_mount+0xdb/0x149
[  249.438677]  [<ffffffff811b714e>] xfs_mountfs+0x310/0x5c3
[  249.438677]  [<ffffffff811b7de1>] ? xfs_mru_cache_create+0x126/0x173
[  249.438677]  [<ffffffff811c8ecb>] xfs_fs_fill_super+0x183/0x2c4
[  249.438677]  [<ffffffff810e2d11>] mount_bdev+0x147/0x1ba
[  249.438677]  [<ffffffff811c8d48>] ? xfs_fs_fill_super+0x0/0x2c4
[  249.438677]  [<ffffffff811c7259>] xfs_fs_mount+0x10/0x12
[  249.438677]  [<ffffffff810e1f4f>] vfs_kern_mount+0x61/0x132
[  249.438677]  [<ffffffff810e207e>] do_kern_mount+0x48/0xda
[  249.438677]  [<ffffffff810f8aff>] do_mount+0x6ae/0x71b
[  249.438677]  [<ffffffff810f8dfd>] sys_mount+0x87/0xc8
[  249.438677]  [<ffffffff8102a8bb>] system_call_fastpath+0x16/0x1b
[  249.438677] Code: d1 e8 75 f8 48 be 00 00 00 00 00 37 00 00 48 c7 c7 b0 98 62 81 49 8d 74 35 00 48 c1 ee 16 e8 a2 8c 12 00 48 85 c0 48 89 c3 75 02 <0f> 0b 4b 8d 74 35 00 4c 89 ef e8 2d fa ff ff 48 89 df e8 21 3a 
[  249.438677] RIP  [<ffffffff810cb44e>] vm_unmap_ram+0x9a/0x133
[  249.438677]  RSP <ffff8801156fba88>
[  249.443421] ---[ end trace 2360f16b307700c6 ]---

Which is basically reading the log, not writing to it where l_xbuf
comes into play. The log reading code plays a _lot_ of tricks with
buffer offsets and sizes (if the simple l_xbuf tricks scare you, do
not look at this code ;). Hence it's definitely possible that the
size of the region being passed back to vm_unmap_ram() is wrong in
some of the error cases. I'll spend some more time to verify whether
they are restoring the buffer correctly or not before freeing it.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
