Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 91B2F6B0005
	for <linux-mm@kvack.org>; Wed, 20 Jul 2016 11:33:43 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id x83so35899195wma.2
        for <linux-mm@kvack.org>; Wed, 20 Jul 2016 08:33:43 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i14si1396951wjs.247.2016.07.20.08.33.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 20 Jul 2016 08:33:42 -0700 (PDT)
Subject: Re: [mmotm-2016-07-18-16-40] page allocation failure: order:2,
 mode:0x2000000(GFP_NOWAIT)
References: <20160720114417.GA19146@node.shutemov.name>
 <20160720115323.GI11249@dhcp22.suse.cz>
 <9c2c9249-af41-56c2-7169-1465e0c07edc@suse.cz>
 <20160720151905.GB19146@node.shutemov.name>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <e9ffdc50-b085-c96c-5da7-7358967f421c@suse.cz>
Date: Wed, 20 Jul 2016 17:33:41 +0200
MIME-Version: 1.0
In-Reply-To: <20160720151905.GB19146@node.shutemov.name>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Alexander Potapenko <glider@google.com>, Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, riel@redhat.com, rientjes@google.com, mgorman@techsingularity.net

On 07/20/2016 05:19 PM, Kirill A. Shutemov wrote:
> On Wed, Jul 20, 2016 at 03:39:24PM +0200, Vlastimil Babka wrote:
>> On 07/20/2016 01:53 PM, Michal Hocko wrote:
>>> On Wed 20-07-16 14:44:17, Kirill A. Shutemov wrote:
>>>> Hello,
>>>>
>>>> Looks like current mmotm is broken. See trace below.
>>>
>>> Why do you think it is broken? This is order-2 NOWAIT allocation. So we
>>> are relying on atomic highorder reserve and kcompactd to make sufficient
>>> progress. It is hard to find out more without the full log including the
>>> meminfo.
>>
>> Also it seems to come from kasan allocating stackdepot space to record
>> who freed a slab object, or something.
>>
>>>> It's easy to reproduce in my setup: virtual machine with some amount of
>>>> swap space and try allocate about the size of RAM in userspace (I used
>>>> usemem[1] for that).
>>>
>>> Have you tried to bisect it?
> 
> Bisected to a590d2628f08 ("mm, kasan: switch SLUB to stackdepot, enable
> memory quarantine for SLUB").
> 
> I guess it's candidate for __GFP_WARN. Not sure if there's a better
> solution.

An order-0 fallback maybe?
Agree with NOWARN, if stackdepot (or its users) are able to tell that a
trace is missing because allocation has failed - the precise allocation
trace isn't that useful I guess. Order-2 allocation that's potentially
atomic and frequent just can fail.

> This helps:
> 
> diff --git a/lib/stackdepot.c b/lib/stackdepot.c
> index 53ad6c0831ae..60f77f1d470a 100644
> --- a/lib/stackdepot.c
> +++ b/lib/stackdepot.c
> @@ -242,6 +242,7 @@ depot_stack_handle_t depot_save_stack(struct stack_trace *trace,
>                  */
>                 alloc_flags &= ~GFP_ZONEMASK;
>                 alloc_flags &= (GFP_ATOMIC | GFP_KERNEL);
> +               alloc_flags |= __GFP_NOWARN;
>                 page = alloc_pages(alloc_flags, STACK_ALLOC_ORDER);
>                 if (page)
>                         prealloc = page_address(page);
> 
>>> Some of the recent compaction changes might have made a difference.
>>
>> AFAIK recent compaction changes are not in mmotm yet. The node-based lru
>> reclaim might have shifted some balances perhaps.
>>
>>>> Any clues?
>>>>
>>>> [1] http://www.spinics.net/lists/linux-mm/attachments/gtarazbJaHPaAT.gtar
>>>>
>>>> [   39.413099] kswapd2: page allocation failure: order:2, mode:0x2000000(GFP_NOWAIT)
>>>> [   39.414122] CPU: 2 PID: 64 Comm: kswapd2 Not tainted 4.7.0-rc7-mm1-00428-gc3e13e4dab1b-dirty #2878
>>>> [   39.416018] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BIOS rel-1.9.1-0-gb3ef39f-prebuilt.qemu-project.org 04/01/2014
>>>> [   39.416018]  0000000000000002 ffff88002f807690 ffffffff81c8fb0d 1ffff10005f00ed6
>>>> [   39.416018]  0000000000000000 0000000000000002 ffff88002f807750 ffff88002f8077a8
>>>> [   39.416018]  ffffffff813e728b ffff88002f8077a8 0200000000000000 0000000041b58ab3
>>>> [   39.416018] Call Trace:
>>>> [   39.416018]  <IRQ>  [<ffffffff81c8fb0d>] dump_stack+0x95/0xe8
>>>> [   39.416018]  [<ffffffff813e728b>] warn_alloc_failed+0x1cb/0x250
>>>> [   39.416018]  [<ffffffff813e70c0>] ? zone_watermark_ok_safe+0x250/0x250
>>>> [   39.416018]  [<ffffffff81153788>] ? __kernel_text_address+0x78/0xa0
>>>> [   39.416018]  [<ffffffff813e7f4c>] __alloc_pages_nodemask+0x92c/0x1fe0
>>>> [   39.416018]  [<ffffffff8119047c>] ? sched_clock_cpu+0x12c/0x1e0
>>>> [   39.416018]  [<ffffffff81d24a17>] ? depot_save_stack+0x1b7/0x5b0
>>>> [   39.416018]  [<ffffffff813d5ac2>] ? mempool_free_slab+0x22/0x30
>>>> [   39.416018]  [<ffffffff81313595>] ? is_ftrace_trampoline+0xe5/0x120
>>>> [   39.416018]  [<ffffffff813e7620>] ? __free_pages+0x90/0x90
>>>> [   39.416018]  [<ffffffff811f9870>] ? debug_show_all_locks+0x290/0x290
>>>> [   39.416018]  [<ffffffff81190023>] ? sched_clock_local+0x43/0x120
>>>> [   39.416018]  [<ffffffff81cef815>] ? check_preemption_disabled+0x35/0x190
>>>> [   39.416018]  [<ffffffff81cef815>] ? check_preemption_disabled+0x35/0x190
>>>> [   39.416018]  [<ffffffff81cef98c>] ? debug_smp_processor_id+0x1c/0x20
>>>> [   39.416018]  [<ffffffff811ee78d>] ? get_lock_stats+0x1d/0x90
>>>> [   39.416018]  [<ffffffff81245617>] ? debug_lockdep_rcu_enabled+0x77/0x90
>>>> [   39.416018]  [<ffffffff81153788>] ? __kernel_text_address+0x78/0xa0
>>>> [   39.416018]  [<ffffffff8105d05b>] ? print_context_stack+0x7b/0x100
>>>> [   39.416018]  [<ffffffff814d42dc>] alloc_pages_current+0xbc/0x1f0
>>>> [   39.416018]  [<ffffffff81d24d5f>] depot_save_stack+0x4ff/0x5b0
>>>> [   39.416018]  [<ffffffff813d5ac2>] ? mempool_free_slab+0x22/0x30
>>>> [   39.416018]  [<ffffffff814eb4c7>] kasan_slab_free+0x157/0x180
>>>> [   39.416018]  [<ffffffff8107c58b>] ? save_stack_trace+0x2b/0x50
>>>> [   39.416018]  [<ffffffff814eb453>] ? kasan_slab_free+0xe3/0x180
>>>> [   39.416018]  [<ffffffff814e73e5>] ? kmem_cache_free+0x95/0x300
>>>> [   39.416018]  [<ffffffff813d5ac2>] ? mempool_free_slab+0x22/0x30
>>>> [   39.416018]  [<ffffffff813d59a9>] ? mempool_free+0xd9/0x1d0
>>>> [   39.416018]  [<ffffffff81be96e5>] ? bio_free+0x145/0x220
>>>> [   39.416018]  [<ffffffff81bea8bf>] ? bio_put+0x8f/0xb0
>>>> [   39.416018]  [<ffffffff814a7bfe>] ? end_swap_bio_write+0x22e/0x310
>>>> [   39.416018]  [<ffffffff81bf1687>] ? bio_endio+0x187/0x1f0
>>>> [   39.416018]  [<ffffffff81c0e89b>] ? blk_update_request+0x1bb/0xc30
>>>> [   39.416018]  [<ffffffff81c3238c>] ? blk_mq_end_request+0x4c/0x130
>>>> [   39.416018]  [<ffffffff8208a330>] ? virtblk_request_done+0xb0/0x2a0
>>>> [   39.416018]  [<ffffffff81c2d17d>] ? __blk_mq_complete_request_remote+0x5d/0x70
>>>> [   39.416018]  [<ffffffff8129fe3c>] ? flush_smp_call_function_queue+0xdc/0x3a0
>>>> [   39.416018]  [<ffffffff812a0548>] ? generic_smp_call_function_single_interrupt+0x18/0x20
>>>> [   39.416018]  [<ffffffff8109c654>] ? smp_call_function_single_interrupt+0x64/0x90
>>>> [   39.416018]  [<ffffffff829584a9>] ? call_function_single_interrupt+0x89/0x90
>>>> [   39.416018]  [<ffffffff81c350f6>] ? blk_mq_map_request+0xe6/0xc00
>>>> [   39.416018]  [<ffffffff81c36f6f>] ? blk_sq_make_request+0x9af/0xca0
>>>> [   39.416018]  [<ffffffff81c0b05e>] ? generic_make_request+0x30e/0x660
>>>> [   39.416018]  [<ffffffff81c0b540>] ? submit_bio+0x190/0x470
>>>> [   39.416018]  [<ffffffff814a8fd8>] ? __swap_writepage+0x6e8/0x940
>>>> [   39.416018]  [<ffffffff814a926a>] ? swap_writepage+0x3a/0x70
>>>> [   39.416018]  [<ffffffff8141376b>] ? shrink_page_list+0x1bdb/0x2f00
>>>> [   39.416018]  [<ffffffff81416038>] ? shrink_inactive_list+0x538/0xc70
>>>> [   39.416018]  [<ffffffff81417a1b>] ? shrink_node_memcg+0xa1b/0x1160
>>>> [   39.416018]  [<ffffffff81418436>] ? shrink_node+0x2d6/0xc60
>>>> [   39.416018]  [<ffffffff8141bf1e>] ? kswapd+0x82e/0x1460
>>>> [   39.416018]  [<ffffffff81156d4a>] ? kthread+0x24a/0x2e0
>>>> [   39.416018]  [<ffffffff8295773f>] ? ret_from_fork+0x1f/0x40
>>>> [   39.416018]  [<ffffffff81190023>] ? sched_clock_local+0x43/0x120
>>>> [   39.416018]  [<ffffffff81cef815>] ? check_preemption_disabled+0x35/0x190
>>>> [   39.416018]  [<ffffffff81cef815>] ? check_preemption_disabled+0x35/0x190
>>>> [   39.416018]  [<ffffffff81cef815>] ? check_preemption_disabled+0x35/0x190
>>>> [   39.416018]  [<ffffffff81353e65>] ? time_hardirqs_off+0x45/0x2f0
>>>> [   39.416018]  [<ffffffff814e73c5>] ? kmem_cache_free+0x75/0x300
>>>> [   39.416018]  [<ffffffff81353e65>] ? time_hardirqs_off+0x45/0x2f0
>>>> [   39.416018]  [<ffffffff814e747f>] ? kmem_cache_free+0x12f/0x300
>>>> [   39.416018]  [<ffffffff813d5ac2>] ? mempool_free_slab+0x22/0x30
>>>> [   39.416018]  [<ffffffff814e73e5>] kmem_cache_free+0x95/0x300
>>>> [   39.416018]  [<ffffffff813d5aa0>] ? mempool_free+0x1d0/0x1d0
>>>> [   39.416018]  [<ffffffff813d5ac2>] mempool_free_slab+0x22/0x30
>>>> [   39.416018]  [<ffffffff813d59a9>] mempool_free+0xd9/0x1d0
>>>> [   39.416018]  [<ffffffff81be96e5>] bio_free+0x145/0x220
>>>> [   39.416018]  [<ffffffff814a79d0>] ? SyS_madvise+0x13c0/0x13c0
>>>> [   39.416018]  [<ffffffff81bea8bf>] bio_put+0x8f/0xb0
>>>> [   39.416018]  [<ffffffff814a7bfe>] end_swap_bio_write+0x22e/0x310
>>>> [   39.416018]  [<ffffffff814a79d0>] ? SyS_madvise+0x13c0/0x13c0
>>>> [   39.416018]  [<ffffffff81bf1687>] bio_endio+0x187/0x1f0
>>>> [   39.416018]  [<ffffffff81c0e89b>] blk_update_request+0x1bb/0xc30
>>>> [   39.416018]  [<ffffffff81c2d120>] ? blkdev_issue_zeroout+0x3f0/0x3f0
>>>> [   39.416018]  [<ffffffff81c3238c>] blk_mq_end_request+0x4c/0x130
>>>> [   39.416018]  [<ffffffff8208a330>] virtblk_request_done+0xb0/0x2a0
>>>> [   39.416018]  [<ffffffff81c2d17d>] __blk_mq_complete_request_remote+0x5d/0x70
>>>> [   39.416018]  [<ffffffff8129fe3c>] flush_smp_call_function_queue+0xdc/0x3a0
>>>> [   39.416018]  [<ffffffff812a0548>] generic_smp_call_function_single_interrupt+0x18/0x20
>>>> [   39.416018]  [<ffffffff8109c654>] smp_call_function_single_interrupt+0x64/0x90
>>>> [   39.416018]  [<ffffffff829584a9>] call_function_single_interrupt+0x89/0x90
>>>> [   39.416018]  <EOI>  [<ffffffff8120138b>] ? lock_acquire+0x15b/0x340
>>>> [   39.416018]  [<ffffffff81c350a9>] ? blk_mq_map_request+0x99/0xc00
>>>> [   39.416018]  [<ffffffff81c350f6>] blk_mq_map_request+0xe6/0xc00
>>>> [   39.416018]  [<ffffffff81c350a9>] ? blk_mq_map_request+0x99/0xc00
>>>> [   39.416018]  [<ffffffff81c8d434>] ? blk_integrity_merge_bio+0xb4/0x3b0
>>>> [   39.416018]  [<ffffffff81c35010>] ? blk_mq_alloc_request+0x490/0x490
>>>> [   39.416018]  [<ffffffff81c0dd66>] ? blk_attempt_plug_merge+0x226/0x2c0
>>>> [   39.416018]  [<ffffffff81c36f6f>] blk_sq_make_request+0x9af/0xca0
>>>> [   39.416018]  [<ffffffff81c365c0>] ? blk_mq_insert_requests+0x940/0x940
>>>> [   39.416018]  [<ffffffff81c07d20>] ? blk_exit_rl+0x60/0x60
>>>> [   39.416018]  [<ffffffff81c027b0>] ? handle_bad_sector+0x1e0/0x1e0
>>>> [   39.416018]  [<ffffffff81190023>] ? sched_clock_local+0x43/0x120
>>>> [   39.416018]  [<ffffffff81cef815>] ? check_preemption_disabled+0x35/0x190
>>>> [   39.416018]  [<ffffffff81cef815>] ? check_preemption_disabled+0x35/0x190
>>>> [   39.416018]  [<ffffffff81cef815>] ? check_preemption_disabled+0x35/0x190
>>>> [   39.416018]  [<ffffffff81c0b05e>] generic_make_request+0x30e/0x660
>>>> [   39.416018]  [<ffffffff81c0ad50>] ? blk_plug_queued_count+0x160/0x160
>>>> [   39.416018]  [<ffffffff81cef98c>] ? debug_smp_processor_id+0x1c/0x20
>>>> [   39.416018]  [<ffffffff81353ba2>] ? time_hardirqs_on+0xb2/0x330
>>>> [   39.416018]  [<ffffffff8152890b>] ? unlock_page_memcg+0x7b/0x130
>>>> [   39.416018]  [<ffffffff81c0b540>] submit_bio+0x190/0x470
>>>> [   39.416018]  [<ffffffff811dff60>] ? woken_wake_function+0x60/0x60
>>>> [   39.416018]  [<ffffffff81c0b3b0>] ? generic_make_request+0x660/0x660
>>>> [   39.416018]  [<ffffffff813f769d>] ? __test_set_page_writeback+0x36d/0x8c0
>>>> [   39.416018]  [<ffffffff814a8fd8>] __swap_writepage+0x6e8/0x940
>>>> [   39.416018]  [<ffffffff814a79d0>] ? SyS_madvise+0x13c0/0x13c0
>>>> [   39.416018]  [<ffffffff814a88f0>] ? generic_swapfile_activate+0x490/0x490
>>>> [   39.416018]  [<ffffffff814abd45>] ? swap_info_get+0x165/0x240
>>>> [   39.416018]  [<ffffffff814affda>] ? page_swapcount+0xba/0xf0
>>>> [   39.416018]  [<ffffffff82956ba1>] ? _raw_spin_unlock+0x31/0x50
>>>> [   39.416018]  [<ffffffff814affdf>] ? page_swapcount+0xbf/0xf0
>>>> [   39.416018]  [<ffffffff814a926a>] swap_writepage+0x3a/0x70
>>>> [   39.416018]  [<ffffffff8141376b>] shrink_page_list+0x1bdb/0x2f00
>>>> [   39.416018]  [<ffffffff81411b90>] ? putback_lru_page+0x3b0/0x3b0
>>>> [   39.416018]  [<ffffffff81cef9ac>] ? __this_cpu_preempt_check+0x1c/0x20
>>>> [   39.416018]  [<ffffffff81438ed4>] ? __mod_node_page_state+0x94/0xe0
>>>> [   39.416018]  [<ffffffff81190023>] ? sched_clock_local+0x43/0x120
>>>> [   39.416018]  [<ffffffff81cef815>] ? check_preemption_disabled+0x35/0x190
>>>> [   39.416018]  [<ffffffff81cef815>] ? check_preemption_disabled+0x35/0x190
>>>> [   39.416018]  [<ffffffff811ee78d>] ? get_lock_stats+0x1d/0x90
>>>> [   39.416018]  [<ffffffff8140fcb0>] ? __isolate_lru_page+0x3b0/0x3b0
>>>> [   39.416018]  [<ffffffff81cef98c>] ? debug_smp_processor_id+0x1c/0x20
>>>> [   39.416018]  [<ffffffff81353ba2>] ? time_hardirqs_on+0xb2/0x330
>>>> [   39.416018]  [<ffffffff811f6535>] ? trace_hardirqs_on_caller+0x405/0x590
>>>> [   39.416018]  [<ffffffff81416038>] shrink_inactive_list+0x538/0xc70
>>>> [   39.416018]  [<ffffffff81415b00>] ? putback_inactive_pages+0xaa0/0xaa0
>>>> [   39.416018]  [<ffffffff81416770>] ? shrink_inactive_list+0xc70/0xc70
>>>> [   39.416018]  [<ffffffff81190023>] ? sched_clock_local+0x43/0x120
>>>> [   39.416018]  [<ffffffff81cef815>] ? check_preemption_disabled+0x35/0x190
>>>> [   39.416018]  [<ffffffff81cef815>] ? check_preemption_disabled+0x35/0x190
>>>> [   39.416018]  [<ffffffff81cd5780>] ? _find_next_bit.part.0+0xe0/0x120
>>>> [   39.416018]  [<ffffffff8140e654>] ? pgdat_reclaimable_pages+0x764/0x9d0
>>>> [   39.416018]  [<ffffffff8140f2ec>] ? pgdat_reclaimable+0x13c/0x1d0
>>>> [   39.416018]  [<ffffffff8140f3cc>] ? lruvec_lru_size+0x4c/0xa0
>>>> [   39.416018]  [<ffffffff81417a1b>] shrink_node_memcg+0xa1b/0x1160
>>>> [   39.416018]  [<ffffffff81417000>] ? shrink_active_list+0x890/0x890
>>>> [   39.416018]  [<ffffffff81cef815>] ? check_preemption_disabled+0x35/0x190
>>>> [   39.416018]  [<ffffffff81cef98c>] ? debug_smp_processor_id+0x1c/0x20
>>>> [   39.416018]  [<ffffffff8151f208>] ? mem_cgroup_iter+0x1b8/0xd10
>>>> [   39.416018]  [<ffffffff82956c2c>] ? _raw_spin_unlock_irq+0x2c/0x50
>>>> [   39.416018]  [<ffffffff81418436>] shrink_node+0x2d6/0xc60
>>>> [   39.416018]  [<ffffffff81418160>] ? shrink_node_memcg+0x1160/0x1160
>>>> [   39.416018]  [<ffffffff8140f3cc>] ? lruvec_lru_size+0x4c/0xa0
>>>> [   39.416018]  [<ffffffff8141bf1e>] kswapd+0x82e/0x1460
>>>> [   39.416018]  [<ffffffff8141b6f0>] ? mem_cgroup_shrink_node+0x600/0x600
>>>> [   39.416018]  [<ffffffff81171cc8>] ? finish_task_switch+0x178/0x5b0
>>>> [   39.416018]  [<ffffffff82956c2c>] ? _raw_spin_unlock_irq+0x2c/0x50
>>>> [   39.416018]  [<ffffffff811f6535>] ? trace_hardirqs_on_caller+0x405/0x590
>>>> [   39.416018]  [<ffffffff82956c37>] ? _raw_spin_unlock_irq+0x37/0x50
>>>> [   39.416018]  [<ffffffff81171cc8>] ? finish_task_switch+0x178/0x5b0
>>>> [   39.416018]  [<ffffffff811de8f0>] ? __wake_up_common+0x150/0x150
>>>> [   39.416018]  [<ffffffff82948c3e>] ? __schedule+0x55e/0x1b60
>>>> [   39.416018]  [<ffffffff81156a32>] ? __kthread_parkme+0x172/0x240
>>>> [   39.416018]  [<ffffffff81156d4a>] kthread+0x24a/0x2e0
>>>> [   39.416018]  [<ffffffff8141b6f0>] ? mem_cgroup_shrink_node+0x600/0x600
>>>> [   39.416018]  [<ffffffff81156b00>] ? __kthread_parkme+0x240/0x240
>>>> [   39.416018]  [<ffffffff81171c9c>] ? finish_task_switch+0x14c/0x5b0
>>>> [   39.416018]  [<ffffffff8295773f>] ret_from_fork+0x1f/0x40
>>>> [   39.416018]  [<ffffffff81156b00>] ? __kthread_parkme+0x240/0x240
>>>>
>>>> -- 
>>>>  Kirill A. Shutemov
>>>
>>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
