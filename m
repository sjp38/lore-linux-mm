From: Sasha Levin <levinsasha928@gmail.com>
Subject: mm: divide by zero in percpu_pagelist_fraction_sysctl_handler()
Date: Fri, 20 Apr 2012 08:36:14 +0200
Message-ID: <1334903774.5922.35.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>, mel@csn.ul.ie, cl@linux-foundation.org
Cc: linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

Hi all,

I've stumbled on the following after some fuzzing using trinity inside a KVM tools guest, using a recent linux-next.

It appears as though it caused a divide by zero in mm/page_alloc.c:5230:

	high = zone->present_pages / percpu_pagelist_fraction;

Here's the relevant disassembly:

    2360:       48 8b 83 30 20 00 00    mov    0x2030(%rbx),%rax
    2367:       31 d2                   xor    %edx,%edx
    2369:       89 c9                   mov    %ecx,%ecx
    236b:       4c 63 05 00 00 00 00    movslq 0x0(%rip),%r8        # 2372 <percpu_pagelist_fraction_sysctl_handler+0x72>
                        236e: R_X86_64_PC32     percpu_pagelist_fraction+0xfffffffffffffffc
    2372:       49 f7 f0                div    %r8

And finally, the dump:

[ 1208.152452] divide error: 0000 [#1] PREEMPT SMP 
[ 1208.154780] CPU 0 
[ 1208.154780] Pid: 25153, comm: trinity Tainted: G        W    3.4.0-rc3-next-20120419-sasha-dirty #86  
[ 1208.154780] RIP: 0010:[<ffffffff81179632>]  [<ffffffff81179632>] percpu_pagelist_fraction_sysctl_handler+0x72/0xf0
[ 1208.154780] RSP: 0018:ffff88003133dd48  EFLAGS: 00010246
[ 1208.154780] RAX: 0000000000000f4a RBX: ffff88000dfcf000 RCX: 0000000000000000
[ 1208.154780] RDX: 0000000000000000 RSI: 0000000000000005 RDI: 0000000000000000
[ 1208.154780] RBP: ffff88003133dd68 R08: 0000000000000000 R09: 0000000000000000
[ 1208.154780] R10: 0000000000000000 R11: 0000000000000001 R12: ffffffff83746760
[ 1208.154780] R13: 0000000000000060 R14: 0000000000000001 R15: 00000000017f7100
[ 1208.154780] FS:  00007f98fb7ff700(0000) GS:ffff88000d800000(0000) knlGS:0000000000000000
[ 1208.154780] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1208.154780] CR2: 0000000000000000 CR3: 0000000031409000 CR4: 00000000000406f0
[ 1208.154780] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 1208.154780] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 1208.154780] Process trinity (pid: 25153, threadinfo ffff88003133c000, task ffff880031320000)
[ 1208.154780] Stack:
[ 1208.154780]  ffff88000d45d388 ffffffff8323c2a0 0000000000000001 ffff88003133df48
[ 1208.154780]  ffff88003133ddc8 ffffffff8124fb9e ffff88003133ddb8 0000000000000000
[ 1208.154780]  ffff88003133ddb8 00000000017f7100 000000000116a08f 0000000000000001
[ 1208.154780] Call Trace:
[ 1208.154780]  [<ffffffff8124fb9e>] proc_sys_call_handler.clone.11+0x8e/0xc0
[ 1208.154780]  [<ffffffff8124fbd0>] ? proc_sys_call_handler.clone.11+0xc0/0xc0
[ 1208.154780]  [<ffffffff8124fbe3>] proc_sys_write+0x13/0x20
[ 1208.154780]  [<ffffffff811dc8db>] do_loop_readv_writev+0x4b/0x90
[ 1208.154780]  [<ffffffff811dcb76>] do_readv_writev+0x106/0x1e0
[ 1208.154780]  [<ffffffff810b5e2a>] ? do_setitimer+0x1aa/0x1f0
[ 1208.154780]  [<ffffffff8269f77b>] ? _raw_spin_unlock_irq+0x2b/0x80
[ 1208.154780]  [<ffffffff810e45c1>] ? get_parent_ip+0x11/0x50
[ 1208.154780]  [<ffffffff810e478e>] ? sub_preempt_count+0xae/0xe0
[ 1208.154780]  [<ffffffff826a0e29>] ? sysret_check+0x22/0x5d
[ 1208.154780]  [<ffffffff811dcce6>] vfs_writev+0x46/0x60
[ 1208.154780]  [<ffffffff811dcdff>] sys_writev+0x4f/0xb0
[ 1208.154780]  [<ffffffff826a0dfd>] system_call_fastpath+0x1a/0x1f
[ 1208.154780] Code: 00 00 0f 1f 80 00 00 00 00 48 83 bb 30 20 00 00 00 74 64 eb 7d 0f 1f 40 00 48 8b 83 30 20 00 00 31 d2 89 c9 4c 63 05 f6 c9 33 03 <49> f7 f0 48 8b 53 60 48 03 14 cd a0 c2 73 83 48 89 c1 89 42 04 
[ 1208.154780] RIP  [<ffffffff81179632>] percpu_pagelist_fraction_sysctl_handler+0x72/0xf0
[ 1208.154780]  RSP <ffff88003133dd48>
[ 1208.315517] ---[ end trace a307b3ed40206b4b ]---
