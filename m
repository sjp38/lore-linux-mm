Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f44.google.com (mail-yh0-f44.google.com [209.85.213.44])
	by kanga.kvack.org (Postfix) with ESMTP id 581826B0031
	for <linux-mm@kvack.org>; Thu,  3 Apr 2014 10:17:18 -0400 (EDT)
Received: by mail-yh0-f44.google.com with SMTP id f10so1719185yha.17
        for <linux-mm@kvack.org>; Thu, 03 Apr 2014 07:17:18 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id q46si6216160yhl.83.2014.04.03.07.17.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 03 Apr 2014 07:17:17 -0700 (PDT)
Message-ID: <533D6D66.7030402@oracle.com>
Date: Thu, 03 Apr 2014 10:17:10 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: mm: BUG in __phys_addr called from __walk_page_range
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

Hi all,

While fuzzing with trinity inside a KVM tools guest running the latest
-next kernel I've stumbled on the following:

[  942.869226] kernel BUG at arch/x86/mm/physaddr.c:26!
[  942.871710] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[  942.871710] Dumping ftrace buffer:
[  942.871710]    (ftrace buffer empty)
[  942.871710] Modules linked in:
[  942.871710] CPU: 16 PID: 17165 Comm: trinity-c55 Tainted: G        W     3.14.0-next-20140402-sasha-00013-g0cfaf7e-dirty #367
[  942.871710] task: ffff8801de603000 ti: ffff8801e7b4c000 task.ti: ffff8801e7b4c000
[  942.871710] RIP: __phys_addr (arch/x86/mm/physaddr.c:26 (discriminator 1))
[  942.871710] RSP: 0000:ffff8801e7b4daf8  EFLAGS: 00010287
[  942.871710] RAX: 0000780000000000 RBX: 00007f11fb000000 RCX: 0000000000000009
[  942.871710] RDX: 0000000080000000 RSI: 00007f11fae00000 RDI: 0000000000000000
[  942.871710] RBP: ffff8801e7b4daf8 R08: 0000000000000000 R09: 0000000008640070
[  942.871710] R10: 00007f11fae00000 R11: 00007f123ae00000 R12: ffffffffb54b2140
[  942.871710] R13: 0000000000200000 R14: 00007f11fae00000 R15: ffff8801e7b4dc00
[  942.871710] FS:  00007f123eb21700(0000) GS:ffff88046cc00000(0000) knlGS:0000000000000000
[  942.871710] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  942.871710] CR2: 0000000000000000 CR3: 00000001de6bc000 CR4: 00000000000006a0
[  942.871710] DR0: 0000000000696000 DR1: 0000000000696000 DR2: 0000000000000000
[  942.871710] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 000000000057060a
[  942.871710] Stack:
[  942.871710]  ffff8801e7b4db98 ffffffffae2c1651 ffff8801e7b4db38 0000000000000000
[  942.871710]  ffff8801debf40b0 0000000040000000 ffff880767bb4000 00007f11fadfffff
[  942.871710]  00007f11fadfffff 000000003fffffff 00007f11fae00000 ffff8801eb8c7000
[  942.871710] Call Trace:
[  942.871710] __walk_page_range (include/linux/mm.h:1525 include/linux/mm.h:1530 include/linux/hugetlb.h:403 include/linux/hugetlb.h:451 mm/pagewalk.c:196 mm/pagewalk.c:254)
[  942.871710] walk_page_range (mm/pagewalk.c:333)
[  942.871710] queue_pages_range (mm/mempolicy.c:653)
[  942.871710] ? queue_pages_hugetlb (mm/mempolicy.c:492)
[  942.871710] ? queue_pages_range (mm/mempolicy.c:521)
[  942.871710] ? change_prot_numa (mm/mempolicy.c:588)
[  942.871710] migrate_to_node (mm/mempolicy.c:988)
[  942.871710] ? preempt_count_sub (kernel/sched/core.c:2527)
[  942.871710] do_migrate_pages (mm/mempolicy.c:1095)
[  942.871710] SYSC_migrate_pages (mm/mempolicy.c:1445)
[  942.871710] ? SYSC_migrate_pages (include/linux/rcupdate.h:800 mm/mempolicy.c:1391)
[  942.871710] SyS_migrate_pages (mm/mempolicy.c:1365)
[  942.871710] ia32_do_call (arch/x86/ia32/ia32entry.S:430)
[  942.871710] Code: 0f 0b 0f 1f 44 00 00 48 b8 00 00 00 00 00 78 00 00 48 01 f8 48 39 c2 72 12 0f b6 0d 10 0f fe 05 48 89 c2 48 d3 ea 48 85 d2 74 0c <0f> 0b 66 2e 0f 1f 84 00 00 00 00 00 5d c3 66 2e 0f 1f 84 00 00
[  942.871710] RIP __phys_addr (arch/x86/mm/physaddr.c:26 (discriminator 1))
[  942.871710]  RSP <ffff8801e7b4daf8>


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
