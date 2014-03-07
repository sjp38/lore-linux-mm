Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f46.google.com (mail-oa0-f46.google.com [209.85.219.46])
	by kanga.kvack.org (Postfix) with ESMTP id 42D9A6B0031
	for <linux-mm@kvack.org>; Fri,  7 Mar 2014 10:06:16 -0500 (EST)
Received: by mail-oa0-f46.google.com with SMTP id i7so4270929oag.19
        for <linux-mm@kvack.org>; Fri, 07 Mar 2014 07:06:16 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id tm2si6853885oeb.94.2014.03.07.07.06.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 07 Mar 2014 07:06:15 -0800 (PST)
Message-ID: <5319DF72.6090408@oracle.com>
Date: Fri, 07 Mar 2014 10:02:10 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: mm: kernel BUG at mm/filemap.c:202
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>

Hi all,

While fuzzing with trinity inside a KVM tools guest running latest -next kernel I've stumbled on
the following spew:

[  567.833881] kernel BUG at mm/filemap.c:202!
[  567.834485] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[  567.835522] Dumping ftrace buffer:
[  567.836752]    (ftrace buffer empty)
[  567.837307] Modules linked in:
[  567.837796] CPU: 23 PID: 14457 Comm: trinity-c323 Tainted: G        W    3.14.0-rc5-next-20140307-sasha-00010-gb6b571d-dirty #111
[  567.839449] task: ffff88021afa8000 ti: ffff88071f290000 task.ti: ffff88071f290000
[  567.840489] RIP: 0010:[<ffffffff8126b3f0>]  [<ffffffff8126b3f0>] __delete_from_page_cache+0x150/0x270
[  567.841649] RSP: 0018:ffff88071f291b78  EFLAGS: 00010046
[  567.841649] RAX: 0000000000000000 RBX: ffffea0002c4ac40 RCX: 00000000ffffffb8
[  567.841649] RDX: 00000000001dc1a8 RSI: 0000000000000018 RDI: ffff88012ffd2000
[  567.841649] RBP: ffff88071f291b98 R08: 0000000000000048 R09: 00000000ffffffff
[  567.841649] R10: 0000000000000001 R11: 0000000000000001 R12: ffff880627f2bd30
[  567.841649] R13: ffff880627f2bd18 R14: 0000000000000000 R15: 0000000000000000
[  567.841649] FS:  00007f15b504d700(0000) GS:ffff88082ba00000(0000) knlGS:0000000000000000
[  567.841649] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  567.841649] CR2: 0000000002eef848 CR3: 000000071fce7000 CR4: 00000000000006a0
[  567.841649] DR0: 0000000000900870 DR1: 00007f15b505a000 DR2: 0000000000000000
[  567.841649] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000602
[  567.841649] Stack:
[  567.841649]  ffffea0002c4ac40 ffff880627f2bd30 0000000000000000
[  567.859673]  0000000000000200
[  567.859673]  ffff88071f291bc8 ffffffff8126b56a ffff880627f2bd18 ffffea0002c4ac40
[  567.859673]  ffff880627f2bd18 ffff88071f291c48 ffff88071f291be8 ffffffff8127fb94
[  567.859673] Call Trace:
[  567.859673]  [<ffffffff8126b56a>] delete_from_page_cache+0x5a/0x90
[  567.859673]  [<ffffffff8127fb94>] truncate_inode_page+0x74/0x90
[  567.859673]  [<ffffffff8128c875>] shmem_undo_range+0x245/0x770
[  567.859673]  [<ffffffff812a01b8>] ? unmap_mapping_range+0x168/0x180
[  567.859673]  [<ffffffff8128cdb8>] shmem_truncate_range+0x18/0x40
[  567.859673]  [<ffffffff8128d0c9>] shmem_fallocate+0x99/0x2f0
[  567.859673]  [<ffffffff8129b7be>] ? madvise_vma+0xde/0x1c0
[  567.859673]  [<ffffffff811ad632>] ? __lock_release+0x1e2/0x200
[  567.859673]  [<ffffffff812f87da>] do_fallocate+0x14a/0x1a0
[  567.859673]  [<ffffffff8129b7d4>] madvise_vma+0xf4/0x1c0
[  567.859673]  [<ffffffff812a765f>] ? find_vma+0x6f/0x90
[  567.859673]  [<ffffffff8129ba28>] SyS_madvise+0x188/0x250
[  567.859673]  [<ffffffff844b1650>] tracesys+0xdd/0xe2
[  567.859673] Code: be 0a 00 00 00 48 89 df e8 8e 55 02 00 48 8b 03 a9 00 00 08 00 74 0d be 18 00 00 00 48 89 df e8 77 55 02 00 8b 43 18 85 c0 78 10 <0f> 0b 66 0f 1f 44 00 00 eb fe 66 0f 1f 44 00 00 48 8b 03 a8 10
[  567.859673] RIP  [<ffffffff8126b3f0>] __delete_from_page_cache+0x150/0x270
[  567.859673]  RSP <ffff88071f291b78>


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
