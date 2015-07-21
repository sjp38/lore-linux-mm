Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id D13919003C7
	for <linux-mm@kvack.org>; Mon, 20 Jul 2015 21:59:39 -0400 (EDT)
Received: by pabkd10 with SMTP id kd10so38238217pab.2
        for <linux-mm@kvack.org>; Mon, 20 Jul 2015 18:59:39 -0700 (PDT)
Received: from ipmail05.adl6.internode.on.net (ipmail05.adl6.internode.on.net. [150.101.137.143])
        by mx.google.com with ESMTP id k1si39781384pdr.179.2015.07.20.18.59.36
        for <linux-mm@kvack.org>;
        Mon, 20 Jul 2015 18:59:38 -0700 (PDT)
Date: Tue, 21 Jul 2015 11:59:34 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: [regression 4.2-rc3] loop: xfstests xfs/073 deadlocked in low memory
 conditions
Message-ID: <20150721015934.GY7943@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@canonical.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com

Hi Ming,

With the recent merge of the loop device changes, I'm now seeing
XFS deadlock on my single CPU, 1GB RAM VM running xfs/073.

The deadlocked is as follows:

kloopd1: loop_queue_read_work
	xfs_file_iter_read
	lock XFS inode XFS_IOLOCK_SHARED (on image file)
	page cache read (GFP_KERNEL)
	radix tree alloc
	memory reclaim
	reclaim XFS inodes
	log force to unpin inodes
	<wait for log IO completion>

xfs-cil/loop1: <does log force IO work>
	xlog_cil_push
	xlog_write
	<loop issuing log writes>
		xlog_state_get_iclog_space()
		<blocks due to all log buffers under write io>
		<waits for IO completion>

kloopd1: loop_queue_write_work
	xfs_file_write_iter
	lock XFS inode XFS_IOLOCK_EXCL (on image file)
	<wait for inode to be unlocked>

[The full stack traces are below].

i.e. the kloopd, with it's split read and write work queues, has
introduced a dependency through memory reclaim. i.e. that writes
need to be able to progress for reads make progress.

The problem, fundamentally, is that mpage_readpages() does a
GFP_KERNEL allocation, rather than paying attention to the inode's
mapping gfp mask, which is set to GFP_NOFS.

The didn't used to happen, because the loop device used to issue
reads through the splice path and that does:

	error = add_to_page_cache_lru(page, mapping, index,
			GFP_KERNEL & mapping_gfp_mask(mapping));

i.e. it pays attention to the allocation context placed on the
inode and so is doing GFP_NOFS allocations here and avoiding the
recursion problem.

[ CC'd Michal Hocko and the mm list because it's a clear exaple of
why ignoring the mapping gfp mask on any page cache allocation is
a landmine waiting to be tripped over. ]

Cheers,

Dave.

[81248.855166] kworker/u3:0    D ffff88003a8fadc8 11304   930      2 0x00000000
[81248.855166] Workqueue: kloopd1 loop_queue_read_work
[81248.855166]  ffff88003a8fadc8 ffff880003e48000 ffff8800332fdd00 ffff88003a8fadb8
[81248.855166]  ffff88003a8fc000 ffff88003a8faf18 ffff8800332fdd00 ffff88003a8faf10
[81248.855166]  ffffffffffffffff ffff88003a8fade8 ffffffff81db608e ffff88003fc153c0
[81248.855166] Call Trace:
[81248.855166]  [<ffffffff81db608e>] schedule+0x3e/0x90
[81248.855166]  [<ffffffff81dba38f>] schedule_timeout+0x1cf/0x240
[81248.855166]  [<ffffffff810cce16>] ? try_to_wake_up+0x1f6/0x330
[81248.855166]  [<ffffffff81db7534>] wait_for_completion+0xb4/0x120
[81248.855166]  [<ffffffff810cd010>] ? wake_up_q+0x70/0x70
[81248.855166]  [<ffffffff810bc2d9>] flush_work+0xf9/0x170
[81248.855166]  [<ffffffff810ba0d0>] ? destroy_worker+0x90/0x90
[81248.855166]  [<ffffffff81513a2c>] xlog_cil_force_lsn+0xcc/0x250
[81248.855166]  [<ffffffff815126f2>] _xfs_log_force_lsn+0x82/0x2f0
[81248.855166]  [<ffffffff8151298e>] xfs_log_force_lsn+0x2e/0xa0
[81248.855166]  [<ffffffff81501e49>] ? xfs_iunpin_wait+0x19/0x20
[81248.855166]  [<ffffffff814fe686>] __xfs_iunpin_wait+0xb6/0x170
[81248.855166]  [<ffffffff810e0f90>] ? autoremove_wake_function+0x40/0x40
[81248.855166]  [<ffffffff81501e49>] xfs_iunpin_wait+0x19/0x20
[81248.855166]  [<ffffffff814f6df2>] xfs_reclaim_inode+0x72/0x350
[81248.855166]  [<ffffffff814f72e2>] xfs_reclaim_inodes_ag+0x212/0x350
[81248.855166]  [<ffffffff81dbb07e>] ? _raw_spin_unlock+0xe/0x20
[81248.855166]  [<ffffffff81dbb07e>] ? _raw_spin_unlock+0xe/0x20
[81248.855166]  [<ffffffff814f74b3>] xfs_reclaim_inodes_nr+0x33/0x40
[81248.855166]  [<ffffffff81507f19>] xfs_fs_free_cached_objects+0x19/0x20
[81248.855166]  [<ffffffff811cf791>] super_cache_scan+0x191/0x1a0
[81248.855166]  [<ffffffff811912d4>] shrink_slab.part.62.constprop.80+0x1b4/0x380
[81248.855166]  [<ffffffff81194720>] shrink_zone+0x90/0xa0
[81248.855166]  [<ffffffff811948b0>] do_try_to_free_pages+0x180/0x2c0
[81248.855166]  [<ffffffff81194aaa>] try_to_free_pages+0xba/0x160
[81248.855166]  [<ffffffff81189509>] __alloc_pages_nodemask+0x499/0x840
[81248.855166]  [<ffffffff811c3d2f>] new_slab+0x6f/0x2c0
[81248.855166]  [<ffffffff811c5baa>] __slab_alloc.constprop.75+0x3fa/0x580
[81248.855166]  [<ffffffff817be438>] ? __radix_tree_preload+0x48/0xc0
[81248.855166]  [<ffffffff817be438>] ? __radix_tree_preload+0x48/0xc0
[81248.855166]  [<ffffffff811c620e>] kmem_cache_alloc+0x12e/0x160
[81248.855166]  [<ffffffff817be438>] __radix_tree_preload+0x48/0xc0
[81248.855166]  [<ffffffff817be519>] radix_tree_maybe_preload+0x19/0x20
[81248.855166]  [<ffffffff81181b69>] __add_to_page_cache_locked+0x39/0x1f0
[81248.855166]  [<ffffffff81181d68>] add_to_page_cache_lru+0x28/0x80
[81248.855166]  [<ffffffff81209fc9>] mpage_readpages+0xb9/0x130
[81248.855166]  [<ffffffff814e68e0>] ? __xfs_get_blocks+0x840/0x840
[81248.855166]  [<ffffffff814e68e0>] ? __xfs_get_blocks+0x840/0x840
[81248.855166]  [<ffffffff814e409d>] xfs_vm_readpages+0x1d/0x20
[81248.855166]  [<ffffffff8118cfc9>] __do_page_cache_readahead+0x1b9/0x250
[81248.855166]  [<ffffffff8118d13f>] ondemand_readahead+0xdf/0x270
[81248.855166]  [<ffffffff81180fc6>] ? find_get_entry+0x66/0xb0
[81248.855166]  [<ffffffff8118d362>] page_cache_async_readahead+0x92/0xc0
[81248.855166]  [<ffffffff81182c3c>] generic_file_read_iter+0x41c/0x650
[81248.855166]  [<ffffffff81db9664>] ? down_read+0x24/0x40
[81248.855166]  [<ffffffff814f1d66>] xfs_file_read_iter+0xe6/0x2d0
[81248.855166]  [<ffffffff811cba22>] vfs_iter_read+0x62/0xa0
[81248.855166]  [<ffffffff81a98fcd>] loop_handle_cmd.isra.28+0x6dd/0xaa0
[81248.855166]  [<ffffffff810cce16>] ? try_to_wake_up+0x1f6/0x330
[81248.855166]  [<ffffffff81a99472>] loop_queue_read_work+0x12/0x20
[81248.855166]  [<ffffffff810bd02e>] process_one_work+0x14e/0x410
[81248.855166]  [<ffffffff810bd63e>] worker_thread+0x4e/0x460
[81248.855166]  [<ffffffff810bd5f0>] ? rescuer_thread+0x300/0x300
[81248.855166]  [<ffffffff810c288c>] kthread+0xec/0x110
[81248.855166]  [<ffffffff810c27a0>] ? kthread_create_on_node+0x1b0/0x1b0
[81248.855166]  [<ffffffff81dbba5f>] ret_from_fork+0x3f/0x70
[81248.855166]  [<ffffffff810c27a0>] ? kthread_create_on_node+0x1b0/0x1b0

[81248.855166] kworker/0:0     D ffff88002ed8bb88 13896   948      2 0x00000000
[81248.855166] Workqueue: xfs-cil/loop1 xlog_cil_push_work
[81248.855166]  ffff88002ed8bb88 ffffffff82368540 ffff880003e4be00 ffff88001a467cf0
[81248.855166]  ffff88002ed8c000 ffff880005123cf8 ffff88001a467cf0 ffff880003e4be00
[81248.855166]  ffff880005123cc0 ffff88002ed8bba8 ffffffff81db608e ffff88002ed8bba8
[81248.855166] Call Trace:
[81248.855166]  [<ffffffff81db608e>] schedule+0x3e/0x90
[81248.855166]  [<ffffffff81511266>] xlog_state_get_iclog_space+0xe6/0x330
[81248.855166]  [<ffffffff810cd010>] ? wake_up_q+0x70/0x70
[81248.855166]  [<ffffffff81511666>] xlog_write+0x1b6/0x870
[81248.855166]  [<ffffffff8151316d>] xlog_cil_push+0x24d/0x400
[81248.855166]  [<ffffffff81513335>] xlog_cil_push_work+0x15/0x20
[81248.855166]  [<ffffffff810bd02e>] process_one_work+0x14e/0x410
[81248.855166]  [<ffffffff810bd63e>] worker_thread+0x4e/0x460
[81248.855166]  [<ffffffff810bd5f0>] ? rescuer_thread+0x300/0x300
[81248.855166]  [<ffffffff810bd5f0>] ? rescuer_thread+0x300/0x300
[81248.855166]  [<ffffffff810c288c>] kthread+0xec/0x110
[81248.855166]  [<ffffffff810c27a0>] ? kthread_create_on_node+0x1b0/0x1b0
[81248.855166]  [<ffffffff81dbba5f>] ret_from_fork+0x3f/0x70
[81248.855166]  [<ffffffff810c27a0>] ? kthread_create_on_node+0x1b0/0x1b0

[81248.855166] kworker/u3:4    D ffff8800290439f8 12456  1066      2 0x00000000
[81248.855166] Workqueue: kloopd1 loop_queue_write_work
[81248.855166]  ffff8800290439f8 ffffffff82368540 ffff8800332f9f00 ffff8800290439e8
[81248.855166]  ffff880029044000 ffffffff00000000 ffff88001366cfd8 ffffffff00000002
[81248.855166]  ffff8800332f9f00 ffff880029043a18 ffffffff81db608e ffff880029043a18
[81248.855166] Call Trace:
[81248.855166]  [<ffffffff81db608e>] schedule+0x3e/0x90
[81248.855166]  [<ffffffff81db9f3d>] rwsem_down_write_failed+0x13d/0x340
[81248.855166]  [<ffffffff810cce16>] ? try_to_wake_up+0x1f6/0x330
[81248.855166]  [<ffffffff814f2e46>] ? xfs_file_buffered_aio_write+0x66/0x250
[81248.855166]  [<ffffffff817c76a3>] call_rwsem_down_write_failed+0x13/0x20
[81248.855166]  [<ffffffff81db96bf>] ? down_write+0x3f/0x60
[81248.855166]  [<ffffffff814fdea4>] xfs_ilock+0x154/0x1d0
[81248.855166]  [<ffffffff814f2e46>] xfs_file_buffered_aio_write+0x66/0x250
[81248.855166]  [<ffffffff8179264d>] ? kblockd_schedule_work+0x1d/0x30
[81248.855166]  [<ffffffff8179dbc5>] ? blk_mq_kick_requeue_list+0x15/0x20
[81248.855166]  [<ffffffff814f3136>] xfs_file_write_iter+0x106/0x120
[81248.855166]  [<ffffffff811cbac3>] vfs_iter_write+0x63/0xa0
[81248.855166]  [<ffffffff81a97828>] lo_write_bvec+0x58/0x100
[81248.855166]  [<ffffffff81a99248>] loop_handle_cmd.isra.28+0x958/0xaa0
[81248.855166]  [<ffffffff81a9941f>] loop_queue_write_work+0x8f/0xd0
[81248.855166]  [<ffffffff810bd02e>] process_one_work+0x14e/0x410
[81248.855166]  [<ffffffff810bd63e>] worker_thread+0x4e/0x460
[81248.855166]  [<ffffffff810bd5f0>] ? rescuer_thread+0x300/0x300
[81248.855166]  [<ffffffff810c288c>] kthread+0xec/0x110
[81248.855166]  [<ffffffff810c27a0>] ? kthread_create_on_node+0x1b0/0x1b0
[81248.855166]  [<ffffffff81dbba5f>] ret_from_fork+0x3f/0x70
[81248.855166]  [<ffffffff810c27a0>] ? kthread_create_on_node+0x1b0/0x1b0
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
