Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id C46E5280250
	for <linux-mm@kvack.org>; Fri,  7 Oct 2016 04:07:44 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id os4so12968310pac.5
        for <linux-mm@kvack.org>; Fri, 07 Oct 2016 01:07:44 -0700 (PDT)
Received: from mail-pa0-f65.google.com (mail-pa0-f65.google.com. [209.85.220.65])
        by mx.google.com with ESMTPS id f13si7579364pfe.131.2016.10.07.01.07.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Oct 2016 01:07:43 -0700 (PDT)
Received: by mail-pa0-f65.google.com with SMTP id cd13so2377655pac.3
        for <linux-mm@kvack.org>; Fri, 07 Oct 2016 01:07:43 -0700 (PDT)
Date: Fri, 7 Oct 2016 10:07:40 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: lockdep splat due to reclaim recursion detected
Message-ID: <20161007080739.GD18439@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi Dave,
while playing with the test case you have suggested [1], I have hit the
following lockdep splat. This is with mmotm git tree [2] but I didn't
get to retest with the current linux-next (or any other tree of your
preference) so there is a chance that something is broken in my tree so
take this as a heads up. As soon as I am done with testing of the patch
in the above email thread I will retest with linux-next.

[   61.875155] =================================
[   61.875716] [ INFO: inconsistent lock state ]
[   61.876293] 4.7.0-mmotm #995 Not tainted
[   61.876808] ---------------------------------
[   61.877347] inconsistent {IN-RECLAIM_FS-W} -> {RECLAIM_FS-ON-W} usage.
[   61.878150] fs_mark/3179 [HC0[0]:SC0[0]:HE1:SE1] takes:
[   61.878792]  (&xfs_nondir_ilock_class){++++?.}, at: [<ffffffffa0064838>] xfs_ilock_nowait+0x146/0x21c [xfs]
[   61.878792] {IN-RECLAIM_FS-W} state was registered at:
[   61.878792]   [<ffffffff81096ad5>] __lock_acquire+0x3f1/0x156e
[   61.878792]   [<ffffffff81098049>] lock_acquire+0x133/0x1c7
[   61.878792]   [<ffffffff81092a3c>] down_write_nested+0x26/0x55
[   61.878792]   [<ffffffffa0064606>] xfs_ilock+0x158/0x1d8 [xfs]
[   61.878792]   [<ffffffffa005c106>] xfs_reclaim_inode+0x43/0x333 [xfs]
[   61.878792]   [<ffffffffa005c6b2>] xfs_reclaim_inodes_ag+0x2bc/0x364 [xfs]
[   61.878792]   [<ffffffffa005df98>] xfs_reclaim_inodes_nr+0x30/0x36 [xfs]
[   61.878792]   [<ffffffffa006c1a6>] xfs_fs_free_cached_objects+0x19/0x1b [xfs]
[   61.878792]   [<ffffffff8119d10a>] super_cache_scan+0x156/0x179
[   61.878792]   [<ffffffff8113c1e3>] shrink_slab+0x2c3/0x4d9
[   61.878792]   [<ffffffff8113fe5d>] shrink_node+0x166/0x282
[   61.878792]   [<ffffffff811411d8>] kswapd+0x63c/0x807
[   61.878792]   [<ffffffff8106e30b>] kthread+0xed/0xf5
[   61.878792]   [<ffffffff8162f03f>] ret_from_fork+0x1f/0x40
[   61.878792] irq event stamp: 2484353
[   61.878792] hardirqs last  enabled at (2484353): [<ffffffff8112d7d6>] bad_range+0x88/0x11d
[   61.878792] hardirqs last disabled at (2484352): [<ffffffff8112d78f>] bad_range+0x41/0x11d
[   61.878792] softirqs last  enabled at (2482528): [<ffffffff816318ee>] __do_softirq+0x33e/0x447
[   61.878792] softirqs last disabled at (2482507): [<ffffffff81055c5d>] irq_exit+0x40/0x94
[   61.878792] 
[   61.878792] other info that might help us debug this:
[   61.878792]  Possible unsafe locking scenario:
[   61.878792] 
[   61.878792]        CPU0
[   61.878792]        ----
[   61.878792]   lock(&xfs_nondir_ilock_class);
[   61.878792]   <Interrupt>
[   61.878792]     lock(&xfs_nondir_ilock_class);
[   61.878792] 
[   61.878792]  *** DEADLOCK ***
[   61.878792] 
[   61.878792] 6 locks held by fs_mark/3179:
[   61.878792]  #0:  (sb_writers#9){.+.+.+}, at: [<ffffffff8119cf20>] __sb_start_write+0x65/0xae
[   61.878792]  #1:  (&type->i_mutex_dir_key#4){+.+.+.}, at: [<ffffffff811a6f13>] path_openat+0x37c/0x7cd
[   61.878792]  #2:  (sb_internal#2){.+.+.+}, at: [<ffffffff8119cf5b>] __sb_start_write+0xa0/0xae
[   61.878792]  #3:  (&(&ip->i_iolock)->mr_lock/4){+.+.+.}, at: [<ffffffffa006459d>] xfs_ilock+0xef/0x1d8 [xfs]
[   61.878792]  #4:  (&xfs_dir_ilock_class/5){+.+.+.}, at: [<ffffffffa0064606>] xfs_ilock+0x158/0x1d8 [xfs]
[   61.878792]  #5:  (&xfs_nondir_ilock_class){++++?.}, at: [<ffffffffa0064838>] xfs_ilock_nowait+0x146/0x21c [xfs]
[   61.878792] 
[   61.878792] stack backtrace:
[   61.878792] CPU: 0 PID: 3179 Comm: fs_mark Not tainted 4.7.0-mmotm #995
[   61.878792] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Debian-1.8.2-1 04/01/2014
[   61.878792]  0000000000000000 ffff88001c8b3718 ffffffff81312f78 ffffffff825d99d0
[   61.878792]  ffff88001cd04880 ffff88001c8b3750 ffffffff811260d1 000000000000000a
[   61.878792]  ffff88001cd05178 ffff88001cd04880 ffffffff81095395 ffff88001cd04880
[   61.878792] Call Trace:
[   61.878792]  [<ffffffff81312f78>] dump_stack+0x68/0x92
[   61.878792]  [<ffffffff811260d1>] print_usage_bug.part.26+0x25b/0x26a
[   61.878792]  [<ffffffff81095395>] ? print_shortest_lock_dependencies+0x17f/0x17f
[   61.878792]  [<ffffffff81096074>] mark_lock+0x381/0x56d
[   61.878792]  [<ffffffff810962be>] mark_held_locks+0x5e/0x74
[   61.878792]  [<ffffffff8109875c>] lockdep_trace_alloc+0xaf/0xb2
[   61.878792]  [<ffffffff8117d0f7>] kmem_cache_alloc_trace+0x3a/0x270
[   61.878792]  [<ffffffff81169454>] ? vm_map_ram+0x2d2/0x4a6
[   61.878792]  [<ffffffff8116924b>] ? vm_map_ram+0xc9/0x4a6
[   61.878792]  [<ffffffff81169454>] vm_map_ram+0x2d2/0x4a6
[   61.878792]  [<ffffffffa0051069>] _xfs_buf_map_pages+0xae/0x10b [xfs]
[   61.878792]  [<ffffffffa0052cd0>] xfs_buf_get_map+0xaa/0x24f [xfs]
[   61.878792]  [<ffffffffa0081d10>] xfs_trans_get_buf_map+0x144/0x2ef [xfs]
[   61.878792]  [<ffffffffa0032473>] xfs_da_get_buf+0x81/0xc1 [xfs]
[   61.878792]  [<ffffffffa0038e9e>] xfs_dir3_data_init+0x5b/0x1ae [xfs]
[   61.878792]  [<ffffffffa003d858>] xfs_dir2_node_addname+0x62e/0x915 [xfs]
[   61.878792]  [<ffffffffa003d858>] ? xfs_dir2_node_addname+0x62e/0x915 [xfs]
[   61.878792]  [<ffffffffa003609e>] xfs_dir_createname+0x15e/0x17b [xfs]
[   61.878792]  [<ffffffffa00668cc>] xfs_create+0x38a/0x698 [xfs]
[   61.878792]  [<ffffffffa00639f5>] xfs_generic_create+0xc8/0x1e2 [xfs]
[   61.878792]  [<ffffffffa0063b3e>] xfs_vn_mknod+0x14/0x16 [xfs]
[   61.878792]  [<ffffffffa0063b6b>] xfs_vn_create+0x13/0x15 [xfs]
[   61.878792]  [<ffffffff811a603f>] lookup_open+0x45e/0x55a
[   61.878792]  [<ffffffff811a6f3e>] path_openat+0x3a7/0x7cd
[   61.878792]  [<ffffffff81097034>] ? __lock_acquire+0x950/0x156e
[   61.878792]  [<ffffffff811a801e>] do_filp_open+0x4d/0xa3
[   61.878792]  [<ffffffff811b5cb9>] ? __alloc_fd+0x1b2/0x1c4
[   61.878792]  [<ffffffff8162e640>] ? _raw_spin_unlock+0x31/0x44
[   61.878792]  [<ffffffff811b5cb9>] ? __alloc_fd+0x1b2/0x1c4
[   61.878792]  [<ffffffff81198b2d>] do_sys_open+0x140/0x1d0
[   61.878792]  [<ffffffff81198b2d>] ? do_sys_open+0x140/0x1d0
[   61.878792]  [<ffffffff81198bdb>] SyS_open+0x1e/0x20
[   61.878792]  [<ffffffff8162ee25>] entry_SYSCALL_64_fastpath+0x18/0xa8

[1] http://lkml.kernel.org/r/20161004203202.GY9806@dastard
[2] git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git #since-4.7
    which is v4.7 + all mmotm mm related patches.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
