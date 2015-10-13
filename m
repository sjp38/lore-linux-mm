Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id E98616B0254
	for <linux-mm@kvack.org>; Tue, 13 Oct 2015 04:00:40 -0400 (EDT)
Received: by wieq12 with SMTP id q12so18812533wie.1
        for <linux-mm@kvack.org>; Tue, 13 Oct 2015 01:00:40 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id wn7si2379105wjb.200.2015.10.13.01.00.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 13 Oct 2015 01:00:39 -0700 (PDT)
Date: Tue, 13 Oct 2015 10:00:36 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: Potential use-after-free in shrink_page_list
Message-ID: <20151013080036.GH17050@quack.suse.cz>
References: <CAAeHK+xssNPqHVFGbHqCd1bp7n_yJy6m443Be5jsvJM2GEizMw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAeHK+xssNPqHVFGbHqCd1bp7n_yJy6m443Be5jsvJM2GEizMw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Jens Axboe <axboe@fb.com>, Tejun Heo <tj@kernel.org>, Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>, Kostya Serebryany <kcc@google.com>, kasan-dev <kasan-dev@googlegroups.com>, Christoph Hellwig <hch@infradead.org>

  Hello,

On Wed 07-10-15 18:43:30, Andrey Konovalov wrote:
> While fuzzing the kernel (4.3-rc4) with KASAN and Trinity I got the
> following report:
> 
> ==================================================================
> BUG: KASan: use after free in shrink_page_list+0x93a/0xf10 at addr
> ffff88003487da80

Hum, looking into a trace it seems KASAN really found a page with inode
belonging to a destroyed BDI. I think this may be the same problem that was
also reported in http://lists.openwall.net/linux-ext4/2015/08/13/3.
Christoph, did you have time to look into it?

								Honza

> Read of size 8 by task kswapd0/622
> =============================================================================
> BUG kmalloc-16 (Not tainted): kasan: bad access detected
> -----------------------------------------------------------------------------
> 
> Disabling lock debugging due to kernel taint
> INFO: Allocated in bdi_init+0xb9/0x480 age=235622 cpu=0 pid=6
> [<      none      >] __slab_alloc+0x44a/0x480 mm/slub.c:2402
> [<     inline     >] slab_alloc mm/slub.c:2470
> [<      none      >] kmem_cache_alloc_trace+0x12a/0x160 mm/slub.c:2529
> [<     inline     >] kmalloc include/linux/slab.h:440
> [<     inline     >] kzalloc include/linux/slab.h:593
> [<     inline     >] cgwb_bdi_init mm/backing-dev.c:749
> [<      none      >] bdi_init+0xb9/0x480 mm/backing-dev.c:775
> [<      none      >] blk_alloc_queue_node+0xfc/0x380 block/blk-core.c:656
> [<      none      >] blk_init_queue_node+0x1f/0x60 block/blk-core.c:754
> [<      none      >] blk_init_queue+0xe/0x10 block/blk-core.c:745
> [<      none      >] __scsi_alloc_queue+0x14/0x30 drivers/scsi/scsi_lib.c:2139
> [<      none      >] scsi_alloc_queue+0x1c/0x80 drivers/scsi/scsi_lib.c:2151
> [<      none      >] scsi_alloc_sdev+0x3cd/0x5f0 scsi_scan.c:0
> [<      none      >] scsi_probe_and_add_lun+0xc3a/0x10a0 scsi_scan.c:0
> [<      none      >] __scsi_add_device+0x112/0x120 ??:0
> [<      none      >] ata_scsi_scan_host+0xed/0x260 ??:0
> [<      none      >] async_port_probe+0x61/0x80 drivers/ata/libata-core.c:6097
> [<      none      >] async_run_entry_fn+0x74/0x190 async.c:0
> [<      none      >] process_one_work+0x276/0x630 kernel/workqueue.c:2030
> [<      none      >] worker_thread+0x98/0x720 kernel/workqueue.c:2162
> INFO: Freed in bdi_destroy+0x1d9/0x200 age=1073 cpu=0 pid=5919
> [<      none      >] __slab_free+0x150/0x270 mm/slub.c:2587
> [<     inline     >] slab_free mm/slub.c:2736
> [<      none      >] kfree+0x13a/0x150 mm/slub.c:3522
> [<     inline     >] wb_exit include/linux/backing-dev.h:483
> [<      none      >] bdi_destroy+0x1d9/0x200 mm/backing-dev.c:839
> [<      none      >] blk_cleanup_queue+0x158/0x190 block/blk-core.c:579
> [<      none      >] __scsi_remove_device+0x63/0x110 ??:0
> [<      none      >] scsi_remove_device+0x27/0x40 ??:0
> [<      none      >] sdev_store_delete+0x22/0x30 scsi_sysfs.c:0
> [<      none      >] dev_attr_store+0x39/0x50 drivers/base/core.c:137
> [<      none      >] sysfs_kf_write+0x8a/0xa0 file.c:0
> [<      none      >] kernfs_fop_write+0x167/0x200 file.c:0
> [<      none      >] __vfs_write+0x57/0x170 ??:0
> [<      none      >] vfs_write+0xeb/0x250 ??:0
> [<      none      >] SyS_write+0x53/0xb0 ??:0
> [<      none      >] entry_SYSCALL_64_fastpath+0x12/0x71
> arch/x86/entry/entry_64.S:185
> 
> INFO: Slab 0xffffea0000d21f40 objects=12 used=4 fp=0xffff88003487d3f0
> flags=0x100000000000080
> INFO: Object 0xffff88003487da80 @offset=2688 fp=0x          (null)
> 
> Bytes b4 ffff88003487da70: a3 08 ff ff 00 00 00 00 aa 18 57 81 ff ff
> ff ff  ..........W.....
> Object ffff88003487da80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 00  ................
> Redzone ffff88003487da90: bb bb bb bb bb bb bb bb
>     ........
> Padding ffff88003487dbc8: 84 d5 76 81 ff ff ff ff
>     ..v.....
> CPU: 0 PID: 622 Comm: kswapd0 Tainted: G    B           4.3.0-rc4-kasan #16
> Hardware name: Red Hat KVM, BIOS 0.5.1 01/01/2007
>  ffff88003487da80 ffff880034c0f878 ffffffff814a3e7c ffff880036003b00
>  ffff880034c0f8a8 ffffffff812090b8 ffff880036003b00 ffffea0000d21f40
>  ffff88003487da80 ffffea0000ceaf98 ffff880034c0f8d0 ffffffff8120def1
> Call Trace:
>  [<ffffffff814a3e7c>] dump_stack+0x44/0x58 lib/dump_stack.c:15
>  [<ffffffff812090b8>] print_trailer+0xf8/0x150 mm/slub.c:650
>  [<ffffffff8120def1>] object_err+0x31/0x40 mm/slub.c:657
>  [<ffffffff81210215>] kasan_report_error+0x1e5/0x3f0 ??:0
>  [<ffffffff81210804>] kasan_report+0x34/0x40 ??:0
>  [<     inline     >] ? inode_write_congested include/linux/backing-dev.h:193
>  [<ffffffff811bcc1a>] ? shrink_page_list+0x93a/0xf10 mm/vmscan.c:957
>  [<ffffffff8120f564>] __asan_load8+0x64/0xa0 ??:0
>  [<ffffffff811c814f>] ? page_mapping+0x2f/0x70 ??:0
>  [<     inline     >] inode_write_congested include/linux/backing-dev.h:193
>  [<ffffffff811bcc1a>] shrink_page_list+0x93a/0xf10 mm/vmscan.c:957
>  [<ffffffff811bda74>] shrink_inactive_list+0x2f4/0x5f0 mm/vmscan.c:1610
>  [<     inline     >] shrink_list mm/vmscan.c:1945
>  [<ffffffff811bea0a>] shrink_lruvec+0x87a/0xa50 mm/vmscan.c:2229
>  [<ffffffff811beca0>] shrink_zone+0xc0/0x2c0 mm/vmscan.c:2413
>  [<     inline     >] kswapd_shrink_zone mm/vmscan.c:3116
>  [<     inline     >] balance_pgdat mm/vmscan.c:3291
>  [<ffffffff811bffad>] kswapd+0x64d/0xb70 mm/vmscan.c:3499
>  [<ffffffff811bf960>] ? zone_reclaim+0x2a0/0x2a0 mm/vmscan.c:3820
>  [<ffffffff810a491f>] kthread+0x10f/0x130 kthread.c:0
>  [<ffffffff810a4810>] ? kthread_park+0x70/0x70 ??:0
>  [<ffffffff81d4fb5f>] ret_from_fork+0x3f/0x70 arch/x86/entry/entry_64.S:472
>  [<ffffffff810a4810>] ? kthread_park+0x70/0x70 ??:0
> Memory state around the buggy address:
>  ffff88003487d980: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
>  ffff88003487da00: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
> >ffff88003487da80: fb fb fc fc fc fc fc fc fc fc fc fc fc fc fc fc
>                    ^
>  ffff88003487db00: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
>  ffff88003487db80: fc fc fc fc fc fc fc fc fc fc 00 00 fc fc fc fc
> ==================================================================
> 
> Thanks!
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
