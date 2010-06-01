Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id E15B16B01C4
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 03:18:27 -0400 (EDT)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id o517IM0F032564
	for <linux-mm@kvack.org>; Tue, 1 Jun 2010 00:18:23 -0700
Received: from pzk29 (pzk29.prod.google.com [10.243.19.157])
	by wpaz17.hot.corp.google.com with ESMTP id o517ILuR031825
	for <linux-mm@kvack.org>; Tue, 1 Jun 2010 00:18:21 -0700
Received: by pzk29 with SMTP id 29so1119367pzk.3
        for <linux-mm@kvack.org>; Tue, 01 Jun 2010 00:18:21 -0700 (PDT)
Date: Tue, 1 Jun 2010 00:18:18 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm 02/18] oom: sacrifice child with highest badness score
 for parent
In-Reply-To: <alpine.DEB.2.00.1006010008410.29202@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1006010013220.29202@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006010008410.29202@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

When a task is chosen for oom kill, the oom killer first attempts to
sacrifice a child not sharing its parent's memory instead.  Unfortunately,
this often kills in a seemingly random fashion based on the ordering of
the selected task's child list.  Additionally, it is not guaranteed at all
to free a large amount of memory that we need to prevent additional oom
killing in the very near future.

Instead, we now only attempt to sacrifice the worst child not sharing its
parent's memory, if one exists.  The worst child is indicated with the
highest badness() score.  This serves two advantages: we kill a
memory-hogging task more often, and we allow the configurable
/proc/pid/oom_adj value to be considered as a factor in which child to
kill.

Reviewers may observe that the previous implementation would iterate
through the children and attempt to kill each until one was successful and
then the parent if none were found while the new code simply kills the
most memory-hogging task or the parent.  Note that the only time
oom_kill_task() fails, however, is when a child does not have an mm or has
a /proc/pid/oom_adj of OOM_DISABLE.  badness() returns 0 for both cases,
so the final oom_kill_task() will always succeed.

Acked-by: Rik van Riel <riel@redhat.com>
Acked-by: Nick Piggin <npiggin@suse.de>
Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c |   23 +++++++++++++++++------
 1 files changed, 17 insertions(+), 6 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -433,7 +433,10 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 			    unsigned long points, struct mem_cgroup *mem,
 			    const char *message)
 {
+	struct task_struct *victim = p;
 	struct task_struct *c;
+	unsigned long victim_points = 0;
+	struct timespec uptime;
 
 	if (printk_ratelimit())
 		dump_header(p, gfp_mask, order, mem);
@@ -447,19 +450,27 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 		return 0;
 	}
 
-	printk(KERN_ERR "%s: kill process %d (%s) score %li or a child\n",
-					message, task_pid_nr(p), p->comm, points);
+	pr_err("%s: Kill process %d (%s) with score %lu or sacrifice child\n",
+		message, task_pid_nr(p), p->comm, points);
 
-	/* Try to kill a child first */
+	do_posix_clock_monotonic_gettime(&uptime);
+	/* Try to sacrifice the worst child first */
 	list_for_each_entry(c, &p->children, sibling) {
+		unsigned long cpoints;
+
 		if (c->mm == p->mm)
 			continue;
 		if (mem && !task_in_mem_cgroup(c, mem))
 			continue;
-		if (!oom_kill_task(c))
-			return 0;
+
+		/* badness() returns 0 if the thread is unkillable */
+		cpoints = badness(c, uptime.tv_sec);
+		if (cpoints > victim_points) {
+			victim = c;
+			victim_points = cpoints;
+		}
 	}
-	return oom_kill_task(p);
+	return oom_kill_task(victim);
 }
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
