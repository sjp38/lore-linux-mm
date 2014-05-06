Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f176.google.com (mail-vc0-f176.google.com [209.85.220.176])
	by kanga.kvack.org (Postfix) with ESMTP id 50B888299E
	for <linux-mm@kvack.org>; Tue,  6 May 2014 11:20:41 -0400 (EDT)
Received: by mail-vc0-f176.google.com with SMTP id lg15so1132192vcb.21
        for <linux-mm@kvack.org>; Tue, 06 May 2014 08:20:41 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id n36si17036312yhf.169.2014.05.06.08.20.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 06 May 2014 08:20:39 -0700 (PDT)
Message-ID: <5368FDBB.8070106@oracle.com>
Date: Tue, 06 May 2014 11:20:27 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH 6/6] mm: Postpone the disabling of kmemleak early logging
References: <1399038070-1540-1-git-send-email-catalin.marinas@arm.com> <1399038070-1540-7-git-send-email-catalin.marinas@arm.com>
In-Reply-To: <1399038070-1540-7-git-send-email-catalin.marinas@arm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On 05/02/2014 09:41 AM, Catalin Marinas wrote:
> Currently, kmemleak_early_log is disabled at the beginning of the
> kmemleak_init() function, before the full kmemleak tracing is actually
> enabled. In this small window, kmem_cache_create() is called by kmemleak
> which triggers additional memory allocation that are not traced. This
> patch moves the kmemleak_early_log disabling further down and at the
> same time with full kmemleak enabling.
> 
> Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>

This patch makes the kernel die during the boot process:

[   24.471801] BUG: unable to handle kernel paging request at ffffffff922f2b93
[   24.472496] IP: [<ffffffff922f2b93>] log_early+0x0/0xcd
[   24.473021] PGD 10e30067 PUD 10e31063 PMD 12200062
[   24.473544] Oops: 0010 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[   24.474129] Dumping ftrace buffer:
[   24.474535]    (ftrace buffer empty)
[   24.474901] Modules linked in:
[   24.475220] CPU: 0 PID: 1 Comm: swapper/0 Tainted: G        W     3.15.0-rc4-sasha-00193-g315d7bf #442
[   24.476094] task: ffff88025c540000 ti: ffff880036210000 task.ti: ffff880036210000
[   24.476807] RIP: 0010:[<ffffffff922f2b93>]  [<ffffffff922f2b93>] log_early+0x0/0xcd
[   24.477561] RSP: 0000:ffff880036211c20  EFLAGS: 00010246
[   24.478075] RAX: 0000000000000000 RBX: ffff880034e26458 RCX: 0000000000000001
[   24.478727] RDX: 0000000000000400 RSI: ffff880034e26458 RDI: 0000000000000000
[   24.479400] RBP: ffff880036211c48 R08: 0000000000000000 R09: 0000000000000000
[   24.480064] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000400
[   24.480171] R13: 0000000000000001 R14: 0000000000000001 R15: ffff88003680e600
[   24.480171] FS:  0000000000000000(0000) GS:ffff880036c00000(0000) knlGS:0000000000000000
[   24.480171] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[   24.480171] CR2: ffffffff922f2b93 CR3: 0000000010e2d000 CR4: 00000000000006b0
[   24.480171] Stack:
[   24.480171]  ffffffff8f4fb6ac ffff880036ddb210 ffff880034e26458 0000000000000020
[   24.480171]  ffff88003680e600 ffff880036211cc8 ffffffff8c2e0bf1 0000000000000002
[   24.480171]  000000008c19b731 ffffffff8cb07a03 0000000000000000 0000000000000400
[   24.480171] Call Trace:
[   24.480171]  [<ffffffff8f4fb6ac>] ? kmemleak_alloc+0xac/0xd0
[   24.480171]  [<ffffffff8c2e0bf1>] kmem_cache_alloc_node_trace+0x201/0x3d0
[   24.480171]  [<ffffffff8cb07a03>] ? alloc_cpumask_var_node+0x23/0x90
[   24.480171]  [<ffffffff8f566358>] ? preempt_count_sub+0xd8/0x130
[   24.480171]  [<ffffffff8c0c16e0>] ? alloc_pte_page+0x80/0x80
[   24.480171]  [<ffffffff8cb07a03>] alloc_cpumask_var_node+0x23/0x90
[   24.480171]  [<ffffffff8cb07a7e>] alloc_cpumask_var+0xe/0x10
[   24.480171]  [<ffffffff8c0a8a0a>] native_send_call_func_ipi+0x2a/0x130
[   24.480171]  [<ffffffff8cb07bee>] ? cpumask_next_and+0xae/0xd0
[   24.480171]  [<ffffffff8c0c16e0>] ? alloc_pte_page+0x80/0x80
[   24.480171]  [<ffffffff8c0c16e0>] ? alloc_pte_page+0x80/0x80
[   24.480171]  [<ffffffff8c20121b>] smp_call_function_many+0x29b/0x390
[   24.480171]  [<ffffffff8c0c16e0>] ? alloc_pte_page+0x80/0x80
[   24.480171]  [<ffffffff8c201726>] smp_call_function+0x46/0x80
[   24.480171]  [<ffffffff8c0c16e0>] ? alloc_pte_page+0x80/0x80
[   24.480171]  [<ffffffff8c2017ce>] on_each_cpu+0x3e/0x110
[   24.480171]  [<ffffffff8c0c3adb>] change_page_attr_set_clr+0x40b/0x4f0
[   24.480171]  [<ffffffff8c19b731>] ? get_parent_ip+0x11/0x50
[   24.480171]  [<ffffffff8c0c49ef>] set_memory_np+0x2f/0x40
[   24.480171]  [<ffffffff8c0bf32d>] free_init_pages+0x8d/0xb0
[   24.480171]  [<ffffffff8f4f7d60>] ? rest_init+0x140/0x140
[   24.480171]  [<ffffffff8c0bf373>] free_initmem+0x23/0x30
[   24.480171]  [<ffffffff8f4f7d78>] kernel_init+0x18/0x100
[   24.480171]  [<ffffffff8f56b0fc>] ret_from_fork+0x7c/0xb0
[   24.480171]  [<ffffffff8f4f7d60>] ? rest_init+0x140/0x140
[   24.480171] Code:  Bad RIP value.
[   24.480171] RIP  [<ffffffff922f2b93>] log_early+0x0/0xcd
[   24.480171]  RSP <ffff880036211c20>
[   24.480171] CR2: ffffffff922f2b93


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
