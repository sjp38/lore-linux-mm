Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 21BCD6B0069
	for <linux-mm@kvack.org>; Thu,  6 Oct 2016 11:34:57 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id b80so2123191wme.1
        for <linux-mm@kvack.org>; Thu, 06 Oct 2016 08:34:57 -0700 (PDT)
Received: from pandora.armlinux.org.uk (pandora.armlinux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id iw5si17581834wjb.86.2016.10.06.08.34.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 06 Oct 2016 08:34:55 -0700 (PDT)
Date: Thu, 6 Oct 2016 16:34:43 +0100
From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: DMA-API: cpu touching an active dma mapped cacheline
Message-ID: <20161006153443.GT1041@n2100.armlinux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>

Hi,

With DMA API debugging enabled, I'm seeing this splat from it, which to
me looks like the DMA API debugging is getting too eager for it's own
good.

The fact of the matter is that the VM passes block devices pages to be
written out to disk which are page cache pages, which may be looked up
and written to by write() syscalls and via mmap() mappings.  For example,
take the case of a writable shared mapping of a page backed by a file on
a disk - the VM will periodically notice that the page has been dirtied,
and schedule a writeout to disk.  The disk driver has no idea that the
page is still mapped - and arguably it doesn't matter.

So, IMHO this whole "the CPU is touching a DMA mapped buffer" is quite
bogus given our VM behaviour: we have never guaranteed exclusive access
to DMA buffers.

I don't see any maintainer listed for lib/dma-debug.c, but I see the
debug_dma_assert_idle() stuff was introduced by Dan via akpm in 2014.

WARNING: CPU: 0 PID: 2025 at lib/dma-debug.c:606 debug_dma_assert_idle+0x1ac/0x218
sata_mv f10a0000.sata-host: DMA-API: cpu touching an active dma mapped cacheline [cln=0x00a09ec0]
Modules linked in: bluetooth nfsd exportfs ext2 snd_soc_spdif_tx dove_thermal snd_soc_kirkwood tda9950 rc_cec marvell_cesa des_generic orion_wdt ir_lirc_codec lirc_dev etnaviv snd_soc_kirkwood_spdif gpio_ir_recv thermal_sys hwmon fuse
CPU: 0 PID: 2025 Comm: init Not tainted 4.8.0+ #1341
Hardware name: Marvell Dove (Cubox)
Backtrace:
[<c00140e8>] (dump_backtrace) from [<c0014408>] (show_stack+0x18/0x1c)
 r6:00000000 r5:c0768bb8 r4:e5637d60 r3:00000000
[<c00143f0>] (show_stack) from [<c029dd98>] (dump_stack+0x20/0x28)
[<c029dd78>] (dump_stack) from [<c0027970>] (__warn+0xe0/0x108)
[<c0027890>] (__warn) from [<c0027a50>] (warn_slowpath_fmt+0x40/0x48)
 r10:00000000 r8:c088060c r7:a0030113 r6:c1168780 r5:c0847fc8 r4:e6992100
[<c0027a14>] (warn_slowpath_fmt) from [<c02c3f9c>] (debug_dma_assert_idle+0x1ac/0x218)
 r3:c073f708 r2:c0769540
[<c02c3df0>] (debug_dma_assert_idle) from [<c011b240>] (wp_page_copy+0x78/0x4c8)
 r10:e754f960 r8:7f6bd000 r7:e45a3000 r6:e57c89f8 r5:e5637e64 r4:e753df60
[<c011b1c8>] (wp_page_copy) from [<c011c598>] (do_wp_page+0x158/0x660)
 r10:e45a3054 r9:00000055 r8:7f6bd238 r7:e57c89f8 r6:2827b3cf r5:e753df60
 r4:e5637e64
[<c011c440>] (do_wp_page) from [<c011ec68>] (handle_mm_fault+0x338/0xa68)
 r10:e45a3054 r9:00000055 r8:7f6bd238 r7:0000081f r6:e45a3000 r5:0003bdd0
 r4:2827b3cf
[<c011e930>] (handle_mm_fault) from [<c001d594>] (do_page_fault+0x264/0x380)
 r10:e45a3054 r8:7f6bd238 r7:0000081f r6:e45a3000 r5:e626ea80 r4:e5637fb0
[<c001d330>] (do_page_fault) from [<c0009380>] (do_DataAbort+0x3c/0xbc)
 r10:b6f1cf88 r9:b6e6c9e4 r8:e5637fb0 r7:c084d604 r6:7f6bd238 r5:c001d330
 r4:0000081f
[<c0009344>] (do_DataAbort) from [<c0015284>] (__dabt_usr+0x44/0x60)
Exception stack(0xe5637fb0 to 0xe5637ff8)
7fa0:                                     7f6bd23c b6f1cf88 00000003 b6e754e0
7fc0: b6f1cf8b b6b5682c 00000003 bea57d54 7f6bd218 b6e6c9e4 b6f1cf88 bea57e88
7fe0: 00000000 bea57d38 bea57cf4 b6e43794 00030030 ffffffff
 r8:10c53c7d r7:10c5387d r6:ffffffff r5:00030030 r4:b6e43794
---[ end trace 614b28441e79e7b1 ]---
Mapped at:
 [<c0133fa0>] dma_pool_alloc+0x124/0x23c
 [<c03c76b8>] mv_port_start+0xfc/0x150
 [<c03a8550>] ata_host_start+0x100/0x1e0
 [<c03ae714>] ata_host_activate+0x24/0x138
 [<c03c7b0c>] mv_platform_probe+0x400/0x4b8

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
