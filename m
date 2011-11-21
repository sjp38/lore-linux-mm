Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 77C416B0069
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 05:15:36 -0500 (EST)
Received: by ggnq1 with SMTP id q1so5804246ggn.14
        for <linux-mm@kvack.org>; Mon, 21 Nov 2011 02:15:34 -0800 (PST)
Message-ID: <1321870529.2552.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Subject: Re: [BUG] 3.2-rc2: BUG kmalloc-8: Redzone overwritten
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 21 Nov 2011 11:15:29 +0100
In-Reply-To: <1321866845.3831.7.camel@lappy>
References: <1321866845.3831.7.camel@lappy>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>, David Miller <davem@davemloft.net>
Cc: Matt Mackall <mpm@selenic.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, netdev <netdev@vger.kernel.org>

Le lundi 21 novembre 2011 A  11:14 +0200, Sasha Levin a A(C)crit :
> Hi All,
> 
> I got the following output when running some tests (I'm not really sure
> what exactly happened when this bug was triggered):
> 
> [13850.947279] =============================================================================
> [13850.948024] BUG kmalloc-8: Redzone overwritten
> [13850.948024] -----------------------------------------------------------------------------
> [13850.948024] 
> [13850.948024] INFO: 0xffff8800104f6d28-0xffff8800104f6d2b. First byte 0x0 instead of 0xcc
> [13850.948024] INFO: Allocated in __seq_open_private+0x20/0x5e age=4436 cpu=0 pid=17295
> [13850.948024] 	__slab_alloc.clone.46+0x3e7/0x456
> [13850.948024] 	__kmalloc+0x8c/0x110
> [13850.948024] 	__seq_open_private+0x20/0x5e
> [13850.948024] 	seq_open_net+0x3b/0x5d
> [13850.948024] 	dev_mc_seq_open+0x15/0x17
> [13850.948024] 	proc_reg_open+0xad/0x127
> [13850.948024] 	__dentry_open+0x1a0/0x2fe
> [13850.948024] 	nameidata_to_filp+0x63/0x6a
> [13850.948024] 	do_last+0x59e/0x5cb
> [13850.948024] 	path_openat+0xcd/0x35d
> [13850.948024] 	do_filp_open+0x38/0x84
> [13850.948024] 	do_sys_open+0x6f/0x101
> [13850.948024] 	sys_open+0x1b/0x1d
> [13850.948024] 	system_call_fastpath+0x16/0x1b
> [13850.948024] INFO: Freed in seq_release_private+0x26/0x45 age=30272 cpu=0 pid=17283
> [13850.948024] 	__slab_free+0x35/0x1dc
> [13850.948024] 	kfree+0xb6/0xbf
> [13850.948024] 	seq_release_private+0x26/0x45
> [13850.948024] 	seq_release_net+0x32/0x3b
> [13850.948024] 	proc_reg_release+0xd9/0xf6
> [13850.948024] 	fput+0x11e/0x1dc
> [13850.948024] 	filp_close+0x6e/0x79
> [13850.948024] 	put_files_struct+0xcc/0x196
> [13850.948024] 	exit_files+0x46/0x4f
> [13850.948024] 	do_exit+0x264/0x75c
> [13850.948024] 	do_group_exit+0x83/0xb1
> [13850.948024] 	sys_exit_group+0x12/0x16
> [13850.948024] 	system_call_fastpath+0x16/0x1b
> [13850.948024] INFO: Slab 0xffffea0000413d80 objects=12 used=8 fp=0xffff8800104f6000 flags=0x10000000000081
> [13850.948024] INFO: Object 0xffff8800104f6d20 @offset=3360 fp=0xffff8800104f6e70
> [13850.948024] 
> [13850.948024] Bytes b4 ffff8800104f6d10: 39 64 00 00 01 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a  9d......ZZZZZZZZ
> [13850.948024] Object ffff8800104f6d20: 00 a9 38 83 ff ff ff ff                          ..8.....
> [13850.948024] Redzone ffff8800104f6d28: 00 00 00 00 cc cc cc cc                          ........
> [13850.948024] Padding ffff8800104f6e68: 5a 5a 5a 5a 5a 5a 5a 5a                          ZZZZZZZZ
> [13850.948024] Pid: 17295, comm: trinity Tainted: G        W    3.2.0-rc2-sasha-00146-gc729049-dirty #15
> [13850.948024] Call Trace:
> [13850.948024]  [<ffffffff8112c8f6>] ? print_section+0x38/0x3a
> [13850.948024]  [<ffffffff8112ca21>] print_trailer+0x129/0x132
> [13850.948024]  [<ffffffff8112cd02>] check_bytes_and_report+0xb2/0xeb
> [13850.948024]  [<ffffffff8115bacc>] ? __seq_open_private+0x31/0x5e
> [13850.948024]  [<ffffffff8112d811>] check_object+0x4e/0x1ae
> [13850.948024]  [<ffffffff8115ba7c>] ? seq_release_private+0x26/0x45
> [13850.948024]  [<ffffffff8112e723>] free_debug_processing+0x96/0x1dc
> [13850.948024]  [<ffffffff8115ba7c>] ? seq_release_private+0x26/0x45
> [13850.948024]  [<ffffffff8112ec07>] __slab_free+0x35/0x1dc
> [13850.948024]  [<ffffffff8115ba7c>] ? seq_release_private+0x26/0x45
> [13850.948024]  [<ffffffff8115ba7c>] ? seq_release_private+0x26/0x45
> [13850.948024]  [<ffffffff81626be3>] ? debug_check_no_obj_freed+0x12/0x17
> [13850.948024]  [<ffffffff8115ba7c>] ? seq_release_private+0x26/0x45
> [13850.948024]  [<ffffffff8113041f>] kfree+0xb6/0xbf
> [13850.948024]  [<ffffffff81196f4b>] ? single_open_net+0x54/0x54
> [13850.948024]  [<ffffffff8115ba7c>] seq_release_private+0x26/0x45
> [13850.948024]  [<ffffffff81196f7d>] seq_release_net+0x32/0x3b
> [13850.948024]  [<ffffffff8118dc6c>] proc_reg_release+0xd9/0xf6
> [13850.948024]  [<ffffffff811418cf>] fput+0x11e/0x1dc
> [13850.948024]  [<ffffffff8113f3d8>] filp_close+0x6e/0x79
> [13850.948024]  [<ffffffff81089f17>] put_files_struct+0xcc/0x196
> [13850.948024]  [<ffffffff8108a074>] exit_files+0x46/0x4f
> [13850.948024]  [<ffffffff8108a756>] do_exit+0x264/0x75c
> [13850.948024]  [<ffffffff8113f67c>] ? fsnotify_modify+0x60/0x68
> [13850.948024]  [<ffffffff81b96f8a>] ? sysret_check+0x2e/0x69
> [13850.948024]  [<ffffffff8108ad01>] do_group_exit+0x83/0xb1
> [13850.948024]  [<ffffffff8108ad41>] sys_exit_group+0x12/0x16
> [13850.948024]  [<ffffffff81b96f52>] system_call_fastpath+0x16/0x1b
> [13850.948024] FIX kmalloc-8: Restoring 0xffff8800104f6d28-0xffff8800104f6d2b=0xcc
> [13850.948024] 
> [14925.113722] =============================================================================
> [14925.114041] BUG kmalloc-8: Redzone overwritten
> [14925.114041] -----------------------------------------------------------------------------
> [14925.114041] 
> [14925.114041] INFO: 0xffff8800104f2d28-0xffff8800104f2d2b. First byte 0x0 instead of 0xcc
> [14925.114041] INFO: Allocated in __seq_open_private+0x20/0x5e age=6777 cpu=0 pid=17491
> [14925.114041] 	__slab_alloc.clone.46+0x3e7/0x456
> [14925.114041] 	__kmalloc+0x8c/0x110
> [14925.114041] 	__seq_open_private+0x20/0x5e
> [14925.114041] 	seq_open_net+0x3b/0x5d
> [14925.114041] 	dev_mc_seq_open+0x15/0x17
> [14925.114041] 	proc_reg_open+0xad/0x127
> [14925.114041] 	__dentry_open+0x1a0/0x2fe
> [14925.114041] 	nameidata_to_filp+0x63/0x6a
> [14925.114041] 	do_last+0x59e/0x5cb
> [14925.114041] 	path_openat+0xcd/0x35d
> [14925.114041] 	do_filp_open+0x38/0x84
> [14925.114041] 	do_sys_open+0x6f/0x101
> [14925.114041] 	sys_open+0x1b/0x1d
> [14925.114041] 	system_call_fastpath+0x16/0x1b
> [14925.114041] INFO: Freed in seq_release_private+0x26/0x45 age=30836 cpu=0 pid=17487
> [14925.114041] 	__slab_free+0x35/0x1dc
> [14925.114041] 	kfree+0xb6/0xbf
> [14925.114041] 	seq_release_private+0x26/0x45
> [14925.114041] 	seq_release_net+0x32/0x3b
> [14925.114041] 	proc_reg_release+0xd9/0xf6
> [14925.114041] 	fput+0x11e/0x1dc
> [14925.114041] 	filp_close+0x6e/0x79
> [14925.114041] 	put_files_struct+0xcc/0x196
> [14925.114041] 	exit_files+0x46/0x4f
> [14925.114041] 	do_exit+0x264/0x75c
> [14925.114041] 	do_group_exit+0x83/0xb1
> [14925.114041] 	sys_exit_group+0x12/0x16
> [14925.114041] 	system_call_fastpath+0x16/0x1b
> [14925.114041] INFO: Slab 0xffffea0000413c80 objects=12 used=11 fp=0xffff8800104f27e0 flags=0x10000000000081
> [14925.114041] INFO: Object 0xffff8800104f2d20 @offset=3360 fp=0xffff8800104f2bd0
> [14925.114041] 
> [14925.114041] Bytes b4 ffff8800104f2d10: 0a b1 de 00 01 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a  ........ZZZZZZZZ
> [14925.114041] Object ffff8800104f2d20: 00 a9 38 83 ff ff ff ff                          ..8.....
> [14925.114041] Redzone ffff8800104f2d28: 00 00 00 00 cc cc cc cc                          ........
> [14925.114041] Padding ffff8800104f2e68: 5a 5a 5a 5a 5a 5a 5a 5a                          ZZZZZZZZ
> [14925.114041] Pid: 17491, comm: trinity Tainted: G        W    3.2.0-rc2-sasha-00146-gc729049-dirty #15
> [14925.114041] Call Trace:
> [14925.114041]  [<ffffffff8112c8f6>] ? print_section+0x38/0x3a
> [14925.114041]  [<ffffffff8112ca21>] print_trailer+0x129/0x132
> [14925.114041]  [<ffffffff8112cd02>] check_bytes_and_report+0xb2/0xeb
> [14925.114041]  [<ffffffff8115bacc>] ? __seq_open_private+0x31/0x5e
> [14925.114041]  [<ffffffff8112d811>] check_object+0x4e/0x1ae
> [14925.114041]  [<ffffffff8115ba7c>] ? seq_release_private+0x26/0x45
> [14925.114041]  [<ffffffff8112e723>] free_debug_processing+0x96/0x1dc
> [14925.114041]  [<ffffffff8115ba7c>] ? seq_release_private+0x26/0x45
> [14925.114041]  [<ffffffff8112ec07>] __slab_free+0x35/0x1dc
> [14925.114041]  [<ffffffff8115ba7c>] ? seq_release_private+0x26/0x45
> [14925.114041]  [<ffffffff8115ba7c>] ? seq_release_private+0x26/0x45
> [14925.114041]  [<ffffffff81626be3>] ? debug_check_no_obj_freed+0x12/0x17
> [14925.114041]  [<ffffffff8115ba7c>] ? seq_release_private+0x26/0x45
> [14925.114041]  [<ffffffff8113041f>] kfree+0xb6/0xbf
> [14925.114041]  [<ffffffff81196f4b>] ? single_open_net+0x54/0x54
> [14925.114041]  [<ffffffff8115ba7c>] seq_release_private+0x26/0x45
> [14925.114041]  [<ffffffff81196f7d>] seq_release_net+0x32/0x3b
> [14925.114041]  [<ffffffff8118dc6c>] proc_reg_release+0xd9/0xf6
> [14925.114041]  [<ffffffff811418cf>] fput+0x11e/0x1dc
> [14925.114041]  [<ffffffff8113f3d8>] filp_close+0x6e/0x79
> [14925.114041]  [<ffffffff81089f17>] put_files_struct+0xcc/0x196
> [14925.114041]  [<ffffffff8108a074>] exit_files+0x46/0x4f
> [14925.114041]  [<ffffffff8108a756>] do_exit+0x264/0x75c
> [14925.114041]  [<ffffffff8104ca1b>] ? smp_apic_timer_interrupt+0x76/0x84
> [14925.114041]  [<ffffffff81b966b8>] ? retint_restore_args+0x13/0x13
> [14925.114041]  [<ffffffff8108ad01>] do_group_exit+0x83/0xb1
> [14925.114041]  [<ffffffff8108ad41>] sys_exit_group+0x12/0x16
> [14925.114041]  [<ffffffff81b96f52>] system_call_fastpath+0x16/0x1b
> [14925.114041] FIX kmalloc-8: Restoring 0xffff8800104f2d28-0xffff8800104f2d2b=0xcc
> [14925.114041] 
> [15958.081391] general protection fault: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> [15958.082012] CPU 1 
> [15958.082012] Pid: 15, comm: rcuc/1 Tainted: G        W    3.2.0-rc2-sasha-00146-gc729049-dirty #15  
> [15958.082012] RIP: 0010:[<ffffffff810b305b>]  [<ffffffff810b305b>] __lock_acquire+0xff/0xe50
> [15958.082012] RSP: 0000:ffff880013c03cc8  EFLAGS: 00010002
> [15958.082012] RAX: 6b6b6b6b6b6b6b6b RBX: ffff8800124daf60 RCX: 0000000000000000
> [15958.082012] RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffff880010b82568
> [15958.082012] RBP: ffff880013c03d98 R08: 0000000000000002 R09: 0000000000000000
> [15958.082012] R10: ffff880010b82568 R11: 0000000000000001 R12: ffff880010b82568
> [15958.082012] R13: 0000000000000002 R14: 0000000000000000 R15: ffff880013c03f18
> [15958.082012] FS:  0000000000000000(0000) GS:ffff880013c00000(0000) knlGS:0000000000000000
> [15958.082012] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [15958.082012] CR2: 00007f9193a05c2c CR3: 0000000010735000 CR4: 00000000000406e0
> [15958.082012] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [15958.082012] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [15958.082012] Process rcuc/1 (pid: 15, threadinfo ffff8800124e6000, task ffff8800124daf60)
> [15958.082012] Stack:
> [15958.082012]  ffff880013dceb10 ffff8800124daf60 ffffffff00000000 0000000000000000
> [15958.082012]  ffff880010b82568 0000000000000082 ffff880000000000 ffffffff810b1d97
> [15958.082012]  ffff8800124daf60 ffff880013c03ee8 ffff880013c03df8 ffffffff816141ae
> [15958.082012] Call Trace:
> [15958.082012]  <IRQ> 
> [15958.082012]  [<ffffffff810b1d97>] ? trace_hardirqs_on_caller+0x151/0x197
> [15958.082012]  [<ffffffff816141ae>] ? trace_hardirqs_on_thunk+0x3a/0x3f
> [15958.082012]  [<ffffffff810b4255>] lock_acquire+0x8a/0xa7
> [15958.082012]  [<ffffffff81aa6314>] ? dn_slow_timer+0x20/0x108
> [15958.082012]  [<ffffffff810afac3>] ? arch_local_irq_restore+0x12/0x19
> [15958.082012]  [<ffffffff81b958b7>] _raw_spin_lock+0x3b/0x6e
> [15958.082012]  [<ffffffff81aa6314>] ? dn_slow_timer+0x20/0x108
> [15958.082012]  [<ffffffff81aa6314>] dn_slow_timer+0x20/0x108
> [15958.082012]  [<ffffffff810915f1>] run_timer_softirq+0x1da/0x28c
> [15958.082012]  [<ffffffff81091599>] ? run_timer_softirq+0x182/0x28c
> [15958.082012]  [<ffffffff81aa62f4>] ? dn_neigh_elist+0x3a/0x3a
> [15958.082012]  [<ffffffff8108c2e4>] __do_softirq+0xa4/0x14b
> [15958.082012]  [<ffffffff81b9923c>] call_softirq+0x1c/0x30
> [15958.082012]  <EOI> 
> [15958.082012]  [<ffffffff8103525a>] do_softirq+0x62/0xb8
> [15958.082012]  [<ffffffff810e1711>] ? rcu_cpu_kthread+0x284/0x2b8
> [15958.082012]  [<ffffffff8108c1cb>] _local_bh_enable_ip+0xaf/0xe6
> [15958.082012]  [<ffffffff8108c233>] local_bh_enable+0xd/0xf
> [15958.082012]  [<ffffffff810e1711>] rcu_cpu_kthread+0x284/0x2b8
> [15958.082012]  [<ffffffff810e148d>] ? rcu_do_batch.clone.24+0x1fe/0x1fe
> [15958.082012]  [<ffffffff8109ee97>] kthread+0x9b/0xa3
> [15958.082012]  [<ffffffff810b1d97>] ? trace_hardirqs_on_caller+0x151/0x197
> [15958.082012]  [<ffffffff81b99144>] kernel_thread_helper+0x4/0x10
> [15958.082012]  [<ffffffff81b966b8>] ? retint_restore_args+0x13/0x13
> [15958.082012]  [<ffffffff8109edfc>] ? kthread_flush_work_fn+0xf/0xf
> [15958.082012]  [<ffffffff81b99140>] ? gs_change+0x13/0x13
> [15958.082012] Code: 8d 40 ff ff ff 4c 89 95 50 ff ff ff 45 31 f6 e8 23 fc ff ff 44 8b 8d 40 ff ff ff 48 85 c0 4c 8b 95 50 ff ff ff 0f 84 e4 0c 00 00 <f0> ff 80 98 01 00 00 44 8b bb d0 08 00 00 83 3d 64 27 74 01 00 
> [15958.082012] RIP  [<ffffffff810b305b>] __lock_acquire+0xff/0xe50
> [15958.082012]  RSP <ffff880013c03cc8>
> [15958.082012] ---[ end trace 21ee6c8ed26977a8 ]---
> [15958.082012] Kernel panic - not syncing: Fatal exception in interrupt
> [15958.082012] Pid: 15, comm: rcuc/1 Tainted: G      D W    3.2.0-rc2-sasha-00146-gc729049-dirty #15
> [15958.082012] Call Trace:
> [15958.082012]  <IRQ>  [<ffffffff81b930f3>] panic+0x96/0x1c3
> [15958.082012]  [<ffffffff81036626>] oops_end+0xcf/0xdf
> [15958.082012]  [<ffffffff8103677c>] die+0x55/0x61
> [15958.082012]  [<ffffffff8103417b>] do_general_protection+0x12e/0x136
> [15958.082012]  [<ffffffff81b966e8>] ? restore_args+0x30/0x30
> [15958.082012]  [<ffffffff81b96935>] general_protection+0x25/0x30
> [15958.082012]  [<ffffffff810b305b>] ? __lock_acquire+0xff/0xe50
> [15958.082012]  [<ffffffff810b2fcb>] ? __lock_acquire+0x6f/0xe50
> [15958.082012]  [<ffffffff810b1d97>] ? trace_hardirqs_on_caller+0x151/0x197
> [15958.082012]  [<ffffffff816141ae>] ? trace_hardirqs_on_thunk+0x3a/0x3f
> [15958.082012]  [<ffffffff810b4255>] lock_acquire+0x8a/0xa7
> [15958.082012]  [<ffffffff81aa6314>] ? dn_slow_timer+0x20/0x108
> [15958.082012]  [<ffffffff810afac3>] ? arch_local_irq_restore+0x12/0x19
> [15958.082012]  [<ffffffff81b958b7>] _raw_spin_lock+0x3b/0x6e
> [15958.082012]  [<ffffffff81aa6314>] ? dn_slow_timer+0x20/0x108
> [15958.082012]  [<ffffffff81aa6314>] dn_slow_timer+0x20/0x108
> [15958.082012]  [<ffffffff810915f1>] run_timer_softirq+0x1da/0x28c
> [15958.082012]  [<ffffffff81091599>] ? run_timer_softirq+0x182/0x28c
> [15958.082012]  [<ffffffff81aa62f4>] ? dn_neigh_elist+0x3a/0x3a
> [15958.082012]  [<ffffffff8108c2e4>] __do_softirq+0xa4/0x14b
> [15958.082012]  [<ffffffff81b9923c>] call_softirq+0x1c/0x30
> [15958.082012]  <EOI>  [<ffffffff8103525a>] do_softirq+0x62/0xb8
> [15958.082012]  [<ffffffff810e1711>] ? rcu_cpu_kthread+0x284/0x2b8
> [15958.082012]  [<ffffffff8108c1cb>] _local_bh_enable_ip+0xaf/0xe6
> [15958.082012]  [<ffffffff8108c233>] local_bh_enable+0xd/0xf
> [15958.082012]  [<ffffffff810e1711>] rcu_cpu_kthread+0x284/0x2b8
> [15958.082012]  [<ffffffff810e148d>] ? rcu_do_batch.clone.24+0x1fe/0x1fe
> [15958.082012]  [<ffffffff8109ee97>] kthread+0x9b/0xa3
> [15958.082012]  [<ffffffff810b1d97>] ? trace_hardirqs_on_caller+0x151/0x197
> [15958.082012]  [<ffffffff81b99144>] kernel_thread_helper+0x4/0x10
> [15958.082012]  [<ffffffff81b966b8>] ? retint_restore_args+0x13/0x13
> [15958.082012]  [<ffffffff8109edfc>] ? kthread_flush_work_fn+0xf/0xf
> [15958.082012]  [<ffffffff81b99140>] ? gs_change+0x13/0x13
> [15958.082012] Rebooting in 1 seconds..
>   # KVM session ended normally.
> 
> Please let me know if theres anything I can do to help debugging it.
> 

Hmm, trinity tries to crash decnet ;)

Maybe we should remove this decnet stuff for good instead of tracking
all bugs just for the record. Is there anybody still using decnet ?

For example dn_start_slow_timer() starts a timer without holding a
reference on struct sock, this is highly suspect.

[PATCH] decnet: proper socket refcounting

Better use sk_reset_timer() / sk_stop_timer() helpers to make sure we
dont access already freed/reused memory later.

Reported-by: Sasha Levin <levinsasha928@gmail.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/decnet/dn_timer.c |   16 +++++-----------
 1 file changed, 5 insertions(+), 11 deletions(-)

diff --git a/net/decnet/dn_timer.c b/net/decnet/dn_timer.c
index 67f691b..9f95f0d 100644
--- a/net/decnet/dn_timer.c
+++ b/net/decnet/dn_timer.c
@@ -36,16 +36,13 @@ static void dn_slow_timer(unsigned long arg);
 
 void dn_start_slow_timer(struct sock *sk)
 {
-	sk->sk_timer.expires	= jiffies + SLOW_INTERVAL;
-	sk->sk_timer.function	= dn_slow_timer;
-	sk->sk_timer.data	= (unsigned long)sk;
-
-	add_timer(&sk->sk_timer);
+	setup_timer(&sk->sk_timer, dn_slow_timer, (unsigned long)sk);
+	sk_reset_timer(sk, &sk->sk_timer, jiffies + SLOW_INTERVAL);
 }
 
 void dn_stop_slow_timer(struct sock *sk)
 {
-	del_timer(&sk->sk_timer);
+	sk_stop_timer(sk, &sk->sk_timer);
 }
 
 static void dn_slow_timer(unsigned long arg)
@@ -57,8 +54,7 @@ static void dn_slow_timer(unsigned long arg)
 	bh_lock_sock(sk);
 
 	if (sock_owned_by_user(sk)) {
-		sk->sk_timer.expires = jiffies + HZ / 10;
-		add_timer(&sk->sk_timer);
+		sk_reset_timer(sk, &sk->sk_timer, jiffies + HZ / 10);
 		goto out;
 	}
 
@@ -100,9 +96,7 @@ static void dn_slow_timer(unsigned long arg)
 			scp->keepalive_fxn(sk);
 	}
 
-	sk->sk_timer.expires = jiffies + SLOW_INTERVAL;
-
-	add_timer(&sk->sk_timer);
+	sk_reset_timer(sk, &sk->sk_timer, jiffies + SLOW_INTERVAL);
 out:
 	bh_unlock_sock(sk);
 	sock_put(sk);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
