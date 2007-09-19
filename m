Date: Wed, 19 Sep 2007 11:24:37 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 6/8] oom: suppress extraneous stack and memory dump
In-Reply-To: <alpine.DEB.0.9999.0709190351140.23538@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.0.9999.0709190351290.23538@chino.kir.corp.google.com>
References: <alpine.DEB.0.9999.0709181950170.25510@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709190350001.23538@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709190350240.23538@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709190350410.23538@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709190350560.23538@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709190351140.23538@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <andrea@suse.de>, Christoph Lameter <clameter@sgi.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Suppresses the extraneous stack and memory dump when a parallel OOM
killing has been found.  There's no need to fill the ring buffer with
this information if its already been printed and the condition that
triggered the previous OOM killer has not yet been alleviated.

Cc: Andrea Arcangeli <andrea@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c |   27 ++++++++++++++-------------
 1 files changed, 14 insertions(+), 13 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -345,12 +345,20 @@ static int oom_kill_task(struct task_struct *p)
 	return 0;
 }
 
-static int oom_kill_process(struct task_struct *p, unsigned long points,
-		const char *message)
+static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
+			    unsigned long points, const char *message)
 {
 	struct task_struct *c;
 	struct list_head *tsk;
 
+	if (printk_ratelimit()) {
+		printk(KERN_WARNING "%s invoked oom-killer: "
+			"gfp_mask=0x%x, order=%d, oomkilladj=%d\n",
+			current->comm, gfp_mask, order, current->oomkilladj);
+		dump_stack();
+		show_mem();
+	}
+
 	/*
 	 * If the task is already exiting, don't alarm the sysadmin or kill
 	 * its children or threads, just set TIF_MEMDIE so it can die quickly
@@ -477,14 +485,6 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask, int order)
 		/* Got some memory back in the last second. */
 		return;
 
-	if (printk_ratelimit()) {
-		printk(KERN_WARNING "%s invoked oom-killer: "
-			"gfp_mask=0x%x, order=%d, oomkilladj=%d\n",
-			current->comm, gfp_mask, order, current->oomkilladj);
-		dump_stack();
-		show_mem();
-	}
-
 	if (sysctl_panic_on_oom == 2)
 		panic("out of memory. Compulsory panic_on_oom is selected.\n");
 
@@ -498,7 +498,7 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask, int order)
 
 	switch (constraint) {
 	case CONSTRAINT_MEMORY_POLICY:
-		oom_kill_process(current, points,
+		oom_kill_process(current, gfp_mask, order, points,
 				"No available memory (MPOL_BIND)");
 		break;
 
@@ -513,7 +513,7 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask, int order)
 		if (!oom_kill_asking_task(current))
 			goto retry;
 
-		oom_kill_process(current, points,
+		oom_kill_process(current, gfp_mask, order, points,
 				"No available memory in cpuset");
 		break;
 
@@ -537,7 +537,8 @@ retry:
 			panic("Out of memory and no killable processes...\n");
 		}
 
-		if (oom_kill_process(p, points, "Out of memory"))
+		if (oom_kill_process(p, gfp_mask, order, points,
+				     "Out of memory"))
 			goto retry;
 
 		break;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
