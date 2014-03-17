Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f54.google.com (mail-yh0-f54.google.com [209.85.213.54])
	by kanga.kvack.org (Postfix) with ESMTP id 6ED1A6B00DC
	for <linux-mm@kvack.org>; Mon, 17 Mar 2014 18:56:38 -0400 (EDT)
Received: by mail-yh0-f54.google.com with SMTP id f73so6128845yha.27
        for <linux-mm@kvack.org>; Mon, 17 Mar 2014 15:56:38 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id y67si8699968yhk.76.2014.03.17.15.56.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 17 Mar 2014 15:56:37 -0700 (PDT)
Message-ID: <53277D9F.7070006@oracle.com>
Date: Mon, 17 Mar 2014 18:56:31 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: mm: kernel BUG at mm/mremap.c:68!
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

Hi all,

While fuzzing with trinity inside a KVM tools guest running latest -next
kernel I've stumbled on the following:

[ 2977.289180] kernel BUG at mm/mremap.c:68!
[ 2977.290064] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[ 2977.290231] Dumping ftrace buffer:
[ 2977.290231]    (ftrace buffer empty)
[ 2977.290231] Modules linked in:
[ 2977.290231] CPU: 20 PID: 36563 Comm: trinity-c383 Tainted: G        W     3.14.0-rc6-next-20140317-sasha-00012-ge933921-dirty #226
[ 2977.290231] task: ffff880bf79d3000 ti: ffff880bfb5c8000 task.ti: ffff880bfb5c8000
[ 2977.290231] RIP:  alloc_new_pmd (mm/mremap.c:68)
[ 2977.290231] RSP: 0018:ffff880bfb5c9d78  EFLAGS: 00010286
[ 2977.290231] RAX: 00000004b2a008e7 RBX: ffff880c28ab2000 RCX: ffff880000000000
[ 2977.290231] RDX: 00003ffffffff000 RSI: ffff880bc678c800 RDI: 00000004b2a008e7
[ 2977.290231] RBP: ffff880bfb5c9d98 R08: 0000000000000000 R09: 0000000000000000
[ 2977.290231] R10: 0000000000000001 R11: 00007f9847e76000 R12: ffff880c28ab3000
[ 2977.290231] R13: ffff880c27a6f000 R14: 0000000000100000 R15: ffff880c16e3b1f0
[ 2977.290231] FS:  00007f9847c67700(0000) GS:ffff88052ba00000(0000) knlGS:0000000000000000
[ 2977.290231] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 2977.290231] CR2: 0000000000697280 CR3: 0000000bf79af000 CR4: 00000000000006a0
[ 2977.290231] DR0: 0000000000698000 DR1: 0000000000698000 DR2: 0000000000000000
[ 2977.290231] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
[ 2977.290231] Stack:
[ 2977.290231]  0000000000102000 00007f9847c76000 ffff880bc678c800 0000000000002000
[ 2977.290231]  ffff880bfb5c9e28 ffffffff812a31a1 0000000000000000 0000000000000282
[ 2977.290231]  ffff880bfb5c9e08 ffff880504497400 00007f9847e76000 0000000000002000
[ 2977.290231] Call Trace:
[ 2977.290231]  move_page_tables (mm/mremap.c:193)
[ 2977.290231]  move_vma (mm/mremap.c:271)
[ 2977.290231]  mremap_to (mm/mremap.c:439)
[ 2977.290231]  ? SyS_mremap (mm/mremap.c:500 mm/mremap.c:470)
[ 2977.290231]  SyS_mremap (mm/mremap.c:501 mm/mremap.c:470)
[ 2977.290231]  ? syscall_trace_enter (include/linux/context_tracking.h:27 arch/x86/kernel/ptrace.c:1461)
[ 2977.290231]  tracesys (arch/x86/kernel/entry_64.S:749)
[ 2977.290231] Code: 3f 49 8b 3c 24 48 83 3d 43 ae ba 04 00 75 11 0f 0b 0f 1f 80 00 00 00 00 eb fe 66 0f 1f 44 00 00 48 89 f8 66 66 66 90 84 c0 79 15 <0f> 0b 0f 1f 00 eb fe 66 0f 1f 44 00 00 45 31 e4 0f 1f 44 00 00
[ 2977.290231] RIP  alloc_new_pmd (mm/mremap.c:68)
[ 2977.290231]  RSP <ffff880bfb5c9d78>


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
