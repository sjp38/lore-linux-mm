Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5289A8E0001
	for <linux-mm@kvack.org>; Sun, 16 Dec 2018 17:21:24 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id t199so5016648wmd.3
        for <linux-mm@kvack.org>; Sun, 16 Dec 2018 14:21:24 -0800 (PST)
Received: from bhuna.collabora.co.uk (bhuna.collabora.co.uk. [2a00:1098:0:82:1000:25:2eeb:e3e3])
        by mx.google.com with ESMTPS id h9si5338129wrr.418.2018.12.16.14.21.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 16 Dec 2018 14:21:22 -0800 (PST)
Date: Sun, 16 Dec 2018 17:21:17 -0500
From: =?utf-8?B?R2HDq2w=?= PORTAY <gael.portay@collabora.com>
Subject: cma: deadlock using usb-storage and fs
Message-ID: <20181216222117.v5bzdfdvtulv2t54@archlinux.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, usb-storage@lists.one-eyed-alien.net
Cc: Alan Stern <stern@rowland.harvard.edu>

Dear kernel hackers,

I faced a deadlock in CMA (using usb-storage and FAT) between two tasks that
want to allocate CMA. All task involved are in D-state. I am running 4.19.1
mainline on an imx6q platform.

My understanding of that issue is as follow:

The first task gets in cma_alloc(), acquires the mutex, triggers page
migrations and yields.

	QSGRenderThread D    0  1852    564 0x00000000
	Backtrace: 
	[<c091d038>] (__schedule) from [<c091d844>] (schedule+0x5c/0xcc) r10:c0f04068 r9:efc2e600 r8:ffffe000 r7:00004000 r6:efc2e600 r5:edd31a94 r4:ffffe000
	[<c091d7e8>] (schedule) from [<c01575fc>] (io_schedule+0x20/0x48) r5:edd31a94 r4:00000000
	[<c01575dc>] (io_schedule) from [<c0211d84>] (wait_on_page_bit+0x10c/0x158) r5:edd31a94 r4:c0f04064
	[<c0211c78>] (wait_on_page_bit) from [<c026b608>] (migrate_pages+0x658/0x8e0) r10:efc2e600 r9:00000000 r8:00000000 r7:00000000 r6:ef899260 r5:ea733c7c r4:efc2e5e0
	[<c026afb0>] (migrate_pages) from [<c0220e10>] (alloc_contig_range+0x17c/0x3b0) r10:00071700 r9:c026c21c r8:00071b31 r7:00071b60 r6:ffffe000 r5:00000000 r4:edd31b54
	[<c0220c94>] (alloc_contig_range) from [<c026c8c8>] (cma_alloc+0x110/0x2f4) r10:00000460 r9:00020000 r8:fffffff4 r7:00000460 r6:c0fe0444 r5:00071700 r4:00001700
	[<c026c7b8>] (cma_alloc) from [<c018edb0>] (dma_alloc_from_contiguous+0x44/0x4c) r10:ecfe4840 r9:00000460 r8:00000647 r7:edd31cb4 r6:ec217c10 r5:00000001 r4:00460000
	[<c018ed6c>] (dma_alloc_from_contiguous) from [<c0119f40>] (__alloc_from_contiguous+0x58/0xf8)
	[<c0119ee8>] (__alloc_from_contiguous) from [<c011a030>] (cma_allocator_alloc+0x50/0x58) r10:ecfe4840 r9:eccfbd58 r8:c0f04d08 r7:00000000 r6:ffffffff r5:ec217c10 r4:006002c0
	[<c0119fe0>] (cma_allocator_alloc) from [<c011a218>] (__dma_alloc+0x1e0/0x308) r5:ec217c10 r4:006002c0
	[<c011a038>] (__dma_alloc) from [<c011a3d8>] (arm_dma_alloc+0x4c/0x58) r10:edd31e24 r9:eccfbd58 r8:c0f04d08 r7:c011a38c r6:ec217c10 r5:00000000 r4:00000004
	[<c011a38c>] (arm_dma_alloc) from [<c05b4928>] (drm_gem_cma_create+0xd0/0x168) r5:eccfbcc0 r4:00460000
	[<c05b4858>] (drm_gem_cma_create) from [<c05b4f2c>] (drm_gem_cma_dumb_create+0x50/0xa4) r9:c05ad874 r8:00000010 r7:00000000 r6:00000000 r5:ecd9c500 r4:edd31e34
	[<c05b4edc>] (drm_gem_cma_dumb_create) from [<c05ad860>] (drm_mode_create_dumb+0xbc/0xd0) r7:00000000 r6:00000000 r5:00000000 r4:00460000
	[<c05ad7a4>] (drm_mode_create_dumb) from [<c05ad88c>] (drm_mode_create_dumb_ioctl+0x18/0x1c) r7:00000000 r6:c0f04d08 r5:ec559000 r4:ecd9c500
	[<c05ad874>] (drm_mode_create_dumb_ioctl) from [<c058f3c8>] (drm_ioctl_kernel+0x90/0xec)
	[<c058f338>] (drm_ioctl_kernel) from [<c058f8ac>] (drm_ioctl+0x2c4/0x3e4) r10:c0f04d08 r9:edd31e24 r8:000000b2 r7:c02064b2 r6:ecd9c500 r5:00000020 r4:c0a47ac8
	[<c058f5e8>] (drm_ioctl) from [<c0286be4>] (do_vfs_ioctl+0xac/0x934) r10:00000036 r9:0000001a r8:ec554b90 r7:c02064b2 r6:ed0d3d80 r5:ac5df5d8 r4:c0f04d08
	[<c0286b38>] (do_vfs_ioctl) from [<c02874b0>] (ksys_ioctl+0x44/0x68) r10:00000036 r9:edd30000 r8:ac5df5d8 r7:c02064b2 r6:0000001a r5:ed0d3d80 r4:ed0d3d81
	[<c028746c>] (ksys_ioctl) from [<c02874ec>] (sys_ioctl+0x18/0x1c) r9:edd30000 r8:c0101204 r7:00000036 r6:c02064b2 r5:ac5df5d8 r4:ac5df640
	[<c02874d4>] (sys_ioctl) from [<c0101000>] (ret_fast_syscall+0x0/0x54)
	Exception stack(0xedd31fa8 to 0xedd31ff0)
	1fa0:                   ac5df640 ac5df5d8 0000001a c02064b2 ac5df5d8 00000005
	1fc0: ac5df640 ac5df5d8 c02064b2 00000036 00000380 0188cfc0 ac5df640 ac5df60c
	1fe0: b4bd0094 ac5df5b4 b4bb7bb4 b55444fc

The second task wants to writeback/flush the pages through USB, which, I
assume, is due to the page migration. The usb-storage triggers a CMA allocation
but get locked in cma_alloc since the first task hold the mutex (It is a FAT
formatted partition, if it helps).

	usb-storage     D    0   349      2 0x00000000
	Backtrace: 
	[<c091d038>] (__schedule) from [<c091d844>] (schedule+0x5c/0xcc) r10:00000002 r9:00020000 r8:c0f20b34 r7:00000000 r6:ece579a4 r5:ffffe000 r4:ffffe000
	[<c091d7e8>] (schedule) from [<c091dd90>] (schedule_preempt_disabled+0x30/0x4c) r5:ffffe000 r4:ffffe000
	[<c091dd60>] (schedule_preempt_disabled) from [<c091ee48>] (__mutex_lock.constprop.7+0x2f8/0x60c) r5:ffffe000 r4:c0f20b30
	[<c091eb50>] (__mutex_lock.constprop.7) from [<c091f274>] (__mutex_lock_slowpath+0x1c/0x20) r10:00000001 r9:00020000 r8:fffffff4 r7:00000001 r6:c0fe0444 r5:00070068 r4:00000068
	[<c091f258>] (__mutex_lock_slowpath) from [<c091f2c8>] (mutex_lock+0x50/0x54)
	[<c091f278>] (mutex_lock) from [<c026c8b4>] (cma_alloc+0xfc/0x2f4)
	[<c026c7b8>] (cma_alloc) from [<c018edb0>] (dma_alloc_from_contiguous+0x44/0x4c) r10:ed19e5c0 r9:00000001 r8:00000647 r7:ece57aec r6:ec215610 r5:00000001 r4:00001000
	[<c018ed6c>] (dma_alloc_from_contiguous) from [<c0119f40>] (__alloc_from_contiguous+0x58/0xf8)
	[<c0119ee8>] (__alloc_from_contiguous) from [<c011a030>] (cma_allocator_alloc+0x50/0x58) r10:ed19e5c0 r9:ed19e84c r8:c0f04d08 r7:00000000 r6:ffffffff r5:ec215610 r4:00600000
	[<c0119fe0>] (cma_allocator_alloc) from [<c011a218>] (__dma_alloc+0x1e0/0x308) r5:ec215610 r4:00600000
	[<c011a038>] (__dma_alloc) from [<c011a3d8>] (arm_dma_alloc+0x4c/0x58) r10:c011a38c r9:ec215610 r8:c0f04d08 r7:00600000 r6:ece6c808 r5:00000000 r4:00000000
	[<c011a38c>] (arm_dma_alloc) from [<c0264cec>] (dma_pool_alloc+0x21c/0x290) r5:ece6c800 r4:ed19e840
	[<c0264ad0>] (dma_pool_alloc) from [<bf25a40c>] (ehci_qtd_alloc+0x30/0x94 [ehci_hcd]) r10:00000200 r9:000000ca r8:e72e0260 r7:ece57c6c r6:f15c6f60 r5:c0f04d08 r4:00000200
	[<bf25a3dc>] (ehci_qtd_alloc [ehci_hcd]) from [<bf25cec8>] (qh_urb_transaction+0x150/0x42c [ehci_hcd]) r6:f15c6f60 r5:00019400 r4:00000200
	[<bf25cd78>] (qh_urb_transaction [ehci_hcd]) from [<bf25fad8>] (ehci_urb_enqueue+0x74/0xe3c [ehci_hcd]) r10:000000ef r9:eccd8c00 r8:ed236308 r7:ed236300 r6:00000000 r5:ece57c6c r4:00000003
	[<bf25fa64>] (ehci_urb_enqueue [ehci_hcd]) from [<bf1c478c>] (usb_hcd_submit_urb+0xc8/0x980 [usbcore]) r10:000000ef r9:00600000 r8:ed236308 r7:c0f04d08 r6:00000000 r5:eccd8c00 r4:ed236300
	[<bf1c46c4>] (usb_hcd_submit_urb [usbcore]) from [<bf1c6160>] (usb_submit_urb+0x360/0x564 [usbcore]) r10:000000ef r9:bf1d8924 r8:00000000 r7:00600000 r6:00000002 r5:eccc1800 r4:ed236300
	[<bf1c5e00>] (usb_submit_urb [usbcore]) from [<bf1c75b8>] (usb_sg_wait+0x68/0x154 [usbcore]) r10:0000001f r9:00000000 r8:00000001 r7:eca5951c r6:c0008200 r5:00000000 r4:eca59514
	[<bf1c7550>] (usb_sg_wait [usbcore]) from [<bf2bd618>] (usb_stor_bulk_transfer_sglist.part.2+0x80/0xdc [usb_storage]) r9:0001e000 r8:eca594ac r7:0001e000 r6:c0008200 r5:eca59514 r4:eca59488
	[<bf2bd598>] (usb_stor_bulk_transfer_sglist.part.2 [usb_storage]) from [<bf2bd6c0>] (usb_stor_bulk_srb+0x4c/0x7c [usb_storage]) r8:c0f04d08 r7:00000000 r6:ed71f0c0 r5:c0f04d08 r4:ed71f0c0
	[<bf2bd674>] (usb_stor_bulk_srb [usb_storage]) from [<bf2bd810>] (usb_stor_Bulk_transport+0x120/0x390 [usb_storage]) r5:f19e2000 r4:eca59488
	[<bf2bd6f0>] (usb_stor_Bulk_transport [usb_storage]) from [<bf2be14c>] (usb_stor_invoke_transport+0x3c/0x490 [usb_storage]) r10:ecd0bb3c r9:c0f03d00 r8:c0f04d08 r7:ed71f0c0 r6:c0f04d08 r5:ed71f0c0 r4:eca59488
	[<bf2be110>] (usb_stor_invoke_transport [usb_storage]) from [<bf2bcd58>] (usb_stor_transparent_scsi_command+0x18/0x1c [usb_storage]) r10:ecd0bb3c r9:c0f03d00 r8:c0f04d08 r7:ed71f0c0 r6:00000000 r5:eca59550 r4:eca59488
	[<bf2bcd40>] (usb_stor_transparent_scsi_command [usb_storage]) from [<bf2bf5e4>] (usb_stor_control_thread+0x174/0x29c [usb_storage])
	[<bf2bf470>] (usb_stor_control_thread [usb_storage]) from [<c0149fc4>] (kthread+0x154/0x16c)
	 r10:ecd0bb3c r9:bf2bf470 r8:eca59488 r7:ece56000 r6:ed1f4f80 r5:ecba3140
	 r4:00000000
	[<c0149e70>] (kthread) from [<c01010e8>] (ret_from_fork+0x14/0x2c)
	Exception stack(0xece57fb0 to 0xece57ff8)
	7fa0:                                     00000000 00000000 00000000 00000000
	7fc0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
	7fe0: 00000000 00000000 00000000 00000000 00000013 00000000
	 r10:00000000 r9:00000000 r8:00000000 r7:00000000 r6:00000000 r5:c0149e70
	 r4:ed1f4f80

The CMA in use is described in the DTS as follow:

        reserved-memory {
                #address-cells = <1>;
                #size-cells = <1>;
                ranges;

                linux,cma {
                        compatible = "shared-dma-pool";
                        reusable;
                        size = <0x20000000>;
                        linux,cma-default;
                };
        };

The issue is 100% reproductible using a Qt application, but I cannot
reproduce it (yet) using a simple script.

Also, here is stacktrace of another task involved in this issue. This task is
supposed to write a large amount of bytes (a tar of rootfs) in the USB flash
drive.

	openssl         D    0  1961   1878 0x00000000
	Backtrace: 
	[<c091d038>] (__schedule) from [<c091d844>] (schedule+0x5c/0xcc) r10:0000120c r9:c0f04d08 r8:c0f03ec4 r7:ffffe000 r6:e73dbcd4 r5:c0f03ec0 r4:ffffe000
	[<c091d7e8>] (schedule) from [<c01575fc>] (io_schedule+0x20/0x48) r5:c0f03ec0 r4:00000000
	[<c01575dc>] (io_schedule) from [<c0212250>] (__lock_page+0xfc/0x168) r5:c0f03ec0 r4:ef9f44a0
	[<c0212154>] (__lock_page) from [<c022206c>] (write_cache_pages+0x118/0x508) r9:ea733c7c r8:00000000 r7:e73dbd3c r6:e73dbe68 r5:00000001 r4:ef9f44a0
	[<c0221f54>] (write_cache_pages) from [<c02b9eb8>] (mpage_writepages+0x74/0x100) r10:e601bd88 r9:00000000 r8:00000000 r7:00000001 r6:e73dbe68 r5:c0f04d08 r4:c038003c
	[<c02b9e44>] (mpage_writepages) from [<c037dd30>] (fat_writepages+0x1c/0x24) r9:00000008 r8:c02218a8 r7:c0f04d08 r6:ffffffff r5:ea733c7c r4:e73dbe68
	[<c037dd14>] (fat_writepages) from [<c022475c>] (do_writepages+0x4c/0xec)
	[<c0224710>] (do_writepages) from [<c0214ad8>] (__filemap_fdatawrite_range+0x8c/0xc8) r8:e9918990 r7:7fffffff r6:ffffffff r5:ea733c7c r4:c0f04d08
	[<c0214a4c>] (__filemap_fdatawrite_range) from [<c0214b4c>] (filemap_fdatawrite+0x38/0x40) r7:ece13610 r6:ea733b90 r5:7fffffff r4:ffffffff
	[<c0214b14>] (filemap_fdatawrite) from [<c037ff1c>] (writeback_inode+0x30/0x34) r5:00000000 r4:ea733b90
	[<c037feec>] (writeback_inode) from [<c037ff5c>] (fat_flush_inodes+0x3c/0x94) r5:00000000 r4:eccc5c00
	[<c037ff20>] (fat_flush_inodes) from [<c037cac8>] (fat_file_release+0x4c/0x60) r5:00000000 r4:e601bd80
	[<c037ca7c>] (fat_file_release) from [<c0273c10>] (__fput+0x98/0x1d4)
	[<c0273b78>] (__fput) from [<c0273dbc>] (____fput+0x18/0x1c) r10:e601bd80 r9:edd16470 r8:c0f926d4 r7:00000000 r6:edd16000 r5:edd1645c r4:00000000
	[<c0273da4>] (____fput) from [<c01481c4>] (task_work_run+0xa0/0xc4)
	[<c0148124>] (task_work_run) from [<c010d924>] (do_work_pending+0xe4/0xf8) r10:00000006 r9:e73da000 r8:c0101204 r7:e73dbfb0 r6:c0101204 r5:ffffe000 r4:00000000 r3:edd16000
	[<c010d840>] (do_work_pending) from [<c010106c>] (slow_work_pending+0xc/0x20)
	Exception stack(0xe73dbfb0 to 0xe73dbff8)
	bfa0:                                     00000000 00000444 b6d5f6e0 b6c89ed4
	bfc0: 00bf75d8 b6d5fb24 00000000 00000006 00000000 0009e6d8 00bfb1c0 00bf83a8
	bfe0: fbad2c04 beb0813c b6c8b668 b6ce469c 20070010 00000003
	 r7:00000006 r6:00000000 r5:b6d5fb24 r4:00bf75d8

I wonder if someone has already met that issue, and I really need your help or
some tips to fix it.

Kind Regards,
Gael
