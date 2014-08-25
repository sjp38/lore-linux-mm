Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f50.google.com (mail-oa0-f50.google.com [209.85.219.50])
	by kanga.kvack.org (Postfix) with ESMTP id 4D43F6B0035
	for <linux-mm@kvack.org>; Mon, 25 Aug 2014 12:38:31 -0400 (EDT)
Received: by mail-oa0-f50.google.com with SMTP id g18so11047373oah.9
        for <linux-mm@kvack.org>; Mon, 25 Aug 2014 09:38:31 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id i10si46712621obw.100.2014.08.25.09.38.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 25 Aug 2014 09:38:30 -0700 (PDT)
Message-ID: <53FB6667.9010600@oracle.com>
Date: Mon, 25 Aug 2014 12:37:59 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: mm/v9fs: kernel panic accessing kmap()ed pages
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ericvh@gmail.com, lucho@ionkov.net, rminnich@sandia.gov, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Dave Jones <davej@redhat.com>, LKML <linux-kernel@vger.kernel.org>, v9fs-developer@lists.sourceforge.net

Hi all,

While fuzzing with trinity inside a KVM tools guest running the latest -next
kernel, I've stumbled on the following spew:

[12886.637991] BUG: unable to handle kernel paging request at ffff88017dce7000
[12886.640053] IP: memset (arch/x86/lib/memset_64.S:84)
[12886.640053] PGD 15b46067 PUD 9763c5067 PMD 9761d6067 PTE 800000017dce7060
[12886.640053] Oops: 0002 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[12886.640053] Dumping ftrace buffer:
[12886.640053]    (ftrace buffer empty)
[12886.640053] Modules linked in:
[12886.640053] CPU: 4 PID: 7421 Comm: modprobe Not tainted 3.17.0-rc1-next-20140823-sasha-00034-g503bc40 #1077
[12886.640053] task: ffff8804c2288000 ti: ffff88008398c000 task.ti: ffff88008398c000
[12886.640053] RIP: memset (arch/x86/lib/memset_64.S:84)
[12886.640053] RSP: 0018:ffff88008398f9f0  EFLAGS: 00010212
[12886.640053] RAX: 0000000000000000 RBX: ffffea0005f6e800 RCX: 03ffffffffffae7f
[12886.640053] RDX: fffffffffffe4c08 RSI: 0000000000000000 RDI: ffff88017dce6ff8
[12886.640053] RBP: ffff88008398fa28 R08: 0000000000000002 R09: 0000000000000006
[12886.640053] R10: ffff88017dbbc3f6 R11: 0000000000000000 R12: ffff880271538de8
[12886.640053] R13: ffff88076b4ff500 R14: ffff88017dba0000 R15: ffffea0005f6e820
[12886.640053] FS:  0000000000000000(0000) GS:ffff880277c00000(0000) knlGS:0000000000000000
[12886.640053] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[12886.640053] CR2: ffff88017dce7000 CR3: 00000007990c2000 CR4: 00000000000006a0
[12886.640053] Stack:
[12886.640053]  ffffffff8e7a9a25 ffff88008398fa08 ffffffff8e2a77cd ffffea0005f6e800
[12886.640053]  ffff88008398fb38 ffff880271538ff8 ffff8804c2288000 ffff88008398fa38
[12886.640053]  ffffffff8e7a9b75 ffff88008398fa98 ffffffff8e2a4b25 ffffffff8e7acf40
[12886.640053] Call Trace:
[12886.640053] ? v9fs_fid_readpage (./arch/x86/include/asm/bitops.h:75 include/linux/page-flags.h:321 fs/9p/vfs_addr.c:79)
[12886.640053] ? lru_cache_add (mm/swap.c:665)
[12886.640053] v9fs_vfs_readpage (fs/9p/vfs_addr.c:101)
[12886.640053] read_cache_pages (mm/readahead.c:100)
[12886.640053] ? v9fs_cache_session_get_key (fs/9p/cache.c:306)
[12886.640053] ? v9fs_write_begin (fs/9p/vfs_addr.c:99)
[12886.640053] v9fs_vfs_readpages (fs/9p/vfs_addr.c:127)
[12886.640053] __do_page_cache_readahead (mm/readahead.c:123 mm/readahead.c:200)
[12886.640053] ? __do_page_cache_readahead (include/linux/rcupdate.h:814 mm/readahead.c:178)
[12886.640053] filemap_fault (include/linux/memcontrol.h:137 include/linux/memcontrol.h:194 mm/filemap.c:1891)
[12886.640053] __do_fault (mm/memory.c:2712)
[12886.640053] ? _raw_spin_unlock (./arch/x86/include/asm/preempt.h:98 include/linux/spinlock_api_smp.h:152 kernel/locking/spinlock.c:183)
[12886.640053] do_read_fault.isra.40 (mm/memory.c:2901)
[12886.640053] ? get_parent_ip (kernel/sched/core.c:2552)
[12886.640053] ? preempt_count_sub (kernel/sched/core.c:2608)
[12886.640053] __handle_mm_fault (mm/memory.c:3048 mm/memory.c:3214 mm/memory.c:3341)
[12886.640053] handle_mm_fault (include/linux/memcontrol.h:120 mm/memory.c:3373)
[12886.640053] ? __do_page_fault (arch/x86/mm/fault.c:1163)
[12886.640053] __do_page_fault (arch/x86/mm/fault.c:1231)
[12886.640053] ? vtime_account_user (kernel/sched/cputime.c:687)
[12886.640053] ? get_parent_ip (kernel/sched/core.c:2552)
[12886.640053] ? preempt_count_sub (kernel/sched/core.c:2608)
[12886.640053] ? context_tracking_user_exit (kernel/context_tracking.c:184)
[12886.640053] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[12886.640053] ? trace_hardirqs_off_caller (kernel/locking/lockdep.c:2640 (discriminator 2))
[12886.640053] trace_do_page_fault (arch/x86/mm/fault.c:1314 include/linux/jump_label.h:114 include/linux/context_tracking_state.h:27 include/linux/context_tracking.h:45 arch/x86/mm/fault.c:1315)
[12886.640053] do_async_page_fault (arch/x86/kernel/kvm.c:264)
[12886.640053] async_page_fault (arch/x86/kernel/entry_64.S:1313)
[12886.640053] Code: 01 01 01 01 01 01 48 0f af c1 41 89 f9 41 83 e1 07 75 70 48 89 d1 48 c1 e9 06 74 39 66 0f 1f 84 00 00 00 00 00 48 ff c9 48 89 07 <48> 89 47 08 48 89 47 10 48 89 47 18 48 89 47 20 48 89 47 28 48
All code
========
   0:	01 01                	add    %eax,(%rcx)
   2:	01 01                	add    %eax,(%rcx)
   4:	01 01                	add    %eax,(%rcx)
   6:	48 0f af c1          	imul   %rcx,%rax
   a:	41 89 f9             	mov    %edi,%r9d
   d:	41 83 e1 07          	and    $0x7,%r9d
  11:	75 70                	jne    0x83
  13:	48 89 d1             	mov    %rdx,%rcx
  16:	48 c1 e9 06          	shr    $0x6,%rcx
  1a:	74 39                	je     0x55
  1c:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
  23:	00 00
  25:	48 ff c9             	dec    %rcx
  28:	48 89 07             	mov    %rax,(%rdi)
  2b:*	48 89 47 08          	mov    %rax,0x8(%rdi)		<-- trapping instruction
  2f:	48 89 47 10          	mov    %rax,0x10(%rdi)
  33:	48 89 47 18          	mov    %rax,0x18(%rdi)
  37:	48 89 47 20          	mov    %rax,0x20(%rdi)
  3b:	48 89 47 28          	mov    %rax,0x28(%rdi)
  3f:	48                   	rex.W
	...

Code starting with the faulting instruction
===========================================
   0:	48 89 47 08          	mov    %rax,0x8(%rdi)
   4:	48 89 47 10          	mov    %rax,0x10(%rdi)
   8:	48 89 47 18          	mov    %rax,0x18(%rdi)
   c:	48 89 47 20          	mov    %rax,0x20(%rdi)
  10:	48 89 47 28          	mov    %rax,0x28(%rdi)
  14:	48                   	rex.W
	...
[12886.640053] RIP memset (arch/x86/lib/memset_64.S:84)
[12886.640053]  RSP <ffff88008398f9f0>
[12886.640053] CR2: ffff88017dce7000


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
