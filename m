Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f173.google.com (mail-lb0-f173.google.com [209.85.217.173])
	by kanga.kvack.org (Postfix) with ESMTP id 7D17C6B0254
	for <linux-mm@kvack.org>; Wed,  2 Sep 2015 07:08:55 -0400 (EDT)
Received: by lbcjc2 with SMTP id jc2so3850861lbc.0
        for <linux-mm@kvack.org>; Wed, 02 Sep 2015 04:08:54 -0700 (PDT)
Received: from mail-lb0-x22c.google.com (mail-lb0-x22c.google.com. [2a00:1450:4010:c04::22c])
        by mx.google.com with ESMTPS id t5si19323941lbb.35.2015.09.02.04.08.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Sep 2015 04:08:54 -0700 (PDT)
Received: by lbpo4 with SMTP id o4so3839338lbp.2
        for <linux-mm@kvack.org>; Wed, 02 Sep 2015 04:08:53 -0700 (PDT)
MIME-Version: 1.0
Date: Wed, 2 Sep 2015 13:08:52 +0200
Message-ID: <CAAeHK+zUJ74Zn17=rOyxacHU18SgCfC6bsYW=6kCY5GXJBwGfQ@mail.gmail.com>
Subject: Use-after-free in page_cache_async_readahead
From: Andrey Konovalov <andreyknvl@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Tejun Heo <tj@kernel.org>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>, Kostya Serebryany <kcc@google.com>

Hi!

While running KASAN on 4.2 with Trinity I got the following report:

==================================================================
BUG: KASan: use after free in page_cache_async_readahead+0x2cb/0x3f0
at addr ffff880034bf6690
Read of size 8 by task sshd/2571
=============================================================================
BUG kmalloc-16 (Tainted: G        W      ): kasan: bad access detected
-----------------------------------------------------------------------------

Disabling lock debugging due to kernel taint
INFO: Allocated in bdi_init+0x168/0x960 age=554826 cpu=0 pid=6
[<      none      >] __slab_alloc+0x492/0x4b0 mm/slub.c:2405
[<     inlined    >] kmem_cache_alloc_trace+0x13b/0x170
slab_alloc_node mm/slub.c:2473
[<     inlined    >] kmem_cache_alloc_trace+0x13b/0x170 slab_alloc
mm/slub.c:2515
[<      none      >] kmem_cache_alloc_trace+0x13b/0x170 mm/slub.c:2532
[<     inlined    >] bdi_init+0x168/0x960 kzalloc include/linux/slab.h:430
[<     inlined    >] bdi_init+0x168/0x960 cgwb_bdi_init mm/backing-dev.c:749
[<      none      >] bdi_init+0x168/0x960 mm/backing-dev.c:775
[<      none      >] blk_alloc_queue_node+0x147/0x670 block/blk-core.c:654
[<      none      >] blk_init_queue_node+0x1f/0x60 block/blk-core.c:750
[<      none      >] blk_init_queue+0xe/0x10 block/blk-core.c:741
[<      none      >] __scsi_alloc_queue+0x14/0x30 drivers/scsi/scsi_lib.c:2139
[<      none      >] scsi_alloc_queue+0x32/0xa0 drivers/scsi/scsi_lib.c:2151
[<      none      >] scsi_alloc_sdev+0x73b/0xd50 drivers/scsi/scsi_scan.c:266
[<      none      >] scsi_probe_and_add_lun+0x1545/0x2180
drivers/scsi/scsi_scan.c:1079
[<      none      >] __scsi_add_device+0x1eb/0x210 drivers/scsi/scsi_scan.c:1487
[<      none      >] ata_scsi_scan_host+0x13a/0x3d0
drivers/ata/libata-scsi.c:3736
[<      none      >] async_port_probe+0xae/0xe0 drivers/ata/libata-core.c:6096
[<      none      >] async_run_entry_fn+0xfa/0x3d0 kernel/async.c:123
[<      none      >] process_one_work+0x512/0x1220 kernel/workqueue.c:2032
[<      none      >] worker_thread+0xd7/0x1270 kernel/workqueue.c:2164
INFO: Freed in bdi_destroy+0x2d8/0x390 age=6389 cpu=0 pid=9823
[<      none      >] __slab_free+0x159/0x290 mm/slub.c:2590 (discriminator 1)
[<     inlined    >] kfree+0x143/0x150 slab_free mm/slub.c:2739
[<      none      >] kfree+0x143/0x150 mm/slub.c:3418
[<     inlined    >] bdi_destroy+0x2d8/0x390 wb_exit
include/linux/backing-dev.h:476
[<      none      >] bdi_destroy+0x2d8/0x390 mm/backing-dev.c:839
[<      none      >] blk_cleanup_queue+0x211/0x2b0 block/blk-core.c:581
[<      none      >] __scsi_remove_device+0xaf/0x210
drivers/scsi/scsi_sysfs.c:1087
[<      none      >] scsi_remove_device+0x39/0x50 drivers/scsi/scsi_sysfs.c:1113
[<      none      >] sdev_store_delete+0x22/0x30 drivers/scsi/scsi_sysfs.c:680
[<      none      >] dev_attr_store+0x37/0x70 drivers/base/core.c:137
[<      none      >] sysfs_kf_write+0x12c/0x1f0 fs/sysfs/file.c:131
[<      none      >] kernfs_fop_write+0x1f2/0x390 fs/kernfs/file.c:312
[<      none      >] do_loop_readv_writev+0x123/0x1e0 fs/read_write.c:680
[<      none      >] do_readv_writev+0x57b/0x680 fs/read_write.c:810
[<      none      >] vfs_writev+0x67/0xa0 fs/read_write.c:847
[<     inlined    >] SyS_writev+0x109/0x2d0 SYSC_writev fs/read_write.c:880
[<      none      >] SyS_writev+0x109/0x2d0 fs/read_write.c:872
[<      none      >] entry_SYSCALL_64_fastpath+0x12/0x71
arch/x86/entry/entry_64.S:186
INFO: Slab 0xffffea0000d2fd80 objects=12 used=11 fp=0xffff880034bf6690
flags=0x100000000000080
INFO: Object 0xffff880034bf6690 @offset=1680 fp=0x          (null)

Bytes b4 ffff880034bf6680: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
Object ffff880034bf6690: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00  ................
Redzone ffff880034bf66a0: bb bb bb bb bb bb bb bb
    ........
Padding ffff880034bf67d8: 00 00 00 00 00 00 00 00
    ........
CPU: 0 PID: 2571 Comm: sshd Tainted: G    B   W       4.2.0-kasan #19
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
 ffff880034bf6000 ffff880032867a18 ffffffff82d58114 0000000000000053
 ffff880035c03b00 ffff880032867a48 ffffffff81422074 ffff880035c03b00
 ffffea0000d2fd80 ffff880034bf6690 0000000000000000 ffff880032867a78
Call Trace:
 [<     inlined    >] dump_stack+0x45/0x57 __dump_stack lib/dump_stack.c:15
 [<ffffffff82d58114>] dump_stack+0x45/0x57 lib/dump_stack.c:50
 [<ffffffff81422074>] print_trailer+0xf4/0x150 mm/slub.c:650
 [<ffffffff81426aa3>] object_err+0x33/0x40 mm/slub.c:657
 [<     inlined    >] kasan_report_error+0x1e1/0x420
print_address_description mm/kasan/report.c:120
 [<ffffffff81429461>] kasan_report_error+0x1e1/0x420 mm/kasan/report.c:194
 [<ffffffff819f0e50>] ? __radix_tree_lookup+0x2c0/0x2c0 lib/radix-tree.c:532
 [<ffffffff811f76b2>] ? call_rcu_sched+0x12/0x20 kernel/rcu/tree.c:3074
 [<ffffffff814296c8>] kasan_report.part.2+0x28/0x30 mm/kasan/report.c:223
 [<     inlined    >] ? page_cache_async_readahead+0x2cb/0x3f0
wb_congested include/linux/backing-dev.h:192
 [<     inlined    >] ? page_cache_async_readahead+0x2cb/0x3f0
inode_congested include/linux/backing-dev.h:528
 [<     inlined    >] ? page_cache_async_readahead+0x2cb/0x3f0
inode_read_congested include/linux/backing-dev.h:535
 [<ffffffff8137933b>] ? page_cache_async_readahead+0x2cb/0x3f0
mm/readahead.c:544
 [<     inlined    >] __asan_report_load8_noabort+0x29/0x30
kasan_report mm/kasan/report.c:244
 [<ffffffff81429789>] __asan_report_load8_noabort+0x29/0x30
mm/kasan/report.c:244
 [<     inlined    >] page_cache_async_readahead+0x2cb/0x3f0
wb_congested include/linux/backing-dev.h:192
 [<     inlined    >] page_cache_async_readahead+0x2cb/0x3f0
inode_congested include/linux/backing-dev.h:528
 [<     inlined    >] page_cache_async_readahead+0x2cb/0x3f0
inode_read_congested include/linux/backing-dev.h:535
 [<ffffffff8137933b>] page_cache_async_readahead+0x2cb/0x3f0 mm/readahead.c:544
 [<     inlined    >] filemap_fault+0x6a6/0xaa0
do_async_mmap_readahead mm/filemap.c:1864
 [<ffffffff8135b256>] filemap_fault+0x6a6/0xaa0 mm/filemap.c:1917
 [<     inlined    >] ? unlock_page+0xfb/0x150 wake_up_page
include/linux/pagemap.h:501
 [<ffffffff81355ddb>] ? unlock_page+0xfb/0x150 mm/filemap.c:774
 [<ffffffff813c520d>] __do_fault+0xdd/0x180 mm/memory.c:2756
 [<ffffffff813c5130>] ? print_bad_pte+0x670/0x670 mm/memory.c:678
 [<     inlined    >] handle_mm_fault+0x1575/0x2910 do_fault mm/memory.c:2945
 [<     inlined    >] handle_mm_fault+0x1575/0x2910 handle_pte_fault
mm/memory.c:3255
 [<     inlined    >] handle_mm_fault+0x1575/0x2910 __handle_mm_fault
mm/memory.c:3379
 [<ffffffff813cea45>] handle_mm_fault+0x1575/0x2910 mm/memory.c:3408
 [<ffffffff81111830>] ? retarget_shared_pending+0x360/0x360
include/linux/signal.h:117
 [<ffffffff813cd4d0>] ? copy_page_range+0x1140/0x1140 mm/memory.c:1024
 [<ffffffff81118db0>] ? sigprocmask+0x140/0x290 kernel/signal.c:2573
 [<ffffffff813d564c>] ? find_vma+0x1c/0x120 mm/mmap.c:2033
 [<ffffffff810ce4e3>] __do_page_fault+0x2c3/0x840 arch/x86/mm/fault.c:1235
 [<ffffffff810f8aa0>] ? SyS_waitid+0x1d0/0x1d0 kernel/exit.c:1577
 [<ffffffff810ceafa>] trace_do_page_fault+0x6a/0x1c0 arch/x86/mm/fault.c:1328
 [<ffffffff810c2364>] do_async_page_fault+0x14/0x70 arch/x86/kernel/kvm.c:264
 [<ffffffff82d70ab8>] async_page_fault+0x28/0x30 arch/x86/entry/entry_64.S:1081
Memory state around the buggy address:
 ffff880034bf6580: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
 ffff880034bf6600: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
>ffff880034bf6680: fc fc fb fb fc fc fc fc fc fc fc fc fc fc fc fc
                         ^
 ffff880034bf6700: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
 ffff880034bf6780: fc fc fc fc fc fc fc fc fc fc fc fc 00 00 fc fc
==================================================================

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
