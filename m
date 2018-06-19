Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id A72A36B0003
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 22:51:46 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id h4-v6so16544369qkm.9
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 19:51:46 -0700 (PDT)
Received: from frisell.zx2c4.com (frisell.zx2c4.com. [192.95.5.64])
        by mx.google.com with ESMTPS id e11-v6si767042qvo.221.2018.06.18.19.51.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 18 Jun 2018 19:51:45 -0700 (PDT)
Received: 
	by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTP id a875fb2a
	for <linux-mm@kvack.org>;
	Tue, 19 Jun 2018 02:45:50 +0000 (UTC)
Received: 
	by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTPSA id fd038d6b (TLSv1.2:ECDHE-RSA-AES128-GCM-SHA256:128:NO)
	for <linux-mm@kvack.org>;
	Tue, 19 Jun 2018 02:45:48 +0000 (UTC)
Received: by mail-ot0-f173.google.com with SMTP id a5-v6so20874086otf.12
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 19:51:37 -0700 (PDT)
MIME-Version: 1.0
From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Date: Tue, 19 Jun 2018 04:51:25 +0200
Message-ID: <CAHmME9rtoPwxUSnktxzKso14iuVCWT7BE_-_8PAC=pGw1iJnQg@mail.gmail.com>
Subject: Possible regression in "slab, slub: skip unnecessary kasan_cache_shutdown()"
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aryabinin@virtuozzo.com, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, Andrew Morton <akpm@linux-foundation.org>, kasan-dev@googlegroups.com, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Shakeel Butt <shakeelb@google.com>

Hello Shakeel,

It may be the case that f9e13c0a5a33d1eaec374d6d4dab53a4f72756a0 has
introduced a regression. I've bisected a failing test to this commit,
and after staring at the my code for a long time, I'm unable to find a
bug that this commit might have unearthed. Rather, it looks like this
commit introduces a performance optimization, rather than a
correctness fix, so it seems that whatever test case is failing is
likely an incorrect failure. Does that seem like an accurate
possibility to you?

Below is a stack trace when things go south. Let me know if you'd like
to run my test suite, and I can send additional information.

Regards,
Jason


[    1.364686] kasan: GPF could be caused by NULL-ptr deref or user
memory access
[    1.365258] general protection fault: 0000 [#1] PREEMPT SMP
DEBUG_PAGEALLOC KASAN
[    1.365852] CPU: 1 PID: 1 Comm: swapper/0 Not tainted 4.16.0 #19
[    1.366315] RIP: 0010:___cache_free+0x76/0x1e0
[    1.366667] RSP: 0000:ffff8800003af868 EFLAGS: 00010286
[    1.367079] RAX: ffffea0000cb04a0 RBX: ffff8800351f1958 RCX: ffff880035954900
[    1.367640] RDX: ffffea0000cb049f RSI: ffff8800351f1958 RDI: ffff880035954900
[    1.368014] RBP: ffffea0000d47c40 R08: ffff8800003a0870 R09: 0000000000000006
[    1.368014] R10: 0000000000000000 R11: 0000000000000000 R12: ffff880033314b98
[    1.368014] R13: ffff880035954900 R14: ffffea0000000000 R15: ffffffff826dfae0
[    1.368014] FS:  0000000000000000(0000) GS:ffff880036480000(0000)
knlGS:00000000000
[    1.368014] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[    1.368014] CR2: 00000000ffffffff CR3: 0000000002220001 CR4: 00000000001606a0
[    1.368014] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[    1.368014] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[    1.368014] Call Trace:
[    1.368014]  ? qlist_free_all+0x58/0x1c0
[    1.368014]  qlist_free_all+0x70/0x1c0
[    1.368014]  ? trace_hardirqs_on_caller+0x3d0/0x630
[    1.368014]  quarantine_reduce+0x221/0x310
[    1.368014]  kasan_kmalloc+0x95/0xc0
[    1.368014]  kmem_cache_alloc+0x151/0x2b0
[    1.368014]  create_object+0xa7/0xa70
[    1.368014]  ? kmemleak_disable+0x90/0x90
[    1.368014]  ? trace_hardirqs_on_caller+0x3d0/0x630
[    1.368014]  ? fs_reclaim_acquire.part.14+0x30/0x30
[    1.368014]  __kmalloc+0x200/0x340
[    1.368014]  ? do_one_initcall+0x12c/0x212
[    1.368014]  __register_sysctl_table+0xbe/0x11b0
[    1.368014]  ipv4_sysctl_init_net+0x1cf/0x2d0
[    1.368014]  ops_init+0x203/0x510
[    1.368014]  ? proc_sys_setattr+0xe0/0xe0
[    1.368014]  ? __peernet2id_alloc+0x180/0x180
[    1.368014]  ? __rb_erase_color+0x1d90/0x1d90
[    1.368014]  register_pernet_operations+0x38e/0x960
[    1.368014]  ? setup_net+0x8b0/0x8b0
[    1.368014]  ? register_pernet_subsys+0x10/0x40
[    1.368014]  ? down_write+0x96/0x150
[    1.368014]  ? register_pernet_subsys+0x10/0x40
[    1.368014]  ? __register_sysctl_table+0x669/0x11b0
[    1.368014]  ? gre_offload_init+0x44/0x44
[    1.368014]  register_pernet_subsys+0x1f/0x40
[    1.368014]  sysctl_ipv4_init+0x34/0x47
[    1.368014]  do_one_initcall+0x12c/0x212
[    1.368014]  ? start_kernel+0x60e/0x60e
[    1.368014]  ? up_write+0x78/0x220
[    1.368014]  ? up_read+0x130/0x130
[    1.368014]  ? __asan_register_globals+0x53/0x80
[    1.368014]  ? kasan_unpoison_shadow+0x30/0x40
[    1.368014]  kernel_init_freeable+0x3b5/0x459
[    1.368014]  ? rest_init+0x2bf/0x2bf
[    1.368014]  kernel_init+0x7/0x11b
[    1.368014]  ? rest_init+0x2bf/0x2bf
[    1.368014]  ret_from_fork+0x24/0x30
[    1.368014] Code: 83 fd e0 0f 84 62 01 00 00 48 8b 45 20 49 c7 c7
e0 fa 6d 82 48 8
[    1.368014] RIP: ___cache_free+0x76/0x1e0 RSP: ffff8800003af868
[    1.387680] ---[ end trace 975b7b250dd637de ]---
[    1.388098] Kernel panic - not syncing: Fatal exception
[    1.388655] Kernel Offset: disabled
