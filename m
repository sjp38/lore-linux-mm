Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id BCB7B6B003D
	for <linux-mm@kvack.org>; Sat,  2 May 2009 04:04:30 -0400 (EDT)
Date: Sat, 2 May 2009 16:04:05 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] use GFP_NOFS in kernel_event()
Message-ID: <20090502080405.GA6432@localhost>
References: <20090430020004.GA1898@localhost> <20090429191044.b6fceae2.akpm@linux-foundation.org> <1241097573.6020.7.camel@localhost.localdomain> <20090430134821.GB8644@localhost> <20090430142807.GA13931@localhost> <1241103132.6020.17.camel@localhost.localdomain> <20090502022515.GB29422@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090502022515.GB29422@localhost>
Sender: owner-linux-mm@kvack.org
To: Eric Paris <eparis@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Matt Mackall <mpm@selenic.com>, Ingo Molnar <mingo@elte.hu>, Al Viro <viro@zeniv.linux.org.uk>, "peterz@infradead.org" <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Sat, May 02, 2009 at 10:25:15AM +0800, Wu Fengguang wrote:
> On Thu, Apr 30, 2009 at 10:52:12PM +0800, Eric Paris wrote:
> > On Thu, 2009-04-30 at 22:28 +0800, Wu Fengguang wrote:
> > > On Thu, Apr 30, 2009 at 09:48:21PM +0800, Wu Fengguang wrote:
> > > > On Thu, Apr 30, 2009 at 09:19:33PM +0800, Eric Paris wrote:
> > > > > On Wed, 2009-04-29 at 19:10 -0700, Andrew Morton wrote:
> > > > > > On Thu, 30 Apr 2009 10:00:04 +0800 Wu Fengguang <fengguang.wu@intel.com> wrote:
> > > > > > 
> > > > > > > Fix a possible deadlock on inotify_mutex, reported by lockdep.
> > > > > > > 
> > > > > > > inotify_inode_queue_event() => take inotify_mutex => kernel_event() =>
> > > > > > > kmalloc() => SLOB => alloc_pages_node() => page reclaim => slab reclaim =>
> > > > > > > dcache reclaim => inotify_inode_is_dead => take inotify_mutex => deadlock
> > > > > > > 
> > > > > > > The actual deadlock may not happen because the inode was grabbed at
> > > > > > > inotify_add_watch(). But the GFP_KERNEL here is unsound and not
> > > > > > > consistent with the other two GFP_NOFS inside the same function.
> > > > > > > 
> > > > > > > [ 2668.325318]
> > > > > > > [ 2668.325322] =================================
> > > > > > > [ 2668.327448] [ INFO: inconsistent lock state ]
> > > > > > > [ 2668.327448] 2.6.30-rc2-next-20090417 #203
> > > > > > > [ 2668.327448] ---------------------------------
> > > > > > > [ 2668.327448] inconsistent {RECLAIM_FS-ON-W} -> {IN-RECLAIM_FS-W} usage.
> > > > > > > [ 2668.327448] kswapd0/380 [HC0[0]:SC0[0]:HE1:SE1] takes:
> > > > > > > [ 2668.327448]  (&inode->inotify_mutex){+.+.?.}, at: [<ffffffff8112f1b5>] inotify_inode_is_dead+0x35/0xb0
> > > > > 
> > > > > 
> > > > > > > [ 2668.327448] Pid: 380, comm: kswapd0 Not tainted 2.6.30-rc2-next-20090417 #203
> > > > > > > [ 2668.327448] Call Trace:
> > > > > > > [ 2668.327448]  [<ffffffff810789ef>] print_usage_bug+0x19f/0x200
> > > > > > > [ 2668.327448]  [<ffffffff81018bff>] ? save_stack_trace+0x2f/0x50
> > > > > > > [ 2668.327448]  [<ffffffff81078f0b>] mark_lock+0x4bb/0x6d0
> > > > > > > [ 2668.327448]  [<ffffffff810799e0>] ? check_usage_forwards+0x0/0xc0
> > > > > > > [ 2668.327448]  [<ffffffff8107b142>] __lock_acquire+0xc62/0x1ae0
> > > > > > > [ 2668.327448]  [<ffffffff810f478c>] ? slob_free+0x10c/0x370
> > > > > > > [ 2668.327448]  [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
> > > > > > > [ 2668.327448]  [<ffffffff8112f1b5>] ? inotify_inode_is_dead+0x35/0xb0
> > > > > > > [ 2668.327448]  [<ffffffff81562d43>] mutex_lock_nested+0x63/0x420
> > > > > > > [ 2668.327448]  [<ffffffff8112f1b5>] ? inotify_inode_is_dead+0x35/0xb0
> > > > > > > [ 2668.327448]  [<ffffffff8112f1b5>] ? inotify_inode_is_dead+0x35/0xb0
> > > > > > > [ 2668.327448]  [<ffffffff81012fe9>] ? sched_clock+0x9/0x10
> > > > > > > [ 2668.327448]  [<ffffffff81077165>] ? lock_release_holdtime+0x35/0x1c0
> > > > > > > [ 2668.327448]  [<ffffffff8112f1b5>] inotify_inode_is_dead+0x35/0xb0
> > > > > > > [ 2668.327448]  [<ffffffff8110c9dc>] dentry_iput+0xbc/0xe0
> > > > > > > [ 2668.327448]  [<ffffffff8110cb23>] d_kill+0x33/0x60
> > > > > > > [ 2668.327448]  [<ffffffff8110ce23>] __shrink_dcache_sb+0x2d3/0x350
> > > > > > > [ 2668.327448]  [<ffffffff8110cffa>] shrink_dcache_memory+0x15a/0x1e0
> > > > > > > [ 2668.327448]  [<ffffffff810d0cc5>] shrink_slab+0x125/0x180
> > > > > > > [ 2668.327448]  [<ffffffff810d1540>] kswapd+0x560/0x7a0
> > > > > > > [ 2668.327448]  [<ffffffff810ce160>] ? isolate_pages_global+0x0/0x2c0
> > > > > > > [ 2668.327448]  [<ffffffff81065a30>] ? autoremove_wake_function+0x0/0x40
> > > > > > > [ 2668.327448]  [<ffffffff8107953d>] ? trace_hardirqs_on+0xd/0x10
> > > > > > > [ 2668.327448]  [<ffffffff810d0fe0>] ? kswapd+0x0/0x7a0
> > > > > > > [ 2668.327448]  [<ffffffff8106555b>] kthread+0x5b/0xa0
> > > > > > > [ 2668.327448]  [<ffffffff8100d40a>] child_rip+0xa/0x20
> > > > > > > [ 2668.327448]  [<ffffffff8100cdd0>] ? restore_args+0x0/0x30
> > > > > > > [ 2668.327448]  [<ffffffff81065500>] ? kthread+0x0/0xa0
> > > > > > > [ 2668.327448]  [<ffffffff8100d400>] ? child_rip+0x0/0x20
> > > > > > > 
> > > > > 
> > > > > > 
> > > > > > Somebody was going to fix this for us via lockdep annotation.
> > > > > > 
> > > > > > <adds randomly-chosen cc>
> > > > > 
> > > > > I really didn't forget this, but I can't figure out how to recreate it,
> > > > > so I don't know if my logic in the patch is sound.  The patch certainly
> > > > > will shut up the complaint.
> > > > > 
> > > > > We can only hit this inotify cleanup path if the i_nlink = 0.  I can't
> > > > > find a way to leave the dentry around for memory pressure to clean up
> > > > > later, but have the n_link = 0.  On ext* the inode is kicked out as soon
> > > > > as the last close on all open fds for an inode which has been unlinked.
> > > > > I tried attaching an inotify watch to an NFS or CIFS inode, deleting the
> > > > > inode on another node, and then putting the first machine under memory
> > > > > pressure.  I'm not sure why, but the dentry or inode in question were
> > > > > never evicted so I didn't hit this path either....
> > > > 
> > > > FYI, I'm running a huge copy on btrfs with SLOB ;-)
> > > > 
> > > > > I know the patch will shut up the problem, but since I can't figure out
> > > > > by looking at the code a path to reproduce I don't really feel 100%
> > > > > confident that it is correct....
> > > > > 
> > > > > -Eric
> > > > > 
> > > > > inotify: lockdep annotation when watch being removed
> > > > > 
> > > > > From: Eric Paris <eparis@redhat.com>
> > > > > 
> > > > > When a dentry is being evicted from memory pressure, if the inode associated
> > > > > with that dentry has i_nlink == 0 we are going to drop all of the watches and
> > > > > kick everything out.  Lockdep complains that previously holding inotify_mutex
> > > > > we did a __GFP_FS allocation and now __GFP_FS reclaim is taking that lock.
> > > > > There is no deadlock or danger, since we know on this code path we are
> > > > > actually cleaning up and evicting everything.  So we move the lock into a new
> > > > > class for clean up.
> > > > 
> > > > I can reproduce the bug and hence confirm that this patch works, so
> > > > 
> > > > Tested-by: Wu Fengguang <fengguang.wu@intel.com>
> > > 
> > > Ah! The big copy runs all OK - until I run shutdown, and got this big
> > > warning:
> > 
> > Hmmmmm, maybe we need to move the mutex_init(&inode->inotify_mutex) call
> > from inode_init_once to inode_init_always so those inodes/locks that we
> > moved into the new class will get put back in the old class when they
> > are reused...
> 
> Eric: this patch worked for me. Till now it has undergone many read,
> write, reboot, halt cycles without triggering the lockdep warnings :-)
 
Bad news: the warning turns up again:

[12979.538333] nfsd: last server has exited, flushing export cache
[12982.962058]
[12982.962062] ======================================================
[12982.965486] [ INFO: RECLAIM_FS-safe -> RECLAIM_FS-unsafe lock order detected ]
[12982.965486] 2.6.30-rc2-next-20090417 #218
[12982.965486] ------------------------------------------------------
[12982.965486] umount/3574 [HC0[0]:SC0[0]:HE1:SE1] is trying to acquire:
[12982.965486]  (&inode->inotify_mutex){+.+.+.}, at: [<ffffffff81134ada>] inotify_unmount_inodes+0xda/0x1f0
[12982.965486]
[12982.965486] and this task is already holding:
[12982.965486]  (iprune_mutex){+.+.-.}, at: [<ffffffff811160da>] invalidate_inodes+0x3a/0x170
[12982.965486] which would create a new lock dependency:
[12982.965486]  (iprune_mutex){+.+.-.} -> (&inode->inotify_mutex){+.+.+.}
[12982.965486]
[12982.965486] but this new dependency connects a RECLAIM_FS-irq-safe lock:
[12982.965486]  (iprune_mutex){+.+.-.}
[12982.965486] ... which became RECLAIM_FS-irq-safe at:
[12982.965486]   [<ffffffff8107b172>] __lock_acquire+0xc62/0x1ae0
[12982.965486]   [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]   [<ffffffff81569353>] mutex_lock_nested+0x63/0x420
[12982.965486]   [<ffffffff81115e24>] shrink_icache_memory+0x84/0x300
[12982.965486]   [<ffffffff810d5d75>] shrink_slab+0x125/0x180
[12982.965486]   [<ffffffff810d6f66>] try_to_free_pages+0x276/0x400
[12982.965486]   [<ffffffff810cdf96>] __alloc_pages_internal+0x2b6/0x650
[12982.965486]   [<ffffffff810f819c>] alloc_pages_current+0x8c/0xe0
[12982.965486]   [<ffffffff810c5920>] __page_cache_alloc+0x10/0x20
[12982.965486]   [<ffffffff810d0add>] __do_page_cache_readahead+0x11d/0x260
[12982.965486]   [<ffffffff810d0f4b>] ondemand_readahead+0x1cb/0x250
[12982.965486]   [<ffffffff810d1079>] page_cache_async_readahead+0xa9/0xc0
[12982.965486]   [<ffffffff810c7763>] generic_file_aio_read+0x493/0x7c0
[12982.965486]   [<ffffffff810fe1a9>] do_sync_read+0xf9/0x140
[12982.965486]   [<ffffffff810ff233>] vfs_read+0x113/0x1d0
[12982.965486]   [<ffffffff810ff407>] sys_read+0x57/0xb0
[12982.965486]   [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[12982.965486]   [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486] to a RECLAIM_FS-irq-unsafe lock:
[12982.965486]  (&inode->inotify_mutex){+.+.+.}
[12982.965486] ... which became RECLAIM_FS-irq-unsafe at:
[12982.965486] ...  [<ffffffff810791b8>] mark_held_locks+0x68/0x90
[12982.965486]   [<ffffffff810792d5>] lockdep_trace_alloc+0xf5/0x100
[12982.965486]   [<ffffffff810fa561>] __kmalloc_node+0x31/0x1e0
[12982.965486]   [<ffffffff811359c2>] kernel_event+0xe2/0x190
[12982.965486]   [<ffffffff81135b96>] inotify_dev_queue_event+0x126/0x230
[12982.965486]   [<ffffffff811343a6>] inotify_inode_queue_event+0xc6/0x110
[12982.965486]   [<ffffffff8110974d>] vfs_create+0xcd/0x140
[12982.965486]   [<ffffffff8110d55d>] do_filp_open+0x88d/0xa20
[12982.965486]   [<ffffffff810fbe68>] do_sys_open+0x98/0x140
[12982.965486]   [<ffffffff810fbf50>] sys_open+0x20/0x30
[12982.965486]   [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[12982.965486]   [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486] other info that might help us debug this:
[12982.965486]
[12982.965486] 3 locks held by umount/3574:
[12982.965486]  #0:  (&type->s_umount_key#36){++++..}, at: [<ffffffff811017f3>] deactivate_super+0x53/0x80
[12982.965486]  #1:  (&type->s_lock_key#9){+.+...}, at: [<ffffffff81100aee>] lock_super+0x2e/0x30
[12982.965486]  #2:  (iprune_mutex){+.+.-.}, at: [<ffffffff811160da>] invalidate_inodes+0x3a/0x170
[12982.965486]
[12982.965486] the RECLAIM_FS-irq-safe lock's dependencies:
[12982.965486] -> (iprune_mutex){+.+.-.} ops: 0 {
[12982.965486]    HARDIRQ-ON-W at:
[12982.965486]                                        [<ffffffff8107b035>] __lock_acquire+0xb25/0x1ae0
[12982.965486]                                        [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                        [<ffffffff81569353>] mutex_lock_nested+0x63/0x420
[12982.965486]                                        [<ffffffff81115e24>] shrink_icache_memory+0x84/0x300
[12982.965486]                                        [<ffffffff810d5d75>] shrink_slab+0x125/0x180
[12982.965486]                                        [<ffffffff810d6f66>] try_to_free_pages+0x276/0x400
[12982.965486]                                        [<ffffffff810cdf96>] __alloc_pages_internal+0x2b6/0x650
[12982.965486]                                        [<ffffffff810f819c>] alloc_pages_current+0x8c/0xe0
[12982.965486]                                        [<ffffffff810c5920>] __page_cache_alloc+0x10/0x20
[12982.965486]                                        [<ffffffff810d0add>] __do_page_cache_readahead+0x11d/0x260
[12982.965486]                                        [<ffffffff810d0f4b>] ondemand_readahead+0x1cb/0x250
[12982.965486]                                        [<ffffffff810d1079>] page_cache_async_readahead+0xa9/0xc0
[12982.965486]                                        [<ffffffff810c7763>] generic_file_aio_read+0x493/0x7c0
[12982.965486]                                        [<ffffffff810fe1a9>] do_sync_read+0xf9/0x140
[12982.965486]                                        [<ffffffff810ff233>] vfs_read+0x113/0x1d0
[12982.965486]                                        [<ffffffff810ff407>] sys_read+0x57/0xb0
[12982.965486]                                        [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[12982.965486]                                        [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]    SOFTIRQ-ON-W at:
[12982.965486]                                        [<ffffffff8107b061>] __lock_acquire+0xb51/0x1ae0
[12982.965486]                                        [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                        [<ffffffff81569353>] mutex_lock_nested+0x63/0x420
[12982.965486]                                        [<ffffffff81115e24>] shrink_icache_memory+0x84/0x300
[12982.965486]                                        [<ffffffff810d5d75>] shrink_slab+0x125/0x180
[12982.965486]                                        [<ffffffff810d6f66>] try_to_free_pages+0x276/0x400
[12982.965486]                                        [<ffffffff810cdf96>] __alloc_pages_internal+0x2b6/0x650
[12982.965486]                                        [<ffffffff810f819c>] alloc_pages_current+0x8c/0xe0
[12982.965486]                                        [<ffffffff810c5920>] __page_cache_alloc+0x10/0x20
[12982.965486]                                        [<ffffffff810d0add>] __do_page_cache_readahead+0x11d/0x260
[12982.965486]                                        [<ffffffff810d0f4b>] ondemand_readahead+0x1cb/0x250
[12982.965486]                                        [<ffffffff810d1079>] page_cache_async_readahead+0xa9/0xc0
[12982.965486]                                        [<ffffffff810c7763>] generic_file_aio_read+0x493/0x7c0
[12982.965486]                                        [<ffffffff810fe1a9>] do_sync_read+0xf9/0x140
[12982.965486]                                        [<ffffffff810ff233>] vfs_read+0x113/0x1d0
[12982.965486]                                        [<ffffffff810ff407>] sys_read+0x57/0xb0
[12982.965486]                                        [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[12982.965486]                                        [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]    IN-RECLAIM_FS-W at:
[12982.965486]                                           [<ffffffff8107b172>] __lock_acquire+0xc62/0x1ae0
[12982.965486]                                           [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                           [<ffffffff81569353>] mutex_lock_nested+0x63/0x420
[12982.965486]                                           [<ffffffff81115e24>] shrink_icache_memory+0x84/0x300
[12982.965486]                                           [<ffffffff810d5d75>] shrink_slab+0x125/0x180
[12982.965486]                                           [<ffffffff810d6f66>] try_to_free_pages+0x276/0x400
[12982.965486]                                           [<ffffffff810cdf96>] __alloc_pages_internal+0x2b6/0x650
[12982.965486]                                           [<ffffffff810f819c>] alloc_pages_current+0x8c/0xe0
[12982.965486]                                           [<ffffffff810c5920>] __page_cache_alloc+0x10/0x20
[12982.965486]                                           [<ffffffff810d0add>] __do_page_cache_readahead+0x11d/0x260
[12982.965486]                                           [<ffffffff810d0f4b>] ondemand_readahead+0x1cb/0x250
[12982.965486]                                           [<ffffffff810d1079>] page_cache_async_readahead+0xa9/0xc0
[12982.965486]                                           [<ffffffff810c7763>] generic_file_aio_read+0x493/0x7c0
[12982.965486]                                           [<ffffffff810fe1a9>] do_sync_read+0xf9/0x140
[12982.965486]                                           [<ffffffff810ff233>] vfs_read+0x113/0x1d0
[12982.965486]                                           [<ffffffff810ff407>] sys_read+0x57/0xb0
[12982.965486]                                           [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[12982.965486]                                           [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]    INITIAL USE at:
[12982.965486]                                       [<ffffffff8107a6af>] __lock_acquire+0x19f/0x1ae0
[12982.965486]                                       [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                       [<ffffffff81569353>] mutex_lock_nested+0x63/0x420
[12982.965486]                                       [<ffffffff81115e24>] shrink_icache_memory+0x84/0x300
[12982.965486]                                       [<ffffffff810d5d75>] shrink_slab+0x125/0x180
[12982.965486]                                       [<ffffffff810d6f66>] try_to_free_pages+0x276/0x400
[12982.965486]                                       [<ffffffff810cdf96>] __alloc_pages_internal+0x2b6/0x650
[12982.965486]                                       [<ffffffff810f819c>] alloc_pages_current+0x8c/0xe0
[12982.965486]                                       [<ffffffff810c5920>] __page_cache_alloc+0x10/0x20
[12982.965486]                                       [<ffffffff810d0add>] __do_page_cache_readahead+0x11d/0x260
[12982.965486]                                       [<ffffffff810d0f4b>] ondemand_readahead+0x1cb/0x250
[12982.965486]                                       [<ffffffff810d1079>] page_cache_async_readahead+0xa9/0xc0
[12982.965486]                                       [<ffffffff810c7763>] generic_file_aio_read+0x493/0x7c0
[12982.965486]                                       [<ffffffff810fe1a9>] do_sync_read+0xf9/0x140
[12982.965486]                                       [<ffffffff810ff233>] vfs_read+0x113/0x1d0
[12982.965486]                                       [<ffffffff810ff407>] sys_read+0x57/0xb0
[12982.965486]                                       [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[12982.965486]                                       [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]  }
[12982.965486]  ... key      at: [<ffffffff817f1750>] iprune_mutex+0x70/0xa0
[12982.965486]  -> (inode_lock){+.+.-.} ops: 0 {
[12982.965486]     HARDIRQ-ON-W at:
[12982.965486]                                          [<ffffffff8107b035>] __lock_acquire+0xb25/0x1ae0
[12982.965486]                                          [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                          [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]                                          [<ffffffff811155ae>] ifind_fast+0x2e/0xd0
[12982.965486]                                          [<ffffffff81116949>] iget_locked+0x49/0x180
[12982.965486]                                          [<ffffffff811527d5>] sysfs_get_inode+0x25/0x280
[12982.965486]                                          [<ffffffff811558c6>] sysfs_fill_super+0x56/0xd0
[12982.965486]                                          [<ffffffff811018ea>] get_sb_single+0xca/0x100
[12982.965486]                                          [<ffffffff8115586b>] sysfs_get_sb+0x1b/0x20
[12982.965486]                                          [<ffffffff811003f0>] vfs_kern_mount+0x50/0xd0
[12982.965486]                                          [<ffffffff81100489>] kern_mount_data+0x19/0x20
[12982.965486]                                          [<ffffffff818d38d4>] sysfs_init+0x7f/0xd4
[12982.965486]                                          [<ffffffff818d20d4>] mnt_init+0x9d/0x21e
[12982.965486]                                          [<ffffffff818d1c24>] vfs_caches_init+0xa8/0x140
[12982.965486]                                          [<ffffffff818b5d0f>] start_kernel+0x34c/0x44f
[12982.965486]                                          [<ffffffff818b5299>] x86_64_start_reservations+0x99/0xb9
[12982.965486]                                          [<ffffffff818b53b0>] x86_64_start_kernel+0xf7/0x122
[12982.965486]                                          [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]     SOFTIRQ-ON-W at:
[12982.965486]                                          [<ffffffff8107b061>] __lock_acquire+0xb51/0x1ae0
[12982.965486]                                          [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                          [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]                                          [<ffffffff811155ae>] ifind_fast+0x2e/0xd0
[12982.965486]                                          [<ffffffff81116949>] iget_locked+0x49/0x180
[12982.965486]                                          [<ffffffff811527d5>] sysfs_get_inode+0x25/0x280
[12982.965486]                                          [<ffffffff811558c6>] sysfs_fill_super+0x56/0xd0
[12982.965486]                                          [<ffffffff811018ea>] get_sb_single+0xca/0x100
[12982.965486]                                          [<ffffffff8115586b>] sysfs_get_sb+0x1b/0x20
[12982.965486]                                          [<ffffffff811003f0>] vfs_kern_mount+0x50/0xd0
[12982.965486]                                          [<ffffffff81100489>] kern_mount_data+0x19/0x20
[12982.965486]                                          [<ffffffff818d38d4>] sysfs_init+0x7f/0xd4
[12982.965486]                                          [<ffffffff818d20d4>] mnt_init+0x9d/0x21e
[12982.965486]                                          [<ffffffff818d1c24>] vfs_caches_init+0xa8/0x140
[12982.965486]                                          [<ffffffff818b5d0f>] start_kernel+0x34c/0x44f
[12982.965486]                                          [<ffffffff818b5299>] x86_64_start_reservations+0x99/0xb9
[12982.965486]                                          [<ffffffff818b53b0>] x86_64_start_kernel+0xf7/0x122
[12982.965486]                                          [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]     IN-RECLAIM_FS-W at:
[12982.965486]                                             [<ffffffff8107b172>] __lock_acquire+0xc62/0x1ae0
[12982.965486]                                             [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                             [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]                                             [<ffffffff81277628>] _atomic_dec_and_lock+0x98/0xc0
[12982.965486]                                             [<ffffffff81114fea>] iput+0x4a/0x90
[12982.965486]                                             [<ffffffff81154764>] sysfs_d_iput+0x34/0x40
[12982.965486]                                             [<ffffffff81111caa>] dentry_iput+0x8a/0xf0
[12982.965486]                                             [<ffffffff81111e33>] d_kill+0x33/0x60
[12982.965486]                                             [<ffffffff81112133>] __shrink_dcache_sb+0x2d3/0x350
[12982.965486]                                             [<ffffffff8111230a>] shrink_dcache_memory+0x15a/0x1e0
[12982.965486]                                             [<ffffffff810d5d75>] shrink_slab+0x125/0x180
[12982.965486]                                             [<ffffffff810d65f0>] kswapd+0x560/0x7a0
[12982.965486]                                             [<ffffffff8106558b>] kthread+0x5b/0xa0
[12982.965486]                                             [<ffffffff8100d40a>] child_rip+0xa/0x20
[12982.965486]                                             [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]     INITIAL USE at:
[12982.965486]                                         [<ffffffff8107a6af>] __lock_acquire+0x19f/0x1ae0
[12982.965486]                                         [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                         [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]                                         [<ffffffff811155ae>] ifind_fast+0x2e/0xd0
[12982.965486]                                         [<ffffffff81116949>] iget_locked+0x49/0x180
[12982.965486]                                         [<ffffffff811527d5>] sysfs_get_inode+0x25/0x280
[12982.965486]                                         [<ffffffff811558c6>] sysfs_fill_super+0x56/0xd0
[12982.965486]                                         [<ffffffff811018ea>] get_sb_single+0xca/0x100
[12982.965486]                                         [<ffffffff8115586b>] sysfs_get_sb+0x1b/0x20
[12982.965486]                                         [<ffffffff811003f0>] vfs_kern_mount+0x50/0xd0
[12982.965486]                                         [<ffffffff81100489>] kern_mount_data+0x19/0x20
[12982.965486]                                         [<ffffffff818d38d4>] sysfs_init+0x7f/0xd4
[12982.965486]                                         [<ffffffff818d20d4>] mnt_init+0x9d/0x21e
[12982.965486]                                         [<ffffffff818d1c24>] vfs_caches_init+0xa8/0x140
[12982.965486]                                         [<ffffffff818b5d0f>] start_kernel+0x34c/0x44f
[12982.965486]                                         [<ffffffff818b5299>] x86_64_start_reservations+0x99/0xb9
[12982.965486]                                         [<ffffffff818b53b0>] x86_64_start_kernel+0xf7/0x122
[12982.965486]                                         [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]   }
[12982.965486]   ... key      at: [<ffffffff817f1678>] inode_lock+0x18/0x40
[12982.965486]  ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]    [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]    [<ffffffff81115e30>] shrink_icache_memory+0x90/0x300
[12982.965486]    [<ffffffff810d5d75>] shrink_slab+0x125/0x180
[12982.965486]    [<ffffffff810d6f66>] try_to_free_pages+0x276/0x400
[12982.965486]    [<ffffffff810cdf96>] __alloc_pages_internal+0x2b6/0x650
[12982.965486]    [<ffffffff810f819c>] alloc_pages_current+0x8c/0xe0
[12982.965486]    [<ffffffff810c5920>] __page_cache_alloc+0x10/0x20
[12982.965486]    [<ffffffff810d0add>] __do_page_cache_readahead+0x11d/0x260
[12982.965486]    [<ffffffff810d0f4b>] ondemand_readahead+0x1cb/0x250
[12982.965486]    [<ffffffff810d1079>] page_cache_async_readahead+0xa9/0xc0
[12982.965486]    [<ffffffff810c7763>] generic_file_aio_read+0x493/0x7c0
[12982.965486]    [<ffffffff810fe1a9>] do_sync_read+0xf9/0x140
[12982.965486]    [<ffffffff810ff233>] vfs_read+0x113/0x1d0
[12982.965486]    [<ffffffff810ff407>] sys_read+0x57/0xb0
[12982.965486]    [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]  -> (&inode->i_data.tree_lock){....-.} ops: 0 {
[12982.965486]     IN-RECLAIM_FS-W at:
[12982.965486]                                             [<ffffffff8107b172>] __lock_acquire+0xc62/0x1ae0
[12982.965486]                                             [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                             [<ffffffff8156b913>] _spin_lock_irq+0x43/0x80
[12982.965486]                                             [<ffffffff810d3e65>] __remove_mapping+0xb5/0x1e0
[12982.965486]                                             [<ffffffff810d4891>] shrink_page_list+0x5d1/0xa70
[12982.965486]                                             [<ffffffff810d54be>] shrink_list+0x2be/0x660
[12982.965486]                                             [<ffffffff810d5a51>] shrink_zone+0x1f1/0x3f0
[12982.965486]                                             [<ffffffff810d67b9>] kswapd+0x729/0x7a0
[12982.965486]                                             [<ffffffff8106558b>] kthread+0x5b/0xa0
[12982.965486]                                             [<ffffffff8100d40a>] child_rip+0xa/0x20
[12982.965486]                                             [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]     INITIAL USE at:
[12982.965486]                                         [<ffffffff8107a6af>] __lock_acquire+0x19f/0x1ae0
[12982.965486]                                         [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                         [<ffffffff8156b913>] _spin_lock_irq+0x43/0x80
[12982.965486]                                         [<ffffffff810c5a08>] add_to_page_cache_locked+0xd8/0x140
[12982.965486]                                         [<ffffffff810c5ab2>] add_to_page_cache_lru+0x42/0xb0
[12982.965486]                                         [<ffffffff810c5c98>] read_cache_page_async+0x78/0x200
[12982.965486]                                         [<ffffffff810c5e33>] read_cache_page+0x13/0x90
[12982.965486]                                         [<ffffffff81150e89>] read_dev_sector+0x49/0xe0
[12982.965486]                                         [<ffffffff81152003>] msdos_partition+0x53/0x720
[12982.965486]                                         [<ffffffff81151ce6>] rescan_partitions+0x176/0x3b0
[12982.965486]                                         [<ffffffff8112e9cb>] __blkdev_get+0x19b/0x420
[12982.965486]                                         [<ffffffff8112ec60>] blkdev_get+0x10/0x20
[12982.965486]                                         [<ffffffff8115106c>] register_disk+0x14c/0x170
[12982.965486]                                         [<ffffffff81270b4d>] add_disk+0x17d/0x210
[12982.965486]                                         [<ffffffff81359d23>] sd_probe_async+0x1d3/0x2d0
[12982.965486]                                         [<ffffffff8106d4aa>] async_thread+0x10a/0x250
[12982.965486]                                         [<ffffffff8106558b>] kthread+0x5b/0xa0
[12982.965486]                                         [<ffffffff8100d40a>] child_rip+0xa/0x20
[12982.965486]                                         [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]   }
[12982.965486]   ... key      at: [<ffffffff822da47c>] __key.28599+0x0/0x8
[12982.965486]   -> (&rnp->lock){..-.-.} ops: 0 {
[12982.965486]      IN-SOFTIRQ-W at:
[12982.965486]                                            [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]      IN-RECLAIM_FS-W at:
[12982.965486]                                               [<ffffffff8107b172>] __lock_acquire+0xc62/0x1ae0
[12982.965486]                                               [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                               [<ffffffff8156b9a6>] _spin_lock_irqsave+0x56/0xa0
[12982.965486]                                               [<ffffffff810a6520>] __call_rcu+0x130/0x170
[12982.965486]                                               [<ffffffff810a6595>] call_rcu+0x15/0x20
[12982.965486]                                               [<ffffffff8127c448>] radix_tree_delete+0x148/0x2c0
[12982.965486]                                               [<ffffffff810c7ea6>] __remove_from_page_cache+0x26/0x110
[12982.965486]                                               [<ffffffff810d3f50>] __remove_mapping+0x1a0/0x1e0
[12982.965486]                                               [<ffffffff810d4891>] shrink_page_list+0x5d1/0xa70
[12982.965486]                                               [<ffffffff810d54be>] shrink_list+0x2be/0x660
[12982.965486]                                               [<ffffffff810d5a51>] shrink_zone+0x1f1/0x3f0
[12982.965486]                                               [<ffffffff810d67b9>] kswapd+0x729/0x7a0
[12982.965486]                                               [<ffffffff8106558b>] kthread+0x5b/0xa0
[12982.965486]                                               [<ffffffff8100d40a>] child_rip+0xa/0x20
[12982.965486]                                               [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]      INITIAL USE at:
[12982.965486]                                           [<ffffffff8107a6af>] __lock_acquire+0x19f/0x1ae0
[12982.965486]                                           [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                           [<ffffffff8156b9a6>] _spin_lock_irqsave+0x56/0xa0
[12982.965486]                                           [<ffffffff81565836>] rcu_init_percpu_data+0x2f/0x157
[12982.965486]                                           [<ffffffff8156599b>] rcu_cpu_notify+0x3d/0x86
[12982.965486]                                           [<ffffffff818cd5f1>] __rcu_init+0x184/0x186
[12982.965486]                                           [<ffffffff818cb389>] rcu_init+0x9/0x17
[12982.965486]                                           [<ffffffff818b5bcd>] start_kernel+0x20a/0x44f
[12982.965486]                                           [<ffffffff818b5299>] x86_64_start_reservations+0x99/0xb9
[12982.965486]                                           [<ffffffff818b53b0>] x86_64_start_kernel+0xf7/0x122
[12982.965486]                                           [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]    }
[12982.965486]    ... key      at: [<ffffffff822af2e8>] __key.18709+0x0/0x8
[12982.965486]   ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]    [<ffffffff8156b9a6>] _spin_lock_irqsave+0x56/0xa0
[12982.965486]    [<ffffffff810a6520>] __call_rcu+0x130/0x170
[12982.965486]    [<ffffffff810a6595>] call_rcu+0x15/0x20
[12982.965486]    [<ffffffff8127c4ff>] radix_tree_delete+0x1ff/0x2c0
[12982.965486]    [<ffffffff810c7ea6>] __remove_from_page_cache+0x26/0x110
[12982.965486]    [<ffffffff810c7fde>] remove_from_page_cache+0x4e/0x70
[12982.965486]    [<ffffffff810d2b22>] truncate_complete_page+0x72/0xc0
[12982.965486]    [<ffffffff810d2d57>] truncate_inode_pages_range+0x1e7/0x4f0
[12982.965486]    [<ffffffff810d3075>] truncate_inode_pages+0x15/0x20
[12982.965486]    [<ffffffff8112e646>] __blkdev_put+0xe6/0x210
[12982.965486]    [<ffffffff8112e780>] blkdev_put+0x10/0x20
[12982.965486]    [<ffffffff8112e81a>] close_bdev_exclusive+0x2a/0x40
[12982.965486]    [<ffffffff81233f57>] btrfs_scan_one_device+0xb7/0x170
[12982.965486]    [<ffffffff811ee909>] btrfs_get_sb+0xa9/0x560
[12982.965486]    [<ffffffff811003f0>] vfs_kern_mount+0x50/0xd0
[12982.965486]    [<ffffffff811004e5>] do_kern_mount+0x55/0x130
[12982.965486]    [<ffffffff8111bc07>] do_mount+0x2b7/0x8f0
[12982.965486]    [<ffffffff8111c31b>] sys_mount+0xdb/0x110
[12982.965486]    [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]   -> (key#4){......} ops: 0 {
[12982.965486]      INITIAL USE at:
[12982.965486]                                           [<ffffffff8107a6af>] __lock_acquire+0x19f/0x1ae0
[12982.965486]                                           [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                           [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]                                           [<ffffffff8128ebd8>] __percpu_counter_add+0x58/0x80
[12982.965486]                                           [<ffffffff810d00c3>] account_page_dirtied+0x53/0x80
[12982.965486]                                           [<ffffffff810d0239>] __set_page_dirty_nobuffers+0x149/0x2a0
[12982.965486]                                           [<ffffffff811c8c2d>] nfs_updatepage+0x13d/0x610
[12982.965486]                                           [<ffffffff811b889c>] nfs_write_end+0x7c/0x2e0
[12982.965486]                                           [<ffffffff810c6a89>] generic_file_buffered_write+0x329/0x3e0
[12982.965486]                                           [<ffffffff810c729d>] __generic_file_aio_write_nolock+0x51d/0x550
[12982.965486]                                           [<ffffffff810c7e20>] generic_file_aio_write+0x80/0xe0
[12982.965486]                                           [<ffffffff811b9988>] nfs_file_write+0x138/0x230
[12982.965486]                                           [<ffffffff810fe069>] do_sync_write+0xf9/0x140
[12982.965486]                                           [<ffffffff810feef6>] vfs_write+0x116/0x1d0
[12982.965486]                                           [<ffffffff810ff0c7>] sys_write+0x57/0xb0
[12982.965486]                                           [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[12982.965486]                                           [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]    }
[12982.965486]    ... key      at: [<ffffffff822d7c00>] __key.25527+0x0/0x8
[12982.965486]   ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]    [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]    [<ffffffff8128ebd8>] __percpu_counter_add+0x58/0x80
[12982.965486]    [<ffffffff810d00c3>] account_page_dirtied+0x53/0x80
[12982.965486]    [<ffffffff810d0239>] __set_page_dirty_nobuffers+0x149/0x2a0
[12982.965486]    [<ffffffff811c8c2d>] nfs_updatepage+0x13d/0x610
[12982.965486]    [<ffffffff811b889c>] nfs_write_end+0x7c/0x2e0
[12982.965486]    [<ffffffff810c6a89>] generic_file_buffered_write+0x329/0x3e0
[12982.965486]    [<ffffffff810c729d>] __generic_file_aio_write_nolock+0x51d/0x550
[12982.965486]    [<ffffffff810c7e20>] generic_file_aio_write+0x80/0xe0
[12982.965486]    [<ffffffff811b9988>] nfs_file_write+0x138/0x230
[12982.965486]    [<ffffffff810fe069>] do_sync_write+0xf9/0x140
[12982.965486]    [<ffffffff810feef6>] vfs_write+0x116/0x1d0
[12982.965486]    [<ffffffff810ff0c7>] sys_write+0x57/0xb0
[12982.965486]    [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]   -> (key#5){......} ops: 0 {
[12982.965486]      INITIAL USE at:
[12982.965486]                                           [<ffffffff8107a6af>] __lock_acquire+0x19f/0x1ae0
[12982.965486]                                           [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                           [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]                                           [<ffffffff8128ebd8>] __percpu_counter_add+0x58/0x80
[12982.965486]                                           [<ffffffff8127b575>] __prop_inc_percpu_max+0xd5/0x120
[12982.965486]                                           [<ffffffff810ce977>] test_clear_page_writeback+0x117/0x190
[12982.965486]                                           [<ffffffff810c56b4>] end_page_writeback+0x24/0x60
[12982.965486]                                           [<ffffffff811c6f08>] nfs_end_page_writeback+0x28/0x70
[12982.965486]                                           [<ffffffff811c7d6c>] nfs_writeback_release_full+0x6c/0x230
[12982.965486]                                           [<ffffffff814fe3c7>] rpc_release_calldata+0x17/0x20
[12982.965486]                                           [<ffffffff814fe43f>] rpc_free_task+0x3f/0xb0
[12982.965486]                                           [<ffffffff814fe5a5>] rpc_async_release+0x15/0x20
[12982.965486]                                           [<ffffffff81060550>] worker_thread+0x230/0x3b0
[12982.965486]                                           [<ffffffff8106558b>] kthread+0x5b/0xa0
[12982.965486]                                           [<ffffffff8100d40a>] child_rip+0xa/0x20
[12982.965486]                                           [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]    }
[12982.965486]    ... key      at: [<ffffffff822e7028>] __key.10789+0x0/0x8
[12982.965486]   ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]    [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]    [<ffffffff8128ebd8>] __percpu_counter_add+0x58/0x80
[12982.965486]    [<ffffffff8127b575>] __prop_inc_percpu_max+0xd5/0x120
[12982.965486]    [<ffffffff810ce977>] test_clear_page_writeback+0x117/0x190
[12982.965486]    [<ffffffff810c56b4>] end_page_writeback+0x24/0x60
[12982.965486]    [<ffffffff811c6f08>] nfs_end_page_writeback+0x28/0x70
[12982.965486]    [<ffffffff811c7d6c>] nfs_writeback_release_full+0x6c/0x230
[12982.965486]    [<ffffffff814fe3c7>] rpc_release_calldata+0x17/0x20
[12982.965486]    [<ffffffff814fe43f>] rpc_free_task+0x3f/0xb0
[12982.965486]    [<ffffffff814fe5a5>] rpc_async_release+0x15/0x20
[12982.965486]    [<ffffffff81060550>] worker_thread+0x230/0x3b0
[12982.965486]    [<ffffffff8106558b>] kthread+0x5b/0xa0
[12982.965486]    [<ffffffff8100d40a>] child_rip+0xa/0x20
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]   -> (key#6){......} ops: 0 {
[12982.965486]      INITIAL USE at:
[12982.965486]                                           [<ffffffff8107a6af>] __lock_acquire+0x19f/0x1ae0
[12982.965486]                                           [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                           [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]                                           [<ffffffff8128ebd8>] __percpu_counter_add+0x58/0x80
[12982.965486]                                           [<ffffffff8127b58f>] __prop_inc_percpu_max+0xef/0x120
[12982.965486]                                           [<ffffffff810ce977>] test_clear_page_writeback+0x117/0x190
[12982.965486]                                           [<ffffffff810c56b4>] end_page_writeback+0x24/0x60
[12982.965486]                                           [<ffffffff811c6f08>] nfs_end_page_writeback+0x28/0x70
[12982.965486]                                           [<ffffffff811c7d6c>] nfs_writeback_release_full+0x6c/0x230
[12982.965486]                                           [<ffffffff814fe3c7>] rpc_release_calldata+0x17/0x20
[12982.965486]                                           [<ffffffff814fe43f>] rpc_free_task+0x3f/0xb0
[12982.965486]                                           [<ffffffff814fe5a5>] rpc_async_release+0x15/0x20
[12982.965486]                                           [<ffffffff81060550>] worker_thread+0x230/0x3b0
[12982.965486]                                           [<ffffffff8106558b>] kthread+0x5b/0xa0
[12982.965486]                                           [<ffffffff8100d40a>] child_rip+0xa/0x20
[12982.965486]                                           [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]    }
[12982.965486]    ... key      at: [<ffffffff822e7040>] __key.10725+0x0/0x8
[12982.965486]   ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]    [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]    [<ffffffff8128ebd8>] __percpu_counter_add+0x58/0x80
[12982.965486]    [<ffffffff8127b58f>] __prop_inc_percpu_max+0xef/0x120
[12982.965486]    [<ffffffff810ce977>] test_clear_page_writeback+0x117/0x190
[12982.965486]    [<ffffffff810c56b4>] end_page_writeback+0x24/0x60
[12982.965486]    [<ffffffff811c6f08>] nfs_end_page_writeback+0x28/0x70
[12982.965486]    [<ffffffff811c7d6c>] nfs_writeback_release_full+0x6c/0x230
[12982.965486]    [<ffffffff814fe3c7>] rpc_release_calldata+0x17/0x20
[12982.965486]    [<ffffffff814fe43f>] rpc_free_task+0x3f/0xb0
[12982.965486]    [<ffffffff814fe5a5>] rpc_async_release+0x15/0x20
[12982.965486]    [<ffffffff81060550>] worker_thread+0x230/0x3b0
[12982.965486]    [<ffffffff8106558b>] kthread+0x5b/0xa0
[12982.965486]    [<ffffffff8100d40a>] child_rip+0xa/0x20
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]  ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]    [<ffffffff8156b913>] _spin_lock_irq+0x43/0x80
[12982.965486]    [<ffffffff810d3e65>] __remove_mapping+0xb5/0x1e0
[12982.965486]    [<ffffffff810d3fa4>] remove_mapping+0x14/0x90
[12982.965486]    [<ffffffff810d295a>] __invalidate_mapping_pages+0x1fa/0x240
[12982.965486]    [<ffffffff810d29b0>] invalidate_mapping_pages+0x10/0x20
[12982.965486]    [<ffffffff81116073>] shrink_icache_memory+0x2d3/0x300
[12982.965486]    [<ffffffff810d5d75>] shrink_slab+0x125/0x180
[12982.965486]    [<ffffffff810d6f66>] try_to_free_pages+0x276/0x400
[12982.965486]    [<ffffffff810cdf96>] __alloc_pages_internal+0x2b6/0x650
[12982.965486]    [<ffffffff810f819c>] alloc_pages_current+0x8c/0xe0
[12982.965486]    [<ffffffff810c5920>] __page_cache_alloc+0x10/0x20
[12982.965486]    [<ffffffff810d0add>] __do_page_cache_readahead+0x11d/0x260
[12982.965486]    [<ffffffff810d0f4b>] ondemand_readahead+0x1cb/0x250
[12982.965486]    [<ffffffff810d1079>] page_cache_async_readahead+0xa9/0xc0
[12982.965486]    [<ffffffff810c7763>] generic_file_aio_read+0x493/0x7c0
[12982.965486]    [<ffffffff810fe1a9>] do_sync_read+0xf9/0x140
[12982.965486]    [<ffffffff810ff233>] vfs_read+0x113/0x1d0
[12982.965486]    [<ffffffff810ff407>] sys_read+0x57/0xb0
[12982.965486]    [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]  -> (&zone->lru_lock){....-.} ops: 0 {
[12982.965486]     IN-RECLAIM_FS-W at:
[12982.965486]                                             [<ffffffff8107b172>] __lock_acquire+0xc62/0x1ae0
[12982.965486]                                             [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                             [<ffffffff8156b913>] _spin_lock_irq+0x43/0x80
[12982.965486]                                             [<ffffffff810d4d9e>] shrink_active_list+0x6e/0x4d0
[12982.965486]                                             [<ffffffff810d6370>] kswapd+0x2e0/0x7a0
[12982.965486]                                             [<ffffffff8106558b>] kthread+0x5b/0xa0
[12982.965486]                                             [<ffffffff8100d40a>] child_rip+0xa/0x20
[12982.965486]                                             [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]     INITIAL USE at:
[12982.965486]                                         [<ffffffff8107a6af>] __lock_acquire+0x19f/0x1ae0
[12982.965486]                                         [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                         [<ffffffff8156b913>] _spin_lock_irq+0x43/0x80
[12982.965486]                                         [<ffffffff810d1b00>] ____pagevec_lru_add+0xd0/0x220
[12982.965486]                                         [<ffffffff810d1cbb>] drain_cpu_pagevecs+0x6b/0xe0
[12982.965486]                                         [<ffffffff810d1da6>] lru_add_drain+0x16/0x20
[12982.965486]                                         [<ffffffff810d1f76>] __pagevec_release+0x16/0x40
[12982.965486]                                         [<ffffffff810d2e13>] truncate_inode_pages_range+0x2a3/0x4f0
[12982.965486]                                         [<ffffffff810d3075>] truncate_inode_pages+0x15/0x20
[12982.965486]                                         [<ffffffff8112e646>] __blkdev_put+0xe6/0x210
[12982.965486]                                         [<ffffffff8112e780>] blkdev_put+0x10/0x20
[12982.965486]                                         [<ffffffff81151081>] register_disk+0x161/0x170
[12982.965486]                                         [<ffffffff81270b4d>] add_disk+0x17d/0x210
[12982.965486]                                         [<ffffffff81359d23>] sd_probe_async+0x1d3/0x2d0
[12982.965486]                                         [<ffffffff8106d4aa>] async_thread+0x10a/0x250
[12982.965486]                                         [<ffffffff8106558b>] kthread+0x5b/0xa0
[12982.965486]                                         [<ffffffff8100d40a>] child_rip+0xa/0x20
[12982.965486]                                         [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]   }
[12982.965486]   ... key      at: [<ffffffff822d73a8>] __key.32156+0x0/0x8
[12982.965486]  ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]    [<ffffffff8156b9a6>] _spin_lock_irqsave+0x56/0xa0
[12982.965486]    [<ffffffff810d1674>] release_pages+0x184/0x2a0
[12982.965486]    [<ffffffff810d1f86>] __pagevec_release+0x26/0x40
[12982.965486]    [<ffffffff810d297a>] __invalidate_mapping_pages+0x21a/0x240
[12982.965486]    [<ffffffff810d29b0>] invalidate_mapping_pages+0x10/0x20
[12982.965486]    [<ffffffff81116073>] shrink_icache_memory+0x2d3/0x300
[12982.965486]    [<ffffffff810d5d75>] shrink_slab+0x125/0x180
[12982.965486]    [<ffffffff810d6f66>] try_to_free_pages+0x276/0x400
[12982.965486]    [<ffffffff810cdf96>] __alloc_pages_internal+0x2b6/0x650
[12982.965486]    [<ffffffff810f819c>] alloc_pages_current+0x8c/0xe0
[12982.965486]    [<ffffffff810c5920>] __page_cache_alloc+0x10/0x20
[12982.965486]    [<ffffffff810d0add>] __do_page_cache_readahead+0x11d/0x260
[12982.965486]    [<ffffffff810d0f4b>] ondemand_readahead+0x1cb/0x250
[12982.965486]    [<ffffffff810d1079>] page_cache_async_readahead+0xa9/0xc0
[12982.965486]    [<ffffffff810c7763>] generic_file_aio_read+0x493/0x7c0
[12982.965486]    [<ffffffff810fe1a9>] do_sync_read+0xf9/0x140
[12982.965486]    [<ffffffff810ff233>] vfs_read+0x113/0x1d0
[12982.965486]    [<ffffffff810ff407>] sys_read+0x57/0xb0
[12982.965486]    [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]  -> (&obj_hash[i].lock){-.-.-.} ops: 0 {
[12982.965486]     IN-HARDIRQ-W at:
[12982.965486]                                          [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]     IN-SOFTIRQ-W at:
[12982.965486]                                          [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]     IN-RECLAIM_FS-W at:
[12982.965486]                                             [<ffffffff8107b172>] __lock_acquire+0xc62/0x1ae0
[12982.965486]                                             [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                             [<ffffffff8156b9a6>] _spin_lock_irqsave+0x56/0xa0
[12982.965486]                                             [<ffffffff812870ee>] debug_check_no_obj_freed+0x8e/0x200
[12982.965486]                                             [<ffffffff810ccabc>] free_hot_cold_page+0x14c/0x350
[12982.965486]                                             [<ffffffff810ccd01>] __pagevec_free+0x41/0x60
[12982.965486]                                             [<ffffffff810d48d5>] shrink_page_list+0x615/0xa70
[12982.965486]                                             [<ffffffff810d54be>] shrink_list+0x2be/0x660
[12982.965486]                                             [<ffffffff810d5a51>] shrink_zone+0x1f1/0x3f0
[12982.965486]                                             [<ffffffff810d67b9>] kswapd+0x729/0x7a0
[12982.965486]                                             [<ffffffff8106558b>] kthread+0x5b/0xa0
[12982.965486]                                             [<ffffffff8100d40a>] child_rip+0xa/0x20
[12982.965486]                                             [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]     INITIAL USE at:
[12982.965486]                                         [<ffffffff8107a6af>] __lock_acquire+0x19f/0x1ae0
[12982.965486]                                         [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                         [<ffffffff8156b9a6>] _spin_lock_irqsave+0x56/0xa0
[12982.965486]                                         [<ffffffff812873fc>] __debug_object_init+0x5c/0x410
[12982.965486]                                         [<ffffffff812877ff>] debug_object_init+0x1f/0x30
[12982.965486]                                         [<ffffffff810696de>] hrtimer_init+0x2e/0x50
[12982.965486]                                         [<ffffffff818ca227>] sched_init+0xab/0x3c5
[12982.965486]                                         [<ffffffff818b5b43>] start_kernel+0x180/0x44f
[12982.965486]                                         [<ffffffff818b5299>] x86_64_start_reservations+0x99/0xb9
[12982.965486]                                         [<ffffffff818b53b0>] x86_64_start_kernel+0xf7/0x122
[12982.965486]                                         [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]   }
[12982.965486]   ... key      at: [<ffffffff822e7088>] __key.20519+0x0/0x8
[12982.965486]   -> (pool_lock){..-.-.} ops: 0 {
[12982.965486]      IN-SOFTIRQ-W at:
[12982.965486]                                            [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]      IN-RECLAIM_FS-W at:
[12982.965486]                                               [<ffffffff8107b172>] __lock_acquire+0xc62/0x1ae0
[12982.965486]                                               [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                               [<ffffffff8156b9a6>] _spin_lock_irqsave+0x56/0xa0
[12982.965486]                                               [<ffffffff81286fd6>] free_object+0x16/0xa0
[12982.965486]                                               [<ffffffff81287226>] debug_check_no_obj_freed+0x1c6/0x200
[12982.965486]                                               [<ffffffff810ccabc>] free_hot_cold_page+0x14c/0x350
[12982.965486]                                               [<ffffffff810ccd50>] free_hot_page+0x10/0x20
[12982.965486]                                               [<ffffffff810ccdd2>] __free_pages+0x72/0x80
[12982.965486]                                               [<ffffffff810cce5b>] free_pages+0x7b/0x80
[12982.965486]                                               [<ffffffff810f9ad5>] slob_free+0x155/0x370
[12982.965486]                                               [<ffffffff810f9d25>] __kmem_cache_free+0x35/0x40
[12982.965486]                                               [<ffffffff810f9dfc>] kmem_cache_free+0xcc/0xd0
[12982.965486]                                               [<ffffffff81145909>] proc_destroy_inode+0x19/0x20
[12982.965486]                                               [<ffffffff81115c5d>] destroy_inode+0x4d/0x70
[12982.965486]                                               [<ffffffff81116359>] generic_delete_inode+0x149/0x190
[12982.965486]                                               [<ffffffff8111501d>] iput+0x7d/0x90
[12982.965486]                                               [<ffffffff81111cb8>] dentry_iput+0x98/0xf0
[12982.965486]                                               [<ffffffff81111e33>] d_kill+0x33/0x60
[12982.965486]                                               [<ffffffff81112133>] __shrink_dcache_sb+0x2d3/0x350
[12982.965486]                                               [<ffffffff8111230a>] shrink_dcache_memory+0x15a/0x1e0
[12982.965486]                                               [<ffffffff810d5d75>] shrink_slab+0x125/0x180
[12982.965486]                                               [<ffffffff810d65f0>] kswapd+0x560/0x7a0
[12982.965486]                                               [<ffffffff8106558b>] kthread+0x5b/0xa0
[12982.965486]                                               [<ffffffff8100d40a>] child_rip+0xa/0x20
[12982.965486]                                               [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]      INITIAL USE at:
[12982.965486]                                           [<ffffffff8107a6af>] __lock_acquire+0x19f/0x1ae0
[12982.965486]                                           [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                           [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]                                           [<ffffffff8128748a>] __debug_object_init+0xea/0x410
[12982.965486]                                           [<ffffffff812877ff>] debug_object_init+0x1f/0x30
[12982.965486]                                           [<ffffffff810696de>] hrtimer_init+0x2e/0x50
[12982.965486]                                           [<ffffffff818ca227>] sched_init+0xab/0x3c5
[12982.965486]                                           [<ffffffff818b5b43>] start_kernel+0x180/0x44f
[12982.965486]                                           [<ffffffff818b5299>] x86_64_start_reservations+0x99/0xb9
[12982.965486]                                           [<ffffffff818b53b0>] x86_64_start_kernel+0xf7/0x122
[12982.965486]                                           [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]    }
[12982.965486]    ... key      at: [<ffffffff81806678>] pool_lock+0x18/0x40
[12982.965486]   ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]    [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]    [<ffffffff8128748a>] __debug_object_init+0xea/0x410
[12982.965486]    [<ffffffff812877ff>] debug_object_init+0x1f/0x30
[12982.965486]    [<ffffffff810696de>] hrtimer_init+0x2e/0x50
[12982.965486]    [<ffffffff818ca227>] sched_init+0xab/0x3c5
[12982.965486]    [<ffffffff818b5b43>] start_kernel+0x180/0x44f
[12982.965486]    [<ffffffff818b5299>] x86_64_start_reservations+0x99/0xb9
[12982.965486]    [<ffffffff818b53b0>] x86_64_start_kernel+0xf7/0x122
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]  ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]    [<ffffffff8156b9a6>] _spin_lock_irqsave+0x56/0xa0
[12982.965486]    [<ffffffff812870ee>] debug_check_no_obj_freed+0x8e/0x200
[12982.965486]    [<ffffffff810ccabc>] free_hot_cold_page+0x14c/0x350
[12982.965486]    [<ffffffff810ccd01>] __pagevec_free+0x41/0x60
[12982.965486]    [<ffffffff810d16b4>] release_pages+0x1c4/0x2a0
[12982.965486]    [<ffffffff810d1f86>] __pagevec_release+0x26/0x40
[12982.965486]    [<ffffffff810d297a>] __invalidate_mapping_pages+0x21a/0x240
[12982.965486]    [<ffffffff810d29b0>] invalidate_mapping_pages+0x10/0x20
[12982.965486]    [<ffffffff81116073>] shrink_icache_memory+0x2d3/0x300
[12982.965486]    [<ffffffff810d5d75>] shrink_slab+0x125/0x180
[12982.965486]    [<ffffffff810d6f66>] try_to_free_pages+0x276/0x400
[12982.965486]    [<ffffffff810cdf96>] __alloc_pages_internal+0x2b6/0x650
[12982.965486]    [<ffffffff810f819c>] alloc_pages_current+0x8c/0xe0
[12982.965486]    [<ffffffff810c5920>] __page_cache_alloc+0x10/0x20
[12982.965486]    [<ffffffff810d0add>] __do_page_cache_readahead+0x11d/0x260
[12982.965486]    [<ffffffff810d0f4b>] ondemand_readahead+0x1cb/0x250
[12982.965486]    [<ffffffff810d1079>] page_cache_async_readahead+0xa9/0xc0
[12982.965486]    [<ffffffff810c7763>] generic_file_aio_read+0x493/0x7c0
[12982.965486]    [<ffffffff810fe1a9>] do_sync_read+0xf9/0x140
[12982.965486]    [<ffffffff810ff233>] vfs_read+0x113/0x1d0
[12982.965486]    [<ffffffff810ff407>] sys_read+0x57/0xb0
[12982.965486]    [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]  -> (&sb->s_type->i_lock_key#2){+.+.-.} ops: 0 {
[12982.965486]     HARDIRQ-ON-W at:
[12982.965486]                                          [<ffffffff8107b035>] __lock_acquire+0xb25/0x1ae0
[12982.965486]                                          [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                          [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]                                          [<ffffffff811b7e1c>] nfs_do_access+0x3c/0x370
[12982.965486]                                          [<ffffffff811b82fe>] nfs_permission+0x1ae/0x220
[12982.965486]                                          [<ffffffff81108280>] inode_permission+0x60/0xa0
[12982.965486]                                          [<ffffffff810fce7a>] sys_chdir+0x5a/0x90
[12982.965486]                                          [<ffffffff818b5fd4>] do_mount_root+0x3c/0xab
[12982.965486]                                          [<ffffffff818b64bf>] mount_root+0x138/0x141
[12982.965486]                                          [<ffffffff818b65c0>] prepare_namespace+0xf8/0x198
[12982.965486]                                          [<ffffffff818b56fe>] kernel_init+0x18b/0x1a8
[12982.965486]                                          [<ffffffff8100d40a>] child_rip+0xa/0x20
[12982.965486]                                          [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]     SOFTIRQ-ON-W at:
[12982.965486]                                          [<ffffffff8107b061>] __lock_acquire+0xb51/0x1ae0
[12982.965486]                                          [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                          [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]                                          [<ffffffff811b7e1c>] nfs_do_access+0x3c/0x370
[12982.965486]                                          [<ffffffff811b82fe>] nfs_permission+0x1ae/0x220
[12982.965486]                                          [<ffffffff81108280>] inode_permission+0x60/0xa0
[12982.965486]                                          [<ffffffff810fce7a>] sys_chdir+0x5a/0x90
[12982.965486]                                          [<ffffffff818b5fd4>] do_mount_root+0x3c/0xab
[12982.965486]                                          [<ffffffff818b64bf>] mount_root+0x138/0x141
[12982.965486]                                          [<ffffffff818b65c0>] prepare_namespace+0xf8/0x198
[12982.965486]                                          [<ffffffff818b56fe>] kernel_init+0x18b/0x1a8
[12982.965486]                                          [<ffffffff8100d40a>] child_rip+0xa/0x20
[12982.965486]                                          [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]     IN-RECLAIM_FS-W at:
[12982.965486]                                             [<ffffffff8107b172>] __lock_acquire+0xc62/0x1ae0
[12982.965486]                                             [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                             [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]                                             [<ffffffff811cee59>] nfs3_forget_cached_acls+0x49/0x90
[12982.965486]                                             [<ffffffff811ba21f>] nfs_zap_acl_cache+0x3f/0x70
[12982.965486]                                             [<ffffffff811bc69f>] nfs_clear_inode+0x6f/0x90
[12982.965486]                                             [<ffffffff81115a6e>] clear_inode+0xfe/0x170
[12982.965486]                                             [<ffffffff81115cb8>] dispose_list+0x38/0x120
[12982.965486]                                             [<ffffffff8111602f>] shrink_icache_memory+0x28f/0x300
[12982.965486]                                             [<ffffffff810d5d75>] shrink_slab+0x125/0x180
[12982.965486]                                             [<ffffffff810d6f66>] try_to_free_pages+0x276/0x400
[12982.965486]                                             [<ffffffff810cdf96>] __alloc_pages_internal+0x2b6/0x650
[12982.965486]                                             [<ffffffff810f819c>] alloc_pages_current+0x8c/0xe0
[12982.965486]                                             [<ffffffff810c5920>] __page_cache_alloc+0x10/0x20
[12982.965486]                                             [<ffffffff810d0add>] __do_page_cache_readahead+0x11d/0x260
[12982.965486]                                             [<ffffffff810d0f4b>] ondemand_readahead+0x1cb/0x250
[12982.965486]                                             [<ffffffff810d1079>] page_cache_async_readahead+0xa9/0xc0
[12982.965486]                                             [<ffffffff810c7763>] generic_file_aio_read+0x493/0x7c0
[12982.965486]                                             [<ffffffff810fe1a9>] do_sync_read+0xf9/0x140
[12982.965486]                                             [<ffffffff810ff233>] vfs_read+0x113/0x1d0
[12982.965486]                                             [<ffffffff810ff407>] sys_read+0x57/0xb0
[12982.965486]                                             [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[12982.965486]                                             [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]     INITIAL USE at:
[12982.965486]                                         [<ffffffff8107a6af>] __lock_acquire+0x19f/0x1ae0
[12982.965486]                                         [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                         [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]                                         [<ffffffff811b7e1c>] nfs_do_access+0x3c/0x370
[12982.965486]                                         [<ffffffff811b82fe>] nfs_permission+0x1ae/0x220
[12982.965486]                                         [<ffffffff81108280>] inode_permission+0x60/0xa0
[12982.965486]                                         [<ffffffff810fce7a>] sys_chdir+0x5a/0x90
[12982.965486]                                         [<ffffffff818b5fd4>] do_mount_root+0x3c/0xab
[12982.965486]                                         [<ffffffff818b64bf>] mount_root+0x138/0x141
[12982.965486]                                         [<ffffffff818b65c0>] prepare_namespace+0xf8/0x198
[12982.965486]                                         [<ffffffff818b56fe>] kernel_init+0x18b/0x1a8
[12982.965486]                                         [<ffffffff8100d40a>] child_rip+0xa/0x20
[12982.965486]                                         [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]   }
[12982.965486]   ... key      at: [<ffffffff817f4990>] nfs_fs_type+0x50/0x80
[12982.965486]   ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]    [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]    [<ffffffff81114bfd>] igrab+0x1d/0x50
[12982.965486]    [<ffffffff811c90ed>] nfs_updatepage+0x5fd/0x610
[12982.965486]    [<ffffffff811b889c>] nfs_write_end+0x7c/0x2e0
[12982.965486]    [<ffffffff810c6a89>] generic_file_buffered_write+0x329/0x3e0
[12982.965486]    [<ffffffff810c729d>] __generic_file_aio_write_nolock+0x51d/0x550
[12982.965486]    [<ffffffff810c7e20>] generic_file_aio_write+0x80/0xe0
[12982.965486]    [<ffffffff811b9988>] nfs_file_write+0x138/0x230
[12982.965486]    [<ffffffff810fe069>] do_sync_write+0xf9/0x140
[12982.965486]    [<ffffffff810feef6>] vfs_write+0x116/0x1d0
[12982.965486]    [<ffffffff810ff0c7>] sys_write+0x57/0xb0
[12982.965486]    [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]   ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]    [<ffffffff8156b9a6>] _spin_lock_irqsave+0x56/0xa0
[12982.965486]    [<ffffffff810ce714>] test_set_page_writeback+0x84/0x1d0
[12982.965486]    [<ffffffff811c7490>] nfs_do_writepage+0x120/0x1b0
[12982.965486]    [<ffffffff811c7c4e>] nfs_writepages_callback+0x1e/0x40
[12982.965486]    [<ffffffff810cf1df>] write_cache_pages+0x3ff/0x4b0
[12982.965486]    [<ffffffff811c7b98>] nfs_writepages+0xe8/0x180
[12982.965486]    [<ffffffff810cf2f0>] do_writepages+0x30/0x50
[12982.965486]    [<ffffffff810c66c9>] __filemap_fdatawrite_range+0x59/0x70
[12982.965486]    [<ffffffff810c7acf>] filemap_fdatawrite+0x1f/0x30
[12982.965486]    [<ffffffff810c7b1d>] filemap_write_and_wait+0x3d/0x60
[12982.965486]    [<ffffffff811bbfab>] nfs_sync_mapping+0x3b/0x50
[12982.965486]    [<ffffffff811b8dd8>] do_unlk+0x38/0xa0
[12982.965486]    [<ffffffff811b911e>] nfs_lock+0x11e/0x200
[12982.965486]    [<ffffffff8113dbb3>] vfs_lock_file+0x23/0x50
[12982.965486]    [<ffffffff8113ddf7>] fcntl_setlk+0x157/0x350
[12982.965486]    [<ffffffff8110e0aa>] sys_fcntl+0xca/0x480
[12982.965486]    [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]   -> (&q->lock){-.-.-.} ops: 0 {
[12982.965486]      IN-HARDIRQ-W at:
[12982.965486]                                            [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]      IN-SOFTIRQ-W at:
[12982.965486]                                            [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]      IN-RECLAIM_FS-W at:
[12982.965486]                                               [<ffffffff8107b172>] __lock_acquire+0xc62/0x1ae0
[12982.965486]                                               [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                               [<ffffffff8156b9a6>] _spin_lock_irqsave+0x56/0xa0
[12982.965486]                                               [<ffffffff81065d61>] prepare_to_wait+0x31/0x90
[12982.965486]                                               [<ffffffff810d6190>] kswapd+0x100/0x7a0
[12982.965486]                                               [<ffffffff8106558b>] kthread+0x5b/0xa0
[12982.965486]                                               [<ffffffff8100d40a>] child_rip+0xa/0x20
[12982.965486]                                               [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]      INITIAL USE at:
[12982.965486]                                           [<ffffffff8107a6af>] __lock_acquire+0x19f/0x1ae0
[12982.965486]                                           [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                           [<ffffffff8156b913>] _spin_lock_irq+0x43/0x80
[12982.965486]                                           [<ffffffff8156825b>] wait_for_common+0x4b/0x1d0
[12982.965486]                                           [<ffffffff8156849d>] wait_for_completion+0x1d/0x20
[12982.965486]                                           [<ffffffff8106584f>] kthread_create+0xaf/0x180
[12982.965486]                                           [<ffffffff81564129>] migration_call+0x1a6/0x5d2
[12982.965486]                                           [<ffffffff818ca080>] migration_init+0x2e/0x7f
[12982.965486]                                           [<ffffffff8100904f>] do_one_initcall+0x3f/0x1d0
[12982.965486]                                           [<ffffffff818b55e0>] kernel_init+0x6d/0x1a8
[12982.965486]                                           [<ffffffff8100d40a>] child_rip+0xa/0x20
[12982.965486]                                           [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]    }
[12982.965486]    ... key      at: [<ffffffff81b54dc8>] __key.19115+0x0/0x18
[12982.965486]    -> (&rq->lock){-.-.-.} ops: 0 {
[12982.965486]       IN-HARDIRQ-W at:
[12982.965486]                                              [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]       IN-SOFTIRQ-W at:
[12982.965486]                                              [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]       IN-RECLAIM_FS-W at:
[12982.965486]                                                 [<ffffffff8107b172>] __lock_acquire+0xc62/0x1ae0
[12982.965486]                                                 [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                                 [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]                                                 [<ffffffff8103a3c3>] task_rq_lock+0x63/0xc0
[12982.965486]                                                 [<ffffffff81045c29>] set_cpus_allowed_ptr+0x39/0x160
[12982.965486]                                                 [<ffffffff810d610f>] kswapd+0x7f/0x7a0
[12982.965486]                                                 [<ffffffff8106558b>] kthread+0x5b/0xa0
[12982.965486]                                                 [<ffffffff8100d40a>] child_rip+0xa/0x20
[12982.965486]                                                 [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]       INITIAL USE at:
[12982.965486]                                             [<ffffffff8107a6af>] __lock_acquire+0x19f/0x1ae0
[12982.965486]                                             [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                             [<ffffffff8156b9a6>] _spin_lock_irqsave+0x56/0xa0
[12982.965486]                                             [<ffffffff8104210b>] rq_attach_root+0x2b/0x110
[12982.965486]                                             [<ffffffff818ca437>] sched_init+0x2bb/0x3c5
[12982.965486]                                             [<ffffffff818b5b43>] start_kernel+0x180/0x44f
[12982.965486]                                             [<ffffffff818b5299>] x86_64_start_reservations+0x99/0xb9
[12982.965486]                                             [<ffffffff818b53b0>] x86_64_start_kernel+0xf7/0x122
[12982.965486]                                             [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]     }
[12982.965486]     ... key      at: [<ffffffff81b0f858>] __key.48846+0x0/0x8
[12982.965486]     -> (&vec->lock){-.-.-.} ops: 0 {
[12982.965486]        IN-HARDIRQ-W at:
[12982.965486]                                                [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]        IN-SOFTIRQ-W at:
[12982.965486]                                                [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]        IN-RECLAIM_FS-W at:
[12982.965486]                                                   [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]        INITIAL USE at:
[12982.965486]                                               [<ffffffff8107a6af>] __lock_acquire+0x19f/0x1ae0
[12982.965486]                                               [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                               [<ffffffff8156b9a6>] _spin_lock_irqsave+0x56/0xa0
[12982.965486]                                               [<ffffffff810c38e2>] cpupri_set+0x102/0x1a0
[12982.965486]                                               [<ffffffff8103e839>] rq_online_rt+0x49/0x80
[12982.965486]                                               [<ffffffff8103826e>] set_rq_online+0x5e/0x80
[12982.965486]                                               [<ffffffff810421c8>] rq_attach_root+0xe8/0x110
[12982.965486]                                               [<ffffffff818ca437>] sched_init+0x2bb/0x3c5
[12982.965486]                                               [<ffffffff818b5b43>] start_kernel+0x180/0x44f
[12982.965486]                                               [<ffffffff818b5299>] x86_64_start_reservations+0x99/0xb9
[12982.965486]                                               [<ffffffff818b53b0>] x86_64_start_kernel+0xf7/0x122
[12982.965486]                                               [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]      }
[12982.965486]      ... key      at: [<ffffffff822d7338>] __key.15844+0x0/0x8
[12982.965486]     ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]    [<ffffffff8156b9a6>] _spin_lock_irqsave+0x56/0xa0
[12982.965486]    [<ffffffff810c38e2>] cpupri_set+0x102/0x1a0
[12982.965486]    [<ffffffff8103e839>] rq_online_rt+0x49/0x80
[12982.965486]    [<ffffffff8103826e>] set_rq_online+0x5e/0x80
[12982.965486]    [<ffffffff810421c8>] rq_attach_root+0xe8/0x110
[12982.965486]    [<ffffffff818ca437>] sched_init+0x2bb/0x3c5
[12982.965486]    [<ffffffff818b5b43>] start_kernel+0x180/0x44f
[12982.965486]    [<ffffffff818b5299>] x86_64_start_reservations+0x99/0xb9
[12982.965486]    [<ffffffff818b53b0>] x86_64_start_kernel+0xf7/0x122
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]     -> (&rt_b->rt_runtime_lock){-.-.-.} ops: 0 {
[12982.965486]        IN-HARDIRQ-W at:
[12982.965486]                                                [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]        IN-SOFTIRQ-W at:
[12982.965486]                                                [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]        IN-RECLAIM_FS-W at:
[12982.965486]                                                   [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]        INITIAL USE at:
[12982.965486]                                               [<ffffffff8107a6af>] __lock_acquire+0x19f/0x1ae0
[12982.965486]                                               [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                               [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]                                               [<ffffffff8103f294>] enqueue_task_rt+0x254/0x300
[12982.965486]                                               [<ffffffff810391f6>] enqueue_task+0x86/0xa0
[12982.965486]                                               [<ffffffff8103923d>] activate_task+0x2d/0x40
[12982.965486]                                               [<ffffffff81040610>] try_to_wake_up+0x1b0/0x320
[12982.965486]                                               [<ffffffff810407d5>] wake_up_process+0x15/0x20
[12982.965486]                                               [<ffffffff81563fe0>] migration_call+0x5d/0x5d2
[12982.965486]                                               [<ffffffff818ca0b7>] migration_init+0x65/0x7f
[12982.965486]                                               [<ffffffff8100904f>] do_one_initcall+0x3f/0x1d0
[12982.965486]                                               [<ffffffff818b55e0>] kernel_init+0x6d/0x1a8
[12982.965486]                                               [<ffffffff8100d40a>] child_rip+0xa/0x20
[12982.965486]                                               [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]      }
[12982.965486]      ... key      at: [<ffffffff81b0f860>] __key.39068+0x0/0x8
[12982.965486]      -> (&cpu_base->lock){-.-.-.} ops: 0 {
[12982.965486]         IN-HARDIRQ-W at:
[12982.965486]                                                  [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]         IN-SOFTIRQ-W at:
[12982.965486]                                                  [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]         IN-RECLAIM_FS-W at:
[12982.965486]                                                     [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]         INITIAL USE at:
[12982.965486]                                                 [<ffffffff8107a6af>] __lock_acquire+0x19f/0x1ae0
[12982.965486]                                                 [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                                 [<ffffffff8156b9a6>] _spin_lock_irqsave+0x56/0xa0
[12982.965486]                                                 [<ffffffff8106984c>] lock_hrtimer_base+0x5c/0x90
[12982.965486]                                                 [<ffffffff81069ac3>] __hrtimer_start_range_ns+0x43/0x340
[12982.965486]                                                 [<ffffffff8103f2e2>] enqueue_task_rt+0x2a2/0x300
[12982.965486]                                                 [<ffffffff810391f6>] enqueue_task+0x86/0xa0
[12982.965486]                                                 [<ffffffff8103923d>] activate_task+0x2d/0x40
[12982.965486]                                                 [<ffffffff81040610>] try_to_wake_up+0x1b0/0x320
[12982.965486]                                                 [<ffffffff810407d5>] wake_up_process+0x15/0x20
[12982.965486]                                                 [<ffffffff81563fe0>] migration_call+0x5d/0x5d2
[12982.965486]                                                 [<ffffffff818ca0b7>] migration_init+0x65/0x7f
[12982.965486]                                                 [<ffffffff8100904f>] do_one_initcall+0x3f/0x1d0
[12982.965486]                                                 [<ffffffff818b55e0>] kernel_init+0x6d/0x1a8
[12982.965486]                                                 [<ffffffff8100d40a>] child_rip+0xa/0x20
[12982.965486]                                                 [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]       }
[12982.965486]       ... key      at: [<ffffffff81b54e10>] __key.21319+0x0/0x8
[12982.965486]       ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]    [<ffffffff8156b9a6>] _spin_lock_irqsave+0x56/0xa0
[12982.965486]    [<ffffffff81286eac>] debug_object_activate+0x5c/0x170
[12982.965486]    [<ffffffff81068e75>] enqueue_hrtimer+0x35/0xb0
[12982.965486]    [<ffffffff81069b6d>] __hrtimer_start_range_ns+0xed/0x340
[12982.965486]    [<ffffffff8103f2e2>] enqueue_task_rt+0x2a2/0x300
[12982.965486]    [<ffffffff810391f6>] enqueue_task+0x86/0xa0
[12982.965486]    [<ffffffff8103923d>] activate_task+0x2d/0x40
[12982.965486]    [<ffffffff81040610>] try_to_wake_up+0x1b0/0x320
[12982.965486]    [<ffffffff810407d5>] wake_up_process+0x15/0x20
[12982.965486]    [<ffffffff81563fe0>] migration_call+0x5d/0x5d2
[12982.965486]    [<ffffffff818ca0b7>] migration_init+0x65/0x7f
[12982.965486]    [<ffffffff8100904f>] do_one_initcall+0x3f/0x1d0
[12982.965486]    [<ffffffff818b55e0>] kernel_init+0x6d/0x1a8
[12982.965486]    [<ffffffff8100d40a>] child_rip+0xa/0x20
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]      ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]    [<ffffffff8156b9a6>] _spin_lock_irqsave+0x56/0xa0
[12982.965486]    [<ffffffff8106984c>] lock_hrtimer_base+0x5c/0x90
[12982.965486]    [<ffffffff81069ac3>] __hrtimer_start_range_ns+0x43/0x340
[12982.965486]    [<ffffffff8103f2e2>] enqueue_task_rt+0x2a2/0x300
[12982.965486]    [<ffffffff810391f6>] enqueue_task+0x86/0xa0
[12982.965486]    [<ffffffff8103923d>] activate_task+0x2d/0x40
[12982.965486]    [<ffffffff81040610>] try_to_wake_up+0x1b0/0x320
[12982.965486]    [<ffffffff810407d5>] wake_up_process+0x15/0x20
[12982.965486]    [<ffffffff81563fe0>] migration_call+0x5d/0x5d2
[12982.965486]    [<ffffffff818ca0b7>] migration_init+0x65/0x7f
[12982.965486]    [<ffffffff8100904f>] do_one_initcall+0x3f/0x1d0
[12982.965486]    [<ffffffff818b55e0>] kernel_init+0x6d/0x1a8
[12982.965486]    [<ffffffff8100d40a>] child_rip+0xa/0x20
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]      -> (&rt_rq->rt_runtime_lock){-.-...} ops: 0 {
[12982.965486]         IN-HARDIRQ-W at:
[12982.965486]                                                  [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]         IN-SOFTIRQ-W at:
[12982.965486]                                                  [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]         INITIAL USE at:
[12982.965486]                                                 [<ffffffff8107a6af>] __lock_acquire+0x19f/0x1ae0
[12982.965486]                                                 [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                                 [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]                                                 [<ffffffff8103acaf>] update_curr_rt+0x12f/0x1e0
[12982.965486]                                                 [<ffffffff8103eb84>] dequeue_task_rt+0x24/0x90
[12982.965486]                                                 [<ffffffff81039a4a>] dequeue_task+0xea/0x140
[12982.965486]                                                 [<ffffffff81039acd>] deactivate_task+0x2d/0x40
[12982.965486]                                                 [<ffffffff81567463>] __schedule+0x243/0x8ce
[12982.965486]                                                 [<ffffffff81568015>] schedule+0x15/0x50
[12982.965486]                                                 [<ffffffff8104598c>] migration_thread+0x1cc/0x2f0
[12982.965486]                                                 [<ffffffff8106558b>] kthread+0x5b/0xa0
[12982.965486]                                                 [<ffffffff8100d40a>] child_rip+0xa/0x20
[12982.965486]                                                 [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]       }
[12982.965486]       ... key      at: [<ffffffff81b0f868>] __key.48826+0x0/0x8
[12982.965486]      ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]    [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]    [<ffffffff8103afa4>] __enable_runtime+0x54/0xa0
[12982.965486]    [<ffffffff8103e81d>] rq_online_rt+0x2d/0x80
[12982.965486]    [<ffffffff8103826e>] set_rq_online+0x5e/0x80
[12982.965486]    [<ffffffff8156446a>] migration_call+0x4e7/0x5d2
[12982.965486]    [<ffffffff8156ed4f>] notifier_call_chain+0x3f/0x80
[12982.965486]    [<ffffffff8106b356>] raw_notifier_call_chain+0x16/0x20
[12982.965486]    [<ffffffff81564906>] _cpu_up+0x146/0x14b
[12982.965486]    [<ffffffff81564987>] cpu_up+0x7c/0x95
[12982.965486]    [<ffffffff818b5658>] kernel_init+0xe5/0x1a8
[12982.965486]    [<ffffffff8100d40a>] child_rip+0xa/0x20
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]     ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]    [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]    [<ffffffff8103f294>] enqueue_task_rt+0x254/0x300
[12982.965486]    [<ffffffff810391f6>] enqueue_task+0x86/0xa0
[12982.965486]    [<ffffffff8103923d>] activate_task+0x2d/0x40
[12982.965486]    [<ffffffff81040610>] try_to_wake_up+0x1b0/0x320
[12982.965486]    [<ffffffff810407d5>] wake_up_process+0x15/0x20
[12982.965486]    [<ffffffff81563fe0>] migration_call+0x5d/0x5d2
[12982.965486]    [<ffffffff818ca0b7>] migration_init+0x65/0x7f
[12982.965486]    [<ffffffff8100904f>] do_one_initcall+0x3f/0x1d0
[12982.965486]    [<ffffffff818b55e0>] kernel_init+0x6d/0x1a8
[12982.965486]    [<ffffffff8100d40a>] child_rip+0xa/0x20
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]     ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]    [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]    [<ffffffff8103acaf>] update_curr_rt+0x12f/0x1e0
[12982.965486]    [<ffffffff8103eb84>] dequeue_task_rt+0x24/0x90
[12982.965486]    [<ffffffff81039a4a>] dequeue_task+0xea/0x140
[12982.965486]    [<ffffffff81039acd>] deactivate_task+0x2d/0x40
[12982.965486]    [<ffffffff81567463>] __schedule+0x243/0x8ce
[12982.965486]    [<ffffffff81568015>] schedule+0x15/0x50
[12982.965486]    [<ffffffff8104598c>] migration_thread+0x1cc/0x2f0
[12982.965486]    [<ffffffff8106558b>] kthread+0x5b/0xa0
[12982.965486]    [<ffffffff8100d40a>] child_rip+0xa/0x20
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]     -> (&rq->lock/1){..-.-.} ops: 0 {
[12982.965486]        IN-SOFTIRQ-W at:
[12982.965486]                                                [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]        IN-RECLAIM_FS-W at:
[12982.965486]                                                   [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]        INITIAL USE at:
[12982.965486]                                               [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]      }
[12982.965486]      ... key      at: [<ffffffff81b0f859>] __key.48846+0x1/0x8
[12982.965486]      -> (&sig->cputimer.lock){-.-...} ops: 0 {
[12982.965486]         IN-HARDIRQ-W at:
[12982.965486]                                                  [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]         IN-SOFTIRQ-W at:
[12982.965486]                                                  [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]         INITIAL USE at:
[12982.965486]                                                 [<ffffffff8107a6af>] __lock_acquire+0x19f/0x1ae0
[12982.965486]                                                 [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                                 [<ffffffff8156b9a6>] _spin_lock_irqsave+0x56/0xa0
[12982.965486]                                                 [<ffffffff81066ead>] thread_group_cputimer+0x3d/0xf0
[12982.965486]                                                 [<ffffffff8106886a>] posix_cpu_timers_exit_group+0x1a/0x40
[12982.965486]                                                 [<ffffffff8104df10>] release_task+0x450/0x500
[12982.965486]                                                 [<ffffffff8104f832>] do_exit+0x6d2/0x9b0
[12982.965486]                                                 [<ffffffff8105fc9b>] ____call_usermodehelper+0x16b/0x170
[12982.965486]                                                 [<ffffffff8100d40a>] child_rip+0xa/0x20
[12982.965486]                                                 [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]       }
[12982.965486]       ... key      at: [<ffffffff81b11a04>] __key.16763+0x0/0x8
[12982.965486]      ... acquired at:
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]     ... acquired at:
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]     ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]    [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]    [<ffffffff8103a572>] update_curr+0x152/0x1a0
[12982.965486]    [<ffffffff8103c1e2>] dequeue_task_fair+0x52/0x290
[12982.965486]    [<ffffffff81039a4a>] dequeue_task+0xea/0x140
[12982.965486]    [<ffffffff81039acd>] deactivate_task+0x2d/0x40
[12982.965486]    [<ffffffff81567463>] __schedule+0x243/0x8ce
[12982.965486]    [<ffffffff81568015>] schedule+0x15/0x50
[12982.965486]    [<ffffffff814fea78>] rpc_wait_bit_killable+0x48/0x80
[12982.965486]    [<ffffffff81568912>] __wait_on_bit+0x62/0x90
[12982.965486]    [<ffffffff815689b9>] out_of_line_wait_on_bit+0x79/0x90
[12982.965486]    [<ffffffff814ff5d5>] __rpc_execute+0x285/0x340
[12982.965486]    [<ffffffff814ff6bd>] rpc_execute+0x2d/0x40
[12982.965486]    [<ffffffff814f73e0>] rpc_run_task+0x40/0x80
[12982.965486]    [<ffffffff814f7574>] rpc_call_sync+0x64/0xb0
[12982.965486]    [<ffffffff811ca3fe>] nfs3_rpc_wrapper+0x2e/0x90
[12982.965486]    [<ffffffff811caae3>] nfs3_proc_access+0xf3/0x1e0
[12982.965486]    [<ffffffff811b7efe>] nfs_do_access+0x11e/0x370
[12982.965486]    [<ffffffff811b82fe>] nfs_permission+0x1ae/0x220
[12982.965486]    [<ffffffff81108280>] inode_permission+0x60/0xa0
[12982.965486]    [<ffffffff8110a64f>] __link_path_walk+0x8f/0x1090
[12982.965486]    [<ffffffff8110b87c>] path_walk+0x5c/0xb0
[12982.965486]    [<ffffffff8110ba76>] do_path_lookup+0x96/0x270
[12982.965486]    [<ffffffff8110bd3a>] path_lookup_open+0x6a/0xe0
[12982.965486]    [<ffffffff8110cd9f>] do_filp_open+0xcf/0xa20
[12982.965486]    [<ffffffff810fbe68>] do_sys_open+0x98/0x140
[12982.965486]    [<ffffffff810fbf50>] sys_open+0x20/0x30
[12982.965486]    [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]    ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]    [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]    [<ffffffff8103a3c3>] task_rq_lock+0x63/0xc0
[12982.965486]    [<ffffffff810404a5>] try_to_wake_up+0x45/0x320
[12982.965486]    [<ffffffff81040792>] default_wake_function+0x12/0x20
[12982.965486]    [<ffffffff81037daa>] __wake_up_common+0x5a/0x90
[12982.965486]    [<ffffffff8103a124>] complete+0x44/0x60
[12982.965486]    [<ffffffff81065569>] kthread+0x39/0xa0
[12982.965486]    [<ffffffff8100d40a>] child_rip+0xa/0x20
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]    -> (&ep->lock){......} ops: 0 {
[12982.965486]       INITIAL USE at:
[12982.965486]                                             [<ffffffff8107a6af>] __lock_acquire+0x19f/0x1ae0
[12982.965486]                                             [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                             [<ffffffff8156b9a6>] _spin_lock_irqsave+0x56/0xa0
[12982.965486]                                             [<ffffffff81136f12>] sys_epoll_ctl+0x412/0x520
[12982.965486]                                             [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[12982.965486]                                             [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]     }
[12982.965486]     ... key      at: [<ffffffff822da890>] __key.23850+0x0/0x10
[12982.965486]    ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]    [<ffffffff8156b9a6>] _spin_lock_irqsave+0x56/0xa0
[12982.965486]    [<ffffffff81136534>] ep_poll_callback+0x34/0x130
[12982.965486]    [<ffffffff81037daa>] __wake_up_common+0x5a/0x90
[12982.965486]    [<ffffffff8103a1c4>] __wake_up_sync_key+0x84/0xb0
[12982.965486]    [<ffffffff81435718>] sock_def_readable+0x48/0x80
[12982.965486]    [<ffffffff814b629d>] unix_stream_sendmsg+0x23d/0x3c0
[12982.965486]    [<ffffffff814314cb>] sock_aio_write+0x12b/0x140
[12982.965486]    [<ffffffff810fe069>] do_sync_write+0xf9/0x140
[12982.965486]    [<ffffffff810fefa8>] vfs_write+0x1c8/0x1d0
[12982.965486]    [<ffffffff810ff0c7>] sys_write+0x57/0xb0
[12982.965486]    [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]   ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]    [<ffffffff8156b9a6>] _spin_lock_irqsave+0x56/0xa0
[12982.965486]    [<ffffffff8103a242>] __wake_up+0x32/0x70
[12982.965486]    [<ffffffff81065a11>] __wake_up_bit+0x31/0x40
[12982.965486]    [<ffffffff81065a4d>] wake_up_bit+0x2d/0x40
[12982.965486]    [<ffffffff811c31d7>] nfs_unlock_request+0x27/0x50
[12982.965486]    [<ffffffff811c3259>] nfs_clear_page_tag_locked+0x59/0x80
[12982.965486]    [<ffffffff811c7d98>] nfs_writeback_release_full+0x98/0x230
[12982.965486]    [<ffffffff814fe3c7>] rpc_release_calldata+0x17/0x20
[12982.965486]    [<ffffffff814fe43f>] rpc_free_task+0x3f/0xb0
[12982.965486]    [<ffffffff814fe5a5>] rpc_async_release+0x15/0x20
[12982.965486]    [<ffffffff81060550>] worker_thread+0x230/0x3b0
[12982.965486]    [<ffffffff8106558b>] kthread+0x5b/0xa0
[12982.965486]    [<ffffffff8100d40a>] child_rip+0xa/0x20
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]   ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]    [<ffffffff8156b9a6>] _spin_lock_irqsave+0x56/0xa0
[12982.965486]    [<ffffffff810a6520>] __call_rcu+0x130/0x170
[12982.965486]    [<ffffffff810a6595>] call_rcu+0x15/0x20
[12982.965486]    [<ffffffff8127c4ff>] radix_tree_delete+0x1ff/0x2c0
[12982.965486]    [<ffffffff811c6fd3>] nfs_inode_remove_request+0x83/0xd0
[12982.965486]    [<ffffffff811c8280>] nfs_commit_release+0x50/0x210
[12982.965486]    [<ffffffff814fe3c7>] rpc_release_calldata+0x17/0x20
[12982.965486]    [<ffffffff814fe43f>] rpc_free_task+0x3f/0xb0
[12982.965486]    [<ffffffff814fe5a5>] rpc_async_release+0x15/0x20
[12982.965486]    [<ffffffff81060550>] worker_thread+0x230/0x3b0
[12982.965486]    [<ffffffff8106558b>] kthread+0x5b/0xa0
[12982.965486]    [<ffffffff8100d40a>] child_rip+0xa/0x20
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]  ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]    [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]    [<ffffffff811cee59>] nfs3_forget_cached_acls+0x49/0x90
[12982.965486]    [<ffffffff811ba21f>] nfs_zap_acl_cache+0x3f/0x70
[12982.965486]    [<ffffffff811bc69f>] nfs_clear_inode+0x6f/0x90
[12982.965486]    [<ffffffff81115a6e>] clear_inode+0xfe/0x170
[12982.965486]    [<ffffffff81115cb8>] dispose_list+0x38/0x120
[12982.965486]    [<ffffffff8111602f>] shrink_icache_memory+0x28f/0x300
[12982.965486]    [<ffffffff810d5d75>] shrink_slab+0x125/0x180
[12982.965486]    [<ffffffff810d6f66>] try_to_free_pages+0x276/0x400
[12982.965486]    [<ffffffff810cdf96>] __alloc_pages_internal+0x2b6/0x650
[12982.965486]    [<ffffffff810f819c>] alloc_pages_current+0x8c/0xe0
[12982.965486]    [<ffffffff810c5920>] __page_cache_alloc+0x10/0x20
[12982.965486]    [<ffffffff810d0add>] __do_page_cache_readahead+0x11d/0x260
[12982.965486]    [<ffffffff810d0f4b>] ondemand_readahead+0x1cb/0x250
[12982.965486]    [<ffffffff810d1079>] page_cache_async_readahead+0xa9/0xc0
[12982.965486]    [<ffffffff810c7763>] generic_file_aio_read+0x493/0x7c0
[12982.965486]    [<ffffffff810fe1a9>] do_sync_read+0xf9/0x140
[12982.965486]    [<ffffffff810ff233>] vfs_read+0x113/0x1d0
[12982.965486]    [<ffffffff810ff407>] sys_read+0x57/0xb0
[12982.965486]    [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]  -> (nfs_access_lru_lock){+.+.-.} ops: 0 {
[12982.965486]     HARDIRQ-ON-W at:
[12982.965486]                                          [<ffffffff8107b035>] __lock_acquire+0xb25/0x1ae0
[12982.965486]                                          [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                          [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]                                          [<ffffffff811b8089>] nfs_do_access+0x2a9/0x370
[12982.965486]                                          [<ffffffff811b82fe>] nfs_permission+0x1ae/0x220
[12982.965486]                                          [<ffffffff81108280>] inode_permission+0x60/0xa0
[12982.965486]                                          [<ffffffff810fce7a>] sys_chdir+0x5a/0x90
[12982.965486]                                          [<ffffffff818b5fd4>] do_mount_root+0x3c/0xab
[12982.965486]                                          [<ffffffff818b64bf>] mount_root+0x138/0x141
[12982.965486]                                          [<ffffffff818b65c0>] prepare_namespace+0xf8/0x198
[12982.965486]                                          [<ffffffff818b56fe>] kernel_init+0x18b/0x1a8
[12982.965486]                                          [<ffffffff8100d40a>] child_rip+0xa/0x20
[12982.965486]                                          [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]     SOFTIRQ-ON-W at:
[12982.965486]                                          [<ffffffff8107b061>] __lock_acquire+0xb51/0x1ae0
[12982.965486]                                          [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                          [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]                                          [<ffffffff811b8089>] nfs_do_access+0x2a9/0x370
[12982.965486]                                          [<ffffffff811b82fe>] nfs_permission+0x1ae/0x220
[12982.965486]                                          [<ffffffff81108280>] inode_permission+0x60/0xa0
[12982.965486]                                          [<ffffffff810fce7a>] sys_chdir+0x5a/0x90
[12982.965486]                                          [<ffffffff818b5fd4>] do_mount_root+0x3c/0xab
[12982.965486]                                          [<ffffffff818b64bf>] mount_root+0x138/0x141
[12982.965486]                                          [<ffffffff818b65c0>] prepare_namespace+0xf8/0x198
[12982.965486]                                          [<ffffffff818b56fe>] kernel_init+0x18b/0x1a8
[12982.965486]                                          [<ffffffff8100d40a>] child_rip+0xa/0x20
[12982.965486]                                          [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]     IN-RECLAIM_FS-W at:
[12982.965486]                                             [<ffffffff8107b172>] __lock_acquire+0xc62/0x1ae0
[12982.965486]                                             [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                             [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]                                             [<ffffffff811b83d5>] nfs_access_cache_shrinker+0x35/0x260
[12982.965486]                                             [<ffffffff810d5ce0>] shrink_slab+0x90/0x180
[12982.965486]                                             [<ffffffff810d65f0>] kswapd+0x560/0x7a0
[12982.965486]                                             [<ffffffff8106558b>] kthread+0x5b/0xa0
[12982.965486]                                             [<ffffffff8100d40a>] child_rip+0xa/0x20
[12982.965486]                                             [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]     INITIAL USE at:
[12982.965486]                                         [<ffffffff8107a6af>] __lock_acquire+0x19f/0x1ae0
[12982.965486]                                         [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                         [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]                                         [<ffffffff811b8089>] nfs_do_access+0x2a9/0x370
[12982.965486]                                         [<ffffffff811b82fe>] nfs_permission+0x1ae/0x220
[12982.965486]                                         [<ffffffff81108280>] inode_permission+0x60/0xa0
[12982.965486]                                         [<ffffffff810fce7a>] sys_chdir+0x5a/0x90
[12982.965486]                                         [<ffffffff818b5fd4>] do_mount_root+0x3c/0xab
[12982.965486]                                         [<ffffffff818b64bf>] mount_root+0x138/0x141
[12982.965486]                                         [<ffffffff818b65c0>] prepare_namespace+0xf8/0x198
[12982.965486]                                         [<ffffffff818b56fe>] kernel_init+0x18b/0x1a8
[12982.965486]                                         [<ffffffff8100d40a>] child_rip+0xa/0x20
[12982.965486]                                         [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]   }
[12982.965486]   ... key      at: [<ffffffff817f4818>] nfs_access_lru_lock+0x18/0x40
[12982.965486]   -> (&sem->wait_lock){....-.} ops: 0 {
[12982.965486]      IN-RECLAIM_FS-W at:
[12982.965486]                                               [<ffffffff8107b172>] __lock_acquire+0xc62/0x1ae0
[12982.965486]                                               [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                               [<ffffffff8156b9a6>] _spin_lock_irqsave+0x56/0xa0
[12982.965486]                                               [<ffffffff8127d1c0>] __down_read_trylock+0x20/0x60
[12982.965486]                                               [<ffffffff8106a6ad>] down_read_trylock+0x1d/0x60
[12982.965486]                                               [<ffffffff811122cf>] shrink_dcache_memory+0x11f/0x1e0
[12982.965486]                                               [<ffffffff810d5d75>] shrink_slab+0x125/0x180
[12982.965486]                                               [<ffffffff810d65f0>] kswapd+0x560/0x7a0
[12982.965486]                                               [<ffffffff8106558b>] kthread+0x5b/0xa0
[12982.965486]                                               [<ffffffff8100d40a>] child_rip+0xa/0x20
[12982.965486]                                               [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]      INITIAL USE at:
[12982.965486]                                           [<ffffffff8107a6af>] __lock_acquire+0x19f/0x1ae0
[12982.965486]                                           [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                           [<ffffffff8156b9a6>] _spin_lock_irqsave+0x56/0xa0
[12982.965486]                                           [<ffffffff8127d160>] __down_write_trylock+0x20/0x60
[12982.965486]                                           [<ffffffff8106a56f>] down_write_nested+0x5f/0xa0
[12982.965486]                                           [<ffffffff81100f8d>] sget+0x21d/0x490
[12982.965486]                                           [<ffffffff81101866>] get_sb_single+0x46/0x100
[12982.965486]                                           [<ffffffff8115586b>] sysfs_get_sb+0x1b/0x20
[12982.965486]                                           [<ffffffff811003f0>] vfs_kern_mount+0x50/0xd0
[12982.965486]                                           [<ffffffff81100489>] kern_mount_data+0x19/0x20
[12982.965486]                                           [<ffffffff818d38d4>] sysfs_init+0x7f/0xd4
[12982.965486]                                           [<ffffffff818d20d4>] mnt_init+0x9d/0x21e
[12982.965486]                                           [<ffffffff818d1c24>] vfs_caches_init+0xa8/0x140
[12982.965486]                                           [<ffffffff818b5d0f>] start_kernel+0x34c/0x44f
[12982.965486]                                           [<ffffffff818b5299>] x86_64_start_reservations+0x99/0xb9
[12982.965486]                                           [<ffffffff818b53b0>] x86_64_start_kernel+0xf7/0x122
[12982.965486]                                           [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]    }
[12982.965486]    ... key      at: [<ffffffff822e7058>] __key.16656+0x0/0x8
[12982.965486]   ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]    [<ffffffff8156b9a6>] _spin_lock_irqsave+0x56/0xa0
[12982.965486]    [<ffffffff8127d1c0>] __down_read_trylock+0x20/0x60
[12982.965486]    [<ffffffff8106a6ad>] down_read_trylock+0x1d/0x60
[12982.965486]    [<ffffffff811b842f>] nfs_access_cache_shrinker+0x8f/0x260
[12982.965486]    [<ffffffff810d5d75>] shrink_slab+0x125/0x180
[12982.965486]    [<ffffffff810d6b9d>] shrink_all_memory+0x36d/0x4c0
[12982.965486]    [<ffffffff8108bd8f>] swsusp_shrink_memory+0x1af/0x1c0
[12982.965486]    [<ffffffff8108c842>] hibernation_snapshot+0x22/0x2a0
[12982.965486]    [<ffffffff8108cc04>] hibernate+0x144/0x220
[12982.965486]    [<ffffffff8108b204>] state_store+0xe4/0x100
[12982.965486]    [<ffffffff81278e87>] kobj_attr_store+0x17/0x20
[12982.965486]    [<ffffffff811530bf>] sysfs_write_file+0xcf/0x140
[12982.965486]    [<ffffffff810feef6>] vfs_write+0x116/0x1d0
[12982.965486]    [<ffffffff810ff0c7>] sys_write+0x57/0xb0
[12982.965486]    [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]   ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]    [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]    [<ffffffff81114bfd>] igrab+0x1d/0x50
[12982.965486]    [<ffffffff811b8440>] nfs_access_cache_shrinker+0xa0/0x260
[12982.965486]    [<ffffffff810d5d75>] shrink_slab+0x125/0x180
[12982.965486]    [<ffffffff810d6b9d>] shrink_all_memory+0x36d/0x4c0
[12982.965486]    [<ffffffff8108bd8f>] swsusp_shrink_memory+0x1af/0x1c0
[12982.965486]    [<ffffffff8108c842>] hibernation_snapshot+0x22/0x2a0
[12982.965486]    [<ffffffff8108cc04>] hibernate+0x144/0x220
[12982.965486]    [<ffffffff8108b204>] state_store+0xe4/0x100
[12982.965486]    [<ffffffff81278e87>] kobj_attr_store+0x17/0x20
[12982.965486]    [<ffffffff811530bf>] sysfs_write_file+0xcf/0x140
[12982.965486]    [<ffffffff810feef6>] vfs_write+0x116/0x1d0
[12982.965486]    [<ffffffff810ff0c7>] sys_write+0x57/0xb0
[12982.965486]    [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]   ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]    [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]    [<ffffffff811b84f6>] nfs_access_cache_shrinker+0x156/0x260
[12982.965486]    [<ffffffff810d5d75>] shrink_slab+0x125/0x180
[12982.965486]    [<ffffffff810d6b9d>] shrink_all_memory+0x36d/0x4c0
[12982.965486]    [<ffffffff8108bd8f>] swsusp_shrink_memory+0x1af/0x1c0
[12982.965486]    [<ffffffff8108c842>] hibernation_snapshot+0x22/0x2a0
[12982.965486]    [<ffffffff8108cc04>] hibernate+0x144/0x220
[12982.965486]    [<ffffffff8108b204>] state_store+0xe4/0x100
[12982.965486]    [<ffffffff81278e87>] kobj_attr_store+0x17/0x20
[12982.965486]    [<ffffffff811530bf>] sysfs_write_file+0xcf/0x140
[12982.965486]    [<ffffffff810feef6>] vfs_write+0x116/0x1d0
[12982.965486]    [<ffffffff810ff0c7>] sys_write+0x57/0xb0
[12982.965486]    [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]  ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]    [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]    [<ffffffff811b7d7f>] nfs_access_zap_cache+0x3f/0xa0
[12982.965486]    [<ffffffff811bc6a7>] nfs_clear_inode+0x77/0x90
[12982.965486]    [<ffffffff81115a6e>] clear_inode+0xfe/0x170
[12982.965486]    [<ffffffff81115cb8>] dispose_list+0x38/0x120
[12982.965486]    [<ffffffff8111602f>] shrink_icache_memory+0x28f/0x300
[12982.965486]    [<ffffffff810d5d75>] shrink_slab+0x125/0x180
[12982.965486]    [<ffffffff810d6f66>] try_to_free_pages+0x276/0x400
[12982.965486]    [<ffffffff810cdf96>] __alloc_pages_internal+0x2b6/0x650
[12982.965486]    [<ffffffff810f819c>] alloc_pages_current+0x8c/0xe0
[12982.965486]    [<ffffffff810c5920>] __page_cache_alloc+0x10/0x20
[12982.965486]    [<ffffffff810d0add>] __do_page_cache_readahead+0x11d/0x260
[12982.965486]    [<ffffffff810d0f4b>] ondemand_readahead+0x1cb/0x250
[12982.965486]    [<ffffffff810d1079>] page_cache_async_readahead+0xa9/0xc0
[12982.965486]    [<ffffffff810c7763>] generic_file_aio_read+0x493/0x7c0
[12982.965486]    [<ffffffff810fe1a9>] do_sync_read+0xf9/0x140
[12982.965486]    [<ffffffff810ff233>] vfs_read+0x113/0x1d0
[12982.965486]    [<ffffffff810ff407>] sys_read+0x57/0xb0
[12982.965486]    [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]  -> (slob_lock){-.-.-.} ops: 0 {
[12982.965486]     IN-HARDIRQ-W at:
[12982.965486]                                          [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]     IN-SOFTIRQ-W at:
[12982.965486]                                          [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]     IN-RECLAIM_FS-W at:
[12982.965486]                                             [<ffffffff8107b172>] __lock_acquire+0xc62/0x1ae0
[12982.965486]                                             [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                             [<ffffffff8156b9a6>] _spin_lock_irqsave+0x56/0xa0
[12982.965486]                                             [<ffffffff810f9fc9>] slob_alloc+0x59/0x250
[12982.965486]                                             [<ffffffff810fa2df>] kmem_cache_alloc_node+0x11f/0x1a0
[12982.965486]                                             [<ffffffff8122d523>] alloc_extent_state+0x23/0x70
[12982.965486]                                             [<ffffffff8122fcc6>] clear_extent_bit+0x206/0x360
[12982.965486]                                             [<ffffffff8122ffb3>] try_release_extent_state+0x83/0xa0
[12982.965486]                                             [<ffffffff81230143>] try_release_extent_mapping+0x173/0x1a0
[12982.965486]                                             [<ffffffff81214b6b>] __btrfs_releasepage+0x3b/0x80
[12982.965486]                                             [<ffffffff81214be0>] btrfs_releasepage+0x30/0x40
[12982.965486]                                             [<ffffffff810c3c03>] try_to_release_page+0x63/0x80
[12982.965486]                                             [<ffffffff810d497a>] shrink_page_list+0x6ba/0xa70
[12982.965486]                                             [<ffffffff810d54be>] shrink_list+0x2be/0x660
[12982.965486]                                             [<ffffffff810d5a51>] shrink_zone+0x1f1/0x3f0
[12982.965486]                                             [<ffffffff810d67b9>] kswapd+0x729/0x7a0
[12982.965486]                                             [<ffffffff8106558b>] kthread+0x5b/0xa0
[12982.965486]                                             [<ffffffff8100d40a>] child_rip+0xa/0x20
[12982.965486]                                             [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]     INITIAL USE at:
[12982.965486]                                         [<ffffffff8107a6af>] __lock_acquire+0x19f/0x1ae0
[12982.965486]                                         [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                         [<ffffffff8156b9a6>] _spin_lock_irqsave+0x56/0xa0
[12982.965486]                                         [<ffffffff810f9fc9>] slob_alloc+0x59/0x250
[12982.965486]                                         [<ffffffff810fa3a9>] kmem_cache_create+0x49/0xe0
[12982.965486]                                         [<ffffffff818d608b>] debug_objects_mem_init+0x39/0x28d
[12982.965486]                                         [<ffffffff818b5c9d>] start_kernel+0x2da/0x44f
[12982.965486]                                         [<ffffffff818b5299>] x86_64_start_reservations+0x99/0xb9
[12982.965486]                                         [<ffffffff818b53b0>] x86_64_start_kernel+0xf7/0x122
[12982.965486]                                         [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]   }
[12982.965486]   ... key      at: [<ffffffff817f0dd8>] slob_lock+0x18/0x40
[12982.965486]  ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]    [<ffffffff8156b9a6>] _spin_lock_irqsave+0x56/0xa0
[12982.965486]    [<ffffffff810f9a21>] slob_free+0xa1/0x370
[12982.965486]    [<ffffffff810fa51a>] kfree+0xda/0xf0
[12982.965486]    [<ffffffff811b7c72>] nfs_access_free_entry+0x22/0x40
[12982.965486]    [<ffffffff811b7d20>] __nfs_access_zap_cache+0x90/0xb0
[12982.965486]    [<ffffffff811b7dca>] nfs_access_zap_cache+0x8a/0xa0
[12982.965486]    [<ffffffff811bc6a7>] nfs_clear_inode+0x77/0x90
[12982.965486]    [<ffffffff81115a6e>] clear_inode+0xfe/0x170
[12982.965486]    [<ffffffff81115cb8>] dispose_list+0x38/0x120
[12982.965486]    [<ffffffff8111602f>] shrink_icache_memory+0x28f/0x300
[12982.965486]    [<ffffffff810d5d75>] shrink_slab+0x125/0x180
[12982.965486]    [<ffffffff810d6f66>] try_to_free_pages+0x276/0x400
[12982.965486]    [<ffffffff810cdf96>] __alloc_pages_internal+0x2b6/0x650
[12982.965486]    [<ffffffff810f819c>] alloc_pages_current+0x8c/0xe0
[12982.965486]    [<ffffffff810c5920>] __page_cache_alloc+0x10/0x20
[12982.965486]    [<ffffffff810d0add>] __do_page_cache_readahead+0x11d/0x260
[12982.965486]    [<ffffffff810d0f4b>] ondemand_readahead+0x1cb/0x250
[12982.965486]    [<ffffffff810d1079>] page_cache_async_readahead+0xa9/0xc0
[12982.965486]    [<ffffffff810c7763>] generic_file_aio_read+0x493/0x7c0
[12982.965486]    [<ffffffff810fe1a9>] do_sync_read+0xf9/0x140
[12982.965486]    [<ffffffff810ff233>] vfs_read+0x113/0x1d0
[12982.965486]    [<ffffffff810ff407>] sys_read+0x57/0xb0
[12982.965486]    [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]  -> (&zone->lock){..-.-.} ops: 0 {
[12982.965486]     IN-SOFTIRQ-W at:
[12982.965486]                                          [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]     IN-RECLAIM_FS-W at:
[12982.965486]                                             [<ffffffff8107b172>] __lock_acquire+0xc62/0x1ae0
[12982.965486]                                             [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                             [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]                                             [<ffffffff810cb008>] free_pages_bulk+0x38/0x3b0
[12982.965486]                                             [<ffffffff810ccc8a>] free_hot_cold_page+0x31a/0x350
[12982.965486]                                             [<ffffffff810ccd01>] __pagevec_free+0x41/0x60
[12982.965486]                                             [<ffffffff810d48d5>] shrink_page_list+0x615/0xa70
[12982.965486]                                             [<ffffffff810d54be>] shrink_list+0x2be/0x660
[12982.965486]                                             [<ffffffff810d5a51>] shrink_zone+0x1f1/0x3f0
[12982.965486]                                             [<ffffffff810d67b9>] kswapd+0x729/0x7a0
[12982.965486]                                             [<ffffffff8106558b>] kthread+0x5b/0xa0
[12982.965486]                                             [<ffffffff8100d40a>] child_rip+0xa/0x20
[12982.965486]                                             [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]     INITIAL USE at:
[12982.965486]                                         [<ffffffff8107a6af>] __lock_acquire+0x19f/0x1ae0
[12982.965486]                                         [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                         [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]                                         [<ffffffff810cb008>] free_pages_bulk+0x38/0x3b0
[12982.965486]                                         [<ffffffff810ccc8a>] free_hot_cold_page+0x31a/0x350
[12982.965486]                                         [<ffffffff810ccd50>] free_hot_page+0x10/0x20
[12982.965486]                                         [<ffffffff810ccdd2>] __free_pages+0x72/0x80
[12982.965486]                                         [<ffffffff818ec6ef>] __free_pages_bootmem+0xf0/0x111
[12982.965486]                                         [<ffffffff818cf1c7>] free_all_bootmem_core+0x10b/0x235
[12982.965486]                                         [<ffffffff818cf31a>] free_all_bootmem_node+0x10/0x12
[12982.965486]                                         [<ffffffff818c88d1>] numa_free_all_bootmem+0x49/0x7f
[12982.965486]                                         [<ffffffff818c78bc>] mem_init+0x1e/0x161
[12982.965486]                                         [<ffffffff818b5c8d>] start_kernel+0x2ca/0x44f
[12982.965486]                                         [<ffffffff818b5299>] x86_64_start_reservations+0x99/0xb9
[12982.965486]                                         [<ffffffff818b53b0>] x86_64_start_kernel+0xf7/0x122
[12982.965486]                                         [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]   }
[12982.965486]   ... key      at: [<ffffffff822d73b0>] __key.32155+0x0/0x8
[12982.965486]  ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]    [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]    [<ffffffff810cb008>] free_pages_bulk+0x38/0x3b0
[12982.965486]    [<ffffffff810ccc8a>] free_hot_cold_page+0x31a/0x350
[12982.965486]    [<ffffffff810ccd50>] free_hot_page+0x10/0x20
[12982.965486]    [<ffffffff810ccdd2>] __free_pages+0x72/0x80
[12982.965486]    [<ffffffff810cce5b>] free_pages+0x7b/0x80
[12982.965486]    [<ffffffff810f9ad5>] slob_free+0x155/0x370
[12982.965486]    [<ffffffff810f9d25>] __kmem_cache_free+0x35/0x40
[12982.965486]    [<ffffffff810f9dfc>] kmem_cache_free+0xcc/0xd0
[12982.965486]    [<ffffffff811ba0ec>] nfs_destroy_inode+0x1c/0x20
[12982.965486]    [<ffffffff81115c5d>] destroy_inode+0x4d/0x70
[12982.965486]    [<ffffffff81115d31>] dispose_list+0xb1/0x120
[12982.965486]    [<ffffffff8111602f>] shrink_icache_memory+0x28f/0x300
[12982.965486]    [<ffffffff810d5d75>] shrink_slab+0x125/0x180
[12982.965486]    [<ffffffff810d6f66>] try_to_free_pages+0x276/0x400
[12982.965486]    [<ffffffff810cdf96>] __alloc_pages_internal+0x2b6/0x650
[12982.965486]    [<ffffffff810f819c>] alloc_pages_current+0x8c/0xe0
[12982.965486]    [<ffffffff810c5920>] __page_cache_alloc+0x10/0x20
[12982.965486]    [<ffffffff810d0add>] __do_page_cache_readahead+0x11d/0x260
[12982.965486]    [<ffffffff810d0f4b>] ondemand_readahead+0x1cb/0x250
[12982.965486]    [<ffffffff810d1079>] page_cache_async_readahead+0xa9/0xc0
[12982.965486]    [<ffffffff810c7763>] generic_file_aio_read+0x493/0x7c0
[12982.965486]    [<ffffffff810fe1a9>] do_sync_read+0xf9/0x140
[12982.965486]    [<ffffffff810ff233>] vfs_read+0x113/0x1d0
[12982.965486]    [<ffffffff810ff407>] sys_read+0x57/0xb0
[12982.965486]    [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]  ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]    [<ffffffff8156b9a6>] _spin_lock_irqsave+0x56/0xa0
[12982.965486]    [<ffffffff81286fd6>] free_object+0x16/0xa0
[12982.965486]    [<ffffffff81287226>] debug_check_no_obj_freed+0x1c6/0x200
[12982.965486]    [<ffffffff810ccabc>] free_hot_cold_page+0x14c/0x350
[12982.965486]    [<ffffffff810ccd50>] free_hot_page+0x10/0x20
[12982.965486]    [<ffffffff810ccdd2>] __free_pages+0x72/0x80
[12982.965486]    [<ffffffff810cce5b>] free_pages+0x7b/0x80
[12982.965486]    [<ffffffff810f9ad5>] slob_free+0x155/0x370
[12982.965486]    [<ffffffff810f9d25>] __kmem_cache_free+0x35/0x40
[12982.965486]    [<ffffffff810f9dfc>] kmem_cache_free+0xcc/0xd0
[12982.965486]    [<ffffffff811ba0ec>] nfs_destroy_inode+0x1c/0x20
[12982.965486]    [<ffffffff81115c5d>] destroy_inode+0x4d/0x70
[12982.965486]    [<ffffffff81115d31>] dispose_list+0xb1/0x120
[12982.965486]    [<ffffffff8111602f>] shrink_icache_memory+0x28f/0x300
[12982.965486]    [<ffffffff810d5d75>] shrink_slab+0x125/0x180
[12982.965486]    [<ffffffff810d6f66>] try_to_free_pages+0x276/0x400
[12982.965486]    [<ffffffff810cdf96>] __alloc_pages_internal+0x2b6/0x650
[12982.965486]    [<ffffffff810f819c>] alloc_pages_current+0x8c/0xe0
[12982.965486]    [<ffffffff810c5920>] __page_cache_alloc+0x10/0x20
[12982.965486]    [<ffffffff810d0add>] __do_page_cache_readahead+0x11d/0x260
[12982.965486]    [<ffffffff810d0f4b>] ondemand_readahead+0x1cb/0x250
[12982.965486]    [<ffffffff810d1079>] page_cache_async_readahead+0xa9/0xc0
[12982.965486]    [<ffffffff810c7763>] generic_file_aio_read+0x493/0x7c0
[12982.965486]    [<ffffffff810fe1a9>] do_sync_read+0xf9/0x140
[12982.965486]    [<ffffffff810ff233>] vfs_read+0x113/0x1d0
[12982.965486]    [<ffffffff810ff407>] sys_read+0x57/0xb0
[12982.965486]    [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]
[12982.965486] the RECLAIM_FS-irq-unsafe lock's dependencies:
[12982.965486] -> (&inode->inotify_mutex){+.+.+.} ops: 0 {
[12982.965486]    HARDIRQ-ON-W at:
[12982.965486]                                        [<ffffffff8107b035>] __lock_acquire+0xb25/0x1ae0
[12982.965486]                                        [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                        [<ffffffff81569353>] mutex_lock_nested+0x63/0x420
[12982.965486]                                        [<ffffffff811340e5>] inotify_find_update_watch+0x85/0x130
[12982.965486]                                        [<ffffffff811354e4>] sys_inotify_add_watch+0x184/0x290
[12982.965486]                                        [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[12982.965486]                                        [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]    SOFTIRQ-ON-W at:
[12982.965486]                                        [<ffffffff8107b061>] __lock_acquire+0xb51/0x1ae0
[12982.965486]                                        [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                        [<ffffffff81569353>] mutex_lock_nested+0x63/0x420
[12982.965486]                                        [<ffffffff811340e5>] inotify_find_update_watch+0x85/0x130
[12982.965486]                                        [<ffffffff811354e4>] sys_inotify_add_watch+0x184/0x290
[12982.965486]                                        [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[12982.965486]                                        [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]    RECLAIM_FS-ON-W at:
[12982.965486]                                           [<ffffffff810791b8>] mark_held_locks+0x68/0x90
[12982.965486]                                           [<ffffffff810792d5>] lockdep_trace_alloc+0xf5/0x100
[12982.965486]                                           [<ffffffff810fa561>] __kmalloc_node+0x31/0x1e0
[12982.965486]                                           [<ffffffff811359c2>] kernel_event+0xe2/0x190
[12982.965486]                                           [<ffffffff81135b96>] inotify_dev_queue_event+0x126/0x230
[12982.965486]                                           [<ffffffff811343a6>] inotify_inode_queue_event+0xc6/0x110
[12982.965486]                                           [<ffffffff8110974d>] vfs_create+0xcd/0x140
[12982.965486]                                           [<ffffffff8110d55d>] do_filp_open+0x88d/0xa20
[12982.965486]                                           [<ffffffff810fbe68>] do_sys_open+0x98/0x140
[12982.965486]                                           [<ffffffff810fbf50>] sys_open+0x20/0x30
[12982.965486]                                           [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[12982.965486]                                           [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]    INITIAL USE at:
[12982.965486]                                       [<ffffffff8107a6af>] __lock_acquire+0x19f/0x1ae0
[12982.965486]                                       [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                       [<ffffffff81569353>] mutex_lock_nested+0x63/0x420
[12982.965486]                                       [<ffffffff811340e5>] inotify_find_update_watch+0x85/0x130
[12982.965486]                                       [<ffffffff811354e4>] sys_inotify_add_watch+0x184/0x290
[12982.965486]                                       [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[12982.965486]                                       [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]  }
[12982.965486]  ... key      at: [<ffffffff822da484>] __key.28540+0x0/0x8
[12982.965486]  -> (&ih->mutex){+.+.+.} ops: 0 {
[12982.965486]     HARDIRQ-ON-W at:
[12982.965486]                                          [<ffffffff8107b035>] __lock_acquire+0xb25/0x1ae0
[12982.965486]                                          [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                          [<ffffffff81569353>] mutex_lock_nested+0x63/0x420
[12982.965486]                                          [<ffffffff811340f7>] inotify_find_update_watch+0x97/0x130
[12982.965486]                                          [<ffffffff811354e4>] sys_inotify_add_watch+0x184/0x290
[12982.965486]                                          [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[12982.965486]                                          [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]     SOFTIRQ-ON-W at:
[12982.965486]                                          [<ffffffff8107b061>] __lock_acquire+0xb51/0x1ae0
[12982.965486]                                          [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                          [<ffffffff81569353>] mutex_lock_nested+0x63/0x420
[12982.965486]                                          [<ffffffff811340f7>] inotify_find_update_watch+0x97/0x130
[12982.965486]                                          [<ffffffff811354e4>] sys_inotify_add_watch+0x184/0x290
[12982.965486]                                          [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[12982.965486]                                          [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]     RECLAIM_FS-ON-W at:
[12982.965486]                                             [<ffffffff810791b8>] mark_held_locks+0x68/0x90
[12982.965486]                                             [<ffffffff810792d5>] lockdep_trace_alloc+0xf5/0x100
[12982.965486]                                             [<ffffffff810fa561>] __kmalloc_node+0x31/0x1e0
[12982.965486]                                             [<ffffffff811359c2>] kernel_event+0xe2/0x190
[12982.965486]                                             [<ffffffff81135b96>] inotify_dev_queue_event+0x126/0x230
[12982.965486]                                             [<ffffffff811343a6>] inotify_inode_queue_event+0xc6/0x110
[12982.965486]                                             [<ffffffff8110974d>] vfs_create+0xcd/0x140
[12982.965486]                                             [<ffffffff8110d55d>] do_filp_open+0x88d/0xa20
[12982.965486]                                             [<ffffffff810fbe68>] do_sys_open+0x98/0x140
[12982.965486]                                             [<ffffffff810fbf50>] sys_open+0x20/0x30
[12982.965486]                                             [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[12982.965486]                                             [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]     INITIAL USE at:
[12982.965486]                                         [<ffffffff8107a6af>] __lock_acquire+0x19f/0x1ae0
[12982.965486]                                         [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                         [<ffffffff81569353>] mutex_lock_nested+0x63/0x420
[12982.965486]                                         [<ffffffff811340f7>] inotify_find_update_watch+0x97/0x130
[12982.965486]                                         [<ffffffff811354e4>] sys_inotify_add_watch+0x184/0x290
[12982.965486]                                         [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[12982.965486]                                         [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]   }
[12982.965486]   ... key      at: [<ffffffff822da858>] __key.20503+0x0/0x8
[12982.965486]   -> (slob_lock){-.-.-.} ops: 0 {
[12982.965486]      IN-HARDIRQ-W at:
[12982.965486]                                            [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]      IN-SOFTIRQ-W at:
[12982.965486]                                            [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]      IN-RECLAIM_FS-W at:
[12982.965486]                                               [<ffffffff8107b172>] __lock_acquire+0xc62/0x1ae0
[12982.965486]                                               [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                               [<ffffffff8156b9a6>] _spin_lock_irqsave+0x56/0xa0
[12982.965486]                                               [<ffffffff810f9fc9>] slob_alloc+0x59/0x250
[12982.965486]                                               [<ffffffff810fa2df>] kmem_cache_alloc_node+0x11f/0x1a0
[12982.965486]                                               [<ffffffff8122d523>] alloc_extent_state+0x23/0x70
[12982.965486]                                               [<ffffffff8122fcc6>] clear_extent_bit+0x206/0x360
[12982.965486]                                               [<ffffffff8122ffb3>] try_release_extent_state+0x83/0xa0
[12982.965486]                                               [<ffffffff81230143>] try_release_extent_mapping+0x173/0x1a0
[12982.965486]                                               [<ffffffff81214b6b>] __btrfs_releasepage+0x3b/0x80
[12982.965486]                                               [<ffffffff81214be0>] btrfs_releasepage+0x30/0x40
[12982.965486]                                               [<ffffffff810c3c03>] try_to_release_page+0x63/0x80
[12982.965486]                                               [<ffffffff810d497a>] shrink_page_list+0x6ba/0xa70
[12982.965486]                                               [<ffffffff810d54be>] shrink_list+0x2be/0x660
[12982.965486]                                               [<ffffffff810d5a51>] shrink_zone+0x1f1/0x3f0
[12982.965486]                                               [<ffffffff810d67b9>] kswapd+0x729/0x7a0
[12982.965486]                                               [<ffffffff8106558b>] kthread+0x5b/0xa0
[12982.965486]                                               [<ffffffff8100d40a>] child_rip+0xa/0x20
[12982.965486]                                               [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]      INITIAL USE at:
[12982.965486]                                           [<ffffffff8107a6af>] __lock_acquire+0x19f/0x1ae0
[12982.965486]                                           [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                           [<ffffffff8156b9a6>] _spin_lock_irqsave+0x56/0xa0
[12982.965486]                                           [<ffffffff810f9fc9>] slob_alloc+0x59/0x250
[12982.965486]                                           [<ffffffff810fa3a9>] kmem_cache_create+0x49/0xe0
[12982.965486]                                           [<ffffffff818d608b>] debug_objects_mem_init+0x39/0x28d
[12982.965486]                                           [<ffffffff818b5c9d>] start_kernel+0x2da/0x44f
[12982.965486]                                           [<ffffffff818b5299>] x86_64_start_reservations+0x99/0xb9
[12982.965486]                                           [<ffffffff818b53b0>] x86_64_start_kernel+0xf7/0x122
[12982.965486]                                           [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]    }
[12982.965486]    ... key      at: [<ffffffff817f0dd8>] slob_lock+0x18/0x40
[12982.965486]   ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]    [<ffffffff8156b9a6>] _spin_lock_irqsave+0x56/0xa0
[12982.965486]    [<ffffffff810f9fc9>] slob_alloc+0x59/0x250
[12982.965486]    [<ffffffff810fa2df>] kmem_cache_alloc_node+0x11f/0x1a0
[12982.965486]    [<ffffffff812789da>] idr_pre_get+0x6a/0x90
[12982.965486]    [<ffffffff81133c8a>] inotify_handle_get_wd+0x3a/0xc0
[12982.965486]    [<ffffffff81133f9b>] inotify_add_watch+0xab/0x170
[12982.965486]    [<ffffffff811355c8>] sys_inotify_add_watch+0x268/0x290
[12982.965486]    [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]   -> (&idp->lock){......} ops: 0 {
[12982.965486]      INITIAL USE at:
[12982.965486]                                           [<ffffffff8107a6af>] __lock_acquire+0x19f/0x1ae0
[12982.965486]                                           [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                           [<ffffffff8156b9a6>] _spin_lock_irqsave+0x56/0xa0
[12982.965486]                                           [<ffffffff812789a0>] idr_pre_get+0x30/0x90
[12982.965486]                                           [<ffffffff8140ef99>] get_idr+0x39/0x100
[12982.965486]                                           [<ffffffff8140fc70>] thermal_zone_bind_cooling_device+0x120/0x2a0
[12982.965486]                                           [<ffffffff812e4e4d>] acpi_thermal_cooling_device_cb+0x8a/0x180
[12982.965486]                                           [<ffffffff812e4f6f>] acpi_thermal_bind_cooling_device+0x15/0x17
[12982.965486]                                           [<ffffffff8140f8d4>] thermal_zone_device_register+0x334/0x490
[12982.965486]                                           [<ffffffff812e5189>] acpi_thermal_add+0x218/0x4b5
[12982.965486]                                           [<ffffffff812a8af2>] acpi_device_probe+0x5c/0x1c9
[12982.965486]                                           [<ffffffff81328774>] driver_probe_device+0xc4/0x1e0
[12982.965486]                                           [<ffffffff8132892b>] __driver_attach+0x9b/0xb0
[12982.965486]                                           [<ffffffff81327ee3>] bus_for_each_dev+0x73/0xa0
[12982.965486]                                           [<ffffffff81328581>] driver_attach+0x21/0x30
[12982.965486]                                           [<ffffffff8132766d>] bus_add_driver+0x15d/0x260
[12982.965486]                                           [<ffffffff81328c64>] driver_register+0xa4/0x180
[12982.965486]                                           [<ffffffff812aa48d>] acpi_bus_register_driver+0x43/0x46
[12982.965486]                                           [<ffffffff818d96bb>] acpi_thermal_init+0x59/0x7b
[12982.965486]                                           [<ffffffff8100904f>] do_one_initcall+0x3f/0x1d0
[12982.965486]                                           [<ffffffff818b56c3>] kernel_init+0x150/0x1a8
[12982.965486]                                           [<ffffffff8100d40a>] child_rip+0xa/0x20
[12982.965486]                                           [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]    }
[12982.965486]    ... key      at: [<ffffffff822e6df8>] __key.12631+0x0/0x8
[12982.965486]   ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]    [<ffffffff8156b9a6>] _spin_lock_irqsave+0x56/0xa0
[12982.965486]    [<ffffffff812789a0>] idr_pre_get+0x30/0x90
[12982.965486]    [<ffffffff81133c8a>] inotify_handle_get_wd+0x3a/0xc0
[12982.965486]    [<ffffffff81133f9b>] inotify_add_watch+0xab/0x170
[12982.965486]    [<ffffffff811355c8>] sys_inotify_add_watch+0x268/0x290
[12982.965486]    [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]   -> (inode_lock){+.+.-.} ops: 0 {
[12982.965486]      HARDIRQ-ON-W at:
[12982.965486]                                            [<ffffffff8107b035>] __lock_acquire+0xb25/0x1ae0
[12982.965486]                                            [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                            [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]                                            [<ffffffff811155ae>] ifind_fast+0x2e/0xd0
[12982.965486]                                            [<ffffffff81116949>] iget_locked+0x49/0x180
[12982.965486]                                            [<ffffffff811527d5>] sysfs_get_inode+0x25/0x280
[12982.965486]                                            [<ffffffff811558c6>] sysfs_fill_super+0x56/0xd0
[12982.965486]                                            [<ffffffff811018ea>] get_sb_single+0xca/0x100
[12982.965486]                                            [<ffffffff8115586b>] sysfs_get_sb+0x1b/0x20
[12982.965486]                                            [<ffffffff811003f0>] vfs_kern_mount+0x50/0xd0
[12982.965486]                                            [<ffffffff81100489>] kern_mount_data+0x19/0x20
[12982.965486]                                            [<ffffffff818d38d4>] sysfs_init+0x7f/0xd4
[12982.965486]                                            [<ffffffff818d20d4>] mnt_init+0x9d/0x21e
[12982.965486]                                            [<ffffffff818d1c24>] vfs_caches_init+0xa8/0x140
[12982.965486]                                            [<ffffffff818b5d0f>] start_kernel+0x34c/0x44f
[12982.965486]                                            [<ffffffff818b5299>] x86_64_start_reservations+0x99/0xb9
[12982.965486]                                            [<ffffffff818b53b0>] x86_64_start_kernel+0xf7/0x122
[12982.965486]                                            [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]      SOFTIRQ-ON-W at:
[12982.965486]                                            [<ffffffff8107b061>] __lock_acquire+0xb51/0x1ae0
[12982.965486]                                            [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                            [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]                                            [<ffffffff811155ae>] ifind_fast+0x2e/0xd0
[12982.965486]                                            [<ffffffff81116949>] iget_locked+0x49/0x180
[12982.965486]                                            [<ffffffff811527d5>] sysfs_get_inode+0x25/0x280
[12982.965486]                                            [<ffffffff811558c6>] sysfs_fill_super+0x56/0xd0
[12982.965486]                                            [<ffffffff811018ea>] get_sb_single+0xca/0x100
[12982.965486]                                            [<ffffffff8115586b>] sysfs_get_sb+0x1b/0x20
[12982.965486]                                            [<ffffffff811003f0>] vfs_kern_mount+0x50/0xd0
[12982.965486]                                            [<ffffffff81100489>] kern_mount_data+0x19/0x20
[12982.965486]                                            [<ffffffff818d38d4>] sysfs_init+0x7f/0xd4
[12982.965486]                                            [<ffffffff818d20d4>] mnt_init+0x9d/0x21e
[12982.965486]                                            [<ffffffff818d1c24>] vfs_caches_init+0xa8/0x140
[12982.965486]                                            [<ffffffff818b5d0f>] start_kernel+0x34c/0x44f
[12982.965486]                                            [<ffffffff818b5299>] x86_64_start_reservations+0x99/0xb9
[12982.965486]                                            [<ffffffff818b53b0>] x86_64_start_kernel+0xf7/0x122
[12982.965486]                                            [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]      IN-RECLAIM_FS-W at:
[12982.965486]                                               [<ffffffff8107b172>] __lock_acquire+0xc62/0x1ae0
[12982.965486]                                               [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                               [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]                                               [<ffffffff81277628>] _atomic_dec_and_lock+0x98/0xc0
[12982.965486]                                               [<ffffffff81114fea>] iput+0x4a/0x90
[12982.965486]                                               [<ffffffff81154764>] sysfs_d_iput+0x34/0x40
[12982.965486]                                               [<ffffffff81111caa>] dentry_iput+0x8a/0xf0
[12982.965486]                                               [<ffffffff81111e33>] d_kill+0x33/0x60
[12982.965486]                                               [<ffffffff81112133>] __shrink_dcache_sb+0x2d3/0x350
[12982.965486]                                               [<ffffffff8111230a>] shrink_dcache_memory+0x15a/0x1e0
[12982.965486]                                               [<ffffffff810d5d75>] shrink_slab+0x125/0x180
[12982.965486]                                               [<ffffffff810d65f0>] kswapd+0x560/0x7a0
[12982.965486]                                               [<ffffffff8106558b>] kthread+0x5b/0xa0
[12982.965486]                                               [<ffffffff8100d40a>] child_rip+0xa/0x20
[12982.965486]                                               [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]      INITIAL USE at:
[12982.965486]                                           [<ffffffff8107a6af>] __lock_acquire+0x19f/0x1ae0
[12982.965486]                                           [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                           [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]                                           [<ffffffff811155ae>] ifind_fast+0x2e/0xd0
[12982.965486]                                           [<ffffffff81116949>] iget_locked+0x49/0x180
[12982.965486]                                           [<ffffffff811527d5>] sysfs_get_inode+0x25/0x280
[12982.965486]                                           [<ffffffff811558c6>] sysfs_fill_super+0x56/0xd0
[12982.965486]                                           [<ffffffff811018ea>] get_sb_single+0xca/0x100
[12982.965486]                                           [<ffffffff8115586b>] sysfs_get_sb+0x1b/0x20
[12982.965486]                                           [<ffffffff811003f0>] vfs_kern_mount+0x50/0xd0
[12982.965486]                                           [<ffffffff81100489>] kern_mount_data+0x19/0x20
[12982.965486]                                           [<ffffffff818d38d4>] sysfs_init+0x7f/0xd4
[12982.965486]                                           [<ffffffff818d20d4>] mnt_init+0x9d/0x21e
[12982.965486]                                           [<ffffffff818d1c24>] vfs_caches_init+0xa8/0x140
[12982.965486]                                           [<ffffffff818b5d0f>] start_kernel+0x34c/0x44f
[12982.965486]                                           [<ffffffff818b5299>] x86_64_start_reservations+0x99/0xb9
[12982.965486]                                           [<ffffffff818b53b0>] x86_64_start_kernel+0xf7/0x122
[12982.965486]                                           [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]    }
[12982.965486]    ... key      at: [<ffffffff817f1678>] inode_lock+0x18/0x40
[12982.965486]   ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]    [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]    [<ffffffff81114bfd>] igrab+0x1d/0x50
[12982.965486]    [<ffffffff81133ff0>] inotify_add_watch+0x100/0x170
[12982.965486]    [<ffffffff811355c8>] sys_inotify_add_watch+0x268/0x290
[12982.965486]    [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]   -> (dcache_lock){+.+.-.} ops: 0 {
[12982.965486]      HARDIRQ-ON-W at:
[12982.965486]                                            [<ffffffff8107b035>] __lock_acquire+0xb25/0x1ae0
[12982.965486]                                            [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                            [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]                                            [<ffffffff81113ebf>] d_alloc+0x20f/0x230
[12982.965486]                                            [<ffffffff81113f0e>] d_alloc_root+0x2e/0x70
[12982.965486]                                            [<ffffffff811558e2>] sysfs_fill_super+0x72/0xd0
[12982.965486]                                            [<ffffffff811018ea>] get_sb_single+0xca/0x100
[12982.965486]                                            [<ffffffff8115586b>] sysfs_get_sb+0x1b/0x20
[12982.965486]                                            [<ffffffff811003f0>] vfs_kern_mount+0x50/0xd0
[12982.965486]                                            [<ffffffff81100489>] kern_mount_data+0x19/0x20
[12982.965486]                                            [<ffffffff818d38d4>] sysfs_init+0x7f/0xd4
[12982.965486]                                            [<ffffffff818d20d4>] mnt_init+0x9d/0x21e
[12982.965486]                                            [<ffffffff818d1c24>] vfs_caches_init+0xa8/0x140
[12982.965486]                                            [<ffffffff818b5d0f>] start_kernel+0x34c/0x44f
[12982.965486]                                            [<ffffffff818b5299>] x86_64_start_reservations+0x99/0xb9
[12982.965486]                                            [<ffffffff818b53b0>] x86_64_start_kernel+0xf7/0x122
[12982.965486]                                            [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]      SOFTIRQ-ON-W at:
[12982.965486]                                            [<ffffffff8107b061>] __lock_acquire+0xb51/0x1ae0
[12982.965486]                                            [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                            [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]                                            [<ffffffff81113ebf>] d_alloc+0x20f/0x230
[12982.965486]                                            [<ffffffff81113f0e>] d_alloc_root+0x2e/0x70
[12982.965486]                                            [<ffffffff811558e2>] sysfs_fill_super+0x72/0xd0
[12982.965486]                                            [<ffffffff811018ea>] get_sb_single+0xca/0x100
[12982.965486]                                            [<ffffffff8115586b>] sysfs_get_sb+0x1b/0x20
[12982.965486]                                            [<ffffffff811003f0>] vfs_kern_mount+0x50/0xd0
[12982.965486]                                            [<ffffffff81100489>] kern_mount_data+0x19/0x20
[12982.965486]                                            [<ffffffff818d38d4>] sysfs_init+0x7f/0xd4
[12982.965486]                                            [<ffffffff818d20d4>] mnt_init+0x9d/0x21e
[12982.965486]                                            [<ffffffff818d1c24>] vfs_caches_init+0xa8/0x140
[12982.965486]                                            [<ffffffff818b5d0f>] start_kernel+0x34c/0x44f
[12982.965486]                                            [<ffffffff818b5299>] x86_64_start_reservations+0x99/0xb9
[12982.965486]                                            [<ffffffff818b53b0>] x86_64_start_kernel+0xf7/0x122
[12982.965486]                                            [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]      IN-RECLAIM_FS-W at:
[12982.965486]                                               [<ffffffff8107b172>] __lock_acquire+0xc62/0x1ae0
[12982.965486]                                               [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                               [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]                                               [<ffffffff81112235>] shrink_dcache_memory+0x85/0x1e0
[12982.965486]                                               [<ffffffff810d5d75>] shrink_slab+0x125/0x180
[12982.965486]                                               [<ffffffff810d65f0>] kswapd+0x560/0x7a0
[12982.965486]                                               [<ffffffff8106558b>] kthread+0x5b/0xa0
[12982.965486]                                               [<ffffffff8100d40a>] child_rip+0xa/0x20
[12982.965486]                                               [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]      INITIAL USE at:
[12982.965486]                                           [<ffffffff8107a6af>] __lock_acquire+0x19f/0x1ae0
[12982.965486]                                           [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                           [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]                                           [<ffffffff81113ebf>] d_alloc+0x20f/0x230
[12982.965486]                                           [<ffffffff81113f0e>] d_alloc_root+0x2e/0x70
[12982.965486]                                           [<ffffffff811558e2>] sysfs_fill_super+0x72/0xd0
[12982.965486]                                           [<ffffffff811018ea>] get_sb_single+0xca/0x100
[12982.965486]                                           [<ffffffff8115586b>] sysfs_get_sb+0x1b/0x20
[12982.965486]                                           [<ffffffff811003f0>] vfs_kern_mount+0x50/0xd0
[12982.965486]                                           [<ffffffff81100489>] kern_mount_data+0x19/0x20
[12982.965486]                                           [<ffffffff818d38d4>] sysfs_init+0x7f/0xd4
[12982.965486]                                           [<ffffffff818d20d4>] mnt_init+0x9d/0x21e
[12982.965486]                                           [<ffffffff818d1c24>] vfs_caches_init+0xa8/0x140
[12982.965486]                                           [<ffffffff818b5d0f>] start_kernel+0x34c/0x44f
[12982.965486]                                           [<ffffffff818b5299>] x86_64_start_reservations+0x99/0xb9
[12982.965486]                                           [<ffffffff818b53b0>] x86_64_start_kernel+0xf7/0x122
[12982.965486]                                           [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]    }
[12982.965486]    ... key      at: [<ffffffff818a37d8>] dcache_lock+0x18/0x40
[12982.965486]    -> (&dentry->d_lock){+.+.-.} ops: 0 {
[12982.965486]       HARDIRQ-ON-W at:
[12982.965486]                                              [<ffffffff8107b035>] __lock_acquire+0xb25/0x1ae0
[12982.965486]                                              [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                              [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]                                              [<ffffffff81133a2a>] inotify_d_instantiate+0x2a/0x60
[12982.965486]                                              [<ffffffff81112f15>] __d_instantiate+0x45/0x50
[12982.965486]                                              [<ffffffff81112f7a>] d_instantiate+0x5a/0x80
[12982.965486]                                              [<ffffffff81113f34>] d_alloc_root+0x54/0x70
[12982.965486]                                              [<ffffffff811558e2>] sysfs_fill_super+0x72/0xd0
[12982.965486]                                              [<ffffffff811018ea>] get_sb_single+0xca/0x100
[12982.965486]                                              [<ffffffff8115586b>] sysfs_get_sb+0x1b/0x20
[12982.965486]                                              [<ffffffff811003f0>] vfs_kern_mount+0x50/0xd0
[12982.965486]                                              [<ffffffff81100489>] kern_mount_data+0x19/0x20
[12982.965486]                                              [<ffffffff818d38d4>] sysfs_init+0x7f/0xd4
[12982.965486]                                              [<ffffffff818d20d4>] mnt_init+0x9d/0x21e
[12982.965486]                                              [<ffffffff818d1c24>] vfs_caches_init+0xa8/0x140
[12982.965486]                                              [<ffffffff818b5d0f>] start_kernel+0x34c/0x44f
[12982.965486]                                              [<ffffffff818b5299>] x86_64_start_reservations+0x99/0xb9
[12982.965486]                                              [<ffffffff818b53b0>] x86_64_start_kernel+0xf7/0x122
[12982.965486]                                              [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]       SOFTIRQ-ON-W at:
[12982.965486]                                              [<ffffffff8107b061>] __lock_acquire+0xb51/0x1ae0
[12982.965486]                                              [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                              [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]                                              [<ffffffff81133a2a>] inotify_d_instantiate+0x2a/0x60
[12982.965486]                                              [<ffffffff81112f15>] __d_instantiate+0x45/0x50
[12982.965486]                                              [<ffffffff81112f7a>] d_instantiate+0x5a/0x80
[12982.965486]                                              [<ffffffff81113f34>] d_alloc_root+0x54/0x70
[12982.965486]                                              [<ffffffff811558e2>] sysfs_fill_super+0x72/0xd0
[12982.965486]                                              [<ffffffff811018ea>] get_sb_single+0xca/0x100
[12982.965486]                                              [<ffffffff8115586b>] sysfs_get_sb+0x1b/0x20
[12982.965486]                                              [<ffffffff811003f0>] vfs_kern_mount+0x50/0xd0
[12982.965486]                                              [<ffffffff81100489>] kern_mount_data+0x19/0x20
[12982.965486]                                              [<ffffffff818d38d4>] sysfs_init+0x7f/0xd4
[12982.965486]                                              [<ffffffff818d20d4>] mnt_init+0x9d/0x21e
[12982.965486]                                              [<ffffffff818d1c24>] vfs_caches_init+0xa8/0x140
[12982.965486]                                              [<ffffffff818b5d0f>] start_kernel+0x34c/0x44f
[12982.965486]                                              [<ffffffff818b5299>] x86_64_start_reservations+0x99/0xb9
[12982.965486]                                              [<ffffffff818b53b0>] x86_64_start_kernel+0xf7/0x122
[12982.965486]                                              [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]       IN-RECLAIM_FS-W at:
[12982.965486]                                                 [<ffffffff8107b172>] __lock_acquire+0xc62/0x1ae0
[12982.965486]                                                 [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                                 [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]                                                 [<ffffffff81111fcb>] __shrink_dcache_sb+0x16b/0x350
[12982.965486]                                                 [<ffffffff8111230a>] shrink_dcache_memory+0x15a/0x1e0
[12982.965486]                                                 [<ffffffff810d5d75>] shrink_slab+0x125/0x180
[12982.965486]                                                 [<ffffffff810d65f0>] kswapd+0x560/0x7a0
[12982.965486]                                                 [<ffffffff8106558b>] kthread+0x5b/0xa0
[12982.965486]                                                 [<ffffffff8100d40a>] child_rip+0xa/0x20
[12982.965486]                                                 [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]       INITIAL USE at:
[12982.965486]                                             [<ffffffff8107a6af>] __lock_acquire+0x19f/0x1ae0
[12982.965486]                                             [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                             [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]                                             [<ffffffff81133a2a>] inotify_d_instantiate+0x2a/0x60
[12982.965486]                                             [<ffffffff81112f15>] __d_instantiate+0x45/0x50
[12982.965486]                                             [<ffffffff81112f7a>] d_instantiate+0x5a/0x80
[12982.965486]                                             [<ffffffff81113f34>] d_alloc_root+0x54/0x70
[12982.965486]                                             [<ffffffff811558e2>] sysfs_fill_super+0x72/0xd0
[12982.965486]                                             [<ffffffff811018ea>] get_sb_single+0xca/0x100
[12982.965486]                                             [<ffffffff8115586b>] sysfs_get_sb+0x1b/0x20
[12982.965486]                                             [<ffffffff811003f0>] vfs_kern_mount+0x50/0xd0
[12982.965486]                                             [<ffffffff81100489>] kern_mount_data+0x19/0x20
[12982.965486]                                             [<ffffffff818d38d4>] sysfs_init+0x7f/0xd4
[12982.965486]                                             [<ffffffff818d20d4>] mnt_init+0x9d/0x21e
[12982.965486]                                             [<ffffffff818d1c24>] vfs_caches_init+0xa8/0x140
[12982.965486]                                             [<ffffffff818b5d0f>] start_kernel+0x34c/0x44f
[12982.965486]                                             [<ffffffff818b5299>] x86_64_start_reservations+0x99/0xb9
[12982.965486]                                             [<ffffffff818b53b0>] x86_64_start_kernel+0xf7/0x122
[12982.965486]                                             [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]     }
[12982.965486]     ... key      at: [<ffffffff822da420>] __key.28050+0x0/0x20
[12982.965486]     -> (&dentry->d_lock/1){+.+...} ops: 0 {
[12982.965486]        HARDIRQ-ON-W at:
[12982.965486]                                                [<ffffffff8107b035>] __lock_acquire+0xb25/0x1ae0
[12982.965486]                                                [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                                [<ffffffff8156b7b4>] _spin_lock_nested+0x34/0x70
[12982.965486]                                                [<ffffffff811134b2>] d_move_locked+0x212/0x260
[12982.965486]                                                [<ffffffff81113533>] d_move+0x33/0x50
[12982.965486]                                                [<ffffffff81109e05>] vfs_rename+0x375/0x430
[12982.965486]                                                [<ffffffff8110c0ad>] sys_renameat+0x24d/0x2a0
[12982.965486]                                                [<ffffffff8110c11b>] sys_rename+0x1b/0x20
[12982.965486]                                                [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[12982.965486]                                                [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]        SOFTIRQ-ON-W at:
[12982.965486]                                                [<ffffffff8107b061>] __lock_acquire+0xb51/0x1ae0
[12982.965486]                                                [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                                [<ffffffff8156b7b4>] _spin_lock_nested+0x34/0x70
[12982.965486]                                                [<ffffffff811134b2>] d_move_locked+0x212/0x260
[12982.965486]                                                [<ffffffff81113533>] d_move+0x33/0x50
[12982.965486]                                                [<ffffffff81109e05>] vfs_rename+0x375/0x430
[12982.965486]                                                [<ffffffff8110c0ad>] sys_renameat+0x24d/0x2a0
[12982.965486]                                                [<ffffffff8110c11b>] sys_rename+0x1b/0x20
[12982.965486]                                                [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[12982.965486]                                                [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]        INITIAL USE at:
[12982.965486]                                               [<ffffffff8107a6af>] __lock_acquire+0x19f/0x1ae0
[12982.965486]                                               [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                               [<ffffffff8156b7b4>] _spin_lock_nested+0x34/0x70
[12982.965486]                                               [<ffffffff811134b2>] d_move_locked+0x212/0x260
[12982.965486]                                               [<ffffffff81113533>] d_move+0x33/0x50
[12982.965486]                                               [<ffffffff81109e05>] vfs_rename+0x375/0x430
[12982.965486]                                               [<ffffffff8110c0ad>] sys_renameat+0x24d/0x2a0
[12982.965486]                                               [<ffffffff8110c11b>] sys_rename+0x1b/0x20
[12982.965486]                                               [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[12982.965486]                                               [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]      }
[12982.965486]      ... key      at: [<ffffffff822da421>] __key.28050+0x1/0x20
[12982.965486]     ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]    [<ffffffff8156b7b4>] _spin_lock_nested+0x34/0x70
[12982.965486]    [<ffffffff811134b2>] d_move_locked+0x212/0x260
[12982.965486]    [<ffffffff81113533>] d_move+0x33/0x50
[12982.965486]    [<ffffffff81109e05>] vfs_rename+0x375/0x430
[12982.965486]    [<ffffffff8110c0ad>] sys_renameat+0x24d/0x2a0
[12982.965486]    [<ffffffff8110c11b>] sys_rename+0x1b/0x20
[12982.965486]    [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]     -> (sysctl_lock){+.+.-.} ops: 0 {
[12982.965486]        HARDIRQ-ON-W at:
[12982.965486]                                                [<ffffffff8107b035>] __lock_acquire+0xb25/0x1ae0
[12982.965486]                                                [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                                [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]                                                [<ffffffff81054ea2>] __sysctl_head_next+0x32/0x140
[12982.965486]                                                [<ffffffff8106e839>] sysctl_check_lookup+0x49/0x150
[12982.965486]                                                [<ffffffff8106eb08>] sysctl_check_table+0x158/0x750
[12982.965486]                                                [<ffffffff81054a97>] __register_sysctl_paths+0x117/0x360
[12982.965486]                                                [<ffffffff81054d0e>] register_sysctl_paths+0x2e/0x30
[12982.965486]                                                [<ffffffff81054d28>] register_sysctl_table+0x18/0x20
[12982.965486]                                                [<ffffffff8104419d>] register_sched_domain_sysctl+0x45d/0x4d0
[12982.965486]                                                [<ffffffff818ca614>] sched_init_smp+0xd3/0x1d8
[12982.965486]                                                [<ffffffff818b5685>] kernel_init+0x112/0x1a8
[12982.965486]                                                [<ffffffff8100d40a>] child_rip+0xa/0x20
[12982.965486]                                                [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]        SOFTIRQ-ON-W at:
[12982.965486]                                                [<ffffffff8107b061>] __lock_acquire+0xb51/0x1ae0
[12982.965486]                                                [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                                [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]                                                [<ffffffff81054ea2>] __sysctl_head_next+0x32/0x140
[12982.965486]                                                [<ffffffff8106e839>] sysctl_check_lookup+0x49/0x150
[12982.965486]                                                [<ffffffff8106eb08>] sysctl_check_table+0x158/0x750
[12982.965486]                                                [<ffffffff81054a97>] __register_sysctl_paths+0x117/0x360
[12982.965486]                                                [<ffffffff81054d0e>] register_sysctl_paths+0x2e/0x30
[12982.965486]                                                [<ffffffff81054d28>] register_sysctl_table+0x18/0x20
[12982.965486]                                                [<ffffffff8104419d>] register_sched_domain_sysctl+0x45d/0x4d0
[12982.965486]                                                [<ffffffff818ca614>] sched_init_smp+0xd3/0x1d8
[12982.965486]                                                [<ffffffff818b5685>] kernel_init+0x112/0x1a8
[12982.965486]                                                [<ffffffff8100d40a>] child_rip+0xa/0x20
[12982.965486]                                                [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]        IN-RECLAIM_FS-W at:
[12982.965486]                                                   [<ffffffff8107b172>] __lock_acquire+0xc62/0x1ae0
[12982.965486]                                                   [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                                   [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]                                                   [<ffffffff8105480d>] sysctl_head_put+0x1d/0x50
[12982.965486]                                                   [<ffffffff811461e4>] proc_delete_inode+0x44/0x60
[12982.965486]                                                   [<ffffffff811162d3>] generic_delete_inode+0xc3/0x190
[12982.965486]                                                   [<ffffffff8111501d>] iput+0x7d/0x90
[12982.965486]                                                   [<ffffffff81111cb8>] dentry_iput+0x98/0xf0
[12982.965486]                                                   [<ffffffff81111e33>] d_kill+0x33/0x60
[12982.965486]                                                   [<ffffffff81112133>] __shrink_dcache_sb+0x2d3/0x350
[12982.965486]                                                   [<ffffffff8111230a>] shrink_dcache_memory+0x15a/0x1e0
[12982.965486]                                                   [<ffffffff810d5d75>] shrink_slab+0x125/0x180
[12982.965486]                                                   [<ffffffff810d65f0>] kswapd+0x560/0x7a0
[12982.965486]                                                   [<ffffffff8106558b>] kthread+0x5b/0xa0
[12982.965486]                                                   [<ffffffff8100d40a>] child_rip+0xa/0x20
[12982.965486]                                                   [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]        INITIAL USE at:
[12982.965486]                                               [<ffffffff8107a6af>] __lock_acquire+0x19f/0x1ae0
[12982.965486]                                               [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                               [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]                                               [<ffffffff81054ea2>] __sysctl_head_next+0x32/0x140
[12982.965486]                                               [<ffffffff8106e839>] sysctl_check_lookup+0x49/0x150
[12982.965486]                                               [<ffffffff8106eb08>] sysctl_check_table+0x158/0x750
[12982.965486]                                               [<ffffffff81054a97>] __register_sysctl_paths+0x117/0x360
[12982.965486]                                               [<ffffffff81054d0e>] register_sysctl_paths+0x2e/0x30
[12982.965486]                                               [<ffffffff81054d28>] register_sysctl_table+0x18/0x20
[12982.965486]                                               [<ffffffff8104419d>] register_sched_domain_sysctl+0x45d/0x4d0
[12982.965486]                                               [<ffffffff818ca614>] sched_init_smp+0xd3/0x1d8
[12982.965486]                                               [<ffffffff818b5685>] kernel_init+0x112/0x1a8
[12982.965486]                                               [<ffffffff8100d40a>] child_rip+0xa/0x20
[12982.965486]                                               [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]      }
[12982.965486]      ... key      at: [<ffffffff817e5cb8>] sysctl_lock+0x18/0x40
[12982.965486]     ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]    [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]    [<ffffffff810546df>] sysctl_is_seen+0x2f/0x80
[12982.965486]    [<ffffffff8114f09e>] proc_sys_compare+0x3e/0x50
[12982.965486]    [<ffffffff8111394d>] __d_lookup+0x17d/0x1d0
[12982.965486]    [<ffffffff81108a22>] __lookup_hash+0x62/0x1a0
[12982.965486]    [<ffffffff81108b9a>] lookup_hash+0x3a/0x50
[12982.965486]    [<ffffffff8110cfcc>] do_filp_open+0x2fc/0xa20
[12982.965486]    [<ffffffff810fbe68>] do_sys_open+0x98/0x140
[12982.965486]    [<ffffffff810fbf50>] sys_open+0x20/0x30
[12982.965486]    [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]    ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]    [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]    [<ffffffff81133a2a>] inotify_d_instantiate+0x2a/0x60
[12982.965486]    [<ffffffff81112f15>] __d_instantiate+0x45/0x50
[12982.965486]    [<ffffffff81112f7a>] d_instantiate+0x5a/0x80
[12982.965486]    [<ffffffff81113f34>] d_alloc_root+0x54/0x70
[12982.965486]    [<ffffffff811558e2>] sysfs_fill_super+0x72/0xd0
[12982.965486]    [<ffffffff811018ea>] get_sb_single+0xca/0x100
[12982.965486]    [<ffffffff8115586b>] sysfs_get_sb+0x1b/0x20
[12982.965486]    [<ffffffff811003f0>] vfs_kern_mount+0x50/0xd0
[12982.965486]    [<ffffffff81100489>] kern_mount_data+0x19/0x20
[12982.965486]    [<ffffffff818d38d4>] sysfs_init+0x7f/0xd4
[12982.965486]    [<ffffffff818d20d4>] mnt_init+0x9d/0x21e
[12982.965486]    [<ffffffff818d1c24>] vfs_caches_init+0xa8/0x140
[12982.965486]    [<ffffffff818b5d0f>] start_kernel+0x34c/0x44f
[12982.965486]    [<ffffffff818b5299>] x86_64_start_reservations+0x99/0xb9
[12982.965486]    [<ffffffff818b53b0>] x86_64_start_kernel+0xf7/0x122
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]    -> (vfsmount_lock){+.+...} ops: 0 {
[12982.965486]       HARDIRQ-ON-W at:
[12982.965486]                                              [<ffffffff8107b035>] __lock_acquire+0xb25/0x1ae0
[12982.965486]                                              [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                              [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]                                              [<ffffffff8111b0ad>] alloc_vfsmnt+0x5d/0x180
[12982.965486]                                              [<ffffffff811003d6>] vfs_kern_mount+0x36/0xd0
[12982.965486]                                              [<ffffffff81100489>] kern_mount_data+0x19/0x20
[12982.965486]                                              [<ffffffff818d38d4>] sysfs_init+0x7f/0xd4
[12982.965486]                                              [<ffffffff818d20d4>] mnt_init+0x9d/0x21e
[12982.965486]                                              [<ffffffff818d1c24>] vfs_caches_init+0xa8/0x140
[12982.965486]                                              [<ffffffff818b5d0f>] start_kernel+0x34c/0x44f
[12982.965486]                                              [<ffffffff818b5299>] x86_64_start_reservations+0x99/0xb9
[12982.965486]                                              [<ffffffff818b53b0>] x86_64_start_kernel+0xf7/0x122
[12982.965486]                                              [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]       SOFTIRQ-ON-W at:
[12982.965486]                                              [<ffffffff8107b061>] __lock_acquire+0xb51/0x1ae0
[12982.965486]                                              [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                              [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]                                              [<ffffffff8111b0ad>] alloc_vfsmnt+0x5d/0x180
[12982.965486]                                              [<ffffffff811003d6>] vfs_kern_mount+0x36/0xd0
[12982.965486]                                              [<ffffffff81100489>] kern_mount_data+0x19/0x20
[12982.965486]                                              [<ffffffff818d38d4>] sysfs_init+0x7f/0xd4
[12982.965486]                                              [<ffffffff818d20d4>] mnt_init+0x9d/0x21e
[12982.965486]                                              [<ffffffff818d1c24>] vfs_caches_init+0xa8/0x140
[12982.965486]                                              [<ffffffff818b5d0f>] start_kernel+0x34c/0x44f
[12982.965486]                                              [<ffffffff818b5299>] x86_64_start_reservations+0x99/0xb9
[12982.965486]                                              [<ffffffff818b53b0>] x86_64_start_kernel+0xf7/0x122
[12982.965486]                                              [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]       INITIAL USE at:
[12982.965486]                                             [<ffffffff8107a6af>] __lock_acquire+0x19f/0x1ae0
[12982.965486]                                             [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                             [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]                                             [<ffffffff8111b0ad>] alloc_vfsmnt+0x5d/0x180
[12982.965486]                                             [<ffffffff811003d6>] vfs_kern_mount+0x36/0xd0
[12982.965486]                                             [<ffffffff81100489>] kern_mount_data+0x19/0x20
[12982.965486]                                             [<ffffffff818d38d4>] sysfs_init+0x7f/0xd4
[12982.965486]                                             [<ffffffff818d20d4>] mnt_init+0x9d/0x21e
[12982.965486]                                             [<ffffffff818d1c24>] vfs_caches_init+0xa8/0x140
[12982.965486]                                             [<ffffffff818b5d0f>] start_kernel+0x34c/0x44f
[12982.965486]                                             [<ffffffff818b5299>] x86_64_start_reservations+0x99/0xb9
[12982.965486]                                             [<ffffffff818b53b0>] x86_64_start_kernel+0xf7/0x122
[12982.965486]                                             [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]     }
[12982.965486]     ... key      at: [<ffffffff818a3898>] vfsmount_lock+0x18/0x40
[12982.965486]     -> (mnt_id_ida.lock){......} ops: 0 {
[12982.965486]        INITIAL USE at:
[12982.965486]                                               [<ffffffff8107a6af>] __lock_acquire+0x19f/0x1ae0
[12982.965486]                                               [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                               [<ffffffff8156b9a6>] _spin_lock_irqsave+0x56/0xa0
[12982.965486]                                               [<ffffffff812789a0>] idr_pre_get+0x30/0x90
[12982.965486]                                               [<ffffffff81278a1c>] ida_pre_get+0x1c/0x80
[12982.965486]                                               [<ffffffff8111b0a1>] alloc_vfsmnt+0x51/0x180
[12982.965486]                                               [<ffffffff811003d6>] vfs_kern_mount+0x36/0xd0
[12982.965486]                                               [<ffffffff81100489>] kern_mount_data+0x19/0x20
[12982.965486]                                               [<ffffffff818d38d4>] sysfs_init+0x7f/0xd4
[12982.965486]                                               [<ffffffff818d20d4>] mnt_init+0x9d/0x21e
[12982.965486]                                               [<ffffffff818d1c24>] vfs_caches_init+0xa8/0x140
[12982.965486]                                               [<ffffffff818b5d0f>] start_kernel+0x34c/0x44f
[12982.965486]                                               [<ffffffff818b5299>] x86_64_start_reservations+0x99/0xb9
[12982.965486]                                               [<ffffffff818b53b0>] x86_64_start_kernel+0xf7/0x122
[12982.965486]                                               [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]      }
[12982.965486]      ... key      at: [<ffffffff817f1b90>] mnt_id_ida+0x30/0x60
[12982.965486]     ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]    [<ffffffff8156b9a6>] _spin_lock_irqsave+0x56/0xa0
[12982.965486]    [<ffffffff81277c63>] get_from_free_list+0x23/0x60
[12982.965486]    [<ffffffff812781ad>] idr_get_empty_slot+0x2bd/0x2e0
[12982.965486]    [<ffffffff8127828e>] ida_get_new_above+0xbe/0x210
[12982.965486]    [<ffffffff812783ee>] ida_get_new+0xe/0x10
[12982.965486]    [<ffffffff8111b0bc>] alloc_vfsmnt+0x6c/0x180
[12982.965486]    [<ffffffff811003d6>] vfs_kern_mount+0x36/0xd0
[12982.965486]    [<ffffffff81100489>] kern_mount_data+0x19/0x20
[12982.965486]    [<ffffffff818d38d4>] sysfs_init+0x7f/0xd4
[12982.965486]    [<ffffffff818d20d4>] mnt_init+0x9d/0x21e
[12982.965486]    [<ffffffff818d1c24>] vfs_caches_init+0xa8/0x140
[12982.965486]    [<ffffffff818b5d0f>] start_kernel+0x34c/0x44f
[12982.965486]    [<ffffffff818b5299>] x86_64_start_reservations+0x99/0xb9
[12982.965486]    [<ffffffff818b53b0>] x86_64_start_kernel+0xf7/0x122
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]     ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]    [<ffffffff8156b9a6>] _spin_lock_irqsave+0x56/0xa0
[12982.965486]    [<ffffffff810f9a21>] slob_free+0xa1/0x370
[12982.965486]    [<ffffffff810f9d25>] __kmem_cache_free+0x35/0x40
[12982.965486]    [<ffffffff810f9dfc>] kmem_cache_free+0xcc/0xd0
[12982.965486]    [<ffffffff81278311>] ida_get_new_above+0x141/0x210
[12982.965486]    [<ffffffff812783ee>] ida_get_new+0xe/0x10
[12982.965486]    [<ffffffff8111b0bc>] alloc_vfsmnt+0x6c/0x180
[12982.965486]    [<ffffffff811003d6>] vfs_kern_mount+0x36/0xd0
[12982.965486]    [<ffffffff81100489>] kern_mount_data+0x19/0x20
[12982.965486]    [<ffffffff818d38d4>] sysfs_init+0x7f/0xd4
[12982.965486]    [<ffffffff818d20d4>] mnt_init+0x9d/0x21e
[12982.965486]    [<ffffffff818d1c24>] vfs_caches_init+0xa8/0x140
[12982.965486]    [<ffffffff818b5d0f>] start_kernel+0x34c/0x44f
[12982.965486]    [<ffffffff818b5299>] x86_64_start_reservations+0x99/0xb9
[12982.965486]    [<ffffffff818b53b0>] x86_64_start_kernel+0xf7/0x122
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]     -> (&q->lock){-.-.-.} ops: 0 {
[12982.965486]        IN-HARDIRQ-W at:
[12982.965486]                                                [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]        IN-SOFTIRQ-W at:
[12982.965486]                                                [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]        IN-RECLAIM_FS-W at:
[12982.965486]                                                   [<ffffffff8107b172>] __lock_acquire+0xc62/0x1ae0
[12982.965486]                                                   [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                                   [<ffffffff8156b9a6>] _spin_lock_irqsave+0x56/0xa0
[12982.965486]                                                   [<ffffffff81065d61>] prepare_to_wait+0x31/0x90
[12982.965486]                                                   [<ffffffff810d6190>] kswapd+0x100/0x7a0
[12982.965486]                                                   [<ffffffff8106558b>] kthread+0x5b/0xa0
[12982.965486]                                                   [<ffffffff8100d40a>] child_rip+0xa/0x20
[12982.965486]                                                   [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]        INITIAL USE at:
[12982.965486]                                               [<ffffffff8107a6af>] __lock_acquire+0x19f/0x1ae0
[12982.965486]                                               [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                               [<ffffffff8156b913>] _spin_lock_irq+0x43/0x80
[12982.965486]                                               [<ffffffff8156825b>] wait_for_common+0x4b/0x1d0
[12982.965486]                                               [<ffffffff8156849d>] wait_for_completion+0x1d/0x20
[12982.965486]                                               [<ffffffff8106584f>] kthread_create+0xaf/0x180
[12982.965486]                                               [<ffffffff81564129>] migration_call+0x1a6/0x5d2
[12982.965486]                                               [<ffffffff818ca080>] migration_init+0x2e/0x7f
[12982.965486]                                               [<ffffffff8100904f>] do_one_initcall+0x3f/0x1d0
[12982.965486]                                               [<ffffffff818b55e0>] kernel_init+0x6d/0x1a8
[12982.965486]                                               [<ffffffff8100d40a>] child_rip+0xa/0x20
[12982.965486]                                               [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]      }
[12982.965486]      ... key      at: [<ffffffff81b54dc8>] __key.19115+0x0/0x18
[12982.965486]      -> (&rq->lock){-.-.-.} ops: 0 {
[12982.965486]         IN-HARDIRQ-W at:
[12982.965486]                                                  [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]         IN-SOFTIRQ-W at:
[12982.965486]                                                  [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]         IN-RECLAIM_FS-W at:
[12982.965486]                                                     [<ffffffff8107b172>] __lock_acquire+0xc62/0x1ae0
[12982.965486]                                                     [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                                     [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]                                                     [<ffffffff8103a3c3>] task_rq_lock+0x63/0xc0
[12982.965486]                                                     [<ffffffff81045c29>] set_cpus_allowed_ptr+0x39/0x160
[12982.965486]                                                     [<ffffffff810d610f>] kswapd+0x7f/0x7a0
[12982.965486]                                                     [<ffffffff8106558b>] kthread+0x5b/0xa0
[12982.965486]                                                     [<ffffffff8100d40a>] child_rip+0xa/0x20
[12982.965486]                                                     [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]         INITIAL USE at:
[12982.965486]                                                 [<ffffffff8107a6af>] __lock_acquire+0x19f/0x1ae0
[12982.965486]                                                 [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                                 [<ffffffff8156b9a6>] _spin_lock_irqsave+0x56/0xa0
[12982.965486]                                                 [<ffffffff8104210b>] rq_attach_root+0x2b/0x110
[12982.965486]                                                 [<ffffffff818ca437>] sched_init+0x2bb/0x3c5
[12982.965486]                                                 [<ffffffff818b5b43>] start_kernel+0x180/0x44f
[12982.965486]                                                 [<ffffffff818b5299>] x86_64_start_reservations+0x99/0xb9
[12982.965486]                                                 [<ffffffff818b53b0>] x86_64_start_kernel+0xf7/0x122
[12982.965486]                                                 [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]       }
[12982.965486]       ... key      at: [<ffffffff81b0f858>] __key.48846+0x0/0x8
[12982.965486]       -> (&vec->lock){-.-.-.} ops: 0 {
[12982.965486]          IN-HARDIRQ-W at:
[12982.965486]                                                    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]          IN-SOFTIRQ-W at:
[12982.965486]                                                    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]          IN-RECLAIM_FS-W at:
[12982.965486]                                                       [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]          INITIAL USE at:
[12982.965486]                                                   [<ffffffff8107a6af>] __lock_acquire+0x19f/0x1ae0
[12982.965486]                                                   [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                                   [<ffffffff8156b9a6>] _spin_lock_irqsave+0x56/0xa0
[12982.965486]                                                   [<ffffffff810c38e2>] cpupri_set+0x102/0x1a0
[12982.965486]                                                   [<ffffffff8103e839>] rq_online_rt+0x49/0x80
[12982.965486]                                                   [<ffffffff8103826e>] set_rq_online+0x5e/0x80
[12982.965486]                                                   [<ffffffff810421c8>] rq_attach_root+0xe8/0x110
[12982.965486]                                                   [<ffffffff818ca437>] sched_init+0x2bb/0x3c5
[12982.965486]                                                   [<ffffffff818b5b43>] start_kernel+0x180/0x44f
[12982.965486]                                                   [<ffffffff818b5299>] x86_64_start_reservations+0x99/0xb9
[12982.965486]                                                   [<ffffffff818b53b0>] x86_64_start_kernel+0xf7/0x122
[12982.965486]                                                   [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]        }
[12982.965486]        ... key      at: [<ffffffff822d7338>] __key.15844+0x0/0x8
[12982.965486]       ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]    [<ffffffff8156b9a6>] _spin_lock_irqsave+0x56/0xa0
[12982.965486]    [<ffffffff810c38e2>] cpupri_set+0x102/0x1a0
[12982.965486]    [<ffffffff8103e839>] rq_online_rt+0x49/0x80
[12982.965486]    [<ffffffff8103826e>] set_rq_online+0x5e/0x80
[12982.965486]    [<ffffffff810421c8>] rq_attach_root+0xe8/0x110
[12982.965486]    [<ffffffff818ca437>] sched_init+0x2bb/0x3c5
[12982.965486]    [<ffffffff818b5b43>] start_kernel+0x180/0x44f
[12982.965486]    [<ffffffff818b5299>] x86_64_start_reservations+0x99/0xb9
[12982.965486]    [<ffffffff818b53b0>] x86_64_start_kernel+0xf7/0x122
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]       -> (&rt_b->rt_runtime_lock){-.-.-.} ops: 0 {
[12982.965486]          IN-HARDIRQ-W at:
[12982.965486]                                                    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]          IN-SOFTIRQ-W at:
[12982.965486]                                                    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]          IN-RECLAIM_FS-W at:
[12982.965486]                                                       [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]          INITIAL USE at:
[12982.965486]                                                   [<ffffffff8107a6af>] __lock_acquire+0x19f/0x1ae0
[12982.965486]                                                   [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                                   [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]                                                   [<ffffffff8103f294>] enqueue_task_rt+0x254/0x300
[12982.965486]                                                   [<ffffffff810391f6>] enqueue_task+0x86/0xa0
[12982.965486]                                                   [<ffffffff8103923d>] activate_task+0x2d/0x40
[12982.965486]                                                   [<ffffffff81040610>] try_to_wake_up+0x1b0/0x320
[12982.965486]                                                   [<ffffffff810407d5>] wake_up_process+0x15/0x20
[12982.965486]                                                   [<ffffffff81563fe0>] migration_call+0x5d/0x5d2
[12982.965486]                                                   [<ffffffff818ca0b7>] migration_init+0x65/0x7f
[12982.965486]                                                   [<ffffffff8100904f>] do_one_initcall+0x3f/0x1d0
[12982.965486]                                                   [<ffffffff818b55e0>] kernel_init+0x6d/0x1a8
[12982.965486]                                                   [<ffffffff8100d40a>] child_rip+0xa/0x20
[12982.965486]                                                   [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]        }
[12982.965486]        ... key      at: [<ffffffff81b0f860>] __key.39068+0x0/0x8
[12982.965486]        -> (&cpu_base->lock){-.-.-.} ops: 0 {
[12982.965486]           IN-HARDIRQ-W at:
[12982.965486]                                                      [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]           IN-SOFTIRQ-W at:
[12982.965486]                                                      [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]           IN-RECLAIM_FS-W at:
[12982.965486]                                                         [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]           INITIAL USE at:
[12982.965486]                                                     [<ffffffff8107a6af>] __lock_acquire+0x19f/0x1ae0
[12982.965486]                                                     [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                                     [<ffffffff8156b9a6>] _spin_lock_irqsave+0x56/0xa0
[12982.965486]                                                     [<ffffffff8106984c>] lock_hrtimer_base+0x5c/0x90
[12982.965486]                                                     [<ffffffff81069ac3>] __hrtimer_start_range_ns+0x43/0x340
[12982.965486]                                                     [<ffffffff8103f2e2>] enqueue_task_rt+0x2a2/0x300
[12982.965486]                                                     [<ffffffff810391f6>] enqueue_task+0x86/0xa0
[12982.965486]                                                     [<ffffffff8103923d>] activate_task+0x2d/0x40
[12982.965486]                                                     [<ffffffff81040610>] try_to_wake_up+0x1b0/0x320
[12982.965486]                                                     [<ffffffff810407d5>] wake_up_process+0x15/0x20
[12982.965486]                                                     [<ffffffff81563fe0>] migration_call+0x5d/0x5d2
[12982.965486]                                                     [<ffffffff818ca0b7>] migration_init+0x65/0x7f
[12982.965486]                                                     [<ffffffff8100904f>] do_one_initcall+0x3f/0x1d0
[12982.965486]                                                     [<ffffffff818b55e0>] kernel_init+0x6d/0x1a8
[12982.965486]                                                     [<ffffffff8100d40a>] child_rip+0xa/0x20
[12982.965486]                                                     [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]         }
[12982.965486]         ... key      at: [<ffffffff81b54e10>] __key.21319+0x0/0x8
[12982.965486]         -> (&obj_hash[i].lock){-.-.-.} ops: 0 {
[12982.965486]            IN-HARDIRQ-W at:
[12982.965486]                                                        [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]            IN-SOFTIRQ-W at:
[12982.965486]                                                        [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]            IN-RECLAIM_FS-W at:
[12982.965486]                                                           [<ffffffff8107b172>] __lock_acquire+0xc62/0x1ae0
[12982.965486]                                                           [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                                           [<ffffffff8156b9a6>] _spin_lock_irqsave+0x56/0xa0
[12982.965486]                                                           [<ffffffff812870ee>] debug_check_no_obj_freed+0x8e/0x200
[12982.965486]                                                           [<ffffffff810ccabc>] free_hot_cold_page+0x14c/0x350
[12982.965486]                                                           [<ffffffff810ccd01>] __pagevec_free+0x41/0x60
[12982.965486]                                                           [<ffffffff810d48d5>] shrink_page_list+0x615/0xa70
[12982.965486]                                                           [<ffffffff810d54be>] shrink_list+0x2be/0x660
[12982.965486]                                                           [<ffffffff810d5a51>] shrink_zone+0x1f1/0x3f0
[12982.965486]                                                           [<ffffffff810d67b9>] kswapd+0x729/0x7a0
[12982.965486]                                                           [<ffffffff8106558b>] kthread+0x5b/0xa0
[12982.965486]                                                           [<ffffffff8100d40a>] child_rip+0xa/0x20
[12982.965486]                                                           [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]            INITIAL USE at:
[12982.965486]                                                       [<ffffffff8107a6af>] __lock_acquire+0x19f/0x1ae0
[12982.965486]                                                       [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                                       [<ffffffff8156b9a6>] _spin_lock_irqsave+0x56/0xa0
[12982.965486]                                                       [<ffffffff812873fc>] __debug_object_init+0x5c/0x410
[12982.965486]                                                       [<ffffffff812877ff>] debug_object_init+0x1f/0x30
[12982.965486]                                                       [<ffffffff810696de>] hrtimer_init+0x2e/0x50
[12982.965486]                                                       [<ffffffff818ca227>] sched_init+0xab/0x3c5
[12982.965486]                                                       [<ffffffff818b5b43>] start_kernel+0x180/0x44f
[12982.965486]                                                       [<ffffffff818b5299>] x86_64_start_reservations+0x99/0xb9
[12982.965486]                                                       [<ffffffff818b53b0>] x86_64_start_kernel+0xf7/0x122
[12982.965486]                                                       [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]          }
[12982.965486]          ... key      at: [<ffffffff822e7088>] __key.20519+0x0/0x8
[12982.965486]          -> (pool_lock){..-.-.} ops: 0 {
[12982.965486]             IN-SOFTIRQ-W at:
[12982.965486]                                                          [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]             IN-RECLAIM_FS-W at:
[12982.965486]                                                             [<ffffffff8107b172>] __lock_acquire+0xc62/0x1ae0
[12982.965486]                                                             [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                                             [<ffffffff8156b9a6>] _spin_lock_irqsave+0x56/0xa0
[12982.965486]                                                             [<ffffffff81286fd6>] free_object+0x16/0xa0
[12982.965486]                                                             [<ffffffff81287226>] debug_check_no_obj_freed+0x1c6/0x200
[12982.965486]                                                             [<ffffffff810ccabc>] free_hot_cold_page+0x14c/0x350
[12982.965486]                                                             [<ffffffff810ccd50>] free_hot_page+0x10/0x20
[12982.965486]                                                             [<ffffffff810ccdd2>] __free_pages+0x72/0x80
[12982.965486]                                                             [<ffffffff810cce5b>] free_pages+0x7b/0x80
[12982.965486]                                                             [<ffffffff810f9ad5>] slob_free+0x155/0x370
[12982.965486]                                                             [<ffffffff810f9d25>] __kmem_cache_free+0x35/0x40
[12982.965486]                                                             [<ffffffff810f9dfc>] kmem_cache_free+0xcc/0xd0
[12982.965486]                                                             [<ffffffff81145909>] proc_destroy_inode+0x19/0x20
[12982.965486]                                                             [<ffffffff81115c5d>] destroy_inode+0x4d/0x70
[12982.965486]                                                             [<ffffffff81116359>] generic_delete_inode+0x149/0x190
[12982.965486]                                                             [<ffffffff8111501d>] iput+0x7d/0x90
[12982.965486]                                                             [<ffffffff81111cb8>] dentry_iput+0x98/0xf0
[12982.965486]                                                             [<ffffffff81111e33>] d_kill+0x33/0x60
[12982.965486]                                                             [<ffffffff81112133>] __shrink_dcache_sb+0x2d3/0x350
[12982.965486]                                                             [<ffffffff8111230a>] shrink_dcache_memory+0x15a/0x1e0
[12982.965486]                                                             [<ffffffff810d5d75>] shrink_slab+0x125/0x180
[12982.965486]                                                             [<ffffffff810d65f0>] kswapd+0x560/0x7a0
[12982.965486]                                                             [<ffffffff8106558b>] kthread+0x5b/0xa0
[12982.965486]                                                             [<ffffffff8100d40a>] child_rip+0xa/0x20
[12982.965486]                                                             [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]             INITIAL USE at:
[12982.965486]                                                         [<ffffffff8107a6af>] __lock_acquire+0x19f/0x1ae0
[12982.965486]                                                         [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                                         [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]                                                         [<ffffffff8128748a>] __debug_object_init+0xea/0x410
[12982.965486]                                                         [<ffffffff812877ff>] debug_object_init+0x1f/0x30
[12982.965486]                                                         [<ffffffff810696de>] hrtimer_init+0x2e/0x50
[12982.965486]                                                         [<ffffffff818ca227>] sched_init+0xab/0x3c5
[12982.965486]                                                         [<ffffffff818b5b43>] start_kernel+0x180/0x44f
[12982.965486]                                                         [<ffffffff818b5299>] x86_64_start_reservations+0x99/0xb9
[12982.965486]                                                         [<ffffffff818b53b0>] x86_64_start_kernel+0xf7/0x122
[12982.965486]                                                         [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]           }
[12982.965486]           ... key      at: [<ffffffff81806678>] pool_lock+0x18/0x40
[12982.965486]          ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]    [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]    [<ffffffff8128748a>] __debug_object_init+0xea/0x410
[12982.965486]    [<ffffffff812877ff>] debug_object_init+0x1f/0x30
[12982.965486]    [<ffffffff810696de>] hrtimer_init+0x2e/0x50
[12982.965486]    [<ffffffff818ca227>] sched_init+0xab/0x3c5
[12982.965486]    [<ffffffff818b5b43>] start_kernel+0x180/0x44f
[12982.965486]    [<ffffffff818b5299>] x86_64_start_reservations+0x99/0xb9
[12982.965486]    [<ffffffff818b53b0>] x86_64_start_kernel+0xf7/0x122
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]         ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]    [<ffffffff8156b9a6>] _spin_lock_irqsave+0x56/0xa0
[12982.965486]    [<ffffffff81286eac>] debug_object_activate+0x5c/0x170
[12982.965486]    [<ffffffff81068e75>] enqueue_hrtimer+0x35/0xb0
[12982.965486]    [<ffffffff81069b6d>] __hrtimer_start_range_ns+0xed/0x340
[12982.965486]    [<ffffffff8103f2e2>] enqueue_task_rt+0x2a2/0x300
[12982.965486]    [<ffffffff810391f6>] enqueue_task+0x86/0xa0
[12982.965486]    [<ffffffff8103923d>] activate_task+0x2d/0x40
[12982.965486]    [<ffffffff81040610>] try_to_wake_up+0x1b0/0x320
[12982.965486]    [<ffffffff810407d5>] wake_up_process+0x15/0x20
[12982.965486]    [<ffffffff81563fe0>] migration_call+0x5d/0x5d2
[12982.965486]    [<ffffffff818ca0b7>] migration_init+0x65/0x7f
[12982.965486]    [<ffffffff8100904f>] do_one_initcall+0x3f/0x1d0
[12982.965486]    [<ffffffff818b55e0>] kernel_init+0x6d/0x1a8
[12982.965486]    [<ffffffff8100d40a>] child_rip+0xa/0x20
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]        ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]    [<ffffffff8156b9a6>] _spin_lock_irqsave+0x56/0xa0
[12982.965486]    [<ffffffff8106984c>] lock_hrtimer_base+0x5c/0x90
[12982.965486]    [<ffffffff81069ac3>] __hrtimer_start_range_ns+0x43/0x340
[12982.965486]    [<ffffffff8103f2e2>] enqueue_task_rt+0x2a2/0x300
[12982.965486]    [<ffffffff810391f6>] enqueue_task+0x86/0xa0
[12982.965486]    [<ffffffff8103923d>] activate_task+0x2d/0x40
[12982.965486]    [<ffffffff81040610>] try_to_wake_up+0x1b0/0x320
[12982.965486]    [<ffffffff810407d5>] wake_up_process+0x15/0x20
[12982.965486]    [<ffffffff81563fe0>] migration_call+0x5d/0x5d2
[12982.965486]    [<ffffffff818ca0b7>] migration_init+0x65/0x7f
[12982.965486]    [<ffffffff8100904f>] do_one_initcall+0x3f/0x1d0
[12982.965486]    [<ffffffff818b55e0>] kernel_init+0x6d/0x1a8
[12982.965486]    [<ffffffff8100d40a>] child_rip+0xa/0x20
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]        -> (&rt_rq->rt_runtime_lock){-.-...} ops: 0 {
[12982.965486]           IN-HARDIRQ-W at:
[12982.965486]                                                      [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]           IN-SOFTIRQ-W at:
[12982.965486]                                                      [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]           INITIAL USE at:
[12982.965486]                                                     [<ffffffff8107a6af>] __lock_acquire+0x19f/0x1ae0
[12982.965486]                                                     [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                                     [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]                                                     [<ffffffff8103acaf>] update_curr_rt+0x12f/0x1e0
[12982.965486]                                                     [<ffffffff8103eb84>] dequeue_task_rt+0x24/0x90
[12982.965486]                                                     [<ffffffff81039a4a>] dequeue_task+0xea/0x140
[12982.965486]                                                     [<ffffffff81039acd>] deactivate_task+0x2d/0x40
[12982.965486]                                                     [<ffffffff81567463>] __schedule+0x243/0x8ce
[12982.965486]                                                     [<ffffffff81568015>] schedule+0x15/0x50
[12982.965486]                                                     [<ffffffff8104598c>] migration_thread+0x1cc/0x2f0
[12982.965486]                                                     [<ffffffff8106558b>] kthread+0x5b/0xa0
[12982.965486]                                                     [<ffffffff8100d40a>] child_rip+0xa/0x20
[12982.965486]                                                     [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]         }
[12982.965486]         ... key      at: [<ffffffff81b0f868>] __key.48826+0x0/0x8
[12982.965486]        ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]    [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]    [<ffffffff8103afa4>] __enable_runtime+0x54/0xa0
[12982.965486]    [<ffffffff8103e81d>] rq_online_rt+0x2d/0x80
[12982.965486]    [<ffffffff8103826e>] set_rq_online+0x5e/0x80
[12982.965486]    [<ffffffff8156446a>] migration_call+0x4e7/0x5d2
[12982.965486]    [<ffffffff8156ed4f>] notifier_call_chain+0x3f/0x80
[12982.965486]    [<ffffffff8106b356>] raw_notifier_call_chain+0x16/0x20
[12982.965486]    [<ffffffff81564906>] _cpu_up+0x146/0x14b
[12982.965486]    [<ffffffff81564987>] cpu_up+0x7c/0x95
[12982.965486]    [<ffffffff818b5658>] kernel_init+0xe5/0x1a8
[12982.965486]    [<ffffffff8100d40a>] child_rip+0xa/0x20
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]       ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]    [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]    [<ffffffff8103f294>] enqueue_task_rt+0x254/0x300
[12982.965486]    [<ffffffff810391f6>] enqueue_task+0x86/0xa0
[12982.965486]    [<ffffffff8103923d>] activate_task+0x2d/0x40
[12982.965486]    [<ffffffff81040610>] try_to_wake_up+0x1b0/0x320
[12982.965486]    [<ffffffff810407d5>] wake_up_process+0x15/0x20
[12982.965486]    [<ffffffff81563fe0>] migration_call+0x5d/0x5d2
[12982.965486]    [<ffffffff818ca0b7>] migration_init+0x65/0x7f
[12982.965486]    [<ffffffff8100904f>] do_one_initcall+0x3f/0x1d0
[12982.965486]    [<ffffffff818b55e0>] kernel_init+0x6d/0x1a8
[12982.965486]    [<ffffffff8100d40a>] child_rip+0xa/0x20
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]       ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]    [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]    [<ffffffff8103acaf>] update_curr_rt+0x12f/0x1e0
[12982.965486]    [<ffffffff8103eb84>] dequeue_task_rt+0x24/0x90
[12982.965486]    [<ffffffff81039a4a>] dequeue_task+0xea/0x140
[12982.965486]    [<ffffffff81039acd>] deactivate_task+0x2d/0x40
[12982.965486]    [<ffffffff81567463>] __schedule+0x243/0x8ce
[12982.965486]    [<ffffffff81568015>] schedule+0x15/0x50
[12982.965486]    [<ffffffff8104598c>] migration_thread+0x1cc/0x2f0
[12982.965486]    [<ffffffff8106558b>] kthread+0x5b/0xa0
[12982.965486]    [<ffffffff8100d40a>] child_rip+0xa/0x20
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]       -> (&rq->lock/1){..-.-.} ops: 0 {
[12982.965486]          IN-SOFTIRQ-W at:
[12982.965486]                                                    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]          IN-RECLAIM_FS-W at:
[12982.965486]                                                       [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]          INITIAL USE at:
[12982.965486]                                                   [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]        }
[12982.965486]        ... key      at: [<ffffffff81b0f859>] __key.48846+0x1/0x8
[12982.965486]        -> (&sig->cputimer.lock){-.-...} ops: 0 {
[12982.965486]           IN-HARDIRQ-W at:
[12982.965486]                                                      [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]           IN-SOFTIRQ-W at:
[12982.965486]                                                      [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]           INITIAL USE at:
[12982.965486]                                                     [<ffffffff8107a6af>] __lock_acquire+0x19f/0x1ae0
[12982.965486]                                                     [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                                     [<ffffffff8156b9a6>] _spin_lock_irqsave+0x56/0xa0
[12982.965486]                                                     [<ffffffff81066ead>] thread_group_cputimer+0x3d/0xf0
[12982.965486]                                                     [<ffffffff8106886a>] posix_cpu_timers_exit_group+0x1a/0x40
[12982.965486]                                                     [<ffffffff8104df10>] release_task+0x450/0x500
[12982.965486]                                                     [<ffffffff8104f832>] do_exit+0x6d2/0x9b0
[12982.965486]                                                     [<ffffffff8105fc9b>] ____call_usermodehelper+0x16b/0x170
[12982.965486]                                                     [<ffffffff8100d40a>] child_rip+0xa/0x20
[12982.965486]                                                     [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]         }
[12982.965486]         ... key      at: [<ffffffff81b11a04>] __key.16763+0x0/0x8
[12982.965486]        ... acquired at:
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]       ... acquired at:
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]       ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]    [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]    [<ffffffff8103a572>] update_curr+0x152/0x1a0
[12982.965486]    [<ffffffff8103c1e2>] dequeue_task_fair+0x52/0x290
[12982.965486]    [<ffffffff81039a4a>] dequeue_task+0xea/0x140
[12982.965486]    [<ffffffff81039acd>] deactivate_task+0x2d/0x40
[12982.965486]    [<ffffffff81567463>] __schedule+0x243/0x8ce
[12982.965486]    [<ffffffff81568015>] schedule+0x15/0x50
[12982.965486]    [<ffffffff814fea78>] rpc_wait_bit_killable+0x48/0x80
[12982.965486]    [<ffffffff81568912>] __wait_on_bit+0x62/0x90
[12982.965486]    [<ffffffff815689b9>] out_of_line_wait_on_bit+0x79/0x90
[12982.965486]    [<ffffffff814ff5d5>] __rpc_execute+0x285/0x340
[12982.965486]    [<ffffffff814ff6bd>] rpc_execute+0x2d/0x40
[12982.965486]    [<ffffffff814f73e0>] rpc_run_task+0x40/0x80
[12982.965486]    [<ffffffff814f7574>] rpc_call_sync+0x64/0xb0
[12982.965486]    [<ffffffff811ca3fe>] nfs3_rpc_wrapper+0x2e/0x90
[12982.965486]    [<ffffffff811caae3>] nfs3_proc_access+0xf3/0x1e0
[12982.965486]    [<ffffffff811b7efe>] nfs_do_access+0x11e/0x370
[12982.965486]    [<ffffffff811b82fe>] nfs_permission+0x1ae/0x220
[12982.965486]    [<ffffffff81108280>] inode_permission+0x60/0xa0
[12982.965486]    [<ffffffff8110a64f>] __link_path_walk+0x8f/0x1090
[12982.965486]    [<ffffffff8110b87c>] path_walk+0x5c/0xb0
[12982.965486]    [<ffffffff8110ba76>] do_path_lookup+0x96/0x270
[12982.965486]    [<ffffffff8110bd3a>] path_lookup_open+0x6a/0xe0
[12982.965486]    [<ffffffff8110cd9f>] do_filp_open+0xcf/0xa20
[12982.965486]    [<ffffffff810fbe68>] do_sys_open+0x98/0x140
[12982.965486]    [<ffffffff810fbf50>] sys_open+0x20/0x30
[12982.965486]    [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]      ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]    [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]    [<ffffffff8103a3c3>] task_rq_lock+0x63/0xc0
[12982.965486]    [<ffffffff810404a5>] try_to_wake_up+0x45/0x320
[12982.965486]    [<ffffffff81040792>] default_wake_function+0x12/0x20
[12982.965486]    [<ffffffff81037daa>] __wake_up_common+0x5a/0x90
[12982.965486]    [<ffffffff8103a124>] complete+0x44/0x60
[12982.965486]    [<ffffffff81065569>] kthread+0x39/0xa0
[12982.965486]    [<ffffffff8100d40a>] child_rip+0xa/0x20
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]      -> (&ep->lock){......} ops: 0 {
[12982.965486]         INITIAL USE at:
[12982.965486]                                                 [<ffffffff8107a6af>] __lock_acquire+0x19f/0x1ae0
[12982.965486]                                                 [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                                 [<ffffffff8156b9a6>] _spin_lock_irqsave+0x56/0xa0
[12982.965486]                                                 [<ffffffff81136f12>] sys_epoll_ctl+0x412/0x520
[12982.965486]                                                 [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[12982.965486]                                                 [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]       }
[12982.965486]       ... key      at: [<ffffffff822da890>] __key.23850+0x0/0x10
[12982.965486]      ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]    [<ffffffff8156b9a6>] _spin_lock_irqsave+0x56/0xa0
[12982.965486]    [<ffffffff81136534>] ep_poll_callback+0x34/0x130
[12982.965486]    [<ffffffff81037daa>] __wake_up_common+0x5a/0x90
[12982.965486]    [<ffffffff8103a1c4>] __wake_up_sync_key+0x84/0xb0
[12982.965486]    [<ffffffff81435718>] sock_def_readable+0x48/0x80
[12982.965486]    [<ffffffff814b629d>] unix_stream_sendmsg+0x23d/0x3c0
[12982.965486]    [<ffffffff814314cb>] sock_aio_write+0x12b/0x140
[12982.965486]    [<ffffffff810fe069>] do_sync_write+0xf9/0x140
[12982.965486]    [<ffffffff810fefa8>] vfs_write+0x1c8/0x1d0
[12982.965486]    [<ffffffff810ff0c7>] sys_write+0x57/0xb0
[12982.965486]    [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]     ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]    [<ffffffff8156b9a6>] _spin_lock_irqsave+0x56/0xa0
[12982.965486]    [<ffffffff8103a242>] __wake_up+0x32/0x70
[12982.965486]    [<ffffffff81119614>] touch_mnt_namespace+0x34/0x40
[12982.965486]    [<ffffffff81119b31>] commit_tree+0x101/0x110
[12982.965486]    [<ffffffff8111ae17>] attach_recursive_mnt+0x2b7/0x2c0
[12982.965486]    [<ffffffff8111aee1>] graft_tree+0xc1/0xf0
[12982.965486]    [<ffffffff8111b004>] do_add_mount+0xf4/0x140
[12982.965486]    [<ffffffff8111bc43>] do_mount+0x2f3/0x8f0
[12982.965486]    [<ffffffff8111c31b>] sys_mount+0xdb/0x110
[12982.965486]    [<ffffffff818b5fb9>] do_mount_root+0x21/0xab
[12982.965486]    [<ffffffff818b64bf>] mount_root+0x138/0x141
[12982.965486]    [<ffffffff818b65c0>] prepare_namespace+0xf8/0x198
[12982.965486]    [<ffffffff818b56fe>] kernel_init+0x18b/0x1a8
[12982.965486]    [<ffffffff8100d40a>] child_rip+0xa/0x20
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]    ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]    [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]    [<ffffffff811128ee>] __d_path+0x3e/0x190
[12982.965486]    [<ffffffff81112b55>] sys_getcwd+0x115/0x1e0
[12982.965486]    [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]    -> (rename_lock){+.+...} ops: 0 {
[12982.965486]       HARDIRQ-ON-W at:
[12982.965486]                                              [<ffffffff8107b035>] __lock_acquire+0xb25/0x1ae0
[12982.965486]                                              [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                              [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]                                              [<ffffffff811132d3>] d_move_locked+0x33/0x260
[12982.965486]                                              [<ffffffff81113533>] d_move+0x33/0x50
[12982.965486]                                              [<ffffffff81109e05>] vfs_rename+0x375/0x430
[12982.965486]                                              [<ffffffff8110c0ad>] sys_renameat+0x24d/0x2a0
[12982.965486]                                              [<ffffffff8110c11b>] sys_rename+0x1b/0x20
[12982.965486]                                              [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[12982.965486]                                              [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]       SOFTIRQ-ON-W at:
[12982.965486]                                              [<ffffffff8107b061>] __lock_acquire+0xb51/0x1ae0
[12982.965486]                                              [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                              [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]                                              [<ffffffff811132d3>] d_move_locked+0x33/0x260
[12982.965486]                                              [<ffffffff81113533>] d_move+0x33/0x50
[12982.965486]                                              [<ffffffff81109e05>] vfs_rename+0x375/0x430
[12982.965486]                                              [<ffffffff8110c0ad>] sys_renameat+0x24d/0x2a0
[12982.965486]                                              [<ffffffff8110c11b>] sys_rename+0x1b/0x20
[12982.965486]                                              [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[12982.965486]                                              [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]       INITIAL USE at:
[12982.965486]                                             [<ffffffff8107a6af>] __lock_acquire+0x19f/0x1ae0
[12982.965486]                                             [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                             [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]                                             [<ffffffff811132d3>] d_move_locked+0x33/0x260
[12982.965486]                                             [<ffffffff81113533>] d_move+0x33/0x50
[12982.965486]                                             [<ffffffff81109e05>] vfs_rename+0x375/0x430
[12982.965486]                                             [<ffffffff8110c0ad>] sys_renameat+0x24d/0x2a0
[12982.965486]                                             [<ffffffff8110c11b>] sys_rename+0x1b/0x20
[12982.965486]                                             [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[12982.965486]                                             [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]     }
[12982.965486]     ... key      at: [<ffffffff818a3820>] rename_lock+0x20/0x80
[12982.965486]     ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]    [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]    [<ffffffff811134a5>] d_move_locked+0x205/0x260
[12982.965486]    [<ffffffff81113533>] d_move+0x33/0x50
[12982.965486]    [<ffffffff81109e05>] vfs_rename+0x375/0x430
[12982.965486]    [<ffffffff8110c0ad>] sys_renameat+0x24d/0x2a0
[12982.965486]    [<ffffffff8110c11b>] sys_rename+0x1b/0x20
[12982.965486]    [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]     ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107cc9f>] lock_release_non_nested+0x14f/0x2d0
[12982.965486]    [<ffffffff8107cf57>] lock_release+0x137/0x220
[12982.965486]    [<ffffffff8156b653>] _spin_unlock+0x23/0x40
[12982.965486]    [<ffffffff81113454>] d_move_locked+0x1b4/0x260
[12982.965486]    [<ffffffff81113533>] d_move+0x33/0x50
[12982.965486]    [<ffffffff81109e05>] vfs_rename+0x375/0x430
[12982.965486]    [<ffffffff8110c0ad>] sys_renameat+0x24d/0x2a0
[12982.965486]    [<ffffffff8110c11b>] sys_rename+0x1b/0x20
[12982.965486]    [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]    ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]    [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]    [<ffffffff811132d3>] d_move_locked+0x33/0x260
[12982.965486]    [<ffffffff81113533>] d_move+0x33/0x50
[12982.965486]    [<ffffffff81109e05>] vfs_rename+0x375/0x430
[12982.965486]    [<ffffffff8110c0ad>] sys_renameat+0x24d/0x2a0
[12982.965486]    [<ffffffff8110c11b>] sys_rename+0x1b/0x20
[12982.965486]    [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]    -> (sb_lock){+.+.-.} ops: 0 {
[12982.965486]       HARDIRQ-ON-W at:
[12982.965486]                                              [<ffffffff8107b035>] __lock_acquire+0xb25/0x1ae0
[12982.965486]                                              [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                              [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]                                              [<ffffffff81100dc4>] sget+0x54/0x490
[12982.965486]                                              [<ffffffff81101866>] get_sb_single+0x46/0x100
[12982.965486]                                              [<ffffffff8115586b>] sysfs_get_sb+0x1b/0x20
[12982.965486]                                              [<ffffffff811003f0>] vfs_kern_mount+0x50/0xd0
[12982.965486]                                              [<ffffffff81100489>] kern_mount_data+0x19/0x20
[12982.965486]                                              [<ffffffff818d38d4>] sysfs_init+0x7f/0xd4
[12982.965486]                                              [<ffffffff818d20d4>] mnt_init+0x9d/0x21e
[12982.965486]                                              [<ffffffff818d1c24>] vfs_caches_init+0xa8/0x140
[12982.965486]                                              [<ffffffff818b5d0f>] start_kernel+0x34c/0x44f
[12982.965486]                                              [<ffffffff818b5299>] x86_64_start_reservations+0x99/0xb9
[12982.965486]                                              [<ffffffff818b53b0>] x86_64_start_kernel+0xf7/0x122
[12982.965486]                                              [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]       SOFTIRQ-ON-W at:
[12982.965486]                                              [<ffffffff8107b061>] __lock_acquire+0xb51/0x1ae0
[12982.965486]                                              [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                              [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]                                              [<ffffffff81100dc4>] sget+0x54/0x490
[12982.965486]                                              [<ffffffff81101866>] get_sb_single+0x46/0x100
[12982.965486]                                              [<ffffffff8115586b>] sysfs_get_sb+0x1b/0x20
[12982.965486]                                              [<ffffffff811003f0>] vfs_kern_mount+0x50/0xd0
[12982.965486]                                              [<ffffffff81100489>] kern_mount_data+0x19/0x20
[12982.965486]                                              [<ffffffff818d38d4>] sysfs_init+0x7f/0xd4
[12982.965486]                                              [<ffffffff818d20d4>] mnt_init+0x9d/0x21e
[12982.965486]                                              [<ffffffff818d1c24>] vfs_caches_init+0xa8/0x140
[12982.965486]                                              [<ffffffff818b5d0f>] start_kernel+0x34c/0x44f
[12982.965486]                                              [<ffffffff818b5299>] x86_64_start_reservations+0x99/0xb9
[12982.965486]                                              [<ffffffff818b53b0>] x86_64_start_kernel+0xf7/0x122
[12982.965486]                                              [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]       IN-RECLAIM_FS-W at:
[12982.965486]                                                 [<ffffffff8107b172>] __lock_acquire+0xc62/0x1ae0
[12982.965486]                                                 [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                                 [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]                                                 [<ffffffff81112259>] shrink_dcache_memory+0xa9/0x1e0
[12982.965486]                                                 [<ffffffff810d5d75>] shrink_slab+0x125/0x180
[12982.965486]                                                 [<ffffffff810d65f0>] kswapd+0x560/0x7a0
[12982.965486]                                                 [<ffffffff8106558b>] kthread+0x5b/0xa0
[12982.965486]                                                 [<ffffffff8100d40a>] child_rip+0xa/0x20
[12982.965486]                                                 [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]       INITIAL USE at:
[12982.965486]                                             [<ffffffff8107a6af>] __lock_acquire+0x19f/0x1ae0
[12982.965486]                                             [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                             [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]                                             [<ffffffff81100dc4>] sget+0x54/0x490
[12982.965486]                                             [<ffffffff81101866>] get_sb_single+0x46/0x100
[12982.965486]                                             [<ffffffff8115586b>] sysfs_get_sb+0x1b/0x20
[12982.965486]                                             [<ffffffff811003f0>] vfs_kern_mount+0x50/0xd0
[12982.965486]                                             [<ffffffff81100489>] kern_mount_data+0x19/0x20
[12982.965486]                                             [<ffffffff818d38d4>] sysfs_init+0x7f/0xd4
[12982.965486]                                             [<ffffffff818d20d4>] mnt_init+0x9d/0x21e
[12982.965486]                                             [<ffffffff818d1c24>] vfs_caches_init+0xa8/0x140
[12982.965486]                                             [<ffffffff818b5d0f>] start_kernel+0x34c/0x44f
[12982.965486]                                             [<ffffffff818b5299>] x86_64_start_reservations+0x99/0xb9
[12982.965486]                                             [<ffffffff818b53b0>] x86_64_start_kernel+0xf7/0x122
[12982.965486]                                             [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]     }
[12982.965486]     ... key      at: [<ffffffff817f0fd8>] sb_lock+0x18/0x40
[12982.965486]     ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]    [<ffffffff8156b9a6>] _spin_lock_irqsave+0x56/0xa0
[12982.965486]    [<ffffffff810f9fc9>] slob_alloc+0x59/0x250
[12982.965486]    [<ffffffff810fa2df>] kmem_cache_alloc_node+0x11f/0x1a0
[12982.965486]    [<ffffffff812789da>] idr_pre_get+0x6a/0x90
[12982.965486]    [<ffffffff81278a1c>] ida_pre_get+0x1c/0x80
[12982.965486]    [<ffffffff811005f1>] set_anon_super+0x31/0xe0
[12982.965486]    [<ffffffff81101142>] sget+0x3d2/0x490
[12982.965486]    [<ffffffff81101866>] get_sb_single+0x46/0x100
[12982.965486]    [<ffffffff8115586b>] sysfs_get_sb+0x1b/0x20
[12982.965486]    [<ffffffff811003f0>] vfs_kern_mount+0x50/0xd0
[12982.965486]    [<ffffffff81100489>] kern_mount_data+0x19/0x20
[12982.965486]    [<ffffffff818d38d4>] sysfs_init+0x7f/0xd4
[12982.965486]    [<ffffffff818d20d4>] mnt_init+0x9d/0x21e
[12982.965486]    [<ffffffff818d1c24>] vfs_caches_init+0xa8/0x140
[12982.965486]    [<ffffffff818b5d0f>] start_kernel+0x34c/0x44f
[12982.965486]    [<ffffffff818b5299>] x86_64_start_reservations+0x99/0xb9
[12982.965486]    [<ffffffff818b53b0>] x86_64_start_kernel+0xf7/0x122
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]     -> (unnamed_dev_ida.lock){......} ops: 0 {
[12982.965486]        INITIAL USE at:
[12982.965486]                                               [<ffffffff8107a6af>] __lock_acquire+0x19f/0x1ae0
[12982.965486]                                               [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                               [<ffffffff8156b9a6>] _spin_lock_irqsave+0x56/0xa0
[12982.965486]                                               [<ffffffff812789a0>] idr_pre_get+0x30/0x90
[12982.965486]                                               [<ffffffff81278a1c>] ida_pre_get+0x1c/0x80
[12982.965486]                                               [<ffffffff811005f1>] set_anon_super+0x31/0xe0
[12982.965486]                                               [<ffffffff81101142>] sget+0x3d2/0x490
[12982.965486]                                               [<ffffffff81101866>] get_sb_single+0x46/0x100
[12982.965486]                                               [<ffffffff8115586b>] sysfs_get_sb+0x1b/0x20
[12982.965486]                                               [<ffffffff811003f0>] vfs_kern_mount+0x50/0xd0
[12982.965486]                                               [<ffffffff81100489>] kern_mount_data+0x19/0x20
[12982.965486]                                               [<ffffffff818d38d4>] sysfs_init+0x7f/0xd4
[12982.965486]                                               [<ffffffff818d20d4>] mnt_init+0x9d/0x21e
[12982.965486]                                               [<ffffffff818d1c24>] vfs_caches_init+0xa8/0x140
[12982.965486]                                               [<ffffffff818b5d0f>] start_kernel+0x34c/0x44f
[12982.965486]                                               [<ffffffff818b5299>] x86_64_start_reservations+0x99/0xb9
[12982.965486]                                               [<ffffffff818b53b0>] x86_64_start_kernel+0xf7/0x122
[12982.965486]                                               [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]      }
[12982.965486]      ... key      at: [<ffffffff817f1070>] unnamed_dev_ida+0x30/0x60
[12982.965486]     ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]    [<ffffffff8156b9a6>] _spin_lock_irqsave+0x56/0xa0
[12982.965486]    [<ffffffff812789a0>] idr_pre_get+0x30/0x90
[12982.965486]    [<ffffffff81278a1c>] ida_pre_get+0x1c/0x80
[12982.965486]    [<ffffffff811005f1>] set_anon_super+0x31/0xe0
[12982.965486]    [<ffffffff81101142>] sget+0x3d2/0x490
[12982.965486]    [<ffffffff81101866>] get_sb_single+0x46/0x100
[12982.965486]    [<ffffffff8115586b>] sysfs_get_sb+0x1b/0x20
[12982.965486]    [<ffffffff811003f0>] vfs_kern_mount+0x50/0xd0
[12982.965486]    [<ffffffff81100489>] kern_mount_data+0x19/0x20
[12982.965486]    [<ffffffff818d38d4>] sysfs_init+0x7f/0xd4
[12982.965486]    [<ffffffff818d20d4>] mnt_init+0x9d/0x21e
[12982.965486]    [<ffffffff818d1c24>] vfs_caches_init+0xa8/0x140
[12982.965486]    [<ffffffff818b5d0f>] start_kernel+0x34c/0x44f
[12982.965486]    [<ffffffff818b5299>] x86_64_start_reservations+0x99/0xb9
[12982.965486]    [<ffffffff818b53b0>] x86_64_start_kernel+0xf7/0x122
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]     -> (unnamed_dev_lock){+.+...} ops: 0 {
[12982.965486]        HARDIRQ-ON-W at:
[12982.965486]                                                [<ffffffff8107b035>] __lock_acquire+0xb25/0x1ae0
[12982.965486]                                                [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                                [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]                                                [<ffffffff81100601>] set_anon_super+0x41/0xe0
[12982.965486]                                                [<ffffffff81101142>] sget+0x3d2/0x490
[12982.965486]                                                [<ffffffff81101866>] get_sb_single+0x46/0x100
[12982.965486]                                                [<ffffffff8115586b>] sysfs_get_sb+0x1b/0x20
[12982.965486]                                                [<ffffffff811003f0>] vfs_kern_mount+0x50/0xd0
[12982.965486]                                                [<ffffffff81100489>] kern_mount_data+0x19/0x20
[12982.965486]                                                [<ffffffff818d38d4>] sysfs_init+0x7f/0xd4
[12982.965486]                                                [<ffffffff818d20d4>] mnt_init+0x9d/0x21e
[12982.965486]                                                [<ffffffff818d1c24>] vfs_caches_init+0xa8/0x140
[12982.965486]                                                [<ffffffff818b5d0f>] start_kernel+0x34c/0x44f
[12982.965486]                                                [<ffffffff818b5299>] x86_64_start_reservations+0x99/0xb9
[12982.965486]                                                [<ffffffff818b53b0>] x86_64_start_kernel+0xf7/0x122
[12982.965486]                                                [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]        SOFTIRQ-ON-W at:
[12982.965486]                                                [<ffffffff8107b061>] __lock_acquire+0xb51/0x1ae0
[12982.965486]                                                [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                                [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]                                                [<ffffffff81100601>] set_anon_super+0x41/0xe0
[12982.965486]                                                [<ffffffff81101142>] sget+0x3d2/0x490
[12982.965486]                                                [<ffffffff81101866>] get_sb_single+0x46/0x100
[12982.965486]                                                [<ffffffff8115586b>] sysfs_get_sb+0x1b/0x20
[12982.965486]                                                [<ffffffff811003f0>] vfs_kern_mount+0x50/0xd0
[12982.965486]                                                [<ffffffff81100489>] kern_mount_data+0x19/0x20
[12982.965486]                                                [<ffffffff818d38d4>] sysfs_init+0x7f/0xd4
[12982.965486]                                                [<ffffffff818d20d4>] mnt_init+0x9d/0x21e
[12982.965486]                                                [<ffffffff818d1c24>] vfs_caches_init+0xa8/0x140
[12982.965486]                                                [<ffffffff818b5d0f>] start_kernel+0x34c/0x44f
[12982.965486]                                                [<ffffffff818b5299>] x86_64_start_reservations+0x99/0xb9
[12982.965486]                                                [<ffffffff818b53b0>] x86_64_start_kernel+0xf7/0x122
[12982.965486]                                                [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]        INITIAL USE at:
[12982.965486]                                               [<ffffffff8107a6af>] __lock_acquire+0x19f/0x1ae0
[12982.965486]                                               [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                               [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]                                               [<ffffffff81100601>] set_anon_super+0x41/0xe0
[12982.965486]                                               [<ffffffff81101142>] sget+0x3d2/0x490
[12982.965486]                                               [<ffffffff81101866>] get_sb_single+0x46/0x100
[12982.965486]                                               [<ffffffff8115586b>] sysfs_get_sb+0x1b/0x20
[12982.965486]                                               [<ffffffff811003f0>] vfs_kern_mount+0x50/0xd0
[12982.965486]                                               [<ffffffff81100489>] kern_mount_data+0x19/0x20
[12982.965486]                                               [<ffffffff818d38d4>] sysfs_init+0x7f/0xd4
[12982.965486]                                               [<ffffffff818d20d4>] mnt_init+0x9d/0x21e
[12982.965486]                                               [<ffffffff818d1c24>] vfs_caches_init+0xa8/0x140
[12982.965486]                                               [<ffffffff818b5d0f>] start_kernel+0x34c/0x44f
[12982.965486]                                               [<ffffffff818b5299>] x86_64_start_reservations+0x99/0xb9
[12982.965486]                                               [<ffffffff818b53b0>] x86_64_start_kernel+0xf7/0x122
[12982.965486]                                               [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]      }
[12982.965486]      ... key      at: [<ffffffff817f1018>] unnamed_dev_lock+0x18/0x40
[12982.965486]      ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]    [<ffffffff8156b9a6>] _spin_lock_irqsave+0x56/0xa0
[12982.965486]    [<ffffffff81277c63>] get_from_free_list+0x23/0x60
[12982.965486]    [<ffffffff812781ad>] idr_get_empty_slot+0x2bd/0x2e0
[12982.965486]    [<ffffffff8127828e>] ida_get_new_above+0xbe/0x210
[12982.965486]    [<ffffffff812783ee>] ida_get_new+0xe/0x10
[12982.965486]    [<ffffffff81100610>] set_anon_super+0x50/0xe0
[12982.965486]    [<ffffffff81101142>] sget+0x3d2/0x490
[12982.965486]    [<ffffffff81101866>] get_sb_single+0x46/0x100
[12982.965486]    [<ffffffff8115586b>] sysfs_get_sb+0x1b/0x20
[12982.965486]    [<ffffffff811003f0>] vfs_kern_mount+0x50/0xd0
[12982.965486]    [<ffffffff81100489>] kern_mount_data+0x19/0x20
[12982.965486]    [<ffffffff818d38d4>] sysfs_init+0x7f/0xd4
[12982.965486]    [<ffffffff818d20d4>] mnt_init+0x9d/0x21e
[12982.965486]    [<ffffffff818d1c24>] vfs_caches_init+0xa8/0x140
[12982.965486]    [<ffffffff818b5d0f>] start_kernel+0x34c/0x44f
[12982.965486]    [<ffffffff818b5299>] x86_64_start_reservations+0x99/0xb9
[12982.965486]    [<ffffffff818b53b0>] x86_64_start_kernel+0xf7/0x122
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]      ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]    [<ffffffff8156b9a6>] _spin_lock_irqsave+0x56/0xa0
[12982.965486]    [<ffffffff810f9a21>] slob_free+0xa1/0x370
[12982.965486]    [<ffffffff810f9d25>] __kmem_cache_free+0x35/0x40
[12982.965486]    [<ffffffff810f9dfc>] kmem_cache_free+0xcc/0xd0
[12982.965486]    [<ffffffff81278311>] ida_get_new_above+0x141/0x210
[12982.965486]    [<ffffffff812783ee>] ida_get_new+0xe/0x10
[12982.965486]    [<ffffffff81100610>] set_anon_super+0x50/0xe0
[12982.965486]    [<ffffffff81101142>] sget+0x3d2/0x490
[12982.965486]    [<ffffffff81101866>] get_sb_single+0x46/0x100
[12982.965486]    [<ffffffff8115586b>] sysfs_get_sb+0x1b/0x20
[12982.965486]    [<ffffffff811003f0>] vfs_kern_mount+0x50/0xd0
[12982.965486]    [<ffffffff81100489>] kern_mount_data+0x19/0x20
[12982.965486]    [<ffffffff818d38d4>] sysfs_init+0x7f/0xd4
[12982.965486]    [<ffffffff818d20d4>] mnt_init+0x9d/0x21e
[12982.965486]    [<ffffffff818d1c24>] vfs_caches_init+0xa8/0x140
[12982.965486]    [<ffffffff818b5d0f>] start_kernel+0x34c/0x44f
[12982.965486]    [<ffffffff818b5299>] x86_64_start_reservations+0x99/0xb9
[12982.965486]    [<ffffffff818b53b0>] x86_64_start_kernel+0xf7/0x122
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]     ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]    [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]    [<ffffffff81100601>] set_anon_super+0x41/0xe0
[12982.965486]    [<ffffffff81101142>] sget+0x3d2/0x490
[12982.965486]    [<ffffffff81101866>] get_sb_single+0x46/0x100
[12982.965486]    [<ffffffff8115586b>] sysfs_get_sb+0x1b/0x20
[12982.965486]    [<ffffffff811003f0>] vfs_kern_mount+0x50/0xd0
[12982.965486]    [<ffffffff81100489>] kern_mount_data+0x19/0x20
[12982.965486]    [<ffffffff818d38d4>] sysfs_init+0x7f/0xd4
[12982.965486]    [<ffffffff818d20d4>] mnt_init+0x9d/0x21e
[12982.965486]    [<ffffffff818d1c24>] vfs_caches_init+0xa8/0x140
[12982.965486]    [<ffffffff818b5d0f>] start_kernel+0x34c/0x44f
[12982.965486]    [<ffffffff818b5299>] x86_64_start_reservations+0x99/0xb9
[12982.965486]    [<ffffffff818b53b0>] x86_64_start_kernel+0xf7/0x122
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]    ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]    [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]    [<ffffffff81112259>] shrink_dcache_memory+0xa9/0x1e0
[12982.965486]    [<ffffffff810d5d75>] shrink_slab+0x125/0x180
[12982.965486]    [<ffffffff810d6b9d>] shrink_all_memory+0x36d/0x4c0
[12982.965486]    [<ffffffff8108bcc3>] swsusp_shrink_memory+0xe3/0x1c0
[12982.965486]    [<ffffffff8108c842>] hibernation_snapshot+0x22/0x2a0
[12982.965486]    [<ffffffff8108cc04>] hibernate+0x144/0x220
[12982.965486]    [<ffffffff8108b204>] state_store+0xe4/0x100
[12982.965486]    [<ffffffff81278e87>] kobj_attr_store+0x17/0x20
[12982.965486]    [<ffffffff811530bf>] sysfs_write_file+0xcf/0x140
[12982.965486]    [<ffffffff810feef6>] vfs_write+0x116/0x1d0
[12982.965486]    [<ffffffff810ff0c7>] sys_write+0x57/0xb0
[12982.965486]    [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]    -> (&sem->wait_lock){....-.} ops: 0 {
[12982.965486]       IN-RECLAIM_FS-W at:
[12982.965486]                                                 [<ffffffff8107b172>] __lock_acquire+0xc62/0x1ae0
[12982.965486]                                                 [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                                 [<ffffffff8156b9a6>] _spin_lock_irqsave+0x56/0xa0
[12982.965486]                                                 [<ffffffff8127d1c0>] __down_read_trylock+0x20/0x60
[12982.965486]                                                 [<ffffffff8106a6ad>] down_read_trylock+0x1d/0x60
[12982.965486]                                                 [<ffffffff811122cf>] shrink_dcache_memory+0x11f/0x1e0
[12982.965486]                                                 [<ffffffff810d5d75>] shrink_slab+0x125/0x180
[12982.965486]                                                 [<ffffffff810d65f0>] kswapd+0x560/0x7a0
[12982.965486]                                                 [<ffffffff8106558b>] kthread+0x5b/0xa0
[12982.965486]                                                 [<ffffffff8100d40a>] child_rip+0xa/0x20
[12982.965486]                                                 [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]       INITIAL USE at:
[12982.965486]                                             [<ffffffff8107a6af>] __lock_acquire+0x19f/0x1ae0
[12982.965486]                                             [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                             [<ffffffff8156b9a6>] _spin_lock_irqsave+0x56/0xa0
[12982.965486]                                             [<ffffffff8127d160>] __down_write_trylock+0x20/0x60
[12982.965486]                                             [<ffffffff8106a56f>] down_write_nested+0x5f/0xa0
[12982.965486]                                             [<ffffffff81100f8d>] sget+0x21d/0x490
[12982.965486]                                             [<ffffffff81101866>] get_sb_single+0x46/0x100
[12982.965486]                                             [<ffffffff8115586b>] sysfs_get_sb+0x1b/0x20
[12982.965486]                                             [<ffffffff811003f0>] vfs_kern_mount+0x50/0xd0
[12982.965486]                                             [<ffffffff81100489>] kern_mount_data+0x19/0x20
[12982.965486]                                             [<ffffffff818d38d4>] sysfs_init+0x7f/0xd4
[12982.965486]                                             [<ffffffff818d20d4>] mnt_init+0x9d/0x21e
[12982.965486]                                             [<ffffffff818d1c24>] vfs_caches_init+0xa8/0x140
[12982.965486]                                             [<ffffffff818b5d0f>] start_kernel+0x34c/0x44f
[12982.965486]                                             [<ffffffff818b5299>] x86_64_start_reservations+0x99/0xb9
[12982.965486]                                             [<ffffffff818b53b0>] x86_64_start_kernel+0xf7/0x122
[12982.965486]                                             [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]     }
[12982.965486]     ... key      at: [<ffffffff822e7058>] __key.16656+0x0/0x8
[12982.965486]    ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]    [<ffffffff8156b9a6>] _spin_lock_irqsave+0x56/0xa0
[12982.965486]    [<ffffffff8127d1c0>] __down_read_trylock+0x20/0x60
[12982.965486]    [<ffffffff8106a6ad>] down_read_trylock+0x1d/0x60
[12982.965486]    [<ffffffff811122cf>] shrink_dcache_memory+0x11f/0x1e0
[12982.965486]    [<ffffffff810d5d75>] shrink_slab+0x125/0x180
[12982.965486]    [<ffffffff810d6b9d>] shrink_all_memory+0x36d/0x4c0
[12982.965486]    [<ffffffff8108bcc3>] swsusp_shrink_memory+0xe3/0x1c0
[12982.965486]    [<ffffffff8108c842>] hibernation_snapshot+0x22/0x2a0
[12982.965486]    [<ffffffff8108cc04>] hibernate+0x144/0x220
[12982.965486]    [<ffffffff8108b204>] state_store+0xe4/0x100
[12982.965486]    [<ffffffff81278e87>] kobj_attr_store+0x17/0x20
[12982.965486]    [<ffffffff811530bf>] sysfs_write_file+0xcf/0x140
[12982.965486]    [<ffffffff810feef6>] vfs_write+0x116/0x1d0
[12982.965486]    [<ffffffff810ff0c7>] sys_write+0x57/0xb0
[12982.965486]    [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]   ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]    [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]    [<ffffffff81133e28>] set_dentry_child_flags+0x28/0xf0
[12982.965486]    [<ffffffff8113404e>] inotify_add_watch+0x15e/0x170
[12982.965486]    [<ffffffff811355c8>] sys_inotify_add_watch+0x268/0x290
[12982.965486]    [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]   -> (&dev->ev_mutex){+.+.+.} ops: 0 {
[12982.965486]      HARDIRQ-ON-W at:
[12982.965486]                                            [<ffffffff8107b035>] __lock_acquire+0xb25/0x1ae0
[12982.965486]                                            [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                            [<ffffffff81569353>] mutex_lock_nested+0x63/0x420
[12982.965486]                                            [<ffffffff81134d58>] inotify_poll+0x48/0x80
[12982.965486]                                            [<ffffffff811108b1>] do_select+0x3b1/0x730
[12982.965486]                                            [<ffffffff81110e40>] core_sys_select+0x210/0x370
[12982.965486]                                            [<ffffffff8111123f>] sys_select+0x4f/0x110
[12982.965486]                                            [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[12982.965486]                                            [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]      SOFTIRQ-ON-W at:
[12982.965486]                                            [<ffffffff8107b061>] __lock_acquire+0xb51/0x1ae0
[12982.965486]                                            [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                            [<ffffffff81569353>] mutex_lock_nested+0x63/0x420
[12982.965486]                                            [<ffffffff81134d58>] inotify_poll+0x48/0x80
[12982.965486]                                            [<ffffffff811108b1>] do_select+0x3b1/0x730
[12982.965486]                                            [<ffffffff81110e40>] core_sys_select+0x210/0x370
[12982.965486]                                            [<ffffffff8111123f>] sys_select+0x4f/0x110
[12982.965486]                                            [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[12982.965486]                                            [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]      RECLAIM_FS-ON-W at:
[12982.965486]                                               [<ffffffff810791b8>] mark_held_locks+0x68/0x90
[12982.965486]                                               [<ffffffff810792d5>] lockdep_trace_alloc+0xf5/0x100
[12982.965486]                                               [<ffffffff810fa561>] __kmalloc_node+0x31/0x1e0
[12982.965486]                                               [<ffffffff811359c2>] kernel_event+0xe2/0x190
[12982.965486]                                               [<ffffffff81135b96>] inotify_dev_queue_event+0x126/0x230
[12982.965486]                                               [<ffffffff811343a6>] inotify_inode_queue_event+0xc6/0x110
[12982.965486]                                               [<ffffffff8110974d>] vfs_create+0xcd/0x140
[12982.965486]                                               [<ffffffff8110d55d>] do_filp_open+0x88d/0xa20
[12982.965486]                                               [<ffffffff810fbe68>] do_sys_open+0x98/0x140
[12982.965486]                                               [<ffffffff810fbf50>] sys_open+0x20/0x30
[12982.965486]                                               [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[12982.965486]                                               [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]      INITIAL USE at:
[12982.965486]                                           [<ffffffff8107a6af>] __lock_acquire+0x19f/0x1ae0
[12982.965486]                                           [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]                                           [<ffffffff81569353>] mutex_lock_nested+0x63/0x420
[12982.965486]                                           [<ffffffff81134d58>] inotify_poll+0x48/0x80
[12982.965486]                                           [<ffffffff811108b1>] do_select+0x3b1/0x730
[12982.965486]                                           [<ffffffff81110e40>] core_sys_select+0x210/0x370
[12982.965486]                                           [<ffffffff8111123f>] sys_select+0x4f/0x110
[12982.965486]                                           [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[12982.965486]                                           [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]    }
[12982.965486]    ... key      at: [<ffffffff822da874>] __key.21140+0x0/0x8
[12982.965486]    ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]    [<ffffffff8156b9a6>] _spin_lock_irqsave+0x56/0xa0
[12982.965486]    [<ffffffff810f9fc9>] slob_alloc+0x59/0x250
[12982.965486]    [<ffffffff810fa2df>] kmem_cache_alloc_node+0x11f/0x1a0
[12982.965486]    [<ffffffff81135926>] kernel_event+0x46/0x190
[12982.965486]    [<ffffffff81135b96>] inotify_dev_queue_event+0x126/0x230
[12982.965486]    [<ffffffff811343a6>] inotify_inode_queue_event+0xc6/0x110
[12982.965486]    [<ffffffff8110974d>] vfs_create+0xcd/0x140
[12982.965486]    [<ffffffff8110d55d>] do_filp_open+0x88d/0xa20
[12982.965486]    [<ffffffff810fbe68>] do_sys_open+0x98/0x140
[12982.965486]    [<ffffffff810fbf50>] sys_open+0x20/0x30
[12982.965486]    [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]    ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]    [<ffffffff8156b9a6>] _spin_lock_irqsave+0x56/0xa0
[12982.965486]    [<ffffffff8103a242>] __wake_up+0x32/0x70
[12982.965486]    [<ffffffff81135c01>] inotify_dev_queue_event+0x191/0x230
[12982.965486]    [<ffffffff811343a6>] inotify_inode_queue_event+0xc6/0x110
[12982.965486]    [<ffffffff8110974d>] vfs_create+0xcd/0x140
[12982.965486]    [<ffffffff8110d55d>] do_filp_open+0x88d/0xa20
[12982.965486]    [<ffffffff810fbe68>] do_sys_open+0x98/0x140
[12982.965486]    [<ffffffff810fbf50>] sys_open+0x20/0x30
[12982.965486]    [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]   ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]    [<ffffffff81569353>] mutex_lock_nested+0x63/0x420
[12982.965486]    [<ffffffff81135ab7>] inotify_dev_queue_event+0x47/0x230
[12982.965486]    [<ffffffff811343a6>] inotify_inode_queue_event+0xc6/0x110
[12982.965486]    [<ffffffff8110974d>] vfs_create+0xcd/0x140
[12982.965486]    [<ffffffff8110d55d>] do_filp_open+0x88d/0xa20
[12982.965486]    [<ffffffff810fbe68>] do_sys_open+0x98/0x140
[12982.965486]    [<ffffffff810fbf50>] sys_open+0x20/0x30
[12982.965486]    [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]   ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]    [<ffffffff8156b826>] _spin_lock+0x36/0x70
[12982.965486]    [<ffffffff81133b34>] pin_to_kill+0x44/0x160
[12982.965486]    [<ffffffff81134906>] inotify_destroy+0x56/0x120
[12982.965486]    [<ffffffff81134dbd>] inotify_release+0x2d/0xf0
[12982.965486]    [<ffffffff810ffdb4>] __fput+0x124/0x2f0
[12982.965486]    [<ffffffff810fffa5>] fput+0x25/0x30
[12982.965486]    [<ffffffff810fbc43>] filp_close+0x63/0x90
[12982.965486]    [<ffffffff810fbd2e>] sys_close+0xbe/0x160
[12982.965486]    [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]  ... acquired at:
[12982.965486]    [<ffffffff8107bae4>] __lock_acquire+0x15d4/0x1ae0
[12982.965486]    [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]    [<ffffffff81569353>] mutex_lock_nested+0x63/0x420
[12982.965486]    [<ffffffff811340f7>] inotify_find_update_watch+0x97/0x130
[12982.965486]    [<ffffffff811354e4>] sys_inotify_add_watch+0x184/0x290
[12982.965486]    [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[12982.965486]    [<ffffffffffffffff>] 0xffffffffffffffff
[12982.965486]
[12982.965486]
[12982.965486] stack backtrace:
[12982.965486] Pid: 3574, comm: umount Not tainted 2.6.30-rc2-next-20090417 #218
[12982.965486] Call Trace:
[12982.965486]  [<ffffffff8107a354>] check_usage+0x3d4/0x490
[12982.965486]  [<ffffffff8107a474>] check_irq_usage+0x64/0x100
[12982.965486]  [<ffffffff8107b8fe>] __lock_acquire+0x13ee/0x1ae0
[12982.965486]  [<ffffffff8107a01e>] ? check_usage+0x9e/0x490
[12982.965486]  [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
[12982.965486]  [<ffffffff81134ada>] ? inotify_unmount_inodes+0xda/0x1f0
[12982.965486]  [<ffffffff81569353>] mutex_lock_nested+0x63/0x420
[12982.965486]  [<ffffffff81134ada>] ? inotify_unmount_inodes+0xda/0x1f0
[12982.965486]  [<ffffffff81077195>] ? lock_release_holdtime+0x35/0x1c0
[12982.965486]  [<ffffffff81134ada>] ? inotify_unmount_inodes+0xda/0x1f0
[12982.965486]  [<ffffffff812863ad>] ? _raw_spin_unlock+0xcd/0x120
[12982.965486]  [<ffffffff81134ada>] inotify_unmount_inodes+0xda/0x1f0
[12982.965486]  [<ffffffff811160e9>] ? invalidate_inodes+0x49/0x170
[12982.965486]  [<ffffffff811160f1>] invalidate_inodes+0x51/0x170
[12982.965486]  [<ffffffff8110160b>] generic_shutdown_super+0x4b/0x110
[12982.965486]  [<ffffffff81101701>] kill_block_super+0x31/0x50
[12982.965486]  [<ffffffff811017fb>] deactivate_super+0x5b/0x80
[12982.965486]  [<ffffffff8111a28c>] mntput_no_expire+0x18c/0x1c0
[12982.965486]  [<ffffffff8111a637>] sys_umount+0x67/0x380
[12982.965486]  [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[13006.039812] EXT4-fs: mballoc: 0 blocks 0 reqs (0 success)
[13006.045326] EXT4-fs: mballoc: 0 extents scanned, 0 goal hits, 0 2^N hits, 0 breaks, 0 lost
[13006.053743] EXT4-fs: mballoc: 0 generated and it took 0
[13006.059105] EXT4-fs: mballoc: 0 preallocated, 0 discarded

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
