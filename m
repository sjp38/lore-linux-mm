Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 6F50F6B0256
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 08:50:48 -0500 (EST)
Received: by wmuu63 with SMTP id u63so97264287wmu.0
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 05:50:48 -0800 (PST)
Received: from mail-wm0-x233.google.com (mail-wm0-x233.google.com. [2a00:1450:400c:c09::233])
        by mx.google.com with ESMTPS id 6si26913600wjx.175.2015.11.24.05.50.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Nov 2015 05:50:47 -0800 (PST)
Received: by wmww144 with SMTP id w144so27256828wmw.0
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 05:50:47 -0800 (PST)
MIME-Version: 1.0
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 24 Nov 2015 14:50:26 +0100
Message-ID: <CACT4Y+ZCkv0BPOdo3aiheA5LXzXhcnuiw7kCoWL=b9FcC8-wqg@mail.gmail.com>
Subject: WARNING in handle_mm_fault
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, cgroups@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: syzkaller <syzkaller@googlegroups.com>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>, Sasha Levin <sasha.levin@oracle.com>, Eric Dumazet <edumazet@google.com>, Greg Thelen <gthelen@google.com>

Hello,

I am hitting the following WARNING on commit
8005c49d9aea74d382f474ce11afbbc7d7130bec (Nov 15):


------------[ cut here ]------------
WARNING: CPU: 3 PID: 12661 at include/linux/memcontrol.h:412
handle_mm_fault+0x17ec/0x3530()
Modules linked in:
CPU: 3 PID: 12661 Comm: executor Tainted: G    B   W       4.4.0-rc1+ #81
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
 00000000ffffffff ffff88003725fc80 ffffffff825d3336 0000000000000000
 ffff880061d95900 ffffffff84cfb6c0 ffff88003725fcc0 ffffffff81247889
 ffffffff815b68fc ffffffff84cfb6c0 000000000000019c 0000000002f68038
Call Trace:
 [<ffffffff81247ab9>] warn_slowpath_null+0x29/0x30 kernel/panic.c:411
 [<ffffffff815b68fc>] handle_mm_fault+0x17ec/0x3530 mm/memory.c:3440
 [<     inline     >] access_error arch/x86/mm/fault.c:1020
 [<ffffffff81220951>] __do_page_fault+0x361/0x8b0 arch/x86/mm/fault.c:1227
 [<     inline     >] trace_page_fault_kernel
./arch/x86/include/asm/trace/exceptions.h:44
 [<     inline     >] trace_page_fault_entries arch/x86/mm/fault.c:1314
 [<ffffffff81220f5a>] trace_do_page_fault+0x8a/0x230 arch/x86/mm/fault.c:1330
 [<ffffffff81213f14>] do_async_page_fault+0x14/0x70
 [<ffffffff84bf2b98>] async_page_fault+0x28/0x30
---[ end trace 179dec89fcb66e7f ]---


Reproduction instructions are somewhat involved. I can provide
detailed instructions if necessary. But maybe we can debug it without
the reproducer. Just in case I've left some traces here:
https://gist.githubusercontent.com/dvyukov/451019c8fb14aa4565a4/raw/4f6d55c19fbec74c5923a1aa62acf1db81fe4e98/gistfile1.txt


As a blind guess, I've added the following BUG into copy_process:

diff --git a/kernel/fork.c b/kernel/fork.c
index b4dc490..c5667e8 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1620,6 +1620,8 @@ static struct task_struct *copy_process(unsigned
long clone_flags,
        trace_task_newtask(p, clone_flags);
        uprobe_copy_process(p, clone_flags);

+       BUG_ON(p->memcg_may_oom);
+
        return p;


And it fired:

------------[ cut here ]------------
kernel BUG at kernel/fork.c:1623!
invalid opcode: 0000 [#1] SMP KASAN
Modules linked in:
CPU: 3 PID: 28384 Comm: executor Not tainted 4.4.0-rc1+ #83
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
task: ffff880034c542c0 ti: ffff880033140000 task.ti: ffff880033140000
RIP: 0010:[<ffffffff81242df3>]  [<ffffffff81242df3>] copy_process+0x32e3/0x5bf0
RSP: 0018:ffff880033147c28  EFLAGS: 00010246
RAX: ffff880034c542c0 RBX: ffff880033148000 RCX: 0000000000000001
RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffff880060ca9a14
RBP: ffff880033147e08 R08: ffff880060ca9808 R09: 0000000000000001
R10: 0000000000000000 R11: 0000000000000001 R12: ffff88006269b148
R13: 00000000003d0f00 R14: 1ffff10006628fa8 R15: ffff880060ca9640
FS:  0000000002017880(0063) GS:ffff88006dd00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007fc73b14ae78 CR3: 000000000089a000 CR4: 00000000000006e0
Stack:
 ffffea00017e1780 1ffff10006628f8b ffff880033147c48 ffffffff81338b22
 ffff880034c54a58 ffffffff816509d0 0000000000000246 ffffffff00000001
 ffff880060ca99b8 00007fc73b14ae78 ffffea00017e1780 00000002624ab4d0
Call Trace:
 [<ffffffff81245afd>] _do_fork+0x14d/0xb40 kernel/fork.c:1729
 [<     inline     >] SYSC_clone kernel/fork.c:1838
 [<ffffffff812465c7>] SyS_clone+0x37/0x50 kernel/fork.c:1832
 [<ffffffff84bf0c76>] entry_SYSCALL_64_fastpath+0x16/0x7a
arch/x86/entry/entry_64.S:185
Code: 03 0f b6 04 02 48 89 fa 83 e2 07 38 d0 7f 09 84 c0 74 05 e8 c0
e4 3d 00 41 f6 87 d4 03 00 00 20 0f 84 d7 ce ff ff e8 ed 70 21 00 <0f>
0b e8 e6 70 21 00 48 8b 1d 8f 39 cf 04 49 bc 00 00 00 00 00
RIP  [<ffffffff81242df3>] copy_process+0x32e3/0x5bf0
kernel/fork.c:1623 (discriminator 1)
 RSP <ffff880033147c28>
---[ end trace 6b4b09a815461606 ]---


So it seems that copy_process creates tasks with memcg_may_oom flag
set, which looks wrong. Can it be the root cause?


Thank you

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
