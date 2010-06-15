Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id E88576B01CB
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 13:37:39 -0400 (EDT)
Date: Tue, 15 Jun 2010 18:28:39 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC PATCH 0/6] Do not call ->writepage[s] from direct reclaim
 and use a_ops->writepages() where possible
Message-ID: <20100615162839.GI28052@random.random>
References: <1275987745-21708-1-git-send-email-mel@csn.ul.ie>
 <20100615140011.GD28052@random.random>
 <20100615145134.GM26788@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100615145134.GM26788@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 15, 2010 at 03:51:34PM +0100, Mel Gorman wrote:
> kswapd does end up freeing a lot of memory in response to lumpy reclaim
> because it also tries to restore watermarks for a high-order page. This
> is disruptive to the system and something I'm going to revisit but it's
> a separate topic for another discussion. I can see why transparent
> hugepage support would not want this disruptive effect to occur where as
> it might make sense when resizing the hugepage pool.

on a related topic, I also had to nuke lumpy reclaim, it's pointless
with mem compaction and it halts the system and makes it unusable
under all normal loads unless allocations are run like hugetlbfs does
(just all at once at app startup and never again, so the hang is
limited to the first minute when app starts). With a dynamic approach
like THP systems becomes unusable. Nothing should fail when large
order allocation fails (I mean the large order that activates lumpy
reclaims) so there's no point to grind the system to unusable state in
order to generate those large order pages, considering lumpy reclaim
effectives is next to irrelevant compared to compaction, and in turn
not worth it.

>         Depth    Size   Location    (49 entries)
>         -----    ----   --------
>   0)     5064     304   get_page_from_freelist+0x2e4/0x722
>   1)     4760     240   __alloc_pages_nodemask+0x15f/0x6a7
>   2)     4520      48   kmem_getpages+0x61/0x12c
>   3)     4472      96   cache_grow+0xca/0x272
>   4)     4376      80   cache_alloc_refill+0x1d4/0x226
>   5)     4296      64   kmem_cache_alloc+0x129/0x1bc
>   6)     4232      16   mempool_alloc_slab+0x16/0x18
>   7)     4216     144   mempool_alloc+0x56/0x104
>   8)     4072      16   scsi_sg_alloc+0x48/0x4a [scsi_mod]
>   9)     4056      96   __sg_alloc_table+0x58/0xf8
>  10)     3960      32   scsi_init_sgtable+0x37/0x8f [scsi_mod]
>  11)     3928      32   scsi_init_io+0x24/0xce [scsi_mod]
>  12)     3896      48   scsi_setup_fs_cmnd+0xbc/0xc4 [scsi_mod]
>  13)     3848     144   sd_prep_fn+0x1d3/0xc13 [sd_mod]
>  14)     3704      64   blk_peek_request+0xe2/0x1a6
>  15)     3640      96   scsi_request_fn+0x87/0x522 [scsi_mod]
>  16)     3544      32   __blk_run_queue+0x88/0x14b
>  17)     3512      48   elv_insert+0xb7/0x254
>  18)     3464      48   __elv_add_request+0x9f/0xa7
>  19)     3416     128   __make_request+0x3f4/0x476
>  20)     3288     192   generic_make_request+0x332/0x3a4
>  21)     3096      64   submit_bio+0xc4/0xcd
>  22)     3032      80   _xfs_buf_ioapply+0x222/0x252 [xfs]
>  23)     2952      48   xfs_buf_iorequest+0x84/0xa1 [xfs]
>  24)     2904      32   xlog_bdstrat+0x47/0x4d [xfs]
>  25)     2872      64   xlog_sync+0x21a/0x329 [xfs]
>  26)     2808      48   xlog_state_release_iclog+0x9b/0xa8 [xfs]
>  27)     2760     176   xlog_write+0x356/0x506 [xfs]
>  28)     2584      96   xfs_log_write+0x5a/0x86 [xfs]
>  29)     2488     368   xfs_trans_commit_iclog+0x165/0x2c3 [xfs]
>  30)     2120      80   _xfs_trans_commit+0xd8/0x20d [xfs]
>  31)     2040     240   xfs_iomap_write_allocate+0x247/0x336 [xfs]
>  32)     1800     144   xfs_iomap+0x31a/0x345 [xfs]
>  33)     1656      48   xfs_map_blocks+0x3c/0x40 [xfs]
>  34)     1608     256   xfs_page_state_convert+0x2c4/0x597 [xfs]
>  35)     1352      64   xfs_vm_writepage+0xf5/0x12f [xfs]
>  36)     1288      32   __writepage+0x17/0x34
>  37)     1256     288   write_cache_pages+0x1f3/0x2f8
>  38)      968      16   generic_writepages+0x24/0x2a
>  39)      952      64   xfs_vm_writepages+0x4f/0x5c [xfs]
>  40)      888      16   do_writepages+0x21/0x2a
>  41)      872      48   writeback_single_inode+0xd8/0x2f4
>  42)      824     112   writeback_inodes_wb+0x41a/0x51e
>  43)      712     176   wb_writeback+0x13d/0x1b7
>  44)      536     128   wb_do_writeback+0x150/0x167
>  45)      408      80   bdi_writeback_task+0x43/0x117
>  46)      328      48   bdi_start_fn+0x76/0xd5
>  47)      280      96   kthread+0x82/0x8a
>  48)      184     184   kernel_thread_helper+0x4/0x10
> 
> XFS as you can see is quite deep there. Now consider if
> get_page_from_freelist() there had entered direct reclaim and then tried
> to writeback a page. That's the problem that is being worried about.

As said in other email this can't be a problem, 5k is very ok there
and there's zero risk as writepage can't reenter itself or fs would
lockup.

This even the above trace, already shows that 5k is used just for xfs
writepage itself, so that means generic kernel code can't exceed 3k, I
agree it's too risky (at least with xfs, dunno if ext4 also eats ~5k
just for writepage + bio).

> I also haven't been able to trigger a new OOM as a result of the patch
> but maybe I'm missing something. To trigger an OOM, the bulk of the LRU

Well you're throttling and waiting I/O from the kernel thread, so it
should be fully safe and zero risk for OOM regressions, agreed!

But if we make changes to tackle this "risk", I prefer if we allow to
remove the PF_MEMALLOC in ext4_write_inode too.. and we instead allow
it to run when __GFP_FS|__GFP_IO is set.

> I hadn't posted them because they had been posted previously and I
> didn't think they were that interesting as such because it wasn't being
> disputed.

No problem, I didn't notice those prev reports, the links you posted
have been handy to find them more quickly ;), that's surely more than
enough, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
