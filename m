From: Nick Piggin <npiggin@suse.de>
Message-Id: <20060515210556.30275.63352.sendpatchset@linux.site>
In-Reply-To: <20060515210529.30275.74992.sendpatchset@linux.site>
References: <20060515210529.30275.74992.sendpatchset@linux.site>
Subject: [patch 3/9] cpuset: oom panic fix
Date: Fri, 28 Jul 2006 09:21:11 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Nick Piggin <npiggin@suse.de>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

cpuset_excl_nodes_overlap always returns 0 if current is exiting. This caused
customer's systems to panic in the OOM killer when processes were having
trouble getting memory for the final put_user in mm_release. Even though there
were lots of processes to kill.

Change to returning 0 in this case. This achieves parity with !CONFIG_CPUSETS
case, and was observed to fix the problem.

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/kernel/cpuset.c
===================================================================
--- linux-2.6.orig/kernel/cpuset.c
+++ linux-2.6/kernel/cpuset.c
@@ -2369,7 +2369,7 @@ EXPORT_SYMBOL_GPL(cpuset_mem_spread_node
 int cpuset_excl_nodes_overlap(const struct task_struct *p)
 {
 	const struct cpuset *cs1, *cs2;	/* my and p's cpuset ancestors */
-	int overlap = 0;		/* do cpusets overlap? */
+	int overlap = 1;		/* do cpusets overlap? */
 
 	task_lock(current);
 	if (current->flags & PF_EXITING) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
