Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f177.google.com (mail-ie0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id 1CD456B0035
	for <linux-mm@kvack.org>; Wed, 22 Jan 2014 20:08:07 -0500 (EST)
Received: by mail-ie0-f177.google.com with SMTP id at1so405875iec.22
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 17:08:06 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id kc2si17021860igb.41.2014.01.22.17.08.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 22 Jan 2014 17:08:05 -0800 (PST)
Message-ID: <52E06B6F.90808@oracle.com>
Date: Wed, 22 Jan 2014 20:07:59 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: mm: BUG: Bad rss-counter state
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: khlebnikov@openvz.org, Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hi all,

While fuzzing with trinity running inside a KVM tools guest using latest -next kernel,
I've stumbled on a "mm: BUG: Bad rss-counter state" error which was pretty non-obvious
in the mix of the kernel spew (why?).

I've added a small BUG() after the printk() in check_mm(), and here's the full output:

[  318.334905] BUG: Bad rss-counter state mm:ffff8801e6dec000 idx:0 val:1
[  318.335955] ------------[ cut here ]------------
[  318.336507] kernel BUG at kernel/fork.c:562!
[  318.336930] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[  318.337826] Dumping ftrace buffer:
[  318.338431]    (ftrace buffer empty)
[  318.338951] Modules linked in:
[  318.339287] CPU: 45 PID: 10022 Comm: trinity-c190 Tainted: G        W    3.13.0-next
-20140122-sasha-00011-gcc8342a-dirty #4
[  318.340120] task: ffff8801e6a9b000 ti: ffff8801e6aee000 task.ti: ffff8801e6aee000
[  318.340120] RIP: 0010:[<ffffffff8113ca4a>]  [<ffffffff8113ca4a>] __mmdrop+0x9a/0xc0
[  318.340120] RSP: 0000:ffff8801e6aefe68  EFLAGS: 00010292
[  318.340120] RAX: 000000000000003a RBX: ffff8801e6dec000 RCX: 0000000000000001
[  318.340120] RDX: 0000000000000000 RSI: 0000000000000001 RDI: 0000000000000286
[  318.340120] RBP: ffff8801e6aefe78 R08: 0000000000000001 R09: 0000000000000000
[  318.340120] R10: 0000000000000001 R11: 0000000000000001 R12: ffff8801e6dec138
[  318.340120] R13: ffff8801e6dec000 R14: ffff8801e6dec0a8 R15: 00000000000000a3
[  318.340120] FS:  00007f6bc5915700(0000) GS:ffff88007b400000(0000) knlGS:000000000000
0000
[  318.340120] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  318.340120] CR2: 00007fffd3d62588 CR3: 0000000005e26000 CR4: 00000000000006e0
[  318.340120] Stack:
[  318.340120]  ffff8801e6dec138 ffff8801e6dec000 ffff8801e6aefe98 ffffffff8113cb3b
[  318.340120]  ffff8801e6a9bbb0 ffff8801e6a9b000 ffff8801e6aefef8 ffffffff81140ced
[  318.340120]  ffff8801e6c4db00 ffff8801e6c4db00 ffff8801e6aefef8 ffffffff811f3ea5
[  318.340120] Call Trace:
[  318.340120]  [<ffffffff8113cb3b>] mmput+0xcb/0xe0
[  318.340120]  [<ffffffff81140ced>] exit_mm+0x18d/0x1a0
[  318.340120]  [<ffffffff811f3ea5>] ? acct_collect+0x175/0x1b0
[  318.340120]  [<ffffffff8114315f>] do_exit+0x26f/0x520
[  318.355754]  [<ffffffff811434b9>] do_group_exit+0xa9/0xe0
[  318.355754]  [<ffffffff81143507>] SyS_exit_group+0x17/0x20
[  318.355754]  [<ffffffff8444b7d0>] tracesys+0xdd/0xe2
[  318.355754] Code: 00 00 eb 16 0f 1f 44 00 00 48 8b 8b 68 03 00 00 48 85 c9 74 24 ba 02 00 00 00 
48 89 de 48 c7 c7 10 16 68 85 31 c0 e8 a2 d2 2f 03 <0f> 0b 0f 1f 40 00 eb fe 66 0f 1f 44 00 00 48 89 
de 48 8b 3d 1e
[  318.355754] RIP  [<ffffffff8113ca4a>] __mmdrop+0x9a/0xc0
[  318.355754]  RSP <ffff8801e6aefe68>
[  318.363991] ---[ end trace 7d85aceb881be62b ]---


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
