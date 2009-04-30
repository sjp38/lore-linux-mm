Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 3C1926B003D
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 10:51:45 -0400 (EDT)
Subject: Re: [PATCH] use GFP_NOFS in kernel_event()
From: Eric Paris <eparis@redhat.com>
In-Reply-To: <20090430142807.GA13931@localhost>
References: <20090430020004.GA1898@localhost>
	 <20090429191044.b6fceae2.akpm@linux-foundation.org>
	 <1241097573.6020.7.camel@localhost.localdomain>
	 <20090430134821.GB8644@localhost>  <20090430142807.GA13931@localhost>
Content-Type: text/plain
Date: Thu, 30 Apr 2009 10:52:12 -0400
Message-Id: <1241103132.6020.17.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Matt Mackall <mpm@selenic.com>, Ingo Molnar <mingo@elte.hu>, Al Viro <viro@zeniv.linux.org.uk>, peterz@infradead.org
List-ID: <linux-mm.kvack.org>

On Thu, 2009-04-30 at 22:28 +0800, Wu Fengguang wrote:
> On Thu, Apr 30, 2009 at 09:48:21PM +0800, Wu Fengguang wrote:
> > On Thu, Apr 30, 2009 at 09:19:33PM +0800, Eric Paris wrote:
> > > On Wed, 2009-04-29 at 19:10 -0700, Andrew Morton wrote:
> > > > On Thu, 30 Apr 2009 10:00:04 +0800 Wu Fengguang <fengguang.wu@intel.com> wrote:
> > > > 
> > > > > Fix a possible deadlock on inotify_mutex, reported by lockdep.
> > > > > 
> > > > > inotify_inode_queue_event() => take inotify_mutex => kernel_event() =>
> > > > > kmalloc() => SLOB => alloc_pages_node() => page reclaim => slab reclaim =>
> > > > > dcache reclaim => inotify_inode_is_dead => take inotify_mutex => deadlock
> > > > > 
> > > > > The actual deadlock may not happen because the inode was grabbed at
> > > > > inotify_add_watch(). But the GFP_KERNEL here is unsound and not
> > > > > consistent with the other two GFP_NOFS inside the same function.
> > > > > 
> > > > > [ 2668.325318]
> > > > > [ 2668.325322] =================================
> > > > > [ 2668.327448] [ INFO: inconsistent lock state ]
> > > > > [ 2668.327448] 2.6.30-rc2-next-20090417 #203
> > > > > [ 2668.327448] ---------------------------------
> > > > > [ 2668.327448] inconsistent {RECLAIM_FS-ON-W} -> {IN-RECLAIM_FS-W} usage.
> > > > > [ 2668.327448] kswapd0/380 [HC0[0]:SC0[0]:HE1:SE1] takes:
> > > > > [ 2668.327448]  (&inode->inotify_mutex){+.+.?.}, at: [<ffffffff8112f1b5>] inotify_inode_is_dead+0x35/0xb0
> > > 
> > > 
> > > > > [ 2668.327448] Pid: 380, comm: kswapd0 Not tainted 2.6.30-rc2-next-20090417 #203
> > > > > [ 2668.327448] Call Trace:
> > > > > [ 2668.327448]  [<ffffffff810789ef>] print_usage_bug+0x19f/0x200
> > > > > [ 2668.327448]  [<ffffffff81018bff>] ? save_stack_trace+0x2f/0x50
> > > > > [ 2668.327448]  [<ffffffff81078f0b>] mark_lock+0x4bb/0x6d0
> > > > > [ 2668.327448]  [<ffffffff810799e0>] ? check_usage_forwards+0x0/0xc0
> > > > > [ 2668.327448]  [<ffffffff8107b142>] __lock_acquire+0xc62/0x1ae0
> > > > > [ 2668.327448]  [<ffffffff810f478c>] ? slob_free+0x10c/0x370
> > > > > [ 2668.327448]  [<ffffffff8107c0a1>] lock_acquire+0xe1/0x120
> > > > > [ 2668.327448]  [<ffffffff8112f1b5>] ? inotify_inode_is_dead+0x35/0xb0
> > > > > [ 2668.327448]  [<ffffffff81562d43>] mutex_lock_nested+0x63/0x420
> > > > > [ 2668.327448]  [<ffffffff8112f1b5>] ? inotify_inode_is_dead+0x35/0xb0
> > > > > [ 2668.327448]  [<ffffffff8112f1b5>] ? inotify_inode_is_dead+0x35/0xb0
> > > > > [ 2668.327448]  [<ffffffff81012fe9>] ? sched_clock+0x9/0x10
> > > > > [ 2668.327448]  [<ffffffff81077165>] ? lock_release_holdtime+0x35/0x1c0
> > > > > [ 2668.327448]  [<ffffffff8112f1b5>] inotify_inode_is_dead+0x35/0xb0
> > > > > [ 2668.327448]  [<ffffffff8110c9dc>] dentry_iput+0xbc/0xe0
> > > > > [ 2668.327448]  [<ffffffff8110cb23>] d_kill+0x33/0x60
> > > > > [ 2668.327448]  [<ffffffff8110ce23>] __shrink_dcache_sb+0x2d3/0x350
> > > > > [ 2668.327448]  [<ffffffff8110cffa>] shrink_dcache_memory+0x15a/0x1e0
> > > > > [ 2668.327448]  [<ffffffff810d0cc5>] shrink_slab+0x125/0x180
> > > > > [ 2668.327448]  [<ffffffff810d1540>] kswapd+0x560/0x7a0
> > > > > [ 2668.327448]  [<ffffffff810ce160>] ? isolate_pages_global+0x0/0x2c0
> > > > > [ 2668.327448]  [<ffffffff81065a30>] ? autoremove_wake_function+0x0/0x40
> > > > > [ 2668.327448]  [<ffffffff8107953d>] ? trace_hardirqs_on+0xd/0x10
> > > > > [ 2668.327448]  [<ffffffff810d0fe0>] ? kswapd+0x0/0x7a0
> > > > > [ 2668.327448]  [<ffffffff8106555b>] kthread+0x5b/0xa0
> > > > > [ 2668.327448]  [<ffffffff8100d40a>] child_rip+0xa/0x20
> > > > > [ 2668.327448]  [<ffffffff8100cdd0>] ? restore_args+0x0/0x30
> > > > > [ 2668.327448]  [<ffffffff81065500>] ? kthread+0x0/0xa0
> > > > > [ 2668.327448]  [<ffffffff8100d400>] ? child_rip+0x0/0x20
> > > > > 
> > > 
> > > > 
> > > > Somebody was going to fix this for us via lockdep annotation.
> > > > 
> > > > <adds randomly-chosen cc>
> > > 
> > > I really didn't forget this, but I can't figure out how to recreate it,
> > > so I don't know if my logic in the patch is sound.  The patch certainly
> > > will shut up the complaint.
> > > 
> > > We can only hit this inotify cleanup path if the i_nlink = 0.  I can't
> > > find a way to leave the dentry around for memory pressure to clean up
> > > later, but have the n_link = 0.  On ext* the inode is kicked out as soon
> > > as the last close on all open fds for an inode which has been unlinked.
> > > I tried attaching an inotify watch to an NFS or CIFS inode, deleting the
> > > inode on another node, and then putting the first machine under memory
> > > pressure.  I'm not sure why, but the dentry or inode in question were
> > > never evicted so I didn't hit this path either....
> > 
> > FYI, I'm running a huge copy on btrfs with SLOB ;-)
> > 
> > > I know the patch will shut up the problem, but since I can't figure out
> > > by looking at the code a path to reproduce I don't really feel 100%
> > > confident that it is correct....
> > > 
> > > -Eric
> > > 
> > > inotify: lockdep annotation when watch being removed
> > > 
> > > From: Eric Paris <eparis@redhat.com>
> > > 
> > > When a dentry is being evicted from memory pressure, if the inode associated
> > > with that dentry has i_nlink == 0 we are going to drop all of the watches and
> > > kick everything out.  Lockdep complains that previously holding inotify_mutex
> > > we did a __GFP_FS allocation and now __GFP_FS reclaim is taking that lock.
> > > There is no deadlock or danger, since we know on this code path we are
> > > actually cleaning up and evicting everything.  So we move the lock into a new
> > > class for clean up.
> > 
> > I can reproduce the bug and hence confirm that this patch works, so
> > 
> > Tested-by: Wu Fengguang <fengguang.wu@intel.com>
> 
> Ah! The big copy runs all OK - until I run shutdown, and got this big
> warning:

Hmmmmm, maybe we need to move the mutex_init(&inode->inotify_mutex) call
from inode_init_once to inode_init_always so those inodes/locks that we
moved into the new class will get put back in the old class when they
are reused...

diff --git a/fs/inode.c b/fs/inode.c
index 29ca114..cba9ce5 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -189,6 +189,9 @@ struct inode *inode_init_always(struct super_block *sb, struct inode *inode)
 	inode->i_private = NULL;
 	inode->i_mapping = mapping;
 
+#ifdef CONFIG_INOTIFY
+	mutex_init(&inode->inotify_mutex);
+#endif
 	return inode;
 
 out_free_security:
@@ -249,7 +252,6 @@ void inode_init_once(struct inode *inode)
 	i_size_ordered_init(inode);
 #ifdef CONFIG_INOTIFY
 	INIT_LIST_HEAD(&inode->inotify_watches);
-	mutex_init(&inode->inotify_mutex);
 #endif
 }
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
