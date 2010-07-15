Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 0A52E600227
	for <linux-mm@kvack.org>; Thu, 15 Jul 2010 07:47:28 -0400 (EDT)
From: Dave Chinner <david@fromorbit.com>
Subject: [PATCH 0/3] shrinker fixes for XFS for 2.6.35
Date: Thu, 15 Jul 2010 21:46:55 +1000
Message-Id: <1279194418-16119-1-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
To: xfs@oss.sgi.com
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Per-superblock shrinkers are not baked well enough for 2.6.36. However, we
still need fixes for the XFS shrinker lockdep problems caused by the global
mount list lock and other problems before 2.6.35 releases. The lockdep issues
look like:

=======================================================
[ INFO: possible circular locking dependency detected ]
2.6.35-rc5-dgc+ #34
-------------------------------------------------------
kswapd0/471 is trying to acquire lock:
 (&(&ip->i_lock)->mr_lock){++++-.}, at: [<ffffffff81316feb>] xfs_ilock+0x10b/0x190

but task is already holding lock:
 (&xfs_mount_list_lock){++++.-}, at: [<ffffffff81350fd6>] xfs_reclaim_inode_shrink+0xd6/0x150

which lock already depends on the new lock.


the existing dependency chain (in reverse order) is:

-> #1 (&xfs_mount_list_lock){++++.-}:
       [<ffffffff810b4ad6>] lock_acquire+0xa6/0x160
       [<ffffffff817a4dd5>] _raw_spin_lock_irqsave+0x55/0xa0
       [<ffffffff8106db62>] __wake_up+0x32/0x70
       [<ffffffff811196db>] wakeup_kswapd+0xab/0xb0
       [<ffffffff811132cd>] __alloc_pages_nodemask+0x27d/0x760
       [<ffffffff81145c72>] kmem_getpages+0x62/0x160
       [<ffffffff81146cdf>] fallback_alloc+0x18f/0x260
       [<ffffffff81146a6b>] ____cache_alloc_node+0x9b/0x180
       [<ffffffff811473bb>] kmem_cache_alloc+0x16b/0x1e0
       [<ffffffff81340d54>] kmem_zone_alloc+0x94/0xe0
       [<ffffffff813173a9>] xfs_inode_alloc+0x29/0x1b0
       [<ffffffff8131781c>] xfs_iget+0x2ec/0x7a0
       [<ffffffff8133a697>] xfs_trans_iget+0x27/0x60
       [<ffffffff8131a60a>] xfs_ialloc+0xca/0x790
       [<ffffffff8133b37f>] xfs_dir_ialloc+0xaf/0x340
       [<ffffffff8133c38c>] xfs_create+0x3dc/0x710
       [<ffffffff8134d277>] xfs_vn_mknod+0xa7/0x1c0
       [<ffffffff8134d3c0>] xfs_vn_create+0x10/0x20
       [<ffffffff8115ab2c>] vfs_create+0xac/0xd0
       [<ffffffff8115b6bc>] do_last+0x51c/0x620
       [<ffffffff8115dbd4>] do_filp_open+0x224/0x640
       [<ffffffff8114d969>] do_sys_open+0x69/0x140
       [<ffffffff8114da80>] sys_open+0x20/0x30
       [<ffffffff81034ff2>] system_call_fastpath+0x16/0x1b

-> #0 (&(&ip->i_lock)->mr_lock){++++-.}:
       [<ffffffff810b47a3>] __lock_acquire+0x11c3/0x1450
       [<ffffffff810b4ad6>] lock_acquire+0xa6/0x160
       [<ffffffff810a2035>] down_write_nested+0x65/0xb0
       [<ffffffff81316feb>] xfs_ilock+0x10b/0x190
       [<ffffffff8135023d>] xfs_reclaim_inode+0x9d/0x250
       [<ffffffff81350d4b>] xfs_inode_ag_walk+0x8b/0x150
       [<ffffffff81350e9b>] xfs_inode_ag_iterator+0x8b/0xf0
       [<ffffffff8135100c>] xfs_reclaim_inode_shrink+0x10c/0x150
       [<ffffffff81119be5>] shrink_slab+0x135/0x1a0
       [<ffffffff8111bac1>] balance_pgdat+0x421/0x6a0
       [<ffffffff8111be5d>] kswapd+0x11d/0x320
       [<ffffffff8109cdb6>] kthread+0x96/0xa0
       [<ffffffff81035de4>] kernel_thread_helper+0x4/0x10

other info that might help us debug this:

2 locks held by kswapd0/471:
 #0:  (shrinker_rwsem){++++..}, at: [<ffffffff81119aed>] shrink_slab+0x3d/0x1a0
 #1:  (&xfs_mount_list_lock){++++.-}, at: [<ffffffff81350fd6>] xfs_reclaim_inode_shrink+0xd6/0x150

There are also a few variations as these paths are traversed
from different locations in different workloads.

There are also scanning overhead problems caused by the global shrinker as seen
in https://bugzilla.kernel.org/show_bug.cgi?id=16348. This is not helped by
every shrinker call potentially traversing multiple filesystems to find one
with reclaimable inodes.

The context based shrinker solution is very simple and doesn't have any effect
outside XFS. For XFS, it allows us to avoid locking needed by a global list, as
well as remove the repeated scanning of clean filesystems on every shrinker
call. In combination with the tagging of the per-AG index to track AGs with
reclaimable inodes, all the unnecessary AG scanning is removed and the overhead
is minimised. Hence kswapd CPU usage and reclaim progress is not hindered
anymore.

The patch set is also available at:

	git://git.kernel.org/pub/scm/git/linux/dgc/xfsdev shrinker

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
