Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E54B76B022E
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 08:02:58 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o58C2rvw016146
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 8 Jun 2010 21:02:53 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0B52945DE57
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 21:02:53 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id DED9E45DE4E
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 21:02:52 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C004CE08003
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 21:02:52 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6D4041DB8038
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 21:02:52 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 09/10] oom: filter tasks not sharing the same cpuset
In-Reply-To: <20100608204621.767A.A69D9226@jp.fujitsu.com>
References: <20100608204621.767A.A69D9226@jp.fujitsu.com>
Message-Id: <20100608210148.7695.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  8 Jun 2010 21:02:51 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

From: David Rientjes <rientjes@google.com>

Tasks that do not share the same set of allowed nodes with the task that
triggered the oom should not be considered as candidates for oom kill.

Tasks in other cpusets with a disjoint set of mems would be unfairly
penalized otherwise because of oom conditions elsewhere; an extreme
example could unfairly kill all other applications on the system if a
single task in a user's cpuset sets itself to OOM_DISABLE and then uses
more memory than allowed.

Killing tasks outside of current's cpuset rarely would free memory for
current anyway.  To use a sane heuristic, we must ensure that killing a
task would likely free memory for current and avoid needlessly killing
others at all costs just because their potential memory freeing is
unknown.  It is better to kill current than another task needlessly.

kosaki: a historical interlude...

We applied the exactly same patch in 2005:

	: commit ef08e3b4981aebf2ba9bd7025ef7210e8eec07ce
	: Author: Paul Jackson <pj@sgi.com>
	: Date:   Tue Sep 6 15:18:13 2005 -0700
	:
	: [PATCH] cpusets: confine oom_killer to mem_exclusive cpuset
	:
	: Now the real motivation for this cpuset mem_exclusive patch series seems
	: trivial.
	:
	: This patch keeps a task in or under one mem_exclusive cpuset from provoking an
	: oom kill of a task under a non-overlapping mem_exclusive cpuset.  Since only
	: interrupt and GFP_ATOMIC allocations are allowed to escape mem_exclusive
	: containment, there is little to gain from oom killing a task under a
	: non-overlapping mem_exclusive cpuset, as almost all kernel and user memory
	: allocation must come from disjoint memory nodes.
	:
	: This patch enables configuring a system so that a runaway job under one
	: mem_exclusive cpuset cannot cause the killing of a job in another such cpuset
	: that might be using very high compute and memory resources for a prolonged
	: time.

And we changed it to current logic in 2006

	: commit 7887a3da753e1ba8244556cc9a2b38c815bfe256
	: Author: Nick Piggin <npiggin@suse.de>
	: Date:   Mon Sep 25 23:31:29 2006 -0700
	:
	: [PATCH] oom: cpuset hint
	:
	: cpuset_excl_nodes_overlap does not always indicate that killing a task will
	: not free any memory we for us.  For example, we may be asking for an
	: allocation from _anywhere_ in the machine, or the task in question may be
	: pinning memory that is outside its cpuset.  Fix this by just causing
	: cpuset_excl_nodes_overlap to reduce the badness rather than disallow it.

And we haven't get the explanation why this patch doesn't reintroduced
an old issue. but I don't refuse a patch if it have multiple ack.

Acked-by: Rik van Riel <riel@redhat.com>
Acked-by: Nick Piggin <npiggin@suse.de>
Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: David Rientjes <rientjes@google.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> [add to
care of oom_kill_allocating_task case and dump_tasks]
---
 mm/oom_kill.c |   16 +++++++---------
 1 files changed, 7 insertions(+), 9 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 599f977..f45ac18 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -35,7 +35,7 @@ int sysctl_oom_dump_tasks = 1;
 static DEFINE_SPINLOCK(zone_scan_lock);
 
 /*
- * Is all threads of the target process nodes overlap ours?
+ * Do all threads of the target process overlap our allowed nodes?
  */
 static int has_intersects_mems_allowed(struct task_struct *p)
 {
@@ -181,14 +181,6 @@ unsigned long oom_badness(struct task_struct *p, unsigned long uptime)
 		points /= 4;
 
 	/*
-	 * If p's nodes don't overlap ours, it may still help to kill p
-	 * because p may have allocated or otherwise mapped memory on
-	 * this node before. However it will be less likely.
-	 */
-	if (!has_intersects_mems_allowed(p))
-		points /= 8;
-
-	/*
 	 * Adjust the score by oom_adj.
 	 */
 	if (oom_adj) {
@@ -259,6 +251,10 @@ static int oom_unkillable(struct task_struct *p, struct mem_cgroup *mem)
 	if (p->signal->oom_adj == OOM_DISABLE)
 		return 1;
 
+	/* If p's nodes don't overlap ours, it may not help to kill p. */
+	if (!has_intersects_mems_allowed(p))
+		return 1;
+
 	return 0;
 }
 
@@ -336,6 +332,8 @@ static void dump_tasks(const struct mem_cgroup *mem)
 			continue;
 		if (mem && !task_in_mem_cgroup(p, mem))
 			continue;
+		if (!has_intersects_mems_allowed(p))
+			continue;
 
 		task = find_lock_task_mm(p);
 		if (!task)
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
