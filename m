Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 9E5FC6B0088
	for <linux-mm@kvack.org>; Thu, 25 Oct 2012 09:10:26 -0400 (EDT)
Message-Id: <20121025124834.651572752@chello.nl>
Date: Thu, 25 Oct 2012 14:16:46 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 29/31] sched, numa, mm: Add NUMA_MIGRATION feature flag
References: <20121025121617.617683848@chello.nl>
Content-Disposition: inline; filename=0029-sched-numa-mm-Add-NUMA_MIGRATION-feature-flag.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>

From: Ingo Molnar <mingo@kernel.org>

After this patch, doing:

   # echo NO_NUMA_MIGRATION > /sys/kernel/debug/sched_features

Will turn off the NUMA placement logic/policy - but keeps the
working set sampling faults in place.

This allows the debugging of the WSS facility, by using it
but keeping vanilla, non-NUMA CPU and memory placement
policies.

Default enabled. Generates on extra code on !CONFIG_SCHED_DEBUG.

Signed-off-by: Ingo Molnar <mingo@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
---
 kernel/sched/core.c     |    3 +++
 kernel/sched/features.h |    3 +++
 2 files changed, 6 insertions(+)

Index: tip/kernel/sched/core.c
===================================================================
--- tip.orig/kernel/sched/core.c
+++ tip/kernel/sched/core.c
@@ -6002,6 +6002,9 @@ void sched_setnode(struct task_struct *p
 	int on_rq, running;
 	struct rq *rq;
 
+	if (!sched_feat(NUMA_MIGRATION))
+		return;
+
 	rq = task_rq_lock(p, &flags);
 	on_rq = p->on_rq;
 	running = task_current(rq, p);
Index: tip/kernel/sched/features.h
===================================================================
--- tip.orig/kernel/sched/features.h
+++ tip/kernel/sched/features.h
@@ -63,7 +63,10 @@ SCHED_FEAT(RT_RUNTIME_SHARE, true)
 SCHED_FEAT(LB_MIN, false)
 
 #ifdef CONFIG_SCHED_NUMA
+/* Do the working set probing faults: */
 SCHED_FEAT(NUMA,           true)
+/* Do actual migration/placement based on the working set information: */
+SCHED_FEAT(NUMA_MIGRATION, true)
 SCHED_FEAT(NUMA_HOT,       true)
 SCHED_FEAT(NUMA_TTWU_BIAS, false)
 SCHED_FEAT(NUMA_TTWU_TO,   false)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
