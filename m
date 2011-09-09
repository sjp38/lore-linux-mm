Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 9BCFD6B01A2
	for <linux-mm@kvack.org>; Fri,  9 Sep 2011 06:15:28 -0400 (EDT)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id p89AFMpJ003849
	for <linux-mm@kvack.org>; Fri, 9 Sep 2011 03:15:25 -0700
Received: from pzk4 (pzk4.prod.google.com [10.243.19.132])
	by wpaz37.hot.corp.google.com with ESMTP id p89AEY3F009444
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 9 Sep 2011 03:15:21 -0700
Received: by pzk4 with SMTP id 4so2989694pzk.28
        for <linux-mm@kvack.org>; Fri, 09 Sep 2011 03:15:19 -0700 (PDT)
Date: Fri, 9 Sep 2011 03:15:17 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] cpusets: avoid looping when storing to mems_allowed if one
 node remains set
Message-ID: <alpine.DEB.2.00.1109090313130.23841@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Miao Xie <miaox@cn.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Paul Menage <paul@paulmenage.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

{get,put}_mems_allowed() exist so that general kernel code may locklessly
access a task's set of allowable nodes without having the chance that a
concurrent write will cause the nodemask to be empty on configurations
where MAX_NUMNODES > BITS_PER_LONG.

This could incur a significant delay, however, especially in low memory
conditions because the page allocator is blocking and reclaim requires
get_mems_allowed() itself.  It is not atypical to see writes to cpuset.mems
take over 2 seconds to complete, for example.  In low memory conditions,
this is problematic because it's one of the most imporant times to change
cpuset.mems in the first place!

The only way a task's set of allowable nodes may change is through
cpusets by writing to cpuset.mems and when attaching a task to a
different cpuset.  This is done by setting all new nodes, ensuring
generic code is not reading the nodemask with get_mems_allowed() at the
same time, and then clearing all the old nodes.  This prevents the
possibility that a reader will see an empty nodemask at the same time the
writer is storing a new nodemask.

If at least one node remains unchanged, though, it's possible to simply
set all new nodes and then clear all the old nodes.  Changing a task's
nodemask is protected by cgroup_mutex so it's guaranteed that two threads
are not changing the same task's nodemask at the same time, so the
nodemask is guaranteed to be stored before another thread changes it and
determines whether a node remains set or not.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 kernel/cpuset.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -949,6 +949,8 @@ static void cpuset_migrate_mm(struct mm_struct *mm, const nodemask_t *from,
 static void cpuset_change_task_nodemask(struct task_struct *tsk,
 					nodemask_t *newmems)
 {
+	bool masks_disjoint = !nodes_intersects(*newmems, tsk->mems_allowed);
+
 repeat:
 	/*
 	 * Allow tasks that have access to memory reserves because they have
@@ -963,7 +965,6 @@ repeat:
 	nodes_or(tsk->mems_allowed, tsk->mems_allowed, *newmems);
 	mpol_rebind_task(tsk, newmems, MPOL_REBIND_STEP1);
 
-
 	/*
 	 * ensure checking ->mems_allowed_change_disable after setting all new
 	 * allowed nodes.
@@ -980,9 +981,11 @@ repeat:
 
 	/*
 	 * Allocation of memory is very fast, we needn't sleep when waiting
-	 * for the read-side.
+	 * for the read-side.  No wait is necessary, however, if at least one
+	 * node remains unchanged.
 	 */
-	while (ACCESS_ONCE(tsk->mems_allowed_change_disable)) {
+	while (masks_disjoint &&
+			ACCESS_ONCE(tsk->mems_allowed_change_disable)) {
 		task_unlock(tsk);
 		if (!task_curr(tsk))
 			yield();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
