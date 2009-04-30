Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 57B696B003D
	for <linux-mm@kvack.org>; Wed, 29 Apr 2009 22:00:25 -0400 (EDT)
Date: Thu, 30 Apr 2009 10:00:04 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH] use GFP_NOFS in kernel_event()
Message-ID: <20090430020004.GA1898@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>, Christoph Lameter <clameter@sgi.com>, Ingo Molnar <mingo@elte.hu>, Al Viro <viro@zeniv.linux.org.uk>
List-ID: <linux-mm.kvack.org>

Fix a possible deadlock on inotify_mutex, reported by lockdep.

inotify_inode_queue_event() => take inotify_mutex => kernel_event() =>
kmalloc() => SLOB => alloc_pages_node() => page reclaim => slab reclaim =>
dcache reclaim => inotify_inode_is_dead => take inotify_mutex => deadlock

The actual deadlock may not happen because the inode was grabbed at
inotify_add_watch(). But the GFP_KERNEL here is unsound and not
consistent with the other two GFP_NOFS inside the same function.

[ 2668.325318]
[ 2668.325322] =================================
[ 2668.327448] [ INFO: inconsistent lock state ]
[ 2668.327448] 2.6.30-rc2-next-20090417 #203
[ 2668.327448] ---------------------------------
[ 2668.327448] inconsistent {RECLAIM_FS-ON-W} -> {IN-RECLAIM_FS-W} usage.
[ 2668.327448] kswapd0/380 [HC0[0]:SC0[0]:HE1:SE1] takes:
[ 2668.327448]  (&inode->inotify_mutex){+.+.?.}, at: [<ffffffff8112f1b5>] inotify_inode_is_dead+0x35/0xb0
[ 2668.327448] {RECLAIM_FS-ON-W} state was registered at:
[ 2668.327448]   [<ffffffff81079188>] mark_held_locks+0x68/0x90
[ 2668.327448]   [<ffffffff810792a5>] lockdep_trace_alloc+0xf5/0x100
[ 2668.327448]   [<ffffffff810f5261>] __kmalloc_node+0x31/0x1e0
[ 2668.327448]   [<ffffffff81130652>] kernel_event+0xe2/0x190
[ 2668.327448]   [<ffffffff81130826>] inotify_dev_queue_event+0x126/0x230
[ 2668.327448]   [<ffffffff8112f096>] inotify_inode_queue_event+0xc6/0x110
[ 2668.327448]   [<ffffffff8110444d>] vfs_create+0xcd/0x140
[ 2668.327448]   [<ffffffff8110825d>] do_filp_open+0x88d/0xa20
[ 2668.327448]   [<ffffffff810f6b68>] do_sys_open+0x98/0x140
[ 2668.327448]   [<ffffffff810f6c50>] sys_open+0x20/0x30
[ 2668.327448]   [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
[ 2668.327448]   [<ffffffffffffffff>] 0xffffffffffffffff
[ 2668.327448] irq event stamp: 690455
[ 2668.327448] hardirqs last  enabled at (690455): [<ffffffff81564fe4>] _spin_unlock_irqrestore+0x44/0x80
[ 2668.327448] hardirqs last disabled at (690454): [<ffffffff81565372>] _spin_lock_irqsave+0x32/0xa0
[ 2668.327448] softirqs last  enabled at (690178): [<ffffffff81052282>] __do_softirq+0x202/0x220
[ 2668.327448] softirqs last disabled at (690157): [<ffffffff8100d50c>] call_softirq+0x1c/0x50
[ 2668.327448]
[ 2668.327448] other info that might help us debug this:
[ 2668.327448] 2 locks held by kswapd0/380:
[ 2668.327448]  #0:  (shrinker_rwsem){++++..}, at: [<ffffffff810d0bd7>] shrink_slab+0x37/0x180
[ 2668.327448]  #1:  (&type->s_umount_key#17){++++..}, at: [<ffffffff8110cfbf>] shrink_dcache_memory+0x11f/0x1e0
[ 2668.327448]
[ 2668.327448] stack backtrace:
[ 2668.327448] Pid: 380, comm: kswapd0 Not tainted 2.6.30-rc2-next-20090417 #203
[ 2668.327448] Call Trace:
[ 2668.327448]  [<ffffffff810789ef>] print_usage_bug+0x19f/0x200
[ 2668.327448]  [<ffffffff81018bff>] ? save_stack_trace+0x2f/0x50
[ 2668.327448]  [<ffffffff81078f0b>] mark_lock+0x4bb/0x6d0
[ 2668.327448]  [<ffffffff810799e0>] ? check_usage_forwards+0x0/0xc0
[ 2668.327448]  [<ffffffff8107b142>] __lock_acquire+0xc62/0x1ae0
[ 2668.327448]  [<ffffffff810f478c>] ? slob_free+0x10c/0x370
[ 2668.327448]  [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
[ 2668.327448]  [<ffffffff8112f1b5>] ? inotify_inode_is_dead+0x35/0xb0
[ 2668.327448]  [<ffffffff81562d43>] mutex_lock_nested+0x63/0x420
[ 2668.327448]  [<ffffffff8112f1b5>] ? inotify_inode_is_dead+0x35/0xb0
[ 2668.327448]  [<ffffffff8112f1b5>] ? inotify_inode_is_dead+0x35/0xb0
[ 2668.327448]  [<ffffffff81012fe9>] ? sched_clock+0x9/0x10
[ 2668.327448]  [<ffffffff81077165>] ? lock_release_holdtime+0x35/0x1c0
[ 2668.327448]  [<ffffffff8112f1b5>] inotify_inode_is_dead+0x35/0xb0
[ 2668.327448]  [<ffffffff8110c9dc>] dentry_iput+0xbc/0xe0
[ 2668.327448]  [<ffffffff8110cb23>] d_kill+0x33/0x60
[ 2668.327448]  [<ffffffff8110ce23>] __shrink_dcache_sb+0x2d3/0x350
[ 2668.327448]  [<ffffffff8110cffa>] shrink_dcache_memory+0x15a/0x1e0
[ 2668.327448]  [<ffffffff810d0cc5>] shrink_slab+0x125/0x180
[ 2668.327448]  [<ffffffff810d1540>] kswapd+0x560/0x7a0
[ 2668.327448]  [<ffffffff810ce160>] ? isolate_pages_global+0x0/0x2c0
[ 2668.327448]  [<ffffffff81065a30>] ? autoremove_wake_function+0x0/0x40
[ 2668.327448]  [<ffffffff8107953d>] ? trace_hardirqs_on+0xd/0x10
[ 2668.327448]  [<ffffffff810d0fe0>] ? kswapd+0x0/0x7a0
[ 2668.327448]  [<ffffffff8106555b>] kthread+0x5b/0xa0
[ 2668.327448]  [<ffffffff8100d40a>] child_rip+0xa/0x20
[ 2668.327448]  [<ffffffff8100cdd0>] ? restore_args+0x0/0x30
[ 2668.327448]  [<ffffffff81065500>] ? kthread+0x0/0xa0
[ 2668.327448]  [<ffffffff8100d400>] ? child_rip+0x0/0x20

cc: Al Viro <viro@zeniv.linux.org.uk>
cc: Matt Mackall <mpm@selenic.com>
cc: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/notify/inotify/inotify_user.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- mm.orig/fs/notify/inotify/inotify_user.c
+++ mm/fs/notify/inotify/inotify_user.c
@@ -220,7 +220,7 @@ static struct inotify_kernel_event * ker
 				rem = 0;
 		}
 
-		kevent->name = kmalloc(len + rem, GFP_KERNEL);
+		kevent->name = kmalloc(len + rem, GFP_NOFS);
 		if (unlikely(!kevent->name)) {
 			kmem_cache_free(event_cachep, kevent);
 			return NULL;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
