Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id C6F376B024D
	for <linux-mm@kvack.org>; Fri, 23 Jul 2010 11:51:23 -0400 (EDT)
Date: Sat, 24 Jul 2010 01:51:18 +1000
From: Nick Piggin <npiggin@kernel.dk>
Subject: Re: VFS scalability git tree
Message-ID: <20100723155118.GB5773@amd>
References: <20100722190100.GA22269@amd>
 <20100723111310.GI32635@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100723111310.GI32635@dastard>
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: Nick Piggin <npiggin@kernel.dk>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Frank Mayhar <fmayhar@google.com>, John Stultz <johnstul@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jul 23, 2010 at 09:13:10PM +1000, Dave Chinner wrote:
> On Fri, Jul 23, 2010 at 05:01:00AM +1000, Nick Piggin wrote:
> > I'm pleased to announce I have a git tree up of my vfs scalability work.
> > 
> > git://git.kernel.org/pub/scm/linux/kernel/git/npiggin/linux-npiggin.git
> > http://git.kernel.org/?p=linux/kernel/git/npiggin/linux-npiggin.git
> > 
> > Branch vfs-scale-working
> 
> I've got a couple of patches needed to build XFS - they shrinker
> merge left some bad fragments - I'll post them in a minute. This

OK cool.


> email is for the longest ever lockdep warning I've seen that
> occurred on boot.

Ah thanks. OK that was one of my attempts to keep sockets out of
hidding the vfs as much as possible (lazy inode number evaluation).
Not a big problem, but I'll drop the patch for now.

I have just got one for you too, btw :) (on vanilla kernel but it is
messing up my lockdep stress testing on xfs). Real or false?

[ INFO: possible circular locking dependency detected ]
2.6.35-rc5-00064-ga9f7f2e #334
-------------------------------------------------------
kswapd0/605 is trying to acquire lock:
 (&(&ip->i_lock)->mr_lock){++++--}, at: [<ffffffff8125500c>]
xfs_ilock+0x7c/0xa0

but task is already holding lock:
 (&xfs_mount_list_lock){++++.-}, at: [<ffffffff81281a76>]
xfs_reclaim_inode_shrink+0xc6/0x140

which lock already depends on the new lock.


the existing dependency chain (in reverse order) is:

-> #1 (&xfs_mount_list_lock){++++.-}:
       [<ffffffff8106ef9a>] lock_acquire+0x5a/0x70
       [<ffffffff815aa646>] _raw_spin_lock+0x36/0x50
       [<ffffffff810fabf3>] try_to_free_buffers+0x43/0xb0
       [<ffffffff812763b2>] xfs_vm_releasepage+0x92/0xe0
       [<ffffffff810908ee>] try_to_release_page+0x2e/0x50
       [<ffffffff8109ef56>] shrink_page_list+0x486/0x5a0
       [<ffffffff8109f35d>] shrink_inactive_list+0x2ed/0x700
       [<ffffffff8109fda0>] shrink_zone+0x3b0/0x460
       [<ffffffff810a0f41>] try_to_free_pages+0x241/0x3a0
       [<ffffffff810999e2>] __alloc_pages_nodemask+0x4c2/0x6b0
       [<ffffffff810c52c6>] alloc_pages_current+0x76/0xf0
       [<ffffffff8109205b>] __page_cache_alloc+0xb/0x10
       [<ffffffff81092a2a>] find_or_create_page+0x4a/0xa0
       [<ffffffff812780cc>] _xfs_buf_lookup_pages+0x14c/0x360
       [<ffffffff81279122>] xfs_buf_get+0x72/0x160
       [<ffffffff8126eb68>] xfs_trans_get_buf+0xc8/0xf0
       [<ffffffff8124439f>] xfs_da_do_buf+0x3df/0x6d0
       [<ffffffff81244825>] xfs_da_get_buf+0x25/0x30
       [<ffffffff8124a076>] xfs_dir2_data_init+0x46/0xe0
       [<ffffffff81247f89>] xfs_dir2_sf_to_block+0xb9/0x5a0
       [<ffffffff812501c8>] xfs_dir2_sf_addname+0x418/0x5c0
       [<ffffffff81247d7c>] xfs_dir_createname+0x14c/0x1a0
       [<ffffffff81271d49>] xfs_create+0x449/0x5d0
       [<ffffffff8127d802>] xfs_vn_mknod+0xa2/0x1b0
       [<ffffffff8127d92b>] xfs_vn_create+0xb/0x10
       [<ffffffff810ddc81>] vfs_create+0x81/0xd0
       [<ffffffff810df1a5>] do_last+0x535/0x690
       [<ffffffff810e11fd>] do_filp_open+0x21d/0x660
       [<ffffffff810d16b4>] do_sys_open+0x64/0x140
       [<ffffffff810d17bb>] sys_open+0x1b/0x20
       [<ffffffff810023eb>] system_call_fastpath+0x16/0x1b

:-> #0 (&(&ip->i_lock)->mr_lock){++++--}:
       [<ffffffff8106ef10>] __lock_acquire+0x1be0/0x1c10
       [<ffffffff8106ef9a>] lock_acquire+0x5a/0x70
       [<ffffffff8105dfba>] down_write_nested+0x4a/0x70
       [<ffffffff8125500c>] xfs_ilock+0x7c/0xa0
       [<ffffffff81280c98>] xfs_reclaim_inode+0x98/0x250
       [<ffffffff81281824>] xfs_inode_ag_walk+0x74/0x120
       [<ffffffff81281953>] xfs_inode_ag_iterator+0x83/0xe0
       [<ffffffff81281aa4>] xfs_reclaim_inode_shrink+0xf4/0x140
       [<ffffffff8109ff7d>] shrink_slab+0x12d/0x190
       [<ffffffff810a07ad>] balance_pgdat+0x43d/0x6f0
       [<ffffffff810a0b1e>] kswapd+0xbe/0x2a0
       [<ffffffff810592ae>] kthread+0x8e/0xa0
       [<ffffffff81003194>] kernel_thread_helper+0x4/0x10

other info that might help us debug this:

2 locks held by kswapd0/605:
 #0:  (shrinker_rwsem){++++..}, at: [<ffffffff8109fe88>]
shrink_slab+0x38/0x190
 #1:  (&xfs_mount_list_lock){++++.-}, at: [<ffffffff81281a76>]
xfs_reclaim_inode_shrink+0xc6/0x140

stack backtrace:
Pid: 605, comm: kswapd0 Not tainted 2.6.35-rc5-00064-ga9f7f2e #334
Call Trace:
 [<ffffffff8106c5d9>] print_circular_bug+0xe9/0xf0
 [<ffffffff8106ef10>] __lock_acquire+0x1be0/0x1c10
 [<ffffffff8106e3c2>] ? __lock_acquire+0x1092/0x1c10
 [<ffffffff8106ef9a>] lock_acquire+0x5a/0x70
 [<ffffffff8125500c>] ? xfs_ilock+0x7c/0xa0
 [<ffffffff8105dfba>] down_write_nested+0x4a/0x70
 [<ffffffff8125500c>] ? xfs_ilock+0x7c/0xa0
 [<ffffffff815ae795>] ? sub_preempt_count+0x95/0xd0
 [<ffffffff8125500c>] xfs_ilock+0x7c/0xa0
 [<ffffffff81280c98>] xfs_reclaim_inode+0x98/0x250
 [<ffffffff81281824>] xfs_inode_ag_walk+0x74/0x120
 [<ffffffff81280c00>] ? xfs_reclaim_inode+0x0/0x250
 [<ffffffff81281953>] xfs_inode_ag_iterator+0x83/0xe0
 [<ffffffff81280c00>] ? xfs_reclaim_inode+0x0/0x250
 [<ffffffff81281aa4>] xfs_reclaim_inode_shrink+0xf4/0x140
 [<ffffffff8109ff7d>] shrink_slab+0x12d/0x190
 [<ffffffff810a07ad>] balance_pgdat+0x43d/0x6f0
 [<ffffffff810a0b1e>] kswapd+0xbe/0x2a0
 [<ffffffff81059700>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff815aaf3d>] ? _raw_spin_unlock_irqrestore+0x3d/0x70
 [<ffffffff810a0a60>] ? kswapd+0x0/0x2a0
 [<ffffffff810592ae>] kthread+0x8e/0xa0
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff815ab400>] ? restore_args+0x0/0x30
 [<ffffffff81059220>] ? kthread+0x0/0xa0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
