Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 514386B0009
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 07:52:52 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id l65so102731044wmf.1
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 04:52:52 -0800 (PST)
Received: from mail-wm0-x22d.google.com (mail-wm0-x22d.google.com. [2a00:1450:400c:c09::22d])
        by mx.google.com with ESMTPS id q135si5301112wmg.88.2016.01.26.04.52.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jan 2016 04:52:51 -0800 (PST)
Received: by mail-wm0-x22d.google.com with SMTP id 123so104587568wmz.0
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 04:52:51 -0800 (PST)
MIME-Version: 1.0
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 26 Jan 2016 13:52:31 +0100
Message-ID: <CACT4Y+YK7or=W4RGpv1k1T5-xDHu3_PPVZWqsQU6nWoArsV5vA@mail.gmail.com>
Subject: mm: VM_BUG_ON_PAGE(PageTail(page)) in mbind
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Shiraz Hashim <shashim@codeaurora.org>, David Rientjes <rientjes@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Sasha Levin <sasha.levin@oracle.com>
Cc: syzkaller <syzkaller@googlegroups.com>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>

Hello,

The following program triggers the following bug:

page:ffffea0000b82240 count:0 mapcount:1 mapping:dead0000ffffffff
index:0x0 compound_mapcount: 0
flags: 0x1fffc0000000000()
page dumped because: VM_BUG_ON_PAGE(PageTail(page))
------------[ cut here ]------------
kernel BUG at mm/vmscan.c:1446!
invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC KASAN
Modules linked in:
CPU: 1 PID: 6868 Comm: a.out Not tainted 4.5.0-rc1+ #287
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
task: ffff88003e24af80 ti: ffff88002e808000 task.ti: ffff88002e808000
RIP: 0010:[<ffffffff816a4b7a>]  [<ffffffff816a4b7a>]
isolate_lru_page+0x4ea/0x6d0
RSP: 0018:ffff88002e80fa50  EFLAGS: 00010282
RAX: ffff88003e24af80 RBX: ffffea0000b82240 RCX: 0000000000000000
RDX: 0000000000000000 RSI: 0000000000000001 RDI: ffffea0000b82278
RBP: ffff88002e80fa88 R08: 0000000000000001 R09: 0000000000000000
R10: ffff88003e24af80 R11: 0000000000000001 R12: ffffea0000b82260
R13: ffffea0000b82200 R14: ffffea0000b82201 R15: 0000000020004000
FS:  0000000000c1f880(0063) GS:ffff88003ed00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000020005ff8 CR3: 000000002e324000 CR4: 00000000000006e0
Stack:
 dffffc0000000000 ffffffff816f5e89 ffff88003124b010 0000000020002000
 dffffc0000000000 ffffea0000b82240 0000000020004000 ffff88002e80fb10
 ffffffff817612bd ffffea0000000001 ffff88002e80fc70 ffff88002e80fde8
Call Trace:
 [<     inline     >] migrate_page_add mm/mempolicy.c:966
 [<ffffffff817612bd>] queue_pages_pte_range+0x4ad/0x10b0 mm/mempolicy.c:552
 [<     inline     >] walk_pmd_range mm/pagewalk.c:50
 [<     inline     >] walk_pud_range mm/pagewalk.c:90
 [<     inline     >] walk_pgd_range mm/pagewalk.c:116
 [<ffffffff81732713>] __walk_page_range+0x653/0xcd0 mm/pagewalk.c:204
 [<ffffffff81732ec4>] walk_page_range+0x134/0x300 mm/pagewalk.c:281
 [<ffffffff8175f07b>] queue_pages_range+0xfb/0x130 mm/mempolicy.c:687
 [<ffffffff817678c1>] do_mbind+0x2c1/0xdc0 mm/mempolicy.c:1239
 [<     inline     >] SYSC_mbind mm/mempolicy.c:1351
 [<ffffffff8176871d>] SyS_mbind+0x13d/0x150 mm/mempolicy.c:1333
 [<ffffffff8646ed76>] entry_SYSCALL_64_fastpath+0x16/0x7a
arch/x86/entry/entry_64.S:185
Code: 89 df e8 aa 64 04 00 0f 0b e8 63 6d ed ff 4d 8d 6e ff e9 73 fb
ff ff e8 55 6d ed ff 48 c7 c6 60 7b 5b 86 48 89 df e8 86 64 04 00 <0f>
0b e8 3f 6d ed ff 4d 8d 6e ff e9 eb fb ff ff c7 45 d0 f0 ff
RIP  [<ffffffff816a4b7a>] isolate_lru_page+0x4ea/0x6d0 mm/vmscan.c:1446
 RSP <ffff88002e80fa50>
---[ end trace 310d844ac0b69c5b ]---
BUG: sleeping function called from invalid context at include/linux/sched.h:2805
in_atomic(): 1, irqs_disabled(): 0, pid: 6868, name: a.out
INFO: lockdep is turned off.
CPU: 1 PID: 6868 Comm: a.out Tainted: G      D         4.5.0-rc1+ #287
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
 00000000ffffffff ffff88002e80f548 ffffffff829f9d0d ffff88003e24af80
 0000000000001ad4 0000000000000000 ffff88002e80f570 ffffffff813cba2b
 ffff88003e24af80 ffffffff865527a0 0000000000000af5 ffff88002e80f5b0
Call Trace:
 [<     inline     >] __dump_stack lib/dump_stack.c:15
 [<ffffffff829f9d0d>] dump_stack+0x6f/0xa2 lib/dump_stack.c:50
 [<ffffffff813cba2b>] ___might_sleep+0x27b/0x3a0 kernel/sched/core.c:7703
 [<ffffffff813cbbe0>] __might_sleep+0x90/0x1a0 kernel/sched/core.c:7665
 [<     inline     >] threadgroup_change_begin include/linux/sched.h:2805
 [<ffffffff81383221>] exit_signals+0x81/0x430 kernel/signal.c:2392
 [<ffffffff8135c55c>] do_exit+0x23c/0x2cb0 kernel/exit.c:701
 [<ffffffff811aa28f>] oops_end+0x9f/0xd0 arch/x86/kernel/dumpstack.c:250
 [<ffffffff811aa686>] die+0x46/0x60 arch/x86/kernel/dumpstack.c:316
 [<     inline     >] do_trap_no_signal arch/x86/kernel/traps.c:205
 [<ffffffff811a3b9f>] do_trap+0x18f/0x380 arch/x86/kernel/traps.c:251
 [<ffffffff811a400e>] do_error_trap+0x11e/0x280 arch/x86/kernel/traps.c:290
 [<ffffffff811a527b>] do_invalid_op+0x1b/0x20 arch/x86/kernel/traps.c:303
 [<ffffffff86470a8e>] invalid_op+0x1e/0x30 arch/x86/entry/entry_64.S:830
 [<     inline     >] migrate_page_add mm/mempolicy.c:966
 [<ffffffff817612bd>] queue_pages_pte_range+0x4ad/0x10b0 mm/mempolicy.c:552
 [<     inline     >] walk_pmd_range mm/pagewalk.c:50
 [<     inline     >] walk_pud_range mm/pagewalk.c:90
 [<     inline     >] walk_pgd_range mm/pagewalk.c:116
 [<ffffffff81732713>] __walk_page_range+0x653/0xcd0 mm/pagewalk.c:204
 [<ffffffff81732ec4>] walk_page_range+0x134/0x300 mm/pagewalk.c:281
 [<ffffffff8175f07b>] queue_pages_range+0xfb/0x130 mm/mempolicy.c:687
 [<ffffffff817678c1>] do_mbind+0x2c1/0xdc0 mm/mempolicy.c:1239
 [<     inline     >] SYSC_mbind mm/mempolicy.c:1351
 [<ffffffff8176871d>] SyS_mbind+0x13d/0x150 mm/mempolicy.c:1333
 [<ffffffff8646ed76>] entry_SYSCALL_64_fastpath+0x16/0x7a
arch/x86/entry/entry_64.S:185
note: a.out[6868] exited with preempt_count 1


// autogenerated by syzkaller (http://github.com/google/syzkaller)
#include <pthread.h>
#include <stdint.h>
#include <string.h>
#include <sys/syscall.h>
#include <unistd.h>
#include <fcntl.h>

#ifndef SYS_mlock2
#define SYS_mlock2 325
#endif

int main()
{
  long r[8];
  memset(r, -1, sizeof(r));
  r[0] = syscall(SYS_mmap, 0x20000000ul, 0x1000ul, 0x3ul, 0x32ul,
                 0xfffffffffffffffful, 0x0ul);
  memcpy((void*)0x20000f33, "\x2f\x64\x65\x76\x2f\x73\x67\x23", 8);
  r[2] = syscall(SYS_open, "/dev/sg0",O_RDWR);
  r[3] = syscall(SYS_mmap, 0x20001000ul, 0x4000ul, 0x4ul, 0x12ul, r[2],
                 0x0ul);
  r[4] = syscall(SYS_mlock2, 0x20001000ul, 0x3000ul, 0x1ul, 0, 0, 0);
  r[5] = syscall(SYS_mmap, 0x20005000ul, 0x1000ul, 0x3ul, 0x32ul,
                 0xfffffffffffffffful, 0x0ul);
  *(uint64_t*)0x20005ff8 = (uint64_t)0x80000000;
  r[7] = syscall(SYS_mbind, 0x20000000ul, 0x4000ul, 0x8000ul,
                 0x20005ff8ul, 0x5ul, 0x2ul);
  return 0;
}


On commit 92e963f50fc74041b5e9e744c330dca48e04f08d.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
