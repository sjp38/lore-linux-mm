Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f174.google.com (mail-pf0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 88C336B0005
	for <linux-mm@kvack.org>; Tue, 19 Jan 2016 23:37:06 -0500 (EST)
Received: by mail-pf0-f174.google.com with SMTP id q63so192947438pfb.1
        for <linux-mm@kvack.org>; Tue, 19 Jan 2016 20:37:06 -0800 (PST)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com. [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id v76si46800657pfi.96.2016.01.19.20.37.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jan 2016 20:37:05 -0800 (PST)
Received: by mail-pa0-x22a.google.com with SMTP id cy9so463426954pac.0
        for <linux-mm@kvack.org>; Tue, 19 Jan 2016 20:37:05 -0800 (PST)
From: gavin.guo@canonical.com
Subject: [PATCH V3] sched/numa: Fix use-after-free bug in the task_numa_compare
Date: Wed, 20 Jan 2016 12:36:58 +0800
Message-Id: <1453264618-17645-1-git-send-email-gavin.guo@canonical.com>
In-Reply-To: <20160119093535.GA2458@gmail.com>
References: <20160119093535.GA2458@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, mingo@redhat.com
Cc: linux-mm@kvack.org, jay.vosburgh@canonical.com, liang.chen@canonical.com, mgorman@suse.de, peterz@infradead.org, riel@redhat.com

From: Gavin Guo <gavin.guo@canonical.com>

The following message can be observed on the Ubuntu v3.13.0-65 with KASan
backported:

==================================================================
BUG: KASan: use after free in task_numa_find_cpu+0x64c/0x890 at addr ffff880dd393ecd8
Read of size 8 by task qemu-system-x86/3998900
=============================================================================
BUG kmalloc-128 (Tainted: G    B        ): kasan: bad access detected
-----------------------------------------------------------------------------

INFO: Allocated in task_numa_fault+0xc1b/0xed0 age=41980 cpu=18 pid=3998890
	__slab_alloc+0x4f8/0x560
	__kmalloc+0x1eb/0x280
	task_numa_fault+0xc1b/0xed0
	do_numa_page+0x192/0x200
	handle_mm_fault+0x808/0x1160
	__do_page_fault+0x218/0x750
	do_page_fault+0x1a/0x70
	page_fault+0x28/0x30
	SyS_poll+0x66/0x1a0
	system_call_fastpath+0x1a/0x1f
INFO: Freed in task_numa_free+0x1d2/0x200 age=62 cpu=18 pid=0
	__slab_free+0x2ab/0x3f0
	kfree+0x161/0x170
	task_numa_free+0x1d2/0x200
	finish_task_switch+0x1d2/0x210
	__schedule+0x5d4/0xc60
	schedule_preempt_disabled+0x40/0xc0
	cpu_startup_entry+0x2da/0x340
	start_secondary+0x28f/0x360
INFO: Slab 0xffffea00374e4f00 objects=37 used=17 fp=0xffff880dd393ecb0 flags=0x6ffff0000004080
INFO: Object 0xffff880dd393ecb0 @offset=11440 fp=0xffff880dd393f700

Bytes b4 ffff880dd393eca0: 0c 00 00 00 18 00 00 00 af 63 3a 04 01 00 00 00  .........c:.....
Object ffff880dd393ecb0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Object ffff880dd393ecc0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Object ffff880dd393ecd0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Object ffff880dd393ece0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Object ffff880dd393ecf0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Object ffff880dd393ed00: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Object ffff880dd393ed10: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Object ffff880dd393ed20: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5  kkkkkkkkkkkkkkk.
CPU: 61 PID: 3998900 Comm: qemu-system-x86 Tainted: G    B         3.13.0-65-generic #105
Hardware name: Supermicro X8QB6/X8QB6, BIOS 2.0c    06/11/2
 ffffea00374e4f00 ffff8816c572b420 ffffffff81a6ce35 ffff88045f00f500
 ffff8816c572b450 ffffffff81244aed ffff88045f00f500 ffffea00374e4f00
 ffff880dd393ecb0 0000000000000012 ffff8816c572b478 ffffffff8124ac36
Call Trace:
 [<ffffffff81a6ce35>] dump_stack+0x45/0x56
 [<ffffffff81244aed>] print_trailer+0xfd/0x170
 [<ffffffff8124ac36>] object_err+0x36/0x40
 [<ffffffff8124cbf9>] kasan_report_error+0x1e9/0x3a0
 [<ffffffff8124d260>] kasan_report+0x40/0x50
 [<ffffffff810dda7c>] ? task_numa_find_cpu+0x64c/0x890
 [<ffffffff8124bee9>] __asan_load8+0x69/0xa0
 [<ffffffff814f5c38>] ? find_next_bit+0xd8/0x120
 [<ffffffff810dda7c>] task_numa_find_cpu+0x64c/0x890
 [<ffffffff810de16c>] task_numa_migrate+0x4ac/0x7b0
 [<ffffffff810de523>] numa_migrate_preferred+0xb3/0xc0
 [<ffffffff810e0b88>] task_numa_fault+0xb88/0xed0
 [<ffffffff8120ef02>] do_numa_page+0x192/0x200
 [<ffffffff81211038>] handle_mm_fault+0x808/0x1160
 [<ffffffff810d7dbd>] ? sched_clock_cpu+0x10d/0x160
 [<ffffffff81068c52>] ? native_load_tls+0x82/0xa0
 [<ffffffff81a7bd68>] __do_page_fault+0x218/0x750
 [<ffffffff810c2186>] ? hrtimer_try_to_cancel+0x76/0x160
 [<ffffffff81a6f5e7>] ? schedule_hrtimeout_range_clock.part.24+0xf7/0x1c0
 [<ffffffff81a7c2ba>] do_page_fault+0x1a/0x70
 [<ffffffff81a772e8>] page_fault+0x28/0x30
 [<ffffffff8128cbd4>] ? do_sys_poll+0x1c4/0x6d0
 [<ffffffff810e64f6>] ? enqueue_task_fair+0x4b6/0xaa0
 [<ffffffff810233c9>] ? sched_clock+0x9/0x10
 [<ffffffff810cf70a>] ? resched_task+0x7a/0xc0
 [<ffffffff810d0663>] ? check_preempt_curr+0xb3/0x130
 [<ffffffff8128b5c0>] ? poll_select_copy_remaining+0x170/0x170
 [<ffffffff810d3bc0>] ? wake_up_state+0x10/0x20
 [<ffffffff8112a28f>] ? drop_futex_key_refs.isra.14+0x1f/0x90
 [<ffffffff8112d40e>] ? futex_requeue+0x3de/0xba0
 [<ffffffff8112e49e>] ? do_futex+0xbe/0x8f0
 [<ffffffff81022c89>] ? read_tsc+0x9/0x20
 [<ffffffff8111bd9d>] ? ktime_get_ts+0x12d/0x170
 [<ffffffff8108f699>] ? timespec_add_safe+0x59/0xe0
 [<ffffffff8128d1f6>] SyS_poll+0x66/0x1a0
 [<ffffffff81a830dd>] system_call_fastpath+0x1a/0x1f
Memory state around the buggy address:
 ffff880dd393eb80: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
 ffff880dd393ec00: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
>ffff880dd393ec80: fc fc fc fc fc fc fb fb fb fb fb fb fb fb fb fb
                                                    ^
 ffff880dd393ed00: fb fb fb fb fb fb fc fc fc fc fc fc fc fc fc fc
 ffff880dd393ed80: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
==================================================================

As commit 1effd9f19324 ("sched/numa: Fix unsafe get_task_struct() in
task_numa_assign()") points out, the rcu_read_lock() cannot protect the
task_struct from being freed in the finish_task_switch(). And the bug
happens in the process of calculation of imp which requires the access of
p->numa_faults being freed in the following path:

do_exit()
        current->flags |= PF_EXITING;
    release_task()
        ~~delayed_put_task_struct()~~
    schedule()
    ...
    ...
rq->curr = next;
    context_switch()
        finish_task_switch()
            put_task_struct()
                __put_task_struct()
		    task_numa_free()

The fix here to get_task_struct() early before end of dst_rq->lock to
protect the calculation process and also put_task_struct() in the
corresponding point if finally the dst_rq->curr somehow cannot be
assigned.

Additional credit to Liang Chen who helped fix the error logic and add the
put_task_struct() to the place it missed.

v1->v2:
- Fix coding style suggested by Peter Zijlstra.

v2->v3:
- Additional credit to Liang Chen suggested by Ingo Molnar.

Signed-off-by: Gavin Guo <gavin.guo@canonical.com>
---
Currently, the bug still cannot be observed on the upstream kernel with
KASan enabled.  However, even in the Ubuntu v3.13.0-65, we took about 1
week or more to reproduce the bug. After comparing the source between
v3.13.0-65 and latest mainline kernel, there seems not much difference in
the logic of task_numa_compare. So, it has possibilities to happen in the
tricky case.
---
 kernel/sched/fair.c | 30 +++++++++++++++++++++++-------
 1 file changed, 23 insertions(+), 7 deletions(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 1926606..56b7d4b 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -1220,8 +1220,6 @@ static void task_numa_assign(struct task_numa_env *env,
 {
 	if (env->best_task)
 		put_task_struct(env->best_task);
-	if (p)
-		get_task_struct(p);
 
 	env->best_task = p;
 	env->best_imp = imp;
@@ -1289,20 +1287,30 @@ static void task_numa_compare(struct task_numa_env *env,
 	long imp = env->p->numa_group ? groupimp : taskimp;
 	long moveimp = imp;
 	int dist = env->dist;
+	bool assigned = false;
 
 	rcu_read_lock();
 
 	raw_spin_lock_irq(&dst_rq->lock);
 	cur = dst_rq->curr;
 	/*
-	 * No need to move the exiting task, and this ensures that ->curr
-	 * wasn't reaped and thus get_task_struct() in task_numa_assign()
-	 * is safe under RCU read lock.
-	 * Note that rcu_read_lock() itself can't protect from the final
-	 * put_task_struct() after the last schedule().
+	 * No need to move the exiting task or idle task.
 	 */
 	if ((cur->flags & PF_EXITING) || is_idle_task(cur))
 		cur = NULL;
+	else {
+		/*
+		 * The task_struct must be protected here to protect the
+		 * p->numa_faults access in the task_weight since the
+		 * numa_faults could already be freed in the following path:
+		 * finish_task_switch()
+		 *     --> put_task_struct()
+		 *         --> __put_task_struct()
+		 *             --> task_numa_free()
+		 */
+		get_task_struct(cur);
+	}
+
 	raw_spin_unlock_irq(&dst_rq->lock);
 
 	/*
@@ -1386,6 +1394,7 @@ balance:
 		 */
 		if (!load_too_imbalanced(src_load, dst_load, env)) {
 			imp = moveimp - 1;
+			put_task_struct(cur);
 			cur = NULL;
 			goto assign;
 		}
@@ -1411,9 +1420,16 @@ balance:
 		env->dst_cpu = select_idle_sibling(env->p, env->dst_cpu);
 
 assign:
+	assigned = true;
 	task_numa_assign(env, cur, imp);
 unlock:
 	rcu_read_unlock();
+	/*
+	 * The dst_rq->curr isn't assigned. The protection for task_struct is
+	 * finished.
+	 */
+	if (cur && !assigned)
+		put_task_struct(cur);
 }
 
 static void task_numa_find_cpu(struct task_numa_env *env,
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
