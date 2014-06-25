Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 3E9F76B0031
	for <linux-mm@kvack.org>; Wed, 25 Jun 2014 05:36:57 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id y13so1433579pdi.13
        for <linux-mm@kvack.org>; Wed, 25 Jun 2014 02:36:56 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id yy5si4328933pbb.144.2014.06.25.02.36.55
        for <linux-mm@kvack.org>;
        Wed, 25 Jun 2014 02:36:56 -0700 (PDT)
Date: Wed, 25 Jun 2014 17:36:50 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [cpufreq] kernel BUG at kernel/irq_work.c:175!
Message-ID: <20140625093650.GD27280@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Viresh Kumar <viresh.kumar@linaro.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Jet Chen <jet.chen@intel.com>, Yuanhan Liu <yuanhan.liu@intel.com>, LKP <lkp@01.org>, "Su, Tao" <tao.su@intel.com>

FYI, we find similar bug message in Viresh's tree, which contains 8
cpufreq patches based on next-20140625.

tree:   git://git.linaro.org/people/vireshk/linux cpufreq/cpu0-exynos
head:   d51c9fbdf49983fc3303ec576d02e8ef97da3d8b
commit: d51c9fbdf49983fc3303ec576d02e8ef97da3d8b [8/8] cpufreq: cpu0: Add support for multiple 'struct cpufreq_policy' instances

+-----------------------------------------------------------------------------+-----------+---------------+------------+
|                                                                             | v3.16-rc2 | next-20140625 | d51c9fbdf4 |
+-----------------------------------------------------------------------------+-----------+---------------+------------+
| boot_successes                                                              | 3         | 3             | 1          |
| boot_failures                                                               | 0         | 0             | 2          |
| kernel_BUG_at_kernel/irq_work.c                                             | 0         | 0             | 2          |
| invalid_opcode                                                              | 0         | 0             | 2          |
| RIP:irq_work_run                                                            | 0         | 0             | 2          |
| BUG:sleeping_function_called_from_invalid_context_at_kernel/locking/rwsem.c | 0         | 0             | 2          |
| backtrace:smpboot_thread_fn                                                 | 0         | 0             | 2          |
+-----------------------------------------------------------------------------+-----------+---------------+------------+

mount.nfs: access denied by server while mounting bee:/nfsroot/trinity
run-parts: /etc/kernel-tests/99-trinity exited with return code 32
[   66.841357] ------------[ cut here ]------------
[   66.841772] kernel BUG at kernel/irq_work.c:175!
[   66.842302] invalid opcode: 0000 [#1] SMP 
[   66.842686] Modules linked in:
[   66.842969] CPU: 1 PID: 10 Comm: migration/1 Not tainted 3.16.0-rc2-next-20140625-00008-gd51c9fb #6
[   66.843747] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   66.844010] task: ffff88001eb75e60 ti: ffff88001e03c000 task.ti: ffff88001e03c000
[   66.844010] RIP: 0010:[<ffffffff811820fd>]  [<ffffffff811820fd>] irq_work_run+0xf/0x22
[   66.844010] RSP: 0018:ffff88001e03fcc0  EFLAGS: 00010046
[   66.844010] RAX: 0000000080000001 RBX: 0000000000000000 RCX: 0000000000000005
[   66.844010] RDX: 0000000000000001 RSI: 0000000000000008 RDI: 0000000000000000
[   66.844010] RBP: ffff88001e03fce0 R08: 0000000000000200 R09: ffffffff82137030
[   66.844010] R10: 0000000000001c24 R11: 0000000000007c00 R12: ffff88001fd13940
[   66.844010] R13: 0000000000000000 R14: 0000000000000000 R15: ffffffff82073270
[   66.844010] FS:  0000000000000000(0000) GS:ffff88001fd00000(0000) knlGS:0000000000000000
[   66.844010] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[   66.844010] CR2: 00007f10054a6000 CR3: 0000000000030000 CR4: 00000000000006e0
[   66.844010] Stack:
[   66.844010]  ffffffff811412f7 0000000000000001 ffff88001fd13980 ffffffff82055fb0
[   66.844010]  ffff88001e03fd00 ffffffff811413ea 0000000000000001 00000000fffffff0
[   66.844010]  ffff88001e03fd48 ffffffff81105027 0000000000000001 0000000000000008
[   66.844010] Call Trace:
[   66.844010]  [<ffffffff811412f7>] ? flush_smp_call_function_queue+0xab/0x10e
[   66.844010]  [<ffffffff811413ea>] hotplug_cfd+0x90/0x97
[   66.844010]  [<ffffffff81105027>] notifier_call_chain+0x6d/0x93
[   66.844010]  [<ffffffff811050c5>] __raw_notifier_call_chain+0xe/0x10
[   66.844010]  [<ffffffff810e5408>] __cpu_notify+0x20/0x37
[   66.844010]  [<ffffffff810e5432>] cpu_notify+0x13/0x15
[   66.844010]  [<ffffffff819bd4ab>] take_cpu_down+0x27/0x3a
[   66.844010]  [<ffffffff81155737>] multi_cpu_stop+0x93/0xed
[   66.844010]  [<ffffffff811556a4>] ? cpu_stop_park+0x63/0x63
[   66.844010]  [<ffffffff811559b3>] cpu_stopper_thread+0x92/0x114
[   66.844010]  [<ffffffff819d1e64>] ? retint_restore_args+0x13/0x13
[   66.844010]  [<ffffffff819d0bbf>] ? _raw_spin_lock_irqsave+0x25/0x56
[   66.844010]  [<ffffffff81107069>] smpboot_thread_fn+0x187/0x1a5
[   66.844010]  [<ffffffff81106ee2>] ? SyS_setgroups+0x10c/0x10c
[   66.844010]  [<ffffffff81101627>] kthread+0xdb/0xe3
[   66.844010]  [<ffffffff8110154c>] ? kthread_create_on_node+0x174/0x174
[   66.844010]  [<ffffffff819d127c>] ret_from_fork+0x7c/0xb0
[   66.844010]  [<ffffffff8110154c>] ? kthread_create_on_node+0x174/0x174
[   66.844010] Code: cd 81 e8 dc 31 f6 ff c6 05 46 c3 f8 00 01 eb 05 e8 91 ff ff ff b8 01 00 00 00 5d c3 65 8b 04 25 50 b9 00 00 a9 00 00 0f 00 75 02 <0f> 0b 55 48 89 e5 e8 70 ff ff ff 5d c3 55 48 89 e5 5d c3 55 48 
[   66.844010] RIP  [<ffffffff811820fd>] irq_work_run+0xf/0x22
[   66.844010]  RSP <ffff88001e03fcc0>
[   66.844010] ---[ end trace 043717361af3ed47 ]---
[   66.844010] BUG: sleeping function called from invalid context at kernel/locking/rwsem.c:41

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
