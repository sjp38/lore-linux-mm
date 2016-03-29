Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 231486B0005
	for <linux-mm@kvack.org>; Tue, 29 Mar 2016 10:53:27 -0400 (EDT)
Received: by mail-wm0-f44.google.com with SMTP id 127so61850092wmu.1
        for <linux-mm@kvack.org>; Tue, 29 Mar 2016 07:53:27 -0700 (PDT)
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com. [74.125.82.41])
        by mx.google.com with ESMTPS id y85si4292355wmd.1.2016.03.29.07.53.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Mar 2016 07:53:25 -0700 (PDT)
Received: by mail-wm0-f41.google.com with SMTP id p65so30147659wmp.0
        for <linux-mm@kvack.org>; Tue, 29 Mar 2016 07:53:25 -0700 (PDT)
Subject: Re: memory fragmentation issues on 4.4
References: <56F8F5DA.6040206@kyup.com> <56FA8F18.60306@suse.cz>
From: Nikolay Borisov <kernel@kyup.com>
Message-ID: <56FA96E3.3020200@kyup.com>
Date: Tue, 29 Mar 2016 17:53:23 +0300
MIME-Version: 1.0
In-Reply-To: <56FA8F18.60306@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Linux MM <linux-mm@kvack.org>
Cc: mgorman@techsingularity.net



On 03/29/2016 05:20 PM, Vlastimil Babka wrote:
> On 03/28/2016 11:14 AM, Nikolay Borisov wrote:
>> Hello,
>>
>> On kernel 4.4 I observe that the memory gets really fragmented fairly
>> quickly. E.g. there are no order  > 4 pages even after 2 days of uptime.
>> This leads to certain data structures on XFS (in my case order 4/order 5
>> allocations)  not being allocated and causes the server to stall. When
>> this happens either someone has to log on the server and manually invoke
>> the memory compaction or plain reboot the server. Before that the server
>> was running with the exact same workload but with 3.12.52 kernel and no
>> such issue were observed. That is - memory was fragmented but allocation
>> didn't fail, maybe alloc_pages_direct_compact was doing a better job?
>>
>> FYI the allocation is performed with GFP_KERNEL | GFP_NOFS
> 
> GFP_NOFS is indeed excluded from memory compaction in the allocation
> context (i.e. direct compaction).
> 
>> Manual compaction usually does the job, however I'm wondering why isn't
>> invoking __alloc_pages_direct_compact from within __alloc_pages_nodemask
>> satisfying the request if manual compaction would do the job. Is there a
>> difference in the efficiency of manually invoking memory compaction and
>> the one invoked from the page allocator path?
> 
> Manual compaction via /proc is known to be safe in not holding any locks
> that XFS might be holding. Compaction relies on page migration and IIRC
> some filesystems cannot migrate dirty pages unless there's writeback,
> and if that writeback called back to xfs, it would be a deadlock.
> However, we could investigate if the async compaction would be safe.
> 
> In any case, such high-order allocations should always have an order-0
> fallback. You're suggesting there's an infinite loop around the
> allocation attempt instead? Do you have the full backtrace?

Yes, here is a full backtrace:

loop0           D ffff881fe081f038     0 15174      2 0x00000000
 ffff881fe081f038 ffff883ff29fa700 ffff881fecb70d00 ffff88407fffae00
 0000000000000000 0000000502404240 ffffffff81e30d60 0000000000000000
 0000000000000000 ffff881f00000003 0000000000000282 ffff883f00000000
Call Trace:
 [<ffffffff8163ac01>] ? _raw_spin_lock_irqsave+0x21/0x60
 [<ffffffff81636fd7>] schedule+0x47/0x90
 [<ffffffff81639f03>] schedule_timeout+0x113/0x1e0
 [<ffffffff810ac580>] ? lock_timer_base+0x80/0x80
 [<ffffffff816363d4>] io_schedule_timeout+0xa4/0x110
 [<ffffffff8114aadf>] congestion_wait+0x7f/0x130
 [<ffffffff810939e0>] ? woken_wake_function+0x20/0x20
 [<ffffffffa0283bac>] kmem_alloc+0x8c/0x120 [xfs]
 [<ffffffff81181751>] ? __kmalloc+0x121/0x250
 [<ffffffffa0283c73>] kmem_realloc+0x33/0x80 [xfs]
 [<ffffffffa02546cd>] xfs_iext_realloc_indirect+0x3d/0x60 [xfs]
 [<ffffffffa02548cf>] xfs_iext_irec_new+0x3f/0xf0 [xfs]
 [<ffffffffa0254c0d>] xfs_iext_add_indirect_multi+0x14d/0x210 [xfs]
 [<ffffffffa02554b5>] xfs_iext_add+0xc5/0x230 [xfs]
 [<ffffffff8112b5c5>] ? mempool_alloc_slab+0x15/0x20
 [<ffffffffa0256269>] xfs_iext_insert+0x59/0x110 [xfs]
 [<ffffffffa0230928>] ? xfs_bmap_add_extent_hole_delay+0xd8/0x740 [xfs]
 [<ffffffffa0230928>] xfs_bmap_add_extent_hole_delay+0xd8/0x740 [xfs]
 [<ffffffff8112b5c5>] ? mempool_alloc_slab+0x15/0x20
 [<ffffffff8112b725>] ? mempool_alloc+0x65/0x180
 [<ffffffffa02543d8>] ? xfs_iext_get_ext+0x38/0x70 [xfs]
 [<ffffffffa0254e8d>] ? xfs_iext_bno_to_ext+0xed/0x150 [xfs]
 [<ffffffffa02311b5>] xfs_bmapi_reserve_delalloc+0x225/0x250 [xfs]
 [<ffffffffa023131e>] xfs_bmapi_delay+0x13e/0x290 [xfs]
 [<ffffffffa02730ad>] xfs_iomap_write_delay+0x17d/0x300 [xfs]
 [<ffffffffa022e434>] ? xfs_bmapi_read+0x114/0x330 [xfs]
 [<ffffffffa025ddc5>] __xfs_get_blocks+0x585/0xa90 [xfs]
 [<ffffffff81324b53>] ? __percpu_counter_add+0x63/0x80
 [<ffffffff811374cd>] ? account_page_dirtied+0xed/0x1b0
 [<ffffffff811cfc59>] ? alloc_buffer_head+0x49/0x60
 [<ffffffff811d07c0>] ? alloc_page_buffers+0x60/0xb0
 [<ffffffff811d13e5>] ? create_empty_buffers+0x45/0xc0
 [<ffffffffa025e324>] xfs_get_blocks+0x14/0x20 [xfs]
 [<ffffffff811d34e2>] __block_write_begin+0x1c2/0x580
 [<ffffffffa025e310>] ? xfs_get_blocks_direct+0x20/0x20 [xfs]
 [<ffffffffa025bbb1>] xfs_vm_write_begin+0x61/0xf0 [xfs]
 [<ffffffff81127e50>] generic_perform_write+0xd0/0x1f0
 [<ffffffffa026a341>] xfs_file_buffered_aio_write+0xe1/0x240 [xfs]
 [<ffffffff812e16d2>] ? bt_clear_tag+0xb2/0xd0
 [<ffffffffa026ab87>] xfs_file_write_iter+0x167/0x170 [xfs]
 [<ffffffff81199d76>] vfs_iter_write+0x76/0xa0
 [<ffffffffa03fb735>] lo_write_bvec+0x65/0x100 [loop]
 [<ffffffffa03fd589>] loop_queue_work+0x689/0x924 [loop]
 [<ffffffff8163ba52>] ? retint_kernel+0x10/0x10
 [<ffffffff81074d71>] kthread_worker_fn+0x61/0x1c0
 [<ffffffff81074d10>] ? flush_kthread_work+0x120/0x120
 [<ffffffff81074d10>] ? flush_kthread_work+0x120/0x120
 [<ffffffff810744d7>] kthread+0xd7/0xf0
 [<ffffffff8107d22e>] ? schedule_tail+0x1e/0xd0
 [<ffffffff81074400>] ? kthread_freezable_should_stop+0x80/0x80
 [<ffffffff8163b2af>] ret_from_fork+0x3f/0x70
 [<ffffffff81074400>] ? kthread_freezable_should_stop+0x80/0x80

Basically on a very large sparse file the array which holds the extents
that describe said file can grow fairly big. In this particular case it
couldn't satisfy an order-5 allocation as evident from the following
message from xfs:


XFS: loop0(15174) possible memory allocation deadlock size 107168 in
kmem_alloc (mode:0x2400240)

This basically says "I cannot allocate 107 contiguous kb"


And here is a discussion that ensued on xfs mailing list:
http://oss.sgi.com/archives/xfs/2016-03/msg00447.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
