Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 60B156B0078
	for <linux-mm@kvack.org>; Wed, 10 Feb 2010 11:32:14 -0500 (EST)
Received: from kpbe18.cbf.corp.google.com (kpbe18.cbf.corp.google.com [172.25.105.82])
	by smtp-out.google.com with ESMTP id o1AGWCQI018229
	for <linux-mm@kvack.org>; Wed, 10 Feb 2010 08:32:12 -0800
Received: from pzk27 (pzk27.prod.google.com [10.243.19.155])
	by kpbe18.cbf.corp.google.com with ESMTP id o1AGVctx027506
	for <linux-mm@kvack.org>; Wed, 10 Feb 2010 08:32:11 -0800
Received: by pzk27 with SMTP id 27so183137pzk.33
        for <linux-mm@kvack.org>; Wed, 10 Feb 2010 08:32:09 -0800 (PST)
Date: Wed, 10 Feb 2010 08:32:08 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch 1/7 -mm] oom: filter tasks not sharing the same cpuset
In-Reply-To: <alpine.DEB.2.00.1002100224210.8001@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1002100227590.8001@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002100224210.8001@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Tasks that do not share the same set of allowed nodes with the task that
triggered the oom should not be considered as candidates for oom kill.

Tasks in other cpusets with a disjoint set of mems would be unfairly
penalized otherwise because of oom conditions elsewhere; an extreme
example could unfairly kill all other applications on the system if a
single task in a user's cpuset sets itself to OOM_DISABLE and then uses
more memory than allowed.

Killing tasks outside of current's cpuset rarely would free memory for
current anyway.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c |   12 +++---------
 1 files changed, 3 insertions(+), 9 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -35,7 +35,7 @@ static DEFINE_SPINLOCK(zone_scan_lock);
 /* #define DEBUG */
 
 /*
- * Is all threads of the target process nodes overlap ours?
+ * Do all threads of the target process overlap our allowed nodes?
  */
 static int has_intersects_mems_allowed(struct task_struct *tsk)
 {
@@ -167,14 +167,6 @@ unsigned long badness(struct task_struct *p, unsigned long uptime)
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
@@ -266,6 +258,8 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
 			continue;
 		if (mem && !task_in_mem_cgroup(p, mem))
 			continue;
+		if (!has_intersects_mems_allowed(p))
+			continue;
 
 		/*
 		 * This task already has access to memory reserves and is

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
