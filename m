Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 639518D001E
	for <linux-mm@kvack.org>; Thu, 22 Nov 2012 17:51:57 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so6043409eek.14
        for <linux-mm@kvack.org>; Thu, 22 Nov 2012 14:51:56 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 33/33] sched: Track shared task's node groups and interleave their memory allocations
Date: Thu, 22 Nov 2012 23:49:54 +0100
Message-Id: <1353624594-1118-34-git-send-email-mingo@kernel.org>
In-Reply-To: <1353624594-1118-1-git-send-email-mingo@kernel.org>
References: <1353624594-1118-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

This patch shows the power of the shared/private distinction: in
the shared tasks active balancing function (sched_update_ideal_cpu_shared())
we are able to to build a per (shared) task node mask of the nodes that
it and its buddies occupy at the moment.

Private tasks on the other hand are not affected and continue to do
efficient node-local allocations.

There's two important special cases:

 - if a group of shared tasks fits on a single node. In this case
   the interleaving happens on a single bit, a single node and thus
   turns into nice node-local allocations.

 - if a large group spans the whole system: in this case the node
   masks will cover the whole system, and all memory gets evenly
   interleaved and available RAM bandwidth gets utilized. This is
   preferable to allocating memory assymetrically and overloading
   certain CPU links and running into their bandwidth limitations.

This patch, in combination with the private/shared buddies patch,
optimizes the "4x JVM", "single JVM" and "2x JVM" SPECjbb workloads
on a 4-node system produce almost completely perfect memory placement.

For example a 4-JVM workload on a 4-node, 32-CPU system has
this performance (8 SPECjbb warehouses per JVM):

 spec1.txt:           throughput =     177460.44 SPECjbb2005 bops
 spec2.txt:           throughput =     176175.08 SPECjbb2005 bops
 spec3.txt:           throughput =     175053.91 SPECjbb2005 bops
 spec4.txt:           throughput =     171383.52 SPECjbb2005 bops

Which is close to the hard binding performance figures.

while previously it would regress compared to mainline.

Mainline has the following 4x JVM performance:

 spec1.txt:           throughput =     157839.25 SPECjbb2005 bops
 spec2.txt:           throughput =     156969.15 SPECjbb2005 bops
 spec3.txt:           throughput =     157571.59 SPECjbb2005 bops
 spec4.txt:           throughput =     157873.86 SPECjbb2005 bops

So the patch brings a 12% speedup.

This placement idea came while discussing interleaving strategies
with Christoph Lameter.

Suggested-by: Christoph Lameter <cl@linux.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 kernel/sched/fair.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index ab4a7130..5cc3620 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -922,6 +922,10 @@ static int sched_update_ideal_cpu_shared(struct task_struct *p)
 			buddies++;
 		}
 		WARN_ON_ONCE(buddies > full_buddies);
+		if (buddies)
+			node_set(node, p->numa_policy.v.nodes);
+		else
+			node_clear(node, p->numa_policy.v.nodes);
 
 		/* Don't go to a node that is already at full capacity: */
 		if (buddies == full_buddies)
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
