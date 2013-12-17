Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id CC99F6B0037
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 20:14:47 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id fb1so3707103pad.18
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 17:14:47 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id qz9si10294208pab.307.2013.12.16.17.14.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 16 Dec 2013 17:14:45 -0800 (PST)
Message-ID: <52AFA331.9070108@oracle.com>
Date: Mon, 16 Dec 2013 20:04:49 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: mm: kernel BUG at mm/mlock.c:82!
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Michel Lespinasse <walken@google.com>

Hi all,

While fuzzing with trinity inside a KVM tools guest running latest -next kernel, I've
stumbled on the following spew.

Codewise, it's pretty straightforward. In try_to_unmap_cluster():

                 page = vm_normal_page(vma, address, *pte);
                 BUG_ON(!page || PageAnon(page));

                 if (locked_vma) {
                         mlock_vma_page(page);   /* no-op if already mlocked */
                         if (page == check_page)
                                 ret = SWAP_MLOCK;
                         continue;       /* don't unmap */
                 }

And the BUG triggers once we see that 'page' isn't locked.

I couldn't find anything that recently changed in those codepaths, so I'm a bit lost.

[  253.869145] kernel BUG at mm/mlock.c:82!
[  253.869549] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[  253.870098] Dumping ftrace buffer:
[  253.870098]    (ftrace buffer empty)
[  253.870098] Modules linked in:
[  253.870098] CPU: 10 PID: 9162 Comm: trinity-child75 Tainted: G        W    3.13.0-rc
4-next-20131216-sasha-00011-g5f105ec-dirty #4137
[  253.873310] task: ffff8800c98cb000 ti: ffff8804d34e8000 task.ti: ffff8804d34e8000
[  253.873310] RIP: 0010:[<ffffffff81281f28>]  [<ffffffff81281f28>] mlock_vma_page+0x18
/0xc0
[  253.873310] RSP: 0000:ffff8804d34e99e8  EFLAGS: 00010246
[  253.873310] RAX: 006fffff8038002c RBX: ffffea00474944c0 RCX: ffff880807636000
[  253.873310] RDX: ffffea0000000000 RSI: 00007f17a9bca000 RDI: ffffea00474944c0
[  253.873310] RBP: ffff8804d34e99f8 R08: ffff880807020000 R09: 0000000000000000
[  253.873310] R10: 0000000000000001 R11: 0000000000002000 R12: 00007f17a9bca000
[  253.873310] R13: ffffea00474944c0 R14: 00007f17a9be0000 R15: ffff880807020000
[  253.873310] FS:  00007f17aa31a700(0000) GS:ffff8801c9c00000(0000) knlGS:000000000000
0000
[  253.873310] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  253.873310] CR2: 00007f17a94fa000 CR3: 00000004d3b02000 CR4: 00000000000006e0
[  253.873310] DR0: 00007f17a74ca000 DR1: 0000000000000000 DR2: 0000000000000000
[  253.873310] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
[  253.873310] Stack:
[  253.873310]  0000000b3de28067 ffff880b3de28e50 ffff8804d34e9aa8 ffffffff8128bc31
[  253.873310]  0000000000000301 ffffea0011850220 ffff8809a4039000 ffffea0011850238
[  253.873310]  ffff8804d34e9aa8 ffff880807636060 0000000000000001 ffff880807636348
[  253.873310] Call Trace:
[  253.873310]  [<ffffffff8128bc31>] try_to_unmap_cluster+0x1c1/0x340
[  253.873310]  [<ffffffff8128c60a>] try_to_unmap_file+0x20a/0x2e0
[  253.873310]  [<ffffffff8128c7b3>] try_to_unmap+0x73/0x90
[  253.873310]  [<ffffffff812b526d>] __unmap_and_move+0x18d/0x250
[  253.873310]  [<ffffffff812b53e9>] unmap_and_move+0xb9/0x180
[  253.873310]  [<ffffffff812b559b>] migrate_pages+0xeb/0x2f0
[  253.873310]  [<ffffffff812a0660>] ? queue_pages_pte_range+0x1a0/0x1a0
[  253.873310]  [<ffffffff812a193c>] migrate_to_node+0x9c/0xc0
[  253.873310]  [<ffffffff812a30b8>] do_migrate_pages+0x1b8/0x240
[  253.873310]  [<ffffffff812a3456>] SYSC_migrate_pages+0x316/0x380
[  253.873310]  [<ffffffff812a31ec>] ? SYSC_migrate_pages+0xac/0x380
[  253.873310]  [<ffffffff811763c6>] ? vtime_account_user+0x96/0xb0
[  253.873310]  [<ffffffff812a34ce>] SyS_migrate_pages+0xe/0x10
[  253.873310]  [<ffffffff843c4990>] tracesys+0xdd/0xe2
[  253.873310] Code: 0f 1f 00 65 48 ff 04 25 10 25 1d 00 48 83 c4 08 5b c9 c3 55 48 89 e5 53 48 83 
ec 08 66 66 66 66 90 48 8b 07 48 89 fb a8 01 75 10 <0f> 0b 66 0f 1f 44 00 00 eb fe 66 0f 1f 44 00 00 
f0 0f ba 2f 15
[  253.873310] RIP  [<ffffffff81281f28>] mlock_vma_page+0x18/0xc0
[  253.873310]  RSP <ffff8804d34e99e8>
[  253.904194] ---[ end trace be59c4a7f8edab3f ]---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
