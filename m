Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id DA4FB6B0037
	for <linux-mm@kvack.org>; Mon, 12 May 2014 11:06:33 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id lf10so6261666pab.20
        for <linux-mm@kvack.org>; Mon, 12 May 2014 08:06:33 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id wt1si6459470pbc.505.2014.05.12.08.06.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 12 May 2014 08:06:32 -0700 (PDT)
Message-ID: <5370E1B1.5050501@oracle.com>
Date: Mon, 12 May 2014 10:58:57 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: shmem: NULL ptr deref in shmem_fault
References: <5370DA09.7020801@oracle.com>
In-Reply-To: <5370DA09.7020801@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Jones <davej@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 05/12/2014 10:26 AM, Sasha Levin wrote:
> Hi all,
> 
> While fuzzing with trinity inside a KVM tools guest running the latest -next
> kernel I've stumbled on the following spew.
> 
> It seems that in this case, 'inode->i_mapping' was NULL, and the deref happened
> when we tried to get it's flags in mapping_gfp_mask().

And another one, which seems to be related. Here it seems that inode->policy was
invalid:

[  610.862199] BUG: unable to handle kernel paging request at ffffffffffffff48
[  610.863416] IP: mpol_shared_policy_lookup (mm/mempolicy.c:2202)
[  610.864598] PGD 2c02f067 PUD 2c031067 PMD 0
[  610.865360] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[  610.866325] Dumping ftrace buffer:
[  610.867017]    (ftrace buffer empty)
[  610.867689] Modules linked in:
[  610.868697] CPU: 12 PID: 13939 Comm: trinity-c101 Not tainted 3.15.0-rc5-next-20140512-sasha-00019-ga20bc00-dirty #456
[  610.870051] task: ffff880291403000 ti: ffff880291124000 task.ti: ffff880291124000
[  610.870051] RIP: mpol_shared_policy_lookup (mm/mempolicy.c:2202)
[  610.870051] RSP: 0018:ffff880291125e48  EFLAGS: 00010286
[  610.870051] RAX: ffff8802bb80b800 RBX: ffffffffffffff48 RCX: ffffffffae748740
[  610.870051] RDX: ffffffffa72a3b20 RSI: 0000000000000001 RDI: ffffffffffffff48
[  610.870051] RBP: ffff880291125e68 R08: ffff88036620e4b8 R09: 0000000000000000
[  610.870051] R10: 0000000000000001 R11: 0000000000000000 R12: 000000000000cf54
[  610.870051] R13: 00007fe57c76f000 R14: ffff8802fd0a7200 R15: ffff880291403000
[  610.870051] FS:  00007fe57c76d700(0000) GS:ffff8802fee00000(0000) knlGS:0000000000000000
[  610.870051] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  610.870051] CR2: ffffffffffffff48 CR3: 0000000291108000 CR4: 00000000000006a0
[  610.870051] DR0: 00000000006df000 DR1: 00000000006df000 DR2: 00000000006df000
[  610.886009] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000602
[  610.886009] Stack:
[  610.886009]  ffff88029114e800 ffff88036620e000 000000000000cf54 00007fe57c76f000
[  610.886009]  ffff880291125e78 ffffffffa72a3b4e ffff880291125e98 ffffffffa72e16a2
[  610.886009]  000000000000cf54 00007fe57c76f000 ffff880291125ef8 ffffffffa71a9f3b
[  610.886009] Call Trace:
[  610.886009] shmem_get_policy (mm/shmem.c:1262)
[  610.886009] vma_policy_mof (mm/mempolicy.c:1609)
[  610.886009] task_numa_work (kernel/sched/fair.c:1905)
[  610.886009] ? context_tracking_user_exit (arch/x86/include/asm/paravirt.h:809 (discriminator 2) kernel/context_tracking.c:182 (discriminator 2))
[  610.886009] task_work_run (kernel/task_work.c:125 (discriminator 1))
[  610.886009] do_notify_resume (include/linux/tracehook.h:196 arch/x86/kernel/signal.c:753)
[  610.886009] int_signal (arch/x86/kernel/entry_64.S:804)
[  610.886009] Code: 66 66 66 90 55 48 89 e5 e8 02 ff ff ff 5d c3 66 66 66 66 90 55 48 89 e5 48 83 ec 20 48 89 5d e8 48 89 fb 4c 89 65 f0 4c 89 6d f8 <48> 83 3f 00 74 4e 4c 8d 6f 08 49 89 f4 4c 89 ef e8 4f 85 2a 03
[  610.886009] RIP mpol_shared_policy_lookup (mm/mempolicy.c:2202)
[  610.886009]  RSP <ffff880291125e48>
[  610.886009] CR2: ffffffffffffff48


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
