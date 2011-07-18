Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 641456B007E
	for <linux-mm@kvack.org>; Sun, 17 Jul 2011 22:27:35 -0400 (EDT)
Date: Mon, 18 Jul 2011 12:22:26 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 1/5] mm: vmscan: Do not writeback filesystem pages in
 direct reclaim
Message-ID: <20110718022226.GC30254@dastard>
References: <1310567487-15367-1-git-send-email-mgorman@suse.de>
 <1310567487-15367-2-git-send-email-mgorman@suse.de>
 <20110714103801.83e10fdb.kamezawa.hiroyu@jp.fujitsu.com>
 <20110714044643.GA3203@infradead.org>
 <20110714134634.4a7a15c8.kamezawa.hiroyu@jp.fujitsu.com>
 <20110715022226.GD31294@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110715022226.GD31294@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Christoph Hellwig <hch@infradead.org>, Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, XFS <xfs@oss.sgi.com>, Johannes Weiner <jweiner@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>

On Fri, Jul 15, 2011 at 12:22:26PM +1000, Dave Chinner wrote:
> On Thu, Jul 14, 2011 at 01:46:34PM +0900, KAMEZAWA Hiroyuki wrote:
> > On Thu, 14 Jul 2011 00:46:43 -0400
> > Christoph Hellwig <hch@infradead.org> wrote:
> > 
> > > On Thu, Jul 14, 2011 at 10:38:01AM +0900, KAMEZAWA Hiroyuki wrote:
> > > > > +			/*
> > > > > +			 * Only kswapd can writeback filesystem pages to
> > > > > +			 * avoid risk of stack overflow
> > > > > +			 */
> > > > > +			if (page_is_file_cache(page) && !current_is_kswapd()) {
> > > > > +				inc_zone_page_state(page, NR_VMSCAN_WRITE_SKIP);
> > > > > +				goto keep_locked;
> > > > > +			}
> > > > > +
> > > > 
> > > > 
> > > > This will cause tons of memcg OOM kill because we have no help of kswapd (now).
> > > 
> > > XFS and btrfs already disable writeback from memcg context, as does ext4
> > > for the typical non-overwrite workloads, and none has fallen apart.
> > > 
> > > In fact there's no way we can enable them as the memcg calling contexts
> > > tend to have massive stack usage.
> > > 
> > 
> > Hmm, XFS/btrfs adds pages to radix-tree in deep stack ?
> 
> Here's an example writeback stack trace. Notice how deep it is from
> the __writepage() call?
....
> 
> So from ->writepage, there is about 3.5k of stack usage here.  2.5k
> of that is in XFS, and the worst I've seen is around 4k before
> getting to the IO subsystem, which in the worst case I've seen
> consumed 2.5k of stack. IOWs, I've seen stack usage from .writepage
> down to IO take over 6k of stack space on x86_64....

BTW, here's a stack frame that indicates swap IO:

dave@test-4:~$ cat /sys/kernel/debug/tracing/stack_trace
        Depth    Size   Location    (46 entries)
        -----    ----   --------
  0)     5080      40   zone_statistics+0xad/0xc0
  1)     5040     272   get_page_from_freelist+0x2ad/0x7e0
  2)     4768     288   __alloc_pages_nodemask+0x133/0x7b0
  3)     4480      48   kmem_getpages+0x62/0x160
  4)     4432     112   cache_grow+0x2d1/0x300
  5)     4320      80   cache_alloc_refill+0x219/0x260
  6)     4240      64   kmem_cache_alloc+0x182/0x190
  7)     4176      16   mempool_alloc_slab+0x15/0x20
  8)     4160     144   mempool_alloc+0x63/0x140
  9)     4016      16   scsi_sg_alloc+0x4c/0x60
 10)     4000     112   __sg_alloc_table+0x66/0x140
 11)     3888      32   scsi_init_sgtable+0x33/0x90
 12)     3856      48   scsi_init_io+0x31/0xc0
 13)     3808      32   scsi_setup_fs_cmnd+0x79/0xe0
 14)     3776     112   sd_prep_fn+0x150/0xa90
 15)     3664      64   blk_peek_request+0xc7/0x230
 16)     3600      96   scsi_request_fn+0x68/0x500
 17)     3504      16   __blk_run_queue+0x1b/0x20
 18)     3488      96   __make_request+0x2cb/0x310
 19)     3392     192   generic_make_request+0x26d/0x500
 20)     3200      96   submit_bio+0x64/0xe0
 21)     3104      48   swap_writepage+0x83/0xd0
 22)     3056     112   pageout+0x122/0x2f0
 23)     2944     192   shrink_page_list+0x458/0x5f0
 24)     2752     192   shrink_inactive_list+0x1ec/0x410
 25)     2560     224   shrink_zone+0x468/0x500
 26)     2336     144   do_try_to_free_pages+0x2b7/0x3f0
 27)     2192     176   try_to_free_pages+0xa4/0x120
 28)     2016     288   __alloc_pages_nodemask+0x43f/0x7b0
 29)     1728      48   kmem_getpages+0x62/0x160
 30)     1680     128   fallback_alloc+0x192/0x240
 31)     1552      96   ____cache_alloc_node+0x9a/0x170
 32)     1456      16   __kmalloc+0x17d/0x200
 33)     1440     128   kmem_alloc+0x77/0xf0
 34)     1312     128   xfs_log_commit_cil+0x95/0x3d0
 35)     1184      96   _xfs_trans_commit+0x1e9/0x2a0
 36)     1088     208   xfs_create+0x57a/0x640
 37)      880      96   xfs_vn_mknod+0xa1/0x1b0
 38)      784      16   xfs_vn_create+0x10/0x20
 39)      768      64   vfs_create+0xb1/0xe0
 40)      704      96   do_last+0x5f5/0x770
 41)      608     144   path_openat+0xd5/0x400
 42)      464     224   do_filp_open+0x49/0xa0
 43)      240      96   do_sys_open+0x107/0x1e0
 44)      144      16   sys_open+0x20/0x30
 45)      128     128   system_call_fastpath+0x16/0x1b


That's pretty damn bad. From kmem_alloc to the top of the stack is
more than 3.5k through the direct reclaim swap IO path. That, to me,
kind of indicates that even doing swap IO on dirty anonymous pages
from direct reclaim risks overflowing the 8k stack on x86_64....

Umm, hold on a second, WTF is my standard create-lots-of-zero-length
inodes-in-parallel doing swapping? Oh, shit, it's also running about
50% slower (50-60k files/s instead of 110-120l files/s)....

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
