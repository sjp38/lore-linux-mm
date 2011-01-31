Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 89A448D0039
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 16:00:01 -0500 (EST)
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e39.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p0VKkV1q011237
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 13:46:31 -0700
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p0VKwo8Q176822
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 13:58:51 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p0VKwoRt012894
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 13:58:50 -0700
Subject: Re: kswapd hung tasks in 2.6.38-rc1
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <1150342867.83404.1295513748640.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
References: 
	 <1150342867.83404.1295513748640.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Mon, 31 Jan 2011 12:58:48 -0800
Message-ID: <1296507528.7797.4609.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: CAI Qian <caiqian@redhat.com>
Cc: linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 2011-01-20 at 03:55 -0500, CAI Qian wrote:
> When running LTP oom01 [1] testing, the allocation process stopped
> processing right after starting to swap.

I'm seeing the same stuff, but on -rc2.  I thought it was
transparent-hugepage-related, but I don't see much of a trace of it in
the stack dumps.

http://sr71.net/~dave/ibm/config-v2.6.38-rc2

It happened to me as well around the time that things started to hit
swap.

[  723.702046] INFO: task kswapd0:706 blocked for more than 120 seconds.
[  723.708478] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  723.716289] kswapd0         D 000000010000f58a     0   706      2 0x00000000
[  723.723358]  ffff88083e183920 0000000000000046 0000000000000001 0000000000011c40
[  723.730815]  ffff88083f9af460 ffff88083f9af100 ffffffff81925020 ffffffff00000000
[  723.738270]  ffff88083fac94f0 000000103e183880 ffff88083dfa1d80 ffff88083d891308
[  723.745727] Call Trace:
[  723.748177]  [<ffffffff810ebb27>] ? mempool_alloc+0x47/0x120
[  723.753825]  [<ffffffff812ecbc6>] ? cfq_may_queue+0x56/0xe0
[  723.759388]  [<ffffffff815f0424>] io_schedule+0x44/0x60
[  723.764603]  [<ffffffff812dd13b>] get_request_wait+0xdb/0x170
[  723.770337]  [<ffffffff81099150>] ? autoremove_wake_function+0x0/0x40
[  723.776764]  [<ffffffff812d8e5b>] ? elv_merge+0x17b/0x1d0
[  723.782154]  [<ffffffff812df93e>] __make_request+0x6e/0x480
[  723.787716]  [<ffffffff812db9d2>] generic_make_request+0x282/0x3f0
[  723.793885]  [<ffffffff81164a2d>] ? bio_init+0x1d/0x40
[  723.799013]  [<ffffffff812df807>] submit_bio+0x67/0xe0
[  723.804141]  [<ffffffff810f2955>] ? test_set_page_writeback+0xc5/0x180
[  723.810656]  [<ffffffff81118cb0>] swap_writepage+0xa0/0xc0
[  723.816131]  [<ffffffff810f7a7c>] shrink_page_list+0x45c/0x800
[  723.821954]  [<ffffffff810f95be>] shrink_inactive_list+0x11e/0x3c0
[  723.828120]  [<ffffffff810f9af1>] shrink_zone+0x291/0x4c0
[  723.833509]  [<ffffffff810eff86>] ? zone_watermark_ok_safe+0xb6/0xd0
[  723.839848]  [<ffffffff810fa575>] kswapd+0x605/0x8a0
[  723.844802]  [<ffffffff810f9f70>] ? kswapd+0x0/0x8a0
[  723.849756]  [<ffffffff81098c77>] kthread+0x97/0xa0
[  723.854628]  [<ffffffff8103ba54>] kernel_thread_helper+0x4/0x10
[  723.860533]  [<ffffffff81098be0>] ? kthread+0x0/0xa0
[  723.865489]  [<ffffffff8103ba50>] ? kernel_thread_helper+0x0/0x10
[  723.871567] INFO: task kswapd1:707 blocked for more than 120 seconds.
[  723.877992] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  723.885800] kswapd1         D 000000010000f4ec     0   707      2 0x00000000
[  723.892869]  ffff88083e145920 0000000000000046 0000000000000001 0000000000011c40
[  723.900324]  ffff88083f9afb60 ffff88083f9af800 ffff88083f80b8c0 ffffffff0000000c
[  723.907781]  ffff88083fac94f0 000000103e145880 ffff88103e94c3c0 ffff88083d891308
[  723.915239] Call Trace:
[  723.917683]  [<ffffffff810ebb27>] ? mempool_alloc+0x47/0x120
[  723.923329]  [<ffffffff812ecbc6>] ? cfq_may_queue+0x56/0xe0
[  723.928891]  [<ffffffff815f0424>] io_schedule+0x44/0x60
[  723.934104]  [<ffffffff812dd13b>] get_request_wait+0xdb/0x170
[  723.939836]  [<ffffffff81099150>] ? autoremove_wake_function+0x0/0x40
[  723.946264]  [<ffffffff812d8e5b>] ? elv_merge+0x17b/0x1d0
[  723.951651]  [<ffffffff812df93e>] __make_request+0x6e/0x480
[  723.957212]  [<ffffffff812db9d2>] generic_make_request+0x282/0x3f0
[  723.963378]  [<ffffffff81164a2d>] ? bio_init+0x1d/0x40
[  723.968509]  [<ffffffff812df807>] submit_bio+0x67/0xe0
[  723.973636]  [<ffffffff810f2955>] ? test_set_page_writeback+0xc5/0x180
[  723.980151]  [<ffffffff81118cb0>] swap_writepage+0xa0/0xc0
[  723.985625]  [<ffffffff810f7a7c>] shrink_page_list+0x45c/0x800
[  723.991448]  [<ffffffff810f95be>] shrink_inactive_list+0x11e/0x3c0
[  723.997613]  [<ffffffff810f1cfa>] ? determine_dirtyable_memory+0x1a/0x40
[  724.004298]  [<ffffffff810f9af1>] shrink_zone+0x291/0x4c0
[  724.009686]  [<ffffffff810eff86>] ? zone_watermark_ok_safe+0xb6/0xd0
[  724.016024]  [<ffffffff810fa575>] kswapd+0x605/0x8a0
[  724.020981]  [<ffffffff810f9f70>] ? kswapd+0x0/0x8a0
[  724.025937]  [<ffffffff81098c77>] kthread+0x97/0xa0
[  724.030805]  [<ffffffff8103ba54>] kernel_thread_helper+0x4/0x10
[  724.036713]  [<ffffffff81098be0>] ? kthread+0x0/0xa0
[  724.041667]  [<ffffffff8103ba50>] ? kernel_thread_helper+0x0/0x10
[  724.047748] INFO: task kjournald:1908 blocked for more than 120 seconds.
[  724.054431] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  724.062240] kjournald       D 000000010000f8dd     0  1908      2 0x00000000
[  724.069309]  ffff88083e3795d0 0000000000000046 0000000000000000 0000000000011c40
[  724.076763]  ffff88083f93dbe0 ffff88083f93d880 ffff880840350840 ffffea0000000004
[  724.084214]  0000000000000001 ffff88083e3795f8 0000000000000202 0000000000000000
[  724.091670] Call Trace:
[  724.094116]  [<ffffffff812ecb9c>] ? cfq_may_queue+0x2c/0xe0
[  724.099676]  [<ffffffff815f0424>] io_schedule+0x44/0x60
[  724.104889]  [<ffffffff812dd13b>] get_request_wait+0xdb/0x170
[  724.110624]  [<ffffffff81099150>] ? autoremove_wake_function+0x0/0x40
[  724.117049]  [<ffffffff812d8e5b>] ? elv_merge+0x17b/0x1d0
[  724.122437]  [<ffffffff812df93e>] __make_request+0x6e/0x480
[  724.127999]  [<ffffffff812db9d2>] generic_make_request+0x282/0x3f0
[  724.134164]  [<ffffffff81164a2d>] ? bio_init+0x1d/0x40
[  724.139292]  [<ffffffff812df807>] submit_bio+0x67/0xe0
[  724.144418]  [<ffffffff810f2955>] ? test_set_page_writeback+0xc5/0x180
[  724.150931]  [<ffffffff81118cb0>] swap_writepage+0xa0/0xc0
[  724.156404]  [<ffffffff810f7a7c>] shrink_page_list+0x45c/0x800
[  724.162223]  [<ffffffff810f95be>] shrink_inactive_list+0x11e/0x3c0
[  724.168388]  [<ffffffff810f9af1>] shrink_zone+0x291/0x4c0
[  724.173775]  [<ffffffff810fa9db>] do_try_to_free_pages+0x9b/0x300
[  724.179853]  [<ffffffff810fae00>] try_to_free_pages+0x90/0x110
[  724.185674]  [<ffffffff810f02f5>] __alloc_pages_nodemask+0x355/0x730
[  724.192015]  [<ffffffff81123a9c>] alloc_pages_current+0x8c/0xd0
[  724.197921]  [<ffffffff810e9800>] __page_cache_alloc+0x10/0x20
[  724.203740]  [<ffffffff810e9ca1>] find_or_create_page+0x51/0xb0
[  724.209650]  [<ffffffff8116067f>] __getblk+0xdf/0x270
[  724.214693]  [<ffffffff811f7f56>] journal_get_descriptor_buffer+0x46/0xa0
[  724.221467]  [<ffffffff811f401a>] journal_commit_transaction+0xd7a/0xf30
[  724.228157]  [<ffffffff81087ec9>] ? try_to_del_timer_sync+0x49/0xe0
[  724.234411]  [<ffffffff811f73e0>] kjournald+0xe0/0x250
[  724.239540]  [<ffffffff81099150>] ? autoremove_wake_function+0x0/0x40
[  724.245968]  [<ffffffff811f7300>] ? kjournald+0x0/0x250
[  724.251182]  [<ffffffff81098c77>] kthread+0x97/0xa0
[  724.256051]  [<ffffffff8103ba54>] kernel_thread_helper+0x4/0x10
[  724.261960]  [<ffffffff81098be0>] ? kthread+0x0/0xa0
[  724.266913]  [<ffffffff8103ba50>] ? kernel_thread_helper+0x0/0x10
[  724.272993] INFO: task jbd2/sdc3-8:2298 blocked for more than 120 seconds.
[  724.279851] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  724.287660] jbd2/sdc3-8     D 000000010000f9d4     0  2298      2 0x00000000
[  724.294731]  ffff88083ef3d560 0000000000000046 ffff881000000000 0000000000011c40
[  724.302184]  ffff88083e3a7b60 ffff88083e3a7800 ffff880840350840 0000000000000004
[  724.309637]  ffff88103e8c8520 ffff88083d891308 ffff88083ef3d4c0 ffffffff812f52ba
[  724.317092] Call Trace:
[  724.319537]  [<ffffffff812f52ba>] ? rb_insert_color+0x8a/0xf0
[  724.325272]  [<ffffffff812ecbc6>] ? cfq_may_queue+0x56/0xe0
[  724.330832]  [<ffffffff815f0424>] io_schedule+0x44/0x60
[  724.336046]  [<ffffffff812dd13b>] get_request_wait+0xdb/0x170
[  724.341781]  [<ffffffff81099150>] ? autoremove_wake_function+0x0/0x40
[  724.348207]  [<ffffffff812d8e5b>] ? elv_merge+0x17b/0x1d0
[  724.353597]  [<ffffffff812df93e>] __make_request+0x6e/0x480
[  724.359156]  [<ffffffff812db9d2>] generic_make_request+0x282/0x3f0
[  724.365324]  [<ffffffff81164a2d>] ? bio_init+0x1d/0x40
[  724.370450]  [<ffffffff812df807>] submit_bio+0x67/0xe0
[  724.375579]  [<ffffffff810f2955>] ? test_set_page_writeback+0xc5/0x180
[  724.382091]  [<ffffffff81118cb0>] swap_writepage+0xa0/0xc0
[  724.387567]  [<ffffffff810f7a7c>] shrink_page_list+0x45c/0x800
[  724.393387]  [<ffffffff810f95be>] shrink_inactive_list+0x11e/0x3c0
[  724.399556]  [<ffffffff81070a99>] ? load_balance+0x1e9/0x1560
[  724.405293]  [<ffffffff810f9af1>] shrink_zone+0x291/0x4c0
[  724.410681]  [<ffffffff810fa9db>] do_try_to_free_pages+0x9b/0x300
[  724.416762]  [<ffffffff810fae00>] try_to_free_pages+0x90/0x110
[  724.422582]  [<ffffffff810f02f5>] __alloc_pages_nodemask+0x355/0x730
[  724.428926]  [<ffffffff81123a9c>] alloc_pages_current+0x8c/0xd0
[  724.434832]  [<ffffffff810e9800>] __page_cache_alloc+0x10/0x20
[  724.440653]  [<ffffffff810e9ca1>] find_or_create_page+0x51/0xb0
[  724.446560]  [<ffffffff8116067f>] __getblk+0xdf/0x270
[  724.451603]  [<ffffffff811ff807>] jbd2_journal_get_descriptor_buffer+0x47/0xa0
[  724.458809]  [<ffffffff811fb5d7>] jbd2_journal_commit_transaction+0x1247/0x1400
[  724.466099]  [<ffffffff81099150>] ? autoremove_wake_function+0x0/0x40
[  724.472528]  [<ffffffff811ffcf7>] kjournald2+0xb7/0x230
[  724.477743]  [<ffffffff81099150>] ? autoremove_wake_function+0x0/0x40
[  724.484172]  [<ffffffff811ffc40>] ? kjournald2+0x0/0x230
[  724.489474]  [<ffffffff81098c77>] kthread+0x97/0xa0
[  724.494343]  [<ffffffff8103ba54>] kernel_thread_helper+0x4/0x10
[  724.500248]  [<ffffffff81098be0>] ? kthread+0x0/0xa0
[  724.505206]  [<ffffffff8103ba50>] ? kernel_thread_helper+0x0/0x10
[  724.511286] INFO: task cron:2380 blocked for more than 120 seconds.
[  724.517537] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  724.525346] cron            D 00000001000126d4     0  2380      1 0x00000000
[  724.532418]  ffff88083ea235b8 0000000000000082 00e8c03100000000 0000000000011c40
[  724.539871]  ffff88083f86d520 ffff88083f86d1c0 ffff880840350840 90b88d4800000004
[  724.547327]  ffff88083ea23518 0000000000000046 00c7c748c68948da 0000000000000001
[  724.554782] Call Trace:
[  724.557226]  [<ffffffff812ecb9c>] ? cfq_may_queue+0x2c/0xe0
[  724.562789]  [<ffffffff815f0424>] io_schedule+0x44/0x60
[  724.568006]  [<ffffffff812dd13b>] get_request_wait+0xdb/0x170
[  724.573741]  [<ffffffff81099150>] ? autoremove_wake_function+0x0/0x40
[  724.580166]  [<ffffffff812d8e5b>] ? elv_merge+0x17b/0x1d0
[  724.585554]  [<ffffffff812df93e>] __make_request+0x6e/0x480
[  724.591114]  [<ffffffff812db9d2>] generic_make_request+0x282/0x3f0
[  724.597281]  [<ffffffff81164a2d>] ? bio_init+0x1d/0x40
[  724.602409]  [<ffffffff812df807>] submit_bio+0x67/0xe0
[  724.607538]  [<ffffffff810f2955>] ? test_set_page_writeback+0xc5/0x180
[  724.614053]  [<ffffffff81118cb0>] swap_writepage+0xa0/0xc0
[  724.619528]  [<ffffffff810f7a7c>] shrink_page_list+0x45c/0x800
[  724.625350]  [<ffffffff810f95be>] shrink_inactive_list+0x11e/0x3c0
[  724.631515]  [<ffffffff810f9af1>] shrink_zone+0x291/0x4c0
[  724.636903]  [<ffffffff810fa9db>] do_try_to_free_pages+0x9b/0x300
[  724.642985]  [<ffffffff810fae00>] try_to_free_pages+0x90/0x110
[  724.648805]  [<ffffffff810f02f5>] __alloc_pages_nodemask+0x355/0x730
[  724.655148]  [<ffffffff8112703c>] kmem_getpages+0x6c/0x160
[  724.660621]  [<ffffffff81127689>] fallback_alloc+0x119/0x1c0
[  724.666269]  [<ffffffff811277c5>] ____cache_alloc_node+0x95/0x150
[  724.672349]  [<ffffffff811281a3>] kmem_cache_alloc+0x103/0x170
[  724.678170]  [<ffffffff811439cb>] getname+0x3b/0x230
[  724.683124]  [<ffffffff81145b4a>] user_path_at+0x2a/0xa0
[  724.688425]  [<ffffffff812f68b0>] ? timerqueue_add+0x60/0xb0
[  724.694075]  [<ffffffff8109c891>] ? lock_hrtimer_base+0x31/0x60
[  724.699983]  [<ffffffff8109c961>] ? hrtimer_try_to_cancel+0x51/0xd0
[  724.706236]  [<ffffffff8109c9fd>] ? hrtimer_cancel+0x1d/0x30
[  724.711887]  [<ffffffff8113ba0a>] vfs_fstatat+0x4a/0x80
[  724.717100]  [<ffffffff8113ba7b>] vfs_stat+0x1b/0x20
[  724.722055]  [<ffffffff8113bc64>] sys_newstat+0x24/0x50
[  724.727270]  [<ffffffff8109cdb7>] ? sys_nanosleep+0x77/0x80
[  724.732832]  [<ffffffff8103ad2b>] system_call_fastpath+0x16/0x1b
[  724.738829] INFO: task sshd:2536 blocked for more than 120 seconds.
[  724.745080] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  724.752890] sshd            D 0000000100010811     0  2536   2508 0x00000000
[  724.759959]  ffff88083ddd9438 0000000000000082 ffff88083ddd9378 0000000000011c40
[  724.767413]  ffff88083fb0ebe0 ffff88083fb0e880 ffff88084039d880 ffff881000000008
[  724.774870]  0000000000000000 0000000000000000 0000000000000020 0000000000000046
[  724.782324] Call Trace:
[  724.784769]  [<ffffffff812e25ab>] ? alloc_io_context+0x1b/0x80
[  724.790591]  [<ffffffff812e263f>] ? current_io_context+0x2f/0x40
[  724.796586]  [<ffffffff815f0424>] io_schedule+0x44/0x60
[  724.801801]  [<ffffffff812dd13b>] get_request_wait+0xdb/0x170
[  724.807536]  [<ffffffff81099150>] ? autoremove_wake_function+0x0/0x40
[  724.813961]  [<ffffffff812d8e5b>] ? elv_merge+0x17b/0x1d0
[  724.819351]  [<ffffffff812df93e>] __make_request+0x6e/0x480
[  724.824914]  [<ffffffff812db9d2>] generic_make_request+0x282/0x3f0
[  724.831080]  [<ffffffff81164a2d>] ? bio_init+0x1d/0x40
[  724.836210]  [<ffffffff812df807>] submit_bio+0x67/0xe0
[  724.841337]  [<ffffffff810f2955>] ? test_set_page_writeback+0xc5/0x180
[  724.847850]  [<ffffffff81118cb0>] swap_writepage+0xa0/0xc0
[  724.853325]  [<ffffffff810f7a7c>] shrink_page_list+0x45c/0x800
[  724.859147]  [<ffffffff810f95be>] shrink_inactive_list+0x11e/0x3c0
[  724.865315]  [<ffffffff810f1cfa>] ? determine_dirtyable_memory+0x1a/0x40
[  724.872001]  [<ffffffff810f9af1>] shrink_zone+0x291/0x4c0
[  724.877388]  [<ffffffff810fa9db>] do_try_to_free_pages+0x9b/0x300
[  724.883466]  [<ffffffff810fae00>] try_to_free_pages+0x90/0x110
[  724.889290]  [<ffffffff810f02f5>] __alloc_pages_nodemask+0x355/0x730
[  724.895632]  [<ffffffff81123a9c>] alloc_pages_current+0x8c/0xd0
[  724.901539]  [<ffffffff81063a4b>] pte_alloc_one+0x1b/0x50
[  724.906926]  [<ffffffff811482c0>] ? pollwake+0x0/0x70
[  724.911969]  [<ffffffff81109fa7>] __pte_alloc+0x27/0x110
[  724.917270]  [<ffffffff8110a19f>] handle_mm_fault+0x10f/0x270
[  724.923004]  [<ffffffff815f52f1>] do_page_fault+0x161/0x480
[  724.928567]  [<ffffffff815f1ea4>] ? _raw_spin_unlock_bh+0x14/0x20
[  724.934646]  [<ffffffff81518519>] ? release_sock+0xd9/0x110
[  724.940210]  [<ffffffff81559339>] ? tcp_sendmsg+0x819/0xb80
[  724.945770]  [<ffffffff815f251f>] page_fault+0x1f/0x30
[  724.950897]  [<ffffffff812f992d>] ? copy_user_generic_string+0x2d/0x40
[  724.957411]  [<ffffffff81149243>] ? core_sys_select+0x1e3/0x2c0
[  724.963317]  [<ffffffff81137585>] ? do_sync_write+0xd5/0x120
[  724.968968]  [<ffffffff8116aa05>] ? fsnotify+0x1d5/0x2e0
[  724.974272]  [<ffffffff8114953b>] sys_select+0x4b/0x100
[  724.979485]  [<ffffffff811383f5>] ? sys_write+0x55/0x90
[  724.984701]  [<ffffffff8103ad2b>] system_call_fastpath+0x16/0x1b
[  724.990696] INFO: task qemu-system-x86:2731 blocked for more than 120 seconds.
[  724.997900] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  725.005710] qemu-system-x86 D 000000010000f685     0  2731   2692 0x00000000
[  725.012780]  ffff88083fa472c8 0000000000000082 0000000000000001 0000000000011c40
[  725.020237]  ffff88083fa693e0 ffff88083fa69080 ffff88084039d880 ffffffff00000008
[  725.027692]  ffff88083fac94f0 000000103fa47228 ffff88083fb947b0 ffff88083d891308
[  725.035146] Call Trace:
[  725.037589]  [<ffffffff810ebb27>] ? mempool_alloc+0x47/0x120
[  725.043236]  [<ffffffff812ecbc6>] ? cfq_may_queue+0x56/0xe0
[  725.048796]  [<ffffffff815f0424>] io_schedule+0x44/0x60
[  725.054010]  [<ffffffff812dd13b>] get_request_wait+0xdb/0x170
[  725.059746]  [<ffffffff81099150>] ? autoremove_wake_function+0x0/0x40
[  725.066170]  [<ffffffff812d8e5b>] ? elv_merge+0x17b/0x1d0
[  725.071560]  [<ffffffff812df93e>] __make_request+0x6e/0x480
[  725.077123]  [<ffffffff812db9d2>] generic_make_request+0x282/0x3f0
[  725.083289]  [<ffffffff81164a2d>] ? bio_init+0x1d/0x40
[  725.088415]  [<ffffffff812df807>] submit_bio+0x67/0xe0
[  725.093545]  [<ffffffff810f2955>] ? test_set_page_writeback+0xc5/0x180
[  725.100059]  [<ffffffff81118cb0>] swap_writepage+0xa0/0xc0
[  725.105535]  [<ffffffff810f7a7c>] shrink_page_list+0x45c/0x800
[  725.111358]  [<ffffffff810f95be>] shrink_inactive_list+0x11e/0x3c0
[  725.117523]  [<ffffffff810f1cfa>] ? determine_dirtyable_memory+0x1a/0x40
[  725.124211]  [<ffffffff810f9af1>] shrink_zone+0x291/0x4c0
[  725.129599]  [<ffffffff810fa9db>] do_try_to_free_pages+0x9b/0x300
[  725.135682]  [<ffffffff810fae00>] try_to_free_pages+0x90/0x110
[  725.141503]  [<ffffffff810f02f5>] __alloc_pages_nodemask+0x355/0x730
[  725.147841]  [<ffffffff81123a9c>] alloc_pages_current+0x8c/0xd0
[  725.153746]  [<ffffffff810ef25e>] __get_free_pages+0xe/0x50
[  725.159306]  [<ffffffff81148285>] __pollwait+0xc5/0x100
[  725.164521]  [<ffffffff815579d8>] tcp_poll+0x28/0x180
[  725.169564]  [<ffffffff815136fd>] sock_poll+0x1d/0x20
[  725.174604]  [<ffffffff81148d93>] do_select+0x3b3/0x680
[  725.179821]  [<ffffffff811481c0>] ? __pollwait+0x0/0x100
[  725.185125]  [<ffffffff811482c0>] ? pollwake+0x0/0x70
[  725.190165]  [<ffffffff811482c0>] ? pollwake+0x0/0x70
[  725.195207]  [<ffffffff811482c0>] ? pollwake+0x0/0x70
[  725.200250]  [<ffffffff811482c0>] ? pollwake+0x0/0x70
[  725.205290]  [<ffffffff811482c0>] ? pollwake+0x0/0x70
[  725.210331]  [<ffffffff811482c0>] ? pollwake+0x0/0x70
[  725.215371]  [<ffffffff811482c0>] ? pollwake+0x0/0x70
[  725.220412]  [<ffffffff811482c0>] ? pollwake+0x0/0x70
[  725.225453]  [<ffffffff811482c0>] ? pollwake+0x0/0x70
[  725.230495]  [<ffffffff8114921e>] core_sys_select+0x1be/0x2c0
[  725.236229]  [<ffffffff8116f605>] ? signalfd_read+0xd5/0x500
[  725.241875]  [<ffffffff812f68b0>] ? timerqueue_add+0x60/0xb0
[  725.247522]  [<ffffffff81170305>] ? eventfd_ctx_read+0x95/0x190
[  725.253431]  [<ffffffff8107fb39>] ? timespec_add_safe+0x39/0x70
[  725.259340]  [<ffffffff8114953b>] sys_select+0x4b/0x100
[  725.264556]  [<ffffffff8103ad2b>] system_call_fastpath+0x16/0x1b
[  725.270550] INFO: task qemu-system-x86:2733 blocked for more than 120 seconds.
[  725.277755] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  725.285562] qemu-system-x86 D 000000010000fbd6     0  2733   2692 0x00000000
[  725.292631]  ffff88103b95d238 0000000000000082 0000000000000001 0000000000011c40
[  725.300086]  ffff88103ea603a0 ffff88103ea60040 ffff88083f80b8c0 ffffffff0000000c
[  725.307541]  ffff88083fac94f0 000000103b95d198 ffff880102069b60 ffff88083d891308
[  725.314997] Call Trace:
[  725.317441]  [<ffffffff810ebb27>] ? mempool_alloc+0x47/0x120
[  725.323088]  [<ffffffff812ecbc6>] ? cfq_may_queue+0x56/0xe0
[  725.328650]  [<ffffffff815f0424>] io_schedule+0x44/0x60
[  725.333865]  [<ffffffff812dd13b>] get_request_wait+0xdb/0x170
[  725.339601]  [<ffffffff81099150>] ? autoremove_wake_function+0x0/0x40
[  725.346026]  [<ffffffff812d8e5b>] ? elv_merge+0x17b/0x1d0
[  725.351415]  [<ffffffff812df93e>] __make_request+0x6e/0x480
[  725.356977]  [<ffffffff812db9d2>] generic_make_request+0x282/0x3f0
[  725.363145]  [<ffffffff81164a2d>] ? bio_init+0x1d/0x40
[  725.368274]  [<ffffffff812df807>] submit_bio+0x67/0xe0
[  725.373400]  [<ffffffff810f2955>] ? test_set_page_writeback+0xc5/0x180
[  725.379914]  [<ffffffff81118cb0>] swap_writepage+0xa0/0xc0
[  725.385386]  [<ffffffff810f7a7c>] shrink_page_list+0x45c/0x800
[  725.391208]  [<ffffffff810f95be>] shrink_inactive_list+0x11e/0x3c0
[  725.397373]  [<ffffffff810f1cfa>] ? determine_dirtyable_memory+0x1a/0x40
[  725.404060]  [<ffffffff810f9af1>] shrink_zone+0x291/0x4c0
[  725.409448]  [<ffffffff810f70f9>] ? shrink_slab+0x149/0x180
[  725.415008]  [<ffffffff810fa9db>] do_try_to_free_pages+0x9b/0x300
[  725.421089]  [<ffffffff810fae00>] try_to_free_pages+0x90/0x110
[  725.426909]  [<ffffffff810f02f5>] __alloc_pages_nodemask+0x355/0x730
[  725.433251]  [<ffffffff81123a9c>] alloc_pages_current+0x8c/0xd0
[  725.439159]  [<ffffffff81063a4b>] pte_alloc_one+0x1b/0x50
[  725.444548]  [<ffffffff81109fa7>] __pte_alloc+0x27/0x110
[  725.449848]  [<ffffffff8110a19f>] handle_mm_fault+0x10f/0x270
[  725.455582]  [<ffffffff8110a44f>] __get_user_pages+0x14f/0x490
[  725.461406]  [<ffffffff81001e69>] ? kvm_read_guest_page+0x39/0x80
[  725.467487]  [<ffffffff8110a7e2>] get_user_pages+0x52/0x60
[  725.472963]  [<ffffffff810642c4>] get_user_pages_fast+0x134/0x160
[  725.479042]  [<ffffffff810029a1>] hva_to_pfn+0xc1/0x280
[  725.484257]  [<ffffffff81002c4f>] __gfn_to_pfn+0xbf/0xe0
[  725.489560]  [<ffffffff81002cca>] gfn_to_pfn_async+0x1a/0x20
[  725.495208]  [<ffffffff8101f6fb>] try_async_pf+0x4b/0x1e0
[  725.500598]  [<ffffffff81001232>] ? gfn_to_memslot+0x12/0x20
[  725.506244]  [<ffffffff810012af>] ? gfn_to_hva+0x1f/0x30
[  725.511543]  [<ffffffff81004296>] ? kvm_host_page_size+0x86/0x90
[  725.517538]  [<ffffffff810241ff>] tdp_page_fault+0xef/0x1d0
[  725.523100]  [<ffffffff8103316a>] ? vmx_set_interrupt_shadow+0x1a/0x50
[  725.529614]  [<ffffffff8102080c>] kvm_mmu_page_fault+0x2c/0x90
[  725.535435]  [<ffffffff81033cc0>] handle_ept_violation+0x80/0x150
[  725.541515]  [<ffffffff8103716a>] vmx_handle_exit+0xba/0x4e0
[  725.547162]  [<ffffffff8102f65f>] ? apic_update_ppr+0x3f/0x90
[  725.552897]  [<ffffffff8109ea74>] ? sched_clock_cpu+0x24/0xf0
[  725.558632]  [<ffffffff810180d1>] kvm_arch_vcpu_ioctl_run+0x4e1/0xe00
[  725.565057]  [<ffffffff81017797>] ? kvm_arch_vcpu_load+0x47/0x120
[  725.571140]  [<ffffffff81006bf2>] kvm_vcpu_ioctl+0x4d2/0x5c0
[  725.576787]  [<ffffffff81003ca0>] ? kvm_vm_ioctl+0xa0/0x3c0
[  725.582346]  [<ffffffff81515cc7>] ? sys_sendto+0x137/0x140
[  725.587819]  [<ffffffff81146e1d>] vfs_ioctl+0x1d/0x50
[  725.592861]  [<ffffffff81146fb5>] do_vfs_ioctl+0xa5/0x4e0
[  725.598251]  [<ffffffff810a8d43>] ? sys_futex+0x83/0x140
[  725.603553]  [<ffffffff8114743f>] sys_ioctl+0x4f/0x80
[  725.608596]  [<ffffffff8103ad2b>] system_call_fastpath+0x16/0x1b
[  725.614587] INFO: task qemu-system-x86:2736 blocked for more than 120 seconds.
[  725.621790] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  725.629600] qemu-system-x86 D 000000010000f67d     0  2736   2692 0x00000000
[  725.636669]  ffff88102de7f508 0000000000000082 ffff88083d891308 0000000000011c40
[  725.644128]  ffff88103ea5fc20 ffff88103ea5f8c0 ffff88084039d880 ffff880800000008
[  725.651584]  ffffffff8192d4a0 ffffffff811269b8 ffff88102de7f478 ffff88083faaecc0
[  725.659040] Call Trace:
[  725.661483]  [<ffffffff811269b8>] ? transfer_objects+0x58/0x80
[  725.667304]  [<ffffffff811279af>] ? cache_alloc_refill+0x9f/0x260
[  725.673383]  [<ffffffff812ecbc6>] ? cfq_may_queue+0x56/0xe0
[  725.678944]  [<ffffffff815f0424>] io_schedule+0x44/0x60
[  725.684159]  [<ffffffff812dd13b>] get_request_wait+0xdb/0x170
[  725.689893]  [<ffffffff81099150>] ? autoremove_wake_function+0x0/0x40
[  725.696319]  [<ffffffff812d8e5b>] ? elv_merge+0x17b/0x1d0
[  725.701708]  [<ffffffff812df93e>] __make_request+0x6e/0x480
[  725.707271]  [<ffffffff812db9d2>] generic_make_request+0x282/0x3f0
[  725.713437]  [<ffffffff81164a2d>] ? bio_init+0x1d/0x40
[  725.718568]  [<ffffffff812df807>] submit_bio+0x67/0xe0
[  725.723695]  [<ffffffff810f2955>] ? test_set_page_writeback+0xc5/0x180
[  725.730209]  [<ffffffff81118cb0>] swap_writepage+0xa0/0xc0
[  725.735685]  [<ffffffff810f7a7c>] shrink_page_list+0x45c/0x800
[  725.741506]  [<ffffffff810f95be>] shrink_inactive_list+0x11e/0x3c0
[  725.747673]  [<ffffffff810f1cfa>] ? determine_dirtyable_memory+0x1a/0x40
[  725.754360]  [<ffffffff810f9af1>] shrink_zone+0x291/0x4c0
[  725.759750]  [<ffffffff810fa9db>] do_try_to_free_pages+0x9b/0x300
[  725.765831]  [<ffffffff810fae00>] try_to_free_pages+0x90/0x110
[  725.771653]  [<ffffffff810f02f5>] __alloc_pages_nodemask+0x355/0x730
[  725.778000]  [<ffffffff81123a9c>] alloc_pages_current+0x8c/0xd0
[  725.783906]  [<ffffffff810e9800>] __page_cache_alloc+0x10/0x20
[  725.789725]  [<ffffffff810f2f82>] __do_page_cache_readahead+0xe2/0x220
[  725.796236]  [<ffffffff810f30e1>] ra_submit+0x21/0x30
[  725.801278]  [<ffffffff810f3288>] ondemand_readahead+0xa8/0x1d0
[  725.807186]  [<ffffffff810f34a6>] page_cache_sync_readahead+0x36/0x50
[  725.813614]  [<ffffffff810ead0a>] generic_file_aio_read+0x57a/0x6f0
[  725.819865]  [<ffffffff8106a72b>] ? __wake_up_common+0x5b/0x90
[  725.825688]  [<ffffffff811376a5>] do_sync_read+0xd5/0x120
[  725.831075]  [<ffffffff8108c0e2>] ? group_send_sig_info+0x52/0x60
[  725.837157]  [<ffffffff8108c13b>] ? kill_pid_info+0x4b/0x70
[  725.842717]  [<ffffffff8108ca44>] ? sys_kill+0x94/0x190
[  725.847930]  [<ffffffff81137ebb>] vfs_read+0xcb/0x170
[  725.852972]  [<ffffffff811384ba>] sys_pread64+0x8a/0x90
[  725.858186]  [<ffffffff8103ad2b>] system_call_fastpath+0x16/0x1b
[  725.864180] INFO: task memknobs:2751 blocked for more than 120 seconds.
[  725.870778] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  725.878588] memknobs        D 000000010000f603     0  2751   2617 0x00000000
[  725.885656]  ffff88083e57d6b8 0000000000000082 0000000000000001 0000000000011c40
[  725.893111]  ffff88083fb0ab20 ffff88083fb0a7c0 ffffffff81925020 ffffffff00000000
[  725.900567]  ffff88083fac94f0 000000103e57d618 ffff88083d8a15e0 ffff88083d891308
[  725.908021] Call Trace:
[  725.910467]  [<ffffffff810ebb27>] ? mempool_alloc+0x47/0x120
[  725.916115]  [<ffffffff812ecbc6>] ? cfq_may_queue+0x56/0xe0
[  725.921676]  [<ffffffff815f0424>] io_schedule+0x44/0x60
[  725.926890]  [<ffffffff812dd13b>] get_request_wait+0xdb/0x170
[  725.932623]  [<ffffffff81099150>] ? autoremove_wake_function+0x0/0x40
[  725.939050]  [<ffffffff812d8e5b>] ? elv_merge+0x17b/0x1d0
[  725.944437]  [<ffffffff812df93e>] __make_request+0x6e/0x480
[  725.949998]  [<ffffffff812db9d2>] generic_make_request+0x282/0x3f0
[  725.956165]  [<ffffffff81164a2d>] ? bio_init+0x1d/0x40
[  725.961292]  [<ffffffff812df807>] submit_bio+0x67/0xe0
[  725.966418]  [<ffffffff810f2955>] ? test_set_page_writeback+0xc5/0x180
[  725.972933]  [<ffffffff81118cb0>] swap_writepage+0xa0/0xc0
[  725.978406]  [<ffffffff810f7a7c>] shrink_page_list+0x45c/0x800
[  725.984228]  [<ffffffff810f95be>] shrink_inactive_list+0x11e/0x3c0
[  725.990394]  [<ffffffff810f1cfa>] ? determine_dirtyable_memory+0x1a/0x40
[  725.997081]  [<ffffffff810f9af1>] shrink_zone+0x291/0x4c0
[  726.002471]  [<ffffffff810fa9db>] do_try_to_free_pages+0x9b/0x300
[  726.008551]  [<ffffffff810fae00>] try_to_free_pages+0x90/0x110
[  726.014373]  [<ffffffff810f02f5>] __alloc_pages_nodemask+0x355/0x730
[  726.020714]  [<ffffffff810e94e0>] ? sync_page+0x0/0x60
[  726.025845]  [<ffffffff81123a9c>] alloc_pages_current+0x8c/0xd0
[  726.031751]  [<ffffffff81063a4b>] pte_alloc_one+0x1b/0x50
[  726.037141]  [<ffffffff81109fa7>] __pte_alloc+0x27/0x110
[  726.042445]  [<ffffffff8110a19f>] handle_mm_fault+0x10f/0x270
[  726.048179]  [<ffffffff815f52f1>] do_page_fault+0x161/0x480
[  726.053740]  [<ffffffff8108ae63>] ? do_sigaction+0x103/0x1a0
[  726.059388]  [<ffffffff8108d9e9>] ? sys_rt_sigaction+0x89/0xc0
[  726.065207]  [<ffffffff815f251f>] page_fault+0x1f/0x30

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
