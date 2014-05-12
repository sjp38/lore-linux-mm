Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id 2C18D6B0035
	for <linux-mm@kvack.org>; Mon, 12 May 2014 11:19:28 -0400 (EDT)
Received: by mail-ig0-f181.google.com with SMTP id h3so3969657igd.14
        for <linux-mm@kvack.org>; Mon, 12 May 2014 08:19:27 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id ac8si9471898icc.144.2014.05.12.08.19.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 12 May 2014 08:19:27 -0700 (PDT)
Message-ID: <5370E65F.5080700@oracle.com>
Date: Mon, 12 May 2014 11:18:55 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: sched,mm: gpf in task_numa_work/mempolicy
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>

Hello friendly NUMA crew,

While fuzzing with trinity inside a KVM tools guest running the latest -next
kernel I've stumbled on the following spew:

[ 2328.642035] general protection fault: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[ 2328.644453] Dumping ftrace buffer:
[ 2328.646204]    (ftrace buffer empty)
[ 2328.647309] Modules linked in:
[ 2328.648317] CPU: 47 PID: 50166 Comm: trinity-c370 Tainted: G        W     3.15.0-rc5-next-20140512-sasha-00019-ga20bc00-dirty #456
[ 2328.650074] task: ffff880002bd8000 ti: ffff8800b9a2c000 task.ti: ffff8800b9a2c000
[ 2328.650074] RIP: task_numa_work (include/linux/gfp.h:258 include/linux/mempolicy.h:184 kernel/sched/fair.c:1905)
[ 2328.650074] RSP: 0018:ffff8800b9a2dea8  EFLAGS: 00010286
[ 2328.650074] RAX: a56b6b6b6b6b6b6b RBX: ffff8800cbbbc000 RCX: ffffffffb2748a58
[ 2328.650074] RDX: ffffffffab2a3b20 RSI: 0000000000000000 RDI: 0000000000000000
[ 2328.650074] RBP: ffff8800b9a2def8 R08: ffff8800cbbbc4b8 R09: 0000000000000000
[ 2328.650074] R10: 0000000000000001 R11: 0000000000000000 R12: 000000000000d18a
[ 2328.659448] R13: 00007f7c1b649000 R14: ffff880585651600 R15: ffff880002bd8000
[ 2328.659448] FS:  00007f7c1b647700(0000) GS:ffff8803a0e00000(0000) knlGS:0000000000000000
[ 2328.659448] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 2328.659448] CR2: 00000000006e2000 CR3: 00000000ca3f0000 CR4: 00000000000006a0
[ 2328.659448] DR0: 0000000000000000 DR1: 00000000006df000 DR2: 0000000000000000
[ 2328.659448] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
[ 2328.659448] Stack:
[ 2328.659448]  ffffffffab286f35 00007f7c1b646000 ffff8800cbbbc0a8 00000000000012d1
[ 2328.659448]  ffff8800b9a2ded8 ffffffffb193a100 0000000000000000 ffff880002bd8bb8
[ 2328.659448]  ffff880002bd8000 0000000000000004 ffff8800b9a2df28 ffffffffab189b4e
[ 2328.659448] Call Trace:
[ 2328.659448] ? context_tracking_user_exit (arch/x86/include/asm/paravirt.h:809 (discriminator 2) kernel/context_tracking.c:182 (discriminator 2))
[ 2328.659448] task_work_run (kernel/task_work.c:125 (discriminator 1))
[ 2328.659448] do_notify_resume (include/linux/tracehook.h:196 arch/x86/kernel/signal.c:753)
[ 2328.659448] int_signal (arch/x86/kernel/entry_64.S:804)
[ 2328.659448] Code: c3 e9 68 01 00 00 49 f7 46 50 00 44 00 00 0f 85 12 01 00 00 49 8b 86 a0 00 00 00 48 85 c0 0f 84 22 01 00 00 48 8b 80 f8 01 00 00 <48> 8b 90 48 01 00 00 b8 22 01 32 01 83 e2 0f 8d 0c 12 d3 f8 b9
[ 2328.659448] RIP task_numa_work (include/linux/gfp.h:258 include/linux/mempolicy.h:184 kernel/sched/fair.c:1905)
[ 2328.659448]  RSP <ffff8800b9a2dea8>


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
