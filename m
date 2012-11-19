Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id AF8B86B007D
	for <linux-mm@kvack.org>; Sun, 18 Nov 2012 21:15:44 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so3182484eek.14
        for <linux-mm@kvack.org>; Sun, 18 Nov 2012 18:15:44 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 10/27] sched: Make find_busiest_queue() a method
Date: Mon, 19 Nov 2012 03:14:27 +0100
Message-Id: <1353291284-2998-11-git-send-email-mingo@kernel.org>
In-Reply-To: <1353291284-2998-1-git-send-email-mingo@kernel.org>
References: <1353291284-2998-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

Its a bit awkward but it was the least painful means of modifying the
queue selection. Used in a later patch to conditionally use a random
queue.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Paul Turner <pjt@google.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>
Link: http://lkml.kernel.org/n/tip-lfpez319yryvdhwqfqrh99f2@git.kernel.org
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 kernel/sched/fair.c | 20 ++++++++++++--------
 1 file changed, 12 insertions(+), 8 deletions(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 59e072b..511fbb8 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -3600,6 +3600,9 @@ struct lb_env {
 	unsigned int		loop;
 	unsigned int		loop_break;
 	unsigned int		loop_max;
+
+	struct rq *		(*find_busiest_queue)(struct lb_env *,
+						      struct sched_group *);
 };
 
 /*
@@ -4779,13 +4782,14 @@ static int load_balance(int this_cpu, struct rq *this_rq,
 	struct cpumask *cpus = __get_cpu_var(load_balance_tmpmask);
 
 	struct lb_env env = {
-		.sd		= sd,
-		.dst_cpu	= this_cpu,
-		.dst_rq		= this_rq,
-		.dst_grpmask    = sched_group_cpus(sd->groups),
-		.idle		= idle,
-		.loop_break	= sched_nr_migrate_break,
-		.cpus		= cpus,
+		.sd		    = sd,
+		.dst_cpu	    = this_cpu,
+		.dst_rq		    = this_rq,
+		.dst_grpmask        = sched_group_cpus(sd->groups),
+		.idle		    = idle,
+		.loop_break	    = sched_nr_migrate_break,
+		.cpus		    = cpus,
+		.find_busiest_queue = find_busiest_queue,
 	};
 
 	cpumask_copy(cpus, cpu_active_mask);
@@ -4804,7 +4808,7 @@ redo:
 		goto out_balanced;
 	}
 
-	busiest = find_busiest_queue(&env, group);
+	busiest = env.find_busiest_queue(&env, group);
 	if (!busiest) {
 		schedstat_inc(sd, lb_nobusyq[idle]);
 		goto out_balanced;
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
