Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 7A4586B0033
	for <linux-mm@kvack.org>; Fri, 19 Jul 2013 00:22:43 -0400 (EDT)
Date: Fri, 19 Jul 2013 00:22:38 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 1/5] mm: invoke oom-killer from remaining unconverted page
 fault handlers
Message-ID: <20130719042238.GD17812@cmpxchg.org>
References: <20130710182506.F25DF461@pobox.sk>
 <20130711072507.GA21667@dhcp22.suse.cz>
 <20130714012641.C2DA4E05@pobox.sk>
 <20130714015112.FFCB7AF7@pobox.sk>
 <20130715154119.GA32435@dhcp22.suse.cz>
 <20130715160006.GB32435@dhcp22.suse.cz>
 <20130716153544.GX17812@cmpxchg.org>
 <20130716160905.GA20018@dhcp22.suse.cz>
 <20130716164830.GZ17812@cmpxchg.org>
 <20130719042124.GC17812@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130719042124.GC17812@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: azurIt <azurit@pobox.sk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups mailinglist <cgroups@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, righi.andrea@gmail.com

[already upstream, included for 3.2 reference]

A few remaining architectures directly kill the page faulting task in an
out of memory situation.  This is usually not a good idea since that
task might not even use a significant amount of memory and so may not be
the optimal victim to resolve the situation.

Since 2.6.29's 1c0fe6e ("mm: invoke oom-killer from page fault") there
is a hook that architecture page fault handlers are supposed to call to
invoke the OOM killer and let it pick the right task to kill.  Convert
the remaining architectures over to this hook.

To have the previous behavior of simply taking out the faulting task the
vm.oom_kill_allocating_task sysctl can be set to 1.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Reviewed-by: Michal Hocko <mhocko@suse.cz>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Acked-by: David Rientjes <rientjes@google.com>
Acked-by: Vineet Gupta <vgupta@synopsys.com>   [arch/arc bits]
Cc: James Hogan <james.hogan@imgtec.com>
Cc: David Howells <dhowells@redhat.com>
Cc: Jonas Bonn <jonas@southpole.se>
Cc: Chen Liqin <liqin.chen@sunplusct.com>
Cc: Lennox Wu <lennox.wu@gmail.com>
Cc: Chris Metcalf <cmetcalf@tilera.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
---
 arch/mn10300/mm/fault.c  | 7 ++++---
 arch/openrisc/mm/fault.c | 8 ++++----
 arch/score/mm/fault.c    | 8 ++++----
 arch/tile/mm/fault.c     | 8 ++++----
 4 files changed, 16 insertions(+), 15 deletions(-)

diff --git a/arch/mn10300/mm/fault.c b/arch/mn10300/mm/fault.c
index 0945409..5ac4df5 100644
--- a/arch/mn10300/mm/fault.c
+++ b/arch/mn10300/mm/fault.c
@@ -329,9 +329,10 @@ no_context:
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
index a5dce82..d78881c 100644
--- a/arch/openrisc/mm/fault.c
+++ b/arch/openrisc/mm/fault.c
@@ -246,10 +246,10 @@ out_of_memory:
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
index 25b7b90..3312531 100644
--- a/arch/tile/mm/fault.c
+++ b/arch/tile/mm/fault.c
@@ -540,10 +540,10 @@ out_of_memory:
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
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
