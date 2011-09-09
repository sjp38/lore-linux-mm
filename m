Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A7F6A6B0201
	for <linux-mm@kvack.org>; Fri,  9 Sep 2011 06:57:34 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 04/14] mm: allow PF_MEMALLOC from softirq context
Date: Fri,  9 Sep 2011 11:57:15 +0100
Message-Id: <1315565845-16857-5-git-send-email-mgorman@suse.de>
In-Reply-To: <1315565845-16857-1-git-send-email-mgorman@suse.de>
References: <1315565845-16857-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>

This is needed to allow network softirq packet processing to make
use of PF_MEMALLOC.

Currently softirq context cannot use PF_MEMALLOC due to it not being
associated with a task, and therefore not having task flags to fiddle
with - thus the gfp to alloc flag mapping ignores the task flags when
in interrupts (hard or soft) context.

Allowing softirqs to make use of PF_MEMALLOC therefore requires some
trickery.  We basically borrow the task flags from whatever process
happens to be preempted by the softirq.

So we modify the gfp to alloc flags mapping to not exclude task flags
in softirq context, and modify the softirq code to save, clear and
restore the PF_MEMALLOC flag.

The save and clear, ensures the preempted task's PF_MEMALLOC flag
doesn't leak into the softirq. The restore ensures a softirq's
PF_MEMALLOC flag cannot leak back into the preempted process.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/sched.h |    7 +++++++
 kernel/softirq.c      |    3 +++
 mm/page_alloc.c       |    5 ++++-
 3 files changed, 14 insertions(+), 1 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 4ac2c05..791536c 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1869,6 +1869,13 @@ static inline void rcu_copy_process(struct task_struct *p)
 
 #endif
 
+static inline void tsk_restore_flags(struct task_struct *p,
+				     unsigned long pflags, unsigned long mask)
+{
+	p->flags &= ~mask;
+	p->flags |= pflags & mask;
+}
+
 #ifdef CONFIG_SMP
 extern void do_set_cpus_allowed(struct task_struct *p,
 			       const struct cpumask *new_mask);
diff --git a/kernel/softirq.c b/kernel/softirq.c
index fca82c3..f773afe 100644
--- a/kernel/softirq.c
+++ b/kernel/softirq.c
@@ -210,6 +210,8 @@ asmlinkage void __do_softirq(void)
 	__u32 pending;
 	int max_restart = MAX_SOFTIRQ_RESTART;
 	int cpu;
+	unsigned long pflags = current->flags;
+	current->flags &= ~PF_MEMALLOC;
 
 	pending = local_softirq_pending();
 	account_system_vtime(current);
@@ -265,6 +267,7 @@ restart:
 
 	account_system_vtime(current);
 	__local_bh_enable(SOFTIRQ_OFFSET);
+	tsk_restore_flags(current, pflags, PF_MEMALLOC);
 }
 
 #ifndef __ARCH_HAS_DO_SOFTIRQ
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 03fd18c..31e0eb2 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2060,7 +2060,10 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
 	if (likely(!(gfp_mask & __GFP_NOMEMALLOC))) {
 		if (gfp_mask & __GFP_MEMALLOC)
 			alloc_flags |= ALLOC_NO_WATERMARKS;
-		else if (likely(!(gfp_mask & __GFP_NOMEMALLOC)) && !in_interrupt())
+		else if (!in_irq() && (current->flags & PF_MEMALLOC))
+			alloc_flags |= ALLOC_NO_WATERMARKS;
+		else if (!in_interrupt() &&
+				unlikely(test_thread_flag(TIF_MEMDIE)))
 			alloc_flags |= ALLOC_NO_WATERMARKS;
 	}
 
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
