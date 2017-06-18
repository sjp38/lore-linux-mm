Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8EA3D6B0343
	for <linux-mm@kvack.org>; Sun, 18 Jun 2017 17:30:26 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id m19so65454915ioe.12
        for <linux-mm@kvack.org>; Sun, 18 Jun 2017 14:30:26 -0700 (PDT)
Received: from omzsmtpe02.verizonbusiness.com (omzsmtpe02.verizonbusiness.com. [199.249.25.209])
        by mx.google.com with ESMTPS id s9si4799180itd.138.2017.06.18.14.30.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 Jun 2017 14:30:25 -0700 (PDT)
From: "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>
Subject: Re: [PATCH v2 00/10] PCID and improved laziness
Date: Sun, 18 Jun 2017 21:29:51 +0000
Message-ID: <20170618212948.mt33zbajt5n6saed@sasha-lappy>
References: <cover.1497415951.git.luto@kernel.org>
In-Reply-To: <cover.1497415951.git.luto@kernel.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <E566AEB7FF1E334596C9AC04BDB1FFF9@vzwcorp.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: "x86@kernel.org" <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bp@alien8.de>, Linus
 Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan
 van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

On Tue, Jun 13, 2017 at 09:56:18PM -0700, Andy Lutomirski wrote:
>There are three performance benefits here:
>
>1. TLB flushing is slow.  (I.e. the flush itself takes a while.)
>   This avoids many of them when switching tasks by using PCID.  In
>   a stupid little benchmark I did, it saves about 100ns on my laptop
>   per context switch.  I'll try to improve that benchmark.
>
>2. Mms that have been used recently on a given CPU might get to keep
>   their TLB entries alive across process switches with this patch
>   set.  TLB fills are pretty fast on modern CPUs, but they're even
>   faster when they don't happen.
>
>3. Lazy TLB is way better.  We used to do two stupid things when we
>   ran kernel threads: we'd send IPIs to flush user contexts on their
>   CPUs and then we'd write to CR3 for no particular reason as an excuse
>   to stop further IPIs.  With this patch, we do neither.
>
>This will, in general, perform suboptimally if paravirt TLB flushing
>is in use (currently just Xen, I think, but Hyper-V is in the works).
>The code is structured so we could fix it in one of two ways: we
>could take a spinlock when touching the percpu state so we can update
>it remotely after a paravirt flush, or we could be more careful about
>our exactly how we access the state and use cmpxchg16b to do atomic
>remote updates.  (On SMP systems without cmpxchg16b, we'd just skip
>the optimization entirely.)

Hey Andy,

I've started seeing the following in -next:

------------[ cut here ]------------
kernel BUG at arch/x86/mm/tlb.c:47!
invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC KASAN
Dumping ftrace buffer:
   (ftrace buffer empty)
Modules linked in:
CPU: 0 PID: 5302 Comm: kworker/u9:1 Not tainted 4.12.0-rc5+ #142
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.1-1ubuntu1=
 04/01/2014
Workqueue: writeback wb_workfn (flush-259:0)
task: ffff880030ad0040 task.stack: ffff880036e78000
RIP: 0010:leave_mm+0x33/0x40 arch/x86/mm/tlb.c:50
RSP: 0018:ffff880036e7d4c8 EFLAGS: 00010246
RAX: 0000000000000001 RBX: ffff88006a65e240 RCX: dffffc0000000000
RDX: 0000000000000000 RSI: ffffffffb1475fa0 RDI: 0000000000000000
RBP: ffff880036e7d638 R08: 1ffff10006dcfad1 R09: ffff880030ad0040
R10: ffff880036e7d3b8 R11: 0000000000000000 R12: 1ffff10006dcfa9e
R13: ffff880036e7d6c0 R14: ffff880036e7d680 R15: 0000000000000000
FS:  0000000000000000(0000) GS:ffff88003ea00000(0000) knlGS:000000000000000=
0
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 000000c420019318 CR3: 0000000047a28000 CR4: 00000000000406f0
Call Trace:
 flush_tlb_func_local arch/x86/mm/tlb.c:239 [inline]
 flush_tlb_mm_range+0x26d/0x370 arch/x86/mm/tlb.c:317
 flush_tlb_page arch/x86/include/asm/tlbflush.h:253 [inline]
 ptep_clear_flush+0xd5/0x110 mm/pgtable-generic.c:86
 page_mkclean_one+0x242/0x540 mm/rmap.c:867
 rmap_walk_file+0x5e3/0xd20 mm/rmap.c:1681
 rmap_walk+0x1cd/0x2f0 mm/rmap.c:1699
 page_mkclean+0x2a0/0x380 mm/rmap.c:928
 clear_page_dirty_for_io+0x37e/0x9d0 mm/page-writeback.c:2703
 mpage_submit_page+0x77/0x230 fs/ext4/inode.c:2131
 mpage_process_page_bufs+0x427/0x500 fs/ext4/inode.c:2261
 mpage_prepare_extent_to_map+0x78d/0xcf0 fs/ext4/inode.c:2638
 ext4_writepages+0x13be/0x3dd0 fs/ext4/inode.c:2784
 do_writepages+0xff/0x170 mm/page-writeback.c:2357
 __writeback_single_inode+0x1d9/0x1480 fs/fs-writeback.c:1319
 writeback_sb_inodes+0x6e2/0x1260 fs/fs-writeback.c:1583
 wb_writeback+0x45d/0xed0 fs/fs-writeback.c:1759
 wb_do_writeback fs/fs-writeback.c:1891 [inline]
 wb_workfn+0x2b5/0x1460 fs/fs-writeback.c:1927
 process_one_work+0xbfa/0x1d30 kernel/workqueue.c:2097
 worker_thread+0x221/0x1860 kernel/workqueue.c:2231
 kthread+0x35f/0x430 kernel/kthread.c:231
 ret_from_fork+0x2a/0x40 arch/x86/entry/entry_64.S:425
Code: 48 3d 80 96 f8 b1 74 22 65 8b 05 f1 42 8c 53 83 f8 01 74 17 55 31 d2 =
48 c7 c6 80 96 f8 b1 31 ff 48 89 e5 e8 60 ff ff ff 5d c3 c3 <0f> 0b 90 66 2=
e 0f 1f 84 00 00 00 00 00 48 c7 c0 b4 10 73 b2 55=20
RIP: leave_mm+0x33/0x40 arch/x86/mm/tlb.c:50 RSP: ffff880036e7d4c8
---[ end trace 3b5d5a6fb6e394f8 ]---
Kernel panic - not syncing: Fatal exception
Dumping ftrace buffer:
   (ftrace buffer empty)
Kernel Offset: 0x2b800000 from 0xffffffff81000000 (relocation range: 0xffff=
ffff80000000-0xffffffffbfffffff)
Rebooting in 86400 seconds..

Don't really have an easy way to reproduce it...

--=20

Thanks,
Sasha=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
