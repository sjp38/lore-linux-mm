Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9FB4A6B0035
	for <linux-mm@kvack.org>; Thu, 29 May 2014 21:05:46 -0400 (EDT)
Received: by mail-pb0-f51.google.com with SMTP id ma3so1112354pbc.10
        for <linux-mm@kvack.org>; Thu, 29 May 2014 18:05:46 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id ff3si3134243pbd.167.2014.05.29.18.05.44
        for <linux-mm@kvack.org>;
        Thu, 29 May 2014 18:05:45 -0700 (PDT)
Date: Fri, 30 May 2014 10:06:19 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: virtio ring cleanups, which save stack on older gcc
Message-ID: <20140530010619.GP10092@bbox>
References: <87oayh6s3s.fsf@rustcorp.com.au>
 <1401348405-18614-1-git-send-email-rusty@rustcorp.com.au>
 <20140529074117.GI10092@bbox>
 <87fvjs7sge.fsf@rustcorp.com.au>
 <20140529234522.GL10092@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140529234522.GL10092@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Jens Axboe <axboe@kernel.dk>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, "Michael S. Tsirkin" <mst@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Steven Rostedt <rostedt@goodmis.org>

On Fri, May 30, 2014 at 08:45:22AM +0900, Minchan Kim wrote:
> On Thu, May 29, 2014 at 08:38:33PM +0930, Rusty Russell wrote:
> > Minchan Kim <minchan@kernel.org> writes:
> > > Hello Rusty,
> > >
> > > On Thu, May 29, 2014 at 04:56:41PM +0930, Rusty Russell wrote:
> > >> They don't make much difference: the easier fix is use gcc 4.8
> > >> which drops stack required across virtio block's virtio_queue_rq
> > >> down to that kmalloc in virtio_ring from 528 to 392 bytes.
> > >> 
> > >> Still, these (*lightly tested*) patches reduce to 432 bytes,
> > >> even for gcc 4.6.4.  Posted here FYI.
> > >
> > > I am testing with below which was hack for Dave's idea so don't have
> > > a machine to test your patches until tomorrow.
> > > So, I will queue your patches into testing machine tomorrow morning.
> > 
> > More interesting would be updating your compiler to 4.8, I think.
> > Saving <100 bytes on virtio is not going to save you, right?
> 
> But in my report, virtio_ring consumes more than yours.
> As I mentioned other thread to Steven, I don't know why stacktrace report
> vring_add_indirect consumes 376-byte. Apparently, objdump says it didn't
> consume too much so I'd like to test your patches and see the result.
> 
> Thanks.
> 
> [ 1065.604404] kworker/-5766    0d..2 1071625993us : stack_trace_call:  10)     6376     376   vring_add_indirect+0x36/0x200
> [ 1065.604404] kworker/-5766    0d..2 1071625993us : stack_trace_call:  11)     6000     144   virtqueue_add_sgs+0x2e2/0x320
> [ 1065.604404] kworker/-5766    0d..2 1071625993us : stack_trace_call:  12)     5856     288   __virtblk_add_req+0xda/0x1b0
> [ 1065.604404] kworker/-5766    0d..2 1071625993us : stack_trace_call:  13)     5568      96   virtio_queue_rq+0xd3/0x1d0
> 

As you expected, virtio_ring consumes less than before but not enough but
interesting thing is consumption of stack usage of __kmalloc and __slab_alloc
works right in this time. Hmm....

In my previous report,

[ 1065.604404] kworker/-5766    0d..2 1071625992us : stack_trace_call:   6)     6640       8   alloc_pages_current+0x10f/0x1f0
[ 1065.604404] kworker/-5766    0d..2 1071625992us : stack_trace_call:   7)     6632     168   new_slab+0x2c5/0x370
[ 1065.604404] kworker/-5766    0d..2 1071625992us : stack_trace_call:   8)     6464       8   __slab_alloc+0x3a9/0x501
[ 1065.604404] kworker/-5766    0d..2 1071625993us : stack_trace_call:   9)     6456      80   __kmalloc+0x1cb/0x200
[ 1065.604404] kworker/-5766    0d..2 1071625993us : stack_trace_call:  10)     6376     376   vring_add_indirect+0x36/0x200
[ 1065.604404] kworker/-5766    0d..2 1071625993us : stack_trace_call:  11)     6000     144   virtqueue_add_sgs+0x2e2/0x320
[ 1065.604404] kworker/-5766    0d..2 1071625993us : stack_trace_call:  12)     5856     288   __virtblk_add_req+0xda/0x1b0
[ 1065.604404] kworker/-5766    0d..2 1071625993us : stack_trace_call:  13)     5568      96   virtio_queue_rq+0xd3/0x1d0
[ 1065.604404] kworker/-5766    0d..2 1071625994us : stack_trace_call:  14)     5472     128   __blk_mq_run_hw_queue+0x1ef/0x440
[ 1065.604404] kworker/-5766    0d..2 1071625994us : stack_trace_call:  15)     5344      16   blk_mq_run_hw_queue+0x35/0x40

In this time,

[ 2069.135929] kworker/u24:2 (26991) used greatest stack depth: 408 bytes left
[ 2580.413428] ------------[ cut here ]------------
[ 2580.413926] kernel BUG at kernel/trace/trace_stack.c:177!
[ 2580.414479] invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC
[ 2580.415073] Dumping ftrace buffer:
[ 2580.415465] ---------------------------------
[ 2580.415763]    <...>-18634   9d..2 2598341673us : stack_trace_call:         Depth    Size   Location    (49 entries)
[ 2580.415763]         -----    ----   --------
[ 2580.415763]    <...>-18634   9d..2 2598341697us : stack_trace_call:   0)     7280       8   __alloc_pages_nodemask+0x199/0xb20
[ 2580.415763]    <...>-18634   9d..2 2598341698us : stack_trace_call:   1)     7272     352   alloc_pages_current+0x10f/0x1f0
[ 2580.415763]    <...>-18634   9d..2 2598341698us : stack_trace_call:   2)     6920     168   new_slab+0x2c5/0x370
[ 2580.415763]    <...>-18634   9d..2 2598341698us : stack_trace_call:   3)     6752     256   __slab_alloc+0x3a9/0x501
[ 2580.415763]    <...>-18634   9d..2 2598341699us : stack_trace_call:   4)     6496     112   __kmalloc+0x1cb/0x200
[ 2580.415763]    <...>-18634   9d..2 2598341699us : stack_trace_call:   5)     6384      32   alloc_indirect+0x1e/0x50
[ 2580.415763]    <...>-18634   9d..2 2598341699us : stack_trace_call:   6)     6352     112   virtqueue_add_sgs+0xc7/0x300
[ 2580.415763]    <...>-18634   9d..2 2598341699us : stack_trace_call:   7)     6240     288   __virtblk_add_req+0xda/0x1b0
[ 2580.415763]    <...>-18634   9d..2 2598341699us : stack_trace_call:   8)     5952      96   virtio_queue_rq+0xd3/0x1d0
[ 2580.415763]    <...>-18634   9d..2 2598341699us : stack_trace_call:   9)     5856     128   __blk_mq_run_hw_queue+0x1ef/0x440
[ 2580.415763]    <...>-18634   9d..2 2598341700us : stack_trace_call:  10)     5728      16   blk_mq_run_hw_queue+0x35/0x40
[ 2580.415763]    <...>-18634   9d..2 2598341700us : stack_trace_call:  11)     5712      96   blk_mq_insert_requests+0xdb/0x160
[ 2580.415763]    <...>-18634   9d..2 2598341700us : stack_trace_call:  12)     5616     112   blk_mq_flush_plug_list+0x12b/0x140
[ 2580.415763]    <...>-18634   9d..2 2598341700us : stack_trace_call:  13)     5504     112   blk_flush_plug_list+0xc7/0x220
[ 2580.415763]    <...>-18634   9d..2 2598341700us : stack_trace_call:  14)     5392      64   io_schedule_timeout+0x88/0x100
[ 2580.415763]    <...>-18634   9d..2 2598341701us : stack_trace_call:  15)     5328     128   mempool_alloc+0x145/0x170
[ 2580.415763]    <...>-18634   9d..2 2598341701us : stack_trace_call:  16)     5200      96   bio_alloc_bioset+0x10b/0x1d0
[ 2580.415763]    <...>-18634   9d..2 2598341701us : stack_trace_call:  17)     5104      48   get_swap_bio+0x30/0x90
[ 2580.415763]    <...>-18634   9d..2 2598341701us : stack_trace_call:  18)     5056     160   __swap_writepage+0x150/0x230
[ 2580.415763]    <...>-18634   9d..2 2598341701us : stack_trace_call:  19)     4896      32   swap_writepage+0x42/0x90
[ 2580.415763]    <...>-18634   9d..2 2598341701us : stack_trace_call:  20)     4864     320   shrink_page_list+0x676/0xa80
[ 2580.415763]    <...>-18634   9d..2 2598341702us : stack_trace_call:  21)     4544     208   shrink_inactive_list+0x262/0x4e0
[ 2580.415763]    <...>-18634   9d..2 2598341702us : stack_trace_call:  22)     4336     304   shrink_lruvec+0x3e1/0x6a0
[ 2580.415763]    <...>-18634   9d..2 2598341702us : stack_trace_call:  23)     4032      80   shrink_zone+0x3f/0x110
[ 2580.415763]    <...>-18634   9d..2 2598341702us : stack_trace_call:  24)     3952     128   do_try_to_free_pages+0x156/0x4c0
[ 2580.415763]    <...>-18634   9d..2 2598341702us : stack_trace_call:  25)     3824     208   try_to_free_pages+0xf7/0x1e0
[ 2580.415763]    <...>-18634   9d..2 2598341703us : stack_trace_call:  26)     3616     352   __alloc_pages_nodemask+0x783/0xb20
[ 2580.415763]    <...>-18634   9d..2 2598341703us : stack_trace_call:  27)     3264       8   alloc_pages_current+0x10f/0x1f0
[ 2580.415763]    <...>-18634   9d..2 2598341703us : stack_trace_call:  28)     3256     200   __page_cache_alloc+0x13f/0x160
[ 2580.415763]    <...>-18634   9d..2 2598341703us : stack_trace_call:  29)     3056      80   find_or_create_page+0x4c/0xb0
[ 2580.415763]    <...>-18634   9d..2 2598341703us : stack_trace_call:  30)     2976     112   __getblk+0x109/0x2f0
[ 2580.415763]    <...>-18634   9d..2 2598341703us : stack_trace_call:  31)     2864      80   ext4_read_block_bitmap_nowait+0x5e/0x330
[ 2580.415763]    <...>-18634   9d..2 2598341704us : stack_trace_call:  32)     2784     192   ext4_mb_init_cache+0x158/0x780
[ 2580.415763]    <...>-18634   9d..2 2598341704us : stack_trace_call:  33)     2592      80   ext4_mb_load_buddy+0x28a/0x370
[ 2580.415763]    <...>-18634   9d..2 2598341704us : stack_trace_call:  34)     2512     176   ext4_mb_regular_allocator+0x1b7/0x460
[ 2580.415763]    <...>-18634   9d..2 2598341704us : stack_trace_call:  35)     2336     128   ext4_mb_new_blocks+0x458/0x5f0
[ 2580.415763]    <...>-18634   9d..2 2598341704us : stack_trace_call:  36)     2208     256   ext4_ext_map_blocks+0x70b/0x1010
[ 2580.415763]    <...>-18634   9d..2 2598341704us : stack_trace_call:  37)     1952     160   ext4_map_blocks+0x325/0x530
[ 2580.415763]    <...>-18634   9d..2 2598341705us : stack_trace_call:  38)     1792     384   ext4_writepages+0x6d1/0xce0
[ 2580.415763]    <...>-18634   9d..2 2598341705us : stack_trace_call:  39)     1408      16   do_writepages+0x23/0x40
[ 2580.415763]    <...>-18634   9d..2 2598341705us : stack_trace_call:  40)     1392      96   __writeback_single_inode+0x45/0x2e0
[ 2580.415763]    <...>-18634   9d..2 2598341705us : stack_trace_call:  41)     1296     176   writeback_sb_inodes+0x2ad/0x500
[ 2580.415763]    <...>-18634   9d..2 2598341705us : stack_trace_call:  42)     1120      80   __writeback_inodes_wb+0x9e/0xd0
[ 2580.415763]    <...>-18634   9d..2 2598341706us : stack_trace_call:  43)     1040     160   wb_writeback+0x29b/0x350
[ 2580.415763]    <...>-18634   9d..2 2598341706us : stack_trace_call:  44)      880     208   bdi_writeback_workfn+0x11c/0x480
[ 2580.415763]    <...>-18634   9d..2 2598341706us : stack_trace_call:  45)      672     144   process_one_work+0x1d2/0x570
[ 2580.415763]    <...>-18634   9d..2 2598341706us : stack_trace_call:  46)      528     112   worker_thread+0x116/0x370
[ 2580.415763]    <...>-18634   9d..2 2598341706us : stack_trace_call:  47)      416     240   kthread+0xf3/0x110
[ 2580.415763]    <...>-18634   9d..2 2598341706us : stack_trace_call:  48)      176     176   ret_from_fork+0x7c/0xb0
[ 2580.415763] ---------------------------------
[ 2580.415763] Modules linked in:
[ 2580.415763] CPU: 9 PID: 18634 Comm: kworker/u24:1 Not tainted 3.14.0+ #202
[ 2580.415763] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[ 2580.415763] Workqueue: writeback bdi_writeback_workfn (flush-253:0)
[ 2580.415763] task: ffff88001e9ca0e0 ti: ffff880029c52000 task.ti: ffff880029c52000
[ 2580.415763] RIP: 0010:[<ffffffff8112340f>]  [<ffffffff8112340f>] stack_trace_call+0x37f/0x390
[ 2580.415763] RSP: 0000:ffff880029c52270  EFLAGS: 00010096
[ 2580.415763] RAX: ffff880029c52000 RBX: 0000000000000009 RCX: 0000000000000002
[ 2580.415763] RDX: 0000000000000006 RSI: 0000000000000002 RDI: ffff88003780be00
[ 2580.415763] RBP: ffff880029c522d0 R08: 00000000000009e8 R09: ffffffffffffffff
[ 2580.415763] R10: ffff880029c53fd8 R11: 0000000000000001 R12: 000000000000f2e8
[ 2580.415763] R13: 0000000000000009 R14: ffffffff82768dfc R15: 00000000000000f8
[ 2580.415763] FS:  0000000000000000(0000) GS:ffff880037d20000(0000) knlGS:0000000000000000
[ 2580.415763] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 2580.415763] CR2: 00002aea5db57000 CR3: 0000000001c0b000 CR4: 00000000000006e0
[ 2580.415763] Stack:
[ 2580.415763]  0000000000000009 ffffffff81150819 0000000000000083 0000000000001c70
[ 2580.415763]  ffff880029c52300 ffffffff81005e11 ffffffff81c55ef0 0000000000000000
[ 2580.415763]  0000000000000002 ffff88001e9ca0e0 ffff88001e9cb108 0000000000000000
[ 2580.415763] Call Trace:
[ 2580.415763]  [<ffffffff81150819>] ? __alloc_pages_nodemask+0x199/0xb20
[ 2580.415763]  [<ffffffff81005e11>] ? print_context_stack+0x81/0x140
[ 2580.415763]  [<ffffffff816eedbf>] ftrace_call+0x5/0x2f
[ 2580.415763]  [<ffffffff8119097f>] ? alloc_pages_current+0x10f/0x1f0
[ 2580.415763]  [<ffffffff8119097f>] ? alloc_pages_current+0x10f/0x1f0
[ 2580.415763]  [<ffffffff811650b5>] ? next_zones_zonelist+0x5/0x70
[ 2580.415763]  [<ffffffff810a22dd>] ? trace_hardirqs_off+0xd/0x10
[ 2580.415763]  [<ffffffff811650b5>] ? next_zones_zonelist+0x5/0x70
[ 2580.415763]  [<ffffffff81150819>] ? __alloc_pages_nodemask+0x199/0xb20
[ 2580.415763]  [<ffffffff8119097f>] ? alloc_pages_current+0x10f/0x1f0
[ 2580.415763]  [<ffffffff810a22dd>] ? trace_hardirqs_off+0xd/0x10
[ 2580.415763]  [<ffffffff811231a9>] ? stack_trace_call+0x119/0x390
[ 2580.415763]  [<ffffffff816eedbf>] ? ftrace_call+0x5/0x2f
[ 2580.415763]  [<ffffffff8119097f>] alloc_pages_current+0x10f/0x1f0
[ 2580.415763]  [<ffffffff81199d25>] ? new_slab+0x2c5/0x370
[ 2580.415763]  [<ffffffff81199d25>] new_slab+0x2c5/0x370
[ 2580.415763]  [<ffffffff816dafb2>] __slab_alloc+0x3a9/0x501
[ 2580.415763]  [<ffffffff8141daee>] ? alloc_indirect+0x1e/0x50
[ 2580.415763]  [<ffffffff8141daee>] ? alloc_indirect+0x1e/0x50
[ 2580.415763]  [<ffffffff8141daee>] ? alloc_indirect+0x1e/0x50
[ 2580.415763]  [<ffffffff8119afdb>] __kmalloc+0x1cb/0x200
[ 2580.415763]  [<ffffffff8141daee>] alloc_indirect+0x1e/0x50
[ 2580.415763]  [<ffffffff8141e297>] virtqueue_add_sgs+0xc7/0x300
[ 2580.415763]  [<ffffffff8148e2fa>] __virtblk_add_req+0xda/0x1b0
[ 2580.415763]  [<ffffffff8148e4a3>] virtio_queue_rq+0xd3/0x1d0
[ 2580.415763]  [<ffffffff8134aa5f>] __blk_mq_run_hw_queue+0x1ef/0x440
[ 2580.415763]  [<ffffffff8134b125>] blk_mq_run_hw_queue+0x35/0x40
[ 2580.415763]  [<ffffffff8134b80b>] blk_mq_insert_requests+0xdb/0x160
[ 2580.415763]  [<ffffffff8134beab>] blk_mq_flush_plug_list+0x12b/0x140
[ 2580.415763]  [<ffffffff81342287>] blk_flush_plug_list+0xc7/0x220
[ 2580.415763]  [<ffffffff816e609f>] ? _raw_spin_unlock_irqrestore+0x3f/0x70
[ 2580.415763]  [<ffffffff816e1698>] io_schedule_timeout+0x88/0x100
[ 2580.415763]  [<ffffffff816e1615>] ? io_schedule_timeout+0x5/0x100
[ 2580.415763]  [<ffffffff81149465>] mempool_alloc+0x145/0x170
[ 2580.415763]  [<ffffffff8109baf0>] ? __init_waitqueue_head+0x60/0x60
[ 2580.415763]  [<ffffffff811e24bb>] bio_alloc_bioset+0x10b/0x1d0
[ 2580.415763]  [<ffffffff81184280>] ? end_swap_bio_read+0xc0/0xc0
[ 2580.415763]  [<ffffffff81184280>] ? end_swap_bio_read+0xc0/0xc0
[ 2580.415763]  [<ffffffff81184160>] get_swap_bio+0x30/0x90
[ 2580.415763]  [<ffffffff81184280>] ? end_swap_bio_read+0xc0/0xc0
[ 2580.415763]  [<ffffffff811846b0>] __swap_writepage+0x150/0x230
[ 2580.415763]  [<ffffffff810ab405>] ? do_raw_spin_unlock+0x5/0xa0
[ 2580.415763]  [<ffffffff81184280>] ? end_swap_bio_read+0xc0/0xc0
[ 2580.415763]  [<ffffffff81184565>] ? __swap_writepage+0x5/0x230
[ 2580.415763]  [<ffffffff811847d2>] swap_writepage+0x42/0x90
[ 2580.415763]  [<ffffffff8115aee6>] shrink_page_list+0x676/0xa80
[ 2580.415763]  [<ffffffff816eedbf>] ? ftrace_call+0x5/0x2f
[ 2580.415763]  [<ffffffff8115b8c2>] shrink_inactive_list+0x262/0x4e0
[ 2580.415763]  [<ffffffff8115c211>] shrink_lruvec+0x3e1/0x6a0
[ 2580.415763]  [<ffffffff8115c50f>] shrink_zone+0x3f/0x110
[ 2580.415763]  [<ffffffff816eedbf>] ? ftrace_call+0x5/0x2f
[ 2580.415763]  [<ffffffff8115ca36>] do_try_to_free_pages+0x156/0x4c0
[ 2580.415763]  [<ffffffff8115cf97>] try_to_free_pages+0xf7/0x1e0
[ 2580.415763]  [<ffffffff81150e03>] __alloc_pages_nodemask+0x783/0xb20
[ 2580.415763]  [<ffffffff8119097f>] alloc_pages_current+0x10f/0x1f0
[ 2580.415763]  [<ffffffff81145c5f>] ? __page_cache_alloc+0x13f/0x160
[ 2580.415763]  [<ffffffff81145c5f>] __page_cache_alloc+0x13f/0x160
[ 2580.415763]  [<ffffffff81146cbc>] find_or_create_page+0x4c/0xb0
[ 2580.415763]  [<ffffffff811ded09>] __getblk+0x109/0x2f0
[ 2580.415763]  [<ffffffff8124629e>] ext4_read_block_bitmap_nowait+0x5e/0x330
[ 2580.415763]  [<ffffffff81282bf8>] ext4_mb_init_cache+0x158/0x780
[ 2580.415763]  [<ffffffff816eedbf>] ? ftrace_call+0x5/0x2f
[ 2580.415763]  [<ffffffff81155d15>] ? __lru_cache_add+0x5/0x90
[ 2580.415763]  [<ffffffff81146435>] ? find_get_page+0x5/0x130
[ 2580.415763]  [<ffffffff812838aa>] ext4_mb_load_buddy+0x28a/0x370
[ 2580.415763]  [<ffffffff81284c57>] ext4_mb_regular_allocator+0x1b7/0x460
[ 2580.415763]  [<ffffffff812810c0>] ? ext4_mb_use_preallocated+0x40/0x360
[ 2580.415763]  [<ffffffff816eedbf>] ? ftrace_call+0x5/0x2f
[ 2580.415763]  [<ffffffff81287f08>] ext4_mb_new_blocks+0x458/0x5f0
[ 2580.415763]  [<ffffffff8127d88b>] ext4_ext_map_blocks+0x70b/0x1010
[ 2580.415763]  [<ffffffff8124e725>] ext4_map_blocks+0x325/0x530
[ 2580.415763]  [<ffffffff812538c1>] ext4_writepages+0x6d1/0xce0
[ 2580.415763]  [<ffffffff812531f0>] ? ext4_journalled_write_end+0x330/0x330
[ 2580.415763]  [<ffffffff81153a03>] do_writepages+0x23/0x40
[ 2580.415763]  [<ffffffff811d23b5>] __writeback_single_inode+0x45/0x2e0
[ 2580.415763]  [<ffffffff811d373d>] writeback_sb_inodes+0x2ad/0x500
[ 2580.415763]  [<ffffffff811d3a2e>] __writeback_inodes_wb+0x9e/0xd0
[ 2580.415763]  [<ffffffff811d410b>] wb_writeback+0x29b/0x350
[ 2580.415763]  [<ffffffff81057c3d>] ? __local_bh_enable_ip+0x6d/0xd0
[ 2580.415763]  [<ffffffff811d6eec>] bdi_writeback_workfn+0x11c/0x480
[ 2580.415763]  [<ffffffff81070610>] ? process_one_work+0x170/0x570
[ 2580.415763]  [<ffffffff81070672>] process_one_work+0x1d2/0x570
[ 2580.415763]  [<ffffffff81070610>] ? process_one_work+0x170/0x570
[ 2580.415763]  [<ffffffff81071bb6>] worker_thread+0x116/0x370
[ 2580.415763]  [<ffffffff81071aa0>] ? manage_workers.isra.19+0x2e0/0x2e0
[ 2580.415763]  [<ffffffff81078e53>] kthread+0xf3/0x110
[ 2580.415763]  [<ffffffff81078d60>] ? flush_kthread_worker+0x150/0x150
[ 2580.415763]  [<ffffffff816ef06c>] ret_from_fork+0x7c/0xb0
[ 2580.415763]  [<ffffffff81078d60>] ? flush_kthread_worker+0x150/0x150

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
