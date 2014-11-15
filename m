Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id 265626B00CE
	for <linux-mm@kvack.org>; Fri, 14 Nov 2014 22:39:30 -0500 (EST)
Received: by mail-ob0-f174.google.com with SMTP id uz6so13605340obc.33
        for <linux-mm@kvack.org>; Fri, 14 Nov 2014 19:39:29 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id ge9si31679572obb.99.2014.11.14.19.39.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 14 Nov 2014 19:39:28 -0800 (PST)
Message-ID: <5466C8A5.3000402@oracle.com>
Date: Fri, 14 Nov 2014 22:29:41 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/7] Replace _PAGE_NUMA with PAGE_NONE protections
References: <1415971986-16143-1-git-send-email-mgorman@suse.de>
In-Reply-To: <1415971986-16143-1-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Linux Kernel <linux-kernel@vger.kernel.org>
Cc: Linux-MM <linux-mm@kvack.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, Dave Jones <davej@redhat.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@redhat.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>

On 11/14/2014 08:32 AM, Mel Gorman wrote:> This is follow up from the "pipe/page fault oddness" thread.

Hi Mel,

Applying this patch series I've started seeing the following straight away:

[  367.547848] page:ffffea0003fb7db0 count:1007 mapcount:1005 mapping:ffff8800691f2f58 index:0x37
[  367.551481] flags: 0x5001aa8030202d(locked|referenced|uptodate|lru|writeback|unevictable|mlocked)
[  367.555382] page dumped because: VM_BUG_ON_PAGE(!v9inode->writeback_fid)
[  367.558262] page->mem_cgroup:ffff88006d8a1bd8
[  367.560403] ------------[ cut here ]------------
[  367.562343] kernel BUG at fs/9p/vfs_addr.c:190!
[  367.564239] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC KASAN
[  367.566991] Dumping ftrace buffer:
[  367.568481]    (ftrace buffer empty)
[  367.569914] Modules linked in:
[  367.570254] CPU: 3 PID: 8234 Comm: kworker/u52:1 Not tainted 3.18.0-rc4-next-20141114-sasha-00054-ga9ff95e-dirty #1459
[  367.570254] Workqueue: writeback bdi_writeback_workfn (flush-9p-1)
[  367.570254] task: ffff8801e21d8000 ti: ffff8801e1f34000 task.ti: ffff8801e1f34000
[  367.570254] RIP: v9fs_vfs_writepage_locked (fs/9p/vfs_addr.c:190 (discriminator 1))
[  367.570254] RSP: 0018:ffff8801e1f376c8  EFLAGS: 00010286
[  367.570254] RAX: 0000000000000021 RBX: ffffea0003fb7db0 RCX: 0000000000000000
[  367.570254] RDX: 0000000000000021 RSI: ffffffff9208b2e6 RDI: ffff8801e21d8d0c
[  367.570254] RBP: ffff8801e1f37728 R08: 0000000000000001 R09: 0000000000000000
[  367.570254] R10: 0000000000000001 R11: 0000000000000001 R12: ffff8800691f2d48
[  367.570254] R13: 0000000000001000 R14: ffff8800691f2c30 R15: ffff8800691f2c98
[  367.570254] FS:  0000000000000000(0000) GS:ffff8801e5c00000(0000) knlGS:0000000000000000
[  367.570254] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  367.570254] CR2: 0000000000000000 CR3: 00000000ca00c000 CR4: 00000000000006a0
[  367.570254] DR0: ffffffff81000000 DR1: 0000000000000000 DR2: 0000000000000000
[  367.570254] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
[  367.570254] Stack:
[  367.570254]  ffffda003c43b1a1 ffffda003c43b1a1 0000000000000000 0000000000000002
[  367.570254]  0000000000000002 0000000000037000 ffff8801e1f37758 ffffea0003fb7db0
[  367.570254]  0000000000000000 ffff8801e1f37a60 ffff8801e1f37a60 ffffea0003fb7db0
[  367.570254] Call Trace:
[  367.570254] v9fs_vfs_writepage (fs/9p/vfs_addr.c:212)
[  367.570254] __writepage (include/linux/pagemap.h:32 mm/page-writeback.c:2006)
[  367.570254] write_cache_pages (mm/page-writeback.c:1943)
[  367.570254] ? bdi_set_max_ratio (mm/page-writeback.c:2003)
[  367.570254] ? sched_clock_local (kernel/sched/clock.c:202)
[  367.570254] generic_writepages (mm/page-writeback.c:2030)
[  367.570254] do_writepages (mm/page-writeback.c:2047)
[  367.570254] __writeback_single_inode (fs/fs-writeback.c:461 (discriminator 3))
[  367.570254] writeback_sb_inodes (fs/fs-writeback.c:706)
[  367.570254] __writeback_inodes_wb (fs/fs-writeback.c:749)
[  367.570254] wb_writeback (fs/fs-writeback.c:880)
[  367.570254] ? __lock_is_held (kernel/locking/lockdep.c:3518)
[  367.570254] bdi_writeback_workfn (fs/fs-writeback.c:1015 fs/fs-writeback.c:1060)
[  367.570254] process_one_work (kernel/workqueue.c:2023 include/linux/jump_label.h:114 include/trace/events/workqueue.h:111 kernel/workqueue.c:2028)
[  367.570254] ? process_one_work (kernel/workqueue.c:2020)
[  367.570254] ? get_lock_stats (kernel/locking/lockdep.c:249)
[  367.570254] worker_thread (include/linux/list.h:189 kernel/workqueue.c:2156)
[  367.570254] ? __schedule (./arch/x86/include/asm/bitops.h:311 include/linux/thread_info.h:91 include/linux/sched.h:2939 kernel/sched/core.c:2848)
[  367.570254] ? rescuer_thread (kernel/workqueue.c:2100)
[  367.570254] kthread (kernel/kthread.c:207)
[  367.570254] ? flush_kthread_work (kernel/kthread.c:176)
[  367.570254] ret_from_fork (arch/x86/kernel/entry_64.S:348)
[  367.570254] ? flush_kthread_work (kernel/kthread.c:176)
[ 367.570254] Code: 48 83 c4 38 44 89 f0 5b 41 5c 41 5d 41 5e 41 5f 5d c3 66 2e 0f 1f 84 00 00 00 00 00 48 c7 c6 f8 18 37 93 48 89 df e8 e1 8b 93 fe <0f> 0b 48 89 de 48 c7 c7 30 bd 9f 95 48 89 4d b8 e8 10 5f 02 0f

All code
========
   0:	48 83 c4 38          	add    $0x38,%rsp
   4:	44 89 f0             	mov    %r14d,%eax
   7:	5b                   	pop    %rbx
   8:	41 5c                	pop    %r12
   a:	41 5d                	pop    %r13
   c:	41 5e                	pop    %r14
   e:	41 5f                	pop    %r15
  10:	5d                   	pop    %rbp
  11:	c3                   	retq
  12:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  19:	00 00 00
  1c:	48 c7 c6 f8 18 37 93 	mov    $0xffffffff933718f8,%rsi
  23:	48 89 df             	mov    %rbx,%rdi
  26:	e8 e1 8b 93 fe       	callq  0xfffffffffe938c0c
  2b:*	0f 0b                	ud2    		<-- trapping instruction
  2d:	48 89 de             	mov    %rbx,%rsi
  30:	48 c7 c7 30 bd 9f 95 	mov    $0xffffffff959fbd30,%rdi
  37:	48 89 4d b8          	mov    %rcx,-0x48(%rbp)
  3b:	e8 10 5f 02 0f       	callq  0xf025f50
	...

Code starting with the faulting instruction
===========================================
   0:	0f 0b                	ud2
   2:	48 89 de             	mov    %rbx,%rsi
   5:	48 c7 c7 30 bd 9f 95 	mov    $0xffffffff959fbd30,%rdi
   c:	48 89 4d b8          	mov    %rcx,-0x48(%rbp)
  10:	e8 10 5f 02 0f       	callq  0xf025f25
	...
[  367.570254] RIP v9fs_vfs_writepage_locked (fs/9p/vfs_addr.c:190 (discriminator 1))
[  367.570254]  RSP <ffff8801e1f376c8>

(Note that I replaced the BUG_ON with a VM_BUG_ON_PAGE to get some extra information.)


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
