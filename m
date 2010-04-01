Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id C868B6B01EE
	for <linux-mm@kvack.org>; Thu,  1 Apr 2010 15:44:35 -0400 (EDT)
Received: from hpaq11.eem.corp.google.com (hpaq11.eem.corp.google.com [10.3.21.11])
	by smtp-out.google.com with ESMTP id o31JiWbm029459
	for <linux-mm@kvack.org>; Thu, 1 Apr 2010 21:44:32 +0200
Received: from pwi6 (pwi6.prod.google.com [10.241.219.6])
	by hpaq11.eem.corp.google.com with ESMTP id o31JiUCC016742
	for <linux-mm@kvack.org>; Thu, 1 Apr 2010 21:44:31 +0200
Received: by pwi6 with SMTP id 6so1288711pwi.32
        for <linux-mm@kvack.org>; Thu, 01 Apr 2010 12:44:30 -0700 (PDT)
Date: Thu, 1 Apr 2010 12:44:28 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm 1/5 v2] oom: hold tasklist_lock when dumping tasks
In-Reply-To: <alpine.DEB.2.00.1004011240370.13247@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1004011242420.13247@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1004011240370.13247@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

dump_header() always requires tasklist_lock to be held because it calls 
dump_tasks() which iterates through the tasklist.  There are a few places
where this isn't maintained, so make sure tasklist_lock is always held
whenever calling dump_header().

This also fixes the pagefault case where oom_kill_process() is called on
current without tasklist_lock.  It is necessary to hold a readlock for
both calling dump_header() and iterating its children.

Reported-by: Oleg Nesterov <oleg@redhat.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c |   23 ++++++++++-------------
 1 files changed, 10 insertions(+), 13 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -395,6 +395,9 @@ static void dump_tasks(const struct mem_cgroup *mem)
 	} while_each_thread(g, p);
 }
 
+/*
+ * Call with tasklist_lock read-locked.
+ */
 static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
 							struct mem_cgroup *mem)
 {
@@ -641,8 +644,8 @@ retry:
 
 	/* Found nothing?!?! Either we hang forever, or we panic. */
 	if (!p) {
-		read_unlock(&tasklist_lock);
 		dump_header(NULL, gfp_mask, order, NULL);
+		read_unlock(&tasklist_lock);
 		panic("Out of memory and no killable processes...\n");
 	}
 
@@ -675,11 +678,6 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 		/* Got some memory back in the last second. */
 		return;
 
-	if (sysctl_panic_on_oom == 2) {
-		dump_header(NULL, gfp_mask, order, NULL);
-		panic("out of memory. Compulsory panic_on_oom is selected.\n");
-	}
-
 	/*
 	 * Check if there were limitations on the allocation (only relevant for
 	 * NUMA) that may require different handling.
@@ -688,15 +686,12 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 						&totalpages);
 	read_lock(&tasklist_lock);
 	if (unlikely(sysctl_panic_on_oom)) {
-		/*
-		 * panic_on_oom only affects CONSTRAINT_NONE, the kernel
-		 * should not panic for cpuset or mempolicy induced memory
-		 * failures.
-		 */
-		if (constraint == CONSTRAINT_NONE) {
+		if (sysctl_panic_on_oom == 2 || constraint == CONSTRAINT_NONE) {
 			dump_header(NULL, gfp_mask, order, NULL);
 			read_unlock(&tasklist_lock);
-			panic("Out of memory: panic_on_oom is enabled\n");
+			panic("Out of memory: %s panic_on_oom is enabled\n",
+				sysctl_panic_on_oom == 2 ? "compulsory" :
+							   "system-wide");
 		}
 	}
 	__out_of_memory(gfp_mask, order, totalpages, constraint, nodemask);
@@ -724,8 +719,10 @@ void pagefault_out_of_memory(void)
 
 	if (try_set_system_oom()) {
 		constrained_alloc(NULL, 0, NULL, &totalpages);
+		read_lock(&tasklist_lock);
 		err = oom_kill_process(current, 0, 0, 0, totalpages, NULL,
 					"Out of memory (pagefault)");
+		read_unlock(&tasklist_lock);
 		if (err)
 			out_of_memory(NULL, 0, 0, NULL);
 		clear_system_oom();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
