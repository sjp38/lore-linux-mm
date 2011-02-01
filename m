Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 72DF98D0039
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 20:43:30 -0500 (EST)
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p111SpkL021327
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 18:28:51 -0700
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p111hLVQ127186
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 18:43:21 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p111hK2X002363
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 18:43:20 -0700
Subject: Re: kswapd hung tasks in 2.6.38-rc1
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20110131231301.GP16981@random.random>
References: 
	 <1150342867.83404.1295513748640.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
	 <1296507528.7797.4609.camel@nimitz> <1296513616.7797.4929.camel@nimitz>
	 <20110131231301.GP16981@random.random>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Mon, 31 Jan 2011 17:43:19 -0800
Message-ID: <1296524599.27022.439.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: CAI Qian <caiqian@redhat.com>, linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 2011-02-01 at 00:13 +0100, Andrea Arcangeli wrote:
> On Mon, Jan 31, 2011 at 02:40:16PM -0800, Dave Hansen wrote:
> > Still not a very good data point, but I ran a heavy swap load for an
> > hour or so without reproducing this.  But, it happened again after I
> > enabled transparent huge pages.  I managed to get a sysrq-t dump out of
> > it:
> > 
> > 	http://sr71.net/~dave/ibm/2.6.38-rc2-hang-0.txt
> > 
> > khugepaged is one of the three running tasks.  Note, I set both its
> > sleep timeouts to zero to stress it out a bit.
> 
> sysrq+l? sysrq+t doesn't provide interesting info for running tasks.

Got one again.  Took ~3 hours to reproduce this time, but I don't think
I was hitting swap very hard most of the time.

Here's sysrq+l pasted.  sysrq-t is here:

	http://sr71.net/~dave/ibm/2.6.38-rc2-hang-1.txt

[ 9834.262374] SysRq : Show backtrace of all active CPUs
[ 9834.267437] CPU0:
[ 9834.269360] CPU 0 
[ 9834.271197] Modules linked in:
[ 9834.274455] 
[ 9834.275948] Pid: 0, comm: swapper Not tainted 2.6.38-rc2-dirty #119 49Y6512     /System x3650 M2 -[7947AC1]-
[ 9834.285748] RIP: 0010:[<ffffffff81348d3d>]  [<ffffffff81348d3d>] acpi_idle_enter_bm+0x22e/0x265
[ 9834.294443] RSP: 0000:ffffffff818c9ec8  EFLAGS: 00000246
[ 9834.299742] RAX: 00000000000009db RBX: ffffffff8109dbce RCX: 00000000000003e8
[ 9834.306857] RDX: 0000000000000119 RSI: 0000000000000001 RDI: 0000000000000000
[ 9834.313971] RBP: ffffffff818c9ef8 R08: 0000000000000001 R09: 0000000000000020
[ 9834.321086] R10: 0000000000000000 R11: 0000000000000000 R12: ffffffff815f1ece
[ 9834.328201] R13: ffff88083e786800 R14: ffff88083e786820 R15: ffff88083e78680c
[ 9834.335317] FS:  0000000000000000(0000) GS:ffff88007a800000(0000) knlGS:0000000000000000
[ 9834.343386] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 9834.349116] CR2: 00007f9b2eaf5720 CR3: 000000000191b000 CR4: 00000000000006f0
[ 9834.356231] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 9834.363346] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 9834.370461] Process swapper (pid: 0, threadinfo ffffffff818c8000, task ffffffff81923020)
[ 9834.378530] Stack:
[ 9834.380540]  ffffffff818c9ef8 00000000814f76b6 ffff88083e786820 ffff88083e7868f0
[ 9834.387992]  0000000000000000 0000000000000002 ffffffff818c9f38 ffffffff814f68a9
[ 9834.395442]  ffffffff818c9f18 ffffffff819aaf80 6db6db6db6db6db7 000000000000001f
[ 9834.402893] Call Trace:
[ 9834.405338]  [<ffffffff814f68a9>] cpuidle_idle_call+0xb9/0x210
[ 9834.411159]  [<ffffffff81039c87>] cpu_idle+0x47/0x80
[ 9834.416113]  [<ffffffff815c61f2>] rest_init+0x72/0x80
[ 9834.421152]  [<ffffffff819c3dff>] start_kernel+0x2ff/0x3e0
[ 9834.426626]  [<ffffffff819c3271>] x86_64_start_reservations+0x81/0xd0
[ 9834.433049]  [<ffffffff819c339d>] x86_64_start_kernel+0xdd/0x100
[ 9834.439041] Code: 89 d5 ff 48 89 c6 ba e8 03 00 00 48 29 de 48 89 d1 31 d2 48 89 f0 48 89 f7 48 f7 f1 48 89 c3 e8 ba 5e d5 ff fb 41 80 7c 24 08 01 <74> 10 65 48 8b 04 25 08 b7 00 00 83 88 3c e0 ff ff 04 41 ff 44 
[ 9834.459137] Call Trace:
[ 9834.461580]  [<ffffffff814f68a9>] cpuidle_idle_call+0xb9/0x210
[ 9834.467399]  [<ffffffff81039c87>] cpu_idle+0x47/0x80
[ 9834.472353]  [<ffffffff815c61f2>] rest_init+0x72/0x80
[ 9834.477391]  [<ffffffff819c3dff>] start_kernel+0x2ff/0x3e0
[ 9834.482864]  [<ffffffff819c3271>] x86_64_start_reservations+0x81/0xd0
[ 9834.489287]  [<ffffffff819c339d>] x86_64_start_kernel+0xdd/0x100
[ 9834.495337] CPU4:
[ 9834.497266]  ffff88107fc03ef8 0000000000000046 0000000000000004 ffffffff8135edc0
[ 9834.504721]  ffff88087fffc2d8 ffff88083e067bd0 ffff88107fc03f38 ffffffff8103e74a
[ 9834.512175]  ffff88107fc03f58 ffffffff8135ee0d ffff88107fc03f68 ffff88007a812580
[ 9834.519633] Call Trace:
[ 9834.522077]  <IRQ>  [<ffffffff8135edc0>] ? showacpu+0x0/0x70
[ 9834.527747]  [<ffffffff8103e74a>] ? show_stack+0x1a/0x20
[ 9834.533049]  [<ffffffff8135ee0d>] ? showacpu+0x4d/0x70
[ 9834.538179]  [<ffffffff810aabcb>] ? generic_smp_call_function_interrupt+0x7b/0x170
[ 9834.545733]  [<ffffffff81053c27>] ? smp_call_function_interrupt+0x27/0x40
[ 9834.552505]  [<ffffffff8103b7d3>] ? call_function_interrupt+0x13/0x20
[ 9834.558927]  <EOI>  [<ffffffff810f99cd>] ? shrink_zone+0x16d/0x4c0
[ 9834.565113]  [<ffffffff810fa9db>] ? do_try_to_free_pages+0x9b/0x300
[ 9834.571365]  [<ffffffff810fae00>] ? try_to_free_pages+0x90/0x110
[ 9834.577360]  [<ffffffff810f02f5>] ? __alloc_pages_nodemask+0x355/0x730
[ 9834.583873]  [<ffffffff815f018e>] ? schedule_timeout+0x11e/0x250
[ 9834.589866]  [<ffffffff811223e2>] ? alloc_pages_vma+0x82/0x130
[ 9834.595687]  [<ffffffff8112de30>] ? khugepaged+0x8c0/0x10c0
[ 9834.601249]  [<ffffffff81099150>] ? autoremove_wake_function+0x0/0x40
[ 9834.607673]  [<ffffffff8112d570>] ? khugepaged+0x0/0x10c0
[ 9834.613059]  [<ffffffff81098c77>] ? kthread+0x97/0xa0
[ 9834.618099]  [<ffffffff8103ba54>] ? kernel_thread_helper+0x4/0x10
[ 9834.624176]  [<ffffffff81098be0>] ? kthread+0x0/0xa0
[ 9834.629132]  [<ffffffff8103ba50>] ? kernel_thread_helper+0x0/0x10

And the hung task messages:

[ 9687.185858] INFO: task kswapd0:706 blocked for more than 120 seconds.
[ 9687.192291] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[ 9687.200102] kswapd0         D 000000010022f817     0   706      2 0x00000000
[ 9687.207173]  ffff88083e75f920 0000000000000046 0000000000000001 0000000000011c40
[ 9687.214627]  ffff88083f998b60 ffff88083f998800 ffff880840309880 ffffffff00000001
[ 9687.222080]  ffff88083de8c9f0 000000103e75f880 ffff8805724a3880 ffff88083e7e3308
[ 9687.229532] Call Trace:
[ 9687.231986]  [<ffffffff810ebb27>] ? mempool_alloc+0x47/0x120
[ 9687.237634]  [<ffffffff812ec7c6>] ? cfq_may_queue+0x56/0xe0
[ 9687.243201]  [<ffffffff815effe4>] io_schedule+0x44/0x60
[ 9687.248421]  [<ffffffff812dcd3b>] get_request_wait+0xdb/0x170
[ 9687.254154]  [<ffffffff81099150>] ? autoremove_wake_function+0x0/0x40
[ 9687.260581]  [<ffffffff812d8927>] ? elv_merge+0x47/0x1d0
[ 9687.265882]  [<ffffffff812df53e>] __make_request+0x6e/0x480
[ 9687.271446]  [<ffffffff812db5d2>] generic_make_request+0x282/0x3f0
[ 9687.277612]  [<ffffffff811646ed>] ? bio_init+0x1d/0x40
[ 9687.282741]  [<ffffffff812df407>] submit_bio+0x67/0xe0
[ 9687.287869]  [<ffffffff810f2955>] ? test_set_page_writeback+0xc5/0x180
[ 9687.294386]  [<ffffffff81118ca0>] swap_writepage+0xa0/0xc0
[ 9687.299860]  [<ffffffff810f7a7c>] shrink_page_list+0x45c/0x800
[ 9687.305682]  [<ffffffff810f95be>] shrink_inactive_list+0x11e/0x3c0
[ 9687.311849]  [<ffffffff810f9af1>] shrink_zone+0x291/0x4c0
[ 9687.317239]  [<ffffffff810eff86>] ? zone_watermark_ok_safe+0xb6/0xd0
[ 9687.323579]  [<ffffffff810fa575>] kswapd+0x605/0x8a0
[ 9687.328534]  [<ffffffff810f9f70>] ? kswapd+0x0/0x8a0
[ 9687.333488]  [<ffffffff81098c77>] kthread+0x97/0xa0
[ 9687.338362]  [<ffffffff8103ba54>] kernel_thread_helper+0x4/0x10
[ 9687.344269]  [<ffffffff81098be0>] ? kthread+0x0/0xa0
[ 9687.349225]  [<ffffffff8103ba50>] ? kernel_thread_helper+0x0/0x10
[ 9687.355303] INFO: task kswapd1:707 blocked for more than 120 seconds.
[ 9687.361725] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[ 9687.369537] kswapd1         D 000000010022f812     0   707      2 0x00000000
[ 9687.376609]  ffff88083e705920 0000000000000046 0000000000000001 0000000000011c40
[ 9687.384062]  ffff88083f998460 ffff88083f998100 ffff88083f80b8c0 ffffffff0000000c
[ 9687.391518]  ffff88083de8c9f0 000000103e705880 ffff880ee402b880 ffff88083e7e3308
[ 9687.398971] Call Trace:
[ 9687.401414]  [<ffffffff810ebb27>] ? mempool_alloc+0x47/0x120
[ 9687.407062]  [<ffffffff812ec7c6>] ? cfq_may_queue+0x56/0xe0
[ 9687.412625]  [<ffffffff815effe4>] io_schedule+0x44/0x60
[ 9687.417842]  [<ffffffff812dcd3b>] get_request_wait+0xdb/0x170
[ 9687.423576]  [<ffffffff81099150>] ? autoremove_wake_function+0x0/0x40
[ 9687.430002]  [<ffffffff812d8a5b>] ? elv_merge+0x17b/0x1d0
[ 9687.435392]  [<ffffffff812df53e>] __make_request+0x6e/0x480
[ 9687.440952]  [<ffffffff812db5d2>] generic_make_request+0x282/0x3f0
[ 9687.447121]  [<ffffffff811646ed>] ? bio_init+0x1d/0x40
[ 9687.452251]  [<ffffffff812df407>] submit_bio+0x67/0xe0
[ 9687.457377]  [<ffffffff810f2955>] ? test_set_page_writeback+0xc5/0x180
[ 9687.463889]  [<ffffffff81118ca0>] swap_writepage+0xa0/0xc0
[ 9687.469364]  [<ffffffff810f7a7c>] shrink_page_list+0x45c/0x800
[ 9687.475183]  [<ffffffff810f95be>] shrink_inactive_list+0x11e/0x3c0
[ 9687.481349]  [<ffffffff810f9af1>] shrink_zone+0x291/0x4c0
[ 9687.486741]  [<ffffffff810eff86>] ? zone_watermark_ok_safe+0xb6/0xd0
[ 9687.493082]  [<ffffffff810fa575>] kswapd+0x605/0x8a0
[ 9687.498038]  [<ffffffff810f9f70>] ? kswapd+0x0/0x8a0
[ 9687.502992]  [<ffffffff81098c77>] kthread+0x97/0xa0
[ 9687.507862]  [<ffffffff8103ba54>] kernel_thread_helper+0x4/0x10
[ 9687.513768]  [<ffffffff81098be0>] ? kthread+0x0/0xa0
[ 9687.518723]  [<ffffffff8103ba50>] ? kernel_thread_helper+0x0/0x10
[ 9687.524805] INFO: task memknobs:2741 blocked for more than 120 seconds.
[ 9687.531403] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[ 9687.539211] memknobs        D 000000010022f7f5     0  2741   2674 0x00000000
[ 9687.546282]  ffff88103e3ffc68 0000000000000086 ffff88083faa8f40 0000000000011c40
[ 9687.553735]  ffff88103eb024a0 ffff88103eb02140 ffff88083f818800 ffff88080000000e
[ 9687.561189]  0000000000000008 000000000081f4c7 ffff88103e3ffc38 ffffffff812db5d2
[ 9687.568644] Call Trace:
[ 9687.571089]  [<ffffffff812db5d2>] ? generic_make_request+0x282/0x3f0
[ 9687.577429]  [<ffffffff811646ed>] ? bio_init+0x1d/0x40
[ 9687.582556]  [<ffffffff815effe4>] io_schedule+0x44/0x60
[ 9687.587769]  [<ffffffff810e9525>] sync_page+0x45/0x60
[ 9687.592811]  [<ffffffff815f04be>] __wait_on_bit+0x5e/0x90
[ 9687.598197]  [<ffffffff810e94e0>] ? sync_page+0x0/0x60
[ 9687.603324]  [<ffffffff810e9724>] wait_on_page_bit+0x74/0x80
[ 9687.608973]  [<ffffffff81099190>] ? wake_bit_function+0x0/0x40
[ 9687.614795]  [<ffffffff812f3abe>] ? radix_tree_lookup_slot+0xe/0x10
[ 9687.621048]  [<ffffffff810e97dc>] __lock_page_or_retry+0x4c/0x60
[ 9687.627043]  [<ffffffff81108adf>] handle_pte_fault+0x79f/0x7c0
[ 9687.632864]  [<ffffffff810ef167>] ? __free_pages+0x27/0x30
[ 9687.638340]  [<ffffffff8110a031>] ? __pte_alloc+0xb1/0x110
[ 9687.643813]  [<ffffffff8110a1f2>] handle_mm_fault+0x162/0x270
[ 9687.649547]  [<ffffffff815f4eb1>] do_page_fault+0x161/0x480
[ 9687.655108]  [<ffffffff8108ae63>] ? do_sigaction+0x103/0x1a0
[ 9687.660758]  [<ffffffff8108d9e9>] ? sys_rt_sigaction+0x89/0xc0
[ 9687.666578]  [<ffffffff815f20df>] page_fault+0x1f/0x30
[ 9687.671708] INFO: task memknobs:2794 blocked for more than 120 seconds.
[ 9687.678308] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[ 9687.686117] memknobs        D 000000010022f90a     0  2794   2724 0x00000000
[ 9687.693187]  ffff880c66627c68 0000000000000082 ffff88083faa8f40 0000000000011c40
[ 9687.700639]  ffff88103e26cae0 ffff88103e26c780 ffffffff81923020 ffff880800000000
[ 9687.708095]  0000000000000008 0000000000821ba7 ffff880c66627c38 ffffffff812db5d2
[ 9687.715551] Call Trace:
[ 9687.717998]  [<ffffffff812db5d2>] ? generic_make_request+0x282/0x3f0
[ 9687.724338]  [<ffffffff815effe4>] io_schedule+0x44/0x60
[ 9687.729555]  [<ffffffff810e9525>] sync_page+0x45/0x60
[ 9687.734597]  [<ffffffff815f04be>] __wait_on_bit+0x5e/0x90
[ 9687.739984]  [<ffffffff810e94e0>] ? sync_page+0x0/0x60
[ 9687.745112]  [<ffffffff810e9724>] wait_on_page_bit+0x74/0x80
[ 9687.750759]  [<ffffffff81099190>] ? wake_bit_function+0x0/0x40
[ 9687.756578]  [<ffffffff812f3abe>] ? radix_tree_lookup_slot+0xe/0x10
[ 9687.762830]  [<ffffffff810e97dc>] __lock_page_or_retry+0x4c/0x60
[ 9687.768824]  [<ffffffff81108adf>] handle_pte_fault+0x79f/0x7c0
[ 9687.774645]  [<ffffffff810ef167>] ? __free_pages+0x27/0x30
[ 9687.780118]  [<ffffffff8110a031>] ? __pte_alloc+0xb1/0x110
[ 9687.785591]  [<ffffffff8110a1f2>] handle_mm_fault+0x162/0x270
[ 9687.791324]  [<ffffffff815f4eb1>] do_page_fault+0x161/0x480
[ 9687.796884]  [<ffffffff8108ae63>] ? do_sigaction+0x103/0x1a0
[ 9687.802530]  [<ffffffff8108d9e9>] ? sys_rt_sigaction+0x89/0xc0
[ 9687.808351]  [<ffffffff815f20df>] page_fault+0x1f/0x30
[ 9807.612419] INFO: task kswapd0:706 blocked for more than 120 seconds.
[ 9807.618845] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[ 9807.626656] kswapd0         D 000000010022f817     0   706      2 0x00000000
[ 9807.633728]  ffff88083e75f920 0000000000000046 0000000000000001 0000000000011c40
[ 9807.641187]  ffff88083f998b60 ffff88083f998800 ffff880840309880 ffffffff00000001
[ 9807.648640]  ffff88083de8c9f0 000000103e75f880 ffff8805724a3880 ffff88083e7e3308
[ 9807.656097] Call Trace:
[ 9807.658544]  [<ffffffff810ebb27>] ? mempool_alloc+0x47/0x120
[ 9807.664190]  [<ffffffff812ec7c6>] ? cfq_may_queue+0x56/0xe0
[ 9807.669754]  [<ffffffff815effe4>] io_schedule+0x44/0x60
[ 9807.674969]  [<ffffffff812dcd3b>] get_request_wait+0xdb/0x170
[ 9807.680705]  [<ffffffff81099150>] ? autoremove_wake_function+0x0/0x40
[ 9807.687131]  [<ffffffff812d8927>] ? elv_merge+0x47/0x1d0
[ 9807.692432]  [<ffffffff812df53e>] __make_request+0x6e/0x480
[ 9807.697995]  [<ffffffff812db5d2>] generic_make_request+0x282/0x3f0
[ 9807.704160]  [<ffffffff811646ed>] ? bio_init+0x1d/0x40
[ 9807.709288]  [<ffffffff812df407>] submit_bio+0x67/0xe0
[ 9807.714417]  [<ffffffff810f2955>] ? test_set_page_writeback+0xc5/0x180
[ 9807.720932]  [<ffffffff81118ca0>] swap_writepage+0xa0/0xc0
[ 9807.726406]  [<ffffffff810f7a7c>] shrink_page_list+0x45c/0x800
[ 9807.732231]  [<ffffffff810f95be>] shrink_inactive_list+0x11e/0x3c0
[ 9807.738396]  [<ffffffff810f9af1>] shrink_zone+0x291/0x4c0
[ 9807.743788]  [<ffffffff810eff86>] ? zone_watermark_ok_safe+0xb6/0xd0
[ 9807.750127]  [<ffffffff810fa575>] kswapd+0x605/0x8a0
[ 9807.755081]  [<ffffffff810f9f70>] ? kswapd+0x0/0x8a0
[ 9807.760037]  [<ffffffff81098c77>] kthread+0x97/0xa0
[ 9807.764908]  [<ffffffff8103ba54>] kernel_thread_helper+0x4/0x10
[ 9807.770814]  [<ffffffff81098be0>] ? kthread+0x0/0xa0
[ 9807.775770]  [<ffffffff8103ba50>] ? kernel_thread_helper+0x0/0x10
[ 9807.781851] INFO: task kswapd1:707 blocked for more than 120 seconds.
[ 9807.788277] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[ 9807.796084] kswapd1         D 000000010022f812     0   707      2 0x00000000
[ 9807.803158]  ffff88083e705920 0000000000000046 0000000000000001 0000000000011c40
[ 9807.810615]  ffff88083f998460 ffff88083f998100 ffff88083f80b8c0 ffffffff0000000c
[ 9807.818070]  ffff88083de8c9f0 000000103e705880 ffff880ee402b880 ffff88083e7e3308
[ 9807.825524] Call Trace:
[ 9807.827967]  [<ffffffff810ebb27>] ? mempool_alloc+0x47/0x120
[ 9807.833614]  [<ffffffff812ec7c6>] ? cfq_may_queue+0x56/0xe0
[ 9807.839176]  [<ffffffff815effe4>] io_schedule+0x44/0x60
[ 9807.844393]  [<ffffffff812dcd3b>] get_request_wait+0xdb/0x170
[ 9807.850126]  [<ffffffff81099150>] ? autoremove_wake_function+0x0/0x40
[ 9807.856551]  [<ffffffff812d8a5b>] ? elv_merge+0x17b/0x1d0
[ 9807.861940]  [<ffffffff812df53e>] __make_request+0x6e/0x480
[ 9807.867503]  [<ffffffff812db5d2>] generic_make_request+0x282/0x3f0
[ 9807.873669]  [<ffffffff811646ed>] ? bio_init+0x1d/0x40
[ 9807.878796]  [<ffffffff812df407>] submit_bio+0x67/0xe0
[ 9807.883926]  [<ffffffff810f2955>] ? test_set_page_writeback+0xc5/0x180
[ 9807.890439]  [<ffffffff81118ca0>] swap_writepage+0xa0/0xc0
[ 9807.895915]  [<ffffffff810f7a7c>] shrink_page_list+0x45c/0x800
[ 9807.901737]  [<ffffffff810f95be>] shrink_inactive_list+0x11e/0x3c0
[ 9807.907905]  [<ffffffff810f9af1>] shrink_zone+0x291/0x4c0
[ 9807.913335]  [<ffffffff810eff86>] ? zone_watermark_ok_safe+0xb6/0xd0
[ 9807.919675]  [<ffffffff810fa575>] kswapd+0x605/0x8a0
[ 9807.924632]  [<ffffffff810f9f70>] ? kswapd+0x0/0x8a0
[ 9807.929588]  [<ffffffff81098c77>] kthread+0x97/0xa0
[ 9807.934457]  [<ffffffff8103ba54>] kernel_thread_helper+0x4/0x10
[ 9807.940365]  [<ffffffff81098be0>] ? kthread+0x0/0xa0
[ 9807.945321]  [<ffffffff8103ba50>] ? kernel_thread_helper+0x0/0x10
[ 9807.951404] INFO: task avahi-daemon:2353 blocked for more than 120 seconds.
[ 9807.958346] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[ 9807.966155] avahi-daemon    D 00000001002332a4     0  2353      1 0x00000000
[ 9807.973227]  ffff88103f5437a8 0000000000000086 ffff88083faa8f40 0000000000011c40
[ 9807.980682]  ffff88103eb764e0 ffff88103eb76180 ffffffff81923020 ffff880800000000
[ 9807.988134]  0000000000000008 00000000007e89ff ffff88103f543778 ffffffff812db5d2
[ 9807.995587] Call Trace:
[ 9807.998034]  [<ffffffff812db5d2>] ? generic_make_request+0x282/0x3f0
[ 9808.004374]  [<ffffffff811646ed>] ? bio_init+0x1d/0x40
[ 9808.009501]  [<ffffffff815effe4>] io_schedule+0x44/0x60
[ 9808.014716]  [<ffffffff810e9525>] sync_page+0x45/0x60
[ 9808.019759]  [<ffffffff815f04be>] __wait_on_bit+0x5e/0x90
[ 9808.025146]  [<ffffffff810e94e0>] ? sync_page+0x0/0x60
[ 9808.030273]  [<ffffffff810e9724>] wait_on_page_bit+0x74/0x80
[ 9808.035922]  [<ffffffff81099190>] ? wake_bit_function+0x0/0x40
[ 9808.041745]  [<ffffffff812f3abe>] ? radix_tree_lookup_slot+0xe/0x10
[ 9808.047999]  [<ffffffff810e97dc>] __lock_page_or_retry+0x4c/0x60
[ 9808.053994]  [<ffffffff81108adf>] handle_pte_fault+0x79f/0x7c0
[ 9808.059814]  [<ffffffff810ef167>] ? __free_pages+0x27/0x30
[ 9808.065290]  [<ffffffff8110a031>] ? __pte_alloc+0xb1/0x110
[ 9808.070766]  [<ffffffff8110a1f2>] handle_mm_fault+0x162/0x270
[ 9808.076500]  [<ffffffff815f4eb1>] do_page_fault+0x161/0x480
[ 9808.082063]  [<ffffffff812f4eba>] ? rb_insert_color+0x8a/0xf0
[ 9808.087800]  [<ffffffff812f64b0>] ? timerqueue_add+0x60/0xb0
[ 9808.093449]  [<ffffffff8109c891>] ? lock_hrtimer_base+0x31/0x60
[ 9808.099356]  [<ffffffff8109c961>] ? hrtimer_try_to_cancel+0x51/0xd0
[ 9808.105610]  [<ffffffff815f20df>] page_fault+0x1f/0x30
[ 9808.110741]  [<ffffffff8114848c>] ? do_sys_poll+0x3ac/0x460
[ 9808.116301]  [<ffffffff81148450>] ? do_sys_poll+0x370/0x460
[ 9808.121863]  [<ffffffff81147e80>] ? __pollwait+0x0/0x100
[ 9808.127164]  [<ffffffff81147f80>] ? pollwake+0x0/0x70
[ 9808.132206]  [<ffffffff81147f80>] ? pollwake+0x0/0x70
[ 9808.137248]  [<ffffffff81147f80>] ? pollwake+0x0/0x70
[ 9808.142291]  [<ffffffff81147f80>] ? pollwake+0x0/0x70
[ 9808.147331]  [<ffffffff81147f80>] ? pollwake+0x0/0x70
[ 9808.152373]  [<ffffffff81147f80>] ? pollwake+0x0/0x70
[ 9808.157416]  [<ffffffff81147f80>] ? pollwake+0x0/0x70
[ 9808.162457]  [<ffffffff81147f80>] ? pollwake+0x0/0x70
[ 9808.167530]  [<ffffffff81137365>] ? do_sync_read+0xd5/0x120
[ 9808.173093]  [<ffffffff8107fb39>] ? timespec_add_safe+0x39/0x70
[ 9808.179000]  [<ffffffff81147d34>] ? poll_select_set_timeout+0x84/0xa0
[ 9808.185426]  [<ffffffff811485bc>] sys_poll+0x7c/0x100
[ 9808.190469]  [<ffffffff8103ad2b>] system_call_fastpath+0x16/0x1b
[ 9808.196463] INFO: task rsyslogd:2523 blocked for more than 120 seconds.
[ 9808.203061] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[ 9808.210872] rsyslogd        D 0000000100237de3     0  2523      1 0x00000000
[ 9808.217944]  ffff88083ec11a88 0000000000000086 ffff88083faa8f40 0000000000011c40
[ 9808.225403]  ffff88083f93a460 ffff88083f93a100 ffffffff81923020 ffff880800000000
[ 9808.232858]  0000000000000008 00000000006f52cf ffff88083ec11a58 ffffffff812db5d2
[ 9808.240311] Call Trace:
[ 9808.242754]  [<ffffffff812db5d2>] ? generic_make_request+0x282/0x3f0
[ 9808.249092]  [<ffffffff811646ed>] ? bio_init+0x1d/0x40
[ 9808.254220]  [<ffffffff815effe4>] io_schedule+0x44/0x60
[ 9808.259571]  [<ffffffff810e9525>] sync_page+0x45/0x60
[ 9808.264616]  [<ffffffff815f04be>] __wait_on_bit+0x5e/0x90
[ 9808.270002]  [<ffffffff810e94e0>] ? sync_page+0x0/0x60
[ 9808.275131]  [<ffffffff810e9724>] wait_on_page_bit+0x74/0x80
[ 9808.280780]  [<ffffffff81099190>] ? wake_bit_function+0x0/0x40
[ 9808.286600]  [<ffffffff812f3abe>] ? radix_tree_lookup_slot+0xe/0x10
[ 9808.292855]  [<ffffffff810e97dc>] __lock_page_or_retry+0x4c/0x60
[ 9808.298849]  [<ffffffff81108adf>] handle_pte_fault+0x79f/0x7c0
[ 9808.304668]  [<ffffffff810ef167>] ? __free_pages+0x27/0x30
[ 9808.310142]  [<ffffffff8110a031>] ? __pte_alloc+0xb1/0x110
[ 9808.315618]  [<ffffffff8110a1f2>] handle_mm_fault+0x162/0x270
[ 9808.321352]  [<ffffffff815f4eb1>] do_page_fault+0x161/0x480
[ 9808.326913]  [<ffffffff81039996>] ? __switch_to+0x1e6/0x2a0
[ 9808.332472]  [<ffffffff815ef808>] ? schedule+0x3f8/0xaf0
[ 9808.337775]  [<ffffffff815f20df>] page_fault+0x1f/0x30
[ 9808.342904]  [<ffffffff8107bd47>] ? do_syslog+0x347/0x4e0
[ 9808.348292]  [<ffffffff8107bd02>] ? do_syslog+0x302/0x4e0
[ 9808.353681]  [<ffffffff81099150>] ? autoremove_wake_function+0x0/0x40
[ 9808.360107]  [<ffffffff81193f36>] kmsg_read+0x36/0x70
[ 9808.365149]  [<ffffffff8118a324>] proc_reg_read+0x74/0xb0
[ 9808.370538]  [<ffffffff81137b7b>] vfs_read+0xcb/0x170
[ 9808.375581]  [<ffffffff81138025>] sys_read+0x55/0x90
[ 9808.380539]  [<ffffffff8103ad2b>] system_call_fastpath+0x16/0x1b
[ 9808.386532] INFO: task memknobs:2741 blocked for more than 120 seconds.
[ 9808.393133] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[ 9808.400942] memknobs        D 000000010022f7f5     0  2741   2674 0x00000000
[ 9808.408014]  ffff88103e3ffc68 0000000000000086 ffff88083faa8f40 0000000000011c40
[ 9808.415471]  ffff88103eb024a0 ffff88103eb02140 ffff88083f818800 ffff88080000000e
[ 9808.422926]  0000000000000008 000000000081f4c7 ffff88103e3ffc38 ffffffff812db5d2
[ 9808.430377] Call Trace:
[ 9808.432824]  [<ffffffff812db5d2>] ? generic_make_request+0x282/0x3f0
[ 9808.439165]  [<ffffffff811646ed>] ? bio_init+0x1d/0x40
[ 9808.444295]  [<ffffffff815effe4>] io_schedule+0x44/0x60
[ 9808.449511]  [<ffffffff810e9525>] sync_page+0x45/0x60
[ 9808.454553]  [<ffffffff815f04be>] __wait_on_bit+0x5e/0x90
[ 9808.459943]  [<ffffffff810e94e0>] ? sync_page+0x0/0x60
[ 9808.465070]  [<ffffffff810e9724>] wait_on_page_bit+0x74/0x80
[ 9808.470715]  [<ffffffff81099190>] ? wake_bit_function+0x0/0x40
[ 9808.476535]  [<ffffffff812f3abe>] ? radix_tree_lookup_slot+0xe/0x10
[ 9808.482788]  [<ffffffff810e97dc>] __lock_page_or_retry+0x4c/0x60
[ 9808.488781]  [<ffffffff81108adf>] handle_pte_fault+0x79f/0x7c0
[ 9808.494604]  [<ffffffff810ef167>] ? __free_pages+0x27/0x30
[ 9808.500077]  [<ffffffff8110a031>] ? __pte_alloc+0xb1/0x110
[ 9808.505549]  [<ffffffff8110a1f2>] handle_mm_fault+0x162/0x270
[ 9808.511284]  [<ffffffff815f4eb1>] do_page_fault+0x161/0x480
[ 9808.516848]  [<ffffffff8108ae63>] ? do_sigaction+0x103/0x1a0
[ 9808.522498]  [<ffffffff8108d9e9>] ? sys_rt_sigaction+0x89/0xc0
[ 9808.528318]  [<ffffffff815f20df>] page_fault+0x1f/0x30
[ 9808.533449] INFO: task sshd:2755 blocked for more than 120 seconds.
[ 9808.539700] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[ 9808.547511] sshd            D 00000001002310ff     0  2755   2510 0x00000000
[ 9808.554582]  ffff880079c27c68 0000000000000086 ffff88083faa8f40 0000000000011c40
[ 9808.562039]  ffff88083e2f1aa0 ffff88083e2f1740 ffffffff81923020 ffff880800000000
[ 9808.569493]  0000000000000008 00000000007de1b7 ffff880079c27c38 ffffffff812db5d2
[ 9808.576948] Call Trace:
[ 9808.579393]  [<ffffffff812db5d2>] ? generic_make_request+0x282/0x3f0
[ 9808.585731]  [<ffffffff811646ed>] ? bio_init+0x1d/0x40
[ 9808.590859]  [<ffffffff815effe4>] io_schedule+0x44/0x60
[ 9808.596075]  [<ffffffff810e9525>] sync_page+0x45/0x60
[ 9808.601115]  [<ffffffff815f04be>] __wait_on_bit+0x5e/0x90
[ 9808.606502]  [<ffffffff810e94e0>] ? sync_page+0x0/0x60
[ 9808.611630]  [<ffffffff810e9724>] wait_on_page_bit+0x74/0x80
[ 9808.617277]  [<ffffffff81099190>] ? wake_bit_function+0x0/0x40
[ 9808.623096]  [<ffffffff812f3abe>] ? radix_tree_lookup_slot+0xe/0x10
[ 9808.629350]  [<ffffffff810e97dc>] __lock_page_or_retry+0x4c/0x60
[ 9808.635345]  [<ffffffff81108adf>] handle_pte_fault+0x79f/0x7c0
[ 9808.641166]  [<ffffffff810ef167>] ? __free_pages+0x27/0x30
[ 9808.646643]  [<ffffffff8110a031>] ? __pte_alloc+0xb1/0x110
[ 9808.652118]  [<ffffffff8110a1f2>] handle_mm_fault+0x162/0x270
[ 9808.657851]  [<ffffffff815f4eb1>] do_page_fault+0x161/0x480
[ 9808.663413]  [<ffffffff81137bde>] ? vfs_read+0x12e/0x170
[ 9808.668713]  [<ffffffff815f20df>] page_fault+0x1f/0x30


-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
