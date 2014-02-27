Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 2F69A6B0037
	for <linux-mm@kvack.org>; Thu, 27 Feb 2014 10:03:41 -0500 (EST)
Received: by mail-pd0-f180.google.com with SMTP id y10so2542926pdj.39
        for <linux-mm@kvack.org>; Thu, 27 Feb 2014 07:03:40 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id fd10si4905270pad.109.2014.02.27.07.03.39
        for <linux-mm@kvack.org>;
        Thu, 27 Feb 2014 07:03:40 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <530F3F0A.5040304@oracle.com>
References: <530F3F0A.5040304@oracle.com>
Subject: RE: mm: kernel BUG at mm/huge_memory.c:2785!
Content-Transfer-Encoding: 7bit
Message-Id: <20140227150313.3BA27E0098@blue.fi.intel.com>
Date: Thu, 27 Feb 2014 17:03:13 +0200 (EET)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>, Andrea Arcangeli <aarcange@redhat.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Sasha Levin wrote:
> Hi all,
> 
> While fuzzing with trinity inside a KVM tools guest running latest -next kernel I've stumbled on the 
> following spew:
> 
> [ 1428.146261] kernel BUG at mm/huge_memory.c:2785!

Hm, interesting.

It seems we either failed to split huge page on vma split or it
materialized from under us. I don't see how it can happen:

  - it seems we do the right thing with vma_adjust_trans_huge() in
    __split_vma();
  - we hold ->mmap_sem all the way from vm_munmap(). At least I don't see
    a place where we could drop it;

Andrea, any ideas?

> [ 1428.147100] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> [ 1428.148512] Dumping ftrace buffer:
> [ 1428.149497]    (ftrace buffer empty)
> [ 1428.150248] Modules linked in:
> [ 1428.151164] CPU: 106 PID: 29430 Comm: trinity-c106 Tainted: G        W 
> 3.14.0-rc4-next-20140226-sasha-00013-g082bdac-dirty #4
> [ 1428.153515] task: ffff8808906c8000 ti: ffff880890aa6000 task.ti: ffff880890aa6000
> [ 1428.154274] RIP: 0010:[<mm/huge_memory.c:2785>]  [<mm/huge_memory.c:2785>] 
> __split_huge_page_pmd+0x3f/0x2e0
> [ 1428.154274] RSP: 0018:ffff880890aa7c98  EFLAGS: 00010287
> [ 1428.154274] RAX: ffff880890f34000 RBX: ffff880b3c6791a0 RCX: 00003ffffffff000
> [ 1428.154274] RDX: ffff880b3c6791a0 RSI: 00007f29869b4000 RDI: ffff8803dcbd6400
> [ 1428.154274] RBP: ffff880890aa7ce8 R08: 00007f29869b5000 R09: 0000000000000000
> [ 1428.154274] R10: 0000000000000000 R11: 0000000000000000 R12: ffff880b3c6791a0
> [ 1428.154274] R13: 00007f2986800000 R14: ffff8803dcbd6400 R15: 00007f29869b4fff
> [ 1428.154274] FS:  00007f298bb67700(0000) GS:ffff8803de800000(0000) knlGS:0000000000000000
> [ 1428.154274] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [ 1428.154274] CR2: 00007f298b978608 CR3: 00000008907c3000 CR4: 00000000000006e0
> [ 1428.154274] DR0: 8200000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [ 1428.154274] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
> [ 1428.154274] Stack:
> [ 1428.154274]  00000000001d8400 0000000000000001 ffff880890aa7cc8 ffff880890f34000
> [ 1428.154274]  ffffffff876bcfe0 ffff880b3c6791a0 00007f29869b4000 00007f29869b5000
> [ 1428.154274]  ffff880890aa7e18 00007f29869b4fff ffff880890aa7d78 ffffffff8127ff06
> [ 1428.154274] Call Trace:
> [ 1428.154274]  [<mm/memory.c:1230 mm/memory.c:1265 mm/memory.c:1290>] unmap_page_range+0x2a6/0x410
> [ 1428.154274]  [<mm/memory.c:1338>] unmap_single_vma+0xf1/0x110
> [ 1428.154274]  [<mm/memory.c:1365>] unmap_vmas+0x61/0xa0
> [ 1428.154274]  [<mm/mmap.c:2361>] unmap_region+0xbc/0x120
> [ 1428.154274]  [<include/linux/mm.h:1315 mm/mmap.c:2332 mm/mmap.c:2557>] do_munmap+0x27a/0x350
> [ 1428.154274]  [<mm/mmap.c:2568>] ? vm_munmap+0x41/0x80
> [ 1428.154274]  [<mm/mmap.c:2569>] vm_munmap+0x4f/0x80
> [ 1428.154274]  [<mm/mmap.c:2574>] SyS_munmap+0x27/0x40
> [ 1428.154274]  [<arch/x86/kernel/entry_64.S:749>] tracesys+0xdd/0xe2
> [ 1428.154274] Code: e5 00 00 e0 ff 53 49 89 d4 48 83 ec 28 48 8b 47 40 48 89 45 c8 4c 3b 2f 72 11 
> 49 8d 95 00 00 20 00 48 89 55 c0 48 39 57 08 73 11 <0f> 0b 0f 1f 80 00 00 00 00 eb fe 66 0f 1f 44 00 
> 00 4c 89 e3 49
> [ 1428.154274] RIP  [<mm/huge_memory.c:2785>] __split_huge_page_pmd+0x3f/0x2e0
> [ 1428.154274]  RSP <ffff880890aa7c98>
> 
> 
> Thanks,
> Sasha

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
