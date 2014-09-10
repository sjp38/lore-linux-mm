Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f175.google.com (mail-lb0-f175.google.com [209.85.217.175])
	by kanga.kvack.org (Postfix) with ESMTP id 9560B6B0036
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 09:40:21 -0400 (EDT)
Received: by mail-lb0-f175.google.com with SMTP id v6so4741200lbi.20
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 06:40:20 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r8si21647387lby.33.2014.09.10.06.40.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Sep 2014 06:40:19 -0700 (PDT)
Date: Wed, 10 Sep 2014 14:40:14 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: mm: BUG in unmap_page_range
Message-ID: <20140910134014.GU17501@suse.de>
References: <53FD4D9F.6050500@oracle.com>
 <20140827152622.GC12424@suse.de>
 <540127AC.4040804@oracle.com>
 <54082B25.9090600@oracle.com>
 <20140908171853.GN17501@suse.de>
 <540DEDE7.4020300@oracle.com>
 <20140909213309.GQ17501@suse.de>
 <540F7D42.1020402@oracle.com>
 <alpine.LSU.2.11.1409091903390.10989@eggly.anvils>
 <54104E24.5010402@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <54104E24.5010402@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Hugh Dickins <hughd@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, LKML <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Cyrill Gorcunov <gorcunov@gmail.com>

On Wed, Sep 10, 2014 at 09:12:04AM -0400, Sasha Levin wrote:
> <SNIP, haven't digested the rest>
> 
> I've spotted a new trace in overnight fuzzing, it could be related to this issue:
> 
> [ 3494.324839] general protection fault: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> [ 3494.332153] Dumping ftrace buffer:
> [ 3494.332153]    (ftrace buffer empty)
> [ 3494.332153] Modules linked in:
> [ 3494.332153] CPU: 8 PID: 2727 Comm: trinity-c929 Not tainted 3.17.0-rc4-next-20140909-sasha-00032-gc16d47b #1135
> [ 3494.332153] task: ffff88047e52b000 ti: ffff8804d491c000 task.ti: ffff8804d491c000
> [ 3494.332153] RIP: task_numa_work (include/linux/mempolicy.h:177 kernel/sched/fair.c:1956)
> [ 3494.332153] RSP: 0000:ffff8804d491feb8  EFLAGS: 00010206
> [ 3494.332153] RAX: 0000000000000000 RBX: ffff8804bf4e8000 RCX: 000000000000e8e8
> [ 3494.343974] RDX: 000000000000000a RSI: 0000000000000000 RDI: ffff8804bd6d4da8
> [ 3494.343974] RBP: ffff8804d491fef8 R08: ffff8804bf4e84c8 R09: 0000000000000000
> [ 3494.343974] R10: 00007f53e443c000 R11: 0000000000000001 R12: 00007f53e443c000
> [ 3494.343974] R13: 000000000000dc51 R14: 006f732e61727478 R15: ffff88047e52b000
> [ 3494.343974] FS:  00007f53e463f700(0000) GS:ffff880277e00000(0000) knlGS:0000000000000000
> [ 3494.343974] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [ 3494.369895] CR2: 0000000001670fa8 CR3: 0000000283562000 CR4: 00000000000006a0
> [ 3494.369895] DR0: 00000000006f0000 DR1: 0000000000000000 DR2: 0000000000000000
> [ 3494.369895] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
> [ 3494.380081] Stack:
> [ 3494.380081]  ffff8804bf4e80a8 0000000000000014 00007f53e4437000 0000000000000000
> [ 3494.380081]  ffffffff9b976e70 ffff88047e52bbd8 ffff88047e52b000 0000000000000000
> [ 3494.380081]  ffff8804d491ff28 ffffffff95193d84 0000000000000002 ffff8804d491ff58
> [ 3494.380081] Call Trace:
> [ 3494.380081] task_work_run (kernel/task_work.c:125 (discriminator 1))
> [ 3494.380081] do_notify_resume (include/linux/tracehook.h:190 arch/x86/kernel/signal.c:758)
> [ 3494.380081] retint_signal (arch/x86/kernel/entry_64.S:918)
> [ 3494.380081] Code: e8 1e e5 01 00 48 89 df 4c 89 e6 e8 a3 2d 13 00 49 89 c6 48 85 c0 0f 84 07 02 00 00 48 c7 45 c8 00 00 00 00 0f 1f 80 00 00 00 00 <49> f7 46 50 00 44 00 00 0f 85 42 01 00 00 49 8b 86 a0 00 00 00

Shot in dark, can you test this please? Pagetable teardown can schedule
and I'm wondering if we are trying to add hinting faults to an address
space that is in the process of going away. The TASK_DEAD check is bogus
so replacing it.

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 7ea6006..007fc1c 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -1810,7 +1810,7 @@ void task_numa_fault(int last_cpupid, int mem_node, int pages, int flags)
 		return;
 
 	/* Do not worry about placement if exiting */
-	if (p->state == TASK_DEAD)
+	if (p->flags & PF_EXITING)
 		return;
 
 	/* Allocate buffer to track faults on a per-node basis */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
