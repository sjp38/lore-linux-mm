Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9A28A8E0038
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 15:46:33 -0500 (EST)
Received: by mail-yb1-f200.google.com with SMTP id r191so757637ybr.12
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 12:46:33 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r11sor8986033ywl.107.2019.01.07.12.46.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 07 Jan 2019 12:46:29 -0800 (PST)
Date: Mon, 7 Jan 2019 15:46:27 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: possible deadlock in __wake_up_common_lock
Message-ID: <20190107204627.GA25526@cmpxchg.org>
References: <000000000000f67ca2057e75bec3@google.com>
 <1194004c-f176-6253-a5fd-682472dccacc@suse.cz>
 <20190107095217.GB2861@worktop.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190107095217.GB2861@worktop.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, syzbot <syzbot+93d94a001cfbce9e60e1@syzkaller.appspotmail.com>, aarcange@redhat.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux@dominikbrodowski.net, mhocko@suse.com, rientjes@google.com, syzkaller-bugs@googlegroups.com, xieyisheng1@huawei.com, zhongjiang@huawei.com, Mel Gorman <mgorman@techsingularity.net>, Ingo Molnar <mingo@kernel.org>

On Mon, Jan 07, 2019 at 10:52:17AM +0100, Peter Zijlstra wrote:
> On Wed, Jan 02, 2019 at 01:51:01PM +0100, Vlastimil Babka wrote:
> > > -> #3 (&base->lock){-.-.}:
> > >         __raw_spin_lock_irqsave include/linux/spinlock_api_smp.h:110 [inline]
> > >         _raw_spin_lock_irqsave+0x99/0xd0 kernel/locking/spinlock.c:152
> > >         lock_timer_base+0xbb/0x2b0 kernel/time/timer.c:937
> > >         __mod_timer kernel/time/timer.c:1009 [inline]
> > >         mod_timer kernel/time/timer.c:1101 [inline]
> > >         add_timer+0x895/0x1490 kernel/time/timer.c:1137
> > >         __queue_delayed_work+0x249/0x380 kernel/workqueue.c:1533
> > >         queue_delayed_work_on+0x1a2/0x1f0 kernel/workqueue.c:1558
> > >         queue_delayed_work include/linux/workqueue.h:527 [inline]
> > >         schedule_delayed_work include/linux/workqueue.h:628 [inline]
> > >         psi_group_change kernel/sched/psi.c:485 [inline]
> > >         psi_task_change+0x3f1/0x5f0 kernel/sched/psi.c:534
> > >         psi_enqueue kernel/sched/stats.h:82 [inline]
> > >         enqueue_task kernel/sched/core.c:727 [inline]
> > >         activate_task+0x21a/0x430 kernel/sched/core.c:751
> > >         wake_up_new_task+0x527/0xd20 kernel/sched/core.c:2423
> > >         _do_fork+0x33b/0x11d0 kernel/fork.c:2247
> > >         kernel_thread+0x34/0x40 kernel/fork.c:2281
> > >         rest_init+0x28/0x372 init/main.c:409
> > >         arch_call_rest_init+0xe/0x1b
> > >         start_kernel+0x873/0x8ae init/main.c:741
> > >         x86_64_start_reservations+0x29/0x2b arch/x86/kernel/head64.c:470
> > >         x86_64_start_kernel+0x76/0x79 arch/x86/kernel/head64.c:451
> > >         secondary_startup_64+0xa4/0xb0 arch/x86/kernel/head_64.S:243
> 
> That thing is fairly new; I don't think we used to have this dependency
> prior to PSI.
> 
> Johannes, can we move that mod_timer out from under rq->lock? At worst
> we can use an irq_work to self-ipi.

Hm, so the splat says this:

wakeups take the pi lock
pi lock holders take the rq lock
rq lock holders take the timer base lock (thanks psi)
timer base lock holders take the zone lock (thanks kasan)
problem: now a zone lock holder wakes up kswapd

right? And we can break the chain from the VM or from psi.

I cannot say one is clearly cleaner than the other, though. With kasan
allocating from inside the basic timer code, those locks leak out from
kernel/* and contaminate the VM locking anyway.

Do you think the rq->lock -> base->lock ordering is likely to cause
issues elsewhere?

Something like this below seems to pass the smoke test. If we want to
go ahead with that, I'd test it properly and send it with a sign-off.

diff --git a/include/linux/psi_types.h b/include/linux/psi_types.h
index 2cf422db5d18..42e287139c31 100644
--- a/include/linux/psi_types.h
+++ b/include/linux/psi_types.h
@@ -1,6 +1,7 @@
 #ifndef _LINUX_PSI_TYPES_H
 #define _LINUX_PSI_TYPES_H
 
+#include <linux/irq_work.h>
 #include <linux/seqlock.h>
 #include <linux/types.h>
 
@@ -77,6 +78,7 @@ struct psi_group {
 	u64 last_update;
 	u64 next_update;
 	struct delayed_work clock_work;
+	struct irq_work clock_reviver;
 
 	/* Total stall times and sampled pressure averages */
 	u64 total[NR_PSI_STATES - 1];
diff --git a/kernel/sched/psi.c b/kernel/sched/psi.c
index f39958321293..9654de009250 100644
--- a/kernel/sched/psi.c
+++ b/kernel/sched/psi.c
@@ -165,6 +165,7 @@ static struct psi_group psi_system = {
 };
 
 static void psi_update_work(struct work_struct *work);
+static void psi_revive_clock(struct irq_work *work);
 
 static void group_init(struct psi_group *group)
 {
@@ -177,6 +178,7 @@ static void group_init(struct psi_group *group)
 	group->last_update = now;
 	group->next_update = now + psi_period;
 	INIT_DELAYED_WORK(&group->clock_work, psi_update_work);
+	init_irq_work(&group->clock_reviver, psi_revive_clock);
 	mutex_init(&group->stat_lock);
 }
 
@@ -399,6 +401,14 @@ static void psi_update_work(struct work_struct *work)
 	}
 }
 
+static void psi_revive_clock(struct irq_work *work)
+{
+	struct psi_group *group;
+
+	group = container_of(work, struct psi_group, clock_reviver);
+	schedule_delayed_work(&group->clock_work, PSI_FREQ);
+}
+
 static void record_times(struct psi_group_cpu *groupc, int cpu,
 			 bool memstall_tick)
 {
@@ -484,8 +494,14 @@ static void psi_group_change(struct psi_group *group, int cpu,
 
 	write_seqcount_end(&groupc->seq);
 
+	/*
+	 * We cannot modify workqueues or timers with the rq lock held
+	 * here. If the clock has stopped due to a lack of activity in
+	 * the past and needs reviving, go through an IPI to wake it
+	 * back up. In most cases, the work should already be pending.
+	 */
 	if (!delayed_work_pending(&group->clock_work))
-		schedule_delayed_work(&group->clock_work, PSI_FREQ);
+		irq_work_queue(&group->clock_reviver);
 }
 
 static struct psi_group *iterate_groups(struct task_struct *task, void **iter)
