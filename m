Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 8223D9003C7
	for <linux-mm@kvack.org>; Thu, 13 Aug 2015 11:12:19 -0400 (EDT)
Received: by wicne3 with SMTP id ne3so144037476wic.0
        for <linux-mm@kvack.org>; Thu, 13 Aug 2015 08:12:19 -0700 (PDT)
Received: from mail-wi0-x241.google.com (mail-wi0-x241.google.com. [2a00:1450:400c:c05::241])
        by mx.google.com with ESMTPS id f8si4562684wix.1.2015.08.13.08.12.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Aug 2015 08:12:18 -0700 (PDT)
Received: by wibvo3 with SMTP id vo3so10891859wib.3
        for <linux-mm@kvack.org>; Thu, 13 Aug 2015 08:12:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <55be1332.5NMwVwgRwvmoOtmG%fengguang.wu@intel.com>
References: <55be1332.5NMwVwgRwvmoOtmG%fengguang.wu@intel.com>
Date: Thu, 13 Aug 2015 18:12:17 +0300
Message-ID: <CAPAsAGw8Td3KU3_vT3fr4=HZtFEDtycpSCpeSR-dYBGqmL8Q9g@mail.gmail.com>
Subject: Re: [x86_64] RIP: 0010:[<ffffffff813bc3dc>] [<ffffffff813bc3dc>] __asan_store8
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel test robot <fengguang.wu@intel.com>
Cc: LKP <lkp@01.org>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Andrey Konovalov <adech.fo@gmail.com>, wfg@linux.intel.com

2015-08-02 15:55 GMT+03:00 kernel test robot <fengguang.wu@intel.com>:
> Greetings,
>
> 0day kernel testing robot got the below dmesg and the first bad commit is
>

So you have preemption enabled and some heavy debug options:
CONFIG_GCOV_PROFILE_ALL=y
CONFIG_KASAN=y

>
> [   53.667591] xz_dec_test: Create a device node with 'mknod xz_dec_test c 250 0' and write .xz files to it.
> [   53.671288] rbtree testing

But why is your vm so slow? Perhaps your host is overloaded so guests
run too slow.
E.g. mine guest reaches this point in less than 2 seconds.

We could stick cond_resched() into for loops in rbtree_test_init(),
but likely you just get
soft lockup in some other place.


> [   80.140009] NMI watchdog: BUG: soft lockup - CPU#0 stuck for 22s! [swapper:1]
> [   80.140009] Modules linked in:
> [   80.140009] CPU: 0 PID: 1 Comm: swapper Not tainted 3.19.0-05243-gef7f0d6 #4
> [   80.140009] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140531_083030-gandalf 04/01/2014
> [   80.140009] task: ffff88000e4d0000 ti: ffff88000e4d8000 task.ti: ffff88000e4d8000
> [   80.140009] RIP: 0010:[<ffffffff813bc3dc>]  [<ffffffff813bc3dc>] __asan_store8+0x4c/0x140
> [   80.140009] RSP: 0018:ffff88000e4dbd88  EFLAGS: 00000206
> [   80.140009] RAX: 0000000086dfa090 RBX: ffffffff8413730f RCX: dffffc0000000000
> [   80.140009] RDX: 0000000086dfa08f RSI: 0000000000000008 RDI: ffffffff84a3d468
> [   80.140009] RBP: ffff88000e4dbdb8 R08: fffffbfff0826e61 R09: ffffffff8413730f
> [   80.140009] R10: 0000000026d79129 R11: 0000000026d6454e R12: 0000000026d6bb7e
> [   80.140009] R13: 1ffffffff0826e61 R14: 0000000000000010 R15: ffff88000e4dbdb8
> [   80.140009] FS:  0000000000000000(0000) GS:ffffffff838b0000(0000) knlGS:0000000000000000
> [   80.140009] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [   80.140009] CR2: 0000000000000000 CR3: 000000000388a000 CR4: 00000000000006b0
> [   80.140009] Stack:
> [   80.140009]  ffff88000e4dbdf8 ffffffff84a3d440 ffffffff84a3cfb8 0000000000000002
> [   80.140009]  00000000b4f0c03a ffffffff84a3d460 ffff88000e4dbdf8 ffffffff82d2a679
> [   80.140009]  0000000026d79123 00000000000005c8 0000000000004094 00000034c1e9ef3c
> [   80.140009] Call Trace:
> [   80.140009]  [<ffffffff82d2a679>] insert+0x9d/0xf1
> [   80.140009]  [<ffffffff844eef7e>] rbtree_test_init+0x98/0x32c
> [   80.140009]  [<ffffffff810006a9>] do_one_initcall+0x409/0x570
> [   80.140009]  [<ffffffff844eeee6>] ? dynamic_debug_init+0x52a/0x52a
> [   80.140009]  [<ffffffff8446d38b>] kernel_init_freeable+0x25a/0x3e4
> [   80.140009]  [<ffffffff811567d4>] ? finish_task_switch+0x274/0x4c0
> [   80.140009]  [<ffffffff82d142c0>] ? rest_init+0xe0/0xe0
> [   80.140009]  [<ffffffff82d142df>] kernel_init+0x1f/0x2b0
> [   80.140009]  [<ffffffff82d142c0>] ? rest_init+0xe0/0xe0
> [   80.140009]  [<ffffffff82d50ffa>] ret_from_fork+0x7a/0xb0
> [   80.140009]  [<ffffffff82d142c0>] ? rest_init+0xe0/0xe0
> [   80.140009] Code: 01 48 39 c7 76 49 48 8b 15 42 ce 3f 03 48 b9 00 00 00 00 00 fc ff df 48 83 05 00 d2 3f 03 01 48 8d 42 01 48 83 05 04 d2 3f 03 01 <48> 89 05 1d ce 3f 03 48 89 f8 48 c1 e8 03 48 01 c8 66 83 38 00
> [   80.140009] Kernel panic - not syncing: softlockup: hung tasks
> [   80.140009] CPU: 0 PID: 1 Comm: swapper Tainted: G             L  3.19.0-05243-gef7f0d6 #4
> [   80.140009] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140531_083030-gandalf 04/01/2014
> [   80.140009]  0000000000000003 0000000000000003 0000000000000001 ffff88000e4dbc01
> [   80.140009]  0000000000000000 ffffffff838b3da8 ffffffff82d28acb ffffffff838b3e38
> [   80.140009]  ffffffff82d1c785 ffffffff838b3e38 ffffffff00000008 ffffffff838b3e48
> [   80.140009] Call Trace:
> [   80.140009]  <IRQ>  [<ffffffff82d28acb>] dump_stack+0x2e/0x3e
> [   80.140009]  [<ffffffff82d1c785>] panic+0x1bb/0x4d6
> [   80.140009]  [<ffffffff81227d1e>] watchdog_timer_fn+0x46e/0x470
> [   80.140009]  [<ffffffff811b7aca>] hrtimer_run_queues+0x5aa/0xb30
> [   80.140009]  [<ffffffff812278b0>] ? watchdog+0x40/0x40
> [   80.140009]  [<ffffffff811b59cb>] update_process_times+0x3b/0xe0
> [   80.140009]  [<ffffffff811ddb6e>] tick_nohz_handler+0x15e/0x350
> [   80.140009]  [<ffffffff81071dd5>] local_apic_timer_interrupt+0x65/0xb0
> [   80.140009]  [<ffffffff81072245>] smp_apic_timer_interrupt+0x85/0xb0
> [   80.140009]  [<ffffffff82d51dfb>] apic_timer_interrupt+0x6b/0x70
> [   80.140009]  <EOI>  [<ffffffff813bc3dc>] ? __asan_store8+0x4c/0x140
> [   80.140009]  [<ffffffff82d2a679>] insert+0x9d/0xf1
> [   80.140009]  [<ffffffff844eef7e>] rbtree_test_init+0x98/0x32c
> [   80.140009]  [<ffffffff810006a9>] do_one_initcall+0x409/0x570
> [   80.140009]  [<ffffffff844eeee6>] ? dynamic_debug_init+0x52a/0x52a
> [   80.140009]  [<ffffffff8446d38b>] kernel_init_freeable+0x25a/0x3e4
> [   80.140009]  [<ffffffff811567d4>] ? finish_task_switch+0x274/0x4c0
> [   80.140009]  [<ffffffff82d142c0>] ? rest_init+0xe0/0xe0
> [   80.140009]  [<ffffffff82d142df>] kernel_init+0x1f/0x2b0
> [   80.140009]  [<ffffffff82d142c0>] ? rest_init+0xe0/0xe0
> [   80.140009]  [<ffffffff82d50ffa>] ret_from_fork+0x7a/0xb0
> [   80.140009]  [<ffffffff82d142c0>] ? rest_init+0xe0/0xe0
> [   80.140009] Kernel Offset: 0x0 from 0xffffffff81000000 (relocation range: 0xffffffff80000000-0xffffffff9fffffff)
>
> Elapsed time: 110
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
