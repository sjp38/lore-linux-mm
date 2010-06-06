Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6F7126B01CC
	for <linux-mm@kvack.org>; Sun,  6 Jun 2010 18:34:46 -0400 (EDT)
Received: from kpbe15.cbf.corp.google.com (kpbe15.cbf.corp.google.com [172.25.105.79])
	by smtp-out.google.com with ESMTP id o56MYjmr009476
	for <linux-mm@kvack.org>; Sun, 6 Jun 2010 15:34:45 -0700
Received: from pxi8 (pxi8.prod.google.com [10.243.27.8])
	by kpbe15.cbf.corp.google.com with ESMTP id o56MYho9011426
	for <linux-mm@kvack.org>; Sun, 6 Jun 2010 15:34:44 -0700
Received: by pxi8 with SMTP id 8so2215587pxi.5
        for <linux-mm@kvack.org>; Sun, 06 Jun 2010 15:34:43 -0700 (PDT)
Date: Sun, 6 Jun 2010 15:34:41 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 12/18] oom: extract panic helper function
In-Reply-To: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1006061526000.32225@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

There are various points in the oom killer where the kernel must
determine whether to panic or not.  It's better to extract this to a
helper function to remove all the confusion as to its semantics.

Also fix a call to dump_header() where tasklist_lock is not read-
locked, as required.

There's no functional change with this patch.

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/oom.h |    1 +
 mm/oom_kill.c       |   53 +++++++++++++++++++++++++++-----------------------
 2 files changed, 30 insertions(+), 24 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -22,6 +22,7 @@ enum oom_constraint {
 	CONSTRAINT_NONE,
 	CONSTRAINT_CPUSET,
 	CONSTRAINT_MEMORY_POLICY,
+	CONSTRAINT_MEMCG,
 };
 
 extern int try_set_zone_oom(struct zonelist *zonelist, gfp_t gfp_flags);
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -505,17 +505,40 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 	return oom_kill_task(victim);
 }
 
+/*
+ * Determines whether the kernel must panic because of the panic_on_oom sysctl.
+ */
+static void check_panic_on_oom(enum oom_constraint constraint, gfp_t gfp_mask,
+				int order)
+{
+	if (likely(!sysctl_panic_on_oom))
+		return;
+	if (sysctl_panic_on_oom != 2) {
+		/*
+		 * panic_on_oom == 1 only affects CONSTRAINT_NONE, the kernel
+		 * does not panic for cpuset, mempolicy, or memcg allocation
+		 * failures.
+		 */
+		if (constraint != CONSTRAINT_NONE)
+			return;
+	}
+	read_lock(&tasklist_lock);
+	dump_header(NULL, gfp_mask, order, NULL);
+	read_unlock(&tasklist_lock);
+	panic("Out of memory: %s panic_on_oom is enabled\n",
+		sysctl_panic_on_oom == 2 ? "compulsory" : "system-wide");
+}
+
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
 void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask)
 {
 	unsigned long points = 0;
 	struct task_struct *p;
 
-	if (sysctl_panic_on_oom == 2)
-		panic("out of memory(memcg). panic_on_oom is selected.\n");
+	check_panic_on_oom(CONSTRAINT_MEMCG, gfp_mask, 0);
 	read_lock(&tasklist_lock);
 retry:
-	p = select_bad_process(&points, mem, CONSTRAINT_NONE, NULL);
+	p = select_bad_process(&points, mem, CONSTRAINT_MEMCG, NULL);
 	if (!p || PTR_ERR(p) == -1UL)
 		goto out;
 
@@ -616,8 +639,8 @@ retry:
 
 	/* Found nothing?!?! Either we hang forever, or we panic. */
 	if (!p) {
-		read_unlock(&tasklist_lock);
 		dump_header(NULL, gfp_mask, order, NULL);
+		read_unlock(&tasklist_lock);
 		panic("Out of memory and no killable processes...\n");
 	}
 
@@ -639,9 +662,7 @@ void pagefault_out_of_memory(void)
 		/* Got some memory back in the last second. */
 		return;
 
-	if (sysctl_panic_on_oom)
-		panic("out of memory from page fault. panic_on_oom is selected.\n");
-
+	check_panic_on_oom(CONSTRAINT_NONE, 0, 0);
 	read_lock(&tasklist_lock);
 	/* unknown gfp_mask and order */
 	__out_of_memory(0, 0, CONSTRAINT_NONE, NULL);
@@ -688,29 +709,13 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 		return;
 	}
 
-	if (sysctl_panic_on_oom == 2) {
-		dump_header(NULL, gfp_mask, order, NULL);
-		panic("out of memory. Compulsory panic_on_oom is selected.\n");
-	}
-
 	/*
 	 * Check if there were limitations on the allocation (only relevant for
 	 * NUMA) that may require different handling.
 	 */
 	constraint = constrained_alloc(zonelist, gfp_mask, nodemask);
+	check_panic_on_oom(constraint, gfp_mask, order);
 	read_lock(&tasklist_lock);
-	if (unlikely(sysctl_panic_on_oom)) {
-		/*
-		 * panic_on_oom only affects CONSTRAINT_NONE, the kernel
-		 * should not panic for cpuset or mempolicy induced memory
-		 * failures.
-		 */
-		if (constraint == CONSTRAINT_NONE) {
-			dump_header(NULL, gfp_mask, order, NULL);
-			read_unlock(&tasklist_lock);
-			panic("Out of memory: panic_on_oom is enabled\n");
-		}
-	}
 	__out_of_memory(gfp_mask, order, constraint, nodemask);
 	read_unlock(&tasklist_lock);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
