Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f45.google.com (mail-yh0-f45.google.com [209.85.213.45])
	by kanga.kvack.org (Postfix) with ESMTP id C20716B0031
	for <linux-mm@kvack.org>; Wed,  4 Dec 2013 07:07:41 -0500 (EST)
Received: by mail-yh0-f45.google.com with SMTP id v1so10045881yhn.4
        for <linux-mm@kvack.org>; Wed, 04 Dec 2013 04:07:41 -0800 (PST)
Received: from mail-ve0-x22e.google.com (mail-ve0-x22e.google.com [2607:f8b0:400c:c01::22e])
        by mx.google.com with ESMTPS id nm5si16245989qeb.88.2013.12.04.04.07.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 04 Dec 2013 04:07:40 -0800 (PST)
Received: by mail-ve0-f174.google.com with SMTP id pa12so11966067veb.33
        for <linux-mm@kvack.org>; Wed, 04 Dec 2013 04:07:40 -0800 (PST)
MIME-Version: 1.0
Date: Wed, 4 Dec 2013 16:07:40 +0400
Message-ID: <CANaxB-y0A8x3tJn16EByc3Rw8+8WqQXXFhOcqnVsgDncpwaLTw@mail.gmail.com>
Subject: BUG at include/linux/mm.h:1443!
From: Andrey Wagin <avagin@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: linux-mm@kvack.org

Hi Kirill,

I have a test server, which executes CRIU tests. It crashed today. I
don't know how to reproduce this bug. If these information will be not
enough, I will try to get more.

commit 6ce4eac1f600b34f2f7f58f9cd8f0503d79e42ae
Author: Linus Torvalds <torvalds@linux-foundation.org>
Date:   Fri Nov 22 11:30:55 2013 -0800

    Linux 3.13-rc1

[174344.224407] ------------[ cut here ]------------
[174344.225025] kernel BUG at include/linux/mm.h:1443!
[174344.225025] invalid opcode: 0000 [#1] SMP
[174344.225025] Modules linked in: binfmt_misc ip6table_filter
ip6_tables tun netlink_diag af_packet_diag udp_diag tcp_diag inet_diag
unix_diag microcode joydev pcspkr virtio_net virtio_balloon i2c_piix4
i2c_core virtio_blk floppy
[174344.225025] CPU: 1 PID: 9446 Comm: criu Not tainted 3.13.0-rc1+ #147
[174344.225025] Hardware name: Red Hat KVM, BIOS 0.5.1 01/01/2007
[174344.225025] task: ffff880116d20000 ti: ffff88008f266000 task.ti:
ffff88008f266000
[174344.225025] RIP: 0010:[<ffffffff81046f7f>]  [<ffffffff81046f7f>]
___pmd_free_tlb+0x6f/0x80
[174344.225025] RSP: 0018:ffff88008f267c28  EFLAGS: 00010282
[174344.225025] RAX: ffffea0000000000 RBX: ffff88008f267d58 RCX:
0000000000000000
[174344.225025] RDX: ffff880000000000 RSI: ffff88007ad04000 RDI:
ffff88008f267d58
[174344.225025] RBP: ffff88008f267c38 R08: 0000000000000000 R09:
00000000001d7588
[174344.225025] R10: ffff88011ffd5740 R11: 0000000000000018 R12:
ffffea0001eb4100
[174344.225025] R13: 00007f6bbff02000 R14: ffff88007ad04ff8 R15:
00007f6bbff01fff
[174344.225025] FS:  00007f6bd1be0740(0000) GS:ffff88011b400000(0000)
knlGS:0000000000000000
[174344.225025] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[174344.225025] CR2: 0000000000449a00 CR3: 000000008d857000 CR4:
00000000000006e0
[174344.225025] Stack:
[174344.225025]  ffff88008f267d58 00007f6bbff02000 ffff88008f267ce8
ffffffff8119427f
[174344.225025]  00007effffffffff 00007f6bbfffffff 00007f0000000000
00007f6bc0000000
[174344.225025]  00007f6bbff01fff 00007f6bc0000000 00007f6bbff02000
00007f2a5c502000
[174344.225025] Call Trace:
[174344.225025]  [<ffffffff8119427f>] free_pgd_range+0x2bf/0x410
[174344.225025]  [<ffffffff8119449e>] free_pgtables+0xce/0x120
[174344.225025]  [<ffffffff8119b900>] unmap_region+0xe0/0x120
[174344.225025]  [<ffffffff811a0036>] ? move_page_tables+0x526/0x6b0
[174344.225025]  [<ffffffff8119d6a9>] do_munmap+0x249/0x360
[174344.225025]  [<ffffffff811a0304>] move_vma+0x144/0x270
[174344.225025]  [<ffffffff811a07e9>] SyS_mremap+0x3b9/0x510
[174344.225025]  [<ffffffff8172d512>] system_call_fastpath+0x16/0x1b
[174344.225025] Code: 83 7c 24 20 00 75 24 4c 89 e7 e8 bd b7 14 00 4c
89 e6 48 89 df e8 82 b9 14 00 85 c0 75 08 48 89 df e8 36 c9 14 00 5b
41 5c c9 c3 <0f> 0b eb fe 90 90 90 90 90 90 90 90 90 90 90 90 90 55 48
89 e5
[174344.225025] RIP  [<ffffffff81046f7f>] ___pmd_free_tlb+0x6f/0x80
[174344.225025]  RSP <ffff88008f267c28>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
