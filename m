Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 866BE6B0092
	for <linux-mm@kvack.org>; Mon, 24 Jan 2011 22:25:52 -0500 (EST)
Received: from mail06.corp.redhat.com (zmail06.collab.prod.int.phx2.redhat.com [10.5.5.45])
	by mx4-phx2.redhat.com (8.13.8/8.13.8) with ESMTP id p0P3PpEp014684
	for <linux-mm@kvack.org>; Mon, 24 Jan 2011 22:25:51 -0500
Date: Mon, 24 Jan 2011 22:25:50 -0500 (EST)
From: CAI Qian <caiqian@redhat.com>
Message-ID: <1141871353.139439.1295925950928.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
In-Reply-To: <431670486.139432.1295925891388.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
Subject: kswapd hung tasks
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is not always reproducible so far but I thought it would send it out anyway in case someone could spot the problem. Running some memory allocation using cpuset with swapping workloads (like oom02 in LTP) caused hung tasks in 2.6.38-rc2 kernel.

Is this something that it took a long time to move memory into the swap device?

Would this go away by replacing with a fast storage for swapping?

INFO: task kswapd1:275 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
kswapd1         D ffff88045dd8c5a0     0   275      2 0x00000000
 ffff88045dda5810 0000000000000046 0000000000011210 ffff880500000000
 0000000000014d40 ffff88045dd8c040 ffff88045dd8c5a0 ffff88045dda5fd8
 ffff88045dd8c5a8 0000000000014d40 ffff88045dda4010 0000000000014d40
Call Trace:
 [<ffffffff814a2330>] io_schedule+0x70/0xc0
 [<ffffffff8120463a>] get_request_wait+0xca/0x1a0
 [<ffffffff8107fd50>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff811fd197>] ? elv_merge+0x1d7/0x210
 [<ffffffff8120477b>] __make_request+0x6b/0x4d0
 [<ffffffff8100cb2e>] ? call_function_interrupt+0xe/0x20
 [<ffffffff8120259f>] generic_make_request+0x21f/0x5b0
 [<ffffffff810f7885>] ? mempool_alloc_slab+0x15/0x20
 [<ffffffff810f7a23>] ? mempool_alloc+0x63/0x150
 [<ffffffff812029b6>] submit_bio+0x86/0x110
 [<ffffffff810ffb96>] ? test_set_page_writeback+0x106/0x190
 [<ffffffff81127f63>] swap_writepage+0x83/0xd0
 [<ffffffff811048fe>] pageout+0x12e/0x310
 [<ffffffff81104efa>] shrink_page_list+0x41a/0x5a0
 [<ffffffff81105686>] shrink_inactive_list+0x166/0x480
 [<ffffffff81106023>] shrink_zone+0x363/0x4d0
 [<ffffffff810fa4e5>] ? zone_watermark_ok_safe+0xb5/0xd0
 [<ffffffff811077a9>] kswapd+0x949/0xbf0
 [<ffffffff81106e60>] ? kswapd+0x0/0xbf0
 [<ffffffff8107f6c6>] kthread+0x96/0xa0
 [<ffffffff8100cdc4>] kernel_thread_helper+0x4/0x10
 [<ffffffff8107f630>] ? kthread+0x0/0xa0
 [<ffffffff8100cdc0>] ? kernel_thread_helper+0x0/0x10
INFO: task kswapd2:276 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
kswapd2         D ffff88045dda79e0     0   276      2 0x00000000
 ffff88045dda9810 0000000000000046 0000000000011210 ffff880b00000000
 0000000000014d40 ffff88045dda7480 ffff88045dda79e0 ffff88045dda9fd8
 ffff88045dda79e8 0000000000014d40 ffff88045dda8010 0000000000014d40
Call Trace:
 [<ffffffff814a2330>] io_schedule+0x70/0xc0
 [<ffffffff8120463a>] get_request_wait+0xca/0x1a0
 [<ffffffff8107fd50>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff811fd197>] ? elv_merge+0x1d7/0x210
 [<ffffffff8120477b>] __make_request+0x6b/0x4d0
 [<ffffffff8120259f>] generic_make_request+0x21f/0x5b0
 [<ffffffff810f7885>] ? mempool_alloc_slab+0x15/0x20
 [<ffffffff810f7a23>] ? mempool_alloc+0x63/0x150
 [<ffffffff812029b6>] submit_bio+0x86/0x110
 [<ffffffff810ffb96>] ? test_set_page_writeback+0x106/0x190
 [<ffffffff81127f63>] swap_writepage+0x83/0xd0
 [<ffffffff811048fe>] pageout+0x12e/0x310
 [<ffffffff81104efa>] shrink_page_list+0x41a/0x5a0
 [<ffffffff81105686>] shrink_inactive_list+0x166/0x480
 [<ffffffff810fe7aa>] ? determine_dirtyable_memory+0x1a/0x30
 [<ffffffff81106023>] shrink_zone+0x363/0x4d0
 [<ffffffff810fa4e5>] ? zone_watermark_ok_safe+0xb5/0xd0
 [<ffffffff811077a9>] kswapd+0x949/0xbf0
 [<ffffffff81106e60>] ? kswapd+0x0/0xbf0
 [<ffffffff8107f6c6>] kthread+0x96/0xa0
 [<ffffffff8100cdc4>] kernel_thread_helper+0x4/0x10
 [<ffffffff8107f630>] ? kthread+0x0/0xa0
 [<ffffffff8100cdc0>] ? kernel_thread_helper+0x0/0x10
INFO: task jbd2/dm-0-8:1180 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
jbd2/dm-0-8     D ffff88045df370e0     0  1180      2 0x00000000
 ffff88045d34f430 0000000000000046 0000000000011210 ffff880b00000000
 0000000000014d40 ffff88045df36b80 ffff88045df370e0 ffff88045d34ffd8
 ffff88045df370e8 0000000000014d40 ffff88045d34e010 0000000000014d40
Call Trace:
 [<ffffffff814a2330>] io_schedule+0x70/0xc0
 [<ffffffff8120463a>] get_request_wait+0xca/0x1a0
 [<ffffffff8107fd50>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff811fd007>] ? elv_merge+0x47/0x210
 [<ffffffff8120477b>] __make_request+0x6b/0x4d0
 [<ffffffff8120259f>] generic_make_request+0x21f/0x5b0
 [<ffffffff810f7885>] ? mempool_alloc_slab+0x15/0x20
 [<ffffffff810f7a23>] ? mempool_alloc+0x63/0x150
 [<ffffffff8100c96e>] ? apic_timer_interrupt+0xe/0x20
 [<ffffffff812029b6>] submit_bio+0x86/0x110
 [<ffffffff810ffb96>] ? test_set_page_writeback+0x106/0x190
 [<ffffffff81127f63>] swap_writepage+0x83/0xd0
 [<ffffffff811048fe>] pageout+0x12e/0x310
 [<ffffffff81104efa>] shrink_page_list+0x41a/0x5a0
 [<ffffffff81105686>] shrink_inactive_list+0x166/0x480
 [<ffffffff8104c846>] ? enqueue_task+0x66/0x80
 [<ffffffff810fe7aa>] ? determine_dirtyable_memory+0x1a/0x30
 [<ffffffff81106023>] shrink_zone+0x363/0x4d0
 [<ffffffff8110470e>] ? shrink_slab+0x14e/0x180
 [<ffffffff8110675f>] do_try_to_free_pages+0xaf/0x4a0
 [<ffffffff81106dc2>] try_to_free_pages+0x92/0x130
 [<ffffffff8104c643>] ? __wake_up+0x53/0x70
 [<ffffffff810fc46b>] __alloc_pages_nodemask+0x3fb/0x760
 [<ffffffff8113349a>] alloc_pages_current+0x9a/0x100
 [<ffffffff810f55b7>] __page_cache_alloc+0x87/0x90
 [<ffffffff810f61ff>] find_or_create_page+0x4f/0xb0
 [<ffffffff8117575c>] __getblk+0xec/0x330
 [<ffffffffa0089bae>] jbd2_journal_get_descriptor_buffer+0x4e/0xb0 [jbd2]
 [<ffffffffa008307d>] jbd2_journal_commit_transaction+0x99d/0x13f0 [jbd2]
 [<ffffffff8106e2a3>] ? try_to_del_timer_sync+0x83/0xe0
 [<ffffffffa00882c8>] kjournald2+0xb8/0x220 [jbd2]
 [<ffffffff8107fd50>] ? autoremove_wake_function+0x0/0x40
 [<ffffffffa0088210>] ? kjournald2+0x0/0x220 [jbd2]
 [<ffffffff8107f6c6>] kthread+0x96/0xa0
 [<ffffffff8100cdc4>] kernel_thread_helper+0x4/0x10
 [<ffffffff8107f630>] ? kthread+0x0/0xa0
 [<ffffffff8100cdc0>] ? kernel_thread_helper+0x0/0x10
INFO: task irqbalance:3426 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
irqbalance      D ffff880c5e96c5a0     0  3426      1 0x00000080
 ffff880c5e911318 0000000000000086 0000000000011210 ffff881027b470c0
 0000000000014d40 ffff880c5e96c040 ffff880c5e96c5a0 ffff880c5e911fd8
 ffff880c5e96c5a8 0000000000014d40 ffff880c5e910010 0000000000014d40
Call Trace:
 [<ffffffff814a2330>] io_schedule+0x70/0xc0
 [<ffffffff8120463a>] get_request_wait+0xca/0x1a0
 [<ffffffff8107fd50>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff811fd197>] ? elv_merge+0x1d7/0x210
 [<ffffffff8120477b>] __make_request+0x6b/0x4d0
 [<ffffffff8120259f>] generic_make_request+0x21f/0x5b0
 [<ffffffff810f7885>] ? mempool_alloc_slab+0x15/0x20
 [<ffffffff810f7a23>] ? mempool_alloc+0x63/0x150
 [<ffffffff812029b6>] submit_bio+0x86/0x110
 [<ffffffff810ffb96>] ? test_set_page_writeback+0x106/0x190
 [<ffffffff81127f63>] swap_writepage+0x83/0xd0
 [<ffffffff811048fe>] pageout+0x12e/0x310
 [<ffffffff81104efa>] shrink_page_list+0x41a/0x5a0
 [<ffffffff81105686>] shrink_inactive_list+0x166/0x480
 [<ffffffff812198a9>] ? cpumask_next_and+0x29/0x50
 [<ffffffff8104d535>] ? select_idle_sibling+0x95/0x150
 [<ffffffff810fe7aa>] ? determine_dirtyable_memory+0x1a/0x30
 [<ffffffff81106023>] shrink_zone+0x363/0x4d0
 [<ffffffff810899f3>] ? ktime_get_ts+0xb3/0xf0
 [<ffffffff8110675f>] do_try_to_free_pages+0xaf/0x4a0
 [<ffffffff81106dc2>] try_to_free_pages+0x92/0x130
 [<ffffffff8104c643>] ? __wake_up+0x53/0x70
 [<ffffffff810fc46b>] __alloc_pages_nodemask+0x3fb/0x760
 [<ffffffff8113349a>] alloc_pages_current+0x9a/0x100
 [<ffffffff810fb6ce>] __get_free_pages+0xe/0x50
 [<ffffffff811dacd4>] inode_doinit_with_dentry+0x144/0x670
 [<ffffffff8107fc17>] ? bit_waitqueue+0x17/0xd0
 [<ffffffff811db21c>] selinux_d_instantiate+0x1c/0x20
 [<ffffffff811d2bfb>] security_d_instantiate+0x1b/0x30
 [<ffffffff8115da0a>] d_instantiate+0x4a/0x70
 [<ffffffff811a9a90>] proc_lookup_de+0xa0/0x100
 [<ffffffff811a9b0b>] proc_lookup+0x1b/0x20
 [<ffffffff811a3b27>] proc_root_lookup+0x27/0x50
 [<ffffffff81153d15>] d_alloc_and_lookup+0x45/0x90
 [<ffffffff8115e3f5>] ? d_lookup+0x35/0x60
 [<ffffffff81156701>] do_lookup+0x1e1/0x2c0
 [<ffffffff81156d5b>] link_path_walk+0x57b/0xa90
 [<ffffffff8115754b>] do_path_lookup+0x5b/0x130
 [<ffffffff811585e7>] do_filp_open+0x1f7/0x770
 [<ffffffff811391ee>] ? fallback_alloc+0x14e/0x270
 [<ffffffff81164105>] ? alloc_fd+0x95/0x160
 [<ffffffff81147669>] do_sys_open+0x69/0x110
 [<ffffffff81147750>] sys_open+0x20/0x30
 [<ffffffff8100bf82>] system_call_fastpath+0x16/0x1b

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
