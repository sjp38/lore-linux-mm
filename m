Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id BEF4B6B0072
	for <linux-mm@kvack.org>; Thu, 12 Jul 2012 02:40:42 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 04/16] mm: allow PF_MEMALLOC from softirq context
Date: Thu, 12 Jul 2012 07:40:20 +0100
Message-Id: <1342075232-29267-5-git-send-email-mgorman@suse.de>
In-Reply-To: <1342075232-29267-1-git-send-email-mgorman@suse.de>
References: <1342075232-29267-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>, Eric Dumazet <eric.dumazet@gmail.com>, Sebastian Andrzej Siewior <sebastian@breakpoint.cc>, Mel Gorman <mgorman@suse.de>

This is needed to allow network softirq packet processing to make
use of PF_MEMALLOC.

Currently softirq context cannot use PF_MEMALLOC due to it not being
associated with a task, and therefore not having task flags to fiddle
with - thus the gfp to alloc flag mapping ignores the task flags when
in interrupts (hard or soft) context.

Allowing softirqs to make use of PF_MEMALLOC therefore requires some
trickery. This patch borrows the task flags from whatever process happens
to be preempted by the softirq. It then modifies the gfp to alloc flags
mapping to not exclude task flags in softirq context, and modify the
softirq code to save, clear and restore the PF_MEMALLOC flag.

The save and clear, ensures the preempted task's PF_MEMALLOC flag
doesn't leak into the softirq. The restore ensures a softirq's
PF_MEMALLOC flag cannot leak back into the preempted process. This
should be safe due to the following reasons

Softirqs can run on multiple CPUs sure but the same task should not be
	executing the same softirq code. Neither should the softirq
	handler be preempted by any other softirq handler so the flags
	should not leak to an unrelated softirq.

Softirqs re-enable hardware interrupts in __do_softirq() so can be
	preempted by hardware interrupts so PF_MEMALLOC is inherited
	by the hard IRQ. However, this is similar to a process in
	reclaim being preempted by a hardirq. While PF_MEMALLOC is
	set, gfp_to_alloc_flags() distinguishes between hard and
	soft irqs and avoids giving a hardirq the ALLOC_NO_WATERMARKS
	flag.

If the softirq is deferred to ksoftirq then its flags may be used
        instead of a normal tasks but as the softirq cannot be preempted,
        the PF_MEMALLOC flag does not leak to other code by accident.

[davem@davemloft.net: Document why PF_MEMALLOC is safe]
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/sched.h |    7 +++++++
 kernel/softirq.c      |    9 +++++++++
 mm/page_alloc.c       |    6 +++++-
 3 files changed, 21 insertions(+), 1 deletion(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 901bc98..f6d4324 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1910,6 +1910,13 @@ static inline void rcu_copy_process(struct task_struct *p)
 
 #endif
 
+static inline void tsk_restore_flags(struct task_struct *task,
+				unsigned long orig_flags, unsigned long flags)
+{
+	task->flags &= ~flags;
+	task->flags |= orig_flags & flags;
+}
+
 #ifdef CONFIG_SMP
 extern void do_set_cpus_allowed(struct task_struct *p,
 			       const struct cpumask *new_mask);
diff --git a/kernel/softirq.c b/kernel/softirq.c
index 671f959..b73e681 100644
--- a/kernel/softirq.c
+++ b/kernel/softirq.c
@@ -210,6 +210,14 @@ asmlinkage void __do_softirq(void)
 	__u32 pending;
 	int max_restart = MAX_SOFTIRQ_RESTART;
 	int cpu;
+	unsigned long old_flags = current->flags;
+
+	/*
+	 * Mask out PF_MEMALLOC s current task context is borrowed for the
+	 * softirq. A softirq handled such as network RX might set PF_MEMALLOC
+	 * again if the socket is related to swap
+	 */
+	current->flags &= ~PF_MEMALLOC;
 
 	pending = local_softirq_pending();
 	account_system_vtime(current);
@@ -265,6 +273,7 @@ restart:
 
 	account_system_vtime(current);
 	__local_bh_enable(SOFTIRQ_OFFSET);
+	tsk_restore_flags(current, old_flags, PF_MEMALLOC);
 }
 
 #ifndef __ARCH_HAS_DO_SOFTIRQ
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ace51cc..f19c724 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2268,7 +2268,11 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
 	if (likely(!(gfp_mask & __GFP_NOMEMALLOC))) {
 		if (gfp_mask & __GFP_MEMALLOC)
 			alloc_flags |= ALLOC_NO_WATERMARKS;
-		else if (likely(!(gfp_mask & __GFP_NOMEMALLOC)) && !in_interrupt())
+		else if (in_serving_softirq() && (current->flags & PF_MEMALLOC))
+			alloc_flags |= ALLOC_NO_WATERMARKS;
+		else if (!in_interrupt() &&
+				((current->flags & PF_MEMALLOC) ||
+				 unlikely(test_thread_flag(TIF_MEMDIE))))
 			alloc_flags |= ALLOC_NO_WATERMARKS;
 	}
 
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
