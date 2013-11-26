Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f41.google.com (mail-qe0-f41.google.com [209.85.128.41])
	by kanga.kvack.org (Postfix) with ESMTP id 5AB456B0075
	for <linux-mm@kvack.org>; Tue, 26 Nov 2013 09:03:56 -0500 (EST)
Received: by mail-qe0-f41.google.com with SMTP id gh4so3163167qeb.0
        for <linux-mm@kvack.org>; Tue, 26 Nov 2013 06:03:56 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id ik2si11269362qab.60.2013.11.26.06.03.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Nov 2013 06:03:55 -0800 (PST)
Date: Tue, 26 Nov 2013 15:03:41 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: [PATCH] cpuset: Fix memory allocator deadlock
Message-ID: <20131126140341.GL10022@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>, Tejun Heo <tj@kernel.org>
Cc: John Stultz <john.stultz@linaro.org>, Mel Gorman <mgorman@suse.de>, Juri Lelli <juri.lelli@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Juri hit the below lockdep report:

[    4.303391] ======================================================
[    4.303392] [ INFO: SOFTIRQ-safe -> SOFTIRQ-unsafe lock order detected ]
[    4.303394] 3.12.0-dl-peterz+ #144 Not tainted
[    4.303395] ------------------------------------------------------
[    4.303397] kworker/u4:3/689 [HC0[0]:SC0[0]:HE0:SE1] is trying to acquire:
[    4.303399]  (&p->mems_allowed_seq){+.+...}, at: [<ffffffff8114e63c>] new_slab+0x6c/0x290
[    4.303417]
[    4.303417] and this task is already holding:
[    4.303418]  (&(&q->__queue_lock)->rlock){..-...}, at: [<ffffffff812d2dfb>] blk_execute_rq_nowait+0x5b/0x100
[    4.303431] which would create a new lock dependency:
[    4.303432]  (&(&q->__queue_lock)->rlock){..-...} -> (&p->mems_allowed_seq){+.+...}
[    4.303436]

[    4.303898] the dependencies between the lock to be acquired and SOFTIRQ-irq-unsafe lock:
[    4.303918] -> (&p->mems_allowed_seq){+.+...} ops: 2762 {
[    4.303922]    HARDIRQ-ON-W at:
[    4.303923]                     [<ffffffff8108ab9a>] __lock_acquire+0x65a/0x1ff0
[    4.303926]                     [<ffffffff8108cbe3>] lock_acquire+0x93/0x140
[    4.303929]                     [<ffffffff81063dd6>] kthreadd+0x86/0x180
[    4.303931]                     [<ffffffff816ded6c>] ret_from_fork+0x7c/0xb0
[    4.303933]    SOFTIRQ-ON-W at:
[    4.303933]                     [<ffffffff8108abcc>] __lock_acquire+0x68c/0x1ff0
[    4.303935]                     [<ffffffff8108cbe3>] lock_acquire+0x93/0x140
[    4.303940]                     [<ffffffff81063dd6>] kthreadd+0x86/0x180
[    4.303955]                     [<ffffffff816ded6c>] ret_from_fork+0x7c/0xb0
[    4.303959]    INITIAL USE at:
[    4.303960]                    [<ffffffff8108a884>] __lock_acquire+0x344/0x1ff0
[    4.303963]                    [<ffffffff8108cbe3>] lock_acquire+0x93/0x140
[    4.303966]                    [<ffffffff81063dd6>] kthreadd+0x86/0x180
[    4.303969]                    [<ffffffff816ded6c>] ret_from_fork+0x7c/0xb0
[    4.303972]  }

Which reports that we take mems_allowed_seq with interrupts enabled. A
little digging found that this can only be from
cpuset_change_task_nodemask().

This is an actual deadlock because an interrupt doing an allocation will
hit get_mems_allowed()->...->__read_seqcount_begin(), which will spin
forever waiting for the write side to complete.

Cc: John Stultz <john.stultz@linaro.org>
Cc: Mel Gorman <mgorman@suse.de>
Reported-by: Juri Lelli <juri.lelli@gmail.com>
Signed-off-by: Peter Zijlstra <peterz@infradead.org>
---
 kernel/cpuset.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 6bf981e13c43..4772034b4b17 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -1033,8 +1033,10 @@ static void cpuset_change_task_nodemask(struct task_struct *tsk,
 	need_loop = task_has_mempolicy(tsk) ||
 			!nodes_intersects(*newmems, tsk->mems_allowed);
 
-	if (need_loop)
+	if (need_loop) {
+		local_irq_disable();
 		write_seqcount_begin(&tsk->mems_allowed_seq);
+	}
 
 	nodes_or(tsk->mems_allowed, tsk->mems_allowed, *newmems);
 	mpol_rebind_task(tsk, newmems, MPOL_REBIND_STEP1);
@@ -1042,8 +1044,10 @@ static void cpuset_change_task_nodemask(struct task_struct *tsk,
 	mpol_rebind_task(tsk, newmems, MPOL_REBIND_STEP2);
 	tsk->mems_allowed = *newmems;
 
-	if (need_loop)
+	if (need_loop) {
 		write_seqcount_end(&tsk->mems_allowed_seq);
+		local_irq_enable();
+	}
 
 	task_unlock(tsk);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
