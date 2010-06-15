Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1FF746B0245
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 10:51:55 -0400 (EDT)
Date: Tue, 15 Jun 2010 15:51:34 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC PATCH 0/6] Do not call ->writepage[s] from direct reclaim
	and use a_ops->writepages() where possible
Message-ID: <20100615145134.GM26788@csn.ul.ie>
References: <1275987745-21708-1-git-send-email-mel@csn.ul.ie> <20100615140011.GD28052@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100615140011.GD28052@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 15, 2010 at 04:00:11PM +0200, Andrea Arcangeli wrote:
> Hi Mel,
> 
> I know lots of people doesn't like direct reclaim,

It's not direct reclaim that is the problem per-se, it's direct reclaim
calling writepage and splicing two potentially deep call chains
together.

> but I personally do
> and I think if memory pressure is hard enough we should eventually
> enter direct reclaim full force including ->writepage to avoid false
> positive OOM failures.

Be that as it may, filesystems that have deep call paths for their
->writepage are ignoring both kswapd and direct reclaim so on XFS and
btrfs for example, this "full force" effect is not being reached.

> Transparent hugepage allocation in fact won't
> even wakeup kswapd that would be insist to create hugepages and shrink
> an excessive amount of memory (especially before memory compaction was
> merged, it shall be tried again but if memory compaction fails in
> kswapd context, definitely kswapd should immediately stop and not go
> ahead trying the create hugepages the blind way, kswapd
> order-awareness the blind way is surely detrimental and pointless).
> 

kswapd does end up freeing a lot of memory in response to lumpy reclaim
because it also tries to restore watermarks for a high-order page. This
is disruptive to the system and something I'm going to revisit but it's
a separate topic for another discussion. I can see why transparent
hugepage support would not want this disruptive effect to occur where as
it might make sense when resizing the hugepage pool.

> When memory pressure is low, not going into ->writepage may be
> beneficial from latency prospective too. (but again it depends how
> much it matters to go in LRU and how beneficial is the cache, to know
> if it's worth taking clean cache away even if hotter than dirty cache)
> 
> About the stack overflow did you ever got any stack-debug error?

Not an error. Got a report from Dave Chinner though and it's what kicked
off this whole routine in the first place. I've been recording stack
usage figures but not reporting them. In reclaim I'm getting to about 5K
deep but this was on simple storage and XFS was ignoring attempts for
reclaim to writeback.

http://lkml.org/lkml/2010/4/13/121

Here is one my my own stack traces though

        Depth    Size   Location    (49 entries)
        -----    ----   --------
  0)     5064     304   get_page_from_freelist+0x2e4/0x722
  1)     4760     240   __alloc_pages_nodemask+0x15f/0x6a7
  2)     4520      48   kmem_getpages+0x61/0x12c
  3)     4472      96   cache_grow+0xca/0x272
  4)     4376      80   cache_alloc_refill+0x1d4/0x226
  5)     4296      64   kmem_cache_alloc+0x129/0x1bc
  6)     4232      16   mempool_alloc_slab+0x16/0x18
  7)     4216     144   mempool_alloc+0x56/0x104
  8)     4072      16   scsi_sg_alloc+0x48/0x4a [scsi_mod]
  9)     4056      96   __sg_alloc_table+0x58/0xf8
 10)     3960      32   scsi_init_sgtable+0x37/0x8f [scsi_mod]
 11)     3928      32   scsi_init_io+0x24/0xce [scsi_mod]
 12)     3896      48   scsi_setup_fs_cmnd+0xbc/0xc4 [scsi_mod]
 13)     3848     144   sd_prep_fn+0x1d3/0xc13 [sd_mod]
 14)     3704      64   blk_peek_request+0xe2/0x1a6
 15)     3640      96   scsi_request_fn+0x87/0x522 [scsi_mod]
 16)     3544      32   __blk_run_queue+0x88/0x14b
 17)     3512      48   elv_insert+0xb7/0x254
 18)     3464      48   __elv_add_request+0x9f/0xa7
 19)     3416     128   __make_request+0x3f4/0x476
 20)     3288     192   generic_make_request+0x332/0x3a4
 21)     3096      64   submit_bio+0xc4/0xcd
 22)     3032      80   _xfs_buf_ioapply+0x222/0x252 [xfs]
 23)     2952      48   xfs_buf_iorequest+0x84/0xa1 [xfs]
 24)     2904      32   xlog_bdstrat+0x47/0x4d [xfs]
 25)     2872      64   xlog_sync+0x21a/0x329 [xfs]
 26)     2808      48   xlog_state_release_iclog+0x9b/0xa8 [xfs]
 27)     2760     176   xlog_write+0x356/0x506 [xfs]
 28)     2584      96   xfs_log_write+0x5a/0x86 [xfs]
 29)     2488     368   xfs_trans_commit_iclog+0x165/0x2c3 [xfs]
 30)     2120      80   _xfs_trans_commit+0xd8/0x20d [xfs]
 31)     2040     240   xfs_iomap_write_allocate+0x247/0x336 [xfs]
 32)     1800     144   xfs_iomap+0x31a/0x345 [xfs]
 33)     1656      48   xfs_map_blocks+0x3c/0x40 [xfs]
 34)     1608     256   xfs_page_state_convert+0x2c4/0x597 [xfs]
 35)     1352      64   xfs_vm_writepage+0xf5/0x12f [xfs]
 36)     1288      32   __writepage+0x17/0x34
 37)     1256     288   write_cache_pages+0x1f3/0x2f8
 38)      968      16   generic_writepages+0x24/0x2a
 39)      952      64   xfs_vm_writepages+0x4f/0x5c [xfs]
 40)      888      16   do_writepages+0x21/0x2a
 41)      872      48   writeback_single_inode+0xd8/0x2f4
 42)      824     112   writeback_inodes_wb+0x41a/0x51e
 43)      712     176   wb_writeback+0x13d/0x1b7
 44)      536     128   wb_do_writeback+0x150/0x167
 45)      408      80   bdi_writeback_task+0x43/0x117
 46)      328      48   bdi_start_fn+0x76/0xd5
 47)      280      96   kthread+0x82/0x8a
 48)      184     184   kernel_thread_helper+0x4/0x10

XFS as you can see is quite deep there. Now consider if
get_page_from_freelist() there had entered direct reclaim and then tried
to writeback a page. That's the problem that is being worried about.


> We've
> plenty of instrumentation and ->writepage definitely runs with irq
> enable, so if there's any issue, it can't possibly be unnoticed. The
> worry about stack overflow shall be backed by numbers.
> 
> You posted lots of latency numbers (surely latency will improve but
> it's only safe approach on light memory pressure, on heavy pressure
> it'll early-oom not to call ->writepage, and if cache is very
> important and system has little ram, not going in lru order may also
> screw fs-cache performance),

I also haven't been able to trigger a new OOM as a result of the patch
but maybe I'm missing something. To trigger an OOM, the bulk of the LRU
would have to be dirty and the direct reclaimer making no further
progress but if the bulk of the LRU has been dirtied like this, are we
not already in trouble?

We could have it that direct reclaimers kick the flusher threads when it
counters dirty pages and goes to sleep but this will increase latency
and considering the number of dirty pages direct reclaimers should be
seeing, I'm not sure it's necessary.

> but I didn't see any max-stack usage hard
> numbers, to back the claim that we're going to overflow.
> 

I hadn't posted them because they had been posted previously and I
didn't think they were that interesting as such because it wasn't being
disputed.

> In any case I'd prefer to be able to still call ->writepage if memory
> pressure is high (at some point when priority going down and
> collecting clean cache doesn't still satisfy the allocation),

Well, kswapd is still writing pages if the pressure is high enough that
the flusher threads are not doing it and a direct reclaimer will wait on
congestion_wait() if the pressure gets high enough (PRIORITY < 2).

> during
> allocations in direct reclaim and increase the THREAD_SIZE than doing
> this purely for stack reasons as the VM will lose reliability if we
> forbid ->writepage at all in direct reclaim.

Well, we've lost that particular reliability already on btrfs and xfs
because they are ignoring the VM and increasing THREAD_SIZE would
increase the order used for stack allocations which causes problems of
its own.

The VM would lose a lot of reliability if we weren't throttling on pages
being dirtied in the fault path but because we are doing that, I don't
currently believe we are losing reliability by not writing back pages in
direct reclaim.

> Throttling on kswapd is
> possible but it's probably less efficient and on the stack we know
> exactly which kind of memory we should allocate, kswapd doesn't and it
> works global.
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
