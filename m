Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 981416B004A
	for <linux-mm@kvack.org>; Thu, 14 Jul 2011 22:22:36 -0400 (EDT)
Date: Fri, 15 Jul 2011 12:22:26 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 1/5] mm: vmscan: Do not writeback filesystem pages in
 direct reclaim
Message-ID: <20110715022226.GD31294@dastard>
References: <1310567487-15367-1-git-send-email-mgorman@suse.de>
 <1310567487-15367-2-git-send-email-mgorman@suse.de>
 <20110714103801.83e10fdb.kamezawa.hiroyu@jp.fujitsu.com>
 <20110714044643.GA3203@infradead.org>
 <20110714134634.4a7a15c8.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110714134634.4a7a15c8.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Christoph Hellwig <hch@infradead.org>, Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, XFS <xfs@oss.sgi.com>, Johannes Weiner <jweiner@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>

On Thu, Jul 14, 2011 at 01:46:34PM +0900, KAMEZAWA Hiroyuki wrote:
> On Thu, 14 Jul 2011 00:46:43 -0400
> Christoph Hellwig <hch@infradead.org> wrote:
> 
> > On Thu, Jul 14, 2011 at 10:38:01AM +0900, KAMEZAWA Hiroyuki wrote:
> > > > +			/*
> > > > +			 * Only kswapd can writeback filesystem pages to
> > > > +			 * avoid risk of stack overflow
> > > > +			 */
> > > > +			if (page_is_file_cache(page) && !current_is_kswapd()) {
> > > > +				inc_zone_page_state(page, NR_VMSCAN_WRITE_SKIP);
> > > > +				goto keep_locked;
> > > > +			}
> > > > +
> > > 
> > > 
> > > This will cause tons of memcg OOM kill because we have no help of kswapd (now).
> > 
> > XFS and btrfs already disable writeback from memcg context, as does ext4
> > for the typical non-overwrite workloads, and none has fallen apart.
> > 
> > In fact there's no way we can enable them as the memcg calling contexts
> > tend to have massive stack usage.
> > 
> 
> Hmm, XFS/btrfs adds pages to radix-tree in deep stack ?

Here's an example writeback stack trace. Notice how deep it is from
the __writepage() call?

$ cat /sys/kernel/debug/tracing/stack_trace
        Depth    Size   Location    (50 entries)
        -----    ----   --------
  0)     5000      80   enqueue_task_fair+0x63/0x4f0
  1)     4920      48   enqueue_task+0x6a/0x80
  2)     4872      32   activate_task+0x2d/0x40
  3)     4840      32   ttwu_activate+0x21/0x50
  4)     4808      32   T.2130+0x3c/0x60
  5)     4776     112   try_to_wake_up+0x25e/0x2d0
  6)     4664      16   wake_up_process+0x15/0x20
  7)     4648      16   wake_up_worker+0x24/0x30
  8)     4632      16   insert_work+0x6f/0x80
  9)     4616      96   __queue_work+0xf9/0x3f0
 10)     4520      16   queue_work_on+0x25/0x40
 11)     4504      16   queue_work+0x1f/0x30
 12)     4488      16   queue_delayed_work+0x2d/0x40
 13)     4472      32   blk_run_queue_async+0x41/0x60
 14)     4440      64   queue_unplugged+0x8e/0xc0
 15)     4376     112   blk_flush_plug_list+0x1f5/0x240
 16)     4264     176   schedule+0x4c3/0x8b0
 17)     4088     128   schedule_timeout+0x1a5/0x280
 18)     3960     160   wait_for_common+0xdb/0x180
 19)     3800      16   wait_for_completion+0x1d/0x20
 20)     3784      48   xfs_buf_iowait+0x30/0xc0
 21)     3736      32   _xfs_buf_read+0x60/0x70
 22)     3704      48   xfs_buf_read+0xa2/0x100
 23)     3656      80   xfs_trans_read_buf+0x1ef/0x430
 24)     3576      96   xfs_btree_read_buf_block+0x5e/0xd0
 25)     3480      96   xfs_btree_lookup_get_block+0x83/0xf0
 26)     3384     176   xfs_btree_lookup+0xd7/0x490
 27)     3208      16   xfs_alloc_lookup_eq+0x19/0x20
 28)     3192     112   xfs_alloc_fixup_trees+0x2b5/0x350
 29)     3080     224   xfs_alloc_ag_vextent_near+0x631/0xb60
 30)     2856      32   xfs_alloc_ag_vextent+0xd5/0x100
 31)     2824      96   xfs_alloc_vextent+0x2a4/0x5f0
 32)     2728     256   xfs_bmap_btalloc+0x257/0x720
 33)     2472      16   xfs_bmap_alloc+0x21/0x40
 34)     2456     432   xfs_bmapi+0x9b7/0x1150
 35)     2024     192   xfs_iomap_write_allocate+0x17d/0x350
 36)     1832     144   xfs_map_blocks+0x1e2/0x270
 37)     1688     208   xfs_vm_writepage+0x19f/0x500
 38)     1480      32   __writepage+0x17/0x40
 39)     1448     304   write_cache_pages+0x21d/0x4d0
 40)     1144      96   generic_writepages+0x51/0x80
 41)     1048      48   xfs_vm_writepages+0x5d/0x80
 42)     1000      16   do_writepages+0x21/0x40
 43)      984      96   writeback_single_inode+0x10e/0x270
 44)      888      96   writeback_sb_inodes+0xdb/0x1b0
 45)      792     208   wb_writeback+0x1bf/0x420
 46)      584     160   wb_do_writeback+0x9f/0x270
 47)      424     144   bdi_writeback_thread+0xaa/0x270
 48)      280      96   kthread+0x96/0xa0
 49)      184     184   kernel_thread_helper+0x4/0x10

So from ->writepage, there is about 3.5k of stack usage here.  2.5k
of that is in XFS, and the worst I've seen is around 4k before
getting to the IO subsystem, which in the worst case I've seen
consumed 2.5k of stack. IOWs, I've seen stack usage from .writepage
down to IO take over 6k of stack space on x86_64....


Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
