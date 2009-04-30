Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id ECC406B003D
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 10:31:33 -0400 (EDT)
Date: Thu, 30 Apr 2009 22:28:07 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] use GFP_NOFS in kernel_event()
Message-ID: <20090430142807.GA13931@localhost>
References: <20090430020004.GA1898@localhost> <20090429191044.b6fceae2.akpm@linux-foundation.org> <1241097573.6020.7.camel@localhost.localdomain> <20090430134821.GB8644@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090430134821.GB8644@localhost>
Sender: owner-linux-mm@kvack.org
To: Eric Paris <eparis@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Matt Mackall <mpm@selenic.com>, Christoph Lameter <clameter@sgi.com>, Ingo Molnar <mingo@elte.hu>, Al Viro <viro@zeniv.linux.org.uk>
List-ID: <linux-mm.kvack.org>

On Thu, Apr 30, 2009 at 09:48:21PM +0800, Wu Fengguang wrote:
> On Thu, Apr 30, 2009 at 09:19:33PM +0800, Eric Paris wrote:
> > On Wed, 2009-04-29 at 19:10 -0700, Andrew Morton wrote:
> > > On Thu, 30 Apr 2009 10:00:04 +0800 Wu Fengguang <fengguang.wu@intel.com> wrote:
> > > 
> > > > Fix a possible deadlock on inotify_mutex, reported by lockdep.
> > > > 
> > > > inotify_inode_queue_event() => take inotify_mutex => kernel_event() =>
> > > > kmalloc() => SLOB => alloc_pages_node() => page reclaim => slab reclaim =>
> > > > dcache reclaim => inotify_inode_is_dead => take inotify_mutex => deadlock
> > > > 
> > > > The actual deadlock may not happen because the inode was grabbed at
> > > > inotify_add_watch(). But the GFP_KERNEL here is unsound and not
> > > > consistent with the other two GFP_NOFS inside the same function.
> > > > 
> > > > [ 2668.325318]
> > > > [ 2668.325322] =================================
> > > > [ 2668.327448] [ INFO: inconsistent lock state ]
> > > > [ 2668.327448] 2.6.30-rc2-next-20090417 #203
> > > > [ 2668.327448] ---------------------------------
> > > > [ 2668.327448] inconsistent {RECLAIM_FS-ON-W} -> {IN-RECLAIM_FS-W} usage.
> > > > [ 2668.327448] kswapd0/380 [HC0[0]:SC0[0]:HE1:SE1] takes:
> > > > [ 2668.327448]  (&inode->inotify_mutex){+.+.?.}, at: [<ffffffff8112f1b5>] inotify_inode_is_dead+0x35/0xb0
> > 
> > 
> > > > [ 2668.327448] Pid: 380, comm: kswapd0 Not tainted 2.6.30-rc2-next-20090417 #203
> > > > [ 2668.327448] Call Trace:
> > > > [ 2668.327448]  [<ffffffff810789ef>] print_usage_bug+0x19f/0x200
> > > > [ 2668.327448]  [<ffffffff81018bff>] ? save_stack_trace+0x2f/0x50
> > > > [ 2668.327448]  [<ffffffff81078f0b>] mark_lock+0x4bb/0x6d0
> > > > [ 2668.327448]  [<ffffffff810799e0>] ? check_usage_forwards+0x0/0xc0
> > > > [ 2668.327448]  [<ffffffff8107b142>] __lock_acquire+0xc62/0x1ae0
> > > > [ 2668.327448]  [<ffffffff810f478c>] ? slob_free+0x10c/0x370
> > > > [ 2668.327448]  [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
> > > > [ 2668.327448]  [<ffffffff8112f1b5>] ? inotify_inode_is_dead+0x35/0xb0
> > > > [ 2668.327448]  [<ffffffff81562d43>] mutex_lock_nested+0x63/0x420
> > > > [ 2668.327448]  [<ffffffff8112f1b5>] ? inotify_inode_is_dead+0x35/0xb0
> > > > [ 2668.327448]  [<ffffffff8112f1b5>] ? inotify_inode_is_dead+0x35/0xb0
> > > > [ 2668.327448]  [<ffffffff81012fe9>] ? sched_clock+0x9/0x10
> > > > [ 2668.327448]  [<ffffffff81077165>] ? lock_release_holdtime+0x35/0x1c0
> > > > [ 2668.327448]  [<ffffffff8112f1b5>] inotify_inode_is_dead+0x35/0xb0
> > > > [ 2668.327448]  [<ffffffff8110c9dc>] dentry_iput+0xbc/0xe0
> > > > [ 2668.327448]  [<ffffffff8110cb23>] d_kill+0x33/0x60
> > > > [ 2668.327448]  [<ffffffff8110ce23>] __shrink_dcache_sb+0x2d3/0x350
> > > > [ 2668.327448]  [<ffffffff8110cffa>] shrink_dcache_memory+0x15a/0x1e0
> > > > [ 2668.327448]  [<ffffffff810d0cc5>] shrink_slab+0x125/0x180
> > > > [ 2668.327448]  [<ffffffff810d1540>] kswapd+0x560/0x7a0
> > > > [ 2668.327448]  [<ffffffff810ce160>] ? isolate_pages_global+0x0/0x2c0
> > > > [ 2668.327448]  [<ffffffff81065a30>] ? autoremove_wake_function+0x0/0x40
> > > > [ 2668.327448]  [<ffffffff8107953d>] ? trace_hardirqs_on+0xd/0x10
> > > > [ 2668.327448]  [<ffffffff810d0fe0>] ? kswapd+0x0/0x7a0
> > > > [ 2668.327448]  [<ffffffff8106555b>] kthread+0x5b/0xa0
> > > > [ 2668.327448]  [<ffffffff8100d40a>] child_rip+0xa/0x20
> > > > [ 2668.327448]  [<ffffffff8100cdd0>] ? restore_args+0x0/0x30
> > > > [ 2668.327448]  [<ffffffff81065500>] ? kthread+0x0/0xa0
> > > > [ 2668.327448]  [<ffffffff8100d400>] ? child_rip+0x0/0x20
> > > > 
> > 
> > > 
> > > Somebody was going to fix this for us via lockdep annotation.
> > > 
> > > <adds randomly-chosen cc>
> > 
> > I really didn't forget this, but I can't figure out how to recreate it,
> > so I don't know if my logic in the patch is sound.  The patch certainly
> > will shut up the complaint.
> > 
> > We can only hit this inotify cleanup path if the i_nlink = 0.  I can't
> > find a way to leave the dentry around for memory pressure to clean up
> > later, but have the n_link = 0.  On ext* the inode is kicked out as soon
> > as the last close on all open fds for an inode which has been unlinked.
> > I tried attaching an inotify watch to an NFS or CIFS inode, deleting the
> > inode on another node, and then putting the first machine under memory
> > pressure.  I'm not sure why, but the dentry or inode in question were
> > never evicted so I didn't hit this path either....
> 
> FYI, I'm running a huge copy on btrfs with SLOB ;-)
> 
> > I know the patch will shut up the problem, but since I can't figure out
> > by looking at the code a path to reproduce I don't really feel 100%
> > confident that it is correct....
> > 
> > -Eric
> > 
> > inotify: lockdep annotation when watch being removed
> > 
> > From: Eric Paris <eparis@redhat.com>
> > 
> > When a dentry is being evicted from memory pressure, if the inode associated
> > with that dentry has i_nlink == 0 we are going to drop all of the watches and
> > kick everything out.  Lockdep complains that previously holding inotify_mutex
> > we did a __GFP_FS allocation and now __GFP_FS reclaim is taking that lock.
> > There is no deadlock or danger, since we know on this code path we are
> > actually cleaning up and evicting everything.  So we move the lock into a new
> > class for clean up.
> 
> I can reproduce the bug and hence confirm that this patch works, so
> 
> Tested-by: Wu Fengguang <fengguang.wu@intel.com>

Ah! The big copy runs all OK - until I run shutdown, and got this big
warning:

[ 2686.044276] nfsd: last server has exited, flushing export cache
[ 2689.681559]
[ 2689.681564] ======================================================
[ 2689.684200] [ INFO: RECLAIM_FS-safe -> RECLAIM_FS-unsafe lock order detected ]
[ 2689.684200] 2.6.30-rc2-next-20090417 #210
[ 2689.684200] ------------------------------------------------------
[ 2689.684200] umount/3548 [HC0[0]:SC0[0]:HE1:SE1] is trying to acquire:
[ 2689.684200]  (&inode->inotify_mutex){+.+.+.}, at: [<ffffffff8112f7da>] inotify_unmount_inodes+0xda/0x1f0
[ 2689.684200]
[ 2689.684200] and this task is already holding:
[ 2689.684200]  (iprune_mutex){+.+.-.}, at: [<ffffffff81110dfa>] invalidate_inodes+0x3a/0x170
[ 2689.684200] which would create a new lock dependency:
[ 2689.684200]  (iprune_mutex){+.+.-.} -> (&inode->inotify_mutex){+.+.+.}
[ 2689.684200]
[ 2689.684200] but this new dependency connects a RECLAIM_FS-irq-safe lock:
[ 2689.684200]  (iprune_mutex){+.+.-.}
[ 2689.684200] ... which became RECLAIM_FS-irq-safe at:
[ 2689.684200]   [<ffffffff8107b142>] __lock_acquire+0xc62/0x1ae0
[ 2689.684200]   [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]   [<ffffffff81562da3>] mutex_lock_nested+0x63/0x420
[ 2689.684200]   [<ffffffff81110b44>] shrink_icache_memory+0x84/0x300
[ 2689.684200]   [<ffffffff810d0cc5>] shrink_slab+0x125/0x180
[ 2689.684200]   [<ffffffff810d1540>] kswapd+0x560/0x7a0
[ 2689.684200]   [<ffffffff8106555b>] kthread+0x5b/0xa0
[ 2689.684200]   [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]   [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200] to a RECLAIM_FS-irq-unsafe lock:
[ 2689.684200]  (&inode->inotify_mutex){+.+.+.}
[ 2689.684200] ... which became RECLAIM_FS-irq-unsafe at:
[ 2689.684200] ...  [<ffffffff81079188>] mark_held_locks+0x68/0x90
[ 2689.684200]   [<ffffffff810792a5>] lockdep_trace_alloc+0xf5/0x100
[ 2689.684200]   [<ffffffff810f5261>] __kmalloc_node+0x31/0x1e0
[ 2689.684200]   [<ffffffff811306c2>] kernel_event+0xe2/0x190
[ 2689.684200]   [<ffffffff81130896>] inotify_dev_queue_event+0x126/0x230
[ 2689.684200]   [<ffffffff8112f0a6>] inotify_inode_queue_event+0xc6/0x110
[ 2689.684200]   [<ffffffff8110444d>] vfs_create+0xcd/0x140
[ 2689.684200]   [<ffffffff8110825d>] do_filp_open+0x88d/0xa20
[ 2689.684200]   [<ffffffff810f6b68>] do_sys_open+0x98/0x140
[ 2689.684200]   [<ffffffff810f6c50>] sys_open+0x20/0x30
[ 2689.684200]   [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[ 2689.684200]   [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200] other info that might help us debug this:
[ 2689.684200]
[ 2689.684200] 3 locks held by umount/3548:
[ 2689.684200]  #0:  (&type->s_umount_key#31){++++..}, at: [<ffffffff810fc4f3>] deactivate_super+0x53/0x80
[ 2689.684200]  #1:  (&type->s_lock_key#9){+.+...}, at: [<ffffffff810fb7ee>] lock_super+0x2e/0x30
[ 2689.684200]  #2:  (iprune_mutex){+.+.-.}, at: [<ffffffff81110dfa>] invalidate_inodes+0x3a/0x170
[ 2689.684200]
[ 2689.684200] the RECLAIM_FS-irq-safe lock's dependencies:
[ 2689.684200] -> (iprune_mutex){+.+.-.} ops: 0 {
[ 2689.684200]    HARDIRQ-ON-W at:
[ 2689.684200]                                        [<ffffffff8107b005>] __lock_acquire+0xb25/0x1ae0
[ 2689.684200]                                        [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                        [<ffffffff81562da3>] mutex_lock_nested+0x63/0x420
[ 2689.684200]                                        [<ffffffff81110b44>] shrink_icache_memory+0x84/0x300
[ 2689.684200]                                        [<ffffffff810d0cc5>] shrink_slab+0x125/0x180
[ 2689.684200]                                        [<ffffffff810d1540>] kswapd+0x560/0x7a0
[ 2689.684200]                                        [<ffffffff8106555b>] kthread+0x5b/0xa0
[ 2689.684200]                                        [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]                                        [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]    SOFTIRQ-ON-W at:
[ 2689.684200]                                        [<ffffffff8107b031>] __lock_acquire+0xb51/0x1ae0
[ 2689.684200]                                        [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                        [<ffffffff81562da3>] mutex_lock_nested+0x63/0x420
[ 2689.684200]                                        [<ffffffff81110b44>] shrink_icache_memory+0x84/0x300
[ 2689.684200]                                        [<ffffffff810d0cc5>] shrink_slab+0x125/0x180
[ 2689.684200]                                        [<ffffffff810d1540>] kswapd+0x560/0x7a0
[ 2689.684200]                                        [<ffffffff8106555b>] kthread+0x5b/0xa0
[ 2689.684200]                                        [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]                                        [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]    IN-RECLAIM_FS-W at:
[ 2689.684200]                                           [<ffffffff8107b142>] __lock_acquire+0xc62/0x1ae0
[ 2689.684200]                                           [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                           [<ffffffff81562da3>] mutex_lock_nested+0x63/0x420
[ 2689.684200]                                           [<ffffffff81110b44>] shrink_icache_memory+0x84/0x300
[ 2689.684200]                                           [<ffffffff810d0cc5>] shrink_slab+0x125/0x180
[ 2689.684200]                                           [<ffffffff810d1540>] kswapd+0x560/0x7a0
[ 2689.684200]                                           [<ffffffff8106555b>] kthread+0x5b/0xa0
[ 2689.684200]                                           [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]                                           [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]    INITIAL USE at:
[ 2689.684200]                                       [<ffffffff8107a67f>] __lock_acquire+0x19f/0x1ae0
[ 2689.684200]                                       [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                       [<ffffffff81562da3>] mutex_lock_nested+0x63/0x420
[ 2689.684200]                                       [<ffffffff81110b44>] shrink_icache_memory+0x84/0x300
[ 2689.684200]                                       [<ffffffff810d0cc5>] shrink_slab+0x125/0x180
[ 2689.684200]                                       [<ffffffff810d1540>] kswapd+0x560/0x7a0
[ 2689.684200]                                       [<ffffffff8106555b>] kthread+0x5b/0xa0
[ 2689.684200]                                       [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]                                       [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]  }
[ 2689.684200]  ... key      at: [<ffffffff817e94d0>] iprune_mutex+0x70/0xa0
[ 2689.684200]  -> (inode_lock){+.+.-.} ops: 0 {
[ 2689.684200]     HARDIRQ-ON-W at:
[ 2689.684200]                                          [<ffffffff8107b005>] __lock_acquire+0xb25/0x1ae0
[ 2689.684200]                                          [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                          [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]                                          [<ffffffff811102ae>] ifind_fast+0x2e/0xd0
[ 2689.684200]                                          [<ffffffff81111649>] iget_locked+0x49/0x180
[ 2689.684200]                                          [<ffffffff8114d4d5>] sysfs_get_inode+0x25/0x280
[ 2689.684200]                                          [<ffffffff811505c6>] sysfs_fill_super+0x56/0xd0
[ 2689.684200]                                          [<ffffffff810fc5ea>] get_sb_single+0xca/0x100
[ 2689.684200]                                          [<ffffffff8115056b>] sysfs_get_sb+0x1b/0x20
[ 2689.684200]                                          [<ffffffff810fb0f0>] vfs_kern_mount+0x50/0xd0
[ 2689.684200]                                          [<ffffffff810fb189>] kern_mount_data+0x19/0x20
[ 2689.684200]                                          [<ffffffff818cb634>] sysfs_init+0x7f/0xd4
[ 2689.684200]                                          [<ffffffff818c9e34>] mnt_init+0x9d/0x21e
[ 2689.684200]                                          [<ffffffff818c9984>] vfs_caches_init+0xa8/0x140
[ 2689.684200]                                          [<ffffffff818add0f>] start_kernel+0x34c/0x44f
[ 2689.684200]                                          [<ffffffff818ad299>] x86_64_start_reservations+0x99/0xb9
[ 2689.684200]                                          [<ffffffff818ad3b0>] x86_64_start_kernel+0xf7/0x122
[ 2689.684200]                                          [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]     SOFTIRQ-ON-W at:
[ 2689.684200]                                          [<ffffffff8107b031>] __lock_acquire+0xb51/0x1ae0
[ 2689.684200]                                          [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                          [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]                                          [<ffffffff811102ae>] ifind_fast+0x2e/0xd0
[ 2689.684200]                                          [<ffffffff81111649>] iget_locked+0x49/0x180
[ 2689.684200]                                          [<ffffffff8114d4d5>] sysfs_get_inode+0x25/0x280
[ 2689.684200]                                          [<ffffffff811505c6>] sysfs_fill_super+0x56/0xd0
[ 2689.684200]                                          [<ffffffff810fc5ea>] get_sb_single+0xca/0x100
[ 2689.684200]                                          [<ffffffff8115056b>] sysfs_get_sb+0x1b/0x20
[ 2689.684200]                                          [<ffffffff810fb0f0>] vfs_kern_mount+0x50/0xd0
[ 2689.684200]                                          [<ffffffff810fb189>] kern_mount_data+0x19/0x20
[ 2689.684200]                                          [<ffffffff818cb634>] sysfs_init+0x7f/0xd4
[ 2689.684200]                                          [<ffffffff818c9e34>] mnt_init+0x9d/0x21e
[ 2689.684200]                                          [<ffffffff818c9984>] vfs_caches_init+0xa8/0x140
[ 2689.684200]                                          [<ffffffff818add0f>] start_kernel+0x34c/0x44f
[ 2689.684200]                                          [<ffffffff818ad299>] x86_64_start_reservations+0x99/0xb9
[ 2689.684200]                                          [<ffffffff818ad3b0>] x86_64_start_kernel+0xf7/0x122
[ 2689.684200]                                          [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]     IN-RECLAIM_FS-W at:
[ 2689.684200]                                             [<ffffffff8107b142>] __lock_acquire+0xc62/0x1ae0
[ 2689.684200]                                             [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                             [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]                                             [<ffffffff81272328>] _atomic_dec_and_lock+0x98/0xc0
[ 2689.684200]                                             [<ffffffff8110fcea>] iput+0x4a/0x90
[ 2689.684200]                                             [<ffffffff8114f464>] sysfs_d_iput+0x34/0x40
[ 2689.684200]                                             [<ffffffff8110c9aa>] dentry_iput+0x8a/0xf0
[ 2689.684200]                                             [<ffffffff8110cb33>] d_kill+0x33/0x60
[ 2689.684200]                                             [<ffffffff8110ce33>] __shrink_dcache_sb+0x2d3/0x350
[ 2689.684200]                                             [<ffffffff8110d00a>] shrink_dcache_memory+0x15a/0x1e0
[ 2689.684200]                                             [<ffffffff810d0cc5>] shrink_slab+0x125/0x180
[ 2689.684200]                                             [<ffffffff810d1540>] kswapd+0x560/0x7a0
[ 2689.684200]                                             [<ffffffff8106555b>] kthread+0x5b/0xa0
[ 2689.684200]                                             [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]                                             [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]     INITIAL USE at:
[ 2689.684200]                                         [<ffffffff8107a67f>] __lock_acquire+0x19f/0x1ae0
[ 2689.684200]                                         [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                         [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]                                         [<ffffffff811102ae>] ifind_fast+0x2e/0xd0
[ 2689.684200]                                         [<ffffffff81111649>] iget_locked+0x49/0x180
[ 2689.684200]                                         [<ffffffff8114d4d5>] sysfs_get_inode+0x25/0x280
[ 2689.684200]                                         [<ffffffff811505c6>] sysfs_fill_super+0x56/0xd0
[ 2689.684200]                                         [<ffffffff810fc5ea>] get_sb_single+0xca/0x100
[ 2689.684200]                                         [<ffffffff8115056b>] sysfs_get_sb+0x1b/0x20
[ 2689.684200]                                         [<ffffffff810fb0f0>] vfs_kern_mount+0x50/0xd0
[ 2689.684200]                                         [<ffffffff810fb189>] kern_mount_data+0x19/0x20
[ 2689.684200]                                         [<ffffffff818cb634>] sysfs_init+0x7f/0xd4
[ 2689.684200]                                         [<ffffffff818c9e34>] mnt_init+0x9d/0x21e
[ 2689.684200]                                         [<ffffffff818c9984>] vfs_caches_init+0xa8/0x140
[ 2689.684200]                                         [<ffffffff818add0f>] start_kernel+0x34c/0x44f
[ 2689.684200]                                         [<ffffffff818ad299>] x86_64_start_reservations+0x99/0xb9
[ 2689.684200]                                         [<ffffffff818ad3b0>] x86_64_start_kernel+0xf7/0x122
[ 2689.684200]                                         [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]   }
[ 2689.684200]   ... key      at: [<ffffffff817e93f8>] inode_lock+0x18/0x40
[ 2689.684200]  ... acquired at:
[ 2689.684200]    [<ffffffff8107bab4>] __lock_acquire+0x15d4/0x1ae0
[ 2689.684200]    [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]    [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]    [<ffffffff81110b50>] shrink_icache_memory+0x90/0x300
[ 2689.684200]    [<ffffffff810d0cc5>] shrink_slab+0x125/0x180
[ 2689.684200]    [<ffffffff810d1540>] kswapd+0x560/0x7a0
[ 2689.684200]    [<ffffffff8106555b>] kthread+0x5b/0xa0
[ 2689.684200]    [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200]  -> (&sb->s_type->i_lock_key#2){+.+.-.} ops: 0 {
[ 2689.684200]     HARDIRQ-ON-W at:
[ 2689.684200]                                          [<ffffffff8107b005>] __lock_acquire+0xb25/0x1ae0
[ 2689.684200]                                          [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                          [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]                                          [<ffffffff811b2b1c>] nfs_do_access+0x3c/0x370
[ 2689.684200]                                          [<ffffffff811b2ffe>] nfs_permission+0x1ae/0x220
[ 2689.684200]                                          [<ffffffff81102f80>] inode_permission+0x60/0xa0
[ 2689.684200]                                          [<ffffffff810f7b7a>] sys_chdir+0x5a/0x90
[ 2689.684200]                                          [<ffffffff818adfd4>] do_mount_root+0x3c/0xab
[ 2689.684200]                                          [<ffffffff818ae4bf>] mount_root+0x138/0x141
[ 2689.684200]                                          [<ffffffff818ae5c0>] prepare_namespace+0xf8/0x198
[ 2689.684200]                                          [<ffffffff818ad6fe>] kernel_init+0x18b/0x1a8
[ 2689.684200]                                          [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]                                          [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]     SOFTIRQ-ON-W at:
[ 2689.684200]                                          [<ffffffff8107b031>] __lock_acquire+0xb51/0x1ae0
[ 2689.684200]                                          [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                          [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]                                          [<ffffffff811b2b1c>] nfs_do_access+0x3c/0x370
[ 2689.684200]                                          [<ffffffff811b2ffe>] nfs_permission+0x1ae/0x220
[ 2689.684200]                                          [<ffffffff81102f80>] inode_permission+0x60/0xa0
[ 2689.684200]                                          [<ffffffff810f7b7a>] sys_chdir+0x5a/0x90
[ 2689.684200]                                          [<ffffffff818adfd4>] do_mount_root+0x3c/0xab
[ 2689.684200]                                          [<ffffffff818ae4bf>] mount_root+0x138/0x141
[ 2689.684200]                                          [<ffffffff818ae5c0>] prepare_namespace+0xf8/0x198
[ 2689.684200]                                          [<ffffffff818ad6fe>] kernel_init+0x18b/0x1a8
[ 2689.684200]                                          [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]                                          [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]     IN-RECLAIM_FS-W at:
[ 2689.684200]                                             [<ffffffff8107b142>] __lock_acquire+0xc62/0x1ae0
[ 2689.684200]                                             [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                             [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]                                             [<ffffffff811c9b59>] nfs3_forget_cached_acls+0x49/0x90
[ 2689.684200]                                             [<ffffffff811b4f1f>] nfs_zap_acl_cache+0x3f/0x70
[ 2689.684200]                                             [<ffffffff811b739f>] nfs_clear_inode+0x6f/0x90
[ 2689.684200]                                             [<ffffffff8111076e>] clear_inode+0xfe/0x170
[ 2689.684200]                                             [<ffffffff811109d8>] dispose_list+0x38/0x120
[ 2689.684200]                                             [<ffffffff81110d4f>] shrink_icache_memory+0x28f/0x300
[ 2689.684200]                                             [<ffffffff810d0cc5>] shrink_slab+0x125/0x180
[ 2689.684200]                                             [<ffffffff810d1540>] kswapd+0x560/0x7a0
[ 2689.684200]                                             [<ffffffff8106555b>] kthread+0x5b/0xa0
[ 2689.684200]                                             [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]                                             [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]     INITIAL USE at:
[ 2689.684200]                                         [<ffffffff8107a67f>] __lock_acquire+0x19f/0x1ae0
[ 2689.684200]                                         [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                         [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]                                         [<ffffffff811b2b1c>] nfs_do_access+0x3c/0x370
[ 2689.684200]                                         [<ffffffff811b2ffe>] nfs_permission+0x1ae/0x220
[ 2689.684200]                                         [<ffffffff81102f80>] inode_permission+0x60/0xa0
[ 2689.684200]                                         [<ffffffff810f7b7a>] sys_chdir+0x5a/0x90
[ 2689.684200]                                         [<ffffffff818adfd4>] do_mount_root+0x3c/0xab
[ 2689.684200]                                         [<ffffffff818ae4bf>] mount_root+0x138/0x141
[ 2689.684200]                                         [<ffffffff818ae5c0>] prepare_namespace+0xf8/0x198
[ 2689.684200]                                         [<ffffffff818ad6fe>] kernel_init+0x18b/0x1a8
[ 2689.684200]                                         [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]                                         [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]   }
[ 2689.684200]   ... key      at: [<ffffffff817ec710>] nfs_fs_type+0x50/0x80
[ 2689.684200]   ... acquired at:
[ 2689.684200]    [<ffffffff8107bab4>] __lock_acquire+0x15d4/0x1ae0
[ 2689.684200]    [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]    [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]    [<ffffffff8110f8fd>] igrab+0x1d/0x50
[ 2689.684200]    [<ffffffff811c3ded>] nfs_updatepage+0x5fd/0x610
[ 2689.684200]    [<ffffffff811b359c>] nfs_write_end+0x7c/0x2e0
[ 2689.684200]    [<ffffffff810c1b99>] generic_file_buffered_write+0x329/0x3e0
[ 2689.684200]    [<ffffffff810c23ad>] __generic_file_aio_write_nolock+0x51d/0x550
[ 2689.684200]    [<ffffffff810c2f30>] generic_file_aio_write+0x80/0xe0
[ 2689.684200]    [<ffffffff811b4688>] nfs_file_write+0x138/0x230
[ 2689.684200]    [<ffffffff810f8d69>] do_sync_write+0xf9/0x140
[ 2689.684200]    [<ffffffff810f9bf6>] vfs_write+0x116/0x1d0
[ 2689.684200]    [<ffffffff810f9dc7>] sys_write+0x57/0xb0
[ 2689.684200]    [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[ 2689.684200]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200]   -> (&inode->i_data.tree_lock){....-.} ops: 0 {
[ 2689.684200]      IN-RECLAIM_FS-W at:
[ 2689.684200]                                               [<ffffffff8107b142>] __lock_acquire+0xc62/0x1ae0
[ 2689.684200]                                               [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                               [<ffffffff81565363>] _spin_lock_irq+0x43/0x80
[ 2689.684200]                                               [<ffffffff810ceda5>] __remove_mapping+0xb5/0x1e0
[ 2689.684200]                                               [<ffffffff810cf7d1>] shrink_page_list+0x5d1/0xa70
[ 2689.684200]                                               [<ffffffff810d03fe>] shrink_list+0x2be/0x660
[ 2689.684200]                                               [<ffffffff810d09a1>] shrink_zone+0x201/0x400
[ 2689.684200]                                               [<ffffffff810d1709>] kswapd+0x729/0x7a0
[ 2689.684200]                                               [<ffffffff8106555b>] kthread+0x5b/0xa0
[ 2689.684200]                                               [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]                                               [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]      INITIAL USE at:
[ 2689.684200]                                           [<ffffffff8107a67f>] __lock_acquire+0x19f/0x1ae0
[ 2689.684200]                                           [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                           [<ffffffff81565363>] _spin_lock_irq+0x43/0x80
[ 2689.684200]                                           [<ffffffff810c0b18>] add_to_page_cache_locked+0xd8/0x140
[ 2689.684200]                                           [<ffffffff810c0bc2>] add_to_page_cache_lru+0x42/0xb0
[ 2689.684200]                                           [<ffffffff810c0da8>] read_cache_page_async+0x78/0x200
[ 2689.684200]                                           [<ffffffff810c0f43>] read_cache_page+0x13/0x90
[ 2689.684200]                                           [<ffffffff8114bb89>] read_dev_sector+0x49/0xe0
[ 2689.684200]                                           [<ffffffff8114cd03>] msdos_partition+0x53/0x720
[ 2689.684200]                                           [<ffffffff8114c9e6>] rescan_partitions+0x176/0x3b0
[ 2689.684200]                                           [<ffffffff811296cb>] __blkdev_get+0x19b/0x420
[ 2689.684200]                                           [<ffffffff81129960>] blkdev_get+0x10/0x20
[ 2689.684200]                                           [<ffffffff8114bd6c>] register_disk+0x14c/0x170
[ 2689.684200]                                           [<ffffffff8126b84d>] add_disk+0x17d/0x210
[ 2689.684200]                                           [<ffffffff81353c13>] sd_probe_async+0x1d3/0x2d0
[ 2689.684200]                                           [<ffffffff8106d47a>] async_thread+0x10a/0x250
[ 2689.684200]                                           [<ffffffff8106555b>] kthread+0x5b/0xa0
[ 2689.684200]                                           [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]                                           [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]    }
[ 2689.684200]    ... key      at: [<ffffffff822d1304>] __key.28593+0x0/0x8
[ 2689.684200]    -> (&rnp->lock){..-.-.} ops: 0 {
[ 2689.684200]       IN-SOFTIRQ-W at:
[ 2689.684200]                                              [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]       IN-RECLAIM_FS-W at:
[ 2689.684200]                                                 [<ffffffff8107b142>] __lock_acquire+0xc62/0x1ae0
[ 2689.684200]                                                 [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                                 [<ffffffff815653f6>] _spin_lock_irqsave+0x56/0xa0
[ 2689.684200]                                                 [<ffffffff810a1630>] __call_rcu+0x130/0x170
[ 2689.684200]                                                 [<ffffffff810a16a5>] call_rcu+0x15/0x20
[ 2689.684200]                                                 [<ffffffff81277148>] radix_tree_delete+0x148/0x2c0
[ 2689.684200]                                                 [<ffffffff810c2fb6>] __remove_from_page_cache+0x26/0x110
[ 2689.684200]                                                 [<ffffffff810cee90>] __remove_mapping+0x1a0/0x1e0
[ 2689.684200]                                                 [<ffffffff810cf7d1>] shrink_page_list+0x5d1/0xa70
[ 2689.684200]                                                 [<ffffffff810d03fe>] shrink_list+0x2be/0x660
[ 2689.684200]                                                 [<ffffffff810d09a1>] shrink_zone+0x201/0x400
[ 2689.684200]                                                 [<ffffffff810d1709>] kswapd+0x729/0x7a0
[ 2689.684200]                                                 [<ffffffff8106555b>] kthread+0x5b/0xa0
[ 2689.684200]                                                 [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]                                                 [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]       INITIAL USE at:
[ 2689.684200]                                             [<ffffffff8107a67f>] __lock_acquire+0x19f/0x1ae0
[ 2689.684200]                                             [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                             [<ffffffff815653f6>] _spin_lock_irqsave+0x56/0xa0
[ 2689.684200]                                             [<ffffffff8155f286>] rcu_init_percpu_data+0x2f/0x157
[ 2689.684200]                                             [<ffffffff8155f3eb>] rcu_cpu_notify+0x3d/0x86
[ 2689.684200]                                             [<ffffffff818c5351>] __rcu_init+0x184/0x186
[ 2689.684200]                                             [<ffffffff818c3259>] rcu_init+0x9/0x17
[ 2689.684200]                                             [<ffffffff818adbcd>] start_kernel+0x20a/0x44f
[ 2689.684200]                                             [<ffffffff818ad299>] x86_64_start_reservations+0x99/0xb9
[ 2689.684200]                                             [<ffffffff818ad3b0>] x86_64_start_kernel+0xf7/0x122
[ 2689.684200]                                             [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]     }
[ 2689.684200]     ... key      at: [<ffffffff822a6168>] __key.18709+0x0/0x8
[ 2689.684200]    ... acquired at:
[ 2689.684200]    [<ffffffff8107bab4>] __lock_acquire+0x15d4/0x1ae0
[ 2689.684200]    [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]    [<ffffffff815653f6>] _spin_lock_irqsave+0x56/0xa0
[ 2689.684200]    [<ffffffff810a1630>] __call_rcu+0x130/0x170
[ 2689.684200]    [<ffffffff810a16a5>] call_rcu+0x15/0x20
[ 2689.684200]    [<ffffffff812771ff>] radix_tree_delete+0x1ff/0x2c0
[ 2689.684200]    [<ffffffff810c2fb6>] __remove_from_page_cache+0x26/0x110
[ 2689.684200]    [<ffffffff810c30ee>] remove_from_page_cache+0x4e/0x70
[ 2689.684200]    [<ffffffff810cda62>] truncate_complete_page+0x72/0xc0
[ 2689.684200]    [<ffffffff810cdc97>] truncate_inode_pages_range+0x1e7/0x4f0
[ 2689.684200]    [<ffffffff810cdfb5>] truncate_inode_pages+0x15/0x20
[ 2689.684200]    [<ffffffff81129346>] __blkdev_put+0xe6/0x210
[ 2689.684200]    [<ffffffff81129480>] blkdev_put+0x10/0x20
[ 2689.684200]    [<ffffffff8112951a>] close_bdev_exclusive+0x2a/0x40
[ 2689.684200]    [<ffffffff8122ec57>] btrfs_scan_one_device+0xb7/0x170
[ 2689.684200]    [<ffffffff811e9609>] btrfs_get_sb+0xa9/0x560
[ 2689.684200]    [<ffffffff810fb0f0>] vfs_kern_mount+0x50/0xd0
[ 2689.684200]    [<ffffffff810fb1e5>] do_kern_mount+0x55/0x130
[ 2689.684200]    [<ffffffff81116907>] do_mount+0x2b7/0x8f0
[ 2689.684200]    [<ffffffff8111701b>] sys_mount+0xdb/0x110
[ 2689.684200]    [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[ 2689.684200]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200]    -> (key#4){......} ops: 0 {
[ 2689.684200]       INITIAL USE at:
[ 2689.684200]                                             [<ffffffff8107a67f>] __lock_acquire+0x19f/0x1ae0
[ 2689.684200]                                             [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                             [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]                                             [<ffffffff812898d8>] __percpu_counter_add+0x58/0x80
[ 2689.684200]                                             [<ffffffff810cb003>] account_page_dirtied+0x53/0x80
[ 2689.684200]                                             [<ffffffff810cb179>] __set_page_dirty_nobuffers+0x149/0x2a0
[ 2689.684200]                                             [<ffffffff811c392d>] nfs_updatepage+0x13d/0x610
[ 2689.684200]                                             [<ffffffff811b359c>] nfs_write_end+0x7c/0x2e0
[ 2689.684200]                                             [<ffffffff810c1b99>] generic_file_buffered_write+0x329/0x3e0
[ 2689.684200]                                             [<ffffffff810c23ad>] __generic_file_aio_write_nolock+0x51d/0x550
[ 2689.684200]                                             [<ffffffff810c2f30>] generic_file_aio_write+0x80/0xe0
[ 2689.684200]                                             [<ffffffff811b4688>] nfs_file_write+0x138/0x230
[ 2689.684200]                                             [<ffffffff810f8d69>] do_sync_write+0xf9/0x140
[ 2689.684200]                                             [<ffffffff810f9bf6>] vfs_write+0x116/0x1d0
[ 2689.684200]                                             [<ffffffff810f9dc7>] sys_write+0x57/0xb0
[ 2689.684200]                                             [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[ 2689.684200]                                             [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]     }
[ 2689.684200]     ... key      at: [<ffffffff822cea80>] __key.25523+0x0/0x8
[ 2689.684200]    ... acquired at:
[ 2689.684200]    [<ffffffff8107bab4>] __lock_acquire+0x15d4/0x1ae0
[ 2689.684200]    [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]    [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]    [<ffffffff812898d8>] __percpu_counter_add+0x58/0x80
[ 2689.684200]    [<ffffffff810cb003>] account_page_dirtied+0x53/0x80
[ 2689.684200]    [<ffffffff810cb179>] __set_page_dirty_nobuffers+0x149/0x2a0
[ 2689.684200]    [<ffffffff811c392d>] nfs_updatepage+0x13d/0x610
[ 2689.684200]    [<ffffffff811b359c>] nfs_write_end+0x7c/0x2e0
[ 2689.684200]    [<ffffffff810c1b99>] generic_file_buffered_write+0x329/0x3e0
[ 2689.684200]    [<ffffffff810c23ad>] __generic_file_aio_write_nolock+0x51d/0x550
[ 2689.684200]    [<ffffffff810c2f30>] generic_file_aio_write+0x80/0xe0
[ 2689.684200]    [<ffffffff811b4688>] nfs_file_write+0x138/0x230
[ 2689.684200]    [<ffffffff810f8d69>] do_sync_write+0xf9/0x140
[ 2689.684200]    [<ffffffff810f9bf6>] vfs_write+0x116/0x1d0
[ 2689.684200]    [<ffffffff810f9dc7>] sys_write+0x57/0xb0
[ 2689.684200]    [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[ 2689.684200]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200]    -> (key#5){......} ops: 0 {
[ 2689.684200]       INITIAL USE at:
[ 2689.684200]                                             [<ffffffff8107a67f>] __lock_acquire+0x19f/0x1ae0
[ 2689.684200]                                             [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                             [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]                                             [<ffffffff812898d8>] __percpu_counter_add+0x58/0x80
[ 2689.684200]                                             [<ffffffff81276275>] __prop_inc_percpu_max+0xd5/0x120
[ 2689.684200]                                             [<ffffffff810c98b7>] test_clear_page_writeback+0x117/0x190
[ 2689.684200]                                             [<ffffffff810c07c4>] end_page_writeback+0x24/0x60
[ 2689.684200]                                             [<ffffffff811c1c08>] nfs_end_page_writeback+0x28/0x70
[ 2689.684200]                                             [<ffffffff811c2a6c>] nfs_writeback_release_full+0x6c/0x230
[ 2689.684200]                                             [<ffffffff814f7e17>] rpc_release_calldata+0x17/0x20
[ 2689.684200]                                             [<ffffffff814f7e8f>] rpc_free_task+0x3f/0xb0
[ 2689.684200]                                             [<ffffffff814f7ff5>] rpc_async_release+0x15/0x20
[ 2689.684200]                                             [<ffffffff81060520>] worker_thread+0x230/0x3b0
[ 2689.684200]                                             [<ffffffff8106555b>] kthread+0x5b/0xa0
[ 2689.684200]                                             [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]                                             [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]     }
[ 2689.684200]     ... key      at: [<ffffffff822ddea8>] __key.10789+0x0/0x8
[ 2689.684200]    ... acquired at:
[ 2689.684200]    [<ffffffff8107bab4>] __lock_acquire+0x15d4/0x1ae0
[ 2689.684200]    [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]    [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]    [<ffffffff812898d8>] __percpu_counter_add+0x58/0x80
[ 2689.684200]    [<ffffffff81276275>] __prop_inc_percpu_max+0xd5/0x120
[ 2689.684200]    [<ffffffff810c98b7>] test_clear_page_writeback+0x117/0x190
[ 2689.684200]    [<ffffffff810c07c4>] end_page_writeback+0x24/0x60
[ 2689.684200]    [<ffffffff811c1c08>] nfs_end_page_writeback+0x28/0x70
[ 2689.684200]    [<ffffffff811c2a6c>] nfs_writeback_release_full+0x6c/0x230
[ 2689.684200]    [<ffffffff814f7e17>] rpc_release_calldata+0x17/0x20
[ 2689.684200]    [<ffffffff814f7e8f>] rpc_free_task+0x3f/0xb0
[ 2689.684200]    [<ffffffff814f7ff5>] rpc_async_release+0x15/0x20
[ 2689.684200]    [<ffffffff81060520>] worker_thread+0x230/0x3b0
[ 2689.684200]    [<ffffffff8106555b>] kthread+0x5b/0xa0
[ 2689.684200]    [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200]    -> (key#6){......} ops: 0 {
[ 2689.684200]       INITIAL USE at:
[ 2689.684200]                                             [<ffffffff8107a67f>] __lock_acquire+0x19f/0x1ae0
[ 2689.684200]                                             [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                             [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]                                             [<ffffffff812898d8>] __percpu_counter_add+0x58/0x80
[ 2689.684200]                                             [<ffffffff8127628f>] __prop_inc_percpu_max+0xef/0x120
[ 2689.684200]                                             [<ffffffff810c98b7>] test_clear_page_writeback+0x117/0x190
[ 2689.684200]                                             [<ffffffff810c07c4>] end_page_writeback+0x24/0x60
[ 2689.684200]                                             [<ffffffff811c1c08>] nfs_end_page_writeback+0x28/0x70
[ 2689.684200]                                             [<ffffffff811c2a6c>] nfs_writeback_release_full+0x6c/0x230
[ 2689.684200]                                             [<ffffffff814f7e17>] rpc_release_calldata+0x17/0x20
[ 2689.684200]                                             [<ffffffff814f7e8f>] rpc_free_task+0x3f/0xb0
[ 2689.684200]                                             [<ffffffff814f7ff5>] rpc_async_release+0x15/0x20
[ 2689.684200]                                             [<ffffffff81060520>] worker_thread+0x230/0x3b0
[ 2689.684200]                                             [<ffffffff8106555b>] kthread+0x5b/0xa0
[ 2689.684200]                                             [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]                                             [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]     }
[ 2689.684200]     ... key      at: [<ffffffff822ddec0>] __key.10725+0x0/0x8
[ 2689.684200]    ... acquired at:
[ 2689.684200]    [<ffffffff8107bab4>] __lock_acquire+0x15d4/0x1ae0
[ 2689.684200]    [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]    [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]    [<ffffffff812898d8>] __percpu_counter_add+0x58/0x80
[ 2689.684200]    [<ffffffff8127628f>] __prop_inc_percpu_max+0xef/0x120
[ 2689.684200]    [<ffffffff810c98b7>] test_clear_page_writeback+0x117/0x190
[ 2689.684200]    [<ffffffff810c07c4>] end_page_writeback+0x24/0x60
[ 2689.684200]    [<ffffffff811c1c08>] nfs_end_page_writeback+0x28/0x70
[ 2689.684200]    [<ffffffff811c2a6c>] nfs_writeback_release_full+0x6c/0x230
[ 2689.684200]    [<ffffffff814f7e17>] rpc_release_calldata+0x17/0x20
[ 2689.684200]    [<ffffffff814f7e8f>] rpc_free_task+0x3f/0xb0
[ 2689.684200]    [<ffffffff814f7ff5>] rpc_async_release+0x15/0x20
[ 2689.684200]    [<ffffffff81060520>] worker_thread+0x230/0x3b0
[ 2689.684200]    [<ffffffff8106555b>] kthread+0x5b/0xa0
[ 2689.684200]    [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200]   ... acquired at:
[ 2689.684200]    [<ffffffff8107bab4>] __lock_acquire+0x15d4/0x1ae0
[ 2689.684200]    [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]    [<ffffffff815653f6>] _spin_lock_irqsave+0x56/0xa0
[ 2689.684200]    [<ffffffff810c9654>] test_set_page_writeback+0x84/0x1d0
[ 2689.684200]    [<ffffffff811c2190>] nfs_do_writepage+0x120/0x1b0
[ 2689.684200]    [<ffffffff811c294e>] nfs_writepages_callback+0x1e/0x40
[ 2689.684200]    [<ffffffff810ca11f>] write_cache_pages+0x3ff/0x4b0
[ 2689.684200]    [<ffffffff811c2898>] nfs_writepages+0xe8/0x180
[ 2689.684200]    [<ffffffff810ca230>] do_writepages+0x30/0x50
[ 2689.684200]    [<ffffffff810c17d9>] __filemap_fdatawrite_range+0x59/0x70
[ 2689.684200]    [<ffffffff810c2bdf>] filemap_fdatawrite+0x1f/0x30
[ 2689.684200]    [<ffffffff810c2c2d>] filemap_write_and_wait+0x3d/0x60
[ 2689.684200]    [<ffffffff811b6cab>] nfs_sync_mapping+0x3b/0x50
[ 2689.684200]    [<ffffffff811b3ad8>] do_unlk+0x38/0xa0
[ 2689.684200]    [<ffffffff811b3e1e>] nfs_lock+0x11e/0x200
[ 2689.684200]    [<ffffffff811388b3>] vfs_lock_file+0x23/0x50
[ 2689.684200]    [<ffffffff81138af7>] fcntl_setlk+0x157/0x350
[ 2689.684200]    [<ffffffff81108daa>] sys_fcntl+0xca/0x480
[ 2689.684200]    [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[ 2689.684200]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200]   -> (&q->lock){-.-.-.} ops: 0 {
[ 2689.684200]      IN-HARDIRQ-W at:
[ 2689.684200]                                            [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]      IN-SOFTIRQ-W at:
[ 2689.684200]                                            [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]      IN-RECLAIM_FS-W at:
[ 2689.684200]                                               [<ffffffff8107b142>] __lock_acquire+0xc62/0x1ae0
[ 2689.684200]                                               [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                               [<ffffffff815653f6>] _spin_lock_irqsave+0x56/0xa0
[ 2689.684200]                                               [<ffffffff81065d31>] prepare_to_wait+0x31/0x90
[ 2689.684200]                                               [<ffffffff810d10e0>] kswapd+0x100/0x7a0
[ 2689.684200]                                               [<ffffffff8106555b>] kthread+0x5b/0xa0
[ 2689.684200]                                               [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]                                               [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]      INITIAL USE at:
[ 2689.684200]                                           [<ffffffff8107a67f>] __lock_acquire+0x19f/0x1ae0
[ 2689.684200]                                           [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                           [<ffffffff81565363>] _spin_lock_irq+0x43/0x80
[ 2689.684200]                                           [<ffffffff81561cab>] wait_for_common+0x4b/0x1d0
[ 2689.684200]                                           [<ffffffff81561eed>] wait_for_completion+0x1d/0x20
[ 2689.684200]                                           [<ffffffff8106581f>] kthread_create+0xaf/0x180
[ 2689.684200]                                           [<ffffffff8155db79>] migration_call+0x1a6/0x5d2
[ 2689.684200]                                           [<ffffffff818c1f50>] migration_init+0x2e/0x7f
[ 2689.684200]                                           [<ffffffff8100904f>] do_one_initcall+0x3f/0x1d0
[ 2689.684200]                                           [<ffffffff818ad5e0>] kernel_init+0x6d/0x1a8
[ 2689.684200]                                           [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]                                           [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]    }
[ 2689.684200]    ... key      at: [<ffffffff81b4bdc8>] __key.19111+0x0/0x18
[ 2689.684200]    -> (&rq->lock){-.-.-.} ops: 0 {
[ 2689.684200]       IN-HARDIRQ-W at:
[ 2689.684200]                                              [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]       IN-SOFTIRQ-W at:
[ 2689.684200]                                              [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]       IN-RECLAIM_FS-W at:
[ 2689.684200]                                                 [<ffffffff8107b142>] __lock_acquire+0xc62/0x1ae0
[ 2689.684200]                                                 [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                                 [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]                                                 [<ffffffff8103a3c3>] task_rq_lock+0x63/0xc0
[ 2689.684200]                                                 [<ffffffff81045c29>] set_cpus_allowed_ptr+0x39/0x160
[ 2689.684200]                                                 [<ffffffff810d105f>] kswapd+0x7f/0x7a0
[ 2689.684200]                                                 [<ffffffff8106555b>] kthread+0x5b/0xa0
[ 2689.684200]                                                 [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]                                                 [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]       INITIAL USE at:
[ 2689.684200]                                             [<ffffffff8107a67f>] __lock_acquire+0x19f/0x1ae0
[ 2689.684200]                                             [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                             [<ffffffff815653f6>] _spin_lock_irqsave+0x56/0xa0
[ 2689.684200]                                             [<ffffffff8104210b>] rq_attach_root+0x2b/0x110
[ 2689.684200]                                             [<ffffffff818c2307>] sched_init+0x2bb/0x3c5
[ 2689.684200]                                             [<ffffffff818adb43>] start_kernel+0x180/0x44f
[ 2689.684200]                                             [<ffffffff818ad299>] x86_64_start_reservations+0x99/0xb9
[ 2689.684200]                                             [<ffffffff818ad3b0>] x86_64_start_kernel+0xf7/0x122
[ 2689.684200]                                             [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]     }
[ 2689.684200]     ... key      at: [<ffffffff81b06858>] __key.48842+0x0/0x8
[ 2689.684200]     -> (&vec->lock){-.-.-.} ops: 0 {
[ 2689.684200]        IN-HARDIRQ-W at:
[ 2689.684200]                                                [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]        IN-SOFTIRQ-W at:
[ 2689.684200]                                                [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]        IN-RECLAIM_FS-W at:
[ 2689.684200]                                                   [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]        INITIAL USE at:
[ 2689.684200]                                               [<ffffffff8107a67f>] __lock_acquire+0x19f/0x1ae0
[ 2689.684200]                                               [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                               [<ffffffff815653f6>] _spin_lock_irqsave+0x56/0xa0
[ 2689.684200]                                               [<ffffffff810be9f2>] cpupri_set+0x102/0x1a0
[ 2689.684200]                                               [<ffffffff8103e839>] rq_online_rt+0x49/0x80
[ 2689.684200]                                               [<ffffffff8103826e>] set_rq_online+0x5e/0x80
[ 2689.684200]                                               [<ffffffff810421c8>] rq_attach_root+0xe8/0x110
[ 2689.684200]                                               [<ffffffff818c2307>] sched_init+0x2bb/0x3c5
[ 2689.684200]                                               [<ffffffff818adb43>] start_kernel+0x180/0x44f
[ 2689.684200]                                               [<ffffffff818ad299>] x86_64_start_reservations+0x99/0xb9
[ 2689.684200]                                               [<ffffffff818ad3b0>] x86_64_start_kernel+0xf7/0x122
[ 2689.684200]                                               [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]      }
[ 2689.684200]      ... key      at: [<ffffffff822ce1b8>] __key.15844+0x0/0x8
[ 2689.684200]     ... acquired at:
[ 2689.684200]    [<ffffffff8107bab4>] __lock_acquire+0x15d4/0x1ae0
[ 2689.684200]    [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]    [<ffffffff815653f6>] _spin_lock_irqsave+0x56/0xa0
[ 2689.684200]    [<ffffffff810be9f2>] cpupri_set+0x102/0x1a0
[ 2689.684200]    [<ffffffff8103e839>] rq_online_rt+0x49/0x80
[ 2689.684200]    [<ffffffff8103826e>] set_rq_online+0x5e/0x80
[ 2689.684200]    [<ffffffff810421c8>] rq_attach_root+0xe8/0x110
[ 2689.684200]    [<ffffffff818c2307>] sched_init+0x2bb/0x3c5
[ 2689.684200]    [<ffffffff818adb43>] start_kernel+0x180/0x44f
[ 2689.684200]    [<ffffffff818ad299>] x86_64_start_reservations+0x99/0xb9
[ 2689.684200]    [<ffffffff818ad3b0>] x86_64_start_kernel+0xf7/0x122
[ 2689.684200]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200]     -> (&rt_b->rt_runtime_lock){-.-.-.} ops: 0 {
[ 2689.684200]        IN-HARDIRQ-W at:
[ 2689.684200]                                                [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]        IN-SOFTIRQ-W at:
[ 2689.684200]                                                [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]        IN-RECLAIM_FS-W at:
[ 2689.684200]                                                   [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]        INITIAL USE at:
[ 2689.684200]                                               [<ffffffff8107a67f>] __lock_acquire+0x19f/0x1ae0
[ 2689.684200]                                               [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                               [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]                                               [<ffffffff8103f294>] enqueue_task_rt+0x254/0x300
[ 2689.684200]                                               [<ffffffff810391f6>] enqueue_task+0x86/0xa0
[ 2689.684200]                                               [<ffffffff8103923d>] activate_task+0x2d/0x40
[ 2689.684200]                                               [<ffffffff81040610>] try_to_wake_up+0x1b0/0x320
[ 2689.684200]                                               [<ffffffff810407d5>] wake_up_process+0x15/0x20
[ 2689.684200]                                               [<ffffffff8155da30>] migration_call+0x5d/0x5d2
[ 2689.684200]                                               [<ffffffff818c1f87>] migration_init+0x65/0x7f
[ 2689.684200]                                               [<ffffffff8100904f>] do_one_initcall+0x3f/0x1d0
[ 2689.684200]                                               [<ffffffff818ad5e0>] kernel_init+0x6d/0x1a8
[ 2689.684200]                                               [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]                                               [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]      }
[ 2689.684200]      ... key      at: [<ffffffff81b06860>] __key.39064+0x0/0x8
[ 2689.684200]      -> (&cpu_base->lock){-.-.-.} ops: 0 {
[ 2689.684200]         IN-HARDIRQ-W at:
[ 2689.684200]                                                  [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]         IN-SOFTIRQ-W at:
[ 2689.684200]                                                  [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]         IN-RECLAIM_FS-W at:
[ 2689.684200]                                                     [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]         INITIAL USE at:
[ 2689.684200]                                                 [<ffffffff8107a67f>] __lock_acquire+0x19f/0x1ae0
[ 2689.684200]                                                 [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                                 [<ffffffff815653f6>] _spin_lock_irqsave+0x56/0xa0
[ 2689.684200]                                                 [<ffffffff8106981c>] lock_hrtimer_base+0x5c/0x90
[ 2689.684200]                                                 [<ffffffff81069a93>] __hrtimer_start_range_ns+0x43/0x340
[ 2689.684200]                                                 [<ffffffff8103f2e2>] enqueue_task_rt+0x2a2/0x300
[ 2689.684200]                                                 [<ffffffff810391f6>] enqueue_task+0x86/0xa0
[ 2689.684200]                                                 [<ffffffff8103923d>] activate_task+0x2d/0x40
[ 2689.684200]                                                 [<ffffffff81040610>] try_to_wake_up+0x1b0/0x320
[ 2689.684200]                                                 [<ffffffff810407d5>] wake_up_process+0x15/0x20
[ 2689.684200]                                                 [<ffffffff8155da30>] migration_call+0x5d/0x5d2
[ 2689.684200]                                                 [<ffffffff818c1f87>] migration_init+0x65/0x7f
[ 2689.684200]                                                 [<ffffffff8100904f>] do_one_initcall+0x3f/0x1d0
[ 2689.684200]                                                 [<ffffffff818ad5e0>] kernel_init+0x6d/0x1a8
[ 2689.684200]                                                 [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]                                                 [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]       }
[ 2689.684200]       ... key      at: [<ffffffff81b4be10>] __key.21319+0x0/0x8
[ 2689.684200]       -> (&obj_hash[i].lock){-.-.-.} ops: 0 {
[ 2689.684200]          IN-HARDIRQ-W at:
[ 2689.684200]                                                    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]          IN-SOFTIRQ-W at:
[ 2689.684200]                                                    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]          IN-RECLAIM_FS-W at:
[ 2689.684200]                                                       [<ffffffff8107b142>] __lock_acquire+0xc62/0x1ae0
[ 2689.684200]                                                       [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                                       [<ffffffff815653f6>] _spin_lock_irqsave+0x56/0xa0
[ 2689.684200]                                                       [<ffffffff81281dee>] debug_check_no_obj_freed+0x8e/0x200
[ 2689.684200]                                                       [<ffffffff810c7bcc>] free_hot_cold_page+0x14c/0x350
[ 2689.684200]                                                       [<ffffffff810c7e11>] __pagevec_free+0x41/0x60
[ 2689.684200]                                                       [<ffffffff810cf815>] shrink_page_list+0x615/0xa70
[ 2689.684200]                                                       [<ffffffff810d03fe>] shrink_list+0x2be/0x660
[ 2689.684200]                                                       [<ffffffff810d09a1>] shrink_zone+0x201/0x400
[ 2689.684200]                                                       [<ffffffff810d1709>] kswapd+0x729/0x7a0
[ 2689.684200]                                                       [<ffffffff8106555b>] kthread+0x5b/0xa0
[ 2689.684200]                                                       [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]                                                       [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]          INITIAL USE at:
[ 2689.684200]                                                   [<ffffffff8107a67f>] __lock_acquire+0x19f/0x1ae0
[ 2689.684200]                                                   [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                                   [<ffffffff815653f6>] _spin_lock_irqsave+0x56/0xa0
[ 2689.684200]                                                   [<ffffffff812820fc>] __debug_object_init+0x5c/0x410
[ 2689.684200]                                                   [<ffffffff812824ff>] debug_object_init+0x1f/0x30
[ 2689.684200]                                                   [<ffffffff810696ae>] hrtimer_init+0x2e/0x50
[ 2689.684200]                                                   [<ffffffff818c20f7>] sched_init+0xab/0x3c5
[ 2689.684200]                                                   [<ffffffff818adb43>] start_kernel+0x180/0x44f
[ 2689.684200]                                                   [<ffffffff818ad299>] x86_64_start_reserv ations+0x99/0xb9
[ 2689.684200]                                                   [<ffffffff818ad3b0>] x86_64_start_kernel+0xf7/0x122
[ 2689.684200]                                                   [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]        }
[ 2689.684200]        ... key      at: [<ffffffff822ddf08>] __key.20519+0x0/0x8
[ 2689.684200]        -> (pool_lock){..-.-.} ops: 0 {
[ 2689.684200]           IN-SOFTIRQ-W at:
[ 2689.684200]                                                      [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]           IN-RECLAIM_FS-W at:
[ 2689.684200]                                                         [<ffffffff8107b142>] __lock_acquire+0xc62/0x1ae0
[ 2689.684200]                                                         [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                                         [<ffffffff815653f6>] _spin_lock_irqsave+0x56/0xa0
[ 2689.684200]                                                         [<ffffffff81281cd6>] free_object+0x16/0xa0
[ 2689.684200]                                                         [<ffffffff81281f26>] debug_check_no_obj_freed+0x1c6/0x200
[ 2689.684200]                                                         [<ffffffff810c7bcc>] free_hot_cold_page+0x14c/0x350
[ 2689.684200]                                                         [<ffffffff810c7e60>] free_hot_page+0x10/0x20
[ 2689.684200]                                                         [<ffffffff810c7ee2>] __free_pages+0x72/0x80
[ 2689.684200]                                                         [<ffffffff810c7f6b>] free_pages+0x7b/0x80
[ 2689.684200]                                                         [<ffffffff810f47d5>] slob_free+0x155/0x370
[ 2689.684200]                                                         [<ffffffff810f4a25>] __kmem_cache_free+0x35/0x40
[ 2689.684200]                                                         [<ffffffff810f4afc>] kmem_cache_free+0xcc/0xd0
[ 2689.684200]                                                         [<ffffffff81110991>] destroy_inode+0x61/0x70
[ 2689.684200]                                                         [<ffffffff81111079>] generic_delete_inode+0x149/0x190
[ 2689.684200]                                                         [<ffffffff8110fd1d>] iput+0x7d/0x90
[ 2689.684200]                                                         [<ffffffff8114f464>] sysfs_d_iput+0x34/0x40
[ 2689.684200]                                                         [<ffffffff8110c9aa>] dentry_iput+0x8a/0xf0
[ 2689.684200]                                                         [<ffffffff8110cb33>] d_kill+0x33/0x60
[ 2689.684200]                                                         [<ffffffff8110ce33>] __shrink_dcache_sb+0x2d3/0x350
[ 2689.684200]                                                         [<ffffffff8110d00a>] shrink_dcache_memory+0x15a/0x1e0
[ 2689.684200]                                                         [<ffffffff810d0cc5>] shrink_slab+0x125/0x180
[ 2689.684200]                                                         [<ffffffff810d1540>] kswapd+0x560/0x7a0
[ 2689.684200]                                                         [<ffffffff8106555b>] kthread+0x5b/0xa0
[ 2689.684200]                                                         [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]                                                         [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]           INITIAL USE at:
[ 2689.684200]                                                     [<ffffffff8107a67f>] __lock_acquire+0x19f/0x1ae0
[ 2689.684200]                                                     [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                                     [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]                                                     [<ffffffff8128218a>] __debug_object_init+0xea/0x410
[ 2689.684200]                                                     [<ffffffff812824ff>] debug_object_init+0x1f/0x30
[ 2689.684200]                                                     [<ffffffff810696ae>] hrtimer_init+0x2e/0x50
[ 2689.684200]                                                     [<ffffffff818c20f7>] sched_init+0xab/0x3c5
[ 2689.684200]                                                     [<ffffffff818adb43>] start_kernel+0x180/0x44f
[ 2689.684200]                                                     [<ffffffff818ad299>] x86_64_start_reservations+0x99/0xb9
[ 2689.684200]                                                     [<ffffffff818ad3b0>] x86_64_start_kernel+0xf7/0x122
[ 2689.684200]                                                     [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]         }
[ 2689.684200]         ... key      at: [<ffffffff817fe3f8>] pool_lock+0x18/0x40
[ 2689.684200]        ... acquired at:
[ 2689.684200]    [<ffffffff8107bab4>] __lock_acquire+0x15d4/0x1ae0
[ 2689.684200]    [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]    [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]    [<ffffffff8128218a>] __debug_object_init+0xea/0x410
[ 2689.684200]    [<ffffffff812824ff>] debug_object_init+0x1f/0x30
[ 2689.684200]    [<ffffffff810696ae>] hrtimer_init+0x2e/0x50
[ 2689.684200]    [<ffffffff818c20f7>] sched_init+0xab/0x3c5
[ 2689.684200]    [<ffffffff818adb43>] start_kernel+0x180/0x44f
[ 2689.684200]    [<ffffffff818ad299>] x86_64_start_reservations+0x99/0xb9
[ 2689.684200]    [<ffffffff818ad3b0>] x86_64_start_kernel+0xf7/0x122
[ 2689.684200]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200]       ... acquired at:
[ 2689.684200]    [<ffffffff8107bab4>] __lock_acquire+0x15d4/0x1ae0
[ 2689.684200]    [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]    [<ffffffff815653f6>] _spin_lock_irqsave+0x56/0xa0
[ 2689.684200]    [<ffffffff81281bac>] debug_object_activate+0x5c/0x170
[ 2689.684200]    [<ffffffff81068e45>] enqueue_hrtimer+0x35/0xb0
[ 2689.684200]    [<ffffffff81069b3d>] __hrtimer_start_range_ns+0xed/0x340
[ 2689.684200]    [<ffffffff8103f2e2>] enqueue_task_rt+0x2a2/0x300
[ 2689.684200]    [<ffffffff810391f6>] enqueue_task+0x86/0xa0
[ 2689.684200]    [<ffffffff8103923d>] activate_task+0x2d/0x40
[ 2689.684200]    [<ffffffff81040610>] try_to_wake_up+0x1b0/0x320
[ 2689.684200]    [<ffffffff810407d5>] wake_up_process+0x15/0x20
[ 2689.684200]    [<ffffffff8155da30>] migration_call+0x5d/0x5d2
[ 2689.684200]    [<ffffffff818c1f87>] migration_init+0x65/0x7f
[ 2689.684200]    [<ffffffff8100904f>] do_one_initcall+0x3f/0x1d0
[ 2689.684200]    [<ffffffff818ad5e0>] kernel_init+0x6d/0x1a8
[ 2689.684200]    [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200]      ... acquired at:
[ 2689.684200]    [<ffffffff8107bab4>] __lock_acquire+0x15d4/0x1ae0
[ 2689.684200]    [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]    [<ffffffff815653f6>] _spin_lock_irqsave+0x56/0xa0
[ 2689.684200]    [<ffffffff8106981c>] lock_hrtimer_base+0x5c/0x90
[ 2689.684200]    [<ffffffff81069a93>] __hrtimer_start_range_ns+0x43/0x340
[ 2689.684200]    [<ffffffff8103f2e2>] enqueue_task_rt+0x2a2/0x300
[ 2689.684200]    [<ffffffff810391f6>] enqueue_task+0x86/0xa0
[ 2689.684200]    [<ffffffff8103923d>] activate_task+0x2d/0x40
[ 2689.684200]    [<ffffffff81040610>] try_to_wake_up+0x1b0/0x320
[ 2689.684200]    [<ffffffff810407d5>] wake_up_process+0x15/0x20
[ 2689.684200]    [<ffffffff8155da30>] migration_call+0x5d/0x5d2
[ 2689.684200]    [<ffffffff818c1f87>] migration_init+0x65/0x7f
[ 2689.684200]    [<ffffffff8100904f>] do_one_initcall+0x3f/0x1d0
[ 2689.684200]    [<ffffffff818ad5e0>] kernel_init+0x6d/0x1a8
[ 2689.684200]    [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200]      -> (&rt_rq->rt_runtime_lock){-.-.-.} ops: 0 {
[ 2689.684200]         IN-HARDIRQ-W at:
[ 2689.684200]                                                  [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]         IN-SOFTIRQ-W at:
[ 2689.684200]                                                  [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]         IN-RECLAIM_FS-W at:
[ 2689.684200]                                                     [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]         INITIAL USE at:
[ 2689.684200]                                                 [<ffffffff8107a67f>] __lock_acquire+0x19f/0x1ae0
[ 2689.684200]                                                 [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                                 [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]                                                 [<ffffffff8103acaf>] update_curr_rt+0x12f/0x1e0
[ 2689.684200]                                                 [<ffffffff8103eb84>] dequeue_task_rt+0x24/0x90
[ 2689.684200]                                                 [<ffffffff81039a4a>] dequeue_task+0xea/0x140
[ 2689.684200]                                                 [<ffffffff81039acd>] deactivate_task+0x2d/0x40
[ 2689.684200]                                                 [<ffffffff81560eb3>] __schedule+0x243/0x8ce
[ 2689.684200]                                                 [<ffffffff81561a65>] schedule+0x15/0x50
[ 2689.684200]                                                 [<ffffffff8104598c>] migration_thread+0x1cc/0x2f0
[ 2689.684200]                                                 [<ffffffff8106555b>] kthread+0x5b/0xa0
[ 2689.684200]                                                 [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]                                                 [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]       }
[ 2689.684200]       ... key      at: [<ffffffff81b06868>] __key.48822+0x0/0x8
[ 2689.684200]      ... acquired at:
[ 2689.684200]    [<ffffffff8107bab4>] __lock_acquire+0x15d4/0x1ae0
[ 2689.684200]    [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]    [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]    [<ffffffff8103afa4>] __enable_runtime+0x54/0xa0
[ 2689.684200]    [<ffffffff8103e81d>] rq_online_rt+0x2d/0x80
[ 2689.684200]    [<ffffffff8103826e>] set_rq_online+0x5e/0x80
[ 2689.684200]    [<ffffffff8155deba>] migration_call+0x4e7/0x5d2
[ 2689.684200]    [<ffffffff8156879f>] notifier_call_chain+0x3f/0x80
[ 2689.684200]    [<ffffffff8106b326>] raw_notifier_call_chain+0x16/0x20
[ 2689.684200]    [<ffffffff8155e356>] _cpu_up+0x146/0x14b
[ 2689.684200]    [<ffffffff8155e3d7>] cpu_up+0x7c/0x95
[ 2689.684200]    [<ffffffff818ad658>] kernel_init+0xe5/0x1a8
[ 2689.684200]    [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200]     ... acquired at:
[ 2689.684200]    [<ffffffff8107bab4>] __lock_acquire+0x15d4/0x1ae0
[ 2689.684200]    [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]    [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]    [<ffffffff8103f294>] enqueue_task_rt+0x254/0x300
[ 2689.684200]    [<ffffffff810391f6>] enqueue_task+0x86/0xa0
[ 2689.684200]    [<ffffffff8103923d>] activate_task+0x2d/0x40
[ 2689.684200]    [<ffffffff81040610>] try_to_wake_up+0x1b0/0x320
[ 2689.684200]    [<ffffffff810407d5>] wake_up_process+0x15/0x20
[ 2689.684200]    [<ffffffff8155da30>] migration_call+0x5d/0x5d2
[ 2689.684200]    [<ffffffff818c1f87>] migration_init+0x65/0x7f
[ 2689.684200]    [<ffffffff8100904f>] do_one_initcall+0x3f/0x1d0
[ 2689.684200]    [<ffffffff818ad5e0>] kernel_init+0x6d/0x1a8
[ 2689.684200]    [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200]     ... acquired at:
[ 2689.684200]    [<ffffffff8107bab4>] __lock_acquire+0x15d4/0x1ae0
[ 2689.684200]    [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]    [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]    [<ffffffff8103acaf>] update_curr_rt+0x12f/0x1e0
[ 2689.684200]    [<ffffffff8103eb84>] dequeue_task_rt+0x24/0x90
[ 2689.684200]    [<ffffffff81039a4a>] dequeue_task+0xea/0x140
[ 2689.684200]    [<ffffffff81039acd>] deactivate_task+0x2d/0x40
[ 2689.684200]    [<ffffffff81560eb3>] __schedule+0x243/0x8ce
[ 2689.684200]    [<ffffffff81561a65>] schedule+0x15/0x50
[ 2689.684200]    [<ffffffff8104598c>] migration_thread+0x1cc/0x2f0
[ 2689.684200]    [<ffffffff8106555b>] kthread+0x5b/0xa0
[ 2689.684200]    [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200]     -> (&rq->lock/1){..-.-.} ops: 0 {
[ 2689.684200]        IN-SOFTIRQ-W at:
[ 2689.684200]                                                [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]        IN-RECLAIM_FS-W at:
[<ffffffff8123031d>] btrfs_read_sys_array+0x4d/0x1a0
[ 2689.684200]                                            [<ffffffff8120a3f3>] open_ctree+0xbc3/0x11a0
[ 2689.684200]                                            [<ffffffff811e997e>] btrfs_get_sb+0x41e/0x560
[ 2689.684200]                                            [<ffffffff810fb0f0>] vfs_kern_mount+0x50/0xd0
[ 2689.684200]                                            [<ffffffff810fb1e5>] do_kern_mount+0x55/0x130
[ 2689.684200]                                            [<ffffffff81116907>] do_mount+0x2b7/0x8f0
[ 2689.684200]                                            [<ffffffff8111701b>] sys_mount+0xdb/0x110
[ 2689.684200]                                            [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[ 2689.684200]                                            [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]      IN-RECLAIM_FS-W at:
[ 2689.684200]                                               [<ffffffff8107b142>] __lock_acquire+0xc62/0x1ae0
[ 2689.684200]                                               [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                               [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]                                               [<ffffffff812288e5>] test_range_bit+0x35/0x180
[ 2689.684200]                                               [<ffffffff8122ac78>] try_release_extent_state+0x48/0xa0
[ 2689.684200]                                               [<ffffffff81206f9b>] btree_releasepage+0x6b/0xb0
[ 2689.684200]                                               [<ffffffff810bed13>] try_to_release_page+0x63/0x80
[ 2689.684200]                                               [<ffffffff810cf8ba>] shrink_page_list+0x6ba/0xa70
[ 2689.684200]                                               [<ffffffff810d03fe>] shrink_list+0x2be/0x660
[ 2689.684200]                                               [<ffffffff810d09a1>] shrink_zone+0x201/0x400
[ 2689.684200]                                               [<ffffffff810d1709>] kswapd+0x729/0x7a0
[ 2689.684200]                                               [<ffffffff8106555b>] kthread+0x5b/0xa0
[ 2689.684200]                                               [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]                                               [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]      INITIAL USE at:
[ 2689.684200]                                           [<ffffffff8107a67f>] __lock_acquire+0x19f/0x1ae0
[ 2689.684200]                                           [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                           [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]                                           [<ffffffff8122944a>] set_extent_bit+0x5a/0x3c0
[ 2689.684200]                                           [<ffffffff812297d0>] set_extent_uptodate+0x20/0x30
[ 2689.684200]                                           [<ffffffff8122982e>] set_extent_buffer_uptodate+0x4e/0x140
[ 2689.684200]                                           [<ffffffff81206b46>] btrfs_set_buffer_uptodate+0x26/0x30
[ 2689.684200]                                           [<ffffffff8123031d>] btrfs_read_sys_array+0x4d/0x1a0
[ 2689.684200]                                           [<ffffffff8120a3f3>] open_ctree+0xbc3/0x11a0
[ 2689.684200]                                           [<ffffffff811e997e>] btrfs_get_sb+0x41e/0x560
[ 2689.684200]                                           [<ffffffff810fb0f0>] vfs_kern_mount+0x50/0xd0
[ 2689.684200]                                           [<ffffffff810fb1e5>] do_kern_mount+0x55/0x130
[ 2689.684200]                                           [<ffffffff81116907>] do_mount+0x2b7/0x8f0
[ 2689.684200]                                           [<ffffffff8111701b>] sys_mount+0xdb/0x110
[ 2689.684200]                                           [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[ 2689.684200]                                           [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]    }
[ 2689.684200]    ... key      at: [<ffffffff822dd178>] __key.31822+0x0/0x8
[ 2689.684200]    ... acquired at:
[ 2689.684200]    [<ffffffff8107bab4>] __lock_acquire+0x15d4/0x1ae0
[ 2689.684200]    [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]    [<ffffffff815653f6>] _spin_lock_irqsave+0x56/0xa0
[ 2689.684200]    [<ffffffff8103a242>] __wake_up+0x32/0x70
[ 2689.684200]    [<ffffffff8122a705>] clear_state_bit+0x145/0x200
[ 2689.684200]    [<ffffffff8122aa17>] clear_extent_bit+0x257/0x360
[ 2689.684200]    [<ffffffff8122b303>] unlock_extent+0x23/0x30
[ 2689.684200]    [<ffffffff8122c34f>] end_bio_extent_readpage+0x16f/0x220
[ 2689.684200]    [<ffffffff81125b01>] bio_endio+0x21/0x50
[ 2689.684200]    [<ffffffff81208df3>] end_workqueue_fn+0xf3/0x130
[ 2689.684200]    [<ffffffff8123440a>] worker_loop+0x7a/0x200
[ 2689.684200]    [<ffffffff8106555b>] kthread+0x5b/0xa0
[ 2689.684200]    [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200]    ... acquired at:
[ 2689.684200]    [<ffffffff8107bab4>] __lock_acquire+0x15d4/0x1ae0
[ 2689.684200]    [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]    [<ffffffff815653f6>] _spin_lock_irqsave+0x56/0xa0
[ 2689.684200]    [<ffffffff810f4721>] slob_free+0xa1/0x370
[ 2689.684200]    [<ffffffff810f4a25>] __kmem_cache_free+0x35/0x40
[ 2689.684200]    [<ffffffff810f4afc>] kmem_cache_free+0xcc/0xd0
[ 2689.684200]    [<ffffffff81227572>] free_extent_state+0x82/0xa0
[ 2689.684200]    [<ffffffff81229274>] merge_state+0x104/0x110
[ 2689.684200]    [<ffffffff8122a71b>] clear_state_bit+0x15b/0x200
[ 2689.684200]    [<ffffffff8122aa17>] clear_extent_bit+0x257/0x360
[ 2689.684200]    [<ffffffff8122b303>] unlock_extent+0x23/0x30
[ 2689.684200]    [<ffffffff8122c34f>] end_bio_extent_readpage+0x16f/0x220
[ 2689.684200]    [<ffffffff81125b01>] bio_endio+0x21/0x50
[ 2689.684200]    [<ffffffff81208df3>] end_workqueue_fn+0xf3/0x130
[ 2689.684200]    [<ffffffff8123440a>] worker_loop+0x7a/0x200
[ 2689.684200]    [<ffffffff8106555b>] kthread+0x5b/0xa0
[ 2689.684200]    [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200]    ... acquired at:
[ 2689.684200]    [<ffffffff8107bab4>] __lock_acquire+0x15d4/0x1ae0
[ 2689.684200]    [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]    [<ffffffff815653f6>] _spin_lock_irqsave+0x56/0xa0
[ 2689.684200]    [<ffffffff81281dee>] debug_check_no_obj_freed+0x8e/0x200
[ 2689.684200]    [<ffffffff810c7bcc>] free_hot_cold_page+0x14c/0x350
[ 2689.684200]    [<ffffffff810c7e60>] free_hot_page+0x10/0x20
[ 2689.684200]    [<ffffffff810c7ee2>] __free_pages+0x72/0x80
[ 2689.684200]    [<ffffffff810c7f6b>] free_pages+0x7b/0x80
[ 2689.684200]    [<ffffffff810f47d5>] slob_free+0x155/0x370
[ 2689.684200]    [<ffffffff810f4a25>] __kmem_cache_free+0x35/0x40
[ 2689.684200]    [<ffffffff810f4afc>] kmem_cache_free+0xcc/0xd0
[ 2689.684200]    [<ffffffff81227572>] free_extent_state+0x82/0xa0
[ 2689.684200]    [<ffffffff81229274>] merge_state+0x104/0x110
[ 2689.684200]    [<ffffffff8122a71b>] clear_state_bit+0x15b/0x200
[ 2689.684200]    [<ffffffff8122aa17>] clear_extent_bit+0x257/0x360
[ 2689.684200]    [<ffffffff8122b303>] unlock_extent+0x23/0x30
[ 2689.684200]    [<ffffffff8122b950>] __extent_read_full_page+0x640/0x670
[ 2689.684200]    [<ffffffff8122c011>] extent_readpages+0x91/0x210
[ 2689.684200]    [<ffffffff8120f90f>] btrfs_readpages+0x1f/0x30
[ 2689.684200]    [<ffffffff810cba84>] __do_page_cache_readahead+0x184/0x260
[ 2689.684200]    [<ffffffff810cbe8b>] ondemand_readahead+0x1cb/0x250
[ 2689.684200]    [<ffffffff810cbfb9>] page_cache_async_readahead+0xa9/0xc0
[ 2689.684200]    [<ffffffff810c2873>] generic_file_aio_read+0x493/0x7c0
[ 2689.684200]    [<ffffffff810f8ea9>] do_sync_read+0xf9/0x140
[ 2689.684200]    [<ffffffff810f9f33>] vfs_read+0x113/0x1d0
[ 2689.684200]    [<ffffffff810fa107>] sys_read+0x57/0xb0
[ 2689.684200]    [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[ 2689.684200]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200]    ... acquired at:
[ 2689.684200]    [<ffffffff8107bab4>] __lock_acquire+0x15d4/0x1ae0
[ 2689.684200]    [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]    [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]    [<ffffffff810c6118>] free_pages_bulk+0x38/0x3b0
[ 2689.684200]    [<ffffffff810c7d9a>] free_hot_cold_page+0x31a/0x350
[ 2689.684200]    [<ffffffff810c7e60>] free_hot_page+0x10/0x20
[ 2689.684200]    [<ffffffff810c7ee2>] __free_pages+0x72/0x80
[ 2689.684200]    [<ffffffff810c7f6b>] free_pages+0x7b/0x80
[ 2689.684200]    [<ffffffff810f47d5>] slob_free+0x155/0x370
[ 2689.684200]    [<ffffffff810f4a25>] __kmem_cache_free+0x35/0x40
[ 2689.684200]    [<ffffffff810f4afc>] kmem_cache_free+0xcc/0xd0
[ 2689.684200]    [<ffffffff81227572>] free_extent_state+0x82/0xa0
[ 2689.684200]    [<ffffffff8122a6cd>] clear_state_bit+0x10d/0x200
[ 2689.684200]    [<ffffffff8122aaf9>] clear_extent_bit+0x339/0x360
[ 2689.684200]    [<ffffffff8122acb3>] try_release_extent_state+0x83/0xa0
[ 2689.684200]    [<ffffffff8122ae43>] try_release_extent_mapping+0x173/0x1a0
[ 2689.684200]    [<ffffffff8120f86b>] __btrfs_releasepage+0x3b/0x80
[ 2689.684200]    [<ffffffff8120f8e0>] btrfs_releasepage+0x30/0x40
[ 2689.684200]    [<ffffffff810bed13>] try_to_release_page+0x63/0x80
[ 2689.684200]    [<ffffffff810cf8ba>] shrink_page_list+0x6ba/0xa70
[ 2689.684200]    [<ffffffff810d03fe>] shrink_list+0x2be/0x660
[ 2689.684200]    [<ffffffff810d09a1>] shrink_zone+0x201/0x400
[ 2689.684200]    [<ffffffff810d1709>] kswapd+0x729/0x7a0
[ 2689.684200]    [<ffffffff8106555b>] kthread+0x5b/0xa0
[ 2689.684200]    [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200]   ... acquired at:
[ 2689.684200]    [<ffffffff8107bab4>] __lock_acquire+0x15d4/0x1ae0
[ 2689.684200]    [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]    [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]    [<ffffffff812288e5>] test_range_bit+0x35/0x180
[ 2689.684200]    [<ffffffff8122ae04>] try_release_extent_mapping+0x134/0x1a0
[ 2689.684200]    [<ffffffff8120f86b>] __btrfs_releasepage+0x3b/0x80
[ 2689.684200]    [<ffffffff8120f8e0>] btrfs_releasepage+0x30/0x40
[ 2689.684200]    [<ffffffff810bed13>] try_to_release_page+0x63/0x80
[ 2689.684200]    [<ffffffff810cf8ba>] shrink_page_list+0x6ba/0xa70
[ 2689.684200]    [<ffffffff810d03fe>] shrink_list+0x2be/0x660
[ 2689.684200]    [<ffffffff810d09a1>] shrink_zone+0x201/0x400
[ 2689.684200]    [<ffffffff810d1709>] kswapd+0x729/0x7a0
[ 2689.684200]    [<ffffffff8106555b>] kthread+0x5b/0xa0
[ 2689.684200]    [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200]  ... acquired at:
[ 2689.684200]    [<ffffffff8107bab4>] __lock_acquire+0x15d4/0x1ae0
[ 2689.684200]    [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]    [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]    [<ffffffff8121858d>] btrfs_drop_extent_cache+0x25d/0x3b0
[ 2689.684200]    [<ffffffff8120e26a>] btrfs_destroy_inode+0x17a/0x250
[ 2689.684200]    [<ffffffff8111097d>] destroy_inode+0x4d/0x70
[ 2689.684200]    [<ffffffff81110a51>] dispose_list+0xb1/0x120
[ 2689.684200]    [<ffffffff81110d4f>] shrink_icache_memory+0x28f/0x300
[ 2689.684200]    [<ffffffff810d0cc5>] shrink_slab+0x125/0x180
[ 2689.684200]    [<ffffffff810d1540>] kswapd+0x560/0x7a0
[ 2689.684200]    [<ffffffff8106555b>] kthread+0x5b/0xa0
[ 2689.684200]    [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200]  -> (&journal->j_list_lock){+.+.-.} ops: 0 {
[ 2689.684200]     HARDIRQ-ON-W at:
[ 2689.684200]                                          [<ffffffff8107b005>] __lock_acquire+0xb25/0x1ae0
[ 2689.684200]                                          [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                          [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]                                          [<ffffffff811a9047>] jbd2_journal_release_jbd_inode+0xb7/0x100
[ 2689.684200]                                          [<ffffffff8117f99c>] ext4_clear_inode+0x3c/0x50
[ 2689.684200]                                          [<ffffffff8111076e>] clear_inode+0xfe/0x170
[ 2689.684200]                                          [<ffffffff811109d8>] dispose_list+0x38/0x120
[ 2689.684200]                                          [<ffffffff81110d4f>] shrink_icache_memory+0x28f/0x300
[ 2689.684200]                                          [<ffffffff810d0cc5>] shrink_slab+0x125/0x180
[ 2689.684200]                                          [<ffffffff810d1e16>] try_to_free_pages+0x276/0x400
[ 2689.684200]                                          [<ffffffff810c8ed6>] __alloc_pages_internal+0x2b6/0x650
[ 2689.684200]                                          [<ffffffff810f2e9c>] alloc_pages_current+0x8c/0xe0
[ 2689.684200]                                          [<ffffffff810f4c5b>] slob_new_pages+0x11b/0x130
[ 2689.684200]                                          [<ffffffff810f4f12>] kmem_cache_alloc_node+0x52/0x1a0
[ 2689.684200]                                          [<ffffffff811050a0>] getname+0x40/0x260
[ 2689.684200]                                          [<ffffffff81107790>] user_path_at+0x30/0xe0
[ 2689.684200]                                          [<ffffffff810fd9ba>] vfs_lstat_fd+0x2a/0x60
[ 2689.684200]                                          [<ffffffff810fdbec>] sys_newfstatat+0x5c/0x80
[ 2689.684200]                                          [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[ 2689.684200]                                          [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]     SOFTIRQ-ON-W at:
[ 2689.684200]                                          [<ffffffff8107b031>] __lock_acquire+0xb51/0x1ae0
[ 2689.684200]                                          [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                          [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]                                          [<ffffffff811a9047>] jbd2_journal_release_jbd_inode+0xb7/0x100
[ 2689.684200]                                          [<ffffffff8117f99c>] ext4_clear_inode+0x3c/0x50
[ 2689.684200]                                          [<ffffffff8111076e>] clear_inode+0xfe/0x170
[ 2689.684200]                                          [<ffffffff811109d8>] dispose_list+0x38/0x120
[ 2689.684200]                                          [<ffffffff81110d4f>] shrink_icache_memory+0x28f/0x300
[ 2689.684200]                                          [<ffffffff810d0cc5>] shrink_slab+0x125/0x180
[ 2689.684200]                                          [<ffffffff810d1e16>] try_to_free_pages+0x276/0x400
[ 2689.684200]                                          [<ffffffff810c8ed6>] __alloc_pages_internal+0x2b6/0x650
[ 2689.684200]                                          [<ffffffff810f2e9c>] alloc_pages_current+0x8c/0xe0
[ 2689.684200]                                          [<ffffffff810f4c5b>] slob_new_pages+0x11b/0x130
[ 2689.684200]                                          [<ffffffff810f4f12>] kmem_cache_alloc_node+0x52/0x1a0
[ 2689.684200]                                          [<ffffffff811050a0>] getname+0x40/0x260
[ 2689.684200]                                          [<ffffffff81107790>] user_path_at+0x30/0xe0
[ 2689.684200]                                          [<ffffffff810fd9ba>] vfs_lstat_fd+0x2a/0x60
[ 2689.684200]                                          [<ffffffff810fdbec>] sys_newfstatat+0x5c/0x80
[ 2689.684200]                                          [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[ 2689.684200]                                          [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]     IN-RECLAIM_FS-W at:
[ 2689.684200]                                             [<ffffffff8107b142>] __lock_acquire+0xc62/0x1ae0
[ 2689.684200]                                             [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                             [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]                                             [<ffffffff811a9047>] jbd2_journal_release_jbd_inode+0xb7/0x100
[ 2689.684200]                                             [<ffffffff8117f99c>] ext4_clear_inode+0x3c/0x50
[ 2689.684200]                                             [<ffffffff8111076e>] clear_inode+0xfe/0x170
[ 2689.684200]                                             [<ffffffff811109d8>] dispose_list+0x38/0x120
[ 2689.684200]                                             [<ffffffff81110d4f>] shrink_icache_memory+0x28f/0x300
[ 2689.684200]                                             [<ffffffff810d0cc5>] shrink_slab+0x125/0x180
[ 2689.684200]                                             [<ffffffff810d1e16>] try_to_free_pages+0x276/0x400
[ 2689.684200]                                             [<ffffffff810c8ed6>] __alloc_pages_internal+0x2b6/0x650
[ 2689.684200]                                             [<ffffffff810f2e9c>] alloc_pages_current+0x8c/0xe0
[ 2689.684200]                                             [<ffffffff810f4c5b>] slob_new_pages+0x11b/0x130
[ 2689.684200]                                             [<ffffffff810f4f12>] kmem_cache_alloc_node+0x52/0x1a0
[ 2689.684200]                                             [<ffffffff811050a0>] getname+0x40/0x260
[ 2689.684200]                                             [<ffffffff81107790>] user_path_at+0x30/0xe0
[ 2689.684200]                                             [<ffffffff810fd9ba>] vfs_lstat_fd+0x2a/0x60
[ 2689.684200]                                             [<ffffffff810fdbec>] sys_newfstatat+0x5c/0x80
[ 2689.684200]                                             [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[ 2689.684200]                                             [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]     INITIAL USE at:
[ 2689.684200]                                         [<ffffffff8107a67f>] __lock_acquire+0x19f/0x1ae0
[ 2689.684200]                                         [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                         [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]                                         [<ffffffff811a9047>] jbd2_journal_release_jbd_inode+0xb7/0x100
[ 2689.684200]                                         [<ffffffff8117f99c>] ext4_clear_inode+0x3c/0x50
[ 2689.684200]                                         [<ffffffff8111076e>] clear_inode+0xfe/0x170
[ 2689.684200]                                         [<ffffffff811109d8>] dispose_list+0x38/0x120
[ 2689.684200]                                         [<ffffffff81110d4f>] shrink_icache_memory+0x28f/0x300
[ 2689.684200]                                         [<ffffffff810d0cc5>] shrink_slab+0x125/0x180
[ 2689.684200]                                         [<ffffffff810d1e16>] try_to_free_pages+0x276/0x400
[ 2689.684200]                                         [<ffffffff810c8ed6>] __alloc_pages_internal+0x2b6/0x650
[ 2689.684200]                                         [<ffffffff810f2e9c>] alloc_pages_current+0x8c/0xe0
[ 2689.684200]                                         [<ffffffff810f4c5b>] slob_new_pages+0x11b/0x130
[ 2689.684200]                                         [<ffffffff810f4f12>] kmem_cache_alloc_node+0x52/0x1a0
[ 2689.684200]                                         [<ffffffff811050a0>] getname+0x40/0x260
[ 2689.684200]                                         [<ffffffff81107790>] user_path_at+0x30/0xe0
[ 2689.684200]                                         [<ffffffff810fd9ba>] vfs_lstat_fd+0x2a/0x60
[ 2689.684200]                                         [<ffffffff810fdbec>] sys_newfstatat+0x5c/0x80
[ 2689.684200]                                         [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[ 2689.684200]                                         [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]   }
[ 2689.684200]   ... key      at: [<ffffffff822d2bf8>] __key.26375+0x0/0x8
[ 2689.684200]  ... acquired at:
[ 2689.684200]    [<ffffffff8107bab4>] __lock_acquire+0x15d4/0x1ae0
[ 2689.684200]    [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]    [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]    [<ffffffff811a9047>] jbd2_journal_release_jbd_inode+0xb7/0x100
[ 2689.684200]    [<ffffffff8117f99c>] ext4_clear_inode+0x3c/0x50
[ 2689.684200]    [<ffffffff8111076e>] clear_inode+0xfe/0x170
[ 2689.684200]    [<ffffffff811109d8>] dispose_list+0x38/0x120
[ 2689.684200]    [<ffffffff81110d4f>] shrink_icache_memory+0x28f/0x300
[ 2689.684200]    [<ffffffff810d0cc5>] shrink_slab+0x125/0x180
[ 2689.684200]    [<ffffffff810d1e16>] try_to_free_pages+0x276/0x400
[ 2689.684200]    [<ffffffff810c8ed6>] __alloc_pages_internal+0x2b6/0x650
[ 2689.684200]    [<ffffffff810f2e9c>] alloc_pages_current+0x8c/0xe0
[ 2689.684200]    [<ffffffff810f4c5b>] slob_new_pages+0x11b/0x130
[ 2689.684200]    [<ffffffff810f4f12>] kmem_cache_alloc_node+0x52/0x1a0
[ 2689.684200]    [<ffffffff811050a0>] getname+0x40/0x260
[ 2689.684200]    [<ffffffff81107790>] user_path_at+0x30/0xe0
[ 2689.684200]    [<ffffffff810fd9ba>] vfs_lstat_fd+0x2a/0x60
[ 2689.684200]    [<ffffffff810fdbec>] sys_newfstatat+0x5c/0x80
[ 2689.684200]    [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[ 2689.684200]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200]  -> (&ei->i_prealloc_lock){+.+.-.} ops: 0 {
[ 2689.684200]     HARDIRQ-ON-W at:
[ 2689.684200]                                          [<ffffffff8107b005>] __lock_acquire+0xb25/0x1ae0
[ 2689.684200]                                          [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                          [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]                                          [<ffffffff81192781>] ext4_discard_preallocations+0xd1/0x4a0
[ 2689.684200]                                          [<ffffffff8117f976>] ext4_clear_inode+0x16/0x50
[ 2689.684200]                                          [<ffffffff8111076e>] clear_inode+0xfe/0x170
[ 2689.684200]                                          [<ffffffff811109d8>] dispose_list+0x38/0x120
[ 2689.684200]                                          [<ffffffff81110d4f>] shrink_icache_memory+0x28f/0x300
[ 2689.684200]                                          [<ffffffff810d0cc5>] shrink_slab+0x125/0x180
[ 2689.684200]                                          [<ffffffff810d1e16>] try_to_free_pages+0x276/0x400
[ 2689.684200]                                          [<ffffffff810c8ed6>] __alloc_pages_internal+0x2b6/0x650
[ 2689.684200]                                          [<ffffffff810f2e9c>] alloc_pages_current+0x8c/0xe0
[ 2689.684200]                                          [<ffffffff810f4c5b>] slob_new_pages+0x11b/0x130
[ 2689.684200]                                          [<ffffffff810f4f12>] kmem_cache_alloc_node+0x52/0x1a0
[ 2689.684200]                                          [<ffffffff811050a0>] getname+0x40/0x260
[ 2689.684200]                                          [<ffffffff81107790>] user_path_at+0x30/0xe0
[ 2689.684200]                                          [<ffffffff810fd9ba>] vfs_lstat_fd+0x2a/0x60
[ 2689.684200]                                          [<ffffffff810fdbec>] sys_newfstatat+0x5c/0x80
[ 2689.684200]                                          [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[ 2689.684200]                                          [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]     SOFTIRQ-ON-W at:
[ 2689.684200]                                          [<ffffffff8107b031>] __lock_acquire+0xb51/0x1ae0
[ 2689.684200]                                          [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                          [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]                                          [<ffffffff81192781>] ext4_discard_preallocations+0xd1/0x4a0
[ 2689.684200]                                          [<ffffffff8117f976>] ext4_clear_inode+0x16/0x50
[ 2689.684200]                                          [<ffffffff8111076e>] clear_inode+0xfe/0x170
[ 2689.684200]                                          [<ffffffff811109d8>] dispose_list+0x38/0x120
[ 2689.684200]                                          [<ffffffff81110d4f>] shrink_icache_memory+0x28f/0x300
[ 2689.684200]                                          [<ffffffff810d0cc5>] shrink_slab+0x125/0x180
[ 2689.684200]                                          [<ffffffff810d1e16>] try_to_free_pages+0x276/0x400
[ 2689.684200]                                          [<ffffffff810c8ed6>] __alloc_pages_internal+0x2b6/0x650
[ 2689.684200]                                          [<ffffffff810f2e9c>] alloc_pages_current+0x8c/0xe0
[ 2689.684200]                                          [<ffffffff810f4c5b>] slob_new_pages+0x11b/0x130
[ 2689.684200]                                          [<ffffffff810f4f12>] kmem_cache_alloc_node+0x52/0x1a0
[ 2689.684200]                                          [<ffffffff811050a0>] getname+0x40/0x260
[ 2689.684200]                                          [<ffffffff81107790>] user_path_at+0x30/0xe0
[ 2689.684200]                                          [<ffffffff810fd9ba>] vfs_lstat_fd+0x2a/0x60
[ 2689.684200]                                          [<ffffffff810fdbec>] sys_newfstatat+0x5c/0x80
[ 2689.684200]                                          [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[ 2689.684200]                                          [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]     IN-RECLAIM_FS-W at:
[ 2689.684200]                                             [<ffffffff8107b142>] __lock_acquire+0xc62/0x1ae0
[ 2689.684200]                                             [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                             [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]                                             [<ffffffff81192781>] ext4_discard_preallocations+0xd1/0x4a0
[ 2689.684200]                                             [<ffffffff8117f976>] ext4_clear_inode+0x16/0x50
[ 2689.684200]                                             [<ffffffff8111076e>] clear_inode+0xfe/0x170
[ 2689.684200]                                             [<ffffffff811109d8>] dispose_list+0x38/0x120
[ 2689.684200]                                             [<ffffffff81110d4f>] shrink_icache_memory+0x28f/0x300
[ 2689.684200]                                             [<ffffffff810d0cc5>] shrink_slab+0x125/0x180
[ 2689.684200]                                             [<ffffffff810d1e16>] try_to_free_pages+0x276/0x400
[ 2689.684200]                                             [<ffffffff810c8ed6>] __alloc_pages_internal+0x2b6/0x650
[ 2689.684200]                                             [<ffffffff810f2e9c>] alloc_pages_current+0x8c/0xe0
[ 2689.684200]                                             [<ffffffff810f4c5b>] slob_new_pages+0x11b/0x130
[ 2689.684200]                                             [<ffffffff810f4f12>] kmem_cache_alloc_node+0x52/0x1a0
[ 2689.684200]                                             [<ffffffff811050a0>] getname+0x40/0x260
[ 2689.684200]                                             [<ffffffff81107790>] user_path_at+0x30/0xe0
[ 2689.684200]                                             [<ffffffff810fd9ba>] vfs_lstat_fd+0x2a/0x60
[ 2689.684200]                                             [<ffffffff810fdbec>] sys_newfstatat+0x5c/0x80
[ 2689.684200]                                             [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[ 2689.684200]                                             [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]     INITIAL USE at:
[ 2689.684200]                                         [<ffffffff8107a67f>] __lock_acquire+0x19f/0x1ae0
[ 2689.684200]                                         [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                         [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]                                         [<ffffffff81192781>] ext4_discard_preallocations+0xd1/0x4a0
[ 2689.684200]                                         [<ffffffff8117f976>] ext4_clear_inode+0x16/0x50
[ 2689.684200]                                         [<ffffffff8111076e>] clear_inode+0xfe/0x170
[ 2689.684200]                                         [<ffffffff811109d8>] dispose_list+0x38/0x120
[ 2689.684200]                                         [<ffffffff81110d4f>] shrink_icache_memory+0x28f/0x300
[ 2689.684200]                                         [<ffffffff810d0cc5>] shrink_slab+0x125/0x180
[ 2689.684200]                                         [<ffffffff810d1e16>] try_to_free_pages+0x276/0x400
[ 2689.684200]                                         [<ffffffff810c8ed6>] __alloc_pages_internal+0x2b6/0x650
[ 2689.684200]                                         [<ffffffff810f2e9c>] alloc_pages_current+0x8c/0xe0
[ 2689.684200]                                         [<ffffffff810f4c5b>] slob_new_pages+0x11b/0x130
[ 2689.684200]                                         [<ffffffff810f4f12>] kmem_cache_alloc_node+0x52/0x1a0
[ 2689.684200]                                         [<ffffffff811050a0>] getname+0x40/0x260
[ 2689.684200]                                         [<ffffffff81107790>] user_path_at+0x30/0xe0
[ 2689.684200]                                         [<ffffffff810fd9ba>] vfs_lstat_fd+0x2a/0x60
[ 2689.684200]                                         [<ffffffff810fdbec>] sys_newfstatat+0x5c/0x80
[ 2689.684200]                                         [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[ 2689.684200]                                         [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]   }
[ 2689.684200]   ... key      at: [<ffffffff822d2ab0>] __key.31742+0x0/0x8
[ 2689.684200]  ... acquired at:
[ 2689.684200]    [<ffffffff8107bab4>] __lock_acquire+0x15d4/0x1ae0
[ 2689.684200]    [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]    [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]    [<ffffffff81192781>] ext4_discard_preallocations+0xd1/0x4a0
[ 2689.684200]    [<ffffffff8117f976>] ext4_clear_inode+0x16/0x50
[ 2689.684200]    [<ffffffff8111076e>] clear_inode+0xfe/0x170
[ 2689.684200]    [<ffffffff811109d8>] dispose_list+0x38/0x120
[ 2689.684200]    [<ffffffff81110d4f>] shrink_icache_memory+0x28f/0x300
[ 2689.684200]    [<ffffffff810d0cc5>] shrink_slab+0x125/0x180
[ 2689.684200]    [<ffffffff810d1e16>] try_to_free_pages+0x276/0x400
[ 2689.684200]    [<ffffffff810c8ed6>] __alloc_pages_internal+0x2b6/0x650
[ 2689.684200]    [<ffffffff810f2e9c>] alloc_pages_current+0x8c/0xe0
[ 2689.684200]    [<ffffffff810f4c5b>] slob_new_pages+0x11b/0x130
[ 2689.684200]    [<ffffffff810f4f12>] kmem_cache_alloc_node+0x52/0x1a0
[ 2689.684200]    [<ffffffff811050a0>] getname+0x40/0x260
[ 2689.684200]    [<ffffffff81107790>] user_path_at+0x30/0xe0
[ 2689.684200]    [<ffffffff810fd9ba>] vfs_lstat_fd+0x2a/0x60
[ 2689.684200]    [<ffffffff810fdbec>] sys_newfstatat+0x5c/0x80
[ 2689.684200]    [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[ 2689.684200]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200]  ... acquired at:
[ 2689.684200]    [<ffffffff8107bab4>] __lock_acquire+0x15d4/0x1ae0
[ 2689.684200]    [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]    [<ffffffff81565363>] _spin_lock_irq+0x43/0x80
[ 2689.684200]    [<ffffffff81560e39>] __schedule+0x1c9/0x8ce
[ 2689.684200]    [<ffffffff81561a65>] schedule+0x15/0x50
[ 2689.684200]    [<ffffffff81045ae8>] __cond_resched+0x38/0x80
[ 2689.684200]    [<ffffffff81561c55>] _cond_resched+0x65/0x70
[ 2689.684200]    [<ffffffff81110697>] clear_inode+0x27/0x170
[ 2689.684200]    [<ffffffff811109d8>] dispose_list+0x38/0x120
[ 2689.684200]    [<ffffffff81110d4f>] shrink_icache_memory+0x28f/0x300
[ 2689.684200]    [<ffffffff810d0cc5>] shrink_slab+0x125/0x180
[ 2689.684200]    [<ffffffff810d1e16>] try_to_free_pages+0x276/0x400
[ 2689.684200]    [<ffffffff810c8ed6>] __alloc_pages_internal+0x2b6/0x650
[ 2689.684200]    [<ffffffff810f2e9c>] alloc_pages_current+0x8c/0xe0
[ 2689.684200]    [<ffffffff810f4c5b>] slob_new_pages+0x11b/0x130
[ 2689.684200]    [<ffffffff810f4f12>] kmem_cache_alloc_node+0x52/0x1a0
[ 2689.684200]    [<ffffffff811050a0>] getname+0x40/0x260
[ 2689.684200]    [<ffffffff81107790>] user_path_at+0x30/0xe0
[ 2689.684200]    [<ffffffff810fd9ba>] vfs_lstat_fd+0x2a/0x60
[ 2689.684200]    [<ffffffff810fdbec>] sys_newfstatat+0x5c/0x80
[ 2689.684200]    [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[ 2689.684200]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200]
[ 2689.684200] the RECLAIM_FS-irq-unsafe lock's dependencies:
[ 2689.684200] -> (&inode->inotify_mutex){+.+.+.} ops: 0 {
[ 2689.684200]    HARDIRQ-ON-W at:
[ 2689.684200]                                        [<ffffffff8107b005>] __lock_acquire+0xb25/0x1ae0
[ 2689.684200]                                        [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                        [<ffffffff81562da3>] mutex_lock_nested+0x63/0x420
[ 2689.684200]                                        [<ffffffff8112ede5>] inotify_find_update_watch+0x85/0x130
[ 2689.684200]                                        [<ffffffff811301e4>] sys_inotify_add_watch+0x184/0x290
[ 2689.684200]                                        [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[ 2689.684200]                                        [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]    SOFTIRQ-ON-W at:
[ 2689.684200]                                        [<ffffffff8107b031>] __lock_acquire+0xb51/0x1ae0
[ 2689.684200]                                        [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                        [<ffffffff81562da3>] mutex_lock_nested+0x63/0x420
[ 2689.684200]                                        [<ffffffff8112ede5>] inotify_find_update_watch+0x85/0x130
[ 2689.684200]                                        [<ffffffff811301e4>] sys_inotify_add_watch+0x184/0x290
[ 2689.684200]                                        [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[ 2689.684200]                                        [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]    RECLAIM_FS-ON-W at:
[ 2689.684200]                                           [<ffffffff81079188>] mark_held_locks+0x68/0x90
[ 2689.684200]                                           [<ffffffff810792a5>] lockdep_trace_alloc+0xf5/0x100
[ 2689.684200]                                           [<ffffffff810f5261>] __kmalloc_node+0x31/0x1e0
[ 2689.684200]                                           [<ffffffff811306c2>] kernel_event+0xe2/0x190
[ 2689.684200]                                           [<ffffffff81130896>] inotify_dev_queue_event+0x126/0x230
[ 2689.684200]                                           [<ffffffff8112f0a6>] inotify_inode_queue_event+0xc6/0x110
[ 2689.684200]                                           [<ffffffff8110444d>] vfs_create+0xcd/0x140
[ 2689.684200]                                           [<ffffffff8110825d>] do_filp_open+0x88d/0xa20
[ 2689.684200]                                           [<ffffffff810f6b68>] do_sys_open+0x98/0x140
[ 2689.684200]                                           [<ffffffff810f6c50>] sys_open+0x20/0x30
[ 2689.684200]                                           [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[ 2689.684200]                                           [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]    INITIAL USE at:
[ 2689.684200]                                       [<ffffffff8107a67f>] __lock_acquire+0x19f/0x1ae0
[ 2689.684200]                                       [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                       [<ffffffff81562da3>] mutex_lock_nested+0x63/0x420
[ 2689.684200]                                       [<ffffffff8112ede5>] inotify_find_update_watch+0x85/0x130
[ 2689.684200]                                       [<ffffffff811301e4>] sys_inotify_add_watch+0x184/0x290
[ 2689.684200]                                       [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[ 2689.684200]                                       [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]  }
[ 2689.684200]  ... key      at: [<ffffffff822d12ec>] __key.28596+0x0/0x8
[ 2689.684200]  -> (&ih->mutex){+.+.+.} ops: 0 {
[ 2689.684200]     HARDIRQ-ON-W at:
[ 2689.684200]                                          [<ffffffff8107b005>] __lock_acquire+0xb25/0x1ae0
[ 2689.684200]                                          [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                          [<ffffffff81562da3>] mutex_lock_nested+0x63/0x420
[ 2689.684200]                                          [<ffffffff8112edf7>] inotify_find_update_watch+0x97/0x130
[ 2689.684200]                                          [<ffffffff811301e4>] sys_inotify_add_watch+0x184/0x290
[ 2689.684200]                                          [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[ 2689.684200]                                          [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]     SOFTIRQ-ON-W at:
[ 2689.684200]                                          [<ffffffff8107b031>] __lock_acquire+0xb51/0x1ae0
[ 2689.684200]                                          [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                          [<ffffffff81562da3>] mutex_lock_nested+0x63/0x420
[ 2689.684200]                                          [<ffffffff8112edf7>] inotify_find_update_watch+0x97/0x130
[ 2689.684200]                                          [<ffffffff811301e4>] sys_inotify_add_watch+0x184/0x290
[ 2689.684200]                                          [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[ 2689.684200]                                          [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]     RECLAIM_FS-ON-W at:
[ 2689.684200]                                             [<ffffffff81079188>] mark_held_locks+0x68/0x90
[ 2689.684200]                                             [<ffffffff810792a5>] lockdep_trace_alloc+0xf5/0x100
[ 2689.684200]                                             [<ffffffff810f5261>] __kmalloc_node+0x31/0x1e0
[ 2689.684200]                                             [<ffffffff811306c2>] kernel_event+0xe2/0x190
[ 2689.684200]                                             [<ffffffff81130896>] inotify_dev_queue_event+0x126/0x230
[ 2689.684200]                                             [<ffffffff8112f0a6>] inotify_inode_queue_event+0xc6/0x110
[ 2689.684200]                                             [<ffffffff8110444d>] vfs_create+0xcd/0x140
[ 2689.684200]                                             [<ffffffff8110825d>] do_filp_open+0x88d/0xa20
[ 2689.684200]                                             [<ffffffff810f6b68>] do_sys_open+0x98/0x140
[ 2689.684200]                                             [<ffffffff810f6c50>] sys_open+0x20/0x30
[ 2689.684200]                                             [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[ 2689.684200]                                             [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]     INITIAL USE at:
[ 2689.684200]                                         [<ffffffff8107a67f>] __lock_acquire+0x19f/0x1ae0
[ 2689.684200]                                         [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                         [<ffffffff81562da3>] mutex_lock_nested+0x63/0x420
[ 2689.684200]                                         [<ffffffff8112edf7>] inotify_find_update_watch+0x97/0x130
[ 2689.684200]                                         [<ffffffff811301e4>] sys_inotify_add_watch+0x184/0x290
[ 2689.684200]                                         [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[ 2689.684200]                                         [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]   }
[ 2689.684200]   ... key      at: [<ffffffff822d16d8>] __key.20503+0x0/0x8
[ 2689.684200]   -> (slob_lock){-.-.-.} ops: 0 {
[ 2689.684200]      IN-HARDIRQ-W at:
[ 2689.684200]                                            [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]      IN-SOFTIRQ-W at:
[ 2689.684200]                                            [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]      IN-RECLAIM_FS-W at:
[ 2689.684200]                                               [<ffffffff8107b142>] __lock_acquire+0xc62/0x1ae0
[ 2689.684200]                                               [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                               [<ffffffff815653f6>] _spin_lock_irqsave+0x56/0xa0
[ 2689.684200]                                               [<ffffffff810f4721>] slob_free+0xa1/0x370
[ 2689.684200]                                               [<ffffffff810f4a25>] __kmem_cache_free+0x35/0x40
[ 2689.684200]                                               [<ffffffff810f4afc>] kmem_cache_free+0xcc/0xd0
[ 2689.684200]                                               [<ffffffff81120783>] free_buffer_head+0x43/0x60
[ 2689.684200]                                               [<ffffffff81120fae>] try_to_free_buffers+0x9e/0xd0
[ 2689.684200]                                               [<ffffffff810bed28>] try_to_release_page+0x78/0x80
[ 2689.684200]                                               [<ffffffff810cf8ba>] shrink_page_list+0x6ba/0xa70
[ 2689.684200]                                               [<ffffffff810d03fe>] shrink_list+0x2be/0x660
[ 2689.684200]                                               [<ffffffff810d09a1>] shrink_zone+0x201/0x400
[ 2689.684200]                                               [<ffffffff810d1709>] kswapd+0x729/0x7a0
[ 2689.684200]                                               [<ffffffff8106555b>] kthread+0x5b/0xa0
[ 2689.684200]                                               [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]                                               [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]      INITIAL USE at:
[ 2689.684200]                                           [<ffffffff8107a67f>] __lock_acquire+0x19f/0x1ae0
[ 2689.684200]                                           [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                           [<ffffffff815653f6>] _spin_lock_irqsave+0x56/0xa0
[ 2689.684200]                                           [<ffffffff810f4cc9>] slob_alloc+0x59/0x250
[ 2689.684200]                                           [<ffffffff810f50a9>] kmem_cache_create+0x49/0xe0
[ 2689.684200]                                           [<ffffffff818cddeb>] debug_objects_mem_init+0x39/0x28d
[ 2689.684200]                                           [<ffffffff818adc9d>] start_kernel+0x2da/0x44f
[ 2689.684200]                                           [<ffffffff818ad299>] x86_64_start_reservations+0x99/0xb9
[ 2689.684200]                                           [<ffffffff818ad3b0>] x86_64_start_kernel+0xf7/0x122
[ 2689.684200]                                           [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]    }
[ 2689.684200]    ... key      at: [<ffffffff817e8b58>] slob_lock+0x18/0x40
[ 2689.684200]   ... acquired at:
[ 2689.684200]    [<ffffffff8107bab4>] __lock_acquire+0x15d4/0x1ae0
[ 2689.684200]    [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]    [<ffffffff815653f6>] _spin_lock_irqsave+0x56/0xa0
[ 2689.684200]    [<ffffffff810f4cc9>] slob_alloc+0x59/0x250
[ 2689.684200]    [<ffffffff810f4fdf>] kmem_cache_alloc_node+0x11f/0x1a0
[ 2689.684200]    [<ffffffff812736da>] idr_pre_get+0x6a/0x90
[ 2689.684200]    [<ffffffff8112e98a>] inotify_handle_get_wd+0x3a/0xc0
[ 2689.684200]    [<ffffffff8112ec9b>] inotify_add_watch+0xab/0x170
[ 2689.684200]    [<ffffffff811302c8>] sys_inotify_add_watch+0x268/0x290
[ 2689.684200]    [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[ 2689.684200]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200]   -> (&idp->lock){......} ops: 0 {
[ 2689.684200]      INITIAL USE at:
[ 2689.684200]                                           [<ffffffff8107a67f>] __lock_acquire+0x19f/0x1ae0
[ 2689.684200]                                           [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                           [<ffffffff815653f6>] _spin_lock_irqsave+0x56/0xa0
[ 2689.684200]                                           [<ffffffff812736a0>] idr_pre_get+0x30/0x90
[ 2689.684200]                                           [<ffffffff81408e69>] get_idr+0x39/0x100
[ 2689.684200]                                           [<ffffffff81409b40>] thermal_zone_bind_cooling_device+0x120/0x2a0
[ 2689.684200]                                           [<ffffffff812df2a5>] acpi_thermal_cooling_device_cb+0x8a/0x180
[ 2689.684200]                                           [<ffffffff812df3c7>] acpi_thermal_bind_cooling_device+0x15/0x17
[ 2689.684200]                                           [<ffffffff814097a4>] thermal_zone_device_register+0x334/0x490
[ 2689.684200]                                           [<ffffffff812df5e1>] acpi_thermal_add+0x218/0x4b5
[ 2689.684200]                                           [<ffffffff812a2f4a>] acpi_device_probe+0x5c/0x1c9
[ 2689.684200]                                           [<ffffffff81322bc4>] driver_probe_device+0xc4/0x1e0
[ 2689.684200]                                           [<ffffffff81322d7b>] __driver_attach+0x9b/0xb0
[ 2689.684200]                                           [<ffffffff81322333>] bus_for_each_dev+0x73/0xa0
[ 2689.684200]                                           [<ffffffff813229d1>] driver_attach+0x21/0x30
[ 2689.684200]                                           [<ffffffff81321abd>] bus_add_driver+0x15d/0x260
[ 2689.684200]                                           [<ffffffff813230b4>] driver_register+0xa4/0x180
[ 2689.684200]                                           [<ffffffff812a48e5>] acpi_bus_register_driver+0x43/0x46
[ 2689.684200]                                           [<ffffffff818d1381>] acpi_thermal_init+0x59/0x7b
[ 2689.684200]                                           [<ffffffff8100904f>] do_one_initcall+0x3f/0x1d0
[ 2689.684200]                                           [<ffffffff818ad6c3>] kernel_init+0x150/0x1a8
[ 2689.684200]                                           [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]                                           [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]    }
[ 2689.684200]    ... key      at: [<ffffffff822ddc78>] __key.12631+0x0/0x8
[ 2689.684200]   ... acquired at:
[ 2689.684200]    [<ffffffff8107bab4>] __lock_acquire+0x15d4/0x1ae0
[ 2689.684200]    [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]    [<ffffffff815653f6>] _spin_lock_irqsave+0x56/0xa0
[ 2689.684200]    [<ffffffff812736a0>] idr_pre_get+0x30/0x90
[ 2689.684200]    [<ffffffff8112e98a>] inotify_handle_get_wd+0x3a/0xc0
[ 2689.684200]    [<ffffffff8112ec9b>] inotify_add_watch+0xab/0x170
[ 2689.684200]    [<ffffffff811302c8>] sys_inotify_add_watch+0x268/0x290
[ 2689.684200]    [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[ 2689.684200]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200]   -> (inode_lock){+.+.-.} ops: 0 {
[ 2689.684200]      HARDIRQ-ON-W at:
[ 2689.684200]                                            [<ffffffff8107b005>] __lock_acquire+0xb25/0x1ae0
[ 2689.684200]                                            [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                            [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]                                            [<ffffffff811102ae>] ifind_fast+0x2e/0xd0
[ 2689.684200]                                            [<ffffffff81111649>] iget_locked+0x49/0x180
[ 2689.684200]                                            [<ffffffff8114d4d5>] sysfs_get_inode+0x25/0x280
[ 2689.684200]                                            [<ffffffff811505c6>] sysfs_fill_super+0x56/0xd0
[ 2689.684200]                                            [<ffffffff810fc5ea>] get_sb_single+0xca/0x100
[ 2689.684200]                                            [<ffffffff8115056b>] sysfs_get_sb+0x1b/0x20
[ 2689.684200]                                            [<ffffffff810fb0f0>] vfs_kern_mount+0x50/0xd0
[ 2689.684200]                                            [<ffffffff810fb189>] kern_mount_data+0x19/0x20
[ 2689.684200]                                            [<ffffffff818cb634>] sysfs_init+0x7f/0xd4
[ 2689.684200]                                            [<ffffffff818c9e34>] mnt_init+0x9d/0x21e
[ 2689.684200]                                            [<ffffffff818c9984>] vfs_caches_init+0xa8/0x140
[ 2689.684200]                                            [<ffffffff818add0f>] start_kernel+0x34c/0x44f
[ 2689.684200]                                            [<ffffffff818ad299>] x86_64_start_reservations+0x99/0xb9
[ 2689.684200]                                            [<ffffffff818ad3b0>] x86_64_start_kernel+0xf7/0x122
[ 2689.684200]                                            [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]      SOFTIRQ-ON-W at:
[ 2689.684200]                                            [<ffffffff8107b031>] __lock_acquire+0xb51/0x1ae0
[ 2689.684200]                                            [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                            [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]                                            [<ffffffff811102ae>] ifind_fast+0x2e/0xd0
[ 2689.684200]                                            [<ffffffff81111649>] iget_locked+0x49/0x180
[ 2689.684200]                                            [<ffffffff8114d4d5>] sysfs_get_inode+0x25/0x280
[ 2689.684200]                                            [<ffffffff811505c6>] sysfs_fill_super+0x56/0xd0
[ 2689.684200]                                            [<ffffffff810fc5ea>] get_sb_single+0xca/0x100
[ 2689.684200]                                            [<ffffffff8115056b>] sysfs_get_sb+0x1b/0x20
[ 2689.684200]                                            [<ffffffff810fb0f0>] vfs_kern_mount+0x50/0xd0
[ 2689.684200]                                            [<ffffffff810fb189>] kern_mount_data+0x19/0x20
[ 2689.684200]                                            [<ffffffff818cb634>] sysfs_init+0x7f/0xd4
[ 2689.684200]                                            [<ffffffff818c9e34>] mnt_init+0x9d/0x21e
[ 2689.684200]                                            [<ffffffff818c9984>] vfs_caches_init+0xa8/0x140
[ 2689.684200]                                            [<ffffffff818add0f>] start_kernel+0x34c/0x44f
[ 2689.684200]                                            [<ffffffff818ad299>] x86_64_start_reservations+0x99/0xb9
[ 2689.684200]                                            [<ffffffff818ad3b0>] x86_64_start_kernel+0xf7/0x122
[ 2689.684200]                                            [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]      IN-RECLAIM_FS-W at:
[ 2689.684200]                                               [<ffffffff8107b142>] __lock_acquire+0xc62/0x1ae0
[ 2689.684200]                                               [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                               [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]                                               [<ffffffff81272328>] _atomic_dec_and_lock+0x98/0xc0
[ 2689.684200]                                               [<ffffffff8110fcea>] iput+0x4a/0x90
[ 2689.684200]                                               [<ffffffff8114f464>] sysfs_d_iput+0x34/0x40
[ 2689.684200]                                               [<ffffffff8110c9aa>] dentry_iput+0x8a/0xf0
[ 2689.684200]                                               [<ffffffff8110cb33>] d_kill+0x33/0x60
[ 2689.684200]                                               [<ffffffff8110ce33>] __shrink_dcache_sb+0x2d3/0x350
[ 2689.684200]                                               [<ffffffff8110d00a>] shrink_dcache_memory+0x15a/0x1e0
[ 2689.684200]                                               [<ffffffff810d0cc5>] shrink_slab+0x125/0x180
[ 2689.684200]                                               [<ffffffff810d1540>] kswapd+0x560/0x7a0
[ 2689.684200]                                               [<ffffffff8106555b>] kthread+0x5b/0xa0
[ 2689.684200]                                               [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]                                               [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]      INITIAL USE at:
[ 2689.684200]                                           [<ffffffff8107a67f>] __lock_acquire+0x19f/0x1ae0
[ 2689.684200]                                           [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                           [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]                                           [<ffffffff811102ae>] ifind_fast+0x2e/0xd0
[ 2689.684200]                                           [<ffffffff81111649>] iget_locked+0x49/0x180
[ 2689.684200]                                           [<ffffffff8114d4d5>] sysfs_get_inode+0x25/0x280
[ 2689.684200]                                           [<ffffffff811505c6>] sysfs_fill_super+0x56/0xd0
[ 2689.684200]                                           [<ffffffff810fc5ea>] get_sb_single+0xca/0x100
[ 2689.684200]                                           [<ffffffff8115056b>] sysfs_get_sb+0x1b/0x20
[ 2689.684200]                                           [<ffffffff810fb0f0>] vfs_kern_mount+0x50/0xd0
[ 2689.684200]                                           [<ffffffff810fb189>] kern_mount_data+0x19/0x20
[ 2689.684200]                                           [<ffffffff818cb634>] sysfs_init+0x7f/0xd4
[ 2689.684200]                                           [<ffffffff818c9e34>] mnt_init+0x9d/0x21e
[ 2689.684200]                                           [<ffffffff818c9984>] vfs_caches_init+0xa8/0x140
[ 2689.684200]                                           [<ffffffff818add0f>] start_kernel+0x34c/0x44f
[ 2689.684200]                                           [<ffffffff818ad299>] x86_64_start_reservations+0x99/0xb9
[ 2689.684200]                                           [<ffffffff818ad3b0>] x86_64_start_kernel+0xf7/0x122
[ 2689.684200]                                           [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]    }
[ 2689.684200]    ... key      at: [<ffffffff817e93f8>] inode_lock+0x18/0x40
[ 2689.684200]   ... acquired at:
[ 2689.684200]    [<ffffffff8107bab4>] __lock_acquire+0x15d4/0x1ae0
[ 2689.684200]    [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]    [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]    [<ffffffff8110f8fd>] igrab+0x1d/0x50
[ 2689.684200]    [<ffffffff8112ecf0>] inotify_add_watch+0x100/0x170
[ 2689.684200]    [<ffffffff811302c8>] sys_inotify_add_watch+0x268/0x290
[ 2689.684200]    [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[ 2689.684200]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200]   -> (dcache_lock){+.+.-.} ops: 0 {
[ 2689.684200]      HARDIRQ-ON-W at:
[ 2689.684200]                                            [<ffffffff8107b005>] __lock_acquire+0xb25/0x1ae0
[ 2689.684200]                                            [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                            [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]                                            [<ffffffff8110ebbf>] d_alloc+0x20f/0x230
[ 2689.684200]                                            [<ffffffff8110ec0e>] d_alloc_root+0x2e/0x70
[ 2689.684200]                                            [<ffffffff811505e2>] sysfs_fill_super+0x72/0xd0
[ 2689.684200]                                            [<ffffffff810fc5ea>] get_sb_single+0xca/0x100
[ 2689.684200]                                            [<ffffffff8115056b>] sysfs_get_sb+0x1b/0x20
[ 2689.684200]                                            [<ffffffff810fb0f0>] vfs_kern_mount+0x50/0xd0
[ 2689.684200]                                            [<ffffffff810fb189>] kern_mount_data+0x19/0x20
[ 2689.684200]                                            [<ffffffff818cb634>] sysfs_init+0x7f/0xd4
[ 2689.684200]                                            [<ffffffff818c9e34>] mnt_init+0x9d/0x21e
[ 2689.684200]                                            [<ffffffff818c9984>] vfs_caches_init+0xa8/0x140
[ 2689.684200]                                            [<ffffffff818add0f>] start_kernel+0x34c/0x44f
[ 2689.684200]                                            [<ffffffff818ad299>] x86_64_start_reservations+0x99/0xb9
[ 2689.684200]                                            [<ffffffff818ad3b0>] x86_64_start_kernel+0xf7/0x122
[ 2689.684200]                                            [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]      SOFTIRQ-ON-W at:
[ 2689.684200]                                            [<ffffffff8107b031>] __lock_acquire+0xb51/0x1ae0
[ 2689.684200]                                            [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                            [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]                                            [<ffffffff8110ebbf>] d_alloc+0x20f/0x230
[ 2689.684200]                                            [<ffffffff8110ec0e>] d_alloc_root+0x2e/0x70
[ 2689.684200]                                            [<ffffffff811505e2>] sysfs_fill_super+0x72/0xd0
[ 2689.684200]                                            [<ffffffff810fc5ea>] get_sb_single+0xca/0x100
[ 2689.684200]                                            [<ffffffff8115056b>] sysfs_get_sb+0x1b/0x20
[ 2689.684200]                                            [<ffffffff810fb0f0>] vfs_kern_mount+0x50/0xd0
[ 2689.684200]                                            [<ffffffff810fb189>] kern_mount_data+0x19/0x20
[ 2689.684200]                                            [<ffffffff818cb634>] sysfs_init+0x7f/0xd4
[ 2689.684200]                                            [<ffffffff818c9e34>] mnt_init+0x9d/0x21e
[ 2689.684200]                                            [<ffffffff818c9984>] vfs_caches_init+0xa8/0x140
[ 2689.684200]                                            [<ffffffff818add0f>] start_kernel+0x34c/0x44f
[ 2689.684200]                                            [<ffffffff818ad299>] x86_64_start_reservations+0x99/0xb9
[ 2689.684200]                                            [<ffffffff818ad3b0>] x86_64_start_kernel+0xf7/0x122
[ 2689.684200]                                            [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]      IN-RECLAIM_FS-W at:
[ 2689.684200]                                               [<ffffffff8107b142>] __lock_acquire+0xc62/0x1ae0
[ 2689.684200]                                               [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                               [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]                                               [<ffffffff8110cf35>] shrink_dcache_memory+0x85/0x1e0
[ 2689.684200]                                               [<ffffffff810d0cc5>] shrink_slab+0x125/0x180
[ 2689.684200]                                               [<ffffffff810d1540>] kswapd+0x560/0x7a0
[ 2689.684200]                                               [<ffffffff8106555b>] kthread+0x5b/0xa0
[ 2689.684200]                                               [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]                                               [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]      INITIAL USE at:
[ 2689.684200]                                           [<ffffffff8107a67f>] __lock_acquire+0x19f/0x1ae0
[ 2689.684200]                                           [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                           [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]                                           [<ffffffff8110ebbf>] d_alloc+0x20f/0x230
[ 2689.684200]                                           [<ffffffff8110ec0e>] d_alloc_root+0x2e/0x70
[ 2689.684200]                                           [<ffffffff811505e2>] sysfs_fill_super+0x72/0xd0
[ 2689.684200]                                           [<ffffffff810fc5ea>] get_sb_single+0xca/0x100
[ 2689.684200]                                           [<ffffffff8115056b>] sysfs_get_sb+0x1b/0x20
[ 2689.684200]                                           [<ffffffff810fb0f0>] vfs_kern_mount+0x50/0xd0
[ 2689.684200]                                           [<ffffffff810fb189>] kern_mount_data+0x19/0x20
[ 2689.684200]                                           [<ffffffff818cb634>] sysfs_init+0x7f/0xd4
[ 2689.684200]                                           [<ffffffff818c9e34>] mnt_init+0x9d/0x21e
[ 2689.684200]                                           [<ffffffff818c9984>] vfs_caches_init+0xa8/0x140
[ 2689.684200]                                           [<ffffffff818add0f>] start_kernel+0x34c/0x44f
[ 2689.684200]                                           [<ffffffff818ad299>] x86_64_start_reservations+0x99/0xb9
[ 2689.684200]                                           [<ffffffff818ad3b0>] x86_64_start_kernel+0xf7/0x122
[ 2689.684200]                                           [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]    }
[ 2689.684200]    ... key      at: [<ffffffff8189b7d8>] dcache_lock+0x18/0x40
[ 2689.684200]    -> (&dentry->d_lock){+.+.-.} ops: 0 {
[ 2689.684200]       HARDIRQ-ON-W at:
[ 2689.684200]                                              [<ffffffff8107b005>] __lock_acquire+0xb25/0x1ae0
[ 2689.684200]                                              [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                              [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]                                              [<ffffffff8112e72a>] inotify_d_instantiate+0x2a/0x60
[ 2689.684200]                                              [<ffffffff8110dc15>] __d_instantiate+0x45/0x50
[ 2689.684200]                                              [<ffffffff8110dc7a>] d_instantiate+0x5a/0x80
[ 2689.684200]                                              [<ffffffff8110ec34>] d_alloc_root+0x54/0x70
[ 2689.684200]                                              [<ffffffff811505e2>] sysfs_fill_super+0x72/0xd0
[ 2689.684200]                                              [<ffffffff810fc5ea>] get_sb_single+0xca/0x100
[ 2689.684200]                                              [<ffffffff8115056b>] sysfs_get_sb+0x1b/0x20
[ 2689.684200]                                              [<ffffffff810fb0f0>] vfs_kern_mount+0x50/0xd0
[ 2689.684200]                                              [<ffffffff810fb189>] kern_mount_data+0x19/0x20
[ 2689.684200]                                              [<ffffffff818cb634>] sysfs_init+0x7f/0xd4
[ 2689.684200]                                              [<ffffffff818c9e34>] mnt_init+0x9d/0x21e
[ 2689.684200]                                              [<ffffffff818c9984>] vfs_caches_init+0xa8/0x140
[ 2689.684200]                                              [<ffffffff818add0f>] start_kernel+0x34c/0x44f
[ 2689.684200]                                              [<ffffffff818ad299>] x86_64_start_reservations+0x99/0xb9
[ 2689.684200]                                              [<ffffffff818ad3b0>] x86_64_start_kernel+0xf7/0x122
[ 2689.684200]                                              [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]       SOFTIRQ-ON-W at:
[ 2689.684200]                                              [<ffffffff8107b031>] __lock_acquire+0xb51/0x1ae0
[ 2689.684200]                                              [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                              [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]                                              [<ffffffff8112e72a>] inotify_d_instantiate+0x2a/0x60
[ 2689.684200]                                              [<ffffffff8110dc15>] __d_instantiate+0x45/0x50
[ 2689.684200]                                              [<ffffffff8110dc7a>] d_instantiate+0x5a/0x80
[ 2689.684200]                                              [<ffffffff8110ec34>] d_alloc_root+0x54/0x70
[ 2689.684200]                                              [<ffffffff811505e2>] sysfs_fill_super+0x72/0xd0
[ 2689.684200]                                              [<ffffffff810fc5ea>] get_sb_single+0xca/0x100
[ 2689.684200]                                              [<ffffffff8115056b>] sysfs_get_sb+0x1b/0x20
[ 2689.684200]                                              [<ffffffff810fb0f0>] vfs_kern_mount+0x50/0xd0
[ 2689.684200]                                              [<ffffffff810fb189>] kern_mount_data+0x19/0x20
[ 2689.684200]                                              [<ffffffff818cb634>] sysfs_init+0x7f/0xd4
[ 2689.684200]                                              [<ffffffff818c9e34>] mnt_init+0x9d/0x21e
[ 2689.684200]                                              [<ffffffff818c9984>] vfs_caches_init+0xa8/0x140
[ 2689.684200]                                              [<ffffffff818add0f>] start_kernel+0x34c/0x44f
[ 2689.684200]                                              [<ffffffff818ad299>] x86_64_start_reservations+0x99/0xb9
[ 2689.684200]                                              [<ffffffff818ad3b0>] x86_64_start_kernel+0xf7/0x122
[ 2689.684200]                                              [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]       IN-RECLAIM_FS-W at:
[ 2689.684200]                                                 [<ffffffff8107b142>] __lock_acquire+0xc62/0x1ae0
[ 2689.684200]                                                 [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                                 [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]                                                 [<ffffffff8110cccb>] __shrink_dcache_sb+0x16b/0x350
[ 2689.684200]                                                 [<ffffffff8110d00a>] shrink_dcache_memory+0x15a/0x1e0
[ 2689.684200]                                                 [<ffffffff810d0cc5>] shrink_slab+0x125/0x180
[ 2689.684200]                                                 [<ffffffff810d1540>] kswapd+0x560/0x7a0
[ 2689.684200]                                                 [<ffffffff8106555b>] kthread+0x5b/0xa0
[ 2689.684200]                                                 [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]                                                 [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]       INITIAL USE at:
[ 2689.684200]                                             [<ffffffff8107a67f>] __lock_acquire+0x19f/0x1ae0
[ 2689.684200]                                             [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                             [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]                                             [<ffffffff8112e72a>] inotify_d_instantiate+0x2a/0x60
[ 2689.684200]                                             [<ffffffff8110dc15>] __d_instantiate+0x45/0x50
[ 2689.684200]                                             [<ffffffff8110dc7a>] d_instantiate+0x5a/0x80
[ 2689.684200]                                             [<ffffffff8110ec34>] d_alloc_root+0x54/0x70
[ 2689.684200]                                             [<ffffffff811505e2>] sysfs_fill_super+0x72/0xd0
[ 2689.684200]                                             [<ffffffff810fc5ea>] get_sb_single+0xca/0x100
[ 2689.684200]                                             [<ffffffff8115056b>] sysfs_get_sb+0x1b/0x20
[ 2689.684200]                                             [<ffffffff810fb0f0>] vfs_kern_mount+0x50/0xd0
[ 2689.684200]                                             [<ffffffff810fb189>] kern_mount_data+0x19/0x20
[ 2689.684200]                                             [<ffffffff818cb634>] sysfs_init+0x7f/0xd4
[ 2689.684200]                                             [<ffffffff818c9e34>] mnt_init+0x9d/0x21e
[ 2689.684200]                                             [<ffffffff818c9984>] vfs_caches_init+0xa8/0x140
[ 2689.684200]                                             [<ffffffff818add0f>] start_kernel+0x34c/0x44f
[ 2689.684200]                                             [<ffffffff818ad299>] x86_64_start_reservations+0x99/0xb9
[ 2689.684200]                                             [<ffffffff818ad3b0>] x86_64_start_kernel+0xf7/0x122
[ 2689.684200]                                             [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]     }
[ 2689.684200]     ... key      at: [<ffffffff822d12a0>] __key.28046+0x0/0x20
[ 2689.684200]     -> (&dentry->d_lock/1){+.+...} ops: 0 {
[ 2689.684200]        HARDIRQ-ON-W at:
[ 2689.684200]                                                [<ffffffff8107b005>] __lock_acquire+0xb25/0x1ae0
[ 2689.684200]                                                [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                                [<ffffffff81565204>] _spin_lock_nested+0x34/0x70
[ 2689.684200]                                                [<ffffffff8110e1b2>] d_move_locked+0x212/0x260
[ 2689.684200]                                                [<ffffffff8110e233>] d_move+0x33/0x50
[ 2689.684200]                                                [<ffffffff81104b05>] vfs_rename+0x375/0x430
[ 2689.684200]                                                [<ffffffff81106dad>] sys_renameat+0x24d/0x2a0
[ 2689.684200]                                                [<ffffffff81106e1b>] sys_rename+0x1b/0x20
[ 2689.684200]                                                [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[ 2689.684200]                                                [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]        SOFTIRQ-ON-W at:
[ 2689.684200]                                                [<ffffffff8107b031>] __lock_acquire+0xb51/0x1ae0
[ 2689.684200]                                                [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                                [<ffffffff81565204>] _spin_lock_nested+0x34/0x70
[ 2689.684200]                                                [<ffffffff8110e1b2>] d_move_locked+0x212/0x260
[ 2689.684200]                                                [<ffffffff8110e233>] d_move+0x33/0x50
[ 2689.684200]                                                [<ffffffff81104b05>] vfs_rename+0x375/0x430
[ 2689.684200]                                                [<ffffffff81106dad>] sys_renameat+0x24d/0x2a0
[ 2689.684200]                                                [<ffffffff81106e1b>] sys_rename+0x1b/0x20
[ 2689.684200]                                                [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[ 2689.684200]                                                [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]        INITIAL USE at:
[ 2689.684200]                                               [<ffffffff8107a67f>] __lock_acquire+0x19f/0x1ae0
[ 2689.684200]                                               [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                               [<ffffffff81565204>] _spin_lock_nested+0x34/0x70
[ 2689.684200]                                               [<ffffffff8110e1b2>] d_move_locked+0x212/0x260
[ 2689.684200]                                               [<ffffffff8110e233>] d_move+0x33/0x50
[ 2689.684200]                                               [<ffffffff81104b05>] vfs_rename+0x375/0x430
[ 2689.684200]                                               [<ffffffff81106dad>] sys_renameat+0x24d/0x2a0
[ 2689.684200]                                               [<ffffffff81106e1b>] sys_rename+0x1b/0x20
[ 2689.684200]                                               [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[ 2689.684200]                                               [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]      }
[ 2689.684200]      ... key      at: [<ffffffff822d12a1>] __key.28046+0x1/0x20
[ 2689.684200]     ... acquired at:
[ 2689.684200]    [<ffffffff8107bab4>] __lock_acquire+0x15d4/0x1ae0
[ 2689.684200]    [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]    [<ffffffff81565204>] _spin_lock_nested+0x34/0x70
[ 2689.684200]    [<ffffffff8110e1b2>] d_move_locked+0x212/0x260
[ 2689.684200]    [<ffffffff8110e233>] d_move+0x33/0x50
[ 2689.684200]    [<ffffffff81104b05>] vfs_rename+0x375/0x430
[ 2689.684200]    [<ffffffff81106dad>] sys_renameat+0x24d/0x2a0
[ 2689.684200]    [<ffffffff81106e1b>] sys_rename+0x1b/0x20
[ 2689.684200]    [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[ 2689.684200]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200]     -> (sysctl_lock){+.+.-.} ops: 0 {
[ 2689.684200]        HARDIRQ-ON-W at:
[ 2689.684200]                                                [<ffffffff8107b005>] __lock_acquire+0xb25/0x1ae0
[ 2689.684200]                                                [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                                [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]                                                [<ffffffff81054ea2>] __sysctl_head_next+0x32/0x140
[ 2689.684200]                                                [<ffffffff8106e809>] sysctl_check_lookup+0x49/0x150
[ 2689.684200]                                                [<ffffffff8106ead8>] sysctl_check_table+0x158/0x750
[ 2689.684200]                                                [<ffffffff81054a97>] __register_sysctl_paths+0x117/0x360
[ 2689.684200]                                                [<ffffffff81054d0e>] register_sysctl_paths+0x2e/0x30
[ 2689.684200]                                                [<ffffffff81054d28>] register_sysctl_table+0x18/0x20
[ 2689.684200]                                                [<ffffffff8104419d>] register_sched_domain_sysctl+0x45d/0x4d0
[ 2689.684200]                                                [<ffffffff818c24e4>] sched_init_smp+0xd3/0x1d8
[ 2689.684200]                                                [<ffffffff818ad685>] kernel_init+0x112/0x1a8
[ 2689.684200]                                                [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]                                                [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]        SOFTIRQ-ON-W at:
[ 2689.684200]                                                [<ffffffff8107b031>] __lock_acquire+0xb51/0x1ae0
[ 2689.684200]                                                [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                                [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]                                                [<ffffffff81054ea2>] __sysctl_head_next+0x32/0x140
[ 2689.684200]                                                [<ffffffff8106e809>] sysctl_check_lookup+0x49/0x150
[ 2689.684200]                                                [<ffffffff8106ead8>] sysctl_check_table+0x158/0x750
[ 2689.684200]                                                [<ffffffff81054a97>] __register_sysctl_paths+0x117/0x360
[ 2689.684200]                                                [<ffffffff81054d0e>] register_sysctl_paths+0x2e/0x30
[ 2689.684200]                                                [<ffffffff81054d28>] register_sysctl_table+0x18/0x20
[ 2689.684200]                                                [<ffffffff8104419d>] register_sched_domain_sysctl+0x45d/0x4d0
[ 2689.684200]                                                [<ffffffff818c24e4>] sched_init_smp+0xd3/0x1d8
[ 2689.684200]                                                [<ffffffff818ad685>] kernel_init+0x112/0x1a8
[ 2689.684200]                                                [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]                                                [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]        IN-RECLAIM_FS-W at:
[ 2689.684200]                                                   [<ffffffff8107b142>] __lock_acquire+0xc62/0x1ae0
[ 2689.684200]                                                   [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                                   [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]                                                   [<ffffffff8105480d>] sysctl_head_put+0x1d/0x50
[ 2689.684200]                                                   [<ffffffff81140ee4>] proc_delete_inode+0x44/0x60
[ 2689.684200]                                                   [<ffffffff81110ff3>] generic_delete_inode+0xc3/0x190
[ 2689.684200]                                                   [<ffffffff8110fd1d>] iput+0x7d/0x90
[ 2689.684200]                                                   [<ffffffff8110c9b8>] dentry_iput+0x98/0xf0
[ 2689.684200]                                                   [<ffffffff8110cb33>] d_kill+0x33/0x60
[ 2689.684200]                                                   [<ffffffff8110ce33>] __shrink_dcache_sb+0x2d3/0x350
[ 2689.684200]                                                   [<ffffffff8110d00a>] shrink_dcache_memory+0x15a/0x1e0
[ 2689.684200]                                                   [<ffffffff810d0cc5>] shrink_slab+0x125/0x180
[ 2689.684200]                                                   [<ffffffff810d1540>] kswapd+0x560/0x7a0
[ 2689.684200]                                                   [<ffffffff8106555b>] kthread+0x5b/0xa0
[ 2689.684200]                                                   [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]                                                   [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]        INITIAL USE at:
[ 2689.684200]                                               [<ffffffff8107a67f>] __lock_acquire+0x19f/0x1ae0
[ 2689.684200]                                               [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                               [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]                                               [<ffffffff81054ea2>] __sysctl_head_next+0x32/0x140
[ 2689.684200]                                               [<ffffffff8106e809>] sysctl_check_lookup+0x49/0x150
[ 2689.684200]                                               [<ffffffff8106ead8>] sysctl_check_table+0x158/0x750
[ 2689.684200]                                               [<ffffffff81054a97>] __register_sysctl_paths+0x117/0x360
[ 2689.684200]                                               [<ffffffff81054d0e>] register_sysctl_paths+0x2e/0x30
[ 2689.684200]                                               [<ffffffff81054d28>] register_sysctl_table+0x18/0x20
[ 2689.684200]                                               [<ffffffff8104419d>] register_sched_domain_sysctl+0x45d/0x4d0
[ 2689.684200]                                               [<ffffffff818c24e4>] sched_init_smp+0xd3/0x1d8
[ 2689.684200]                                               [<ffffffff818ad685>] kernel_init+0x112/0x1a8
[ 2689.684200]                                               [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]                                               [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]      }
[ 2689.684200]      ... key      at: [<ffffffff817ddcb8>] sysctl_lock+0x18/0x40
[ 2689.684200]     ... acquired at:
[ 2689.684200]    [<ffffffff8107bab4>] __lock_acquire+0x15d4/0x1ae0
[ 2689.684200]    [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]    [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]    [<ffffffff810546df>] sysctl_is_seen+0x2f/0x80
[ 2689.684200]    [<ffffffff81149d9e>] proc_sys_compare+0x3e/0x50
[ 2689.684200]    [<ffffffff8110e64d>] __d_lookup+0x17d/0x1d0
[ 2689.684200]    [<ffffffff81103722>] __lookup_hash+0x62/0x1a0
[ 2689.684200]    [<ffffffff8110389a>] lookup_hash+0x3a/0x50
[ 2689.684200]    [<ffffffff81107ccc>] do_filp_open+0x2fc/0xa20
[ 2689.684200]    [<ffffffff810f6b68>] do_sys_open+0x98/0x140
[ 2689.684200]    [<ffffffff810f6c50>] sys_open+0x20/0x30
[ 2689.684200]    [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[ 2689.684200]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200]    ... acquired at:
[ 2689.684200]    [<ffffffff8107bab4>] __lock_acquire+0x15d4/0x1ae0
[ 2689.684200]    [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]    [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]    [<ffffffff8112e72a>] inotify_d_instantiate+0x2a/0x60
[ 2689.684200]    [<ffffffff8110dc15>] __d_instantiate+0x45/0x50
[ 2689.684200]    [<ffffffff8110dc7a>] d_instantiate+0x5a/0x80
[ 2689.684200]    [<ffffffff8110ec34>] d_alloc_root+0x54/0x70
[ 2689.684200]    [<ffffffff811505e2>] sysfs_fill_super+0x72/0xd0
[ 2689.684200]    [<ffffffff810fc5ea>] get_sb_single+0xca/0x100
[ 2689.684200]    [<ffffffff8115056b>] sysfs_get_sb+0x1b/0x20
[ 2689.684200]    [<ffffffff810fb0f0>] vfs_kern_mount+0x50/0xd0
[ 2689.684200]    [<ffffffff810fb189>] kern_mount_data+0x19/0x20
[ 2689.684200]    [<ffffffff818cb634>] sysfs_init+0x7f/0xd4
[ 2689.684200]    [<ffffffff818c9e34>] mnt_init+0x9d/0x21e
[ 2689.684200]    [<ffffffff818c9984>] vfs_caches_init+0xa8/0x140
[ 2689.684200]    [<ffffffff818add0f>] start_kernel+0x34c/0x44f
[ 2689.684200]    [<ffffffff818ad299>] x86_64_start_reservations+0x99/0xb9
[ 2689.684200]    [<ffffffff818ad3b0>] x86_64_start_kernel+0xf7/0x122
[ 2689.684200]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200]    -> (vfsmount_lock){+.+...} ops: 0 {
[ 2689.684200]       HARDIRQ-ON-W at:
[ 2689.684200]                                              [<ffffffff8107b005>] __lock_acquire+0xb25/0x1ae0
[ 2689.684200]                                              [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                              [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]                                              [<ffffffff81115dad>] alloc_vfsmnt+0x5d/0x180
[ 2689.684200]                                              [<ffffffff810fb0d6>] vfs_kern_mount+0x36/0xd0
[ 2689.684200]                                              [<ffffffff810fb189>] kern_mount_data+0x19/0x20
[ 2689.684200]                                              [<ffffffff818cb634>] sysfs_init+0x7f/0xd4
[ 2689.684200]                                              [<ffffffff818c9e34>] mnt_init+0x9d/0x21e
[ 2689.684200]                                              [<ffffffff818c9984>] vfs_caches_init+0xa8/0x140
[ 2689.684200]                                              [<ffffffff818add0f>] start_kernel+0x34c/0x44f
[ 2689.684200]                                              [<ffffffff818ad299>] x86_64_start_reservations+0x99/0xb9
[ 2689.684200]                                              [<ffffffff818ad3b0>] x86_64_start_kernel+0xf7/0x122
[ 2689.684200]                                              [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]       SOFTIRQ-ON-W at:
[ 2689.684200]                                              [<ffffffff8107b031>] __lock_acquire+0xb51/0x1ae0
[ 2689.684200]                                              [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                              [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]                                              [<ffffffff81115dad>] alloc_vfsmnt+0x5d/0x180
[ 2689.684200]                                              [<ffffffff810fb0d6>] vfs_kern_mount+0x36/0xd0
[ 2689.684200]                                              [<ffffffff810fb189>] kern_mount_data+0x19/0x20
[ 2689.684200]                                              [<ffffffff818cb634>] sysfs_init+0x7f/0xd4
[ 2689.684200]                                              [<ffffffff818c9e34>] mnt_init+0x9d/0x21e
[ 2689.684200]                                              [<ffffffff818c9984>] vfs_caches_init+0xa8/0x140
[ 2689.684200]                                              [<ffffffff818add0f>] start_kernel+0x34c/0x44f
[ 2689.684200]                                              [<ffffffff818ad299>] x86_64_start_reservations+0x99/0xb9
[ 2689.684200]                                              [<ffffffff818ad3b0>] x86_64_start_kernel+0xf7/0x122
[ 2689.684200]                                              [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]       INITIAL USE at:
[ 2689.684200]                                             [<ffffffff8107a67f>] __lock_acquire+0x19f/0x1ae0
[ 2689.684200]                                             [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                             [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]                                             [<ffffffff81115dad>] alloc_vfsmnt+0x5d/0x180
[ 2689.684200]                                             [<ffffffff810fb0d6>] vfs_kern_mount+0x36/0xd0
[ 2689.684200]                                             [<ffffffff810fb189>] kern_mount_data+0x19/0x20
[ 2689.684200]                                             [<ffffffff818cb634>] sysfs_init+0x7f/0xd4
[ 2689.684200]                                             [<ffffffff818c9e34>] mnt_init+0x9d/0x21e
[ 2689.684200]                                             [<ffffffff818c9984>] vfs_caches_init+0xa8/0x140
[ 2689.684200]                                             [<ffffffff818add0f>] start_kernel+0x34c/0x44f
[ 2689.684200]                                             [<ffffffff818ad299>] x86_64_start_reservations+0x99/0xb9
[ 2689.684200]                                             [<ffffffff818ad3b0>] x86_64_start_kernel+0xf7/0x122
[ 2689.684200]                                             [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]     }
[ 2689.684200]     ... key      at: [<ffffffff8189b898>] vfsmount_lock+0x18/0x40
[ 2689.684200]     -> (mnt_id_ida.lock){......} ops: 0 {
[ 2689.684200]        INITIAL USE at:
[ 2689.684200]                                               [<ffffffff8107a67f>] __lock_acquire+0x19f/0x1ae0
[ 2689.684200]                                               [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                               [<ffffffff815653f6>] _spin_lock_irqsave+0x56/0xa0
[ 2689.684200]                                               [<ffffffff812736a0>] idr_pre_get+0x30/0x90
[ 2689.684200]                                               [<ffffffff8127371c>] ida_pre_get+0x1c/0x80
[ 2689.684200]                                               [<ffffffff81115da1>] alloc_vfsmnt+0x51/0x180
[ 2689.684200]                                               [<ffffffff810fb0d6>] vfs_kern_mount+0x36/0xd0
[ 2689.684200]                                               [<ffffffff810fb189>] kern_mount_data+0x19/0x20
[ 2689.684200]                                               [<ffffffff818cb634>] sysfs_init+0x7f/0xd4
[ 2689.684200]                                               [<ffffffff818c9e34>] mnt_init+0x9d/0x21e
[ 2689.684200]                                               [<ffffffff818c9984>] vfs_caches_init+0xa8/0x140
[ 2689.684200]                                               [<ffffffff818add0f>] start_kernel+0x34c/0x44f
[ 2689.684200]                                               [<ffffffff818ad299>] x86_64_start_reservations+0x99/0xb9
[ 2689.684200]                                               [<ffffffff818ad3b0>] x86_64_start_kernel+0xf7/0x122
[ 2689.684200]                                               [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]      }
[ 2689.684200]      ... key      at: [<ffffffff817e9910>] mnt_id_ida+0x30/0x60
[ 2689.684200]     ... acquired at:
[ 2689.684200]    [<ffffffff8107bab4>] __lock_acquire+0x15d4/0x1ae0
[ 2689.684200]    [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]    [<ffffffff815653f6>] _spin_lock_irqsave+0x56/0xa0
[ 2689.684200]    [<ffffffff81272963>] get_from_free_list+0x23/0x60
[ 2689.684200]    [<ffffffff81272ead>] idr_get_empty_slot+0x2bd/0x2e0
[ 2689.684200]    [<ffffffff81272f8e>] ida_get_new_above+0xbe/0x210
[ 2689.684200]    [<ffffffff812730ee>] ida_get_new+0xe/0x10
[ 2689.684200]    [<ffffffff81115dbc>] alloc_vfsmnt+0x6c/0x180
[ 2689.684200]    [<ffffffff810fb0d6>] vfs_kern_mount+0x36/0xd0
[ 2689.684200]    [<ffffffff810fb189>] kern_mount_data+0x19/0x20
[ 2689.684200]    [<ffffffff818cb634>] sysfs_init+0x7f/0xd4
[ 2689.684200]    [<ffffffff818c9e34>] mnt_init+0x9d/0x21e
[ 2689.684200]    [<ffffffff818c9984>] vfs_caches_init+0xa8/0x140
[ 2689.684200]    [<ffffffff818add0f>] start_kernel+0x34c/0x44f
[ 2689.684200]    [<ffffffff818ad299>] x86_64_start_reservations+0x99/0xb9
[ 2689.684200]    [<ffffffff818ad3b0>] x86_64_start_kernel+0xf7/0x122
[ 2689.684200]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200]     ... acquired at:
[ 2689.684200]    [<ffffffff8107bab4>] __lock_acquire+0x15d4/0x1ae0
[ 2689.684200]    [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]    [<ffffffff815653f6>] _spin_lock_irqsave+0x56/0xa0
[ 2689.684200]    [<ffffffff810f4721>] slob_free+0xa1/0x370
[ 2689.684200]    [<ffffffff810f4a25>] __kmem_cache_free+0x35/0x40
[ 2689.684200]    [<ffffffff810f4afc>] kmem_cache_free+0xcc/0xd0
[ 2689.684200]    [<ffffffff81273011>] ida_get_new_above+0x141/0x210
[ 2689.684200]    [<ffffffff812730ee>] ida_get_new+0xe/0x10
[ 2689.684200]    [<ffffffff81115dbc>] alloc_vfsmnt+0x6c/0x180
[ 2689.684200]    [<ffffffff810fb0d6>] vfs_kern_mount+0x36/0xd0
[ 2689.684200]    [<ffffffff810fb189>] kern_mount_data+0x19/0x20
[ 2689.684200]    [<ffffffff818cb634>] sysfs_init+0x7f/0xd4
[ 2689.684200]    [<ffffffff818c9e34>] mnt_init+0x9d/0x21e
[ 2689.684200]    [<ffffffff818c9984>] vfs_caches_init+0xa8/0x140
[ 2689.684200]    [<ffffffff818add0f>] start_kernel+0x34c/0x44f
[ 2689.684200]    [<ffffffff818ad299>] x86_64_start_reservations+0x99/0xb9
[ 2689.684200]    [<ffffffff818ad3b0>] x86_64_start_kernel+0xf7/0x122
[ 2689.684200]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200]     -> (&q->lock){-.-.-.} ops: 0 {
[ 2689.684200]        IN-HARDIRQ-W at:
[ 2689.684200]                                                [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]        IN-SOFTIRQ-W at:
[ 2689.684200]                                                [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]        IN-RECLAIM_FS-W at:
[ 2689.684200]                                                   [<ffffffff8107b142>] __lock_acquire+0xc62/0x1ae0
[ 2689.684200]                                                   [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                                   [<ffffffff815653f6>] _spin_lock_irqsave+0x56/0xa0
[ 2689.684200]                                                   [<ffffffff81065d31>] prepare_to_wait+0x31/0x90
[ 2689.684200]                                                   [<ffffffff810d10e0>] kswapd+0x100/0x7a0
[ 2689.684200]                                                   [<ffffffff8106555b>] kthread+0x5b/0xa0
[ 2689.684200]                                                   [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]                                                   [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]        INITIAL USE at:
[ 2689.684200]                                               [<ffffffff8107a67f>] __lock_acquire+0x19f/0x1ae0
[ 2689.684200]                                               [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                               [<ffffffff81565363>] _spin_lock_irq+0x43/0x80
[ 2689.684200]                                               [<ffffffff81561cab>] wait_for_common+0x4b/0x1d0
[ 2689.684200]                                               [<ffffffff81561eed>] wait_for_completion+0x1d/0x20
[ 2689.684200]                                               [<ffffffff8106581f>] kthread_create+0xaf/0x180
[ 2689.684200]                                               [<ffffffff8155db79>] migration_call+0x1a6/0x5d2
[ 2689.684200]                                               [<ffffffff818c1f50>] migration_init+0x2e/0x7f
[ 2689.684200]                                               [<ffffffff8100904f>] do_one_initcall+0x3f/0x1d0
[ 2689.684200]                                               [<ffffffff818ad5e0>] kernel_init+0x6d/0x1a8
[ 2689.684200]                                               [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]                                               [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]      }
[ 2689.684200]      ... key      at: [<ffffffff81b4bdc8>] __key.19111+0x0/0x18
[ 2689.684200]      -> (&rq->lock){-.-.-.} ops: 0 {
[ 2689.684200]         IN-HARDIRQ-W at:
[ 2689.684200]                                                  [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]         IN-SOFTIRQ-W at:
[ 2689.684200]                                                  [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]         IN-RECLAIM_FS-W at:
[ 2689.684200]                                                     [<ffffffff8107b142>] __lock_acquire+0xc62/0x1ae0
[ 2689.684200]                                                     [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                                     [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]                                                     [<ffffffff8103a3c3>] task_rq_lock+0x63/0xc0
[ 2689.684200]                                                     [<ffffffff81045c29>] set_cpus_allowed_ptr+0x39/0x160
[ 2689.684200]                                                     [<ffffffff810d105f>] kswapd+0x7f/0x7a0
[ 2689.684200]                                                     [<ffffffff8106555b>] kthread+0x5b/0xa0
[ 2689.684200]                                                     [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]                                                     [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]         INITIAL USE at:
[ 2689.684200]                                                 [<ffffffff8107a67f>] __lock_acquire+0x19f/0x1ae0
[ 2689.684200]                                                 [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                                 [<ffffffff815653f6>] _spin_lock_irqsave+0x56/0xa0
[ 2689.684200]                                                 [<ffffffff8104210b>] rq_attach_root+0x2b/0x110
[ 2689.684200]                                                 [<ffffffff818c2307>] sched_init+0x2bb/0x3c5
[ 2689.684200]                                                 [<ffffffff818adb43>] start_kernel+0x180/0x44f
[ 2689.684200]                                                 [<ffffffff818ad299>] x86_64_start_reservations+0x99/0xb9
[ 2689.684200]                                                 [<ffffffff818ad3b0>] x86_64_start_kernel+0xf7/0x122
[ 2689.684200]                                                 [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]       }
[ 2689.684200]       ... key      at: [<ffffffff81b06858>] __key.48842+0x0/0x8
[ 2689.684200]       -> (&vec->lock){-.-.-.} ops: 0 {
[ 2689.684200]          IN-HARDIRQ-W at:
[ 2689.684200]                                                    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]          IN-SOFTIRQ-W at:
[ 2689.684200]                                                    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]          IN-RECLAIM_FS-W at:
[ 2689.684200]                                                       [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]          INITIAL USE at:
[ 2689.684200]                                                   [<ffffffff8107a67f>] __lock_acquire+0x19f/0x1ae0
[ 2689.684200]                                                   [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                                   [<ffffffff815653f6>] _spin_lock_irqsave+0x56/0xa0
[ 2689.684200]                                                   [<ffffffff810be9f2>] cpupri_set+0x102/0x1a0
[ 2689.684200]                                                   [<ffffffff8103e839>] rq_online_rt+0x49/0x80
[ 2689.684200]                                                   [<ffffffff8103826e>] set_rq_online+0x5e/0x80
[ 2689.684200]                                                   [<ffffffff810421c8>] rq_attach_root+0xe8/0x110
[ 2689.684200]                                                   [<ffffffff818c2307>] sched_init+0x2bb/0x3c5
[ 2689.684200]                                                   [<ffffffff818adb43>] start_kernel+0x180/0x44f
[ 2689.684200]                                                   [<ffffffff818ad299>] x86_64_start_reservations+0x99/0xb9
[ 2689.684200]                                                   [<ffffffff818ad3b0>] x86_64_start_kernel+0xf7/0x122
[ 2689.684200]                                                   [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]        }
[ 2689.684200]        ... key      at: [<ffffffff822ce1b8>] __key.15844+0x0/0x8
[ 2689.684200]       ... acquired at:
[ 2689.684200]    [<ffffffff8107bab4>] __lock_acquire+0x15d4/0x1ae0
[ 2689.684200]    [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]    [<ffffffff815653f6>] _spin_lock_irqsave+0x56/0xa0
[ 2689.684200]    [<ffffffff810be9f2>] cpupri_set+0x102/0x1a0
[ 2689.684200]    [<ffffffff8103e839>] rq_online_rt+0x49/0x80
[ 2689.684200]    [<ffffffff8103826e>] set_rq_online+0x5e/0x80
[ 2689.684200]    [<ffffffff810421c8>] rq_attach_root+0xe8/0x110
[ 2689.684200]    [<ffffffff818c2307>] sched_init+0x2bb/0x3c5
[ 2689.684200]    [<ffffffff818adb43>] start_kernel+0x180/0x44f
[ 2689.684200]    [<ffffffff818ad299>] x86_64_start_reservations+0x99/0xb9
[ 2689.684200]    [<ffffffff818ad3b0>] x86_64_start_kernel+0xf7/0x122
[ 2689.684200]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200]       -> (&rt_b->rt_runtime_lock){-.-.-.} ops: 0 {
[ 2689.684200]          IN-HARDIRQ-W at:
[ 2689.684200]                                                    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]          IN-SOFTIRQ-W at:
[ 2689.684200]                                                    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]          IN-RECLAIM_FS-W at:
[ 2689.684200]                                                       [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]          INITIAL USE at:
[ 2689.684200]                                                   [<ffffffff8107a67f>] __lock_acquire+0x19f/0x1ae0
[ 2689.684200]                                                   [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                                   [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]                                                   [<ffffffff8103f294>] enqueue_task_rt+0x254/0x300
[ 2689.684200]                                                   [<ffffffff810391f6>] enqueue_task+0x86/0xa0
[ 2689.684200]                                                   [<ffffffff8103923d>] activate_task+0x2d/0x40
[ 2689.684200]                                                   [<ffffffff81040610>] try_to_wake_up+0x1b0/0x320
[ 2689.684200]                                                   [<ffffffff810407d5>] wake_up_process+0x15/0x20
[ 2689.684200]                                                   [<ffffffff8155da30>] migration_call+0x5d/0x5d2
[ 2689.684200]                                                   [<ffffffff818c1f87>] migration_init+0x65/0x7f
[ 2689.684200]                                                   [<ffffffff8100904f>] do_one_initcall+0x3f/0x1d0
[ 2689.684200]                                                   [<ffffffff818ad5e0>] kernel_init+0x6d/0x1a8
[ 2689.684200]                                                   [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]                                                   [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]        }
[ 2689.684200]        ... key      at: [<ffffffff81b06860>] __key.39064+0x0/0x8
[ 2689.684200]        -> (&cpu_base->lock){-.-.-.} ops: 0 {
[ 2689.684200]           IN-HARDIRQ-W at:
[ 2689.684200]                                                      [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]           IN-SOFTIRQ-W at:
[ 2689.684200]                                                      [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]           IN-RECLAIM_FS-W at:
[ 2689.684200]                                                         [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]           INITIAL USE at:
[ 2689.684200]                                                     [<ffffffff8107a67f>] __lock_acquire+0x19f/0x1ae0
[ 2689.684200]                                                     [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                                     [<ffffffff815653f6>] _spin_lock_irqsave+0x56/0xa0
[ 2689.684200]                                                     [<ffffffff8106981c>] lock_hrtimer_base+0x5c/0x90
[ 2689.684200]                                                     [<ffffffff81069a93>] __hrtimer_start_range_ns+0x43/0x340
[ 2689.684200]                                                     [<ffffffff8103f2e2>] enqueue_task_rt+0x2a2/0x300
[ 2689.684200]                                                     [<ffffffff810391f6>] enqueue_task+0x86/0xa0
[ 2689.684200]                                                     [<ffffffff8103923d>] activate_task+0x2d/0x40
[ 2689.684200]                                                     [<ffffffff81040610>] try_to_wake_up+0x1b0/0x320
[ 2689.684200]                                                     [<ffffffff810407d5>] wake_up_process+0x15/0x20
[ 2689.684200]                                                     [<ffffffff8155da30>] migration_call+0x5d/0x5d2
[ 2689.684200]                                                     [<ffffffff818c1f87>] migration_init+0x65/0x7f
[ 2689.684200]                                                     [<ffffffff8100904f>] do_one_initcall+0x3f/0x1d0
[ 2689.684200]                                                     [<ffffffff818ad5e0>] kernel_init+0x6d/0x1a8
[ 2689.684200]                                                     [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]                                                     [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]         }
[ 2689.684200]         ... key      at: [<ffffffff81b4be10>] __key.21319+0x0/0x8
[ 2689.684200]         -> (&obj_hash[i].lock){-.-.-.} ops: 0 {
[ 2689.684200]            IN-HARDIRQ-W at:
[ 2689.684200]                                                        [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]            IN-SOFTIRQ-W at:
[ 2689.684200]                                                        [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]            IN-RECLAIM_FS-W at:
[ 2689.684200]                                                           [<ffffffff8107b142>] __lock_acquire+0xc62/0x1ae0
[ 2689.684200]                                                           [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                                           [<ffffffff815653f6>] _spin_lock_irqsave+0x56/0xa0
[ 2689.684200]                                                           [<ffffffff81281dee>] debug_check_no_obj_freed+0x8e/0x200
[ 2689.684200]                                                           [<ffffffff810c7bcc>] free_hot_cold_page+0x14c/0x350
[ 2689.684200]                                                           [<ffffffff810c7e11>] __pagevec_free+0x41/0x60
[ 2689.684200]                                                           [<ffffffff810cf815>] shrink_page_list+0x615/0xa70
[ 2689.684200]                                                           [<ffffffff810d03fe>] shrink_list+0x2be/0x660
[ 2689.684200]                                                           [<ffffffff810d09a1>] shrink_zone+0x201/0x400
[ 2689.684200]                                                           [<ffffffff810d1709>] kswapd+0x729/0x7a0
[ 2689.684200]                                                           [<ffffffff8106555b>] kthread+0x5b/0xa0
[ 2689.684200]                                                           [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]                                                           [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]            INITIAL USE at:
[ 2689.684200]                                                       [<ffffffff8107a67f>] __lock_acquire+0x19f/0x1ae0
[ 2689.684200]                                                       [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                                       [<ffffffff815653f6>] _spin_lock_irqsave+0x56/0xa0
[ 2689.684200]                                                       [<ffffffff812820fc>] __debug_object_init+0x5c/0x410
[ 2689.684200]                                                       [<ffffffff812824ff>] debug_object_init+0x1f/0x30
[ 2689.684200]                                                       [<ffffffff810696ae>] hrtimer_init+0x2e/0x50
[ 2689.684200]                                                       [<ffffffff818c20f7>] sched_init+0xab/0x3c5
[ 2689.684200]                                                       [<ffffffff818adb43>] start_kernel+0x180/0x44f
[ 2689.684200]                                                       [<ffffffff818ad299>] x86_64_start_reservations+0x99/0xb9
[ 2689.684200]                                                       [<ffffffff818ad3b0>] x86_64_start_kernel+0xf7/0x122
[ 2689.684200]                                                       [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]          }
[ 2689.684200]          ... key      at: [<ffffffff822ddf08>] __key.20519+0x0/0x8
[ 2689.684200]          -> (pool_lock){..-.-.} ops: 0 {
[ 2689.684200]             IN-SOFTIRQ-W at:
[ 2689.684200]                                                          [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]             IN-RECLAIM_FS-W at:
[ 2689.684200]                                                             [<ffffffff8107b142>] __lock_acquire+0xc62/0x1ae0
[ 2689.684200]                                                             [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                                             [<ffffffff815653f6>] _spin_lock_irqsave+0x56/0xa0
[ 2689.684200]                                                             [<ffffffff81281cd6>] free_object+0x16/0xa0
[ 2689.684200]                                                             [<ffffffff81281f26>] debug_check_no_obj_freed+0x1c6/0x200
[ 2689.684200]                                                             [<ffffffff810c7bcc>] free_hot_cold_page+0x14c/0x350
[ 2689.684200]                                                             [<ffffffff810c7e60>] free_hot_page+0x10/0x20
[ 2689.684200]                                                             [<ffffffff810c7ee2>] __free_pages+0x72/0x80
[ 2689.684200]                                                             [<ffffffff810c7f6b>] free_pages+0x7b/0x80
[ 2689.684200]                                                             [<ffffffff810f47d5>] slob_free+0x155/0x370
[ 2689.684200]                                                             [<ffffffff810f4a25>] __kmem_cache_free+0x35/0x40
[ 2689.684200]                                                             [<ffffffff810f4afc>] kmem_cache_free+0xcc/0xd0
[ 2689.684200]                                                             [<ffffffff81110991>] destroy_inode+0x61/0x70
[ 2689.684200]                                                             [<ffffffff81111079>] generic_delete_inode+0x149/0x190
[ 2689.684200]                                                             [<ffffffff8110fd1d>] iput+0x7d/0x90
[ 2689.684200]                                                             [<ffffffff8114f464>] sysfs_d_iput+0x34/0x40
[ 2689.684200]                                                             [<ffffffff8110c9aa>] dentry_iput+0x8a/0xf0
[ 2689.684200]                                                             [<ffffffff8110cb33>] d_kill+0x33/0x60
[ 2689.684200]                                                             [<ffffffff8110ce33>] __shrink_dcache_sb+0x2d3/0x350
[ 2689.684200]                                                             [<ffffffff8110d00a>] shrink_dcache_memory+0x15a/0x1e0
[ 2689.684200]                                                             [<ffffffff810d0cc5>] shrink_slab+0x125/0x180
[ 2689.684200]                                                             [<ffffffff810d1540>] kswapd+0x560/0x7a0
[ 2689.684200]                                                             [<ffffffff8106555b>] kthread+0x5b/0xa0
[ 2689.684200]                                                             [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]                                                             [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]             INITIAL USE at:
[ 2689.684200]                                                         [<ffffffff8107a67f>] __lock_acquire+0x19f/0x1ae0
[ 2689.684200]                                                         [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                                         [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]                                                         [<ffffffff8128218a>] __debug_object_init+0xea/0x410
[ 2689.684200]                                                         [<ffffffff812824ff>] debug_object_init+0x1f/0x30
[ 2689.684200]                                                         [<ffffffff810696ae>] hrtimer_init+0x2e/0x50
[ 2689.684200]                                                         [<ffffffff818c20f7>] sched_init+0xab/0x3c5
[ 2689.684200]                                                         [<ffffffff818adb43>] start_kernel+0x180/0x44f
[ 2689.684200]                                                         [<ffffffff818ad299>] x86_64_start_reservations+0x99/0xb9
[ 2689.684200]                                                         [<ffffffff818ad3b0>] x86_64_start_kernel+0xf7/0x122
[ 2689.684200]                                                         [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]           }
[ 2689.684200]           ... key      at: [<ffffffff817fe3f8>] pool_lock+0x18/0x40
[ 2689.684200]          ... acquired at:
[ 2689.684200]    [<ffffffff8107bab4>] __lock_acquire+0x15d4/0x1ae0
[ 2689.684200]    [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]    [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]    [<ffffffff8128218a>] __debug_object_init+0xea/0x410
[ 2689.684200]    [<ffffffff812824ff>] debug_object_init+0x1f/0x30
[ 2689.684200]    [<ffffffff810696ae>] hrtimer_init+0x2e/0x50
[ 2689.684200]    [<ffffffff818c20f7>] sched_init+0xab/0x3c5
[ 2689.684200]    [<ffffffff818adb43>] start_kernel+0x180/0x44f
[ 2689.684200]    [<ffffffff818ad299>] x86_64_start_reservations+0x99/0xb9
[ 2689.684200]    [<ffffffff818ad3b0>] x86_64_start_kernel+0xf7/0x122
[ 2689.684200]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200]         ... acquired at:
[ 2689.684200]    [<ffffffff8107bab4>] __lock_acquire+0x15d4/0x1ae0
[ 2689.684200]    [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]    [<ffffffff815653f6>] _spin_lock_irqsave+0x56/0xa0
[ 2689.684200]    [<ffffffff81281bac>] debug_object_activate+0x5c/0x170
[ 2689.684200]    [<ffffffff81068e45>] enqueue_hrtimer+0x35/0xb0
[ 2689.684200]    [<ffffffff81069b3d>] __hrtimer_start_range_ns+0xed/0x340
[ 2689.684200]    [<ffffffff8103f2e2>] enqueue_task_rt+0x2a2/0x300
[ 2689.684200]    [<ffffffff810391f6>] enqueue_task+0x86/0xa0
[ 2689.684200]    [<ffffffff8103923d>] activate_task+0x2d/0x40
[ 2689.684200]    [<ffffffff81040610>] try_to_wake_up+0x1b0/0x320
[ 2689.684200]    [<ffffffff810407d5>] wake_up_process+0x15/0x20
[ 2689.684200]    [<ffffffff8155da30>] migration_call+0x5d/0x5d2
[ 2689.684200]    [<ffffffff818c1f87>] migration_init+0x65/0x7f
[ 2689.684200]    [<ffffffff8100904f>] do_one_initcall+0x3f/0x1d0
[ 2689.684200]    [<ffffffff818ad5e0>] kernel_init+0x6d/0x1a8
[ 2689.684200]    [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200]        ... acquired at:
[ 2689.684200]    [<ffffffff8107bab4>] __lock_acquire+0x15d4/0x1ae0
[ 2689.684200]    [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]    [<ffffffff815653f6>] _spin_lock_irqsave+0x56/0xa0
[ 2689.684200]    [<ffffffff8106981c>] lock_hrtimer_base+0x5c/0x90
[ 2689.684200]    [<ffffffff81069a93>] __hrtimer_start_range_ns+0x43/0x340
[ 2689.684200]    [<ffffffff8103f2e2>] enqueue_task_rt+0x2a2/0x300
[ 2689.684200]    [<ffffffff810391f6>] enqueue_task+0x86/0xa0
[ 2689.684200]    [<ffffffff8103923d>] activate_task+0x2d/0x40
[ 2689.684200]    [<ffffffff81040610>] try_to_wake_up+0x1b0/0x320
[ 2689.684200]    [<ffffffff810407d5>] wake_up_process+0x15/0x20
[ 2689.684200]    [<ffffffff8155da30>] migration_call+0x5d/0x5d2
[ 2689.684200]    [<ffffffff818c1f87>] migration_init+0x65/0x7f
[ 2689.684200]    [<ffffffff8100904f>] do_one_initcall+0x3f/0x1d0
[ 2689.684200]    [<ffffffff818ad5e0>] kernel_init+0x6d/0x1a8
[ 2689.684200]    [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200]        -> (&rt_rq->rt_runtime_lock){-.-.-.} ops: 0 {
[ 2689.684200]           IN-HARDIRQ-W at:
[ 2689.684200]                                                      [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]           IN-SOFTIRQ-W at:
[ 2689.684200]                                                      [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]           IN-RECLAIM_FS-W at:
[ 2689.684200]                                                         [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]           INITIAL USE at:
[ 2689.684200]                                                     [<ffffffff8107a67f>] __lock_acquire+0x19f/0x1ae0
[ 2689.684200]                                                     [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                                     [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]                                                     [<ffffffff8103acaf>] update_curr_rt+0x12f/0x1e0
[ 2689.684200]                                                     [<ffffffff8103eb84>] dequeue_task_rt+0x24/0x90
[ 2689.684200]                                                     [<ffffffff81039a4a>] dequeue_task+0xea/0x140
[ 2689.684200]                                                     [<ffffffff81039acd>] deactivate_task+0x2d/0x40
[ 2689.684200]                                                     [<ffffffff81560eb3>] __schedule+0x243/0x8ce
[ 2689.684200]                                                     [<ffffffff81561a65>] schedule+0x15/0x50
[ 2689.684200]                                                     [<ffffffff8104598c>] migration_thread+0x1cc/0x2f0
[ 2689.684200]                                                     [<ffffffff8106555b>] kthread+0x5b/0xa0
[ 2689.684200]                                                     [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]                                                     [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]         }
[ 2689.684200]         ... key      at: [<ffffffff81b06868>] __key.48822+0x0/0x8
[ 2689.684200]        ... acquired at:
[ 2689.684200]    [<ffffffff8107bab4>] __lock_acquire+0x15d4/0x1ae0
[ 2689.684200]    [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]    [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]    [<ffffffff8103afa4>] __enable_runtime+0x54/0xa0
[ 2689.684200]    [<ffffffff8103e81d>] rq_online_rt+0x2d/0x80
[ 2689.684200]    [<ffffffff8103826e>] set_rq_online+0x5e/0x80
[ 2689.684200]    [<ffffffff8155deba>] migration_call+0x4e7/0x5d2
[ 2689.684200]    [<ffffffff8156879f>] notifier_call_chain+0x3f/0x80
[ 2689.684200]    [<ffffffff8106b326>] raw_notifier_call_chain+0x16/0x20
[ 2689.684200]    [<ffffffff8155e356>] _cpu_up+0x146/0x14b
[ 2689.684200]    [<ffffffff8155e3d7>] cpu_up+0x7c/0x95
[ 2689.684200]    [<ffffffff818ad658>] kernel_init+0xe5/0x1a8
[ 2689.684200]    [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200]       ... acquired at:
[ 2689.684200]    [<ffffffff8107bab4>] __lock_acquire+0x15d4/0x1ae0
[ 2689.684200]    [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]    [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]    [<ffffffff8103f294>] enqueue_task_rt+0x254/0x300
[ 2689.684200]    [<ffffffff810391f6>] enqueue_task+0x86/0xa0
[ 2689.684200]    [<ffffffff8103923d>] activate_task+0x2d/0x40
[ 2689.684200]    [<ffffffff81040610>] try_to_wake_up+0x1b0/0x320
[ 2689.684200]    [<ffffffff810407d5>] wake_up_process+0x15/0x20
[ 2689.684200]    [<ffffffff8155da30>] migration_call+0x5d/0x5d2
[ 2689.684200]    [<ffffffff818c1f87>] migration_init+0x65/0x7f
[ 2689.684200]    [<ffffffff8100904f>] do_one_initcall+0x3f/0x1d0
[ 2689.684200]    [<ffffffff818ad5e0>] kernel_init+0x6d/0x1a8
[ 2689.684200]    [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200]       ... acquired at:
[ 2689.684200]    [<ffffffff8107bab4>] __lock_acquire+0x15d4/0x1ae0
[ 2689.684200]    [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]    [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]    [<ffffffff8103acaf>] update_curr_rt+0x12f/0x1e0
[ 2689.684200]    [<ffffffff8103eb84>] dequeue_task_rt+0x24/0x90
[ 2689.684200]    [<ffffffff81039a4a>] dequeue_task+0xea/0x140
[ 2689.684200]    [<ffffffff81039acd>] deactivate_task+0x2d/0x40
[ 2689.684200]    [<ffffffff81560eb3>] __schedule+0x243/0x8ce
[ 2689.684200]    [<ffffffff81561a65>] schedule+0x15/0x50
[ 2689.684200]    [<ffffffff8104598c>] migration_thread+0x1cc/0x2f0
[ 2689.684200]    [<ffffffff8106555b>] kthread+0x5b/0xa0
[ 2689.684200]    [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200]       -> (&rq->lock/1){..-.-.} ops: 0 {
[ 2689.684200]          IN-SOFTIRQ-W at:
[ 2689.684200]                                                    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]          IN-RECLAIM_FS-W at:
[ 2689.684200]                                                       [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]          INITIAL USE at:
[ 2689.684200]                                                   [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]        }
[ 2689.684200]        ... key      at: [<ffffffff81b06859>] __key.48842+0x1/0x8
[ 2689.684200]       ... acquired at:
[ 2689.684200]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200]       -> (&sig->cputimer.lock){-.-.-.} ops: 0 {
[ 2689.684200]          IN-HARDIRQ-W at:
[ 2689.684200]                                                    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]          IN-SOFTIRQ-W at:
[ 2689.684200]                                                    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]          IN-RECLAIM_FS-W at:
[ 2689.684200]                                                       [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]          INITIAL USE at:
[ 2689.684200]                                                   [<ffffffff8107a67f>] __lock_acquire+0x19f/0x1ae0
[ 2689.684200]                                                   [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                                   [<ffffffff815653f6>] _spin_lock_irqsave+0x56/0xa0
[ 2689.684200]                                                   [<ffffffff81066e7d>] thread_group_cputimer+0x3d/0xf0
[ 2689.684200]                                                   [<ffffffff8106883a>] posix_cpu_timers_exit_group+0x1a/0x40
[ 2689.684200]                                                   [<ffffffff8104df10>] release_task+0x450/0x500
[ 2689.684200]                                                   [<ffffffff8104f832>] do_exit+0x6d2/0x9b0
[ 2689.684200]                                                   [<ffffffff8105fc6b>] ____call_usermodehelper+0x16b/0x170
[ 2689.684200]                                                   [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]                                                   [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]        }
[ 2689.684200]        ... key      at: [<ffffffff81b08a04>] __key.16763+0x0/0x8
[ 2689.684200]       ... acquired at:
[ 2689.684200]    [<ffffffff8107bab4>] __lock_acquire+0x15d4/0x1ae0
[ 2689.684200]    [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]    [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]    [<ffffffff8103a572>] update_curr+0x152/0x1a0
[ 2689.684200]    [<ffffffff8103c1e2>] dequeue_task_fair+0x52/0x290
[ 2689.684200]    [<ffffffff81039a4a>] dequeue_task+0xea/0x140
[ 2689.684200]    [<ffffffff81039acd>] deactivate_task+0x2d/0x40
[ 2689.684200]    [<ffffffff81560eb3>] __schedule+0x243/0x8ce
[ 2689.684200]    [<ffffffff81561a65>] schedule+0x15/0x50
[ 2689.684200]    [<ffffffff814f84c8>] rpc_wait_bit_killable+0x48/0x80
[ 2689.684200]    [<ffffffff81562362>] __wait_on_bit+0x62/0x90
[ 2689.684200]    [<ffffffff81562409>] out_of_line_wait_on_bit+0x79/0x90
[ 2689.684200]    [<ffffffff814f9025>] __rpc_execute+0x285/0x340
[ 2689.684200]    [<ffffffff814f910d>] rpc_execute+0x2d/0x40
[ 2689.684200]    [<ffffffff814f0e30>] rpc_run_task+0x40/0x80
[ 2689.684200]    [<ffffffff814f0fc4>] rpc_call_sync+0x64/0xb0
[ 2689.684200]    [<ffffffff811c50fe>] nfs3_rpc_wrapper+0x2e/0x90
[ 2689.684200]    [<ffffffff811c57e3>] nfs3_proc_access+0xf3/0x1e0
[ 2689.684200]    [<ffffffff811b2bfe>] nfs_do_access+0x11e/0x370
[ 2689.684200]    [<ffffffff811b2ffe>] nfs_permission+0x1ae/0x220
[ 2689.684200]    [<ffffffff81102f80>] inode_permission+0x60/0xa0
[ 2689.684200]    [<ffffffff8110534f>] __link_path_walk+0x8f/0x1090
[ 2689.684200]    [<ffffffff8110657c>] path_walk+0x5c/0xb0
[ 2689.684200]    [<ffffffff81106776>] do_path_lookup+0x96/0x270
[ 2689.684200]    [<ffffffff81106a3a>] path_lookup_open+0x6a/0xe0
[ 2689.684200]    [<ffffffff81107a9f>] do_filp_open+0xcf/0xa20
[ 2689.684200]    [<ffffffff810f6b68>] do_sys_open+0x98/0x140
[ 2689.684200]    [<ffffffff810f6c50>] sys_open+0x20/0x30
[ 2689.684200]    [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[ 2689.684200]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200]      ... acquired at:
[ 2689.684200]    [<ffffffff8107bab4>] __lock_acquire+0x15d4/0x1ae0
[ 2689.684200]    [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]    [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]    [<ffffffff8103a3c3>] task_rq_lock+0x63/0xc0
[ 2689.684200]    [<ffffffff810404a5>] try_to_wake_up+0x45/0x320
[ 2689.684200]    [<ffffffff81040792>] default_wake_function+0x12/0x20
[ 2689.684200]    [<ffffffff81037daa>] __wake_up_common+0x5a/0x90
[ 2689.684200]    [<ffffffff8103a124>] complete+0x44/0x60
[ 2689.684200]    [<ffffffff81065539>] kthread+0x39/0xa0
[ 2689.684200]    [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200]      -> (&ep->lock){......} ops: 0 {
[ 2689.684200]         INITIAL USE at:
[ 2689.684200]                                                 [<ffffffff8107a67f>] __lock_acquire+0x19f/0x1ae0
[ 2689.684200]                                                 [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                                 [<ffffffff815653f6>] _spin_lock_irqsave+0x56/0xa0
[ 2689.684200]                                                 [<ffffffff81131c12>] sys_epoll_ctl+0x412/0x520
[ 2689.684200]                                                 [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[ 2689.684200]                                                 [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]       }
[ 2689.684200]       ... key      at: [<ffffffff822d1710>] __key.23846+0x0/0x10
[ 2689.684200]      ... acquired at:
[ 2689.684200]    [<ffffffff8107bab4>] __lock_acquire+0x15d4/0x1ae0
[ 2689.684200]    [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]    [<ffffffff815653f6>] _spin_lock_irqsave+0x56/0xa0
[ 2689.684200]    [<ffffffff81131234>] ep_poll_callback+0x34/0x130
[ 2689.684200]    [<ffffffff81037daa>] __wake_up_common+0x5a/0x90
[ 2689.684200]    [<ffffffff8103a1c4>] __wake_up_sync_key+0x84/0xb0
[ 2689.684200]    [<ffffffff8142f158>] sock_def_readable+0x48/0x80
[ 2689.684200]    [<ffffffff814afcdd>] unix_stream_sendmsg+0x23d/0x3c0
[ 2689.684200]    [<ffffffff8142af0b>] sock_aio_write+0x12b/0x140
[ 2689.684200]    [<ffffffff810f8d69>] do_sync_write+0xf9/0x140
[ 2689.684200]    [<ffffffff810f9ca8>] vfs_write+0x1c8/0x1d0
[ 2689.684200]    [<ffffffff810f9dc7>] sys_write+0x57/0xb0
[ 2689.684200]    [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[ 2689.684200]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200]     ... acquired at:
[ 2689.684200]    [<ffffffff8107bab4>] __lock_acquire+0x15d4/0x1ae0
[ 2689.684200]    [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]    [<ffffffff815653f6>] _spin_lock_irqsave+0x56/0xa0
[ 2689.684200]    [<ffffffff8103a242>] __wake_up+0x32/0x70
[ 2689.684200]    [<ffffffff81114314>] touch_mnt_namespace+0x34/0x40
[ 2689.684200]    [<ffffffff81114831>] commit_tree+0x101/0x110
[ 2689.684200]    [<ffffffff81115b17>] attach_recursive_mnt+0x2b7/0x2c0
[ 2689.684200]    [<ffffffff81115be1>] graft_tree+0xc1/0xf0
[ 2689.684200]    [<ffffffff81115d04>] do_add_mount+0xf4/0x140
[ 2689.684200]    [<ffffffff81116943>] do_mount+0x2f3/0x8f0
[ 2689.684200]    [<ffffffff8111701b>] sys_mount+0xdb/0x110
[ 2689.684200]    [<ffffffff818adfb9>] do_mount_root+0x21/0xab
[ 2689.684200]    [<ffffffff818ae4bf>] mount_root+0x138/0x141
[ 2689.684200]    [<ffffffff818ae5c0>] prepare_namespace+0xf8/0x198
[ 2689.684200]    [<ffffffff818ad6fe>] kernel_init+0x18b/0x1a8
[ 2689.684200]    [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200]     ... acquired at:
[ 2689.684200]    [<ffffffff8107bab4>] __lock_acquire+0x15d4/0x1ae0
[ 2689.684200]    [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]    [<ffffffff815653f6>] _spin_lock_irqsave+0x56/0xa0
[ 2689.684200]    [<ffffffff81281dee>] debug_check_no_obj_freed+0x8e/0x200
[ 2689.684200]    [<ffffffff810c7bcc>] free_hot_cold_page+0x14c/0x350
[ 2689.684200]    [<ffffffff810c7e60>] free_hot_page+0x10/0x20
[ 2689.684200]    [<ffffffff810c7ee2>] __free_pages+0x72/0x80
[ 2689.684200]    [<ffffffff810c7f6b>] free_pages+0x7b/0x80
[ 2689.684200]    [<ffffffff810f47d5>] slob_free+0x155/0x370
[ 2689.684200]    [<ffffffff810f4a25>] __kmem_cache_free+0x35/0x40
[ 2689.684200]    [<ffffffff810f4afc>] kmem_cache_free+0xcc/0xd0
[ 2689.684200]    [<ffffffff81273011>] ida_get_new_above+0x141/0x210
[ 2689.684200]    [<ffffffff812730ee>] ida_get_new+0xe/0x10
[ 2689.684200]    [<ffffffff81115dbc>] alloc_vfsmnt+0x6c/0x180
[ 2689.684200]    [<ffffffff810fb0d6>] vfs_kern_mount+0x36/0xd0
[ 2689.684200]    [<ffffffff810fb1e5>] do_kern_mount+0x55/0x130
[ 2689.684200]    [<ffffffff81116907>] do_mount+0x2b7/0x8f0
[ 2689.684200]    [<ffffffff8111701b>] sys_mount+0xdb/0x110
[ 2689.684200]    [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[ 2689.684200]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200]    ... acquired at:
[ 2689.684200]    [<ffffffff8107bab4>] __lock_acquire+0x15d4/0x1ae0
[ 2689.684200]    [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]    [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]    [<ffffffff8110d5ee>] __d_path+0x3e/0x190
[ 2689.684200]    [<ffffffff8110d855>] sys_getcwd+0x115/0x1e0
[ 2689.684200]    [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[ 2689.684200]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200]    -> (rename_lock){+.+...} ops: 0 {
[ 2689.684200]       HARDIRQ-ON-W at:
[ 2689.684200]                                              [<ffffffff8107b005>] __lock_acquire+0xb25/0x1ae0
[ 2689.684200]                                              [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                              [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]                                              [<ffffffff8110dfd3>] d_move_locked+0x33/0x260
[ 2689.684200]                                              [<ffffffff8110e233>] d_move+0x33/0x50
[ 2689.684200]                                              [<ffffffff81104b05>] vfs_rename+0x375/0x430
[ 2689.684200]                                              [<ffffffff81106dad>] sys_renameat+0x24d/0x2a0
[ 2689.684200]                                              [<ffffffff81106e1b>] sys_rename+0x1b/0x20
[ 2689.684200]                                              [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[ 2689.684200]                                              [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]       SOFTIRQ-ON-W at:
[ 2689.684200]                                              [<ffffffff8107b031>] __lock_acquire+0xb51/0x1ae0
[ 2689.684200]                                              [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                              [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]                                              [<ffffffff8110dfd3>] d_move_locked+0x33/0x260
[ 2689.684200]                                              [<ffffffff8110e233>] d_move+0x33/0x50
[ 2689.684200]                                              [<ffffffff81104b05>] vfs_rename+0x375/0x430
[ 2689.684200]                                              [<ffffffff81106dad>] sys_renameat+0x24d/0x2a0
[ 2689.684200]                                              [<ffffffff81106e1b>] sys_rename+0x1b/0x20
[ 2689.684200]                                              [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[ 2689.684200]                                              [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]       INITIAL USE at:
[ 2689.684200]                                             [<ffffffff8107a67f>] __lock_acquire+0x19f/0x1ae0
[ 2689.684200]                                             [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                             [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]                                             [<ffffffff8110dfd3>] d_move_locked+0x33/0x260
[ 2689.684200]                                             [<ffffffff8110e233>] d_move+0x33/0x50
[ 2689.684200]                                             [<ffffffff81104b05>] vfs_rename+0x375/0x430
[ 2689.684200]                                             [<ffffffff81106dad>] sys_renameat+0x24d/0x2a0
[ 2689.684200]                                             [<ffffffff81106e1b>] sys_rename+0x1b/0x20
[ 2689.684200]                                             [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[ 2689.684200]                                             [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]     }
[ 2689.684200]     ... key      at: [<ffffffff8189b820>] rename_lock+0x20/0x80
[ 2689.684200]     ... acquired at:
[ 2689.684200]    [<ffffffff8107bab4>] __lock_acquire+0x15d4/0x1ae0
[ 2689.684200]    [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]    [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]    [<ffffffff8110e1a5>] d_move_locked+0x205/0x260
[ 2689.684200]    [<ffffffff8110e233>] d_move+0x33/0x50
[ 2689.684200]    [<ffffffff81104b05>] vfs_rename+0x375/0x430
[ 2689.684200]    [<ffffffff81106dad>] sys_renameat+0x24d/0x2a0
[ 2689.684200]    [<ffffffff81106e1b>] sys_rename+0x1b/0x20
[ 2689.684200]    [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[ 2689.684200]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200]     ... acquired at:
[ 2689.684200]    [<ffffffff8107bab4>] __lock_acquire+0x15d4/0x1ae0
[ 2689.684200]    [<ffffffff8107cc6f>] lock_release_non_nested+0x14f/0x2d0
[ 2689.684200]    [<ffffffff8107cf27>] lock_release+0x137/0x220
[ 2689.684200]    [<ffffffff815650a3>] _spin_unlock+0x23/0x40
[ 2689.684200]    [<ffffffff8110e154>] d_move_locked+0x1b4/0x260
[ 2689.684200]    [<ffffffff8110e233>] d_move+0x33/0x50
[ 2689.684200]    [<ffffffff81104b05>] vfs_rename+0x375/0x430
[ 2689.684200]    [<ffffffff81106dad>] sys_renameat+0x24d/0x2a0
[ 2689.684200]    [<ffffffff81106e1b>] sys_rename+0x1b/0x20
[ 2689.684200]    [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[ 2689.684200]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200]    ... acquired at:
[ 2689.684200]    [<ffffffff8107bab4>] __lock_acquire+0x15d4/0x1ae0
[ 2689.684200]    [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]    [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]    [<ffffffff8110dfd3>] d_move_locked+0x33/0x260
[ 2689.684200]    [<ffffffff8110e233>] d_move+0x33/0x50
[ 2689.684200]    [<ffffffff81104b05>] vfs_rename+0x375/0x430
[ 2689.684200]    [<ffffffff81106dad>] sys_renameat+0x24d/0x2a0
[ 2689.684200]    [<ffffffff81106e1b>] sys_rename+0x1b/0x20
[ 2689.684200]    [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[ 2689.684200]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200]    -> (sb_lock){+.+.-.} ops: 0 {
[ 2689.684200]       HARDIRQ-ON-W at:
[ 2689.684200]                                              [<ffffffff8107b005>] __lock_acquire+0xb25/0x1ae0
[ 2689.684200]                                              [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                              [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]                                              [<ffffffff810fbac4>] sget+0x54/0x490
[ 2689.684200]                                              [<ffffffff810fc566>] get_sb_single+0x46/0x100
[ 2689.684200]                                              [<ffffffff8115056b>] sysfs_get_sb+0x1b/0x20
[ 2689.684200]                                              [<ffffffff810fb0f0>] vfs_kern_mount+0x50/0xd0
[ 2689.684200]                                              [<ffffffff810fb189>] kern_mount_data+0x19/0x20
[ 2689.684200]                                              [<ffffffff818cb634>] sysfs_init+0x7f/0xd4
[ 2689.684200]                                              [<ffffffff818c9e34>] mnt_init+0x9d/0x21e
[ 2689.684200]                                              [<ffffffff818c9984>] vfs_caches_init+0xa8/0x140
[ 2689.684200]                                              [<ffffffff818add0f>] start_kernel+0x34c/0x44f
[ 2689.684200]                                              [<ffffffff818ad299>] x86_64_start_reservations+0x99/0xb9
[ 2689.684200]                                              [<ffffffff818ad3b0>] x86_64_start_kernel+0xf7/0x122
[ 2689.684200]                                              [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]       SOFTIRQ-ON-W at:
[ 2689.684200]                                              [<ffffffff8107b031>] __lock_acquire+0xb51/0x1ae0
[ 2689.684200]                                              [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                              [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]                                              [<ffffffff810fbac4>] sget+0x54/0x490
[ 2689.684200]                                              [<ffffffff810fc566>] get_sb_single+0x46/0x100
[ 2689.684200]                                              [<ffffffff8115056b>] sysfs_get_sb+0x1b/0x20
[ 2689.684200]                                              [<ffffffff810fb0f0>] vfs_kern_mount+0x50/0xd0
[ 2689.684200]                                              [<ffffffff810fb189>] kern_mount_data+0x19/0x20
[ 2689.684200]                                              [<ffffffff818cb634>] sysfs_init+0x7f/0xd4
[ 2689.684200]                                              [<ffffffff818c9e34>] mnt_init+0x9d/0x21e
[ 2689.684200]                                              [<ffffffff818c9984>] vfs_caches_init+0xa8/0x140
[ 2689.684200]                                              [<ffffffff818add0f>] start_kernel+0x34c/0x44f
[ 2689.684200]                                              [<ffffffff818ad299>] x86_64_start_reservations+0x99/0xb9
[ 2689.684200]                                              [<ffffffff818ad3b0>] x86_64_start_kernel+0xf7/0x122
[ 2689.684200]                                              [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]       IN-RECLAIM_FS-W at:
[ 2689.684200]                                                 [<ffffffff8107b142>] __lock_acquire+0xc62/0x1ae0
[ 2689.684200]                                                 [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                                 [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]                                                 [<ffffffff8110cf59>] shrink_dcache_memory+0xa9/0x1e0
[ 2689.684200]                                                 [<ffffffff810d0cc5>] shrink_slab+0x125/0x180
[ 2689.684200]                                                 [<ffffffff810d1540>] kswapd+0x560/0x7a0
[ 2689.684200]                                                 [<ffffffff8106555b>] kthread+0x5b/0xa0
[ 2689.684200]                                                 [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]                                                 [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]       INITIAL USE at:
[ 2689.684200]                                             [<ffffffff8107a67f>] __lock_acquire+0x19f/0x1ae0
[ 2689.684200]                                             [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                             [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]                                             [<ffffffff810fbac4>] sget+0x54/0x490
[ 2689.684200]                                             [<ffffffff810fc566>] get_sb_single+0x46/0x100
[ 2689.684200]                                             [<ffffffff8115056b>] sysfs_get_sb+0x1b/0x20
[ 2689.684200]                                             [<ffffffff810fb0f0>] vfs_kern_mount+0x50/0xd0
[ 2689.684200]                                             [<ffffffff810fb189>] kern_mount_data+0x19/0x20
[ 2689.684200]                                             [<ffffffff818cb634>] sysfs_init+0x7f/0xd4
[ 2689.684200]                                             [<ffffffff818c9e34>] mnt_init+0x9d/0x21e
[ 2689.684200]                                             [<ffffffff818c9984>] vfs_caches_init+0xa8/0x140
[ 2689.684200]                                             [<ffffffff818add0f>] start_kernel+0x34c/0x44f
[ 2689.684200]                                             [<ffffffff818ad299>] x86_64_start_reservations+0x99/0xb9
[ 2689.684200]                                             [<ffffffff818ad3b0>] x86_64_start_kernel+0xf7/0x122
[ 2689.684200]                                             [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]     }
[ 2689.684200]     ... key      at: [<ffffffff817e8d58>] sb_lock+0x18/0x40
[ 2689.684200]     ... acquired at:
[ 2689.684200]    [<ffffffff8107bab4>] __lock_acquire+0x15d4/0x1ae0
[ 2689.684200]    [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]    [<ffffffff815653f6>] _spin_lock_irqsave+0x56/0xa0
[ 2689.684200]    [<ffffffff810f4cc9>] slob_alloc+0x59/0x250
[ 2689.684200]    [<ffffffff810f4fdf>] kmem_cache_alloc_node+0x11f/0x1a0
[ 2689.684200]    [<ffffffff812736da>] idr_pre_get+0x6a/0x90
[ 2689.684200]    [<ffffffff8127371c>] ida_pre_get+0x1c/0x80
[ 2689.684200]    [<ffffffff810fb2f1>] set_anon_super+0x31/0xe0
[ 2689.684200]    [<ffffffff810fbe42>] sget+0x3d2/0x490
[ 2689.684200]    [<ffffffff810fc566>] get_sb_single+0x46/0x100
[ 2689.684200]    [<ffffffff8115056b>] sysfs_get_sb+0x1b/0x20
[ 2689.684200]    [<ffffffff810fb0f0>] vfs_kern_mount+0x50/0xd0
[ 2689.684200]    [<ffffffff810fb189>] kern_mount_data+0x19/0x20
[ 2689.684200]    [<ffffffff818cb634>] sysfs_init+0x7f/0xd4
[ 2689.684200]    [<ffffffff818c9e34>] mnt_init+0x9d/0x21e
[ 2689.684200]    [<ffffffff818c9984>] vfs_caches_init+0xa8/0x140
[ 2689.684200]    [<ffffffff818add0f>] start_kernel+0x34c/0x44f
[ 2689.684200]    [<ffffffff818ad299>] x86_64_start_reservations+0x99/0xb9
[ 2689.684200]    [<ffffffff818ad3b0>] x86_64_start_kernel+0xf7/0x122
[ 2689.684200]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200]     -> (unnamed_dev_ida.lock){......} ops: 0 {
[ 2689.684200]        INITIAL USE at:
[ 2689.684200]                                               [<ffffffff8107a67f>] __lock_acquire+0x19f/0x1ae0
[ 2689.684200]                                               [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                               [<ffffffff815653f6>] _spin_lock_irqsave+0x56/0xa0
[ 2689.684200]                                               [<ffffffff812736a0>] idr_pre_get+0x30/0x90
[ 2689.684200]                                               [<ffffffff8127371c>] ida_pre_get+0x1c/0x80
[ 2689.684200]                                               [<ffffffff810fb2f1>] set_anon_super+0x31/0xe0
[ 2689.684200]                                               [<ffffffff810fbe42>] sget+0x3d2/0x490
[ 2689.684200]                                               [<ffffffff810fc566>] get_sb_single+0x46/0x100
[ 2689.684200]                                               [<ffffffff8115056b>] sysfs_get_sb+0x1b/0x20
[ 2689.684200]                                               [<ffffffff810fb0f0>] vfs_kern_mount+0x50/0xd0
[ 2689.684200]                                               [<ffffffff810fb189>] kern_mount_data+0x19/0x20
[ 2689.684200]                                               [<ffffffff818cb634>] sysfs_init+0x7f/0xd4
[ 2689.684200]                                               [<ffffffff818c9e34>] mnt_init+0x9d/0x21e
[ 2689.684200]                                               [<ffffffff818c9984>] vfs_caches_init+0xa8/0x140
[ 2689.684200]                                               [<ffffffff818add0f>] start_kernel+0x34c/0x44f
[ 2689.684200]                                               [<ffffffff818ad299>] x86_64_start_reservations+0x99/0xb9
[ 2689.684200]                                               [<ffffffff818ad3b0>] x86_64_start_kernel+0xf7/0x122
[ 2689.684200]                                               [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]      }
[ 2689.684200]      ... key      at: [<ffffffff817e8df0>] unnamed_dev_ida+0x30/0x60
[ 2689.684200]     ... acquired at:
[ 2689.684200]    [<ffffffff8107bab4>] __lock_acquire+0x15d4/0x1ae0
[ 2689.684200]    [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]    [<ffffffff815653f6>] _spin_lock_irqsave+0x56/0xa0
[ 2689.684200]    [<ffffffff812736a0>] idr_pre_get+0x30/0x90
[ 2689.684200]    [<ffffffff8127371c>] ida_pre_get+0x1c/0x80
[ 2689.684200]    [<ffffffff810fb2f1>] set_anon_super+0x31/0xe0
[ 2689.684200]    [<ffffffff810fbe42>] sget+0x3d2/0x490
[ 2689.684200]    [<ffffffff810fc566>] get_sb_single+0x46/0x100
[ 2689.684200]    [<ffffffff8115056b>] sysfs_get_sb+0x1b/0x20
[ 2689.684200]    [<ffffffff810fb0f0>] vfs_kern_mount+0x50/0xd0
[ 2689.684200]    [<ffffffff810fb189>] kern_mount_data+0x19/0x20
[ 2689.684200]    [<ffffffff818cb634>] sysfs_init+0x7f/0xd4
[ 2689.684200]    [<ffffffff818c9e34>] mnt_init+0x9d/0x21e
[ 2689.684200]    [<ffffffff818c9984>] vfs_caches_init+0xa8/0x140
[ 2689.684200]    [<ffffffff818add0f>] start_kernel+0x34c/0x44f
[ 2689.684200]    [<ffffffff818ad299>] x86_64_start_reservations+0x99/0xb9
[ 2689.684200]    [<ffffffff818ad3b0>] x86_64_start_kernel+0xf7/0x122
[ 2689.684200]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200]     -> (unnamed_dev_lock){+.+...} ops: 0 {
[ 2689.684200]        HARDIRQ-ON-W at:
[ 2689.684200]                                                [<ffffffff8107b005>] __lock_acquire+0xb25/0x1ae0
[ 2689.684200]                                                [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                                [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]                                                [<ffffffff810fb301>] set_anon_super+0x41/0xe0
[ 2689.684200]                                                [<ffffffff810fbe42>] sget+0x3d2/0x490
[ 2689.684200]                                                [<ffffffff810fc566>] get_sb_single+0x46/0x100
[ 2689.684200]                                                [<ffffffff8115056b>] sysfs_get_sb+0x1b/0x20
[ 2689.684200]                                                [<ffffffff810fb0f0>] vfs_kern_mount+0x50/0xd0
[ 2689.684200]                                                [<ffffffff810fb189>] kern_mount_data+0x19/0x20
[ 2689.684200]                                                [<ffffffff818cb634>] sysfs_init+0x7f/0xd4
[ 2689.684200]                                                [<ffffffff818c9e34>] mnt_init+0x9d/0x21e
[ 2689.684200]                                                [<ffffffff818c9984>] vfs_caches_init+0xa8/0x140
[ 2689.684200]                                                [<ffffffff818add0f>] start_kernel+0x34c/0x44f
[ 2689.684200]                                                [<ffffffff818ad299>] x86_64_start_reservations+0x99/0xb9
[ 2689.684200]                                                [<ffffffff818ad3b0>] x86_64_start_kernel+0xf7/0x122
[ 2689.684200]                                                [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]        SOFTIRQ-ON-W at:
[ 2689.684200]                                                [<ffffffff8107b031>] __lock_acquire+0xb51/0x1ae0
[ 2689.684200]                                                [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                                [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]                                                [<ffffffff810fb301>] set_anon_super+0x41/0xe0
[ 2689.684200]                                                [<ffffffff810fbe42>] sget+0x3d2/0x490
[ 2689.684200]                                                [<ffffffff810fc566>] get_sb_single+0x46/0x100
[ 2689.684200]                                                [<ffffffff8115056b>] sysfs_get_sb+0x1b/0x20
[ 2689.684200]                                                [<ffffffff810fb0f0>] vfs_kern_mount+0x50/0xd0
[ 2689.684200]                                                [<ffffffff810fb189>] kern_mount_data+0x19/0x20
[ 2689.684200]                                                [<ffffffff818cb634>] sysfs_init+0x7f/0xd4
[ 2689.684200]                                                [<ffffffff818c9e34>] mnt_init+0x9d/0x21e
[ 2689.684200]                                                [<ffffffff818c9984>] vfs_caches_init+0xa8/0x140
[ 2689.684200]                                                [<ffffffff818add0f>] start_kernel+0x34c/0x44f
[ 2689.684200]                                                [<ffffffff818ad299>] x86_64_start_reservations+0x99/0xb9
[ 2689.684200]                                                [<ffffffff818ad3b0>] x86_64_start_kernel+0xf7/0x122
[ 2689.684200]                                                [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]        INITIAL USE at:
[ 2689.684200]                                               [<ffffffff8107a67f>] __lock_acquire+0x19f/0x1ae0
[ 2689.684200]                                               [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                               [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]                                               [<ffffffff810fb301>] set_anon_super+0x41/0xe0
[ 2689.684200]                                               [<ffffffff810fbe42>] sget+0x3d2/0x490
[ 2689.684200]                                               [<ffffffff810fc566>] get_sb_single+0x46/0x100
[ 2689.684200]                                               [<ffffffff8115056b>] sysfs_get_sb+0x1b/0x20
[ 2689.684200]                                               [<ffffffff810fb0f0>] vfs_kern_mount+0x50/0xd0
[ 2689.684200]                                               [<ffffffff810fb189>] kern_mount_data+0x19/0x20
[ 2689.684200]                                               [<ffffffff818cb634>] sysfs_init+0x7f/0xd4
[ 2689.684200]                                               [<ffffffff818c9e34>] mnt_init+0x9d/0x21e
[ 2689.684200]                                               [<ffffffff818c9984>] vfs_caches_init+0xa8/0x140
[ 2689.684200]                                               [<ffffffff818add0f>] start_kernel+0x34c/0x44f
[ 2689.684200]                                               [<ffffffff818ad299>] x86_64_start_reservations+0x99/0xb9
[ 2689.684200]                                               [<ffffffff818ad3b0>] x86_64_start_kernel+0xf7/0x122
[ 2689.684200]                                               [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]      }
[ 2689.684200]      ... key      at: [<ffffffff817e8d98>] unnamed_dev_lock+0x18/0x40
[ 2689.684200]      ... acquired at:
[ 2689.684200]    [<ffffffff8107bab4>] __lock_acquire+0x15d4/0x1ae0
[ 2689.684200]    [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]    [<ffffffff815653f6>] _spin_lock_irqsave+0x56/0xa0
[ 2689.684200]    [<ffffffff81272963>] get_from_free_list+0x23/0x60
[ 2689.684200]    [<ffffffff81272ead>] idr_get_empty_slot+0x2bd/0x2e0
[ 2689.684200]    [<ffffffff81272f8e>] ida_get_new_above+0xbe/0x210
[ 2689.684200]    [<ffffffff812730ee>] ida_get_new+0xe/0x10
[ 2689.684200]    [<ffffffff810fb310>] set_anon_super+0x50/0xe0
[ 2689.684200]    [<ffffffff810fbe42>] sget+0x3d2/0x490
[ 2689.684200]    [<ffffffff810fc566>] get_sb_single+0x46/0x100
[ 2689.684200]    [<ffffffff8115056b>] sysfs_get_sb+0x1b/0x20
[ 2689.684200]    [<ffffffff810fb0f0>] vfs_kern_mount+0x50/0xd0
[ 2689.684200]    [<ffffffff810fb189>] kern_mount_data+0x19/0x20
[ 2689.684200]    [<ffffffff818cb634>] sysfs_init+0x7f/0xd4
[ 2689.684200]    [<ffffffff818c9e34>] mnt_init+0x9d/0x21e
[ 2689.684200]    [<ffffffff818c9984>] vfs_caches_init+0xa8/0x140
[ 2689.684200]    [<ffffffff818add0f>] start_kernel+0x34c/0x44f
[ 2689.684200]    [<ffffffff818ad299>] x86_64_start_reservations+0x99/0xb9
[ 2689.684200]    [<ffffffff818ad3b0>] x86_64_start_kernel+0xf7/0x122
[ 2689.684200]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200]      ... acquired at:
[ 2689.684200]    [<ffffffff8107bab4>] __lock_acquire+0x15d4/0x1ae0
[ 2689.684200]    [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]    [<ffffffff815653f6>] _spin_lock_irqsave+0x56/0xa0
[ 2689.684200]    [<ffffffff810f4721>] slob_free+0xa1/0x370
[ 2689.684200]    [<ffffffff810f4a25>] __kmem_cache_free+0x35/0x40
[ 2689.684200]    [<ffffffff810f4afc>] kmem_cache_free+0xcc/0xd0
[ 2689.684200]    [<ffffffff81273011>] ida_get_new_above+0x141/0x210
[ 2689.684200]    [<ffffffff812730ee>] ida_get_new+0xe/0x10
[ 2689.684200]    [<ffffffff810fb310>] set_anon_super+0x50/0xe0
[ 2689.684200]    [<ffffffff810fbe42>] sget+0x3d2/0x490
[ 2689.684200]    [<ffffffff810fc566>] get_sb_single+0x46/0x100
[ 2689.684200]    [<ffffffff8115056b>] sysfs_get_sb+0x1b/0x20
[ 2689.684200]    [<ffffffff810fb0f0>] vfs_kern_mount+0x50/0xd0
[ 2689.684200]    [<ffffffff810fb189>] kern_mount_data+0x19/0x20
[ 2689.684200]    [<ffffffff818cb634>] sysfs_init+0x7f/0xd4
[ 2689.684200]    [<ffffffff818c9e34>] mnt_init+0x9d/0x21e
[ 2689.684200]    [<ffffffff818c9984>] vfs_caches_init+0xa8/0x140
[ 2689.684200]    [<ffffffff818add0f>] start_kernel+0x34c/0x44f
[ 2689.684200]    [<ffffffff818ad299>] x86_64_start_reservations+0x99/0xb9
[ 2689.684200]    [<ffffffff818ad3b0>] x86_64_start_kernel+0xf7/0x122
[ 2689.684200]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200]     ... acquired at:
[ 2689.684200]    [<ffffffff8107bab4>] __lock_acquire+0x15d4/0x1ae0
[ 2689.684200]    [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]    [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]    [<ffffffff810fb301>] set_anon_super+0x41/0xe0
[ 2689.684200]    [<ffffffff810fbe42>] sget+0x3d2/0x490
[ 2689.684200]    [<ffffffff810fc566>] get_sb_single+0x46/0x100
[ 2689.684200]    [<ffffffff8115056b>] sysfs_get_sb+0x1b/0x20
[ 2689.684200]    [<ffffffff810fb0f0>] vfs_kern_mount+0x50/0xd0
[ 2689.684200]    [<ffffffff810fb189>] kern_mount_data+0x19/0x20
[ 2689.684200]    [<ffffffff818cb634>] sysfs_init+0x7f/0xd4
[ 2689.684200]    [<ffffffff818c9e34>] mnt_init+0x9d/0x21e
[ 2689.684200]    [<ffffffff818c9984>] vfs_caches_init+0xa8/0x140
[ 2689.684200]    [<ffffffff818add0f>] start_kernel+0x34c/0x44f
[ 2689.684200]    [<ffffffff818ad299>] x86_64_start_reservations+0x99/0xb9
[ 2689.684200]    [<ffffffff818ad3b0>] x86_64_start_kernel+0xf7/0x122
[ 2689.684200]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200]     ... acquired at:
[ 2689.684200]    [<ffffffff8107bab4>] __lock_acquire+0x15d4/0x1ae0
[ 2689.684200]    [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]    [<ffffffff815653f6>] _spin_lock_irqsave+0x56/0xa0
[ 2689.684200]    [<ffffffff81281dee>] debug_check_no_obj_freed+0x8e/0x200
[ 2689.684200]    [<ffffffff810c7bcc>] free_hot_cold_page+0x14c/0x350
[ 2689.684200]    [<ffffffff810c7e60>] free_hot_page+0x10/0x20
[ 2689.684200]    [<ffffffff810c7ee2>] __free_pages+0x72/0x80
[ 2689.684200]    [<ffffffff810c7f6b>] free_pages+0x7b/0x80
[ 2689.684200]    [<ffffffff810f47d5>] slob_free+0x155/0x370
[ 2689.684200]    [<ffffffff810f521a>] kfree+0xda/0xf0
[ 2689.684200]    [<ffffffff810fb475>] __put_super+0x45/0x60
[ 2689.684200]    [<ffffffff810fb4b5>] put_super+0x25/0x40
[ 2689.684200]    [<ffffffff810fc50b>] deactivate_super+0x6b/0x80
[ 2689.684200]    [<ffffffff81114f8c>] mntput_no_expire+0x18c/0x1c0
[ 2689.684200]    [<ffffffff81115337>] sys_umount+0x67/0x380
[ 2689.684200]    [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[ 2689.684200]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200]     ... acquired at:
[ 2689.684200]    [<ffffffff8107bab4>] __lock_acquire+0x15d4/0x1ae0
[ 2689.684200]    [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]    [<ffffffff815653f6>] _spin_lock_irqsave+0x56/0xa0
[ 2689.684200]    [<ffffffff81281cd6>] free_object+0x16/0xa0
[ 2689.684200]    [<ffffffff81281f26>] debug_check_no_obj_freed+0x1c6/0x200
[ 2689.684200]    [<ffffffff810c7bcc>] free_hot_cold_page+0x14c/0x350
[ 2689.684200]    [<ffffffff810c7e60>] free_hot_page+0x10/0x20
[ 2689.684200]    [<ffffffff810c7ee2>] __free_pages+0x72/0x80
[ 2689.684200]    [<ffffffff810c7f6b>] free_pages+0x7b/0x80
[ 2689.684200]    [<ffffffff810f47d5>] slob_free+0x155/0x370
[ 2689.684200]    [<ffffffff810f521a>] kfree+0xda/0xf0
[ 2689.684200]    [<ffffffff810fb475>] __put_super+0x45/0x60
[ 2689.684200]    [<ffffffff810fb4b5>] put_super+0x25/0x40
[ 2689.684200]    [<ffffffff810fc50b>] deactivate_super+0x6b/0x80
[ 2689.684200]    [<ffffffff81114f8c>] mntput_no_expire+0x18c/0x1c0
[ 2689.684200]    [<ffffffff81115337>] sys_umount+0x67/0x380
[ 2689.684200]    [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[ 2689.684200]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200]    ... acquired at:
[ 2689.684200]    [<ffffffff8107bab4>] __lock_acquire+0x15d4/0x1ae0
[ 2689.684200]    [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]    [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]    [<ffffffff8110cf59>] shrink_dcache_memory+0xa9/0x1e0
[ 2689.684200]    [<ffffffff810d0cc5>] shrink_slab+0x125/0x180
[ 2689.684200]    [<ffffffff810d1540>] kswapd+0x560/0x7a0
[ 2689.684200]    [<ffffffff8106555b>] kthread+0x5b/0xa0
[ 2689.684200]    [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200]    -> (&sem->wait_lock){....-.} ops: 0 {
[ 2689.684200]       IN-RECLAIM_FS-W at:
[ 2689.684200]                                                 [<ffffffff8107b142>] __lock_acquire+0xc62/0x1ae0
[ 2689.684200]                                                 [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                                 [<ffffffff815653f6>] _spin_lock_irqsave+0x56/0xa0
[ 2689.684200]                                                 [<ffffffff81277ec0>] __down_read_trylock+0x20/0x60
[ 2689.684200]                                                 [<ffffffff8106a67d>] down_read_trylock+0x1d/0x60
[ 2689.684200]                                                 [<ffffffff8110cfcf>] shrink_dcache_memory+0x11f/0x1e0
[ 2689.684200]                                                 [<ffffffff810d0cc5>] shrink_slab+0x125/0x180
[ 2689.684200]                                                 [<ffffffff810d1540>] kswapd+0x560/0x7a0
[ 2689.684200]                                                 [<ffffffff8106555b>] kthread+0x5b/0xa0
[ 2689.684200]                                                 [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]                                                 [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]       INITIAL USE at:
[ 2689.684200]                                             [<ffffffff8107a67f>] __lock_acquire+0x19f/0x1ae0
[ 2689.684200]                                             [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                             [<ffffffff815653f6>] _spin_lock_irqsave+0x56/0xa0
[ 2689.684200]                                             [<ffffffff81277e60>] __down_write_trylock+0x20/0x60
[ 2689.684200]                                             [<ffffffff8106a53f>] down_write_nested+0x5f/0xa0
[ 2689.684200]                                             [<ffffffff810fbc8d>] sget+0x21d/0x490
[ 2689.684200]                                             [<ffffffff810fc566>] get_sb_single+0x46/0x100
[ 2689.684200]                                             [<ffffffff8115056b>] sysfs_get_sb+0x1b/0x20
[ 2689.684200]                                             [<ffffffff810fb0f0>] vfs_kern_mount+0x50/0xd0
[ 2689.684200]                                             [<ffffffff810fb189>] kern_mount_data+0x19/0x20
[ 2689.684200]                                             [<ffffffff818cb634>] sysfs_init+0x7f/0xd4
[ 2689.684200]                                             [<ffffffff818c9e34>] mnt_init+0x9d/0x21e
[ 2689.684200]                                             [<ffffffff818c9984>] vfs_caches_init+0xa8/0x140
[ 2689.684200]                                             [<ffffffff818add0f>] start_kernel+0x34c/0x44f
[ 2689.684200]                                             [<ffffffff818ad299>] x86_64_start_reservations+0x99/0xb9
[ 2689.684200]                                             [<ffffffff818ad3b0>] x86_64_start_kernel+0xf7/0x122
[ 2689.684200]                                             [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]     }
[ 2689.684200]     ... key      at: [<ffffffff822dded8>] __key.16656+0x0/0x8
[ 2689.684200]     ... acquired at:
[ 2689.684200]    [<ffffffff8107bab4>] __lock_acquire+0x15d4/0x1ae0
[ 2689.684200]    [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]    [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]    [<ffffffff8103a3c3>] task_rq_lock+0x63/0xc0
[ 2689.684200]    [<ffffffff810404a5>] try_to_wake_up+0x45/0x320
[ 2689.684200]    [<ffffffff810407d5>] wake_up_process+0x15/0x20
[ 2689.684200]    [<ffffffff81278079>] __up_write+0x99/0x120
[ 2689.684200]    [<ffffffff8106a73b>] up_write+0x2b/0x40
[ 2689.684200]    [<ffffffff81048a9e>] dup_mm+0x45e/0x4c0
[ 2689.684200]    [<ffffffff8104a0b7>] copy_process+0x1567/0x16d0
[ 2689.684200]    [<ffffffff8104a309>] do_fork+0xe9/0x520
[ 2689.684200]    [<ffffffff8100a5d8>] sys_clone+0x28/0x30
[ 2689.684200]    [<ffffffff8100c6a3>] stub_clone+0x13/0x20
[ 2689.684200]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200]    ... acquired at:
[ 2689.684200]    [<ffffffff8107bab4>] __lock_acquire+0x15d4/0x1ae0
[ 2689.684200]    [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]    [<ffffffff815653f6>] _spin_lock_irqsave+0x56/0xa0
[ 2689.684200]    [<ffffffff81277ec0>] __down_read_trylock+0x20/0x60
[ 2689.684200]    [<ffffffff8106a67d>] down_read_trylock+0x1d/0x60
[ 2689.684200]    [<ffffffff8110cfcf>] shrink_dcache_memory+0x11f/0x1e0
[ 2689.684200]    [<ffffffff810d0cc5>] shrink_slab+0x125/0x180
[ 2689.684200]    [<ffffffff810d1540>] kswapd+0x560/0x7a0
[ 2689.684200]    [<ffffffff8106555b>] kthread+0x5b/0xa0
[ 2689.684200]    [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2689.684200]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200]   ... acquired at:
[ 2689.684200]    [<ffffffff8107bab4>] __lock_acquire+0x15d4/0x1ae0
[ 2689.684200]    [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]    [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]    [<ffffffff8112eb28>] set_dentry_child_flags+0x28/0xf0
[ 2689.684200]    [<ffffffff8112ed4e>] inotify_add_watch+0x15e/0x170
[ 2689.684200]    [<ffffffff811302c8>] sys_inotify_add_watch+0x268/0x290
[ 2689.684200]    [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[ 2689.684200]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200]   -> (&dev->ev_mutex){+.+.+.} ops: 0 {
[ 2689.684200]      HARDIRQ-ON-W at:
[ 2689.684200]                                            [<ffffffff8107b005>] __lock_acquire+0xb25/0x1ae0
[ 2689.684200]                                            [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                            [<ffffffff81562da3>] mutex_lock_nested+0x63/0x420
[ 2689.684200]                                            [<ffffffff8112fa58>] inotify_poll+0x48/0x80
[ 2689.684200]                                            [<ffffffff8110b5b1>] do_select+0x3b1/0x730
[ 2689.684200]                                            [<ffffffff8110bb40>] core_sys_select+0x210/0x370
[ 2689.684200]                                            [<ffffffff8110bf3f>] sys_select+0x4f/0x110
[ 2689.684200]                                            [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[ 2689.684200]                                            [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]      SOFTIRQ-ON-W at:
[ 2689.684200]                                            [<ffffffff8107b031>] __lock_acquire+0xb51/0x1ae0
[ 2689.684200]                                            [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                            [<ffffffff81562da3>] mutex_lock_nested+0x63/0x420
[ 2689.684200]                                            [<ffffffff8112fa58>] inotify_poll+0x48/0x80
[ 2689.684200]                                            [<ffffffff8110b5b1>] do_select+0x3b1/0x730
[ 2689.684200]                                            [<ffffffff8110bb40>] core_sys_select+0x210/0x370
[ 2689.684200]                                            [<ffffffff8110bf3f>] sys_select+0x4f/0x110
[ 2689.684200]                                            [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[ 2689.684200]                                            [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]      RECLAIM_FS-ON-W at:
[ 2689.684200]                                               [<ffffffff81079188>] mark_held_locks+0x68/0x90
[ 2689.684200]                                               [<ffffffff810792a5>] lockdep_trace_alloc+0xf5/0x100
[ 2689.684200]                                               [<ffffffff810f5261>] __kmalloc_node+0x31/0x1e0
[ 2689.684200]                                               [<ffffffff811306c2>] kernel_event+0xe2/0x190
[ 2689.684200]                                               [<ffffffff81130896>] inotify_dev_queue_event+0x126/0x230
[ 2689.684200]                                               [<ffffffff8112f0a6>] inotify_inode_queue_event+0xc6/0x110
[ 2689.684200]                                               [<ffffffff8110444d>] vfs_create+0xcd/0x140
[ 2689.684200]                                               [<ffffffff8110825d>] do_filp_open+0x88d/0xa20
[ 2689.684200]                                               [<ffffffff810f6b68>] do_sys_open+0x98/0x140
[ 2689.684200]                                               [<ffffffff810f6c50>] sys_open+0x20/0x30
[ 2689.684200]                                               [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[ 2689.684200]                                               [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]      INITIAL USE at:
[ 2689.684200]                                           [<ffffffff8107a67f>] __lock_acquire+0x19f/0x1ae0
[ 2689.684200]                                           [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]                                           [<ffffffff81562da3>] mutex_lock_nested+0x63/0x420
[ 2689.684200]                                           [<ffffffff8112fa58>] inotify_poll+0x48/0x80
[ 2689.684200]                                           [<ffffffff8110b5b1>] do_select+0x3b1/0x730
[ 2689.684200]                                           [<ffffffff8110bb40>] core_sys_select+0x210/0x370
[ 2689.684200]                                           [<ffffffff8110bf3f>] sys_select+0x4f/0x110
[ 2689.684200]                                           [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[ 2689.684200]                                           [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]    }
[ 2689.684200]    ... key      at: [<ffffffff822d16f4>] __key.21140+0x0/0x8
[ 2689.684200]    ... acquired at:
[ 2689.684200]    [<ffffffff8107bab4>] __lock_acquire+0x15d4/0x1ae0
[ 2689.684200]    [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]    [<ffffffff815653f6>] _spin_lock_irqsave+0x56/0xa0
[ 2689.684200]    [<ffffffff810f4cc9>] slob_alloc+0x59/0x250
[ 2689.684200]    [<ffffffff810f4fdf>] kmem_cache_alloc_node+0x11f/0x1a0
[ 2689.684200]    [<ffffffff81130626>] kernel_event+0x46/0x190
[ 2689.684200]    [<ffffffff81130896>] inotify_dev_queue_event+0x126/0x230
[ 2689.684200]    [<ffffffff8112f0a6>] inotify_inode_queue_event+0xc6/0x110
[ 2689.684200]    [<ffffffff8110444d>] vfs_create+0xcd/0x140
[ 2689.684200]    [<ffffffff8110825d>] do_filp_open+0x88d/0xa20
[ 2689.684200]    [<ffffffff810f6b68>] do_sys_open+0x98/0x140
[ 2689.684200]    [<ffffffff810f6c50>] sys_open+0x20/0x30
[ 2689.684200]    [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[ 2689.684200]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200]    ... acquired at:
[ 2689.684200]    [<ffffffff8107bab4>] __lock_acquire+0x15d4/0x1ae0
[ 2689.684200]    [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]    [<ffffffff815653f6>] _spin_lock_irqsave+0x56/0xa0
[ 2689.684200]    [<ffffffff8103a242>] __wake_up+0x32/0x70
[ 2689.684200]    [<ffffffff81130901>] inotify_dev_queue_event+0x191/0x230
[ 2689.684200]    [<ffffffff8112f0a6>] inotify_inode_queue_event+0xc6/0x110
[ 2689.684200]    [<ffffffff8110444d>] vfs_create+0xcd/0x140
[ 2689.684200]    [<ffffffff8110825d>] do_filp_open+0x88d/0xa20
[ 2689.684200]    [<ffffffff810f6b68>] do_sys_open+0x98/0x140
[ 2689.684200]    [<ffffffff810f6c50>] sys_open+0x20/0x30
[ 2689.684200]    [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[ 2689.684200]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200]   ... acquired at:
[ 2689.684200]    [<ffffffff8107bab4>] __lock_acquire+0x15d4/0x1ae0
[ 2689.684200]    [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]    [<ffffffff81562da3>] mutex_lock_nested+0x63/0x420
[ 2689.684200]    [<ffffffff811307b7>] inotify_dev_queue_event+0x47/0x230
[ 2689.684200]    [<ffffffff8112f0a6>] inotify_inode_queue_event+0xc6/0x110
[ 2689.684200]    [<ffffffff8110444d>] vfs_create+0xcd/0x140
[ 2689.684200]    [<ffffffff8110825d>] do_filp_open+0x88d/0xa20
[ 2689.684200]    [<ffffffff810f6b68>] do_sys_open+0x98/0x140
[ 2689.684200]    [<ffffffff810f6c50>] sys_open+0x20/0x30
[ 2689.684200]    [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[ 2689.684200]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200]   ... acquired at:
[ 2689.684200]    [<ffffffff8107bab4>] __lock_acquire+0x15d4/0x1ae0
[ 2689.684200]    [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]    [<ffffffff81565276>] _spin_lock+0x36/0x70
[ 2689.684200]    [<ffffffff8112e834>] pin_to_kill+0x44/0x160
[ 2689.684200]    [<ffffffff8112f606>] inotify_destroy+0x56/0x120
[ 2689.684200]    [<ffffffff8112fabd>] inotify_release+0x2d/0xf0
[ 2689.684200]    [<ffffffff810faab4>] __fput+0x124/0x2f0
[ 2689.684200]    [<ffffffff810faca5>] fput+0x25/0x30
[ 2689.684200]    [<ffffffff810f6943>] filp_close+0x63/0x90
[ 2689.684200]    [<ffffffff810f6a2e>] sys_close+0xbe/0x160
[ 2689.684200]    [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[ 2689.684200]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200]  ... acquired at:
[ 2689.684200]    [<ffffffff8107bab4>] __lock_acquire+0x15d4/0x1ae0
[ 2689.684200]    [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]    [<ffffffff81562da3>] mutex_lock_nested+0x63/0x420
[ 2689.684200]    [<ffffffff8112edf7>] inotify_find_update_watch+0x97/0x130
[ 2689.684200]    [<ffffffff811301e4>] sys_inotify_add_watch+0x184/0x290
[ 2689.684200]    [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[ 2689.684200]    [<ffffffffffffffff>] 0xffffffffffffffff
[ 2689.684200]
[ 2689.684200]
[ 2689.684200] stack backtrace:
[ 2689.684200] Pid: 3548, comm: umount Not tainted 2.6.30-rc2-next-20090417 #210
[ 2689.684200] Call Trace:
[ 2689.684200]  [<ffffffff8107a324>] check_usage+0x3d4/0x490
[ 2689.684200]  [<ffffffff8107a444>] check_irq_usage+0x64/0x100
[ 2689.684200]  [<ffffffff8107b8ce>] __lock_acquire+0x13ee/0x1ae0
[ 2689.684200]  [<ffffffff81079fee>] ? check_usage+0x9e/0x490
[ 2689.684200]  [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2689.684200]  [<ffffffff8112f7da>] ? inotify_unmount_inodes+0xda/0x1f0
[ 2689.684200]  [<ffffffff81562da3>] mutex_lock_nested+0x63/0x420
[ 2689.684200]  [<ffffffff8112f7da>] ? inotify_unmount_inodes+0xda/0x1f0
[ 2689.684200]  [<ffffffff81077165>] ? lock_release_holdtime+0x35/0x1c0
[ 2689.684200]  [<ffffffff8112f7da>] ? inotify_unmount_inodes+0xda/0x1f0
[ 2689.684200]  [<ffffffff812810ad>] ? _raw_spin_unlock+0xcd/0x120
[ 2689.684200]  [<ffffffff8112f7da>] inotify_unmount_inodes+0xda/0x1f0
[ 2689.684200]  [<ffffffff81110e09>] ? invalidate_inodes+0x49/0x170
[ 2689.684200]  [<ffffffff81110e11>] invalidate_inodes+0x51/0x170
[ 2689.684200]  [<ffffffff810fc30b>] generic_shutdown_super+0x4b/0x110
[ 2689.684200]  [<ffffffff810fc401>] kill_block_super+0x31/0x50
[ 2689.684200]  [<ffffffff810fc4fb>] deactivate_super+0x5b/0x80
[ 2689.684200]  [<ffffffff81114f8c>] mntput_no_expire+0x18c/0x1c0
[ 2689.684200]  [<ffffffff81115337>] sys_umount+0x67/0x380
[ 2689.684200]  [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[ 2716.663141] EXT4-fs: mballoc: 0 blocks 0 reqs (0 success)
[ 2716.668695] EXT4-fs: mballoc: 0 extents scanned, 0 goal hits, 0 2^N hits, 0 breaks, 0 lost
[ 2716.677094] EXT4-fs: mballoc: 0 generated and it took 0
[ 2716.682417] EXT4-fs: mballoc: 0 preallocated, 0 discarded

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
