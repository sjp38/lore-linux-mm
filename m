Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id DF9E36B0031
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 23:09:58 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 1/2] arch: invoke oom-killer from page fault
Date: Wed,  5 Jun 2013 23:09:52 -0400
Message-Id: <1370488193-4747-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

Since '1c0fe6e mm: invoke oom-killer from page fault', page fault
handlers should not directly kill faulting tasks in an out of memory
condition.  Instead, they should be invoking the OOM killer to pick
the right task.  Convert the remaining architectures.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 arch/arc/mm/fault.c      | 6 ++++--
 arch/metag/mm/fault.c    | 6 ++++--
 arch/mn10300/mm/fault.c  | 7 ++++---
 arch/openrisc/mm/fault.c | 8 ++++----
 arch/score/mm/fault.c    | 8 ++++----
 arch/tile/mm/fault.c     | 8 ++++----
 6 files changed, 24 insertions(+), 19 deletions(-)

diff --git a/arch/arc/mm/fault.c b/arch/arc/mm/fault.c
index c0decc1..d5ec60a 100644
--- a/arch/arc/mm/fault.c
+++ b/arch/arc/mm/fault.c
@@ -207,8 +207,10 @@ out_of_memory:
 	}
 	up_read(&mm->mmap_sem);
 
-	if (user_mode(regs))
-		do_group_exit(SIGKILL);	/* This will never return */
+	if (user_mode(regs)) {
+		pagefault_out_of_memory();
+		return;
+	}
 
 	goto no_context;
 
diff --git a/arch/metag/mm/fault.c b/arch/metag/mm/fault.c
index 2c75bf7..8fddf46 100644
--- a/arch/metag/mm/fault.c
+++ b/arch/metag/mm/fault.c
@@ -224,8 +224,10 @@ do_sigbus:
 	 */
 out_of_memory:
 	up_read(&mm->mmap_sem);
-	if (user_mode(regs))
-		do_group_exit(SIGKILL);
+	if (user_mode(regs)) {
+		pagefault_out_of_memory();
+		return 1;
+	}
 
 no_context:
 	/* Are we prepared to handle this kernel fault?  */
diff --git a/arch/mn10300/mm/fault.c b/arch/mn10300/mm/fault.c
index d48a84f..8a2e6de 100644
--- a/arch/mn10300/mm/fault.c
+++ b/arch/mn10300/mm/fault.c
@@ -345,9 +345,10 @@ no_context:
  */
 out_of_memory:
 	up_read(&mm->mmap_sem);
-	printk(KERN_ALERT "VM: killing process %s\n", tsk->comm);
-	if ((fault_code & MMUFCR_xFC_ACCESS) == MMUFCR_xFC_ACCESS_USR)
-		do_exit(SIGKILL);
+	if ((fault_code & MMUFCR_xFC_ACCESS) == MMUFCR_xFC_ACCESS_USR) {
+		pagefault_out_of_memory();
+		return;
+	}
 	goto no_context;
 
 do_sigbus:
diff --git a/arch/openrisc/mm/fault.c b/arch/openrisc/mm/fault.c
index e2bfafc..4a41f84 100644
--- a/arch/openrisc/mm/fault.c
+++ b/arch/openrisc/mm/fault.c
@@ -267,10 +267,10 @@ out_of_memory:
 	__asm__ __volatile__("l.nop 1");
 
 	up_read(&mm->mmap_sem);
-	printk("VM: killing process %s\n", tsk->comm);
-	if (user_mode(regs))
-		do_exit(SIGKILL);
-	goto no_context;
+	if (!user_mode(regs))
+		goto no_context;
+	pagefault_out_of_memory();
+	return;
 
 do_sigbus:
 	up_read(&mm->mmap_sem);
diff --git a/arch/score/mm/fault.c b/arch/score/mm/fault.c
index 47b600e..6b18fb0 100644
--- a/arch/score/mm/fault.c
+++ b/arch/score/mm/fault.c
@@ -172,10 +172,10 @@ out_of_memory:
 		down_read(&mm->mmap_sem);
 		goto survive;
 	}
-	printk("VM: killing process %s\n", tsk->comm);
-	if (user_mode(regs))
-		do_group_exit(SIGKILL);
-	goto no_context;
+	if (!user_mode(regs))
+		goto no_context;
+	pagefault_out_of_memory();
+	return;
 
 do_sigbus:
 	up_read(&mm->mmap_sem);
diff --git a/arch/tile/mm/fault.c b/arch/tile/mm/fault.c
index 3d2b81c..f7f99f9 100644
--- a/arch/tile/mm/fault.c
+++ b/arch/tile/mm/fault.c
@@ -573,10 +573,10 @@ out_of_memory:
 		down_read(&mm->mmap_sem);
 		goto survive;
 	}
-	pr_alert("VM: killing process %s\n", tsk->comm);
-	if (!is_kernel_mode)
-		do_group_exit(SIGKILL);
-	goto no_context;
+	if (is_kernel_mode)
+		goto no_context;
+	pagefault_out_of_memory();
+	return 0;
 
 do_sigbus:
 	up_read(&mm->mmap_sem);
-- 
1.8.2.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
