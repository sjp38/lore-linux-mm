Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 4F6226B005D
	for <linux-mm@kvack.org>; Sat, 15 Sep 2012 10:01:49 -0400 (EDT)
Received: by eaaf11 with SMTP id f11so2233212eaa.14
        for <linux-mm@kvack.org>; Sat, 15 Sep 2012 07:01:47 -0700 (PDT)
Message-ID: <50548A62.5000005@gmail.com>
Date: Sat, 15 Sep 2012 16:02:10 +0200
From: Sasha Levin <levinsasha928@gmail.com>
MIME-Version: 1.0
Subject: Re: blk, mm: lockdep irq lock inversion in linux-next
References: <5054878F.1030908@gmail.com>
In-Reply-To: <5054878F.1030908@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>

On 09/15/2012 03:50 PM, Sasha Levin wrote:
> Hi all,
> 
> While fuzzing with trinity within a KVM tools guest on a linux-next kernel, I
> got the lockdep warning at the bottom of this mail.
> 
> I've tried figuring out where it was introduced, but haven't found any sign that
> any of the code in that area changed recently, so I'm probably missing something...
> 
> 
> [ 157.966399] =========================================================
> [ 157.968523] [ INFO: possible irq lock inversion dependency detected ]
> [ 157.970029] 3.6.0-rc5-next-20120914-sasha-00001-g802bf6c-dirty #340 Tainted: G W
> [ 157.970029] ---------------------------------------------------------
> [ 157.970029] trinity-child38/6642 just changed the state of lock:
> [ 157.970029] (&(&mapping->tree_lock)->rlock){+.+...}, at: [<ffffffff8120cafc>]
> invalidate_inode_pages2_range+0x20c/0x3c0
> [ 157.970029] but this lock was taken by another, SOFTIRQ-safe lock in the past:
> [ 157.970029] (&(&new->queue_lock)->rlock){..-...}
> 
> and interrupts could create inverse lock ordering between them.
> 
> [ 157.970029]
> [ 157.970029] other info that might help us debug this:
> [ 157.970029] Possible interrupt unsafe locking scenario:
> [ 157.970029]
> [ 157.970029] CPU0 CPU1
> [ 157.970029] ---- ----
> [ 157.970029] lock(&(&mapping->tree_lock)->rlock);
> [ 157.970029] local_irq_disable();
> [ 157.970029] lock(&(&new->queue_lock)->rlock);
> [ 157.970029] lock(&(&mapping->tree_lock)->rlock);
> [ 157.970029] <Interrupt>
> [ 157.970029] lock(&(&new->queue_lock)->rlock);
> [ 157.970029]
> [ 157.970029] *** DEADLOCK ***
> [ 157.970029]
> [ 157.970029] 1 lock held by trinity-child38/6642:
> [ 157.970029] #0: (&(&mapping->tree_lock)->rlock){+.+...}, at:
> [<ffffffff8120cafc>] invalidate_inode_pages2_range+0x20c/0x3c0
> [ 157.970029]
> [ 157.970029] the shortest dependencies between 2nd lock and 1st lock:
> [ 157.970029] -> (&(&new->queue_lock)->rlock){..-...} ops: 4790 {
> [ 157.970029] IN-SOFTIRQ-W at:
> [ 157.970029] [<ffffffff8117bf2a>] __lock_acquire+0x87a/0x1bd0
> [ 157.970029] [<ffffffff8117f87a>] lock_acquire+0x1aa/0x240
> [ 157.970029] [<ffffffff8375f6cc>] _raw_spin_lock_irqsave+0x7c/0xc0
> [ 157.970029] [<ffffffff819b7239>] cfq_idle_slice_timer+0x19/0xd0
> [ 157.970029] [<ffffffff81119f66>] call_timer_fn+0x166/0x380
> [ 157.970029] [<ffffffff8111a46c>] run_timer_softirq+0x2ec/0x380
> [ 157.970029] [<ffffffff81110b27>] __do_softirq+0x1c7/0x440
> [ 157.970029] [<ffffffff8376256c>] call_softirq+0x1c/0x30
> [ 157.970029] [<ffffffff8106f51d>] do_softirq+0x6d/0x100
> [ 157.970029] [<ffffffff81110f1a>] irq_exit+0x5a/0xd0
> [ 157.970029] [<ffffffff8109674a>] smp_apic_timer_interrupt+0x8a/0xa0
> [ 157.970029] [<ffffffff83761e6f>] apic_timer_interrupt+0x6f/0x80
> [ 157.970029] [<ffffffff810775b5>] default_idle+0x235/0x5b0
> [ 157.970029] [<ffffffff810785e8>] cpu_idle+0x138/0x160
> [ 157.970029] [<ffffffff836fbed7>] start_secondary+0x26e/0x276
> [ 157.970029] INITIAL USE at:
> [ 157.970029] [<ffffffff8117c07f>] __lock_acquire+0x9cf/0x1bd0
> [ 157.970029] [<ffffffff8117f87a>] lock_acquire+0x1aa/0x240
> [ 157.970029] [<ffffffff8375f767>] _raw_spin_lock_irq+0x57/0x90
> [ 157.970029] [<ffffffff819954e6>] blk_queue_bypass_start+0x16/0xa0
> [ 157.970029] [<ffffffff819af017>] blkcg_activate_policy+0x67/0x370
> [ 157.970029] [<ffffffff819b3d09>] cfq_init_queue+0x79/0x380
> [ 157.970029] [<ffffffff8198eeb3>] elevator_init+0xd3/0x140
> [ 157.970029] [<ffffffff81995ca2>] blk_init_allocated_queue+0xa2/0xd0
> [ 157.970029] [<ffffffff81995d0c>] blk_init_queue_node+0x3c/0x70
> [ 157.970029] [<ffffffff81995d4e>] blk_init_queue+0xe/0x10
> [ 157.970029] [<ffffffff8222a99f>] add_mtd_blktrans_dev+0x28f/0x410
> [ 157.970029] [<ffffffff8222b6d1>] mtdblock_add_mtd+0x81/0xa0
> [ 157.970029] [<ffffffff82229ea1>] blktrans_notify_add+0x31/0x50
> [ 157.970029] [<ffffffff82224047>] add_mtd_device+0x237/0x2e0
> [ 157.970029] [<ffffffff8222418c>] mtd_device_parse_register+0x9c/0xc0
> [ 157.970029] [<ffffffff8226ac04>] mtdram_init_device+0x114/0x120
> [ 157.970029] [<ffffffff85662443>] init_mtdram+0x81/0xfa
> [ 157.970029] [<ffffffff85600c9f>] do_one_initcall+0x7a/0x135
> [ 157.970029] [<ffffffff85600eb7>] kernel_init+0x15d/0x1e1
> [ 157.970029] [<ffffffff83762504>] kernel_thread_helper+0x4/0x10
> [ 157.970029] }
> [ 157.970029] ... key at: [<ffffffff865d3fac>] __key.29440+0x0/0x8
> [ 157.970029] ... acquired at:
> [ 157.970029] [<ffffffff8117f87a>] lock_acquire+0x1aa/0x240
> [ 157.970029] [<ffffffff8375f6cc>] _raw_spin_lock_irqsave+0x7c/0xc0
> [ 157.970029] [<ffffffff812095be>] test_clear_page_writeback+0x6e/0x1b0
> [ 157.970029] [<ffffffff811fbdc4>] end_page_writeback+0x24/0x50
> [ 157.970029] [<ffffffff812a4372>] end_buffer_async_write+0x222/0x2f0
> [ 157.970029] [<ffffffff812a36cd>] end_bio_bh_io_sync+0x3d/0x50
> [ 157.970029] [<ffffffff812a8dfd>] bio_endio+0x2d/0x30
> [ 157.970029] [<ffffffff819921f5>] req_bio_endio.isra.36+0xb5/0xd0
> [ 157.970029] [<ffffffff819976ac>] blk_update_request+0x33c/0x600
> [ 157.970029] [<ffffffff81997992>] blk_update_bidi_request+0x22/0x90
> [ 157.970029] [<ffffffff81997abb>] __blk_end_bidi_request+0x1b/0x40
> [ 157.970029] [<ffffffff81997bcb>] __blk_end_request+0xb/0x10
> [ 157.970029] [<ffffffff81997fbd>] __blk_end_request_cur+0x3d/0x40
> [ 157.970029] [<ffffffff8222a234>] mtd_blktrans_thread+0x2c4/0x340
> [ 157.970029] [<ffffffff81135e13>] kthread+0xe3/0xf0
> [ 157.970029] [<ffffffff83762504>] kernel_thread_helper+0x4/0x10
> [ 157.970029]
> [ 157.970029] -> (&(&mapping->tree_lock)->rlock){+.+...} ops: 63737 {
> [ 157.970029] HARDIRQ-ON-W at:
> [ 157.970029] [<ffffffff8117a353>] mark_held_locks+0x113/0x130
> [ 157.970029] [<ffffffff8117a567>] trace_hardirqs_on_caller+0x1f7/0x230
> [ 157.970029] [<ffffffff8117a5ad>] trace_hardirqs_on+0xd/0x10
> [ 157.970029] [<ffffffff8375f95b>] _raw_spin_unlock_irq+0x2b/0x80
> [ 157.970029] [<ffffffff8121076d>] isolate_lru_page+0x15d/0x180
> [ 157.970029] [<ffffffff8122d39a>] __clear_page_mlock+0x3a/0x70
> [ 157.970029] [<ffffffff8120cb35>] invalidate_inode_pages2_range+0x245/0x3c0
> [ 157.970029] [<ffffffff811fe1f7>] generic_file_direct_write+0xc7/0x180
> [ 157.970029] [<ffffffff811fe8c9>] __generic_file_aio_write+0x249/0x3a0
> [ 157.970029] [<ffffffff812aabc1>] blkdev_aio_write+0x51/0xb0
> [ 157.970029] [<ffffffff81270468>] do_sync_write+0x98/0xf0
> [ 157.970029] [<ffffffff81270570>] vfs_write+0xb0/0x180
> [ 157.970029] [<ffffffff81270718>] sys_write+0x48/0x90
> [ 157.970029] [<ffffffff83761368>] tracesys+0xe1/0xe6
> [ 157.970029] SOFTIRQ-ON-W at:
> [ 157.970029] [<ffffffff8117a353>] mark_held_locks+0x113/0x130
> [ 157.970029] [<ffffffff8117a4d5>] trace_hardirqs_on_caller+0x165/0x230
> [ 157.970029] [<ffffffff8117a5ad>] trace_hardirqs_on+0xd/0x10
> [ 157.970029] [<ffffffff8375f95b>] _raw_spin_unlock_irq+0x2b/0x80
> [ 157.970029] [<ffffffff8121076d>] isolate_lru_page+0x15d/0x180
> [ 157.970029] [<ffffffff8122d39a>] __clear_page_mlock+0x3a/0x70
> [ 157.970029] [<ffffffff8120cb35>] invalidate_inode_pages2_range+0x245/0x3c0
> [ 157.970029] [<ffffffff811fe1f7>] generic_file_direct_write+0xc7/0x180
> [ 157.970029] [<ffffffff811fe8c9>] __generic_file_aio_write+0x249/0x3a0
> [ 157.970029] [<ffffffff812aabc1>] blkdev_aio_write+0x51/0xb0
> [ 157.970029] [<ffffffff81270468>] do_sync_write+0x98/0xf0
> [ 157.970029] [<ffffffff81270570>] vfs_write+0xb0/0x180
> [ 157.970029] [<ffffffff81270718>] sys_write+0x48/0x90
> [ 157.970029] [<ffffffff83761368>] tracesys+0xe1/0xe6
> [ 157.970029] INITIAL USE at:
> [ 157.970029] [<ffffffff8117c07f>] __lock_acquire+0x9cf/0x1bd0
> [ 157.970029] [<ffffffff8117f87a>] lock_acquire+0x1aa/0x240
> [ 157.970029] [<ffffffff8375f767>] _raw_spin_lock_irq+0x57/0x90
> [ 157.970029] [<ffffffff8128c06c>] clear_inode+0x2c/0x90
> [ 157.970029] [<ffffffff81219629>] shmem_evict_inode+0x129/0x140
> [ 157.970029] [<ffffffff8128c179>] evict+0xa9/0x170
> [ 157.970029] [<ffffffff8128d04f>] iput+0x1cf/0x1f0
> [ 157.970029] [<ffffffff81289da0>] d_delete+0x150/0x1b0
> [ 157.970029] [<ffffffff812804c1>] vfs_unlink+0xe1/0x120
> [ 157.970029] [<ffffffff81e08814>] handle_remove+0x244/0x270
> [ 157.970029] [<ffffffff81e08b65>] devtmpfsd+0x125/0x170
> [ 157.970029] [<ffffffff81135e13>] kthread+0xe3/0xf0
> [ 157.970029] [<ffffffff83762504>] kernel_thread_helper+0x4/0x10
> [ 157.970029] }
> [ 157.970029] ... key at: [<ffffffff86226a60>] __key.30203+0x0/0x8
> [ 157.970029] ... acquired at:
> [ 157.970029] [<ffffffff811796be>] check_usage_backwards+0xce/0xe0
> [ 157.970029] [<ffffffff8117a0ad>] mark_lock+0x15d/0x2f0
> [ 157.970029] [<ffffffff8117a353>] mark_held_locks+0x113/0x130
> [ 157.970029] [<ffffffff8117a4d5>] trace_hardirqs_on_caller+0x165/0x230
> [ 157.970029] [<ffffffff8117a5ad>] trace_hardirqs_on+0xd/0x10
> [ 157.970029] [<ffffffff8375f95b>] _raw_spin_unlock_irq+0x2b/0x80
> [ 157.970029] [<ffffffff8121076d>] isolate_lru_page+0x15d/0x180
> [ 157.970029] [<ffffffff8122d39a>] __clear_page_mlock+0x3a/0x70
> [ 157.970029] [<ffffffff8120cb35>] invalidate_inode_pages2_range+0x245/0x3c0
> [ 157.970029] [<ffffffff811fe1f7>] generic_file_direct_write+0xc7/0x180
> [ 157.970029] [<ffffffff811fe8c9>] __generic_file_aio_write+0x249/0x3a0
> [ 157.970029] [<ffffffff812aabc1>] blkdev_aio_write+0x51/0xb0
> [ 157.970029] [<ffffffff81270468>] do_sync_write+0x98/0xf0
> [ 157.970029] [<ffffffff81270570>] vfs_write+0xb0/0x180
> [ 157.970029] [<ffffffff81270718>] sys_write+0x48/0x90
> [ 157.970029] [<ffffffff83761368>] tracesys+0xe1/0xe6
> [ 157.970029]
> [ 157.970029]
> [ 157.970029] stack backtrace:
> [ 157.970029] Pid: 6642, comm: trinity-child38 Tainted: G W
> 3.6.0-rc5-next-20120914-sasha-00001-g802bf6c-dirty #340
> [ 157.970029] Call Trace:
> [ 157.970029] [<ffffffff811794e1>] print_irq_inversion_bug+0x201/0x220
> [ 157.970029] [<ffffffff811796be>] check_usage_backwards+0xce/0xe0
> [ 157.970029] [<ffffffff811795f0>] ? check_usage_forwards+0xf0/0xf0
> [ 157.970029] [<ffffffff8117a0ad>] mark_lock+0x15d/0x2f0
> [ 157.970029] [<ffffffff8117a353>] mark_held_locks+0x113/0x130
> [ 157.970029] [<ffffffff81177a9e>] ? put_lock_stats.isra.16+0xe/0x40
> [ 157.970029] [<ffffffff8375f95b>] ? _raw_spin_unlock_irq+0x2b/0x80
> [ 157.970029] [<ffffffff8117a4d5>] trace_hardirqs_on_caller+0x165/0x230
> [ 157.970029] [<ffffffff8117a5ad>] trace_hardirqs_on+0xd/0x10
> [ 157.970029] [<ffffffff8375f95b>] _raw_spin_unlock_irq+0x2b/0x80
> [ 157.970029] [<ffffffff8121076d>] isolate_lru_page+0x15d/0x180
> [ 157.970029] [<ffffffff8122d39a>] __clear_page_mlock+0x3a/0x70
> [ 157.970029] [<ffffffff8120cb35>] invalidate_inode_pages2_range+0x245/0x3c0
> [ 157.970029] [<ffffffff8120951c>] ? do_writepages+0x1c/0x50
> [ 157.970029] [<ffffffff811fb4c9>] ? __filemap_fdatawrite_range+0x49/0x50
> [ 157.970029] [<ffffffff811fe1f7>] generic_file_direct_write+0xc7/0x180
> [ 157.970029] [<ffffffff811fe8c9>] __generic_file_aio_write+0x249/0x3a0
> [ 157.970029] [<ffffffff81177a12>] ? get_lock_stats+0x22/0x70
> [ 157.970029] [<ffffffff812aabc1>] blkdev_aio_write+0x51/0xb0
> [ 157.970029] [<ffffffff8111b603>] ? del_timer+0x63/0x80
> [ 157.970029] [<ffffffff81270468>] do_sync_write+0x98/0xf0
> [ 157.970029] [<ffffffff81270570>] vfs_write+0xb0/0x180
> [ 157.970029] [<ffffffff81270718>] sys_write+0x48/0x90
> [ 157.970029] [<ffffffff83761368>] tracesys+0xe1/0xe6
> 

Just got another related warning:

[ 197.827054] =================================
[ 197.828667] [ INFO: inconsistent lock state ]
[ 197.830035] 3.6.0-rc5-next-20120914-sasha-00001-g802bf6c-dirty #340 Tainted: G W
[ 197.830035] ---------------------------------
[ 197.830035] inconsistent {IN-SOFTIRQ-W} -> {SOFTIRQ-ON-W} usage.
[ 197.830035] trinity-child18/8192 [HC0[0]:SC0[0]:HE1:SE1] takes:
[ 197.830035] (&(&mapping->tree_lock)->rlock){+.?...}, at: [<ffffffff8120cafc>]
invalidate_inode_pages2_range+0x20c/0x3c0
[ 197.830035] {IN-SOFTIRQ-W} state was registered at:
[ 197.830035] [<ffffffff8117bf2a>] __lock_acquire+0x87a/0x1bd0
[ 197.830035] [<ffffffff8117f87a>] lock_acquire+0x1aa/0x240
[ 197.830035] [<ffffffff8375f6cc>] _raw_spin_lock_irqsave+0x7c/0xc0
[ 197.830035] [<ffffffff812095be>] test_clear_page_writeback+0x6e/0x1b0
[ 197.830035] [<ffffffff811fbdc4>] end_page_writeback+0x24/0x50
[ 197.830035] [<ffffffff812a4372>] end_buffer_async_write+0x222/0x2f0
[ 197.830035] [<ffffffff812a36cd>] end_bio_bh_io_sync+0x3d/0x50
[ 197.830035] [<ffffffff812a8dfd>] bio_endio+0x2d/0x30
[ 197.830035] [<ffffffff819921f5>] req_bio_endio.isra.36+0xb5/0xd0
[ 197.830035] [<ffffffff819976ac>] blk_update_request+0x33c/0x600
[ 197.830035] [<ffffffff81997992>] blk_update_bidi_request+0x22/0x90
[ 197.830035] [<ffffffff81997a27>] blk_end_bidi_request+0x27/0x70
[ 197.830035] [<ffffffff81997aeb>] blk_end_request+0xb/0x10
[ 197.830035] [<ffffffff81ede493>] scsi_io_completion+0x263/0x6b0
[ 197.830035] [<ffffffff81ed7168>] scsi_finish_command+0x118/0x130
[ 197.830035] [<ffffffff81ede145>] scsi_softirq_done+0x135/0x150
[ 197.830035] [<ffffffff8199dd60>] blk_done_softirq+0xb0/0xd0
[ 197.830035] [<ffffffff81110b27>] __do_softirq+0x1c7/0x440
[ 197.830035] [<ffffffff8376256c>] call_softirq+0x1c/0x30
[ 197.830035] [<ffffffff8106f51d>] do_softirq+0x6d/0x100
[ 197.830035] [<ffffffff81110f1a>] irq_exit+0x5a/0xd0
[ 197.830035] [<ffffffff8109674a>] smp_apic_timer_interrupt+0x8a/0xa0
[ 197.830035] [<ffffffff83761e6f>] apic_timer_interrupt+0x6f/0x80
[ 197.830035] [<ffffffff810775b5>] default_idle+0x235/0x5b0
[ 197.830035] [<ffffffff810785e8>] cpu_idle+0x138/0x160
[ 197.830035] [<ffffffff836fbed7>] start_secondary+0x26e/0x276
[ 197.830035] irq event stamp: 178348
[ 197.830035] hardirqs last enabled at (178347): [<ffffffff8375f8dd>]
_raw_spin_unlock_irqrestore+0x5d/0xb0
[ 197.830035] hardirqs last disabled at (178348): [<ffffffff8375f73a>]
_raw_spin_lock_irq+0x2a/0x90
[ 197.830035] softirqs last enabled at (168698): [<ffffffff81110cd2>]
__do_softirq+0x372/0x440
[ 197.830035] softirqs last disabled at (168687): [<ffffffff8376256c>]
call_softirq+0x1c/0x30
[ 197.830035]
[ 197.830035] other info that might help us debug this:
[ 197.830035] Possible unsafe locking scenario:
[ 197.830035]
[ 197.830035] CPU0
[ 197.830035] ----
[ 197.830035] lock(&(&mapping->tree_lock)->rlock);
[ 197.830035] <Interrupt>
[ 197.830035] lock(&(&mapping->tree_lock)->rlock);
[ 197.830035]
[ 197.830035] *** DEADLOCK ***
[ 197.830035]
[ 197.830035] 1 lock held by trinity-child18/8192:
[ 197.830035] #0: (&(&mapping->tree_lock)->rlock){+.?...}, at:
[<ffffffff8120cafc>] invalidate_inode_pages2_range+0x20c/0x3c0
[ 197.830035]
[ 197.830035] stack backtrace:
[ 197.830035] Pid: 8192, comm: trinity-child18 Tainted: G W
3.6.0-rc5-next-20120914-sasha-00001-g802bf6c-dirty #340
[ 197.830035] Call Trace:
[ 197.830035] [<ffffffff8370a28a>] print_usage_bug+0x1f7/0x208
[ 197.830035] [<ffffffff8107d9ba>] ? save_stack_trace+0x2a/0x50
[ 197.830035] [<ffffffff811795f0>] ? check_usage_forwards+0xf0/0xf0
[ 197.830035] [<ffffffff8117a0c6>] mark_lock+0x176/0x2f0
[ 197.830035] [<ffffffff8117a353>] mark_held_locks+0x113/0x130
[ 197.830035] [<ffffffff81177a9e>] ? put_lock_stats.isra.16+0xe/0x40
[ 197.830035] [<ffffffff8375f95b>] ? _raw_spin_unlock_irq+0x2b/0x80
[ 197.830035] [<ffffffff8117a4d5>] trace_hardirqs_on_caller+0x165/0x230
[ 197.830035] [<ffffffff8117a5ad>] trace_hardirqs_on+0xd/0x10
[ 197.830035] [<ffffffff8375f95b>] _raw_spin_unlock_irq+0x2b/0x80
[ 197.830035] [<ffffffff8121076d>] isolate_lru_page+0x15d/0x180
[ 197.830035] [<ffffffff8122d39a>] __clear_page_mlock+0x3a/0x70
[ 197.830035] [<ffffffff8120cb35>] invalidate_inode_pages2_range+0x245/0x3c0
[ 197.830035] [<ffffffff8120951c>] ? do_writepages+0x1c/0x50
[ 197.830035] [<ffffffff811fb4c9>] ? __filemap_fdatawrite_range+0x49/0x50
[ 197.830035] [<ffffffff811fe1f7>] generic_file_direct_write+0xc7/0x180
[ 197.830035] [<ffffffff811fe8c9>] __generic_file_aio_write+0x249/0x3a0
[ 197.830035] [<ffffffff812aabc1>] blkdev_aio_write+0x51/0xb0
[ 197.830035] [<ffffffff812aab70>] ? block_llseek+0xc0/0xc0
[ 197.830035] [<ffffffff8127097c>] do_sync_readv_writev+0x8c/0xe0
[ 197.830035] [<ffffffff81270c79>] do_readv_writev+0xd9/0x1e0
[ 197.830035] [<ffffffff811c63d5>] ? rcu_user_exit+0xa5/0xd0
[ 197.830035] [<ffffffff81270e1a>] vfs_writev+0x3a/0x60
[ 197.830035] [<ffffffff81270f38>] sys_writev+0x48/0xb0
[ 197.830035] [<ffffffff83761368>] tracesys+0xe1/0xe6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
