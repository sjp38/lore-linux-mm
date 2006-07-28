From: Nick Piggin <npiggin@suse.de>
Message-Id: <20060515210605.30275.11106.sendpatchset@linux.site>
In-Reply-To: <20060515210529.30275.74992.sendpatchset@linux.site>
References: <20060515210529.30275.74992.sendpatchset@linux.site>
Subject: [patch 4/9] oom: cpuset hint
Date: Fri, 28 Jul 2006 09:21:19 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Nick Piggin <npiggin@suse.de>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

cpuset_excl_nodes_overlap does not always indicate that killing a task will
not free any memory we for us. For example, we may be asking for an allocation
from _anywhere_ in the machine, or the task in question may be pinning memory
that is outside its cpuset.  Fix this by just causing cpuset_excl_nodes_overlap
to reduce the badness rather than disallow it.

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/mm/oom_kill.c
===================================================================
--- linux-2.6.orig/mm/oom_kill.c
+++ linux-2.6/mm/oom_kill.c
@@ -127,6 +127,14 @@ unsigned long badness(struct task_struct
 		points /= 4;
 
 	/*
+	 * If p's nodes don't overlap ours, it may still help to kill p
+	 * because p may have allocated or otherwise mapped memory on
+	 * this node before. However it will be less likely.
+	 */
+	if (!cpuset_excl_nodes_overlap(p))
+		points /= 8;
+
+	/*
 	 * Adjust the score by oomkilladj.
 	 */
 	if (p->oomkilladj) {
@@ -196,9 +204,6 @@ static struct task_struct *select_bad_pr
 			continue;
 		if (p->oomkilladj == OOM_DISABLE)
 			continue;
-		/* If p's nodes don't overlap ours, it won't help to kill p. */
-		if (!cpuset_excl_nodes_overlap(p))
-			continue;
 
 		/*
 		 * This is in the process of releasing memory so wait for it

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
