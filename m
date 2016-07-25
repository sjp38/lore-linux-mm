Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id BD4F56B0253
	for <linux-mm@kvack.org>; Mon, 25 Jul 2016 17:31:02 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id y134so428353494pfg.1
        for <linux-mm@kvack.org>; Mon, 25 Jul 2016 14:31:02 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id qp6si18988297pab.258.2016.07.25.14.31.01
        for <linux-mm@kvack.org>;
        Mon, 25 Jul 2016 14:31:01 -0700 (PDT)
Date: Mon, 25 Jul 2016 15:30:59 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 14/15] dax: Protect PTE modification on WP fault by radix
 tree entry lock
Message-ID: <20160725213059.GA19713@linux.intel.com>
References: <1469189981-19000-1-git-send-email-jack@suse.cz>
 <1469189981-19000-15-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1469189981-19000-15-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Fri, Jul 22, 2016 at 02:19:40PM +0200, Jan Kara wrote:
> Currently PTE gets updated in wp_pfn_shared() after dax_pfn_mkwrite()
> has released corresponding radix tree entry lock. When we want to
> writeprotect PTE on cache flush, we need PTE modification to happen
> under radix tree entry lock to ensure consisten updates of PTE and radix
> tree (standard faults use page lock to ensure this consistency). So move
> update of PTE bit into dax_pfn_mkwrite().
> 
> Signed-off-by: Jan Kara <jack@suse.cz>

After applying the whole series to a v4.7 baseline I was hitting a deadlock in
my testing, and it bisected to this commit.  This deadlock happens in my QEMU
guest with generic/068, ext4 and DAX.  It reproduces 100% of the time after
this commit.

Here is the lockdep info, passed through kasan_symbolize.py:

run fstests generic/068 at 2016-07-25 15:29:10
EXT4-fs (pmem0p2): DAX enabled. Warning: EXPERIMENTAL, use at your own risk
EXT4-fs (pmem0p2): mounted filesystem with ordered data mode. Opts: dax

======================================================
[ INFO: HARDIRQ-safe -> HARDIRQ-unsafe lock order detected ]
4.7.0+ #1 Not tainted
------------------------------------------------------
fstest/1856 [HC0[0]:SC0[0]:HE0:SE1] is trying to acquire:
 (&(ptlock_ptr(page))->rlock#2){+.+...}, at: [<     inline     >] spin_lock include/linux/spinlock.h:302
 (&(ptlock_ptr(page))->rlock#2){+.+...}, at: [<ffffffff8121c0b7>] finish_mkwrite_fault+0xa7/0x120 mm/memory.c:2286

and this task is already holding:
 (&(&mapping->tree_lock)->rlock){-.-...}, at: [<     inline     >] spin_lock_irq include/linux/spinlock.h:332
 (&(&mapping->tree_lock)->rlock){-.-...}, at: [<ffffffff812d5086>] dax_pfn_mkwrite+0x36/0x90 fs/dax.c:1280
which would create a new lock dependency:
 (&(&mapping->tree_lock)->rlock){-.-...} -> (&(ptlock_ptr(page))->rlock#2){+.+...}

but this new dependency connects a HARDIRQ-irq-safe lock:
 (&(&mapping->tree_lock)->rlock){-.-...}
... which became HARDIRQ-irq-safe at:
  [<     inline     >] mark_irqflags kernel/locking/lockdep.c:2912
  [<ffffffff8110a236>] __lock_acquire+0x706/0x14b0 kernel/locking/lockdep.c:3287
  [<ffffffff8110b490>] lock_acquire+0xf0/0x1d0 kernel/locking/lockdep.c:3741
  [<     inline     >] __raw_spin_lock_irqsave include/linux/spinlock_api_smp.h:112
  [<ffffffff81ad02ff>] _raw_spin_lock_irqsave+0x4f/0x90 kernel/locking/spinlock.c:159
  [<ffffffff811f2a27>] test_clear_page_writeback+0x67/0x2a0 mm/page-writeback.c:2737
  [<ffffffff811de81f>] end_page_writeback+0x1f/0xa0 mm/filemap.c:858
  [<ffffffff812b9495>] end_buffer_async_write+0xc5/0x180 fs/buffer.c:375
  [<ffffffff812b8338>] end_bio_bh_io_sync+0x28/0x40 fs/buffer.c:2936
  [<ffffffff81575907>] bio_endio+0x57/0x60 block/bio.c:1758
  [<ffffffff818915fc>] dec_pending+0x21c/0x340 drivers/md/dm.c:1015
  [<ffffffff818922a6>] clone_endio+0x76/0xe0 drivers/md/dm.c:1059
  [<ffffffff81575907>] bio_endio+0x57/0x60 block/bio.c:1758
  [<     inline     >] req_bio_endio block/blk-core.c:155
  [<ffffffff8157f072>] blk_update_request+0xa2/0x3c0 block/blk-core.c:2644
  [<ffffffff8158998a>] blk_mq_end_request+0x1a/0x70 block/blk-mq.c:320
  [<ffffffff8177bcdf>] virtblk_request_done+0x3f/0x70 drivers/block/virtio_blk.c:131
  [<ffffffff81588983>] __blk_mq_complete_request_remote+0x13/0x20 block/blk-mq.c:330
  [<ffffffff8114bebf>] flush_smp_call_function_queue+0x5f/0x150 kernel/smp.c:249
  [<ffffffff8114c903>] generic_smp_call_function_single_interrupt+0x13/0x60 kernel/smp.c:194
  [<     inline     >] __smp_call_function_single_interrupt arch/x86/kernel/smp.c:311
  [<ffffffff810575a7>] smp_call_function_single_interrupt+0x27/0x40 arch/x86/kernel/smp.c:318
  [<ffffffff81ad1926>] call_function_single_interrupt+0x96/0xa0 arch/x86/entry/entry_64.S:639
  [<     inline     >] raw_spin_unlock_irq_rcu_node kernel/rcu/tree.h:718
  [<     inline     >] rcu_gp_init kernel/rcu/tree.c:1934
  [<ffffffff8112a5f7>] rcu_gp_kthread+0x157/0x8f0 kernel/rcu/tree.c:2175
  [<ffffffff810d59e6>] kthread+0xf6/0x110 kernel/kthread.c:209
  [<ffffffff81ad06af>] ret_from_fork+0x1f/0x40 arch/x86/entry/entry_64.S:389

to a HARDIRQ-irq-unsafe lock:
 (&(ptlock_ptr(page))->rlock#2){+.+...}
... which became HARDIRQ-irq-unsafe at:
...  [<     inline     >] mark_irqflags kernel/locking/lockdep.c:2929
...  [<ffffffff8110a0f1>] __lock_acquire+0x5c1/0x14b0 kernel/locking/lockdep.c:3287
  [<ffffffff8110b490>] lock_acquire+0xf0/0x1d0 kernel/locking/lockdep.c:3741
  [<     inline     >] __raw_spin_lock include/linux/spinlock_api_smp.h:144
  [<ffffffff81acf796>] _raw_spin_lock+0x36/0x70 kernel/locking/spinlock.c:151
  [<     inline     >] spin_lock include/linux/spinlock.h:302
  [<     inline     >] do_anonymous_page mm/memory.c:2823
  [<     inline     >] handle_pte_fault mm/memory.c:3378
  [<     inline     >] __handle_mm_fault mm/memory.c:3505
  [<ffffffff8121ea5c>] handle_mm_fault+0x196c/0x1d60 mm/memory.c:3534
  [<     inline     >] faultin_page mm/gup.c:378
  [<ffffffff8121829a>] __get_user_pages+0x18a/0x760 mm/gup.c:577
  [<     inline     >] __get_user_pages_locked mm/gup.c:754
  [<ffffffff81218c84>] get_user_pages_remote+0x54/0x60 mm/gup.c:962
  [<     inline     >] get_arg_page fs/exec.c:206
  [<ffffffff81280bcf>] copy_strings.isra.21+0x15f/0x3e0 fs/exec.c:521
  [<ffffffff81280e84>] copy_strings_kernel+0x34/0x40 fs/exec.c:566
  [<ffffffff812815fa>] do_execveat_common.isra.36+0x57a/0x970 fs/exec.c:1690
  [<ffffffff81281a1c>] do_execve+0x2c/0x30 fs/exec.c:1747
  [<ffffffff810c9f80>] call_usermodehelper_exec_async+0xf0/0x140 kernel/kmod.c:252
  [<ffffffff81ad06af>] ret_from_fork+0x1f/0x40 arch/x86/entry/entry_64.S:389

other info that might help us debug this:

 Possible interrupt unsafe locking scenario:

       CPU0                    CPU1
       ----                    ----
  lock(&(ptlock_ptr(page))->rlock#2);
                               local_irq_disable();
                               lock(&(&mapping->tree_lock)->rlock);
                               lock(&(ptlock_ptr(page))->rlock#2);
  <Interrupt>
    lock(&(&mapping->tree_lock)->rlock);

 *** DEADLOCK ***

4 locks held by fstest/1856:
 #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff81070ad2>] __do_page_fault+0x152/0x4c0 arch/x86/mm/fault.c:1295
 #1:  (sb_pagefaults){++++..}, at: [<ffffffff8127c854>] __sb_start_write+0xb4/0xf0 fs/super.c:1197
 #2:  (&ei->i_mmap_sem){++++.+}, at: [<ffffffff8131cd04>] ext4_dax_pfn_mkwrite+0x54/0xa0 fs/ext4/file.c:273
 #3:  (&(&mapping->tree_lock)->rlock){-.-...}, at: [<     inline     >] spin_lock_irq include/linux/spinlock.h:332
 #3:  (&(&mapping->tree_lock)->rlock){-.-...}, at: [<ffffffff812d5086>] dax_pfn_mkwrite+0x36/0x90 fs/dax.c:1280

the dependencies between HARDIRQ-irq-safe lock and the holding lock:
-> (&(&mapping->tree_lock)->rlock){-.-...} ops: 605595 {
   IN-HARDIRQ-W at:
                    [<     inline     >] mark_irqflags kernel/locking/lockdep.c:2912
                    [<ffffffff8110a236>] __lock_acquire+0x706/0x14b0 kernel/locking/lockdep.c:3287
                    [<ffffffff8110b490>] lock_acquire+0xf0/0x1d0 kernel/locking/lockdep.c:3741
                    [<     inline     >] __raw_spin_lock_irqsave include/linux/spinlock_api_smp.h:112
                    [<ffffffff81ad02ff>] _raw_spin_lock_irqsave+0x4f/0x90 kernel/locking/spinlock.c:159
                    [<ffffffff811f2a27>] test_clear_page_writeback+0x67/0x2a0 mm/page-writeback.c:2737
                    [<ffffffff811de81f>] end_page_writeback+0x1f/0xa0 mm/filemap.c:858
                    [<ffffffff812b9495>] end_buffer_async_write+0xc5/0x180 fs/buffer.c:375
                    [<ffffffff812b8338>] end_bio_bh_io_sync+0x28/0x40 fs/buffer.c:2936
                    [<ffffffff81575907>] bio_endio+0x57/0x60 block/bio.c:1758
                    [<ffffffff818915fc>] dec_pending+0x21c/0x340 drivers/md/dm.c:1015
                    [<ffffffff818922a6>] clone_endio+0x76/0xe0 drivers/md/dm.c:1059
                    [<ffffffff81575907>] bio_endio+0x57/0x60 block/bio.c:1758
                    [<     inline     >] req_bio_endio block/blk-core.c:155
                    [<ffffffff8157f072>] blk_update_request+0xa2/0x3c0 block/blk-core.c:2644
                    [<ffffffff8158998a>] blk_mq_end_request+0x1a/0x70 block/blk-mq.c:320
                    [<ffffffff8177bcdf>] virtblk_request_done+0x3f/0x70 drivers/block/virtio_blk.c:131
                    [<ffffffff81588983>] __blk_mq_complete_request_remote+0x13/0x20 block/blk-mq.c:330
                    [<ffffffff8114bebf>] flush_smp_call_function_queue+0x5f/0x150 kernel/smp.c:249
                    [<ffffffff8114c903>] generic_smp_call_function_single_interrupt+0x13/0x60 kernel/smp.c:194
                    [<     inline     >] __smp_call_function_single_interrupt arch/x86/kernel/smp.c:311
                    [<ffffffff810575a7>] smp_call_function_single_interrupt+0x27/0x40 arch/x86/kernel/smp.c:318
                    [<ffffffff81ad1926>] call_function_single_interrupt+0x96/0xa0 arch/x86/entry/entry_64.S:639
                    [<     inline     >] raw_spin_unlock_irq_rcu_node kernel/rcu/tree.h:718
                    [<     inline     >] rcu_gp_init kernel/rcu/tree.c:1934
                    [<ffffffff8112a5f7>] rcu_gp_kthread+0x157/0x8f0 kernel/rcu/tree.c:2175
                    [<ffffffff810d59e6>] kthread+0xf6/0x110 kernel/kthread.c:209
                    [<ffffffff81ad06af>] ret_from_fork+0x1f/0x40 arch/x86/entry/entry_64.S:389
   IN-SOFTIRQ-W at:
                    [<     inline     >] mark_irqflags kernel/locking/lockdep.c:2915
                    [<ffffffff8110a0cf>] __lock_acquire+0x59f/0x14b0 kernel/locking/lockdep.c:3287
                    [<ffffffff8110b490>] lock_acquire+0xf0/0x1d0 kernel/locking/lockdep.c:3741
                    [<     inline     >] __raw_spin_lock_irqsave include/linux/spinlock_api_smp.h:112
                    [<ffffffff81ad02ff>] _raw_spin_lock_irqsave+0x4f/0x90 kernel/locking/spinlock.c:159
                    [<ffffffff811f2a27>] test_clear_page_writeback+0x67/0x2a0 mm/page-writeback.c:2737
                    [<ffffffff811de81f>] end_page_writeback+0x1f/0xa0 mm/filemap.c:858
                    [<ffffffff8132cc89>] ext4_finish_bio+0x159/0x1e0 fs/ext4/page-io.c:119
                    [<ffffffff8132d09f>] ext4_end_bio+0x4f/0x100 fs/ext4/page-io.c:333
                    [<ffffffff81575907>] bio_endio+0x57/0x60 block/bio.c:1758
                    [<ffffffff818915fc>] dec_pending+0x21c/0x340 drivers/md/dm.c:1015
                    [<ffffffff818922a6>] clone_endio+0x76/0xe0 drivers/md/dm.c:1059
                    [<ffffffff81575907>] bio_endio+0x57/0x60 block/bio.c:1758
                    [<     inline     >] req_bio_endio block/blk-core.c:155
                    [<ffffffff8157f072>] blk_update_request+0xa2/0x3c0 block/blk-core.c:2644
                    [<ffffffff8158998a>] blk_mq_end_request+0x1a/0x70 block/blk-mq.c:320
                    [<ffffffff8177bcdf>] virtblk_request_done+0x3f/0x70 drivers/block/virtio_blk.c:131
                    [<     inline     >] blk_mq_ipi_complete_request block/blk-mq.c:354
                    [<ffffffff81589b48>] __blk_mq_complete_request+0x78/0xf0 block/blk-mq.c:366
                    [<ffffffff81589bdc>] blk_mq_complete_request+0x1c/0x20 block/blk-mq.c:385
                    [<ffffffff8177b543>] virtblk_done+0x73/0x100 drivers/block/virtio_blk.c:147
                    [<ffffffff816800ac>] vring_interrupt+0x3c/0x90 drivers/virtio/virtio_ring.c:892
                    [<ffffffff8111fa81>] handle_irq_event_percpu+0x41/0x330 kernel/irq/handle.c:145
                    [<ffffffff8111fda9>] handle_irq_event+0x39/0x60 kernel/irq/handle.c:192
                    [<ffffffff811232c4>] handle_edge_irq+0x74/0x130 kernel/irq/chip.c:623
                    [<     inline     >] generic_handle_irq_desc include/linux/irqdesc.h:147
                    [<ffffffff81036103>] handle_irq+0x73/0x120 arch/x86/kernel/irq_64.c:78
                    [<ffffffff81ad2f81>] do_IRQ+0x61/0x120 arch/x86/kernel/irq.c:240
                    [<ffffffff81ad0e16>] ret_from_intr+0x0/0x20 arch/x86/entry/entry_64.S:482
                    [<     inline     >] invoke_softirq kernel/softirq.c:350
                    [<ffffffff810b6dff>] irq_exit+0x10f/0x120 kernel/softirq.c:391
                    [<     inline     >] exiting_irq ./arch/x86/include/asm/apic.h:658
                    [<ffffffff81ad3082>] smp_apic_timer_interrupt+0x42/0x50 arch/x86/kernel/apic/apic.c:932
                    [<ffffffff81ad11a6>] apic_timer_interrupt+0x96/0xa0 arch/x86/entry/entry_64.S:618
                    [<     inline     >] rcu_lock_acquire include/linux/rcupdate.h:486
                    [<     inline     >] rcu_read_lock_sched include/linux/rcupdate.h:971
                    [<     inline     >] percpu_ref_get_many include/linux/percpu-refcount.h:174
                    [<     inline     >] percpu_ref_get include/linux/percpu-refcount.h:194
                    [<     inline     >] blk_queue_enter_live block/blk.h:85
                    [<ffffffff8158b06a>] blk_mq_map_request+0x5a/0x440 block/blk-mq.c:1175
                    [<ffffffff8158c275>] blk_sq_make_request+0xa5/0x500 block/blk-mq.c:1364
                    [<ffffffff8157e816>] generic_make_request+0xf6/0x2a0 block/blk-core.c:2076
                    [<ffffffff8157ea36>] submit_bio+0x76/0x170 block/blk-core.c:2139
                    [<ffffffff8132d25f>] ext4_io_submit+0x2f/0x40 fs/ext4/page-io.c:345
                    [<     inline     >] io_submit_add_bh fs/ext4/page-io.c:385
                    [<ffffffff8132d428>] ext4_bio_write_page+0x198/0x3c0 fs/ext4/page-io.c:495
                    [<ffffffff8132205d>] mpage_submit_page+0x5d/0x80 fs/ext4/inode.c:2091
                    [<ffffffff8132217b>] mpage_process_page_bufs+0xfb/0x110 fs/ext4/inode.c:2196
                    [<ffffffff81323662>] mpage_prepare_extent_to_map+0x202/0x300 fs/ext4/inode.c:2575
                    [<ffffffff81327988>] ext4_writepages+0x618/0x1020 fs/ext4/inode.c:2736
                    [<ffffffff811f2661>] do_writepages+0x21/0x30 mm/page-writeback.c:2364
                    [<ffffffff811e12a6>] __filemap_fdatawrite_range+0xc6/0x100 mm/filemap.c:300
                    [<ffffffff811e1424>] filemap_write_and_wait_range+0x44/0x90 mm/filemap.c:490
                    [<ffffffff8131dc1e>] ext4_sync_file+0x9e/0x4a0 fs/ext4/fsync.c:115
                    [<ffffffff812b545b>] vfs_fsync_range+0x4b/0xb0 fs/sync.c:195
                    [<     inline     >] vfs_fsync fs/sync.c:209
                    [<ffffffff812b551d>] do_fsync+0x3d/0x70 fs/sync.c:219
                    [<     inline     >] SYSC_fsync fs/sync.c:227
                    [<ffffffff812b57d0>] SyS_fsync+0x10/0x20 fs/sync.c:225
                    [<ffffffff81003fa7>] do_syscall_64+0x67/0x190 arch/x86/entry/common.c:350
                    [<ffffffff81ad053f>] return_from_SYSCALL_64+0x0/0x7a arch/x86/entry/entry_64.S:248
   INITIAL USE at:
                   [<ffffffff81109daf>] __lock_acquire+0x27f/0x14b0 kernel/locking/lockdep.c:3291
                   [<ffffffff8110b490>] lock_acquire+0xf0/0x1d0 kernel/locking/lockdep.c:3741
                   [<     inline     >] __raw_spin_lock_irq include/linux/spinlock_api_smp.h:130
                   [<ffffffff81acfa03>] _raw_spin_lock_irq+0x43/0x80 kernel/locking/spinlock.c:167
                   [<     inline     >] spin_lock_irq include/linux/spinlock.h:332
                   [<ffffffff811dfb9e>] __add_to_page_cache_locked+0x13e/0x500 mm/filemap.c:653
                   [<ffffffff811dffce>] add_to_page_cache_lru+0x4e/0xe0 mm/filemap.c:702
                   [<ffffffff811e012e>] pagecache_get_page+0xce/0x300 mm/filemap.c:1208
                   [<ffffffff811e0389>] grab_cache_page_write_begin+0x29/0x40 mm/filemap.c:2581
                   [<ffffffff812a7ee8>] simple_write_begin+0x28/0x1b0 fs/libfs.c:428
                   [<ffffffff811dd80f>] pagecache_write_begin+0x1f/0x30 mm/filemap.c:2484
                   [<ffffffff81284220>] __page_symlink+0xc0/0x100 fs/namei.c:4720
                   [<ffffffff81284282>] page_symlink+0x22/0x30 fs/namei.c:4743
                   [<ffffffff8138e71a>] ramfs_symlink+0x4a/0xc0 fs/ramfs/inode.c:129
                   [<ffffffff812859bc>] vfs_symlink+0xac/0x110 fs/namei.c:4071
                   [<     inline     >] SYSC_symlinkat fs/namei.c:4098
                   [<     inline     >] SyS_symlinkat fs/namei.c:4078
                   [<     inline     >] SYSC_symlink fs/namei.c:4111
                   [<ffffffff8128bbc0>] SyS_symlink+0x80/0xf0 fs/namei.c:4109
                   [<ffffffff825b4e53>] do_symlink+0x4d/0x90 init/initramfs.c:393
                   [<ffffffff825b4c5f>] write_buffer+0x23/0x34 init/initramfs.c:417
                   [<ffffffff825b4c9b>] flush_buffer+0x2b/0x85 init/initramfs.c:429
                   [<ffffffff825ff590>] __gunzip+0x27e/0x322 lib/decompress_inflate.c:147
                   [<ffffffff825ff645>] gunzip+0x11/0x13 lib/decompress_inflate.c:193
                   [<ffffffff825b560b>] unpack_to_rootfs+0x17e/0x294 init/initramfs.c:485
                   [<ffffffff825b58f7>] populate_rootfs+0x5c/0xfc init/initramfs.c:617
                   [<ffffffff81002190>] do_one_initcall+0x50/0x190 init/main.c:772
                   [<     inline     >] do_initcall_level init/main.c:837
                   [<     inline     >] do_initcalls init/main.c:845
                   [<     inline     >] do_basic_setup init/main.c:863
                   [<ffffffff825b320f>] kernel_init_freeable+0x1f6/0x290 init/main.c:1010
                   [<ffffffff81ac0f1e>] kernel_init+0xe/0x100 init/main.c:936
                   [<ffffffff81ad06af>] ret_from_fork+0x1f/0x40 arch/x86/entry/entry_64.S:389
 }
 ... key      at: [<ffffffff8355c9a0>] __key.44708+0x0/0x8 ??:?
 ... acquired at:
   [<ffffffff81108bcb>] check_irq_usage+0x4b/0xb0 kernel/locking/lockdep.c:1620
   [<     inline     >] check_prev_add_irq kernel/locking/lockdep_states.h:7
   [<     inline     >] check_prev_add kernel/locking/lockdep.c:1828
   [<     inline     >] check_prevs_add kernel/locking/lockdep.c:1934
   [<     inline     >] validate_chain kernel/locking/lockdep.c:2261
   [<ffffffff8110a972>] __lock_acquire+0xe42/0x14b0 kernel/locking/lockdep.c:3330
   [<ffffffff8110b490>] lock_acquire+0xf0/0x1d0 kernel/locking/lockdep.c:3741
   [<     inline     >] __raw_spin_lock include/linux/spinlock_api_smp.h:144
   [<ffffffff81acf796>] _raw_spin_lock+0x36/0x70 kernel/locking/spinlock.c:151
   [<     inline     >] spin_lock include/linux/spinlock.h:302
   [<ffffffff8121c0b7>] finish_mkwrite_fault+0xa7/0x120 mm/memory.c:2286
   [<ffffffff812d50b5>] dax_pfn_mkwrite+0x65/0x90 fs/dax.c:1290
   [<ffffffff8131cd4b>] ext4_dax_pfn_mkwrite+0x9b/0xa0 fs/ext4/file.c:278
   [<     inline     >] wp_pfn_shared mm/memory.c:2317
   [<ffffffff8121c643>] do_wp_page+0x513/0x760 mm/memory.c:2403
   [<     inline     >] handle_pte_fault mm/memory.c:3397
   [<     inline     >] __handle_mm_fault mm/memory.c:3505
   [<ffffffff8121e102>] handle_mm_fault+0x1012/0x1d60 mm/memory.c:3534
   [<ffffffff81070b5e>] __do_page_fault+0x1de/0x4c0 arch/x86/mm/fault.c:1356
   [<ffffffff81070f1c>] trace_do_page_fault+0x5c/0x280 arch/x86/mm/fault.c:1449
   [<ffffffff8106af7a>] do_async_page_fault+0x1a/0xa0 arch/x86/kernel/kvm.c:265
   [<ffffffff81ad2708>] async_page_fault+0x28/0x30 arch/x86/entry/entry_64.S:923


the dependencies between the lock to be acquired and HARDIRQ-irq-unsafe lock:
-> (&(ptlock_ptr(page))->rlock#2){+.+...} ops: 921722 {
   HARDIRQ-ON-W at:
                    [<     inline     >] mark_irqflags kernel/locking/lockdep.c:2929
                    [<ffffffff8110a0f1>] __lock_acquire+0x5c1/0x14b0 kernel/locking/lockdep.c:3287
                    [<ffffffff8110b490>] lock_acquire+0xf0/0x1d0 kernel/locking/lockdep.c:3741
                    [<     inline     >] __raw_spin_lock include/linux/spinlock_api_smp.h:144
                    [<ffffffff81acf796>] _raw_spin_lock+0x36/0x70 kernel/locking/spinlock.c:151
                    [<     inline     >] spin_lock include/linux/spinlock.h:302
                    [<     inline     >] do_anonymous_page mm/memory.c:2823
                    [<     inline     >] handle_pte_fault mm/memory.c:3378
                    [<     inline     >] __handle_mm_fault mm/memory.c:3505
                    [<ffffffff8121ea5c>] handle_mm_fault+0x196c/0x1d60 mm/memory.c:3534
                    [<     inline     >] faultin_page mm/gup.c:378
                    [<ffffffff8121829a>] __get_user_pages+0x18a/0x760 mm/gup.c:577
                    [<     inline     >] __get_user_pages_locked mm/gup.c:754
                    [<ffffffff81218c84>] get_user_pages_remote+0x54/0x60 mm/gup.c:962
                    [<     inline     >] get_arg_page fs/exec.c:206
                    [<ffffffff81280bcf>] copy_strings.isra.21+0x15f/0x3e0 fs/exec.c:521
                    [<ffffffff81280e84>] copy_strings_kernel+0x34/0x40 fs/exec.c:566
                    [<ffffffff812815fa>] do_execveat_common.isra.36+0x57a/0x970 fs/exec.c:1690
                    [<ffffffff81281a1c>] do_execve+0x2c/0x30 fs/exec.c:1747
                    [<ffffffff810c9f80>] call_usermodehelper_exec_async+0xf0/0x140 kernel/kmod.c:252
                    [<ffffffff81ad06af>] ret_from_fork+0x1f/0x40 arch/x86/entry/entry_64.S:389
   SOFTIRQ-ON-W at:
                    [<     inline     >] mark_irqflags kernel/locking/lockdep.c:2933
                    [<ffffffff8110a11f>] __lock_acquire+0x5ef/0x14b0 kernel/locking/lockdep.c:3287
                    [<ffffffff8110b490>] lock_acquire+0xf0/0x1d0 kernel/locking/lockdep.c:3741
                    [<     inline     >] __raw_spin_lock include/linux/spinlock_api_smp.h:144
                    [<ffffffff81acf796>] _raw_spin_lock+0x36/0x70 kernel/locking/spinlock.c:151
                    [<     inline     >] spin_lock include/linux/spinlock.h:302
                    [<     inline     >] do_anonymous_page mm/memory.c:2823
                    [<     inline     >] handle_pte_fault mm/memory.c:3378
                    [<     inline     >] __handle_mm_fault mm/memory.c:3505
                    [<ffffffff8121ea5c>] handle_mm_fault+0x196c/0x1d60 mm/memory.c:3534
                    [<     inline     >] faultin_page mm/gup.c:378
                    [<ffffffff8121829a>] __get_user_pages+0x18a/0x760 mm/gup.c:577
                    [<     inline     >] __get_user_pages_locked mm/gup.c:754
                    [<ffffffff81218c84>] get_user_pages_remote+0x54/0x60 mm/gup.c:962
                    [<     inline     >] get_arg_page fs/exec.c:206
                    [<ffffffff81280bcf>] copy_strings.isra.21+0x15f/0x3e0 fs/exec.c:521
                    [<ffffffff81280e84>] copy_strings_kernel+0x34/0x40 fs/exec.c:566
                    [<ffffffff812815fa>] do_execveat_common.isra.36+0x57a/0x970 fs/exec.c:1690
                    [<ffffffff81281a1c>] do_execve+0x2c/0x30 fs/exec.c:1747
                    [<ffffffff810c9f80>] call_usermodehelper_exec_async+0xf0/0x140 kernel/kmod.c:252
                    [<ffffffff81ad06af>] ret_from_fork+0x1f/0x40 arch/x86/entry/entry_64.S:389
   INITIAL USE at:
                   [<ffffffff81109daf>] __lock_acquire+0x27f/0x14b0 kernel/locking/lockdep.c:3291
                   [<ffffffff8110b490>] lock_acquire+0xf0/0x1d0 kernel/locking/lockdep.c:3741
                   [<     inline     >] __raw_spin_lock include/linux/spinlock_api_smp.h:144
                   [<ffffffff81acf796>] _raw_spin_lock+0x36/0x70 kernel/locking/spinlock.c:151
                   [<     inline     >] spin_lock include/linux/spinlock.h:302
                   [<     inline     >] do_anonymous_page mm/memory.c:2823
                   [<     inline     >] handle_pte_fault mm/memory.c:3378
                   [<     inline     >] __handle_mm_fault mm/memory.c:3505
                   [<ffffffff8121ea5c>] handle_mm_fault+0x196c/0x1d60 mm/memory.c:3534
                   [<     inline     >] faultin_page mm/gup.c:378
                   [<ffffffff8121829a>] __get_user_pages+0x18a/0x760 mm/gup.c:577
                   [<     inline     >] __get_user_pages_locked mm/gup.c:754
                   [<ffffffff81218c84>] get_user_pages_remote+0x54/0x60 mm/gup.c:962
                   [<     inline     >] get_arg_page fs/exec.c:206
                   [<ffffffff81280bcf>] copy_strings.isra.21+0x15f/0x3e0 fs/exec.c:521
                   [<ffffffff81280e84>] copy_strings_kernel+0x34/0x40 fs/exec.c:566
                   [<ffffffff812815fa>] do_execveat_common.isra.36+0x57a/0x970 fs/exec.c:1690
                   [<ffffffff81281a1c>] do_execve+0x2c/0x30 fs/exec.c:1747
                   [<ffffffff810c9f80>] call_usermodehelper_exec_async+0xf0/0x140 kernel/kmod.c:252
                   [<ffffffff81ad06af>] ret_from_fork+0x1f/0x40 arch/x86/entry/entry_64.S:389
 }
 ... key      at: [<ffffffff8279cc18>] __key.17932+0x0/0x8 ??:?
 ... acquired at:
   [<ffffffff81108bcb>] check_irq_usage+0x4b/0xb0 kernel/locking/lockdep.c:1620
   [<     inline     >] check_prev_add_irq kernel/locking/lockdep_states.h:7
   [<     inline     >] check_prev_add kernel/locking/lockdep.c:1828
   [<     inline     >] check_prevs_add kernel/locking/lockdep.c:1934
   [<     inline     >] validate_chain kernel/locking/lockdep.c:2261
   [<ffffffff8110a972>] __lock_acquire+0xe42/0x14b0 kernel/locking/lockdep.c:3330
   [<ffffffff8110b490>] lock_acquire+0xf0/0x1d0 kernel/locking/lockdep.c:3741
   [<     inline     >] __raw_spin_lock include/linux/spinlock_api_smp.h:144
   [<ffffffff81acf796>] _raw_spin_lock+0x36/0x70 kernel/locking/spinlock.c:151
   [<     inline     >] spin_lock include/linux/spinlock.h:302
   [<ffffffff8121c0b7>] finish_mkwrite_fault+0xa7/0x120 mm/memory.c:2286
   [<ffffffff812d50b5>] dax_pfn_mkwrite+0x65/0x90 fs/dax.c:1290
   [<ffffffff8131cd4b>] ext4_dax_pfn_mkwrite+0x9b/0xa0 fs/ext4/file.c:278
   [<     inline     >] wp_pfn_shared mm/memory.c:2317
   [<ffffffff8121c643>] do_wp_page+0x513/0x760 mm/memory.c:2403
   [<     inline     >] handle_pte_fault mm/memory.c:3397
   [<     inline     >] __handle_mm_fault mm/memory.c:3505
   [<ffffffff8121e102>] handle_mm_fault+0x1012/0x1d60 mm/memory.c:3534
   [<ffffffff81070b5e>] __do_page_fault+0x1de/0x4c0 arch/x86/mm/fault.c:1356
   [<ffffffff81070f1c>] trace_do_page_fault+0x5c/0x280 arch/x86/mm/fault.c:1449
   [<ffffffff8106af7a>] do_async_page_fault+0x1a/0xa0 arch/x86/kernel/kvm.c:265
   [<ffffffff81ad2708>] async_page_fault+0x28/0x30 arch/x86/entry/entry_64.S:923


stack backtrace:
CPU: 0 PID: 1856 Comm: fstest Not tainted 4.7.0+ #1
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.9.1-0-gb3ef39f-prebuilt.qemu-project.org 04/01/2014
 0000000000000086 0000000070a78a50 ffff8800a768f9a8 ffffffff815b20a3
 ffffffff82ec47f0 0000000000000030 ffff8800a768fac0 ffffffff81108b29
 0000000000000000 0000000000000000 0000000000000001 000000000d3ea148
Call Trace:
 [<     inline     >] __dump_stack lib/dump_stack.c:15
 [<ffffffff815b20a3>] dump_stack+0x85/0xc2 lib/dump_stack.c:51
 [<     inline     >] print_bad_irq_dependency kernel/locking/lockdep.c:1532
 [<ffffffff81108b29>] check_usage+0x539/0x590 kernel/locking/lockdep.c:1564
 [<ffffffff81108bcb>] check_irq_usage+0x4b/0xb0 kernel/locking/lockdep.c:1620
 [<     inline     >] check_prev_add_irq kernel/locking/lockdep_states.h:7
 [<     inline     >] check_prev_add kernel/locking/lockdep.c:1828
 [<     inline     >] check_prevs_add kernel/locking/lockdep.c:1934
 [<     inline     >] validate_chain kernel/locking/lockdep.c:2261
 [<ffffffff8110a972>] __lock_acquire+0xe42/0x14b0 kernel/locking/lockdep.c:3330
 [<ffffffff8110b490>] lock_acquire+0xf0/0x1d0 kernel/locking/lockdep.c:3741
 [<     inline     >] __raw_spin_lock include/linux/spinlock_api_smp.h:144
 [<ffffffff81acf796>] _raw_spin_lock+0x36/0x70 kernel/locking/spinlock.c:151
 [<     inline     >] spin_lock include/linux/spinlock.h:302
 [<ffffffff8121c0b7>] finish_mkwrite_fault+0xa7/0x120 mm/memory.c:2286
 [<ffffffff812d50b5>] dax_pfn_mkwrite+0x65/0x90 fs/dax.c:1290
 [<ffffffff8131cd4b>] ext4_dax_pfn_mkwrite+0x9b/0xa0 fs/ext4/file.c:278
 [<     inline     >] wp_pfn_shared mm/memory.c:2317
 [<ffffffff8121c643>] do_wp_page+0x513/0x760 mm/memory.c:2403
 [<     inline     >] handle_pte_fault mm/memory.c:3397
 [<     inline     >] __handle_mm_fault mm/memory.c:3505
 [<ffffffff8121e102>] handle_mm_fault+0x1012/0x1d60 mm/memory.c:3534
 [<ffffffff81070b5e>] __do_page_fault+0x1de/0x4c0 arch/x86/mm/fault.c:1356
 [<ffffffff81070f1c>] trace_do_page_fault+0x5c/0x280 arch/x86/mm/fault.c:1449
 [<ffffffff8106af7a>] do_async_page_fault+0x1a/0xa0 arch/x86/kernel/kvm.c:265
 [<ffffffff81ad2708>] async_page_fault+0x28/0x30 arch/x86/entry/entry_64.S:923

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
