Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id DCE706B004D
	for <linux-mm@kvack.org>; Thu, 22 Nov 2012 03:30:58 -0500 (EST)
Date: Thu, 22 Nov 2012 17:31:11 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: Lockdep complain for zram
Message-ID: <20121122083110.GC5121@bbox>
References: <20121121083737.GB5121@bbox>
 <50AD1829.7050709@vflare.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50AD1829.7050709@vflare.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nitin Gupta <ngupta@vflare.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@cs.helsinki.fi>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

Hi Nitin,

On Wed, Nov 21, 2012 at 10:06:33AM -0800, Nitin Gupta wrote:
> On 11/21/2012 12:37 AM, Minchan Kim wrote:
> >Hi alls,
> >
> >Today, I saw below complain of lockdep.
> >As a matter of fact, I knew it long time ago but forgot that.
> >The reason lockdep complains is that now zram uses GFP_KERNEL
> >in reclaim path(ex, __zram_make_request) :(
> >I can fix it via replacing GFP_KERNEL with GFP_NOIO.
> >But more big problem is vzalloc in zram_init_device which calls GFP_KERNEL.
> >Of course, I can change it with __vmalloc which can receive gfp_t.
> >But still we have a problem. Althoug __vmalloc can handle gfp_t, it calls
> >allocation of GFP_KERNEL. That's why I sent the patch.
> >https://lkml.org/lkml/2012/4/23/77
> >Since then, I forgot it, saw the bug today and poped the question again.
> >
> >Yes. Fundamental problem is utter crap API vmalloc.
> >If we can fix it, everyone would be happy. But life isn't simple like seeing
> >my thread of the patch.
> >
> >So next option is to move zram_init_device into setting disksize time.
> >But it makes unnecessary metadata waste until zram is used really(That's why
> >Nitin move zram_init_device from disksize setting time to make_request) and
> >it makes user should set the disksize before using, which are behavior change.
> >
> >I would like to clean up this issue before promoting because it might change
> >usage behavior.
> >
> >Do you have any idea?
> >
> 
> Maybe we can alloc_vm_area() right on device creation in
> create_device() assuming the default disksize. If user explicitly
> sets the disksize, this vm area is deallocated and a new one is
> allocated based on the new disksize.  When the device is reset, we
> should only free physical pages allocated for the table and the
> virtual area should be set back as if disksize is set to the
> default.
> 
> At the device init time, all the pages can be allocated with
> GFP_NOIO | __GPF_HIGHMEM and since the VM area is preallocated,
> map_vm_area() will not hit any of those page-table allocations with
> GFP_KERNEL.
> 
> Other allocations made directly from zram, for instance in the
> partial I/O case, should also be changed to GFP_NOIO |
> __GFP_HIGHMEM.
> 

Yes. It's a good idea and actually I thought about it.
My concern about that approach is following as.

1) User of zram normally do mkfs.xxx or mkswap before using
   the zram block device(ex, normally, do it at booting time)
   It ends up allocating such metadata of zram before real usage so
   benefit of lazy initialzation would be mitigated.

2) Some user want to use zram when memory pressure is high.(ie, load zram
   dynamically, NOT booting time). It does make sense because people don't
   want to waste memory until memory pressure is high(ie, where zram is really
   helpful time). In this case, lazy initialzation could be failed easily
   because we will use GFP_NOIO instead of GFP_KERNEL due to swap use-case.
   So the benefit of lazy initialzation would be mitigated, too.

3) Current zram's documenation is wrong.
   Set Disksize isn't optional when we use zram firstly.
   Once user set disksize, it could be optional, but NOT optional
   at first usage time. It's very odd behavior. So I think user set to disksizes
   before using is more safe and clear.

So my suggestion is following as.

 * Let's change disksize setting to MUST before using for consistent behavior.
 * When user set to disksize, let's allocate metadata all at once.
   4K : 12 byte(64bit) -> 64G : 192M so 0.3% isn't big overhead.
   If insane user use such big zram device up to 20, it could consume 6% of ram
   but efficieny of zram will cover the waste.
 * If someone has a concern about this, let's guide for him set to disksize
   right before zram using.

What do you think about it?


> Thanks,
> Nitin
> 
> >============ 8< ==============
> >
> >
> >[  335.772277] =================================
> >[  335.772615] [ INFO: inconsistent lock state ]
> >[  335.772955] 3.7.0-rc6 #162 Tainted: G         C
> >[  335.773320] ---------------------------------
> >[  335.773663] inconsistent {RECLAIM_FS-ON-W} -> {IN-RECLAIM_FS-R} usage.
> >[  335.774170] kswapd0/23 [HC0[0]:SC0[0]:HE1:SE1] takes:
> >[  335.774564]  (&zram->init_lock){+++++-}, at: [<ffffffffa0009d0a>] zram_make_request+0x4a/0x260 [zram]
> >[  335.775321] {RECLAIM_FS-ON-W} state was registered at:
> >[  335.775716]   [<ffffffff81099532>] mark_held_locks+0x82/0x130
> >[  335.776009]   [<ffffffff81099c47>] lockdep_trace_alloc+0x67/0xc0
> >[  335.776009]   [<ffffffff811189d4>] __alloc_pages_nodemask+0x94/0xa00
> >[  335.776009]   [<ffffffff81152806>] alloc_pages_current+0xb6/0x120
> >[  335.776009]   [<ffffffff811143d4>] __get_free_pages+0x14/0x50
> >[  335.776009]   [<ffffffff81157dff>] kmalloc_order_trace+0x3f/0xf0
> >[  335.776009]   [<ffffffffa0009b1b>] zram_init_device+0x7b/0x220 [zram]
> >[  335.776009]   [<ffffffffa0009f0a>] zram_make_request+0x24a/0x260 [zram]
> >[  335.776009]   [<ffffffff81299d8a>] generic_make_request+0xca/0x100
> >[  335.776009]   [<ffffffff81299e3b>] submit_bio+0x7b/0x160
> >[  335.776009]   [<ffffffff81197b92>] submit_bh+0xf2/0x120
> >[  335.776009]   [<ffffffff8119b855>] block_read_full_page+0x235/0x3a0
> >[  335.776009]   [<ffffffff8119efc8>] blkdev_readpage+0x18/0x20
> >[  335.776009]   [<ffffffff8111c107>] __do_page_cache_readahead+0x2c7/0x2d0
> >[  335.776009]   [<ffffffff8111c249>] force_page_cache_readahead+0x79/0xb0
> >[  335.776009]   [<ffffffff8111c683>] page_cache_sync_readahead+0x43/0x50
> >[  335.776009]   [<ffffffff81111490>] generic_file_aio_read+0x4f0/0x760
> >[  335.776009]   [<ffffffff8119ffbb>] blkdev_aio_read+0xbb/0xf0
> >[  335.776009]   [<ffffffff811661f3>] do_sync_read+0xa3/0xe0
> >[  335.776009]   [<ffffffff81166910>] vfs_read+0xb0/0x180
> >[  335.776009]   [<ffffffff81166a32>] sys_read+0x52/0xa0
> >[  335.776009]   [<ffffffff8155a982>] system_call_fastpath+0x16/0x1b
> >[  335.776009] irq event stamp: 97589
> >[  335.776009] hardirqs last  enabled at (97589): [<ffffffff812b3374>] throtl_update_dispatch_stats+0x94/0xf0
> >[  335.776009] hardirqs last disabled at (97588): [<ffffffff812b332d>] throtl_update_dispatch_stats+0x4d/0xf0
> >[  335.776009] softirqs last  enabled at (67416): [<ffffffff81046c59>] __do_softirq+0x139/0x280
> >[  335.776009] softirqs last disabled at (67395): [<ffffffff8155bb0c>] call_softirq+0x1c/0x30
> >[  335.776009]
> >[  335.776009] other info that might help us debug this:
> >[  335.776009]  Possible unsafe locking scenario:
> >[  335.776009]
> >[  335.776009]        CPU0
> >[  335.776009]        ----
> >[  335.776009]   lock(&zram->init_lock);
> >[  335.776009]   <Interrupt>
> >[  335.776009]     lock(&zram->init_lock);
> >[  335.776009]
> >[  335.776009]  *** DEADLOCK ***
> >[  335.776009]
> >[  335.776009] no locks held by kswapd0/23.
> >[  335.776009]
> >[  335.776009] stack backtrace:
> >[  335.776009] Pid: 23, comm: kswapd0 Tainted: G         C   3.7.0-rc6 #162
> >[  335.776009] Call Trace:
> >[  335.776009]  [<ffffffff81547ff7>] print_usage_bug+0x1f5/0x206
> >[  335.776009]  [<ffffffff8100f90f>] ? save_stack_trace+0x2f/0x50
> >[  335.776009]  [<ffffffff81096a65>] mark_lock+0x295/0x2f0
> >[  335.776009]  [<ffffffff81095e90>] ? print_irq_inversion_bug.part.37+0x1f0/0x1f0
> >[  335.776009]  [<ffffffff812b4af8>] ? blk_throtl_bio+0x88/0x630
> >[  335.776009]  [<ffffffff81097024>] __lock_acquire+0x564/0x1c00
> >[  335.776009]  [<ffffffff810996e5>] ? trace_hardirqs_on_caller+0x105/0x190
> >[  335.776009]  [<ffffffff812b4e32>] ? blk_throtl_bio+0x3c2/0x630
> >[  335.776009]  [<ffffffff812b4af8>] ? blk_throtl_bio+0x88/0x630
> >[  335.776009]  [<ffffffff812a101c>] ? create_task_io_context+0xdc/0x150
> >[  335.776009]  [<ffffffff812a101c>] ? create_task_io_context+0xdc/0x150
> >[  335.776009]  [<ffffffffa0009d0a>] ? zram_make_request+0x4a/0x260 [zram]
> >[  335.776009]  [<ffffffff81098c85>] lock_acquire+0x85/0x130
> >[  335.776009]  [<ffffffffa0009d0a>] ? zram_make_request+0x4a/0x260 [zram]
> >[  335.776009]  [<ffffffff8154f87c>] down_read+0x4c/0x61
> >[  335.776009]  [<ffffffffa0009d0a>] ? zram_make_request+0x4a/0x260 [zram]
> >[  335.776009]  [<ffffffff81299ac2>] ? generic_make_request_checks+0x222/0x420
> >[  335.776009]  [<ffffffff8111a4fe>] ? test_set_page_writeback+0x6e/0x1a0
> >[  335.776009]  [<ffffffffa0009d0a>] zram_make_request+0x4a/0x260 [zram]
> >[  335.776009]  [<ffffffff81299d8a>] generic_make_request+0xca/0x100
> >[  335.776009]  [<ffffffff81299e3b>] submit_bio+0x7b/0x160
> >[  335.776009]  [<ffffffff81119423>] ? account_page_writeback+0x13/0x20
> >[  335.776009]  [<ffffffff8111a585>] ? test_set_page_writeback+0xf5/0x1a0
> >[  335.776009]  [<ffffffff81148aa9>] swap_writepage+0x1b9/0x240
> >[  335.776009]  [<ffffffff81149bf5>] ? __swap_duplicate+0x65/0x170
> >[  335.776009]  [<ffffffff8112715a>] ? shmem_writepage+0x17a/0x2f0
> >[  335.776009]  [<ffffffff8112715a>] ? shmem_writepage+0x17a/0x2f0
> >[  335.776009]  [<ffffffff8154f411>] ? __mutex_unlock_slowpath+0xd1/0x160
> >[  335.776009]  [<ffffffff810996e5>] ? trace_hardirqs_on_caller+0x105/0x190
> >[  335.776009]  [<ffffffff8109977d>] ? trace_hardirqs_on+0xd/0x10
> >[  335.776009]  [<ffffffff81127195>] shmem_writepage+0x1b5/0x2f0
> >[  335.776009]  [<ffffffff81122b96>] shrink_page_list+0x516/0x9a0
> >[  335.776009]  [<ffffffff8111ca20>] ? __activate_page+0x150/0x150
> >[  335.776009]  [<ffffffff811235c7>] shrink_inactive_list+0x1f7/0x3f0
> >[  335.776009]  [<ffffffff81123f05>] shrink_lruvec+0x435/0x540
> >[  335.776009]  [<ffffffff81065050>] ? __init_waitqueue_head+0x60/0x60
> >[  335.776009]  [<ffffffff81125093>] kswapd+0x703/0xc80
> >[  335.776009]  [<ffffffff81551dd0>] ? _raw_spin_unlock_irq+0x30/0x50
> >[  335.776009]  [<ffffffff81065050>] ? __init_waitqueue_head+0x60/0x60
> >[  335.776009]  [<ffffffff81124990>] ? try_to_free_pages+0x6f0/0x6f0
> >[  335.776009]  [<ffffffff810646ea>] kthread+0xea/0xf0
> >[  335.776009]  [<ffffffff81064600>] ? flush_kthread_work+0x1a0/0x1a0
> >[  335.776009]  [<ffffffff8155a8dc>] ret_from_fork+0x7c/0xb0
> >[  335.776009]  [<ffffffff81064600>] ? flush_kthread_work+0x1a0/0x1a0
> >
> >
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
