From: Sasha Levin <levinsasha928@gmail.com>
Subject: mm: kernel BUG at mm/memory.c:1230
Date: Thu, 24 May 2012 20:27:34 +0200
Message-ID: <1337884054.3292.22.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: viro <viro@zeniv.linux.org.uk>, oleg@redhat.com, akpm@linux-foundation.org, "a.p.zijlstra" <a.p.zijlstra@chello.nl>, mingo <mingo@kernel.org>
Cc: Dave Jones <davej@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-Id: linux-mm.kvack.org

Hi all,

During fuzzing with trinity inside a KVM tools guest, using latest linux-next, I've stumbled on the following:

[ 2043.098949] ------------[ cut here ]------------
[ 2043.099014] kernel BUG at mm/memory.c:1230!
[ 2043.099014] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[ 2043.111029] CPU 3 
[ 2043.111029] Pid: 26853, comm: trinity Tainted: G        W    3.4.0-next-20120524-sasha-00003-ge89ff01 #281  
[ 2043.111029] RIP: 0010:[<ffffffff811f14d2>]  [<ffffffff811f14d2>] unmap_page_range+0x232/0x3b0
[ 2043.111029] RSP: 0018:ffff880030349ce8  EFLAGS: 00010246
[ 2043.111029] RAX: ffff880000025000 RBX: ffff8800266bc000 RCX: 00003ffffffff000
[ 2043.111029] RDX: ffff880000000000 RSI: ffff88003028cfc0 RDI: 000000006de001e0
[ 2043.111029] RBP: ffff880030349d68 R08: 0000000100001000 R09: 0000000000000000
[ 2043.111029] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000100000000
[ 2043.111029] R13: 0000000100001000 R14: ffff880030349e08 R15: 0000000100000fff
[ 2043.111029] FS:  0000000000000000(0000) GS:ffff880035a00000(0000) knlGS:0000000000000000
[ 2043.111029] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 2043.111029] CR2: 0000000000000ffc CR3: 0000000013480000 CR4: 00000000000406e0
[ 2043.111029] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 2043.111029] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 2043.111029] Process trinity (pid: 26853, threadinfo ffff880030348000, task ffff88002ed68000)
[ 2043.111029] Stack:
[ 2043.111029]  ffffffff811f0b55 0000000100000000 0000000100000fff 0000000100001000
[ 2043.111029]  ffff880013480000 0000000100000fff 0000000000000000 ffff88003028cfc0
[ 2043.111029]  ffff8800142b0020 0000000100001000 ffff880030349d58 ffff88003028cfc0
[ 2043.111029] Call Trace:
[ 2043.111029]  [<ffffffff811f0b55>] ? follow_page+0x315/0x5a0
[ 2043.111029]  [<ffffffff811f1719>] unmap_single_vma+0xc9/0xe0
[ 2043.111029]  [<ffffffff811f1792>] unmap_vmas+0x62/0xa0
[ 2043.111029]  [<ffffffff811f77a9>] exit_mmap+0xc9/0x170
[ 2043.111029]  [<ffffffff81225ae5>] ? __khugepaged_exit+0xd5/0x140
[ 2043.111029]  [<ffffffff810cf719>] mmput+0x89/0xe0
[ 2043.111029]  [<ffffffff810d5f7b>] exit_mm+0x11b/0x130
[ 2043.111029]  [<ffffffff82f71b99>] ? _raw_spin_unlock_irq+0x59/0x80
[ 2043.111029]  [<ffffffff810d8933>] do_exit+0x263/0x510
[ 2043.111029]  [<ffffffff810d8c81>] do_group_exit+0xa1/0xe0
[ 2043.111029]  [<ffffffff810d8cd2>] sys_exit_group+0x12/0x20
[ 2043.111029]  [<ffffffff82f72bf9>] system_call_fastpath+0x16/0x1b
[ 2043.111029] Code: 00 48 89 f8 66 66 66 90 84 c0 0f 89 89 00 00 00 4c 89 c0 4c 29 e0 48 3d 00 00 20 00 74 5b 49 8b 06 48 83 b8 a8 00 00 00 00 75 0e <0f> 0b 0f 1f 40 00 eb fe 66 0f 1f 44 00 00 48 8b 3b 48 83 3d 85 
[ 2043.111029] RIP  [<ffffffff811f14d2>] unmap_page_range+0x232/0x3b0
[ 2043.111029]  RSP <ffff880030349ce8>
