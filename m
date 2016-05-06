Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 089976B007E
	for <linux-mm@kvack.org>; Fri,  6 May 2016 07:00:20 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id d62so243904222iof.1
        for <linux-mm@kvack.org>; Fri, 06 May 2016 04:00:20 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id e32si16572124iod.77.2016.05.06.04.00.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 06 May 2016 04:00:17 -0700 (PDT)
Subject: [next-20160506 mm,smp] hang up at csd_lock_wait() from drain_all_pages()
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-Id: <201605061958.HHG48967.JVFtSLFQOFOOMH@I-love.SAKURA.ne.jp>
Date: Fri, 6 May 2016 19:58:45 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, tglx@linutronix.de, mingo@kernel.org, akpm@linux-foundation.org, mgorman@techsingularity.net, mhocko@kernel.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hello.

I'm hitting this bug while doing OOM-killer torture test, but I can't tell
whether this is a mm bug. When I hit this bug, SysRq-l shows that multiple
CPUs are spinning at csd_lock_wait() called from on_each_cpu_mask()
called from drain_all_pages(). We can see that drain_all_pages() is using
unprotected global variable

    static cpumask_t cpus_with_pcps;

when calling on_each_cpu_mask().

Question 1:
Is on_each_cpu_mask() safe if struct cpumask argument (in this case
cpus_with_pcps) is modified by other CPUs?

Question 2:
Is it legal to call smp_call_func_t callback (in this case drain_local_pages())
concurrently which could contend on same spinlock (in this case zone->lock
in free_pcppages_bulk() called from drain_pages_zone() called from
drain_local_pages())?

Question 3:
Are on_each_cpu_mask(mask1, func1, info1, true) and on_each_cpu_mask(mask2,
func2, info2, true) safe each other when they are called at the same time?
(In other words, do we need to guarantee that on_each_cpu_mask() calls with
wait == true are globally serialized?)

Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-20160506.txt.xz .
----------------------------------------
[  234.861274] sysrq: SysRq : Show backtrace of all active CPUs
[  234.864808] Sending NMI to all CPUs:
[  234.867281] NMI backtrace for cpu 2
[  234.869576] CPU: 2 PID: 1181 Comm: smbd Not tainted 4.6.0-rc6-next-20160506 #124
[  234.873806] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  234.879711] task: ffff88003c374000 ti: ffff88003afec000 task.ti: ffff88003afec000
[  234.884219] RIP: 0010:[<ffffffff810f6c0f>]  [<ffffffff810f6c0f>] smp_call_function_many+0x1ef/0x240
[  234.890500] RSP: 0000:ffff88003afef9d8  EFLAGS: 00000202
[  234.893838] RAX: 0000000000000000 RBX: ffffffff8114ad30 RCX: ffffe8fffee02360
[  234.897968] RDX: 0000000000000000 RSI: 0000000000000040 RDI: ffff88003fb3a860
[  234.902089] RBP: ffff88003afefa10 R08: 000000000000000b R09: 0000000000000000
[  234.906288] R10: 0000000000000001 R11: ffff88003bac9f84 R12: 0000000000000000
[  234.910464] R13: ffff88003d6987c0 R14: 0000000000000040 R15: 0000000000018780
[  234.914637] FS:  00007f743eed2840(0000) GS:ffff88003d680000(0000) knlGS:0000000000000000
[  234.919262] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  234.922700] CR2: 00007f743b68ca00 CR3: 000000003875e000 CR4: 00000000001406e0
[  234.926923] Stack:
[  234.928529]  0000000000000002 0100000000000001 ffffffff82ce9c00 ffffffff8114ad30
[  234.932819]  0000000000000000 0000000000000002 0000000000000000 ffff88003afefa40
[  234.937150]  ffffffff810f6d64 0000000000000040 0000000000000000 0000000000000003
[  234.941562] Call Trace:
[  234.943421]  [<ffffffff8114ad30>] ? page_alloc_cpu_notify+0x40/0x40
[  234.947388]  [<ffffffff810f6d64>] on_each_cpu_mask+0x24/0x90
[  234.950884]  [<ffffffff8114b6da>] drain_all_pages+0xca/0xe0
[  234.954296]  [<ffffffff8114d5ac>] __alloc_pages_nodemask+0x70c/0xe30
[  234.958175]  [<ffffffff811972d6>] alloc_pages_current+0x96/0x1b0
[  234.961818]  [<ffffffff81142c6d>] __page_cache_alloc+0x12d/0x160
[  234.965498]  [<ffffffff811533a9>] __do_page_cache_readahead+0x109/0x360
[  234.969434]  [<ffffffff8115340b>] ? __do_page_cache_readahead+0x16b/0x360
[  234.973504]  [<ffffffff811435e7>] ? pagecache_get_page+0x27/0x260
[  234.977185]  [<ffffffff8114671b>] filemap_fault+0x31b/0x670
[  234.980625]  [<ffffffffa0251ab0>] ? xfs_ilock+0xd0/0xe0 [xfs]
[  234.984134]  [<ffffffffa0245a79>] xfs_filemap_fault+0x39/0x60 [xfs]
[  234.988488]  [<ffffffff811700db>] __do_fault+0x6b/0x120
[  234.991775]  [<ffffffff811768c7>] handle_mm_fault+0xed7/0x16f0
[  234.995342]  [<ffffffff81175a38>] ? handle_mm_fault+0x48/0x16f0
[  234.998910]  [<ffffffff8105af27>] ? __do_page_fault+0x127/0x4d0
[  235.002695]  [<ffffffff8105afb5>] __do_page_fault+0x1b5/0x4d0
[  235.006205]  [<ffffffff8105b300>] do_page_fault+0x30/0x80
[  235.009618]  [<ffffffff8161aa28>] page_fault+0x28/0x30
[  235.012798] Code: 63 d2 e8 65 bb 1e 00 3b 05 93 b7 c1 00 89 c2 0f 8d 99 fe ff ff 48 98 49 8b 4d 00 48 03 0c c5 e0 ed cf 81 f6 41 18 01 74 08 f3 90 <f6> 41 18 01 75 f8 eb be 48 c7 c2 80 1a d1 81 4c  
89 fe 44 89 f7
[  235.024075] NMI backtrace for cpu 1
[  235.026474] CPU: 1 PID: 398 Comm: systemd-journal Not tainted 4.6.0-rc6-next-20160506 #124
[  235.031317] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  235.039025] task: ffff8800386de080 ti: ffff880036550000 task.ti: ffff880036550000
[  235.043399] RIP: 0010:[<ffffffff810f6c0f>]  [<ffffffff810f6c0f>] smp_call_function_many+0x1ef/0x240
[  235.048558] RSP: 0000:ffff8800365539d8  EFLAGS: 00000202
[  235.051821] RAX: 0000000000000000 RBX: ffffffff8114ad30 RCX: ffffe8fffee02340
[  235.056213] RDX: 0000000000000000 RSI: 0000000000000040 RDI: ffff88003fb3a8e0
[  235.060439] RBP: ffff880036553a10 R08: 000000000000000d R09: 0000000000000000
[  235.064642] R10: 0000000000000001 R11: 0000000000000000 R12: 0000000000000000
[  235.068834] R13: ffff88003d6587c0 R14: 0000000000000040 R15: 0000000000018780
[  235.073214] FS:  00007f0362f4f880(0000) GS:ffff88003d640000(0000) knlGS:0000000000000000
[  235.077848] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  235.081284] CR2: 00007f0361b062e0 CR3: 00000000364d8000 CR4: 00000000001406e0
[  235.086255] Stack:
[  235.088069]  0000000000000001 0100000000000001 ffffffff82ce9c00 ffffffff8114ad30
[  235.092562]  0000000000000000 0000000000000001 0000000000000000 ffff880036553a40
[  235.096871]  ffffffff810f6d64 0000000000000040 0000000000000000 0000000000000003
[  235.101206] Call Trace:
[  235.102992]  [<ffffffff8114ad30>] ? page_alloc_cpu_notify+0x40/0x40
[  235.106935]  [<ffffffff810f6d64>] on_each_cpu_mask+0x24/0x90
[  235.110327]  [<ffffffff8114b6da>] drain_all_pages+0xca/0xe0
[  235.113678]  [<ffffffff8114d5ac>] __alloc_pages_nodemask+0x70c/0xe30
[  235.117443]  [<ffffffff811972d6>] alloc_pages_current+0x96/0x1b0
[  235.121231]  [<ffffffff81142c6d>] __page_cache_alloc+0x12d/0x160
[  235.124842]  [<ffffffff811533a9>] __do_page_cache_readahead+0x109/0x360
[  235.128717]  [<ffffffff8115340b>] ? __do_page_cache_readahead+0x16b/0x360
[  235.132676]  [<ffffffff811435e7>] ? pagecache_get_page+0x27/0x260
[  235.138094]  [<ffffffff8114671b>] filemap_fault+0x31b/0x670
[  235.141695]  [<ffffffffa0251ab0>] ? xfs_ilock+0xd0/0xe0 [xfs]
[  235.145120]  [<ffffffffa0245a79>] xfs_filemap_fault+0x39/0x60 [xfs]
[  235.148808]  [<ffffffff811700db>] __do_fault+0x6b/0x120
[  235.151975]  [<ffffffff811768c7>] handle_mm_fault+0xed7/0x16f0
[  235.155636]  [<ffffffff81175a38>] ? handle_mm_fault+0x48/0x16f0
[  235.159145]  [<ffffffff8105af27>] ? __do_page_fault+0x127/0x4d0
[  235.162643]  [<ffffffff8105afb5>] __do_page_fault+0x1b5/0x4d0
[  235.166045]  [<ffffffff8105b300>] do_page_fault+0x30/0x80
[  235.169412]  [<ffffffff8161aa28>] page_fault+0x28/0x30
[  235.172997] Code: 63 d2 e8 65 bb 1e 00 3b 05 93 b7 c1 00 89 c2 0f 8d 99 fe ff ff 48 98 49 8b 4d 00 48 03 0c c5 e0 ed cf 81 f6 41 18 01 74 08 f3 90 <f6> 41 18 01 75 f8 eb be 48 c7 c2 80 1a d1 81 4c  
89 fe 44 89 f7
[  235.184715] NMI backtrace for cpu 0
[  235.187229] CPU: 0 PID: 1294 Comm: tgid=1294 Not tainted 4.6.0-rc6-next-20160506 #124
[  235.192548] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  235.198853] task: ffff88003ad82100 ti: ffff88003ad88000 task.ti: ffff88003ad88000
[  235.203368] RIP: 0010:[<ffffffff810c2d94>]  [<ffffffff810c2d94>] __rwsem_do_wake+0x134/0x150
[  235.208393] RSP: 0000:ffff88003ad8bc20  EFLAGS: 00000097
[  235.211722] RAX: ffff880028647c00 RBX: ffff88003ad5e420 RCX: ffffffff00000000
[  235.216326] RDX: fffffffe00000001 RSI: 0000000000000001 RDI: ffffffffffffffff
[  235.220608] RBP: ffff88003ad8bc48 R08: 0000000000000001 R09: 0000000000000001
[  235.225009] R10: ffff88003ad82100 R11: ffff88003ad82c98 R12: ffff88003ad5e420
[  235.229220] R13: 0000000000000286 R14: 00000000024201ca R15: ffff88003ad8bdb0
[  235.233383] FS:  00007f30f147f740(0000) GS:ffff88003d600000(0000) knlGS:0000000000000000
[  235.238199] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  235.241693] CR2: 00007f30ec0e18c8 CR3: 000000003ad71000 CR4: 00000000001406f0
[  235.246447] Stack:
[  235.248025]  ffff88003ad5e420 ffff88003ad5e438 0000000000000286 00000000024201ca
[  235.252431]  ffff88003ad8bdb0 ffff88003ad8bc78 ffffffff810c31c5 ffff88003ad5e420
[  235.256818]  ffff880038086380 ffff88003d058468 00000000024201ca ffff88003ad8bcc0
[  235.261162] Call Trace:
[  235.262977]  [<ffffffff810c31c5>] rwsem_wake+0x55/0xd0
[  235.266244]  [<ffffffff812dba9b>] call_rwsem_wake+0x1b/0x30
[  235.269821]  [<ffffffff810b9b90>] up_read+0x30/0x40
[  235.272922]  [<ffffffff8114637c>] __lock_page_or_retry+0x6c/0xf0
[  235.276507]  [<ffffffff811465ab>] filemap_fault+0x1ab/0x670
[  235.279893]  [<ffffffff81146730>] ? filemap_fault+0x330/0x670
[  235.283374]  [<ffffffffa0245a79>] xfs_filemap_fault+0x39/0x60 [xfs]
[  235.287093]  [<ffffffff811700db>] __do_fault+0x6b/0x120
[  235.290439]  [<ffffffff811768c7>] handle_mm_fault+0xed7/0x16f0
[  235.294528]  [<ffffffff81175a38>] ? handle_mm_fault+0x48/0x16f0
[  235.298067]  [<ffffffff8105af27>] ? __do_page_fault+0x127/0x4d0
[  235.301731]  [<ffffffff8105afb5>] __do_page_fault+0x1b5/0x4d0
[  235.305507]  [<ffffffff8105b300>] do_page_fault+0x30/0x80
[  235.309014]  [<ffffffff8161aa28>] page_fault+0x28/0x30
[  235.312348] Code: a1 48 8b 78 10 e8 ed 83 fd ff 5b 4c 89 e0 41 5c 41 5d 41 5e 41 5f 5d c3 48 89 c2 31 f6 e9 43 ff ff ff 48 89 fa f0 49 0f c1 14 24 <83> ea 01 0f 84 15 ff ff ff e9 e3 fe ff ff 66 66  
66 66 66 2e 0f
[  235.323155] NMI backtrace for cpu 3
[  235.325497] CPU: 3 PID: 1602 Comm: tgid=1332 Not tainted 4.6.0-rc6-next-20160506 #124
[  235.330345] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  235.336438] task: ffff8800287a80c0 ti: ffff8800287ac000 task.ti: ffff8800287ac000
[  235.340943] RIP: 0010:[<ffffffff81049b5b>]  [<ffffffff81049b5b>] __default_send_IPI_dest_field+0x3b/0x60
[  235.346341] RSP: 0000:ffff88003d6c3be8  EFLAGS: 00000046
[  235.349666] RAX: 0000000000000400 RBX: 0000000000000003 RCX: 0000000000000003
[  235.353976] RDX: 0000000000000400 RSI: 0000000000000002 RDI: 0000000006000000
[  235.358389] RBP: ffff88003d6c3bf8 R08: 000000000000000f R09: 0000000000000000
[  235.363064] R10: 0000000000000001 R11: 000000000000109f R12: 000000000000a12e
[  235.367468] R13: ffffffff81d16bc0 R14: 0000000000000002 R15: 0000000000000046
[  235.371864] FS:  00007f30f147f740(0000) GS:ffff88003d6c0000(0000) knlGS:0000000000000000
[  235.376555] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  235.380145] CR2: 00007f743df6f218 CR3: 000000003aa1a000 CR4: 00000000001406e0
[  235.384447] Stack:
[  235.386016]  000000003d6c3bf8 0000000600000002 ffff88003d6c3c30 ffffffff81049c50
[  235.390469]  0000000000000001 0000000000000003 ffffffff8104ad90 0000000000000040
[  235.395174]  ffff88003cb93b88 ffff88003d6c3c40 ffffffff8104ada6 ffff88003d6c3c70
[  235.399489] Call Trace:
[  235.401306]  <IRQ> d [<ffffffff81049c50>] default_send_IPI_mask_sequence_phys+0x50/0xb0
[  235.406101]  [<ffffffff8104ad90>] ? irq_force_complete_move+0x120/0x120
[  235.410118]  [<ffffffff8104ada6>] nmi_raise_cpu_backtrace+0x16/0x20
[  235.413895]  [<ffffffff812d20cf>] nmi_trigger_all_cpu_backtrace+0xff/0x110
[  235.418023]  [<ffffffff8104ade4>] arch_trigger_all_cpu_backtrace+0x14/0x20
[  235.422167]  [<ffffffff813975fe>] sysrq_handle_showallcpus+0xe/0x10
[  235.425929]  [<ffffffff81397d01>] __handle_sysrq+0x131/0x210
[  235.429379]  [<ffffffff81397bd0>] ? __sysrq_get_key_op+0x30/0x30
[  235.433363]  [<ffffffff8139817e>] sysrq_filter+0x36e/0x3b0
[  235.436672]  [<ffffffff81469d52>] input_to_handler+0x52/0x100
[  235.440317]  [<ffffffff8146ba7c>] input_pass_values.part.5+0x1bc/0x260
[  235.444178]  [<ffffffff8146b8c0>] ? input_devices_seq_next+0x20/0x20
[  235.448137]  [<ffffffff8146be7b>] input_handle_event+0xfb/0x4f0
[  235.451687]  [<ffffffff8146c2be>] input_event+0x4e/0x70
[  235.455004]  [<ffffffff81474a0d>] atkbd_interrupt+0x5bd/0x6a0
[  235.458493]  [<ffffffff814670f1>] serio_interrupt+0x41/0x80
[  235.461836]  [<ffffffff81467d0a>] i8042_interrupt+0x1da/0x3a0
[  235.475800]  [<ffffffff810d06a3>] handle_irq_event_percpu+0x33/0x110
[  235.479609]  [<ffffffff810d07b4>] handle_irq_event+0x34/0x60
[  235.483096]  [<ffffffff810d3ac4>] handle_edge_irq+0xa4/0x140
[  235.486581]  [<ffffffff81027c98>] handle_irq+0x18/0x30
[  235.489883]  [<ffffffff8102756e>] do_IRQ+0x5e/0x120
[  235.493153]  [<ffffffff8114ad30>] ? page_alloc_cpu_notify+0x40/0x40
[  235.496848]  [<ffffffff81619896>] common_interrupt+0x96/0x96
[  235.500232]  <EOI> d [<ffffffff8114ad30>] ? page_alloc_cpu_notify+0x40/0x40
[  235.504513]  [<ffffffff810f6c0f>] ? smp_call_function_many+0x1ef/0x240
[  235.508409]  [<ffffffff810f6beb>] ? smp_call_function_many+0x1cb/0x240
[  235.512457]  [<ffffffff8114ad30>] ? page_alloc_cpu_notify+0x40/0x40
[  235.516123]  [<ffffffff810f6d64>] on_each_cpu_mask+0x24/0x90
[  235.519496]  [<ffffffff8114b6da>] drain_all_pages+0xca/0xe0
[  235.522973]  [<ffffffff8114d5ac>] __alloc_pages_nodemask+0x70c/0xe30
[  235.526736]  [<ffffffff811972d6>] alloc_pages_current+0x96/0x1b0
[  235.530238]  [<ffffffff81142c6d>] __page_cache_alloc+0x12d/0x160
[  235.533858]  [<ffffffff811533a9>] __do_page_cache_readahead+0x109/0x360
[  235.537651]  [<ffffffff8115340b>] ? __do_page_cache_readahead+0x16b/0x360
[  235.541675]  [<ffffffff811435e7>] ? pagecache_get_page+0x27/0x260
[  235.545568]  [<ffffffff8114671b>] filemap_fault+0x31b/0x670
[  235.548926]  [<ffffffffa0251ab0>] ? xfs_ilock+0xd0/0xe0 [xfs]
[  235.552416]  [<ffffffffa0245a79>] xfs_filemap_fault+0x39/0x60 [xfs]
[  235.556215]  [<ffffffff811700db>] __do_fault+0x6b/0x120
[  235.559306]  [<ffffffff811768c7>] handle_mm_fault+0xed7/0x16f0
[  235.562962]  [<ffffffff81175a38>] ? handle_mm_fault+0x48/0x16f0
[  235.566573]  [<ffffffff8105af27>] ? __do_page_fault+0x127/0x4d0
[  235.570058]  [<ffffffff8105afb5>] __do_page_fault+0x1b5/0x4d0
[  235.573929]  [<ffffffff8105b300>] do_page_fault+0x30/0x80
[  235.577161]  [<ffffffff8161aa28>] page_fault+0x28/0x30
[  235.580186] Code: 90 8b 04 25 00 d3 5f ff f6 c4 10 75 f2 c1 e7 18 89 3c 25 10 d3 5f ff 89 f0 09 d0 80 ce 04 83 fe 02 0f 44 c2 89 04 25 00 d3 5f ff <c9> c3 48 8b 05 e4 55 cc 00 89 55 f4 89 75 f8 89  
7d fc ff 90 18
----------------------------------------

----------------------------------------
00000000000f4810 <smp_call_function_many>:
  * hardware interrupt handler or from a bottom half handler. Preemption
  * must be disabled when calling this function.
  */
void smp_call_function_many(const struct cpumask *mask,
                             smp_call_func_t func, void *info, bool wait)
(...snipped...)
static inline void arch_send_call_function_ipi_mask(const struct cpumask *mask)
{
         smp_ops.send_call_func_ipi(mask);
    f49ac:       49 8b 7d 08             mov    0x8(%r13),%rdi
    f49b0:       ff 15 00 00 00 00       callq  *0x0(%rip)        # f49b6 <smp_call_function_many+0x1a6>
         }

         /* Send a message to all CPUs in the map */
         arch_send_call_function_ipi_mask(cfd->cpumask);

         if (wait) {
    f49b6:       80 7d d0 00             cmpb   $0x0,-0x30(%rbp)
    f49ba:       ba ff ff ff ff          mov    $0xffffffff,%edx
    f49bf:       0f 84 bd fe ff ff       je     f4882 <smp_call_function_many+0x72>
    f49c5:       48 63 35 00 00 00 00    movslq 0x0(%rip),%rsi        # f49cc <smp_call_function_many+0x1bc>
    f49cc:       49 8b 7d 08             mov    0x8(%r13),%rdi
    f49d0:       83 c2 01                add    $0x1,%edx
    f49d3:       48 63 d2                movslq %edx,%rdx
    f49d6:       e8 00 00 00 00          callq  f49db <smp_call_function_many+0x1cb>
                 for_each_cpu(cpu, cfd->cpumask) {
    f49db:       3b 05 00 00 00 00       cmp    0x0(%rip),%eax        # f49e1 <smp_call_function_many+0x1d1>
    f49e1:       89 c2                   mov    %eax,%edx
    f49e3:       0f 8d 99 fe ff ff       jge    f4882 <smp_call_function_many+0x72>
                         struct call_single_data *csd;

                         csd = per_cpu_ptr(cfd->csd, cpu);
    f49e9:       48 98                   cltq
    f49eb:       49 8b 4d 00             mov    0x0(%r13),%rcx
    f49ef:       48 03 0c c5 00 00 00    add    0x0(,%rax,8),%rcx
    f49f6:       00
  * previous function call. For multi-cpu calls its even more interesting
  * as we'll have to ensure no other cpu is observing our csd.
  */
static __always_inline void csd_lock_wait(struct call_single_data *csd)
{
         smp_cond_acquire(!(csd->flags & CSD_FLAG_LOCK));
    f49f7:       f6 41 18 01             testb  $0x1,0x18(%rcx)
    f49fb:       74 08                   je     f4a05 <smp_call_function_many+0x1f5>
    f49fd:       f3 90                   pause
    f49ff:       f6 41 18 01             testb  $0x1,0x18(%rcx)         /***** smp_call_function_many+0x1ef is here *****/
    f4a03:       75 f8                   jne    f49fd <smp_call_function_many+0x1ed>
    f4a05:       eb be                   jmp    f49c5 <smp_call_function_many+0x1b5>
                      && !oops_in_progress && !early_boot_irqs_disabled);

         /* Try to fastpath.  So, what's a CPU they want? Ignoring this one. */
         cpu = cpumask_first_and(mask, cpu_online_mask);
         if (cpu == this_cpu)
                 cpu = cpumask_next_and(cpu, mask, cpu_online_mask);
    f4a07:       48 c7 c2 00 00 00 00    mov    $0x0,%rdx
    f4a0e:       4c 89 fe                mov    %r15,%rsi
    f4a11:       44 89 f7                mov    %r14d,%edi
    f4a14:       e8 00 00 00 00          callq  f4a19 <smp_call_function_many+0x209>
    f4a19:       41 89 c5                mov    %eax,%r13d
    f4a1c:       e9 58 fe ff ff          jmpq   f4879 <smp_call_function_many+0x69>
         if (next_cpu == this_cpu)
                 next_cpu = cpumask_next_and(next_cpu, mask, cpu_online_mask);

         /* Fastpath: do that cpu by itself. */
----------------------------------------

Source code for OOM-killer torture test.
----------------------------------------
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <signal.h>
#include <poll.h>
#include <sched.h>
#include <sys/prctl.h>
#include <sys/wait.h>

static int memory_eater(void *unused)
{
	char *buf = NULL;
	unsigned long size = 0;
	while (1) {
		char *tmp = realloc(buf, size + 4096);
		if (!tmp)
			break;
		buf = tmp;
		buf[size] = 0;
		size += 4096;
		size %= 1048576;
	}
	kill(getpid(), SIGKILL);
	return 0;
}

static void child(void)
{
	char *stack = malloc(4096 * 2);
	char from[128] = { };
	char to[128] = { };
	const pid_t pid = getpid();
	unsigned char prev = 0;
	int fd = open("/proc/self/oom_score_adj", O_WRONLY);
	write(fd, "1000", 4);
	close(fd);
	snprintf(from, sizeof(from), "tgid=%u", pid);
	prctl(PR_SET_NAME, (unsigned long) from, 0, 0, 0);
	srand(pid);
	snprintf(from, sizeof(from), "file.%u-0", pid);
	fd = open(from, O_WRONLY | O_CREAT, 0600);
	if (fd == EOF)
		_exit(1);
	if (clone(memory_eater, stack + 4096, CLONE_THREAD | CLONE_SIGHAND | CLONE_VM, NULL) == -1)
		_exit(1);
	while (1) {
		const unsigned char next = rand();
		snprintf(from, sizeof(from), "file.%u-%u", pid, prev);
		snprintf(to, sizeof(to), "file.%u-%u", pid, next);
		prev = next;
		rename(from, to);
		write(fd, "", 1);
	}
	_exit(0);
}

int main(int argc, char *argv[])
{
	if (chdir("/tmp"))
		return 1;
	if (fork() == 0) {
		char *buf = NULL;
		unsigned long size;
		unsigned long i;
		for (size = 1048576; size < 512UL * (1 << 30); size <<= 1) {
			char *cp = realloc(buf, size);
			if (!cp) {
				size >>= 1;
				break;
			}
			buf = cp;
		}
		/* Will cause OOM due to overcommit */
		for (i = 0; i < size; i += 4096)
			buf[i] = 0;
		while (1)
			pause();
	} else {
		int children = 1024;
		while (1) {
			while (children > 0) {
				switch (fork()) {
				case 0:
					child();
				case -1:
					sleep(1);
					break;
				default:
					children--;
				}
			}
			wait(NULL);
			children++;
		}
	}
	return 0;
}
----------------------------------------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
