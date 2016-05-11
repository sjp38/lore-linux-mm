Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5EE5C6B0005
	for <linux-mm@kvack.org>; Wed, 11 May 2016 11:19:22 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id d62so98013522iof.1
        for <linux-mm@kvack.org>; Wed, 11 May 2016 08:19:22 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id xg17si11308814igc.35.2016.05.11.08.19.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 11 May 2016 08:19:19 -0700 (PDT)
Subject: Re: x86_64 Question: Are concurrent IPI requests safe?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <alpine.DEB.2.11.1605091853130.3540@nanos>
	<201605112219.HEB64012.FLQOFMJOVOtFHS@I-love.SAKURA.ne.jp>
	<20160511133928.GF3192@twins.programming.kicks-ass.net>
	<201605112309.AGJ18252.tOFMFQOJFLSOVH@I-love.SAKURA.ne.jp>
	<alpine.DEB.2.11.1605111631430.3540@nanos>
In-Reply-To: <alpine.DEB.2.11.1605111631430.3540@nanos>
Message-Id: <201605120019.CGI60411.OJSLHFQFtVMOOF@I-love.SAKURA.ne.jp>
Date: Thu, 12 May 2016 00:19:07 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de
Cc: peterz@infradead.org, mingo@kernel.org, akpm@linux-foundation.org, mgorman@techsingularity.net, mhocko@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Thomas Gleixner wrote:
> On Wed, 11 May 2016, Tetsuo Handa wrote:
> > Peter Zijlstra wrote:
> > > On Wed, May 11, 2016 at 10:19:16PM +0900, Tetsuo Handa wrote:
> > > > [  180.434659] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
> > > 
> > > can you reproduce on real hardware?
> > > 
> > Unfortunately, I don't have a real hardware to run development kernels.
> > 
> > My Linux environment is limited to 4 CPUs / 1024MB or 2048MB RAM running
> > as a VMware guest on Windows. Can somebody try KVM environment with
> > 4 CPUs / 1024MB or 2048MB RAM whith partition only plain /dev/sda1
> > formatted as XFS?
> 
> Can you trigger a back trace on all cpus when the watchdog triggers?
> 
"a back trace on all cpus" means SysRq-l ? Then, here it is.

We can see a CPU with EFLAGS: 00000082 or EFLAGS: 00000097 which is at
__rwsem_do_wake().

Well, I came to feel that this is caused by down_write_killable() bug.
I guess we should fix down_write_killable() bug first.

( Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-20160511-2.txt.xz . )
----------------------------------------
[  164.412391] NMI watchdog: BUG: soft lockup - CPU#1 stuck for 23s! [tgid=5368:5372]
[  164.412397] NMI watchdog: BUG: soft lockup - CPU#3 stuck for 23s! [nmbd:3765]
(...snipped...)
[  174.740085] sysrq: SysRq : Show backtrace of all active CPUs
[  174.741969] Sending NMI to all CPUs:
[  174.743474] NMI backtrace for cpu 0
[  174.744834] CPU: 0 PID: 5313 Comm: tgid=5309 Tainted: G             L  4.6.0-rc7-next-20160511 #426
[  174.747223] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  174.749993] task: ffff880073e91940 ti: ffff880079b88000 task.ti: ffff880079b88000
[  174.752321] RIP: 0010:[<ffffffff811105bf>]  [<ffffffff811105bf>] smp_call_function_many+0x21f/0x2c0
[  174.754804] RSP: 0000:ffff880079b8bbb8  EFLAGS: 00000202
[  174.756528] RAX: 0000000000000002 RBX: ffff88007f818880 RCX: ffff88007f89c238
[  174.758673] RDX: 0000000000000002 RSI: 0000000000000008 RDI: ffff88007f818888
[  174.761174] RBP: ffff880079b8bbf8 R08: 000000000000000c R09: 0000000000000000
[  174.763583] R10: 0000000000000001 R11: 0000000000000000 R12: 0000000000000002
[  174.765616] R13: 0000000000000008 R14: ffffffff81188420 R15: 0000000000000000
[  174.767622] FS:  00007fd2d1c82740(0000) GS:ffff88007f800000(0000) knlGS:0000000000000000
[  174.769922] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  174.771744] CR2: 00007f1069816541 CR3: 00000000657ec000 CR4: 00000000001406f0
[  174.774472] Stack:
[  174.775576]  0000000000018840 0100000000000001 ffff88007f818888 ffffffff82b50168
[  174.777672]  0000000000000000 ffffffff81188420 0000000000000000 0000000000000001
[  174.779768]  ffff880079b8bc30 ffffffff8111079d 0000000000000008 0000000000000000
[  174.781996] Call Trace:
[  174.783490]  [<ffffffff81188420>] ? page_alloc_cpu_notify+0x40/0x40
[  174.785348]  [<ffffffff8111079d>] on_each_cpu_mask+0x3d/0xc0
[  174.787503]  [<ffffffff81189234>] drain_all_pages+0xf4/0x130
[  174.789379]  [<ffffffff8118b88b>] __alloc_pages_nodemask+0x8ab/0xe80
[  174.791292]  [<ffffffff811e3259>] alloc_pages_vma+0xb9/0x2b0
[  174.793399]  [<ffffffff811be9e0>] handle_mm_fault+0x1430/0x1980
[  174.795189]  [<ffffffff811bd5f8>] ? handle_mm_fault+0x48/0x1980
[  174.797012]  [<ffffffff8105432a>] __do_page_fault+0x1aa/0x530
[  174.798779]  [<ffffffff810546d1>] do_page_fault+0x21/0x70
[  174.800461]  [<ffffffff8172cb52>] page_fault+0x22/0x30
[  174.802102] Code: d2 e8 26 33 2b 00 3b 05 a4 26 be 00 41 89 c4 0f 8d 6b fe ff ff 48 63 d0 48 8b 0b 48 03 0c d5 20 14 cf 81 f6 41 18 01 74 08 f3 90 <f6> 41 18 01 75 f8 83 f8 ff 74 ba 83 f8 07 76 b5 80 3d 70 76 bc 
[  174.807003] NMI backtrace for cpu 3
[  174.808419] CPU: 3 PID: 3765 Comm: nmbd Tainted: G             L  4.6.0-rc7-next-20160511 #426
[  174.810860] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  174.813685] task: ffff880079c81940 ti: ffff880078d38000 task.ti: ffff880078d38000
[  174.815857] RIP: 0010:[<ffffffff811105bf>]  [<ffffffff811105bf>] smp_call_function_many+0x21f/0x2c0
[  174.818324] RSP: 0000:ffff880078d3ba88  EFLAGS: 00000202
[  174.820163] RAX: 0000000000000002 RBX: ffff88007f8d8880 RCX: ffff88007f89d8f8
[  174.822353] RDX: 0000000000000002 RSI: 0000000000000008 RDI: ffff88007f8d8888
[  174.824503] RBP: ffff880078d3bac8 R08: 0000000000000005 R09: 0000000000000000
[  174.826634] R10: 0000000000000001 R11: 0000000000000000 R12: 0000000000000002
[  174.828762] R13: 0000000000000008 R14: ffffffff81188420 R15: 0000000000000000
[  174.830885] FS:  00007f72564d5840(0000) GS:ffff88007f8c0000(0000) knlGS:0000000000000000
[  174.833195] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  174.835061] CR2: 00007f0d7c0d7110 CR3: 000000007925d000 CR4: 00000000001406e0
[  174.837160] Stack:
[  174.838307]  0000000000018840 0100000000000001 ffff88007f8d8888 ffffffff82b50168
[  174.840472]  0000000000000003 ffffffff81188420 0000000000000000 0000000000000001
[  174.842625]  ffff880078d3bb00 ffffffff8111079d 0000000000000008 0000000000000000
[  174.844762] Call Trace:
[  174.845987]  [<ffffffff81188420>] ? page_alloc_cpu_notify+0x40/0x40
[  174.847900]  [<ffffffff8111079d>] on_each_cpu_mask+0x3d/0xc0
[  174.849686]  [<ffffffff81189234>] drain_all_pages+0xf4/0x130
[  174.851483]  [<ffffffff8118b88b>] __alloc_pages_nodemask+0x8ab/0xe80
[  174.853646]  [<ffffffff811e0c82>] alloc_pages_current+0x92/0x190
[  174.855497]  [<ffffffff8117eef6>] __page_cache_alloc+0x146/0x180
[  174.857860]  [<ffffffff811809f7>] ? pagecache_get_page+0x27/0x280
[  174.859715]  [<ffffffff81182d02>] filemap_fault+0x442/0x680
[  174.861498]  [<ffffffff81182bc8>] ? filemap_fault+0x308/0x680
[  174.863624]  [<ffffffff8130dcd8>] xfs_filemap_fault+0x68/0x1f0
[  174.865439]  [<ffffffff811b8f1b>] __do_fault+0x6b/0x110
[  174.867120]  [<ffffffff811be802>] handle_mm_fault+0x1252/0x1980
[  174.868947]  [<ffffffff811bd5f8>] ? handle_mm_fault+0x48/0x1980
[  174.870763]  [<ffffffff8105432a>] __do_page_fault+0x1aa/0x530
[  174.872540]  [<ffffffff810546d1>] do_page_fault+0x21/0x70
[  174.874684]  [<ffffffff8172cb52>] page_fault+0x22/0x30
[  174.876354] Code: d2 e8 26 33 2b 00 3b 05 a4 26 be 00 41 89 c4 0f 8d 6b fe ff ff 48 63 d0 48 8b 0b 48 03 0c d5 20 14 cf 81 f6 41 18 01 74 08 f3 90 <f6> 41 18 01 75 f8 83 f8 ff 74 ba 83 f8 07 76 b5 80 3d 70 76 bc 
[  174.881275] NMI backtrace for cpu 1
[  174.882668] CPU: 1 PID: 5372 Comm: tgid=5368 Tainted: G             L  4.6.0-rc7-next-20160511 #426
[  174.885226] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  174.888341] task: ffff8800038c6440 ti: ffff880003af8000 task.ti: ffff880003af8000
[  174.890688] RIP: 0010:[<ffffffff8104594b>]  [<ffffffff8104594b>] __default_send_IPI_dest_field+0x3b/0x60
[  174.893307] RSP: 0000:ffff88007f843b90  EFLAGS: 00000046
[  174.895106] RAX: 0000000000000400 RBX: 0000000000000001 RCX: 0000000000000001
[  174.897232] RDX: 0000000000000400 RSI: 0000000000000002 RDI: 0000000002000000
[  174.899502] RBP: ffff88007f843ba0 R08: 000000000000000f R09: 0000000000000000
[  174.901658] R10: 0000000000000001 R11: 0000000000001d1e R12: 000000000000a12e
[  174.904146] R13: ffffffff81cf59a0 R14: 0000000000000002 R15: 0000000000000082
[  174.906259] FS:  00007fd2d1c82740(0000) GS:ffff88007f840000(0000) knlGS:0000000000000000
[  174.908544] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  174.910382] CR2: 00007fd2d176c480 CR3: 0000000005f64000 CR4: 00000000001406e0
[  174.912446] Stack:
[  174.913860]  000000007f843ba0 0000000200000002 ffff88007f843be0 ffffffff81045a37
[  174.915947]  ffff88007f843bc0 0000000000000001 0000000000000001 ffffffff81046b10
[  174.918031]  0000000000000007 ffff88007ace3100 ffff88007f843bf0 ffffffff81046b26
[  174.920220] Call Trace:
[  174.921448]  <IRQ> d [<ffffffff81045a37>] default_send_IPI_mask_sequence_phys+0x67/0xe0
[  174.923677]  [<ffffffff81046b10>] ? irq_force_complete_move+0x100/0x100
[  174.926005]  [<ffffffff81046b26>] nmi_raise_cpu_backtrace+0x16/0x20
[  174.928079]  [<ffffffff813b3104>] nmi_trigger_all_cpu_backtrace+0x64/0xfc
[  174.930088]  [<ffffffff81046b84>] arch_trigger_all_cpu_backtrace+0x14/0x20
[  174.932193]  [<ffffffff8146a5ee>] sysrq_handle_showallcpus+0xe/0x10
[  174.934125]  [<ffffffff8146ad16>] __handle_sysrq+0x136/0x220
[  174.935914]  [<ffffffff8146abe0>] ? __sysrq_get_key_op+0x30/0x30
[  174.937753]  [<ffffffff8146b19e>] sysrq_filter+0x36e/0x3b0
[  174.939497]  [<ffffffff81566172>] input_to_handler+0x52/0x100
[  174.941283]  [<ffffffff81568def>] input_pass_values.part.5+0x1ff/0x280
[  174.943228]  [<ffffffff81568bf0>] ? input_register_handler+0xc0/0xc0
[  174.945131]  [<ffffffff815695a4>] input_handle_event+0x114/0x4e0
[  174.946947]  [<ffffffff815699bf>] input_event+0x4f/0x70
[  174.948638]  [<ffffffff8157113d>] atkbd_interrupt+0x5bd/0x6a0
[  174.950409]  [<ffffffff81563531>] serio_interrupt+0x41/0x80
[  174.952183]  [<ffffffff8156412a>] i8042_interrupt+0x1da/0x3a0
[  174.954407]  [<ffffffff810e0949>] handle_irq_event_percpu+0x69/0x470
[  174.956320]  [<ffffffff810e0d84>] handle_irq_event+0x34/0x60
[  174.958205]  [<ffffffff810e41d3>] handle_edge_irq+0xa3/0x160
[  174.960187]  [<ffffffff8101f647>] handle_irq+0xf7/0x170
[  174.961870]  [<ffffffff8101eaca>] do_IRQ+0x6a/0x130
[  174.963462]  [<ffffffff81188420>] ? page_alloc_cpu_notify+0x40/0x40
[  174.969241]  [<ffffffff8172b593>] common_interrupt+0x93/0x93
[  174.971035]  <EOI> d [<ffffffff81188420>] ? page_alloc_cpu_notify+0x40/0x40
[  174.973042]  [<ffffffff811105bf>] ? smp_call_function_many+0x21f/0x2c0
[  174.975222]  [<ffffffff81188420>] ? page_alloc_cpu_notify+0x40/0x40
[  174.977089]  [<ffffffff8111079d>] on_each_cpu_mask+0x3d/0xc0
[  174.979940]  [<ffffffff81189234>] drain_all_pages+0xf4/0x130
[  174.981739]  [<ffffffff8118b88b>] __alloc_pages_nodemask+0x8ab/0xe80
[  174.983945]  [<ffffffff811e0c82>] alloc_pages_current+0x92/0x190
[  174.985740]  [<ffffffff8117eef6>] __page_cache_alloc+0x146/0x180
[  174.987576]  [<ffffffff81192061>] __do_page_cache_readahead+0x111/0x380
[  174.989462]  [<ffffffff811920ba>] ? __do_page_cache_readahead+0x16a/0x380
[  174.991327]  [<ffffffff811809f7>] ? pagecache_get_page+0x27/0x280
[  174.993432]  [<ffffffff81182bb3>] filemap_fault+0x2f3/0x680
[  174.995088]  [<ffffffff8130dccd>] ? xfs_filemap_fault+0x5d/0x1f0
[  174.996808]  [<ffffffff810c7c6d>] ? down_read_nested+0x2d/0x50
[  174.998586]  [<ffffffff8131e7c2>] ? xfs_ilock+0x1e2/0x2d0
[  175.000279]  [<ffffffff8130dcd8>] xfs_filemap_fault+0x68/0x1f0
[  175.002649]  [<ffffffff811b8f1b>] __do_fault+0x6b/0x110
[  175.004203]  [<ffffffff811be802>] handle_mm_fault+0x1252/0x1980
[  175.005888]  [<ffffffff811bd5f8>] ? handle_mm_fault+0x48/0x1980
[  175.007575]  [<ffffffff8105432a>] __do_page_fault+0x1aa/0x530
[  175.009203]  [<ffffffff810546d1>] do_page_fault+0x21/0x70
[  175.010840]  [<ffffffff8172cb52>] page_fault+0x22/0x30
[  175.012346] Code: 90 8b 04 25 00 d3 5f ff f6 c4 10 75 f2 c1 e7 18 89 3c 25 10 d3 5f ff 89 f0 09 d0 80 ce 04 83 fe 02 0f 44 c2 89 04 25 00 d3 5f ff <c9> c3 48 8b 05 74 be ca 00 89 55 f4 89 75 f8 89 7d fc ff 90 18 
[  175.017059] NMI backtrace for cpu 2
[  175.018546] CPU: 2 PID: 5207 Comm: tgid=5207 Tainted: G             L  4.6.0-rc7-next-20160511 #426
[  175.021220] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  175.025744] task: ffff880007860040 ti: ffff88005d7cc000 task.ti: ffff88005d7cc000
[  175.027749] RIP: 0010:[<ffffffff810d09db>]  [<ffffffff810d09db>] __rwsem_do_wake+0x5b/0x150
[  175.029917] RSP: 0000:ffff88005d7cfc10  EFLAGS: 00000082
[  175.031562] RAX: ffff8800795dbbc0 RBX: ffff880064645be0 RCX: ffffffff00000000
[  175.033558] RDX: fffffffe00000000 RSI: 0000000000000001 RDI: ffffffffffffffff
[  175.035618] RBP: ffff88005d7cfc38 R08: 0000000000000001 R09: 0000000000000000
[  175.037932] R10: ffff880007860040 R11: ffff8800078608d8 R12: ffff880064645be0
[  175.039920] R13: 0000000000000282 R14: ffff8800738ed068 R15: ffffea00016cb680
[  175.041979] FS:  00007fd2d1c82740(0000) GS:ffff88007f880000(0000) knlGS:0000000000000000
[  175.044474] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  175.046204] CR2: 00007f7252d7b540 CR3: 000000007a495000 CR4: 00000000001406e0
[  175.048219] Stack:
[  175.049286]  ffff880064645be0 ffff880064645bf8 0000000000000282 ffff8800738ed068
[  175.051392]  ffffea00016cb680 ffff88005d7cfc68 ffffffff810d0b18 ffff880064645be0
[  175.053477]  ffff880078d6db40 ffff88005d7cfdb0 ffff8800738ed068 ffff88005d7cfcb0
[  175.055587] Call Trace:
[  175.056745]  [<ffffffff810d0b18>] rwsem_wake+0x48/0xb0
[  175.058402]  [<ffffffff813bc99b>] call_rwsem_wake+0x1b/0x30
[  175.060146]  [<ffffffff810c7d80>] up_read+0x30/0x40
[  175.061774]  [<ffffffff8118283c>] __lock_page_or_retry+0x6c/0xf0
[  175.063597]  [<ffffffff81182a5c>] filemap_fault+0x19c/0x680
[  175.065324]  [<ffffffff81182bc8>] ? filemap_fault+0x308/0x680
[  175.067080]  [<ffffffff8130dcd8>] xfs_filemap_fault+0x68/0x1f0
[  175.069002]  [<ffffffff811b8f1b>] __do_fault+0x6b/0x110
[  175.070705]  [<ffffffff811be802>] handle_mm_fault+0x1252/0x1980
[  175.072513]  [<ffffffff811bd5f8>] ? handle_mm_fault+0x48/0x1980
[  175.074323]  [<ffffffff8105432a>] __do_page_fault+0x1aa/0x530
[  175.076093]  [<ffffffff810546d1>] do_page_fault+0x21/0x70
[  175.077784]  [<ffffffff8172cb52>] page_fault+0x22/0x30
[  175.079423] Code: 5f 5d c3 83 fe 02 0f 84 e5 00 00 00 be 01 00 00 00 48 b9 00 00 00 00 ff ff ff ff 48 c7 c7 ff ff ff ff 48 89 f2 f0 49 0f c1 14 24 <48> 39 ca 0f 8c c7 00 00 00 49 8b 54 24 08 be 01 00 00 00 4d 8d 
(...snipped...)
[  209.471203] sysrq: SysRq : Show backtrace of all active CPUs
[  209.473421] Sending NMI to all CPUs:
[  209.475059] NMI backtrace for cpu 0
[  209.476875] CPU: 0 PID: 5313 Comm: tgid=5309 Tainted: G             L  4.6.0-rc7-next-20160511 #426
[  209.479592] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  209.482566] task: ffff880073e91940 ti: ffff880079b88000 task.ti: ffff880079b88000
[  209.484837] RIP: 0010:[<ffffffff811105bf>]  [<ffffffff811105bf>] smp_call_function_many+0x21f/0x2c0
[  209.487465] RSP: 0000:ffff880079b8bbb8  EFLAGS: 00000202
[  209.489353] RAX: 0000000000000002 RBX: ffff88007f818880 RCX: ffff88007f89c238
[  209.491539] RDX: 0000000000000002 RSI: 0000000000000008 RDI: ffff88007f818888
[  209.493706] RBP: ffff880079b8bbf8 R08: 000000000000000c R09: 0000000000000000
[  209.495889] R10: 0000000000000001 R11: 0000000000000000 R12: 0000000000000002
[  209.498366] R13: 0000000000000008 R14: ffffffff81188420 R15: 0000000000000000
[  209.500459] FS:  00007fd2d1c82740(0000) GS:ffff88007f800000(0000) knlGS:0000000000000000
[  209.502701] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  209.504539] CR2: 00007f1069816541 CR3: 00000000657ec000 CR4: 00000000001406f0
[  209.508705] Stack:
[  209.510195]  0000000000018840 0100000000000001 ffff88007f818888 ffffffff82b50168
[  209.512492]  0000000000000000 ffffffff81188420 0000000000000000 0000000000000001
[  209.514658]  ffff880079b8bc30 ffffffff8111079d 0000000000000008 0000000000000000
[  209.516853] Call Trace:
[  209.518138]  [<ffffffff81188420>] ? page_alloc_cpu_notify+0x40/0x40
[  209.520060]  [<ffffffff8111079d>] on_each_cpu_mask+0x3d/0xc0
[  209.521855]  [<ffffffff81189234>] drain_all_pages+0xf4/0x130
[  209.523842]  [<ffffffff8118b88b>] __alloc_pages_nodemask+0x8ab/0xe80
[  209.525752]  [<ffffffff811e3259>] alloc_pages_vma+0xb9/0x2b0
[  209.527587]  [<ffffffff811be9e0>] handle_mm_fault+0x1430/0x1980
[  209.529484]  [<ffffffff811bd5f8>] ? handle_mm_fault+0x48/0x1980
[  209.531536]  [<ffffffff8105432a>] __do_page_fault+0x1aa/0x530
[  209.533310]  [<ffffffff810546d1>] do_page_fault+0x21/0x70
[  209.535023]  [<ffffffff8172cb52>] page_fault+0x22/0x30
[  209.536666] Code: d2 e8 26 33 2b 00 3b 05 a4 26 be 00 41 89 c4 0f 8d 6b fe ff ff 48 63 d0 48 8b 0b 48 03 0c d5 20 14 cf 81 f6 41 18 01 74 08 f3 90 <f6> 41 18 01 75 f8 83 f8 ff 74 ba 83 f8 07 76 b5 80 3d 70 76 bc 
[  209.542321] NMI backtrace for cpu 3
[  209.543740] CPU: 3 PID: 3765 Comm: nmbd Tainted: G             L  4.6.0-rc7-next-20160511 #426
[  209.546090] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  209.549111] task: ffff880079c81940 ti: ffff880078d38000 task.ti: ffff880078d38000
[  209.551336] RIP: 0010:[<ffffffff811105bf>]  [<ffffffff811105bf>] smp_call_function_many+0x21f/0x2c0
[  209.553848] RSP: 0000:ffff880078d3ba88  EFLAGS: 00000202
[  209.555668] RAX: 0000000000000002 RBX: ffff88007f8d8880 RCX: ffff88007f89d8f8
[  209.558128] RDX: 0000000000000002 RSI: 0000000000000008 RDI: ffff88007f8d8888
[  209.561152] RBP: ffff880078d3bac8 R08: 0000000000000005 R09: 0000000000000000
[  209.563334] R10: 0000000000000001 R11: 0000000000000000 R12: 0000000000000002
[  209.565526] R13: 0000000000000008 R14: ffffffff81188420 R15: 0000000000000000
[  209.567984] FS:  00007f72564d5840(0000) GS:ffff88007f8c0000(0000) knlGS:0000000000000000
[  209.570302] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  209.573204] CR2: 00007f0d7c0d7110 CR3: 000000007925d000 CR4: 00000000001406e0
[  209.575365] Stack:
[  209.576556]  0000000000018840 0100000000000001 ffff88007f8d8888 ffffffff82b50168
[  209.578709]  0000000000000003 ffffffff81188420 0000000000000000 0000000000000001
[  209.580948]  ffff880078d3bb00 ffffffff8111079d 0000000000000008 0000000000000000
[  209.583196] Call Trace:
[  209.584428]  [<ffffffff81188420>] ? page_alloc_cpu_notify+0x40/0x40
[  209.586703]  [<ffffffff8111079d>] on_each_cpu_mask+0x3d/0xc0
[  209.588513]  [<ffffffff81189234>] drain_all_pages+0xf4/0x130
[  209.590445]  [<ffffffff8118b88b>] __alloc_pages_nodemask+0x8ab/0xe80
[  209.592459]  [<ffffffff811e0c82>] alloc_pages_current+0x92/0x190
[  209.595874]  [<ffffffff8117eef6>] __page_cache_alloc+0x146/0x180
[  209.597738]  [<ffffffff811809f7>] ? pagecache_get_page+0x27/0x280
[  209.599601]  [<ffffffff81182d02>] filemap_fault+0x442/0x680
[  209.601363]  [<ffffffff81182bc8>] ? filemap_fault+0x308/0x680
[  209.603141]  [<ffffffff8130dcd8>] xfs_filemap_fault+0x68/0x1f0
[  209.604944]  [<ffffffff811b8f1b>] __do_fault+0x6b/0x110
[  209.607422]  [<ffffffff811be802>] handle_mm_fault+0x1252/0x1980
[  209.609281]  [<ffffffff811bd5f8>] ? handle_mm_fault+0x48/0x1980
[  209.611068]  [<ffffffff8105432a>] __do_page_fault+0x1aa/0x530
[  209.612826]  [<ffffffff810546d1>] do_page_fault+0x21/0x70
[  209.614518]  [<ffffffff8172cb52>] page_fault+0x22/0x30
[  209.616155] Code: d2 e8 26 33 2b 00 3b 05 a4 26 be 00 41 89 c4 0f 8d 6b fe ff ff 48 63 d0 48 8b 0b 48 03 0c d5 20 14 cf 81 f6 41 18 01 74 08 f3 90 <f6> 41 18 01 75 f8 83 f8 ff 74 ba 83 f8 07 76 b5 80 3d 70 76 bc 
[  209.621077] NMI backtrace for cpu 1
[  209.622473] CPU: 1 PID: 5372 Comm: tgid=5368 Tainted: G             L  4.6.0-rc7-next-20160511 #426
[  209.624907] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  209.628064] task: ffff8800038c6440 ti: ffff880003af8000 task.ti: ffff880003af8000
[  209.630234] RIP: 0010:[<ffffffff8104594b>]  [<ffffffff8104594b>] __default_send_IPI_dest_field+0x3b/0x60
[  209.632774] RSP: 0000:ffff88007f843b90  EFLAGS: 00000046
[  209.634554] RAX: 0000000000000400 RBX: 0000000000000001 RCX: 0000000000000001
[  209.636682] RDX: 0000000000000400 RSI: 0000000000000002 RDI: 0000000002000000
[  209.639148] RBP: ffff88007f843ba0 R08: 000000000000000f R09: 0000000000000000
[  209.641495] R10: 0000000000000001 R11: 0000000000001e88 R12: 000000000000a12e
[  209.643584] R13: ffffffff81cf59a0 R14: 0000000000000002 R15: 0000000000000082
[  209.645672] FS:  00007fd2d1c82740(0000) GS:ffff88007f840000(0000) knlGS:0000000000000000
[  209.648320] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  209.650338] CR2: 00007fd2d176c480 CR3: 0000000005f64000 CR4: 00000000001406e0
[  209.656131] Stack:
[  209.658919]  000000007f843ba0 0000000200000002 ffff88007f843be0 ffffffff81045a37
[  209.665787]  ffff88007f843bc0 0000000000000001 0000000000000001 ffffffff81046b10
[  209.671430]  0000000000000007 ffff88007ace3100 ffff88007f843bf0 ffffffff81046b26
[  209.675269] Call Trace:
[  209.676537]  <IRQ> d [<ffffffff81045a37>] default_send_IPI_mask_sequence_phys+0x67/0xe0
[  209.678825]  [<ffffffff81046b10>] ? irq_force_complete_move+0x100/0x100
[  209.680819]  [<ffffffff81046b26>] nmi_raise_cpu_backtrace+0x16/0x20
[  209.682741]  [<ffffffff813b3104>] nmi_trigger_all_cpu_backtrace+0x64/0xfc
[  209.684727]  [<ffffffff81046b84>] arch_trigger_all_cpu_backtrace+0x14/0x20
[  209.686744]  [<ffffffff8146a5ee>] sysrq_handle_showallcpus+0xe/0x10
[  209.689182]  [<ffffffff8146ad16>] __handle_sysrq+0x136/0x220
[  209.691013]  [<ffffffff8146abe0>] ? __sysrq_get_key_op+0x30/0x30
[  209.692861]  [<ffffffff8146b19e>] sysrq_filter+0x36e/0x3b0
[  209.694591]  [<ffffffff81566172>] input_to_handler+0x52/0x100
[  209.696354]  [<ffffffff81568def>] input_pass_values.part.5+0x1ff/0x280
[  209.698259]  [<ffffffff81568bf0>] ? input_register_handler+0xc0/0xc0
[  209.700143]  [<ffffffff815695a4>] input_handle_event+0x114/0x4e0
[  209.701948]  [<ffffffff815699bf>] input_event+0x4f/0x70
[  209.703670]  [<ffffffff8157113d>] atkbd_interrupt+0x5bd/0x6a0
[  209.705451]  [<ffffffff81563531>] serio_interrupt+0x41/0x80
[  209.707256]  [<ffffffff8156412a>] i8042_interrupt+0x1da/0x3a0
[  209.709449]  [<ffffffff810e0949>] handle_irq_event_percpu+0x69/0x470
[  209.711598]  [<ffffffff810e0d84>] handle_irq_event+0x34/0x60
[  209.713558]  [<ffffffff810e41d3>] handle_edge_irq+0xa3/0x160
[  209.715308]  [<ffffffff8101f647>] handle_irq+0xf7/0x170
[  209.716966]  [<ffffffff8101eaca>] do_IRQ+0x6a/0x130
[  209.718558]  [<ffffffff81188420>] ? page_alloc_cpu_notify+0x40/0x40
[  209.720407]  [<ffffffff8172b593>] common_interrupt+0x93/0x93
[  209.722147]  <EOI> d [<ffffffff81188420>] ? page_alloc_cpu_notify+0x40/0x40
[  209.724180]  [<ffffffff811105bf>] ? smp_call_function_many+0x21f/0x2c0
[  209.726093]  [<ffffffff81188420>] ? page_alloc_cpu_notify+0x40/0x40
[  209.728009]  [<ffffffff8111079d>] on_each_cpu_mask+0x3d/0xc0
[  209.729760]  [<ffffffff81189234>] drain_all_pages+0xf4/0x130
[  209.731481]  [<ffffffff8118b88b>] __alloc_pages_nodemask+0x8ab/0xe80
[  209.733322]  [<ffffffff811e0c82>] alloc_pages_current+0x92/0x190
[  209.735077]  [<ffffffff8117eef6>] __page_cache_alloc+0x146/0x180
[  209.736942]  [<ffffffff81192061>] __do_page_cache_readahead+0x111/0x380
[  209.738924]  [<ffffffff811920ba>] ? __do_page_cache_readahead+0x16a/0x380
[  209.740849]  [<ffffffff811809f7>] ? pagecache_get_page+0x27/0x280
[  209.742584]  [<ffffffff81182bb3>] filemap_fault+0x2f3/0x680
[  209.744241]  [<ffffffff8130dccd>] ? xfs_filemap_fault+0x5d/0x1f0
[  209.745991]  [<ffffffff810c7c6d>] ? down_read_nested+0x2d/0x50
[  209.748244]  [<ffffffff8131e7c2>] ? xfs_ilock+0x1e2/0x2d0
[  209.749849]  [<ffffffff8130dcd8>] xfs_filemap_fault+0x68/0x1f0
[  209.751538]  [<ffffffff811b8f1b>] __do_fault+0x6b/0x110
[  209.753159]  [<ffffffff811be802>] handle_mm_fault+0x1252/0x1980
[  209.754844]  [<ffffffff811bd5f8>] ? handle_mm_fault+0x48/0x1980
[  209.756518]  [<ffffffff8105432a>] __do_page_fault+0x1aa/0x530
[  209.758136]  [<ffffffff810546d1>] do_page_fault+0x21/0x70
[  209.759695]  [<ffffffff8172cb52>] page_fault+0x22/0x30
[  209.761195] Code: 90 8b 04 25 00 d3 5f ff f6 c4 10 75 f2 c1 e7 18 89 3c 25 10 d3 5f ff 89 f0 09 d0 80 ce 04 83 fe 02 0f 44 c2 89 04 25 00 d3 5f ff <c9> c3 48 8b 05 74 be ca 00 89 55 f4 89 75 f8 89 7d fc ff 90 18 
[  209.765816] NMI backtrace for cpu 2
[  209.767392] CPU: 2 PID: 5207 Comm: tgid=5207 Tainted: G             L  4.6.0-rc7-next-20160511 #426
[  209.769738] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  209.772854] task: ffff880007860040 ti: ffff88005d7cc000 task.ti: ffff88005d7cc000
[  209.775300] RIP: 0010:[<ffffffff810d0ab4>]  [<ffffffff810d0ab4>] __rwsem_do_wake+0x134/0x150
[  209.777929] RSP: 0000:ffff88005d7cfc10  EFLAGS: 00000097
[  209.779555] RAX: ffff8800795dbbc0 RBX: ffff880064645be0 RCX: ffffffff00000000
[  209.781522] RDX: fffffffe00000001 RSI: 0000000000000001 RDI: ffffffffffffffff
[  209.783490] RBP: ffff88005d7cfc38 R08: 0000000000000001 R09: 0000000000000000
[  209.785533] R10: ffff880007860040 R11: ffff8800078608d8 R12: ffff880064645be0
[  209.787876] R13: 0000000000000282 R14: ffff8800738ed068 R15: ffffea00016cb680
[  209.789858] FS:  00007fd2d1c82740(0000) GS:ffff88007f880000(0000) knlGS:0000000000000000
[  209.792025] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  209.793751] CR2: 00007f7252d7b540 CR3: 000000007a495000 CR4: 00000000001406e0
[  209.795772] Stack:
[  209.796839]  ffff880064645be0 ffff880064645bf8 0000000000000282 ffff8800738ed068
[  209.798923]  ffffea00016cb680 ffff88005d7cfc68 ffffffff810d0b18 ffff880064645be0
[  209.800992]  ffff880078d6db40 ffff88005d7cfdb0 ffff8800738ed068 ffff88005d7cfcb0
[  209.803058] Call Trace:
[  209.804220]  [<ffffffff810d0b18>] rwsem_wake+0x48/0xb0
[  209.806152]  [<ffffffff813bc99b>] call_rwsem_wake+0x1b/0x30
[  209.808068]  [<ffffffff810c7d80>] up_read+0x30/0x40
[  209.809769]  [<ffffffff8118283c>] __lock_page_or_retry+0x6c/0xf0
[  209.811709]  [<ffffffff81182a5c>] filemap_fault+0x19c/0x680
[  209.814493]  [<ffffffff81182bc8>] ? filemap_fault+0x308/0x680
[  209.816282]  [<ffffffff8130dcd8>] xfs_filemap_fault+0x68/0x1f0
[  209.818121]  [<ffffffff811b8f1b>] __do_fault+0x6b/0x110
[  209.819798]  [<ffffffff811be802>] handle_mm_fault+0x1252/0x1980
[  209.821614]  [<ffffffff811bd5f8>] ? handle_mm_fault+0x48/0x1980
[  209.823405]  [<ffffffff8105432a>] __do_page_fault+0x1aa/0x530
[  209.825154]  [<ffffffff810546d1>] do_page_fault+0x21/0x70
[  209.827191]  [<ffffffff8172cb52>] page_fault+0x22/0x30
[  209.828843] Code: a1 48 8b 78 10 e8 ad 06 fd ff 5b 4c 89 e0 41 5c 41 5d 41 5e 41 5f 5d c3 48 89 c2 31 f6 e9 43 ff ff ff 48 89 fa f0 49 0f c1 14 24 <83> ea 01 0f 84 15 ff ff ff e9 e3 fe ff ff 66 66 66 66 66 2e 0f 
----------------------------------------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
