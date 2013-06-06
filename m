Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 151EE6B0033
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 00:36:32 -0400 (EDT)
Date: Thu, 6 Jun 2013 00:36:20 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 1/2] arch: invoke oom-killer from page fault
Message-ID: <20130606043620.GA9406@cmpxchg.org>
References: <1370488193-4747-1-git-send-email-hannes@cmpxchg.org>
 <alpine.DEB.2.02.1306052053360.25115@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1306052053360.25115@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Jun 05, 2013 at 08:57:44PM -0700, David Rientjes wrote:
> On Wed, 5 Jun 2013, Johannes Weiner wrote:
> 
> > Since '1c0fe6e mm: invoke oom-killer from page fault', page fault
> > handlers should not directly kill faulting tasks in an out of memory
> > condition.
> 
> I have no objection to the patch, but there's no explanation given here 
> why exiting with a kill shouldn't be done.  Is it because of memory 
> reserves and there is no guarantee that current will be able to exit?  Or 
> is it just for consistency with other archs?
> 
> > Instead, they should be invoking the OOM killer to pick
> > the right task.  Convert the remaining architectures.
> > 
> 
> If this is a matter of memory reserves, I guess you could point people who 
> want the current behavior (avoiding the expensiveness of the tasklist scan 
> in the oom killer for example) to /proc/sys/vm/oom_kill_allocating_task?
> 
> This changelog is a bit cryptic in its motivation.

Fixing copy-pasted bitrot^W^W^W^WHow about this?

---
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] mm: invoke oom-killer from remaining unconverted page fault
 handlers

A few remaining architectures directly kill the page faulting task in
an out of memory situation.  This is usually not a good idea since
that task might not even use a significant amount of memory and so may
not be the optimal victim to resolve the situation.

Since '1c0fe6e mm: invoke oom-killer from page fault' (2.6.29) there
is a hook that architecture page fault handlers are supposed to call
to invoke the OOM killer and let it pick the right task to kill.
Convert the remaining architectures over to this hook.

To have the previous behavior of simply taking out the faulting task
the vm.oom_kill_allocating_task sysctl can be set to 1.

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
