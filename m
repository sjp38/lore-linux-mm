Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 14EC06B00C0
	for <linux-mm@kvack.org>; Tue,  3 Jun 2014 00:21:33 -0400 (EDT)
Received: by mail-wg0-f44.google.com with SMTP id a1so5999971wgh.3
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 21:21:33 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id o12si25751404wiv.36.2014.06.02.21.21.31
        for <linux-mm@kvack.org>;
        Mon, 02 Jun 2014 21:21:32 -0700 (PDT)
Date: Tue, 3 Jun 2014 00:21:21 -0400
From: Dave Jones <davej@redhat.com>
Subject: 3.15-rc8 mm/filemap.c:202 BUG
Message-ID: <20140603042121.GA27177@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>

I'm still seeing this one from time to time, though it takes me quite a while to hit it,
despite my attempts at trying to narrow down the set of syscalls that cause it.

kernel BUG at mm/filemap.c:202!
invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
CPU: 3 PID: 3013 Comm: trinity-c361 Not tainted 3.15.0-rc8+ #225
task: ffff88006c610000 ti: ffff880055960000 task.ti: ffff880055960000
RIP: 0010:[<ffffffffac158e28>]  [<ffffffffac158e28>] __delete_from_page_cache+0x318/0x360
RSP: 0018:ffff880055963b90  EFLAGS: 00010046
RAX: 0000000000000000 RBX: 0000000000000003 RCX: ffff880146f68388
RDX: 000000000000022a RSI: ffffffffaca8db38 RDI: ffffffffaca62b17
RBP: ffff880055963be0 R08: 0000000000000002 R09: ffff88000613d530
R10: ffff880055963ba8 R11: ffff880007f49a40 R12: ffffea0006795880
R13: ffff880143232ad0 R14: 0000000000000000 R15: ffff880143232ad8
FS:  00007f1e40673700(0000) GS:ffff88024d180000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007f1e404e6000 CR3: 00000000603eb000 CR4: 00000000001407e0
DR0: 0000000001bb1000 DR1: 0000000002537000 DR2: 00000000016a5000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600
Stack:
 ffff880143232ae8 0000000000000000 ffff88000613d530 ffff88000613d568
 0000000008828259 ffffea0006795880 ffff880143232ae8 0000000000000000
 0000000000000002 0000000000000002 ffff880055963c08 ffffffffac158eae
Call Trace:
 [<ffffffffac158eae>] delete_from_page_cache+0x3e/0x70
 [<ffffffffac16921b>] truncate_inode_page+0x5b/0x90
 [<ffffffffac174493>] shmem_undo_range+0x363/0x790
 [<ffffffffac1748d4>] shmem_truncate_range+0x14/0x30
 [<ffffffffac174bcf>] shmem_fallocate+0x9f/0x340
 [<ffffffffac324d40>] ? timerqueue_add+0x60/0xb0
 [<ffffffffac1c5ff6>] do_fallocate+0x116/0x1a0
 [<ffffffffac182260>] SyS_madvise+0x3c0/0x870
 [<ffffffffac346b33>] ? __this_cpu_preempt_check+0x13/0x20
 [<ffffffffac74c41f>] tracesys+0xdd/0xe2
Code: ff ff 01 41 f6 c6 01 48 8b 45 c8 75 16 4c 89 30 e9 70 fe ff ff 66 0f 1f 44 00 00 0f 0b 66 0f 1f 44 00 00 0f 0b 66 0f 1f 44 00 00 <0f> 0b 66 0f 1f 44 00 00  41 54 9d e8 78 9e fd ff e9 8c fe ff ff 
RIP  [<ffffffffac158e28>] __delete_from_page_cache+0x318/0x360

There was also another variant of the same BUG with a slighty different stack trace.

kernel BUG at mm/filemap.c:202!
invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
CPU: 2 PID: 6928 Comm: trinity-c45 Not tainted 3.15.0-rc5+ #208 
task: ffff88023669d0a0 ti: ffff880186146000 task.ti: ffff880186146000
RIP: 0010:[<ffffffff8415ba05>]  [<ffffffff8415ba05>] __delete_from_page_cache+0x315/0x320
RSP: 0018:ffff880186147b18  EFLAGS: 00010046
RAX: 0000000000000000 RBX: 0000000000000003 RCX: 0000000000000002
RDX: 000000000000012a RSI: ffffffff84a9a83c RDI: ffffffff84a6e0c0
RBP: ffff880186147b68 R08: 0000000000000002 R09: ffff88002669e668
R10: ffff880186147b30 R11: 0000000000000000 R12: ffffea0008b067c0
R13: ffff880025355670 R14: 0000000000000000 R15: ffff880025355678
FS:  00007fc10026f740(0000) GS:ffff880244400000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00002ab350f5c004 CR3: 000000018566c000 CR4: 00000000001407e0
DR0: 0000000001989000 DR1: 0000000000944000 DR2: 0000000002494000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600
Stack:
 ffff880025355688 ffff8800253556a0 ffff88002669e668 ffff88002669e6a0
 000000008ea099ef ffffea0008b067c0 ffff880025355688 0000000000000000
 0000000000000000 0000000000000002 ffff880186147b90 ffffffff8415ba4d
Call Trace:
 [<ffffffff8415ba4d>] delete_from_page_cache+0x3d/0x70
 [<ffffffff8416b0ab>] truncate_inode_page+0x5b/0x90
 [<ffffffff84175f0b>] shmem_undo_range+0x30b/0x780
 [<ffffffff84176394>] shmem_truncate_range+0x14/0x30
 [<ffffffff8417647d>] shmem_evict_inode+0xcd/0x150
 [<ffffffff841e4b17>] evict+0xa7/0x170
 [<ffffffff841e5435>] iput+0xf5/0x180
 [<ffffffff841df8a0>] dentry_kill+0x260/0x2d0
 [<ffffffff841df97c>] dput+0x6c/0x110
 [<ffffffff841c92a9>] __fput+0x189/0x200
 [<ffffffff841c936e>] ____fput+0xe/0x10
 [<ffffffff84090484>] task_work_run+0xb4/0xe0
 [<ffffffff8406ee42>] do_exit+0x302/0xb80
 [<ffffffff84349e13>] ? __this_cpu_preempt_check+0x13/0x20
 [<ffffffff8407073c>] do_group_exit+0x4c/0xc0
 [<ffffffff840707c4>] SyS_exit_group+0x14/0x20
 [<ffffffff8475bf64>] tracesys+0xdd/0xe2
Code: 4c 89 30 e9 80 fe ff ff 48 8b 75 c0 4c 89 ff e8 82 8f 1c 00 84 c0 0f 85 6c fe ff ff e9 4f fe ff ff 0f 1f 44 00 00 e8 ae 95 5e 00 <0f> 0b e8 04 1c f1 ff 0f 0b 66 90 0f 1f 44 00 00 55 48 89 e5 41 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
