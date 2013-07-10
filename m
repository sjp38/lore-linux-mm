Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 80A096B0032
	for <linux-mm@kvack.org>; Tue,  9 Jul 2013 22:32:19 -0400 (EDT)
Date: Wed, 10 Jul 2013 12:31:39 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: linux-next: slab shrinkers: BUG at mm/list_lru.c:92
Message-ID: <20130710023138.GO3438@dastard>
References: <20130630183349.GA23731@dhcp22.suse.cz>
 <20130701012558.GB27780@dastard>
 <20130701075005.GA28765@dhcp22.suse.cz>
 <20130701081056.GA4072@dastard>
 <20130702092200.GB16815@dhcp22.suse.cz>
 <20130702121947.GE14996@dastard>
 <20130702124427.GG16815@dhcp22.suse.cz>
 <20130703112403.GP14996@dastard>
 <20130704163643.GF7833@dhcp22.suse.cz>
 <20130708125352.GC20149@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130708125352.GC20149@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Glauber Costa <glommer@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon, Jul 08, 2013 at 02:53:52PM +0200, Michal Hocko wrote:
> On Thu 04-07-13 18:36:43, Michal Hocko wrote:
> > On Wed 03-07-13 21:24:03, Dave Chinner wrote:
> > > On Tue, Jul 02, 2013 at 02:44:27PM +0200, Michal Hocko wrote:
> > > > On Tue 02-07-13 22:19:47, Dave Chinner wrote:
> > > > [...]
> > > > > Ok, so it's been leaked from a dispose list somehow. Thanks for the
> > > > > info, Michal, it's time to go look at the code....
> > > > 
> > > > OK, just in case we will need it, I am keeping the machine in this state
> > > > for now. So we still can play with crash and check all the juicy
> > > > internals.
> > > 
> > > My current suspect is the LRU_RETRY code. I don't think what it is
> > > doing is at all valid - list_for_each_safe() is not safe if you drop
> > > the lock that protects the list. i.e. there is nothing that protects
> > > the stored next pointer from being removed from the list by someone
> > > else. Hence what I think is occurring is this:
> > > 
> > > 
> > > thread 1			thread 2
> > > lock(lru)
> > > list_for_each_safe(lru)		lock(lru)
> > >   isolate			......
> > >     lock(i_lock)
> > >     has buffers
> > >       __iget
> > >       unlock(i_lock)
> > >       unlock(lru)
> > >       .....			(gets lru lock)
> > >       				list_for_each_safe(lru)
> > > 				  walks all the inodes
> > > 				  finds inode being isolated by other thread
> > > 				  isolate
> > > 				    i_count > 0
> > > 				      list_del_init(i_lru)
> > > 				      return LRU_REMOVED;
> > > 				   moves to next inode, inode that
> > > 				   other thread has stored as next
> > > 				   isolate
> > > 				     i_state |= I_FREEING
> > > 				     list_move(dispose_list)
> > > 				     return LRU_REMOVED
> > > 				 ....
> > > 				 unlock(lru)
> > >       lock(lru)
> > >       return LRU_RETRY;
> > >   if (!first_pass)
> > >     ....
> > >   --nr_to_scan
> > >   (loop again using next, which has already been removed from the
> > >   LRU by the other thread!)
> > >   isolate
> > >     lock(i_lock)
> > >     if (i_state & ~I_REFERENCED)
> > >       list_del_init(i_lru)	<<<<< inode is on dispose list!
> > > 				<<<<< inode is now isolated, with I_FREEING set
> > >       return LRU_REMOVED;
> > > 
> > > That fits the corpse left on your machine, Michal. One thread has
> > > moved the inode to a dispose list, the other thread thinks it is
> > > still on the LRU and should be removed, and removes it.
> > > 
> > > This also explains the lru item count going negative - the same item
> > > is being removed from the lru twice. So it seems like all the
> > > problems you've been seeing are caused by this one problem....
> > > 
> > > Patch below that should fix this.
> > 
> > Good news! The test was running since morning and it didn't hang nor
> > crashed. So this really looks like the right fix. It will run also
> > during weekend to be 100% sure. But I guess it is safe to say
> 
> Hmm, it seems I was too optimistic or we have yet another issue here (I
> guess the later is more probable).
> 
> The weekend testing got stuck as well. 
....
> 20761 [<ffffffffa0305fdd>] xlog_grant_head_wait+0xdd/0x1a0 [xfs]
> [<ffffffffa0306166>] xlog_grant_head_check+0xc6/0xe0 [xfs]
> [<ffffffffa030627f>] xfs_log_reserve+0xff/0x240 [xfs]
> [<ffffffffa0302ac4>] xfs_trans_reserve+0x234/0x240 [xfs]
> [<ffffffffa02c5999>] xfs_create+0x1a9/0x5c0 [xfs]
> [<ffffffffa02bccca>] xfs_vn_mknod+0x8a/0x1a0 [xfs]
> [<ffffffffa02bce0e>] xfs_vn_create+0xe/0x10 [xfs]
> [<ffffffff811763dd>] vfs_create+0xad/0xd0
> [<ffffffff81177e68>] lookup_open+0x1b8/0x1d0
> [<ffffffff8117815e>] do_last+0x2de/0x780
> [<ffffffff8117ae9a>] path_openat+0xda/0x400
> [<ffffffff8117b303>] do_filp_open+0x43/0xa0
> [<ffffffff81168ee0>] do_sys_open+0x160/0x1e0
> [<ffffffff81168f9c>] sys_open+0x1c/0x20
> [<ffffffff815830e9>] system_call_fastpath+0x16/0x1b
> [<ffffffffffffffff>] 0xffffffffffffffff

That's an XFS log space issue, indicating that it has run out of
space in IO the log and it is waiting for more to come free. That
requires IO completion to occur.

> [276962.652076] INFO: task xfs-data/sda9:930 blocked for more than 480 seconds.
> [276962.652087] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> [276962.652093] xfs-data/sda9   D ffff88001ffb9cc8     0   930      2 0x00000000

Oh, that's why. This is the IO completion worker...

> [276962.652102]  ffff88003794d198 0000000000000046 ffff8800325f4480 0000000000000000
> [276962.652113]  ffff88003794c010 0000000000012dc0 0000000000012dc0 0000000000012dc0
> [276962.652121]  0000000000012dc0 ffff88003794dfd8 ffff88003794dfd8 0000000000012dc0
> [276962.652128] Call Trace:
> [276962.652151]  [<ffffffff812a2c22>] ? __blk_run_queue+0x32/0x40
> [276962.652160]  [<ffffffff812a31f8>] ? queue_unplugged+0x78/0xb0
> [276962.652171]  [<ffffffff815793a4>] schedule+0x24/0x70
> [276962.652178]  [<ffffffff8157948c>] io_schedule+0x9c/0xf0
> [276962.652187]  [<ffffffff811011a9>] sleep_on_page+0x9/0x10
> [276962.652194]  [<ffffffff815778ca>] __wait_on_bit+0x5a/0x90
> [276962.652200]  [<ffffffff811011a0>] ? __lock_page+0x70/0x70
> [276962.652206]  [<ffffffff8110150f>] wait_on_page_bit+0x6f/0x80
> [276962.652215]  [<ffffffff81067190>] ? autoremove_wake_function+0x40/0x40
> [276962.652224]  [<ffffffff81112ee1>] ? page_evictable+0x11/0x50
> [276962.652231]  [<ffffffff81114e43>] shrink_page_list+0x503/0x790
> [276962.652239]  [<ffffffff8111570b>] shrink_inactive_list+0x1bb/0x570
> [276962.652246]  [<ffffffff81115d5f>] ? shrink_active_list+0x29f/0x340
> [276962.652254]  [<ffffffff81115ef9>] shrink_lruvec+0xf9/0x330
> [276962.652262]  [<ffffffff8111660a>] mem_cgroup_shrink_node_zone+0xda/0x140
> [276962.652274]  [<ffffffff81160c28>] ? mem_cgroup_reclaimable+0x108/0x150
> [276962.652282]  [<ffffffff81163382>] mem_cgroup_soft_reclaim+0xb2/0x140
> [276962.652291]  [<ffffffff811634af>] mem_cgroup_soft_limit_reclaim+0x9f/0x270
> [276962.652298]  [<ffffffff81116418>] shrink_zones+0x108/0x220
> [276962.652305]  [<ffffffff8111776a>] do_try_to_free_pages+0x8a/0x360
> [276962.652313]  [<ffffffff81117d90>] try_to_free_pages+0x130/0x180
> [276962.652323]  [<ffffffff8110a2fe>] __alloc_pages_slowpath+0x39e/0x790
> [276962.652332]  [<ffffffff8110a8ea>] __alloc_pages_nodemask+0x1fa/0x210
> [276962.652343]  [<ffffffff81151c72>] kmem_getpages+0x62/0x1d0
> [276962.652351]  [<ffffffff81153869>] fallback_alloc+0x189/0x250
> [276962.652359]  [<ffffffff8115360d>] ____cache_alloc_node+0x8d/0x160
> [276962.652367]  [<ffffffff81153e51>] __kmalloc+0x281/0x290
> [276962.652490]  [<ffffffffa02c6e97>] ? kmem_alloc+0x77/0xe0 [xfs]
> [276962.652540]  [<ffffffffa02c6e97>] kmem_alloc+0x77/0xe0 [xfs]
> [276962.652588]  [<ffffffffa02c6e97>] ? kmem_alloc+0x77/0xe0 [xfs]
> [276962.652653]  [<ffffffffa030a334>] xfs_inode_item_format_extents+0x54/0x100 [xfs]
> [276962.652714]  [<ffffffffa030a63a>] xfs_inode_item_format+0x25a/0x4f0 [xfs]
> [276962.652774]  [<ffffffffa03081a0>] xlog_cil_prepare_log_vecs+0xa0/0x170 [xfs]
> [276962.652834]  [<ffffffffa03082a8>] xfs_log_commit_cil+0x38/0x1c0 [xfs]
> [276962.652894]  [<ffffffffa0303304>] xfs_trans_commit+0x74/0x260 [xfs]
> [276962.652935]  [<ffffffffa02ac70b>] xfs_setfilesize+0x12b/0x130 [xfs]
> [276962.652947]  [<ffffffff81076bd0>] ? __migrate_task+0x150/0x150
> [276962.652988]  [<ffffffffa02ac985>] xfs_end_io+0x75/0xc0 [xfs]
> [276962.652997]  [<ffffffff8105e934>] process_one_work+0x1b4/0x380

... is running IO completion work and trying to commit a transaction
that is blocked in memory allocation which is waiting for IO
completion. It's disappeared up it's own fundamental orifice.

Ok, this has absolutely nothing to do with the LRU changes - this is
a pre-existing XFS/mm interaction problem from around 3.2. The
question is now this: how the hell do I get memory allocation to not
block waiting on IO completion here? This is already being done in
GFP_NOFS allocation context here....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
