Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 35B826B024C
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 11:11:16 -0400 (EDT)
Date: Tue, 15 Jun 2010 16:10:40 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC PATCH 0/6] Do not call ->writepage[s] from direct reclaim
	and use a_ops->writepages() where possible
Message-ID: <20100615151040.GN26788@csn.ul.ie>
References: <1275987745-21708-1-git-send-email-mel@csn.ul.ie> <20100615140011.GD28052@random.random> <20100615145134.GM26788@csn.ul.ie> <20100615150800.GP6138@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100615150800.GP6138@laptop>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jun 16, 2010 at 01:08:00AM +1000, Nick Piggin wrote:
> On Tue, Jun 15, 2010 at 03:51:34PM +0100, Mel Gorman wrote:
> > On Tue, Jun 15, 2010 at 04:00:11PM +0200, Andrea Arcangeli wrote:
> > > When memory pressure is low, not going into ->writepage may be
> > > beneficial from latency prospective too. (but again it depends how
> > > much it matters to go in LRU and how beneficial is the cache, to know
> > > if it's worth taking clean cache away even if hotter than dirty cache)
> > > 
> > > About the stack overflow did you ever got any stack-debug error?
> > 
> > Not an error. Got a report from Dave Chinner though and it's what kicked
> > off this whole routine in the first place. I've been recording stack
> > usage figures but not reporting them. In reclaim I'm getting to about 5K
> > deep but this was on simple storage and XFS was ignoring attempts for
> > reclaim to writeback.
> > 
> > http://lkml.org/lkml/2010/4/13/121
> > 
> > Here is one my my own stack traces though
> > 
> >         Depth    Size   Location    (49 entries)
> >         -----    ----   --------
> >   0)     5064     304   get_page_from_freelist+0x2e4/0x722
> >   1)     4760     240   __alloc_pages_nodemask+0x15f/0x6a7
> >   2)     4520      48   kmem_getpages+0x61/0x12c
> >   3)     4472      96   cache_grow+0xca/0x272
> >   4)     4376      80   cache_alloc_refill+0x1d4/0x226
> >   5)     4296      64   kmem_cache_alloc+0x129/0x1bc
> >   6)     4232      16   mempool_alloc_slab+0x16/0x18
> >   7)     4216     144   mempool_alloc+0x56/0x104
> >   8)     4072      16   scsi_sg_alloc+0x48/0x4a [scsi_mod]
> >   9)     4056      96   __sg_alloc_table+0x58/0xf8
> >  10)     3960      32   scsi_init_sgtable+0x37/0x8f [scsi_mod]
> >  11)     3928      32   scsi_init_io+0x24/0xce [scsi_mod]
> >  12)     3896      48   scsi_setup_fs_cmnd+0xbc/0xc4 [scsi_mod]
> >  13)     3848     144   sd_prep_fn+0x1d3/0xc13 [sd_mod]
> >  14)     3704      64   blk_peek_request+0xe2/0x1a6
> >  15)     3640      96   scsi_request_fn+0x87/0x522 [scsi_mod]
> >  16)     3544      32   __blk_run_queue+0x88/0x14b
> >  17)     3512      48   elv_insert+0xb7/0x254
> >  18)     3464      48   __elv_add_request+0x9f/0xa7
> >  19)     3416     128   __make_request+0x3f4/0x476
> >  20)     3288     192   generic_make_request+0x332/0x3a4
> >  21)     3096      64   submit_bio+0xc4/0xcd
> >  22)     3032      80   _xfs_buf_ioapply+0x222/0x252 [xfs]
> >  23)     2952      48   xfs_buf_iorequest+0x84/0xa1 [xfs]
> >  24)     2904      32   xlog_bdstrat+0x47/0x4d [xfs]
> >  25)     2872      64   xlog_sync+0x21a/0x329 [xfs]
> >  26)     2808      48   xlog_state_release_iclog+0x9b/0xa8 [xfs]
> >  27)     2760     176   xlog_write+0x356/0x506 [xfs]
> >  28)     2584      96   xfs_log_write+0x5a/0x86 [xfs]
> >  29)     2488     368   xfs_trans_commit_iclog+0x165/0x2c3 [xfs]
> >  30)     2120      80   _xfs_trans_commit+0xd8/0x20d [xfs]
> >  31)     2040     240   xfs_iomap_write_allocate+0x247/0x336 [xfs]
> >  32)     1800     144   xfs_iomap+0x31a/0x345 [xfs]
> >  33)     1656      48   xfs_map_blocks+0x3c/0x40 [xfs]
> >  34)     1608     256   xfs_page_state_convert+0x2c4/0x597 [xfs]
> >  35)     1352      64   xfs_vm_writepage+0xf5/0x12f [xfs]
> >  36)     1288      32   __writepage+0x17/0x34
> >  37)     1256     288   write_cache_pages+0x1f3/0x2f8
> >  38)      968      16   generic_writepages+0x24/0x2a
> >  39)      952      64   xfs_vm_writepages+0x4f/0x5c [xfs]
> >  40)      888      16   do_writepages+0x21/0x2a
> >  41)      872      48   writeback_single_inode+0xd8/0x2f4
> >  42)      824     112   writeback_inodes_wb+0x41a/0x51e
> >  43)      712     176   wb_writeback+0x13d/0x1b7
> >  44)      536     128   wb_do_writeback+0x150/0x167
> >  45)      408      80   bdi_writeback_task+0x43/0x117
> >  46)      328      48   bdi_start_fn+0x76/0xd5
> >  47)      280      96   kthread+0x82/0x8a
> >  48)      184     184   kernel_thread_helper+0x4/0x10
> > 
> > XFS as you can see is quite deep there. Now consider if
> > get_page_from_freelist() there had entered direct reclaim and then tried
> > to writeback a page. That's the problem that is being worried about.
> 
> It would be a problem because it should be !__GFP_IO at that point so
> something would be seriously broken if it called ->writepage again.
> 

True, ignore this as Christoph's example makes more sense.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
