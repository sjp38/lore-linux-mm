Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id AE2796B00EC
	for <linux-mm@kvack.org>; Mon, 26 Mar 2012 14:27:31 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 25/39] autonuma: fix selecting idle sibling
Date: Mon, 26 Mar 2012 19:46:12 +0200
Message-Id: <1332783986-24195-26-git-send-email-aarcange@redhat.com>
In-Reply-To: <1332783986-24195-1-git-send-email-aarcange@redhat.com>
References: <1332783986-24195-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>

From: Hillf Danton <dhillf@gmail.com>

Autonuma cpu is selected only from the idle group without the requirement that
each cpu in the group is autonuma for given task.

Signed-off-by: Hillf Danton <dhillf@gmail.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 kernel/sched/fair.c |   25 +++++++++++++------------
 1 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index bf109cc..0d2fe26 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -2642,7 +2642,6 @@ static int select_idle_sibling(struct task_struct *p, int target)
 	struct sched_domain *sd;
 	struct sched_group *sg;
 	int i;
-	bool numa;
 
 	/*
 	 * If the task is going to be woken-up on this cpu and if it is
@@ -2662,8 +2661,6 @@ static int select_idle_sibling(struct task_struct *p, int target)
 	/*
 	 * Otherwise, iterate the domains and find an elegible idle cpu.
 	 */
-	numa = true;
-again:
 	sd = rcu_dereference(per_cpu(sd_llc, target));
 	for_each_lower_domain(sd) {
 		sg = sd->groups;
@@ -2673,22 +2670,26 @@ again:
 				goto next;
 
 			for_each_cpu(i, sched_group_cpus(sg)) {
-				if (!idle_cpu(i) ||
-				    (numa && !task_autonuma_cpu(p, i)))
+				if (!idle_cpu(i))
 					goto next;
 			}
 
-			target = cpumask_first_and(sched_group_cpus(sg),
-					tsk_cpus_allowed(p));
-			goto done;
+			cpu = -1;
+			for_each_cpu_and(i, sched_group_cpus(sg),
+						tsk_cpus_allowed(p)) {
+				/* Find autonuma cpu only in idle group */
+				if (task_autonuma_cpu(p, i)) {
+					target = i;
+					goto done;
+				}
+				if (cpu == -1)
+					cpu = i;
+			}
+			target = cpu;
 next:
 			sg = sg->next;
 		} while (sg != sd->groups);
 	}
-	if (numa) {
-		numa = false;
-		goto again;
-	}
 done:
 	return target;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
