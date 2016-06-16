Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 778DD6B0005
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 22:48:30 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id g13so67347059ioj.3
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 19:48:30 -0700 (PDT)
Received: from mail-pa0-x244.google.com (mail-pa0-x244.google.com. [2607:f8b0:400e:c03::244])
        by mx.google.com with ESMTPS id wl5si18468141pab.81.2016.06.15.19.48.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jun 2016 19:48:28 -0700 (PDT)
Received: by mail-pa0-x244.google.com with SMTP id us13so2642010pab.1
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 19:48:28 -0700 (PDT)
Date: Thu, 16 Jun 2016 11:48:27 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v7 00/12] Support non-lru page migration
Message-ID: <20160616024827.GA497@swordfish>
References: <1464736881-24886-1-git-send-email-minchan@kernel.org>
 <20160615075909.GA425@swordfish>
 <20160615231248.GI17127@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160615231248.GI17127@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, dri-devel@lists.freedesktop.org, Hugh Dickins <hughd@google.com>, John Einar Reitan <john.reitan@foss.arm.com>, Jonathan Corbet <corbet@lwn.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Mel Gorman <mgorman@suse.de>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Aquini <aquini@redhat.com>, Rik van Riel <riel@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, virtualization@lists.linux-foundation.org, Gioh Kim <gi-oh.kim@profitbricks.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Sangseok Lee <sangseok.lee@lge.com>, Kyeongdon Kim <kyeongdon.kim@lge.com>, Chulmin Kim <cmlaika.kim@samsung.com>

Hi,

On (06/16/16 08:12), Minchan Kim wrote:
> > [  315.146533] kasan: CONFIG_KASAN_INLINE enabled
> > [  315.146538] kasan: GPF could be caused by NULL-ptr deref or user memory access
> > [  315.146546] general protection fault: 0000 [#1] PREEMPT SMP KASAN
> > [  315.146576] Modules linked in: lzo zram zsmalloc mousedev coretemp hwmon crc32c_intel r8169 i2c_i801 mii snd_hda_codec_realtek snd_hda_codec_generic snd_hda_intel snd_hda_codec snd_hda_core acpi_cpufreq snd_pcm snd_timer snd soundcore lpc_ich mfd_core processor sch_fq_codel sd_mod hid_generic usbhid hid ahci libahci libata ehci_pci ehci_hcd scsi_mod usbcore usb_common
> > [  315.146785] CPU: 3 PID: 38 Comm: khugepaged Not tainted 4.7.0-rc3-next-20160614-dbg-00004-ga1c2cbc-dirty #488
> > [  315.146841] task: ffff8800bfaf2900 ti: ffff880112468000 task.ti: ffff880112468000
> > [  315.146859] RIP: 0010:[<ffffffffa02c413d>]  [<ffffffffa02c413d>] zs_page_migrate+0x355/0xaa0 [zsmalloc]
> 
> Thanks for the report!
> 
> zs_page_migrate+0x355? Could you tell me what line is it?
> 
> It seems to be related to obj_to_head.

reproduced. a bit different call stack this time. but the problem is
still the same.

zs_compact()
...
    6371:       e8 00 00 00 00          callq  6376 <zs_compact+0x22b>
    6376:       0f 0b                   ud2    
    6378:       48 8b 95 a8 fe ff ff    mov    -0x158(%rbp),%rdx
    637f:       4d 8d 74 24 78          lea    0x78(%r12),%r14
    6384:       4c 89 ee                mov    %r13,%rsi
    6387:       4c 89 e7                mov    %r12,%rdi
    638a:       e8 86 c7 ff ff          callq  2b15 <get_first_obj_offset>
    638f:       41 89 c5                mov    %eax,%r13d
    6392:       4c 89 f0                mov    %r14,%rax
    6395:       48 c1 e8 03             shr    $0x3,%rax
    6399:       8a 04 18                mov    (%rax,%rbx,1),%al
    639c:       84 c0                   test   %al,%al
    639e:       0f 85 f2 02 00 00       jne    6696 <zs_compact+0x54b>
    63a4:       41 8b 44 24 78          mov    0x78(%r12),%eax
    63a9:       41 0f af c7             imul   %r15d,%eax
    63ad:       41 01 c5                add    %eax,%r13d
    63b0:       4c 89 f0                mov    %r14,%rax
    63b3:       48 c1 e8 03             shr    $0x3,%rax
    63b7:       48 01 d8                add    %rbx,%rax
    63ba:       48 89 85 88 fe ff ff    mov    %rax,-0x178(%rbp)
    63c1:       41 81 fd ff 0f 00 00    cmp    $0xfff,%r13d
    63c8:       0f 87 1a 03 00 00       ja     66e8 <zs_compact+0x59d>
    63ce:       49 63 f5                movslq %r13d,%rsi
    63d1:       48 03 b5 98 fe ff ff    add    -0x168(%rbp),%rsi
    63d8:       48 8b bd a8 fe ff ff    mov    -0x158(%rbp),%rdi
    63df:       e8 67 d9 ff ff          callq  3d4b <obj_to_head>
    63e4:       a8 01                   test   $0x1,%al
    63e6:       0f 84 d9 02 00 00       je     66c5 <zs_compact+0x57a>
    63ec:       48 83 e0 fe             and    $0xfffffffffffffffe,%rax
    63f0:       bf 01 00 00 00          mov    $0x1,%edi
    63f5:       48 89 85 b0 fe ff ff    mov    %rax,-0x150(%rbp)
    63fc:       e8 00 00 00 00          callq  6401 <zs_compact+0x2b6>
    6401:       48 8b 85 b0 fe ff ff    mov    -0x150(%rbp),%rax
					^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    6408:       f0 0f ba 28 00          lock btsl $0x0,(%rax)
    640d:       0f 82 98 02 00 00       jb     66ab <zs_compact+0x560>
    6413:       48 8b 85 10 fe ff ff    mov    -0x1f0(%rbp),%rax
    641a:       48 8d b8 48 10 00 00    lea    0x1048(%rax),%rdi
    6421:       48 89 f8                mov    %rdi,%rax
    6424:       48 c1 e8 03             shr    $0x3,%rax
    6428:       8a 04 18                mov    (%rax,%rbx,1),%al
    642b:       84 c0                   test   %al,%al
    642d:       0f 85 c5 02 00 00       jne    66f8 <zs_compact+0x5ad>
    6433:       48 8b 85 10 fe ff ff    mov    -0x1f0(%rbp),%rax
    643a:       65 4c 8b 2c 25 00 00    mov    %gs:0x0,%r13
    6441:       00 00 
    6443:       49 8d bd 48 10 00 00    lea    0x1048(%r13),%rdi
    644a:       ff 88 48 10 00 00       decl   0x1048(%rax)
    6450:       48 89 f8                mov    %rdi,%rax
    6453:       48 c1 e8 03             shr    $0x3,%rax
    6457:       8a 04 18                mov    (%rax,%rbx,1),%al
    645a:       84 c0                   test   %al,%al
    645c:       0f 85 a8 02 00 00       jne    670a <zs_compact+0x5bf>
    6462:       41 83 bd 48 10 00 00    cmpl   $0x0,0x1048(%r13)


which is

_next/./arch/x86/include/asm/bitops.h:206
_next/./arch/x86/include/asm/bitops.h:219
_next/include/linux/bit_spinlock.h:44
_next/mm/zsmalloc.c:950
_next/mm/zsmalloc.c:1774
_next/mm/zsmalloc.c:1809
_next/mm/zsmalloc.c:2306
_next/mm/zsmalloc.c:2346


smells like race conditon.



backtraces:

[  319.363646] kasan: CONFIG_KASAN_INLINE enabled
[  319.363650] kasan: GPF could be caused by NULL-ptr deref or user memory access
[  319.363658] general protection fault: 0000 [#1] PREEMPT SMP KASAN
[  319.363688] Modules linked in: lzo zram zsmalloc mousedev coretemp hwmon crc32c_intel snd_hda_codec_realtek snd_hda_codec_generic r8169 mii i2c_i801 snd_hda_intel snd_hda_codec snd_hda_core snd_pcm snd_timer acpi_cpufreq snd lpc_ich soundcore mfd_core processor sch_fq_codel sd_mod hid_generic usbhid hid ahci libahci ehci_pci libata ehci_hcd usbcore scsi_mod usb_common
[  319.363895] CPU: 0 PID: 45 Comm: kswapd0 Not tainted 4.7.0-rc3-next-20160615-dbg-00004-g550dc8a-dirty #490
[  319.363950] task: ffff8800bfb93d80 ti: ffff880112200000 task.ti: ffff880112200000
[  319.363968] RIP: 0010:[<ffffffffa03ce408>]  [<ffffffffa03ce408>] zs_compact+0x2bd/0xf22 [zsmalloc]
[  319.364000] RSP: 0018:ffff8801122077f8  EFLAGS: 00010293
[  319.364014] RAX: 2065676162726166 RBX: dffffc0000000000 RCX: 0000000000000000
[  319.364032] RDX: 1ffffffff064c504 RSI: ffff88003217c770 RDI: ffffffff83262ae0
[  319.364049] RBP: ffff880112207a18 R08: 0000000000000001 R09: 0000000000000000
[  319.364067] R10: ffff880112207768 R11: 00000000a19f2c26 R12: ffff8800a7caab00
[  319.364085] R13: 0000000000000770 R14: ffff8800a7caab78 R15: 0000000000000000
[  319.364103] FS:  0000000000000000(0000) GS:ffff880113600000(0000) knlGS:0000000000000000
[  319.364123] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  319.364138] CR2: 00007fa154633d70 CR3: 00000000b183d000 CR4: 00000000000006f0
[  319.364154] Stack:
[  319.364160]  ffffed00163d6a81 1ffff10017f729b9 ffff8800bfb944a0 ffffed0017f729b9
[  319.364191]  ffff8800bfb93d80 ffff8800b1eb5408 ffff8800bfb93d80 ffff8800bfb94dc8
[  319.364222]  ffff8800bfb944f8 ffff880000000001 1ffff10022440f1a 0000000041b58ab3
[  319.364252] Call Trace:
[  319.364264]  [<ffffffff8111f405>] ? debug_show_all_locks+0x226/0x226
[  319.364284]  [<ffffffffa03ce14b>] ? zs_free+0x27a/0x27a [zsmalloc]
[  319.364303]  [<ffffffff812303e3>] ? list_lru_count_one+0x65/0x6d
[  319.364320]  [<ffffffff81122faf>] ? lock_acquire+0xec/0x147
[  319.364336]  [<ffffffff812303b7>] ? list_lru_count_one+0x39/0x6d
[  319.364353]  [<ffffffff81d32e4f>] ? _raw_spin_unlock+0x2c/0x3f
[  319.364371]  [<ffffffffa03cf0a8>] zs_shrinker_scan+0x3b/0x4e [zsmalloc]
[  319.364391]  [<ffffffff81204eef>] shrink_slab.part.5.constprop.17+0x2e4/0x432
[  319.364411]  [<ffffffff81204c0b>] ? cpu_callback+0xb0/0xb0
[  319.364426]  [<ffffffff8120bfbc>] shrink_zone+0x19b/0x416
[  319.364442]  [<ffffffff8120be21>] ? shrink_zone_memcg.isra.14+0xd08/0xd08
[  319.364461]  [<ffffffff811f0b10>] ? zone_watermark_ok_safe+0x1e9/0x1f8
[  319.364478]  [<ffffffff81205fd7>] ? zone_reclaimable+0x14b/0x170
[  319.364495]  [<ffffffff8120d2fb>] kswapd+0xaad/0xcee
[  319.364510]  [<ffffffff8120c84e>] ? try_to_free_pages+0x617/0x617
[  319.364527]  [<ffffffff8111d13f>] ? trace_hardirqs_on_caller+0x3d2/0x492
[  319.364545]  [<ffffffff81111487>] ? prepare_to_wait_event+0x3f7/0x3f7
[  319.364564]  [<ffffffff810cd0de>] kthread+0x252/0x261
[  319.364578]  [<ffffffff8120c84e>] ? try_to_free_pages+0x617/0x617
[  319.364595]  [<ffffffff810cce8c>] ? kthread_create_on_node+0x377/0x377
[  319.364614]  [<ffffffff81d3387f>] ret_from_fork+0x1f/0x40
[  319.364629]  [<ffffffff810cce8c>] ? kthread_create_on_node+0x377/0x377
[  319.364645] Code: ff ff e8 67 d9 ff ff a8 01 0f 84 d9 02 00 00 48 83 e0 fe bf 01 00 00 00 48 89 85 b0 fe ff ff e8 71 78 d0 e0 48 8b 85 b0 fe ff ff <f0> 0f ba 28 00 0f 82 98 02 00 00 48 8b 85 10 fe ff ff 48 8d b8 
[  319.364913] RIP  [<ffffffffa03ce408>] zs_compact+0x2bd/0xf22 [zsmalloc]
[  319.364937]  RSP <ffff8801122077f8>
[  319.372870] ---[ end trace bcefd5a456f6b462 ]---



[  319.372875] BUG: sleeping function called from invalid context at include/linux/sched.h:2960
[  319.372877] in_atomic(): 1, irqs_disabled(): 0, pid: 45, name: kswapd0
[  319.372879] INFO: lockdep is turned off.
[  319.372880] Preemption disabled at:[<ffffffffa03ce2c3>] zs_compact+0x178/0xf22 [zsmalloc]

[  319.372891] CPU: 0 PID: 45 Comm: kswapd0 Tainted: G      D         4.7.0-rc3-next-20160615-dbg-00004-g550dc8a-dirty #490
[  319.372895]  0000000000000000 ffff880112207418 ffffffff814d69b0 ffff8800bfb93d80
[  319.372901]  0000000000000003 ffff880112207458 ffffffff810d6165 0000000000000000
[  319.372906]  ffff8800bfb93d80 ffffffff81e39860 0000000000000b90 0000000000000000
[  319.372911] Call Trace:
[  319.372915]  [<ffffffff814d69b0>] dump_stack+0x68/0x92
[  319.372919]  [<ffffffff810d6165>] ___might_sleep+0x3bd/0x3c9
[  319.372922]  [<ffffffff810d62cc>] __might_sleep+0x15b/0x167
[  319.372927]  [<ffffffff810ac7bf>] exit_signals+0x7a/0x34f
[  319.372931]  [<ffffffff810ac745>] ? get_signal+0xd9b/0xd9b
[  319.372934]  [<ffffffff811af758>] ? irq_work_queue+0x101/0x11c
[  319.372938]  [<ffffffff8111f405>] ? debug_show_all_locks+0x226/0x226
[  319.372943]  [<ffffffff81096655>] do_exit+0x34d/0x1b4e
[  319.372947]  [<ffffffff8113119f>] ? vprintk_emit+0x4b1/0x4d3
[  319.372951]  [<ffffffff81096308>] ? is_current_pgrp_orphaned+0x8c/0x8c
[  319.372954]  [<ffffffff81122faf>] ? lock_acquire+0xec/0x147
[  319.372957]  [<ffffffff81132578>] ? kmsg_dump+0x12/0x27a
[  319.372961]  [<ffffffff811327d1>] ? kmsg_dump+0x26b/0x27a
[  319.372965]  [<ffffffff81036507>] oops_end+0x9d/0xa4
[  319.372968]  [<ffffffff81036641>] die+0x55/0x5e
[  319.372971]  [<ffffffff81032aa0>] do_general_protection+0x16c/0x337
[  319.372975]  [<ffffffff81d34bbf>] general_protection+0x1f/0x30
[  319.372981]  [<ffffffffa03ce408>] ? zs_compact+0x2bd/0xf22 [zsmalloc]
[  319.372986]  [<ffffffffa03ce401>] ? zs_compact+0x2b6/0xf22 [zsmalloc]
[  319.372989]  [<ffffffff8111f405>] ? debug_show_all_locks+0x226/0x226
[  319.372995]  [<ffffffffa03ce14b>] ? zs_free+0x27a/0x27a [zsmalloc]
[  319.372999]  [<ffffffff812303e3>] ? list_lru_count_one+0x65/0x6d
[  319.373002]  [<ffffffff81122faf>] ? lock_acquire+0xec/0x147
[  319.373005]  [<ffffffff812303b7>] ? list_lru_count_one+0x39/0x6d
[  319.373009]  [<ffffffff81d32e4f>] ? _raw_spin_unlock+0x2c/0x3f
[  319.373014]  [<ffffffffa03cf0a8>] zs_shrinker_scan+0x3b/0x4e [zsmalloc]
[  319.373018]  [<ffffffff81204eef>] shrink_slab.part.5.constprop.17+0x2e4/0x432
[  319.373022]  [<ffffffff81204c0b>] ? cpu_callback+0xb0/0xb0
[  319.373025]  [<ffffffff8120bfbc>] shrink_zone+0x19b/0x416
[  319.373029]  [<ffffffff8120be21>] ? shrink_zone_memcg.isra.14+0xd08/0xd08
[  319.373032]  [<ffffffff811f0b10>] ? zone_watermark_ok_safe+0x1e9/0x1f8
[  319.373036]  [<ffffffff81205fd7>] ? zone_reclaimable+0x14b/0x170
[  319.373039]  [<ffffffff8120d2fb>] kswapd+0xaad/0xcee
[  319.373043]  [<ffffffff8120c84e>] ? try_to_free_pages+0x617/0x617
[  319.373046]  [<ffffffff8111d13f>] ? trace_hardirqs_on_caller+0x3d2/0x492
[  319.373050]  [<ffffffff81111487>] ? prepare_to_wait_event+0x3f7/0x3f7
[  319.373054]  [<ffffffff810cd0de>] kthread+0x252/0x261
[  319.373057]  [<ffffffff8120c84e>] ? try_to_free_pages+0x617/0x617
[  319.373060]  [<ffffffff810cce8c>] ? kthread_create_on_node+0x377/0x377
[  319.373064]  [<ffffffff81d3387f>] ret_from_fork+0x1f/0x40
[  319.373068]  [<ffffffff810cce8c>] ? kthread_create_on_node+0x377/0x377


[  319.373071] note: kswapd0[45] exited with preempt_count 3
[  322.891083] kmemleak: Cannot allocate a kmemleak_object structure


[  322.891091] kmemleak: Kernel memory leak detector disabled
[  322.891194] kmemleak: Automatic memory scanning thread ended


[  344.264076] NMI watchdog: BUG: soft lockup - CPU#1 stuck for 22s! [kworker/u8:3:108]
[  344.264080] Modules linked in: lzo zram zsmalloc mousedev coretemp hwmon crc32c_intel snd_hda_codec_realtek snd_hda_codec_generic r8169 mii i2c_i801 snd_hda_intel snd_hda_codec snd_hda_core snd_pcm snd_timer acpi_cpufreq snd lpc_ich soundcore mfd_core processor sch_fq_codel sd_mod hid_generic usbhid hid ahci libahci ehci_pci libata ehci_hcd usbcore scsi_mod usb_common
[  344.264118] irq event stamp: 13848655
[  344.264119] hardirqs last  enabled at (13848655): [<ffffffff8127dbd8>] __slab_alloc.isra.18.constprop.23+0x53/0x61
[  344.264127] hardirqs last disabled at (13848654): [<ffffffff8127db9e>] __slab_alloc.isra.18.constprop.23+0x19/0x61
[  344.264131] softirqs last  enabled at (13848614): [<ffffffff81d3565e>] __do_softirq+0x406/0x48f
[  344.264136] softirqs last disabled at (13848593): [<ffffffff81099448>] irq_exit+0x6a/0x113
[  344.264143] CPU: 1 PID: 108 Comm: kworker/u8:3 Tainted: G      D         4.7.0-rc3-next-20160615-dbg-00004-g550dc8a-dirty #490
[  344.264151] Workqueue: writeback wb_workfn (flush-254:0)
[  344.264155] task: ffff8800ba1c2900 ti: ffff8801122a0000 task.ti: ffff8801122a0000
[  344.264157] RIP: 0010:[<ffffffff814eeae3>]  [<ffffffff814eeae3>] delay_tsc+0x81/0xa4
[  344.264162] RSP: 0018:ffff8801122a70d0  EFLAGS: 00000206
[  344.264164] RAX: 000000000000001c RBX: 000000dc3a548e47 RCX: 0000000000000000
[  344.264166] RDX: 000000dc3a548e63 RSI: ffffffff81ed2e80 RDI: ffffffff81ed2ec0
[  344.264168] RBP: ffff8801122a70f0 R08: 0000000000000001 R09: 0000000000000000
[  344.264170] R10: ffff8801122a70e8 R11: 0000000045cb5d4f R12: 000000dc3a548e63
[  344.264172] R13: 0000000000000001 R14: 0000000000000001 R15: 0000000000000000
[  344.264175] FS:  0000000000000000(0000) GS:ffff880113680000(0000) knlGS:0000000000000000
[  344.264177] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  344.264179] CR2: 00007fa26a978978 CR3: 0000000002209000 CR4: 00000000000006e0
[  344.264180] Stack:
[  344.264181]  ffff8800a7caab00 ffff8800a7caab10 ffff8800a7caab08 0000000022af534e
[  344.264186]  ffff8801122a7100 ffffffff814eeb8c ffff8801122a7148 ffffffff81127ce6
[  344.264191]  ffffed0014f95560 000000009e85cd68 ffff8800a7caab00 ffff8800a7caab58
[  344.264196] Call Trace:
[  344.264199]  [<ffffffff814eeb8c>] __delay+0xa/0xc
[  344.264203]  [<ffffffff81127ce6>] do_raw_spin_lock+0x197/0x257
[  344.264206]  [<ffffffff81d32d0d>] _raw_spin_lock+0x35/0x3c
[  344.264212]  [<ffffffffa03ccd78>] ? zs_malloc+0x17e/0xb71 [zsmalloc]
[  344.264217]  [<ffffffffa03ccd78>] zs_malloc+0x17e/0xb71 [zsmalloc]
[  344.264220]  [<ffffffffa0190204>] ? lzo_decompress+0x11d/0x11d [lzo]
[  344.264223]  [<ffffffff81122faf>] ? lock_acquire+0xec/0x147
[  344.264228]  [<ffffffffa03ccbfa>] ? obj_malloc+0x372/0x372 [zsmalloc]
[  344.264233]  [<ffffffff81472ff9>] ? crypto_compress+0x87/0x93
[  344.264238]  [<ffffffffa041522d>] zram_bvec_rw+0x1073/0x1638 [zram]
[  344.264243]  [<ffffffffa04141ba>] ? zram_slot_free_notify+0x1c8/0x1c8 [zram]
[  344.264247]  [<ffffffff812fc37b>] ? wb_writeback+0x316/0x44c
[  344.264251]  [<ffffffffa0416104>] zram_make_request+0x6f5/0x89f [zram]
[  344.264255]  [<ffffffff81111ef0>] ? woken_wake_function+0x51/0x51
[  344.264260]  [<ffffffffa0415a0f>] ? zram_rw_page+0x21d/0x21d [zram]
[  344.264263]  [<ffffffff81494948>] ? blk_exit_rl+0x39/0x39
[  344.264267]  [<ffffffff81491130>] ? handle_bad_sector+0x192/0x192
[  344.264271]  [<ffffffff811506a1>] ? call_rcu+0x12/0x14
[  344.264274]  [<ffffffff8129a684>] ? put_object+0x58/0x5b
[  344.264277]  [<ffffffff81496128>] generic_make_request+0x2bc/0x496
[  344.264280]  [<ffffffff81495e6c>] ? blk_plug_queued_count+0x103/0x103
[  344.264283]  [<ffffffff814965fa>] submit_bio+0x2f8/0x324
[  344.264286]  [<ffffffff81496302>] ? generic_make_request+0x496/0x496
[  344.264289]  [<ffffffff813aa993>] ? ext4_reserve_inode_write+0x101/0x101
[  344.264292]  [<ffffffff813b44e8>] ext4_io_submit+0x12d/0x15d
[  344.264295]  [<ffffffff813ac54d>] ext4_writepages+0x15f9/0x1660
[  344.264298]  [<ffffffff813aaf54>] ? ext4_mark_inode_dirty+0x5c1/0x5c1
[  344.264301]  [<ffffffff8111f405>] ? debug_show_all_locks+0x226/0x226
[  344.264304]  [<ffffffff8111f405>] ? debug_show_all_locks+0x226/0x226
[  344.264307]  [<ffffffff8111f9a4>] ? __lock_acquire+0x59f/0x33b8
[  344.264311]  [<ffffffff811fa6ea>] do_writepages+0x93/0xa1
[  344.264315]  [<ffffffff812fb7a0>] ? writeback_sb_inodes+0x270/0x85e
[  344.264317]  [<ffffffff811fa6ea>] ? do_writepages+0x93/0xa1
[  344.264321]  [<ffffffff812fb287>] __writeback_single_inode+0x8b/0x334
[  344.264324]  [<ffffffff812fb9c9>] writeback_sb_inodes+0x499/0x85e
[  344.264327]  [<ffffffff812fb530>] ? __writeback_single_inode+0x334/0x334
[  344.264331]  [<ffffffff81115e1c>] ? down_read_trylock+0x53/0xaf
[  344.264335]  [<ffffffff812a7398>] ? trylock_super+0x16/0xaf
[  344.264338]  [<ffffffff812fbe95>] __writeback_inodes_wb+0x107/0x17d
[  344.264341]  [<ffffffff812fc37b>] wb_writeback+0x316/0x44c
[  344.264345]  [<ffffffff812fc065>] ? writeback_inodes_wb.constprop.10+0x15a/0x15a
[  344.264348]  [<ffffffff811f837f>] ? wb_over_bg_thresh+0x110/0x194
[  344.264351]  [<ffffffff811f826f>] ? balance_dirty_pages_ratelimited+0x14f5/0x14f5
[  344.264354]  [<ffffffff812fce5d>] ? wb_workfn+0x296/0x6d6
[  344.264357]  [<ffffffff812fced4>] wb_workfn+0x30d/0x6d6
[  344.264360]  [<ffffffff812fced4>] ? wb_workfn+0x30d/0x6d6
[  344.264364]  [<ffffffff812fcbc7>] ? inode_wait_for_writeback+0x2e/0x2e
[  344.264368]  [<ffffffff810be6d0>] process_one_work+0x6f4/0xb2c
[  344.264371]  [<ffffffff810bdfdc>] ? pwq_dec_nr_in_flight+0x22b/0x22b
[  344.264375]  [<ffffffff810c0de0>] worker_thread+0x5bb/0x88e
[  344.264378]  [<ffffffff810cd0de>] kthread+0x252/0x261
[  344.264381]  [<ffffffff810c0825>] ? rescuer_thread+0x879/0x879
[  344.264383]  [<ffffffff810cce8c>] ? kthread_create_on_node+0x377/0x377
[  344.264387]  [<ffffffff81d3387f>] ret_from_fork+0x1f/0x40
[  344.264390]  [<ffffffff810cce8c>] ? kthread_create_on_node+0x377/0x377
[  344.264392] Code: 14 6a b2 7e 85 c0 75 05 e8 8b 35 b1 ff f3 90 bf 01 00 00 00 e8 a1 71 be ff e8 e6 f3 01 00 44 39 f0 74 b6 4c 29 e3 49 01 dd eb 97 <bf> 01 00 00 00 e8 4c 81 be ff 65 8b 05 dc 69 b2 7e 85 c0 75 05 


> Could you test with [zsmalloc: keep first object offset in struct page]
> in mmotm?

sure, I can.  will it help, tho? we have a race condition here I think.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
