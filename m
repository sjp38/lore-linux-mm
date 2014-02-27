Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f175.google.com (mail-qc0-f175.google.com [209.85.216.175])
	by kanga.kvack.org (Postfix) with ESMTP id 65F446B0073
	for <linux-mm@kvack.org>; Thu, 27 Feb 2014 08:35:14 -0500 (EST)
Received: by mail-qc0-f175.google.com with SMTP id m20so2486764qcx.6
        for <linux-mm@kvack.org>; Thu, 27 Feb 2014 05:35:14 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id 74si2102018qgf.18.2014.02.27.05.35.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 27 Feb 2014 05:35:13 -0800 (PST)
Message-ID: <530F3F0A.5040304@oracle.com>
Date: Thu, 27 Feb 2014 08:35:06 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: mm: kernel BUG at mm/huge_memory.c:2785!
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Hi all,

While fuzzing with trinity inside a KVM tools guest running latest -next kernel I've stumbled on the 
following spew:

[ 1428.146261] kernel BUG at mm/huge_memory.c:2785!
[ 1428.147100] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[ 1428.148512] Dumping ftrace buffer:
[ 1428.149497]    (ftrace buffer empty)
[ 1428.150248] Modules linked in:
[ 1428.151164] CPU: 106 PID: 29430 Comm: trinity-c106 Tainted: G        W 
3.14.0-rc4-next-20140226-sasha-00013-g082bdac-dirty #4
[ 1428.153515] task: ffff8808906c8000 ti: ffff880890aa6000 task.ti: ffff880890aa6000
[ 1428.154274] RIP: 0010:[<mm/huge_memory.c:2785>]  [<mm/huge_memory.c:2785>] 
__split_huge_page_pmd+0x3f/0x2e0
[ 1428.154274] RSP: 0018:ffff880890aa7c98  EFLAGS: 00010287
[ 1428.154274] RAX: ffff880890f34000 RBX: ffff880b3c6791a0 RCX: 00003ffffffff000
[ 1428.154274] RDX: ffff880b3c6791a0 RSI: 00007f29869b4000 RDI: ffff8803dcbd6400
[ 1428.154274] RBP: ffff880890aa7ce8 R08: 00007f29869b5000 R09: 0000000000000000
[ 1428.154274] R10: 0000000000000000 R11: 0000000000000000 R12: ffff880b3c6791a0
[ 1428.154274] R13: 00007f2986800000 R14: ffff8803dcbd6400 R15: 00007f29869b4fff
[ 1428.154274] FS:  00007f298bb67700(0000) GS:ffff8803de800000(0000) knlGS:0000000000000000
[ 1428.154274] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 1428.154274] CR2: 00007f298b978608 CR3: 00000008907c3000 CR4: 00000000000006e0
[ 1428.154274] DR0: 8200000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 1428.154274] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
[ 1428.154274] Stack:
[ 1428.154274]  00000000001d8400 0000000000000001 ffff880890aa7cc8 ffff880890f34000
[ 1428.154274]  ffffffff876bcfe0 ffff880b3c6791a0 00007f29869b4000 00007f29869b5000
[ 1428.154274]  ffff880890aa7e18 00007f29869b4fff ffff880890aa7d78 ffffffff8127ff06
[ 1428.154274] Call Trace:
[ 1428.154274]  [<mm/memory.c:1230 mm/memory.c:1265 mm/memory.c:1290>] unmap_page_range+0x2a6/0x410
[ 1428.154274]  [<mm/memory.c:1338>] unmap_single_vma+0xf1/0x110
[ 1428.154274]  [<mm/memory.c:1365>] unmap_vmas+0x61/0xa0
[ 1428.154274]  [<mm/mmap.c:2361>] unmap_region+0xbc/0x120
[ 1428.154274]  [<include/linux/mm.h:1315 mm/mmap.c:2332 mm/mmap.c:2557>] do_munmap+0x27a/0x350
[ 1428.154274]  [<mm/mmap.c:2568>] ? vm_munmap+0x41/0x80
[ 1428.154274]  [<mm/mmap.c:2569>] vm_munmap+0x4f/0x80
[ 1428.154274]  [<mm/mmap.c:2574>] SyS_munmap+0x27/0x40
[ 1428.154274]  [<arch/x86/kernel/entry_64.S:749>] tracesys+0xdd/0xe2
[ 1428.154274] Code: e5 00 00 e0 ff 53 49 89 d4 48 83 ec 28 48 8b 47 40 48 89 45 c8 4c 3b 2f 72 11 
49 8d 95 00 00 20 00 48 89 55 c0 48 39 57 08 73 11 <0f> 0b 0f 1f 80 00 00 00 00 eb fe 66 0f 1f 44 00 
00 4c 89 e3 49
[ 1428.154274] RIP  [<mm/huge_memory.c:2785>] __split_huge_page_pmd+0x3f/0x2e0
[ 1428.154274]  RSP <ffff880890aa7c98>


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
