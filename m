Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id AD7998E0001
	for <linux-mm@kvack.org>; Tue, 11 Sep 2018 10:02:24 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id w196-v6so1729788itb.4
        for <linux-mm@kvack.org>; Tue, 11 Sep 2018 07:02:24 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id a1-v6si12343025ion.111.2018.09.11.07.02.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Sep 2018 07:02:23 -0700 (PDT)
Subject: Re: [RFC PATCH 0/3] rework mmap-exit vs. oom_reaper handover
References: <1536382452-3443-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20180910125513.311-1-mhocko@kernel.org>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <70a92ca8-ca3e-2586-d52a-36c5ef6f7e43@i-love.sakura.ne.jp>
Date: Tue, 11 Sep 2018 23:01:57 +0900
MIME-Version: 1.0
In-Reply-To: <20180910125513.311-1-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>

On 2018/09/10 21:55, Michal Hocko wrote:
> This is a very coarse implementation of the idea I've had before.
> Please note that I haven't tested it yet. It is mostly to show the
> direction I would wish to go for.

Hmm, this patchset does not allow me to boot. ;-)

        free_pgd_range(&tlb, vma->vm_start, vma->vm_prev->vm_end,
                        FIRST_USER_ADDRESS, USER_PGTABLES_CEILING);

[    1.875675] sched_clock: Marking stable (1810466565, 65169393)->(1977240380, -101604422)
[    1.877833] registered taskstats version 1
[    1.877853] Loading compiled-in X.509 certificates
[    1.878835] zswap: loaded using pool lzo/zbud
[    1.880835] BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
[    1.881792] PGD 0 P4D 0 
[    1.881812] Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
[    1.882792] CPU: 1 PID: 121 Comm: modprobe Not tainted 4.19.0-rc3+ #469
[    1.883803] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 05/19/2017
[    1.884792] RIP: 0010:exit_mmap+0x122/0x1f0
[    1.884812] Code: 8b 5b 10 48 85 db 75 e7 45 84 e4 48 8b 45 00 0f 85 9a 00 00 00 48 8b 50 18 48 8b 30 48 8d 7c 24 08 45 31 c0 31 c9 48 89 04 24 <48> 8b 52 08 e8 45 3b ff ff 48 8d 7c 24 08 31 f6 48 c7 c2 ff ff ff
[    1.886793] RSP: 0018:ffffc90000897de0 EFLAGS: 00010246
[    1.887812] RAX: ffff88013494fcc0 RBX: 0000000000000000 RCX: 0000000000000000
[    1.888872] RDX: 0000000000000000 RSI: 0000000000400000 RDI: ffffc90000897de8
[    1.889794] RBP: ffff880134950040 R08: 0000000000000000 R09: 0000000000000000
[    1.890792] R10: 0000000000000001 R11: 0000000000081741 R12: 0000000000000000
[    1.891794] R13: ffff8801348fe240 R14: ffff8801348fe928 R15: 0000000000000000
[    1.892836] FS:  0000000000000000(0000) GS:ffff88013b240000(0000) knlGS:0000000000000000
[    1.893792] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[    1.894792] CR2: 0000000000000008 CR3: 000000000220f001 CR4: 00000000001606e0
[    1.895797] Call Trace:
[    1.895817]  ? switch_mm_irqs_off+0x2e1/0x870
[    1.895837]  mmput+0x63/0x130
[    1.895857]  do_exit+0x2a7/0xc80
[    1.895877]  ? __do_page_fault+0x219/0x520
[    1.896793]  ? trace_hardirqs_on_thunk+0x1a/0x1c
[    1.896813]  do_group_exit+0x41/0xc0
[    1.896833]  __x64_sys_exit_group+0xf/0x10
[    1.896853]  do_syscall_64+0x4f/0x1f0
[    1.896873]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
[    1.896893] RIP: 0033:0x7fa50e122909
[    1.896913] Code: Bad RIP value.
[    1.896933] RSP: 002b:00007fff0fdb96a8 EFLAGS: 00000246 ORIG_RAX: 00000000000000e7
[    1.897792] RAX: ffffffffffffffda RBX: 0000000000000001 RCX: 00007fa50e122909
[    1.898792] RDX: 0000000000000001 RSI: 0000000000000000 RDI: 0000000000000001
[    1.899795] RBP: 00007fa50e41f838 R08: 000000000000003c R09: 00000000000000e7
[    1.900800] R10: ffffffffffffff70 R11: 0000000000000246 R12: 00007fa50e41f838
[    1.901793] R13: 00007fa50e424e80 R14: 0000000000000000 R15: 0000000000000000
[    1.902796] Modules linked in:
[    1.902816] CR2: 0000000000000008
[    1.902836] ---[ end trace a1a4ea7953190d43 ]---
[    1.902856] RIP: 0010:exit_mmap+0x122/0x1f0
[    1.902876] Code: 8b 5b 10 48 85 db 75 e7 45 84 e4 48 8b 45 00 0f 85 9a 00 00 00 48 8b 50 18 48 8b 30 48 8d 7c 24 08 45 31 c0 31 c9 48 89 04 24 <48> 8b 52 08 e8 45 3b ff ff 48 8d 7c 24 08 31 f6 48 c7 c2 ff ff ff
[    1.905792] RSP: 0018:ffffc90000897de0 EFLAGS: 00010246
[    1.906792] RAX: ffff88013494fcc0 RBX: 0000000000000000 RCX: 0000000000000000
[    1.907799] RDX: 0000000000000000 RSI: 0000000000400000 RDI: ffffc90000897de8
[    1.908837] RBP: ffff880134950040 R08: 0000000000000000 R09: 0000000000000000
[    1.909814] R10: 0000000000000001 R11: 0000000000081741 R12: 0000000000000000
[    1.910812] R13: ffff8801348fe240 R14: ffff8801348fe928 R15: 0000000000000000
[    1.911807] FS:  0000000000000000(0000) GS:ffff88013b240000(0000) knlGS:0000000000000000
[    1.912792] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[    1.913820] CR2: 00007fa50e1228df CR3: 000000000220f001 CR4: 00000000001606e0
[    1.914812] Fixing recursive fault but reboot is needed!
[    2.076860] input: ImPS/2 Generic Wheel Mouse as /devices/platform/i8042/serio1/input/input3
[    2.667963] tsc: Refined TSC clocksource calibration: 2793.558 MHz
