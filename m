Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f43.google.com (mail-oa0-f43.google.com [209.85.219.43])
	by kanga.kvack.org (Postfix) with ESMTP id 097AB6B0062
	for <linux-mm@kvack.org>; Sat,  8 Feb 2014 14:49:27 -0500 (EST)
Received: by mail-oa0-f43.google.com with SMTP id h16so5848029oag.16
        for <linux-mm@kvack.org>; Sat, 08 Feb 2014 11:49:26 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id bx5si4931941oec.39.2014.02.08.11.49.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 08 Feb 2014 11:49:26 -0800 (PST)
Message-ID: <52F6898A.50101@oracle.com>
Date: Sat, 08 Feb 2014 14:46:18 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: shm: hang in shmem_fallocate
References: <52AE7B10.2080201@oracle.com>
In-Reply-To: <52AE7B10.2080201@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 12/15/2013 11:01 PM, Sasha Levin wrote:
> Hi all,
>
> While fuzzing with trinity inside a KVM tools guest running latest -next, I've noticed that
> quite often there's a hang happening inside shmem_fallocate. There are several processes stuck
> trying to acquire inode->i_mutex (for more than 2 minutes), while the process that holds it has
> the following stack trace:

[snip]

This still happens. For the record, here's a better trace:

[  507.124903] CPU: 60 PID: 10864 Comm: trinity-c173 Tainted: G        W 
3.14.0-rc1-next-20140207-sasha-00007-g03959f6-dirty #2
[  507.124903] task: ffff8801f1e38000 ti: ffff8801f1e40000 task.ti: ffff8801f1e40000
[  507.124903] RIP: 0010:[<ffffffff81ae924f>]  [<ffffffff81ae924f>] __delay+0xf/0x20
[  507.124903] RSP: 0000:ffff8801f1e418a8  EFLAGS: 00000202
[  507.124903] RAX: 0000000000000001 RBX: ffff880524cf9f40 RCX: 00000000e9adc2c3
[  507.124903] RDX: 000000000000010f RSI: ffffffff8129813c RDI: 00000000ffffffff
[  507.124903] RBP: ffff8801f1e418a8 R08: 0000000000000000 R09: 0000000000000000
[  507.124903] R10: 0000000000000001 R11: 0000000000000000 R12: 00000000000affe0
[  507.124903] R13: 0000000086c42710 R14: ffff8801f1e41998 R15: ffff8801f1e41ac8
[  507.124903] FS:  00007ff708073700(0000) GS:ffff88052b400000(0000) knlGS:0000000000000000
[  507.124903] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  507.124903] CR2: 000000000089d010 CR3: 00000001f1e2c000 CR4: 00000000000006e0
[  507.124903] DR0: 0000000000696000 DR1: 0000000000000000 DR2: 0000000000000000
[  507.124903] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
[  507.124903] Stack:
[  507.124903]  ffff8801f1e418d8 ffffffff811af053 ffff880524cf9f40 ffff880524cf9f40
[  507.124903]  ffff880524cf9f58 ffff8807275b1000 ffff8801f1e41908 ffffffff84447580
[  507.124903]  ffffffff8129813c ffffffff811ea882 00003ffffffff000 00007ff705eb2000
[  507.124903] Call Trace:
[  507.124903]  [<ffffffff811af053>] do_raw_spin_lock+0xe3/0x170
[  507.124903]  [<ffffffff84447580>] _raw_spin_lock+0x60/0x80
[  507.124903]  [<ffffffff8129813c>] ? zap_pte_range+0xec/0x580
[  507.124903]  [<ffffffff811ea882>] ? smp_call_function_single+0x242/0x270
[  507.124903]  [<ffffffff8129813c>] zap_pte_range+0xec/0x580
[  507.124903]  [<ffffffff810ca710>] ? flush_tlb_mm_range+0x280/0x280
[  507.124903]  [<ffffffff81adbd67>] ? cpumask_next_and+0xa7/0xd0
[  507.124903]  [<ffffffff810ca710>] ? flush_tlb_mm_range+0x280/0x280
[  507.124903]  [<ffffffff812989ce>] unmap_page_range+0x3fe/0x410
[  507.124903]  [<ffffffff81298ae1>] unmap_single_vma+0x101/0x120
[  507.124903]  [<ffffffff81298cb9>] zap_page_range_single+0x119/0x160
[  507.124903]  [<ffffffff811a87b8>] ? trace_hardirqs_on+0x8/0x10
[  507.124903]  [<ffffffff812ddb8a>] ? memcg_check_events+0x7a/0x170
[  507.124903]  [<ffffffff81298d73>] ? unmap_mapping_range+0x73/0x180
[  507.124903]  [<ffffffff81298dfe>] unmap_mapping_range+0xfe/0x180
[  507.124903]  [<ffffffff812790c7>] truncate_inode_page+0x37/0x90
[  507.124903]  [<ffffffff812861aa>] shmem_undo_range+0x6aa/0x770
[  507.124903]  [<ffffffff81298e68>] ? unmap_mapping_range+0x168/0x180
[  507.124903]  [<ffffffff81286288>] shmem_truncate_range+0x18/0x40
[  507.124903]  [<ffffffff81286599>] shmem_fallocate+0x99/0x2f0
[  507.124903]  [<ffffffff8129487e>] ? madvise_vma+0xde/0x1c0
[  507.124903]  [<ffffffff811aa5d2>] ? __lock_release+0x1e2/0x200
[  507.124903]  [<ffffffff812ee006>] do_fallocate+0x126/0x170
[  507.124903]  [<ffffffff81294894>] madvise_vma+0xf4/0x1c0
[  507.124903]  [<ffffffff81294ae8>] SyS_madvise+0x188/0x250
[  507.124903]  [<ffffffff84452450>] tracesys+0xdd/0xe2
[  507.124903] Code: 66 66 66 66 90 48 c7 05 a4 66 04 05 e0 92 ae 81 c9 c3 66 2e 0f 1f 84 00 00 00 
00 00 55 48 89 e5 66 66 66 66 90 ff 15 89 66 04 05 <c9> c3 66 66 66 66 66 66 2e 0f 1f 84 00 00 00 00 
00 55 48 8d 04

I'm still trying to figure it out. To me it seems like a series of calls to shmem_truncate_range() 
takes so long that one of the tasks triggers a hung task. We don't actually hang in any specific
shmem_truncate_range() for too long though.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
